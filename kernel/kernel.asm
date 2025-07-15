
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
    80000060:	d2478793          	addi	a5,a5,-732 # 80005d80 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd67a3>
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
    800001fe:	00028797          	auipc	a5,0x28
    80000202:	e227a783          	lw	a5,-478(a5) # 80028020 <panicked>
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
    8000048e:	00020797          	auipc	a5,0x20
    80000492:	bd278793          	addi	a5,a5,-1070 # 80020060 <devsw>
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
    800004d0:	00009617          	auipc	a2,0x9
    800004d4:	84060613          	addi	a2,a2,-1984 # 80008d10 <digits>
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
    800005a4:	00028717          	auipc	a4,0x28
    800005a8:	a6f72e23          	sw	a5,-1412(a4) # 80028020 <panicked>
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
    80000610:	704b0b13          	addi	s6,s6,1796 # 80008d10 <digits>
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
    80000884:	00027797          	auipc	a5,0x27
    80000888:	7d878793          	addi	a5,a5,2008 # 8002805c <end>
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
    80000954:	00027517          	auipc	a0,0x27
    80000958:	70850513          	addi	a0,a0,1800 # 8002805c <end>
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
    800009de:	00027797          	auipc	a5,0x27
    800009e2:	6467a783          	lw	a5,1606(a5) # 80028024 <nlock>
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
    80000a00:	00027717          	auipc	a4,0x27
    80000a04:	62f72223          	sw	a5,1572(a4) # 80028024 <nlock>
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
    80000c08:	f68080e7          	jalr	-152(ra) # 80002b6c <argint>
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
    80000f2c:	00027717          	auipc	a4,0x27
    80000f30:	0fc70713          	addi	a4,a4,252 # 80028028 <started>
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
    80000f66:	796080e7          	jalr	1942(ra) # 800026f8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	e56080e7          	jalr	-426(ra) # 80005dc0 <plicinithart>
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
    80000fde:	6f6080e7          	jalr	1782(ra) # 800026d0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fe2:	00001097          	auipc	ra,0x1
    80000fe6:	716080e7          	jalr	1814(ra) # 800026f8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fea:	00005097          	auipc	ra,0x5
    80000fee:	dc0080e7          	jalr	-576(ra) # 80005daa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ff2:	00005097          	auipc	ra,0x5
    80000ff6:	dce080e7          	jalr	-562(ra) # 80005dc0 <plicinithart>
    binit();         // buffer cache
    80000ffa:	00002097          	auipc	ra,0x2
    80000ffe:	e52080e7          	jalr	-430(ra) # 80002e4c <binit>
    iinit();         // inode cache
    80001002:	00002097          	auipc	ra,0x2
    80001006:	4e6080e7          	jalr	1254(ra) # 800034e8 <iinit>
    fileinit();      // file table
    8000100a:	00003097          	auipc	ra,0x3
    8000100e:	570080e7          	jalr	1392(ra) # 8000457a <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80001012:	4501                	li	a0,0
    80001014:	00005097          	auipc	ra,0x5
    80001018:	ece080e7          	jalr	-306(ra) # 80005ee2 <virtio_disk_init>
    userinit();      // first user process
    8000101c:	00001097          	auipc	ra,0x1
    80001020:	cb0080e7          	jalr	-848(ra) # 80001ccc <userinit>
    __sync_synchronize();
    80001024:	0ff0000f          	fence
    started = 1;
    80001028:	4785                	li	a5,1
    8000102a:	00027717          	auipc	a4,0x27
    8000102e:	fef72f23          	sw	a5,-2(a4) # 80028028 <started>
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
    8000114a:	00027797          	auipc	a5,0x27
    8000114e:	ee67b783          	ld	a5,-282(a5) # 80028030 <kernel_pagetable>
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
    800011be:	00027517          	auipc	a0,0x27
    800011c2:	e7253503          	ld	a0,-398(a0) # 80028030 <kernel_pagetable>
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
    800012a4:	00027517          	auipc	a0,0x27
    800012a8:	d8c53503          	ld	a0,-628(a0) # 80028030 <kernel_pagetable>
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
    800012e0:	00027797          	auipc	a5,0x27
    800012e4:	d4a7b823          	sd	a0,-688(a5) # 80028030 <kernel_pagetable>
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
    800018ec:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd6fa4>
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
    800019a0:	584b0b13          	addi	s6,s6,1412 # 80008f20 <syscalls+0xb8>
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
    80001ab6:	c5e080e7          	jalr	-930(ra) # 80002710 <usertrapret>
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
    80001ad0:	99c080e7          	jalr	-1636(ra) # 80003468 <fsinit>
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
    80001ce0:	00026797          	auipc	a5,0x26
    80001ce4:	34a7bc23          	sd	a0,856(a5) # 80028038 <initproc>
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
    80001d2e:	140080e7          	jalr	320(ra) # 80003e6a <namei>
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
    80001e74:	00002097          	auipc	ra,0x2
    80001e78:	798080e7          	jalr	1944(ra) # 8000460c <filedup>
    80001e7c:	00a93023          	sd	a0,0(s2)
    80001e80:	b7e5                	j	80001e68 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001e82:	158ab503          	ld	a0,344(s5)
    80001e86:	00002097          	auipc	ra,0x2
    80001e8a:	81c080e7          	jalr	-2020(ra) # 800036a2 <idup>
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
    80001eea:	00026a17          	auipc	s4,0x26
    80001eee:	14ea0a13          	addi	s4,s4,334 # 80028038 <initproc>
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
    800020ea:	00026797          	auipc	a5,0x26
    800020ee:	f4e7b783          	ld	a5,-178(a5) # 80028038 <initproc>
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
    80002112:	550080e7          	jalr	1360(ra) # 8000465e <fileclose>
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
    8000212c:	f9c080e7          	jalr	-100(ra) # 800040c4 <begin_op>
  iput(p->cwd);
    80002130:	1589b503          	ld	a0,344(s3)
    80002134:	00001097          	auipc	ra,0x1
    80002138:	6ba080e7          	jalr	1722(ra) # 800037ee <iput>
  end_op(ROOTDEV);
    8000213c:	4501                	li	a0,0
    8000213e:	00002097          	auipc	ra,0x2
    80002142:	030080e7          	jalr	48(ra) # 8000416e <end_op>
  p->cwd = 0;
    80002146:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    8000214a:	00026497          	auipc	s1,0x26
    8000214e:	eee48493          	addi	s1,s1,-274 # 80028038 <initproc>
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
    80002572:	7bab8b93          	addi	s7,s7,1978 # 80008d28 <states.0>
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

0000000080002636 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002636:	1141                	addi	sp,sp,-16
    80002638:	e422                	sd	s0,8(sp)
    8000263a:	0800                	addi	s0,sp,16
    8000263c:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    8000263e:	00151713          	slli	a4,a0,0x1
    80002642:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    80002644:	04054c63          	bltz	a0,8000269c <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    80002648:	5685                	li	a3,-31
    8000264a:	8285                	srli	a3,a3,0x1
    8000264c:	8ee9                	and	a3,a3,a0
    8000264e:	caad                	beqz	a3,800026c0 <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    80002650:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002652:	00006517          	auipc	a0,0x6
    80002656:	eae50513          	addi	a0,a0,-338 # 80008500 <userret+0x470>
    } else if (code <= 23) {
    8000265a:	06e6f063          	bgeu	a3,a4,800026ba <scause_desc+0x84>
    } else if (code <= 31) {
    8000265e:	fc100693          	li	a3,-63
    80002662:	8285                	srli	a3,a3,0x1
    80002664:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    80002666:	00006517          	auipc	a0,0x6
    8000266a:	ec250513          	addi	a0,a0,-318 # 80008528 <userret+0x498>
    } else if (code <= 31) {
    8000266e:	c6b1                	beqz	a3,800026ba <scause_desc+0x84>
    } else if (code <= 47) {
    80002670:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    80002674:	00006517          	auipc	a0,0x6
    80002678:	e8c50513          	addi	a0,a0,-372 # 80008500 <userret+0x470>
    } else if (code <= 47) {
    8000267c:	02e6ff63          	bgeu	a3,a4,800026ba <scause_desc+0x84>
    } else if (code <= 63) {
    80002680:	f8100513          	li	a0,-127
    80002684:	8105                	srli	a0,a0,0x1
    80002686:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    80002688:	00006517          	auipc	a0,0x6
    8000268c:	ea050513          	addi	a0,a0,-352 # 80008528 <userret+0x498>
    } else if (code <= 63) {
    80002690:	c78d                	beqz	a5,800026ba <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    80002692:	00006517          	auipc	a0,0x6
    80002696:	e6e50513          	addi	a0,a0,-402 # 80008500 <userret+0x470>
    8000269a:	a005                	j	800026ba <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    8000269c:	5505                	li	a0,-31
    8000269e:	8105                	srli	a0,a0,0x1
    800026a0:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    800026a2:	00006517          	auipc	a0,0x6
    800026a6:	ea650513          	addi	a0,a0,-346 # 80008548 <userret+0x4b8>
    if (code < NELEM(intr_desc)) {
    800026aa:	eb81                	bnez	a5,800026ba <scause_desc+0x84>
      return intr_desc[code];
    800026ac:	070e                	slli	a4,a4,0x3
    800026ae:	00006797          	auipc	a5,0x6
    800026b2:	6a278793          	addi	a5,a5,1698 # 80008d50 <intr_desc.1>
    800026b6:	973e                	add	a4,a4,a5
    800026b8:	6308                	ld	a0,0(a4)
    }
  }
}
    800026ba:	6422                	ld	s0,8(sp)
    800026bc:	0141                	addi	sp,sp,16
    800026be:	8082                	ret
      return nointr_desc[code];
    800026c0:	070e                	slli	a4,a4,0x3
    800026c2:	00006797          	auipc	a5,0x6
    800026c6:	68e78793          	addi	a5,a5,1678 # 80008d50 <intr_desc.1>
    800026ca:	973e                	add	a4,a4,a5
    800026cc:	6348                	ld	a0,128(a4)
    800026ce:	b7f5                	j	800026ba <scause_desc+0x84>

00000000800026d0 <trapinit>:
{
    800026d0:	1141                	addi	sp,sp,-16
    800026d2:	e406                	sd	ra,8(sp)
    800026d4:	e022                	sd	s0,0(sp)
    800026d6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026d8:	00006597          	auipc	a1,0x6
    800026dc:	e9058593          	addi	a1,a1,-368 # 80008568 <userret+0x4d8>
    800026e0:	00013517          	auipc	a0,0x13
    800026e4:	3e050513          	addi	a0,a0,992 # 80015ac0 <tickslock>
    800026e8:	ffffe097          	auipc	ra,0xffffe
    800026ec:	2e4080e7          	jalr	740(ra) # 800009cc <initlock>
}
    800026f0:	60a2                	ld	ra,8(sp)
    800026f2:	6402                	ld	s0,0(sp)
    800026f4:	0141                	addi	sp,sp,16
    800026f6:	8082                	ret

00000000800026f8 <trapinithart>:
{
    800026f8:	1141                	addi	sp,sp,-16
    800026fa:	e422                	sd	s0,8(sp)
    800026fc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026fe:	00003797          	auipc	a5,0x3
    80002702:	5f278793          	addi	a5,a5,1522 # 80005cf0 <kernelvec>
    80002706:	10579073          	csrw	stvec,a5
}
    8000270a:	6422                	ld	s0,8(sp)
    8000270c:	0141                	addi	sp,sp,16
    8000270e:	8082                	ret

0000000080002710 <usertrapret>:
{
    80002710:	1141                	addi	sp,sp,-16
    80002712:	e406                	sd	ra,8(sp)
    80002714:	e022                	sd	s0,0(sp)
    80002716:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002718:	fffff097          	auipc	ra,0xfffff
    8000271c:	340080e7          	jalr	832(ra) # 80001a58 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002720:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002724:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002726:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000272a:	00006617          	auipc	a2,0x6
    8000272e:	8d660613          	addi	a2,a2,-1834 # 80008000 <trampoline>
    80002732:	00006697          	auipc	a3,0x6
    80002736:	8ce68693          	addi	a3,a3,-1842 # 80008000 <trampoline>
    8000273a:	8e91                	sub	a3,a3,a2
    8000273c:	040007b7          	lui	a5,0x4000
    80002740:	17fd                	addi	a5,a5,-1
    80002742:	07b2                	slli	a5,a5,0xc
    80002744:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002746:	10569073          	csrw	stvec,a3
  p->tf->kernel_satp = r_satp();         // kernel page table
    8000274a:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000274c:	180026f3          	csrr	a3,satp
    80002750:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002752:	7138                	ld	a4,96(a0)
    80002754:	6534                	ld	a3,72(a0)
    80002756:	6585                	lui	a1,0x1
    80002758:	96ae                	add	a3,a3,a1
    8000275a:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    8000275c:	7138                	ld	a4,96(a0)
    8000275e:	00000697          	auipc	a3,0x0
    80002762:	12c68693          	addi	a3,a3,300 # 8000288a <usertrap>
    80002766:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    80002768:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000276a:	8692                	mv	a3,tp
    8000276c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000276e:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002772:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002776:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000277a:	10069073          	csrw	sstatus,a3
  w_sepc(p->tf->epc);
    8000277e:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002780:	6f18                	ld	a4,24(a4)
    80002782:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    80002786:	6d2c                	ld	a1,88(a0)
    80002788:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000278a:	00006717          	auipc	a4,0x6
    8000278e:	90670713          	addi	a4,a4,-1786 # 80008090 <userret>
    80002792:	8f11                	sub	a4,a4,a2
    80002794:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002796:	577d                	li	a4,-1
    80002798:	177e                	slli	a4,a4,0x3f
    8000279a:	8dd9                	or	a1,a1,a4
    8000279c:	02000537          	lui	a0,0x2000
    800027a0:	157d                	addi	a0,a0,-1
    800027a2:	0536                	slli	a0,a0,0xd
    800027a4:	9782                	jalr	a5
}
    800027a6:	60a2                	ld	ra,8(sp)
    800027a8:	6402                	ld	s0,0(sp)
    800027aa:	0141                	addi	sp,sp,16
    800027ac:	8082                	ret

00000000800027ae <clockintr>:
{
    800027ae:	1101                	addi	sp,sp,-32
    800027b0:	ec06                	sd	ra,24(sp)
    800027b2:	e822                	sd	s0,16(sp)
    800027b4:	e426                	sd	s1,8(sp)
    800027b6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027b8:	00013497          	auipc	s1,0x13
    800027bc:	30848493          	addi	s1,s1,776 # 80015ac0 <tickslock>
    800027c0:	8526                	mv	a0,s1
    800027c2:	ffffe097          	auipc	ra,0xffffe
    800027c6:	2de080e7          	jalr	734(ra) # 80000aa0 <acquire>
  ticks++;
    800027ca:	00026517          	auipc	a0,0x26
    800027ce:	87650513          	addi	a0,a0,-1930 # 80028040 <ticks>
    800027d2:	411c                	lw	a5,0(a0)
    800027d4:	2785                	addiw	a5,a5,1
    800027d6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027d8:	00000097          	auipc	ra,0x0
    800027dc:	bc0080e7          	jalr	-1088(ra) # 80002398 <wakeup>
  release(&tickslock);
    800027e0:	8526                	mv	a0,s1
    800027e2:	ffffe097          	auipc	ra,0xffffe
    800027e6:	38e080e7          	jalr	910(ra) # 80000b70 <release>
}
    800027ea:	60e2                	ld	ra,24(sp)
    800027ec:	6442                	ld	s0,16(sp)
    800027ee:	64a2                	ld	s1,8(sp)
    800027f0:	6105                	addi	sp,sp,32
    800027f2:	8082                	ret

00000000800027f4 <devintr>:
{
    800027f4:	1101                	addi	sp,sp,-32
    800027f6:	ec06                	sd	ra,24(sp)
    800027f8:	e822                	sd	s0,16(sp)
    800027fa:	e426                	sd	s1,8(sp)
    800027fc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027fe:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002802:	00074d63          	bltz	a4,8000281c <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002806:	57fd                	li	a5,-1
    80002808:	17fe                	slli	a5,a5,0x3f
    8000280a:	0785                	addi	a5,a5,1
    return 0;
    8000280c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000280e:	04f70d63          	beq	a4,a5,80002868 <devintr+0x74>
}
    80002812:	60e2                	ld	ra,24(sp)
    80002814:	6442                	ld	s0,16(sp)
    80002816:	64a2                	ld	s1,8(sp)
    80002818:	6105                	addi	sp,sp,32
    8000281a:	8082                	ret
     (scause & 0xff) == 9){
    8000281c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002820:	46a5                	li	a3,9
    80002822:	fed792e3          	bne	a5,a3,80002806 <devintr+0x12>
    int irq = plic_claim();
    80002826:	00003097          	auipc	ra,0x3
    8000282a:	5d2080e7          	jalr	1490(ra) # 80005df8 <plic_claim>
    8000282e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002830:	47a9                	li	a5,10
    80002832:	00f50a63          	beq	a0,a5,80002846 <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    80002836:	fff5079b          	addiw	a5,a0,-1
    8000283a:	4705                	li	a4,1
    8000283c:	00f77a63          	bgeu	a4,a5,80002850 <devintr+0x5c>
    return 1;
    80002840:	4505                	li	a0,1
    if(irq)
    80002842:	d8e1                	beqz	s1,80002812 <devintr+0x1e>
    80002844:	a819                	j	8000285a <devintr+0x66>
      uartintr();
    80002846:	ffffe097          	auipc	ra,0xffffe
    8000284a:	ffe080e7          	jalr	-2(ra) # 80000844 <uartintr>
    8000284e:	a031                	j	8000285a <devintr+0x66>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    80002850:	853e                	mv	a0,a5
    80002852:	00004097          	auipc	ra,0x4
    80002856:	b74080e7          	jalr	-1164(ra) # 800063c6 <virtio_disk_intr>
      plic_complete(irq);
    8000285a:	8526                	mv	a0,s1
    8000285c:	00003097          	auipc	ra,0x3
    80002860:	5c0080e7          	jalr	1472(ra) # 80005e1c <plic_complete>
    return 1;
    80002864:	4505                	li	a0,1
    80002866:	b775                	j	80002812 <devintr+0x1e>
    if(cpuid() == 0){
    80002868:	fffff097          	auipc	ra,0xfffff
    8000286c:	1c4080e7          	jalr	452(ra) # 80001a2c <cpuid>
    80002870:	c901                	beqz	a0,80002880 <devintr+0x8c>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002872:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002876:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002878:	14479073          	csrw	sip,a5
    return 2;
    8000287c:	4509                	li	a0,2
    8000287e:	bf51                	j	80002812 <devintr+0x1e>
      clockintr();
    80002880:	00000097          	auipc	ra,0x0
    80002884:	f2e080e7          	jalr	-210(ra) # 800027ae <clockintr>
    80002888:	b7ed                	j	80002872 <devintr+0x7e>

000000008000288a <usertrap>:
{
    8000288a:	7179                	addi	sp,sp,-48
    8000288c:	f406                	sd	ra,40(sp)
    8000288e:	f022                	sd	s0,32(sp)
    80002890:	ec26                	sd	s1,24(sp)
    80002892:	e84a                	sd	s2,16(sp)
    80002894:	e44e                	sd	s3,8(sp)
    80002896:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002898:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000289c:	1007f793          	andi	a5,a5,256
    800028a0:	e3b5                	bnez	a5,80002904 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028a2:	00003797          	auipc	a5,0x3
    800028a6:	44e78793          	addi	a5,a5,1102 # 80005cf0 <kernelvec>
    800028aa:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028ae:	fffff097          	auipc	ra,0xfffff
    800028b2:	1aa080e7          	jalr	426(ra) # 80001a58 <myproc>
    800028b6:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    800028b8:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ba:	14102773          	csrr	a4,sepc
    800028be:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028c0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028c4:	47a1                	li	a5,8
    800028c6:	04f71d63          	bne	a4,a5,80002920 <usertrap+0x96>
    if(p->killed)
    800028ca:	5d1c                	lw	a5,56(a0)
    800028cc:	e7a1                	bnez	a5,80002914 <usertrap+0x8a>
    p->tf->epc += 4;
    800028ce:	70b8                	ld	a4,96(s1)
    800028d0:	6f1c                	ld	a5,24(a4)
    800028d2:	0791                	addi	a5,a5,4
    800028d4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028da:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028de:	10079073          	csrw	sstatus,a5
    syscall();
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	2fe080e7          	jalr	766(ra) # 80002be0 <syscall>
  if(p->killed)
    800028ea:	5c9c                	lw	a5,56(s1)
    800028ec:	e3cd                	bnez	a5,8000298e <usertrap+0x104>
  usertrapret();
    800028ee:	00000097          	auipc	ra,0x0
    800028f2:	e22080e7          	jalr	-478(ra) # 80002710 <usertrapret>
}
    800028f6:	70a2                	ld	ra,40(sp)
    800028f8:	7402                	ld	s0,32(sp)
    800028fa:	64e2                	ld	s1,24(sp)
    800028fc:	6942                	ld	s2,16(sp)
    800028fe:	69a2                	ld	s3,8(sp)
    80002900:	6145                	addi	sp,sp,48
    80002902:	8082                	ret
    panic("usertrap: not from user mode");
    80002904:	00006517          	auipc	a0,0x6
    80002908:	c6c50513          	addi	a0,a0,-916 # 80008570 <userret+0x4e0>
    8000290c:	ffffe097          	auipc	ra,0xffffe
    80002910:	c48080e7          	jalr	-952(ra) # 80000554 <panic>
      exit(-1);
    80002914:	557d                	li	a0,-1
    80002916:	fffff097          	auipc	ra,0xfffff
    8000291a:	7b8080e7          	jalr	1976(ra) # 800020ce <exit>
    8000291e:	bf45                	j	800028ce <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80002920:	00000097          	auipc	ra,0x0
    80002924:	ed4080e7          	jalr	-300(ra) # 800027f4 <devintr>
    80002928:	892a                	mv	s2,a0
    8000292a:	c501                	beqz	a0,80002932 <usertrap+0xa8>
  if(p->killed)
    8000292c:	5c9c                	lw	a5,56(s1)
    8000292e:	cba1                	beqz	a5,8000297e <usertrap+0xf4>
    80002930:	a091                	j	80002974 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002932:	142029f3          	csrr	s3,scause
    80002936:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    8000293a:	00000097          	auipc	ra,0x0
    8000293e:	cfc080e7          	jalr	-772(ra) # 80002636 <scause_desc>
    80002942:	862a                	mv	a2,a0
    80002944:	40b4                	lw	a3,64(s1)
    80002946:	85ce                	mv	a1,s3
    80002948:	00006517          	auipc	a0,0x6
    8000294c:	c4850513          	addi	a0,a0,-952 # 80008590 <userret+0x500>
    80002950:	ffffe097          	auipc	ra,0xffffe
    80002954:	c5e080e7          	jalr	-930(ra) # 800005ae <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002958:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000295c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002960:	00006517          	auipc	a0,0x6
    80002964:	c6050513          	addi	a0,a0,-928 # 800085c0 <userret+0x530>
    80002968:	ffffe097          	auipc	ra,0xffffe
    8000296c:	c46080e7          	jalr	-954(ra) # 800005ae <printf>
    p->killed = 1;
    80002970:	4785                	li	a5,1
    80002972:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002974:	557d                	li	a0,-1
    80002976:	fffff097          	auipc	ra,0xfffff
    8000297a:	758080e7          	jalr	1880(ra) # 800020ce <exit>
  if(which_dev == 2)
    8000297e:	4789                	li	a5,2
    80002980:	f6f917e3          	bne	s2,a5,800028ee <usertrap+0x64>
    yield();
    80002984:	00000097          	auipc	ra,0x0
    80002988:	858080e7          	jalr	-1960(ra) # 800021dc <yield>
    8000298c:	b78d                	j	800028ee <usertrap+0x64>
  int which_dev = 0;
    8000298e:	4901                	li	s2,0
    80002990:	b7d5                	j	80002974 <usertrap+0xea>

0000000080002992 <kerneltrap>:
{
    80002992:	7179                	addi	sp,sp,-48
    80002994:	f406                	sd	ra,40(sp)
    80002996:	f022                	sd	s0,32(sp)
    80002998:	ec26                	sd	s1,24(sp)
    8000299a:	e84a                	sd	s2,16(sp)
    8000299c:	e44e                	sd	s3,8(sp)
    8000299e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029a0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029a4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029a8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029ac:	1004f793          	andi	a5,s1,256
    800029b0:	cb85                	beqz	a5,800029e0 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029b6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029b8:	ef85                	bnez	a5,800029f0 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029ba:	00000097          	auipc	ra,0x0
    800029be:	e3a080e7          	jalr	-454(ra) # 800027f4 <devintr>
    800029c2:	cd1d                	beqz	a0,80002a00 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029c4:	4789                	li	a5,2
    800029c6:	08f50063          	beq	a0,a5,80002a46 <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029ca:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ce:	10049073          	csrw	sstatus,s1
}
    800029d2:	70a2                	ld	ra,40(sp)
    800029d4:	7402                	ld	s0,32(sp)
    800029d6:	64e2                	ld	s1,24(sp)
    800029d8:	6942                	ld	s2,16(sp)
    800029da:	69a2                	ld	s3,8(sp)
    800029dc:	6145                	addi	sp,sp,48
    800029de:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029e0:	00006517          	auipc	a0,0x6
    800029e4:	c0050513          	addi	a0,a0,-1024 # 800085e0 <userret+0x550>
    800029e8:	ffffe097          	auipc	ra,0xffffe
    800029ec:	b6c080e7          	jalr	-1172(ra) # 80000554 <panic>
    panic("kerneltrap: interrupts enabled");
    800029f0:	00006517          	auipc	a0,0x6
    800029f4:	c1850513          	addi	a0,a0,-1000 # 80008608 <userret+0x578>
    800029f8:	ffffe097          	auipc	ra,0xffffe
    800029fc:	b5c080e7          	jalr	-1188(ra) # 80000554 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002a00:	854e                	mv	a0,s3
    80002a02:	00000097          	auipc	ra,0x0
    80002a06:	c34080e7          	jalr	-972(ra) # 80002636 <scause_desc>
    80002a0a:	862a                	mv	a2,a0
    80002a0c:	85ce                	mv	a1,s3
    80002a0e:	00006517          	auipc	a0,0x6
    80002a12:	c1a50513          	addi	a0,a0,-998 # 80008628 <userret+0x598>
    80002a16:	ffffe097          	auipc	ra,0xffffe
    80002a1a:	b98080e7          	jalr	-1128(ra) # 800005ae <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a1e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a22:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a26:	00006517          	auipc	a0,0x6
    80002a2a:	c1250513          	addi	a0,a0,-1006 # 80008638 <userret+0x5a8>
    80002a2e:	ffffe097          	auipc	ra,0xffffe
    80002a32:	b80080e7          	jalr	-1152(ra) # 800005ae <printf>
    panic("kerneltrap");
    80002a36:	00006517          	auipc	a0,0x6
    80002a3a:	c1a50513          	addi	a0,a0,-998 # 80008650 <userret+0x5c0>
    80002a3e:	ffffe097          	auipc	ra,0xffffe
    80002a42:	b16080e7          	jalr	-1258(ra) # 80000554 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a46:	fffff097          	auipc	ra,0xfffff
    80002a4a:	012080e7          	jalr	18(ra) # 80001a58 <myproc>
    80002a4e:	dd35                	beqz	a0,800029ca <kerneltrap+0x38>
    80002a50:	fffff097          	auipc	ra,0xfffff
    80002a54:	008080e7          	jalr	8(ra) # 80001a58 <myproc>
    80002a58:	5118                	lw	a4,32(a0)
    80002a5a:	478d                	li	a5,3
    80002a5c:	f6f717e3          	bne	a4,a5,800029ca <kerneltrap+0x38>
    yield();
    80002a60:	fffff097          	auipc	ra,0xfffff
    80002a64:	77c080e7          	jalr	1916(ra) # 800021dc <yield>
    80002a68:	b78d                	j	800029ca <kerneltrap+0x38>

0000000080002a6a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a6a:	1101                	addi	sp,sp,-32
    80002a6c:	ec06                	sd	ra,24(sp)
    80002a6e:	e822                	sd	s0,16(sp)
    80002a70:	e426                	sd	s1,8(sp)
    80002a72:	1000                	addi	s0,sp,32
    80002a74:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a76:	fffff097          	auipc	ra,0xfffff
    80002a7a:	fe2080e7          	jalr	-30(ra) # 80001a58 <myproc>
  switch (n) {
    80002a7e:	4795                	li	a5,5
    80002a80:	0497e163          	bltu	a5,s1,80002ac2 <argraw+0x58>
    80002a84:	048a                	slli	s1,s1,0x2
    80002a86:	00006717          	auipc	a4,0x6
    80002a8a:	3ca70713          	addi	a4,a4,970 # 80008e50 <nointr_desc.0+0x80>
    80002a8e:	94ba                	add	s1,s1,a4
    80002a90:	409c                	lw	a5,0(s1)
    80002a92:	97ba                	add	a5,a5,a4
    80002a94:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002a96:	713c                	ld	a5,96(a0)
    80002a98:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002a9a:	60e2                	ld	ra,24(sp)
    80002a9c:	6442                	ld	s0,16(sp)
    80002a9e:	64a2                	ld	s1,8(sp)
    80002aa0:	6105                	addi	sp,sp,32
    80002aa2:	8082                	ret
    return p->tf->a1;
    80002aa4:	713c                	ld	a5,96(a0)
    80002aa6:	7fa8                	ld	a0,120(a5)
    80002aa8:	bfcd                	j	80002a9a <argraw+0x30>
    return p->tf->a2;
    80002aaa:	713c                	ld	a5,96(a0)
    80002aac:	63c8                	ld	a0,128(a5)
    80002aae:	b7f5                	j	80002a9a <argraw+0x30>
    return p->tf->a3;
    80002ab0:	713c                	ld	a5,96(a0)
    80002ab2:	67c8                	ld	a0,136(a5)
    80002ab4:	b7dd                	j	80002a9a <argraw+0x30>
    return p->tf->a4;
    80002ab6:	713c                	ld	a5,96(a0)
    80002ab8:	6bc8                	ld	a0,144(a5)
    80002aba:	b7c5                	j	80002a9a <argraw+0x30>
    return p->tf->a5;
    80002abc:	713c                	ld	a5,96(a0)
    80002abe:	6fc8                	ld	a0,152(a5)
    80002ac0:	bfe9                	j	80002a9a <argraw+0x30>
  panic("argraw");
    80002ac2:	00006517          	auipc	a0,0x6
    80002ac6:	d9650513          	addi	a0,a0,-618 # 80008858 <userret+0x7c8>
    80002aca:	ffffe097          	auipc	ra,0xffffe
    80002ace:	a8a080e7          	jalr	-1398(ra) # 80000554 <panic>

0000000080002ad2 <fetchaddr>:
{
    80002ad2:	1101                	addi	sp,sp,-32
    80002ad4:	ec06                	sd	ra,24(sp)
    80002ad6:	e822                	sd	s0,16(sp)
    80002ad8:	e426                	sd	s1,8(sp)
    80002ada:	e04a                	sd	s2,0(sp)
    80002adc:	1000                	addi	s0,sp,32
    80002ade:	84aa                	mv	s1,a0
    80002ae0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ae2:	fffff097          	auipc	ra,0xfffff
    80002ae6:	f76080e7          	jalr	-138(ra) # 80001a58 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002aea:	693c                	ld	a5,80(a0)
    80002aec:	02f4f863          	bgeu	s1,a5,80002b1c <fetchaddr+0x4a>
    80002af0:	00848713          	addi	a4,s1,8
    80002af4:	02e7e663          	bltu	a5,a4,80002b20 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002af8:	46a1                	li	a3,8
    80002afa:	8626                	mv	a2,s1
    80002afc:	85ca                	mv	a1,s2
    80002afe:	6d28                	ld	a0,88(a0)
    80002b00:	fffff097          	auipc	ra,0xfffff
    80002b04:	cd6080e7          	jalr	-810(ra) # 800017d6 <copyin>
    80002b08:	00a03533          	snez	a0,a0
    80002b0c:	40a00533          	neg	a0,a0
}
    80002b10:	60e2                	ld	ra,24(sp)
    80002b12:	6442                	ld	s0,16(sp)
    80002b14:	64a2                	ld	s1,8(sp)
    80002b16:	6902                	ld	s2,0(sp)
    80002b18:	6105                	addi	sp,sp,32
    80002b1a:	8082                	ret
    return -1;
    80002b1c:	557d                	li	a0,-1
    80002b1e:	bfcd                	j	80002b10 <fetchaddr+0x3e>
    80002b20:	557d                	li	a0,-1
    80002b22:	b7fd                	j	80002b10 <fetchaddr+0x3e>

0000000080002b24 <fetchstr>:
{
    80002b24:	7179                	addi	sp,sp,-48
    80002b26:	f406                	sd	ra,40(sp)
    80002b28:	f022                	sd	s0,32(sp)
    80002b2a:	ec26                	sd	s1,24(sp)
    80002b2c:	e84a                	sd	s2,16(sp)
    80002b2e:	e44e                	sd	s3,8(sp)
    80002b30:	1800                	addi	s0,sp,48
    80002b32:	892a                	mv	s2,a0
    80002b34:	84ae                	mv	s1,a1
    80002b36:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b38:	fffff097          	auipc	ra,0xfffff
    80002b3c:	f20080e7          	jalr	-224(ra) # 80001a58 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002b40:	86ce                	mv	a3,s3
    80002b42:	864a                	mv	a2,s2
    80002b44:	85a6                	mv	a1,s1
    80002b46:	6d28                	ld	a0,88(a0)
    80002b48:	fffff097          	auipc	ra,0xfffff
    80002b4c:	d1c080e7          	jalr	-740(ra) # 80001864 <copyinstr>
  if(err < 0)
    80002b50:	00054763          	bltz	a0,80002b5e <fetchstr+0x3a>
  return strlen(buf);
    80002b54:	8526                	mv	a0,s1
    80002b56:	ffffe097          	auipc	ra,0xffffe
    80002b5a:	39c080e7          	jalr	924(ra) # 80000ef2 <strlen>
}
    80002b5e:	70a2                	ld	ra,40(sp)
    80002b60:	7402                	ld	s0,32(sp)
    80002b62:	64e2                	ld	s1,24(sp)
    80002b64:	6942                	ld	s2,16(sp)
    80002b66:	69a2                	ld	s3,8(sp)
    80002b68:	6145                	addi	sp,sp,48
    80002b6a:	8082                	ret

0000000080002b6c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b6c:	1101                	addi	sp,sp,-32
    80002b6e:	ec06                	sd	ra,24(sp)
    80002b70:	e822                	sd	s0,16(sp)
    80002b72:	e426                	sd	s1,8(sp)
    80002b74:	1000                	addi	s0,sp,32
    80002b76:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b78:	00000097          	auipc	ra,0x0
    80002b7c:	ef2080e7          	jalr	-270(ra) # 80002a6a <argraw>
    80002b80:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b82:	4501                	li	a0,0
    80002b84:	60e2                	ld	ra,24(sp)
    80002b86:	6442                	ld	s0,16(sp)
    80002b88:	64a2                	ld	s1,8(sp)
    80002b8a:	6105                	addi	sp,sp,32
    80002b8c:	8082                	ret

0000000080002b8e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b8e:	1101                	addi	sp,sp,-32
    80002b90:	ec06                	sd	ra,24(sp)
    80002b92:	e822                	sd	s0,16(sp)
    80002b94:	e426                	sd	s1,8(sp)
    80002b96:	1000                	addi	s0,sp,32
    80002b98:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b9a:	00000097          	auipc	ra,0x0
    80002b9e:	ed0080e7          	jalr	-304(ra) # 80002a6a <argraw>
    80002ba2:	e088                	sd	a0,0(s1)
  return 0;
}
    80002ba4:	4501                	li	a0,0
    80002ba6:	60e2                	ld	ra,24(sp)
    80002ba8:	6442                	ld	s0,16(sp)
    80002baa:	64a2                	ld	s1,8(sp)
    80002bac:	6105                	addi	sp,sp,32
    80002bae:	8082                	ret

0000000080002bb0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bb0:	1101                	addi	sp,sp,-32
    80002bb2:	ec06                	sd	ra,24(sp)
    80002bb4:	e822                	sd	s0,16(sp)
    80002bb6:	e426                	sd	s1,8(sp)
    80002bb8:	e04a                	sd	s2,0(sp)
    80002bba:	1000                	addi	s0,sp,32
    80002bbc:	84ae                	mv	s1,a1
    80002bbe:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002bc0:	00000097          	auipc	ra,0x0
    80002bc4:	eaa080e7          	jalr	-342(ra) # 80002a6a <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002bc8:	864a                	mv	a2,s2
    80002bca:	85a6                	mv	a1,s1
    80002bcc:	00000097          	auipc	ra,0x0
    80002bd0:	f58080e7          	jalr	-168(ra) # 80002b24 <fetchstr>
}
    80002bd4:	60e2                	ld	ra,24(sp)
    80002bd6:	6442                	ld	s0,16(sp)
    80002bd8:	64a2                	ld	s1,8(sp)
    80002bda:	6902                	ld	s2,0(sp)
    80002bdc:	6105                	addi	sp,sp,32
    80002bde:	8082                	ret

0000000080002be0 <syscall>:
[SYS_ntas]    sys_ntas,
};

void
syscall(void)
{
    80002be0:	1101                	addi	sp,sp,-32
    80002be2:	ec06                	sd	ra,24(sp)
    80002be4:	e822                	sd	s0,16(sp)
    80002be6:	e426                	sd	s1,8(sp)
    80002be8:	e04a                	sd	s2,0(sp)
    80002bea:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bec:	fffff097          	auipc	ra,0xfffff
    80002bf0:	e6c080e7          	jalr	-404(ra) # 80001a58 <myproc>
    80002bf4:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002bf6:	06053903          	ld	s2,96(a0)
    80002bfa:	0a893783          	ld	a5,168(s2)
    80002bfe:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c02:	37fd                	addiw	a5,a5,-1
    80002c04:	4755                	li	a4,21
    80002c06:	00f76f63          	bltu	a4,a5,80002c24 <syscall+0x44>
    80002c0a:	00369713          	slli	a4,a3,0x3
    80002c0e:	00006797          	auipc	a5,0x6
    80002c12:	25a78793          	addi	a5,a5,602 # 80008e68 <syscalls>
    80002c16:	97ba                	add	a5,a5,a4
    80002c18:	639c                	ld	a5,0(a5)
    80002c1a:	c789                	beqz	a5,80002c24 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002c1c:	9782                	jalr	a5
    80002c1e:	06a93823          	sd	a0,112(s2)
    80002c22:	a839                	j	80002c40 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c24:	16048613          	addi	a2,s1,352
    80002c28:	40ac                	lw	a1,64(s1)
    80002c2a:	00006517          	auipc	a0,0x6
    80002c2e:	c3650513          	addi	a0,a0,-970 # 80008860 <userret+0x7d0>
    80002c32:	ffffe097          	auipc	ra,0xffffe
    80002c36:	97c080e7          	jalr	-1668(ra) # 800005ae <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002c3a:	70bc                	ld	a5,96(s1)
    80002c3c:	577d                	li	a4,-1
    80002c3e:	fbb8                	sd	a4,112(a5)
  }
}
    80002c40:	60e2                	ld	ra,24(sp)
    80002c42:	6442                	ld	s0,16(sp)
    80002c44:	64a2                	ld	s1,8(sp)
    80002c46:	6902                	ld	s2,0(sp)
    80002c48:	6105                	addi	sp,sp,32
    80002c4a:	8082                	ret

0000000080002c4c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c4c:	1101                	addi	sp,sp,-32
    80002c4e:	ec06                	sd	ra,24(sp)
    80002c50:	e822                	sd	s0,16(sp)
    80002c52:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c54:	fec40593          	addi	a1,s0,-20
    80002c58:	4501                	li	a0,0
    80002c5a:	00000097          	auipc	ra,0x0
    80002c5e:	f12080e7          	jalr	-238(ra) # 80002b6c <argint>
    return -1;
    80002c62:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c64:	00054963          	bltz	a0,80002c76 <sys_exit+0x2a>
  exit(n);
    80002c68:	fec42503          	lw	a0,-20(s0)
    80002c6c:	fffff097          	auipc	ra,0xfffff
    80002c70:	462080e7          	jalr	1122(ra) # 800020ce <exit>
  return 0;  // not reached
    80002c74:	4781                	li	a5,0
}
    80002c76:	853e                	mv	a0,a5
    80002c78:	60e2                	ld	ra,24(sp)
    80002c7a:	6442                	ld	s0,16(sp)
    80002c7c:	6105                	addi	sp,sp,32
    80002c7e:	8082                	ret

0000000080002c80 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c80:	1141                	addi	sp,sp,-16
    80002c82:	e406                	sd	ra,8(sp)
    80002c84:	e022                	sd	s0,0(sp)
    80002c86:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c88:	fffff097          	auipc	ra,0xfffff
    80002c8c:	dd0080e7          	jalr	-560(ra) # 80001a58 <myproc>
}
    80002c90:	4128                	lw	a0,64(a0)
    80002c92:	60a2                	ld	ra,8(sp)
    80002c94:	6402                	ld	s0,0(sp)
    80002c96:	0141                	addi	sp,sp,16
    80002c98:	8082                	ret

0000000080002c9a <sys_fork>:

uint64
sys_fork(void)
{
    80002c9a:	1141                	addi	sp,sp,-16
    80002c9c:	e406                	sd	ra,8(sp)
    80002c9e:	e022                	sd	s0,0(sp)
    80002ca0:	0800                	addi	s0,sp,16
  return fork();
    80002ca2:	fffff097          	auipc	ra,0xfffff
    80002ca6:	120080e7          	jalr	288(ra) # 80001dc2 <fork>
}
    80002caa:	60a2                	ld	ra,8(sp)
    80002cac:	6402                	ld	s0,0(sp)
    80002cae:	0141                	addi	sp,sp,16
    80002cb0:	8082                	ret

0000000080002cb2 <sys_wait>:

uint64
sys_wait(void)
{
    80002cb2:	1101                	addi	sp,sp,-32
    80002cb4:	ec06                	sd	ra,24(sp)
    80002cb6:	e822                	sd	s0,16(sp)
    80002cb8:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002cba:	fe840593          	addi	a1,s0,-24
    80002cbe:	4501                	li	a0,0
    80002cc0:	00000097          	auipc	ra,0x0
    80002cc4:	ece080e7          	jalr	-306(ra) # 80002b8e <argaddr>
    80002cc8:	87aa                	mv	a5,a0
    return -1;
    80002cca:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002ccc:	0007c863          	bltz	a5,80002cdc <sys_wait+0x2a>
  return wait(p);
    80002cd0:	fe843503          	ld	a0,-24(s0)
    80002cd4:	fffff097          	auipc	ra,0xfffff
    80002cd8:	5c2080e7          	jalr	1474(ra) # 80002296 <wait>
}
    80002cdc:	60e2                	ld	ra,24(sp)
    80002cde:	6442                	ld	s0,16(sp)
    80002ce0:	6105                	addi	sp,sp,32
    80002ce2:	8082                	ret

0000000080002ce4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ce4:	7179                	addi	sp,sp,-48
    80002ce6:	f406                	sd	ra,40(sp)
    80002ce8:	f022                	sd	s0,32(sp)
    80002cea:	ec26                	sd	s1,24(sp)
    80002cec:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002cee:	fdc40593          	addi	a1,s0,-36
    80002cf2:	4501                	li	a0,0
    80002cf4:	00000097          	auipc	ra,0x0
    80002cf8:	e78080e7          	jalr	-392(ra) # 80002b6c <argint>
    return -1;
    80002cfc:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002cfe:	00054f63          	bltz	a0,80002d1c <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002d02:	fffff097          	auipc	ra,0xfffff
    80002d06:	d56080e7          	jalr	-682(ra) # 80001a58 <myproc>
    80002d0a:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002d0c:	fdc42503          	lw	a0,-36(s0)
    80002d10:	fffff097          	auipc	ra,0xfffff
    80002d14:	03e080e7          	jalr	62(ra) # 80001d4e <growproc>
    80002d18:	00054863          	bltz	a0,80002d28 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002d1c:	8526                	mv	a0,s1
    80002d1e:	70a2                	ld	ra,40(sp)
    80002d20:	7402                	ld	s0,32(sp)
    80002d22:	64e2                	ld	s1,24(sp)
    80002d24:	6145                	addi	sp,sp,48
    80002d26:	8082                	ret
    return -1;
    80002d28:	54fd                	li	s1,-1
    80002d2a:	bfcd                	j	80002d1c <sys_sbrk+0x38>

0000000080002d2c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d2c:	7139                	addi	sp,sp,-64
    80002d2e:	fc06                	sd	ra,56(sp)
    80002d30:	f822                	sd	s0,48(sp)
    80002d32:	f426                	sd	s1,40(sp)
    80002d34:	f04a                	sd	s2,32(sp)
    80002d36:	ec4e                	sd	s3,24(sp)
    80002d38:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d3a:	fcc40593          	addi	a1,s0,-52
    80002d3e:	4501                	li	a0,0
    80002d40:	00000097          	auipc	ra,0x0
    80002d44:	e2c080e7          	jalr	-468(ra) # 80002b6c <argint>
    return -1;
    80002d48:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d4a:	06054563          	bltz	a0,80002db4 <sys_sleep+0x88>
  acquire(&tickslock);
    80002d4e:	00013517          	auipc	a0,0x13
    80002d52:	d7250513          	addi	a0,a0,-654 # 80015ac0 <tickslock>
    80002d56:	ffffe097          	auipc	ra,0xffffe
    80002d5a:	d4a080e7          	jalr	-694(ra) # 80000aa0 <acquire>
  ticks0 = ticks;
    80002d5e:	00025917          	auipc	s2,0x25
    80002d62:	2e292903          	lw	s2,738(s2) # 80028040 <ticks>
  while(ticks - ticks0 < n){
    80002d66:	fcc42783          	lw	a5,-52(s0)
    80002d6a:	cf85                	beqz	a5,80002da2 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d6c:	00013997          	auipc	s3,0x13
    80002d70:	d5498993          	addi	s3,s3,-684 # 80015ac0 <tickslock>
    80002d74:	00025497          	auipc	s1,0x25
    80002d78:	2cc48493          	addi	s1,s1,716 # 80028040 <ticks>
    if(myproc()->killed){
    80002d7c:	fffff097          	auipc	ra,0xfffff
    80002d80:	cdc080e7          	jalr	-804(ra) # 80001a58 <myproc>
    80002d84:	5d1c                	lw	a5,56(a0)
    80002d86:	ef9d                	bnez	a5,80002dc4 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d88:	85ce                	mv	a1,s3
    80002d8a:	8526                	mv	a0,s1
    80002d8c:	fffff097          	auipc	ra,0xfffff
    80002d90:	48c080e7          	jalr	1164(ra) # 80002218 <sleep>
  while(ticks - ticks0 < n){
    80002d94:	409c                	lw	a5,0(s1)
    80002d96:	412787bb          	subw	a5,a5,s2
    80002d9a:	fcc42703          	lw	a4,-52(s0)
    80002d9e:	fce7efe3          	bltu	a5,a4,80002d7c <sys_sleep+0x50>
  }
  release(&tickslock);
    80002da2:	00013517          	auipc	a0,0x13
    80002da6:	d1e50513          	addi	a0,a0,-738 # 80015ac0 <tickslock>
    80002daa:	ffffe097          	auipc	ra,0xffffe
    80002dae:	dc6080e7          	jalr	-570(ra) # 80000b70 <release>
  return 0;
    80002db2:	4781                	li	a5,0
}
    80002db4:	853e                	mv	a0,a5
    80002db6:	70e2                	ld	ra,56(sp)
    80002db8:	7442                	ld	s0,48(sp)
    80002dba:	74a2                	ld	s1,40(sp)
    80002dbc:	7902                	ld	s2,32(sp)
    80002dbe:	69e2                	ld	s3,24(sp)
    80002dc0:	6121                	addi	sp,sp,64
    80002dc2:	8082                	ret
      release(&tickslock);
    80002dc4:	00013517          	auipc	a0,0x13
    80002dc8:	cfc50513          	addi	a0,a0,-772 # 80015ac0 <tickslock>
    80002dcc:	ffffe097          	auipc	ra,0xffffe
    80002dd0:	da4080e7          	jalr	-604(ra) # 80000b70 <release>
      return -1;
    80002dd4:	57fd                	li	a5,-1
    80002dd6:	bff9                	j	80002db4 <sys_sleep+0x88>

0000000080002dd8 <sys_kill>:

uint64
sys_kill(void)
{
    80002dd8:	1101                	addi	sp,sp,-32
    80002dda:	ec06                	sd	ra,24(sp)
    80002ddc:	e822                	sd	s0,16(sp)
    80002dde:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002de0:	fec40593          	addi	a1,s0,-20
    80002de4:	4501                	li	a0,0
    80002de6:	00000097          	auipc	ra,0x0
    80002dea:	d86080e7          	jalr	-634(ra) # 80002b6c <argint>
    80002dee:	87aa                	mv	a5,a0
    return -1;
    80002df0:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002df2:	0007c863          	bltz	a5,80002e02 <sys_kill+0x2a>
  return kill(pid);
    80002df6:	fec42503          	lw	a0,-20(s0)
    80002dfa:	fffff097          	auipc	ra,0xfffff
    80002dfe:	608080e7          	jalr	1544(ra) # 80002402 <kill>
}
    80002e02:	60e2                	ld	ra,24(sp)
    80002e04:	6442                	ld	s0,16(sp)
    80002e06:	6105                	addi	sp,sp,32
    80002e08:	8082                	ret

0000000080002e0a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e0a:	1101                	addi	sp,sp,-32
    80002e0c:	ec06                	sd	ra,24(sp)
    80002e0e:	e822                	sd	s0,16(sp)
    80002e10:	e426                	sd	s1,8(sp)
    80002e12:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e14:	00013517          	auipc	a0,0x13
    80002e18:	cac50513          	addi	a0,a0,-852 # 80015ac0 <tickslock>
    80002e1c:	ffffe097          	auipc	ra,0xffffe
    80002e20:	c84080e7          	jalr	-892(ra) # 80000aa0 <acquire>
  xticks = ticks;
    80002e24:	00025497          	auipc	s1,0x25
    80002e28:	21c4a483          	lw	s1,540(s1) # 80028040 <ticks>
  release(&tickslock);
    80002e2c:	00013517          	auipc	a0,0x13
    80002e30:	c9450513          	addi	a0,a0,-876 # 80015ac0 <tickslock>
    80002e34:	ffffe097          	auipc	ra,0xffffe
    80002e38:	d3c080e7          	jalr	-708(ra) # 80000b70 <release>
  return xticks;
}
    80002e3c:	02049513          	slli	a0,s1,0x20
    80002e40:	9101                	srli	a0,a0,0x20
    80002e42:	60e2                	ld	ra,24(sp)
    80002e44:	6442                	ld	s0,16(sp)
    80002e46:	64a2                	ld	s1,8(sp)
    80002e48:	6105                	addi	sp,sp,32
    80002e4a:	8082                	ret

0000000080002e4c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e4c:	7179                	addi	sp,sp,-48
    80002e4e:	f406                	sd	ra,40(sp)
    80002e50:	f022                	sd	s0,32(sp)
    80002e52:	ec26                	sd	s1,24(sp)
    80002e54:	e84a                	sd	s2,16(sp)
    80002e56:	e44e                	sd	s3,8(sp)
    80002e58:	e052                	sd	s4,0(sp)
    80002e5a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e5c:	00005597          	auipc	a1,0x5
    80002e60:	45c58593          	addi	a1,a1,1116 # 800082b8 <userret+0x228>
    80002e64:	00013517          	auipc	a0,0x13
    80002e68:	c7c50513          	addi	a0,a0,-900 # 80015ae0 <bcache>
    80002e6c:	ffffe097          	auipc	ra,0xffffe
    80002e70:	b60080e7          	jalr	-1184(ra) # 800009cc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e74:	0001b797          	auipc	a5,0x1b
    80002e78:	c6c78793          	addi	a5,a5,-916 # 8001dae0 <bcache+0x8000>
    80002e7c:	0001b717          	auipc	a4,0x1b
    80002e80:	fc470713          	addi	a4,a4,-60 # 8001de40 <bcache+0x8360>
    80002e84:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    80002e88:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e8c:	00013497          	auipc	s1,0x13
    80002e90:	c7448493          	addi	s1,s1,-908 # 80015b00 <bcache+0x20>
    b->next = bcache.head.next;
    80002e94:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e96:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e98:	00006a17          	auipc	s4,0x6
    80002e9c:	9e8a0a13          	addi	s4,s4,-1560 # 80008880 <userret+0x7f0>
    b->next = bcache.head.next;
    80002ea0:	3b893783          	ld	a5,952(s2)
    80002ea4:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    80002ea6:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    80002eaa:	85d2                	mv	a1,s4
    80002eac:	01048513          	addi	a0,s1,16
    80002eb0:	00001097          	auipc	ra,0x1
    80002eb4:	5a0080e7          	jalr	1440(ra) # 80004450 <initsleeplock>
    bcache.head.next->prev = b;
    80002eb8:	3b893783          	ld	a5,952(s2)
    80002ebc:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    80002ebe:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ec2:	46048493          	addi	s1,s1,1120
    80002ec6:	fd349de3          	bne	s1,s3,80002ea0 <binit+0x54>
  }
}
    80002eca:	70a2                	ld	ra,40(sp)
    80002ecc:	7402                	ld	s0,32(sp)
    80002ece:	64e2                	ld	s1,24(sp)
    80002ed0:	6942                	ld	s2,16(sp)
    80002ed2:	69a2                	ld	s3,8(sp)
    80002ed4:	6a02                	ld	s4,0(sp)
    80002ed6:	6145                	addi	sp,sp,48
    80002ed8:	8082                	ret

0000000080002eda <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002eda:	7179                	addi	sp,sp,-48
    80002edc:	f406                	sd	ra,40(sp)
    80002ede:	f022                	sd	s0,32(sp)
    80002ee0:	ec26                	sd	s1,24(sp)
    80002ee2:	e84a                	sd	s2,16(sp)
    80002ee4:	e44e                	sd	s3,8(sp)
    80002ee6:	1800                	addi	s0,sp,48
    80002ee8:	892a                	mv	s2,a0
    80002eea:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002eec:	00013517          	auipc	a0,0x13
    80002ef0:	bf450513          	addi	a0,a0,-1036 # 80015ae0 <bcache>
    80002ef4:	ffffe097          	auipc	ra,0xffffe
    80002ef8:	bac080e7          	jalr	-1108(ra) # 80000aa0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002efc:	0001b497          	auipc	s1,0x1b
    80002f00:	f9c4b483          	ld	s1,-100(s1) # 8001de98 <bcache+0x83b8>
    80002f04:	0001b797          	auipc	a5,0x1b
    80002f08:	f3c78793          	addi	a5,a5,-196 # 8001de40 <bcache+0x8360>
    80002f0c:	02f48f63          	beq	s1,a5,80002f4a <bread+0x70>
    80002f10:	873e                	mv	a4,a5
    80002f12:	a021                	j	80002f1a <bread+0x40>
    80002f14:	6ca4                	ld	s1,88(s1)
    80002f16:	02e48a63          	beq	s1,a4,80002f4a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f1a:	449c                	lw	a5,8(s1)
    80002f1c:	ff279ce3          	bne	a5,s2,80002f14 <bread+0x3a>
    80002f20:	44dc                	lw	a5,12(s1)
    80002f22:	ff3799e3          	bne	a5,s3,80002f14 <bread+0x3a>
      b->refcnt++;
    80002f26:	44bc                	lw	a5,72(s1)
    80002f28:	2785                	addiw	a5,a5,1
    80002f2a:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002f2c:	00013517          	auipc	a0,0x13
    80002f30:	bb450513          	addi	a0,a0,-1100 # 80015ae0 <bcache>
    80002f34:	ffffe097          	auipc	ra,0xffffe
    80002f38:	c3c080e7          	jalr	-964(ra) # 80000b70 <release>
      acquiresleep(&b->lock);
    80002f3c:	01048513          	addi	a0,s1,16
    80002f40:	00001097          	auipc	ra,0x1
    80002f44:	54a080e7          	jalr	1354(ra) # 8000448a <acquiresleep>
      return b;
    80002f48:	a8b9                	j	80002fa6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f4a:	0001b497          	auipc	s1,0x1b
    80002f4e:	f464b483          	ld	s1,-186(s1) # 8001de90 <bcache+0x83b0>
    80002f52:	0001b797          	auipc	a5,0x1b
    80002f56:	eee78793          	addi	a5,a5,-274 # 8001de40 <bcache+0x8360>
    80002f5a:	00f48863          	beq	s1,a5,80002f6a <bread+0x90>
    80002f5e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f60:	44bc                	lw	a5,72(s1)
    80002f62:	cf81                	beqz	a5,80002f7a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f64:	68a4                	ld	s1,80(s1)
    80002f66:	fee49de3          	bne	s1,a4,80002f60 <bread+0x86>
  panic("bget: no buffers");
    80002f6a:	00006517          	auipc	a0,0x6
    80002f6e:	91e50513          	addi	a0,a0,-1762 # 80008888 <userret+0x7f8>
    80002f72:	ffffd097          	auipc	ra,0xffffd
    80002f76:	5e2080e7          	jalr	1506(ra) # 80000554 <panic>
      b->dev = dev;
    80002f7a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f7e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f82:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f86:	4785                	li	a5,1
    80002f88:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002f8a:	00013517          	auipc	a0,0x13
    80002f8e:	b5650513          	addi	a0,a0,-1194 # 80015ae0 <bcache>
    80002f92:	ffffe097          	auipc	ra,0xffffe
    80002f96:	bde080e7          	jalr	-1058(ra) # 80000b70 <release>
      acquiresleep(&b->lock);
    80002f9a:	01048513          	addi	a0,s1,16
    80002f9e:	00001097          	auipc	ra,0x1
    80002fa2:	4ec080e7          	jalr	1260(ra) # 8000448a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002fa6:	409c                	lw	a5,0(s1)
    80002fa8:	cb89                	beqz	a5,80002fba <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80002faa:	8526                	mv	a0,s1
    80002fac:	70a2                	ld	ra,40(sp)
    80002fae:	7402                	ld	s0,32(sp)
    80002fb0:	64e2                	ld	s1,24(sp)
    80002fb2:	6942                	ld	s2,16(sp)
    80002fb4:	69a2                	ld	s3,8(sp)
    80002fb6:	6145                	addi	sp,sp,48
    80002fb8:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    80002fba:	4601                	li	a2,0
    80002fbc:	85a6                	mv	a1,s1
    80002fbe:	4488                	lw	a0,8(s1)
    80002fc0:	00003097          	auipc	ra,0x3
    80002fc4:	10a080e7          	jalr	266(ra) # 800060ca <virtio_disk_rw>
    b->valid = 1;
    80002fc8:	4785                	li	a5,1
    80002fca:	c09c                	sw	a5,0(s1)
  return b;
    80002fcc:	bff9                	j	80002faa <bread+0xd0>

0000000080002fce <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fce:	1101                	addi	sp,sp,-32
    80002fd0:	ec06                	sd	ra,24(sp)
    80002fd2:	e822                	sd	s0,16(sp)
    80002fd4:	e426                	sd	s1,8(sp)
    80002fd6:	1000                	addi	s0,sp,32
    80002fd8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fda:	0541                	addi	a0,a0,16
    80002fdc:	00001097          	auipc	ra,0x1
    80002fe0:	548080e7          	jalr	1352(ra) # 80004524 <holdingsleep>
    80002fe4:	cd09                	beqz	a0,80002ffe <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80002fe6:	4605                	li	a2,1
    80002fe8:	85a6                	mv	a1,s1
    80002fea:	4488                	lw	a0,8(s1)
    80002fec:	00003097          	auipc	ra,0x3
    80002ff0:	0de080e7          	jalr	222(ra) # 800060ca <virtio_disk_rw>
}
    80002ff4:	60e2                	ld	ra,24(sp)
    80002ff6:	6442                	ld	s0,16(sp)
    80002ff8:	64a2                	ld	s1,8(sp)
    80002ffa:	6105                	addi	sp,sp,32
    80002ffc:	8082                	ret
    panic("bwrite");
    80002ffe:	00006517          	auipc	a0,0x6
    80003002:	8a250513          	addi	a0,a0,-1886 # 800088a0 <userret+0x810>
    80003006:	ffffd097          	auipc	ra,0xffffd
    8000300a:	54e080e7          	jalr	1358(ra) # 80000554 <panic>

000000008000300e <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    8000300e:	1101                	addi	sp,sp,-32
    80003010:	ec06                	sd	ra,24(sp)
    80003012:	e822                	sd	s0,16(sp)
    80003014:	e426                	sd	s1,8(sp)
    80003016:	e04a                	sd	s2,0(sp)
    80003018:	1000                	addi	s0,sp,32
    8000301a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000301c:	01050913          	addi	s2,a0,16
    80003020:	854a                	mv	a0,s2
    80003022:	00001097          	auipc	ra,0x1
    80003026:	502080e7          	jalr	1282(ra) # 80004524 <holdingsleep>
    8000302a:	c92d                	beqz	a0,8000309c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000302c:	854a                	mv	a0,s2
    8000302e:	00001097          	auipc	ra,0x1
    80003032:	4b2080e7          	jalr	1202(ra) # 800044e0 <releasesleep>

  acquire(&bcache.lock);
    80003036:	00013517          	auipc	a0,0x13
    8000303a:	aaa50513          	addi	a0,a0,-1366 # 80015ae0 <bcache>
    8000303e:	ffffe097          	auipc	ra,0xffffe
    80003042:	a62080e7          	jalr	-1438(ra) # 80000aa0 <acquire>
  b->refcnt--;
    80003046:	44bc                	lw	a5,72(s1)
    80003048:	37fd                	addiw	a5,a5,-1
    8000304a:	0007871b          	sext.w	a4,a5
    8000304e:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    80003050:	eb05                	bnez	a4,80003080 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003052:	6cbc                	ld	a5,88(s1)
    80003054:	68b8                	ld	a4,80(s1)
    80003056:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    80003058:	68bc                	ld	a5,80(s1)
    8000305a:	6cb8                	ld	a4,88(s1)
    8000305c:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    8000305e:	0001b797          	auipc	a5,0x1b
    80003062:	a8278793          	addi	a5,a5,-1406 # 8001dae0 <bcache+0x8000>
    80003066:	3b87b703          	ld	a4,952(a5)
    8000306a:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    8000306c:	0001b717          	auipc	a4,0x1b
    80003070:	dd470713          	addi	a4,a4,-556 # 8001de40 <bcache+0x8360>
    80003074:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    80003076:	3b87b703          	ld	a4,952(a5)
    8000307a:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    8000307c:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    80003080:	00013517          	auipc	a0,0x13
    80003084:	a6050513          	addi	a0,a0,-1440 # 80015ae0 <bcache>
    80003088:	ffffe097          	auipc	ra,0xffffe
    8000308c:	ae8080e7          	jalr	-1304(ra) # 80000b70 <release>
}
    80003090:	60e2                	ld	ra,24(sp)
    80003092:	6442                	ld	s0,16(sp)
    80003094:	64a2                	ld	s1,8(sp)
    80003096:	6902                	ld	s2,0(sp)
    80003098:	6105                	addi	sp,sp,32
    8000309a:	8082                	ret
    panic("brelse");
    8000309c:	00006517          	auipc	a0,0x6
    800030a0:	80c50513          	addi	a0,a0,-2036 # 800088a8 <userret+0x818>
    800030a4:	ffffd097          	auipc	ra,0xffffd
    800030a8:	4b0080e7          	jalr	1200(ra) # 80000554 <panic>

00000000800030ac <bpin>:

void
bpin(struct buf *b) {
    800030ac:	1101                	addi	sp,sp,-32
    800030ae:	ec06                	sd	ra,24(sp)
    800030b0:	e822                	sd	s0,16(sp)
    800030b2:	e426                	sd	s1,8(sp)
    800030b4:	1000                	addi	s0,sp,32
    800030b6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030b8:	00013517          	auipc	a0,0x13
    800030bc:	a2850513          	addi	a0,a0,-1496 # 80015ae0 <bcache>
    800030c0:	ffffe097          	auipc	ra,0xffffe
    800030c4:	9e0080e7          	jalr	-1568(ra) # 80000aa0 <acquire>
  b->refcnt++;
    800030c8:	44bc                	lw	a5,72(s1)
    800030ca:	2785                	addiw	a5,a5,1
    800030cc:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    800030ce:	00013517          	auipc	a0,0x13
    800030d2:	a1250513          	addi	a0,a0,-1518 # 80015ae0 <bcache>
    800030d6:	ffffe097          	auipc	ra,0xffffe
    800030da:	a9a080e7          	jalr	-1382(ra) # 80000b70 <release>
}
    800030de:	60e2                	ld	ra,24(sp)
    800030e0:	6442                	ld	s0,16(sp)
    800030e2:	64a2                	ld	s1,8(sp)
    800030e4:	6105                	addi	sp,sp,32
    800030e6:	8082                	ret

00000000800030e8 <bunpin>:

void
bunpin(struct buf *b) {
    800030e8:	1101                	addi	sp,sp,-32
    800030ea:	ec06                	sd	ra,24(sp)
    800030ec:	e822                	sd	s0,16(sp)
    800030ee:	e426                	sd	s1,8(sp)
    800030f0:	1000                	addi	s0,sp,32
    800030f2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030f4:	00013517          	auipc	a0,0x13
    800030f8:	9ec50513          	addi	a0,a0,-1556 # 80015ae0 <bcache>
    800030fc:	ffffe097          	auipc	ra,0xffffe
    80003100:	9a4080e7          	jalr	-1628(ra) # 80000aa0 <acquire>
  b->refcnt--;
    80003104:	44bc                	lw	a5,72(s1)
    80003106:	37fd                	addiw	a5,a5,-1
    80003108:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    8000310a:	00013517          	auipc	a0,0x13
    8000310e:	9d650513          	addi	a0,a0,-1578 # 80015ae0 <bcache>
    80003112:	ffffe097          	auipc	ra,0xffffe
    80003116:	a5e080e7          	jalr	-1442(ra) # 80000b70 <release>
}
    8000311a:	60e2                	ld	ra,24(sp)
    8000311c:	6442                	ld	s0,16(sp)
    8000311e:	64a2                	ld	s1,8(sp)
    80003120:	6105                	addi	sp,sp,32
    80003122:	8082                	ret

0000000080003124 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003124:	1101                	addi	sp,sp,-32
    80003126:	ec06                	sd	ra,24(sp)
    80003128:	e822                	sd	s0,16(sp)
    8000312a:	e426                	sd	s1,8(sp)
    8000312c:	e04a                	sd	s2,0(sp)
    8000312e:	1000                	addi	s0,sp,32
    80003130:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003132:	00d5d59b          	srliw	a1,a1,0xd
    80003136:	0001b797          	auipc	a5,0x1b
    8000313a:	1867a783          	lw	a5,390(a5) # 8001e2bc <sb+0x1c>
    8000313e:	9dbd                	addw	a1,a1,a5
    80003140:	00000097          	auipc	ra,0x0
    80003144:	d9a080e7          	jalr	-614(ra) # 80002eda <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003148:	0074f713          	andi	a4,s1,7
    8000314c:	4785                	li	a5,1
    8000314e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003152:	14ce                	slli	s1,s1,0x33
    80003154:	90d9                	srli	s1,s1,0x36
    80003156:	00950733          	add	a4,a0,s1
    8000315a:	06074703          	lbu	a4,96(a4)
    8000315e:	00e7f6b3          	and	a3,a5,a4
    80003162:	c69d                	beqz	a3,80003190 <bfree+0x6c>
    80003164:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003166:	94aa                	add	s1,s1,a0
    80003168:	fff7c793          	not	a5,a5
    8000316c:	8ff9                	and	a5,a5,a4
    8000316e:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80003172:	00001097          	auipc	ra,0x1
    80003176:	19e080e7          	jalr	414(ra) # 80004310 <log_write>
  brelse(bp);
    8000317a:	854a                	mv	a0,s2
    8000317c:	00000097          	auipc	ra,0x0
    80003180:	e92080e7          	jalr	-366(ra) # 8000300e <brelse>
}
    80003184:	60e2                	ld	ra,24(sp)
    80003186:	6442                	ld	s0,16(sp)
    80003188:	64a2                	ld	s1,8(sp)
    8000318a:	6902                	ld	s2,0(sp)
    8000318c:	6105                	addi	sp,sp,32
    8000318e:	8082                	ret
    panic("freeing free block");
    80003190:	00005517          	auipc	a0,0x5
    80003194:	72050513          	addi	a0,a0,1824 # 800088b0 <userret+0x820>
    80003198:	ffffd097          	auipc	ra,0xffffd
    8000319c:	3bc080e7          	jalr	956(ra) # 80000554 <panic>

00000000800031a0 <balloc>:
{
    800031a0:	711d                	addi	sp,sp,-96
    800031a2:	ec86                	sd	ra,88(sp)
    800031a4:	e8a2                	sd	s0,80(sp)
    800031a6:	e4a6                	sd	s1,72(sp)
    800031a8:	e0ca                	sd	s2,64(sp)
    800031aa:	fc4e                	sd	s3,56(sp)
    800031ac:	f852                	sd	s4,48(sp)
    800031ae:	f456                	sd	s5,40(sp)
    800031b0:	f05a                	sd	s6,32(sp)
    800031b2:	ec5e                	sd	s7,24(sp)
    800031b4:	e862                	sd	s8,16(sp)
    800031b6:	e466                	sd	s9,8(sp)
    800031b8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031ba:	0001b797          	auipc	a5,0x1b
    800031be:	0ea7a783          	lw	a5,234(a5) # 8001e2a4 <sb+0x4>
    800031c2:	cbd1                	beqz	a5,80003256 <balloc+0xb6>
    800031c4:	8baa                	mv	s7,a0
    800031c6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031c8:	0001bb17          	auipc	s6,0x1b
    800031cc:	0d8b0b13          	addi	s6,s6,216 # 8001e2a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031d0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031d2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031d4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031d6:	6c89                	lui	s9,0x2
    800031d8:	a831                	j	800031f4 <balloc+0x54>
    brelse(bp);
    800031da:	854a                	mv	a0,s2
    800031dc:	00000097          	auipc	ra,0x0
    800031e0:	e32080e7          	jalr	-462(ra) # 8000300e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031e4:	015c87bb          	addw	a5,s9,s5
    800031e8:	00078a9b          	sext.w	s5,a5
    800031ec:	004b2703          	lw	a4,4(s6)
    800031f0:	06eaf363          	bgeu	s5,a4,80003256 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800031f4:	41fad79b          	sraiw	a5,s5,0x1f
    800031f8:	0137d79b          	srliw	a5,a5,0x13
    800031fc:	015787bb          	addw	a5,a5,s5
    80003200:	40d7d79b          	sraiw	a5,a5,0xd
    80003204:	01cb2583          	lw	a1,28(s6)
    80003208:	9dbd                	addw	a1,a1,a5
    8000320a:	855e                	mv	a0,s7
    8000320c:	00000097          	auipc	ra,0x0
    80003210:	cce080e7          	jalr	-818(ra) # 80002eda <bread>
    80003214:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003216:	004b2503          	lw	a0,4(s6)
    8000321a:	000a849b          	sext.w	s1,s5
    8000321e:	8662                	mv	a2,s8
    80003220:	faa4fde3          	bgeu	s1,a0,800031da <balloc+0x3a>
      m = 1 << (bi % 8);
    80003224:	41f6579b          	sraiw	a5,a2,0x1f
    80003228:	01d7d69b          	srliw	a3,a5,0x1d
    8000322c:	00c6873b          	addw	a4,a3,a2
    80003230:	00777793          	andi	a5,a4,7
    80003234:	9f95                	subw	a5,a5,a3
    80003236:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000323a:	4037571b          	sraiw	a4,a4,0x3
    8000323e:	00e906b3          	add	a3,s2,a4
    80003242:	0606c683          	lbu	a3,96(a3)
    80003246:	00d7f5b3          	and	a1,a5,a3
    8000324a:	cd91                	beqz	a1,80003266 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000324c:	2605                	addiw	a2,a2,1
    8000324e:	2485                	addiw	s1,s1,1
    80003250:	fd4618e3          	bne	a2,s4,80003220 <balloc+0x80>
    80003254:	b759                	j	800031da <balloc+0x3a>
  panic("balloc: out of blocks");
    80003256:	00005517          	auipc	a0,0x5
    8000325a:	67250513          	addi	a0,a0,1650 # 800088c8 <userret+0x838>
    8000325e:	ffffd097          	auipc	ra,0xffffd
    80003262:	2f6080e7          	jalr	758(ra) # 80000554 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003266:	974a                	add	a4,a4,s2
    80003268:	8fd5                	or	a5,a5,a3
    8000326a:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    8000326e:	854a                	mv	a0,s2
    80003270:	00001097          	auipc	ra,0x1
    80003274:	0a0080e7          	jalr	160(ra) # 80004310 <log_write>
        brelse(bp);
    80003278:	854a                	mv	a0,s2
    8000327a:	00000097          	auipc	ra,0x0
    8000327e:	d94080e7          	jalr	-620(ra) # 8000300e <brelse>
  bp = bread(dev, bno);
    80003282:	85a6                	mv	a1,s1
    80003284:	855e                	mv	a0,s7
    80003286:	00000097          	auipc	ra,0x0
    8000328a:	c54080e7          	jalr	-940(ra) # 80002eda <bread>
    8000328e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003290:	40000613          	li	a2,1024
    80003294:	4581                	li	a1,0
    80003296:	06050513          	addi	a0,a0,96
    8000329a:	ffffe097          	auipc	ra,0xffffe
    8000329e:	ad4080e7          	jalr	-1324(ra) # 80000d6e <memset>
  log_write(bp);
    800032a2:	854a                	mv	a0,s2
    800032a4:	00001097          	auipc	ra,0x1
    800032a8:	06c080e7          	jalr	108(ra) # 80004310 <log_write>
  brelse(bp);
    800032ac:	854a                	mv	a0,s2
    800032ae:	00000097          	auipc	ra,0x0
    800032b2:	d60080e7          	jalr	-672(ra) # 8000300e <brelse>
}
    800032b6:	8526                	mv	a0,s1
    800032b8:	60e6                	ld	ra,88(sp)
    800032ba:	6446                	ld	s0,80(sp)
    800032bc:	64a6                	ld	s1,72(sp)
    800032be:	6906                	ld	s2,64(sp)
    800032c0:	79e2                	ld	s3,56(sp)
    800032c2:	7a42                	ld	s4,48(sp)
    800032c4:	7aa2                	ld	s5,40(sp)
    800032c6:	7b02                	ld	s6,32(sp)
    800032c8:	6be2                	ld	s7,24(sp)
    800032ca:	6c42                	ld	s8,16(sp)
    800032cc:	6ca2                	ld	s9,8(sp)
    800032ce:	6125                	addi	sp,sp,96
    800032d0:	8082                	ret

00000000800032d2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800032d2:	7179                	addi	sp,sp,-48
    800032d4:	f406                	sd	ra,40(sp)
    800032d6:	f022                	sd	s0,32(sp)
    800032d8:	ec26                	sd	s1,24(sp)
    800032da:	e84a                	sd	s2,16(sp)
    800032dc:	e44e                	sd	s3,8(sp)
    800032de:	e052                	sd	s4,0(sp)
    800032e0:	1800                	addi	s0,sp,48
    800032e2:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032e4:	47ad                	li	a5,11
    800032e6:	04b7fe63          	bgeu	a5,a1,80003342 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800032ea:	ff45849b          	addiw	s1,a1,-12
    800032ee:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032f2:	0ff00793          	li	a5,255
    800032f6:	0ae7e363          	bltu	a5,a4,8000339c <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800032fa:	08852583          	lw	a1,136(a0)
    800032fe:	c5ad                	beqz	a1,80003368 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003300:	00092503          	lw	a0,0(s2)
    80003304:	00000097          	auipc	ra,0x0
    80003308:	bd6080e7          	jalr	-1066(ra) # 80002eda <bread>
    8000330c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000330e:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003312:	02049593          	slli	a1,s1,0x20
    80003316:	9181                	srli	a1,a1,0x20
    80003318:	058a                	slli	a1,a1,0x2
    8000331a:	00b784b3          	add	s1,a5,a1
    8000331e:	0004a983          	lw	s3,0(s1)
    80003322:	04098d63          	beqz	s3,8000337c <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003326:	8552                	mv	a0,s4
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	ce6080e7          	jalr	-794(ra) # 8000300e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003330:	854e                	mv	a0,s3
    80003332:	70a2                	ld	ra,40(sp)
    80003334:	7402                	ld	s0,32(sp)
    80003336:	64e2                	ld	s1,24(sp)
    80003338:	6942                	ld	s2,16(sp)
    8000333a:	69a2                	ld	s3,8(sp)
    8000333c:	6a02                	ld	s4,0(sp)
    8000333e:	6145                	addi	sp,sp,48
    80003340:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003342:	02059493          	slli	s1,a1,0x20
    80003346:	9081                	srli	s1,s1,0x20
    80003348:	048a                	slli	s1,s1,0x2
    8000334a:	94aa                	add	s1,s1,a0
    8000334c:	0584a983          	lw	s3,88(s1)
    80003350:	fe0990e3          	bnez	s3,80003330 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003354:	4108                	lw	a0,0(a0)
    80003356:	00000097          	auipc	ra,0x0
    8000335a:	e4a080e7          	jalr	-438(ra) # 800031a0 <balloc>
    8000335e:	0005099b          	sext.w	s3,a0
    80003362:	0534ac23          	sw	s3,88(s1)
    80003366:	b7e9                	j	80003330 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003368:	4108                	lw	a0,0(a0)
    8000336a:	00000097          	auipc	ra,0x0
    8000336e:	e36080e7          	jalr	-458(ra) # 800031a0 <balloc>
    80003372:	0005059b          	sext.w	a1,a0
    80003376:	08b92423          	sw	a1,136(s2)
    8000337a:	b759                	j	80003300 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000337c:	00092503          	lw	a0,0(s2)
    80003380:	00000097          	auipc	ra,0x0
    80003384:	e20080e7          	jalr	-480(ra) # 800031a0 <balloc>
    80003388:	0005099b          	sext.w	s3,a0
    8000338c:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003390:	8552                	mv	a0,s4
    80003392:	00001097          	auipc	ra,0x1
    80003396:	f7e080e7          	jalr	-130(ra) # 80004310 <log_write>
    8000339a:	b771                	j	80003326 <bmap+0x54>
  panic("bmap: out of range");
    8000339c:	00005517          	auipc	a0,0x5
    800033a0:	54450513          	addi	a0,a0,1348 # 800088e0 <userret+0x850>
    800033a4:	ffffd097          	auipc	ra,0xffffd
    800033a8:	1b0080e7          	jalr	432(ra) # 80000554 <panic>

00000000800033ac <iget>:
{
    800033ac:	7179                	addi	sp,sp,-48
    800033ae:	f406                	sd	ra,40(sp)
    800033b0:	f022                	sd	s0,32(sp)
    800033b2:	ec26                	sd	s1,24(sp)
    800033b4:	e84a                	sd	s2,16(sp)
    800033b6:	e44e                	sd	s3,8(sp)
    800033b8:	e052                	sd	s4,0(sp)
    800033ba:	1800                	addi	s0,sp,48
    800033bc:	89aa                	mv	s3,a0
    800033be:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800033c0:	0001b517          	auipc	a0,0x1b
    800033c4:	f0050513          	addi	a0,a0,-256 # 8001e2c0 <icache>
    800033c8:	ffffd097          	auipc	ra,0xffffd
    800033cc:	6d8080e7          	jalr	1752(ra) # 80000aa0 <acquire>
  empty = 0;
    800033d0:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800033d2:	0001b497          	auipc	s1,0x1b
    800033d6:	f0e48493          	addi	s1,s1,-242 # 8001e2e0 <icache+0x20>
    800033da:	0001d697          	auipc	a3,0x1d
    800033de:	b2668693          	addi	a3,a3,-1242 # 8001ff00 <log>
    800033e2:	a039                	j	800033f0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033e4:	02090b63          	beqz	s2,8000341a <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800033e8:	09048493          	addi	s1,s1,144
    800033ec:	02d48a63          	beq	s1,a3,80003420 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033f0:	449c                	lw	a5,8(s1)
    800033f2:	fef059e3          	blez	a5,800033e4 <iget+0x38>
    800033f6:	4098                	lw	a4,0(s1)
    800033f8:	ff3716e3          	bne	a4,s3,800033e4 <iget+0x38>
    800033fc:	40d8                	lw	a4,4(s1)
    800033fe:	ff4713e3          	bne	a4,s4,800033e4 <iget+0x38>
      ip->ref++;
    80003402:	2785                	addiw	a5,a5,1
    80003404:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003406:	0001b517          	auipc	a0,0x1b
    8000340a:	eba50513          	addi	a0,a0,-326 # 8001e2c0 <icache>
    8000340e:	ffffd097          	auipc	ra,0xffffd
    80003412:	762080e7          	jalr	1890(ra) # 80000b70 <release>
      return ip;
    80003416:	8926                	mv	s2,s1
    80003418:	a03d                	j	80003446 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000341a:	f7f9                	bnez	a5,800033e8 <iget+0x3c>
    8000341c:	8926                	mv	s2,s1
    8000341e:	b7e9                	j	800033e8 <iget+0x3c>
  if(empty == 0)
    80003420:	02090c63          	beqz	s2,80003458 <iget+0xac>
  ip->dev = dev;
    80003424:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003428:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000342c:	4785                	li	a5,1
    8000342e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003432:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    80003436:	0001b517          	auipc	a0,0x1b
    8000343a:	e8a50513          	addi	a0,a0,-374 # 8001e2c0 <icache>
    8000343e:	ffffd097          	auipc	ra,0xffffd
    80003442:	732080e7          	jalr	1842(ra) # 80000b70 <release>
}
    80003446:	854a                	mv	a0,s2
    80003448:	70a2                	ld	ra,40(sp)
    8000344a:	7402                	ld	s0,32(sp)
    8000344c:	64e2                	ld	s1,24(sp)
    8000344e:	6942                	ld	s2,16(sp)
    80003450:	69a2                	ld	s3,8(sp)
    80003452:	6a02                	ld	s4,0(sp)
    80003454:	6145                	addi	sp,sp,48
    80003456:	8082                	ret
    panic("iget: no inodes");
    80003458:	00005517          	auipc	a0,0x5
    8000345c:	4a050513          	addi	a0,a0,1184 # 800088f8 <userret+0x868>
    80003460:	ffffd097          	auipc	ra,0xffffd
    80003464:	0f4080e7          	jalr	244(ra) # 80000554 <panic>

0000000080003468 <fsinit>:
fsinit(int dev) {
    80003468:	7179                	addi	sp,sp,-48
    8000346a:	f406                	sd	ra,40(sp)
    8000346c:	f022                	sd	s0,32(sp)
    8000346e:	ec26                	sd	s1,24(sp)
    80003470:	e84a                	sd	s2,16(sp)
    80003472:	e44e                	sd	s3,8(sp)
    80003474:	1800                	addi	s0,sp,48
    80003476:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003478:	4585                	li	a1,1
    8000347a:	00000097          	auipc	ra,0x0
    8000347e:	a60080e7          	jalr	-1440(ra) # 80002eda <bread>
    80003482:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003484:	0001b997          	auipc	s3,0x1b
    80003488:	e1c98993          	addi	s3,s3,-484 # 8001e2a0 <sb>
    8000348c:	02000613          	li	a2,32
    80003490:	06050593          	addi	a1,a0,96
    80003494:	854e                	mv	a0,s3
    80003496:	ffffe097          	auipc	ra,0xffffe
    8000349a:	934080e7          	jalr	-1740(ra) # 80000dca <memmove>
  brelse(bp);
    8000349e:	8526                	mv	a0,s1
    800034a0:	00000097          	auipc	ra,0x0
    800034a4:	b6e080e7          	jalr	-1170(ra) # 8000300e <brelse>
  if(sb.magic != FSMAGIC)
    800034a8:	0009a703          	lw	a4,0(s3)
    800034ac:	102037b7          	lui	a5,0x10203
    800034b0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034b4:	02f71263          	bne	a4,a5,800034d8 <fsinit+0x70>
  initlog(dev, &sb);
    800034b8:	0001b597          	auipc	a1,0x1b
    800034bc:	de858593          	addi	a1,a1,-536 # 8001e2a0 <sb>
    800034c0:	854a                	mv	a0,s2
    800034c2:	00001097          	auipc	ra,0x1
    800034c6:	b38080e7          	jalr	-1224(ra) # 80003ffa <initlog>
}
    800034ca:	70a2                	ld	ra,40(sp)
    800034cc:	7402                	ld	s0,32(sp)
    800034ce:	64e2                	ld	s1,24(sp)
    800034d0:	6942                	ld	s2,16(sp)
    800034d2:	69a2                	ld	s3,8(sp)
    800034d4:	6145                	addi	sp,sp,48
    800034d6:	8082                	ret
    panic("invalid file system");
    800034d8:	00005517          	auipc	a0,0x5
    800034dc:	43050513          	addi	a0,a0,1072 # 80008908 <userret+0x878>
    800034e0:	ffffd097          	auipc	ra,0xffffd
    800034e4:	074080e7          	jalr	116(ra) # 80000554 <panic>

00000000800034e8 <iinit>:
{
    800034e8:	7179                	addi	sp,sp,-48
    800034ea:	f406                	sd	ra,40(sp)
    800034ec:	f022                	sd	s0,32(sp)
    800034ee:	ec26                	sd	s1,24(sp)
    800034f0:	e84a                	sd	s2,16(sp)
    800034f2:	e44e                	sd	s3,8(sp)
    800034f4:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800034f6:	00005597          	auipc	a1,0x5
    800034fa:	42a58593          	addi	a1,a1,1066 # 80008920 <userret+0x890>
    800034fe:	0001b517          	auipc	a0,0x1b
    80003502:	dc250513          	addi	a0,a0,-574 # 8001e2c0 <icache>
    80003506:	ffffd097          	auipc	ra,0xffffd
    8000350a:	4c6080e7          	jalr	1222(ra) # 800009cc <initlock>
  for(i = 0; i < NINODE; i++) {
    8000350e:	0001b497          	auipc	s1,0x1b
    80003512:	de248493          	addi	s1,s1,-542 # 8001e2f0 <icache+0x30>
    80003516:	0001d997          	auipc	s3,0x1d
    8000351a:	9fa98993          	addi	s3,s3,-1542 # 8001ff10 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000351e:	00005917          	auipc	s2,0x5
    80003522:	40a90913          	addi	s2,s2,1034 # 80008928 <userret+0x898>
    80003526:	85ca                	mv	a1,s2
    80003528:	8526                	mv	a0,s1
    8000352a:	00001097          	auipc	ra,0x1
    8000352e:	f26080e7          	jalr	-218(ra) # 80004450 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003532:	09048493          	addi	s1,s1,144
    80003536:	ff3498e3          	bne	s1,s3,80003526 <iinit+0x3e>
}
    8000353a:	70a2                	ld	ra,40(sp)
    8000353c:	7402                	ld	s0,32(sp)
    8000353e:	64e2                	ld	s1,24(sp)
    80003540:	6942                	ld	s2,16(sp)
    80003542:	69a2                	ld	s3,8(sp)
    80003544:	6145                	addi	sp,sp,48
    80003546:	8082                	ret

0000000080003548 <ialloc>:
{
    80003548:	715d                	addi	sp,sp,-80
    8000354a:	e486                	sd	ra,72(sp)
    8000354c:	e0a2                	sd	s0,64(sp)
    8000354e:	fc26                	sd	s1,56(sp)
    80003550:	f84a                	sd	s2,48(sp)
    80003552:	f44e                	sd	s3,40(sp)
    80003554:	f052                	sd	s4,32(sp)
    80003556:	ec56                	sd	s5,24(sp)
    80003558:	e85a                	sd	s6,16(sp)
    8000355a:	e45e                	sd	s7,8(sp)
    8000355c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000355e:	0001b717          	auipc	a4,0x1b
    80003562:	d4e72703          	lw	a4,-690(a4) # 8001e2ac <sb+0xc>
    80003566:	4785                	li	a5,1
    80003568:	04e7fa63          	bgeu	a5,a4,800035bc <ialloc+0x74>
    8000356c:	8aaa                	mv	s5,a0
    8000356e:	8bae                	mv	s7,a1
    80003570:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003572:	0001ba17          	auipc	s4,0x1b
    80003576:	d2ea0a13          	addi	s4,s4,-722 # 8001e2a0 <sb>
    8000357a:	00048b1b          	sext.w	s6,s1
    8000357e:	0044d793          	srli	a5,s1,0x4
    80003582:	018a2583          	lw	a1,24(s4)
    80003586:	9dbd                	addw	a1,a1,a5
    80003588:	8556                	mv	a0,s5
    8000358a:	00000097          	auipc	ra,0x0
    8000358e:	950080e7          	jalr	-1712(ra) # 80002eda <bread>
    80003592:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003594:	06050993          	addi	s3,a0,96
    80003598:	00f4f793          	andi	a5,s1,15
    8000359c:	079a                	slli	a5,a5,0x6
    8000359e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035a0:	00099783          	lh	a5,0(s3)
    800035a4:	c785                	beqz	a5,800035cc <ialloc+0x84>
    brelse(bp);
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	a68080e7          	jalr	-1432(ra) # 8000300e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035ae:	0485                	addi	s1,s1,1
    800035b0:	00ca2703          	lw	a4,12(s4)
    800035b4:	0004879b          	sext.w	a5,s1
    800035b8:	fce7e1e3          	bltu	a5,a4,8000357a <ialloc+0x32>
  panic("ialloc: no inodes");
    800035bc:	00005517          	auipc	a0,0x5
    800035c0:	37450513          	addi	a0,a0,884 # 80008930 <userret+0x8a0>
    800035c4:	ffffd097          	auipc	ra,0xffffd
    800035c8:	f90080e7          	jalr	-112(ra) # 80000554 <panic>
      memset(dip, 0, sizeof(*dip));
    800035cc:	04000613          	li	a2,64
    800035d0:	4581                	li	a1,0
    800035d2:	854e                	mv	a0,s3
    800035d4:	ffffd097          	auipc	ra,0xffffd
    800035d8:	79a080e7          	jalr	1946(ra) # 80000d6e <memset>
      dip->type = type;
    800035dc:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035e0:	854a                	mv	a0,s2
    800035e2:	00001097          	auipc	ra,0x1
    800035e6:	d2e080e7          	jalr	-722(ra) # 80004310 <log_write>
      brelse(bp);
    800035ea:	854a                	mv	a0,s2
    800035ec:	00000097          	auipc	ra,0x0
    800035f0:	a22080e7          	jalr	-1502(ra) # 8000300e <brelse>
      return iget(dev, inum);
    800035f4:	85da                	mv	a1,s6
    800035f6:	8556                	mv	a0,s5
    800035f8:	00000097          	auipc	ra,0x0
    800035fc:	db4080e7          	jalr	-588(ra) # 800033ac <iget>
}
    80003600:	60a6                	ld	ra,72(sp)
    80003602:	6406                	ld	s0,64(sp)
    80003604:	74e2                	ld	s1,56(sp)
    80003606:	7942                	ld	s2,48(sp)
    80003608:	79a2                	ld	s3,40(sp)
    8000360a:	7a02                	ld	s4,32(sp)
    8000360c:	6ae2                	ld	s5,24(sp)
    8000360e:	6b42                	ld	s6,16(sp)
    80003610:	6ba2                	ld	s7,8(sp)
    80003612:	6161                	addi	sp,sp,80
    80003614:	8082                	ret

0000000080003616 <iupdate>:
{
    80003616:	1101                	addi	sp,sp,-32
    80003618:	ec06                	sd	ra,24(sp)
    8000361a:	e822                	sd	s0,16(sp)
    8000361c:	e426                	sd	s1,8(sp)
    8000361e:	e04a                	sd	s2,0(sp)
    80003620:	1000                	addi	s0,sp,32
    80003622:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003624:	415c                	lw	a5,4(a0)
    80003626:	0047d79b          	srliw	a5,a5,0x4
    8000362a:	0001b597          	auipc	a1,0x1b
    8000362e:	c8e5a583          	lw	a1,-882(a1) # 8001e2b8 <sb+0x18>
    80003632:	9dbd                	addw	a1,a1,a5
    80003634:	4108                	lw	a0,0(a0)
    80003636:	00000097          	auipc	ra,0x0
    8000363a:	8a4080e7          	jalr	-1884(ra) # 80002eda <bread>
    8000363e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003640:	06050793          	addi	a5,a0,96
    80003644:	40c8                	lw	a0,4(s1)
    80003646:	893d                	andi	a0,a0,15
    80003648:	051a                	slli	a0,a0,0x6
    8000364a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000364c:	04c49703          	lh	a4,76(s1)
    80003650:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003654:	04e49703          	lh	a4,78(s1)
    80003658:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000365c:	05049703          	lh	a4,80(s1)
    80003660:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003664:	05249703          	lh	a4,82(s1)
    80003668:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000366c:	48f8                	lw	a4,84(s1)
    8000366e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003670:	03400613          	li	a2,52
    80003674:	05848593          	addi	a1,s1,88
    80003678:	0531                	addi	a0,a0,12
    8000367a:	ffffd097          	auipc	ra,0xffffd
    8000367e:	750080e7          	jalr	1872(ra) # 80000dca <memmove>
  log_write(bp);
    80003682:	854a                	mv	a0,s2
    80003684:	00001097          	auipc	ra,0x1
    80003688:	c8c080e7          	jalr	-884(ra) # 80004310 <log_write>
  brelse(bp);
    8000368c:	854a                	mv	a0,s2
    8000368e:	00000097          	auipc	ra,0x0
    80003692:	980080e7          	jalr	-1664(ra) # 8000300e <brelse>
}
    80003696:	60e2                	ld	ra,24(sp)
    80003698:	6442                	ld	s0,16(sp)
    8000369a:	64a2                	ld	s1,8(sp)
    8000369c:	6902                	ld	s2,0(sp)
    8000369e:	6105                	addi	sp,sp,32
    800036a0:	8082                	ret

00000000800036a2 <idup>:
{
    800036a2:	1101                	addi	sp,sp,-32
    800036a4:	ec06                	sd	ra,24(sp)
    800036a6:	e822                	sd	s0,16(sp)
    800036a8:	e426                	sd	s1,8(sp)
    800036aa:	1000                	addi	s0,sp,32
    800036ac:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800036ae:	0001b517          	auipc	a0,0x1b
    800036b2:	c1250513          	addi	a0,a0,-1006 # 8001e2c0 <icache>
    800036b6:	ffffd097          	auipc	ra,0xffffd
    800036ba:	3ea080e7          	jalr	1002(ra) # 80000aa0 <acquire>
  ip->ref++;
    800036be:	449c                	lw	a5,8(s1)
    800036c0:	2785                	addiw	a5,a5,1
    800036c2:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800036c4:	0001b517          	auipc	a0,0x1b
    800036c8:	bfc50513          	addi	a0,a0,-1028 # 8001e2c0 <icache>
    800036cc:	ffffd097          	auipc	ra,0xffffd
    800036d0:	4a4080e7          	jalr	1188(ra) # 80000b70 <release>
}
    800036d4:	8526                	mv	a0,s1
    800036d6:	60e2                	ld	ra,24(sp)
    800036d8:	6442                	ld	s0,16(sp)
    800036da:	64a2                	ld	s1,8(sp)
    800036dc:	6105                	addi	sp,sp,32
    800036de:	8082                	ret

00000000800036e0 <ilock>:
{
    800036e0:	1101                	addi	sp,sp,-32
    800036e2:	ec06                	sd	ra,24(sp)
    800036e4:	e822                	sd	s0,16(sp)
    800036e6:	e426                	sd	s1,8(sp)
    800036e8:	e04a                	sd	s2,0(sp)
    800036ea:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036ec:	c115                	beqz	a0,80003710 <ilock+0x30>
    800036ee:	84aa                	mv	s1,a0
    800036f0:	451c                	lw	a5,8(a0)
    800036f2:	00f05f63          	blez	a5,80003710 <ilock+0x30>
  acquiresleep(&ip->lock);
    800036f6:	0541                	addi	a0,a0,16
    800036f8:	00001097          	auipc	ra,0x1
    800036fc:	d92080e7          	jalr	-622(ra) # 8000448a <acquiresleep>
  if(ip->valid == 0){
    80003700:	44bc                	lw	a5,72(s1)
    80003702:	cf99                	beqz	a5,80003720 <ilock+0x40>
}
    80003704:	60e2                	ld	ra,24(sp)
    80003706:	6442                	ld	s0,16(sp)
    80003708:	64a2                	ld	s1,8(sp)
    8000370a:	6902                	ld	s2,0(sp)
    8000370c:	6105                	addi	sp,sp,32
    8000370e:	8082                	ret
    panic("ilock");
    80003710:	00005517          	auipc	a0,0x5
    80003714:	23850513          	addi	a0,a0,568 # 80008948 <userret+0x8b8>
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	e3c080e7          	jalr	-452(ra) # 80000554 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003720:	40dc                	lw	a5,4(s1)
    80003722:	0047d79b          	srliw	a5,a5,0x4
    80003726:	0001b597          	auipc	a1,0x1b
    8000372a:	b925a583          	lw	a1,-1134(a1) # 8001e2b8 <sb+0x18>
    8000372e:	9dbd                	addw	a1,a1,a5
    80003730:	4088                	lw	a0,0(s1)
    80003732:	fffff097          	auipc	ra,0xfffff
    80003736:	7a8080e7          	jalr	1960(ra) # 80002eda <bread>
    8000373a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000373c:	06050593          	addi	a1,a0,96
    80003740:	40dc                	lw	a5,4(s1)
    80003742:	8bbd                	andi	a5,a5,15
    80003744:	079a                	slli	a5,a5,0x6
    80003746:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003748:	00059783          	lh	a5,0(a1)
    8000374c:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003750:	00259783          	lh	a5,2(a1)
    80003754:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003758:	00459783          	lh	a5,4(a1)
    8000375c:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003760:	00659783          	lh	a5,6(a1)
    80003764:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003768:	459c                	lw	a5,8(a1)
    8000376a:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000376c:	03400613          	li	a2,52
    80003770:	05b1                	addi	a1,a1,12
    80003772:	05848513          	addi	a0,s1,88
    80003776:	ffffd097          	auipc	ra,0xffffd
    8000377a:	654080e7          	jalr	1620(ra) # 80000dca <memmove>
    brelse(bp);
    8000377e:	854a                	mv	a0,s2
    80003780:	00000097          	auipc	ra,0x0
    80003784:	88e080e7          	jalr	-1906(ra) # 8000300e <brelse>
    ip->valid = 1;
    80003788:	4785                	li	a5,1
    8000378a:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    8000378c:	04c49783          	lh	a5,76(s1)
    80003790:	fbb5                	bnez	a5,80003704 <ilock+0x24>
      panic("ilock: no type");
    80003792:	00005517          	auipc	a0,0x5
    80003796:	1be50513          	addi	a0,a0,446 # 80008950 <userret+0x8c0>
    8000379a:	ffffd097          	auipc	ra,0xffffd
    8000379e:	dba080e7          	jalr	-582(ra) # 80000554 <panic>

00000000800037a2 <iunlock>:
{
    800037a2:	1101                	addi	sp,sp,-32
    800037a4:	ec06                	sd	ra,24(sp)
    800037a6:	e822                	sd	s0,16(sp)
    800037a8:	e426                	sd	s1,8(sp)
    800037aa:	e04a                	sd	s2,0(sp)
    800037ac:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037ae:	c905                	beqz	a0,800037de <iunlock+0x3c>
    800037b0:	84aa                	mv	s1,a0
    800037b2:	01050913          	addi	s2,a0,16
    800037b6:	854a                	mv	a0,s2
    800037b8:	00001097          	auipc	ra,0x1
    800037bc:	d6c080e7          	jalr	-660(ra) # 80004524 <holdingsleep>
    800037c0:	cd19                	beqz	a0,800037de <iunlock+0x3c>
    800037c2:	449c                	lw	a5,8(s1)
    800037c4:	00f05d63          	blez	a5,800037de <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037c8:	854a                	mv	a0,s2
    800037ca:	00001097          	auipc	ra,0x1
    800037ce:	d16080e7          	jalr	-746(ra) # 800044e0 <releasesleep>
}
    800037d2:	60e2                	ld	ra,24(sp)
    800037d4:	6442                	ld	s0,16(sp)
    800037d6:	64a2                	ld	s1,8(sp)
    800037d8:	6902                	ld	s2,0(sp)
    800037da:	6105                	addi	sp,sp,32
    800037dc:	8082                	ret
    panic("iunlock");
    800037de:	00005517          	auipc	a0,0x5
    800037e2:	18250513          	addi	a0,a0,386 # 80008960 <userret+0x8d0>
    800037e6:	ffffd097          	auipc	ra,0xffffd
    800037ea:	d6e080e7          	jalr	-658(ra) # 80000554 <panic>

00000000800037ee <iput>:
{
    800037ee:	7139                	addi	sp,sp,-64
    800037f0:	fc06                	sd	ra,56(sp)
    800037f2:	f822                	sd	s0,48(sp)
    800037f4:	f426                	sd	s1,40(sp)
    800037f6:	f04a                	sd	s2,32(sp)
    800037f8:	ec4e                	sd	s3,24(sp)
    800037fa:	e852                	sd	s4,16(sp)
    800037fc:	e456                	sd	s5,8(sp)
    800037fe:	0080                	addi	s0,sp,64
    80003800:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003802:	0001b517          	auipc	a0,0x1b
    80003806:	abe50513          	addi	a0,a0,-1346 # 8001e2c0 <icache>
    8000380a:	ffffd097          	auipc	ra,0xffffd
    8000380e:	296080e7          	jalr	662(ra) # 80000aa0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003812:	4498                	lw	a4,8(s1)
    80003814:	4785                	li	a5,1
    80003816:	02f70663          	beq	a4,a5,80003842 <iput+0x54>
  ip->ref--;
    8000381a:	449c                	lw	a5,8(s1)
    8000381c:	37fd                	addiw	a5,a5,-1
    8000381e:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003820:	0001b517          	auipc	a0,0x1b
    80003824:	aa050513          	addi	a0,a0,-1376 # 8001e2c0 <icache>
    80003828:	ffffd097          	auipc	ra,0xffffd
    8000382c:	348080e7          	jalr	840(ra) # 80000b70 <release>
}
    80003830:	70e2                	ld	ra,56(sp)
    80003832:	7442                	ld	s0,48(sp)
    80003834:	74a2                	ld	s1,40(sp)
    80003836:	7902                	ld	s2,32(sp)
    80003838:	69e2                	ld	s3,24(sp)
    8000383a:	6a42                	ld	s4,16(sp)
    8000383c:	6aa2                	ld	s5,8(sp)
    8000383e:	6121                	addi	sp,sp,64
    80003840:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003842:	44bc                	lw	a5,72(s1)
    80003844:	dbf9                	beqz	a5,8000381a <iput+0x2c>
    80003846:	05249783          	lh	a5,82(s1)
    8000384a:	fbe1                	bnez	a5,8000381a <iput+0x2c>
    acquiresleep(&ip->lock);
    8000384c:	01048a13          	addi	s4,s1,16
    80003850:	8552                	mv	a0,s4
    80003852:	00001097          	auipc	ra,0x1
    80003856:	c38080e7          	jalr	-968(ra) # 8000448a <acquiresleep>
    release(&icache.lock);
    8000385a:	0001b517          	auipc	a0,0x1b
    8000385e:	a6650513          	addi	a0,a0,-1434 # 8001e2c0 <icache>
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	30e080e7          	jalr	782(ra) # 80000b70 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000386a:	05848913          	addi	s2,s1,88
    8000386e:	08848993          	addi	s3,s1,136
    80003872:	a021                	j	8000387a <iput+0x8c>
    80003874:	0911                	addi	s2,s2,4
    80003876:	01390d63          	beq	s2,s3,80003890 <iput+0xa2>
    if(ip->addrs[i]){
    8000387a:	00092583          	lw	a1,0(s2)
    8000387e:	d9fd                	beqz	a1,80003874 <iput+0x86>
      bfree(ip->dev, ip->addrs[i]);
    80003880:	4088                	lw	a0,0(s1)
    80003882:	00000097          	auipc	ra,0x0
    80003886:	8a2080e7          	jalr	-1886(ra) # 80003124 <bfree>
      ip->addrs[i] = 0;
    8000388a:	00092023          	sw	zero,0(s2)
    8000388e:	b7dd                	j	80003874 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003890:	0884a583          	lw	a1,136(s1)
    80003894:	ed9d                	bnez	a1,800038d2 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003896:	0404aa23          	sw	zero,84(s1)
  iupdate(ip);
    8000389a:	8526                	mv	a0,s1
    8000389c:	00000097          	auipc	ra,0x0
    800038a0:	d7a080e7          	jalr	-646(ra) # 80003616 <iupdate>
    ip->type = 0;
    800038a4:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    800038a8:	8526                	mv	a0,s1
    800038aa:	00000097          	auipc	ra,0x0
    800038ae:	d6c080e7          	jalr	-660(ra) # 80003616 <iupdate>
    ip->valid = 0;
    800038b2:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    800038b6:	8552                	mv	a0,s4
    800038b8:	00001097          	auipc	ra,0x1
    800038bc:	c28080e7          	jalr	-984(ra) # 800044e0 <releasesleep>
    acquire(&icache.lock);
    800038c0:	0001b517          	auipc	a0,0x1b
    800038c4:	a0050513          	addi	a0,a0,-1536 # 8001e2c0 <icache>
    800038c8:	ffffd097          	auipc	ra,0xffffd
    800038cc:	1d8080e7          	jalr	472(ra) # 80000aa0 <acquire>
    800038d0:	b7a9                	j	8000381a <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038d2:	4088                	lw	a0,0(s1)
    800038d4:	fffff097          	auipc	ra,0xfffff
    800038d8:	606080e7          	jalr	1542(ra) # 80002eda <bread>
    800038dc:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    800038de:	06050913          	addi	s2,a0,96
    800038e2:	46050993          	addi	s3,a0,1120
    800038e6:	a021                	j	800038ee <iput+0x100>
    800038e8:	0911                	addi	s2,s2,4
    800038ea:	01390b63          	beq	s2,s3,80003900 <iput+0x112>
      if(a[j])
    800038ee:	00092583          	lw	a1,0(s2)
    800038f2:	d9fd                	beqz	a1,800038e8 <iput+0xfa>
        bfree(ip->dev, a[j]);
    800038f4:	4088                	lw	a0,0(s1)
    800038f6:	00000097          	auipc	ra,0x0
    800038fa:	82e080e7          	jalr	-2002(ra) # 80003124 <bfree>
    800038fe:	b7ed                	j	800038e8 <iput+0xfa>
    brelse(bp);
    80003900:	8556                	mv	a0,s5
    80003902:	fffff097          	auipc	ra,0xfffff
    80003906:	70c080e7          	jalr	1804(ra) # 8000300e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000390a:	0884a583          	lw	a1,136(s1)
    8000390e:	4088                	lw	a0,0(s1)
    80003910:	00000097          	auipc	ra,0x0
    80003914:	814080e7          	jalr	-2028(ra) # 80003124 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003918:	0804a423          	sw	zero,136(s1)
    8000391c:	bfad                	j	80003896 <iput+0xa8>

000000008000391e <iunlockput>:
{
    8000391e:	1101                	addi	sp,sp,-32
    80003920:	ec06                	sd	ra,24(sp)
    80003922:	e822                	sd	s0,16(sp)
    80003924:	e426                	sd	s1,8(sp)
    80003926:	1000                	addi	s0,sp,32
    80003928:	84aa                	mv	s1,a0
  iunlock(ip);
    8000392a:	00000097          	auipc	ra,0x0
    8000392e:	e78080e7          	jalr	-392(ra) # 800037a2 <iunlock>
  iput(ip);
    80003932:	8526                	mv	a0,s1
    80003934:	00000097          	auipc	ra,0x0
    80003938:	eba080e7          	jalr	-326(ra) # 800037ee <iput>
}
    8000393c:	60e2                	ld	ra,24(sp)
    8000393e:	6442                	ld	s0,16(sp)
    80003940:	64a2                	ld	s1,8(sp)
    80003942:	6105                	addi	sp,sp,32
    80003944:	8082                	ret

0000000080003946 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003946:	1141                	addi	sp,sp,-16
    80003948:	e422                	sd	s0,8(sp)
    8000394a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000394c:	411c                	lw	a5,0(a0)
    8000394e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003950:	415c                	lw	a5,4(a0)
    80003952:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003954:	04c51783          	lh	a5,76(a0)
    80003958:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000395c:	05251783          	lh	a5,82(a0)
    80003960:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003964:	05456783          	lwu	a5,84(a0)
    80003968:	e99c                	sd	a5,16(a1)
}
    8000396a:	6422                	ld	s0,8(sp)
    8000396c:	0141                	addi	sp,sp,16
    8000396e:	8082                	ret

0000000080003970 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003970:	497c                	lw	a5,84(a0)
    80003972:	0ed7e563          	bltu	a5,a3,80003a5c <readi+0xec>
{
    80003976:	7159                	addi	sp,sp,-112
    80003978:	f486                	sd	ra,104(sp)
    8000397a:	f0a2                	sd	s0,96(sp)
    8000397c:	eca6                	sd	s1,88(sp)
    8000397e:	e8ca                	sd	s2,80(sp)
    80003980:	e4ce                	sd	s3,72(sp)
    80003982:	e0d2                	sd	s4,64(sp)
    80003984:	fc56                	sd	s5,56(sp)
    80003986:	f85a                	sd	s6,48(sp)
    80003988:	f45e                	sd	s7,40(sp)
    8000398a:	f062                	sd	s8,32(sp)
    8000398c:	ec66                	sd	s9,24(sp)
    8000398e:	e86a                	sd	s10,16(sp)
    80003990:	e46e                	sd	s11,8(sp)
    80003992:	1880                	addi	s0,sp,112
    80003994:	8baa                	mv	s7,a0
    80003996:	8c2e                	mv	s8,a1
    80003998:	8ab2                	mv	s5,a2
    8000399a:	8936                	mv	s2,a3
    8000399c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000399e:	9f35                	addw	a4,a4,a3
    800039a0:	0cd76063          	bltu	a4,a3,80003a60 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    800039a4:	00e7f463          	bgeu	a5,a4,800039ac <readi+0x3c>
    n = ip->size - off;
    800039a8:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039ac:	080b0763          	beqz	s6,80003a3a <readi+0xca>
    800039b0:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800039b2:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039b6:	5cfd                	li	s9,-1
    800039b8:	a82d                	j	800039f2 <readi+0x82>
    800039ba:	02099d93          	slli	s11,s3,0x20
    800039be:	020ddd93          	srli	s11,s11,0x20
    800039c2:	06048793          	addi	a5,s1,96
    800039c6:	86ee                	mv	a3,s11
    800039c8:	963e                	add	a2,a2,a5
    800039ca:	85d6                	mv	a1,s5
    800039cc:	8562                	mv	a0,s8
    800039ce:	fffff097          	auipc	ra,0xfffff
    800039d2:	aa4080e7          	jalr	-1372(ra) # 80002472 <either_copyout>
    800039d6:	05950d63          	beq	a0,s9,80003a30 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    800039da:	8526                	mv	a0,s1
    800039dc:	fffff097          	auipc	ra,0xfffff
    800039e0:	632080e7          	jalr	1586(ra) # 8000300e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039e4:	01498a3b          	addw	s4,s3,s4
    800039e8:	0129893b          	addw	s2,s3,s2
    800039ec:	9aee                	add	s5,s5,s11
    800039ee:	056a7663          	bgeu	s4,s6,80003a3a <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800039f2:	000ba483          	lw	s1,0(s7)
    800039f6:	00a9559b          	srliw	a1,s2,0xa
    800039fa:	855e                	mv	a0,s7
    800039fc:	00000097          	auipc	ra,0x0
    80003a00:	8d6080e7          	jalr	-1834(ra) # 800032d2 <bmap>
    80003a04:	0005059b          	sext.w	a1,a0
    80003a08:	8526                	mv	a0,s1
    80003a0a:	fffff097          	auipc	ra,0xfffff
    80003a0e:	4d0080e7          	jalr	1232(ra) # 80002eda <bread>
    80003a12:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a14:	3ff97613          	andi	a2,s2,1023
    80003a18:	40cd07bb          	subw	a5,s10,a2
    80003a1c:	414b073b          	subw	a4,s6,s4
    80003a20:	89be                	mv	s3,a5
    80003a22:	2781                	sext.w	a5,a5
    80003a24:	0007069b          	sext.w	a3,a4
    80003a28:	f8f6f9e3          	bgeu	a3,a5,800039ba <readi+0x4a>
    80003a2c:	89ba                	mv	s3,a4
    80003a2e:	b771                	j	800039ba <readi+0x4a>
      brelse(bp);
    80003a30:	8526                	mv	a0,s1
    80003a32:	fffff097          	auipc	ra,0xfffff
    80003a36:	5dc080e7          	jalr	1500(ra) # 8000300e <brelse>
  }
  return n;
    80003a3a:	000b051b          	sext.w	a0,s6
}
    80003a3e:	70a6                	ld	ra,104(sp)
    80003a40:	7406                	ld	s0,96(sp)
    80003a42:	64e6                	ld	s1,88(sp)
    80003a44:	6946                	ld	s2,80(sp)
    80003a46:	69a6                	ld	s3,72(sp)
    80003a48:	6a06                	ld	s4,64(sp)
    80003a4a:	7ae2                	ld	s5,56(sp)
    80003a4c:	7b42                	ld	s6,48(sp)
    80003a4e:	7ba2                	ld	s7,40(sp)
    80003a50:	7c02                	ld	s8,32(sp)
    80003a52:	6ce2                	ld	s9,24(sp)
    80003a54:	6d42                	ld	s10,16(sp)
    80003a56:	6da2                	ld	s11,8(sp)
    80003a58:	6165                	addi	sp,sp,112
    80003a5a:	8082                	ret
    return -1;
    80003a5c:	557d                	li	a0,-1
}
    80003a5e:	8082                	ret
    return -1;
    80003a60:	557d                	li	a0,-1
    80003a62:	bff1                	j	80003a3e <readi+0xce>

0000000080003a64 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a64:	497c                	lw	a5,84(a0)
    80003a66:	10d7e663          	bltu	a5,a3,80003b72 <writei+0x10e>
{
    80003a6a:	7159                	addi	sp,sp,-112
    80003a6c:	f486                	sd	ra,104(sp)
    80003a6e:	f0a2                	sd	s0,96(sp)
    80003a70:	eca6                	sd	s1,88(sp)
    80003a72:	e8ca                	sd	s2,80(sp)
    80003a74:	e4ce                	sd	s3,72(sp)
    80003a76:	e0d2                	sd	s4,64(sp)
    80003a78:	fc56                	sd	s5,56(sp)
    80003a7a:	f85a                	sd	s6,48(sp)
    80003a7c:	f45e                	sd	s7,40(sp)
    80003a7e:	f062                	sd	s8,32(sp)
    80003a80:	ec66                	sd	s9,24(sp)
    80003a82:	e86a                	sd	s10,16(sp)
    80003a84:	e46e                	sd	s11,8(sp)
    80003a86:	1880                	addi	s0,sp,112
    80003a88:	8baa                	mv	s7,a0
    80003a8a:	8c2e                	mv	s8,a1
    80003a8c:	8ab2                	mv	s5,a2
    80003a8e:	8936                	mv	s2,a3
    80003a90:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a92:	00e687bb          	addw	a5,a3,a4
    80003a96:	0ed7e063          	bltu	a5,a3,80003b76 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a9a:	00043737          	lui	a4,0x43
    80003a9e:	0cf76e63          	bltu	a4,a5,80003b7a <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aa2:	0a0b0763          	beqz	s6,80003b50 <writei+0xec>
    80003aa6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aa8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003aac:	5cfd                	li	s9,-1
    80003aae:	a091                	j	80003af2 <writei+0x8e>
    80003ab0:	02099d93          	slli	s11,s3,0x20
    80003ab4:	020ddd93          	srli	s11,s11,0x20
    80003ab8:	06048793          	addi	a5,s1,96
    80003abc:	86ee                	mv	a3,s11
    80003abe:	8656                	mv	a2,s5
    80003ac0:	85e2                	mv	a1,s8
    80003ac2:	953e                	add	a0,a0,a5
    80003ac4:	fffff097          	auipc	ra,0xfffff
    80003ac8:	a04080e7          	jalr	-1532(ra) # 800024c8 <either_copyin>
    80003acc:	07950263          	beq	a0,s9,80003b30 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ad0:	8526                	mv	a0,s1
    80003ad2:	00001097          	auipc	ra,0x1
    80003ad6:	83e080e7          	jalr	-1986(ra) # 80004310 <log_write>
    brelse(bp);
    80003ada:	8526                	mv	a0,s1
    80003adc:	fffff097          	auipc	ra,0xfffff
    80003ae0:	532080e7          	jalr	1330(ra) # 8000300e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ae4:	01498a3b          	addw	s4,s3,s4
    80003ae8:	0129893b          	addw	s2,s3,s2
    80003aec:	9aee                	add	s5,s5,s11
    80003aee:	056a7663          	bgeu	s4,s6,80003b3a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003af2:	000ba483          	lw	s1,0(s7)
    80003af6:	00a9559b          	srliw	a1,s2,0xa
    80003afa:	855e                	mv	a0,s7
    80003afc:	fffff097          	auipc	ra,0xfffff
    80003b00:	7d6080e7          	jalr	2006(ra) # 800032d2 <bmap>
    80003b04:	0005059b          	sext.w	a1,a0
    80003b08:	8526                	mv	a0,s1
    80003b0a:	fffff097          	auipc	ra,0xfffff
    80003b0e:	3d0080e7          	jalr	976(ra) # 80002eda <bread>
    80003b12:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b14:	3ff97513          	andi	a0,s2,1023
    80003b18:	40ad07bb          	subw	a5,s10,a0
    80003b1c:	414b073b          	subw	a4,s6,s4
    80003b20:	89be                	mv	s3,a5
    80003b22:	2781                	sext.w	a5,a5
    80003b24:	0007069b          	sext.w	a3,a4
    80003b28:	f8f6f4e3          	bgeu	a3,a5,80003ab0 <writei+0x4c>
    80003b2c:	89ba                	mv	s3,a4
    80003b2e:	b749                	j	80003ab0 <writei+0x4c>
      brelse(bp);
    80003b30:	8526                	mv	a0,s1
    80003b32:	fffff097          	auipc	ra,0xfffff
    80003b36:	4dc080e7          	jalr	1244(ra) # 8000300e <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003b3a:	054ba783          	lw	a5,84(s7)
    80003b3e:	0127f463          	bgeu	a5,s2,80003b46 <writei+0xe2>
      ip->size = off;
    80003b42:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003b46:	855e                	mv	a0,s7
    80003b48:	00000097          	auipc	ra,0x0
    80003b4c:	ace080e7          	jalr	-1330(ra) # 80003616 <iupdate>
  }

  return n;
    80003b50:	000b051b          	sext.w	a0,s6
}
    80003b54:	70a6                	ld	ra,104(sp)
    80003b56:	7406                	ld	s0,96(sp)
    80003b58:	64e6                	ld	s1,88(sp)
    80003b5a:	6946                	ld	s2,80(sp)
    80003b5c:	69a6                	ld	s3,72(sp)
    80003b5e:	6a06                	ld	s4,64(sp)
    80003b60:	7ae2                	ld	s5,56(sp)
    80003b62:	7b42                	ld	s6,48(sp)
    80003b64:	7ba2                	ld	s7,40(sp)
    80003b66:	7c02                	ld	s8,32(sp)
    80003b68:	6ce2                	ld	s9,24(sp)
    80003b6a:	6d42                	ld	s10,16(sp)
    80003b6c:	6da2                	ld	s11,8(sp)
    80003b6e:	6165                	addi	sp,sp,112
    80003b70:	8082                	ret
    return -1;
    80003b72:	557d                	li	a0,-1
}
    80003b74:	8082                	ret
    return -1;
    80003b76:	557d                	li	a0,-1
    80003b78:	bff1                	j	80003b54 <writei+0xf0>
    return -1;
    80003b7a:	557d                	li	a0,-1
    80003b7c:	bfe1                	j	80003b54 <writei+0xf0>

0000000080003b7e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b7e:	1141                	addi	sp,sp,-16
    80003b80:	e406                	sd	ra,8(sp)
    80003b82:	e022                	sd	s0,0(sp)
    80003b84:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b86:	4639                	li	a2,14
    80003b88:	ffffd097          	auipc	ra,0xffffd
    80003b8c:	2be080e7          	jalr	702(ra) # 80000e46 <strncmp>
}
    80003b90:	60a2                	ld	ra,8(sp)
    80003b92:	6402                	ld	s0,0(sp)
    80003b94:	0141                	addi	sp,sp,16
    80003b96:	8082                	ret

0000000080003b98 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b98:	7139                	addi	sp,sp,-64
    80003b9a:	fc06                	sd	ra,56(sp)
    80003b9c:	f822                	sd	s0,48(sp)
    80003b9e:	f426                	sd	s1,40(sp)
    80003ba0:	f04a                	sd	s2,32(sp)
    80003ba2:	ec4e                	sd	s3,24(sp)
    80003ba4:	e852                	sd	s4,16(sp)
    80003ba6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ba8:	04c51703          	lh	a4,76(a0)
    80003bac:	4785                	li	a5,1
    80003bae:	00f71a63          	bne	a4,a5,80003bc2 <dirlookup+0x2a>
    80003bb2:	892a                	mv	s2,a0
    80003bb4:	89ae                	mv	s3,a1
    80003bb6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bb8:	497c                	lw	a5,84(a0)
    80003bba:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bbc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bbe:	e79d                	bnez	a5,80003bec <dirlookup+0x54>
    80003bc0:	a8a5                	j	80003c38 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003bc2:	00005517          	auipc	a0,0x5
    80003bc6:	da650513          	addi	a0,a0,-602 # 80008968 <userret+0x8d8>
    80003bca:	ffffd097          	auipc	ra,0xffffd
    80003bce:	98a080e7          	jalr	-1654(ra) # 80000554 <panic>
      panic("dirlookup read");
    80003bd2:	00005517          	auipc	a0,0x5
    80003bd6:	dae50513          	addi	a0,a0,-594 # 80008980 <userret+0x8f0>
    80003bda:	ffffd097          	auipc	ra,0xffffd
    80003bde:	97a080e7          	jalr	-1670(ra) # 80000554 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003be2:	24c1                	addiw	s1,s1,16
    80003be4:	05492783          	lw	a5,84(s2)
    80003be8:	04f4f763          	bgeu	s1,a5,80003c36 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bec:	4741                	li	a4,16
    80003bee:	86a6                	mv	a3,s1
    80003bf0:	fc040613          	addi	a2,s0,-64
    80003bf4:	4581                	li	a1,0
    80003bf6:	854a                	mv	a0,s2
    80003bf8:	00000097          	auipc	ra,0x0
    80003bfc:	d78080e7          	jalr	-648(ra) # 80003970 <readi>
    80003c00:	47c1                	li	a5,16
    80003c02:	fcf518e3          	bne	a0,a5,80003bd2 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c06:	fc045783          	lhu	a5,-64(s0)
    80003c0a:	dfe1                	beqz	a5,80003be2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c0c:	fc240593          	addi	a1,s0,-62
    80003c10:	854e                	mv	a0,s3
    80003c12:	00000097          	auipc	ra,0x0
    80003c16:	f6c080e7          	jalr	-148(ra) # 80003b7e <namecmp>
    80003c1a:	f561                	bnez	a0,80003be2 <dirlookup+0x4a>
      if(poff)
    80003c1c:	000a0463          	beqz	s4,80003c24 <dirlookup+0x8c>
        *poff = off;
    80003c20:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c24:	fc045583          	lhu	a1,-64(s0)
    80003c28:	00092503          	lw	a0,0(s2)
    80003c2c:	fffff097          	auipc	ra,0xfffff
    80003c30:	780080e7          	jalr	1920(ra) # 800033ac <iget>
    80003c34:	a011                	j	80003c38 <dirlookup+0xa0>
  return 0;
    80003c36:	4501                	li	a0,0
}
    80003c38:	70e2                	ld	ra,56(sp)
    80003c3a:	7442                	ld	s0,48(sp)
    80003c3c:	74a2                	ld	s1,40(sp)
    80003c3e:	7902                	ld	s2,32(sp)
    80003c40:	69e2                	ld	s3,24(sp)
    80003c42:	6a42                	ld	s4,16(sp)
    80003c44:	6121                	addi	sp,sp,64
    80003c46:	8082                	ret

0000000080003c48 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c48:	711d                	addi	sp,sp,-96
    80003c4a:	ec86                	sd	ra,88(sp)
    80003c4c:	e8a2                	sd	s0,80(sp)
    80003c4e:	e4a6                	sd	s1,72(sp)
    80003c50:	e0ca                	sd	s2,64(sp)
    80003c52:	fc4e                	sd	s3,56(sp)
    80003c54:	f852                	sd	s4,48(sp)
    80003c56:	f456                	sd	s5,40(sp)
    80003c58:	f05a                	sd	s6,32(sp)
    80003c5a:	ec5e                	sd	s7,24(sp)
    80003c5c:	e862                	sd	s8,16(sp)
    80003c5e:	e466                	sd	s9,8(sp)
    80003c60:	1080                	addi	s0,sp,96
    80003c62:	84aa                	mv	s1,a0
    80003c64:	8aae                	mv	s5,a1
    80003c66:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c68:	00054703          	lbu	a4,0(a0)
    80003c6c:	02f00793          	li	a5,47
    80003c70:	02f70363          	beq	a4,a5,80003c96 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c74:	ffffe097          	auipc	ra,0xffffe
    80003c78:	de4080e7          	jalr	-540(ra) # 80001a58 <myproc>
    80003c7c:	15853503          	ld	a0,344(a0)
    80003c80:	00000097          	auipc	ra,0x0
    80003c84:	a22080e7          	jalr	-1502(ra) # 800036a2 <idup>
    80003c88:	89aa                	mv	s3,a0
  while(*path == '/')
    80003c8a:	02f00913          	li	s2,47
  len = path - s;
    80003c8e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003c90:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c92:	4b85                	li	s7,1
    80003c94:	a865                	j	80003d4c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003c96:	4585                	li	a1,1
    80003c98:	4501                	li	a0,0
    80003c9a:	fffff097          	auipc	ra,0xfffff
    80003c9e:	712080e7          	jalr	1810(ra) # 800033ac <iget>
    80003ca2:	89aa                	mv	s3,a0
    80003ca4:	b7dd                	j	80003c8a <namex+0x42>
      iunlockput(ip);
    80003ca6:	854e                	mv	a0,s3
    80003ca8:	00000097          	auipc	ra,0x0
    80003cac:	c76080e7          	jalr	-906(ra) # 8000391e <iunlockput>
      return 0;
    80003cb0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cb2:	854e                	mv	a0,s3
    80003cb4:	60e6                	ld	ra,88(sp)
    80003cb6:	6446                	ld	s0,80(sp)
    80003cb8:	64a6                	ld	s1,72(sp)
    80003cba:	6906                	ld	s2,64(sp)
    80003cbc:	79e2                	ld	s3,56(sp)
    80003cbe:	7a42                	ld	s4,48(sp)
    80003cc0:	7aa2                	ld	s5,40(sp)
    80003cc2:	7b02                	ld	s6,32(sp)
    80003cc4:	6be2                	ld	s7,24(sp)
    80003cc6:	6c42                	ld	s8,16(sp)
    80003cc8:	6ca2                	ld	s9,8(sp)
    80003cca:	6125                	addi	sp,sp,96
    80003ccc:	8082                	ret
      iunlock(ip);
    80003cce:	854e                	mv	a0,s3
    80003cd0:	00000097          	auipc	ra,0x0
    80003cd4:	ad2080e7          	jalr	-1326(ra) # 800037a2 <iunlock>
      return ip;
    80003cd8:	bfe9                	j	80003cb2 <namex+0x6a>
      iunlockput(ip);
    80003cda:	854e                	mv	a0,s3
    80003cdc:	00000097          	auipc	ra,0x0
    80003ce0:	c42080e7          	jalr	-958(ra) # 8000391e <iunlockput>
      return 0;
    80003ce4:	89e6                	mv	s3,s9
    80003ce6:	b7f1                	j	80003cb2 <namex+0x6a>
  len = path - s;
    80003ce8:	40b48633          	sub	a2,s1,a1
    80003cec:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003cf0:	099c5463          	bge	s8,s9,80003d78 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003cf4:	4639                	li	a2,14
    80003cf6:	8552                	mv	a0,s4
    80003cf8:	ffffd097          	auipc	ra,0xffffd
    80003cfc:	0d2080e7          	jalr	210(ra) # 80000dca <memmove>
  while(*path == '/')
    80003d00:	0004c783          	lbu	a5,0(s1)
    80003d04:	01279763          	bne	a5,s2,80003d12 <namex+0xca>
    path++;
    80003d08:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d0a:	0004c783          	lbu	a5,0(s1)
    80003d0e:	ff278de3          	beq	a5,s2,80003d08 <namex+0xc0>
    ilock(ip);
    80003d12:	854e                	mv	a0,s3
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	9cc080e7          	jalr	-1588(ra) # 800036e0 <ilock>
    if(ip->type != T_DIR){
    80003d1c:	04c99783          	lh	a5,76(s3)
    80003d20:	f97793e3          	bne	a5,s7,80003ca6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d24:	000a8563          	beqz	s5,80003d2e <namex+0xe6>
    80003d28:	0004c783          	lbu	a5,0(s1)
    80003d2c:	d3cd                	beqz	a5,80003cce <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d2e:	865a                	mv	a2,s6
    80003d30:	85d2                	mv	a1,s4
    80003d32:	854e                	mv	a0,s3
    80003d34:	00000097          	auipc	ra,0x0
    80003d38:	e64080e7          	jalr	-412(ra) # 80003b98 <dirlookup>
    80003d3c:	8caa                	mv	s9,a0
    80003d3e:	dd51                	beqz	a0,80003cda <namex+0x92>
    iunlockput(ip);
    80003d40:	854e                	mv	a0,s3
    80003d42:	00000097          	auipc	ra,0x0
    80003d46:	bdc080e7          	jalr	-1060(ra) # 8000391e <iunlockput>
    ip = next;
    80003d4a:	89e6                	mv	s3,s9
  while(*path == '/')
    80003d4c:	0004c783          	lbu	a5,0(s1)
    80003d50:	05279763          	bne	a5,s2,80003d9e <namex+0x156>
    path++;
    80003d54:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d56:	0004c783          	lbu	a5,0(s1)
    80003d5a:	ff278de3          	beq	a5,s2,80003d54 <namex+0x10c>
  if(*path == 0)
    80003d5e:	c79d                	beqz	a5,80003d8c <namex+0x144>
    path++;
    80003d60:	85a6                	mv	a1,s1
  len = path - s;
    80003d62:	8cda                	mv	s9,s6
    80003d64:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003d66:	01278963          	beq	a5,s2,80003d78 <namex+0x130>
    80003d6a:	dfbd                	beqz	a5,80003ce8 <namex+0xa0>
    path++;
    80003d6c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003d6e:	0004c783          	lbu	a5,0(s1)
    80003d72:	ff279ce3          	bne	a5,s2,80003d6a <namex+0x122>
    80003d76:	bf8d                	j	80003ce8 <namex+0xa0>
    memmove(name, s, len);
    80003d78:	2601                	sext.w	a2,a2
    80003d7a:	8552                	mv	a0,s4
    80003d7c:	ffffd097          	auipc	ra,0xffffd
    80003d80:	04e080e7          	jalr	78(ra) # 80000dca <memmove>
    name[len] = 0;
    80003d84:	9cd2                	add	s9,s9,s4
    80003d86:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d8a:	bf9d                	j	80003d00 <namex+0xb8>
  if(nameiparent){
    80003d8c:	f20a83e3          	beqz	s5,80003cb2 <namex+0x6a>
    iput(ip);
    80003d90:	854e                	mv	a0,s3
    80003d92:	00000097          	auipc	ra,0x0
    80003d96:	a5c080e7          	jalr	-1444(ra) # 800037ee <iput>
    return 0;
    80003d9a:	4981                	li	s3,0
    80003d9c:	bf19                	j	80003cb2 <namex+0x6a>
  if(*path == 0)
    80003d9e:	d7fd                	beqz	a5,80003d8c <namex+0x144>
  while(*path != '/' && *path != 0)
    80003da0:	0004c783          	lbu	a5,0(s1)
    80003da4:	85a6                	mv	a1,s1
    80003da6:	b7d1                	j	80003d6a <namex+0x122>

0000000080003da8 <dirlink>:
{
    80003da8:	7139                	addi	sp,sp,-64
    80003daa:	fc06                	sd	ra,56(sp)
    80003dac:	f822                	sd	s0,48(sp)
    80003dae:	f426                	sd	s1,40(sp)
    80003db0:	f04a                	sd	s2,32(sp)
    80003db2:	ec4e                	sd	s3,24(sp)
    80003db4:	e852                	sd	s4,16(sp)
    80003db6:	0080                	addi	s0,sp,64
    80003db8:	892a                	mv	s2,a0
    80003dba:	8a2e                	mv	s4,a1
    80003dbc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dbe:	4601                	li	a2,0
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	dd8080e7          	jalr	-552(ra) # 80003b98 <dirlookup>
    80003dc8:	e93d                	bnez	a0,80003e3e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dca:	05492483          	lw	s1,84(s2)
    80003dce:	c49d                	beqz	s1,80003dfc <dirlink+0x54>
    80003dd0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dd2:	4741                	li	a4,16
    80003dd4:	86a6                	mv	a3,s1
    80003dd6:	fc040613          	addi	a2,s0,-64
    80003dda:	4581                	li	a1,0
    80003ddc:	854a                	mv	a0,s2
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	b92080e7          	jalr	-1134(ra) # 80003970 <readi>
    80003de6:	47c1                	li	a5,16
    80003de8:	06f51163          	bne	a0,a5,80003e4a <dirlink+0xa2>
    if(de.inum == 0)
    80003dec:	fc045783          	lhu	a5,-64(s0)
    80003df0:	c791                	beqz	a5,80003dfc <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003df2:	24c1                	addiw	s1,s1,16
    80003df4:	05492783          	lw	a5,84(s2)
    80003df8:	fcf4ede3          	bltu	s1,a5,80003dd2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003dfc:	4639                	li	a2,14
    80003dfe:	85d2                	mv	a1,s4
    80003e00:	fc240513          	addi	a0,s0,-62
    80003e04:	ffffd097          	auipc	ra,0xffffd
    80003e08:	07e080e7          	jalr	126(ra) # 80000e82 <strncpy>
  de.inum = inum;
    80003e0c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e10:	4741                	li	a4,16
    80003e12:	86a6                	mv	a3,s1
    80003e14:	fc040613          	addi	a2,s0,-64
    80003e18:	4581                	li	a1,0
    80003e1a:	854a                	mv	a0,s2
    80003e1c:	00000097          	auipc	ra,0x0
    80003e20:	c48080e7          	jalr	-952(ra) # 80003a64 <writei>
    80003e24:	872a                	mv	a4,a0
    80003e26:	47c1                	li	a5,16
  return 0;
    80003e28:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e2a:	02f71863          	bne	a4,a5,80003e5a <dirlink+0xb2>
}
    80003e2e:	70e2                	ld	ra,56(sp)
    80003e30:	7442                	ld	s0,48(sp)
    80003e32:	74a2                	ld	s1,40(sp)
    80003e34:	7902                	ld	s2,32(sp)
    80003e36:	69e2                	ld	s3,24(sp)
    80003e38:	6a42                	ld	s4,16(sp)
    80003e3a:	6121                	addi	sp,sp,64
    80003e3c:	8082                	ret
    iput(ip);
    80003e3e:	00000097          	auipc	ra,0x0
    80003e42:	9b0080e7          	jalr	-1616(ra) # 800037ee <iput>
    return -1;
    80003e46:	557d                	li	a0,-1
    80003e48:	b7dd                	j	80003e2e <dirlink+0x86>
      panic("dirlink read");
    80003e4a:	00005517          	auipc	a0,0x5
    80003e4e:	b4650513          	addi	a0,a0,-1210 # 80008990 <userret+0x900>
    80003e52:	ffffc097          	auipc	ra,0xffffc
    80003e56:	702080e7          	jalr	1794(ra) # 80000554 <panic>
    panic("dirlink");
    80003e5a:	00005517          	auipc	a0,0x5
    80003e5e:	c5650513          	addi	a0,a0,-938 # 80008ab0 <userret+0xa20>
    80003e62:	ffffc097          	auipc	ra,0xffffc
    80003e66:	6f2080e7          	jalr	1778(ra) # 80000554 <panic>

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
    80003e78:	00000097          	auipc	ra,0x0
    80003e7c:	dd0080e7          	jalr	-560(ra) # 80003c48 <namex>
}
    80003e80:	60e2                	ld	ra,24(sp)
    80003e82:	6442                	ld	s0,16(sp)
    80003e84:	6105                	addi	sp,sp,32
    80003e86:	8082                	ret

0000000080003e88 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e88:	1141                	addi	sp,sp,-16
    80003e8a:	e406                	sd	ra,8(sp)
    80003e8c:	e022                	sd	s0,0(sp)
    80003e8e:	0800                	addi	s0,sp,16
    80003e90:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e92:	4585                	li	a1,1
    80003e94:	00000097          	auipc	ra,0x0
    80003e98:	db4080e7          	jalr	-588(ra) # 80003c48 <namex>
}
    80003e9c:	60a2                	ld	ra,8(sp)
    80003e9e:	6402                	ld	s0,0(sp)
    80003ea0:	0141                	addi	sp,sp,16
    80003ea2:	8082                	ret

0000000080003ea4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80003ea4:	7179                	addi	sp,sp,-48
    80003ea6:	f406                	sd	ra,40(sp)
    80003ea8:	f022                	sd	s0,32(sp)
    80003eaa:	ec26                	sd	s1,24(sp)
    80003eac:	e84a                	sd	s2,16(sp)
    80003eae:	e44e                	sd	s3,8(sp)
    80003eb0:	1800                	addi	s0,sp,48
    80003eb2:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80003eb4:	0b000993          	li	s3,176
    80003eb8:	033507b3          	mul	a5,a0,s3
    80003ebc:	0001c997          	auipc	s3,0x1c
    80003ec0:	04498993          	addi	s3,s3,68 # 8001ff00 <log>
    80003ec4:	99be                	add	s3,s3,a5
    80003ec6:	0209a583          	lw	a1,32(s3)
    80003eca:	fffff097          	auipc	ra,0xfffff
    80003ece:	010080e7          	jalr	16(ra) # 80002eda <bread>
    80003ed2:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80003ed4:	0349a783          	lw	a5,52(s3)
    80003ed8:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003eda:	0349a783          	lw	a5,52(s3)
    80003ede:	02f05763          	blez	a5,80003f0c <write_head+0x68>
    80003ee2:	0b000793          	li	a5,176
    80003ee6:	02f487b3          	mul	a5,s1,a5
    80003eea:	0001c717          	auipc	a4,0x1c
    80003eee:	04e70713          	addi	a4,a4,78 # 8001ff38 <log+0x38>
    80003ef2:	97ba                	add	a5,a5,a4
    80003ef4:	06450693          	addi	a3,a0,100
    80003ef8:	4701                	li	a4,0
    80003efa:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80003efc:	4390                	lw	a2,0(a5)
    80003efe:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003f00:	2705                	addiw	a4,a4,1
    80003f02:	0791                	addi	a5,a5,4
    80003f04:	0691                	addi	a3,a3,4
    80003f06:	59d0                	lw	a2,52(a1)
    80003f08:	fec74ae3          	blt	a4,a2,80003efc <write_head+0x58>
  }
  bwrite(buf);
    80003f0c:	854a                	mv	a0,s2
    80003f0e:	fffff097          	auipc	ra,0xfffff
    80003f12:	0c0080e7          	jalr	192(ra) # 80002fce <bwrite>
  brelse(buf);
    80003f16:	854a                	mv	a0,s2
    80003f18:	fffff097          	auipc	ra,0xfffff
    80003f1c:	0f6080e7          	jalr	246(ra) # 8000300e <brelse>
}
    80003f20:	70a2                	ld	ra,40(sp)
    80003f22:	7402                	ld	s0,32(sp)
    80003f24:	64e2                	ld	s1,24(sp)
    80003f26:	6942                	ld	s2,16(sp)
    80003f28:	69a2                	ld	s3,8(sp)
    80003f2a:	6145                	addi	sp,sp,48
    80003f2c:	8082                	ret

0000000080003f2e <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003f2e:	0b000793          	li	a5,176
    80003f32:	02f50733          	mul	a4,a0,a5
    80003f36:	0001c797          	auipc	a5,0x1c
    80003f3a:	fca78793          	addi	a5,a5,-54 # 8001ff00 <log>
    80003f3e:	97ba                	add	a5,a5,a4
    80003f40:	5bdc                	lw	a5,52(a5)
    80003f42:	0af05b63          	blez	a5,80003ff8 <install_trans+0xca>
{
    80003f46:	7139                	addi	sp,sp,-64
    80003f48:	fc06                	sd	ra,56(sp)
    80003f4a:	f822                	sd	s0,48(sp)
    80003f4c:	f426                	sd	s1,40(sp)
    80003f4e:	f04a                	sd	s2,32(sp)
    80003f50:	ec4e                	sd	s3,24(sp)
    80003f52:	e852                	sd	s4,16(sp)
    80003f54:	e456                	sd	s5,8(sp)
    80003f56:	e05a                	sd	s6,0(sp)
    80003f58:	0080                	addi	s0,sp,64
    80003f5a:	0001c797          	auipc	a5,0x1c
    80003f5e:	fde78793          	addi	a5,a5,-34 # 8001ff38 <log+0x38>
    80003f62:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003f66:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80003f68:	00050b1b          	sext.w	s6,a0
    80003f6c:	0001ca97          	auipc	s5,0x1c
    80003f70:	f94a8a93          	addi	s5,s5,-108 # 8001ff00 <log>
    80003f74:	9aba                	add	s5,s5,a4
    80003f76:	020aa583          	lw	a1,32(s5)
    80003f7a:	013585bb          	addw	a1,a1,s3
    80003f7e:	2585                	addiw	a1,a1,1
    80003f80:	855a                	mv	a0,s6
    80003f82:	fffff097          	auipc	ra,0xfffff
    80003f86:	f58080e7          	jalr	-168(ra) # 80002eda <bread>
    80003f8a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80003f8c:	000a2583          	lw	a1,0(s4)
    80003f90:	855a                	mv	a0,s6
    80003f92:	fffff097          	auipc	ra,0xfffff
    80003f96:	f48080e7          	jalr	-184(ra) # 80002eda <bread>
    80003f9a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f9c:	40000613          	li	a2,1024
    80003fa0:	06090593          	addi	a1,s2,96
    80003fa4:	06050513          	addi	a0,a0,96
    80003fa8:	ffffd097          	auipc	ra,0xffffd
    80003fac:	e22080e7          	jalr	-478(ra) # 80000dca <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	fffff097          	auipc	ra,0xfffff
    80003fb6:	01c080e7          	jalr	28(ra) # 80002fce <bwrite>
    bunpin(dbuf);
    80003fba:	8526                	mv	a0,s1
    80003fbc:	fffff097          	auipc	ra,0xfffff
    80003fc0:	12c080e7          	jalr	300(ra) # 800030e8 <bunpin>
    brelse(lbuf);
    80003fc4:	854a                	mv	a0,s2
    80003fc6:	fffff097          	auipc	ra,0xfffff
    80003fca:	048080e7          	jalr	72(ra) # 8000300e <brelse>
    brelse(dbuf);
    80003fce:	8526                	mv	a0,s1
    80003fd0:	fffff097          	auipc	ra,0xfffff
    80003fd4:	03e080e7          	jalr	62(ra) # 8000300e <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003fd8:	2985                	addiw	s3,s3,1
    80003fda:	0a11                	addi	s4,s4,4
    80003fdc:	034aa783          	lw	a5,52(s5)
    80003fe0:	f8f9cbe3          	blt	s3,a5,80003f76 <install_trans+0x48>
}
    80003fe4:	70e2                	ld	ra,56(sp)
    80003fe6:	7442                	ld	s0,48(sp)
    80003fe8:	74a2                	ld	s1,40(sp)
    80003fea:	7902                	ld	s2,32(sp)
    80003fec:	69e2                	ld	s3,24(sp)
    80003fee:	6a42                	ld	s4,16(sp)
    80003ff0:	6aa2                	ld	s5,8(sp)
    80003ff2:	6b02                	ld	s6,0(sp)
    80003ff4:	6121                	addi	sp,sp,64
    80003ff6:	8082                	ret
    80003ff8:	8082                	ret

0000000080003ffa <initlog>:
{
    80003ffa:	7179                	addi	sp,sp,-48
    80003ffc:	f406                	sd	ra,40(sp)
    80003ffe:	f022                	sd	s0,32(sp)
    80004000:	ec26                	sd	s1,24(sp)
    80004002:	e84a                	sd	s2,16(sp)
    80004004:	e44e                	sd	s3,8(sp)
    80004006:	e052                	sd	s4,0(sp)
    80004008:	1800                	addi	s0,sp,48
    8000400a:	892a                	mv	s2,a0
    8000400c:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    8000400e:	0b000713          	li	a4,176
    80004012:	02e504b3          	mul	s1,a0,a4
    80004016:	0001c997          	auipc	s3,0x1c
    8000401a:	eea98993          	addi	s3,s3,-278 # 8001ff00 <log>
    8000401e:	99a6                	add	s3,s3,s1
    80004020:	00005597          	auipc	a1,0x5
    80004024:	98058593          	addi	a1,a1,-1664 # 800089a0 <userret+0x910>
    80004028:	854e                	mv	a0,s3
    8000402a:	ffffd097          	auipc	ra,0xffffd
    8000402e:	9a2080e7          	jalr	-1630(ra) # 800009cc <initlock>
  log[dev].start = sb->logstart;
    80004032:	014a2583          	lw	a1,20(s4)
    80004036:	02b9a023          	sw	a1,32(s3)
  log[dev].size = sb->nlog;
    8000403a:	010a2783          	lw	a5,16(s4)
    8000403e:	02f9a223          	sw	a5,36(s3)
  log[dev].dev = dev;
    80004042:	0329a823          	sw	s2,48(s3)
  struct buf *buf = bread(dev, log[dev].start);
    80004046:	854a                	mv	a0,s2
    80004048:	fffff097          	auipc	ra,0xfffff
    8000404c:	e92080e7          	jalr	-366(ra) # 80002eda <bread>
  log[dev].lh.n = lh->n;
    80004050:	5134                	lw	a3,96(a0)
    80004052:	02d9aa23          	sw	a3,52(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004056:	02d05663          	blez	a3,80004082 <initlog+0x88>
    8000405a:	06450793          	addi	a5,a0,100
    8000405e:	0001c717          	auipc	a4,0x1c
    80004062:	eda70713          	addi	a4,a4,-294 # 8001ff38 <log+0x38>
    80004066:	9726                	add	a4,a4,s1
    80004068:	36fd                	addiw	a3,a3,-1
    8000406a:	1682                	slli	a3,a3,0x20
    8000406c:	9281                	srli	a3,a3,0x20
    8000406e:	068a                	slli	a3,a3,0x2
    80004070:	06850613          	addi	a2,a0,104
    80004074:	96b2                	add	a3,a3,a2
    log[dev].lh.block[i] = lh->block[i];
    80004076:	4390                	lw	a2,0(a5)
    80004078:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000407a:	0791                	addi	a5,a5,4
    8000407c:	0711                	addi	a4,a4,4
    8000407e:	fed79ce3          	bne	a5,a3,80004076 <initlog+0x7c>
  brelse(buf);
    80004082:	fffff097          	auipc	ra,0xfffff
    80004086:	f8c080e7          	jalr	-116(ra) # 8000300e <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    8000408a:	854a                	mv	a0,s2
    8000408c:	00000097          	auipc	ra,0x0
    80004090:	ea2080e7          	jalr	-350(ra) # 80003f2e <install_trans>
  log[dev].lh.n = 0;
    80004094:	0b000793          	li	a5,176
    80004098:	02f90733          	mul	a4,s2,a5
    8000409c:	0001c797          	auipc	a5,0x1c
    800040a0:	e6478793          	addi	a5,a5,-412 # 8001ff00 <log>
    800040a4:	97ba                	add	a5,a5,a4
    800040a6:	0207aa23          	sw	zero,52(a5)
  write_head(dev); // clear the log
    800040aa:	854a                	mv	a0,s2
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	df8080e7          	jalr	-520(ra) # 80003ea4 <write_head>
}
    800040b4:	70a2                	ld	ra,40(sp)
    800040b6:	7402                	ld	s0,32(sp)
    800040b8:	64e2                	ld	s1,24(sp)
    800040ba:	6942                	ld	s2,16(sp)
    800040bc:	69a2                	ld	s3,8(sp)
    800040be:	6a02                	ld	s4,0(sp)
    800040c0:	6145                	addi	sp,sp,48
    800040c2:	8082                	ret

00000000800040c4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    800040c4:	7139                	addi	sp,sp,-64
    800040c6:	fc06                	sd	ra,56(sp)
    800040c8:	f822                	sd	s0,48(sp)
    800040ca:	f426                	sd	s1,40(sp)
    800040cc:	f04a                	sd	s2,32(sp)
    800040ce:	ec4e                	sd	s3,24(sp)
    800040d0:	e852                	sd	s4,16(sp)
    800040d2:	e456                	sd	s5,8(sp)
    800040d4:	0080                	addi	s0,sp,64
    800040d6:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    800040d8:	0b000913          	li	s2,176
    800040dc:	032507b3          	mul	a5,a0,s2
    800040e0:	0001c917          	auipc	s2,0x1c
    800040e4:	e2090913          	addi	s2,s2,-480 # 8001ff00 <log>
    800040e8:	993e                	add	s2,s2,a5
    800040ea:	854a                	mv	a0,s2
    800040ec:	ffffd097          	auipc	ra,0xffffd
    800040f0:	9b4080e7          	jalr	-1612(ra) # 80000aa0 <acquire>
  while(1){
    if(log[dev].committing){
    800040f4:	0001c997          	auipc	s3,0x1c
    800040f8:	e0c98993          	addi	s3,s3,-500 # 8001ff00 <log>
    800040fc:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040fe:	4a79                	li	s4,30
    80004100:	a039                	j	8000410e <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    80004102:	85ca                	mv	a1,s2
    80004104:	854e                	mv	a0,s3
    80004106:	ffffe097          	auipc	ra,0xffffe
    8000410a:	112080e7          	jalr	274(ra) # 80002218 <sleep>
    if(log[dev].committing){
    8000410e:	54dc                	lw	a5,44(s1)
    80004110:	fbed                	bnez	a5,80004102 <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004112:	549c                	lw	a5,40(s1)
    80004114:	0017871b          	addiw	a4,a5,1
    80004118:	0007069b          	sext.w	a3,a4
    8000411c:	0027179b          	slliw	a5,a4,0x2
    80004120:	9fb9                	addw	a5,a5,a4
    80004122:	0017979b          	slliw	a5,a5,0x1
    80004126:	58d8                	lw	a4,52(s1)
    80004128:	9fb9                	addw	a5,a5,a4
    8000412a:	00fa5963          	bge	s4,a5,8000413c <begin_op+0x78>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    8000412e:	85ca                	mv	a1,s2
    80004130:	854e                	mv	a0,s3
    80004132:	ffffe097          	auipc	ra,0xffffe
    80004136:	0e6080e7          	jalr	230(ra) # 80002218 <sleep>
    8000413a:	bfd1                	j	8000410e <begin_op+0x4a>
    } else {
      log[dev].outstanding += 1;
    8000413c:	0b000513          	li	a0,176
    80004140:	02aa8ab3          	mul	s5,s5,a0
    80004144:	0001c797          	auipc	a5,0x1c
    80004148:	dbc78793          	addi	a5,a5,-580 # 8001ff00 <log>
    8000414c:	9abe                	add	s5,s5,a5
    8000414e:	02daa423          	sw	a3,40(s5)
      release(&log[dev].lock);
    80004152:	854a                	mv	a0,s2
    80004154:	ffffd097          	auipc	ra,0xffffd
    80004158:	a1c080e7          	jalr	-1508(ra) # 80000b70 <release>
      break;
    }
  }
}
    8000415c:	70e2                	ld	ra,56(sp)
    8000415e:	7442                	ld	s0,48(sp)
    80004160:	74a2                	ld	s1,40(sp)
    80004162:	7902                	ld	s2,32(sp)
    80004164:	69e2                	ld	s3,24(sp)
    80004166:	6a42                	ld	s4,16(sp)
    80004168:	6aa2                	ld	s5,8(sp)
    8000416a:	6121                	addi	sp,sp,64
    8000416c:	8082                	ret

000000008000416e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    8000416e:	715d                	addi	sp,sp,-80
    80004170:	e486                	sd	ra,72(sp)
    80004172:	e0a2                	sd	s0,64(sp)
    80004174:	fc26                	sd	s1,56(sp)
    80004176:	f84a                	sd	s2,48(sp)
    80004178:	f44e                	sd	s3,40(sp)
    8000417a:	f052                	sd	s4,32(sp)
    8000417c:	ec56                	sd	s5,24(sp)
    8000417e:	e85a                	sd	s6,16(sp)
    80004180:	e45e                	sd	s7,8(sp)
    80004182:	e062                	sd	s8,0(sp)
    80004184:	0880                	addi	s0,sp,80
    80004186:	89aa                	mv	s3,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    80004188:	0b000913          	li	s2,176
    8000418c:	03250933          	mul	s2,a0,s2
    80004190:	0001c497          	auipc	s1,0x1c
    80004194:	d7048493          	addi	s1,s1,-656 # 8001ff00 <log>
    80004198:	94ca                	add	s1,s1,s2
    8000419a:	8526                	mv	a0,s1
    8000419c:	ffffd097          	auipc	ra,0xffffd
    800041a0:	904080e7          	jalr	-1788(ra) # 80000aa0 <acquire>
  log[dev].outstanding -= 1;
    800041a4:	549c                	lw	a5,40(s1)
    800041a6:	37fd                	addiw	a5,a5,-1
    800041a8:	00078a9b          	sext.w	s5,a5
    800041ac:	d49c                	sw	a5,40(s1)
  if(log[dev].committing)
    800041ae:	54dc                	lw	a5,44(s1)
    800041b0:	e3b5                	bnez	a5,80004214 <end_op+0xa6>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    800041b2:	060a9963          	bnez	s5,80004224 <end_op+0xb6>
    do_commit = 1;
    log[dev].committing = 1;
    800041b6:	0b000a13          	li	s4,176
    800041ba:	034987b3          	mul	a5,s3,s4
    800041be:	0001ca17          	auipc	s4,0x1c
    800041c2:	d42a0a13          	addi	s4,s4,-702 # 8001ff00 <log>
    800041c6:	9a3e                	add	s4,s4,a5
    800041c8:	4785                	li	a5,1
    800041ca:	02fa2623          	sw	a5,44(s4)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    800041ce:	8526                	mv	a0,s1
    800041d0:	ffffd097          	auipc	ra,0xffffd
    800041d4:	9a0080e7          	jalr	-1632(ra) # 80000b70 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    800041d8:	034a2783          	lw	a5,52(s4)
    800041dc:	06f04d63          	bgtz	a5,80004256 <end_op+0xe8>
    acquire(&log[dev].lock);
    800041e0:	8526                	mv	a0,s1
    800041e2:	ffffd097          	auipc	ra,0xffffd
    800041e6:	8be080e7          	jalr	-1858(ra) # 80000aa0 <acquire>
    log[dev].committing = 0;
    800041ea:	0001c517          	auipc	a0,0x1c
    800041ee:	d1650513          	addi	a0,a0,-746 # 8001ff00 <log>
    800041f2:	0b000793          	li	a5,176
    800041f6:	02f989b3          	mul	s3,s3,a5
    800041fa:	99aa                	add	s3,s3,a0
    800041fc:	0209a623          	sw	zero,44(s3)
    wakeup(&log);
    80004200:	ffffe097          	auipc	ra,0xffffe
    80004204:	198080e7          	jalr	408(ra) # 80002398 <wakeup>
    release(&log[dev].lock);
    80004208:	8526                	mv	a0,s1
    8000420a:	ffffd097          	auipc	ra,0xffffd
    8000420e:	966080e7          	jalr	-1690(ra) # 80000b70 <release>
}
    80004212:	a035                	j	8000423e <end_op+0xd0>
    panic("log[dev].committing");
    80004214:	00004517          	auipc	a0,0x4
    80004218:	79450513          	addi	a0,a0,1940 # 800089a8 <userret+0x918>
    8000421c:	ffffc097          	auipc	ra,0xffffc
    80004220:	338080e7          	jalr	824(ra) # 80000554 <panic>
    wakeup(&log);
    80004224:	0001c517          	auipc	a0,0x1c
    80004228:	cdc50513          	addi	a0,a0,-804 # 8001ff00 <log>
    8000422c:	ffffe097          	auipc	ra,0xffffe
    80004230:	16c080e7          	jalr	364(ra) # 80002398 <wakeup>
  release(&log[dev].lock);
    80004234:	8526                	mv	a0,s1
    80004236:	ffffd097          	auipc	ra,0xffffd
    8000423a:	93a080e7          	jalr	-1734(ra) # 80000b70 <release>
}
    8000423e:	60a6                	ld	ra,72(sp)
    80004240:	6406                	ld	s0,64(sp)
    80004242:	74e2                	ld	s1,56(sp)
    80004244:	7942                	ld	s2,48(sp)
    80004246:	79a2                	ld	s3,40(sp)
    80004248:	7a02                	ld	s4,32(sp)
    8000424a:	6ae2                	ld	s5,24(sp)
    8000424c:	6b42                	ld	s6,16(sp)
    8000424e:	6ba2                	ld	s7,8(sp)
    80004250:	6c02                	ld	s8,0(sp)
    80004252:	6161                	addi	sp,sp,80
    80004254:	8082                	ret
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004256:	0001c797          	auipc	a5,0x1c
    8000425a:	ce278793          	addi	a5,a5,-798 # 8001ff38 <log+0x38>
    8000425e:	993e                	add	s2,s2,a5
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80004260:	00098c1b          	sext.w	s8,s3
    80004264:	0b000b93          	li	s7,176
    80004268:	037987b3          	mul	a5,s3,s7
    8000426c:	0001cb97          	auipc	s7,0x1c
    80004270:	c94b8b93          	addi	s7,s7,-876 # 8001ff00 <log>
    80004274:	9bbe                	add	s7,s7,a5
    80004276:	020ba583          	lw	a1,32(s7)
    8000427a:	015585bb          	addw	a1,a1,s5
    8000427e:	2585                	addiw	a1,a1,1
    80004280:	8562                	mv	a0,s8
    80004282:	fffff097          	auipc	ra,0xfffff
    80004286:	c58080e7          	jalr	-936(ra) # 80002eda <bread>
    8000428a:	8a2a                	mv	s4,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    8000428c:	00092583          	lw	a1,0(s2)
    80004290:	8562                	mv	a0,s8
    80004292:	fffff097          	auipc	ra,0xfffff
    80004296:	c48080e7          	jalr	-952(ra) # 80002eda <bread>
    8000429a:	8b2a                	mv	s6,a0
    memmove(to->data, from->data, BSIZE);
    8000429c:	40000613          	li	a2,1024
    800042a0:	06050593          	addi	a1,a0,96
    800042a4:	060a0513          	addi	a0,s4,96
    800042a8:	ffffd097          	auipc	ra,0xffffd
    800042ac:	b22080e7          	jalr	-1246(ra) # 80000dca <memmove>
    bwrite(to);  // write the log
    800042b0:	8552                	mv	a0,s4
    800042b2:	fffff097          	auipc	ra,0xfffff
    800042b6:	d1c080e7          	jalr	-740(ra) # 80002fce <bwrite>
    brelse(from);
    800042ba:	855a                	mv	a0,s6
    800042bc:	fffff097          	auipc	ra,0xfffff
    800042c0:	d52080e7          	jalr	-686(ra) # 8000300e <brelse>
    brelse(to);
    800042c4:	8552                	mv	a0,s4
    800042c6:	fffff097          	auipc	ra,0xfffff
    800042ca:	d48080e7          	jalr	-696(ra) # 8000300e <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800042ce:	2a85                	addiw	s5,s5,1
    800042d0:	0911                	addi	s2,s2,4
    800042d2:	034ba783          	lw	a5,52(s7)
    800042d6:	fafac0e3          	blt	s5,a5,80004276 <end_op+0x108>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    800042da:	854e                	mv	a0,s3
    800042dc:	00000097          	auipc	ra,0x0
    800042e0:	bc8080e7          	jalr	-1080(ra) # 80003ea4 <write_head>
    install_trans(dev); // Now install writes to home locations
    800042e4:	854e                	mv	a0,s3
    800042e6:	00000097          	auipc	ra,0x0
    800042ea:	c48080e7          	jalr	-952(ra) # 80003f2e <install_trans>
    log[dev].lh.n = 0;
    800042ee:	0b000793          	li	a5,176
    800042f2:	02f98733          	mul	a4,s3,a5
    800042f6:	0001c797          	auipc	a5,0x1c
    800042fa:	c0a78793          	addi	a5,a5,-1014 # 8001ff00 <log>
    800042fe:	97ba                	add	a5,a5,a4
    80004300:	0207aa23          	sw	zero,52(a5)
    write_head(dev);    // Erase the transaction from the log
    80004304:	854e                	mv	a0,s3
    80004306:	00000097          	auipc	ra,0x0
    8000430a:	b9e080e7          	jalr	-1122(ra) # 80003ea4 <write_head>
    8000430e:	bdc9                	j	800041e0 <end_op+0x72>

0000000080004310 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004310:	7179                	addi	sp,sp,-48
    80004312:	f406                	sd	ra,40(sp)
    80004314:	f022                	sd	s0,32(sp)
    80004316:	ec26                	sd	s1,24(sp)
    80004318:	e84a                	sd	s2,16(sp)
    8000431a:	e44e                	sd	s3,8(sp)
    8000431c:	e052                	sd	s4,0(sp)
    8000431e:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004320:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004324:	0b000793          	li	a5,176
    80004328:	02f90733          	mul	a4,s2,a5
    8000432c:	0001c797          	auipc	a5,0x1c
    80004330:	bd478793          	addi	a5,a5,-1068 # 8001ff00 <log>
    80004334:	97ba                	add	a5,a5,a4
    80004336:	5bd4                	lw	a3,52(a5)
    80004338:	47f5                	li	a5,29
    8000433a:	0ad7cc63          	blt	a5,a3,800043f2 <log_write+0xe2>
    8000433e:	89aa                	mv	s3,a0
    80004340:	0001c797          	auipc	a5,0x1c
    80004344:	bc078793          	addi	a5,a5,-1088 # 8001ff00 <log>
    80004348:	97ba                	add	a5,a5,a4
    8000434a:	53dc                	lw	a5,36(a5)
    8000434c:	37fd                	addiw	a5,a5,-1
    8000434e:	0af6d263          	bge	a3,a5,800043f2 <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004352:	0b000793          	li	a5,176
    80004356:	02f90733          	mul	a4,s2,a5
    8000435a:	0001c797          	auipc	a5,0x1c
    8000435e:	ba678793          	addi	a5,a5,-1114 # 8001ff00 <log>
    80004362:	97ba                	add	a5,a5,a4
    80004364:	579c                	lw	a5,40(a5)
    80004366:	08f05e63          	blez	a5,80004402 <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    8000436a:	0b000793          	li	a5,176
    8000436e:	02f904b3          	mul	s1,s2,a5
    80004372:	0001ca17          	auipc	s4,0x1c
    80004376:	b8ea0a13          	addi	s4,s4,-1138 # 8001ff00 <log>
    8000437a:	9a26                	add	s4,s4,s1
    8000437c:	8552                	mv	a0,s4
    8000437e:	ffffc097          	auipc	ra,0xffffc
    80004382:	722080e7          	jalr	1826(ra) # 80000aa0 <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004386:	034a2603          	lw	a2,52(s4)
    8000438a:	08c05463          	blez	a2,80004412 <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000438e:	00c9a583          	lw	a1,12(s3)
    80004392:	0001c797          	auipc	a5,0x1c
    80004396:	ba678793          	addi	a5,a5,-1114 # 8001ff38 <log+0x38>
    8000439a:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    8000439c:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000439e:	4394                	lw	a3,0(a5)
    800043a0:	06b68a63          	beq	a3,a1,80004414 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    800043a4:	2705                	addiw	a4,a4,1
    800043a6:	0791                	addi	a5,a5,4
    800043a8:	fec71be3          	bne	a4,a2,8000439e <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    800043ac:	02c00793          	li	a5,44
    800043b0:	02f907b3          	mul	a5,s2,a5
    800043b4:	97b2                	add	a5,a5,a2
    800043b6:	07b1                	addi	a5,a5,12
    800043b8:	078a                	slli	a5,a5,0x2
    800043ba:	0001c717          	auipc	a4,0x1c
    800043be:	b4670713          	addi	a4,a4,-1210 # 8001ff00 <log>
    800043c2:	97ba                	add	a5,a5,a4
    800043c4:	00c9a703          	lw	a4,12(s3)
    800043c8:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    800043ca:	854e                	mv	a0,s3
    800043cc:	fffff097          	auipc	ra,0xfffff
    800043d0:	ce0080e7          	jalr	-800(ra) # 800030ac <bpin>
    log[dev].lh.n++;
    800043d4:	0b000793          	li	a5,176
    800043d8:	02f90933          	mul	s2,s2,a5
    800043dc:	0001c797          	auipc	a5,0x1c
    800043e0:	b2478793          	addi	a5,a5,-1244 # 8001ff00 <log>
    800043e4:	993e                	add	s2,s2,a5
    800043e6:	03492783          	lw	a5,52(s2)
    800043ea:	2785                	addiw	a5,a5,1
    800043ec:	02f92a23          	sw	a5,52(s2)
    800043f0:	a099                	j	80004436 <log_write+0x126>
    panic("too big a transaction");
    800043f2:	00004517          	auipc	a0,0x4
    800043f6:	5ce50513          	addi	a0,a0,1486 # 800089c0 <userret+0x930>
    800043fa:	ffffc097          	auipc	ra,0xffffc
    800043fe:	15a080e7          	jalr	346(ra) # 80000554 <panic>
    panic("log_write outside of trans");
    80004402:	00004517          	auipc	a0,0x4
    80004406:	5d650513          	addi	a0,a0,1494 # 800089d8 <userret+0x948>
    8000440a:	ffffc097          	auipc	ra,0xffffc
    8000440e:	14a080e7          	jalr	330(ra) # 80000554 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004412:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    80004414:	02c00793          	li	a5,44
    80004418:	02f907b3          	mul	a5,s2,a5
    8000441c:	97ba                	add	a5,a5,a4
    8000441e:	07b1                	addi	a5,a5,12
    80004420:	078a                	slli	a5,a5,0x2
    80004422:	0001c697          	auipc	a3,0x1c
    80004426:	ade68693          	addi	a3,a3,-1314 # 8001ff00 <log>
    8000442a:	97b6                	add	a5,a5,a3
    8000442c:	00c9a683          	lw	a3,12(s3)
    80004430:	c794                	sw	a3,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004432:	f8e60ce3          	beq	a2,a4,800043ca <log_write+0xba>
  }
  release(&log[dev].lock);
    80004436:	8552                	mv	a0,s4
    80004438:	ffffc097          	auipc	ra,0xffffc
    8000443c:	738080e7          	jalr	1848(ra) # 80000b70 <release>
}
    80004440:	70a2                	ld	ra,40(sp)
    80004442:	7402                	ld	s0,32(sp)
    80004444:	64e2                	ld	s1,24(sp)
    80004446:	6942                	ld	s2,16(sp)
    80004448:	69a2                	ld	s3,8(sp)
    8000444a:	6a02                	ld	s4,0(sp)
    8000444c:	6145                	addi	sp,sp,48
    8000444e:	8082                	ret

0000000080004450 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004450:	1101                	addi	sp,sp,-32
    80004452:	ec06                	sd	ra,24(sp)
    80004454:	e822                	sd	s0,16(sp)
    80004456:	e426                	sd	s1,8(sp)
    80004458:	e04a                	sd	s2,0(sp)
    8000445a:	1000                	addi	s0,sp,32
    8000445c:	84aa                	mv	s1,a0
    8000445e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004460:	00004597          	auipc	a1,0x4
    80004464:	59858593          	addi	a1,a1,1432 # 800089f8 <userret+0x968>
    80004468:	0521                	addi	a0,a0,8
    8000446a:	ffffc097          	auipc	ra,0xffffc
    8000446e:	562080e7          	jalr	1378(ra) # 800009cc <initlock>
  lk->name = name;
    80004472:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004476:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000447a:	0204a823          	sw	zero,48(s1)
}
    8000447e:	60e2                	ld	ra,24(sp)
    80004480:	6442                	ld	s0,16(sp)
    80004482:	64a2                	ld	s1,8(sp)
    80004484:	6902                	ld	s2,0(sp)
    80004486:	6105                	addi	sp,sp,32
    80004488:	8082                	ret

000000008000448a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000448a:	1101                	addi	sp,sp,-32
    8000448c:	ec06                	sd	ra,24(sp)
    8000448e:	e822                	sd	s0,16(sp)
    80004490:	e426                	sd	s1,8(sp)
    80004492:	e04a                	sd	s2,0(sp)
    80004494:	1000                	addi	s0,sp,32
    80004496:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004498:	00850913          	addi	s2,a0,8
    8000449c:	854a                	mv	a0,s2
    8000449e:	ffffc097          	auipc	ra,0xffffc
    800044a2:	602080e7          	jalr	1538(ra) # 80000aa0 <acquire>
  while (lk->locked) {
    800044a6:	409c                	lw	a5,0(s1)
    800044a8:	cb89                	beqz	a5,800044ba <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800044aa:	85ca                	mv	a1,s2
    800044ac:	8526                	mv	a0,s1
    800044ae:	ffffe097          	auipc	ra,0xffffe
    800044b2:	d6a080e7          	jalr	-662(ra) # 80002218 <sleep>
  while (lk->locked) {
    800044b6:	409c                	lw	a5,0(s1)
    800044b8:	fbed                	bnez	a5,800044aa <acquiresleep+0x20>
  }
  lk->locked = 1;
    800044ba:	4785                	li	a5,1
    800044bc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800044be:	ffffd097          	auipc	ra,0xffffd
    800044c2:	59a080e7          	jalr	1434(ra) # 80001a58 <myproc>
    800044c6:	413c                	lw	a5,64(a0)
    800044c8:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    800044ca:	854a                	mv	a0,s2
    800044cc:	ffffc097          	auipc	ra,0xffffc
    800044d0:	6a4080e7          	jalr	1700(ra) # 80000b70 <release>
}
    800044d4:	60e2                	ld	ra,24(sp)
    800044d6:	6442                	ld	s0,16(sp)
    800044d8:	64a2                	ld	s1,8(sp)
    800044da:	6902                	ld	s2,0(sp)
    800044dc:	6105                	addi	sp,sp,32
    800044de:	8082                	ret

00000000800044e0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044e0:	1101                	addi	sp,sp,-32
    800044e2:	ec06                	sd	ra,24(sp)
    800044e4:	e822                	sd	s0,16(sp)
    800044e6:	e426                	sd	s1,8(sp)
    800044e8:	e04a                	sd	s2,0(sp)
    800044ea:	1000                	addi	s0,sp,32
    800044ec:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044ee:	00850913          	addi	s2,a0,8
    800044f2:	854a                	mv	a0,s2
    800044f4:	ffffc097          	auipc	ra,0xffffc
    800044f8:	5ac080e7          	jalr	1452(ra) # 80000aa0 <acquire>
  lk->locked = 0;
    800044fc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004500:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    80004504:	8526                	mv	a0,s1
    80004506:	ffffe097          	auipc	ra,0xffffe
    8000450a:	e92080e7          	jalr	-366(ra) # 80002398 <wakeup>
  release(&lk->lk);
    8000450e:	854a                	mv	a0,s2
    80004510:	ffffc097          	auipc	ra,0xffffc
    80004514:	660080e7          	jalr	1632(ra) # 80000b70 <release>
}
    80004518:	60e2                	ld	ra,24(sp)
    8000451a:	6442                	ld	s0,16(sp)
    8000451c:	64a2                	ld	s1,8(sp)
    8000451e:	6902                	ld	s2,0(sp)
    80004520:	6105                	addi	sp,sp,32
    80004522:	8082                	ret

0000000080004524 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004524:	7179                	addi	sp,sp,-48
    80004526:	f406                	sd	ra,40(sp)
    80004528:	f022                	sd	s0,32(sp)
    8000452a:	ec26                	sd	s1,24(sp)
    8000452c:	e84a                	sd	s2,16(sp)
    8000452e:	e44e                	sd	s3,8(sp)
    80004530:	1800                	addi	s0,sp,48
    80004532:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004534:	00850913          	addi	s2,a0,8
    80004538:	854a                	mv	a0,s2
    8000453a:	ffffc097          	auipc	ra,0xffffc
    8000453e:	566080e7          	jalr	1382(ra) # 80000aa0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004542:	409c                	lw	a5,0(s1)
    80004544:	ef99                	bnez	a5,80004562 <holdingsleep+0x3e>
    80004546:	4481                	li	s1,0
  release(&lk->lk);
    80004548:	854a                	mv	a0,s2
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	626080e7          	jalr	1574(ra) # 80000b70 <release>
  return r;
}
    80004552:	8526                	mv	a0,s1
    80004554:	70a2                	ld	ra,40(sp)
    80004556:	7402                	ld	s0,32(sp)
    80004558:	64e2                	ld	s1,24(sp)
    8000455a:	6942                	ld	s2,16(sp)
    8000455c:	69a2                	ld	s3,8(sp)
    8000455e:	6145                	addi	sp,sp,48
    80004560:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004562:	0304a983          	lw	s3,48(s1)
    80004566:	ffffd097          	auipc	ra,0xffffd
    8000456a:	4f2080e7          	jalr	1266(ra) # 80001a58 <myproc>
    8000456e:	4124                	lw	s1,64(a0)
    80004570:	413484b3          	sub	s1,s1,s3
    80004574:	0014b493          	seqz	s1,s1
    80004578:	bfc1                	j	80004548 <holdingsleep+0x24>

000000008000457a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000457a:	1141                	addi	sp,sp,-16
    8000457c:	e406                	sd	ra,8(sp)
    8000457e:	e022                	sd	s0,0(sp)
    80004580:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004582:	00004597          	auipc	a1,0x4
    80004586:	48658593          	addi	a1,a1,1158 # 80008a08 <userret+0x978>
    8000458a:	0001c517          	auipc	a0,0x1c
    8000458e:	b7650513          	addi	a0,a0,-1162 # 80020100 <ftable>
    80004592:	ffffc097          	auipc	ra,0xffffc
    80004596:	43a080e7          	jalr	1082(ra) # 800009cc <initlock>
}
    8000459a:	60a2                	ld	ra,8(sp)
    8000459c:	6402                	ld	s0,0(sp)
    8000459e:	0141                	addi	sp,sp,16
    800045a0:	8082                	ret

00000000800045a2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045a2:	1101                	addi	sp,sp,-32
    800045a4:	ec06                	sd	ra,24(sp)
    800045a6:	e822                	sd	s0,16(sp)
    800045a8:	e426                	sd	s1,8(sp)
    800045aa:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045ac:	0001c517          	auipc	a0,0x1c
    800045b0:	b5450513          	addi	a0,a0,-1196 # 80020100 <ftable>
    800045b4:	ffffc097          	auipc	ra,0xffffc
    800045b8:	4ec080e7          	jalr	1260(ra) # 80000aa0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045bc:	0001c497          	auipc	s1,0x1c
    800045c0:	b6448493          	addi	s1,s1,-1180 # 80020120 <ftable+0x20>
    800045c4:	0001d717          	auipc	a4,0x1d
    800045c8:	afc70713          	addi	a4,a4,-1284 # 800210c0 <ftable+0xfc0>
    if(f->ref == 0){
    800045cc:	40dc                	lw	a5,4(s1)
    800045ce:	cf99                	beqz	a5,800045ec <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045d0:	02848493          	addi	s1,s1,40
    800045d4:	fee49ce3          	bne	s1,a4,800045cc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045d8:	0001c517          	auipc	a0,0x1c
    800045dc:	b2850513          	addi	a0,a0,-1240 # 80020100 <ftable>
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	590080e7          	jalr	1424(ra) # 80000b70 <release>
  return 0;
    800045e8:	4481                	li	s1,0
    800045ea:	a819                	j	80004600 <filealloc+0x5e>
      f->ref = 1;
    800045ec:	4785                	li	a5,1
    800045ee:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800045f0:	0001c517          	auipc	a0,0x1c
    800045f4:	b1050513          	addi	a0,a0,-1264 # 80020100 <ftable>
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	578080e7          	jalr	1400(ra) # 80000b70 <release>
}
    80004600:	8526                	mv	a0,s1
    80004602:	60e2                	ld	ra,24(sp)
    80004604:	6442                	ld	s0,16(sp)
    80004606:	64a2                	ld	s1,8(sp)
    80004608:	6105                	addi	sp,sp,32
    8000460a:	8082                	ret

000000008000460c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000460c:	1101                	addi	sp,sp,-32
    8000460e:	ec06                	sd	ra,24(sp)
    80004610:	e822                	sd	s0,16(sp)
    80004612:	e426                	sd	s1,8(sp)
    80004614:	1000                	addi	s0,sp,32
    80004616:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004618:	0001c517          	auipc	a0,0x1c
    8000461c:	ae850513          	addi	a0,a0,-1304 # 80020100 <ftable>
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	480080e7          	jalr	1152(ra) # 80000aa0 <acquire>
  if(f->ref < 1)
    80004628:	40dc                	lw	a5,4(s1)
    8000462a:	02f05263          	blez	a5,8000464e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000462e:	2785                	addiw	a5,a5,1
    80004630:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004632:	0001c517          	auipc	a0,0x1c
    80004636:	ace50513          	addi	a0,a0,-1330 # 80020100 <ftable>
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	536080e7          	jalr	1334(ra) # 80000b70 <release>
  return f;
}
    80004642:	8526                	mv	a0,s1
    80004644:	60e2                	ld	ra,24(sp)
    80004646:	6442                	ld	s0,16(sp)
    80004648:	64a2                	ld	s1,8(sp)
    8000464a:	6105                	addi	sp,sp,32
    8000464c:	8082                	ret
    panic("filedup");
    8000464e:	00004517          	auipc	a0,0x4
    80004652:	3c250513          	addi	a0,a0,962 # 80008a10 <userret+0x980>
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	efe080e7          	jalr	-258(ra) # 80000554 <panic>

000000008000465e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000465e:	7139                	addi	sp,sp,-64
    80004660:	fc06                	sd	ra,56(sp)
    80004662:	f822                	sd	s0,48(sp)
    80004664:	f426                	sd	s1,40(sp)
    80004666:	f04a                	sd	s2,32(sp)
    80004668:	ec4e                	sd	s3,24(sp)
    8000466a:	e852                	sd	s4,16(sp)
    8000466c:	e456                	sd	s5,8(sp)
    8000466e:	0080                	addi	s0,sp,64
    80004670:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004672:	0001c517          	auipc	a0,0x1c
    80004676:	a8e50513          	addi	a0,a0,-1394 # 80020100 <ftable>
    8000467a:	ffffc097          	auipc	ra,0xffffc
    8000467e:	426080e7          	jalr	1062(ra) # 80000aa0 <acquire>
  if(f->ref < 1)
    80004682:	40dc                	lw	a5,4(s1)
    80004684:	06f05563          	blez	a5,800046ee <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004688:	37fd                	addiw	a5,a5,-1
    8000468a:	0007871b          	sext.w	a4,a5
    8000468e:	c0dc                	sw	a5,4(s1)
    80004690:	06e04763          	bgtz	a4,800046fe <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004694:	0004a903          	lw	s2,0(s1)
    80004698:	0094ca83          	lbu	s5,9(s1)
    8000469c:	0104ba03          	ld	s4,16(s1)
    800046a0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800046a4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046a8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800046ac:	0001c517          	auipc	a0,0x1c
    800046b0:	a5450513          	addi	a0,a0,-1452 # 80020100 <ftable>
    800046b4:	ffffc097          	auipc	ra,0xffffc
    800046b8:	4bc080e7          	jalr	1212(ra) # 80000b70 <release>

  if(ff.type == FD_PIPE){
    800046bc:	4785                	li	a5,1
    800046be:	06f90163          	beq	s2,a5,80004720 <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800046c2:	3979                	addiw	s2,s2,-2
    800046c4:	4785                	li	a5,1
    800046c6:	0527e463          	bltu	a5,s2,8000470e <fileclose+0xb0>
    begin_op(ff.ip->dev);
    800046ca:	0009a503          	lw	a0,0(s3)
    800046ce:	00000097          	auipc	ra,0x0
    800046d2:	9f6080e7          	jalr	-1546(ra) # 800040c4 <begin_op>
    iput(ff.ip);
    800046d6:	854e                	mv	a0,s3
    800046d8:	fffff097          	auipc	ra,0xfffff
    800046dc:	116080e7          	jalr	278(ra) # 800037ee <iput>
    end_op(ff.ip->dev);
    800046e0:	0009a503          	lw	a0,0(s3)
    800046e4:	00000097          	auipc	ra,0x0
    800046e8:	a8a080e7          	jalr	-1398(ra) # 8000416e <end_op>
    800046ec:	a00d                	j	8000470e <fileclose+0xb0>
    panic("fileclose");
    800046ee:	00004517          	auipc	a0,0x4
    800046f2:	32a50513          	addi	a0,a0,810 # 80008a18 <userret+0x988>
    800046f6:	ffffc097          	auipc	ra,0xffffc
    800046fa:	e5e080e7          	jalr	-418(ra) # 80000554 <panic>
    release(&ftable.lock);
    800046fe:	0001c517          	auipc	a0,0x1c
    80004702:	a0250513          	addi	a0,a0,-1534 # 80020100 <ftable>
    80004706:	ffffc097          	auipc	ra,0xffffc
    8000470a:	46a080e7          	jalr	1130(ra) # 80000b70 <release>
  }
}
    8000470e:	70e2                	ld	ra,56(sp)
    80004710:	7442                	ld	s0,48(sp)
    80004712:	74a2                	ld	s1,40(sp)
    80004714:	7902                	ld	s2,32(sp)
    80004716:	69e2                	ld	s3,24(sp)
    80004718:	6a42                	ld	s4,16(sp)
    8000471a:	6aa2                	ld	s5,8(sp)
    8000471c:	6121                	addi	sp,sp,64
    8000471e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004720:	85d6                	mv	a1,s5
    80004722:	8552                	mv	a0,s4
    80004724:	00000097          	auipc	ra,0x0
    80004728:	376080e7          	jalr	886(ra) # 80004a9a <pipeclose>
    8000472c:	b7cd                	j	8000470e <fileclose+0xb0>

000000008000472e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000472e:	715d                	addi	sp,sp,-80
    80004730:	e486                	sd	ra,72(sp)
    80004732:	e0a2                	sd	s0,64(sp)
    80004734:	fc26                	sd	s1,56(sp)
    80004736:	f84a                	sd	s2,48(sp)
    80004738:	f44e                	sd	s3,40(sp)
    8000473a:	0880                	addi	s0,sp,80
    8000473c:	84aa                	mv	s1,a0
    8000473e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004740:	ffffd097          	auipc	ra,0xffffd
    80004744:	318080e7          	jalr	792(ra) # 80001a58 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004748:	409c                	lw	a5,0(s1)
    8000474a:	37f9                	addiw	a5,a5,-2
    8000474c:	4705                	li	a4,1
    8000474e:	04f76763          	bltu	a4,a5,8000479c <filestat+0x6e>
    80004752:	892a                	mv	s2,a0
    ilock(f->ip);
    80004754:	6c88                	ld	a0,24(s1)
    80004756:	fffff097          	auipc	ra,0xfffff
    8000475a:	f8a080e7          	jalr	-118(ra) # 800036e0 <ilock>
    stati(f->ip, &st);
    8000475e:	fb840593          	addi	a1,s0,-72
    80004762:	6c88                	ld	a0,24(s1)
    80004764:	fffff097          	auipc	ra,0xfffff
    80004768:	1e2080e7          	jalr	482(ra) # 80003946 <stati>
    iunlock(f->ip);
    8000476c:	6c88                	ld	a0,24(s1)
    8000476e:	fffff097          	auipc	ra,0xfffff
    80004772:	034080e7          	jalr	52(ra) # 800037a2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004776:	46e1                	li	a3,24
    80004778:	fb840613          	addi	a2,s0,-72
    8000477c:	85ce                	mv	a1,s3
    8000477e:	05893503          	ld	a0,88(s2)
    80004782:	ffffd097          	auipc	ra,0xffffd
    80004786:	fc8080e7          	jalr	-56(ra) # 8000174a <copyout>
    8000478a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000478e:	60a6                	ld	ra,72(sp)
    80004790:	6406                	ld	s0,64(sp)
    80004792:	74e2                	ld	s1,56(sp)
    80004794:	7942                	ld	s2,48(sp)
    80004796:	79a2                	ld	s3,40(sp)
    80004798:	6161                	addi	sp,sp,80
    8000479a:	8082                	ret
  return -1;
    8000479c:	557d                	li	a0,-1
    8000479e:	bfc5                	j	8000478e <filestat+0x60>

00000000800047a0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047a0:	7179                	addi	sp,sp,-48
    800047a2:	f406                	sd	ra,40(sp)
    800047a4:	f022                	sd	s0,32(sp)
    800047a6:	ec26                	sd	s1,24(sp)
    800047a8:	e84a                	sd	s2,16(sp)
    800047aa:	e44e                	sd	s3,8(sp)
    800047ac:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800047ae:	00854783          	lbu	a5,8(a0)
    800047b2:	c7c5                	beqz	a5,8000485a <fileread+0xba>
    800047b4:	84aa                	mv	s1,a0
    800047b6:	89ae                	mv	s3,a1
    800047b8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800047ba:	411c                	lw	a5,0(a0)
    800047bc:	4705                	li	a4,1
    800047be:	04e78963          	beq	a5,a4,80004810 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047c2:	470d                	li	a4,3
    800047c4:	04e78d63          	beq	a5,a4,8000481e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800047c8:	4709                	li	a4,2
    800047ca:	08e79063          	bne	a5,a4,8000484a <fileread+0xaa>
    ilock(f->ip);
    800047ce:	6d08                	ld	a0,24(a0)
    800047d0:	fffff097          	auipc	ra,0xfffff
    800047d4:	f10080e7          	jalr	-240(ra) # 800036e0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800047d8:	874a                	mv	a4,s2
    800047da:	5094                	lw	a3,32(s1)
    800047dc:	864e                	mv	a2,s3
    800047de:	4585                	li	a1,1
    800047e0:	6c88                	ld	a0,24(s1)
    800047e2:	fffff097          	auipc	ra,0xfffff
    800047e6:	18e080e7          	jalr	398(ra) # 80003970 <readi>
    800047ea:	892a                	mv	s2,a0
    800047ec:	00a05563          	blez	a0,800047f6 <fileread+0x56>
      f->off += r;
    800047f0:	509c                	lw	a5,32(s1)
    800047f2:	9fa9                	addw	a5,a5,a0
    800047f4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047f6:	6c88                	ld	a0,24(s1)
    800047f8:	fffff097          	auipc	ra,0xfffff
    800047fc:	faa080e7          	jalr	-86(ra) # 800037a2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004800:	854a                	mv	a0,s2
    80004802:	70a2                	ld	ra,40(sp)
    80004804:	7402                	ld	s0,32(sp)
    80004806:	64e2                	ld	s1,24(sp)
    80004808:	6942                	ld	s2,16(sp)
    8000480a:	69a2                	ld	s3,8(sp)
    8000480c:	6145                	addi	sp,sp,48
    8000480e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004810:	6908                	ld	a0,16(a0)
    80004812:	00000097          	auipc	ra,0x0
    80004816:	406080e7          	jalr	1030(ra) # 80004c18 <piperead>
    8000481a:	892a                	mv	s2,a0
    8000481c:	b7d5                	j	80004800 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000481e:	02451783          	lh	a5,36(a0)
    80004822:	03079693          	slli	a3,a5,0x30
    80004826:	92c1                	srli	a3,a3,0x30
    80004828:	4725                	li	a4,9
    8000482a:	02d76a63          	bltu	a4,a3,8000485e <fileread+0xbe>
    8000482e:	0792                	slli	a5,a5,0x4
    80004830:	0001c717          	auipc	a4,0x1c
    80004834:	83070713          	addi	a4,a4,-2000 # 80020060 <devsw>
    80004838:	97ba                	add	a5,a5,a4
    8000483a:	639c                	ld	a5,0(a5)
    8000483c:	c39d                	beqz	a5,80004862 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    8000483e:	86b2                	mv	a3,a2
    80004840:	862e                	mv	a2,a1
    80004842:	4585                	li	a1,1
    80004844:	9782                	jalr	a5
    80004846:	892a                	mv	s2,a0
    80004848:	bf65                	j	80004800 <fileread+0x60>
    panic("fileread");
    8000484a:	00004517          	auipc	a0,0x4
    8000484e:	1de50513          	addi	a0,a0,478 # 80008a28 <userret+0x998>
    80004852:	ffffc097          	auipc	ra,0xffffc
    80004856:	d02080e7          	jalr	-766(ra) # 80000554 <panic>
    return -1;
    8000485a:	597d                	li	s2,-1
    8000485c:	b755                	j	80004800 <fileread+0x60>
      return -1;
    8000485e:	597d                	li	s2,-1
    80004860:	b745                	j	80004800 <fileread+0x60>
    80004862:	597d                	li	s2,-1
    80004864:	bf71                	j	80004800 <fileread+0x60>

0000000080004866 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004866:	00954783          	lbu	a5,9(a0)
    8000486a:	14078663          	beqz	a5,800049b6 <filewrite+0x150>
{
    8000486e:	715d                	addi	sp,sp,-80
    80004870:	e486                	sd	ra,72(sp)
    80004872:	e0a2                	sd	s0,64(sp)
    80004874:	fc26                	sd	s1,56(sp)
    80004876:	f84a                	sd	s2,48(sp)
    80004878:	f44e                	sd	s3,40(sp)
    8000487a:	f052                	sd	s4,32(sp)
    8000487c:	ec56                	sd	s5,24(sp)
    8000487e:	e85a                	sd	s6,16(sp)
    80004880:	e45e                	sd	s7,8(sp)
    80004882:	e062                	sd	s8,0(sp)
    80004884:	0880                	addi	s0,sp,80
    80004886:	84aa                	mv	s1,a0
    80004888:	8aae                	mv	s5,a1
    8000488a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000488c:	411c                	lw	a5,0(a0)
    8000488e:	4705                	li	a4,1
    80004890:	02e78263          	beq	a5,a4,800048b4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004894:	470d                	li	a4,3
    80004896:	02e78563          	beq	a5,a4,800048c0 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    8000489a:	4709                	li	a4,2
    8000489c:	10e79563          	bne	a5,a4,800049a6 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048a0:	0ec05f63          	blez	a2,8000499e <filewrite+0x138>
    int i = 0;
    800048a4:	4981                	li	s3,0
    800048a6:	6b05                	lui	s6,0x1
    800048a8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800048ac:	6b85                	lui	s7,0x1
    800048ae:	c00b8b9b          	addiw	s7,s7,-1024
    800048b2:	a851                	j	80004946 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800048b4:	6908                	ld	a0,16(a0)
    800048b6:	00000097          	auipc	ra,0x0
    800048ba:	254080e7          	jalr	596(ra) # 80004b0a <pipewrite>
    800048be:	a865                	j	80004976 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800048c0:	02451783          	lh	a5,36(a0)
    800048c4:	03079693          	slli	a3,a5,0x30
    800048c8:	92c1                	srli	a3,a3,0x30
    800048ca:	4725                	li	a4,9
    800048cc:	0ed76763          	bltu	a4,a3,800049ba <filewrite+0x154>
    800048d0:	0792                	slli	a5,a5,0x4
    800048d2:	0001b717          	auipc	a4,0x1b
    800048d6:	78e70713          	addi	a4,a4,1934 # 80020060 <devsw>
    800048da:	97ba                	add	a5,a5,a4
    800048dc:	679c                	ld	a5,8(a5)
    800048de:	c3e5                	beqz	a5,800049be <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    800048e0:	86b2                	mv	a3,a2
    800048e2:	862e                	mv	a2,a1
    800048e4:	4585                	li	a1,1
    800048e6:	9782                	jalr	a5
    800048e8:	a079                	j	80004976 <filewrite+0x110>
    800048ea:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    800048ee:	6c9c                	ld	a5,24(s1)
    800048f0:	4388                	lw	a0,0(a5)
    800048f2:	fffff097          	auipc	ra,0xfffff
    800048f6:	7d2080e7          	jalr	2002(ra) # 800040c4 <begin_op>
      ilock(f->ip);
    800048fa:	6c88                	ld	a0,24(s1)
    800048fc:	fffff097          	auipc	ra,0xfffff
    80004900:	de4080e7          	jalr	-540(ra) # 800036e0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004904:	8762                	mv	a4,s8
    80004906:	5094                	lw	a3,32(s1)
    80004908:	01598633          	add	a2,s3,s5
    8000490c:	4585                	li	a1,1
    8000490e:	6c88                	ld	a0,24(s1)
    80004910:	fffff097          	auipc	ra,0xfffff
    80004914:	154080e7          	jalr	340(ra) # 80003a64 <writei>
    80004918:	892a                	mv	s2,a0
    8000491a:	02a05e63          	blez	a0,80004956 <filewrite+0xf0>
        f->off += r;
    8000491e:	509c                	lw	a5,32(s1)
    80004920:	9fa9                	addw	a5,a5,a0
    80004922:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004924:	6c88                	ld	a0,24(s1)
    80004926:	fffff097          	auipc	ra,0xfffff
    8000492a:	e7c080e7          	jalr	-388(ra) # 800037a2 <iunlock>
      end_op(f->ip->dev);
    8000492e:	6c9c                	ld	a5,24(s1)
    80004930:	4388                	lw	a0,0(a5)
    80004932:	00000097          	auipc	ra,0x0
    80004936:	83c080e7          	jalr	-1988(ra) # 8000416e <end_op>

      if(r < 0)
        break;
      if(r != n1)
    8000493a:	052c1a63          	bne	s8,s2,8000498e <filewrite+0x128>
        panic("short filewrite");
      i += r;
    8000493e:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80004942:	0349d763          	bge	s3,s4,80004970 <filewrite+0x10a>
      int n1 = n - i;
    80004946:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000494a:	893e                	mv	s2,a5
    8000494c:	2781                	sext.w	a5,a5
    8000494e:	f8fb5ee3          	bge	s6,a5,800048ea <filewrite+0x84>
    80004952:	895e                	mv	s2,s7
    80004954:	bf59                	j	800048ea <filewrite+0x84>
      iunlock(f->ip);
    80004956:	6c88                	ld	a0,24(s1)
    80004958:	fffff097          	auipc	ra,0xfffff
    8000495c:	e4a080e7          	jalr	-438(ra) # 800037a2 <iunlock>
      end_op(f->ip->dev);
    80004960:	6c9c                	ld	a5,24(s1)
    80004962:	4388                	lw	a0,0(a5)
    80004964:	00000097          	auipc	ra,0x0
    80004968:	80a080e7          	jalr	-2038(ra) # 8000416e <end_op>
      if(r < 0)
    8000496c:	fc0957e3          	bgez	s2,8000493a <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004970:	8552                	mv	a0,s4
    80004972:	033a1863          	bne	s4,s3,800049a2 <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004976:	60a6                	ld	ra,72(sp)
    80004978:	6406                	ld	s0,64(sp)
    8000497a:	74e2                	ld	s1,56(sp)
    8000497c:	7942                	ld	s2,48(sp)
    8000497e:	79a2                	ld	s3,40(sp)
    80004980:	7a02                	ld	s4,32(sp)
    80004982:	6ae2                	ld	s5,24(sp)
    80004984:	6b42                	ld	s6,16(sp)
    80004986:	6ba2                	ld	s7,8(sp)
    80004988:	6c02                	ld	s8,0(sp)
    8000498a:	6161                	addi	sp,sp,80
    8000498c:	8082                	ret
        panic("short filewrite");
    8000498e:	00004517          	auipc	a0,0x4
    80004992:	0aa50513          	addi	a0,a0,170 # 80008a38 <userret+0x9a8>
    80004996:	ffffc097          	auipc	ra,0xffffc
    8000499a:	bbe080e7          	jalr	-1090(ra) # 80000554 <panic>
    int i = 0;
    8000499e:	4981                	li	s3,0
    800049a0:	bfc1                	j	80004970 <filewrite+0x10a>
    ret = (i == n ? n : -1);
    800049a2:	557d                	li	a0,-1
    800049a4:	bfc9                	j	80004976 <filewrite+0x110>
    panic("filewrite");
    800049a6:	00004517          	auipc	a0,0x4
    800049aa:	0a250513          	addi	a0,a0,162 # 80008a48 <userret+0x9b8>
    800049ae:	ffffc097          	auipc	ra,0xffffc
    800049b2:	ba6080e7          	jalr	-1114(ra) # 80000554 <panic>
    return -1;
    800049b6:	557d                	li	a0,-1
}
    800049b8:	8082                	ret
      return -1;
    800049ba:	557d                	li	a0,-1
    800049bc:	bf6d                	j	80004976 <filewrite+0x110>
    800049be:	557d                	li	a0,-1
    800049c0:	bf5d                	j	80004976 <filewrite+0x110>

00000000800049c2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049c2:	7179                	addi	sp,sp,-48
    800049c4:	f406                	sd	ra,40(sp)
    800049c6:	f022                	sd	s0,32(sp)
    800049c8:	ec26                	sd	s1,24(sp)
    800049ca:	e84a                	sd	s2,16(sp)
    800049cc:	e44e                	sd	s3,8(sp)
    800049ce:	e052                	sd	s4,0(sp)
    800049d0:	1800                	addi	s0,sp,48
    800049d2:	84aa                	mv	s1,a0
    800049d4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800049d6:	0005b023          	sd	zero,0(a1)
    800049da:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800049de:	00000097          	auipc	ra,0x0
    800049e2:	bc4080e7          	jalr	-1084(ra) # 800045a2 <filealloc>
    800049e6:	e088                	sd	a0,0(s1)
    800049e8:	c549                	beqz	a0,80004a72 <pipealloc+0xb0>
    800049ea:	00000097          	auipc	ra,0x0
    800049ee:	bb8080e7          	jalr	-1096(ra) # 800045a2 <filealloc>
    800049f2:	00aa3023          	sd	a0,0(s4)
    800049f6:	c925                	beqz	a0,80004a66 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800049f8:	ffffc097          	auipc	ra,0xffffc
    800049fc:	f74080e7          	jalr	-140(ra) # 8000096c <kalloc>
    80004a00:	892a                	mv	s2,a0
    80004a02:	cd39                	beqz	a0,80004a60 <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    80004a04:	4985                	li	s3,1
    80004a06:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004a0a:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004a0e:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004a12:	22052023          	sw	zero,544(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    80004a16:	02000613          	li	a2,32
    80004a1a:	4581                	li	a1,0
    80004a1c:	ffffc097          	auipc	ra,0xffffc
    80004a20:	352080e7          	jalr	850(ra) # 80000d6e <memset>
  (*f0)->type = FD_PIPE;
    80004a24:	609c                	ld	a5,0(s1)
    80004a26:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a2a:	609c                	ld	a5,0(s1)
    80004a2c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a30:	609c                	ld	a5,0(s1)
    80004a32:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a36:	609c                	ld	a5,0(s1)
    80004a38:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a3c:	000a3783          	ld	a5,0(s4)
    80004a40:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a44:	000a3783          	ld	a5,0(s4)
    80004a48:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a4c:	000a3783          	ld	a5,0(s4)
    80004a50:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a54:	000a3783          	ld	a5,0(s4)
    80004a58:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a5c:	4501                	li	a0,0
    80004a5e:	a025                	j	80004a86 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a60:	6088                	ld	a0,0(s1)
    80004a62:	e501                	bnez	a0,80004a6a <pipealloc+0xa8>
    80004a64:	a039                	j	80004a72 <pipealloc+0xb0>
    80004a66:	6088                	ld	a0,0(s1)
    80004a68:	c51d                	beqz	a0,80004a96 <pipealloc+0xd4>
    fileclose(*f0);
    80004a6a:	00000097          	auipc	ra,0x0
    80004a6e:	bf4080e7          	jalr	-1036(ra) # 8000465e <fileclose>
  if(*f1)
    80004a72:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a76:	557d                	li	a0,-1
  if(*f1)
    80004a78:	c799                	beqz	a5,80004a86 <pipealloc+0xc4>
    fileclose(*f1);
    80004a7a:	853e                	mv	a0,a5
    80004a7c:	00000097          	auipc	ra,0x0
    80004a80:	be2080e7          	jalr	-1054(ra) # 8000465e <fileclose>
  return -1;
    80004a84:	557d                	li	a0,-1
}
    80004a86:	70a2                	ld	ra,40(sp)
    80004a88:	7402                	ld	s0,32(sp)
    80004a8a:	64e2                	ld	s1,24(sp)
    80004a8c:	6942                	ld	s2,16(sp)
    80004a8e:	69a2                	ld	s3,8(sp)
    80004a90:	6a02                	ld	s4,0(sp)
    80004a92:	6145                	addi	sp,sp,48
    80004a94:	8082                	ret
  return -1;
    80004a96:	557d                	li	a0,-1
    80004a98:	b7fd                	j	80004a86 <pipealloc+0xc4>

0000000080004a9a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a9a:	1101                	addi	sp,sp,-32
    80004a9c:	ec06                	sd	ra,24(sp)
    80004a9e:	e822                	sd	s0,16(sp)
    80004aa0:	e426                	sd	s1,8(sp)
    80004aa2:	e04a                	sd	s2,0(sp)
    80004aa4:	1000                	addi	s0,sp,32
    80004aa6:	84aa                	mv	s1,a0
    80004aa8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	ff6080e7          	jalr	-10(ra) # 80000aa0 <acquire>
  if(writable){
    80004ab2:	02090d63          	beqz	s2,80004aec <pipeclose+0x52>
    pi->writeopen = 0;
    80004ab6:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004aba:	22048513          	addi	a0,s1,544
    80004abe:	ffffe097          	auipc	ra,0xffffe
    80004ac2:	8da080e7          	jalr	-1830(ra) # 80002398 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ac6:	2284b783          	ld	a5,552(s1)
    80004aca:	eb95                	bnez	a5,80004afe <pipeclose+0x64>
    release(&pi->lock);
    80004acc:	8526                	mv	a0,s1
    80004ace:	ffffc097          	auipc	ra,0xffffc
    80004ad2:	0a2080e7          	jalr	162(ra) # 80000b70 <release>
    kfree((char*)pi);
    80004ad6:	8526                	mv	a0,s1
    80004ad8:	ffffc097          	auipc	ra,0xffffc
    80004adc:	d98080e7          	jalr	-616(ra) # 80000870 <kfree>
  } else
    release(&pi->lock);
}
    80004ae0:	60e2                	ld	ra,24(sp)
    80004ae2:	6442                	ld	s0,16(sp)
    80004ae4:	64a2                	ld	s1,8(sp)
    80004ae6:	6902                	ld	s2,0(sp)
    80004ae8:	6105                	addi	sp,sp,32
    80004aea:	8082                	ret
    pi->readopen = 0;
    80004aec:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004af0:	22448513          	addi	a0,s1,548
    80004af4:	ffffe097          	auipc	ra,0xffffe
    80004af8:	8a4080e7          	jalr	-1884(ra) # 80002398 <wakeup>
    80004afc:	b7e9                	j	80004ac6 <pipeclose+0x2c>
    release(&pi->lock);
    80004afe:	8526                	mv	a0,s1
    80004b00:	ffffc097          	auipc	ra,0xffffc
    80004b04:	070080e7          	jalr	112(ra) # 80000b70 <release>
}
    80004b08:	bfe1                	j	80004ae0 <pipeclose+0x46>

0000000080004b0a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b0a:	711d                	addi	sp,sp,-96
    80004b0c:	ec86                	sd	ra,88(sp)
    80004b0e:	e8a2                	sd	s0,80(sp)
    80004b10:	e4a6                	sd	s1,72(sp)
    80004b12:	e0ca                	sd	s2,64(sp)
    80004b14:	fc4e                	sd	s3,56(sp)
    80004b16:	f852                	sd	s4,48(sp)
    80004b18:	f456                	sd	s5,40(sp)
    80004b1a:	f05a                	sd	s6,32(sp)
    80004b1c:	ec5e                	sd	s7,24(sp)
    80004b1e:	e862                	sd	s8,16(sp)
    80004b20:	1080                	addi	s0,sp,96
    80004b22:	84aa                	mv	s1,a0
    80004b24:	8aae                	mv	s5,a1
    80004b26:	8a32                	mv	s4,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004b28:	ffffd097          	auipc	ra,0xffffd
    80004b2c:	f30080e7          	jalr	-208(ra) # 80001a58 <myproc>
    80004b30:	8baa                	mv	s7,a0

  acquire(&pi->lock);
    80004b32:	8526                	mv	a0,s1
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	f6c080e7          	jalr	-148(ra) # 80000aa0 <acquire>
  for(i = 0; i < n; i++){
    80004b3c:	09405f63          	blez	s4,80004bda <pipewrite+0xd0>
    80004b40:	fffa0b1b          	addiw	s6,s4,-1
    80004b44:	1b02                	slli	s6,s6,0x20
    80004b46:	020b5b13          	srli	s6,s6,0x20
    80004b4a:	001a8793          	addi	a5,s5,1
    80004b4e:	9b3e                	add	s6,s6,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004b50:	22048993          	addi	s3,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004b54:	22448913          	addi	s2,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b58:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b5a:	2204a783          	lw	a5,544(s1)
    80004b5e:	2244a703          	lw	a4,548(s1)
    80004b62:	2007879b          	addiw	a5,a5,512
    80004b66:	02f71e63          	bne	a4,a5,80004ba2 <pipewrite+0x98>
      if(pi->readopen == 0 || myproc()->killed){
    80004b6a:	2284a783          	lw	a5,552(s1)
    80004b6e:	c3d9                	beqz	a5,80004bf4 <pipewrite+0xea>
    80004b70:	ffffd097          	auipc	ra,0xffffd
    80004b74:	ee8080e7          	jalr	-280(ra) # 80001a58 <myproc>
    80004b78:	5d1c                	lw	a5,56(a0)
    80004b7a:	efad                	bnez	a5,80004bf4 <pipewrite+0xea>
      wakeup(&pi->nread);
    80004b7c:	854e                	mv	a0,s3
    80004b7e:	ffffe097          	auipc	ra,0xffffe
    80004b82:	81a080e7          	jalr	-2022(ra) # 80002398 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b86:	85a6                	mv	a1,s1
    80004b88:	854a                	mv	a0,s2
    80004b8a:	ffffd097          	auipc	ra,0xffffd
    80004b8e:	68e080e7          	jalr	1678(ra) # 80002218 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b92:	2204a783          	lw	a5,544(s1)
    80004b96:	2244a703          	lw	a4,548(s1)
    80004b9a:	2007879b          	addiw	a5,a5,512
    80004b9e:	fcf706e3          	beq	a4,a5,80004b6a <pipewrite+0x60>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ba2:	4685                	li	a3,1
    80004ba4:	8656                	mv	a2,s5
    80004ba6:	faf40593          	addi	a1,s0,-81
    80004baa:	058bb503          	ld	a0,88(s7) # 1058 <_entry-0x7fffefa8>
    80004bae:	ffffd097          	auipc	ra,0xffffd
    80004bb2:	c28080e7          	jalr	-984(ra) # 800017d6 <copyin>
    80004bb6:	03850263          	beq	a0,s8,80004bda <pipewrite+0xd0>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004bba:	2244a783          	lw	a5,548(s1)
    80004bbe:	0017871b          	addiw	a4,a5,1
    80004bc2:	22e4a223          	sw	a4,548(s1)
    80004bc6:	1ff7f793          	andi	a5,a5,511
    80004bca:	97a6                	add	a5,a5,s1
    80004bcc:	faf44703          	lbu	a4,-81(s0)
    80004bd0:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004bd4:	0a85                	addi	s5,s5,1
    80004bd6:	f96a92e3          	bne	s5,s6,80004b5a <pipewrite+0x50>
  }
  wakeup(&pi->nread);
    80004bda:	22048513          	addi	a0,s1,544
    80004bde:	ffffd097          	auipc	ra,0xffffd
    80004be2:	7ba080e7          	jalr	1978(ra) # 80002398 <wakeup>
  release(&pi->lock);
    80004be6:	8526                	mv	a0,s1
    80004be8:	ffffc097          	auipc	ra,0xffffc
    80004bec:	f88080e7          	jalr	-120(ra) # 80000b70 <release>
  return n;
    80004bf0:	8552                	mv	a0,s4
    80004bf2:	a039                	j	80004c00 <pipewrite+0xf6>
        release(&pi->lock);
    80004bf4:	8526                	mv	a0,s1
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	f7a080e7          	jalr	-134(ra) # 80000b70 <release>
        return -1;
    80004bfe:	557d                	li	a0,-1
}
    80004c00:	60e6                	ld	ra,88(sp)
    80004c02:	6446                	ld	s0,80(sp)
    80004c04:	64a6                	ld	s1,72(sp)
    80004c06:	6906                	ld	s2,64(sp)
    80004c08:	79e2                	ld	s3,56(sp)
    80004c0a:	7a42                	ld	s4,48(sp)
    80004c0c:	7aa2                	ld	s5,40(sp)
    80004c0e:	7b02                	ld	s6,32(sp)
    80004c10:	6be2                	ld	s7,24(sp)
    80004c12:	6c42                	ld	s8,16(sp)
    80004c14:	6125                	addi	sp,sp,96
    80004c16:	8082                	ret

0000000080004c18 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c18:	715d                	addi	sp,sp,-80
    80004c1a:	e486                	sd	ra,72(sp)
    80004c1c:	e0a2                	sd	s0,64(sp)
    80004c1e:	fc26                	sd	s1,56(sp)
    80004c20:	f84a                	sd	s2,48(sp)
    80004c22:	f44e                	sd	s3,40(sp)
    80004c24:	f052                	sd	s4,32(sp)
    80004c26:	ec56                	sd	s5,24(sp)
    80004c28:	e85a                	sd	s6,16(sp)
    80004c2a:	0880                	addi	s0,sp,80
    80004c2c:	84aa                	mv	s1,a0
    80004c2e:	892e                	mv	s2,a1
    80004c30:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004c32:	ffffd097          	auipc	ra,0xffffd
    80004c36:	e26080e7          	jalr	-474(ra) # 80001a58 <myproc>
    80004c3a:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004c3c:	8526                	mv	a0,s1
    80004c3e:	ffffc097          	auipc	ra,0xffffc
    80004c42:	e62080e7          	jalr	-414(ra) # 80000aa0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c46:	2204a703          	lw	a4,544(s1)
    80004c4a:	2244a783          	lw	a5,548(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c4e:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c52:	02f71763          	bne	a4,a5,80004c80 <piperead+0x68>
    80004c56:	22c4a783          	lw	a5,556(s1)
    80004c5a:	c39d                	beqz	a5,80004c80 <piperead+0x68>
    if(myproc()->killed){
    80004c5c:	ffffd097          	auipc	ra,0xffffd
    80004c60:	dfc080e7          	jalr	-516(ra) # 80001a58 <myproc>
    80004c64:	5d1c                	lw	a5,56(a0)
    80004c66:	ebc1                	bnez	a5,80004cf6 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c68:	85a6                	mv	a1,s1
    80004c6a:	854e                	mv	a0,s3
    80004c6c:	ffffd097          	auipc	ra,0xffffd
    80004c70:	5ac080e7          	jalr	1452(ra) # 80002218 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c74:	2204a703          	lw	a4,544(s1)
    80004c78:	2244a783          	lw	a5,548(s1)
    80004c7c:	fcf70de3          	beq	a4,a5,80004c56 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c80:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c82:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c84:	05405363          	blez	s4,80004cca <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004c88:	2204a783          	lw	a5,544(s1)
    80004c8c:	2244a703          	lw	a4,548(s1)
    80004c90:	02f70d63          	beq	a4,a5,80004cca <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c94:	0017871b          	addiw	a4,a5,1
    80004c98:	22e4a023          	sw	a4,544(s1)
    80004c9c:	1ff7f793          	andi	a5,a5,511
    80004ca0:	97a6                	add	a5,a5,s1
    80004ca2:	0207c783          	lbu	a5,32(a5)
    80004ca6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004caa:	4685                	li	a3,1
    80004cac:	fbf40613          	addi	a2,s0,-65
    80004cb0:	85ca                	mv	a1,s2
    80004cb2:	058ab503          	ld	a0,88(s5)
    80004cb6:	ffffd097          	auipc	ra,0xffffd
    80004cba:	a94080e7          	jalr	-1388(ra) # 8000174a <copyout>
    80004cbe:	01650663          	beq	a0,s6,80004cca <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cc2:	2985                	addiw	s3,s3,1
    80004cc4:	0905                	addi	s2,s2,1
    80004cc6:	fd3a11e3          	bne	s4,s3,80004c88 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004cca:	22448513          	addi	a0,s1,548
    80004cce:	ffffd097          	auipc	ra,0xffffd
    80004cd2:	6ca080e7          	jalr	1738(ra) # 80002398 <wakeup>
  release(&pi->lock);
    80004cd6:	8526                	mv	a0,s1
    80004cd8:	ffffc097          	auipc	ra,0xffffc
    80004cdc:	e98080e7          	jalr	-360(ra) # 80000b70 <release>
  return i;
}
    80004ce0:	854e                	mv	a0,s3
    80004ce2:	60a6                	ld	ra,72(sp)
    80004ce4:	6406                	ld	s0,64(sp)
    80004ce6:	74e2                	ld	s1,56(sp)
    80004ce8:	7942                	ld	s2,48(sp)
    80004cea:	79a2                	ld	s3,40(sp)
    80004cec:	7a02                	ld	s4,32(sp)
    80004cee:	6ae2                	ld	s5,24(sp)
    80004cf0:	6b42                	ld	s6,16(sp)
    80004cf2:	6161                	addi	sp,sp,80
    80004cf4:	8082                	ret
      release(&pi->lock);
    80004cf6:	8526                	mv	a0,s1
    80004cf8:	ffffc097          	auipc	ra,0xffffc
    80004cfc:	e78080e7          	jalr	-392(ra) # 80000b70 <release>
      return -1;
    80004d00:	59fd                	li	s3,-1
    80004d02:	bff9                	j	80004ce0 <piperead+0xc8>

0000000080004d04 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004d04:	de010113          	addi	sp,sp,-544
    80004d08:	20113c23          	sd	ra,536(sp)
    80004d0c:	20813823          	sd	s0,528(sp)
    80004d10:	20913423          	sd	s1,520(sp)
    80004d14:	21213023          	sd	s2,512(sp)
    80004d18:	ffce                	sd	s3,504(sp)
    80004d1a:	fbd2                	sd	s4,496(sp)
    80004d1c:	f7d6                	sd	s5,488(sp)
    80004d1e:	f3da                	sd	s6,480(sp)
    80004d20:	efde                	sd	s7,472(sp)
    80004d22:	ebe2                	sd	s8,464(sp)
    80004d24:	e7e6                	sd	s9,456(sp)
    80004d26:	e3ea                	sd	s10,448(sp)
    80004d28:	ff6e                	sd	s11,440(sp)
    80004d2a:	1400                	addi	s0,sp,544
    80004d2c:	892a                	mv	s2,a0
    80004d2e:	dea43423          	sd	a0,-536(s0)
    80004d32:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d36:	ffffd097          	auipc	ra,0xffffd
    80004d3a:	d22080e7          	jalr	-734(ra) # 80001a58 <myproc>
    80004d3e:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    80004d40:	4501                	li	a0,0
    80004d42:	fffff097          	auipc	ra,0xfffff
    80004d46:	382080e7          	jalr	898(ra) # 800040c4 <begin_op>

  if((ip = namei(path)) == 0){
    80004d4a:	854a                	mv	a0,s2
    80004d4c:	fffff097          	auipc	ra,0xfffff
    80004d50:	11e080e7          	jalr	286(ra) # 80003e6a <namei>
    80004d54:	cd25                	beqz	a0,80004dcc <exec+0xc8>
    80004d56:	8aaa                	mv	s5,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004d58:	fffff097          	auipc	ra,0xfffff
    80004d5c:	988080e7          	jalr	-1656(ra) # 800036e0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d60:	04000713          	li	a4,64
    80004d64:	4681                	li	a3,0
    80004d66:	e4840613          	addi	a2,s0,-440
    80004d6a:	4581                	li	a1,0
    80004d6c:	8556                	mv	a0,s5
    80004d6e:	fffff097          	auipc	ra,0xfffff
    80004d72:	c02080e7          	jalr	-1022(ra) # 80003970 <readi>
    80004d76:	04000793          	li	a5,64
    80004d7a:	00f51a63          	bne	a0,a5,80004d8e <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004d7e:	e4842703          	lw	a4,-440(s0)
    80004d82:	464c47b7          	lui	a5,0x464c4
    80004d86:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d8a:	04f70863          	beq	a4,a5,80004dda <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d8e:	8556                	mv	a0,s5
    80004d90:	fffff097          	auipc	ra,0xfffff
    80004d94:	b8e080e7          	jalr	-1138(ra) # 8000391e <iunlockput>
    end_op(ROOTDEV);
    80004d98:	4501                	li	a0,0
    80004d9a:	fffff097          	auipc	ra,0xfffff
    80004d9e:	3d4080e7          	jalr	980(ra) # 8000416e <end_op>
  }
  return -1;
    80004da2:	557d                	li	a0,-1
}
    80004da4:	21813083          	ld	ra,536(sp)
    80004da8:	21013403          	ld	s0,528(sp)
    80004dac:	20813483          	ld	s1,520(sp)
    80004db0:	20013903          	ld	s2,512(sp)
    80004db4:	79fe                	ld	s3,504(sp)
    80004db6:	7a5e                	ld	s4,496(sp)
    80004db8:	7abe                	ld	s5,488(sp)
    80004dba:	7b1e                	ld	s6,480(sp)
    80004dbc:	6bfe                	ld	s7,472(sp)
    80004dbe:	6c5e                	ld	s8,464(sp)
    80004dc0:	6cbe                	ld	s9,456(sp)
    80004dc2:	6d1e                	ld	s10,448(sp)
    80004dc4:	7dfa                	ld	s11,440(sp)
    80004dc6:	22010113          	addi	sp,sp,544
    80004dca:	8082                	ret
    end_op(ROOTDEV);
    80004dcc:	4501                	li	a0,0
    80004dce:	fffff097          	auipc	ra,0xfffff
    80004dd2:	3a0080e7          	jalr	928(ra) # 8000416e <end_op>
    return -1;
    80004dd6:	557d                	li	a0,-1
    80004dd8:	b7f1                	j	80004da4 <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    80004dda:	8526                	mv	a0,s1
    80004ddc:	ffffd097          	auipc	ra,0xffffd
    80004de0:	d40080e7          	jalr	-704(ra) # 80001b1c <proc_pagetable>
    80004de4:	8b2a                	mv	s6,a0
    80004de6:	d545                	beqz	a0,80004d8e <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004de8:	e6842783          	lw	a5,-408(s0)
    80004dec:	e8045703          	lhu	a4,-384(s0)
    80004df0:	10070263          	beqz	a4,80004ef4 <exec+0x1f0>
  sz = 0;
    80004df4:	de043c23          	sd	zero,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004df8:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004dfc:	6a05                	lui	s4,0x1
    80004dfe:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004e02:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004e06:	6d85                	lui	s11,0x1
    80004e08:	7d7d                	lui	s10,0xfffff
    80004e0a:	a88d                	j	80004e7c <exec+0x178>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e0c:	00004517          	auipc	a0,0x4
    80004e10:	c4c50513          	addi	a0,a0,-948 # 80008a58 <userret+0x9c8>
    80004e14:	ffffb097          	auipc	ra,0xffffb
    80004e18:	740080e7          	jalr	1856(ra) # 80000554 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e1c:	874a                	mv	a4,s2
    80004e1e:	009c86bb          	addw	a3,s9,s1
    80004e22:	4581                	li	a1,0
    80004e24:	8556                	mv	a0,s5
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	b4a080e7          	jalr	-1206(ra) # 80003970 <readi>
    80004e2e:	2501                	sext.w	a0,a0
    80004e30:	10a91863          	bne	s2,a0,80004f40 <exec+0x23c>
  for(i = 0; i < sz; i += PGSIZE){
    80004e34:	009d84bb          	addw	s1,s11,s1
    80004e38:	013d09bb          	addw	s3,s10,s3
    80004e3c:	0374f263          	bgeu	s1,s7,80004e60 <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    80004e40:	02049593          	slli	a1,s1,0x20
    80004e44:	9181                	srli	a1,a1,0x20
    80004e46:	95e2                	add	a1,a1,s8
    80004e48:	855a                	mv	a0,s6
    80004e4a:	ffffc097          	auipc	ra,0xffffc
    80004e4e:	31e080e7          	jalr	798(ra) # 80001168 <walkaddr>
    80004e52:	862a                	mv	a2,a0
    if(pa == 0)
    80004e54:	dd45                	beqz	a0,80004e0c <exec+0x108>
      n = PGSIZE;
    80004e56:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004e58:	fd49f2e3          	bgeu	s3,s4,80004e1c <exec+0x118>
      n = sz - i;
    80004e5c:	894e                	mv	s2,s3
    80004e5e:	bf7d                	j	80004e1c <exec+0x118>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e60:	e0843783          	ld	a5,-504(s0)
    80004e64:	0017869b          	addiw	a3,a5,1
    80004e68:	e0d43423          	sd	a3,-504(s0)
    80004e6c:	e0043783          	ld	a5,-512(s0)
    80004e70:	0387879b          	addiw	a5,a5,56
    80004e74:	e8045703          	lhu	a4,-384(s0)
    80004e78:	08e6d063          	bge	a3,a4,80004ef8 <exec+0x1f4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e7c:	2781                	sext.w	a5,a5
    80004e7e:	e0f43023          	sd	a5,-512(s0)
    80004e82:	03800713          	li	a4,56
    80004e86:	86be                	mv	a3,a5
    80004e88:	e1040613          	addi	a2,s0,-496
    80004e8c:	4581                	li	a1,0
    80004e8e:	8556                	mv	a0,s5
    80004e90:	fffff097          	auipc	ra,0xfffff
    80004e94:	ae0080e7          	jalr	-1312(ra) # 80003970 <readi>
    80004e98:	03800793          	li	a5,56
    80004e9c:	0af51263          	bne	a0,a5,80004f40 <exec+0x23c>
    if(ph.type != ELF_PROG_LOAD)
    80004ea0:	e1042783          	lw	a5,-496(s0)
    80004ea4:	4705                	li	a4,1
    80004ea6:	fae79de3          	bne	a5,a4,80004e60 <exec+0x15c>
    if(ph.memsz < ph.filesz)
    80004eaa:	e3843603          	ld	a2,-456(s0)
    80004eae:	e3043783          	ld	a5,-464(s0)
    80004eb2:	08f66763          	bltu	a2,a5,80004f40 <exec+0x23c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004eb6:	e2043783          	ld	a5,-480(s0)
    80004eba:	963e                	add	a2,a2,a5
    80004ebc:	08f66263          	bltu	a2,a5,80004f40 <exec+0x23c>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004ec0:	df843583          	ld	a1,-520(s0)
    80004ec4:	855a                	mv	a0,s6
    80004ec6:	ffffc097          	auipc	ra,0xffffc
    80004eca:	6aa080e7          	jalr	1706(ra) # 80001570 <uvmalloc>
    80004ece:	dea43c23          	sd	a0,-520(s0)
    80004ed2:	c53d                	beqz	a0,80004f40 <exec+0x23c>
    if(ph.vaddr % PGSIZE != 0)
    80004ed4:	e2043c03          	ld	s8,-480(s0)
    80004ed8:	de043783          	ld	a5,-544(s0)
    80004edc:	00fc77b3          	and	a5,s8,a5
    80004ee0:	e3a5                	bnez	a5,80004f40 <exec+0x23c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ee2:	e1842c83          	lw	s9,-488(s0)
    80004ee6:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004eea:	f60b8be3          	beqz	s7,80004e60 <exec+0x15c>
    80004eee:	89de                	mv	s3,s7
    80004ef0:	4481                	li	s1,0
    80004ef2:	b7b9                	j	80004e40 <exec+0x13c>
  sz = 0;
    80004ef4:	de043c23          	sd	zero,-520(s0)
  iunlockput(ip);
    80004ef8:	8556                	mv	a0,s5
    80004efa:	fffff097          	auipc	ra,0xfffff
    80004efe:	a24080e7          	jalr	-1500(ra) # 8000391e <iunlockput>
  end_op(ROOTDEV);
    80004f02:	4501                	li	a0,0
    80004f04:	fffff097          	auipc	ra,0xfffff
    80004f08:	26a080e7          	jalr	618(ra) # 8000416e <end_op>
  p = myproc();
    80004f0c:	ffffd097          	auipc	ra,0xffffd
    80004f10:	b4c080e7          	jalr	-1204(ra) # 80001a58 <myproc>
    80004f14:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004f16:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    80004f1a:	6585                	lui	a1,0x1
    80004f1c:	15fd                	addi	a1,a1,-1
    80004f1e:	df843783          	ld	a5,-520(s0)
    80004f22:	95be                	add	a1,a1,a5
    80004f24:	77fd                	lui	a5,0xfffff
    80004f26:	8dfd                	and	a1,a1,a5
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f28:	6609                	lui	a2,0x2
    80004f2a:	962e                	add	a2,a2,a1
    80004f2c:	855a                	mv	a0,s6
    80004f2e:	ffffc097          	auipc	ra,0xffffc
    80004f32:	642080e7          	jalr	1602(ra) # 80001570 <uvmalloc>
    80004f36:	892a                	mv	s2,a0
    80004f38:	dea43c23          	sd	a0,-520(s0)
  ip = 0;
    80004f3c:	4a81                	li	s5,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f3e:	ed01                	bnez	a0,80004f56 <exec+0x252>
    proc_freepagetable(pagetable, sz);
    80004f40:	df843583          	ld	a1,-520(s0)
    80004f44:	855a                	mv	a0,s6
    80004f46:	ffffd097          	auipc	ra,0xffffd
    80004f4a:	cd6080e7          	jalr	-810(ra) # 80001c1c <proc_freepagetable>
  if(ip){
    80004f4e:	e40a90e3          	bnez	s5,80004d8e <exec+0x8a>
  return -1;
    80004f52:	557d                	li	a0,-1
    80004f54:	bd81                	j	80004da4 <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f56:	75f9                	lui	a1,0xffffe
    80004f58:	95aa                	add	a1,a1,a0
    80004f5a:	855a                	mv	a0,s6
    80004f5c:	ffffc097          	auipc	ra,0xffffc
    80004f60:	7bc080e7          	jalr	1980(ra) # 80001718 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f64:	7c7d                	lui	s8,0xfffff
    80004f66:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    80004f68:	df043783          	ld	a5,-528(s0)
    80004f6c:	6388                	ld	a0,0(a5)
    80004f6e:	c52d                	beqz	a0,80004fd8 <exec+0x2d4>
    80004f70:	e8840993          	addi	s3,s0,-376
    80004f74:	f8840a93          	addi	s5,s0,-120
    80004f78:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004f7a:	ffffc097          	auipc	ra,0xffffc
    80004f7e:	f78080e7          	jalr	-136(ra) # 80000ef2 <strlen>
    80004f82:	0015079b          	addiw	a5,a0,1
    80004f86:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f8a:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004f8e:	0f896b63          	bltu	s2,s8,80005084 <exec+0x380>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f92:	df043d03          	ld	s10,-528(s0)
    80004f96:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7ffd6fa4>
    80004f9a:	8552                	mv	a0,s4
    80004f9c:	ffffc097          	auipc	ra,0xffffc
    80004fa0:	f56080e7          	jalr	-170(ra) # 80000ef2 <strlen>
    80004fa4:	0015069b          	addiw	a3,a0,1
    80004fa8:	8652                	mv	a2,s4
    80004faa:	85ca                	mv	a1,s2
    80004fac:	855a                	mv	a0,s6
    80004fae:	ffffc097          	auipc	ra,0xffffc
    80004fb2:	79c080e7          	jalr	1948(ra) # 8000174a <copyout>
    80004fb6:	0c054963          	bltz	a0,80005088 <exec+0x384>
    ustack[argc] = sp;
    80004fba:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004fbe:	0485                	addi	s1,s1,1
    80004fc0:	008d0793          	addi	a5,s10,8
    80004fc4:	def43823          	sd	a5,-528(s0)
    80004fc8:	008d3503          	ld	a0,8(s10)
    80004fcc:	c909                	beqz	a0,80004fde <exec+0x2da>
    if(argc >= MAXARG)
    80004fce:	09a1                	addi	s3,s3,8
    80004fd0:	fb3a95e3          	bne	s5,s3,80004f7a <exec+0x276>
  ip = 0;
    80004fd4:	4a81                	li	s5,0
    80004fd6:	b7ad                	j	80004f40 <exec+0x23c>
  sp = sz;
    80004fd8:	df843903          	ld	s2,-520(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004fdc:	4481                	li	s1,0
  ustack[argc] = 0;
    80004fde:	00349793          	slli	a5,s1,0x3
    80004fe2:	f9040713          	addi	a4,s0,-112
    80004fe6:	97ba                	add	a5,a5,a4
    80004fe8:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd6e9c>
  sp -= (argc+1) * sizeof(uint64);
    80004fec:	00148693          	addi	a3,s1,1
    80004ff0:	068e                	slli	a3,a3,0x3
    80004ff2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ff6:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80004ffa:	4a81                	li	s5,0
  if(sp < stackbase)
    80004ffc:	f58962e3          	bltu	s2,s8,80004f40 <exec+0x23c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005000:	e8840613          	addi	a2,s0,-376
    80005004:	85ca                	mv	a1,s2
    80005006:	855a                	mv	a0,s6
    80005008:	ffffc097          	auipc	ra,0xffffc
    8000500c:	742080e7          	jalr	1858(ra) # 8000174a <copyout>
    80005010:	06054e63          	bltz	a0,8000508c <exec+0x388>
  p->tf->a1 = sp;
    80005014:	060bb783          	ld	a5,96(s7)
    80005018:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000501c:	de843783          	ld	a5,-536(s0)
    80005020:	0007c703          	lbu	a4,0(a5)
    80005024:	cf11                	beqz	a4,80005040 <exec+0x33c>
    80005026:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005028:	02f00693          	li	a3,47
    8000502c:	a039                	j	8000503a <exec+0x336>
      last = s+1;
    8000502e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005032:	0785                	addi	a5,a5,1
    80005034:	fff7c703          	lbu	a4,-1(a5)
    80005038:	c701                	beqz	a4,80005040 <exec+0x33c>
    if(*s == '/')
    8000503a:	fed71ce3          	bne	a4,a3,80005032 <exec+0x32e>
    8000503e:	bfc5                	j	8000502e <exec+0x32a>
  safestrcpy(p->name, last, sizeof(p->name));
    80005040:	4641                	li	a2,16
    80005042:	de843583          	ld	a1,-536(s0)
    80005046:	160b8513          	addi	a0,s7,352
    8000504a:	ffffc097          	auipc	ra,0xffffc
    8000504e:	e76080e7          	jalr	-394(ra) # 80000ec0 <safestrcpy>
  oldpagetable = p->pagetable;
    80005052:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80005056:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    8000505a:	df843783          	ld	a5,-520(s0)
    8000505e:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80005062:	060bb783          	ld	a5,96(s7)
    80005066:	e6043703          	ld	a4,-416(s0)
    8000506a:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    8000506c:	060bb783          	ld	a5,96(s7)
    80005070:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005074:	85e6                	mv	a1,s9
    80005076:	ffffd097          	auipc	ra,0xffffd
    8000507a:	ba6080e7          	jalr	-1114(ra) # 80001c1c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000507e:	0004851b          	sext.w	a0,s1
    80005082:	b30d                	j	80004da4 <exec+0xa0>
  ip = 0;
    80005084:	4a81                	li	s5,0
    80005086:	bd6d                	j	80004f40 <exec+0x23c>
    80005088:	4a81                	li	s5,0
    8000508a:	bd5d                	j	80004f40 <exec+0x23c>
    8000508c:	4a81                	li	s5,0
    8000508e:	bd4d                	j	80004f40 <exec+0x23c>

0000000080005090 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005090:	7179                	addi	sp,sp,-48
    80005092:	f406                	sd	ra,40(sp)
    80005094:	f022                	sd	s0,32(sp)
    80005096:	ec26                	sd	s1,24(sp)
    80005098:	e84a                	sd	s2,16(sp)
    8000509a:	1800                	addi	s0,sp,48
    8000509c:	892e                	mv	s2,a1
    8000509e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800050a0:	fdc40593          	addi	a1,s0,-36
    800050a4:	ffffe097          	auipc	ra,0xffffe
    800050a8:	ac8080e7          	jalr	-1336(ra) # 80002b6c <argint>
    800050ac:	04054063          	bltz	a0,800050ec <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800050b0:	fdc42703          	lw	a4,-36(s0)
    800050b4:	47bd                	li	a5,15
    800050b6:	02e7ed63          	bltu	a5,a4,800050f0 <argfd+0x60>
    800050ba:	ffffd097          	auipc	ra,0xffffd
    800050be:	99e080e7          	jalr	-1634(ra) # 80001a58 <myproc>
    800050c2:	fdc42703          	lw	a4,-36(s0)
    800050c6:	01a70793          	addi	a5,a4,26
    800050ca:	078e                	slli	a5,a5,0x3
    800050cc:	953e                	add	a0,a0,a5
    800050ce:	651c                	ld	a5,8(a0)
    800050d0:	c395                	beqz	a5,800050f4 <argfd+0x64>
    return -1;
  if(pfd)
    800050d2:	00090463          	beqz	s2,800050da <argfd+0x4a>
    *pfd = fd;
    800050d6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800050da:	4501                	li	a0,0
  if(pf)
    800050dc:	c091                	beqz	s1,800050e0 <argfd+0x50>
    *pf = f;
    800050de:	e09c                	sd	a5,0(s1)
}
    800050e0:	70a2                	ld	ra,40(sp)
    800050e2:	7402                	ld	s0,32(sp)
    800050e4:	64e2                	ld	s1,24(sp)
    800050e6:	6942                	ld	s2,16(sp)
    800050e8:	6145                	addi	sp,sp,48
    800050ea:	8082                	ret
    return -1;
    800050ec:	557d                	li	a0,-1
    800050ee:	bfcd                	j	800050e0 <argfd+0x50>
    return -1;
    800050f0:	557d                	li	a0,-1
    800050f2:	b7fd                	j	800050e0 <argfd+0x50>
    800050f4:	557d                	li	a0,-1
    800050f6:	b7ed                	j	800050e0 <argfd+0x50>

00000000800050f8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050f8:	1101                	addi	sp,sp,-32
    800050fa:	ec06                	sd	ra,24(sp)
    800050fc:	e822                	sd	s0,16(sp)
    800050fe:	e426                	sd	s1,8(sp)
    80005100:	1000                	addi	s0,sp,32
    80005102:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005104:	ffffd097          	auipc	ra,0xffffd
    80005108:	954080e7          	jalr	-1708(ra) # 80001a58 <myproc>
    8000510c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000510e:	0d850793          	addi	a5,a0,216
    80005112:	4501                	li	a0,0
    80005114:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005116:	6398                	ld	a4,0(a5)
    80005118:	cb19                	beqz	a4,8000512e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000511a:	2505                	addiw	a0,a0,1
    8000511c:	07a1                	addi	a5,a5,8
    8000511e:	fed51ce3          	bne	a0,a3,80005116 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005122:	557d                	li	a0,-1
}
    80005124:	60e2                	ld	ra,24(sp)
    80005126:	6442                	ld	s0,16(sp)
    80005128:	64a2                	ld	s1,8(sp)
    8000512a:	6105                	addi	sp,sp,32
    8000512c:	8082                	ret
      p->ofile[fd] = f;
    8000512e:	01a50793          	addi	a5,a0,26
    80005132:	078e                	slli	a5,a5,0x3
    80005134:	963e                	add	a2,a2,a5
    80005136:	e604                	sd	s1,8(a2)
      return fd;
    80005138:	b7f5                	j	80005124 <fdalloc+0x2c>

000000008000513a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000513a:	715d                	addi	sp,sp,-80
    8000513c:	e486                	sd	ra,72(sp)
    8000513e:	e0a2                	sd	s0,64(sp)
    80005140:	fc26                	sd	s1,56(sp)
    80005142:	f84a                	sd	s2,48(sp)
    80005144:	f44e                	sd	s3,40(sp)
    80005146:	f052                	sd	s4,32(sp)
    80005148:	ec56                	sd	s5,24(sp)
    8000514a:	0880                	addi	s0,sp,80
    8000514c:	89ae                	mv	s3,a1
    8000514e:	8ab2                	mv	s5,a2
    80005150:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005152:	fb040593          	addi	a1,s0,-80
    80005156:	fffff097          	auipc	ra,0xfffff
    8000515a:	d32080e7          	jalr	-718(ra) # 80003e88 <nameiparent>
    8000515e:	892a                	mv	s2,a0
    80005160:	12050e63          	beqz	a0,8000529c <create+0x162>
    return 0;

  ilock(dp);
    80005164:	ffffe097          	auipc	ra,0xffffe
    80005168:	57c080e7          	jalr	1404(ra) # 800036e0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000516c:	4601                	li	a2,0
    8000516e:	fb040593          	addi	a1,s0,-80
    80005172:	854a                	mv	a0,s2
    80005174:	fffff097          	auipc	ra,0xfffff
    80005178:	a24080e7          	jalr	-1500(ra) # 80003b98 <dirlookup>
    8000517c:	84aa                	mv	s1,a0
    8000517e:	c921                	beqz	a0,800051ce <create+0x94>
    iunlockput(dp);
    80005180:	854a                	mv	a0,s2
    80005182:	ffffe097          	auipc	ra,0xffffe
    80005186:	79c080e7          	jalr	1948(ra) # 8000391e <iunlockput>
    ilock(ip);
    8000518a:	8526                	mv	a0,s1
    8000518c:	ffffe097          	auipc	ra,0xffffe
    80005190:	554080e7          	jalr	1364(ra) # 800036e0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005194:	2981                	sext.w	s3,s3
    80005196:	4789                	li	a5,2
    80005198:	02f99463          	bne	s3,a5,800051c0 <create+0x86>
    8000519c:	04c4d783          	lhu	a5,76(s1)
    800051a0:	37f9                	addiw	a5,a5,-2
    800051a2:	17c2                	slli	a5,a5,0x30
    800051a4:	93c1                	srli	a5,a5,0x30
    800051a6:	4705                	li	a4,1
    800051a8:	00f76c63          	bltu	a4,a5,800051c0 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800051ac:	8526                	mv	a0,s1
    800051ae:	60a6                	ld	ra,72(sp)
    800051b0:	6406                	ld	s0,64(sp)
    800051b2:	74e2                	ld	s1,56(sp)
    800051b4:	7942                	ld	s2,48(sp)
    800051b6:	79a2                	ld	s3,40(sp)
    800051b8:	7a02                	ld	s4,32(sp)
    800051ba:	6ae2                	ld	s5,24(sp)
    800051bc:	6161                	addi	sp,sp,80
    800051be:	8082                	ret
    iunlockput(ip);
    800051c0:	8526                	mv	a0,s1
    800051c2:	ffffe097          	auipc	ra,0xffffe
    800051c6:	75c080e7          	jalr	1884(ra) # 8000391e <iunlockput>
    return 0;
    800051ca:	4481                	li	s1,0
    800051cc:	b7c5                	j	800051ac <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800051ce:	85ce                	mv	a1,s3
    800051d0:	00092503          	lw	a0,0(s2)
    800051d4:	ffffe097          	auipc	ra,0xffffe
    800051d8:	374080e7          	jalr	884(ra) # 80003548 <ialloc>
    800051dc:	84aa                	mv	s1,a0
    800051de:	c521                	beqz	a0,80005226 <create+0xec>
  ilock(ip);
    800051e0:	ffffe097          	auipc	ra,0xffffe
    800051e4:	500080e7          	jalr	1280(ra) # 800036e0 <ilock>
  ip->major = major;
    800051e8:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    800051ec:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    800051f0:	4a05                	li	s4,1
    800051f2:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    800051f6:	8526                	mv	a0,s1
    800051f8:	ffffe097          	auipc	ra,0xffffe
    800051fc:	41e080e7          	jalr	1054(ra) # 80003616 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005200:	2981                	sext.w	s3,s3
    80005202:	03498a63          	beq	s3,s4,80005236 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005206:	40d0                	lw	a2,4(s1)
    80005208:	fb040593          	addi	a1,s0,-80
    8000520c:	854a                	mv	a0,s2
    8000520e:	fffff097          	auipc	ra,0xfffff
    80005212:	b9a080e7          	jalr	-1126(ra) # 80003da8 <dirlink>
    80005216:	06054b63          	bltz	a0,8000528c <create+0x152>
  iunlockput(dp);
    8000521a:	854a                	mv	a0,s2
    8000521c:	ffffe097          	auipc	ra,0xffffe
    80005220:	702080e7          	jalr	1794(ra) # 8000391e <iunlockput>
  return ip;
    80005224:	b761                	j	800051ac <create+0x72>
    panic("create: ialloc");
    80005226:	00004517          	auipc	a0,0x4
    8000522a:	85250513          	addi	a0,a0,-1966 # 80008a78 <userret+0x9e8>
    8000522e:	ffffb097          	auipc	ra,0xffffb
    80005232:	326080e7          	jalr	806(ra) # 80000554 <panic>
    dp->nlink++;  // for ".."
    80005236:	05295783          	lhu	a5,82(s2)
    8000523a:	2785                	addiw	a5,a5,1
    8000523c:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    80005240:	854a                	mv	a0,s2
    80005242:	ffffe097          	auipc	ra,0xffffe
    80005246:	3d4080e7          	jalr	980(ra) # 80003616 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000524a:	40d0                	lw	a2,4(s1)
    8000524c:	00004597          	auipc	a1,0x4
    80005250:	83c58593          	addi	a1,a1,-1988 # 80008a88 <userret+0x9f8>
    80005254:	8526                	mv	a0,s1
    80005256:	fffff097          	auipc	ra,0xfffff
    8000525a:	b52080e7          	jalr	-1198(ra) # 80003da8 <dirlink>
    8000525e:	00054f63          	bltz	a0,8000527c <create+0x142>
    80005262:	00492603          	lw	a2,4(s2)
    80005266:	00004597          	auipc	a1,0x4
    8000526a:	82a58593          	addi	a1,a1,-2006 # 80008a90 <userret+0xa00>
    8000526e:	8526                	mv	a0,s1
    80005270:	fffff097          	auipc	ra,0xfffff
    80005274:	b38080e7          	jalr	-1224(ra) # 80003da8 <dirlink>
    80005278:	f80557e3          	bgez	a0,80005206 <create+0xcc>
      panic("create dots");
    8000527c:	00004517          	auipc	a0,0x4
    80005280:	81c50513          	addi	a0,a0,-2020 # 80008a98 <userret+0xa08>
    80005284:	ffffb097          	auipc	ra,0xffffb
    80005288:	2d0080e7          	jalr	720(ra) # 80000554 <panic>
    panic("create: dirlink");
    8000528c:	00004517          	auipc	a0,0x4
    80005290:	81c50513          	addi	a0,a0,-2020 # 80008aa8 <userret+0xa18>
    80005294:	ffffb097          	auipc	ra,0xffffb
    80005298:	2c0080e7          	jalr	704(ra) # 80000554 <panic>
    return 0;
    8000529c:	84aa                	mv	s1,a0
    8000529e:	b739                	j	800051ac <create+0x72>

00000000800052a0 <sys_dup>:
{
    800052a0:	7179                	addi	sp,sp,-48
    800052a2:	f406                	sd	ra,40(sp)
    800052a4:	f022                	sd	s0,32(sp)
    800052a6:	ec26                	sd	s1,24(sp)
    800052a8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800052aa:	fd840613          	addi	a2,s0,-40
    800052ae:	4581                	li	a1,0
    800052b0:	4501                	li	a0,0
    800052b2:	00000097          	auipc	ra,0x0
    800052b6:	dde080e7          	jalr	-546(ra) # 80005090 <argfd>
    return -1;
    800052ba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800052bc:	02054363          	bltz	a0,800052e2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800052c0:	fd843503          	ld	a0,-40(s0)
    800052c4:	00000097          	auipc	ra,0x0
    800052c8:	e34080e7          	jalr	-460(ra) # 800050f8 <fdalloc>
    800052cc:	84aa                	mv	s1,a0
    return -1;
    800052ce:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800052d0:	00054963          	bltz	a0,800052e2 <sys_dup+0x42>
  filedup(f);
    800052d4:	fd843503          	ld	a0,-40(s0)
    800052d8:	fffff097          	auipc	ra,0xfffff
    800052dc:	334080e7          	jalr	820(ra) # 8000460c <filedup>
  return fd;
    800052e0:	87a6                	mv	a5,s1
}
    800052e2:	853e                	mv	a0,a5
    800052e4:	70a2                	ld	ra,40(sp)
    800052e6:	7402                	ld	s0,32(sp)
    800052e8:	64e2                	ld	s1,24(sp)
    800052ea:	6145                	addi	sp,sp,48
    800052ec:	8082                	ret

00000000800052ee <sys_read>:
{
    800052ee:	7179                	addi	sp,sp,-48
    800052f0:	f406                	sd	ra,40(sp)
    800052f2:	f022                	sd	s0,32(sp)
    800052f4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052f6:	fe840613          	addi	a2,s0,-24
    800052fa:	4581                	li	a1,0
    800052fc:	4501                	li	a0,0
    800052fe:	00000097          	auipc	ra,0x0
    80005302:	d92080e7          	jalr	-622(ra) # 80005090 <argfd>
    return -1;
    80005306:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005308:	04054163          	bltz	a0,8000534a <sys_read+0x5c>
    8000530c:	fe440593          	addi	a1,s0,-28
    80005310:	4509                	li	a0,2
    80005312:	ffffe097          	auipc	ra,0xffffe
    80005316:	85a080e7          	jalr	-1958(ra) # 80002b6c <argint>
    return -1;
    8000531a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000531c:	02054763          	bltz	a0,8000534a <sys_read+0x5c>
    80005320:	fd840593          	addi	a1,s0,-40
    80005324:	4505                	li	a0,1
    80005326:	ffffe097          	auipc	ra,0xffffe
    8000532a:	868080e7          	jalr	-1944(ra) # 80002b8e <argaddr>
    return -1;
    8000532e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005330:	00054d63          	bltz	a0,8000534a <sys_read+0x5c>
  return fileread(f, p, n);
    80005334:	fe442603          	lw	a2,-28(s0)
    80005338:	fd843583          	ld	a1,-40(s0)
    8000533c:	fe843503          	ld	a0,-24(s0)
    80005340:	fffff097          	auipc	ra,0xfffff
    80005344:	460080e7          	jalr	1120(ra) # 800047a0 <fileread>
    80005348:	87aa                	mv	a5,a0
}
    8000534a:	853e                	mv	a0,a5
    8000534c:	70a2                	ld	ra,40(sp)
    8000534e:	7402                	ld	s0,32(sp)
    80005350:	6145                	addi	sp,sp,48
    80005352:	8082                	ret

0000000080005354 <sys_write>:
{
    80005354:	7179                	addi	sp,sp,-48
    80005356:	f406                	sd	ra,40(sp)
    80005358:	f022                	sd	s0,32(sp)
    8000535a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000535c:	fe840613          	addi	a2,s0,-24
    80005360:	4581                	li	a1,0
    80005362:	4501                	li	a0,0
    80005364:	00000097          	auipc	ra,0x0
    80005368:	d2c080e7          	jalr	-724(ra) # 80005090 <argfd>
    return -1;
    8000536c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000536e:	04054163          	bltz	a0,800053b0 <sys_write+0x5c>
    80005372:	fe440593          	addi	a1,s0,-28
    80005376:	4509                	li	a0,2
    80005378:	ffffd097          	auipc	ra,0xffffd
    8000537c:	7f4080e7          	jalr	2036(ra) # 80002b6c <argint>
    return -1;
    80005380:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005382:	02054763          	bltz	a0,800053b0 <sys_write+0x5c>
    80005386:	fd840593          	addi	a1,s0,-40
    8000538a:	4505                	li	a0,1
    8000538c:	ffffe097          	auipc	ra,0xffffe
    80005390:	802080e7          	jalr	-2046(ra) # 80002b8e <argaddr>
    return -1;
    80005394:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005396:	00054d63          	bltz	a0,800053b0 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000539a:	fe442603          	lw	a2,-28(s0)
    8000539e:	fd843583          	ld	a1,-40(s0)
    800053a2:	fe843503          	ld	a0,-24(s0)
    800053a6:	fffff097          	auipc	ra,0xfffff
    800053aa:	4c0080e7          	jalr	1216(ra) # 80004866 <filewrite>
    800053ae:	87aa                	mv	a5,a0
}
    800053b0:	853e                	mv	a0,a5
    800053b2:	70a2                	ld	ra,40(sp)
    800053b4:	7402                	ld	s0,32(sp)
    800053b6:	6145                	addi	sp,sp,48
    800053b8:	8082                	ret

00000000800053ba <sys_close>:
{
    800053ba:	1101                	addi	sp,sp,-32
    800053bc:	ec06                	sd	ra,24(sp)
    800053be:	e822                	sd	s0,16(sp)
    800053c0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800053c2:	fe040613          	addi	a2,s0,-32
    800053c6:	fec40593          	addi	a1,s0,-20
    800053ca:	4501                	li	a0,0
    800053cc:	00000097          	auipc	ra,0x0
    800053d0:	cc4080e7          	jalr	-828(ra) # 80005090 <argfd>
    return -1;
    800053d4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800053d6:	02054463          	bltz	a0,800053fe <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800053da:	ffffc097          	auipc	ra,0xffffc
    800053de:	67e080e7          	jalr	1662(ra) # 80001a58 <myproc>
    800053e2:	fec42783          	lw	a5,-20(s0)
    800053e6:	07e9                	addi	a5,a5,26
    800053e8:	078e                	slli	a5,a5,0x3
    800053ea:	97aa                	add	a5,a5,a0
    800053ec:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800053f0:	fe043503          	ld	a0,-32(s0)
    800053f4:	fffff097          	auipc	ra,0xfffff
    800053f8:	26a080e7          	jalr	618(ra) # 8000465e <fileclose>
  return 0;
    800053fc:	4781                	li	a5,0
}
    800053fe:	853e                	mv	a0,a5
    80005400:	60e2                	ld	ra,24(sp)
    80005402:	6442                	ld	s0,16(sp)
    80005404:	6105                	addi	sp,sp,32
    80005406:	8082                	ret

0000000080005408 <sys_fstat>:
{
    80005408:	1101                	addi	sp,sp,-32
    8000540a:	ec06                	sd	ra,24(sp)
    8000540c:	e822                	sd	s0,16(sp)
    8000540e:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005410:	fe840613          	addi	a2,s0,-24
    80005414:	4581                	li	a1,0
    80005416:	4501                	li	a0,0
    80005418:	00000097          	auipc	ra,0x0
    8000541c:	c78080e7          	jalr	-904(ra) # 80005090 <argfd>
    return -1;
    80005420:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005422:	02054563          	bltz	a0,8000544c <sys_fstat+0x44>
    80005426:	fe040593          	addi	a1,s0,-32
    8000542a:	4505                	li	a0,1
    8000542c:	ffffd097          	auipc	ra,0xffffd
    80005430:	762080e7          	jalr	1890(ra) # 80002b8e <argaddr>
    return -1;
    80005434:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005436:	00054b63          	bltz	a0,8000544c <sys_fstat+0x44>
  return filestat(f, st);
    8000543a:	fe043583          	ld	a1,-32(s0)
    8000543e:	fe843503          	ld	a0,-24(s0)
    80005442:	fffff097          	auipc	ra,0xfffff
    80005446:	2ec080e7          	jalr	748(ra) # 8000472e <filestat>
    8000544a:	87aa                	mv	a5,a0
}
    8000544c:	853e                	mv	a0,a5
    8000544e:	60e2                	ld	ra,24(sp)
    80005450:	6442                	ld	s0,16(sp)
    80005452:	6105                	addi	sp,sp,32
    80005454:	8082                	ret

0000000080005456 <sys_link>:
{
    80005456:	7169                	addi	sp,sp,-304
    80005458:	f606                	sd	ra,296(sp)
    8000545a:	f222                	sd	s0,288(sp)
    8000545c:	ee26                	sd	s1,280(sp)
    8000545e:	ea4a                	sd	s2,272(sp)
    80005460:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005462:	08000613          	li	a2,128
    80005466:	ed040593          	addi	a1,s0,-304
    8000546a:	4501                	li	a0,0
    8000546c:	ffffd097          	auipc	ra,0xffffd
    80005470:	744080e7          	jalr	1860(ra) # 80002bb0 <argstr>
    return -1;
    80005474:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005476:	12054363          	bltz	a0,8000559c <sys_link+0x146>
    8000547a:	08000613          	li	a2,128
    8000547e:	f5040593          	addi	a1,s0,-176
    80005482:	4505                	li	a0,1
    80005484:	ffffd097          	auipc	ra,0xffffd
    80005488:	72c080e7          	jalr	1836(ra) # 80002bb0 <argstr>
    return -1;
    8000548c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000548e:	10054763          	bltz	a0,8000559c <sys_link+0x146>
  begin_op(ROOTDEV);
    80005492:	4501                	li	a0,0
    80005494:	fffff097          	auipc	ra,0xfffff
    80005498:	c30080e7          	jalr	-976(ra) # 800040c4 <begin_op>
  if((ip = namei(old)) == 0){
    8000549c:	ed040513          	addi	a0,s0,-304
    800054a0:	fffff097          	auipc	ra,0xfffff
    800054a4:	9ca080e7          	jalr	-1590(ra) # 80003e6a <namei>
    800054a8:	84aa                	mv	s1,a0
    800054aa:	c559                	beqz	a0,80005538 <sys_link+0xe2>
  ilock(ip);
    800054ac:	ffffe097          	auipc	ra,0xffffe
    800054b0:	234080e7          	jalr	564(ra) # 800036e0 <ilock>
  if(ip->type == T_DIR){
    800054b4:	04c49703          	lh	a4,76(s1)
    800054b8:	4785                	li	a5,1
    800054ba:	08f70663          	beq	a4,a5,80005546 <sys_link+0xf0>
  ip->nlink++;
    800054be:	0524d783          	lhu	a5,82(s1)
    800054c2:	2785                	addiw	a5,a5,1
    800054c4:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800054c8:	8526                	mv	a0,s1
    800054ca:	ffffe097          	auipc	ra,0xffffe
    800054ce:	14c080e7          	jalr	332(ra) # 80003616 <iupdate>
  iunlock(ip);
    800054d2:	8526                	mv	a0,s1
    800054d4:	ffffe097          	auipc	ra,0xffffe
    800054d8:	2ce080e7          	jalr	718(ra) # 800037a2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800054dc:	fd040593          	addi	a1,s0,-48
    800054e0:	f5040513          	addi	a0,s0,-176
    800054e4:	fffff097          	auipc	ra,0xfffff
    800054e8:	9a4080e7          	jalr	-1628(ra) # 80003e88 <nameiparent>
    800054ec:	892a                	mv	s2,a0
    800054ee:	cd2d                	beqz	a0,80005568 <sys_link+0x112>
  ilock(dp);
    800054f0:	ffffe097          	auipc	ra,0xffffe
    800054f4:	1f0080e7          	jalr	496(ra) # 800036e0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800054f8:	00092703          	lw	a4,0(s2)
    800054fc:	409c                	lw	a5,0(s1)
    800054fe:	06f71063          	bne	a4,a5,8000555e <sys_link+0x108>
    80005502:	40d0                	lw	a2,4(s1)
    80005504:	fd040593          	addi	a1,s0,-48
    80005508:	854a                	mv	a0,s2
    8000550a:	fffff097          	auipc	ra,0xfffff
    8000550e:	89e080e7          	jalr	-1890(ra) # 80003da8 <dirlink>
    80005512:	04054663          	bltz	a0,8000555e <sys_link+0x108>
  iunlockput(dp);
    80005516:	854a                	mv	a0,s2
    80005518:	ffffe097          	auipc	ra,0xffffe
    8000551c:	406080e7          	jalr	1030(ra) # 8000391e <iunlockput>
  iput(ip);
    80005520:	8526                	mv	a0,s1
    80005522:	ffffe097          	auipc	ra,0xffffe
    80005526:	2cc080e7          	jalr	716(ra) # 800037ee <iput>
  end_op(ROOTDEV);
    8000552a:	4501                	li	a0,0
    8000552c:	fffff097          	auipc	ra,0xfffff
    80005530:	c42080e7          	jalr	-958(ra) # 8000416e <end_op>
  return 0;
    80005534:	4781                	li	a5,0
    80005536:	a09d                	j	8000559c <sys_link+0x146>
    end_op(ROOTDEV);
    80005538:	4501                	li	a0,0
    8000553a:	fffff097          	auipc	ra,0xfffff
    8000553e:	c34080e7          	jalr	-972(ra) # 8000416e <end_op>
    return -1;
    80005542:	57fd                	li	a5,-1
    80005544:	a8a1                	j	8000559c <sys_link+0x146>
    iunlockput(ip);
    80005546:	8526                	mv	a0,s1
    80005548:	ffffe097          	auipc	ra,0xffffe
    8000554c:	3d6080e7          	jalr	982(ra) # 8000391e <iunlockput>
    end_op(ROOTDEV);
    80005550:	4501                	li	a0,0
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	c1c080e7          	jalr	-996(ra) # 8000416e <end_op>
    return -1;
    8000555a:	57fd                	li	a5,-1
    8000555c:	a081                	j	8000559c <sys_link+0x146>
    iunlockput(dp);
    8000555e:	854a                	mv	a0,s2
    80005560:	ffffe097          	auipc	ra,0xffffe
    80005564:	3be080e7          	jalr	958(ra) # 8000391e <iunlockput>
  ilock(ip);
    80005568:	8526                	mv	a0,s1
    8000556a:	ffffe097          	auipc	ra,0xffffe
    8000556e:	176080e7          	jalr	374(ra) # 800036e0 <ilock>
  ip->nlink--;
    80005572:	0524d783          	lhu	a5,82(s1)
    80005576:	37fd                	addiw	a5,a5,-1
    80005578:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000557c:	8526                	mv	a0,s1
    8000557e:	ffffe097          	auipc	ra,0xffffe
    80005582:	098080e7          	jalr	152(ra) # 80003616 <iupdate>
  iunlockput(ip);
    80005586:	8526                	mv	a0,s1
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	396080e7          	jalr	918(ra) # 8000391e <iunlockput>
  end_op(ROOTDEV);
    80005590:	4501                	li	a0,0
    80005592:	fffff097          	auipc	ra,0xfffff
    80005596:	bdc080e7          	jalr	-1060(ra) # 8000416e <end_op>
  return -1;
    8000559a:	57fd                	li	a5,-1
}
    8000559c:	853e                	mv	a0,a5
    8000559e:	70b2                	ld	ra,296(sp)
    800055a0:	7412                	ld	s0,288(sp)
    800055a2:	64f2                	ld	s1,280(sp)
    800055a4:	6952                	ld	s2,272(sp)
    800055a6:	6155                	addi	sp,sp,304
    800055a8:	8082                	ret

00000000800055aa <sys_unlink>:
{
    800055aa:	7151                	addi	sp,sp,-240
    800055ac:	f586                	sd	ra,232(sp)
    800055ae:	f1a2                	sd	s0,224(sp)
    800055b0:	eda6                	sd	s1,216(sp)
    800055b2:	e9ca                	sd	s2,208(sp)
    800055b4:	e5ce                	sd	s3,200(sp)
    800055b6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055b8:	08000613          	li	a2,128
    800055bc:	f3040593          	addi	a1,s0,-208
    800055c0:	4501                	li	a0,0
    800055c2:	ffffd097          	auipc	ra,0xffffd
    800055c6:	5ee080e7          	jalr	1518(ra) # 80002bb0 <argstr>
    800055ca:	18054463          	bltz	a0,80005752 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    800055ce:	4501                	li	a0,0
    800055d0:	fffff097          	auipc	ra,0xfffff
    800055d4:	af4080e7          	jalr	-1292(ra) # 800040c4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800055d8:	fb040593          	addi	a1,s0,-80
    800055dc:	f3040513          	addi	a0,s0,-208
    800055e0:	fffff097          	auipc	ra,0xfffff
    800055e4:	8a8080e7          	jalr	-1880(ra) # 80003e88 <nameiparent>
    800055e8:	84aa                	mv	s1,a0
    800055ea:	cd61                	beqz	a0,800056c2 <sys_unlink+0x118>
  ilock(dp);
    800055ec:	ffffe097          	auipc	ra,0xffffe
    800055f0:	0f4080e7          	jalr	244(ra) # 800036e0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800055f4:	00003597          	auipc	a1,0x3
    800055f8:	49458593          	addi	a1,a1,1172 # 80008a88 <userret+0x9f8>
    800055fc:	fb040513          	addi	a0,s0,-80
    80005600:	ffffe097          	auipc	ra,0xffffe
    80005604:	57e080e7          	jalr	1406(ra) # 80003b7e <namecmp>
    80005608:	14050c63          	beqz	a0,80005760 <sys_unlink+0x1b6>
    8000560c:	00003597          	auipc	a1,0x3
    80005610:	48458593          	addi	a1,a1,1156 # 80008a90 <userret+0xa00>
    80005614:	fb040513          	addi	a0,s0,-80
    80005618:	ffffe097          	auipc	ra,0xffffe
    8000561c:	566080e7          	jalr	1382(ra) # 80003b7e <namecmp>
    80005620:	14050063          	beqz	a0,80005760 <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005624:	f2c40613          	addi	a2,s0,-212
    80005628:	fb040593          	addi	a1,s0,-80
    8000562c:	8526                	mv	a0,s1
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	56a080e7          	jalr	1386(ra) # 80003b98 <dirlookup>
    80005636:	892a                	mv	s2,a0
    80005638:	12050463          	beqz	a0,80005760 <sys_unlink+0x1b6>
  ilock(ip);
    8000563c:	ffffe097          	auipc	ra,0xffffe
    80005640:	0a4080e7          	jalr	164(ra) # 800036e0 <ilock>
  if(ip->nlink < 1)
    80005644:	05291783          	lh	a5,82(s2)
    80005648:	08f05463          	blez	a5,800056d0 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000564c:	04c91703          	lh	a4,76(s2)
    80005650:	4785                	li	a5,1
    80005652:	08f70763          	beq	a4,a5,800056e0 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005656:	4641                	li	a2,16
    80005658:	4581                	li	a1,0
    8000565a:	fc040513          	addi	a0,s0,-64
    8000565e:	ffffb097          	auipc	ra,0xffffb
    80005662:	710080e7          	jalr	1808(ra) # 80000d6e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005666:	4741                	li	a4,16
    80005668:	f2c42683          	lw	a3,-212(s0)
    8000566c:	fc040613          	addi	a2,s0,-64
    80005670:	4581                	li	a1,0
    80005672:	8526                	mv	a0,s1
    80005674:	ffffe097          	auipc	ra,0xffffe
    80005678:	3f0080e7          	jalr	1008(ra) # 80003a64 <writei>
    8000567c:	47c1                	li	a5,16
    8000567e:	0af51763          	bne	a0,a5,8000572c <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005682:	04c91703          	lh	a4,76(s2)
    80005686:	4785                	li	a5,1
    80005688:	0af70a63          	beq	a4,a5,8000573c <sys_unlink+0x192>
  iunlockput(dp);
    8000568c:	8526                	mv	a0,s1
    8000568e:	ffffe097          	auipc	ra,0xffffe
    80005692:	290080e7          	jalr	656(ra) # 8000391e <iunlockput>
  ip->nlink--;
    80005696:	05295783          	lhu	a5,82(s2)
    8000569a:	37fd                	addiw	a5,a5,-1
    8000569c:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    800056a0:	854a                	mv	a0,s2
    800056a2:	ffffe097          	auipc	ra,0xffffe
    800056a6:	f74080e7          	jalr	-140(ra) # 80003616 <iupdate>
  iunlockput(ip);
    800056aa:	854a                	mv	a0,s2
    800056ac:	ffffe097          	auipc	ra,0xffffe
    800056b0:	272080e7          	jalr	626(ra) # 8000391e <iunlockput>
  end_op(ROOTDEV);
    800056b4:	4501                	li	a0,0
    800056b6:	fffff097          	auipc	ra,0xfffff
    800056ba:	ab8080e7          	jalr	-1352(ra) # 8000416e <end_op>
  return 0;
    800056be:	4501                	li	a0,0
    800056c0:	a85d                	j	80005776 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    800056c2:	4501                	li	a0,0
    800056c4:	fffff097          	auipc	ra,0xfffff
    800056c8:	aaa080e7          	jalr	-1366(ra) # 8000416e <end_op>
    return -1;
    800056cc:	557d                	li	a0,-1
    800056ce:	a065                	j	80005776 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    800056d0:	00003517          	auipc	a0,0x3
    800056d4:	3e850513          	addi	a0,a0,1000 # 80008ab8 <userret+0xa28>
    800056d8:	ffffb097          	auipc	ra,0xffffb
    800056dc:	e7c080e7          	jalr	-388(ra) # 80000554 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056e0:	05492703          	lw	a4,84(s2)
    800056e4:	02000793          	li	a5,32
    800056e8:	f6e7f7e3          	bgeu	a5,a4,80005656 <sys_unlink+0xac>
    800056ec:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056f0:	4741                	li	a4,16
    800056f2:	86ce                	mv	a3,s3
    800056f4:	f1840613          	addi	a2,s0,-232
    800056f8:	4581                	li	a1,0
    800056fa:	854a                	mv	a0,s2
    800056fc:	ffffe097          	auipc	ra,0xffffe
    80005700:	274080e7          	jalr	628(ra) # 80003970 <readi>
    80005704:	47c1                	li	a5,16
    80005706:	00f51b63          	bne	a0,a5,8000571c <sys_unlink+0x172>
    if(de.inum != 0)
    8000570a:	f1845783          	lhu	a5,-232(s0)
    8000570e:	e7a1                	bnez	a5,80005756 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005710:	29c1                	addiw	s3,s3,16
    80005712:	05492783          	lw	a5,84(s2)
    80005716:	fcf9ede3          	bltu	s3,a5,800056f0 <sys_unlink+0x146>
    8000571a:	bf35                	j	80005656 <sys_unlink+0xac>
      panic("isdirempty: readi");
    8000571c:	00003517          	auipc	a0,0x3
    80005720:	3b450513          	addi	a0,a0,948 # 80008ad0 <userret+0xa40>
    80005724:	ffffb097          	auipc	ra,0xffffb
    80005728:	e30080e7          	jalr	-464(ra) # 80000554 <panic>
    panic("unlink: writei");
    8000572c:	00003517          	auipc	a0,0x3
    80005730:	3bc50513          	addi	a0,a0,956 # 80008ae8 <userret+0xa58>
    80005734:	ffffb097          	auipc	ra,0xffffb
    80005738:	e20080e7          	jalr	-480(ra) # 80000554 <panic>
    dp->nlink--;
    8000573c:	0524d783          	lhu	a5,82(s1)
    80005740:	37fd                	addiw	a5,a5,-1
    80005742:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005746:	8526                	mv	a0,s1
    80005748:	ffffe097          	auipc	ra,0xffffe
    8000574c:	ece080e7          	jalr	-306(ra) # 80003616 <iupdate>
    80005750:	bf35                	j	8000568c <sys_unlink+0xe2>
    return -1;
    80005752:	557d                	li	a0,-1
    80005754:	a00d                	j	80005776 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005756:	854a                	mv	a0,s2
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	1c6080e7          	jalr	454(ra) # 8000391e <iunlockput>
  iunlockput(dp);
    80005760:	8526                	mv	a0,s1
    80005762:	ffffe097          	auipc	ra,0xffffe
    80005766:	1bc080e7          	jalr	444(ra) # 8000391e <iunlockput>
  end_op(ROOTDEV);
    8000576a:	4501                	li	a0,0
    8000576c:	fffff097          	auipc	ra,0xfffff
    80005770:	a02080e7          	jalr	-1534(ra) # 8000416e <end_op>
  return -1;
    80005774:	557d                	li	a0,-1
}
    80005776:	70ae                	ld	ra,232(sp)
    80005778:	740e                	ld	s0,224(sp)
    8000577a:	64ee                	ld	s1,216(sp)
    8000577c:	694e                	ld	s2,208(sp)
    8000577e:	69ae                	ld	s3,200(sp)
    80005780:	616d                	addi	sp,sp,240
    80005782:	8082                	ret

0000000080005784 <sys_open>:

uint64
sys_open(void)
{
    80005784:	7131                	addi	sp,sp,-192
    80005786:	fd06                	sd	ra,184(sp)
    80005788:	f922                	sd	s0,176(sp)
    8000578a:	f526                	sd	s1,168(sp)
    8000578c:	f14a                	sd	s2,160(sp)
    8000578e:	ed4e                	sd	s3,152(sp)
    80005790:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005792:	08000613          	li	a2,128
    80005796:	f5040593          	addi	a1,s0,-176
    8000579a:	4501                	li	a0,0
    8000579c:	ffffd097          	auipc	ra,0xffffd
    800057a0:	414080e7          	jalr	1044(ra) # 80002bb0 <argstr>
    return -1;
    800057a4:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800057a6:	0a054963          	bltz	a0,80005858 <sys_open+0xd4>
    800057aa:	f4c40593          	addi	a1,s0,-180
    800057ae:	4505                	li	a0,1
    800057b0:	ffffd097          	auipc	ra,0xffffd
    800057b4:	3bc080e7          	jalr	956(ra) # 80002b6c <argint>
    800057b8:	0a054063          	bltz	a0,80005858 <sys_open+0xd4>

  begin_op(ROOTDEV);
    800057bc:	4501                	li	a0,0
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	906080e7          	jalr	-1786(ra) # 800040c4 <begin_op>

  if(omode & O_CREATE){
    800057c6:	f4c42783          	lw	a5,-180(s0)
    800057ca:	2007f793          	andi	a5,a5,512
    800057ce:	c3dd                	beqz	a5,80005874 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    800057d0:	4681                	li	a3,0
    800057d2:	4601                	li	a2,0
    800057d4:	4589                	li	a1,2
    800057d6:	f5040513          	addi	a0,s0,-176
    800057da:	00000097          	auipc	ra,0x0
    800057de:	960080e7          	jalr	-1696(ra) # 8000513a <create>
    800057e2:	892a                	mv	s2,a0
    if(ip == 0){
    800057e4:	c151                	beqz	a0,80005868 <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800057e6:	04c91703          	lh	a4,76(s2)
    800057ea:	478d                	li	a5,3
    800057ec:	00f71763          	bne	a4,a5,800057fa <sys_open+0x76>
    800057f0:	04e95703          	lhu	a4,78(s2)
    800057f4:	47a5                	li	a5,9
    800057f6:	0ce7e663          	bltu	a5,a4,800058c2 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057fa:	fffff097          	auipc	ra,0xfffff
    800057fe:	da8080e7          	jalr	-600(ra) # 800045a2 <filealloc>
    80005802:	89aa                	mv	s3,a0
    80005804:	c97d                	beqz	a0,800058fa <sys_open+0x176>
    80005806:	00000097          	auipc	ra,0x0
    8000580a:	8f2080e7          	jalr	-1806(ra) # 800050f8 <fdalloc>
    8000580e:	84aa                	mv	s1,a0
    80005810:	0e054063          	bltz	a0,800058f0 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005814:	04c91703          	lh	a4,76(s2)
    80005818:	478d                	li	a5,3
    8000581a:	0cf70063          	beq	a4,a5,800058da <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    8000581e:	4789                	li	a5,2
    80005820:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005824:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005828:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    8000582c:	f4c42783          	lw	a5,-180(s0)
    80005830:	0017c713          	xori	a4,a5,1
    80005834:	8b05                	andi	a4,a4,1
    80005836:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000583a:	8b8d                	andi	a5,a5,3
    8000583c:	00f037b3          	snez	a5,a5
    80005840:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005844:	854a                	mv	a0,s2
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	f5c080e7          	jalr	-164(ra) # 800037a2 <iunlock>
  end_op(ROOTDEV);
    8000584e:	4501                	li	a0,0
    80005850:	fffff097          	auipc	ra,0xfffff
    80005854:	91e080e7          	jalr	-1762(ra) # 8000416e <end_op>

  return fd;
}
    80005858:	8526                	mv	a0,s1
    8000585a:	70ea                	ld	ra,184(sp)
    8000585c:	744a                	ld	s0,176(sp)
    8000585e:	74aa                	ld	s1,168(sp)
    80005860:	790a                	ld	s2,160(sp)
    80005862:	69ea                	ld	s3,152(sp)
    80005864:	6129                	addi	sp,sp,192
    80005866:	8082                	ret
      end_op(ROOTDEV);
    80005868:	4501                	li	a0,0
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	904080e7          	jalr	-1788(ra) # 8000416e <end_op>
      return -1;
    80005872:	b7dd                	j	80005858 <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005874:	f5040513          	addi	a0,s0,-176
    80005878:	ffffe097          	auipc	ra,0xffffe
    8000587c:	5f2080e7          	jalr	1522(ra) # 80003e6a <namei>
    80005880:	892a                	mv	s2,a0
    80005882:	c90d                	beqz	a0,800058b4 <sys_open+0x130>
    ilock(ip);
    80005884:	ffffe097          	auipc	ra,0xffffe
    80005888:	e5c080e7          	jalr	-420(ra) # 800036e0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000588c:	04c91703          	lh	a4,76(s2)
    80005890:	4785                	li	a5,1
    80005892:	f4f71ae3          	bne	a4,a5,800057e6 <sys_open+0x62>
    80005896:	f4c42783          	lw	a5,-180(s0)
    8000589a:	d3a5                	beqz	a5,800057fa <sys_open+0x76>
      iunlockput(ip);
    8000589c:	854a                	mv	a0,s2
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	080080e7          	jalr	128(ra) # 8000391e <iunlockput>
      end_op(ROOTDEV);
    800058a6:	4501                	li	a0,0
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	8c6080e7          	jalr	-1850(ra) # 8000416e <end_op>
      return -1;
    800058b0:	54fd                	li	s1,-1
    800058b2:	b75d                	j	80005858 <sys_open+0xd4>
      end_op(ROOTDEV);
    800058b4:	4501                	li	a0,0
    800058b6:	fffff097          	auipc	ra,0xfffff
    800058ba:	8b8080e7          	jalr	-1864(ra) # 8000416e <end_op>
      return -1;
    800058be:	54fd                	li	s1,-1
    800058c0:	bf61                	j	80005858 <sys_open+0xd4>
    iunlockput(ip);
    800058c2:	854a                	mv	a0,s2
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	05a080e7          	jalr	90(ra) # 8000391e <iunlockput>
    end_op(ROOTDEV);
    800058cc:	4501                	li	a0,0
    800058ce:	fffff097          	auipc	ra,0xfffff
    800058d2:	8a0080e7          	jalr	-1888(ra) # 8000416e <end_op>
    return -1;
    800058d6:	54fd                	li	s1,-1
    800058d8:	b741                	j	80005858 <sys_open+0xd4>
    f->type = FD_DEVICE;
    800058da:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800058de:	04e91783          	lh	a5,78(s2)
    800058e2:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    800058e6:	05091783          	lh	a5,80(s2)
    800058ea:	02f99323          	sh	a5,38(s3)
    800058ee:	bf1d                	j	80005824 <sys_open+0xa0>
      fileclose(f);
    800058f0:	854e                	mv	a0,s3
    800058f2:	fffff097          	auipc	ra,0xfffff
    800058f6:	d6c080e7          	jalr	-660(ra) # 8000465e <fileclose>
    iunlockput(ip);
    800058fa:	854a                	mv	a0,s2
    800058fc:	ffffe097          	auipc	ra,0xffffe
    80005900:	022080e7          	jalr	34(ra) # 8000391e <iunlockput>
    end_op(ROOTDEV);
    80005904:	4501                	li	a0,0
    80005906:	fffff097          	auipc	ra,0xfffff
    8000590a:	868080e7          	jalr	-1944(ra) # 8000416e <end_op>
    return -1;
    8000590e:	54fd                	li	s1,-1
    80005910:	b7a1                	j	80005858 <sys_open+0xd4>

0000000080005912 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005912:	7175                	addi	sp,sp,-144
    80005914:	e506                	sd	ra,136(sp)
    80005916:	e122                	sd	s0,128(sp)
    80005918:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    8000591a:	4501                	li	a0,0
    8000591c:	ffffe097          	auipc	ra,0xffffe
    80005920:	7a8080e7          	jalr	1960(ra) # 800040c4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005924:	08000613          	li	a2,128
    80005928:	f7040593          	addi	a1,s0,-144
    8000592c:	4501                	li	a0,0
    8000592e:	ffffd097          	auipc	ra,0xffffd
    80005932:	282080e7          	jalr	642(ra) # 80002bb0 <argstr>
    80005936:	02054a63          	bltz	a0,8000596a <sys_mkdir+0x58>
    8000593a:	4681                	li	a3,0
    8000593c:	4601                	li	a2,0
    8000593e:	4585                	li	a1,1
    80005940:	f7040513          	addi	a0,s0,-144
    80005944:	fffff097          	auipc	ra,0xfffff
    80005948:	7f6080e7          	jalr	2038(ra) # 8000513a <create>
    8000594c:	cd19                	beqz	a0,8000596a <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    8000594e:	ffffe097          	auipc	ra,0xffffe
    80005952:	fd0080e7          	jalr	-48(ra) # 8000391e <iunlockput>
  end_op(ROOTDEV);
    80005956:	4501                	li	a0,0
    80005958:	fffff097          	auipc	ra,0xfffff
    8000595c:	816080e7          	jalr	-2026(ra) # 8000416e <end_op>
  return 0;
    80005960:	4501                	li	a0,0
}
    80005962:	60aa                	ld	ra,136(sp)
    80005964:	640a                	ld	s0,128(sp)
    80005966:	6149                	addi	sp,sp,144
    80005968:	8082                	ret
    end_op(ROOTDEV);
    8000596a:	4501                	li	a0,0
    8000596c:	fffff097          	auipc	ra,0xfffff
    80005970:	802080e7          	jalr	-2046(ra) # 8000416e <end_op>
    return -1;
    80005974:	557d                	li	a0,-1
    80005976:	b7f5                	j	80005962 <sys_mkdir+0x50>

0000000080005978 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005978:	7135                	addi	sp,sp,-160
    8000597a:	ed06                	sd	ra,152(sp)
    8000597c:	e922                	sd	s0,144(sp)
    8000597e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005980:	4501                	li	a0,0
    80005982:	ffffe097          	auipc	ra,0xffffe
    80005986:	742080e7          	jalr	1858(ra) # 800040c4 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000598a:	08000613          	li	a2,128
    8000598e:	f7040593          	addi	a1,s0,-144
    80005992:	4501                	li	a0,0
    80005994:	ffffd097          	auipc	ra,0xffffd
    80005998:	21c080e7          	jalr	540(ra) # 80002bb0 <argstr>
    8000599c:	04054b63          	bltz	a0,800059f2 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    800059a0:	f6c40593          	addi	a1,s0,-148
    800059a4:	4505                	li	a0,1
    800059a6:	ffffd097          	auipc	ra,0xffffd
    800059aa:	1c6080e7          	jalr	454(ra) # 80002b6c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059ae:	04054263          	bltz	a0,800059f2 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    800059b2:	f6840593          	addi	a1,s0,-152
    800059b6:	4509                	li	a0,2
    800059b8:	ffffd097          	auipc	ra,0xffffd
    800059bc:	1b4080e7          	jalr	436(ra) # 80002b6c <argint>
     argint(1, &major) < 0 ||
    800059c0:	02054963          	bltz	a0,800059f2 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800059c4:	f6841683          	lh	a3,-152(s0)
    800059c8:	f6c41603          	lh	a2,-148(s0)
    800059cc:	458d                	li	a1,3
    800059ce:	f7040513          	addi	a0,s0,-144
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	768080e7          	jalr	1896(ra) # 8000513a <create>
     argint(2, &minor) < 0 ||
    800059da:	cd01                	beqz	a0,800059f2 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    800059dc:	ffffe097          	auipc	ra,0xffffe
    800059e0:	f42080e7          	jalr	-190(ra) # 8000391e <iunlockput>
  end_op(ROOTDEV);
    800059e4:	4501                	li	a0,0
    800059e6:	ffffe097          	auipc	ra,0xffffe
    800059ea:	788080e7          	jalr	1928(ra) # 8000416e <end_op>
  return 0;
    800059ee:	4501                	li	a0,0
    800059f0:	a039                	j	800059fe <sys_mknod+0x86>
    end_op(ROOTDEV);
    800059f2:	4501                	li	a0,0
    800059f4:	ffffe097          	auipc	ra,0xffffe
    800059f8:	77a080e7          	jalr	1914(ra) # 8000416e <end_op>
    return -1;
    800059fc:	557d                	li	a0,-1
}
    800059fe:	60ea                	ld	ra,152(sp)
    80005a00:	644a                	ld	s0,144(sp)
    80005a02:	610d                	addi	sp,sp,160
    80005a04:	8082                	ret

0000000080005a06 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a06:	7135                	addi	sp,sp,-160
    80005a08:	ed06                	sd	ra,152(sp)
    80005a0a:	e922                	sd	s0,144(sp)
    80005a0c:	e526                	sd	s1,136(sp)
    80005a0e:	e14a                	sd	s2,128(sp)
    80005a10:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a12:	ffffc097          	auipc	ra,0xffffc
    80005a16:	046080e7          	jalr	70(ra) # 80001a58 <myproc>
    80005a1a:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005a1c:	4501                	li	a0,0
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	6a6080e7          	jalr	1702(ra) # 800040c4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a26:	08000613          	li	a2,128
    80005a2a:	f6040593          	addi	a1,s0,-160
    80005a2e:	4501                	li	a0,0
    80005a30:	ffffd097          	auipc	ra,0xffffd
    80005a34:	180080e7          	jalr	384(ra) # 80002bb0 <argstr>
    80005a38:	04054c63          	bltz	a0,80005a90 <sys_chdir+0x8a>
    80005a3c:	f6040513          	addi	a0,s0,-160
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	42a080e7          	jalr	1066(ra) # 80003e6a <namei>
    80005a48:	84aa                	mv	s1,a0
    80005a4a:	c139                	beqz	a0,80005a90 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	c94080e7          	jalr	-876(ra) # 800036e0 <ilock>
  if(ip->type != T_DIR){
    80005a54:	04c49703          	lh	a4,76(s1)
    80005a58:	4785                	li	a5,1
    80005a5a:	04f71263          	bne	a4,a5,80005a9e <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005a5e:	8526                	mv	a0,s1
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	d42080e7          	jalr	-702(ra) # 800037a2 <iunlock>
  iput(p->cwd);
    80005a68:	15893503          	ld	a0,344(s2)
    80005a6c:	ffffe097          	auipc	ra,0xffffe
    80005a70:	d82080e7          	jalr	-638(ra) # 800037ee <iput>
  end_op(ROOTDEV);
    80005a74:	4501                	li	a0,0
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	6f8080e7          	jalr	1784(ra) # 8000416e <end_op>
  p->cwd = ip;
    80005a7e:	14993c23          	sd	s1,344(s2)
  return 0;
    80005a82:	4501                	li	a0,0
}
    80005a84:	60ea                	ld	ra,152(sp)
    80005a86:	644a                	ld	s0,144(sp)
    80005a88:	64aa                	ld	s1,136(sp)
    80005a8a:	690a                	ld	s2,128(sp)
    80005a8c:	610d                	addi	sp,sp,160
    80005a8e:	8082                	ret
    end_op(ROOTDEV);
    80005a90:	4501                	li	a0,0
    80005a92:	ffffe097          	auipc	ra,0xffffe
    80005a96:	6dc080e7          	jalr	1756(ra) # 8000416e <end_op>
    return -1;
    80005a9a:	557d                	li	a0,-1
    80005a9c:	b7e5                	j	80005a84 <sys_chdir+0x7e>
    iunlockput(ip);
    80005a9e:	8526                	mv	a0,s1
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	e7e080e7          	jalr	-386(ra) # 8000391e <iunlockput>
    end_op(ROOTDEV);
    80005aa8:	4501                	li	a0,0
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	6c4080e7          	jalr	1732(ra) # 8000416e <end_op>
    return -1;
    80005ab2:	557d                	li	a0,-1
    80005ab4:	bfc1                	j	80005a84 <sys_chdir+0x7e>

0000000080005ab6 <sys_exec>:

uint64
sys_exec(void)
{
    80005ab6:	7145                	addi	sp,sp,-464
    80005ab8:	e786                	sd	ra,456(sp)
    80005aba:	e3a2                	sd	s0,448(sp)
    80005abc:	ff26                	sd	s1,440(sp)
    80005abe:	fb4a                	sd	s2,432(sp)
    80005ac0:	f74e                	sd	s3,424(sp)
    80005ac2:	f352                	sd	s4,416(sp)
    80005ac4:	ef56                	sd	s5,408(sp)
    80005ac6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ac8:	08000613          	li	a2,128
    80005acc:	f4040593          	addi	a1,s0,-192
    80005ad0:	4501                	li	a0,0
    80005ad2:	ffffd097          	auipc	ra,0xffffd
    80005ad6:	0de080e7          	jalr	222(ra) # 80002bb0 <argstr>
    80005ada:	0e054663          	bltz	a0,80005bc6 <sys_exec+0x110>
    80005ade:	e3840593          	addi	a1,s0,-456
    80005ae2:	4505                	li	a0,1
    80005ae4:	ffffd097          	auipc	ra,0xffffd
    80005ae8:	0aa080e7          	jalr	170(ra) # 80002b8e <argaddr>
    80005aec:	0e054763          	bltz	a0,80005bda <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005af0:	10000613          	li	a2,256
    80005af4:	4581                	li	a1,0
    80005af6:	e4040513          	addi	a0,s0,-448
    80005afa:	ffffb097          	auipc	ra,0xffffb
    80005afe:	274080e7          	jalr	628(ra) # 80000d6e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b02:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005b06:	89ca                	mv	s3,s2
    80005b08:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005b0a:	02000a13          	li	s4,32
    80005b0e:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b12:	00349793          	slli	a5,s1,0x3
    80005b16:	e3040593          	addi	a1,s0,-464
    80005b1a:	e3843503          	ld	a0,-456(s0)
    80005b1e:	953e                	add	a0,a0,a5
    80005b20:	ffffd097          	auipc	ra,0xffffd
    80005b24:	fb2080e7          	jalr	-78(ra) # 80002ad2 <fetchaddr>
    80005b28:	02054a63          	bltz	a0,80005b5c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005b2c:	e3043783          	ld	a5,-464(s0)
    80005b30:	c7a1                	beqz	a5,80005b78 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b32:	ffffb097          	auipc	ra,0xffffb
    80005b36:	e3a080e7          	jalr	-454(ra) # 8000096c <kalloc>
    80005b3a:	85aa                	mv	a1,a0
    80005b3c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b40:	c92d                	beqz	a0,80005bb2 <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005b42:	6605                	lui	a2,0x1
    80005b44:	e3043503          	ld	a0,-464(s0)
    80005b48:	ffffd097          	auipc	ra,0xffffd
    80005b4c:	fdc080e7          	jalr	-36(ra) # 80002b24 <fetchstr>
    80005b50:	00054663          	bltz	a0,80005b5c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005b54:	0485                	addi	s1,s1,1
    80005b56:	09a1                	addi	s3,s3,8
    80005b58:	fb449be3          	bne	s1,s4,80005b0e <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b5c:	10090493          	addi	s1,s2,256
    80005b60:	00093503          	ld	a0,0(s2)
    80005b64:	cd39                	beqz	a0,80005bc2 <sys_exec+0x10c>
    kfree(argv[i]);
    80005b66:	ffffb097          	auipc	ra,0xffffb
    80005b6a:	d0a080e7          	jalr	-758(ra) # 80000870 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b6e:	0921                	addi	s2,s2,8
    80005b70:	fe9918e3          	bne	s2,s1,80005b60 <sys_exec+0xaa>
  return -1;
    80005b74:	557d                	li	a0,-1
    80005b76:	a889                	j	80005bc8 <sys_exec+0x112>
      argv[i] = 0;
    80005b78:	0a8e                	slli	s5,s5,0x3
    80005b7a:	fc040793          	addi	a5,s0,-64
    80005b7e:	9abe                	add	s5,s5,a5
    80005b80:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005b84:	e4040593          	addi	a1,s0,-448
    80005b88:	f4040513          	addi	a0,s0,-192
    80005b8c:	fffff097          	auipc	ra,0xfffff
    80005b90:	178080e7          	jalr	376(ra) # 80004d04 <exec>
    80005b94:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b96:	10090993          	addi	s3,s2,256
    80005b9a:	00093503          	ld	a0,0(s2)
    80005b9e:	c901                	beqz	a0,80005bae <sys_exec+0xf8>
    kfree(argv[i]);
    80005ba0:	ffffb097          	auipc	ra,0xffffb
    80005ba4:	cd0080e7          	jalr	-816(ra) # 80000870 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ba8:	0921                	addi	s2,s2,8
    80005baa:	ff3918e3          	bne	s2,s3,80005b9a <sys_exec+0xe4>
  return ret;
    80005bae:	8526                	mv	a0,s1
    80005bb0:	a821                	j	80005bc8 <sys_exec+0x112>
      panic("sys_exec kalloc");
    80005bb2:	00003517          	auipc	a0,0x3
    80005bb6:	f4650513          	addi	a0,a0,-186 # 80008af8 <userret+0xa68>
    80005bba:	ffffb097          	auipc	ra,0xffffb
    80005bbe:	99a080e7          	jalr	-1638(ra) # 80000554 <panic>
  return -1;
    80005bc2:	557d                	li	a0,-1
    80005bc4:	a011                	j	80005bc8 <sys_exec+0x112>
    return -1;
    80005bc6:	557d                	li	a0,-1
}
    80005bc8:	60be                	ld	ra,456(sp)
    80005bca:	641e                	ld	s0,448(sp)
    80005bcc:	74fa                	ld	s1,440(sp)
    80005bce:	795a                	ld	s2,432(sp)
    80005bd0:	79ba                	ld	s3,424(sp)
    80005bd2:	7a1a                	ld	s4,416(sp)
    80005bd4:	6afa                	ld	s5,408(sp)
    80005bd6:	6179                	addi	sp,sp,464
    80005bd8:	8082                	ret
    return -1;
    80005bda:	557d                	li	a0,-1
    80005bdc:	b7f5                	j	80005bc8 <sys_exec+0x112>

0000000080005bde <sys_pipe>:

uint64
sys_pipe(void)
{
    80005bde:	7139                	addi	sp,sp,-64
    80005be0:	fc06                	sd	ra,56(sp)
    80005be2:	f822                	sd	s0,48(sp)
    80005be4:	f426                	sd	s1,40(sp)
    80005be6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005be8:	ffffc097          	auipc	ra,0xffffc
    80005bec:	e70080e7          	jalr	-400(ra) # 80001a58 <myproc>
    80005bf0:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005bf2:	fd840593          	addi	a1,s0,-40
    80005bf6:	4501                	li	a0,0
    80005bf8:	ffffd097          	auipc	ra,0xffffd
    80005bfc:	f96080e7          	jalr	-106(ra) # 80002b8e <argaddr>
    return -1;
    80005c00:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005c02:	0e054063          	bltz	a0,80005ce2 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005c06:	fc840593          	addi	a1,s0,-56
    80005c0a:	fd040513          	addi	a0,s0,-48
    80005c0e:	fffff097          	auipc	ra,0xfffff
    80005c12:	db4080e7          	jalr	-588(ra) # 800049c2 <pipealloc>
    return -1;
    80005c16:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c18:	0c054563          	bltz	a0,80005ce2 <sys_pipe+0x104>
  fd0 = -1;
    80005c1c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c20:	fd043503          	ld	a0,-48(s0)
    80005c24:	fffff097          	auipc	ra,0xfffff
    80005c28:	4d4080e7          	jalr	1236(ra) # 800050f8 <fdalloc>
    80005c2c:	fca42223          	sw	a0,-60(s0)
    80005c30:	08054c63          	bltz	a0,80005cc8 <sys_pipe+0xea>
    80005c34:	fc843503          	ld	a0,-56(s0)
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	4c0080e7          	jalr	1216(ra) # 800050f8 <fdalloc>
    80005c40:	fca42023          	sw	a0,-64(s0)
    80005c44:	06054863          	bltz	a0,80005cb4 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c48:	4691                	li	a3,4
    80005c4a:	fc440613          	addi	a2,s0,-60
    80005c4e:	fd843583          	ld	a1,-40(s0)
    80005c52:	6ca8                	ld	a0,88(s1)
    80005c54:	ffffc097          	auipc	ra,0xffffc
    80005c58:	af6080e7          	jalr	-1290(ra) # 8000174a <copyout>
    80005c5c:	02054063          	bltz	a0,80005c7c <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c60:	4691                	li	a3,4
    80005c62:	fc040613          	addi	a2,s0,-64
    80005c66:	fd843583          	ld	a1,-40(s0)
    80005c6a:	0591                	addi	a1,a1,4
    80005c6c:	6ca8                	ld	a0,88(s1)
    80005c6e:	ffffc097          	auipc	ra,0xffffc
    80005c72:	adc080e7          	jalr	-1316(ra) # 8000174a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c76:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c78:	06055563          	bgez	a0,80005ce2 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005c7c:	fc442783          	lw	a5,-60(s0)
    80005c80:	07e9                	addi	a5,a5,26
    80005c82:	078e                	slli	a5,a5,0x3
    80005c84:	97a6                	add	a5,a5,s1
    80005c86:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005c8a:	fc042503          	lw	a0,-64(s0)
    80005c8e:	0569                	addi	a0,a0,26
    80005c90:	050e                	slli	a0,a0,0x3
    80005c92:	9526                	add	a0,a0,s1
    80005c94:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005c98:	fd043503          	ld	a0,-48(s0)
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	9c2080e7          	jalr	-1598(ra) # 8000465e <fileclose>
    fileclose(wf);
    80005ca4:	fc843503          	ld	a0,-56(s0)
    80005ca8:	fffff097          	auipc	ra,0xfffff
    80005cac:	9b6080e7          	jalr	-1610(ra) # 8000465e <fileclose>
    return -1;
    80005cb0:	57fd                	li	a5,-1
    80005cb2:	a805                	j	80005ce2 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005cb4:	fc442783          	lw	a5,-60(s0)
    80005cb8:	0007c863          	bltz	a5,80005cc8 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005cbc:	01a78513          	addi	a0,a5,26
    80005cc0:	050e                	slli	a0,a0,0x3
    80005cc2:	9526                	add	a0,a0,s1
    80005cc4:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005cc8:	fd043503          	ld	a0,-48(s0)
    80005ccc:	fffff097          	auipc	ra,0xfffff
    80005cd0:	992080e7          	jalr	-1646(ra) # 8000465e <fileclose>
    fileclose(wf);
    80005cd4:	fc843503          	ld	a0,-56(s0)
    80005cd8:	fffff097          	auipc	ra,0xfffff
    80005cdc:	986080e7          	jalr	-1658(ra) # 8000465e <fileclose>
    return -1;
    80005ce0:	57fd                	li	a5,-1
}
    80005ce2:	853e                	mv	a0,a5
    80005ce4:	70e2                	ld	ra,56(sp)
    80005ce6:	7442                	ld	s0,48(sp)
    80005ce8:	74a2                	ld	s1,40(sp)
    80005cea:	6121                	addi	sp,sp,64
    80005cec:	8082                	ret
	...

0000000080005cf0 <kernelvec>:
    80005cf0:	7111                	addi	sp,sp,-256
    80005cf2:	e006                	sd	ra,0(sp)
    80005cf4:	e40a                	sd	sp,8(sp)
    80005cf6:	e80e                	sd	gp,16(sp)
    80005cf8:	ec12                	sd	tp,24(sp)
    80005cfa:	f016                	sd	t0,32(sp)
    80005cfc:	f41a                	sd	t1,40(sp)
    80005cfe:	f81e                	sd	t2,48(sp)
    80005d00:	fc22                	sd	s0,56(sp)
    80005d02:	e0a6                	sd	s1,64(sp)
    80005d04:	e4aa                	sd	a0,72(sp)
    80005d06:	e8ae                	sd	a1,80(sp)
    80005d08:	ecb2                	sd	a2,88(sp)
    80005d0a:	f0b6                	sd	a3,96(sp)
    80005d0c:	f4ba                	sd	a4,104(sp)
    80005d0e:	f8be                	sd	a5,112(sp)
    80005d10:	fcc2                	sd	a6,120(sp)
    80005d12:	e146                	sd	a7,128(sp)
    80005d14:	e54a                	sd	s2,136(sp)
    80005d16:	e94e                	sd	s3,144(sp)
    80005d18:	ed52                	sd	s4,152(sp)
    80005d1a:	f156                	sd	s5,160(sp)
    80005d1c:	f55a                	sd	s6,168(sp)
    80005d1e:	f95e                	sd	s7,176(sp)
    80005d20:	fd62                	sd	s8,184(sp)
    80005d22:	e1e6                	sd	s9,192(sp)
    80005d24:	e5ea                	sd	s10,200(sp)
    80005d26:	e9ee                	sd	s11,208(sp)
    80005d28:	edf2                	sd	t3,216(sp)
    80005d2a:	f1f6                	sd	t4,224(sp)
    80005d2c:	f5fa                	sd	t5,232(sp)
    80005d2e:	f9fe                	sd	t6,240(sp)
    80005d30:	c63fc0ef          	jal	ra,80002992 <kerneltrap>
    80005d34:	6082                	ld	ra,0(sp)
    80005d36:	6122                	ld	sp,8(sp)
    80005d38:	61c2                	ld	gp,16(sp)
    80005d3a:	7282                	ld	t0,32(sp)
    80005d3c:	7322                	ld	t1,40(sp)
    80005d3e:	73c2                	ld	t2,48(sp)
    80005d40:	7462                	ld	s0,56(sp)
    80005d42:	6486                	ld	s1,64(sp)
    80005d44:	6526                	ld	a0,72(sp)
    80005d46:	65c6                	ld	a1,80(sp)
    80005d48:	6666                	ld	a2,88(sp)
    80005d4a:	7686                	ld	a3,96(sp)
    80005d4c:	7726                	ld	a4,104(sp)
    80005d4e:	77c6                	ld	a5,112(sp)
    80005d50:	7866                	ld	a6,120(sp)
    80005d52:	688a                	ld	a7,128(sp)
    80005d54:	692a                	ld	s2,136(sp)
    80005d56:	69ca                	ld	s3,144(sp)
    80005d58:	6a6a                	ld	s4,152(sp)
    80005d5a:	7a8a                	ld	s5,160(sp)
    80005d5c:	7b2a                	ld	s6,168(sp)
    80005d5e:	7bca                	ld	s7,176(sp)
    80005d60:	7c6a                	ld	s8,184(sp)
    80005d62:	6c8e                	ld	s9,192(sp)
    80005d64:	6d2e                	ld	s10,200(sp)
    80005d66:	6dce                	ld	s11,208(sp)
    80005d68:	6e6e                	ld	t3,216(sp)
    80005d6a:	7e8e                	ld	t4,224(sp)
    80005d6c:	7f2e                	ld	t5,232(sp)
    80005d6e:	7fce                	ld	t6,240(sp)
    80005d70:	6111                	addi	sp,sp,256
    80005d72:	10200073          	sret
    80005d76:	00000013          	nop
    80005d7a:	00000013          	nop
    80005d7e:	0001                	nop

0000000080005d80 <timervec>:
    80005d80:	34051573          	csrrw	a0,mscratch,a0
    80005d84:	e10c                	sd	a1,0(a0)
    80005d86:	e510                	sd	a2,8(a0)
    80005d88:	e914                	sd	a3,16(a0)
    80005d8a:	710c                	ld	a1,32(a0)
    80005d8c:	7510                	ld	a2,40(a0)
    80005d8e:	6194                	ld	a3,0(a1)
    80005d90:	96b2                	add	a3,a3,a2
    80005d92:	e194                	sd	a3,0(a1)
    80005d94:	4589                	li	a1,2
    80005d96:	14459073          	csrw	sip,a1
    80005d9a:	6914                	ld	a3,16(a0)
    80005d9c:	6510                	ld	a2,8(a0)
    80005d9e:	610c                	ld	a1,0(a0)
    80005da0:	34051573          	csrrw	a0,mscratch,a0
    80005da4:	30200073          	mret
	...

0000000080005daa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005daa:	1141                	addi	sp,sp,-16
    80005dac:	e422                	sd	s0,8(sp)
    80005dae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005db0:	0c0007b7          	lui	a5,0xc000
    80005db4:	4705                	li	a4,1
    80005db6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005db8:	c3d8                	sw	a4,4(a5)
}
    80005dba:	6422                	ld	s0,8(sp)
    80005dbc:	0141                	addi	sp,sp,16
    80005dbe:	8082                	ret

0000000080005dc0 <plicinithart>:

void
plicinithart(void)
{
    80005dc0:	1141                	addi	sp,sp,-16
    80005dc2:	e406                	sd	ra,8(sp)
    80005dc4:	e022                	sd	s0,0(sp)
    80005dc6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005dc8:	ffffc097          	auipc	ra,0xffffc
    80005dcc:	c64080e7          	jalr	-924(ra) # 80001a2c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005dd0:	0085171b          	slliw	a4,a0,0x8
    80005dd4:	0c0027b7          	lui	a5,0xc002
    80005dd8:	97ba                	add	a5,a5,a4
    80005dda:	40200713          	li	a4,1026
    80005dde:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005de2:	00d5151b          	slliw	a0,a0,0xd
    80005de6:	0c2017b7          	lui	a5,0xc201
    80005dea:	953e                	add	a0,a0,a5
    80005dec:	00052023          	sw	zero,0(a0)
}
    80005df0:	60a2                	ld	ra,8(sp)
    80005df2:	6402                	ld	s0,0(sp)
    80005df4:	0141                	addi	sp,sp,16
    80005df6:	8082                	ret

0000000080005df8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005df8:	1141                	addi	sp,sp,-16
    80005dfa:	e406                	sd	ra,8(sp)
    80005dfc:	e022                	sd	s0,0(sp)
    80005dfe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e00:	ffffc097          	auipc	ra,0xffffc
    80005e04:	c2c080e7          	jalr	-980(ra) # 80001a2c <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e08:	00d5179b          	slliw	a5,a0,0xd
    80005e0c:	0c201537          	lui	a0,0xc201
    80005e10:	953e                	add	a0,a0,a5
  return irq;
}
    80005e12:	4148                	lw	a0,4(a0)
    80005e14:	60a2                	ld	ra,8(sp)
    80005e16:	6402                	ld	s0,0(sp)
    80005e18:	0141                	addi	sp,sp,16
    80005e1a:	8082                	ret

0000000080005e1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e1c:	1101                	addi	sp,sp,-32
    80005e1e:	ec06                	sd	ra,24(sp)
    80005e20:	e822                	sd	s0,16(sp)
    80005e22:	e426                	sd	s1,8(sp)
    80005e24:	1000                	addi	s0,sp,32
    80005e26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e28:	ffffc097          	auipc	ra,0xffffc
    80005e2c:	c04080e7          	jalr	-1020(ra) # 80001a2c <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e30:	00d5151b          	slliw	a0,a0,0xd
    80005e34:	0c2017b7          	lui	a5,0xc201
    80005e38:	97aa                	add	a5,a5,a0
    80005e3a:	c3c4                	sw	s1,4(a5)
}
    80005e3c:	60e2                	ld	ra,24(sp)
    80005e3e:	6442                	ld	s0,16(sp)
    80005e40:	64a2                	ld	s1,8(sp)
    80005e42:	6105                	addi	sp,sp,32
    80005e44:	8082                	ret

0000000080005e46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80005e46:	1141                	addi	sp,sp,-16
    80005e48:	e406                	sd	ra,8(sp)
    80005e4a:	e022                	sd	s0,0(sp)
    80005e4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e4e:	479d                	li	a5,7
    80005e50:	06b7c963          	blt	a5,a1,80005ec2 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80005e54:	00151793          	slli	a5,a0,0x1
    80005e58:	97aa                	add	a5,a5,a0
    80005e5a:	00c79713          	slli	a4,a5,0xc
    80005e5e:	0001c797          	auipc	a5,0x1c
    80005e62:	1a278793          	addi	a5,a5,418 # 80022000 <disk>
    80005e66:	97ba                	add	a5,a5,a4
    80005e68:	97ae                	add	a5,a5,a1
    80005e6a:	6709                	lui	a4,0x2
    80005e6c:	97ba                	add	a5,a5,a4
    80005e6e:	0187c783          	lbu	a5,24(a5)
    80005e72:	e3a5                	bnez	a5,80005ed2 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80005e74:	0001c817          	auipc	a6,0x1c
    80005e78:	18c80813          	addi	a6,a6,396 # 80022000 <disk>
    80005e7c:	00151693          	slli	a3,a0,0x1
    80005e80:	00a68733          	add	a4,a3,a0
    80005e84:	0732                	slli	a4,a4,0xc
    80005e86:	00e807b3          	add	a5,a6,a4
    80005e8a:	6709                	lui	a4,0x2
    80005e8c:	00f70633          	add	a2,a4,a5
    80005e90:	6210                	ld	a2,0(a2)
    80005e92:	00459893          	slli	a7,a1,0x4
    80005e96:	9646                	add	a2,a2,a7
    80005e98:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    80005e9c:	97ae                	add	a5,a5,a1
    80005e9e:	97ba                	add	a5,a5,a4
    80005ea0:	4605                	li	a2,1
    80005ea2:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80005ea6:	96aa                	add	a3,a3,a0
    80005ea8:	06b2                	slli	a3,a3,0xc
    80005eaa:	0761                	addi	a4,a4,24
    80005eac:	96ba                	add	a3,a3,a4
    80005eae:	00d80533          	add	a0,a6,a3
    80005eb2:	ffffc097          	auipc	ra,0xffffc
    80005eb6:	4e6080e7          	jalr	1254(ra) # 80002398 <wakeup>
}
    80005eba:	60a2                	ld	ra,8(sp)
    80005ebc:	6402                	ld	s0,0(sp)
    80005ebe:	0141                	addi	sp,sp,16
    80005ec0:	8082                	ret
    panic("virtio_disk_intr 1");
    80005ec2:	00003517          	auipc	a0,0x3
    80005ec6:	c4650513          	addi	a0,a0,-954 # 80008b08 <userret+0xa78>
    80005eca:	ffffa097          	auipc	ra,0xffffa
    80005ece:	68a080e7          	jalr	1674(ra) # 80000554 <panic>
    panic("virtio_disk_intr 2");
    80005ed2:	00003517          	auipc	a0,0x3
    80005ed6:	c4e50513          	addi	a0,a0,-946 # 80008b20 <userret+0xa90>
    80005eda:	ffffa097          	auipc	ra,0xffffa
    80005ede:	67a080e7          	jalr	1658(ra) # 80000554 <panic>

0000000080005ee2 <virtio_disk_init>:
  __sync_synchronize();
    80005ee2:	0ff0000f          	fence
  if(disk[n].init)
    80005ee6:	00151793          	slli	a5,a0,0x1
    80005eea:	97aa                	add	a5,a5,a0
    80005eec:	07b2                	slli	a5,a5,0xc
    80005eee:	0001c717          	auipc	a4,0x1c
    80005ef2:	11270713          	addi	a4,a4,274 # 80022000 <disk>
    80005ef6:	973e                	add	a4,a4,a5
    80005ef8:	6789                	lui	a5,0x2
    80005efa:	97ba                	add	a5,a5,a4
    80005efc:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80005f00:	c391                	beqz	a5,80005f04 <virtio_disk_init+0x22>
    80005f02:	8082                	ret
{
    80005f04:	7139                	addi	sp,sp,-64
    80005f06:	fc06                	sd	ra,56(sp)
    80005f08:	f822                	sd	s0,48(sp)
    80005f0a:	f426                	sd	s1,40(sp)
    80005f0c:	f04a                	sd	s2,32(sp)
    80005f0e:	ec4e                	sd	s3,24(sp)
    80005f10:	e852                	sd	s4,16(sp)
    80005f12:	e456                	sd	s5,8(sp)
    80005f14:	0080                	addi	s0,sp,64
    80005f16:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80005f18:	85aa                	mv	a1,a0
    80005f1a:	00003517          	auipc	a0,0x3
    80005f1e:	c1e50513          	addi	a0,a0,-994 # 80008b38 <userret+0xaa8>
    80005f22:	ffffa097          	auipc	ra,0xffffa
    80005f26:	68c080e7          	jalr	1676(ra) # 800005ae <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    80005f2a:	00149993          	slli	s3,s1,0x1
    80005f2e:	99a6                	add	s3,s3,s1
    80005f30:	09b2                	slli	s3,s3,0xc
    80005f32:	6789                	lui	a5,0x2
    80005f34:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80005f38:	97ce                	add	a5,a5,s3
    80005f3a:	00003597          	auipc	a1,0x3
    80005f3e:	c1658593          	addi	a1,a1,-1002 # 80008b50 <userret+0xac0>
    80005f42:	0001c517          	auipc	a0,0x1c
    80005f46:	0be50513          	addi	a0,a0,190 # 80022000 <disk>
    80005f4a:	953e                	add	a0,a0,a5
    80005f4c:	ffffb097          	auipc	ra,0xffffb
    80005f50:	a80080e7          	jalr	-1408(ra) # 800009cc <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f54:	0014891b          	addiw	s2,s1,1
    80005f58:	00c9191b          	slliw	s2,s2,0xc
    80005f5c:	100007b7          	lui	a5,0x10000
    80005f60:	97ca                	add	a5,a5,s2
    80005f62:	4398                	lw	a4,0(a5)
    80005f64:	2701                	sext.w	a4,a4
    80005f66:	747277b7          	lui	a5,0x74727
    80005f6a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f6e:	12f71663          	bne	a4,a5,8000609a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80005f72:	100007b7          	lui	a5,0x10000
    80005f76:	0791                	addi	a5,a5,4
    80005f78:	97ca                	add	a5,a5,s2
    80005f7a:	439c                	lw	a5,0(a5)
    80005f7c:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f7e:	4705                	li	a4,1
    80005f80:	10e79d63          	bne	a5,a4,8000609a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f84:	100007b7          	lui	a5,0x10000
    80005f88:	07a1                	addi	a5,a5,8
    80005f8a:	97ca                	add	a5,a5,s2
    80005f8c:	439c                	lw	a5,0(a5)
    80005f8e:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80005f90:	4709                	li	a4,2
    80005f92:	10e79463          	bne	a5,a4,8000609a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f96:	100007b7          	lui	a5,0x10000
    80005f9a:	07b1                	addi	a5,a5,12
    80005f9c:	97ca                	add	a5,a5,s2
    80005f9e:	4398                	lw	a4,0(a5)
    80005fa0:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fa2:	554d47b7          	lui	a5,0x554d4
    80005fa6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005faa:	0ef71863          	bne	a4,a5,8000609a <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005fae:	100007b7          	lui	a5,0x10000
    80005fb2:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80005fb6:	96ca                	add	a3,a3,s2
    80005fb8:	4705                	li	a4,1
    80005fba:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005fbc:	470d                	li	a4,3
    80005fbe:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    80005fc0:	01078713          	addi	a4,a5,16
    80005fc4:	974a                	add	a4,a4,s2
    80005fc6:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005fc8:	02078613          	addi	a2,a5,32
    80005fcc:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005fce:	c7ffe737          	lui	a4,0xc7ffe
    80005fd2:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd6703>
    80005fd6:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005fd8:	2701                	sext.w	a4,a4
    80005fda:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005fdc:	472d                	li	a4,11
    80005fde:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005fe0:	473d                	li	a4,15
    80005fe2:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005fe4:	02878713          	addi	a4,a5,40
    80005fe8:	974a                	add	a4,a4,s2
    80005fea:	6685                	lui	a3,0x1
    80005fec:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005fee:	03078713          	addi	a4,a5,48
    80005ff2:	974a                	add	a4,a4,s2
    80005ff4:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ff8:	03478793          	addi	a5,a5,52
    80005ffc:	97ca                	add	a5,a5,s2
    80005ffe:	439c                	lw	a5,0(a5)
    80006000:	2781                	sext.w	a5,a5
  if(max == 0)
    80006002:	c7c5                	beqz	a5,800060aa <virtio_disk_init+0x1c8>
  if(max < NUM)
    80006004:	471d                	li	a4,7
    80006006:	0af77a63          	bgeu	a4,a5,800060ba <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000600a:	10000ab7          	lui	s5,0x10000
    8000600e:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80006012:	97ca                	add	a5,a5,s2
    80006014:	4721                	li	a4,8
    80006016:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006018:	0001ca17          	auipc	s4,0x1c
    8000601c:	fe8a0a13          	addi	s4,s4,-24 # 80022000 <disk>
    80006020:	99d2                	add	s3,s3,s4
    80006022:	6609                	lui	a2,0x2
    80006024:	4581                	li	a1,0
    80006026:	854e                	mv	a0,s3
    80006028:	ffffb097          	auipc	ra,0xffffb
    8000602c:	d46080e7          	jalr	-698(ra) # 80000d6e <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    80006030:	040a8a93          	addi	s5,s5,64
    80006034:	9956                	add	s2,s2,s5
    80006036:	00c9d793          	srli	a5,s3,0xc
    8000603a:	2781                	sext.w	a5,a5
    8000603c:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80006040:	00149693          	slli	a3,s1,0x1
    80006044:	009687b3          	add	a5,a3,s1
    80006048:	07b2                	slli	a5,a5,0xc
    8000604a:	97d2                	add	a5,a5,s4
    8000604c:	6609                	lui	a2,0x2
    8000604e:	97b2                	add	a5,a5,a2
    80006050:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006054:	08098713          	addi	a4,s3,128
    80006058:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    8000605a:	6705                	lui	a4,0x1
    8000605c:	99ba                	add	s3,s3,a4
    8000605e:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80006062:	4705                	li	a4,1
    80006064:	00e78c23          	sb	a4,24(a5)
    80006068:	00e78ca3          	sb	a4,25(a5)
    8000606c:	00e78d23          	sb	a4,26(a5)
    80006070:	00e78da3          	sb	a4,27(a5)
    80006074:	00e78e23          	sb	a4,28(a5)
    80006078:	00e78ea3          	sb	a4,29(a5)
    8000607c:	00e78f23          	sb	a4,30(a5)
    80006080:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80006084:	0ae7a423          	sw	a4,168(a5)
}
    80006088:	70e2                	ld	ra,56(sp)
    8000608a:	7442                	ld	s0,48(sp)
    8000608c:	74a2                	ld	s1,40(sp)
    8000608e:	7902                	ld	s2,32(sp)
    80006090:	69e2                	ld	s3,24(sp)
    80006092:	6a42                	ld	s4,16(sp)
    80006094:	6aa2                	ld	s5,8(sp)
    80006096:	6121                	addi	sp,sp,64
    80006098:	8082                	ret
    panic("could not find virtio disk");
    8000609a:	00003517          	auipc	a0,0x3
    8000609e:	ac650513          	addi	a0,a0,-1338 # 80008b60 <userret+0xad0>
    800060a2:	ffffa097          	auipc	ra,0xffffa
    800060a6:	4b2080e7          	jalr	1202(ra) # 80000554 <panic>
    panic("virtio disk has no queue 0");
    800060aa:	00003517          	auipc	a0,0x3
    800060ae:	ad650513          	addi	a0,a0,-1322 # 80008b80 <userret+0xaf0>
    800060b2:	ffffa097          	auipc	ra,0xffffa
    800060b6:	4a2080e7          	jalr	1186(ra) # 80000554 <panic>
    panic("virtio disk max queue too short");
    800060ba:	00003517          	auipc	a0,0x3
    800060be:	ae650513          	addi	a0,a0,-1306 # 80008ba0 <userret+0xb10>
    800060c2:	ffffa097          	auipc	ra,0xffffa
    800060c6:	492080e7          	jalr	1170(ra) # 80000554 <panic>

00000000800060ca <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    800060ca:	7135                	addi	sp,sp,-160
    800060cc:	ed06                	sd	ra,152(sp)
    800060ce:	e922                	sd	s0,144(sp)
    800060d0:	e526                	sd	s1,136(sp)
    800060d2:	e14a                	sd	s2,128(sp)
    800060d4:	fcce                	sd	s3,120(sp)
    800060d6:	f8d2                	sd	s4,112(sp)
    800060d8:	f4d6                	sd	s5,104(sp)
    800060da:	f0da                	sd	s6,96(sp)
    800060dc:	ecde                	sd	s7,88(sp)
    800060de:	e8e2                	sd	s8,80(sp)
    800060e0:	e4e6                	sd	s9,72(sp)
    800060e2:	e0ea                	sd	s10,64(sp)
    800060e4:	fc6e                	sd	s11,56(sp)
    800060e6:	1100                	addi	s0,sp,160
    800060e8:	8aaa                	mv	s5,a0
    800060ea:	8c2e                	mv	s8,a1
    800060ec:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    800060ee:	45dc                	lw	a5,12(a1)
    800060f0:	0017979b          	slliw	a5,a5,0x1
    800060f4:	1782                	slli	a5,a5,0x20
    800060f6:	9381                	srli	a5,a5,0x20
    800060f8:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    800060fc:	00151493          	slli	s1,a0,0x1
    80006100:	94aa                	add	s1,s1,a0
    80006102:	04b2                	slli	s1,s1,0xc
    80006104:	6909                	lui	s2,0x2
    80006106:	0b090c93          	addi	s9,s2,176 # 20b0 <_entry-0x7fffdf50>
    8000610a:	9ca6                	add	s9,s9,s1
    8000610c:	0001c997          	auipc	s3,0x1c
    80006110:	ef498993          	addi	s3,s3,-268 # 80022000 <disk>
    80006114:	9cce                	add	s9,s9,s3
    80006116:	8566                	mv	a0,s9
    80006118:	ffffb097          	auipc	ra,0xffffb
    8000611c:	988080e7          	jalr	-1656(ra) # 80000aa0 <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006120:	0961                	addi	s2,s2,24
    80006122:	94ca                	add	s1,s1,s2
    80006124:	99a6                	add	s3,s3,s1
  for(int i = 0; i < 3; i++){
    80006126:	4a01                	li	s4,0
  for(int i = 0; i < NUM; i++){
    80006128:	44a1                	li	s1,8
      disk[n].free[i] = 0;
    8000612a:	001a9793          	slli	a5,s5,0x1
    8000612e:	97d6                	add	a5,a5,s5
    80006130:	07b2                	slli	a5,a5,0xc
    80006132:	0001cb97          	auipc	s7,0x1c
    80006136:	eceb8b93          	addi	s7,s7,-306 # 80022000 <disk>
    8000613a:	9bbe                	add	s7,s7,a5
    8000613c:	a8a9                	j	80006196 <virtio_disk_rw+0xcc>
    8000613e:	00fb8733          	add	a4,s7,a5
    80006142:	9742                	add	a4,a4,a6
    80006144:	00070c23          	sb	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    idx[i] = alloc_desc(n);
    80006148:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000614a:	0207c263          	bltz	a5,8000616e <virtio_disk_rw+0xa4>
  for(int i = 0; i < 3; i++){
    8000614e:	2905                	addiw	s2,s2,1
    80006150:	0611                	addi	a2,a2,4
    80006152:	1ca90463          	beq	s2,a0,8000631a <virtio_disk_rw+0x250>
    idx[i] = alloc_desc(n);
    80006156:	85b2                	mv	a1,a2
    80006158:	874e                	mv	a4,s3
  for(int i = 0; i < NUM; i++){
    8000615a:	87d2                	mv	a5,s4
    if(disk[n].free[i]){
    8000615c:	00074683          	lbu	a3,0(a4)
    80006160:	fef9                	bnez	a3,8000613e <virtio_disk_rw+0x74>
  for(int i = 0; i < NUM; i++){
    80006162:	2785                	addiw	a5,a5,1
    80006164:	0705                	addi	a4,a4,1
    80006166:	fe979be3          	bne	a5,s1,8000615c <virtio_disk_rw+0x92>
    idx[i] = alloc_desc(n);
    8000616a:	57fd                	li	a5,-1
    8000616c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000616e:	01205e63          	blez	s2,8000618a <virtio_disk_rw+0xc0>
    80006172:	8d52                	mv	s10,s4
        free_desc(n, idx[j]);
    80006174:	000b2583          	lw	a1,0(s6)
    80006178:	8556                	mv	a0,s5
    8000617a:	00000097          	auipc	ra,0x0
    8000617e:	ccc080e7          	jalr	-820(ra) # 80005e46 <free_desc>
      for(int j = 0; j < i; j++)
    80006182:	2d05                	addiw	s10,s10,1
    80006184:	0b11                	addi	s6,s6,4
    80006186:	ffa917e3          	bne	s2,s10,80006174 <virtio_disk_rw+0xaa>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    8000618a:	85e6                	mv	a1,s9
    8000618c:	854e                	mv	a0,s3
    8000618e:	ffffc097          	auipc	ra,0xffffc
    80006192:	08a080e7          	jalr	138(ra) # 80002218 <sleep>
  for(int i = 0; i < 3; i++){
    80006196:	f8040b13          	addi	s6,s0,-128
{
    8000619a:	865a                	mv	a2,s6
  for(int i = 0; i < 3; i++){
    8000619c:	8952                	mv	s2,s4
      disk[n].free[i] = 0;
    8000619e:	6809                	lui	a6,0x2
  for(int i = 0; i < 3; i++){
    800061a0:	450d                	li	a0,3
    800061a2:	bf55                	j	80006156 <virtio_disk_rw+0x8c>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    800061a4:	001a9793          	slli	a5,s5,0x1
    800061a8:	97d6                	add	a5,a5,s5
    800061aa:	07b2                	slli	a5,a5,0xc
    800061ac:	0001c717          	auipc	a4,0x1c
    800061b0:	e5470713          	addi	a4,a4,-428 # 80022000 <disk>
    800061b4:	973e                	add	a4,a4,a5
    800061b6:	6789                	lui	a5,0x2
    800061b8:	97ba                	add	a5,a5,a4
    800061ba:	639c                	ld	a5,0(a5)
    800061bc:	97b6                	add	a5,a5,a3
    800061be:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061c2:	0001c517          	auipc	a0,0x1c
    800061c6:	e3e50513          	addi	a0,a0,-450 # 80022000 <disk>
    800061ca:	001a9793          	slli	a5,s5,0x1
    800061ce:	01578733          	add	a4,a5,s5
    800061d2:	0732                	slli	a4,a4,0xc
    800061d4:	972a                	add	a4,a4,a0
    800061d6:	6609                	lui	a2,0x2
    800061d8:	9732                	add	a4,a4,a2
    800061da:	6310                	ld	a2,0(a4)
    800061dc:	9636                	add	a2,a2,a3
    800061de:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800061e2:	0015e593          	ori	a1,a1,1
    800061e6:	00b61623          	sh	a1,12(a2)
  disk[n].desc[idx[1]].next = idx[2];
    800061ea:	f8842603          	lw	a2,-120(s0)
    800061ee:	630c                	ld	a1,0(a4)
    800061f0:	96ae                	add	a3,a3,a1
    800061f2:	00c69723          	sh	a2,14(a3) # 100e <_entry-0x7fffeff2>

  disk[n].info[idx[0]].status = 0;
    800061f6:	97d6                	add	a5,a5,s5
    800061f8:	07a2                	slli	a5,a5,0x8
    800061fa:	97a6                	add	a5,a5,s1
    800061fc:	20078793          	addi	a5,a5,512
    80006200:	0792                	slli	a5,a5,0x4
    80006202:	97aa                	add	a5,a5,a0
    80006204:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006208:	00461693          	slli	a3,a2,0x4
    8000620c:	00073803          	ld	a6,0(a4)
    80006210:	9836                	add	a6,a6,a3
    80006212:	20348613          	addi	a2,s1,515
    80006216:	001a9593          	slli	a1,s5,0x1
    8000621a:	95d6                	add	a1,a1,s5
    8000621c:	05a2                	slli	a1,a1,0x8
    8000621e:	962e                	add	a2,a2,a1
    80006220:	0612                	slli	a2,a2,0x4
    80006222:	962a                	add	a2,a2,a0
    80006224:	00c83023          	sd	a2,0(a6) # 2000 <_entry-0x7fffe000>
  disk[n].desc[idx[2]].len = 1;
    80006228:	630c                	ld	a1,0(a4)
    8000622a:	95b6                	add	a1,a1,a3
    8000622c:	4605                	li	a2,1
    8000622e:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006230:	630c                	ld	a1,0(a4)
    80006232:	95b6                	add	a1,a1,a3
    80006234:	4509                	li	a0,2
    80006236:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    8000623a:	630c                	ld	a1,0(a4)
    8000623c:	96ae                	add	a3,a3,a1
    8000623e:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006242:	00cc2223          	sw	a2,4(s8) # fffffffffffff004 <end+0xffffffff7ffd6fa8>
  disk[n].info[idx[0]].b = b;
    80006246:	0387b423          	sd	s8,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    8000624a:	6714                	ld	a3,8(a4)
    8000624c:	0026d783          	lhu	a5,2(a3)
    80006250:	8b9d                	andi	a5,a5,7
    80006252:	0789                	addi	a5,a5,2
    80006254:	0786                	slli	a5,a5,0x1
    80006256:	97b6                	add	a5,a5,a3
    80006258:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    8000625c:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006260:	6718                	ld	a4,8(a4)
    80006262:	00275783          	lhu	a5,2(a4)
    80006266:	2785                	addiw	a5,a5,1
    80006268:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000626c:	001a879b          	addiw	a5,s5,1
    80006270:	00c7979b          	slliw	a5,a5,0xc
    80006274:	10000737          	lui	a4,0x10000
    80006278:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    8000627c:	97ba                	add	a5,a5,a4
    8000627e:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006282:	004c2783          	lw	a5,4(s8)
    80006286:	00c79d63          	bne	a5,a2,800062a0 <virtio_disk_rw+0x1d6>
    8000628a:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    8000628c:	85e6                	mv	a1,s9
    8000628e:	8562                	mv	a0,s8
    80006290:	ffffc097          	auipc	ra,0xffffc
    80006294:	f88080e7          	jalr	-120(ra) # 80002218 <sleep>
  while(b->disk == 1) {
    80006298:	004c2783          	lw	a5,4(s8)
    8000629c:	fe9788e3          	beq	a5,s1,8000628c <virtio_disk_rw+0x1c2>
  }

  disk[n].info[idx[0]].b = 0;
    800062a0:	f8042483          	lw	s1,-128(s0)
    800062a4:	001a9793          	slli	a5,s5,0x1
    800062a8:	97d6                	add	a5,a5,s5
    800062aa:	07a2                	slli	a5,a5,0x8
    800062ac:	97a6                	add	a5,a5,s1
    800062ae:	20078793          	addi	a5,a5,512
    800062b2:	0792                	slli	a5,a5,0x4
    800062b4:	0001c717          	auipc	a4,0x1c
    800062b8:	d4c70713          	addi	a4,a4,-692 # 80022000 <disk>
    800062bc:	97ba                	add	a5,a5,a4
    800062be:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800062c2:	001a9793          	slli	a5,s5,0x1
    800062c6:	97d6                	add	a5,a5,s5
    800062c8:	07b2                	slli	a5,a5,0xc
    800062ca:	97ba                	add	a5,a5,a4
    800062cc:	6909                	lui	s2,0x2
    800062ce:	993e                	add	s2,s2,a5
    800062d0:	a019                	j	800062d6 <virtio_disk_rw+0x20c>
      i = disk[n].desc[i].next;
    800062d2:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    800062d6:	85a6                	mv	a1,s1
    800062d8:	8556                	mv	a0,s5
    800062da:	00000097          	auipc	ra,0x0
    800062de:	b6c080e7          	jalr	-1172(ra) # 80005e46 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800062e2:	0492                	slli	s1,s1,0x4
    800062e4:	00093783          	ld	a5,0(s2) # 2000 <_entry-0x7fffe000>
    800062e8:	94be                	add	s1,s1,a5
    800062ea:	00c4d783          	lhu	a5,12(s1)
    800062ee:	8b85                	andi	a5,a5,1
    800062f0:	f3ed                	bnez	a5,800062d2 <virtio_disk_rw+0x208>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    800062f2:	8566                	mv	a0,s9
    800062f4:	ffffb097          	auipc	ra,0xffffb
    800062f8:	87c080e7          	jalr	-1924(ra) # 80000b70 <release>
}
    800062fc:	60ea                	ld	ra,152(sp)
    800062fe:	644a                	ld	s0,144(sp)
    80006300:	64aa                	ld	s1,136(sp)
    80006302:	690a                	ld	s2,128(sp)
    80006304:	79e6                	ld	s3,120(sp)
    80006306:	7a46                	ld	s4,112(sp)
    80006308:	7aa6                	ld	s5,104(sp)
    8000630a:	7b06                	ld	s6,96(sp)
    8000630c:	6be6                	ld	s7,88(sp)
    8000630e:	6c46                	ld	s8,80(sp)
    80006310:	6ca6                	ld	s9,72(sp)
    80006312:	6d06                	ld	s10,64(sp)
    80006314:	7de2                	ld	s11,56(sp)
    80006316:	610d                	addi	sp,sp,160
    80006318:	8082                	ret
  if(write)
    8000631a:	01b037b3          	snez	a5,s11
    8000631e:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006322:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006326:	f6843783          	ld	a5,-152(s0)
    8000632a:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000632e:	f8042483          	lw	s1,-128(s0)
    80006332:	00449993          	slli	s3,s1,0x4
    80006336:	001a9793          	slli	a5,s5,0x1
    8000633a:	97d6                	add	a5,a5,s5
    8000633c:	07b2                	slli	a5,a5,0xc
    8000633e:	0001c917          	auipc	s2,0x1c
    80006342:	cc290913          	addi	s2,s2,-830 # 80022000 <disk>
    80006346:	97ca                	add	a5,a5,s2
    80006348:	6909                	lui	s2,0x2
    8000634a:	993e                	add	s2,s2,a5
    8000634c:	00093a03          	ld	s4,0(s2) # 2000 <_entry-0x7fffe000>
    80006350:	9a4e                	add	s4,s4,s3
    80006352:	f7040513          	addi	a0,s0,-144
    80006356:	ffffb097          	auipc	ra,0xffffb
    8000635a:	e54080e7          	jalr	-428(ra) # 800011aa <kvmpa>
    8000635e:	00aa3023          	sd	a0,0(s4)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006362:	00093783          	ld	a5,0(s2)
    80006366:	97ce                	add	a5,a5,s3
    80006368:	4741                	li	a4,16
    8000636a:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000636c:	00093783          	ld	a5,0(s2)
    80006370:	97ce                	add	a5,a5,s3
    80006372:	4705                	li	a4,1
    80006374:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    80006378:	f8442683          	lw	a3,-124(s0)
    8000637c:	00093783          	ld	a5,0(s2)
    80006380:	99be                	add	s3,s3,a5
    80006382:	00d99723          	sh	a3,14(s3)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006386:	0692                	slli	a3,a3,0x4
    80006388:	00093783          	ld	a5,0(s2)
    8000638c:	97b6                	add	a5,a5,a3
    8000638e:	060c0713          	addi	a4,s8,96
    80006392:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006394:	00093783          	ld	a5,0(s2)
    80006398:	97b6                	add	a5,a5,a3
    8000639a:	40000713          	li	a4,1024
    8000639e:	c798                	sw	a4,8(a5)
  if(write)
    800063a0:	e00d92e3          	bnez	s11,800061a4 <virtio_disk_rw+0xda>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800063a4:	001a9793          	slli	a5,s5,0x1
    800063a8:	97d6                	add	a5,a5,s5
    800063aa:	07b2                	slli	a5,a5,0xc
    800063ac:	0001c717          	auipc	a4,0x1c
    800063b0:	c5470713          	addi	a4,a4,-940 # 80022000 <disk>
    800063b4:	973e                	add	a4,a4,a5
    800063b6:	6789                	lui	a5,0x2
    800063b8:	97ba                	add	a5,a5,a4
    800063ba:	639c                	ld	a5,0(a5)
    800063bc:	97b6                	add	a5,a5,a3
    800063be:	4709                	li	a4,2
    800063c0:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    800063c4:	bbfd                	j	800061c2 <virtio_disk_rw+0xf8>

00000000800063c6 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    800063c6:	7139                	addi	sp,sp,-64
    800063c8:	fc06                	sd	ra,56(sp)
    800063ca:	f822                	sd	s0,48(sp)
    800063cc:	f426                	sd	s1,40(sp)
    800063ce:	f04a                	sd	s2,32(sp)
    800063d0:	ec4e                	sd	s3,24(sp)
    800063d2:	e852                	sd	s4,16(sp)
    800063d4:	e456                	sd	s5,8(sp)
    800063d6:	0080                	addi	s0,sp,64
    800063d8:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    800063da:	00151913          	slli	s2,a0,0x1
    800063de:	00a90a33          	add	s4,s2,a0
    800063e2:	0a32                	slli	s4,s4,0xc
    800063e4:	6989                	lui	s3,0x2
    800063e6:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    800063ea:	9a3e                	add	s4,s4,a5
    800063ec:	0001ca97          	auipc	s5,0x1c
    800063f0:	c14a8a93          	addi	s5,s5,-1004 # 80022000 <disk>
    800063f4:	9a56                	add	s4,s4,s5
    800063f6:	8552                	mv	a0,s4
    800063f8:	ffffa097          	auipc	ra,0xffffa
    800063fc:	6a8080e7          	jalr	1704(ra) # 80000aa0 <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006400:	9926                	add	s2,s2,s1
    80006402:	0932                	slli	s2,s2,0xc
    80006404:	9956                	add	s2,s2,s5
    80006406:	99ca                	add	s3,s3,s2
    80006408:	0209d783          	lhu	a5,32(s3)
    8000640c:	0109b703          	ld	a4,16(s3)
    80006410:	00275683          	lhu	a3,2(a4)
    80006414:	8ebd                	xor	a3,a3,a5
    80006416:	8a9d                	andi	a3,a3,7
    80006418:	c2a5                	beqz	a3,80006478 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    8000641a:	8956                	mv	s2,s5
    8000641c:	00149693          	slli	a3,s1,0x1
    80006420:	96a6                	add	a3,a3,s1
    80006422:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006426:	06b2                	slli	a3,a3,0xc
    80006428:	96d6                	add	a3,a3,s5
    8000642a:	6489                	lui	s1,0x2
    8000642c:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    8000642e:	078e                	slli	a5,a5,0x3
    80006430:	97ba                	add	a5,a5,a4
    80006432:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006434:	00f98733          	add	a4,s3,a5
    80006438:	20070713          	addi	a4,a4,512
    8000643c:	0712                	slli	a4,a4,0x4
    8000643e:	974a                	add	a4,a4,s2
    80006440:	03074703          	lbu	a4,48(a4)
    80006444:	eb21                	bnez	a4,80006494 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006446:	97ce                	add	a5,a5,s3
    80006448:	20078793          	addi	a5,a5,512
    8000644c:	0792                	slli	a5,a5,0x4
    8000644e:	97ca                	add	a5,a5,s2
    80006450:	7798                	ld	a4,40(a5)
    80006452:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006456:	7788                	ld	a0,40(a5)
    80006458:	ffffc097          	auipc	ra,0xffffc
    8000645c:	f40080e7          	jalr	-192(ra) # 80002398 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006460:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006464:	2785                	addiw	a5,a5,1
    80006466:	8b9d                	andi	a5,a5,7
    80006468:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    8000646c:	6898                	ld	a4,16(s1)
    8000646e:	00275683          	lhu	a3,2(a4)
    80006472:	8a9d                	andi	a3,a3,7
    80006474:	faf69de3          	bne	a3,a5,8000642e <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    80006478:	8552                	mv	a0,s4
    8000647a:	ffffa097          	auipc	ra,0xffffa
    8000647e:	6f6080e7          	jalr	1782(ra) # 80000b70 <release>
}
    80006482:	70e2                	ld	ra,56(sp)
    80006484:	7442                	ld	s0,48(sp)
    80006486:	74a2                	ld	s1,40(sp)
    80006488:	7902                	ld	s2,32(sp)
    8000648a:	69e2                	ld	s3,24(sp)
    8000648c:	6a42                	ld	s4,16(sp)
    8000648e:	6aa2                	ld	s5,8(sp)
    80006490:	6121                	addi	sp,sp,64
    80006492:	8082                	ret
      panic("virtio_disk_intr status");
    80006494:	00002517          	auipc	a0,0x2
    80006498:	72c50513          	addi	a0,a0,1836 # 80008bc0 <userret+0xb30>
    8000649c:	ffffa097          	auipc	ra,0xffffa
    800064a0:	0b8080e7          	jalr	184(ra) # 80000554 <panic>

00000000800064a4 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    800064a4:	1141                	addi	sp,sp,-16
    800064a6:	e422                	sd	s0,8(sp)
    800064a8:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    800064aa:	41f5d79b          	sraiw	a5,a1,0x1f
    800064ae:	01d7d79b          	srliw	a5,a5,0x1d
    800064b2:	9dbd                	addw	a1,a1,a5
    800064b4:	0075f713          	andi	a4,a1,7
    800064b8:	9f1d                	subw	a4,a4,a5
    800064ba:	4785                	li	a5,1
    800064bc:	00e797bb          	sllw	a5,a5,a4
    800064c0:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    800064c4:	4035d59b          	sraiw	a1,a1,0x3
    800064c8:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    800064ca:	0005c503          	lbu	a0,0(a1)
    800064ce:	8d7d                	and	a0,a0,a5
    800064d0:	8d1d                	sub	a0,a0,a5
}
    800064d2:	00153513          	seqz	a0,a0
    800064d6:	6422                	ld	s0,8(sp)
    800064d8:	0141                	addi	sp,sp,16
    800064da:	8082                	ret

00000000800064dc <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    800064dc:	1141                	addi	sp,sp,-16
    800064de:	e422                	sd	s0,8(sp)
    800064e0:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800064e2:	41f5d79b          	sraiw	a5,a1,0x1f
    800064e6:	01d7d79b          	srliw	a5,a5,0x1d
    800064ea:	9dbd                	addw	a1,a1,a5
    800064ec:	4035d71b          	sraiw	a4,a1,0x3
    800064f0:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800064f2:	899d                	andi	a1,a1,7
    800064f4:	9d9d                	subw	a1,a1,a5
    800064f6:	4785                	li	a5,1
    800064f8:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    800064fc:	00054783          	lbu	a5,0(a0)
    80006500:	8ddd                	or	a1,a1,a5
    80006502:	00b50023          	sb	a1,0(a0)
}
    80006506:	6422                	ld	s0,8(sp)
    80006508:	0141                	addi	sp,sp,16
    8000650a:	8082                	ret

000000008000650c <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    8000650c:	1141                	addi	sp,sp,-16
    8000650e:	e422                	sd	s0,8(sp)
    80006510:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006512:	41f5d79b          	sraiw	a5,a1,0x1f
    80006516:	01d7d79b          	srliw	a5,a5,0x1d
    8000651a:	9dbd                	addw	a1,a1,a5
    8000651c:	4035d71b          	sraiw	a4,a1,0x3
    80006520:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006522:	899d                	andi	a1,a1,7
    80006524:	9d9d                	subw	a1,a1,a5
    80006526:	4785                	li	a5,1
    80006528:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    8000652c:	fff5c593          	not	a1,a1
    80006530:	00054783          	lbu	a5,0(a0)
    80006534:	8dfd                	and	a1,a1,a5
    80006536:	00b50023          	sb	a1,0(a0)
}
    8000653a:	6422                	ld	s0,8(sp)
    8000653c:	0141                	addi	sp,sp,16
    8000653e:	8082                	ret

0000000080006540 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006540:	715d                	addi	sp,sp,-80
    80006542:	e486                	sd	ra,72(sp)
    80006544:	e0a2                	sd	s0,64(sp)
    80006546:	fc26                	sd	s1,56(sp)
    80006548:	f84a                	sd	s2,48(sp)
    8000654a:	f44e                	sd	s3,40(sp)
    8000654c:	f052                	sd	s4,32(sp)
    8000654e:	ec56                	sd	s5,24(sp)
    80006550:	e85a                	sd	s6,16(sp)
    80006552:	e45e                	sd	s7,8(sp)
    80006554:	0880                	addi	s0,sp,80
    80006556:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006558:	08b05b63          	blez	a1,800065ee <bd_print_vector+0xae>
    8000655c:	89aa                	mv	s3,a0
    8000655e:	4481                	li	s1,0
  lb = 0;
    80006560:	4a81                	li	s5,0
  last = 1;
    80006562:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006564:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006566:	00002b97          	auipc	s7,0x2
    8000656a:	672b8b93          	addi	s7,s7,1650 # 80008bd8 <userret+0xb48>
    8000656e:	a821                	j	80006586 <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80006570:	85a6                	mv	a1,s1
    80006572:	854e                	mv	a0,s3
    80006574:	00000097          	auipc	ra,0x0
    80006578:	f30080e7          	jalr	-208(ra) # 800064a4 <bit_isset>
    8000657c:	892a                	mv	s2,a0
    8000657e:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006580:	2485                	addiw	s1,s1,1
    80006582:	029a0463          	beq	s4,s1,800065aa <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006586:	85a6                	mv	a1,s1
    80006588:	854e                	mv	a0,s3
    8000658a:	00000097          	auipc	ra,0x0
    8000658e:	f1a080e7          	jalr	-230(ra) # 800064a4 <bit_isset>
    80006592:	ff2507e3          	beq	a0,s2,80006580 <bd_print_vector+0x40>
    if(last == 1)
    80006596:	fd691de3          	bne	s2,s6,80006570 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    8000659a:	8626                	mv	a2,s1
    8000659c:	85d6                	mv	a1,s5
    8000659e:	855e                	mv	a0,s7
    800065a0:	ffffa097          	auipc	ra,0xffffa
    800065a4:	00e080e7          	jalr	14(ra) # 800005ae <printf>
    800065a8:	b7e1                	j	80006570 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    800065aa:	000a8563          	beqz	s5,800065b4 <bd_print_vector+0x74>
    800065ae:	4785                	li	a5,1
    800065b0:	00f91c63          	bne	s2,a5,800065c8 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    800065b4:	8652                	mv	a2,s4
    800065b6:	85d6                	mv	a1,s5
    800065b8:	00002517          	auipc	a0,0x2
    800065bc:	62050513          	addi	a0,a0,1568 # 80008bd8 <userret+0xb48>
    800065c0:	ffffa097          	auipc	ra,0xffffa
    800065c4:	fee080e7          	jalr	-18(ra) # 800005ae <printf>
  }
  printf("\n");
    800065c8:	00002517          	auipc	a0,0x2
    800065cc:	cc850513          	addi	a0,a0,-824 # 80008290 <userret+0x200>
    800065d0:	ffffa097          	auipc	ra,0xffffa
    800065d4:	fde080e7          	jalr	-34(ra) # 800005ae <printf>
}
    800065d8:	60a6                	ld	ra,72(sp)
    800065da:	6406                	ld	s0,64(sp)
    800065dc:	74e2                	ld	s1,56(sp)
    800065de:	7942                	ld	s2,48(sp)
    800065e0:	79a2                	ld	s3,40(sp)
    800065e2:	7a02                	ld	s4,32(sp)
    800065e4:	6ae2                	ld	s5,24(sp)
    800065e6:	6b42                	ld	s6,16(sp)
    800065e8:	6ba2                	ld	s7,8(sp)
    800065ea:	6161                	addi	sp,sp,80
    800065ec:	8082                	ret
  lb = 0;
    800065ee:	4a81                	li	s5,0
    800065f0:	b7d1                	j	800065b4 <bd_print_vector+0x74>

00000000800065f2 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    800065f2:	00022697          	auipc	a3,0x22
    800065f6:	a666a683          	lw	a3,-1434(a3) # 80028058 <nsizes>
    800065fa:	10d05063          	blez	a3,800066fa <bd_print+0x108>
bd_print() {
    800065fe:	711d                	addi	sp,sp,-96
    80006600:	ec86                	sd	ra,88(sp)
    80006602:	e8a2                	sd	s0,80(sp)
    80006604:	e4a6                	sd	s1,72(sp)
    80006606:	e0ca                	sd	s2,64(sp)
    80006608:	fc4e                	sd	s3,56(sp)
    8000660a:	f852                	sd	s4,48(sp)
    8000660c:	f456                	sd	s5,40(sp)
    8000660e:	f05a                	sd	s6,32(sp)
    80006610:	ec5e                	sd	s7,24(sp)
    80006612:	e862                	sd	s8,16(sp)
    80006614:	e466                	sd	s9,8(sp)
    80006616:	e06a                	sd	s10,0(sp)
    80006618:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    8000661a:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    8000661c:	4a85                	li	s5,1
    8000661e:	4c41                	li	s8,16
    80006620:	00002b97          	auipc	s7,0x2
    80006624:	5c8b8b93          	addi	s7,s7,1480 # 80008be8 <userret+0xb58>
    lst_print(&bd_sizes[k].free);
    80006628:	00022a17          	auipc	s4,0x22
    8000662c:	a28a0a13          	addi	s4,s4,-1496 # 80028050 <bd_sizes>
    printf("  alloc:");
    80006630:	00002b17          	auipc	s6,0x2
    80006634:	5e0b0b13          	addi	s6,s6,1504 # 80008c10 <userret+0xb80>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006638:	00022997          	auipc	s3,0x22
    8000663c:	a2098993          	addi	s3,s3,-1504 # 80028058 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006640:	00002c97          	auipc	s9,0x2
    80006644:	5e0c8c93          	addi	s9,s9,1504 # 80008c20 <userret+0xb90>
    80006648:	a801                	j	80006658 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    8000664a:	0009a683          	lw	a3,0(s3)
    8000664e:	0485                	addi	s1,s1,1
    80006650:	0004879b          	sext.w	a5,s1
    80006654:	08d7d563          	bge	a5,a3,800066de <bd_print+0xec>
    80006658:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    8000665c:	36fd                	addiw	a3,a3,-1
    8000665e:	9e85                	subw	a3,a3,s1
    80006660:	00da96bb          	sllw	a3,s5,a3
    80006664:	009c1633          	sll	a2,s8,s1
    80006668:	85ca                	mv	a1,s2
    8000666a:	855e                	mv	a0,s7
    8000666c:	ffffa097          	auipc	ra,0xffffa
    80006670:	f42080e7          	jalr	-190(ra) # 800005ae <printf>
    lst_print(&bd_sizes[k].free);
    80006674:	00549d13          	slli	s10,s1,0x5
    80006678:	000a3503          	ld	a0,0(s4)
    8000667c:	956a                	add	a0,a0,s10
    8000667e:	00001097          	auipc	ra,0x1
    80006682:	a56080e7          	jalr	-1450(ra) # 800070d4 <lst_print>
    printf("  alloc:");
    80006686:	855a                	mv	a0,s6
    80006688:	ffffa097          	auipc	ra,0xffffa
    8000668c:	f26080e7          	jalr	-218(ra) # 800005ae <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006690:	0009a583          	lw	a1,0(s3)
    80006694:	35fd                	addiw	a1,a1,-1
    80006696:	412585bb          	subw	a1,a1,s2
    8000669a:	000a3783          	ld	a5,0(s4)
    8000669e:	97ea                	add	a5,a5,s10
    800066a0:	00ba95bb          	sllw	a1,s5,a1
    800066a4:	6b88                	ld	a0,16(a5)
    800066a6:	00000097          	auipc	ra,0x0
    800066aa:	e9a080e7          	jalr	-358(ra) # 80006540 <bd_print_vector>
    if(k > 0) {
    800066ae:	f9205ee3          	blez	s2,8000664a <bd_print+0x58>
      printf("  split:");
    800066b2:	8566                	mv	a0,s9
    800066b4:	ffffa097          	auipc	ra,0xffffa
    800066b8:	efa080e7          	jalr	-262(ra) # 800005ae <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    800066bc:	0009a583          	lw	a1,0(s3)
    800066c0:	35fd                	addiw	a1,a1,-1
    800066c2:	412585bb          	subw	a1,a1,s2
    800066c6:	000a3783          	ld	a5,0(s4)
    800066ca:	9d3e                	add	s10,s10,a5
    800066cc:	00ba95bb          	sllw	a1,s5,a1
    800066d0:	018d3503          	ld	a0,24(s10)
    800066d4:	00000097          	auipc	ra,0x0
    800066d8:	e6c080e7          	jalr	-404(ra) # 80006540 <bd_print_vector>
    800066dc:	b7bd                	j	8000664a <bd_print+0x58>
    }
  }
}
    800066de:	60e6                	ld	ra,88(sp)
    800066e0:	6446                	ld	s0,80(sp)
    800066e2:	64a6                	ld	s1,72(sp)
    800066e4:	6906                	ld	s2,64(sp)
    800066e6:	79e2                	ld	s3,56(sp)
    800066e8:	7a42                	ld	s4,48(sp)
    800066ea:	7aa2                	ld	s5,40(sp)
    800066ec:	7b02                	ld	s6,32(sp)
    800066ee:	6be2                	ld	s7,24(sp)
    800066f0:	6c42                	ld	s8,16(sp)
    800066f2:	6ca2                	ld	s9,8(sp)
    800066f4:	6d02                	ld	s10,0(sp)
    800066f6:	6125                	addi	sp,sp,96
    800066f8:	8082                	ret
    800066fa:	8082                	ret

00000000800066fc <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800066fc:	1141                	addi	sp,sp,-16
    800066fe:	e422                	sd	s0,8(sp)
    80006700:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006702:	47c1                	li	a5,16
    80006704:	00a7fb63          	bgeu	a5,a0,8000671a <firstk+0x1e>
    80006708:	872a                	mv	a4,a0
  int k = 0;
    8000670a:	4501                	li	a0,0
    k++;
    8000670c:	2505                	addiw	a0,a0,1
    size *= 2;
    8000670e:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006710:	fee7eee3          	bltu	a5,a4,8000670c <firstk+0x10>
  }
  return k;
}
    80006714:	6422                	ld	s0,8(sp)
    80006716:	0141                	addi	sp,sp,16
    80006718:	8082                	ret
  int k = 0;
    8000671a:	4501                	li	a0,0
    8000671c:	bfe5                	j	80006714 <firstk+0x18>

000000008000671e <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    8000671e:	1141                	addi	sp,sp,-16
    80006720:	e422                	sd	s0,8(sp)
    80006722:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006724:	00022797          	auipc	a5,0x22
    80006728:	9247b783          	ld	a5,-1756(a5) # 80028048 <bd_base>
    8000672c:	9d9d                	subw	a1,a1,a5
    8000672e:	47c1                	li	a5,16
    80006730:	00a797b3          	sll	a5,a5,a0
    80006734:	02f5c5b3          	div	a1,a1,a5
}
    80006738:	0005851b          	sext.w	a0,a1
    8000673c:	6422                	ld	s0,8(sp)
    8000673e:	0141                	addi	sp,sp,16
    80006740:	8082                	ret

0000000080006742 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006742:	1141                	addi	sp,sp,-16
    80006744:	e422                	sd	s0,8(sp)
    80006746:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006748:	47c1                	li	a5,16
    8000674a:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    8000674e:	02b787bb          	mulw	a5,a5,a1
}
    80006752:	00022517          	auipc	a0,0x22
    80006756:	8f653503          	ld	a0,-1802(a0) # 80028048 <bd_base>
    8000675a:	953e                	add	a0,a0,a5
    8000675c:	6422                	ld	s0,8(sp)
    8000675e:	0141                	addi	sp,sp,16
    80006760:	8082                	ret

0000000080006762 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006762:	7159                	addi	sp,sp,-112
    80006764:	f486                	sd	ra,104(sp)
    80006766:	f0a2                	sd	s0,96(sp)
    80006768:	eca6                	sd	s1,88(sp)
    8000676a:	e8ca                	sd	s2,80(sp)
    8000676c:	e4ce                	sd	s3,72(sp)
    8000676e:	e0d2                	sd	s4,64(sp)
    80006770:	fc56                	sd	s5,56(sp)
    80006772:	f85a                	sd	s6,48(sp)
    80006774:	f45e                	sd	s7,40(sp)
    80006776:	f062                	sd	s8,32(sp)
    80006778:	ec66                	sd	s9,24(sp)
    8000677a:	e86a                	sd	s10,16(sp)
    8000677c:	e46e                	sd	s11,8(sp)
    8000677e:	1880                	addi	s0,sp,112
    80006780:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006782:	00022517          	auipc	a0,0x22
    80006786:	87e50513          	addi	a0,a0,-1922 # 80028000 <lock>
    8000678a:	ffffa097          	auipc	ra,0xffffa
    8000678e:	316080e7          	jalr	790(ra) # 80000aa0 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006792:	8526                	mv	a0,s1
    80006794:	00000097          	auipc	ra,0x0
    80006798:	f68080e7          	jalr	-152(ra) # 800066fc <firstk>
  for (k = fk; k < nsizes; k++) {
    8000679c:	00022797          	auipc	a5,0x22
    800067a0:	8bc7a783          	lw	a5,-1860(a5) # 80028058 <nsizes>
    800067a4:	02f55d63          	bge	a0,a5,800067de <bd_malloc+0x7c>
    800067a8:	8c2a                	mv	s8,a0
    800067aa:	00551913          	slli	s2,a0,0x5
    800067ae:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    800067b0:	00022997          	auipc	s3,0x22
    800067b4:	8a098993          	addi	s3,s3,-1888 # 80028050 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    800067b8:	00022a17          	auipc	s4,0x22
    800067bc:	8a0a0a13          	addi	s4,s4,-1888 # 80028058 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    800067c0:	0009b503          	ld	a0,0(s3)
    800067c4:	954a                	add	a0,a0,s2
    800067c6:	00001097          	auipc	ra,0x1
    800067ca:	894080e7          	jalr	-1900(ra) # 8000705a <lst_empty>
    800067ce:	c115                	beqz	a0,800067f2 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    800067d0:	2485                	addiw	s1,s1,1
    800067d2:	02090913          	addi	s2,s2,32
    800067d6:	000a2783          	lw	a5,0(s4)
    800067da:	fef4c3e3          	blt	s1,a5,800067c0 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    800067de:	00022517          	auipc	a0,0x22
    800067e2:	82250513          	addi	a0,a0,-2014 # 80028000 <lock>
    800067e6:	ffffa097          	auipc	ra,0xffffa
    800067ea:	38a080e7          	jalr	906(ra) # 80000b70 <release>
    return 0;
    800067ee:	4b01                	li	s6,0
    800067f0:	a0e1                	j	800068b8 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    800067f2:	00022797          	auipc	a5,0x22
    800067f6:	8667a783          	lw	a5,-1946(a5) # 80028058 <nsizes>
    800067fa:	fef4d2e3          	bge	s1,a5,800067de <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    800067fe:	00549993          	slli	s3,s1,0x5
    80006802:	00022917          	auipc	s2,0x22
    80006806:	84e90913          	addi	s2,s2,-1970 # 80028050 <bd_sizes>
    8000680a:	00093503          	ld	a0,0(s2)
    8000680e:	954e                	add	a0,a0,s3
    80006810:	00001097          	auipc	ra,0x1
    80006814:	876080e7          	jalr	-1930(ra) # 80007086 <lst_pop>
    80006818:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    8000681a:	00022597          	auipc	a1,0x22
    8000681e:	82e5b583          	ld	a1,-2002(a1) # 80028048 <bd_base>
    80006822:	40b505bb          	subw	a1,a0,a1
    80006826:	47c1                	li	a5,16
    80006828:	009797b3          	sll	a5,a5,s1
    8000682c:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006830:	00093783          	ld	a5,0(s2)
    80006834:	97ce                	add	a5,a5,s3
    80006836:	2581                	sext.w	a1,a1
    80006838:	6b88                	ld	a0,16(a5)
    8000683a:	00000097          	auipc	ra,0x0
    8000683e:	ca2080e7          	jalr	-862(ra) # 800064dc <bit_set>
  for(; k > fk; k--) {
    80006842:	069c5363          	bge	s8,s1,800068a8 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006846:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006848:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    8000684a:	00021d17          	auipc	s10,0x21
    8000684e:	7fed0d13          	addi	s10,s10,2046 # 80028048 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006852:	85a6                	mv	a1,s1
    80006854:	34fd                	addiw	s1,s1,-1
    80006856:	009b9ab3          	sll	s5,s7,s1
    8000685a:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    8000685e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
  int n = p - (char *) bd_base;
    80006862:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006866:	412b093b          	subw	s2,s6,s2
    8000686a:	00bb95b3          	sll	a1,s7,a1
    8000686e:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006872:	013a07b3          	add	a5,s4,s3
    80006876:	2581                	sext.w	a1,a1
    80006878:	6f88                	ld	a0,24(a5)
    8000687a:	00000097          	auipc	ra,0x0
    8000687e:	c62080e7          	jalr	-926(ra) # 800064dc <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006882:	1981                	addi	s3,s3,-32
    80006884:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006886:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    8000688a:	2581                	sext.w	a1,a1
    8000688c:	010a3503          	ld	a0,16(s4)
    80006890:	00000097          	auipc	ra,0x0
    80006894:	c4c080e7          	jalr	-948(ra) # 800064dc <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006898:	85e6                	mv	a1,s9
    8000689a:	8552                	mv	a0,s4
    8000689c:	00001097          	auipc	ra,0x1
    800068a0:	820080e7          	jalr	-2016(ra) # 800070bc <lst_push>
  for(; k > fk; k--) {
    800068a4:	fb8497e3          	bne	s1,s8,80006852 <bd_malloc+0xf0>
  }
  release(&lock);
    800068a8:	00021517          	auipc	a0,0x21
    800068ac:	75850513          	addi	a0,a0,1880 # 80028000 <lock>
    800068b0:	ffffa097          	auipc	ra,0xffffa
    800068b4:	2c0080e7          	jalr	704(ra) # 80000b70 <release>

  return p;
}
    800068b8:	855a                	mv	a0,s6
    800068ba:	70a6                	ld	ra,104(sp)
    800068bc:	7406                	ld	s0,96(sp)
    800068be:	64e6                	ld	s1,88(sp)
    800068c0:	6946                	ld	s2,80(sp)
    800068c2:	69a6                	ld	s3,72(sp)
    800068c4:	6a06                	ld	s4,64(sp)
    800068c6:	7ae2                	ld	s5,56(sp)
    800068c8:	7b42                	ld	s6,48(sp)
    800068ca:	7ba2                	ld	s7,40(sp)
    800068cc:	7c02                	ld	s8,32(sp)
    800068ce:	6ce2                	ld	s9,24(sp)
    800068d0:	6d42                	ld	s10,16(sp)
    800068d2:	6da2                	ld	s11,8(sp)
    800068d4:	6165                	addi	sp,sp,112
    800068d6:	8082                	ret

00000000800068d8 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    800068d8:	7139                	addi	sp,sp,-64
    800068da:	fc06                	sd	ra,56(sp)
    800068dc:	f822                	sd	s0,48(sp)
    800068de:	f426                	sd	s1,40(sp)
    800068e0:	f04a                	sd	s2,32(sp)
    800068e2:	ec4e                	sd	s3,24(sp)
    800068e4:	e852                	sd	s4,16(sp)
    800068e6:	e456                	sd	s5,8(sp)
    800068e8:	e05a                	sd	s6,0(sp)
    800068ea:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    800068ec:	00021a97          	auipc	s5,0x21
    800068f0:	76caaa83          	lw	s5,1900(s5) # 80028058 <nsizes>
  return n / BLK_SIZE(k);
    800068f4:	00021a17          	auipc	s4,0x21
    800068f8:	754a3a03          	ld	s4,1876(s4) # 80028048 <bd_base>
    800068fc:	41450a3b          	subw	s4,a0,s4
    80006900:	00021497          	auipc	s1,0x21
    80006904:	7504b483          	ld	s1,1872(s1) # 80028050 <bd_sizes>
    80006908:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    8000690c:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    8000690e:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006910:	03595363          	bge	s2,s5,80006936 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006914:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006918:	013b15b3          	sll	a1,s6,s3
    8000691c:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006920:	2581                	sext.w	a1,a1
    80006922:	6088                	ld	a0,0(s1)
    80006924:	00000097          	auipc	ra,0x0
    80006928:	b80080e7          	jalr	-1152(ra) # 800064a4 <bit_isset>
    8000692c:	02048493          	addi	s1,s1,32
    80006930:	e501                	bnez	a0,80006938 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006932:	894e                	mv	s2,s3
    80006934:	bff1                	j	80006910 <size+0x38>
      return k;
    }
  }
  return 0;
    80006936:	4901                	li	s2,0
}
    80006938:	854a                	mv	a0,s2
    8000693a:	70e2                	ld	ra,56(sp)
    8000693c:	7442                	ld	s0,48(sp)
    8000693e:	74a2                	ld	s1,40(sp)
    80006940:	7902                	ld	s2,32(sp)
    80006942:	69e2                	ld	s3,24(sp)
    80006944:	6a42                	ld	s4,16(sp)
    80006946:	6aa2                	ld	s5,8(sp)
    80006948:	6b02                	ld	s6,0(sp)
    8000694a:	6121                	addi	sp,sp,64
    8000694c:	8082                	ret

000000008000694e <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    8000694e:	7159                	addi	sp,sp,-112
    80006950:	f486                	sd	ra,104(sp)
    80006952:	f0a2                	sd	s0,96(sp)
    80006954:	eca6                	sd	s1,88(sp)
    80006956:	e8ca                	sd	s2,80(sp)
    80006958:	e4ce                	sd	s3,72(sp)
    8000695a:	e0d2                	sd	s4,64(sp)
    8000695c:	fc56                	sd	s5,56(sp)
    8000695e:	f85a                	sd	s6,48(sp)
    80006960:	f45e                	sd	s7,40(sp)
    80006962:	f062                	sd	s8,32(sp)
    80006964:	ec66                	sd	s9,24(sp)
    80006966:	e86a                	sd	s10,16(sp)
    80006968:	e46e                	sd	s11,8(sp)
    8000696a:	1880                	addi	s0,sp,112
    8000696c:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    8000696e:	00021517          	auipc	a0,0x21
    80006972:	69250513          	addi	a0,a0,1682 # 80028000 <lock>
    80006976:	ffffa097          	auipc	ra,0xffffa
    8000697a:	12a080e7          	jalr	298(ra) # 80000aa0 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    8000697e:	8556                	mv	a0,s5
    80006980:	00000097          	auipc	ra,0x0
    80006984:	f58080e7          	jalr	-168(ra) # 800068d8 <size>
    80006988:	84aa                	mv	s1,a0
    8000698a:	00021797          	auipc	a5,0x21
    8000698e:	6ce7a783          	lw	a5,1742(a5) # 80028058 <nsizes>
    80006992:	37fd                	addiw	a5,a5,-1
    80006994:	0cf55063          	bge	a0,a5,80006a54 <bd_free+0x106>
    80006998:	00150a13          	addi	s4,a0,1
    8000699c:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    8000699e:	00021c17          	auipc	s8,0x21
    800069a2:	6aac0c13          	addi	s8,s8,1706 # 80028048 <bd_base>
  return n / BLK_SIZE(k);
    800069a6:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    800069a8:	00021b17          	auipc	s6,0x21
    800069ac:	6a8b0b13          	addi	s6,s6,1704 # 80028050 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    800069b0:	00021c97          	auipc	s9,0x21
    800069b4:	6a8c8c93          	addi	s9,s9,1704 # 80028058 <nsizes>
    800069b8:	a82d                	j	800069f2 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800069ba:	fff58d9b          	addiw	s11,a1,-1
    800069be:	a881                	j	80006a0e <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    800069c0:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    800069c2:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    800069c6:	40ba85bb          	subw	a1,s5,a1
    800069ca:	009b97b3          	sll	a5,s7,s1
    800069ce:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    800069d2:	000b3783          	ld	a5,0(s6)
    800069d6:	97d2                	add	a5,a5,s4
    800069d8:	2581                	sext.w	a1,a1
    800069da:	6f88                	ld	a0,24(a5)
    800069dc:	00000097          	auipc	ra,0x0
    800069e0:	b30080e7          	jalr	-1232(ra) # 8000650c <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    800069e4:	020a0a13          	addi	s4,s4,32
    800069e8:	000ca783          	lw	a5,0(s9)
    800069ec:	37fd                	addiw	a5,a5,-1
    800069ee:	06f4d363          	bge	s1,a5,80006a54 <bd_free+0x106>
  int n = p - (char *) bd_base;
    800069f2:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    800069f6:	009b99b3          	sll	s3,s7,s1
    800069fa:	412a87bb          	subw	a5,s5,s2
    800069fe:	0337c7b3          	div	a5,a5,s3
    80006a02:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006a06:	8b85                	andi	a5,a5,1
    80006a08:	fbcd                	bnez	a5,800069ba <bd_free+0x6c>
    80006a0a:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006a0e:	fe0a0d13          	addi	s10,s4,-32
    80006a12:	000b3783          	ld	a5,0(s6)
    80006a16:	9d3e                	add	s10,s10,a5
    80006a18:	010d3503          	ld	a0,16(s10)
    80006a1c:	00000097          	auipc	ra,0x0
    80006a20:	af0080e7          	jalr	-1296(ra) # 8000650c <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006a24:	85ee                	mv	a1,s11
    80006a26:	010d3503          	ld	a0,16(s10)
    80006a2a:	00000097          	auipc	ra,0x0
    80006a2e:	a7a080e7          	jalr	-1414(ra) # 800064a4 <bit_isset>
    80006a32:	e10d                	bnez	a0,80006a54 <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    80006a34:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006a38:	03b989bb          	mulw	s3,s3,s11
    80006a3c:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006a3e:	854a                	mv	a0,s2
    80006a40:	00000097          	auipc	ra,0x0
    80006a44:	630080e7          	jalr	1584(ra) # 80007070 <lst_remove>
    if(buddy % 2 == 0) {
    80006a48:	001d7d13          	andi	s10,s10,1
    80006a4c:	f60d1ae3          	bnez	s10,800069c0 <bd_free+0x72>
      p = q;
    80006a50:	8aca                	mv	s5,s2
    80006a52:	b7bd                	j	800069c0 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    80006a54:	0496                	slli	s1,s1,0x5
    80006a56:	85d6                	mv	a1,s5
    80006a58:	00021517          	auipc	a0,0x21
    80006a5c:	5f853503          	ld	a0,1528(a0) # 80028050 <bd_sizes>
    80006a60:	9526                	add	a0,a0,s1
    80006a62:	00000097          	auipc	ra,0x0
    80006a66:	65a080e7          	jalr	1626(ra) # 800070bc <lst_push>
  release(&lock);
    80006a6a:	00021517          	auipc	a0,0x21
    80006a6e:	59650513          	addi	a0,a0,1430 # 80028000 <lock>
    80006a72:	ffffa097          	auipc	ra,0xffffa
    80006a76:	0fe080e7          	jalr	254(ra) # 80000b70 <release>
}
    80006a7a:	70a6                	ld	ra,104(sp)
    80006a7c:	7406                	ld	s0,96(sp)
    80006a7e:	64e6                	ld	s1,88(sp)
    80006a80:	6946                	ld	s2,80(sp)
    80006a82:	69a6                	ld	s3,72(sp)
    80006a84:	6a06                	ld	s4,64(sp)
    80006a86:	7ae2                	ld	s5,56(sp)
    80006a88:	7b42                	ld	s6,48(sp)
    80006a8a:	7ba2                	ld	s7,40(sp)
    80006a8c:	7c02                	ld	s8,32(sp)
    80006a8e:	6ce2                	ld	s9,24(sp)
    80006a90:	6d42                	ld	s10,16(sp)
    80006a92:	6da2                	ld	s11,8(sp)
    80006a94:	6165                	addi	sp,sp,112
    80006a96:	8082                	ret

0000000080006a98 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006a98:	1141                	addi	sp,sp,-16
    80006a9a:	e422                	sd	s0,8(sp)
    80006a9c:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006a9e:	00021797          	auipc	a5,0x21
    80006aa2:	5aa7b783          	ld	a5,1450(a5) # 80028048 <bd_base>
    80006aa6:	8d9d                	sub	a1,a1,a5
    80006aa8:	47c1                	li	a5,16
    80006aaa:	00a797b3          	sll	a5,a5,a0
    80006aae:	02f5c533          	div	a0,a1,a5
    80006ab2:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006ab4:	02f5e5b3          	rem	a1,a1,a5
    80006ab8:	c191                	beqz	a1,80006abc <blk_index_next+0x24>
      n++;
    80006aba:	2505                	addiw	a0,a0,1
  return n ;
}
    80006abc:	6422                	ld	s0,8(sp)
    80006abe:	0141                	addi	sp,sp,16
    80006ac0:	8082                	ret

0000000080006ac2 <log2>:

int
log2(uint64 n) {
    80006ac2:	1141                	addi	sp,sp,-16
    80006ac4:	e422                	sd	s0,8(sp)
    80006ac6:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006ac8:	4705                	li	a4,1
    80006aca:	00a77b63          	bgeu	a4,a0,80006ae0 <log2+0x1e>
    80006ace:	87aa                	mv	a5,a0
  int k = 0;
    80006ad0:	4501                	li	a0,0
    k++;
    80006ad2:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006ad4:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006ad6:	fef76ee3          	bltu	a4,a5,80006ad2 <log2+0x10>
  }
  return k;
}
    80006ada:	6422                	ld	s0,8(sp)
    80006adc:	0141                	addi	sp,sp,16
    80006ade:	8082                	ret
  int k = 0;
    80006ae0:	4501                	li	a0,0
    80006ae2:	bfe5                	j	80006ada <log2+0x18>

0000000080006ae4 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006ae4:	711d                	addi	sp,sp,-96
    80006ae6:	ec86                	sd	ra,88(sp)
    80006ae8:	e8a2                	sd	s0,80(sp)
    80006aea:	e4a6                	sd	s1,72(sp)
    80006aec:	e0ca                	sd	s2,64(sp)
    80006aee:	fc4e                	sd	s3,56(sp)
    80006af0:	f852                	sd	s4,48(sp)
    80006af2:	f456                	sd	s5,40(sp)
    80006af4:	f05a                	sd	s6,32(sp)
    80006af6:	ec5e                	sd	s7,24(sp)
    80006af8:	e862                	sd	s8,16(sp)
    80006afa:	e466                	sd	s9,8(sp)
    80006afc:	e06a                	sd	s10,0(sp)
    80006afe:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006b00:	00b56933          	or	s2,a0,a1
    80006b04:	00f97913          	andi	s2,s2,15
    80006b08:	04091263          	bnez	s2,80006b4c <bd_mark+0x68>
    80006b0c:	8b2a                	mv	s6,a0
    80006b0e:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006b10:	00021c17          	auipc	s8,0x21
    80006b14:	548c2c03          	lw	s8,1352(s8) # 80028058 <nsizes>
    80006b18:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006b1a:	00021d17          	auipc	s10,0x21
    80006b1e:	52ed0d13          	addi	s10,s10,1326 # 80028048 <bd_base>
  return n / BLK_SIZE(k);
    80006b22:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006b24:	00021a97          	auipc	s5,0x21
    80006b28:	52ca8a93          	addi	s5,s5,1324 # 80028050 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006b2c:	07804563          	bgtz	s8,80006b96 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006b30:	60e6                	ld	ra,88(sp)
    80006b32:	6446                	ld	s0,80(sp)
    80006b34:	64a6                	ld	s1,72(sp)
    80006b36:	6906                	ld	s2,64(sp)
    80006b38:	79e2                	ld	s3,56(sp)
    80006b3a:	7a42                	ld	s4,48(sp)
    80006b3c:	7aa2                	ld	s5,40(sp)
    80006b3e:	7b02                	ld	s6,32(sp)
    80006b40:	6be2                	ld	s7,24(sp)
    80006b42:	6c42                	ld	s8,16(sp)
    80006b44:	6ca2                	ld	s9,8(sp)
    80006b46:	6d02                	ld	s10,0(sp)
    80006b48:	6125                	addi	sp,sp,96
    80006b4a:	8082                	ret
    panic("bd_mark");
    80006b4c:	00002517          	auipc	a0,0x2
    80006b50:	0e450513          	addi	a0,a0,228 # 80008c30 <userret+0xba0>
    80006b54:	ffffa097          	auipc	ra,0xffffa
    80006b58:	a00080e7          	jalr	-1536(ra) # 80000554 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006b5c:	000ab783          	ld	a5,0(s5)
    80006b60:	97ca                	add	a5,a5,s2
    80006b62:	85a6                	mv	a1,s1
    80006b64:	6b88                	ld	a0,16(a5)
    80006b66:	00000097          	auipc	ra,0x0
    80006b6a:	976080e7          	jalr	-1674(ra) # 800064dc <bit_set>
    for(; bi < bj; bi++) {
    80006b6e:	2485                	addiw	s1,s1,1
    80006b70:	009a0e63          	beq	s4,s1,80006b8c <bd_mark+0xa8>
      if(k > 0) {
    80006b74:	ff3054e3          	blez	s3,80006b5c <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006b78:	000ab783          	ld	a5,0(s5)
    80006b7c:	97ca                	add	a5,a5,s2
    80006b7e:	85a6                	mv	a1,s1
    80006b80:	6f88                	ld	a0,24(a5)
    80006b82:	00000097          	auipc	ra,0x0
    80006b86:	95a080e7          	jalr	-1702(ra) # 800064dc <bit_set>
    80006b8a:	bfc9                	j	80006b5c <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006b8c:	2985                	addiw	s3,s3,1
    80006b8e:	02090913          	addi	s2,s2,32
    80006b92:	f9898fe3          	beq	s3,s8,80006b30 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006b96:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006b9a:	409b04bb          	subw	s1,s6,s1
    80006b9e:	013c97b3          	sll	a5,s9,s3
    80006ba2:	02f4c4b3          	div	s1,s1,a5
    80006ba6:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006ba8:	85de                	mv	a1,s7
    80006baa:	854e                	mv	a0,s3
    80006bac:	00000097          	auipc	ra,0x0
    80006bb0:	eec080e7          	jalr	-276(ra) # 80006a98 <blk_index_next>
    80006bb4:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006bb6:	faa4cfe3          	blt	s1,a0,80006b74 <bd_mark+0x90>
    80006bba:	bfc9                	j	80006b8c <bd_mark+0xa8>

0000000080006bbc <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006bbc:	7139                	addi	sp,sp,-64
    80006bbe:	fc06                	sd	ra,56(sp)
    80006bc0:	f822                	sd	s0,48(sp)
    80006bc2:	f426                	sd	s1,40(sp)
    80006bc4:	f04a                	sd	s2,32(sp)
    80006bc6:	ec4e                	sd	s3,24(sp)
    80006bc8:	e852                	sd	s4,16(sp)
    80006bca:	e456                	sd	s5,8(sp)
    80006bcc:	e05a                	sd	s6,0(sp)
    80006bce:	0080                	addi	s0,sp,64
    80006bd0:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006bd2:	00058a9b          	sext.w	s5,a1
    80006bd6:	0015f793          	andi	a5,a1,1
    80006bda:	ebad                	bnez	a5,80006c4c <bd_initfree_pair+0x90>
    80006bdc:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006be0:	00599493          	slli	s1,s3,0x5
    80006be4:	00021797          	auipc	a5,0x21
    80006be8:	46c7b783          	ld	a5,1132(a5) # 80028050 <bd_sizes>
    80006bec:	94be                	add	s1,s1,a5
    80006bee:	0104bb03          	ld	s6,16(s1)
    80006bf2:	855a                	mv	a0,s6
    80006bf4:	00000097          	auipc	ra,0x0
    80006bf8:	8b0080e7          	jalr	-1872(ra) # 800064a4 <bit_isset>
    80006bfc:	892a                	mv	s2,a0
    80006bfe:	85d2                	mv	a1,s4
    80006c00:	855a                	mv	a0,s6
    80006c02:	00000097          	auipc	ra,0x0
    80006c06:	8a2080e7          	jalr	-1886(ra) # 800064a4 <bit_isset>
  int free = 0;
    80006c0a:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006c0c:	02a90563          	beq	s2,a0,80006c36 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006c10:	45c1                	li	a1,16
    80006c12:	013599b3          	sll	s3,a1,s3
    80006c16:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006c1a:	02090c63          	beqz	s2,80006c52 <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006c1e:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006c22:	00021597          	auipc	a1,0x21
    80006c26:	4265b583          	ld	a1,1062(a1) # 80028048 <bd_base>
    80006c2a:	95ce                	add	a1,a1,s3
    80006c2c:	8526                	mv	a0,s1
    80006c2e:	00000097          	auipc	ra,0x0
    80006c32:	48e080e7          	jalr	1166(ra) # 800070bc <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006c36:	855a                	mv	a0,s6
    80006c38:	70e2                	ld	ra,56(sp)
    80006c3a:	7442                	ld	s0,48(sp)
    80006c3c:	74a2                	ld	s1,40(sp)
    80006c3e:	7902                	ld	s2,32(sp)
    80006c40:	69e2                	ld	s3,24(sp)
    80006c42:	6a42                	ld	s4,16(sp)
    80006c44:	6aa2                	ld	s5,8(sp)
    80006c46:	6b02                	ld	s6,0(sp)
    80006c48:	6121                	addi	sp,sp,64
    80006c4a:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006c4c:	fff58a1b          	addiw	s4,a1,-1
    80006c50:	bf41                	j	80006be0 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006c52:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006c56:	00021597          	auipc	a1,0x21
    80006c5a:	3f25b583          	ld	a1,1010(a1) # 80028048 <bd_base>
    80006c5e:	95ce                	add	a1,a1,s3
    80006c60:	8526                	mv	a0,s1
    80006c62:	00000097          	auipc	ra,0x0
    80006c66:	45a080e7          	jalr	1114(ra) # 800070bc <lst_push>
    80006c6a:	b7f1                	j	80006c36 <bd_initfree_pair+0x7a>

0000000080006c6c <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006c6c:	711d                	addi	sp,sp,-96
    80006c6e:	ec86                	sd	ra,88(sp)
    80006c70:	e8a2                	sd	s0,80(sp)
    80006c72:	e4a6                	sd	s1,72(sp)
    80006c74:	e0ca                	sd	s2,64(sp)
    80006c76:	fc4e                	sd	s3,56(sp)
    80006c78:	f852                	sd	s4,48(sp)
    80006c7a:	f456                	sd	s5,40(sp)
    80006c7c:	f05a                	sd	s6,32(sp)
    80006c7e:	ec5e                	sd	s7,24(sp)
    80006c80:	e862                	sd	s8,16(sp)
    80006c82:	e466                	sd	s9,8(sp)
    80006c84:	e06a                	sd	s10,0(sp)
    80006c86:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006c88:	00021717          	auipc	a4,0x21
    80006c8c:	3d072703          	lw	a4,976(a4) # 80028058 <nsizes>
    80006c90:	4785                	li	a5,1
    80006c92:	06e7db63          	bge	a5,a4,80006d08 <bd_initfree+0x9c>
    80006c96:	8aaa                	mv	s5,a0
    80006c98:	8b2e                	mv	s6,a1
    80006c9a:	4901                	li	s2,0
  int free = 0;
    80006c9c:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006c9e:	00021c97          	auipc	s9,0x21
    80006ca2:	3aac8c93          	addi	s9,s9,938 # 80028048 <bd_base>
  return n / BLK_SIZE(k);
    80006ca6:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006ca8:	00021b97          	auipc	s7,0x21
    80006cac:	3b0b8b93          	addi	s7,s7,944 # 80028058 <nsizes>
    80006cb0:	a039                	j	80006cbe <bd_initfree+0x52>
    80006cb2:	2905                	addiw	s2,s2,1
    80006cb4:	000ba783          	lw	a5,0(s7)
    80006cb8:	37fd                	addiw	a5,a5,-1
    80006cba:	04f95863          	bge	s2,a5,80006d0a <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006cbe:	85d6                	mv	a1,s5
    80006cc0:	854a                	mv	a0,s2
    80006cc2:	00000097          	auipc	ra,0x0
    80006cc6:	dd6080e7          	jalr	-554(ra) # 80006a98 <blk_index_next>
    80006cca:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006ccc:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006cd0:	409b04bb          	subw	s1,s6,s1
    80006cd4:	012c17b3          	sll	a5,s8,s2
    80006cd8:	02f4c4b3          	div	s1,s1,a5
    80006cdc:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006cde:	85aa                	mv	a1,a0
    80006ce0:	854a                	mv	a0,s2
    80006ce2:	00000097          	auipc	ra,0x0
    80006ce6:	eda080e7          	jalr	-294(ra) # 80006bbc <bd_initfree_pair>
    80006cea:	01450d3b          	addw	s10,a0,s4
    80006cee:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006cf2:	fc99d0e3          	bge	s3,s1,80006cb2 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006cf6:	85a6                	mv	a1,s1
    80006cf8:	854a                	mv	a0,s2
    80006cfa:	00000097          	auipc	ra,0x0
    80006cfe:	ec2080e7          	jalr	-318(ra) # 80006bbc <bd_initfree_pair>
    80006d02:	00ad0a3b          	addw	s4,s10,a0
    80006d06:	b775                	j	80006cb2 <bd_initfree+0x46>
  int free = 0;
    80006d08:	4a01                	li	s4,0
  }
  return free;
}
    80006d0a:	8552                	mv	a0,s4
    80006d0c:	60e6                	ld	ra,88(sp)
    80006d0e:	6446                	ld	s0,80(sp)
    80006d10:	64a6                	ld	s1,72(sp)
    80006d12:	6906                	ld	s2,64(sp)
    80006d14:	79e2                	ld	s3,56(sp)
    80006d16:	7a42                	ld	s4,48(sp)
    80006d18:	7aa2                	ld	s5,40(sp)
    80006d1a:	7b02                	ld	s6,32(sp)
    80006d1c:	6be2                	ld	s7,24(sp)
    80006d1e:	6c42                	ld	s8,16(sp)
    80006d20:	6ca2                	ld	s9,8(sp)
    80006d22:	6d02                	ld	s10,0(sp)
    80006d24:	6125                	addi	sp,sp,96
    80006d26:	8082                	ret

0000000080006d28 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006d28:	7179                	addi	sp,sp,-48
    80006d2a:	f406                	sd	ra,40(sp)
    80006d2c:	f022                	sd	s0,32(sp)
    80006d2e:	ec26                	sd	s1,24(sp)
    80006d30:	e84a                	sd	s2,16(sp)
    80006d32:	e44e                	sd	s3,8(sp)
    80006d34:	1800                	addi	s0,sp,48
    80006d36:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006d38:	00021997          	auipc	s3,0x21
    80006d3c:	31098993          	addi	s3,s3,784 # 80028048 <bd_base>
    80006d40:	0009b483          	ld	s1,0(s3)
    80006d44:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006d48:	00021797          	auipc	a5,0x21
    80006d4c:	3107a783          	lw	a5,784(a5) # 80028058 <nsizes>
    80006d50:	37fd                	addiw	a5,a5,-1
    80006d52:	4641                	li	a2,16
    80006d54:	00f61633          	sll	a2,a2,a5
    80006d58:	85a6                	mv	a1,s1
    80006d5a:	00002517          	auipc	a0,0x2
    80006d5e:	ede50513          	addi	a0,a0,-290 # 80008c38 <userret+0xba8>
    80006d62:	ffffa097          	auipc	ra,0xffffa
    80006d66:	84c080e7          	jalr	-1972(ra) # 800005ae <printf>
  bd_mark(bd_base, p);
    80006d6a:	85ca                	mv	a1,s2
    80006d6c:	0009b503          	ld	a0,0(s3)
    80006d70:	00000097          	auipc	ra,0x0
    80006d74:	d74080e7          	jalr	-652(ra) # 80006ae4 <bd_mark>
  return meta;
}
    80006d78:	8526                	mv	a0,s1
    80006d7a:	70a2                	ld	ra,40(sp)
    80006d7c:	7402                	ld	s0,32(sp)
    80006d7e:	64e2                	ld	s1,24(sp)
    80006d80:	6942                	ld	s2,16(sp)
    80006d82:	69a2                	ld	s3,8(sp)
    80006d84:	6145                	addi	sp,sp,48
    80006d86:	8082                	ret

0000000080006d88 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006d88:	1101                	addi	sp,sp,-32
    80006d8a:	ec06                	sd	ra,24(sp)
    80006d8c:	e822                	sd	s0,16(sp)
    80006d8e:	e426                	sd	s1,8(sp)
    80006d90:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006d92:	00021497          	auipc	s1,0x21
    80006d96:	2c64a483          	lw	s1,710(s1) # 80028058 <nsizes>
    80006d9a:	fff4879b          	addiw	a5,s1,-1
    80006d9e:	44c1                	li	s1,16
    80006da0:	00f494b3          	sll	s1,s1,a5
    80006da4:	00021797          	auipc	a5,0x21
    80006da8:	2a47b783          	ld	a5,676(a5) # 80028048 <bd_base>
    80006dac:	8d1d                	sub	a0,a0,a5
    80006dae:	40a4853b          	subw	a0,s1,a0
    80006db2:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006db6:	00905a63          	blez	s1,80006dca <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006dba:	357d                	addiw	a0,a0,-1
    80006dbc:	41f5549b          	sraiw	s1,a0,0x1f
    80006dc0:	01c4d49b          	srliw	s1,s1,0x1c
    80006dc4:	9ca9                	addw	s1,s1,a0
    80006dc6:	98c1                	andi	s1,s1,-16
    80006dc8:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006dca:	85a6                	mv	a1,s1
    80006dcc:	00002517          	auipc	a0,0x2
    80006dd0:	ea450513          	addi	a0,a0,-348 # 80008c70 <userret+0xbe0>
    80006dd4:	ffff9097          	auipc	ra,0xffff9
    80006dd8:	7da080e7          	jalr	2010(ra) # 800005ae <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006ddc:	00021717          	auipc	a4,0x21
    80006de0:	26c73703          	ld	a4,620(a4) # 80028048 <bd_base>
    80006de4:	00021597          	auipc	a1,0x21
    80006de8:	2745a583          	lw	a1,628(a1) # 80028058 <nsizes>
    80006dec:	fff5879b          	addiw	a5,a1,-1
    80006df0:	45c1                	li	a1,16
    80006df2:	00f595b3          	sll	a1,a1,a5
    80006df6:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006dfa:	95ba                	add	a1,a1,a4
    80006dfc:	953a                	add	a0,a0,a4
    80006dfe:	00000097          	auipc	ra,0x0
    80006e02:	ce6080e7          	jalr	-794(ra) # 80006ae4 <bd_mark>
  return unavailable;
}
    80006e06:	8526                	mv	a0,s1
    80006e08:	60e2                	ld	ra,24(sp)
    80006e0a:	6442                	ld	s0,16(sp)
    80006e0c:	64a2                	ld	s1,8(sp)
    80006e0e:	6105                	addi	sp,sp,32
    80006e10:	8082                	ret

0000000080006e12 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80006e12:	715d                	addi	sp,sp,-80
    80006e14:	e486                	sd	ra,72(sp)
    80006e16:	e0a2                	sd	s0,64(sp)
    80006e18:	fc26                	sd	s1,56(sp)
    80006e1a:	f84a                	sd	s2,48(sp)
    80006e1c:	f44e                	sd	s3,40(sp)
    80006e1e:	f052                	sd	s4,32(sp)
    80006e20:	ec56                	sd	s5,24(sp)
    80006e22:	e85a                	sd	s6,16(sp)
    80006e24:	e45e                	sd	s7,8(sp)
    80006e26:	e062                	sd	s8,0(sp)
    80006e28:	0880                	addi	s0,sp,80
    80006e2a:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80006e2c:	fff50493          	addi	s1,a0,-1
    80006e30:	98c1                	andi	s1,s1,-16
    80006e32:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80006e34:	00002597          	auipc	a1,0x2
    80006e38:	e5c58593          	addi	a1,a1,-420 # 80008c90 <userret+0xc00>
    80006e3c:	00021517          	auipc	a0,0x21
    80006e40:	1c450513          	addi	a0,a0,452 # 80028000 <lock>
    80006e44:	ffffa097          	auipc	ra,0xffffa
    80006e48:	b88080e7          	jalr	-1144(ra) # 800009cc <initlock>
  bd_base = (void *) p;
    80006e4c:	00021797          	auipc	a5,0x21
    80006e50:	1e97be23          	sd	s1,508(a5) # 80028048 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006e54:	409c0933          	sub	s2,s8,s1
    80006e58:	43f95513          	srai	a0,s2,0x3f
    80006e5c:	893d                	andi	a0,a0,15
    80006e5e:	954a                	add	a0,a0,s2
    80006e60:	8511                	srai	a0,a0,0x4
    80006e62:	00000097          	auipc	ra,0x0
    80006e66:	c60080e7          	jalr	-928(ra) # 80006ac2 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80006e6a:	47c1                	li	a5,16
    80006e6c:	00a797b3          	sll	a5,a5,a0
    80006e70:	1b27c663          	blt	a5,s2,8000701c <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006e74:	2505                	addiw	a0,a0,1
    80006e76:	00021797          	auipc	a5,0x21
    80006e7a:	1ea7a123          	sw	a0,482(a5) # 80028058 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80006e7e:	00021997          	auipc	s3,0x21
    80006e82:	1da98993          	addi	s3,s3,474 # 80028058 <nsizes>
    80006e86:	0009a603          	lw	a2,0(s3)
    80006e8a:	85ca                	mv	a1,s2
    80006e8c:	00002517          	auipc	a0,0x2
    80006e90:	e0c50513          	addi	a0,a0,-500 # 80008c98 <userret+0xc08>
    80006e94:	ffff9097          	auipc	ra,0xffff9
    80006e98:	71a080e7          	jalr	1818(ra) # 800005ae <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80006e9c:	00021797          	auipc	a5,0x21
    80006ea0:	1a97ba23          	sd	s1,436(a5) # 80028050 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80006ea4:	0009a603          	lw	a2,0(s3)
    80006ea8:	00561913          	slli	s2,a2,0x5
    80006eac:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80006eae:	0056161b          	slliw	a2,a2,0x5
    80006eb2:	4581                	li	a1,0
    80006eb4:	8526                	mv	a0,s1
    80006eb6:	ffffa097          	auipc	ra,0xffffa
    80006eba:	eb8080e7          	jalr	-328(ra) # 80000d6e <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80006ebe:	0009a783          	lw	a5,0(s3)
    80006ec2:	06f05a63          	blez	a5,80006f36 <bd_init+0x124>
    80006ec6:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80006ec8:	00021a97          	auipc	s5,0x21
    80006ecc:	188a8a93          	addi	s5,s5,392 # 80028050 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006ed0:	00021a17          	auipc	s4,0x21
    80006ed4:	188a0a13          	addi	s4,s4,392 # 80028058 <nsizes>
    80006ed8:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80006eda:	00599b93          	slli	s7,s3,0x5
    80006ede:	000ab503          	ld	a0,0(s5)
    80006ee2:	955e                	add	a0,a0,s7
    80006ee4:	00000097          	auipc	ra,0x0
    80006ee8:	166080e7          	jalr	358(ra) # 8000704a <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006eec:	000a2483          	lw	s1,0(s4)
    80006ef0:	34fd                	addiw	s1,s1,-1
    80006ef2:	413484bb          	subw	s1,s1,s3
    80006ef6:	009b14bb          	sllw	s1,s6,s1
    80006efa:	fff4879b          	addiw	a5,s1,-1
    80006efe:	41f7d49b          	sraiw	s1,a5,0x1f
    80006f02:	01d4d49b          	srliw	s1,s1,0x1d
    80006f06:	9cbd                	addw	s1,s1,a5
    80006f08:	98e1                	andi	s1,s1,-8
    80006f0a:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80006f0c:	000ab783          	ld	a5,0(s5)
    80006f10:	9bbe                	add	s7,s7,a5
    80006f12:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80006f16:	848d                	srai	s1,s1,0x3
    80006f18:	8626                	mv	a2,s1
    80006f1a:	4581                	li	a1,0
    80006f1c:	854a                	mv	a0,s2
    80006f1e:	ffffa097          	auipc	ra,0xffffa
    80006f22:	e50080e7          	jalr	-432(ra) # 80000d6e <memset>
    p += sz;
    80006f26:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80006f28:	0985                	addi	s3,s3,1
    80006f2a:	000a2703          	lw	a4,0(s4)
    80006f2e:	0009879b          	sext.w	a5,s3
    80006f32:	fae7c4e3          	blt	a5,a4,80006eda <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80006f36:	00021797          	auipc	a5,0x21
    80006f3a:	1227a783          	lw	a5,290(a5) # 80028058 <nsizes>
    80006f3e:	4705                	li	a4,1
    80006f40:	06f75163          	bge	a4,a5,80006fa2 <bd_init+0x190>
    80006f44:	02000a13          	li	s4,32
    80006f48:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006f4a:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80006f4c:	00021b17          	auipc	s6,0x21
    80006f50:	104b0b13          	addi	s6,s6,260 # 80028050 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80006f54:	00021a97          	auipc	s5,0x21
    80006f58:	104a8a93          	addi	s5,s5,260 # 80028058 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006f5c:	37fd                	addiw	a5,a5,-1
    80006f5e:	413787bb          	subw	a5,a5,s3
    80006f62:	00fb94bb          	sllw	s1,s7,a5
    80006f66:	fff4879b          	addiw	a5,s1,-1
    80006f6a:	41f7d49b          	sraiw	s1,a5,0x1f
    80006f6e:	01d4d49b          	srliw	s1,s1,0x1d
    80006f72:	9cbd                	addw	s1,s1,a5
    80006f74:	98e1                	andi	s1,s1,-8
    80006f76:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80006f78:	000b3783          	ld	a5,0(s6)
    80006f7c:	97d2                	add	a5,a5,s4
    80006f7e:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80006f82:	848d                	srai	s1,s1,0x3
    80006f84:	8626                	mv	a2,s1
    80006f86:	4581                	li	a1,0
    80006f88:	854a                	mv	a0,s2
    80006f8a:	ffffa097          	auipc	ra,0xffffa
    80006f8e:	de4080e7          	jalr	-540(ra) # 80000d6e <memset>
    p += sz;
    80006f92:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80006f94:	2985                	addiw	s3,s3,1
    80006f96:	000aa783          	lw	a5,0(s5)
    80006f9a:	020a0a13          	addi	s4,s4,32
    80006f9e:	faf9cfe3          	blt	s3,a5,80006f5c <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80006fa2:	197d                	addi	s2,s2,-1
    80006fa4:	ff097913          	andi	s2,s2,-16
    80006fa8:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80006faa:	854a                	mv	a0,s2
    80006fac:	00000097          	auipc	ra,0x0
    80006fb0:	d7c080e7          	jalr	-644(ra) # 80006d28 <bd_mark_data_structures>
    80006fb4:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80006fb6:	85ca                	mv	a1,s2
    80006fb8:	8562                	mv	a0,s8
    80006fba:	00000097          	auipc	ra,0x0
    80006fbe:	dce080e7          	jalr	-562(ra) # 80006d88 <bd_mark_unavailable>
    80006fc2:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006fc4:	00021a97          	auipc	s5,0x21
    80006fc8:	094a8a93          	addi	s5,s5,148 # 80028058 <nsizes>
    80006fcc:	000aa783          	lw	a5,0(s5)
    80006fd0:	37fd                	addiw	a5,a5,-1
    80006fd2:	44c1                	li	s1,16
    80006fd4:	00f497b3          	sll	a5,s1,a5
    80006fd8:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80006fda:	00021597          	auipc	a1,0x21
    80006fde:	06e5b583          	ld	a1,110(a1) # 80028048 <bd_base>
    80006fe2:	95be                	add	a1,a1,a5
    80006fe4:	854a                	mv	a0,s2
    80006fe6:	00000097          	auipc	ra,0x0
    80006fea:	c86080e7          	jalr	-890(ra) # 80006c6c <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80006fee:	000aa603          	lw	a2,0(s5)
    80006ff2:	367d                	addiw	a2,a2,-1
    80006ff4:	00c49633          	sll	a2,s1,a2
    80006ff8:	41460633          	sub	a2,a2,s4
    80006ffc:	41360633          	sub	a2,a2,s3
    80007000:	02c51463          	bne	a0,a2,80007028 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80007004:	60a6                	ld	ra,72(sp)
    80007006:	6406                	ld	s0,64(sp)
    80007008:	74e2                	ld	s1,56(sp)
    8000700a:	7942                	ld	s2,48(sp)
    8000700c:	79a2                	ld	s3,40(sp)
    8000700e:	7a02                	ld	s4,32(sp)
    80007010:	6ae2                	ld	s5,24(sp)
    80007012:	6b42                	ld	s6,16(sp)
    80007014:	6ba2                	ld	s7,8(sp)
    80007016:	6c02                	ld	s8,0(sp)
    80007018:	6161                	addi	sp,sp,80
    8000701a:	8082                	ret
    nsizes++;  // round up to the next power of 2
    8000701c:	2509                	addiw	a0,a0,2
    8000701e:	00021797          	auipc	a5,0x21
    80007022:	02a7ad23          	sw	a0,58(a5) # 80028058 <nsizes>
    80007026:	bda1                	j	80006e7e <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007028:	85aa                	mv	a1,a0
    8000702a:	00002517          	auipc	a0,0x2
    8000702e:	cae50513          	addi	a0,a0,-850 # 80008cd8 <userret+0xc48>
    80007032:	ffff9097          	auipc	ra,0xffff9
    80007036:	57c080e7          	jalr	1404(ra) # 800005ae <printf>
    panic("bd_init: free mem");
    8000703a:	00002517          	auipc	a0,0x2
    8000703e:	cae50513          	addi	a0,a0,-850 # 80008ce8 <userret+0xc58>
    80007042:	ffff9097          	auipc	ra,0xffff9
    80007046:	512080e7          	jalr	1298(ra) # 80000554 <panic>

000000008000704a <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    8000704a:	1141                	addi	sp,sp,-16
    8000704c:	e422                	sd	s0,8(sp)
    8000704e:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007050:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80007052:	e508                	sd	a0,8(a0)
}
    80007054:	6422                	ld	s0,8(sp)
    80007056:	0141                	addi	sp,sp,16
    80007058:	8082                	ret

000000008000705a <lst_empty>:

int
lst_empty(struct list *lst) {
    8000705a:	1141                	addi	sp,sp,-16
    8000705c:	e422                	sd	s0,8(sp)
    8000705e:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007060:	611c                	ld	a5,0(a0)
    80007062:	40a78533          	sub	a0,a5,a0
}
    80007066:	00153513          	seqz	a0,a0
    8000706a:	6422                	ld	s0,8(sp)
    8000706c:	0141                	addi	sp,sp,16
    8000706e:	8082                	ret

0000000080007070 <lst_remove>:

void
lst_remove(struct list *e) {
    80007070:	1141                	addi	sp,sp,-16
    80007072:	e422                	sd	s0,8(sp)
    80007074:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007076:	6518                	ld	a4,8(a0)
    80007078:	611c                	ld	a5,0(a0)
    8000707a:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    8000707c:	6518                	ld	a4,8(a0)
    8000707e:	e798                	sd	a4,8(a5)
}
    80007080:	6422                	ld	s0,8(sp)
    80007082:	0141                	addi	sp,sp,16
    80007084:	8082                	ret

0000000080007086 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007086:	1101                	addi	sp,sp,-32
    80007088:	ec06                	sd	ra,24(sp)
    8000708a:	e822                	sd	s0,16(sp)
    8000708c:	e426                	sd	s1,8(sp)
    8000708e:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007090:	6104                	ld	s1,0(a0)
    80007092:	00a48d63          	beq	s1,a0,800070ac <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007096:	8526                	mv	a0,s1
    80007098:	00000097          	auipc	ra,0x0
    8000709c:	fd8080e7          	jalr	-40(ra) # 80007070 <lst_remove>
  return (void *)p;
}
    800070a0:	8526                	mv	a0,s1
    800070a2:	60e2                	ld	ra,24(sp)
    800070a4:	6442                	ld	s0,16(sp)
    800070a6:	64a2                	ld	s1,8(sp)
    800070a8:	6105                	addi	sp,sp,32
    800070aa:	8082                	ret
    panic("lst_pop");
    800070ac:	00002517          	auipc	a0,0x2
    800070b0:	c5450513          	addi	a0,a0,-940 # 80008d00 <userret+0xc70>
    800070b4:	ffff9097          	auipc	ra,0xffff9
    800070b8:	4a0080e7          	jalr	1184(ra) # 80000554 <panic>

00000000800070bc <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    800070bc:	1141                	addi	sp,sp,-16
    800070be:	e422                	sd	s0,8(sp)
    800070c0:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    800070c2:	611c                	ld	a5,0(a0)
    800070c4:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    800070c6:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    800070c8:	611c                	ld	a5,0(a0)
    800070ca:	e78c                	sd	a1,8(a5)
  lst->next = e;
    800070cc:	e10c                	sd	a1,0(a0)
}
    800070ce:	6422                	ld	s0,8(sp)
    800070d0:	0141                	addi	sp,sp,16
    800070d2:	8082                	ret

00000000800070d4 <lst_print>:

void
lst_print(struct list *lst)
{
    800070d4:	7179                	addi	sp,sp,-48
    800070d6:	f406                	sd	ra,40(sp)
    800070d8:	f022                	sd	s0,32(sp)
    800070da:	ec26                	sd	s1,24(sp)
    800070dc:	e84a                	sd	s2,16(sp)
    800070de:	e44e                	sd	s3,8(sp)
    800070e0:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800070e2:	6104                	ld	s1,0(a0)
    800070e4:	02950063          	beq	a0,s1,80007104 <lst_print+0x30>
    800070e8:	892a                	mv	s2,a0
    printf(" %p", p);
    800070ea:	00002997          	auipc	s3,0x2
    800070ee:	c1e98993          	addi	s3,s3,-994 # 80008d08 <userret+0xc78>
    800070f2:	85a6                	mv	a1,s1
    800070f4:	854e                	mv	a0,s3
    800070f6:	ffff9097          	auipc	ra,0xffff9
    800070fa:	4b8080e7          	jalr	1208(ra) # 800005ae <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800070fe:	6084                	ld	s1,0(s1)
    80007100:	fe9919e3          	bne	s2,s1,800070f2 <lst_print+0x1e>
  }
  printf("\n");
    80007104:	00001517          	auipc	a0,0x1
    80007108:	18c50513          	addi	a0,a0,396 # 80008290 <userret+0x200>
    8000710c:	ffff9097          	auipc	ra,0xffff9
    80007110:	4a2080e7          	jalr	1186(ra) # 800005ae <printf>
}
    80007114:	70a2                	ld	ra,40(sp)
    80007116:	7402                	ld	s0,32(sp)
    80007118:	64e2                	ld	s1,24(sp)
    8000711a:	6942                	ld	s2,16(sp)
    8000711c:	69a2                	ld	s3,8(sp)
    8000711e:	6145                	addi	sp,sp,48
    80007120:	8082                	ret
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
