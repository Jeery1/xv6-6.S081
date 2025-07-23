
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	80010113          	addi	sp,sp,-2048 # 8000a800 <stack0>
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
    8000004a:	0000a617          	auipc	a2,0xa
    8000004e:	fb660613          	addi	a2,a2,-74 # 8000a000 <mscratch0>
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
    80000060:	00478793          	addi	a5,a5,4 # 80006060 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd57a3>
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
    80000112:	00012517          	auipc	a0,0x12
    80000116:	6ee50513          	addi	a0,a0,1774 # 80012800 <cons>
    8000011a:	00001097          	auipc	ra,0x1
    8000011e:	986080e7          	jalr	-1658(ra) # 80000aa0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000122:	00012497          	auipc	s1,0x12
    80000126:	6de48493          	addi	s1,s1,1758 # 80012800 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000012a:	00012917          	auipc	s2,0x12
    8000012e:	77690913          	addi	s2,s2,1910 # 800128a0 <cons+0xa0>
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
    8000014c:	910080e7          	jalr	-1776(ra) # 80001a58 <myproc>
    80000150:	5d1c                	lw	a5,56(a0)
    80000152:	e7b5                	bnez	a5,800001be <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    80000154:	85a6                	mv	a1,s1
    80000156:	854a                	mv	a0,s2
    80000158:	00002097          	auipc	ra,0x2
    8000015c:	0c0080e7          	jalr	192(ra) # 80002218 <sleep>
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
    80000198:	2de080e7          	jalr	734(ra) # 80002472 <either_copyout>
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
    800001a8:	00012517          	auipc	a0,0x12
    800001ac:	65850513          	addi	a0,a0,1624 # 80012800 <cons>
    800001b0:	00001097          	auipc	ra,0x1
    800001b4:	9c0080e7          	jalr	-1600(ra) # 80000b70 <release>

  return target - n;
    800001b8:	413b053b          	subw	a0,s6,s3
    800001bc:	a811                	j	800001d0 <consoleread+0xe4>
        release(&cons.lock);
    800001be:	00012517          	auipc	a0,0x12
    800001c2:	64250513          	addi	a0,a0,1602 # 80012800 <cons>
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
    800001f4:	00012717          	auipc	a4,0x12
    800001f8:	6af72623          	sw	a5,1708(a4) # 800128a0 <cons+0xa0>
    800001fc:	b775                	j	800001a8 <consoleread+0xbc>

00000000800001fe <consputc>:
  if(panicked){
    800001fe:	00029797          	auipc	a5,0x29
    80000202:	e227a783          	lw	a5,-478(a5) # 80029020 <panicked>
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
    80000264:	00012517          	auipc	a0,0x12
    80000268:	59c50513          	addi	a0,a0,1436 # 80012800 <cons>
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
    80000296:	236080e7          	jalr	566(ra) # 800024c8 <either_copyin>
    8000029a:	01450b63          	beq	a0,s4,800002b0 <consolewrite+0x64>
    consputc(c);
    8000029e:	fbf44503          	lbu	a0,-65(s0)
    800002a2:	00000097          	auipc	ra,0x0
    800002a6:	f5c080e7          	jalr	-164(ra) # 800001fe <consputc>
  for(i = 0; i < n; i++){
    800002aa:	0485                	addi	s1,s1,1
    800002ac:	fd249ee3          	bne	s1,s2,80000288 <consolewrite+0x3c>
  release(&cons.lock);
    800002b0:	00012517          	auipc	a0,0x12
    800002b4:	55050513          	addi	a0,a0,1360 # 80012800 <cons>
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
    800002e2:	00012517          	auipc	a0,0x12
    800002e6:	51e50513          	addi	a0,a0,1310 # 80012800 <cons>
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
    8000030c:	216080e7          	jalr	534(ra) # 8000251e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00012517          	auipc	a0,0x12
    80000314:	4f050513          	addi	a0,a0,1264 # 80012800 <cons>
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
    80000334:	00012717          	auipc	a4,0x12
    80000338:	4cc70713          	addi	a4,a4,1228 # 80012800 <cons>
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
    8000035e:	00012797          	auipc	a5,0x12
    80000362:	4a278793          	addi	a5,a5,1186 # 80012800 <cons>
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
    8000038c:	00012797          	auipc	a5,0x12
    80000390:	5147a783          	lw	a5,1300(a5) # 800128a0 <cons+0xa0>
    80000394:	0807879b          	addiw	a5,a5,128
    80000398:	f6f61ce3          	bne	a2,a5,80000310 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000039c:	863e                	mv	a2,a5
    8000039e:	a07d                	j	8000044c <consoleintr+0x178>
    while(cons.e != cons.w &&
    800003a0:	00012717          	auipc	a4,0x12
    800003a4:	46070713          	addi	a4,a4,1120 # 80012800 <cons>
    800003a8:	0a872783          	lw	a5,168(a4)
    800003ac:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b0:	00012497          	auipc	s1,0x12
    800003b4:	45048493          	addi	s1,s1,1104 # 80012800 <cons>
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
    800003ec:	00012717          	auipc	a4,0x12
    800003f0:	41470713          	addi	a4,a4,1044 # 80012800 <cons>
    800003f4:	0a872783          	lw	a5,168(a4)
    800003f8:	0a472703          	lw	a4,164(a4)
    800003fc:	f0f70ae3          	beq	a4,a5,80000310 <consoleintr+0x3c>
      cons.e--;
    80000400:	37fd                	addiw	a5,a5,-1
    80000402:	00012717          	auipc	a4,0x12
    80000406:	4af72323          	sw	a5,1190(a4) # 800128a8 <cons+0xa8>
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
    80000428:	00012797          	auipc	a5,0x12
    8000042c:	3d878793          	addi	a5,a5,984 # 80012800 <cons>
    80000430:	0a87a703          	lw	a4,168(a5)
    80000434:	0017069b          	addiw	a3,a4,1
    80000438:	0006861b          	sext.w	a2,a3
    8000043c:	0ad7a423          	sw	a3,168(a5)
    80000440:	07f77713          	andi	a4,a4,127
    80000444:	97ba                	add	a5,a5,a4
    80000446:	4729                	li	a4,10
    80000448:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    8000044c:	00012797          	auipc	a5,0x12
    80000450:	44c7ac23          	sw	a2,1112(a5) # 800128a4 <cons+0xa4>
        wakeup(&cons.r);
    80000454:	00012517          	auipc	a0,0x12
    80000458:	44c50513          	addi	a0,a0,1100 # 800128a0 <cons+0xa0>
    8000045c:	00002097          	auipc	ra,0x2
    80000460:	f3c080e7          	jalr	-196(ra) # 80002398 <wakeup>
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
    8000046e:	00008597          	auipc	a1,0x8
    80000472:	caa58593          	addi	a1,a1,-854 # 80008118 <userret+0x88>
    80000476:	00012517          	auipc	a0,0x12
    8000047a:	38a50513          	addi	a0,a0,906 # 80012800 <cons>
    8000047e:	00000097          	auipc	ra,0x0
    80000482:	54e080e7          	jalr	1358(ra) # 800009cc <initlock>

  uartinit();
    80000486:	00000097          	auipc	ra,0x0
    8000048a:	33a080e7          	jalr	826(ra) # 800007c0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000048e:	00021797          	auipc	a5,0x21
    80000492:	4d278793          	addi	a5,a5,1234 # 80021960 <devsw>
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
    800004d0:	00008617          	auipc	a2,0x8
    800004d4:	68060613          	addi	a2,a2,1664 # 80008b50 <digits>
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
    80000560:	00012797          	auipc	a5,0x12
    80000564:	3607a823          	sw	zero,880(a5) # 800128d0 <pr+0x20>
  printf("PANIC: ");
    80000568:	00008517          	auipc	a0,0x8
    8000056c:	bb850513          	addi	a0,a0,-1096 # 80008120 <userret+0x90>
    80000570:	00000097          	auipc	ra,0x0
    80000574:	03e080e7          	jalr	62(ra) # 800005ae <printf>
  printf(s);
    80000578:	8526                	mv	a0,s1
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	034080e7          	jalr	52(ra) # 800005ae <printf>
  printf("\n");
    80000582:	00008517          	auipc	a0,0x8
    80000586:	d0e50513          	addi	a0,a0,-754 # 80008290 <userret+0x200>
    8000058a:	00000097          	auipc	ra,0x0
    8000058e:	024080e7          	jalr	36(ra) # 800005ae <printf>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    80000592:	00008517          	auipc	a0,0x8
    80000596:	b9650513          	addi	a0,a0,-1130 # 80008128 <userret+0x98>
    8000059a:	00000097          	auipc	ra,0x0
    8000059e:	014080e7          	jalr	20(ra) # 800005ae <printf>
  panicked = 1; // freeze other CPUs
    800005a2:	4785                	li	a5,1
    800005a4:	00029717          	auipc	a4,0x29
    800005a8:	a6f72e23          	sw	a5,-1412(a4) # 80029020 <panicked>
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
    800005e0:	00012d97          	auipc	s11,0x12
    800005e4:	2f0dad83          	lw	s11,752(s11) # 800128d0 <pr+0x20>
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
    8000060c:	00008b17          	auipc	s6,0x8
    80000610:	544b0b13          	addi	s6,s6,1348 # 80008b50 <digits>
    switch(c){
    80000614:	07300c93          	li	s9,115
    80000618:	06400c13          	li	s8,100
    8000061c:	a82d                	j	80000656 <printf+0xa8>
    acquire(&pr.lock);
    8000061e:	00012517          	auipc	a0,0x12
    80000622:	29250513          	addi	a0,a0,658 # 800128b0 <pr>
    80000626:	00000097          	auipc	ra,0x0
    8000062a:	47a080e7          	jalr	1146(ra) # 80000aa0 <acquire>
    8000062e:	bf7d                	j	800005ec <printf+0x3e>
    panic("null fmt");
    80000630:	00008517          	auipc	a0,0x8
    80000634:	bd050513          	addi	a0,a0,-1072 # 80008200 <userret+0x170>
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
    8000072a:	00008497          	auipc	s1,0x8
    8000072e:	ace48493          	addi	s1,s1,-1330 # 800081f8 <userret+0x168>
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
    8000077c:	00012517          	auipc	a0,0x12
    80000780:	13450513          	addi	a0,a0,308 # 800128b0 <pr>
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
    80000798:	00012497          	auipc	s1,0x12
    8000079c:	11848493          	addi	s1,s1,280 # 800128b0 <pr>
    800007a0:	00008597          	auipc	a1,0x8
    800007a4:	a7058593          	addi	a1,a1,-1424 # 80008210 <userret+0x180>
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
    80000884:	00028797          	auipc	a5,0x28
    80000888:	7d878793          	addi	a5,a5,2008 # 8002905c <end>
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
    800008a4:	00012917          	auipc	s2,0x12
    800008a8:	03490913          	addi	s2,s2,52 # 800128d8 <kmem>
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
    800008d6:	00008517          	auipc	a0,0x8
    800008da:	94250513          	addi	a0,a0,-1726 # 80008218 <userret+0x188>
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
    80000938:	00008597          	auipc	a1,0x8
    8000093c:	8e858593          	addi	a1,a1,-1816 # 80008220 <userret+0x190>
    80000940:	00012517          	auipc	a0,0x12
    80000944:	f9850513          	addi	a0,a0,-104 # 800128d8 <kmem>
    80000948:	00000097          	auipc	ra,0x0
    8000094c:	084080e7          	jalr	132(ra) # 800009cc <initlock>
  freerange(end, (void*)PHYSTOP);
    80000950:	45c5                	li	a1,17
    80000952:	05ee                	slli	a1,a1,0x1b
    80000954:	00028517          	auipc	a0,0x28
    80000958:	70850513          	addi	a0,a0,1800 # 8002905c <end>
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
    80000976:	00012497          	auipc	s1,0x12
    8000097a:	f6248493          	addi	s1,s1,-158 # 800128d8 <kmem>
    8000097e:	8526                	mv	a0,s1
    80000980:	00000097          	auipc	ra,0x0
    80000984:	120080e7          	jalr	288(ra) # 80000aa0 <acquire>
  r = kmem.freelist;
    80000988:	7084                	ld	s1,32(s1)
  if(r)
    8000098a:	c885                	beqz	s1,800009ba <kalloc+0x4e>
    kmem.freelist = r->next;
    8000098c:	609c                	ld	a5,0(s1)
    8000098e:	00012517          	auipc	a0,0x12
    80000992:	f4a50513          	addi	a0,a0,-182 # 800128d8 <kmem>
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
    800009ba:	00012517          	auipc	a0,0x12
    800009be:	f1e50513          	addi	a0,a0,-226 # 800128d8 <kmem>
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
    800009de:	00028797          	auipc	a5,0x28
    800009e2:	6467a783          	lw	a5,1606(a5) # 80029024 <nlock>
    800009e6:	3e700713          	li	a4,999
    800009ea:	02f74063          	blt	a4,a5,80000a0a <initlock+0x3e>
    panic("initlock");
  locks[nlock] = lk;
    800009ee:	00379693          	slli	a3,a5,0x3
    800009f2:	00012717          	auipc	a4,0x12
    800009f6:	f0e70713          	addi	a4,a4,-242 # 80012900 <locks>
    800009fa:	9736                	add	a4,a4,a3
    800009fc:	e308                	sd	a0,0(a4)
  nlock++;
    800009fe:	2785                	addiw	a5,a5,1
    80000a00:	00028717          	auipc	a4,0x28
    80000a04:	62f72223          	sw	a5,1572(a4) # 80029024 <nlock>
    80000a08:	8082                	ret
{
    80000a0a:	1141                	addi	sp,sp,-16
    80000a0c:	e406                	sd	ra,8(sp)
    80000a0e:	e022                	sd	s0,0(sp)
    80000a10:	0800                	addi	s0,sp,16
    panic("initlock");
    80000a12:	00008517          	auipc	a0,0x8
    80000a16:	81650513          	addi	a0,a0,-2026 # 80008228 <userret+0x198>
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
    80000a3a:	006080e7          	jalr	6(ra) # 80001a3c <mycpu>
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
    80000a70:	fd0080e7          	jalr	-48(ra) # 80001a3c <mycpu>
    80000a74:	5d3c                	lw	a5,120(a0)
    80000a76:	cf89                	beqz	a5,80000a90 <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000a78:	00001097          	auipc	ra,0x1
    80000a7c:	fc4080e7          	jalr	-60(ra) # 80001a3c <mycpu>
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
    80000a94:	fac080e7          	jalr	-84(ra) # 80001a3c <mycpu>
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
    80000ad2:	00007517          	auipc	a0,0x7
    80000ad6:	76650513          	addi	a0,a0,1894 # 80008238 <userret+0x1a8>
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
    80000b00:	f40080e7          	jalr	-192(ra) # 80001a3c <mycpu>
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
    80000b24:	f1c080e7          	jalr	-228(ra) # 80001a3c <mycpu>
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
    80000b50:	00007517          	auipc	a0,0x7
    80000b54:	6f050513          	addi	a0,a0,1776 # 80008240 <userret+0x1b0>
    80000b58:	00000097          	auipc	ra,0x0
    80000b5c:	9fc080e7          	jalr	-1540(ra) # 80000554 <panic>
    panic("pop_off");
    80000b60:	00007517          	auipc	a0,0x7
    80000b64:	6f850513          	addi	a0,a0,1784 # 80008258 <userret+0x1c8>
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
    80000ba8:	00007517          	auipc	a0,0x7
    80000bac:	6b850513          	addi	a0,a0,1720 # 80008260 <userret+0x1d0>
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
    80000bca:	00007517          	auipc	a0,0x7
    80000bce:	69e50513          	addi	a0,a0,1694 # 80008268 <userret+0x1d8>
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
    80000c08:	eae080e7          	jalr	-338(ra) # 80002ab2 <argint>
    80000c0c:	14054d63          	bltz	a0,80000d66 <sys_ntas+0x184>
    return -1;
  }
  if(zero == 0) {
    80000c10:	fac42783          	lw	a5,-84(s0)
    80000c14:	e78d                	bnez	a5,80000c3e <sys_ntas+0x5c>
    80000c16:	00012797          	auipc	a5,0x12
    80000c1a:	cea78793          	addi	a5,a5,-790 # 80012900 <locks>
    80000c1e:	00014697          	auipc	a3,0x14
    80000c22:	c2268693          	addi	a3,a3,-990 # 80014840 <pid_lock>
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
    80000c3e:	00007517          	auipc	a0,0x7
    80000c42:	65a50513          	addi	a0,a0,1626 # 80008298 <userret+0x208>
    80000c46:	00000097          	auipc	ra,0x0
    80000c4a:	968080e7          	jalr	-1688(ra) # 800005ae <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000c4e:	00012b17          	auipc	s6,0x12
    80000c52:	cb2b0b13          	addi	s6,s6,-846 # 80012900 <locks>
    80000c56:	00014b97          	auipc	s7,0x14
    80000c5a:	beab8b93          	addi	s7,s7,-1046 # 80014840 <pid_lock>
  printf("=== lock kmem/bcache stats\n");
    80000c5e:	84da                	mv	s1,s6
  int tot = 0;
    80000c60:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000c62:	00007a17          	auipc	s4,0x7
    80000c66:	656a0a13          	addi	s4,s4,1622 # 800082b8 <userret+0x228>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000c6a:	00007c17          	auipc	s8,0x7
    80000c6e:	5b6c0c13          	addi	s8,s8,1462 # 80008220 <userret+0x190>
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
    80000cd6:	00007517          	auipc	a0,0x7
    80000cda:	5ea50513          	addi	a0,a0,1514 # 800082c0 <userret+0x230>
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
    80000cf2:	00012497          	auipc	s1,0x12
    80000cf6:	c0e48493          	addi	s1,s1,-1010 # 80012900 <locks>
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
    80000f28:	b08080e7          	jalr	-1272(ra) # 80001a2c <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f2c:	00028717          	auipc	a4,0x28
    80000f30:	0fc70713          	addi	a4,a4,252 # 80029028 <started>
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
    80000f44:	aec080e7          	jalr	-1300(ra) # 80001a2c <cpuid>
    80000f48:	85aa                	mv	a1,a0
    80000f4a:	00007517          	auipc	a0,0x7
    80000f4e:	3ae50513          	addi	a0,a0,942 # 800082f8 <userret+0x268>
    80000f52:	fffff097          	auipc	ra,0xfffff
    80000f56:	65c080e7          	jalr	1628(ra) # 800005ae <printf>
    kvminithart();    // turn on paging
    80000f5a:	00000097          	auipc	ra,0x0
    80000f5e:	1ea080e7          	jalr	490(ra) # 80001144 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f62:	00001097          	auipc	ra,0x1
    80000f66:	6fc080e7          	jalr	1788(ra) # 8000265e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	136080e7          	jalr	310(ra) # 800060a0 <plicinithart>
  }

  scheduler();        
    80000f72:	00001097          	auipc	ra,0x1
    80000f76:	fc4080e7          	jalr	-60(ra) # 80001f36 <scheduler>
    consoleinit();
    80000f7a:	fffff097          	auipc	ra,0xfffff
    80000f7e:	4ec080e7          	jalr	1260(ra) # 80000466 <consoleinit>
    printfinit();
    80000f82:	00000097          	auipc	ra,0x0
    80000f86:	80c080e7          	jalr	-2036(ra) # 8000078e <printfinit>
    printf("\n");
    80000f8a:	00007517          	auipc	a0,0x7
    80000f8e:	30650513          	addi	a0,a0,774 # 80008290 <userret+0x200>
    80000f92:	fffff097          	auipc	ra,0xfffff
    80000f96:	61c080e7          	jalr	1564(ra) # 800005ae <printf>
    printf("xv6 kernel is booting\n");
    80000f9a:	00007517          	auipc	a0,0x7
    80000f9e:	34650513          	addi	a0,a0,838 # 800082e0 <userret+0x250>
    80000fa2:	fffff097          	auipc	ra,0xfffff
    80000fa6:	60c080e7          	jalr	1548(ra) # 800005ae <printf>
    printf("\n");
    80000faa:	00007517          	auipc	a0,0x7
    80000fae:	2e650513          	addi	a0,a0,742 # 80008290 <userret+0x200>
    80000fb2:	fffff097          	auipc	ra,0xfffff
    80000fb6:	5fc080e7          	jalr	1532(ra) # 800005ae <printf>
    kinit();         // physical page allocator
    80000fba:	00000097          	auipc	ra,0x0
    80000fbe:	976080e7          	jalr	-1674(ra) # 80000930 <kinit>
    kvminit();       // create kernel page table
    80000fc2:	00000097          	auipc	ra,0x0
    80000fc6:	30c080e7          	jalr	780(ra) # 800012ce <kvminit>
    kvminithart();   // turn on paging
    80000fca:	00000097          	auipc	ra,0x0
    80000fce:	17a080e7          	jalr	378(ra) # 80001144 <kvminithart>
    procinit();      // process table
    80000fd2:	00001097          	auipc	ra,0x1
    80000fd6:	98a080e7          	jalr	-1654(ra) # 8000195c <procinit>
    trapinit();      // trap vectors
    80000fda:	00001097          	auipc	ra,0x1
    80000fde:	65c080e7          	jalr	1628(ra) # 80002636 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fe2:	00001097          	auipc	ra,0x1
    80000fe6:	67c080e7          	jalr	1660(ra) # 8000265e <trapinithart>
    plicinit();      // set up interrupt controller
    80000fea:	00005097          	auipc	ra,0x5
    80000fee:	0a0080e7          	jalr	160(ra) # 8000608a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ff2:	00005097          	auipc	ra,0x5
    80000ff6:	0ae080e7          	jalr	174(ra) # 800060a0 <plicinithart>
    binit();         // buffer cache
    80000ffa:	00002097          	auipc	ra,0x2
    80000ffe:	d98080e7          	jalr	-616(ra) # 80002d92 <binit>
    iinit();         // inode cache
    80001002:	00002097          	auipc	ra,0x2
    80001006:	4f0080e7          	jalr	1264(ra) # 800034f2 <iinit>
    fileinit();      // file table
    8000100a:	00003097          	auipc	ra,0x3
    8000100e:	65e080e7          	jalr	1630(ra) # 80004668 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80001012:	4501                	li	a0,0
    80001014:	00005097          	auipc	ra,0x5
    80001018:	1ae080e7          	jalr	430(ra) # 800061c2 <virtio_disk_init>
    userinit();      // first user process
    8000101c:	00001097          	auipc	ra,0x1
    80001020:	cb0080e7          	jalr	-848(ra) # 80001ccc <userinit>
    __sync_synchronize();
    80001024:	0ff0000f          	fence
    started = 1;
    80001028:	4785                	li	a5,1
    8000102a:	00028717          	auipc	a4,0x28
    8000102e:	fef72f23          	sw	a5,-2(a4) # 80029028 <started>
    80001032:	b781                	j	80000f72 <main+0x56>

0000000080001034 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001034:	7139                	addi	sp,sp,-64
    80001036:	fc06                	sd	ra,56(sp)
    80001038:	f822                	sd	s0,48(sp)
    8000103a:	f426                	sd	s1,40(sp)
    8000103c:	f04a                	sd	s2,32(sp)
    8000103e:	ec4e                	sd	s3,24(sp)
    80001040:	e852                	sd	s4,16(sp)
    80001042:	e456                	sd	s5,8(sp)
    80001044:	e05a                	sd	s6,0(sp)
    80001046:	0080                	addi	s0,sp,64
    80001048:	84aa                	mv	s1,a0
    8000104a:	89ae                	mv	s3,a1
    8000104c:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000104e:	57fd                	li	a5,-1
    80001050:	83e9                	srli	a5,a5,0x1a
    80001052:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001054:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001056:	04b7f263          	bgeu	a5,a1,8000109a <walk+0x66>
    panic("walk");
    8000105a:	00007517          	auipc	a0,0x7
    8000105e:	2b650513          	addi	a0,a0,694 # 80008310 <userret+0x280>
    80001062:	fffff097          	auipc	ra,0xfffff
    80001066:	4f2080e7          	jalr	1266(ra) # 80000554 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000106a:	060a8663          	beqz	s5,800010d6 <walk+0xa2>
    8000106e:	00000097          	auipc	ra,0x0
    80001072:	8fe080e7          	jalr	-1794(ra) # 8000096c <kalloc>
    80001076:	84aa                	mv	s1,a0
    80001078:	c529                	beqz	a0,800010c2 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000107a:	6605                	lui	a2,0x1
    8000107c:	4581                	li	a1,0
    8000107e:	00000097          	auipc	ra,0x0
    80001082:	cf0080e7          	jalr	-784(ra) # 80000d6e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001086:	00c4d793          	srli	a5,s1,0xc
    8000108a:	07aa                	slli	a5,a5,0xa
    8000108c:	0017e793          	ori	a5,a5,1
    80001090:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001094:	3a5d                	addiw	s4,s4,-9
    80001096:	036a0063          	beq	s4,s6,800010b6 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000109a:	0149d933          	srl	s2,s3,s4
    8000109e:	1ff97913          	andi	s2,s2,511
    800010a2:	090e                	slli	s2,s2,0x3
    800010a4:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010a6:	00093483          	ld	s1,0(s2)
    800010aa:	0014f793          	andi	a5,s1,1
    800010ae:	dfd5                	beqz	a5,8000106a <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010b0:	80a9                	srli	s1,s1,0xa
    800010b2:	04b2                	slli	s1,s1,0xc
    800010b4:	b7c5                	j	80001094 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010b6:	00c9d513          	srli	a0,s3,0xc
    800010ba:	1ff57513          	andi	a0,a0,511
    800010be:	050e                	slli	a0,a0,0x3
    800010c0:	9526                	add	a0,a0,s1
}
    800010c2:	70e2                	ld	ra,56(sp)
    800010c4:	7442                	ld	s0,48(sp)
    800010c6:	74a2                	ld	s1,40(sp)
    800010c8:	7902                	ld	s2,32(sp)
    800010ca:	69e2                	ld	s3,24(sp)
    800010cc:	6a42                	ld	s4,16(sp)
    800010ce:	6aa2                	ld	s5,8(sp)
    800010d0:	6b02                	ld	s6,0(sp)
    800010d2:	6121                	addi	sp,sp,64
    800010d4:	8082                	ret
        return 0;
    800010d6:	4501                	li	a0,0
    800010d8:	b7ed                	j	800010c2 <walk+0x8e>

00000000800010da <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    800010da:	7179                	addi	sp,sp,-48
    800010dc:	f406                	sd	ra,40(sp)
    800010de:	f022                	sd	s0,32(sp)
    800010e0:	ec26                	sd	s1,24(sp)
    800010e2:	e84a                	sd	s2,16(sp)
    800010e4:	e44e                	sd	s3,8(sp)
    800010e6:	e052                	sd	s4,0(sp)
    800010e8:	1800                	addi	s0,sp,48
    800010ea:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800010ec:	84aa                	mv	s1,a0
    800010ee:	6905                	lui	s2,0x1
    800010f0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800010f2:	4985                	li	s3,1
    800010f4:	a821                	j	8000110c <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800010f6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800010f8:	0532                	slli	a0,a0,0xc
    800010fa:	00000097          	auipc	ra,0x0
    800010fe:	fe0080e7          	jalr	-32(ra) # 800010da <freewalk>
      pagetable[i] = 0;
    80001102:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001106:	04a1                	addi	s1,s1,8
    80001108:	03248163          	beq	s1,s2,8000112a <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000110c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000110e:	00f57793          	andi	a5,a0,15
    80001112:	ff3782e3          	beq	a5,s3,800010f6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001116:	8905                	andi	a0,a0,1
    80001118:	d57d                	beqz	a0,80001106 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000111a:	00007517          	auipc	a0,0x7
    8000111e:	1fe50513          	addi	a0,a0,510 # 80008318 <userret+0x288>
    80001122:	fffff097          	auipc	ra,0xfffff
    80001126:	432080e7          	jalr	1074(ra) # 80000554 <panic>
    }
  }
  kfree((void*)pagetable);
    8000112a:	8552                	mv	a0,s4
    8000112c:	fffff097          	auipc	ra,0xfffff
    80001130:	744080e7          	jalr	1860(ra) # 80000870 <kfree>
}
    80001134:	70a2                	ld	ra,40(sp)
    80001136:	7402                	ld	s0,32(sp)
    80001138:	64e2                	ld	s1,24(sp)
    8000113a:	6942                	ld	s2,16(sp)
    8000113c:	69a2                	ld	s3,8(sp)
    8000113e:	6a02                	ld	s4,0(sp)
    80001140:	6145                	addi	sp,sp,48
    80001142:	8082                	ret

0000000080001144 <kvminithart>:
{
    80001144:	1141                	addi	sp,sp,-16
    80001146:	e422                	sd	s0,8(sp)
    80001148:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000114a:	00028797          	auipc	a5,0x28
    8000114e:	ee67b783          	ld	a5,-282(a5) # 80029030 <kernel_pagetable>
    80001152:	83b1                	srli	a5,a5,0xc
    80001154:	577d                	li	a4,-1
    80001156:	177e                	slli	a4,a4,0x3f
    80001158:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000115a:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000115e:	12000073          	sfence.vma
}
    80001162:	6422                	ld	s0,8(sp)
    80001164:	0141                	addi	sp,sp,16
    80001166:	8082                	ret

0000000080001168 <walkaddr>:
  if(va >= MAXVA)
    80001168:	57fd                	li	a5,-1
    8000116a:	83e9                	srli	a5,a5,0x1a
    8000116c:	00b7f463          	bgeu	a5,a1,80001174 <walkaddr+0xc>
    return 0;
    80001170:	4501                	li	a0,0
}
    80001172:	8082                	ret
{
    80001174:	1141                	addi	sp,sp,-16
    80001176:	e406                	sd	ra,8(sp)
    80001178:	e022                	sd	s0,0(sp)
    8000117a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000117c:	4601                	li	a2,0
    8000117e:	00000097          	auipc	ra,0x0
    80001182:	eb6080e7          	jalr	-330(ra) # 80001034 <walk>
  if(pte == 0)
    80001186:	c105                	beqz	a0,800011a6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001188:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000118a:	0117f693          	andi	a3,a5,17
    8000118e:	4745                	li	a4,17
    return 0;
    80001190:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001192:	00e68663          	beq	a3,a4,8000119e <walkaddr+0x36>
}
    80001196:	60a2                	ld	ra,8(sp)
    80001198:	6402                	ld	s0,0(sp)
    8000119a:	0141                	addi	sp,sp,16
    8000119c:	8082                	ret
  pa = PTE2PA(*pte);
    8000119e:	00a7d513          	srli	a0,a5,0xa
    800011a2:	0532                	slli	a0,a0,0xc
  return pa;
    800011a4:	bfcd                	j	80001196 <walkaddr+0x2e>
    return 0;
    800011a6:	4501                	li	a0,0
    800011a8:	b7fd                	j	80001196 <walkaddr+0x2e>

00000000800011aa <kvmpa>:
{
    800011aa:	1101                	addi	sp,sp,-32
    800011ac:	ec06                	sd	ra,24(sp)
    800011ae:	e822                	sd	s0,16(sp)
    800011b0:	e426                	sd	s1,8(sp)
    800011b2:	1000                	addi	s0,sp,32
    800011b4:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800011b6:	1552                	slli	a0,a0,0x34
    800011b8:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    800011bc:	4601                	li	a2,0
    800011be:	00028517          	auipc	a0,0x28
    800011c2:	e7253503          	ld	a0,-398(a0) # 80029030 <kernel_pagetable>
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	e6e080e7          	jalr	-402(ra) # 80001034 <walk>
  if(pte == 0)
    800011ce:	cd09                	beqz	a0,800011e8 <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    800011d0:	6108                	ld	a0,0(a0)
    800011d2:	00157793          	andi	a5,a0,1
    800011d6:	c38d                	beqz	a5,800011f8 <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    800011d8:	8129                	srli	a0,a0,0xa
    800011da:	0532                	slli	a0,a0,0xc
}
    800011dc:	9526                	add	a0,a0,s1
    800011de:	60e2                	ld	ra,24(sp)
    800011e0:	6442                	ld	s0,16(sp)
    800011e2:	64a2                	ld	s1,8(sp)
    800011e4:	6105                	addi	sp,sp,32
    800011e6:	8082                	ret
    panic("kvmpa");
    800011e8:	00007517          	auipc	a0,0x7
    800011ec:	14050513          	addi	a0,a0,320 # 80008328 <userret+0x298>
    800011f0:	fffff097          	auipc	ra,0xfffff
    800011f4:	364080e7          	jalr	868(ra) # 80000554 <panic>
    panic("kvmpa");
    800011f8:	00007517          	auipc	a0,0x7
    800011fc:	13050513          	addi	a0,a0,304 # 80008328 <userret+0x298>
    80001200:	fffff097          	auipc	ra,0xfffff
    80001204:	354080e7          	jalr	852(ra) # 80000554 <panic>

0000000080001208 <mappages>:
{
    80001208:	715d                	addi	sp,sp,-80
    8000120a:	e486                	sd	ra,72(sp)
    8000120c:	e0a2                	sd	s0,64(sp)
    8000120e:	fc26                	sd	s1,56(sp)
    80001210:	f84a                	sd	s2,48(sp)
    80001212:	f44e                	sd	s3,40(sp)
    80001214:	f052                	sd	s4,32(sp)
    80001216:	ec56                	sd	s5,24(sp)
    80001218:	e85a                	sd	s6,16(sp)
    8000121a:	e45e                	sd	s7,8(sp)
    8000121c:	0880                	addi	s0,sp,80
    8000121e:	8aaa                	mv	s5,a0
    80001220:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    80001222:	777d                	lui	a4,0xfffff
    80001224:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001228:	167d                	addi	a2,a2,-1
    8000122a:	00b609b3          	add	s3,a2,a1
    8000122e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001232:	893e                	mv	s2,a5
    80001234:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    80001238:	6b85                	lui	s7,0x1
    8000123a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000123e:	4605                	li	a2,1
    80001240:	85ca                	mv	a1,s2
    80001242:	8556                	mv	a0,s5
    80001244:	00000097          	auipc	ra,0x0
    80001248:	df0080e7          	jalr	-528(ra) # 80001034 <walk>
    8000124c:	c51d                	beqz	a0,8000127a <mappages+0x72>
    if(*pte & PTE_V)
    8000124e:	611c                	ld	a5,0(a0)
    80001250:	8b85                	andi	a5,a5,1
    80001252:	ef81                	bnez	a5,8000126a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001254:	80b1                	srli	s1,s1,0xc
    80001256:	04aa                	slli	s1,s1,0xa
    80001258:	0164e4b3          	or	s1,s1,s6
    8000125c:	0014e493          	ori	s1,s1,1
    80001260:	e104                	sd	s1,0(a0)
    if(a == last)
    80001262:	03390863          	beq	s2,s3,80001292 <mappages+0x8a>
    a += PGSIZE;
    80001266:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001268:	bfc9                	j	8000123a <mappages+0x32>
      panic("remap");
    8000126a:	00007517          	auipc	a0,0x7
    8000126e:	0c650513          	addi	a0,a0,198 # 80008330 <userret+0x2a0>
    80001272:	fffff097          	auipc	ra,0xfffff
    80001276:	2e2080e7          	jalr	738(ra) # 80000554 <panic>
      return -1;
    8000127a:	557d                	li	a0,-1
}
    8000127c:	60a6                	ld	ra,72(sp)
    8000127e:	6406                	ld	s0,64(sp)
    80001280:	74e2                	ld	s1,56(sp)
    80001282:	7942                	ld	s2,48(sp)
    80001284:	79a2                	ld	s3,40(sp)
    80001286:	7a02                	ld	s4,32(sp)
    80001288:	6ae2                	ld	s5,24(sp)
    8000128a:	6b42                	ld	s6,16(sp)
    8000128c:	6ba2                	ld	s7,8(sp)
    8000128e:	6161                	addi	sp,sp,80
    80001290:	8082                	ret
  return 0;
    80001292:	4501                	li	a0,0
    80001294:	b7e5                	j	8000127c <mappages+0x74>

0000000080001296 <kvmmap>:
{
    80001296:	1141                	addi	sp,sp,-16
    80001298:	e406                	sd	ra,8(sp)
    8000129a:	e022                	sd	s0,0(sp)
    8000129c:	0800                	addi	s0,sp,16
    8000129e:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800012a0:	86ae                	mv	a3,a1
    800012a2:	85aa                	mv	a1,a0
    800012a4:	00028517          	auipc	a0,0x28
    800012a8:	d8c53503          	ld	a0,-628(a0) # 80029030 <kernel_pagetable>
    800012ac:	00000097          	auipc	ra,0x0
    800012b0:	f5c080e7          	jalr	-164(ra) # 80001208 <mappages>
    800012b4:	e509                	bnez	a0,800012be <kvmmap+0x28>
}
    800012b6:	60a2                	ld	ra,8(sp)
    800012b8:	6402                	ld	s0,0(sp)
    800012ba:	0141                	addi	sp,sp,16
    800012bc:	8082                	ret
    panic("kvmmap");
    800012be:	00007517          	auipc	a0,0x7
    800012c2:	07a50513          	addi	a0,a0,122 # 80008338 <userret+0x2a8>
    800012c6:	fffff097          	auipc	ra,0xfffff
    800012ca:	28e080e7          	jalr	654(ra) # 80000554 <panic>

00000000800012ce <kvminit>:
{
    800012ce:	1101                	addi	sp,sp,-32
    800012d0:	ec06                	sd	ra,24(sp)
    800012d2:	e822                	sd	s0,16(sp)
    800012d4:	e426                	sd	s1,8(sp)
    800012d6:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800012d8:	fffff097          	auipc	ra,0xfffff
    800012dc:	694080e7          	jalr	1684(ra) # 8000096c <kalloc>
    800012e0:	00028797          	auipc	a5,0x28
    800012e4:	d4a7b823          	sd	a0,-688(a5) # 80029030 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800012e8:	6605                	lui	a2,0x1
    800012ea:	4581                	li	a1,0
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	a82080e7          	jalr	-1406(ra) # 80000d6e <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012f4:	4699                	li	a3,6
    800012f6:	6605                	lui	a2,0x1
    800012f8:	100005b7          	lui	a1,0x10000
    800012fc:	10000537          	lui	a0,0x10000
    80001300:	00000097          	auipc	ra,0x0
    80001304:	f96080e7          	jalr	-106(ra) # 80001296 <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    80001308:	4699                	li	a3,6
    8000130a:	6605                	lui	a2,0x1
    8000130c:	100015b7          	lui	a1,0x10001
    80001310:	10001537          	lui	a0,0x10001
    80001314:	00000097          	auipc	ra,0x0
    80001318:	f82080e7          	jalr	-126(ra) # 80001296 <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    8000131c:	4699                	li	a3,6
    8000131e:	6605                	lui	a2,0x1
    80001320:	100025b7          	lui	a1,0x10002
    80001324:	10002537          	lui	a0,0x10002
    80001328:	00000097          	auipc	ra,0x0
    8000132c:	f6e080e7          	jalr	-146(ra) # 80001296 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001330:	4699                	li	a3,6
    80001332:	6641                	lui	a2,0x10
    80001334:	020005b7          	lui	a1,0x2000
    80001338:	02000537          	lui	a0,0x2000
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	f5a080e7          	jalr	-166(ra) # 80001296 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001344:	4699                	li	a3,6
    80001346:	00400637          	lui	a2,0x400
    8000134a:	0c0005b7          	lui	a1,0xc000
    8000134e:	0c000537          	lui	a0,0xc000
    80001352:	00000097          	auipc	ra,0x0
    80001356:	f44080e7          	jalr	-188(ra) # 80001296 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000135a:	00008497          	auipc	s1,0x8
    8000135e:	ca648493          	addi	s1,s1,-858 # 80009000 <initcode>
    80001362:	46a9                	li	a3,10
    80001364:	80008617          	auipc	a2,0x80008
    80001368:	c9c60613          	addi	a2,a2,-868 # 9000 <_entry-0x7fff7000>
    8000136c:	4585                	li	a1,1
    8000136e:	05fe                	slli	a1,a1,0x1f
    80001370:	852e                	mv	a0,a1
    80001372:	00000097          	auipc	ra,0x0
    80001376:	f24080e7          	jalr	-220(ra) # 80001296 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000137a:	4699                	li	a3,6
    8000137c:	4645                	li	a2,17
    8000137e:	066e                	slli	a2,a2,0x1b
    80001380:	8e05                	sub	a2,a2,s1
    80001382:	85a6                	mv	a1,s1
    80001384:	8526                	mv	a0,s1
    80001386:	00000097          	auipc	ra,0x0
    8000138a:	f10080e7          	jalr	-240(ra) # 80001296 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000138e:	46a9                	li	a3,10
    80001390:	6605                	lui	a2,0x1
    80001392:	00007597          	auipc	a1,0x7
    80001396:	c6e58593          	addi	a1,a1,-914 # 80008000 <trampoline>
    8000139a:	04000537          	lui	a0,0x4000
    8000139e:	157d                	addi	a0,a0,-1
    800013a0:	0532                	slli	a0,a0,0xc
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	ef4080e7          	jalr	-268(ra) # 80001296 <kvmmap>
}
    800013aa:	60e2                	ld	ra,24(sp)
    800013ac:	6442                	ld	s0,16(sp)
    800013ae:	64a2                	ld	s1,8(sp)
    800013b0:	6105                	addi	sp,sp,32
    800013b2:	8082                	ret

00000000800013b4 <uvmunmap>:
{
    800013b4:	715d                	addi	sp,sp,-80
    800013b6:	e486                	sd	ra,72(sp)
    800013b8:	e0a2                	sd	s0,64(sp)
    800013ba:	fc26                	sd	s1,56(sp)
    800013bc:	f84a                	sd	s2,48(sp)
    800013be:	f44e                	sd	s3,40(sp)
    800013c0:	f052                	sd	s4,32(sp)
    800013c2:	ec56                	sd	s5,24(sp)
    800013c4:	e85a                	sd	s6,16(sp)
    800013c6:	e45e                	sd	s7,8(sp)
    800013c8:	0880                	addi	s0,sp,80
    800013ca:	8a2a                	mv	s4,a0
    800013cc:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    800013ce:	77fd                	lui	a5,0xfffff
    800013d0:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800013d4:	167d                	addi	a2,a2,-1
    800013d6:	00b609b3          	add	s3,a2,a1
    800013da:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    800013de:	4b05                	li	s6,1
    a += PGSIZE;
    800013e0:	6b85                	lui	s7,0x1
    800013e2:	a0b9                	j	80001430 <uvmunmap+0x7c>
      panic("uvmunmap: walk");
    800013e4:	00007517          	auipc	a0,0x7
    800013e8:	f5c50513          	addi	a0,a0,-164 # 80008340 <userret+0x2b0>
    800013ec:	fffff097          	auipc	ra,0xfffff
    800013f0:	168080e7          	jalr	360(ra) # 80000554 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800013f4:	85ca                	mv	a1,s2
    800013f6:	00007517          	auipc	a0,0x7
    800013fa:	f5a50513          	addi	a0,a0,-166 # 80008350 <userret+0x2c0>
    800013fe:	fffff097          	auipc	ra,0xfffff
    80001402:	1b0080e7          	jalr	432(ra) # 800005ae <printf>
      panic("uvmunmap: not mapped");
    80001406:	00007517          	auipc	a0,0x7
    8000140a:	f5a50513          	addi	a0,a0,-166 # 80008360 <userret+0x2d0>
    8000140e:	fffff097          	auipc	ra,0xfffff
    80001412:	146080e7          	jalr	326(ra) # 80000554 <panic>
      panic("uvmunmap: not a leaf");
    80001416:	00007517          	auipc	a0,0x7
    8000141a:	f6250513          	addi	a0,a0,-158 # 80008378 <userret+0x2e8>
    8000141e:	fffff097          	auipc	ra,0xfffff
    80001422:	136080e7          	jalr	310(ra) # 80000554 <panic>
    *pte = 0;
    80001426:	0004b023          	sd	zero,0(s1)
    if(a == last)
    8000142a:	03390e63          	beq	s2,s3,80001466 <uvmunmap+0xb2>
    a += PGSIZE;
    8000142e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    80001430:	4601                	li	a2,0
    80001432:	85ca                	mv	a1,s2
    80001434:	8552                	mv	a0,s4
    80001436:	00000097          	auipc	ra,0x0
    8000143a:	bfe080e7          	jalr	-1026(ra) # 80001034 <walk>
    8000143e:	84aa                	mv	s1,a0
    80001440:	d155                	beqz	a0,800013e4 <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    80001442:	6110                	ld	a2,0(a0)
    80001444:	00167793          	andi	a5,a2,1
    80001448:	d7d5                	beqz	a5,800013f4 <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000144a:	3ff67793          	andi	a5,a2,1023
    8000144e:	fd6784e3          	beq	a5,s6,80001416 <uvmunmap+0x62>
    if(do_free){
    80001452:	fc0a8ae3          	beqz	s5,80001426 <uvmunmap+0x72>
      pa = PTE2PA(*pte);
    80001456:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    80001458:	00c61513          	slli	a0,a2,0xc
    8000145c:	fffff097          	auipc	ra,0xfffff
    80001460:	414080e7          	jalr	1044(ra) # 80000870 <kfree>
    80001464:	b7c9                	j	80001426 <uvmunmap+0x72>
}
    80001466:	60a6                	ld	ra,72(sp)
    80001468:	6406                	ld	s0,64(sp)
    8000146a:	74e2                	ld	s1,56(sp)
    8000146c:	7942                	ld	s2,48(sp)
    8000146e:	79a2                	ld	s3,40(sp)
    80001470:	7a02                	ld	s4,32(sp)
    80001472:	6ae2                	ld	s5,24(sp)
    80001474:	6b42                	ld	s6,16(sp)
    80001476:	6ba2                	ld	s7,8(sp)
    80001478:	6161                	addi	sp,sp,80
    8000147a:	8082                	ret

000000008000147c <uvmcreate>:
{
    8000147c:	1101                	addi	sp,sp,-32
    8000147e:	ec06                	sd	ra,24(sp)
    80001480:	e822                	sd	s0,16(sp)
    80001482:	e426                	sd	s1,8(sp)
    80001484:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    80001486:	fffff097          	auipc	ra,0xfffff
    8000148a:	4e6080e7          	jalr	1254(ra) # 8000096c <kalloc>
  if(pagetable == 0)
    8000148e:	cd11                	beqz	a0,800014aa <uvmcreate+0x2e>
    80001490:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    80001492:	6605                	lui	a2,0x1
    80001494:	4581                	li	a1,0
    80001496:	00000097          	auipc	ra,0x0
    8000149a:	8d8080e7          	jalr	-1832(ra) # 80000d6e <memset>
}
    8000149e:	8526                	mv	a0,s1
    800014a0:	60e2                	ld	ra,24(sp)
    800014a2:	6442                	ld	s0,16(sp)
    800014a4:	64a2                	ld	s1,8(sp)
    800014a6:	6105                	addi	sp,sp,32
    800014a8:	8082                	ret
    panic("uvmcreate: out of memory");
    800014aa:	00007517          	auipc	a0,0x7
    800014ae:	ee650513          	addi	a0,a0,-282 # 80008390 <userret+0x300>
    800014b2:	fffff097          	auipc	ra,0xfffff
    800014b6:	0a2080e7          	jalr	162(ra) # 80000554 <panic>

00000000800014ba <uvminit>:
{
    800014ba:	7179                	addi	sp,sp,-48
    800014bc:	f406                	sd	ra,40(sp)
    800014be:	f022                	sd	s0,32(sp)
    800014c0:	ec26                	sd	s1,24(sp)
    800014c2:	e84a                	sd	s2,16(sp)
    800014c4:	e44e                	sd	s3,8(sp)
    800014c6:	e052                	sd	s4,0(sp)
    800014c8:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    800014ca:	6785                	lui	a5,0x1
    800014cc:	04f67863          	bgeu	a2,a5,8000151c <uvminit+0x62>
    800014d0:	8a2a                	mv	s4,a0
    800014d2:	89ae                	mv	s3,a1
    800014d4:	84b2                	mv	s1,a2
  mem = kalloc();
    800014d6:	fffff097          	auipc	ra,0xfffff
    800014da:	496080e7          	jalr	1174(ra) # 8000096c <kalloc>
    800014de:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014e0:	6605                	lui	a2,0x1
    800014e2:	4581                	li	a1,0
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	88a080e7          	jalr	-1910(ra) # 80000d6e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014ec:	4779                	li	a4,30
    800014ee:	86ca                	mv	a3,s2
    800014f0:	6605                	lui	a2,0x1
    800014f2:	4581                	li	a1,0
    800014f4:	8552                	mv	a0,s4
    800014f6:	00000097          	auipc	ra,0x0
    800014fa:	d12080e7          	jalr	-750(ra) # 80001208 <mappages>
  memmove(mem, src, sz);
    800014fe:	8626                	mv	a2,s1
    80001500:	85ce                	mv	a1,s3
    80001502:	854a                	mv	a0,s2
    80001504:	00000097          	auipc	ra,0x0
    80001508:	8c6080e7          	jalr	-1850(ra) # 80000dca <memmove>
}
    8000150c:	70a2                	ld	ra,40(sp)
    8000150e:	7402                	ld	s0,32(sp)
    80001510:	64e2                	ld	s1,24(sp)
    80001512:	6942                	ld	s2,16(sp)
    80001514:	69a2                	ld	s3,8(sp)
    80001516:	6a02                	ld	s4,0(sp)
    80001518:	6145                	addi	sp,sp,48
    8000151a:	8082                	ret
    panic("inituvm: more than a page");
    8000151c:	00007517          	auipc	a0,0x7
    80001520:	e9450513          	addi	a0,a0,-364 # 800083b0 <userret+0x320>
    80001524:	fffff097          	auipc	ra,0xfffff
    80001528:	030080e7          	jalr	48(ra) # 80000554 <panic>

000000008000152c <uvmdealloc>:
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    return oldsz;
    80001536:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001538:	00b67d63          	bgeu	a2,a1,80001552 <uvmdealloc+0x26>
    8000153c:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    8000153e:	6785                	lui	a5,0x1
    80001540:	17fd                	addi	a5,a5,-1
    80001542:	00f60733          	add	a4,a2,a5
    80001546:	76fd                	lui	a3,0xfffff
    80001548:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    8000154a:	97ae                	add	a5,a5,a1
    8000154c:	8ff5                	and	a5,a5,a3
    8000154e:	00f76863          	bltu	a4,a5,8000155e <uvmdealloc+0x32>
}
    80001552:	8526                	mv	a0,s1
    80001554:	60e2                	ld	ra,24(sp)
    80001556:	6442                	ld	s0,16(sp)
    80001558:	64a2                	ld	s1,8(sp)
    8000155a:	6105                	addi	sp,sp,32
    8000155c:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    8000155e:	4685                	li	a3,1
    80001560:	40e58633          	sub	a2,a1,a4
    80001564:	85ba                	mv	a1,a4
    80001566:	00000097          	auipc	ra,0x0
    8000156a:	e4e080e7          	jalr	-434(ra) # 800013b4 <uvmunmap>
    8000156e:	b7d5                	j	80001552 <uvmdealloc+0x26>

0000000080001570 <uvmalloc>:
  if(newsz < oldsz)
    80001570:	0ab66163          	bltu	a2,a1,80001612 <uvmalloc+0xa2>
{
    80001574:	7139                	addi	sp,sp,-64
    80001576:	fc06                	sd	ra,56(sp)
    80001578:	f822                	sd	s0,48(sp)
    8000157a:	f426                	sd	s1,40(sp)
    8000157c:	f04a                	sd	s2,32(sp)
    8000157e:	ec4e                	sd	s3,24(sp)
    80001580:	e852                	sd	s4,16(sp)
    80001582:	e456                	sd	s5,8(sp)
    80001584:	0080                	addi	s0,sp,64
    80001586:	8aaa                	mv	s5,a0
    80001588:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000158a:	6985                	lui	s3,0x1
    8000158c:	19fd                	addi	s3,s3,-1
    8000158e:	95ce                	add	a1,a1,s3
    80001590:	79fd                	lui	s3,0xfffff
    80001592:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    80001596:	08c9f063          	bgeu	s3,a2,80001616 <uvmalloc+0xa6>
  a = oldsz;
    8000159a:	894e                	mv	s2,s3
    mem = kalloc();
    8000159c:	fffff097          	auipc	ra,0xfffff
    800015a0:	3d0080e7          	jalr	976(ra) # 8000096c <kalloc>
    800015a4:	84aa                	mv	s1,a0
    if(mem == 0){
    800015a6:	c51d                	beqz	a0,800015d4 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800015a8:	6605                	lui	a2,0x1
    800015aa:	4581                	li	a1,0
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	7c2080e7          	jalr	1986(ra) # 80000d6e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800015b4:	4779                	li	a4,30
    800015b6:	86a6                	mv	a3,s1
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85ca                	mv	a1,s2
    800015bc:	8556                	mv	a0,s5
    800015be:	00000097          	auipc	ra,0x0
    800015c2:	c4a080e7          	jalr	-950(ra) # 80001208 <mappages>
    800015c6:	e905                	bnez	a0,800015f6 <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    800015c8:	6785                	lui	a5,0x1
    800015ca:	993e                	add	s2,s2,a5
    800015cc:	fd4968e3          	bltu	s2,s4,8000159c <uvmalloc+0x2c>
  return newsz;
    800015d0:	8552                	mv	a0,s4
    800015d2:	a809                	j	800015e4 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800015d4:	864e                	mv	a2,s3
    800015d6:	85ca                	mv	a1,s2
    800015d8:	8556                	mv	a0,s5
    800015da:	00000097          	auipc	ra,0x0
    800015de:	f52080e7          	jalr	-174(ra) # 8000152c <uvmdealloc>
      return 0;
    800015e2:	4501                	li	a0,0
}
    800015e4:	70e2                	ld	ra,56(sp)
    800015e6:	7442                	ld	s0,48(sp)
    800015e8:	74a2                	ld	s1,40(sp)
    800015ea:	7902                	ld	s2,32(sp)
    800015ec:	69e2                	ld	s3,24(sp)
    800015ee:	6a42                	ld	s4,16(sp)
    800015f0:	6aa2                	ld	s5,8(sp)
    800015f2:	6121                	addi	sp,sp,64
    800015f4:	8082                	ret
      kfree(mem);
    800015f6:	8526                	mv	a0,s1
    800015f8:	fffff097          	auipc	ra,0xfffff
    800015fc:	278080e7          	jalr	632(ra) # 80000870 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001600:	864e                	mv	a2,s3
    80001602:	85ca                	mv	a1,s2
    80001604:	8556                	mv	a0,s5
    80001606:	00000097          	auipc	ra,0x0
    8000160a:	f26080e7          	jalr	-218(ra) # 8000152c <uvmdealloc>
      return 0;
    8000160e:	4501                	li	a0,0
    80001610:	bfd1                	j	800015e4 <uvmalloc+0x74>
    return oldsz;
    80001612:	852e                	mv	a0,a1
}
    80001614:	8082                	ret
  return newsz;
    80001616:	8532                	mv	a0,a2
    80001618:	b7f1                	j	800015e4 <uvmalloc+0x74>

000000008000161a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000161a:	1101                	addi	sp,sp,-32
    8000161c:	ec06                	sd	ra,24(sp)
    8000161e:	e822                	sd	s0,16(sp)
    80001620:	e426                	sd	s1,8(sp)
    80001622:	1000                	addi	s0,sp,32
    80001624:	84aa                	mv	s1,a0
    80001626:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001628:	4685                	li	a3,1
    8000162a:	4581                	li	a1,0
    8000162c:	00000097          	auipc	ra,0x0
    80001630:	d88080e7          	jalr	-632(ra) # 800013b4 <uvmunmap>
  freewalk(pagetable);
    80001634:	8526                	mv	a0,s1
    80001636:	00000097          	auipc	ra,0x0
    8000163a:	aa4080e7          	jalr	-1372(ra) # 800010da <freewalk>
}
    8000163e:	60e2                	ld	ra,24(sp)
    80001640:	6442                	ld	s0,16(sp)
    80001642:	64a2                	ld	s1,8(sp)
    80001644:	6105                	addi	sp,sp,32
    80001646:	8082                	ret

0000000080001648 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001648:	c671                	beqz	a2,80001714 <uvmcopy+0xcc>
{
    8000164a:	715d                	addi	sp,sp,-80
    8000164c:	e486                	sd	ra,72(sp)
    8000164e:	e0a2                	sd	s0,64(sp)
    80001650:	fc26                	sd	s1,56(sp)
    80001652:	f84a                	sd	s2,48(sp)
    80001654:	f44e                	sd	s3,40(sp)
    80001656:	f052                	sd	s4,32(sp)
    80001658:	ec56                	sd	s5,24(sp)
    8000165a:	e85a                	sd	s6,16(sp)
    8000165c:	e45e                	sd	s7,8(sp)
    8000165e:	0880                	addi	s0,sp,80
    80001660:	8b2a                	mv	s6,a0
    80001662:	8aae                	mv	s5,a1
    80001664:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001666:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001668:	4601                	li	a2,0
    8000166a:	85ce                	mv	a1,s3
    8000166c:	855a                	mv	a0,s6
    8000166e:	00000097          	auipc	ra,0x0
    80001672:	9c6080e7          	jalr	-1594(ra) # 80001034 <walk>
    80001676:	c531                	beqz	a0,800016c2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001678:	6118                	ld	a4,0(a0)
    8000167a:	00177793          	andi	a5,a4,1
    8000167e:	cbb1                	beqz	a5,800016d2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001680:	00a75593          	srli	a1,a4,0xa
    80001684:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001688:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000168c:	fffff097          	auipc	ra,0xfffff
    80001690:	2e0080e7          	jalr	736(ra) # 8000096c <kalloc>
    80001694:	892a                	mv	s2,a0
    80001696:	c939                	beqz	a0,800016ec <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001698:	6605                	lui	a2,0x1
    8000169a:	85de                	mv	a1,s7
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	72e080e7          	jalr	1838(ra) # 80000dca <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016a4:	8726                	mv	a4,s1
    800016a6:	86ca                	mv	a3,s2
    800016a8:	6605                	lui	a2,0x1
    800016aa:	85ce                	mv	a1,s3
    800016ac:	8556                	mv	a0,s5
    800016ae:	00000097          	auipc	ra,0x0
    800016b2:	b5a080e7          	jalr	-1190(ra) # 80001208 <mappages>
    800016b6:	e515                	bnez	a0,800016e2 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800016b8:	6785                	lui	a5,0x1
    800016ba:	99be                	add	s3,s3,a5
    800016bc:	fb49e6e3          	bltu	s3,s4,80001668 <uvmcopy+0x20>
    800016c0:	a83d                	j	800016fe <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    800016c2:	00007517          	auipc	a0,0x7
    800016c6:	d0e50513          	addi	a0,a0,-754 # 800083d0 <userret+0x340>
    800016ca:	fffff097          	auipc	ra,0xfffff
    800016ce:	e8a080e7          	jalr	-374(ra) # 80000554 <panic>
      panic("uvmcopy: page not present");
    800016d2:	00007517          	auipc	a0,0x7
    800016d6:	d1e50513          	addi	a0,a0,-738 # 800083f0 <userret+0x360>
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	e7a080e7          	jalr	-390(ra) # 80000554 <panic>
      kfree(mem);
    800016e2:	854a                	mv	a0,s2
    800016e4:	fffff097          	auipc	ra,0xfffff
    800016e8:	18c080e7          	jalr	396(ra) # 80000870 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800016ec:	4685                	li	a3,1
    800016ee:	864e                	mv	a2,s3
    800016f0:	4581                	li	a1,0
    800016f2:	8556                	mv	a0,s5
    800016f4:	00000097          	auipc	ra,0x0
    800016f8:	cc0080e7          	jalr	-832(ra) # 800013b4 <uvmunmap>
  return -1;
    800016fc:	557d                	li	a0,-1
}
    800016fe:	60a6                	ld	ra,72(sp)
    80001700:	6406                	ld	s0,64(sp)
    80001702:	74e2                	ld	s1,56(sp)
    80001704:	7942                	ld	s2,48(sp)
    80001706:	79a2                	ld	s3,40(sp)
    80001708:	7a02                	ld	s4,32(sp)
    8000170a:	6ae2                	ld	s5,24(sp)
    8000170c:	6b42                	ld	s6,16(sp)
    8000170e:	6ba2                	ld	s7,8(sp)
    80001710:	6161                	addi	sp,sp,80
    80001712:	8082                	ret
  return 0;
    80001714:	4501                	li	a0,0
}
    80001716:	8082                	ret

0000000080001718 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001718:	1141                	addi	sp,sp,-16
    8000171a:	e406                	sd	ra,8(sp)
    8000171c:	e022                	sd	s0,0(sp)
    8000171e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001720:	4601                	li	a2,0
    80001722:	00000097          	auipc	ra,0x0
    80001726:	912080e7          	jalr	-1774(ra) # 80001034 <walk>
  if(pte == 0)
    8000172a:	c901                	beqz	a0,8000173a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000172c:	611c                	ld	a5,0(a0)
    8000172e:	9bbd                	andi	a5,a5,-17
    80001730:	e11c                	sd	a5,0(a0)
}
    80001732:	60a2                	ld	ra,8(sp)
    80001734:	6402                	ld	s0,0(sp)
    80001736:	0141                	addi	sp,sp,16
    80001738:	8082                	ret
    panic("uvmclear");
    8000173a:	00007517          	auipc	a0,0x7
    8000173e:	cd650513          	addi	a0,a0,-810 # 80008410 <userret+0x380>
    80001742:	fffff097          	auipc	ra,0xfffff
    80001746:	e12080e7          	jalr	-494(ra) # 80000554 <panic>

000000008000174a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000174a:	c6bd                	beqz	a3,800017b8 <copyout+0x6e>
{
    8000174c:	715d                	addi	sp,sp,-80
    8000174e:	e486                	sd	ra,72(sp)
    80001750:	e0a2                	sd	s0,64(sp)
    80001752:	fc26                	sd	s1,56(sp)
    80001754:	f84a                	sd	s2,48(sp)
    80001756:	f44e                	sd	s3,40(sp)
    80001758:	f052                	sd	s4,32(sp)
    8000175a:	ec56                	sd	s5,24(sp)
    8000175c:	e85a                	sd	s6,16(sp)
    8000175e:	e45e                	sd	s7,8(sp)
    80001760:	e062                	sd	s8,0(sp)
    80001762:	0880                	addi	s0,sp,80
    80001764:	8b2a                	mv	s6,a0
    80001766:	8c2e                	mv	s8,a1
    80001768:	8a32                	mv	s4,a2
    8000176a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000176c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000176e:	6a85                	lui	s5,0x1
    80001770:	a015                	j	80001794 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001772:	9562                	add	a0,a0,s8
    80001774:	0004861b          	sext.w	a2,s1
    80001778:	85d2                	mv	a1,s4
    8000177a:	41250533          	sub	a0,a0,s2
    8000177e:	fffff097          	auipc	ra,0xfffff
    80001782:	64c080e7          	jalr	1612(ra) # 80000dca <memmove>

    len -= n;
    80001786:	409989b3          	sub	s3,s3,s1
    src += n;
    8000178a:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000178c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001790:	02098263          	beqz	s3,800017b4 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001794:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001798:	85ca                	mv	a1,s2
    8000179a:	855a                	mv	a0,s6
    8000179c:	00000097          	auipc	ra,0x0
    800017a0:	9cc080e7          	jalr	-1588(ra) # 80001168 <walkaddr>
    if(pa0 == 0)
    800017a4:	cd01                	beqz	a0,800017bc <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800017a6:	418904b3          	sub	s1,s2,s8
    800017aa:	94d6                	add	s1,s1,s5
    if(n > len)
    800017ac:	fc99f3e3          	bgeu	s3,s1,80001772 <copyout+0x28>
    800017b0:	84ce                	mv	s1,s3
    800017b2:	b7c1                	j	80001772 <copyout+0x28>
  }
  return 0;
    800017b4:	4501                	li	a0,0
    800017b6:	a021                	j	800017be <copyout+0x74>
    800017b8:	4501                	li	a0,0
}
    800017ba:	8082                	ret
      return -1;
    800017bc:	557d                	li	a0,-1
}
    800017be:	60a6                	ld	ra,72(sp)
    800017c0:	6406                	ld	s0,64(sp)
    800017c2:	74e2                	ld	s1,56(sp)
    800017c4:	7942                	ld	s2,48(sp)
    800017c6:	79a2                	ld	s3,40(sp)
    800017c8:	7a02                	ld	s4,32(sp)
    800017ca:	6ae2                	ld	s5,24(sp)
    800017cc:	6b42                	ld	s6,16(sp)
    800017ce:	6ba2                	ld	s7,8(sp)
    800017d0:	6c02                	ld	s8,0(sp)
    800017d2:	6161                	addi	sp,sp,80
    800017d4:	8082                	ret

00000000800017d6 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017d6:	caa5                	beqz	a3,80001846 <copyin+0x70>
{
    800017d8:	715d                	addi	sp,sp,-80
    800017da:	e486                	sd	ra,72(sp)
    800017dc:	e0a2                	sd	s0,64(sp)
    800017de:	fc26                	sd	s1,56(sp)
    800017e0:	f84a                	sd	s2,48(sp)
    800017e2:	f44e                	sd	s3,40(sp)
    800017e4:	f052                	sd	s4,32(sp)
    800017e6:	ec56                	sd	s5,24(sp)
    800017e8:	e85a                	sd	s6,16(sp)
    800017ea:	e45e                	sd	s7,8(sp)
    800017ec:	e062                	sd	s8,0(sp)
    800017ee:	0880                	addi	s0,sp,80
    800017f0:	8b2a                	mv	s6,a0
    800017f2:	8a2e                	mv	s4,a1
    800017f4:	8c32                	mv	s8,a2
    800017f6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017f8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017fa:	6a85                	lui	s5,0x1
    800017fc:	a01d                	j	80001822 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017fe:	018505b3          	add	a1,a0,s8
    80001802:	0004861b          	sext.w	a2,s1
    80001806:	412585b3          	sub	a1,a1,s2
    8000180a:	8552                	mv	a0,s4
    8000180c:	fffff097          	auipc	ra,0xfffff
    80001810:	5be080e7          	jalr	1470(ra) # 80000dca <memmove>

    len -= n;
    80001814:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001818:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000181a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000181e:	02098263          	beqz	s3,80001842 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001822:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001826:	85ca                	mv	a1,s2
    80001828:	855a                	mv	a0,s6
    8000182a:	00000097          	auipc	ra,0x0
    8000182e:	93e080e7          	jalr	-1730(ra) # 80001168 <walkaddr>
    if(pa0 == 0)
    80001832:	cd01                	beqz	a0,8000184a <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001834:	418904b3          	sub	s1,s2,s8
    80001838:	94d6                	add	s1,s1,s5
    if(n > len)
    8000183a:	fc99f2e3          	bgeu	s3,s1,800017fe <copyin+0x28>
    8000183e:	84ce                	mv	s1,s3
    80001840:	bf7d                	j	800017fe <copyin+0x28>
  }
  return 0;
    80001842:	4501                	li	a0,0
    80001844:	a021                	j	8000184c <copyin+0x76>
    80001846:	4501                	li	a0,0
}
    80001848:	8082                	ret
      return -1;
    8000184a:	557d                	li	a0,-1
}
    8000184c:	60a6                	ld	ra,72(sp)
    8000184e:	6406                	ld	s0,64(sp)
    80001850:	74e2                	ld	s1,56(sp)
    80001852:	7942                	ld	s2,48(sp)
    80001854:	79a2                	ld	s3,40(sp)
    80001856:	7a02                	ld	s4,32(sp)
    80001858:	6ae2                	ld	s5,24(sp)
    8000185a:	6b42                	ld	s6,16(sp)
    8000185c:	6ba2                	ld	s7,8(sp)
    8000185e:	6c02                	ld	s8,0(sp)
    80001860:	6161                	addi	sp,sp,80
    80001862:	8082                	ret

0000000080001864 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001864:	c6c5                	beqz	a3,8000190c <copyinstr+0xa8>
{
    80001866:	715d                	addi	sp,sp,-80
    80001868:	e486                	sd	ra,72(sp)
    8000186a:	e0a2                	sd	s0,64(sp)
    8000186c:	fc26                	sd	s1,56(sp)
    8000186e:	f84a                	sd	s2,48(sp)
    80001870:	f44e                	sd	s3,40(sp)
    80001872:	f052                	sd	s4,32(sp)
    80001874:	ec56                	sd	s5,24(sp)
    80001876:	e85a                	sd	s6,16(sp)
    80001878:	e45e                	sd	s7,8(sp)
    8000187a:	0880                	addi	s0,sp,80
    8000187c:	8a2a                	mv	s4,a0
    8000187e:	8b2e                	mv	s6,a1
    80001880:	8bb2                	mv	s7,a2
    80001882:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001884:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001886:	6985                	lui	s3,0x1
    80001888:	a035                	j	800018b4 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000188a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000188e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001890:	0017b793          	seqz	a5,a5
    80001894:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001898:	60a6                	ld	ra,72(sp)
    8000189a:	6406                	ld	s0,64(sp)
    8000189c:	74e2                	ld	s1,56(sp)
    8000189e:	7942                	ld	s2,48(sp)
    800018a0:	79a2                	ld	s3,40(sp)
    800018a2:	7a02                	ld	s4,32(sp)
    800018a4:	6ae2                	ld	s5,24(sp)
    800018a6:	6b42                	ld	s6,16(sp)
    800018a8:	6ba2                	ld	s7,8(sp)
    800018aa:	6161                	addi	sp,sp,80
    800018ac:	8082                	ret
    srcva = va0 + PGSIZE;
    800018ae:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800018b2:	c8a9                	beqz	s1,80001904 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800018b4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018b8:	85ca                	mv	a1,s2
    800018ba:	8552                	mv	a0,s4
    800018bc:	00000097          	auipc	ra,0x0
    800018c0:	8ac080e7          	jalr	-1876(ra) # 80001168 <walkaddr>
    if(pa0 == 0)
    800018c4:	c131                	beqz	a0,80001908 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800018c6:	41790833          	sub	a6,s2,s7
    800018ca:	984e                	add	a6,a6,s3
    if(n > max)
    800018cc:	0104f363          	bgeu	s1,a6,800018d2 <copyinstr+0x6e>
    800018d0:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018d2:	955e                	add	a0,a0,s7
    800018d4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018d8:	fc080be3          	beqz	a6,800018ae <copyinstr+0x4a>
    800018dc:	985a                	add	a6,a6,s6
    800018de:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018e0:	41650633          	sub	a2,a0,s6
    800018e4:	14fd                	addi	s1,s1,-1
    800018e6:	9b26                	add	s6,s6,s1
    800018e8:	00f60733          	add	a4,a2,a5
    800018ec:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd5fa4>
    800018f0:	df49                	beqz	a4,8000188a <copyinstr+0x26>
        *dst = *p;
    800018f2:	00e78023          	sb	a4,0(a5)
      --max;
    800018f6:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018fa:	0785                	addi	a5,a5,1
    while(n > 0){
    800018fc:	ff0796e3          	bne	a5,a6,800018e8 <copyinstr+0x84>
      dst++;
    80001900:	8b42                	mv	s6,a6
    80001902:	b775                	j	800018ae <copyinstr+0x4a>
    80001904:	4781                	li	a5,0
    80001906:	b769                	j	80001890 <copyinstr+0x2c>
      return -1;
    80001908:	557d                	li	a0,-1
    8000190a:	b779                	j	80001898 <copyinstr+0x34>
  int got_null = 0;
    8000190c:	4781                	li	a5,0
  if(got_null){
    8000190e:	0017b793          	seqz	a5,a5
    80001912:	40f00533          	neg	a0,a5
}
    80001916:	8082                	ret

0000000080001918 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001918:	1101                	addi	sp,sp,-32
    8000191a:	ec06                	sd	ra,24(sp)
    8000191c:	e822                	sd	s0,16(sp)
    8000191e:	e426                	sd	s1,8(sp)
    80001920:	1000                	addi	s0,sp,32
    80001922:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001924:	fffff097          	auipc	ra,0xfffff
    80001928:	0fe080e7          	jalr	254(ra) # 80000a22 <holding>
    8000192c:	c909                	beqz	a0,8000193e <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    8000192e:	789c                	ld	a5,48(s1)
    80001930:	00978f63          	beq	a5,s1,8000194e <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001934:	60e2                	ld	ra,24(sp)
    80001936:	6442                	ld	s0,16(sp)
    80001938:	64a2                	ld	s1,8(sp)
    8000193a:	6105                	addi	sp,sp,32
    8000193c:	8082                	ret
    panic("wakeup1");
    8000193e:	00007517          	auipc	a0,0x7
    80001942:	ae250513          	addi	a0,a0,-1310 # 80008420 <userret+0x390>
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	c0e080e7          	jalr	-1010(ra) # 80000554 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    8000194e:	5098                	lw	a4,32(s1)
    80001950:	4785                	li	a5,1
    80001952:	fef711e3          	bne	a4,a5,80001934 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001956:	4789                	li	a5,2
    80001958:	d09c                	sw	a5,32(s1)
}
    8000195a:	bfe9                	j	80001934 <wakeup1+0x1c>

000000008000195c <procinit>:
{
    8000195c:	715d                	addi	sp,sp,-80
    8000195e:	e486                	sd	ra,72(sp)
    80001960:	e0a2                	sd	s0,64(sp)
    80001962:	fc26                	sd	s1,56(sp)
    80001964:	f84a                	sd	s2,48(sp)
    80001966:	f44e                	sd	s3,40(sp)
    80001968:	f052                	sd	s4,32(sp)
    8000196a:	ec56                	sd	s5,24(sp)
    8000196c:	e85a                	sd	s6,16(sp)
    8000196e:	e45e                	sd	s7,8(sp)
    80001970:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001972:	00007597          	auipc	a1,0x7
    80001976:	ab658593          	addi	a1,a1,-1354 # 80008428 <userret+0x398>
    8000197a:	00013517          	auipc	a0,0x13
    8000197e:	ec650513          	addi	a0,a0,-314 # 80014840 <pid_lock>
    80001982:	fffff097          	auipc	ra,0xfffff
    80001986:	04a080e7          	jalr	74(ra) # 800009cc <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000198a:	00013917          	auipc	s2,0x13
    8000198e:	2d690913          	addi	s2,s2,726 # 80014c60 <proc>
      initlock(&p->lock, "proc");
    80001992:	00007a17          	auipc	s4,0x7
    80001996:	a9ea0a13          	addi	s4,s4,-1378 # 80008430 <userret+0x3a0>
      uint64 va = KSTACK((int) (p - proc));
    8000199a:	8bca                	mv	s7,s2
    8000199c:	00007b17          	auipc	s6,0x7
    800019a0:	2ccb0b13          	addi	s6,s6,716 # 80008c68 <syscalls+0xc0>
    800019a4:	040009b7          	lui	s3,0x4000
    800019a8:	19fd                	addi	s3,s3,-1
    800019aa:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ac:	00014a97          	auipc	s5,0x14
    800019b0:	114a8a93          	addi	s5,s5,276 # 80015ac0 <tickslock>
      initlock(&p->lock, "proc");
    800019b4:	85d2                	mv	a1,s4
    800019b6:	854a                	mv	a0,s2
    800019b8:	fffff097          	auipc	ra,0xfffff
    800019bc:	014080e7          	jalr	20(ra) # 800009cc <initlock>
      char *pa = kalloc();
    800019c0:	fffff097          	auipc	ra,0xfffff
    800019c4:	fac080e7          	jalr	-84(ra) # 8000096c <kalloc>
    800019c8:	85aa                	mv	a1,a0
      if(pa == 0)
    800019ca:	c929                	beqz	a0,80001a1c <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800019cc:	417904b3          	sub	s1,s2,s7
    800019d0:	8491                	srai	s1,s1,0x4
    800019d2:	000b3783          	ld	a5,0(s6)
    800019d6:	02f484b3          	mul	s1,s1,a5
    800019da:	2485                	addiw	s1,s1,1
    800019dc:	00d4949b          	slliw	s1,s1,0xd
    800019e0:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019e4:	4699                	li	a3,6
    800019e6:	6605                	lui	a2,0x1
    800019e8:	8526                	mv	a0,s1
    800019ea:	00000097          	auipc	ra,0x0
    800019ee:	8ac080e7          	jalr	-1876(ra) # 80001296 <kvmmap>
      p->kstack = va;
    800019f2:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019f6:	17090913          	addi	s2,s2,368
    800019fa:	fb591de3          	bne	s2,s5,800019b4 <procinit+0x58>
  kvminithart();
    800019fe:	fffff097          	auipc	ra,0xfffff
    80001a02:	746080e7          	jalr	1862(ra) # 80001144 <kvminithart>
}
    80001a06:	60a6                	ld	ra,72(sp)
    80001a08:	6406                	ld	s0,64(sp)
    80001a0a:	74e2                	ld	s1,56(sp)
    80001a0c:	7942                	ld	s2,48(sp)
    80001a0e:	79a2                	ld	s3,40(sp)
    80001a10:	7a02                	ld	s4,32(sp)
    80001a12:	6ae2                	ld	s5,24(sp)
    80001a14:	6b42                	ld	s6,16(sp)
    80001a16:	6ba2                	ld	s7,8(sp)
    80001a18:	6161                	addi	sp,sp,80
    80001a1a:	8082                	ret
        panic("kalloc");
    80001a1c:	00007517          	auipc	a0,0x7
    80001a20:	a1c50513          	addi	a0,a0,-1508 # 80008438 <userret+0x3a8>
    80001a24:	fffff097          	auipc	ra,0xfffff
    80001a28:	b30080e7          	jalr	-1232(ra) # 80000554 <panic>

0000000080001a2c <cpuid>:
{
    80001a2c:	1141                	addi	sp,sp,-16
    80001a2e:	e422                	sd	s0,8(sp)
    80001a30:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a32:	8512                	mv	a0,tp
}
    80001a34:	2501                	sext.w	a0,a0
    80001a36:	6422                	ld	s0,8(sp)
    80001a38:	0141                	addi	sp,sp,16
    80001a3a:	8082                	ret

0000000080001a3c <mycpu>:
mycpu(void) {
    80001a3c:	1141                	addi	sp,sp,-16
    80001a3e:	e422                	sd	s0,8(sp)
    80001a40:	0800                	addi	s0,sp,16
    80001a42:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a44:	2781                	sext.w	a5,a5
    80001a46:	079e                	slli	a5,a5,0x7
}
    80001a48:	00013517          	auipc	a0,0x13
    80001a4c:	e1850513          	addi	a0,a0,-488 # 80014860 <cpus>
    80001a50:	953e                	add	a0,a0,a5
    80001a52:	6422                	ld	s0,8(sp)
    80001a54:	0141                	addi	sp,sp,16
    80001a56:	8082                	ret

0000000080001a58 <myproc>:
myproc(void) {
    80001a58:	1101                	addi	sp,sp,-32
    80001a5a:	ec06                	sd	ra,24(sp)
    80001a5c:	e822                	sd	s0,16(sp)
    80001a5e:	e426                	sd	s1,8(sp)
    80001a60:	1000                	addi	s0,sp,32
  push_off();
    80001a62:	fffff097          	auipc	ra,0xfffff
    80001a66:	fee080e7          	jalr	-18(ra) # 80000a50 <push_off>
    80001a6a:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a6c:	2781                	sext.w	a5,a5
    80001a6e:	079e                	slli	a5,a5,0x7
    80001a70:	00013717          	auipc	a4,0x13
    80001a74:	dd070713          	addi	a4,a4,-560 # 80014840 <pid_lock>
    80001a78:	97ba                	add	a5,a5,a4
    80001a7a:	7384                	ld	s1,32(a5)
  pop_off();
    80001a7c:	fffff097          	auipc	ra,0xfffff
    80001a80:	094080e7          	jalr	148(ra) # 80000b10 <pop_off>
}
    80001a84:	8526                	mv	a0,s1
    80001a86:	60e2                	ld	ra,24(sp)
    80001a88:	6442                	ld	s0,16(sp)
    80001a8a:	64a2                	ld	s1,8(sp)
    80001a8c:	6105                	addi	sp,sp,32
    80001a8e:	8082                	ret

0000000080001a90 <forkret>:
{
    80001a90:	1141                	addi	sp,sp,-16
    80001a92:	e406                	sd	ra,8(sp)
    80001a94:	e022                	sd	s0,0(sp)
    80001a96:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a98:	00000097          	auipc	ra,0x0
    80001a9c:	fc0080e7          	jalr	-64(ra) # 80001a58 <myproc>
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	0d0080e7          	jalr	208(ra) # 80000b70 <release>
  if (first) {
    80001aa8:	00007797          	auipc	a5,0x7
    80001aac:	58c7a783          	lw	a5,1420(a5) # 80009034 <first.1>
    80001ab0:	eb89                	bnez	a5,80001ac2 <forkret+0x32>
  usertrapret();
    80001ab2:	00001097          	auipc	ra,0x1
    80001ab6:	bc4080e7          	jalr	-1084(ra) # 80002676 <usertrapret>
}
    80001aba:	60a2                	ld	ra,8(sp)
    80001abc:	6402                	ld	s0,0(sp)
    80001abe:	0141                	addi	sp,sp,16
    80001ac0:	8082                	ret
    first = 0;
    80001ac2:	00007797          	auipc	a5,0x7
    80001ac6:	5607a923          	sw	zero,1394(a5) # 80009034 <first.1>
    fsinit(minor(ROOTDEV));
    80001aca:	4501                	li	a0,0
    80001acc:	00002097          	auipc	ra,0x2
    80001ad0:	9a6080e7          	jalr	-1626(ra) # 80003472 <fsinit>
    80001ad4:	bff9                	j	80001ab2 <forkret+0x22>

0000000080001ad6 <allocpid>:
allocpid() {
    80001ad6:	1101                	addi	sp,sp,-32
    80001ad8:	ec06                	sd	ra,24(sp)
    80001ada:	e822                	sd	s0,16(sp)
    80001adc:	e426                	sd	s1,8(sp)
    80001ade:	e04a                	sd	s2,0(sp)
    80001ae0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ae2:	00013917          	auipc	s2,0x13
    80001ae6:	d5e90913          	addi	s2,s2,-674 # 80014840 <pid_lock>
    80001aea:	854a                	mv	a0,s2
    80001aec:	fffff097          	auipc	ra,0xfffff
    80001af0:	fb4080e7          	jalr	-76(ra) # 80000aa0 <acquire>
  pid = nextpid;
    80001af4:	00007797          	auipc	a5,0x7
    80001af8:	54478793          	addi	a5,a5,1348 # 80009038 <nextpid>
    80001afc:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001afe:	0014871b          	addiw	a4,s1,1
    80001b02:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b04:	854a                	mv	a0,s2
    80001b06:	fffff097          	auipc	ra,0xfffff
    80001b0a:	06a080e7          	jalr	106(ra) # 80000b70 <release>
}
    80001b0e:	8526                	mv	a0,s1
    80001b10:	60e2                	ld	ra,24(sp)
    80001b12:	6442                	ld	s0,16(sp)
    80001b14:	64a2                	ld	s1,8(sp)
    80001b16:	6902                	ld	s2,0(sp)
    80001b18:	6105                	addi	sp,sp,32
    80001b1a:	8082                	ret

0000000080001b1c <proc_pagetable>:
{
    80001b1c:	1101                	addi	sp,sp,-32
    80001b1e:	ec06                	sd	ra,24(sp)
    80001b20:	e822                	sd	s0,16(sp)
    80001b22:	e426                	sd	s1,8(sp)
    80001b24:	e04a                	sd	s2,0(sp)
    80001b26:	1000                	addi	s0,sp,32
    80001b28:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b2a:	00000097          	auipc	ra,0x0
    80001b2e:	952080e7          	jalr	-1710(ra) # 8000147c <uvmcreate>
    80001b32:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b34:	4729                	li	a4,10
    80001b36:	00006697          	auipc	a3,0x6
    80001b3a:	4ca68693          	addi	a3,a3,1226 # 80008000 <trampoline>
    80001b3e:	6605                	lui	a2,0x1
    80001b40:	040005b7          	lui	a1,0x4000
    80001b44:	15fd                	addi	a1,a1,-1
    80001b46:	05b2                	slli	a1,a1,0xc
    80001b48:	fffff097          	auipc	ra,0xfffff
    80001b4c:	6c0080e7          	jalr	1728(ra) # 80001208 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b50:	4719                	li	a4,6
    80001b52:	06093683          	ld	a3,96(s2)
    80001b56:	6605                	lui	a2,0x1
    80001b58:	020005b7          	lui	a1,0x2000
    80001b5c:	15fd                	addi	a1,a1,-1
    80001b5e:	05b6                	slli	a1,a1,0xd
    80001b60:	8526                	mv	a0,s1
    80001b62:	fffff097          	auipc	ra,0xfffff
    80001b66:	6a6080e7          	jalr	1702(ra) # 80001208 <mappages>
}
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	60e2                	ld	ra,24(sp)
    80001b6e:	6442                	ld	s0,16(sp)
    80001b70:	64a2                	ld	s1,8(sp)
    80001b72:	6902                	ld	s2,0(sp)
    80001b74:	6105                	addi	sp,sp,32
    80001b76:	8082                	ret

0000000080001b78 <allocproc>:
{
    80001b78:	1101                	addi	sp,sp,-32
    80001b7a:	ec06                	sd	ra,24(sp)
    80001b7c:	e822                	sd	s0,16(sp)
    80001b7e:	e426                	sd	s1,8(sp)
    80001b80:	e04a                	sd	s2,0(sp)
    80001b82:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b84:	00013497          	auipc	s1,0x13
    80001b88:	0dc48493          	addi	s1,s1,220 # 80014c60 <proc>
    80001b8c:	00014917          	auipc	s2,0x14
    80001b90:	f3490913          	addi	s2,s2,-204 # 80015ac0 <tickslock>
    acquire(&p->lock);
    80001b94:	8526                	mv	a0,s1
    80001b96:	fffff097          	auipc	ra,0xfffff
    80001b9a:	f0a080e7          	jalr	-246(ra) # 80000aa0 <acquire>
    if(p->state == UNUSED) {
    80001b9e:	509c                	lw	a5,32(s1)
    80001ba0:	c395                	beqz	a5,80001bc4 <allocproc+0x4c>
      release(&p->lock);
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	fcc080e7          	jalr	-52(ra) # 80000b70 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bac:	17048493          	addi	s1,s1,368
    80001bb0:	ff2492e3          	bne	s1,s2,80001b94 <allocproc+0x1c>
  return 0;
    80001bb4:	4481                	li	s1,0
}
    80001bb6:	8526                	mv	a0,s1
    80001bb8:	60e2                	ld	ra,24(sp)
    80001bba:	6442                	ld	s0,16(sp)
    80001bbc:	64a2                	ld	s1,8(sp)
    80001bbe:	6902                	ld	s2,0(sp)
    80001bc0:	6105                	addi	sp,sp,32
    80001bc2:	8082                	ret
  p->pid = allocpid();
    80001bc4:	00000097          	auipc	ra,0x0
    80001bc8:	f12080e7          	jalr	-238(ra) # 80001ad6 <allocpid>
    80001bcc:	c0a8                	sw	a0,64(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	d9e080e7          	jalr	-610(ra) # 8000096c <kalloc>
    80001bd6:	892a                	mv	s2,a0
    80001bd8:	f0a8                	sd	a0,96(s1)
    80001bda:	c915                	beqz	a0,80001c0e <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	00000097          	auipc	ra,0x0
    80001be2:	f3e080e7          	jalr	-194(ra) # 80001b1c <proc_pagetable>
    80001be6:	eca8                	sd	a0,88(s1)
  memset(&p->context, 0, sizeof p->context);
    80001be8:	07000613          	li	a2,112
    80001bec:	4581                	li	a1,0
    80001bee:	06848513          	addi	a0,s1,104
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	17c080e7          	jalr	380(ra) # 80000d6e <memset>
  p->context.ra = (uint64)forkret;
    80001bfa:	00000797          	auipc	a5,0x0
    80001bfe:	e9678793          	addi	a5,a5,-362 # 80001a90 <forkret>
    80001c02:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c04:	64bc                	ld	a5,72(s1)
    80001c06:	6705                	lui	a4,0x1
    80001c08:	97ba                	add	a5,a5,a4
    80001c0a:	f8bc                	sd	a5,112(s1)
  return p;
    80001c0c:	b76d                	j	80001bb6 <allocproc+0x3e>
    release(&p->lock);
    80001c0e:	8526                	mv	a0,s1
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	f60080e7          	jalr	-160(ra) # 80000b70 <release>
    return 0;
    80001c18:	84ca                	mv	s1,s2
    80001c1a:	bf71                	j	80001bb6 <allocproc+0x3e>

0000000080001c1c <proc_freepagetable>:
{
    80001c1c:	1101                	addi	sp,sp,-32
    80001c1e:	ec06                	sd	ra,24(sp)
    80001c20:	e822                	sd	s0,16(sp)
    80001c22:	e426                	sd	s1,8(sp)
    80001c24:	e04a                	sd	s2,0(sp)
    80001c26:	1000                	addi	s0,sp,32
    80001c28:	84aa                	mv	s1,a0
    80001c2a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001c2c:	4681                	li	a3,0
    80001c2e:	6605                	lui	a2,0x1
    80001c30:	040005b7          	lui	a1,0x4000
    80001c34:	15fd                	addi	a1,a1,-1
    80001c36:	05b2                	slli	a1,a1,0xc
    80001c38:	fffff097          	auipc	ra,0xfffff
    80001c3c:	77c080e7          	jalr	1916(ra) # 800013b4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001c40:	4681                	li	a3,0
    80001c42:	6605                	lui	a2,0x1
    80001c44:	020005b7          	lui	a1,0x2000
    80001c48:	15fd                	addi	a1,a1,-1
    80001c4a:	05b6                	slli	a1,a1,0xd
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	766080e7          	jalr	1894(ra) # 800013b4 <uvmunmap>
  if(sz > 0)
    80001c56:	00091863          	bnez	s2,80001c66 <proc_freepagetable+0x4a>
}
    80001c5a:	60e2                	ld	ra,24(sp)
    80001c5c:	6442                	ld	s0,16(sp)
    80001c5e:	64a2                	ld	s1,8(sp)
    80001c60:	6902                	ld	s2,0(sp)
    80001c62:	6105                	addi	sp,sp,32
    80001c64:	8082                	ret
    uvmfree(pagetable, sz);
    80001c66:	85ca                	mv	a1,s2
    80001c68:	8526                	mv	a0,s1
    80001c6a:	00000097          	auipc	ra,0x0
    80001c6e:	9b0080e7          	jalr	-1616(ra) # 8000161a <uvmfree>
}
    80001c72:	b7e5                	j	80001c5a <proc_freepagetable+0x3e>

0000000080001c74 <freeproc>:
{
    80001c74:	1101                	addi	sp,sp,-32
    80001c76:	ec06                	sd	ra,24(sp)
    80001c78:	e822                	sd	s0,16(sp)
    80001c7a:	e426                	sd	s1,8(sp)
    80001c7c:	1000                	addi	s0,sp,32
    80001c7e:	84aa                	mv	s1,a0
  if(p->tf)
    80001c80:	7128                	ld	a0,96(a0)
    80001c82:	c509                	beqz	a0,80001c8c <freeproc+0x18>
    kfree((void*)p->tf);
    80001c84:	fffff097          	auipc	ra,0xfffff
    80001c88:	bec080e7          	jalr	-1044(ra) # 80000870 <kfree>
  p->tf = 0;
    80001c8c:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001c90:	6ca8                	ld	a0,88(s1)
    80001c92:	c511                	beqz	a0,80001c9e <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c94:	68ac                	ld	a1,80(s1)
    80001c96:	00000097          	auipc	ra,0x0
    80001c9a:	f86080e7          	jalr	-122(ra) # 80001c1c <proc_freepagetable>
  p->pagetable = 0;
    80001c9e:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001ca2:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001ca6:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001caa:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001cae:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001cb2:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001cb6:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001cba:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001cbe:	0204a023          	sw	zero,32(s1)
}
    80001cc2:	60e2                	ld	ra,24(sp)
    80001cc4:	6442                	ld	s0,16(sp)
    80001cc6:	64a2                	ld	s1,8(sp)
    80001cc8:	6105                	addi	sp,sp,32
    80001cca:	8082                	ret

0000000080001ccc <userinit>:
{
    80001ccc:	1101                	addi	sp,sp,-32
    80001cce:	ec06                	sd	ra,24(sp)
    80001cd0:	e822                	sd	s0,16(sp)
    80001cd2:	e426                	sd	s1,8(sp)
    80001cd4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cd6:	00000097          	auipc	ra,0x0
    80001cda:	ea2080e7          	jalr	-350(ra) # 80001b78 <allocproc>
    80001cde:	84aa                	mv	s1,a0
  initproc = p;
    80001ce0:	00027797          	auipc	a5,0x27
    80001ce4:	34a7bc23          	sd	a0,856(a5) # 80029038 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001ce8:	03300613          	li	a2,51
    80001cec:	00007597          	auipc	a1,0x7
    80001cf0:	31458593          	addi	a1,a1,788 # 80009000 <initcode>
    80001cf4:	6d28                	ld	a0,88(a0)
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	7c4080e7          	jalr	1988(ra) # 800014ba <uvminit>
  p->sz = PGSIZE;
    80001cfe:	6785                	lui	a5,0x1
    80001d00:	e8bc                	sd	a5,80(s1)
  p->tf->epc = 0;      // user program counter
    80001d02:	70b8                	ld	a4,96(s1)
    80001d04:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001d08:	70b8                	ld	a4,96(s1)
    80001d0a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d0c:	4641                	li	a2,16
    80001d0e:	00006597          	auipc	a1,0x6
    80001d12:	73258593          	addi	a1,a1,1842 # 80008440 <userret+0x3b0>
    80001d16:	16048513          	addi	a0,s1,352
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	1a6080e7          	jalr	422(ra) # 80000ec0 <safestrcpy>
  p->cwd = namei("/");
    80001d22:	00006517          	auipc	a0,0x6
    80001d26:	72e50513          	addi	a0,a0,1838 # 80008450 <userret+0x3c0>
    80001d2a:	00002097          	auipc	ra,0x2
    80001d2e:	22e080e7          	jalr	558(ra) # 80003f58 <namei>
    80001d32:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d36:	4789                	li	a5,2
    80001d38:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	e34080e7          	jalr	-460(ra) # 80000b70 <release>
}
    80001d44:	60e2                	ld	ra,24(sp)
    80001d46:	6442                	ld	s0,16(sp)
    80001d48:	64a2                	ld	s1,8(sp)
    80001d4a:	6105                	addi	sp,sp,32
    80001d4c:	8082                	ret

0000000080001d4e <growproc>:
{
    80001d4e:	1101                	addi	sp,sp,-32
    80001d50:	ec06                	sd	ra,24(sp)
    80001d52:	e822                	sd	s0,16(sp)
    80001d54:	e426                	sd	s1,8(sp)
    80001d56:	e04a                	sd	s2,0(sp)
    80001d58:	1000                	addi	s0,sp,32
    80001d5a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d5c:	00000097          	auipc	ra,0x0
    80001d60:	cfc080e7          	jalr	-772(ra) # 80001a58 <myproc>
    80001d64:	892a                	mv	s2,a0
  sz = p->sz;
    80001d66:	692c                	ld	a1,80(a0)
    80001d68:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d6c:	00904f63          	bgtz	s1,80001d8a <growproc+0x3c>
  } else if(n < 0){
    80001d70:	0204cc63          	bltz	s1,80001da8 <growproc+0x5a>
  p->sz = sz;
    80001d74:	1602                	slli	a2,a2,0x20
    80001d76:	9201                	srli	a2,a2,0x20
    80001d78:	04c93823          	sd	a2,80(s2)
  return 0;
    80001d7c:	4501                	li	a0,0
}
    80001d7e:	60e2                	ld	ra,24(sp)
    80001d80:	6442                	ld	s0,16(sp)
    80001d82:	64a2                	ld	s1,8(sp)
    80001d84:	6902                	ld	s2,0(sp)
    80001d86:	6105                	addi	sp,sp,32
    80001d88:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d8a:	9e25                	addw	a2,a2,s1
    80001d8c:	1602                	slli	a2,a2,0x20
    80001d8e:	9201                	srli	a2,a2,0x20
    80001d90:	1582                	slli	a1,a1,0x20
    80001d92:	9181                	srli	a1,a1,0x20
    80001d94:	6d28                	ld	a0,88(a0)
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	7da080e7          	jalr	2010(ra) # 80001570 <uvmalloc>
    80001d9e:	0005061b          	sext.w	a2,a0
    80001da2:	fa69                	bnez	a2,80001d74 <growproc+0x26>
      return -1;
    80001da4:	557d                	li	a0,-1
    80001da6:	bfe1                	j	80001d7e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001da8:	9e25                	addw	a2,a2,s1
    80001daa:	1602                	slli	a2,a2,0x20
    80001dac:	9201                	srli	a2,a2,0x20
    80001dae:	1582                	slli	a1,a1,0x20
    80001db0:	9181                	srli	a1,a1,0x20
    80001db2:	6d28                	ld	a0,88(a0)
    80001db4:	fffff097          	auipc	ra,0xfffff
    80001db8:	778080e7          	jalr	1912(ra) # 8000152c <uvmdealloc>
    80001dbc:	0005061b          	sext.w	a2,a0
    80001dc0:	bf55                	j	80001d74 <growproc+0x26>

0000000080001dc2 <fork>:
{
    80001dc2:	7139                	addi	sp,sp,-64
    80001dc4:	fc06                	sd	ra,56(sp)
    80001dc6:	f822                	sd	s0,48(sp)
    80001dc8:	f426                	sd	s1,40(sp)
    80001dca:	f04a                	sd	s2,32(sp)
    80001dcc:	ec4e                	sd	s3,24(sp)
    80001dce:	e852                	sd	s4,16(sp)
    80001dd0:	e456                	sd	s5,8(sp)
    80001dd2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dd4:	00000097          	auipc	ra,0x0
    80001dd8:	c84080e7          	jalr	-892(ra) # 80001a58 <myproc>
    80001ddc:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001dde:	00000097          	auipc	ra,0x0
    80001de2:	d9a080e7          	jalr	-614(ra) # 80001b78 <allocproc>
    80001de6:	c17d                	beqz	a0,80001ecc <fork+0x10a>
    80001de8:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dea:	050ab603          	ld	a2,80(s5)
    80001dee:	6d2c                	ld	a1,88(a0)
    80001df0:	058ab503          	ld	a0,88(s5)
    80001df4:	00000097          	auipc	ra,0x0
    80001df8:	854080e7          	jalr	-1964(ra) # 80001648 <uvmcopy>
    80001dfc:	04054a63          	bltz	a0,80001e50 <fork+0x8e>
  np->sz = p->sz;
    80001e00:	050ab783          	ld	a5,80(s5)
    80001e04:	04fa3823          	sd	a5,80(s4)
  np->parent = p;
    80001e08:	035a3423          	sd	s5,40(s4)
  *(np->tf) = *(p->tf);
    80001e0c:	060ab683          	ld	a3,96(s5)
    80001e10:	87b6                	mv	a5,a3
    80001e12:	060a3703          	ld	a4,96(s4)
    80001e16:	12068693          	addi	a3,a3,288
    80001e1a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e1e:	6788                	ld	a0,8(a5)
    80001e20:	6b8c                	ld	a1,16(a5)
    80001e22:	6f90                	ld	a2,24(a5)
    80001e24:	01073023          	sd	a6,0(a4)
    80001e28:	e708                	sd	a0,8(a4)
    80001e2a:	eb0c                	sd	a1,16(a4)
    80001e2c:	ef10                	sd	a2,24(a4)
    80001e2e:	02078793          	addi	a5,a5,32
    80001e32:	02070713          	addi	a4,a4,32
    80001e36:	fed792e3          	bne	a5,a3,80001e1a <fork+0x58>
  np->tf->a0 = 0;
    80001e3a:	060a3783          	ld	a5,96(s4)
    80001e3e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e42:	0d8a8493          	addi	s1,s5,216
    80001e46:	0d8a0913          	addi	s2,s4,216
    80001e4a:	158a8993          	addi	s3,s5,344
    80001e4e:	a00d                	j	80001e70 <fork+0xae>
    freeproc(np);
    80001e50:	8552                	mv	a0,s4
    80001e52:	00000097          	auipc	ra,0x0
    80001e56:	e22080e7          	jalr	-478(ra) # 80001c74 <freeproc>
    release(&np->lock);
    80001e5a:	8552                	mv	a0,s4
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	d14080e7          	jalr	-748(ra) # 80000b70 <release>
    return -1;
    80001e64:	54fd                	li	s1,-1
    80001e66:	a889                	j	80001eb8 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001e68:	04a1                	addi	s1,s1,8
    80001e6a:	0921                	addi	s2,s2,8
    80001e6c:	01348b63          	beq	s1,s3,80001e82 <fork+0xc0>
    if(p->ofile[i])
    80001e70:	6088                	ld	a0,0(s1)
    80001e72:	d97d                	beqz	a0,80001e68 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e74:	00003097          	auipc	ra,0x3
    80001e78:	886080e7          	jalr	-1914(ra) # 800046fa <filedup>
    80001e7c:	00a93023          	sd	a0,0(s2)
    80001e80:	b7e5                	j	80001e68 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001e82:	158ab503          	ld	a0,344(s5)
    80001e86:	00002097          	auipc	ra,0x2
    80001e8a:	828080e7          	jalr	-2008(ra) # 800036ae <idup>
    80001e8e:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e92:	4641                	li	a2,16
    80001e94:	160a8593          	addi	a1,s5,352
    80001e98:	160a0513          	addi	a0,s4,352
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	024080e7          	jalr	36(ra) # 80000ec0 <safestrcpy>
  pid = np->pid;
    80001ea4:	040a2483          	lw	s1,64(s4)
  np->state = RUNNABLE;
    80001ea8:	4789                	li	a5,2
    80001eaa:	02fa2023          	sw	a5,32(s4)
  release(&np->lock);
    80001eae:	8552                	mv	a0,s4
    80001eb0:	fffff097          	auipc	ra,0xfffff
    80001eb4:	cc0080e7          	jalr	-832(ra) # 80000b70 <release>
}
    80001eb8:	8526                	mv	a0,s1
    80001eba:	70e2                	ld	ra,56(sp)
    80001ebc:	7442                	ld	s0,48(sp)
    80001ebe:	74a2                	ld	s1,40(sp)
    80001ec0:	7902                	ld	s2,32(sp)
    80001ec2:	69e2                	ld	s3,24(sp)
    80001ec4:	6a42                	ld	s4,16(sp)
    80001ec6:	6aa2                	ld	s5,8(sp)
    80001ec8:	6121                	addi	sp,sp,64
    80001eca:	8082                	ret
    return -1;
    80001ecc:	54fd                	li	s1,-1
    80001ece:	b7ed                	j	80001eb8 <fork+0xf6>

0000000080001ed0 <reparent>:
{
    80001ed0:	7179                	addi	sp,sp,-48
    80001ed2:	f406                	sd	ra,40(sp)
    80001ed4:	f022                	sd	s0,32(sp)
    80001ed6:	ec26                	sd	s1,24(sp)
    80001ed8:	e84a                	sd	s2,16(sp)
    80001eda:	e44e                	sd	s3,8(sp)
    80001edc:	e052                	sd	s4,0(sp)
    80001ede:	1800                	addi	s0,sp,48
    80001ee0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ee2:	00013497          	auipc	s1,0x13
    80001ee6:	d7e48493          	addi	s1,s1,-642 # 80014c60 <proc>
      pp->parent = initproc;
    80001eea:	00027a17          	auipc	s4,0x27
    80001eee:	14ea0a13          	addi	s4,s4,334 # 80029038 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ef2:	00014997          	auipc	s3,0x14
    80001ef6:	bce98993          	addi	s3,s3,-1074 # 80015ac0 <tickslock>
    80001efa:	a029                	j	80001f04 <reparent+0x34>
    80001efc:	17048493          	addi	s1,s1,368
    80001f00:	03348363          	beq	s1,s3,80001f26 <reparent+0x56>
    if(pp->parent == p){
    80001f04:	749c                	ld	a5,40(s1)
    80001f06:	ff279be3          	bne	a5,s2,80001efc <reparent+0x2c>
      acquire(&pp->lock);
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	fffff097          	auipc	ra,0xfffff
    80001f10:	b94080e7          	jalr	-1132(ra) # 80000aa0 <acquire>
      pp->parent = initproc;
    80001f14:	000a3783          	ld	a5,0(s4)
    80001f18:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	fffff097          	auipc	ra,0xfffff
    80001f20:	c54080e7          	jalr	-940(ra) # 80000b70 <release>
    80001f24:	bfe1                	j	80001efc <reparent+0x2c>
}
    80001f26:	70a2                	ld	ra,40(sp)
    80001f28:	7402                	ld	s0,32(sp)
    80001f2a:	64e2                	ld	s1,24(sp)
    80001f2c:	6942                	ld	s2,16(sp)
    80001f2e:	69a2                	ld	s3,8(sp)
    80001f30:	6a02                	ld	s4,0(sp)
    80001f32:	6145                	addi	sp,sp,48
    80001f34:	8082                	ret

0000000080001f36 <scheduler>:
{
    80001f36:	715d                	addi	sp,sp,-80
    80001f38:	e486                	sd	ra,72(sp)
    80001f3a:	e0a2                	sd	s0,64(sp)
    80001f3c:	fc26                	sd	s1,56(sp)
    80001f3e:	f84a                	sd	s2,48(sp)
    80001f40:	f44e                	sd	s3,40(sp)
    80001f42:	f052                	sd	s4,32(sp)
    80001f44:	ec56                	sd	s5,24(sp)
    80001f46:	e85a                	sd	s6,16(sp)
    80001f48:	e45e                	sd	s7,8(sp)
    80001f4a:	e062                	sd	s8,0(sp)
    80001f4c:	0880                	addi	s0,sp,80
    80001f4e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f50:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f52:	00779b13          	slli	s6,a5,0x7
    80001f56:	00013717          	auipc	a4,0x13
    80001f5a:	8ea70713          	addi	a4,a4,-1814 # 80014840 <pid_lock>
    80001f5e:	975a                	add	a4,a4,s6
    80001f60:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    80001f64:	00013717          	auipc	a4,0x13
    80001f68:	90470713          	addi	a4,a4,-1788 # 80014868 <cpus+0x8>
    80001f6c:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f6e:	4b8d                	li	s7,3
        c->proc = p;
    80001f70:	079e                	slli	a5,a5,0x7
    80001f72:	00013917          	auipc	s2,0x13
    80001f76:	8ce90913          	addi	s2,s2,-1842 # 80014840 <pid_lock>
    80001f7a:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f7c:	00014a17          	auipc	s4,0x14
    80001f80:	b44a0a13          	addi	s4,s4,-1212 # 80015ac0 <tickslock>
    80001f84:	a0b9                	j	80001fd2 <scheduler+0x9c>
      c->intena = 0;
    80001f86:	08092e23          	sw	zero,156(s2)
      release(&p->lock);
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	fffff097          	auipc	ra,0xfffff
    80001f90:	be4080e7          	jalr	-1052(ra) # 80000b70 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f94:	17048493          	addi	s1,s1,368
    80001f98:	03448963          	beq	s1,s4,80001fca <scheduler+0x94>
      acquire(&p->lock);
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	b02080e7          	jalr	-1278(ra) # 80000aa0 <acquire>
      if(p->state == RUNNABLE) {
    80001fa6:	509c                	lw	a5,32(s1)
    80001fa8:	fd379fe3          	bne	a5,s3,80001f86 <scheduler+0x50>
        p->state = RUNNING;
    80001fac:	0374a023          	sw	s7,32(s1)
        c->proc = p;
    80001fb0:	02993023          	sd	s1,32(s2)
        swtch(&c->scheduler, &p->context);
    80001fb4:	06848593          	addi	a1,s1,104
    80001fb8:	855a                	mv	a0,s6
    80001fba:	00000097          	auipc	ra,0x0
    80001fbe:	612080e7          	jalr	1554(ra) # 800025cc <swtch>
        c->proc = 0;
    80001fc2:	02093023          	sd	zero,32(s2)
        found = 1;
    80001fc6:	8ae2                	mv	s5,s8
    80001fc8:	bf7d                	j	80001f86 <scheduler+0x50>
    if(found == 0){
    80001fca:	000a9463          	bnez	s5,80001fd2 <scheduler+0x9c>
      asm volatile("wfi");
    80001fce:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fd2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fd6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fda:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fde:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001fe2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fe4:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001fe8:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fea:	00013497          	auipc	s1,0x13
    80001fee:	c7648493          	addi	s1,s1,-906 # 80014c60 <proc>
      if(p->state == RUNNABLE) {
    80001ff2:	4989                	li	s3,2
        found = 1;
    80001ff4:	4c05                	li	s8,1
    80001ff6:	b75d                	j	80001f9c <scheduler+0x66>

0000000080001ff8 <sched>:
{
    80001ff8:	7179                	addi	sp,sp,-48
    80001ffa:	f406                	sd	ra,40(sp)
    80001ffc:	f022                	sd	s0,32(sp)
    80001ffe:	ec26                	sd	s1,24(sp)
    80002000:	e84a                	sd	s2,16(sp)
    80002002:	e44e                	sd	s3,8(sp)
    80002004:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002006:	00000097          	auipc	ra,0x0
    8000200a:	a52080e7          	jalr	-1454(ra) # 80001a58 <myproc>
    8000200e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002010:	fffff097          	auipc	ra,0xfffff
    80002014:	a12080e7          	jalr	-1518(ra) # 80000a22 <holding>
    80002018:	c93d                	beqz	a0,8000208e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000201a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000201c:	2781                	sext.w	a5,a5
    8000201e:	079e                	slli	a5,a5,0x7
    80002020:	00013717          	auipc	a4,0x13
    80002024:	82070713          	addi	a4,a4,-2016 # 80014840 <pid_lock>
    80002028:	97ba                	add	a5,a5,a4
    8000202a:	0987a703          	lw	a4,152(a5)
    8000202e:	4785                	li	a5,1
    80002030:	06f71763          	bne	a4,a5,8000209e <sched+0xa6>
  if(p->state == RUNNING)
    80002034:	5098                	lw	a4,32(s1)
    80002036:	478d                	li	a5,3
    80002038:	06f70b63          	beq	a4,a5,800020ae <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000203c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002040:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002042:	efb5                	bnez	a5,800020be <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002044:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002046:	00012917          	auipc	s2,0x12
    8000204a:	7fa90913          	addi	s2,s2,2042 # 80014840 <pid_lock>
    8000204e:	2781                	sext.w	a5,a5
    80002050:	079e                	slli	a5,a5,0x7
    80002052:	97ca                	add	a5,a5,s2
    80002054:	09c7a983          	lw	s3,156(a5)
    80002058:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    8000205a:	2781                	sext.w	a5,a5
    8000205c:	079e                	slli	a5,a5,0x7
    8000205e:	00013597          	auipc	a1,0x13
    80002062:	80a58593          	addi	a1,a1,-2038 # 80014868 <cpus+0x8>
    80002066:	95be                	add	a1,a1,a5
    80002068:	06848513          	addi	a0,s1,104
    8000206c:	00000097          	auipc	ra,0x0
    80002070:	560080e7          	jalr	1376(ra) # 800025cc <swtch>
    80002074:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002076:	2781                	sext.w	a5,a5
    80002078:	079e                	slli	a5,a5,0x7
    8000207a:	97ca                	add	a5,a5,s2
    8000207c:	0937ae23          	sw	s3,156(a5)
}
    80002080:	70a2                	ld	ra,40(sp)
    80002082:	7402                	ld	s0,32(sp)
    80002084:	64e2                	ld	s1,24(sp)
    80002086:	6942                	ld	s2,16(sp)
    80002088:	69a2                	ld	s3,8(sp)
    8000208a:	6145                	addi	sp,sp,48
    8000208c:	8082                	ret
    panic("sched p->lock");
    8000208e:	00006517          	auipc	a0,0x6
    80002092:	3ca50513          	addi	a0,a0,970 # 80008458 <userret+0x3c8>
    80002096:	ffffe097          	auipc	ra,0xffffe
    8000209a:	4be080e7          	jalr	1214(ra) # 80000554 <panic>
    panic("sched locks");
    8000209e:	00006517          	auipc	a0,0x6
    800020a2:	3ca50513          	addi	a0,a0,970 # 80008468 <userret+0x3d8>
    800020a6:	ffffe097          	auipc	ra,0xffffe
    800020aa:	4ae080e7          	jalr	1198(ra) # 80000554 <panic>
    panic("sched running");
    800020ae:	00006517          	auipc	a0,0x6
    800020b2:	3ca50513          	addi	a0,a0,970 # 80008478 <userret+0x3e8>
    800020b6:	ffffe097          	auipc	ra,0xffffe
    800020ba:	49e080e7          	jalr	1182(ra) # 80000554 <panic>
    panic("sched interruptible");
    800020be:	00006517          	auipc	a0,0x6
    800020c2:	3ca50513          	addi	a0,a0,970 # 80008488 <userret+0x3f8>
    800020c6:	ffffe097          	auipc	ra,0xffffe
    800020ca:	48e080e7          	jalr	1166(ra) # 80000554 <panic>

00000000800020ce <exit>:
{
    800020ce:	7179                	addi	sp,sp,-48
    800020d0:	f406                	sd	ra,40(sp)
    800020d2:	f022                	sd	s0,32(sp)
    800020d4:	ec26                	sd	s1,24(sp)
    800020d6:	e84a                	sd	s2,16(sp)
    800020d8:	e44e                	sd	s3,8(sp)
    800020da:	e052                	sd	s4,0(sp)
    800020dc:	1800                	addi	s0,sp,48
    800020de:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020e0:	00000097          	auipc	ra,0x0
    800020e4:	978080e7          	jalr	-1672(ra) # 80001a58 <myproc>
    800020e8:	89aa                	mv	s3,a0
  if(p == initproc)
    800020ea:	00027797          	auipc	a5,0x27
    800020ee:	f4e7b783          	ld	a5,-178(a5) # 80029038 <initproc>
    800020f2:	0d850493          	addi	s1,a0,216
    800020f6:	15850913          	addi	s2,a0,344
    800020fa:	02a79363          	bne	a5,a0,80002120 <exit+0x52>
    panic("init exiting");
    800020fe:	00006517          	auipc	a0,0x6
    80002102:	3a250513          	addi	a0,a0,930 # 800084a0 <userret+0x410>
    80002106:	ffffe097          	auipc	ra,0xffffe
    8000210a:	44e080e7          	jalr	1102(ra) # 80000554 <panic>
      fileclose(f);
    8000210e:	00002097          	auipc	ra,0x2
    80002112:	63e080e7          	jalr	1598(ra) # 8000474c <fileclose>
      p->ofile[fd] = 0;
    80002116:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000211a:	04a1                	addi	s1,s1,8
    8000211c:	01248563          	beq	s1,s2,80002126 <exit+0x58>
    if(p->ofile[fd]){
    80002120:	6088                	ld	a0,0(s1)
    80002122:	f575                	bnez	a0,8000210e <exit+0x40>
    80002124:	bfdd                	j	8000211a <exit+0x4c>
  begin_op(ROOTDEV);
    80002126:	4501                	li	a0,0
    80002128:	00002097          	auipc	ra,0x2
    8000212c:	08a080e7          	jalr	138(ra) # 800041b2 <begin_op>
  iput(p->cwd);
    80002130:	1589b503          	ld	a0,344(s3)
    80002134:	00001097          	auipc	ra,0x1
    80002138:	6c8080e7          	jalr	1736(ra) # 800037fc <iput>
  end_op(ROOTDEV);
    8000213c:	4501                	li	a0,0
    8000213e:	00002097          	auipc	ra,0x2
    80002142:	11e080e7          	jalr	286(ra) # 8000425c <end_op>
  p->cwd = 0;
    80002146:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    8000214a:	00027497          	auipc	s1,0x27
    8000214e:	eee48493          	addi	s1,s1,-274 # 80029038 <initproc>
    80002152:	6088                	ld	a0,0(s1)
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	94c080e7          	jalr	-1716(ra) # 80000aa0 <acquire>
  wakeup1(initproc);
    8000215c:	6088                	ld	a0,0(s1)
    8000215e:	fffff097          	auipc	ra,0xfffff
    80002162:	7ba080e7          	jalr	1978(ra) # 80001918 <wakeup1>
  release(&initproc->lock);
    80002166:	6088                	ld	a0,0(s1)
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	a08080e7          	jalr	-1528(ra) # 80000b70 <release>
  acquire(&p->lock);
    80002170:	854e                	mv	a0,s3
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	92e080e7          	jalr	-1746(ra) # 80000aa0 <acquire>
  struct proc *original_parent = p->parent;
    8000217a:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    8000217e:	854e                	mv	a0,s3
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	9f0080e7          	jalr	-1552(ra) # 80000b70 <release>
  acquire(&original_parent->lock);
    80002188:	8526                	mv	a0,s1
    8000218a:	fffff097          	auipc	ra,0xfffff
    8000218e:	916080e7          	jalr	-1770(ra) # 80000aa0 <acquire>
  acquire(&p->lock);
    80002192:	854e                	mv	a0,s3
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	90c080e7          	jalr	-1780(ra) # 80000aa0 <acquire>
  reparent(p);
    8000219c:	854e                	mv	a0,s3
    8000219e:	00000097          	auipc	ra,0x0
    800021a2:	d32080e7          	jalr	-718(ra) # 80001ed0 <reparent>
  wakeup1(original_parent);
    800021a6:	8526                	mv	a0,s1
    800021a8:	fffff097          	auipc	ra,0xfffff
    800021ac:	770080e7          	jalr	1904(ra) # 80001918 <wakeup1>
  p->xstate = status;
    800021b0:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800021b4:	4791                	li	a5,4
    800021b6:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800021ba:	8526                	mv	a0,s1
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	9b4080e7          	jalr	-1612(ra) # 80000b70 <release>
  sched();
    800021c4:	00000097          	auipc	ra,0x0
    800021c8:	e34080e7          	jalr	-460(ra) # 80001ff8 <sched>
  panic("zombie exit");
    800021cc:	00006517          	auipc	a0,0x6
    800021d0:	2e450513          	addi	a0,a0,740 # 800084b0 <userret+0x420>
    800021d4:	ffffe097          	auipc	ra,0xffffe
    800021d8:	380080e7          	jalr	896(ra) # 80000554 <panic>

00000000800021dc <yield>:
{
    800021dc:	1101                	addi	sp,sp,-32
    800021de:	ec06                	sd	ra,24(sp)
    800021e0:	e822                	sd	s0,16(sp)
    800021e2:	e426                	sd	s1,8(sp)
    800021e4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021e6:	00000097          	auipc	ra,0x0
    800021ea:	872080e7          	jalr	-1934(ra) # 80001a58 <myproc>
    800021ee:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021f0:	fffff097          	auipc	ra,0xfffff
    800021f4:	8b0080e7          	jalr	-1872(ra) # 80000aa0 <acquire>
  p->state = RUNNABLE;
    800021f8:	4789                	li	a5,2
    800021fa:	d09c                	sw	a5,32(s1)
  sched();
    800021fc:	00000097          	auipc	ra,0x0
    80002200:	dfc080e7          	jalr	-516(ra) # 80001ff8 <sched>
  release(&p->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	96a080e7          	jalr	-1686(ra) # 80000b70 <release>
}
    8000220e:	60e2                	ld	ra,24(sp)
    80002210:	6442                	ld	s0,16(sp)
    80002212:	64a2                	ld	s1,8(sp)
    80002214:	6105                	addi	sp,sp,32
    80002216:	8082                	ret

0000000080002218 <sleep>:
{
    80002218:	7179                	addi	sp,sp,-48
    8000221a:	f406                	sd	ra,40(sp)
    8000221c:	f022                	sd	s0,32(sp)
    8000221e:	ec26                	sd	s1,24(sp)
    80002220:	e84a                	sd	s2,16(sp)
    80002222:	e44e                	sd	s3,8(sp)
    80002224:	1800                	addi	s0,sp,48
    80002226:	89aa                	mv	s3,a0
    80002228:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000222a:	00000097          	auipc	ra,0x0
    8000222e:	82e080e7          	jalr	-2002(ra) # 80001a58 <myproc>
    80002232:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002234:	05250663          	beq	a0,s2,80002280 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	868080e7          	jalr	-1944(ra) # 80000aa0 <acquire>
    release(lk);
    80002240:	854a                	mv	a0,s2
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	92e080e7          	jalr	-1746(ra) # 80000b70 <release>
  p->chan = chan;
    8000224a:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000224e:	4785                	li	a5,1
    80002250:	d09c                	sw	a5,32(s1)
  sched();
    80002252:	00000097          	auipc	ra,0x0
    80002256:	da6080e7          	jalr	-602(ra) # 80001ff8 <sched>
  p->chan = 0;
    8000225a:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    8000225e:	8526                	mv	a0,s1
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	910080e7          	jalr	-1776(ra) # 80000b70 <release>
    acquire(lk);
    80002268:	854a                	mv	a0,s2
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	836080e7          	jalr	-1994(ra) # 80000aa0 <acquire>
}
    80002272:	70a2                	ld	ra,40(sp)
    80002274:	7402                	ld	s0,32(sp)
    80002276:	64e2                	ld	s1,24(sp)
    80002278:	6942                	ld	s2,16(sp)
    8000227a:	69a2                	ld	s3,8(sp)
    8000227c:	6145                	addi	sp,sp,48
    8000227e:	8082                	ret
  p->chan = chan;
    80002280:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    80002284:	4785                	li	a5,1
    80002286:	d11c                	sw	a5,32(a0)
  sched();
    80002288:	00000097          	auipc	ra,0x0
    8000228c:	d70080e7          	jalr	-656(ra) # 80001ff8 <sched>
  p->chan = 0;
    80002290:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    80002294:	bff9                	j	80002272 <sleep+0x5a>

0000000080002296 <wait>:
{
    80002296:	715d                	addi	sp,sp,-80
    80002298:	e486                	sd	ra,72(sp)
    8000229a:	e0a2                	sd	s0,64(sp)
    8000229c:	fc26                	sd	s1,56(sp)
    8000229e:	f84a                	sd	s2,48(sp)
    800022a0:	f44e                	sd	s3,40(sp)
    800022a2:	f052                	sd	s4,32(sp)
    800022a4:	ec56                	sd	s5,24(sp)
    800022a6:	e85a                	sd	s6,16(sp)
    800022a8:	e45e                	sd	s7,8(sp)
    800022aa:	0880                	addi	s0,sp,80
    800022ac:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	7aa080e7          	jalr	1962(ra) # 80001a58 <myproc>
    800022b6:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022b8:	ffffe097          	auipc	ra,0xffffe
    800022bc:	7e8080e7          	jalr	2024(ra) # 80000aa0 <acquire>
    havekids = 0;
    800022c0:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022c2:	4a11                	li	s4,4
        havekids = 1;
    800022c4:	4b05                	li	s6,1
    for(np = proc; np < &proc[NPROC]; np++){
    800022c6:	00013997          	auipc	s3,0x13
    800022ca:	7fa98993          	addi	s3,s3,2042 # 80015ac0 <tickslock>
    havekids = 0;
    800022ce:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022d0:	00013497          	auipc	s1,0x13
    800022d4:	99048493          	addi	s1,s1,-1648 # 80014c60 <proc>
    800022d8:	a08d                	j	8000233a <wait+0xa4>
          pid = np->pid;
    800022da:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022de:	000a8e63          	beqz	s5,800022fa <wait+0x64>
    800022e2:	4691                	li	a3,4
    800022e4:	03c48613          	addi	a2,s1,60
    800022e8:	85d6                	mv	a1,s5
    800022ea:	05893503          	ld	a0,88(s2)
    800022ee:	fffff097          	auipc	ra,0xfffff
    800022f2:	45c080e7          	jalr	1116(ra) # 8000174a <copyout>
    800022f6:	02054263          	bltz	a0,8000231a <wait+0x84>
          freeproc(np);
    800022fa:	8526                	mv	a0,s1
    800022fc:	00000097          	auipc	ra,0x0
    80002300:	978080e7          	jalr	-1672(ra) # 80001c74 <freeproc>
          release(&np->lock);
    80002304:	8526                	mv	a0,s1
    80002306:	fffff097          	auipc	ra,0xfffff
    8000230a:	86a080e7          	jalr	-1942(ra) # 80000b70 <release>
          release(&p->lock);
    8000230e:	854a                	mv	a0,s2
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	860080e7          	jalr	-1952(ra) # 80000b70 <release>
          return pid;
    80002318:	a8a9                	j	80002372 <wait+0xdc>
            release(&np->lock);
    8000231a:	8526                	mv	a0,s1
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	854080e7          	jalr	-1964(ra) # 80000b70 <release>
            release(&p->lock);
    80002324:	854a                	mv	a0,s2
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	84a080e7          	jalr	-1974(ra) # 80000b70 <release>
            return -1;
    8000232e:	59fd                	li	s3,-1
    80002330:	a089                	j	80002372 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002332:	17048493          	addi	s1,s1,368
    80002336:	03348463          	beq	s1,s3,8000235e <wait+0xc8>
      if(np->parent == p){
    8000233a:	749c                	ld	a5,40(s1)
    8000233c:	ff279be3          	bne	a5,s2,80002332 <wait+0x9c>
        acquire(&np->lock);
    80002340:	8526                	mv	a0,s1
    80002342:	ffffe097          	auipc	ra,0xffffe
    80002346:	75e080e7          	jalr	1886(ra) # 80000aa0 <acquire>
        if(np->state == ZOMBIE){
    8000234a:	509c                	lw	a5,32(s1)
    8000234c:	f94787e3          	beq	a5,s4,800022da <wait+0x44>
        release(&np->lock);
    80002350:	8526                	mv	a0,s1
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	81e080e7          	jalr	-2018(ra) # 80000b70 <release>
        havekids = 1;
    8000235a:	875a                	mv	a4,s6
    8000235c:	bfd9                	j	80002332 <wait+0x9c>
    if(!havekids || p->killed){
    8000235e:	c701                	beqz	a4,80002366 <wait+0xd0>
    80002360:	03892783          	lw	a5,56(s2)
    80002364:	c39d                	beqz	a5,8000238a <wait+0xf4>
      release(&p->lock);
    80002366:	854a                	mv	a0,s2
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	808080e7          	jalr	-2040(ra) # 80000b70 <release>
      return -1;
    80002370:	59fd                	li	s3,-1
}
    80002372:	854e                	mv	a0,s3
    80002374:	60a6                	ld	ra,72(sp)
    80002376:	6406                	ld	s0,64(sp)
    80002378:	74e2                	ld	s1,56(sp)
    8000237a:	7942                	ld	s2,48(sp)
    8000237c:	79a2                	ld	s3,40(sp)
    8000237e:	7a02                	ld	s4,32(sp)
    80002380:	6ae2                	ld	s5,24(sp)
    80002382:	6b42                	ld	s6,16(sp)
    80002384:	6ba2                	ld	s7,8(sp)
    80002386:	6161                	addi	sp,sp,80
    80002388:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000238a:	85ca                	mv	a1,s2
    8000238c:	854a                	mv	a0,s2
    8000238e:	00000097          	auipc	ra,0x0
    80002392:	e8a080e7          	jalr	-374(ra) # 80002218 <sleep>
    havekids = 0;
    80002396:	bf25                	j	800022ce <wait+0x38>

0000000080002398 <wakeup>:
{
    80002398:	7139                	addi	sp,sp,-64
    8000239a:	fc06                	sd	ra,56(sp)
    8000239c:	f822                	sd	s0,48(sp)
    8000239e:	f426                	sd	s1,40(sp)
    800023a0:	f04a                	sd	s2,32(sp)
    800023a2:	ec4e                	sd	s3,24(sp)
    800023a4:	e852                	sd	s4,16(sp)
    800023a6:	e456                	sd	s5,8(sp)
    800023a8:	0080                	addi	s0,sp,64
    800023aa:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023ac:	00013497          	auipc	s1,0x13
    800023b0:	8b448493          	addi	s1,s1,-1868 # 80014c60 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023b4:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023b6:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023b8:	00013917          	auipc	s2,0x13
    800023bc:	70890913          	addi	s2,s2,1800 # 80015ac0 <tickslock>
    800023c0:	a811                	j	800023d4 <wakeup+0x3c>
    release(&p->lock);
    800023c2:	8526                	mv	a0,s1
    800023c4:	ffffe097          	auipc	ra,0xffffe
    800023c8:	7ac080e7          	jalr	1964(ra) # 80000b70 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023cc:	17048493          	addi	s1,s1,368
    800023d0:	03248063          	beq	s1,s2,800023f0 <wakeup+0x58>
    acquire(&p->lock);
    800023d4:	8526                	mv	a0,s1
    800023d6:	ffffe097          	auipc	ra,0xffffe
    800023da:	6ca080e7          	jalr	1738(ra) # 80000aa0 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800023de:	509c                	lw	a5,32(s1)
    800023e0:	ff3791e3          	bne	a5,s3,800023c2 <wakeup+0x2a>
    800023e4:	789c                	ld	a5,48(s1)
    800023e6:	fd479ee3          	bne	a5,s4,800023c2 <wakeup+0x2a>
      p->state = RUNNABLE;
    800023ea:	0354a023          	sw	s5,32(s1)
    800023ee:	bfd1                	j	800023c2 <wakeup+0x2a>
}
    800023f0:	70e2                	ld	ra,56(sp)
    800023f2:	7442                	ld	s0,48(sp)
    800023f4:	74a2                	ld	s1,40(sp)
    800023f6:	7902                	ld	s2,32(sp)
    800023f8:	69e2                	ld	s3,24(sp)
    800023fa:	6a42                	ld	s4,16(sp)
    800023fc:	6aa2                	ld	s5,8(sp)
    800023fe:	6121                	addi	sp,sp,64
    80002400:	8082                	ret

0000000080002402 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002402:	7179                	addi	sp,sp,-48
    80002404:	f406                	sd	ra,40(sp)
    80002406:	f022                	sd	s0,32(sp)
    80002408:	ec26                	sd	s1,24(sp)
    8000240a:	e84a                	sd	s2,16(sp)
    8000240c:	e44e                	sd	s3,8(sp)
    8000240e:	1800                	addi	s0,sp,48
    80002410:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002412:	00013497          	auipc	s1,0x13
    80002416:	84e48493          	addi	s1,s1,-1970 # 80014c60 <proc>
    8000241a:	00013997          	auipc	s3,0x13
    8000241e:	6a698993          	addi	s3,s3,1702 # 80015ac0 <tickslock>
    acquire(&p->lock);
    80002422:	8526                	mv	a0,s1
    80002424:	ffffe097          	auipc	ra,0xffffe
    80002428:	67c080e7          	jalr	1660(ra) # 80000aa0 <acquire>
    if(p->pid == pid){
    8000242c:	40bc                	lw	a5,64(s1)
    8000242e:	03278363          	beq	a5,s2,80002454 <kill+0x52>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002432:	8526                	mv	a0,s1
    80002434:	ffffe097          	auipc	ra,0xffffe
    80002438:	73c080e7          	jalr	1852(ra) # 80000b70 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000243c:	17048493          	addi	s1,s1,368
    80002440:	ff3491e3          	bne	s1,s3,80002422 <kill+0x20>
  }
  return -1;
    80002444:	557d                	li	a0,-1
}
    80002446:	70a2                	ld	ra,40(sp)
    80002448:	7402                	ld	s0,32(sp)
    8000244a:	64e2                	ld	s1,24(sp)
    8000244c:	6942                	ld	s2,16(sp)
    8000244e:	69a2                	ld	s3,8(sp)
    80002450:	6145                	addi	sp,sp,48
    80002452:	8082                	ret
      p->killed = 1;
    80002454:	4785                	li	a5,1
    80002456:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    80002458:	5098                	lw	a4,32(s1)
    8000245a:	00f70963          	beq	a4,a5,8000246c <kill+0x6a>
      release(&p->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	ffffe097          	auipc	ra,0xffffe
    80002464:	710080e7          	jalr	1808(ra) # 80000b70 <release>
      return 0;
    80002468:	4501                	li	a0,0
    8000246a:	bff1                	j	80002446 <kill+0x44>
        p->state = RUNNABLE;
    8000246c:	4789                	li	a5,2
    8000246e:	d09c                	sw	a5,32(s1)
    80002470:	b7fd                	j	8000245e <kill+0x5c>

0000000080002472 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002472:	7179                	addi	sp,sp,-48
    80002474:	f406                	sd	ra,40(sp)
    80002476:	f022                	sd	s0,32(sp)
    80002478:	ec26                	sd	s1,24(sp)
    8000247a:	e84a                	sd	s2,16(sp)
    8000247c:	e44e                	sd	s3,8(sp)
    8000247e:	e052                	sd	s4,0(sp)
    80002480:	1800                	addi	s0,sp,48
    80002482:	84aa                	mv	s1,a0
    80002484:	892e                	mv	s2,a1
    80002486:	89b2                	mv	s3,a2
    80002488:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	5ce080e7          	jalr	1486(ra) # 80001a58 <myproc>
  if(user_dst){
    80002492:	c08d                	beqz	s1,800024b4 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002494:	86d2                	mv	a3,s4
    80002496:	864e                	mv	a2,s3
    80002498:	85ca                	mv	a1,s2
    8000249a:	6d28                	ld	a0,88(a0)
    8000249c:	fffff097          	auipc	ra,0xfffff
    800024a0:	2ae080e7          	jalr	686(ra) # 8000174a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024a4:	70a2                	ld	ra,40(sp)
    800024a6:	7402                	ld	s0,32(sp)
    800024a8:	64e2                	ld	s1,24(sp)
    800024aa:	6942                	ld	s2,16(sp)
    800024ac:	69a2                	ld	s3,8(sp)
    800024ae:	6a02                	ld	s4,0(sp)
    800024b0:	6145                	addi	sp,sp,48
    800024b2:	8082                	ret
    memmove((char *)dst, src, len);
    800024b4:	000a061b          	sext.w	a2,s4
    800024b8:	85ce                	mv	a1,s3
    800024ba:	854a                	mv	a0,s2
    800024bc:	fffff097          	auipc	ra,0xfffff
    800024c0:	90e080e7          	jalr	-1778(ra) # 80000dca <memmove>
    return 0;
    800024c4:	8526                	mv	a0,s1
    800024c6:	bff9                	j	800024a4 <either_copyout+0x32>

00000000800024c8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024c8:	7179                	addi	sp,sp,-48
    800024ca:	f406                	sd	ra,40(sp)
    800024cc:	f022                	sd	s0,32(sp)
    800024ce:	ec26                	sd	s1,24(sp)
    800024d0:	e84a                	sd	s2,16(sp)
    800024d2:	e44e                	sd	s3,8(sp)
    800024d4:	e052                	sd	s4,0(sp)
    800024d6:	1800                	addi	s0,sp,48
    800024d8:	892a                	mv	s2,a0
    800024da:	84ae                	mv	s1,a1
    800024dc:	89b2                	mv	s3,a2
    800024de:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024e0:	fffff097          	auipc	ra,0xfffff
    800024e4:	578080e7          	jalr	1400(ra) # 80001a58 <myproc>
  if(user_src){
    800024e8:	c08d                	beqz	s1,8000250a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024ea:	86d2                	mv	a3,s4
    800024ec:	864e                	mv	a2,s3
    800024ee:	85ca                	mv	a1,s2
    800024f0:	6d28                	ld	a0,88(a0)
    800024f2:	fffff097          	auipc	ra,0xfffff
    800024f6:	2e4080e7          	jalr	740(ra) # 800017d6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024fa:	70a2                	ld	ra,40(sp)
    800024fc:	7402                	ld	s0,32(sp)
    800024fe:	64e2                	ld	s1,24(sp)
    80002500:	6942                	ld	s2,16(sp)
    80002502:	69a2                	ld	s3,8(sp)
    80002504:	6a02                	ld	s4,0(sp)
    80002506:	6145                	addi	sp,sp,48
    80002508:	8082                	ret
    memmove(dst, (char*)src, len);
    8000250a:	000a061b          	sext.w	a2,s4
    8000250e:	85ce                	mv	a1,s3
    80002510:	854a                	mv	a0,s2
    80002512:	fffff097          	auipc	ra,0xfffff
    80002516:	8b8080e7          	jalr	-1864(ra) # 80000dca <memmove>
    return 0;
    8000251a:	8526                	mv	a0,s1
    8000251c:	bff9                	j	800024fa <either_copyin+0x32>

000000008000251e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000251e:	715d                	addi	sp,sp,-80
    80002520:	e486                	sd	ra,72(sp)
    80002522:	e0a2                	sd	s0,64(sp)
    80002524:	fc26                	sd	s1,56(sp)
    80002526:	f84a                	sd	s2,48(sp)
    80002528:	f44e                	sd	s3,40(sp)
    8000252a:	f052                	sd	s4,32(sp)
    8000252c:	ec56                	sd	s5,24(sp)
    8000252e:	e85a                	sd	s6,16(sp)
    80002530:	e45e                	sd	s7,8(sp)
    80002532:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002534:	00006517          	auipc	a0,0x6
    80002538:	d5c50513          	addi	a0,a0,-676 # 80008290 <userret+0x200>
    8000253c:	ffffe097          	auipc	ra,0xffffe
    80002540:	072080e7          	jalr	114(ra) # 800005ae <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002544:	00013497          	auipc	s1,0x13
    80002548:	87c48493          	addi	s1,s1,-1924 # 80014dc0 <proc+0x160>
    8000254c:	00013917          	auipc	s2,0x13
    80002550:	6d490913          	addi	s2,s2,1748 # 80015c20 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002554:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002556:	00006997          	auipc	s3,0x6
    8000255a:	f6a98993          	addi	s3,s3,-150 # 800084c0 <userret+0x430>
    printf("%d %s %s", p->pid, state, p->name);
    8000255e:	00006a97          	auipc	s5,0x6
    80002562:	f6aa8a93          	addi	s5,s5,-150 # 800084c8 <userret+0x438>
    printf("\n");
    80002566:	00006a17          	auipc	s4,0x6
    8000256a:	d2aa0a13          	addi	s4,s4,-726 # 80008290 <userret+0x200>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000256e:	00006b97          	auipc	s7,0x6
    80002572:	5fab8b93          	addi	s7,s7,1530 # 80008b68 <states.0>
    80002576:	a00d                	j	80002598 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002578:	ee06a583          	lw	a1,-288(a3)
    8000257c:	8556                	mv	a0,s5
    8000257e:	ffffe097          	auipc	ra,0xffffe
    80002582:	030080e7          	jalr	48(ra) # 800005ae <printf>
    printf("\n");
    80002586:	8552                	mv	a0,s4
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	026080e7          	jalr	38(ra) # 800005ae <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002590:	17048493          	addi	s1,s1,368
    80002594:	03248163          	beq	s1,s2,800025b6 <procdump+0x98>
    if(p->state == UNUSED)
    80002598:	86a6                	mv	a3,s1
    8000259a:	ec04a783          	lw	a5,-320(s1)
    8000259e:	dbed                	beqz	a5,80002590 <procdump+0x72>
      state = "???";
    800025a0:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a2:	fcfb6be3          	bltu	s6,a5,80002578 <procdump+0x5a>
    800025a6:	1782                	slli	a5,a5,0x20
    800025a8:	9381                	srli	a5,a5,0x20
    800025aa:	078e                	slli	a5,a5,0x3
    800025ac:	97de                	add	a5,a5,s7
    800025ae:	6390                	ld	a2,0(a5)
    800025b0:	f661                	bnez	a2,80002578 <procdump+0x5a>
      state = "???";
    800025b2:	864e                	mv	a2,s3
    800025b4:	b7d1                	j	80002578 <procdump+0x5a>
  }
}
    800025b6:	60a6                	ld	ra,72(sp)
    800025b8:	6406                	ld	s0,64(sp)
    800025ba:	74e2                	ld	s1,56(sp)
    800025bc:	7942                	ld	s2,48(sp)
    800025be:	79a2                	ld	s3,40(sp)
    800025c0:	7a02                	ld	s4,32(sp)
    800025c2:	6ae2                	ld	s5,24(sp)
    800025c4:	6b42                	ld	s6,16(sp)
    800025c6:	6ba2                	ld	s7,8(sp)
    800025c8:	6161                	addi	sp,sp,80
    800025ca:	8082                	ret

00000000800025cc <swtch>:
    800025cc:	00153023          	sd	ra,0(a0)
    800025d0:	00253423          	sd	sp,8(a0)
    800025d4:	e900                	sd	s0,16(a0)
    800025d6:	ed04                	sd	s1,24(a0)
    800025d8:	03253023          	sd	s2,32(a0)
    800025dc:	03353423          	sd	s3,40(a0)
    800025e0:	03453823          	sd	s4,48(a0)
    800025e4:	03553c23          	sd	s5,56(a0)
    800025e8:	05653023          	sd	s6,64(a0)
    800025ec:	05753423          	sd	s7,72(a0)
    800025f0:	05853823          	sd	s8,80(a0)
    800025f4:	05953c23          	sd	s9,88(a0)
    800025f8:	07a53023          	sd	s10,96(a0)
    800025fc:	07b53423          	sd	s11,104(a0)
    80002600:	0005b083          	ld	ra,0(a1)
    80002604:	0085b103          	ld	sp,8(a1)
    80002608:	6980                	ld	s0,16(a1)
    8000260a:	6d84                	ld	s1,24(a1)
    8000260c:	0205b903          	ld	s2,32(a1)
    80002610:	0285b983          	ld	s3,40(a1)
    80002614:	0305ba03          	ld	s4,48(a1)
    80002618:	0385ba83          	ld	s5,56(a1)
    8000261c:	0405bb03          	ld	s6,64(a1)
    80002620:	0485bb83          	ld	s7,72(a1)
    80002624:	0505bc03          	ld	s8,80(a1)
    80002628:	0585bc83          	ld	s9,88(a1)
    8000262c:	0605bd03          	ld	s10,96(a1)
    80002630:	0685bd83          	ld	s11,104(a1)
    80002634:	8082                	ret

0000000080002636 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002636:	1141                	addi	sp,sp,-16
    80002638:	e406                	sd	ra,8(sp)
    8000263a:	e022                	sd	s0,0(sp)
    8000263c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000263e:	00006597          	auipc	a1,0x6
    80002642:	ec258593          	addi	a1,a1,-318 # 80008500 <userret+0x470>
    80002646:	00013517          	auipc	a0,0x13
    8000264a:	47a50513          	addi	a0,a0,1146 # 80015ac0 <tickslock>
    8000264e:	ffffe097          	auipc	ra,0xffffe
    80002652:	37e080e7          	jalr	894(ra) # 800009cc <initlock>
}
    80002656:	60a2                	ld	ra,8(sp)
    80002658:	6402                	ld	s0,0(sp)
    8000265a:	0141                	addi	sp,sp,16
    8000265c:	8082                	ret

000000008000265e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000265e:	1141                	addi	sp,sp,-16
    80002660:	e422                	sd	s0,8(sp)
    80002662:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002664:	00004797          	auipc	a5,0x4
    80002668:	96c78793          	addi	a5,a5,-1684 # 80005fd0 <kernelvec>
    8000266c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002670:	6422                	ld	s0,8(sp)
    80002672:	0141                	addi	sp,sp,16
    80002674:	8082                	ret

0000000080002676 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002676:	1141                	addi	sp,sp,-16
    80002678:	e406                	sd	ra,8(sp)
    8000267a:	e022                	sd	s0,0(sp)
    8000267c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000267e:	fffff097          	auipc	ra,0xfffff
    80002682:	3da080e7          	jalr	986(ra) # 80001a58 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002686:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000268a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000268c:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002690:	00006617          	auipc	a2,0x6
    80002694:	97060613          	addi	a2,a2,-1680 # 80008000 <trampoline>
    80002698:	00006697          	auipc	a3,0x6
    8000269c:	96868693          	addi	a3,a3,-1688 # 80008000 <trampoline>
    800026a0:	8e91                	sub	a3,a3,a2
    800026a2:	040007b7          	lui	a5,0x4000
    800026a6:	17fd                	addi	a5,a5,-1
    800026a8:	07b2                	slli	a5,a5,0xc
    800026aa:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026ac:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    800026b0:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026b2:	180026f3          	csrr	a3,satp
    800026b6:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026b8:	7138                	ld	a4,96(a0)
    800026ba:	6534                	ld	a3,72(a0)
    800026bc:	6585                	lui	a1,0x1
    800026be:	96ae                	add	a3,a3,a1
    800026c0:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    800026c2:	7138                	ld	a4,96(a0)
    800026c4:	00000697          	auipc	a3,0x0
    800026c8:	12c68693          	addi	a3,a3,300 # 800027f0 <usertrap>
    800026cc:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    800026ce:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026d0:	8692                	mv	a3,tp
    800026d2:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026d4:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026d8:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026dc:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026e0:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    800026e4:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026e6:	6f18                	ld	a4,24(a4)
    800026e8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026ec:	6d2c                	ld	a1,88(a0)
    800026ee:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800026f0:	00006717          	auipc	a4,0x6
    800026f4:	9a070713          	addi	a4,a4,-1632 # 80008090 <userret>
    800026f8:	8f11                	sub	a4,a4,a2
    800026fa:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800026fc:	577d                	li	a4,-1
    800026fe:	177e                	slli	a4,a4,0x3f
    80002700:	8dd9                	or	a1,a1,a4
    80002702:	02000537          	lui	a0,0x2000
    80002706:	157d                	addi	a0,a0,-1
    80002708:	0536                	slli	a0,a0,0xd
    8000270a:	9782                	jalr	a5
}
    8000270c:	60a2                	ld	ra,8(sp)
    8000270e:	6402                	ld	s0,0(sp)
    80002710:	0141                	addi	sp,sp,16
    80002712:	8082                	ret

0000000080002714 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002714:	1101                	addi	sp,sp,-32
    80002716:	ec06                	sd	ra,24(sp)
    80002718:	e822                	sd	s0,16(sp)
    8000271a:	e426                	sd	s1,8(sp)
    8000271c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000271e:	00013497          	auipc	s1,0x13
    80002722:	3a248493          	addi	s1,s1,930 # 80015ac0 <tickslock>
    80002726:	8526                	mv	a0,s1
    80002728:	ffffe097          	auipc	ra,0xffffe
    8000272c:	378080e7          	jalr	888(ra) # 80000aa0 <acquire>
  ticks++;
    80002730:	00027517          	auipc	a0,0x27
    80002734:	91050513          	addi	a0,a0,-1776 # 80029040 <ticks>
    80002738:	411c                	lw	a5,0(a0)
    8000273a:	2785                	addiw	a5,a5,1
    8000273c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000273e:	00000097          	auipc	ra,0x0
    80002742:	c5a080e7          	jalr	-934(ra) # 80002398 <wakeup>
  release(&tickslock);
    80002746:	8526                	mv	a0,s1
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	428080e7          	jalr	1064(ra) # 80000b70 <release>
}
    80002750:	60e2                	ld	ra,24(sp)
    80002752:	6442                	ld	s0,16(sp)
    80002754:	64a2                	ld	s1,8(sp)
    80002756:	6105                	addi	sp,sp,32
    80002758:	8082                	ret

000000008000275a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000275a:	1101                	addi	sp,sp,-32
    8000275c:	ec06                	sd	ra,24(sp)
    8000275e:	e822                	sd	s0,16(sp)
    80002760:	e426                	sd	s1,8(sp)
    80002762:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002764:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002768:	00074d63          	bltz	a4,80002782 <devintr+0x28>

    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000276c:	57fd                	li	a5,-1
    8000276e:	17fe                	slli	a5,a5,0x3f
    80002770:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002772:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002774:	04f70d63          	beq	a4,a5,800027ce <devintr+0x74>
  }
}
    80002778:	60e2                	ld	ra,24(sp)
    8000277a:	6442                	ld	s0,16(sp)
    8000277c:	64a2                	ld	s1,8(sp)
    8000277e:	6105                	addi	sp,sp,32
    80002780:	8082                	ret
     (scause & 0xff) == 9){
    80002782:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002786:	46a5                	li	a3,9
    80002788:	fed792e3          	bne	a5,a3,8000276c <devintr+0x12>
    int irq = plic_claim();
    8000278c:	00004097          	auipc	ra,0x4
    80002790:	94c080e7          	jalr	-1716(ra) # 800060d8 <plic_claim>
    80002794:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002796:	47a9                	li	a5,10
    80002798:	00f50a63          	beq	a0,a5,800027ac <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    8000279c:	fff5079b          	addiw	a5,a0,-1
    800027a0:	4705                	li	a4,1
    800027a2:	00f77a63          	bgeu	a4,a5,800027b6 <devintr+0x5c>
    return 1;
    800027a6:	4505                	li	a0,1
    if(irq)
    800027a8:	d8e1                	beqz	s1,80002778 <devintr+0x1e>
    800027aa:	a819                	j	800027c0 <devintr+0x66>
      uartintr();
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	098080e7          	jalr	152(ra) # 80000844 <uartintr>
    800027b4:	a031                	j	800027c0 <devintr+0x66>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800027b6:	853e                	mv	a0,a5
    800027b8:	00004097          	auipc	ra,0x4
    800027bc:	eee080e7          	jalr	-274(ra) # 800066a6 <virtio_disk_intr>
      plic_complete(irq);
    800027c0:	8526                	mv	a0,s1
    800027c2:	00004097          	auipc	ra,0x4
    800027c6:	93a080e7          	jalr	-1734(ra) # 800060fc <plic_complete>
    return 1;
    800027ca:	4505                	li	a0,1
    800027cc:	b775                	j	80002778 <devintr+0x1e>
    if(cpuid() == 0){
    800027ce:	fffff097          	auipc	ra,0xfffff
    800027d2:	25e080e7          	jalr	606(ra) # 80001a2c <cpuid>
    800027d6:	c901                	beqz	a0,800027e6 <devintr+0x8c>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027d8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027dc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027de:	14479073          	csrw	sip,a5
    return 2;
    800027e2:	4509                	li	a0,2
    800027e4:	bf51                	j	80002778 <devintr+0x1e>
      clockintr();
    800027e6:	00000097          	auipc	ra,0x0
    800027ea:	f2e080e7          	jalr	-210(ra) # 80002714 <clockintr>
    800027ee:	b7ed                	j	800027d8 <devintr+0x7e>

00000000800027f0 <usertrap>:
{
    800027f0:	1101                	addi	sp,sp,-32
    800027f2:	ec06                	sd	ra,24(sp)
    800027f4:	e822                	sd	s0,16(sp)
    800027f6:	e426                	sd	s1,8(sp)
    800027f8:	e04a                	sd	s2,0(sp)
    800027fa:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027fc:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002800:	1007f793          	andi	a5,a5,256
    80002804:	e3ad                	bnez	a5,80002866 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002806:	00003797          	auipc	a5,0x3
    8000280a:	7ca78793          	addi	a5,a5,1994 # 80005fd0 <kernelvec>
    8000280e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002812:	fffff097          	auipc	ra,0xfffff
    80002816:	246080e7          	jalr	582(ra) # 80001a58 <myproc>
    8000281a:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    8000281c:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000281e:	14102773          	csrr	a4,sepc
    80002822:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002824:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002828:	47a1                	li	a5,8
    8000282a:	04f71c63          	bne	a4,a5,80002882 <usertrap+0x92>
    if(p->killed)
    8000282e:	5d1c                	lw	a5,56(a0)
    80002830:	e3b9                	bnez	a5,80002876 <usertrap+0x86>
    p->tf->epc += 4;
    80002832:	70b8                	ld	a4,96(s1)
    80002834:	6f1c                	ld	a5,24(a4)
    80002836:	0791                	addi	a5,a5,4
    80002838:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000283a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000283e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002842:	10079073          	csrw	sstatus,a5
    syscall();
    80002846:	00000097          	auipc	ra,0x0
    8000284a:	2e0080e7          	jalr	736(ra) # 80002b26 <syscall>
  if(p->killed)
    8000284e:	5c9c                	lw	a5,56(s1)
    80002850:	ebc1                	bnez	a5,800028e0 <usertrap+0xf0>
  usertrapret();
    80002852:	00000097          	auipc	ra,0x0
    80002856:	e24080e7          	jalr	-476(ra) # 80002676 <usertrapret>
}
    8000285a:	60e2                	ld	ra,24(sp)
    8000285c:	6442                	ld	s0,16(sp)
    8000285e:	64a2                	ld	s1,8(sp)
    80002860:	6902                	ld	s2,0(sp)
    80002862:	6105                	addi	sp,sp,32
    80002864:	8082                	ret
    panic("usertrap: not from user mode");
    80002866:	00006517          	auipc	a0,0x6
    8000286a:	ca250513          	addi	a0,a0,-862 # 80008508 <userret+0x478>
    8000286e:	ffffe097          	auipc	ra,0xffffe
    80002872:	ce6080e7          	jalr	-794(ra) # 80000554 <panic>
      exit(-1);
    80002876:	557d                	li	a0,-1
    80002878:	00000097          	auipc	ra,0x0
    8000287c:	856080e7          	jalr	-1962(ra) # 800020ce <exit>
    80002880:	bf4d                	j	80002832 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002882:	00000097          	auipc	ra,0x0
    80002886:	ed8080e7          	jalr	-296(ra) # 8000275a <devintr>
    8000288a:	892a                	mv	s2,a0
    8000288c:	c501                	beqz	a0,80002894 <usertrap+0xa4>
  if(p->killed)
    8000288e:	5c9c                	lw	a5,56(s1)
    80002890:	c3a1                	beqz	a5,800028d0 <usertrap+0xe0>
    80002892:	a815                	j	800028c6 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002894:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002898:	40b0                	lw	a2,64(s1)
    8000289a:	00006517          	auipc	a0,0x6
    8000289e:	c8e50513          	addi	a0,a0,-882 # 80008528 <userret+0x498>
    800028a2:	ffffe097          	auipc	ra,0xffffe
    800028a6:	d0c080e7          	jalr	-756(ra) # 800005ae <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028aa:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028ae:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028b2:	00006517          	auipc	a0,0x6
    800028b6:	ca650513          	addi	a0,a0,-858 # 80008558 <userret+0x4c8>
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	cf4080e7          	jalr	-780(ra) # 800005ae <printf>
    p->killed = 1;
    800028c2:	4785                	li	a5,1
    800028c4:	dc9c                	sw	a5,56(s1)
    exit(-1);
    800028c6:	557d                	li	a0,-1
    800028c8:	00000097          	auipc	ra,0x0
    800028cc:	806080e7          	jalr	-2042(ra) # 800020ce <exit>
  if(which_dev == 2)
    800028d0:	4789                	li	a5,2
    800028d2:	f8f910e3          	bne	s2,a5,80002852 <usertrap+0x62>
    yield();
    800028d6:	00000097          	auipc	ra,0x0
    800028da:	906080e7          	jalr	-1786(ra) # 800021dc <yield>
    800028de:	bf95                	j	80002852 <usertrap+0x62>
  int which_dev = 0;
    800028e0:	4901                	li	s2,0
    800028e2:	b7d5                	j	800028c6 <usertrap+0xd6>

00000000800028e4 <kerneltrap>:
{
    800028e4:	7179                	addi	sp,sp,-48
    800028e6:	f406                	sd	ra,40(sp)
    800028e8:	f022                	sd	s0,32(sp)
    800028ea:	ec26                	sd	s1,24(sp)
    800028ec:	e84a                	sd	s2,16(sp)
    800028ee:	e44e                	sd	s3,8(sp)
    800028f0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028f2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028f6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028fa:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028fe:	1004f793          	andi	a5,s1,256
    80002902:	cb85                	beqz	a5,80002932 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002904:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002908:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000290a:	ef85                	bnez	a5,80002942 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000290c:	00000097          	auipc	ra,0x0
    80002910:	e4e080e7          	jalr	-434(ra) # 8000275a <devintr>
    80002914:	cd1d                	beqz	a0,80002952 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002916:	4789                	li	a5,2
    80002918:	06f50a63          	beq	a0,a5,8000298c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000291c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002920:	10049073          	csrw	sstatus,s1
}
    80002924:	70a2                	ld	ra,40(sp)
    80002926:	7402                	ld	s0,32(sp)
    80002928:	64e2                	ld	s1,24(sp)
    8000292a:	6942                	ld	s2,16(sp)
    8000292c:	69a2                	ld	s3,8(sp)
    8000292e:	6145                	addi	sp,sp,48
    80002930:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002932:	00006517          	auipc	a0,0x6
    80002936:	c4650513          	addi	a0,a0,-954 # 80008578 <userret+0x4e8>
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	c1a080e7          	jalr	-998(ra) # 80000554 <panic>
    panic("kerneltrap: interrupts enabled");
    80002942:	00006517          	auipc	a0,0x6
    80002946:	c5e50513          	addi	a0,a0,-930 # 800085a0 <userret+0x510>
    8000294a:	ffffe097          	auipc	ra,0xffffe
    8000294e:	c0a080e7          	jalr	-1014(ra) # 80000554 <panic>
    printf("scause %p\n", scause);
    80002952:	85ce                	mv	a1,s3
    80002954:	00006517          	auipc	a0,0x6
    80002958:	c6c50513          	addi	a0,a0,-916 # 800085c0 <userret+0x530>
    8000295c:	ffffe097          	auipc	ra,0xffffe
    80002960:	c52080e7          	jalr	-942(ra) # 800005ae <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002964:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002968:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000296c:	00006517          	auipc	a0,0x6
    80002970:	c6450513          	addi	a0,a0,-924 # 800085d0 <userret+0x540>
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	c3a080e7          	jalr	-966(ra) # 800005ae <printf>
    panic("kerneltrap");
    8000297c:	00006517          	auipc	a0,0x6
    80002980:	c6c50513          	addi	a0,a0,-916 # 800085e8 <userret+0x558>
    80002984:	ffffe097          	auipc	ra,0xffffe
    80002988:	bd0080e7          	jalr	-1072(ra) # 80000554 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000298c:	fffff097          	auipc	ra,0xfffff
    80002990:	0cc080e7          	jalr	204(ra) # 80001a58 <myproc>
    80002994:	d541                	beqz	a0,8000291c <kerneltrap+0x38>
    80002996:	fffff097          	auipc	ra,0xfffff
    8000299a:	0c2080e7          	jalr	194(ra) # 80001a58 <myproc>
    8000299e:	5118                	lw	a4,32(a0)
    800029a0:	478d                	li	a5,3
    800029a2:	f6f71de3          	bne	a4,a5,8000291c <kerneltrap+0x38>
    yield();
    800029a6:	00000097          	auipc	ra,0x0
    800029aa:	836080e7          	jalr	-1994(ra) # 800021dc <yield>
    800029ae:	b7bd                	j	8000291c <kerneltrap+0x38>

00000000800029b0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029b0:	1101                	addi	sp,sp,-32
    800029b2:	ec06                	sd	ra,24(sp)
    800029b4:	e822                	sd	s0,16(sp)
    800029b6:	e426                	sd	s1,8(sp)
    800029b8:	1000                	addi	s0,sp,32
    800029ba:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029bc:	fffff097          	auipc	ra,0xfffff
    800029c0:	09c080e7          	jalr	156(ra) # 80001a58 <myproc>
  switch (n) {
    800029c4:	4795                	li	a5,5
    800029c6:	0497e163          	bltu	a5,s1,80002a08 <argraw+0x58>
    800029ca:	048a                	slli	s1,s1,0x2
    800029cc:	00006717          	auipc	a4,0x6
    800029d0:	1c470713          	addi	a4,a4,452 # 80008b90 <states.0+0x28>
    800029d4:	94ba                	add	s1,s1,a4
    800029d6:	409c                	lw	a5,0(s1)
    800029d8:	97ba                	add	a5,a5,a4
    800029da:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    800029dc:	713c                	ld	a5,96(a0)
    800029de:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    800029e0:	60e2                	ld	ra,24(sp)
    800029e2:	6442                	ld	s0,16(sp)
    800029e4:	64a2                	ld	s1,8(sp)
    800029e6:	6105                	addi	sp,sp,32
    800029e8:	8082                	ret
    return p->tf->a1;
    800029ea:	713c                	ld	a5,96(a0)
    800029ec:	7fa8                	ld	a0,120(a5)
    800029ee:	bfcd                	j	800029e0 <argraw+0x30>
    return p->tf->a2;
    800029f0:	713c                	ld	a5,96(a0)
    800029f2:	63c8                	ld	a0,128(a5)
    800029f4:	b7f5                	j	800029e0 <argraw+0x30>
    return p->tf->a3;
    800029f6:	713c                	ld	a5,96(a0)
    800029f8:	67c8                	ld	a0,136(a5)
    800029fa:	b7dd                	j	800029e0 <argraw+0x30>
    return p->tf->a4;
    800029fc:	713c                	ld	a5,96(a0)
    800029fe:	6bc8                	ld	a0,144(a5)
    80002a00:	b7c5                	j	800029e0 <argraw+0x30>
    return p->tf->a5;
    80002a02:	713c                	ld	a5,96(a0)
    80002a04:	6fc8                	ld	a0,152(a5)
    80002a06:	bfe9                	j	800029e0 <argraw+0x30>
  panic("argraw");
    80002a08:	00006517          	auipc	a0,0x6
    80002a0c:	bf050513          	addi	a0,a0,-1040 # 800085f8 <userret+0x568>
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	b44080e7          	jalr	-1212(ra) # 80000554 <panic>

0000000080002a18 <fetchaddr>:
{
    80002a18:	1101                	addi	sp,sp,-32
    80002a1a:	ec06                	sd	ra,24(sp)
    80002a1c:	e822                	sd	s0,16(sp)
    80002a1e:	e426                	sd	s1,8(sp)
    80002a20:	e04a                	sd	s2,0(sp)
    80002a22:	1000                	addi	s0,sp,32
    80002a24:	84aa                	mv	s1,a0
    80002a26:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a28:	fffff097          	auipc	ra,0xfffff
    80002a2c:	030080e7          	jalr	48(ra) # 80001a58 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a30:	693c                	ld	a5,80(a0)
    80002a32:	02f4f863          	bgeu	s1,a5,80002a62 <fetchaddr+0x4a>
    80002a36:	00848713          	addi	a4,s1,8
    80002a3a:	02e7e663          	bltu	a5,a4,80002a66 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a3e:	46a1                	li	a3,8
    80002a40:	8626                	mv	a2,s1
    80002a42:	85ca                	mv	a1,s2
    80002a44:	6d28                	ld	a0,88(a0)
    80002a46:	fffff097          	auipc	ra,0xfffff
    80002a4a:	d90080e7          	jalr	-624(ra) # 800017d6 <copyin>
    80002a4e:	00a03533          	snez	a0,a0
    80002a52:	40a00533          	neg	a0,a0
}
    80002a56:	60e2                	ld	ra,24(sp)
    80002a58:	6442                	ld	s0,16(sp)
    80002a5a:	64a2                	ld	s1,8(sp)
    80002a5c:	6902                	ld	s2,0(sp)
    80002a5e:	6105                	addi	sp,sp,32
    80002a60:	8082                	ret
    return -1;
    80002a62:	557d                	li	a0,-1
    80002a64:	bfcd                	j	80002a56 <fetchaddr+0x3e>
    80002a66:	557d                	li	a0,-1
    80002a68:	b7fd                	j	80002a56 <fetchaddr+0x3e>

0000000080002a6a <fetchstr>:
{
    80002a6a:	7179                	addi	sp,sp,-48
    80002a6c:	f406                	sd	ra,40(sp)
    80002a6e:	f022                	sd	s0,32(sp)
    80002a70:	ec26                	sd	s1,24(sp)
    80002a72:	e84a                	sd	s2,16(sp)
    80002a74:	e44e                	sd	s3,8(sp)
    80002a76:	1800                	addi	s0,sp,48
    80002a78:	892a                	mv	s2,a0
    80002a7a:	84ae                	mv	s1,a1
    80002a7c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a7e:	fffff097          	auipc	ra,0xfffff
    80002a82:	fda080e7          	jalr	-38(ra) # 80001a58 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002a86:	86ce                	mv	a3,s3
    80002a88:	864a                	mv	a2,s2
    80002a8a:	85a6                	mv	a1,s1
    80002a8c:	6d28                	ld	a0,88(a0)
    80002a8e:	fffff097          	auipc	ra,0xfffff
    80002a92:	dd6080e7          	jalr	-554(ra) # 80001864 <copyinstr>
  if(err < 0)
    80002a96:	00054763          	bltz	a0,80002aa4 <fetchstr+0x3a>
  return strlen(buf);
    80002a9a:	8526                	mv	a0,s1
    80002a9c:	ffffe097          	auipc	ra,0xffffe
    80002aa0:	456080e7          	jalr	1110(ra) # 80000ef2 <strlen>
}
    80002aa4:	70a2                	ld	ra,40(sp)
    80002aa6:	7402                	ld	s0,32(sp)
    80002aa8:	64e2                	ld	s1,24(sp)
    80002aaa:	6942                	ld	s2,16(sp)
    80002aac:	69a2                	ld	s3,8(sp)
    80002aae:	6145                	addi	sp,sp,48
    80002ab0:	8082                	ret

0000000080002ab2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002ab2:	1101                	addi	sp,sp,-32
    80002ab4:	ec06                	sd	ra,24(sp)
    80002ab6:	e822                	sd	s0,16(sp)
    80002ab8:	e426                	sd	s1,8(sp)
    80002aba:	1000                	addi	s0,sp,32
    80002abc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002abe:	00000097          	auipc	ra,0x0
    80002ac2:	ef2080e7          	jalr	-270(ra) # 800029b0 <argraw>
    80002ac6:	c088                	sw	a0,0(s1)
  return 0;
}
    80002ac8:	4501                	li	a0,0
    80002aca:	60e2                	ld	ra,24(sp)
    80002acc:	6442                	ld	s0,16(sp)
    80002ace:	64a2                	ld	s1,8(sp)
    80002ad0:	6105                	addi	sp,sp,32
    80002ad2:	8082                	ret

0000000080002ad4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002ad4:	1101                	addi	sp,sp,-32
    80002ad6:	ec06                	sd	ra,24(sp)
    80002ad8:	e822                	sd	s0,16(sp)
    80002ada:	e426                	sd	s1,8(sp)
    80002adc:	1000                	addi	s0,sp,32
    80002ade:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ae0:	00000097          	auipc	ra,0x0
    80002ae4:	ed0080e7          	jalr	-304(ra) # 800029b0 <argraw>
    80002ae8:	e088                	sd	a0,0(s1)
  return 0;
}
    80002aea:	4501                	li	a0,0
    80002aec:	60e2                	ld	ra,24(sp)
    80002aee:	6442                	ld	s0,16(sp)
    80002af0:	64a2                	ld	s1,8(sp)
    80002af2:	6105                	addi	sp,sp,32
    80002af4:	8082                	ret

0000000080002af6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002af6:	1101                	addi	sp,sp,-32
    80002af8:	ec06                	sd	ra,24(sp)
    80002afa:	e822                	sd	s0,16(sp)
    80002afc:	e426                	sd	s1,8(sp)
    80002afe:	e04a                	sd	s2,0(sp)
    80002b00:	1000                	addi	s0,sp,32
    80002b02:	84ae                	mv	s1,a1
    80002b04:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b06:	00000097          	auipc	ra,0x0
    80002b0a:	eaa080e7          	jalr	-342(ra) # 800029b0 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b0e:	864a                	mv	a2,s2
    80002b10:	85a6                	mv	a1,s1
    80002b12:	00000097          	auipc	ra,0x0
    80002b16:	f58080e7          	jalr	-168(ra) # 80002a6a <fetchstr>
}
    80002b1a:	60e2                	ld	ra,24(sp)
    80002b1c:	6442                	ld	s0,16(sp)
    80002b1e:	64a2                	ld	s1,8(sp)
    80002b20:	6902                	ld	s2,0(sp)
    80002b22:	6105                	addi	sp,sp,32
    80002b24:	8082                	ret

0000000080002b26 <syscall>:
[SYS_symlink] sys_symlink
};

void
syscall(void)
{
    80002b26:	1101                	addi	sp,sp,-32
    80002b28:	ec06                	sd	ra,24(sp)
    80002b2a:	e822                	sd	s0,16(sp)
    80002b2c:	e426                	sd	s1,8(sp)
    80002b2e:	e04a                	sd	s2,0(sp)
    80002b30:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b32:	fffff097          	auipc	ra,0xfffff
    80002b36:	f26080e7          	jalr	-218(ra) # 80001a58 <myproc>
    80002b3a:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002b3c:	06053903          	ld	s2,96(a0)
    80002b40:	0a893783          	ld	a5,168(s2)
    80002b44:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b48:	37fd                	addiw	a5,a5,-1
    80002b4a:	4759                	li	a4,22
    80002b4c:	00f76f63          	bltu	a4,a5,80002b6a <syscall+0x44>
    80002b50:	00369713          	slli	a4,a3,0x3
    80002b54:	00006797          	auipc	a5,0x6
    80002b58:	05478793          	addi	a5,a5,84 # 80008ba8 <syscalls>
    80002b5c:	97ba                	add	a5,a5,a4
    80002b5e:	639c                	ld	a5,0(a5)
    80002b60:	c789                	beqz	a5,80002b6a <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002b62:	9782                	jalr	a5
    80002b64:	06a93823          	sd	a0,112(s2)
    80002b68:	a839                	j	80002b86 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b6a:	16048613          	addi	a2,s1,352
    80002b6e:	40ac                	lw	a1,64(s1)
    80002b70:	00006517          	auipc	a0,0x6
    80002b74:	a9050513          	addi	a0,a0,-1392 # 80008600 <userret+0x570>
    80002b78:	ffffe097          	auipc	ra,0xffffe
    80002b7c:	a36080e7          	jalr	-1482(ra) # 800005ae <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002b80:	70bc                	ld	a5,96(s1)
    80002b82:	577d                	li	a4,-1
    80002b84:	fbb8                	sd	a4,112(a5)
  }
}
    80002b86:	60e2                	ld	ra,24(sp)
    80002b88:	6442                	ld	s0,16(sp)
    80002b8a:	64a2                	ld	s1,8(sp)
    80002b8c:	6902                	ld	s2,0(sp)
    80002b8e:	6105                	addi	sp,sp,32
    80002b90:	8082                	ret

0000000080002b92 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002b92:	1101                	addi	sp,sp,-32
    80002b94:	ec06                	sd	ra,24(sp)
    80002b96:	e822                	sd	s0,16(sp)
    80002b98:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002b9a:	fec40593          	addi	a1,s0,-20
    80002b9e:	4501                	li	a0,0
    80002ba0:	00000097          	auipc	ra,0x0
    80002ba4:	f12080e7          	jalr	-238(ra) # 80002ab2 <argint>
    return -1;
    80002ba8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002baa:	00054963          	bltz	a0,80002bbc <sys_exit+0x2a>
  exit(n);
    80002bae:	fec42503          	lw	a0,-20(s0)
    80002bb2:	fffff097          	auipc	ra,0xfffff
    80002bb6:	51c080e7          	jalr	1308(ra) # 800020ce <exit>
  return 0;  // not reached
    80002bba:	4781                	li	a5,0
}
    80002bbc:	853e                	mv	a0,a5
    80002bbe:	60e2                	ld	ra,24(sp)
    80002bc0:	6442                	ld	s0,16(sp)
    80002bc2:	6105                	addi	sp,sp,32
    80002bc4:	8082                	ret

0000000080002bc6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bc6:	1141                	addi	sp,sp,-16
    80002bc8:	e406                	sd	ra,8(sp)
    80002bca:	e022                	sd	s0,0(sp)
    80002bcc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bce:	fffff097          	auipc	ra,0xfffff
    80002bd2:	e8a080e7          	jalr	-374(ra) # 80001a58 <myproc>
}
    80002bd6:	4128                	lw	a0,64(a0)
    80002bd8:	60a2                	ld	ra,8(sp)
    80002bda:	6402                	ld	s0,0(sp)
    80002bdc:	0141                	addi	sp,sp,16
    80002bde:	8082                	ret

0000000080002be0 <sys_fork>:

uint64
sys_fork(void)
{
    80002be0:	1141                	addi	sp,sp,-16
    80002be2:	e406                	sd	ra,8(sp)
    80002be4:	e022                	sd	s0,0(sp)
    80002be6:	0800                	addi	s0,sp,16
  return fork();
    80002be8:	fffff097          	auipc	ra,0xfffff
    80002bec:	1da080e7          	jalr	474(ra) # 80001dc2 <fork>
}
    80002bf0:	60a2                	ld	ra,8(sp)
    80002bf2:	6402                	ld	s0,0(sp)
    80002bf4:	0141                	addi	sp,sp,16
    80002bf6:	8082                	ret

0000000080002bf8 <sys_wait>:

uint64
sys_wait(void)
{
    80002bf8:	1101                	addi	sp,sp,-32
    80002bfa:	ec06                	sd	ra,24(sp)
    80002bfc:	e822                	sd	s0,16(sp)
    80002bfe:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c00:	fe840593          	addi	a1,s0,-24
    80002c04:	4501                	li	a0,0
    80002c06:	00000097          	auipc	ra,0x0
    80002c0a:	ece080e7          	jalr	-306(ra) # 80002ad4 <argaddr>
    80002c0e:	87aa                	mv	a5,a0
    return -1;
    80002c10:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002c12:	0007c863          	bltz	a5,80002c22 <sys_wait+0x2a>
  return wait(p);
    80002c16:	fe843503          	ld	a0,-24(s0)
    80002c1a:	fffff097          	auipc	ra,0xfffff
    80002c1e:	67c080e7          	jalr	1660(ra) # 80002296 <wait>
}
    80002c22:	60e2                	ld	ra,24(sp)
    80002c24:	6442                	ld	s0,16(sp)
    80002c26:	6105                	addi	sp,sp,32
    80002c28:	8082                	ret

0000000080002c2a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c2a:	7179                	addi	sp,sp,-48
    80002c2c:	f406                	sd	ra,40(sp)
    80002c2e:	f022                	sd	s0,32(sp)
    80002c30:	ec26                	sd	s1,24(sp)
    80002c32:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c34:	fdc40593          	addi	a1,s0,-36
    80002c38:	4501                	li	a0,0
    80002c3a:	00000097          	auipc	ra,0x0
    80002c3e:	e78080e7          	jalr	-392(ra) # 80002ab2 <argint>
    return -1;
    80002c42:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002c44:	00054f63          	bltz	a0,80002c62 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002c48:	fffff097          	auipc	ra,0xfffff
    80002c4c:	e10080e7          	jalr	-496(ra) # 80001a58 <myproc>
    80002c50:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002c52:	fdc42503          	lw	a0,-36(s0)
    80002c56:	fffff097          	auipc	ra,0xfffff
    80002c5a:	0f8080e7          	jalr	248(ra) # 80001d4e <growproc>
    80002c5e:	00054863          	bltz	a0,80002c6e <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002c62:	8526                	mv	a0,s1
    80002c64:	70a2                	ld	ra,40(sp)
    80002c66:	7402                	ld	s0,32(sp)
    80002c68:	64e2                	ld	s1,24(sp)
    80002c6a:	6145                	addi	sp,sp,48
    80002c6c:	8082                	ret
    return -1;
    80002c6e:	54fd                	li	s1,-1
    80002c70:	bfcd                	j	80002c62 <sys_sbrk+0x38>

0000000080002c72 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c72:	7139                	addi	sp,sp,-64
    80002c74:	fc06                	sd	ra,56(sp)
    80002c76:	f822                	sd	s0,48(sp)
    80002c78:	f426                	sd	s1,40(sp)
    80002c7a:	f04a                	sd	s2,32(sp)
    80002c7c:	ec4e                	sd	s3,24(sp)
    80002c7e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002c80:	fcc40593          	addi	a1,s0,-52
    80002c84:	4501                	li	a0,0
    80002c86:	00000097          	auipc	ra,0x0
    80002c8a:	e2c080e7          	jalr	-468(ra) # 80002ab2 <argint>
    return -1;
    80002c8e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c90:	06054563          	bltz	a0,80002cfa <sys_sleep+0x88>
  acquire(&tickslock);
    80002c94:	00013517          	auipc	a0,0x13
    80002c98:	e2c50513          	addi	a0,a0,-468 # 80015ac0 <tickslock>
    80002c9c:	ffffe097          	auipc	ra,0xffffe
    80002ca0:	e04080e7          	jalr	-508(ra) # 80000aa0 <acquire>
  ticks0 = ticks;
    80002ca4:	00026917          	auipc	s2,0x26
    80002ca8:	39c92903          	lw	s2,924(s2) # 80029040 <ticks>
  while(ticks - ticks0 < n){
    80002cac:	fcc42783          	lw	a5,-52(s0)
    80002cb0:	cf85                	beqz	a5,80002ce8 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cb2:	00013997          	auipc	s3,0x13
    80002cb6:	e0e98993          	addi	s3,s3,-498 # 80015ac0 <tickslock>
    80002cba:	00026497          	auipc	s1,0x26
    80002cbe:	38648493          	addi	s1,s1,902 # 80029040 <ticks>
    if(myproc()->killed){
    80002cc2:	fffff097          	auipc	ra,0xfffff
    80002cc6:	d96080e7          	jalr	-618(ra) # 80001a58 <myproc>
    80002cca:	5d1c                	lw	a5,56(a0)
    80002ccc:	ef9d                	bnez	a5,80002d0a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002cce:	85ce                	mv	a1,s3
    80002cd0:	8526                	mv	a0,s1
    80002cd2:	fffff097          	auipc	ra,0xfffff
    80002cd6:	546080e7          	jalr	1350(ra) # 80002218 <sleep>
  while(ticks - ticks0 < n){
    80002cda:	409c                	lw	a5,0(s1)
    80002cdc:	412787bb          	subw	a5,a5,s2
    80002ce0:	fcc42703          	lw	a4,-52(s0)
    80002ce4:	fce7efe3          	bltu	a5,a4,80002cc2 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002ce8:	00013517          	auipc	a0,0x13
    80002cec:	dd850513          	addi	a0,a0,-552 # 80015ac0 <tickslock>
    80002cf0:	ffffe097          	auipc	ra,0xffffe
    80002cf4:	e80080e7          	jalr	-384(ra) # 80000b70 <release>
  return 0;
    80002cf8:	4781                	li	a5,0
}
    80002cfa:	853e                	mv	a0,a5
    80002cfc:	70e2                	ld	ra,56(sp)
    80002cfe:	7442                	ld	s0,48(sp)
    80002d00:	74a2                	ld	s1,40(sp)
    80002d02:	7902                	ld	s2,32(sp)
    80002d04:	69e2                	ld	s3,24(sp)
    80002d06:	6121                	addi	sp,sp,64
    80002d08:	8082                	ret
      release(&tickslock);
    80002d0a:	00013517          	auipc	a0,0x13
    80002d0e:	db650513          	addi	a0,a0,-586 # 80015ac0 <tickslock>
    80002d12:	ffffe097          	auipc	ra,0xffffe
    80002d16:	e5e080e7          	jalr	-418(ra) # 80000b70 <release>
      return -1;
    80002d1a:	57fd                	li	a5,-1
    80002d1c:	bff9                	j	80002cfa <sys_sleep+0x88>

0000000080002d1e <sys_kill>:

uint64
sys_kill(void)
{
    80002d1e:	1101                	addi	sp,sp,-32
    80002d20:	ec06                	sd	ra,24(sp)
    80002d22:	e822                	sd	s0,16(sp)
    80002d24:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d26:	fec40593          	addi	a1,s0,-20
    80002d2a:	4501                	li	a0,0
    80002d2c:	00000097          	auipc	ra,0x0
    80002d30:	d86080e7          	jalr	-634(ra) # 80002ab2 <argint>
    80002d34:	87aa                	mv	a5,a0
    return -1;
    80002d36:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002d38:	0007c863          	bltz	a5,80002d48 <sys_kill+0x2a>
  return kill(pid);
    80002d3c:	fec42503          	lw	a0,-20(s0)
    80002d40:	fffff097          	auipc	ra,0xfffff
    80002d44:	6c2080e7          	jalr	1730(ra) # 80002402 <kill>
}
    80002d48:	60e2                	ld	ra,24(sp)
    80002d4a:	6442                	ld	s0,16(sp)
    80002d4c:	6105                	addi	sp,sp,32
    80002d4e:	8082                	ret

0000000080002d50 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d50:	1101                	addi	sp,sp,-32
    80002d52:	ec06                	sd	ra,24(sp)
    80002d54:	e822                	sd	s0,16(sp)
    80002d56:	e426                	sd	s1,8(sp)
    80002d58:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d5a:	00013517          	auipc	a0,0x13
    80002d5e:	d6650513          	addi	a0,a0,-666 # 80015ac0 <tickslock>
    80002d62:	ffffe097          	auipc	ra,0xffffe
    80002d66:	d3e080e7          	jalr	-706(ra) # 80000aa0 <acquire>
  xticks = ticks;
    80002d6a:	00026497          	auipc	s1,0x26
    80002d6e:	2d64a483          	lw	s1,726(s1) # 80029040 <ticks>
  release(&tickslock);
    80002d72:	00013517          	auipc	a0,0x13
    80002d76:	d4e50513          	addi	a0,a0,-690 # 80015ac0 <tickslock>
    80002d7a:	ffffe097          	auipc	ra,0xffffe
    80002d7e:	df6080e7          	jalr	-522(ra) # 80000b70 <release>
  return xticks;
}
    80002d82:	02049513          	slli	a0,s1,0x20
    80002d86:	9101                	srli	a0,a0,0x20
    80002d88:	60e2                	ld	ra,24(sp)
    80002d8a:	6442                	ld	s0,16(sp)
    80002d8c:	64a2                	ld	s1,8(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret

0000000080002d92 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d92:	7179                	addi	sp,sp,-48
    80002d94:	f406                	sd	ra,40(sp)
    80002d96:	f022                	sd	s0,32(sp)
    80002d98:	ec26                	sd	s1,24(sp)
    80002d9a:	e84a                	sd	s2,16(sp)
    80002d9c:	e44e                	sd	s3,8(sp)
    80002d9e:	e052                	sd	s4,0(sp)
    80002da0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002da2:	00005597          	auipc	a1,0x5
    80002da6:	51658593          	addi	a1,a1,1302 # 800082b8 <userret+0x228>
    80002daa:	00013517          	auipc	a0,0x13
    80002dae:	d3650513          	addi	a0,a0,-714 # 80015ae0 <bcache>
    80002db2:	ffffe097          	auipc	ra,0xffffe
    80002db6:	c1a080e7          	jalr	-998(ra) # 800009cc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002dba:	0001b797          	auipc	a5,0x1b
    80002dbe:	d2678793          	addi	a5,a5,-730 # 8001dae0 <bcache+0x8000>
    80002dc2:	0001b717          	auipc	a4,0x1b
    80002dc6:	07e70713          	addi	a4,a4,126 # 8001de40 <bcache+0x8360>
    80002dca:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    80002dce:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dd2:	00013497          	auipc	s1,0x13
    80002dd6:	d2e48493          	addi	s1,s1,-722 # 80015b00 <bcache+0x20>
    b->next = bcache.head.next;
    80002dda:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ddc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002dde:	00006a17          	auipc	s4,0x6
    80002de2:	842a0a13          	addi	s4,s4,-1982 # 80008620 <userret+0x590>
    b->next = bcache.head.next;
    80002de6:	3b893783          	ld	a5,952(s2)
    80002dea:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    80002dec:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    80002df0:	85d2                	mv	a1,s4
    80002df2:	01048513          	addi	a0,s1,16
    80002df6:	00001097          	auipc	ra,0x1
    80002dfa:	748080e7          	jalr	1864(ra) # 8000453e <initsleeplock>
    bcache.head.next->prev = b;
    80002dfe:	3b893783          	ld	a5,952(s2)
    80002e02:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    80002e04:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e08:	46048493          	addi	s1,s1,1120
    80002e0c:	fd349de3          	bne	s1,s3,80002de6 <binit+0x54>
  }
}
    80002e10:	70a2                	ld	ra,40(sp)
    80002e12:	7402                	ld	s0,32(sp)
    80002e14:	64e2                	ld	s1,24(sp)
    80002e16:	6942                	ld	s2,16(sp)
    80002e18:	69a2                	ld	s3,8(sp)
    80002e1a:	6a02                	ld	s4,0(sp)
    80002e1c:	6145                	addi	sp,sp,48
    80002e1e:	8082                	ret

0000000080002e20 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e20:	7179                	addi	sp,sp,-48
    80002e22:	f406                	sd	ra,40(sp)
    80002e24:	f022                	sd	s0,32(sp)
    80002e26:	ec26                	sd	s1,24(sp)
    80002e28:	e84a                	sd	s2,16(sp)
    80002e2a:	e44e                	sd	s3,8(sp)
    80002e2c:	1800                	addi	s0,sp,48
    80002e2e:	892a                	mv	s2,a0
    80002e30:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e32:	00013517          	auipc	a0,0x13
    80002e36:	cae50513          	addi	a0,a0,-850 # 80015ae0 <bcache>
    80002e3a:	ffffe097          	auipc	ra,0xffffe
    80002e3e:	c66080e7          	jalr	-922(ra) # 80000aa0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e42:	0001b497          	auipc	s1,0x1b
    80002e46:	0564b483          	ld	s1,86(s1) # 8001de98 <bcache+0x83b8>
    80002e4a:	0001b797          	auipc	a5,0x1b
    80002e4e:	ff678793          	addi	a5,a5,-10 # 8001de40 <bcache+0x8360>
    80002e52:	02f48f63          	beq	s1,a5,80002e90 <bread+0x70>
    80002e56:	873e                	mv	a4,a5
    80002e58:	a021                	j	80002e60 <bread+0x40>
    80002e5a:	6ca4                	ld	s1,88(s1)
    80002e5c:	02e48a63          	beq	s1,a4,80002e90 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e60:	449c                	lw	a5,8(s1)
    80002e62:	ff279ce3          	bne	a5,s2,80002e5a <bread+0x3a>
    80002e66:	44dc                	lw	a5,12(s1)
    80002e68:	ff3799e3          	bne	a5,s3,80002e5a <bread+0x3a>
      b->refcnt++;
    80002e6c:	44bc                	lw	a5,72(s1)
    80002e6e:	2785                	addiw	a5,a5,1
    80002e70:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002e72:	00013517          	auipc	a0,0x13
    80002e76:	c6e50513          	addi	a0,a0,-914 # 80015ae0 <bcache>
    80002e7a:	ffffe097          	auipc	ra,0xffffe
    80002e7e:	cf6080e7          	jalr	-778(ra) # 80000b70 <release>
      acquiresleep(&b->lock);
    80002e82:	01048513          	addi	a0,s1,16
    80002e86:	00001097          	auipc	ra,0x1
    80002e8a:	6f2080e7          	jalr	1778(ra) # 80004578 <acquiresleep>
      return b;
    80002e8e:	a8b9                	j	80002eec <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e90:	0001b497          	auipc	s1,0x1b
    80002e94:	0004b483          	ld	s1,0(s1) # 8001de90 <bcache+0x83b0>
    80002e98:	0001b797          	auipc	a5,0x1b
    80002e9c:	fa878793          	addi	a5,a5,-88 # 8001de40 <bcache+0x8360>
    80002ea0:	00f48863          	beq	s1,a5,80002eb0 <bread+0x90>
    80002ea4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ea6:	44bc                	lw	a5,72(s1)
    80002ea8:	cf81                	beqz	a5,80002ec0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002eaa:	68a4                	ld	s1,80(s1)
    80002eac:	fee49de3          	bne	s1,a4,80002ea6 <bread+0x86>
  panic("bget: no buffers");
    80002eb0:	00005517          	auipc	a0,0x5
    80002eb4:	77850513          	addi	a0,a0,1912 # 80008628 <userret+0x598>
    80002eb8:	ffffd097          	auipc	ra,0xffffd
    80002ebc:	69c080e7          	jalr	1692(ra) # 80000554 <panic>
      b->dev = dev;
    80002ec0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ec4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ec8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ecc:	4785                	li	a5,1
    80002ece:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002ed0:	00013517          	auipc	a0,0x13
    80002ed4:	c1050513          	addi	a0,a0,-1008 # 80015ae0 <bcache>
    80002ed8:	ffffe097          	auipc	ra,0xffffe
    80002edc:	c98080e7          	jalr	-872(ra) # 80000b70 <release>
      acquiresleep(&b->lock);
    80002ee0:	01048513          	addi	a0,s1,16
    80002ee4:	00001097          	auipc	ra,0x1
    80002ee8:	694080e7          	jalr	1684(ra) # 80004578 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002eec:	409c                	lw	a5,0(s1)
    80002eee:	cb89                	beqz	a5,80002f00 <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ef0:	8526                	mv	a0,s1
    80002ef2:	70a2                	ld	ra,40(sp)
    80002ef4:	7402                	ld	s0,32(sp)
    80002ef6:	64e2                	ld	s1,24(sp)
    80002ef8:	6942                	ld	s2,16(sp)
    80002efa:	69a2                	ld	s3,8(sp)
    80002efc:	6145                	addi	sp,sp,48
    80002efe:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    80002f00:	4601                	li	a2,0
    80002f02:	85a6                	mv	a1,s1
    80002f04:	4488                	lw	a0,8(s1)
    80002f06:	00003097          	auipc	ra,0x3
    80002f0a:	4a4080e7          	jalr	1188(ra) # 800063aa <virtio_disk_rw>
    b->valid = 1;
    80002f0e:	4785                	li	a5,1
    80002f10:	c09c                	sw	a5,0(s1)
  return b;
    80002f12:	bff9                	j	80002ef0 <bread+0xd0>

0000000080002f14 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f14:	1101                	addi	sp,sp,-32
    80002f16:	ec06                	sd	ra,24(sp)
    80002f18:	e822                	sd	s0,16(sp)
    80002f1a:	e426                	sd	s1,8(sp)
    80002f1c:	1000                	addi	s0,sp,32
    80002f1e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f20:	0541                	addi	a0,a0,16
    80002f22:	00001097          	auipc	ra,0x1
    80002f26:	6f0080e7          	jalr	1776(ra) # 80004612 <holdingsleep>
    80002f2a:	cd09                	beqz	a0,80002f44 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80002f2c:	4605                	li	a2,1
    80002f2e:	85a6                	mv	a1,s1
    80002f30:	4488                	lw	a0,8(s1)
    80002f32:	00003097          	auipc	ra,0x3
    80002f36:	478080e7          	jalr	1144(ra) # 800063aa <virtio_disk_rw>
}
    80002f3a:	60e2                	ld	ra,24(sp)
    80002f3c:	6442                	ld	s0,16(sp)
    80002f3e:	64a2                	ld	s1,8(sp)
    80002f40:	6105                	addi	sp,sp,32
    80002f42:	8082                	ret
    panic("bwrite");
    80002f44:	00005517          	auipc	a0,0x5
    80002f48:	6fc50513          	addi	a0,a0,1788 # 80008640 <userret+0x5b0>
    80002f4c:	ffffd097          	auipc	ra,0xffffd
    80002f50:	608080e7          	jalr	1544(ra) # 80000554 <panic>

0000000080002f54 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80002f54:	1101                	addi	sp,sp,-32
    80002f56:	ec06                	sd	ra,24(sp)
    80002f58:	e822                	sd	s0,16(sp)
    80002f5a:	e426                	sd	s1,8(sp)
    80002f5c:	e04a                	sd	s2,0(sp)
    80002f5e:	1000                	addi	s0,sp,32
    80002f60:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f62:	01050913          	addi	s2,a0,16
    80002f66:	854a                	mv	a0,s2
    80002f68:	00001097          	auipc	ra,0x1
    80002f6c:	6aa080e7          	jalr	1706(ra) # 80004612 <holdingsleep>
    80002f70:	c92d                	beqz	a0,80002fe2 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002f72:	854a                	mv	a0,s2
    80002f74:	00001097          	auipc	ra,0x1
    80002f78:	65a080e7          	jalr	1626(ra) # 800045ce <releasesleep>

  acquire(&bcache.lock);
    80002f7c:	00013517          	auipc	a0,0x13
    80002f80:	b6450513          	addi	a0,a0,-1180 # 80015ae0 <bcache>
    80002f84:	ffffe097          	auipc	ra,0xffffe
    80002f88:	b1c080e7          	jalr	-1252(ra) # 80000aa0 <acquire>
  b->refcnt--;
    80002f8c:	44bc                	lw	a5,72(s1)
    80002f8e:	37fd                	addiw	a5,a5,-1
    80002f90:	0007871b          	sext.w	a4,a5
    80002f94:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    80002f96:	eb05                	bnez	a4,80002fc6 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f98:	6cbc                	ld	a5,88(s1)
    80002f9a:	68b8                	ld	a4,80(s1)
    80002f9c:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    80002f9e:	68bc                	ld	a5,80(s1)
    80002fa0:	6cb8                	ld	a4,88(s1)
    80002fa2:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    80002fa4:	0001b797          	auipc	a5,0x1b
    80002fa8:	b3c78793          	addi	a5,a5,-1220 # 8001dae0 <bcache+0x8000>
    80002fac:	3b87b703          	ld	a4,952(a5)
    80002fb0:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    80002fb2:	0001b717          	auipc	a4,0x1b
    80002fb6:	e8e70713          	addi	a4,a4,-370 # 8001de40 <bcache+0x8360>
    80002fba:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    80002fbc:	3b87b703          	ld	a4,952(a5)
    80002fc0:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    80002fc2:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    80002fc6:	00013517          	auipc	a0,0x13
    80002fca:	b1a50513          	addi	a0,a0,-1254 # 80015ae0 <bcache>
    80002fce:	ffffe097          	auipc	ra,0xffffe
    80002fd2:	ba2080e7          	jalr	-1118(ra) # 80000b70 <release>
}
    80002fd6:	60e2                	ld	ra,24(sp)
    80002fd8:	6442                	ld	s0,16(sp)
    80002fda:	64a2                	ld	s1,8(sp)
    80002fdc:	6902                	ld	s2,0(sp)
    80002fde:	6105                	addi	sp,sp,32
    80002fe0:	8082                	ret
    panic("brelse");
    80002fe2:	00005517          	auipc	a0,0x5
    80002fe6:	66650513          	addi	a0,a0,1638 # 80008648 <userret+0x5b8>
    80002fea:	ffffd097          	auipc	ra,0xffffd
    80002fee:	56a080e7          	jalr	1386(ra) # 80000554 <panic>

0000000080002ff2 <bpin>:

void
bpin(struct buf *b) {
    80002ff2:	1101                	addi	sp,sp,-32
    80002ff4:	ec06                	sd	ra,24(sp)
    80002ff6:	e822                	sd	s0,16(sp)
    80002ff8:	e426                	sd	s1,8(sp)
    80002ffa:	1000                	addi	s0,sp,32
    80002ffc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ffe:	00013517          	auipc	a0,0x13
    80003002:	ae250513          	addi	a0,a0,-1310 # 80015ae0 <bcache>
    80003006:	ffffe097          	auipc	ra,0xffffe
    8000300a:	a9a080e7          	jalr	-1382(ra) # 80000aa0 <acquire>
  b->refcnt++;
    8000300e:	44bc                	lw	a5,72(s1)
    80003010:	2785                	addiw	a5,a5,1
    80003012:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003014:	00013517          	auipc	a0,0x13
    80003018:	acc50513          	addi	a0,a0,-1332 # 80015ae0 <bcache>
    8000301c:	ffffe097          	auipc	ra,0xffffe
    80003020:	b54080e7          	jalr	-1196(ra) # 80000b70 <release>
}
    80003024:	60e2                	ld	ra,24(sp)
    80003026:	6442                	ld	s0,16(sp)
    80003028:	64a2                	ld	s1,8(sp)
    8000302a:	6105                	addi	sp,sp,32
    8000302c:	8082                	ret

000000008000302e <bunpin>:

void
bunpin(struct buf *b) {
    8000302e:	1101                	addi	sp,sp,-32
    80003030:	ec06                	sd	ra,24(sp)
    80003032:	e822                	sd	s0,16(sp)
    80003034:	e426                	sd	s1,8(sp)
    80003036:	1000                	addi	s0,sp,32
    80003038:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000303a:	00013517          	auipc	a0,0x13
    8000303e:	aa650513          	addi	a0,a0,-1370 # 80015ae0 <bcache>
    80003042:	ffffe097          	auipc	ra,0xffffe
    80003046:	a5e080e7          	jalr	-1442(ra) # 80000aa0 <acquire>
  b->refcnt--;
    8000304a:	44bc                	lw	a5,72(s1)
    8000304c:	37fd                	addiw	a5,a5,-1
    8000304e:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003050:	00013517          	auipc	a0,0x13
    80003054:	a9050513          	addi	a0,a0,-1392 # 80015ae0 <bcache>
    80003058:	ffffe097          	auipc	ra,0xffffe
    8000305c:	b18080e7          	jalr	-1256(ra) # 80000b70 <release>
}
    80003060:	60e2                	ld	ra,24(sp)
    80003062:	6442                	ld	s0,16(sp)
    80003064:	64a2                	ld	s1,8(sp)
    80003066:	6105                	addi	sp,sp,32
    80003068:	8082                	ret

000000008000306a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000306a:	1101                	addi	sp,sp,-32
    8000306c:	ec06                	sd	ra,24(sp)
    8000306e:	e822                	sd	s0,16(sp)
    80003070:	e426                	sd	s1,8(sp)
    80003072:	e04a                	sd	s2,0(sp)
    80003074:	1000                	addi	s0,sp,32
    80003076:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003078:	00d5d59b          	srliw	a1,a1,0xd
    8000307c:	0001b797          	auipc	a5,0x1b
    80003080:	2407a783          	lw	a5,576(a5) # 8001e2bc <sb+0x1c>
    80003084:	9dbd                	addw	a1,a1,a5
    80003086:	00000097          	auipc	ra,0x0
    8000308a:	d9a080e7          	jalr	-614(ra) # 80002e20 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000308e:	0074f713          	andi	a4,s1,7
    80003092:	4785                	li	a5,1
    80003094:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003098:	14ce                	slli	s1,s1,0x33
    8000309a:	90d9                	srli	s1,s1,0x36
    8000309c:	00950733          	add	a4,a0,s1
    800030a0:	06074703          	lbu	a4,96(a4)
    800030a4:	00e7f6b3          	and	a3,a5,a4
    800030a8:	c69d                	beqz	a3,800030d6 <bfree+0x6c>
    800030aa:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030ac:	94aa                	add	s1,s1,a0
    800030ae:	fff7c793          	not	a5,a5
    800030b2:	8ff9                	and	a5,a5,a4
    800030b4:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    800030b8:	00001097          	auipc	ra,0x1
    800030bc:	346080e7          	jalr	838(ra) # 800043fe <log_write>
  brelse(bp);
    800030c0:	854a                	mv	a0,s2
    800030c2:	00000097          	auipc	ra,0x0
    800030c6:	e92080e7          	jalr	-366(ra) # 80002f54 <brelse>
}
    800030ca:	60e2                	ld	ra,24(sp)
    800030cc:	6442                	ld	s0,16(sp)
    800030ce:	64a2                	ld	s1,8(sp)
    800030d0:	6902                	ld	s2,0(sp)
    800030d2:	6105                	addi	sp,sp,32
    800030d4:	8082                	ret
    panic("freeing free block");
    800030d6:	00005517          	auipc	a0,0x5
    800030da:	57a50513          	addi	a0,a0,1402 # 80008650 <userret+0x5c0>
    800030de:	ffffd097          	auipc	ra,0xffffd
    800030e2:	476080e7          	jalr	1142(ra) # 80000554 <panic>

00000000800030e6 <balloc>:
{
    800030e6:	711d                	addi	sp,sp,-96
    800030e8:	ec86                	sd	ra,88(sp)
    800030ea:	e8a2                	sd	s0,80(sp)
    800030ec:	e4a6                	sd	s1,72(sp)
    800030ee:	e0ca                	sd	s2,64(sp)
    800030f0:	fc4e                	sd	s3,56(sp)
    800030f2:	f852                	sd	s4,48(sp)
    800030f4:	f456                	sd	s5,40(sp)
    800030f6:	f05a                	sd	s6,32(sp)
    800030f8:	ec5e                	sd	s7,24(sp)
    800030fa:	e862                	sd	s8,16(sp)
    800030fc:	e466                	sd	s9,8(sp)
    800030fe:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003100:	0001b797          	auipc	a5,0x1b
    80003104:	1a47a783          	lw	a5,420(a5) # 8001e2a4 <sb+0x4>
    80003108:	cbd1                	beqz	a5,8000319c <balloc+0xb6>
    8000310a:	8baa                	mv	s7,a0
    8000310c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000310e:	0001bb17          	auipc	s6,0x1b
    80003112:	192b0b13          	addi	s6,s6,402 # 8001e2a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003116:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003118:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000311a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000311c:	6c89                	lui	s9,0x2
    8000311e:	a831                	j	8000313a <balloc+0x54>
    brelse(bp);
    80003120:	854a                	mv	a0,s2
    80003122:	00000097          	auipc	ra,0x0
    80003126:	e32080e7          	jalr	-462(ra) # 80002f54 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000312a:	015c87bb          	addw	a5,s9,s5
    8000312e:	00078a9b          	sext.w	s5,a5
    80003132:	004b2703          	lw	a4,4(s6)
    80003136:	06eaf363          	bgeu	s5,a4,8000319c <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000313a:	41fad79b          	sraiw	a5,s5,0x1f
    8000313e:	0137d79b          	srliw	a5,a5,0x13
    80003142:	015787bb          	addw	a5,a5,s5
    80003146:	40d7d79b          	sraiw	a5,a5,0xd
    8000314a:	01cb2583          	lw	a1,28(s6)
    8000314e:	9dbd                	addw	a1,a1,a5
    80003150:	855e                	mv	a0,s7
    80003152:	00000097          	auipc	ra,0x0
    80003156:	cce080e7          	jalr	-818(ra) # 80002e20 <bread>
    8000315a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000315c:	004b2503          	lw	a0,4(s6)
    80003160:	000a849b          	sext.w	s1,s5
    80003164:	8662                	mv	a2,s8
    80003166:	faa4fde3          	bgeu	s1,a0,80003120 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000316a:	41f6579b          	sraiw	a5,a2,0x1f
    8000316e:	01d7d69b          	srliw	a3,a5,0x1d
    80003172:	00c6873b          	addw	a4,a3,a2
    80003176:	00777793          	andi	a5,a4,7
    8000317a:	9f95                	subw	a5,a5,a3
    8000317c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003180:	4037571b          	sraiw	a4,a4,0x3
    80003184:	00e906b3          	add	a3,s2,a4
    80003188:	0606c683          	lbu	a3,96(a3)
    8000318c:	00d7f5b3          	and	a1,a5,a3
    80003190:	cd91                	beqz	a1,800031ac <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003192:	2605                	addiw	a2,a2,1
    80003194:	2485                	addiw	s1,s1,1
    80003196:	fd4618e3          	bne	a2,s4,80003166 <balloc+0x80>
    8000319a:	b759                	j	80003120 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000319c:	00005517          	auipc	a0,0x5
    800031a0:	4cc50513          	addi	a0,a0,1228 # 80008668 <userret+0x5d8>
    800031a4:	ffffd097          	auipc	ra,0xffffd
    800031a8:	3b0080e7          	jalr	944(ra) # 80000554 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031ac:	974a                	add	a4,a4,s2
    800031ae:	8fd5                	or	a5,a5,a3
    800031b0:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    800031b4:	854a                	mv	a0,s2
    800031b6:	00001097          	auipc	ra,0x1
    800031ba:	248080e7          	jalr	584(ra) # 800043fe <log_write>
        brelse(bp);
    800031be:	854a                	mv	a0,s2
    800031c0:	00000097          	auipc	ra,0x0
    800031c4:	d94080e7          	jalr	-620(ra) # 80002f54 <brelse>
  bp = bread(dev, bno);
    800031c8:	85a6                	mv	a1,s1
    800031ca:	855e                	mv	a0,s7
    800031cc:	00000097          	auipc	ra,0x0
    800031d0:	c54080e7          	jalr	-940(ra) # 80002e20 <bread>
    800031d4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031d6:	40000613          	li	a2,1024
    800031da:	4581                	li	a1,0
    800031dc:	06050513          	addi	a0,a0,96
    800031e0:	ffffe097          	auipc	ra,0xffffe
    800031e4:	b8e080e7          	jalr	-1138(ra) # 80000d6e <memset>
  log_write(bp);
    800031e8:	854a                	mv	a0,s2
    800031ea:	00001097          	auipc	ra,0x1
    800031ee:	214080e7          	jalr	532(ra) # 800043fe <log_write>
  brelse(bp);
    800031f2:	854a                	mv	a0,s2
    800031f4:	00000097          	auipc	ra,0x0
    800031f8:	d60080e7          	jalr	-672(ra) # 80002f54 <brelse>
}
    800031fc:	8526                	mv	a0,s1
    800031fe:	60e6                	ld	ra,88(sp)
    80003200:	6446                	ld	s0,80(sp)
    80003202:	64a6                	ld	s1,72(sp)
    80003204:	6906                	ld	s2,64(sp)
    80003206:	79e2                	ld	s3,56(sp)
    80003208:	7a42                	ld	s4,48(sp)
    8000320a:	7aa2                	ld	s5,40(sp)
    8000320c:	7b02                	ld	s6,32(sp)
    8000320e:	6be2                	ld	s7,24(sp)
    80003210:	6c42                	ld	s8,16(sp)
    80003212:	6ca2                	ld	s9,8(sp)
    80003214:	6125                	addi	sp,sp,96
    80003216:	8082                	ret

0000000080003218 <bmap>:
  return 0;
}

static uint
bmap(struct inode *ip, uint bn)
{
    80003218:	7139                	addi	sp,sp,-64
    8000321a:	fc06                	sd	ra,56(sp)
    8000321c:	f822                	sd	s0,48(sp)
    8000321e:	f426                	sd	s1,40(sp)
    80003220:	f04a                	sd	s2,32(sp)
    80003222:	ec4e                	sd	s3,24(sp)
    80003224:	e852                	sd	s4,16(sp)
    80003226:	e456                	sd	s5,8(sp)
    80003228:	0080                	addi	s0,sp,64
    8000322a:	892a                	mv	s2,a0
  uint addr, *a, *a2;
  struct buf *bp, *bp2;
  /** bn是相对file（inode）的虚拟编号  */
  /** 直接返回块ip->addrs[bn]  */
  if(bn < NDIRECT){
    8000322c:	47a9                	li	a5,10
    8000322e:	06b7f263          	bgeu	a5,a1,80003292 <bmap+0x7a>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  /** 否则减去NDIRENT  */
  bn -= NDIRECT;
    80003232:	ff55849b          	addiw	s1,a1,-11
    80003236:	0004871b          	sext.w	a4,s1
  //11 + 256 + 256 * 256
  if(bn < NINDIRECT){
    8000323a:	67c1                	lui	a5,0x10
    8000323c:	0ff78793          	addi	a5,a5,255 # 100ff <_entry-0x7ffeff01>
    80003240:	16e7e363          	bltu	a5,a4,800033a6 <bmap+0x18e>
    if(bn < SINGLEDIRECT){
    80003244:	0ff00793          	li	a5,255
    80003248:	0ae7e263          	bltu	a5,a4,800032ec <bmap+0xd4>
      // Load indirect block, allocating if necessary.
      if((addr = ip->addrs[NDIRECT]) == 0)
    8000324c:	10452583          	lw	a1,260(a0)
    80003250:	c5a5                	beqz	a1,800032b8 <bmap+0xa0>
        ip->addrs[NDIRECT] = addr = balloc(ip->dev);
      /** Return a locked buf with the contents of the indicated block.  */
      bp = bread(ip->dev, addr);
    80003252:	00092503          	lw	a0,0(s2)
    80003256:	00000097          	auipc	ra,0x0
    8000325a:	bca080e7          	jalr	-1078(ra) # 80002e20 <bread>
    8000325e:	8a2a                	mv	s4,a0
      a = (uint*)bp->data; 
    80003260:	06050793          	addi	a5,a0,96
      if((addr = a[bn]) == 0){
    80003264:	1482                	slli	s1,s1,0x20
    80003266:	9081                	srli	s1,s1,0x20
    80003268:	048a                	slli	s1,s1,0x2
    8000326a:	94be                	add	s1,s1,a5
    8000326c:	0004a983          	lw	s3,0(s1)
    80003270:	04098e63          	beqz	s3,800032cc <bmap+0xb4>
        a[bn] = addr = balloc(ip->dev);
        log_write(bp);
      }
      brelse(bp);
    80003274:	8552                	mv	a0,s4
    80003276:	00000097          	auipc	ra,0x0
    8000327a:	cde080e7          	jalr	-802(ra) # 80002f54 <brelse>
    }
    return addr;
  }

  panic("bmap: out of range");
}
    8000327e:	854e                	mv	a0,s3
    80003280:	70e2                	ld	ra,56(sp)
    80003282:	7442                	ld	s0,48(sp)
    80003284:	74a2                	ld	s1,40(sp)
    80003286:	7902                	ld	s2,32(sp)
    80003288:	69e2                	ld	s3,24(sp)
    8000328a:	6a42                	ld	s4,16(sp)
    8000328c:	6aa2                	ld	s5,8(sp)
    8000328e:	6121                	addi	sp,sp,64
    80003290:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003292:	02059493          	slli	s1,a1,0x20
    80003296:	9081                	srli	s1,s1,0x20
    80003298:	048a                	slli	s1,s1,0x2
    8000329a:	94aa                	add	s1,s1,a0
    8000329c:	0d84a983          	lw	s3,216(s1)
    800032a0:	fc099fe3          	bnez	s3,8000327e <bmap+0x66>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800032a4:	4108                	lw	a0,0(a0)
    800032a6:	00000097          	auipc	ra,0x0
    800032aa:	e40080e7          	jalr	-448(ra) # 800030e6 <balloc>
    800032ae:	0005099b          	sext.w	s3,a0
    800032b2:	0d34ac23          	sw	s3,216(s1)
    800032b6:	b7e1                	j	8000327e <bmap+0x66>
        ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800032b8:	4108                	lw	a0,0(a0)
    800032ba:	00000097          	auipc	ra,0x0
    800032be:	e2c080e7          	jalr	-468(ra) # 800030e6 <balloc>
    800032c2:	0005059b          	sext.w	a1,a0
    800032c6:	10b92223          	sw	a1,260(s2)
    800032ca:	b761                	j	80003252 <bmap+0x3a>
        a[bn] = addr = balloc(ip->dev);
    800032cc:	00092503          	lw	a0,0(s2)
    800032d0:	00000097          	auipc	ra,0x0
    800032d4:	e16080e7          	jalr	-490(ra) # 800030e6 <balloc>
    800032d8:	0005099b          	sext.w	s3,a0
    800032dc:	0134a023          	sw	s3,0(s1)
        log_write(bp);
    800032e0:	8552                	mv	a0,s4
    800032e2:	00001097          	auipc	ra,0x1
    800032e6:	11c080e7          	jalr	284(ra) # 800043fe <log_write>
    800032ea:	b769                	j	80003274 <bmap+0x5c>
      bn -= SINGLEDIRECT;
    800032ec:	ef55859b          	addiw	a1,a1,-267
      int single_indirect_index = bn / SINGLEDIRECT;
    800032f0:	0085da9b          	srliw	s5,a1,0x8
      int relative_offset_bn = bn % SINGLEDIRECT;
    800032f4:	0ff5f493          	andi	s1,a1,255
      if((addr = ip->addrs[pos]) == 0)
    800032f8:	10852583          	lw	a1,264(a0)
    800032fc:	c9b9                	beqz	a1,80003352 <bmap+0x13a>
      bp = bread(ip->dev, addr);
    800032fe:	00092503          	lw	a0,0(s2)
    80003302:	00000097          	auipc	ra,0x0
    80003306:	b1e080e7          	jalr	-1250(ra) # 80002e20 <bread>
    8000330a:	89aa                	mv	s3,a0
      a = (uint*)bp->data;
    8000330c:	06050a13          	addi	s4,a0,96
      if((addr = a[single_indirect_index]) == 0){
    80003310:	0a8a                	slli	s5,s5,0x2
    80003312:	9a56                	add	s4,s4,s5
    80003314:	000a2a83          	lw	s5,0(s4) # 2000 <_entry-0x7fffe000>
    80003318:	040a8763          	beqz	s5,80003366 <bmap+0x14e>
      brelse(bp);
    8000331c:	854e                	mv	a0,s3
    8000331e:	00000097          	auipc	ra,0x0
    80003322:	c36080e7          	jalr	-970(ra) # 80002f54 <brelse>
      bp2 = bread(ip->dev, addr);
    80003326:	85d6                	mv	a1,s5
    80003328:	00092503          	lw	a0,0(s2)
    8000332c:	00000097          	auipc	ra,0x0
    80003330:	af4080e7          	jalr	-1292(ra) # 80002e20 <bread>
    80003334:	8a2a                	mv	s4,a0
      a2 = (uint*)bp2->data; 
    80003336:	06050793          	addi	a5,a0,96
      if((addr = a2[relative_offset_bn]) == 0){
    8000333a:	048a                	slli	s1,s1,0x2
    8000333c:	94be                	add	s1,s1,a5
    8000333e:	0004a983          	lw	s3,0(s1)
    80003342:	04098263          	beqz	s3,80003386 <bmap+0x16e>
      brelse(bp2);
    80003346:	8552                	mv	a0,s4
    80003348:	00000097          	auipc	ra,0x0
    8000334c:	c0c080e7          	jalr	-1012(ra) # 80002f54 <brelse>
    80003350:	b73d                	j	8000327e <bmap+0x66>
        ip->addrs[pos] = addr = balloc(ip->dev);
    80003352:	4108                	lw	a0,0(a0)
    80003354:	00000097          	auipc	ra,0x0
    80003358:	d92080e7          	jalr	-622(ra) # 800030e6 <balloc>
    8000335c:	0005059b          	sext.w	a1,a0
    80003360:	10b92423          	sw	a1,264(s2)
    80003364:	bf69                	j	800032fe <bmap+0xe6>
        a[single_indirect_index] = addr = balloc(ip->dev);
    80003366:	00092503          	lw	a0,0(s2)
    8000336a:	00000097          	auipc	ra,0x0
    8000336e:	d7c080e7          	jalr	-644(ra) # 800030e6 <balloc>
    80003372:	00050a9b          	sext.w	s5,a0
    80003376:	015a2023          	sw	s5,0(s4)
        log_write(bp);
    8000337a:	854e                	mv	a0,s3
    8000337c:	00001097          	auipc	ra,0x1
    80003380:	082080e7          	jalr	130(ra) # 800043fe <log_write>
    80003384:	bf61                	j	8000331c <bmap+0x104>
        a2[relative_offset_bn] = addr = balloc(ip->dev);
    80003386:	00092503          	lw	a0,0(s2)
    8000338a:	00000097          	auipc	ra,0x0
    8000338e:	d5c080e7          	jalr	-676(ra) # 800030e6 <balloc>
    80003392:	0005099b          	sext.w	s3,a0
    80003396:	0134a023          	sw	s3,0(s1)
        log_write(bp2);
    8000339a:	8552                	mv	a0,s4
    8000339c:	00001097          	auipc	ra,0x1
    800033a0:	062080e7          	jalr	98(ra) # 800043fe <log_write>
    800033a4:	b74d                	j	80003346 <bmap+0x12e>
  panic("bmap: out of range");
    800033a6:	00005517          	auipc	a0,0x5
    800033aa:	2da50513          	addi	a0,a0,730 # 80008680 <userret+0x5f0>
    800033ae:	ffffd097          	auipc	ra,0xffffd
    800033b2:	1a6080e7          	jalr	422(ra) # 80000554 <panic>

00000000800033b6 <iget>:
{
    800033b6:	7179                	addi	sp,sp,-48
    800033b8:	f406                	sd	ra,40(sp)
    800033ba:	f022                	sd	s0,32(sp)
    800033bc:	ec26                	sd	s1,24(sp)
    800033be:	e84a                	sd	s2,16(sp)
    800033c0:	e44e                	sd	s3,8(sp)
    800033c2:	e052                	sd	s4,0(sp)
    800033c4:	1800                	addi	s0,sp,48
    800033c6:	89aa                	mv	s3,a0
    800033c8:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800033ca:	0001b517          	auipc	a0,0x1b
    800033ce:	ef650513          	addi	a0,a0,-266 # 8001e2c0 <icache>
    800033d2:	ffffd097          	auipc	ra,0xffffd
    800033d6:	6ce080e7          	jalr	1742(ra) # 80000aa0 <acquire>
  empty = 0;
    800033da:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800033dc:	0001b497          	auipc	s1,0x1b
    800033e0:	f0448493          	addi	s1,s1,-252 # 8001e2e0 <icache+0x20>
    800033e4:	0001e697          	auipc	a3,0x1e
    800033e8:	41c68693          	addi	a3,a3,1052 # 80021800 <log>
    800033ec:	a039                	j	800033fa <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033ee:	02090b63          	beqz	s2,80003424 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800033f2:	11048493          	addi	s1,s1,272
    800033f6:	02d48a63          	beq	s1,a3,8000342a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033fa:	449c                	lw	a5,8(s1)
    800033fc:	fef059e3          	blez	a5,800033ee <iget+0x38>
    80003400:	4098                	lw	a4,0(s1)
    80003402:	ff3716e3          	bne	a4,s3,800033ee <iget+0x38>
    80003406:	40d8                	lw	a4,4(s1)
    80003408:	ff4713e3          	bne	a4,s4,800033ee <iget+0x38>
      ip->ref++;
    8000340c:	2785                	addiw	a5,a5,1
    8000340e:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003410:	0001b517          	auipc	a0,0x1b
    80003414:	eb050513          	addi	a0,a0,-336 # 8001e2c0 <icache>
    80003418:	ffffd097          	auipc	ra,0xffffd
    8000341c:	758080e7          	jalr	1880(ra) # 80000b70 <release>
      return ip;
    80003420:	8926                	mv	s2,s1
    80003422:	a03d                	j	80003450 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003424:	f7f9                	bnez	a5,800033f2 <iget+0x3c>
    80003426:	8926                	mv	s2,s1
    80003428:	b7e9                	j	800033f2 <iget+0x3c>
  if(empty == 0)
    8000342a:	02090c63          	beqz	s2,80003462 <iget+0xac>
  ip->dev = dev;
    8000342e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003432:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003436:	4785                	li	a5,1
    80003438:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000343c:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    80003440:	0001b517          	auipc	a0,0x1b
    80003444:	e8050513          	addi	a0,a0,-384 # 8001e2c0 <icache>
    80003448:	ffffd097          	auipc	ra,0xffffd
    8000344c:	728080e7          	jalr	1832(ra) # 80000b70 <release>
}
    80003450:	854a                	mv	a0,s2
    80003452:	70a2                	ld	ra,40(sp)
    80003454:	7402                	ld	s0,32(sp)
    80003456:	64e2                	ld	s1,24(sp)
    80003458:	6942                	ld	s2,16(sp)
    8000345a:	69a2                	ld	s3,8(sp)
    8000345c:	6a02                	ld	s4,0(sp)
    8000345e:	6145                	addi	sp,sp,48
    80003460:	8082                	ret
    panic("iget: no inodes");
    80003462:	00005517          	auipc	a0,0x5
    80003466:	23650513          	addi	a0,a0,566 # 80008698 <userret+0x608>
    8000346a:	ffffd097          	auipc	ra,0xffffd
    8000346e:	0ea080e7          	jalr	234(ra) # 80000554 <panic>

0000000080003472 <fsinit>:
fsinit(int dev) {
    80003472:	7179                	addi	sp,sp,-48
    80003474:	f406                	sd	ra,40(sp)
    80003476:	f022                	sd	s0,32(sp)
    80003478:	ec26                	sd	s1,24(sp)
    8000347a:	e84a                	sd	s2,16(sp)
    8000347c:	e44e                	sd	s3,8(sp)
    8000347e:	1800                	addi	s0,sp,48
    80003480:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003482:	4585                	li	a1,1
    80003484:	00000097          	auipc	ra,0x0
    80003488:	99c080e7          	jalr	-1636(ra) # 80002e20 <bread>
    8000348c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000348e:	0001b997          	auipc	s3,0x1b
    80003492:	e1298993          	addi	s3,s3,-494 # 8001e2a0 <sb>
    80003496:	02000613          	li	a2,32
    8000349a:	06050593          	addi	a1,a0,96
    8000349e:	854e                	mv	a0,s3
    800034a0:	ffffe097          	auipc	ra,0xffffe
    800034a4:	92a080e7          	jalr	-1750(ra) # 80000dca <memmove>
  brelse(bp);
    800034a8:	8526                	mv	a0,s1
    800034aa:	00000097          	auipc	ra,0x0
    800034ae:	aaa080e7          	jalr	-1366(ra) # 80002f54 <brelse>
  if(sb.magic != FSMAGIC)
    800034b2:	0009a703          	lw	a4,0(s3)
    800034b6:	102037b7          	lui	a5,0x10203
    800034ba:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034be:	02f71263          	bne	a4,a5,800034e2 <fsinit+0x70>
  initlog(dev, &sb);
    800034c2:	0001b597          	auipc	a1,0x1b
    800034c6:	dde58593          	addi	a1,a1,-546 # 8001e2a0 <sb>
    800034ca:	854a                	mv	a0,s2
    800034cc:	00001097          	auipc	ra,0x1
    800034d0:	c1c080e7          	jalr	-996(ra) # 800040e8 <initlog>
}
    800034d4:	70a2                	ld	ra,40(sp)
    800034d6:	7402                	ld	s0,32(sp)
    800034d8:	64e2                	ld	s1,24(sp)
    800034da:	6942                	ld	s2,16(sp)
    800034dc:	69a2                	ld	s3,8(sp)
    800034de:	6145                	addi	sp,sp,48
    800034e0:	8082                	ret
    panic("invalid file system");
    800034e2:	00005517          	auipc	a0,0x5
    800034e6:	1c650513          	addi	a0,a0,454 # 800086a8 <userret+0x618>
    800034ea:	ffffd097          	auipc	ra,0xffffd
    800034ee:	06a080e7          	jalr	106(ra) # 80000554 <panic>

00000000800034f2 <iinit>:
{
    800034f2:	7179                	addi	sp,sp,-48
    800034f4:	f406                	sd	ra,40(sp)
    800034f6:	f022                	sd	s0,32(sp)
    800034f8:	ec26                	sd	s1,24(sp)
    800034fa:	e84a                	sd	s2,16(sp)
    800034fc:	e44e                	sd	s3,8(sp)
    800034fe:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003500:	00005597          	auipc	a1,0x5
    80003504:	1c058593          	addi	a1,a1,448 # 800086c0 <userret+0x630>
    80003508:	0001b517          	auipc	a0,0x1b
    8000350c:	db850513          	addi	a0,a0,-584 # 8001e2c0 <icache>
    80003510:	ffffd097          	auipc	ra,0xffffd
    80003514:	4bc080e7          	jalr	1212(ra) # 800009cc <initlock>
  for(i = 0; i < NINODE; i++) {
    80003518:	0001b497          	auipc	s1,0x1b
    8000351c:	dd848493          	addi	s1,s1,-552 # 8001e2f0 <icache+0x30>
    80003520:	0001e997          	auipc	s3,0x1e
    80003524:	2f098993          	addi	s3,s3,752 # 80021810 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003528:	00005917          	auipc	s2,0x5
    8000352c:	1a090913          	addi	s2,s2,416 # 800086c8 <userret+0x638>
    80003530:	85ca                	mv	a1,s2
    80003532:	8526                	mv	a0,s1
    80003534:	00001097          	auipc	ra,0x1
    80003538:	00a080e7          	jalr	10(ra) # 8000453e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000353c:	11048493          	addi	s1,s1,272
    80003540:	ff3498e3          	bne	s1,s3,80003530 <iinit+0x3e>
}
    80003544:	70a2                	ld	ra,40(sp)
    80003546:	7402                	ld	s0,32(sp)
    80003548:	64e2                	ld	s1,24(sp)
    8000354a:	6942                	ld	s2,16(sp)
    8000354c:	69a2                	ld	s3,8(sp)
    8000354e:	6145                	addi	sp,sp,48
    80003550:	8082                	ret

0000000080003552 <ialloc>:
{
    80003552:	715d                	addi	sp,sp,-80
    80003554:	e486                	sd	ra,72(sp)
    80003556:	e0a2                	sd	s0,64(sp)
    80003558:	fc26                	sd	s1,56(sp)
    8000355a:	f84a                	sd	s2,48(sp)
    8000355c:	f44e                	sd	s3,40(sp)
    8000355e:	f052                	sd	s4,32(sp)
    80003560:	ec56                	sd	s5,24(sp)
    80003562:	e85a                	sd	s6,16(sp)
    80003564:	e45e                	sd	s7,8(sp)
    80003566:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003568:	0001b717          	auipc	a4,0x1b
    8000356c:	d4472703          	lw	a4,-700(a4) # 8001e2ac <sb+0xc>
    80003570:	4785                	li	a5,1
    80003572:	04e7fa63          	bgeu	a5,a4,800035c6 <ialloc+0x74>
    80003576:	8aaa                	mv	s5,a0
    80003578:	8bae                	mv	s7,a1
    8000357a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000357c:	0001ba17          	auipc	s4,0x1b
    80003580:	d24a0a13          	addi	s4,s4,-732 # 8001e2a0 <sb>
    80003584:	00048b1b          	sext.w	s6,s1
    80003588:	0044d793          	srli	a5,s1,0x4
    8000358c:	018a2583          	lw	a1,24(s4)
    80003590:	9dbd                	addw	a1,a1,a5
    80003592:	8556                	mv	a0,s5
    80003594:	00000097          	auipc	ra,0x0
    80003598:	88c080e7          	jalr	-1908(ra) # 80002e20 <bread>
    8000359c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000359e:	06050993          	addi	s3,a0,96
    800035a2:	00f4f793          	andi	a5,s1,15
    800035a6:	079a                	slli	a5,a5,0x6
    800035a8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035aa:	00099783          	lh	a5,0(s3)
    800035ae:	c785                	beqz	a5,800035d6 <ialloc+0x84>
    brelse(bp);
    800035b0:	00000097          	auipc	ra,0x0
    800035b4:	9a4080e7          	jalr	-1628(ra) # 80002f54 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035b8:	0485                	addi	s1,s1,1
    800035ba:	00ca2703          	lw	a4,12(s4)
    800035be:	0004879b          	sext.w	a5,s1
    800035c2:	fce7e1e3          	bltu	a5,a4,80003584 <ialloc+0x32>
  panic("ialloc: no inodes");
    800035c6:	00005517          	auipc	a0,0x5
    800035ca:	10a50513          	addi	a0,a0,266 # 800086d0 <userret+0x640>
    800035ce:	ffffd097          	auipc	ra,0xffffd
    800035d2:	f86080e7          	jalr	-122(ra) # 80000554 <panic>
      memset(dip, 0, sizeof(*dip));
    800035d6:	04000613          	li	a2,64
    800035da:	4581                	li	a1,0
    800035dc:	854e                	mv	a0,s3
    800035de:	ffffd097          	auipc	ra,0xffffd
    800035e2:	790080e7          	jalr	1936(ra) # 80000d6e <memset>
      dip->type = type;
    800035e6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035ea:	854a                	mv	a0,s2
    800035ec:	00001097          	auipc	ra,0x1
    800035f0:	e12080e7          	jalr	-494(ra) # 800043fe <log_write>
      brelse(bp);
    800035f4:	854a                	mv	a0,s2
    800035f6:	00000097          	auipc	ra,0x0
    800035fa:	95e080e7          	jalr	-1698(ra) # 80002f54 <brelse>
      return iget(dev, inum);
    800035fe:	85da                	mv	a1,s6
    80003600:	8556                	mv	a0,s5
    80003602:	00000097          	auipc	ra,0x0
    80003606:	db4080e7          	jalr	-588(ra) # 800033b6 <iget>
}
    8000360a:	60a6                	ld	ra,72(sp)
    8000360c:	6406                	ld	s0,64(sp)
    8000360e:	74e2                	ld	s1,56(sp)
    80003610:	7942                	ld	s2,48(sp)
    80003612:	79a2                	ld	s3,40(sp)
    80003614:	7a02                	ld	s4,32(sp)
    80003616:	6ae2                	ld	s5,24(sp)
    80003618:	6b42                	ld	s6,16(sp)
    8000361a:	6ba2                	ld	s7,8(sp)
    8000361c:	6161                	addi	sp,sp,80
    8000361e:	8082                	ret

0000000080003620 <iupdate>:
{
    80003620:	1101                	addi	sp,sp,-32
    80003622:	ec06                	sd	ra,24(sp)
    80003624:	e822                	sd	s0,16(sp)
    80003626:	e426                	sd	s1,8(sp)
    80003628:	e04a                	sd	s2,0(sp)
    8000362a:	1000                	addi	s0,sp,32
    8000362c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000362e:	415c                	lw	a5,4(a0)
    80003630:	0047d79b          	srliw	a5,a5,0x4
    80003634:	0001b597          	auipc	a1,0x1b
    80003638:	c845a583          	lw	a1,-892(a1) # 8001e2b8 <sb+0x18>
    8000363c:	9dbd                	addw	a1,a1,a5
    8000363e:	4108                	lw	a0,0(a0)
    80003640:	fffff097          	auipc	ra,0xfffff
    80003644:	7e0080e7          	jalr	2016(ra) # 80002e20 <bread>
    80003648:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000364a:	06050793          	addi	a5,a0,96
    8000364e:	40c8                	lw	a0,4(s1)
    80003650:	893d                	andi	a0,a0,15
    80003652:	051a                	slli	a0,a0,0x6
    80003654:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003656:	0cc49703          	lh	a4,204(s1)
    8000365a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000365e:	0ce49703          	lh	a4,206(s1)
    80003662:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003666:	0d049703          	lh	a4,208(s1)
    8000366a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000366e:	0d249703          	lh	a4,210(s1)
    80003672:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003676:	0d44a703          	lw	a4,212(s1)
    8000367a:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000367c:	03400613          	li	a2,52
    80003680:	0d848593          	addi	a1,s1,216
    80003684:	0531                	addi	a0,a0,12
    80003686:	ffffd097          	auipc	ra,0xffffd
    8000368a:	744080e7          	jalr	1860(ra) # 80000dca <memmove>
  log_write(bp);
    8000368e:	854a                	mv	a0,s2
    80003690:	00001097          	auipc	ra,0x1
    80003694:	d6e080e7          	jalr	-658(ra) # 800043fe <log_write>
  brelse(bp);
    80003698:	854a                	mv	a0,s2
    8000369a:	00000097          	auipc	ra,0x0
    8000369e:	8ba080e7          	jalr	-1862(ra) # 80002f54 <brelse>
}
    800036a2:	60e2                	ld	ra,24(sp)
    800036a4:	6442                	ld	s0,16(sp)
    800036a6:	64a2                	ld	s1,8(sp)
    800036a8:	6902                	ld	s2,0(sp)
    800036aa:	6105                	addi	sp,sp,32
    800036ac:	8082                	ret

00000000800036ae <idup>:
{
    800036ae:	1101                	addi	sp,sp,-32
    800036b0:	ec06                	sd	ra,24(sp)
    800036b2:	e822                	sd	s0,16(sp)
    800036b4:	e426                	sd	s1,8(sp)
    800036b6:	1000                	addi	s0,sp,32
    800036b8:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800036ba:	0001b517          	auipc	a0,0x1b
    800036be:	c0650513          	addi	a0,a0,-1018 # 8001e2c0 <icache>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	3de080e7          	jalr	990(ra) # 80000aa0 <acquire>
  ip->ref++;
    800036ca:	449c                	lw	a5,8(s1)
    800036cc:	2785                	addiw	a5,a5,1
    800036ce:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800036d0:	0001b517          	auipc	a0,0x1b
    800036d4:	bf050513          	addi	a0,a0,-1040 # 8001e2c0 <icache>
    800036d8:	ffffd097          	auipc	ra,0xffffd
    800036dc:	498080e7          	jalr	1176(ra) # 80000b70 <release>
}
    800036e0:	8526                	mv	a0,s1
    800036e2:	60e2                	ld	ra,24(sp)
    800036e4:	6442                	ld	s0,16(sp)
    800036e6:	64a2                	ld	s1,8(sp)
    800036e8:	6105                	addi	sp,sp,32
    800036ea:	8082                	ret

00000000800036ec <ilock>:
{
    800036ec:	1101                	addi	sp,sp,-32
    800036ee:	ec06                	sd	ra,24(sp)
    800036f0:	e822                	sd	s0,16(sp)
    800036f2:	e426                	sd	s1,8(sp)
    800036f4:	e04a                	sd	s2,0(sp)
    800036f6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036f8:	c115                	beqz	a0,8000371c <ilock+0x30>
    800036fa:	84aa                	mv	s1,a0
    800036fc:	451c                	lw	a5,8(a0)
    800036fe:	00f05f63          	blez	a5,8000371c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003702:	0541                	addi	a0,a0,16
    80003704:	00001097          	auipc	ra,0x1
    80003708:	e74080e7          	jalr	-396(ra) # 80004578 <acquiresleep>
  if(ip->valid == 0){
    8000370c:	44bc                	lw	a5,72(s1)
    8000370e:	cf99                	beqz	a5,8000372c <ilock+0x40>
}
    80003710:	60e2                	ld	ra,24(sp)
    80003712:	6442                	ld	s0,16(sp)
    80003714:	64a2                	ld	s1,8(sp)
    80003716:	6902                	ld	s2,0(sp)
    80003718:	6105                	addi	sp,sp,32
    8000371a:	8082                	ret
    panic("ilock");
    8000371c:	00005517          	auipc	a0,0x5
    80003720:	fcc50513          	addi	a0,a0,-52 # 800086e8 <userret+0x658>
    80003724:	ffffd097          	auipc	ra,0xffffd
    80003728:	e30080e7          	jalr	-464(ra) # 80000554 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000372c:	40dc                	lw	a5,4(s1)
    8000372e:	0047d79b          	srliw	a5,a5,0x4
    80003732:	0001b597          	auipc	a1,0x1b
    80003736:	b865a583          	lw	a1,-1146(a1) # 8001e2b8 <sb+0x18>
    8000373a:	9dbd                	addw	a1,a1,a5
    8000373c:	4088                	lw	a0,0(s1)
    8000373e:	fffff097          	auipc	ra,0xfffff
    80003742:	6e2080e7          	jalr	1762(ra) # 80002e20 <bread>
    80003746:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003748:	06050593          	addi	a1,a0,96
    8000374c:	40dc                	lw	a5,4(s1)
    8000374e:	8bbd                	andi	a5,a5,15
    80003750:	079a                	slli	a5,a5,0x6
    80003752:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003754:	00059783          	lh	a5,0(a1)
    80003758:	0cf49623          	sh	a5,204(s1)
    ip->major = dip->major;
    8000375c:	00259783          	lh	a5,2(a1)
    80003760:	0cf49723          	sh	a5,206(s1)
    ip->minor = dip->minor;
    80003764:	00459783          	lh	a5,4(a1)
    80003768:	0cf49823          	sh	a5,208(s1)
    ip->nlink = dip->nlink;
    8000376c:	00659783          	lh	a5,6(a1)
    80003770:	0cf49923          	sh	a5,210(s1)
    ip->size = dip->size;
    80003774:	459c                	lw	a5,8(a1)
    80003776:	0cf4aa23          	sw	a5,212(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000377a:	03400613          	li	a2,52
    8000377e:	05b1                	addi	a1,a1,12
    80003780:	0d848513          	addi	a0,s1,216
    80003784:	ffffd097          	auipc	ra,0xffffd
    80003788:	646080e7          	jalr	1606(ra) # 80000dca <memmove>
    brelse(bp);
    8000378c:	854a                	mv	a0,s2
    8000378e:	fffff097          	auipc	ra,0xfffff
    80003792:	7c6080e7          	jalr	1990(ra) # 80002f54 <brelse>
    ip->valid = 1;
    80003796:	4785                	li	a5,1
    80003798:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    8000379a:	0cc49783          	lh	a5,204(s1)
    8000379e:	fbad                	bnez	a5,80003710 <ilock+0x24>
      panic("ilock: no type");
    800037a0:	00005517          	auipc	a0,0x5
    800037a4:	f5050513          	addi	a0,a0,-176 # 800086f0 <userret+0x660>
    800037a8:	ffffd097          	auipc	ra,0xffffd
    800037ac:	dac080e7          	jalr	-596(ra) # 80000554 <panic>

00000000800037b0 <iunlock>:
{
    800037b0:	1101                	addi	sp,sp,-32
    800037b2:	ec06                	sd	ra,24(sp)
    800037b4:	e822                	sd	s0,16(sp)
    800037b6:	e426                	sd	s1,8(sp)
    800037b8:	e04a                	sd	s2,0(sp)
    800037ba:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037bc:	c905                	beqz	a0,800037ec <iunlock+0x3c>
    800037be:	84aa                	mv	s1,a0
    800037c0:	01050913          	addi	s2,a0,16
    800037c4:	854a                	mv	a0,s2
    800037c6:	00001097          	auipc	ra,0x1
    800037ca:	e4c080e7          	jalr	-436(ra) # 80004612 <holdingsleep>
    800037ce:	cd19                	beqz	a0,800037ec <iunlock+0x3c>
    800037d0:	449c                	lw	a5,8(s1)
    800037d2:	00f05d63          	blez	a5,800037ec <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037d6:	854a                	mv	a0,s2
    800037d8:	00001097          	auipc	ra,0x1
    800037dc:	df6080e7          	jalr	-522(ra) # 800045ce <releasesleep>
}
    800037e0:	60e2                	ld	ra,24(sp)
    800037e2:	6442                	ld	s0,16(sp)
    800037e4:	64a2                	ld	s1,8(sp)
    800037e6:	6902                	ld	s2,0(sp)
    800037e8:	6105                	addi	sp,sp,32
    800037ea:	8082                	ret
    panic("iunlock");
    800037ec:	00005517          	auipc	a0,0x5
    800037f0:	f1450513          	addi	a0,a0,-236 # 80008700 <userret+0x670>
    800037f4:	ffffd097          	auipc	ra,0xffffd
    800037f8:	d60080e7          	jalr	-672(ra) # 80000554 <panic>

00000000800037fc <iput>:
{
    800037fc:	711d                	addi	sp,sp,-96
    800037fe:	ec86                	sd	ra,88(sp)
    80003800:	e8a2                	sd	s0,80(sp)
    80003802:	e4a6                	sd	s1,72(sp)
    80003804:	e0ca                	sd	s2,64(sp)
    80003806:	fc4e                	sd	s3,56(sp)
    80003808:	f852                	sd	s4,48(sp)
    8000380a:	f456                	sd	s5,40(sp)
    8000380c:	f05a                	sd	s6,32(sp)
    8000380e:	ec5e                	sd	s7,24(sp)
    80003810:	e862                	sd	s8,16(sp)
    80003812:	e466                	sd	s9,8(sp)
    80003814:	1080                	addi	s0,sp,96
    80003816:	89aa                	mv	s3,a0
  acquire(&icache.lock);
    80003818:	0001b517          	auipc	a0,0x1b
    8000381c:	aa850513          	addi	a0,a0,-1368 # 8001e2c0 <icache>
    80003820:	ffffd097          	auipc	ra,0xffffd
    80003824:	280080e7          	jalr	640(ra) # 80000aa0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003828:	0089a703          	lw	a4,8(s3)
    8000382c:	4785                	li	a5,1
    8000382e:	02f70c63          	beq	a4,a5,80003866 <iput+0x6a>
  ip->ref--;
    80003832:	0089a783          	lw	a5,8(s3)
    80003836:	37fd                	addiw	a5,a5,-1
    80003838:	00f9a423          	sw	a5,8(s3)
  release(&icache.lock);
    8000383c:	0001b517          	auipc	a0,0x1b
    80003840:	a8450513          	addi	a0,a0,-1404 # 8001e2c0 <icache>
    80003844:	ffffd097          	auipc	ra,0xffffd
    80003848:	32c080e7          	jalr	812(ra) # 80000b70 <release>
}
    8000384c:	60e6                	ld	ra,88(sp)
    8000384e:	6446                	ld	s0,80(sp)
    80003850:	64a6                	ld	s1,72(sp)
    80003852:	6906                	ld	s2,64(sp)
    80003854:	79e2                	ld	s3,56(sp)
    80003856:	7a42                	ld	s4,48(sp)
    80003858:	7aa2                	ld	s5,40(sp)
    8000385a:	7b02                	ld	s6,32(sp)
    8000385c:	6be2                	ld	s7,24(sp)
    8000385e:	6c42                	ld	s8,16(sp)
    80003860:	6ca2                	ld	s9,8(sp)
    80003862:	6125                	addi	sp,sp,96
    80003864:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003866:	0489a783          	lw	a5,72(s3)
    8000386a:	d7e1                	beqz	a5,80003832 <iput+0x36>
    8000386c:	0d299783          	lh	a5,210(s3)
    80003870:	f3e9                	bnez	a5,80003832 <iput+0x36>
    acquiresleep(&ip->lock);
    80003872:	01098b13          	addi	s6,s3,16
    80003876:	855a                	mv	a0,s6
    80003878:	00001097          	auipc	ra,0x1
    8000387c:	d00080e7          	jalr	-768(ra) # 80004578 <acquiresleep>
    release(&icache.lock);
    80003880:	0001b517          	auipc	a0,0x1b
    80003884:	a4050513          	addi	a0,a0,-1472 # 8001e2c0 <icache>
    80003888:	ffffd097          	auipc	ra,0xffffd
    8000388c:	2e8080e7          	jalr	744(ra) # 80000b70 <release>
{
  int i, j;
  struct buf *bp, *bp2;
  uint *a, *a2;
  /** Free掉所有Direct */
  for(i = 0; i < NDIRECT; i++){
    80003890:	0d898493          	addi	s1,s3,216
    80003894:	10498913          	addi	s2,s3,260
    80003898:	a821                	j	800038b0 <iput+0xb4>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    8000389a:	0009a503          	lw	a0,0(s3)
    8000389e:	fffff097          	auipc	ra,0xfffff
    800038a2:	7cc080e7          	jalr	1996(ra) # 8000306a <bfree>
      ip->addrs[i] = 0;
    800038a6:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    800038aa:	0491                	addi	s1,s1,4
    800038ac:	01248563          	beq	s1,s2,800038b6 <iput+0xba>
    if(ip->addrs[i]){
    800038b0:	408c                	lw	a1,0(s1)
    800038b2:	dde5                	beqz	a1,800038aa <iput+0xae>
    800038b4:	b7dd                	j	8000389a <iput+0x9e>
    }
  }
  /** Free掉single-direct  */
  if(ip->addrs[NDIRECT]){
    800038b6:	1049a583          	lw	a1,260(s3)
    800038ba:	e1b1                	bnez	a1,800038fe <iput+0x102>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }
  /** Free掉double-direct  */
  if(ip->addrs[NDIRECT + 1]){
    800038bc:	1089a783          	lw	a5,264(s3)
    800038c0:	e7d9                	bnez	a5,8000394e <iput+0x152>
    }
    brelse(bp);
    bfree(ip->dev, ip->addrs[pos]);
    ip->addrs[pos] = 0;
  }
  ip->size = 0;
    800038c2:	0c09aa23          	sw	zero,212(s3)
  iupdate(ip);
    800038c6:	854e                	mv	a0,s3
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	d58080e7          	jalr	-680(ra) # 80003620 <iupdate>
    ip->type = 0;
    800038d0:	0c099623          	sh	zero,204(s3)
    iupdate(ip);
    800038d4:	854e                	mv	a0,s3
    800038d6:	00000097          	auipc	ra,0x0
    800038da:	d4a080e7          	jalr	-694(ra) # 80003620 <iupdate>
    ip->valid = 0;
    800038de:	0409a423          	sw	zero,72(s3)
    releasesleep(&ip->lock);
    800038e2:	855a                	mv	a0,s6
    800038e4:	00001097          	auipc	ra,0x1
    800038e8:	cea080e7          	jalr	-790(ra) # 800045ce <releasesleep>
    acquire(&icache.lock);
    800038ec:	0001b517          	auipc	a0,0x1b
    800038f0:	9d450513          	addi	a0,a0,-1580 # 8001e2c0 <icache>
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	1ac080e7          	jalr	428(ra) # 80000aa0 <acquire>
    800038fc:	bf1d                	j	80003832 <iput+0x36>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038fe:	0009a503          	lw	a0,0(s3)
    80003902:	fffff097          	auipc	ra,0xfffff
    80003906:	51e080e7          	jalr	1310(ra) # 80002e20 <bread>
    8000390a:	8a2a                	mv	s4,a0
    for (j = 0; j < SINGLEDIRECT; j++)
    8000390c:	06050493          	addi	s1,a0,96
    80003910:	46050913          	addi	s2,a0,1120
    80003914:	a021                	j	8000391c <iput+0x120>
    80003916:	0491                	addi	s1,s1,4
    80003918:	01248b63          	beq	s1,s2,8000392e <iput+0x132>
      if(a[j])
    8000391c:	408c                	lw	a1,0(s1)
    8000391e:	dde5                	beqz	a1,80003916 <iput+0x11a>
        bfree(ip->dev, a[j]);
    80003920:	0009a503          	lw	a0,0(s3)
    80003924:	fffff097          	auipc	ra,0xfffff
    80003928:	746080e7          	jalr	1862(ra) # 8000306a <bfree>
    8000392c:	b7ed                	j	80003916 <iput+0x11a>
    brelse(bp);
    8000392e:	8552                	mv	a0,s4
    80003930:	fffff097          	auipc	ra,0xfffff
    80003934:	624080e7          	jalr	1572(ra) # 80002f54 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003938:	1049a583          	lw	a1,260(s3)
    8000393c:	0009a503          	lw	a0,0(s3)
    80003940:	fffff097          	auipc	ra,0xfffff
    80003944:	72a080e7          	jalr	1834(ra) # 8000306a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003948:	1009a223          	sw	zero,260(s3)
    8000394c:	bf85                	j	800038bc <iput+0xc0>
    printf("free double\n");
    8000394e:	00005517          	auipc	a0,0x5
    80003952:	dba50513          	addi	a0,a0,-582 # 80008708 <userret+0x678>
    80003956:	ffffd097          	auipc	ra,0xffffd
    8000395a:	c58080e7          	jalr	-936(ra) # 800005ae <printf>
    bp = bread(ip->dev, ip->addrs[pos]);
    8000395e:	1089a583          	lw	a1,264(s3)
    80003962:	0009a503          	lw	a0,0(s3)
    80003966:	fffff097          	auipc	ra,0xfffff
    8000396a:	4ba080e7          	jalr	1210(ra) # 80002e20 <bread>
    8000396e:	8caa                	mv	s9,a0
    for (i = 0; i < number_of_single_direct; i++)
    80003970:	06050a13          	addi	s4,a0,96
    80003974:	46050b93          	addi	s7,a0,1120
    80003978:	a83d                	j	800039b6 <iput+0x1ba>
            bfree(ip->dev, a2[j]);
    8000397a:	0009a503          	lw	a0,0(s3)
    8000397e:	fffff097          	auipc	ra,0xfffff
    80003982:	6ec080e7          	jalr	1772(ra) # 8000306a <bfree>
        for (j = 0; j < SINGLEDIRECT; j++)
    80003986:	0491                	addi	s1,s1,4
    80003988:	00990563          	beq	s2,s1,80003992 <iput+0x196>
          if(a2[j])
    8000398c:	408c                	lw	a1,0(s1)
    8000398e:	dde5                	beqz	a1,80003986 <iput+0x18a>
    80003990:	b7ed                	j	8000397a <iput+0x17e>
        brelse(bp2);
    80003992:	8562                	mv	a0,s8
    80003994:	fffff097          	auipc	ra,0xfffff
    80003998:	5c0080e7          	jalr	1472(ra) # 80002f54 <brelse>
        bfree(ip->dev, a[i]);
    8000399c:	000aa583          	lw	a1,0(s5)
    800039a0:	0009a503          	lw	a0,0(s3)
    800039a4:	fffff097          	auipc	ra,0xfffff
    800039a8:	6c6080e7          	jalr	1734(ra) # 8000306a <bfree>
        a[i] = 0;
    800039ac:	000aa023          	sw	zero,0(s5)
    for (i = 0; i < number_of_single_direct; i++)
    800039b0:	0a11                	addi	s4,s4,4
    800039b2:	037a0263          	beq	s4,s7,800039d6 <iput+0x1da>
      if(a[i]){
    800039b6:	8ad2                	mv	s5,s4
    800039b8:	000a2583          	lw	a1,0(s4)
    800039bc:	d9f5                	beqz	a1,800039b0 <iput+0x1b4>
        bp2 = bread(ip->dev, a[i]);
    800039be:	0009a503          	lw	a0,0(s3)
    800039c2:	fffff097          	auipc	ra,0xfffff
    800039c6:	45e080e7          	jalr	1118(ra) # 80002e20 <bread>
    800039ca:	8c2a                	mv	s8,a0
        for (j = 0; j < SINGLEDIRECT; j++)
    800039cc:	06050493          	addi	s1,a0,96
    800039d0:	46050913          	addi	s2,a0,1120
    800039d4:	bf65                	j	8000398c <iput+0x190>
    brelse(bp);
    800039d6:	8566                	mv	a0,s9
    800039d8:	fffff097          	auipc	ra,0xfffff
    800039dc:	57c080e7          	jalr	1404(ra) # 80002f54 <brelse>
    bfree(ip->dev, ip->addrs[pos]);
    800039e0:	1089a583          	lw	a1,264(s3)
    800039e4:	0009a503          	lw	a0,0(s3)
    800039e8:	fffff097          	auipc	ra,0xfffff
    800039ec:	682080e7          	jalr	1666(ra) # 8000306a <bfree>
    ip->addrs[pos] = 0;
    800039f0:	1009a423          	sw	zero,264(s3)
    800039f4:	b5f9                	j	800038c2 <iput+0xc6>

00000000800039f6 <iunlockput>:
{
    800039f6:	1101                	addi	sp,sp,-32
    800039f8:	ec06                	sd	ra,24(sp)
    800039fa:	e822                	sd	s0,16(sp)
    800039fc:	e426                	sd	s1,8(sp)
    800039fe:	1000                	addi	s0,sp,32
    80003a00:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a02:	00000097          	auipc	ra,0x0
    80003a06:	dae080e7          	jalr	-594(ra) # 800037b0 <iunlock>
  iput(ip);
    80003a0a:	8526                	mv	a0,s1
    80003a0c:	00000097          	auipc	ra,0x0
    80003a10:	df0080e7          	jalr	-528(ra) # 800037fc <iput>
}
    80003a14:	60e2                	ld	ra,24(sp)
    80003a16:	6442                	ld	s0,16(sp)
    80003a18:	64a2                	ld	s1,8(sp)
    80003a1a:	6105                	addi	sp,sp,32
    80003a1c:	8082                	ret

0000000080003a1e <mapaddr_single>:
{
    80003a1e:	1141                	addi	sp,sp,-16
    80003a20:	e422                	sd	s0,8(sp)
    80003a22:	0800                	addi	s0,sp,16
}
    80003a24:	4501                	li	a0,0
    80003a26:	6422                	ld	s0,8(sp)
    80003a28:	0141                	addi	sp,sp,16
    80003a2a:	8082                	ret

0000000080003a2c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a2c:	1141                	addi	sp,sp,-16
    80003a2e:	e422                	sd	s0,8(sp)
    80003a30:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a32:	411c                	lw	a5,0(a0)
    80003a34:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a36:	415c                	lw	a5,4(a0)
    80003a38:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a3a:	0cc51783          	lh	a5,204(a0)
    80003a3e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a42:	0d251783          	lh	a5,210(a0)
    80003a46:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a4a:	0d456783          	lwu	a5,212(a0)
    80003a4e:	e99c                	sd	a5,16(a1)
}
    80003a50:	6422                	ld	s0,8(sp)
    80003a52:	0141                	addi	sp,sp,16
    80003a54:	8082                	ret

0000000080003a56 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a56:	0d452783          	lw	a5,212(a0)
    80003a5a:	0ed7e563          	bltu	a5,a3,80003b44 <readi+0xee>
{
    80003a5e:	7159                	addi	sp,sp,-112
    80003a60:	f486                	sd	ra,104(sp)
    80003a62:	f0a2                	sd	s0,96(sp)
    80003a64:	eca6                	sd	s1,88(sp)
    80003a66:	e8ca                	sd	s2,80(sp)
    80003a68:	e4ce                	sd	s3,72(sp)
    80003a6a:	e0d2                	sd	s4,64(sp)
    80003a6c:	fc56                	sd	s5,56(sp)
    80003a6e:	f85a                	sd	s6,48(sp)
    80003a70:	f45e                	sd	s7,40(sp)
    80003a72:	f062                	sd	s8,32(sp)
    80003a74:	ec66                	sd	s9,24(sp)
    80003a76:	e86a                	sd	s10,16(sp)
    80003a78:	e46e                	sd	s11,8(sp)
    80003a7a:	1880                	addi	s0,sp,112
    80003a7c:	8baa                	mv	s7,a0
    80003a7e:	8c2e                	mv	s8,a1
    80003a80:	8ab2                	mv	s5,a2
    80003a82:	8936                	mv	s2,a3
    80003a84:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a86:	9f35                	addw	a4,a4,a3
    80003a88:	0cd76063          	bltu	a4,a3,80003b48 <readi+0xf2>
    return -1;
  if(off + n > ip->size)
    80003a8c:	00e7f463          	bgeu	a5,a4,80003a94 <readi+0x3e>
    n = ip->size - off;
    80003a90:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a94:	080b0763          	beqz	s6,80003b22 <readi+0xcc>
    80003a98:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a9a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a9e:	5cfd                	li	s9,-1
    80003aa0:	a82d                	j	80003ada <readi+0x84>
    80003aa2:	02099d93          	slli	s11,s3,0x20
    80003aa6:	020ddd93          	srli	s11,s11,0x20
    80003aaa:	06048793          	addi	a5,s1,96
    80003aae:	86ee                	mv	a3,s11
    80003ab0:	963e                	add	a2,a2,a5
    80003ab2:	85d6                	mv	a1,s5
    80003ab4:	8562                	mv	a0,s8
    80003ab6:	fffff097          	auipc	ra,0xfffff
    80003aba:	9bc080e7          	jalr	-1604(ra) # 80002472 <either_copyout>
    80003abe:	05950d63          	beq	a0,s9,80003b18 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003ac2:	8526                	mv	a0,s1
    80003ac4:	fffff097          	auipc	ra,0xfffff
    80003ac8:	490080e7          	jalr	1168(ra) # 80002f54 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003acc:	01498a3b          	addw	s4,s3,s4
    80003ad0:	0129893b          	addw	s2,s3,s2
    80003ad4:	9aee                	add	s5,s5,s11
    80003ad6:	056a7663          	bgeu	s4,s6,80003b22 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ada:	000ba483          	lw	s1,0(s7)
    80003ade:	00a9559b          	srliw	a1,s2,0xa
    80003ae2:	855e                	mv	a0,s7
    80003ae4:	fffff097          	auipc	ra,0xfffff
    80003ae8:	734080e7          	jalr	1844(ra) # 80003218 <bmap>
    80003aec:	0005059b          	sext.w	a1,a0
    80003af0:	8526                	mv	a0,s1
    80003af2:	fffff097          	auipc	ra,0xfffff
    80003af6:	32e080e7          	jalr	814(ra) # 80002e20 <bread>
    80003afa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003afc:	3ff97613          	andi	a2,s2,1023
    80003b00:	40cd07bb          	subw	a5,s10,a2
    80003b04:	414b073b          	subw	a4,s6,s4
    80003b08:	89be                	mv	s3,a5
    80003b0a:	2781                	sext.w	a5,a5
    80003b0c:	0007069b          	sext.w	a3,a4
    80003b10:	f8f6f9e3          	bgeu	a3,a5,80003aa2 <readi+0x4c>
    80003b14:	89ba                	mv	s3,a4
    80003b16:	b771                	j	80003aa2 <readi+0x4c>
      brelse(bp);
    80003b18:	8526                	mv	a0,s1
    80003b1a:	fffff097          	auipc	ra,0xfffff
    80003b1e:	43a080e7          	jalr	1082(ra) # 80002f54 <brelse>
  }
  return n;
    80003b22:	000b051b          	sext.w	a0,s6
}
    80003b26:	70a6                	ld	ra,104(sp)
    80003b28:	7406                	ld	s0,96(sp)
    80003b2a:	64e6                	ld	s1,88(sp)
    80003b2c:	6946                	ld	s2,80(sp)
    80003b2e:	69a6                	ld	s3,72(sp)
    80003b30:	6a06                	ld	s4,64(sp)
    80003b32:	7ae2                	ld	s5,56(sp)
    80003b34:	7b42                	ld	s6,48(sp)
    80003b36:	7ba2                	ld	s7,40(sp)
    80003b38:	7c02                	ld	s8,32(sp)
    80003b3a:	6ce2                	ld	s9,24(sp)
    80003b3c:	6d42                	ld	s10,16(sp)
    80003b3e:	6da2                	ld	s11,8(sp)
    80003b40:	6165                	addi	sp,sp,112
    80003b42:	8082                	ret
    return -1;
    80003b44:	557d                	li	a0,-1
}
    80003b46:	8082                	ret
    return -1;
    80003b48:	557d                	li	a0,-1
    80003b4a:	bff1                	j	80003b26 <readi+0xd0>

0000000080003b4c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b4c:	0d452783          	lw	a5,212(a0)
    80003b50:	10d7e763          	bltu	a5,a3,80003c5e <writei+0x112>
{
    80003b54:	7159                	addi	sp,sp,-112
    80003b56:	f486                	sd	ra,104(sp)
    80003b58:	f0a2                	sd	s0,96(sp)
    80003b5a:	eca6                	sd	s1,88(sp)
    80003b5c:	e8ca                	sd	s2,80(sp)
    80003b5e:	e4ce                	sd	s3,72(sp)
    80003b60:	e0d2                	sd	s4,64(sp)
    80003b62:	fc56                	sd	s5,56(sp)
    80003b64:	f85a                	sd	s6,48(sp)
    80003b66:	f45e                	sd	s7,40(sp)
    80003b68:	f062                	sd	s8,32(sp)
    80003b6a:	ec66                	sd	s9,24(sp)
    80003b6c:	e86a                	sd	s10,16(sp)
    80003b6e:	e46e                	sd	s11,8(sp)
    80003b70:	1880                	addi	s0,sp,112
    80003b72:	8baa                	mv	s7,a0
    80003b74:	8c2e                	mv	s8,a1
    80003b76:	8ab2                	mv	s5,a2
    80003b78:	8936                	mv	s2,a3
    80003b7a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b7c:	9f35                	addw	a4,a4,a3
    80003b7e:	0ed76263          	bltu	a4,a3,80003c62 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b82:	040437b7          	lui	a5,0x4043
    80003b86:	c0078793          	addi	a5,a5,-1024 # 4042c00 <_entry-0x7bfbd400>
    80003b8a:	0ce7ee63          	bltu	a5,a4,80003c66 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b8e:	0a0b0763          	beqz	s6,80003c3c <writei+0xf0>
    80003b92:	4a01                	li	s4,0
    /** 物理块重复了的指针？是什么问题  */
    /* printf("off/BSIZE: %d , bmap(ip, off/BSIZE): %p\n",off / BSIZE, bmap(ip, off/BSIZE));
    if((off / BSIZE) > SINGLEDIRECT + 20){
      exit(-1);
    } */
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b94:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b98:	5cfd                	li	s9,-1
    80003b9a:	a091                	j	80003bde <writei+0x92>
    80003b9c:	02099d93          	slli	s11,s3,0x20
    80003ba0:	020ddd93          	srli	s11,s11,0x20
    80003ba4:	06048793          	addi	a5,s1,96
    80003ba8:	86ee                	mv	a3,s11
    80003baa:	8656                	mv	a2,s5
    80003bac:	85e2                	mv	a1,s8
    80003bae:	953e                	add	a0,a0,a5
    80003bb0:	fffff097          	auipc	ra,0xfffff
    80003bb4:	918080e7          	jalr	-1768(ra) # 800024c8 <either_copyin>
    80003bb8:	07950263          	beq	a0,s9,80003c1c <writei+0xd0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003bbc:	8526                	mv	a0,s1
    80003bbe:	00001097          	auipc	ra,0x1
    80003bc2:	840080e7          	jalr	-1984(ra) # 800043fe <log_write>
    brelse(bp);
    80003bc6:	8526                	mv	a0,s1
    80003bc8:	fffff097          	auipc	ra,0xfffff
    80003bcc:	38c080e7          	jalr	908(ra) # 80002f54 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bd0:	01498a3b          	addw	s4,s3,s4
    80003bd4:	0129893b          	addw	s2,s3,s2
    80003bd8:	9aee                	add	s5,s5,s11
    80003bda:	056a7663          	bgeu	s4,s6,80003c26 <writei+0xda>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bde:	000ba483          	lw	s1,0(s7)
    80003be2:	00a9559b          	srliw	a1,s2,0xa
    80003be6:	855e                	mv	a0,s7
    80003be8:	fffff097          	auipc	ra,0xfffff
    80003bec:	630080e7          	jalr	1584(ra) # 80003218 <bmap>
    80003bf0:	0005059b          	sext.w	a1,a0
    80003bf4:	8526                	mv	a0,s1
    80003bf6:	fffff097          	auipc	ra,0xfffff
    80003bfa:	22a080e7          	jalr	554(ra) # 80002e20 <bread>
    80003bfe:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c00:	3ff97513          	andi	a0,s2,1023
    80003c04:	40ad07bb          	subw	a5,s10,a0
    80003c08:	414b073b          	subw	a4,s6,s4
    80003c0c:	89be                	mv	s3,a5
    80003c0e:	2781                	sext.w	a5,a5
    80003c10:	0007069b          	sext.w	a3,a4
    80003c14:	f8f6f4e3          	bgeu	a3,a5,80003b9c <writei+0x50>
    80003c18:	89ba                	mv	s3,a4
    80003c1a:	b749                	j	80003b9c <writei+0x50>
      brelse(bp);
    80003c1c:	8526                	mv	a0,s1
    80003c1e:	fffff097          	auipc	ra,0xfffff
    80003c22:	336080e7          	jalr	822(ra) # 80002f54 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003c26:	0d4ba783          	lw	a5,212(s7)
    80003c2a:	0127f463          	bgeu	a5,s2,80003c32 <writei+0xe6>
      ip->size = off;
    80003c2e:	0d2baa23          	sw	s2,212(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003c32:	855e                	mv	a0,s7
    80003c34:	00000097          	auipc	ra,0x0
    80003c38:	9ec080e7          	jalr	-1556(ra) # 80003620 <iupdate>
  }

  return n;
    80003c3c:	000b051b          	sext.w	a0,s6
}
    80003c40:	70a6                	ld	ra,104(sp)
    80003c42:	7406                	ld	s0,96(sp)
    80003c44:	64e6                	ld	s1,88(sp)
    80003c46:	6946                	ld	s2,80(sp)
    80003c48:	69a6                	ld	s3,72(sp)
    80003c4a:	6a06                	ld	s4,64(sp)
    80003c4c:	7ae2                	ld	s5,56(sp)
    80003c4e:	7b42                	ld	s6,48(sp)
    80003c50:	7ba2                	ld	s7,40(sp)
    80003c52:	7c02                	ld	s8,32(sp)
    80003c54:	6ce2                	ld	s9,24(sp)
    80003c56:	6d42                	ld	s10,16(sp)
    80003c58:	6da2                	ld	s11,8(sp)
    80003c5a:	6165                	addi	sp,sp,112
    80003c5c:	8082                	ret
    return -1;
    80003c5e:	557d                	li	a0,-1
}
    80003c60:	8082                	ret
    return -1;
    80003c62:	557d                	li	a0,-1
    80003c64:	bff1                	j	80003c40 <writei+0xf4>
    return -1;
    80003c66:	557d                	li	a0,-1
    80003c68:	bfe1                	j	80003c40 <writei+0xf4>

0000000080003c6a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c6a:	1141                	addi	sp,sp,-16
    80003c6c:	e406                	sd	ra,8(sp)
    80003c6e:	e022                	sd	s0,0(sp)
    80003c70:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c72:	4639                	li	a2,14
    80003c74:	ffffd097          	auipc	ra,0xffffd
    80003c78:	1d2080e7          	jalr	466(ra) # 80000e46 <strncmp>
}
    80003c7c:	60a2                	ld	ra,8(sp)
    80003c7e:	6402                	ld	s0,0(sp)
    80003c80:	0141                	addi	sp,sp,16
    80003c82:	8082                	ret

0000000080003c84 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c84:	7139                	addi	sp,sp,-64
    80003c86:	fc06                	sd	ra,56(sp)
    80003c88:	f822                	sd	s0,48(sp)
    80003c8a:	f426                	sd	s1,40(sp)
    80003c8c:	f04a                	sd	s2,32(sp)
    80003c8e:	ec4e                	sd	s3,24(sp)
    80003c90:	e852                	sd	s4,16(sp)
    80003c92:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c94:	0cc51703          	lh	a4,204(a0)
    80003c98:	4785                	li	a5,1
    80003c9a:	00f71b63          	bne	a4,a5,80003cb0 <dirlookup+0x2c>
    80003c9e:	892a                	mv	s2,a0
    80003ca0:	89ae                	mv	s3,a1
    80003ca2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ca4:	0d452783          	lw	a5,212(a0)
    80003ca8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003caa:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cac:	e79d                	bnez	a5,80003cda <dirlookup+0x56>
    80003cae:	a8a5                	j	80003d26 <dirlookup+0xa2>
    panic("dirlookup not DIR");
    80003cb0:	00005517          	auipc	a0,0x5
    80003cb4:	a6850513          	addi	a0,a0,-1432 # 80008718 <userret+0x688>
    80003cb8:	ffffd097          	auipc	ra,0xffffd
    80003cbc:	89c080e7          	jalr	-1892(ra) # 80000554 <panic>
      panic("dirlookup read");
    80003cc0:	00005517          	auipc	a0,0x5
    80003cc4:	a7050513          	addi	a0,a0,-1424 # 80008730 <userret+0x6a0>
    80003cc8:	ffffd097          	auipc	ra,0xffffd
    80003ccc:	88c080e7          	jalr	-1908(ra) # 80000554 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cd0:	24c1                	addiw	s1,s1,16
    80003cd2:	0d492783          	lw	a5,212(s2)
    80003cd6:	04f4f763          	bgeu	s1,a5,80003d24 <dirlookup+0xa0>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cda:	4741                	li	a4,16
    80003cdc:	86a6                	mv	a3,s1
    80003cde:	fc040613          	addi	a2,s0,-64
    80003ce2:	4581                	li	a1,0
    80003ce4:	854a                	mv	a0,s2
    80003ce6:	00000097          	auipc	ra,0x0
    80003cea:	d70080e7          	jalr	-656(ra) # 80003a56 <readi>
    80003cee:	47c1                	li	a5,16
    80003cf0:	fcf518e3          	bne	a0,a5,80003cc0 <dirlookup+0x3c>
    if(de.inum == 0)
    80003cf4:	fc045783          	lhu	a5,-64(s0)
    80003cf8:	dfe1                	beqz	a5,80003cd0 <dirlookup+0x4c>
    if(namecmp(name, de.name) == 0){
    80003cfa:	fc240593          	addi	a1,s0,-62
    80003cfe:	854e                	mv	a0,s3
    80003d00:	00000097          	auipc	ra,0x0
    80003d04:	f6a080e7          	jalr	-150(ra) # 80003c6a <namecmp>
    80003d08:	f561                	bnez	a0,80003cd0 <dirlookup+0x4c>
      if(poff)
    80003d0a:	000a0463          	beqz	s4,80003d12 <dirlookup+0x8e>
        *poff = off;
    80003d0e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d12:	fc045583          	lhu	a1,-64(s0)
    80003d16:	00092503          	lw	a0,0(s2)
    80003d1a:	fffff097          	auipc	ra,0xfffff
    80003d1e:	69c080e7          	jalr	1692(ra) # 800033b6 <iget>
    80003d22:	a011                	j	80003d26 <dirlookup+0xa2>
  return 0;
    80003d24:	4501                	li	a0,0
}
    80003d26:	70e2                	ld	ra,56(sp)
    80003d28:	7442                	ld	s0,48(sp)
    80003d2a:	74a2                	ld	s1,40(sp)
    80003d2c:	7902                	ld	s2,32(sp)
    80003d2e:	69e2                	ld	s3,24(sp)
    80003d30:	6a42                	ld	s4,16(sp)
    80003d32:	6121                	addi	sp,sp,64
    80003d34:	8082                	ret

0000000080003d36 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d36:	711d                	addi	sp,sp,-96
    80003d38:	ec86                	sd	ra,88(sp)
    80003d3a:	e8a2                	sd	s0,80(sp)
    80003d3c:	e4a6                	sd	s1,72(sp)
    80003d3e:	e0ca                	sd	s2,64(sp)
    80003d40:	fc4e                	sd	s3,56(sp)
    80003d42:	f852                	sd	s4,48(sp)
    80003d44:	f456                	sd	s5,40(sp)
    80003d46:	f05a                	sd	s6,32(sp)
    80003d48:	ec5e                	sd	s7,24(sp)
    80003d4a:	e862                	sd	s8,16(sp)
    80003d4c:	e466                	sd	s9,8(sp)
    80003d4e:	1080                	addi	s0,sp,96
    80003d50:	84aa                	mv	s1,a0
    80003d52:	8aae                	mv	s5,a1
    80003d54:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d56:	00054703          	lbu	a4,0(a0)
    80003d5a:	02f00793          	li	a5,47
    80003d5e:	02f70363          	beq	a4,a5,80003d84 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d62:	ffffe097          	auipc	ra,0xffffe
    80003d66:	cf6080e7          	jalr	-778(ra) # 80001a58 <myproc>
    80003d6a:	15853503          	ld	a0,344(a0)
    80003d6e:	00000097          	auipc	ra,0x0
    80003d72:	940080e7          	jalr	-1728(ra) # 800036ae <idup>
    80003d76:	89aa                	mv	s3,a0
  while(*path == '/')
    80003d78:	02f00913          	li	s2,47
  len = path - s;
    80003d7c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003d7e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d80:	4b85                	li	s7,1
    80003d82:	a865                	j	80003e3a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003d84:	4585                	li	a1,1
    80003d86:	4501                	li	a0,0
    80003d88:	fffff097          	auipc	ra,0xfffff
    80003d8c:	62e080e7          	jalr	1582(ra) # 800033b6 <iget>
    80003d90:	89aa                	mv	s3,a0
    80003d92:	b7dd                	j	80003d78 <namex+0x42>
      iunlockput(ip);
    80003d94:	854e                	mv	a0,s3
    80003d96:	00000097          	auipc	ra,0x0
    80003d9a:	c60080e7          	jalr	-928(ra) # 800039f6 <iunlockput>
      return 0;
    80003d9e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003da0:	854e                	mv	a0,s3
    80003da2:	60e6                	ld	ra,88(sp)
    80003da4:	6446                	ld	s0,80(sp)
    80003da6:	64a6                	ld	s1,72(sp)
    80003da8:	6906                	ld	s2,64(sp)
    80003daa:	79e2                	ld	s3,56(sp)
    80003dac:	7a42                	ld	s4,48(sp)
    80003dae:	7aa2                	ld	s5,40(sp)
    80003db0:	7b02                	ld	s6,32(sp)
    80003db2:	6be2                	ld	s7,24(sp)
    80003db4:	6c42                	ld	s8,16(sp)
    80003db6:	6ca2                	ld	s9,8(sp)
    80003db8:	6125                	addi	sp,sp,96
    80003dba:	8082                	ret
      iunlock(ip);
    80003dbc:	854e                	mv	a0,s3
    80003dbe:	00000097          	auipc	ra,0x0
    80003dc2:	9f2080e7          	jalr	-1550(ra) # 800037b0 <iunlock>
      return ip;
    80003dc6:	bfe9                	j	80003da0 <namex+0x6a>
      iunlockput(ip);
    80003dc8:	854e                	mv	a0,s3
    80003dca:	00000097          	auipc	ra,0x0
    80003dce:	c2c080e7          	jalr	-980(ra) # 800039f6 <iunlockput>
      return 0;
    80003dd2:	89e6                	mv	s3,s9
    80003dd4:	b7f1                	j	80003da0 <namex+0x6a>
  len = path - s;
    80003dd6:	40b48633          	sub	a2,s1,a1
    80003dda:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003dde:	099c5463          	bge	s8,s9,80003e66 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003de2:	4639                	li	a2,14
    80003de4:	8552                	mv	a0,s4
    80003de6:	ffffd097          	auipc	ra,0xffffd
    80003dea:	fe4080e7          	jalr	-28(ra) # 80000dca <memmove>
  while(*path == '/')
    80003dee:	0004c783          	lbu	a5,0(s1)
    80003df2:	01279763          	bne	a5,s2,80003e00 <namex+0xca>
    path++;
    80003df6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003df8:	0004c783          	lbu	a5,0(s1)
    80003dfc:	ff278de3          	beq	a5,s2,80003df6 <namex+0xc0>
    ilock(ip);
    80003e00:	854e                	mv	a0,s3
    80003e02:	00000097          	auipc	ra,0x0
    80003e06:	8ea080e7          	jalr	-1814(ra) # 800036ec <ilock>
    if(ip->type != T_DIR){
    80003e0a:	0cc99783          	lh	a5,204(s3)
    80003e0e:	f97793e3          	bne	a5,s7,80003d94 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003e12:	000a8563          	beqz	s5,80003e1c <namex+0xe6>
    80003e16:	0004c783          	lbu	a5,0(s1)
    80003e1a:	d3cd                	beqz	a5,80003dbc <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e1c:	865a                	mv	a2,s6
    80003e1e:	85d2                	mv	a1,s4
    80003e20:	854e                	mv	a0,s3
    80003e22:	00000097          	auipc	ra,0x0
    80003e26:	e62080e7          	jalr	-414(ra) # 80003c84 <dirlookup>
    80003e2a:	8caa                	mv	s9,a0
    80003e2c:	dd51                	beqz	a0,80003dc8 <namex+0x92>
    iunlockput(ip);
    80003e2e:	854e                	mv	a0,s3
    80003e30:	00000097          	auipc	ra,0x0
    80003e34:	bc6080e7          	jalr	-1082(ra) # 800039f6 <iunlockput>
    ip = next;
    80003e38:	89e6                	mv	s3,s9
  while(*path == '/')
    80003e3a:	0004c783          	lbu	a5,0(s1)
    80003e3e:	05279763          	bne	a5,s2,80003e8c <namex+0x156>
    path++;
    80003e42:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e44:	0004c783          	lbu	a5,0(s1)
    80003e48:	ff278de3          	beq	a5,s2,80003e42 <namex+0x10c>
  if(*path == 0)
    80003e4c:	c79d                	beqz	a5,80003e7a <namex+0x144>
    path++;
    80003e4e:	85a6                	mv	a1,s1
  len = path - s;
    80003e50:	8cda                	mv	s9,s6
    80003e52:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003e54:	01278963          	beq	a5,s2,80003e66 <namex+0x130>
    80003e58:	dfbd                	beqz	a5,80003dd6 <namex+0xa0>
    path++;
    80003e5a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003e5c:	0004c783          	lbu	a5,0(s1)
    80003e60:	ff279ce3          	bne	a5,s2,80003e58 <namex+0x122>
    80003e64:	bf8d                	j	80003dd6 <namex+0xa0>
    memmove(name, s, len);
    80003e66:	2601                	sext.w	a2,a2
    80003e68:	8552                	mv	a0,s4
    80003e6a:	ffffd097          	auipc	ra,0xffffd
    80003e6e:	f60080e7          	jalr	-160(ra) # 80000dca <memmove>
    name[len] = 0;
    80003e72:	9cd2                	add	s9,s9,s4
    80003e74:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e78:	bf9d                	j	80003dee <namex+0xb8>
  if(nameiparent){
    80003e7a:	f20a83e3          	beqz	s5,80003da0 <namex+0x6a>
    iput(ip);
    80003e7e:	854e                	mv	a0,s3
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	97c080e7          	jalr	-1668(ra) # 800037fc <iput>
    return 0;
    80003e88:	4981                	li	s3,0
    80003e8a:	bf19                	j	80003da0 <namex+0x6a>
  if(*path == 0)
    80003e8c:	d7fd                	beqz	a5,80003e7a <namex+0x144>
  while(*path != '/' && *path != 0)
    80003e8e:	0004c783          	lbu	a5,0(s1)
    80003e92:	85a6                	mv	a1,s1
    80003e94:	b7d1                	j	80003e58 <namex+0x122>

0000000080003e96 <dirlink>:
{
    80003e96:	7139                	addi	sp,sp,-64
    80003e98:	fc06                	sd	ra,56(sp)
    80003e9a:	f822                	sd	s0,48(sp)
    80003e9c:	f426                	sd	s1,40(sp)
    80003e9e:	f04a                	sd	s2,32(sp)
    80003ea0:	ec4e                	sd	s3,24(sp)
    80003ea2:	e852                	sd	s4,16(sp)
    80003ea4:	0080                	addi	s0,sp,64
    80003ea6:	892a                	mv	s2,a0
    80003ea8:	8a2e                	mv	s4,a1
    80003eaa:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003eac:	4601                	li	a2,0
    80003eae:	00000097          	auipc	ra,0x0
    80003eb2:	dd6080e7          	jalr	-554(ra) # 80003c84 <dirlookup>
    80003eb6:	e93d                	bnez	a0,80003f2c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eb8:	0d492483          	lw	s1,212(s2)
    80003ebc:	c49d                	beqz	s1,80003eea <dirlink+0x54>
    80003ebe:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ec0:	4741                	li	a4,16
    80003ec2:	86a6                	mv	a3,s1
    80003ec4:	fc040613          	addi	a2,s0,-64
    80003ec8:	4581                	li	a1,0
    80003eca:	854a                	mv	a0,s2
    80003ecc:	00000097          	auipc	ra,0x0
    80003ed0:	b8a080e7          	jalr	-1142(ra) # 80003a56 <readi>
    80003ed4:	47c1                	li	a5,16
    80003ed6:	06f51163          	bne	a0,a5,80003f38 <dirlink+0xa2>
    if(de.inum == 0)
    80003eda:	fc045783          	lhu	a5,-64(s0)
    80003ede:	c791                	beqz	a5,80003eea <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ee0:	24c1                	addiw	s1,s1,16
    80003ee2:	0d492783          	lw	a5,212(s2)
    80003ee6:	fcf4ede3          	bltu	s1,a5,80003ec0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003eea:	4639                	li	a2,14
    80003eec:	85d2                	mv	a1,s4
    80003eee:	fc240513          	addi	a0,s0,-62
    80003ef2:	ffffd097          	auipc	ra,0xffffd
    80003ef6:	f90080e7          	jalr	-112(ra) # 80000e82 <strncpy>
  de.inum = inum;
    80003efa:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003efe:	4741                	li	a4,16
    80003f00:	86a6                	mv	a3,s1
    80003f02:	fc040613          	addi	a2,s0,-64
    80003f06:	4581                	li	a1,0
    80003f08:	854a                	mv	a0,s2
    80003f0a:	00000097          	auipc	ra,0x0
    80003f0e:	c42080e7          	jalr	-958(ra) # 80003b4c <writei>
    80003f12:	872a                	mv	a4,a0
    80003f14:	47c1                	li	a5,16
  return 0;
    80003f16:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f18:	02f71863          	bne	a4,a5,80003f48 <dirlink+0xb2>
}
    80003f1c:	70e2                	ld	ra,56(sp)
    80003f1e:	7442                	ld	s0,48(sp)
    80003f20:	74a2                	ld	s1,40(sp)
    80003f22:	7902                	ld	s2,32(sp)
    80003f24:	69e2                	ld	s3,24(sp)
    80003f26:	6a42                	ld	s4,16(sp)
    80003f28:	6121                	addi	sp,sp,64
    80003f2a:	8082                	ret
    iput(ip);
    80003f2c:	00000097          	auipc	ra,0x0
    80003f30:	8d0080e7          	jalr	-1840(ra) # 800037fc <iput>
    return -1;
    80003f34:	557d                	li	a0,-1
    80003f36:	b7dd                	j	80003f1c <dirlink+0x86>
      panic("dirlink read");
    80003f38:	00005517          	auipc	a0,0x5
    80003f3c:	80850513          	addi	a0,a0,-2040 # 80008740 <userret+0x6b0>
    80003f40:	ffffc097          	auipc	ra,0xffffc
    80003f44:	614080e7          	jalr	1556(ra) # 80000554 <panic>
    panic("dirlink");
    80003f48:	00005517          	auipc	a0,0x5
    80003f4c:	91850513          	addi	a0,a0,-1768 # 80008860 <userret+0x7d0>
    80003f50:	ffffc097          	auipc	ra,0xffffc
    80003f54:	604080e7          	jalr	1540(ra) # 80000554 <panic>

0000000080003f58 <namei>:

struct inode*
namei(char *path)
{
    80003f58:	1101                	addi	sp,sp,-32
    80003f5a:	ec06                	sd	ra,24(sp)
    80003f5c:	e822                	sd	s0,16(sp)
    80003f5e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f60:	fe040613          	addi	a2,s0,-32
    80003f64:	4581                	li	a1,0
    80003f66:	00000097          	auipc	ra,0x0
    80003f6a:	dd0080e7          	jalr	-560(ra) # 80003d36 <namex>
}
    80003f6e:	60e2                	ld	ra,24(sp)
    80003f70:	6442                	ld	s0,16(sp)
    80003f72:	6105                	addi	sp,sp,32
    80003f74:	8082                	ret

0000000080003f76 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f76:	1141                	addi	sp,sp,-16
    80003f78:	e406                	sd	ra,8(sp)
    80003f7a:	e022                	sd	s0,0(sp)
    80003f7c:	0800                	addi	s0,sp,16
    80003f7e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f80:	4585                	li	a1,1
    80003f82:	00000097          	auipc	ra,0x0
    80003f86:	db4080e7          	jalr	-588(ra) # 80003d36 <namex>
}
    80003f8a:	60a2                	ld	ra,8(sp)
    80003f8c:	6402                	ld	s0,0(sp)
    80003f8e:	0141                	addi	sp,sp,16
    80003f90:	8082                	ret

0000000080003f92 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80003f92:	7179                	addi	sp,sp,-48
    80003f94:	f406                	sd	ra,40(sp)
    80003f96:	f022                	sd	s0,32(sp)
    80003f98:	ec26                	sd	s1,24(sp)
    80003f9a:	e84a                	sd	s2,16(sp)
    80003f9c:	e44e                	sd	s3,8(sp)
    80003f9e:	1800                	addi	s0,sp,48
    80003fa0:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80003fa2:	0b000993          	li	s3,176
    80003fa6:	033507b3          	mul	a5,a0,s3
    80003faa:	0001e997          	auipc	s3,0x1e
    80003fae:	85698993          	addi	s3,s3,-1962 # 80021800 <log>
    80003fb2:	99be                	add	s3,s3,a5
    80003fb4:	0209a583          	lw	a1,32(s3)
    80003fb8:	fffff097          	auipc	ra,0xfffff
    80003fbc:	e68080e7          	jalr	-408(ra) # 80002e20 <bread>
    80003fc0:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80003fc2:	0349a783          	lw	a5,52(s3)
    80003fc6:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003fc8:	0349a783          	lw	a5,52(s3)
    80003fcc:	02f05763          	blez	a5,80003ffa <write_head+0x68>
    80003fd0:	0b000793          	li	a5,176
    80003fd4:	02f487b3          	mul	a5,s1,a5
    80003fd8:	0001e717          	auipc	a4,0x1e
    80003fdc:	86070713          	addi	a4,a4,-1952 # 80021838 <log+0x38>
    80003fe0:	97ba                	add	a5,a5,a4
    80003fe2:	06450693          	addi	a3,a0,100
    80003fe6:	4701                	li	a4,0
    80003fe8:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80003fea:	4390                	lw	a2,0(a5)
    80003fec:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003fee:	2705                	addiw	a4,a4,1
    80003ff0:	0791                	addi	a5,a5,4
    80003ff2:	0691                	addi	a3,a3,4
    80003ff4:	59d0                	lw	a2,52(a1)
    80003ff6:	fec74ae3          	blt	a4,a2,80003fea <write_head+0x58>
  }
  bwrite(buf);
    80003ffa:	854a                	mv	a0,s2
    80003ffc:	fffff097          	auipc	ra,0xfffff
    80004000:	f18080e7          	jalr	-232(ra) # 80002f14 <bwrite>
  brelse(buf);
    80004004:	854a                	mv	a0,s2
    80004006:	fffff097          	auipc	ra,0xfffff
    8000400a:	f4e080e7          	jalr	-178(ra) # 80002f54 <brelse>
}
    8000400e:	70a2                	ld	ra,40(sp)
    80004010:	7402                	ld	s0,32(sp)
    80004012:	64e2                	ld	s1,24(sp)
    80004014:	6942                	ld	s2,16(sp)
    80004016:	69a2                	ld	s3,8(sp)
    80004018:	6145                	addi	sp,sp,48
    8000401a:	8082                	ret

000000008000401c <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000401c:	0b000793          	li	a5,176
    80004020:	02f50733          	mul	a4,a0,a5
    80004024:	0001d797          	auipc	a5,0x1d
    80004028:	7dc78793          	addi	a5,a5,2012 # 80021800 <log>
    8000402c:	97ba                	add	a5,a5,a4
    8000402e:	5bdc                	lw	a5,52(a5)
    80004030:	0af05b63          	blez	a5,800040e6 <install_trans+0xca>
{
    80004034:	7139                	addi	sp,sp,-64
    80004036:	fc06                	sd	ra,56(sp)
    80004038:	f822                	sd	s0,48(sp)
    8000403a:	f426                	sd	s1,40(sp)
    8000403c:	f04a                	sd	s2,32(sp)
    8000403e:	ec4e                	sd	s3,24(sp)
    80004040:	e852                	sd	s4,16(sp)
    80004042:	e456                	sd	s5,8(sp)
    80004044:	e05a                	sd	s6,0(sp)
    80004046:	0080                	addi	s0,sp,64
    80004048:	0001d797          	auipc	a5,0x1d
    8000404c:	7f078793          	addi	a5,a5,2032 # 80021838 <log+0x38>
    80004050:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004054:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80004056:	00050b1b          	sext.w	s6,a0
    8000405a:	0001da97          	auipc	s5,0x1d
    8000405e:	7a6a8a93          	addi	s5,s5,1958 # 80021800 <log>
    80004062:	9aba                	add	s5,s5,a4
    80004064:	020aa583          	lw	a1,32(s5)
    80004068:	013585bb          	addw	a1,a1,s3
    8000406c:	2585                	addiw	a1,a1,1
    8000406e:	855a                	mv	a0,s6
    80004070:	fffff097          	auipc	ra,0xfffff
    80004074:	db0080e7          	jalr	-592(ra) # 80002e20 <bread>
    80004078:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    8000407a:	000a2583          	lw	a1,0(s4)
    8000407e:	855a                	mv	a0,s6
    80004080:	fffff097          	auipc	ra,0xfffff
    80004084:	da0080e7          	jalr	-608(ra) # 80002e20 <bread>
    80004088:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000408a:	40000613          	li	a2,1024
    8000408e:	06090593          	addi	a1,s2,96
    80004092:	06050513          	addi	a0,a0,96
    80004096:	ffffd097          	auipc	ra,0xffffd
    8000409a:	d34080e7          	jalr	-716(ra) # 80000dca <memmove>
    bwrite(dbuf);  // write dst to disk
    8000409e:	8526                	mv	a0,s1
    800040a0:	fffff097          	auipc	ra,0xfffff
    800040a4:	e74080e7          	jalr	-396(ra) # 80002f14 <bwrite>
    bunpin(dbuf);
    800040a8:	8526                	mv	a0,s1
    800040aa:	fffff097          	auipc	ra,0xfffff
    800040ae:	f84080e7          	jalr	-124(ra) # 8000302e <bunpin>
    brelse(lbuf);
    800040b2:	854a                	mv	a0,s2
    800040b4:	fffff097          	auipc	ra,0xfffff
    800040b8:	ea0080e7          	jalr	-352(ra) # 80002f54 <brelse>
    brelse(dbuf);
    800040bc:	8526                	mv	a0,s1
    800040be:	fffff097          	auipc	ra,0xfffff
    800040c2:	e96080e7          	jalr	-362(ra) # 80002f54 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800040c6:	2985                	addiw	s3,s3,1
    800040c8:	0a11                	addi	s4,s4,4
    800040ca:	034aa783          	lw	a5,52(s5)
    800040ce:	f8f9cbe3          	blt	s3,a5,80004064 <install_trans+0x48>
}
    800040d2:	70e2                	ld	ra,56(sp)
    800040d4:	7442                	ld	s0,48(sp)
    800040d6:	74a2                	ld	s1,40(sp)
    800040d8:	7902                	ld	s2,32(sp)
    800040da:	69e2                	ld	s3,24(sp)
    800040dc:	6a42                	ld	s4,16(sp)
    800040de:	6aa2                	ld	s5,8(sp)
    800040e0:	6b02                	ld	s6,0(sp)
    800040e2:	6121                	addi	sp,sp,64
    800040e4:	8082                	ret
    800040e6:	8082                	ret

00000000800040e8 <initlog>:
{
    800040e8:	7179                	addi	sp,sp,-48
    800040ea:	f406                	sd	ra,40(sp)
    800040ec:	f022                	sd	s0,32(sp)
    800040ee:	ec26                	sd	s1,24(sp)
    800040f0:	e84a                	sd	s2,16(sp)
    800040f2:	e44e                	sd	s3,8(sp)
    800040f4:	e052                	sd	s4,0(sp)
    800040f6:	1800                	addi	s0,sp,48
    800040f8:	892a                	mv	s2,a0
    800040fa:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    800040fc:	0b000713          	li	a4,176
    80004100:	02e504b3          	mul	s1,a0,a4
    80004104:	0001d997          	auipc	s3,0x1d
    80004108:	6fc98993          	addi	s3,s3,1788 # 80021800 <log>
    8000410c:	99a6                	add	s3,s3,s1
    8000410e:	00004597          	auipc	a1,0x4
    80004112:	64258593          	addi	a1,a1,1602 # 80008750 <userret+0x6c0>
    80004116:	854e                	mv	a0,s3
    80004118:	ffffd097          	auipc	ra,0xffffd
    8000411c:	8b4080e7          	jalr	-1868(ra) # 800009cc <initlock>
  log[dev].start = sb->logstart;
    80004120:	014a2583          	lw	a1,20(s4)
    80004124:	02b9a023          	sw	a1,32(s3)
  log[dev].size = sb->nlog;
    80004128:	010a2783          	lw	a5,16(s4)
    8000412c:	02f9a223          	sw	a5,36(s3)
  log[dev].dev = dev;
    80004130:	0329a823          	sw	s2,48(s3)
  struct buf *buf = bread(dev, log[dev].start);
    80004134:	854a                	mv	a0,s2
    80004136:	fffff097          	auipc	ra,0xfffff
    8000413a:	cea080e7          	jalr	-790(ra) # 80002e20 <bread>
  log[dev].lh.n = lh->n;
    8000413e:	5134                	lw	a3,96(a0)
    80004140:	02d9aa23          	sw	a3,52(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004144:	02d05663          	blez	a3,80004170 <initlog+0x88>
    80004148:	06450793          	addi	a5,a0,100
    8000414c:	0001d717          	auipc	a4,0x1d
    80004150:	6ec70713          	addi	a4,a4,1772 # 80021838 <log+0x38>
    80004154:	9726                	add	a4,a4,s1
    80004156:	36fd                	addiw	a3,a3,-1
    80004158:	1682                	slli	a3,a3,0x20
    8000415a:	9281                	srli	a3,a3,0x20
    8000415c:	068a                	slli	a3,a3,0x2
    8000415e:	06850613          	addi	a2,a0,104
    80004162:	96b2                	add	a3,a3,a2
    log[dev].lh.block[i] = lh->block[i];
    80004164:	4390                	lw	a2,0(a5)
    80004166:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004168:	0791                	addi	a5,a5,4
    8000416a:	0711                	addi	a4,a4,4
    8000416c:	fed79ce3          	bne	a5,a3,80004164 <initlog+0x7c>
  brelse(buf);
    80004170:	fffff097          	auipc	ra,0xfffff
    80004174:	de4080e7          	jalr	-540(ra) # 80002f54 <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    80004178:	854a                	mv	a0,s2
    8000417a:	00000097          	auipc	ra,0x0
    8000417e:	ea2080e7          	jalr	-350(ra) # 8000401c <install_trans>
  log[dev].lh.n = 0;
    80004182:	0b000793          	li	a5,176
    80004186:	02f90733          	mul	a4,s2,a5
    8000418a:	0001d797          	auipc	a5,0x1d
    8000418e:	67678793          	addi	a5,a5,1654 # 80021800 <log>
    80004192:	97ba                	add	a5,a5,a4
    80004194:	0207aa23          	sw	zero,52(a5)
  write_head(dev); // clear the log
    80004198:	854a                	mv	a0,s2
    8000419a:	00000097          	auipc	ra,0x0
    8000419e:	df8080e7          	jalr	-520(ra) # 80003f92 <write_head>
}
    800041a2:	70a2                	ld	ra,40(sp)
    800041a4:	7402                	ld	s0,32(sp)
    800041a6:	64e2                	ld	s1,24(sp)
    800041a8:	6942                	ld	s2,16(sp)
    800041aa:	69a2                	ld	s3,8(sp)
    800041ac:	6a02                	ld	s4,0(sp)
    800041ae:	6145                	addi	sp,sp,48
    800041b0:	8082                	ret

00000000800041b2 <begin_op>:
 * and until there is enough unreserved log 
 * space to hold the writes from this call.
 */
void
begin_op(int dev)
{
    800041b2:	7139                	addi	sp,sp,-64
    800041b4:	fc06                	sd	ra,56(sp)
    800041b6:	f822                	sd	s0,48(sp)
    800041b8:	f426                	sd	s1,40(sp)
    800041ba:	f04a                	sd	s2,32(sp)
    800041bc:	ec4e                	sd	s3,24(sp)
    800041be:	e852                	sd	s4,16(sp)
    800041c0:	e456                	sd	s5,8(sp)
    800041c2:	0080                	addi	s0,sp,64
    800041c4:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    800041c6:	0b000913          	li	s2,176
    800041ca:	032507b3          	mul	a5,a0,s2
    800041ce:	0001d917          	auipc	s2,0x1d
    800041d2:	63290913          	addi	s2,s2,1586 # 80021800 <log>
    800041d6:	993e                	add	s2,s2,a5
    800041d8:	854a                	mv	a0,s2
    800041da:	ffffd097          	auipc	ra,0xffffd
    800041de:	8c6080e7          	jalr	-1850(ra) # 80000aa0 <acquire>
  while(1){
    if(log[dev].committing){
    800041e2:	0001d997          	auipc	s3,0x1d
    800041e6:	61e98993          	addi	s3,s3,1566 # 80021800 <log>
    800041ea:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041ec:	4a79                	li	s4,30
    800041ee:	a039                	j	800041fc <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    800041f0:	85ca                	mv	a1,s2
    800041f2:	854e                	mv	a0,s3
    800041f4:	ffffe097          	auipc	ra,0xffffe
    800041f8:	024080e7          	jalr	36(ra) # 80002218 <sleep>
    if(log[dev].committing){
    800041fc:	54dc                	lw	a5,44(s1)
    800041fe:	fbed                	bnez	a5,800041f0 <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004200:	549c                	lw	a5,40(s1)
    80004202:	0017871b          	addiw	a4,a5,1
    80004206:	0007069b          	sext.w	a3,a4
    8000420a:	0027179b          	slliw	a5,a4,0x2
    8000420e:	9fb9                	addw	a5,a5,a4
    80004210:	0017979b          	slliw	a5,a5,0x1
    80004214:	58d8                	lw	a4,52(s1)
    80004216:	9fb9                	addw	a5,a5,a4
    80004218:	00fa5963          	bge	s4,a5,8000422a <begin_op+0x78>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    8000421c:	85ca                	mv	a1,s2
    8000421e:	854e                	mv	a0,s3
    80004220:	ffffe097          	auipc	ra,0xffffe
    80004224:	ff8080e7          	jalr	-8(ra) # 80002218 <sleep>
    80004228:	bfd1                	j	800041fc <begin_op+0x4a>
    } else {
      /** log.outstanding counts the number of system calls that have reserved log space  */
      log[dev].outstanding += 1;
    8000422a:	0b000513          	li	a0,176
    8000422e:	02aa8ab3          	mul	s5,s5,a0
    80004232:	0001d797          	auipc	a5,0x1d
    80004236:	5ce78793          	addi	a5,a5,1486 # 80021800 <log>
    8000423a:	9abe                	add	s5,s5,a5
    8000423c:	02daa423          	sw	a3,40(s5)
      release(&log[dev].lock);
    80004240:	854a                	mv	a0,s2
    80004242:	ffffd097          	auipc	ra,0xffffd
    80004246:	92e080e7          	jalr	-1746(ra) # 80000b70 <release>
      break;
    }
  }
}
    8000424a:	70e2                	ld	ra,56(sp)
    8000424c:	7442                	ld	s0,48(sp)
    8000424e:	74a2                	ld	s1,40(sp)
    80004250:	7902                	ld	s2,32(sp)
    80004252:	69e2                	ld	s3,24(sp)
    80004254:	6a42                	ld	s4,16(sp)
    80004256:	6aa2                	ld	s5,8(sp)
    80004258:	6121                	addi	sp,sp,64
    8000425a:	8082                	ret

000000008000425c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    8000425c:	715d                	addi	sp,sp,-80
    8000425e:	e486                	sd	ra,72(sp)
    80004260:	e0a2                	sd	s0,64(sp)
    80004262:	fc26                	sd	s1,56(sp)
    80004264:	f84a                	sd	s2,48(sp)
    80004266:	f44e                	sd	s3,40(sp)
    80004268:	f052                	sd	s4,32(sp)
    8000426a:	ec56                	sd	s5,24(sp)
    8000426c:	e85a                	sd	s6,16(sp)
    8000426e:	e45e                	sd	s7,8(sp)
    80004270:	e062                	sd	s8,0(sp)
    80004272:	0880                	addi	s0,sp,80
    80004274:	89aa                	mv	s3,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    80004276:	0b000913          	li	s2,176
    8000427a:	03250933          	mul	s2,a0,s2
    8000427e:	0001d497          	auipc	s1,0x1d
    80004282:	58248493          	addi	s1,s1,1410 # 80021800 <log>
    80004286:	94ca                	add	s1,s1,s2
    80004288:	8526                	mv	a0,s1
    8000428a:	ffffd097          	auipc	ra,0xffffd
    8000428e:	816080e7          	jalr	-2026(ra) # 80000aa0 <acquire>
  log[dev].outstanding -= 1;
    80004292:	549c                	lw	a5,40(s1)
    80004294:	37fd                	addiw	a5,a5,-1
    80004296:	00078a9b          	sext.w	s5,a5
    8000429a:	d49c                	sw	a5,40(s1)
  if(log[dev].committing)
    8000429c:	54dc                	lw	a5,44(s1)
    8000429e:	e3b5                	bnez	a5,80004302 <end_op+0xa6>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    800042a0:	060a9963          	bnez	s5,80004312 <end_op+0xb6>
    do_commit = 1;
    log[dev].committing = 1;
    800042a4:	0b000a13          	li	s4,176
    800042a8:	034987b3          	mul	a5,s3,s4
    800042ac:	0001da17          	auipc	s4,0x1d
    800042b0:	554a0a13          	addi	s4,s4,1364 # 80021800 <log>
    800042b4:	9a3e                	add	s4,s4,a5
    800042b6:	4785                	li	a5,1
    800042b8:	02fa2623          	sw	a5,44(s4)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    800042bc:	8526                	mv	a0,s1
    800042be:	ffffd097          	auipc	ra,0xffffd
    800042c2:	8b2080e7          	jalr	-1870(ra) # 80000b70 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    800042c6:	034a2783          	lw	a5,52(s4)
    800042ca:	06f04d63          	bgtz	a5,80004344 <end_op+0xe8>
    acquire(&log[dev].lock);
    800042ce:	8526                	mv	a0,s1
    800042d0:	ffffc097          	auipc	ra,0xffffc
    800042d4:	7d0080e7          	jalr	2000(ra) # 80000aa0 <acquire>
    log[dev].committing = 0;
    800042d8:	0001d517          	auipc	a0,0x1d
    800042dc:	52850513          	addi	a0,a0,1320 # 80021800 <log>
    800042e0:	0b000793          	li	a5,176
    800042e4:	02f989b3          	mul	s3,s3,a5
    800042e8:	99aa                	add	s3,s3,a0
    800042ea:	0209a623          	sw	zero,44(s3)
    wakeup(&log);
    800042ee:	ffffe097          	auipc	ra,0xffffe
    800042f2:	0aa080e7          	jalr	170(ra) # 80002398 <wakeup>
    release(&log[dev].lock);
    800042f6:	8526                	mv	a0,s1
    800042f8:	ffffd097          	auipc	ra,0xffffd
    800042fc:	878080e7          	jalr	-1928(ra) # 80000b70 <release>
}
    80004300:	a035                	j	8000432c <end_op+0xd0>
    panic("log[dev].committing");
    80004302:	00004517          	auipc	a0,0x4
    80004306:	45650513          	addi	a0,a0,1110 # 80008758 <userret+0x6c8>
    8000430a:	ffffc097          	auipc	ra,0xffffc
    8000430e:	24a080e7          	jalr	586(ra) # 80000554 <panic>
    wakeup(&log);
    80004312:	0001d517          	auipc	a0,0x1d
    80004316:	4ee50513          	addi	a0,a0,1262 # 80021800 <log>
    8000431a:	ffffe097          	auipc	ra,0xffffe
    8000431e:	07e080e7          	jalr	126(ra) # 80002398 <wakeup>
  release(&log[dev].lock);
    80004322:	8526                	mv	a0,s1
    80004324:	ffffd097          	auipc	ra,0xffffd
    80004328:	84c080e7          	jalr	-1972(ra) # 80000b70 <release>
}
    8000432c:	60a6                	ld	ra,72(sp)
    8000432e:	6406                	ld	s0,64(sp)
    80004330:	74e2                	ld	s1,56(sp)
    80004332:	7942                	ld	s2,48(sp)
    80004334:	79a2                	ld	s3,40(sp)
    80004336:	7a02                	ld	s4,32(sp)
    80004338:	6ae2                	ld	s5,24(sp)
    8000433a:	6b42                	ld	s6,16(sp)
    8000433c:	6ba2                	ld	s7,8(sp)
    8000433e:	6c02                	ld	s8,0(sp)
    80004340:	6161                	addi	sp,sp,80
    80004342:	8082                	ret
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004344:	0001d797          	auipc	a5,0x1d
    80004348:	4f478793          	addi	a5,a5,1268 # 80021838 <log+0x38>
    8000434c:	993e                	add	s2,s2,a5
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    8000434e:	00098c1b          	sext.w	s8,s3
    80004352:	0b000b93          	li	s7,176
    80004356:	037987b3          	mul	a5,s3,s7
    8000435a:	0001db97          	auipc	s7,0x1d
    8000435e:	4a6b8b93          	addi	s7,s7,1190 # 80021800 <log>
    80004362:	9bbe                	add	s7,s7,a5
    80004364:	020ba583          	lw	a1,32(s7)
    80004368:	015585bb          	addw	a1,a1,s5
    8000436c:	2585                	addiw	a1,a1,1
    8000436e:	8562                	mv	a0,s8
    80004370:	fffff097          	auipc	ra,0xfffff
    80004374:	ab0080e7          	jalr	-1360(ra) # 80002e20 <bread>
    80004378:	8a2a                	mv	s4,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    8000437a:	00092583          	lw	a1,0(s2)
    8000437e:	8562                	mv	a0,s8
    80004380:	fffff097          	auipc	ra,0xfffff
    80004384:	aa0080e7          	jalr	-1376(ra) # 80002e20 <bread>
    80004388:	8b2a                	mv	s6,a0
    memmove(to->data, from->data, BSIZE);
    8000438a:	40000613          	li	a2,1024
    8000438e:	06050593          	addi	a1,a0,96
    80004392:	060a0513          	addi	a0,s4,96
    80004396:	ffffd097          	auipc	ra,0xffffd
    8000439a:	a34080e7          	jalr	-1484(ra) # 80000dca <memmove>
    bwrite(to);  // write the log
    8000439e:	8552                	mv	a0,s4
    800043a0:	fffff097          	auipc	ra,0xfffff
    800043a4:	b74080e7          	jalr	-1164(ra) # 80002f14 <bwrite>
    brelse(from);
    800043a8:	855a                	mv	a0,s6
    800043aa:	fffff097          	auipc	ra,0xfffff
    800043ae:	baa080e7          	jalr	-1110(ra) # 80002f54 <brelse>
    brelse(to);
    800043b2:	8552                	mv	a0,s4
    800043b4:	fffff097          	auipc	ra,0xfffff
    800043b8:	ba0080e7          	jalr	-1120(ra) # 80002f54 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800043bc:	2a85                	addiw	s5,s5,1
    800043be:	0911                	addi	s2,s2,4
    800043c0:	034ba783          	lw	a5,52(s7)
    800043c4:	fafac0e3          	blt	s5,a5,80004364 <end_op+0x108>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    800043c8:	854e                	mv	a0,s3
    800043ca:	00000097          	auipc	ra,0x0
    800043ce:	bc8080e7          	jalr	-1080(ra) # 80003f92 <write_head>
    install_trans(dev); // Now install writes to home locations
    800043d2:	854e                	mv	a0,s3
    800043d4:	00000097          	auipc	ra,0x0
    800043d8:	c48080e7          	jalr	-952(ra) # 8000401c <install_trans>
    log[dev].lh.n = 0;
    800043dc:	0b000793          	li	a5,176
    800043e0:	02f98733          	mul	a4,s3,a5
    800043e4:	0001d797          	auipc	a5,0x1d
    800043e8:	41c78793          	addi	a5,a5,1052 # 80021800 <log>
    800043ec:	97ba                	add	a5,a5,a4
    800043ee:	0207aa23          	sw	zero,52(a5)
    write_head(dev);    // Erase the transaction from the log
    800043f2:	854e                	mv	a0,s3
    800043f4:	00000097          	auipc	ra,0x0
    800043f8:	b9e080e7          	jalr	-1122(ra) # 80003f92 <write_head>
    800043fc:	bdc9                	j	800042ce <end_op+0x72>

00000000800043fe <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043fe:	7179                	addi	sp,sp,-48
    80004400:	f406                	sd	ra,40(sp)
    80004402:	f022                	sd	s0,32(sp)
    80004404:	ec26                	sd	s1,24(sp)
    80004406:	e84a                	sd	s2,16(sp)
    80004408:	e44e                	sd	s3,8(sp)
    8000440a:	e052                	sd	s4,0(sp)
    8000440c:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    8000440e:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004412:	0b000793          	li	a5,176
    80004416:	02f90733          	mul	a4,s2,a5
    8000441a:	0001d797          	auipc	a5,0x1d
    8000441e:	3e678793          	addi	a5,a5,998 # 80021800 <log>
    80004422:	97ba                	add	a5,a5,a4
    80004424:	5bd4                	lw	a3,52(a5)
    80004426:	47f5                	li	a5,29
    80004428:	0ad7cc63          	blt	a5,a3,800044e0 <log_write+0xe2>
    8000442c:	89aa                	mv	s3,a0
    8000442e:	0001d797          	auipc	a5,0x1d
    80004432:	3d278793          	addi	a5,a5,978 # 80021800 <log>
    80004436:	97ba                	add	a5,a5,a4
    80004438:	53dc                	lw	a5,36(a5)
    8000443a:	37fd                	addiw	a5,a5,-1
    8000443c:	0af6d263          	bge	a3,a5,800044e0 <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004440:	0b000793          	li	a5,176
    80004444:	02f90733          	mul	a4,s2,a5
    80004448:	0001d797          	auipc	a5,0x1d
    8000444c:	3b878793          	addi	a5,a5,952 # 80021800 <log>
    80004450:	97ba                	add	a5,a5,a4
    80004452:	579c                	lw	a5,40(a5)
    80004454:	08f05e63          	blez	a5,800044f0 <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    80004458:	0b000793          	li	a5,176
    8000445c:	02f904b3          	mul	s1,s2,a5
    80004460:	0001da17          	auipc	s4,0x1d
    80004464:	3a0a0a13          	addi	s4,s4,928 # 80021800 <log>
    80004468:	9a26                	add	s4,s4,s1
    8000446a:	8552                	mv	a0,s4
    8000446c:	ffffc097          	auipc	ra,0xffffc
    80004470:	634080e7          	jalr	1588(ra) # 80000aa0 <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004474:	034a2603          	lw	a2,52(s4)
    80004478:	08c05463          	blez	a2,80004500 <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000447c:	00c9a583          	lw	a1,12(s3)
    80004480:	0001d797          	auipc	a5,0x1d
    80004484:	3b878793          	addi	a5,a5,952 # 80021838 <log+0x38>
    80004488:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    8000448a:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000448c:	4394                	lw	a3,0(a5)
    8000448e:	06b68a63          	beq	a3,a1,80004502 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004492:	2705                	addiw	a4,a4,1
    80004494:	0791                	addi	a5,a5,4
    80004496:	fec71be3          	bne	a4,a2,8000448c <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    8000449a:	02c00793          	li	a5,44
    8000449e:	02f907b3          	mul	a5,s2,a5
    800044a2:	97b2                	add	a5,a5,a2
    800044a4:	07b1                	addi	a5,a5,12
    800044a6:	078a                	slli	a5,a5,0x2
    800044a8:	0001d717          	auipc	a4,0x1d
    800044ac:	35870713          	addi	a4,a4,856 # 80021800 <log>
    800044b0:	97ba                	add	a5,a5,a4
    800044b2:	00c9a703          	lw	a4,12(s3)
    800044b6:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    800044b8:	854e                	mv	a0,s3
    800044ba:	fffff097          	auipc	ra,0xfffff
    800044be:	b38080e7          	jalr	-1224(ra) # 80002ff2 <bpin>
    log[dev].lh.n++;
    800044c2:	0b000793          	li	a5,176
    800044c6:	02f90933          	mul	s2,s2,a5
    800044ca:	0001d797          	auipc	a5,0x1d
    800044ce:	33678793          	addi	a5,a5,822 # 80021800 <log>
    800044d2:	993e                	add	s2,s2,a5
    800044d4:	03492783          	lw	a5,52(s2)
    800044d8:	2785                	addiw	a5,a5,1
    800044da:	02f92a23          	sw	a5,52(s2)
    800044de:	a099                	j	80004524 <log_write+0x126>
    panic("too big a transaction");
    800044e0:	00004517          	auipc	a0,0x4
    800044e4:	29050513          	addi	a0,a0,656 # 80008770 <userret+0x6e0>
    800044e8:	ffffc097          	auipc	ra,0xffffc
    800044ec:	06c080e7          	jalr	108(ra) # 80000554 <panic>
    panic("log_write outside of trans");
    800044f0:	00004517          	auipc	a0,0x4
    800044f4:	29850513          	addi	a0,a0,664 # 80008788 <userret+0x6f8>
    800044f8:	ffffc097          	auipc	ra,0xffffc
    800044fc:	05c080e7          	jalr	92(ra) # 80000554 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004500:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    80004502:	02c00793          	li	a5,44
    80004506:	02f907b3          	mul	a5,s2,a5
    8000450a:	97ba                	add	a5,a5,a4
    8000450c:	07b1                	addi	a5,a5,12
    8000450e:	078a                	slli	a5,a5,0x2
    80004510:	0001d697          	auipc	a3,0x1d
    80004514:	2f068693          	addi	a3,a3,752 # 80021800 <log>
    80004518:	97b6                	add	a5,a5,a3
    8000451a:	00c9a683          	lw	a3,12(s3)
    8000451e:	c794                	sw	a3,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004520:	f8e60ce3          	beq	a2,a4,800044b8 <log_write+0xba>
  }
  release(&log[dev].lock);
    80004524:	8552                	mv	a0,s4
    80004526:	ffffc097          	auipc	ra,0xffffc
    8000452a:	64a080e7          	jalr	1610(ra) # 80000b70 <release>
}
    8000452e:	70a2                	ld	ra,40(sp)
    80004530:	7402                	ld	s0,32(sp)
    80004532:	64e2                	ld	s1,24(sp)
    80004534:	6942                	ld	s2,16(sp)
    80004536:	69a2                	ld	s3,8(sp)
    80004538:	6a02                	ld	s4,0(sp)
    8000453a:	6145                	addi	sp,sp,48
    8000453c:	8082                	ret

000000008000453e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000453e:	1101                	addi	sp,sp,-32
    80004540:	ec06                	sd	ra,24(sp)
    80004542:	e822                	sd	s0,16(sp)
    80004544:	e426                	sd	s1,8(sp)
    80004546:	e04a                	sd	s2,0(sp)
    80004548:	1000                	addi	s0,sp,32
    8000454a:	84aa                	mv	s1,a0
    8000454c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000454e:	00004597          	auipc	a1,0x4
    80004552:	25a58593          	addi	a1,a1,602 # 800087a8 <userret+0x718>
    80004556:	0521                	addi	a0,a0,8
    80004558:	ffffc097          	auipc	ra,0xffffc
    8000455c:	474080e7          	jalr	1140(ra) # 800009cc <initlock>
  lk->name = name;
    80004560:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004564:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004568:	0204a823          	sw	zero,48(s1)
}
    8000456c:	60e2                	ld	ra,24(sp)
    8000456e:	6442                	ld	s0,16(sp)
    80004570:	64a2                	ld	s1,8(sp)
    80004572:	6902                	ld	s2,0(sp)
    80004574:	6105                	addi	sp,sp,32
    80004576:	8082                	ret

0000000080004578 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004578:	1101                	addi	sp,sp,-32
    8000457a:	ec06                	sd	ra,24(sp)
    8000457c:	e822                	sd	s0,16(sp)
    8000457e:	e426                	sd	s1,8(sp)
    80004580:	e04a                	sd	s2,0(sp)
    80004582:	1000                	addi	s0,sp,32
    80004584:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004586:	00850913          	addi	s2,a0,8
    8000458a:	854a                	mv	a0,s2
    8000458c:	ffffc097          	auipc	ra,0xffffc
    80004590:	514080e7          	jalr	1300(ra) # 80000aa0 <acquire>
  while (lk->locked) {
    80004594:	409c                	lw	a5,0(s1)
    80004596:	cb89                	beqz	a5,800045a8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004598:	85ca                	mv	a1,s2
    8000459a:	8526                	mv	a0,s1
    8000459c:	ffffe097          	auipc	ra,0xffffe
    800045a0:	c7c080e7          	jalr	-900(ra) # 80002218 <sleep>
  while (lk->locked) {
    800045a4:	409c                	lw	a5,0(s1)
    800045a6:	fbed                	bnez	a5,80004598 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045a8:	4785                	li	a5,1
    800045aa:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045ac:	ffffd097          	auipc	ra,0xffffd
    800045b0:	4ac080e7          	jalr	1196(ra) # 80001a58 <myproc>
    800045b4:	413c                	lw	a5,64(a0)
    800045b6:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    800045b8:	854a                	mv	a0,s2
    800045ba:	ffffc097          	auipc	ra,0xffffc
    800045be:	5b6080e7          	jalr	1462(ra) # 80000b70 <release>
}
    800045c2:	60e2                	ld	ra,24(sp)
    800045c4:	6442                	ld	s0,16(sp)
    800045c6:	64a2                	ld	s1,8(sp)
    800045c8:	6902                	ld	s2,0(sp)
    800045ca:	6105                	addi	sp,sp,32
    800045cc:	8082                	ret

00000000800045ce <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045ce:	1101                	addi	sp,sp,-32
    800045d0:	ec06                	sd	ra,24(sp)
    800045d2:	e822                	sd	s0,16(sp)
    800045d4:	e426                	sd	s1,8(sp)
    800045d6:	e04a                	sd	s2,0(sp)
    800045d8:	1000                	addi	s0,sp,32
    800045da:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045dc:	00850913          	addi	s2,a0,8
    800045e0:	854a                	mv	a0,s2
    800045e2:	ffffc097          	auipc	ra,0xffffc
    800045e6:	4be080e7          	jalr	1214(ra) # 80000aa0 <acquire>
  lk->locked = 0;
    800045ea:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045ee:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    800045f2:	8526                	mv	a0,s1
    800045f4:	ffffe097          	auipc	ra,0xffffe
    800045f8:	da4080e7          	jalr	-604(ra) # 80002398 <wakeup>
  release(&lk->lk);
    800045fc:	854a                	mv	a0,s2
    800045fe:	ffffc097          	auipc	ra,0xffffc
    80004602:	572080e7          	jalr	1394(ra) # 80000b70 <release>
}
    80004606:	60e2                	ld	ra,24(sp)
    80004608:	6442                	ld	s0,16(sp)
    8000460a:	64a2                	ld	s1,8(sp)
    8000460c:	6902                	ld	s2,0(sp)
    8000460e:	6105                	addi	sp,sp,32
    80004610:	8082                	ret

0000000080004612 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004612:	7179                	addi	sp,sp,-48
    80004614:	f406                	sd	ra,40(sp)
    80004616:	f022                	sd	s0,32(sp)
    80004618:	ec26                	sd	s1,24(sp)
    8000461a:	e84a                	sd	s2,16(sp)
    8000461c:	e44e                	sd	s3,8(sp)
    8000461e:	1800                	addi	s0,sp,48
    80004620:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004622:	00850913          	addi	s2,a0,8
    80004626:	854a                	mv	a0,s2
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	478080e7          	jalr	1144(ra) # 80000aa0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004630:	409c                	lw	a5,0(s1)
    80004632:	ef99                	bnez	a5,80004650 <holdingsleep+0x3e>
    80004634:	4481                	li	s1,0
  release(&lk->lk);
    80004636:	854a                	mv	a0,s2
    80004638:	ffffc097          	auipc	ra,0xffffc
    8000463c:	538080e7          	jalr	1336(ra) # 80000b70 <release>
  return r;
}
    80004640:	8526                	mv	a0,s1
    80004642:	70a2                	ld	ra,40(sp)
    80004644:	7402                	ld	s0,32(sp)
    80004646:	64e2                	ld	s1,24(sp)
    80004648:	6942                	ld	s2,16(sp)
    8000464a:	69a2                	ld	s3,8(sp)
    8000464c:	6145                	addi	sp,sp,48
    8000464e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004650:	0304a983          	lw	s3,48(s1)
    80004654:	ffffd097          	auipc	ra,0xffffd
    80004658:	404080e7          	jalr	1028(ra) # 80001a58 <myproc>
    8000465c:	4124                	lw	s1,64(a0)
    8000465e:	413484b3          	sub	s1,s1,s3
    80004662:	0014b493          	seqz	s1,s1
    80004666:	bfc1                	j	80004636 <holdingsleep+0x24>

0000000080004668 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004668:	1141                	addi	sp,sp,-16
    8000466a:	e406                	sd	ra,8(sp)
    8000466c:	e022                	sd	s0,0(sp)
    8000466e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004670:	00004597          	auipc	a1,0x4
    80004674:	14858593          	addi	a1,a1,328 # 800087b8 <userret+0x728>
    80004678:	0001d517          	auipc	a0,0x1d
    8000467c:	38850513          	addi	a0,a0,904 # 80021a00 <ftable>
    80004680:	ffffc097          	auipc	ra,0xffffc
    80004684:	34c080e7          	jalr	844(ra) # 800009cc <initlock>
}
    80004688:	60a2                	ld	ra,8(sp)
    8000468a:	6402                	ld	s0,0(sp)
    8000468c:	0141                	addi	sp,sp,16
    8000468e:	8082                	ret

0000000080004690 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004690:	1101                	addi	sp,sp,-32
    80004692:	ec06                	sd	ra,24(sp)
    80004694:	e822                	sd	s0,16(sp)
    80004696:	e426                	sd	s1,8(sp)
    80004698:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000469a:	0001d517          	auipc	a0,0x1d
    8000469e:	36650513          	addi	a0,a0,870 # 80021a00 <ftable>
    800046a2:	ffffc097          	auipc	ra,0xffffc
    800046a6:	3fe080e7          	jalr	1022(ra) # 80000aa0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046aa:	0001d497          	auipc	s1,0x1d
    800046ae:	37648493          	addi	s1,s1,886 # 80021a20 <ftable+0x20>
    800046b2:	0001e717          	auipc	a4,0x1e
    800046b6:	30e70713          	addi	a4,a4,782 # 800229c0 <ftable+0xfc0>
    if(f->ref == 0){
    800046ba:	40dc                	lw	a5,4(s1)
    800046bc:	cf99                	beqz	a5,800046da <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046be:	02848493          	addi	s1,s1,40
    800046c2:	fee49ce3          	bne	s1,a4,800046ba <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046c6:	0001d517          	auipc	a0,0x1d
    800046ca:	33a50513          	addi	a0,a0,826 # 80021a00 <ftable>
    800046ce:	ffffc097          	auipc	ra,0xffffc
    800046d2:	4a2080e7          	jalr	1186(ra) # 80000b70 <release>
  return 0;
    800046d6:	4481                	li	s1,0
    800046d8:	a819                	j	800046ee <filealloc+0x5e>
      f->ref = 1;
    800046da:	4785                	li	a5,1
    800046dc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046de:	0001d517          	auipc	a0,0x1d
    800046e2:	32250513          	addi	a0,a0,802 # 80021a00 <ftable>
    800046e6:	ffffc097          	auipc	ra,0xffffc
    800046ea:	48a080e7          	jalr	1162(ra) # 80000b70 <release>
}
    800046ee:	8526                	mv	a0,s1
    800046f0:	60e2                	ld	ra,24(sp)
    800046f2:	6442                	ld	s0,16(sp)
    800046f4:	64a2                	ld	s1,8(sp)
    800046f6:	6105                	addi	sp,sp,32
    800046f8:	8082                	ret

00000000800046fa <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046fa:	1101                	addi	sp,sp,-32
    800046fc:	ec06                	sd	ra,24(sp)
    800046fe:	e822                	sd	s0,16(sp)
    80004700:	e426                	sd	s1,8(sp)
    80004702:	1000                	addi	s0,sp,32
    80004704:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004706:	0001d517          	auipc	a0,0x1d
    8000470a:	2fa50513          	addi	a0,a0,762 # 80021a00 <ftable>
    8000470e:	ffffc097          	auipc	ra,0xffffc
    80004712:	392080e7          	jalr	914(ra) # 80000aa0 <acquire>
  if(f->ref < 1)
    80004716:	40dc                	lw	a5,4(s1)
    80004718:	02f05263          	blez	a5,8000473c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000471c:	2785                	addiw	a5,a5,1
    8000471e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004720:	0001d517          	auipc	a0,0x1d
    80004724:	2e050513          	addi	a0,a0,736 # 80021a00 <ftable>
    80004728:	ffffc097          	auipc	ra,0xffffc
    8000472c:	448080e7          	jalr	1096(ra) # 80000b70 <release>
  return f;
}
    80004730:	8526                	mv	a0,s1
    80004732:	60e2                	ld	ra,24(sp)
    80004734:	6442                	ld	s0,16(sp)
    80004736:	64a2                	ld	s1,8(sp)
    80004738:	6105                	addi	sp,sp,32
    8000473a:	8082                	ret
    panic("filedup");
    8000473c:	00004517          	auipc	a0,0x4
    80004740:	08450513          	addi	a0,a0,132 # 800087c0 <userret+0x730>
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	e10080e7          	jalr	-496(ra) # 80000554 <panic>

000000008000474c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000474c:	7139                	addi	sp,sp,-64
    8000474e:	fc06                	sd	ra,56(sp)
    80004750:	f822                	sd	s0,48(sp)
    80004752:	f426                	sd	s1,40(sp)
    80004754:	f04a                	sd	s2,32(sp)
    80004756:	ec4e                	sd	s3,24(sp)
    80004758:	e852                	sd	s4,16(sp)
    8000475a:	e456                	sd	s5,8(sp)
    8000475c:	0080                	addi	s0,sp,64
    8000475e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004760:	0001d517          	auipc	a0,0x1d
    80004764:	2a050513          	addi	a0,a0,672 # 80021a00 <ftable>
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	338080e7          	jalr	824(ra) # 80000aa0 <acquire>
  if(f->ref < 1)
    80004770:	40dc                	lw	a5,4(s1)
    80004772:	06f05563          	blez	a5,800047dc <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004776:	37fd                	addiw	a5,a5,-1
    80004778:	0007871b          	sext.w	a4,a5
    8000477c:	c0dc                	sw	a5,4(s1)
    8000477e:	06e04763          	bgtz	a4,800047ec <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004782:	0004a903          	lw	s2,0(s1)
    80004786:	0094ca83          	lbu	s5,9(s1)
    8000478a:	0104ba03          	ld	s4,16(s1)
    8000478e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004792:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004796:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000479a:	0001d517          	auipc	a0,0x1d
    8000479e:	26650513          	addi	a0,a0,614 # 80021a00 <ftable>
    800047a2:	ffffc097          	auipc	ra,0xffffc
    800047a6:	3ce080e7          	jalr	974(ra) # 80000b70 <release>

  if(ff.type == FD_PIPE){
    800047aa:	4785                	li	a5,1
    800047ac:	06f90163          	beq	s2,a5,8000480e <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047b0:	3979                	addiw	s2,s2,-2
    800047b2:	4785                	li	a5,1
    800047b4:	0527e463          	bltu	a5,s2,800047fc <fileclose+0xb0>
    begin_op(ff.ip->dev);
    800047b8:	0009a503          	lw	a0,0(s3)
    800047bc:	00000097          	auipc	ra,0x0
    800047c0:	9f6080e7          	jalr	-1546(ra) # 800041b2 <begin_op>
    iput(ff.ip);
    800047c4:	854e                	mv	a0,s3
    800047c6:	fffff097          	auipc	ra,0xfffff
    800047ca:	036080e7          	jalr	54(ra) # 800037fc <iput>
    end_op(ff.ip->dev);
    800047ce:	0009a503          	lw	a0,0(s3)
    800047d2:	00000097          	auipc	ra,0x0
    800047d6:	a8a080e7          	jalr	-1398(ra) # 8000425c <end_op>
    800047da:	a00d                	j	800047fc <fileclose+0xb0>
    panic("fileclose");
    800047dc:	00004517          	auipc	a0,0x4
    800047e0:	fec50513          	addi	a0,a0,-20 # 800087c8 <userret+0x738>
    800047e4:	ffffc097          	auipc	ra,0xffffc
    800047e8:	d70080e7          	jalr	-656(ra) # 80000554 <panic>
    release(&ftable.lock);
    800047ec:	0001d517          	auipc	a0,0x1d
    800047f0:	21450513          	addi	a0,a0,532 # 80021a00 <ftable>
    800047f4:	ffffc097          	auipc	ra,0xffffc
    800047f8:	37c080e7          	jalr	892(ra) # 80000b70 <release>
  }
}
    800047fc:	70e2                	ld	ra,56(sp)
    800047fe:	7442                	ld	s0,48(sp)
    80004800:	74a2                	ld	s1,40(sp)
    80004802:	7902                	ld	s2,32(sp)
    80004804:	69e2                	ld	s3,24(sp)
    80004806:	6a42                	ld	s4,16(sp)
    80004808:	6aa2                	ld	s5,8(sp)
    8000480a:	6121                	addi	sp,sp,64
    8000480c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000480e:	85d6                	mv	a1,s5
    80004810:	8552                	mv	a0,s4
    80004812:	00000097          	auipc	ra,0x0
    80004816:	376080e7          	jalr	886(ra) # 80004b88 <pipeclose>
    8000481a:	b7cd                	j	800047fc <fileclose+0xb0>

000000008000481c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000481c:	715d                	addi	sp,sp,-80
    8000481e:	e486                	sd	ra,72(sp)
    80004820:	e0a2                	sd	s0,64(sp)
    80004822:	fc26                	sd	s1,56(sp)
    80004824:	f84a                	sd	s2,48(sp)
    80004826:	f44e                	sd	s3,40(sp)
    80004828:	0880                	addi	s0,sp,80
    8000482a:	84aa                	mv	s1,a0
    8000482c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000482e:	ffffd097          	auipc	ra,0xffffd
    80004832:	22a080e7          	jalr	554(ra) # 80001a58 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004836:	409c                	lw	a5,0(s1)
    80004838:	37f9                	addiw	a5,a5,-2
    8000483a:	4705                	li	a4,1
    8000483c:	04f76763          	bltu	a4,a5,8000488a <filestat+0x6e>
    80004840:	892a                	mv	s2,a0
    ilock(f->ip);
    80004842:	6c88                	ld	a0,24(s1)
    80004844:	fffff097          	auipc	ra,0xfffff
    80004848:	ea8080e7          	jalr	-344(ra) # 800036ec <ilock>
    stati(f->ip, &st);
    8000484c:	fb840593          	addi	a1,s0,-72
    80004850:	6c88                	ld	a0,24(s1)
    80004852:	fffff097          	auipc	ra,0xfffff
    80004856:	1da080e7          	jalr	474(ra) # 80003a2c <stati>
    iunlock(f->ip);
    8000485a:	6c88                	ld	a0,24(s1)
    8000485c:	fffff097          	auipc	ra,0xfffff
    80004860:	f54080e7          	jalr	-172(ra) # 800037b0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004864:	46e1                	li	a3,24
    80004866:	fb840613          	addi	a2,s0,-72
    8000486a:	85ce                	mv	a1,s3
    8000486c:	05893503          	ld	a0,88(s2)
    80004870:	ffffd097          	auipc	ra,0xffffd
    80004874:	eda080e7          	jalr	-294(ra) # 8000174a <copyout>
    80004878:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000487c:	60a6                	ld	ra,72(sp)
    8000487e:	6406                	ld	s0,64(sp)
    80004880:	74e2                	ld	s1,56(sp)
    80004882:	7942                	ld	s2,48(sp)
    80004884:	79a2                	ld	s3,40(sp)
    80004886:	6161                	addi	sp,sp,80
    80004888:	8082                	ret
  return -1;
    8000488a:	557d                	li	a0,-1
    8000488c:	bfc5                	j	8000487c <filestat+0x60>

000000008000488e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000488e:	7179                	addi	sp,sp,-48
    80004890:	f406                	sd	ra,40(sp)
    80004892:	f022                	sd	s0,32(sp)
    80004894:	ec26                	sd	s1,24(sp)
    80004896:	e84a                	sd	s2,16(sp)
    80004898:	e44e                	sd	s3,8(sp)
    8000489a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000489c:	00854783          	lbu	a5,8(a0)
    800048a0:	c7c5                	beqz	a5,80004948 <fileread+0xba>
    800048a2:	84aa                	mv	s1,a0
    800048a4:	89ae                	mv	s3,a1
    800048a6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048a8:	411c                	lw	a5,0(a0)
    800048aa:	4705                	li	a4,1
    800048ac:	04e78963          	beq	a5,a4,800048fe <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048b0:	470d                	li	a4,3
    800048b2:	04e78d63          	beq	a5,a4,8000490c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800048b6:	4709                	li	a4,2
    800048b8:	08e79063          	bne	a5,a4,80004938 <fileread+0xaa>
    ilock(f->ip);
    800048bc:	6d08                	ld	a0,24(a0)
    800048be:	fffff097          	auipc	ra,0xfffff
    800048c2:	e2e080e7          	jalr	-466(ra) # 800036ec <ilock>
    //printf("file/fileread():read from %s\n", f->ip->target);
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048c6:	874a                	mv	a4,s2
    800048c8:	5094                	lw	a3,32(s1)
    800048ca:	864e                	mv	a2,s3
    800048cc:	4585                	li	a1,1
    800048ce:	6c88                	ld	a0,24(s1)
    800048d0:	fffff097          	auipc	ra,0xfffff
    800048d4:	186080e7          	jalr	390(ra) # 80003a56 <readi>
    800048d8:	892a                	mv	s2,a0
    800048da:	00a05563          	blez	a0,800048e4 <fileread+0x56>
      f->off += r;
    800048de:	509c                	lw	a5,32(s1)
    800048e0:	9fa9                	addw	a5,a5,a0
    800048e2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048e4:	6c88                	ld	a0,24(s1)
    800048e6:	fffff097          	auipc	ra,0xfffff
    800048ea:	eca080e7          	jalr	-310(ra) # 800037b0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048ee:	854a                	mv	a0,s2
    800048f0:	70a2                	ld	ra,40(sp)
    800048f2:	7402                	ld	s0,32(sp)
    800048f4:	64e2                	ld	s1,24(sp)
    800048f6:	6942                	ld	s2,16(sp)
    800048f8:	69a2                	ld	s3,8(sp)
    800048fa:	6145                	addi	sp,sp,48
    800048fc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048fe:	6908                	ld	a0,16(a0)
    80004900:	00000097          	auipc	ra,0x0
    80004904:	406080e7          	jalr	1030(ra) # 80004d06 <piperead>
    80004908:	892a                	mv	s2,a0
    8000490a:	b7d5                	j	800048ee <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000490c:	02451783          	lh	a5,36(a0)
    80004910:	03079693          	slli	a3,a5,0x30
    80004914:	92c1                	srli	a3,a3,0x30
    80004916:	4725                	li	a4,9
    80004918:	02d76a63          	bltu	a4,a3,8000494c <fileread+0xbe>
    8000491c:	0792                	slli	a5,a5,0x4
    8000491e:	0001d717          	auipc	a4,0x1d
    80004922:	04270713          	addi	a4,a4,66 # 80021960 <devsw>
    80004926:	97ba                	add	a5,a5,a4
    80004928:	639c                	ld	a5,0(a5)
    8000492a:	c39d                	beqz	a5,80004950 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    8000492c:	86b2                	mv	a3,a2
    8000492e:	862e                	mv	a2,a1
    80004930:	4585                	li	a1,1
    80004932:	9782                	jalr	a5
    80004934:	892a                	mv	s2,a0
    80004936:	bf65                	j	800048ee <fileread+0x60>
    panic("fileread");
    80004938:	00004517          	auipc	a0,0x4
    8000493c:	ea050513          	addi	a0,a0,-352 # 800087d8 <userret+0x748>
    80004940:	ffffc097          	auipc	ra,0xffffc
    80004944:	c14080e7          	jalr	-1004(ra) # 80000554 <panic>
    return -1;
    80004948:	597d                	li	s2,-1
    8000494a:	b755                	j	800048ee <fileread+0x60>
      return -1;
    8000494c:	597d                	li	s2,-1
    8000494e:	b745                	j	800048ee <fileread+0x60>
    80004950:	597d                	li	s2,-1
    80004952:	bf71                	j	800048ee <fileread+0x60>

0000000080004954 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004954:	00954783          	lbu	a5,9(a0)
    80004958:	14078663          	beqz	a5,80004aa4 <filewrite+0x150>
{
    8000495c:	715d                	addi	sp,sp,-80
    8000495e:	e486                	sd	ra,72(sp)
    80004960:	e0a2                	sd	s0,64(sp)
    80004962:	fc26                	sd	s1,56(sp)
    80004964:	f84a                	sd	s2,48(sp)
    80004966:	f44e                	sd	s3,40(sp)
    80004968:	f052                	sd	s4,32(sp)
    8000496a:	ec56                	sd	s5,24(sp)
    8000496c:	e85a                	sd	s6,16(sp)
    8000496e:	e45e                	sd	s7,8(sp)
    80004970:	e062                	sd	s8,0(sp)
    80004972:	0880                	addi	s0,sp,80
    80004974:	84aa                	mv	s1,a0
    80004976:	8aae                	mv	s5,a1
    80004978:	8a32                	mv	s4,a2
    return -1;
  if(f->type == FD_PIPE){
    8000497a:	411c                	lw	a5,0(a0)
    8000497c:	4705                	li	a4,1
    8000497e:	02e78263          	beq	a5,a4,800049a2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004982:	470d                	li	a4,3
    80004984:	02e78563          	beq	a5,a4,800049ae <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004988:	4709                	li	a4,2
    8000498a:	10e79563          	bne	a5,a4,80004a94 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000498e:	0ec05f63          	blez	a2,80004a8c <filewrite+0x138>
    int i = 0;
    80004992:	4981                	li	s3,0
    80004994:	6b05                	lui	s6,0x1
    80004996:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000499a:	6b85                	lui	s7,0x1
    8000499c:	c00b8b9b          	addiw	s7,s7,-1024
    800049a0:	a851                	j	80004a34 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800049a2:	6908                	ld	a0,16(a0)
    800049a4:	00000097          	auipc	ra,0x0
    800049a8:	254080e7          	jalr	596(ra) # 80004bf8 <pipewrite>
    800049ac:	a865                	j	80004a64 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049ae:	02451783          	lh	a5,36(a0)
    800049b2:	03079693          	slli	a3,a5,0x30
    800049b6:	92c1                	srli	a3,a3,0x30
    800049b8:	4725                	li	a4,9
    800049ba:	0ed76763          	bltu	a4,a3,80004aa8 <filewrite+0x154>
    800049be:	0792                	slli	a5,a5,0x4
    800049c0:	0001d717          	auipc	a4,0x1d
    800049c4:	fa070713          	addi	a4,a4,-96 # 80021960 <devsw>
    800049c8:	97ba                	add	a5,a5,a4
    800049ca:	679c                	ld	a5,8(a5)
    800049cc:	c3e5                	beqz	a5,80004aac <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    800049ce:	86b2                	mv	a3,a2
    800049d0:	862e                	mv	a2,a1
    800049d2:	4585                	li	a1,1
    800049d4:	9782                	jalr	a5
    800049d6:	a079                	j	80004a64 <filewrite+0x110>
    800049d8:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    800049dc:	6c9c                	ld	a5,24(s1)
    800049de:	4388                	lw	a0,0(a5)
    800049e0:	fffff097          	auipc	ra,0xfffff
    800049e4:	7d2080e7          	jalr	2002(ra) # 800041b2 <begin_op>
      ilock(f->ip);
    800049e8:	6c88                	ld	a0,24(s1)
    800049ea:	fffff097          	auipc	ra,0xfffff
    800049ee:	d02080e7          	jalr	-766(ra) # 800036ec <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049f2:	8762                	mv	a4,s8
    800049f4:	5094                	lw	a3,32(s1)
    800049f6:	01598633          	add	a2,s3,s5
    800049fa:	4585                	li	a1,1
    800049fc:	6c88                	ld	a0,24(s1)
    800049fe:	fffff097          	auipc	ra,0xfffff
    80004a02:	14e080e7          	jalr	334(ra) # 80003b4c <writei>
    80004a06:	892a                	mv	s2,a0
    80004a08:	02a05e63          	blez	a0,80004a44 <filewrite+0xf0>
        f->off += r;
    80004a0c:	509c                	lw	a5,32(s1)
    80004a0e:	9fa9                	addw	a5,a5,a0
    80004a10:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004a12:	6c88                	ld	a0,24(s1)
    80004a14:	fffff097          	auipc	ra,0xfffff
    80004a18:	d9c080e7          	jalr	-612(ra) # 800037b0 <iunlock>
      end_op(f->ip->dev);
    80004a1c:	6c9c                	ld	a5,24(s1)
    80004a1e:	4388                	lw	a0,0(a5)
    80004a20:	00000097          	auipc	ra,0x0
    80004a24:	83c080e7          	jalr	-1988(ra) # 8000425c <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004a28:	052c1a63          	bne	s8,s2,80004a7c <filewrite+0x128>
        panic("short filewrite");
      i += r;
    80004a2c:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80004a30:	0349d763          	bge	s3,s4,80004a5e <filewrite+0x10a>
      int n1 = n - i;
    80004a34:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a38:	893e                	mv	s2,a5
    80004a3a:	2781                	sext.w	a5,a5
    80004a3c:	f8fb5ee3          	bge	s6,a5,800049d8 <filewrite+0x84>
    80004a40:	895e                	mv	s2,s7
    80004a42:	bf59                	j	800049d8 <filewrite+0x84>
      iunlock(f->ip);
    80004a44:	6c88                	ld	a0,24(s1)
    80004a46:	fffff097          	auipc	ra,0xfffff
    80004a4a:	d6a080e7          	jalr	-662(ra) # 800037b0 <iunlock>
      end_op(f->ip->dev);
    80004a4e:	6c9c                	ld	a5,24(s1)
    80004a50:	4388                	lw	a0,0(a5)
    80004a52:	00000097          	auipc	ra,0x0
    80004a56:	80a080e7          	jalr	-2038(ra) # 8000425c <end_op>
      if(r < 0)
    80004a5a:	fc0957e3          	bgez	s2,80004a28 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004a5e:	8552                	mv	a0,s4
    80004a60:	033a1863          	bne	s4,s3,80004a90 <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a64:	60a6                	ld	ra,72(sp)
    80004a66:	6406                	ld	s0,64(sp)
    80004a68:	74e2                	ld	s1,56(sp)
    80004a6a:	7942                	ld	s2,48(sp)
    80004a6c:	79a2                	ld	s3,40(sp)
    80004a6e:	7a02                	ld	s4,32(sp)
    80004a70:	6ae2                	ld	s5,24(sp)
    80004a72:	6b42                	ld	s6,16(sp)
    80004a74:	6ba2                	ld	s7,8(sp)
    80004a76:	6c02                	ld	s8,0(sp)
    80004a78:	6161                	addi	sp,sp,80
    80004a7a:	8082                	ret
        panic("short filewrite");
    80004a7c:	00004517          	auipc	a0,0x4
    80004a80:	d6c50513          	addi	a0,a0,-660 # 800087e8 <userret+0x758>
    80004a84:	ffffc097          	auipc	ra,0xffffc
    80004a88:	ad0080e7          	jalr	-1328(ra) # 80000554 <panic>
    int i = 0;
    80004a8c:	4981                	li	s3,0
    80004a8e:	bfc1                	j	80004a5e <filewrite+0x10a>
    ret = (i == n ? n : -1);
    80004a90:	557d                	li	a0,-1
    80004a92:	bfc9                	j	80004a64 <filewrite+0x110>
    panic("filewrite");
    80004a94:	00004517          	auipc	a0,0x4
    80004a98:	d6450513          	addi	a0,a0,-668 # 800087f8 <userret+0x768>
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	ab8080e7          	jalr	-1352(ra) # 80000554 <panic>
    return -1;
    80004aa4:	557d                	li	a0,-1
}
    80004aa6:	8082                	ret
      return -1;
    80004aa8:	557d                	li	a0,-1
    80004aaa:	bf6d                	j	80004a64 <filewrite+0x110>
    80004aac:	557d                	li	a0,-1
    80004aae:	bf5d                	j	80004a64 <filewrite+0x110>

0000000080004ab0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ab0:	7179                	addi	sp,sp,-48
    80004ab2:	f406                	sd	ra,40(sp)
    80004ab4:	f022                	sd	s0,32(sp)
    80004ab6:	ec26                	sd	s1,24(sp)
    80004ab8:	e84a                	sd	s2,16(sp)
    80004aba:	e44e                	sd	s3,8(sp)
    80004abc:	e052                	sd	s4,0(sp)
    80004abe:	1800                	addi	s0,sp,48
    80004ac0:	84aa                	mv	s1,a0
    80004ac2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ac4:	0005b023          	sd	zero,0(a1)
    80004ac8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004acc:	00000097          	auipc	ra,0x0
    80004ad0:	bc4080e7          	jalr	-1084(ra) # 80004690 <filealloc>
    80004ad4:	e088                	sd	a0,0(s1)
    80004ad6:	c549                	beqz	a0,80004b60 <pipealloc+0xb0>
    80004ad8:	00000097          	auipc	ra,0x0
    80004adc:	bb8080e7          	jalr	-1096(ra) # 80004690 <filealloc>
    80004ae0:	00aa3023          	sd	a0,0(s4)
    80004ae4:	c925                	beqz	a0,80004b54 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	e86080e7          	jalr	-378(ra) # 8000096c <kalloc>
    80004aee:	892a                	mv	s2,a0
    80004af0:	cd39                	beqz	a0,80004b4e <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    80004af2:	4985                	li	s3,1
    80004af4:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004af8:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004afc:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004b00:	22052023          	sw	zero,544(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    80004b04:	02000613          	li	a2,32
    80004b08:	4581                	li	a1,0
    80004b0a:	ffffc097          	auipc	ra,0xffffc
    80004b0e:	264080e7          	jalr	612(ra) # 80000d6e <memset>
  (*f0)->type = FD_PIPE;
    80004b12:	609c                	ld	a5,0(s1)
    80004b14:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b18:	609c                	ld	a5,0(s1)
    80004b1a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b1e:	609c                	ld	a5,0(s1)
    80004b20:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b24:	609c                	ld	a5,0(s1)
    80004b26:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b2a:	000a3783          	ld	a5,0(s4)
    80004b2e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b32:	000a3783          	ld	a5,0(s4)
    80004b36:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b3a:	000a3783          	ld	a5,0(s4)
    80004b3e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b42:	000a3783          	ld	a5,0(s4)
    80004b46:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b4a:	4501                	li	a0,0
    80004b4c:	a025                	j	80004b74 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b4e:	6088                	ld	a0,0(s1)
    80004b50:	e501                	bnez	a0,80004b58 <pipealloc+0xa8>
    80004b52:	a039                	j	80004b60 <pipealloc+0xb0>
    80004b54:	6088                	ld	a0,0(s1)
    80004b56:	c51d                	beqz	a0,80004b84 <pipealloc+0xd4>
    fileclose(*f0);
    80004b58:	00000097          	auipc	ra,0x0
    80004b5c:	bf4080e7          	jalr	-1036(ra) # 8000474c <fileclose>
  if(*f1)
    80004b60:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b64:	557d                	li	a0,-1
  if(*f1)
    80004b66:	c799                	beqz	a5,80004b74 <pipealloc+0xc4>
    fileclose(*f1);
    80004b68:	853e                	mv	a0,a5
    80004b6a:	00000097          	auipc	ra,0x0
    80004b6e:	be2080e7          	jalr	-1054(ra) # 8000474c <fileclose>
  return -1;
    80004b72:	557d                	li	a0,-1
}
    80004b74:	70a2                	ld	ra,40(sp)
    80004b76:	7402                	ld	s0,32(sp)
    80004b78:	64e2                	ld	s1,24(sp)
    80004b7a:	6942                	ld	s2,16(sp)
    80004b7c:	69a2                	ld	s3,8(sp)
    80004b7e:	6a02                	ld	s4,0(sp)
    80004b80:	6145                	addi	sp,sp,48
    80004b82:	8082                	ret
  return -1;
    80004b84:	557d                	li	a0,-1
    80004b86:	b7fd                	j	80004b74 <pipealloc+0xc4>

0000000080004b88 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b88:	1101                	addi	sp,sp,-32
    80004b8a:	ec06                	sd	ra,24(sp)
    80004b8c:	e822                	sd	s0,16(sp)
    80004b8e:	e426                	sd	s1,8(sp)
    80004b90:	e04a                	sd	s2,0(sp)
    80004b92:	1000                	addi	s0,sp,32
    80004b94:	84aa                	mv	s1,a0
    80004b96:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b98:	ffffc097          	auipc	ra,0xffffc
    80004b9c:	f08080e7          	jalr	-248(ra) # 80000aa0 <acquire>
  if(writable){
    80004ba0:	02090d63          	beqz	s2,80004bda <pipeclose+0x52>
    pi->writeopen = 0;
    80004ba4:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004ba8:	22048513          	addi	a0,s1,544
    80004bac:	ffffd097          	auipc	ra,0xffffd
    80004bb0:	7ec080e7          	jalr	2028(ra) # 80002398 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bb4:	2284b783          	ld	a5,552(s1)
    80004bb8:	eb95                	bnez	a5,80004bec <pipeclose+0x64>
    release(&pi->lock);
    80004bba:	8526                	mv	a0,s1
    80004bbc:	ffffc097          	auipc	ra,0xffffc
    80004bc0:	fb4080e7          	jalr	-76(ra) # 80000b70 <release>
    kfree((char*)pi);
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	ffffc097          	auipc	ra,0xffffc
    80004bca:	caa080e7          	jalr	-854(ra) # 80000870 <kfree>
  } else
    release(&pi->lock);
}
    80004bce:	60e2                	ld	ra,24(sp)
    80004bd0:	6442                	ld	s0,16(sp)
    80004bd2:	64a2                	ld	s1,8(sp)
    80004bd4:	6902                	ld	s2,0(sp)
    80004bd6:	6105                	addi	sp,sp,32
    80004bd8:	8082                	ret
    pi->readopen = 0;
    80004bda:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004bde:	22448513          	addi	a0,s1,548
    80004be2:	ffffd097          	auipc	ra,0xffffd
    80004be6:	7b6080e7          	jalr	1974(ra) # 80002398 <wakeup>
    80004bea:	b7e9                	j	80004bb4 <pipeclose+0x2c>
    release(&pi->lock);
    80004bec:	8526                	mv	a0,s1
    80004bee:	ffffc097          	auipc	ra,0xffffc
    80004bf2:	f82080e7          	jalr	-126(ra) # 80000b70 <release>
}
    80004bf6:	bfe1                	j	80004bce <pipeclose+0x46>

0000000080004bf8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bf8:	711d                	addi	sp,sp,-96
    80004bfa:	ec86                	sd	ra,88(sp)
    80004bfc:	e8a2                	sd	s0,80(sp)
    80004bfe:	e4a6                	sd	s1,72(sp)
    80004c00:	e0ca                	sd	s2,64(sp)
    80004c02:	fc4e                	sd	s3,56(sp)
    80004c04:	f852                	sd	s4,48(sp)
    80004c06:	f456                	sd	s5,40(sp)
    80004c08:	f05a                	sd	s6,32(sp)
    80004c0a:	ec5e                	sd	s7,24(sp)
    80004c0c:	e862                	sd	s8,16(sp)
    80004c0e:	1080                	addi	s0,sp,96
    80004c10:	84aa                	mv	s1,a0
    80004c12:	8aae                	mv	s5,a1
    80004c14:	8a32                	mv	s4,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004c16:	ffffd097          	auipc	ra,0xffffd
    80004c1a:	e42080e7          	jalr	-446(ra) # 80001a58 <myproc>
    80004c1e:	8baa                	mv	s7,a0

  acquire(&pi->lock);
    80004c20:	8526                	mv	a0,s1
    80004c22:	ffffc097          	auipc	ra,0xffffc
    80004c26:	e7e080e7          	jalr	-386(ra) # 80000aa0 <acquire>
  for(i = 0; i < n; i++){
    80004c2a:	09405f63          	blez	s4,80004cc8 <pipewrite+0xd0>
    80004c2e:	fffa0b1b          	addiw	s6,s4,-1
    80004c32:	1b02                	slli	s6,s6,0x20
    80004c34:	020b5b13          	srli	s6,s6,0x20
    80004c38:	001a8793          	addi	a5,s5,1
    80004c3c:	9b3e                	add	s6,s6,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c3e:	22048993          	addi	s3,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004c42:	22448913          	addi	s2,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c46:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c48:	2204a783          	lw	a5,544(s1)
    80004c4c:	2244a703          	lw	a4,548(s1)
    80004c50:	2007879b          	addiw	a5,a5,512
    80004c54:	02f71e63          	bne	a4,a5,80004c90 <pipewrite+0x98>
      if(pi->readopen == 0 || myproc()->killed){
    80004c58:	2284a783          	lw	a5,552(s1)
    80004c5c:	c3d9                	beqz	a5,80004ce2 <pipewrite+0xea>
    80004c5e:	ffffd097          	auipc	ra,0xffffd
    80004c62:	dfa080e7          	jalr	-518(ra) # 80001a58 <myproc>
    80004c66:	5d1c                	lw	a5,56(a0)
    80004c68:	efad                	bnez	a5,80004ce2 <pipewrite+0xea>
      wakeup(&pi->nread);
    80004c6a:	854e                	mv	a0,s3
    80004c6c:	ffffd097          	auipc	ra,0xffffd
    80004c70:	72c080e7          	jalr	1836(ra) # 80002398 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c74:	85a6                	mv	a1,s1
    80004c76:	854a                	mv	a0,s2
    80004c78:	ffffd097          	auipc	ra,0xffffd
    80004c7c:	5a0080e7          	jalr	1440(ra) # 80002218 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c80:	2204a783          	lw	a5,544(s1)
    80004c84:	2244a703          	lw	a4,548(s1)
    80004c88:	2007879b          	addiw	a5,a5,512
    80004c8c:	fcf706e3          	beq	a4,a5,80004c58 <pipewrite+0x60>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c90:	4685                	li	a3,1
    80004c92:	8656                	mv	a2,s5
    80004c94:	faf40593          	addi	a1,s0,-81
    80004c98:	058bb503          	ld	a0,88(s7) # 1058 <_entry-0x7fffefa8>
    80004c9c:	ffffd097          	auipc	ra,0xffffd
    80004ca0:	b3a080e7          	jalr	-1222(ra) # 800017d6 <copyin>
    80004ca4:	03850263          	beq	a0,s8,80004cc8 <pipewrite+0xd0>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ca8:	2244a783          	lw	a5,548(s1)
    80004cac:	0017871b          	addiw	a4,a5,1
    80004cb0:	22e4a223          	sw	a4,548(s1)
    80004cb4:	1ff7f793          	andi	a5,a5,511
    80004cb8:	97a6                	add	a5,a5,s1
    80004cba:	faf44703          	lbu	a4,-81(s0)
    80004cbe:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004cc2:	0a85                	addi	s5,s5,1
    80004cc4:	f96a92e3          	bne	s5,s6,80004c48 <pipewrite+0x50>
  }
  wakeup(&pi->nread);
    80004cc8:	22048513          	addi	a0,s1,544
    80004ccc:	ffffd097          	auipc	ra,0xffffd
    80004cd0:	6cc080e7          	jalr	1740(ra) # 80002398 <wakeup>
  release(&pi->lock);
    80004cd4:	8526                	mv	a0,s1
    80004cd6:	ffffc097          	auipc	ra,0xffffc
    80004cda:	e9a080e7          	jalr	-358(ra) # 80000b70 <release>
  return n;
    80004cde:	8552                	mv	a0,s4
    80004ce0:	a039                	j	80004cee <pipewrite+0xf6>
        release(&pi->lock);
    80004ce2:	8526                	mv	a0,s1
    80004ce4:	ffffc097          	auipc	ra,0xffffc
    80004ce8:	e8c080e7          	jalr	-372(ra) # 80000b70 <release>
        return -1;
    80004cec:	557d                	li	a0,-1
}
    80004cee:	60e6                	ld	ra,88(sp)
    80004cf0:	6446                	ld	s0,80(sp)
    80004cf2:	64a6                	ld	s1,72(sp)
    80004cf4:	6906                	ld	s2,64(sp)
    80004cf6:	79e2                	ld	s3,56(sp)
    80004cf8:	7a42                	ld	s4,48(sp)
    80004cfa:	7aa2                	ld	s5,40(sp)
    80004cfc:	7b02                	ld	s6,32(sp)
    80004cfe:	6be2                	ld	s7,24(sp)
    80004d00:	6c42                	ld	s8,16(sp)
    80004d02:	6125                	addi	sp,sp,96
    80004d04:	8082                	ret

0000000080004d06 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d06:	715d                	addi	sp,sp,-80
    80004d08:	e486                	sd	ra,72(sp)
    80004d0a:	e0a2                	sd	s0,64(sp)
    80004d0c:	fc26                	sd	s1,56(sp)
    80004d0e:	f84a                	sd	s2,48(sp)
    80004d10:	f44e                	sd	s3,40(sp)
    80004d12:	f052                	sd	s4,32(sp)
    80004d14:	ec56                	sd	s5,24(sp)
    80004d16:	e85a                	sd	s6,16(sp)
    80004d18:	0880                	addi	s0,sp,80
    80004d1a:	84aa                	mv	s1,a0
    80004d1c:	892e                	mv	s2,a1
    80004d1e:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004d20:	ffffd097          	auipc	ra,0xffffd
    80004d24:	d38080e7          	jalr	-712(ra) # 80001a58 <myproc>
    80004d28:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004d2a:	8526                	mv	a0,s1
    80004d2c:	ffffc097          	auipc	ra,0xffffc
    80004d30:	d74080e7          	jalr	-652(ra) # 80000aa0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d34:	2204a703          	lw	a4,544(s1)
    80004d38:	2244a783          	lw	a5,548(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d3c:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d40:	02f71763          	bne	a4,a5,80004d6e <piperead+0x68>
    80004d44:	22c4a783          	lw	a5,556(s1)
    80004d48:	c39d                	beqz	a5,80004d6e <piperead+0x68>
    if(myproc()->killed){
    80004d4a:	ffffd097          	auipc	ra,0xffffd
    80004d4e:	d0e080e7          	jalr	-754(ra) # 80001a58 <myproc>
    80004d52:	5d1c                	lw	a5,56(a0)
    80004d54:	ebc1                	bnez	a5,80004de4 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d56:	85a6                	mv	a1,s1
    80004d58:	854e                	mv	a0,s3
    80004d5a:	ffffd097          	auipc	ra,0xffffd
    80004d5e:	4be080e7          	jalr	1214(ra) # 80002218 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d62:	2204a703          	lw	a4,544(s1)
    80004d66:	2244a783          	lw	a5,548(s1)
    80004d6a:	fcf70de3          	beq	a4,a5,80004d44 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d6e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d70:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d72:	05405363          	blez	s4,80004db8 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004d76:	2204a783          	lw	a5,544(s1)
    80004d7a:	2244a703          	lw	a4,548(s1)
    80004d7e:	02f70d63          	beq	a4,a5,80004db8 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d82:	0017871b          	addiw	a4,a5,1
    80004d86:	22e4a023          	sw	a4,544(s1)
    80004d8a:	1ff7f793          	andi	a5,a5,511
    80004d8e:	97a6                	add	a5,a5,s1
    80004d90:	0207c783          	lbu	a5,32(a5)
    80004d94:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d98:	4685                	li	a3,1
    80004d9a:	fbf40613          	addi	a2,s0,-65
    80004d9e:	85ca                	mv	a1,s2
    80004da0:	058ab503          	ld	a0,88(s5)
    80004da4:	ffffd097          	auipc	ra,0xffffd
    80004da8:	9a6080e7          	jalr	-1626(ra) # 8000174a <copyout>
    80004dac:	01650663          	beq	a0,s6,80004db8 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004db0:	2985                	addiw	s3,s3,1
    80004db2:	0905                	addi	s2,s2,1
    80004db4:	fd3a11e3          	bne	s4,s3,80004d76 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004db8:	22448513          	addi	a0,s1,548
    80004dbc:	ffffd097          	auipc	ra,0xffffd
    80004dc0:	5dc080e7          	jalr	1500(ra) # 80002398 <wakeup>
  release(&pi->lock);
    80004dc4:	8526                	mv	a0,s1
    80004dc6:	ffffc097          	auipc	ra,0xffffc
    80004dca:	daa080e7          	jalr	-598(ra) # 80000b70 <release>
  return i;
}
    80004dce:	854e                	mv	a0,s3
    80004dd0:	60a6                	ld	ra,72(sp)
    80004dd2:	6406                	ld	s0,64(sp)
    80004dd4:	74e2                	ld	s1,56(sp)
    80004dd6:	7942                	ld	s2,48(sp)
    80004dd8:	79a2                	ld	s3,40(sp)
    80004dda:	7a02                	ld	s4,32(sp)
    80004ddc:	6ae2                	ld	s5,24(sp)
    80004dde:	6b42                	ld	s6,16(sp)
    80004de0:	6161                	addi	sp,sp,80
    80004de2:	8082                	ret
      release(&pi->lock);
    80004de4:	8526                	mv	a0,s1
    80004de6:	ffffc097          	auipc	ra,0xffffc
    80004dea:	d8a080e7          	jalr	-630(ra) # 80000b70 <release>
      return -1;
    80004dee:	59fd                	li	s3,-1
    80004df0:	bff9                	j	80004dce <piperead+0xc8>

0000000080004df2 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004df2:	de010113          	addi	sp,sp,-544
    80004df6:	20113c23          	sd	ra,536(sp)
    80004dfa:	20813823          	sd	s0,528(sp)
    80004dfe:	20913423          	sd	s1,520(sp)
    80004e02:	21213023          	sd	s2,512(sp)
    80004e06:	ffce                	sd	s3,504(sp)
    80004e08:	fbd2                	sd	s4,496(sp)
    80004e0a:	f7d6                	sd	s5,488(sp)
    80004e0c:	f3da                	sd	s6,480(sp)
    80004e0e:	efde                	sd	s7,472(sp)
    80004e10:	ebe2                	sd	s8,464(sp)
    80004e12:	e7e6                	sd	s9,456(sp)
    80004e14:	e3ea                	sd	s10,448(sp)
    80004e16:	ff6e                	sd	s11,440(sp)
    80004e18:	1400                	addi	s0,sp,544
    80004e1a:	892a                	mv	s2,a0
    80004e1c:	dea43423          	sd	a0,-536(s0)
    80004e20:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e24:	ffffd097          	auipc	ra,0xffffd
    80004e28:	c34080e7          	jalr	-972(ra) # 80001a58 <myproc>
    80004e2c:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    80004e2e:	4501                	li	a0,0
    80004e30:	fffff097          	auipc	ra,0xfffff
    80004e34:	382080e7          	jalr	898(ra) # 800041b2 <begin_op>

  if((ip = namei(path)) == 0){
    80004e38:	854a                	mv	a0,s2
    80004e3a:	fffff097          	auipc	ra,0xfffff
    80004e3e:	11e080e7          	jalr	286(ra) # 80003f58 <namei>
    80004e42:	cd25                	beqz	a0,80004eba <exec+0xc8>
    80004e44:	8aaa                	mv	s5,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004e46:	fffff097          	auipc	ra,0xfffff
    80004e4a:	8a6080e7          	jalr	-1882(ra) # 800036ec <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e4e:	04000713          	li	a4,64
    80004e52:	4681                	li	a3,0
    80004e54:	e4840613          	addi	a2,s0,-440
    80004e58:	4581                	li	a1,0
    80004e5a:	8556                	mv	a0,s5
    80004e5c:	fffff097          	auipc	ra,0xfffff
    80004e60:	bfa080e7          	jalr	-1030(ra) # 80003a56 <readi>
    80004e64:	04000793          	li	a5,64
    80004e68:	00f51a63          	bne	a0,a5,80004e7c <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e6c:	e4842703          	lw	a4,-440(s0)
    80004e70:	464c47b7          	lui	a5,0x464c4
    80004e74:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e78:	04f70863          	beq	a4,a5,80004ec8 <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e7c:	8556                	mv	a0,s5
    80004e7e:	fffff097          	auipc	ra,0xfffff
    80004e82:	b78080e7          	jalr	-1160(ra) # 800039f6 <iunlockput>
    end_op(ROOTDEV);
    80004e86:	4501                	li	a0,0
    80004e88:	fffff097          	auipc	ra,0xfffff
    80004e8c:	3d4080e7          	jalr	980(ra) # 8000425c <end_op>
  }
  return -1;
    80004e90:	557d                	li	a0,-1
}
    80004e92:	21813083          	ld	ra,536(sp)
    80004e96:	21013403          	ld	s0,528(sp)
    80004e9a:	20813483          	ld	s1,520(sp)
    80004e9e:	20013903          	ld	s2,512(sp)
    80004ea2:	79fe                	ld	s3,504(sp)
    80004ea4:	7a5e                	ld	s4,496(sp)
    80004ea6:	7abe                	ld	s5,488(sp)
    80004ea8:	7b1e                	ld	s6,480(sp)
    80004eaa:	6bfe                	ld	s7,472(sp)
    80004eac:	6c5e                	ld	s8,464(sp)
    80004eae:	6cbe                	ld	s9,456(sp)
    80004eb0:	6d1e                	ld	s10,448(sp)
    80004eb2:	7dfa                	ld	s11,440(sp)
    80004eb4:	22010113          	addi	sp,sp,544
    80004eb8:	8082                	ret
    end_op(ROOTDEV);
    80004eba:	4501                	li	a0,0
    80004ebc:	fffff097          	auipc	ra,0xfffff
    80004ec0:	3a0080e7          	jalr	928(ra) # 8000425c <end_op>
    return -1;
    80004ec4:	557d                	li	a0,-1
    80004ec6:	b7f1                	j	80004e92 <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ec8:	8526                	mv	a0,s1
    80004eca:	ffffd097          	auipc	ra,0xffffd
    80004ece:	c52080e7          	jalr	-942(ra) # 80001b1c <proc_pagetable>
    80004ed2:	8b2a                	mv	s6,a0
    80004ed4:	d545                	beqz	a0,80004e7c <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ed6:	e6842783          	lw	a5,-408(s0)
    80004eda:	e8045703          	lhu	a4,-384(s0)
    80004ede:	10070263          	beqz	a4,80004fe2 <exec+0x1f0>
  sz = 0;
    80004ee2:	de043c23          	sd	zero,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ee6:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004eea:	6a05                	lui	s4,0x1
    80004eec:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004ef0:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004ef4:	6d85                	lui	s11,0x1
    80004ef6:	7d7d                	lui	s10,0xfffff
    80004ef8:	a88d                	j	80004f6a <exec+0x178>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004efa:	00004517          	auipc	a0,0x4
    80004efe:	90e50513          	addi	a0,a0,-1778 # 80008808 <userret+0x778>
    80004f02:	ffffb097          	auipc	ra,0xffffb
    80004f06:	652080e7          	jalr	1618(ra) # 80000554 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f0a:	874a                	mv	a4,s2
    80004f0c:	009c86bb          	addw	a3,s9,s1
    80004f10:	4581                	li	a1,0
    80004f12:	8556                	mv	a0,s5
    80004f14:	fffff097          	auipc	ra,0xfffff
    80004f18:	b42080e7          	jalr	-1214(ra) # 80003a56 <readi>
    80004f1c:	2501                	sext.w	a0,a0
    80004f1e:	10a91863          	bne	s2,a0,8000502e <exec+0x23c>
  for(i = 0; i < sz; i += PGSIZE){
    80004f22:	009d84bb          	addw	s1,s11,s1
    80004f26:	013d09bb          	addw	s3,s10,s3
    80004f2a:	0374f263          	bgeu	s1,s7,80004f4e <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    80004f2e:	02049593          	slli	a1,s1,0x20
    80004f32:	9181                	srli	a1,a1,0x20
    80004f34:	95e2                	add	a1,a1,s8
    80004f36:	855a                	mv	a0,s6
    80004f38:	ffffc097          	auipc	ra,0xffffc
    80004f3c:	230080e7          	jalr	560(ra) # 80001168 <walkaddr>
    80004f40:	862a                	mv	a2,a0
    if(pa == 0)
    80004f42:	dd45                	beqz	a0,80004efa <exec+0x108>
      n = PGSIZE;
    80004f44:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f46:	fd49f2e3          	bgeu	s3,s4,80004f0a <exec+0x118>
      n = sz - i;
    80004f4a:	894e                	mv	s2,s3
    80004f4c:	bf7d                	j	80004f0a <exec+0x118>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f4e:	e0843783          	ld	a5,-504(s0)
    80004f52:	0017869b          	addiw	a3,a5,1
    80004f56:	e0d43423          	sd	a3,-504(s0)
    80004f5a:	e0043783          	ld	a5,-512(s0)
    80004f5e:	0387879b          	addiw	a5,a5,56
    80004f62:	e8045703          	lhu	a4,-384(s0)
    80004f66:	08e6d063          	bge	a3,a4,80004fe6 <exec+0x1f4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f6a:	2781                	sext.w	a5,a5
    80004f6c:	e0f43023          	sd	a5,-512(s0)
    80004f70:	03800713          	li	a4,56
    80004f74:	86be                	mv	a3,a5
    80004f76:	e1040613          	addi	a2,s0,-496
    80004f7a:	4581                	li	a1,0
    80004f7c:	8556                	mv	a0,s5
    80004f7e:	fffff097          	auipc	ra,0xfffff
    80004f82:	ad8080e7          	jalr	-1320(ra) # 80003a56 <readi>
    80004f86:	03800793          	li	a5,56
    80004f8a:	0af51263          	bne	a0,a5,8000502e <exec+0x23c>
    if(ph.type != ELF_PROG_LOAD)
    80004f8e:	e1042783          	lw	a5,-496(s0)
    80004f92:	4705                	li	a4,1
    80004f94:	fae79de3          	bne	a5,a4,80004f4e <exec+0x15c>
    if(ph.memsz < ph.filesz)
    80004f98:	e3843603          	ld	a2,-456(s0)
    80004f9c:	e3043783          	ld	a5,-464(s0)
    80004fa0:	08f66763          	bltu	a2,a5,8000502e <exec+0x23c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fa4:	e2043783          	ld	a5,-480(s0)
    80004fa8:	963e                	add	a2,a2,a5
    80004faa:	08f66263          	bltu	a2,a5,8000502e <exec+0x23c>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fae:	df843583          	ld	a1,-520(s0)
    80004fb2:	855a                	mv	a0,s6
    80004fb4:	ffffc097          	auipc	ra,0xffffc
    80004fb8:	5bc080e7          	jalr	1468(ra) # 80001570 <uvmalloc>
    80004fbc:	dea43c23          	sd	a0,-520(s0)
    80004fc0:	c53d                	beqz	a0,8000502e <exec+0x23c>
    if(ph.vaddr % PGSIZE != 0)
    80004fc2:	e2043c03          	ld	s8,-480(s0)
    80004fc6:	de043783          	ld	a5,-544(s0)
    80004fca:	00fc77b3          	and	a5,s8,a5
    80004fce:	e3a5                	bnez	a5,8000502e <exec+0x23c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fd0:	e1842c83          	lw	s9,-488(s0)
    80004fd4:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fd8:	f60b8be3          	beqz	s7,80004f4e <exec+0x15c>
    80004fdc:	89de                	mv	s3,s7
    80004fde:	4481                	li	s1,0
    80004fe0:	b7b9                	j	80004f2e <exec+0x13c>
  sz = 0;
    80004fe2:	de043c23          	sd	zero,-520(s0)
  iunlockput(ip);
    80004fe6:	8556                	mv	a0,s5
    80004fe8:	fffff097          	auipc	ra,0xfffff
    80004fec:	a0e080e7          	jalr	-1522(ra) # 800039f6 <iunlockput>
  end_op(ROOTDEV);
    80004ff0:	4501                	li	a0,0
    80004ff2:	fffff097          	auipc	ra,0xfffff
    80004ff6:	26a080e7          	jalr	618(ra) # 8000425c <end_op>
  p = myproc();
    80004ffa:	ffffd097          	auipc	ra,0xffffd
    80004ffe:	a5e080e7          	jalr	-1442(ra) # 80001a58 <myproc>
    80005002:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005004:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    80005008:	6585                	lui	a1,0x1
    8000500a:	15fd                	addi	a1,a1,-1
    8000500c:	df843783          	ld	a5,-520(s0)
    80005010:	95be                	add	a1,a1,a5
    80005012:	77fd                	lui	a5,0xfffff
    80005014:	8dfd                	and	a1,a1,a5
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005016:	6609                	lui	a2,0x2
    80005018:	962e                	add	a2,a2,a1
    8000501a:	855a                	mv	a0,s6
    8000501c:	ffffc097          	auipc	ra,0xffffc
    80005020:	554080e7          	jalr	1364(ra) # 80001570 <uvmalloc>
    80005024:	892a                	mv	s2,a0
    80005026:	dea43c23          	sd	a0,-520(s0)
  ip = 0;
    8000502a:	4a81                	li	s5,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000502c:	ed01                	bnez	a0,80005044 <exec+0x252>
    proc_freepagetable(pagetable, sz);
    8000502e:	df843583          	ld	a1,-520(s0)
    80005032:	855a                	mv	a0,s6
    80005034:	ffffd097          	auipc	ra,0xffffd
    80005038:	be8080e7          	jalr	-1048(ra) # 80001c1c <proc_freepagetable>
  if(ip){
    8000503c:	e40a90e3          	bnez	s5,80004e7c <exec+0x8a>
  return -1;
    80005040:	557d                	li	a0,-1
    80005042:	bd81                	j	80004e92 <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005044:	75f9                	lui	a1,0xffffe
    80005046:	95aa                	add	a1,a1,a0
    80005048:	855a                	mv	a0,s6
    8000504a:	ffffc097          	auipc	ra,0xffffc
    8000504e:	6ce080e7          	jalr	1742(ra) # 80001718 <uvmclear>
  stackbase = sp - PGSIZE;
    80005052:	7c7d                	lui	s8,0xfffff
    80005054:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    80005056:	df043783          	ld	a5,-528(s0)
    8000505a:	6388                	ld	a0,0(a5)
    8000505c:	c52d                	beqz	a0,800050c6 <exec+0x2d4>
    8000505e:	e8840993          	addi	s3,s0,-376
    80005062:	f8840a93          	addi	s5,s0,-120
    80005066:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005068:	ffffc097          	auipc	ra,0xffffc
    8000506c:	e8a080e7          	jalr	-374(ra) # 80000ef2 <strlen>
    80005070:	0015079b          	addiw	a5,a0,1
    80005074:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005078:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000507c:	0f896b63          	bltu	s2,s8,80005172 <exec+0x380>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005080:	df043d03          	ld	s10,-528(s0)
    80005084:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7ffd5fa4>
    80005088:	8552                	mv	a0,s4
    8000508a:	ffffc097          	auipc	ra,0xffffc
    8000508e:	e68080e7          	jalr	-408(ra) # 80000ef2 <strlen>
    80005092:	0015069b          	addiw	a3,a0,1
    80005096:	8652                	mv	a2,s4
    80005098:	85ca                	mv	a1,s2
    8000509a:	855a                	mv	a0,s6
    8000509c:	ffffc097          	auipc	ra,0xffffc
    800050a0:	6ae080e7          	jalr	1710(ra) # 8000174a <copyout>
    800050a4:	0c054963          	bltz	a0,80005176 <exec+0x384>
    ustack[argc] = sp;
    800050a8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050ac:	0485                	addi	s1,s1,1
    800050ae:	008d0793          	addi	a5,s10,8
    800050b2:	def43823          	sd	a5,-528(s0)
    800050b6:	008d3503          	ld	a0,8(s10)
    800050ba:	c909                	beqz	a0,800050cc <exec+0x2da>
    if(argc >= MAXARG)
    800050bc:	09a1                	addi	s3,s3,8
    800050be:	fb3a95e3          	bne	s5,s3,80005068 <exec+0x276>
  ip = 0;
    800050c2:	4a81                	li	s5,0
    800050c4:	b7ad                	j	8000502e <exec+0x23c>
  sp = sz;
    800050c6:	df843903          	ld	s2,-520(s0)
  for(argc = 0; argv[argc]; argc++) {
    800050ca:	4481                	li	s1,0
  ustack[argc] = 0;
    800050cc:	00349793          	slli	a5,s1,0x3
    800050d0:	f9040713          	addi	a4,s0,-112
    800050d4:	97ba                	add	a5,a5,a4
    800050d6:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd5e9c>
  sp -= (argc+1) * sizeof(uint64);
    800050da:	00148693          	addi	a3,s1,1
    800050de:	068e                	slli	a3,a3,0x3
    800050e0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050e4:	ff097913          	andi	s2,s2,-16
  ip = 0;
    800050e8:	4a81                	li	s5,0
  if(sp < stackbase)
    800050ea:	f58962e3          	bltu	s2,s8,8000502e <exec+0x23c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050ee:	e8840613          	addi	a2,s0,-376
    800050f2:	85ca                	mv	a1,s2
    800050f4:	855a                	mv	a0,s6
    800050f6:	ffffc097          	auipc	ra,0xffffc
    800050fa:	654080e7          	jalr	1620(ra) # 8000174a <copyout>
    800050fe:	06054e63          	bltz	a0,8000517a <exec+0x388>
  p->tf->a1 = sp;
    80005102:	060bb783          	ld	a5,96(s7)
    80005106:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000510a:	de843783          	ld	a5,-536(s0)
    8000510e:	0007c703          	lbu	a4,0(a5)
    80005112:	cf11                	beqz	a4,8000512e <exec+0x33c>
    80005114:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005116:	02f00693          	li	a3,47
    8000511a:	a039                	j	80005128 <exec+0x336>
      last = s+1;
    8000511c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005120:	0785                	addi	a5,a5,1
    80005122:	fff7c703          	lbu	a4,-1(a5)
    80005126:	c701                	beqz	a4,8000512e <exec+0x33c>
    if(*s == '/')
    80005128:	fed71ce3          	bne	a4,a3,80005120 <exec+0x32e>
    8000512c:	bfc5                	j	8000511c <exec+0x32a>
  safestrcpy(p->name, last, sizeof(p->name));
    8000512e:	4641                	li	a2,16
    80005130:	de843583          	ld	a1,-536(s0)
    80005134:	160b8513          	addi	a0,s7,352
    80005138:	ffffc097          	auipc	ra,0xffffc
    8000513c:	d88080e7          	jalr	-632(ra) # 80000ec0 <safestrcpy>
  oldpagetable = p->pagetable;
    80005140:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80005144:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    80005148:	df843783          	ld	a5,-520(s0)
    8000514c:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80005150:	060bb783          	ld	a5,96(s7)
    80005154:	e6043703          	ld	a4,-416(s0)
    80005158:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    8000515a:	060bb783          	ld	a5,96(s7)
    8000515e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005162:	85e6                	mv	a1,s9
    80005164:	ffffd097          	auipc	ra,0xffffd
    80005168:	ab8080e7          	jalr	-1352(ra) # 80001c1c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000516c:	0004851b          	sext.w	a0,s1
    80005170:	b30d                	j	80004e92 <exec+0xa0>
  ip = 0;
    80005172:	4a81                	li	s5,0
    80005174:	bd6d                	j	8000502e <exec+0x23c>
    80005176:	4a81                	li	s5,0
    80005178:	bd5d                	j	8000502e <exec+0x23c>
    8000517a:	4a81                	li	s5,0
    8000517c:	bd4d                	j	8000502e <exec+0x23c>

000000008000517e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000517e:	7179                	addi	sp,sp,-48
    80005180:	f406                	sd	ra,40(sp)
    80005182:	f022                	sd	s0,32(sp)
    80005184:	ec26                	sd	s1,24(sp)
    80005186:	e84a                	sd	s2,16(sp)
    80005188:	1800                	addi	s0,sp,48
    8000518a:	892e                	mv	s2,a1
    8000518c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000518e:	fdc40593          	addi	a1,s0,-36
    80005192:	ffffe097          	auipc	ra,0xffffe
    80005196:	920080e7          	jalr	-1760(ra) # 80002ab2 <argint>
    8000519a:	04054063          	bltz	a0,800051da <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000519e:	fdc42703          	lw	a4,-36(s0)
    800051a2:	47bd                	li	a5,15
    800051a4:	02e7ed63          	bltu	a5,a4,800051de <argfd+0x60>
    800051a8:	ffffd097          	auipc	ra,0xffffd
    800051ac:	8b0080e7          	jalr	-1872(ra) # 80001a58 <myproc>
    800051b0:	fdc42703          	lw	a4,-36(s0)
    800051b4:	01a70793          	addi	a5,a4,26
    800051b8:	078e                	slli	a5,a5,0x3
    800051ba:	953e                	add	a0,a0,a5
    800051bc:	651c                	ld	a5,8(a0)
    800051be:	c395                	beqz	a5,800051e2 <argfd+0x64>
    return -1;
  if(pfd)
    800051c0:	00090463          	beqz	s2,800051c8 <argfd+0x4a>
    *pfd = fd;
    800051c4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051c8:	4501                	li	a0,0
  if(pf)
    800051ca:	c091                	beqz	s1,800051ce <argfd+0x50>
    *pf = f;
    800051cc:	e09c                	sd	a5,0(s1)
}
    800051ce:	70a2                	ld	ra,40(sp)
    800051d0:	7402                	ld	s0,32(sp)
    800051d2:	64e2                	ld	s1,24(sp)
    800051d4:	6942                	ld	s2,16(sp)
    800051d6:	6145                	addi	sp,sp,48
    800051d8:	8082                	ret
    return -1;
    800051da:	557d                	li	a0,-1
    800051dc:	bfcd                	j	800051ce <argfd+0x50>
    return -1;
    800051de:	557d                	li	a0,-1
    800051e0:	b7fd                	j	800051ce <argfd+0x50>
    800051e2:	557d                	li	a0,-1
    800051e4:	b7ed                	j	800051ce <argfd+0x50>

00000000800051e6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051e6:	1101                	addi	sp,sp,-32
    800051e8:	ec06                	sd	ra,24(sp)
    800051ea:	e822                	sd	s0,16(sp)
    800051ec:	e426                	sd	s1,8(sp)
    800051ee:	1000                	addi	s0,sp,32
    800051f0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051f2:	ffffd097          	auipc	ra,0xffffd
    800051f6:	866080e7          	jalr	-1946(ra) # 80001a58 <myproc>
    800051fa:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800051fc:	0d850793          	addi	a5,a0,216
    80005200:	4501                	li	a0,0
    80005202:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005204:	6398                	ld	a4,0(a5)
    80005206:	cb19                	beqz	a4,8000521c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005208:	2505                	addiw	a0,a0,1
    8000520a:	07a1                	addi	a5,a5,8
    8000520c:	fed51ce3          	bne	a0,a3,80005204 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005210:	557d                	li	a0,-1
}
    80005212:	60e2                	ld	ra,24(sp)
    80005214:	6442                	ld	s0,16(sp)
    80005216:	64a2                	ld	s1,8(sp)
    80005218:	6105                	addi	sp,sp,32
    8000521a:	8082                	ret
      p->ofile[fd] = f;
    8000521c:	01a50793          	addi	a5,a0,26
    80005220:	078e                	slli	a5,a5,0x3
    80005222:	963e                	add	a2,a2,a5
    80005224:	e604                	sd	s1,8(a2)
      return fd;
    80005226:	b7f5                	j	80005212 <fdalloc+0x2c>

0000000080005228 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005228:	715d                	addi	sp,sp,-80
    8000522a:	e486                	sd	ra,72(sp)
    8000522c:	e0a2                	sd	s0,64(sp)
    8000522e:	fc26                	sd	s1,56(sp)
    80005230:	f84a                	sd	s2,48(sp)
    80005232:	f44e                	sd	s3,40(sp)
    80005234:	f052                	sd	s4,32(sp)
    80005236:	ec56                	sd	s5,24(sp)
    80005238:	0880                	addi	s0,sp,80
    8000523a:	89ae                	mv	s3,a1
    8000523c:	8ab2                	mv	s5,a2
    8000523e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005240:	fb040593          	addi	a1,s0,-80
    80005244:	fffff097          	auipc	ra,0xfffff
    80005248:	d32080e7          	jalr	-718(ra) # 80003f76 <nameiparent>
    8000524c:	892a                	mv	s2,a0
    8000524e:	12050e63          	beqz	a0,8000538a <create+0x162>
    return 0;

  ilock(dp);
    80005252:	ffffe097          	auipc	ra,0xffffe
    80005256:	49a080e7          	jalr	1178(ra) # 800036ec <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000525a:	4601                	li	a2,0
    8000525c:	fb040593          	addi	a1,s0,-80
    80005260:	854a                	mv	a0,s2
    80005262:	fffff097          	auipc	ra,0xfffff
    80005266:	a22080e7          	jalr	-1502(ra) # 80003c84 <dirlookup>
    8000526a:	84aa                	mv	s1,a0
    8000526c:	c921                	beqz	a0,800052bc <create+0x94>
    iunlockput(dp);
    8000526e:	854a                	mv	a0,s2
    80005270:	ffffe097          	auipc	ra,0xffffe
    80005274:	786080e7          	jalr	1926(ra) # 800039f6 <iunlockput>
    ilock(ip);
    80005278:	8526                	mv	a0,s1
    8000527a:	ffffe097          	auipc	ra,0xffffe
    8000527e:	472080e7          	jalr	1138(ra) # 800036ec <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005282:	2981                	sext.w	s3,s3
    80005284:	4789                	li	a5,2
    80005286:	02f99463          	bne	s3,a5,800052ae <create+0x86>
    8000528a:	0cc4d783          	lhu	a5,204(s1)
    8000528e:	37f9                	addiw	a5,a5,-2
    80005290:	17c2                	slli	a5,a5,0x30
    80005292:	93c1                	srli	a5,a5,0x30
    80005294:	4705                	li	a4,1
    80005296:	00f76c63          	bltu	a4,a5,800052ae <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000529a:	8526                	mv	a0,s1
    8000529c:	60a6                	ld	ra,72(sp)
    8000529e:	6406                	ld	s0,64(sp)
    800052a0:	74e2                	ld	s1,56(sp)
    800052a2:	7942                	ld	s2,48(sp)
    800052a4:	79a2                	ld	s3,40(sp)
    800052a6:	7a02                	ld	s4,32(sp)
    800052a8:	6ae2                	ld	s5,24(sp)
    800052aa:	6161                	addi	sp,sp,80
    800052ac:	8082                	ret
    iunlockput(ip);
    800052ae:	8526                	mv	a0,s1
    800052b0:	ffffe097          	auipc	ra,0xffffe
    800052b4:	746080e7          	jalr	1862(ra) # 800039f6 <iunlockput>
    return 0;
    800052b8:	4481                	li	s1,0
    800052ba:	b7c5                	j	8000529a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052bc:	85ce                	mv	a1,s3
    800052be:	00092503          	lw	a0,0(s2)
    800052c2:	ffffe097          	auipc	ra,0xffffe
    800052c6:	290080e7          	jalr	656(ra) # 80003552 <ialloc>
    800052ca:	84aa                	mv	s1,a0
    800052cc:	c521                	beqz	a0,80005314 <create+0xec>
  ilock(ip);
    800052ce:	ffffe097          	auipc	ra,0xffffe
    800052d2:	41e080e7          	jalr	1054(ra) # 800036ec <ilock>
  ip->major = major;
    800052d6:	0d549723          	sh	s5,206(s1)
  ip->minor = minor;
    800052da:	0d449823          	sh	s4,208(s1)
  ip->nlink = 1;
    800052de:	4a05                	li	s4,1
    800052e0:	0d449923          	sh	s4,210(s1)
  iupdate(ip);
    800052e4:	8526                	mv	a0,s1
    800052e6:	ffffe097          	auipc	ra,0xffffe
    800052ea:	33a080e7          	jalr	826(ra) # 80003620 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052ee:	2981                	sext.w	s3,s3
    800052f0:	03498a63          	beq	s3,s4,80005324 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800052f4:	40d0                	lw	a2,4(s1)
    800052f6:	fb040593          	addi	a1,s0,-80
    800052fa:	854a                	mv	a0,s2
    800052fc:	fffff097          	auipc	ra,0xfffff
    80005300:	b9a080e7          	jalr	-1126(ra) # 80003e96 <dirlink>
    80005304:	06054b63          	bltz	a0,8000537a <create+0x152>
  iunlockput(dp);
    80005308:	854a                	mv	a0,s2
    8000530a:	ffffe097          	auipc	ra,0xffffe
    8000530e:	6ec080e7          	jalr	1772(ra) # 800039f6 <iunlockput>
  return ip;
    80005312:	b761                	j	8000529a <create+0x72>
    panic("create: ialloc");
    80005314:	00003517          	auipc	a0,0x3
    80005318:	51450513          	addi	a0,a0,1300 # 80008828 <userret+0x798>
    8000531c:	ffffb097          	auipc	ra,0xffffb
    80005320:	238080e7          	jalr	568(ra) # 80000554 <panic>
    dp->nlink++;  // for ".."
    80005324:	0d295783          	lhu	a5,210(s2)
    80005328:	2785                	addiw	a5,a5,1
    8000532a:	0cf91923          	sh	a5,210(s2)
    iupdate(dp);
    8000532e:	854a                	mv	a0,s2
    80005330:	ffffe097          	auipc	ra,0xffffe
    80005334:	2f0080e7          	jalr	752(ra) # 80003620 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005338:	40d0                	lw	a2,4(s1)
    8000533a:	00003597          	auipc	a1,0x3
    8000533e:	4fe58593          	addi	a1,a1,1278 # 80008838 <userret+0x7a8>
    80005342:	8526                	mv	a0,s1
    80005344:	fffff097          	auipc	ra,0xfffff
    80005348:	b52080e7          	jalr	-1198(ra) # 80003e96 <dirlink>
    8000534c:	00054f63          	bltz	a0,8000536a <create+0x142>
    80005350:	00492603          	lw	a2,4(s2)
    80005354:	00003597          	auipc	a1,0x3
    80005358:	4ec58593          	addi	a1,a1,1260 # 80008840 <userret+0x7b0>
    8000535c:	8526                	mv	a0,s1
    8000535e:	fffff097          	auipc	ra,0xfffff
    80005362:	b38080e7          	jalr	-1224(ra) # 80003e96 <dirlink>
    80005366:	f80557e3          	bgez	a0,800052f4 <create+0xcc>
      panic("create dots");
    8000536a:	00003517          	auipc	a0,0x3
    8000536e:	4de50513          	addi	a0,a0,1246 # 80008848 <userret+0x7b8>
    80005372:	ffffb097          	auipc	ra,0xffffb
    80005376:	1e2080e7          	jalr	482(ra) # 80000554 <panic>
    panic("create: dirlink");
    8000537a:	00003517          	auipc	a0,0x3
    8000537e:	4de50513          	addi	a0,a0,1246 # 80008858 <userret+0x7c8>
    80005382:	ffffb097          	auipc	ra,0xffffb
    80005386:	1d2080e7          	jalr	466(ra) # 80000554 <panic>
    return 0;
    8000538a:	84aa                	mv	s1,a0
    8000538c:	b739                	j	8000529a <create+0x72>

000000008000538e <sys_dup>:
{
    8000538e:	7179                	addi	sp,sp,-48
    80005390:	f406                	sd	ra,40(sp)
    80005392:	f022                	sd	s0,32(sp)
    80005394:	ec26                	sd	s1,24(sp)
    80005396:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005398:	fd840613          	addi	a2,s0,-40
    8000539c:	4581                	li	a1,0
    8000539e:	4501                	li	a0,0
    800053a0:	00000097          	auipc	ra,0x0
    800053a4:	dde080e7          	jalr	-546(ra) # 8000517e <argfd>
    return -1;
    800053a8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053aa:	02054363          	bltz	a0,800053d0 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053ae:	fd843503          	ld	a0,-40(s0)
    800053b2:	00000097          	auipc	ra,0x0
    800053b6:	e34080e7          	jalr	-460(ra) # 800051e6 <fdalloc>
    800053ba:	84aa                	mv	s1,a0
    return -1;
    800053bc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053be:	00054963          	bltz	a0,800053d0 <sys_dup+0x42>
  filedup(f);
    800053c2:	fd843503          	ld	a0,-40(s0)
    800053c6:	fffff097          	auipc	ra,0xfffff
    800053ca:	334080e7          	jalr	820(ra) # 800046fa <filedup>
  return fd;
    800053ce:	87a6                	mv	a5,s1
}
    800053d0:	853e                	mv	a0,a5
    800053d2:	70a2                	ld	ra,40(sp)
    800053d4:	7402                	ld	s0,32(sp)
    800053d6:	64e2                	ld	s1,24(sp)
    800053d8:	6145                	addi	sp,sp,48
    800053da:	8082                	ret

00000000800053dc <sys_read>:
{
    800053dc:	7179                	addi	sp,sp,-48
    800053de:	f406                	sd	ra,40(sp)
    800053e0:	f022                	sd	s0,32(sp)
    800053e2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053e4:	fe840613          	addi	a2,s0,-24
    800053e8:	4581                	li	a1,0
    800053ea:	4501                	li	a0,0
    800053ec:	00000097          	auipc	ra,0x0
    800053f0:	d92080e7          	jalr	-622(ra) # 8000517e <argfd>
    return -1;
    800053f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053f6:	04054163          	bltz	a0,80005438 <sys_read+0x5c>
    800053fa:	fe440593          	addi	a1,s0,-28
    800053fe:	4509                	li	a0,2
    80005400:	ffffd097          	auipc	ra,0xffffd
    80005404:	6b2080e7          	jalr	1714(ra) # 80002ab2 <argint>
    return -1;
    80005408:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000540a:	02054763          	bltz	a0,80005438 <sys_read+0x5c>
    8000540e:	fd840593          	addi	a1,s0,-40
    80005412:	4505                	li	a0,1
    80005414:	ffffd097          	auipc	ra,0xffffd
    80005418:	6c0080e7          	jalr	1728(ra) # 80002ad4 <argaddr>
    return -1;
    8000541c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000541e:	00054d63          	bltz	a0,80005438 <sys_read+0x5c>
  return fileread(f, p, n);
    80005422:	fe442603          	lw	a2,-28(s0)
    80005426:	fd843583          	ld	a1,-40(s0)
    8000542a:	fe843503          	ld	a0,-24(s0)
    8000542e:	fffff097          	auipc	ra,0xfffff
    80005432:	460080e7          	jalr	1120(ra) # 8000488e <fileread>
    80005436:	87aa                	mv	a5,a0
}
    80005438:	853e                	mv	a0,a5
    8000543a:	70a2                	ld	ra,40(sp)
    8000543c:	7402                	ld	s0,32(sp)
    8000543e:	6145                	addi	sp,sp,48
    80005440:	8082                	ret

0000000080005442 <sys_write>:
{
    80005442:	7179                	addi	sp,sp,-48
    80005444:	f406                	sd	ra,40(sp)
    80005446:	f022                	sd	s0,32(sp)
    80005448:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000544a:	fe840613          	addi	a2,s0,-24
    8000544e:	4581                	li	a1,0
    80005450:	4501                	li	a0,0
    80005452:	00000097          	auipc	ra,0x0
    80005456:	d2c080e7          	jalr	-724(ra) # 8000517e <argfd>
    return -1;
    8000545a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000545c:	04054163          	bltz	a0,8000549e <sys_write+0x5c>
    80005460:	fe440593          	addi	a1,s0,-28
    80005464:	4509                	li	a0,2
    80005466:	ffffd097          	auipc	ra,0xffffd
    8000546a:	64c080e7          	jalr	1612(ra) # 80002ab2 <argint>
    return -1;
    8000546e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005470:	02054763          	bltz	a0,8000549e <sys_write+0x5c>
    80005474:	fd840593          	addi	a1,s0,-40
    80005478:	4505                	li	a0,1
    8000547a:	ffffd097          	auipc	ra,0xffffd
    8000547e:	65a080e7          	jalr	1626(ra) # 80002ad4 <argaddr>
    return -1;
    80005482:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005484:	00054d63          	bltz	a0,8000549e <sys_write+0x5c>
  return filewrite(f, p, n);
    80005488:	fe442603          	lw	a2,-28(s0)
    8000548c:	fd843583          	ld	a1,-40(s0)
    80005490:	fe843503          	ld	a0,-24(s0)
    80005494:	fffff097          	auipc	ra,0xfffff
    80005498:	4c0080e7          	jalr	1216(ra) # 80004954 <filewrite>
    8000549c:	87aa                	mv	a5,a0
}
    8000549e:	853e                	mv	a0,a5
    800054a0:	70a2                	ld	ra,40(sp)
    800054a2:	7402                	ld	s0,32(sp)
    800054a4:	6145                	addi	sp,sp,48
    800054a6:	8082                	ret

00000000800054a8 <sys_close>:
{
    800054a8:	1101                	addi	sp,sp,-32
    800054aa:	ec06                	sd	ra,24(sp)
    800054ac:	e822                	sd	s0,16(sp)
    800054ae:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054b0:	fe040613          	addi	a2,s0,-32
    800054b4:	fec40593          	addi	a1,s0,-20
    800054b8:	4501                	li	a0,0
    800054ba:	00000097          	auipc	ra,0x0
    800054be:	cc4080e7          	jalr	-828(ra) # 8000517e <argfd>
    return -1;
    800054c2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054c4:	02054463          	bltz	a0,800054ec <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054c8:	ffffc097          	auipc	ra,0xffffc
    800054cc:	590080e7          	jalr	1424(ra) # 80001a58 <myproc>
    800054d0:	fec42783          	lw	a5,-20(s0)
    800054d4:	07e9                	addi	a5,a5,26
    800054d6:	078e                	slli	a5,a5,0x3
    800054d8:	97aa                	add	a5,a5,a0
    800054da:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800054de:	fe043503          	ld	a0,-32(s0)
    800054e2:	fffff097          	auipc	ra,0xfffff
    800054e6:	26a080e7          	jalr	618(ra) # 8000474c <fileclose>
  return 0;
    800054ea:	4781                	li	a5,0
}
    800054ec:	853e                	mv	a0,a5
    800054ee:	60e2                	ld	ra,24(sp)
    800054f0:	6442                	ld	s0,16(sp)
    800054f2:	6105                	addi	sp,sp,32
    800054f4:	8082                	ret

00000000800054f6 <sys_fstat>:
{
    800054f6:	1101                	addi	sp,sp,-32
    800054f8:	ec06                	sd	ra,24(sp)
    800054fa:	e822                	sd	s0,16(sp)
    800054fc:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054fe:	fe840613          	addi	a2,s0,-24
    80005502:	4581                	li	a1,0
    80005504:	4501                	li	a0,0
    80005506:	00000097          	auipc	ra,0x0
    8000550a:	c78080e7          	jalr	-904(ra) # 8000517e <argfd>
    return -1;
    8000550e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005510:	02054563          	bltz	a0,8000553a <sys_fstat+0x44>
    80005514:	fe040593          	addi	a1,s0,-32
    80005518:	4505                	li	a0,1
    8000551a:	ffffd097          	auipc	ra,0xffffd
    8000551e:	5ba080e7          	jalr	1466(ra) # 80002ad4 <argaddr>
    return -1;
    80005522:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005524:	00054b63          	bltz	a0,8000553a <sys_fstat+0x44>
  return filestat(f, st);
    80005528:	fe043583          	ld	a1,-32(s0)
    8000552c:	fe843503          	ld	a0,-24(s0)
    80005530:	fffff097          	auipc	ra,0xfffff
    80005534:	2ec080e7          	jalr	748(ra) # 8000481c <filestat>
    80005538:	87aa                	mv	a5,a0
}
    8000553a:	853e                	mv	a0,a5
    8000553c:	60e2                	ld	ra,24(sp)
    8000553e:	6442                	ld	s0,16(sp)
    80005540:	6105                	addi	sp,sp,32
    80005542:	8082                	ret

0000000080005544 <sys_link>:
{
    80005544:	7169                	addi	sp,sp,-304
    80005546:	f606                	sd	ra,296(sp)
    80005548:	f222                	sd	s0,288(sp)
    8000554a:	ee26                	sd	s1,280(sp)
    8000554c:	ea4a                	sd	s2,272(sp)
    8000554e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005550:	08000613          	li	a2,128
    80005554:	ed040593          	addi	a1,s0,-304
    80005558:	4501                	li	a0,0
    8000555a:	ffffd097          	auipc	ra,0xffffd
    8000555e:	59c080e7          	jalr	1436(ra) # 80002af6 <argstr>
    return -1;
    80005562:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005564:	12054363          	bltz	a0,8000568a <sys_link+0x146>
    80005568:	08000613          	li	a2,128
    8000556c:	f5040593          	addi	a1,s0,-176
    80005570:	4505                	li	a0,1
    80005572:	ffffd097          	auipc	ra,0xffffd
    80005576:	584080e7          	jalr	1412(ra) # 80002af6 <argstr>
    return -1;
    8000557a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000557c:	10054763          	bltz	a0,8000568a <sys_link+0x146>
  begin_op(ROOTDEV);
    80005580:	4501                	li	a0,0
    80005582:	fffff097          	auipc	ra,0xfffff
    80005586:	c30080e7          	jalr	-976(ra) # 800041b2 <begin_op>
  if((ip = namei(old)) == 0){
    8000558a:	ed040513          	addi	a0,s0,-304
    8000558e:	fffff097          	auipc	ra,0xfffff
    80005592:	9ca080e7          	jalr	-1590(ra) # 80003f58 <namei>
    80005596:	84aa                	mv	s1,a0
    80005598:	c559                	beqz	a0,80005626 <sys_link+0xe2>
  ilock(ip);
    8000559a:	ffffe097          	auipc	ra,0xffffe
    8000559e:	152080e7          	jalr	338(ra) # 800036ec <ilock>
  if(ip->type == T_DIR){
    800055a2:	0cc49703          	lh	a4,204(s1)
    800055a6:	4785                	li	a5,1
    800055a8:	08f70663          	beq	a4,a5,80005634 <sys_link+0xf0>
  ip->nlink++;
    800055ac:	0d24d783          	lhu	a5,210(s1)
    800055b0:	2785                	addiw	a5,a5,1
    800055b2:	0cf49923          	sh	a5,210(s1)
  iupdate(ip);
    800055b6:	8526                	mv	a0,s1
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	068080e7          	jalr	104(ra) # 80003620 <iupdate>
  iunlock(ip);
    800055c0:	8526                	mv	a0,s1
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	1ee080e7          	jalr	494(ra) # 800037b0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055ca:	fd040593          	addi	a1,s0,-48
    800055ce:	f5040513          	addi	a0,s0,-176
    800055d2:	fffff097          	auipc	ra,0xfffff
    800055d6:	9a4080e7          	jalr	-1628(ra) # 80003f76 <nameiparent>
    800055da:	892a                	mv	s2,a0
    800055dc:	cd2d                	beqz	a0,80005656 <sys_link+0x112>
  ilock(dp);
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	10e080e7          	jalr	270(ra) # 800036ec <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055e6:	00092703          	lw	a4,0(s2)
    800055ea:	409c                	lw	a5,0(s1)
    800055ec:	06f71063          	bne	a4,a5,8000564c <sys_link+0x108>
    800055f0:	40d0                	lw	a2,4(s1)
    800055f2:	fd040593          	addi	a1,s0,-48
    800055f6:	854a                	mv	a0,s2
    800055f8:	fffff097          	auipc	ra,0xfffff
    800055fc:	89e080e7          	jalr	-1890(ra) # 80003e96 <dirlink>
    80005600:	04054663          	bltz	a0,8000564c <sys_link+0x108>
  iunlockput(dp);
    80005604:	854a                	mv	a0,s2
    80005606:	ffffe097          	auipc	ra,0xffffe
    8000560a:	3f0080e7          	jalr	1008(ra) # 800039f6 <iunlockput>
  iput(ip);
    8000560e:	8526                	mv	a0,s1
    80005610:	ffffe097          	auipc	ra,0xffffe
    80005614:	1ec080e7          	jalr	492(ra) # 800037fc <iput>
  end_op(ROOTDEV);
    80005618:	4501                	li	a0,0
    8000561a:	fffff097          	auipc	ra,0xfffff
    8000561e:	c42080e7          	jalr	-958(ra) # 8000425c <end_op>
  return 0;
    80005622:	4781                	li	a5,0
    80005624:	a09d                	j	8000568a <sys_link+0x146>
    end_op(ROOTDEV);
    80005626:	4501                	li	a0,0
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	c34080e7          	jalr	-972(ra) # 8000425c <end_op>
    return -1;
    80005630:	57fd                	li	a5,-1
    80005632:	a8a1                	j	8000568a <sys_link+0x146>
    iunlockput(ip);
    80005634:	8526                	mv	a0,s1
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	3c0080e7          	jalr	960(ra) # 800039f6 <iunlockput>
    end_op(ROOTDEV);
    8000563e:	4501                	li	a0,0
    80005640:	fffff097          	auipc	ra,0xfffff
    80005644:	c1c080e7          	jalr	-996(ra) # 8000425c <end_op>
    return -1;
    80005648:	57fd                	li	a5,-1
    8000564a:	a081                	j	8000568a <sys_link+0x146>
    iunlockput(dp);
    8000564c:	854a                	mv	a0,s2
    8000564e:	ffffe097          	auipc	ra,0xffffe
    80005652:	3a8080e7          	jalr	936(ra) # 800039f6 <iunlockput>
  ilock(ip);
    80005656:	8526                	mv	a0,s1
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	094080e7          	jalr	148(ra) # 800036ec <ilock>
  ip->nlink--;
    80005660:	0d24d783          	lhu	a5,210(s1)
    80005664:	37fd                	addiw	a5,a5,-1
    80005666:	0cf49923          	sh	a5,210(s1)
  iupdate(ip);
    8000566a:	8526                	mv	a0,s1
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	fb4080e7          	jalr	-76(ra) # 80003620 <iupdate>
  iunlockput(ip);
    80005674:	8526                	mv	a0,s1
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	380080e7          	jalr	896(ra) # 800039f6 <iunlockput>
  end_op(ROOTDEV);
    8000567e:	4501                	li	a0,0
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	bdc080e7          	jalr	-1060(ra) # 8000425c <end_op>
  return -1;
    80005688:	57fd                	li	a5,-1
}
    8000568a:	853e                	mv	a0,a5
    8000568c:	70b2                	ld	ra,296(sp)
    8000568e:	7412                	ld	s0,288(sp)
    80005690:	64f2                	ld	s1,280(sp)
    80005692:	6952                	ld	s2,272(sp)
    80005694:	6155                	addi	sp,sp,304
    80005696:	8082                	ret

0000000080005698 <sys_unlink>:
{
    80005698:	7151                	addi	sp,sp,-240
    8000569a:	f586                	sd	ra,232(sp)
    8000569c:	f1a2                	sd	s0,224(sp)
    8000569e:	eda6                	sd	s1,216(sp)
    800056a0:	e9ca                	sd	s2,208(sp)
    800056a2:	e5ce                	sd	s3,200(sp)
    800056a4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056a6:	08000613          	li	a2,128
    800056aa:	f3040593          	addi	a1,s0,-208
    800056ae:	4501                	li	a0,0
    800056b0:	ffffd097          	auipc	ra,0xffffd
    800056b4:	446080e7          	jalr	1094(ra) # 80002af6 <argstr>
    800056b8:	18054463          	bltz	a0,80005840 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    800056bc:	4501                	li	a0,0
    800056be:	fffff097          	auipc	ra,0xfffff
    800056c2:	af4080e7          	jalr	-1292(ra) # 800041b2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056c6:	fb040593          	addi	a1,s0,-80
    800056ca:	f3040513          	addi	a0,s0,-208
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	8a8080e7          	jalr	-1880(ra) # 80003f76 <nameiparent>
    800056d6:	84aa                	mv	s1,a0
    800056d8:	cd61                	beqz	a0,800057b0 <sys_unlink+0x118>
  ilock(dp);
    800056da:	ffffe097          	auipc	ra,0xffffe
    800056de:	012080e7          	jalr	18(ra) # 800036ec <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056e2:	00003597          	auipc	a1,0x3
    800056e6:	15658593          	addi	a1,a1,342 # 80008838 <userret+0x7a8>
    800056ea:	fb040513          	addi	a0,s0,-80
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	57c080e7          	jalr	1404(ra) # 80003c6a <namecmp>
    800056f6:	14050c63          	beqz	a0,8000584e <sys_unlink+0x1b6>
    800056fa:	00003597          	auipc	a1,0x3
    800056fe:	14658593          	addi	a1,a1,326 # 80008840 <userret+0x7b0>
    80005702:	fb040513          	addi	a0,s0,-80
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	564080e7          	jalr	1380(ra) # 80003c6a <namecmp>
    8000570e:	14050063          	beqz	a0,8000584e <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005712:	f2c40613          	addi	a2,s0,-212
    80005716:	fb040593          	addi	a1,s0,-80
    8000571a:	8526                	mv	a0,s1
    8000571c:	ffffe097          	auipc	ra,0xffffe
    80005720:	568080e7          	jalr	1384(ra) # 80003c84 <dirlookup>
    80005724:	892a                	mv	s2,a0
    80005726:	12050463          	beqz	a0,8000584e <sys_unlink+0x1b6>
  ilock(ip);
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	fc2080e7          	jalr	-62(ra) # 800036ec <ilock>
  if(ip->nlink < 1)
    80005732:	0d291783          	lh	a5,210(s2)
    80005736:	08f05463          	blez	a5,800057be <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000573a:	0cc91703          	lh	a4,204(s2)
    8000573e:	4785                	li	a5,1
    80005740:	08f70763          	beq	a4,a5,800057ce <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005744:	4641                	li	a2,16
    80005746:	4581                	li	a1,0
    80005748:	fc040513          	addi	a0,s0,-64
    8000574c:	ffffb097          	auipc	ra,0xffffb
    80005750:	622080e7          	jalr	1570(ra) # 80000d6e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005754:	4741                	li	a4,16
    80005756:	f2c42683          	lw	a3,-212(s0)
    8000575a:	fc040613          	addi	a2,s0,-64
    8000575e:	4581                	li	a1,0
    80005760:	8526                	mv	a0,s1
    80005762:	ffffe097          	auipc	ra,0xffffe
    80005766:	3ea080e7          	jalr	1002(ra) # 80003b4c <writei>
    8000576a:	47c1                	li	a5,16
    8000576c:	0af51763          	bne	a0,a5,8000581a <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005770:	0cc91703          	lh	a4,204(s2)
    80005774:	4785                	li	a5,1
    80005776:	0af70a63          	beq	a4,a5,8000582a <sys_unlink+0x192>
  iunlockput(dp);
    8000577a:	8526                	mv	a0,s1
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	27a080e7          	jalr	634(ra) # 800039f6 <iunlockput>
  ip->nlink--;
    80005784:	0d295783          	lhu	a5,210(s2)
    80005788:	37fd                	addiw	a5,a5,-1
    8000578a:	0cf91923          	sh	a5,210(s2)
  iupdate(ip);
    8000578e:	854a                	mv	a0,s2
    80005790:	ffffe097          	auipc	ra,0xffffe
    80005794:	e90080e7          	jalr	-368(ra) # 80003620 <iupdate>
  iunlockput(ip);
    80005798:	854a                	mv	a0,s2
    8000579a:	ffffe097          	auipc	ra,0xffffe
    8000579e:	25c080e7          	jalr	604(ra) # 800039f6 <iunlockput>
  end_op(ROOTDEV);
    800057a2:	4501                	li	a0,0
    800057a4:	fffff097          	auipc	ra,0xfffff
    800057a8:	ab8080e7          	jalr	-1352(ra) # 8000425c <end_op>
  return 0;
    800057ac:	4501                	li	a0,0
    800057ae:	a85d                	j	80005864 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    800057b0:	4501                	li	a0,0
    800057b2:	fffff097          	auipc	ra,0xfffff
    800057b6:	aaa080e7          	jalr	-1366(ra) # 8000425c <end_op>
    return -1;
    800057ba:	557d                	li	a0,-1
    800057bc:	a065                	j	80005864 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    800057be:	00003517          	auipc	a0,0x3
    800057c2:	0aa50513          	addi	a0,a0,170 # 80008868 <userret+0x7d8>
    800057c6:	ffffb097          	auipc	ra,0xffffb
    800057ca:	d8e080e7          	jalr	-626(ra) # 80000554 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057ce:	0d492703          	lw	a4,212(s2)
    800057d2:	02000793          	li	a5,32
    800057d6:	f6e7f7e3          	bgeu	a5,a4,80005744 <sys_unlink+0xac>
    800057da:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057de:	4741                	li	a4,16
    800057e0:	86ce                	mv	a3,s3
    800057e2:	f1840613          	addi	a2,s0,-232
    800057e6:	4581                	li	a1,0
    800057e8:	854a                	mv	a0,s2
    800057ea:	ffffe097          	auipc	ra,0xffffe
    800057ee:	26c080e7          	jalr	620(ra) # 80003a56 <readi>
    800057f2:	47c1                	li	a5,16
    800057f4:	00f51b63          	bne	a0,a5,8000580a <sys_unlink+0x172>
    if(de.inum != 0)
    800057f8:	f1845783          	lhu	a5,-232(s0)
    800057fc:	e7a1                	bnez	a5,80005844 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057fe:	29c1                	addiw	s3,s3,16
    80005800:	0d492783          	lw	a5,212(s2)
    80005804:	fcf9ede3          	bltu	s3,a5,800057de <sys_unlink+0x146>
    80005808:	bf35                	j	80005744 <sys_unlink+0xac>
      panic("isdirempty: readi");
    8000580a:	00003517          	auipc	a0,0x3
    8000580e:	07650513          	addi	a0,a0,118 # 80008880 <userret+0x7f0>
    80005812:	ffffb097          	auipc	ra,0xffffb
    80005816:	d42080e7          	jalr	-702(ra) # 80000554 <panic>
    panic("unlink: writei");
    8000581a:	00003517          	auipc	a0,0x3
    8000581e:	07e50513          	addi	a0,a0,126 # 80008898 <userret+0x808>
    80005822:	ffffb097          	auipc	ra,0xffffb
    80005826:	d32080e7          	jalr	-718(ra) # 80000554 <panic>
    dp->nlink--;
    8000582a:	0d24d783          	lhu	a5,210(s1)
    8000582e:	37fd                	addiw	a5,a5,-1
    80005830:	0cf49923          	sh	a5,210(s1)
    iupdate(dp);
    80005834:	8526                	mv	a0,s1
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	dea080e7          	jalr	-534(ra) # 80003620 <iupdate>
    8000583e:	bf35                	j	8000577a <sys_unlink+0xe2>
    return -1;
    80005840:	557d                	li	a0,-1
    80005842:	a00d                	j	80005864 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005844:	854a                	mv	a0,s2
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	1b0080e7          	jalr	432(ra) # 800039f6 <iunlockput>
  iunlockput(dp);
    8000584e:	8526                	mv	a0,s1
    80005850:	ffffe097          	auipc	ra,0xffffe
    80005854:	1a6080e7          	jalr	422(ra) # 800039f6 <iunlockput>
  end_op(ROOTDEV);
    80005858:	4501                	li	a0,0
    8000585a:	fffff097          	auipc	ra,0xfffff
    8000585e:	a02080e7          	jalr	-1534(ra) # 8000425c <end_op>
  return -1;
    80005862:	557d                	li	a0,-1
}
    80005864:	70ae                	ld	ra,232(sp)
    80005866:	740e                	ld	s0,224(sp)
    80005868:	64ee                	ld	s1,216(sp)
    8000586a:	694e                	ld	s2,208(sp)
    8000586c:	69ae                	ld	s3,200(sp)
    8000586e:	616d                	addi	sp,sp,240
    80005870:	8082                	ret

0000000080005872 <sys_mkdir>:


uint64
sys_mkdir(void)
{
    80005872:	7175                	addi	sp,sp,-144
    80005874:	e506                	sd	ra,136(sp)
    80005876:	e122                	sd	s0,128(sp)
    80005878:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    8000587a:	4501                	li	a0,0
    8000587c:	fffff097          	auipc	ra,0xfffff
    80005880:	936080e7          	jalr	-1738(ra) # 800041b2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005884:	08000613          	li	a2,128
    80005888:	f7040593          	addi	a1,s0,-144
    8000588c:	4501                	li	a0,0
    8000588e:	ffffd097          	auipc	ra,0xffffd
    80005892:	268080e7          	jalr	616(ra) # 80002af6 <argstr>
    80005896:	02054a63          	bltz	a0,800058ca <sys_mkdir+0x58>
    8000589a:	4681                	li	a3,0
    8000589c:	4601                	li	a2,0
    8000589e:	4585                	li	a1,1
    800058a0:	f7040513          	addi	a0,s0,-144
    800058a4:	00000097          	auipc	ra,0x0
    800058a8:	984080e7          	jalr	-1660(ra) # 80005228 <create>
    800058ac:	cd19                	beqz	a0,800058ca <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    800058ae:	ffffe097          	auipc	ra,0xffffe
    800058b2:	148080e7          	jalr	328(ra) # 800039f6 <iunlockput>
  end_op(ROOTDEV);
    800058b6:	4501                	li	a0,0
    800058b8:	fffff097          	auipc	ra,0xfffff
    800058bc:	9a4080e7          	jalr	-1628(ra) # 8000425c <end_op>
  return 0;
    800058c0:	4501                	li	a0,0
}
    800058c2:	60aa                	ld	ra,136(sp)
    800058c4:	640a                	ld	s0,128(sp)
    800058c6:	6149                	addi	sp,sp,144
    800058c8:	8082                	ret
    end_op(ROOTDEV);
    800058ca:	4501                	li	a0,0
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	990080e7          	jalr	-1648(ra) # 8000425c <end_op>
    return -1;
    800058d4:	557d                	li	a0,-1
    800058d6:	b7f5                	j	800058c2 <sys_mkdir+0x50>

00000000800058d8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800058d8:	7135                	addi	sp,sp,-160
    800058da:	ed06                	sd	ra,152(sp)
    800058dc:	e922                	sd	s0,144(sp)
    800058de:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    800058e0:	4501                	li	a0,0
    800058e2:	fffff097          	auipc	ra,0xfffff
    800058e6:	8d0080e7          	jalr	-1840(ra) # 800041b2 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058ea:	08000613          	li	a2,128
    800058ee:	f7040593          	addi	a1,s0,-144
    800058f2:	4501                	li	a0,0
    800058f4:	ffffd097          	auipc	ra,0xffffd
    800058f8:	202080e7          	jalr	514(ra) # 80002af6 <argstr>
    800058fc:	04054b63          	bltz	a0,80005952 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80005900:	f6c40593          	addi	a1,s0,-148
    80005904:	4505                	li	a0,1
    80005906:	ffffd097          	auipc	ra,0xffffd
    8000590a:	1ac080e7          	jalr	428(ra) # 80002ab2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000590e:	04054263          	bltz	a0,80005952 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005912:	f6840593          	addi	a1,s0,-152
    80005916:	4509                	li	a0,2
    80005918:	ffffd097          	auipc	ra,0xffffd
    8000591c:	19a080e7          	jalr	410(ra) # 80002ab2 <argint>
     argint(1, &major) < 0 ||
    80005920:	02054963          	bltz	a0,80005952 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005924:	f6841683          	lh	a3,-152(s0)
    80005928:	f6c41603          	lh	a2,-148(s0)
    8000592c:	458d                	li	a1,3
    8000592e:	f7040513          	addi	a0,s0,-144
    80005932:	00000097          	auipc	ra,0x0
    80005936:	8f6080e7          	jalr	-1802(ra) # 80005228 <create>
     argint(2, &minor) < 0 ||
    8000593a:	cd01                	beqz	a0,80005952 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	0ba080e7          	jalr	186(ra) # 800039f6 <iunlockput>
  end_op(ROOTDEV);
    80005944:	4501                	li	a0,0
    80005946:	fffff097          	auipc	ra,0xfffff
    8000594a:	916080e7          	jalr	-1770(ra) # 8000425c <end_op>
  return 0;
    8000594e:	4501                	li	a0,0
    80005950:	a039                	j	8000595e <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005952:	4501                	li	a0,0
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	908080e7          	jalr	-1784(ra) # 8000425c <end_op>
    return -1;
    8000595c:	557d                	li	a0,-1
}
    8000595e:	60ea                	ld	ra,152(sp)
    80005960:	644a                	ld	s0,144(sp)
    80005962:	610d                	addi	sp,sp,160
    80005964:	8082                	ret

0000000080005966 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005966:	7135                	addi	sp,sp,-160
    80005968:	ed06                	sd	ra,152(sp)
    8000596a:	e922                	sd	s0,144(sp)
    8000596c:	e526                	sd	s1,136(sp)
    8000596e:	e14a                	sd	s2,128(sp)
    80005970:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005972:	ffffc097          	auipc	ra,0xffffc
    80005976:	0e6080e7          	jalr	230(ra) # 80001a58 <myproc>
    8000597a:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    8000597c:	4501                	li	a0,0
    8000597e:	fffff097          	auipc	ra,0xfffff
    80005982:	834080e7          	jalr	-1996(ra) # 800041b2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005986:	08000613          	li	a2,128
    8000598a:	f6040593          	addi	a1,s0,-160
    8000598e:	4501                	li	a0,0
    80005990:	ffffd097          	auipc	ra,0xffffd
    80005994:	166080e7          	jalr	358(ra) # 80002af6 <argstr>
    80005998:	04054c63          	bltz	a0,800059f0 <sys_chdir+0x8a>
    8000599c:	f6040513          	addi	a0,s0,-160
    800059a0:	ffffe097          	auipc	ra,0xffffe
    800059a4:	5b8080e7          	jalr	1464(ra) # 80003f58 <namei>
    800059a8:	84aa                	mv	s1,a0
    800059aa:	c139                	beqz	a0,800059f0 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    800059ac:	ffffe097          	auipc	ra,0xffffe
    800059b0:	d40080e7          	jalr	-704(ra) # 800036ec <ilock>
  if(ip->type != T_DIR){
    800059b4:	0cc49703          	lh	a4,204(s1)
    800059b8:	4785                	li	a5,1
    800059ba:	04f71263          	bne	a4,a5,800059fe <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    800059be:	8526                	mv	a0,s1
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	df0080e7          	jalr	-528(ra) # 800037b0 <iunlock>
  iput(p->cwd);
    800059c8:	15893503          	ld	a0,344(s2)
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	e30080e7          	jalr	-464(ra) # 800037fc <iput>
  end_op(ROOTDEV);
    800059d4:	4501                	li	a0,0
    800059d6:	fffff097          	auipc	ra,0xfffff
    800059da:	886080e7          	jalr	-1914(ra) # 8000425c <end_op>
  p->cwd = ip;
    800059de:	14993c23          	sd	s1,344(s2)
  return 0;
    800059e2:	4501                	li	a0,0
}
    800059e4:	60ea                	ld	ra,152(sp)
    800059e6:	644a                	ld	s0,144(sp)
    800059e8:	64aa                	ld	s1,136(sp)
    800059ea:	690a                	ld	s2,128(sp)
    800059ec:	610d                	addi	sp,sp,160
    800059ee:	8082                	ret
    end_op(ROOTDEV);
    800059f0:	4501                	li	a0,0
    800059f2:	fffff097          	auipc	ra,0xfffff
    800059f6:	86a080e7          	jalr	-1942(ra) # 8000425c <end_op>
    return -1;
    800059fa:	557d                	li	a0,-1
    800059fc:	b7e5                	j	800059e4 <sys_chdir+0x7e>
    iunlockput(ip);
    800059fe:	8526                	mv	a0,s1
    80005a00:	ffffe097          	auipc	ra,0xffffe
    80005a04:	ff6080e7          	jalr	-10(ra) # 800039f6 <iunlockput>
    end_op(ROOTDEV);
    80005a08:	4501                	li	a0,0
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	852080e7          	jalr	-1966(ra) # 8000425c <end_op>
    return -1;
    80005a12:	557d                	li	a0,-1
    80005a14:	bfc1                	j	800059e4 <sys_chdir+0x7e>

0000000080005a16 <sys_exec>:

uint64
sys_exec(void)
{
    80005a16:	7145                	addi	sp,sp,-464
    80005a18:	e786                	sd	ra,456(sp)
    80005a1a:	e3a2                	sd	s0,448(sp)
    80005a1c:	ff26                	sd	s1,440(sp)
    80005a1e:	fb4a                	sd	s2,432(sp)
    80005a20:	f74e                	sd	s3,424(sp)
    80005a22:	f352                	sd	s4,416(sp)
    80005a24:	ef56                	sd	s5,408(sp)
    80005a26:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a28:	08000613          	li	a2,128
    80005a2c:	f4040593          	addi	a1,s0,-192
    80005a30:	4501                	li	a0,0
    80005a32:	ffffd097          	auipc	ra,0xffffd
    80005a36:	0c4080e7          	jalr	196(ra) # 80002af6 <argstr>
    80005a3a:	0e054663          	bltz	a0,80005b26 <sys_exec+0x110>
    80005a3e:	e3840593          	addi	a1,s0,-456
    80005a42:	4505                	li	a0,1
    80005a44:	ffffd097          	auipc	ra,0xffffd
    80005a48:	090080e7          	jalr	144(ra) # 80002ad4 <argaddr>
    80005a4c:	0e054763          	bltz	a0,80005b3a <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005a50:	10000613          	li	a2,256
    80005a54:	4581                	li	a1,0
    80005a56:	e4040513          	addi	a0,s0,-448
    80005a5a:	ffffb097          	auipc	ra,0xffffb
    80005a5e:	314080e7          	jalr	788(ra) # 80000d6e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a62:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a66:	89ca                	mv	s3,s2
    80005a68:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005a6a:	02000a13          	li	s4,32
    80005a6e:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a72:	00349793          	slli	a5,s1,0x3
    80005a76:	e3040593          	addi	a1,s0,-464
    80005a7a:	e3843503          	ld	a0,-456(s0)
    80005a7e:	953e                	add	a0,a0,a5
    80005a80:	ffffd097          	auipc	ra,0xffffd
    80005a84:	f98080e7          	jalr	-104(ra) # 80002a18 <fetchaddr>
    80005a88:	02054a63          	bltz	a0,80005abc <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005a8c:	e3043783          	ld	a5,-464(s0)
    80005a90:	c7a1                	beqz	a5,80005ad8 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a92:	ffffb097          	auipc	ra,0xffffb
    80005a96:	eda080e7          	jalr	-294(ra) # 8000096c <kalloc>
    80005a9a:	85aa                	mv	a1,a0
    80005a9c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005aa0:	c92d                	beqz	a0,80005b12 <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005aa2:	6605                	lui	a2,0x1
    80005aa4:	e3043503          	ld	a0,-464(s0)
    80005aa8:	ffffd097          	auipc	ra,0xffffd
    80005aac:	fc2080e7          	jalr	-62(ra) # 80002a6a <fetchstr>
    80005ab0:	00054663          	bltz	a0,80005abc <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005ab4:	0485                	addi	s1,s1,1
    80005ab6:	09a1                	addi	s3,s3,8
    80005ab8:	fb449be3          	bne	s1,s4,80005a6e <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005abc:	10090493          	addi	s1,s2,256
    80005ac0:	00093503          	ld	a0,0(s2)
    80005ac4:	cd39                	beqz	a0,80005b22 <sys_exec+0x10c>
    kfree(argv[i]);
    80005ac6:	ffffb097          	auipc	ra,0xffffb
    80005aca:	daa080e7          	jalr	-598(ra) # 80000870 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ace:	0921                	addi	s2,s2,8
    80005ad0:	fe9918e3          	bne	s2,s1,80005ac0 <sys_exec+0xaa>
  return -1;
    80005ad4:	557d                	li	a0,-1
    80005ad6:	a889                	j	80005b28 <sys_exec+0x112>
      argv[i] = 0;
    80005ad8:	0a8e                	slli	s5,s5,0x3
    80005ada:	fc040793          	addi	a5,s0,-64
    80005ade:	9abe                	add	s5,s5,a5
    80005ae0:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ae4:	e4040593          	addi	a1,s0,-448
    80005ae8:	f4040513          	addi	a0,s0,-192
    80005aec:	fffff097          	auipc	ra,0xfffff
    80005af0:	306080e7          	jalr	774(ra) # 80004df2 <exec>
    80005af4:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005af6:	10090993          	addi	s3,s2,256
    80005afa:	00093503          	ld	a0,0(s2)
    80005afe:	c901                	beqz	a0,80005b0e <sys_exec+0xf8>
    kfree(argv[i]);
    80005b00:	ffffb097          	auipc	ra,0xffffb
    80005b04:	d70080e7          	jalr	-656(ra) # 80000870 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b08:	0921                	addi	s2,s2,8
    80005b0a:	ff3918e3          	bne	s2,s3,80005afa <sys_exec+0xe4>
  return ret;
    80005b0e:	8526                	mv	a0,s1
    80005b10:	a821                	j	80005b28 <sys_exec+0x112>
      panic("sys_exec kalloc");
    80005b12:	00003517          	auipc	a0,0x3
    80005b16:	d9650513          	addi	a0,a0,-618 # 800088a8 <userret+0x818>
    80005b1a:	ffffb097          	auipc	ra,0xffffb
    80005b1e:	a3a080e7          	jalr	-1478(ra) # 80000554 <panic>
  return -1;
    80005b22:	557d                	li	a0,-1
    80005b24:	a011                	j	80005b28 <sys_exec+0x112>
    return -1;
    80005b26:	557d                	li	a0,-1
}
    80005b28:	60be                	ld	ra,456(sp)
    80005b2a:	641e                	ld	s0,448(sp)
    80005b2c:	74fa                	ld	s1,440(sp)
    80005b2e:	795a                	ld	s2,432(sp)
    80005b30:	79ba                	ld	s3,424(sp)
    80005b32:	7a1a                	ld	s4,416(sp)
    80005b34:	6afa                	ld	s5,408(sp)
    80005b36:	6179                	addi	sp,sp,464
    80005b38:	8082                	ret
    return -1;
    80005b3a:	557d                	li	a0,-1
    80005b3c:	b7f5                	j	80005b28 <sys_exec+0x112>

0000000080005b3e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b3e:	7139                	addi	sp,sp,-64
    80005b40:	fc06                	sd	ra,56(sp)
    80005b42:	f822                	sd	s0,48(sp)
    80005b44:	f426                	sd	s1,40(sp)
    80005b46:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b48:	ffffc097          	auipc	ra,0xffffc
    80005b4c:	f10080e7          	jalr	-240(ra) # 80001a58 <myproc>
    80005b50:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b52:	fd840593          	addi	a1,s0,-40
    80005b56:	4501                	li	a0,0
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	f7c080e7          	jalr	-132(ra) # 80002ad4 <argaddr>
    return -1;
    80005b60:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b62:	0e054063          	bltz	a0,80005c42 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005b66:	fc840593          	addi	a1,s0,-56
    80005b6a:	fd040513          	addi	a0,s0,-48
    80005b6e:	fffff097          	auipc	ra,0xfffff
    80005b72:	f42080e7          	jalr	-190(ra) # 80004ab0 <pipealloc>
    return -1;
    80005b76:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b78:	0c054563          	bltz	a0,80005c42 <sys_pipe+0x104>
  fd0 = -1;
    80005b7c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b80:	fd043503          	ld	a0,-48(s0)
    80005b84:	fffff097          	auipc	ra,0xfffff
    80005b88:	662080e7          	jalr	1634(ra) # 800051e6 <fdalloc>
    80005b8c:	fca42223          	sw	a0,-60(s0)
    80005b90:	08054c63          	bltz	a0,80005c28 <sys_pipe+0xea>
    80005b94:	fc843503          	ld	a0,-56(s0)
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	64e080e7          	jalr	1614(ra) # 800051e6 <fdalloc>
    80005ba0:	fca42023          	sw	a0,-64(s0)
    80005ba4:	06054863          	bltz	a0,80005c14 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ba8:	4691                	li	a3,4
    80005baa:	fc440613          	addi	a2,s0,-60
    80005bae:	fd843583          	ld	a1,-40(s0)
    80005bb2:	6ca8                	ld	a0,88(s1)
    80005bb4:	ffffc097          	auipc	ra,0xffffc
    80005bb8:	b96080e7          	jalr	-1130(ra) # 8000174a <copyout>
    80005bbc:	02054063          	bltz	a0,80005bdc <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005bc0:	4691                	li	a3,4
    80005bc2:	fc040613          	addi	a2,s0,-64
    80005bc6:	fd843583          	ld	a1,-40(s0)
    80005bca:	0591                	addi	a1,a1,4
    80005bcc:	6ca8                	ld	a0,88(s1)
    80005bce:	ffffc097          	auipc	ra,0xffffc
    80005bd2:	b7c080e7          	jalr	-1156(ra) # 8000174a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005bd6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bd8:	06055563          	bgez	a0,80005c42 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005bdc:	fc442783          	lw	a5,-60(s0)
    80005be0:	07e9                	addi	a5,a5,26
    80005be2:	078e                	slli	a5,a5,0x3
    80005be4:	97a6                	add	a5,a5,s1
    80005be6:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005bea:	fc042503          	lw	a0,-64(s0)
    80005bee:	0569                	addi	a0,a0,26
    80005bf0:	050e                	slli	a0,a0,0x3
    80005bf2:	9526                	add	a0,a0,s1
    80005bf4:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005bf8:	fd043503          	ld	a0,-48(s0)
    80005bfc:	fffff097          	auipc	ra,0xfffff
    80005c00:	b50080e7          	jalr	-1200(ra) # 8000474c <fileclose>
    fileclose(wf);
    80005c04:	fc843503          	ld	a0,-56(s0)
    80005c08:	fffff097          	auipc	ra,0xfffff
    80005c0c:	b44080e7          	jalr	-1212(ra) # 8000474c <fileclose>
    return -1;
    80005c10:	57fd                	li	a5,-1
    80005c12:	a805                	j	80005c42 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005c14:	fc442783          	lw	a5,-60(s0)
    80005c18:	0007c863          	bltz	a5,80005c28 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c1c:	01a78513          	addi	a0,a5,26
    80005c20:	050e                	slli	a0,a0,0x3
    80005c22:	9526                	add	a0,a0,s1
    80005c24:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005c28:	fd043503          	ld	a0,-48(s0)
    80005c2c:	fffff097          	auipc	ra,0xfffff
    80005c30:	b20080e7          	jalr	-1248(ra) # 8000474c <fileclose>
    fileclose(wf);
    80005c34:	fc843503          	ld	a0,-56(s0)
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	b14080e7          	jalr	-1260(ra) # 8000474c <fileclose>
    return -1;
    80005c40:	57fd                	li	a5,-1
}
    80005c42:	853e                	mv	a0,a5
    80005c44:	70e2                	ld	ra,56(sp)
    80005c46:	7442                	ld	s0,48(sp)
    80005c48:	74a2                	ld	s1,40(sp)
    80005c4a:	6121                	addi	sp,sp,64
    80005c4c:	8082                	ret

0000000080005c4e <mkdebug>:
 * 
 */
int break_point = 0;

void
mkdebug(){
    80005c4e:	1141                	addi	sp,sp,-16
    80005c50:	e406                	sd	ra,8(sp)
    80005c52:	e022                	sd	s0,0(sp)
    80005c54:	0800                	addi	s0,sp,16
  break_point++;
    80005c56:	00023797          	auipc	a5,0x23
    80005c5a:	3ee78793          	addi	a5,a5,1006 # 80029044 <break_point>
    80005c5e:	438c                	lw	a1,0(a5)
    80005c60:	2585                	addiw	a1,a1,1
    80005c62:	c38c                	sw	a1,0(a5)
  printf("### break point %d \n", break_point);
    80005c64:	2581                	sext.w	a1,a1
    80005c66:	00003517          	auipc	a0,0x3
    80005c6a:	c5250513          	addi	a0,a0,-942 # 800088b8 <userret+0x828>
    80005c6e:	ffffb097          	auipc	ra,0xffffb
    80005c72:	940080e7          	jalr	-1728(ra) # 800005ae <printf>
}
    80005c76:	60a2                	ld	ra,8(sp)
    80005c78:	6402                	ld	s0,0(sp)
    80005c7a:	0141                	addi	sp,sp,16
    80005c7c:	8082                	ret

0000000080005c7e <cleandebug>:

void
cleandebug(){
    80005c7e:	1141                	addi	sp,sp,-16
    80005c80:	e422                	sd	s0,8(sp)
    80005c82:	0800                	addi	s0,sp,16
  break_point = 0;
    80005c84:	00023797          	auipc	a5,0x23
    80005c88:	3c07a023          	sw	zero,960(a5) # 80029044 <break_point>
}
    80005c8c:	6422                	ld	s0,8(sp)
    80005c8e:	0141                	addi	sp,sp,16
    80005c90:	8082                	ret

0000000080005c92 <printinode>:

void 
printinode(struct inode* ip){
    80005c92:	1101                	addi	sp,sp,-32
    80005c94:	ec06                	sd	ra,24(sp)
    80005c96:	e822                	sd	s0,16(sp)
    80005c98:	e426                	sd	s1,8(sp)
    80005c9a:	1000                	addi	s0,sp,32
    80005c9c:	84aa                	mv	s1,a0
  printf("-----------------------------\n"); 
    80005c9e:	00003517          	auipc	a0,0x3
    80005ca2:	c3250513          	addi	a0,a0,-974 # 800088d0 <userret+0x840>
    80005ca6:	ffffb097          	auipc	ra,0xffffb
    80005caa:	908080e7          	jalr	-1784(ra) # 800005ae <printf>
  printf("dev:%d\n", ip->dev);
    80005cae:	408c                	lw	a1,0(s1)
    80005cb0:	00003517          	auipc	a0,0x3
    80005cb4:	c4050513          	addi	a0,a0,-960 # 800088f0 <userret+0x860>
    80005cb8:	ffffb097          	auipc	ra,0xffffb
    80005cbc:	8f6080e7          	jalr	-1802(ra) # 800005ae <printf>
  printf("inum:%d\n", ip->inum);
    80005cc0:	40cc                	lw	a1,4(s1)
    80005cc2:	00003517          	auipc	a0,0x3
    80005cc6:	c3650513          	addi	a0,a0,-970 # 800088f8 <userret+0x868>
    80005cca:	ffffb097          	auipc	ra,0xffffb
    80005cce:	8e4080e7          	jalr	-1820(ra) # 800005ae <printf>
  printf("target:%s\n", ip->target);
    80005cd2:	04c48593          	addi	a1,s1,76
    80005cd6:	00003517          	auipc	a0,0x3
    80005cda:	c3250513          	addi	a0,a0,-974 # 80008908 <userret+0x878>
    80005cde:	ffffb097          	auipc	ra,0xffffb
    80005ce2:	8d0080e7          	jalr	-1840(ra) # 800005ae <printf>
  printf("type:%d\n", ip->type);
    80005ce6:	0cc49583          	lh	a1,204(s1)
    80005cea:	00003517          	auipc	a0,0x3
    80005cee:	c2e50513          	addi	a0,a0,-978 # 80008918 <userret+0x888>
    80005cf2:	ffffb097          	auipc	ra,0xffffb
    80005cf6:	8bc080e7          	jalr	-1860(ra) # 800005ae <printf>
  printf("-----------------------------\n");
    80005cfa:	00003517          	auipc	a0,0x3
    80005cfe:	bd650513          	addi	a0,a0,-1066 # 800088d0 <userret+0x840>
    80005d02:	ffffb097          	auipc	ra,0xffffb
    80005d06:	8ac080e7          	jalr	-1876(ra) # 800005ae <printf>
}
    80005d0a:	60e2                	ld	ra,24(sp)
    80005d0c:	6442                	ld	s0,16(sp)
    80005d0e:	64a2                	ld	s1,8(sp)
    80005d10:	6105                	addi	sp,sp,32
    80005d12:	8082                	ret

0000000080005d14 <sys_open>:

uint64
sys_open(void)
{
    80005d14:	7131                	addi	sp,sp,-192
    80005d16:	fd06                	sd	ra,184(sp)
    80005d18:	f922                	sd	s0,176(sp)
    80005d1a:	f526                	sd	s1,168(sp)
    80005d1c:	f14a                	sd	s2,160(sp)
    80005d1e:	ed4e                	sd	s3,152(sp)
    80005d20:	0180                	addi	s0,sp,192
  char path[MAXPATH];
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d22:	08000613          	li	a2,128
    80005d26:	f5040593          	addi	a1,s0,-176
    80005d2a:	4501                	li	a0,0
    80005d2c:	ffffd097          	auipc	ra,0xffffd
    80005d30:	dca080e7          	jalr	-566(ra) # 80002af6 <argstr>
    return -1;
    80005d34:	597d                	li	s2,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005d36:	0a054a63          	bltz	a0,80005dea <sys_open+0xd6>
    80005d3a:	f4c40593          	addi	a1,s0,-180
    80005d3e:	4505                	li	a0,1
    80005d40:	ffffd097          	auipc	ra,0xffffd
    80005d44:	d72080e7          	jalr	-654(ra) # 80002ab2 <argint>
    80005d48:	0a054163          	bltz	a0,80005dea <sys_open+0xd6>

  begin_op(ROOTDEV);
    80005d4c:	4501                	li	a0,0
    80005d4e:	ffffe097          	auipc	ra,0xffffe
    80005d52:	464080e7          	jalr	1124(ra) # 800041b2 <begin_op>
  
  if(omode & O_CREATE){
    80005d56:	f4c42783          	lw	a5,-180(s0)
    80005d5a:	2007f793          	andi	a5,a5,512
    80005d5e:	c7c5                	beqz	a5,80005e06 <sys_open+0xf2>
    ip = create(path, T_FILE, 0, 0);
    80005d60:	4681                	li	a3,0
    80005d62:	4601                	li	a2,0
    80005d64:	4589                	li	a1,2
    80005d66:	f5040513          	addi	a0,s0,-176
    80005d6a:	fffff097          	auipc	ra,0xfffff
    80005d6e:	4be080e7          	jalr	1214(ra) # 80005228 <create>
    80005d72:	84aa                	mv	s1,a0
    ////printf("### create %s\n",path);
    if(ip == 0){
    80005d74:	c159                	beqz	a0,80005dfa <sys_open+0xe6>
      return -1;
    }
    
  }
  
  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005d76:	0cc49703          	lh	a4,204(s1)
    80005d7a:	478d                	li	a5,3
    80005d7c:	00f71763          	bne	a4,a5,80005d8a <sys_open+0x76>
    80005d80:	0ce4d703          	lhu	a4,206(s1)
    80005d84:	47a5                	li	a5,9
    80005d86:	12e7e863          	bltu	a5,a4,80005eb6 <sys_open+0x1a2>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d8a:	fffff097          	auipc	ra,0xfffff
    80005d8e:	906080e7          	jalr	-1786(ra) # 80004690 <filealloc>
    80005d92:	89aa                	mv	s3,a0
    80005d94:	14050d63          	beqz	a0,80005eee <sys_open+0x1da>
    80005d98:	fffff097          	auipc	ra,0xfffff
    80005d9c:	44e080e7          	jalr	1102(ra) # 800051e6 <fdalloc>
    80005da0:	892a                	mv	s2,a0
    80005da2:	14054163          	bltz	a0,80005ee4 <sys_open+0x1d0>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005da6:	0cc49703          	lh	a4,204(s1)
    80005daa:	478d                	li	a5,3
    80005dac:	12f70163          	beq	a4,a5,80005ece <sys_open+0x1ba>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005db0:	4789                	li	a5,2
    80005db2:	00f9a023          	sw	a5,0(s3)
  }

  f->ip = ip;
    80005db6:	0099bc23          	sd	s1,24(s3)
  f->off = 0;
    80005dba:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005dbe:	f4c42783          	lw	a5,-180(s0)
    80005dc2:	0017c713          	xori	a4,a5,1
    80005dc6:	8b05                	andi	a4,a4,1
    80005dc8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005dcc:	8b8d                	andi	a5,a5,3
    80005dce:	00f037b3          	snez	a5,a5
    80005dd2:	00f984a3          	sb	a5,9(s3)
  iunlock(ip);
    80005dd6:	8526                	mv	a0,s1
    80005dd8:	ffffe097          	auipc	ra,0xffffe
    80005ddc:	9d8080e7          	jalr	-1576(ra) # 800037b0 <iunlock>
  end_op(ROOTDEV);
    80005de0:	4501                	li	a0,0
    80005de2:	ffffe097          	auipc	ra,0xffffe
    80005de6:	47a080e7          	jalr	1146(ra) # 8000425c <end_op>
  return fd;
}
    80005dea:	854a                	mv	a0,s2
    80005dec:	70ea                	ld	ra,184(sp)
    80005dee:	744a                	ld	s0,176(sp)
    80005df0:	74aa                	ld	s1,168(sp)
    80005df2:	790a                	ld	s2,160(sp)
    80005df4:	69ea                	ld	s3,152(sp)
    80005df6:	6129                	addi	sp,sp,192
    80005df8:	8082                	ret
      end_op(ROOTDEV);
    80005dfa:	4501                	li	a0,0
    80005dfc:	ffffe097          	auipc	ra,0xffffe
    80005e00:	460080e7          	jalr	1120(ra) # 8000425c <end_op>
      return -1;
    80005e04:	b7dd                	j	80005dea <sys_open+0xd6>
    if((ip = namei(path)) == 0){
    80005e06:	f5040513          	addi	a0,s0,-176
    80005e0a:	ffffe097          	auipc	ra,0xffffe
    80005e0e:	14e080e7          	jalr	334(ra) # 80003f58 <namei>
    80005e12:	84aa                	mv	s1,a0
    80005e14:	c139                	beqz	a0,80005e5a <sys_open+0x146>
    if(ip->type == T_SYMLINK && !(omode & O_NOFOLLOW)){
    80005e16:	0cc51703          	lh	a4,204(a0)
    80005e1a:	4791                	li	a5,4
    80005e1c:	00f71663          	bne	a4,a5,80005e28 <sys_open+0x114>
    80005e20:	f4c42783          	lw	a5,-180(s0)
    80005e24:	8bc1                	andi	a5,a5,16
    80005e26:	c3a9                	beqz	a5,80005e68 <sys_open+0x154>
    ilock(ip);
    80005e28:	8526                	mv	a0,s1
    80005e2a:	ffffe097          	auipc	ra,0xffffe
    80005e2e:	8c2080e7          	jalr	-1854(ra) # 800036ec <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e32:	0cc49703          	lh	a4,204(s1)
    80005e36:	4785                	li	a5,1
    80005e38:	f2f71fe3          	bne	a4,a5,80005d76 <sys_open+0x62>
    80005e3c:	f4c42783          	lw	a5,-180(s0)
    80005e40:	d7a9                	beqz	a5,80005d8a <sys_open+0x76>
      iunlockput(ip);
    80005e42:	8526                	mv	a0,s1
    80005e44:	ffffe097          	auipc	ra,0xffffe
    80005e48:	bb2080e7          	jalr	-1102(ra) # 800039f6 <iunlockput>
      end_op(ROOTDEV);
    80005e4c:	4501                	li	a0,0
    80005e4e:	ffffe097          	auipc	ra,0xffffe
    80005e52:	40e080e7          	jalr	1038(ra) # 8000425c <end_op>
      return -1;
    80005e56:	597d                	li	s2,-1
    80005e58:	bf49                	j	80005dea <sys_open+0xd6>
      end_op(ROOTDEV);
    80005e5a:	4501                	li	a0,0
    80005e5c:	ffffe097          	auipc	ra,0xffffe
    80005e60:	400080e7          	jalr	1024(ra) # 8000425c <end_op>
      return -1;
    80005e64:	597d                	li	s2,-1
    80005e66:	b751                	j	80005dea <sys_open+0xd6>
    80005e68:	4929                	li	s2,10
      while ((ip = namei(ip->target)) && ip->type == T_SYMLINK)
    80005e6a:	4991                	li	s3,4
    80005e6c:	04c48513          	addi	a0,s1,76
    80005e70:	ffffe097          	auipc	ra,0xffffe
    80005e74:	0e8080e7          	jalr	232(ra) # 80003f58 <namei>
    80005e78:	84aa                	mv	s1,a0
    80005e7a:	c51d                	beqz	a0,80005ea8 <sys_open+0x194>
    80005e7c:	0cc51783          	lh	a5,204(a0)
    80005e80:	fb3794e3          	bne	a5,s3,80005e28 <sys_open+0x114>
        if(counter >= 10){
    80005e84:	397d                	addiw	s2,s2,-1
    80005e86:	fe0913e3          	bnez	s2,80005e6c <sys_open+0x158>
          printf("open(): too many symlink\n");
    80005e8a:	00003517          	auipc	a0,0x3
    80005e8e:	a9e50513          	addi	a0,a0,-1378 # 80008928 <userret+0x898>
    80005e92:	ffffa097          	auipc	ra,0xffffa
    80005e96:	71c080e7          	jalr	1820(ra) # 800005ae <printf>
          end_op(ROOTDEV);
    80005e9a:	4501                	li	a0,0
    80005e9c:	ffffe097          	auipc	ra,0xffffe
    80005ea0:	3c0080e7          	jalr	960(ra) # 8000425c <end_op>
          return -1;
    80005ea4:	597d                	li	s2,-1
    80005ea6:	b791                	j	80005dea <sys_open+0xd6>
        end_op(ROOTDEV);
    80005ea8:	4501                	li	a0,0
    80005eaa:	ffffe097          	auipc	ra,0xffffe
    80005eae:	3b2080e7          	jalr	946(ra) # 8000425c <end_op>
        return -1;
    80005eb2:	597d                	li	s2,-1
    80005eb4:	bf1d                	j	80005dea <sys_open+0xd6>
    iunlockput(ip);
    80005eb6:	8526                	mv	a0,s1
    80005eb8:	ffffe097          	auipc	ra,0xffffe
    80005ebc:	b3e080e7          	jalr	-1218(ra) # 800039f6 <iunlockput>
    end_op(ROOTDEV);
    80005ec0:	4501                	li	a0,0
    80005ec2:	ffffe097          	auipc	ra,0xffffe
    80005ec6:	39a080e7          	jalr	922(ra) # 8000425c <end_op>
    return -1;
    80005eca:	597d                	li	s2,-1
    80005ecc:	bf39                	j	80005dea <sys_open+0xd6>
    f->type = FD_DEVICE;
    80005ece:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ed2:	0ce49783          	lh	a5,206(s1)
    80005ed6:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005eda:	0d049783          	lh	a5,208(s1)
    80005ede:	02f99323          	sh	a5,38(s3)
    80005ee2:	bdd1                	j	80005db6 <sys_open+0xa2>
      fileclose(f);
    80005ee4:	854e                	mv	a0,s3
    80005ee6:	fffff097          	auipc	ra,0xfffff
    80005eea:	866080e7          	jalr	-1946(ra) # 8000474c <fileclose>
    iunlockput(ip);
    80005eee:	8526                	mv	a0,s1
    80005ef0:	ffffe097          	auipc	ra,0xffffe
    80005ef4:	b06080e7          	jalr	-1274(ra) # 800039f6 <iunlockput>
    end_op(ROOTDEV);
    80005ef8:	4501                	li	a0,0
    80005efa:	ffffe097          	auipc	ra,0xffffe
    80005efe:	362080e7          	jalr	866(ra) # 8000425c <end_op>
    return -1;
    80005f02:	597d                	li	s2,-1
    80005f04:	b5dd                	j	80005dea <sys_open+0xd6>

0000000080005f06 <sys_symlink>:
 * You will need to choose somewhere to store the target path of a symbolic link, 
 * for example, in the inode's data blocks.
 * 
 */
uint64
sys_symlink(void){
    80005f06:	7169                	addi	sp,sp,-304
    80005f08:	f606                	sd	ra,296(sp)
    80005f0a:	f222                	sd	s0,288(sp)
    80005f0c:	ee26                	sd	s1,280(sp)
    80005f0e:	ea4a                	sd	s2,272(sp)
    80005f10:	e64e                	sd	s3,264(sp)
    80005f12:	1a00                	addi	s0,sp,304
  int target_len, path_len;
  char target[MAXPATH], path[MAXPATH];
  /* struct file *f;
  int fd; */
  
  if((target_len = argstr(0, target, MAXPATH)) < 0 || 
    80005f14:	08000613          	li	a2,128
    80005f18:	f5040593          	addi	a1,s0,-176
    80005f1c:	4501                	li	a0,0
    80005f1e:	ffffd097          	auipc	ra,0xffffd
    80005f22:	bd8080e7          	jalr	-1064(ra) # 80002af6 <argstr>
    80005f26:	84aa                	mv	s1,a0
     (path_len = argstr(1, path, MAXPATH)) < 0 )
    return -1;
    80005f28:	557d                	li	a0,-1
  if((target_len = argstr(0, target, MAXPATH)) < 0 || 
    80005f2a:	0804c363          	bltz	s1,80005fb0 <sys_symlink+0xaa>
     (path_len = argstr(1, path, MAXPATH)) < 0 )
    80005f2e:	08000613          	li	a2,128
    80005f32:	ed040593          	addi	a1,s0,-304
    80005f36:	4505                	li	a0,1
    80005f38:	ffffd097          	auipc	ra,0xffffd
    80005f3c:	bbe080e7          	jalr	-1090(ra) # 80002af6 <argstr>
    80005f40:	87aa                	mv	a5,a0
    return -1;
    80005f42:	557d                	li	a0,-1
  if((target_len = argstr(0, target, MAXPATH)) < 0 || 
    80005f44:	0607c663          	bltz	a5,80005fb0 <sys_symlink+0xaa>

  
  begin_op(ROOTDEV);
    80005f48:	4501                	li	a0,0
    80005f4a:	ffffe097          	auipc	ra,0xffffe
    80005f4e:	268080e7          	jalr	616(ra) # 800041b2 <begin_op>
  /**
   * Create returns a locked inode, but namei does not
   */
  ip = create(path, T_SYMLINK, 0, 0);
    80005f52:	4681                	li	a3,0
    80005f54:	4601                	li	a2,0
    80005f56:	4591                	li	a1,4
    80005f58:	ed040513          	addi	a0,s0,-304
    80005f5c:	fffff097          	auipc	ra,0xfffff
    80005f60:	2cc080e7          	jalr	716(ra) # 80005228 <create>
    80005f64:	892a                	mv	s2,a0
  if(ip == 0){
    80005f66:	cd21                	beqz	a0,80005fbe <sys_symlink+0xb8>
    end_op(ROOTDEV);
    return -1;
  }
  if(target_len > MAXPATH)
    target_len = MAXPATH;
  memset(ip->target, 0, MAXPATH);
    80005f68:	04c50993          	addi	s3,a0,76
    80005f6c:	08000613          	li	a2,128
    80005f70:	4581                	li	a1,0
    80005f72:	854e                	mv	a0,s3
    80005f74:	ffffb097          	auipc	ra,0xffffb
    80005f78:	dfa080e7          	jalr	-518(ra) # 80000d6e <memset>
  memmove(ip->target, target, target_len);
    80005f7c:	8626                	mv	a2,s1
    80005f7e:	08000793          	li	a5,128
    80005f82:	0097d463          	bge	a5,s1,80005f8a <sys_symlink+0x84>
    80005f86:	08000613          	li	a2,128
    80005f8a:	2601                	sext.w	a2,a2
    80005f8c:	f5040593          	addi	a1,s0,-176
    80005f90:	854e                	mv	a0,s3
    80005f92:	ffffb097          	auipc	ra,0xffffb
    80005f96:	e38080e7          	jalr	-456(ra) # 80000dca <memmove>
  iunlockput(ip);
    80005f9a:	854a                	mv	a0,s2
    80005f9c:	ffffe097          	auipc	ra,0xffffe
    80005fa0:	a5a080e7          	jalr	-1446(ra) # 800039f6 <iunlockput>
  end_op(ROOTDEV);
    80005fa4:	4501                	li	a0,0
    80005fa6:	ffffe097          	auipc	ra,0xffffe
    80005faa:	2b6080e7          	jalr	694(ra) # 8000425c <end_op>
  return 0;
    80005fae:	4501                	li	a0,0
}
    80005fb0:	70b2                	ld	ra,296(sp)
    80005fb2:	7412                	ld	s0,288(sp)
    80005fb4:	64f2                	ld	s1,280(sp)
    80005fb6:	6952                	ld	s2,272(sp)
    80005fb8:	69b2                	ld	s3,264(sp)
    80005fba:	6155                	addi	sp,sp,304
    80005fbc:	8082                	ret
    end_op(ROOTDEV);
    80005fbe:	4501                	li	a0,0
    80005fc0:	ffffe097          	auipc	ra,0xffffe
    80005fc4:	29c080e7          	jalr	668(ra) # 8000425c <end_op>
    return -1;
    80005fc8:	557d                	li	a0,-1
    80005fca:	b7dd                	j	80005fb0 <sys_symlink+0xaa>
    80005fcc:	0000                	unimp
	...

0000000080005fd0 <kernelvec>:
    80005fd0:	7111                	addi	sp,sp,-256
    80005fd2:	e006                	sd	ra,0(sp)
    80005fd4:	e40a                	sd	sp,8(sp)
    80005fd6:	e80e                	sd	gp,16(sp)
    80005fd8:	ec12                	sd	tp,24(sp)
    80005fda:	f016                	sd	t0,32(sp)
    80005fdc:	f41a                	sd	t1,40(sp)
    80005fde:	f81e                	sd	t2,48(sp)
    80005fe0:	fc22                	sd	s0,56(sp)
    80005fe2:	e0a6                	sd	s1,64(sp)
    80005fe4:	e4aa                	sd	a0,72(sp)
    80005fe6:	e8ae                	sd	a1,80(sp)
    80005fe8:	ecb2                	sd	a2,88(sp)
    80005fea:	f0b6                	sd	a3,96(sp)
    80005fec:	f4ba                	sd	a4,104(sp)
    80005fee:	f8be                	sd	a5,112(sp)
    80005ff0:	fcc2                	sd	a6,120(sp)
    80005ff2:	e146                	sd	a7,128(sp)
    80005ff4:	e54a                	sd	s2,136(sp)
    80005ff6:	e94e                	sd	s3,144(sp)
    80005ff8:	ed52                	sd	s4,152(sp)
    80005ffa:	f156                	sd	s5,160(sp)
    80005ffc:	f55a                	sd	s6,168(sp)
    80005ffe:	f95e                	sd	s7,176(sp)
    80006000:	fd62                	sd	s8,184(sp)
    80006002:	e1e6                	sd	s9,192(sp)
    80006004:	e5ea                	sd	s10,200(sp)
    80006006:	e9ee                	sd	s11,208(sp)
    80006008:	edf2                	sd	t3,216(sp)
    8000600a:	f1f6                	sd	t4,224(sp)
    8000600c:	f5fa                	sd	t5,232(sp)
    8000600e:	f9fe                	sd	t6,240(sp)
    80006010:	8d5fc0ef          	jal	ra,800028e4 <kerneltrap>
    80006014:	6082                	ld	ra,0(sp)
    80006016:	6122                	ld	sp,8(sp)
    80006018:	61c2                	ld	gp,16(sp)
    8000601a:	7282                	ld	t0,32(sp)
    8000601c:	7322                	ld	t1,40(sp)
    8000601e:	73c2                	ld	t2,48(sp)
    80006020:	7462                	ld	s0,56(sp)
    80006022:	6486                	ld	s1,64(sp)
    80006024:	6526                	ld	a0,72(sp)
    80006026:	65c6                	ld	a1,80(sp)
    80006028:	6666                	ld	a2,88(sp)
    8000602a:	7686                	ld	a3,96(sp)
    8000602c:	7726                	ld	a4,104(sp)
    8000602e:	77c6                	ld	a5,112(sp)
    80006030:	7866                	ld	a6,120(sp)
    80006032:	688a                	ld	a7,128(sp)
    80006034:	692a                	ld	s2,136(sp)
    80006036:	69ca                	ld	s3,144(sp)
    80006038:	6a6a                	ld	s4,152(sp)
    8000603a:	7a8a                	ld	s5,160(sp)
    8000603c:	7b2a                	ld	s6,168(sp)
    8000603e:	7bca                	ld	s7,176(sp)
    80006040:	7c6a                	ld	s8,184(sp)
    80006042:	6c8e                	ld	s9,192(sp)
    80006044:	6d2e                	ld	s10,200(sp)
    80006046:	6dce                	ld	s11,208(sp)
    80006048:	6e6e                	ld	t3,216(sp)
    8000604a:	7e8e                	ld	t4,224(sp)
    8000604c:	7f2e                	ld	t5,232(sp)
    8000604e:	7fce                	ld	t6,240(sp)
    80006050:	6111                	addi	sp,sp,256
    80006052:	10200073          	sret
    80006056:	00000013          	nop
    8000605a:	00000013          	nop
    8000605e:	0001                	nop

0000000080006060 <timervec>:
    80006060:	34051573          	csrrw	a0,mscratch,a0
    80006064:	e10c                	sd	a1,0(a0)
    80006066:	e510                	sd	a2,8(a0)
    80006068:	e914                	sd	a3,16(a0)
    8000606a:	710c                	ld	a1,32(a0)
    8000606c:	7510                	ld	a2,40(a0)
    8000606e:	6194                	ld	a3,0(a1)
    80006070:	96b2                	add	a3,a3,a2
    80006072:	e194                	sd	a3,0(a1)
    80006074:	4589                	li	a1,2
    80006076:	14459073          	csrw	sip,a1
    8000607a:	6914                	ld	a3,16(a0)
    8000607c:	6510                	ld	a2,8(a0)
    8000607e:	610c                	ld	a1,0(a0)
    80006080:	34051573          	csrrw	a0,mscratch,a0
    80006084:	30200073          	mret
	...

000000008000608a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000608a:	1141                	addi	sp,sp,-16
    8000608c:	e422                	sd	s0,8(sp)
    8000608e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006090:	0c0007b7          	lui	a5,0xc000
    80006094:	4705                	li	a4,1
    80006096:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006098:	c3d8                	sw	a4,4(a5)
}
    8000609a:	6422                	ld	s0,8(sp)
    8000609c:	0141                	addi	sp,sp,16
    8000609e:	8082                	ret

00000000800060a0 <plicinithart>:

void
plicinithart(void)
{
    800060a0:	1141                	addi	sp,sp,-16
    800060a2:	e406                	sd	ra,8(sp)
    800060a4:	e022                	sd	s0,0(sp)
    800060a6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060a8:	ffffc097          	auipc	ra,0xffffc
    800060ac:	984080e7          	jalr	-1660(ra) # 80001a2c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800060b0:	0085171b          	slliw	a4,a0,0x8
    800060b4:	0c0027b7          	lui	a5,0xc002
    800060b8:	97ba                	add	a5,a5,a4
    800060ba:	40200713          	li	a4,1026
    800060be:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800060c2:	00d5151b          	slliw	a0,a0,0xd
    800060c6:	0c2017b7          	lui	a5,0xc201
    800060ca:	953e                	add	a0,a0,a5
    800060cc:	00052023          	sw	zero,0(a0)
}
    800060d0:	60a2                	ld	ra,8(sp)
    800060d2:	6402                	ld	s0,0(sp)
    800060d4:	0141                	addi	sp,sp,16
    800060d6:	8082                	ret

00000000800060d8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800060d8:	1141                	addi	sp,sp,-16
    800060da:	e406                	sd	ra,8(sp)
    800060dc:	e022                	sd	s0,0(sp)
    800060de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060e0:	ffffc097          	auipc	ra,0xffffc
    800060e4:	94c080e7          	jalr	-1716(ra) # 80001a2c <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800060e8:	00d5179b          	slliw	a5,a0,0xd
    800060ec:	0c201537          	lui	a0,0xc201
    800060f0:	953e                	add	a0,a0,a5
  return irq;
}
    800060f2:	4148                	lw	a0,4(a0)
    800060f4:	60a2                	ld	ra,8(sp)
    800060f6:	6402                	ld	s0,0(sp)
    800060f8:	0141                	addi	sp,sp,16
    800060fa:	8082                	ret

00000000800060fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060fc:	1101                	addi	sp,sp,-32
    800060fe:	ec06                	sd	ra,24(sp)
    80006100:	e822                	sd	s0,16(sp)
    80006102:	e426                	sd	s1,8(sp)
    80006104:	1000                	addi	s0,sp,32
    80006106:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006108:	ffffc097          	auipc	ra,0xffffc
    8000610c:	924080e7          	jalr	-1756(ra) # 80001a2c <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006110:	00d5151b          	slliw	a0,a0,0xd
    80006114:	0c2017b7          	lui	a5,0xc201
    80006118:	97aa                	add	a5,a5,a0
    8000611a:	c3c4                	sw	s1,4(a5)
}
    8000611c:	60e2                	ld	ra,24(sp)
    8000611e:	6442                	ld	s0,16(sp)
    80006120:	64a2                	ld	s1,8(sp)
    80006122:	6105                	addi	sp,sp,32
    80006124:	8082                	ret

0000000080006126 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80006126:	1141                	addi	sp,sp,-16
    80006128:	e406                	sd	ra,8(sp)
    8000612a:	e022                	sd	s0,0(sp)
    8000612c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000612e:	479d                	li	a5,7
    80006130:	06b7c963          	blt	a5,a1,800061a2 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80006134:	00151793          	slli	a5,a0,0x1
    80006138:	97aa                	add	a5,a5,a0
    8000613a:	00c79713          	slli	a4,a5,0xc
    8000613e:	0001d797          	auipc	a5,0x1d
    80006142:	ec278793          	addi	a5,a5,-318 # 80023000 <disk>
    80006146:	97ba                	add	a5,a5,a4
    80006148:	97ae                	add	a5,a5,a1
    8000614a:	6709                	lui	a4,0x2
    8000614c:	97ba                	add	a5,a5,a4
    8000614e:	0187c783          	lbu	a5,24(a5)
    80006152:	e3a5                	bnez	a5,800061b2 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80006154:	0001d817          	auipc	a6,0x1d
    80006158:	eac80813          	addi	a6,a6,-340 # 80023000 <disk>
    8000615c:	00151693          	slli	a3,a0,0x1
    80006160:	00a68733          	add	a4,a3,a0
    80006164:	0732                	slli	a4,a4,0xc
    80006166:	00e807b3          	add	a5,a6,a4
    8000616a:	6709                	lui	a4,0x2
    8000616c:	00f70633          	add	a2,a4,a5
    80006170:	6210                	ld	a2,0(a2)
    80006172:	00459893          	slli	a7,a1,0x4
    80006176:	9646                	add	a2,a2,a7
    80006178:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    8000617c:	97ae                	add	a5,a5,a1
    8000617e:	97ba                	add	a5,a5,a4
    80006180:	4605                	li	a2,1
    80006182:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80006186:	96aa                	add	a3,a3,a0
    80006188:	06b2                	slli	a3,a3,0xc
    8000618a:	0761                	addi	a4,a4,24
    8000618c:	96ba                	add	a3,a3,a4
    8000618e:	00d80533          	add	a0,a6,a3
    80006192:	ffffc097          	auipc	ra,0xffffc
    80006196:	206080e7          	jalr	518(ra) # 80002398 <wakeup>
}
    8000619a:	60a2                	ld	ra,8(sp)
    8000619c:	6402                	ld	s0,0(sp)
    8000619e:	0141                	addi	sp,sp,16
    800061a0:	8082                	ret
    panic("virtio_disk_intr 1");
    800061a2:	00002517          	auipc	a0,0x2
    800061a6:	7a650513          	addi	a0,a0,1958 # 80008948 <userret+0x8b8>
    800061aa:	ffffa097          	auipc	ra,0xffffa
    800061ae:	3aa080e7          	jalr	938(ra) # 80000554 <panic>
    panic("virtio_disk_intr 2");
    800061b2:	00002517          	auipc	a0,0x2
    800061b6:	7ae50513          	addi	a0,a0,1966 # 80008960 <userret+0x8d0>
    800061ba:	ffffa097          	auipc	ra,0xffffa
    800061be:	39a080e7          	jalr	922(ra) # 80000554 <panic>

00000000800061c2 <virtio_disk_init>:
  __sync_synchronize();
    800061c2:	0ff0000f          	fence
  if(disk[n].init)
    800061c6:	00151793          	slli	a5,a0,0x1
    800061ca:	97aa                	add	a5,a5,a0
    800061cc:	07b2                	slli	a5,a5,0xc
    800061ce:	0001d717          	auipc	a4,0x1d
    800061d2:	e3270713          	addi	a4,a4,-462 # 80023000 <disk>
    800061d6:	973e                	add	a4,a4,a5
    800061d8:	6789                	lui	a5,0x2
    800061da:	97ba                	add	a5,a5,a4
    800061dc:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    800061e0:	c391                	beqz	a5,800061e4 <virtio_disk_init+0x22>
    800061e2:	8082                	ret
{
    800061e4:	7139                	addi	sp,sp,-64
    800061e6:	fc06                	sd	ra,56(sp)
    800061e8:	f822                	sd	s0,48(sp)
    800061ea:	f426                	sd	s1,40(sp)
    800061ec:	f04a                	sd	s2,32(sp)
    800061ee:	ec4e                	sd	s3,24(sp)
    800061f0:	e852                	sd	s4,16(sp)
    800061f2:	e456                	sd	s5,8(sp)
    800061f4:	0080                	addi	s0,sp,64
    800061f6:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    800061f8:	85aa                	mv	a1,a0
    800061fa:	00002517          	auipc	a0,0x2
    800061fe:	77e50513          	addi	a0,a0,1918 # 80008978 <userret+0x8e8>
    80006202:	ffffa097          	auipc	ra,0xffffa
    80006206:	3ac080e7          	jalr	940(ra) # 800005ae <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    8000620a:	00149993          	slli	s3,s1,0x1
    8000620e:	99a6                	add	s3,s3,s1
    80006210:	09b2                	slli	s3,s3,0xc
    80006212:	6789                	lui	a5,0x2
    80006214:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80006218:	97ce                	add	a5,a5,s3
    8000621a:	00002597          	auipc	a1,0x2
    8000621e:	77658593          	addi	a1,a1,1910 # 80008990 <userret+0x900>
    80006222:	0001d517          	auipc	a0,0x1d
    80006226:	dde50513          	addi	a0,a0,-546 # 80023000 <disk>
    8000622a:	953e                	add	a0,a0,a5
    8000622c:	ffffa097          	auipc	ra,0xffffa
    80006230:	7a0080e7          	jalr	1952(ra) # 800009cc <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006234:	0014891b          	addiw	s2,s1,1
    80006238:	00c9191b          	slliw	s2,s2,0xc
    8000623c:	100007b7          	lui	a5,0x10000
    80006240:	97ca                	add	a5,a5,s2
    80006242:	4398                	lw	a4,0(a5)
    80006244:	2701                	sext.w	a4,a4
    80006246:	747277b7          	lui	a5,0x74727
    8000624a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000624e:	12f71663          	bne	a4,a5,8000637a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006252:	100007b7          	lui	a5,0x10000
    80006256:	0791                	addi	a5,a5,4
    80006258:	97ca                	add	a5,a5,s2
    8000625a:	439c                	lw	a5,0(a5)
    8000625c:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000625e:	4705                	li	a4,1
    80006260:	10e79d63          	bne	a5,a4,8000637a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006264:	100007b7          	lui	a5,0x10000
    80006268:	07a1                	addi	a5,a5,8
    8000626a:	97ca                	add	a5,a5,s2
    8000626c:	439c                	lw	a5,0(a5)
    8000626e:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006270:	4709                	li	a4,2
    80006272:	10e79463          	bne	a5,a4,8000637a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006276:	100007b7          	lui	a5,0x10000
    8000627a:	07b1                	addi	a5,a5,12
    8000627c:	97ca                	add	a5,a5,s2
    8000627e:	4398                	lw	a4,0(a5)
    80006280:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006282:	554d47b7          	lui	a5,0x554d4
    80006286:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000628a:	0ef71863          	bne	a4,a5,8000637a <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000628e:	100007b7          	lui	a5,0x10000
    80006292:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80006296:	96ca                	add	a3,a3,s2
    80006298:	4705                	li	a4,1
    8000629a:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000629c:	470d                	li	a4,3
    8000629e:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    800062a0:	01078713          	addi	a4,a5,16
    800062a4:	974a                	add	a4,a4,s2
    800062a6:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800062a8:	02078613          	addi	a2,a5,32
    800062ac:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800062ae:	c7ffe737          	lui	a4,0xc7ffe
    800062b2:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd5703>
    800062b6:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800062b8:	2701                	sext.w	a4,a4
    800062ba:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800062bc:	472d                	li	a4,11
    800062be:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800062c0:	473d                	li	a4,15
    800062c2:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800062c4:	02878713          	addi	a4,a5,40
    800062c8:	974a                	add	a4,a4,s2
    800062ca:	6685                	lui	a3,0x1
    800062cc:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    800062ce:	03078713          	addi	a4,a5,48
    800062d2:	974a                	add	a4,a4,s2
    800062d4:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    800062d8:	03478793          	addi	a5,a5,52
    800062dc:	97ca                	add	a5,a5,s2
    800062de:	439c                	lw	a5,0(a5)
    800062e0:	2781                	sext.w	a5,a5
  if(max == 0)
    800062e2:	c7c5                	beqz	a5,8000638a <virtio_disk_init+0x1c8>
  if(max < NUM)
    800062e4:	471d                	li	a4,7
    800062e6:	0af77a63          	bgeu	a4,a5,8000639a <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800062ea:	10000ab7          	lui	s5,0x10000
    800062ee:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    800062f2:	97ca                	add	a5,a5,s2
    800062f4:	4721                	li	a4,8
    800062f6:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    800062f8:	0001da17          	auipc	s4,0x1d
    800062fc:	d08a0a13          	addi	s4,s4,-760 # 80023000 <disk>
    80006300:	99d2                	add	s3,s3,s4
    80006302:	6609                	lui	a2,0x2
    80006304:	4581                	li	a1,0
    80006306:	854e                	mv	a0,s3
    80006308:	ffffb097          	auipc	ra,0xffffb
    8000630c:	a66080e7          	jalr	-1434(ra) # 80000d6e <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    80006310:	040a8a93          	addi	s5,s5,64
    80006314:	9956                	add	s2,s2,s5
    80006316:	00c9d793          	srli	a5,s3,0xc
    8000631a:	2781                	sext.w	a5,a5
    8000631c:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80006320:	00149693          	slli	a3,s1,0x1
    80006324:	009687b3          	add	a5,a3,s1
    80006328:	07b2                	slli	a5,a5,0xc
    8000632a:	97d2                	add	a5,a5,s4
    8000632c:	6609                	lui	a2,0x2
    8000632e:	97b2                	add	a5,a5,a2
    80006330:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006334:	08098713          	addi	a4,s3,128
    80006338:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    8000633a:	6705                	lui	a4,0x1
    8000633c:	99ba                	add	s3,s3,a4
    8000633e:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80006342:	4705                	li	a4,1
    80006344:	00e78c23          	sb	a4,24(a5)
    80006348:	00e78ca3          	sb	a4,25(a5)
    8000634c:	00e78d23          	sb	a4,26(a5)
    80006350:	00e78da3          	sb	a4,27(a5)
    80006354:	00e78e23          	sb	a4,28(a5)
    80006358:	00e78ea3          	sb	a4,29(a5)
    8000635c:	00e78f23          	sb	a4,30(a5)
    80006360:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80006364:	0ae7a423          	sw	a4,168(a5)
}
    80006368:	70e2                	ld	ra,56(sp)
    8000636a:	7442                	ld	s0,48(sp)
    8000636c:	74a2                	ld	s1,40(sp)
    8000636e:	7902                	ld	s2,32(sp)
    80006370:	69e2                	ld	s3,24(sp)
    80006372:	6a42                	ld	s4,16(sp)
    80006374:	6aa2                	ld	s5,8(sp)
    80006376:	6121                	addi	sp,sp,64
    80006378:	8082                	ret
    panic("could not find virtio disk");
    8000637a:	00002517          	auipc	a0,0x2
    8000637e:	62650513          	addi	a0,a0,1574 # 800089a0 <userret+0x910>
    80006382:	ffffa097          	auipc	ra,0xffffa
    80006386:	1d2080e7          	jalr	466(ra) # 80000554 <panic>
    panic("virtio disk has no queue 0");
    8000638a:	00002517          	auipc	a0,0x2
    8000638e:	63650513          	addi	a0,a0,1590 # 800089c0 <userret+0x930>
    80006392:	ffffa097          	auipc	ra,0xffffa
    80006396:	1c2080e7          	jalr	450(ra) # 80000554 <panic>
    panic("virtio disk max queue too short");
    8000639a:	00002517          	auipc	a0,0x2
    8000639e:	64650513          	addi	a0,a0,1606 # 800089e0 <userret+0x950>
    800063a2:	ffffa097          	auipc	ra,0xffffa
    800063a6:	1b2080e7          	jalr	434(ra) # 80000554 <panic>

00000000800063aa <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    800063aa:	7135                	addi	sp,sp,-160
    800063ac:	ed06                	sd	ra,152(sp)
    800063ae:	e922                	sd	s0,144(sp)
    800063b0:	e526                	sd	s1,136(sp)
    800063b2:	e14a                	sd	s2,128(sp)
    800063b4:	fcce                	sd	s3,120(sp)
    800063b6:	f8d2                	sd	s4,112(sp)
    800063b8:	f4d6                	sd	s5,104(sp)
    800063ba:	f0da                	sd	s6,96(sp)
    800063bc:	ecde                	sd	s7,88(sp)
    800063be:	e8e2                	sd	s8,80(sp)
    800063c0:	e4e6                	sd	s9,72(sp)
    800063c2:	e0ea                	sd	s10,64(sp)
    800063c4:	fc6e                	sd	s11,56(sp)
    800063c6:	1100                	addi	s0,sp,160
    800063c8:	8aaa                	mv	s5,a0
    800063ca:	8c2e                	mv	s8,a1
    800063cc:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    800063ce:	45dc                	lw	a5,12(a1)
    800063d0:	0017979b          	slliw	a5,a5,0x1
    800063d4:	1782                	slli	a5,a5,0x20
    800063d6:	9381                	srli	a5,a5,0x20
    800063d8:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    800063dc:	00151493          	slli	s1,a0,0x1
    800063e0:	94aa                	add	s1,s1,a0
    800063e2:	04b2                	slli	s1,s1,0xc
    800063e4:	6909                	lui	s2,0x2
    800063e6:	0b090c93          	addi	s9,s2,176 # 20b0 <_entry-0x7fffdf50>
    800063ea:	9ca6                	add	s9,s9,s1
    800063ec:	0001d997          	auipc	s3,0x1d
    800063f0:	c1498993          	addi	s3,s3,-1004 # 80023000 <disk>
    800063f4:	9cce                	add	s9,s9,s3
    800063f6:	8566                	mv	a0,s9
    800063f8:	ffffa097          	auipc	ra,0xffffa
    800063fc:	6a8080e7          	jalr	1704(ra) # 80000aa0 <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006400:	0961                	addi	s2,s2,24
    80006402:	94ca                	add	s1,s1,s2
    80006404:	99a6                	add	s3,s3,s1
  for(int i = 0; i < 3; i++){
    80006406:	4a01                	li	s4,0
  for(int i = 0; i < NUM; i++){
    80006408:	44a1                	li	s1,8
      disk[n].free[i] = 0;
    8000640a:	001a9793          	slli	a5,s5,0x1
    8000640e:	97d6                	add	a5,a5,s5
    80006410:	07b2                	slli	a5,a5,0xc
    80006412:	0001db97          	auipc	s7,0x1d
    80006416:	beeb8b93          	addi	s7,s7,-1042 # 80023000 <disk>
    8000641a:	9bbe                	add	s7,s7,a5
    8000641c:	a8a9                	j	80006476 <virtio_disk_rw+0xcc>
    8000641e:	00fb8733          	add	a4,s7,a5
    80006422:	9742                	add	a4,a4,a6
    80006424:	00070c23          	sb	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    idx[i] = alloc_desc(n);
    80006428:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000642a:	0207c263          	bltz	a5,8000644e <virtio_disk_rw+0xa4>
  for(int i = 0; i < 3; i++){
    8000642e:	2905                	addiw	s2,s2,1
    80006430:	0611                	addi	a2,a2,4
    80006432:	1ca90463          	beq	s2,a0,800065fa <virtio_disk_rw+0x250>
    idx[i] = alloc_desc(n);
    80006436:	85b2                	mv	a1,a2
    80006438:	874e                	mv	a4,s3
  for(int i = 0; i < NUM; i++){
    8000643a:	87d2                	mv	a5,s4
    if(disk[n].free[i]){
    8000643c:	00074683          	lbu	a3,0(a4)
    80006440:	fef9                	bnez	a3,8000641e <virtio_disk_rw+0x74>
  for(int i = 0; i < NUM; i++){
    80006442:	2785                	addiw	a5,a5,1
    80006444:	0705                	addi	a4,a4,1
    80006446:	fe979be3          	bne	a5,s1,8000643c <virtio_disk_rw+0x92>
    idx[i] = alloc_desc(n);
    8000644a:	57fd                	li	a5,-1
    8000644c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000644e:	01205e63          	blez	s2,8000646a <virtio_disk_rw+0xc0>
    80006452:	8d52                	mv	s10,s4
        free_desc(n, idx[j]);
    80006454:	000b2583          	lw	a1,0(s6)
    80006458:	8556                	mv	a0,s5
    8000645a:	00000097          	auipc	ra,0x0
    8000645e:	ccc080e7          	jalr	-820(ra) # 80006126 <free_desc>
      for(int j = 0; j < i; j++)
    80006462:	2d05                	addiw	s10,s10,1
    80006464:	0b11                	addi	s6,s6,4
    80006466:	ffa917e3          	bne	s2,s10,80006454 <virtio_disk_rw+0xaa>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    8000646a:	85e6                	mv	a1,s9
    8000646c:	854e                	mv	a0,s3
    8000646e:	ffffc097          	auipc	ra,0xffffc
    80006472:	daa080e7          	jalr	-598(ra) # 80002218 <sleep>
  for(int i = 0; i < 3; i++){
    80006476:	f8040b13          	addi	s6,s0,-128
{
    8000647a:	865a                	mv	a2,s6
  for(int i = 0; i < 3; i++){
    8000647c:	8952                	mv	s2,s4
      disk[n].free[i] = 0;
    8000647e:	6809                	lui	a6,0x2
  for(int i = 0; i < 3; i++){
    80006480:	450d                	li	a0,3
    80006482:	bf55                	j	80006436 <virtio_disk_rw+0x8c>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80006484:	001a9793          	slli	a5,s5,0x1
    80006488:	97d6                	add	a5,a5,s5
    8000648a:	07b2                	slli	a5,a5,0xc
    8000648c:	0001d717          	auipc	a4,0x1d
    80006490:	b7470713          	addi	a4,a4,-1164 # 80023000 <disk>
    80006494:	973e                	add	a4,a4,a5
    80006496:	6789                	lui	a5,0x2
    80006498:	97ba                	add	a5,a5,a4
    8000649a:	639c                	ld	a5,0(a5)
    8000649c:	97b6                	add	a5,a5,a3
    8000649e:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800064a2:	0001d517          	auipc	a0,0x1d
    800064a6:	b5e50513          	addi	a0,a0,-1186 # 80023000 <disk>
    800064aa:	001a9793          	slli	a5,s5,0x1
    800064ae:	01578733          	add	a4,a5,s5
    800064b2:	0732                	slli	a4,a4,0xc
    800064b4:	972a                	add	a4,a4,a0
    800064b6:	6609                	lui	a2,0x2
    800064b8:	9732                	add	a4,a4,a2
    800064ba:	6310                	ld	a2,0(a4)
    800064bc:	9636                	add	a2,a2,a3
    800064be:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800064c2:	0015e593          	ori	a1,a1,1
    800064c6:	00b61623          	sh	a1,12(a2)
  disk[n].desc[idx[1]].next = idx[2];
    800064ca:	f8842603          	lw	a2,-120(s0)
    800064ce:	630c                	ld	a1,0(a4)
    800064d0:	96ae                	add	a3,a3,a1
    800064d2:	00c69723          	sh	a2,14(a3) # 100e <_entry-0x7fffeff2>

  disk[n].info[idx[0]].status = 0;
    800064d6:	97d6                	add	a5,a5,s5
    800064d8:	07a2                	slli	a5,a5,0x8
    800064da:	97a6                	add	a5,a5,s1
    800064dc:	20078793          	addi	a5,a5,512
    800064e0:	0792                	slli	a5,a5,0x4
    800064e2:	97aa                	add	a5,a5,a0
    800064e4:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    800064e8:	00461693          	slli	a3,a2,0x4
    800064ec:	00073803          	ld	a6,0(a4)
    800064f0:	9836                	add	a6,a6,a3
    800064f2:	20348613          	addi	a2,s1,515
    800064f6:	001a9593          	slli	a1,s5,0x1
    800064fa:	95d6                	add	a1,a1,s5
    800064fc:	05a2                	slli	a1,a1,0x8
    800064fe:	962e                	add	a2,a2,a1
    80006500:	0612                	slli	a2,a2,0x4
    80006502:	962a                	add	a2,a2,a0
    80006504:	00c83023          	sd	a2,0(a6) # 2000 <_entry-0x7fffe000>
  disk[n].desc[idx[2]].len = 1;
    80006508:	630c                	ld	a1,0(a4)
    8000650a:	95b6                	add	a1,a1,a3
    8000650c:	4605                	li	a2,1
    8000650e:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006510:	630c                	ld	a1,0(a4)
    80006512:	95b6                	add	a1,a1,a3
    80006514:	4509                	li	a0,2
    80006516:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    8000651a:	630c                	ld	a1,0(a4)
    8000651c:	96ae                	add	a3,a3,a1
    8000651e:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006522:	00cc2223          	sw	a2,4(s8) # fffffffffffff004 <end+0xffffffff7ffd5fa8>
  disk[n].info[idx[0]].b = b;
    80006526:	0387b423          	sd	s8,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    8000652a:	6714                	ld	a3,8(a4)
    8000652c:	0026d783          	lhu	a5,2(a3)
    80006530:	8b9d                	andi	a5,a5,7
    80006532:	0789                	addi	a5,a5,2
    80006534:	0786                	slli	a5,a5,0x1
    80006536:	97b6                	add	a5,a5,a3
    80006538:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    8000653c:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006540:	6718                	ld	a4,8(a4)
    80006542:	00275783          	lhu	a5,2(a4)
    80006546:	2785                	addiw	a5,a5,1
    80006548:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000654c:	001a879b          	addiw	a5,s5,1
    80006550:	00c7979b          	slliw	a5,a5,0xc
    80006554:	10000737          	lui	a4,0x10000
    80006558:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    8000655c:	97ba                	add	a5,a5,a4
    8000655e:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006562:	004c2783          	lw	a5,4(s8)
    80006566:	00c79d63          	bne	a5,a2,80006580 <virtio_disk_rw+0x1d6>
    8000656a:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    8000656c:	85e6                	mv	a1,s9
    8000656e:	8562                	mv	a0,s8
    80006570:	ffffc097          	auipc	ra,0xffffc
    80006574:	ca8080e7          	jalr	-856(ra) # 80002218 <sleep>
  while(b->disk == 1) {
    80006578:	004c2783          	lw	a5,4(s8)
    8000657c:	fe9788e3          	beq	a5,s1,8000656c <virtio_disk_rw+0x1c2>
  }

  disk[n].info[idx[0]].b = 0;
    80006580:	f8042483          	lw	s1,-128(s0)
    80006584:	001a9793          	slli	a5,s5,0x1
    80006588:	97d6                	add	a5,a5,s5
    8000658a:	07a2                	slli	a5,a5,0x8
    8000658c:	97a6                	add	a5,a5,s1
    8000658e:	20078793          	addi	a5,a5,512
    80006592:	0792                	slli	a5,a5,0x4
    80006594:	0001d717          	auipc	a4,0x1d
    80006598:	a6c70713          	addi	a4,a4,-1428 # 80023000 <disk>
    8000659c:	97ba                	add	a5,a5,a4
    8000659e:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800065a2:	001a9793          	slli	a5,s5,0x1
    800065a6:	97d6                	add	a5,a5,s5
    800065a8:	07b2                	slli	a5,a5,0xc
    800065aa:	97ba                	add	a5,a5,a4
    800065ac:	6909                	lui	s2,0x2
    800065ae:	993e                	add	s2,s2,a5
    800065b0:	a019                	j	800065b6 <virtio_disk_rw+0x20c>
      i = disk[n].desc[i].next;
    800065b2:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    800065b6:	85a6                	mv	a1,s1
    800065b8:	8556                	mv	a0,s5
    800065ba:	00000097          	auipc	ra,0x0
    800065be:	b6c080e7          	jalr	-1172(ra) # 80006126 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800065c2:	0492                	slli	s1,s1,0x4
    800065c4:	00093783          	ld	a5,0(s2) # 2000 <_entry-0x7fffe000>
    800065c8:	94be                	add	s1,s1,a5
    800065ca:	00c4d783          	lhu	a5,12(s1)
    800065ce:	8b85                	andi	a5,a5,1
    800065d0:	f3ed                	bnez	a5,800065b2 <virtio_disk_rw+0x208>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    800065d2:	8566                	mv	a0,s9
    800065d4:	ffffa097          	auipc	ra,0xffffa
    800065d8:	59c080e7          	jalr	1436(ra) # 80000b70 <release>
}
    800065dc:	60ea                	ld	ra,152(sp)
    800065de:	644a                	ld	s0,144(sp)
    800065e0:	64aa                	ld	s1,136(sp)
    800065e2:	690a                	ld	s2,128(sp)
    800065e4:	79e6                	ld	s3,120(sp)
    800065e6:	7a46                	ld	s4,112(sp)
    800065e8:	7aa6                	ld	s5,104(sp)
    800065ea:	7b06                	ld	s6,96(sp)
    800065ec:	6be6                	ld	s7,88(sp)
    800065ee:	6c46                	ld	s8,80(sp)
    800065f0:	6ca6                	ld	s9,72(sp)
    800065f2:	6d06                	ld	s10,64(sp)
    800065f4:	7de2                	ld	s11,56(sp)
    800065f6:	610d                	addi	sp,sp,160
    800065f8:	8082                	ret
  if(write)
    800065fa:	01b037b3          	snez	a5,s11
    800065fe:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006602:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006606:	f6843783          	ld	a5,-152(s0)
    8000660a:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000660e:	f8042483          	lw	s1,-128(s0)
    80006612:	00449993          	slli	s3,s1,0x4
    80006616:	001a9793          	slli	a5,s5,0x1
    8000661a:	97d6                	add	a5,a5,s5
    8000661c:	07b2                	slli	a5,a5,0xc
    8000661e:	0001d917          	auipc	s2,0x1d
    80006622:	9e290913          	addi	s2,s2,-1566 # 80023000 <disk>
    80006626:	97ca                	add	a5,a5,s2
    80006628:	6909                	lui	s2,0x2
    8000662a:	993e                	add	s2,s2,a5
    8000662c:	00093a03          	ld	s4,0(s2) # 2000 <_entry-0x7fffe000>
    80006630:	9a4e                	add	s4,s4,s3
    80006632:	f7040513          	addi	a0,s0,-144
    80006636:	ffffb097          	auipc	ra,0xffffb
    8000663a:	b74080e7          	jalr	-1164(ra) # 800011aa <kvmpa>
    8000663e:	00aa3023          	sd	a0,0(s4)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006642:	00093783          	ld	a5,0(s2)
    80006646:	97ce                	add	a5,a5,s3
    80006648:	4741                	li	a4,16
    8000664a:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000664c:	00093783          	ld	a5,0(s2)
    80006650:	97ce                	add	a5,a5,s3
    80006652:	4705                	li	a4,1
    80006654:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    80006658:	f8442683          	lw	a3,-124(s0)
    8000665c:	00093783          	ld	a5,0(s2)
    80006660:	99be                	add	s3,s3,a5
    80006662:	00d99723          	sh	a3,14(s3)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006666:	0692                	slli	a3,a3,0x4
    80006668:	00093783          	ld	a5,0(s2)
    8000666c:	97b6                	add	a5,a5,a3
    8000666e:	060c0713          	addi	a4,s8,96
    80006672:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006674:	00093783          	ld	a5,0(s2)
    80006678:	97b6                	add	a5,a5,a3
    8000667a:	40000713          	li	a4,1024
    8000667e:	c798                	sw	a4,8(a5)
  if(write)
    80006680:	e00d92e3          	bnez	s11,80006484 <virtio_disk_rw+0xda>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006684:	001a9793          	slli	a5,s5,0x1
    80006688:	97d6                	add	a5,a5,s5
    8000668a:	07b2                	slli	a5,a5,0xc
    8000668c:	0001d717          	auipc	a4,0x1d
    80006690:	97470713          	addi	a4,a4,-1676 # 80023000 <disk>
    80006694:	973e                	add	a4,a4,a5
    80006696:	6789                	lui	a5,0x2
    80006698:	97ba                	add	a5,a5,a4
    8000669a:	639c                	ld	a5,0(a5)
    8000669c:	97b6                	add	a5,a5,a3
    8000669e:	4709                	li	a4,2
    800066a0:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    800066a4:	bbfd                	j	800064a2 <virtio_disk_rw+0xf8>

00000000800066a6 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    800066a6:	7139                	addi	sp,sp,-64
    800066a8:	fc06                	sd	ra,56(sp)
    800066aa:	f822                	sd	s0,48(sp)
    800066ac:	f426                	sd	s1,40(sp)
    800066ae:	f04a                	sd	s2,32(sp)
    800066b0:	ec4e                	sd	s3,24(sp)
    800066b2:	e852                	sd	s4,16(sp)
    800066b4:	e456                	sd	s5,8(sp)
    800066b6:	0080                	addi	s0,sp,64
    800066b8:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    800066ba:	00151913          	slli	s2,a0,0x1
    800066be:	00a90a33          	add	s4,s2,a0
    800066c2:	0a32                	slli	s4,s4,0xc
    800066c4:	6989                	lui	s3,0x2
    800066c6:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    800066ca:	9a3e                	add	s4,s4,a5
    800066cc:	0001da97          	auipc	s5,0x1d
    800066d0:	934a8a93          	addi	s5,s5,-1740 # 80023000 <disk>
    800066d4:	9a56                	add	s4,s4,s5
    800066d6:	8552                	mv	a0,s4
    800066d8:	ffffa097          	auipc	ra,0xffffa
    800066dc:	3c8080e7          	jalr	968(ra) # 80000aa0 <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    800066e0:	9926                	add	s2,s2,s1
    800066e2:	0932                	slli	s2,s2,0xc
    800066e4:	9956                	add	s2,s2,s5
    800066e6:	99ca                	add	s3,s3,s2
    800066e8:	0209d783          	lhu	a5,32(s3)
    800066ec:	0109b703          	ld	a4,16(s3)
    800066f0:	00275683          	lhu	a3,2(a4)
    800066f4:	8ebd                	xor	a3,a3,a5
    800066f6:	8a9d                	andi	a3,a3,7
    800066f8:	c2a5                	beqz	a3,80006758 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    800066fa:	8956                	mv	s2,s5
    800066fc:	00149693          	slli	a3,s1,0x1
    80006700:	96a6                	add	a3,a3,s1
    80006702:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006706:	06b2                	slli	a3,a3,0xc
    80006708:	96d6                	add	a3,a3,s5
    8000670a:	6489                	lui	s1,0x2
    8000670c:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    8000670e:	078e                	slli	a5,a5,0x3
    80006710:	97ba                	add	a5,a5,a4
    80006712:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006714:	00f98733          	add	a4,s3,a5
    80006718:	20070713          	addi	a4,a4,512
    8000671c:	0712                	slli	a4,a4,0x4
    8000671e:	974a                	add	a4,a4,s2
    80006720:	03074703          	lbu	a4,48(a4)
    80006724:	eb21                	bnez	a4,80006774 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006726:	97ce                	add	a5,a5,s3
    80006728:	20078793          	addi	a5,a5,512
    8000672c:	0792                	slli	a5,a5,0x4
    8000672e:	97ca                	add	a5,a5,s2
    80006730:	7798                	ld	a4,40(a5)
    80006732:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006736:	7788                	ld	a0,40(a5)
    80006738:	ffffc097          	auipc	ra,0xffffc
    8000673c:	c60080e7          	jalr	-928(ra) # 80002398 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006740:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006744:	2785                	addiw	a5,a5,1
    80006746:	8b9d                	andi	a5,a5,7
    80006748:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    8000674c:	6898                	ld	a4,16(s1)
    8000674e:	00275683          	lhu	a3,2(a4)
    80006752:	8a9d                	andi	a3,a3,7
    80006754:	faf69de3          	bne	a3,a5,8000670e <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    80006758:	8552                	mv	a0,s4
    8000675a:	ffffa097          	auipc	ra,0xffffa
    8000675e:	416080e7          	jalr	1046(ra) # 80000b70 <release>
}
    80006762:	70e2                	ld	ra,56(sp)
    80006764:	7442                	ld	s0,48(sp)
    80006766:	74a2                	ld	s1,40(sp)
    80006768:	7902                	ld	s2,32(sp)
    8000676a:	69e2                	ld	s3,24(sp)
    8000676c:	6a42                	ld	s4,16(sp)
    8000676e:	6aa2                	ld	s5,8(sp)
    80006770:	6121                	addi	sp,sp,64
    80006772:	8082                	ret
      panic("virtio_disk_intr status");
    80006774:	00002517          	auipc	a0,0x2
    80006778:	28c50513          	addi	a0,a0,652 # 80008a00 <userret+0x970>
    8000677c:	ffffa097          	auipc	ra,0xffffa
    80006780:	dd8080e7          	jalr	-552(ra) # 80000554 <panic>

0000000080006784 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80006784:	1141                	addi	sp,sp,-16
    80006786:	e422                	sd	s0,8(sp)
    80006788:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    8000678a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000678e:	01d7d79b          	srliw	a5,a5,0x1d
    80006792:	9dbd                	addw	a1,a1,a5
    80006794:	0075f713          	andi	a4,a1,7
    80006798:	9f1d                	subw	a4,a4,a5
    8000679a:	4785                	li	a5,1
    8000679c:	00e797bb          	sllw	a5,a5,a4
    800067a0:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    800067a4:	4035d59b          	sraiw	a1,a1,0x3
    800067a8:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    800067aa:	0005c503          	lbu	a0,0(a1)
    800067ae:	8d7d                	and	a0,a0,a5
    800067b0:	8d1d                	sub	a0,a0,a5
}
    800067b2:	00153513          	seqz	a0,a0
    800067b6:	6422                	ld	s0,8(sp)
    800067b8:	0141                	addi	sp,sp,16
    800067ba:	8082                	ret

00000000800067bc <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    800067bc:	1141                	addi	sp,sp,-16
    800067be:	e422                	sd	s0,8(sp)
    800067c0:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800067c2:	41f5d79b          	sraiw	a5,a1,0x1f
    800067c6:	01d7d79b          	srliw	a5,a5,0x1d
    800067ca:	9dbd                	addw	a1,a1,a5
    800067cc:	4035d71b          	sraiw	a4,a1,0x3
    800067d0:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800067d2:	899d                	andi	a1,a1,7
    800067d4:	9d9d                	subw	a1,a1,a5
    800067d6:	4785                	li	a5,1
    800067d8:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    800067dc:	00054783          	lbu	a5,0(a0)
    800067e0:	8ddd                	or	a1,a1,a5
    800067e2:	00b50023          	sb	a1,0(a0)
}
    800067e6:	6422                	ld	s0,8(sp)
    800067e8:	0141                	addi	sp,sp,16
    800067ea:	8082                	ret

00000000800067ec <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    800067ec:	1141                	addi	sp,sp,-16
    800067ee:	e422                	sd	s0,8(sp)
    800067f0:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800067f2:	41f5d79b          	sraiw	a5,a1,0x1f
    800067f6:	01d7d79b          	srliw	a5,a5,0x1d
    800067fa:	9dbd                	addw	a1,a1,a5
    800067fc:	4035d71b          	sraiw	a4,a1,0x3
    80006800:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006802:	899d                	andi	a1,a1,7
    80006804:	9d9d                	subw	a1,a1,a5
    80006806:	4785                	li	a5,1
    80006808:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    8000680c:	fff5c593          	not	a1,a1
    80006810:	00054783          	lbu	a5,0(a0)
    80006814:	8dfd                	and	a1,a1,a5
    80006816:	00b50023          	sb	a1,0(a0)
}
    8000681a:	6422                	ld	s0,8(sp)
    8000681c:	0141                	addi	sp,sp,16
    8000681e:	8082                	ret

0000000080006820 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006820:	715d                	addi	sp,sp,-80
    80006822:	e486                	sd	ra,72(sp)
    80006824:	e0a2                	sd	s0,64(sp)
    80006826:	fc26                	sd	s1,56(sp)
    80006828:	f84a                	sd	s2,48(sp)
    8000682a:	f44e                	sd	s3,40(sp)
    8000682c:	f052                	sd	s4,32(sp)
    8000682e:	ec56                	sd	s5,24(sp)
    80006830:	e85a                	sd	s6,16(sp)
    80006832:	e45e                	sd	s7,8(sp)
    80006834:	0880                	addi	s0,sp,80
    80006836:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006838:	08b05b63          	blez	a1,800068ce <bd_print_vector+0xae>
    8000683c:	89aa                	mv	s3,a0
    8000683e:	4481                	li	s1,0
  lb = 0;
    80006840:	4a81                	li	s5,0
  last = 1;
    80006842:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006844:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006846:	00002b97          	auipc	s7,0x2
    8000684a:	1d2b8b93          	addi	s7,s7,466 # 80008a18 <userret+0x988>
    8000684e:	a821                	j	80006866 <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80006850:	85a6                	mv	a1,s1
    80006852:	854e                	mv	a0,s3
    80006854:	00000097          	auipc	ra,0x0
    80006858:	f30080e7          	jalr	-208(ra) # 80006784 <bit_isset>
    8000685c:	892a                	mv	s2,a0
    8000685e:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006860:	2485                	addiw	s1,s1,1
    80006862:	029a0463          	beq	s4,s1,8000688a <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006866:	85a6                	mv	a1,s1
    80006868:	854e                	mv	a0,s3
    8000686a:	00000097          	auipc	ra,0x0
    8000686e:	f1a080e7          	jalr	-230(ra) # 80006784 <bit_isset>
    80006872:	ff2507e3          	beq	a0,s2,80006860 <bd_print_vector+0x40>
    if(last == 1)
    80006876:	fd691de3          	bne	s2,s6,80006850 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    8000687a:	8626                	mv	a2,s1
    8000687c:	85d6                	mv	a1,s5
    8000687e:	855e                	mv	a0,s7
    80006880:	ffffa097          	auipc	ra,0xffffa
    80006884:	d2e080e7          	jalr	-722(ra) # 800005ae <printf>
    80006888:	b7e1                	j	80006850 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    8000688a:	000a8563          	beqz	s5,80006894 <bd_print_vector+0x74>
    8000688e:	4785                	li	a5,1
    80006890:	00f91c63          	bne	s2,a5,800068a8 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006894:	8652                	mv	a2,s4
    80006896:	85d6                	mv	a1,s5
    80006898:	00002517          	auipc	a0,0x2
    8000689c:	18050513          	addi	a0,a0,384 # 80008a18 <userret+0x988>
    800068a0:	ffffa097          	auipc	ra,0xffffa
    800068a4:	d0e080e7          	jalr	-754(ra) # 800005ae <printf>
  }
  printf("\n");
    800068a8:	00002517          	auipc	a0,0x2
    800068ac:	9e850513          	addi	a0,a0,-1560 # 80008290 <userret+0x200>
    800068b0:	ffffa097          	auipc	ra,0xffffa
    800068b4:	cfe080e7          	jalr	-770(ra) # 800005ae <printf>
}
    800068b8:	60a6                	ld	ra,72(sp)
    800068ba:	6406                	ld	s0,64(sp)
    800068bc:	74e2                	ld	s1,56(sp)
    800068be:	7942                	ld	s2,48(sp)
    800068c0:	79a2                	ld	s3,40(sp)
    800068c2:	7a02                	ld	s4,32(sp)
    800068c4:	6ae2                	ld	s5,24(sp)
    800068c6:	6b42                	ld	s6,16(sp)
    800068c8:	6ba2                	ld	s7,8(sp)
    800068ca:	6161                	addi	sp,sp,80
    800068cc:	8082                	ret
  lb = 0;
    800068ce:	4a81                	li	s5,0
    800068d0:	b7d1                	j	80006894 <bd_print_vector+0x74>

00000000800068d2 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    800068d2:	00022697          	auipc	a3,0x22
    800068d6:	7866a683          	lw	a3,1926(a3) # 80029058 <nsizes>
    800068da:	10d05063          	blez	a3,800069da <bd_print+0x108>
bd_print() {
    800068de:	711d                	addi	sp,sp,-96
    800068e0:	ec86                	sd	ra,88(sp)
    800068e2:	e8a2                	sd	s0,80(sp)
    800068e4:	e4a6                	sd	s1,72(sp)
    800068e6:	e0ca                	sd	s2,64(sp)
    800068e8:	fc4e                	sd	s3,56(sp)
    800068ea:	f852                	sd	s4,48(sp)
    800068ec:	f456                	sd	s5,40(sp)
    800068ee:	f05a                	sd	s6,32(sp)
    800068f0:	ec5e                	sd	s7,24(sp)
    800068f2:	e862                	sd	s8,16(sp)
    800068f4:	e466                	sd	s9,8(sp)
    800068f6:	e06a                	sd	s10,0(sp)
    800068f8:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    800068fa:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800068fc:	4a85                	li	s5,1
    800068fe:	4c41                	li	s8,16
    80006900:	00002b97          	auipc	s7,0x2
    80006904:	128b8b93          	addi	s7,s7,296 # 80008a28 <userret+0x998>
    lst_print(&bd_sizes[k].free);
    80006908:	00022a17          	auipc	s4,0x22
    8000690c:	748a0a13          	addi	s4,s4,1864 # 80029050 <bd_sizes>
    printf("  alloc:");
    80006910:	00002b17          	auipc	s6,0x2
    80006914:	140b0b13          	addi	s6,s6,320 # 80008a50 <userret+0x9c0>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006918:	00022997          	auipc	s3,0x22
    8000691c:	74098993          	addi	s3,s3,1856 # 80029058 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006920:	00002c97          	auipc	s9,0x2
    80006924:	140c8c93          	addi	s9,s9,320 # 80008a60 <userret+0x9d0>
    80006928:	a801                	j	80006938 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    8000692a:	0009a683          	lw	a3,0(s3)
    8000692e:	0485                	addi	s1,s1,1
    80006930:	0004879b          	sext.w	a5,s1
    80006934:	08d7d563          	bge	a5,a3,800069be <bd_print+0xec>
    80006938:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    8000693c:	36fd                	addiw	a3,a3,-1
    8000693e:	9e85                	subw	a3,a3,s1
    80006940:	00da96bb          	sllw	a3,s5,a3
    80006944:	009c1633          	sll	a2,s8,s1
    80006948:	85ca                	mv	a1,s2
    8000694a:	855e                	mv	a0,s7
    8000694c:	ffffa097          	auipc	ra,0xffffa
    80006950:	c62080e7          	jalr	-926(ra) # 800005ae <printf>
    lst_print(&bd_sizes[k].free);
    80006954:	00549d13          	slli	s10,s1,0x5
    80006958:	000a3503          	ld	a0,0(s4)
    8000695c:	956a                	add	a0,a0,s10
    8000695e:	00001097          	auipc	ra,0x1
    80006962:	a56080e7          	jalr	-1450(ra) # 800073b4 <lst_print>
    printf("  alloc:");
    80006966:	855a                	mv	a0,s6
    80006968:	ffffa097          	auipc	ra,0xffffa
    8000696c:	c46080e7          	jalr	-954(ra) # 800005ae <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006970:	0009a583          	lw	a1,0(s3)
    80006974:	35fd                	addiw	a1,a1,-1
    80006976:	412585bb          	subw	a1,a1,s2
    8000697a:	000a3783          	ld	a5,0(s4)
    8000697e:	97ea                	add	a5,a5,s10
    80006980:	00ba95bb          	sllw	a1,s5,a1
    80006984:	6b88                	ld	a0,16(a5)
    80006986:	00000097          	auipc	ra,0x0
    8000698a:	e9a080e7          	jalr	-358(ra) # 80006820 <bd_print_vector>
    if(k > 0) {
    8000698e:	f9205ee3          	blez	s2,8000692a <bd_print+0x58>
      printf("  split:");
    80006992:	8566                	mv	a0,s9
    80006994:	ffffa097          	auipc	ra,0xffffa
    80006998:	c1a080e7          	jalr	-998(ra) # 800005ae <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    8000699c:	0009a583          	lw	a1,0(s3)
    800069a0:	35fd                	addiw	a1,a1,-1
    800069a2:	412585bb          	subw	a1,a1,s2
    800069a6:	000a3783          	ld	a5,0(s4)
    800069aa:	9d3e                	add	s10,s10,a5
    800069ac:	00ba95bb          	sllw	a1,s5,a1
    800069b0:	018d3503          	ld	a0,24(s10)
    800069b4:	00000097          	auipc	ra,0x0
    800069b8:	e6c080e7          	jalr	-404(ra) # 80006820 <bd_print_vector>
    800069bc:	b7bd                	j	8000692a <bd_print+0x58>
    }
  }
}
    800069be:	60e6                	ld	ra,88(sp)
    800069c0:	6446                	ld	s0,80(sp)
    800069c2:	64a6                	ld	s1,72(sp)
    800069c4:	6906                	ld	s2,64(sp)
    800069c6:	79e2                	ld	s3,56(sp)
    800069c8:	7a42                	ld	s4,48(sp)
    800069ca:	7aa2                	ld	s5,40(sp)
    800069cc:	7b02                	ld	s6,32(sp)
    800069ce:	6be2                	ld	s7,24(sp)
    800069d0:	6c42                	ld	s8,16(sp)
    800069d2:	6ca2                	ld	s9,8(sp)
    800069d4:	6d02                	ld	s10,0(sp)
    800069d6:	6125                	addi	sp,sp,96
    800069d8:	8082                	ret
    800069da:	8082                	ret

00000000800069dc <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800069dc:	1141                	addi	sp,sp,-16
    800069de:	e422                	sd	s0,8(sp)
    800069e0:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    800069e2:	47c1                	li	a5,16
    800069e4:	00a7fb63          	bgeu	a5,a0,800069fa <firstk+0x1e>
    800069e8:	872a                	mv	a4,a0
  int k = 0;
    800069ea:	4501                	li	a0,0
    k++;
    800069ec:	2505                	addiw	a0,a0,1
    size *= 2;
    800069ee:	0786                	slli	a5,a5,0x1
  while (size < n) {
    800069f0:	fee7eee3          	bltu	a5,a4,800069ec <firstk+0x10>
  }
  return k;
}
    800069f4:	6422                	ld	s0,8(sp)
    800069f6:	0141                	addi	sp,sp,16
    800069f8:	8082                	ret
  int k = 0;
    800069fa:	4501                	li	a0,0
    800069fc:	bfe5                	j	800069f4 <firstk+0x18>

00000000800069fe <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    800069fe:	1141                	addi	sp,sp,-16
    80006a00:	e422                	sd	s0,8(sp)
    80006a02:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006a04:	00022797          	auipc	a5,0x22
    80006a08:	6447b783          	ld	a5,1604(a5) # 80029048 <bd_base>
    80006a0c:	9d9d                	subw	a1,a1,a5
    80006a0e:	47c1                	li	a5,16
    80006a10:	00a797b3          	sll	a5,a5,a0
    80006a14:	02f5c5b3          	div	a1,a1,a5
}
    80006a18:	0005851b          	sext.w	a0,a1
    80006a1c:	6422                	ld	s0,8(sp)
    80006a1e:	0141                	addi	sp,sp,16
    80006a20:	8082                	ret

0000000080006a22 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006a22:	1141                	addi	sp,sp,-16
    80006a24:	e422                	sd	s0,8(sp)
    80006a26:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006a28:	47c1                	li	a5,16
    80006a2a:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006a2e:	02b787bb          	mulw	a5,a5,a1
}
    80006a32:	00022517          	auipc	a0,0x22
    80006a36:	61653503          	ld	a0,1558(a0) # 80029048 <bd_base>
    80006a3a:	953e                	add	a0,a0,a5
    80006a3c:	6422                	ld	s0,8(sp)
    80006a3e:	0141                	addi	sp,sp,16
    80006a40:	8082                	ret

0000000080006a42 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006a42:	7159                	addi	sp,sp,-112
    80006a44:	f486                	sd	ra,104(sp)
    80006a46:	f0a2                	sd	s0,96(sp)
    80006a48:	eca6                	sd	s1,88(sp)
    80006a4a:	e8ca                	sd	s2,80(sp)
    80006a4c:	e4ce                	sd	s3,72(sp)
    80006a4e:	e0d2                	sd	s4,64(sp)
    80006a50:	fc56                	sd	s5,56(sp)
    80006a52:	f85a                	sd	s6,48(sp)
    80006a54:	f45e                	sd	s7,40(sp)
    80006a56:	f062                	sd	s8,32(sp)
    80006a58:	ec66                	sd	s9,24(sp)
    80006a5a:	e86a                	sd	s10,16(sp)
    80006a5c:	e46e                	sd	s11,8(sp)
    80006a5e:	1880                	addi	s0,sp,112
    80006a60:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006a62:	00022517          	auipc	a0,0x22
    80006a66:	59e50513          	addi	a0,a0,1438 # 80029000 <lock>
    80006a6a:	ffffa097          	auipc	ra,0xffffa
    80006a6e:	036080e7          	jalr	54(ra) # 80000aa0 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006a72:	8526                	mv	a0,s1
    80006a74:	00000097          	auipc	ra,0x0
    80006a78:	f68080e7          	jalr	-152(ra) # 800069dc <firstk>
  for (k = fk; k < nsizes; k++) {
    80006a7c:	00022797          	auipc	a5,0x22
    80006a80:	5dc7a783          	lw	a5,1500(a5) # 80029058 <nsizes>
    80006a84:	02f55d63          	bge	a0,a5,80006abe <bd_malloc+0x7c>
    80006a88:	8c2a                	mv	s8,a0
    80006a8a:	00551913          	slli	s2,a0,0x5
    80006a8e:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006a90:	00022997          	auipc	s3,0x22
    80006a94:	5c098993          	addi	s3,s3,1472 # 80029050 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006a98:	00022a17          	auipc	s4,0x22
    80006a9c:	5c0a0a13          	addi	s4,s4,1472 # 80029058 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006aa0:	0009b503          	ld	a0,0(s3)
    80006aa4:	954a                	add	a0,a0,s2
    80006aa6:	00001097          	auipc	ra,0x1
    80006aaa:	894080e7          	jalr	-1900(ra) # 8000733a <lst_empty>
    80006aae:	c115                	beqz	a0,80006ad2 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006ab0:	2485                	addiw	s1,s1,1
    80006ab2:	02090913          	addi	s2,s2,32
    80006ab6:	000a2783          	lw	a5,0(s4)
    80006aba:	fef4c3e3          	blt	s1,a5,80006aa0 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006abe:	00022517          	auipc	a0,0x22
    80006ac2:	54250513          	addi	a0,a0,1346 # 80029000 <lock>
    80006ac6:	ffffa097          	auipc	ra,0xffffa
    80006aca:	0aa080e7          	jalr	170(ra) # 80000b70 <release>
    return 0;
    80006ace:	4b01                	li	s6,0
    80006ad0:	a0e1                	j	80006b98 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80006ad2:	00022797          	auipc	a5,0x22
    80006ad6:	5867a783          	lw	a5,1414(a5) # 80029058 <nsizes>
    80006ada:	fef4d2e3          	bge	s1,a5,80006abe <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006ade:	00549993          	slli	s3,s1,0x5
    80006ae2:	00022917          	auipc	s2,0x22
    80006ae6:	56e90913          	addi	s2,s2,1390 # 80029050 <bd_sizes>
    80006aea:	00093503          	ld	a0,0(s2)
    80006aee:	954e                	add	a0,a0,s3
    80006af0:	00001097          	auipc	ra,0x1
    80006af4:	876080e7          	jalr	-1930(ra) # 80007366 <lst_pop>
    80006af8:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006afa:	00022597          	auipc	a1,0x22
    80006afe:	54e5b583          	ld	a1,1358(a1) # 80029048 <bd_base>
    80006b02:	40b505bb          	subw	a1,a0,a1
    80006b06:	47c1                	li	a5,16
    80006b08:	009797b3          	sll	a5,a5,s1
    80006b0c:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006b10:	00093783          	ld	a5,0(s2)
    80006b14:	97ce                	add	a5,a5,s3
    80006b16:	2581                	sext.w	a1,a1
    80006b18:	6b88                	ld	a0,16(a5)
    80006b1a:	00000097          	auipc	ra,0x0
    80006b1e:	ca2080e7          	jalr	-862(ra) # 800067bc <bit_set>
  for(; k > fk; k--) {
    80006b22:	069c5363          	bge	s8,s1,80006b88 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006b26:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006b28:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006b2a:	00022d17          	auipc	s10,0x22
    80006b2e:	51ed0d13          	addi	s10,s10,1310 # 80029048 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006b32:	85a6                	mv	a1,s1
    80006b34:	34fd                	addiw	s1,s1,-1
    80006b36:	009b9ab3          	sll	s5,s7,s1
    80006b3a:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006b3e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
  int n = p - (char *) bd_base;
    80006b42:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006b46:	412b093b          	subw	s2,s6,s2
    80006b4a:	00bb95b3          	sll	a1,s7,a1
    80006b4e:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006b52:	013a07b3          	add	a5,s4,s3
    80006b56:	2581                	sext.w	a1,a1
    80006b58:	6f88                	ld	a0,24(a5)
    80006b5a:	00000097          	auipc	ra,0x0
    80006b5e:	c62080e7          	jalr	-926(ra) # 800067bc <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006b62:	1981                	addi	s3,s3,-32
    80006b64:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006b66:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006b6a:	2581                	sext.w	a1,a1
    80006b6c:	010a3503          	ld	a0,16(s4)
    80006b70:	00000097          	auipc	ra,0x0
    80006b74:	c4c080e7          	jalr	-948(ra) # 800067bc <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006b78:	85e6                	mv	a1,s9
    80006b7a:	8552                	mv	a0,s4
    80006b7c:	00001097          	auipc	ra,0x1
    80006b80:	820080e7          	jalr	-2016(ra) # 8000739c <lst_push>
  for(; k > fk; k--) {
    80006b84:	fb8497e3          	bne	s1,s8,80006b32 <bd_malloc+0xf0>
  }
  release(&lock);
    80006b88:	00022517          	auipc	a0,0x22
    80006b8c:	47850513          	addi	a0,a0,1144 # 80029000 <lock>
    80006b90:	ffffa097          	auipc	ra,0xffffa
    80006b94:	fe0080e7          	jalr	-32(ra) # 80000b70 <release>

  return p;
}
    80006b98:	855a                	mv	a0,s6
    80006b9a:	70a6                	ld	ra,104(sp)
    80006b9c:	7406                	ld	s0,96(sp)
    80006b9e:	64e6                	ld	s1,88(sp)
    80006ba0:	6946                	ld	s2,80(sp)
    80006ba2:	69a6                	ld	s3,72(sp)
    80006ba4:	6a06                	ld	s4,64(sp)
    80006ba6:	7ae2                	ld	s5,56(sp)
    80006ba8:	7b42                	ld	s6,48(sp)
    80006baa:	7ba2                	ld	s7,40(sp)
    80006bac:	7c02                	ld	s8,32(sp)
    80006bae:	6ce2                	ld	s9,24(sp)
    80006bb0:	6d42                	ld	s10,16(sp)
    80006bb2:	6da2                	ld	s11,8(sp)
    80006bb4:	6165                	addi	sp,sp,112
    80006bb6:	8082                	ret

0000000080006bb8 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006bb8:	7139                	addi	sp,sp,-64
    80006bba:	fc06                	sd	ra,56(sp)
    80006bbc:	f822                	sd	s0,48(sp)
    80006bbe:	f426                	sd	s1,40(sp)
    80006bc0:	f04a                	sd	s2,32(sp)
    80006bc2:	ec4e                	sd	s3,24(sp)
    80006bc4:	e852                	sd	s4,16(sp)
    80006bc6:	e456                	sd	s5,8(sp)
    80006bc8:	e05a                	sd	s6,0(sp)
    80006bca:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006bcc:	00022a97          	auipc	s5,0x22
    80006bd0:	48caaa83          	lw	s5,1164(s5) # 80029058 <nsizes>
  return n / BLK_SIZE(k);
    80006bd4:	00022a17          	auipc	s4,0x22
    80006bd8:	474a3a03          	ld	s4,1140(s4) # 80029048 <bd_base>
    80006bdc:	41450a3b          	subw	s4,a0,s4
    80006be0:	00022497          	auipc	s1,0x22
    80006be4:	4704b483          	ld	s1,1136(s1) # 80029050 <bd_sizes>
    80006be8:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006bec:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006bee:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006bf0:	03595363          	bge	s2,s5,80006c16 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006bf4:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006bf8:	013b15b3          	sll	a1,s6,s3
    80006bfc:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006c00:	2581                	sext.w	a1,a1
    80006c02:	6088                	ld	a0,0(s1)
    80006c04:	00000097          	auipc	ra,0x0
    80006c08:	b80080e7          	jalr	-1152(ra) # 80006784 <bit_isset>
    80006c0c:	02048493          	addi	s1,s1,32
    80006c10:	e501                	bnez	a0,80006c18 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006c12:	894e                	mv	s2,s3
    80006c14:	bff1                	j	80006bf0 <size+0x38>
      return k;
    }
  }
  return 0;
    80006c16:	4901                	li	s2,0
}
    80006c18:	854a                	mv	a0,s2
    80006c1a:	70e2                	ld	ra,56(sp)
    80006c1c:	7442                	ld	s0,48(sp)
    80006c1e:	74a2                	ld	s1,40(sp)
    80006c20:	7902                	ld	s2,32(sp)
    80006c22:	69e2                	ld	s3,24(sp)
    80006c24:	6a42                	ld	s4,16(sp)
    80006c26:	6aa2                	ld	s5,8(sp)
    80006c28:	6b02                	ld	s6,0(sp)
    80006c2a:	6121                	addi	sp,sp,64
    80006c2c:	8082                	ret

0000000080006c2e <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006c2e:	7159                	addi	sp,sp,-112
    80006c30:	f486                	sd	ra,104(sp)
    80006c32:	f0a2                	sd	s0,96(sp)
    80006c34:	eca6                	sd	s1,88(sp)
    80006c36:	e8ca                	sd	s2,80(sp)
    80006c38:	e4ce                	sd	s3,72(sp)
    80006c3a:	e0d2                	sd	s4,64(sp)
    80006c3c:	fc56                	sd	s5,56(sp)
    80006c3e:	f85a                	sd	s6,48(sp)
    80006c40:	f45e                	sd	s7,40(sp)
    80006c42:	f062                	sd	s8,32(sp)
    80006c44:	ec66                	sd	s9,24(sp)
    80006c46:	e86a                	sd	s10,16(sp)
    80006c48:	e46e                	sd	s11,8(sp)
    80006c4a:	1880                	addi	s0,sp,112
    80006c4c:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006c4e:	00022517          	auipc	a0,0x22
    80006c52:	3b250513          	addi	a0,a0,946 # 80029000 <lock>
    80006c56:	ffffa097          	auipc	ra,0xffffa
    80006c5a:	e4a080e7          	jalr	-438(ra) # 80000aa0 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80006c5e:	8556                	mv	a0,s5
    80006c60:	00000097          	auipc	ra,0x0
    80006c64:	f58080e7          	jalr	-168(ra) # 80006bb8 <size>
    80006c68:	84aa                	mv	s1,a0
    80006c6a:	00022797          	auipc	a5,0x22
    80006c6e:	3ee7a783          	lw	a5,1006(a5) # 80029058 <nsizes>
    80006c72:	37fd                	addiw	a5,a5,-1
    80006c74:	0cf55063          	bge	a0,a5,80006d34 <bd_free+0x106>
    80006c78:	00150a13          	addi	s4,a0,1
    80006c7c:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    80006c7e:	00022c17          	auipc	s8,0x22
    80006c82:	3cac0c13          	addi	s8,s8,970 # 80029048 <bd_base>
  return n / BLK_SIZE(k);
    80006c86:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006c88:	00022b17          	auipc	s6,0x22
    80006c8c:	3c8b0b13          	addi	s6,s6,968 # 80029050 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006c90:	00022c97          	auipc	s9,0x22
    80006c94:	3c8c8c93          	addi	s9,s9,968 # 80029058 <nsizes>
    80006c98:	a82d                	j	80006cd2 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006c9a:	fff58d9b          	addiw	s11,a1,-1
    80006c9e:	a881                	j	80006cee <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006ca0:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80006ca2:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80006ca6:	40ba85bb          	subw	a1,s5,a1
    80006caa:	009b97b3          	sll	a5,s7,s1
    80006cae:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006cb2:	000b3783          	ld	a5,0(s6)
    80006cb6:	97d2                	add	a5,a5,s4
    80006cb8:	2581                	sext.w	a1,a1
    80006cba:	6f88                	ld	a0,24(a5)
    80006cbc:	00000097          	auipc	ra,0x0
    80006cc0:	b30080e7          	jalr	-1232(ra) # 800067ec <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006cc4:	020a0a13          	addi	s4,s4,32
    80006cc8:	000ca783          	lw	a5,0(s9)
    80006ccc:	37fd                	addiw	a5,a5,-1
    80006cce:	06f4d363          	bge	s1,a5,80006d34 <bd_free+0x106>
  int n = p - (char *) bd_base;
    80006cd2:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006cd6:	009b99b3          	sll	s3,s7,s1
    80006cda:	412a87bb          	subw	a5,s5,s2
    80006cde:	0337c7b3          	div	a5,a5,s3
    80006ce2:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006ce6:	8b85                	andi	a5,a5,1
    80006ce8:	fbcd                	bnez	a5,80006c9a <bd_free+0x6c>
    80006cea:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006cee:	fe0a0d13          	addi	s10,s4,-32
    80006cf2:	000b3783          	ld	a5,0(s6)
    80006cf6:	9d3e                	add	s10,s10,a5
    80006cf8:	010d3503          	ld	a0,16(s10)
    80006cfc:	00000097          	auipc	ra,0x0
    80006d00:	af0080e7          	jalr	-1296(ra) # 800067ec <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006d04:	85ee                	mv	a1,s11
    80006d06:	010d3503          	ld	a0,16(s10)
    80006d0a:	00000097          	auipc	ra,0x0
    80006d0e:	a7a080e7          	jalr	-1414(ra) # 80006784 <bit_isset>
    80006d12:	e10d                	bnez	a0,80006d34 <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    80006d14:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006d18:	03b989bb          	mulw	s3,s3,s11
    80006d1c:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006d1e:	854a                	mv	a0,s2
    80006d20:	00000097          	auipc	ra,0x0
    80006d24:	630080e7          	jalr	1584(ra) # 80007350 <lst_remove>
    if(buddy % 2 == 0) {
    80006d28:	001d7d13          	andi	s10,s10,1
    80006d2c:	f60d1ae3          	bnez	s10,80006ca0 <bd_free+0x72>
      p = q;
    80006d30:	8aca                	mv	s5,s2
    80006d32:	b7bd                	j	80006ca0 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    80006d34:	0496                	slli	s1,s1,0x5
    80006d36:	85d6                	mv	a1,s5
    80006d38:	00022517          	auipc	a0,0x22
    80006d3c:	31853503          	ld	a0,792(a0) # 80029050 <bd_sizes>
    80006d40:	9526                	add	a0,a0,s1
    80006d42:	00000097          	auipc	ra,0x0
    80006d46:	65a080e7          	jalr	1626(ra) # 8000739c <lst_push>
  release(&lock);
    80006d4a:	00022517          	auipc	a0,0x22
    80006d4e:	2b650513          	addi	a0,a0,694 # 80029000 <lock>
    80006d52:	ffffa097          	auipc	ra,0xffffa
    80006d56:	e1e080e7          	jalr	-482(ra) # 80000b70 <release>
}
    80006d5a:	70a6                	ld	ra,104(sp)
    80006d5c:	7406                	ld	s0,96(sp)
    80006d5e:	64e6                	ld	s1,88(sp)
    80006d60:	6946                	ld	s2,80(sp)
    80006d62:	69a6                	ld	s3,72(sp)
    80006d64:	6a06                	ld	s4,64(sp)
    80006d66:	7ae2                	ld	s5,56(sp)
    80006d68:	7b42                	ld	s6,48(sp)
    80006d6a:	7ba2                	ld	s7,40(sp)
    80006d6c:	7c02                	ld	s8,32(sp)
    80006d6e:	6ce2                	ld	s9,24(sp)
    80006d70:	6d42                	ld	s10,16(sp)
    80006d72:	6da2                	ld	s11,8(sp)
    80006d74:	6165                	addi	sp,sp,112
    80006d76:	8082                	ret

0000000080006d78 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006d78:	1141                	addi	sp,sp,-16
    80006d7a:	e422                	sd	s0,8(sp)
    80006d7c:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006d7e:	00022797          	auipc	a5,0x22
    80006d82:	2ca7b783          	ld	a5,714(a5) # 80029048 <bd_base>
    80006d86:	8d9d                	sub	a1,a1,a5
    80006d88:	47c1                	li	a5,16
    80006d8a:	00a797b3          	sll	a5,a5,a0
    80006d8e:	02f5c533          	div	a0,a1,a5
    80006d92:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006d94:	02f5e5b3          	rem	a1,a1,a5
    80006d98:	c191                	beqz	a1,80006d9c <blk_index_next+0x24>
      n++;
    80006d9a:	2505                	addiw	a0,a0,1
  return n ;
}
    80006d9c:	6422                	ld	s0,8(sp)
    80006d9e:	0141                	addi	sp,sp,16
    80006da0:	8082                	ret

0000000080006da2 <log2>:

int
log2(uint64 n) {
    80006da2:	1141                	addi	sp,sp,-16
    80006da4:	e422                	sd	s0,8(sp)
    80006da6:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006da8:	4705                	li	a4,1
    80006daa:	00a77b63          	bgeu	a4,a0,80006dc0 <log2+0x1e>
    80006dae:	87aa                	mv	a5,a0
  int k = 0;
    80006db0:	4501                	li	a0,0
    k++;
    80006db2:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006db4:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006db6:	fef76ee3          	bltu	a4,a5,80006db2 <log2+0x10>
  }
  return k;
}
    80006dba:	6422                	ld	s0,8(sp)
    80006dbc:	0141                	addi	sp,sp,16
    80006dbe:	8082                	ret
  int k = 0;
    80006dc0:	4501                	li	a0,0
    80006dc2:	bfe5                	j	80006dba <log2+0x18>

0000000080006dc4 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006dc4:	711d                	addi	sp,sp,-96
    80006dc6:	ec86                	sd	ra,88(sp)
    80006dc8:	e8a2                	sd	s0,80(sp)
    80006dca:	e4a6                	sd	s1,72(sp)
    80006dcc:	e0ca                	sd	s2,64(sp)
    80006dce:	fc4e                	sd	s3,56(sp)
    80006dd0:	f852                	sd	s4,48(sp)
    80006dd2:	f456                	sd	s5,40(sp)
    80006dd4:	f05a                	sd	s6,32(sp)
    80006dd6:	ec5e                	sd	s7,24(sp)
    80006dd8:	e862                	sd	s8,16(sp)
    80006dda:	e466                	sd	s9,8(sp)
    80006ddc:	e06a                	sd	s10,0(sp)
    80006dde:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006de0:	00b56933          	or	s2,a0,a1
    80006de4:	00f97913          	andi	s2,s2,15
    80006de8:	04091263          	bnez	s2,80006e2c <bd_mark+0x68>
    80006dec:	8b2a                	mv	s6,a0
    80006dee:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006df0:	00022c17          	auipc	s8,0x22
    80006df4:	268c2c03          	lw	s8,616(s8) # 80029058 <nsizes>
    80006df8:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006dfa:	00022d17          	auipc	s10,0x22
    80006dfe:	24ed0d13          	addi	s10,s10,590 # 80029048 <bd_base>
  return n / BLK_SIZE(k);
    80006e02:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006e04:	00022a97          	auipc	s5,0x22
    80006e08:	24ca8a93          	addi	s5,s5,588 # 80029050 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006e0c:	07804563          	bgtz	s8,80006e76 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006e10:	60e6                	ld	ra,88(sp)
    80006e12:	6446                	ld	s0,80(sp)
    80006e14:	64a6                	ld	s1,72(sp)
    80006e16:	6906                	ld	s2,64(sp)
    80006e18:	79e2                	ld	s3,56(sp)
    80006e1a:	7a42                	ld	s4,48(sp)
    80006e1c:	7aa2                	ld	s5,40(sp)
    80006e1e:	7b02                	ld	s6,32(sp)
    80006e20:	6be2                	ld	s7,24(sp)
    80006e22:	6c42                	ld	s8,16(sp)
    80006e24:	6ca2                	ld	s9,8(sp)
    80006e26:	6d02                	ld	s10,0(sp)
    80006e28:	6125                	addi	sp,sp,96
    80006e2a:	8082                	ret
    panic("bd_mark");
    80006e2c:	00002517          	auipc	a0,0x2
    80006e30:	c4450513          	addi	a0,a0,-956 # 80008a70 <userret+0x9e0>
    80006e34:	ffff9097          	auipc	ra,0xffff9
    80006e38:	720080e7          	jalr	1824(ra) # 80000554 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006e3c:	000ab783          	ld	a5,0(s5)
    80006e40:	97ca                	add	a5,a5,s2
    80006e42:	85a6                	mv	a1,s1
    80006e44:	6b88                	ld	a0,16(a5)
    80006e46:	00000097          	auipc	ra,0x0
    80006e4a:	976080e7          	jalr	-1674(ra) # 800067bc <bit_set>
    for(; bi < bj; bi++) {
    80006e4e:	2485                	addiw	s1,s1,1
    80006e50:	009a0e63          	beq	s4,s1,80006e6c <bd_mark+0xa8>
      if(k > 0) {
    80006e54:	ff3054e3          	blez	s3,80006e3c <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006e58:	000ab783          	ld	a5,0(s5)
    80006e5c:	97ca                	add	a5,a5,s2
    80006e5e:	85a6                	mv	a1,s1
    80006e60:	6f88                	ld	a0,24(a5)
    80006e62:	00000097          	auipc	ra,0x0
    80006e66:	95a080e7          	jalr	-1702(ra) # 800067bc <bit_set>
    80006e6a:	bfc9                	j	80006e3c <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006e6c:	2985                	addiw	s3,s3,1
    80006e6e:	02090913          	addi	s2,s2,32
    80006e72:	f9898fe3          	beq	s3,s8,80006e10 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006e76:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006e7a:	409b04bb          	subw	s1,s6,s1
    80006e7e:	013c97b3          	sll	a5,s9,s3
    80006e82:	02f4c4b3          	div	s1,s1,a5
    80006e86:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006e88:	85de                	mv	a1,s7
    80006e8a:	854e                	mv	a0,s3
    80006e8c:	00000097          	auipc	ra,0x0
    80006e90:	eec080e7          	jalr	-276(ra) # 80006d78 <blk_index_next>
    80006e94:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006e96:	faa4cfe3          	blt	s1,a0,80006e54 <bd_mark+0x90>
    80006e9a:	bfc9                	j	80006e6c <bd_mark+0xa8>

0000000080006e9c <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006e9c:	7139                	addi	sp,sp,-64
    80006e9e:	fc06                	sd	ra,56(sp)
    80006ea0:	f822                	sd	s0,48(sp)
    80006ea2:	f426                	sd	s1,40(sp)
    80006ea4:	f04a                	sd	s2,32(sp)
    80006ea6:	ec4e                	sd	s3,24(sp)
    80006ea8:	e852                	sd	s4,16(sp)
    80006eaa:	e456                	sd	s5,8(sp)
    80006eac:	e05a                	sd	s6,0(sp)
    80006eae:	0080                	addi	s0,sp,64
    80006eb0:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006eb2:	00058a9b          	sext.w	s5,a1
    80006eb6:	0015f793          	andi	a5,a1,1
    80006eba:	ebad                	bnez	a5,80006f2c <bd_initfree_pair+0x90>
    80006ebc:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006ec0:	00599493          	slli	s1,s3,0x5
    80006ec4:	00022797          	auipc	a5,0x22
    80006ec8:	18c7b783          	ld	a5,396(a5) # 80029050 <bd_sizes>
    80006ecc:	94be                	add	s1,s1,a5
    80006ece:	0104bb03          	ld	s6,16(s1)
    80006ed2:	855a                	mv	a0,s6
    80006ed4:	00000097          	auipc	ra,0x0
    80006ed8:	8b0080e7          	jalr	-1872(ra) # 80006784 <bit_isset>
    80006edc:	892a                	mv	s2,a0
    80006ede:	85d2                	mv	a1,s4
    80006ee0:	855a                	mv	a0,s6
    80006ee2:	00000097          	auipc	ra,0x0
    80006ee6:	8a2080e7          	jalr	-1886(ra) # 80006784 <bit_isset>
  int free = 0;
    80006eea:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006eec:	02a90563          	beq	s2,a0,80006f16 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006ef0:	45c1                	li	a1,16
    80006ef2:	013599b3          	sll	s3,a1,s3
    80006ef6:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006efa:	02090c63          	beqz	s2,80006f32 <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006efe:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006f02:	00022597          	auipc	a1,0x22
    80006f06:	1465b583          	ld	a1,326(a1) # 80029048 <bd_base>
    80006f0a:	95ce                	add	a1,a1,s3
    80006f0c:	8526                	mv	a0,s1
    80006f0e:	00000097          	auipc	ra,0x0
    80006f12:	48e080e7          	jalr	1166(ra) # 8000739c <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006f16:	855a                	mv	a0,s6
    80006f18:	70e2                	ld	ra,56(sp)
    80006f1a:	7442                	ld	s0,48(sp)
    80006f1c:	74a2                	ld	s1,40(sp)
    80006f1e:	7902                	ld	s2,32(sp)
    80006f20:	69e2                	ld	s3,24(sp)
    80006f22:	6a42                	ld	s4,16(sp)
    80006f24:	6aa2                	ld	s5,8(sp)
    80006f26:	6b02                	ld	s6,0(sp)
    80006f28:	6121                	addi	sp,sp,64
    80006f2a:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006f2c:	fff58a1b          	addiw	s4,a1,-1
    80006f30:	bf41                	j	80006ec0 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006f32:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006f36:	00022597          	auipc	a1,0x22
    80006f3a:	1125b583          	ld	a1,274(a1) # 80029048 <bd_base>
    80006f3e:	95ce                	add	a1,a1,s3
    80006f40:	8526                	mv	a0,s1
    80006f42:	00000097          	auipc	ra,0x0
    80006f46:	45a080e7          	jalr	1114(ra) # 8000739c <lst_push>
    80006f4a:	b7f1                	j	80006f16 <bd_initfree_pair+0x7a>

0000000080006f4c <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006f4c:	711d                	addi	sp,sp,-96
    80006f4e:	ec86                	sd	ra,88(sp)
    80006f50:	e8a2                	sd	s0,80(sp)
    80006f52:	e4a6                	sd	s1,72(sp)
    80006f54:	e0ca                	sd	s2,64(sp)
    80006f56:	fc4e                	sd	s3,56(sp)
    80006f58:	f852                	sd	s4,48(sp)
    80006f5a:	f456                	sd	s5,40(sp)
    80006f5c:	f05a                	sd	s6,32(sp)
    80006f5e:	ec5e                	sd	s7,24(sp)
    80006f60:	e862                	sd	s8,16(sp)
    80006f62:	e466                	sd	s9,8(sp)
    80006f64:	e06a                	sd	s10,0(sp)
    80006f66:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006f68:	00022717          	auipc	a4,0x22
    80006f6c:	0f072703          	lw	a4,240(a4) # 80029058 <nsizes>
    80006f70:	4785                	li	a5,1
    80006f72:	06e7db63          	bge	a5,a4,80006fe8 <bd_initfree+0x9c>
    80006f76:	8aaa                	mv	s5,a0
    80006f78:	8b2e                	mv	s6,a1
    80006f7a:	4901                	li	s2,0
  int free = 0;
    80006f7c:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006f7e:	00022c97          	auipc	s9,0x22
    80006f82:	0cac8c93          	addi	s9,s9,202 # 80029048 <bd_base>
  return n / BLK_SIZE(k);
    80006f86:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006f88:	00022b97          	auipc	s7,0x22
    80006f8c:	0d0b8b93          	addi	s7,s7,208 # 80029058 <nsizes>
    80006f90:	a039                	j	80006f9e <bd_initfree+0x52>
    80006f92:	2905                	addiw	s2,s2,1
    80006f94:	000ba783          	lw	a5,0(s7)
    80006f98:	37fd                	addiw	a5,a5,-1
    80006f9a:	04f95863          	bge	s2,a5,80006fea <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006f9e:	85d6                	mv	a1,s5
    80006fa0:	854a                	mv	a0,s2
    80006fa2:	00000097          	auipc	ra,0x0
    80006fa6:	dd6080e7          	jalr	-554(ra) # 80006d78 <blk_index_next>
    80006faa:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006fac:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006fb0:	409b04bb          	subw	s1,s6,s1
    80006fb4:	012c17b3          	sll	a5,s8,s2
    80006fb8:	02f4c4b3          	div	s1,s1,a5
    80006fbc:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006fbe:	85aa                	mv	a1,a0
    80006fc0:	854a                	mv	a0,s2
    80006fc2:	00000097          	auipc	ra,0x0
    80006fc6:	eda080e7          	jalr	-294(ra) # 80006e9c <bd_initfree_pair>
    80006fca:	01450d3b          	addw	s10,a0,s4
    80006fce:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006fd2:	fc99d0e3          	bge	s3,s1,80006f92 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006fd6:	85a6                	mv	a1,s1
    80006fd8:	854a                	mv	a0,s2
    80006fda:	00000097          	auipc	ra,0x0
    80006fde:	ec2080e7          	jalr	-318(ra) # 80006e9c <bd_initfree_pair>
    80006fe2:	00ad0a3b          	addw	s4,s10,a0
    80006fe6:	b775                	j	80006f92 <bd_initfree+0x46>
  int free = 0;
    80006fe8:	4a01                	li	s4,0
  }
  return free;
}
    80006fea:	8552                	mv	a0,s4
    80006fec:	60e6                	ld	ra,88(sp)
    80006fee:	6446                	ld	s0,80(sp)
    80006ff0:	64a6                	ld	s1,72(sp)
    80006ff2:	6906                	ld	s2,64(sp)
    80006ff4:	79e2                	ld	s3,56(sp)
    80006ff6:	7a42                	ld	s4,48(sp)
    80006ff8:	7aa2                	ld	s5,40(sp)
    80006ffa:	7b02                	ld	s6,32(sp)
    80006ffc:	6be2                	ld	s7,24(sp)
    80006ffe:	6c42                	ld	s8,16(sp)
    80007000:	6ca2                	ld	s9,8(sp)
    80007002:	6d02                	ld	s10,0(sp)
    80007004:	6125                	addi	sp,sp,96
    80007006:	8082                	ret

0000000080007008 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80007008:	7179                	addi	sp,sp,-48
    8000700a:	f406                	sd	ra,40(sp)
    8000700c:	f022                	sd	s0,32(sp)
    8000700e:	ec26                	sd	s1,24(sp)
    80007010:	e84a                	sd	s2,16(sp)
    80007012:	e44e                	sd	s3,8(sp)
    80007014:	1800                	addi	s0,sp,48
    80007016:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80007018:	00022997          	auipc	s3,0x22
    8000701c:	03098993          	addi	s3,s3,48 # 80029048 <bd_base>
    80007020:	0009b483          	ld	s1,0(s3)
    80007024:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80007028:	00022797          	auipc	a5,0x22
    8000702c:	0307a783          	lw	a5,48(a5) # 80029058 <nsizes>
    80007030:	37fd                	addiw	a5,a5,-1
    80007032:	4641                	li	a2,16
    80007034:	00f61633          	sll	a2,a2,a5
    80007038:	85a6                	mv	a1,s1
    8000703a:	00002517          	auipc	a0,0x2
    8000703e:	a3e50513          	addi	a0,a0,-1474 # 80008a78 <userret+0x9e8>
    80007042:	ffff9097          	auipc	ra,0xffff9
    80007046:	56c080e7          	jalr	1388(ra) # 800005ae <printf>
  bd_mark(bd_base, p);
    8000704a:	85ca                	mv	a1,s2
    8000704c:	0009b503          	ld	a0,0(s3)
    80007050:	00000097          	auipc	ra,0x0
    80007054:	d74080e7          	jalr	-652(ra) # 80006dc4 <bd_mark>
  return meta;
}
    80007058:	8526                	mv	a0,s1
    8000705a:	70a2                	ld	ra,40(sp)
    8000705c:	7402                	ld	s0,32(sp)
    8000705e:	64e2                	ld	s1,24(sp)
    80007060:	6942                	ld	s2,16(sp)
    80007062:	69a2                	ld	s3,8(sp)
    80007064:	6145                	addi	sp,sp,48
    80007066:	8082                	ret

0000000080007068 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80007068:	1101                	addi	sp,sp,-32
    8000706a:	ec06                	sd	ra,24(sp)
    8000706c:	e822                	sd	s0,16(sp)
    8000706e:	e426                	sd	s1,8(sp)
    80007070:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80007072:	00022497          	auipc	s1,0x22
    80007076:	fe64a483          	lw	s1,-26(s1) # 80029058 <nsizes>
    8000707a:	fff4879b          	addiw	a5,s1,-1
    8000707e:	44c1                	li	s1,16
    80007080:	00f494b3          	sll	s1,s1,a5
    80007084:	00022797          	auipc	a5,0x22
    80007088:	fc47b783          	ld	a5,-60(a5) # 80029048 <bd_base>
    8000708c:	8d1d                	sub	a0,a0,a5
    8000708e:	40a4853b          	subw	a0,s1,a0
    80007092:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80007096:	00905a63          	blez	s1,800070aa <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    8000709a:	357d                	addiw	a0,a0,-1
    8000709c:	41f5549b          	sraiw	s1,a0,0x1f
    800070a0:	01c4d49b          	srliw	s1,s1,0x1c
    800070a4:	9ca9                	addw	s1,s1,a0
    800070a6:	98c1                	andi	s1,s1,-16
    800070a8:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    800070aa:	85a6                	mv	a1,s1
    800070ac:	00002517          	auipc	a0,0x2
    800070b0:	a0450513          	addi	a0,a0,-1532 # 80008ab0 <userret+0xa20>
    800070b4:	ffff9097          	auipc	ra,0xffff9
    800070b8:	4fa080e7          	jalr	1274(ra) # 800005ae <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    800070bc:	00022717          	auipc	a4,0x22
    800070c0:	f8c73703          	ld	a4,-116(a4) # 80029048 <bd_base>
    800070c4:	00022597          	auipc	a1,0x22
    800070c8:	f945a583          	lw	a1,-108(a1) # 80029058 <nsizes>
    800070cc:	fff5879b          	addiw	a5,a1,-1
    800070d0:	45c1                	li	a1,16
    800070d2:	00f595b3          	sll	a1,a1,a5
    800070d6:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    800070da:	95ba                	add	a1,a1,a4
    800070dc:	953a                	add	a0,a0,a4
    800070de:	00000097          	auipc	ra,0x0
    800070e2:	ce6080e7          	jalr	-794(ra) # 80006dc4 <bd_mark>
  return unavailable;
}
    800070e6:	8526                	mv	a0,s1
    800070e8:	60e2                	ld	ra,24(sp)
    800070ea:	6442                	ld	s0,16(sp)
    800070ec:	64a2                	ld	s1,8(sp)
    800070ee:	6105                	addi	sp,sp,32
    800070f0:	8082                	ret

00000000800070f2 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    800070f2:	715d                	addi	sp,sp,-80
    800070f4:	e486                	sd	ra,72(sp)
    800070f6:	e0a2                	sd	s0,64(sp)
    800070f8:	fc26                	sd	s1,56(sp)
    800070fa:	f84a                	sd	s2,48(sp)
    800070fc:	f44e                	sd	s3,40(sp)
    800070fe:	f052                	sd	s4,32(sp)
    80007100:	ec56                	sd	s5,24(sp)
    80007102:	e85a                	sd	s6,16(sp)
    80007104:	e45e                	sd	s7,8(sp)
    80007106:	e062                	sd	s8,0(sp)
    80007108:	0880                	addi	s0,sp,80
    8000710a:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    8000710c:	fff50493          	addi	s1,a0,-1
    80007110:	98c1                	andi	s1,s1,-16
    80007112:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80007114:	00002597          	auipc	a1,0x2
    80007118:	9bc58593          	addi	a1,a1,-1604 # 80008ad0 <userret+0xa40>
    8000711c:	00022517          	auipc	a0,0x22
    80007120:	ee450513          	addi	a0,a0,-284 # 80029000 <lock>
    80007124:	ffffa097          	auipc	ra,0xffffa
    80007128:	8a8080e7          	jalr	-1880(ra) # 800009cc <initlock>
  bd_base = (void *) p;
    8000712c:	00022797          	auipc	a5,0x22
    80007130:	f097be23          	sd	s1,-228(a5) # 80029048 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007134:	409c0933          	sub	s2,s8,s1
    80007138:	43f95513          	srai	a0,s2,0x3f
    8000713c:	893d                	andi	a0,a0,15
    8000713e:	954a                	add	a0,a0,s2
    80007140:	8511                	srai	a0,a0,0x4
    80007142:	00000097          	auipc	ra,0x0
    80007146:	c60080e7          	jalr	-928(ra) # 80006da2 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    8000714a:	47c1                	li	a5,16
    8000714c:	00a797b3          	sll	a5,a5,a0
    80007150:	1b27c663          	blt	a5,s2,800072fc <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007154:	2505                	addiw	a0,a0,1
    80007156:	00022797          	auipc	a5,0x22
    8000715a:	f0a7a123          	sw	a0,-254(a5) # 80029058 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    8000715e:	00022997          	auipc	s3,0x22
    80007162:	efa98993          	addi	s3,s3,-262 # 80029058 <nsizes>
    80007166:	0009a603          	lw	a2,0(s3)
    8000716a:	85ca                	mv	a1,s2
    8000716c:	00002517          	auipc	a0,0x2
    80007170:	96c50513          	addi	a0,a0,-1684 # 80008ad8 <userret+0xa48>
    80007174:	ffff9097          	auipc	ra,0xffff9
    80007178:	43a080e7          	jalr	1082(ra) # 800005ae <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    8000717c:	00022797          	auipc	a5,0x22
    80007180:	ec97ba23          	sd	s1,-300(a5) # 80029050 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80007184:	0009a603          	lw	a2,0(s3)
    80007188:	00561913          	slli	s2,a2,0x5
    8000718c:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    8000718e:	0056161b          	slliw	a2,a2,0x5
    80007192:	4581                	li	a1,0
    80007194:	8526                	mv	a0,s1
    80007196:	ffffa097          	auipc	ra,0xffffa
    8000719a:	bd8080e7          	jalr	-1064(ra) # 80000d6e <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    8000719e:	0009a783          	lw	a5,0(s3)
    800071a2:	06f05a63          	blez	a5,80007216 <bd_init+0x124>
    800071a6:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    800071a8:	00022a97          	auipc	s5,0x22
    800071ac:	ea8a8a93          	addi	s5,s5,-344 # 80029050 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800071b0:	00022a17          	auipc	s4,0x22
    800071b4:	ea8a0a13          	addi	s4,s4,-344 # 80029058 <nsizes>
    800071b8:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    800071ba:	00599b93          	slli	s7,s3,0x5
    800071be:	000ab503          	ld	a0,0(s5)
    800071c2:	955e                	add	a0,a0,s7
    800071c4:	00000097          	auipc	ra,0x0
    800071c8:	166080e7          	jalr	358(ra) # 8000732a <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800071cc:	000a2483          	lw	s1,0(s4)
    800071d0:	34fd                	addiw	s1,s1,-1
    800071d2:	413484bb          	subw	s1,s1,s3
    800071d6:	009b14bb          	sllw	s1,s6,s1
    800071da:	fff4879b          	addiw	a5,s1,-1
    800071de:	41f7d49b          	sraiw	s1,a5,0x1f
    800071e2:	01d4d49b          	srliw	s1,s1,0x1d
    800071e6:	9cbd                	addw	s1,s1,a5
    800071e8:	98e1                	andi	s1,s1,-8
    800071ea:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    800071ec:	000ab783          	ld	a5,0(s5)
    800071f0:	9bbe                	add	s7,s7,a5
    800071f2:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    800071f6:	848d                	srai	s1,s1,0x3
    800071f8:	8626                	mv	a2,s1
    800071fa:	4581                	li	a1,0
    800071fc:	854a                	mv	a0,s2
    800071fe:	ffffa097          	auipc	ra,0xffffa
    80007202:	b70080e7          	jalr	-1168(ra) # 80000d6e <memset>
    p += sz;
    80007206:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80007208:	0985                	addi	s3,s3,1
    8000720a:	000a2703          	lw	a4,0(s4)
    8000720e:	0009879b          	sext.w	a5,s3
    80007212:	fae7c4e3          	blt	a5,a4,800071ba <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80007216:	00022797          	auipc	a5,0x22
    8000721a:	e427a783          	lw	a5,-446(a5) # 80029058 <nsizes>
    8000721e:	4705                	li	a4,1
    80007220:	06f75163          	bge	a4,a5,80007282 <bd_init+0x190>
    80007224:	02000a13          	li	s4,32
    80007228:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000722a:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    8000722c:	00022b17          	auipc	s6,0x22
    80007230:	e24b0b13          	addi	s6,s6,-476 # 80029050 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80007234:	00022a97          	auipc	s5,0x22
    80007238:	e24a8a93          	addi	s5,s5,-476 # 80029058 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000723c:	37fd                	addiw	a5,a5,-1
    8000723e:	413787bb          	subw	a5,a5,s3
    80007242:	00fb94bb          	sllw	s1,s7,a5
    80007246:	fff4879b          	addiw	a5,s1,-1
    8000724a:	41f7d49b          	sraiw	s1,a5,0x1f
    8000724e:	01d4d49b          	srliw	s1,s1,0x1d
    80007252:	9cbd                	addw	s1,s1,a5
    80007254:	98e1                	andi	s1,s1,-8
    80007256:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80007258:	000b3783          	ld	a5,0(s6)
    8000725c:	97d2                	add	a5,a5,s4
    8000725e:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80007262:	848d                	srai	s1,s1,0x3
    80007264:	8626                	mv	a2,s1
    80007266:	4581                	li	a1,0
    80007268:	854a                	mv	a0,s2
    8000726a:	ffffa097          	auipc	ra,0xffffa
    8000726e:	b04080e7          	jalr	-1276(ra) # 80000d6e <memset>
    p += sz;
    80007272:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80007274:	2985                	addiw	s3,s3,1
    80007276:	000aa783          	lw	a5,0(s5)
    8000727a:	020a0a13          	addi	s4,s4,32
    8000727e:	faf9cfe3          	blt	s3,a5,8000723c <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80007282:	197d                	addi	s2,s2,-1
    80007284:	ff097913          	andi	s2,s2,-16
    80007288:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    8000728a:	854a                	mv	a0,s2
    8000728c:	00000097          	auipc	ra,0x0
    80007290:	d7c080e7          	jalr	-644(ra) # 80007008 <bd_mark_data_structures>
    80007294:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80007296:	85ca                	mv	a1,s2
    80007298:	8562                	mv	a0,s8
    8000729a:	00000097          	auipc	ra,0x0
    8000729e:	dce080e7          	jalr	-562(ra) # 80007068 <bd_mark_unavailable>
    800072a2:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    800072a4:	00022a97          	auipc	s5,0x22
    800072a8:	db4a8a93          	addi	s5,s5,-588 # 80029058 <nsizes>
    800072ac:	000aa783          	lw	a5,0(s5)
    800072b0:	37fd                	addiw	a5,a5,-1
    800072b2:	44c1                	li	s1,16
    800072b4:	00f497b3          	sll	a5,s1,a5
    800072b8:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    800072ba:	00022597          	auipc	a1,0x22
    800072be:	d8e5b583          	ld	a1,-626(a1) # 80029048 <bd_base>
    800072c2:	95be                	add	a1,a1,a5
    800072c4:	854a                	mv	a0,s2
    800072c6:	00000097          	auipc	ra,0x0
    800072ca:	c86080e7          	jalr	-890(ra) # 80006f4c <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    800072ce:	000aa603          	lw	a2,0(s5)
    800072d2:	367d                	addiw	a2,a2,-1
    800072d4:	00c49633          	sll	a2,s1,a2
    800072d8:	41460633          	sub	a2,a2,s4
    800072dc:	41360633          	sub	a2,a2,s3
    800072e0:	02c51463          	bne	a0,a2,80007308 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    800072e4:	60a6                	ld	ra,72(sp)
    800072e6:	6406                	ld	s0,64(sp)
    800072e8:	74e2                	ld	s1,56(sp)
    800072ea:	7942                	ld	s2,48(sp)
    800072ec:	79a2                	ld	s3,40(sp)
    800072ee:	7a02                	ld	s4,32(sp)
    800072f0:	6ae2                	ld	s5,24(sp)
    800072f2:	6b42                	ld	s6,16(sp)
    800072f4:	6ba2                	ld	s7,8(sp)
    800072f6:	6c02                	ld	s8,0(sp)
    800072f8:	6161                	addi	sp,sp,80
    800072fa:	8082                	ret
    nsizes++;  // round up to the next power of 2
    800072fc:	2509                	addiw	a0,a0,2
    800072fe:	00022797          	auipc	a5,0x22
    80007302:	d4a7ad23          	sw	a0,-678(a5) # 80029058 <nsizes>
    80007306:	bda1                	j	8000715e <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007308:	85aa                	mv	a1,a0
    8000730a:	00002517          	auipc	a0,0x2
    8000730e:	80e50513          	addi	a0,a0,-2034 # 80008b18 <userret+0xa88>
    80007312:	ffff9097          	auipc	ra,0xffff9
    80007316:	29c080e7          	jalr	668(ra) # 800005ae <printf>
    panic("bd_init: free mem");
    8000731a:	00002517          	auipc	a0,0x2
    8000731e:	80e50513          	addi	a0,a0,-2034 # 80008b28 <userret+0xa98>
    80007322:	ffff9097          	auipc	ra,0xffff9
    80007326:	232080e7          	jalr	562(ra) # 80000554 <panic>

000000008000732a <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    8000732a:	1141                	addi	sp,sp,-16
    8000732c:	e422                	sd	s0,8(sp)
    8000732e:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007330:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80007332:	e508                	sd	a0,8(a0)
}
    80007334:	6422                	ld	s0,8(sp)
    80007336:	0141                	addi	sp,sp,16
    80007338:	8082                	ret

000000008000733a <lst_empty>:

int
lst_empty(struct list *lst) {
    8000733a:	1141                	addi	sp,sp,-16
    8000733c:	e422                	sd	s0,8(sp)
    8000733e:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007340:	611c                	ld	a5,0(a0)
    80007342:	40a78533          	sub	a0,a5,a0
}
    80007346:	00153513          	seqz	a0,a0
    8000734a:	6422                	ld	s0,8(sp)
    8000734c:	0141                	addi	sp,sp,16
    8000734e:	8082                	ret

0000000080007350 <lst_remove>:

void
lst_remove(struct list *e) {
    80007350:	1141                	addi	sp,sp,-16
    80007352:	e422                	sd	s0,8(sp)
    80007354:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007356:	6518                	ld	a4,8(a0)
    80007358:	611c                	ld	a5,0(a0)
    8000735a:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    8000735c:	6518                	ld	a4,8(a0)
    8000735e:	e798                	sd	a4,8(a5)
}
    80007360:	6422                	ld	s0,8(sp)
    80007362:	0141                	addi	sp,sp,16
    80007364:	8082                	ret

0000000080007366 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007366:	1101                	addi	sp,sp,-32
    80007368:	ec06                	sd	ra,24(sp)
    8000736a:	e822                	sd	s0,16(sp)
    8000736c:	e426                	sd	s1,8(sp)
    8000736e:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007370:	6104                	ld	s1,0(a0)
    80007372:	00a48d63          	beq	s1,a0,8000738c <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007376:	8526                	mv	a0,s1
    80007378:	00000097          	auipc	ra,0x0
    8000737c:	fd8080e7          	jalr	-40(ra) # 80007350 <lst_remove>
  return (void *)p;
}
    80007380:	8526                	mv	a0,s1
    80007382:	60e2                	ld	ra,24(sp)
    80007384:	6442                	ld	s0,16(sp)
    80007386:	64a2                	ld	s1,8(sp)
    80007388:	6105                	addi	sp,sp,32
    8000738a:	8082                	ret
    panic("lst_pop");
    8000738c:	00001517          	auipc	a0,0x1
    80007390:	7b450513          	addi	a0,a0,1972 # 80008b40 <userret+0xab0>
    80007394:	ffff9097          	auipc	ra,0xffff9
    80007398:	1c0080e7          	jalr	448(ra) # 80000554 <panic>

000000008000739c <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    8000739c:	1141                	addi	sp,sp,-16
    8000739e:	e422                	sd	s0,8(sp)
    800073a0:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    800073a2:	611c                	ld	a5,0(a0)
    800073a4:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    800073a6:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    800073a8:	611c                	ld	a5,0(a0)
    800073aa:	e78c                	sd	a1,8(a5)
  lst->next = e;
    800073ac:	e10c                	sd	a1,0(a0)
}
    800073ae:	6422                	ld	s0,8(sp)
    800073b0:	0141                	addi	sp,sp,16
    800073b2:	8082                	ret

00000000800073b4 <lst_print>:

void
lst_print(struct list *lst)
{
    800073b4:	7179                	addi	sp,sp,-48
    800073b6:	f406                	sd	ra,40(sp)
    800073b8:	f022                	sd	s0,32(sp)
    800073ba:	ec26                	sd	s1,24(sp)
    800073bc:	e84a                	sd	s2,16(sp)
    800073be:	e44e                	sd	s3,8(sp)
    800073c0:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800073c2:	6104                	ld	s1,0(a0)
    800073c4:	02950063          	beq	a0,s1,800073e4 <lst_print+0x30>
    800073c8:	892a                	mv	s2,a0
    printf(" %p", p);
    800073ca:	00001997          	auipc	s3,0x1
    800073ce:	77e98993          	addi	s3,s3,1918 # 80008b48 <userret+0xab8>
    800073d2:	85a6                	mv	a1,s1
    800073d4:	854e                	mv	a0,s3
    800073d6:	ffff9097          	auipc	ra,0xffff9
    800073da:	1d8080e7          	jalr	472(ra) # 800005ae <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800073de:	6084                	ld	s1,0(s1)
    800073e0:	fe9919e3          	bne	s2,s1,800073d2 <lst_print+0x1e>
  }
  printf("\n");
    800073e4:	00001517          	auipc	a0,0x1
    800073e8:	eac50513          	addi	a0,a0,-340 # 80008290 <userret+0x200>
    800073ec:	ffff9097          	auipc	ra,0xffff9
    800073f0:	1c2080e7          	jalr	450(ra) # 800005ae <printf>
}
    800073f4:	70a2                	ld	ra,40(sp)
    800073f6:	7402                	ld	s0,32(sp)
    800073f8:	64e2                	ld	s1,24(sp)
    800073fa:	6942                	ld	s2,16(sp)
    800073fc:	69a2                	ld	s3,8(sp)
    800073fe:	6145                	addi	sp,sp,48
    80007400:	8082                	ret
	...

0000000080008000 <trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
