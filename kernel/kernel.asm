
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
    80000060:	3a478793          	addi	a5,a5,932 # 80006400 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffca7a3>
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
    8000014c:	916080e7          	jalr	-1770(ra) # 80001a5e <myproc>
    80000150:	5d1c                	lw	a5,56(a0)
    80000152:	e7b5                	bnez	a5,800001be <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    80000154:	85a6                	mv	a1,s1
    80000156:	854a                	mv	a0,s2
    80000158:	00002097          	auipc	ra,0x2
    8000015c:	210080e7          	jalr	528(ra) # 80002368 <sleep>
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
    80000198:	440080e7          	jalr	1088(ra) # 800025d4 <either_copyout>
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
    800001fe:	00034797          	auipc	a5,0x34
    80000202:	e227a783          	lw	a5,-478(a5) # 80034020 <panicked>
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
    80000296:	398080e7          	jalr	920(ra) # 8000262a <either_copyin>
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
    8000030c:	378080e7          	jalr	888(ra) # 80002680 <procdump>
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
    80000460:	08e080e7          	jalr	142(ra) # 800024ea <wakeup>
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
    8000048e:	0002c797          	auipc	a5,0x2c
    80000492:	7f278793          	addi	a5,a5,2034 # 8002cc80 <devsw>
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
    800004d4:	9f060613          	addi	a2,a2,-1552 # 80008ec0 <digits>
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
    80000586:	6be50513          	addi	a0,a0,1726 # 80008c40 <userret+0xbb0>
    8000058a:	00000097          	auipc	ra,0x0
    8000058e:	024080e7          	jalr	36(ra) # 800005ae <printf>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    80000592:	00008517          	auipc	a0,0x8
    80000596:	b9650513          	addi	a0,a0,-1130 # 80008128 <userret+0x98>
    8000059a:	00000097          	auipc	ra,0x0
    8000059e:	014080e7          	jalr	20(ra) # 800005ae <printf>
  panicked = 1; // freeze other CPUs
    800005a2:	4785                	li	a5,1
    800005a4:	00034717          	auipc	a4,0x34
    800005a8:	a6f72e23          	sw	a5,-1412(a4) # 80034020 <panicked>
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
    80000610:	8b4b0b13          	addi	s6,s6,-1868 # 80008ec0 <digits>
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
    80000884:	00033797          	auipc	a5,0x33
    80000888:	7d878793          	addi	a5,a5,2008 # 8003405c <end>
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
    80000940:	00013517          	auipc	a0,0x13
    80000944:	f9850513          	addi	a0,a0,-104 # 800138d8 <kmem>
    80000948:	00000097          	auipc	ra,0x0
    8000094c:	084080e7          	jalr	132(ra) # 800009cc <initlock>
  freerange(end, (void*)PHYSTOP);
    80000950:	45c5                	li	a1,17
    80000952:	05ee                	slli	a1,a1,0x1b
    80000954:	00033517          	auipc	a0,0x33
    80000958:	70850513          	addi	a0,a0,1800 # 8003405c <end>
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
    800009de:	00033797          	auipc	a5,0x33
    800009e2:	6467a783          	lw	a5,1606(a5) # 80034024 <nlock>
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
    80000a00:	00033717          	auipc	a4,0x33
    80000a04:	62f72223          	sw	a5,1572(a4) # 80034024 <nlock>
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
    80000a3a:	00c080e7          	jalr	12(ra) # 80001a42 <mycpu>
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
    80000a70:	fd6080e7          	jalr	-42(ra) # 80001a42 <mycpu>
    80000a74:	5d3c                	lw	a5,120(a0)
    80000a76:	cf89                	beqz	a5,80000a90 <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000a78:	00001097          	auipc	ra,0x1
    80000a7c:	fca080e7          	jalr	-54(ra) # 80001a42 <mycpu>
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
    80000a94:	fb2080e7          	jalr	-78(ra) # 80001a42 <mycpu>
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
    80000b00:	f46080e7          	jalr	-186(ra) # 80001a42 <mycpu>
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
    80000b24:	f22080e7          	jalr	-222(ra) # 80001a42 <mycpu>
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
    80000c08:	27a080e7          	jalr	634(ra) # 80002e7e <argint>
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
    80000c3e:	00007517          	auipc	a0,0x7
    80000c42:	65a50513          	addi	a0,a0,1626 # 80008298 <userret+0x208>
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
    80000f28:	b0e080e7          	jalr	-1266(ra) # 80001a32 <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f2c:	00033717          	auipc	a4,0x33
    80000f30:	0fc70713          	addi	a4,a4,252 # 80034028 <started>
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
    80000f44:	af2080e7          	jalr	-1294(ra) # 80001a32 <cpuid>
    80000f48:	85aa                	mv	a1,a0
    80000f4a:	00007517          	auipc	a0,0x7
    80000f4e:	3ae50513          	addi	a0,a0,942 # 800082f8 <userret+0x268>
    80000f52:	fffff097          	auipc	ra,0xfffff
    80000f56:	65c080e7          	jalr	1628(ra) # 800005ae <printf>
    kvminithart();    // turn on paging
    80000f5a:	00000097          	auipc	ra,0x0
    80000f5e:	1ea080e7          	jalr	490(ra) # 80001144 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f62:	00002097          	auipc	ra,0x2
    80000f66:	900080e7          	jalr	-1792(ra) # 80002862 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	4d6080e7          	jalr	1238(ra) # 80006440 <plicinithart>
  }

  scheduler();        
    80000f72:	00001097          	auipc	ra,0x1
    80000f76:	060080e7          	jalr	96(ra) # 80001fd2 <scheduler>
    consoleinit();
    80000f7a:	fffff097          	auipc	ra,0xfffff
    80000f7e:	4ec080e7          	jalr	1260(ra) # 80000466 <consoleinit>
    printfinit();
    80000f82:	00000097          	auipc	ra,0x0
    80000f86:	80c080e7          	jalr	-2036(ra) # 8000078e <printfinit>
    printf("\n");
    80000f8a:	00008517          	auipc	a0,0x8
    80000f8e:	cb650513          	addi	a0,a0,-842 # 80008c40 <userret+0xbb0>
    80000f92:	fffff097          	auipc	ra,0xfffff
    80000f96:	61c080e7          	jalr	1564(ra) # 800005ae <printf>
    printf("xv6 kernel is booting\n");
    80000f9a:	00007517          	auipc	a0,0x7
    80000f9e:	34650513          	addi	a0,a0,838 # 800082e0 <userret+0x250>
    80000fa2:	fffff097          	auipc	ra,0xfffff
    80000fa6:	60c080e7          	jalr	1548(ra) # 800005ae <printf>
    printf("\n");
    80000faa:	00008517          	auipc	a0,0x8
    80000fae:	c9650513          	addi	a0,a0,-874 # 80008c40 <userret+0xbb0>
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
    80000fda:	00002097          	auipc	ra,0x2
    80000fde:	860080e7          	jalr	-1952(ra) # 8000283a <trapinit>
    trapinithart();  // install kernel trap vector
    80000fe2:	00002097          	auipc	ra,0x2
    80000fe6:	880080e7          	jalr	-1920(ra) # 80002862 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fea:	00005097          	auipc	ra,0x5
    80000fee:	440080e7          	jalr	1088(ra) # 8000642a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ff2:	00005097          	auipc	ra,0x5
    80000ff6:	44e080e7          	jalr	1102(ra) # 80006440 <plicinithart>
    binit();         // buffer cache
    80000ffa:	00002097          	auipc	ra,0x2
    80000ffe:	164080e7          	jalr	356(ra) # 8000315e <binit>
    iinit();         // inode cache
    80001002:	00002097          	auipc	ra,0x2
    80001006:	7f8080e7          	jalr	2040(ra) # 800037fa <iinit>
    fileinit();      // file table
    8000100a:	00004097          	auipc	ra,0x4
    8000100e:	882080e7          	jalr	-1918(ra) # 8000488c <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80001012:	4501                	li	a0,0
    80001014:	00005097          	auipc	ra,0x5
    80001018:	54e080e7          	jalr	1358(ra) # 80006562 <virtio_disk_init>
    userinit();      // first user process
    8000101c:	00001097          	auipc	ra,0x1
    80001020:	ce8080e7          	jalr	-792(ra) # 80001d04 <userinit>
    __sync_synchronize();
    80001024:	0ff0000f          	fence
    started = 1;
    80001028:	4785                	li	a5,1
    8000102a:	00033717          	auipc	a4,0x33
    8000102e:	fef72f23          	sw	a5,-2(a4) # 80034028 <started>
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
    8000114a:	00033797          	auipc	a5,0x33
    8000114e:	ee67b783          	ld	a5,-282(a5) # 80034030 <kernel_pagetable>
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
    800011be:	00033517          	auipc	a0,0x33
    800011c2:	e7253503          	ld	a0,-398(a0) # 80034030 <kernel_pagetable>
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
    if(*pte & PTE_V){
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
    800012a4:	00033517          	auipc	a0,0x33
    800012a8:	d8c53503          	ld	a0,-628(a0) # 80034030 <kernel_pagetable>
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
    800012e0:	00033797          	auipc	a5,0x33
    800012e4:	d4a7b823          	sd	a0,-688(a5) # 80034030 <kernel_pagetable>
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
    8000135a:	00009497          	auipc	s1,0x9
    8000135e:	ca648493          	addi	s1,s1,-858 # 8000a000 <initcode>
    80001362:	46a9                	li	a3,10
    80001364:	80009617          	auipc	a2,0x80009
    80001368:	c9c60613          	addi	a2,a2,-868 # a000 <_entry-0x7fff6000>
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
    800018ec:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffcafa4>
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
    80001970:	e062                	sd	s8,0(sp)
    80001972:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001974:	00007597          	auipc	a1,0x7
    80001978:	ab458593          	addi	a1,a1,-1356 # 80008428 <userret+0x398>
    8000197c:	00014517          	auipc	a0,0x14
    80001980:	ec450513          	addi	a0,a0,-316 # 80015840 <pid_lock>
    80001984:	fffff097          	auipc	ra,0xfffff
    80001988:	048080e7          	jalr	72(ra) # 800009cc <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000198c:	00014917          	auipc	s2,0x14
    80001990:	2d490913          	addi	s2,s2,724 # 80015c60 <proc>
      uint64 va = KSTACK((int) (p - proc));
    80001994:	8c4a                	mv	s8,s2
    80001996:	00007b97          	auipc	s7,0x7
    8000199a:	742b8b93          	addi	s7,s7,1858 # 800090d8 <syscalls+0xc0>
    8000199e:	040009b7          	lui	s3,0x4000
    800019a2:	19fd                	addi	s3,s3,-1
    800019a4:	09b2                	slli	s3,s3,0xc
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019a6:	6a05                	lui	s4,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a8:	440a0b13          	addi	s6,s4,1088 # 1440 <_entry-0x7fffebc0>
    800019ac:	00021a97          	auipc	s5,0x21
    800019b0:	d34a8a93          	addi	s5,s5,-716 # 800226e0 <tickslock>
      initlock(&p->lock, "proc");
    800019b4:	00007597          	auipc	a1,0x7
    800019b8:	a7c58593          	addi	a1,a1,-1412 # 80008430 <userret+0x3a0>
    800019bc:	854a                	mv	a0,s2
    800019be:	fffff097          	auipc	ra,0xfffff
    800019c2:	00e080e7          	jalr	14(ra) # 800009cc <initlock>
      char *pa = kalloc();
    800019c6:	fffff097          	auipc	ra,0xfffff
    800019ca:	fa6080e7          	jalr	-90(ra) # 8000096c <kalloc>
    800019ce:	85aa                	mv	a1,a0
      if(pa == 0)
    800019d0:	c929                	beqz	a0,80001a22 <procinit+0xc6>
      uint64 va = KSTACK((int) (p - proc));
    800019d2:	418904b3          	sub	s1,s2,s8
    800019d6:	8499                	srai	s1,s1,0x6
    800019d8:	000bb783          	ld	a5,0(s7)
    800019dc:	02f484b3          	mul	s1,s1,a5
    800019e0:	2485                	addiw	s1,s1,1
    800019e2:	00d4949b          	slliw	s1,s1,0xd
    800019e6:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019ea:	4699                	li	a3,6
    800019ec:	8652                	mv	a2,s4
    800019ee:	8526                	mv	a0,s1
    800019f0:	00000097          	auipc	ra,0x0
    800019f4:	8a6080e7          	jalr	-1882(ra) # 80001296 <kvmmap>
      p->kstack = va;
    800019f8:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019fc:	995a                	add	s2,s2,s6
    800019fe:	fb591be3          	bne	s2,s5,800019b4 <procinit+0x58>
  kvminithart();
    80001a02:	fffff097          	auipc	ra,0xfffff
    80001a06:	742080e7          	jalr	1858(ra) # 80001144 <kvminithart>
}
    80001a0a:	60a6                	ld	ra,72(sp)
    80001a0c:	6406                	ld	s0,64(sp)
    80001a0e:	74e2                	ld	s1,56(sp)
    80001a10:	7942                	ld	s2,48(sp)
    80001a12:	79a2                	ld	s3,40(sp)
    80001a14:	7a02                	ld	s4,32(sp)
    80001a16:	6ae2                	ld	s5,24(sp)
    80001a18:	6b42                	ld	s6,16(sp)
    80001a1a:	6ba2                	ld	s7,8(sp)
    80001a1c:	6c02                	ld	s8,0(sp)
    80001a1e:	6161                	addi	sp,sp,80
    80001a20:	8082                	ret
        panic("kalloc");
    80001a22:	00007517          	auipc	a0,0x7
    80001a26:	a1650513          	addi	a0,a0,-1514 # 80008438 <userret+0x3a8>
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	b2a080e7          	jalr	-1238(ra) # 80000554 <panic>

0000000080001a32 <cpuid>:
{
    80001a32:	1141                	addi	sp,sp,-16
    80001a34:	e422                	sd	s0,8(sp)
    80001a36:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a38:	8512                	mv	a0,tp
}
    80001a3a:	2501                	sext.w	a0,a0
    80001a3c:	6422                	ld	s0,8(sp)
    80001a3e:	0141                	addi	sp,sp,16
    80001a40:	8082                	ret

0000000080001a42 <mycpu>:
mycpu(void) {
    80001a42:	1141                	addi	sp,sp,-16
    80001a44:	e422                	sd	s0,8(sp)
    80001a46:	0800                	addi	s0,sp,16
    80001a48:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a4a:	2781                	sext.w	a5,a5
    80001a4c:	079e                	slli	a5,a5,0x7
}
    80001a4e:	00014517          	auipc	a0,0x14
    80001a52:	e1250513          	addi	a0,a0,-494 # 80015860 <cpus>
    80001a56:	953e                	add	a0,a0,a5
    80001a58:	6422                	ld	s0,8(sp)
    80001a5a:	0141                	addi	sp,sp,16
    80001a5c:	8082                	ret

0000000080001a5e <myproc>:
myproc(void) {
    80001a5e:	1101                	addi	sp,sp,-32
    80001a60:	ec06                	sd	ra,24(sp)
    80001a62:	e822                	sd	s0,16(sp)
    80001a64:	e426                	sd	s1,8(sp)
    80001a66:	1000                	addi	s0,sp,32
  push_off();
    80001a68:	fffff097          	auipc	ra,0xfffff
    80001a6c:	fe8080e7          	jalr	-24(ra) # 80000a50 <push_off>
    80001a70:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a72:	2781                	sext.w	a5,a5
    80001a74:	079e                	slli	a5,a5,0x7
    80001a76:	00014717          	auipc	a4,0x14
    80001a7a:	dca70713          	addi	a4,a4,-566 # 80015840 <pid_lock>
    80001a7e:	97ba                	add	a5,a5,a4
    80001a80:	7384                	ld	s1,32(a5)
  pop_off();
    80001a82:	fffff097          	auipc	ra,0xfffff
    80001a86:	08e080e7          	jalr	142(ra) # 80000b10 <pop_off>
}
    80001a8a:	8526                	mv	a0,s1
    80001a8c:	60e2                	ld	ra,24(sp)
    80001a8e:	6442                	ld	s0,16(sp)
    80001a90:	64a2                	ld	s1,8(sp)
    80001a92:	6105                	addi	sp,sp,32
    80001a94:	8082                	ret

0000000080001a96 <forkret>:
{
    80001a96:	1141                	addi	sp,sp,-16
    80001a98:	e406                	sd	ra,8(sp)
    80001a9a:	e022                	sd	s0,0(sp)
    80001a9c:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a9e:	00000097          	auipc	ra,0x0
    80001aa2:	fc0080e7          	jalr	-64(ra) # 80001a5e <myproc>
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	0ca080e7          	jalr	202(ra) # 80000b70 <release>
  if (first) {
    80001aae:	00008797          	auipc	a5,0x8
    80001ab2:	5867a783          	lw	a5,1414(a5) # 8000a034 <first.1>
    80001ab6:	eb89                	bnez	a5,80001ac8 <forkret+0x32>
  usertrapret();
    80001ab8:	00001097          	auipc	ra,0x1
    80001abc:	dc2080e7          	jalr	-574(ra) # 8000287a <usertrapret>
}
    80001ac0:	60a2                	ld	ra,8(sp)
    80001ac2:	6402                	ld	s0,0(sp)
    80001ac4:	0141                	addi	sp,sp,16
    80001ac6:	8082                	ret
    first = 0;
    80001ac8:	00008797          	auipc	a5,0x8
    80001acc:	5607a623          	sw	zero,1388(a5) # 8000a034 <first.1>
    fsinit(minor(ROOTDEV));
    80001ad0:	4501                	li	a0,0
    80001ad2:	00002097          	auipc	ra,0x2
    80001ad6:	ca8080e7          	jalr	-856(ra) # 8000377a <fsinit>
    80001ada:	bff9                	j	80001ab8 <forkret+0x22>

0000000080001adc <allocpid>:
allocpid() {
    80001adc:	1101                	addi	sp,sp,-32
    80001ade:	ec06                	sd	ra,24(sp)
    80001ae0:	e822                	sd	s0,16(sp)
    80001ae2:	e426                	sd	s1,8(sp)
    80001ae4:	e04a                	sd	s2,0(sp)
    80001ae6:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ae8:	00014917          	auipc	s2,0x14
    80001aec:	d5890913          	addi	s2,s2,-680 # 80015840 <pid_lock>
    80001af0:	854a                	mv	a0,s2
    80001af2:	fffff097          	auipc	ra,0xfffff
    80001af6:	fae080e7          	jalr	-82(ra) # 80000aa0 <acquire>
  pid = nextpid;
    80001afa:	00008797          	auipc	a5,0x8
    80001afe:	53e78793          	addi	a5,a5,1342 # 8000a038 <nextpid>
    80001b02:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b04:	0014871b          	addiw	a4,s1,1
    80001b08:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b0a:	854a                	mv	a0,s2
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	064080e7          	jalr	100(ra) # 80000b70 <release>
}
    80001b14:	8526                	mv	a0,s1
    80001b16:	60e2                	ld	ra,24(sp)
    80001b18:	6442                	ld	s0,16(sp)
    80001b1a:	64a2                	ld	s1,8(sp)
    80001b1c:	6902                	ld	s2,0(sp)
    80001b1e:	6105                	addi	sp,sp,32
    80001b20:	8082                	ret

0000000080001b22 <proc_pagetable>:
{
    80001b22:	1101                	addi	sp,sp,-32
    80001b24:	ec06                	sd	ra,24(sp)
    80001b26:	e822                	sd	s0,16(sp)
    80001b28:	e426                	sd	s1,8(sp)
    80001b2a:	e04a                	sd	s2,0(sp)
    80001b2c:	1000                	addi	s0,sp,32
    80001b2e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b30:	00000097          	auipc	ra,0x0
    80001b34:	94c080e7          	jalr	-1716(ra) # 8000147c <uvmcreate>
    80001b38:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b3a:	4729                	li	a4,10
    80001b3c:	00006697          	auipc	a3,0x6
    80001b40:	4c468693          	addi	a3,a3,1220 # 80008000 <trampoline>
    80001b44:	6605                	lui	a2,0x1
    80001b46:	040005b7          	lui	a1,0x4000
    80001b4a:	15fd                	addi	a1,a1,-1
    80001b4c:	05b2                	slli	a1,a1,0xc
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	6ba080e7          	jalr	1722(ra) # 80001208 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b56:	4719                	li	a4,6
    80001b58:	06093683          	ld	a3,96(s2)
    80001b5c:	6605                	lui	a2,0x1
    80001b5e:	020005b7          	lui	a1,0x2000
    80001b62:	15fd                	addi	a1,a1,-1
    80001b64:	05b6                	slli	a1,a1,0xd
    80001b66:	8526                	mv	a0,s1
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	6a0080e7          	jalr	1696(ra) # 80001208 <mappages>
}
    80001b70:	8526                	mv	a0,s1
    80001b72:	60e2                	ld	ra,24(sp)
    80001b74:	6442                	ld	s0,16(sp)
    80001b76:	64a2                	ld	s1,8(sp)
    80001b78:	6902                	ld	s2,0(sp)
    80001b7a:	6105                	addi	sp,sp,32
    80001b7c:	8082                	ret

0000000080001b7e <allocproc>:
{
    80001b7e:	7179                	addi	sp,sp,-48
    80001b80:	f406                	sd	ra,40(sp)
    80001b82:	f022                	sd	s0,32(sp)
    80001b84:	ec26                	sd	s1,24(sp)
    80001b86:	e84a                	sd	s2,16(sp)
    80001b88:	e44e                	sd	s3,8(sp)
    80001b8a:	e052                	sd	s4,0(sp)
    80001b8c:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b8e:	00014497          	auipc	s1,0x14
    80001b92:	0d248493          	addi	s1,s1,210 # 80015c60 <proc>
    80001b96:	6985                	lui	s3,0x1
    80001b98:	44098993          	addi	s3,s3,1088 # 1440 <_entry-0x7fffebc0>
    80001b9c:	00021a17          	auipc	s4,0x21
    80001ba0:	b44a0a13          	addi	s4,s4,-1212 # 800226e0 <tickslock>
    acquire(&p->lock);
    80001ba4:	8526                	mv	a0,s1
    80001ba6:	fffff097          	auipc	ra,0xfffff
    80001baa:	efa080e7          	jalr	-262(ra) # 80000aa0 <acquire>
    if(p->state == UNUSED) {
    80001bae:	509c                	lw	a5,32(s1)
    80001bb0:	c39d                	beqz	a5,80001bd6 <allocproc+0x58>
      release(&p->lock);
    80001bb2:	8526                	mv	a0,s1
    80001bb4:	fffff097          	auipc	ra,0xfffff
    80001bb8:	fbc080e7          	jalr	-68(ra) # 80000b70 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bbc:	94ce                	add	s1,s1,s3
    80001bbe:	ff4493e3          	bne	s1,s4,80001ba4 <allocproc+0x26>
  return 0;
    80001bc2:	4481                	li	s1,0
}
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	70a2                	ld	ra,40(sp)
    80001bc8:	7402                	ld	s0,32(sp)
    80001bca:	64e2                	ld	s1,24(sp)
    80001bcc:	6942                	ld	s2,16(sp)
    80001bce:	69a2                	ld	s3,8(sp)
    80001bd0:	6a02                	ld	s4,0(sp)
    80001bd2:	6145                	addi	sp,sp,48
    80001bd4:	8082                	ret
  p->pid = allocpid();
    80001bd6:	00000097          	auipc	ra,0x0
    80001bda:	f06080e7          	jalr	-250(ra) # 80001adc <allocpid>
    80001bde:	c0a8                	sw	a0,64(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001be0:	fffff097          	auipc	ra,0xfffff
    80001be4:	d8c080e7          	jalr	-628(ra) # 8000096c <kalloc>
    80001be8:	89aa                	mv	s3,a0
    80001bea:	f0a8                	sd	a0,96(s1)
    80001bec:	cd29                	beqz	a0,80001c46 <allocproc+0xc8>
  p->pagetable = proc_pagetable(p);
    80001bee:	8526                	mv	a0,s1
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	f32080e7          	jalr	-206(ra) # 80001b22 <proc_pagetable>
    80001bf8:	eca8                	sd	a0,88(s1)
  memset(&p->context, 0, sizeof p->context);
    80001bfa:	07000613          	li	a2,112
    80001bfe:	4581                	li	a1,0
    80001c00:	06848513          	addi	a0,s1,104
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	16a080e7          	jalr	362(ra) # 80000d6e <memset>
  p->context.ra = (uint64)forkret;
    80001c0c:	00000797          	auipc	a5,0x0
    80001c10:	e8a78793          	addi	a5,a5,-374 # 80001a96 <forkret>
    80001c14:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c16:	6785                	lui	a5,0x1
    80001c18:	64b8                	ld	a4,72(s1)
    80001c1a:	973e                	add	a4,a4,a5
    80001c1c:	f8b8                	sd	a4,112(s1)
  for (int i = NVMA - 1; i >= 0; i--)
    80001c1e:	40078793          	addi	a5,a5,1024 # 1400 <_entry-0x7fffec00>
    80001c22:	97a6                	add	a5,a5,s1
    80001c24:	14048713          	addi	a4,s1,320
    p->vmas[i].vm_valid = 1;
    80001c28:	4685                	li	a3,1
    80001c2a:	c394                	sw	a3,0(a5)
  for (int i = NVMA - 1; i >= 0; i--)
    80001c2c:	fd078793          	addi	a5,a5,-48
    80001c30:	fee79de3          	bne	a5,a4,80001c2a <allocproc+0xac>
  p->current_maxva = VMASTART;
    80001c34:	6705                	lui	a4,0x1
    80001c36:	9726                	add	a4,a4,s1
    80001c38:	020007b7          	lui	a5,0x2000
    80001c3c:	17fd                	addi	a5,a5,-1
    80001c3e:	07b6                	slli	a5,a5,0xd
    80001c40:	42f73823          	sd	a5,1072(a4) # 1430 <_entry-0x7fffebd0>
  return p;
    80001c44:	b741                	j	80001bc4 <allocproc+0x46>
    release(&p->lock);
    80001c46:	8526                	mv	a0,s1
    80001c48:	fffff097          	auipc	ra,0xfffff
    80001c4c:	f28080e7          	jalr	-216(ra) # 80000b70 <release>
    return 0;
    80001c50:	84ce                	mv	s1,s3
    80001c52:	bf8d                	j	80001bc4 <allocproc+0x46>

0000000080001c54 <proc_freepagetable>:
{
    80001c54:	1101                	addi	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	addi	s0,sp,32
    80001c60:	84aa                	mv	s1,a0
    80001c62:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001c64:	4681                	li	a3,0
    80001c66:	6605                	lui	a2,0x1
    80001c68:	040005b7          	lui	a1,0x4000
    80001c6c:	15fd                	addi	a1,a1,-1
    80001c6e:	05b2                	slli	a1,a1,0xc
    80001c70:	fffff097          	auipc	ra,0xfffff
    80001c74:	744080e7          	jalr	1860(ra) # 800013b4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001c78:	4681                	li	a3,0
    80001c7a:	6605                	lui	a2,0x1
    80001c7c:	020005b7          	lui	a1,0x2000
    80001c80:	15fd                	addi	a1,a1,-1
    80001c82:	05b6                	slli	a1,a1,0xd
    80001c84:	8526                	mv	a0,s1
    80001c86:	fffff097          	auipc	ra,0xfffff
    80001c8a:	72e080e7          	jalr	1838(ra) # 800013b4 <uvmunmap>
  if(sz > 0)
    80001c8e:	00091863          	bnez	s2,80001c9e <proc_freepagetable+0x4a>
}
    80001c92:	60e2                	ld	ra,24(sp)
    80001c94:	6442                	ld	s0,16(sp)
    80001c96:	64a2                	ld	s1,8(sp)
    80001c98:	6902                	ld	s2,0(sp)
    80001c9a:	6105                	addi	sp,sp,32
    80001c9c:	8082                	ret
    uvmfree(pagetable, sz);
    80001c9e:	85ca                	mv	a1,s2
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	00000097          	auipc	ra,0x0
    80001ca6:	978080e7          	jalr	-1672(ra) # 8000161a <uvmfree>
}
    80001caa:	b7e5                	j	80001c92 <proc_freepagetable+0x3e>

0000000080001cac <freeproc>:
{
    80001cac:	1101                	addi	sp,sp,-32
    80001cae:	ec06                	sd	ra,24(sp)
    80001cb0:	e822                	sd	s0,16(sp)
    80001cb2:	e426                	sd	s1,8(sp)
    80001cb4:	1000                	addi	s0,sp,32
    80001cb6:	84aa                	mv	s1,a0
  if(p->tf)
    80001cb8:	7128                	ld	a0,96(a0)
    80001cba:	c509                	beqz	a0,80001cc4 <freeproc+0x18>
    kfree((void*)p->tf);
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	bb4080e7          	jalr	-1100(ra) # 80000870 <kfree>
  p->tf = 0;
    80001cc4:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001cc8:	6ca8                	ld	a0,88(s1)
    80001cca:	c511                	beqz	a0,80001cd6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ccc:	68ac                	ld	a1,80(s1)
    80001cce:	00000097          	auipc	ra,0x0
    80001cd2:	f86080e7          	jalr	-122(ra) # 80001c54 <proc_freepagetable>
  p->pagetable = 0;
    80001cd6:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001cda:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001cde:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001ce2:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001ce6:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001cea:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001cee:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001cf2:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001cf6:	0204a023          	sw	zero,32(s1)
}
    80001cfa:	60e2                	ld	ra,24(sp)
    80001cfc:	6442                	ld	s0,16(sp)
    80001cfe:	64a2                	ld	s1,8(sp)
    80001d00:	6105                	addi	sp,sp,32
    80001d02:	8082                	ret

0000000080001d04 <userinit>:
{
    80001d04:	1101                	addi	sp,sp,-32
    80001d06:	ec06                	sd	ra,24(sp)
    80001d08:	e822                	sd	s0,16(sp)
    80001d0a:	e426                	sd	s1,8(sp)
    80001d0c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d0e:	00000097          	auipc	ra,0x0
    80001d12:	e70080e7          	jalr	-400(ra) # 80001b7e <allocproc>
    80001d16:	84aa                	mv	s1,a0
  initproc = p;
    80001d18:	00032797          	auipc	a5,0x32
    80001d1c:	32a7b023          	sd	a0,800(a5) # 80034038 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d20:	03300613          	li	a2,51
    80001d24:	00008597          	auipc	a1,0x8
    80001d28:	2dc58593          	addi	a1,a1,732 # 8000a000 <initcode>
    80001d2c:	6d28                	ld	a0,88(a0)
    80001d2e:	fffff097          	auipc	ra,0xfffff
    80001d32:	78c080e7          	jalr	1932(ra) # 800014ba <uvminit>
  p->sz = PGSIZE;
    80001d36:	6785                	lui	a5,0x1
    80001d38:	e8bc                	sd	a5,80(s1)
  p->tf->epc = 0;      // user program counter
    80001d3a:	70b8                	ld	a4,96(s1)
    80001d3c:	00073c23          	sd	zero,24(a4)
  p->tf->sp = PGSIZE;  // user stack pointer
    80001d40:	70b8                	ld	a4,96(s1)
    80001d42:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d44:	4641                	li	a2,16
    80001d46:	00006597          	auipc	a1,0x6
    80001d4a:	6fa58593          	addi	a1,a1,1786 # 80008440 <userret+0x3b0>
    80001d4e:	16048513          	addi	a0,s1,352
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	16e080e7          	jalr	366(ra) # 80000ec0 <safestrcpy>
  p->cwd = namei("/");
    80001d5a:	00006517          	auipc	a0,0x6
    80001d5e:	6f650513          	addi	a0,a0,1782 # 80008450 <userret+0x3c0>
    80001d62:	00002097          	auipc	ra,0x2
    80001d66:	41a080e7          	jalr	1050(ra) # 8000417c <namei>
    80001d6a:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d6e:	4789                	li	a5,2
    80001d70:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001d72:	8526                	mv	a0,s1
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	dfc080e7          	jalr	-516(ra) # 80000b70 <release>
}
    80001d7c:	60e2                	ld	ra,24(sp)
    80001d7e:	6442                	ld	s0,16(sp)
    80001d80:	64a2                	ld	s1,8(sp)
    80001d82:	6105                	addi	sp,sp,32
    80001d84:	8082                	ret

0000000080001d86 <growproc>:
{
    80001d86:	1101                	addi	sp,sp,-32
    80001d88:	ec06                	sd	ra,24(sp)
    80001d8a:	e822                	sd	s0,16(sp)
    80001d8c:	e426                	sd	s1,8(sp)
    80001d8e:	e04a                	sd	s2,0(sp)
    80001d90:	1000                	addi	s0,sp,32
    80001d92:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d94:	00000097          	auipc	ra,0x0
    80001d98:	cca080e7          	jalr	-822(ra) # 80001a5e <myproc>
    80001d9c:	892a                	mv	s2,a0
  sz = p->sz;
    80001d9e:	692c                	ld	a1,80(a0)
    80001da0:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001da4:	00904f63          	bgtz	s1,80001dc2 <growproc+0x3c>
  } else if(n < 0){
    80001da8:	0204cc63          	bltz	s1,80001de0 <growproc+0x5a>
  p->sz = sz;
    80001dac:	1602                	slli	a2,a2,0x20
    80001dae:	9201                	srli	a2,a2,0x20
    80001db0:	04c93823          	sd	a2,80(s2)
  return 0;
    80001db4:	4501                	li	a0,0
}
    80001db6:	60e2                	ld	ra,24(sp)
    80001db8:	6442                	ld	s0,16(sp)
    80001dba:	64a2                	ld	s1,8(sp)
    80001dbc:	6902                	ld	s2,0(sp)
    80001dbe:	6105                	addi	sp,sp,32
    80001dc0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dc2:	9e25                	addw	a2,a2,s1
    80001dc4:	1602                	slli	a2,a2,0x20
    80001dc6:	9201                	srli	a2,a2,0x20
    80001dc8:	1582                	slli	a1,a1,0x20
    80001dca:	9181                	srli	a1,a1,0x20
    80001dcc:	6d28                	ld	a0,88(a0)
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	7a2080e7          	jalr	1954(ra) # 80001570 <uvmalloc>
    80001dd6:	0005061b          	sext.w	a2,a0
    80001dda:	fa69                	bnez	a2,80001dac <growproc+0x26>
      return -1;
    80001ddc:	557d                	li	a0,-1
    80001dde:	bfe1                	j	80001db6 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001de0:	9e25                	addw	a2,a2,s1
    80001de2:	1602                	slli	a2,a2,0x20
    80001de4:	9201                	srli	a2,a2,0x20
    80001de6:	1582                	slli	a1,a1,0x20
    80001de8:	9181                	srli	a1,a1,0x20
    80001dea:	6d28                	ld	a0,88(a0)
    80001dec:	fffff097          	auipc	ra,0xfffff
    80001df0:	740080e7          	jalr	1856(ra) # 8000152c <uvmdealloc>
    80001df4:	0005061b          	sext.w	a2,a0
    80001df8:	bf55                	j	80001dac <growproc+0x26>

0000000080001dfa <fork>:
{
    80001dfa:	7139                	addi	sp,sp,-64
    80001dfc:	fc06                	sd	ra,56(sp)
    80001dfe:	f822                	sd	s0,48(sp)
    80001e00:	f426                	sd	s1,40(sp)
    80001e02:	f04a                	sd	s2,32(sp)
    80001e04:	ec4e                	sd	s3,24(sp)
    80001e06:	e852                	sd	s4,16(sp)
    80001e08:	e456                	sd	s5,8(sp)
    80001e0a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e0c:	00000097          	auipc	ra,0x0
    80001e10:	c52080e7          	jalr	-942(ra) # 80001a5e <myproc>
    80001e14:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e16:	00000097          	auipc	ra,0x0
    80001e1a:	d68080e7          	jalr	-664(ra) # 80001b7e <allocproc>
    80001e1e:	14050163          	beqz	a0,80001f60 <fork+0x166>
    80001e22:	84aa                	mv	s1,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e24:	05093603          	ld	a2,80(s2)
    80001e28:	6d2c                	ld	a1,88(a0)
    80001e2a:	05893503          	ld	a0,88(s2)
    80001e2e:	00000097          	auipc	ra,0x0
    80001e32:	81a080e7          	jalr	-2022(ra) # 80001648 <uvmcopy>
    80001e36:	02054c63          	bltz	a0,80001e6e <fork+0x74>
  np->sz = p->sz;
    80001e3a:	05093783          	ld	a5,80(s2)
    80001e3e:	e8bc                	sd	a5,80(s1)
  np->parent = p;
    80001e40:	0324b423          	sd	s2,40(s1)
  np->current_maxva = p->current_maxva;
    80001e44:	6785                	lui	a5,0x1
    80001e46:	00f906b3          	add	a3,s2,a5
    80001e4a:	4306b603          	ld	a2,1072(a3)
    80001e4e:	00f48733          	add	a4,s1,a5
    80001e52:	42c73823          	sd	a2,1072(a4)
  np->current_imaxvma = p->current_imaxvma;
    80001e56:	4386a683          	lw	a3,1080(a3)
    80001e5a:	42d72c23          	sw	a3,1080(a4)
  for (int i = NVMA - 1; i >= 0; i--)
    80001e5e:	40078793          	addi	a5,a5,1024 # 1400 <_entry-0x7fffec00>
    80001e62:	00f906b3          	add	a3,s2,a5
    80001e66:	97a6                	add	a5,a5,s1
    80001e68:	14090513          	addi	a0,s2,320
    80001e6c:	a089                	j	80001eae <fork+0xb4>
    freeproc(np);
    80001e6e:	8526                	mv	a0,s1
    80001e70:	00000097          	auipc	ra,0x0
    80001e74:	e3c080e7          	jalr	-452(ra) # 80001cac <freeproc>
    release(&np->lock);
    80001e78:	8526                	mv	a0,s1
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	cf6080e7          	jalr	-778(ra) # 80000b70 <release>
    return -1;
    80001e82:	597d                	li	s2,-1
    80001e84:	a0e1                	j	80001f4c <fork+0x152>
    np->vmas[i].vm_end = p->vmas[i].vm_end;
    80001e86:	6b10                	ld	a2,16(a4)
    80001e88:	eb90                	sd	a2,16(a5)
    np->vmas[i].vm_fd = p->vmas[i].vm_fd;
    80001e8a:	5710                	lw	a2,40(a4)
    80001e8c:	d790                	sw	a2,40(a5)
    np->vmas[i].vm_file = p->vmas[i].vm_file;
    80001e8e:	7310                	ld	a2,32(a4)
    80001e90:	f390                	sd	a2,32(a5)
    np->vmas[i].vm_flags = p->vmas[i].vm_flags;
    80001e92:	4f10                	lw	a2,24(a4)
    80001e94:	cf90                	sw	a2,24(a5)
    np->vmas[i].vm_prot = p->vmas[i].vm_prot;
    80001e96:	4f50                	lw	a2,28(a4)
    80001e98:	cfd0                	sw	a2,28(a5)
    np->vmas[i].vm_start = p->vmas[i].vm_start;
    80001e9a:	6710                	ld	a2,8(a4)
    80001e9c:	e790                	sd	a2,8(a5)
    np->vmas[i].vm_valid = p->vmas[i].vm_valid;
    80001e9e:	4318                	lw	a4,0(a4)
    80001ea0:	c398                	sw	a4,0(a5)
  for (int i = NVMA - 1; i >= 0; i--)
    80001ea2:	fd068693          	addi	a3,a3,-48
    80001ea6:	fd078793          	addi	a5,a5,-48
    80001eaa:	00a68963          	beq	a3,a0,80001ebc <fork+0xc2>
    if(p->vmas[i].vm_file)
    80001eae:	8736                	mv	a4,a3
    80001eb0:	7290                	ld	a2,32(a3)
    80001eb2:	da71                	beqz	a2,80001e86 <fork+0x8c>
      p->vmas[i].vm_file->ref++;
    80001eb4:	424c                	lw	a1,4(a2)
    80001eb6:	2585                	addiw	a1,a1,1
    80001eb8:	c24c                	sw	a1,4(a2)
    80001eba:	b7f1                	j	80001e86 <fork+0x8c>
  *(np->tf) = *(p->tf);
    80001ebc:	06093683          	ld	a3,96(s2)
    80001ec0:	87b6                	mv	a5,a3
    80001ec2:	70b8                	ld	a4,96(s1)
    80001ec4:	12068693          	addi	a3,a3,288
    80001ec8:	0007b803          	ld	a6,0(a5)
    80001ecc:	6788                	ld	a0,8(a5)
    80001ece:	6b8c                	ld	a1,16(a5)
    80001ed0:	6f90                	ld	a2,24(a5)
    80001ed2:	01073023          	sd	a6,0(a4)
    80001ed6:	e708                	sd	a0,8(a4)
    80001ed8:	eb0c                	sd	a1,16(a4)
    80001eda:	ef10                	sd	a2,24(a4)
    80001edc:	02078793          	addi	a5,a5,32
    80001ee0:	02070713          	addi	a4,a4,32
    80001ee4:	fed792e3          	bne	a5,a3,80001ec8 <fork+0xce>
  np->tf->a0 = 0;
    80001ee8:	70bc                	ld	a5,96(s1)
    80001eea:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001eee:	0d890993          	addi	s3,s2,216
    80001ef2:	0d848a13          	addi	s4,s1,216
    80001ef6:	15890a93          	addi	s5,s2,344
    80001efa:	a029                	j	80001f04 <fork+0x10a>
    80001efc:	09a1                	addi	s3,s3,8
    80001efe:	0a21                	addi	s4,s4,8
    80001f00:	01598c63          	beq	s3,s5,80001f18 <fork+0x11e>
    if(p->ofile[i])
    80001f04:	0009b503          	ld	a0,0(s3)
    80001f08:	d975                	beqz	a0,80001efc <fork+0x102>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f0a:	00003097          	auipc	ra,0x3
    80001f0e:	a14080e7          	jalr	-1516(ra) # 8000491e <filedup>
    80001f12:	00aa3023          	sd	a0,0(s4)
    80001f16:	b7dd                	j	80001efc <fork+0x102>
  np->cwd = idup(p->cwd);
    80001f18:	15893503          	ld	a0,344(s2)
    80001f1c:	00002097          	auipc	ra,0x2
    80001f20:	a98080e7          	jalr	-1384(ra) # 800039b4 <idup>
    80001f24:	14a4bc23          	sd	a0,344(s1)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f28:	4641                	li	a2,16
    80001f2a:	16090593          	addi	a1,s2,352
    80001f2e:	16048513          	addi	a0,s1,352
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	f8e080e7          	jalr	-114(ra) # 80000ec0 <safestrcpy>
  pid = np->pid;
    80001f3a:	0404a903          	lw	s2,64(s1)
  np->state = RUNNABLE;
    80001f3e:	4789                	li	a5,2
    80001f40:	d09c                	sw	a5,32(s1)
  release(&np->lock);
    80001f42:	8526                	mv	a0,s1
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	c2c080e7          	jalr	-980(ra) # 80000b70 <release>
}
    80001f4c:	854a                	mv	a0,s2
    80001f4e:	70e2                	ld	ra,56(sp)
    80001f50:	7442                	ld	s0,48(sp)
    80001f52:	74a2                	ld	s1,40(sp)
    80001f54:	7902                	ld	s2,32(sp)
    80001f56:	69e2                	ld	s3,24(sp)
    80001f58:	6a42                	ld	s4,16(sp)
    80001f5a:	6aa2                	ld	s5,8(sp)
    80001f5c:	6121                	addi	sp,sp,64
    80001f5e:	8082                	ret
    return -1;
    80001f60:	597d                	li	s2,-1
    80001f62:	b7ed                	j	80001f4c <fork+0x152>

0000000080001f64 <reparent>:
{
    80001f64:	7139                	addi	sp,sp,-64
    80001f66:	fc06                	sd	ra,56(sp)
    80001f68:	f822                	sd	s0,48(sp)
    80001f6a:	f426                	sd	s1,40(sp)
    80001f6c:	f04a                	sd	s2,32(sp)
    80001f6e:	ec4e                	sd	s3,24(sp)
    80001f70:	e852                	sd	s4,16(sp)
    80001f72:	e456                	sd	s5,8(sp)
    80001f74:	0080                	addi	s0,sp,64
    80001f76:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f78:	00014497          	auipc	s1,0x14
    80001f7c:	ce848493          	addi	s1,s1,-792 # 80015c60 <proc>
      pp->parent = initproc;
    80001f80:	00032a97          	auipc	s5,0x32
    80001f84:	0b8a8a93          	addi	s5,s5,184 # 80034038 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f88:	6905                	lui	s2,0x1
    80001f8a:	44090913          	addi	s2,s2,1088 # 1440 <_entry-0x7fffebc0>
    80001f8e:	00020a17          	auipc	s4,0x20
    80001f92:	752a0a13          	addi	s4,s4,1874 # 800226e0 <tickslock>
    80001f96:	a021                	j	80001f9e <reparent+0x3a>
    80001f98:	94ca                	add	s1,s1,s2
    80001f9a:	03448363          	beq	s1,s4,80001fc0 <reparent+0x5c>
    if(pp->parent == p){
    80001f9e:	749c                	ld	a5,40(s1)
    80001fa0:	ff379ce3          	bne	a5,s3,80001f98 <reparent+0x34>
      acquire(&pp->lock);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	afa080e7          	jalr	-1286(ra) # 80000aa0 <acquire>
      pp->parent = initproc;
    80001fae:	000ab783          	ld	a5,0(s5)
    80001fb2:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	bba080e7          	jalr	-1094(ra) # 80000b70 <release>
    80001fbe:	bfe9                	j	80001f98 <reparent+0x34>
}
    80001fc0:	70e2                	ld	ra,56(sp)
    80001fc2:	7442                	ld	s0,48(sp)
    80001fc4:	74a2                	ld	s1,40(sp)
    80001fc6:	7902                	ld	s2,32(sp)
    80001fc8:	69e2                	ld	s3,24(sp)
    80001fca:	6a42                	ld	s4,16(sp)
    80001fcc:	6aa2                	ld	s5,8(sp)
    80001fce:	6121                	addi	sp,sp,64
    80001fd0:	8082                	ret

0000000080001fd2 <scheduler>:
{
    80001fd2:	711d                	addi	sp,sp,-96
    80001fd4:	ec86                	sd	ra,88(sp)
    80001fd6:	e8a2                	sd	s0,80(sp)
    80001fd8:	e4a6                	sd	s1,72(sp)
    80001fda:	e0ca                	sd	s2,64(sp)
    80001fdc:	fc4e                	sd	s3,56(sp)
    80001fde:	f852                	sd	s4,48(sp)
    80001fe0:	f456                	sd	s5,40(sp)
    80001fe2:	f05a                	sd	s6,32(sp)
    80001fe4:	ec5e                	sd	s7,24(sp)
    80001fe6:	e862                	sd	s8,16(sp)
    80001fe8:	e466                	sd	s9,8(sp)
    80001fea:	1080                	addi	s0,sp,96
    80001fec:	8792                	mv	a5,tp
  int id = r_tp();
    80001fee:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ff0:	00779b93          	slli	s7,a5,0x7
    80001ff4:	00014717          	auipc	a4,0x14
    80001ff8:	84c70713          	addi	a4,a4,-1972 # 80015840 <pid_lock>
    80001ffc:	975e                	add	a4,a4,s7
    80001ffe:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    80002002:	00014717          	auipc	a4,0x14
    80002006:	86670713          	addi	a4,a4,-1946 # 80015868 <cpus+0x8>
    8000200a:	9bba                	add	s7,s7,a4
        p->state = RUNNING;
    8000200c:	4c0d                	li	s8,3
        c->proc = p;
    8000200e:	079e                	slli	a5,a5,0x7
    80002010:	00014917          	auipc	s2,0x14
    80002014:	83090913          	addi	s2,s2,-2000 # 80015840 <pid_lock>
    80002018:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000201a:	6a85                	lui	s5,0x1
    8000201c:	440a8a93          	addi	s5,s5,1088 # 1440 <_entry-0x7fffebc0>
    80002020:	a0b1                	j	8000206c <scheduler+0x9a>
      c->intena = 0;
    80002022:	08092e23          	sw	zero,156(s2)
      release(&p->lock);
    80002026:	8526                	mv	a0,s1
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	b48080e7          	jalr	-1208(ra) # 80000b70 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002030:	94d6                	add	s1,s1,s5
    80002032:	03448963          	beq	s1,s4,80002064 <scheduler+0x92>
      acquire(&p->lock);
    80002036:	8526                	mv	a0,s1
    80002038:	fffff097          	auipc	ra,0xfffff
    8000203c:	a68080e7          	jalr	-1432(ra) # 80000aa0 <acquire>
      if(p->state == RUNNABLE) {
    80002040:	509c                	lw	a5,32(s1)
    80002042:	ff3790e3          	bne	a5,s3,80002022 <scheduler+0x50>
        p->state = RUNNING;
    80002046:	0384a023          	sw	s8,32(s1)
        c->proc = p;
    8000204a:	02993023          	sd	s1,32(s2)
        swtch(&c->scheduler, &p->context);
    8000204e:	06848593          	addi	a1,s1,104
    80002052:	855e                	mv	a0,s7
    80002054:	00000097          	auipc	ra,0x0
    80002058:	6e2080e7          	jalr	1762(ra) # 80002736 <swtch>
        c->proc = 0;
    8000205c:	02093023          	sd	zero,32(s2)
        found = 1;
    80002060:	8b66                	mv	s6,s9
    80002062:	b7c1                	j	80002022 <scheduler+0x50>
    if(found == 0){
    80002064:	000b1863          	bnez	s6,80002074 <scheduler+0xa2>
      asm volatile("wfi");
    80002068:	10500073          	wfi
    for(p = proc; p < &proc[NPROC]; p++) {
    8000206c:	00020a17          	auipc	s4,0x20
    80002070:	674a0a13          	addi	s4,s4,1652 # 800226e0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002074:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002078:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000207c:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002080:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002084:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002086:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000208a:	4b01                	li	s6,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000208c:	00014497          	auipc	s1,0x14
    80002090:	bd448493          	addi	s1,s1,-1068 # 80015c60 <proc>
      if(p->state == RUNNABLE) {
    80002094:	4989                	li	s3,2
        found = 1;
    80002096:	4c85                	li	s9,1
    80002098:	bf79                	j	80002036 <scheduler+0x64>

000000008000209a <sched>:
{
    8000209a:	7179                	addi	sp,sp,-48
    8000209c:	f406                	sd	ra,40(sp)
    8000209e:	f022                	sd	s0,32(sp)
    800020a0:	ec26                	sd	s1,24(sp)
    800020a2:	e84a                	sd	s2,16(sp)
    800020a4:	e44e                	sd	s3,8(sp)
    800020a6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020a8:	00000097          	auipc	ra,0x0
    800020ac:	9b6080e7          	jalr	-1610(ra) # 80001a5e <myproc>
    800020b0:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	970080e7          	jalr	-1680(ra) # 80000a22 <holding>
    800020ba:	c93d                	beqz	a0,80002130 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020bc:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020be:	2781                	sext.w	a5,a5
    800020c0:	079e                	slli	a5,a5,0x7
    800020c2:	00013717          	auipc	a4,0x13
    800020c6:	77e70713          	addi	a4,a4,1918 # 80015840 <pid_lock>
    800020ca:	97ba                	add	a5,a5,a4
    800020cc:	0987a703          	lw	a4,152(a5)
    800020d0:	4785                	li	a5,1
    800020d2:	06f71763          	bne	a4,a5,80002140 <sched+0xa6>
  if(p->state == RUNNING)
    800020d6:	5098                	lw	a4,32(s1)
    800020d8:	478d                	li	a5,3
    800020da:	06f70b63          	beq	a4,a5,80002150 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020de:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020e2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020e4:	efb5                	bnez	a5,80002160 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020e6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020e8:	00013917          	auipc	s2,0x13
    800020ec:	75890913          	addi	s2,s2,1880 # 80015840 <pid_lock>
    800020f0:	2781                	sext.w	a5,a5
    800020f2:	079e                	slli	a5,a5,0x7
    800020f4:	97ca                	add	a5,a5,s2
    800020f6:	09c7a983          	lw	s3,156(a5)
    800020fa:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    800020fc:	2781                	sext.w	a5,a5
    800020fe:	079e                	slli	a5,a5,0x7
    80002100:	00013597          	auipc	a1,0x13
    80002104:	76858593          	addi	a1,a1,1896 # 80015868 <cpus+0x8>
    80002108:	95be                	add	a1,a1,a5
    8000210a:	06848513          	addi	a0,s1,104
    8000210e:	00000097          	auipc	ra,0x0
    80002112:	628080e7          	jalr	1576(ra) # 80002736 <swtch>
    80002116:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002118:	2781                	sext.w	a5,a5
    8000211a:	079e                	slli	a5,a5,0x7
    8000211c:	97ca                	add	a5,a5,s2
    8000211e:	0937ae23          	sw	s3,156(a5)
}
    80002122:	70a2                	ld	ra,40(sp)
    80002124:	7402                	ld	s0,32(sp)
    80002126:	64e2                	ld	s1,24(sp)
    80002128:	6942                	ld	s2,16(sp)
    8000212a:	69a2                	ld	s3,8(sp)
    8000212c:	6145                	addi	sp,sp,48
    8000212e:	8082                	ret
    panic("sched p->lock");
    80002130:	00006517          	auipc	a0,0x6
    80002134:	32850513          	addi	a0,a0,808 # 80008458 <userret+0x3c8>
    80002138:	ffffe097          	auipc	ra,0xffffe
    8000213c:	41c080e7          	jalr	1052(ra) # 80000554 <panic>
    panic("sched locks");
    80002140:	00006517          	auipc	a0,0x6
    80002144:	32850513          	addi	a0,a0,808 # 80008468 <userret+0x3d8>
    80002148:	ffffe097          	auipc	ra,0xffffe
    8000214c:	40c080e7          	jalr	1036(ra) # 80000554 <panic>
    panic("sched running");
    80002150:	00006517          	auipc	a0,0x6
    80002154:	32850513          	addi	a0,a0,808 # 80008478 <userret+0x3e8>
    80002158:	ffffe097          	auipc	ra,0xffffe
    8000215c:	3fc080e7          	jalr	1020(ra) # 80000554 <panic>
    panic("sched interruptible");
    80002160:	00006517          	auipc	a0,0x6
    80002164:	32850513          	addi	a0,a0,808 # 80008488 <userret+0x3f8>
    80002168:	ffffe097          	auipc	ra,0xffffe
    8000216c:	3ec080e7          	jalr	1004(ra) # 80000554 <panic>

0000000080002170 <exit>:
{
    80002170:	711d                	addi	sp,sp,-96
    80002172:	ec86                	sd	ra,88(sp)
    80002174:	e8a2                	sd	s0,80(sp)
    80002176:	e4a6                	sd	s1,72(sp)
    80002178:	e0ca                	sd	s2,64(sp)
    8000217a:	fc4e                	sd	s3,56(sp)
    8000217c:	f852                	sd	s4,48(sp)
    8000217e:	f456                	sd	s5,40(sp)
    80002180:	f05a                	sd	s6,32(sp)
    80002182:	ec5e                	sd	s7,24(sp)
    80002184:	e862                	sd	s8,16(sp)
    80002186:	e466                	sd	s9,8(sp)
    80002188:	1080                	addi	s0,sp,96
    8000218a:	8c2a                	mv	s8,a0
  struct proc *p = myproc();
    8000218c:	00000097          	auipc	ra,0x0
    80002190:	8d2080e7          	jalr	-1838(ra) # 80001a5e <myproc>
    80002194:	8aaa                	mv	s5,a0
  if(p == initproc)
    80002196:	00032797          	auipc	a5,0x32
    8000219a:	ea27b783          	ld	a5,-350(a5) # 80034038 <initproc>
    8000219e:	0d850493          	addi	s1,a0,216
    800021a2:	15850913          	addi	s2,a0,344
    800021a6:	00a79d63          	bne	a5,a0,800021c0 <exit+0x50>
    panic("init exiting");
    800021aa:	00006517          	auipc	a0,0x6
    800021ae:	2f650513          	addi	a0,a0,758 # 800084a0 <userret+0x410>
    800021b2:	ffffe097          	auipc	ra,0xffffe
    800021b6:	3a2080e7          	jalr	930(ra) # 80000554 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800021ba:	04a1                	addi	s1,s1,8
    800021bc:	01248b63          	beq	s1,s2,800021d2 <exit+0x62>
    if(p->ofile[fd]){
    800021c0:	6088                	ld	a0,0(s1)
    800021c2:	dd65                	beqz	a0,800021ba <exit+0x4a>
      fileclose(f);
    800021c4:	00002097          	auipc	ra,0x2
    800021c8:	7ac080e7          	jalr	1964(ra) # 80004970 <fileclose>
      p->ofile[fd] = 0;
    800021cc:	0004b023          	sd	zero,0(s1)
    800021d0:	b7ed                	j	800021ba <exit+0x4a>
    800021d2:	170a8493          	addi	s1,s5,368
    800021d6:	6a05                	lui	s4,0x1
    800021d8:	430a0a13          	addi	s4,s4,1072 # 1430 <_entry-0x7fffebd0>
    800021dc:	9a56                	add	s4,s4,s5
      vma->vm_valid = 1;
    800021de:	4b05                	li	s6,1
        if(vma->vm_flags == MAP_SHARED){
    800021e0:	4b89                	li	s7,2
          printf("sys_munmap(): write back \n");
    800021e2:	00006c97          	auipc	s9,0x6
    800021e6:	2cec8c93          	addi	s9,s9,718 # 800084b0 <userret+0x420>
    800021ea:	a805                	j	8000221a <exit+0xaa>
        uvmunmap(p->pagetable, vma->vm_start, totsz,1);
    800021ec:	86da                	mv	a3,s6
    800021ee:	864a                	mv	a2,s2
    800021f0:	0089b583          	ld	a1,8(s3)
    800021f4:	058ab503          	ld	a0,88(s5)
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	1bc080e7          	jalr	444(ra) # 800013b4 <uvmunmap>
      vma->vm_start += totsz;
    80002200:	0089b603          	ld	a2,8(s3)
    80002204:	964a                	add	a2,a2,s2
    80002206:	00c9b423          	sd	a2,8(s3)
      if(vma->vm_start == vma->vm_end){
    8000220a:	0109b783          	ld	a5,16(s3)
    8000220e:	04f60663          	beq	a2,a5,8000225a <exit+0xea>
  for (int i = 0; i < NVMA; i++)
    80002212:	03048493          	addi	s1,s1,48
    80002216:	05448863          	beq	s1,s4,80002266 <exit+0xf6>
    if(!p->vmas[i].vm_valid){
    8000221a:	89a6                	mv	s3,s1
    8000221c:	409c                	lw	a5,0(s1)
    8000221e:	fbf5                	bnez	a5,80002212 <exit+0xa2>
      vma->vm_valid = 1;
    80002220:	0164a023          	sw	s6,0(s1)
      int totsz = vma->vm_end - vma->vm_start;
    80002224:	648c                	ld	a1,8(s1)
    80002226:	6890                	ld	a2,16(s1)
    80002228:	40b6093b          	subw	s2,a2,a1
      if(walkaddr(p->pagetable, vma->vm_start)){
    8000222c:	058ab503          	ld	a0,88(s5)
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	f38080e7          	jalr	-200(ra) # 80001168 <walkaddr>
    80002238:	d561                	beqz	a0,80002200 <exit+0x90>
        if(vma->vm_flags == MAP_SHARED){
    8000223a:	4c9c                	lw	a5,24(s1)
    8000223c:	fb7798e3          	bne	a5,s7,800021ec <exit+0x7c>
          printf("sys_munmap(): write back \n");
    80002240:	8566                	mv	a0,s9
    80002242:	ffffe097          	auipc	ra,0xffffe
    80002246:	36c080e7          	jalr	876(ra) # 800005ae <printf>
          filewrite(vma->vm_file, vma->vm_start, totsz);
    8000224a:	864a                	mv	a2,s2
    8000224c:	648c                	ld	a1,8(s1)
    8000224e:	7088                	ld	a0,32(s1)
    80002250:	00003097          	auipc	ra,0x3
    80002254:	928080e7          	jalr	-1752(ra) # 80004b78 <filewrite>
    80002258:	bf51                	j	800021ec <exit+0x7c>
        vma->vm_file->ref--;
    8000225a:	0209b703          	ld	a4,32(s3)
    8000225e:	435c                	lw	a5,4(a4)
    80002260:	37fd                	addiw	a5,a5,-1
    80002262:	c35c                	sw	a5,4(a4)
    80002264:	b77d                	j	80002212 <exit+0xa2>
  p->current_maxva = VMASTART;
    80002266:	6705                	lui	a4,0x1
    80002268:	9756                	add	a4,a4,s5
    8000226a:	020007b7          	lui	a5,0x2000
    8000226e:	17fd                	addi	a5,a5,-1
    80002270:	07b6                	slli	a5,a5,0xd
    80002272:	42f73823          	sd	a5,1072(a4) # 1430 <_entry-0x7fffebd0>
  begin_op(ROOTDEV);
    80002276:	4501                	li	a0,0
    80002278:	00002097          	auipc	ra,0x2
    8000227c:	15e080e7          	jalr	350(ra) # 800043d6 <begin_op>
  iput(p->cwd);
    80002280:	158ab503          	ld	a0,344(s5)
    80002284:	00002097          	auipc	ra,0x2
    80002288:	87c080e7          	jalr	-1924(ra) # 80003b00 <iput>
  end_op(ROOTDEV);
    8000228c:	4501                	li	a0,0
    8000228e:	00002097          	auipc	ra,0x2
    80002292:	1f2080e7          	jalr	498(ra) # 80004480 <end_op>
  p->cwd = 0;
    80002296:	140abc23          	sd	zero,344(s5)
  acquire(&initproc->lock);
    8000229a:	00032497          	auipc	s1,0x32
    8000229e:	d9e48493          	addi	s1,s1,-610 # 80034038 <initproc>
    800022a2:	6088                	ld	a0,0(s1)
    800022a4:	ffffe097          	auipc	ra,0xffffe
    800022a8:	7fc080e7          	jalr	2044(ra) # 80000aa0 <acquire>
  wakeup1(initproc);
    800022ac:	6088                	ld	a0,0(s1)
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	66a080e7          	jalr	1642(ra) # 80001918 <wakeup1>
  release(&initproc->lock);
    800022b6:	6088                	ld	a0,0(s1)
    800022b8:	fffff097          	auipc	ra,0xfffff
    800022bc:	8b8080e7          	jalr	-1864(ra) # 80000b70 <release>
  acquire(&p->lock);
    800022c0:	8556                	mv	a0,s5
    800022c2:	ffffe097          	auipc	ra,0xffffe
    800022c6:	7de080e7          	jalr	2014(ra) # 80000aa0 <acquire>
  struct proc *original_parent = p->parent;
    800022ca:	028ab483          	ld	s1,40(s5)
  release(&p->lock);
    800022ce:	8556                	mv	a0,s5
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	8a0080e7          	jalr	-1888(ra) # 80000b70 <release>
  acquire(&original_parent->lock);
    800022d8:	8526                	mv	a0,s1
    800022da:	ffffe097          	auipc	ra,0xffffe
    800022de:	7c6080e7          	jalr	1990(ra) # 80000aa0 <acquire>
  acquire(&p->lock);
    800022e2:	8556                	mv	a0,s5
    800022e4:	ffffe097          	auipc	ra,0xffffe
    800022e8:	7bc080e7          	jalr	1980(ra) # 80000aa0 <acquire>
  reparent(p);
    800022ec:	8556                	mv	a0,s5
    800022ee:	00000097          	auipc	ra,0x0
    800022f2:	c76080e7          	jalr	-906(ra) # 80001f64 <reparent>
  wakeup1(original_parent);
    800022f6:	8526                	mv	a0,s1
    800022f8:	fffff097          	auipc	ra,0xfffff
    800022fc:	620080e7          	jalr	1568(ra) # 80001918 <wakeup1>
  p->xstate = status;
    80002300:	038aae23          	sw	s8,60(s5)
  p->state = ZOMBIE;
    80002304:	4791                	li	a5,4
    80002306:	02faa023          	sw	a5,32(s5)
  release(&original_parent->lock);
    8000230a:	8526                	mv	a0,s1
    8000230c:	fffff097          	auipc	ra,0xfffff
    80002310:	864080e7          	jalr	-1948(ra) # 80000b70 <release>
  sched();
    80002314:	00000097          	auipc	ra,0x0
    80002318:	d86080e7          	jalr	-634(ra) # 8000209a <sched>
  panic("zombie exit");
    8000231c:	00006517          	auipc	a0,0x6
    80002320:	1b450513          	addi	a0,a0,436 # 800084d0 <userret+0x440>
    80002324:	ffffe097          	auipc	ra,0xffffe
    80002328:	230080e7          	jalr	560(ra) # 80000554 <panic>

000000008000232c <yield>:
{
    8000232c:	1101                	addi	sp,sp,-32
    8000232e:	ec06                	sd	ra,24(sp)
    80002330:	e822                	sd	s0,16(sp)
    80002332:	e426                	sd	s1,8(sp)
    80002334:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	728080e7          	jalr	1832(ra) # 80001a5e <myproc>
    8000233e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002340:	ffffe097          	auipc	ra,0xffffe
    80002344:	760080e7          	jalr	1888(ra) # 80000aa0 <acquire>
  p->state = RUNNABLE;
    80002348:	4789                	li	a5,2
    8000234a:	d09c                	sw	a5,32(s1)
  sched();
    8000234c:	00000097          	auipc	ra,0x0
    80002350:	d4e080e7          	jalr	-690(ra) # 8000209a <sched>
  release(&p->lock);
    80002354:	8526                	mv	a0,s1
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	81a080e7          	jalr	-2022(ra) # 80000b70 <release>
}
    8000235e:	60e2                	ld	ra,24(sp)
    80002360:	6442                	ld	s0,16(sp)
    80002362:	64a2                	ld	s1,8(sp)
    80002364:	6105                	addi	sp,sp,32
    80002366:	8082                	ret

0000000080002368 <sleep>:
{
    80002368:	7179                	addi	sp,sp,-48
    8000236a:	f406                	sd	ra,40(sp)
    8000236c:	f022                	sd	s0,32(sp)
    8000236e:	ec26                	sd	s1,24(sp)
    80002370:	e84a                	sd	s2,16(sp)
    80002372:	e44e                	sd	s3,8(sp)
    80002374:	1800                	addi	s0,sp,48
    80002376:	89aa                	mv	s3,a0
    80002378:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	6e4080e7          	jalr	1764(ra) # 80001a5e <myproc>
    80002382:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002384:	05250663          	beq	a0,s2,800023d0 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002388:	ffffe097          	auipc	ra,0xffffe
    8000238c:	718080e7          	jalr	1816(ra) # 80000aa0 <acquire>
    release(lk);
    80002390:	854a                	mv	a0,s2
    80002392:	ffffe097          	auipc	ra,0xffffe
    80002396:	7de080e7          	jalr	2014(ra) # 80000b70 <release>
  p->chan = chan;
    8000239a:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000239e:	4785                	li	a5,1
    800023a0:	d09c                	sw	a5,32(s1)
  sched();
    800023a2:	00000097          	auipc	ra,0x0
    800023a6:	cf8080e7          	jalr	-776(ra) # 8000209a <sched>
  p->chan = 0;
    800023aa:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    800023ae:	8526                	mv	a0,s1
    800023b0:	ffffe097          	auipc	ra,0xffffe
    800023b4:	7c0080e7          	jalr	1984(ra) # 80000b70 <release>
    acquire(lk);
    800023b8:	854a                	mv	a0,s2
    800023ba:	ffffe097          	auipc	ra,0xffffe
    800023be:	6e6080e7          	jalr	1766(ra) # 80000aa0 <acquire>
}
    800023c2:	70a2                	ld	ra,40(sp)
    800023c4:	7402                	ld	s0,32(sp)
    800023c6:	64e2                	ld	s1,24(sp)
    800023c8:	6942                	ld	s2,16(sp)
    800023ca:	69a2                	ld	s3,8(sp)
    800023cc:	6145                	addi	sp,sp,48
    800023ce:	8082                	ret
  p->chan = chan;
    800023d0:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800023d4:	4785                	li	a5,1
    800023d6:	d11c                	sw	a5,32(a0)
  sched();
    800023d8:	00000097          	auipc	ra,0x0
    800023dc:	cc2080e7          	jalr	-830(ra) # 8000209a <sched>
  p->chan = 0;
    800023e0:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800023e4:	bff9                	j	800023c2 <sleep+0x5a>

00000000800023e6 <wait>:
{
    800023e6:	715d                	addi	sp,sp,-80
    800023e8:	e486                	sd	ra,72(sp)
    800023ea:	e0a2                	sd	s0,64(sp)
    800023ec:	fc26                	sd	s1,56(sp)
    800023ee:	f84a                	sd	s2,48(sp)
    800023f0:	f44e                	sd	s3,40(sp)
    800023f2:	f052                	sd	s4,32(sp)
    800023f4:	ec56                	sd	s5,24(sp)
    800023f6:	e85a                	sd	s6,16(sp)
    800023f8:	e45e                	sd	s7,8(sp)
    800023fa:	0880                	addi	s0,sp,80
    800023fc:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	660080e7          	jalr	1632(ra) # 80001a5e <myproc>
    80002406:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002408:	ffffe097          	auipc	ra,0xffffe
    8000240c:	698080e7          	jalr	1688(ra) # 80000aa0 <acquire>
        if(np->state == ZOMBIE){
    80002410:	4a91                	li	s5,4
        havekids = 1;
    80002412:	4b85                	li	s7,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002414:	6985                	lui	s3,0x1
    80002416:	44098993          	addi	s3,s3,1088 # 1440 <_entry-0x7fffebc0>
    8000241a:	00020a17          	auipc	s4,0x20
    8000241e:	2c6a0a13          	addi	s4,s4,710 # 800226e0 <tickslock>
    havekids = 0;
    80002422:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    80002424:	00014497          	auipc	s1,0x14
    80002428:	83c48493          	addi	s1,s1,-1988 # 80015c60 <proc>
    8000242c:	a085                	j	8000248c <wait+0xa6>
          pid = np->pid;
    8000242e:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002432:	000b0e63          	beqz	s6,8000244e <wait+0x68>
    80002436:	4691                	li	a3,4
    80002438:	03c48613          	addi	a2,s1,60
    8000243c:	85da                	mv	a1,s6
    8000243e:	05893503          	ld	a0,88(s2)
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	308080e7          	jalr	776(ra) # 8000174a <copyout>
    8000244a:	02054263          	bltz	a0,8000246e <wait+0x88>
          freeproc(np);
    8000244e:	8526                	mv	a0,s1
    80002450:	00000097          	auipc	ra,0x0
    80002454:	85c080e7          	jalr	-1956(ra) # 80001cac <freeproc>
          release(&np->lock);
    80002458:	8526                	mv	a0,s1
    8000245a:	ffffe097          	auipc	ra,0xffffe
    8000245e:	716080e7          	jalr	1814(ra) # 80000b70 <release>
          release(&p->lock);
    80002462:	854a                	mv	a0,s2
    80002464:	ffffe097          	auipc	ra,0xffffe
    80002468:	70c080e7          	jalr	1804(ra) # 80000b70 <release>
          return pid;
    8000246c:	a8a1                	j	800024c4 <wait+0xde>
            release(&np->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	ffffe097          	auipc	ra,0xffffe
    80002474:	700080e7          	jalr	1792(ra) # 80000b70 <release>
            release(&p->lock);
    80002478:	854a                	mv	a0,s2
    8000247a:	ffffe097          	auipc	ra,0xffffe
    8000247e:	6f6080e7          	jalr	1782(ra) # 80000b70 <release>
            return -1;
    80002482:	59fd                	li	s3,-1
    80002484:	a081                	j	800024c4 <wait+0xde>
    for(np = proc; np < &proc[NPROC]; np++){
    80002486:	94ce                	add	s1,s1,s3
    80002488:	03448463          	beq	s1,s4,800024b0 <wait+0xca>
      if(np->parent == p){
    8000248c:	749c                	ld	a5,40(s1)
    8000248e:	ff279ce3          	bne	a5,s2,80002486 <wait+0xa0>
        acquire(&np->lock);
    80002492:	8526                	mv	a0,s1
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	60c080e7          	jalr	1548(ra) # 80000aa0 <acquire>
        if(np->state == ZOMBIE){
    8000249c:	509c                	lw	a5,32(s1)
    8000249e:	f95788e3          	beq	a5,s5,8000242e <wait+0x48>
        release(&np->lock);
    800024a2:	8526                	mv	a0,s1
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	6cc080e7          	jalr	1740(ra) # 80000b70 <release>
        havekids = 1;
    800024ac:	875e                	mv	a4,s7
    800024ae:	bfe1                	j	80002486 <wait+0xa0>
    if(!havekids || p->killed){
    800024b0:	c701                	beqz	a4,800024b8 <wait+0xd2>
    800024b2:	03892783          	lw	a5,56(s2)
    800024b6:	c39d                	beqz	a5,800024dc <wait+0xf6>
      release(&p->lock);
    800024b8:	854a                	mv	a0,s2
    800024ba:	ffffe097          	auipc	ra,0xffffe
    800024be:	6b6080e7          	jalr	1718(ra) # 80000b70 <release>
      return -1;
    800024c2:	59fd                	li	s3,-1
}
    800024c4:	854e                	mv	a0,s3
    800024c6:	60a6                	ld	ra,72(sp)
    800024c8:	6406                	ld	s0,64(sp)
    800024ca:	74e2                	ld	s1,56(sp)
    800024cc:	7942                	ld	s2,48(sp)
    800024ce:	79a2                	ld	s3,40(sp)
    800024d0:	7a02                	ld	s4,32(sp)
    800024d2:	6ae2                	ld	s5,24(sp)
    800024d4:	6b42                	ld	s6,16(sp)
    800024d6:	6ba2                	ld	s7,8(sp)
    800024d8:	6161                	addi	sp,sp,80
    800024da:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800024dc:	85ca                	mv	a1,s2
    800024de:	854a                	mv	a0,s2
    800024e0:	00000097          	auipc	ra,0x0
    800024e4:	e88080e7          	jalr	-376(ra) # 80002368 <sleep>
    havekids = 0;
    800024e8:	bf2d                	j	80002422 <wait+0x3c>

00000000800024ea <wakeup>:
{
    800024ea:	7139                	addi	sp,sp,-64
    800024ec:	fc06                	sd	ra,56(sp)
    800024ee:	f822                	sd	s0,48(sp)
    800024f0:	f426                	sd	s1,40(sp)
    800024f2:	f04a                	sd	s2,32(sp)
    800024f4:	ec4e                	sd	s3,24(sp)
    800024f6:	e852                	sd	s4,16(sp)
    800024f8:	e456                	sd	s5,8(sp)
    800024fa:	e05a                	sd	s6,0(sp)
    800024fc:	0080                	addi	s0,sp,64
    800024fe:	8aaa                	mv	s5,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002500:	00013497          	auipc	s1,0x13
    80002504:	76048493          	addi	s1,s1,1888 # 80015c60 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002508:	4a05                	li	s4,1
      p->state = RUNNABLE;
    8000250a:	4b09                	li	s6,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000250c:	6905                	lui	s2,0x1
    8000250e:	44090913          	addi	s2,s2,1088 # 1440 <_entry-0x7fffebc0>
    80002512:	00020997          	auipc	s3,0x20
    80002516:	1ce98993          	addi	s3,s3,462 # 800226e0 <tickslock>
    8000251a:	a809                	j	8000252c <wakeup+0x42>
    release(&p->lock);
    8000251c:	8526                	mv	a0,s1
    8000251e:	ffffe097          	auipc	ra,0xffffe
    80002522:	652080e7          	jalr	1618(ra) # 80000b70 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002526:	94ca                	add	s1,s1,s2
    80002528:	03348063          	beq	s1,s3,80002548 <wakeup+0x5e>
    acquire(&p->lock);
    8000252c:	8526                	mv	a0,s1
    8000252e:	ffffe097          	auipc	ra,0xffffe
    80002532:	572080e7          	jalr	1394(ra) # 80000aa0 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002536:	509c                	lw	a5,32(s1)
    80002538:	ff4792e3          	bne	a5,s4,8000251c <wakeup+0x32>
    8000253c:	789c                	ld	a5,48(s1)
    8000253e:	fd579fe3          	bne	a5,s5,8000251c <wakeup+0x32>
      p->state = RUNNABLE;
    80002542:	0364a023          	sw	s6,32(s1)
    80002546:	bfd9                	j	8000251c <wakeup+0x32>
}
    80002548:	70e2                	ld	ra,56(sp)
    8000254a:	7442                	ld	s0,48(sp)
    8000254c:	74a2                	ld	s1,40(sp)
    8000254e:	7902                	ld	s2,32(sp)
    80002550:	69e2                	ld	s3,24(sp)
    80002552:	6a42                	ld	s4,16(sp)
    80002554:	6aa2                	ld	s5,8(sp)
    80002556:	6b02                	ld	s6,0(sp)
    80002558:	6121                	addi	sp,sp,64
    8000255a:	8082                	ret

000000008000255c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000255c:	7179                	addi	sp,sp,-48
    8000255e:	f406                	sd	ra,40(sp)
    80002560:	f022                	sd	s0,32(sp)
    80002562:	ec26                	sd	s1,24(sp)
    80002564:	e84a                	sd	s2,16(sp)
    80002566:	e44e                	sd	s3,8(sp)
    80002568:	e052                	sd	s4,0(sp)
    8000256a:	1800                	addi	s0,sp,48
    8000256c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000256e:	00013497          	auipc	s1,0x13
    80002572:	6f248493          	addi	s1,s1,1778 # 80015c60 <proc>
    80002576:	6985                	lui	s3,0x1
    80002578:	44098993          	addi	s3,s3,1088 # 1440 <_entry-0x7fffebc0>
    8000257c:	00020a17          	auipc	s4,0x20
    80002580:	164a0a13          	addi	s4,s4,356 # 800226e0 <tickslock>
    acquire(&p->lock);
    80002584:	8526                	mv	a0,s1
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	51a080e7          	jalr	1306(ra) # 80000aa0 <acquire>
    if(p->pid == pid){
    8000258e:	40bc                	lw	a5,64(s1)
    80002590:	03278363          	beq	a5,s2,800025b6 <kill+0x5a>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002594:	8526                	mv	a0,s1
    80002596:	ffffe097          	auipc	ra,0xffffe
    8000259a:	5da080e7          	jalr	1498(ra) # 80000b70 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000259e:	94ce                	add	s1,s1,s3
    800025a0:	ff4492e3          	bne	s1,s4,80002584 <kill+0x28>
  }
  return -1;
    800025a4:	557d                	li	a0,-1
}
    800025a6:	70a2                	ld	ra,40(sp)
    800025a8:	7402                	ld	s0,32(sp)
    800025aa:	64e2                	ld	s1,24(sp)
    800025ac:	6942                	ld	s2,16(sp)
    800025ae:	69a2                	ld	s3,8(sp)
    800025b0:	6a02                	ld	s4,0(sp)
    800025b2:	6145                	addi	sp,sp,48
    800025b4:	8082                	ret
      p->killed = 1;
    800025b6:	4785                	li	a5,1
    800025b8:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    800025ba:	5098                	lw	a4,32(s1)
    800025bc:	00f70963          	beq	a4,a5,800025ce <kill+0x72>
      release(&p->lock);
    800025c0:	8526                	mv	a0,s1
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	5ae080e7          	jalr	1454(ra) # 80000b70 <release>
      return 0;
    800025ca:	4501                	li	a0,0
    800025cc:	bfe9                	j	800025a6 <kill+0x4a>
        p->state = RUNNABLE;
    800025ce:	4789                	li	a5,2
    800025d0:	d09c                	sw	a5,32(s1)
    800025d2:	b7fd                	j	800025c0 <kill+0x64>

00000000800025d4 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025d4:	7179                	addi	sp,sp,-48
    800025d6:	f406                	sd	ra,40(sp)
    800025d8:	f022                	sd	s0,32(sp)
    800025da:	ec26                	sd	s1,24(sp)
    800025dc:	e84a                	sd	s2,16(sp)
    800025de:	e44e                	sd	s3,8(sp)
    800025e0:	e052                	sd	s4,0(sp)
    800025e2:	1800                	addi	s0,sp,48
    800025e4:	84aa                	mv	s1,a0
    800025e6:	892e                	mv	s2,a1
    800025e8:	89b2                	mv	s3,a2
    800025ea:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ec:	fffff097          	auipc	ra,0xfffff
    800025f0:	472080e7          	jalr	1138(ra) # 80001a5e <myproc>
  if(user_dst){
    800025f4:	c08d                	beqz	s1,80002616 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025f6:	86d2                	mv	a3,s4
    800025f8:	864e                	mv	a2,s3
    800025fa:	85ca                	mv	a1,s2
    800025fc:	6d28                	ld	a0,88(a0)
    800025fe:	fffff097          	auipc	ra,0xfffff
    80002602:	14c080e7          	jalr	332(ra) # 8000174a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002606:	70a2                	ld	ra,40(sp)
    80002608:	7402                	ld	s0,32(sp)
    8000260a:	64e2                	ld	s1,24(sp)
    8000260c:	6942                	ld	s2,16(sp)
    8000260e:	69a2                	ld	s3,8(sp)
    80002610:	6a02                	ld	s4,0(sp)
    80002612:	6145                	addi	sp,sp,48
    80002614:	8082                	ret
    memmove((char *)dst, src, len);
    80002616:	000a061b          	sext.w	a2,s4
    8000261a:	85ce                	mv	a1,s3
    8000261c:	854a                	mv	a0,s2
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	7ac080e7          	jalr	1964(ra) # 80000dca <memmove>
    return 0;
    80002626:	8526                	mv	a0,s1
    80002628:	bff9                	j	80002606 <either_copyout+0x32>

000000008000262a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000262a:	7179                	addi	sp,sp,-48
    8000262c:	f406                	sd	ra,40(sp)
    8000262e:	f022                	sd	s0,32(sp)
    80002630:	ec26                	sd	s1,24(sp)
    80002632:	e84a                	sd	s2,16(sp)
    80002634:	e44e                	sd	s3,8(sp)
    80002636:	e052                	sd	s4,0(sp)
    80002638:	1800                	addi	s0,sp,48
    8000263a:	892a                	mv	s2,a0
    8000263c:	84ae                	mv	s1,a1
    8000263e:	89b2                	mv	s3,a2
    80002640:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002642:	fffff097          	auipc	ra,0xfffff
    80002646:	41c080e7          	jalr	1052(ra) # 80001a5e <myproc>
  if(user_src){
    8000264a:	c08d                	beqz	s1,8000266c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000264c:	86d2                	mv	a3,s4
    8000264e:	864e                	mv	a2,s3
    80002650:	85ca                	mv	a1,s2
    80002652:	6d28                	ld	a0,88(a0)
    80002654:	fffff097          	auipc	ra,0xfffff
    80002658:	182080e7          	jalr	386(ra) # 800017d6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000265c:	70a2                	ld	ra,40(sp)
    8000265e:	7402                	ld	s0,32(sp)
    80002660:	64e2                	ld	s1,24(sp)
    80002662:	6942                	ld	s2,16(sp)
    80002664:	69a2                	ld	s3,8(sp)
    80002666:	6a02                	ld	s4,0(sp)
    80002668:	6145                	addi	sp,sp,48
    8000266a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000266c:	000a061b          	sext.w	a2,s4
    80002670:	85ce                	mv	a1,s3
    80002672:	854a                	mv	a0,s2
    80002674:	ffffe097          	auipc	ra,0xffffe
    80002678:	756080e7          	jalr	1878(ra) # 80000dca <memmove>
    return 0;
    8000267c:	8526                	mv	a0,s1
    8000267e:	bff9                	j	8000265c <either_copyin+0x32>

0000000080002680 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002680:	715d                	addi	sp,sp,-80
    80002682:	e486                	sd	ra,72(sp)
    80002684:	e0a2                	sd	s0,64(sp)
    80002686:	fc26                	sd	s1,56(sp)
    80002688:	f84a                	sd	s2,48(sp)
    8000268a:	f44e                	sd	s3,40(sp)
    8000268c:	f052                	sd	s4,32(sp)
    8000268e:	ec56                	sd	s5,24(sp)
    80002690:	e85a                	sd	s6,16(sp)
    80002692:	e45e                	sd	s7,8(sp)
    80002694:	e062                	sd	s8,0(sp)
    80002696:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002698:	00006517          	auipc	a0,0x6
    8000269c:	5a850513          	addi	a0,a0,1448 # 80008c40 <userret+0xbb0>
    800026a0:	ffffe097          	auipc	ra,0xffffe
    800026a4:	f0e080e7          	jalr	-242(ra) # 800005ae <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026a8:	00013497          	auipc	s1,0x13
    800026ac:	71848493          	addi	s1,s1,1816 # 80015dc0 <proc+0x160>
    800026b0:	00020997          	auipc	s3,0x20
    800026b4:	19098993          	addi	s3,s3,400 # 80022840 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b8:	4b91                	li	s7,4
      state = states[p->state];
    else
      state = "???";
    800026ba:	00006a17          	auipc	s4,0x6
    800026be:	e26a0a13          	addi	s4,s4,-474 # 800084e0 <userret+0x450>
    printf("%d %s %s", p->pid, state, p->name);
    800026c2:	00006b17          	auipc	s6,0x6
    800026c6:	e26b0b13          	addi	s6,s6,-474 # 800084e8 <userret+0x458>
    printf("\n");
    800026ca:	00006a97          	auipc	s5,0x6
    800026ce:	576a8a93          	addi	s5,s5,1398 # 80008c40 <userret+0xbb0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026d2:	00007c17          	auipc	s8,0x7
    800026d6:	806c0c13          	addi	s8,s8,-2042 # 80008ed8 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    800026da:	6905                	lui	s2,0x1
    800026dc:	44090913          	addi	s2,s2,1088 # 1440 <_entry-0x7fffebc0>
    800026e0:	a005                	j	80002700 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    800026e2:	ee06a583          	lw	a1,-288(a3)
    800026e6:	855a                	mv	a0,s6
    800026e8:	ffffe097          	auipc	ra,0xffffe
    800026ec:	ec6080e7          	jalr	-314(ra) # 800005ae <printf>
    printf("\n");
    800026f0:	8556                	mv	a0,s5
    800026f2:	ffffe097          	auipc	ra,0xffffe
    800026f6:	ebc080e7          	jalr	-324(ra) # 800005ae <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026fa:	94ca                	add	s1,s1,s2
    800026fc:	03348163          	beq	s1,s3,8000271e <procdump+0x9e>
    if(p->state == UNUSED)
    80002700:	86a6                	mv	a3,s1
    80002702:	ec04a783          	lw	a5,-320(s1)
    80002706:	dbf5                	beqz	a5,800026fa <procdump+0x7a>
      state = "???";
    80002708:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000270a:	fcfbece3          	bltu	s7,a5,800026e2 <procdump+0x62>
    8000270e:	1782                	slli	a5,a5,0x20
    80002710:	9381                	srli	a5,a5,0x20
    80002712:	078e                	slli	a5,a5,0x3
    80002714:	97e2                	add	a5,a5,s8
    80002716:	6390                	ld	a2,0(a5)
    80002718:	f669                	bnez	a2,800026e2 <procdump+0x62>
      state = "???";
    8000271a:	8652                	mv	a2,s4
    8000271c:	b7d9                	j	800026e2 <procdump+0x62>
  }
}
    8000271e:	60a6                	ld	ra,72(sp)
    80002720:	6406                	ld	s0,64(sp)
    80002722:	74e2                	ld	s1,56(sp)
    80002724:	7942                	ld	s2,48(sp)
    80002726:	79a2                	ld	s3,40(sp)
    80002728:	7a02                	ld	s4,32(sp)
    8000272a:	6ae2                	ld	s5,24(sp)
    8000272c:	6b42                	ld	s6,16(sp)
    8000272e:	6ba2                	ld	s7,8(sp)
    80002730:	6c02                	ld	s8,0(sp)
    80002732:	6161                	addi	sp,sp,80
    80002734:	8082                	ret

0000000080002736 <swtch>:
    80002736:	00153023          	sd	ra,0(a0)
    8000273a:	00253423          	sd	sp,8(a0)
    8000273e:	e900                	sd	s0,16(a0)
    80002740:	ed04                	sd	s1,24(a0)
    80002742:	03253023          	sd	s2,32(a0)
    80002746:	03353423          	sd	s3,40(a0)
    8000274a:	03453823          	sd	s4,48(a0)
    8000274e:	03553c23          	sd	s5,56(a0)
    80002752:	05653023          	sd	s6,64(a0)
    80002756:	05753423          	sd	s7,72(a0)
    8000275a:	05853823          	sd	s8,80(a0)
    8000275e:	05953c23          	sd	s9,88(a0)
    80002762:	07a53023          	sd	s10,96(a0)
    80002766:	07b53423          	sd	s11,104(a0)
    8000276a:	0005b083          	ld	ra,0(a1)
    8000276e:	0085b103          	ld	sp,8(a1)
    80002772:	6980                	ld	s0,16(a1)
    80002774:	6d84                	ld	s1,24(a1)
    80002776:	0205b903          	ld	s2,32(a1)
    8000277a:	0285b983          	ld	s3,40(a1)
    8000277e:	0305ba03          	ld	s4,48(a1)
    80002782:	0385ba83          	ld	s5,56(a1)
    80002786:	0405bb03          	ld	s6,64(a1)
    8000278a:	0485bb83          	ld	s7,72(a1)
    8000278e:	0505bc03          	ld	s8,80(a1)
    80002792:	0585bc83          	ld	s9,88(a1)
    80002796:	0605bd03          	ld	s10,96(a1)
    8000279a:	0685bd83          	ld	s11,104(a1)
    8000279e:	8082                	ret

00000000800027a0 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    800027a0:	1141                	addi	sp,sp,-16
    800027a2:	e422                	sd	s0,8(sp)
    800027a4:	0800                	addi	s0,sp,16
    800027a6:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    800027a8:	00151713          	slli	a4,a0,0x1
    800027ac:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    800027ae:	04054c63          	bltz	a0,80002806 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    800027b2:	5685                	li	a3,-31
    800027b4:	8285                	srli	a3,a3,0x1
    800027b6:	8ee9                	and	a3,a3,a0
    800027b8:	caad                	beqz	a3,8000282a <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    800027ba:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    800027bc:	00006517          	auipc	a0,0x6
    800027c0:	d6450513          	addi	a0,a0,-668 # 80008520 <userret+0x490>
    } else if (code <= 23) {
    800027c4:	06e6f063          	bgeu	a3,a4,80002824 <scause_desc+0x84>
    } else if (code <= 31) {
    800027c8:	fc100693          	li	a3,-63
    800027cc:	8285                	srli	a3,a3,0x1
    800027ce:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    800027d0:	00006517          	auipc	a0,0x6
    800027d4:	d7850513          	addi	a0,a0,-648 # 80008548 <userret+0x4b8>
    } else if (code <= 31) {
    800027d8:	c6b1                	beqz	a3,80002824 <scause_desc+0x84>
    } else if (code <= 47) {
    800027da:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    800027de:	00006517          	auipc	a0,0x6
    800027e2:	d4250513          	addi	a0,a0,-702 # 80008520 <userret+0x490>
    } else if (code <= 47) {
    800027e6:	02e6ff63          	bgeu	a3,a4,80002824 <scause_desc+0x84>
    } else if (code <= 63) {
    800027ea:	f8100513          	li	a0,-127
    800027ee:	8105                	srli	a0,a0,0x1
    800027f0:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    800027f2:	00006517          	auipc	a0,0x6
    800027f6:	d5650513          	addi	a0,a0,-682 # 80008548 <userret+0x4b8>
    } else if (code <= 63) {
    800027fa:	c78d                	beqz	a5,80002824 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    800027fc:	00006517          	auipc	a0,0x6
    80002800:	d2450513          	addi	a0,a0,-732 # 80008520 <userret+0x490>
    80002804:	a005                	j	80002824 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    80002806:	5505                	li	a0,-31
    80002808:	8105                	srli	a0,a0,0x1
    8000280a:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    8000280c:	00006517          	auipc	a0,0x6
    80002810:	d5c50513          	addi	a0,a0,-676 # 80008568 <userret+0x4d8>
    if (code < NELEM(intr_desc)) {
    80002814:	eb81                	bnez	a5,80002824 <scause_desc+0x84>
      return intr_desc[code];
    80002816:	070e                	slli	a4,a4,0x3
    80002818:	00006797          	auipc	a5,0x6
    8000281c:	6e878793          	addi	a5,a5,1768 # 80008f00 <intr_desc.1>
    80002820:	973e                	add	a4,a4,a5
    80002822:	6308                	ld	a0,0(a4)
    }
  }
}
    80002824:	6422                	ld	s0,8(sp)
    80002826:	0141                	addi	sp,sp,16
    80002828:	8082                	ret
      return nointr_desc[code];
    8000282a:	070e                	slli	a4,a4,0x3
    8000282c:	00006797          	auipc	a5,0x6
    80002830:	6d478793          	addi	a5,a5,1748 # 80008f00 <intr_desc.1>
    80002834:	973e                	add	a4,a4,a5
    80002836:	6348                	ld	a0,128(a4)
    80002838:	b7f5                	j	80002824 <scause_desc+0x84>

000000008000283a <trapinit>:
{
    8000283a:	1141                	addi	sp,sp,-16
    8000283c:	e406                	sd	ra,8(sp)
    8000283e:	e022                	sd	s0,0(sp)
    80002840:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002842:	00006597          	auipc	a1,0x6
    80002846:	d4658593          	addi	a1,a1,-698 # 80008588 <userret+0x4f8>
    8000284a:	00020517          	auipc	a0,0x20
    8000284e:	e9650513          	addi	a0,a0,-362 # 800226e0 <tickslock>
    80002852:	ffffe097          	auipc	ra,0xffffe
    80002856:	17a080e7          	jalr	378(ra) # 800009cc <initlock>
}
    8000285a:	60a2                	ld	ra,8(sp)
    8000285c:	6402                	ld	s0,0(sp)
    8000285e:	0141                	addi	sp,sp,16
    80002860:	8082                	ret

0000000080002862 <trapinithart>:
{
    80002862:	1141                	addi	sp,sp,-16
    80002864:	e422                	sd	s0,8(sp)
    80002866:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002868:	00004797          	auipc	a5,0x4
    8000286c:	b0878793          	addi	a5,a5,-1272 # 80006370 <kernelvec>
    80002870:	10579073          	csrw	stvec,a5
}
    80002874:	6422                	ld	s0,8(sp)
    80002876:	0141                	addi	sp,sp,16
    80002878:	8082                	ret

000000008000287a <usertrapret>:
{
    8000287a:	1141                	addi	sp,sp,-16
    8000287c:	e406                	sd	ra,8(sp)
    8000287e:	e022                	sd	s0,0(sp)
    80002880:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002882:	fffff097          	auipc	ra,0xfffff
    80002886:	1dc080e7          	jalr	476(ra) # 80001a5e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000288a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000288e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002890:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002894:	00005617          	auipc	a2,0x5
    80002898:	76c60613          	addi	a2,a2,1900 # 80008000 <trampoline>
    8000289c:	00005697          	auipc	a3,0x5
    800028a0:	76468693          	addi	a3,a3,1892 # 80008000 <trampoline>
    800028a4:	8e91                	sub	a3,a3,a2
    800028a6:	040007b7          	lui	a5,0x4000
    800028aa:	17fd                	addi	a5,a5,-1
    800028ac:	07b2                	slli	a5,a5,0xc
    800028ae:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028b0:	10569073          	csrw	stvec,a3
  p->tf->kernel_satp = r_satp();         // kernel page table
    800028b4:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028b6:	180026f3          	csrr	a3,satp
    800028ba:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028bc:	7138                	ld	a4,96(a0)
    800028be:	6534                	ld	a3,72(a0)
    800028c0:	6585                	lui	a1,0x1
    800028c2:	96ae                	add	a3,a3,a1
    800028c4:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    800028c6:	7138                	ld	a4,96(a0)
    800028c8:	00000697          	auipc	a3,0x0
    800028cc:	12c68693          	addi	a3,a3,300 # 800029f4 <usertrap>
    800028d0:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    800028d2:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028d4:	8692                	mv	a3,tp
    800028d6:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d8:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028dc:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028e0:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028e4:	10069073          	csrw	sstatus,a3
  w_sepc(p->tf->epc);
    800028e8:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028ea:	6f18                	ld	a4,24(a4)
    800028ec:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    800028f0:	6d2c                	ld	a1,88(a0)
    800028f2:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800028f4:	00005717          	auipc	a4,0x5
    800028f8:	79c70713          	addi	a4,a4,1948 # 80008090 <userret>
    800028fc:	8f11                	sub	a4,a4,a2
    800028fe:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002900:	577d                	li	a4,-1
    80002902:	177e                	slli	a4,a4,0x3f
    80002904:	8dd9                	or	a1,a1,a4
    80002906:	02000537          	lui	a0,0x2000
    8000290a:	157d                	addi	a0,a0,-1
    8000290c:	0536                	slli	a0,a0,0xd
    8000290e:	9782                	jalr	a5
}
    80002910:	60a2                	ld	ra,8(sp)
    80002912:	6402                	ld	s0,0(sp)
    80002914:	0141                	addi	sp,sp,16
    80002916:	8082                	ret

0000000080002918 <clockintr>:
{
    80002918:	1101                	addi	sp,sp,-32
    8000291a:	ec06                	sd	ra,24(sp)
    8000291c:	e822                	sd	s0,16(sp)
    8000291e:	e426                	sd	s1,8(sp)
    80002920:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002922:	00020497          	auipc	s1,0x20
    80002926:	dbe48493          	addi	s1,s1,-578 # 800226e0 <tickslock>
    8000292a:	8526                	mv	a0,s1
    8000292c:	ffffe097          	auipc	ra,0xffffe
    80002930:	174080e7          	jalr	372(ra) # 80000aa0 <acquire>
  ticks++;
    80002934:	00031517          	auipc	a0,0x31
    80002938:	70c50513          	addi	a0,a0,1804 # 80034040 <ticks>
    8000293c:	411c                	lw	a5,0(a0)
    8000293e:	2785                	addiw	a5,a5,1
    80002940:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002942:	00000097          	auipc	ra,0x0
    80002946:	ba8080e7          	jalr	-1112(ra) # 800024ea <wakeup>
  release(&tickslock);
    8000294a:	8526                	mv	a0,s1
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	224080e7          	jalr	548(ra) # 80000b70 <release>
}
    80002954:	60e2                	ld	ra,24(sp)
    80002956:	6442                	ld	s0,16(sp)
    80002958:	64a2                	ld	s1,8(sp)
    8000295a:	6105                	addi	sp,sp,32
    8000295c:	8082                	ret

000000008000295e <devintr>:
{
    8000295e:	1101                	addi	sp,sp,-32
    80002960:	ec06                	sd	ra,24(sp)
    80002962:	e822                	sd	s0,16(sp)
    80002964:	e426                	sd	s1,8(sp)
    80002966:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002968:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    8000296c:	00074d63          	bltz	a4,80002986 <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002970:	57fd                	li	a5,-1
    80002972:	17fe                	slli	a5,a5,0x3f
    80002974:	0785                	addi	a5,a5,1
    return 0;
    80002976:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002978:	04f70d63          	beq	a4,a5,800029d2 <devintr+0x74>
}
    8000297c:	60e2                	ld	ra,24(sp)
    8000297e:	6442                	ld	s0,16(sp)
    80002980:	64a2                	ld	s1,8(sp)
    80002982:	6105                	addi	sp,sp,32
    80002984:	8082                	ret
     (scause & 0xff) == 9){
    80002986:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000298a:	46a5                	li	a3,9
    8000298c:	fed792e3          	bne	a5,a3,80002970 <devintr+0x12>
    int irq = plic_claim();
    80002990:	00004097          	auipc	ra,0x4
    80002994:	ae8080e7          	jalr	-1304(ra) # 80006478 <plic_claim>
    80002998:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000299a:	47a9                	li	a5,10
    8000299c:	00f50a63          	beq	a0,a5,800029b0 <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    800029a0:	fff5079b          	addiw	a5,a0,-1
    800029a4:	4705                	li	a4,1
    800029a6:	00f77a63          	bgeu	a4,a5,800029ba <devintr+0x5c>
    return 1;
    800029aa:	4505                	li	a0,1
    if(irq)
    800029ac:	d8e1                	beqz	s1,8000297c <devintr+0x1e>
    800029ae:	a819                	j	800029c4 <devintr+0x66>
      uartintr();
    800029b0:	ffffe097          	auipc	ra,0xffffe
    800029b4:	e94080e7          	jalr	-364(ra) # 80000844 <uartintr>
    800029b8:	a031                	j	800029c4 <devintr+0x66>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800029ba:	853e                	mv	a0,a5
    800029bc:	00004097          	auipc	ra,0x4
    800029c0:	08a080e7          	jalr	138(ra) # 80006a46 <virtio_disk_intr>
      plic_complete(irq);
    800029c4:	8526                	mv	a0,s1
    800029c6:	00004097          	auipc	ra,0x4
    800029ca:	ad6080e7          	jalr	-1322(ra) # 8000649c <plic_complete>
    return 1;
    800029ce:	4505                	li	a0,1
    800029d0:	b775                	j	8000297c <devintr+0x1e>
    if(cpuid() == 0){
    800029d2:	fffff097          	auipc	ra,0xfffff
    800029d6:	060080e7          	jalr	96(ra) # 80001a32 <cpuid>
    800029da:	c901                	beqz	a0,800029ea <devintr+0x8c>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029dc:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029e0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029e2:	14479073          	csrw	sip,a5
    return 2;
    800029e6:	4509                	li	a0,2
    800029e8:	bf51                	j	8000297c <devintr+0x1e>
      clockintr();
    800029ea:	00000097          	auipc	ra,0x0
    800029ee:	f2e080e7          	jalr	-210(ra) # 80002918 <clockintr>
    800029f2:	b7ed                	j	800029dc <devintr+0x7e>

00000000800029f4 <usertrap>:
{
    800029f4:	7139                	addi	sp,sp,-64
    800029f6:	fc06                	sd	ra,56(sp)
    800029f8:	f822                	sd	s0,48(sp)
    800029fa:	f426                	sd	s1,40(sp)
    800029fc:	f04a                	sd	s2,32(sp)
    800029fe:	ec4e                	sd	s3,24(sp)
    80002a00:	e852                	sd	s4,16(sp)
    80002a02:	e456                	sd	s5,8(sp)
    80002a04:	0080                	addi	s0,sp,64
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a06:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a0a:	1007f793          	andi	a5,a5,256
    80002a0e:	e7bd                	bnez	a5,80002a7c <usertrap+0x88>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a10:	00004797          	auipc	a5,0x4
    80002a14:	96078793          	addi	a5,a5,-1696 # 80006370 <kernelvec>
    80002a18:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a1c:	fffff097          	auipc	ra,0xfffff
    80002a20:	042080e7          	jalr	66(ra) # 80001a5e <myproc>
    80002a24:	89aa                	mv	s3,a0
  p->tf->epc = r_sepc();
    80002a26:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a28:	14102773          	csrr	a4,sepc
    80002a2c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a2e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a32:	47a1                	li	a5,8
    80002a34:	06f71263          	bne	a4,a5,80002a98 <usertrap+0xa4>
    if(p->killed)
    80002a38:	5d1c                	lw	a5,56(a0)
    80002a3a:	eba9                	bnez	a5,80002a8c <usertrap+0x98>
    p->tf->epc += 4;
    80002a3c:	0609b703          	ld	a4,96(s3)
    80002a40:	6f1c                	ld	a5,24(a4)
    80002a42:	0791                	addi	a5,a5,4
    80002a44:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a46:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a4a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a4e:	10079073          	csrw	sstatus,a5
    syscall();
    80002a52:	00000097          	auipc	ra,0x0
    80002a56:	4a0080e7          	jalr	1184(ra) # 80002ef2 <syscall>
  if(p->killed)
    80002a5a:	0389a783          	lw	a5,56(s3)
    80002a5e:	20079963          	bnez	a5,80002c70 <usertrap+0x27c>
  usertrapret();
    80002a62:	00000097          	auipc	ra,0x0
    80002a66:	e18080e7          	jalr	-488(ra) # 8000287a <usertrapret>
}
    80002a6a:	70e2                	ld	ra,56(sp)
    80002a6c:	7442                	ld	s0,48(sp)
    80002a6e:	74a2                	ld	s1,40(sp)
    80002a70:	7902                	ld	s2,32(sp)
    80002a72:	69e2                	ld	s3,24(sp)
    80002a74:	6a42                	ld	s4,16(sp)
    80002a76:	6aa2                	ld	s5,8(sp)
    80002a78:	6121                	addi	sp,sp,64
    80002a7a:	8082                	ret
    panic("usertrap: not from user mode");
    80002a7c:	00006517          	auipc	a0,0x6
    80002a80:	b1450513          	addi	a0,a0,-1260 # 80008590 <userret+0x500>
    80002a84:	ffffe097          	auipc	ra,0xffffe
    80002a88:	ad0080e7          	jalr	-1328(ra) # 80000554 <panic>
      exit(-1);
    80002a8c:	557d                	li	a0,-1
    80002a8e:	fffff097          	auipc	ra,0xfffff
    80002a92:	6e2080e7          	jalr	1762(ra) # 80002170 <exit>
    80002a96:	b75d                	j	80002a3c <usertrap+0x48>
  } else if((which_dev = devintr()) != 0){
    80002a98:	00000097          	auipc	ra,0x0
    80002a9c:	ec6080e7          	jalr	-314(ra) # 8000295e <devintr>
    80002aa0:	84aa                	mv	s1,a0
    80002aa2:	1c051363          	bnez	a0,80002c68 <usertrap+0x274>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aa6:	14202773          	csrr	a4,scause
    if(r_scause() == 13 || r_scause() == 15){
    80002aaa:	47b5                	li	a5,13
    80002aac:	00f70763          	beq	a4,a5,80002aba <usertrap+0xc6>
    80002ab0:	14202773          	csrr	a4,scause
    80002ab4:	47bd                	li	a5,15
    80002ab6:	16f71563          	bne	a4,a5,80002c20 <usertrap+0x22c>
      struct proc* p = myproc();
    80002aba:	fffff097          	auipc	ra,0xfffff
    80002abe:	fa4080e7          	jalr	-92(ra) # 80001a5e <myproc>
    80002ac2:	8a2a                	mv	s4,a0
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ac4:	14302973          	csrr	s2,stval
      uint64 va = PGROUNDDOWN(r_stval());
    80002ac8:	77fd                	lui	a5,0xfffff
    80002aca:	00f97933          	and	s2,s2,a5
      printf("MAXVA: %p, va: %p, current_max: %p\n",MAXVA, va, p->current_maxva);
    80002ace:	6485                	lui	s1,0x1
    80002ad0:	009507b3          	add	a5,a0,s1
    80002ad4:	4307b683          	ld	a3,1072(a5) # fffffffffffff430 <end+0xffffffff7ffcb3d4>
    80002ad8:	864a                	mv	a2,s2
    80002ada:	4585                	li	a1,1
    80002adc:	159a                	slli	a1,a1,0x26
    80002ade:	00006517          	auipc	a0,0x6
    80002ae2:	ad250513          	addi	a0,a0,-1326 # 800085b0 <userret+0x520>
    80002ae6:	ffffe097          	auipc	ra,0xffffe
    80002aea:	ac8080e7          	jalr	-1336(ra) # 800005ae <printf>
      for (int i = NVMA; i >= 0; i--)
    80002aee:	43848793          	addi	a5,s1,1080 # 1438 <_entry-0x7fffebc8>
    80002af2:	97d2                	add	a5,a5,s4
    80002af4:	06400493          	li	s1,100
    80002af8:	56fd                	li	a3,-1
    80002afa:	a031                	j	80002b06 <usertrap+0x112>
    80002afc:	34fd                	addiw	s1,s1,-1
    80002afe:	fd078793          	addi	a5,a5,-48
    80002b02:	18d48563          	beq	s1,a3,80002c8c <usertrap+0x298>
        if(p->vmas[i].vm_start <= va && va <= p->vmas[i].vm_end){
    80002b06:	6398                	ld	a4,0(a5)
    80002b08:	fee96ae3          	bltu	s2,a4,80002afc <usertrap+0x108>
    80002b0c:	6798                	ld	a4,8(a5)
    80002b0e:	ff2767e3          	bltu	a4,s2,80002afc <usertrap+0x108>
      if(va > vma->vm_end){
    80002b12:	00149793          	slli	a5,s1,0x1
    80002b16:	97a6                	add	a5,a5,s1
    80002b18:	0792                	slli	a5,a5,0x4
    80002b1a:	97d2                	add	a5,a5,s4
    80002b1c:	1807b783          	ld	a5,384(a5)
    80002b20:	0b27e763          	bltu	a5,s2,80002bce <usertrap+0x1da>
      char* mem = (char *)kalloc();
    80002b24:	ffffe097          	auipc	ra,0xffffe
    80002b28:	e48080e7          	jalr	-440(ra) # 8000096c <kalloc>
    80002b2c:	8aaa                	mv	s5,a0
      if(mem == 0){
    80002b2e:	cd45                	beqz	a0,80002be6 <usertrap+0x1f2>
      printf("walk va %p result : %d \n",va, walkaddr(p->pagetable, va));
    80002b30:	85ca                	mv	a1,s2
    80002b32:	058a3503          	ld	a0,88(s4)
    80002b36:	ffffe097          	auipc	ra,0xffffe
    80002b3a:	632080e7          	jalr	1586(ra) # 80001168 <walkaddr>
    80002b3e:	862a                	mv	a2,a0
    80002b40:	85ca                	mv	a1,s2
    80002b42:	00006517          	auipc	a0,0x6
    80002b46:	ade50513          	addi	a0,a0,-1314 # 80008620 <userret+0x590>
    80002b4a:	ffffe097          	auipc	ra,0xffffe
    80002b4e:	a64080e7          	jalr	-1436(ra) # 800005ae <printf>
      memset(mem, 0, PGSIZE);
    80002b52:	6605                	lui	a2,0x1
    80002b54:	4581                	li	a1,0
    80002b56:	8556                	mv	a0,s5
    80002b58:	ffffe097          	auipc	ra,0xffffe
    80002b5c:	216080e7          	jalr	534(ra) # 80000d6e <memset>
      if(mappages(p->pagetable, va, PGSIZE, (uint64)mem, vma->vm_prot|PTE_U|PTE_X) < 0){
    80002b60:	00149793          	slli	a5,s1,0x1
    80002b64:	97a6                	add	a5,a5,s1
    80002b66:	0792                	slli	a5,a5,0x4
    80002b68:	97d2                	add	a5,a5,s4
    80002b6a:	18c7a703          	lw	a4,396(a5)
    80002b6e:	01876713          	ori	a4,a4,24
    80002b72:	86d6                	mv	a3,s5
    80002b74:	6605                	lui	a2,0x1
    80002b76:	85ca                	mv	a1,s2
    80002b78:	058a3503          	ld	a0,88(s4)
    80002b7c:	ffffe097          	auipc	ra,0xffffe
    80002b80:	68c080e7          	jalr	1676(ra) # 80001208 <mappages>
    80002b84:	06054d63          	bltz	a0,80002bfe <usertrap+0x20a>
      struct file* f = vma->vm_file;
    80002b88:	00149793          	slli	a5,s1,0x1
    80002b8c:	00978733          	add	a4,a5,s1
    80002b90:	0712                	slli	a4,a4,0x4
    80002b92:	9752                	add	a4,a4,s4
    80002b94:	19073a83          	ld	s5,400(a4)
      int offset = va - vma->vm_start;
    80002b98:	17873483          	ld	s1,376(a4)
    80002b9c:	409904bb          	subw	s1,s2,s1
      ilock(f->ip);
    80002ba0:	018ab503          	ld	a0,24(s5)
    80002ba4:	00001097          	auipc	ra,0x1
    80002ba8:	e4e080e7          	jalr	-434(ra) # 800039f2 <ilock>
      readi(f->ip, 1, va, offset, PGSIZE);
    80002bac:	6705                	lui	a4,0x1
    80002bae:	86a6                	mv	a3,s1
    80002bb0:	864a                	mv	a2,s2
    80002bb2:	4585                	li	a1,1
    80002bb4:	018ab503          	ld	a0,24(s5)
    80002bb8:	00001097          	auipc	ra,0x1
    80002bbc:	0ca080e7          	jalr	202(ra) # 80003c82 <readi>
      iunlock(f->ip);
    80002bc0:	018ab503          	ld	a0,24(s5)
    80002bc4:	00001097          	auipc	ra,0x1
    80002bc8:	ef0080e7          	jalr	-272(ra) # 80003ab4 <iunlock>
    if(r_scause() == 13 || r_scause() == 15){
    80002bcc:	b579                	j	80002a5a <usertrap+0x66>
        printf("usertrap(): va is greater than vm_end \n");
    80002bce:	00006517          	auipc	a0,0x6
    80002bd2:	a0a50513          	addi	a0,a0,-1526 # 800085d8 <userret+0x548>
    80002bd6:	ffffe097          	auipc	ra,0xffffe
    80002bda:	9d8080e7          	jalr	-1576(ra) # 800005ae <printf>
        p->killed = 1;
    80002bde:	4785                	li	a5,1
    80002be0:	02fa2c23          	sw	a5,56(s4)
        goto end;
    80002be4:	bd9d                	j	80002a5a <usertrap+0x66>
        printf("usertrap(): no mem left\n");
    80002be6:	00006517          	auipc	a0,0x6
    80002bea:	a1a50513          	addi	a0,a0,-1510 # 80008600 <userret+0x570>
    80002bee:	ffffe097          	auipc	ra,0xffffe
    80002bf2:	9c0080e7          	jalr	-1600(ra) # 800005ae <printf>
        p->killed = 1;
    80002bf6:	4785                	li	a5,1
    80002bf8:	02fa2c23          	sw	a5,56(s4)
        goto end;
    80002bfc:	bdb9                	j	80002a5a <usertrap+0x66>
        printf("usertrap(): cannot map\n");
    80002bfe:	00006517          	auipc	a0,0x6
    80002c02:	a4250513          	addi	a0,a0,-1470 # 80008640 <userret+0x5b0>
    80002c06:	ffffe097          	auipc	ra,0xffffe
    80002c0a:	9a8080e7          	jalr	-1624(ra) # 800005ae <printf>
        kfree(mem);
    80002c0e:	8556                	mv	a0,s5
    80002c10:	ffffe097          	auipc	ra,0xffffe
    80002c14:	c60080e7          	jalr	-928(ra) # 80000870 <kfree>
        p->killed = 1;
    80002c18:	4785                	li	a5,1
    80002c1a:	02fa2c23          	sw	a5,56(s4)
        goto end;
    80002c1e:	bd35                	j	80002a5a <usertrap+0x66>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c20:	14202973          	csrr	s2,scause
    80002c24:	14202573          	csrr	a0,scause
      printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80002c28:	00000097          	auipc	ra,0x0
    80002c2c:	b78080e7          	jalr	-1160(ra) # 800027a0 <scause_desc>
    80002c30:	862a                	mv	a2,a0
    80002c32:	0409a683          	lw	a3,64(s3)
    80002c36:	85ca                	mv	a1,s2
    80002c38:	00006517          	auipc	a0,0x6
    80002c3c:	a2050513          	addi	a0,a0,-1504 # 80008658 <userret+0x5c8>
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	96e080e7          	jalr	-1682(ra) # 800005ae <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c48:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c4c:	14302673          	csrr	a2,stval
      printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c50:	00006517          	auipc	a0,0x6
    80002c54:	a3850513          	addi	a0,a0,-1480 # 80008688 <userret+0x5f8>
    80002c58:	ffffe097          	auipc	ra,0xffffe
    80002c5c:	956080e7          	jalr	-1706(ra) # 800005ae <printf>
      p->killed = 1;
    80002c60:	4785                	li	a5,1
    80002c62:	02f9ac23          	sw	a5,56(s3)
  if(p->killed)
    80002c66:	a031                	j	80002c72 <usertrap+0x27e>
    80002c68:	0389a783          	lw	a5,56(s3)
    80002c6c:	cb81                	beqz	a5,80002c7c <usertrap+0x288>
    80002c6e:	a011                	j	80002c72 <usertrap+0x27e>
    80002c70:	4481                	li	s1,0
    exit(-1);
    80002c72:	557d                	li	a0,-1
    80002c74:	fffff097          	auipc	ra,0xfffff
    80002c78:	4fc080e7          	jalr	1276(ra) # 80002170 <exit>
  if(which_dev == 2)
    80002c7c:	4789                	li	a5,2
    80002c7e:	def492e3          	bne	s1,a5,80002a62 <usertrap+0x6e>
    yield();
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	6aa080e7          	jalr	1706(ra) # 8000232c <yield>
    80002c8a:	bbe1                	j	80002a62 <usertrap+0x6e>
        printf("usertrap(): not find vma \n");
    80002c8c:	00006517          	auipc	a0,0x6
    80002c90:	a1c50513          	addi	a0,a0,-1508 # 800086a8 <userret+0x618>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	91a080e7          	jalr	-1766(ra) # 800005ae <printf>
        p->killed = 1;
    80002c9c:	4785                	li	a5,1
    80002c9e:	02fa2c23          	sw	a5,56(s4)
        goto end;
    80002ca2:	bb65                	j	80002a5a <usertrap+0x66>

0000000080002ca4 <kerneltrap>:
{
    80002ca4:	7179                	addi	sp,sp,-48
    80002ca6:	f406                	sd	ra,40(sp)
    80002ca8:	f022                	sd	s0,32(sp)
    80002caa:	ec26                	sd	s1,24(sp)
    80002cac:	e84a                	sd	s2,16(sp)
    80002cae:	e44e                	sd	s3,8(sp)
    80002cb0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cb2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cb6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cba:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002cbe:	1004f793          	andi	a5,s1,256
    80002cc2:	cb85                	beqz	a5,80002cf2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cc4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cc8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002cca:	ef85                	bnez	a5,80002d02 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002ccc:	00000097          	auipc	ra,0x0
    80002cd0:	c92080e7          	jalr	-878(ra) # 8000295e <devintr>
    80002cd4:	cd1d                	beqz	a0,80002d12 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cd6:	4789                	li	a5,2
    80002cd8:	08f50063          	beq	a0,a5,80002d58 <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cdc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ce0:	10049073          	csrw	sstatus,s1
}
    80002ce4:	70a2                	ld	ra,40(sp)
    80002ce6:	7402                	ld	s0,32(sp)
    80002ce8:	64e2                	ld	s1,24(sp)
    80002cea:	6942                	ld	s2,16(sp)
    80002cec:	69a2                	ld	s3,8(sp)
    80002cee:	6145                	addi	sp,sp,48
    80002cf0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cf2:	00006517          	auipc	a0,0x6
    80002cf6:	9d650513          	addi	a0,a0,-1578 # 800086c8 <userret+0x638>
    80002cfa:	ffffe097          	auipc	ra,0xffffe
    80002cfe:	85a080e7          	jalr	-1958(ra) # 80000554 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d02:	00006517          	auipc	a0,0x6
    80002d06:	9ee50513          	addi	a0,a0,-1554 # 800086f0 <userret+0x660>
    80002d0a:	ffffe097          	auipc	ra,0xffffe
    80002d0e:	84a080e7          	jalr	-1974(ra) # 80000554 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002d12:	854e                	mv	a0,s3
    80002d14:	00000097          	auipc	ra,0x0
    80002d18:	a8c080e7          	jalr	-1396(ra) # 800027a0 <scause_desc>
    80002d1c:	862a                	mv	a2,a0
    80002d1e:	85ce                	mv	a1,s3
    80002d20:	00006517          	auipc	a0,0x6
    80002d24:	9f050513          	addi	a0,a0,-1552 # 80008710 <userret+0x680>
    80002d28:	ffffe097          	auipc	ra,0xffffe
    80002d2c:	886080e7          	jalr	-1914(ra) # 800005ae <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d30:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d34:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d38:	00006517          	auipc	a0,0x6
    80002d3c:	9e850513          	addi	a0,a0,-1560 # 80008720 <userret+0x690>
    80002d40:	ffffe097          	auipc	ra,0xffffe
    80002d44:	86e080e7          	jalr	-1938(ra) # 800005ae <printf>
    panic("kerneltrap");
    80002d48:	00006517          	auipc	a0,0x6
    80002d4c:	9f050513          	addi	a0,a0,-1552 # 80008738 <userret+0x6a8>
    80002d50:	ffffe097          	auipc	ra,0xffffe
    80002d54:	804080e7          	jalr	-2044(ra) # 80000554 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	d06080e7          	jalr	-762(ra) # 80001a5e <myproc>
    80002d60:	dd35                	beqz	a0,80002cdc <kerneltrap+0x38>
    80002d62:	fffff097          	auipc	ra,0xfffff
    80002d66:	cfc080e7          	jalr	-772(ra) # 80001a5e <myproc>
    80002d6a:	5118                	lw	a4,32(a0)
    80002d6c:	478d                	li	a5,3
    80002d6e:	f6f717e3          	bne	a4,a5,80002cdc <kerneltrap+0x38>
    yield();
    80002d72:	fffff097          	auipc	ra,0xfffff
    80002d76:	5ba080e7          	jalr	1466(ra) # 8000232c <yield>
    80002d7a:	b78d                	j	80002cdc <kerneltrap+0x38>

0000000080002d7c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d7c:	1101                	addi	sp,sp,-32
    80002d7e:	ec06                	sd	ra,24(sp)
    80002d80:	e822                	sd	s0,16(sp)
    80002d82:	e426                	sd	s1,8(sp)
    80002d84:	1000                	addi	s0,sp,32
    80002d86:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	cd6080e7          	jalr	-810(ra) # 80001a5e <myproc>
  switch (n) {
    80002d90:	4795                	li	a5,5
    80002d92:	0497e163          	bltu	a5,s1,80002dd4 <argraw+0x58>
    80002d96:	048a                	slli	s1,s1,0x2
    80002d98:	00006717          	auipc	a4,0x6
    80002d9c:	26870713          	addi	a4,a4,616 # 80009000 <nointr_desc.0+0x80>
    80002da0:	94ba                	add	s1,s1,a4
    80002da2:	409c                	lw	a5,0(s1)
    80002da4:	97ba                	add	a5,a5,a4
    80002da6:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002da8:	713c                	ld	a5,96(a0)
    80002daa:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002dac:	60e2                	ld	ra,24(sp)
    80002dae:	6442                	ld	s0,16(sp)
    80002db0:	64a2                	ld	s1,8(sp)
    80002db2:	6105                	addi	sp,sp,32
    80002db4:	8082                	ret
    return p->tf->a1;
    80002db6:	713c                	ld	a5,96(a0)
    80002db8:	7fa8                	ld	a0,120(a5)
    80002dba:	bfcd                	j	80002dac <argraw+0x30>
    return p->tf->a2;
    80002dbc:	713c                	ld	a5,96(a0)
    80002dbe:	63c8                	ld	a0,128(a5)
    80002dc0:	b7f5                	j	80002dac <argraw+0x30>
    return p->tf->a3;
    80002dc2:	713c                	ld	a5,96(a0)
    80002dc4:	67c8                	ld	a0,136(a5)
    80002dc6:	b7dd                	j	80002dac <argraw+0x30>
    return p->tf->a4;
    80002dc8:	713c                	ld	a5,96(a0)
    80002dca:	6bc8                	ld	a0,144(a5)
    80002dcc:	b7c5                	j	80002dac <argraw+0x30>
    return p->tf->a5;
    80002dce:	713c                	ld	a5,96(a0)
    80002dd0:	6fc8                	ld	a0,152(a5)
    80002dd2:	bfe9                	j	80002dac <argraw+0x30>
  panic("argraw");
    80002dd4:	00006517          	auipc	a0,0x6
    80002dd8:	b6c50513          	addi	a0,a0,-1172 # 80008940 <userret+0x8b0>
    80002ddc:	ffffd097          	auipc	ra,0xffffd
    80002de0:	778080e7          	jalr	1912(ra) # 80000554 <panic>

0000000080002de4 <fetchaddr>:
{
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	e426                	sd	s1,8(sp)
    80002dec:	e04a                	sd	s2,0(sp)
    80002dee:	1000                	addi	s0,sp,32
    80002df0:	84aa                	mv	s1,a0
    80002df2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002df4:	fffff097          	auipc	ra,0xfffff
    80002df8:	c6a080e7          	jalr	-918(ra) # 80001a5e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002dfc:	693c                	ld	a5,80(a0)
    80002dfe:	02f4f863          	bgeu	s1,a5,80002e2e <fetchaddr+0x4a>
    80002e02:	00848713          	addi	a4,s1,8
    80002e06:	02e7e663          	bltu	a5,a4,80002e32 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e0a:	46a1                	li	a3,8
    80002e0c:	8626                	mv	a2,s1
    80002e0e:	85ca                	mv	a1,s2
    80002e10:	6d28                	ld	a0,88(a0)
    80002e12:	fffff097          	auipc	ra,0xfffff
    80002e16:	9c4080e7          	jalr	-1596(ra) # 800017d6 <copyin>
    80002e1a:	00a03533          	snez	a0,a0
    80002e1e:	40a00533          	neg	a0,a0
}
    80002e22:	60e2                	ld	ra,24(sp)
    80002e24:	6442                	ld	s0,16(sp)
    80002e26:	64a2                	ld	s1,8(sp)
    80002e28:	6902                	ld	s2,0(sp)
    80002e2a:	6105                	addi	sp,sp,32
    80002e2c:	8082                	ret
    return -1;
    80002e2e:	557d                	li	a0,-1
    80002e30:	bfcd                	j	80002e22 <fetchaddr+0x3e>
    80002e32:	557d                	li	a0,-1
    80002e34:	b7fd                	j	80002e22 <fetchaddr+0x3e>

0000000080002e36 <fetchstr>:
{
    80002e36:	7179                	addi	sp,sp,-48
    80002e38:	f406                	sd	ra,40(sp)
    80002e3a:	f022                	sd	s0,32(sp)
    80002e3c:	ec26                	sd	s1,24(sp)
    80002e3e:	e84a                	sd	s2,16(sp)
    80002e40:	e44e                	sd	s3,8(sp)
    80002e42:	1800                	addi	s0,sp,48
    80002e44:	892a                	mv	s2,a0
    80002e46:	84ae                	mv	s1,a1
    80002e48:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e4a:	fffff097          	auipc	ra,0xfffff
    80002e4e:	c14080e7          	jalr	-1004(ra) # 80001a5e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002e52:	86ce                	mv	a3,s3
    80002e54:	864a                	mv	a2,s2
    80002e56:	85a6                	mv	a1,s1
    80002e58:	6d28                	ld	a0,88(a0)
    80002e5a:	fffff097          	auipc	ra,0xfffff
    80002e5e:	a0a080e7          	jalr	-1526(ra) # 80001864 <copyinstr>
  if(err < 0)
    80002e62:	00054763          	bltz	a0,80002e70 <fetchstr+0x3a>
  return strlen(buf);
    80002e66:	8526                	mv	a0,s1
    80002e68:	ffffe097          	auipc	ra,0xffffe
    80002e6c:	08a080e7          	jalr	138(ra) # 80000ef2 <strlen>
}
    80002e70:	70a2                	ld	ra,40(sp)
    80002e72:	7402                	ld	s0,32(sp)
    80002e74:	64e2                	ld	s1,24(sp)
    80002e76:	6942                	ld	s2,16(sp)
    80002e78:	69a2                	ld	s3,8(sp)
    80002e7a:	6145                	addi	sp,sp,48
    80002e7c:	8082                	ret

0000000080002e7e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e7e:	1101                	addi	sp,sp,-32
    80002e80:	ec06                	sd	ra,24(sp)
    80002e82:	e822                	sd	s0,16(sp)
    80002e84:	e426                	sd	s1,8(sp)
    80002e86:	1000                	addi	s0,sp,32
    80002e88:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e8a:	00000097          	auipc	ra,0x0
    80002e8e:	ef2080e7          	jalr	-270(ra) # 80002d7c <argraw>
    80002e92:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e94:	4501                	li	a0,0
    80002e96:	60e2                	ld	ra,24(sp)
    80002e98:	6442                	ld	s0,16(sp)
    80002e9a:	64a2                	ld	s1,8(sp)
    80002e9c:	6105                	addi	sp,sp,32
    80002e9e:	8082                	ret

0000000080002ea0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002ea0:	1101                	addi	sp,sp,-32
    80002ea2:	ec06                	sd	ra,24(sp)
    80002ea4:	e822                	sd	s0,16(sp)
    80002ea6:	e426                	sd	s1,8(sp)
    80002ea8:	1000                	addi	s0,sp,32
    80002eaa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eac:	00000097          	auipc	ra,0x0
    80002eb0:	ed0080e7          	jalr	-304(ra) # 80002d7c <argraw>
    80002eb4:	e088                	sd	a0,0(s1)
  return 0;
}
    80002eb6:	4501                	li	a0,0
    80002eb8:	60e2                	ld	ra,24(sp)
    80002eba:	6442                	ld	s0,16(sp)
    80002ebc:	64a2                	ld	s1,8(sp)
    80002ebe:	6105                	addi	sp,sp,32
    80002ec0:	8082                	ret

0000000080002ec2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ec2:	1101                	addi	sp,sp,-32
    80002ec4:	ec06                	sd	ra,24(sp)
    80002ec6:	e822                	sd	s0,16(sp)
    80002ec8:	e426                	sd	s1,8(sp)
    80002eca:	e04a                	sd	s2,0(sp)
    80002ecc:	1000                	addi	s0,sp,32
    80002ece:	84ae                	mv	s1,a1
    80002ed0:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002ed2:	00000097          	auipc	ra,0x0
    80002ed6:	eaa080e7          	jalr	-342(ra) # 80002d7c <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002eda:	864a                	mv	a2,s2
    80002edc:	85a6                	mv	a1,s1
    80002ede:	00000097          	auipc	ra,0x0
    80002ee2:	f58080e7          	jalr	-168(ra) # 80002e36 <fetchstr>
}
    80002ee6:	60e2                	ld	ra,24(sp)
    80002ee8:	6442                	ld	s0,16(sp)
    80002eea:	64a2                	ld	s1,8(sp)
    80002eec:	6902                	ld	s2,0(sp)
    80002eee:	6105                	addi	sp,sp,32
    80002ef0:	8082                	ret

0000000080002ef2 <syscall>:
[SYS_munmap]  sys_munmap
};

void
syscall(void)
{
    80002ef2:	1101                	addi	sp,sp,-32
    80002ef4:	ec06                	sd	ra,24(sp)
    80002ef6:	e822                	sd	s0,16(sp)
    80002ef8:	e426                	sd	s1,8(sp)
    80002efa:	e04a                	sd	s2,0(sp)
    80002efc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002efe:	fffff097          	auipc	ra,0xfffff
    80002f02:	b60080e7          	jalr	-1184(ra) # 80001a5e <myproc>
    80002f06:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002f08:	06053903          	ld	s2,96(a0)
    80002f0c:	0a893783          	ld	a5,168(s2)
    80002f10:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f14:	37fd                	addiw	a5,a5,-1
    80002f16:	4759                	li	a4,22
    80002f18:	00f76f63          	bltu	a4,a5,80002f36 <syscall+0x44>
    80002f1c:	00369713          	slli	a4,a3,0x3
    80002f20:	00006797          	auipc	a5,0x6
    80002f24:	0f878793          	addi	a5,a5,248 # 80009018 <syscalls>
    80002f28:	97ba                	add	a5,a5,a4
    80002f2a:	639c                	ld	a5,0(a5)
    80002f2c:	c789                	beqz	a5,80002f36 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002f2e:	9782                	jalr	a5
    80002f30:	06a93823          	sd	a0,112(s2)
    80002f34:	a839                	j	80002f52 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f36:	16048613          	addi	a2,s1,352
    80002f3a:	40ac                	lw	a1,64(s1)
    80002f3c:	00006517          	auipc	a0,0x6
    80002f40:	a0c50513          	addi	a0,a0,-1524 # 80008948 <userret+0x8b8>
    80002f44:	ffffd097          	auipc	ra,0xffffd
    80002f48:	66a080e7          	jalr	1642(ra) # 800005ae <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002f4c:	70bc                	ld	a5,96(s1)
    80002f4e:	577d                	li	a4,-1
    80002f50:	fbb8                	sd	a4,112(a5)
  }
}
    80002f52:	60e2                	ld	ra,24(sp)
    80002f54:	6442                	ld	s0,16(sp)
    80002f56:	64a2                	ld	s1,8(sp)
    80002f58:	6902                	ld	s2,0(sp)
    80002f5a:	6105                	addi	sp,sp,32
    80002f5c:	8082                	ret

0000000080002f5e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f5e:	1101                	addi	sp,sp,-32
    80002f60:	ec06                	sd	ra,24(sp)
    80002f62:	e822                	sd	s0,16(sp)
    80002f64:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f66:	fec40593          	addi	a1,s0,-20
    80002f6a:	4501                	li	a0,0
    80002f6c:	00000097          	auipc	ra,0x0
    80002f70:	f12080e7          	jalr	-238(ra) # 80002e7e <argint>
    return -1;
    80002f74:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f76:	00054963          	bltz	a0,80002f88 <sys_exit+0x2a>
  exit(n);
    80002f7a:	fec42503          	lw	a0,-20(s0)
    80002f7e:	fffff097          	auipc	ra,0xfffff
    80002f82:	1f2080e7          	jalr	498(ra) # 80002170 <exit>
  return 0;  // not reached
    80002f86:	4781                	li	a5,0
}
    80002f88:	853e                	mv	a0,a5
    80002f8a:	60e2                	ld	ra,24(sp)
    80002f8c:	6442                	ld	s0,16(sp)
    80002f8e:	6105                	addi	sp,sp,32
    80002f90:	8082                	ret

0000000080002f92 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f92:	1141                	addi	sp,sp,-16
    80002f94:	e406                	sd	ra,8(sp)
    80002f96:	e022                	sd	s0,0(sp)
    80002f98:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f9a:	fffff097          	auipc	ra,0xfffff
    80002f9e:	ac4080e7          	jalr	-1340(ra) # 80001a5e <myproc>
}
    80002fa2:	4128                	lw	a0,64(a0)
    80002fa4:	60a2                	ld	ra,8(sp)
    80002fa6:	6402                	ld	s0,0(sp)
    80002fa8:	0141                	addi	sp,sp,16
    80002faa:	8082                	ret

0000000080002fac <sys_fork>:

uint64
sys_fork(void)
{
    80002fac:	1141                	addi	sp,sp,-16
    80002fae:	e406                	sd	ra,8(sp)
    80002fb0:	e022                	sd	s0,0(sp)
    80002fb2:	0800                	addi	s0,sp,16
  return fork();
    80002fb4:	fffff097          	auipc	ra,0xfffff
    80002fb8:	e46080e7          	jalr	-442(ra) # 80001dfa <fork>
}
    80002fbc:	60a2                	ld	ra,8(sp)
    80002fbe:	6402                	ld	s0,0(sp)
    80002fc0:	0141                	addi	sp,sp,16
    80002fc2:	8082                	ret

0000000080002fc4 <sys_wait>:

uint64
sys_wait(void)
{
    80002fc4:	1101                	addi	sp,sp,-32
    80002fc6:	ec06                	sd	ra,24(sp)
    80002fc8:	e822                	sd	s0,16(sp)
    80002fca:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002fcc:	fe840593          	addi	a1,s0,-24
    80002fd0:	4501                	li	a0,0
    80002fd2:	00000097          	auipc	ra,0x0
    80002fd6:	ece080e7          	jalr	-306(ra) # 80002ea0 <argaddr>
    80002fda:	87aa                	mv	a5,a0
    return -1;
    80002fdc:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002fde:	0007c863          	bltz	a5,80002fee <sys_wait+0x2a>
  return wait(p);
    80002fe2:	fe843503          	ld	a0,-24(s0)
    80002fe6:	fffff097          	auipc	ra,0xfffff
    80002fea:	400080e7          	jalr	1024(ra) # 800023e6 <wait>
}
    80002fee:	60e2                	ld	ra,24(sp)
    80002ff0:	6442                	ld	s0,16(sp)
    80002ff2:	6105                	addi	sp,sp,32
    80002ff4:	8082                	ret

0000000080002ff6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ff6:	7179                	addi	sp,sp,-48
    80002ff8:	f406                	sd	ra,40(sp)
    80002ffa:	f022                	sd	s0,32(sp)
    80002ffc:	ec26                	sd	s1,24(sp)
    80002ffe:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003000:	fdc40593          	addi	a1,s0,-36
    80003004:	4501                	li	a0,0
    80003006:	00000097          	auipc	ra,0x0
    8000300a:	e78080e7          	jalr	-392(ra) # 80002e7e <argint>
    return -1;
    8000300e:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003010:	00054f63          	bltz	a0,8000302e <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	a4a080e7          	jalr	-1462(ra) # 80001a5e <myproc>
    8000301c:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    8000301e:	fdc42503          	lw	a0,-36(s0)
    80003022:	fffff097          	auipc	ra,0xfffff
    80003026:	d64080e7          	jalr	-668(ra) # 80001d86 <growproc>
    8000302a:	00054863          	bltz	a0,8000303a <sys_sbrk+0x44>
    return -1;
  return addr;
}
    8000302e:	8526                	mv	a0,s1
    80003030:	70a2                	ld	ra,40(sp)
    80003032:	7402                	ld	s0,32(sp)
    80003034:	64e2                	ld	s1,24(sp)
    80003036:	6145                	addi	sp,sp,48
    80003038:	8082                	ret
    return -1;
    8000303a:	54fd                	li	s1,-1
    8000303c:	bfcd                	j	8000302e <sys_sbrk+0x38>

000000008000303e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000303e:	7139                	addi	sp,sp,-64
    80003040:	fc06                	sd	ra,56(sp)
    80003042:	f822                	sd	s0,48(sp)
    80003044:	f426                	sd	s1,40(sp)
    80003046:	f04a                	sd	s2,32(sp)
    80003048:	ec4e                	sd	s3,24(sp)
    8000304a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000304c:	fcc40593          	addi	a1,s0,-52
    80003050:	4501                	li	a0,0
    80003052:	00000097          	auipc	ra,0x0
    80003056:	e2c080e7          	jalr	-468(ra) # 80002e7e <argint>
    return -1;
    8000305a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000305c:	06054563          	bltz	a0,800030c6 <sys_sleep+0x88>
  acquire(&tickslock);
    80003060:	0001f517          	auipc	a0,0x1f
    80003064:	68050513          	addi	a0,a0,1664 # 800226e0 <tickslock>
    80003068:	ffffe097          	auipc	ra,0xffffe
    8000306c:	a38080e7          	jalr	-1480(ra) # 80000aa0 <acquire>
  ticks0 = ticks;
    80003070:	00031917          	auipc	s2,0x31
    80003074:	fd092903          	lw	s2,-48(s2) # 80034040 <ticks>
  while(ticks - ticks0 < n){
    80003078:	fcc42783          	lw	a5,-52(s0)
    8000307c:	cf85                	beqz	a5,800030b4 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000307e:	0001f997          	auipc	s3,0x1f
    80003082:	66298993          	addi	s3,s3,1634 # 800226e0 <tickslock>
    80003086:	00031497          	auipc	s1,0x31
    8000308a:	fba48493          	addi	s1,s1,-70 # 80034040 <ticks>
    if(myproc()->killed){
    8000308e:	fffff097          	auipc	ra,0xfffff
    80003092:	9d0080e7          	jalr	-1584(ra) # 80001a5e <myproc>
    80003096:	5d1c                	lw	a5,56(a0)
    80003098:	ef9d                	bnez	a5,800030d6 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000309a:	85ce                	mv	a1,s3
    8000309c:	8526                	mv	a0,s1
    8000309e:	fffff097          	auipc	ra,0xfffff
    800030a2:	2ca080e7          	jalr	714(ra) # 80002368 <sleep>
  while(ticks - ticks0 < n){
    800030a6:	409c                	lw	a5,0(s1)
    800030a8:	412787bb          	subw	a5,a5,s2
    800030ac:	fcc42703          	lw	a4,-52(s0)
    800030b0:	fce7efe3          	bltu	a5,a4,8000308e <sys_sleep+0x50>
  }
  release(&tickslock);
    800030b4:	0001f517          	auipc	a0,0x1f
    800030b8:	62c50513          	addi	a0,a0,1580 # 800226e0 <tickslock>
    800030bc:	ffffe097          	auipc	ra,0xffffe
    800030c0:	ab4080e7          	jalr	-1356(ra) # 80000b70 <release>
  return 0;
    800030c4:	4781                	li	a5,0
}
    800030c6:	853e                	mv	a0,a5
    800030c8:	70e2                	ld	ra,56(sp)
    800030ca:	7442                	ld	s0,48(sp)
    800030cc:	74a2                	ld	s1,40(sp)
    800030ce:	7902                	ld	s2,32(sp)
    800030d0:	69e2                	ld	s3,24(sp)
    800030d2:	6121                	addi	sp,sp,64
    800030d4:	8082                	ret
      release(&tickslock);
    800030d6:	0001f517          	auipc	a0,0x1f
    800030da:	60a50513          	addi	a0,a0,1546 # 800226e0 <tickslock>
    800030de:	ffffe097          	auipc	ra,0xffffe
    800030e2:	a92080e7          	jalr	-1390(ra) # 80000b70 <release>
      return -1;
    800030e6:	57fd                	li	a5,-1
    800030e8:	bff9                	j	800030c6 <sys_sleep+0x88>

00000000800030ea <sys_kill>:

uint64
sys_kill(void)
{
    800030ea:	1101                	addi	sp,sp,-32
    800030ec:	ec06                	sd	ra,24(sp)
    800030ee:	e822                	sd	s0,16(sp)
    800030f0:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800030f2:	fec40593          	addi	a1,s0,-20
    800030f6:	4501                	li	a0,0
    800030f8:	00000097          	auipc	ra,0x0
    800030fc:	d86080e7          	jalr	-634(ra) # 80002e7e <argint>
    80003100:	87aa                	mv	a5,a0
    return -1;
    80003102:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003104:	0007c863          	bltz	a5,80003114 <sys_kill+0x2a>
  return kill(pid);
    80003108:	fec42503          	lw	a0,-20(s0)
    8000310c:	fffff097          	auipc	ra,0xfffff
    80003110:	450080e7          	jalr	1104(ra) # 8000255c <kill>
}
    80003114:	60e2                	ld	ra,24(sp)
    80003116:	6442                	ld	s0,16(sp)
    80003118:	6105                	addi	sp,sp,32
    8000311a:	8082                	ret

000000008000311c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000311c:	1101                	addi	sp,sp,-32
    8000311e:	ec06                	sd	ra,24(sp)
    80003120:	e822                	sd	s0,16(sp)
    80003122:	e426                	sd	s1,8(sp)
    80003124:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003126:	0001f517          	auipc	a0,0x1f
    8000312a:	5ba50513          	addi	a0,a0,1466 # 800226e0 <tickslock>
    8000312e:	ffffe097          	auipc	ra,0xffffe
    80003132:	972080e7          	jalr	-1678(ra) # 80000aa0 <acquire>
  xticks = ticks;
    80003136:	00031497          	auipc	s1,0x31
    8000313a:	f0a4a483          	lw	s1,-246(s1) # 80034040 <ticks>
  release(&tickslock);
    8000313e:	0001f517          	auipc	a0,0x1f
    80003142:	5a250513          	addi	a0,a0,1442 # 800226e0 <tickslock>
    80003146:	ffffe097          	auipc	ra,0xffffe
    8000314a:	a2a080e7          	jalr	-1494(ra) # 80000b70 <release>
  return xticks;
}
    8000314e:	02049513          	slli	a0,s1,0x20
    80003152:	9101                	srli	a0,a0,0x20
    80003154:	60e2                	ld	ra,24(sp)
    80003156:	6442                	ld	s0,16(sp)
    80003158:	64a2                	ld	s1,8(sp)
    8000315a:	6105                	addi	sp,sp,32
    8000315c:	8082                	ret

000000008000315e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000315e:	7179                	addi	sp,sp,-48
    80003160:	f406                	sd	ra,40(sp)
    80003162:	f022                	sd	s0,32(sp)
    80003164:	ec26                	sd	s1,24(sp)
    80003166:	e84a                	sd	s2,16(sp)
    80003168:	e44e                	sd	s3,8(sp)
    8000316a:	e052                	sd	s4,0(sp)
    8000316c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000316e:	00005597          	auipc	a1,0x5
    80003172:	14a58593          	addi	a1,a1,330 # 800082b8 <userret+0x228>
    80003176:	0001f517          	auipc	a0,0x1f
    8000317a:	58a50513          	addi	a0,a0,1418 # 80022700 <bcache>
    8000317e:	ffffe097          	auipc	ra,0xffffe
    80003182:	84e080e7          	jalr	-1970(ra) # 800009cc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003186:	00027797          	auipc	a5,0x27
    8000318a:	57a78793          	addi	a5,a5,1402 # 8002a700 <bcache+0x8000>
    8000318e:	00028717          	auipc	a4,0x28
    80003192:	8d270713          	addi	a4,a4,-1838 # 8002aa60 <bcache+0x8360>
    80003196:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    8000319a:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000319e:	0001f497          	auipc	s1,0x1f
    800031a2:	58248493          	addi	s1,s1,1410 # 80022720 <bcache+0x20>
    b->next = bcache.head.next;
    800031a6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800031a8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800031aa:	00005a17          	auipc	s4,0x5
    800031ae:	7bea0a13          	addi	s4,s4,1982 # 80008968 <userret+0x8d8>
    b->next = bcache.head.next;
    800031b2:	3b893783          	ld	a5,952(s2)
    800031b6:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    800031b8:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    800031bc:	85d2                	mv	a1,s4
    800031be:	01048513          	addi	a0,s1,16
    800031c2:	00001097          	auipc	ra,0x1
    800031c6:	5a0080e7          	jalr	1440(ra) # 80004762 <initsleeplock>
    bcache.head.next->prev = b;
    800031ca:	3b893783          	ld	a5,952(s2)
    800031ce:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    800031d0:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031d4:	46048493          	addi	s1,s1,1120
    800031d8:	fd349de3          	bne	s1,s3,800031b2 <binit+0x54>
  }
}
    800031dc:	70a2                	ld	ra,40(sp)
    800031de:	7402                	ld	s0,32(sp)
    800031e0:	64e2                	ld	s1,24(sp)
    800031e2:	6942                	ld	s2,16(sp)
    800031e4:	69a2                	ld	s3,8(sp)
    800031e6:	6a02                	ld	s4,0(sp)
    800031e8:	6145                	addi	sp,sp,48
    800031ea:	8082                	ret

00000000800031ec <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031ec:	7179                	addi	sp,sp,-48
    800031ee:	f406                	sd	ra,40(sp)
    800031f0:	f022                	sd	s0,32(sp)
    800031f2:	ec26                	sd	s1,24(sp)
    800031f4:	e84a                	sd	s2,16(sp)
    800031f6:	e44e                	sd	s3,8(sp)
    800031f8:	1800                	addi	s0,sp,48
    800031fa:	892a                	mv	s2,a0
    800031fc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031fe:	0001f517          	auipc	a0,0x1f
    80003202:	50250513          	addi	a0,a0,1282 # 80022700 <bcache>
    80003206:	ffffe097          	auipc	ra,0xffffe
    8000320a:	89a080e7          	jalr	-1894(ra) # 80000aa0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000320e:	00028497          	auipc	s1,0x28
    80003212:	8aa4b483          	ld	s1,-1878(s1) # 8002aab8 <bcache+0x83b8>
    80003216:	00028797          	auipc	a5,0x28
    8000321a:	84a78793          	addi	a5,a5,-1974 # 8002aa60 <bcache+0x8360>
    8000321e:	02f48f63          	beq	s1,a5,8000325c <bread+0x70>
    80003222:	873e                	mv	a4,a5
    80003224:	a021                	j	8000322c <bread+0x40>
    80003226:	6ca4                	ld	s1,88(s1)
    80003228:	02e48a63          	beq	s1,a4,8000325c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000322c:	449c                	lw	a5,8(s1)
    8000322e:	ff279ce3          	bne	a5,s2,80003226 <bread+0x3a>
    80003232:	44dc                	lw	a5,12(s1)
    80003234:	ff3799e3          	bne	a5,s3,80003226 <bread+0x3a>
      b->refcnt++;
    80003238:	44bc                	lw	a5,72(s1)
    8000323a:	2785                	addiw	a5,a5,1
    8000323c:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    8000323e:	0001f517          	auipc	a0,0x1f
    80003242:	4c250513          	addi	a0,a0,1218 # 80022700 <bcache>
    80003246:	ffffe097          	auipc	ra,0xffffe
    8000324a:	92a080e7          	jalr	-1750(ra) # 80000b70 <release>
      acquiresleep(&b->lock);
    8000324e:	01048513          	addi	a0,s1,16
    80003252:	00001097          	auipc	ra,0x1
    80003256:	54a080e7          	jalr	1354(ra) # 8000479c <acquiresleep>
      return b;
    8000325a:	a8b9                	j	800032b8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000325c:	00028497          	auipc	s1,0x28
    80003260:	8544b483          	ld	s1,-1964(s1) # 8002aab0 <bcache+0x83b0>
    80003264:	00027797          	auipc	a5,0x27
    80003268:	7fc78793          	addi	a5,a5,2044 # 8002aa60 <bcache+0x8360>
    8000326c:	00f48863          	beq	s1,a5,8000327c <bread+0x90>
    80003270:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003272:	44bc                	lw	a5,72(s1)
    80003274:	cf81                	beqz	a5,8000328c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003276:	68a4                	ld	s1,80(s1)
    80003278:	fee49de3          	bne	s1,a4,80003272 <bread+0x86>
  panic("bget: no buffers");
    8000327c:	00005517          	auipc	a0,0x5
    80003280:	6f450513          	addi	a0,a0,1780 # 80008970 <userret+0x8e0>
    80003284:	ffffd097          	auipc	ra,0xffffd
    80003288:	2d0080e7          	jalr	720(ra) # 80000554 <panic>
      b->dev = dev;
    8000328c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003290:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003294:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003298:	4785                	li	a5,1
    8000329a:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    8000329c:	0001f517          	auipc	a0,0x1f
    800032a0:	46450513          	addi	a0,a0,1124 # 80022700 <bcache>
    800032a4:	ffffe097          	auipc	ra,0xffffe
    800032a8:	8cc080e7          	jalr	-1844(ra) # 80000b70 <release>
      acquiresleep(&b->lock);
    800032ac:	01048513          	addi	a0,s1,16
    800032b0:	00001097          	auipc	ra,0x1
    800032b4:	4ec080e7          	jalr	1260(ra) # 8000479c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800032b8:	409c                	lw	a5,0(s1)
    800032ba:	cb89                	beqz	a5,800032cc <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    800032bc:	8526                	mv	a0,s1
    800032be:	70a2                	ld	ra,40(sp)
    800032c0:	7402                	ld	s0,32(sp)
    800032c2:	64e2                	ld	s1,24(sp)
    800032c4:	6942                	ld	s2,16(sp)
    800032c6:	69a2                	ld	s3,8(sp)
    800032c8:	6145                	addi	sp,sp,48
    800032ca:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    800032cc:	4601                	li	a2,0
    800032ce:	85a6                	mv	a1,s1
    800032d0:	4488                	lw	a0,8(s1)
    800032d2:	00003097          	auipc	ra,0x3
    800032d6:	478080e7          	jalr	1144(ra) # 8000674a <virtio_disk_rw>
    b->valid = 1;
    800032da:	4785                	li	a5,1
    800032dc:	c09c                	sw	a5,0(s1)
  return b;
    800032de:	bff9                	j	800032bc <bread+0xd0>

00000000800032e0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032e0:	1101                	addi	sp,sp,-32
    800032e2:	ec06                	sd	ra,24(sp)
    800032e4:	e822                	sd	s0,16(sp)
    800032e6:	e426                	sd	s1,8(sp)
    800032e8:	1000                	addi	s0,sp,32
    800032ea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032ec:	0541                	addi	a0,a0,16
    800032ee:	00001097          	auipc	ra,0x1
    800032f2:	548080e7          	jalr	1352(ra) # 80004836 <holdingsleep>
    800032f6:	cd09                	beqz	a0,80003310 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    800032f8:	4605                	li	a2,1
    800032fa:	85a6                	mv	a1,s1
    800032fc:	4488                	lw	a0,8(s1)
    800032fe:	00003097          	auipc	ra,0x3
    80003302:	44c080e7          	jalr	1100(ra) # 8000674a <virtio_disk_rw>
}
    80003306:	60e2                	ld	ra,24(sp)
    80003308:	6442                	ld	s0,16(sp)
    8000330a:	64a2                	ld	s1,8(sp)
    8000330c:	6105                	addi	sp,sp,32
    8000330e:	8082                	ret
    panic("bwrite");
    80003310:	00005517          	auipc	a0,0x5
    80003314:	67850513          	addi	a0,a0,1656 # 80008988 <userret+0x8f8>
    80003318:	ffffd097          	auipc	ra,0xffffd
    8000331c:	23c080e7          	jalr	572(ra) # 80000554 <panic>

0000000080003320 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80003320:	1101                	addi	sp,sp,-32
    80003322:	ec06                	sd	ra,24(sp)
    80003324:	e822                	sd	s0,16(sp)
    80003326:	e426                	sd	s1,8(sp)
    80003328:	e04a                	sd	s2,0(sp)
    8000332a:	1000                	addi	s0,sp,32
    8000332c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000332e:	01050913          	addi	s2,a0,16
    80003332:	854a                	mv	a0,s2
    80003334:	00001097          	auipc	ra,0x1
    80003338:	502080e7          	jalr	1282(ra) # 80004836 <holdingsleep>
    8000333c:	c92d                	beqz	a0,800033ae <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000333e:	854a                	mv	a0,s2
    80003340:	00001097          	auipc	ra,0x1
    80003344:	4b2080e7          	jalr	1202(ra) # 800047f2 <releasesleep>

  acquire(&bcache.lock);
    80003348:	0001f517          	auipc	a0,0x1f
    8000334c:	3b850513          	addi	a0,a0,952 # 80022700 <bcache>
    80003350:	ffffd097          	auipc	ra,0xffffd
    80003354:	750080e7          	jalr	1872(ra) # 80000aa0 <acquire>
  b->refcnt--;
    80003358:	44bc                	lw	a5,72(s1)
    8000335a:	37fd                	addiw	a5,a5,-1
    8000335c:	0007871b          	sext.w	a4,a5
    80003360:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    80003362:	eb05                	bnez	a4,80003392 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003364:	6cbc                	ld	a5,88(s1)
    80003366:	68b8                	ld	a4,80(s1)
    80003368:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    8000336a:	68bc                	ld	a5,80(s1)
    8000336c:	6cb8                	ld	a4,88(s1)
    8000336e:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    80003370:	00027797          	auipc	a5,0x27
    80003374:	39078793          	addi	a5,a5,912 # 8002a700 <bcache+0x8000>
    80003378:	3b87b703          	ld	a4,952(a5)
    8000337c:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    8000337e:	00027717          	auipc	a4,0x27
    80003382:	6e270713          	addi	a4,a4,1762 # 8002aa60 <bcache+0x8360>
    80003386:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    80003388:	3b87b703          	ld	a4,952(a5)
    8000338c:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    8000338e:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    80003392:	0001f517          	auipc	a0,0x1f
    80003396:	36e50513          	addi	a0,a0,878 # 80022700 <bcache>
    8000339a:	ffffd097          	auipc	ra,0xffffd
    8000339e:	7d6080e7          	jalr	2006(ra) # 80000b70 <release>
}
    800033a2:	60e2                	ld	ra,24(sp)
    800033a4:	6442                	ld	s0,16(sp)
    800033a6:	64a2                	ld	s1,8(sp)
    800033a8:	6902                	ld	s2,0(sp)
    800033aa:	6105                	addi	sp,sp,32
    800033ac:	8082                	ret
    panic("brelse");
    800033ae:	00005517          	auipc	a0,0x5
    800033b2:	5e250513          	addi	a0,a0,1506 # 80008990 <userret+0x900>
    800033b6:	ffffd097          	auipc	ra,0xffffd
    800033ba:	19e080e7          	jalr	414(ra) # 80000554 <panic>

00000000800033be <bpin>:

void
bpin(struct buf *b) {
    800033be:	1101                	addi	sp,sp,-32
    800033c0:	ec06                	sd	ra,24(sp)
    800033c2:	e822                	sd	s0,16(sp)
    800033c4:	e426                	sd	s1,8(sp)
    800033c6:	1000                	addi	s0,sp,32
    800033c8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033ca:	0001f517          	auipc	a0,0x1f
    800033ce:	33650513          	addi	a0,a0,822 # 80022700 <bcache>
    800033d2:	ffffd097          	auipc	ra,0xffffd
    800033d6:	6ce080e7          	jalr	1742(ra) # 80000aa0 <acquire>
  b->refcnt++;
    800033da:	44bc                	lw	a5,72(s1)
    800033dc:	2785                	addiw	a5,a5,1
    800033de:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    800033e0:	0001f517          	auipc	a0,0x1f
    800033e4:	32050513          	addi	a0,a0,800 # 80022700 <bcache>
    800033e8:	ffffd097          	auipc	ra,0xffffd
    800033ec:	788080e7          	jalr	1928(ra) # 80000b70 <release>
}
    800033f0:	60e2                	ld	ra,24(sp)
    800033f2:	6442                	ld	s0,16(sp)
    800033f4:	64a2                	ld	s1,8(sp)
    800033f6:	6105                	addi	sp,sp,32
    800033f8:	8082                	ret

00000000800033fa <bunpin>:

void
bunpin(struct buf *b) {
    800033fa:	1101                	addi	sp,sp,-32
    800033fc:	ec06                	sd	ra,24(sp)
    800033fe:	e822                	sd	s0,16(sp)
    80003400:	e426                	sd	s1,8(sp)
    80003402:	1000                	addi	s0,sp,32
    80003404:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003406:	0001f517          	auipc	a0,0x1f
    8000340a:	2fa50513          	addi	a0,a0,762 # 80022700 <bcache>
    8000340e:	ffffd097          	auipc	ra,0xffffd
    80003412:	692080e7          	jalr	1682(ra) # 80000aa0 <acquire>
  b->refcnt--;
    80003416:	44bc                	lw	a5,72(s1)
    80003418:	37fd                	addiw	a5,a5,-1
    8000341a:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    8000341c:	0001f517          	auipc	a0,0x1f
    80003420:	2e450513          	addi	a0,a0,740 # 80022700 <bcache>
    80003424:	ffffd097          	auipc	ra,0xffffd
    80003428:	74c080e7          	jalr	1868(ra) # 80000b70 <release>
}
    8000342c:	60e2                	ld	ra,24(sp)
    8000342e:	6442                	ld	s0,16(sp)
    80003430:	64a2                	ld	s1,8(sp)
    80003432:	6105                	addi	sp,sp,32
    80003434:	8082                	ret

0000000080003436 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003436:	1101                	addi	sp,sp,-32
    80003438:	ec06                	sd	ra,24(sp)
    8000343a:	e822                	sd	s0,16(sp)
    8000343c:	e426                	sd	s1,8(sp)
    8000343e:	e04a                	sd	s2,0(sp)
    80003440:	1000                	addi	s0,sp,32
    80003442:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003444:	00d5d59b          	srliw	a1,a1,0xd
    80003448:	00028797          	auipc	a5,0x28
    8000344c:	a947a783          	lw	a5,-1388(a5) # 8002aedc <sb+0x1c>
    80003450:	9dbd                	addw	a1,a1,a5
    80003452:	00000097          	auipc	ra,0x0
    80003456:	d9a080e7          	jalr	-614(ra) # 800031ec <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000345a:	0074f713          	andi	a4,s1,7
    8000345e:	4785                	li	a5,1
    80003460:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003464:	14ce                	slli	s1,s1,0x33
    80003466:	90d9                	srli	s1,s1,0x36
    80003468:	00950733          	add	a4,a0,s1
    8000346c:	06074703          	lbu	a4,96(a4)
    80003470:	00e7f6b3          	and	a3,a5,a4
    80003474:	c69d                	beqz	a3,800034a2 <bfree+0x6c>
    80003476:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003478:	94aa                	add	s1,s1,a0
    8000347a:	fff7c793          	not	a5,a5
    8000347e:	8ff9                	and	a5,a5,a4
    80003480:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80003484:	00001097          	auipc	ra,0x1
    80003488:	19e080e7          	jalr	414(ra) # 80004622 <log_write>
  brelse(bp);
    8000348c:	854a                	mv	a0,s2
    8000348e:	00000097          	auipc	ra,0x0
    80003492:	e92080e7          	jalr	-366(ra) # 80003320 <brelse>
}
    80003496:	60e2                	ld	ra,24(sp)
    80003498:	6442                	ld	s0,16(sp)
    8000349a:	64a2                	ld	s1,8(sp)
    8000349c:	6902                	ld	s2,0(sp)
    8000349e:	6105                	addi	sp,sp,32
    800034a0:	8082                	ret
    panic("freeing free block");
    800034a2:	00005517          	auipc	a0,0x5
    800034a6:	4f650513          	addi	a0,a0,1270 # 80008998 <userret+0x908>
    800034aa:	ffffd097          	auipc	ra,0xffffd
    800034ae:	0aa080e7          	jalr	170(ra) # 80000554 <panic>

00000000800034b2 <balloc>:
{
    800034b2:	711d                	addi	sp,sp,-96
    800034b4:	ec86                	sd	ra,88(sp)
    800034b6:	e8a2                	sd	s0,80(sp)
    800034b8:	e4a6                	sd	s1,72(sp)
    800034ba:	e0ca                	sd	s2,64(sp)
    800034bc:	fc4e                	sd	s3,56(sp)
    800034be:	f852                	sd	s4,48(sp)
    800034c0:	f456                	sd	s5,40(sp)
    800034c2:	f05a                	sd	s6,32(sp)
    800034c4:	ec5e                	sd	s7,24(sp)
    800034c6:	e862                	sd	s8,16(sp)
    800034c8:	e466                	sd	s9,8(sp)
    800034ca:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034cc:	00028797          	auipc	a5,0x28
    800034d0:	9f87a783          	lw	a5,-1544(a5) # 8002aec4 <sb+0x4>
    800034d4:	cbd1                	beqz	a5,80003568 <balloc+0xb6>
    800034d6:	8baa                	mv	s7,a0
    800034d8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034da:	00028b17          	auipc	s6,0x28
    800034de:	9e6b0b13          	addi	s6,s6,-1562 # 8002aec0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034e2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034e4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034e6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034e8:	6c89                	lui	s9,0x2
    800034ea:	a831                	j	80003506 <balloc+0x54>
    brelse(bp);
    800034ec:	854a                	mv	a0,s2
    800034ee:	00000097          	auipc	ra,0x0
    800034f2:	e32080e7          	jalr	-462(ra) # 80003320 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034f6:	015c87bb          	addw	a5,s9,s5
    800034fa:	00078a9b          	sext.w	s5,a5
    800034fe:	004b2703          	lw	a4,4(s6)
    80003502:	06eaf363          	bgeu	s5,a4,80003568 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003506:	41fad79b          	sraiw	a5,s5,0x1f
    8000350a:	0137d79b          	srliw	a5,a5,0x13
    8000350e:	015787bb          	addw	a5,a5,s5
    80003512:	40d7d79b          	sraiw	a5,a5,0xd
    80003516:	01cb2583          	lw	a1,28(s6)
    8000351a:	9dbd                	addw	a1,a1,a5
    8000351c:	855e                	mv	a0,s7
    8000351e:	00000097          	auipc	ra,0x0
    80003522:	cce080e7          	jalr	-818(ra) # 800031ec <bread>
    80003526:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003528:	004b2503          	lw	a0,4(s6)
    8000352c:	000a849b          	sext.w	s1,s5
    80003530:	8662                	mv	a2,s8
    80003532:	faa4fde3          	bgeu	s1,a0,800034ec <balloc+0x3a>
      m = 1 << (bi % 8);
    80003536:	41f6579b          	sraiw	a5,a2,0x1f
    8000353a:	01d7d69b          	srliw	a3,a5,0x1d
    8000353e:	00c6873b          	addw	a4,a3,a2
    80003542:	00777793          	andi	a5,a4,7
    80003546:	9f95                	subw	a5,a5,a3
    80003548:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000354c:	4037571b          	sraiw	a4,a4,0x3
    80003550:	00e906b3          	add	a3,s2,a4
    80003554:	0606c683          	lbu	a3,96(a3)
    80003558:	00d7f5b3          	and	a1,a5,a3
    8000355c:	cd91                	beqz	a1,80003578 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000355e:	2605                	addiw	a2,a2,1
    80003560:	2485                	addiw	s1,s1,1
    80003562:	fd4618e3          	bne	a2,s4,80003532 <balloc+0x80>
    80003566:	b759                	j	800034ec <balloc+0x3a>
  panic("balloc: out of blocks");
    80003568:	00005517          	auipc	a0,0x5
    8000356c:	44850513          	addi	a0,a0,1096 # 800089b0 <userret+0x920>
    80003570:	ffffd097          	auipc	ra,0xffffd
    80003574:	fe4080e7          	jalr	-28(ra) # 80000554 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003578:	974a                	add	a4,a4,s2
    8000357a:	8fd5                	or	a5,a5,a3
    8000357c:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    80003580:	854a                	mv	a0,s2
    80003582:	00001097          	auipc	ra,0x1
    80003586:	0a0080e7          	jalr	160(ra) # 80004622 <log_write>
        brelse(bp);
    8000358a:	854a                	mv	a0,s2
    8000358c:	00000097          	auipc	ra,0x0
    80003590:	d94080e7          	jalr	-620(ra) # 80003320 <brelse>
  bp = bread(dev, bno);
    80003594:	85a6                	mv	a1,s1
    80003596:	855e                	mv	a0,s7
    80003598:	00000097          	auipc	ra,0x0
    8000359c:	c54080e7          	jalr	-940(ra) # 800031ec <bread>
    800035a0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800035a2:	40000613          	li	a2,1024
    800035a6:	4581                	li	a1,0
    800035a8:	06050513          	addi	a0,a0,96
    800035ac:	ffffd097          	auipc	ra,0xffffd
    800035b0:	7c2080e7          	jalr	1986(ra) # 80000d6e <memset>
  log_write(bp);
    800035b4:	854a                	mv	a0,s2
    800035b6:	00001097          	auipc	ra,0x1
    800035ba:	06c080e7          	jalr	108(ra) # 80004622 <log_write>
  brelse(bp);
    800035be:	854a                	mv	a0,s2
    800035c0:	00000097          	auipc	ra,0x0
    800035c4:	d60080e7          	jalr	-672(ra) # 80003320 <brelse>
}
    800035c8:	8526                	mv	a0,s1
    800035ca:	60e6                	ld	ra,88(sp)
    800035cc:	6446                	ld	s0,80(sp)
    800035ce:	64a6                	ld	s1,72(sp)
    800035d0:	6906                	ld	s2,64(sp)
    800035d2:	79e2                	ld	s3,56(sp)
    800035d4:	7a42                	ld	s4,48(sp)
    800035d6:	7aa2                	ld	s5,40(sp)
    800035d8:	7b02                	ld	s6,32(sp)
    800035da:	6be2                	ld	s7,24(sp)
    800035dc:	6c42                	ld	s8,16(sp)
    800035de:	6ca2                	ld	s9,8(sp)
    800035e0:	6125                	addi	sp,sp,96
    800035e2:	8082                	ret

00000000800035e4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800035e4:	7179                	addi	sp,sp,-48
    800035e6:	f406                	sd	ra,40(sp)
    800035e8:	f022                	sd	s0,32(sp)
    800035ea:	ec26                	sd	s1,24(sp)
    800035ec:	e84a                	sd	s2,16(sp)
    800035ee:	e44e                	sd	s3,8(sp)
    800035f0:	e052                	sd	s4,0(sp)
    800035f2:	1800                	addi	s0,sp,48
    800035f4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035f6:	47ad                	li	a5,11
    800035f8:	04b7fe63          	bgeu	a5,a1,80003654 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800035fc:	ff45849b          	addiw	s1,a1,-12
    80003600:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003604:	0ff00793          	li	a5,255
    80003608:	0ae7e363          	bltu	a5,a4,800036ae <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000360c:	08852583          	lw	a1,136(a0)
    80003610:	c5ad                	beqz	a1,8000367a <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003612:	00092503          	lw	a0,0(s2)
    80003616:	00000097          	auipc	ra,0x0
    8000361a:	bd6080e7          	jalr	-1066(ra) # 800031ec <bread>
    8000361e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003620:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003624:	02049593          	slli	a1,s1,0x20
    80003628:	9181                	srli	a1,a1,0x20
    8000362a:	058a                	slli	a1,a1,0x2
    8000362c:	00b784b3          	add	s1,a5,a1
    80003630:	0004a983          	lw	s3,0(s1)
    80003634:	04098d63          	beqz	s3,8000368e <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003638:	8552                	mv	a0,s4
    8000363a:	00000097          	auipc	ra,0x0
    8000363e:	ce6080e7          	jalr	-794(ra) # 80003320 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003642:	854e                	mv	a0,s3
    80003644:	70a2                	ld	ra,40(sp)
    80003646:	7402                	ld	s0,32(sp)
    80003648:	64e2                	ld	s1,24(sp)
    8000364a:	6942                	ld	s2,16(sp)
    8000364c:	69a2                	ld	s3,8(sp)
    8000364e:	6a02                	ld	s4,0(sp)
    80003650:	6145                	addi	sp,sp,48
    80003652:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003654:	02059493          	slli	s1,a1,0x20
    80003658:	9081                	srli	s1,s1,0x20
    8000365a:	048a                	slli	s1,s1,0x2
    8000365c:	94aa                	add	s1,s1,a0
    8000365e:	0584a983          	lw	s3,88(s1)
    80003662:	fe0990e3          	bnez	s3,80003642 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003666:	4108                	lw	a0,0(a0)
    80003668:	00000097          	auipc	ra,0x0
    8000366c:	e4a080e7          	jalr	-438(ra) # 800034b2 <balloc>
    80003670:	0005099b          	sext.w	s3,a0
    80003674:	0534ac23          	sw	s3,88(s1)
    80003678:	b7e9                	j	80003642 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000367a:	4108                	lw	a0,0(a0)
    8000367c:	00000097          	auipc	ra,0x0
    80003680:	e36080e7          	jalr	-458(ra) # 800034b2 <balloc>
    80003684:	0005059b          	sext.w	a1,a0
    80003688:	08b92423          	sw	a1,136(s2)
    8000368c:	b759                	j	80003612 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000368e:	00092503          	lw	a0,0(s2)
    80003692:	00000097          	auipc	ra,0x0
    80003696:	e20080e7          	jalr	-480(ra) # 800034b2 <balloc>
    8000369a:	0005099b          	sext.w	s3,a0
    8000369e:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800036a2:	8552                	mv	a0,s4
    800036a4:	00001097          	auipc	ra,0x1
    800036a8:	f7e080e7          	jalr	-130(ra) # 80004622 <log_write>
    800036ac:	b771                	j	80003638 <bmap+0x54>
  panic("bmap: out of range");
    800036ae:	00005517          	auipc	a0,0x5
    800036b2:	31a50513          	addi	a0,a0,794 # 800089c8 <userret+0x938>
    800036b6:	ffffd097          	auipc	ra,0xffffd
    800036ba:	e9e080e7          	jalr	-354(ra) # 80000554 <panic>

00000000800036be <iget>:
{
    800036be:	7179                	addi	sp,sp,-48
    800036c0:	f406                	sd	ra,40(sp)
    800036c2:	f022                	sd	s0,32(sp)
    800036c4:	ec26                	sd	s1,24(sp)
    800036c6:	e84a                	sd	s2,16(sp)
    800036c8:	e44e                	sd	s3,8(sp)
    800036ca:	e052                	sd	s4,0(sp)
    800036cc:	1800                	addi	s0,sp,48
    800036ce:	89aa                	mv	s3,a0
    800036d0:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800036d2:	00028517          	auipc	a0,0x28
    800036d6:	80e50513          	addi	a0,a0,-2034 # 8002aee0 <icache>
    800036da:	ffffd097          	auipc	ra,0xffffd
    800036de:	3c6080e7          	jalr	966(ra) # 80000aa0 <acquire>
  empty = 0;
    800036e2:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800036e4:	00028497          	auipc	s1,0x28
    800036e8:	81c48493          	addi	s1,s1,-2020 # 8002af00 <icache+0x20>
    800036ec:	00029697          	auipc	a3,0x29
    800036f0:	43468693          	addi	a3,a3,1076 # 8002cb20 <log>
    800036f4:	a039                	j	80003702 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036f6:	02090b63          	beqz	s2,8000372c <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800036fa:	09048493          	addi	s1,s1,144
    800036fe:	02d48a63          	beq	s1,a3,80003732 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003702:	449c                	lw	a5,8(s1)
    80003704:	fef059e3          	blez	a5,800036f6 <iget+0x38>
    80003708:	4098                	lw	a4,0(s1)
    8000370a:	ff3716e3          	bne	a4,s3,800036f6 <iget+0x38>
    8000370e:	40d8                	lw	a4,4(s1)
    80003710:	ff4713e3          	bne	a4,s4,800036f6 <iget+0x38>
      ip->ref++;
    80003714:	2785                	addiw	a5,a5,1
    80003716:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003718:	00027517          	auipc	a0,0x27
    8000371c:	7c850513          	addi	a0,a0,1992 # 8002aee0 <icache>
    80003720:	ffffd097          	auipc	ra,0xffffd
    80003724:	450080e7          	jalr	1104(ra) # 80000b70 <release>
      return ip;
    80003728:	8926                	mv	s2,s1
    8000372a:	a03d                	j	80003758 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000372c:	f7f9                	bnez	a5,800036fa <iget+0x3c>
    8000372e:	8926                	mv	s2,s1
    80003730:	b7e9                	j	800036fa <iget+0x3c>
  if(empty == 0)
    80003732:	02090c63          	beqz	s2,8000376a <iget+0xac>
  ip->dev = dev;
    80003736:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000373a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000373e:	4785                	li	a5,1
    80003740:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003744:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    80003748:	00027517          	auipc	a0,0x27
    8000374c:	79850513          	addi	a0,a0,1944 # 8002aee0 <icache>
    80003750:	ffffd097          	auipc	ra,0xffffd
    80003754:	420080e7          	jalr	1056(ra) # 80000b70 <release>
}
    80003758:	854a                	mv	a0,s2
    8000375a:	70a2                	ld	ra,40(sp)
    8000375c:	7402                	ld	s0,32(sp)
    8000375e:	64e2                	ld	s1,24(sp)
    80003760:	6942                	ld	s2,16(sp)
    80003762:	69a2                	ld	s3,8(sp)
    80003764:	6a02                	ld	s4,0(sp)
    80003766:	6145                	addi	sp,sp,48
    80003768:	8082                	ret
    panic("iget: no inodes");
    8000376a:	00005517          	auipc	a0,0x5
    8000376e:	27650513          	addi	a0,a0,630 # 800089e0 <userret+0x950>
    80003772:	ffffd097          	auipc	ra,0xffffd
    80003776:	de2080e7          	jalr	-542(ra) # 80000554 <panic>

000000008000377a <fsinit>:
fsinit(int dev) {
    8000377a:	7179                	addi	sp,sp,-48
    8000377c:	f406                	sd	ra,40(sp)
    8000377e:	f022                	sd	s0,32(sp)
    80003780:	ec26                	sd	s1,24(sp)
    80003782:	e84a                	sd	s2,16(sp)
    80003784:	e44e                	sd	s3,8(sp)
    80003786:	1800                	addi	s0,sp,48
    80003788:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000378a:	4585                	li	a1,1
    8000378c:	00000097          	auipc	ra,0x0
    80003790:	a60080e7          	jalr	-1440(ra) # 800031ec <bread>
    80003794:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003796:	00027997          	auipc	s3,0x27
    8000379a:	72a98993          	addi	s3,s3,1834 # 8002aec0 <sb>
    8000379e:	02000613          	li	a2,32
    800037a2:	06050593          	addi	a1,a0,96
    800037a6:	854e                	mv	a0,s3
    800037a8:	ffffd097          	auipc	ra,0xffffd
    800037ac:	622080e7          	jalr	1570(ra) # 80000dca <memmove>
  brelse(bp);
    800037b0:	8526                	mv	a0,s1
    800037b2:	00000097          	auipc	ra,0x0
    800037b6:	b6e080e7          	jalr	-1170(ra) # 80003320 <brelse>
  if(sb.magic != FSMAGIC)
    800037ba:	0009a703          	lw	a4,0(s3)
    800037be:	102037b7          	lui	a5,0x10203
    800037c2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037c6:	02f71263          	bne	a4,a5,800037ea <fsinit+0x70>
  initlog(dev, &sb);
    800037ca:	00027597          	auipc	a1,0x27
    800037ce:	6f658593          	addi	a1,a1,1782 # 8002aec0 <sb>
    800037d2:	854a                	mv	a0,s2
    800037d4:	00001097          	auipc	ra,0x1
    800037d8:	b38080e7          	jalr	-1224(ra) # 8000430c <initlog>
}
    800037dc:	70a2                	ld	ra,40(sp)
    800037de:	7402                	ld	s0,32(sp)
    800037e0:	64e2                	ld	s1,24(sp)
    800037e2:	6942                	ld	s2,16(sp)
    800037e4:	69a2                	ld	s3,8(sp)
    800037e6:	6145                	addi	sp,sp,48
    800037e8:	8082                	ret
    panic("invalid file system");
    800037ea:	00005517          	auipc	a0,0x5
    800037ee:	20650513          	addi	a0,a0,518 # 800089f0 <userret+0x960>
    800037f2:	ffffd097          	auipc	ra,0xffffd
    800037f6:	d62080e7          	jalr	-670(ra) # 80000554 <panic>

00000000800037fa <iinit>:
{
    800037fa:	7179                	addi	sp,sp,-48
    800037fc:	f406                	sd	ra,40(sp)
    800037fe:	f022                	sd	s0,32(sp)
    80003800:	ec26                	sd	s1,24(sp)
    80003802:	e84a                	sd	s2,16(sp)
    80003804:	e44e                	sd	s3,8(sp)
    80003806:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003808:	00005597          	auipc	a1,0x5
    8000380c:	20058593          	addi	a1,a1,512 # 80008a08 <userret+0x978>
    80003810:	00027517          	auipc	a0,0x27
    80003814:	6d050513          	addi	a0,a0,1744 # 8002aee0 <icache>
    80003818:	ffffd097          	auipc	ra,0xffffd
    8000381c:	1b4080e7          	jalr	436(ra) # 800009cc <initlock>
  for(i = 0; i < NINODE; i++) {
    80003820:	00027497          	auipc	s1,0x27
    80003824:	6f048493          	addi	s1,s1,1776 # 8002af10 <icache+0x30>
    80003828:	00029997          	auipc	s3,0x29
    8000382c:	30898993          	addi	s3,s3,776 # 8002cb30 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003830:	00005917          	auipc	s2,0x5
    80003834:	1e090913          	addi	s2,s2,480 # 80008a10 <userret+0x980>
    80003838:	85ca                	mv	a1,s2
    8000383a:	8526                	mv	a0,s1
    8000383c:	00001097          	auipc	ra,0x1
    80003840:	f26080e7          	jalr	-218(ra) # 80004762 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003844:	09048493          	addi	s1,s1,144
    80003848:	ff3498e3          	bne	s1,s3,80003838 <iinit+0x3e>
}
    8000384c:	70a2                	ld	ra,40(sp)
    8000384e:	7402                	ld	s0,32(sp)
    80003850:	64e2                	ld	s1,24(sp)
    80003852:	6942                	ld	s2,16(sp)
    80003854:	69a2                	ld	s3,8(sp)
    80003856:	6145                	addi	sp,sp,48
    80003858:	8082                	ret

000000008000385a <ialloc>:
{
    8000385a:	715d                	addi	sp,sp,-80
    8000385c:	e486                	sd	ra,72(sp)
    8000385e:	e0a2                	sd	s0,64(sp)
    80003860:	fc26                	sd	s1,56(sp)
    80003862:	f84a                	sd	s2,48(sp)
    80003864:	f44e                	sd	s3,40(sp)
    80003866:	f052                	sd	s4,32(sp)
    80003868:	ec56                	sd	s5,24(sp)
    8000386a:	e85a                	sd	s6,16(sp)
    8000386c:	e45e                	sd	s7,8(sp)
    8000386e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003870:	00027717          	auipc	a4,0x27
    80003874:	65c72703          	lw	a4,1628(a4) # 8002aecc <sb+0xc>
    80003878:	4785                	li	a5,1
    8000387a:	04e7fa63          	bgeu	a5,a4,800038ce <ialloc+0x74>
    8000387e:	8aaa                	mv	s5,a0
    80003880:	8bae                	mv	s7,a1
    80003882:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003884:	00027a17          	auipc	s4,0x27
    80003888:	63ca0a13          	addi	s4,s4,1596 # 8002aec0 <sb>
    8000388c:	00048b1b          	sext.w	s6,s1
    80003890:	0044d793          	srli	a5,s1,0x4
    80003894:	018a2583          	lw	a1,24(s4)
    80003898:	9dbd                	addw	a1,a1,a5
    8000389a:	8556                	mv	a0,s5
    8000389c:	00000097          	auipc	ra,0x0
    800038a0:	950080e7          	jalr	-1712(ra) # 800031ec <bread>
    800038a4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800038a6:	06050993          	addi	s3,a0,96
    800038aa:	00f4f793          	andi	a5,s1,15
    800038ae:	079a                	slli	a5,a5,0x6
    800038b0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800038b2:	00099783          	lh	a5,0(s3)
    800038b6:	c785                	beqz	a5,800038de <ialloc+0x84>
    brelse(bp);
    800038b8:	00000097          	auipc	ra,0x0
    800038bc:	a68080e7          	jalr	-1432(ra) # 80003320 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038c0:	0485                	addi	s1,s1,1
    800038c2:	00ca2703          	lw	a4,12(s4)
    800038c6:	0004879b          	sext.w	a5,s1
    800038ca:	fce7e1e3          	bltu	a5,a4,8000388c <ialloc+0x32>
  panic("ialloc: no inodes");
    800038ce:	00005517          	auipc	a0,0x5
    800038d2:	14a50513          	addi	a0,a0,330 # 80008a18 <userret+0x988>
    800038d6:	ffffd097          	auipc	ra,0xffffd
    800038da:	c7e080e7          	jalr	-898(ra) # 80000554 <panic>
      memset(dip, 0, sizeof(*dip));
    800038de:	04000613          	li	a2,64
    800038e2:	4581                	li	a1,0
    800038e4:	854e                	mv	a0,s3
    800038e6:	ffffd097          	auipc	ra,0xffffd
    800038ea:	488080e7          	jalr	1160(ra) # 80000d6e <memset>
      dip->type = type;
    800038ee:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038f2:	854a                	mv	a0,s2
    800038f4:	00001097          	auipc	ra,0x1
    800038f8:	d2e080e7          	jalr	-722(ra) # 80004622 <log_write>
      brelse(bp);
    800038fc:	854a                	mv	a0,s2
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	a22080e7          	jalr	-1502(ra) # 80003320 <brelse>
      return iget(dev, inum);
    80003906:	85da                	mv	a1,s6
    80003908:	8556                	mv	a0,s5
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	db4080e7          	jalr	-588(ra) # 800036be <iget>
}
    80003912:	60a6                	ld	ra,72(sp)
    80003914:	6406                	ld	s0,64(sp)
    80003916:	74e2                	ld	s1,56(sp)
    80003918:	7942                	ld	s2,48(sp)
    8000391a:	79a2                	ld	s3,40(sp)
    8000391c:	7a02                	ld	s4,32(sp)
    8000391e:	6ae2                	ld	s5,24(sp)
    80003920:	6b42                	ld	s6,16(sp)
    80003922:	6ba2                	ld	s7,8(sp)
    80003924:	6161                	addi	sp,sp,80
    80003926:	8082                	ret

0000000080003928 <iupdate>:
{
    80003928:	1101                	addi	sp,sp,-32
    8000392a:	ec06                	sd	ra,24(sp)
    8000392c:	e822                	sd	s0,16(sp)
    8000392e:	e426                	sd	s1,8(sp)
    80003930:	e04a                	sd	s2,0(sp)
    80003932:	1000                	addi	s0,sp,32
    80003934:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003936:	415c                	lw	a5,4(a0)
    80003938:	0047d79b          	srliw	a5,a5,0x4
    8000393c:	00027597          	auipc	a1,0x27
    80003940:	59c5a583          	lw	a1,1436(a1) # 8002aed8 <sb+0x18>
    80003944:	9dbd                	addw	a1,a1,a5
    80003946:	4108                	lw	a0,0(a0)
    80003948:	00000097          	auipc	ra,0x0
    8000394c:	8a4080e7          	jalr	-1884(ra) # 800031ec <bread>
    80003950:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003952:	06050793          	addi	a5,a0,96
    80003956:	40c8                	lw	a0,4(s1)
    80003958:	893d                	andi	a0,a0,15
    8000395a:	051a                	slli	a0,a0,0x6
    8000395c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000395e:	04c49703          	lh	a4,76(s1)
    80003962:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003966:	04e49703          	lh	a4,78(s1)
    8000396a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000396e:	05049703          	lh	a4,80(s1)
    80003972:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003976:	05249703          	lh	a4,82(s1)
    8000397a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000397e:	48f8                	lw	a4,84(s1)
    80003980:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003982:	03400613          	li	a2,52
    80003986:	05848593          	addi	a1,s1,88
    8000398a:	0531                	addi	a0,a0,12
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	43e080e7          	jalr	1086(ra) # 80000dca <memmove>
  log_write(bp);
    80003994:	854a                	mv	a0,s2
    80003996:	00001097          	auipc	ra,0x1
    8000399a:	c8c080e7          	jalr	-884(ra) # 80004622 <log_write>
  brelse(bp);
    8000399e:	854a                	mv	a0,s2
    800039a0:	00000097          	auipc	ra,0x0
    800039a4:	980080e7          	jalr	-1664(ra) # 80003320 <brelse>
}
    800039a8:	60e2                	ld	ra,24(sp)
    800039aa:	6442                	ld	s0,16(sp)
    800039ac:	64a2                	ld	s1,8(sp)
    800039ae:	6902                	ld	s2,0(sp)
    800039b0:	6105                	addi	sp,sp,32
    800039b2:	8082                	ret

00000000800039b4 <idup>:
{
    800039b4:	1101                	addi	sp,sp,-32
    800039b6:	ec06                	sd	ra,24(sp)
    800039b8:	e822                	sd	s0,16(sp)
    800039ba:	e426                	sd	s1,8(sp)
    800039bc:	1000                	addi	s0,sp,32
    800039be:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800039c0:	00027517          	auipc	a0,0x27
    800039c4:	52050513          	addi	a0,a0,1312 # 8002aee0 <icache>
    800039c8:	ffffd097          	auipc	ra,0xffffd
    800039cc:	0d8080e7          	jalr	216(ra) # 80000aa0 <acquire>
  ip->ref++;
    800039d0:	449c                	lw	a5,8(s1)
    800039d2:	2785                	addiw	a5,a5,1
    800039d4:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800039d6:	00027517          	auipc	a0,0x27
    800039da:	50a50513          	addi	a0,a0,1290 # 8002aee0 <icache>
    800039de:	ffffd097          	auipc	ra,0xffffd
    800039e2:	192080e7          	jalr	402(ra) # 80000b70 <release>
}
    800039e6:	8526                	mv	a0,s1
    800039e8:	60e2                	ld	ra,24(sp)
    800039ea:	6442                	ld	s0,16(sp)
    800039ec:	64a2                	ld	s1,8(sp)
    800039ee:	6105                	addi	sp,sp,32
    800039f0:	8082                	ret

00000000800039f2 <ilock>:
{
    800039f2:	1101                	addi	sp,sp,-32
    800039f4:	ec06                	sd	ra,24(sp)
    800039f6:	e822                	sd	s0,16(sp)
    800039f8:	e426                	sd	s1,8(sp)
    800039fa:	e04a                	sd	s2,0(sp)
    800039fc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039fe:	c115                	beqz	a0,80003a22 <ilock+0x30>
    80003a00:	84aa                	mv	s1,a0
    80003a02:	451c                	lw	a5,8(a0)
    80003a04:	00f05f63          	blez	a5,80003a22 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a08:	0541                	addi	a0,a0,16
    80003a0a:	00001097          	auipc	ra,0x1
    80003a0e:	d92080e7          	jalr	-622(ra) # 8000479c <acquiresleep>
  if(ip->valid == 0){
    80003a12:	44bc                	lw	a5,72(s1)
    80003a14:	cf99                	beqz	a5,80003a32 <ilock+0x40>
}
    80003a16:	60e2                	ld	ra,24(sp)
    80003a18:	6442                	ld	s0,16(sp)
    80003a1a:	64a2                	ld	s1,8(sp)
    80003a1c:	6902                	ld	s2,0(sp)
    80003a1e:	6105                	addi	sp,sp,32
    80003a20:	8082                	ret
    panic("ilock");
    80003a22:	00005517          	auipc	a0,0x5
    80003a26:	00e50513          	addi	a0,a0,14 # 80008a30 <userret+0x9a0>
    80003a2a:	ffffd097          	auipc	ra,0xffffd
    80003a2e:	b2a080e7          	jalr	-1238(ra) # 80000554 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a32:	40dc                	lw	a5,4(s1)
    80003a34:	0047d79b          	srliw	a5,a5,0x4
    80003a38:	00027597          	auipc	a1,0x27
    80003a3c:	4a05a583          	lw	a1,1184(a1) # 8002aed8 <sb+0x18>
    80003a40:	9dbd                	addw	a1,a1,a5
    80003a42:	4088                	lw	a0,0(s1)
    80003a44:	fffff097          	auipc	ra,0xfffff
    80003a48:	7a8080e7          	jalr	1960(ra) # 800031ec <bread>
    80003a4c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a4e:	06050593          	addi	a1,a0,96
    80003a52:	40dc                	lw	a5,4(s1)
    80003a54:	8bbd                	andi	a5,a5,15
    80003a56:	079a                	slli	a5,a5,0x6
    80003a58:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a5a:	00059783          	lh	a5,0(a1)
    80003a5e:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003a62:	00259783          	lh	a5,2(a1)
    80003a66:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003a6a:	00459783          	lh	a5,4(a1)
    80003a6e:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003a72:	00659783          	lh	a5,6(a1)
    80003a76:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003a7a:	459c                	lw	a5,8(a1)
    80003a7c:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a7e:	03400613          	li	a2,52
    80003a82:	05b1                	addi	a1,a1,12
    80003a84:	05848513          	addi	a0,s1,88
    80003a88:	ffffd097          	auipc	ra,0xffffd
    80003a8c:	342080e7          	jalr	834(ra) # 80000dca <memmove>
    brelse(bp);
    80003a90:	854a                	mv	a0,s2
    80003a92:	00000097          	auipc	ra,0x0
    80003a96:	88e080e7          	jalr	-1906(ra) # 80003320 <brelse>
    ip->valid = 1;
    80003a9a:	4785                	li	a5,1
    80003a9c:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003a9e:	04c49783          	lh	a5,76(s1)
    80003aa2:	fbb5                	bnez	a5,80003a16 <ilock+0x24>
      panic("ilock: no type");
    80003aa4:	00005517          	auipc	a0,0x5
    80003aa8:	f9450513          	addi	a0,a0,-108 # 80008a38 <userret+0x9a8>
    80003aac:	ffffd097          	auipc	ra,0xffffd
    80003ab0:	aa8080e7          	jalr	-1368(ra) # 80000554 <panic>

0000000080003ab4 <iunlock>:
{
    80003ab4:	1101                	addi	sp,sp,-32
    80003ab6:	ec06                	sd	ra,24(sp)
    80003ab8:	e822                	sd	s0,16(sp)
    80003aba:	e426                	sd	s1,8(sp)
    80003abc:	e04a                	sd	s2,0(sp)
    80003abe:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ac0:	c905                	beqz	a0,80003af0 <iunlock+0x3c>
    80003ac2:	84aa                	mv	s1,a0
    80003ac4:	01050913          	addi	s2,a0,16
    80003ac8:	854a                	mv	a0,s2
    80003aca:	00001097          	auipc	ra,0x1
    80003ace:	d6c080e7          	jalr	-660(ra) # 80004836 <holdingsleep>
    80003ad2:	cd19                	beqz	a0,80003af0 <iunlock+0x3c>
    80003ad4:	449c                	lw	a5,8(s1)
    80003ad6:	00f05d63          	blez	a5,80003af0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ada:	854a                	mv	a0,s2
    80003adc:	00001097          	auipc	ra,0x1
    80003ae0:	d16080e7          	jalr	-746(ra) # 800047f2 <releasesleep>
}
    80003ae4:	60e2                	ld	ra,24(sp)
    80003ae6:	6442                	ld	s0,16(sp)
    80003ae8:	64a2                	ld	s1,8(sp)
    80003aea:	6902                	ld	s2,0(sp)
    80003aec:	6105                	addi	sp,sp,32
    80003aee:	8082                	ret
    panic("iunlock");
    80003af0:	00005517          	auipc	a0,0x5
    80003af4:	f5850513          	addi	a0,a0,-168 # 80008a48 <userret+0x9b8>
    80003af8:	ffffd097          	auipc	ra,0xffffd
    80003afc:	a5c080e7          	jalr	-1444(ra) # 80000554 <panic>

0000000080003b00 <iput>:
{
    80003b00:	7139                	addi	sp,sp,-64
    80003b02:	fc06                	sd	ra,56(sp)
    80003b04:	f822                	sd	s0,48(sp)
    80003b06:	f426                	sd	s1,40(sp)
    80003b08:	f04a                	sd	s2,32(sp)
    80003b0a:	ec4e                	sd	s3,24(sp)
    80003b0c:	e852                	sd	s4,16(sp)
    80003b0e:	e456                	sd	s5,8(sp)
    80003b10:	0080                	addi	s0,sp,64
    80003b12:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003b14:	00027517          	auipc	a0,0x27
    80003b18:	3cc50513          	addi	a0,a0,972 # 8002aee0 <icache>
    80003b1c:	ffffd097          	auipc	ra,0xffffd
    80003b20:	f84080e7          	jalr	-124(ra) # 80000aa0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b24:	4498                	lw	a4,8(s1)
    80003b26:	4785                	li	a5,1
    80003b28:	02f70663          	beq	a4,a5,80003b54 <iput+0x54>
  ip->ref--;
    80003b2c:	449c                	lw	a5,8(s1)
    80003b2e:	37fd                	addiw	a5,a5,-1
    80003b30:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b32:	00027517          	auipc	a0,0x27
    80003b36:	3ae50513          	addi	a0,a0,942 # 8002aee0 <icache>
    80003b3a:	ffffd097          	auipc	ra,0xffffd
    80003b3e:	036080e7          	jalr	54(ra) # 80000b70 <release>
}
    80003b42:	70e2                	ld	ra,56(sp)
    80003b44:	7442                	ld	s0,48(sp)
    80003b46:	74a2                	ld	s1,40(sp)
    80003b48:	7902                	ld	s2,32(sp)
    80003b4a:	69e2                	ld	s3,24(sp)
    80003b4c:	6a42                	ld	s4,16(sp)
    80003b4e:	6aa2                	ld	s5,8(sp)
    80003b50:	6121                	addi	sp,sp,64
    80003b52:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b54:	44bc                	lw	a5,72(s1)
    80003b56:	dbf9                	beqz	a5,80003b2c <iput+0x2c>
    80003b58:	05249783          	lh	a5,82(s1)
    80003b5c:	fbe1                	bnez	a5,80003b2c <iput+0x2c>
    acquiresleep(&ip->lock);
    80003b5e:	01048a13          	addi	s4,s1,16
    80003b62:	8552                	mv	a0,s4
    80003b64:	00001097          	auipc	ra,0x1
    80003b68:	c38080e7          	jalr	-968(ra) # 8000479c <acquiresleep>
    release(&icache.lock);
    80003b6c:	00027517          	auipc	a0,0x27
    80003b70:	37450513          	addi	a0,a0,884 # 8002aee0 <icache>
    80003b74:	ffffd097          	auipc	ra,0xffffd
    80003b78:	ffc080e7          	jalr	-4(ra) # 80000b70 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b7c:	05848913          	addi	s2,s1,88
    80003b80:	08848993          	addi	s3,s1,136
    80003b84:	a021                	j	80003b8c <iput+0x8c>
    80003b86:	0911                	addi	s2,s2,4
    80003b88:	01390d63          	beq	s2,s3,80003ba2 <iput+0xa2>
    if(ip->addrs[i]){
    80003b8c:	00092583          	lw	a1,0(s2)
    80003b90:	d9fd                	beqz	a1,80003b86 <iput+0x86>
      bfree(ip->dev, ip->addrs[i]);
    80003b92:	4088                	lw	a0,0(s1)
    80003b94:	00000097          	auipc	ra,0x0
    80003b98:	8a2080e7          	jalr	-1886(ra) # 80003436 <bfree>
      ip->addrs[i] = 0;
    80003b9c:	00092023          	sw	zero,0(s2)
    80003ba0:	b7dd                	j	80003b86 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ba2:	0884a583          	lw	a1,136(s1)
    80003ba6:	ed9d                	bnez	a1,80003be4 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ba8:	0404aa23          	sw	zero,84(s1)
  iupdate(ip);
    80003bac:	8526                	mv	a0,s1
    80003bae:	00000097          	auipc	ra,0x0
    80003bb2:	d7a080e7          	jalr	-646(ra) # 80003928 <iupdate>
    ip->type = 0;
    80003bb6:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003bba:	8526                	mv	a0,s1
    80003bbc:	00000097          	auipc	ra,0x0
    80003bc0:	d6c080e7          	jalr	-660(ra) # 80003928 <iupdate>
    ip->valid = 0;
    80003bc4:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003bc8:	8552                	mv	a0,s4
    80003bca:	00001097          	auipc	ra,0x1
    80003bce:	c28080e7          	jalr	-984(ra) # 800047f2 <releasesleep>
    acquire(&icache.lock);
    80003bd2:	00027517          	auipc	a0,0x27
    80003bd6:	30e50513          	addi	a0,a0,782 # 8002aee0 <icache>
    80003bda:	ffffd097          	auipc	ra,0xffffd
    80003bde:	ec6080e7          	jalr	-314(ra) # 80000aa0 <acquire>
    80003be2:	b7a9                	j	80003b2c <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003be4:	4088                	lw	a0,0(s1)
    80003be6:	fffff097          	auipc	ra,0xfffff
    80003bea:	606080e7          	jalr	1542(ra) # 800031ec <bread>
    80003bee:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003bf0:	06050913          	addi	s2,a0,96
    80003bf4:	46050993          	addi	s3,a0,1120
    80003bf8:	a021                	j	80003c00 <iput+0x100>
    80003bfa:	0911                	addi	s2,s2,4
    80003bfc:	01390b63          	beq	s2,s3,80003c12 <iput+0x112>
      if(a[j])
    80003c00:	00092583          	lw	a1,0(s2)
    80003c04:	d9fd                	beqz	a1,80003bfa <iput+0xfa>
        bfree(ip->dev, a[j]);
    80003c06:	4088                	lw	a0,0(s1)
    80003c08:	00000097          	auipc	ra,0x0
    80003c0c:	82e080e7          	jalr	-2002(ra) # 80003436 <bfree>
    80003c10:	b7ed                	j	80003bfa <iput+0xfa>
    brelse(bp);
    80003c12:	8556                	mv	a0,s5
    80003c14:	fffff097          	auipc	ra,0xfffff
    80003c18:	70c080e7          	jalr	1804(ra) # 80003320 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c1c:	0884a583          	lw	a1,136(s1)
    80003c20:	4088                	lw	a0,0(s1)
    80003c22:	00000097          	auipc	ra,0x0
    80003c26:	814080e7          	jalr	-2028(ra) # 80003436 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c2a:	0804a423          	sw	zero,136(s1)
    80003c2e:	bfad                	j	80003ba8 <iput+0xa8>

0000000080003c30 <iunlockput>:
{
    80003c30:	1101                	addi	sp,sp,-32
    80003c32:	ec06                	sd	ra,24(sp)
    80003c34:	e822                	sd	s0,16(sp)
    80003c36:	e426                	sd	s1,8(sp)
    80003c38:	1000                	addi	s0,sp,32
    80003c3a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c3c:	00000097          	auipc	ra,0x0
    80003c40:	e78080e7          	jalr	-392(ra) # 80003ab4 <iunlock>
  iput(ip);
    80003c44:	8526                	mv	a0,s1
    80003c46:	00000097          	auipc	ra,0x0
    80003c4a:	eba080e7          	jalr	-326(ra) # 80003b00 <iput>
}
    80003c4e:	60e2                	ld	ra,24(sp)
    80003c50:	6442                	ld	s0,16(sp)
    80003c52:	64a2                	ld	s1,8(sp)
    80003c54:	6105                	addi	sp,sp,32
    80003c56:	8082                	ret

0000000080003c58 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c58:	1141                	addi	sp,sp,-16
    80003c5a:	e422                	sd	s0,8(sp)
    80003c5c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c5e:	411c                	lw	a5,0(a0)
    80003c60:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c62:	415c                	lw	a5,4(a0)
    80003c64:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c66:	04c51783          	lh	a5,76(a0)
    80003c6a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c6e:	05251783          	lh	a5,82(a0)
    80003c72:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c76:	05456783          	lwu	a5,84(a0)
    80003c7a:	e99c                	sd	a5,16(a1)
}
    80003c7c:	6422                	ld	s0,8(sp)
    80003c7e:	0141                	addi	sp,sp,16
    80003c80:	8082                	ret

0000000080003c82 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c82:	497c                	lw	a5,84(a0)
    80003c84:	0ed7e563          	bltu	a5,a3,80003d6e <readi+0xec>
{
    80003c88:	7159                	addi	sp,sp,-112
    80003c8a:	f486                	sd	ra,104(sp)
    80003c8c:	f0a2                	sd	s0,96(sp)
    80003c8e:	eca6                	sd	s1,88(sp)
    80003c90:	e8ca                	sd	s2,80(sp)
    80003c92:	e4ce                	sd	s3,72(sp)
    80003c94:	e0d2                	sd	s4,64(sp)
    80003c96:	fc56                	sd	s5,56(sp)
    80003c98:	f85a                	sd	s6,48(sp)
    80003c9a:	f45e                	sd	s7,40(sp)
    80003c9c:	f062                	sd	s8,32(sp)
    80003c9e:	ec66                	sd	s9,24(sp)
    80003ca0:	e86a                	sd	s10,16(sp)
    80003ca2:	e46e                	sd	s11,8(sp)
    80003ca4:	1880                	addi	s0,sp,112
    80003ca6:	8baa                	mv	s7,a0
    80003ca8:	8c2e                	mv	s8,a1
    80003caa:	8ab2                	mv	s5,a2
    80003cac:	8936                	mv	s2,a3
    80003cae:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cb0:	9f35                	addw	a4,a4,a3
    80003cb2:	0cd76063          	bltu	a4,a3,80003d72 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    80003cb6:	00e7f463          	bgeu	a5,a4,80003cbe <readi+0x3c>
    n = ip->size - off;
    80003cba:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cbe:	080b0763          	beqz	s6,80003d4c <readi+0xca>
    80003cc2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cc4:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cc8:	5cfd                	li	s9,-1
    80003cca:	a82d                	j	80003d04 <readi+0x82>
    80003ccc:	02099d93          	slli	s11,s3,0x20
    80003cd0:	020ddd93          	srli	s11,s11,0x20
    80003cd4:	06048793          	addi	a5,s1,96
    80003cd8:	86ee                	mv	a3,s11
    80003cda:	963e                	add	a2,a2,a5
    80003cdc:	85d6                	mv	a1,s5
    80003cde:	8562                	mv	a0,s8
    80003ce0:	fffff097          	auipc	ra,0xfffff
    80003ce4:	8f4080e7          	jalr	-1804(ra) # 800025d4 <either_copyout>
    80003ce8:	05950d63          	beq	a0,s9,80003d42 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003cec:	8526                	mv	a0,s1
    80003cee:	fffff097          	auipc	ra,0xfffff
    80003cf2:	632080e7          	jalr	1586(ra) # 80003320 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cf6:	01498a3b          	addw	s4,s3,s4
    80003cfa:	0129893b          	addw	s2,s3,s2
    80003cfe:	9aee                	add	s5,s5,s11
    80003d00:	056a7663          	bgeu	s4,s6,80003d4c <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d04:	000ba483          	lw	s1,0(s7)
    80003d08:	00a9559b          	srliw	a1,s2,0xa
    80003d0c:	855e                	mv	a0,s7
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	8d6080e7          	jalr	-1834(ra) # 800035e4 <bmap>
    80003d16:	0005059b          	sext.w	a1,a0
    80003d1a:	8526                	mv	a0,s1
    80003d1c:	fffff097          	auipc	ra,0xfffff
    80003d20:	4d0080e7          	jalr	1232(ra) # 800031ec <bread>
    80003d24:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d26:	3ff97613          	andi	a2,s2,1023
    80003d2a:	40cd07bb          	subw	a5,s10,a2
    80003d2e:	414b073b          	subw	a4,s6,s4
    80003d32:	89be                	mv	s3,a5
    80003d34:	2781                	sext.w	a5,a5
    80003d36:	0007069b          	sext.w	a3,a4
    80003d3a:	f8f6f9e3          	bgeu	a3,a5,80003ccc <readi+0x4a>
    80003d3e:	89ba                	mv	s3,a4
    80003d40:	b771                	j	80003ccc <readi+0x4a>
      brelse(bp);
    80003d42:	8526                	mv	a0,s1
    80003d44:	fffff097          	auipc	ra,0xfffff
    80003d48:	5dc080e7          	jalr	1500(ra) # 80003320 <brelse>
  }
  return n;
    80003d4c:	000b051b          	sext.w	a0,s6
}
    80003d50:	70a6                	ld	ra,104(sp)
    80003d52:	7406                	ld	s0,96(sp)
    80003d54:	64e6                	ld	s1,88(sp)
    80003d56:	6946                	ld	s2,80(sp)
    80003d58:	69a6                	ld	s3,72(sp)
    80003d5a:	6a06                	ld	s4,64(sp)
    80003d5c:	7ae2                	ld	s5,56(sp)
    80003d5e:	7b42                	ld	s6,48(sp)
    80003d60:	7ba2                	ld	s7,40(sp)
    80003d62:	7c02                	ld	s8,32(sp)
    80003d64:	6ce2                	ld	s9,24(sp)
    80003d66:	6d42                	ld	s10,16(sp)
    80003d68:	6da2                	ld	s11,8(sp)
    80003d6a:	6165                	addi	sp,sp,112
    80003d6c:	8082                	ret
    return -1;
    80003d6e:	557d                	li	a0,-1
}
    80003d70:	8082                	ret
    return -1;
    80003d72:	557d                	li	a0,-1
    80003d74:	bff1                	j	80003d50 <readi+0xce>

0000000080003d76 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d76:	497c                	lw	a5,84(a0)
    80003d78:	10d7e663          	bltu	a5,a3,80003e84 <writei+0x10e>
{
    80003d7c:	7159                	addi	sp,sp,-112
    80003d7e:	f486                	sd	ra,104(sp)
    80003d80:	f0a2                	sd	s0,96(sp)
    80003d82:	eca6                	sd	s1,88(sp)
    80003d84:	e8ca                	sd	s2,80(sp)
    80003d86:	e4ce                	sd	s3,72(sp)
    80003d88:	e0d2                	sd	s4,64(sp)
    80003d8a:	fc56                	sd	s5,56(sp)
    80003d8c:	f85a                	sd	s6,48(sp)
    80003d8e:	f45e                	sd	s7,40(sp)
    80003d90:	f062                	sd	s8,32(sp)
    80003d92:	ec66                	sd	s9,24(sp)
    80003d94:	e86a                	sd	s10,16(sp)
    80003d96:	e46e                	sd	s11,8(sp)
    80003d98:	1880                	addi	s0,sp,112
    80003d9a:	8baa                	mv	s7,a0
    80003d9c:	8c2e                	mv	s8,a1
    80003d9e:	8ab2                	mv	s5,a2
    80003da0:	8936                	mv	s2,a3
    80003da2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003da4:	00e687bb          	addw	a5,a3,a4
    80003da8:	0ed7e063          	bltu	a5,a3,80003e88 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003dac:	00043737          	lui	a4,0x43
    80003db0:	0cf76e63          	bltu	a4,a5,80003e8c <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003db4:	0a0b0763          	beqz	s6,80003e62 <writei+0xec>
    80003db8:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dba:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003dbe:	5cfd                	li	s9,-1
    80003dc0:	a091                	j	80003e04 <writei+0x8e>
    80003dc2:	02099d93          	slli	s11,s3,0x20
    80003dc6:	020ddd93          	srli	s11,s11,0x20
    80003dca:	06048793          	addi	a5,s1,96
    80003dce:	86ee                	mv	a3,s11
    80003dd0:	8656                	mv	a2,s5
    80003dd2:	85e2                	mv	a1,s8
    80003dd4:	953e                	add	a0,a0,a5
    80003dd6:	fffff097          	auipc	ra,0xfffff
    80003dda:	854080e7          	jalr	-1964(ra) # 8000262a <either_copyin>
    80003dde:	07950263          	beq	a0,s9,80003e42 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003de2:	8526                	mv	a0,s1
    80003de4:	00001097          	auipc	ra,0x1
    80003de8:	83e080e7          	jalr	-1986(ra) # 80004622 <log_write>
    brelse(bp);
    80003dec:	8526                	mv	a0,s1
    80003dee:	fffff097          	auipc	ra,0xfffff
    80003df2:	532080e7          	jalr	1330(ra) # 80003320 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003df6:	01498a3b          	addw	s4,s3,s4
    80003dfa:	0129893b          	addw	s2,s3,s2
    80003dfe:	9aee                	add	s5,s5,s11
    80003e00:	056a7663          	bgeu	s4,s6,80003e4c <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e04:	000ba483          	lw	s1,0(s7)
    80003e08:	00a9559b          	srliw	a1,s2,0xa
    80003e0c:	855e                	mv	a0,s7
    80003e0e:	fffff097          	auipc	ra,0xfffff
    80003e12:	7d6080e7          	jalr	2006(ra) # 800035e4 <bmap>
    80003e16:	0005059b          	sext.w	a1,a0
    80003e1a:	8526                	mv	a0,s1
    80003e1c:	fffff097          	auipc	ra,0xfffff
    80003e20:	3d0080e7          	jalr	976(ra) # 800031ec <bread>
    80003e24:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e26:	3ff97513          	andi	a0,s2,1023
    80003e2a:	40ad07bb          	subw	a5,s10,a0
    80003e2e:	414b073b          	subw	a4,s6,s4
    80003e32:	89be                	mv	s3,a5
    80003e34:	2781                	sext.w	a5,a5
    80003e36:	0007069b          	sext.w	a3,a4
    80003e3a:	f8f6f4e3          	bgeu	a3,a5,80003dc2 <writei+0x4c>
    80003e3e:	89ba                	mv	s3,a4
    80003e40:	b749                	j	80003dc2 <writei+0x4c>
      brelse(bp);
    80003e42:	8526                	mv	a0,s1
    80003e44:	fffff097          	auipc	ra,0xfffff
    80003e48:	4dc080e7          	jalr	1244(ra) # 80003320 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003e4c:	054ba783          	lw	a5,84(s7)
    80003e50:	0127f463          	bgeu	a5,s2,80003e58 <writei+0xe2>
      ip->size = off;
    80003e54:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003e58:	855e                	mv	a0,s7
    80003e5a:	00000097          	auipc	ra,0x0
    80003e5e:	ace080e7          	jalr	-1330(ra) # 80003928 <iupdate>
  }

  return n;
    80003e62:	000b051b          	sext.w	a0,s6
}
    80003e66:	70a6                	ld	ra,104(sp)
    80003e68:	7406                	ld	s0,96(sp)
    80003e6a:	64e6                	ld	s1,88(sp)
    80003e6c:	6946                	ld	s2,80(sp)
    80003e6e:	69a6                	ld	s3,72(sp)
    80003e70:	6a06                	ld	s4,64(sp)
    80003e72:	7ae2                	ld	s5,56(sp)
    80003e74:	7b42                	ld	s6,48(sp)
    80003e76:	7ba2                	ld	s7,40(sp)
    80003e78:	7c02                	ld	s8,32(sp)
    80003e7a:	6ce2                	ld	s9,24(sp)
    80003e7c:	6d42                	ld	s10,16(sp)
    80003e7e:	6da2                	ld	s11,8(sp)
    80003e80:	6165                	addi	sp,sp,112
    80003e82:	8082                	ret
    return -1;
    80003e84:	557d                	li	a0,-1
}
    80003e86:	8082                	ret
    return -1;
    80003e88:	557d                	li	a0,-1
    80003e8a:	bff1                	j	80003e66 <writei+0xf0>
    return -1;
    80003e8c:	557d                	li	a0,-1
    80003e8e:	bfe1                	j	80003e66 <writei+0xf0>

0000000080003e90 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e90:	1141                	addi	sp,sp,-16
    80003e92:	e406                	sd	ra,8(sp)
    80003e94:	e022                	sd	s0,0(sp)
    80003e96:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e98:	4639                	li	a2,14
    80003e9a:	ffffd097          	auipc	ra,0xffffd
    80003e9e:	fac080e7          	jalr	-84(ra) # 80000e46 <strncmp>
}
    80003ea2:	60a2                	ld	ra,8(sp)
    80003ea4:	6402                	ld	s0,0(sp)
    80003ea6:	0141                	addi	sp,sp,16
    80003ea8:	8082                	ret

0000000080003eaa <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003eaa:	7139                	addi	sp,sp,-64
    80003eac:	fc06                	sd	ra,56(sp)
    80003eae:	f822                	sd	s0,48(sp)
    80003eb0:	f426                	sd	s1,40(sp)
    80003eb2:	f04a                	sd	s2,32(sp)
    80003eb4:	ec4e                	sd	s3,24(sp)
    80003eb6:	e852                	sd	s4,16(sp)
    80003eb8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003eba:	04c51703          	lh	a4,76(a0)
    80003ebe:	4785                	li	a5,1
    80003ec0:	00f71a63          	bne	a4,a5,80003ed4 <dirlookup+0x2a>
    80003ec4:	892a                	mv	s2,a0
    80003ec6:	89ae                	mv	s3,a1
    80003ec8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eca:	497c                	lw	a5,84(a0)
    80003ecc:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ece:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ed0:	e79d                	bnez	a5,80003efe <dirlookup+0x54>
    80003ed2:	a8a5                	j	80003f4a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ed4:	00005517          	auipc	a0,0x5
    80003ed8:	b7c50513          	addi	a0,a0,-1156 # 80008a50 <userret+0x9c0>
    80003edc:	ffffc097          	auipc	ra,0xffffc
    80003ee0:	678080e7          	jalr	1656(ra) # 80000554 <panic>
      panic("dirlookup read");
    80003ee4:	00005517          	auipc	a0,0x5
    80003ee8:	b8450513          	addi	a0,a0,-1148 # 80008a68 <userret+0x9d8>
    80003eec:	ffffc097          	auipc	ra,0xffffc
    80003ef0:	668080e7          	jalr	1640(ra) # 80000554 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ef4:	24c1                	addiw	s1,s1,16
    80003ef6:	05492783          	lw	a5,84(s2)
    80003efa:	04f4f763          	bgeu	s1,a5,80003f48 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003efe:	4741                	li	a4,16
    80003f00:	86a6                	mv	a3,s1
    80003f02:	fc040613          	addi	a2,s0,-64
    80003f06:	4581                	li	a1,0
    80003f08:	854a                	mv	a0,s2
    80003f0a:	00000097          	auipc	ra,0x0
    80003f0e:	d78080e7          	jalr	-648(ra) # 80003c82 <readi>
    80003f12:	47c1                	li	a5,16
    80003f14:	fcf518e3          	bne	a0,a5,80003ee4 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f18:	fc045783          	lhu	a5,-64(s0)
    80003f1c:	dfe1                	beqz	a5,80003ef4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f1e:	fc240593          	addi	a1,s0,-62
    80003f22:	854e                	mv	a0,s3
    80003f24:	00000097          	auipc	ra,0x0
    80003f28:	f6c080e7          	jalr	-148(ra) # 80003e90 <namecmp>
    80003f2c:	f561                	bnez	a0,80003ef4 <dirlookup+0x4a>
      if(poff)
    80003f2e:	000a0463          	beqz	s4,80003f36 <dirlookup+0x8c>
        *poff = off;
    80003f32:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f36:	fc045583          	lhu	a1,-64(s0)
    80003f3a:	00092503          	lw	a0,0(s2)
    80003f3e:	fffff097          	auipc	ra,0xfffff
    80003f42:	780080e7          	jalr	1920(ra) # 800036be <iget>
    80003f46:	a011                	j	80003f4a <dirlookup+0xa0>
  return 0;
    80003f48:	4501                	li	a0,0
}
    80003f4a:	70e2                	ld	ra,56(sp)
    80003f4c:	7442                	ld	s0,48(sp)
    80003f4e:	74a2                	ld	s1,40(sp)
    80003f50:	7902                	ld	s2,32(sp)
    80003f52:	69e2                	ld	s3,24(sp)
    80003f54:	6a42                	ld	s4,16(sp)
    80003f56:	6121                	addi	sp,sp,64
    80003f58:	8082                	ret

0000000080003f5a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f5a:	711d                	addi	sp,sp,-96
    80003f5c:	ec86                	sd	ra,88(sp)
    80003f5e:	e8a2                	sd	s0,80(sp)
    80003f60:	e4a6                	sd	s1,72(sp)
    80003f62:	e0ca                	sd	s2,64(sp)
    80003f64:	fc4e                	sd	s3,56(sp)
    80003f66:	f852                	sd	s4,48(sp)
    80003f68:	f456                	sd	s5,40(sp)
    80003f6a:	f05a                	sd	s6,32(sp)
    80003f6c:	ec5e                	sd	s7,24(sp)
    80003f6e:	e862                	sd	s8,16(sp)
    80003f70:	e466                	sd	s9,8(sp)
    80003f72:	1080                	addi	s0,sp,96
    80003f74:	84aa                	mv	s1,a0
    80003f76:	8aae                	mv	s5,a1
    80003f78:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f7a:	00054703          	lbu	a4,0(a0)
    80003f7e:	02f00793          	li	a5,47
    80003f82:	02f70363          	beq	a4,a5,80003fa8 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f86:	ffffe097          	auipc	ra,0xffffe
    80003f8a:	ad8080e7          	jalr	-1320(ra) # 80001a5e <myproc>
    80003f8e:	15853503          	ld	a0,344(a0)
    80003f92:	00000097          	auipc	ra,0x0
    80003f96:	a22080e7          	jalr	-1502(ra) # 800039b4 <idup>
    80003f9a:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f9c:	02f00913          	li	s2,47
  len = path - s;
    80003fa0:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003fa2:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003fa4:	4b85                	li	s7,1
    80003fa6:	a865                	j	8000405e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003fa8:	4585                	li	a1,1
    80003faa:	4501                	li	a0,0
    80003fac:	fffff097          	auipc	ra,0xfffff
    80003fb0:	712080e7          	jalr	1810(ra) # 800036be <iget>
    80003fb4:	89aa                	mv	s3,a0
    80003fb6:	b7dd                	j	80003f9c <namex+0x42>
      iunlockput(ip);
    80003fb8:	854e                	mv	a0,s3
    80003fba:	00000097          	auipc	ra,0x0
    80003fbe:	c76080e7          	jalr	-906(ra) # 80003c30 <iunlockput>
      return 0;
    80003fc2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fc4:	854e                	mv	a0,s3
    80003fc6:	60e6                	ld	ra,88(sp)
    80003fc8:	6446                	ld	s0,80(sp)
    80003fca:	64a6                	ld	s1,72(sp)
    80003fcc:	6906                	ld	s2,64(sp)
    80003fce:	79e2                	ld	s3,56(sp)
    80003fd0:	7a42                	ld	s4,48(sp)
    80003fd2:	7aa2                	ld	s5,40(sp)
    80003fd4:	7b02                	ld	s6,32(sp)
    80003fd6:	6be2                	ld	s7,24(sp)
    80003fd8:	6c42                	ld	s8,16(sp)
    80003fda:	6ca2                	ld	s9,8(sp)
    80003fdc:	6125                	addi	sp,sp,96
    80003fde:	8082                	ret
      iunlock(ip);
    80003fe0:	854e                	mv	a0,s3
    80003fe2:	00000097          	auipc	ra,0x0
    80003fe6:	ad2080e7          	jalr	-1326(ra) # 80003ab4 <iunlock>
      return ip;
    80003fea:	bfe9                	j	80003fc4 <namex+0x6a>
      iunlockput(ip);
    80003fec:	854e                	mv	a0,s3
    80003fee:	00000097          	auipc	ra,0x0
    80003ff2:	c42080e7          	jalr	-958(ra) # 80003c30 <iunlockput>
      return 0;
    80003ff6:	89e6                	mv	s3,s9
    80003ff8:	b7f1                	j	80003fc4 <namex+0x6a>
  len = path - s;
    80003ffa:	40b48633          	sub	a2,s1,a1
    80003ffe:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004002:	099c5463          	bge	s8,s9,8000408a <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004006:	4639                	li	a2,14
    80004008:	8552                	mv	a0,s4
    8000400a:	ffffd097          	auipc	ra,0xffffd
    8000400e:	dc0080e7          	jalr	-576(ra) # 80000dca <memmove>
  while(*path == '/')
    80004012:	0004c783          	lbu	a5,0(s1)
    80004016:	01279763          	bne	a5,s2,80004024 <namex+0xca>
    path++;
    8000401a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000401c:	0004c783          	lbu	a5,0(s1)
    80004020:	ff278de3          	beq	a5,s2,8000401a <namex+0xc0>
    ilock(ip);
    80004024:	854e                	mv	a0,s3
    80004026:	00000097          	auipc	ra,0x0
    8000402a:	9cc080e7          	jalr	-1588(ra) # 800039f2 <ilock>
    if(ip->type != T_DIR){
    8000402e:	04c99783          	lh	a5,76(s3)
    80004032:	f97793e3          	bne	a5,s7,80003fb8 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004036:	000a8563          	beqz	s5,80004040 <namex+0xe6>
    8000403a:	0004c783          	lbu	a5,0(s1)
    8000403e:	d3cd                	beqz	a5,80003fe0 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004040:	865a                	mv	a2,s6
    80004042:	85d2                	mv	a1,s4
    80004044:	854e                	mv	a0,s3
    80004046:	00000097          	auipc	ra,0x0
    8000404a:	e64080e7          	jalr	-412(ra) # 80003eaa <dirlookup>
    8000404e:	8caa                	mv	s9,a0
    80004050:	dd51                	beqz	a0,80003fec <namex+0x92>
    iunlockput(ip);
    80004052:	854e                	mv	a0,s3
    80004054:	00000097          	auipc	ra,0x0
    80004058:	bdc080e7          	jalr	-1060(ra) # 80003c30 <iunlockput>
    ip = next;
    8000405c:	89e6                	mv	s3,s9
  while(*path == '/')
    8000405e:	0004c783          	lbu	a5,0(s1)
    80004062:	05279763          	bne	a5,s2,800040b0 <namex+0x156>
    path++;
    80004066:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004068:	0004c783          	lbu	a5,0(s1)
    8000406c:	ff278de3          	beq	a5,s2,80004066 <namex+0x10c>
  if(*path == 0)
    80004070:	c79d                	beqz	a5,8000409e <namex+0x144>
    path++;
    80004072:	85a6                	mv	a1,s1
  len = path - s;
    80004074:	8cda                	mv	s9,s6
    80004076:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004078:	01278963          	beq	a5,s2,8000408a <namex+0x130>
    8000407c:	dfbd                	beqz	a5,80003ffa <namex+0xa0>
    path++;
    8000407e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004080:	0004c783          	lbu	a5,0(s1)
    80004084:	ff279ce3          	bne	a5,s2,8000407c <namex+0x122>
    80004088:	bf8d                	j	80003ffa <namex+0xa0>
    memmove(name, s, len);
    8000408a:	2601                	sext.w	a2,a2
    8000408c:	8552                	mv	a0,s4
    8000408e:	ffffd097          	auipc	ra,0xffffd
    80004092:	d3c080e7          	jalr	-708(ra) # 80000dca <memmove>
    name[len] = 0;
    80004096:	9cd2                	add	s9,s9,s4
    80004098:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000409c:	bf9d                	j	80004012 <namex+0xb8>
  if(nameiparent){
    8000409e:	f20a83e3          	beqz	s5,80003fc4 <namex+0x6a>
    iput(ip);
    800040a2:	854e                	mv	a0,s3
    800040a4:	00000097          	auipc	ra,0x0
    800040a8:	a5c080e7          	jalr	-1444(ra) # 80003b00 <iput>
    return 0;
    800040ac:	4981                	li	s3,0
    800040ae:	bf19                	j	80003fc4 <namex+0x6a>
  if(*path == 0)
    800040b0:	d7fd                	beqz	a5,8000409e <namex+0x144>
  while(*path != '/' && *path != 0)
    800040b2:	0004c783          	lbu	a5,0(s1)
    800040b6:	85a6                	mv	a1,s1
    800040b8:	b7d1                	j	8000407c <namex+0x122>

00000000800040ba <dirlink>:
{
    800040ba:	7139                	addi	sp,sp,-64
    800040bc:	fc06                	sd	ra,56(sp)
    800040be:	f822                	sd	s0,48(sp)
    800040c0:	f426                	sd	s1,40(sp)
    800040c2:	f04a                	sd	s2,32(sp)
    800040c4:	ec4e                	sd	s3,24(sp)
    800040c6:	e852                	sd	s4,16(sp)
    800040c8:	0080                	addi	s0,sp,64
    800040ca:	892a                	mv	s2,a0
    800040cc:	8a2e                	mv	s4,a1
    800040ce:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040d0:	4601                	li	a2,0
    800040d2:	00000097          	auipc	ra,0x0
    800040d6:	dd8080e7          	jalr	-552(ra) # 80003eaa <dirlookup>
    800040da:	e93d                	bnez	a0,80004150 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040dc:	05492483          	lw	s1,84(s2)
    800040e0:	c49d                	beqz	s1,8000410e <dirlink+0x54>
    800040e2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040e4:	4741                	li	a4,16
    800040e6:	86a6                	mv	a3,s1
    800040e8:	fc040613          	addi	a2,s0,-64
    800040ec:	4581                	li	a1,0
    800040ee:	854a                	mv	a0,s2
    800040f0:	00000097          	auipc	ra,0x0
    800040f4:	b92080e7          	jalr	-1134(ra) # 80003c82 <readi>
    800040f8:	47c1                	li	a5,16
    800040fa:	06f51163          	bne	a0,a5,8000415c <dirlink+0xa2>
    if(de.inum == 0)
    800040fe:	fc045783          	lhu	a5,-64(s0)
    80004102:	c791                	beqz	a5,8000410e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004104:	24c1                	addiw	s1,s1,16
    80004106:	05492783          	lw	a5,84(s2)
    8000410a:	fcf4ede3          	bltu	s1,a5,800040e4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000410e:	4639                	li	a2,14
    80004110:	85d2                	mv	a1,s4
    80004112:	fc240513          	addi	a0,s0,-62
    80004116:	ffffd097          	auipc	ra,0xffffd
    8000411a:	d6c080e7          	jalr	-660(ra) # 80000e82 <strncpy>
  de.inum = inum;
    8000411e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004122:	4741                	li	a4,16
    80004124:	86a6                	mv	a3,s1
    80004126:	fc040613          	addi	a2,s0,-64
    8000412a:	4581                	li	a1,0
    8000412c:	854a                	mv	a0,s2
    8000412e:	00000097          	auipc	ra,0x0
    80004132:	c48080e7          	jalr	-952(ra) # 80003d76 <writei>
    80004136:	872a                	mv	a4,a0
    80004138:	47c1                	li	a5,16
  return 0;
    8000413a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000413c:	02f71863          	bne	a4,a5,8000416c <dirlink+0xb2>
}
    80004140:	70e2                	ld	ra,56(sp)
    80004142:	7442                	ld	s0,48(sp)
    80004144:	74a2                	ld	s1,40(sp)
    80004146:	7902                	ld	s2,32(sp)
    80004148:	69e2                	ld	s3,24(sp)
    8000414a:	6a42                	ld	s4,16(sp)
    8000414c:	6121                	addi	sp,sp,64
    8000414e:	8082                	ret
    iput(ip);
    80004150:	00000097          	auipc	ra,0x0
    80004154:	9b0080e7          	jalr	-1616(ra) # 80003b00 <iput>
    return -1;
    80004158:	557d                	li	a0,-1
    8000415a:	b7dd                	j	80004140 <dirlink+0x86>
      panic("dirlink read");
    8000415c:	00005517          	auipc	a0,0x5
    80004160:	91c50513          	addi	a0,a0,-1764 # 80008a78 <userret+0x9e8>
    80004164:	ffffc097          	auipc	ra,0xffffc
    80004168:	3f0080e7          	jalr	1008(ra) # 80000554 <panic>
    panic("dirlink");
    8000416c:	00005517          	auipc	a0,0x5
    80004170:	a2c50513          	addi	a0,a0,-1492 # 80008b98 <userret+0xb08>
    80004174:	ffffc097          	auipc	ra,0xffffc
    80004178:	3e0080e7          	jalr	992(ra) # 80000554 <panic>

000000008000417c <namei>:

struct inode*
namei(char *path)
{
    8000417c:	1101                	addi	sp,sp,-32
    8000417e:	ec06                	sd	ra,24(sp)
    80004180:	e822                	sd	s0,16(sp)
    80004182:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004184:	fe040613          	addi	a2,s0,-32
    80004188:	4581                	li	a1,0
    8000418a:	00000097          	auipc	ra,0x0
    8000418e:	dd0080e7          	jalr	-560(ra) # 80003f5a <namex>
}
    80004192:	60e2                	ld	ra,24(sp)
    80004194:	6442                	ld	s0,16(sp)
    80004196:	6105                	addi	sp,sp,32
    80004198:	8082                	ret

000000008000419a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000419a:	1141                	addi	sp,sp,-16
    8000419c:	e406                	sd	ra,8(sp)
    8000419e:	e022                	sd	s0,0(sp)
    800041a0:	0800                	addi	s0,sp,16
    800041a2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041a4:	4585                	li	a1,1
    800041a6:	00000097          	auipc	ra,0x0
    800041aa:	db4080e7          	jalr	-588(ra) # 80003f5a <namex>
}
    800041ae:	60a2                	ld	ra,8(sp)
    800041b0:	6402                	ld	s0,0(sp)
    800041b2:	0141                	addi	sp,sp,16
    800041b4:	8082                	ret

00000000800041b6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    800041b6:	7179                	addi	sp,sp,-48
    800041b8:	f406                	sd	ra,40(sp)
    800041ba:	f022                	sd	s0,32(sp)
    800041bc:	ec26                	sd	s1,24(sp)
    800041be:	e84a                	sd	s2,16(sp)
    800041c0:	e44e                	sd	s3,8(sp)
    800041c2:	1800                	addi	s0,sp,48
    800041c4:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    800041c6:	0b000993          	li	s3,176
    800041ca:	033507b3          	mul	a5,a0,s3
    800041ce:	00029997          	auipc	s3,0x29
    800041d2:	95298993          	addi	s3,s3,-1710 # 8002cb20 <log>
    800041d6:	99be                	add	s3,s3,a5
    800041d8:	0209a583          	lw	a1,32(s3)
    800041dc:	fffff097          	auipc	ra,0xfffff
    800041e0:	010080e7          	jalr	16(ra) # 800031ec <bread>
    800041e4:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    800041e6:	0349a783          	lw	a5,52(s3)
    800041ea:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    800041ec:	0349a783          	lw	a5,52(s3)
    800041f0:	02f05763          	blez	a5,8000421e <write_head+0x68>
    800041f4:	0b000793          	li	a5,176
    800041f8:	02f487b3          	mul	a5,s1,a5
    800041fc:	00029717          	auipc	a4,0x29
    80004200:	95c70713          	addi	a4,a4,-1700 # 8002cb58 <log+0x38>
    80004204:	97ba                	add	a5,a5,a4
    80004206:	06450693          	addi	a3,a0,100
    8000420a:	4701                	li	a4,0
    8000420c:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    8000420e:	4390                	lw	a2,0(a5)
    80004210:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004212:	2705                	addiw	a4,a4,1
    80004214:	0791                	addi	a5,a5,4
    80004216:	0691                	addi	a3,a3,4
    80004218:	59d0                	lw	a2,52(a1)
    8000421a:	fec74ae3          	blt	a4,a2,8000420e <write_head+0x58>
  }
  bwrite(buf);
    8000421e:	854a                	mv	a0,s2
    80004220:	fffff097          	auipc	ra,0xfffff
    80004224:	0c0080e7          	jalr	192(ra) # 800032e0 <bwrite>
  brelse(buf);
    80004228:	854a                	mv	a0,s2
    8000422a:	fffff097          	auipc	ra,0xfffff
    8000422e:	0f6080e7          	jalr	246(ra) # 80003320 <brelse>
}
    80004232:	70a2                	ld	ra,40(sp)
    80004234:	7402                	ld	s0,32(sp)
    80004236:	64e2                	ld	s1,24(sp)
    80004238:	6942                	ld	s2,16(sp)
    8000423a:	69a2                	ld	s3,8(sp)
    8000423c:	6145                	addi	sp,sp,48
    8000423e:	8082                	ret

0000000080004240 <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004240:	0b000793          	li	a5,176
    80004244:	02f50733          	mul	a4,a0,a5
    80004248:	00029797          	auipc	a5,0x29
    8000424c:	8d878793          	addi	a5,a5,-1832 # 8002cb20 <log>
    80004250:	97ba                	add	a5,a5,a4
    80004252:	5bdc                	lw	a5,52(a5)
    80004254:	0af05b63          	blez	a5,8000430a <install_trans+0xca>
{
    80004258:	7139                	addi	sp,sp,-64
    8000425a:	fc06                	sd	ra,56(sp)
    8000425c:	f822                	sd	s0,48(sp)
    8000425e:	f426                	sd	s1,40(sp)
    80004260:	f04a                	sd	s2,32(sp)
    80004262:	ec4e                	sd	s3,24(sp)
    80004264:	e852                	sd	s4,16(sp)
    80004266:	e456                	sd	s5,8(sp)
    80004268:	e05a                	sd	s6,0(sp)
    8000426a:	0080                	addi	s0,sp,64
    8000426c:	00029797          	auipc	a5,0x29
    80004270:	8ec78793          	addi	a5,a5,-1812 # 8002cb58 <log+0x38>
    80004274:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004278:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    8000427a:	00050b1b          	sext.w	s6,a0
    8000427e:	00029a97          	auipc	s5,0x29
    80004282:	8a2a8a93          	addi	s5,s5,-1886 # 8002cb20 <log>
    80004286:	9aba                	add	s5,s5,a4
    80004288:	020aa583          	lw	a1,32(s5)
    8000428c:	013585bb          	addw	a1,a1,s3
    80004290:	2585                	addiw	a1,a1,1
    80004292:	855a                	mv	a0,s6
    80004294:	fffff097          	auipc	ra,0xfffff
    80004298:	f58080e7          	jalr	-168(ra) # 800031ec <bread>
    8000429c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    8000429e:	000a2583          	lw	a1,0(s4)
    800042a2:	855a                	mv	a0,s6
    800042a4:	fffff097          	auipc	ra,0xfffff
    800042a8:	f48080e7          	jalr	-184(ra) # 800031ec <bread>
    800042ac:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042ae:	40000613          	li	a2,1024
    800042b2:	06090593          	addi	a1,s2,96
    800042b6:	06050513          	addi	a0,a0,96
    800042ba:	ffffd097          	auipc	ra,0xffffd
    800042be:	b10080e7          	jalr	-1264(ra) # 80000dca <memmove>
    bwrite(dbuf);  // write dst to disk
    800042c2:	8526                	mv	a0,s1
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	01c080e7          	jalr	28(ra) # 800032e0 <bwrite>
    bunpin(dbuf);
    800042cc:	8526                	mv	a0,s1
    800042ce:	fffff097          	auipc	ra,0xfffff
    800042d2:	12c080e7          	jalr	300(ra) # 800033fa <bunpin>
    brelse(lbuf);
    800042d6:	854a                	mv	a0,s2
    800042d8:	fffff097          	auipc	ra,0xfffff
    800042dc:	048080e7          	jalr	72(ra) # 80003320 <brelse>
    brelse(dbuf);
    800042e0:	8526                	mv	a0,s1
    800042e2:	fffff097          	auipc	ra,0xfffff
    800042e6:	03e080e7          	jalr	62(ra) # 80003320 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800042ea:	2985                	addiw	s3,s3,1
    800042ec:	0a11                	addi	s4,s4,4
    800042ee:	034aa783          	lw	a5,52(s5)
    800042f2:	f8f9cbe3          	blt	s3,a5,80004288 <install_trans+0x48>
}
    800042f6:	70e2                	ld	ra,56(sp)
    800042f8:	7442                	ld	s0,48(sp)
    800042fa:	74a2                	ld	s1,40(sp)
    800042fc:	7902                	ld	s2,32(sp)
    800042fe:	69e2                	ld	s3,24(sp)
    80004300:	6a42                	ld	s4,16(sp)
    80004302:	6aa2                	ld	s5,8(sp)
    80004304:	6b02                	ld	s6,0(sp)
    80004306:	6121                	addi	sp,sp,64
    80004308:	8082                	ret
    8000430a:	8082                	ret

000000008000430c <initlog>:
{
    8000430c:	7179                	addi	sp,sp,-48
    8000430e:	f406                	sd	ra,40(sp)
    80004310:	f022                	sd	s0,32(sp)
    80004312:	ec26                	sd	s1,24(sp)
    80004314:	e84a                	sd	s2,16(sp)
    80004316:	e44e                	sd	s3,8(sp)
    80004318:	e052                	sd	s4,0(sp)
    8000431a:	1800                	addi	s0,sp,48
    8000431c:	892a                	mv	s2,a0
    8000431e:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80004320:	0b000713          	li	a4,176
    80004324:	02e504b3          	mul	s1,a0,a4
    80004328:	00028997          	auipc	s3,0x28
    8000432c:	7f898993          	addi	s3,s3,2040 # 8002cb20 <log>
    80004330:	99a6                	add	s3,s3,s1
    80004332:	00004597          	auipc	a1,0x4
    80004336:	75658593          	addi	a1,a1,1878 # 80008a88 <userret+0x9f8>
    8000433a:	854e                	mv	a0,s3
    8000433c:	ffffc097          	auipc	ra,0xffffc
    80004340:	690080e7          	jalr	1680(ra) # 800009cc <initlock>
  log[dev].start = sb->logstart;
    80004344:	014a2583          	lw	a1,20(s4)
    80004348:	02b9a023          	sw	a1,32(s3)
  log[dev].size = sb->nlog;
    8000434c:	010a2783          	lw	a5,16(s4)
    80004350:	02f9a223          	sw	a5,36(s3)
  log[dev].dev = dev;
    80004354:	0329a823          	sw	s2,48(s3)
  struct buf *buf = bread(dev, log[dev].start);
    80004358:	854a                	mv	a0,s2
    8000435a:	fffff097          	auipc	ra,0xfffff
    8000435e:	e92080e7          	jalr	-366(ra) # 800031ec <bread>
  log[dev].lh.n = lh->n;
    80004362:	5134                	lw	a3,96(a0)
    80004364:	02d9aa23          	sw	a3,52(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004368:	02d05663          	blez	a3,80004394 <initlog+0x88>
    8000436c:	06450793          	addi	a5,a0,100
    80004370:	00028717          	auipc	a4,0x28
    80004374:	7e870713          	addi	a4,a4,2024 # 8002cb58 <log+0x38>
    80004378:	9726                	add	a4,a4,s1
    8000437a:	36fd                	addiw	a3,a3,-1
    8000437c:	1682                	slli	a3,a3,0x20
    8000437e:	9281                	srli	a3,a3,0x20
    80004380:	068a                	slli	a3,a3,0x2
    80004382:	06850613          	addi	a2,a0,104
    80004386:	96b2                	add	a3,a3,a2
    log[dev].lh.block[i] = lh->block[i];
    80004388:	4390                	lw	a2,0(a5)
    8000438a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000438c:	0791                	addi	a5,a5,4
    8000438e:	0711                	addi	a4,a4,4
    80004390:	fed79ce3          	bne	a5,a3,80004388 <initlog+0x7c>
  brelse(buf);
    80004394:	fffff097          	auipc	ra,0xfffff
    80004398:	f8c080e7          	jalr	-116(ra) # 80003320 <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    8000439c:	854a                	mv	a0,s2
    8000439e:	00000097          	auipc	ra,0x0
    800043a2:	ea2080e7          	jalr	-350(ra) # 80004240 <install_trans>
  log[dev].lh.n = 0;
    800043a6:	0b000793          	li	a5,176
    800043aa:	02f90733          	mul	a4,s2,a5
    800043ae:	00028797          	auipc	a5,0x28
    800043b2:	77278793          	addi	a5,a5,1906 # 8002cb20 <log>
    800043b6:	97ba                	add	a5,a5,a4
    800043b8:	0207aa23          	sw	zero,52(a5)
  write_head(dev); // clear the log
    800043bc:	854a                	mv	a0,s2
    800043be:	00000097          	auipc	ra,0x0
    800043c2:	df8080e7          	jalr	-520(ra) # 800041b6 <write_head>
}
    800043c6:	70a2                	ld	ra,40(sp)
    800043c8:	7402                	ld	s0,32(sp)
    800043ca:	64e2                	ld	s1,24(sp)
    800043cc:	6942                	ld	s2,16(sp)
    800043ce:	69a2                	ld	s3,8(sp)
    800043d0:	6a02                	ld	s4,0(sp)
    800043d2:	6145                	addi	sp,sp,48
    800043d4:	8082                	ret

00000000800043d6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    800043d6:	7139                	addi	sp,sp,-64
    800043d8:	fc06                	sd	ra,56(sp)
    800043da:	f822                	sd	s0,48(sp)
    800043dc:	f426                	sd	s1,40(sp)
    800043de:	f04a                	sd	s2,32(sp)
    800043e0:	ec4e                	sd	s3,24(sp)
    800043e2:	e852                	sd	s4,16(sp)
    800043e4:	e456                	sd	s5,8(sp)
    800043e6:	0080                	addi	s0,sp,64
    800043e8:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    800043ea:	0b000913          	li	s2,176
    800043ee:	032507b3          	mul	a5,a0,s2
    800043f2:	00028917          	auipc	s2,0x28
    800043f6:	72e90913          	addi	s2,s2,1838 # 8002cb20 <log>
    800043fa:	993e                	add	s2,s2,a5
    800043fc:	854a                	mv	a0,s2
    800043fe:	ffffc097          	auipc	ra,0xffffc
    80004402:	6a2080e7          	jalr	1698(ra) # 80000aa0 <acquire>
  while(1){
    if(log[dev].committing){
    80004406:	00028997          	auipc	s3,0x28
    8000440a:	71a98993          	addi	s3,s3,1818 # 8002cb20 <log>
    8000440e:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004410:	4a79                	li	s4,30
    80004412:	a039                	j	80004420 <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    80004414:	85ca                	mv	a1,s2
    80004416:	854e                	mv	a0,s3
    80004418:	ffffe097          	auipc	ra,0xffffe
    8000441c:	f50080e7          	jalr	-176(ra) # 80002368 <sleep>
    if(log[dev].committing){
    80004420:	54dc                	lw	a5,44(s1)
    80004422:	fbed                	bnez	a5,80004414 <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004424:	549c                	lw	a5,40(s1)
    80004426:	0017871b          	addiw	a4,a5,1
    8000442a:	0007069b          	sext.w	a3,a4
    8000442e:	0027179b          	slliw	a5,a4,0x2
    80004432:	9fb9                	addw	a5,a5,a4
    80004434:	0017979b          	slliw	a5,a5,0x1
    80004438:	58d8                	lw	a4,52(s1)
    8000443a:	9fb9                	addw	a5,a5,a4
    8000443c:	00fa5963          	bge	s4,a5,8000444e <begin_op+0x78>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    80004440:	85ca                	mv	a1,s2
    80004442:	854e                	mv	a0,s3
    80004444:	ffffe097          	auipc	ra,0xffffe
    80004448:	f24080e7          	jalr	-220(ra) # 80002368 <sleep>
    8000444c:	bfd1                	j	80004420 <begin_op+0x4a>
    } else {
      log[dev].outstanding += 1;
    8000444e:	0b000513          	li	a0,176
    80004452:	02aa8ab3          	mul	s5,s5,a0
    80004456:	00028797          	auipc	a5,0x28
    8000445a:	6ca78793          	addi	a5,a5,1738 # 8002cb20 <log>
    8000445e:	9abe                	add	s5,s5,a5
    80004460:	02daa423          	sw	a3,40(s5)
      release(&log[dev].lock);
    80004464:	854a                	mv	a0,s2
    80004466:	ffffc097          	auipc	ra,0xffffc
    8000446a:	70a080e7          	jalr	1802(ra) # 80000b70 <release>
      break;
    }
  }
}
    8000446e:	70e2                	ld	ra,56(sp)
    80004470:	7442                	ld	s0,48(sp)
    80004472:	74a2                	ld	s1,40(sp)
    80004474:	7902                	ld	s2,32(sp)
    80004476:	69e2                	ld	s3,24(sp)
    80004478:	6a42                	ld	s4,16(sp)
    8000447a:	6aa2                	ld	s5,8(sp)
    8000447c:	6121                	addi	sp,sp,64
    8000447e:	8082                	ret

0000000080004480 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    80004480:	715d                	addi	sp,sp,-80
    80004482:	e486                	sd	ra,72(sp)
    80004484:	e0a2                	sd	s0,64(sp)
    80004486:	fc26                	sd	s1,56(sp)
    80004488:	f84a                	sd	s2,48(sp)
    8000448a:	f44e                	sd	s3,40(sp)
    8000448c:	f052                	sd	s4,32(sp)
    8000448e:	ec56                	sd	s5,24(sp)
    80004490:	e85a                	sd	s6,16(sp)
    80004492:	e45e                	sd	s7,8(sp)
    80004494:	e062                	sd	s8,0(sp)
    80004496:	0880                	addi	s0,sp,80
    80004498:	89aa                	mv	s3,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    8000449a:	0b000913          	li	s2,176
    8000449e:	03250933          	mul	s2,a0,s2
    800044a2:	00028497          	auipc	s1,0x28
    800044a6:	67e48493          	addi	s1,s1,1662 # 8002cb20 <log>
    800044aa:	94ca                	add	s1,s1,s2
    800044ac:	8526                	mv	a0,s1
    800044ae:	ffffc097          	auipc	ra,0xffffc
    800044b2:	5f2080e7          	jalr	1522(ra) # 80000aa0 <acquire>
  log[dev].outstanding -= 1;
    800044b6:	549c                	lw	a5,40(s1)
    800044b8:	37fd                	addiw	a5,a5,-1
    800044ba:	00078a9b          	sext.w	s5,a5
    800044be:	d49c                	sw	a5,40(s1)
  if(log[dev].committing)
    800044c0:	54dc                	lw	a5,44(s1)
    800044c2:	e3b5                	bnez	a5,80004526 <end_op+0xa6>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    800044c4:	060a9963          	bnez	s5,80004536 <end_op+0xb6>
    do_commit = 1;
    log[dev].committing = 1;
    800044c8:	0b000a13          	li	s4,176
    800044cc:	034987b3          	mul	a5,s3,s4
    800044d0:	00028a17          	auipc	s4,0x28
    800044d4:	650a0a13          	addi	s4,s4,1616 # 8002cb20 <log>
    800044d8:	9a3e                	add	s4,s4,a5
    800044da:	4785                	li	a5,1
    800044dc:	02fa2623          	sw	a5,44(s4)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    800044e0:	8526                	mv	a0,s1
    800044e2:	ffffc097          	auipc	ra,0xffffc
    800044e6:	68e080e7          	jalr	1678(ra) # 80000b70 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    800044ea:	034a2783          	lw	a5,52(s4)
    800044ee:	06f04d63          	bgtz	a5,80004568 <end_op+0xe8>
    acquire(&log[dev].lock);
    800044f2:	8526                	mv	a0,s1
    800044f4:	ffffc097          	auipc	ra,0xffffc
    800044f8:	5ac080e7          	jalr	1452(ra) # 80000aa0 <acquire>
    log[dev].committing = 0;
    800044fc:	00028517          	auipc	a0,0x28
    80004500:	62450513          	addi	a0,a0,1572 # 8002cb20 <log>
    80004504:	0b000793          	li	a5,176
    80004508:	02f989b3          	mul	s3,s3,a5
    8000450c:	99aa                	add	s3,s3,a0
    8000450e:	0209a623          	sw	zero,44(s3)
    wakeup(&log);
    80004512:	ffffe097          	auipc	ra,0xffffe
    80004516:	fd8080e7          	jalr	-40(ra) # 800024ea <wakeup>
    release(&log[dev].lock);
    8000451a:	8526                	mv	a0,s1
    8000451c:	ffffc097          	auipc	ra,0xffffc
    80004520:	654080e7          	jalr	1620(ra) # 80000b70 <release>
}
    80004524:	a035                	j	80004550 <end_op+0xd0>
    panic("log[dev].committing");
    80004526:	00004517          	auipc	a0,0x4
    8000452a:	56a50513          	addi	a0,a0,1386 # 80008a90 <userret+0xa00>
    8000452e:	ffffc097          	auipc	ra,0xffffc
    80004532:	026080e7          	jalr	38(ra) # 80000554 <panic>
    wakeup(&log);
    80004536:	00028517          	auipc	a0,0x28
    8000453a:	5ea50513          	addi	a0,a0,1514 # 8002cb20 <log>
    8000453e:	ffffe097          	auipc	ra,0xffffe
    80004542:	fac080e7          	jalr	-84(ra) # 800024ea <wakeup>
  release(&log[dev].lock);
    80004546:	8526                	mv	a0,s1
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	628080e7          	jalr	1576(ra) # 80000b70 <release>
}
    80004550:	60a6                	ld	ra,72(sp)
    80004552:	6406                	ld	s0,64(sp)
    80004554:	74e2                	ld	s1,56(sp)
    80004556:	7942                	ld	s2,48(sp)
    80004558:	79a2                	ld	s3,40(sp)
    8000455a:	7a02                	ld	s4,32(sp)
    8000455c:	6ae2                	ld	s5,24(sp)
    8000455e:	6b42                	ld	s6,16(sp)
    80004560:	6ba2                	ld	s7,8(sp)
    80004562:	6c02                	ld	s8,0(sp)
    80004564:	6161                	addi	sp,sp,80
    80004566:	8082                	ret
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004568:	00028797          	auipc	a5,0x28
    8000456c:	5f078793          	addi	a5,a5,1520 # 8002cb58 <log+0x38>
    80004570:	993e                	add	s2,s2,a5
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80004572:	00098c1b          	sext.w	s8,s3
    80004576:	0b000b93          	li	s7,176
    8000457a:	037987b3          	mul	a5,s3,s7
    8000457e:	00028b97          	auipc	s7,0x28
    80004582:	5a2b8b93          	addi	s7,s7,1442 # 8002cb20 <log>
    80004586:	9bbe                	add	s7,s7,a5
    80004588:	020ba583          	lw	a1,32(s7)
    8000458c:	015585bb          	addw	a1,a1,s5
    80004590:	2585                	addiw	a1,a1,1
    80004592:	8562                	mv	a0,s8
    80004594:	fffff097          	auipc	ra,0xfffff
    80004598:	c58080e7          	jalr	-936(ra) # 800031ec <bread>
    8000459c:	8a2a                	mv	s4,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    8000459e:	00092583          	lw	a1,0(s2)
    800045a2:	8562                	mv	a0,s8
    800045a4:	fffff097          	auipc	ra,0xfffff
    800045a8:	c48080e7          	jalr	-952(ra) # 800031ec <bread>
    800045ac:	8b2a                	mv	s6,a0
    memmove(to->data, from->data, BSIZE);
    800045ae:	40000613          	li	a2,1024
    800045b2:	06050593          	addi	a1,a0,96
    800045b6:	060a0513          	addi	a0,s4,96
    800045ba:	ffffd097          	auipc	ra,0xffffd
    800045be:	810080e7          	jalr	-2032(ra) # 80000dca <memmove>
    bwrite(to);  // write the log
    800045c2:	8552                	mv	a0,s4
    800045c4:	fffff097          	auipc	ra,0xfffff
    800045c8:	d1c080e7          	jalr	-740(ra) # 800032e0 <bwrite>
    brelse(from);
    800045cc:	855a                	mv	a0,s6
    800045ce:	fffff097          	auipc	ra,0xfffff
    800045d2:	d52080e7          	jalr	-686(ra) # 80003320 <brelse>
    brelse(to);
    800045d6:	8552                	mv	a0,s4
    800045d8:	fffff097          	auipc	ra,0xfffff
    800045dc:	d48080e7          	jalr	-696(ra) # 80003320 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800045e0:	2a85                	addiw	s5,s5,1
    800045e2:	0911                	addi	s2,s2,4
    800045e4:	034ba783          	lw	a5,52(s7)
    800045e8:	fafac0e3          	blt	s5,a5,80004588 <end_op+0x108>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    800045ec:	854e                	mv	a0,s3
    800045ee:	00000097          	auipc	ra,0x0
    800045f2:	bc8080e7          	jalr	-1080(ra) # 800041b6 <write_head>
    install_trans(dev); // Now install writes to home locations
    800045f6:	854e                	mv	a0,s3
    800045f8:	00000097          	auipc	ra,0x0
    800045fc:	c48080e7          	jalr	-952(ra) # 80004240 <install_trans>
    log[dev].lh.n = 0;
    80004600:	0b000793          	li	a5,176
    80004604:	02f98733          	mul	a4,s3,a5
    80004608:	00028797          	auipc	a5,0x28
    8000460c:	51878793          	addi	a5,a5,1304 # 8002cb20 <log>
    80004610:	97ba                	add	a5,a5,a4
    80004612:	0207aa23          	sw	zero,52(a5)
    write_head(dev);    // Erase the transaction from the log
    80004616:	854e                	mv	a0,s3
    80004618:	00000097          	auipc	ra,0x0
    8000461c:	b9e080e7          	jalr	-1122(ra) # 800041b6 <write_head>
    80004620:	bdc9                	j	800044f2 <end_op+0x72>

0000000080004622 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004622:	7179                	addi	sp,sp,-48
    80004624:	f406                	sd	ra,40(sp)
    80004626:	f022                	sd	s0,32(sp)
    80004628:	ec26                	sd	s1,24(sp)
    8000462a:	e84a                	sd	s2,16(sp)
    8000462c:	e44e                	sd	s3,8(sp)
    8000462e:	e052                	sd	s4,0(sp)
    80004630:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004632:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004636:	0b000793          	li	a5,176
    8000463a:	02f90733          	mul	a4,s2,a5
    8000463e:	00028797          	auipc	a5,0x28
    80004642:	4e278793          	addi	a5,a5,1250 # 8002cb20 <log>
    80004646:	97ba                	add	a5,a5,a4
    80004648:	5bd4                	lw	a3,52(a5)
    8000464a:	47f5                	li	a5,29
    8000464c:	0ad7cc63          	blt	a5,a3,80004704 <log_write+0xe2>
    80004650:	89aa                	mv	s3,a0
    80004652:	00028797          	auipc	a5,0x28
    80004656:	4ce78793          	addi	a5,a5,1230 # 8002cb20 <log>
    8000465a:	97ba                	add	a5,a5,a4
    8000465c:	53dc                	lw	a5,36(a5)
    8000465e:	37fd                	addiw	a5,a5,-1
    80004660:	0af6d263          	bge	a3,a5,80004704 <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004664:	0b000793          	li	a5,176
    80004668:	02f90733          	mul	a4,s2,a5
    8000466c:	00028797          	auipc	a5,0x28
    80004670:	4b478793          	addi	a5,a5,1204 # 8002cb20 <log>
    80004674:	97ba                	add	a5,a5,a4
    80004676:	579c                	lw	a5,40(a5)
    80004678:	08f05e63          	blez	a5,80004714 <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    8000467c:	0b000793          	li	a5,176
    80004680:	02f904b3          	mul	s1,s2,a5
    80004684:	00028a17          	auipc	s4,0x28
    80004688:	49ca0a13          	addi	s4,s4,1180 # 8002cb20 <log>
    8000468c:	9a26                	add	s4,s4,s1
    8000468e:	8552                	mv	a0,s4
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	410080e7          	jalr	1040(ra) # 80000aa0 <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004698:	034a2603          	lw	a2,52(s4)
    8000469c:	08c05463          	blez	a2,80004724 <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800046a0:	00c9a583          	lw	a1,12(s3)
    800046a4:	00028797          	auipc	a5,0x28
    800046a8:	4b478793          	addi	a5,a5,1204 # 8002cb58 <log+0x38>
    800046ac:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    800046ae:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800046b0:	4394                	lw	a3,0(a5)
    800046b2:	06b68a63          	beq	a3,a1,80004726 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    800046b6:	2705                	addiw	a4,a4,1
    800046b8:	0791                	addi	a5,a5,4
    800046ba:	fec71be3          	bne	a4,a2,800046b0 <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    800046be:	02c00793          	li	a5,44
    800046c2:	02f907b3          	mul	a5,s2,a5
    800046c6:	97b2                	add	a5,a5,a2
    800046c8:	07b1                	addi	a5,a5,12
    800046ca:	078a                	slli	a5,a5,0x2
    800046cc:	00028717          	auipc	a4,0x28
    800046d0:	45470713          	addi	a4,a4,1108 # 8002cb20 <log>
    800046d4:	97ba                	add	a5,a5,a4
    800046d6:	00c9a703          	lw	a4,12(s3)
    800046da:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    800046dc:	854e                	mv	a0,s3
    800046de:	fffff097          	auipc	ra,0xfffff
    800046e2:	ce0080e7          	jalr	-800(ra) # 800033be <bpin>
    log[dev].lh.n++;
    800046e6:	0b000793          	li	a5,176
    800046ea:	02f90933          	mul	s2,s2,a5
    800046ee:	00028797          	auipc	a5,0x28
    800046f2:	43278793          	addi	a5,a5,1074 # 8002cb20 <log>
    800046f6:	993e                	add	s2,s2,a5
    800046f8:	03492783          	lw	a5,52(s2)
    800046fc:	2785                	addiw	a5,a5,1
    800046fe:	02f92a23          	sw	a5,52(s2)
    80004702:	a099                	j	80004748 <log_write+0x126>
    panic("too big a transaction");
    80004704:	00004517          	auipc	a0,0x4
    80004708:	3a450513          	addi	a0,a0,932 # 80008aa8 <userret+0xa18>
    8000470c:	ffffc097          	auipc	ra,0xffffc
    80004710:	e48080e7          	jalr	-440(ra) # 80000554 <panic>
    panic("log_write outside of trans");
    80004714:	00004517          	auipc	a0,0x4
    80004718:	3ac50513          	addi	a0,a0,940 # 80008ac0 <userret+0xa30>
    8000471c:	ffffc097          	auipc	ra,0xffffc
    80004720:	e38080e7          	jalr	-456(ra) # 80000554 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004724:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    80004726:	02c00793          	li	a5,44
    8000472a:	02f907b3          	mul	a5,s2,a5
    8000472e:	97ba                	add	a5,a5,a4
    80004730:	07b1                	addi	a5,a5,12
    80004732:	078a                	slli	a5,a5,0x2
    80004734:	00028697          	auipc	a3,0x28
    80004738:	3ec68693          	addi	a3,a3,1004 # 8002cb20 <log>
    8000473c:	97b6                	add	a5,a5,a3
    8000473e:	00c9a683          	lw	a3,12(s3)
    80004742:	c794                	sw	a3,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004744:	f8e60ce3          	beq	a2,a4,800046dc <log_write+0xba>
  }
  release(&log[dev].lock);
    80004748:	8552                	mv	a0,s4
    8000474a:	ffffc097          	auipc	ra,0xffffc
    8000474e:	426080e7          	jalr	1062(ra) # 80000b70 <release>
}
    80004752:	70a2                	ld	ra,40(sp)
    80004754:	7402                	ld	s0,32(sp)
    80004756:	64e2                	ld	s1,24(sp)
    80004758:	6942                	ld	s2,16(sp)
    8000475a:	69a2                	ld	s3,8(sp)
    8000475c:	6a02                	ld	s4,0(sp)
    8000475e:	6145                	addi	sp,sp,48
    80004760:	8082                	ret

0000000080004762 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004762:	1101                	addi	sp,sp,-32
    80004764:	ec06                	sd	ra,24(sp)
    80004766:	e822                	sd	s0,16(sp)
    80004768:	e426                	sd	s1,8(sp)
    8000476a:	e04a                	sd	s2,0(sp)
    8000476c:	1000                	addi	s0,sp,32
    8000476e:	84aa                	mv	s1,a0
    80004770:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004772:	00004597          	auipc	a1,0x4
    80004776:	36e58593          	addi	a1,a1,878 # 80008ae0 <userret+0xa50>
    8000477a:	0521                	addi	a0,a0,8
    8000477c:	ffffc097          	auipc	ra,0xffffc
    80004780:	250080e7          	jalr	592(ra) # 800009cc <initlock>
  lk->name = name;
    80004784:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004788:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000478c:	0204a823          	sw	zero,48(s1)
}
    80004790:	60e2                	ld	ra,24(sp)
    80004792:	6442                	ld	s0,16(sp)
    80004794:	64a2                	ld	s1,8(sp)
    80004796:	6902                	ld	s2,0(sp)
    80004798:	6105                	addi	sp,sp,32
    8000479a:	8082                	ret

000000008000479c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000479c:	1101                	addi	sp,sp,-32
    8000479e:	ec06                	sd	ra,24(sp)
    800047a0:	e822                	sd	s0,16(sp)
    800047a2:	e426                	sd	s1,8(sp)
    800047a4:	e04a                	sd	s2,0(sp)
    800047a6:	1000                	addi	s0,sp,32
    800047a8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047aa:	00850913          	addi	s2,a0,8
    800047ae:	854a                	mv	a0,s2
    800047b0:	ffffc097          	auipc	ra,0xffffc
    800047b4:	2f0080e7          	jalr	752(ra) # 80000aa0 <acquire>
  while (lk->locked) {
    800047b8:	409c                	lw	a5,0(s1)
    800047ba:	cb89                	beqz	a5,800047cc <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800047bc:	85ca                	mv	a1,s2
    800047be:	8526                	mv	a0,s1
    800047c0:	ffffe097          	auipc	ra,0xffffe
    800047c4:	ba8080e7          	jalr	-1112(ra) # 80002368 <sleep>
  while (lk->locked) {
    800047c8:	409c                	lw	a5,0(s1)
    800047ca:	fbed                	bnez	a5,800047bc <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047cc:	4785                	li	a5,1
    800047ce:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047d0:	ffffd097          	auipc	ra,0xffffd
    800047d4:	28e080e7          	jalr	654(ra) # 80001a5e <myproc>
    800047d8:	413c                	lw	a5,64(a0)
    800047da:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    800047dc:	854a                	mv	a0,s2
    800047de:	ffffc097          	auipc	ra,0xffffc
    800047e2:	392080e7          	jalr	914(ra) # 80000b70 <release>
}
    800047e6:	60e2                	ld	ra,24(sp)
    800047e8:	6442                	ld	s0,16(sp)
    800047ea:	64a2                	ld	s1,8(sp)
    800047ec:	6902                	ld	s2,0(sp)
    800047ee:	6105                	addi	sp,sp,32
    800047f0:	8082                	ret

00000000800047f2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800047f2:	1101                	addi	sp,sp,-32
    800047f4:	ec06                	sd	ra,24(sp)
    800047f6:	e822                	sd	s0,16(sp)
    800047f8:	e426                	sd	s1,8(sp)
    800047fa:	e04a                	sd	s2,0(sp)
    800047fc:	1000                	addi	s0,sp,32
    800047fe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004800:	00850913          	addi	s2,a0,8
    80004804:	854a                	mv	a0,s2
    80004806:	ffffc097          	auipc	ra,0xffffc
    8000480a:	29a080e7          	jalr	666(ra) # 80000aa0 <acquire>
  lk->locked = 0;
    8000480e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004812:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    80004816:	8526                	mv	a0,s1
    80004818:	ffffe097          	auipc	ra,0xffffe
    8000481c:	cd2080e7          	jalr	-814(ra) # 800024ea <wakeup>
  release(&lk->lk);
    80004820:	854a                	mv	a0,s2
    80004822:	ffffc097          	auipc	ra,0xffffc
    80004826:	34e080e7          	jalr	846(ra) # 80000b70 <release>
}
    8000482a:	60e2                	ld	ra,24(sp)
    8000482c:	6442                	ld	s0,16(sp)
    8000482e:	64a2                	ld	s1,8(sp)
    80004830:	6902                	ld	s2,0(sp)
    80004832:	6105                	addi	sp,sp,32
    80004834:	8082                	ret

0000000080004836 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004836:	7179                	addi	sp,sp,-48
    80004838:	f406                	sd	ra,40(sp)
    8000483a:	f022                	sd	s0,32(sp)
    8000483c:	ec26                	sd	s1,24(sp)
    8000483e:	e84a                	sd	s2,16(sp)
    80004840:	e44e                	sd	s3,8(sp)
    80004842:	1800                	addi	s0,sp,48
    80004844:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004846:	00850913          	addi	s2,a0,8
    8000484a:	854a                	mv	a0,s2
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	254080e7          	jalr	596(ra) # 80000aa0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004854:	409c                	lw	a5,0(s1)
    80004856:	ef99                	bnez	a5,80004874 <holdingsleep+0x3e>
    80004858:	4481                	li	s1,0
  release(&lk->lk);
    8000485a:	854a                	mv	a0,s2
    8000485c:	ffffc097          	auipc	ra,0xffffc
    80004860:	314080e7          	jalr	788(ra) # 80000b70 <release>
  return r;
}
    80004864:	8526                	mv	a0,s1
    80004866:	70a2                	ld	ra,40(sp)
    80004868:	7402                	ld	s0,32(sp)
    8000486a:	64e2                	ld	s1,24(sp)
    8000486c:	6942                	ld	s2,16(sp)
    8000486e:	69a2                	ld	s3,8(sp)
    80004870:	6145                	addi	sp,sp,48
    80004872:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004874:	0304a983          	lw	s3,48(s1)
    80004878:	ffffd097          	auipc	ra,0xffffd
    8000487c:	1e6080e7          	jalr	486(ra) # 80001a5e <myproc>
    80004880:	4124                	lw	s1,64(a0)
    80004882:	413484b3          	sub	s1,s1,s3
    80004886:	0014b493          	seqz	s1,s1
    8000488a:	bfc1                	j	8000485a <holdingsleep+0x24>

000000008000488c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000488c:	1141                	addi	sp,sp,-16
    8000488e:	e406                	sd	ra,8(sp)
    80004890:	e022                	sd	s0,0(sp)
    80004892:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004894:	00004597          	auipc	a1,0x4
    80004898:	25c58593          	addi	a1,a1,604 # 80008af0 <userret+0xa60>
    8000489c:	00028517          	auipc	a0,0x28
    800048a0:	48450513          	addi	a0,a0,1156 # 8002cd20 <ftable>
    800048a4:	ffffc097          	auipc	ra,0xffffc
    800048a8:	128080e7          	jalr	296(ra) # 800009cc <initlock>
}
    800048ac:	60a2                	ld	ra,8(sp)
    800048ae:	6402                	ld	s0,0(sp)
    800048b0:	0141                	addi	sp,sp,16
    800048b2:	8082                	ret

00000000800048b4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800048b4:	1101                	addi	sp,sp,-32
    800048b6:	ec06                	sd	ra,24(sp)
    800048b8:	e822                	sd	s0,16(sp)
    800048ba:	e426                	sd	s1,8(sp)
    800048bc:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048be:	00028517          	auipc	a0,0x28
    800048c2:	46250513          	addi	a0,a0,1122 # 8002cd20 <ftable>
    800048c6:	ffffc097          	auipc	ra,0xffffc
    800048ca:	1da080e7          	jalr	474(ra) # 80000aa0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048ce:	00028497          	auipc	s1,0x28
    800048d2:	47248493          	addi	s1,s1,1138 # 8002cd40 <ftable+0x20>
    800048d6:	00029717          	auipc	a4,0x29
    800048da:	40a70713          	addi	a4,a4,1034 # 8002dce0 <ftable+0xfc0>
    if(f->ref == 0){
    800048de:	40dc                	lw	a5,4(s1)
    800048e0:	cf99                	beqz	a5,800048fe <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048e2:	02848493          	addi	s1,s1,40
    800048e6:	fee49ce3          	bne	s1,a4,800048de <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800048ea:	00028517          	auipc	a0,0x28
    800048ee:	43650513          	addi	a0,a0,1078 # 8002cd20 <ftable>
    800048f2:	ffffc097          	auipc	ra,0xffffc
    800048f6:	27e080e7          	jalr	638(ra) # 80000b70 <release>
  return 0;
    800048fa:	4481                	li	s1,0
    800048fc:	a819                	j	80004912 <filealloc+0x5e>
      f->ref = 1;
    800048fe:	4785                	li	a5,1
    80004900:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004902:	00028517          	auipc	a0,0x28
    80004906:	41e50513          	addi	a0,a0,1054 # 8002cd20 <ftable>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	266080e7          	jalr	614(ra) # 80000b70 <release>
}
    80004912:	8526                	mv	a0,s1
    80004914:	60e2                	ld	ra,24(sp)
    80004916:	6442                	ld	s0,16(sp)
    80004918:	64a2                	ld	s1,8(sp)
    8000491a:	6105                	addi	sp,sp,32
    8000491c:	8082                	ret

000000008000491e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000491e:	1101                	addi	sp,sp,-32
    80004920:	ec06                	sd	ra,24(sp)
    80004922:	e822                	sd	s0,16(sp)
    80004924:	e426                	sd	s1,8(sp)
    80004926:	1000                	addi	s0,sp,32
    80004928:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000492a:	00028517          	auipc	a0,0x28
    8000492e:	3f650513          	addi	a0,a0,1014 # 8002cd20 <ftable>
    80004932:	ffffc097          	auipc	ra,0xffffc
    80004936:	16e080e7          	jalr	366(ra) # 80000aa0 <acquire>
  if(f->ref < 1)
    8000493a:	40dc                	lw	a5,4(s1)
    8000493c:	02f05263          	blez	a5,80004960 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004940:	2785                	addiw	a5,a5,1
    80004942:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004944:	00028517          	auipc	a0,0x28
    80004948:	3dc50513          	addi	a0,a0,988 # 8002cd20 <ftable>
    8000494c:	ffffc097          	auipc	ra,0xffffc
    80004950:	224080e7          	jalr	548(ra) # 80000b70 <release>
  return f;
}
    80004954:	8526                	mv	a0,s1
    80004956:	60e2                	ld	ra,24(sp)
    80004958:	6442                	ld	s0,16(sp)
    8000495a:	64a2                	ld	s1,8(sp)
    8000495c:	6105                	addi	sp,sp,32
    8000495e:	8082                	ret
    panic("filedup");
    80004960:	00004517          	auipc	a0,0x4
    80004964:	19850513          	addi	a0,a0,408 # 80008af8 <userret+0xa68>
    80004968:	ffffc097          	auipc	ra,0xffffc
    8000496c:	bec080e7          	jalr	-1044(ra) # 80000554 <panic>

0000000080004970 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004970:	7139                	addi	sp,sp,-64
    80004972:	fc06                	sd	ra,56(sp)
    80004974:	f822                	sd	s0,48(sp)
    80004976:	f426                	sd	s1,40(sp)
    80004978:	f04a                	sd	s2,32(sp)
    8000497a:	ec4e                	sd	s3,24(sp)
    8000497c:	e852                	sd	s4,16(sp)
    8000497e:	e456                	sd	s5,8(sp)
    80004980:	0080                	addi	s0,sp,64
    80004982:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004984:	00028517          	auipc	a0,0x28
    80004988:	39c50513          	addi	a0,a0,924 # 8002cd20 <ftable>
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	114080e7          	jalr	276(ra) # 80000aa0 <acquire>
  if(f->ref < 1)
    80004994:	40dc                	lw	a5,4(s1)
    80004996:	06f05563          	blez	a5,80004a00 <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    8000499a:	37fd                	addiw	a5,a5,-1
    8000499c:	0007871b          	sext.w	a4,a5
    800049a0:	c0dc                	sw	a5,4(s1)
    800049a2:	06e04763          	bgtz	a4,80004a10 <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800049a6:	0004a903          	lw	s2,0(s1)
    800049aa:	0094ca83          	lbu	s5,9(s1)
    800049ae:	0104ba03          	ld	s4,16(s1)
    800049b2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049b6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049ba:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049be:	00028517          	auipc	a0,0x28
    800049c2:	36250513          	addi	a0,a0,866 # 8002cd20 <ftable>
    800049c6:	ffffc097          	auipc	ra,0xffffc
    800049ca:	1aa080e7          	jalr	426(ra) # 80000b70 <release>

  if(ff.type == FD_PIPE){
    800049ce:	4785                	li	a5,1
    800049d0:	06f90163          	beq	s2,a5,80004a32 <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049d4:	3979                	addiw	s2,s2,-2
    800049d6:	4785                	li	a5,1
    800049d8:	0527e463          	bltu	a5,s2,80004a20 <fileclose+0xb0>
    begin_op(ff.ip->dev);
    800049dc:	0009a503          	lw	a0,0(s3)
    800049e0:	00000097          	auipc	ra,0x0
    800049e4:	9f6080e7          	jalr	-1546(ra) # 800043d6 <begin_op>
    iput(ff.ip);
    800049e8:	854e                	mv	a0,s3
    800049ea:	fffff097          	auipc	ra,0xfffff
    800049ee:	116080e7          	jalr	278(ra) # 80003b00 <iput>
    end_op(ff.ip->dev);
    800049f2:	0009a503          	lw	a0,0(s3)
    800049f6:	00000097          	auipc	ra,0x0
    800049fa:	a8a080e7          	jalr	-1398(ra) # 80004480 <end_op>
    800049fe:	a00d                	j	80004a20 <fileclose+0xb0>
    panic("fileclose");
    80004a00:	00004517          	auipc	a0,0x4
    80004a04:	10050513          	addi	a0,a0,256 # 80008b00 <userret+0xa70>
    80004a08:	ffffc097          	auipc	ra,0xffffc
    80004a0c:	b4c080e7          	jalr	-1204(ra) # 80000554 <panic>
    release(&ftable.lock);
    80004a10:	00028517          	auipc	a0,0x28
    80004a14:	31050513          	addi	a0,a0,784 # 8002cd20 <ftable>
    80004a18:	ffffc097          	auipc	ra,0xffffc
    80004a1c:	158080e7          	jalr	344(ra) # 80000b70 <release>
  }
}
    80004a20:	70e2                	ld	ra,56(sp)
    80004a22:	7442                	ld	s0,48(sp)
    80004a24:	74a2                	ld	s1,40(sp)
    80004a26:	7902                	ld	s2,32(sp)
    80004a28:	69e2                	ld	s3,24(sp)
    80004a2a:	6a42                	ld	s4,16(sp)
    80004a2c:	6aa2                	ld	s5,8(sp)
    80004a2e:	6121                	addi	sp,sp,64
    80004a30:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a32:	85d6                	mv	a1,s5
    80004a34:	8552                	mv	a0,s4
    80004a36:	00000097          	auipc	ra,0x0
    80004a3a:	376080e7          	jalr	886(ra) # 80004dac <pipeclose>
    80004a3e:	b7cd                	j	80004a20 <fileclose+0xb0>

0000000080004a40 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a40:	715d                	addi	sp,sp,-80
    80004a42:	e486                	sd	ra,72(sp)
    80004a44:	e0a2                	sd	s0,64(sp)
    80004a46:	fc26                	sd	s1,56(sp)
    80004a48:	f84a                	sd	s2,48(sp)
    80004a4a:	f44e                	sd	s3,40(sp)
    80004a4c:	0880                	addi	s0,sp,80
    80004a4e:	84aa                	mv	s1,a0
    80004a50:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a52:	ffffd097          	auipc	ra,0xffffd
    80004a56:	00c080e7          	jalr	12(ra) # 80001a5e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a5a:	409c                	lw	a5,0(s1)
    80004a5c:	37f9                	addiw	a5,a5,-2
    80004a5e:	4705                	li	a4,1
    80004a60:	04f76763          	bltu	a4,a5,80004aae <filestat+0x6e>
    80004a64:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a66:	6c88                	ld	a0,24(s1)
    80004a68:	fffff097          	auipc	ra,0xfffff
    80004a6c:	f8a080e7          	jalr	-118(ra) # 800039f2 <ilock>
    stati(f->ip, &st);
    80004a70:	fb840593          	addi	a1,s0,-72
    80004a74:	6c88                	ld	a0,24(s1)
    80004a76:	fffff097          	auipc	ra,0xfffff
    80004a7a:	1e2080e7          	jalr	482(ra) # 80003c58 <stati>
    iunlock(f->ip);
    80004a7e:	6c88                	ld	a0,24(s1)
    80004a80:	fffff097          	auipc	ra,0xfffff
    80004a84:	034080e7          	jalr	52(ra) # 80003ab4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a88:	46e1                	li	a3,24
    80004a8a:	fb840613          	addi	a2,s0,-72
    80004a8e:	85ce                	mv	a1,s3
    80004a90:	05893503          	ld	a0,88(s2)
    80004a94:	ffffd097          	auipc	ra,0xffffd
    80004a98:	cb6080e7          	jalr	-842(ra) # 8000174a <copyout>
    80004a9c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004aa0:	60a6                	ld	ra,72(sp)
    80004aa2:	6406                	ld	s0,64(sp)
    80004aa4:	74e2                	ld	s1,56(sp)
    80004aa6:	7942                	ld	s2,48(sp)
    80004aa8:	79a2                	ld	s3,40(sp)
    80004aaa:	6161                	addi	sp,sp,80
    80004aac:	8082                	ret
  return -1;
    80004aae:	557d                	li	a0,-1
    80004ab0:	bfc5                	j	80004aa0 <filestat+0x60>

0000000080004ab2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ab2:	7179                	addi	sp,sp,-48
    80004ab4:	f406                	sd	ra,40(sp)
    80004ab6:	f022                	sd	s0,32(sp)
    80004ab8:	ec26                	sd	s1,24(sp)
    80004aba:	e84a                	sd	s2,16(sp)
    80004abc:	e44e                	sd	s3,8(sp)
    80004abe:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004ac0:	00854783          	lbu	a5,8(a0)
    80004ac4:	c7c5                	beqz	a5,80004b6c <fileread+0xba>
    80004ac6:	84aa                	mv	s1,a0
    80004ac8:	89ae                	mv	s3,a1
    80004aca:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004acc:	411c                	lw	a5,0(a0)
    80004ace:	4705                	li	a4,1
    80004ad0:	04e78963          	beq	a5,a4,80004b22 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ad4:	470d                	li	a4,3
    80004ad6:	04e78d63          	beq	a5,a4,80004b30 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004ada:	4709                	li	a4,2
    80004adc:	08e79063          	bne	a5,a4,80004b5c <fileread+0xaa>
    ilock(f->ip);
    80004ae0:	6d08                	ld	a0,24(a0)
    80004ae2:	fffff097          	auipc	ra,0xfffff
    80004ae6:	f10080e7          	jalr	-240(ra) # 800039f2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004aea:	874a                	mv	a4,s2
    80004aec:	5094                	lw	a3,32(s1)
    80004aee:	864e                	mv	a2,s3
    80004af0:	4585                	li	a1,1
    80004af2:	6c88                	ld	a0,24(s1)
    80004af4:	fffff097          	auipc	ra,0xfffff
    80004af8:	18e080e7          	jalr	398(ra) # 80003c82 <readi>
    80004afc:	892a                	mv	s2,a0
    80004afe:	00a05563          	blez	a0,80004b08 <fileread+0x56>
      f->off += r;
    80004b02:	509c                	lw	a5,32(s1)
    80004b04:	9fa9                	addw	a5,a5,a0
    80004b06:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b08:	6c88                	ld	a0,24(s1)
    80004b0a:	fffff097          	auipc	ra,0xfffff
    80004b0e:	faa080e7          	jalr	-86(ra) # 80003ab4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b12:	854a                	mv	a0,s2
    80004b14:	70a2                	ld	ra,40(sp)
    80004b16:	7402                	ld	s0,32(sp)
    80004b18:	64e2                	ld	s1,24(sp)
    80004b1a:	6942                	ld	s2,16(sp)
    80004b1c:	69a2                	ld	s3,8(sp)
    80004b1e:	6145                	addi	sp,sp,48
    80004b20:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b22:	6908                	ld	a0,16(a0)
    80004b24:	00000097          	auipc	ra,0x0
    80004b28:	406080e7          	jalr	1030(ra) # 80004f2a <piperead>
    80004b2c:	892a                	mv	s2,a0
    80004b2e:	b7d5                	j	80004b12 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b30:	02451783          	lh	a5,36(a0)
    80004b34:	03079693          	slli	a3,a5,0x30
    80004b38:	92c1                	srli	a3,a3,0x30
    80004b3a:	4725                	li	a4,9
    80004b3c:	02d76a63          	bltu	a4,a3,80004b70 <fileread+0xbe>
    80004b40:	0792                	slli	a5,a5,0x4
    80004b42:	00028717          	auipc	a4,0x28
    80004b46:	13e70713          	addi	a4,a4,318 # 8002cc80 <devsw>
    80004b4a:	97ba                	add	a5,a5,a4
    80004b4c:	639c                	ld	a5,0(a5)
    80004b4e:	c39d                	beqz	a5,80004b74 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80004b50:	86b2                	mv	a3,a2
    80004b52:	862e                	mv	a2,a1
    80004b54:	4585                	li	a1,1
    80004b56:	9782                	jalr	a5
    80004b58:	892a                	mv	s2,a0
    80004b5a:	bf65                	j	80004b12 <fileread+0x60>
    panic("fileread");
    80004b5c:	00004517          	auipc	a0,0x4
    80004b60:	fb450513          	addi	a0,a0,-76 # 80008b10 <userret+0xa80>
    80004b64:	ffffc097          	auipc	ra,0xffffc
    80004b68:	9f0080e7          	jalr	-1552(ra) # 80000554 <panic>
    return -1;
    80004b6c:	597d                	li	s2,-1
    80004b6e:	b755                	j	80004b12 <fileread+0x60>
      return -1;
    80004b70:	597d                	li	s2,-1
    80004b72:	b745                	j	80004b12 <fileread+0x60>
    80004b74:	597d                	li	s2,-1
    80004b76:	bf71                	j	80004b12 <fileread+0x60>

0000000080004b78 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004b78:	00954783          	lbu	a5,9(a0)
    80004b7c:	14078663          	beqz	a5,80004cc8 <filewrite+0x150>
{
    80004b80:	715d                	addi	sp,sp,-80
    80004b82:	e486                	sd	ra,72(sp)
    80004b84:	e0a2                	sd	s0,64(sp)
    80004b86:	fc26                	sd	s1,56(sp)
    80004b88:	f84a                	sd	s2,48(sp)
    80004b8a:	f44e                	sd	s3,40(sp)
    80004b8c:	f052                	sd	s4,32(sp)
    80004b8e:	ec56                	sd	s5,24(sp)
    80004b90:	e85a                	sd	s6,16(sp)
    80004b92:	e45e                	sd	s7,8(sp)
    80004b94:	e062                	sd	s8,0(sp)
    80004b96:	0880                	addi	s0,sp,80
    80004b98:	84aa                	mv	s1,a0
    80004b9a:	8aae                	mv	s5,a1
    80004b9c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b9e:	411c                	lw	a5,0(a0)
    80004ba0:	4705                	li	a4,1
    80004ba2:	02e78263          	beq	a5,a4,80004bc6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ba6:	470d                	li	a4,3
    80004ba8:	02e78563          	beq	a5,a4,80004bd2 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004bac:	4709                	li	a4,2
    80004bae:	10e79563          	bne	a5,a4,80004cb8 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004bb2:	0ec05f63          	blez	a2,80004cb0 <filewrite+0x138>
    int i = 0;
    80004bb6:	4981                	li	s3,0
    80004bb8:	6b05                	lui	s6,0x1
    80004bba:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004bbe:	6b85                	lui	s7,0x1
    80004bc0:	c00b8b9b          	addiw	s7,s7,-1024
    80004bc4:	a851                	j	80004c58 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004bc6:	6908                	ld	a0,16(a0)
    80004bc8:	00000097          	auipc	ra,0x0
    80004bcc:	254080e7          	jalr	596(ra) # 80004e1c <pipewrite>
    80004bd0:	a865                	j	80004c88 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004bd2:	02451783          	lh	a5,36(a0)
    80004bd6:	03079693          	slli	a3,a5,0x30
    80004bda:	92c1                	srli	a3,a3,0x30
    80004bdc:	4725                	li	a4,9
    80004bde:	0ed76763          	bltu	a4,a3,80004ccc <filewrite+0x154>
    80004be2:	0792                	slli	a5,a5,0x4
    80004be4:	00028717          	auipc	a4,0x28
    80004be8:	09c70713          	addi	a4,a4,156 # 8002cc80 <devsw>
    80004bec:	97ba                	add	a5,a5,a4
    80004bee:	679c                	ld	a5,8(a5)
    80004bf0:	c3e5                	beqz	a5,80004cd0 <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004bf2:	86b2                	mv	a3,a2
    80004bf4:	862e                	mv	a2,a1
    80004bf6:	4585                	li	a1,1
    80004bf8:	9782                	jalr	a5
    80004bfa:	a079                	j	80004c88 <filewrite+0x110>
    80004bfc:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    80004c00:	6c9c                	ld	a5,24(s1)
    80004c02:	4388                	lw	a0,0(a5)
    80004c04:	fffff097          	auipc	ra,0xfffff
    80004c08:	7d2080e7          	jalr	2002(ra) # 800043d6 <begin_op>
      ilock(f->ip);
    80004c0c:	6c88                	ld	a0,24(s1)
    80004c0e:	fffff097          	auipc	ra,0xfffff
    80004c12:	de4080e7          	jalr	-540(ra) # 800039f2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c16:	8762                	mv	a4,s8
    80004c18:	5094                	lw	a3,32(s1)
    80004c1a:	01598633          	add	a2,s3,s5
    80004c1e:	4585                	li	a1,1
    80004c20:	6c88                	ld	a0,24(s1)
    80004c22:	fffff097          	auipc	ra,0xfffff
    80004c26:	154080e7          	jalr	340(ra) # 80003d76 <writei>
    80004c2a:	892a                	mv	s2,a0
    80004c2c:	02a05e63          	blez	a0,80004c68 <filewrite+0xf0>
        f->off += r;
    80004c30:	509c                	lw	a5,32(s1)
    80004c32:	9fa9                	addw	a5,a5,a0
    80004c34:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004c36:	6c88                	ld	a0,24(s1)
    80004c38:	fffff097          	auipc	ra,0xfffff
    80004c3c:	e7c080e7          	jalr	-388(ra) # 80003ab4 <iunlock>
      end_op(f->ip->dev);
    80004c40:	6c9c                	ld	a5,24(s1)
    80004c42:	4388                	lw	a0,0(a5)
    80004c44:	00000097          	auipc	ra,0x0
    80004c48:	83c080e7          	jalr	-1988(ra) # 80004480 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004c4c:	052c1a63          	bne	s8,s2,80004ca0 <filewrite+0x128>
        panic("short filewrite");
      i += r;
    80004c50:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80004c54:	0349d763          	bge	s3,s4,80004c82 <filewrite+0x10a>
      int n1 = n - i;
    80004c58:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004c5c:	893e                	mv	s2,a5
    80004c5e:	2781                	sext.w	a5,a5
    80004c60:	f8fb5ee3          	bge	s6,a5,80004bfc <filewrite+0x84>
    80004c64:	895e                	mv	s2,s7
    80004c66:	bf59                	j	80004bfc <filewrite+0x84>
      iunlock(f->ip);
    80004c68:	6c88                	ld	a0,24(s1)
    80004c6a:	fffff097          	auipc	ra,0xfffff
    80004c6e:	e4a080e7          	jalr	-438(ra) # 80003ab4 <iunlock>
      end_op(f->ip->dev);
    80004c72:	6c9c                	ld	a5,24(s1)
    80004c74:	4388                	lw	a0,0(a5)
    80004c76:	00000097          	auipc	ra,0x0
    80004c7a:	80a080e7          	jalr	-2038(ra) # 80004480 <end_op>
      if(r < 0)
    80004c7e:	fc0957e3          	bgez	s2,80004c4c <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004c82:	8552                	mv	a0,s4
    80004c84:	033a1863          	bne	s4,s3,80004cb4 <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c88:	60a6                	ld	ra,72(sp)
    80004c8a:	6406                	ld	s0,64(sp)
    80004c8c:	74e2                	ld	s1,56(sp)
    80004c8e:	7942                	ld	s2,48(sp)
    80004c90:	79a2                	ld	s3,40(sp)
    80004c92:	7a02                	ld	s4,32(sp)
    80004c94:	6ae2                	ld	s5,24(sp)
    80004c96:	6b42                	ld	s6,16(sp)
    80004c98:	6ba2                	ld	s7,8(sp)
    80004c9a:	6c02                	ld	s8,0(sp)
    80004c9c:	6161                	addi	sp,sp,80
    80004c9e:	8082                	ret
        panic("short filewrite");
    80004ca0:	00004517          	auipc	a0,0x4
    80004ca4:	e8050513          	addi	a0,a0,-384 # 80008b20 <userret+0xa90>
    80004ca8:	ffffc097          	auipc	ra,0xffffc
    80004cac:	8ac080e7          	jalr	-1876(ra) # 80000554 <panic>
    int i = 0;
    80004cb0:	4981                	li	s3,0
    80004cb2:	bfc1                	j	80004c82 <filewrite+0x10a>
    ret = (i == n ? n : -1);
    80004cb4:	557d                	li	a0,-1
    80004cb6:	bfc9                	j	80004c88 <filewrite+0x110>
    panic("filewrite");
    80004cb8:	00004517          	auipc	a0,0x4
    80004cbc:	e7850513          	addi	a0,a0,-392 # 80008b30 <userret+0xaa0>
    80004cc0:	ffffc097          	auipc	ra,0xffffc
    80004cc4:	894080e7          	jalr	-1900(ra) # 80000554 <panic>
    return -1;
    80004cc8:	557d                	li	a0,-1
}
    80004cca:	8082                	ret
      return -1;
    80004ccc:	557d                	li	a0,-1
    80004cce:	bf6d                	j	80004c88 <filewrite+0x110>
    80004cd0:	557d                	li	a0,-1
    80004cd2:	bf5d                	j	80004c88 <filewrite+0x110>

0000000080004cd4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004cd4:	7179                	addi	sp,sp,-48
    80004cd6:	f406                	sd	ra,40(sp)
    80004cd8:	f022                	sd	s0,32(sp)
    80004cda:	ec26                	sd	s1,24(sp)
    80004cdc:	e84a                	sd	s2,16(sp)
    80004cde:	e44e                	sd	s3,8(sp)
    80004ce0:	e052                	sd	s4,0(sp)
    80004ce2:	1800                	addi	s0,sp,48
    80004ce4:	84aa                	mv	s1,a0
    80004ce6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ce8:	0005b023          	sd	zero,0(a1)
    80004cec:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004cf0:	00000097          	auipc	ra,0x0
    80004cf4:	bc4080e7          	jalr	-1084(ra) # 800048b4 <filealloc>
    80004cf8:	e088                	sd	a0,0(s1)
    80004cfa:	c549                	beqz	a0,80004d84 <pipealloc+0xb0>
    80004cfc:	00000097          	auipc	ra,0x0
    80004d00:	bb8080e7          	jalr	-1096(ra) # 800048b4 <filealloc>
    80004d04:	00aa3023          	sd	a0,0(s4)
    80004d08:	c925                	beqz	a0,80004d78 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d0a:	ffffc097          	auipc	ra,0xffffc
    80004d0e:	c62080e7          	jalr	-926(ra) # 8000096c <kalloc>
    80004d12:	892a                	mv	s2,a0
    80004d14:	cd39                	beqz	a0,80004d72 <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    80004d16:	4985                	li	s3,1
    80004d18:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004d1c:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004d20:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004d24:	22052023          	sw	zero,544(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    80004d28:	02000613          	li	a2,32
    80004d2c:	4581                	li	a1,0
    80004d2e:	ffffc097          	auipc	ra,0xffffc
    80004d32:	040080e7          	jalr	64(ra) # 80000d6e <memset>
  (*f0)->type = FD_PIPE;
    80004d36:	609c                	ld	a5,0(s1)
    80004d38:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d3c:	609c                	ld	a5,0(s1)
    80004d3e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d42:	609c                	ld	a5,0(s1)
    80004d44:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d48:	609c                	ld	a5,0(s1)
    80004d4a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d4e:	000a3783          	ld	a5,0(s4)
    80004d52:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d56:	000a3783          	ld	a5,0(s4)
    80004d5a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d5e:	000a3783          	ld	a5,0(s4)
    80004d62:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d66:	000a3783          	ld	a5,0(s4)
    80004d6a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d6e:	4501                	li	a0,0
    80004d70:	a025                	j	80004d98 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d72:	6088                	ld	a0,0(s1)
    80004d74:	e501                	bnez	a0,80004d7c <pipealloc+0xa8>
    80004d76:	a039                	j	80004d84 <pipealloc+0xb0>
    80004d78:	6088                	ld	a0,0(s1)
    80004d7a:	c51d                	beqz	a0,80004da8 <pipealloc+0xd4>
    fileclose(*f0);
    80004d7c:	00000097          	auipc	ra,0x0
    80004d80:	bf4080e7          	jalr	-1036(ra) # 80004970 <fileclose>
  if(*f1)
    80004d84:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d88:	557d                	li	a0,-1
  if(*f1)
    80004d8a:	c799                	beqz	a5,80004d98 <pipealloc+0xc4>
    fileclose(*f1);
    80004d8c:	853e                	mv	a0,a5
    80004d8e:	00000097          	auipc	ra,0x0
    80004d92:	be2080e7          	jalr	-1054(ra) # 80004970 <fileclose>
  return -1;
    80004d96:	557d                	li	a0,-1
}
    80004d98:	70a2                	ld	ra,40(sp)
    80004d9a:	7402                	ld	s0,32(sp)
    80004d9c:	64e2                	ld	s1,24(sp)
    80004d9e:	6942                	ld	s2,16(sp)
    80004da0:	69a2                	ld	s3,8(sp)
    80004da2:	6a02                	ld	s4,0(sp)
    80004da4:	6145                	addi	sp,sp,48
    80004da6:	8082                	ret
  return -1;
    80004da8:	557d                	li	a0,-1
    80004daa:	b7fd                	j	80004d98 <pipealloc+0xc4>

0000000080004dac <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004dac:	1101                	addi	sp,sp,-32
    80004dae:	ec06                	sd	ra,24(sp)
    80004db0:	e822                	sd	s0,16(sp)
    80004db2:	e426                	sd	s1,8(sp)
    80004db4:	e04a                	sd	s2,0(sp)
    80004db6:	1000                	addi	s0,sp,32
    80004db8:	84aa                	mv	s1,a0
    80004dba:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004dbc:	ffffc097          	auipc	ra,0xffffc
    80004dc0:	ce4080e7          	jalr	-796(ra) # 80000aa0 <acquire>
  if(writable){
    80004dc4:	02090d63          	beqz	s2,80004dfe <pipeclose+0x52>
    pi->writeopen = 0;
    80004dc8:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004dcc:	22048513          	addi	a0,s1,544
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	71a080e7          	jalr	1818(ra) # 800024ea <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004dd8:	2284b783          	ld	a5,552(s1)
    80004ddc:	eb95                	bnez	a5,80004e10 <pipeclose+0x64>
    release(&pi->lock);
    80004dde:	8526                	mv	a0,s1
    80004de0:	ffffc097          	auipc	ra,0xffffc
    80004de4:	d90080e7          	jalr	-624(ra) # 80000b70 <release>
    kfree((char*)pi);
    80004de8:	8526                	mv	a0,s1
    80004dea:	ffffc097          	auipc	ra,0xffffc
    80004dee:	a86080e7          	jalr	-1402(ra) # 80000870 <kfree>
  } else
    release(&pi->lock);
}
    80004df2:	60e2                	ld	ra,24(sp)
    80004df4:	6442                	ld	s0,16(sp)
    80004df6:	64a2                	ld	s1,8(sp)
    80004df8:	6902                	ld	s2,0(sp)
    80004dfa:	6105                	addi	sp,sp,32
    80004dfc:	8082                	ret
    pi->readopen = 0;
    80004dfe:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004e02:	22448513          	addi	a0,s1,548
    80004e06:	ffffd097          	auipc	ra,0xffffd
    80004e0a:	6e4080e7          	jalr	1764(ra) # 800024ea <wakeup>
    80004e0e:	b7e9                	j	80004dd8 <pipeclose+0x2c>
    release(&pi->lock);
    80004e10:	8526                	mv	a0,s1
    80004e12:	ffffc097          	auipc	ra,0xffffc
    80004e16:	d5e080e7          	jalr	-674(ra) # 80000b70 <release>
}
    80004e1a:	bfe1                	j	80004df2 <pipeclose+0x46>

0000000080004e1c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e1c:	711d                	addi	sp,sp,-96
    80004e1e:	ec86                	sd	ra,88(sp)
    80004e20:	e8a2                	sd	s0,80(sp)
    80004e22:	e4a6                	sd	s1,72(sp)
    80004e24:	e0ca                	sd	s2,64(sp)
    80004e26:	fc4e                	sd	s3,56(sp)
    80004e28:	f852                	sd	s4,48(sp)
    80004e2a:	f456                	sd	s5,40(sp)
    80004e2c:	f05a                	sd	s6,32(sp)
    80004e2e:	ec5e                	sd	s7,24(sp)
    80004e30:	e862                	sd	s8,16(sp)
    80004e32:	1080                	addi	s0,sp,96
    80004e34:	84aa                	mv	s1,a0
    80004e36:	8aae                	mv	s5,a1
    80004e38:	8a32                	mv	s4,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004e3a:	ffffd097          	auipc	ra,0xffffd
    80004e3e:	c24080e7          	jalr	-988(ra) # 80001a5e <myproc>
    80004e42:	8baa                	mv	s7,a0

  acquire(&pi->lock);
    80004e44:	8526                	mv	a0,s1
    80004e46:	ffffc097          	auipc	ra,0xffffc
    80004e4a:	c5a080e7          	jalr	-934(ra) # 80000aa0 <acquire>
  for(i = 0; i < n; i++){
    80004e4e:	09405f63          	blez	s4,80004eec <pipewrite+0xd0>
    80004e52:	fffa0b1b          	addiw	s6,s4,-1
    80004e56:	1b02                	slli	s6,s6,0x20
    80004e58:	020b5b13          	srli	s6,s6,0x20
    80004e5c:	001a8793          	addi	a5,s5,1
    80004e60:	9b3e                	add	s6,s6,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004e62:	22048993          	addi	s3,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004e66:	22448913          	addi	s2,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e6a:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004e6c:	2204a783          	lw	a5,544(s1)
    80004e70:	2244a703          	lw	a4,548(s1)
    80004e74:	2007879b          	addiw	a5,a5,512
    80004e78:	02f71e63          	bne	a4,a5,80004eb4 <pipewrite+0x98>
      if(pi->readopen == 0 || myproc()->killed){
    80004e7c:	2284a783          	lw	a5,552(s1)
    80004e80:	c3d9                	beqz	a5,80004f06 <pipewrite+0xea>
    80004e82:	ffffd097          	auipc	ra,0xffffd
    80004e86:	bdc080e7          	jalr	-1060(ra) # 80001a5e <myproc>
    80004e8a:	5d1c                	lw	a5,56(a0)
    80004e8c:	efad                	bnez	a5,80004f06 <pipewrite+0xea>
      wakeup(&pi->nread);
    80004e8e:	854e                	mv	a0,s3
    80004e90:	ffffd097          	auipc	ra,0xffffd
    80004e94:	65a080e7          	jalr	1626(ra) # 800024ea <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e98:	85a6                	mv	a1,s1
    80004e9a:	854a                	mv	a0,s2
    80004e9c:	ffffd097          	auipc	ra,0xffffd
    80004ea0:	4cc080e7          	jalr	1228(ra) # 80002368 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004ea4:	2204a783          	lw	a5,544(s1)
    80004ea8:	2244a703          	lw	a4,548(s1)
    80004eac:	2007879b          	addiw	a5,a5,512
    80004eb0:	fcf706e3          	beq	a4,a5,80004e7c <pipewrite+0x60>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004eb4:	4685                	li	a3,1
    80004eb6:	8656                	mv	a2,s5
    80004eb8:	faf40593          	addi	a1,s0,-81
    80004ebc:	058bb503          	ld	a0,88(s7) # 1058 <_entry-0x7fffefa8>
    80004ec0:	ffffd097          	auipc	ra,0xffffd
    80004ec4:	916080e7          	jalr	-1770(ra) # 800017d6 <copyin>
    80004ec8:	03850263          	beq	a0,s8,80004eec <pipewrite+0xd0>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ecc:	2244a783          	lw	a5,548(s1)
    80004ed0:	0017871b          	addiw	a4,a5,1
    80004ed4:	22e4a223          	sw	a4,548(s1)
    80004ed8:	1ff7f793          	andi	a5,a5,511
    80004edc:	97a6                	add	a5,a5,s1
    80004ede:	faf44703          	lbu	a4,-81(s0)
    80004ee2:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004ee6:	0a85                	addi	s5,s5,1
    80004ee8:	f96a92e3          	bne	s5,s6,80004e6c <pipewrite+0x50>
  }
  wakeup(&pi->nread);
    80004eec:	22048513          	addi	a0,s1,544
    80004ef0:	ffffd097          	auipc	ra,0xffffd
    80004ef4:	5fa080e7          	jalr	1530(ra) # 800024ea <wakeup>
  release(&pi->lock);
    80004ef8:	8526                	mv	a0,s1
    80004efa:	ffffc097          	auipc	ra,0xffffc
    80004efe:	c76080e7          	jalr	-906(ra) # 80000b70 <release>
  return n;
    80004f02:	8552                	mv	a0,s4
    80004f04:	a039                	j	80004f12 <pipewrite+0xf6>
        release(&pi->lock);
    80004f06:	8526                	mv	a0,s1
    80004f08:	ffffc097          	auipc	ra,0xffffc
    80004f0c:	c68080e7          	jalr	-920(ra) # 80000b70 <release>
        return -1;
    80004f10:	557d                	li	a0,-1
}
    80004f12:	60e6                	ld	ra,88(sp)
    80004f14:	6446                	ld	s0,80(sp)
    80004f16:	64a6                	ld	s1,72(sp)
    80004f18:	6906                	ld	s2,64(sp)
    80004f1a:	79e2                	ld	s3,56(sp)
    80004f1c:	7a42                	ld	s4,48(sp)
    80004f1e:	7aa2                	ld	s5,40(sp)
    80004f20:	7b02                	ld	s6,32(sp)
    80004f22:	6be2                	ld	s7,24(sp)
    80004f24:	6c42                	ld	s8,16(sp)
    80004f26:	6125                	addi	sp,sp,96
    80004f28:	8082                	ret

0000000080004f2a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f2a:	715d                	addi	sp,sp,-80
    80004f2c:	e486                	sd	ra,72(sp)
    80004f2e:	e0a2                	sd	s0,64(sp)
    80004f30:	fc26                	sd	s1,56(sp)
    80004f32:	f84a                	sd	s2,48(sp)
    80004f34:	f44e                	sd	s3,40(sp)
    80004f36:	f052                	sd	s4,32(sp)
    80004f38:	ec56                	sd	s5,24(sp)
    80004f3a:	e85a                	sd	s6,16(sp)
    80004f3c:	0880                	addi	s0,sp,80
    80004f3e:	84aa                	mv	s1,a0
    80004f40:	892e                	mv	s2,a1
    80004f42:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004f44:	ffffd097          	auipc	ra,0xffffd
    80004f48:	b1a080e7          	jalr	-1254(ra) # 80001a5e <myproc>
    80004f4c:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004f4e:	8526                	mv	a0,s1
    80004f50:	ffffc097          	auipc	ra,0xffffc
    80004f54:	b50080e7          	jalr	-1200(ra) # 80000aa0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f58:	2204a703          	lw	a4,544(s1)
    80004f5c:	2244a783          	lw	a5,548(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f60:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f64:	02f71763          	bne	a4,a5,80004f92 <piperead+0x68>
    80004f68:	22c4a783          	lw	a5,556(s1)
    80004f6c:	c39d                	beqz	a5,80004f92 <piperead+0x68>
    if(myproc()->killed){
    80004f6e:	ffffd097          	auipc	ra,0xffffd
    80004f72:	af0080e7          	jalr	-1296(ra) # 80001a5e <myproc>
    80004f76:	5d1c                	lw	a5,56(a0)
    80004f78:	ebc1                	bnez	a5,80005008 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f7a:	85a6                	mv	a1,s1
    80004f7c:	854e                	mv	a0,s3
    80004f7e:	ffffd097          	auipc	ra,0xffffd
    80004f82:	3ea080e7          	jalr	1002(ra) # 80002368 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f86:	2204a703          	lw	a4,544(s1)
    80004f8a:	2244a783          	lw	a5,548(s1)
    80004f8e:	fcf70de3          	beq	a4,a5,80004f68 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f92:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f94:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f96:	05405363          	blez	s4,80004fdc <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004f9a:	2204a783          	lw	a5,544(s1)
    80004f9e:	2244a703          	lw	a4,548(s1)
    80004fa2:	02f70d63          	beq	a4,a5,80004fdc <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004fa6:	0017871b          	addiw	a4,a5,1
    80004faa:	22e4a023          	sw	a4,544(s1)
    80004fae:	1ff7f793          	andi	a5,a5,511
    80004fb2:	97a6                	add	a5,a5,s1
    80004fb4:	0207c783          	lbu	a5,32(a5)
    80004fb8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fbc:	4685                	li	a3,1
    80004fbe:	fbf40613          	addi	a2,s0,-65
    80004fc2:	85ca                	mv	a1,s2
    80004fc4:	058ab503          	ld	a0,88(s5)
    80004fc8:	ffffc097          	auipc	ra,0xffffc
    80004fcc:	782080e7          	jalr	1922(ra) # 8000174a <copyout>
    80004fd0:	01650663          	beq	a0,s6,80004fdc <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fd4:	2985                	addiw	s3,s3,1
    80004fd6:	0905                	addi	s2,s2,1
    80004fd8:	fd3a11e3          	bne	s4,s3,80004f9a <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004fdc:	22448513          	addi	a0,s1,548
    80004fe0:	ffffd097          	auipc	ra,0xffffd
    80004fe4:	50a080e7          	jalr	1290(ra) # 800024ea <wakeup>
  release(&pi->lock);
    80004fe8:	8526                	mv	a0,s1
    80004fea:	ffffc097          	auipc	ra,0xffffc
    80004fee:	b86080e7          	jalr	-1146(ra) # 80000b70 <release>
  return i;
}
    80004ff2:	854e                	mv	a0,s3
    80004ff4:	60a6                	ld	ra,72(sp)
    80004ff6:	6406                	ld	s0,64(sp)
    80004ff8:	74e2                	ld	s1,56(sp)
    80004ffa:	7942                	ld	s2,48(sp)
    80004ffc:	79a2                	ld	s3,40(sp)
    80004ffe:	7a02                	ld	s4,32(sp)
    80005000:	6ae2                	ld	s5,24(sp)
    80005002:	6b42                	ld	s6,16(sp)
    80005004:	6161                	addi	sp,sp,80
    80005006:	8082                	ret
      release(&pi->lock);
    80005008:	8526                	mv	a0,s1
    8000500a:	ffffc097          	auipc	ra,0xffffc
    8000500e:	b66080e7          	jalr	-1178(ra) # 80000b70 <release>
      return -1;
    80005012:	59fd                	li	s3,-1
    80005014:	bff9                	j	80004ff2 <piperead+0xc8>

0000000080005016 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005016:	de010113          	addi	sp,sp,-544
    8000501a:	20113c23          	sd	ra,536(sp)
    8000501e:	20813823          	sd	s0,528(sp)
    80005022:	20913423          	sd	s1,520(sp)
    80005026:	21213023          	sd	s2,512(sp)
    8000502a:	ffce                	sd	s3,504(sp)
    8000502c:	fbd2                	sd	s4,496(sp)
    8000502e:	f7d6                	sd	s5,488(sp)
    80005030:	f3da                	sd	s6,480(sp)
    80005032:	efde                	sd	s7,472(sp)
    80005034:	ebe2                	sd	s8,464(sp)
    80005036:	e7e6                	sd	s9,456(sp)
    80005038:	e3ea                	sd	s10,448(sp)
    8000503a:	ff6e                	sd	s11,440(sp)
    8000503c:	1400                	addi	s0,sp,544
    8000503e:	892a                	mv	s2,a0
    80005040:	dea43423          	sd	a0,-536(s0)
    80005044:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005048:	ffffd097          	auipc	ra,0xffffd
    8000504c:	a16080e7          	jalr	-1514(ra) # 80001a5e <myproc>
    80005050:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    80005052:	4501                	li	a0,0
    80005054:	fffff097          	auipc	ra,0xfffff
    80005058:	382080e7          	jalr	898(ra) # 800043d6 <begin_op>

  if((ip = namei(path)) == 0){
    8000505c:	854a                	mv	a0,s2
    8000505e:	fffff097          	auipc	ra,0xfffff
    80005062:	11e080e7          	jalr	286(ra) # 8000417c <namei>
    80005066:	cd25                	beqz	a0,800050de <exec+0xc8>
    80005068:	8aaa                	mv	s5,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    8000506a:	fffff097          	auipc	ra,0xfffff
    8000506e:	988080e7          	jalr	-1656(ra) # 800039f2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005072:	04000713          	li	a4,64
    80005076:	4681                	li	a3,0
    80005078:	e4840613          	addi	a2,s0,-440
    8000507c:	4581                	li	a1,0
    8000507e:	8556                	mv	a0,s5
    80005080:	fffff097          	auipc	ra,0xfffff
    80005084:	c02080e7          	jalr	-1022(ra) # 80003c82 <readi>
    80005088:	04000793          	li	a5,64
    8000508c:	00f51a63          	bne	a0,a5,800050a0 <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005090:	e4842703          	lw	a4,-440(s0)
    80005094:	464c47b7          	lui	a5,0x464c4
    80005098:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000509c:	04f70863          	beq	a4,a5,800050ec <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800050a0:	8556                	mv	a0,s5
    800050a2:	fffff097          	auipc	ra,0xfffff
    800050a6:	b8e080e7          	jalr	-1138(ra) # 80003c30 <iunlockput>
    end_op(ROOTDEV);
    800050aa:	4501                	li	a0,0
    800050ac:	fffff097          	auipc	ra,0xfffff
    800050b0:	3d4080e7          	jalr	980(ra) # 80004480 <end_op>
  }
  return -1;
    800050b4:	557d                	li	a0,-1
}
    800050b6:	21813083          	ld	ra,536(sp)
    800050ba:	21013403          	ld	s0,528(sp)
    800050be:	20813483          	ld	s1,520(sp)
    800050c2:	20013903          	ld	s2,512(sp)
    800050c6:	79fe                	ld	s3,504(sp)
    800050c8:	7a5e                	ld	s4,496(sp)
    800050ca:	7abe                	ld	s5,488(sp)
    800050cc:	7b1e                	ld	s6,480(sp)
    800050ce:	6bfe                	ld	s7,472(sp)
    800050d0:	6c5e                	ld	s8,464(sp)
    800050d2:	6cbe                	ld	s9,456(sp)
    800050d4:	6d1e                	ld	s10,448(sp)
    800050d6:	7dfa                	ld	s11,440(sp)
    800050d8:	22010113          	addi	sp,sp,544
    800050dc:	8082                	ret
    end_op(ROOTDEV);
    800050de:	4501                	li	a0,0
    800050e0:	fffff097          	auipc	ra,0xfffff
    800050e4:	3a0080e7          	jalr	928(ra) # 80004480 <end_op>
    return -1;
    800050e8:	557d                	li	a0,-1
    800050ea:	b7f1                	j	800050b6 <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    800050ec:	8526                	mv	a0,s1
    800050ee:	ffffd097          	auipc	ra,0xffffd
    800050f2:	a34080e7          	jalr	-1484(ra) # 80001b22 <proc_pagetable>
    800050f6:	8b2a                	mv	s6,a0
    800050f8:	d545                	beqz	a0,800050a0 <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050fa:	e6842783          	lw	a5,-408(s0)
    800050fe:	e8045703          	lhu	a4,-384(s0)
    80005102:	10070263          	beqz	a4,80005206 <exec+0x1f0>
  sz = 0;
    80005106:	de043c23          	sd	zero,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000510a:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000510e:	6a05                	lui	s4,0x1
    80005110:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005114:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005118:	6d85                	lui	s11,0x1
    8000511a:	7d7d                	lui	s10,0xfffff
    8000511c:	a88d                	j	8000518e <exec+0x178>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000511e:	00004517          	auipc	a0,0x4
    80005122:	a2250513          	addi	a0,a0,-1502 # 80008b40 <userret+0xab0>
    80005126:	ffffb097          	auipc	ra,0xffffb
    8000512a:	42e080e7          	jalr	1070(ra) # 80000554 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000512e:	874a                	mv	a4,s2
    80005130:	009c86bb          	addw	a3,s9,s1
    80005134:	4581                	li	a1,0
    80005136:	8556                	mv	a0,s5
    80005138:	fffff097          	auipc	ra,0xfffff
    8000513c:	b4a080e7          	jalr	-1206(ra) # 80003c82 <readi>
    80005140:	2501                	sext.w	a0,a0
    80005142:	10a91863          	bne	s2,a0,80005252 <exec+0x23c>
  for(i = 0; i < sz; i += PGSIZE){
    80005146:	009d84bb          	addw	s1,s11,s1
    8000514a:	013d09bb          	addw	s3,s10,s3
    8000514e:	0374f263          	bgeu	s1,s7,80005172 <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    80005152:	02049593          	slli	a1,s1,0x20
    80005156:	9181                	srli	a1,a1,0x20
    80005158:	95e2                	add	a1,a1,s8
    8000515a:	855a                	mv	a0,s6
    8000515c:	ffffc097          	auipc	ra,0xffffc
    80005160:	00c080e7          	jalr	12(ra) # 80001168 <walkaddr>
    80005164:	862a                	mv	a2,a0
    if(pa == 0)
    80005166:	dd45                	beqz	a0,8000511e <exec+0x108>
      n = PGSIZE;
    80005168:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000516a:	fd49f2e3          	bgeu	s3,s4,8000512e <exec+0x118>
      n = sz - i;
    8000516e:	894e                	mv	s2,s3
    80005170:	bf7d                	j	8000512e <exec+0x118>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005172:	e0843783          	ld	a5,-504(s0)
    80005176:	0017869b          	addiw	a3,a5,1
    8000517a:	e0d43423          	sd	a3,-504(s0)
    8000517e:	e0043783          	ld	a5,-512(s0)
    80005182:	0387879b          	addiw	a5,a5,56
    80005186:	e8045703          	lhu	a4,-384(s0)
    8000518a:	08e6d063          	bge	a3,a4,8000520a <exec+0x1f4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000518e:	2781                	sext.w	a5,a5
    80005190:	e0f43023          	sd	a5,-512(s0)
    80005194:	03800713          	li	a4,56
    80005198:	86be                	mv	a3,a5
    8000519a:	e1040613          	addi	a2,s0,-496
    8000519e:	4581                	li	a1,0
    800051a0:	8556                	mv	a0,s5
    800051a2:	fffff097          	auipc	ra,0xfffff
    800051a6:	ae0080e7          	jalr	-1312(ra) # 80003c82 <readi>
    800051aa:	03800793          	li	a5,56
    800051ae:	0af51263          	bne	a0,a5,80005252 <exec+0x23c>
    if(ph.type != ELF_PROG_LOAD)
    800051b2:	e1042783          	lw	a5,-496(s0)
    800051b6:	4705                	li	a4,1
    800051b8:	fae79de3          	bne	a5,a4,80005172 <exec+0x15c>
    if(ph.memsz < ph.filesz)
    800051bc:	e3843603          	ld	a2,-456(s0)
    800051c0:	e3043783          	ld	a5,-464(s0)
    800051c4:	08f66763          	bltu	a2,a5,80005252 <exec+0x23c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051c8:	e2043783          	ld	a5,-480(s0)
    800051cc:	963e                	add	a2,a2,a5
    800051ce:	08f66263          	bltu	a2,a5,80005252 <exec+0x23c>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051d2:	df843583          	ld	a1,-520(s0)
    800051d6:	855a                	mv	a0,s6
    800051d8:	ffffc097          	auipc	ra,0xffffc
    800051dc:	398080e7          	jalr	920(ra) # 80001570 <uvmalloc>
    800051e0:	dea43c23          	sd	a0,-520(s0)
    800051e4:	c53d                	beqz	a0,80005252 <exec+0x23c>
    if(ph.vaddr % PGSIZE != 0)
    800051e6:	e2043c03          	ld	s8,-480(s0)
    800051ea:	de043783          	ld	a5,-544(s0)
    800051ee:	00fc77b3          	and	a5,s8,a5
    800051f2:	e3a5                	bnez	a5,80005252 <exec+0x23c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051f4:	e1842c83          	lw	s9,-488(s0)
    800051f8:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051fc:	f60b8be3          	beqz	s7,80005172 <exec+0x15c>
    80005200:	89de                	mv	s3,s7
    80005202:	4481                	li	s1,0
    80005204:	b7b9                	j	80005152 <exec+0x13c>
  sz = 0;
    80005206:	de043c23          	sd	zero,-520(s0)
  iunlockput(ip);
    8000520a:	8556                	mv	a0,s5
    8000520c:	fffff097          	auipc	ra,0xfffff
    80005210:	a24080e7          	jalr	-1500(ra) # 80003c30 <iunlockput>
  end_op(ROOTDEV);
    80005214:	4501                	li	a0,0
    80005216:	fffff097          	auipc	ra,0xfffff
    8000521a:	26a080e7          	jalr	618(ra) # 80004480 <end_op>
  p = myproc();
    8000521e:	ffffd097          	auipc	ra,0xffffd
    80005222:	840080e7          	jalr	-1984(ra) # 80001a5e <myproc>
    80005226:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005228:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    8000522c:	6585                	lui	a1,0x1
    8000522e:	15fd                	addi	a1,a1,-1
    80005230:	df843783          	ld	a5,-520(s0)
    80005234:	95be                	add	a1,a1,a5
    80005236:	77fd                	lui	a5,0xfffff
    80005238:	8dfd                	and	a1,a1,a5
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000523a:	6609                	lui	a2,0x2
    8000523c:	962e                	add	a2,a2,a1
    8000523e:	855a                	mv	a0,s6
    80005240:	ffffc097          	auipc	ra,0xffffc
    80005244:	330080e7          	jalr	816(ra) # 80001570 <uvmalloc>
    80005248:	892a                	mv	s2,a0
    8000524a:	dea43c23          	sd	a0,-520(s0)
  ip = 0;
    8000524e:	4a81                	li	s5,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005250:	ed01                	bnez	a0,80005268 <exec+0x252>
    proc_freepagetable(pagetable, sz);
    80005252:	df843583          	ld	a1,-520(s0)
    80005256:	855a                	mv	a0,s6
    80005258:	ffffd097          	auipc	ra,0xffffd
    8000525c:	9fc080e7          	jalr	-1540(ra) # 80001c54 <proc_freepagetable>
  if(ip){
    80005260:	e40a90e3          	bnez	s5,800050a0 <exec+0x8a>
  return -1;
    80005264:	557d                	li	a0,-1
    80005266:	bd81                	j	800050b6 <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005268:	75f9                	lui	a1,0xffffe
    8000526a:	95aa                	add	a1,a1,a0
    8000526c:	855a                	mv	a0,s6
    8000526e:	ffffc097          	auipc	ra,0xffffc
    80005272:	4aa080e7          	jalr	1194(ra) # 80001718 <uvmclear>
  stackbase = sp - PGSIZE;
    80005276:	7c7d                	lui	s8,0xfffff
    80005278:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    8000527a:	df043783          	ld	a5,-528(s0)
    8000527e:	6388                	ld	a0,0(a5)
    80005280:	c52d                	beqz	a0,800052ea <exec+0x2d4>
    80005282:	e8840993          	addi	s3,s0,-376
    80005286:	f8840a93          	addi	s5,s0,-120
    8000528a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000528c:	ffffc097          	auipc	ra,0xffffc
    80005290:	c66080e7          	jalr	-922(ra) # 80000ef2 <strlen>
    80005294:	0015079b          	addiw	a5,a0,1
    80005298:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000529c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800052a0:	0f896b63          	bltu	s2,s8,80005396 <exec+0x380>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052a4:	df043d03          	ld	s10,-528(s0)
    800052a8:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7ffcafa4>
    800052ac:	8552                	mv	a0,s4
    800052ae:	ffffc097          	auipc	ra,0xffffc
    800052b2:	c44080e7          	jalr	-956(ra) # 80000ef2 <strlen>
    800052b6:	0015069b          	addiw	a3,a0,1
    800052ba:	8652                	mv	a2,s4
    800052bc:	85ca                	mv	a1,s2
    800052be:	855a                	mv	a0,s6
    800052c0:	ffffc097          	auipc	ra,0xffffc
    800052c4:	48a080e7          	jalr	1162(ra) # 8000174a <copyout>
    800052c8:	0c054963          	bltz	a0,8000539a <exec+0x384>
    ustack[argc] = sp;
    800052cc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800052d0:	0485                	addi	s1,s1,1
    800052d2:	008d0793          	addi	a5,s10,8
    800052d6:	def43823          	sd	a5,-528(s0)
    800052da:	008d3503          	ld	a0,8(s10)
    800052de:	c909                	beqz	a0,800052f0 <exec+0x2da>
    if(argc >= MAXARG)
    800052e0:	09a1                	addi	s3,s3,8
    800052e2:	fb3a95e3          	bne	s5,s3,8000528c <exec+0x276>
  ip = 0;
    800052e6:	4a81                	li	s5,0
    800052e8:	b7ad                	j	80005252 <exec+0x23c>
  sp = sz;
    800052ea:	df843903          	ld	s2,-520(s0)
  for(argc = 0; argv[argc]; argc++) {
    800052ee:	4481                	li	s1,0
  ustack[argc] = 0;
    800052f0:	00349793          	slli	a5,s1,0x3
    800052f4:	f9040713          	addi	a4,s0,-112
    800052f8:	97ba                	add	a5,a5,a4
    800052fa:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcae9c>
  sp -= (argc+1) * sizeof(uint64);
    800052fe:	00148693          	addi	a3,s1,1
    80005302:	068e                	slli	a3,a3,0x3
    80005304:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005308:	ff097913          	andi	s2,s2,-16
  ip = 0;
    8000530c:	4a81                	li	s5,0
  if(sp < stackbase)
    8000530e:	f58962e3          	bltu	s2,s8,80005252 <exec+0x23c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005312:	e8840613          	addi	a2,s0,-376
    80005316:	85ca                	mv	a1,s2
    80005318:	855a                	mv	a0,s6
    8000531a:	ffffc097          	auipc	ra,0xffffc
    8000531e:	430080e7          	jalr	1072(ra) # 8000174a <copyout>
    80005322:	06054e63          	bltz	a0,8000539e <exec+0x388>
  p->tf->a1 = sp;
    80005326:	060bb783          	ld	a5,96(s7)
    8000532a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000532e:	de843783          	ld	a5,-536(s0)
    80005332:	0007c703          	lbu	a4,0(a5)
    80005336:	cf11                	beqz	a4,80005352 <exec+0x33c>
    80005338:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000533a:	02f00693          	li	a3,47
    8000533e:	a039                	j	8000534c <exec+0x336>
      last = s+1;
    80005340:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005344:	0785                	addi	a5,a5,1
    80005346:	fff7c703          	lbu	a4,-1(a5)
    8000534a:	c701                	beqz	a4,80005352 <exec+0x33c>
    if(*s == '/')
    8000534c:	fed71ce3          	bne	a4,a3,80005344 <exec+0x32e>
    80005350:	bfc5                	j	80005340 <exec+0x32a>
  safestrcpy(p->name, last, sizeof(p->name));
    80005352:	4641                	li	a2,16
    80005354:	de843583          	ld	a1,-536(s0)
    80005358:	160b8513          	addi	a0,s7,352
    8000535c:	ffffc097          	auipc	ra,0xffffc
    80005360:	b64080e7          	jalr	-1180(ra) # 80000ec0 <safestrcpy>
  oldpagetable = p->pagetable;
    80005364:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80005368:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    8000536c:	df843783          	ld	a5,-520(s0)
    80005370:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80005374:	060bb783          	ld	a5,96(s7)
    80005378:	e6043703          	ld	a4,-416(s0)
    8000537c:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    8000537e:	060bb783          	ld	a5,96(s7)
    80005382:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005386:	85e6                	mv	a1,s9
    80005388:	ffffd097          	auipc	ra,0xffffd
    8000538c:	8cc080e7          	jalr	-1844(ra) # 80001c54 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005390:	0004851b          	sext.w	a0,s1
    80005394:	b30d                	j	800050b6 <exec+0xa0>
  ip = 0;
    80005396:	4a81                	li	s5,0
    80005398:	bd6d                	j	80005252 <exec+0x23c>
    8000539a:	4a81                	li	s5,0
    8000539c:	bd5d                	j	80005252 <exec+0x23c>
    8000539e:	4a81                	li	s5,0
    800053a0:	bd4d                	j	80005252 <exec+0x23c>

00000000800053a2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800053a2:	7179                	addi	sp,sp,-48
    800053a4:	f406                	sd	ra,40(sp)
    800053a6:	f022                	sd	s0,32(sp)
    800053a8:	ec26                	sd	s1,24(sp)
    800053aa:	e84a                	sd	s2,16(sp)
    800053ac:	1800                	addi	s0,sp,48
    800053ae:	892e                	mv	s2,a1
    800053b0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800053b2:	fdc40593          	addi	a1,s0,-36
    800053b6:	ffffe097          	auipc	ra,0xffffe
    800053ba:	ac8080e7          	jalr	-1336(ra) # 80002e7e <argint>
    800053be:	04054063          	bltz	a0,800053fe <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800053c2:	fdc42703          	lw	a4,-36(s0)
    800053c6:	47bd                	li	a5,15
    800053c8:	02e7ed63          	bltu	a5,a4,80005402 <argfd+0x60>
    800053cc:	ffffc097          	auipc	ra,0xffffc
    800053d0:	692080e7          	jalr	1682(ra) # 80001a5e <myproc>
    800053d4:	fdc42703          	lw	a4,-36(s0)
    800053d8:	01a70793          	addi	a5,a4,26
    800053dc:	078e                	slli	a5,a5,0x3
    800053de:	953e                	add	a0,a0,a5
    800053e0:	651c                	ld	a5,8(a0)
    800053e2:	c395                	beqz	a5,80005406 <argfd+0x64>
    return -1;
  if(pfd)
    800053e4:	00090463          	beqz	s2,800053ec <argfd+0x4a>
    *pfd = fd;
    800053e8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800053ec:	4501                	li	a0,0
  if(pf)
    800053ee:	c091                	beqz	s1,800053f2 <argfd+0x50>
    *pf = f;
    800053f0:	e09c                	sd	a5,0(s1)
}
    800053f2:	70a2                	ld	ra,40(sp)
    800053f4:	7402                	ld	s0,32(sp)
    800053f6:	64e2                	ld	s1,24(sp)
    800053f8:	6942                	ld	s2,16(sp)
    800053fa:	6145                	addi	sp,sp,48
    800053fc:	8082                	ret
    return -1;
    800053fe:	557d                	li	a0,-1
    80005400:	bfcd                	j	800053f2 <argfd+0x50>
    return -1;
    80005402:	557d                	li	a0,-1
    80005404:	b7fd                	j	800053f2 <argfd+0x50>
    80005406:	557d                	li	a0,-1
    80005408:	b7ed                	j	800053f2 <argfd+0x50>

000000008000540a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000540a:	1101                	addi	sp,sp,-32
    8000540c:	ec06                	sd	ra,24(sp)
    8000540e:	e822                	sd	s0,16(sp)
    80005410:	e426                	sd	s1,8(sp)
    80005412:	1000                	addi	s0,sp,32
    80005414:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005416:	ffffc097          	auipc	ra,0xffffc
    8000541a:	648080e7          	jalr	1608(ra) # 80001a5e <myproc>
    8000541e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005420:	0d850793          	addi	a5,a0,216
    80005424:	4501                	li	a0,0
    80005426:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005428:	6398                	ld	a4,0(a5)
    8000542a:	cb19                	beqz	a4,80005440 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000542c:	2505                	addiw	a0,a0,1
    8000542e:	07a1                	addi	a5,a5,8
    80005430:	fed51ce3          	bne	a0,a3,80005428 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005434:	557d                	li	a0,-1
}
    80005436:	60e2                	ld	ra,24(sp)
    80005438:	6442                	ld	s0,16(sp)
    8000543a:	64a2                	ld	s1,8(sp)
    8000543c:	6105                	addi	sp,sp,32
    8000543e:	8082                	ret
      p->ofile[fd] = f;
    80005440:	01a50793          	addi	a5,a0,26
    80005444:	078e                	slli	a5,a5,0x3
    80005446:	963e                	add	a2,a2,a5
    80005448:	e604                	sd	s1,8(a2)
      return fd;
    8000544a:	b7f5                	j	80005436 <fdalloc+0x2c>

000000008000544c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000544c:	715d                	addi	sp,sp,-80
    8000544e:	e486                	sd	ra,72(sp)
    80005450:	e0a2                	sd	s0,64(sp)
    80005452:	fc26                	sd	s1,56(sp)
    80005454:	f84a                	sd	s2,48(sp)
    80005456:	f44e                	sd	s3,40(sp)
    80005458:	f052                	sd	s4,32(sp)
    8000545a:	ec56                	sd	s5,24(sp)
    8000545c:	0880                	addi	s0,sp,80
    8000545e:	89ae                	mv	s3,a1
    80005460:	8ab2                	mv	s5,a2
    80005462:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005464:	fb040593          	addi	a1,s0,-80
    80005468:	fffff097          	auipc	ra,0xfffff
    8000546c:	d32080e7          	jalr	-718(ra) # 8000419a <nameiparent>
    80005470:	892a                	mv	s2,a0
    80005472:	12050e63          	beqz	a0,800055ae <create+0x162>
    return 0;

  ilock(dp);
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	57c080e7          	jalr	1404(ra) # 800039f2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000547e:	4601                	li	a2,0
    80005480:	fb040593          	addi	a1,s0,-80
    80005484:	854a                	mv	a0,s2
    80005486:	fffff097          	auipc	ra,0xfffff
    8000548a:	a24080e7          	jalr	-1500(ra) # 80003eaa <dirlookup>
    8000548e:	84aa                	mv	s1,a0
    80005490:	c921                	beqz	a0,800054e0 <create+0x94>
    iunlockput(dp);
    80005492:	854a                	mv	a0,s2
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	79c080e7          	jalr	1948(ra) # 80003c30 <iunlockput>
    ilock(ip);
    8000549c:	8526                	mv	a0,s1
    8000549e:	ffffe097          	auipc	ra,0xffffe
    800054a2:	554080e7          	jalr	1364(ra) # 800039f2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800054a6:	2981                	sext.w	s3,s3
    800054a8:	4789                	li	a5,2
    800054aa:	02f99463          	bne	s3,a5,800054d2 <create+0x86>
    800054ae:	04c4d783          	lhu	a5,76(s1)
    800054b2:	37f9                	addiw	a5,a5,-2
    800054b4:	17c2                	slli	a5,a5,0x30
    800054b6:	93c1                	srli	a5,a5,0x30
    800054b8:	4705                	li	a4,1
    800054ba:	00f76c63          	bltu	a4,a5,800054d2 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800054be:	8526                	mv	a0,s1
    800054c0:	60a6                	ld	ra,72(sp)
    800054c2:	6406                	ld	s0,64(sp)
    800054c4:	74e2                	ld	s1,56(sp)
    800054c6:	7942                	ld	s2,48(sp)
    800054c8:	79a2                	ld	s3,40(sp)
    800054ca:	7a02                	ld	s4,32(sp)
    800054cc:	6ae2                	ld	s5,24(sp)
    800054ce:	6161                	addi	sp,sp,80
    800054d0:	8082                	ret
    iunlockput(ip);
    800054d2:	8526                	mv	a0,s1
    800054d4:	ffffe097          	auipc	ra,0xffffe
    800054d8:	75c080e7          	jalr	1884(ra) # 80003c30 <iunlockput>
    return 0;
    800054dc:	4481                	li	s1,0
    800054de:	b7c5                	j	800054be <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800054e0:	85ce                	mv	a1,s3
    800054e2:	00092503          	lw	a0,0(s2)
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	374080e7          	jalr	884(ra) # 8000385a <ialloc>
    800054ee:	84aa                	mv	s1,a0
    800054f0:	c521                	beqz	a0,80005538 <create+0xec>
  ilock(ip);
    800054f2:	ffffe097          	auipc	ra,0xffffe
    800054f6:	500080e7          	jalr	1280(ra) # 800039f2 <ilock>
  ip->major = major;
    800054fa:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    800054fe:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    80005502:	4a05                	li	s4,1
    80005504:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    80005508:	8526                	mv	a0,s1
    8000550a:	ffffe097          	auipc	ra,0xffffe
    8000550e:	41e080e7          	jalr	1054(ra) # 80003928 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005512:	2981                	sext.w	s3,s3
    80005514:	03498a63          	beq	s3,s4,80005548 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005518:	40d0                	lw	a2,4(s1)
    8000551a:	fb040593          	addi	a1,s0,-80
    8000551e:	854a                	mv	a0,s2
    80005520:	fffff097          	auipc	ra,0xfffff
    80005524:	b9a080e7          	jalr	-1126(ra) # 800040ba <dirlink>
    80005528:	06054b63          	bltz	a0,8000559e <create+0x152>
  iunlockput(dp);
    8000552c:	854a                	mv	a0,s2
    8000552e:	ffffe097          	auipc	ra,0xffffe
    80005532:	702080e7          	jalr	1794(ra) # 80003c30 <iunlockput>
  return ip;
    80005536:	b761                	j	800054be <create+0x72>
    panic("create: ialloc");
    80005538:	00003517          	auipc	a0,0x3
    8000553c:	62850513          	addi	a0,a0,1576 # 80008b60 <userret+0xad0>
    80005540:	ffffb097          	auipc	ra,0xffffb
    80005544:	014080e7          	jalr	20(ra) # 80000554 <panic>
    dp->nlink++;  // for ".."
    80005548:	05295783          	lhu	a5,82(s2)
    8000554c:	2785                	addiw	a5,a5,1
    8000554e:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    80005552:	854a                	mv	a0,s2
    80005554:	ffffe097          	auipc	ra,0xffffe
    80005558:	3d4080e7          	jalr	980(ra) # 80003928 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000555c:	40d0                	lw	a2,4(s1)
    8000555e:	00003597          	auipc	a1,0x3
    80005562:	61258593          	addi	a1,a1,1554 # 80008b70 <userret+0xae0>
    80005566:	8526                	mv	a0,s1
    80005568:	fffff097          	auipc	ra,0xfffff
    8000556c:	b52080e7          	jalr	-1198(ra) # 800040ba <dirlink>
    80005570:	00054f63          	bltz	a0,8000558e <create+0x142>
    80005574:	00492603          	lw	a2,4(s2)
    80005578:	00003597          	auipc	a1,0x3
    8000557c:	60058593          	addi	a1,a1,1536 # 80008b78 <userret+0xae8>
    80005580:	8526                	mv	a0,s1
    80005582:	fffff097          	auipc	ra,0xfffff
    80005586:	b38080e7          	jalr	-1224(ra) # 800040ba <dirlink>
    8000558a:	f80557e3          	bgez	a0,80005518 <create+0xcc>
      panic("create dots");
    8000558e:	00003517          	auipc	a0,0x3
    80005592:	5f250513          	addi	a0,a0,1522 # 80008b80 <userret+0xaf0>
    80005596:	ffffb097          	auipc	ra,0xffffb
    8000559a:	fbe080e7          	jalr	-66(ra) # 80000554 <panic>
    panic("create: dirlink");
    8000559e:	00003517          	auipc	a0,0x3
    800055a2:	5f250513          	addi	a0,a0,1522 # 80008b90 <userret+0xb00>
    800055a6:	ffffb097          	auipc	ra,0xffffb
    800055aa:	fae080e7          	jalr	-82(ra) # 80000554 <panic>
    return 0;
    800055ae:	84aa                	mv	s1,a0
    800055b0:	b739                	j	800054be <create+0x72>

00000000800055b2 <sys_dup>:
{
    800055b2:	7179                	addi	sp,sp,-48
    800055b4:	f406                	sd	ra,40(sp)
    800055b6:	f022                	sd	s0,32(sp)
    800055b8:	ec26                	sd	s1,24(sp)
    800055ba:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800055bc:	fd840613          	addi	a2,s0,-40
    800055c0:	4581                	li	a1,0
    800055c2:	4501                	li	a0,0
    800055c4:	00000097          	auipc	ra,0x0
    800055c8:	dde080e7          	jalr	-546(ra) # 800053a2 <argfd>
    return -1;
    800055cc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800055ce:	02054363          	bltz	a0,800055f4 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800055d2:	fd843503          	ld	a0,-40(s0)
    800055d6:	00000097          	auipc	ra,0x0
    800055da:	e34080e7          	jalr	-460(ra) # 8000540a <fdalloc>
    800055de:	84aa                	mv	s1,a0
    return -1;
    800055e0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800055e2:	00054963          	bltz	a0,800055f4 <sys_dup+0x42>
  filedup(f);
    800055e6:	fd843503          	ld	a0,-40(s0)
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	334080e7          	jalr	820(ra) # 8000491e <filedup>
  return fd;
    800055f2:	87a6                	mv	a5,s1
}
    800055f4:	853e                	mv	a0,a5
    800055f6:	70a2                	ld	ra,40(sp)
    800055f8:	7402                	ld	s0,32(sp)
    800055fa:	64e2                	ld	s1,24(sp)
    800055fc:	6145                	addi	sp,sp,48
    800055fe:	8082                	ret

0000000080005600 <sys_read>:
{
    80005600:	7179                	addi	sp,sp,-48
    80005602:	f406                	sd	ra,40(sp)
    80005604:	f022                	sd	s0,32(sp)
    80005606:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005608:	fe840613          	addi	a2,s0,-24
    8000560c:	4581                	li	a1,0
    8000560e:	4501                	li	a0,0
    80005610:	00000097          	auipc	ra,0x0
    80005614:	d92080e7          	jalr	-622(ra) # 800053a2 <argfd>
    return -1;
    80005618:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000561a:	04054163          	bltz	a0,8000565c <sys_read+0x5c>
    8000561e:	fe440593          	addi	a1,s0,-28
    80005622:	4509                	li	a0,2
    80005624:	ffffe097          	auipc	ra,0xffffe
    80005628:	85a080e7          	jalr	-1958(ra) # 80002e7e <argint>
    return -1;
    8000562c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000562e:	02054763          	bltz	a0,8000565c <sys_read+0x5c>
    80005632:	fd840593          	addi	a1,s0,-40
    80005636:	4505                	li	a0,1
    80005638:	ffffe097          	auipc	ra,0xffffe
    8000563c:	868080e7          	jalr	-1944(ra) # 80002ea0 <argaddr>
    return -1;
    80005640:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005642:	00054d63          	bltz	a0,8000565c <sys_read+0x5c>
  return fileread(f, p, n);
    80005646:	fe442603          	lw	a2,-28(s0)
    8000564a:	fd843583          	ld	a1,-40(s0)
    8000564e:	fe843503          	ld	a0,-24(s0)
    80005652:	fffff097          	auipc	ra,0xfffff
    80005656:	460080e7          	jalr	1120(ra) # 80004ab2 <fileread>
    8000565a:	87aa                	mv	a5,a0
}
    8000565c:	853e                	mv	a0,a5
    8000565e:	70a2                	ld	ra,40(sp)
    80005660:	7402                	ld	s0,32(sp)
    80005662:	6145                	addi	sp,sp,48
    80005664:	8082                	ret

0000000080005666 <sys_write>:
{
    80005666:	7179                	addi	sp,sp,-48
    80005668:	f406                	sd	ra,40(sp)
    8000566a:	f022                	sd	s0,32(sp)
    8000566c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000566e:	fe840613          	addi	a2,s0,-24
    80005672:	4581                	li	a1,0
    80005674:	4501                	li	a0,0
    80005676:	00000097          	auipc	ra,0x0
    8000567a:	d2c080e7          	jalr	-724(ra) # 800053a2 <argfd>
    return -1;
    8000567e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005680:	04054163          	bltz	a0,800056c2 <sys_write+0x5c>
    80005684:	fe440593          	addi	a1,s0,-28
    80005688:	4509                	li	a0,2
    8000568a:	ffffd097          	auipc	ra,0xffffd
    8000568e:	7f4080e7          	jalr	2036(ra) # 80002e7e <argint>
    return -1;
    80005692:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005694:	02054763          	bltz	a0,800056c2 <sys_write+0x5c>
    80005698:	fd840593          	addi	a1,s0,-40
    8000569c:	4505                	li	a0,1
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	802080e7          	jalr	-2046(ra) # 80002ea0 <argaddr>
    return -1;
    800056a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800056a8:	00054d63          	bltz	a0,800056c2 <sys_write+0x5c>
  return filewrite(f, p, n);
    800056ac:	fe442603          	lw	a2,-28(s0)
    800056b0:	fd843583          	ld	a1,-40(s0)
    800056b4:	fe843503          	ld	a0,-24(s0)
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	4c0080e7          	jalr	1216(ra) # 80004b78 <filewrite>
    800056c0:	87aa                	mv	a5,a0
}
    800056c2:	853e                	mv	a0,a5
    800056c4:	70a2                	ld	ra,40(sp)
    800056c6:	7402                	ld	s0,32(sp)
    800056c8:	6145                	addi	sp,sp,48
    800056ca:	8082                	ret

00000000800056cc <sys_close>:
{
    800056cc:	1101                	addi	sp,sp,-32
    800056ce:	ec06                	sd	ra,24(sp)
    800056d0:	e822                	sd	s0,16(sp)
    800056d2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800056d4:	fe040613          	addi	a2,s0,-32
    800056d8:	fec40593          	addi	a1,s0,-20
    800056dc:	4501                	li	a0,0
    800056de:	00000097          	auipc	ra,0x0
    800056e2:	cc4080e7          	jalr	-828(ra) # 800053a2 <argfd>
    return -1;
    800056e6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800056e8:	02054463          	bltz	a0,80005710 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800056ec:	ffffc097          	auipc	ra,0xffffc
    800056f0:	372080e7          	jalr	882(ra) # 80001a5e <myproc>
    800056f4:	fec42783          	lw	a5,-20(s0)
    800056f8:	07e9                	addi	a5,a5,26
    800056fa:	078e                	slli	a5,a5,0x3
    800056fc:	97aa                	add	a5,a5,a0
    800056fe:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005702:	fe043503          	ld	a0,-32(s0)
    80005706:	fffff097          	auipc	ra,0xfffff
    8000570a:	26a080e7          	jalr	618(ra) # 80004970 <fileclose>
  return 0;
    8000570e:	4781                	li	a5,0
}
    80005710:	853e                	mv	a0,a5
    80005712:	60e2                	ld	ra,24(sp)
    80005714:	6442                	ld	s0,16(sp)
    80005716:	6105                	addi	sp,sp,32
    80005718:	8082                	ret

000000008000571a <sys_fstat>:
{
    8000571a:	1101                	addi	sp,sp,-32
    8000571c:	ec06                	sd	ra,24(sp)
    8000571e:	e822                	sd	s0,16(sp)
    80005720:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005722:	fe840613          	addi	a2,s0,-24
    80005726:	4581                	li	a1,0
    80005728:	4501                	li	a0,0
    8000572a:	00000097          	auipc	ra,0x0
    8000572e:	c78080e7          	jalr	-904(ra) # 800053a2 <argfd>
    return -1;
    80005732:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005734:	02054563          	bltz	a0,8000575e <sys_fstat+0x44>
    80005738:	fe040593          	addi	a1,s0,-32
    8000573c:	4505                	li	a0,1
    8000573e:	ffffd097          	auipc	ra,0xffffd
    80005742:	762080e7          	jalr	1890(ra) # 80002ea0 <argaddr>
    return -1;
    80005746:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005748:	00054b63          	bltz	a0,8000575e <sys_fstat+0x44>
  return filestat(f, st);
    8000574c:	fe043583          	ld	a1,-32(s0)
    80005750:	fe843503          	ld	a0,-24(s0)
    80005754:	fffff097          	auipc	ra,0xfffff
    80005758:	2ec080e7          	jalr	748(ra) # 80004a40 <filestat>
    8000575c:	87aa                	mv	a5,a0
}
    8000575e:	853e                	mv	a0,a5
    80005760:	60e2                	ld	ra,24(sp)
    80005762:	6442                	ld	s0,16(sp)
    80005764:	6105                	addi	sp,sp,32
    80005766:	8082                	ret

0000000080005768 <sys_link>:
{
    80005768:	7169                	addi	sp,sp,-304
    8000576a:	f606                	sd	ra,296(sp)
    8000576c:	f222                	sd	s0,288(sp)
    8000576e:	ee26                	sd	s1,280(sp)
    80005770:	ea4a                	sd	s2,272(sp)
    80005772:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005774:	08000613          	li	a2,128
    80005778:	ed040593          	addi	a1,s0,-304
    8000577c:	4501                	li	a0,0
    8000577e:	ffffd097          	auipc	ra,0xffffd
    80005782:	744080e7          	jalr	1860(ra) # 80002ec2 <argstr>
    return -1;
    80005786:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005788:	12054363          	bltz	a0,800058ae <sys_link+0x146>
    8000578c:	08000613          	li	a2,128
    80005790:	f5040593          	addi	a1,s0,-176
    80005794:	4505                	li	a0,1
    80005796:	ffffd097          	auipc	ra,0xffffd
    8000579a:	72c080e7          	jalr	1836(ra) # 80002ec2 <argstr>
    return -1;
    8000579e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057a0:	10054763          	bltz	a0,800058ae <sys_link+0x146>
  begin_op(ROOTDEV);
    800057a4:	4501                	li	a0,0
    800057a6:	fffff097          	auipc	ra,0xfffff
    800057aa:	c30080e7          	jalr	-976(ra) # 800043d6 <begin_op>
  if((ip = namei(old)) == 0){
    800057ae:	ed040513          	addi	a0,s0,-304
    800057b2:	fffff097          	auipc	ra,0xfffff
    800057b6:	9ca080e7          	jalr	-1590(ra) # 8000417c <namei>
    800057ba:	84aa                	mv	s1,a0
    800057bc:	c559                	beqz	a0,8000584a <sys_link+0xe2>
  ilock(ip);
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	234080e7          	jalr	564(ra) # 800039f2 <ilock>
  if(ip->type == T_DIR){
    800057c6:	04c49703          	lh	a4,76(s1)
    800057ca:	4785                	li	a5,1
    800057cc:	08f70663          	beq	a4,a5,80005858 <sys_link+0xf0>
  ip->nlink++;
    800057d0:	0524d783          	lhu	a5,82(s1)
    800057d4:	2785                	addiw	a5,a5,1
    800057d6:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800057da:	8526                	mv	a0,s1
    800057dc:	ffffe097          	auipc	ra,0xffffe
    800057e0:	14c080e7          	jalr	332(ra) # 80003928 <iupdate>
  iunlock(ip);
    800057e4:	8526                	mv	a0,s1
    800057e6:	ffffe097          	auipc	ra,0xffffe
    800057ea:	2ce080e7          	jalr	718(ra) # 80003ab4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800057ee:	fd040593          	addi	a1,s0,-48
    800057f2:	f5040513          	addi	a0,s0,-176
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	9a4080e7          	jalr	-1628(ra) # 8000419a <nameiparent>
    800057fe:	892a                	mv	s2,a0
    80005800:	cd2d                	beqz	a0,8000587a <sys_link+0x112>
  ilock(dp);
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	1f0080e7          	jalr	496(ra) # 800039f2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000580a:	00092703          	lw	a4,0(s2)
    8000580e:	409c                	lw	a5,0(s1)
    80005810:	06f71063          	bne	a4,a5,80005870 <sys_link+0x108>
    80005814:	40d0                	lw	a2,4(s1)
    80005816:	fd040593          	addi	a1,s0,-48
    8000581a:	854a                	mv	a0,s2
    8000581c:	fffff097          	auipc	ra,0xfffff
    80005820:	89e080e7          	jalr	-1890(ra) # 800040ba <dirlink>
    80005824:	04054663          	bltz	a0,80005870 <sys_link+0x108>
  iunlockput(dp);
    80005828:	854a                	mv	a0,s2
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	406080e7          	jalr	1030(ra) # 80003c30 <iunlockput>
  iput(ip);
    80005832:	8526                	mv	a0,s1
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	2cc080e7          	jalr	716(ra) # 80003b00 <iput>
  end_op(ROOTDEV);
    8000583c:	4501                	li	a0,0
    8000583e:	fffff097          	auipc	ra,0xfffff
    80005842:	c42080e7          	jalr	-958(ra) # 80004480 <end_op>
  return 0;
    80005846:	4781                	li	a5,0
    80005848:	a09d                	j	800058ae <sys_link+0x146>
    end_op(ROOTDEV);
    8000584a:	4501                	li	a0,0
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	c34080e7          	jalr	-972(ra) # 80004480 <end_op>
    return -1;
    80005854:	57fd                	li	a5,-1
    80005856:	a8a1                	j	800058ae <sys_link+0x146>
    iunlockput(ip);
    80005858:	8526                	mv	a0,s1
    8000585a:	ffffe097          	auipc	ra,0xffffe
    8000585e:	3d6080e7          	jalr	982(ra) # 80003c30 <iunlockput>
    end_op(ROOTDEV);
    80005862:	4501                	li	a0,0
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	c1c080e7          	jalr	-996(ra) # 80004480 <end_op>
    return -1;
    8000586c:	57fd                	li	a5,-1
    8000586e:	a081                	j	800058ae <sys_link+0x146>
    iunlockput(dp);
    80005870:	854a                	mv	a0,s2
    80005872:	ffffe097          	auipc	ra,0xffffe
    80005876:	3be080e7          	jalr	958(ra) # 80003c30 <iunlockput>
  ilock(ip);
    8000587a:	8526                	mv	a0,s1
    8000587c:	ffffe097          	auipc	ra,0xffffe
    80005880:	176080e7          	jalr	374(ra) # 800039f2 <ilock>
  ip->nlink--;
    80005884:	0524d783          	lhu	a5,82(s1)
    80005888:	37fd                	addiw	a5,a5,-1
    8000588a:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000588e:	8526                	mv	a0,s1
    80005890:	ffffe097          	auipc	ra,0xffffe
    80005894:	098080e7          	jalr	152(ra) # 80003928 <iupdate>
  iunlockput(ip);
    80005898:	8526                	mv	a0,s1
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	396080e7          	jalr	918(ra) # 80003c30 <iunlockput>
  end_op(ROOTDEV);
    800058a2:	4501                	li	a0,0
    800058a4:	fffff097          	auipc	ra,0xfffff
    800058a8:	bdc080e7          	jalr	-1060(ra) # 80004480 <end_op>
  return -1;
    800058ac:	57fd                	li	a5,-1
}
    800058ae:	853e                	mv	a0,a5
    800058b0:	70b2                	ld	ra,296(sp)
    800058b2:	7412                	ld	s0,288(sp)
    800058b4:	64f2                	ld	s1,280(sp)
    800058b6:	6952                	ld	s2,272(sp)
    800058b8:	6155                	addi	sp,sp,304
    800058ba:	8082                	ret

00000000800058bc <sys_unlink>:
{
    800058bc:	7151                	addi	sp,sp,-240
    800058be:	f586                	sd	ra,232(sp)
    800058c0:	f1a2                	sd	s0,224(sp)
    800058c2:	eda6                	sd	s1,216(sp)
    800058c4:	e9ca                	sd	s2,208(sp)
    800058c6:	e5ce                	sd	s3,200(sp)
    800058c8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800058ca:	08000613          	li	a2,128
    800058ce:	f3040593          	addi	a1,s0,-208
    800058d2:	4501                	li	a0,0
    800058d4:	ffffd097          	auipc	ra,0xffffd
    800058d8:	5ee080e7          	jalr	1518(ra) # 80002ec2 <argstr>
    800058dc:	18054463          	bltz	a0,80005a64 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    800058e0:	4501                	li	a0,0
    800058e2:	fffff097          	auipc	ra,0xfffff
    800058e6:	af4080e7          	jalr	-1292(ra) # 800043d6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800058ea:	fb040593          	addi	a1,s0,-80
    800058ee:	f3040513          	addi	a0,s0,-208
    800058f2:	fffff097          	auipc	ra,0xfffff
    800058f6:	8a8080e7          	jalr	-1880(ra) # 8000419a <nameiparent>
    800058fa:	84aa                	mv	s1,a0
    800058fc:	cd61                	beqz	a0,800059d4 <sys_unlink+0x118>
  ilock(dp);
    800058fe:	ffffe097          	auipc	ra,0xffffe
    80005902:	0f4080e7          	jalr	244(ra) # 800039f2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005906:	00003597          	auipc	a1,0x3
    8000590a:	26a58593          	addi	a1,a1,618 # 80008b70 <userret+0xae0>
    8000590e:	fb040513          	addi	a0,s0,-80
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	57e080e7          	jalr	1406(ra) # 80003e90 <namecmp>
    8000591a:	14050c63          	beqz	a0,80005a72 <sys_unlink+0x1b6>
    8000591e:	00003597          	auipc	a1,0x3
    80005922:	25a58593          	addi	a1,a1,602 # 80008b78 <userret+0xae8>
    80005926:	fb040513          	addi	a0,s0,-80
    8000592a:	ffffe097          	auipc	ra,0xffffe
    8000592e:	566080e7          	jalr	1382(ra) # 80003e90 <namecmp>
    80005932:	14050063          	beqz	a0,80005a72 <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005936:	f2c40613          	addi	a2,s0,-212
    8000593a:	fb040593          	addi	a1,s0,-80
    8000593e:	8526                	mv	a0,s1
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	56a080e7          	jalr	1386(ra) # 80003eaa <dirlookup>
    80005948:	892a                	mv	s2,a0
    8000594a:	12050463          	beqz	a0,80005a72 <sys_unlink+0x1b6>
  ilock(ip);
    8000594e:	ffffe097          	auipc	ra,0xffffe
    80005952:	0a4080e7          	jalr	164(ra) # 800039f2 <ilock>
  if(ip->nlink < 1)
    80005956:	05291783          	lh	a5,82(s2)
    8000595a:	08f05463          	blez	a5,800059e2 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000595e:	04c91703          	lh	a4,76(s2)
    80005962:	4785                	li	a5,1
    80005964:	08f70763          	beq	a4,a5,800059f2 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005968:	4641                	li	a2,16
    8000596a:	4581                	li	a1,0
    8000596c:	fc040513          	addi	a0,s0,-64
    80005970:	ffffb097          	auipc	ra,0xffffb
    80005974:	3fe080e7          	jalr	1022(ra) # 80000d6e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005978:	4741                	li	a4,16
    8000597a:	f2c42683          	lw	a3,-212(s0)
    8000597e:	fc040613          	addi	a2,s0,-64
    80005982:	4581                	li	a1,0
    80005984:	8526                	mv	a0,s1
    80005986:	ffffe097          	auipc	ra,0xffffe
    8000598a:	3f0080e7          	jalr	1008(ra) # 80003d76 <writei>
    8000598e:	47c1                	li	a5,16
    80005990:	0af51763          	bne	a0,a5,80005a3e <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005994:	04c91703          	lh	a4,76(s2)
    80005998:	4785                	li	a5,1
    8000599a:	0af70a63          	beq	a4,a5,80005a4e <sys_unlink+0x192>
  iunlockput(dp);
    8000599e:	8526                	mv	a0,s1
    800059a0:	ffffe097          	auipc	ra,0xffffe
    800059a4:	290080e7          	jalr	656(ra) # 80003c30 <iunlockput>
  ip->nlink--;
    800059a8:	05295783          	lhu	a5,82(s2)
    800059ac:	37fd                	addiw	a5,a5,-1
    800059ae:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    800059b2:	854a                	mv	a0,s2
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	f74080e7          	jalr	-140(ra) # 80003928 <iupdate>
  iunlockput(ip);
    800059bc:	854a                	mv	a0,s2
    800059be:	ffffe097          	auipc	ra,0xffffe
    800059c2:	272080e7          	jalr	626(ra) # 80003c30 <iunlockput>
  end_op(ROOTDEV);
    800059c6:	4501                	li	a0,0
    800059c8:	fffff097          	auipc	ra,0xfffff
    800059cc:	ab8080e7          	jalr	-1352(ra) # 80004480 <end_op>
  return 0;
    800059d0:	4501                	li	a0,0
    800059d2:	a85d                	j	80005a88 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    800059d4:	4501                	li	a0,0
    800059d6:	fffff097          	auipc	ra,0xfffff
    800059da:	aaa080e7          	jalr	-1366(ra) # 80004480 <end_op>
    return -1;
    800059de:	557d                	li	a0,-1
    800059e0:	a065                	j	80005a88 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    800059e2:	00003517          	auipc	a0,0x3
    800059e6:	1be50513          	addi	a0,a0,446 # 80008ba0 <userret+0xb10>
    800059ea:	ffffb097          	auipc	ra,0xffffb
    800059ee:	b6a080e7          	jalr	-1174(ra) # 80000554 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059f2:	05492703          	lw	a4,84(s2)
    800059f6:	02000793          	li	a5,32
    800059fa:	f6e7f7e3          	bgeu	a5,a4,80005968 <sys_unlink+0xac>
    800059fe:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a02:	4741                	li	a4,16
    80005a04:	86ce                	mv	a3,s3
    80005a06:	f1840613          	addi	a2,s0,-232
    80005a0a:	4581                	li	a1,0
    80005a0c:	854a                	mv	a0,s2
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	274080e7          	jalr	628(ra) # 80003c82 <readi>
    80005a16:	47c1                	li	a5,16
    80005a18:	00f51b63          	bne	a0,a5,80005a2e <sys_unlink+0x172>
    if(de.inum != 0)
    80005a1c:	f1845783          	lhu	a5,-232(s0)
    80005a20:	e7a1                	bnez	a5,80005a68 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a22:	29c1                	addiw	s3,s3,16
    80005a24:	05492783          	lw	a5,84(s2)
    80005a28:	fcf9ede3          	bltu	s3,a5,80005a02 <sys_unlink+0x146>
    80005a2c:	bf35                	j	80005968 <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005a2e:	00003517          	auipc	a0,0x3
    80005a32:	18a50513          	addi	a0,a0,394 # 80008bb8 <userret+0xb28>
    80005a36:	ffffb097          	auipc	ra,0xffffb
    80005a3a:	b1e080e7          	jalr	-1250(ra) # 80000554 <panic>
    panic("unlink: writei");
    80005a3e:	00003517          	auipc	a0,0x3
    80005a42:	19250513          	addi	a0,a0,402 # 80008bd0 <userret+0xb40>
    80005a46:	ffffb097          	auipc	ra,0xffffb
    80005a4a:	b0e080e7          	jalr	-1266(ra) # 80000554 <panic>
    dp->nlink--;
    80005a4e:	0524d783          	lhu	a5,82(s1)
    80005a52:	37fd                	addiw	a5,a5,-1
    80005a54:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005a58:	8526                	mv	a0,s1
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	ece080e7          	jalr	-306(ra) # 80003928 <iupdate>
    80005a62:	bf35                	j	8000599e <sys_unlink+0xe2>
    return -1;
    80005a64:	557d                	li	a0,-1
    80005a66:	a00d                	j	80005a88 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005a68:	854a                	mv	a0,s2
    80005a6a:	ffffe097          	auipc	ra,0xffffe
    80005a6e:	1c6080e7          	jalr	454(ra) # 80003c30 <iunlockput>
  iunlockput(dp);
    80005a72:	8526                	mv	a0,s1
    80005a74:	ffffe097          	auipc	ra,0xffffe
    80005a78:	1bc080e7          	jalr	444(ra) # 80003c30 <iunlockput>
  end_op(ROOTDEV);
    80005a7c:	4501                	li	a0,0
    80005a7e:	fffff097          	auipc	ra,0xfffff
    80005a82:	a02080e7          	jalr	-1534(ra) # 80004480 <end_op>
  return -1;
    80005a86:	557d                	li	a0,-1
}
    80005a88:	70ae                	ld	ra,232(sp)
    80005a8a:	740e                	ld	s0,224(sp)
    80005a8c:	64ee                	ld	s1,216(sp)
    80005a8e:	694e                	ld	s2,208(sp)
    80005a90:	69ae                	ld	s3,200(sp)
    80005a92:	616d                	addi	sp,sp,240
    80005a94:	8082                	ret

0000000080005a96 <sys_open>:

uint64
sys_open(void)
{
    80005a96:	7131                	addi	sp,sp,-192
    80005a98:	fd06                	sd	ra,184(sp)
    80005a9a:	f922                	sd	s0,176(sp)
    80005a9c:	f526                	sd	s1,168(sp)
    80005a9e:	f14a                	sd	s2,160(sp)
    80005aa0:	ed4e                	sd	s3,152(sp)
    80005aa2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005aa4:	08000613          	li	a2,128
    80005aa8:	f5040593          	addi	a1,s0,-176
    80005aac:	4501                	li	a0,0
    80005aae:	ffffd097          	auipc	ra,0xffffd
    80005ab2:	414080e7          	jalr	1044(ra) # 80002ec2 <argstr>
    return -1;
    80005ab6:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005ab8:	0a054963          	bltz	a0,80005b6a <sys_open+0xd4>
    80005abc:	f4c40593          	addi	a1,s0,-180
    80005ac0:	4505                	li	a0,1
    80005ac2:	ffffd097          	auipc	ra,0xffffd
    80005ac6:	3bc080e7          	jalr	956(ra) # 80002e7e <argint>
    80005aca:	0a054063          	bltz	a0,80005b6a <sys_open+0xd4>

  begin_op(ROOTDEV);
    80005ace:	4501                	li	a0,0
    80005ad0:	fffff097          	auipc	ra,0xfffff
    80005ad4:	906080e7          	jalr	-1786(ra) # 800043d6 <begin_op>

  if(omode & O_CREATE){
    80005ad8:	f4c42783          	lw	a5,-180(s0)
    80005adc:	2007f793          	andi	a5,a5,512
    80005ae0:	c3dd                	beqz	a5,80005b86 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    80005ae2:	4681                	li	a3,0
    80005ae4:	4601                	li	a2,0
    80005ae6:	4589                	li	a1,2
    80005ae8:	f5040513          	addi	a0,s0,-176
    80005aec:	00000097          	auipc	ra,0x0
    80005af0:	960080e7          	jalr	-1696(ra) # 8000544c <create>
    80005af4:	892a                	mv	s2,a0
    if(ip == 0){
    80005af6:	c151                	beqz	a0,80005b7a <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005af8:	04c91703          	lh	a4,76(s2)
    80005afc:	478d                	li	a5,3
    80005afe:	00f71763          	bne	a4,a5,80005b0c <sys_open+0x76>
    80005b02:	04e95703          	lhu	a4,78(s2)
    80005b06:	47a5                	li	a5,9
    80005b08:	0ce7e663          	bltu	a5,a4,80005bd4 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b0c:	fffff097          	auipc	ra,0xfffff
    80005b10:	da8080e7          	jalr	-600(ra) # 800048b4 <filealloc>
    80005b14:	89aa                	mv	s3,a0
    80005b16:	c97d                	beqz	a0,80005c0c <sys_open+0x176>
    80005b18:	00000097          	auipc	ra,0x0
    80005b1c:	8f2080e7          	jalr	-1806(ra) # 8000540a <fdalloc>
    80005b20:	84aa                	mv	s1,a0
    80005b22:	0e054063          	bltz	a0,80005c02 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b26:	04c91703          	lh	a4,76(s2)
    80005b2a:	478d                	li	a5,3
    80005b2c:	0cf70063          	beq	a4,a5,80005bec <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005b30:	4789                	li	a5,2
    80005b32:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005b36:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005b3a:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005b3e:	f4c42783          	lw	a5,-180(s0)
    80005b42:	0017c713          	xori	a4,a5,1
    80005b46:	8b05                	andi	a4,a4,1
    80005b48:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b4c:	8b8d                	andi	a5,a5,3
    80005b4e:	00f037b3          	snez	a5,a5
    80005b52:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005b56:	854a                	mv	a0,s2
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	f5c080e7          	jalr	-164(ra) # 80003ab4 <iunlock>
  end_op(ROOTDEV);
    80005b60:	4501                	li	a0,0
    80005b62:	fffff097          	auipc	ra,0xfffff
    80005b66:	91e080e7          	jalr	-1762(ra) # 80004480 <end_op>

  return fd;
}
    80005b6a:	8526                	mv	a0,s1
    80005b6c:	70ea                	ld	ra,184(sp)
    80005b6e:	744a                	ld	s0,176(sp)
    80005b70:	74aa                	ld	s1,168(sp)
    80005b72:	790a                	ld	s2,160(sp)
    80005b74:	69ea                	ld	s3,152(sp)
    80005b76:	6129                	addi	sp,sp,192
    80005b78:	8082                	ret
      end_op(ROOTDEV);
    80005b7a:	4501                	li	a0,0
    80005b7c:	fffff097          	auipc	ra,0xfffff
    80005b80:	904080e7          	jalr	-1788(ra) # 80004480 <end_op>
      return -1;
    80005b84:	b7dd                	j	80005b6a <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005b86:	f5040513          	addi	a0,s0,-176
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	5f2080e7          	jalr	1522(ra) # 8000417c <namei>
    80005b92:	892a                	mv	s2,a0
    80005b94:	c90d                	beqz	a0,80005bc6 <sys_open+0x130>
    ilock(ip);
    80005b96:	ffffe097          	auipc	ra,0xffffe
    80005b9a:	e5c080e7          	jalr	-420(ra) # 800039f2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b9e:	04c91703          	lh	a4,76(s2)
    80005ba2:	4785                	li	a5,1
    80005ba4:	f4f71ae3          	bne	a4,a5,80005af8 <sys_open+0x62>
    80005ba8:	f4c42783          	lw	a5,-180(s0)
    80005bac:	d3a5                	beqz	a5,80005b0c <sys_open+0x76>
      iunlockput(ip);
    80005bae:	854a                	mv	a0,s2
    80005bb0:	ffffe097          	auipc	ra,0xffffe
    80005bb4:	080080e7          	jalr	128(ra) # 80003c30 <iunlockput>
      end_op(ROOTDEV);
    80005bb8:	4501                	li	a0,0
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	8c6080e7          	jalr	-1850(ra) # 80004480 <end_op>
      return -1;
    80005bc2:	54fd                	li	s1,-1
    80005bc4:	b75d                	j	80005b6a <sys_open+0xd4>
      end_op(ROOTDEV);
    80005bc6:	4501                	li	a0,0
    80005bc8:	fffff097          	auipc	ra,0xfffff
    80005bcc:	8b8080e7          	jalr	-1864(ra) # 80004480 <end_op>
      return -1;
    80005bd0:	54fd                	li	s1,-1
    80005bd2:	bf61                	j	80005b6a <sys_open+0xd4>
    iunlockput(ip);
    80005bd4:	854a                	mv	a0,s2
    80005bd6:	ffffe097          	auipc	ra,0xffffe
    80005bda:	05a080e7          	jalr	90(ra) # 80003c30 <iunlockput>
    end_op(ROOTDEV);
    80005bde:	4501                	li	a0,0
    80005be0:	fffff097          	auipc	ra,0xfffff
    80005be4:	8a0080e7          	jalr	-1888(ra) # 80004480 <end_op>
    return -1;
    80005be8:	54fd                	li	s1,-1
    80005bea:	b741                	j	80005b6a <sys_open+0xd4>
    f->type = FD_DEVICE;
    80005bec:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005bf0:	04e91783          	lh	a5,78(s2)
    80005bf4:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005bf8:	05091783          	lh	a5,80(s2)
    80005bfc:	02f99323          	sh	a5,38(s3)
    80005c00:	bf1d                	j	80005b36 <sys_open+0xa0>
      fileclose(f);
    80005c02:	854e                	mv	a0,s3
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	d6c080e7          	jalr	-660(ra) # 80004970 <fileclose>
    iunlockput(ip);
    80005c0c:	854a                	mv	a0,s2
    80005c0e:	ffffe097          	auipc	ra,0xffffe
    80005c12:	022080e7          	jalr	34(ra) # 80003c30 <iunlockput>
    end_op(ROOTDEV);
    80005c16:	4501                	li	a0,0
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	868080e7          	jalr	-1944(ra) # 80004480 <end_op>
    return -1;
    80005c20:	54fd                	li	s1,-1
    80005c22:	b7a1                	j	80005b6a <sys_open+0xd4>

0000000080005c24 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c24:	7175                	addi	sp,sp,-144
    80005c26:	e506                	sd	ra,136(sp)
    80005c28:	e122                	sd	s0,128(sp)
    80005c2a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005c2c:	4501                	li	a0,0
    80005c2e:	ffffe097          	auipc	ra,0xffffe
    80005c32:	7a8080e7          	jalr	1960(ra) # 800043d6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c36:	08000613          	li	a2,128
    80005c3a:	f7040593          	addi	a1,s0,-144
    80005c3e:	4501                	li	a0,0
    80005c40:	ffffd097          	auipc	ra,0xffffd
    80005c44:	282080e7          	jalr	642(ra) # 80002ec2 <argstr>
    80005c48:	02054a63          	bltz	a0,80005c7c <sys_mkdir+0x58>
    80005c4c:	4681                	li	a3,0
    80005c4e:	4601                	li	a2,0
    80005c50:	4585                	li	a1,1
    80005c52:	f7040513          	addi	a0,s0,-144
    80005c56:	fffff097          	auipc	ra,0xfffff
    80005c5a:	7f6080e7          	jalr	2038(ra) # 8000544c <create>
    80005c5e:	cd19                	beqz	a0,80005c7c <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005c60:	ffffe097          	auipc	ra,0xffffe
    80005c64:	fd0080e7          	jalr	-48(ra) # 80003c30 <iunlockput>
  end_op(ROOTDEV);
    80005c68:	4501                	li	a0,0
    80005c6a:	fffff097          	auipc	ra,0xfffff
    80005c6e:	816080e7          	jalr	-2026(ra) # 80004480 <end_op>
  return 0;
    80005c72:	4501                	li	a0,0
}
    80005c74:	60aa                	ld	ra,136(sp)
    80005c76:	640a                	ld	s0,128(sp)
    80005c78:	6149                	addi	sp,sp,144
    80005c7a:	8082                	ret
    end_op(ROOTDEV);
    80005c7c:	4501                	li	a0,0
    80005c7e:	fffff097          	auipc	ra,0xfffff
    80005c82:	802080e7          	jalr	-2046(ra) # 80004480 <end_op>
    return -1;
    80005c86:	557d                	li	a0,-1
    80005c88:	b7f5                	j	80005c74 <sys_mkdir+0x50>

0000000080005c8a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c8a:	7135                	addi	sp,sp,-160
    80005c8c:	ed06                	sd	ra,152(sp)
    80005c8e:	e922                	sd	s0,144(sp)
    80005c90:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005c92:	4501                	li	a0,0
    80005c94:	ffffe097          	auipc	ra,0xffffe
    80005c98:	742080e7          	jalr	1858(ra) # 800043d6 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c9c:	08000613          	li	a2,128
    80005ca0:	f7040593          	addi	a1,s0,-144
    80005ca4:	4501                	li	a0,0
    80005ca6:	ffffd097          	auipc	ra,0xffffd
    80005caa:	21c080e7          	jalr	540(ra) # 80002ec2 <argstr>
    80005cae:	04054b63          	bltz	a0,80005d04 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80005cb2:	f6c40593          	addi	a1,s0,-148
    80005cb6:	4505                	li	a0,1
    80005cb8:	ffffd097          	auipc	ra,0xffffd
    80005cbc:	1c6080e7          	jalr	454(ra) # 80002e7e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005cc0:	04054263          	bltz	a0,80005d04 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005cc4:	f6840593          	addi	a1,s0,-152
    80005cc8:	4509                	li	a0,2
    80005cca:	ffffd097          	auipc	ra,0xffffd
    80005cce:	1b4080e7          	jalr	436(ra) # 80002e7e <argint>
     argint(1, &major) < 0 ||
    80005cd2:	02054963          	bltz	a0,80005d04 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005cd6:	f6841683          	lh	a3,-152(s0)
    80005cda:	f6c41603          	lh	a2,-148(s0)
    80005cde:	458d                	li	a1,3
    80005ce0:	f7040513          	addi	a0,s0,-144
    80005ce4:	fffff097          	auipc	ra,0xfffff
    80005ce8:	768080e7          	jalr	1896(ra) # 8000544c <create>
     argint(2, &minor) < 0 ||
    80005cec:	cd01                	beqz	a0,80005d04 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005cee:	ffffe097          	auipc	ra,0xffffe
    80005cf2:	f42080e7          	jalr	-190(ra) # 80003c30 <iunlockput>
  end_op(ROOTDEV);
    80005cf6:	4501                	li	a0,0
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	788080e7          	jalr	1928(ra) # 80004480 <end_op>
  return 0;
    80005d00:	4501                	li	a0,0
    80005d02:	a039                	j	80005d10 <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005d04:	4501                	li	a0,0
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	77a080e7          	jalr	1914(ra) # 80004480 <end_op>
    return -1;
    80005d0e:	557d                	li	a0,-1
}
    80005d10:	60ea                	ld	ra,152(sp)
    80005d12:	644a                	ld	s0,144(sp)
    80005d14:	610d                	addi	sp,sp,160
    80005d16:	8082                	ret

0000000080005d18 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d18:	7135                	addi	sp,sp,-160
    80005d1a:	ed06                	sd	ra,152(sp)
    80005d1c:	e922                	sd	s0,144(sp)
    80005d1e:	e526                	sd	s1,136(sp)
    80005d20:	e14a                	sd	s2,128(sp)
    80005d22:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d24:	ffffc097          	auipc	ra,0xffffc
    80005d28:	d3a080e7          	jalr	-710(ra) # 80001a5e <myproc>
    80005d2c:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005d2e:	4501                	li	a0,0
    80005d30:	ffffe097          	auipc	ra,0xffffe
    80005d34:	6a6080e7          	jalr	1702(ra) # 800043d6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d38:	08000613          	li	a2,128
    80005d3c:	f6040593          	addi	a1,s0,-160
    80005d40:	4501                	li	a0,0
    80005d42:	ffffd097          	auipc	ra,0xffffd
    80005d46:	180080e7          	jalr	384(ra) # 80002ec2 <argstr>
    80005d4a:	04054c63          	bltz	a0,80005da2 <sys_chdir+0x8a>
    80005d4e:	f6040513          	addi	a0,s0,-160
    80005d52:	ffffe097          	auipc	ra,0xffffe
    80005d56:	42a080e7          	jalr	1066(ra) # 8000417c <namei>
    80005d5a:	84aa                	mv	s1,a0
    80005d5c:	c139                	beqz	a0,80005da2 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005d5e:	ffffe097          	auipc	ra,0xffffe
    80005d62:	c94080e7          	jalr	-876(ra) # 800039f2 <ilock>
  if(ip->type != T_DIR){
    80005d66:	04c49703          	lh	a4,76(s1)
    80005d6a:	4785                	li	a5,1
    80005d6c:	04f71263          	bne	a4,a5,80005db0 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005d70:	8526                	mv	a0,s1
    80005d72:	ffffe097          	auipc	ra,0xffffe
    80005d76:	d42080e7          	jalr	-702(ra) # 80003ab4 <iunlock>
  iput(p->cwd);
    80005d7a:	15893503          	ld	a0,344(s2)
    80005d7e:	ffffe097          	auipc	ra,0xffffe
    80005d82:	d82080e7          	jalr	-638(ra) # 80003b00 <iput>
  end_op(ROOTDEV);
    80005d86:	4501                	li	a0,0
    80005d88:	ffffe097          	auipc	ra,0xffffe
    80005d8c:	6f8080e7          	jalr	1784(ra) # 80004480 <end_op>
  p->cwd = ip;
    80005d90:	14993c23          	sd	s1,344(s2)
  return 0;
    80005d94:	4501                	li	a0,0
}
    80005d96:	60ea                	ld	ra,152(sp)
    80005d98:	644a                	ld	s0,144(sp)
    80005d9a:	64aa                	ld	s1,136(sp)
    80005d9c:	690a                	ld	s2,128(sp)
    80005d9e:	610d                	addi	sp,sp,160
    80005da0:	8082                	ret
    end_op(ROOTDEV);
    80005da2:	4501                	li	a0,0
    80005da4:	ffffe097          	auipc	ra,0xffffe
    80005da8:	6dc080e7          	jalr	1756(ra) # 80004480 <end_op>
    return -1;
    80005dac:	557d                	li	a0,-1
    80005dae:	b7e5                	j	80005d96 <sys_chdir+0x7e>
    iunlockput(ip);
    80005db0:	8526                	mv	a0,s1
    80005db2:	ffffe097          	auipc	ra,0xffffe
    80005db6:	e7e080e7          	jalr	-386(ra) # 80003c30 <iunlockput>
    end_op(ROOTDEV);
    80005dba:	4501                	li	a0,0
    80005dbc:	ffffe097          	auipc	ra,0xffffe
    80005dc0:	6c4080e7          	jalr	1732(ra) # 80004480 <end_op>
    return -1;
    80005dc4:	557d                	li	a0,-1
    80005dc6:	bfc1                	j	80005d96 <sys_chdir+0x7e>

0000000080005dc8 <sys_exec>:

uint64
sys_exec(void)
{
    80005dc8:	7145                	addi	sp,sp,-464
    80005dca:	e786                	sd	ra,456(sp)
    80005dcc:	e3a2                	sd	s0,448(sp)
    80005dce:	ff26                	sd	s1,440(sp)
    80005dd0:	fb4a                	sd	s2,432(sp)
    80005dd2:	f74e                	sd	s3,424(sp)
    80005dd4:	f352                	sd	s4,416(sp)
    80005dd6:	ef56                	sd	s5,408(sp)
    80005dd8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005dda:	08000613          	li	a2,128
    80005dde:	f4040593          	addi	a1,s0,-192
    80005de2:	4501                	li	a0,0
    80005de4:	ffffd097          	auipc	ra,0xffffd
    80005de8:	0de080e7          	jalr	222(ra) # 80002ec2 <argstr>
    80005dec:	0e054663          	bltz	a0,80005ed8 <sys_exec+0x110>
    80005df0:	e3840593          	addi	a1,s0,-456
    80005df4:	4505                	li	a0,1
    80005df6:	ffffd097          	auipc	ra,0xffffd
    80005dfa:	0aa080e7          	jalr	170(ra) # 80002ea0 <argaddr>
    80005dfe:	0e054763          	bltz	a0,80005eec <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005e02:	10000613          	li	a2,256
    80005e06:	4581                	li	a1,0
    80005e08:	e4040513          	addi	a0,s0,-448
    80005e0c:	ffffb097          	auipc	ra,0xffffb
    80005e10:	f62080e7          	jalr	-158(ra) # 80000d6e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e14:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e18:	89ca                	mv	s3,s2
    80005e1a:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005e1c:	02000a13          	li	s4,32
    80005e20:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e24:	00349793          	slli	a5,s1,0x3
    80005e28:	e3040593          	addi	a1,s0,-464
    80005e2c:	e3843503          	ld	a0,-456(s0)
    80005e30:	953e                	add	a0,a0,a5
    80005e32:	ffffd097          	auipc	ra,0xffffd
    80005e36:	fb2080e7          	jalr	-78(ra) # 80002de4 <fetchaddr>
    80005e3a:	02054a63          	bltz	a0,80005e6e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005e3e:	e3043783          	ld	a5,-464(s0)
    80005e42:	c7a1                	beqz	a5,80005e8a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e44:	ffffb097          	auipc	ra,0xffffb
    80005e48:	b28080e7          	jalr	-1240(ra) # 8000096c <kalloc>
    80005e4c:	85aa                	mv	a1,a0
    80005e4e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e52:	c92d                	beqz	a0,80005ec4 <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005e54:	6605                	lui	a2,0x1
    80005e56:	e3043503          	ld	a0,-464(s0)
    80005e5a:	ffffd097          	auipc	ra,0xffffd
    80005e5e:	fdc080e7          	jalr	-36(ra) # 80002e36 <fetchstr>
    80005e62:	00054663          	bltz	a0,80005e6e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005e66:	0485                	addi	s1,s1,1
    80005e68:	09a1                	addi	s3,s3,8
    80005e6a:	fb449be3          	bne	s1,s4,80005e20 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e6e:	10090493          	addi	s1,s2,256
    80005e72:	00093503          	ld	a0,0(s2)
    80005e76:	cd39                	beqz	a0,80005ed4 <sys_exec+0x10c>
    kfree(argv[i]);
    80005e78:	ffffb097          	auipc	ra,0xffffb
    80005e7c:	9f8080e7          	jalr	-1544(ra) # 80000870 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e80:	0921                	addi	s2,s2,8
    80005e82:	fe9918e3          	bne	s2,s1,80005e72 <sys_exec+0xaa>
  return -1;
    80005e86:	557d                	li	a0,-1
    80005e88:	a889                	j	80005eda <sys_exec+0x112>
      argv[i] = 0;
    80005e8a:	0a8e                	slli	s5,s5,0x3
    80005e8c:	fc040793          	addi	a5,s0,-64
    80005e90:	9abe                	add	s5,s5,a5
    80005e92:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005e96:	e4040593          	addi	a1,s0,-448
    80005e9a:	f4040513          	addi	a0,s0,-192
    80005e9e:	fffff097          	auipc	ra,0xfffff
    80005ea2:	178080e7          	jalr	376(ra) # 80005016 <exec>
    80005ea6:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ea8:	10090993          	addi	s3,s2,256
    80005eac:	00093503          	ld	a0,0(s2)
    80005eb0:	c901                	beqz	a0,80005ec0 <sys_exec+0xf8>
    kfree(argv[i]);
    80005eb2:	ffffb097          	auipc	ra,0xffffb
    80005eb6:	9be080e7          	jalr	-1602(ra) # 80000870 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eba:	0921                	addi	s2,s2,8
    80005ebc:	ff3918e3          	bne	s2,s3,80005eac <sys_exec+0xe4>
  return ret;
    80005ec0:	8526                	mv	a0,s1
    80005ec2:	a821                	j	80005eda <sys_exec+0x112>
      panic("sys_exec kalloc");
    80005ec4:	00003517          	auipc	a0,0x3
    80005ec8:	d1c50513          	addi	a0,a0,-740 # 80008be0 <userret+0xb50>
    80005ecc:	ffffa097          	auipc	ra,0xffffa
    80005ed0:	688080e7          	jalr	1672(ra) # 80000554 <panic>
  return -1;
    80005ed4:	557d                	li	a0,-1
    80005ed6:	a011                	j	80005eda <sys_exec+0x112>
    return -1;
    80005ed8:	557d                	li	a0,-1
}
    80005eda:	60be                	ld	ra,456(sp)
    80005edc:	641e                	ld	s0,448(sp)
    80005ede:	74fa                	ld	s1,440(sp)
    80005ee0:	795a                	ld	s2,432(sp)
    80005ee2:	79ba                	ld	s3,424(sp)
    80005ee4:	7a1a                	ld	s4,416(sp)
    80005ee6:	6afa                	ld	s5,408(sp)
    80005ee8:	6179                	addi	sp,sp,464
    80005eea:	8082                	ret
    return -1;
    80005eec:	557d                	li	a0,-1
    80005eee:	b7f5                	j	80005eda <sys_exec+0x112>

0000000080005ef0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ef0:	7139                	addi	sp,sp,-64
    80005ef2:	fc06                	sd	ra,56(sp)
    80005ef4:	f822                	sd	s0,48(sp)
    80005ef6:	f426                	sd	s1,40(sp)
    80005ef8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005efa:	ffffc097          	auipc	ra,0xffffc
    80005efe:	b64080e7          	jalr	-1180(ra) # 80001a5e <myproc>
    80005f02:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005f04:	fd840593          	addi	a1,s0,-40
    80005f08:	4501                	li	a0,0
    80005f0a:	ffffd097          	auipc	ra,0xffffd
    80005f0e:	f96080e7          	jalr	-106(ra) # 80002ea0 <argaddr>
    return -1;
    80005f12:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005f14:	0e054063          	bltz	a0,80005ff4 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005f18:	fc840593          	addi	a1,s0,-56
    80005f1c:	fd040513          	addi	a0,s0,-48
    80005f20:	fffff097          	auipc	ra,0xfffff
    80005f24:	db4080e7          	jalr	-588(ra) # 80004cd4 <pipealloc>
    return -1;
    80005f28:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f2a:	0c054563          	bltz	a0,80005ff4 <sys_pipe+0x104>
  fd0 = -1;
    80005f2e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f32:	fd043503          	ld	a0,-48(s0)
    80005f36:	fffff097          	auipc	ra,0xfffff
    80005f3a:	4d4080e7          	jalr	1236(ra) # 8000540a <fdalloc>
    80005f3e:	fca42223          	sw	a0,-60(s0)
    80005f42:	08054c63          	bltz	a0,80005fda <sys_pipe+0xea>
    80005f46:	fc843503          	ld	a0,-56(s0)
    80005f4a:	fffff097          	auipc	ra,0xfffff
    80005f4e:	4c0080e7          	jalr	1216(ra) # 8000540a <fdalloc>
    80005f52:	fca42023          	sw	a0,-64(s0)
    80005f56:	06054863          	bltz	a0,80005fc6 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f5a:	4691                	li	a3,4
    80005f5c:	fc440613          	addi	a2,s0,-60
    80005f60:	fd843583          	ld	a1,-40(s0)
    80005f64:	6ca8                	ld	a0,88(s1)
    80005f66:	ffffb097          	auipc	ra,0xffffb
    80005f6a:	7e4080e7          	jalr	2020(ra) # 8000174a <copyout>
    80005f6e:	02054063          	bltz	a0,80005f8e <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f72:	4691                	li	a3,4
    80005f74:	fc040613          	addi	a2,s0,-64
    80005f78:	fd843583          	ld	a1,-40(s0)
    80005f7c:	0591                	addi	a1,a1,4
    80005f7e:	6ca8                	ld	a0,88(s1)
    80005f80:	ffffb097          	auipc	ra,0xffffb
    80005f84:	7ca080e7          	jalr	1994(ra) # 8000174a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f88:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f8a:	06055563          	bgez	a0,80005ff4 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005f8e:	fc442783          	lw	a5,-60(s0)
    80005f92:	07e9                	addi	a5,a5,26
    80005f94:	078e                	slli	a5,a5,0x3
    80005f96:	97a6                	add	a5,a5,s1
    80005f98:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005f9c:	fc042503          	lw	a0,-64(s0)
    80005fa0:	0569                	addi	a0,a0,26
    80005fa2:	050e                	slli	a0,a0,0x3
    80005fa4:	9526                	add	a0,a0,s1
    80005fa6:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005faa:	fd043503          	ld	a0,-48(s0)
    80005fae:	fffff097          	auipc	ra,0xfffff
    80005fb2:	9c2080e7          	jalr	-1598(ra) # 80004970 <fileclose>
    fileclose(wf);
    80005fb6:	fc843503          	ld	a0,-56(s0)
    80005fba:	fffff097          	auipc	ra,0xfffff
    80005fbe:	9b6080e7          	jalr	-1610(ra) # 80004970 <fileclose>
    return -1;
    80005fc2:	57fd                	li	a5,-1
    80005fc4:	a805                	j	80005ff4 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005fc6:	fc442783          	lw	a5,-60(s0)
    80005fca:	0007c863          	bltz	a5,80005fda <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005fce:	01a78513          	addi	a0,a5,26
    80005fd2:	050e                	slli	a0,a0,0x3
    80005fd4:	9526                	add	a0,a0,s1
    80005fd6:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005fda:	fd043503          	ld	a0,-48(s0)
    80005fde:	fffff097          	auipc	ra,0xfffff
    80005fe2:	992080e7          	jalr	-1646(ra) # 80004970 <fileclose>
    fileclose(wf);
    80005fe6:	fc843503          	ld	a0,-56(s0)
    80005fea:	fffff097          	auipc	ra,0xfffff
    80005fee:	986080e7          	jalr	-1658(ra) # 80004970 <fileclose>
    return -1;
    80005ff2:	57fd                	li	a5,-1
}
    80005ff4:	853e                	mv	a0,a5
    80005ff6:	70e2                	ld	ra,56(sp)
    80005ff8:	7442                	ld	s0,48(sp)
    80005ffa:	74a2                	ld	s1,40(sp)
    80005ffc:	6121                	addi	sp,sp,64
    80005ffe:	8082                	ret

0000000080006000 <sys_mmap>:


uint64
sys_mmap(void){
    80006000:	7159                	addi	sp,sp,-112
    80006002:	f486                	sd	ra,104(sp)
    80006004:	f0a2                	sd	s0,96(sp)
    80006006:	eca6                	sd	s1,88(sp)
    80006008:	e8ca                	sd	s2,80(sp)
    8000600a:	e4ce                	sd	s3,72(sp)
    8000600c:	e0d2                	sd	s4,64(sp)
    8000600e:	fc56                	sd	s5,56(sp)
    80006010:	1880                	addi	s0,sp,112
  int flags;
  int fd;
  struct file* f;
  int offset;
  
  if(argaddr(0, &addr) < 0 || argint(1, &length) < 0 || 
    80006012:	fb840593          	addi	a1,s0,-72
    80006016:	4501                	li	a0,0
    80006018:	ffffd097          	auipc	ra,0xffffd
    8000601c:	e88080e7          	jalr	-376(ra) # 80002ea0 <argaddr>
     argint(2, &prot) < 0 || argint(3, &flags) < 0 || 
     argfd(4, &fd, &f) < 0 || argint(5, &offset) < 0){
    return -1;
    80006020:	57fd                	li	a5,-1
  if(argaddr(0, &addr) < 0 || argint(1, &length) < 0 || 
    80006022:	14054263          	bltz	a0,80006166 <sys_mmap+0x166>
    80006026:	fb440593          	addi	a1,s0,-76
    8000602a:	4505                	li	a0,1
    8000602c:	ffffd097          	auipc	ra,0xffffd
    80006030:	e52080e7          	jalr	-430(ra) # 80002e7e <argint>
    return -1;
    80006034:	57fd                	li	a5,-1
  if(argaddr(0, &addr) < 0 || argint(1, &length) < 0 || 
    80006036:	12054863          	bltz	a0,80006166 <sys_mmap+0x166>
     argint(2, &prot) < 0 || argint(3, &flags) < 0 || 
    8000603a:	fb040593          	addi	a1,s0,-80
    8000603e:	4509                	li	a0,2
    80006040:	ffffd097          	auipc	ra,0xffffd
    80006044:	e3e080e7          	jalr	-450(ra) # 80002e7e <argint>
    return -1;
    80006048:	57fd                	li	a5,-1
  if(argaddr(0, &addr) < 0 || argint(1, &length) < 0 || 
    8000604a:	10054e63          	bltz	a0,80006166 <sys_mmap+0x166>
     argint(2, &prot) < 0 || argint(3, &flags) < 0 || 
    8000604e:	fac40593          	addi	a1,s0,-84
    80006052:	450d                	li	a0,3
    80006054:	ffffd097          	auipc	ra,0xffffd
    80006058:	e2a080e7          	jalr	-470(ra) # 80002e7e <argint>
    return -1;
    8000605c:	57fd                	li	a5,-1
     argint(2, &prot) < 0 || argint(3, &flags) < 0 || 
    8000605e:	10054463          	bltz	a0,80006166 <sys_mmap+0x166>
     argfd(4, &fd, &f) < 0 || argint(5, &offset) < 0){
    80006062:	fa040613          	addi	a2,s0,-96
    80006066:	fa840593          	addi	a1,s0,-88
    8000606a:	4511                	li	a0,4
    8000606c:	fffff097          	auipc	ra,0xfffff
    80006070:	336080e7          	jalr	822(ra) # 800053a2 <argfd>
    return -1;
    80006074:	57fd                	li	a5,-1
     argint(2, &prot) < 0 || argint(3, &flags) < 0 || 
    80006076:	0e054863          	bltz	a0,80006166 <sys_mmap+0x166>
     argfd(4, &fd, &f) < 0 || argint(5, &offset) < 0){
    8000607a:	f9c40593          	addi	a1,s0,-100
    8000607e:	4515                	li	a0,5
    80006080:	ffffd097          	auipc	ra,0xffffd
    80006084:	dfe080e7          	jalr	-514(ra) # 80002e7e <argint>
    80006088:	0e054963          	bltz	a0,8000617a <sys_mmap+0x17a>
  }

  if(!f->writable && (prot & PROT_WRITE) && (flags & MAP_SHARED)){
    8000608c:	fa043783          	ld	a5,-96(s0)
    80006090:	0097c783          	lbu	a5,9(a5)
    80006094:	eb91                	bnez	a5,800060a8 <sys_mmap+0xa8>
    80006096:	fb042783          	lw	a5,-80(s0)
    8000609a:	8b91                	andi	a5,a5,4
    8000609c:	c791                	beqz	a5,800060a8 <sys_mmap+0xa8>
    8000609e:	fac42703          	lw	a4,-84(s0)
    800060a2:	8b09                	andi	a4,a4,2
    return -1;
    800060a4:	57fd                	li	a5,-1
  if(!f->writable && (prot & PROT_WRITE) && (flags & MAP_SHARED)){
    800060a6:	e361                	bnez	a4,80006166 <sys_mmap+0x166>
  }
  struct proc* p;
  p = myproc();
    800060a8:	ffffc097          	auipc	ra,0xffffc
    800060ac:	9b6080e7          	jalr	-1610(ra) # 80001a5e <myproc>
    800060b0:	892a                	mv	s2,a0
  
  struct VMA* vma = 0;
  /** 从上往下找到第一个可用的vma  */
  for (int i = NVMA - 1; i >= 0; i--)
    800060b2:	6785                	lui	a5,0x1
    800060b4:	40078793          	addi	a5,a5,1024 # 1400 <_entry-0x7fffec00>
    800060b8:	97aa                	add	a5,a5,a0
    800060ba:	06300493          	li	s1,99
    800060be:	56fd                	li	a3,-1
  {
    if(p->vmas[i].vm_valid){
    800060c0:	4398                	lw	a4,0(a5)
    800060c2:	eb01                	bnez	a4,800060d2 <sys_mmap+0xd2>
  for (int i = NVMA - 1; i >= 0; i--)
    800060c4:	34fd                	addiw	s1,s1,-1
    800060c6:	fd078793          	addi	a5,a5,-48
    800060ca:	fed49be3          	bne	s1,a3,800060c0 <sys_mmap+0xc0>
    vma->vm_file->ref++;
    p->current_maxva = vm_start;
  }
  else
  {
    return -1;
    800060ce:	57fd                	li	a5,-1
    800060d0:	a859                	j	80006166 <sys_mmap+0x166>
      p->current_imaxvma = i;
    800060d2:	6a05                	lui	s4,0x1
    800060d4:	9a4a                	add	s4,s4,s2
    800060d6:	429a2c23          	sw	s1,1080(s4) # 1438 <_entry-0x7fffebc8>
    printf("sys_mmap(): %p, length: %d\n",p->current_maxva, length);
    800060da:	fb442603          	lw	a2,-76(s0)
    800060de:	430a3583          	ld	a1,1072(s4)
    800060e2:	00003517          	auipc	a0,0x3
    800060e6:	b0e50513          	addi	a0,a0,-1266 # 80008bf0 <userret+0xb60>
    800060ea:	ffffa097          	auipc	ra,0xffffa
    800060ee:	4c4080e7          	jalr	1220(ra) # 800005ae <printf>
    uint64 vm_end = PGROUNDDOWN(p->current_maxva);
    800060f2:	430a3783          	ld	a5,1072(s4)
    800060f6:	79fd                	lui	s3,0xfffff
    800060f8:	0137fab3          	and	s5,a5,s3
    uint64 vm_start = PGROUNDDOWN(p->current_maxva - length);
    800060fc:	fb442703          	lw	a4,-76(s0)
    80006100:	8f99                	sub	a5,a5,a4
    80006102:	0137f9b3          	and	s3,a5,s3
    printf("vm_start(): %p, vm_end: %p\n",vm_start, vm_end);
    80006106:	8656                	mv	a2,s5
    80006108:	85ce                	mv	a1,s3
    8000610a:	00003517          	auipc	a0,0x3
    8000610e:	b0650513          	addi	a0,a0,-1274 # 80008c10 <userret+0xb80>
    80006112:	ffffa097          	auipc	ra,0xffffa
    80006116:	49c080e7          	jalr	1180(ra) # 800005ae <printf>
    vma->vm_valid = 0;
    8000611a:	00149713          	slli	a4,s1,0x1
    8000611e:	009707b3          	add	a5,a4,s1
    80006122:	0792                	slli	a5,a5,0x4
    80006124:	97ca                	add	a5,a5,s2
    80006126:	1607a823          	sw	zero,368(a5)
    vma->vm_fd = fd;
    8000612a:	fa842683          	lw	a3,-88(s0)
    8000612e:	18d7ac23          	sw	a3,408(a5)
    vma->vm_file = f;
    80006132:	fa043683          	ld	a3,-96(s0)
    80006136:	18d7b823          	sd	a3,400(a5)
    vma->vm_flags = flags;
    8000613a:	fac42603          	lw	a2,-84(s0)
    8000613e:	18c7a423          	sw	a2,392(a5)
    vma->vm_prot = prot;
    80006142:	fb042603          	lw	a2,-80(s0)
    80006146:	18c7a623          	sw	a2,396(a5)
    vma->vm_end = vm_end;
    8000614a:	1957b023          	sd	s5,384(a5)
    vma->vm_start = vm_start;
    8000614e:	1737bc23          	sd	s3,376(a5)
    vma->vm_file->ref++;
    80006152:	42dc                	lw	a5,4(a3)
    80006154:	2785                	addiw	a5,a5,1
    80006156:	c2dc                	sw	a5,4(a3)
    p->current_maxva = vm_start;
    80006158:	433a3823          	sd	s3,1072(s4)
  }  
  return vma->vm_start;
    8000615c:	9726                	add	a4,a4,s1
    8000615e:	0712                	slli	a4,a4,0x4
    80006160:	993a                	add	s2,s2,a4
    80006162:	17893783          	ld	a5,376(s2)
}
    80006166:	853e                	mv	a0,a5
    80006168:	70a6                	ld	ra,104(sp)
    8000616a:	7406                	ld	s0,96(sp)
    8000616c:	64e6                	ld	s1,88(sp)
    8000616e:	6946                	ld	s2,80(sp)
    80006170:	69a6                	ld	s3,72(sp)
    80006172:	6a06                	ld	s4,64(sp)
    80006174:	7ae2                	ld	s5,56(sp)
    80006176:	6165                	addi	sp,sp,112
    80006178:	8082                	ret
    return -1;
    8000617a:	57fd                	li	a5,-1
    8000617c:	b7ed                	j	80006166 <sys_mmap+0x166>

000000008000617e <sys_munmap>:
 * An munmap call might cover only a portion of an mmap-ed region, but you can assume that 
 * it will either unmap at the start, 
 * or at the end, or the whole region (but not punch a hole in the middle of a region).
 */
uint64
sys_munmap(void){
    8000617e:	7139                	addi	sp,sp,-64
    80006180:	fc06                	sd	ra,56(sp)
    80006182:	f822                	sd	s0,48(sp)
    80006184:	f426                	sd	s1,40(sp)
    80006186:	f04a                	sd	s2,32(sp)
    80006188:	ec4e                	sd	s3,24(sp)
    8000618a:	0080                	addi	s0,sp,64
  uint64 addr;
  int length;
  if(argaddr(0, &addr) < 0 || argint(1, &length) < 0){
    8000618c:	fc840593          	addi	a1,s0,-56
    80006190:	4501                	li	a0,0
    80006192:	ffffd097          	auipc	ra,0xffffd
    80006196:	d0e080e7          	jalr	-754(ra) # 80002ea0 <argaddr>
    return -1;
    8000619a:	57fd                	li	a5,-1
  if(argaddr(0, &addr) < 0 || argint(1, &length) < 0){
    8000619c:	0c054b63          	bltz	a0,80006272 <sys_munmap+0xf4>
    800061a0:	fc440593          	addi	a1,s0,-60
    800061a4:	4505                	li	a0,1
    800061a6:	ffffd097          	auipc	ra,0xffffd
    800061aa:	cd8080e7          	jalr	-808(ra) # 80002e7e <argint>
    return -1;
    800061ae:	57fd                	li	a5,-1
  if(argaddr(0, &addr) < 0 || argint(1, &length) < 0){
    800061b0:	0c054163          	bltz	a0,80006272 <sys_munmap+0xf4>
  }
  printf("### sys_munmap: \n");
    800061b4:	00003517          	auipc	a0,0x3
    800061b8:	a7c50513          	addi	a0,a0,-1412 # 80008c30 <userret+0xba0>
    800061bc:	ffffa097          	auipc	ra,0xffffa
    800061c0:	3f2080e7          	jalr	1010(ra) # 800005ae <printf>
  printf("addr: %p, length:%d, current:%p\n", addr, length, myproc()->current_maxva);
    800061c4:	fc843903          	ld	s2,-56(s0)
    800061c8:	fc442983          	lw	s3,-60(s0)
    800061cc:	ffffc097          	auipc	ra,0xffffc
    800061d0:	892080e7          	jalr	-1902(ra) # 80001a5e <myproc>
    800061d4:	6485                	lui	s1,0x1
    800061d6:	9526                	add	a0,a0,s1
    800061d8:	43053683          	ld	a3,1072(a0)
    800061dc:	864e                	mv	a2,s3
    800061de:	85ca                	mv	a1,s2
    800061e0:	00003517          	auipc	a0,0x3
    800061e4:	a6850513          	addi	a0,a0,-1432 # 80008c48 <userret+0xbb8>
    800061e8:	ffffa097          	auipc	ra,0xffffa
    800061ec:	3c6080e7          	jalr	966(ra) # 800005ae <printf>
  struct proc* p = myproc();
    800061f0:	ffffc097          	auipc	ra,0xffffc
    800061f4:	86e080e7          	jalr	-1938(ra) # 80001a5e <myproc>
    800061f8:	892a                	mv	s2,a0
  for (int i = NVMA - 1; i >= 0; i--)
  {
    if(p->vmas[i].vm_start <= addr && addr <= p->vmas[i].vm_end){
    800061fa:	fc843703          	ld	a4,-56(s0)
    800061fe:	40848793          	addi	a5,s1,1032 # 1408 <_entry-0x7fffebf8>
    80006202:	97aa                	add	a5,a5,a0
  for (int i = NVMA - 1; i >= 0; i--)
    80006204:	06300493          	li	s1,99
    80006208:	56fd                	li	a3,-1
    8000620a:	a049                	j	8000628c <sys_munmap+0x10e>
      struct VMA* vma = &p->vmas[i];
      /** 首先要判断  */
      if(walkaddr(p->pagetable, vma->vm_start)){
        if(vma->vm_flags == MAP_SHARED){
          printf("sys_munmap(): write back \n");
    8000620c:	00002517          	auipc	a0,0x2
    80006210:	2a450513          	addi	a0,a0,676 # 800084b0 <userret+0x420>
    80006214:	ffffa097          	auipc	ra,0xffffa
    80006218:	39a080e7          	jalr	922(ra) # 800005ae <printf>
          /** 回写文件  */
          filewrite(vma->vm_file, vma->vm_start, length);
    8000621c:	00149793          	slli	a5,s1,0x1
    80006220:	97a6                	add	a5,a5,s1
    80006222:	0792                	slli	a5,a5,0x4
    80006224:	97ca                	add	a5,a5,s2
    80006226:	fc442603          	lw	a2,-60(s0)
    8000622a:	1787b583          	ld	a1,376(a5)
    8000622e:	1907b503          	ld	a0,400(a5)
    80006232:	fffff097          	auipc	ra,0xfffff
    80006236:	946080e7          	jalr	-1722(ra) # 80004b78 <filewrite>
    8000623a:	a041                	j	800062ba <sys_munmap+0x13c>
      }

      vma->vm_start += length;
      printf("vma_start: %p, vma_end: %p\n", vma->vm_start, vma->vm_end);
      if(vma->vm_start == vma->vm_end){
        vma->vm_file->ref--;
    8000623c:	1909b683          	ld	a3,400(s3) # fffffffffffff190 <end+0xffffffff7ffcb134>
    80006240:	42d8                	lw	a4,4(a3)
    80006242:	377d                	addiw	a4,a4,-1
    80006244:	c2d8                	sw	a4,4(a3)
        /** 置该块可用  */
        vma->vm_valid = 1;
    80006246:	4705                	li	a4,1
    80006248:	16e9a823          	sw	a4,368(s3)
    8000624c:	a0d9                	j	80006312 <sys_munmap+0x194>
      int j;
      /** 紧缩 p->current_maxva */
      for (j = p->current_imaxvma; j < NVMA; j++)
      {
        if(!p->vmas[j].vm_valid){
          p->current_maxva = p->vmas[j].vm_start;
    8000624e:	6685                	lui	a3,0x1
    80006250:	96ca                	add	a3,a3,s2
    80006252:	00171793          	slli	a5,a4,0x1
    80006256:	97ba                	add	a5,a5,a4
    80006258:	0792                	slli	a5,a5,0x4
    8000625a:	97ca                	add	a5,a5,s2
    8000625c:	1787b783          	ld	a5,376(a5)
    80006260:	42f6b823          	sd	a5,1072(a3) # 1430 <_entry-0x7fffebd0>
          p->current_imaxvma = j;
    80006264:	42e6ac23          	sw	a4,1080(a3)
          break;
        }
      }
      if(j == NVMA){
    80006268:	06400693          	li	a3,100
        p->current_maxva = VMASTART;
      }
      return 0;
    8000626c:	4781                	li	a5,0
      if(j == NVMA){
    8000626e:	0cd70a63          	beq	a4,a3,80006342 <sys_munmap+0x1c4>
    }
  }
  
  printf("################ arrive at munmap!\n");
  return -1;
}
    80006272:	853e                	mv	a0,a5
    80006274:	70e2                	ld	ra,56(sp)
    80006276:	7442                	ld	s0,48(sp)
    80006278:	74a2                	ld	s1,40(sp)
    8000627a:	7902                	ld	s2,32(sp)
    8000627c:	69e2                	ld	s3,24(sp)
    8000627e:	6121                	addi	sp,sp,64
    80006280:	8082                	ret
  for (int i = NVMA - 1; i >= 0; i--)
    80006282:	34fd                	addiw	s1,s1,-1
    80006284:	fd078793          	addi	a5,a5,-48
    80006288:	0cd48763          	beq	s1,a3,80006356 <sys_munmap+0x1d8>
    if(p->vmas[i].vm_start <= addr && addr <= p->vmas[i].vm_end){
    8000628c:	638c                	ld	a1,0(a5)
    8000628e:	feb76ae3          	bltu	a4,a1,80006282 <sys_munmap+0x104>
    80006292:	6790                	ld	a2,8(a5)
    80006294:	fee667e3          	bltu	a2,a4,80006282 <sys_munmap+0x104>
      if(walkaddr(p->pagetable, vma->vm_start)){
    80006298:	05893503          	ld	a0,88(s2)
    8000629c:	ffffb097          	auipc	ra,0xffffb
    800062a0:	ecc080e7          	jalr	-308(ra) # 80001168 <walkaddr>
    800062a4:	c91d                	beqz	a0,800062da <sys_munmap+0x15c>
        if(vma->vm_flags == MAP_SHARED){
    800062a6:	00149793          	slli	a5,s1,0x1
    800062aa:	97a6                	add	a5,a5,s1
    800062ac:	0792                	slli	a5,a5,0x4
    800062ae:	97ca                	add	a5,a5,s2
    800062b0:	1887a703          	lw	a4,392(a5)
    800062b4:	4789                	li	a5,2
    800062b6:	f4f70be3          	beq	a4,a5,8000620c <sys_munmap+0x8e>
        uvmunmap(p->pagetable, vma->vm_start, length ,1);
    800062ba:	00149793          	slli	a5,s1,0x1
    800062be:	97a6                	add	a5,a5,s1
    800062c0:	0792                	slli	a5,a5,0x4
    800062c2:	97ca                	add	a5,a5,s2
    800062c4:	4685                	li	a3,1
    800062c6:	fc442603          	lw	a2,-60(s0)
    800062ca:	1787b583          	ld	a1,376(a5)
    800062ce:	05893503          	ld	a0,88(s2)
    800062d2:	ffffb097          	auipc	ra,0xffffb
    800062d6:	0e2080e7          	jalr	226(ra) # 800013b4 <uvmunmap>
      vma->vm_start += length;
    800062da:	00149993          	slli	s3,s1,0x1
    800062de:	99a6                	add	s3,s3,s1
    800062e0:	0992                	slli	s3,s3,0x4
    800062e2:	99ca                	add	s3,s3,s2
    800062e4:	fc442583          	lw	a1,-60(s0)
    800062e8:	1789b783          	ld	a5,376(s3)
    800062ec:	95be                	add	a1,a1,a5
    800062ee:	16b9bc23          	sd	a1,376(s3)
      printf("vma_start: %p, vma_end: %p\n", vma->vm_start, vma->vm_end);
    800062f2:	1809b603          	ld	a2,384(s3)
    800062f6:	00003517          	auipc	a0,0x3
    800062fa:	97a50513          	addi	a0,a0,-1670 # 80008c70 <userret+0xbe0>
    800062fe:	ffffa097          	auipc	ra,0xffffa
    80006302:	2b0080e7          	jalr	688(ra) # 800005ae <printf>
      if(vma->vm_start == vma->vm_end){
    80006306:	1789b703          	ld	a4,376(s3)
    8000630a:	1809b783          	ld	a5,384(s3)
    8000630e:	f2f707e3          	beq	a4,a5,8000623c <sys_munmap+0xbe>
      for (j = p->current_imaxvma; j < NVMA; j++)
    80006312:	6785                	lui	a5,0x1
    80006314:	97ca                	add	a5,a5,s2
    80006316:	4387a703          	lw	a4,1080(a5) # 1438 <_entry-0x7fffebc8>
    8000631a:	06300793          	li	a5,99
    8000631e:	f4e7c5e3          	blt	a5,a4,80006268 <sys_munmap+0xea>
    80006322:	00171793          	slli	a5,a4,0x1
    80006326:	97ba                	add	a5,a5,a4
    80006328:	0792                	slli	a5,a5,0x4
    8000632a:	17078793          	addi	a5,a5,368
    8000632e:	97ca                	add	a5,a5,s2
    80006330:	06400613          	li	a2,100
        if(!p->vmas[j].vm_valid){
    80006334:	4394                	lw	a3,0(a5)
    80006336:	de81                	beqz	a3,8000624e <sys_munmap+0xd0>
      for (j = p->current_imaxvma; j < NVMA; j++)
    80006338:	2705                	addiw	a4,a4,1
    8000633a:	03078793          	addi	a5,a5,48
    8000633e:	fec71be3          	bne	a4,a2,80006334 <sys_munmap+0x1b6>
        p->current_maxva = VMASTART;
    80006342:	6785                	lui	a5,0x1
    80006344:	993e                	add	s2,s2,a5
    80006346:	020007b7          	lui	a5,0x2000
    8000634a:	17fd                	addi	a5,a5,-1
    8000634c:	07b6                	slli	a5,a5,0xd
    8000634e:	42f93823          	sd	a5,1072(s2)
      return 0;
    80006352:	4781                	li	a5,0
    80006354:	bf39                	j	80006272 <sys_munmap+0xf4>
  printf("################ arrive at munmap!\n");
    80006356:	00003517          	auipc	a0,0x3
    8000635a:	93a50513          	addi	a0,a0,-1734 # 80008c90 <userret+0xc00>
    8000635e:	ffffa097          	auipc	ra,0xffffa
    80006362:	250080e7          	jalr	592(ra) # 800005ae <printf>
  return -1;
    80006366:	57fd                	li	a5,-1
    80006368:	b729                	j	80006272 <sys_munmap+0xf4>
    8000636a:	0000                	unimp
    8000636c:	0000                	unimp
	...

0000000080006370 <kernelvec>:
    80006370:	7111                	addi	sp,sp,-256
    80006372:	e006                	sd	ra,0(sp)
    80006374:	e40a                	sd	sp,8(sp)
    80006376:	e80e                	sd	gp,16(sp)
    80006378:	ec12                	sd	tp,24(sp)
    8000637a:	f016                	sd	t0,32(sp)
    8000637c:	f41a                	sd	t1,40(sp)
    8000637e:	f81e                	sd	t2,48(sp)
    80006380:	fc22                	sd	s0,56(sp)
    80006382:	e0a6                	sd	s1,64(sp)
    80006384:	e4aa                	sd	a0,72(sp)
    80006386:	e8ae                	sd	a1,80(sp)
    80006388:	ecb2                	sd	a2,88(sp)
    8000638a:	f0b6                	sd	a3,96(sp)
    8000638c:	f4ba                	sd	a4,104(sp)
    8000638e:	f8be                	sd	a5,112(sp)
    80006390:	fcc2                	sd	a6,120(sp)
    80006392:	e146                	sd	a7,128(sp)
    80006394:	e54a                	sd	s2,136(sp)
    80006396:	e94e                	sd	s3,144(sp)
    80006398:	ed52                	sd	s4,152(sp)
    8000639a:	f156                	sd	s5,160(sp)
    8000639c:	f55a                	sd	s6,168(sp)
    8000639e:	f95e                	sd	s7,176(sp)
    800063a0:	fd62                	sd	s8,184(sp)
    800063a2:	e1e6                	sd	s9,192(sp)
    800063a4:	e5ea                	sd	s10,200(sp)
    800063a6:	e9ee                	sd	s11,208(sp)
    800063a8:	edf2                	sd	t3,216(sp)
    800063aa:	f1f6                	sd	t4,224(sp)
    800063ac:	f5fa                	sd	t5,232(sp)
    800063ae:	f9fe                	sd	t6,240(sp)
    800063b0:	8f5fc0ef          	jal	ra,80002ca4 <kerneltrap>
    800063b4:	6082                	ld	ra,0(sp)
    800063b6:	6122                	ld	sp,8(sp)
    800063b8:	61c2                	ld	gp,16(sp)
    800063ba:	7282                	ld	t0,32(sp)
    800063bc:	7322                	ld	t1,40(sp)
    800063be:	73c2                	ld	t2,48(sp)
    800063c0:	7462                	ld	s0,56(sp)
    800063c2:	6486                	ld	s1,64(sp)
    800063c4:	6526                	ld	a0,72(sp)
    800063c6:	65c6                	ld	a1,80(sp)
    800063c8:	6666                	ld	a2,88(sp)
    800063ca:	7686                	ld	a3,96(sp)
    800063cc:	7726                	ld	a4,104(sp)
    800063ce:	77c6                	ld	a5,112(sp)
    800063d0:	7866                	ld	a6,120(sp)
    800063d2:	688a                	ld	a7,128(sp)
    800063d4:	692a                	ld	s2,136(sp)
    800063d6:	69ca                	ld	s3,144(sp)
    800063d8:	6a6a                	ld	s4,152(sp)
    800063da:	7a8a                	ld	s5,160(sp)
    800063dc:	7b2a                	ld	s6,168(sp)
    800063de:	7bca                	ld	s7,176(sp)
    800063e0:	7c6a                	ld	s8,184(sp)
    800063e2:	6c8e                	ld	s9,192(sp)
    800063e4:	6d2e                	ld	s10,200(sp)
    800063e6:	6dce                	ld	s11,208(sp)
    800063e8:	6e6e                	ld	t3,216(sp)
    800063ea:	7e8e                	ld	t4,224(sp)
    800063ec:	7f2e                	ld	t5,232(sp)
    800063ee:	7fce                	ld	t6,240(sp)
    800063f0:	6111                	addi	sp,sp,256
    800063f2:	10200073          	sret
    800063f6:	00000013          	nop
    800063fa:	00000013          	nop
    800063fe:	0001                	nop

0000000080006400 <timervec>:
    80006400:	34051573          	csrrw	a0,mscratch,a0
    80006404:	e10c                	sd	a1,0(a0)
    80006406:	e510                	sd	a2,8(a0)
    80006408:	e914                	sd	a3,16(a0)
    8000640a:	710c                	ld	a1,32(a0)
    8000640c:	7510                	ld	a2,40(a0)
    8000640e:	6194                	ld	a3,0(a1)
    80006410:	96b2                	add	a3,a3,a2
    80006412:	e194                	sd	a3,0(a1)
    80006414:	4589                	li	a1,2
    80006416:	14459073          	csrw	sip,a1
    8000641a:	6914                	ld	a3,16(a0)
    8000641c:	6510                	ld	a2,8(a0)
    8000641e:	610c                	ld	a1,0(a0)
    80006420:	34051573          	csrrw	a0,mscratch,a0
    80006424:	30200073          	mret
	...

000000008000642a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000642a:	1141                	addi	sp,sp,-16
    8000642c:	e422                	sd	s0,8(sp)
    8000642e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006430:	0c0007b7          	lui	a5,0xc000
    80006434:	4705                	li	a4,1
    80006436:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006438:	c3d8                	sw	a4,4(a5)
}
    8000643a:	6422                	ld	s0,8(sp)
    8000643c:	0141                	addi	sp,sp,16
    8000643e:	8082                	ret

0000000080006440 <plicinithart>:

void
plicinithart(void)
{
    80006440:	1141                	addi	sp,sp,-16
    80006442:	e406                	sd	ra,8(sp)
    80006444:	e022                	sd	s0,0(sp)
    80006446:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006448:	ffffb097          	auipc	ra,0xffffb
    8000644c:	5ea080e7          	jalr	1514(ra) # 80001a32 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006450:	0085171b          	slliw	a4,a0,0x8
    80006454:	0c0027b7          	lui	a5,0xc002
    80006458:	97ba                	add	a5,a5,a4
    8000645a:	40200713          	li	a4,1026
    8000645e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006462:	00d5151b          	slliw	a0,a0,0xd
    80006466:	0c2017b7          	lui	a5,0xc201
    8000646a:	953e                	add	a0,a0,a5
    8000646c:	00052023          	sw	zero,0(a0)
}
    80006470:	60a2                	ld	ra,8(sp)
    80006472:	6402                	ld	s0,0(sp)
    80006474:	0141                	addi	sp,sp,16
    80006476:	8082                	ret

0000000080006478 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006478:	1141                	addi	sp,sp,-16
    8000647a:	e406                	sd	ra,8(sp)
    8000647c:	e022                	sd	s0,0(sp)
    8000647e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006480:	ffffb097          	auipc	ra,0xffffb
    80006484:	5b2080e7          	jalr	1458(ra) # 80001a32 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006488:	00d5179b          	slliw	a5,a0,0xd
    8000648c:	0c201537          	lui	a0,0xc201
    80006490:	953e                	add	a0,a0,a5
  return irq;
}
    80006492:	4148                	lw	a0,4(a0)
    80006494:	60a2                	ld	ra,8(sp)
    80006496:	6402                	ld	s0,0(sp)
    80006498:	0141                	addi	sp,sp,16
    8000649a:	8082                	ret

000000008000649c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000649c:	1101                	addi	sp,sp,-32
    8000649e:	ec06                	sd	ra,24(sp)
    800064a0:	e822                	sd	s0,16(sp)
    800064a2:	e426                	sd	s1,8(sp)
    800064a4:	1000                	addi	s0,sp,32
    800064a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800064a8:	ffffb097          	auipc	ra,0xffffb
    800064ac:	58a080e7          	jalr	1418(ra) # 80001a32 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800064b0:	00d5151b          	slliw	a0,a0,0xd
    800064b4:	0c2017b7          	lui	a5,0xc201
    800064b8:	97aa                	add	a5,a5,a0
    800064ba:	c3c4                	sw	s1,4(a5)
}
    800064bc:	60e2                	ld	ra,24(sp)
    800064be:	6442                	ld	s0,16(sp)
    800064c0:	64a2                	ld	s1,8(sp)
    800064c2:	6105                	addi	sp,sp,32
    800064c4:	8082                	ret

00000000800064c6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    800064c6:	1141                	addi	sp,sp,-16
    800064c8:	e406                	sd	ra,8(sp)
    800064ca:	e022                	sd	s0,0(sp)
    800064cc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800064ce:	479d                	li	a5,7
    800064d0:	06b7c963          	blt	a5,a1,80006542 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    800064d4:	00151793          	slli	a5,a0,0x1
    800064d8:	97aa                	add	a5,a5,a0
    800064da:	00c79713          	slli	a4,a5,0xc
    800064de:	00028797          	auipc	a5,0x28
    800064e2:	b2278793          	addi	a5,a5,-1246 # 8002e000 <disk>
    800064e6:	97ba                	add	a5,a5,a4
    800064e8:	97ae                	add	a5,a5,a1
    800064ea:	6709                	lui	a4,0x2
    800064ec:	97ba                	add	a5,a5,a4
    800064ee:	0187c783          	lbu	a5,24(a5)
    800064f2:	e3a5                	bnez	a5,80006552 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    800064f4:	00028817          	auipc	a6,0x28
    800064f8:	b0c80813          	addi	a6,a6,-1268 # 8002e000 <disk>
    800064fc:	00151693          	slli	a3,a0,0x1
    80006500:	00a68733          	add	a4,a3,a0
    80006504:	0732                	slli	a4,a4,0xc
    80006506:	00e807b3          	add	a5,a6,a4
    8000650a:	6709                	lui	a4,0x2
    8000650c:	00f70633          	add	a2,a4,a5
    80006510:	6210                	ld	a2,0(a2)
    80006512:	00459893          	slli	a7,a1,0x4
    80006516:	9646                	add	a2,a2,a7
    80006518:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    8000651c:	97ae                	add	a5,a5,a1
    8000651e:	97ba                	add	a5,a5,a4
    80006520:	4605                	li	a2,1
    80006522:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80006526:	96aa                	add	a3,a3,a0
    80006528:	06b2                	slli	a3,a3,0xc
    8000652a:	0761                	addi	a4,a4,24
    8000652c:	96ba                	add	a3,a3,a4
    8000652e:	00d80533          	add	a0,a6,a3
    80006532:	ffffc097          	auipc	ra,0xffffc
    80006536:	fb8080e7          	jalr	-72(ra) # 800024ea <wakeup>
}
    8000653a:	60a2                	ld	ra,8(sp)
    8000653c:	6402                	ld	s0,0(sp)
    8000653e:	0141                	addi	sp,sp,16
    80006540:	8082                	ret
    panic("virtio_disk_intr 1");
    80006542:	00002517          	auipc	a0,0x2
    80006546:	77650513          	addi	a0,a0,1910 # 80008cb8 <userret+0xc28>
    8000654a:	ffffa097          	auipc	ra,0xffffa
    8000654e:	00a080e7          	jalr	10(ra) # 80000554 <panic>
    panic("virtio_disk_intr 2");
    80006552:	00002517          	auipc	a0,0x2
    80006556:	77e50513          	addi	a0,a0,1918 # 80008cd0 <userret+0xc40>
    8000655a:	ffffa097          	auipc	ra,0xffffa
    8000655e:	ffa080e7          	jalr	-6(ra) # 80000554 <panic>

0000000080006562 <virtio_disk_init>:
  __sync_synchronize();
    80006562:	0ff0000f          	fence
  if(disk[n].init)
    80006566:	00151793          	slli	a5,a0,0x1
    8000656a:	97aa                	add	a5,a5,a0
    8000656c:	07b2                	slli	a5,a5,0xc
    8000656e:	00028717          	auipc	a4,0x28
    80006572:	a9270713          	addi	a4,a4,-1390 # 8002e000 <disk>
    80006576:	973e                	add	a4,a4,a5
    80006578:	6789                	lui	a5,0x2
    8000657a:	97ba                	add	a5,a5,a4
    8000657c:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80006580:	c391                	beqz	a5,80006584 <virtio_disk_init+0x22>
    80006582:	8082                	ret
{
    80006584:	7139                	addi	sp,sp,-64
    80006586:	fc06                	sd	ra,56(sp)
    80006588:	f822                	sd	s0,48(sp)
    8000658a:	f426                	sd	s1,40(sp)
    8000658c:	f04a                	sd	s2,32(sp)
    8000658e:	ec4e                	sd	s3,24(sp)
    80006590:	e852                	sd	s4,16(sp)
    80006592:	e456                	sd	s5,8(sp)
    80006594:	0080                	addi	s0,sp,64
    80006596:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80006598:	85aa                	mv	a1,a0
    8000659a:	00002517          	auipc	a0,0x2
    8000659e:	74e50513          	addi	a0,a0,1870 # 80008ce8 <userret+0xc58>
    800065a2:	ffffa097          	auipc	ra,0xffffa
    800065a6:	00c080e7          	jalr	12(ra) # 800005ae <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    800065aa:	00149993          	slli	s3,s1,0x1
    800065ae:	99a6                	add	s3,s3,s1
    800065b0:	09b2                	slli	s3,s3,0xc
    800065b2:	6789                	lui	a5,0x2
    800065b4:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    800065b8:	97ce                	add	a5,a5,s3
    800065ba:	00002597          	auipc	a1,0x2
    800065be:	74658593          	addi	a1,a1,1862 # 80008d00 <userret+0xc70>
    800065c2:	00028517          	auipc	a0,0x28
    800065c6:	a3e50513          	addi	a0,a0,-1474 # 8002e000 <disk>
    800065ca:	953e                	add	a0,a0,a5
    800065cc:	ffffa097          	auipc	ra,0xffffa
    800065d0:	400080e7          	jalr	1024(ra) # 800009cc <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065d4:	0014891b          	addiw	s2,s1,1
    800065d8:	00c9191b          	slliw	s2,s2,0xc
    800065dc:	100007b7          	lui	a5,0x10000
    800065e0:	97ca                	add	a5,a5,s2
    800065e2:	4398                	lw	a4,0(a5)
    800065e4:	2701                	sext.w	a4,a4
    800065e6:	747277b7          	lui	a5,0x74727
    800065ea:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800065ee:	12f71663          	bne	a4,a5,8000671a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800065f2:	100007b7          	lui	a5,0x10000
    800065f6:	0791                	addi	a5,a5,4
    800065f8:	97ca                	add	a5,a5,s2
    800065fa:	439c                	lw	a5,0(a5)
    800065fc:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065fe:	4705                	li	a4,1
    80006600:	10e79d63          	bne	a5,a4,8000671a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006604:	100007b7          	lui	a5,0x10000
    80006608:	07a1                	addi	a5,a5,8
    8000660a:	97ca                	add	a5,a5,s2
    8000660c:	439c                	lw	a5,0(a5)
    8000660e:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006610:	4709                	li	a4,2
    80006612:	10e79463          	bne	a5,a4,8000671a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006616:	100007b7          	lui	a5,0x10000
    8000661a:	07b1                	addi	a5,a5,12
    8000661c:	97ca                	add	a5,a5,s2
    8000661e:	4398                	lw	a4,0(a5)
    80006620:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006622:	554d47b7          	lui	a5,0x554d4
    80006626:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000662a:	0ef71863          	bne	a4,a5,8000671a <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000662e:	100007b7          	lui	a5,0x10000
    80006632:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80006636:	96ca                	add	a3,a3,s2
    80006638:	4705                	li	a4,1
    8000663a:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000663c:	470d                	li	a4,3
    8000663e:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    80006640:	01078713          	addi	a4,a5,16
    80006644:	974a                	add	a4,a4,s2
    80006646:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006648:	02078613          	addi	a2,a5,32
    8000664c:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000664e:	c7ffe737          	lui	a4,0xc7ffe
    80006652:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fca703>
    80006656:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006658:	2701                	sext.w	a4,a4
    8000665a:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000665c:	472d                	li	a4,11
    8000665e:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006660:	473d                	li	a4,15
    80006662:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006664:	02878713          	addi	a4,a5,40
    80006668:	974a                	add	a4,a4,s2
    8000666a:	6685                	lui	a3,0x1
    8000666c:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000666e:	03078713          	addi	a4,a5,48
    80006672:	974a                	add	a4,a4,s2
    80006674:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006678:	03478793          	addi	a5,a5,52
    8000667c:	97ca                	add	a5,a5,s2
    8000667e:	439c                	lw	a5,0(a5)
    80006680:	2781                	sext.w	a5,a5
  if(max == 0)
    80006682:	c7c5                	beqz	a5,8000672a <virtio_disk_init+0x1c8>
  if(max < NUM)
    80006684:	471d                	li	a4,7
    80006686:	0af77a63          	bgeu	a4,a5,8000673a <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000668a:	10000ab7          	lui	s5,0x10000
    8000668e:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80006692:	97ca                	add	a5,a5,s2
    80006694:	4721                	li	a4,8
    80006696:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006698:	00028a17          	auipc	s4,0x28
    8000669c:	968a0a13          	addi	s4,s4,-1688 # 8002e000 <disk>
    800066a0:	99d2                	add	s3,s3,s4
    800066a2:	6609                	lui	a2,0x2
    800066a4:	4581                	li	a1,0
    800066a6:	854e                	mv	a0,s3
    800066a8:	ffffa097          	auipc	ra,0xffffa
    800066ac:	6c6080e7          	jalr	1734(ra) # 80000d6e <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    800066b0:	040a8a93          	addi	s5,s5,64
    800066b4:	9956                	add	s2,s2,s5
    800066b6:	00c9d793          	srli	a5,s3,0xc
    800066ba:	2781                	sext.w	a5,a5
    800066bc:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    800066c0:	00149693          	slli	a3,s1,0x1
    800066c4:	009687b3          	add	a5,a3,s1
    800066c8:	07b2                	slli	a5,a5,0xc
    800066ca:	97d2                	add	a5,a5,s4
    800066cc:	6609                	lui	a2,0x2
    800066ce:	97b2                	add	a5,a5,a2
    800066d0:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    800066d4:	08098713          	addi	a4,s3,128
    800066d8:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    800066da:	6705                	lui	a4,0x1
    800066dc:	99ba                	add	s3,s3,a4
    800066de:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    800066e2:	4705                	li	a4,1
    800066e4:	00e78c23          	sb	a4,24(a5)
    800066e8:	00e78ca3          	sb	a4,25(a5)
    800066ec:	00e78d23          	sb	a4,26(a5)
    800066f0:	00e78da3          	sb	a4,27(a5)
    800066f4:	00e78e23          	sb	a4,28(a5)
    800066f8:	00e78ea3          	sb	a4,29(a5)
    800066fc:	00e78f23          	sb	a4,30(a5)
    80006700:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80006704:	0ae7a423          	sw	a4,168(a5)
}
    80006708:	70e2                	ld	ra,56(sp)
    8000670a:	7442                	ld	s0,48(sp)
    8000670c:	74a2                	ld	s1,40(sp)
    8000670e:	7902                	ld	s2,32(sp)
    80006710:	69e2                	ld	s3,24(sp)
    80006712:	6a42                	ld	s4,16(sp)
    80006714:	6aa2                	ld	s5,8(sp)
    80006716:	6121                	addi	sp,sp,64
    80006718:	8082                	ret
    panic("could not find virtio disk");
    8000671a:	00002517          	auipc	a0,0x2
    8000671e:	5f650513          	addi	a0,a0,1526 # 80008d10 <userret+0xc80>
    80006722:	ffffa097          	auipc	ra,0xffffa
    80006726:	e32080e7          	jalr	-462(ra) # 80000554 <panic>
    panic("virtio disk has no queue 0");
    8000672a:	00002517          	auipc	a0,0x2
    8000672e:	60650513          	addi	a0,a0,1542 # 80008d30 <userret+0xca0>
    80006732:	ffffa097          	auipc	ra,0xffffa
    80006736:	e22080e7          	jalr	-478(ra) # 80000554 <panic>
    panic("virtio disk max queue too short");
    8000673a:	00002517          	auipc	a0,0x2
    8000673e:	61650513          	addi	a0,a0,1558 # 80008d50 <userret+0xcc0>
    80006742:	ffffa097          	auipc	ra,0xffffa
    80006746:	e12080e7          	jalr	-494(ra) # 80000554 <panic>

000000008000674a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    8000674a:	7135                	addi	sp,sp,-160
    8000674c:	ed06                	sd	ra,152(sp)
    8000674e:	e922                	sd	s0,144(sp)
    80006750:	e526                	sd	s1,136(sp)
    80006752:	e14a                	sd	s2,128(sp)
    80006754:	fcce                	sd	s3,120(sp)
    80006756:	f8d2                	sd	s4,112(sp)
    80006758:	f4d6                	sd	s5,104(sp)
    8000675a:	f0da                	sd	s6,96(sp)
    8000675c:	ecde                	sd	s7,88(sp)
    8000675e:	e8e2                	sd	s8,80(sp)
    80006760:	e4e6                	sd	s9,72(sp)
    80006762:	e0ea                	sd	s10,64(sp)
    80006764:	fc6e                	sd	s11,56(sp)
    80006766:	1100                	addi	s0,sp,160
    80006768:	8aaa                	mv	s5,a0
    8000676a:	8c2e                	mv	s8,a1
    8000676c:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    8000676e:	45dc                	lw	a5,12(a1)
    80006770:	0017979b          	slliw	a5,a5,0x1
    80006774:	1782                	slli	a5,a5,0x20
    80006776:	9381                	srli	a5,a5,0x20
    80006778:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    8000677c:	00151493          	slli	s1,a0,0x1
    80006780:	94aa                	add	s1,s1,a0
    80006782:	04b2                	slli	s1,s1,0xc
    80006784:	6909                	lui	s2,0x2
    80006786:	0b090c93          	addi	s9,s2,176 # 20b0 <_entry-0x7fffdf50>
    8000678a:	9ca6                	add	s9,s9,s1
    8000678c:	00028997          	auipc	s3,0x28
    80006790:	87498993          	addi	s3,s3,-1932 # 8002e000 <disk>
    80006794:	9cce                	add	s9,s9,s3
    80006796:	8566                	mv	a0,s9
    80006798:	ffffa097          	auipc	ra,0xffffa
    8000679c:	308080e7          	jalr	776(ra) # 80000aa0 <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    800067a0:	0961                	addi	s2,s2,24
    800067a2:	94ca                	add	s1,s1,s2
    800067a4:	99a6                	add	s3,s3,s1
  for(int i = 0; i < 3; i++){
    800067a6:	4a01                	li	s4,0
  for(int i = 0; i < NUM; i++){
    800067a8:	44a1                	li	s1,8
      disk[n].free[i] = 0;
    800067aa:	001a9793          	slli	a5,s5,0x1
    800067ae:	97d6                	add	a5,a5,s5
    800067b0:	07b2                	slli	a5,a5,0xc
    800067b2:	00028b97          	auipc	s7,0x28
    800067b6:	84eb8b93          	addi	s7,s7,-1970 # 8002e000 <disk>
    800067ba:	9bbe                	add	s7,s7,a5
    800067bc:	a8a9                	j	80006816 <virtio_disk_rw+0xcc>
    800067be:	00fb8733          	add	a4,s7,a5
    800067c2:	9742                	add	a4,a4,a6
    800067c4:	00070c23          	sb	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    idx[i] = alloc_desc(n);
    800067c8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800067ca:	0207c263          	bltz	a5,800067ee <virtio_disk_rw+0xa4>
  for(int i = 0; i < 3; i++){
    800067ce:	2905                	addiw	s2,s2,1
    800067d0:	0611                	addi	a2,a2,4
    800067d2:	1ca90463          	beq	s2,a0,8000699a <virtio_disk_rw+0x250>
    idx[i] = alloc_desc(n);
    800067d6:	85b2                	mv	a1,a2
    800067d8:	874e                	mv	a4,s3
  for(int i = 0; i < NUM; i++){
    800067da:	87d2                	mv	a5,s4
    if(disk[n].free[i]){
    800067dc:	00074683          	lbu	a3,0(a4)
    800067e0:	fef9                	bnez	a3,800067be <virtio_disk_rw+0x74>
  for(int i = 0; i < NUM; i++){
    800067e2:	2785                	addiw	a5,a5,1
    800067e4:	0705                	addi	a4,a4,1
    800067e6:	fe979be3          	bne	a5,s1,800067dc <virtio_disk_rw+0x92>
    idx[i] = alloc_desc(n);
    800067ea:	57fd                	li	a5,-1
    800067ec:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800067ee:	01205e63          	blez	s2,8000680a <virtio_disk_rw+0xc0>
    800067f2:	8d52                	mv	s10,s4
        free_desc(n, idx[j]);
    800067f4:	000b2583          	lw	a1,0(s6)
    800067f8:	8556                	mv	a0,s5
    800067fa:	00000097          	auipc	ra,0x0
    800067fe:	ccc080e7          	jalr	-820(ra) # 800064c6 <free_desc>
      for(int j = 0; j < i; j++)
    80006802:	2d05                	addiw	s10,s10,1
    80006804:	0b11                	addi	s6,s6,4
    80006806:	ffa917e3          	bne	s2,s10,800067f4 <virtio_disk_rw+0xaa>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    8000680a:	85e6                	mv	a1,s9
    8000680c:	854e                	mv	a0,s3
    8000680e:	ffffc097          	auipc	ra,0xffffc
    80006812:	b5a080e7          	jalr	-1190(ra) # 80002368 <sleep>
  for(int i = 0; i < 3; i++){
    80006816:	f8040b13          	addi	s6,s0,-128
{
    8000681a:	865a                	mv	a2,s6
  for(int i = 0; i < 3; i++){
    8000681c:	8952                	mv	s2,s4
      disk[n].free[i] = 0;
    8000681e:	6809                	lui	a6,0x2
  for(int i = 0; i < 3; i++){
    80006820:	450d                	li	a0,3
    80006822:	bf55                	j	800067d6 <virtio_disk_rw+0x8c>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80006824:	001a9793          	slli	a5,s5,0x1
    80006828:	97d6                	add	a5,a5,s5
    8000682a:	07b2                	slli	a5,a5,0xc
    8000682c:	00027717          	auipc	a4,0x27
    80006830:	7d470713          	addi	a4,a4,2004 # 8002e000 <disk>
    80006834:	973e                	add	a4,a4,a5
    80006836:	6789                	lui	a5,0x2
    80006838:	97ba                	add	a5,a5,a4
    8000683a:	639c                	ld	a5,0(a5)
    8000683c:	97b6                	add	a5,a5,a3
    8000683e:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006842:	00027517          	auipc	a0,0x27
    80006846:	7be50513          	addi	a0,a0,1982 # 8002e000 <disk>
    8000684a:	001a9793          	slli	a5,s5,0x1
    8000684e:	01578733          	add	a4,a5,s5
    80006852:	0732                	slli	a4,a4,0xc
    80006854:	972a                	add	a4,a4,a0
    80006856:	6609                	lui	a2,0x2
    80006858:	9732                	add	a4,a4,a2
    8000685a:	6310                	ld	a2,0(a4)
    8000685c:	9636                	add	a2,a2,a3
    8000685e:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006862:	0015e593          	ori	a1,a1,1
    80006866:	00b61623          	sh	a1,12(a2)
  disk[n].desc[idx[1]].next = idx[2];
    8000686a:	f8842603          	lw	a2,-120(s0)
    8000686e:	630c                	ld	a1,0(a4)
    80006870:	96ae                	add	a3,a3,a1
    80006872:	00c69723          	sh	a2,14(a3) # 100e <_entry-0x7fffeff2>

  disk[n].info[idx[0]].status = 0;
    80006876:	97d6                	add	a5,a5,s5
    80006878:	07a2                	slli	a5,a5,0x8
    8000687a:	97a6                	add	a5,a5,s1
    8000687c:	20078793          	addi	a5,a5,512
    80006880:	0792                	slli	a5,a5,0x4
    80006882:	97aa                	add	a5,a5,a0
    80006884:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006888:	00461693          	slli	a3,a2,0x4
    8000688c:	00073803          	ld	a6,0(a4)
    80006890:	9836                	add	a6,a6,a3
    80006892:	20348613          	addi	a2,s1,515
    80006896:	001a9593          	slli	a1,s5,0x1
    8000689a:	95d6                	add	a1,a1,s5
    8000689c:	05a2                	slli	a1,a1,0x8
    8000689e:	962e                	add	a2,a2,a1
    800068a0:	0612                	slli	a2,a2,0x4
    800068a2:	962a                	add	a2,a2,a0
    800068a4:	00c83023          	sd	a2,0(a6) # 2000 <_entry-0x7fffe000>
  disk[n].desc[idx[2]].len = 1;
    800068a8:	630c                	ld	a1,0(a4)
    800068aa:	95b6                	add	a1,a1,a3
    800068ac:	4605                	li	a2,1
    800068ae:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800068b0:	630c                	ld	a1,0(a4)
    800068b2:	95b6                	add	a1,a1,a3
    800068b4:	4509                	li	a0,2
    800068b6:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    800068ba:	630c                	ld	a1,0(a4)
    800068bc:	96ae                	add	a3,a3,a1
    800068be:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800068c2:	00cc2223          	sw	a2,4(s8) # fffffffffffff004 <end+0xffffffff7ffcafa8>
  disk[n].info[idx[0]].b = b;
    800068c6:	0387b423          	sd	s8,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    800068ca:	6714                	ld	a3,8(a4)
    800068cc:	0026d783          	lhu	a5,2(a3)
    800068d0:	8b9d                	andi	a5,a5,7
    800068d2:	0789                	addi	a5,a5,2
    800068d4:	0786                	slli	a5,a5,0x1
    800068d6:	97b6                	add	a5,a5,a3
    800068d8:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    800068dc:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    800068e0:	6718                	ld	a4,8(a4)
    800068e2:	00275783          	lhu	a5,2(a4)
    800068e6:	2785                	addiw	a5,a5,1
    800068e8:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800068ec:	001a879b          	addiw	a5,s5,1
    800068f0:	00c7979b          	slliw	a5,a5,0xc
    800068f4:	10000737          	lui	a4,0x10000
    800068f8:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    800068fc:	97ba                	add	a5,a5,a4
    800068fe:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006902:	004c2783          	lw	a5,4(s8)
    80006906:	00c79d63          	bne	a5,a2,80006920 <virtio_disk_rw+0x1d6>
    8000690a:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    8000690c:	85e6                	mv	a1,s9
    8000690e:	8562                	mv	a0,s8
    80006910:	ffffc097          	auipc	ra,0xffffc
    80006914:	a58080e7          	jalr	-1448(ra) # 80002368 <sleep>
  while(b->disk == 1) {
    80006918:	004c2783          	lw	a5,4(s8)
    8000691c:	fe9788e3          	beq	a5,s1,8000690c <virtio_disk_rw+0x1c2>
  }

  disk[n].info[idx[0]].b = 0;
    80006920:	f8042483          	lw	s1,-128(s0)
    80006924:	001a9793          	slli	a5,s5,0x1
    80006928:	97d6                	add	a5,a5,s5
    8000692a:	07a2                	slli	a5,a5,0x8
    8000692c:	97a6                	add	a5,a5,s1
    8000692e:	20078793          	addi	a5,a5,512
    80006932:	0792                	slli	a5,a5,0x4
    80006934:	00027717          	auipc	a4,0x27
    80006938:	6cc70713          	addi	a4,a4,1740 # 8002e000 <disk>
    8000693c:	97ba                	add	a5,a5,a4
    8000693e:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006942:	001a9793          	slli	a5,s5,0x1
    80006946:	97d6                	add	a5,a5,s5
    80006948:	07b2                	slli	a5,a5,0xc
    8000694a:	97ba                	add	a5,a5,a4
    8000694c:	6909                	lui	s2,0x2
    8000694e:	993e                	add	s2,s2,a5
    80006950:	a019                	j	80006956 <virtio_disk_rw+0x20c>
      i = disk[n].desc[i].next;
    80006952:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    80006956:	85a6                	mv	a1,s1
    80006958:	8556                	mv	a0,s5
    8000695a:	00000097          	auipc	ra,0x0
    8000695e:	b6c080e7          	jalr	-1172(ra) # 800064c6 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006962:	0492                	slli	s1,s1,0x4
    80006964:	00093783          	ld	a5,0(s2) # 2000 <_entry-0x7fffe000>
    80006968:	94be                	add	s1,s1,a5
    8000696a:	00c4d783          	lhu	a5,12(s1)
    8000696e:	8b85                	andi	a5,a5,1
    80006970:	f3ed                	bnez	a5,80006952 <virtio_disk_rw+0x208>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    80006972:	8566                	mv	a0,s9
    80006974:	ffffa097          	auipc	ra,0xffffa
    80006978:	1fc080e7          	jalr	508(ra) # 80000b70 <release>
}
    8000697c:	60ea                	ld	ra,152(sp)
    8000697e:	644a                	ld	s0,144(sp)
    80006980:	64aa                	ld	s1,136(sp)
    80006982:	690a                	ld	s2,128(sp)
    80006984:	79e6                	ld	s3,120(sp)
    80006986:	7a46                	ld	s4,112(sp)
    80006988:	7aa6                	ld	s5,104(sp)
    8000698a:	7b06                	ld	s6,96(sp)
    8000698c:	6be6                	ld	s7,88(sp)
    8000698e:	6c46                	ld	s8,80(sp)
    80006990:	6ca6                	ld	s9,72(sp)
    80006992:	6d06                	ld	s10,64(sp)
    80006994:	7de2                	ld	s11,56(sp)
    80006996:	610d                	addi	sp,sp,160
    80006998:	8082                	ret
  if(write)
    8000699a:	01b037b3          	snez	a5,s11
    8000699e:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    800069a2:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    800069a6:	f6843783          	ld	a5,-152(s0)
    800069aa:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    800069ae:	f8042483          	lw	s1,-128(s0)
    800069b2:	00449993          	slli	s3,s1,0x4
    800069b6:	001a9793          	slli	a5,s5,0x1
    800069ba:	97d6                	add	a5,a5,s5
    800069bc:	07b2                	slli	a5,a5,0xc
    800069be:	00027917          	auipc	s2,0x27
    800069c2:	64290913          	addi	s2,s2,1602 # 8002e000 <disk>
    800069c6:	97ca                	add	a5,a5,s2
    800069c8:	6909                	lui	s2,0x2
    800069ca:	993e                	add	s2,s2,a5
    800069cc:	00093a03          	ld	s4,0(s2) # 2000 <_entry-0x7fffe000>
    800069d0:	9a4e                	add	s4,s4,s3
    800069d2:	f7040513          	addi	a0,s0,-144
    800069d6:	ffffa097          	auipc	ra,0xffffa
    800069da:	7d4080e7          	jalr	2004(ra) # 800011aa <kvmpa>
    800069de:	00aa3023          	sd	a0,0(s4)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    800069e2:	00093783          	ld	a5,0(s2)
    800069e6:	97ce                	add	a5,a5,s3
    800069e8:	4741                	li	a4,16
    800069ea:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800069ec:	00093783          	ld	a5,0(s2)
    800069f0:	97ce                	add	a5,a5,s3
    800069f2:	4705                	li	a4,1
    800069f4:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    800069f8:	f8442683          	lw	a3,-124(s0)
    800069fc:	00093783          	ld	a5,0(s2)
    80006a00:	99be                	add	s3,s3,a5
    80006a02:	00d99723          	sh	a3,14(s3)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006a06:	0692                	slli	a3,a3,0x4
    80006a08:	00093783          	ld	a5,0(s2)
    80006a0c:	97b6                	add	a5,a5,a3
    80006a0e:	060c0713          	addi	a4,s8,96
    80006a12:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006a14:	00093783          	ld	a5,0(s2)
    80006a18:	97b6                	add	a5,a5,a3
    80006a1a:	40000713          	li	a4,1024
    80006a1e:	c798                	sw	a4,8(a5)
  if(write)
    80006a20:	e00d92e3          	bnez	s11,80006824 <virtio_disk_rw+0xda>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006a24:	001a9793          	slli	a5,s5,0x1
    80006a28:	97d6                	add	a5,a5,s5
    80006a2a:	07b2                	slli	a5,a5,0xc
    80006a2c:	00027717          	auipc	a4,0x27
    80006a30:	5d470713          	addi	a4,a4,1492 # 8002e000 <disk>
    80006a34:	973e                	add	a4,a4,a5
    80006a36:	6789                	lui	a5,0x2
    80006a38:	97ba                	add	a5,a5,a4
    80006a3a:	639c                	ld	a5,0(a5)
    80006a3c:	97b6                	add	a5,a5,a3
    80006a3e:	4709                	li	a4,2
    80006a40:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    80006a44:	bbfd                	j	80006842 <virtio_disk_rw+0xf8>

0000000080006a46 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006a46:	7139                	addi	sp,sp,-64
    80006a48:	fc06                	sd	ra,56(sp)
    80006a4a:	f822                	sd	s0,48(sp)
    80006a4c:	f426                	sd	s1,40(sp)
    80006a4e:	f04a                	sd	s2,32(sp)
    80006a50:	ec4e                	sd	s3,24(sp)
    80006a52:	e852                	sd	s4,16(sp)
    80006a54:	e456                	sd	s5,8(sp)
    80006a56:	0080                	addi	s0,sp,64
    80006a58:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    80006a5a:	00151913          	slli	s2,a0,0x1
    80006a5e:	00a90a33          	add	s4,s2,a0
    80006a62:	0a32                	slli	s4,s4,0xc
    80006a64:	6989                	lui	s3,0x2
    80006a66:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    80006a6a:	9a3e                	add	s4,s4,a5
    80006a6c:	00027a97          	auipc	s5,0x27
    80006a70:	594a8a93          	addi	s5,s5,1428 # 8002e000 <disk>
    80006a74:	9a56                	add	s4,s4,s5
    80006a76:	8552                	mv	a0,s4
    80006a78:	ffffa097          	auipc	ra,0xffffa
    80006a7c:	028080e7          	jalr	40(ra) # 80000aa0 <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006a80:	9926                	add	s2,s2,s1
    80006a82:	0932                	slli	s2,s2,0xc
    80006a84:	9956                	add	s2,s2,s5
    80006a86:	99ca                	add	s3,s3,s2
    80006a88:	0209d783          	lhu	a5,32(s3)
    80006a8c:	0109b703          	ld	a4,16(s3)
    80006a90:	00275683          	lhu	a3,2(a4)
    80006a94:	8ebd                	xor	a3,a3,a5
    80006a96:	8a9d                	andi	a3,a3,7
    80006a98:	c2a5                	beqz	a3,80006af8 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    80006a9a:	8956                	mv	s2,s5
    80006a9c:	00149693          	slli	a3,s1,0x1
    80006aa0:	96a6                	add	a3,a3,s1
    80006aa2:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006aa6:	06b2                	slli	a3,a3,0xc
    80006aa8:	96d6                	add	a3,a3,s5
    80006aaa:	6489                	lui	s1,0x2
    80006aac:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006aae:	078e                	slli	a5,a5,0x3
    80006ab0:	97ba                	add	a5,a5,a4
    80006ab2:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006ab4:	00f98733          	add	a4,s3,a5
    80006ab8:	20070713          	addi	a4,a4,512
    80006abc:	0712                	slli	a4,a4,0x4
    80006abe:	974a                	add	a4,a4,s2
    80006ac0:	03074703          	lbu	a4,48(a4)
    80006ac4:	eb21                	bnez	a4,80006b14 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006ac6:	97ce                	add	a5,a5,s3
    80006ac8:	20078793          	addi	a5,a5,512
    80006acc:	0792                	slli	a5,a5,0x4
    80006ace:	97ca                	add	a5,a5,s2
    80006ad0:	7798                	ld	a4,40(a5)
    80006ad2:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006ad6:	7788                	ld	a0,40(a5)
    80006ad8:	ffffc097          	auipc	ra,0xffffc
    80006adc:	a12080e7          	jalr	-1518(ra) # 800024ea <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006ae0:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006ae4:	2785                	addiw	a5,a5,1
    80006ae6:	8b9d                	andi	a5,a5,7
    80006ae8:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006aec:	6898                	ld	a4,16(s1)
    80006aee:	00275683          	lhu	a3,2(a4)
    80006af2:	8a9d                	andi	a3,a3,7
    80006af4:	faf69de3          	bne	a3,a5,80006aae <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    80006af8:	8552                	mv	a0,s4
    80006afa:	ffffa097          	auipc	ra,0xffffa
    80006afe:	076080e7          	jalr	118(ra) # 80000b70 <release>
}
    80006b02:	70e2                	ld	ra,56(sp)
    80006b04:	7442                	ld	s0,48(sp)
    80006b06:	74a2                	ld	s1,40(sp)
    80006b08:	7902                	ld	s2,32(sp)
    80006b0a:	69e2                	ld	s3,24(sp)
    80006b0c:	6a42                	ld	s4,16(sp)
    80006b0e:	6aa2                	ld	s5,8(sp)
    80006b10:	6121                	addi	sp,sp,64
    80006b12:	8082                	ret
      panic("virtio_disk_intr status");
    80006b14:	00002517          	auipc	a0,0x2
    80006b18:	25c50513          	addi	a0,a0,604 # 80008d70 <userret+0xce0>
    80006b1c:	ffffa097          	auipc	ra,0xffffa
    80006b20:	a38080e7          	jalr	-1480(ra) # 80000554 <panic>

0000000080006b24 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80006b24:	1141                	addi	sp,sp,-16
    80006b26:	e422                	sd	s0,8(sp)
    80006b28:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    80006b2a:	41f5d79b          	sraiw	a5,a1,0x1f
    80006b2e:	01d7d79b          	srliw	a5,a5,0x1d
    80006b32:	9dbd                	addw	a1,a1,a5
    80006b34:	0075f713          	andi	a4,a1,7
    80006b38:	9f1d                	subw	a4,a4,a5
    80006b3a:	4785                	li	a5,1
    80006b3c:	00e797bb          	sllw	a5,a5,a4
    80006b40:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    80006b44:	4035d59b          	sraiw	a1,a1,0x3
    80006b48:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80006b4a:	0005c503          	lbu	a0,0(a1)
    80006b4e:	8d7d                	and	a0,a0,a5
    80006b50:	8d1d                	sub	a0,a0,a5
}
    80006b52:	00153513          	seqz	a0,a0
    80006b56:	6422                	ld	s0,8(sp)
    80006b58:	0141                	addi	sp,sp,16
    80006b5a:	8082                	ret

0000000080006b5c <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006b5c:	1141                	addi	sp,sp,-16
    80006b5e:	e422                	sd	s0,8(sp)
    80006b60:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006b62:	41f5d79b          	sraiw	a5,a1,0x1f
    80006b66:	01d7d79b          	srliw	a5,a5,0x1d
    80006b6a:	9dbd                	addw	a1,a1,a5
    80006b6c:	4035d71b          	sraiw	a4,a1,0x3
    80006b70:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006b72:	899d                	andi	a1,a1,7
    80006b74:	9d9d                	subw	a1,a1,a5
    80006b76:	4785                	li	a5,1
    80006b78:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    80006b7c:	00054783          	lbu	a5,0(a0)
    80006b80:	8ddd                	or	a1,a1,a5
    80006b82:	00b50023          	sb	a1,0(a0)
}
    80006b86:	6422                	ld	s0,8(sp)
    80006b88:	0141                	addi	sp,sp,16
    80006b8a:	8082                	ret

0000000080006b8c <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80006b8c:	1141                	addi	sp,sp,-16
    80006b8e:	e422                	sd	s0,8(sp)
    80006b90:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006b92:	41f5d79b          	sraiw	a5,a1,0x1f
    80006b96:	01d7d79b          	srliw	a5,a5,0x1d
    80006b9a:	9dbd                	addw	a1,a1,a5
    80006b9c:	4035d71b          	sraiw	a4,a1,0x3
    80006ba0:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006ba2:	899d                	andi	a1,a1,7
    80006ba4:	9d9d                	subw	a1,a1,a5
    80006ba6:	4785                	li	a5,1
    80006ba8:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    80006bac:	fff5c593          	not	a1,a1
    80006bb0:	00054783          	lbu	a5,0(a0)
    80006bb4:	8dfd                	and	a1,a1,a5
    80006bb6:	00b50023          	sb	a1,0(a0)
}
    80006bba:	6422                	ld	s0,8(sp)
    80006bbc:	0141                	addi	sp,sp,16
    80006bbe:	8082                	ret

0000000080006bc0 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006bc0:	715d                	addi	sp,sp,-80
    80006bc2:	e486                	sd	ra,72(sp)
    80006bc4:	e0a2                	sd	s0,64(sp)
    80006bc6:	fc26                	sd	s1,56(sp)
    80006bc8:	f84a                	sd	s2,48(sp)
    80006bca:	f44e                	sd	s3,40(sp)
    80006bcc:	f052                	sd	s4,32(sp)
    80006bce:	ec56                	sd	s5,24(sp)
    80006bd0:	e85a                	sd	s6,16(sp)
    80006bd2:	e45e                	sd	s7,8(sp)
    80006bd4:	0880                	addi	s0,sp,80
    80006bd6:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006bd8:	08b05b63          	blez	a1,80006c6e <bd_print_vector+0xae>
    80006bdc:	89aa                	mv	s3,a0
    80006bde:	4481                	li	s1,0
  lb = 0;
    80006be0:	4a81                	li	s5,0
  last = 1;
    80006be2:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006be4:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006be6:	00002b97          	auipc	s7,0x2
    80006bea:	1a2b8b93          	addi	s7,s7,418 # 80008d88 <userret+0xcf8>
    80006bee:	a821                	j	80006c06 <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80006bf0:	85a6                	mv	a1,s1
    80006bf2:	854e                	mv	a0,s3
    80006bf4:	00000097          	auipc	ra,0x0
    80006bf8:	f30080e7          	jalr	-208(ra) # 80006b24 <bit_isset>
    80006bfc:	892a                	mv	s2,a0
    80006bfe:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006c00:	2485                	addiw	s1,s1,1
    80006c02:	029a0463          	beq	s4,s1,80006c2a <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006c06:	85a6                	mv	a1,s1
    80006c08:	854e                	mv	a0,s3
    80006c0a:	00000097          	auipc	ra,0x0
    80006c0e:	f1a080e7          	jalr	-230(ra) # 80006b24 <bit_isset>
    80006c12:	ff2507e3          	beq	a0,s2,80006c00 <bd_print_vector+0x40>
    if(last == 1)
    80006c16:	fd691de3          	bne	s2,s6,80006bf0 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    80006c1a:	8626                	mv	a2,s1
    80006c1c:	85d6                	mv	a1,s5
    80006c1e:	855e                	mv	a0,s7
    80006c20:	ffffa097          	auipc	ra,0xffffa
    80006c24:	98e080e7          	jalr	-1650(ra) # 800005ae <printf>
    80006c28:	b7e1                	j	80006bf0 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80006c2a:	000a8563          	beqz	s5,80006c34 <bd_print_vector+0x74>
    80006c2e:	4785                	li	a5,1
    80006c30:	00f91c63          	bne	s2,a5,80006c48 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006c34:	8652                	mv	a2,s4
    80006c36:	85d6                	mv	a1,s5
    80006c38:	00002517          	auipc	a0,0x2
    80006c3c:	15050513          	addi	a0,a0,336 # 80008d88 <userret+0xcf8>
    80006c40:	ffffa097          	auipc	ra,0xffffa
    80006c44:	96e080e7          	jalr	-1682(ra) # 800005ae <printf>
  }
  printf("\n");
    80006c48:	00002517          	auipc	a0,0x2
    80006c4c:	ff850513          	addi	a0,a0,-8 # 80008c40 <userret+0xbb0>
    80006c50:	ffffa097          	auipc	ra,0xffffa
    80006c54:	95e080e7          	jalr	-1698(ra) # 800005ae <printf>
}
    80006c58:	60a6                	ld	ra,72(sp)
    80006c5a:	6406                	ld	s0,64(sp)
    80006c5c:	74e2                	ld	s1,56(sp)
    80006c5e:	7942                	ld	s2,48(sp)
    80006c60:	79a2                	ld	s3,40(sp)
    80006c62:	7a02                	ld	s4,32(sp)
    80006c64:	6ae2                	ld	s5,24(sp)
    80006c66:	6b42                	ld	s6,16(sp)
    80006c68:	6ba2                	ld	s7,8(sp)
    80006c6a:	6161                	addi	sp,sp,80
    80006c6c:	8082                	ret
  lb = 0;
    80006c6e:	4a81                	li	s5,0
    80006c70:	b7d1                	j	80006c34 <bd_print_vector+0x74>

0000000080006c72 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    80006c72:	0002d697          	auipc	a3,0x2d
    80006c76:	3e66a683          	lw	a3,998(a3) # 80034058 <nsizes>
    80006c7a:	10d05063          	blez	a3,80006d7a <bd_print+0x108>
bd_print() {
    80006c7e:	711d                	addi	sp,sp,-96
    80006c80:	ec86                	sd	ra,88(sp)
    80006c82:	e8a2                	sd	s0,80(sp)
    80006c84:	e4a6                	sd	s1,72(sp)
    80006c86:	e0ca                	sd	s2,64(sp)
    80006c88:	fc4e                	sd	s3,56(sp)
    80006c8a:	f852                	sd	s4,48(sp)
    80006c8c:	f456                	sd	s5,40(sp)
    80006c8e:	f05a                	sd	s6,32(sp)
    80006c90:	ec5e                	sd	s7,24(sp)
    80006c92:	e862                	sd	s8,16(sp)
    80006c94:	e466                	sd	s9,8(sp)
    80006c96:	e06a                	sd	s10,0(sp)
    80006c98:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    80006c9a:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006c9c:	4a85                	li	s5,1
    80006c9e:	4c41                	li	s8,16
    80006ca0:	00002b97          	auipc	s7,0x2
    80006ca4:	0f8b8b93          	addi	s7,s7,248 # 80008d98 <userret+0xd08>
    lst_print(&bd_sizes[k].free);
    80006ca8:	0002da17          	auipc	s4,0x2d
    80006cac:	3a8a0a13          	addi	s4,s4,936 # 80034050 <bd_sizes>
    printf("  alloc:");
    80006cb0:	00002b17          	auipc	s6,0x2
    80006cb4:	110b0b13          	addi	s6,s6,272 # 80008dc0 <userret+0xd30>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006cb8:	0002d997          	auipc	s3,0x2d
    80006cbc:	3a098993          	addi	s3,s3,928 # 80034058 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006cc0:	00002c97          	auipc	s9,0x2
    80006cc4:	110c8c93          	addi	s9,s9,272 # 80008dd0 <userret+0xd40>
    80006cc8:	a801                	j	80006cd8 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    80006cca:	0009a683          	lw	a3,0(s3)
    80006cce:	0485                	addi	s1,s1,1
    80006cd0:	0004879b          	sext.w	a5,s1
    80006cd4:	08d7d563          	bge	a5,a3,80006d5e <bd_print+0xec>
    80006cd8:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006cdc:	36fd                	addiw	a3,a3,-1
    80006cde:	9e85                	subw	a3,a3,s1
    80006ce0:	00da96bb          	sllw	a3,s5,a3
    80006ce4:	009c1633          	sll	a2,s8,s1
    80006ce8:	85ca                	mv	a1,s2
    80006cea:	855e                	mv	a0,s7
    80006cec:	ffffa097          	auipc	ra,0xffffa
    80006cf0:	8c2080e7          	jalr	-1854(ra) # 800005ae <printf>
    lst_print(&bd_sizes[k].free);
    80006cf4:	00549d13          	slli	s10,s1,0x5
    80006cf8:	000a3503          	ld	a0,0(s4)
    80006cfc:	956a                	add	a0,a0,s10
    80006cfe:	00001097          	auipc	ra,0x1
    80006d02:	a56080e7          	jalr	-1450(ra) # 80007754 <lst_print>
    printf("  alloc:");
    80006d06:	855a                	mv	a0,s6
    80006d08:	ffffa097          	auipc	ra,0xffffa
    80006d0c:	8a6080e7          	jalr	-1882(ra) # 800005ae <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006d10:	0009a583          	lw	a1,0(s3)
    80006d14:	35fd                	addiw	a1,a1,-1
    80006d16:	412585bb          	subw	a1,a1,s2
    80006d1a:	000a3783          	ld	a5,0(s4)
    80006d1e:	97ea                	add	a5,a5,s10
    80006d20:	00ba95bb          	sllw	a1,s5,a1
    80006d24:	6b88                	ld	a0,16(a5)
    80006d26:	00000097          	auipc	ra,0x0
    80006d2a:	e9a080e7          	jalr	-358(ra) # 80006bc0 <bd_print_vector>
    if(k > 0) {
    80006d2e:	f9205ee3          	blez	s2,80006cca <bd_print+0x58>
      printf("  split:");
    80006d32:	8566                	mv	a0,s9
    80006d34:	ffffa097          	auipc	ra,0xffffa
    80006d38:	87a080e7          	jalr	-1926(ra) # 800005ae <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80006d3c:	0009a583          	lw	a1,0(s3)
    80006d40:	35fd                	addiw	a1,a1,-1
    80006d42:	412585bb          	subw	a1,a1,s2
    80006d46:	000a3783          	ld	a5,0(s4)
    80006d4a:	9d3e                	add	s10,s10,a5
    80006d4c:	00ba95bb          	sllw	a1,s5,a1
    80006d50:	018d3503          	ld	a0,24(s10)
    80006d54:	00000097          	auipc	ra,0x0
    80006d58:	e6c080e7          	jalr	-404(ra) # 80006bc0 <bd_print_vector>
    80006d5c:	b7bd                	j	80006cca <bd_print+0x58>
    }
  }
}
    80006d5e:	60e6                	ld	ra,88(sp)
    80006d60:	6446                	ld	s0,80(sp)
    80006d62:	64a6                	ld	s1,72(sp)
    80006d64:	6906                	ld	s2,64(sp)
    80006d66:	79e2                	ld	s3,56(sp)
    80006d68:	7a42                	ld	s4,48(sp)
    80006d6a:	7aa2                	ld	s5,40(sp)
    80006d6c:	7b02                	ld	s6,32(sp)
    80006d6e:	6be2                	ld	s7,24(sp)
    80006d70:	6c42                	ld	s8,16(sp)
    80006d72:	6ca2                	ld	s9,8(sp)
    80006d74:	6d02                	ld	s10,0(sp)
    80006d76:	6125                	addi	sp,sp,96
    80006d78:	8082                	ret
    80006d7a:	8082                	ret

0000000080006d7c <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80006d7c:	1141                	addi	sp,sp,-16
    80006d7e:	e422                	sd	s0,8(sp)
    80006d80:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006d82:	47c1                	li	a5,16
    80006d84:	00a7fb63          	bgeu	a5,a0,80006d9a <firstk+0x1e>
    80006d88:	872a                	mv	a4,a0
  int k = 0;
    80006d8a:	4501                	li	a0,0
    k++;
    80006d8c:	2505                	addiw	a0,a0,1
    size *= 2;
    80006d8e:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006d90:	fee7eee3          	bltu	a5,a4,80006d8c <firstk+0x10>
  }
  return k;
}
    80006d94:	6422                	ld	s0,8(sp)
    80006d96:	0141                	addi	sp,sp,16
    80006d98:	8082                	ret
  int k = 0;
    80006d9a:	4501                	li	a0,0
    80006d9c:	bfe5                	j	80006d94 <firstk+0x18>

0000000080006d9e <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006d9e:	1141                	addi	sp,sp,-16
    80006da0:	e422                	sd	s0,8(sp)
    80006da2:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006da4:	0002d797          	auipc	a5,0x2d
    80006da8:	2a47b783          	ld	a5,676(a5) # 80034048 <bd_base>
    80006dac:	9d9d                	subw	a1,a1,a5
    80006dae:	47c1                	li	a5,16
    80006db0:	00a797b3          	sll	a5,a5,a0
    80006db4:	02f5c5b3          	div	a1,a1,a5
}
    80006db8:	0005851b          	sext.w	a0,a1
    80006dbc:	6422                	ld	s0,8(sp)
    80006dbe:	0141                	addi	sp,sp,16
    80006dc0:	8082                	ret

0000000080006dc2 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006dc2:	1141                	addi	sp,sp,-16
    80006dc4:	e422                	sd	s0,8(sp)
    80006dc6:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006dc8:	47c1                	li	a5,16
    80006dca:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006dce:	02b787bb          	mulw	a5,a5,a1
}
    80006dd2:	0002d517          	auipc	a0,0x2d
    80006dd6:	27653503          	ld	a0,630(a0) # 80034048 <bd_base>
    80006dda:	953e                	add	a0,a0,a5
    80006ddc:	6422                	ld	s0,8(sp)
    80006dde:	0141                	addi	sp,sp,16
    80006de0:	8082                	ret

0000000080006de2 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006de2:	7159                	addi	sp,sp,-112
    80006de4:	f486                	sd	ra,104(sp)
    80006de6:	f0a2                	sd	s0,96(sp)
    80006de8:	eca6                	sd	s1,88(sp)
    80006dea:	e8ca                	sd	s2,80(sp)
    80006dec:	e4ce                	sd	s3,72(sp)
    80006dee:	e0d2                	sd	s4,64(sp)
    80006df0:	fc56                	sd	s5,56(sp)
    80006df2:	f85a                	sd	s6,48(sp)
    80006df4:	f45e                	sd	s7,40(sp)
    80006df6:	f062                	sd	s8,32(sp)
    80006df8:	ec66                	sd	s9,24(sp)
    80006dfa:	e86a                	sd	s10,16(sp)
    80006dfc:	e46e                	sd	s11,8(sp)
    80006dfe:	1880                	addi	s0,sp,112
    80006e00:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006e02:	0002d517          	auipc	a0,0x2d
    80006e06:	1fe50513          	addi	a0,a0,510 # 80034000 <lock>
    80006e0a:	ffffa097          	auipc	ra,0xffffa
    80006e0e:	c96080e7          	jalr	-874(ra) # 80000aa0 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006e12:	8526                	mv	a0,s1
    80006e14:	00000097          	auipc	ra,0x0
    80006e18:	f68080e7          	jalr	-152(ra) # 80006d7c <firstk>
  for (k = fk; k < nsizes; k++) {
    80006e1c:	0002d797          	auipc	a5,0x2d
    80006e20:	23c7a783          	lw	a5,572(a5) # 80034058 <nsizes>
    80006e24:	02f55d63          	bge	a0,a5,80006e5e <bd_malloc+0x7c>
    80006e28:	8c2a                	mv	s8,a0
    80006e2a:	00551913          	slli	s2,a0,0x5
    80006e2e:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006e30:	0002d997          	auipc	s3,0x2d
    80006e34:	22098993          	addi	s3,s3,544 # 80034050 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006e38:	0002da17          	auipc	s4,0x2d
    80006e3c:	220a0a13          	addi	s4,s4,544 # 80034058 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006e40:	0009b503          	ld	a0,0(s3)
    80006e44:	954a                	add	a0,a0,s2
    80006e46:	00001097          	auipc	ra,0x1
    80006e4a:	894080e7          	jalr	-1900(ra) # 800076da <lst_empty>
    80006e4e:	c115                	beqz	a0,80006e72 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006e50:	2485                	addiw	s1,s1,1
    80006e52:	02090913          	addi	s2,s2,32
    80006e56:	000a2783          	lw	a5,0(s4)
    80006e5a:	fef4c3e3          	blt	s1,a5,80006e40 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006e5e:	0002d517          	auipc	a0,0x2d
    80006e62:	1a250513          	addi	a0,a0,418 # 80034000 <lock>
    80006e66:	ffffa097          	auipc	ra,0xffffa
    80006e6a:	d0a080e7          	jalr	-758(ra) # 80000b70 <release>
    return 0;
    80006e6e:	4b01                	li	s6,0
    80006e70:	a0e1                	j	80006f38 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80006e72:	0002d797          	auipc	a5,0x2d
    80006e76:	1e67a783          	lw	a5,486(a5) # 80034058 <nsizes>
    80006e7a:	fef4d2e3          	bge	s1,a5,80006e5e <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006e7e:	00549993          	slli	s3,s1,0x5
    80006e82:	0002d917          	auipc	s2,0x2d
    80006e86:	1ce90913          	addi	s2,s2,462 # 80034050 <bd_sizes>
    80006e8a:	00093503          	ld	a0,0(s2)
    80006e8e:	954e                	add	a0,a0,s3
    80006e90:	00001097          	auipc	ra,0x1
    80006e94:	876080e7          	jalr	-1930(ra) # 80007706 <lst_pop>
    80006e98:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006e9a:	0002d597          	auipc	a1,0x2d
    80006e9e:	1ae5b583          	ld	a1,430(a1) # 80034048 <bd_base>
    80006ea2:	40b505bb          	subw	a1,a0,a1
    80006ea6:	47c1                	li	a5,16
    80006ea8:	009797b3          	sll	a5,a5,s1
    80006eac:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006eb0:	00093783          	ld	a5,0(s2)
    80006eb4:	97ce                	add	a5,a5,s3
    80006eb6:	2581                	sext.w	a1,a1
    80006eb8:	6b88                	ld	a0,16(a5)
    80006eba:	00000097          	auipc	ra,0x0
    80006ebe:	ca2080e7          	jalr	-862(ra) # 80006b5c <bit_set>
  for(; k > fk; k--) {
    80006ec2:	069c5363          	bge	s8,s1,80006f28 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006ec6:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006ec8:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006eca:	0002dd17          	auipc	s10,0x2d
    80006ece:	17ed0d13          	addi	s10,s10,382 # 80034048 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006ed2:	85a6                	mv	a1,s1
    80006ed4:	34fd                	addiw	s1,s1,-1
    80006ed6:	009b9ab3          	sll	s5,s7,s1
    80006eda:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006ede:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
  int n = p - (char *) bd_base;
    80006ee2:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006ee6:	412b093b          	subw	s2,s6,s2
    80006eea:	00bb95b3          	sll	a1,s7,a1
    80006eee:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006ef2:	013a07b3          	add	a5,s4,s3
    80006ef6:	2581                	sext.w	a1,a1
    80006ef8:	6f88                	ld	a0,24(a5)
    80006efa:	00000097          	auipc	ra,0x0
    80006efe:	c62080e7          	jalr	-926(ra) # 80006b5c <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006f02:	1981                	addi	s3,s3,-32
    80006f04:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006f06:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006f0a:	2581                	sext.w	a1,a1
    80006f0c:	010a3503          	ld	a0,16(s4)
    80006f10:	00000097          	auipc	ra,0x0
    80006f14:	c4c080e7          	jalr	-948(ra) # 80006b5c <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006f18:	85e6                	mv	a1,s9
    80006f1a:	8552                	mv	a0,s4
    80006f1c:	00001097          	auipc	ra,0x1
    80006f20:	820080e7          	jalr	-2016(ra) # 8000773c <lst_push>
  for(; k > fk; k--) {
    80006f24:	fb8497e3          	bne	s1,s8,80006ed2 <bd_malloc+0xf0>
  }
  release(&lock);
    80006f28:	0002d517          	auipc	a0,0x2d
    80006f2c:	0d850513          	addi	a0,a0,216 # 80034000 <lock>
    80006f30:	ffffa097          	auipc	ra,0xffffa
    80006f34:	c40080e7          	jalr	-960(ra) # 80000b70 <release>

  return p;
}
    80006f38:	855a                	mv	a0,s6
    80006f3a:	70a6                	ld	ra,104(sp)
    80006f3c:	7406                	ld	s0,96(sp)
    80006f3e:	64e6                	ld	s1,88(sp)
    80006f40:	6946                	ld	s2,80(sp)
    80006f42:	69a6                	ld	s3,72(sp)
    80006f44:	6a06                	ld	s4,64(sp)
    80006f46:	7ae2                	ld	s5,56(sp)
    80006f48:	7b42                	ld	s6,48(sp)
    80006f4a:	7ba2                	ld	s7,40(sp)
    80006f4c:	7c02                	ld	s8,32(sp)
    80006f4e:	6ce2                	ld	s9,24(sp)
    80006f50:	6d42                	ld	s10,16(sp)
    80006f52:	6da2                	ld	s11,8(sp)
    80006f54:	6165                	addi	sp,sp,112
    80006f56:	8082                	ret

0000000080006f58 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006f58:	7139                	addi	sp,sp,-64
    80006f5a:	fc06                	sd	ra,56(sp)
    80006f5c:	f822                	sd	s0,48(sp)
    80006f5e:	f426                	sd	s1,40(sp)
    80006f60:	f04a                	sd	s2,32(sp)
    80006f62:	ec4e                	sd	s3,24(sp)
    80006f64:	e852                	sd	s4,16(sp)
    80006f66:	e456                	sd	s5,8(sp)
    80006f68:	e05a                	sd	s6,0(sp)
    80006f6a:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006f6c:	0002da97          	auipc	s5,0x2d
    80006f70:	0ecaaa83          	lw	s5,236(s5) # 80034058 <nsizes>
  return n / BLK_SIZE(k);
    80006f74:	0002da17          	auipc	s4,0x2d
    80006f78:	0d4a3a03          	ld	s4,212(s4) # 80034048 <bd_base>
    80006f7c:	41450a3b          	subw	s4,a0,s4
    80006f80:	0002d497          	auipc	s1,0x2d
    80006f84:	0d04b483          	ld	s1,208(s1) # 80034050 <bd_sizes>
    80006f88:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006f8c:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006f8e:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006f90:	03595363          	bge	s2,s5,80006fb6 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006f94:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006f98:	013b15b3          	sll	a1,s6,s3
    80006f9c:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006fa0:	2581                	sext.w	a1,a1
    80006fa2:	6088                	ld	a0,0(s1)
    80006fa4:	00000097          	auipc	ra,0x0
    80006fa8:	b80080e7          	jalr	-1152(ra) # 80006b24 <bit_isset>
    80006fac:	02048493          	addi	s1,s1,32
    80006fb0:	e501                	bnez	a0,80006fb8 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006fb2:	894e                	mv	s2,s3
    80006fb4:	bff1                	j	80006f90 <size+0x38>
      return k;
    }
  }
  return 0;
    80006fb6:	4901                	li	s2,0
}
    80006fb8:	854a                	mv	a0,s2
    80006fba:	70e2                	ld	ra,56(sp)
    80006fbc:	7442                	ld	s0,48(sp)
    80006fbe:	74a2                	ld	s1,40(sp)
    80006fc0:	7902                	ld	s2,32(sp)
    80006fc2:	69e2                	ld	s3,24(sp)
    80006fc4:	6a42                	ld	s4,16(sp)
    80006fc6:	6aa2                	ld	s5,8(sp)
    80006fc8:	6b02                	ld	s6,0(sp)
    80006fca:	6121                	addi	sp,sp,64
    80006fcc:	8082                	ret

0000000080006fce <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006fce:	7159                	addi	sp,sp,-112
    80006fd0:	f486                	sd	ra,104(sp)
    80006fd2:	f0a2                	sd	s0,96(sp)
    80006fd4:	eca6                	sd	s1,88(sp)
    80006fd6:	e8ca                	sd	s2,80(sp)
    80006fd8:	e4ce                	sd	s3,72(sp)
    80006fda:	e0d2                	sd	s4,64(sp)
    80006fdc:	fc56                	sd	s5,56(sp)
    80006fde:	f85a                	sd	s6,48(sp)
    80006fe0:	f45e                	sd	s7,40(sp)
    80006fe2:	f062                	sd	s8,32(sp)
    80006fe4:	ec66                	sd	s9,24(sp)
    80006fe6:	e86a                	sd	s10,16(sp)
    80006fe8:	e46e                	sd	s11,8(sp)
    80006fea:	1880                	addi	s0,sp,112
    80006fec:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006fee:	0002d517          	auipc	a0,0x2d
    80006ff2:	01250513          	addi	a0,a0,18 # 80034000 <lock>
    80006ff6:	ffffa097          	auipc	ra,0xffffa
    80006ffa:	aaa080e7          	jalr	-1366(ra) # 80000aa0 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80006ffe:	8556                	mv	a0,s5
    80007000:	00000097          	auipc	ra,0x0
    80007004:	f58080e7          	jalr	-168(ra) # 80006f58 <size>
    80007008:	84aa                	mv	s1,a0
    8000700a:	0002d797          	auipc	a5,0x2d
    8000700e:	04e7a783          	lw	a5,78(a5) # 80034058 <nsizes>
    80007012:	37fd                	addiw	a5,a5,-1
    80007014:	0cf55063          	bge	a0,a5,800070d4 <bd_free+0x106>
    80007018:	00150a13          	addi	s4,a0,1
    8000701c:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    8000701e:	0002dc17          	auipc	s8,0x2d
    80007022:	02ac0c13          	addi	s8,s8,42 # 80034048 <bd_base>
  return n / BLK_SIZE(k);
    80007026:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80007028:	0002db17          	auipc	s6,0x2d
    8000702c:	028b0b13          	addi	s6,s6,40 # 80034050 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80007030:	0002dc97          	auipc	s9,0x2d
    80007034:	028c8c93          	addi	s9,s9,40 # 80034058 <nsizes>
    80007038:	a82d                	j	80007072 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    8000703a:	fff58d9b          	addiw	s11,a1,-1
    8000703e:	a881                	j	8000708e <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007040:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80007042:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80007046:	40ba85bb          	subw	a1,s5,a1
    8000704a:	009b97b3          	sll	a5,s7,s1
    8000704e:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80007052:	000b3783          	ld	a5,0(s6)
    80007056:	97d2                	add	a5,a5,s4
    80007058:	2581                	sext.w	a1,a1
    8000705a:	6f88                	ld	a0,24(a5)
    8000705c:	00000097          	auipc	ra,0x0
    80007060:	b30080e7          	jalr	-1232(ra) # 80006b8c <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80007064:	020a0a13          	addi	s4,s4,32
    80007068:	000ca783          	lw	a5,0(s9)
    8000706c:	37fd                	addiw	a5,a5,-1
    8000706e:	06f4d363          	bge	s1,a5,800070d4 <bd_free+0x106>
  int n = p - (char *) bd_base;
    80007072:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80007076:	009b99b3          	sll	s3,s7,s1
    8000707a:	412a87bb          	subw	a5,s5,s2
    8000707e:	0337c7b3          	div	a5,a5,s3
    80007082:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007086:	8b85                	andi	a5,a5,1
    80007088:	fbcd                	bnez	a5,8000703a <bd_free+0x6c>
    8000708a:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    8000708e:	fe0a0d13          	addi	s10,s4,-32
    80007092:	000b3783          	ld	a5,0(s6)
    80007096:	9d3e                	add	s10,s10,a5
    80007098:	010d3503          	ld	a0,16(s10)
    8000709c:	00000097          	auipc	ra,0x0
    800070a0:	af0080e7          	jalr	-1296(ra) # 80006b8c <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    800070a4:	85ee                	mv	a1,s11
    800070a6:	010d3503          	ld	a0,16(s10)
    800070aa:	00000097          	auipc	ra,0x0
    800070ae:	a7a080e7          	jalr	-1414(ra) # 80006b24 <bit_isset>
    800070b2:	e10d                	bnez	a0,800070d4 <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    800070b4:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    800070b8:	03b989bb          	mulw	s3,s3,s11
    800070bc:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    800070be:	854a                	mv	a0,s2
    800070c0:	00000097          	auipc	ra,0x0
    800070c4:	630080e7          	jalr	1584(ra) # 800076f0 <lst_remove>
    if(buddy % 2 == 0) {
    800070c8:	001d7d13          	andi	s10,s10,1
    800070cc:	f60d1ae3          	bnez	s10,80007040 <bd_free+0x72>
      p = q;
    800070d0:	8aca                	mv	s5,s2
    800070d2:	b7bd                	j	80007040 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    800070d4:	0496                	slli	s1,s1,0x5
    800070d6:	85d6                	mv	a1,s5
    800070d8:	0002d517          	auipc	a0,0x2d
    800070dc:	f7853503          	ld	a0,-136(a0) # 80034050 <bd_sizes>
    800070e0:	9526                	add	a0,a0,s1
    800070e2:	00000097          	auipc	ra,0x0
    800070e6:	65a080e7          	jalr	1626(ra) # 8000773c <lst_push>
  release(&lock);
    800070ea:	0002d517          	auipc	a0,0x2d
    800070ee:	f1650513          	addi	a0,a0,-234 # 80034000 <lock>
    800070f2:	ffffa097          	auipc	ra,0xffffa
    800070f6:	a7e080e7          	jalr	-1410(ra) # 80000b70 <release>
}
    800070fa:	70a6                	ld	ra,104(sp)
    800070fc:	7406                	ld	s0,96(sp)
    800070fe:	64e6                	ld	s1,88(sp)
    80007100:	6946                	ld	s2,80(sp)
    80007102:	69a6                	ld	s3,72(sp)
    80007104:	6a06                	ld	s4,64(sp)
    80007106:	7ae2                	ld	s5,56(sp)
    80007108:	7b42                	ld	s6,48(sp)
    8000710a:	7ba2                	ld	s7,40(sp)
    8000710c:	7c02                	ld	s8,32(sp)
    8000710e:	6ce2                	ld	s9,24(sp)
    80007110:	6d42                	ld	s10,16(sp)
    80007112:	6da2                	ld	s11,8(sp)
    80007114:	6165                	addi	sp,sp,112
    80007116:	8082                	ret

0000000080007118 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80007118:	1141                	addi	sp,sp,-16
    8000711a:	e422                	sd	s0,8(sp)
    8000711c:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    8000711e:	0002d797          	auipc	a5,0x2d
    80007122:	f2a7b783          	ld	a5,-214(a5) # 80034048 <bd_base>
    80007126:	8d9d                	sub	a1,a1,a5
    80007128:	47c1                	li	a5,16
    8000712a:	00a797b3          	sll	a5,a5,a0
    8000712e:	02f5c533          	div	a0,a1,a5
    80007132:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80007134:	02f5e5b3          	rem	a1,a1,a5
    80007138:	c191                	beqz	a1,8000713c <blk_index_next+0x24>
      n++;
    8000713a:	2505                	addiw	a0,a0,1
  return n ;
}
    8000713c:	6422                	ld	s0,8(sp)
    8000713e:	0141                	addi	sp,sp,16
    80007140:	8082                	ret

0000000080007142 <log2>:

int
log2(uint64 n) {
    80007142:	1141                	addi	sp,sp,-16
    80007144:	e422                	sd	s0,8(sp)
    80007146:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80007148:	4705                	li	a4,1
    8000714a:	00a77b63          	bgeu	a4,a0,80007160 <log2+0x1e>
    8000714e:	87aa                	mv	a5,a0
  int k = 0;
    80007150:	4501                	li	a0,0
    k++;
    80007152:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80007154:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80007156:	fef76ee3          	bltu	a4,a5,80007152 <log2+0x10>
  }
  return k;
}
    8000715a:	6422                	ld	s0,8(sp)
    8000715c:	0141                	addi	sp,sp,16
    8000715e:	8082                	ret
  int k = 0;
    80007160:	4501                	li	a0,0
    80007162:	bfe5                	j	8000715a <log2+0x18>

0000000080007164 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80007164:	711d                	addi	sp,sp,-96
    80007166:	ec86                	sd	ra,88(sp)
    80007168:	e8a2                	sd	s0,80(sp)
    8000716a:	e4a6                	sd	s1,72(sp)
    8000716c:	e0ca                	sd	s2,64(sp)
    8000716e:	fc4e                	sd	s3,56(sp)
    80007170:	f852                	sd	s4,48(sp)
    80007172:	f456                	sd	s5,40(sp)
    80007174:	f05a                	sd	s6,32(sp)
    80007176:	ec5e                	sd	s7,24(sp)
    80007178:	e862                	sd	s8,16(sp)
    8000717a:	e466                	sd	s9,8(sp)
    8000717c:	e06a                	sd	s10,0(sp)
    8000717e:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80007180:	00b56933          	or	s2,a0,a1
    80007184:	00f97913          	andi	s2,s2,15
    80007188:	04091263          	bnez	s2,800071cc <bd_mark+0x68>
    8000718c:	8b2a                	mv	s6,a0
    8000718e:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80007190:	0002dc17          	auipc	s8,0x2d
    80007194:	ec8c2c03          	lw	s8,-312(s8) # 80034058 <nsizes>
    80007198:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    8000719a:	0002dd17          	auipc	s10,0x2d
    8000719e:	eaed0d13          	addi	s10,s10,-338 # 80034048 <bd_base>
  return n / BLK_SIZE(k);
    800071a2:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    800071a4:	0002da97          	auipc	s5,0x2d
    800071a8:	eaca8a93          	addi	s5,s5,-340 # 80034050 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    800071ac:	07804563          	bgtz	s8,80007216 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    800071b0:	60e6                	ld	ra,88(sp)
    800071b2:	6446                	ld	s0,80(sp)
    800071b4:	64a6                	ld	s1,72(sp)
    800071b6:	6906                	ld	s2,64(sp)
    800071b8:	79e2                	ld	s3,56(sp)
    800071ba:	7a42                	ld	s4,48(sp)
    800071bc:	7aa2                	ld	s5,40(sp)
    800071be:	7b02                	ld	s6,32(sp)
    800071c0:	6be2                	ld	s7,24(sp)
    800071c2:	6c42                	ld	s8,16(sp)
    800071c4:	6ca2                	ld	s9,8(sp)
    800071c6:	6d02                	ld	s10,0(sp)
    800071c8:	6125                	addi	sp,sp,96
    800071ca:	8082                	ret
    panic("bd_mark");
    800071cc:	00002517          	auipc	a0,0x2
    800071d0:	c1450513          	addi	a0,a0,-1004 # 80008de0 <userret+0xd50>
    800071d4:	ffff9097          	auipc	ra,0xffff9
    800071d8:	380080e7          	jalr	896(ra) # 80000554 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    800071dc:	000ab783          	ld	a5,0(s5)
    800071e0:	97ca                	add	a5,a5,s2
    800071e2:	85a6                	mv	a1,s1
    800071e4:	6b88                	ld	a0,16(a5)
    800071e6:	00000097          	auipc	ra,0x0
    800071ea:	976080e7          	jalr	-1674(ra) # 80006b5c <bit_set>
    for(; bi < bj; bi++) {
    800071ee:	2485                	addiw	s1,s1,1
    800071f0:	009a0e63          	beq	s4,s1,8000720c <bd_mark+0xa8>
      if(k > 0) {
    800071f4:	ff3054e3          	blez	s3,800071dc <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    800071f8:	000ab783          	ld	a5,0(s5)
    800071fc:	97ca                	add	a5,a5,s2
    800071fe:	85a6                	mv	a1,s1
    80007200:	6f88                	ld	a0,24(a5)
    80007202:	00000097          	auipc	ra,0x0
    80007206:	95a080e7          	jalr	-1702(ra) # 80006b5c <bit_set>
    8000720a:	bfc9                	j	800071dc <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    8000720c:	2985                	addiw	s3,s3,1
    8000720e:	02090913          	addi	s2,s2,32
    80007212:	f9898fe3          	beq	s3,s8,800071b0 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80007216:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    8000721a:	409b04bb          	subw	s1,s6,s1
    8000721e:	013c97b3          	sll	a5,s9,s3
    80007222:	02f4c4b3          	div	s1,s1,a5
    80007226:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80007228:	85de                	mv	a1,s7
    8000722a:	854e                	mv	a0,s3
    8000722c:	00000097          	auipc	ra,0x0
    80007230:	eec080e7          	jalr	-276(ra) # 80007118 <blk_index_next>
    80007234:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80007236:	faa4cfe3          	blt	s1,a0,800071f4 <bd_mark+0x90>
    8000723a:	bfc9                	j	8000720c <bd_mark+0xa8>

000000008000723c <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    8000723c:	7139                	addi	sp,sp,-64
    8000723e:	fc06                	sd	ra,56(sp)
    80007240:	f822                	sd	s0,48(sp)
    80007242:	f426                	sd	s1,40(sp)
    80007244:	f04a                	sd	s2,32(sp)
    80007246:	ec4e                	sd	s3,24(sp)
    80007248:	e852                	sd	s4,16(sp)
    8000724a:	e456                	sd	s5,8(sp)
    8000724c:	e05a                	sd	s6,0(sp)
    8000724e:	0080                	addi	s0,sp,64
    80007250:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80007252:	00058a9b          	sext.w	s5,a1
    80007256:	0015f793          	andi	a5,a1,1
    8000725a:	ebad                	bnez	a5,800072cc <bd_initfree_pair+0x90>
    8000725c:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80007260:	00599493          	slli	s1,s3,0x5
    80007264:	0002d797          	auipc	a5,0x2d
    80007268:	dec7b783          	ld	a5,-532(a5) # 80034050 <bd_sizes>
    8000726c:	94be                	add	s1,s1,a5
    8000726e:	0104bb03          	ld	s6,16(s1)
    80007272:	855a                	mv	a0,s6
    80007274:	00000097          	auipc	ra,0x0
    80007278:	8b0080e7          	jalr	-1872(ra) # 80006b24 <bit_isset>
    8000727c:	892a                	mv	s2,a0
    8000727e:	85d2                	mv	a1,s4
    80007280:	855a                	mv	a0,s6
    80007282:	00000097          	auipc	ra,0x0
    80007286:	8a2080e7          	jalr	-1886(ra) # 80006b24 <bit_isset>
  int free = 0;
    8000728a:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    8000728c:	02a90563          	beq	s2,a0,800072b6 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80007290:	45c1                	li	a1,16
    80007292:	013599b3          	sll	s3,a1,s3
    80007296:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    8000729a:	02090c63          	beqz	s2,800072d2 <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    8000729e:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    800072a2:	0002d597          	auipc	a1,0x2d
    800072a6:	da65b583          	ld	a1,-602(a1) # 80034048 <bd_base>
    800072aa:	95ce                	add	a1,a1,s3
    800072ac:	8526                	mv	a0,s1
    800072ae:	00000097          	auipc	ra,0x0
    800072b2:	48e080e7          	jalr	1166(ra) # 8000773c <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    800072b6:	855a                	mv	a0,s6
    800072b8:	70e2                	ld	ra,56(sp)
    800072ba:	7442                	ld	s0,48(sp)
    800072bc:	74a2                	ld	s1,40(sp)
    800072be:	7902                	ld	s2,32(sp)
    800072c0:	69e2                	ld	s3,24(sp)
    800072c2:	6a42                	ld	s4,16(sp)
    800072c4:	6aa2                	ld	s5,8(sp)
    800072c6:	6b02                	ld	s6,0(sp)
    800072c8:	6121                	addi	sp,sp,64
    800072ca:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800072cc:	fff58a1b          	addiw	s4,a1,-1
    800072d0:	bf41                	j	80007260 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    800072d2:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    800072d6:	0002d597          	auipc	a1,0x2d
    800072da:	d725b583          	ld	a1,-654(a1) # 80034048 <bd_base>
    800072de:	95ce                	add	a1,a1,s3
    800072e0:	8526                	mv	a0,s1
    800072e2:	00000097          	auipc	ra,0x0
    800072e6:	45a080e7          	jalr	1114(ra) # 8000773c <lst_push>
    800072ea:	b7f1                	j	800072b6 <bd_initfree_pair+0x7a>

00000000800072ec <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    800072ec:	711d                	addi	sp,sp,-96
    800072ee:	ec86                	sd	ra,88(sp)
    800072f0:	e8a2                	sd	s0,80(sp)
    800072f2:	e4a6                	sd	s1,72(sp)
    800072f4:	e0ca                	sd	s2,64(sp)
    800072f6:	fc4e                	sd	s3,56(sp)
    800072f8:	f852                	sd	s4,48(sp)
    800072fa:	f456                	sd	s5,40(sp)
    800072fc:	f05a                	sd	s6,32(sp)
    800072fe:	ec5e                	sd	s7,24(sp)
    80007300:	e862                	sd	s8,16(sp)
    80007302:	e466                	sd	s9,8(sp)
    80007304:	e06a                	sd	s10,0(sp)
    80007306:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007308:	0002d717          	auipc	a4,0x2d
    8000730c:	d5072703          	lw	a4,-688(a4) # 80034058 <nsizes>
    80007310:	4785                	li	a5,1
    80007312:	06e7db63          	bge	a5,a4,80007388 <bd_initfree+0x9c>
    80007316:	8aaa                	mv	s5,a0
    80007318:	8b2e                	mv	s6,a1
    8000731a:	4901                	li	s2,0
  int free = 0;
    8000731c:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    8000731e:	0002dc97          	auipc	s9,0x2d
    80007322:	d2ac8c93          	addi	s9,s9,-726 # 80034048 <bd_base>
  return n / BLK_SIZE(k);
    80007326:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80007328:	0002db97          	auipc	s7,0x2d
    8000732c:	d30b8b93          	addi	s7,s7,-720 # 80034058 <nsizes>
    80007330:	a039                	j	8000733e <bd_initfree+0x52>
    80007332:	2905                	addiw	s2,s2,1
    80007334:	000ba783          	lw	a5,0(s7)
    80007338:	37fd                	addiw	a5,a5,-1
    8000733a:	04f95863          	bge	s2,a5,8000738a <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    8000733e:	85d6                	mv	a1,s5
    80007340:	854a                	mv	a0,s2
    80007342:	00000097          	auipc	ra,0x0
    80007346:	dd6080e7          	jalr	-554(ra) # 80007118 <blk_index_next>
    8000734a:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    8000734c:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80007350:	409b04bb          	subw	s1,s6,s1
    80007354:	012c17b3          	sll	a5,s8,s2
    80007358:	02f4c4b3          	div	s1,s1,a5
    8000735c:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    8000735e:	85aa                	mv	a1,a0
    80007360:	854a                	mv	a0,s2
    80007362:	00000097          	auipc	ra,0x0
    80007366:	eda080e7          	jalr	-294(ra) # 8000723c <bd_initfree_pair>
    8000736a:	01450d3b          	addw	s10,a0,s4
    8000736e:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80007372:	fc99d0e3          	bge	s3,s1,80007332 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80007376:	85a6                	mv	a1,s1
    80007378:	854a                	mv	a0,s2
    8000737a:	00000097          	auipc	ra,0x0
    8000737e:	ec2080e7          	jalr	-318(ra) # 8000723c <bd_initfree_pair>
    80007382:	00ad0a3b          	addw	s4,s10,a0
    80007386:	b775                	j	80007332 <bd_initfree+0x46>
  int free = 0;
    80007388:	4a01                	li	s4,0
  }
  return free;
}
    8000738a:	8552                	mv	a0,s4
    8000738c:	60e6                	ld	ra,88(sp)
    8000738e:	6446                	ld	s0,80(sp)
    80007390:	64a6                	ld	s1,72(sp)
    80007392:	6906                	ld	s2,64(sp)
    80007394:	79e2                	ld	s3,56(sp)
    80007396:	7a42                	ld	s4,48(sp)
    80007398:	7aa2                	ld	s5,40(sp)
    8000739a:	7b02                	ld	s6,32(sp)
    8000739c:	6be2                	ld	s7,24(sp)
    8000739e:	6c42                	ld	s8,16(sp)
    800073a0:	6ca2                	ld	s9,8(sp)
    800073a2:	6d02                	ld	s10,0(sp)
    800073a4:	6125                	addi	sp,sp,96
    800073a6:	8082                	ret

00000000800073a8 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    800073a8:	7179                	addi	sp,sp,-48
    800073aa:	f406                	sd	ra,40(sp)
    800073ac:	f022                	sd	s0,32(sp)
    800073ae:	ec26                	sd	s1,24(sp)
    800073b0:	e84a                	sd	s2,16(sp)
    800073b2:	e44e                	sd	s3,8(sp)
    800073b4:	1800                	addi	s0,sp,48
    800073b6:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    800073b8:	0002d997          	auipc	s3,0x2d
    800073bc:	c9098993          	addi	s3,s3,-880 # 80034048 <bd_base>
    800073c0:	0009b483          	ld	s1,0(s3)
    800073c4:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    800073c8:	0002d797          	auipc	a5,0x2d
    800073cc:	c907a783          	lw	a5,-880(a5) # 80034058 <nsizes>
    800073d0:	37fd                	addiw	a5,a5,-1
    800073d2:	4641                	li	a2,16
    800073d4:	00f61633          	sll	a2,a2,a5
    800073d8:	85a6                	mv	a1,s1
    800073da:	00002517          	auipc	a0,0x2
    800073de:	a0e50513          	addi	a0,a0,-1522 # 80008de8 <userret+0xd58>
    800073e2:	ffff9097          	auipc	ra,0xffff9
    800073e6:	1cc080e7          	jalr	460(ra) # 800005ae <printf>
  bd_mark(bd_base, p);
    800073ea:	85ca                	mv	a1,s2
    800073ec:	0009b503          	ld	a0,0(s3)
    800073f0:	00000097          	auipc	ra,0x0
    800073f4:	d74080e7          	jalr	-652(ra) # 80007164 <bd_mark>
  return meta;
}
    800073f8:	8526                	mv	a0,s1
    800073fa:	70a2                	ld	ra,40(sp)
    800073fc:	7402                	ld	s0,32(sp)
    800073fe:	64e2                	ld	s1,24(sp)
    80007400:	6942                	ld	s2,16(sp)
    80007402:	69a2                	ld	s3,8(sp)
    80007404:	6145                	addi	sp,sp,48
    80007406:	8082                	ret

0000000080007408 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80007408:	1101                	addi	sp,sp,-32
    8000740a:	ec06                	sd	ra,24(sp)
    8000740c:	e822                	sd	s0,16(sp)
    8000740e:	e426                	sd	s1,8(sp)
    80007410:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80007412:	0002d497          	auipc	s1,0x2d
    80007416:	c464a483          	lw	s1,-954(s1) # 80034058 <nsizes>
    8000741a:	fff4879b          	addiw	a5,s1,-1
    8000741e:	44c1                	li	s1,16
    80007420:	00f494b3          	sll	s1,s1,a5
    80007424:	0002d797          	auipc	a5,0x2d
    80007428:	c247b783          	ld	a5,-988(a5) # 80034048 <bd_base>
    8000742c:	8d1d                	sub	a0,a0,a5
    8000742e:	40a4853b          	subw	a0,s1,a0
    80007432:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80007436:	00905a63          	blez	s1,8000744a <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    8000743a:	357d                	addiw	a0,a0,-1
    8000743c:	41f5549b          	sraiw	s1,a0,0x1f
    80007440:	01c4d49b          	srliw	s1,s1,0x1c
    80007444:	9ca9                	addw	s1,s1,a0
    80007446:	98c1                	andi	s1,s1,-16
    80007448:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    8000744a:	85a6                	mv	a1,s1
    8000744c:	00002517          	auipc	a0,0x2
    80007450:	9d450513          	addi	a0,a0,-1580 # 80008e20 <userret+0xd90>
    80007454:	ffff9097          	auipc	ra,0xffff9
    80007458:	15a080e7          	jalr	346(ra) # 800005ae <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    8000745c:	0002d717          	auipc	a4,0x2d
    80007460:	bec73703          	ld	a4,-1044(a4) # 80034048 <bd_base>
    80007464:	0002d597          	auipc	a1,0x2d
    80007468:	bf45a583          	lw	a1,-1036(a1) # 80034058 <nsizes>
    8000746c:	fff5879b          	addiw	a5,a1,-1
    80007470:	45c1                	li	a1,16
    80007472:	00f595b3          	sll	a1,a1,a5
    80007476:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    8000747a:	95ba                	add	a1,a1,a4
    8000747c:	953a                	add	a0,a0,a4
    8000747e:	00000097          	auipc	ra,0x0
    80007482:	ce6080e7          	jalr	-794(ra) # 80007164 <bd_mark>
  return unavailable;
}
    80007486:	8526                	mv	a0,s1
    80007488:	60e2                	ld	ra,24(sp)
    8000748a:	6442                	ld	s0,16(sp)
    8000748c:	64a2                	ld	s1,8(sp)
    8000748e:	6105                	addi	sp,sp,32
    80007490:	8082                	ret

0000000080007492 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80007492:	715d                	addi	sp,sp,-80
    80007494:	e486                	sd	ra,72(sp)
    80007496:	e0a2                	sd	s0,64(sp)
    80007498:	fc26                	sd	s1,56(sp)
    8000749a:	f84a                	sd	s2,48(sp)
    8000749c:	f44e                	sd	s3,40(sp)
    8000749e:	f052                	sd	s4,32(sp)
    800074a0:	ec56                	sd	s5,24(sp)
    800074a2:	e85a                	sd	s6,16(sp)
    800074a4:	e45e                	sd	s7,8(sp)
    800074a6:	e062                	sd	s8,0(sp)
    800074a8:	0880                	addi	s0,sp,80
    800074aa:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    800074ac:	fff50493          	addi	s1,a0,-1
    800074b0:	98c1                	andi	s1,s1,-16
    800074b2:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    800074b4:	00002597          	auipc	a1,0x2
    800074b8:	98c58593          	addi	a1,a1,-1652 # 80008e40 <userret+0xdb0>
    800074bc:	0002d517          	auipc	a0,0x2d
    800074c0:	b4450513          	addi	a0,a0,-1212 # 80034000 <lock>
    800074c4:	ffff9097          	auipc	ra,0xffff9
    800074c8:	508080e7          	jalr	1288(ra) # 800009cc <initlock>
  bd_base = (void *) p;
    800074cc:	0002d797          	auipc	a5,0x2d
    800074d0:	b697be23          	sd	s1,-1156(a5) # 80034048 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    800074d4:	409c0933          	sub	s2,s8,s1
    800074d8:	43f95513          	srai	a0,s2,0x3f
    800074dc:	893d                	andi	a0,a0,15
    800074de:	954a                	add	a0,a0,s2
    800074e0:	8511                	srai	a0,a0,0x4
    800074e2:	00000097          	auipc	ra,0x0
    800074e6:	c60080e7          	jalr	-928(ra) # 80007142 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    800074ea:	47c1                	li	a5,16
    800074ec:	00a797b3          	sll	a5,a5,a0
    800074f0:	1b27c663          	blt	a5,s2,8000769c <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    800074f4:	2505                	addiw	a0,a0,1
    800074f6:	0002d797          	auipc	a5,0x2d
    800074fa:	b6a7a123          	sw	a0,-1182(a5) # 80034058 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    800074fe:	0002d997          	auipc	s3,0x2d
    80007502:	b5a98993          	addi	s3,s3,-1190 # 80034058 <nsizes>
    80007506:	0009a603          	lw	a2,0(s3)
    8000750a:	85ca                	mv	a1,s2
    8000750c:	00002517          	auipc	a0,0x2
    80007510:	93c50513          	addi	a0,a0,-1732 # 80008e48 <userret+0xdb8>
    80007514:	ffff9097          	auipc	ra,0xffff9
    80007518:	09a080e7          	jalr	154(ra) # 800005ae <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    8000751c:	0002d797          	auipc	a5,0x2d
    80007520:	b297ba23          	sd	s1,-1228(a5) # 80034050 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80007524:	0009a603          	lw	a2,0(s3)
    80007528:	00561913          	slli	s2,a2,0x5
    8000752c:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    8000752e:	0056161b          	slliw	a2,a2,0x5
    80007532:	4581                	li	a1,0
    80007534:	8526                	mv	a0,s1
    80007536:	ffffa097          	auipc	ra,0xffffa
    8000753a:	838080e7          	jalr	-1992(ra) # 80000d6e <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    8000753e:	0009a783          	lw	a5,0(s3)
    80007542:	06f05a63          	blez	a5,800075b6 <bd_init+0x124>
    80007546:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80007548:	0002da97          	auipc	s5,0x2d
    8000754c:	b08a8a93          	addi	s5,s5,-1272 # 80034050 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007550:	0002da17          	auipc	s4,0x2d
    80007554:	b08a0a13          	addi	s4,s4,-1272 # 80034058 <nsizes>
    80007558:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    8000755a:	00599b93          	slli	s7,s3,0x5
    8000755e:	000ab503          	ld	a0,0(s5)
    80007562:	955e                	add	a0,a0,s7
    80007564:	00000097          	auipc	ra,0x0
    80007568:	166080e7          	jalr	358(ra) # 800076ca <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    8000756c:	000a2483          	lw	s1,0(s4)
    80007570:	34fd                	addiw	s1,s1,-1
    80007572:	413484bb          	subw	s1,s1,s3
    80007576:	009b14bb          	sllw	s1,s6,s1
    8000757a:	fff4879b          	addiw	a5,s1,-1
    8000757e:	41f7d49b          	sraiw	s1,a5,0x1f
    80007582:	01d4d49b          	srliw	s1,s1,0x1d
    80007586:	9cbd                	addw	s1,s1,a5
    80007588:	98e1                	andi	s1,s1,-8
    8000758a:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    8000758c:	000ab783          	ld	a5,0(s5)
    80007590:	9bbe                	add	s7,s7,a5
    80007592:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80007596:	848d                	srai	s1,s1,0x3
    80007598:	8626                	mv	a2,s1
    8000759a:	4581                	li	a1,0
    8000759c:	854a                	mv	a0,s2
    8000759e:	ffff9097          	auipc	ra,0xffff9
    800075a2:	7d0080e7          	jalr	2000(ra) # 80000d6e <memset>
    p += sz;
    800075a6:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    800075a8:	0985                	addi	s3,s3,1
    800075aa:	000a2703          	lw	a4,0(s4)
    800075ae:	0009879b          	sext.w	a5,s3
    800075b2:	fae7c4e3          	blt	a5,a4,8000755a <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    800075b6:	0002d797          	auipc	a5,0x2d
    800075ba:	aa27a783          	lw	a5,-1374(a5) # 80034058 <nsizes>
    800075be:	4705                	li	a4,1
    800075c0:	06f75163          	bge	a4,a5,80007622 <bd_init+0x190>
    800075c4:	02000a13          	li	s4,32
    800075c8:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    800075ca:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    800075cc:	0002db17          	auipc	s6,0x2d
    800075d0:	a84b0b13          	addi	s6,s6,-1404 # 80034050 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    800075d4:	0002da97          	auipc	s5,0x2d
    800075d8:	a84a8a93          	addi	s5,s5,-1404 # 80034058 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    800075dc:	37fd                	addiw	a5,a5,-1
    800075de:	413787bb          	subw	a5,a5,s3
    800075e2:	00fb94bb          	sllw	s1,s7,a5
    800075e6:	fff4879b          	addiw	a5,s1,-1
    800075ea:	41f7d49b          	sraiw	s1,a5,0x1f
    800075ee:	01d4d49b          	srliw	s1,s1,0x1d
    800075f2:	9cbd                	addw	s1,s1,a5
    800075f4:	98e1                	andi	s1,s1,-8
    800075f6:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    800075f8:	000b3783          	ld	a5,0(s6)
    800075fc:	97d2                	add	a5,a5,s4
    800075fe:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80007602:	848d                	srai	s1,s1,0x3
    80007604:	8626                	mv	a2,s1
    80007606:	4581                	li	a1,0
    80007608:	854a                	mv	a0,s2
    8000760a:	ffff9097          	auipc	ra,0xffff9
    8000760e:	764080e7          	jalr	1892(ra) # 80000d6e <memset>
    p += sz;
    80007612:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80007614:	2985                	addiw	s3,s3,1
    80007616:	000aa783          	lw	a5,0(s5)
    8000761a:	020a0a13          	addi	s4,s4,32
    8000761e:	faf9cfe3          	blt	s3,a5,800075dc <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80007622:	197d                	addi	s2,s2,-1
    80007624:	ff097913          	andi	s2,s2,-16
    80007628:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    8000762a:	854a                	mv	a0,s2
    8000762c:	00000097          	auipc	ra,0x0
    80007630:	d7c080e7          	jalr	-644(ra) # 800073a8 <bd_mark_data_structures>
    80007634:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80007636:	85ca                	mv	a1,s2
    80007638:	8562                	mv	a0,s8
    8000763a:	00000097          	auipc	ra,0x0
    8000763e:	dce080e7          	jalr	-562(ra) # 80007408 <bd_mark_unavailable>
    80007642:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007644:	0002da97          	auipc	s5,0x2d
    80007648:	a14a8a93          	addi	s5,s5,-1516 # 80034058 <nsizes>
    8000764c:	000aa783          	lw	a5,0(s5)
    80007650:	37fd                	addiw	a5,a5,-1
    80007652:	44c1                	li	s1,16
    80007654:	00f497b3          	sll	a5,s1,a5
    80007658:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    8000765a:	0002d597          	auipc	a1,0x2d
    8000765e:	9ee5b583          	ld	a1,-1554(a1) # 80034048 <bd_base>
    80007662:	95be                	add	a1,a1,a5
    80007664:	854a                	mv	a0,s2
    80007666:	00000097          	auipc	ra,0x0
    8000766a:	c86080e7          	jalr	-890(ra) # 800072ec <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    8000766e:	000aa603          	lw	a2,0(s5)
    80007672:	367d                	addiw	a2,a2,-1
    80007674:	00c49633          	sll	a2,s1,a2
    80007678:	41460633          	sub	a2,a2,s4
    8000767c:	41360633          	sub	a2,a2,s3
    80007680:	02c51463          	bne	a0,a2,800076a8 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80007684:	60a6                	ld	ra,72(sp)
    80007686:	6406                	ld	s0,64(sp)
    80007688:	74e2                	ld	s1,56(sp)
    8000768a:	7942                	ld	s2,48(sp)
    8000768c:	79a2                	ld	s3,40(sp)
    8000768e:	7a02                	ld	s4,32(sp)
    80007690:	6ae2                	ld	s5,24(sp)
    80007692:	6b42                	ld	s6,16(sp)
    80007694:	6ba2                	ld	s7,8(sp)
    80007696:	6c02                	ld	s8,0(sp)
    80007698:	6161                	addi	sp,sp,80
    8000769a:	8082                	ret
    nsizes++;  // round up to the next power of 2
    8000769c:	2509                	addiw	a0,a0,2
    8000769e:	0002d797          	auipc	a5,0x2d
    800076a2:	9aa7ad23          	sw	a0,-1606(a5) # 80034058 <nsizes>
    800076a6:	bda1                	j	800074fe <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    800076a8:	85aa                	mv	a1,a0
    800076aa:	00001517          	auipc	a0,0x1
    800076ae:	7de50513          	addi	a0,a0,2014 # 80008e88 <userret+0xdf8>
    800076b2:	ffff9097          	auipc	ra,0xffff9
    800076b6:	efc080e7          	jalr	-260(ra) # 800005ae <printf>
    panic("bd_init: free mem");
    800076ba:	00001517          	auipc	a0,0x1
    800076be:	7de50513          	addi	a0,a0,2014 # 80008e98 <userret+0xe08>
    800076c2:	ffff9097          	auipc	ra,0xffff9
    800076c6:	e92080e7          	jalr	-366(ra) # 80000554 <panic>

00000000800076ca <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    800076ca:	1141                	addi	sp,sp,-16
    800076cc:	e422                	sd	s0,8(sp)
    800076ce:	0800                	addi	s0,sp,16
  lst->next = lst;
    800076d0:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    800076d2:	e508                	sd	a0,8(a0)
}
    800076d4:	6422                	ld	s0,8(sp)
    800076d6:	0141                	addi	sp,sp,16
    800076d8:	8082                	ret

00000000800076da <lst_empty>:

int
lst_empty(struct list *lst) {
    800076da:	1141                	addi	sp,sp,-16
    800076dc:	e422                	sd	s0,8(sp)
    800076de:	0800                	addi	s0,sp,16
  return lst->next == lst;
    800076e0:	611c                	ld	a5,0(a0)
    800076e2:	40a78533          	sub	a0,a5,a0
}
    800076e6:	00153513          	seqz	a0,a0
    800076ea:	6422                	ld	s0,8(sp)
    800076ec:	0141                	addi	sp,sp,16
    800076ee:	8082                	ret

00000000800076f0 <lst_remove>:

void
lst_remove(struct list *e) {
    800076f0:	1141                	addi	sp,sp,-16
    800076f2:	e422                	sd	s0,8(sp)
    800076f4:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    800076f6:	6518                	ld	a4,8(a0)
    800076f8:	611c                	ld	a5,0(a0)
    800076fa:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    800076fc:	6518                	ld	a4,8(a0)
    800076fe:	e798                	sd	a4,8(a5)
}
    80007700:	6422                	ld	s0,8(sp)
    80007702:	0141                	addi	sp,sp,16
    80007704:	8082                	ret

0000000080007706 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007706:	1101                	addi	sp,sp,-32
    80007708:	ec06                	sd	ra,24(sp)
    8000770a:	e822                	sd	s0,16(sp)
    8000770c:	e426                	sd	s1,8(sp)
    8000770e:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007710:	6104                	ld	s1,0(a0)
    80007712:	00a48d63          	beq	s1,a0,8000772c <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007716:	8526                	mv	a0,s1
    80007718:	00000097          	auipc	ra,0x0
    8000771c:	fd8080e7          	jalr	-40(ra) # 800076f0 <lst_remove>
  return (void *)p;
}
    80007720:	8526                	mv	a0,s1
    80007722:	60e2                	ld	ra,24(sp)
    80007724:	6442                	ld	s0,16(sp)
    80007726:	64a2                	ld	s1,8(sp)
    80007728:	6105                	addi	sp,sp,32
    8000772a:	8082                	ret
    panic("lst_pop");
    8000772c:	00001517          	auipc	a0,0x1
    80007730:	78450513          	addi	a0,a0,1924 # 80008eb0 <userret+0xe20>
    80007734:	ffff9097          	auipc	ra,0xffff9
    80007738:	e20080e7          	jalr	-480(ra) # 80000554 <panic>

000000008000773c <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    8000773c:	1141                	addi	sp,sp,-16
    8000773e:	e422                	sd	s0,8(sp)
    80007740:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    80007742:	611c                	ld	a5,0(a0)
    80007744:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    80007746:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80007748:	611c                	ld	a5,0(a0)
    8000774a:	e78c                	sd	a1,8(a5)
  lst->next = e;
    8000774c:	e10c                	sd	a1,0(a0)
}
    8000774e:	6422                	ld	s0,8(sp)
    80007750:	0141                	addi	sp,sp,16
    80007752:	8082                	ret

0000000080007754 <lst_print>:

void
lst_print(struct list *lst)
{
    80007754:	7179                	addi	sp,sp,-48
    80007756:	f406                	sd	ra,40(sp)
    80007758:	f022                	sd	s0,32(sp)
    8000775a:	ec26                	sd	s1,24(sp)
    8000775c:	e84a                	sd	s2,16(sp)
    8000775e:	e44e                	sd	s3,8(sp)
    80007760:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007762:	6104                	ld	s1,0(a0)
    80007764:	02950063          	beq	a0,s1,80007784 <lst_print+0x30>
    80007768:	892a                	mv	s2,a0
    printf(" %p", p);
    8000776a:	00001997          	auipc	s3,0x1
    8000776e:	74e98993          	addi	s3,s3,1870 # 80008eb8 <userret+0xe28>
    80007772:	85a6                	mv	a1,s1
    80007774:	854e                	mv	a0,s3
    80007776:	ffff9097          	auipc	ra,0xffff9
    8000777a:	e38080e7          	jalr	-456(ra) # 800005ae <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000777e:	6084                	ld	s1,0(s1)
    80007780:	fe9919e3          	bne	s2,s1,80007772 <lst_print+0x1e>
  }
  printf("\n");
    80007784:	00001517          	auipc	a0,0x1
    80007788:	4bc50513          	addi	a0,a0,1212 # 80008c40 <userret+0xbb0>
    8000778c:	ffff9097          	auipc	ra,0xffff9
    80007790:	e22080e7          	jalr	-478(ra) # 800005ae <printf>
}
    80007794:	70a2                	ld	ra,40(sp)
    80007796:	7402                	ld	s0,32(sp)
    80007798:	64e2                	ld	s1,24(sp)
    8000779a:	6942                	ld	s2,16(sp)
    8000779c:	69a2                	ld	s3,8(sp)
    8000779e:	6145                	addi	sp,sp,48
    800077a0:	8082                	ret
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
