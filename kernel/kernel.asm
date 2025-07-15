
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	80010113          	addi	sp,sp,-2048 # 80009800 <stack0>
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
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fb660613          	addi	a2,a2,-74 # 80009000 <mscratch0>
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
    80000060:	b1478793          	addi	a5,a5,-1260 # 80005b70 <timervec>
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
    800000aa:	b8878793          	addi	a5,a5,-1144 # 80000c2e <main>
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
  timerinit();
    800000c4:	00000097          	auipc	ra,0x0
    800000c8:	f58080e7          	jalr	-168(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000cc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000d0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000d2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000d4:	30200073          	mret
}
    800000d8:	60a2                	ld	ra,8(sp)
    800000da:	6402                	ld	s0,0(sp)
    800000dc:	0141                	addi	sp,sp,16
    800000de:	8082                	ret

00000000800000e0 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    800000e0:	7159                	addi	sp,sp,-112
    800000e2:	f486                	sd	ra,104(sp)
    800000e4:	f0a2                	sd	s0,96(sp)
    800000e6:	eca6                	sd	s1,88(sp)
    800000e8:	e8ca                	sd	s2,80(sp)
    800000ea:	e4ce                	sd	s3,72(sp)
    800000ec:	e0d2                	sd	s4,64(sp)
    800000ee:	fc56                	sd	s5,56(sp)
    800000f0:	f85a                	sd	s6,48(sp)
    800000f2:	f45e                	sd	s7,40(sp)
    800000f4:	f062                	sd	s8,32(sp)
    800000f6:	ec66                	sd	s9,24(sp)
    800000f8:	e86a                	sd	s10,16(sp)
    800000fa:	1880                	addi	s0,sp,112
    800000fc:	8aaa                	mv	s5,a0
    800000fe:	8a2e                	mv	s4,a1
    80000100:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000102:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000106:	00011517          	auipc	a0,0x11
    8000010a:	6fa50513          	addi	a0,a0,1786 # 80011800 <cons>
    8000010e:	00001097          	auipc	ra,0x1
    80000112:	8ae080e7          	jalr	-1874(ra) # 800009bc <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000116:	00011497          	auipc	s1,0x11
    8000011a:	6ea48493          	addi	s1,s1,1770 # 80011800 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000011e:	00011917          	auipc	s2,0x11
    80000122:	77a90913          	addi	s2,s2,1914 # 80011898 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    80000126:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000128:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000012a:	4ca9                	li	s9,10
  while(n > 0){
    8000012c:	07305863          	blez	s3,8000019c <consoleread+0xbc>
    while(cons.r == cons.w){
    80000130:	0984a783          	lw	a5,152(s1)
    80000134:	09c4a703          	lw	a4,156(s1)
    80000138:	02f71463          	bne	a4,a5,80000160 <consoleread+0x80>
      if(myproc()->killed){
    8000013c:	00001097          	auipc	ra,0x1
    80000140:	5e0080e7          	jalr	1504(ra) # 8000171c <myproc>
    80000144:	591c                	lw	a5,48(a0)
    80000146:	e7b5                	bnez	a5,800001b2 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    80000148:	85a6                	mv	a1,s1
    8000014a:	854a                	mv	a0,s2
    8000014c:	00002097          	auipc	ra,0x2
    80000150:	de6080e7          	jalr	-538(ra) # 80001f32 <sleep>
    while(cons.r == cons.w){
    80000154:	0984a783          	lw	a5,152(s1)
    80000158:	09c4a703          	lw	a4,156(s1)
    8000015c:	fef700e3          	beq	a4,a5,8000013c <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80000160:	0017871b          	addiw	a4,a5,1
    80000164:	08e4ac23          	sw	a4,152(s1)
    80000168:	07f7f713          	andi	a4,a5,127
    8000016c:	9726                	add	a4,a4,s1
    8000016e:	01874703          	lbu	a4,24(a4)
    80000172:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000176:	077d0563          	beq	s10,s7,800001e0 <consoleread+0x100>
    cbuf = c;
    8000017a:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000017e:	4685                	li	a3,1
    80000180:	f9f40613          	addi	a2,s0,-97
    80000184:	85d2                	mv	a1,s4
    80000186:	8556                	mv	a0,s5
    80000188:	00002097          	auipc	ra,0x2
    8000018c:	004080e7          	jalr	4(ra) # 8000218c <either_copyout>
    80000190:	01850663          	beq	a0,s8,8000019c <consoleread+0xbc>
    dst++;
    80000194:	0a05                	addi	s4,s4,1
    --n;
    80000196:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000198:	f99d1ae3          	bne	s10,s9,8000012c <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000019c:	00011517          	auipc	a0,0x11
    800001a0:	66450513          	addi	a0,a0,1636 # 80011800 <cons>
    800001a4:	00001097          	auipc	ra,0x1
    800001a8:	880080e7          	jalr	-1920(ra) # 80000a24 <release>

  return target - n;
    800001ac:	413b053b          	subw	a0,s6,s3
    800001b0:	a811                	j	800001c4 <consoleread+0xe4>
        release(&cons.lock);
    800001b2:	00011517          	auipc	a0,0x11
    800001b6:	64e50513          	addi	a0,a0,1614 # 80011800 <cons>
    800001ba:	00001097          	auipc	ra,0x1
    800001be:	86a080e7          	jalr	-1942(ra) # 80000a24 <release>
        return -1;
    800001c2:	557d                	li	a0,-1
}
    800001c4:	70a6                	ld	ra,104(sp)
    800001c6:	7406                	ld	s0,96(sp)
    800001c8:	64e6                	ld	s1,88(sp)
    800001ca:	6946                	ld	s2,80(sp)
    800001cc:	69a6                	ld	s3,72(sp)
    800001ce:	6a06                	ld	s4,64(sp)
    800001d0:	7ae2                	ld	s5,56(sp)
    800001d2:	7b42                	ld	s6,48(sp)
    800001d4:	7ba2                	ld	s7,40(sp)
    800001d6:	7c02                	ld	s8,32(sp)
    800001d8:	6ce2                	ld	s9,24(sp)
    800001da:	6d42                	ld	s10,16(sp)
    800001dc:	6165                	addi	sp,sp,112
    800001de:	8082                	ret
      if(n < target){
    800001e0:	0009871b          	sext.w	a4,s3
    800001e4:	fb677ce3          	bgeu	a4,s6,8000019c <consoleread+0xbc>
        cons.r--;
    800001e8:	00011717          	auipc	a4,0x11
    800001ec:	6af72823          	sw	a5,1712(a4) # 80011898 <cons+0x98>
    800001f0:	b775                	j	8000019c <consoleread+0xbc>

00000000800001f2 <consputc>:
  if(panicked){
    800001f2:	00028797          	auipc	a5,0x28
    800001f6:	e267a783          	lw	a5,-474(a5) # 80028018 <panicked>
    800001fa:	c391                	beqz	a5,800001fe <consputc+0xc>
    for(;;)
    800001fc:	a001                	j	800001fc <consputc+0xa>
{
    800001fe:	1141                	addi	sp,sp,-16
    80000200:	e406                	sd	ra,8(sp)
    80000202:	e022                	sd	s0,0(sp)
    80000204:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000206:	10000793          	li	a5,256
    8000020a:	00f50a63          	beq	a0,a5,8000021e <consputc+0x2c>
    uartputc(c);
    8000020e:	00000097          	auipc	ra,0x0
    80000212:	5cc080e7          	jalr	1484(ra) # 800007da <uartputc>
}
    80000216:	60a2                	ld	ra,8(sp)
    80000218:	6402                	ld	s0,0(sp)
    8000021a:	0141                	addi	sp,sp,16
    8000021c:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    8000021e:	4521                	li	a0,8
    80000220:	00000097          	auipc	ra,0x0
    80000224:	5ba080e7          	jalr	1466(ra) # 800007da <uartputc>
    80000228:	02000513          	li	a0,32
    8000022c:	00000097          	auipc	ra,0x0
    80000230:	5ae080e7          	jalr	1454(ra) # 800007da <uartputc>
    80000234:	4521                	li	a0,8
    80000236:	00000097          	auipc	ra,0x0
    8000023a:	5a4080e7          	jalr	1444(ra) # 800007da <uartputc>
    8000023e:	bfe1                	j	80000216 <consputc+0x24>

0000000080000240 <consolewrite>:
{
    80000240:	715d                	addi	sp,sp,-80
    80000242:	e486                	sd	ra,72(sp)
    80000244:	e0a2                	sd	s0,64(sp)
    80000246:	fc26                	sd	s1,56(sp)
    80000248:	f84a                	sd	s2,48(sp)
    8000024a:	f44e                	sd	s3,40(sp)
    8000024c:	f052                	sd	s4,32(sp)
    8000024e:	ec56                	sd	s5,24(sp)
    80000250:	0880                	addi	s0,sp,80
    80000252:	89aa                	mv	s3,a0
    80000254:	84ae                	mv	s1,a1
    80000256:	8ab2                	mv	s5,a2
  acquire(&cons.lock);
    80000258:	00011517          	auipc	a0,0x11
    8000025c:	5a850513          	addi	a0,a0,1448 # 80011800 <cons>
    80000260:	00000097          	auipc	ra,0x0
    80000264:	75c080e7          	jalr	1884(ra) # 800009bc <acquire>
  for(i = 0; i < n; i++){
    80000268:	03505e63          	blez	s5,800002a4 <consolewrite+0x64>
    8000026c:	00148913          	addi	s2,s1,1
    80000270:	fffa879b          	addiw	a5,s5,-1
    80000274:	1782                	slli	a5,a5,0x20
    80000276:	9381                	srli	a5,a5,0x20
    80000278:	993e                	add	s2,s2,a5
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000027a:	5a7d                	li	s4,-1
    8000027c:	4685                	li	a3,1
    8000027e:	8626                	mv	a2,s1
    80000280:	85ce                	mv	a1,s3
    80000282:	fbf40513          	addi	a0,s0,-65
    80000286:	00002097          	auipc	ra,0x2
    8000028a:	f5c080e7          	jalr	-164(ra) # 800021e2 <either_copyin>
    8000028e:	01450b63          	beq	a0,s4,800002a4 <consolewrite+0x64>
    consputc(c);
    80000292:	fbf44503          	lbu	a0,-65(s0)
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	f5c080e7          	jalr	-164(ra) # 800001f2 <consputc>
  for(i = 0; i < n; i++){
    8000029e:	0485                	addi	s1,s1,1
    800002a0:	fd249ee3          	bne	s1,s2,8000027c <consolewrite+0x3c>
  release(&cons.lock);
    800002a4:	00011517          	auipc	a0,0x11
    800002a8:	55c50513          	addi	a0,a0,1372 # 80011800 <cons>
    800002ac:	00000097          	auipc	ra,0x0
    800002b0:	778080e7          	jalr	1912(ra) # 80000a24 <release>
}
    800002b4:	8556                	mv	a0,s5
    800002b6:	60a6                	ld	ra,72(sp)
    800002b8:	6406                	ld	s0,64(sp)
    800002ba:	74e2                	ld	s1,56(sp)
    800002bc:	7942                	ld	s2,48(sp)
    800002be:	79a2                	ld	s3,40(sp)
    800002c0:	7a02                	ld	s4,32(sp)
    800002c2:	6ae2                	ld	s5,24(sp)
    800002c4:	6161                	addi	sp,sp,80
    800002c6:	8082                	ret

00000000800002c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c8:	1101                	addi	sp,sp,-32
    800002ca:	ec06                	sd	ra,24(sp)
    800002cc:	e822                	sd	s0,16(sp)
    800002ce:	e426                	sd	s1,8(sp)
    800002d0:	e04a                	sd	s2,0(sp)
    800002d2:	1000                	addi	s0,sp,32
    800002d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d6:	00011517          	auipc	a0,0x11
    800002da:	52a50513          	addi	a0,a0,1322 # 80011800 <cons>
    800002de:	00000097          	auipc	ra,0x0
    800002e2:	6de080e7          	jalr	1758(ra) # 800009bc <acquire>

  switch(c){
    800002e6:	47d5                	li	a5,21
    800002e8:	0af48663          	beq	s1,a5,80000394 <consoleintr+0xcc>
    800002ec:	0297ca63          	blt	a5,s1,80000320 <consoleintr+0x58>
    800002f0:	47a1                	li	a5,8
    800002f2:	0ef48763          	beq	s1,a5,800003e0 <consoleintr+0x118>
    800002f6:	47c1                	li	a5,16
    800002f8:	10f49a63          	bne	s1,a5,8000040c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fc:	00002097          	auipc	ra,0x2
    80000300:	f3c080e7          	jalr	-196(ra) # 80002238 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	4fc50513          	addi	a0,a0,1276 # 80011800 <cons>
    8000030c:	00000097          	auipc	ra,0x0
    80000310:	718080e7          	jalr	1816(ra) # 80000a24 <release>
}
    80000314:	60e2                	ld	ra,24(sp)
    80000316:	6442                	ld	s0,16(sp)
    80000318:	64a2                	ld	s1,8(sp)
    8000031a:	6902                	ld	s2,0(sp)
    8000031c:	6105                	addi	sp,sp,32
    8000031e:	8082                	ret
  switch(c){
    80000320:	07f00793          	li	a5,127
    80000324:	0af48e63          	beq	s1,a5,800003e0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000328:	00011717          	auipc	a4,0x11
    8000032c:	4d870713          	addi	a4,a4,1240 # 80011800 <cons>
    80000330:	0a072783          	lw	a5,160(a4)
    80000334:	09872703          	lw	a4,152(a4)
    80000338:	9f99                	subw	a5,a5,a4
    8000033a:	07f00713          	li	a4,127
    8000033e:	fcf763e3          	bltu	a4,a5,80000304 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000342:	47b5                	li	a5,13
    80000344:	0cf48763          	beq	s1,a5,80000412 <consoleintr+0x14a>
      consputc(c);
    80000348:	8526                	mv	a0,s1
    8000034a:	00000097          	auipc	ra,0x0
    8000034e:	ea8080e7          	jalr	-344(ra) # 800001f2 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000352:	00011797          	auipc	a5,0x11
    80000356:	4ae78793          	addi	a5,a5,1198 # 80011800 <cons>
    8000035a:	0a07a703          	lw	a4,160(a5)
    8000035e:	0017069b          	addiw	a3,a4,1
    80000362:	0006861b          	sext.w	a2,a3
    80000366:	0ad7a023          	sw	a3,160(a5)
    8000036a:	07f77713          	andi	a4,a4,127
    8000036e:	97ba                	add	a5,a5,a4
    80000370:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000374:	47a9                	li	a5,10
    80000376:	0cf48563          	beq	s1,a5,80000440 <consoleintr+0x178>
    8000037a:	4791                	li	a5,4
    8000037c:	0cf48263          	beq	s1,a5,80000440 <consoleintr+0x178>
    80000380:	00011797          	auipc	a5,0x11
    80000384:	5187a783          	lw	a5,1304(a5) # 80011898 <cons+0x98>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00011717          	auipc	a4,0x11
    80000398:	46c70713          	addi	a4,a4,1132 # 80011800 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a4:	00011497          	auipc	s1,0x11
    800003a8:	45c48493          	addi	s1,s1,1116 # 80011800 <cons>
    while(cons.e != cons.w &&
    800003ac:	4929                	li	s2,10
    800003ae:	f4f70be3          	beq	a4,a5,80000304 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b2:	37fd                	addiw	a5,a5,-1
    800003b4:	07f7f713          	andi	a4,a5,127
    800003b8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ba:	01874703          	lbu	a4,24(a4)
    800003be:	f52703e3          	beq	a4,s2,80000304 <consoleintr+0x3c>
      cons.e--;
    800003c2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	00000097          	auipc	ra,0x0
    800003ce:	e28080e7          	jalr	-472(ra) # 800001f2 <consputc>
    while(cons.e != cons.w &&
    800003d2:	0a04a783          	lw	a5,160(s1)
    800003d6:	09c4a703          	lw	a4,156(s1)
    800003da:	fcf71ce3          	bne	a4,a5,800003b2 <consoleintr+0xea>
    800003de:	b71d                	j	80000304 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e0:	00011717          	auipc	a4,0x11
    800003e4:	42070713          	addi	a4,a4,1056 # 80011800 <cons>
    800003e8:	0a072783          	lw	a5,160(a4)
    800003ec:	09c72703          	lw	a4,156(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00011717          	auipc	a4,0x11
    800003fa:	4af72523          	sw	a5,1194(a4) # 800118a0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fe:	10000513          	li	a0,256
    80000402:	00000097          	auipc	ra,0x0
    80000406:	df0080e7          	jalr	-528(ra) # 800001f2 <consputc>
    8000040a:	bded                	j	80000304 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040c:	ee048ce3          	beqz	s1,80000304 <consoleintr+0x3c>
    80000410:	bf21                	j	80000328 <consoleintr+0x60>
      consputc(c);
    80000412:	4529                	li	a0,10
    80000414:	00000097          	auipc	ra,0x0
    80000418:	dde080e7          	jalr	-546(ra) # 800001f2 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041c:	00011797          	auipc	a5,0x11
    80000420:	3e478793          	addi	a5,a5,996 # 80011800 <cons>
    80000424:	0a07a703          	lw	a4,160(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a023          	sw	a3,160(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000440:	00011797          	auipc	a5,0x11
    80000444:	44c7ae23          	sw	a2,1116(a5) # 8001189c <cons+0x9c>
        wakeup(&cons.r);
    80000448:	00011517          	auipc	a0,0x11
    8000044c:	45050513          	addi	a0,a0,1104 # 80011898 <cons+0x98>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	c62080e7          	jalr	-926(ra) # 800020b2 <wakeup>
    80000458:	b575                	j	80000304 <consoleintr+0x3c>

000000008000045a <consoleinit>:

void
consoleinit(void)
{
    8000045a:	1141                	addi	sp,sp,-16
    8000045c:	e406                	sd	ra,8(sp)
    8000045e:	e022                	sd	s0,0(sp)
    80000460:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000462:	00007597          	auipc	a1,0x7
    80000466:	cb658593          	addi	a1,a1,-842 # 80007118 <userret+0x88>
    8000046a:	00011517          	auipc	a0,0x11
    8000046e:	39650513          	addi	a0,a0,918 # 80011800 <cons>
    80000472:	00000097          	auipc	ra,0x0
    80000476:	43c080e7          	jalr	1084(ra) # 800008ae <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	32a080e7          	jalr	810(ra) # 800007a4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00021797          	auipc	a5,0x21
    80000486:	65e78793          	addi	a5,a5,1630 # 80021ae0 <devsw>
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c5670713          	addi	a4,a4,-938 # 800000e0 <consoleread>
    80000492:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000494:	00000717          	auipc	a4,0x0
    80000498:	dac70713          	addi	a4,a4,-596 # 80000240 <consolewrite>
    8000049c:	ef98                	sd	a4,24(a5)
}
    8000049e:	60a2                	ld	ra,8(sp)
    800004a0:	6402                	ld	s0,0(sp)
    800004a2:	0141                	addi	sp,sp,16
    800004a4:	8082                	ret

00000000800004a6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a6:	7179                	addi	sp,sp,-48
    800004a8:	f406                	sd	ra,40(sp)
    800004aa:	f022                	sd	s0,32(sp)
    800004ac:	ec26                	sd	s1,24(sp)
    800004ae:	e84a                	sd	s2,16(sp)
    800004b0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b2:	c219                	beqz	a2,800004b8 <printint+0x12>
    800004b4:	08054663          	bltz	a0,80000540 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b8:	2501                	sext.w	a0,a0
    800004ba:	4881                	li	a7,0
    800004bc:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c2:	2581                	sext.w	a1,a1
    800004c4:	00007617          	auipc	a2,0x7
    800004c8:	53c60613          	addi	a2,a2,1340 # 80007a00 <digits>
    800004cc:	883a                	mv	a6,a4
    800004ce:	2705                	addiw	a4,a4,1
    800004d0:	02b577bb          	remuw	a5,a0,a1
    800004d4:	1782                	slli	a5,a5,0x20
    800004d6:	9381                	srli	a5,a5,0x20
    800004d8:	97b2                	add	a5,a5,a2
    800004da:	0007c783          	lbu	a5,0(a5)
    800004de:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e2:	0005079b          	sext.w	a5,a0
    800004e6:	02b5553b          	divuw	a0,a0,a1
    800004ea:	0685                	addi	a3,a3,1
    800004ec:	feb7f0e3          	bgeu	a5,a1,800004cc <printint+0x26>

  if(sign)
    800004f0:	00088b63          	beqz	a7,80000506 <printint+0x60>
    buf[i++] = '-';
    800004f4:	fe040793          	addi	a5,s0,-32
    800004f8:	973e                	add	a4,a4,a5
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000506:	02e05763          	blez	a4,80000534 <printint+0x8e>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	ccc080e7          	jalr	-820(ra) # 800001f2 <consputc>
  while(--i >= 0)
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7c>
}
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    x = -xx;
    80000540:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000544:	4885                	li	a7,1
    x = -xx;
    80000546:	bf9d                	j	800004bc <printint+0x16>

0000000080000548 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000554:	00011797          	auipc	a5,0x11
    80000558:	3607a623          	sw	zero,876(a5) # 800118c0 <pr+0x18>
  printf("panic: ");
    8000055c:	00007517          	auipc	a0,0x7
    80000560:	bc450513          	addi	a0,a0,-1084 # 80007120 <userret+0x90>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00007517          	auipc	a0,0x7
    8000057a:	c2a50513          	addi	a0,a0,-982 # 800071a0 <userret+0x110>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
  panicked = 1; // freeze other CPUs
    80000586:	4785                	li	a5,1
    80000588:	00028717          	auipc	a4,0x28
    8000058c:	a8f72823          	sw	a5,-1392(a4) # 80028018 <panicked>
  for(;;)
    80000590:	a001                	j	80000590 <panic+0x48>

0000000080000592 <printf>:
{
    80000592:	7131                	addi	sp,sp,-192
    80000594:	fc86                	sd	ra,120(sp)
    80000596:	f8a2                	sd	s0,112(sp)
    80000598:	f4a6                	sd	s1,104(sp)
    8000059a:	f0ca                	sd	s2,96(sp)
    8000059c:	ecce                	sd	s3,88(sp)
    8000059e:	e8d2                	sd	s4,80(sp)
    800005a0:	e4d6                	sd	s5,72(sp)
    800005a2:	e0da                	sd	s6,64(sp)
    800005a4:	fc5e                	sd	s7,56(sp)
    800005a6:	f862                	sd	s8,48(sp)
    800005a8:	f466                	sd	s9,40(sp)
    800005aa:	f06a                	sd	s10,32(sp)
    800005ac:	ec6e                	sd	s11,24(sp)
    800005ae:	0100                	addi	s0,sp,128
    800005b0:	8a2a                	mv	s4,a0
    800005b2:	e40c                	sd	a1,8(s0)
    800005b4:	e810                	sd	a2,16(s0)
    800005b6:	ec14                	sd	a3,24(s0)
    800005b8:	f018                	sd	a4,32(s0)
    800005ba:	f41c                	sd	a5,40(s0)
    800005bc:	03043823          	sd	a6,48(s0)
    800005c0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c4:	00011d97          	auipc	s11,0x11
    800005c8:	2fcdad83          	lw	s11,764(s11) # 800118c0 <pr+0x18>
  if(locking)
    800005cc:	020d9b63          	bnez	s11,80000602 <printf+0x70>
  if (fmt == 0)
    800005d0:	040a0263          	beqz	s4,80000614 <printf+0x82>
  va_start(ap, fmt);
    800005d4:	00840793          	addi	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005dc:	000a4503          	lbu	a0,0(s4)
    800005e0:	14050f63          	beqz	a0,8000073e <printf+0x1ac>
    800005e4:	4981                	li	s3,0
    if(c != '%'){
    800005e6:	02500a93          	li	s5,37
    switch(c){
    800005ea:	07000b93          	li	s7,112
  consputc('x');
    800005ee:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f0:	00007b17          	auipc	s6,0x7
    800005f4:	410b0b13          	addi	s6,s6,1040 # 80007a00 <digits>
    switch(c){
    800005f8:	07300c93          	li	s9,115
    800005fc:	06400c13          	li	s8,100
    80000600:	a82d                	j	8000063a <printf+0xa8>
    acquire(&pr.lock);
    80000602:	00011517          	auipc	a0,0x11
    80000606:	2a650513          	addi	a0,a0,678 # 800118a8 <pr>
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	3b2080e7          	jalr	946(ra) # 800009bc <acquire>
    80000612:	bf7d                	j	800005d0 <printf+0x3e>
    panic("null fmt");
    80000614:	00007517          	auipc	a0,0x7
    80000618:	b1c50513          	addi	a0,a0,-1252 # 80007130 <userret+0xa0>
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	f2c080e7          	jalr	-212(ra) # 80000548 <panic>
      consputc(c);
    80000624:	00000097          	auipc	ra,0x0
    80000628:	bce080e7          	jalr	-1074(ra) # 800001f2 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062c:	2985                	addiw	s3,s3,1
    8000062e:	013a07b3          	add	a5,s4,s3
    80000632:	0007c503          	lbu	a0,0(a5)
    80000636:	10050463          	beqz	a0,8000073e <printf+0x1ac>
    if(c != '%'){
    8000063a:	ff5515e3          	bne	a0,s5,80000624 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063e:	2985                	addiw	s3,s3,1
    80000640:	013a07b3          	add	a5,s4,s3
    80000644:	0007c783          	lbu	a5,0(a5)
    80000648:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000064c:	cbed                	beqz	a5,8000073e <printf+0x1ac>
    switch(c){
    8000064e:	05778a63          	beq	a5,s7,800006a2 <printf+0x110>
    80000652:	02fbf663          	bgeu	s7,a5,8000067e <printf+0xec>
    80000656:	09978863          	beq	a5,s9,800006e6 <printf+0x154>
    8000065a:	07800713          	li	a4,120
    8000065e:	0ce79563          	bne	a5,a4,80000728 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000662:	f8843783          	ld	a5,-120(s0)
    80000666:	00878713          	addi	a4,a5,8
    8000066a:	f8e43423          	sd	a4,-120(s0)
    8000066e:	4605                	li	a2,1
    80000670:	85ea                	mv	a1,s10
    80000672:	4388                	lw	a0,0(a5)
    80000674:	00000097          	auipc	ra,0x0
    80000678:	e32080e7          	jalr	-462(ra) # 800004a6 <printint>
      break;
    8000067c:	bf45                	j	8000062c <printf+0x9a>
    switch(c){
    8000067e:	09578f63          	beq	a5,s5,8000071c <printf+0x18a>
    80000682:	0b879363          	bne	a5,s8,80000728 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	45a9                	li	a1,10
    80000696:	4388                	lw	a0,0(a5)
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	e0e080e7          	jalr	-498(ra) # 800004a6 <printint>
      break;
    800006a0:	b771                	j	8000062c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006b2:	03000513          	li	a0,48
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	b3c080e7          	jalr	-1220(ra) # 800001f2 <consputc>
  consputc('x');
    800006be:	07800513          	li	a0,120
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	b30080e7          	jalr	-1232(ra) # 800001f2 <consputc>
    800006ca:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006cc:	03c95793          	srli	a5,s2,0x3c
    800006d0:	97da                	add	a5,a5,s6
    800006d2:	0007c503          	lbu	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	b1c080e7          	jalr	-1252(ra) # 800001f2 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006de:	0912                	slli	s2,s2,0x4
    800006e0:	34fd                	addiw	s1,s1,-1
    800006e2:	f4ed                	bnez	s1,800006cc <printf+0x13a>
    800006e4:	b7a1                	j	8000062c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e6:	f8843783          	ld	a5,-120(s0)
    800006ea:	00878713          	addi	a4,a5,8
    800006ee:	f8e43423          	sd	a4,-120(s0)
    800006f2:	6384                	ld	s1,0(a5)
    800006f4:	cc89                	beqz	s1,8000070e <printf+0x17c>
      for(; *s; s++)
    800006f6:	0004c503          	lbu	a0,0(s1)
    800006fa:	d90d                	beqz	a0,8000062c <printf+0x9a>
        consputc(*s);
    800006fc:	00000097          	auipc	ra,0x0
    80000700:	af6080e7          	jalr	-1290(ra) # 800001f2 <consputc>
      for(; *s; s++)
    80000704:	0485                	addi	s1,s1,1
    80000706:	0004c503          	lbu	a0,0(s1)
    8000070a:	f96d                	bnez	a0,800006fc <printf+0x16a>
    8000070c:	b705                	j	8000062c <printf+0x9a>
        s = "(null)";
    8000070e:	00007497          	auipc	s1,0x7
    80000712:	a1a48493          	addi	s1,s1,-1510 # 80007128 <userret+0x98>
      for(; *s; s++)
    80000716:	02800513          	li	a0,40
    8000071a:	b7cd                	j	800006fc <printf+0x16a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	ad4080e7          	jalr	-1324(ra) # 800001f2 <consputc>
      break;
    80000726:	b719                	j	8000062c <printf+0x9a>
      consputc('%');
    80000728:	8556                	mv	a0,s5
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	ac8080e7          	jalr	-1336(ra) # 800001f2 <consputc>
      consputc(c);
    80000732:	8526                	mv	a0,s1
    80000734:	00000097          	auipc	ra,0x0
    80000738:	abe080e7          	jalr	-1346(ra) # 800001f2 <consputc>
      break;
    8000073c:	bdc5                	j	8000062c <printf+0x9a>
  if(locking)
    8000073e:	020d9163          	bnez	s11,80000760 <printf+0x1ce>
}
    80000742:	70e6                	ld	ra,120(sp)
    80000744:	7446                	ld	s0,112(sp)
    80000746:	74a6                	ld	s1,104(sp)
    80000748:	7906                	ld	s2,96(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7ca2                	ld	s9,40(sp)
    80000758:	7d02                	ld	s10,32(sp)
    8000075a:	6de2                	ld	s11,24(sp)
    8000075c:	6129                	addi	sp,sp,192
    8000075e:	8082                	ret
    release(&pr.lock);
    80000760:	00011517          	auipc	a0,0x11
    80000764:	14850513          	addi	a0,a0,328 # 800118a8 <pr>
    80000768:	00000097          	auipc	ra,0x0
    8000076c:	2bc080e7          	jalr	700(ra) # 80000a24 <release>
}
    80000770:	bfc9                	j	80000742 <printf+0x1b0>

0000000080000772 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000772:	1101                	addi	sp,sp,-32
    80000774:	ec06                	sd	ra,24(sp)
    80000776:	e822                	sd	s0,16(sp)
    80000778:	e426                	sd	s1,8(sp)
    8000077a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077c:	00011497          	auipc	s1,0x11
    80000780:	12c48493          	addi	s1,s1,300 # 800118a8 <pr>
    80000784:	00007597          	auipc	a1,0x7
    80000788:	9bc58593          	addi	a1,a1,-1604 # 80007140 <userret+0xb0>
    8000078c:	8526                	mv	a0,s1
    8000078e:	00000097          	auipc	ra,0x0
    80000792:	120080e7          	jalr	288(ra) # 800008ae <initlock>
  pr.locking = 1;
    80000796:	4785                	li	a5,1
    80000798:	cc9c                	sw	a5,24(s1)
}
    8000079a:	60e2                	ld	ra,24(sp)
    8000079c:	6442                	ld	s0,16(sp)
    8000079e:	64a2                	ld	s1,8(sp)
    800007a0:	6105                	addi	sp,sp,32
    800007a2:	8082                	ret

00000000800007a4 <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    800007a4:	1141                	addi	sp,sp,-16
    800007a6:	e422                	sd	s0,8(sp)
    800007a8:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007aa:	100007b7          	lui	a5,0x10000
    800007ae:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    800007b2:	f8000713          	li	a4,-128
    800007b6:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ba:	470d                	li	a4,3
    800007bc:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    800007c4:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    800007c8:	471d                	li	a4,7
    800007ca:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    800007ce:	4705                	li	a4,1
    800007d0:	00e780a3          	sb	a4,1(a5)
}
    800007d4:	6422                	ld	s0,8(sp)
    800007d6:	0141                	addi	sp,sp,16
    800007d8:	8082                	ret

00000000800007da <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    800007da:	1141                	addi	sp,sp,-16
    800007dc:	e422                	sd	s0,8(sp)
    800007de:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    800007e0:	10000737          	lui	a4,0x10000
    800007e4:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007e8:	0207f793          	andi	a5,a5,32
    800007ec:	dfe5                	beqz	a5,800007e4 <uartputc+0xa>
    ;
  WriteReg(THR, c);
    800007ee:	0ff57513          	andi	a0,a0,255
    800007f2:	100007b7          	lui	a5,0x10000
    800007f6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    800007fa:	6422                	ld	s0,8(sp)
    800007fc:	0141                	addi	sp,sp,16
    800007fe:	8082                	ret

0000000080000800 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000800:	1141                	addi	sp,sp,-16
    80000802:	e422                	sd	s0,8(sp)
    80000804:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000806:	100007b7          	lui	a5,0x10000
    8000080a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000080e:	8b85                	andi	a5,a5,1
    80000810:	cb91                	beqz	a5,80000824 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000812:	100007b7          	lui	a5,0x10000
    80000816:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000081a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000081e:	6422                	ld	s0,8(sp)
    80000820:	0141                	addi	sp,sp,16
    80000822:	8082                	ret
    return -1;
    80000824:	557d                	li	a0,-1
    80000826:	bfe5                	j	8000081e <uartgetc+0x1e>

0000000080000828 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000828:	1101                	addi	sp,sp,-32
    8000082a:	ec06                	sd	ra,24(sp)
    8000082c:	e822                	sd	s0,16(sp)
    8000082e:	e426                	sd	s1,8(sp)
    80000830:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000832:	54fd                	li	s1,-1
    80000834:	a029                	j	8000083e <uartintr+0x16>
      break;
    consoleintr(c);
    80000836:	00000097          	auipc	ra,0x0
    8000083a:	a92080e7          	jalr	-1390(ra) # 800002c8 <consoleintr>
    int c = uartgetc();
    8000083e:	00000097          	auipc	ra,0x0
    80000842:	fc2080e7          	jalr	-62(ra) # 80000800 <uartgetc>
    if(c == -1)
    80000846:	fe9518e3          	bne	a0,s1,80000836 <uartintr+0xe>
  }
}
    8000084a:	60e2                	ld	ra,24(sp)
    8000084c:	6442                	ld	s0,16(sp)
    8000084e:	64a2                	ld	s1,8(sp)
    80000850:	6105                	addi	sp,sp,32
    80000852:	8082                	ret

0000000080000854 <kinit>:

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.
void
kinit()
{
    80000854:	1141                	addi	sp,sp,-16
    80000856:	e406                	sd	ra,8(sp)
    80000858:	e022                	sd	s0,0(sp)
    8000085a:	0800                	addi	s0,sp,16
  char *p = (char *) PGROUNDUP((uint64) end);
  bd_init(p, (void*)PHYSTOP);
    8000085c:	45c5                	li	a1,17
    8000085e:	05ee                	slli	a1,a1,0x1b
    80000860:	00028517          	auipc	a0,0x28
    80000864:	7fb50513          	addi	a0,a0,2043 # 8002905b <end+0xfff>
    80000868:	77fd                	lui	a5,0xfffff
    8000086a:	8d7d                	and	a0,a0,a5
    8000086c:	00006097          	auipc	ra,0x6
    80000870:	440080e7          	jalr	1088(ra) # 80006cac <bd_init>
}
    80000874:	60a2                	ld	ra,8(sp)
    80000876:	6402                	ld	s0,0(sp)
    80000878:	0141                	addi	sp,sp,16
    8000087a:	8082                	ret

000000008000087c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000087c:	1141                	addi	sp,sp,-16
    8000087e:	e406                	sd	ra,8(sp)
    80000880:	e022                	sd	s0,0(sp)
    80000882:	0800                	addi	s0,sp,16
  bd_free(pa);
    80000884:	00006097          	auipc	ra,0x6
    80000888:	f4a080e7          	jalr	-182(ra) # 800067ce <bd_free>
}
    8000088c:	60a2                	ld	ra,8(sp)
    8000088e:	6402                	ld	s0,0(sp)
    80000890:	0141                	addi	sp,sp,16
    80000892:	8082                	ret

0000000080000894 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000894:	1141                	addi	sp,sp,-16
    80000896:	e406                	sd	ra,8(sp)
    80000898:	e022                	sd	s0,0(sp)
    8000089a:	0800                	addi	s0,sp,16
  return bd_malloc(PGSIZE);
    8000089c:	6505                	lui	a0,0x1
    8000089e:	00006097          	auipc	ra,0x6
    800008a2:	d44080e7          	jalr	-700(ra) # 800065e2 <bd_malloc>
}
    800008a6:	60a2                	ld	ra,8(sp)
    800008a8:	6402                	ld	s0,0(sp)
    800008aa:	0141                	addi	sp,sp,16
    800008ac:	8082                	ret

00000000800008ae <initlock>:

uint64 ntest_and_set;

void
initlock(struct spinlock *lk, char *name)
{
    800008ae:	1141                	addi	sp,sp,-16
    800008b0:	e422                	sd	s0,8(sp)
    800008b2:	0800                	addi	s0,sp,16
  lk->name = name;
    800008b4:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800008b6:	00052023          	sw	zero,0(a0) # 1000 <_entry-0x7ffff000>
  lk->cpu = 0;
    800008ba:	00053823          	sd	zero,16(a0)
}
    800008be:	6422                	ld	s0,8(sp)
    800008c0:	0141                	addi	sp,sp,16
    800008c2:	8082                	ret

00000000800008c4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800008c4:	1101                	addi	sp,sp,-32
    800008c6:	ec06                	sd	ra,24(sp)
    800008c8:	e822                	sd	s0,16(sp)
    800008ca:	e426                	sd	s1,8(sp)
    800008cc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800008ce:	100024f3          	csrr	s1,sstatus
    800008d2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800008d6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800008d8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800008dc:	00001097          	auipc	ra,0x1
    800008e0:	e24080e7          	jalr	-476(ra) # 80001700 <mycpu>
    800008e4:	5d3c                	lw	a5,120(a0)
    800008e6:	cf89                	beqz	a5,80000900 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800008e8:	00001097          	auipc	ra,0x1
    800008ec:	e18080e7          	jalr	-488(ra) # 80001700 <mycpu>
    800008f0:	5d3c                	lw	a5,120(a0)
    800008f2:	2785                	addiw	a5,a5,1
    800008f4:	dd3c                	sw	a5,120(a0)
}
    800008f6:	60e2                	ld	ra,24(sp)
    800008f8:	6442                	ld	s0,16(sp)
    800008fa:	64a2                	ld	s1,8(sp)
    800008fc:	6105                	addi	sp,sp,32
    800008fe:	8082                	ret
    mycpu()->intena = old;
    80000900:	00001097          	auipc	ra,0x1
    80000904:	e00080e7          	jalr	-512(ra) # 80001700 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000908:	8085                	srli	s1,s1,0x1
    8000090a:	8885                	andi	s1,s1,1
    8000090c:	dd64                	sw	s1,124(a0)
    8000090e:	bfe9                	j	800008e8 <push_off+0x24>

0000000080000910 <pop_off>:

void
pop_off(void)
{
    80000910:	1141                	addi	sp,sp,-16
    80000912:	e406                	sd	ra,8(sp)
    80000914:	e022                	sd	s0,0(sp)
    80000916:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000918:	00001097          	auipc	ra,0x1
    8000091c:	de8080e7          	jalr	-536(ra) # 80001700 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000920:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000924:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000926:	eb9d                	bnez	a5,8000095c <pop_off+0x4c>
    panic("pop_off - interruptible");
  c->noff -= 1;
    80000928:	5d3c                	lw	a5,120(a0)
    8000092a:	37fd                	addiw	a5,a5,-1
    8000092c:	0007871b          	sext.w	a4,a5
    80000930:	dd3c                	sw	a5,120(a0)
  if(c->noff < 0)
    80000932:	02074d63          	bltz	a4,8000096c <pop_off+0x5c>
    panic("pop_off");
  if(c->noff == 0 && c->intena)
    80000936:	ef19                	bnez	a4,80000954 <pop_off+0x44>
    80000938:	5d7c                	lw	a5,124(a0)
    8000093a:	cf89                	beqz	a5,80000954 <pop_off+0x44>
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000093c:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000940:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000944:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000948:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000094c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000950:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000954:	60a2                	ld	ra,8(sp)
    80000956:	6402                	ld	s0,0(sp)
    80000958:	0141                	addi	sp,sp,16
    8000095a:	8082                	ret
    panic("pop_off - interruptible");
    8000095c:	00006517          	auipc	a0,0x6
    80000960:	7ec50513          	addi	a0,a0,2028 # 80007148 <userret+0xb8>
    80000964:	00000097          	auipc	ra,0x0
    80000968:	be4080e7          	jalr	-1052(ra) # 80000548 <panic>
    panic("pop_off");
    8000096c:	00006517          	auipc	a0,0x6
    80000970:	7f450513          	addi	a0,a0,2036 # 80007160 <userret+0xd0>
    80000974:	00000097          	auipc	ra,0x0
    80000978:	bd4080e7          	jalr	-1068(ra) # 80000548 <panic>

000000008000097c <holding>:
{
    8000097c:	1101                	addi	sp,sp,-32
    8000097e:	ec06                	sd	ra,24(sp)
    80000980:	e822                	sd	s0,16(sp)
    80000982:	e426                	sd	s1,8(sp)
    80000984:	1000                	addi	s0,sp,32
    80000986:	84aa                	mv	s1,a0
  push_off();
    80000988:	00000097          	auipc	ra,0x0
    8000098c:	f3c080e7          	jalr	-196(ra) # 800008c4 <push_off>
  r = (lk->locked && lk->cpu == mycpu());
    80000990:	409c                	lw	a5,0(s1)
    80000992:	ef81                	bnez	a5,800009aa <holding+0x2e>
    80000994:	4481                	li	s1,0
  pop_off();
    80000996:	00000097          	auipc	ra,0x0
    8000099a:	f7a080e7          	jalr	-134(ra) # 80000910 <pop_off>
}
    8000099e:	8526                	mv	a0,s1
    800009a0:	60e2                	ld	ra,24(sp)
    800009a2:	6442                	ld	s0,16(sp)
    800009a4:	64a2                	ld	s1,8(sp)
    800009a6:	6105                	addi	sp,sp,32
    800009a8:	8082                	ret
  r = (lk->locked && lk->cpu == mycpu());
    800009aa:	6884                	ld	s1,16(s1)
    800009ac:	00001097          	auipc	ra,0x1
    800009b0:	d54080e7          	jalr	-684(ra) # 80001700 <mycpu>
    800009b4:	8c89                	sub	s1,s1,a0
    800009b6:	0014b493          	seqz	s1,s1
    800009ba:	bff1                	j	80000996 <holding+0x1a>

00000000800009bc <acquire>:
{
    800009bc:	1101                	addi	sp,sp,-32
    800009be:	ec06                	sd	ra,24(sp)
    800009c0:	e822                	sd	s0,16(sp)
    800009c2:	e426                	sd	s1,8(sp)
    800009c4:	1000                	addi	s0,sp,32
    800009c6:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	efc080e7          	jalr	-260(ra) # 800008c4 <push_off>
  if(holding(lk))
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	faa080e7          	jalr	-86(ra) # 8000097c <holding>
    800009da:	e901                	bnez	a0,800009ea <acquire+0x2e>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    800009dc:	4685                	li	a3,1
     __sync_fetch_and_add(&ntest_and_set, 1);
    800009de:	00027717          	auipc	a4,0x27
    800009e2:	64270713          	addi	a4,a4,1602 # 80028020 <ntest_and_set>
    800009e6:	4605                	li	a2,1
    800009e8:	a829                	j	80000a02 <acquire+0x46>
    panic("acquire");
    800009ea:	00006517          	auipc	a0,0x6
    800009ee:	77e50513          	addi	a0,a0,1918 # 80007168 <userret+0xd8>
    800009f2:	00000097          	auipc	ra,0x0
    800009f6:	b56080e7          	jalr	-1194(ra) # 80000548 <panic>
     __sync_fetch_and_add(&ntest_and_set, 1);
    800009fa:	0f50000f          	fence	iorw,ow
    800009fe:	04c7302f          	amoadd.d.aq	zero,a2,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000a02:	87b6                	mv	a5,a3
    80000a04:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000a08:	2781                	sext.w	a5,a5
    80000a0a:	fbe5                	bnez	a5,800009fa <acquire+0x3e>
  __sync_synchronize();
    80000a0c:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000a10:	00001097          	auipc	ra,0x1
    80000a14:	cf0080e7          	jalr	-784(ra) # 80001700 <mycpu>
    80000a18:	e888                	sd	a0,16(s1)
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6105                	addi	sp,sp,32
    80000a22:	8082                	ret

0000000080000a24 <release>:
{
    80000a24:	1101                	addi	sp,sp,-32
    80000a26:	ec06                	sd	ra,24(sp)
    80000a28:	e822                	sd	s0,16(sp)
    80000a2a:	e426                	sd	s1,8(sp)
    80000a2c:	1000                	addi	s0,sp,32
    80000a2e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000a30:	00000097          	auipc	ra,0x0
    80000a34:	f4c080e7          	jalr	-180(ra) # 8000097c <holding>
    80000a38:	c115                	beqz	a0,80000a5c <release+0x38>
  lk->cpu = 0;
    80000a3a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000a3e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000a42:	0f50000f          	fence	iorw,ow
    80000a46:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	ec6080e7          	jalr	-314(ra) # 80000910 <pop_off>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret
    panic("release");
    80000a5c:	00006517          	auipc	a0,0x6
    80000a60:	71450513          	addi	a0,a0,1812 # 80007170 <userret+0xe0>
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	ae4080e7          	jalr	-1308(ra) # 80000548 <panic>

0000000080000a6c <sys_ntas>:

uint64
sys_ntas(void)
{
    80000a6c:	1141                	addi	sp,sp,-16
    80000a6e:	e422                	sd	s0,8(sp)
    80000a70:	0800                	addi	s0,sp,16
  return ntest_and_set;
}
    80000a72:	00027517          	auipc	a0,0x27
    80000a76:	5ae53503          	ld	a0,1454(a0) # 80028020 <ntest_and_set>
    80000a7a:	6422                	ld	s0,8(sp)
    80000a7c:	0141                	addi	sp,sp,16
    80000a7e:	8082                	ret

0000000080000a80 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000a80:	1141                	addi	sp,sp,-16
    80000a82:	e422                	sd	s0,8(sp)
    80000a84:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000a86:	ca19                	beqz	a2,80000a9c <memset+0x1c>
    80000a88:	87aa                	mv	a5,a0
    80000a8a:	1602                	slli	a2,a2,0x20
    80000a8c:	9201                	srli	a2,a2,0x20
    80000a8e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000a92:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffd6fa4>
  for(i = 0; i < n; i++){
    80000a96:	0785                	addi	a5,a5,1
    80000a98:	fee79de3          	bne	a5,a4,80000a92 <memset+0x12>
  }
  return dst;
}
    80000a9c:	6422                	ld	s0,8(sp)
    80000a9e:	0141                	addi	sp,sp,16
    80000aa0:	8082                	ret

0000000080000aa2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000aa2:	1141                	addi	sp,sp,-16
    80000aa4:	e422                	sd	s0,8(sp)
    80000aa6:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000aa8:	ca05                	beqz	a2,80000ad8 <memcmp+0x36>
    80000aaa:	fff6069b          	addiw	a3,a2,-1
    80000aae:	1682                	slli	a3,a3,0x20
    80000ab0:	9281                	srli	a3,a3,0x20
    80000ab2:	0685                	addi	a3,a3,1
    80000ab4:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000ab6:	00054783          	lbu	a5,0(a0)
    80000aba:	0005c703          	lbu	a4,0(a1)
    80000abe:	00e79863          	bne	a5,a4,80000ace <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ac2:	0505                	addi	a0,a0,1
    80000ac4:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ac6:	fed518e3          	bne	a0,a3,80000ab6 <memcmp+0x14>
  }

  return 0;
    80000aca:	4501                	li	a0,0
    80000acc:	a019                	j	80000ad2 <memcmp+0x30>
      return *s1 - *s2;
    80000ace:	40e7853b          	subw	a0,a5,a4
}
    80000ad2:	6422                	ld	s0,8(sp)
    80000ad4:	0141                	addi	sp,sp,16
    80000ad6:	8082                	ret
  return 0;
    80000ad8:	4501                	li	a0,0
    80000ada:	bfe5                	j	80000ad2 <memcmp+0x30>

0000000080000adc <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000adc:	1141                	addi	sp,sp,-16
    80000ade:	e422                	sd	s0,8(sp)
    80000ae0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ae2:	02a5e563          	bltu	a1,a0,80000b0c <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ae6:	fff6069b          	addiw	a3,a2,-1
    80000aea:	ce11                	beqz	a2,80000b06 <memmove+0x2a>
    80000aec:	1682                	slli	a3,a3,0x20
    80000aee:	9281                	srli	a3,a3,0x20
    80000af0:	0685                	addi	a3,a3,1
    80000af2:	96ae                	add	a3,a3,a1
    80000af4:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000af6:	0585                	addi	a1,a1,1
    80000af8:	0785                	addi	a5,a5,1
    80000afa:	fff5c703          	lbu	a4,-1(a1)
    80000afe:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000b02:	fed59ae3          	bne	a1,a3,80000af6 <memmove+0x1a>

  return dst;
}
    80000b06:	6422                	ld	s0,8(sp)
    80000b08:	0141                	addi	sp,sp,16
    80000b0a:	8082                	ret
  if(s < d && s + n > d){
    80000b0c:	02061713          	slli	a4,a2,0x20
    80000b10:	9301                	srli	a4,a4,0x20
    80000b12:	00e587b3          	add	a5,a1,a4
    80000b16:	fcf578e3          	bgeu	a0,a5,80000ae6 <memmove+0xa>
    d += n;
    80000b1a:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000b1c:	fff6069b          	addiw	a3,a2,-1
    80000b20:	d27d                	beqz	a2,80000b06 <memmove+0x2a>
    80000b22:	02069613          	slli	a2,a3,0x20
    80000b26:	9201                	srli	a2,a2,0x20
    80000b28:	fff64613          	not	a2,a2
    80000b2c:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000b2e:	17fd                	addi	a5,a5,-1
    80000b30:	177d                	addi	a4,a4,-1
    80000b32:	0007c683          	lbu	a3,0(a5)
    80000b36:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000b3a:	fef61ae3          	bne	a2,a5,80000b2e <memmove+0x52>
    80000b3e:	b7e1                	j	80000b06 <memmove+0x2a>

0000000080000b40 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000b40:	1141                	addi	sp,sp,-16
    80000b42:	e406                	sd	ra,8(sp)
    80000b44:	e022                	sd	s0,0(sp)
    80000b46:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	f94080e7          	jalr	-108(ra) # 80000adc <memmove>
}
    80000b50:	60a2                	ld	ra,8(sp)
    80000b52:	6402                	ld	s0,0(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000b58:	1141                	addi	sp,sp,-16
    80000b5a:	e422                	sd	s0,8(sp)
    80000b5c:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000b5e:	ce11                	beqz	a2,80000b7a <strncmp+0x22>
    80000b60:	00054783          	lbu	a5,0(a0)
    80000b64:	cf89                	beqz	a5,80000b7e <strncmp+0x26>
    80000b66:	0005c703          	lbu	a4,0(a1)
    80000b6a:	00f71a63          	bne	a4,a5,80000b7e <strncmp+0x26>
    n--, p++, q++;
    80000b6e:	367d                	addiw	a2,a2,-1
    80000b70:	0505                	addi	a0,a0,1
    80000b72:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000b74:	f675                	bnez	a2,80000b60 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000b76:	4501                	li	a0,0
    80000b78:	a809                	j	80000b8a <strncmp+0x32>
    80000b7a:	4501                	li	a0,0
    80000b7c:	a039                	j	80000b8a <strncmp+0x32>
  if(n == 0)
    80000b7e:	ca09                	beqz	a2,80000b90 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000b80:	00054503          	lbu	a0,0(a0)
    80000b84:	0005c783          	lbu	a5,0(a1)
    80000b88:	9d1d                	subw	a0,a0,a5
}
    80000b8a:	6422                	ld	s0,8(sp)
    80000b8c:	0141                	addi	sp,sp,16
    80000b8e:	8082                	ret
    return 0;
    80000b90:	4501                	li	a0,0
    80000b92:	bfe5                	j	80000b8a <strncmp+0x32>

0000000080000b94 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000b94:	1141                	addi	sp,sp,-16
    80000b96:	e422                	sd	s0,8(sp)
    80000b98:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000b9a:	872a                	mv	a4,a0
    80000b9c:	8832                	mv	a6,a2
    80000b9e:	367d                	addiw	a2,a2,-1
    80000ba0:	01005963          	blez	a6,80000bb2 <strncpy+0x1e>
    80000ba4:	0705                	addi	a4,a4,1
    80000ba6:	0005c783          	lbu	a5,0(a1)
    80000baa:	fef70fa3          	sb	a5,-1(a4)
    80000bae:	0585                	addi	a1,a1,1
    80000bb0:	f7f5                	bnez	a5,80000b9c <strncpy+0x8>
    ;
  while(n-- > 0)
    80000bb2:	86ba                	mv	a3,a4
    80000bb4:	00c05c63          	blez	a2,80000bcc <strncpy+0x38>
    *s++ = 0;
    80000bb8:	0685                	addi	a3,a3,1
    80000bba:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000bbe:	fff6c793          	not	a5,a3
    80000bc2:	9fb9                	addw	a5,a5,a4
    80000bc4:	010787bb          	addw	a5,a5,a6
    80000bc8:	fef048e3          	bgtz	a5,80000bb8 <strncpy+0x24>
  return os;
}
    80000bcc:	6422                	ld	s0,8(sp)
    80000bce:	0141                	addi	sp,sp,16
    80000bd0:	8082                	ret

0000000080000bd2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000bd2:	1141                	addi	sp,sp,-16
    80000bd4:	e422                	sd	s0,8(sp)
    80000bd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000bd8:	02c05363          	blez	a2,80000bfe <safestrcpy+0x2c>
    80000bdc:	fff6069b          	addiw	a3,a2,-1
    80000be0:	1682                	slli	a3,a3,0x20
    80000be2:	9281                	srli	a3,a3,0x20
    80000be4:	96ae                	add	a3,a3,a1
    80000be6:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000be8:	00d58963          	beq	a1,a3,80000bfa <safestrcpy+0x28>
    80000bec:	0585                	addi	a1,a1,1
    80000bee:	0785                	addi	a5,a5,1
    80000bf0:	fff5c703          	lbu	a4,-1(a1)
    80000bf4:	fee78fa3          	sb	a4,-1(a5)
    80000bf8:	fb65                	bnez	a4,80000be8 <safestrcpy+0x16>
    ;
  *s = 0;
    80000bfa:	00078023          	sb	zero,0(a5)
  return os;
}
    80000bfe:	6422                	ld	s0,8(sp)
    80000c00:	0141                	addi	sp,sp,16
    80000c02:	8082                	ret

0000000080000c04 <strlen>:

int
strlen(const char *s)
{
    80000c04:	1141                	addi	sp,sp,-16
    80000c06:	e422                	sd	s0,8(sp)
    80000c08:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000c0a:	00054783          	lbu	a5,0(a0)
    80000c0e:	cf91                	beqz	a5,80000c2a <strlen+0x26>
    80000c10:	0505                	addi	a0,a0,1
    80000c12:	87aa                	mv	a5,a0
    80000c14:	4685                	li	a3,1
    80000c16:	9e89                	subw	a3,a3,a0
    80000c18:	00f6853b          	addw	a0,a3,a5
    80000c1c:	0785                	addi	a5,a5,1
    80000c1e:	fff7c703          	lbu	a4,-1(a5)
    80000c22:	fb7d                	bnez	a4,80000c18 <strlen+0x14>
    ;
  return n;
}
    80000c24:	6422                	ld	s0,8(sp)
    80000c26:	0141                	addi	sp,sp,16
    80000c28:	8082                	ret
  for(n = 0; s[n]; n++)
    80000c2a:	4501                	li	a0,0
    80000c2c:	bfe5                	j	80000c24 <strlen+0x20>

0000000080000c2e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000c2e:	1141                	addi	sp,sp,-16
    80000c30:	e406                	sd	ra,8(sp)
    80000c32:	e022                	sd	s0,0(sp)
    80000c34:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000c36:	00001097          	auipc	ra,0x1
    80000c3a:	aba080e7          	jalr	-1350(ra) # 800016f0 <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000c3e:	00027717          	auipc	a4,0x27
    80000c42:	3ea70713          	addi	a4,a4,1002 # 80028028 <started>
  if(cpuid() == 0){
    80000c46:	c139                	beqz	a0,80000c8c <main+0x5e>
    while(started == 0)
    80000c48:	431c                	lw	a5,0(a4)
    80000c4a:	2781                	sext.w	a5,a5
    80000c4c:	dff5                	beqz	a5,80000c48 <main+0x1a>
      ;
    __sync_synchronize();
    80000c4e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000c52:	00001097          	auipc	ra,0x1
    80000c56:	a9e080e7          	jalr	-1378(ra) # 800016f0 <cpuid>
    80000c5a:	85aa                	mv	a1,a0
    80000c5c:	00006517          	auipc	a0,0x6
    80000c60:	53450513          	addi	a0,a0,1332 # 80007190 <userret+0x100>
    80000c64:	00000097          	auipc	ra,0x0
    80000c68:	92e080e7          	jalr	-1746(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	1ea080e7          	jalr	490(ra) # 80000e56 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000c74:	00001097          	auipc	ra,0x1
    80000c78:	704080e7          	jalr	1796(ra) # 80002378 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000c7c:	00005097          	auipc	ra,0x5
    80000c80:	f34080e7          	jalr	-204(ra) # 80005bb0 <plicinithart>
  }

  scheduler();        
    80000c84:	00001097          	auipc	ra,0x1
    80000c88:	fde080e7          	jalr	-34(ra) # 80001c62 <scheduler>
    consoleinit();
    80000c8c:	fffff097          	auipc	ra,0xfffff
    80000c90:	7ce080e7          	jalr	1998(ra) # 8000045a <consoleinit>
    printfinit();
    80000c94:	00000097          	auipc	ra,0x0
    80000c98:	ade080e7          	jalr	-1314(ra) # 80000772 <printfinit>
    printf("\n");
    80000c9c:	00006517          	auipc	a0,0x6
    80000ca0:	50450513          	addi	a0,a0,1284 # 800071a0 <userret+0x110>
    80000ca4:	00000097          	auipc	ra,0x0
    80000ca8:	8ee080e7          	jalr	-1810(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    80000cac:	00006517          	auipc	a0,0x6
    80000cb0:	4cc50513          	addi	a0,a0,1228 # 80007178 <userret+0xe8>
    80000cb4:	00000097          	auipc	ra,0x0
    80000cb8:	8de080e7          	jalr	-1826(ra) # 80000592 <printf>
    printf("\n");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	4e450513          	addi	a0,a0,1252 # 800071a0 <userret+0x110>
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	8ce080e7          	jalr	-1842(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    80000ccc:	00000097          	auipc	ra,0x0
    80000cd0:	b88080e7          	jalr	-1144(ra) # 80000854 <kinit>
    kvminit();       // create kernel page table
    80000cd4:	00000097          	auipc	ra,0x0
    80000cd8:	300080e7          	jalr	768(ra) # 80000fd4 <kvminit>
    kvminithart();   // turn on paging
    80000cdc:	00000097          	auipc	ra,0x0
    80000ce0:	17a080e7          	jalr	378(ra) # 80000e56 <kvminithart>
    procinit();      // process table
    80000ce4:	00001097          	auipc	ra,0x1
    80000ce8:	93c080e7          	jalr	-1732(ra) # 80001620 <procinit>
    trapinit();      // trap vectors
    80000cec:	00001097          	auipc	ra,0x1
    80000cf0:	664080e7          	jalr	1636(ra) # 80002350 <trapinit>
    trapinithart();  // install kernel trap vector
    80000cf4:	00001097          	auipc	ra,0x1
    80000cf8:	684080e7          	jalr	1668(ra) # 80002378 <trapinithart>
    plicinit();      // set up interrupt controller
    80000cfc:	00005097          	auipc	ra,0x5
    80000d00:	e9e080e7          	jalr	-354(ra) # 80005b9a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000d04:	00005097          	auipc	ra,0x5
    80000d08:	eac080e7          	jalr	-340(ra) # 80005bb0 <plicinithart>
    binit();         // buffer cache
    80000d0c:	00002097          	auipc	ra,0x2
    80000d10:	da8080e7          	jalr	-600(ra) # 80002ab4 <binit>
    iinit();         // inode cache
    80000d14:	00002097          	auipc	ra,0x2
    80000d18:	43c080e7          	jalr	1084(ra) # 80003150 <iinit>
    fileinit();      // file table
    80000d1c:	00003097          	auipc	ra,0x3
    80000d20:	618080e7          	jalr	1560(ra) # 80004334 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80000d24:	4501                	li	a0,0
    80000d26:	00005097          	auipc	ra,0x5
    80000d2a:	fbe080e7          	jalr	-66(ra) # 80005ce4 <virtio_disk_init>
    userinit();      // first user process
    80000d2e:	00001097          	auipc	ra,0x1
    80000d32:	c62080e7          	jalr	-926(ra) # 80001990 <userinit>
    __sync_synchronize();
    80000d36:	0ff0000f          	fence
    started = 1;
    80000d3a:	4785                	li	a5,1
    80000d3c:	00027717          	auipc	a4,0x27
    80000d40:	2ef72623          	sw	a5,748(a4) # 80028028 <started>
    80000d44:	b781                	j	80000c84 <main+0x56>

0000000080000d46 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000d46:	7139                	addi	sp,sp,-64
    80000d48:	fc06                	sd	ra,56(sp)
    80000d4a:	f822                	sd	s0,48(sp)
    80000d4c:	f426                	sd	s1,40(sp)
    80000d4e:	f04a                	sd	s2,32(sp)
    80000d50:	ec4e                	sd	s3,24(sp)
    80000d52:	e852                	sd	s4,16(sp)
    80000d54:	e456                	sd	s5,8(sp)
    80000d56:	e05a                	sd	s6,0(sp)
    80000d58:	0080                	addi	s0,sp,64
    80000d5a:	84aa                	mv	s1,a0
    80000d5c:	89ae                	mv	s3,a1
    80000d5e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000d60:	57fd                	li	a5,-1
    80000d62:	83e9                	srli	a5,a5,0x1a
    80000d64:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000d66:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000d68:	04b7f263          	bgeu	a5,a1,80000dac <walk+0x66>
    panic("walk");
    80000d6c:	00006517          	auipc	a0,0x6
    80000d70:	43c50513          	addi	a0,a0,1084 # 800071a8 <userret+0x118>
    80000d74:	fffff097          	auipc	ra,0xfffff
    80000d78:	7d4080e7          	jalr	2004(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000d7c:	060a8663          	beqz	s5,80000de8 <walk+0xa2>
    80000d80:	00000097          	auipc	ra,0x0
    80000d84:	b14080e7          	jalr	-1260(ra) # 80000894 <kalloc>
    80000d88:	84aa                	mv	s1,a0
    80000d8a:	c529                	beqz	a0,80000dd4 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000d8c:	6605                	lui	a2,0x1
    80000d8e:	4581                	li	a1,0
    80000d90:	00000097          	auipc	ra,0x0
    80000d94:	cf0080e7          	jalr	-784(ra) # 80000a80 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000d98:	00c4d793          	srli	a5,s1,0xc
    80000d9c:	07aa                	slli	a5,a5,0xa
    80000d9e:	0017e793          	ori	a5,a5,1
    80000da2:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000da6:	3a5d                	addiw	s4,s4,-9
    80000da8:	036a0063          	beq	s4,s6,80000dc8 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80000dac:	0149d933          	srl	s2,s3,s4
    80000db0:	1ff97913          	andi	s2,s2,511
    80000db4:	090e                	slli	s2,s2,0x3
    80000db6:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000db8:	00093483          	ld	s1,0(s2)
    80000dbc:	0014f793          	andi	a5,s1,1
    80000dc0:	dfd5                	beqz	a5,80000d7c <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000dc2:	80a9                	srli	s1,s1,0xa
    80000dc4:	04b2                	slli	s1,s1,0xc
    80000dc6:	b7c5                	j	80000da6 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80000dc8:	00c9d513          	srli	a0,s3,0xc
    80000dcc:	1ff57513          	andi	a0,a0,511
    80000dd0:	050e                	slli	a0,a0,0x3
    80000dd2:	9526                	add	a0,a0,s1
}
    80000dd4:	70e2                	ld	ra,56(sp)
    80000dd6:	7442                	ld	s0,48(sp)
    80000dd8:	74a2                	ld	s1,40(sp)
    80000dda:	7902                	ld	s2,32(sp)
    80000ddc:	69e2                	ld	s3,24(sp)
    80000dde:	6a42                	ld	s4,16(sp)
    80000de0:	6aa2                	ld	s5,8(sp)
    80000de2:	6b02                	ld	s6,0(sp)
    80000de4:	6121                	addi	sp,sp,64
    80000de6:	8082                	ret
        return 0;
    80000de8:	4501                	li	a0,0
    80000dea:	b7ed                	j	80000dd4 <walk+0x8e>

0000000080000dec <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    80000dec:	7179                	addi	sp,sp,-48
    80000dee:	f406                	sd	ra,40(sp)
    80000df0:	f022                	sd	s0,32(sp)
    80000df2:	ec26                	sd	s1,24(sp)
    80000df4:	e84a                	sd	s2,16(sp)
    80000df6:	e44e                	sd	s3,8(sp)
    80000df8:	e052                	sd	s4,0(sp)
    80000dfa:	1800                	addi	s0,sp,48
    80000dfc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000dfe:	84aa                	mv	s1,a0
    80000e00:	6905                	lui	s2,0x1
    80000e02:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000e04:	4985                	li	s3,1
    80000e06:	a821                	j	80000e1e <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000e08:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000e0a:	0532                	slli	a0,a0,0xc
    80000e0c:	00000097          	auipc	ra,0x0
    80000e10:	fe0080e7          	jalr	-32(ra) # 80000dec <freewalk>
      pagetable[i] = 0;
    80000e14:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000e18:	04a1                	addi	s1,s1,8
    80000e1a:	03248163          	beq	s1,s2,80000e3c <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000e1e:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000e20:	00f57793          	andi	a5,a0,15
    80000e24:	ff3782e3          	beq	a5,s3,80000e08 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000e28:	8905                	andi	a0,a0,1
    80000e2a:	d57d                	beqz	a0,80000e18 <freewalk+0x2c>
      panic("freewalk: leaf");
    80000e2c:	00006517          	auipc	a0,0x6
    80000e30:	38450513          	addi	a0,a0,900 # 800071b0 <userret+0x120>
    80000e34:	fffff097          	auipc	ra,0xfffff
    80000e38:	714080e7          	jalr	1812(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    80000e3c:	8552                	mv	a0,s4
    80000e3e:	00000097          	auipc	ra,0x0
    80000e42:	a3e080e7          	jalr	-1474(ra) # 8000087c <kfree>
}
    80000e46:	70a2                	ld	ra,40(sp)
    80000e48:	7402                	ld	s0,32(sp)
    80000e4a:	64e2                	ld	s1,24(sp)
    80000e4c:	6942                	ld	s2,16(sp)
    80000e4e:	69a2                	ld	s3,8(sp)
    80000e50:	6a02                	ld	s4,0(sp)
    80000e52:	6145                	addi	sp,sp,48
    80000e54:	8082                	ret

0000000080000e56 <kvminithart>:
{
    80000e56:	1141                	addi	sp,sp,-16
    80000e58:	e422                	sd	s0,8(sp)
    80000e5a:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000e5c:	00027797          	auipc	a5,0x27
    80000e60:	1d47b783          	ld	a5,468(a5) # 80028030 <kernel_pagetable>
    80000e64:	83b1                	srli	a5,a5,0xc
    80000e66:	577d                	li	a4,-1
    80000e68:	177e                	slli	a4,a4,0x3f
    80000e6a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000e6c:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000e70:	12000073          	sfence.vma
}
    80000e74:	6422                	ld	s0,8(sp)
    80000e76:	0141                	addi	sp,sp,16
    80000e78:	8082                	ret

0000000080000e7a <walkaddr>:
{
    80000e7a:	1141                	addi	sp,sp,-16
    80000e7c:	e406                	sd	ra,8(sp)
    80000e7e:	e022                	sd	s0,0(sp)
    80000e80:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000e82:	4601                	li	a2,0
    80000e84:	00000097          	auipc	ra,0x0
    80000e88:	ec2080e7          	jalr	-318(ra) # 80000d46 <walk>
  if(pte == 0)
    80000e8c:	c105                	beqz	a0,80000eac <walkaddr+0x32>
  if((*pte & PTE_V) == 0)
    80000e8e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000e90:	0117f693          	andi	a3,a5,17
    80000e94:	4745                	li	a4,17
    return 0;
    80000e96:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000e98:	00e68663          	beq	a3,a4,80000ea4 <walkaddr+0x2a>
}
    80000e9c:	60a2                	ld	ra,8(sp)
    80000e9e:	6402                	ld	s0,0(sp)
    80000ea0:	0141                	addi	sp,sp,16
    80000ea2:	8082                	ret
  pa = PTE2PA(*pte);
    80000ea4:	83a9                	srli	a5,a5,0xa
    80000ea6:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000eaa:	bfcd                	j	80000e9c <walkaddr+0x22>
    return 0;
    80000eac:	4501                	li	a0,0
    80000eae:	b7fd                	j	80000e9c <walkaddr+0x22>

0000000080000eb0 <kvmpa>:
{
    80000eb0:	1101                	addi	sp,sp,-32
    80000eb2:	ec06                	sd	ra,24(sp)
    80000eb4:	e822                	sd	s0,16(sp)
    80000eb6:	e426                	sd	s1,8(sp)
    80000eb8:	1000                	addi	s0,sp,32
    80000eba:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80000ebc:	1552                	slli	a0,a0,0x34
    80000ebe:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    80000ec2:	4601                	li	a2,0
    80000ec4:	00027517          	auipc	a0,0x27
    80000ec8:	16c53503          	ld	a0,364(a0) # 80028030 <kernel_pagetable>
    80000ecc:	00000097          	auipc	ra,0x0
    80000ed0:	e7a080e7          	jalr	-390(ra) # 80000d46 <walk>
  if(pte == 0)
    80000ed4:	cd09                	beqz	a0,80000eee <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    80000ed6:	6108                	ld	a0,0(a0)
    80000ed8:	00157793          	andi	a5,a0,1
    80000edc:	c38d                	beqz	a5,80000efe <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    80000ede:	8129                	srli	a0,a0,0xa
    80000ee0:	0532                	slli	a0,a0,0xc
}
    80000ee2:	9526                	add	a0,a0,s1
    80000ee4:	60e2                	ld	ra,24(sp)
    80000ee6:	6442                	ld	s0,16(sp)
    80000ee8:	64a2                	ld	s1,8(sp)
    80000eea:	6105                	addi	sp,sp,32
    80000eec:	8082                	ret
    panic("kvmpa");
    80000eee:	00006517          	auipc	a0,0x6
    80000ef2:	2d250513          	addi	a0,a0,722 # 800071c0 <userret+0x130>
    80000ef6:	fffff097          	auipc	ra,0xfffff
    80000efa:	652080e7          	jalr	1618(ra) # 80000548 <panic>
    panic("kvmpa");
    80000efe:	00006517          	auipc	a0,0x6
    80000f02:	2c250513          	addi	a0,a0,706 # 800071c0 <userret+0x130>
    80000f06:	fffff097          	auipc	ra,0xfffff
    80000f0a:	642080e7          	jalr	1602(ra) # 80000548 <panic>

0000000080000f0e <mappages>:
{
    80000f0e:	715d                	addi	sp,sp,-80
    80000f10:	e486                	sd	ra,72(sp)
    80000f12:	e0a2                	sd	s0,64(sp)
    80000f14:	fc26                	sd	s1,56(sp)
    80000f16:	f84a                	sd	s2,48(sp)
    80000f18:	f44e                	sd	s3,40(sp)
    80000f1a:	f052                	sd	s4,32(sp)
    80000f1c:	ec56                	sd	s5,24(sp)
    80000f1e:	e85a                	sd	s6,16(sp)
    80000f20:	e45e                	sd	s7,8(sp)
    80000f22:	0880                	addi	s0,sp,80
    80000f24:	8aaa                	mv	s5,a0
    80000f26:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    80000f28:	777d                	lui	a4,0xfffff
    80000f2a:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80000f2e:	167d                	addi	a2,a2,-1
    80000f30:	00b609b3          	add	s3,a2,a1
    80000f34:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80000f38:	893e                	mv	s2,a5
    80000f3a:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    80000f3e:	6b85                	lui	s7,0x1
    80000f40:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000f44:	4605                	li	a2,1
    80000f46:	85ca                	mv	a1,s2
    80000f48:	8556                	mv	a0,s5
    80000f4a:	00000097          	auipc	ra,0x0
    80000f4e:	dfc080e7          	jalr	-516(ra) # 80000d46 <walk>
    80000f52:	c51d                	beqz	a0,80000f80 <mappages+0x72>
    if(*pte & PTE_V)
    80000f54:	611c                	ld	a5,0(a0)
    80000f56:	8b85                	andi	a5,a5,1
    80000f58:	ef81                	bnez	a5,80000f70 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000f5a:	80b1                	srli	s1,s1,0xc
    80000f5c:	04aa                	slli	s1,s1,0xa
    80000f5e:	0164e4b3          	or	s1,s1,s6
    80000f62:	0014e493          	ori	s1,s1,1
    80000f66:	e104                	sd	s1,0(a0)
    if(a == last)
    80000f68:	03390863          	beq	s2,s3,80000f98 <mappages+0x8a>
    a += PGSIZE;
    80000f6c:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80000f6e:	bfc9                	j	80000f40 <mappages+0x32>
      panic("remap");
    80000f70:	00006517          	auipc	a0,0x6
    80000f74:	25850513          	addi	a0,a0,600 # 800071c8 <userret+0x138>
    80000f78:	fffff097          	auipc	ra,0xfffff
    80000f7c:	5d0080e7          	jalr	1488(ra) # 80000548 <panic>
      return -1;
    80000f80:	557d                	li	a0,-1
}
    80000f82:	60a6                	ld	ra,72(sp)
    80000f84:	6406                	ld	s0,64(sp)
    80000f86:	74e2                	ld	s1,56(sp)
    80000f88:	7942                	ld	s2,48(sp)
    80000f8a:	79a2                	ld	s3,40(sp)
    80000f8c:	7a02                	ld	s4,32(sp)
    80000f8e:	6ae2                	ld	s5,24(sp)
    80000f90:	6b42                	ld	s6,16(sp)
    80000f92:	6ba2                	ld	s7,8(sp)
    80000f94:	6161                	addi	sp,sp,80
    80000f96:	8082                	ret
  return 0;
    80000f98:	4501                	li	a0,0
    80000f9a:	b7e5                	j	80000f82 <mappages+0x74>

0000000080000f9c <kvmmap>:
{
    80000f9c:	1141                	addi	sp,sp,-16
    80000f9e:	e406                	sd	ra,8(sp)
    80000fa0:	e022                	sd	s0,0(sp)
    80000fa2:	0800                	addi	s0,sp,16
    80000fa4:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80000fa6:	86ae                	mv	a3,a1
    80000fa8:	85aa                	mv	a1,a0
    80000faa:	00027517          	auipc	a0,0x27
    80000fae:	08653503          	ld	a0,134(a0) # 80028030 <kernel_pagetable>
    80000fb2:	00000097          	auipc	ra,0x0
    80000fb6:	f5c080e7          	jalr	-164(ra) # 80000f0e <mappages>
    80000fba:	e509                	bnez	a0,80000fc4 <kvmmap+0x28>
}
    80000fbc:	60a2                	ld	ra,8(sp)
    80000fbe:	6402                	ld	s0,0(sp)
    80000fc0:	0141                	addi	sp,sp,16
    80000fc2:	8082                	ret
    panic("kvmmap");
    80000fc4:	00006517          	auipc	a0,0x6
    80000fc8:	20c50513          	addi	a0,a0,524 # 800071d0 <userret+0x140>
    80000fcc:	fffff097          	auipc	ra,0xfffff
    80000fd0:	57c080e7          	jalr	1404(ra) # 80000548 <panic>

0000000080000fd4 <kvminit>:
{
    80000fd4:	1101                	addi	sp,sp,-32
    80000fd6:	ec06                	sd	ra,24(sp)
    80000fd8:	e822                	sd	s0,16(sp)
    80000fda:	e426                	sd	s1,8(sp)
    80000fdc:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80000fde:	00000097          	auipc	ra,0x0
    80000fe2:	8b6080e7          	jalr	-1866(ra) # 80000894 <kalloc>
    80000fe6:	00027797          	auipc	a5,0x27
    80000fea:	04a7b523          	sd	a0,74(a5) # 80028030 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80000fee:	6605                	lui	a2,0x1
    80000ff0:	4581                	li	a1,0
    80000ff2:	00000097          	auipc	ra,0x0
    80000ff6:	a8e080e7          	jalr	-1394(ra) # 80000a80 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000ffa:	4699                	li	a3,6
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	100005b7          	lui	a1,0x10000
    80001002:	10000537          	lui	a0,0x10000
    80001006:	00000097          	auipc	ra,0x0
    8000100a:	f96080e7          	jalr	-106(ra) # 80000f9c <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    8000100e:	4699                	li	a3,6
    80001010:	6605                	lui	a2,0x1
    80001012:	100015b7          	lui	a1,0x10001
    80001016:	10001537          	lui	a0,0x10001
    8000101a:	00000097          	auipc	ra,0x0
    8000101e:	f82080e7          	jalr	-126(ra) # 80000f9c <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    80001022:	4699                	li	a3,6
    80001024:	6605                	lui	a2,0x1
    80001026:	100025b7          	lui	a1,0x10002
    8000102a:	10002537          	lui	a0,0x10002
    8000102e:	00000097          	auipc	ra,0x0
    80001032:	f6e080e7          	jalr	-146(ra) # 80000f9c <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001036:	4699                	li	a3,6
    80001038:	6641                	lui	a2,0x10
    8000103a:	020005b7          	lui	a1,0x2000
    8000103e:	02000537          	lui	a0,0x2000
    80001042:	00000097          	auipc	ra,0x0
    80001046:	f5a080e7          	jalr	-166(ra) # 80000f9c <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000104a:	4699                	li	a3,6
    8000104c:	00400637          	lui	a2,0x400
    80001050:	0c0005b7          	lui	a1,0xc000
    80001054:	0c000537          	lui	a0,0xc000
    80001058:	00000097          	auipc	ra,0x0
    8000105c:	f44080e7          	jalr	-188(ra) # 80000f9c <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001060:	00007497          	auipc	s1,0x7
    80001064:	fa048493          	addi	s1,s1,-96 # 80008000 <initcode>
    80001068:	46a9                	li	a3,10
    8000106a:	80007617          	auipc	a2,0x80007
    8000106e:	f9660613          	addi	a2,a2,-106 # 8000 <_entry-0x7fff8000>
    80001072:	4585                	li	a1,1
    80001074:	05fe                	slli	a1,a1,0x1f
    80001076:	852e                	mv	a0,a1
    80001078:	00000097          	auipc	ra,0x0
    8000107c:	f24080e7          	jalr	-220(ra) # 80000f9c <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001080:	4699                	li	a3,6
    80001082:	4645                	li	a2,17
    80001084:	066e                	slli	a2,a2,0x1b
    80001086:	8e05                	sub	a2,a2,s1
    80001088:	85a6                	mv	a1,s1
    8000108a:	8526                	mv	a0,s1
    8000108c:	00000097          	auipc	ra,0x0
    80001090:	f10080e7          	jalr	-240(ra) # 80000f9c <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001094:	46a9                	li	a3,10
    80001096:	6605                	lui	a2,0x1
    80001098:	00006597          	auipc	a1,0x6
    8000109c:	f6858593          	addi	a1,a1,-152 # 80007000 <trampoline>
    800010a0:	04000537          	lui	a0,0x4000
    800010a4:	157d                	addi	a0,a0,-1
    800010a6:	0532                	slli	a0,a0,0xc
    800010a8:	00000097          	auipc	ra,0x0
    800010ac:	ef4080e7          	jalr	-268(ra) # 80000f9c <kvmmap>
}
    800010b0:	60e2                	ld	ra,24(sp)
    800010b2:	6442                	ld	s0,16(sp)
    800010b4:	64a2                	ld	s1,8(sp)
    800010b6:	6105                	addi	sp,sp,32
    800010b8:	8082                	ret

00000000800010ba <uvmunmap>:
{
    800010ba:	715d                	addi	sp,sp,-80
    800010bc:	e486                	sd	ra,72(sp)
    800010be:	e0a2                	sd	s0,64(sp)
    800010c0:	fc26                	sd	s1,56(sp)
    800010c2:	f84a                	sd	s2,48(sp)
    800010c4:	f44e                	sd	s3,40(sp)
    800010c6:	f052                	sd	s4,32(sp)
    800010c8:	ec56                	sd	s5,24(sp)
    800010ca:	e85a                	sd	s6,16(sp)
    800010cc:	e45e                	sd	s7,8(sp)
    800010ce:	0880                	addi	s0,sp,80
    800010d0:	8a2a                	mv	s4,a0
    800010d2:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    800010d4:	77fd                	lui	a5,0xfffff
    800010d6:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010da:	167d                	addi	a2,a2,-1
    800010dc:	00b609b3          	add	s3,a2,a1
    800010e0:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    800010e4:	4b05                	li	s6,1
    a += PGSIZE;
    800010e6:	6b85                	lui	s7,0x1
    800010e8:	a0b9                	j	80001136 <uvmunmap+0x7c>
      panic("uvmunmap: walk");
    800010ea:	00006517          	auipc	a0,0x6
    800010ee:	0ee50513          	addi	a0,a0,238 # 800071d8 <userret+0x148>
    800010f2:	fffff097          	auipc	ra,0xfffff
    800010f6:	456080e7          	jalr	1110(ra) # 80000548 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800010fa:	85ca                	mv	a1,s2
    800010fc:	00006517          	auipc	a0,0x6
    80001100:	0ec50513          	addi	a0,a0,236 # 800071e8 <userret+0x158>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	48e080e7          	jalr	1166(ra) # 80000592 <printf>
      panic("uvmunmap: not mapped");
    8000110c:	00006517          	auipc	a0,0x6
    80001110:	0ec50513          	addi	a0,a0,236 # 800071f8 <userret+0x168>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	434080e7          	jalr	1076(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    8000111c:	00006517          	auipc	a0,0x6
    80001120:	0f450513          	addi	a0,a0,244 # 80007210 <userret+0x180>
    80001124:	fffff097          	auipc	ra,0xfffff
    80001128:	424080e7          	jalr	1060(ra) # 80000548 <panic>
    *pte = 0;
    8000112c:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001130:	03390e63          	beq	s2,s3,8000116c <uvmunmap+0xb2>
    a += PGSIZE;
    80001134:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    80001136:	4601                	li	a2,0
    80001138:	85ca                	mv	a1,s2
    8000113a:	8552                	mv	a0,s4
    8000113c:	00000097          	auipc	ra,0x0
    80001140:	c0a080e7          	jalr	-1014(ra) # 80000d46 <walk>
    80001144:	84aa                	mv	s1,a0
    80001146:	d155                	beqz	a0,800010ea <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    80001148:	6110                	ld	a2,0(a0)
    8000114a:	00167793          	andi	a5,a2,1
    8000114e:	d7d5                	beqz	a5,800010fa <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001150:	3ff67793          	andi	a5,a2,1023
    80001154:	fd6784e3          	beq	a5,s6,8000111c <uvmunmap+0x62>
    if(do_free){
    80001158:	fc0a8ae3          	beqz	s5,8000112c <uvmunmap+0x72>
      pa = PTE2PA(*pte);
    8000115c:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    8000115e:	00c61513          	slli	a0,a2,0xc
    80001162:	fffff097          	auipc	ra,0xfffff
    80001166:	71a080e7          	jalr	1818(ra) # 8000087c <kfree>
    8000116a:	b7c9                	j	8000112c <uvmunmap+0x72>
}
    8000116c:	60a6                	ld	ra,72(sp)
    8000116e:	6406                	ld	s0,64(sp)
    80001170:	74e2                	ld	s1,56(sp)
    80001172:	7942                	ld	s2,48(sp)
    80001174:	79a2                	ld	s3,40(sp)
    80001176:	7a02                	ld	s4,32(sp)
    80001178:	6ae2                	ld	s5,24(sp)
    8000117a:	6b42                	ld	s6,16(sp)
    8000117c:	6ba2                	ld	s7,8(sp)
    8000117e:	6161                	addi	sp,sp,80
    80001180:	8082                	ret

0000000080001182 <uvmcreate>:
{
    80001182:	1101                	addi	sp,sp,-32
    80001184:	ec06                	sd	ra,24(sp)
    80001186:	e822                	sd	s0,16(sp)
    80001188:	e426                	sd	s1,8(sp)
    8000118a:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    8000118c:	fffff097          	auipc	ra,0xfffff
    80001190:	708080e7          	jalr	1800(ra) # 80000894 <kalloc>
  if(pagetable == 0)
    80001194:	cd11                	beqz	a0,800011b0 <uvmcreate+0x2e>
    80001196:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    80001198:	6605                	lui	a2,0x1
    8000119a:	4581                	li	a1,0
    8000119c:	00000097          	auipc	ra,0x0
    800011a0:	8e4080e7          	jalr	-1820(ra) # 80000a80 <memset>
}
    800011a4:	8526                	mv	a0,s1
    800011a6:	60e2                	ld	ra,24(sp)
    800011a8:	6442                	ld	s0,16(sp)
    800011aa:	64a2                	ld	s1,8(sp)
    800011ac:	6105                	addi	sp,sp,32
    800011ae:	8082                	ret
    panic("uvmcreate: out of memory");
    800011b0:	00006517          	auipc	a0,0x6
    800011b4:	07850513          	addi	a0,a0,120 # 80007228 <userret+0x198>
    800011b8:	fffff097          	auipc	ra,0xfffff
    800011bc:	390080e7          	jalr	912(ra) # 80000548 <panic>

00000000800011c0 <uvminit>:
{
    800011c0:	7179                	addi	sp,sp,-48
    800011c2:	f406                	sd	ra,40(sp)
    800011c4:	f022                	sd	s0,32(sp)
    800011c6:	ec26                	sd	s1,24(sp)
    800011c8:	e84a                	sd	s2,16(sp)
    800011ca:	e44e                	sd	s3,8(sp)
    800011cc:	e052                	sd	s4,0(sp)
    800011ce:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    800011d0:	6785                	lui	a5,0x1
    800011d2:	04f67863          	bgeu	a2,a5,80001222 <uvminit+0x62>
    800011d6:	8a2a                	mv	s4,a0
    800011d8:	89ae                	mv	s3,a1
    800011da:	84b2                	mv	s1,a2
  mem = kalloc();
    800011dc:	fffff097          	auipc	ra,0xfffff
    800011e0:	6b8080e7          	jalr	1720(ra) # 80000894 <kalloc>
    800011e4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800011e6:	6605                	lui	a2,0x1
    800011e8:	4581                	li	a1,0
    800011ea:	00000097          	auipc	ra,0x0
    800011ee:	896080e7          	jalr	-1898(ra) # 80000a80 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800011f2:	4779                	li	a4,30
    800011f4:	86ca                	mv	a3,s2
    800011f6:	6605                	lui	a2,0x1
    800011f8:	4581                	li	a1,0
    800011fa:	8552                	mv	a0,s4
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	d12080e7          	jalr	-750(ra) # 80000f0e <mappages>
  memmove(mem, src, sz);
    80001204:	8626                	mv	a2,s1
    80001206:	85ce                	mv	a1,s3
    80001208:	854a                	mv	a0,s2
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	8d2080e7          	jalr	-1838(ra) # 80000adc <memmove>
}
    80001212:	70a2                	ld	ra,40(sp)
    80001214:	7402                	ld	s0,32(sp)
    80001216:	64e2                	ld	s1,24(sp)
    80001218:	6942                	ld	s2,16(sp)
    8000121a:	69a2                	ld	s3,8(sp)
    8000121c:	6a02                	ld	s4,0(sp)
    8000121e:	6145                	addi	sp,sp,48
    80001220:	8082                	ret
    panic("inituvm: more than a page");
    80001222:	00006517          	auipc	a0,0x6
    80001226:	02650513          	addi	a0,a0,38 # 80007248 <userret+0x1b8>
    8000122a:	fffff097          	auipc	ra,0xfffff
    8000122e:	31e080e7          	jalr	798(ra) # 80000548 <panic>

0000000080001232 <uvmdealloc>:
{
    80001232:	87aa                	mv	a5,a0
    80001234:	852e                	mv	a0,a1
  if(newsz >= oldsz)
    80001236:	00b66363          	bltu	a2,a1,8000123c <uvmdealloc+0xa>
}
    8000123a:	8082                	ret
{
    8000123c:	1101                	addi	sp,sp,-32
    8000123e:	ec06                	sd	ra,24(sp)
    80001240:	e822                	sd	s0,16(sp)
    80001242:	e426                	sd	s1,8(sp)
    80001244:	1000                	addi	s0,sp,32
    80001246:	84b2                	mv	s1,a2
  uvmunmap(pagetable, newsz, oldsz - newsz, 1);
    80001248:	4685                	li	a3,1
    8000124a:	40c58633          	sub	a2,a1,a2
    8000124e:	85a6                	mv	a1,s1
    80001250:	853e                	mv	a0,a5
    80001252:	00000097          	auipc	ra,0x0
    80001256:	e68080e7          	jalr	-408(ra) # 800010ba <uvmunmap>
  return newsz;
    8000125a:	8526                	mv	a0,s1
}
    8000125c:	60e2                	ld	ra,24(sp)
    8000125e:	6442                	ld	s0,16(sp)
    80001260:	64a2                	ld	s1,8(sp)
    80001262:	6105                	addi	sp,sp,32
    80001264:	8082                	ret

0000000080001266 <uvmalloc>:
  if(newsz < oldsz)
    80001266:	0ab66163          	bltu	a2,a1,80001308 <uvmalloc+0xa2>
{
    8000126a:	7139                	addi	sp,sp,-64
    8000126c:	fc06                	sd	ra,56(sp)
    8000126e:	f822                	sd	s0,48(sp)
    80001270:	f426                	sd	s1,40(sp)
    80001272:	f04a                	sd	s2,32(sp)
    80001274:	ec4e                	sd	s3,24(sp)
    80001276:	e852                	sd	s4,16(sp)
    80001278:	e456                	sd	s5,8(sp)
    8000127a:	0080                	addi	s0,sp,64
    8000127c:	8aaa                	mv	s5,a0
    8000127e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001280:	6985                	lui	s3,0x1
    80001282:	19fd                	addi	s3,s3,-1
    80001284:	95ce                	add	a1,a1,s3
    80001286:	79fd                	lui	s3,0xfffff
    80001288:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    8000128c:	08c9f063          	bgeu	s3,a2,8000130c <uvmalloc+0xa6>
  a = oldsz;
    80001290:	894e                	mv	s2,s3
    mem = kalloc();
    80001292:	fffff097          	auipc	ra,0xfffff
    80001296:	602080e7          	jalr	1538(ra) # 80000894 <kalloc>
    8000129a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000129c:	c51d                	beqz	a0,800012ca <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000129e:	6605                	lui	a2,0x1
    800012a0:	4581                	li	a1,0
    800012a2:	fffff097          	auipc	ra,0xfffff
    800012a6:	7de080e7          	jalr	2014(ra) # 80000a80 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800012aa:	4779                	li	a4,30
    800012ac:	86a6                	mv	a3,s1
    800012ae:	6605                	lui	a2,0x1
    800012b0:	85ca                	mv	a1,s2
    800012b2:	8556                	mv	a0,s5
    800012b4:	00000097          	auipc	ra,0x0
    800012b8:	c5a080e7          	jalr	-934(ra) # 80000f0e <mappages>
    800012bc:	e905                	bnez	a0,800012ec <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    800012be:	6785                	lui	a5,0x1
    800012c0:	993e                	add	s2,s2,a5
    800012c2:	fd4968e3          	bltu	s2,s4,80001292 <uvmalloc+0x2c>
  return newsz;
    800012c6:	8552                	mv	a0,s4
    800012c8:	a809                	j	800012da <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800012ca:	864e                	mv	a2,s3
    800012cc:	85ca                	mv	a1,s2
    800012ce:	8556                	mv	a0,s5
    800012d0:	00000097          	auipc	ra,0x0
    800012d4:	f62080e7          	jalr	-158(ra) # 80001232 <uvmdealloc>
      return 0;
    800012d8:	4501                	li	a0,0
}
    800012da:	70e2                	ld	ra,56(sp)
    800012dc:	7442                	ld	s0,48(sp)
    800012de:	74a2                	ld	s1,40(sp)
    800012e0:	7902                	ld	s2,32(sp)
    800012e2:	69e2                	ld	s3,24(sp)
    800012e4:	6a42                	ld	s4,16(sp)
    800012e6:	6aa2                	ld	s5,8(sp)
    800012e8:	6121                	addi	sp,sp,64
    800012ea:	8082                	ret
      kfree(mem);
    800012ec:	8526                	mv	a0,s1
    800012ee:	fffff097          	auipc	ra,0xfffff
    800012f2:	58e080e7          	jalr	1422(ra) # 8000087c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800012f6:	864e                	mv	a2,s3
    800012f8:	85ca                	mv	a1,s2
    800012fa:	8556                	mv	a0,s5
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	f36080e7          	jalr	-202(ra) # 80001232 <uvmdealloc>
      return 0;
    80001304:	4501                	li	a0,0
    80001306:	bfd1                	j	800012da <uvmalloc+0x74>
    return oldsz;
    80001308:	852e                	mv	a0,a1
}
    8000130a:	8082                	ret
  return newsz;
    8000130c:	8532                	mv	a0,a2
    8000130e:	b7f1                	j	800012da <uvmalloc+0x74>

0000000080001310 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001310:	1101                	addi	sp,sp,-32
    80001312:	ec06                	sd	ra,24(sp)
    80001314:	e822                	sd	s0,16(sp)
    80001316:	e426                	sd	s1,8(sp)
    80001318:	1000                	addi	s0,sp,32
    8000131a:	84aa                	mv	s1,a0
    8000131c:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    8000131e:	4685                	li	a3,1
    80001320:	4581                	li	a1,0
    80001322:	00000097          	auipc	ra,0x0
    80001326:	d98080e7          	jalr	-616(ra) # 800010ba <uvmunmap>
  freewalk(pagetable);
    8000132a:	8526                	mv	a0,s1
    8000132c:	00000097          	auipc	ra,0x0
    80001330:	ac0080e7          	jalr	-1344(ra) # 80000dec <freewalk>
}
    80001334:	60e2                	ld	ra,24(sp)
    80001336:	6442                	ld	s0,16(sp)
    80001338:	64a2                	ld	s1,8(sp)
    8000133a:	6105                	addi	sp,sp,32
    8000133c:	8082                	ret

000000008000133e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000133e:	c671                	beqz	a2,8000140a <uvmcopy+0xcc>
{
    80001340:	715d                	addi	sp,sp,-80
    80001342:	e486                	sd	ra,72(sp)
    80001344:	e0a2                	sd	s0,64(sp)
    80001346:	fc26                	sd	s1,56(sp)
    80001348:	f84a                	sd	s2,48(sp)
    8000134a:	f44e                	sd	s3,40(sp)
    8000134c:	f052                	sd	s4,32(sp)
    8000134e:	ec56                	sd	s5,24(sp)
    80001350:	e85a                	sd	s6,16(sp)
    80001352:	e45e                	sd	s7,8(sp)
    80001354:	0880                	addi	s0,sp,80
    80001356:	8b2a                	mv	s6,a0
    80001358:	8aae                	mv	s5,a1
    8000135a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000135c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000135e:	4601                	li	a2,0
    80001360:	85ce                	mv	a1,s3
    80001362:	855a                	mv	a0,s6
    80001364:	00000097          	auipc	ra,0x0
    80001368:	9e2080e7          	jalr	-1566(ra) # 80000d46 <walk>
    8000136c:	c531                	beqz	a0,800013b8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000136e:	6118                	ld	a4,0(a0)
    80001370:	00177793          	andi	a5,a4,1
    80001374:	cbb1                	beqz	a5,800013c8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001376:	00a75593          	srli	a1,a4,0xa
    8000137a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000137e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001382:	fffff097          	auipc	ra,0xfffff
    80001386:	512080e7          	jalr	1298(ra) # 80000894 <kalloc>
    8000138a:	892a                	mv	s2,a0
    8000138c:	c939                	beqz	a0,800013e2 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000138e:	6605                	lui	a2,0x1
    80001390:	85de                	mv	a1,s7
    80001392:	fffff097          	auipc	ra,0xfffff
    80001396:	74a080e7          	jalr	1866(ra) # 80000adc <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000139a:	8726                	mv	a4,s1
    8000139c:	86ca                	mv	a3,s2
    8000139e:	6605                	lui	a2,0x1
    800013a0:	85ce                	mv	a1,s3
    800013a2:	8556                	mv	a0,s5
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	b6a080e7          	jalr	-1174(ra) # 80000f0e <mappages>
    800013ac:	e515                	bnez	a0,800013d8 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800013ae:	6785                	lui	a5,0x1
    800013b0:	99be                	add	s3,s3,a5
    800013b2:	fb49e6e3          	bltu	s3,s4,8000135e <uvmcopy+0x20>
    800013b6:	a83d                	j	800013f4 <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    800013b8:	00006517          	auipc	a0,0x6
    800013bc:	eb050513          	addi	a0,a0,-336 # 80007268 <userret+0x1d8>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	188080e7          	jalr	392(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    800013c8:	00006517          	auipc	a0,0x6
    800013cc:	ec050513          	addi	a0,a0,-320 # 80007288 <userret+0x1f8>
    800013d0:	fffff097          	auipc	ra,0xfffff
    800013d4:	178080e7          	jalr	376(ra) # 80000548 <panic>
      kfree(mem);
    800013d8:	854a                	mv	a0,s2
    800013da:	fffff097          	auipc	ra,0xfffff
    800013de:	4a2080e7          	jalr	1186(ra) # 8000087c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800013e2:	4685                	li	a3,1
    800013e4:	864e                	mv	a2,s3
    800013e6:	4581                	li	a1,0
    800013e8:	8556                	mv	a0,s5
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	cd0080e7          	jalr	-816(ra) # 800010ba <uvmunmap>
  return -1;
    800013f2:	557d                	li	a0,-1
}
    800013f4:	60a6                	ld	ra,72(sp)
    800013f6:	6406                	ld	s0,64(sp)
    800013f8:	74e2                	ld	s1,56(sp)
    800013fa:	7942                	ld	s2,48(sp)
    800013fc:	79a2                	ld	s3,40(sp)
    800013fe:	7a02                	ld	s4,32(sp)
    80001400:	6ae2                	ld	s5,24(sp)
    80001402:	6b42                	ld	s6,16(sp)
    80001404:	6ba2                	ld	s7,8(sp)
    80001406:	6161                	addi	sp,sp,80
    80001408:	8082                	ret
  return 0;
    8000140a:	4501                	li	a0,0
}
    8000140c:	8082                	ret

000000008000140e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000140e:	1141                	addi	sp,sp,-16
    80001410:	e406                	sd	ra,8(sp)
    80001412:	e022                	sd	s0,0(sp)
    80001414:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001416:	4601                	li	a2,0
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	92e080e7          	jalr	-1746(ra) # 80000d46 <walk>
  if(pte == 0)
    80001420:	c901                	beqz	a0,80001430 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001422:	611c                	ld	a5,0(a0)
    80001424:	9bbd                	andi	a5,a5,-17
    80001426:	e11c                	sd	a5,0(a0)
}
    80001428:	60a2                	ld	ra,8(sp)
    8000142a:	6402                	ld	s0,0(sp)
    8000142c:	0141                	addi	sp,sp,16
    8000142e:	8082                	ret
    panic("uvmclear");
    80001430:	00006517          	auipc	a0,0x6
    80001434:	e7850513          	addi	a0,a0,-392 # 800072a8 <userret+0x218>
    80001438:	fffff097          	auipc	ra,0xfffff
    8000143c:	110080e7          	jalr	272(ra) # 80000548 <panic>

0000000080001440 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001440:	cab5                	beqz	a3,800014b4 <copyout+0x74>
{
    80001442:	715d                	addi	sp,sp,-80
    80001444:	e486                	sd	ra,72(sp)
    80001446:	e0a2                	sd	s0,64(sp)
    80001448:	fc26                	sd	s1,56(sp)
    8000144a:	f84a                	sd	s2,48(sp)
    8000144c:	f44e                	sd	s3,40(sp)
    8000144e:	f052                	sd	s4,32(sp)
    80001450:	ec56                	sd	s5,24(sp)
    80001452:	e85a                	sd	s6,16(sp)
    80001454:	e45e                	sd	s7,8(sp)
    80001456:	e062                	sd	s8,0(sp)
    80001458:	0880                	addi	s0,sp,80
    8000145a:	8baa                	mv	s7,a0
    8000145c:	8c2e                	mv	s8,a1
    8000145e:	8a32                	mv	s4,a2
    80001460:	89b6                	mv	s3,a3
    va0 = (uint)PGROUNDDOWN(dstva);
    80001462:	00100b37          	lui	s6,0x100
    80001466:	1b7d                	addi	s6,s6,-1
    80001468:	0b32                	slli	s6,s6,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000146a:	6a85                	lui	s5,0x1
    8000146c:	a015                	j	80001490 <copyout+0x50>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000146e:	9562                	add	a0,a0,s8
    80001470:	0004861b          	sext.w	a2,s1
    80001474:	85d2                	mv	a1,s4
    80001476:	41250533          	sub	a0,a0,s2
    8000147a:	fffff097          	auipc	ra,0xfffff
    8000147e:	662080e7          	jalr	1634(ra) # 80000adc <memmove>

    len -= n;
    80001482:	409989b3          	sub	s3,s3,s1
    src += n;
    80001486:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001488:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000148c:	02098263          	beqz	s3,800014b0 <copyout+0x70>
    va0 = (uint)PGROUNDDOWN(dstva);
    80001490:	016c7933          	and	s2,s8,s6
    pa0 = walkaddr(pagetable, va0);
    80001494:	85ca                	mv	a1,s2
    80001496:	855e                	mv	a0,s7
    80001498:	00000097          	auipc	ra,0x0
    8000149c:	9e2080e7          	jalr	-1566(ra) # 80000e7a <walkaddr>
    if(pa0 == 0)
    800014a0:	cd01                	beqz	a0,800014b8 <copyout+0x78>
    n = PGSIZE - (dstva - va0);
    800014a2:	418904b3          	sub	s1,s2,s8
    800014a6:	94d6                	add	s1,s1,s5
    if(n > len)
    800014a8:	fc99f3e3          	bgeu	s3,s1,8000146e <copyout+0x2e>
    800014ac:	84ce                	mv	s1,s3
    800014ae:	b7c1                	j	8000146e <copyout+0x2e>
  }
  return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	a021                	j	800014ba <copyout+0x7a>
    800014b4:	4501                	li	a0,0
}
    800014b6:	8082                	ret
      return -1;
    800014b8:	557d                	li	a0,-1
}
    800014ba:	60a6                	ld	ra,72(sp)
    800014bc:	6406                	ld	s0,64(sp)
    800014be:	74e2                	ld	s1,56(sp)
    800014c0:	7942                	ld	s2,48(sp)
    800014c2:	79a2                	ld	s3,40(sp)
    800014c4:	7a02                	ld	s4,32(sp)
    800014c6:	6ae2                	ld	s5,24(sp)
    800014c8:	6b42                	ld	s6,16(sp)
    800014ca:	6ba2                	ld	s7,8(sp)
    800014cc:	6c02                	ld	s8,0(sp)
    800014ce:	6161                	addi	sp,sp,80
    800014d0:	8082                	ret

00000000800014d2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800014d2:	cabd                	beqz	a3,80001548 <copyin+0x76>
{
    800014d4:	715d                	addi	sp,sp,-80
    800014d6:	e486                	sd	ra,72(sp)
    800014d8:	e0a2                	sd	s0,64(sp)
    800014da:	fc26                	sd	s1,56(sp)
    800014dc:	f84a                	sd	s2,48(sp)
    800014de:	f44e                	sd	s3,40(sp)
    800014e0:	f052                	sd	s4,32(sp)
    800014e2:	ec56                	sd	s5,24(sp)
    800014e4:	e85a                	sd	s6,16(sp)
    800014e6:	e45e                	sd	s7,8(sp)
    800014e8:	e062                	sd	s8,0(sp)
    800014ea:	0880                	addi	s0,sp,80
    800014ec:	8baa                	mv	s7,a0
    800014ee:	8a2e                	mv	s4,a1
    800014f0:	8c32                	mv	s8,a2
    800014f2:	89b6                	mv	s3,a3
    va0 = (uint)PGROUNDDOWN(srcva);
    800014f4:	00100b37          	lui	s6,0x100
    800014f8:	1b7d                	addi	s6,s6,-1
    800014fa:	0b32                	slli	s6,s6,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014fc:	6a85                	lui	s5,0x1
    800014fe:	a01d                	j	80001524 <copyin+0x52>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001500:	018505b3          	add	a1,a0,s8
    80001504:	0004861b          	sext.w	a2,s1
    80001508:	412585b3          	sub	a1,a1,s2
    8000150c:	8552                	mv	a0,s4
    8000150e:	fffff097          	auipc	ra,0xfffff
    80001512:	5ce080e7          	jalr	1486(ra) # 80000adc <memmove>

    len -= n;
    80001516:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000151a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000151c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001520:	02098263          	beqz	s3,80001544 <copyin+0x72>
    va0 = (uint)PGROUNDDOWN(srcva);
    80001524:	016c7933          	and	s2,s8,s6
    pa0 = walkaddr(pagetable, va0);
    80001528:	85ca                	mv	a1,s2
    8000152a:	855e                	mv	a0,s7
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	94e080e7          	jalr	-1714(ra) # 80000e7a <walkaddr>
    if(pa0 == 0)
    80001534:	cd01                	beqz	a0,8000154c <copyin+0x7a>
    n = PGSIZE - (srcva - va0);
    80001536:	418904b3          	sub	s1,s2,s8
    8000153a:	94d6                	add	s1,s1,s5
    if(n > len)
    8000153c:	fc99f2e3          	bgeu	s3,s1,80001500 <copyin+0x2e>
    80001540:	84ce                	mv	s1,s3
    80001542:	bf7d                	j	80001500 <copyin+0x2e>
  }
  return 0;
    80001544:	4501                	li	a0,0
    80001546:	a021                	j	8000154e <copyin+0x7c>
    80001548:	4501                	li	a0,0
}
    8000154a:	8082                	ret
      return -1;
    8000154c:	557d                	li	a0,-1
}
    8000154e:	60a6                	ld	ra,72(sp)
    80001550:	6406                	ld	s0,64(sp)
    80001552:	74e2                	ld	s1,56(sp)
    80001554:	7942                	ld	s2,48(sp)
    80001556:	79a2                	ld	s3,40(sp)
    80001558:	7a02                	ld	s4,32(sp)
    8000155a:	6ae2                	ld	s5,24(sp)
    8000155c:	6b42                	ld	s6,16(sp)
    8000155e:	6ba2                	ld	s7,8(sp)
    80001560:	6c02                	ld	s8,0(sp)
    80001562:	6161                	addi	sp,sp,80
    80001564:	8082                	ret

0000000080001566 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001566:	c6dd                	beqz	a3,80001614 <copyinstr+0xae>
{
    80001568:	715d                	addi	sp,sp,-80
    8000156a:	e486                	sd	ra,72(sp)
    8000156c:	e0a2                	sd	s0,64(sp)
    8000156e:	fc26                	sd	s1,56(sp)
    80001570:	f84a                	sd	s2,48(sp)
    80001572:	f44e                	sd	s3,40(sp)
    80001574:	f052                	sd	s4,32(sp)
    80001576:	ec56                	sd	s5,24(sp)
    80001578:	e85a                	sd	s6,16(sp)
    8000157a:	e45e                	sd	s7,8(sp)
    8000157c:	0880                	addi	s0,sp,80
    8000157e:	8aaa                	mv	s5,a0
    80001580:	8b2e                	mv	s6,a1
    80001582:	8bb2                	mv	s7,a2
    80001584:	84b6                	mv	s1,a3
    va0 = (uint)PGROUNDDOWN(srcva);
    80001586:	00100a37          	lui	s4,0x100
    8000158a:	1a7d                	addi	s4,s4,-1
    8000158c:	0a32                	slli	s4,s4,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000158e:	6985                	lui	s3,0x1
    80001590:	a035                	j	800015bc <copyinstr+0x56>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001592:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001596:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001598:	0017b793          	seqz	a5,a5
    8000159c:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800015a0:	60a6                	ld	ra,72(sp)
    800015a2:	6406                	ld	s0,64(sp)
    800015a4:	74e2                	ld	s1,56(sp)
    800015a6:	7942                	ld	s2,48(sp)
    800015a8:	79a2                	ld	s3,40(sp)
    800015aa:	7a02                	ld	s4,32(sp)
    800015ac:	6ae2                	ld	s5,24(sp)
    800015ae:	6b42                	ld	s6,16(sp)
    800015b0:	6ba2                	ld	s7,8(sp)
    800015b2:	6161                	addi	sp,sp,80
    800015b4:	8082                	ret
    srcva = va0 + PGSIZE;
    800015b6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800015ba:	c8a9                	beqz	s1,8000160c <copyinstr+0xa6>
    va0 = (uint)PGROUNDDOWN(srcva);
    800015bc:	014bf933          	and	s2,s7,s4
    pa0 = walkaddr(pagetable, va0);
    800015c0:	85ca                	mv	a1,s2
    800015c2:	8556                	mv	a0,s5
    800015c4:	00000097          	auipc	ra,0x0
    800015c8:	8b6080e7          	jalr	-1866(ra) # 80000e7a <walkaddr>
    if(pa0 == 0)
    800015cc:	c131                	beqz	a0,80001610 <copyinstr+0xaa>
    n = PGSIZE - (srcva - va0);
    800015ce:	41790833          	sub	a6,s2,s7
    800015d2:	984e                	add	a6,a6,s3
    if(n > max)
    800015d4:	0104f363          	bgeu	s1,a6,800015da <copyinstr+0x74>
    800015d8:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800015da:	955e                	add	a0,a0,s7
    800015dc:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800015e0:	fc080be3          	beqz	a6,800015b6 <copyinstr+0x50>
    800015e4:	985a                	add	a6,a6,s6
    800015e6:	87da                	mv	a5,s6
      if(*p == '\0'){
    800015e8:	41650633          	sub	a2,a0,s6
    800015ec:	14fd                	addi	s1,s1,-1
    800015ee:	9b26                	add	s6,s6,s1
    800015f0:	00f60733          	add	a4,a2,a5
    800015f4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd6fa4>
    800015f8:	df49                	beqz	a4,80001592 <copyinstr+0x2c>
        *dst = *p;
    800015fa:	00e78023          	sb	a4,0(a5)
      --max;
    800015fe:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001602:	0785                	addi	a5,a5,1
    while(n > 0){
    80001604:	ff0796e3          	bne	a5,a6,800015f0 <copyinstr+0x8a>
      dst++;
    80001608:	8b42                	mv	s6,a6
    8000160a:	b775                	j	800015b6 <copyinstr+0x50>
    8000160c:	4781                	li	a5,0
    8000160e:	b769                	j	80001598 <copyinstr+0x32>
      return -1;
    80001610:	557d                	li	a0,-1
    80001612:	b779                	j	800015a0 <copyinstr+0x3a>
  int got_null = 0;
    80001614:	4781                	li	a5,0
  if(got_null){
    80001616:	0017b793          	seqz	a5,a5
    8000161a:	40f00533          	neg	a0,a5
}
    8000161e:	8082                	ret

0000000080001620 <procinit>:

extern char trampoline[]; // trampoline.S

void
procinit(void)
{
    80001620:	715d                	addi	sp,sp,-80
    80001622:	e486                	sd	ra,72(sp)
    80001624:	e0a2                	sd	s0,64(sp)
    80001626:	fc26                	sd	s1,56(sp)
    80001628:	f84a                	sd	s2,48(sp)
    8000162a:	f44e                	sd	s3,40(sp)
    8000162c:	f052                	sd	s4,32(sp)
    8000162e:	ec56                	sd	s5,24(sp)
    80001630:	e85a                	sd	s6,16(sp)
    80001632:	e45e                	sd	s7,8(sp)
    80001634:	0880                	addi	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001636:	00006597          	auipc	a1,0x6
    8000163a:	c8258593          	addi	a1,a1,-894 # 800072b8 <userret+0x228>
    8000163e:	00010517          	auipc	a0,0x10
    80001642:	28a50513          	addi	a0,a0,650 # 800118c8 <pid_lock>
    80001646:	fffff097          	auipc	ra,0xfffff
    8000164a:	268080e7          	jalr	616(ra) # 800008ae <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000164e:	00010917          	auipc	s2,0x10
    80001652:	69290913          	addi	s2,s2,1682 # 80011ce0 <proc>
      initlock(&p->lock, "proc");
    80001656:	00006b97          	auipc	s7,0x6
    8000165a:	c6ab8b93          	addi	s7,s7,-918 # 800072c0 <userret+0x230>
      // Map it high in memory, followed by an invalid
      // guard page.
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      uint64 va = KSTACK((int) (p - proc));
    8000165e:	8b4a                	mv	s6,s2
    80001660:	00006a97          	auipc	s5,0x6
    80001664:	4b8a8a93          	addi	s5,s5,1208 # 80007b18 <syscalls+0xc0>
    80001668:	040009b7          	lui	s3,0x4000
    8000166c:	19fd                	addi	s3,s3,-1
    8000166e:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001670:	00016a17          	auipc	s4,0x16
    80001674:	070a0a13          	addi	s4,s4,112 # 800176e0 <tickslock>
      initlock(&p->lock, "proc");
    80001678:	85de                	mv	a1,s7
    8000167a:	854a                	mv	a0,s2
    8000167c:	fffff097          	auipc	ra,0xfffff
    80001680:	232080e7          	jalr	562(ra) # 800008ae <initlock>
      char *pa = kalloc();
    80001684:	fffff097          	auipc	ra,0xfffff
    80001688:	210080e7          	jalr	528(ra) # 80000894 <kalloc>
    8000168c:	85aa                	mv	a1,a0
      if(pa == 0)
    8000168e:	c929                	beqz	a0,800016e0 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001690:	416904b3          	sub	s1,s2,s6
    80001694:	848d                	srai	s1,s1,0x3
    80001696:	000ab783          	ld	a5,0(s5)
    8000169a:	02f484b3          	mul	s1,s1,a5
    8000169e:	2485                	addiw	s1,s1,1
    800016a0:	00d4949b          	slliw	s1,s1,0xd
    800016a4:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800016a8:	4699                	li	a3,6
    800016aa:	6605                	lui	a2,0x1
    800016ac:	8526                	mv	a0,s1
    800016ae:	00000097          	auipc	ra,0x0
    800016b2:	8ee080e7          	jalr	-1810(ra) # 80000f9c <kvmmap>
      p->kstack = va;
    800016b6:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800016ba:	16890913          	addi	s2,s2,360
    800016be:	fb491de3          	bne	s2,s4,80001678 <procinit+0x58>
  }
  kvminithart();
    800016c2:	fffff097          	auipc	ra,0xfffff
    800016c6:	794080e7          	jalr	1940(ra) # 80000e56 <kvminithart>
}
    800016ca:	60a6                	ld	ra,72(sp)
    800016cc:	6406                	ld	s0,64(sp)
    800016ce:	74e2                	ld	s1,56(sp)
    800016d0:	7942                	ld	s2,48(sp)
    800016d2:	79a2                	ld	s3,40(sp)
    800016d4:	7a02                	ld	s4,32(sp)
    800016d6:	6ae2                	ld	s5,24(sp)
    800016d8:	6b42                	ld	s6,16(sp)
    800016da:	6ba2                	ld	s7,8(sp)
    800016dc:	6161                	addi	sp,sp,80
    800016de:	8082                	ret
        panic("kalloc");
    800016e0:	00006517          	auipc	a0,0x6
    800016e4:	be850513          	addi	a0,a0,-1048 # 800072c8 <userret+0x238>
    800016e8:	fffff097          	auipc	ra,0xfffff
    800016ec:	e60080e7          	jalr	-416(ra) # 80000548 <panic>

00000000800016f0 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800016f0:	1141                	addi	sp,sp,-16
    800016f2:	e422                	sd	s0,8(sp)
    800016f4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800016f6:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800016f8:	2501                	sext.w	a0,a0
    800016fa:	6422                	ld	s0,8(sp)
    800016fc:	0141                	addi	sp,sp,16
    800016fe:	8082                	ret

0000000080001700 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001700:	1141                	addi	sp,sp,-16
    80001702:	e422                	sd	s0,8(sp)
    80001704:	0800                	addi	s0,sp,16
    80001706:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001708:	2781                	sext.w	a5,a5
    8000170a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000170c:	00010517          	auipc	a0,0x10
    80001710:	1d450513          	addi	a0,a0,468 # 800118e0 <cpus>
    80001714:	953e                	add	a0,a0,a5
    80001716:	6422                	ld	s0,8(sp)
    80001718:	0141                	addi	sp,sp,16
    8000171a:	8082                	ret

000000008000171c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    8000171c:	1101                	addi	sp,sp,-32
    8000171e:	ec06                	sd	ra,24(sp)
    80001720:	e822                	sd	s0,16(sp)
    80001722:	e426                	sd	s1,8(sp)
    80001724:	1000                	addi	s0,sp,32
  push_off();
    80001726:	fffff097          	auipc	ra,0xfffff
    8000172a:	19e080e7          	jalr	414(ra) # 800008c4 <push_off>
    8000172e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001730:	2781                	sext.w	a5,a5
    80001732:	079e                	slli	a5,a5,0x7
    80001734:	00010717          	auipc	a4,0x10
    80001738:	19470713          	addi	a4,a4,404 # 800118c8 <pid_lock>
    8000173c:	97ba                	add	a5,a5,a4
    8000173e:	6f84                	ld	s1,24(a5)
  pop_off();
    80001740:	fffff097          	auipc	ra,0xfffff
    80001744:	1d0080e7          	jalr	464(ra) # 80000910 <pop_off>
  return p;
}
    80001748:	8526                	mv	a0,s1
    8000174a:	60e2                	ld	ra,24(sp)
    8000174c:	6442                	ld	s0,16(sp)
    8000174e:	64a2                	ld	s1,8(sp)
    80001750:	6105                	addi	sp,sp,32
    80001752:	8082                	ret

0000000080001754 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001754:	1141                	addi	sp,sp,-16
    80001756:	e406                	sd	ra,8(sp)
    80001758:	e022                	sd	s0,0(sp)
    8000175a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000175c:	00000097          	auipc	ra,0x0
    80001760:	fc0080e7          	jalr	-64(ra) # 8000171c <myproc>
    80001764:	fffff097          	auipc	ra,0xfffff
    80001768:	2c0080e7          	jalr	704(ra) # 80000a24 <release>

  if (first) {
    8000176c:	00007797          	auipc	a5,0x7
    80001770:	8c87a783          	lw	a5,-1848(a5) # 80008034 <first.1>
    80001774:	eb89                	bnez	a5,80001786 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(minor(ROOTDEV));
  }

  usertrapret();
    80001776:	00001097          	auipc	ra,0x1
    8000177a:	c1a080e7          	jalr	-998(ra) # 80002390 <usertrapret>
}
    8000177e:	60a2                	ld	ra,8(sp)
    80001780:	6402                	ld	s0,0(sp)
    80001782:	0141                	addi	sp,sp,16
    80001784:	8082                	ret
    first = 0;
    80001786:	00007797          	auipc	a5,0x7
    8000178a:	8a07a723          	sw	zero,-1874(a5) # 80008034 <first.1>
    fsinit(minor(ROOTDEV));
    8000178e:	4501                	li	a0,0
    80001790:	00002097          	auipc	ra,0x2
    80001794:	940080e7          	jalr	-1728(ra) # 800030d0 <fsinit>
    80001798:	bff9                	j	80001776 <forkret+0x22>

000000008000179a <allocpid>:
allocpid() {
    8000179a:	1101                	addi	sp,sp,-32
    8000179c:	ec06                	sd	ra,24(sp)
    8000179e:	e822                	sd	s0,16(sp)
    800017a0:	e426                	sd	s1,8(sp)
    800017a2:	e04a                	sd	s2,0(sp)
    800017a4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800017a6:	00010917          	auipc	s2,0x10
    800017aa:	12290913          	addi	s2,s2,290 # 800118c8 <pid_lock>
    800017ae:	854a                	mv	a0,s2
    800017b0:	fffff097          	auipc	ra,0xfffff
    800017b4:	20c080e7          	jalr	524(ra) # 800009bc <acquire>
  pid = nextpid;
    800017b8:	00007797          	auipc	a5,0x7
    800017bc:	88078793          	addi	a5,a5,-1920 # 80008038 <nextpid>
    800017c0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800017c2:	0014871b          	addiw	a4,s1,1
    800017c6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800017c8:	854a                	mv	a0,s2
    800017ca:	fffff097          	auipc	ra,0xfffff
    800017ce:	25a080e7          	jalr	602(ra) # 80000a24 <release>
}
    800017d2:	8526                	mv	a0,s1
    800017d4:	60e2                	ld	ra,24(sp)
    800017d6:	6442                	ld	s0,16(sp)
    800017d8:	64a2                	ld	s1,8(sp)
    800017da:	6902                	ld	s2,0(sp)
    800017dc:	6105                	addi	sp,sp,32
    800017de:	8082                	ret

00000000800017e0 <proc_pagetable>:
{
    800017e0:	1101                	addi	sp,sp,-32
    800017e2:	ec06                	sd	ra,24(sp)
    800017e4:	e822                	sd	s0,16(sp)
    800017e6:	e426                	sd	s1,8(sp)
    800017e8:	e04a                	sd	s2,0(sp)
    800017ea:	1000                	addi	s0,sp,32
    800017ec:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800017ee:	00000097          	auipc	ra,0x0
    800017f2:	994080e7          	jalr	-1644(ra) # 80001182 <uvmcreate>
    800017f6:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    800017f8:	4729                	li	a4,10
    800017fa:	00006697          	auipc	a3,0x6
    800017fe:	80668693          	addi	a3,a3,-2042 # 80007000 <trampoline>
    80001802:	6605                	lui	a2,0x1
    80001804:	040005b7          	lui	a1,0x4000
    80001808:	15fd                	addi	a1,a1,-1
    8000180a:	05b2                	slli	a1,a1,0xc
    8000180c:	fffff097          	auipc	ra,0xfffff
    80001810:	702080e7          	jalr	1794(ra) # 80000f0e <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001814:	4719                	li	a4,6
    80001816:	05893683          	ld	a3,88(s2)
    8000181a:	6605                	lui	a2,0x1
    8000181c:	020005b7          	lui	a1,0x2000
    80001820:	15fd                	addi	a1,a1,-1
    80001822:	05b6                	slli	a1,a1,0xd
    80001824:	8526                	mv	a0,s1
    80001826:	fffff097          	auipc	ra,0xfffff
    8000182a:	6e8080e7          	jalr	1768(ra) # 80000f0e <mappages>
}
    8000182e:	8526                	mv	a0,s1
    80001830:	60e2                	ld	ra,24(sp)
    80001832:	6442                	ld	s0,16(sp)
    80001834:	64a2                	ld	s1,8(sp)
    80001836:	6902                	ld	s2,0(sp)
    80001838:	6105                	addi	sp,sp,32
    8000183a:	8082                	ret

000000008000183c <allocproc>:
{
    8000183c:	1101                	addi	sp,sp,-32
    8000183e:	ec06                	sd	ra,24(sp)
    80001840:	e822                	sd	s0,16(sp)
    80001842:	e426                	sd	s1,8(sp)
    80001844:	e04a                	sd	s2,0(sp)
    80001846:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001848:	00010497          	auipc	s1,0x10
    8000184c:	49848493          	addi	s1,s1,1176 # 80011ce0 <proc>
    80001850:	00016917          	auipc	s2,0x16
    80001854:	e9090913          	addi	s2,s2,-368 # 800176e0 <tickslock>
    acquire(&p->lock);
    80001858:	8526                	mv	a0,s1
    8000185a:	fffff097          	auipc	ra,0xfffff
    8000185e:	162080e7          	jalr	354(ra) # 800009bc <acquire>
    if(p->state == UNUSED) {
    80001862:	4c9c                	lw	a5,24(s1)
    80001864:	cf81                	beqz	a5,8000187c <allocproc+0x40>
      release(&p->lock);
    80001866:	8526                	mv	a0,s1
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	1bc080e7          	jalr	444(ra) # 80000a24 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001870:	16848493          	addi	s1,s1,360
    80001874:	ff2492e3          	bne	s1,s2,80001858 <allocproc+0x1c>
  return 0;
    80001878:	4481                	li	s1,0
    8000187a:	a0a9                	j	800018c4 <allocproc+0x88>
  p->pid = allocpid();
    8000187c:	00000097          	auipc	ra,0x0
    80001880:	f1e080e7          	jalr	-226(ra) # 8000179a <allocpid>
    80001884:	dc88                	sw	a0,56(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001886:	fffff097          	auipc	ra,0xfffff
    8000188a:	00e080e7          	jalr	14(ra) # 80000894 <kalloc>
    8000188e:	892a                	mv	s2,a0
    80001890:	eca8                	sd	a0,88(s1)
    80001892:	c121                	beqz	a0,800018d2 <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001894:	8526                	mv	a0,s1
    80001896:	00000097          	auipc	ra,0x0
    8000189a:	f4a080e7          	jalr	-182(ra) # 800017e0 <proc_pagetable>
    8000189e:	e8a8                	sd	a0,80(s1)
  memset(&p->context, 0, sizeof p->context);
    800018a0:	07000613          	li	a2,112
    800018a4:	4581                	li	a1,0
    800018a6:	06048513          	addi	a0,s1,96
    800018aa:	fffff097          	auipc	ra,0xfffff
    800018ae:	1d6080e7          	jalr	470(ra) # 80000a80 <memset>
  p->context.ra = (uint64)forkret;
    800018b2:	00000797          	auipc	a5,0x0
    800018b6:	ea278793          	addi	a5,a5,-350 # 80001754 <forkret>
    800018ba:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800018bc:	60bc                	ld	a5,64(s1)
    800018be:	6705                	lui	a4,0x1
    800018c0:	97ba                	add	a5,a5,a4
    800018c2:	f4bc                	sd	a5,104(s1)
}
    800018c4:	8526                	mv	a0,s1
    800018c6:	60e2                	ld	ra,24(sp)
    800018c8:	6442                	ld	s0,16(sp)
    800018ca:	64a2                	ld	s1,8(sp)
    800018cc:	6902                	ld	s2,0(sp)
    800018ce:	6105                	addi	sp,sp,32
    800018d0:	8082                	ret
    release(&p->lock);
    800018d2:	8526                	mv	a0,s1
    800018d4:	fffff097          	auipc	ra,0xfffff
    800018d8:	150080e7          	jalr	336(ra) # 80000a24 <release>
    return 0;
    800018dc:	84ca                	mv	s1,s2
    800018de:	b7dd                	j	800018c4 <allocproc+0x88>

00000000800018e0 <proc_freepagetable>:
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	e04a                	sd	s2,0(sp)
    800018ea:	1000                	addi	s0,sp,32
    800018ec:	84aa                	mv	s1,a0
    800018ee:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    800018f0:	4681                	li	a3,0
    800018f2:	6605                	lui	a2,0x1
    800018f4:	040005b7          	lui	a1,0x4000
    800018f8:	15fd                	addi	a1,a1,-1
    800018fa:	05b2                	slli	a1,a1,0xc
    800018fc:	fffff097          	auipc	ra,0xfffff
    80001900:	7be080e7          	jalr	1982(ra) # 800010ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001904:	4681                	li	a3,0
    80001906:	6605                	lui	a2,0x1
    80001908:	020005b7          	lui	a1,0x2000
    8000190c:	15fd                	addi	a1,a1,-1
    8000190e:	05b6                	slli	a1,a1,0xd
    80001910:	8526                	mv	a0,s1
    80001912:	fffff097          	auipc	ra,0xfffff
    80001916:	7a8080e7          	jalr	1960(ra) # 800010ba <uvmunmap>
  if(sz > 0)
    8000191a:	00091863          	bnez	s2,8000192a <proc_freepagetable+0x4a>
}
    8000191e:	60e2                	ld	ra,24(sp)
    80001920:	6442                	ld	s0,16(sp)
    80001922:	64a2                	ld	s1,8(sp)
    80001924:	6902                	ld	s2,0(sp)
    80001926:	6105                	addi	sp,sp,32
    80001928:	8082                	ret
    uvmfree(pagetable, sz);
    8000192a:	85ca                	mv	a1,s2
    8000192c:	8526                	mv	a0,s1
    8000192e:	00000097          	auipc	ra,0x0
    80001932:	9e2080e7          	jalr	-1566(ra) # 80001310 <uvmfree>
}
    80001936:	b7e5                	j	8000191e <proc_freepagetable+0x3e>

0000000080001938 <freeproc>:
{
    80001938:	1101                	addi	sp,sp,-32
    8000193a:	ec06                	sd	ra,24(sp)
    8000193c:	e822                	sd	s0,16(sp)
    8000193e:	e426                	sd	s1,8(sp)
    80001940:	1000                	addi	s0,sp,32
    80001942:	84aa                	mv	s1,a0
  if(p->tf)
    80001944:	6d28                	ld	a0,88(a0)
    80001946:	c509                	beqz	a0,80001950 <freeproc+0x18>
    kfree((void*)p->tf);
    80001948:	fffff097          	auipc	ra,0xfffff
    8000194c:	f34080e7          	jalr	-204(ra) # 8000087c <kfree>
  p->tf = 0;
    80001950:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001954:	68a8                	ld	a0,80(s1)
    80001956:	c511                	beqz	a0,80001962 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001958:	64ac                	ld	a1,72(s1)
    8000195a:	00000097          	auipc	ra,0x0
    8000195e:	f86080e7          	jalr	-122(ra) # 800018e0 <proc_freepagetable>
  p->pagetable = 0;
    80001962:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001966:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    8000196a:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    8000196e:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001972:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001976:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    8000197a:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    8000197e:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001982:	0004ac23          	sw	zero,24(s1)
}
    80001986:	60e2                	ld	ra,24(sp)
    80001988:	6442                	ld	s0,16(sp)
    8000198a:	64a2                	ld	s1,8(sp)
    8000198c:	6105                	addi	sp,sp,32
    8000198e:	8082                	ret

0000000080001990 <userinit>:
{
    80001990:	1101                	addi	sp,sp,-32
    80001992:	ec06                	sd	ra,24(sp)
    80001994:	e822                	sd	s0,16(sp)
    80001996:	e426                	sd	s1,8(sp)
    80001998:	1000                	addi	s0,sp,32
  p = allocproc();
    8000199a:	00000097          	auipc	ra,0x0
    8000199e:	ea2080e7          	jalr	-350(ra) # 8000183c <allocproc>
    800019a2:	84aa                	mv	s1,a0
  initproc = p;
    800019a4:	00026797          	auipc	a5,0x26
    800019a8:	68a7ba23          	sd	a0,1684(a5) # 80028038 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800019ac:	03300613          	li	a2,51
    800019b0:	00006597          	auipc	a1,0x6
    800019b4:	65058593          	addi	a1,a1,1616 # 80008000 <initcode>
    800019b8:	6928                	ld	a0,80(a0)
    800019ba:	00000097          	auipc	ra,0x0
    800019be:	806080e7          	jalr	-2042(ra) # 800011c0 <uvminit>
  p->sz = PGSIZE;
    800019c2:	6785                	lui	a5,0x1
    800019c4:	e4bc                	sd	a5,72(s1)
  p->tf->epc = 0;      // user program counter
    800019c6:	6cb8                	ld	a4,88(s1)
    800019c8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    800019cc:	6cb8                	ld	a4,88(s1)
    800019ce:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800019d0:	4641                	li	a2,16
    800019d2:	00006597          	auipc	a1,0x6
    800019d6:	8fe58593          	addi	a1,a1,-1794 # 800072d0 <userret+0x240>
    800019da:	15848513          	addi	a0,s1,344
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	1f4080e7          	jalr	500(ra) # 80000bd2 <safestrcpy>
  p->cwd = namei("/");
    800019e6:	00006517          	auipc	a0,0x6
    800019ea:	8fa50513          	addi	a0,a0,-1798 # 800072e0 <userret+0x250>
    800019ee:	00002097          	auipc	ra,0x2
    800019f2:	0e6080e7          	jalr	230(ra) # 80003ad4 <namei>
    800019f6:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800019fa:	4789                	li	a5,2
    800019fc:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800019fe:	8526                	mv	a0,s1
    80001a00:	fffff097          	auipc	ra,0xfffff
    80001a04:	024080e7          	jalr	36(ra) # 80000a24 <release>
}
    80001a08:	60e2                	ld	ra,24(sp)
    80001a0a:	6442                	ld	s0,16(sp)
    80001a0c:	64a2                	ld	s1,8(sp)
    80001a0e:	6105                	addi	sp,sp,32
    80001a10:	8082                	ret

0000000080001a12 <growproc>:
{
    80001a12:	1101                	addi	sp,sp,-32
    80001a14:	ec06                	sd	ra,24(sp)
    80001a16:	e822                	sd	s0,16(sp)
    80001a18:	e426                	sd	s1,8(sp)
    80001a1a:	e04a                	sd	s2,0(sp)
    80001a1c:	1000                	addi	s0,sp,32
    80001a1e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001a20:	00000097          	auipc	ra,0x0
    80001a24:	cfc080e7          	jalr	-772(ra) # 8000171c <myproc>
    80001a28:	892a                	mv	s2,a0
  sz = p->sz;
    80001a2a:	652c                	ld	a1,72(a0)
    80001a2c:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001a30:	00904f63          	bgtz	s1,80001a4e <growproc+0x3c>
  } else if(n < 0){
    80001a34:	0204cc63          	bltz	s1,80001a6c <growproc+0x5a>
  p->sz = sz;
    80001a38:	1602                	slli	a2,a2,0x20
    80001a3a:	9201                	srli	a2,a2,0x20
    80001a3c:	04c93423          	sd	a2,72(s2)
  return 0;
    80001a40:	4501                	li	a0,0
}
    80001a42:	60e2                	ld	ra,24(sp)
    80001a44:	6442                	ld	s0,16(sp)
    80001a46:	64a2                	ld	s1,8(sp)
    80001a48:	6902                	ld	s2,0(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001a4e:	9e25                	addw	a2,a2,s1
    80001a50:	1602                	slli	a2,a2,0x20
    80001a52:	9201                	srli	a2,a2,0x20
    80001a54:	1582                	slli	a1,a1,0x20
    80001a56:	9181                	srli	a1,a1,0x20
    80001a58:	6928                	ld	a0,80(a0)
    80001a5a:	00000097          	auipc	ra,0x0
    80001a5e:	80c080e7          	jalr	-2036(ra) # 80001266 <uvmalloc>
    80001a62:	0005061b          	sext.w	a2,a0
    80001a66:	fa69                	bnez	a2,80001a38 <growproc+0x26>
      return -1;
    80001a68:	557d                	li	a0,-1
    80001a6a:	bfe1                	j	80001a42 <growproc+0x30>
    if((sz = uvmdealloc(p->pagetable, sz, sz + n)) == 0) {
    80001a6c:	9e25                	addw	a2,a2,s1
    80001a6e:	1602                	slli	a2,a2,0x20
    80001a70:	9201                	srli	a2,a2,0x20
    80001a72:	1582                	slli	a1,a1,0x20
    80001a74:	9181                	srli	a1,a1,0x20
    80001a76:	6928                	ld	a0,80(a0)
    80001a78:	fffff097          	auipc	ra,0xfffff
    80001a7c:	7ba080e7          	jalr	1978(ra) # 80001232 <uvmdealloc>
    80001a80:	0005061b          	sext.w	a2,a0
    80001a84:	fa55                	bnez	a2,80001a38 <growproc+0x26>
      return -1;
    80001a86:	557d                	li	a0,-1
    80001a88:	bf6d                	j	80001a42 <growproc+0x30>

0000000080001a8a <fork>:
{
    80001a8a:	7139                	addi	sp,sp,-64
    80001a8c:	fc06                	sd	ra,56(sp)
    80001a8e:	f822                	sd	s0,48(sp)
    80001a90:	f426                	sd	s1,40(sp)
    80001a92:	f04a                	sd	s2,32(sp)
    80001a94:	ec4e                	sd	s3,24(sp)
    80001a96:	e852                	sd	s4,16(sp)
    80001a98:	e456                	sd	s5,8(sp)
    80001a9a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001a9c:	00000097          	auipc	ra,0x0
    80001aa0:	c80080e7          	jalr	-896(ra) # 8000171c <myproc>
    80001aa4:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001aa6:	00000097          	auipc	ra,0x0
    80001aaa:	d96080e7          	jalr	-618(ra) # 8000183c <allocproc>
    80001aae:	c17d                	beqz	a0,80001b94 <fork+0x10a>
    80001ab0:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001ab2:	048ab603          	ld	a2,72(s5)
    80001ab6:	692c                	ld	a1,80(a0)
    80001ab8:	050ab503          	ld	a0,80(s5)
    80001abc:	00000097          	auipc	ra,0x0
    80001ac0:	882080e7          	jalr	-1918(ra) # 8000133e <uvmcopy>
    80001ac4:	04054a63          	bltz	a0,80001b18 <fork+0x8e>
  np->sz = p->sz;
    80001ac8:	048ab783          	ld	a5,72(s5)
    80001acc:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001ad0:	035a3023          	sd	s5,32(s4)
  *(np->tf) = *(p->tf);
    80001ad4:	058ab683          	ld	a3,88(s5)
    80001ad8:	87b6                	mv	a5,a3
    80001ada:	058a3703          	ld	a4,88(s4)
    80001ade:	12068693          	addi	a3,a3,288
    80001ae2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ae6:	6788                	ld	a0,8(a5)
    80001ae8:	6b8c                	ld	a1,16(a5)
    80001aea:	6f90                	ld	a2,24(a5)
    80001aec:	01073023          	sd	a6,0(a4)
    80001af0:	e708                	sd	a0,8(a4)
    80001af2:	eb0c                	sd	a1,16(a4)
    80001af4:	ef10                	sd	a2,24(a4)
    80001af6:	02078793          	addi	a5,a5,32
    80001afa:	02070713          	addi	a4,a4,32
    80001afe:	fed792e3          	bne	a5,a3,80001ae2 <fork+0x58>
  np->tf->a0 = 0;
    80001b02:	058a3783          	ld	a5,88(s4)
    80001b06:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001b0a:	0d0a8493          	addi	s1,s5,208
    80001b0e:	0d0a0913          	addi	s2,s4,208
    80001b12:	150a8993          	addi	s3,s5,336
    80001b16:	a00d                	j	80001b38 <fork+0xae>
    freeproc(np);
    80001b18:	8552                	mv	a0,s4
    80001b1a:	00000097          	auipc	ra,0x0
    80001b1e:	e1e080e7          	jalr	-482(ra) # 80001938 <freeproc>
    release(&np->lock);
    80001b22:	8552                	mv	a0,s4
    80001b24:	fffff097          	auipc	ra,0xfffff
    80001b28:	f00080e7          	jalr	-256(ra) # 80000a24 <release>
    return -1;
    80001b2c:	54fd                	li	s1,-1
    80001b2e:	a889                	j	80001b80 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001b30:	04a1                	addi	s1,s1,8
    80001b32:	0921                	addi	s2,s2,8
    80001b34:	01348b63          	beq	s1,s3,80001b4a <fork+0xc0>
    if(p->ofile[i])
    80001b38:	6088                	ld	a0,0(s1)
    80001b3a:	d97d                	beqz	a0,80001b30 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001b3c:	00003097          	auipc	ra,0x3
    80001b40:	880080e7          	jalr	-1920(ra) # 800043bc <filedup>
    80001b44:	00a93023          	sd	a0,0(s2)
    80001b48:	b7e5                	j	80001b30 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001b4a:	150ab503          	ld	a0,336(s5)
    80001b4e:	00001097          	auipc	ra,0x1
    80001b52:	7bc080e7          	jalr	1980(ra) # 8000330a <idup>
    80001b56:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001b5a:	4641                	li	a2,16
    80001b5c:	158a8593          	addi	a1,s5,344
    80001b60:	158a0513          	addi	a0,s4,344
    80001b64:	fffff097          	auipc	ra,0xfffff
    80001b68:	06e080e7          	jalr	110(ra) # 80000bd2 <safestrcpy>
  pid = np->pid;
    80001b6c:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001b70:	4789                	li	a5,2
    80001b72:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001b76:	8552                	mv	a0,s4
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	eac080e7          	jalr	-340(ra) # 80000a24 <release>
}
    80001b80:	8526                	mv	a0,s1
    80001b82:	70e2                	ld	ra,56(sp)
    80001b84:	7442                	ld	s0,48(sp)
    80001b86:	74a2                	ld	s1,40(sp)
    80001b88:	7902                	ld	s2,32(sp)
    80001b8a:	69e2                	ld	s3,24(sp)
    80001b8c:	6a42                	ld	s4,16(sp)
    80001b8e:	6aa2                	ld	s5,8(sp)
    80001b90:	6121                	addi	sp,sp,64
    80001b92:	8082                	ret
    return -1;
    80001b94:	54fd                	li	s1,-1
    80001b96:	b7ed                	j	80001b80 <fork+0xf6>

0000000080001b98 <reparent>:
reparent(struct proc *p, struct proc *parent) {
    80001b98:	711d                	addi	sp,sp,-96
    80001b9a:	ec86                	sd	ra,88(sp)
    80001b9c:	e8a2                	sd	s0,80(sp)
    80001b9e:	e4a6                	sd	s1,72(sp)
    80001ba0:	e0ca                	sd	s2,64(sp)
    80001ba2:	fc4e                	sd	s3,56(sp)
    80001ba4:	f852                	sd	s4,48(sp)
    80001ba6:	f456                	sd	s5,40(sp)
    80001ba8:	f05a                	sd	s6,32(sp)
    80001baa:	ec5e                	sd	s7,24(sp)
    80001bac:	e862                	sd	s8,16(sp)
    80001bae:	e466                	sd	s9,8(sp)
    80001bb0:	1080                	addi	s0,sp,96
    80001bb2:	892a                	mv	s2,a0
  int child_of_init = (p->parent == initproc);
    80001bb4:	02053b83          	ld	s7,32(a0)
    80001bb8:	00026b17          	auipc	s6,0x26
    80001bbc:	480b3b03          	ld	s6,1152(s6) # 80028038 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001bc0:	00010497          	auipc	s1,0x10
    80001bc4:	12048493          	addi	s1,s1,288 # 80011ce0 <proc>
      pp->parent = initproc;
    80001bc8:	00026a17          	auipc	s4,0x26
    80001bcc:	470a0a13          	addi	s4,s4,1136 # 80028038 <initproc>
      if(pp->state == ZOMBIE) {
    80001bd0:	4a91                	li	s5,4
// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
  if(p->chan == p && p->state == SLEEPING) {
    80001bd2:	4c05                	li	s8,1
    p->state = RUNNABLE;
    80001bd4:	4c89                	li	s9,2
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001bd6:	00016997          	auipc	s3,0x16
    80001bda:	b0a98993          	addi	s3,s3,-1270 # 800176e0 <tickslock>
    80001bde:	a805                	j	80001c0e <reparent+0x76>
  if(p->chan == p && p->state == SLEEPING) {
    80001be0:	751c                	ld	a5,40(a0)
    80001be2:	00f51d63          	bne	a0,a5,80001bfc <reparent+0x64>
    80001be6:	4d1c                	lw	a5,24(a0)
    80001be8:	01879a63          	bne	a5,s8,80001bfc <reparent+0x64>
    p->state = RUNNABLE;
    80001bec:	01952c23          	sw	s9,24(a0)
        if(!child_of_init)
    80001bf0:	016b8663          	beq	s7,s6,80001bfc <reparent+0x64>
          release(&initproc->lock);
    80001bf4:	fffff097          	auipc	ra,0xfffff
    80001bf8:	e30080e7          	jalr	-464(ra) # 80000a24 <release>
      release(&pp->lock);
    80001bfc:	8526                	mv	a0,s1
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	e26080e7          	jalr	-474(ra) # 80000a24 <release>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001c06:	16848493          	addi	s1,s1,360
    80001c0a:	03348f63          	beq	s1,s3,80001c48 <reparent+0xb0>
    if(pp->parent == p){
    80001c0e:	709c                	ld	a5,32(s1)
    80001c10:	ff279be3          	bne	a5,s2,80001c06 <reparent+0x6e>
      acquire(&pp->lock);
    80001c14:	8526                	mv	a0,s1
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	da6080e7          	jalr	-602(ra) # 800009bc <acquire>
      pp->parent = initproc;
    80001c1e:	000a3503          	ld	a0,0(s4)
    80001c22:	f088                	sd	a0,32(s1)
      if(pp->state == ZOMBIE) {
    80001c24:	4c9c                	lw	a5,24(s1)
    80001c26:	fd579be3          	bne	a5,s5,80001bfc <reparent+0x64>
        if(!child_of_init)
    80001c2a:	fb6b8be3          	beq	s7,s6,80001be0 <reparent+0x48>
          acquire(&initproc->lock);
    80001c2e:	fffff097          	auipc	ra,0xfffff
    80001c32:	d8e080e7          	jalr	-626(ra) # 800009bc <acquire>
        wakeup1(initproc);
    80001c36:	000a3503          	ld	a0,0(s4)
  if(p->chan == p && p->state == SLEEPING) {
    80001c3a:	751c                	ld	a5,40(a0)
    80001c3c:	faa79ce3          	bne	a5,a0,80001bf4 <reparent+0x5c>
    80001c40:	4d1c                	lw	a5,24(a0)
    80001c42:	fb8799e3          	bne	a5,s8,80001bf4 <reparent+0x5c>
    80001c46:	b75d                	j	80001bec <reparent+0x54>
}
    80001c48:	60e6                	ld	ra,88(sp)
    80001c4a:	6446                	ld	s0,80(sp)
    80001c4c:	64a6                	ld	s1,72(sp)
    80001c4e:	6906                	ld	s2,64(sp)
    80001c50:	79e2                	ld	s3,56(sp)
    80001c52:	7a42                	ld	s4,48(sp)
    80001c54:	7aa2                	ld	s5,40(sp)
    80001c56:	7b02                	ld	s6,32(sp)
    80001c58:	6be2                	ld	s7,24(sp)
    80001c5a:	6c42                	ld	s8,16(sp)
    80001c5c:	6ca2                	ld	s9,8(sp)
    80001c5e:	6125                	addi	sp,sp,96
    80001c60:	8082                	ret

0000000080001c62 <scheduler>:
{
    80001c62:	715d                	addi	sp,sp,-80
    80001c64:	e486                	sd	ra,72(sp)
    80001c66:	e0a2                	sd	s0,64(sp)
    80001c68:	fc26                	sd	s1,56(sp)
    80001c6a:	f84a                	sd	s2,48(sp)
    80001c6c:	f44e                	sd	s3,40(sp)
    80001c6e:	f052                	sd	s4,32(sp)
    80001c70:	ec56                	sd	s5,24(sp)
    80001c72:	e85a                	sd	s6,16(sp)
    80001c74:	e45e                	sd	s7,8(sp)
    80001c76:	e062                	sd	s8,0(sp)
    80001c78:	0880                	addi	s0,sp,80
    80001c7a:	8792                	mv	a5,tp
  int id = r_tp();
    80001c7c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001c7e:	00779b13          	slli	s6,a5,0x7
    80001c82:	00010717          	auipc	a4,0x10
    80001c86:	c4670713          	addi	a4,a4,-954 # 800118c8 <pid_lock>
    80001c8a:	975a                	add	a4,a4,s6
    80001c8c:	00073c23          	sd	zero,24(a4)
        swtch(&c->scheduler, &p->context);
    80001c90:	00010717          	auipc	a4,0x10
    80001c94:	c5870713          	addi	a4,a4,-936 # 800118e8 <cpus+0x8>
    80001c98:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001c9a:	4c0d                	li	s8,3
        c->proc = p;
    80001c9c:	079e                	slli	a5,a5,0x7
    80001c9e:	00010a17          	auipc	s4,0x10
    80001ca2:	c2aa0a13          	addi	s4,s4,-982 # 800118c8 <pid_lock>
    80001ca6:	9a3e                	add	s4,s4,a5
        found = 1;
    80001ca8:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001caa:	00016997          	auipc	s3,0x16
    80001cae:	a3698993          	addi	s3,s3,-1482 # 800176e0 <tickslock>
    80001cb2:	a08d                	j	80001d14 <scheduler+0xb2>
      release(&p->lock);
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	d6e080e7          	jalr	-658(ra) # 80000a24 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001cbe:	16848493          	addi	s1,s1,360
    80001cc2:	03348963          	beq	s1,s3,80001cf4 <scheduler+0x92>
      acquire(&p->lock);
    80001cc6:	8526                	mv	a0,s1
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	cf4080e7          	jalr	-780(ra) # 800009bc <acquire>
      if(p->state == RUNNABLE) {
    80001cd0:	4c9c                	lw	a5,24(s1)
    80001cd2:	ff2791e3          	bne	a5,s2,80001cb4 <scheduler+0x52>
        p->state = RUNNING;
    80001cd6:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001cda:	009a3c23          	sd	s1,24(s4)
        swtch(&c->scheduler, &p->context);
    80001cde:	06048593          	addi	a1,s1,96
    80001ce2:	855a                	mv	a0,s6
    80001ce4:	00000097          	auipc	ra,0x0
    80001ce8:	602080e7          	jalr	1538(ra) # 800022e6 <swtch>
        c->proc = 0;
    80001cec:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001cf0:	8ade                	mv	s5,s7
    80001cf2:	b7c9                	j	80001cb4 <scheduler+0x52>
    if(found == 0){
    80001cf4:	020a9063          	bnez	s5,80001d14 <scheduler+0xb2>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001cf8:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001cfc:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001d00:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d04:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d08:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d0c:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001d10:	10500073          	wfi
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001d14:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001d18:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001d1c:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d20:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d24:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d28:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001d2c:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d2e:	00010497          	auipc	s1,0x10
    80001d32:	fb248493          	addi	s1,s1,-78 # 80011ce0 <proc>
      if(p->state == RUNNABLE) {
    80001d36:	4909                	li	s2,2
    80001d38:	b779                	j	80001cc6 <scheduler+0x64>

0000000080001d3a <sched>:
{
    80001d3a:	7179                	addi	sp,sp,-48
    80001d3c:	f406                	sd	ra,40(sp)
    80001d3e:	f022                	sd	s0,32(sp)
    80001d40:	ec26                	sd	s1,24(sp)
    80001d42:	e84a                	sd	s2,16(sp)
    80001d44:	e44e                	sd	s3,8(sp)
    80001d46:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d48:	00000097          	auipc	ra,0x0
    80001d4c:	9d4080e7          	jalr	-1580(ra) # 8000171c <myproc>
    80001d50:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	c2a080e7          	jalr	-982(ra) # 8000097c <holding>
    80001d5a:	c93d                	beqz	a0,80001dd0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d5c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001d5e:	2781                	sext.w	a5,a5
    80001d60:	079e                	slli	a5,a5,0x7
    80001d62:	00010717          	auipc	a4,0x10
    80001d66:	b6670713          	addi	a4,a4,-1178 # 800118c8 <pid_lock>
    80001d6a:	97ba                	add	a5,a5,a4
    80001d6c:	0907a703          	lw	a4,144(a5)
    80001d70:	4785                	li	a5,1
    80001d72:	06f71763          	bne	a4,a5,80001de0 <sched+0xa6>
  if(p->state == RUNNING)
    80001d76:	4c98                	lw	a4,24(s1)
    80001d78:	478d                	li	a5,3
    80001d7a:	06f70b63          	beq	a4,a5,80001df0 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d7e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001d82:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001d84:	efb5                	bnez	a5,80001e00 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d86:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001d88:	00010917          	auipc	s2,0x10
    80001d8c:	b4090913          	addi	s2,s2,-1216 # 800118c8 <pid_lock>
    80001d90:	2781                	sext.w	a5,a5
    80001d92:	079e                	slli	a5,a5,0x7
    80001d94:	97ca                	add	a5,a5,s2
    80001d96:	0947a983          	lw	s3,148(a5)
    80001d9a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80001d9c:	2781                	sext.w	a5,a5
    80001d9e:	079e                	slli	a5,a5,0x7
    80001da0:	00010597          	auipc	a1,0x10
    80001da4:	b4858593          	addi	a1,a1,-1208 # 800118e8 <cpus+0x8>
    80001da8:	95be                	add	a1,a1,a5
    80001daa:	06048513          	addi	a0,s1,96
    80001dae:	00000097          	auipc	ra,0x0
    80001db2:	538080e7          	jalr	1336(ra) # 800022e6 <swtch>
    80001db6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001db8:	2781                	sext.w	a5,a5
    80001dba:	079e                	slli	a5,a5,0x7
    80001dbc:	97ca                	add	a5,a5,s2
    80001dbe:	0937aa23          	sw	s3,148(a5)
}
    80001dc2:	70a2                	ld	ra,40(sp)
    80001dc4:	7402                	ld	s0,32(sp)
    80001dc6:	64e2                	ld	s1,24(sp)
    80001dc8:	6942                	ld	s2,16(sp)
    80001dca:	69a2                	ld	s3,8(sp)
    80001dcc:	6145                	addi	sp,sp,48
    80001dce:	8082                	ret
    panic("sched p->lock");
    80001dd0:	00005517          	auipc	a0,0x5
    80001dd4:	51850513          	addi	a0,a0,1304 # 800072e8 <userret+0x258>
    80001dd8:	ffffe097          	auipc	ra,0xffffe
    80001ddc:	770080e7          	jalr	1904(ra) # 80000548 <panic>
    panic("sched locks");
    80001de0:	00005517          	auipc	a0,0x5
    80001de4:	51850513          	addi	a0,a0,1304 # 800072f8 <userret+0x268>
    80001de8:	ffffe097          	auipc	ra,0xffffe
    80001dec:	760080e7          	jalr	1888(ra) # 80000548 <panic>
    panic("sched running");
    80001df0:	00005517          	auipc	a0,0x5
    80001df4:	51850513          	addi	a0,a0,1304 # 80007308 <userret+0x278>
    80001df8:	ffffe097          	auipc	ra,0xffffe
    80001dfc:	750080e7          	jalr	1872(ra) # 80000548 <panic>
    panic("sched interruptible");
    80001e00:	00005517          	auipc	a0,0x5
    80001e04:	51850513          	addi	a0,a0,1304 # 80007318 <userret+0x288>
    80001e08:	ffffe097          	auipc	ra,0xffffe
    80001e0c:	740080e7          	jalr	1856(ra) # 80000548 <panic>

0000000080001e10 <exit>:
{
    80001e10:	7179                	addi	sp,sp,-48
    80001e12:	f406                	sd	ra,40(sp)
    80001e14:	f022                	sd	s0,32(sp)
    80001e16:	ec26                	sd	s1,24(sp)
    80001e18:	e84a                	sd	s2,16(sp)
    80001e1a:	e44e                	sd	s3,8(sp)
    80001e1c:	e052                	sd	s4,0(sp)
    80001e1e:	1800                	addi	s0,sp,48
    80001e20:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001e22:	00000097          	auipc	ra,0x0
    80001e26:	8fa080e7          	jalr	-1798(ra) # 8000171c <myproc>
    80001e2a:	89aa                	mv	s3,a0
  if(p == initproc)
    80001e2c:	00026797          	auipc	a5,0x26
    80001e30:	20c7b783          	ld	a5,524(a5) # 80028038 <initproc>
    80001e34:	0d050493          	addi	s1,a0,208
    80001e38:	15050913          	addi	s2,a0,336
    80001e3c:	02a79363          	bne	a5,a0,80001e62 <exit+0x52>
    panic("init exiting");
    80001e40:	00005517          	auipc	a0,0x5
    80001e44:	4f050513          	addi	a0,a0,1264 # 80007330 <userret+0x2a0>
    80001e48:	ffffe097          	auipc	ra,0xffffe
    80001e4c:	700080e7          	jalr	1792(ra) # 80000548 <panic>
      fileclose(f);
    80001e50:	00002097          	auipc	ra,0x2
    80001e54:	5be080e7          	jalr	1470(ra) # 8000440e <fileclose>
      p->ofile[fd] = 0;
    80001e58:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001e5c:	04a1                	addi	s1,s1,8
    80001e5e:	01248563          	beq	s1,s2,80001e68 <exit+0x58>
    if(p->ofile[fd]){
    80001e62:	6088                	ld	a0,0(s1)
    80001e64:	f575                	bnez	a0,80001e50 <exit+0x40>
    80001e66:	bfdd                	j	80001e5c <exit+0x4c>
  begin_op(ROOTDEV);
    80001e68:	4501                	li	a0,0
    80001e6a:	00002097          	auipc	ra,0x2
    80001e6e:	f86080e7          	jalr	-122(ra) # 80003df0 <begin_op>
  iput(p->cwd);
    80001e72:	1509b503          	ld	a0,336(s3)
    80001e76:	00001097          	auipc	ra,0x1
    80001e7a:	5e0080e7          	jalr	1504(ra) # 80003456 <iput>
  end_op(ROOTDEV);
    80001e7e:	4501                	li	a0,0
    80001e80:	00002097          	auipc	ra,0x2
    80001e84:	01a080e7          	jalr	26(ra) # 80003e9a <end_op>
  p->cwd = 0;
    80001e88:	1409b823          	sd	zero,336(s3)
  acquire(&p->parent->lock);
    80001e8c:	0209b503          	ld	a0,32(s3)
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	b2c080e7          	jalr	-1236(ra) # 800009bc <acquire>
  acquire(&p->lock);
    80001e98:	854e                	mv	a0,s3
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	b22080e7          	jalr	-1246(ra) # 800009bc <acquire>
  reparent(p, p->parent);
    80001ea2:	0209b583          	ld	a1,32(s3)
    80001ea6:	854e                	mv	a0,s3
    80001ea8:	00000097          	auipc	ra,0x0
    80001eac:	cf0080e7          	jalr	-784(ra) # 80001b98 <reparent>
  wakeup1(p->parent);
    80001eb0:	0209b783          	ld	a5,32(s3)
  if(p->chan == p && p->state == SLEEPING) {
    80001eb4:	7798                	ld	a4,40(a5)
    80001eb6:	02e78963          	beq	a5,a4,80001ee8 <exit+0xd8>
  p->xstate = status;
    80001eba:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80001ebe:	4791                	li	a5,4
    80001ec0:	00f9ac23          	sw	a5,24(s3)
  release(&p->parent->lock);
    80001ec4:	0209b503          	ld	a0,32(s3)
    80001ec8:	fffff097          	auipc	ra,0xfffff
    80001ecc:	b5c080e7          	jalr	-1188(ra) # 80000a24 <release>
  sched();
    80001ed0:	00000097          	auipc	ra,0x0
    80001ed4:	e6a080e7          	jalr	-406(ra) # 80001d3a <sched>
  panic("zombie exit");
    80001ed8:	00005517          	auipc	a0,0x5
    80001edc:	46850513          	addi	a0,a0,1128 # 80007340 <userret+0x2b0>
    80001ee0:	ffffe097          	auipc	ra,0xffffe
    80001ee4:	668080e7          	jalr	1640(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001ee8:	4f94                	lw	a3,24(a5)
    80001eea:	4705                	li	a4,1
    80001eec:	fce697e3          	bne	a3,a4,80001eba <exit+0xaa>
    p->state = RUNNABLE;
    80001ef0:	4709                	li	a4,2
    80001ef2:	cf98                	sw	a4,24(a5)
    80001ef4:	b7d9                	j	80001eba <exit+0xaa>

0000000080001ef6 <yield>:
{
    80001ef6:	1101                	addi	sp,sp,-32
    80001ef8:	ec06                	sd	ra,24(sp)
    80001efa:	e822                	sd	s0,16(sp)
    80001efc:	e426                	sd	s1,8(sp)
    80001efe:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f00:	00000097          	auipc	ra,0x0
    80001f04:	81c080e7          	jalr	-2020(ra) # 8000171c <myproc>
    80001f08:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f0a:	fffff097          	auipc	ra,0xfffff
    80001f0e:	ab2080e7          	jalr	-1358(ra) # 800009bc <acquire>
  p->state = RUNNABLE;
    80001f12:	4789                	li	a5,2
    80001f14:	cc9c                	sw	a5,24(s1)
  sched();
    80001f16:	00000097          	auipc	ra,0x0
    80001f1a:	e24080e7          	jalr	-476(ra) # 80001d3a <sched>
  release(&p->lock);
    80001f1e:	8526                	mv	a0,s1
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	b04080e7          	jalr	-1276(ra) # 80000a24 <release>
}
    80001f28:	60e2                	ld	ra,24(sp)
    80001f2a:	6442                	ld	s0,16(sp)
    80001f2c:	64a2                	ld	s1,8(sp)
    80001f2e:	6105                	addi	sp,sp,32
    80001f30:	8082                	ret

0000000080001f32 <sleep>:
{
    80001f32:	7179                	addi	sp,sp,-48
    80001f34:	f406                	sd	ra,40(sp)
    80001f36:	f022                	sd	s0,32(sp)
    80001f38:	ec26                	sd	s1,24(sp)
    80001f3a:	e84a                	sd	s2,16(sp)
    80001f3c:	e44e                	sd	s3,8(sp)
    80001f3e:	1800                	addi	s0,sp,48
    80001f40:	89aa                	mv	s3,a0
    80001f42:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	7d8080e7          	jalr	2008(ra) # 8000171c <myproc>
    80001f4c:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80001f4e:	05250663          	beq	a0,s2,80001f9a <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	a6a080e7          	jalr	-1430(ra) # 800009bc <acquire>
    release(lk);
    80001f5a:	854a                	mv	a0,s2
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	ac8080e7          	jalr	-1336(ra) # 80000a24 <release>
  p->chan = chan;
    80001f64:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80001f68:	4785                	li	a5,1
    80001f6a:	cc9c                	sw	a5,24(s1)
  sched();
    80001f6c:	00000097          	auipc	ra,0x0
    80001f70:	dce080e7          	jalr	-562(ra) # 80001d3a <sched>
  p->chan = 0;
    80001f74:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80001f78:	8526                	mv	a0,s1
    80001f7a:	fffff097          	auipc	ra,0xfffff
    80001f7e:	aaa080e7          	jalr	-1366(ra) # 80000a24 <release>
    acquire(lk);
    80001f82:	854a                	mv	a0,s2
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	a38080e7          	jalr	-1480(ra) # 800009bc <acquire>
}
    80001f8c:	70a2                	ld	ra,40(sp)
    80001f8e:	7402                	ld	s0,32(sp)
    80001f90:	64e2                	ld	s1,24(sp)
    80001f92:	6942                	ld	s2,16(sp)
    80001f94:	69a2                	ld	s3,8(sp)
    80001f96:	6145                	addi	sp,sp,48
    80001f98:	8082                	ret
  p->chan = chan;
    80001f9a:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80001f9e:	4785                	li	a5,1
    80001fa0:	cd1c                	sw	a5,24(a0)
  sched();
    80001fa2:	00000097          	auipc	ra,0x0
    80001fa6:	d98080e7          	jalr	-616(ra) # 80001d3a <sched>
  p->chan = 0;
    80001faa:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80001fae:	bff9                	j	80001f8c <sleep+0x5a>

0000000080001fb0 <wait>:
{
    80001fb0:	715d                	addi	sp,sp,-80
    80001fb2:	e486                	sd	ra,72(sp)
    80001fb4:	e0a2                	sd	s0,64(sp)
    80001fb6:	fc26                	sd	s1,56(sp)
    80001fb8:	f84a                	sd	s2,48(sp)
    80001fba:	f44e                	sd	s3,40(sp)
    80001fbc:	f052                	sd	s4,32(sp)
    80001fbe:	ec56                	sd	s5,24(sp)
    80001fc0:	e85a                	sd	s6,16(sp)
    80001fc2:	e45e                	sd	s7,8(sp)
    80001fc4:	0880                	addi	s0,sp,80
    80001fc6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001fc8:	fffff097          	auipc	ra,0xfffff
    80001fcc:	754080e7          	jalr	1876(ra) # 8000171c <myproc>
    80001fd0:	892a                	mv	s2,a0
  acquire(&p->lock);
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	9ea080e7          	jalr	-1558(ra) # 800009bc <acquire>
    havekids = 0;
    80001fda:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80001fdc:	4a11                	li	s4,4
        havekids = 1;
    80001fde:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80001fe0:	00015997          	auipc	s3,0x15
    80001fe4:	70098993          	addi	s3,s3,1792 # 800176e0 <tickslock>
    havekids = 0;
    80001fe8:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80001fea:	00010497          	auipc	s1,0x10
    80001fee:	cf648493          	addi	s1,s1,-778 # 80011ce0 <proc>
    80001ff2:	a08d                	j	80002054 <wait+0xa4>
          pid = np->pid;
    80001ff4:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80001ff8:	000b0e63          	beqz	s6,80002014 <wait+0x64>
    80001ffc:	4691                	li	a3,4
    80001ffe:	03448613          	addi	a2,s1,52
    80002002:	85da                	mv	a1,s6
    80002004:	05093503          	ld	a0,80(s2)
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	438080e7          	jalr	1080(ra) # 80001440 <copyout>
    80002010:	02054263          	bltz	a0,80002034 <wait+0x84>
          freeproc(np);
    80002014:	8526                	mv	a0,s1
    80002016:	00000097          	auipc	ra,0x0
    8000201a:	922080e7          	jalr	-1758(ra) # 80001938 <freeproc>
          release(&np->lock);
    8000201e:	8526                	mv	a0,s1
    80002020:	fffff097          	auipc	ra,0xfffff
    80002024:	a04080e7          	jalr	-1532(ra) # 80000a24 <release>
          release(&p->lock);
    80002028:	854a                	mv	a0,s2
    8000202a:	fffff097          	auipc	ra,0xfffff
    8000202e:	9fa080e7          	jalr	-1542(ra) # 80000a24 <release>
          return pid;
    80002032:	a8a9                	j	8000208c <wait+0xdc>
            release(&np->lock);
    80002034:	8526                	mv	a0,s1
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	9ee080e7          	jalr	-1554(ra) # 80000a24 <release>
            release(&p->lock);
    8000203e:	854a                	mv	a0,s2
    80002040:	fffff097          	auipc	ra,0xfffff
    80002044:	9e4080e7          	jalr	-1564(ra) # 80000a24 <release>
            return -1;
    80002048:	59fd                	li	s3,-1
    8000204a:	a089                	j	8000208c <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    8000204c:	16848493          	addi	s1,s1,360
    80002050:	03348463          	beq	s1,s3,80002078 <wait+0xc8>
      if(np->parent == p){
    80002054:	709c                	ld	a5,32(s1)
    80002056:	ff279be3          	bne	a5,s2,8000204c <wait+0x9c>
        acquire(&np->lock);
    8000205a:	8526                	mv	a0,s1
    8000205c:	fffff097          	auipc	ra,0xfffff
    80002060:	960080e7          	jalr	-1696(ra) # 800009bc <acquire>
        if(np->state == ZOMBIE){
    80002064:	4c9c                	lw	a5,24(s1)
    80002066:	f94787e3          	beq	a5,s4,80001ff4 <wait+0x44>
        release(&np->lock);
    8000206a:	8526                	mv	a0,s1
    8000206c:	fffff097          	auipc	ra,0xfffff
    80002070:	9b8080e7          	jalr	-1608(ra) # 80000a24 <release>
        havekids = 1;
    80002074:	8756                	mv	a4,s5
    80002076:	bfd9                	j	8000204c <wait+0x9c>
    if(!havekids || p->killed){
    80002078:	c701                	beqz	a4,80002080 <wait+0xd0>
    8000207a:	03092783          	lw	a5,48(s2)
    8000207e:	c39d                	beqz	a5,800020a4 <wait+0xf4>
      release(&p->lock);
    80002080:	854a                	mv	a0,s2
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	9a2080e7          	jalr	-1630(ra) # 80000a24 <release>
      return -1;
    8000208a:	59fd                	li	s3,-1
}
    8000208c:	854e                	mv	a0,s3
    8000208e:	60a6                	ld	ra,72(sp)
    80002090:	6406                	ld	s0,64(sp)
    80002092:	74e2                	ld	s1,56(sp)
    80002094:	7942                	ld	s2,48(sp)
    80002096:	79a2                	ld	s3,40(sp)
    80002098:	7a02                	ld	s4,32(sp)
    8000209a:	6ae2                	ld	s5,24(sp)
    8000209c:	6b42                	ld	s6,16(sp)
    8000209e:	6ba2                	ld	s7,8(sp)
    800020a0:	6161                	addi	sp,sp,80
    800020a2:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800020a4:	85ca                	mv	a1,s2
    800020a6:	854a                	mv	a0,s2
    800020a8:	00000097          	auipc	ra,0x0
    800020ac:	e8a080e7          	jalr	-374(ra) # 80001f32 <sleep>
    havekids = 0;
    800020b0:	bf25                	j	80001fe8 <wait+0x38>

00000000800020b2 <wakeup>:
{
    800020b2:	7139                	addi	sp,sp,-64
    800020b4:	fc06                	sd	ra,56(sp)
    800020b6:	f822                	sd	s0,48(sp)
    800020b8:	f426                	sd	s1,40(sp)
    800020ba:	f04a                	sd	s2,32(sp)
    800020bc:	ec4e                	sd	s3,24(sp)
    800020be:	e852                	sd	s4,16(sp)
    800020c0:	e456                	sd	s5,8(sp)
    800020c2:	0080                	addi	s0,sp,64
    800020c4:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800020c6:	00010497          	auipc	s1,0x10
    800020ca:	c1a48493          	addi	s1,s1,-998 # 80011ce0 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800020ce:	4985                	li	s3,1
      p->state = RUNNABLE;
    800020d0:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800020d2:	00015917          	auipc	s2,0x15
    800020d6:	60e90913          	addi	s2,s2,1550 # 800176e0 <tickslock>
    800020da:	a811                	j	800020ee <wakeup+0x3c>
    release(&p->lock);
    800020dc:	8526                	mv	a0,s1
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	946080e7          	jalr	-1722(ra) # 80000a24 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020e6:	16848493          	addi	s1,s1,360
    800020ea:	03248063          	beq	s1,s2,8000210a <wakeup+0x58>
    acquire(&p->lock);
    800020ee:	8526                	mv	a0,s1
    800020f0:	fffff097          	auipc	ra,0xfffff
    800020f4:	8cc080e7          	jalr	-1844(ra) # 800009bc <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800020f8:	4c9c                	lw	a5,24(s1)
    800020fa:	ff3791e3          	bne	a5,s3,800020dc <wakeup+0x2a>
    800020fe:	749c                	ld	a5,40(s1)
    80002100:	fd479ee3          	bne	a5,s4,800020dc <wakeup+0x2a>
      p->state = RUNNABLE;
    80002104:	0154ac23          	sw	s5,24(s1)
    80002108:	bfd1                	j	800020dc <wakeup+0x2a>
}
    8000210a:	70e2                	ld	ra,56(sp)
    8000210c:	7442                	ld	s0,48(sp)
    8000210e:	74a2                	ld	s1,40(sp)
    80002110:	7902                	ld	s2,32(sp)
    80002112:	69e2                	ld	s3,24(sp)
    80002114:	6a42                	ld	s4,16(sp)
    80002116:	6aa2                	ld	s5,8(sp)
    80002118:	6121                	addi	sp,sp,64
    8000211a:	8082                	ret

000000008000211c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000211c:	7179                	addi	sp,sp,-48
    8000211e:	f406                	sd	ra,40(sp)
    80002120:	f022                	sd	s0,32(sp)
    80002122:	ec26                	sd	s1,24(sp)
    80002124:	e84a                	sd	s2,16(sp)
    80002126:	e44e                	sd	s3,8(sp)
    80002128:	1800                	addi	s0,sp,48
    8000212a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000212c:	00010497          	auipc	s1,0x10
    80002130:	bb448493          	addi	s1,s1,-1100 # 80011ce0 <proc>
    80002134:	00015997          	auipc	s3,0x15
    80002138:	5ac98993          	addi	s3,s3,1452 # 800176e0 <tickslock>
    acquire(&p->lock);
    8000213c:	8526                	mv	a0,s1
    8000213e:	fffff097          	auipc	ra,0xfffff
    80002142:	87e080e7          	jalr	-1922(ra) # 800009bc <acquire>
    if(p->pid == pid){
    80002146:	5c9c                	lw	a5,56(s1)
    80002148:	01278d63          	beq	a5,s2,80002162 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000214c:	8526                	mv	a0,s1
    8000214e:	fffff097          	auipc	ra,0xfffff
    80002152:	8d6080e7          	jalr	-1834(ra) # 80000a24 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002156:	16848493          	addi	s1,s1,360
    8000215a:	ff3491e3          	bne	s1,s3,8000213c <kill+0x20>
  }
  return -1;
    8000215e:	557d                	li	a0,-1
    80002160:	a821                	j	80002178 <kill+0x5c>
      p->killed = 1;
    80002162:	4785                	li	a5,1
    80002164:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002166:	4c98                	lw	a4,24(s1)
    80002168:	00f70f63          	beq	a4,a5,80002186 <kill+0x6a>
      release(&p->lock);
    8000216c:	8526                	mv	a0,s1
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	8b6080e7          	jalr	-1866(ra) # 80000a24 <release>
      return 0;
    80002176:	4501                	li	a0,0
}
    80002178:	70a2                	ld	ra,40(sp)
    8000217a:	7402                	ld	s0,32(sp)
    8000217c:	64e2                	ld	s1,24(sp)
    8000217e:	6942                	ld	s2,16(sp)
    80002180:	69a2                	ld	s3,8(sp)
    80002182:	6145                	addi	sp,sp,48
    80002184:	8082                	ret
        p->state = RUNNABLE;
    80002186:	4789                	li	a5,2
    80002188:	cc9c                	sw	a5,24(s1)
    8000218a:	b7cd                	j	8000216c <kill+0x50>

000000008000218c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000218c:	7179                	addi	sp,sp,-48
    8000218e:	f406                	sd	ra,40(sp)
    80002190:	f022                	sd	s0,32(sp)
    80002192:	ec26                	sd	s1,24(sp)
    80002194:	e84a                	sd	s2,16(sp)
    80002196:	e44e                	sd	s3,8(sp)
    80002198:	e052                	sd	s4,0(sp)
    8000219a:	1800                	addi	s0,sp,48
    8000219c:	84aa                	mv	s1,a0
    8000219e:	892e                	mv	s2,a1
    800021a0:	89b2                	mv	s3,a2
    800021a2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	578080e7          	jalr	1400(ra) # 8000171c <myproc>
  if(user_dst){
    800021ac:	c08d                	beqz	s1,800021ce <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800021ae:	86d2                	mv	a3,s4
    800021b0:	864e                	mv	a2,s3
    800021b2:	85ca                	mv	a1,s2
    800021b4:	6928                	ld	a0,80(a0)
    800021b6:	fffff097          	auipc	ra,0xfffff
    800021ba:	28a080e7          	jalr	650(ra) # 80001440 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800021be:	70a2                	ld	ra,40(sp)
    800021c0:	7402                	ld	s0,32(sp)
    800021c2:	64e2                	ld	s1,24(sp)
    800021c4:	6942                	ld	s2,16(sp)
    800021c6:	69a2                	ld	s3,8(sp)
    800021c8:	6a02                	ld	s4,0(sp)
    800021ca:	6145                	addi	sp,sp,48
    800021cc:	8082                	ret
    memmove((char *)dst, src, len);
    800021ce:	000a061b          	sext.w	a2,s4
    800021d2:	85ce                	mv	a1,s3
    800021d4:	854a                	mv	a0,s2
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	906080e7          	jalr	-1786(ra) # 80000adc <memmove>
    return 0;
    800021de:	8526                	mv	a0,s1
    800021e0:	bff9                	j	800021be <either_copyout+0x32>

00000000800021e2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800021e2:	7179                	addi	sp,sp,-48
    800021e4:	f406                	sd	ra,40(sp)
    800021e6:	f022                	sd	s0,32(sp)
    800021e8:	ec26                	sd	s1,24(sp)
    800021ea:	e84a                	sd	s2,16(sp)
    800021ec:	e44e                	sd	s3,8(sp)
    800021ee:	e052                	sd	s4,0(sp)
    800021f0:	1800                	addi	s0,sp,48
    800021f2:	892a                	mv	s2,a0
    800021f4:	84ae                	mv	s1,a1
    800021f6:	89b2                	mv	s3,a2
    800021f8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800021fa:	fffff097          	auipc	ra,0xfffff
    800021fe:	522080e7          	jalr	1314(ra) # 8000171c <myproc>
  if(user_src){
    80002202:	c08d                	beqz	s1,80002224 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002204:	86d2                	mv	a3,s4
    80002206:	864e                	mv	a2,s3
    80002208:	85ca                	mv	a1,s2
    8000220a:	6928                	ld	a0,80(a0)
    8000220c:	fffff097          	auipc	ra,0xfffff
    80002210:	2c6080e7          	jalr	710(ra) # 800014d2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002214:	70a2                	ld	ra,40(sp)
    80002216:	7402                	ld	s0,32(sp)
    80002218:	64e2                	ld	s1,24(sp)
    8000221a:	6942                	ld	s2,16(sp)
    8000221c:	69a2                	ld	s3,8(sp)
    8000221e:	6a02                	ld	s4,0(sp)
    80002220:	6145                	addi	sp,sp,48
    80002222:	8082                	ret
    memmove(dst, (char*)src, len);
    80002224:	000a061b          	sext.w	a2,s4
    80002228:	85ce                	mv	a1,s3
    8000222a:	854a                	mv	a0,s2
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	8b0080e7          	jalr	-1872(ra) # 80000adc <memmove>
    return 0;
    80002234:	8526                	mv	a0,s1
    80002236:	bff9                	j	80002214 <either_copyin+0x32>

0000000080002238 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002238:	715d                	addi	sp,sp,-80
    8000223a:	e486                	sd	ra,72(sp)
    8000223c:	e0a2                	sd	s0,64(sp)
    8000223e:	fc26                	sd	s1,56(sp)
    80002240:	f84a                	sd	s2,48(sp)
    80002242:	f44e                	sd	s3,40(sp)
    80002244:	f052                	sd	s4,32(sp)
    80002246:	ec56                	sd	s5,24(sp)
    80002248:	e85a                	sd	s6,16(sp)
    8000224a:	e45e                	sd	s7,8(sp)
    8000224c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000224e:	00005517          	auipc	a0,0x5
    80002252:	f5250513          	addi	a0,a0,-174 # 800071a0 <userret+0x110>
    80002256:	ffffe097          	auipc	ra,0xffffe
    8000225a:	33c080e7          	jalr	828(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000225e:	00010497          	auipc	s1,0x10
    80002262:	bda48493          	addi	s1,s1,-1062 # 80011e38 <proc+0x158>
    80002266:	00015917          	auipc	s2,0x15
    8000226a:	5d290913          	addi	s2,s2,1490 # 80017838 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000226e:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002270:	00005997          	auipc	s3,0x5
    80002274:	0e098993          	addi	s3,s3,224 # 80007350 <userret+0x2c0>
    printf("%d %s %s", p->pid, state, p->name);
    80002278:	00005a97          	auipc	s5,0x5
    8000227c:	0e0a8a93          	addi	s5,s5,224 # 80007358 <userret+0x2c8>
    printf("\n");
    80002280:	00005a17          	auipc	s4,0x5
    80002284:	f20a0a13          	addi	s4,s4,-224 # 800071a0 <userret+0x110>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002288:	00005b97          	auipc	s7,0x5
    8000228c:	790b8b93          	addi	s7,s7,1936 # 80007a18 <states.0>
    80002290:	a00d                	j	800022b2 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002292:	ee06a583          	lw	a1,-288(a3)
    80002296:	8556                	mv	a0,s5
    80002298:	ffffe097          	auipc	ra,0xffffe
    8000229c:	2fa080e7          	jalr	762(ra) # 80000592 <printf>
    printf("\n");
    800022a0:	8552                	mv	a0,s4
    800022a2:	ffffe097          	auipc	ra,0xffffe
    800022a6:	2f0080e7          	jalr	752(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022aa:	16848493          	addi	s1,s1,360
    800022ae:	03248163          	beq	s1,s2,800022d0 <procdump+0x98>
    if(p->state == UNUSED)
    800022b2:	86a6                	mv	a3,s1
    800022b4:	ec04a783          	lw	a5,-320(s1)
    800022b8:	dbed                	beqz	a5,800022aa <procdump+0x72>
      state = "???";
    800022ba:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022bc:	fcfb6be3          	bltu	s6,a5,80002292 <procdump+0x5a>
    800022c0:	1782                	slli	a5,a5,0x20
    800022c2:	9381                	srli	a5,a5,0x20
    800022c4:	078e                	slli	a5,a5,0x3
    800022c6:	97de                	add	a5,a5,s7
    800022c8:	6390                	ld	a2,0(a5)
    800022ca:	f661                	bnez	a2,80002292 <procdump+0x5a>
      state = "???";
    800022cc:	864e                	mv	a2,s3
    800022ce:	b7d1                	j	80002292 <procdump+0x5a>
  }
}
    800022d0:	60a6                	ld	ra,72(sp)
    800022d2:	6406                	ld	s0,64(sp)
    800022d4:	74e2                	ld	s1,56(sp)
    800022d6:	7942                	ld	s2,48(sp)
    800022d8:	79a2                	ld	s3,40(sp)
    800022da:	7a02                	ld	s4,32(sp)
    800022dc:	6ae2                	ld	s5,24(sp)
    800022de:	6b42                	ld	s6,16(sp)
    800022e0:	6ba2                	ld	s7,8(sp)
    800022e2:	6161                	addi	sp,sp,80
    800022e4:	8082                	ret

00000000800022e6 <swtch>:
    800022e6:	00153023          	sd	ra,0(a0)
    800022ea:	00253423          	sd	sp,8(a0)
    800022ee:	e900                	sd	s0,16(a0)
    800022f0:	ed04                	sd	s1,24(a0)
    800022f2:	03253023          	sd	s2,32(a0)
    800022f6:	03353423          	sd	s3,40(a0)
    800022fa:	03453823          	sd	s4,48(a0)
    800022fe:	03553c23          	sd	s5,56(a0)
    80002302:	05653023          	sd	s6,64(a0)
    80002306:	05753423          	sd	s7,72(a0)
    8000230a:	05853823          	sd	s8,80(a0)
    8000230e:	05953c23          	sd	s9,88(a0)
    80002312:	07a53023          	sd	s10,96(a0)
    80002316:	07b53423          	sd	s11,104(a0)
    8000231a:	0005b083          	ld	ra,0(a1)
    8000231e:	0085b103          	ld	sp,8(a1)
    80002322:	6980                	ld	s0,16(a1)
    80002324:	6d84                	ld	s1,24(a1)
    80002326:	0205b903          	ld	s2,32(a1)
    8000232a:	0285b983          	ld	s3,40(a1)
    8000232e:	0305ba03          	ld	s4,48(a1)
    80002332:	0385ba83          	ld	s5,56(a1)
    80002336:	0405bb03          	ld	s6,64(a1)
    8000233a:	0485bb83          	ld	s7,72(a1)
    8000233e:	0505bc03          	ld	s8,80(a1)
    80002342:	0585bc83          	ld	s9,88(a1)
    80002346:	0605bd03          	ld	s10,96(a1)
    8000234a:	0685bd83          	ld	s11,104(a1)
    8000234e:	8082                	ret

0000000080002350 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002350:	1141                	addi	sp,sp,-16
    80002352:	e406                	sd	ra,8(sp)
    80002354:	e022                	sd	s0,0(sp)
    80002356:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002358:	00005597          	auipc	a1,0x5
    8000235c:	03858593          	addi	a1,a1,56 # 80007390 <userret+0x300>
    80002360:	00015517          	auipc	a0,0x15
    80002364:	38050513          	addi	a0,a0,896 # 800176e0 <tickslock>
    80002368:	ffffe097          	auipc	ra,0xffffe
    8000236c:	546080e7          	jalr	1350(ra) # 800008ae <initlock>
}
    80002370:	60a2                	ld	ra,8(sp)
    80002372:	6402                	ld	s0,0(sp)
    80002374:	0141                	addi	sp,sp,16
    80002376:	8082                	ret

0000000080002378 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002378:	1141                	addi	sp,sp,-16
    8000237a:	e422                	sd	s0,8(sp)
    8000237c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000237e:	00003797          	auipc	a5,0x3
    80002382:	76278793          	addi	a5,a5,1890 # 80005ae0 <kernelvec>
    80002386:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000238a:	6422                	ld	s0,8(sp)
    8000238c:	0141                	addi	sp,sp,16
    8000238e:	8082                	ret

0000000080002390 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002390:	1141                	addi	sp,sp,-16
    80002392:	e406                	sd	ra,8(sp)
    80002394:	e022                	sd	s0,0(sp)
    80002396:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	384080e7          	jalr	900(ra) # 8000171c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023a0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023a4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023a6:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800023aa:	00005617          	auipc	a2,0x5
    800023ae:	c5660613          	addi	a2,a2,-938 # 80007000 <trampoline>
    800023b2:	00005697          	auipc	a3,0x5
    800023b6:	c4e68693          	addi	a3,a3,-946 # 80007000 <trampoline>
    800023ba:	8e91                	sub	a3,a3,a2
    800023bc:	040007b7          	lui	a5,0x4000
    800023c0:	17fd                	addi	a5,a5,-1
    800023c2:	07b2                	slli	a5,a5,0xc
    800023c4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023c6:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    800023ca:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800023cc:	180026f3          	csrr	a3,satp
    800023d0:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800023d2:	6d38                	ld	a4,88(a0)
    800023d4:	6134                	ld	a3,64(a0)
    800023d6:	6585                	lui	a1,0x1
    800023d8:	96ae                	add	a3,a3,a1
    800023da:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    800023dc:	6d38                	ld	a4,88(a0)
    800023de:	00000697          	auipc	a3,0x0
    800023e2:	12868693          	addi	a3,a3,296 # 80002506 <usertrap>
    800023e6:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    800023e8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800023ea:	8692                	mv	a3,tp
    800023ec:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023ee:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800023f2:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800023f6:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023fa:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    800023fe:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002400:	6f18                	ld	a4,24(a4)
    80002402:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002406:	692c                	ld	a1,80(a0)
    80002408:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000240a:	00005717          	auipc	a4,0x5
    8000240e:	c8670713          	addi	a4,a4,-890 # 80007090 <userret>
    80002412:	8f11                	sub	a4,a4,a2
    80002414:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002416:	577d                	li	a4,-1
    80002418:	177e                	slli	a4,a4,0x3f
    8000241a:	8dd9                	or	a1,a1,a4
    8000241c:	02000537          	lui	a0,0x2000
    80002420:	157d                	addi	a0,a0,-1
    80002422:	0536                	slli	a0,a0,0xd
    80002424:	9782                	jalr	a5
}
    80002426:	60a2                	ld	ra,8(sp)
    80002428:	6402                	ld	s0,0(sp)
    8000242a:	0141                	addi	sp,sp,16
    8000242c:	8082                	ret

000000008000242e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000242e:	1101                	addi	sp,sp,-32
    80002430:	ec06                	sd	ra,24(sp)
    80002432:	e822                	sd	s0,16(sp)
    80002434:	e426                	sd	s1,8(sp)
    80002436:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002438:	00015497          	auipc	s1,0x15
    8000243c:	2a848493          	addi	s1,s1,680 # 800176e0 <tickslock>
    80002440:	8526                	mv	a0,s1
    80002442:	ffffe097          	auipc	ra,0xffffe
    80002446:	57a080e7          	jalr	1402(ra) # 800009bc <acquire>
  ticks++;
    8000244a:	00026517          	auipc	a0,0x26
    8000244e:	bf650513          	addi	a0,a0,-1034 # 80028040 <ticks>
    80002452:	411c                	lw	a5,0(a0)
    80002454:	2785                	addiw	a5,a5,1
    80002456:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002458:	00000097          	auipc	ra,0x0
    8000245c:	c5a080e7          	jalr	-934(ra) # 800020b2 <wakeup>
  release(&tickslock);
    80002460:	8526                	mv	a0,s1
    80002462:	ffffe097          	auipc	ra,0xffffe
    80002466:	5c2080e7          	jalr	1474(ra) # 80000a24 <release>
}
    8000246a:	60e2                	ld	ra,24(sp)
    8000246c:	6442                	ld	s0,16(sp)
    8000246e:	64a2                	ld	s1,8(sp)
    80002470:	6105                	addi	sp,sp,32
    80002472:	8082                	ret

0000000080002474 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002474:	1101                	addi	sp,sp,-32
    80002476:	ec06                	sd	ra,24(sp)
    80002478:	e822                	sd	s0,16(sp)
    8000247a:	e426                	sd	s1,8(sp)
    8000247c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000247e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002482:	00074d63          	bltz	a4,8000249c <devintr+0x28>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    }

    plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000001L){
    80002486:	57fd                	li	a5,-1
    80002488:	17fe                	slli	a5,a5,0x3f
    8000248a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000248c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000248e:	04f70b63          	beq	a4,a5,800024e4 <devintr+0x70>
  }
}
    80002492:	60e2                	ld	ra,24(sp)
    80002494:	6442                	ld	s0,16(sp)
    80002496:	64a2                	ld	s1,8(sp)
    80002498:	6105                	addi	sp,sp,32
    8000249a:	8082                	ret
     (scause & 0xff) == 9){
    8000249c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800024a0:	46a5                	li	a3,9
    800024a2:	fed792e3          	bne	a5,a3,80002486 <devintr+0x12>
    int irq = plic_claim();
    800024a6:	00003097          	auipc	ra,0x3
    800024aa:	754080e7          	jalr	1876(ra) # 80005bfa <plic_claim>
    800024ae:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800024b0:	47a9                	li	a5,10
    800024b2:	00f50e63          	beq	a0,a5,800024ce <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    800024b6:	fff5079b          	addiw	a5,a0,-1
    800024ba:	4705                	li	a4,1
    800024bc:	00f77e63          	bgeu	a4,a5,800024d8 <devintr+0x64>
    plic_complete(irq);
    800024c0:	8526                	mv	a0,s1
    800024c2:	00003097          	auipc	ra,0x3
    800024c6:	75c080e7          	jalr	1884(ra) # 80005c1e <plic_complete>
    return 1;
    800024ca:	4505                	li	a0,1
    800024cc:	b7d9                	j	80002492 <devintr+0x1e>
      uartintr();
    800024ce:	ffffe097          	auipc	ra,0xffffe
    800024d2:	35a080e7          	jalr	858(ra) # 80000828 <uartintr>
    800024d6:	b7ed                	j	800024c0 <devintr+0x4c>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800024d8:	853e                	mv	a0,a5
    800024da:	00004097          	auipc	ra,0x4
    800024de:	cee080e7          	jalr	-786(ra) # 800061c8 <virtio_disk_intr>
    800024e2:	bff9                	j	800024c0 <devintr+0x4c>
    if(cpuid() == 0){
    800024e4:	fffff097          	auipc	ra,0xfffff
    800024e8:	20c080e7          	jalr	524(ra) # 800016f0 <cpuid>
    800024ec:	c901                	beqz	a0,800024fc <devintr+0x88>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800024ee:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800024f2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800024f4:	14479073          	csrw	sip,a5
    return 2;
    800024f8:	4509                	li	a0,2
    800024fa:	bf61                	j	80002492 <devintr+0x1e>
      clockintr();
    800024fc:	00000097          	auipc	ra,0x0
    80002500:	f32080e7          	jalr	-206(ra) # 8000242e <clockintr>
    80002504:	b7ed                	j	800024ee <devintr+0x7a>

0000000080002506 <usertrap>:
{
    80002506:	1101                	addi	sp,sp,-32
    80002508:	ec06                	sd	ra,24(sp)
    8000250a:	e822                	sd	s0,16(sp)
    8000250c:	e426                	sd	s1,8(sp)
    8000250e:	e04a                	sd	s2,0(sp)
    80002510:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002512:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002516:	1007f793          	andi	a5,a5,256
    8000251a:	e7bd                	bnez	a5,80002588 <usertrap+0x82>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000251c:	00003797          	auipc	a5,0x3
    80002520:	5c478793          	addi	a5,a5,1476 # 80005ae0 <kernelvec>
    80002524:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002528:	fffff097          	auipc	ra,0xfffff
    8000252c:	1f4080e7          	jalr	500(ra) # 8000171c <myproc>
    80002530:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002532:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002534:	14102773          	csrr	a4,sepc
    80002538:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000253a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000253e:	47a1                	li	a5,8
    80002540:	06f71263          	bne	a4,a5,800025a4 <usertrap+0x9e>
    if(p->killed)
    80002544:	591c                	lw	a5,48(a0)
    80002546:	eba9                	bnez	a5,80002598 <usertrap+0x92>
    p->tf->epc += 4;
    80002548:	6cb8                	ld	a4,88(s1)
    8000254a:	6f1c                	ld	a5,24(a4)
    8000254c:	0791                	addi	a5,a5,4
    8000254e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002550:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80002554:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80002558:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000255c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002560:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002564:	10079073          	csrw	sstatus,a5
    syscall();
    80002568:	00000097          	auipc	ra,0x0
    8000256c:	2e0080e7          	jalr	736(ra) # 80002848 <syscall>
  if(p->killed)
    80002570:	589c                	lw	a5,48(s1)
    80002572:	ebc1                	bnez	a5,80002602 <usertrap+0xfc>
  usertrapret();
    80002574:	00000097          	auipc	ra,0x0
    80002578:	e1c080e7          	jalr	-484(ra) # 80002390 <usertrapret>
}
    8000257c:	60e2                	ld	ra,24(sp)
    8000257e:	6442                	ld	s0,16(sp)
    80002580:	64a2                	ld	s1,8(sp)
    80002582:	6902                	ld	s2,0(sp)
    80002584:	6105                	addi	sp,sp,32
    80002586:	8082                	ret
    panic("usertrap: not from user mode");
    80002588:	00005517          	auipc	a0,0x5
    8000258c:	e1050513          	addi	a0,a0,-496 # 80007398 <userret+0x308>
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	fb8080e7          	jalr	-72(ra) # 80000548 <panic>
      exit(-1);
    80002598:	557d                	li	a0,-1
    8000259a:	00000097          	auipc	ra,0x0
    8000259e:	876080e7          	jalr	-1930(ra) # 80001e10 <exit>
    800025a2:	b75d                	j	80002548 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800025a4:	00000097          	auipc	ra,0x0
    800025a8:	ed0080e7          	jalr	-304(ra) # 80002474 <devintr>
    800025ac:	892a                	mv	s2,a0
    800025ae:	c501                	beqz	a0,800025b6 <usertrap+0xb0>
  if(p->killed)
    800025b0:	589c                	lw	a5,48(s1)
    800025b2:	c3a1                	beqz	a5,800025f2 <usertrap+0xec>
    800025b4:	a815                	j	800025e8 <usertrap+0xe2>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025b6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800025ba:	5c90                	lw	a2,56(s1)
    800025bc:	00005517          	auipc	a0,0x5
    800025c0:	dfc50513          	addi	a0,a0,-516 # 800073b8 <userret+0x328>
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	fce080e7          	jalr	-50(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025cc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025d0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800025d4:	00005517          	auipc	a0,0x5
    800025d8:	e1450513          	addi	a0,a0,-492 # 800073e8 <userret+0x358>
    800025dc:	ffffe097          	auipc	ra,0xffffe
    800025e0:	fb6080e7          	jalr	-74(ra) # 80000592 <printf>
    p->killed = 1;
    800025e4:	4785                	li	a5,1
    800025e6:	d89c                	sw	a5,48(s1)
    exit(-1);
    800025e8:	557d                	li	a0,-1
    800025ea:	00000097          	auipc	ra,0x0
    800025ee:	826080e7          	jalr	-2010(ra) # 80001e10 <exit>
  if(which_dev == 2)
    800025f2:	4789                	li	a5,2
    800025f4:	f8f910e3          	bne	s2,a5,80002574 <usertrap+0x6e>
    yield();
    800025f8:	00000097          	auipc	ra,0x0
    800025fc:	8fe080e7          	jalr	-1794(ra) # 80001ef6 <yield>
    80002600:	bf95                	j	80002574 <usertrap+0x6e>
  int which_dev = 0;
    80002602:	4901                	li	s2,0
    80002604:	b7d5                	j	800025e8 <usertrap+0xe2>

0000000080002606 <kerneltrap>:
{
    80002606:	7179                	addi	sp,sp,-48
    80002608:	f406                	sd	ra,40(sp)
    8000260a:	f022                	sd	s0,32(sp)
    8000260c:	ec26                	sd	s1,24(sp)
    8000260e:	e84a                	sd	s2,16(sp)
    80002610:	e44e                	sd	s3,8(sp)
    80002612:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002614:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002618:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000261c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002620:	1004f793          	andi	a5,s1,256
    80002624:	cb85                	beqz	a5,80002654 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002626:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000262a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000262c:	ef85                	bnez	a5,80002664 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000262e:	00000097          	auipc	ra,0x0
    80002632:	e46080e7          	jalr	-442(ra) # 80002474 <devintr>
    80002636:	cd1d                	beqz	a0,80002674 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002638:	4789                	li	a5,2
    8000263a:	06f50a63          	beq	a0,a5,800026ae <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000263e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002642:	10049073          	csrw	sstatus,s1
}
    80002646:	70a2                	ld	ra,40(sp)
    80002648:	7402                	ld	s0,32(sp)
    8000264a:	64e2                	ld	s1,24(sp)
    8000264c:	6942                	ld	s2,16(sp)
    8000264e:	69a2                	ld	s3,8(sp)
    80002650:	6145                	addi	sp,sp,48
    80002652:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002654:	00005517          	auipc	a0,0x5
    80002658:	db450513          	addi	a0,a0,-588 # 80007408 <userret+0x378>
    8000265c:	ffffe097          	auipc	ra,0xffffe
    80002660:	eec080e7          	jalr	-276(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002664:	00005517          	auipc	a0,0x5
    80002668:	dcc50513          	addi	a0,a0,-564 # 80007430 <userret+0x3a0>
    8000266c:	ffffe097          	auipc	ra,0xffffe
    80002670:	edc080e7          	jalr	-292(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002674:	85ce                	mv	a1,s3
    80002676:	00005517          	auipc	a0,0x5
    8000267a:	dda50513          	addi	a0,a0,-550 # 80007450 <userret+0x3c0>
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	f14080e7          	jalr	-236(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002686:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000268a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000268e:	00005517          	auipc	a0,0x5
    80002692:	dd250513          	addi	a0,a0,-558 # 80007460 <userret+0x3d0>
    80002696:	ffffe097          	auipc	ra,0xffffe
    8000269a:	efc080e7          	jalr	-260(ra) # 80000592 <printf>
    panic("kerneltrap");
    8000269e:	00005517          	auipc	a0,0x5
    800026a2:	dda50513          	addi	a0,a0,-550 # 80007478 <userret+0x3e8>
    800026a6:	ffffe097          	auipc	ra,0xffffe
    800026aa:	ea2080e7          	jalr	-350(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800026ae:	fffff097          	auipc	ra,0xfffff
    800026b2:	06e080e7          	jalr	110(ra) # 8000171c <myproc>
    800026b6:	d541                	beqz	a0,8000263e <kerneltrap+0x38>
    800026b8:	fffff097          	auipc	ra,0xfffff
    800026bc:	064080e7          	jalr	100(ra) # 8000171c <myproc>
    800026c0:	4d18                	lw	a4,24(a0)
    800026c2:	478d                	li	a5,3
    800026c4:	f6f71de3          	bne	a4,a5,8000263e <kerneltrap+0x38>
    yield();
    800026c8:	00000097          	auipc	ra,0x0
    800026cc:	82e080e7          	jalr	-2002(ra) # 80001ef6 <yield>
    800026d0:	b7bd                	j	8000263e <kerneltrap+0x38>

00000000800026d2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026d2:	1101                	addi	sp,sp,-32
    800026d4:	ec06                	sd	ra,24(sp)
    800026d6:	e822                	sd	s0,16(sp)
    800026d8:	e426                	sd	s1,8(sp)
    800026da:	1000                	addi	s0,sp,32
    800026dc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026de:	fffff097          	auipc	ra,0xfffff
    800026e2:	03e080e7          	jalr	62(ra) # 8000171c <myproc>
  switch (n) {
    800026e6:	4795                	li	a5,5
    800026e8:	0497e163          	bltu	a5,s1,8000272a <argraw+0x58>
    800026ec:	048a                	slli	s1,s1,0x2
    800026ee:	00005717          	auipc	a4,0x5
    800026f2:	35270713          	addi	a4,a4,850 # 80007a40 <states.0+0x28>
    800026f6:	94ba                	add	s1,s1,a4
    800026f8:	409c                	lw	a5,0(s1)
    800026fa:	97ba                	add	a5,a5,a4
    800026fc:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    800026fe:	6d3c                	ld	a5,88(a0)
    80002700:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002702:	60e2                	ld	ra,24(sp)
    80002704:	6442                	ld	s0,16(sp)
    80002706:	64a2                	ld	s1,8(sp)
    80002708:	6105                	addi	sp,sp,32
    8000270a:	8082                	ret
    return p->tf->a1;
    8000270c:	6d3c                	ld	a5,88(a0)
    8000270e:	7fa8                	ld	a0,120(a5)
    80002710:	bfcd                	j	80002702 <argraw+0x30>
    return p->tf->a2;
    80002712:	6d3c                	ld	a5,88(a0)
    80002714:	63c8                	ld	a0,128(a5)
    80002716:	b7f5                	j	80002702 <argraw+0x30>
    return p->tf->a3;
    80002718:	6d3c                	ld	a5,88(a0)
    8000271a:	67c8                	ld	a0,136(a5)
    8000271c:	b7dd                	j	80002702 <argraw+0x30>
    return p->tf->a4;
    8000271e:	6d3c                	ld	a5,88(a0)
    80002720:	6bc8                	ld	a0,144(a5)
    80002722:	b7c5                	j	80002702 <argraw+0x30>
    return p->tf->a5;
    80002724:	6d3c                	ld	a5,88(a0)
    80002726:	6fc8                	ld	a0,152(a5)
    80002728:	bfe9                	j	80002702 <argraw+0x30>
  panic("argraw");
    8000272a:	00005517          	auipc	a0,0x5
    8000272e:	d5e50513          	addi	a0,a0,-674 # 80007488 <userret+0x3f8>
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	e16080e7          	jalr	-490(ra) # 80000548 <panic>

000000008000273a <fetchaddr>:
{
    8000273a:	1101                	addi	sp,sp,-32
    8000273c:	ec06                	sd	ra,24(sp)
    8000273e:	e822                	sd	s0,16(sp)
    80002740:	e426                	sd	s1,8(sp)
    80002742:	e04a                	sd	s2,0(sp)
    80002744:	1000                	addi	s0,sp,32
    80002746:	84aa                	mv	s1,a0
    80002748:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000274a:	fffff097          	auipc	ra,0xfffff
    8000274e:	fd2080e7          	jalr	-46(ra) # 8000171c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002752:	653c                	ld	a5,72(a0)
    80002754:	02f4f863          	bgeu	s1,a5,80002784 <fetchaddr+0x4a>
    80002758:	00848713          	addi	a4,s1,8
    8000275c:	02e7e663          	bltu	a5,a4,80002788 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002760:	46a1                	li	a3,8
    80002762:	8626                	mv	a2,s1
    80002764:	85ca                	mv	a1,s2
    80002766:	6928                	ld	a0,80(a0)
    80002768:	fffff097          	auipc	ra,0xfffff
    8000276c:	d6a080e7          	jalr	-662(ra) # 800014d2 <copyin>
    80002770:	00a03533          	snez	a0,a0
    80002774:	40a00533          	neg	a0,a0
}
    80002778:	60e2                	ld	ra,24(sp)
    8000277a:	6442                	ld	s0,16(sp)
    8000277c:	64a2                	ld	s1,8(sp)
    8000277e:	6902                	ld	s2,0(sp)
    80002780:	6105                	addi	sp,sp,32
    80002782:	8082                	ret
    return -1;
    80002784:	557d                	li	a0,-1
    80002786:	bfcd                	j	80002778 <fetchaddr+0x3e>
    80002788:	557d                	li	a0,-1
    8000278a:	b7fd                	j	80002778 <fetchaddr+0x3e>

000000008000278c <fetchstr>:
{
    8000278c:	7179                	addi	sp,sp,-48
    8000278e:	f406                	sd	ra,40(sp)
    80002790:	f022                	sd	s0,32(sp)
    80002792:	ec26                	sd	s1,24(sp)
    80002794:	e84a                	sd	s2,16(sp)
    80002796:	e44e                	sd	s3,8(sp)
    80002798:	1800                	addi	s0,sp,48
    8000279a:	892a                	mv	s2,a0
    8000279c:	84ae                	mv	s1,a1
    8000279e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027a0:	fffff097          	auipc	ra,0xfffff
    800027a4:	f7c080e7          	jalr	-132(ra) # 8000171c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800027a8:	86ce                	mv	a3,s3
    800027aa:	864a                	mv	a2,s2
    800027ac:	85a6                	mv	a1,s1
    800027ae:	6928                	ld	a0,80(a0)
    800027b0:	fffff097          	auipc	ra,0xfffff
    800027b4:	db6080e7          	jalr	-586(ra) # 80001566 <copyinstr>
  if(err < 0)
    800027b8:	00054763          	bltz	a0,800027c6 <fetchstr+0x3a>
  return strlen(buf);
    800027bc:	8526                	mv	a0,s1
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	446080e7          	jalr	1094(ra) # 80000c04 <strlen>
}
    800027c6:	70a2                	ld	ra,40(sp)
    800027c8:	7402                	ld	s0,32(sp)
    800027ca:	64e2                	ld	s1,24(sp)
    800027cc:	6942                	ld	s2,16(sp)
    800027ce:	69a2                	ld	s3,8(sp)
    800027d0:	6145                	addi	sp,sp,48
    800027d2:	8082                	ret

00000000800027d4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800027d4:	1101                	addi	sp,sp,-32
    800027d6:	ec06                	sd	ra,24(sp)
    800027d8:	e822                	sd	s0,16(sp)
    800027da:	e426                	sd	s1,8(sp)
    800027dc:	1000                	addi	s0,sp,32
    800027de:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027e0:	00000097          	auipc	ra,0x0
    800027e4:	ef2080e7          	jalr	-270(ra) # 800026d2 <argraw>
    800027e8:	c088                	sw	a0,0(s1)
  return 0;
}
    800027ea:	4501                	li	a0,0
    800027ec:	60e2                	ld	ra,24(sp)
    800027ee:	6442                	ld	s0,16(sp)
    800027f0:	64a2                	ld	s1,8(sp)
    800027f2:	6105                	addi	sp,sp,32
    800027f4:	8082                	ret

00000000800027f6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800027f6:	1101                	addi	sp,sp,-32
    800027f8:	ec06                	sd	ra,24(sp)
    800027fa:	e822                	sd	s0,16(sp)
    800027fc:	e426                	sd	s1,8(sp)
    800027fe:	1000                	addi	s0,sp,32
    80002800:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002802:	00000097          	auipc	ra,0x0
    80002806:	ed0080e7          	jalr	-304(ra) # 800026d2 <argraw>
    8000280a:	e088                	sd	a0,0(s1)
  return 0;
}
    8000280c:	4501                	li	a0,0
    8000280e:	60e2                	ld	ra,24(sp)
    80002810:	6442                	ld	s0,16(sp)
    80002812:	64a2                	ld	s1,8(sp)
    80002814:	6105                	addi	sp,sp,32
    80002816:	8082                	ret

0000000080002818 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002818:	1101                	addi	sp,sp,-32
    8000281a:	ec06                	sd	ra,24(sp)
    8000281c:	e822                	sd	s0,16(sp)
    8000281e:	e426                	sd	s1,8(sp)
    80002820:	e04a                	sd	s2,0(sp)
    80002822:	1000                	addi	s0,sp,32
    80002824:	84ae                	mv	s1,a1
    80002826:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002828:	00000097          	auipc	ra,0x0
    8000282c:	eaa080e7          	jalr	-342(ra) # 800026d2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002830:	864a                	mv	a2,s2
    80002832:	85a6                	mv	a1,s1
    80002834:	00000097          	auipc	ra,0x0
    80002838:	f58080e7          	jalr	-168(ra) # 8000278c <fetchstr>
}
    8000283c:	60e2                	ld	ra,24(sp)
    8000283e:	6442                	ld	s0,16(sp)
    80002840:	64a2                	ld	s1,8(sp)
    80002842:	6902                	ld	s2,0(sp)
    80002844:	6105                	addi	sp,sp,32
    80002846:	8082                	ret

0000000080002848 <syscall>:
[SYS_crash]   sys_crash,
};

void
syscall(void)
{
    80002848:	1101                	addi	sp,sp,-32
    8000284a:	ec06                	sd	ra,24(sp)
    8000284c:	e822                	sd	s0,16(sp)
    8000284e:	e426                	sd	s1,8(sp)
    80002850:	e04a                	sd	s2,0(sp)
    80002852:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002854:	fffff097          	auipc	ra,0xfffff
    80002858:	ec8080e7          	jalr	-312(ra) # 8000171c <myproc>
    8000285c:	84aa                	mv	s1,a0

  num = p->tf->a7;
    8000285e:	05853903          	ld	s2,88(a0)
    80002862:	0a893783          	ld	a5,168(s2)
    80002866:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000286a:	37fd                	addiw	a5,a5,-1
    8000286c:	4759                	li	a4,22
    8000286e:	00f76f63          	bltu	a4,a5,8000288c <syscall+0x44>
    80002872:	00369713          	slli	a4,a3,0x3
    80002876:	00005797          	auipc	a5,0x5
    8000287a:	1e278793          	addi	a5,a5,482 # 80007a58 <syscalls>
    8000287e:	97ba                	add	a5,a5,a4
    80002880:	639c                	ld	a5,0(a5)
    80002882:	c789                	beqz	a5,8000288c <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002884:	9782                	jalr	a5
    80002886:	06a93823          	sd	a0,112(s2)
    8000288a:	a839                	j	800028a8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000288c:	15848613          	addi	a2,s1,344
    80002890:	5c8c                	lw	a1,56(s1)
    80002892:	00005517          	auipc	a0,0x5
    80002896:	bfe50513          	addi	a0,a0,-1026 # 80007490 <userret+0x400>
    8000289a:	ffffe097          	auipc	ra,0xffffe
    8000289e:	cf8080e7          	jalr	-776(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    800028a2:	6cbc                	ld	a5,88(s1)
    800028a4:	577d                	li	a4,-1
    800028a6:	fbb8                	sd	a4,112(a5)
  }
}
    800028a8:	60e2                	ld	ra,24(sp)
    800028aa:	6442                	ld	s0,16(sp)
    800028ac:	64a2                	ld	s1,8(sp)
    800028ae:	6902                	ld	s2,0(sp)
    800028b0:	6105                	addi	sp,sp,32
    800028b2:	8082                	ret

00000000800028b4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800028b4:	1101                	addi	sp,sp,-32
    800028b6:	ec06                	sd	ra,24(sp)
    800028b8:	e822                	sd	s0,16(sp)
    800028ba:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800028bc:	fec40593          	addi	a1,s0,-20
    800028c0:	4501                	li	a0,0
    800028c2:	00000097          	auipc	ra,0x0
    800028c6:	f12080e7          	jalr	-238(ra) # 800027d4 <argint>
    return -1;
    800028ca:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800028cc:	00054963          	bltz	a0,800028de <sys_exit+0x2a>
  exit(n);
    800028d0:	fec42503          	lw	a0,-20(s0)
    800028d4:	fffff097          	auipc	ra,0xfffff
    800028d8:	53c080e7          	jalr	1340(ra) # 80001e10 <exit>
  return 0;  // not reached
    800028dc:	4781                	li	a5,0
}
    800028de:	853e                	mv	a0,a5
    800028e0:	60e2                	ld	ra,24(sp)
    800028e2:	6442                	ld	s0,16(sp)
    800028e4:	6105                	addi	sp,sp,32
    800028e6:	8082                	ret

00000000800028e8 <sys_getpid>:

uint64
sys_getpid(void)
{
    800028e8:	1141                	addi	sp,sp,-16
    800028ea:	e406                	sd	ra,8(sp)
    800028ec:	e022                	sd	s0,0(sp)
    800028ee:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028f0:	fffff097          	auipc	ra,0xfffff
    800028f4:	e2c080e7          	jalr	-468(ra) # 8000171c <myproc>
}
    800028f8:	5d08                	lw	a0,56(a0)
    800028fa:	60a2                	ld	ra,8(sp)
    800028fc:	6402                	ld	s0,0(sp)
    800028fe:	0141                	addi	sp,sp,16
    80002900:	8082                	ret

0000000080002902 <sys_fork>:

uint64
sys_fork(void)
{
    80002902:	1141                	addi	sp,sp,-16
    80002904:	e406                	sd	ra,8(sp)
    80002906:	e022                	sd	s0,0(sp)
    80002908:	0800                	addi	s0,sp,16
  return fork();
    8000290a:	fffff097          	auipc	ra,0xfffff
    8000290e:	180080e7          	jalr	384(ra) # 80001a8a <fork>
}
    80002912:	60a2                	ld	ra,8(sp)
    80002914:	6402                	ld	s0,0(sp)
    80002916:	0141                	addi	sp,sp,16
    80002918:	8082                	ret

000000008000291a <sys_wait>:

uint64
sys_wait(void)
{
    8000291a:	1101                	addi	sp,sp,-32
    8000291c:	ec06                	sd	ra,24(sp)
    8000291e:	e822                	sd	s0,16(sp)
    80002920:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002922:	fe840593          	addi	a1,s0,-24
    80002926:	4501                	li	a0,0
    80002928:	00000097          	auipc	ra,0x0
    8000292c:	ece080e7          	jalr	-306(ra) # 800027f6 <argaddr>
    80002930:	87aa                	mv	a5,a0
    return -1;
    80002932:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002934:	0007c863          	bltz	a5,80002944 <sys_wait+0x2a>
  return wait(p);
    80002938:	fe843503          	ld	a0,-24(s0)
    8000293c:	fffff097          	auipc	ra,0xfffff
    80002940:	674080e7          	jalr	1652(ra) # 80001fb0 <wait>
}
    80002944:	60e2                	ld	ra,24(sp)
    80002946:	6442                	ld	s0,16(sp)
    80002948:	6105                	addi	sp,sp,32
    8000294a:	8082                	ret

000000008000294c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000294c:	7179                	addi	sp,sp,-48
    8000294e:	f406                	sd	ra,40(sp)
    80002950:	f022                	sd	s0,32(sp)
    80002952:	ec26                	sd	s1,24(sp)
    80002954:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002956:	fdc40593          	addi	a1,s0,-36
    8000295a:	4501                	li	a0,0
    8000295c:	00000097          	auipc	ra,0x0
    80002960:	e78080e7          	jalr	-392(ra) # 800027d4 <argint>
    return -1;
    80002964:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002966:	00054f63          	bltz	a0,80002984 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000296a:	fffff097          	auipc	ra,0xfffff
    8000296e:	db2080e7          	jalr	-590(ra) # 8000171c <myproc>
    80002972:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002974:	fdc42503          	lw	a0,-36(s0)
    80002978:	fffff097          	auipc	ra,0xfffff
    8000297c:	09a080e7          	jalr	154(ra) # 80001a12 <growproc>
    80002980:	00054863          	bltz	a0,80002990 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002984:	8526                	mv	a0,s1
    80002986:	70a2                	ld	ra,40(sp)
    80002988:	7402                	ld	s0,32(sp)
    8000298a:	64e2                	ld	s1,24(sp)
    8000298c:	6145                	addi	sp,sp,48
    8000298e:	8082                	ret
    return -1;
    80002990:	54fd                	li	s1,-1
    80002992:	bfcd                	j	80002984 <sys_sbrk+0x38>

0000000080002994 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002994:	7139                	addi	sp,sp,-64
    80002996:	fc06                	sd	ra,56(sp)
    80002998:	f822                	sd	s0,48(sp)
    8000299a:	f426                	sd	s1,40(sp)
    8000299c:	f04a                	sd	s2,32(sp)
    8000299e:	ec4e                	sd	s3,24(sp)
    800029a0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800029a2:	fcc40593          	addi	a1,s0,-52
    800029a6:	4501                	li	a0,0
    800029a8:	00000097          	auipc	ra,0x0
    800029ac:	e2c080e7          	jalr	-468(ra) # 800027d4 <argint>
    return -1;
    800029b0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800029b2:	06054563          	bltz	a0,80002a1c <sys_sleep+0x88>
  acquire(&tickslock);
    800029b6:	00015517          	auipc	a0,0x15
    800029ba:	d2a50513          	addi	a0,a0,-726 # 800176e0 <tickslock>
    800029be:	ffffe097          	auipc	ra,0xffffe
    800029c2:	ffe080e7          	jalr	-2(ra) # 800009bc <acquire>
  ticks0 = ticks;
    800029c6:	00025917          	auipc	s2,0x25
    800029ca:	67a92903          	lw	s2,1658(s2) # 80028040 <ticks>
  while(ticks - ticks0 < n){
    800029ce:	fcc42783          	lw	a5,-52(s0)
    800029d2:	cf85                	beqz	a5,80002a0a <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029d4:	00015997          	auipc	s3,0x15
    800029d8:	d0c98993          	addi	s3,s3,-756 # 800176e0 <tickslock>
    800029dc:	00025497          	auipc	s1,0x25
    800029e0:	66448493          	addi	s1,s1,1636 # 80028040 <ticks>
    if(myproc()->killed){
    800029e4:	fffff097          	auipc	ra,0xfffff
    800029e8:	d38080e7          	jalr	-712(ra) # 8000171c <myproc>
    800029ec:	591c                	lw	a5,48(a0)
    800029ee:	ef9d                	bnez	a5,80002a2c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800029f0:	85ce                	mv	a1,s3
    800029f2:	8526                	mv	a0,s1
    800029f4:	fffff097          	auipc	ra,0xfffff
    800029f8:	53e080e7          	jalr	1342(ra) # 80001f32 <sleep>
  while(ticks - ticks0 < n){
    800029fc:	409c                	lw	a5,0(s1)
    800029fe:	412787bb          	subw	a5,a5,s2
    80002a02:	fcc42703          	lw	a4,-52(s0)
    80002a06:	fce7efe3          	bltu	a5,a4,800029e4 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002a0a:	00015517          	auipc	a0,0x15
    80002a0e:	cd650513          	addi	a0,a0,-810 # 800176e0 <tickslock>
    80002a12:	ffffe097          	auipc	ra,0xffffe
    80002a16:	012080e7          	jalr	18(ra) # 80000a24 <release>
  return 0;
    80002a1a:	4781                	li	a5,0
}
    80002a1c:	853e                	mv	a0,a5
    80002a1e:	70e2                	ld	ra,56(sp)
    80002a20:	7442                	ld	s0,48(sp)
    80002a22:	74a2                	ld	s1,40(sp)
    80002a24:	7902                	ld	s2,32(sp)
    80002a26:	69e2                	ld	s3,24(sp)
    80002a28:	6121                	addi	sp,sp,64
    80002a2a:	8082                	ret
      release(&tickslock);
    80002a2c:	00015517          	auipc	a0,0x15
    80002a30:	cb450513          	addi	a0,a0,-844 # 800176e0 <tickslock>
    80002a34:	ffffe097          	auipc	ra,0xffffe
    80002a38:	ff0080e7          	jalr	-16(ra) # 80000a24 <release>
      return -1;
    80002a3c:	57fd                	li	a5,-1
    80002a3e:	bff9                	j	80002a1c <sys_sleep+0x88>

0000000080002a40 <sys_kill>:

uint64
sys_kill(void)
{
    80002a40:	1101                	addi	sp,sp,-32
    80002a42:	ec06                	sd	ra,24(sp)
    80002a44:	e822                	sd	s0,16(sp)
    80002a46:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002a48:	fec40593          	addi	a1,s0,-20
    80002a4c:	4501                	li	a0,0
    80002a4e:	00000097          	auipc	ra,0x0
    80002a52:	d86080e7          	jalr	-634(ra) # 800027d4 <argint>
    80002a56:	87aa                	mv	a5,a0
    return -1;
    80002a58:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002a5a:	0007c863          	bltz	a5,80002a6a <sys_kill+0x2a>
  return kill(pid);
    80002a5e:	fec42503          	lw	a0,-20(s0)
    80002a62:	fffff097          	auipc	ra,0xfffff
    80002a66:	6ba080e7          	jalr	1722(ra) # 8000211c <kill>
}
    80002a6a:	60e2                	ld	ra,24(sp)
    80002a6c:	6442                	ld	s0,16(sp)
    80002a6e:	6105                	addi	sp,sp,32
    80002a70:	8082                	ret

0000000080002a72 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a72:	1101                	addi	sp,sp,-32
    80002a74:	ec06                	sd	ra,24(sp)
    80002a76:	e822                	sd	s0,16(sp)
    80002a78:	e426                	sd	s1,8(sp)
    80002a7a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a7c:	00015517          	auipc	a0,0x15
    80002a80:	c6450513          	addi	a0,a0,-924 # 800176e0 <tickslock>
    80002a84:	ffffe097          	auipc	ra,0xffffe
    80002a88:	f38080e7          	jalr	-200(ra) # 800009bc <acquire>
  xticks = ticks;
    80002a8c:	00025497          	auipc	s1,0x25
    80002a90:	5b44a483          	lw	s1,1460(s1) # 80028040 <ticks>
  release(&tickslock);
    80002a94:	00015517          	auipc	a0,0x15
    80002a98:	c4c50513          	addi	a0,a0,-948 # 800176e0 <tickslock>
    80002a9c:	ffffe097          	auipc	ra,0xffffe
    80002aa0:	f88080e7          	jalr	-120(ra) # 80000a24 <release>
  return xticks;
}
    80002aa4:	02049513          	slli	a0,s1,0x20
    80002aa8:	9101                	srli	a0,a0,0x20
    80002aaa:	60e2                	ld	ra,24(sp)
    80002aac:	6442                	ld	s0,16(sp)
    80002aae:	64a2                	ld	s1,8(sp)
    80002ab0:	6105                	addi	sp,sp,32
    80002ab2:	8082                	ret

0000000080002ab4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ab4:	7179                	addi	sp,sp,-48
    80002ab6:	f406                	sd	ra,40(sp)
    80002ab8:	f022                	sd	s0,32(sp)
    80002aba:	ec26                	sd	s1,24(sp)
    80002abc:	e84a                	sd	s2,16(sp)
    80002abe:	e44e                	sd	s3,8(sp)
    80002ac0:	e052                	sd	s4,0(sp)
    80002ac2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ac4:	00005597          	auipc	a1,0x5
    80002ac8:	9ec58593          	addi	a1,a1,-1556 # 800074b0 <userret+0x420>
    80002acc:	00015517          	auipc	a0,0x15
    80002ad0:	c2c50513          	addi	a0,a0,-980 # 800176f8 <bcache>
    80002ad4:	ffffe097          	auipc	ra,0xffffe
    80002ad8:	dda080e7          	jalr	-550(ra) # 800008ae <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002adc:	0001d797          	auipc	a5,0x1d
    80002ae0:	c1c78793          	addi	a5,a5,-996 # 8001f6f8 <bcache+0x8000>
    80002ae4:	0001d717          	auipc	a4,0x1d
    80002ae8:	f6c70713          	addi	a4,a4,-148 # 8001fa50 <bcache+0x8358>
    80002aec:	3ae7b023          	sd	a4,928(a5)
  bcache.head.next = &bcache.head;
    80002af0:	3ae7b423          	sd	a4,936(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002af4:	00015497          	auipc	s1,0x15
    80002af8:	c1c48493          	addi	s1,s1,-996 # 80017710 <bcache+0x18>
    b->next = bcache.head.next;
    80002afc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002afe:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b00:	00005a17          	auipc	s4,0x5
    80002b04:	9b8a0a13          	addi	s4,s4,-1608 # 800074b8 <userret+0x428>
    b->next = bcache.head.next;
    80002b08:	3a893783          	ld	a5,936(s2)
    80002b0c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b0e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b12:	85d2                	mv	a1,s4
    80002b14:	01048513          	addi	a0,s1,16
    80002b18:	00001097          	auipc	ra,0x1
    80002b1c:	6f2080e7          	jalr	1778(ra) # 8000420a <initsleeplock>
    bcache.head.next->prev = b;
    80002b20:	3a893783          	ld	a5,936(s2)
    80002b24:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b26:	3a993423          	sd	s1,936(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b2a:	46048493          	addi	s1,s1,1120
    80002b2e:	fd349de3          	bne	s1,s3,80002b08 <binit+0x54>
  }
}
    80002b32:	70a2                	ld	ra,40(sp)
    80002b34:	7402                	ld	s0,32(sp)
    80002b36:	64e2                	ld	s1,24(sp)
    80002b38:	6942                	ld	s2,16(sp)
    80002b3a:	69a2                	ld	s3,8(sp)
    80002b3c:	6a02                	ld	s4,0(sp)
    80002b3e:	6145                	addi	sp,sp,48
    80002b40:	8082                	ret

0000000080002b42 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b42:	7179                	addi	sp,sp,-48
    80002b44:	f406                	sd	ra,40(sp)
    80002b46:	f022                	sd	s0,32(sp)
    80002b48:	ec26                	sd	s1,24(sp)
    80002b4a:	e84a                	sd	s2,16(sp)
    80002b4c:	e44e                	sd	s3,8(sp)
    80002b4e:	1800                	addi	s0,sp,48
    80002b50:	892a                	mv	s2,a0
    80002b52:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b54:	00015517          	auipc	a0,0x15
    80002b58:	ba450513          	addi	a0,a0,-1116 # 800176f8 <bcache>
    80002b5c:	ffffe097          	auipc	ra,0xffffe
    80002b60:	e60080e7          	jalr	-416(ra) # 800009bc <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b64:	0001d497          	auipc	s1,0x1d
    80002b68:	f3c4b483          	ld	s1,-196(s1) # 8001faa0 <bcache+0x83a8>
    80002b6c:	0001d797          	auipc	a5,0x1d
    80002b70:	ee478793          	addi	a5,a5,-284 # 8001fa50 <bcache+0x8358>
    80002b74:	02f48f63          	beq	s1,a5,80002bb2 <bread+0x70>
    80002b78:	873e                	mv	a4,a5
    80002b7a:	a021                	j	80002b82 <bread+0x40>
    80002b7c:	68a4                	ld	s1,80(s1)
    80002b7e:	02e48a63          	beq	s1,a4,80002bb2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002b82:	449c                	lw	a5,8(s1)
    80002b84:	ff279ce3          	bne	a5,s2,80002b7c <bread+0x3a>
    80002b88:	44dc                	lw	a5,12(s1)
    80002b8a:	ff3799e3          	bne	a5,s3,80002b7c <bread+0x3a>
      b->refcnt++;
    80002b8e:	40bc                	lw	a5,64(s1)
    80002b90:	2785                	addiw	a5,a5,1
    80002b92:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b94:	00015517          	auipc	a0,0x15
    80002b98:	b6450513          	addi	a0,a0,-1180 # 800176f8 <bcache>
    80002b9c:	ffffe097          	auipc	ra,0xffffe
    80002ba0:	e88080e7          	jalr	-376(ra) # 80000a24 <release>
      acquiresleep(&b->lock);
    80002ba4:	01048513          	addi	a0,s1,16
    80002ba8:	00001097          	auipc	ra,0x1
    80002bac:	69c080e7          	jalr	1692(ra) # 80004244 <acquiresleep>
      return b;
    80002bb0:	a8b9                	j	80002c0e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bb2:	0001d497          	auipc	s1,0x1d
    80002bb6:	ee64b483          	ld	s1,-282(s1) # 8001fa98 <bcache+0x83a0>
    80002bba:	0001d797          	auipc	a5,0x1d
    80002bbe:	e9678793          	addi	a5,a5,-362 # 8001fa50 <bcache+0x8358>
    80002bc2:	00f48863          	beq	s1,a5,80002bd2 <bread+0x90>
    80002bc6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002bc8:	40bc                	lw	a5,64(s1)
    80002bca:	cf81                	beqz	a5,80002be2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bcc:	64a4                	ld	s1,72(s1)
    80002bce:	fee49de3          	bne	s1,a4,80002bc8 <bread+0x86>
  panic("bget: no buffers");
    80002bd2:	00005517          	auipc	a0,0x5
    80002bd6:	8ee50513          	addi	a0,a0,-1810 # 800074c0 <userret+0x430>
    80002bda:	ffffe097          	auipc	ra,0xffffe
    80002bde:	96e080e7          	jalr	-1682(ra) # 80000548 <panic>
      b->dev = dev;
    80002be2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002be6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002bea:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002bee:	4785                	li	a5,1
    80002bf0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bf2:	00015517          	auipc	a0,0x15
    80002bf6:	b0650513          	addi	a0,a0,-1274 # 800176f8 <bcache>
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	e2a080e7          	jalr	-470(ra) # 80000a24 <release>
      acquiresleep(&b->lock);
    80002c02:	01048513          	addi	a0,s1,16
    80002c06:	00001097          	auipc	ra,0x1
    80002c0a:	63e080e7          	jalr	1598(ra) # 80004244 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c0e:	409c                	lw	a5,0(s1)
    80002c10:	cb89                	beqz	a5,80002c22 <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c12:	8526                	mv	a0,s1
    80002c14:	70a2                	ld	ra,40(sp)
    80002c16:	7402                	ld	s0,32(sp)
    80002c18:	64e2                	ld	s1,24(sp)
    80002c1a:	6942                	ld	s2,16(sp)
    80002c1c:	69a2                	ld	s3,8(sp)
    80002c1e:	6145                	addi	sp,sp,48
    80002c20:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    80002c22:	4601                	li	a2,0
    80002c24:	85a6                	mv	a1,s1
    80002c26:	4488                	lw	a0,8(s1)
    80002c28:	00003097          	auipc	ra,0x3
    80002c2c:	2a4080e7          	jalr	676(ra) # 80005ecc <virtio_disk_rw>
    b->valid = 1;
    80002c30:	4785                	li	a5,1
    80002c32:	c09c                	sw	a5,0(s1)
  return b;
    80002c34:	bff9                	j	80002c12 <bread+0xd0>

0000000080002c36 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c36:	1101                	addi	sp,sp,-32
    80002c38:	ec06                	sd	ra,24(sp)
    80002c3a:	e822                	sd	s0,16(sp)
    80002c3c:	e426                	sd	s1,8(sp)
    80002c3e:	1000                	addi	s0,sp,32
    80002c40:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c42:	0541                	addi	a0,a0,16
    80002c44:	00001097          	auipc	ra,0x1
    80002c48:	69a080e7          	jalr	1690(ra) # 800042de <holdingsleep>
    80002c4c:	cd09                	beqz	a0,80002c66 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80002c4e:	4605                	li	a2,1
    80002c50:	85a6                	mv	a1,s1
    80002c52:	4488                	lw	a0,8(s1)
    80002c54:	00003097          	auipc	ra,0x3
    80002c58:	278080e7          	jalr	632(ra) # 80005ecc <virtio_disk_rw>
}
    80002c5c:	60e2                	ld	ra,24(sp)
    80002c5e:	6442                	ld	s0,16(sp)
    80002c60:	64a2                	ld	s1,8(sp)
    80002c62:	6105                	addi	sp,sp,32
    80002c64:	8082                	ret
    panic("bwrite");
    80002c66:	00005517          	auipc	a0,0x5
    80002c6a:	87250513          	addi	a0,a0,-1934 # 800074d8 <userret+0x448>
    80002c6e:	ffffe097          	auipc	ra,0xffffe
    80002c72:	8da080e7          	jalr	-1830(ra) # 80000548 <panic>

0000000080002c76 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80002c76:	1101                	addi	sp,sp,-32
    80002c78:	ec06                	sd	ra,24(sp)
    80002c7a:	e822                	sd	s0,16(sp)
    80002c7c:	e426                	sd	s1,8(sp)
    80002c7e:	e04a                	sd	s2,0(sp)
    80002c80:	1000                	addi	s0,sp,32
    80002c82:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c84:	01050913          	addi	s2,a0,16
    80002c88:	854a                	mv	a0,s2
    80002c8a:	00001097          	auipc	ra,0x1
    80002c8e:	654080e7          	jalr	1620(ra) # 800042de <holdingsleep>
    80002c92:	c92d                	beqz	a0,80002d04 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002c94:	854a                	mv	a0,s2
    80002c96:	00001097          	auipc	ra,0x1
    80002c9a:	604080e7          	jalr	1540(ra) # 8000429a <releasesleep>

  acquire(&bcache.lock);
    80002c9e:	00015517          	auipc	a0,0x15
    80002ca2:	a5a50513          	addi	a0,a0,-1446 # 800176f8 <bcache>
    80002ca6:	ffffe097          	auipc	ra,0xffffe
    80002caa:	d16080e7          	jalr	-746(ra) # 800009bc <acquire>
  b->refcnt--;
    80002cae:	40bc                	lw	a5,64(s1)
    80002cb0:	37fd                	addiw	a5,a5,-1
    80002cb2:	0007871b          	sext.w	a4,a5
    80002cb6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002cb8:	eb05                	bnez	a4,80002ce8 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002cba:	68bc                	ld	a5,80(s1)
    80002cbc:	64b8                	ld	a4,72(s1)
    80002cbe:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002cc0:	64bc                	ld	a5,72(s1)
    80002cc2:	68b8                	ld	a4,80(s1)
    80002cc4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002cc6:	0001d797          	auipc	a5,0x1d
    80002cca:	a3278793          	addi	a5,a5,-1486 # 8001f6f8 <bcache+0x8000>
    80002cce:	3a87b703          	ld	a4,936(a5)
    80002cd2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002cd4:	0001d717          	auipc	a4,0x1d
    80002cd8:	d7c70713          	addi	a4,a4,-644 # 8001fa50 <bcache+0x8358>
    80002cdc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002cde:	3a87b703          	ld	a4,936(a5)
    80002ce2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ce4:	3a97b423          	sd	s1,936(a5)
  }
  
  release(&bcache.lock);
    80002ce8:	00015517          	auipc	a0,0x15
    80002cec:	a1050513          	addi	a0,a0,-1520 # 800176f8 <bcache>
    80002cf0:	ffffe097          	auipc	ra,0xffffe
    80002cf4:	d34080e7          	jalr	-716(ra) # 80000a24 <release>
}
    80002cf8:	60e2                	ld	ra,24(sp)
    80002cfa:	6442                	ld	s0,16(sp)
    80002cfc:	64a2                	ld	s1,8(sp)
    80002cfe:	6902                	ld	s2,0(sp)
    80002d00:	6105                	addi	sp,sp,32
    80002d02:	8082                	ret
    panic("brelse");
    80002d04:	00004517          	auipc	a0,0x4
    80002d08:	7dc50513          	addi	a0,a0,2012 # 800074e0 <userret+0x450>
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	83c080e7          	jalr	-1988(ra) # 80000548 <panic>

0000000080002d14 <bpin>:

void
bpin(struct buf *b) {
    80002d14:	1101                	addi	sp,sp,-32
    80002d16:	ec06                	sd	ra,24(sp)
    80002d18:	e822                	sd	s0,16(sp)
    80002d1a:	e426                	sd	s1,8(sp)
    80002d1c:	1000                	addi	s0,sp,32
    80002d1e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d20:	00015517          	auipc	a0,0x15
    80002d24:	9d850513          	addi	a0,a0,-1576 # 800176f8 <bcache>
    80002d28:	ffffe097          	auipc	ra,0xffffe
    80002d2c:	c94080e7          	jalr	-876(ra) # 800009bc <acquire>
  b->refcnt++;
    80002d30:	40bc                	lw	a5,64(s1)
    80002d32:	2785                	addiw	a5,a5,1
    80002d34:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d36:	00015517          	auipc	a0,0x15
    80002d3a:	9c250513          	addi	a0,a0,-1598 # 800176f8 <bcache>
    80002d3e:	ffffe097          	auipc	ra,0xffffe
    80002d42:	ce6080e7          	jalr	-794(ra) # 80000a24 <release>
}
    80002d46:	60e2                	ld	ra,24(sp)
    80002d48:	6442                	ld	s0,16(sp)
    80002d4a:	64a2                	ld	s1,8(sp)
    80002d4c:	6105                	addi	sp,sp,32
    80002d4e:	8082                	ret

0000000080002d50 <bunpin>:

void
bunpin(struct buf *b) {
    80002d50:	1101                	addi	sp,sp,-32
    80002d52:	ec06                	sd	ra,24(sp)
    80002d54:	e822                	sd	s0,16(sp)
    80002d56:	e426                	sd	s1,8(sp)
    80002d58:	1000                	addi	s0,sp,32
    80002d5a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d5c:	00015517          	auipc	a0,0x15
    80002d60:	99c50513          	addi	a0,a0,-1636 # 800176f8 <bcache>
    80002d64:	ffffe097          	auipc	ra,0xffffe
    80002d68:	c58080e7          	jalr	-936(ra) # 800009bc <acquire>
  b->refcnt--;
    80002d6c:	40bc                	lw	a5,64(s1)
    80002d6e:	37fd                	addiw	a5,a5,-1
    80002d70:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d72:	00015517          	auipc	a0,0x15
    80002d76:	98650513          	addi	a0,a0,-1658 # 800176f8 <bcache>
    80002d7a:	ffffe097          	auipc	ra,0xffffe
    80002d7e:	caa080e7          	jalr	-854(ra) # 80000a24 <release>
}
    80002d82:	60e2                	ld	ra,24(sp)
    80002d84:	6442                	ld	s0,16(sp)
    80002d86:	64a2                	ld	s1,8(sp)
    80002d88:	6105                	addi	sp,sp,32
    80002d8a:	8082                	ret

0000000080002d8c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d8c:	1101                	addi	sp,sp,-32
    80002d8e:	ec06                	sd	ra,24(sp)
    80002d90:	e822                	sd	s0,16(sp)
    80002d92:	e426                	sd	s1,8(sp)
    80002d94:	e04a                	sd	s2,0(sp)
    80002d96:	1000                	addi	s0,sp,32
    80002d98:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d9a:	00d5d59b          	srliw	a1,a1,0xd
    80002d9e:	0001d797          	auipc	a5,0x1d
    80002da2:	12e7a783          	lw	a5,302(a5) # 8001fecc <sb+0x1c>
    80002da6:	9dbd                	addw	a1,a1,a5
    80002da8:	00000097          	auipc	ra,0x0
    80002dac:	d9a080e7          	jalr	-614(ra) # 80002b42 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002db0:	0074f713          	andi	a4,s1,7
    80002db4:	4785                	li	a5,1
    80002db6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002dba:	14ce                	slli	s1,s1,0x33
    80002dbc:	90d9                	srli	s1,s1,0x36
    80002dbe:	00950733          	add	a4,a0,s1
    80002dc2:	06074703          	lbu	a4,96(a4)
    80002dc6:	00e7f6b3          	and	a3,a5,a4
    80002dca:	c69d                	beqz	a3,80002df8 <bfree+0x6c>
    80002dcc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002dce:	94aa                	add	s1,s1,a0
    80002dd0:	fff7c793          	not	a5,a5
    80002dd4:	8ff9                	and	a5,a5,a4
    80002dd6:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80002dda:	00001097          	auipc	ra,0x1
    80002dde:	1d2080e7          	jalr	466(ra) # 80003fac <log_write>
  brelse(bp);
    80002de2:	854a                	mv	a0,s2
    80002de4:	00000097          	auipc	ra,0x0
    80002de8:	e92080e7          	jalr	-366(ra) # 80002c76 <brelse>
}
    80002dec:	60e2                	ld	ra,24(sp)
    80002dee:	6442                	ld	s0,16(sp)
    80002df0:	64a2                	ld	s1,8(sp)
    80002df2:	6902                	ld	s2,0(sp)
    80002df4:	6105                	addi	sp,sp,32
    80002df6:	8082                	ret
    panic("freeing free block");
    80002df8:	00004517          	auipc	a0,0x4
    80002dfc:	6f050513          	addi	a0,a0,1776 # 800074e8 <userret+0x458>
    80002e00:	ffffd097          	auipc	ra,0xffffd
    80002e04:	748080e7          	jalr	1864(ra) # 80000548 <panic>

0000000080002e08 <balloc>:
{
    80002e08:	711d                	addi	sp,sp,-96
    80002e0a:	ec86                	sd	ra,88(sp)
    80002e0c:	e8a2                	sd	s0,80(sp)
    80002e0e:	e4a6                	sd	s1,72(sp)
    80002e10:	e0ca                	sd	s2,64(sp)
    80002e12:	fc4e                	sd	s3,56(sp)
    80002e14:	f852                	sd	s4,48(sp)
    80002e16:	f456                	sd	s5,40(sp)
    80002e18:	f05a                	sd	s6,32(sp)
    80002e1a:	ec5e                	sd	s7,24(sp)
    80002e1c:	e862                	sd	s8,16(sp)
    80002e1e:	e466                	sd	s9,8(sp)
    80002e20:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002e22:	0001d797          	auipc	a5,0x1d
    80002e26:	0927a783          	lw	a5,146(a5) # 8001feb4 <sb+0x4>
    80002e2a:	cbd1                	beqz	a5,80002ebe <balloc+0xb6>
    80002e2c:	8baa                	mv	s7,a0
    80002e2e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e30:	0001db17          	auipc	s6,0x1d
    80002e34:	080b0b13          	addi	s6,s6,128 # 8001feb0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e38:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002e3a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e3c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e3e:	6c89                	lui	s9,0x2
    80002e40:	a831                	j	80002e5c <balloc+0x54>
    brelse(bp);
    80002e42:	854a                	mv	a0,s2
    80002e44:	00000097          	auipc	ra,0x0
    80002e48:	e32080e7          	jalr	-462(ra) # 80002c76 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e4c:	015c87bb          	addw	a5,s9,s5
    80002e50:	00078a9b          	sext.w	s5,a5
    80002e54:	004b2703          	lw	a4,4(s6)
    80002e58:	06eaf363          	bgeu	s5,a4,80002ebe <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80002e5c:	41fad79b          	sraiw	a5,s5,0x1f
    80002e60:	0137d79b          	srliw	a5,a5,0x13
    80002e64:	015787bb          	addw	a5,a5,s5
    80002e68:	40d7d79b          	sraiw	a5,a5,0xd
    80002e6c:	01cb2583          	lw	a1,28(s6)
    80002e70:	9dbd                	addw	a1,a1,a5
    80002e72:	855e                	mv	a0,s7
    80002e74:	00000097          	auipc	ra,0x0
    80002e78:	cce080e7          	jalr	-818(ra) # 80002b42 <bread>
    80002e7c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e7e:	004b2503          	lw	a0,4(s6)
    80002e82:	000a849b          	sext.w	s1,s5
    80002e86:	8662                	mv	a2,s8
    80002e88:	faa4fde3          	bgeu	s1,a0,80002e42 <balloc+0x3a>
      m = 1 << (bi % 8);
    80002e8c:	41f6579b          	sraiw	a5,a2,0x1f
    80002e90:	01d7d69b          	srliw	a3,a5,0x1d
    80002e94:	00c6873b          	addw	a4,a3,a2
    80002e98:	00777793          	andi	a5,a4,7
    80002e9c:	9f95                	subw	a5,a5,a3
    80002e9e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002ea2:	4037571b          	sraiw	a4,a4,0x3
    80002ea6:	00e906b3          	add	a3,s2,a4
    80002eaa:	0606c683          	lbu	a3,96(a3)
    80002eae:	00d7f5b3          	and	a1,a5,a3
    80002eb2:	cd91                	beqz	a1,80002ece <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002eb4:	2605                	addiw	a2,a2,1
    80002eb6:	2485                	addiw	s1,s1,1
    80002eb8:	fd4618e3          	bne	a2,s4,80002e88 <balloc+0x80>
    80002ebc:	b759                	j	80002e42 <balloc+0x3a>
  panic("balloc: out of blocks");
    80002ebe:	00004517          	auipc	a0,0x4
    80002ec2:	64250513          	addi	a0,a0,1602 # 80007500 <userret+0x470>
    80002ec6:	ffffd097          	auipc	ra,0xffffd
    80002eca:	682080e7          	jalr	1666(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002ece:	974a                	add	a4,a4,s2
    80002ed0:	8fd5                	or	a5,a5,a3
    80002ed2:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    80002ed6:	854a                	mv	a0,s2
    80002ed8:	00001097          	auipc	ra,0x1
    80002edc:	0d4080e7          	jalr	212(ra) # 80003fac <log_write>
        brelse(bp);
    80002ee0:	854a                	mv	a0,s2
    80002ee2:	00000097          	auipc	ra,0x0
    80002ee6:	d94080e7          	jalr	-620(ra) # 80002c76 <brelse>
  bp = bread(dev, bno);
    80002eea:	85a6                	mv	a1,s1
    80002eec:	855e                	mv	a0,s7
    80002eee:	00000097          	auipc	ra,0x0
    80002ef2:	c54080e7          	jalr	-940(ra) # 80002b42 <bread>
    80002ef6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ef8:	40000613          	li	a2,1024
    80002efc:	4581                	li	a1,0
    80002efe:	06050513          	addi	a0,a0,96
    80002f02:	ffffe097          	auipc	ra,0xffffe
    80002f06:	b7e080e7          	jalr	-1154(ra) # 80000a80 <memset>
  log_write(bp);
    80002f0a:	854a                	mv	a0,s2
    80002f0c:	00001097          	auipc	ra,0x1
    80002f10:	0a0080e7          	jalr	160(ra) # 80003fac <log_write>
  brelse(bp);
    80002f14:	854a                	mv	a0,s2
    80002f16:	00000097          	auipc	ra,0x0
    80002f1a:	d60080e7          	jalr	-672(ra) # 80002c76 <brelse>
}
    80002f1e:	8526                	mv	a0,s1
    80002f20:	60e6                	ld	ra,88(sp)
    80002f22:	6446                	ld	s0,80(sp)
    80002f24:	64a6                	ld	s1,72(sp)
    80002f26:	6906                	ld	s2,64(sp)
    80002f28:	79e2                	ld	s3,56(sp)
    80002f2a:	7a42                	ld	s4,48(sp)
    80002f2c:	7aa2                	ld	s5,40(sp)
    80002f2e:	7b02                	ld	s6,32(sp)
    80002f30:	6be2                	ld	s7,24(sp)
    80002f32:	6c42                	ld	s8,16(sp)
    80002f34:	6ca2                	ld	s9,8(sp)
    80002f36:	6125                	addi	sp,sp,96
    80002f38:	8082                	ret

0000000080002f3a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f3a:	7179                	addi	sp,sp,-48
    80002f3c:	f406                	sd	ra,40(sp)
    80002f3e:	f022                	sd	s0,32(sp)
    80002f40:	ec26                	sd	s1,24(sp)
    80002f42:	e84a                	sd	s2,16(sp)
    80002f44:	e44e                	sd	s3,8(sp)
    80002f46:	e052                	sd	s4,0(sp)
    80002f48:	1800                	addi	s0,sp,48
    80002f4a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f4c:	47ad                	li	a5,11
    80002f4e:	04b7fe63          	bgeu	a5,a1,80002faa <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80002f52:	ff45849b          	addiw	s1,a1,-12
    80002f56:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002f5a:	0ff00793          	li	a5,255
    80002f5e:	0ae7e363          	bltu	a5,a4,80003004 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80002f62:	08052583          	lw	a1,128(a0)
    80002f66:	c5ad                	beqz	a1,80002fd0 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80002f68:	00092503          	lw	a0,0(s2)
    80002f6c:	00000097          	auipc	ra,0x0
    80002f70:	bd6080e7          	jalr	-1066(ra) # 80002b42 <bread>
    80002f74:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f76:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80002f7a:	02049593          	slli	a1,s1,0x20
    80002f7e:	9181                	srli	a1,a1,0x20
    80002f80:	058a                	slli	a1,a1,0x2
    80002f82:	00b784b3          	add	s1,a5,a1
    80002f86:	0004a983          	lw	s3,0(s1)
    80002f8a:	04098d63          	beqz	s3,80002fe4 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80002f8e:	8552                	mv	a0,s4
    80002f90:	00000097          	auipc	ra,0x0
    80002f94:	ce6080e7          	jalr	-794(ra) # 80002c76 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002f98:	854e                	mv	a0,s3
    80002f9a:	70a2                	ld	ra,40(sp)
    80002f9c:	7402                	ld	s0,32(sp)
    80002f9e:	64e2                	ld	s1,24(sp)
    80002fa0:	6942                	ld	s2,16(sp)
    80002fa2:	69a2                	ld	s3,8(sp)
    80002fa4:	6a02                	ld	s4,0(sp)
    80002fa6:	6145                	addi	sp,sp,48
    80002fa8:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80002faa:	02059493          	slli	s1,a1,0x20
    80002fae:	9081                	srli	s1,s1,0x20
    80002fb0:	048a                	slli	s1,s1,0x2
    80002fb2:	94aa                	add	s1,s1,a0
    80002fb4:	0504a983          	lw	s3,80(s1)
    80002fb8:	fe0990e3          	bnez	s3,80002f98 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80002fbc:	4108                	lw	a0,0(a0)
    80002fbe:	00000097          	auipc	ra,0x0
    80002fc2:	e4a080e7          	jalr	-438(ra) # 80002e08 <balloc>
    80002fc6:	0005099b          	sext.w	s3,a0
    80002fca:	0534a823          	sw	s3,80(s1)
    80002fce:	b7e9                	j	80002f98 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80002fd0:	4108                	lw	a0,0(a0)
    80002fd2:	00000097          	auipc	ra,0x0
    80002fd6:	e36080e7          	jalr	-458(ra) # 80002e08 <balloc>
    80002fda:	0005059b          	sext.w	a1,a0
    80002fde:	08b92023          	sw	a1,128(s2)
    80002fe2:	b759                	j	80002f68 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80002fe4:	00092503          	lw	a0,0(s2)
    80002fe8:	00000097          	auipc	ra,0x0
    80002fec:	e20080e7          	jalr	-480(ra) # 80002e08 <balloc>
    80002ff0:	0005099b          	sext.w	s3,a0
    80002ff4:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80002ff8:	8552                	mv	a0,s4
    80002ffa:	00001097          	auipc	ra,0x1
    80002ffe:	fb2080e7          	jalr	-78(ra) # 80003fac <log_write>
    80003002:	b771                	j	80002f8e <bmap+0x54>
  panic("bmap: out of range");
    80003004:	00004517          	auipc	a0,0x4
    80003008:	51450513          	addi	a0,a0,1300 # 80007518 <userret+0x488>
    8000300c:	ffffd097          	auipc	ra,0xffffd
    80003010:	53c080e7          	jalr	1340(ra) # 80000548 <panic>

0000000080003014 <iget>:
{
    80003014:	7179                	addi	sp,sp,-48
    80003016:	f406                	sd	ra,40(sp)
    80003018:	f022                	sd	s0,32(sp)
    8000301a:	ec26                	sd	s1,24(sp)
    8000301c:	e84a                	sd	s2,16(sp)
    8000301e:	e44e                	sd	s3,8(sp)
    80003020:	e052                	sd	s4,0(sp)
    80003022:	1800                	addi	s0,sp,48
    80003024:	89aa                	mv	s3,a0
    80003026:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003028:	0001d517          	auipc	a0,0x1d
    8000302c:	ea850513          	addi	a0,a0,-344 # 8001fed0 <icache>
    80003030:	ffffe097          	auipc	ra,0xffffe
    80003034:	98c080e7          	jalr	-1652(ra) # 800009bc <acquire>
  empty = 0;
    80003038:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000303a:	0001d497          	auipc	s1,0x1d
    8000303e:	eae48493          	addi	s1,s1,-338 # 8001fee8 <icache+0x18>
    80003042:	0001f697          	auipc	a3,0x1f
    80003046:	93668693          	addi	a3,a3,-1738 # 80021978 <log>
    8000304a:	a039                	j	80003058 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000304c:	02090b63          	beqz	s2,80003082 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003050:	08848493          	addi	s1,s1,136
    80003054:	02d48a63          	beq	s1,a3,80003088 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003058:	449c                	lw	a5,8(s1)
    8000305a:	fef059e3          	blez	a5,8000304c <iget+0x38>
    8000305e:	4098                	lw	a4,0(s1)
    80003060:	ff3716e3          	bne	a4,s3,8000304c <iget+0x38>
    80003064:	40d8                	lw	a4,4(s1)
    80003066:	ff4713e3          	bne	a4,s4,8000304c <iget+0x38>
      ip->ref++;
    8000306a:	2785                	addiw	a5,a5,1
    8000306c:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000306e:	0001d517          	auipc	a0,0x1d
    80003072:	e6250513          	addi	a0,a0,-414 # 8001fed0 <icache>
    80003076:	ffffe097          	auipc	ra,0xffffe
    8000307a:	9ae080e7          	jalr	-1618(ra) # 80000a24 <release>
      return ip;
    8000307e:	8926                	mv	s2,s1
    80003080:	a03d                	j	800030ae <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003082:	f7f9                	bnez	a5,80003050 <iget+0x3c>
    80003084:	8926                	mv	s2,s1
    80003086:	b7e9                	j	80003050 <iget+0x3c>
  if(empty == 0)
    80003088:	02090c63          	beqz	s2,800030c0 <iget+0xac>
  ip->dev = dev;
    8000308c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003090:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003094:	4785                	li	a5,1
    80003096:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000309a:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    8000309e:	0001d517          	auipc	a0,0x1d
    800030a2:	e3250513          	addi	a0,a0,-462 # 8001fed0 <icache>
    800030a6:	ffffe097          	auipc	ra,0xffffe
    800030aa:	97e080e7          	jalr	-1666(ra) # 80000a24 <release>
}
    800030ae:	854a                	mv	a0,s2
    800030b0:	70a2                	ld	ra,40(sp)
    800030b2:	7402                	ld	s0,32(sp)
    800030b4:	64e2                	ld	s1,24(sp)
    800030b6:	6942                	ld	s2,16(sp)
    800030b8:	69a2                	ld	s3,8(sp)
    800030ba:	6a02                	ld	s4,0(sp)
    800030bc:	6145                	addi	sp,sp,48
    800030be:	8082                	ret
    panic("iget: no inodes");
    800030c0:	00004517          	auipc	a0,0x4
    800030c4:	47050513          	addi	a0,a0,1136 # 80007530 <userret+0x4a0>
    800030c8:	ffffd097          	auipc	ra,0xffffd
    800030cc:	480080e7          	jalr	1152(ra) # 80000548 <panic>

00000000800030d0 <fsinit>:
fsinit(int dev) {
    800030d0:	7179                	addi	sp,sp,-48
    800030d2:	f406                	sd	ra,40(sp)
    800030d4:	f022                	sd	s0,32(sp)
    800030d6:	ec26                	sd	s1,24(sp)
    800030d8:	e84a                	sd	s2,16(sp)
    800030da:	e44e                	sd	s3,8(sp)
    800030dc:	1800                	addi	s0,sp,48
    800030de:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800030e0:	4585                	li	a1,1
    800030e2:	00000097          	auipc	ra,0x0
    800030e6:	a60080e7          	jalr	-1440(ra) # 80002b42 <bread>
    800030ea:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800030ec:	0001d997          	auipc	s3,0x1d
    800030f0:	dc498993          	addi	s3,s3,-572 # 8001feb0 <sb>
    800030f4:	02000613          	li	a2,32
    800030f8:	06050593          	addi	a1,a0,96
    800030fc:	854e                	mv	a0,s3
    800030fe:	ffffe097          	auipc	ra,0xffffe
    80003102:	9de080e7          	jalr	-1570(ra) # 80000adc <memmove>
  brelse(bp);
    80003106:	8526                	mv	a0,s1
    80003108:	00000097          	auipc	ra,0x0
    8000310c:	b6e080e7          	jalr	-1170(ra) # 80002c76 <brelse>
  if(sb.magic != FSMAGIC)
    80003110:	0009a703          	lw	a4,0(s3)
    80003114:	102037b7          	lui	a5,0x10203
    80003118:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000311c:	02f71263          	bne	a4,a5,80003140 <fsinit+0x70>
  initlog(dev, &sb);
    80003120:	0001d597          	auipc	a1,0x1d
    80003124:	d9058593          	addi	a1,a1,-624 # 8001feb0 <sb>
    80003128:	854a                	mv	a0,s2
    8000312a:	00001097          	auipc	ra,0x1
    8000312e:	bfc080e7          	jalr	-1028(ra) # 80003d26 <initlog>
}
    80003132:	70a2                	ld	ra,40(sp)
    80003134:	7402                	ld	s0,32(sp)
    80003136:	64e2                	ld	s1,24(sp)
    80003138:	6942                	ld	s2,16(sp)
    8000313a:	69a2                	ld	s3,8(sp)
    8000313c:	6145                	addi	sp,sp,48
    8000313e:	8082                	ret
    panic("invalid file system");
    80003140:	00004517          	auipc	a0,0x4
    80003144:	40050513          	addi	a0,a0,1024 # 80007540 <userret+0x4b0>
    80003148:	ffffd097          	auipc	ra,0xffffd
    8000314c:	400080e7          	jalr	1024(ra) # 80000548 <panic>

0000000080003150 <iinit>:
{
    80003150:	7179                	addi	sp,sp,-48
    80003152:	f406                	sd	ra,40(sp)
    80003154:	f022                	sd	s0,32(sp)
    80003156:	ec26                	sd	s1,24(sp)
    80003158:	e84a                	sd	s2,16(sp)
    8000315a:	e44e                	sd	s3,8(sp)
    8000315c:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000315e:	00004597          	auipc	a1,0x4
    80003162:	3fa58593          	addi	a1,a1,1018 # 80007558 <userret+0x4c8>
    80003166:	0001d517          	auipc	a0,0x1d
    8000316a:	d6a50513          	addi	a0,a0,-662 # 8001fed0 <icache>
    8000316e:	ffffd097          	auipc	ra,0xffffd
    80003172:	740080e7          	jalr	1856(ra) # 800008ae <initlock>
  for(i = 0; i < NINODE; i++) {
    80003176:	0001d497          	auipc	s1,0x1d
    8000317a:	d8248493          	addi	s1,s1,-638 # 8001fef8 <icache+0x28>
    8000317e:	0001f997          	auipc	s3,0x1f
    80003182:	80a98993          	addi	s3,s3,-2038 # 80021988 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003186:	00004917          	auipc	s2,0x4
    8000318a:	3da90913          	addi	s2,s2,986 # 80007560 <userret+0x4d0>
    8000318e:	85ca                	mv	a1,s2
    80003190:	8526                	mv	a0,s1
    80003192:	00001097          	auipc	ra,0x1
    80003196:	078080e7          	jalr	120(ra) # 8000420a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000319a:	08848493          	addi	s1,s1,136
    8000319e:	ff3498e3          	bne	s1,s3,8000318e <iinit+0x3e>
}
    800031a2:	70a2                	ld	ra,40(sp)
    800031a4:	7402                	ld	s0,32(sp)
    800031a6:	64e2                	ld	s1,24(sp)
    800031a8:	6942                	ld	s2,16(sp)
    800031aa:	69a2                	ld	s3,8(sp)
    800031ac:	6145                	addi	sp,sp,48
    800031ae:	8082                	ret

00000000800031b0 <ialloc>:
{
    800031b0:	715d                	addi	sp,sp,-80
    800031b2:	e486                	sd	ra,72(sp)
    800031b4:	e0a2                	sd	s0,64(sp)
    800031b6:	fc26                	sd	s1,56(sp)
    800031b8:	f84a                	sd	s2,48(sp)
    800031ba:	f44e                	sd	s3,40(sp)
    800031bc:	f052                	sd	s4,32(sp)
    800031be:	ec56                	sd	s5,24(sp)
    800031c0:	e85a                	sd	s6,16(sp)
    800031c2:	e45e                	sd	s7,8(sp)
    800031c4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800031c6:	0001d717          	auipc	a4,0x1d
    800031ca:	cf672703          	lw	a4,-778(a4) # 8001febc <sb+0xc>
    800031ce:	4785                	li	a5,1
    800031d0:	04e7fa63          	bgeu	a5,a4,80003224 <ialloc+0x74>
    800031d4:	8aaa                	mv	s5,a0
    800031d6:	8bae                	mv	s7,a1
    800031d8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800031da:	0001da17          	auipc	s4,0x1d
    800031de:	cd6a0a13          	addi	s4,s4,-810 # 8001feb0 <sb>
    800031e2:	00048b1b          	sext.w	s6,s1
    800031e6:	0044d793          	srli	a5,s1,0x4
    800031ea:	018a2583          	lw	a1,24(s4)
    800031ee:	9dbd                	addw	a1,a1,a5
    800031f0:	8556                	mv	a0,s5
    800031f2:	00000097          	auipc	ra,0x0
    800031f6:	950080e7          	jalr	-1712(ra) # 80002b42 <bread>
    800031fa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800031fc:	06050993          	addi	s3,a0,96
    80003200:	00f4f793          	andi	a5,s1,15
    80003204:	079a                	slli	a5,a5,0x6
    80003206:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003208:	00099783          	lh	a5,0(s3)
    8000320c:	c785                	beqz	a5,80003234 <ialloc+0x84>
    brelse(bp);
    8000320e:	00000097          	auipc	ra,0x0
    80003212:	a68080e7          	jalr	-1432(ra) # 80002c76 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003216:	0485                	addi	s1,s1,1
    80003218:	00ca2703          	lw	a4,12(s4)
    8000321c:	0004879b          	sext.w	a5,s1
    80003220:	fce7e1e3          	bltu	a5,a4,800031e2 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003224:	00004517          	auipc	a0,0x4
    80003228:	34450513          	addi	a0,a0,836 # 80007568 <userret+0x4d8>
    8000322c:	ffffd097          	auipc	ra,0xffffd
    80003230:	31c080e7          	jalr	796(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    80003234:	04000613          	li	a2,64
    80003238:	4581                	li	a1,0
    8000323a:	854e                	mv	a0,s3
    8000323c:	ffffe097          	auipc	ra,0xffffe
    80003240:	844080e7          	jalr	-1980(ra) # 80000a80 <memset>
      dip->type = type;
    80003244:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003248:	854a                	mv	a0,s2
    8000324a:	00001097          	auipc	ra,0x1
    8000324e:	d62080e7          	jalr	-670(ra) # 80003fac <log_write>
      brelse(bp);
    80003252:	854a                	mv	a0,s2
    80003254:	00000097          	auipc	ra,0x0
    80003258:	a22080e7          	jalr	-1502(ra) # 80002c76 <brelse>
      return iget(dev, inum);
    8000325c:	85da                	mv	a1,s6
    8000325e:	8556                	mv	a0,s5
    80003260:	00000097          	auipc	ra,0x0
    80003264:	db4080e7          	jalr	-588(ra) # 80003014 <iget>
}
    80003268:	60a6                	ld	ra,72(sp)
    8000326a:	6406                	ld	s0,64(sp)
    8000326c:	74e2                	ld	s1,56(sp)
    8000326e:	7942                	ld	s2,48(sp)
    80003270:	79a2                	ld	s3,40(sp)
    80003272:	7a02                	ld	s4,32(sp)
    80003274:	6ae2                	ld	s5,24(sp)
    80003276:	6b42                	ld	s6,16(sp)
    80003278:	6ba2                	ld	s7,8(sp)
    8000327a:	6161                	addi	sp,sp,80
    8000327c:	8082                	ret

000000008000327e <iupdate>:
{
    8000327e:	1101                	addi	sp,sp,-32
    80003280:	ec06                	sd	ra,24(sp)
    80003282:	e822                	sd	s0,16(sp)
    80003284:	e426                	sd	s1,8(sp)
    80003286:	e04a                	sd	s2,0(sp)
    80003288:	1000                	addi	s0,sp,32
    8000328a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000328c:	415c                	lw	a5,4(a0)
    8000328e:	0047d79b          	srliw	a5,a5,0x4
    80003292:	0001d597          	auipc	a1,0x1d
    80003296:	c365a583          	lw	a1,-970(a1) # 8001fec8 <sb+0x18>
    8000329a:	9dbd                	addw	a1,a1,a5
    8000329c:	4108                	lw	a0,0(a0)
    8000329e:	00000097          	auipc	ra,0x0
    800032a2:	8a4080e7          	jalr	-1884(ra) # 80002b42 <bread>
    800032a6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032a8:	06050793          	addi	a5,a0,96
    800032ac:	40c8                	lw	a0,4(s1)
    800032ae:	893d                	andi	a0,a0,15
    800032b0:	051a                	slli	a0,a0,0x6
    800032b2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800032b4:	04449703          	lh	a4,68(s1)
    800032b8:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800032bc:	04649703          	lh	a4,70(s1)
    800032c0:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800032c4:	04849703          	lh	a4,72(s1)
    800032c8:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800032cc:	04a49703          	lh	a4,74(s1)
    800032d0:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800032d4:	44f8                	lw	a4,76(s1)
    800032d6:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800032d8:	03400613          	li	a2,52
    800032dc:	05048593          	addi	a1,s1,80
    800032e0:	0531                	addi	a0,a0,12
    800032e2:	ffffd097          	auipc	ra,0xffffd
    800032e6:	7fa080e7          	jalr	2042(ra) # 80000adc <memmove>
  log_write(bp);
    800032ea:	854a                	mv	a0,s2
    800032ec:	00001097          	auipc	ra,0x1
    800032f0:	cc0080e7          	jalr	-832(ra) # 80003fac <log_write>
  brelse(bp);
    800032f4:	854a                	mv	a0,s2
    800032f6:	00000097          	auipc	ra,0x0
    800032fa:	980080e7          	jalr	-1664(ra) # 80002c76 <brelse>
}
    800032fe:	60e2                	ld	ra,24(sp)
    80003300:	6442                	ld	s0,16(sp)
    80003302:	64a2                	ld	s1,8(sp)
    80003304:	6902                	ld	s2,0(sp)
    80003306:	6105                	addi	sp,sp,32
    80003308:	8082                	ret

000000008000330a <idup>:
{
    8000330a:	1101                	addi	sp,sp,-32
    8000330c:	ec06                	sd	ra,24(sp)
    8000330e:	e822                	sd	s0,16(sp)
    80003310:	e426                	sd	s1,8(sp)
    80003312:	1000                	addi	s0,sp,32
    80003314:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003316:	0001d517          	auipc	a0,0x1d
    8000331a:	bba50513          	addi	a0,a0,-1094 # 8001fed0 <icache>
    8000331e:	ffffd097          	auipc	ra,0xffffd
    80003322:	69e080e7          	jalr	1694(ra) # 800009bc <acquire>
  ip->ref++;
    80003326:	449c                	lw	a5,8(s1)
    80003328:	2785                	addiw	a5,a5,1
    8000332a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000332c:	0001d517          	auipc	a0,0x1d
    80003330:	ba450513          	addi	a0,a0,-1116 # 8001fed0 <icache>
    80003334:	ffffd097          	auipc	ra,0xffffd
    80003338:	6f0080e7          	jalr	1776(ra) # 80000a24 <release>
}
    8000333c:	8526                	mv	a0,s1
    8000333e:	60e2                	ld	ra,24(sp)
    80003340:	6442                	ld	s0,16(sp)
    80003342:	64a2                	ld	s1,8(sp)
    80003344:	6105                	addi	sp,sp,32
    80003346:	8082                	ret

0000000080003348 <ilock>:
{
    80003348:	1101                	addi	sp,sp,-32
    8000334a:	ec06                	sd	ra,24(sp)
    8000334c:	e822                	sd	s0,16(sp)
    8000334e:	e426                	sd	s1,8(sp)
    80003350:	e04a                	sd	s2,0(sp)
    80003352:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003354:	c115                	beqz	a0,80003378 <ilock+0x30>
    80003356:	84aa                	mv	s1,a0
    80003358:	451c                	lw	a5,8(a0)
    8000335a:	00f05f63          	blez	a5,80003378 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000335e:	0541                	addi	a0,a0,16
    80003360:	00001097          	auipc	ra,0x1
    80003364:	ee4080e7          	jalr	-284(ra) # 80004244 <acquiresleep>
  if(ip->valid == 0){
    80003368:	40bc                	lw	a5,64(s1)
    8000336a:	cf99                	beqz	a5,80003388 <ilock+0x40>
}
    8000336c:	60e2                	ld	ra,24(sp)
    8000336e:	6442                	ld	s0,16(sp)
    80003370:	64a2                	ld	s1,8(sp)
    80003372:	6902                	ld	s2,0(sp)
    80003374:	6105                	addi	sp,sp,32
    80003376:	8082                	ret
    panic("ilock");
    80003378:	00004517          	auipc	a0,0x4
    8000337c:	20850513          	addi	a0,a0,520 # 80007580 <userret+0x4f0>
    80003380:	ffffd097          	auipc	ra,0xffffd
    80003384:	1c8080e7          	jalr	456(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003388:	40dc                	lw	a5,4(s1)
    8000338a:	0047d79b          	srliw	a5,a5,0x4
    8000338e:	0001d597          	auipc	a1,0x1d
    80003392:	b3a5a583          	lw	a1,-1222(a1) # 8001fec8 <sb+0x18>
    80003396:	9dbd                	addw	a1,a1,a5
    80003398:	4088                	lw	a0,0(s1)
    8000339a:	fffff097          	auipc	ra,0xfffff
    8000339e:	7a8080e7          	jalr	1960(ra) # 80002b42 <bread>
    800033a2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033a4:	06050593          	addi	a1,a0,96
    800033a8:	40dc                	lw	a5,4(s1)
    800033aa:	8bbd                	andi	a5,a5,15
    800033ac:	079a                	slli	a5,a5,0x6
    800033ae:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800033b0:	00059783          	lh	a5,0(a1)
    800033b4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800033b8:	00259783          	lh	a5,2(a1)
    800033bc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800033c0:	00459783          	lh	a5,4(a1)
    800033c4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800033c8:	00659783          	lh	a5,6(a1)
    800033cc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800033d0:	459c                	lw	a5,8(a1)
    800033d2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800033d4:	03400613          	li	a2,52
    800033d8:	05b1                	addi	a1,a1,12
    800033da:	05048513          	addi	a0,s1,80
    800033de:	ffffd097          	auipc	ra,0xffffd
    800033e2:	6fe080e7          	jalr	1790(ra) # 80000adc <memmove>
    brelse(bp);
    800033e6:	854a                	mv	a0,s2
    800033e8:	00000097          	auipc	ra,0x0
    800033ec:	88e080e7          	jalr	-1906(ra) # 80002c76 <brelse>
    ip->valid = 1;
    800033f0:	4785                	li	a5,1
    800033f2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800033f4:	04449783          	lh	a5,68(s1)
    800033f8:	fbb5                	bnez	a5,8000336c <ilock+0x24>
      panic("ilock: no type");
    800033fa:	00004517          	auipc	a0,0x4
    800033fe:	18e50513          	addi	a0,a0,398 # 80007588 <userret+0x4f8>
    80003402:	ffffd097          	auipc	ra,0xffffd
    80003406:	146080e7          	jalr	326(ra) # 80000548 <panic>

000000008000340a <iunlock>:
{
    8000340a:	1101                	addi	sp,sp,-32
    8000340c:	ec06                	sd	ra,24(sp)
    8000340e:	e822                	sd	s0,16(sp)
    80003410:	e426                	sd	s1,8(sp)
    80003412:	e04a                	sd	s2,0(sp)
    80003414:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003416:	c905                	beqz	a0,80003446 <iunlock+0x3c>
    80003418:	84aa                	mv	s1,a0
    8000341a:	01050913          	addi	s2,a0,16
    8000341e:	854a                	mv	a0,s2
    80003420:	00001097          	auipc	ra,0x1
    80003424:	ebe080e7          	jalr	-322(ra) # 800042de <holdingsleep>
    80003428:	cd19                	beqz	a0,80003446 <iunlock+0x3c>
    8000342a:	449c                	lw	a5,8(s1)
    8000342c:	00f05d63          	blez	a5,80003446 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003430:	854a                	mv	a0,s2
    80003432:	00001097          	auipc	ra,0x1
    80003436:	e68080e7          	jalr	-408(ra) # 8000429a <releasesleep>
}
    8000343a:	60e2                	ld	ra,24(sp)
    8000343c:	6442                	ld	s0,16(sp)
    8000343e:	64a2                	ld	s1,8(sp)
    80003440:	6902                	ld	s2,0(sp)
    80003442:	6105                	addi	sp,sp,32
    80003444:	8082                	ret
    panic("iunlock");
    80003446:	00004517          	auipc	a0,0x4
    8000344a:	15250513          	addi	a0,a0,338 # 80007598 <userret+0x508>
    8000344e:	ffffd097          	auipc	ra,0xffffd
    80003452:	0fa080e7          	jalr	250(ra) # 80000548 <panic>

0000000080003456 <iput>:
{
    80003456:	7139                	addi	sp,sp,-64
    80003458:	fc06                	sd	ra,56(sp)
    8000345a:	f822                	sd	s0,48(sp)
    8000345c:	f426                	sd	s1,40(sp)
    8000345e:	f04a                	sd	s2,32(sp)
    80003460:	ec4e                	sd	s3,24(sp)
    80003462:	e852                	sd	s4,16(sp)
    80003464:	e456                	sd	s5,8(sp)
    80003466:	0080                	addi	s0,sp,64
    80003468:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000346a:	0001d517          	auipc	a0,0x1d
    8000346e:	a6650513          	addi	a0,a0,-1434 # 8001fed0 <icache>
    80003472:	ffffd097          	auipc	ra,0xffffd
    80003476:	54a080e7          	jalr	1354(ra) # 800009bc <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000347a:	4498                	lw	a4,8(s1)
    8000347c:	4785                	li	a5,1
    8000347e:	02f70663          	beq	a4,a5,800034aa <iput+0x54>
  ip->ref--;
    80003482:	449c                	lw	a5,8(s1)
    80003484:	37fd                	addiw	a5,a5,-1
    80003486:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003488:	0001d517          	auipc	a0,0x1d
    8000348c:	a4850513          	addi	a0,a0,-1464 # 8001fed0 <icache>
    80003490:	ffffd097          	auipc	ra,0xffffd
    80003494:	594080e7          	jalr	1428(ra) # 80000a24 <release>
}
    80003498:	70e2                	ld	ra,56(sp)
    8000349a:	7442                	ld	s0,48(sp)
    8000349c:	74a2                	ld	s1,40(sp)
    8000349e:	7902                	ld	s2,32(sp)
    800034a0:	69e2                	ld	s3,24(sp)
    800034a2:	6a42                	ld	s4,16(sp)
    800034a4:	6aa2                	ld	s5,8(sp)
    800034a6:	6121                	addi	sp,sp,64
    800034a8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034aa:	40bc                	lw	a5,64(s1)
    800034ac:	dbf9                	beqz	a5,80003482 <iput+0x2c>
    800034ae:	04a49783          	lh	a5,74(s1)
    800034b2:	fbe1                	bnez	a5,80003482 <iput+0x2c>
    acquiresleep(&ip->lock);
    800034b4:	01048a13          	addi	s4,s1,16
    800034b8:	8552                	mv	a0,s4
    800034ba:	00001097          	auipc	ra,0x1
    800034be:	d8a080e7          	jalr	-630(ra) # 80004244 <acquiresleep>
    release(&icache.lock);
    800034c2:	0001d517          	auipc	a0,0x1d
    800034c6:	a0e50513          	addi	a0,a0,-1522 # 8001fed0 <icache>
    800034ca:	ffffd097          	auipc	ra,0xffffd
    800034ce:	55a080e7          	jalr	1370(ra) # 80000a24 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800034d2:	05048913          	addi	s2,s1,80
    800034d6:	08048993          	addi	s3,s1,128
    800034da:	a021                	j	800034e2 <iput+0x8c>
    800034dc:	0911                	addi	s2,s2,4
    800034de:	01390d63          	beq	s2,s3,800034f8 <iput+0xa2>
    if(ip->addrs[i]){
    800034e2:	00092583          	lw	a1,0(s2)
    800034e6:	d9fd                	beqz	a1,800034dc <iput+0x86>
      bfree(ip->dev, ip->addrs[i]);
    800034e8:	4088                	lw	a0,0(s1)
    800034ea:	00000097          	auipc	ra,0x0
    800034ee:	8a2080e7          	jalr	-1886(ra) # 80002d8c <bfree>
      ip->addrs[i] = 0;
    800034f2:	00092023          	sw	zero,0(s2)
    800034f6:	b7dd                	j	800034dc <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    800034f8:	0804a583          	lw	a1,128(s1)
    800034fc:	ed9d                	bnez	a1,8000353a <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800034fe:	0404a623          	sw	zero,76(s1)
  iupdate(ip);
    80003502:	8526                	mv	a0,s1
    80003504:	00000097          	auipc	ra,0x0
    80003508:	d7a080e7          	jalr	-646(ra) # 8000327e <iupdate>
    ip->type = 0;
    8000350c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003510:	8526                	mv	a0,s1
    80003512:	00000097          	auipc	ra,0x0
    80003516:	d6c080e7          	jalr	-660(ra) # 8000327e <iupdate>
    ip->valid = 0;
    8000351a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000351e:	8552                	mv	a0,s4
    80003520:	00001097          	auipc	ra,0x1
    80003524:	d7a080e7          	jalr	-646(ra) # 8000429a <releasesleep>
    acquire(&icache.lock);
    80003528:	0001d517          	auipc	a0,0x1d
    8000352c:	9a850513          	addi	a0,a0,-1624 # 8001fed0 <icache>
    80003530:	ffffd097          	auipc	ra,0xffffd
    80003534:	48c080e7          	jalr	1164(ra) # 800009bc <acquire>
    80003538:	b7a9                	j	80003482 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000353a:	4088                	lw	a0,0(s1)
    8000353c:	fffff097          	auipc	ra,0xfffff
    80003540:	606080e7          	jalr	1542(ra) # 80002b42 <bread>
    80003544:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003546:	06050913          	addi	s2,a0,96
    8000354a:	46050993          	addi	s3,a0,1120
    8000354e:	a021                	j	80003556 <iput+0x100>
    80003550:	0911                	addi	s2,s2,4
    80003552:	01390b63          	beq	s2,s3,80003568 <iput+0x112>
      if(a[j])
    80003556:	00092583          	lw	a1,0(s2)
    8000355a:	d9fd                	beqz	a1,80003550 <iput+0xfa>
        bfree(ip->dev, a[j]);
    8000355c:	4088                	lw	a0,0(s1)
    8000355e:	00000097          	auipc	ra,0x0
    80003562:	82e080e7          	jalr	-2002(ra) # 80002d8c <bfree>
    80003566:	b7ed                	j	80003550 <iput+0xfa>
    brelse(bp);
    80003568:	8556                	mv	a0,s5
    8000356a:	fffff097          	auipc	ra,0xfffff
    8000356e:	70c080e7          	jalr	1804(ra) # 80002c76 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003572:	0804a583          	lw	a1,128(s1)
    80003576:	4088                	lw	a0,0(s1)
    80003578:	00000097          	auipc	ra,0x0
    8000357c:	814080e7          	jalr	-2028(ra) # 80002d8c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003580:	0804a023          	sw	zero,128(s1)
    80003584:	bfad                	j	800034fe <iput+0xa8>

0000000080003586 <iunlockput>:
{
    80003586:	1101                	addi	sp,sp,-32
    80003588:	ec06                	sd	ra,24(sp)
    8000358a:	e822                	sd	s0,16(sp)
    8000358c:	e426                	sd	s1,8(sp)
    8000358e:	1000                	addi	s0,sp,32
    80003590:	84aa                	mv	s1,a0
  iunlock(ip);
    80003592:	00000097          	auipc	ra,0x0
    80003596:	e78080e7          	jalr	-392(ra) # 8000340a <iunlock>
  iput(ip);
    8000359a:	8526                	mv	a0,s1
    8000359c:	00000097          	auipc	ra,0x0
    800035a0:	eba080e7          	jalr	-326(ra) # 80003456 <iput>
}
    800035a4:	60e2                	ld	ra,24(sp)
    800035a6:	6442                	ld	s0,16(sp)
    800035a8:	64a2                	ld	s1,8(sp)
    800035aa:	6105                	addi	sp,sp,32
    800035ac:	8082                	ret

00000000800035ae <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800035ae:	1141                	addi	sp,sp,-16
    800035b0:	e422                	sd	s0,8(sp)
    800035b2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800035b4:	411c                	lw	a5,0(a0)
    800035b6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800035b8:	415c                	lw	a5,4(a0)
    800035ba:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800035bc:	04451783          	lh	a5,68(a0)
    800035c0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800035c4:	04a51783          	lh	a5,74(a0)
    800035c8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800035cc:	04c56783          	lwu	a5,76(a0)
    800035d0:	e99c                	sd	a5,16(a1)
}
    800035d2:	6422                	ld	s0,8(sp)
    800035d4:	0141                	addi	sp,sp,16
    800035d6:	8082                	ret

00000000800035d8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800035d8:	457c                	lw	a5,76(a0)
    800035da:	0ed7e563          	bltu	a5,a3,800036c4 <readi+0xec>
{
    800035de:	7159                	addi	sp,sp,-112
    800035e0:	f486                	sd	ra,104(sp)
    800035e2:	f0a2                	sd	s0,96(sp)
    800035e4:	eca6                	sd	s1,88(sp)
    800035e6:	e8ca                	sd	s2,80(sp)
    800035e8:	e4ce                	sd	s3,72(sp)
    800035ea:	e0d2                	sd	s4,64(sp)
    800035ec:	fc56                	sd	s5,56(sp)
    800035ee:	f85a                	sd	s6,48(sp)
    800035f0:	f45e                	sd	s7,40(sp)
    800035f2:	f062                	sd	s8,32(sp)
    800035f4:	ec66                	sd	s9,24(sp)
    800035f6:	e86a                	sd	s10,16(sp)
    800035f8:	e46e                	sd	s11,8(sp)
    800035fa:	1880                	addi	s0,sp,112
    800035fc:	8baa                	mv	s7,a0
    800035fe:	8c2e                	mv	s8,a1
    80003600:	8ab2                	mv	s5,a2
    80003602:	8936                	mv	s2,a3
    80003604:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003606:	9f35                	addw	a4,a4,a3
    80003608:	0cd76063          	bltu	a4,a3,800036c8 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    8000360c:	00e7f463          	bgeu	a5,a4,80003614 <readi+0x3c>
    n = ip->size - off;
    80003610:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003614:	080b0763          	beqz	s6,800036a2 <readi+0xca>
    80003618:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000361a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000361e:	5cfd                	li	s9,-1
    80003620:	a82d                	j	8000365a <readi+0x82>
    80003622:	02099d93          	slli	s11,s3,0x20
    80003626:	020ddd93          	srli	s11,s11,0x20
    8000362a:	06048793          	addi	a5,s1,96
    8000362e:	86ee                	mv	a3,s11
    80003630:	963e                	add	a2,a2,a5
    80003632:	85d6                	mv	a1,s5
    80003634:	8562                	mv	a0,s8
    80003636:	fffff097          	auipc	ra,0xfffff
    8000363a:	b56080e7          	jalr	-1194(ra) # 8000218c <either_copyout>
    8000363e:	05950d63          	beq	a0,s9,80003698 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003642:	8526                	mv	a0,s1
    80003644:	fffff097          	auipc	ra,0xfffff
    80003648:	632080e7          	jalr	1586(ra) # 80002c76 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000364c:	01498a3b          	addw	s4,s3,s4
    80003650:	0129893b          	addw	s2,s3,s2
    80003654:	9aee                	add	s5,s5,s11
    80003656:	056a7663          	bgeu	s4,s6,800036a2 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000365a:	000ba483          	lw	s1,0(s7)
    8000365e:	00a9559b          	srliw	a1,s2,0xa
    80003662:	855e                	mv	a0,s7
    80003664:	00000097          	auipc	ra,0x0
    80003668:	8d6080e7          	jalr	-1834(ra) # 80002f3a <bmap>
    8000366c:	0005059b          	sext.w	a1,a0
    80003670:	8526                	mv	a0,s1
    80003672:	fffff097          	auipc	ra,0xfffff
    80003676:	4d0080e7          	jalr	1232(ra) # 80002b42 <bread>
    8000367a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000367c:	3ff97613          	andi	a2,s2,1023
    80003680:	40cd07bb          	subw	a5,s10,a2
    80003684:	414b073b          	subw	a4,s6,s4
    80003688:	89be                	mv	s3,a5
    8000368a:	2781                	sext.w	a5,a5
    8000368c:	0007069b          	sext.w	a3,a4
    80003690:	f8f6f9e3          	bgeu	a3,a5,80003622 <readi+0x4a>
    80003694:	89ba                	mv	s3,a4
    80003696:	b771                	j	80003622 <readi+0x4a>
      brelse(bp);
    80003698:	8526                	mv	a0,s1
    8000369a:	fffff097          	auipc	ra,0xfffff
    8000369e:	5dc080e7          	jalr	1500(ra) # 80002c76 <brelse>
  }
  return n;
    800036a2:	000b051b          	sext.w	a0,s6
}
    800036a6:	70a6                	ld	ra,104(sp)
    800036a8:	7406                	ld	s0,96(sp)
    800036aa:	64e6                	ld	s1,88(sp)
    800036ac:	6946                	ld	s2,80(sp)
    800036ae:	69a6                	ld	s3,72(sp)
    800036b0:	6a06                	ld	s4,64(sp)
    800036b2:	7ae2                	ld	s5,56(sp)
    800036b4:	7b42                	ld	s6,48(sp)
    800036b6:	7ba2                	ld	s7,40(sp)
    800036b8:	7c02                	ld	s8,32(sp)
    800036ba:	6ce2                	ld	s9,24(sp)
    800036bc:	6d42                	ld	s10,16(sp)
    800036be:	6da2                	ld	s11,8(sp)
    800036c0:	6165                	addi	sp,sp,112
    800036c2:	8082                	ret
    return -1;
    800036c4:	557d                	li	a0,-1
}
    800036c6:	8082                	ret
    return -1;
    800036c8:	557d                	li	a0,-1
    800036ca:	bff1                	j	800036a6 <readi+0xce>

00000000800036cc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800036cc:	457c                	lw	a5,76(a0)
    800036ce:	10d7e763          	bltu	a5,a3,800037dc <writei+0x110>
{
    800036d2:	7159                	addi	sp,sp,-112
    800036d4:	f486                	sd	ra,104(sp)
    800036d6:	f0a2                	sd	s0,96(sp)
    800036d8:	eca6                	sd	s1,88(sp)
    800036da:	e8ca                	sd	s2,80(sp)
    800036dc:	e4ce                	sd	s3,72(sp)
    800036de:	e0d2                	sd	s4,64(sp)
    800036e0:	fc56                	sd	s5,56(sp)
    800036e2:	f85a                	sd	s6,48(sp)
    800036e4:	f45e                	sd	s7,40(sp)
    800036e6:	f062                	sd	s8,32(sp)
    800036e8:	ec66                	sd	s9,24(sp)
    800036ea:	e86a                	sd	s10,16(sp)
    800036ec:	e46e                	sd	s11,8(sp)
    800036ee:	1880                	addi	s0,sp,112
    800036f0:	8baa                	mv	s7,a0
    800036f2:	8c2e                	mv	s8,a1
    800036f4:	8ab2                	mv	s5,a2
    800036f6:	8936                	mv	s2,a3
    800036f8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800036fa:	00e687bb          	addw	a5,a3,a4
    800036fe:	0ed7e163          	bltu	a5,a3,800037e0 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003702:	00043737          	lui	a4,0x43
    80003706:	0cf76f63          	bltu	a4,a5,800037e4 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000370a:	0a0b0063          	beqz	s6,800037aa <writei+0xde>
    8000370e:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003710:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003714:	5cfd                	li	s9,-1
    80003716:	a091                	j	8000375a <writei+0x8e>
    80003718:	02099d93          	slli	s11,s3,0x20
    8000371c:	020ddd93          	srli	s11,s11,0x20
    80003720:	06048793          	addi	a5,s1,96
    80003724:	86ee                	mv	a3,s11
    80003726:	8656                	mv	a2,s5
    80003728:	85e2                	mv	a1,s8
    8000372a:	953e                	add	a0,a0,a5
    8000372c:	fffff097          	auipc	ra,0xfffff
    80003730:	ab6080e7          	jalr	-1354(ra) # 800021e2 <either_copyin>
    80003734:	07950263          	beq	a0,s9,80003798 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003738:	8526                	mv	a0,s1
    8000373a:	00001097          	auipc	ra,0x1
    8000373e:	872080e7          	jalr	-1934(ra) # 80003fac <log_write>
    brelse(bp);
    80003742:	8526                	mv	a0,s1
    80003744:	fffff097          	auipc	ra,0xfffff
    80003748:	532080e7          	jalr	1330(ra) # 80002c76 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000374c:	01498a3b          	addw	s4,s3,s4
    80003750:	0129893b          	addw	s2,s3,s2
    80003754:	9aee                	add	s5,s5,s11
    80003756:	056a7663          	bgeu	s4,s6,800037a2 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000375a:	000ba483          	lw	s1,0(s7)
    8000375e:	00a9559b          	srliw	a1,s2,0xa
    80003762:	855e                	mv	a0,s7
    80003764:	fffff097          	auipc	ra,0xfffff
    80003768:	7d6080e7          	jalr	2006(ra) # 80002f3a <bmap>
    8000376c:	0005059b          	sext.w	a1,a0
    80003770:	8526                	mv	a0,s1
    80003772:	fffff097          	auipc	ra,0xfffff
    80003776:	3d0080e7          	jalr	976(ra) # 80002b42 <bread>
    8000377a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000377c:	3ff97513          	andi	a0,s2,1023
    80003780:	40ad07bb          	subw	a5,s10,a0
    80003784:	414b073b          	subw	a4,s6,s4
    80003788:	89be                	mv	s3,a5
    8000378a:	2781                	sext.w	a5,a5
    8000378c:	0007069b          	sext.w	a3,a4
    80003790:	f8f6f4e3          	bgeu	a3,a5,80003718 <writei+0x4c>
    80003794:	89ba                	mv	s3,a4
    80003796:	b749                	j	80003718 <writei+0x4c>
      brelse(bp);
    80003798:	8526                	mv	a0,s1
    8000379a:	fffff097          	auipc	ra,0xfffff
    8000379e:	4dc080e7          	jalr	1244(ra) # 80002c76 <brelse>
  }

  if(n > 0 && off > ip->size){
    800037a2:	04cba783          	lw	a5,76(s7)
    800037a6:	0327e363          	bltu	a5,s2,800037cc <writei+0x100>
    ip->size = off;
    iupdate(ip);
  }
  return n;
    800037aa:	000b051b          	sext.w	a0,s6
}
    800037ae:	70a6                	ld	ra,104(sp)
    800037b0:	7406                	ld	s0,96(sp)
    800037b2:	64e6                	ld	s1,88(sp)
    800037b4:	6946                	ld	s2,80(sp)
    800037b6:	69a6                	ld	s3,72(sp)
    800037b8:	6a06                	ld	s4,64(sp)
    800037ba:	7ae2                	ld	s5,56(sp)
    800037bc:	7b42                	ld	s6,48(sp)
    800037be:	7ba2                	ld	s7,40(sp)
    800037c0:	7c02                	ld	s8,32(sp)
    800037c2:	6ce2                	ld	s9,24(sp)
    800037c4:	6d42                	ld	s10,16(sp)
    800037c6:	6da2                	ld	s11,8(sp)
    800037c8:	6165                	addi	sp,sp,112
    800037ca:	8082                	ret
    ip->size = off;
    800037cc:	052ba623          	sw	s2,76(s7)
    iupdate(ip);
    800037d0:	855e                	mv	a0,s7
    800037d2:	00000097          	auipc	ra,0x0
    800037d6:	aac080e7          	jalr	-1364(ra) # 8000327e <iupdate>
    800037da:	bfc1                	j	800037aa <writei+0xde>
    return -1;
    800037dc:	557d                	li	a0,-1
}
    800037de:	8082                	ret
    return -1;
    800037e0:	557d                	li	a0,-1
    800037e2:	b7f1                	j	800037ae <writei+0xe2>
    return -1;
    800037e4:	557d                	li	a0,-1
    800037e6:	b7e1                	j	800037ae <writei+0xe2>

00000000800037e8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800037e8:	1141                	addi	sp,sp,-16
    800037ea:	e406                	sd	ra,8(sp)
    800037ec:	e022                	sd	s0,0(sp)
    800037ee:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800037f0:	4639                	li	a2,14
    800037f2:	ffffd097          	auipc	ra,0xffffd
    800037f6:	366080e7          	jalr	870(ra) # 80000b58 <strncmp>
}
    800037fa:	60a2                	ld	ra,8(sp)
    800037fc:	6402                	ld	s0,0(sp)
    800037fe:	0141                	addi	sp,sp,16
    80003800:	8082                	ret

0000000080003802 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003802:	7139                	addi	sp,sp,-64
    80003804:	fc06                	sd	ra,56(sp)
    80003806:	f822                	sd	s0,48(sp)
    80003808:	f426                	sd	s1,40(sp)
    8000380a:	f04a                	sd	s2,32(sp)
    8000380c:	ec4e                	sd	s3,24(sp)
    8000380e:	e852                	sd	s4,16(sp)
    80003810:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003812:	04451703          	lh	a4,68(a0)
    80003816:	4785                	li	a5,1
    80003818:	00f71a63          	bne	a4,a5,8000382c <dirlookup+0x2a>
    8000381c:	892a                	mv	s2,a0
    8000381e:	89ae                	mv	s3,a1
    80003820:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003822:	457c                	lw	a5,76(a0)
    80003824:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003826:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003828:	e79d                	bnez	a5,80003856 <dirlookup+0x54>
    8000382a:	a8a5                	j	800038a2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000382c:	00004517          	auipc	a0,0x4
    80003830:	d7450513          	addi	a0,a0,-652 # 800075a0 <userret+0x510>
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	d14080e7          	jalr	-748(ra) # 80000548 <panic>
      panic("dirlookup read");
    8000383c:	00004517          	auipc	a0,0x4
    80003840:	d7c50513          	addi	a0,a0,-644 # 800075b8 <userret+0x528>
    80003844:	ffffd097          	auipc	ra,0xffffd
    80003848:	d04080e7          	jalr	-764(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000384c:	24c1                	addiw	s1,s1,16
    8000384e:	04c92783          	lw	a5,76(s2)
    80003852:	04f4f763          	bgeu	s1,a5,800038a0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003856:	4741                	li	a4,16
    80003858:	86a6                	mv	a3,s1
    8000385a:	fc040613          	addi	a2,s0,-64
    8000385e:	4581                	li	a1,0
    80003860:	854a                	mv	a0,s2
    80003862:	00000097          	auipc	ra,0x0
    80003866:	d76080e7          	jalr	-650(ra) # 800035d8 <readi>
    8000386a:	47c1                	li	a5,16
    8000386c:	fcf518e3          	bne	a0,a5,8000383c <dirlookup+0x3a>
    if(de.inum == 0)
    80003870:	fc045783          	lhu	a5,-64(s0)
    80003874:	dfe1                	beqz	a5,8000384c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003876:	fc240593          	addi	a1,s0,-62
    8000387a:	854e                	mv	a0,s3
    8000387c:	00000097          	auipc	ra,0x0
    80003880:	f6c080e7          	jalr	-148(ra) # 800037e8 <namecmp>
    80003884:	f561                	bnez	a0,8000384c <dirlookup+0x4a>
      if(poff)
    80003886:	000a0463          	beqz	s4,8000388e <dirlookup+0x8c>
        *poff = off;
    8000388a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000388e:	fc045583          	lhu	a1,-64(s0)
    80003892:	00092503          	lw	a0,0(s2)
    80003896:	fffff097          	auipc	ra,0xfffff
    8000389a:	77e080e7          	jalr	1918(ra) # 80003014 <iget>
    8000389e:	a011                	j	800038a2 <dirlookup+0xa0>
  return 0;
    800038a0:	4501                	li	a0,0
}
    800038a2:	70e2                	ld	ra,56(sp)
    800038a4:	7442                	ld	s0,48(sp)
    800038a6:	74a2                	ld	s1,40(sp)
    800038a8:	7902                	ld	s2,32(sp)
    800038aa:	69e2                	ld	s3,24(sp)
    800038ac:	6a42                	ld	s4,16(sp)
    800038ae:	6121                	addi	sp,sp,64
    800038b0:	8082                	ret

00000000800038b2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800038b2:	711d                	addi	sp,sp,-96
    800038b4:	ec86                	sd	ra,88(sp)
    800038b6:	e8a2                	sd	s0,80(sp)
    800038b8:	e4a6                	sd	s1,72(sp)
    800038ba:	e0ca                	sd	s2,64(sp)
    800038bc:	fc4e                	sd	s3,56(sp)
    800038be:	f852                	sd	s4,48(sp)
    800038c0:	f456                	sd	s5,40(sp)
    800038c2:	f05a                	sd	s6,32(sp)
    800038c4:	ec5e                	sd	s7,24(sp)
    800038c6:	e862                	sd	s8,16(sp)
    800038c8:	e466                	sd	s9,8(sp)
    800038ca:	1080                	addi	s0,sp,96
    800038cc:	84aa                	mv	s1,a0
    800038ce:	8aae                	mv	s5,a1
    800038d0:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800038d2:	00054703          	lbu	a4,0(a0)
    800038d6:	02f00793          	li	a5,47
    800038da:	02f70363          	beq	a4,a5,80003900 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800038de:	ffffe097          	auipc	ra,0xffffe
    800038e2:	e3e080e7          	jalr	-450(ra) # 8000171c <myproc>
    800038e6:	15053503          	ld	a0,336(a0)
    800038ea:	00000097          	auipc	ra,0x0
    800038ee:	a20080e7          	jalr	-1504(ra) # 8000330a <idup>
    800038f2:	89aa                	mv	s3,a0
  while(*path == '/')
    800038f4:	02f00913          	li	s2,47
  len = path - s;
    800038f8:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800038fa:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800038fc:	4b85                	li	s7,1
    800038fe:	a865                	j	800039b6 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003900:	4585                	li	a1,1
    80003902:	4501                	li	a0,0
    80003904:	fffff097          	auipc	ra,0xfffff
    80003908:	710080e7          	jalr	1808(ra) # 80003014 <iget>
    8000390c:	89aa                	mv	s3,a0
    8000390e:	b7dd                	j	800038f4 <namex+0x42>
      iunlockput(ip);
    80003910:	854e                	mv	a0,s3
    80003912:	00000097          	auipc	ra,0x0
    80003916:	c74080e7          	jalr	-908(ra) # 80003586 <iunlockput>
      return 0;
    8000391a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000391c:	854e                	mv	a0,s3
    8000391e:	60e6                	ld	ra,88(sp)
    80003920:	6446                	ld	s0,80(sp)
    80003922:	64a6                	ld	s1,72(sp)
    80003924:	6906                	ld	s2,64(sp)
    80003926:	79e2                	ld	s3,56(sp)
    80003928:	7a42                	ld	s4,48(sp)
    8000392a:	7aa2                	ld	s5,40(sp)
    8000392c:	7b02                	ld	s6,32(sp)
    8000392e:	6be2                	ld	s7,24(sp)
    80003930:	6c42                	ld	s8,16(sp)
    80003932:	6ca2                	ld	s9,8(sp)
    80003934:	6125                	addi	sp,sp,96
    80003936:	8082                	ret
      iunlock(ip);
    80003938:	854e                	mv	a0,s3
    8000393a:	00000097          	auipc	ra,0x0
    8000393e:	ad0080e7          	jalr	-1328(ra) # 8000340a <iunlock>
      return ip;
    80003942:	bfe9                	j	8000391c <namex+0x6a>
      iunlockput(ip);
    80003944:	854e                	mv	a0,s3
    80003946:	00000097          	auipc	ra,0x0
    8000394a:	c40080e7          	jalr	-960(ra) # 80003586 <iunlockput>
      return 0;
    8000394e:	89e6                	mv	s3,s9
    80003950:	b7f1                	j	8000391c <namex+0x6a>
  len = path - s;
    80003952:	40b48633          	sub	a2,s1,a1
    80003956:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000395a:	099c5463          	bge	s8,s9,800039e2 <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000395e:	4639                	li	a2,14
    80003960:	8552                	mv	a0,s4
    80003962:	ffffd097          	auipc	ra,0xffffd
    80003966:	17a080e7          	jalr	378(ra) # 80000adc <memmove>
  while(*path == '/')
    8000396a:	0004c783          	lbu	a5,0(s1)
    8000396e:	01279763          	bne	a5,s2,8000397c <namex+0xca>
    path++;
    80003972:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003974:	0004c783          	lbu	a5,0(s1)
    80003978:	ff278de3          	beq	a5,s2,80003972 <namex+0xc0>
    ilock(ip);
    8000397c:	854e                	mv	a0,s3
    8000397e:	00000097          	auipc	ra,0x0
    80003982:	9ca080e7          	jalr	-1590(ra) # 80003348 <ilock>
    if(ip->type != T_DIR){
    80003986:	04499783          	lh	a5,68(s3)
    8000398a:	f97793e3          	bne	a5,s7,80003910 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000398e:	000a8563          	beqz	s5,80003998 <namex+0xe6>
    80003992:	0004c783          	lbu	a5,0(s1)
    80003996:	d3cd                	beqz	a5,80003938 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003998:	865a                	mv	a2,s6
    8000399a:	85d2                	mv	a1,s4
    8000399c:	854e                	mv	a0,s3
    8000399e:	00000097          	auipc	ra,0x0
    800039a2:	e64080e7          	jalr	-412(ra) # 80003802 <dirlookup>
    800039a6:	8caa                	mv	s9,a0
    800039a8:	dd51                	beqz	a0,80003944 <namex+0x92>
    iunlockput(ip);
    800039aa:	854e                	mv	a0,s3
    800039ac:	00000097          	auipc	ra,0x0
    800039b0:	bda080e7          	jalr	-1062(ra) # 80003586 <iunlockput>
    ip = next;
    800039b4:	89e6                	mv	s3,s9
  while(*path == '/')
    800039b6:	0004c783          	lbu	a5,0(s1)
    800039ba:	05279763          	bne	a5,s2,80003a08 <namex+0x156>
    path++;
    800039be:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039c0:	0004c783          	lbu	a5,0(s1)
    800039c4:	ff278de3          	beq	a5,s2,800039be <namex+0x10c>
  if(*path == 0)
    800039c8:	c79d                	beqz	a5,800039f6 <namex+0x144>
    path++;
    800039ca:	85a6                	mv	a1,s1
  len = path - s;
    800039cc:	8cda                	mv	s9,s6
    800039ce:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800039d0:	01278963          	beq	a5,s2,800039e2 <namex+0x130>
    800039d4:	dfbd                	beqz	a5,80003952 <namex+0xa0>
    path++;
    800039d6:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800039d8:	0004c783          	lbu	a5,0(s1)
    800039dc:	ff279ce3          	bne	a5,s2,800039d4 <namex+0x122>
    800039e0:	bf8d                	j	80003952 <namex+0xa0>
    memmove(name, s, len);
    800039e2:	2601                	sext.w	a2,a2
    800039e4:	8552                	mv	a0,s4
    800039e6:	ffffd097          	auipc	ra,0xffffd
    800039ea:	0f6080e7          	jalr	246(ra) # 80000adc <memmove>
    name[len] = 0;
    800039ee:	9cd2                	add	s9,s9,s4
    800039f0:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800039f4:	bf9d                	j	8000396a <namex+0xb8>
  if(nameiparent){
    800039f6:	f20a83e3          	beqz	s5,8000391c <namex+0x6a>
    iput(ip);
    800039fa:	854e                	mv	a0,s3
    800039fc:	00000097          	auipc	ra,0x0
    80003a00:	a5a080e7          	jalr	-1446(ra) # 80003456 <iput>
    return 0;
    80003a04:	4981                	li	s3,0
    80003a06:	bf19                	j	8000391c <namex+0x6a>
  if(*path == 0)
    80003a08:	d7fd                	beqz	a5,800039f6 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003a0a:	0004c783          	lbu	a5,0(s1)
    80003a0e:	85a6                	mv	a1,s1
    80003a10:	b7d1                	j	800039d4 <namex+0x122>

0000000080003a12 <dirlink>:
{
    80003a12:	7139                	addi	sp,sp,-64
    80003a14:	fc06                	sd	ra,56(sp)
    80003a16:	f822                	sd	s0,48(sp)
    80003a18:	f426                	sd	s1,40(sp)
    80003a1a:	f04a                	sd	s2,32(sp)
    80003a1c:	ec4e                	sd	s3,24(sp)
    80003a1e:	e852                	sd	s4,16(sp)
    80003a20:	0080                	addi	s0,sp,64
    80003a22:	892a                	mv	s2,a0
    80003a24:	8a2e                	mv	s4,a1
    80003a26:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a28:	4601                	li	a2,0
    80003a2a:	00000097          	auipc	ra,0x0
    80003a2e:	dd8080e7          	jalr	-552(ra) # 80003802 <dirlookup>
    80003a32:	e93d                	bnez	a0,80003aa8 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a34:	04c92483          	lw	s1,76(s2)
    80003a38:	c49d                	beqz	s1,80003a66 <dirlink+0x54>
    80003a3a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a3c:	4741                	li	a4,16
    80003a3e:	86a6                	mv	a3,s1
    80003a40:	fc040613          	addi	a2,s0,-64
    80003a44:	4581                	li	a1,0
    80003a46:	854a                	mv	a0,s2
    80003a48:	00000097          	auipc	ra,0x0
    80003a4c:	b90080e7          	jalr	-1136(ra) # 800035d8 <readi>
    80003a50:	47c1                	li	a5,16
    80003a52:	06f51163          	bne	a0,a5,80003ab4 <dirlink+0xa2>
    if(de.inum == 0)
    80003a56:	fc045783          	lhu	a5,-64(s0)
    80003a5a:	c791                	beqz	a5,80003a66 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a5c:	24c1                	addiw	s1,s1,16
    80003a5e:	04c92783          	lw	a5,76(s2)
    80003a62:	fcf4ede3          	bltu	s1,a5,80003a3c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003a66:	4639                	li	a2,14
    80003a68:	85d2                	mv	a1,s4
    80003a6a:	fc240513          	addi	a0,s0,-62
    80003a6e:	ffffd097          	auipc	ra,0xffffd
    80003a72:	126080e7          	jalr	294(ra) # 80000b94 <strncpy>
  de.inum = inum;
    80003a76:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a7a:	4741                	li	a4,16
    80003a7c:	86a6                	mv	a3,s1
    80003a7e:	fc040613          	addi	a2,s0,-64
    80003a82:	4581                	li	a1,0
    80003a84:	854a                	mv	a0,s2
    80003a86:	00000097          	auipc	ra,0x0
    80003a8a:	c46080e7          	jalr	-954(ra) # 800036cc <writei>
    80003a8e:	872a                	mv	a4,a0
    80003a90:	47c1                	li	a5,16
  return 0;
    80003a92:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a94:	02f71863          	bne	a4,a5,80003ac4 <dirlink+0xb2>
}
    80003a98:	70e2                	ld	ra,56(sp)
    80003a9a:	7442                	ld	s0,48(sp)
    80003a9c:	74a2                	ld	s1,40(sp)
    80003a9e:	7902                	ld	s2,32(sp)
    80003aa0:	69e2                	ld	s3,24(sp)
    80003aa2:	6a42                	ld	s4,16(sp)
    80003aa4:	6121                	addi	sp,sp,64
    80003aa6:	8082                	ret
    iput(ip);
    80003aa8:	00000097          	auipc	ra,0x0
    80003aac:	9ae080e7          	jalr	-1618(ra) # 80003456 <iput>
    return -1;
    80003ab0:	557d                	li	a0,-1
    80003ab2:	b7dd                	j	80003a98 <dirlink+0x86>
      panic("dirlink read");
    80003ab4:	00004517          	auipc	a0,0x4
    80003ab8:	b1450513          	addi	a0,a0,-1260 # 800075c8 <userret+0x538>
    80003abc:	ffffd097          	auipc	ra,0xffffd
    80003ac0:	a8c080e7          	jalr	-1396(ra) # 80000548 <panic>
    panic("dirlink");
    80003ac4:	00004517          	auipc	a0,0x4
    80003ac8:	cb450513          	addi	a0,a0,-844 # 80007778 <userret+0x6e8>
    80003acc:	ffffd097          	auipc	ra,0xffffd
    80003ad0:	a7c080e7          	jalr	-1412(ra) # 80000548 <panic>

0000000080003ad4 <namei>:

struct inode*
namei(char *path)
{
    80003ad4:	1101                	addi	sp,sp,-32
    80003ad6:	ec06                	sd	ra,24(sp)
    80003ad8:	e822                	sd	s0,16(sp)
    80003ada:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003adc:	fe040613          	addi	a2,s0,-32
    80003ae0:	4581                	li	a1,0
    80003ae2:	00000097          	auipc	ra,0x0
    80003ae6:	dd0080e7          	jalr	-560(ra) # 800038b2 <namex>
}
    80003aea:	60e2                	ld	ra,24(sp)
    80003aec:	6442                	ld	s0,16(sp)
    80003aee:	6105                	addi	sp,sp,32
    80003af0:	8082                	ret

0000000080003af2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003af2:	1141                	addi	sp,sp,-16
    80003af4:	e406                	sd	ra,8(sp)
    80003af6:	e022                	sd	s0,0(sp)
    80003af8:	0800                	addi	s0,sp,16
    80003afa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003afc:	4585                	li	a1,1
    80003afe:	00000097          	auipc	ra,0x0
    80003b02:	db4080e7          	jalr	-588(ra) # 800038b2 <namex>
}
    80003b06:	60a2                	ld	ra,8(sp)
    80003b08:	6402                	ld	s0,0(sp)
    80003b0a:	0141                	addi	sp,sp,16
    80003b0c:	8082                	ret

0000000080003b0e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80003b0e:	7179                	addi	sp,sp,-48
    80003b10:	f406                	sd	ra,40(sp)
    80003b12:	f022                	sd	s0,32(sp)
    80003b14:	ec26                	sd	s1,24(sp)
    80003b16:	e84a                	sd	s2,16(sp)
    80003b18:	e44e                	sd	s3,8(sp)
    80003b1a:	1800                	addi	s0,sp,48
    80003b1c:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80003b1e:	0a800993          	li	s3,168
    80003b22:	033507b3          	mul	a5,a0,s3
    80003b26:	0001e997          	auipc	s3,0x1e
    80003b2a:	e5298993          	addi	s3,s3,-430 # 80021978 <log>
    80003b2e:	99be                	add	s3,s3,a5
    80003b30:	0189a583          	lw	a1,24(s3)
    80003b34:	fffff097          	auipc	ra,0xfffff
    80003b38:	00e080e7          	jalr	14(ra) # 80002b42 <bread>
    80003b3c:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80003b3e:	02c9a783          	lw	a5,44(s3)
    80003b42:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003b44:	02c9a783          	lw	a5,44(s3)
    80003b48:	02f05763          	blez	a5,80003b76 <write_head+0x68>
    80003b4c:	0a800793          	li	a5,168
    80003b50:	02f487b3          	mul	a5,s1,a5
    80003b54:	0001e717          	auipc	a4,0x1e
    80003b58:	e5470713          	addi	a4,a4,-428 # 800219a8 <log+0x30>
    80003b5c:	97ba                	add	a5,a5,a4
    80003b5e:	06450693          	addi	a3,a0,100
    80003b62:	4701                	li	a4,0
    80003b64:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80003b66:	4390                	lw	a2,0(a5)
    80003b68:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003b6a:	2705                	addiw	a4,a4,1
    80003b6c:	0791                	addi	a5,a5,4
    80003b6e:	0691                	addi	a3,a3,4
    80003b70:	55d0                	lw	a2,44(a1)
    80003b72:	fec74ae3          	blt	a4,a2,80003b66 <write_head+0x58>
  }
  bwrite(buf);
    80003b76:	854a                	mv	a0,s2
    80003b78:	fffff097          	auipc	ra,0xfffff
    80003b7c:	0be080e7          	jalr	190(ra) # 80002c36 <bwrite>
  brelse(buf);
    80003b80:	854a                	mv	a0,s2
    80003b82:	fffff097          	auipc	ra,0xfffff
    80003b86:	0f4080e7          	jalr	244(ra) # 80002c76 <brelse>
}
    80003b8a:	70a2                	ld	ra,40(sp)
    80003b8c:	7402                	ld	s0,32(sp)
    80003b8e:	64e2                	ld	s1,24(sp)
    80003b90:	6942                	ld	s2,16(sp)
    80003b92:	69a2                	ld	s3,8(sp)
    80003b94:	6145                	addi	sp,sp,48
    80003b96:	8082                	ret

0000000080003b98 <write_log>:
static void
write_log(int dev)
{
  int tail;

  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003b98:	0a800793          	li	a5,168
    80003b9c:	02f50733          	mul	a4,a0,a5
    80003ba0:	0001e797          	auipc	a5,0x1e
    80003ba4:	dd878793          	addi	a5,a5,-552 # 80021978 <log>
    80003ba8:	97ba                	add	a5,a5,a4
    80003baa:	57dc                	lw	a5,44(a5)
    80003bac:	0af05663          	blez	a5,80003c58 <write_log+0xc0>
{
    80003bb0:	7139                	addi	sp,sp,-64
    80003bb2:	fc06                	sd	ra,56(sp)
    80003bb4:	f822                	sd	s0,48(sp)
    80003bb6:	f426                	sd	s1,40(sp)
    80003bb8:	f04a                	sd	s2,32(sp)
    80003bba:	ec4e                	sd	s3,24(sp)
    80003bbc:	e852                	sd	s4,16(sp)
    80003bbe:	e456                	sd	s5,8(sp)
    80003bc0:	e05a                	sd	s6,0(sp)
    80003bc2:	0080                	addi	s0,sp,64
    80003bc4:	0001e797          	auipc	a5,0x1e
    80003bc8:	de478793          	addi	a5,a5,-540 # 800219a8 <log+0x30>
    80003bcc:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003bd0:	4981                	li	s3,0
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80003bd2:	00050b1b          	sext.w	s6,a0
    80003bd6:	0001ea97          	auipc	s5,0x1e
    80003bda:	da2a8a93          	addi	s5,s5,-606 # 80021978 <log>
    80003bde:	9aba                	add	s5,s5,a4
    80003be0:	018aa583          	lw	a1,24(s5)
    80003be4:	013585bb          	addw	a1,a1,s3
    80003be8:	2585                	addiw	a1,a1,1
    80003bea:	855a                	mv	a0,s6
    80003bec:	fffff097          	auipc	ra,0xfffff
    80003bf0:	f56080e7          	jalr	-170(ra) # 80002b42 <bread>
    80003bf4:	84aa                	mv	s1,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    80003bf6:	000a2583          	lw	a1,0(s4)
    80003bfa:	855a                	mv	a0,s6
    80003bfc:	fffff097          	auipc	ra,0xfffff
    80003c00:	f46080e7          	jalr	-186(ra) # 80002b42 <bread>
    80003c04:	892a                	mv	s2,a0
    memmove(to->data, from->data, BSIZE);
    80003c06:	40000613          	li	a2,1024
    80003c0a:	06050593          	addi	a1,a0,96
    80003c0e:	06048513          	addi	a0,s1,96
    80003c12:	ffffd097          	auipc	ra,0xffffd
    80003c16:	eca080e7          	jalr	-310(ra) # 80000adc <memmove>
    bwrite(to);  // write the log
    80003c1a:	8526                	mv	a0,s1
    80003c1c:	fffff097          	auipc	ra,0xfffff
    80003c20:	01a080e7          	jalr	26(ra) # 80002c36 <bwrite>
    brelse(from);
    80003c24:	854a                	mv	a0,s2
    80003c26:	fffff097          	auipc	ra,0xfffff
    80003c2a:	050080e7          	jalr	80(ra) # 80002c76 <brelse>
    brelse(to);
    80003c2e:	8526                	mv	a0,s1
    80003c30:	fffff097          	auipc	ra,0xfffff
    80003c34:	046080e7          	jalr	70(ra) # 80002c76 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003c38:	2985                	addiw	s3,s3,1
    80003c3a:	0a11                	addi	s4,s4,4
    80003c3c:	02caa783          	lw	a5,44(s5)
    80003c40:	faf9c0e3          	blt	s3,a5,80003be0 <write_log+0x48>
  }
}
    80003c44:	70e2                	ld	ra,56(sp)
    80003c46:	7442                	ld	s0,48(sp)
    80003c48:	74a2                	ld	s1,40(sp)
    80003c4a:	7902                	ld	s2,32(sp)
    80003c4c:	69e2                	ld	s3,24(sp)
    80003c4e:	6a42                	ld	s4,16(sp)
    80003c50:	6aa2                	ld	s5,8(sp)
    80003c52:	6b02                	ld	s6,0(sp)
    80003c54:	6121                	addi	sp,sp,64
    80003c56:	8082                	ret
    80003c58:	8082                	ret

0000000080003c5a <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003c5a:	0a800793          	li	a5,168
    80003c5e:	02f50733          	mul	a4,a0,a5
    80003c62:	0001e797          	auipc	a5,0x1e
    80003c66:	d1678793          	addi	a5,a5,-746 # 80021978 <log>
    80003c6a:	97ba                	add	a5,a5,a4
    80003c6c:	57dc                	lw	a5,44(a5)
    80003c6e:	0af05b63          	blez	a5,80003d24 <install_trans+0xca>
{
    80003c72:	7139                	addi	sp,sp,-64
    80003c74:	fc06                	sd	ra,56(sp)
    80003c76:	f822                	sd	s0,48(sp)
    80003c78:	f426                	sd	s1,40(sp)
    80003c7a:	f04a                	sd	s2,32(sp)
    80003c7c:	ec4e                	sd	s3,24(sp)
    80003c7e:	e852                	sd	s4,16(sp)
    80003c80:	e456                	sd	s5,8(sp)
    80003c82:	e05a                	sd	s6,0(sp)
    80003c84:	0080                	addi	s0,sp,64
    80003c86:	0001e797          	auipc	a5,0x1e
    80003c8a:	d2278793          	addi	a5,a5,-734 # 800219a8 <log+0x30>
    80003c8e:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003c92:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80003c94:	00050b1b          	sext.w	s6,a0
    80003c98:	0001ea97          	auipc	s5,0x1e
    80003c9c:	ce0a8a93          	addi	s5,s5,-800 # 80021978 <log>
    80003ca0:	9aba                	add	s5,s5,a4
    80003ca2:	018aa583          	lw	a1,24(s5)
    80003ca6:	013585bb          	addw	a1,a1,s3
    80003caa:	2585                	addiw	a1,a1,1
    80003cac:	855a                	mv	a0,s6
    80003cae:	fffff097          	auipc	ra,0xfffff
    80003cb2:	e94080e7          	jalr	-364(ra) # 80002b42 <bread>
    80003cb6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80003cb8:	000a2583          	lw	a1,0(s4)
    80003cbc:	855a                	mv	a0,s6
    80003cbe:	fffff097          	auipc	ra,0xfffff
    80003cc2:	e84080e7          	jalr	-380(ra) # 80002b42 <bread>
    80003cc6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003cc8:	40000613          	li	a2,1024
    80003ccc:	06090593          	addi	a1,s2,96
    80003cd0:	06050513          	addi	a0,a0,96
    80003cd4:	ffffd097          	auipc	ra,0xffffd
    80003cd8:	e08080e7          	jalr	-504(ra) # 80000adc <memmove>
    bwrite(dbuf);  // write dst to disk
    80003cdc:	8526                	mv	a0,s1
    80003cde:	fffff097          	auipc	ra,0xfffff
    80003ce2:	f58080e7          	jalr	-168(ra) # 80002c36 <bwrite>
    bunpin(dbuf);
    80003ce6:	8526                	mv	a0,s1
    80003ce8:	fffff097          	auipc	ra,0xfffff
    80003cec:	068080e7          	jalr	104(ra) # 80002d50 <bunpin>
    brelse(lbuf);
    80003cf0:	854a                	mv	a0,s2
    80003cf2:	fffff097          	auipc	ra,0xfffff
    80003cf6:	f84080e7          	jalr	-124(ra) # 80002c76 <brelse>
    brelse(dbuf);
    80003cfa:	8526                	mv	a0,s1
    80003cfc:	fffff097          	auipc	ra,0xfffff
    80003d00:	f7a080e7          	jalr	-134(ra) # 80002c76 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003d04:	2985                	addiw	s3,s3,1
    80003d06:	0a11                	addi	s4,s4,4
    80003d08:	02caa783          	lw	a5,44(s5)
    80003d0c:	f8f9cbe3          	blt	s3,a5,80003ca2 <install_trans+0x48>
}
    80003d10:	70e2                	ld	ra,56(sp)
    80003d12:	7442                	ld	s0,48(sp)
    80003d14:	74a2                	ld	s1,40(sp)
    80003d16:	7902                	ld	s2,32(sp)
    80003d18:	69e2                	ld	s3,24(sp)
    80003d1a:	6a42                	ld	s4,16(sp)
    80003d1c:	6aa2                	ld	s5,8(sp)
    80003d1e:	6b02                	ld	s6,0(sp)
    80003d20:	6121                	addi	sp,sp,64
    80003d22:	8082                	ret
    80003d24:	8082                	ret

0000000080003d26 <initlog>:
{
    80003d26:	7179                	addi	sp,sp,-48
    80003d28:	f406                	sd	ra,40(sp)
    80003d2a:	f022                	sd	s0,32(sp)
    80003d2c:	ec26                	sd	s1,24(sp)
    80003d2e:	e84a                	sd	s2,16(sp)
    80003d30:	e44e                	sd	s3,8(sp)
    80003d32:	e052                	sd	s4,0(sp)
    80003d34:	1800                	addi	s0,sp,48
    80003d36:	892a                	mv	s2,a0
    80003d38:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80003d3a:	0a800713          	li	a4,168
    80003d3e:	02e504b3          	mul	s1,a0,a4
    80003d42:	0001e997          	auipc	s3,0x1e
    80003d46:	c3698993          	addi	s3,s3,-970 # 80021978 <log>
    80003d4a:	99a6                	add	s3,s3,s1
    80003d4c:	00004597          	auipc	a1,0x4
    80003d50:	88c58593          	addi	a1,a1,-1908 # 800075d8 <userret+0x548>
    80003d54:	854e                	mv	a0,s3
    80003d56:	ffffd097          	auipc	ra,0xffffd
    80003d5a:	b58080e7          	jalr	-1192(ra) # 800008ae <initlock>
  log[dev].start = sb->logstart;
    80003d5e:	014a2583          	lw	a1,20(s4)
    80003d62:	00b9ac23          	sw	a1,24(s3)
  log[dev].size = sb->nlog;
    80003d66:	010a2783          	lw	a5,16(s4)
    80003d6a:	00f9ae23          	sw	a5,28(s3)
  log[dev].dev = dev;
    80003d6e:	0329a423          	sw	s2,40(s3)
  struct buf *buf = bread(dev, log[dev].start);
    80003d72:	854a                	mv	a0,s2
    80003d74:	fffff097          	auipc	ra,0xfffff
    80003d78:	dce080e7          	jalr	-562(ra) # 80002b42 <bread>
  log[dev].lh.n = lh->n;
    80003d7c:	5134                	lw	a3,96(a0)
    80003d7e:	02d9a623          	sw	a3,44(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003d82:	02d05663          	blez	a3,80003dae <initlog+0x88>
    80003d86:	06450793          	addi	a5,a0,100
    80003d8a:	0001e717          	auipc	a4,0x1e
    80003d8e:	c1e70713          	addi	a4,a4,-994 # 800219a8 <log+0x30>
    80003d92:	9726                	add	a4,a4,s1
    80003d94:	36fd                	addiw	a3,a3,-1
    80003d96:	1682                	slli	a3,a3,0x20
    80003d98:	9281                	srli	a3,a3,0x20
    80003d9a:	068a                	slli	a3,a3,0x2
    80003d9c:	06850613          	addi	a2,a0,104
    80003da0:	96b2                	add	a3,a3,a2
    log[dev].lh.block[i] = lh->block[i];
    80003da2:	4390                	lw	a2,0(a5)
    80003da4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003da6:	0791                	addi	a5,a5,4
    80003da8:	0711                	addi	a4,a4,4
    80003daa:	fed79ce3          	bne	a5,a3,80003da2 <initlog+0x7c>
  brelse(buf);
    80003dae:	fffff097          	auipc	ra,0xfffff
    80003db2:	ec8080e7          	jalr	-312(ra) # 80002c76 <brelse>
  install_trans(dev); // if committed, copy from log to disk
    80003db6:	854a                	mv	a0,s2
    80003db8:	00000097          	auipc	ra,0x0
    80003dbc:	ea2080e7          	jalr	-350(ra) # 80003c5a <install_trans>
  log[dev].lh.n = 0;
    80003dc0:	0a800793          	li	a5,168
    80003dc4:	02f90733          	mul	a4,s2,a5
    80003dc8:	0001e797          	auipc	a5,0x1e
    80003dcc:	bb078793          	addi	a5,a5,-1104 # 80021978 <log>
    80003dd0:	97ba                	add	a5,a5,a4
    80003dd2:	0207a623          	sw	zero,44(a5)
  write_head(dev); // clear the log
    80003dd6:	854a                	mv	a0,s2
    80003dd8:	00000097          	auipc	ra,0x0
    80003ddc:	d36080e7          	jalr	-714(ra) # 80003b0e <write_head>
}
    80003de0:	70a2                	ld	ra,40(sp)
    80003de2:	7402                	ld	s0,32(sp)
    80003de4:	64e2                	ld	s1,24(sp)
    80003de6:	6942                	ld	s2,16(sp)
    80003de8:	69a2                	ld	s3,8(sp)
    80003dea:	6a02                	ld	s4,0(sp)
    80003dec:	6145                	addi	sp,sp,48
    80003dee:	8082                	ret

0000000080003df0 <begin_op>:
{
    80003df0:	7139                	addi	sp,sp,-64
    80003df2:	fc06                	sd	ra,56(sp)
    80003df4:	f822                	sd	s0,48(sp)
    80003df6:	f426                	sd	s1,40(sp)
    80003df8:	f04a                	sd	s2,32(sp)
    80003dfa:	ec4e                	sd	s3,24(sp)
    80003dfc:	e852                	sd	s4,16(sp)
    80003dfe:	e456                	sd	s5,8(sp)
    80003e00:	0080                	addi	s0,sp,64
    80003e02:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    80003e04:	0a800913          	li	s2,168
    80003e08:	032507b3          	mul	a5,a0,s2
    80003e0c:	0001e917          	auipc	s2,0x1e
    80003e10:	b6c90913          	addi	s2,s2,-1172 # 80021978 <log>
    80003e14:	993e                	add	s2,s2,a5
    80003e16:	854a                	mv	a0,s2
    80003e18:	ffffd097          	auipc	ra,0xffffd
    80003e1c:	ba4080e7          	jalr	-1116(ra) # 800009bc <acquire>
    if(log[dev].committing){
    80003e20:	0001e997          	auipc	s3,0x1e
    80003e24:	b5898993          	addi	s3,s3,-1192 # 80021978 <log>
    80003e28:	84ca                	mv	s1,s2
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003e2a:	4a79                	li	s4,30
    80003e2c:	a039                	j	80003e3a <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    80003e2e:	85ca                	mv	a1,s2
    80003e30:	854e                	mv	a0,s3
    80003e32:	ffffe097          	auipc	ra,0xffffe
    80003e36:	100080e7          	jalr	256(ra) # 80001f32 <sleep>
    if(log[dev].committing){
    80003e3a:	50dc                	lw	a5,36(s1)
    80003e3c:	fbed                	bnez	a5,80003e2e <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003e3e:	509c                	lw	a5,32(s1)
    80003e40:	0017871b          	addiw	a4,a5,1
    80003e44:	0007069b          	sext.w	a3,a4
    80003e48:	0027179b          	slliw	a5,a4,0x2
    80003e4c:	9fb9                	addw	a5,a5,a4
    80003e4e:	0017979b          	slliw	a5,a5,0x1
    80003e52:	54d8                	lw	a4,44(s1)
    80003e54:	9fb9                	addw	a5,a5,a4
    80003e56:	00fa5963          	bge	s4,a5,80003e68 <begin_op+0x78>
      sleep(&log, &log[dev].lock);
    80003e5a:	85ca                	mv	a1,s2
    80003e5c:	854e                	mv	a0,s3
    80003e5e:	ffffe097          	auipc	ra,0xffffe
    80003e62:	0d4080e7          	jalr	212(ra) # 80001f32 <sleep>
    80003e66:	bfd1                	j	80003e3a <begin_op+0x4a>
      log[dev].outstanding += 1;
    80003e68:	0a800513          	li	a0,168
    80003e6c:	02aa8ab3          	mul	s5,s5,a0
    80003e70:	0001e797          	auipc	a5,0x1e
    80003e74:	b0878793          	addi	a5,a5,-1272 # 80021978 <log>
    80003e78:	9abe                	add	s5,s5,a5
    80003e7a:	02daa023          	sw	a3,32(s5)
      release(&log[dev].lock);
    80003e7e:	854a                	mv	a0,s2
    80003e80:	ffffd097          	auipc	ra,0xffffd
    80003e84:	ba4080e7          	jalr	-1116(ra) # 80000a24 <release>
}
    80003e88:	70e2                	ld	ra,56(sp)
    80003e8a:	7442                	ld	s0,48(sp)
    80003e8c:	74a2                	ld	s1,40(sp)
    80003e8e:	7902                	ld	s2,32(sp)
    80003e90:	69e2                	ld	s3,24(sp)
    80003e92:	6a42                	ld	s4,16(sp)
    80003e94:	6aa2                	ld	s5,8(sp)
    80003e96:	6121                	addi	sp,sp,64
    80003e98:	8082                	ret

0000000080003e9a <end_op>:
{
    80003e9a:	7179                	addi	sp,sp,-48
    80003e9c:	f406                	sd	ra,40(sp)
    80003e9e:	f022                	sd	s0,32(sp)
    80003ea0:	ec26                	sd	s1,24(sp)
    80003ea2:	e84a                	sd	s2,16(sp)
    80003ea4:	e44e                	sd	s3,8(sp)
    80003ea6:	1800                	addi	s0,sp,48
    80003ea8:	892a                	mv	s2,a0
  acquire(&log[dev].lock);
    80003eaa:	0a800493          	li	s1,168
    80003eae:	029507b3          	mul	a5,a0,s1
    80003eb2:	0001e497          	auipc	s1,0x1e
    80003eb6:	ac648493          	addi	s1,s1,-1338 # 80021978 <log>
    80003eba:	94be                	add	s1,s1,a5
    80003ebc:	8526                	mv	a0,s1
    80003ebe:	ffffd097          	auipc	ra,0xffffd
    80003ec2:	afe080e7          	jalr	-1282(ra) # 800009bc <acquire>
  log[dev].outstanding -= 1;
    80003ec6:	509c                	lw	a5,32(s1)
    80003ec8:	37fd                	addiw	a5,a5,-1
    80003eca:	0007871b          	sext.w	a4,a5
    80003ece:	d09c                	sw	a5,32(s1)
  if(log[dev].committing)
    80003ed0:	50dc                	lw	a5,36(s1)
    80003ed2:	e3ad                	bnez	a5,80003f34 <end_op+0x9a>
  if(log[dev].outstanding == 0){
    80003ed4:	eb25                	bnez	a4,80003f44 <end_op+0xaa>
    log[dev].committing = 1;
    80003ed6:	0a800993          	li	s3,168
    80003eda:	033907b3          	mul	a5,s2,s3
    80003ede:	0001e997          	auipc	s3,0x1e
    80003ee2:	a9a98993          	addi	s3,s3,-1382 # 80021978 <log>
    80003ee6:	99be                	add	s3,s3,a5
    80003ee8:	4785                	li	a5,1
    80003eea:	02f9a223          	sw	a5,36(s3)
  release(&log[dev].lock);
    80003eee:	8526                	mv	a0,s1
    80003ef0:	ffffd097          	auipc	ra,0xffffd
    80003ef4:	b34080e7          	jalr	-1228(ra) # 80000a24 <release>

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    80003ef8:	02c9a783          	lw	a5,44(s3)
    80003efc:	06f04863          	bgtz	a5,80003f6c <end_op+0xd2>
    acquire(&log[dev].lock);
    80003f00:	8526                	mv	a0,s1
    80003f02:	ffffd097          	auipc	ra,0xffffd
    80003f06:	aba080e7          	jalr	-1350(ra) # 800009bc <acquire>
    log[dev].committing = 0;
    80003f0a:	0001e517          	auipc	a0,0x1e
    80003f0e:	a6e50513          	addi	a0,a0,-1426 # 80021978 <log>
    80003f12:	0a800793          	li	a5,168
    80003f16:	02f90933          	mul	s2,s2,a5
    80003f1a:	992a                	add	s2,s2,a0
    80003f1c:	02092223          	sw	zero,36(s2)
    wakeup(&log);
    80003f20:	ffffe097          	auipc	ra,0xffffe
    80003f24:	192080e7          	jalr	402(ra) # 800020b2 <wakeup>
    release(&log[dev].lock);
    80003f28:	8526                	mv	a0,s1
    80003f2a:	ffffd097          	auipc	ra,0xffffd
    80003f2e:	afa080e7          	jalr	-1286(ra) # 80000a24 <release>
}
    80003f32:	a035                	j	80003f5e <end_op+0xc4>
    panic("log[dev].committing");
    80003f34:	00003517          	auipc	a0,0x3
    80003f38:	6ac50513          	addi	a0,a0,1708 # 800075e0 <userret+0x550>
    80003f3c:	ffffc097          	auipc	ra,0xffffc
    80003f40:	60c080e7          	jalr	1548(ra) # 80000548 <panic>
    wakeup(&log);
    80003f44:	0001e517          	auipc	a0,0x1e
    80003f48:	a3450513          	addi	a0,a0,-1484 # 80021978 <log>
    80003f4c:	ffffe097          	auipc	ra,0xffffe
    80003f50:	166080e7          	jalr	358(ra) # 800020b2 <wakeup>
  release(&log[dev].lock);
    80003f54:	8526                	mv	a0,s1
    80003f56:	ffffd097          	auipc	ra,0xffffd
    80003f5a:	ace080e7          	jalr	-1330(ra) # 80000a24 <release>
}
    80003f5e:	70a2                	ld	ra,40(sp)
    80003f60:	7402                	ld	s0,32(sp)
    80003f62:	64e2                	ld	s1,24(sp)
    80003f64:	6942                	ld	s2,16(sp)
    80003f66:	69a2                	ld	s3,8(sp)
    80003f68:	6145                	addi	sp,sp,48
    80003f6a:	8082                	ret
    write_log(dev);     // Write modified blocks from cache to log
    80003f6c:	854a                	mv	a0,s2
    80003f6e:	00000097          	auipc	ra,0x0
    80003f72:	c2a080e7          	jalr	-982(ra) # 80003b98 <write_log>
    write_head(dev);    // Write header to disk -- the real commit
    80003f76:	854a                	mv	a0,s2
    80003f78:	00000097          	auipc	ra,0x0
    80003f7c:	b96080e7          	jalr	-1130(ra) # 80003b0e <write_head>
    install_trans(dev); // Now install writes to home locations
    80003f80:	854a                	mv	a0,s2
    80003f82:	00000097          	auipc	ra,0x0
    80003f86:	cd8080e7          	jalr	-808(ra) # 80003c5a <install_trans>
    log[dev].lh.n = 0;
    80003f8a:	0a800793          	li	a5,168
    80003f8e:	02f90733          	mul	a4,s2,a5
    80003f92:	0001e797          	auipc	a5,0x1e
    80003f96:	9e678793          	addi	a5,a5,-1562 # 80021978 <log>
    80003f9a:	97ba                	add	a5,a5,a4
    80003f9c:	0207a623          	sw	zero,44(a5)
    write_head(dev);    // Erase the transaction from the log
    80003fa0:	854a                	mv	a0,s2
    80003fa2:	00000097          	auipc	ra,0x0
    80003fa6:	b6c080e7          	jalr	-1172(ra) # 80003b0e <write_head>
    80003faa:	bf99                	j	80003f00 <end_op+0x66>

0000000080003fac <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003fac:	7179                	addi	sp,sp,-48
    80003fae:	f406                	sd	ra,40(sp)
    80003fb0:	f022                	sd	s0,32(sp)
    80003fb2:	ec26                	sd	s1,24(sp)
    80003fb4:	e84a                	sd	s2,16(sp)
    80003fb6:	e44e                	sd	s3,8(sp)
    80003fb8:	e052                	sd	s4,0(sp)
    80003fba:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80003fbc:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80003fc0:	0a800793          	li	a5,168
    80003fc4:	02f90733          	mul	a4,s2,a5
    80003fc8:	0001e797          	auipc	a5,0x1e
    80003fcc:	9b078793          	addi	a5,a5,-1616 # 80021978 <log>
    80003fd0:	97ba                	add	a5,a5,a4
    80003fd2:	57d4                	lw	a3,44(a5)
    80003fd4:	47f5                	li	a5,29
    80003fd6:	0ad7cc63          	blt	a5,a3,8000408e <log_write+0xe2>
    80003fda:	89aa                	mv	s3,a0
    80003fdc:	0001e797          	auipc	a5,0x1e
    80003fe0:	99c78793          	addi	a5,a5,-1636 # 80021978 <log>
    80003fe4:	97ba                	add	a5,a5,a4
    80003fe6:	4fdc                	lw	a5,28(a5)
    80003fe8:	37fd                	addiw	a5,a5,-1
    80003fea:	0af6d263          	bge	a3,a5,8000408e <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80003fee:	0a800793          	li	a5,168
    80003ff2:	02f90733          	mul	a4,s2,a5
    80003ff6:	0001e797          	auipc	a5,0x1e
    80003ffa:	98278793          	addi	a5,a5,-1662 # 80021978 <log>
    80003ffe:	97ba                	add	a5,a5,a4
    80004000:	539c                	lw	a5,32(a5)
    80004002:	08f05e63          	blez	a5,8000409e <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    80004006:	0a800793          	li	a5,168
    8000400a:	02f904b3          	mul	s1,s2,a5
    8000400e:	0001ea17          	auipc	s4,0x1e
    80004012:	96aa0a13          	addi	s4,s4,-1686 # 80021978 <log>
    80004016:	9a26                	add	s4,s4,s1
    80004018:	8552                	mv	a0,s4
    8000401a:	ffffd097          	auipc	ra,0xffffd
    8000401e:	9a2080e7          	jalr	-1630(ra) # 800009bc <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004022:	02ca2603          	lw	a2,44(s4)
    80004026:	08c05463          	blez	a2,800040ae <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000402a:	00c9a583          	lw	a1,12(s3)
    8000402e:	0001e797          	auipc	a5,0x1e
    80004032:	97a78793          	addi	a5,a5,-1670 # 800219a8 <log+0x30>
    80004036:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    80004038:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000403a:	4394                	lw	a3,0(a5)
    8000403c:	06b68a63          	beq	a3,a1,800040b0 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004040:	2705                	addiw	a4,a4,1
    80004042:	0791                	addi	a5,a5,4
    80004044:	fec71be3          	bne	a4,a2,8000403a <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    80004048:	02a00793          	li	a5,42
    8000404c:	02f907b3          	mul	a5,s2,a5
    80004050:	97b2                	add	a5,a5,a2
    80004052:	07a1                	addi	a5,a5,8
    80004054:	078a                	slli	a5,a5,0x2
    80004056:	0001e717          	auipc	a4,0x1e
    8000405a:	92270713          	addi	a4,a4,-1758 # 80021978 <log>
    8000405e:	97ba                	add	a5,a5,a4
    80004060:	00c9a703          	lw	a4,12(s3)
    80004064:	cb98                	sw	a4,16(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    80004066:	854e                	mv	a0,s3
    80004068:	fffff097          	auipc	ra,0xfffff
    8000406c:	cac080e7          	jalr	-852(ra) # 80002d14 <bpin>
    log[dev].lh.n++;
    80004070:	0a800793          	li	a5,168
    80004074:	02f90933          	mul	s2,s2,a5
    80004078:	0001e797          	auipc	a5,0x1e
    8000407c:	90078793          	addi	a5,a5,-1792 # 80021978 <log>
    80004080:	993e                	add	s2,s2,a5
    80004082:	02c92783          	lw	a5,44(s2)
    80004086:	2785                	addiw	a5,a5,1
    80004088:	02f92623          	sw	a5,44(s2)
    8000408c:	a099                	j	800040d2 <log_write+0x126>
    panic("too big a transaction");
    8000408e:	00003517          	auipc	a0,0x3
    80004092:	56a50513          	addi	a0,a0,1386 # 800075f8 <userret+0x568>
    80004096:	ffffc097          	auipc	ra,0xffffc
    8000409a:	4b2080e7          	jalr	1202(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    8000409e:	00003517          	auipc	a0,0x3
    800040a2:	57250513          	addi	a0,a0,1394 # 80007610 <userret+0x580>
    800040a6:	ffffc097          	auipc	ra,0xffffc
    800040aa:	4a2080e7          	jalr	1186(ra) # 80000548 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    800040ae:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    800040b0:	02a00793          	li	a5,42
    800040b4:	02f907b3          	mul	a5,s2,a5
    800040b8:	97ba                	add	a5,a5,a4
    800040ba:	07a1                	addi	a5,a5,8
    800040bc:	078a                	slli	a5,a5,0x2
    800040be:	0001e697          	auipc	a3,0x1e
    800040c2:	8ba68693          	addi	a3,a3,-1862 # 80021978 <log>
    800040c6:	97b6                	add	a5,a5,a3
    800040c8:	00c9a683          	lw	a3,12(s3)
    800040cc:	cb94                	sw	a3,16(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    800040ce:	f8e60ce3          	beq	a2,a4,80004066 <log_write+0xba>
  }
  release(&log[dev].lock);
    800040d2:	8552                	mv	a0,s4
    800040d4:	ffffd097          	auipc	ra,0xffffd
    800040d8:	950080e7          	jalr	-1712(ra) # 80000a24 <release>
}
    800040dc:	70a2                	ld	ra,40(sp)
    800040de:	7402                	ld	s0,32(sp)
    800040e0:	64e2                	ld	s1,24(sp)
    800040e2:	6942                	ld	s2,16(sp)
    800040e4:	69a2                	ld	s3,8(sp)
    800040e6:	6a02                	ld	s4,0(sp)
    800040e8:	6145                	addi	sp,sp,48
    800040ea:	8082                	ret

00000000800040ec <crash_op>:

// crash before commit or after commit
void
crash_op(int dev, int docommit)
{
    800040ec:	7179                	addi	sp,sp,-48
    800040ee:	f406                	sd	ra,40(sp)
    800040f0:	f022                	sd	s0,32(sp)
    800040f2:	ec26                	sd	s1,24(sp)
    800040f4:	e84a                	sd	s2,16(sp)
    800040f6:	e44e                	sd	s3,8(sp)
    800040f8:	1800                	addi	s0,sp,48
    800040fa:	84aa                	mv	s1,a0
    800040fc:	89ae                	mv	s3,a1
  int do_commit = 0;
    
  acquire(&log[dev].lock);
    800040fe:	0a800913          	li	s2,168
    80004102:	032507b3          	mul	a5,a0,s2
    80004106:	0001e917          	auipc	s2,0x1e
    8000410a:	87290913          	addi	s2,s2,-1934 # 80021978 <log>
    8000410e:	993e                	add	s2,s2,a5
    80004110:	854a                	mv	a0,s2
    80004112:	ffffd097          	auipc	ra,0xffffd
    80004116:	8aa080e7          	jalr	-1878(ra) # 800009bc <acquire>

  if (dev < 0 || dev >= NDISK)
    8000411a:	0004871b          	sext.w	a4,s1
    8000411e:	4785                	li	a5,1
    80004120:	0ae7e063          	bltu	a5,a4,800041c0 <crash_op+0xd4>
    panic("end_op: invalid disk");
  if(log[dev].outstanding == 0)
    80004124:	0a800793          	li	a5,168
    80004128:	02f48733          	mul	a4,s1,a5
    8000412c:	0001e797          	auipc	a5,0x1e
    80004130:	84c78793          	addi	a5,a5,-1972 # 80021978 <log>
    80004134:	97ba                	add	a5,a5,a4
    80004136:	539c                	lw	a5,32(a5)
    80004138:	cfc1                	beqz	a5,800041d0 <crash_op+0xe4>
    panic("end_op: already closed");
  log[dev].outstanding -= 1;
    8000413a:	37fd                	addiw	a5,a5,-1
    8000413c:	0007861b          	sext.w	a2,a5
    80004140:	0a800713          	li	a4,168
    80004144:	02e486b3          	mul	a3,s1,a4
    80004148:	0001e717          	auipc	a4,0x1e
    8000414c:	83070713          	addi	a4,a4,-2000 # 80021978 <log>
    80004150:	9736                	add	a4,a4,a3
    80004152:	d31c                	sw	a5,32(a4)
  if(log[dev].committing)
    80004154:	535c                	lw	a5,36(a4)
    80004156:	e7c9                	bnez	a5,800041e0 <crash_op+0xf4>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    80004158:	ee41                	bnez	a2,800041f0 <crash_op+0x104>
    do_commit = 1;
    log[dev].committing = 1;
    8000415a:	0a800793          	li	a5,168
    8000415e:	02f48733          	mul	a4,s1,a5
    80004162:	0001e797          	auipc	a5,0x1e
    80004166:	81678793          	addi	a5,a5,-2026 # 80021978 <log>
    8000416a:	97ba                	add	a5,a5,a4
    8000416c:	4705                	li	a4,1
    8000416e:	d3d8                	sw	a4,36(a5)
  }
  
  release(&log[dev].lock);
    80004170:	854a                	mv	a0,s2
    80004172:	ffffd097          	auipc	ra,0xffffd
    80004176:	8b2080e7          	jalr	-1870(ra) # 80000a24 <release>

  if(docommit & do_commit){
    8000417a:	0019f993          	andi	s3,s3,1
    8000417e:	06098e63          	beqz	s3,800041fa <crash_op+0x10e>
    printf("crash_op: commit\n");
    80004182:	00003517          	auipc	a0,0x3
    80004186:	4de50513          	addi	a0,a0,1246 # 80007660 <userret+0x5d0>
    8000418a:	ffffc097          	auipc	ra,0xffffc
    8000418e:	408080e7          	jalr	1032(ra) # 80000592 <printf>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.

    if (log[dev].lh.n > 0) {
    80004192:	0a800793          	li	a5,168
    80004196:	02f48733          	mul	a4,s1,a5
    8000419a:	0001d797          	auipc	a5,0x1d
    8000419e:	7de78793          	addi	a5,a5,2014 # 80021978 <log>
    800041a2:	97ba                	add	a5,a5,a4
    800041a4:	57dc                	lw	a5,44(a5)
    800041a6:	04f05a63          	blez	a5,800041fa <crash_op+0x10e>
      write_log(dev);     // Write modified blocks from cache to log
    800041aa:	8526                	mv	a0,s1
    800041ac:	00000097          	auipc	ra,0x0
    800041b0:	9ec080e7          	jalr	-1556(ra) # 80003b98 <write_log>
      write_head(dev);    // Write header to disk -- the real commit
    800041b4:	8526                	mv	a0,s1
    800041b6:	00000097          	auipc	ra,0x0
    800041ba:	958080e7          	jalr	-1704(ra) # 80003b0e <write_head>
    800041be:	a835                	j	800041fa <crash_op+0x10e>
    panic("end_op: invalid disk");
    800041c0:	00003517          	auipc	a0,0x3
    800041c4:	47050513          	addi	a0,a0,1136 # 80007630 <userret+0x5a0>
    800041c8:	ffffc097          	auipc	ra,0xffffc
    800041cc:	380080e7          	jalr	896(ra) # 80000548 <panic>
    panic("end_op: already closed");
    800041d0:	00003517          	auipc	a0,0x3
    800041d4:	47850513          	addi	a0,a0,1144 # 80007648 <userret+0x5b8>
    800041d8:	ffffc097          	auipc	ra,0xffffc
    800041dc:	370080e7          	jalr	880(ra) # 80000548 <panic>
    panic("log[dev].committing");
    800041e0:	00003517          	auipc	a0,0x3
    800041e4:	40050513          	addi	a0,a0,1024 # 800075e0 <userret+0x550>
    800041e8:	ffffc097          	auipc	ra,0xffffc
    800041ec:	360080e7          	jalr	864(ra) # 80000548 <panic>
  release(&log[dev].lock);
    800041f0:	854a                	mv	a0,s2
    800041f2:	ffffd097          	auipc	ra,0xffffd
    800041f6:	832080e7          	jalr	-1998(ra) # 80000a24 <release>
    }
  }
  panic("crashed file system; please restart xv6 and run crashtest\n");
    800041fa:	00003517          	auipc	a0,0x3
    800041fe:	47e50513          	addi	a0,a0,1150 # 80007678 <userret+0x5e8>
    80004202:	ffffc097          	auipc	ra,0xffffc
    80004206:	346080e7          	jalr	838(ra) # 80000548 <panic>

000000008000420a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000420a:	1101                	addi	sp,sp,-32
    8000420c:	ec06                	sd	ra,24(sp)
    8000420e:	e822                	sd	s0,16(sp)
    80004210:	e426                	sd	s1,8(sp)
    80004212:	e04a                	sd	s2,0(sp)
    80004214:	1000                	addi	s0,sp,32
    80004216:	84aa                	mv	s1,a0
    80004218:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000421a:	00003597          	auipc	a1,0x3
    8000421e:	49e58593          	addi	a1,a1,1182 # 800076b8 <userret+0x628>
    80004222:	0521                	addi	a0,a0,8
    80004224:	ffffc097          	auipc	ra,0xffffc
    80004228:	68a080e7          	jalr	1674(ra) # 800008ae <initlock>
  lk->name = name;
    8000422c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004230:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004234:	0204a423          	sw	zero,40(s1)
}
    80004238:	60e2                	ld	ra,24(sp)
    8000423a:	6442                	ld	s0,16(sp)
    8000423c:	64a2                	ld	s1,8(sp)
    8000423e:	6902                	ld	s2,0(sp)
    80004240:	6105                	addi	sp,sp,32
    80004242:	8082                	ret

0000000080004244 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004244:	1101                	addi	sp,sp,-32
    80004246:	ec06                	sd	ra,24(sp)
    80004248:	e822                	sd	s0,16(sp)
    8000424a:	e426                	sd	s1,8(sp)
    8000424c:	e04a                	sd	s2,0(sp)
    8000424e:	1000                	addi	s0,sp,32
    80004250:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004252:	00850913          	addi	s2,a0,8
    80004256:	854a                	mv	a0,s2
    80004258:	ffffc097          	auipc	ra,0xffffc
    8000425c:	764080e7          	jalr	1892(ra) # 800009bc <acquire>
  while (lk->locked) {
    80004260:	409c                	lw	a5,0(s1)
    80004262:	cb89                	beqz	a5,80004274 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004264:	85ca                	mv	a1,s2
    80004266:	8526                	mv	a0,s1
    80004268:	ffffe097          	auipc	ra,0xffffe
    8000426c:	cca080e7          	jalr	-822(ra) # 80001f32 <sleep>
  while (lk->locked) {
    80004270:	409c                	lw	a5,0(s1)
    80004272:	fbed                	bnez	a5,80004264 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004274:	4785                	li	a5,1
    80004276:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004278:	ffffd097          	auipc	ra,0xffffd
    8000427c:	4a4080e7          	jalr	1188(ra) # 8000171c <myproc>
    80004280:	5d1c                	lw	a5,56(a0)
    80004282:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004284:	854a                	mv	a0,s2
    80004286:	ffffc097          	auipc	ra,0xffffc
    8000428a:	79e080e7          	jalr	1950(ra) # 80000a24 <release>
}
    8000428e:	60e2                	ld	ra,24(sp)
    80004290:	6442                	ld	s0,16(sp)
    80004292:	64a2                	ld	s1,8(sp)
    80004294:	6902                	ld	s2,0(sp)
    80004296:	6105                	addi	sp,sp,32
    80004298:	8082                	ret

000000008000429a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000429a:	1101                	addi	sp,sp,-32
    8000429c:	ec06                	sd	ra,24(sp)
    8000429e:	e822                	sd	s0,16(sp)
    800042a0:	e426                	sd	s1,8(sp)
    800042a2:	e04a                	sd	s2,0(sp)
    800042a4:	1000                	addi	s0,sp,32
    800042a6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042a8:	00850913          	addi	s2,a0,8
    800042ac:	854a                	mv	a0,s2
    800042ae:	ffffc097          	auipc	ra,0xffffc
    800042b2:	70e080e7          	jalr	1806(ra) # 800009bc <acquire>
  lk->locked = 0;
    800042b6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042ba:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800042be:	8526                	mv	a0,s1
    800042c0:	ffffe097          	auipc	ra,0xffffe
    800042c4:	df2080e7          	jalr	-526(ra) # 800020b2 <wakeup>
  release(&lk->lk);
    800042c8:	854a                	mv	a0,s2
    800042ca:	ffffc097          	auipc	ra,0xffffc
    800042ce:	75a080e7          	jalr	1882(ra) # 80000a24 <release>
}
    800042d2:	60e2                	ld	ra,24(sp)
    800042d4:	6442                	ld	s0,16(sp)
    800042d6:	64a2                	ld	s1,8(sp)
    800042d8:	6902                	ld	s2,0(sp)
    800042da:	6105                	addi	sp,sp,32
    800042dc:	8082                	ret

00000000800042de <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800042de:	7179                	addi	sp,sp,-48
    800042e0:	f406                	sd	ra,40(sp)
    800042e2:	f022                	sd	s0,32(sp)
    800042e4:	ec26                	sd	s1,24(sp)
    800042e6:	e84a                	sd	s2,16(sp)
    800042e8:	e44e                	sd	s3,8(sp)
    800042ea:	1800                	addi	s0,sp,48
    800042ec:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800042ee:	00850913          	addi	s2,a0,8
    800042f2:	854a                	mv	a0,s2
    800042f4:	ffffc097          	auipc	ra,0xffffc
    800042f8:	6c8080e7          	jalr	1736(ra) # 800009bc <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800042fc:	409c                	lw	a5,0(s1)
    800042fe:	ef99                	bnez	a5,8000431c <holdingsleep+0x3e>
    80004300:	4481                	li	s1,0
  release(&lk->lk);
    80004302:	854a                	mv	a0,s2
    80004304:	ffffc097          	auipc	ra,0xffffc
    80004308:	720080e7          	jalr	1824(ra) # 80000a24 <release>
  return r;
}
    8000430c:	8526                	mv	a0,s1
    8000430e:	70a2                	ld	ra,40(sp)
    80004310:	7402                	ld	s0,32(sp)
    80004312:	64e2                	ld	s1,24(sp)
    80004314:	6942                	ld	s2,16(sp)
    80004316:	69a2                	ld	s3,8(sp)
    80004318:	6145                	addi	sp,sp,48
    8000431a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000431c:	0284a983          	lw	s3,40(s1)
    80004320:	ffffd097          	auipc	ra,0xffffd
    80004324:	3fc080e7          	jalr	1020(ra) # 8000171c <myproc>
    80004328:	5d04                	lw	s1,56(a0)
    8000432a:	413484b3          	sub	s1,s1,s3
    8000432e:	0014b493          	seqz	s1,s1
    80004332:	bfc1                	j	80004302 <holdingsleep+0x24>

0000000080004334 <fileinit>:
  //struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004334:	1141                	addi	sp,sp,-16
    80004336:	e406                	sd	ra,8(sp)
    80004338:	e022                	sd	s0,0(sp)
    8000433a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000433c:	00003597          	auipc	a1,0x3
    80004340:	38c58593          	addi	a1,a1,908 # 800076c8 <userret+0x638>
    80004344:	0001d517          	auipc	a0,0x1d
    80004348:	78450513          	addi	a0,a0,1924 # 80021ac8 <ftable>
    8000434c:	ffffc097          	auipc	ra,0xffffc
    80004350:	562080e7          	jalr	1378(ra) # 800008ae <initlock>
}
    80004354:	60a2                	ld	ra,8(sp)
    80004356:	6402                	ld	s0,0(sp)
    80004358:	0141                	addi	sp,sp,16
    8000435a:	8082                	ret

000000008000435c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000435c:	1101                	addi	sp,sp,-32
    8000435e:	ec06                	sd	ra,24(sp)
    80004360:	e822                	sd	s0,16(sp)
    80004362:	e426                	sd	s1,8(sp)
    80004364:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004366:	0001d517          	auipc	a0,0x1d
    8000436a:	76250513          	addi	a0,a0,1890 # 80021ac8 <ftable>
    8000436e:	ffffc097          	auipc	ra,0xffffc
    80004372:	64e080e7          	jalr	1614(ra) # 800009bc <acquire>
  f = bd_malloc(sizeof(*f));
    80004376:	02800513          	li	a0,40
    8000437a:	00002097          	auipc	ra,0x2
    8000437e:	268080e7          	jalr	616(ra) # 800065e2 <bd_malloc>
  if(f->ref == 0){
    80004382:	415c                	lw	a5,4(a0)
    80004384:	e395                	bnez	a5,800043a8 <filealloc+0x4c>
    80004386:	84aa                	mv	s1,a0
    f->ref = 1;
    80004388:	4785                	li	a5,1
    8000438a:	c15c                	sw	a5,4(a0)
    release(&ftable.lock);
    8000438c:	0001d517          	auipc	a0,0x1d
    80004390:	73c50513          	addi	a0,a0,1852 # 80021ac8 <ftable>
    80004394:	ffffc097          	auipc	ra,0xffffc
    80004398:	690080e7          	jalr	1680(ra) # 80000a24 <release>
    return f;
  } 
  release(&ftable.lock);
  return 0;
}
    8000439c:	8526                	mv	a0,s1
    8000439e:	60e2                	ld	ra,24(sp)
    800043a0:	6442                	ld	s0,16(sp)
    800043a2:	64a2                	ld	s1,8(sp)
    800043a4:	6105                	addi	sp,sp,32
    800043a6:	8082                	ret
  release(&ftable.lock);
    800043a8:	0001d517          	auipc	a0,0x1d
    800043ac:	72050513          	addi	a0,a0,1824 # 80021ac8 <ftable>
    800043b0:	ffffc097          	auipc	ra,0xffffc
    800043b4:	674080e7          	jalr	1652(ra) # 80000a24 <release>
  return 0;
    800043b8:	4481                	li	s1,0
    800043ba:	b7cd                	j	8000439c <filealloc+0x40>

00000000800043bc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800043bc:	1101                	addi	sp,sp,-32
    800043be:	ec06                	sd	ra,24(sp)
    800043c0:	e822                	sd	s0,16(sp)
    800043c2:	e426                	sd	s1,8(sp)
    800043c4:	1000                	addi	s0,sp,32
    800043c6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800043c8:	0001d517          	auipc	a0,0x1d
    800043cc:	70050513          	addi	a0,a0,1792 # 80021ac8 <ftable>
    800043d0:	ffffc097          	auipc	ra,0xffffc
    800043d4:	5ec080e7          	jalr	1516(ra) # 800009bc <acquire>
  if(f->ref < 1)
    800043d8:	40dc                	lw	a5,4(s1)
    800043da:	02f05263          	blez	a5,800043fe <filedup+0x42>
    panic("filedup");
  f->ref++;
    800043de:	2785                	addiw	a5,a5,1
    800043e0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800043e2:	0001d517          	auipc	a0,0x1d
    800043e6:	6e650513          	addi	a0,a0,1766 # 80021ac8 <ftable>
    800043ea:	ffffc097          	auipc	ra,0xffffc
    800043ee:	63a080e7          	jalr	1594(ra) # 80000a24 <release>
  return f;
}
    800043f2:	8526                	mv	a0,s1
    800043f4:	60e2                	ld	ra,24(sp)
    800043f6:	6442                	ld	s0,16(sp)
    800043f8:	64a2                	ld	s1,8(sp)
    800043fa:	6105                	addi	sp,sp,32
    800043fc:	8082                	ret
    panic("filedup");
    800043fe:	00003517          	auipc	a0,0x3
    80004402:	2d250513          	addi	a0,a0,722 # 800076d0 <userret+0x640>
    80004406:	ffffc097          	auipc	ra,0xffffc
    8000440a:	142080e7          	jalr	322(ra) # 80000548 <panic>

000000008000440e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000440e:	7139                	addi	sp,sp,-64
    80004410:	fc06                	sd	ra,56(sp)
    80004412:	f822                	sd	s0,48(sp)
    80004414:	f426                	sd	s1,40(sp)
    80004416:	f04a                	sd	s2,32(sp)
    80004418:	ec4e                	sd	s3,24(sp)
    8000441a:	e852                	sd	s4,16(sp)
    8000441c:	e456                	sd	s5,8(sp)
    8000441e:	0080                	addi	s0,sp,64
    80004420:	84aa                	mv	s1,a0
  struct file ff; 

  acquire(&ftable.lock);
    80004422:	0001d517          	auipc	a0,0x1d
    80004426:	6a650513          	addi	a0,a0,1702 # 80021ac8 <ftable>
    8000442a:	ffffc097          	auipc	ra,0xffffc
    8000442e:	592080e7          	jalr	1426(ra) # 800009bc <acquire>
  if(f->ref < 1)
    80004432:	40dc                	lw	a5,4(s1)
    80004434:	06f05a63          	blez	a5,800044a8 <fileclose+0x9a>
    panic("fileclose");
  if(--f->ref > 0){
    80004438:	37fd                	addiw	a5,a5,-1
    8000443a:	0007871b          	sext.w	a4,a5
    8000443e:	c0dc                	sw	a5,4(s1)
    80004440:	06e04c63          	bgtz	a4,800044b8 <fileclose+0xaa>
    release(&ftable.lock);
    return;
  }
  ff = *f; 
    80004444:	0004a903          	lw	s2,0(s1)
    80004448:	0094ca83          	lbu	s5,9(s1)
    8000444c:	0104ba03          	ld	s4,16(s1)
    80004450:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004454:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004458:	0004a023          	sw	zero,0(s1)
  bd_free(f);
    8000445c:	8526                	mv	a0,s1
    8000445e:	00002097          	auipc	ra,0x2
    80004462:	370080e7          	jalr	880(ra) # 800067ce <bd_free>
  release(&ftable.lock);
    80004466:	0001d517          	auipc	a0,0x1d
    8000446a:	66250513          	addi	a0,a0,1634 # 80021ac8 <ftable>
    8000446e:	ffffc097          	auipc	ra,0xffffc
    80004472:	5b6080e7          	jalr	1462(ra) # 80000a24 <release>
  
  if(ff.type == FD_PIPE){
    80004476:	4785                	li	a5,1
    80004478:	06f90163          	beq	s2,a5,800044da <fileclose+0xcc>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000447c:	3979                	addiw	s2,s2,-2
    8000447e:	4785                	li	a5,1
    80004480:	0527e463          	bltu	a5,s2,800044c8 <fileclose+0xba>
    begin_op(ff.ip->dev);
    80004484:	0009a503          	lw	a0,0(s3)
    80004488:	00000097          	auipc	ra,0x0
    8000448c:	968080e7          	jalr	-1688(ra) # 80003df0 <begin_op>
    iput(ff.ip);
    80004490:	854e                	mv	a0,s3
    80004492:	fffff097          	auipc	ra,0xfffff
    80004496:	fc4080e7          	jalr	-60(ra) # 80003456 <iput>
    end_op(ff.ip->dev);
    8000449a:	0009a503          	lw	a0,0(s3)
    8000449e:	00000097          	auipc	ra,0x0
    800044a2:	9fc080e7          	jalr	-1540(ra) # 80003e9a <end_op>
    800044a6:	a00d                	j	800044c8 <fileclose+0xba>
    panic("fileclose");
    800044a8:	00003517          	auipc	a0,0x3
    800044ac:	23050513          	addi	a0,a0,560 # 800076d8 <userret+0x648>
    800044b0:	ffffc097          	auipc	ra,0xffffc
    800044b4:	098080e7          	jalr	152(ra) # 80000548 <panic>
    release(&ftable.lock);
    800044b8:	0001d517          	auipc	a0,0x1d
    800044bc:	61050513          	addi	a0,a0,1552 # 80021ac8 <ftable>
    800044c0:	ffffc097          	auipc	ra,0xffffc
    800044c4:	564080e7          	jalr	1380(ra) # 80000a24 <release>
  }
}
    800044c8:	70e2                	ld	ra,56(sp)
    800044ca:	7442                	ld	s0,48(sp)
    800044cc:	74a2                	ld	s1,40(sp)
    800044ce:	7902                	ld	s2,32(sp)
    800044d0:	69e2                	ld	s3,24(sp)
    800044d2:	6a42                	ld	s4,16(sp)
    800044d4:	6aa2                	ld	s5,8(sp)
    800044d6:	6121                	addi	sp,sp,64
    800044d8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800044da:	85d6                	mv	a1,s5
    800044dc:	8552                	mv	a0,s4
    800044de:	00000097          	auipc	ra,0x0
    800044e2:	348080e7          	jalr	840(ra) # 80004826 <pipeclose>
    800044e6:	b7cd                	j	800044c8 <fileclose+0xba>

00000000800044e8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800044e8:	715d                	addi	sp,sp,-80
    800044ea:	e486                	sd	ra,72(sp)
    800044ec:	e0a2                	sd	s0,64(sp)
    800044ee:	fc26                	sd	s1,56(sp)
    800044f0:	f84a                	sd	s2,48(sp)
    800044f2:	f44e                	sd	s3,40(sp)
    800044f4:	0880                	addi	s0,sp,80
    800044f6:	84aa                	mv	s1,a0
    800044f8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800044fa:	ffffd097          	auipc	ra,0xffffd
    800044fe:	222080e7          	jalr	546(ra) # 8000171c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004502:	409c                	lw	a5,0(s1)
    80004504:	37f9                	addiw	a5,a5,-2
    80004506:	4705                	li	a4,1
    80004508:	04f76763          	bltu	a4,a5,80004556 <filestat+0x6e>
    8000450c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000450e:	6c88                	ld	a0,24(s1)
    80004510:	fffff097          	auipc	ra,0xfffff
    80004514:	e38080e7          	jalr	-456(ra) # 80003348 <ilock>
    stati(f->ip, &st);
    80004518:	fb840593          	addi	a1,s0,-72
    8000451c:	6c88                	ld	a0,24(s1)
    8000451e:	fffff097          	auipc	ra,0xfffff
    80004522:	090080e7          	jalr	144(ra) # 800035ae <stati>
    iunlock(f->ip);
    80004526:	6c88                	ld	a0,24(s1)
    80004528:	fffff097          	auipc	ra,0xfffff
    8000452c:	ee2080e7          	jalr	-286(ra) # 8000340a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004530:	46e1                	li	a3,24
    80004532:	fb840613          	addi	a2,s0,-72
    80004536:	85ce                	mv	a1,s3
    80004538:	05093503          	ld	a0,80(s2)
    8000453c:	ffffd097          	auipc	ra,0xffffd
    80004540:	f04080e7          	jalr	-252(ra) # 80001440 <copyout>
    80004544:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004548:	60a6                	ld	ra,72(sp)
    8000454a:	6406                	ld	s0,64(sp)
    8000454c:	74e2                	ld	s1,56(sp)
    8000454e:	7942                	ld	s2,48(sp)
    80004550:	79a2                	ld	s3,40(sp)
    80004552:	6161                	addi	sp,sp,80
    80004554:	8082                	ret
  return -1;
    80004556:	557d                	li	a0,-1
    80004558:	bfc5                	j	80004548 <filestat+0x60>

000000008000455a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000455a:	7179                	addi	sp,sp,-48
    8000455c:	f406                	sd	ra,40(sp)
    8000455e:	f022                	sd	s0,32(sp)
    80004560:	ec26                	sd	s1,24(sp)
    80004562:	e84a                	sd	s2,16(sp)
    80004564:	e44e                	sd	s3,8(sp)
    80004566:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004568:	00854783          	lbu	a5,8(a0)
    8000456c:	cfc1                	beqz	a5,80004604 <fileread+0xaa>
    8000456e:	84aa                	mv	s1,a0
    80004570:	89ae                	mv	s3,a1
    80004572:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004574:	411c                	lw	a5,0(a0)
    80004576:	4705                	li	a4,1
    80004578:	04e78963          	beq	a5,a4,800045ca <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000457c:	470d                	li	a4,3
    8000457e:	04e78d63          	beq	a5,a4,800045d8 <fileread+0x7e>
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004582:	4709                	li	a4,2
    80004584:	06e79863          	bne	a5,a4,800045f4 <fileread+0x9a>
    ilock(f->ip);
    80004588:	6d08                	ld	a0,24(a0)
    8000458a:	fffff097          	auipc	ra,0xfffff
    8000458e:	dbe080e7          	jalr	-578(ra) # 80003348 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004592:	874a                	mv	a4,s2
    80004594:	5094                	lw	a3,32(s1)
    80004596:	864e                	mv	a2,s3
    80004598:	4585                	li	a1,1
    8000459a:	6c88                	ld	a0,24(s1)
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	03c080e7          	jalr	60(ra) # 800035d8 <readi>
    800045a4:	892a                	mv	s2,a0
    800045a6:	00a05563          	blez	a0,800045b0 <fileread+0x56>
      f->off += r;
    800045aa:	509c                	lw	a5,32(s1)
    800045ac:	9fa9                	addw	a5,a5,a0
    800045ae:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800045b0:	6c88                	ld	a0,24(s1)
    800045b2:	fffff097          	auipc	ra,0xfffff
    800045b6:	e58080e7          	jalr	-424(ra) # 8000340a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800045ba:	854a                	mv	a0,s2
    800045bc:	70a2                	ld	ra,40(sp)
    800045be:	7402                	ld	s0,32(sp)
    800045c0:	64e2                	ld	s1,24(sp)
    800045c2:	6942                	ld	s2,16(sp)
    800045c4:	69a2                	ld	s3,8(sp)
    800045c6:	6145                	addi	sp,sp,48
    800045c8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800045ca:	6908                	ld	a0,16(a0)
    800045cc:	00000097          	auipc	ra,0x0
    800045d0:	3d8080e7          	jalr	984(ra) # 800049a4 <piperead>
    800045d4:	892a                	mv	s2,a0
    800045d6:	b7d5                	j	800045ba <fileread+0x60>
    r = devsw[f->major].read(1, addr, n);
    800045d8:	02451783          	lh	a5,36(a0)
    800045dc:	00479713          	slli	a4,a5,0x4
    800045e0:	0001d797          	auipc	a5,0x1d
    800045e4:	4e878793          	addi	a5,a5,1256 # 80021ac8 <ftable>
    800045e8:	97ba                	add	a5,a5,a4
    800045ea:	6f9c                	ld	a5,24(a5)
    800045ec:	4505                	li	a0,1
    800045ee:	9782                	jalr	a5
    800045f0:	892a                	mv	s2,a0
    800045f2:	b7e1                	j	800045ba <fileread+0x60>
    panic("fileread");
    800045f4:	00003517          	auipc	a0,0x3
    800045f8:	0f450513          	addi	a0,a0,244 # 800076e8 <userret+0x658>
    800045fc:	ffffc097          	auipc	ra,0xffffc
    80004600:	f4c080e7          	jalr	-180(ra) # 80000548 <panic>
    return -1;
    80004604:	597d                	li	s2,-1
    80004606:	bf55                	j	800045ba <fileread+0x60>

0000000080004608 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004608:	00954783          	lbu	a5,9(a0)
    8000460c:	12078e63          	beqz	a5,80004748 <filewrite+0x140>
{
    80004610:	715d                	addi	sp,sp,-80
    80004612:	e486                	sd	ra,72(sp)
    80004614:	e0a2                	sd	s0,64(sp)
    80004616:	fc26                	sd	s1,56(sp)
    80004618:	f84a                	sd	s2,48(sp)
    8000461a:	f44e                	sd	s3,40(sp)
    8000461c:	f052                	sd	s4,32(sp)
    8000461e:	ec56                	sd	s5,24(sp)
    80004620:	e85a                	sd	s6,16(sp)
    80004622:	e45e                	sd	s7,8(sp)
    80004624:	e062                	sd	s8,0(sp)
    80004626:	0880                	addi	s0,sp,80
    80004628:	84aa                	mv	s1,a0
    8000462a:	8aae                	mv	s5,a1
    8000462c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000462e:	411c                	lw	a5,0(a0)
    80004630:	4705                	li	a4,1
    80004632:	02e78263          	beq	a5,a4,80004656 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004636:	470d                	li	a4,3
    80004638:	02e78563          	beq	a5,a4,80004662 <filewrite+0x5a>
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000463c:	4709                	li	a4,2
    8000463e:	0ee79d63          	bne	a5,a4,80004738 <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004642:	0ec05763          	blez	a2,80004730 <filewrite+0x128>
    int i = 0;
    80004646:	4981                	li	s3,0
    80004648:	6b05                	lui	s6,0x1
    8000464a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000464e:	6b85                	lui	s7,0x1
    80004650:	c00b8b9b          	addiw	s7,s7,-1024
    80004654:	a051                	j	800046d8 <filewrite+0xd0>
    ret = pipewrite(f->pipe, addr, n);
    80004656:	6908                	ld	a0,16(a0)
    80004658:	00000097          	auipc	ra,0x0
    8000465c:	23e080e7          	jalr	574(ra) # 80004896 <pipewrite>
    80004660:	a065                	j	80004708 <filewrite+0x100>
    ret = devsw[f->major].write(1, addr, n);
    80004662:	02451783          	lh	a5,36(a0)
    80004666:	00479713          	slli	a4,a5,0x4
    8000466a:	0001d797          	auipc	a5,0x1d
    8000466e:	45e78793          	addi	a5,a5,1118 # 80021ac8 <ftable>
    80004672:	97ba                	add	a5,a5,a4
    80004674:	739c                	ld	a5,32(a5)
    80004676:	4505                	li	a0,1
    80004678:	9782                	jalr	a5
    8000467a:	a079                	j	80004708 <filewrite+0x100>
    8000467c:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    80004680:	6c9c                	ld	a5,24(s1)
    80004682:	4388                	lw	a0,0(a5)
    80004684:	fffff097          	auipc	ra,0xfffff
    80004688:	76c080e7          	jalr	1900(ra) # 80003df0 <begin_op>
      ilock(f->ip);
    8000468c:	6c88                	ld	a0,24(s1)
    8000468e:	fffff097          	auipc	ra,0xfffff
    80004692:	cba080e7          	jalr	-838(ra) # 80003348 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004696:	8762                	mv	a4,s8
    80004698:	5094                	lw	a3,32(s1)
    8000469a:	01598633          	add	a2,s3,s5
    8000469e:	4585                	li	a1,1
    800046a0:	6c88                	ld	a0,24(s1)
    800046a2:	fffff097          	auipc	ra,0xfffff
    800046a6:	02a080e7          	jalr	42(ra) # 800036cc <writei>
    800046aa:	892a                	mv	s2,a0
    800046ac:	02a05e63          	blez	a0,800046e8 <filewrite+0xe0>
        f->off += r;
    800046b0:	509c                	lw	a5,32(s1)
    800046b2:	9fa9                	addw	a5,a5,a0
    800046b4:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    800046b6:	6c88                	ld	a0,24(s1)
    800046b8:	fffff097          	auipc	ra,0xfffff
    800046bc:	d52080e7          	jalr	-686(ra) # 8000340a <iunlock>
      end_op(f->ip->dev);
    800046c0:	6c9c                	ld	a5,24(s1)
    800046c2:	4388                	lw	a0,0(a5)
    800046c4:	fffff097          	auipc	ra,0xfffff
    800046c8:	7d6080e7          	jalr	2006(ra) # 80003e9a <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800046cc:	052c1a63          	bne	s8,s2,80004720 <filewrite+0x118>
        panic("short filewrite");
      i += r;
    800046d0:	013909bb          	addw	s3,s2,s3
    while(i < n){
    800046d4:	0349d763          	bge	s3,s4,80004702 <filewrite+0xfa>
      int n1 = n - i;
    800046d8:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800046dc:	893e                	mv	s2,a5
    800046de:	2781                	sext.w	a5,a5
    800046e0:	f8fb5ee3          	bge	s6,a5,8000467c <filewrite+0x74>
    800046e4:	895e                	mv	s2,s7
    800046e6:	bf59                	j	8000467c <filewrite+0x74>
      iunlock(f->ip);
    800046e8:	6c88                	ld	a0,24(s1)
    800046ea:	fffff097          	auipc	ra,0xfffff
    800046ee:	d20080e7          	jalr	-736(ra) # 8000340a <iunlock>
      end_op(f->ip->dev);
    800046f2:	6c9c                	ld	a5,24(s1)
    800046f4:	4388                	lw	a0,0(a5)
    800046f6:	fffff097          	auipc	ra,0xfffff
    800046fa:	7a4080e7          	jalr	1956(ra) # 80003e9a <end_op>
      if(r < 0)
    800046fe:	fc0957e3          	bgez	s2,800046cc <filewrite+0xc4>
    }
    ret = (i == n ? n : -1);
    80004702:	8552                	mv	a0,s4
    80004704:	033a1863          	bne	s4,s3,80004734 <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004708:	60a6                	ld	ra,72(sp)
    8000470a:	6406                	ld	s0,64(sp)
    8000470c:	74e2                	ld	s1,56(sp)
    8000470e:	7942                	ld	s2,48(sp)
    80004710:	79a2                	ld	s3,40(sp)
    80004712:	7a02                	ld	s4,32(sp)
    80004714:	6ae2                	ld	s5,24(sp)
    80004716:	6b42                	ld	s6,16(sp)
    80004718:	6ba2                	ld	s7,8(sp)
    8000471a:	6c02                	ld	s8,0(sp)
    8000471c:	6161                	addi	sp,sp,80
    8000471e:	8082                	ret
        panic("short filewrite");
    80004720:	00003517          	auipc	a0,0x3
    80004724:	fd850513          	addi	a0,a0,-40 # 800076f8 <userret+0x668>
    80004728:	ffffc097          	auipc	ra,0xffffc
    8000472c:	e20080e7          	jalr	-480(ra) # 80000548 <panic>
    int i = 0;
    80004730:	4981                	li	s3,0
    80004732:	bfc1                	j	80004702 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004734:	557d                	li	a0,-1
    80004736:	bfc9                	j	80004708 <filewrite+0x100>
    panic("filewrite");
    80004738:	00003517          	auipc	a0,0x3
    8000473c:	fd050513          	addi	a0,a0,-48 # 80007708 <userret+0x678>
    80004740:	ffffc097          	auipc	ra,0xffffc
    80004744:	e08080e7          	jalr	-504(ra) # 80000548 <panic>
    return -1;
    80004748:	557d                	li	a0,-1
}
    8000474a:	8082                	ret

000000008000474c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000474c:	7179                	addi	sp,sp,-48
    8000474e:	f406                	sd	ra,40(sp)
    80004750:	f022                	sd	s0,32(sp)
    80004752:	ec26                	sd	s1,24(sp)
    80004754:	e84a                	sd	s2,16(sp)
    80004756:	e44e                	sd	s3,8(sp)
    80004758:	e052                	sd	s4,0(sp)
    8000475a:	1800                	addi	s0,sp,48
    8000475c:	84aa                	mv	s1,a0
    8000475e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004760:	0005b023          	sd	zero,0(a1)
    80004764:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004768:	00000097          	auipc	ra,0x0
    8000476c:	bf4080e7          	jalr	-1036(ra) # 8000435c <filealloc>
    80004770:	e088                	sd	a0,0(s1)
    80004772:	c551                	beqz	a0,800047fe <pipealloc+0xb2>
    80004774:	00000097          	auipc	ra,0x0
    80004778:	be8080e7          	jalr	-1048(ra) # 8000435c <filealloc>
    8000477c:	00aa3023          	sd	a0,0(s4)
    80004780:	c92d                	beqz	a0,800047f2 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004782:	ffffc097          	auipc	ra,0xffffc
    80004786:	112080e7          	jalr	274(ra) # 80000894 <kalloc>
    8000478a:	892a                	mv	s2,a0
    8000478c:	c125                	beqz	a0,800047ec <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000478e:	4985                	li	s3,1
    80004790:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004794:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004798:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000479c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800047a0:	00003597          	auipc	a1,0x3
    800047a4:	f7858593          	addi	a1,a1,-136 # 80007718 <userret+0x688>
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	106080e7          	jalr	262(ra) # 800008ae <initlock>
  (*f0)->type = FD_PIPE;
    800047b0:	609c                	ld	a5,0(s1)
    800047b2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800047b6:	609c                	ld	a5,0(s1)
    800047b8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800047bc:	609c                	ld	a5,0(s1)
    800047be:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800047c2:	609c                	ld	a5,0(s1)
    800047c4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800047c8:	000a3783          	ld	a5,0(s4)
    800047cc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800047d0:	000a3783          	ld	a5,0(s4)
    800047d4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800047d8:	000a3783          	ld	a5,0(s4)
    800047dc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800047e0:	000a3783          	ld	a5,0(s4)
    800047e4:	0127b823          	sd	s2,16(a5)
  return 0;
    800047e8:	4501                	li	a0,0
    800047ea:	a025                	j	80004812 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800047ec:	6088                	ld	a0,0(s1)
    800047ee:	e501                	bnez	a0,800047f6 <pipealloc+0xaa>
    800047f0:	a039                	j	800047fe <pipealloc+0xb2>
    800047f2:	6088                	ld	a0,0(s1)
    800047f4:	c51d                	beqz	a0,80004822 <pipealloc+0xd6>
    fileclose(*f0);
    800047f6:	00000097          	auipc	ra,0x0
    800047fa:	c18080e7          	jalr	-1000(ra) # 8000440e <fileclose>
  if(*f1)
    800047fe:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004802:	557d                	li	a0,-1
  if(*f1)
    80004804:	c799                	beqz	a5,80004812 <pipealloc+0xc6>
    fileclose(*f1);
    80004806:	853e                	mv	a0,a5
    80004808:	00000097          	auipc	ra,0x0
    8000480c:	c06080e7          	jalr	-1018(ra) # 8000440e <fileclose>
  return -1;
    80004810:	557d                	li	a0,-1
}
    80004812:	70a2                	ld	ra,40(sp)
    80004814:	7402                	ld	s0,32(sp)
    80004816:	64e2                	ld	s1,24(sp)
    80004818:	6942                	ld	s2,16(sp)
    8000481a:	69a2                	ld	s3,8(sp)
    8000481c:	6a02                	ld	s4,0(sp)
    8000481e:	6145                	addi	sp,sp,48
    80004820:	8082                	ret
  return -1;
    80004822:	557d                	li	a0,-1
    80004824:	b7fd                	j	80004812 <pipealloc+0xc6>

0000000080004826 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004826:	1101                	addi	sp,sp,-32
    80004828:	ec06                	sd	ra,24(sp)
    8000482a:	e822                	sd	s0,16(sp)
    8000482c:	e426                	sd	s1,8(sp)
    8000482e:	e04a                	sd	s2,0(sp)
    80004830:	1000                	addi	s0,sp,32
    80004832:	84aa                	mv	s1,a0
    80004834:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004836:	ffffc097          	auipc	ra,0xffffc
    8000483a:	186080e7          	jalr	390(ra) # 800009bc <acquire>
  if(writable){
    8000483e:	02090d63          	beqz	s2,80004878 <pipeclose+0x52>
    pi->writeopen = 0;
    80004842:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004846:	21848513          	addi	a0,s1,536
    8000484a:	ffffe097          	auipc	ra,0xffffe
    8000484e:	868080e7          	jalr	-1944(ra) # 800020b2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004852:	2204b783          	ld	a5,544(s1)
    80004856:	eb95                	bnez	a5,8000488a <pipeclose+0x64>
    release(&pi->lock);
    80004858:	8526                	mv	a0,s1
    8000485a:	ffffc097          	auipc	ra,0xffffc
    8000485e:	1ca080e7          	jalr	458(ra) # 80000a24 <release>
    kfree((char*)pi);
    80004862:	8526                	mv	a0,s1
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	018080e7          	jalr	24(ra) # 8000087c <kfree>
  } else
    release(&pi->lock);
}
    8000486c:	60e2                	ld	ra,24(sp)
    8000486e:	6442                	ld	s0,16(sp)
    80004870:	64a2                	ld	s1,8(sp)
    80004872:	6902                	ld	s2,0(sp)
    80004874:	6105                	addi	sp,sp,32
    80004876:	8082                	ret
    pi->readopen = 0;
    80004878:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000487c:	21c48513          	addi	a0,s1,540
    80004880:	ffffe097          	auipc	ra,0xffffe
    80004884:	832080e7          	jalr	-1998(ra) # 800020b2 <wakeup>
    80004888:	b7e9                	j	80004852 <pipeclose+0x2c>
    release(&pi->lock);
    8000488a:	8526                	mv	a0,s1
    8000488c:	ffffc097          	auipc	ra,0xffffc
    80004890:	198080e7          	jalr	408(ra) # 80000a24 <release>
}
    80004894:	bfe1                	j	8000486c <pipeclose+0x46>

0000000080004896 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004896:	711d                	addi	sp,sp,-96
    80004898:	ec86                	sd	ra,88(sp)
    8000489a:	e8a2                	sd	s0,80(sp)
    8000489c:	e4a6                	sd	s1,72(sp)
    8000489e:	e0ca                	sd	s2,64(sp)
    800048a0:	fc4e                	sd	s3,56(sp)
    800048a2:	f852                	sd	s4,48(sp)
    800048a4:	f456                	sd	s5,40(sp)
    800048a6:	f05a                	sd	s6,32(sp)
    800048a8:	ec5e                	sd	s7,24(sp)
    800048aa:	e862                	sd	s8,16(sp)
    800048ac:	1080                	addi	s0,sp,96
    800048ae:	84aa                	mv	s1,a0
    800048b0:	8aae                	mv	s5,a1
    800048b2:	8a32                	mv	s4,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    800048b4:	ffffd097          	auipc	ra,0xffffd
    800048b8:	e68080e7          	jalr	-408(ra) # 8000171c <myproc>
    800048bc:	8baa                	mv	s7,a0

  acquire(&pi->lock);
    800048be:	8526                	mv	a0,s1
    800048c0:	ffffc097          	auipc	ra,0xffffc
    800048c4:	0fc080e7          	jalr	252(ra) # 800009bc <acquire>
  for(i = 0; i < n; i++){
    800048c8:	09405f63          	blez	s4,80004966 <pipewrite+0xd0>
    800048cc:	fffa0b1b          	addiw	s6,s4,-1
    800048d0:	1b02                	slli	s6,s6,0x20
    800048d2:	020b5b13          	srli	s6,s6,0x20
    800048d6:	001a8793          	addi	a5,s5,1
    800048da:	9b3e                	add	s6,s6,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    800048dc:	21848993          	addi	s3,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800048e0:	21c48913          	addi	s2,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800048e4:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800048e6:	2184a783          	lw	a5,536(s1)
    800048ea:	21c4a703          	lw	a4,540(s1)
    800048ee:	2007879b          	addiw	a5,a5,512
    800048f2:	02f71e63          	bne	a4,a5,8000492e <pipewrite+0x98>
      if(pi->readopen == 0 || myproc()->killed){
    800048f6:	2204a783          	lw	a5,544(s1)
    800048fa:	c3d9                	beqz	a5,80004980 <pipewrite+0xea>
    800048fc:	ffffd097          	auipc	ra,0xffffd
    80004900:	e20080e7          	jalr	-480(ra) # 8000171c <myproc>
    80004904:	591c                	lw	a5,48(a0)
    80004906:	efad                	bnez	a5,80004980 <pipewrite+0xea>
      wakeup(&pi->nread);
    80004908:	854e                	mv	a0,s3
    8000490a:	ffffd097          	auipc	ra,0xffffd
    8000490e:	7a8080e7          	jalr	1960(ra) # 800020b2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004912:	85a6                	mv	a1,s1
    80004914:	854a                	mv	a0,s2
    80004916:	ffffd097          	auipc	ra,0xffffd
    8000491a:	61c080e7          	jalr	1564(ra) # 80001f32 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    8000491e:	2184a783          	lw	a5,536(s1)
    80004922:	21c4a703          	lw	a4,540(s1)
    80004926:	2007879b          	addiw	a5,a5,512
    8000492a:	fcf706e3          	beq	a4,a5,800048f6 <pipewrite+0x60>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000492e:	4685                	li	a3,1
    80004930:	8656                	mv	a2,s5
    80004932:	faf40593          	addi	a1,s0,-81
    80004936:	050bb503          	ld	a0,80(s7) # 1050 <_entry-0x7fffefb0>
    8000493a:	ffffd097          	auipc	ra,0xffffd
    8000493e:	b98080e7          	jalr	-1128(ra) # 800014d2 <copyin>
    80004942:	03850263          	beq	a0,s8,80004966 <pipewrite+0xd0>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004946:	21c4a783          	lw	a5,540(s1)
    8000494a:	0017871b          	addiw	a4,a5,1
    8000494e:	20e4ae23          	sw	a4,540(s1)
    80004952:	1ff7f793          	andi	a5,a5,511
    80004956:	97a6                	add	a5,a5,s1
    80004958:	faf44703          	lbu	a4,-81(s0)
    8000495c:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004960:	0a85                	addi	s5,s5,1
    80004962:	f96a92e3          	bne	s5,s6,800048e6 <pipewrite+0x50>
  }
  wakeup(&pi->nread);
    80004966:	21848513          	addi	a0,s1,536
    8000496a:	ffffd097          	auipc	ra,0xffffd
    8000496e:	748080e7          	jalr	1864(ra) # 800020b2 <wakeup>
  release(&pi->lock);
    80004972:	8526                	mv	a0,s1
    80004974:	ffffc097          	auipc	ra,0xffffc
    80004978:	0b0080e7          	jalr	176(ra) # 80000a24 <release>
  return n;
    8000497c:	8552                	mv	a0,s4
    8000497e:	a039                	j	8000498c <pipewrite+0xf6>
        release(&pi->lock);
    80004980:	8526                	mv	a0,s1
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	0a2080e7          	jalr	162(ra) # 80000a24 <release>
        return -1;
    8000498a:	557d                	li	a0,-1
}
    8000498c:	60e6                	ld	ra,88(sp)
    8000498e:	6446                	ld	s0,80(sp)
    80004990:	64a6                	ld	s1,72(sp)
    80004992:	6906                	ld	s2,64(sp)
    80004994:	79e2                	ld	s3,56(sp)
    80004996:	7a42                	ld	s4,48(sp)
    80004998:	7aa2                	ld	s5,40(sp)
    8000499a:	7b02                	ld	s6,32(sp)
    8000499c:	6be2                	ld	s7,24(sp)
    8000499e:	6c42                	ld	s8,16(sp)
    800049a0:	6125                	addi	sp,sp,96
    800049a2:	8082                	ret

00000000800049a4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800049a4:	715d                	addi	sp,sp,-80
    800049a6:	e486                	sd	ra,72(sp)
    800049a8:	e0a2                	sd	s0,64(sp)
    800049aa:	fc26                	sd	s1,56(sp)
    800049ac:	f84a                	sd	s2,48(sp)
    800049ae:	f44e                	sd	s3,40(sp)
    800049b0:	f052                	sd	s4,32(sp)
    800049b2:	ec56                	sd	s5,24(sp)
    800049b4:	e85a                	sd	s6,16(sp)
    800049b6:	0880                	addi	s0,sp,80
    800049b8:	84aa                	mv	s1,a0
    800049ba:	892e                	mv	s2,a1
    800049bc:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    800049be:	ffffd097          	auipc	ra,0xffffd
    800049c2:	d5e080e7          	jalr	-674(ra) # 8000171c <myproc>
    800049c6:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    800049c8:	8526                	mv	a0,s1
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	ff2080e7          	jalr	-14(ra) # 800009bc <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049d2:	2184a703          	lw	a4,536(s1)
    800049d6:	21c4a783          	lw	a5,540(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800049da:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800049de:	02f71763          	bne	a4,a5,80004a0c <piperead+0x68>
    800049e2:	2244a783          	lw	a5,548(s1)
    800049e6:	c39d                	beqz	a5,80004a0c <piperead+0x68>
    if(myproc()->killed){
    800049e8:	ffffd097          	auipc	ra,0xffffd
    800049ec:	d34080e7          	jalr	-716(ra) # 8000171c <myproc>
    800049f0:	591c                	lw	a5,48(a0)
    800049f2:	ebc1                	bnez	a5,80004a82 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800049f4:	85a6                	mv	a1,s1
    800049f6:	854e                	mv	a0,s3
    800049f8:	ffffd097          	auipc	ra,0xffffd
    800049fc:	53a080e7          	jalr	1338(ra) # 80001f32 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a00:	2184a703          	lw	a4,536(s1)
    80004a04:	21c4a783          	lw	a5,540(s1)
    80004a08:	fcf70de3          	beq	a4,a5,800049e2 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a0c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a0e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a10:	05405363          	blez	s4,80004a56 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004a14:	2184a783          	lw	a5,536(s1)
    80004a18:	21c4a703          	lw	a4,540(s1)
    80004a1c:	02f70d63          	beq	a4,a5,80004a56 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004a20:	0017871b          	addiw	a4,a5,1
    80004a24:	20e4ac23          	sw	a4,536(s1)
    80004a28:	1ff7f793          	andi	a5,a5,511
    80004a2c:	97a6                	add	a5,a5,s1
    80004a2e:	0187c783          	lbu	a5,24(a5)
    80004a32:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a36:	4685                	li	a3,1
    80004a38:	fbf40613          	addi	a2,s0,-65
    80004a3c:	85ca                	mv	a1,s2
    80004a3e:	050ab503          	ld	a0,80(s5)
    80004a42:	ffffd097          	auipc	ra,0xffffd
    80004a46:	9fe080e7          	jalr	-1538(ra) # 80001440 <copyout>
    80004a4a:	01650663          	beq	a0,s6,80004a56 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a4e:	2985                	addiw	s3,s3,1
    80004a50:	0905                	addi	s2,s2,1
    80004a52:	fd3a11e3          	bne	s4,s3,80004a14 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004a56:	21c48513          	addi	a0,s1,540
    80004a5a:	ffffd097          	auipc	ra,0xffffd
    80004a5e:	658080e7          	jalr	1624(ra) # 800020b2 <wakeup>
  release(&pi->lock);
    80004a62:	8526                	mv	a0,s1
    80004a64:	ffffc097          	auipc	ra,0xffffc
    80004a68:	fc0080e7          	jalr	-64(ra) # 80000a24 <release>
  return i;
}
    80004a6c:	854e                	mv	a0,s3
    80004a6e:	60a6                	ld	ra,72(sp)
    80004a70:	6406                	ld	s0,64(sp)
    80004a72:	74e2                	ld	s1,56(sp)
    80004a74:	7942                	ld	s2,48(sp)
    80004a76:	79a2                	ld	s3,40(sp)
    80004a78:	7a02                	ld	s4,32(sp)
    80004a7a:	6ae2                	ld	s5,24(sp)
    80004a7c:	6b42                	ld	s6,16(sp)
    80004a7e:	6161                	addi	sp,sp,80
    80004a80:	8082                	ret
      release(&pi->lock);
    80004a82:	8526                	mv	a0,s1
    80004a84:	ffffc097          	auipc	ra,0xffffc
    80004a88:	fa0080e7          	jalr	-96(ra) # 80000a24 <release>
      return -1;
    80004a8c:	59fd                	li	s3,-1
    80004a8e:	bff9                	j	80004a6c <piperead+0xc8>

0000000080004a90 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004a90:	de010113          	addi	sp,sp,-544
    80004a94:	20113c23          	sd	ra,536(sp)
    80004a98:	20813823          	sd	s0,528(sp)
    80004a9c:	20913423          	sd	s1,520(sp)
    80004aa0:	21213023          	sd	s2,512(sp)
    80004aa4:	ffce                	sd	s3,504(sp)
    80004aa6:	fbd2                	sd	s4,496(sp)
    80004aa8:	f7d6                	sd	s5,488(sp)
    80004aaa:	f3da                	sd	s6,480(sp)
    80004aac:	efde                	sd	s7,472(sp)
    80004aae:	ebe2                	sd	s8,464(sp)
    80004ab0:	e7e6                	sd	s9,456(sp)
    80004ab2:	e3ea                	sd	s10,448(sp)
    80004ab4:	ff6e                	sd	s11,440(sp)
    80004ab6:	1400                	addi	s0,sp,544
    80004ab8:	892a                	mv	s2,a0
    80004aba:	dea43423          	sd	a0,-536(s0)
    80004abe:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ac2:	ffffd097          	auipc	ra,0xffffd
    80004ac6:	c5a080e7          	jalr	-934(ra) # 8000171c <myproc>
    80004aca:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    80004acc:	4501                	li	a0,0
    80004ace:	fffff097          	auipc	ra,0xfffff
    80004ad2:	322080e7          	jalr	802(ra) # 80003df0 <begin_op>

  if((ip = namei(path)) == 0){
    80004ad6:	854a                	mv	a0,s2
    80004ad8:	fffff097          	auipc	ra,0xfffff
    80004adc:	ffc080e7          	jalr	-4(ra) # 80003ad4 <namei>
    80004ae0:	cd25                	beqz	a0,80004b58 <exec+0xc8>
    80004ae2:	8aaa                	mv	s5,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004ae4:	fffff097          	auipc	ra,0xfffff
    80004ae8:	864080e7          	jalr	-1948(ra) # 80003348 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004aec:	04000713          	li	a4,64
    80004af0:	4681                	li	a3,0
    80004af2:	e4840613          	addi	a2,s0,-440
    80004af6:	4581                	li	a1,0
    80004af8:	8556                	mv	a0,s5
    80004afa:	fffff097          	auipc	ra,0xfffff
    80004afe:	ade080e7          	jalr	-1314(ra) # 800035d8 <readi>
    80004b02:	04000793          	li	a5,64
    80004b06:	00f51a63          	bne	a0,a5,80004b1a <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004b0a:	e4842703          	lw	a4,-440(s0)
    80004b0e:	464c47b7          	lui	a5,0x464c4
    80004b12:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004b16:	04f70863          	beq	a4,a5,80004b66 <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004b1a:	8556                	mv	a0,s5
    80004b1c:	fffff097          	auipc	ra,0xfffff
    80004b20:	a6a080e7          	jalr	-1430(ra) # 80003586 <iunlockput>
    end_op(ROOTDEV);
    80004b24:	4501                	li	a0,0
    80004b26:	fffff097          	auipc	ra,0xfffff
    80004b2a:	374080e7          	jalr	884(ra) # 80003e9a <end_op>
  }
  return -1;
    80004b2e:	557d                	li	a0,-1
}
    80004b30:	21813083          	ld	ra,536(sp)
    80004b34:	21013403          	ld	s0,528(sp)
    80004b38:	20813483          	ld	s1,520(sp)
    80004b3c:	20013903          	ld	s2,512(sp)
    80004b40:	79fe                	ld	s3,504(sp)
    80004b42:	7a5e                	ld	s4,496(sp)
    80004b44:	7abe                	ld	s5,488(sp)
    80004b46:	7b1e                	ld	s6,480(sp)
    80004b48:	6bfe                	ld	s7,472(sp)
    80004b4a:	6c5e                	ld	s8,464(sp)
    80004b4c:	6cbe                	ld	s9,456(sp)
    80004b4e:	6d1e                	ld	s10,448(sp)
    80004b50:	7dfa                	ld	s11,440(sp)
    80004b52:	22010113          	addi	sp,sp,544
    80004b56:	8082                	ret
    end_op(ROOTDEV);
    80004b58:	4501                	li	a0,0
    80004b5a:	fffff097          	auipc	ra,0xfffff
    80004b5e:	340080e7          	jalr	832(ra) # 80003e9a <end_op>
    return -1;
    80004b62:	557d                	li	a0,-1
    80004b64:	b7f1                	j	80004b30 <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    80004b66:	8526                	mv	a0,s1
    80004b68:	ffffd097          	auipc	ra,0xffffd
    80004b6c:	c78080e7          	jalr	-904(ra) # 800017e0 <proc_pagetable>
    80004b70:	8b2a                	mv	s6,a0
    80004b72:	d545                	beqz	a0,80004b1a <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b74:	e6842783          	lw	a5,-408(s0)
    80004b78:	e8045703          	lhu	a4,-384(s0)
    80004b7c:	10070263          	beqz	a4,80004c80 <exec+0x1f0>
  sz = 0;
    80004b80:	de043c23          	sd	zero,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004b84:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004b88:	6a05                	lui	s4,0x1
    80004b8a:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004b8e:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004b92:	6d85                	lui	s11,0x1
    80004b94:	7d7d                	lui	s10,0xfffff
    80004b96:	a88d                	j	80004c08 <exec+0x178>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004b98:	00003517          	auipc	a0,0x3
    80004b9c:	b8850513          	addi	a0,a0,-1144 # 80007720 <userret+0x690>
    80004ba0:	ffffc097          	auipc	ra,0xffffc
    80004ba4:	9a8080e7          	jalr	-1624(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ba8:	874a                	mv	a4,s2
    80004baa:	009c86bb          	addw	a3,s9,s1
    80004bae:	4581                	li	a1,0
    80004bb0:	8556                	mv	a0,s5
    80004bb2:	fffff097          	auipc	ra,0xfffff
    80004bb6:	a26080e7          	jalr	-1498(ra) # 800035d8 <readi>
    80004bba:	2501                	sext.w	a0,a0
    80004bbc:	10a91863          	bne	s2,a0,80004ccc <exec+0x23c>
  for(i = 0; i < sz; i += PGSIZE){
    80004bc0:	009d84bb          	addw	s1,s11,s1
    80004bc4:	013d09bb          	addw	s3,s10,s3
    80004bc8:	0374f263          	bgeu	s1,s7,80004bec <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    80004bcc:	02049593          	slli	a1,s1,0x20
    80004bd0:	9181                	srli	a1,a1,0x20
    80004bd2:	95e2                	add	a1,a1,s8
    80004bd4:	855a                	mv	a0,s6
    80004bd6:	ffffc097          	auipc	ra,0xffffc
    80004bda:	2a4080e7          	jalr	676(ra) # 80000e7a <walkaddr>
    80004bde:	862a                	mv	a2,a0
    if(pa == 0)
    80004be0:	dd45                	beqz	a0,80004b98 <exec+0x108>
      n = PGSIZE;
    80004be2:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004be4:	fd49f2e3          	bgeu	s3,s4,80004ba8 <exec+0x118>
      n = sz - i;
    80004be8:	894e                	mv	s2,s3
    80004bea:	bf7d                	j	80004ba8 <exec+0x118>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004bec:	e0843783          	ld	a5,-504(s0)
    80004bf0:	0017869b          	addiw	a3,a5,1
    80004bf4:	e0d43423          	sd	a3,-504(s0)
    80004bf8:	e0043783          	ld	a5,-512(s0)
    80004bfc:	0387879b          	addiw	a5,a5,56
    80004c00:	e8045703          	lhu	a4,-384(s0)
    80004c04:	08e6d063          	bge	a3,a4,80004c84 <exec+0x1f4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c08:	2781                	sext.w	a5,a5
    80004c0a:	e0f43023          	sd	a5,-512(s0)
    80004c0e:	03800713          	li	a4,56
    80004c12:	86be                	mv	a3,a5
    80004c14:	e1040613          	addi	a2,s0,-496
    80004c18:	4581                	li	a1,0
    80004c1a:	8556                	mv	a0,s5
    80004c1c:	fffff097          	auipc	ra,0xfffff
    80004c20:	9bc080e7          	jalr	-1604(ra) # 800035d8 <readi>
    80004c24:	03800793          	li	a5,56
    80004c28:	0af51263          	bne	a0,a5,80004ccc <exec+0x23c>
    if(ph.type != ELF_PROG_LOAD)
    80004c2c:	e1042783          	lw	a5,-496(s0)
    80004c30:	4705                	li	a4,1
    80004c32:	fae79de3          	bne	a5,a4,80004bec <exec+0x15c>
    if(ph.memsz < ph.filesz)
    80004c36:	e3843603          	ld	a2,-456(s0)
    80004c3a:	e3043783          	ld	a5,-464(s0)
    80004c3e:	08f66763          	bltu	a2,a5,80004ccc <exec+0x23c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004c42:	e2043783          	ld	a5,-480(s0)
    80004c46:	963e                	add	a2,a2,a5
    80004c48:	08f66263          	bltu	a2,a5,80004ccc <exec+0x23c>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004c4c:	df843583          	ld	a1,-520(s0)
    80004c50:	855a                	mv	a0,s6
    80004c52:	ffffc097          	auipc	ra,0xffffc
    80004c56:	614080e7          	jalr	1556(ra) # 80001266 <uvmalloc>
    80004c5a:	dea43c23          	sd	a0,-520(s0)
    80004c5e:	c53d                	beqz	a0,80004ccc <exec+0x23c>
    if(ph.vaddr % PGSIZE != 0)
    80004c60:	e2043c03          	ld	s8,-480(s0)
    80004c64:	de043783          	ld	a5,-544(s0)
    80004c68:	00fc77b3          	and	a5,s8,a5
    80004c6c:	e3a5                	bnez	a5,80004ccc <exec+0x23c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004c6e:	e1842c83          	lw	s9,-488(s0)
    80004c72:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004c76:	f60b8be3          	beqz	s7,80004bec <exec+0x15c>
    80004c7a:	89de                	mv	s3,s7
    80004c7c:	4481                	li	s1,0
    80004c7e:	b7b9                	j	80004bcc <exec+0x13c>
  sz = 0;
    80004c80:	de043c23          	sd	zero,-520(s0)
  iunlockput(ip);
    80004c84:	8556                	mv	a0,s5
    80004c86:	fffff097          	auipc	ra,0xfffff
    80004c8a:	900080e7          	jalr	-1792(ra) # 80003586 <iunlockput>
  end_op(ROOTDEV);
    80004c8e:	4501                	li	a0,0
    80004c90:	fffff097          	auipc	ra,0xfffff
    80004c94:	20a080e7          	jalr	522(ra) # 80003e9a <end_op>
  p = myproc();
    80004c98:	ffffd097          	auipc	ra,0xffffd
    80004c9c:	a84080e7          	jalr	-1404(ra) # 8000171c <myproc>
    80004ca0:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004ca2:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004ca6:	6585                	lui	a1,0x1
    80004ca8:	15fd                	addi	a1,a1,-1
    80004caa:	df843783          	ld	a5,-520(s0)
    80004cae:	95be                	add	a1,a1,a5
    80004cb0:	77fd                	lui	a5,0xfffff
    80004cb2:	8dfd                	and	a1,a1,a5
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004cb4:	6609                	lui	a2,0x2
    80004cb6:	962e                	add	a2,a2,a1
    80004cb8:	855a                	mv	a0,s6
    80004cba:	ffffc097          	auipc	ra,0xffffc
    80004cbe:	5ac080e7          	jalr	1452(ra) # 80001266 <uvmalloc>
    80004cc2:	892a                	mv	s2,a0
    80004cc4:	dea43c23          	sd	a0,-520(s0)
  ip = 0;
    80004cc8:	4a81                	li	s5,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004cca:	ed01                	bnez	a0,80004ce2 <exec+0x252>
    proc_freepagetable(pagetable, sz);
    80004ccc:	df843583          	ld	a1,-520(s0)
    80004cd0:	855a                	mv	a0,s6
    80004cd2:	ffffd097          	auipc	ra,0xffffd
    80004cd6:	c0e080e7          	jalr	-1010(ra) # 800018e0 <proc_freepagetable>
  if(ip){
    80004cda:	e40a90e3          	bnez	s5,80004b1a <exec+0x8a>
  return -1;
    80004cde:	557d                	li	a0,-1
    80004ce0:	bd81                	j	80004b30 <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004ce2:	75f9                	lui	a1,0xffffe
    80004ce4:	95aa                	add	a1,a1,a0
    80004ce6:	855a                	mv	a0,s6
    80004ce8:	ffffc097          	auipc	ra,0xffffc
    80004cec:	726080e7          	jalr	1830(ra) # 8000140e <uvmclear>
  stackbase = sp - PGSIZE;
    80004cf0:	7c7d                	lui	s8,0xfffff
    80004cf2:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    80004cf4:	df043783          	ld	a5,-528(s0)
    80004cf8:	6388                	ld	a0,0(a5)
    80004cfa:	c52d                	beqz	a0,80004d64 <exec+0x2d4>
    80004cfc:	e8840993          	addi	s3,s0,-376
    80004d00:	f8840a93          	addi	s5,s0,-120
    80004d04:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d06:	ffffc097          	auipc	ra,0xffffc
    80004d0a:	efe080e7          	jalr	-258(ra) # 80000c04 <strlen>
    80004d0e:	0015079b          	addiw	a5,a0,1
    80004d12:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d16:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004d1a:	0f896b63          	bltu	s2,s8,80004e10 <exec+0x380>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d1e:	df043d03          	ld	s10,-528(s0)
    80004d22:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7ffd6fa4>
    80004d26:	8552                	mv	a0,s4
    80004d28:	ffffc097          	auipc	ra,0xffffc
    80004d2c:	edc080e7          	jalr	-292(ra) # 80000c04 <strlen>
    80004d30:	0015069b          	addiw	a3,a0,1
    80004d34:	8652                	mv	a2,s4
    80004d36:	85ca                	mv	a1,s2
    80004d38:	855a                	mv	a0,s6
    80004d3a:	ffffc097          	auipc	ra,0xffffc
    80004d3e:	706080e7          	jalr	1798(ra) # 80001440 <copyout>
    80004d42:	0c054963          	bltz	a0,80004e14 <exec+0x384>
    ustack[argc] = sp;
    80004d46:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004d4a:	0485                	addi	s1,s1,1
    80004d4c:	008d0793          	addi	a5,s10,8
    80004d50:	def43823          	sd	a5,-528(s0)
    80004d54:	008d3503          	ld	a0,8(s10)
    80004d58:	c909                	beqz	a0,80004d6a <exec+0x2da>
    if(argc >= MAXARG)
    80004d5a:	09a1                	addi	s3,s3,8
    80004d5c:	fb3a95e3          	bne	s5,s3,80004d06 <exec+0x276>
  ip = 0;
    80004d60:	4a81                	li	s5,0
    80004d62:	b7ad                	j	80004ccc <exec+0x23c>
  sp = sz;
    80004d64:	df843903          	ld	s2,-520(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004d68:	4481                	li	s1,0
  ustack[argc] = 0;
    80004d6a:	00349793          	slli	a5,s1,0x3
    80004d6e:	f9040713          	addi	a4,s0,-112
    80004d72:	97ba                	add	a5,a5,a4
    80004d74:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd6e9c>
  sp -= (argc+1) * sizeof(uint64);
    80004d78:	00148693          	addi	a3,s1,1
    80004d7c:	068e                	slli	a3,a3,0x3
    80004d7e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004d82:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80004d86:	4a81                	li	s5,0
  if(sp < stackbase)
    80004d88:	f58962e3          	bltu	s2,s8,80004ccc <exec+0x23c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004d8c:	e8840613          	addi	a2,s0,-376
    80004d90:	85ca                	mv	a1,s2
    80004d92:	855a                	mv	a0,s6
    80004d94:	ffffc097          	auipc	ra,0xffffc
    80004d98:	6ac080e7          	jalr	1708(ra) # 80001440 <copyout>
    80004d9c:	06054e63          	bltz	a0,80004e18 <exec+0x388>
  p->tf->a1 = sp;
    80004da0:	058bb783          	ld	a5,88(s7)
    80004da4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004da8:	de843783          	ld	a5,-536(s0)
    80004dac:	0007c703          	lbu	a4,0(a5)
    80004db0:	cf11                	beqz	a4,80004dcc <exec+0x33c>
    80004db2:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004db4:	02f00693          	li	a3,47
    80004db8:	a039                	j	80004dc6 <exec+0x336>
      last = s+1;
    80004dba:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004dbe:	0785                	addi	a5,a5,1
    80004dc0:	fff7c703          	lbu	a4,-1(a5)
    80004dc4:	c701                	beqz	a4,80004dcc <exec+0x33c>
    if(*s == '/')
    80004dc6:	fed71ce3          	bne	a4,a3,80004dbe <exec+0x32e>
    80004dca:	bfc5                	j	80004dba <exec+0x32a>
  safestrcpy(p->name, last, sizeof(p->name));
    80004dcc:	4641                	li	a2,16
    80004dce:	de843583          	ld	a1,-536(s0)
    80004dd2:	158b8513          	addi	a0,s7,344
    80004dd6:	ffffc097          	auipc	ra,0xffffc
    80004dda:	dfc080e7          	jalr	-516(ra) # 80000bd2 <safestrcpy>
  oldpagetable = p->pagetable;
    80004dde:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004de2:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004de6:	df843783          	ld	a5,-520(s0)
    80004dea:	04fbb423          	sd	a5,72(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80004dee:	058bb783          	ld	a5,88(s7)
    80004df2:	e6043703          	ld	a4,-416(s0)
    80004df6:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    80004df8:	058bb783          	ld	a5,88(s7)
    80004dfc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e00:	85e6                	mv	a1,s9
    80004e02:	ffffd097          	auipc	ra,0xffffd
    80004e06:	ade080e7          	jalr	-1314(ra) # 800018e0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e0a:	0004851b          	sext.w	a0,s1
    80004e0e:	b30d                	j	80004b30 <exec+0xa0>
  ip = 0;
    80004e10:	4a81                	li	s5,0
    80004e12:	bd6d                	j	80004ccc <exec+0x23c>
    80004e14:	4a81                	li	s5,0
    80004e16:	bd5d                	j	80004ccc <exec+0x23c>
    80004e18:	4a81                	li	s5,0
    80004e1a:	bd4d                	j	80004ccc <exec+0x23c>

0000000080004e1c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004e1c:	7179                	addi	sp,sp,-48
    80004e1e:	f406                	sd	ra,40(sp)
    80004e20:	f022                	sd	s0,32(sp)
    80004e22:	ec26                	sd	s1,24(sp)
    80004e24:	e84a                	sd	s2,16(sp)
    80004e26:	1800                	addi	s0,sp,48
    80004e28:	892e                	mv	s2,a1
    80004e2a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004e2c:	fdc40593          	addi	a1,s0,-36
    80004e30:	ffffe097          	auipc	ra,0xffffe
    80004e34:	9a4080e7          	jalr	-1628(ra) # 800027d4 <argint>
    80004e38:	04054063          	bltz	a0,80004e78 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004e3c:	fdc42703          	lw	a4,-36(s0)
    80004e40:	47bd                	li	a5,15
    80004e42:	02e7ed63          	bltu	a5,a4,80004e7c <argfd+0x60>
    80004e46:	ffffd097          	auipc	ra,0xffffd
    80004e4a:	8d6080e7          	jalr	-1834(ra) # 8000171c <myproc>
    80004e4e:	fdc42703          	lw	a4,-36(s0)
    80004e52:	01a70793          	addi	a5,a4,26
    80004e56:	078e                	slli	a5,a5,0x3
    80004e58:	953e                	add	a0,a0,a5
    80004e5a:	611c                	ld	a5,0(a0)
    80004e5c:	c395                	beqz	a5,80004e80 <argfd+0x64>
    return -1;
  if(pfd)
    80004e5e:	00090463          	beqz	s2,80004e66 <argfd+0x4a>
    *pfd = fd;
    80004e62:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004e66:	4501                	li	a0,0
  if(pf)
    80004e68:	c091                	beqz	s1,80004e6c <argfd+0x50>
    *pf = f;
    80004e6a:	e09c                	sd	a5,0(s1)
}
    80004e6c:	70a2                	ld	ra,40(sp)
    80004e6e:	7402                	ld	s0,32(sp)
    80004e70:	64e2                	ld	s1,24(sp)
    80004e72:	6942                	ld	s2,16(sp)
    80004e74:	6145                	addi	sp,sp,48
    80004e76:	8082                	ret
    return -1;
    80004e78:	557d                	li	a0,-1
    80004e7a:	bfcd                	j	80004e6c <argfd+0x50>
    return -1;
    80004e7c:	557d                	li	a0,-1
    80004e7e:	b7fd                	j	80004e6c <argfd+0x50>
    80004e80:	557d                	li	a0,-1
    80004e82:	b7ed                	j	80004e6c <argfd+0x50>

0000000080004e84 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004e84:	1101                	addi	sp,sp,-32
    80004e86:	ec06                	sd	ra,24(sp)
    80004e88:	e822                	sd	s0,16(sp)
    80004e8a:	e426                	sd	s1,8(sp)
    80004e8c:	1000                	addi	s0,sp,32
    80004e8e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004e90:	ffffd097          	auipc	ra,0xffffd
    80004e94:	88c080e7          	jalr	-1908(ra) # 8000171c <myproc>
    80004e98:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004e9a:	0d050793          	addi	a5,a0,208
    80004e9e:	4501                	li	a0,0
    80004ea0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ea2:	6398                	ld	a4,0(a5)
    80004ea4:	cb19                	beqz	a4,80004eba <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004ea6:	2505                	addiw	a0,a0,1
    80004ea8:	07a1                	addi	a5,a5,8
    80004eaa:	fed51ce3          	bne	a0,a3,80004ea2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004eae:	557d                	li	a0,-1
}
    80004eb0:	60e2                	ld	ra,24(sp)
    80004eb2:	6442                	ld	s0,16(sp)
    80004eb4:	64a2                	ld	s1,8(sp)
    80004eb6:	6105                	addi	sp,sp,32
    80004eb8:	8082                	ret
      p->ofile[fd] = f;
    80004eba:	01a50793          	addi	a5,a0,26
    80004ebe:	078e                	slli	a5,a5,0x3
    80004ec0:	963e                	add	a2,a2,a5
    80004ec2:	e204                	sd	s1,0(a2)
      return fd;
    80004ec4:	b7f5                	j	80004eb0 <fdalloc+0x2c>

0000000080004ec6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004ec6:	715d                	addi	sp,sp,-80
    80004ec8:	e486                	sd	ra,72(sp)
    80004eca:	e0a2                	sd	s0,64(sp)
    80004ecc:	fc26                	sd	s1,56(sp)
    80004ece:	f84a                	sd	s2,48(sp)
    80004ed0:	f44e                	sd	s3,40(sp)
    80004ed2:	f052                	sd	s4,32(sp)
    80004ed4:	ec56                	sd	s5,24(sp)
    80004ed6:	0880                	addi	s0,sp,80
    80004ed8:	89ae                	mv	s3,a1
    80004eda:	8ab2                	mv	s5,a2
    80004edc:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004ede:	fb040593          	addi	a1,s0,-80
    80004ee2:	fffff097          	auipc	ra,0xfffff
    80004ee6:	c10080e7          	jalr	-1008(ra) # 80003af2 <nameiparent>
    80004eea:	892a                	mv	s2,a0
    80004eec:	12050e63          	beqz	a0,80005028 <create+0x162>
    return 0;

  ilock(dp);
    80004ef0:	ffffe097          	auipc	ra,0xffffe
    80004ef4:	458080e7          	jalr	1112(ra) # 80003348 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004ef8:	4601                	li	a2,0
    80004efa:	fb040593          	addi	a1,s0,-80
    80004efe:	854a                	mv	a0,s2
    80004f00:	fffff097          	auipc	ra,0xfffff
    80004f04:	902080e7          	jalr	-1790(ra) # 80003802 <dirlookup>
    80004f08:	84aa                	mv	s1,a0
    80004f0a:	c921                	beqz	a0,80004f5a <create+0x94>
    iunlockput(dp);
    80004f0c:	854a                	mv	a0,s2
    80004f0e:	ffffe097          	auipc	ra,0xffffe
    80004f12:	678080e7          	jalr	1656(ra) # 80003586 <iunlockput>
    ilock(ip);
    80004f16:	8526                	mv	a0,s1
    80004f18:	ffffe097          	auipc	ra,0xffffe
    80004f1c:	430080e7          	jalr	1072(ra) # 80003348 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004f20:	2981                	sext.w	s3,s3
    80004f22:	4789                	li	a5,2
    80004f24:	02f99463          	bne	s3,a5,80004f4c <create+0x86>
    80004f28:	0444d783          	lhu	a5,68(s1)
    80004f2c:	37f9                	addiw	a5,a5,-2
    80004f2e:	17c2                	slli	a5,a5,0x30
    80004f30:	93c1                	srli	a5,a5,0x30
    80004f32:	4705                	li	a4,1
    80004f34:	00f76c63          	bltu	a4,a5,80004f4c <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004f38:	8526                	mv	a0,s1
    80004f3a:	60a6                	ld	ra,72(sp)
    80004f3c:	6406                	ld	s0,64(sp)
    80004f3e:	74e2                	ld	s1,56(sp)
    80004f40:	7942                	ld	s2,48(sp)
    80004f42:	79a2                	ld	s3,40(sp)
    80004f44:	7a02                	ld	s4,32(sp)
    80004f46:	6ae2                	ld	s5,24(sp)
    80004f48:	6161                	addi	sp,sp,80
    80004f4a:	8082                	ret
    iunlockput(ip);
    80004f4c:	8526                	mv	a0,s1
    80004f4e:	ffffe097          	auipc	ra,0xffffe
    80004f52:	638080e7          	jalr	1592(ra) # 80003586 <iunlockput>
    return 0;
    80004f56:	4481                	li	s1,0
    80004f58:	b7c5                	j	80004f38 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004f5a:	85ce                	mv	a1,s3
    80004f5c:	00092503          	lw	a0,0(s2)
    80004f60:	ffffe097          	auipc	ra,0xffffe
    80004f64:	250080e7          	jalr	592(ra) # 800031b0 <ialloc>
    80004f68:	84aa                	mv	s1,a0
    80004f6a:	c521                	beqz	a0,80004fb2 <create+0xec>
  ilock(ip);
    80004f6c:	ffffe097          	auipc	ra,0xffffe
    80004f70:	3dc080e7          	jalr	988(ra) # 80003348 <ilock>
  ip->major = major;
    80004f74:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80004f78:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004f7c:	4a05                	li	s4,1
    80004f7e:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80004f82:	8526                	mv	a0,s1
    80004f84:	ffffe097          	auipc	ra,0xffffe
    80004f88:	2fa080e7          	jalr	762(ra) # 8000327e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004f8c:	2981                	sext.w	s3,s3
    80004f8e:	03498a63          	beq	s3,s4,80004fc2 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80004f92:	40d0                	lw	a2,4(s1)
    80004f94:	fb040593          	addi	a1,s0,-80
    80004f98:	854a                	mv	a0,s2
    80004f9a:	fffff097          	auipc	ra,0xfffff
    80004f9e:	a78080e7          	jalr	-1416(ra) # 80003a12 <dirlink>
    80004fa2:	06054b63          	bltz	a0,80005018 <create+0x152>
  iunlockput(dp);
    80004fa6:	854a                	mv	a0,s2
    80004fa8:	ffffe097          	auipc	ra,0xffffe
    80004fac:	5de080e7          	jalr	1502(ra) # 80003586 <iunlockput>
  return ip;
    80004fb0:	b761                	j	80004f38 <create+0x72>
    panic("create: ialloc");
    80004fb2:	00002517          	auipc	a0,0x2
    80004fb6:	78e50513          	addi	a0,a0,1934 # 80007740 <userret+0x6b0>
    80004fba:	ffffb097          	auipc	ra,0xffffb
    80004fbe:	58e080e7          	jalr	1422(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    80004fc2:	04a95783          	lhu	a5,74(s2)
    80004fc6:	2785                	addiw	a5,a5,1
    80004fc8:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80004fcc:	854a                	mv	a0,s2
    80004fce:	ffffe097          	auipc	ra,0xffffe
    80004fd2:	2b0080e7          	jalr	688(ra) # 8000327e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004fd6:	40d0                	lw	a2,4(s1)
    80004fd8:	00002597          	auipc	a1,0x2
    80004fdc:	77858593          	addi	a1,a1,1912 # 80007750 <userret+0x6c0>
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	fffff097          	auipc	ra,0xfffff
    80004fe6:	a30080e7          	jalr	-1488(ra) # 80003a12 <dirlink>
    80004fea:	00054f63          	bltz	a0,80005008 <create+0x142>
    80004fee:	00492603          	lw	a2,4(s2)
    80004ff2:	00002597          	auipc	a1,0x2
    80004ff6:	76658593          	addi	a1,a1,1894 # 80007758 <userret+0x6c8>
    80004ffa:	8526                	mv	a0,s1
    80004ffc:	fffff097          	auipc	ra,0xfffff
    80005000:	a16080e7          	jalr	-1514(ra) # 80003a12 <dirlink>
    80005004:	f80557e3          	bgez	a0,80004f92 <create+0xcc>
      panic("create dots");
    80005008:	00002517          	auipc	a0,0x2
    8000500c:	75850513          	addi	a0,a0,1880 # 80007760 <userret+0x6d0>
    80005010:	ffffb097          	auipc	ra,0xffffb
    80005014:	538080e7          	jalr	1336(ra) # 80000548 <panic>
    panic("create: dirlink");
    80005018:	00002517          	auipc	a0,0x2
    8000501c:	75850513          	addi	a0,a0,1880 # 80007770 <userret+0x6e0>
    80005020:	ffffb097          	auipc	ra,0xffffb
    80005024:	528080e7          	jalr	1320(ra) # 80000548 <panic>
    return 0;
    80005028:	84aa                	mv	s1,a0
    8000502a:	b739                	j	80004f38 <create+0x72>

000000008000502c <sys_dup>:
{
    8000502c:	7179                	addi	sp,sp,-48
    8000502e:	f406                	sd	ra,40(sp)
    80005030:	f022                	sd	s0,32(sp)
    80005032:	ec26                	sd	s1,24(sp)
    80005034:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005036:	fd840613          	addi	a2,s0,-40
    8000503a:	4581                	li	a1,0
    8000503c:	4501                	li	a0,0
    8000503e:	00000097          	auipc	ra,0x0
    80005042:	dde080e7          	jalr	-546(ra) # 80004e1c <argfd>
    return -1;
    80005046:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005048:	02054363          	bltz	a0,8000506e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000504c:	fd843503          	ld	a0,-40(s0)
    80005050:	00000097          	auipc	ra,0x0
    80005054:	e34080e7          	jalr	-460(ra) # 80004e84 <fdalloc>
    80005058:	84aa                	mv	s1,a0
    return -1;
    8000505a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000505c:	00054963          	bltz	a0,8000506e <sys_dup+0x42>
  filedup(f);
    80005060:	fd843503          	ld	a0,-40(s0)
    80005064:	fffff097          	auipc	ra,0xfffff
    80005068:	358080e7          	jalr	856(ra) # 800043bc <filedup>
  return fd;
    8000506c:	87a6                	mv	a5,s1
}
    8000506e:	853e                	mv	a0,a5
    80005070:	70a2                	ld	ra,40(sp)
    80005072:	7402                	ld	s0,32(sp)
    80005074:	64e2                	ld	s1,24(sp)
    80005076:	6145                	addi	sp,sp,48
    80005078:	8082                	ret

000000008000507a <sys_read>:
{
    8000507a:	7179                	addi	sp,sp,-48
    8000507c:	f406                	sd	ra,40(sp)
    8000507e:	f022                	sd	s0,32(sp)
    80005080:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005082:	fe840613          	addi	a2,s0,-24
    80005086:	4581                	li	a1,0
    80005088:	4501                	li	a0,0
    8000508a:	00000097          	auipc	ra,0x0
    8000508e:	d92080e7          	jalr	-622(ra) # 80004e1c <argfd>
    return -1;
    80005092:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005094:	04054163          	bltz	a0,800050d6 <sys_read+0x5c>
    80005098:	fe440593          	addi	a1,s0,-28
    8000509c:	4509                	li	a0,2
    8000509e:	ffffd097          	auipc	ra,0xffffd
    800050a2:	736080e7          	jalr	1846(ra) # 800027d4 <argint>
    return -1;
    800050a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050a8:	02054763          	bltz	a0,800050d6 <sys_read+0x5c>
    800050ac:	fd840593          	addi	a1,s0,-40
    800050b0:	4505                	li	a0,1
    800050b2:	ffffd097          	auipc	ra,0xffffd
    800050b6:	744080e7          	jalr	1860(ra) # 800027f6 <argaddr>
    return -1;
    800050ba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050bc:	00054d63          	bltz	a0,800050d6 <sys_read+0x5c>
  return fileread(f, p, n);
    800050c0:	fe442603          	lw	a2,-28(s0)
    800050c4:	fd843583          	ld	a1,-40(s0)
    800050c8:	fe843503          	ld	a0,-24(s0)
    800050cc:	fffff097          	auipc	ra,0xfffff
    800050d0:	48e080e7          	jalr	1166(ra) # 8000455a <fileread>
    800050d4:	87aa                	mv	a5,a0
}
    800050d6:	853e                	mv	a0,a5
    800050d8:	70a2                	ld	ra,40(sp)
    800050da:	7402                	ld	s0,32(sp)
    800050dc:	6145                	addi	sp,sp,48
    800050de:	8082                	ret

00000000800050e0 <sys_write>:
{
    800050e0:	7179                	addi	sp,sp,-48
    800050e2:	f406                	sd	ra,40(sp)
    800050e4:	f022                	sd	s0,32(sp)
    800050e6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050e8:	fe840613          	addi	a2,s0,-24
    800050ec:	4581                	li	a1,0
    800050ee:	4501                	li	a0,0
    800050f0:	00000097          	auipc	ra,0x0
    800050f4:	d2c080e7          	jalr	-724(ra) # 80004e1c <argfd>
    return -1;
    800050f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800050fa:	04054163          	bltz	a0,8000513c <sys_write+0x5c>
    800050fe:	fe440593          	addi	a1,s0,-28
    80005102:	4509                	li	a0,2
    80005104:	ffffd097          	auipc	ra,0xffffd
    80005108:	6d0080e7          	jalr	1744(ra) # 800027d4 <argint>
    return -1;
    8000510c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000510e:	02054763          	bltz	a0,8000513c <sys_write+0x5c>
    80005112:	fd840593          	addi	a1,s0,-40
    80005116:	4505                	li	a0,1
    80005118:	ffffd097          	auipc	ra,0xffffd
    8000511c:	6de080e7          	jalr	1758(ra) # 800027f6 <argaddr>
    return -1;
    80005120:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005122:	00054d63          	bltz	a0,8000513c <sys_write+0x5c>
  return filewrite(f, p, n);
    80005126:	fe442603          	lw	a2,-28(s0)
    8000512a:	fd843583          	ld	a1,-40(s0)
    8000512e:	fe843503          	ld	a0,-24(s0)
    80005132:	fffff097          	auipc	ra,0xfffff
    80005136:	4d6080e7          	jalr	1238(ra) # 80004608 <filewrite>
    8000513a:	87aa                	mv	a5,a0
}
    8000513c:	853e                	mv	a0,a5
    8000513e:	70a2                	ld	ra,40(sp)
    80005140:	7402                	ld	s0,32(sp)
    80005142:	6145                	addi	sp,sp,48
    80005144:	8082                	ret

0000000080005146 <sys_close>:
{
    80005146:	1101                	addi	sp,sp,-32
    80005148:	ec06                	sd	ra,24(sp)
    8000514a:	e822                	sd	s0,16(sp)
    8000514c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000514e:	fe040613          	addi	a2,s0,-32
    80005152:	fec40593          	addi	a1,s0,-20
    80005156:	4501                	li	a0,0
    80005158:	00000097          	auipc	ra,0x0
    8000515c:	cc4080e7          	jalr	-828(ra) # 80004e1c <argfd>
    return -1;
    80005160:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005162:	02054463          	bltz	a0,8000518a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005166:	ffffc097          	auipc	ra,0xffffc
    8000516a:	5b6080e7          	jalr	1462(ra) # 8000171c <myproc>
    8000516e:	fec42783          	lw	a5,-20(s0)
    80005172:	07e9                	addi	a5,a5,26
    80005174:	078e                	slli	a5,a5,0x3
    80005176:	97aa                	add	a5,a5,a0
    80005178:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000517c:	fe043503          	ld	a0,-32(s0)
    80005180:	fffff097          	auipc	ra,0xfffff
    80005184:	28e080e7          	jalr	654(ra) # 8000440e <fileclose>
  return 0;
    80005188:	4781                	li	a5,0
}
    8000518a:	853e                	mv	a0,a5
    8000518c:	60e2                	ld	ra,24(sp)
    8000518e:	6442                	ld	s0,16(sp)
    80005190:	6105                	addi	sp,sp,32
    80005192:	8082                	ret

0000000080005194 <sys_fstat>:
{
    80005194:	1101                	addi	sp,sp,-32
    80005196:	ec06                	sd	ra,24(sp)
    80005198:	e822                	sd	s0,16(sp)
    8000519a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000519c:	fe840613          	addi	a2,s0,-24
    800051a0:	4581                	li	a1,0
    800051a2:	4501                	li	a0,0
    800051a4:	00000097          	auipc	ra,0x0
    800051a8:	c78080e7          	jalr	-904(ra) # 80004e1c <argfd>
    return -1;
    800051ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800051ae:	02054563          	bltz	a0,800051d8 <sys_fstat+0x44>
    800051b2:	fe040593          	addi	a1,s0,-32
    800051b6:	4505                	li	a0,1
    800051b8:	ffffd097          	auipc	ra,0xffffd
    800051bc:	63e080e7          	jalr	1598(ra) # 800027f6 <argaddr>
    return -1;
    800051c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800051c2:	00054b63          	bltz	a0,800051d8 <sys_fstat+0x44>
  return filestat(f, st);
    800051c6:	fe043583          	ld	a1,-32(s0)
    800051ca:	fe843503          	ld	a0,-24(s0)
    800051ce:	fffff097          	auipc	ra,0xfffff
    800051d2:	31a080e7          	jalr	794(ra) # 800044e8 <filestat>
    800051d6:	87aa                	mv	a5,a0
}
    800051d8:	853e                	mv	a0,a5
    800051da:	60e2                	ld	ra,24(sp)
    800051dc:	6442                	ld	s0,16(sp)
    800051de:	6105                	addi	sp,sp,32
    800051e0:	8082                	ret

00000000800051e2 <sys_link>:
{
    800051e2:	7169                	addi	sp,sp,-304
    800051e4:	f606                	sd	ra,296(sp)
    800051e6:	f222                	sd	s0,288(sp)
    800051e8:	ee26                	sd	s1,280(sp)
    800051ea:	ea4a                	sd	s2,272(sp)
    800051ec:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800051ee:	08000613          	li	a2,128
    800051f2:	ed040593          	addi	a1,s0,-304
    800051f6:	4501                	li	a0,0
    800051f8:	ffffd097          	auipc	ra,0xffffd
    800051fc:	620080e7          	jalr	1568(ra) # 80002818 <argstr>
    return -1;
    80005200:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005202:	12054363          	bltz	a0,80005328 <sys_link+0x146>
    80005206:	08000613          	li	a2,128
    8000520a:	f5040593          	addi	a1,s0,-176
    8000520e:	4505                	li	a0,1
    80005210:	ffffd097          	auipc	ra,0xffffd
    80005214:	608080e7          	jalr	1544(ra) # 80002818 <argstr>
    return -1;
    80005218:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000521a:	10054763          	bltz	a0,80005328 <sys_link+0x146>
  begin_op(ROOTDEV);
    8000521e:	4501                	li	a0,0
    80005220:	fffff097          	auipc	ra,0xfffff
    80005224:	bd0080e7          	jalr	-1072(ra) # 80003df0 <begin_op>
  if((ip = namei(old)) == 0){
    80005228:	ed040513          	addi	a0,s0,-304
    8000522c:	fffff097          	auipc	ra,0xfffff
    80005230:	8a8080e7          	jalr	-1880(ra) # 80003ad4 <namei>
    80005234:	84aa                	mv	s1,a0
    80005236:	c559                	beqz	a0,800052c4 <sys_link+0xe2>
  ilock(ip);
    80005238:	ffffe097          	auipc	ra,0xffffe
    8000523c:	110080e7          	jalr	272(ra) # 80003348 <ilock>
  if(ip->type == T_DIR){
    80005240:	04449703          	lh	a4,68(s1)
    80005244:	4785                	li	a5,1
    80005246:	08f70663          	beq	a4,a5,800052d2 <sys_link+0xf0>
  ip->nlink++;
    8000524a:	04a4d783          	lhu	a5,74(s1)
    8000524e:	2785                	addiw	a5,a5,1
    80005250:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005254:	8526                	mv	a0,s1
    80005256:	ffffe097          	auipc	ra,0xffffe
    8000525a:	028080e7          	jalr	40(ra) # 8000327e <iupdate>
  iunlock(ip);
    8000525e:	8526                	mv	a0,s1
    80005260:	ffffe097          	auipc	ra,0xffffe
    80005264:	1aa080e7          	jalr	426(ra) # 8000340a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005268:	fd040593          	addi	a1,s0,-48
    8000526c:	f5040513          	addi	a0,s0,-176
    80005270:	fffff097          	auipc	ra,0xfffff
    80005274:	882080e7          	jalr	-1918(ra) # 80003af2 <nameiparent>
    80005278:	892a                	mv	s2,a0
    8000527a:	cd2d                	beqz	a0,800052f4 <sys_link+0x112>
  ilock(dp);
    8000527c:	ffffe097          	auipc	ra,0xffffe
    80005280:	0cc080e7          	jalr	204(ra) # 80003348 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005284:	00092703          	lw	a4,0(s2)
    80005288:	409c                	lw	a5,0(s1)
    8000528a:	06f71063          	bne	a4,a5,800052ea <sys_link+0x108>
    8000528e:	40d0                	lw	a2,4(s1)
    80005290:	fd040593          	addi	a1,s0,-48
    80005294:	854a                	mv	a0,s2
    80005296:	ffffe097          	auipc	ra,0xffffe
    8000529a:	77c080e7          	jalr	1916(ra) # 80003a12 <dirlink>
    8000529e:	04054663          	bltz	a0,800052ea <sys_link+0x108>
  iunlockput(dp);
    800052a2:	854a                	mv	a0,s2
    800052a4:	ffffe097          	auipc	ra,0xffffe
    800052a8:	2e2080e7          	jalr	738(ra) # 80003586 <iunlockput>
  iput(ip);
    800052ac:	8526                	mv	a0,s1
    800052ae:	ffffe097          	auipc	ra,0xffffe
    800052b2:	1a8080e7          	jalr	424(ra) # 80003456 <iput>
  end_op(ROOTDEV);
    800052b6:	4501                	li	a0,0
    800052b8:	fffff097          	auipc	ra,0xfffff
    800052bc:	be2080e7          	jalr	-1054(ra) # 80003e9a <end_op>
  return 0;
    800052c0:	4781                	li	a5,0
    800052c2:	a09d                	j	80005328 <sys_link+0x146>
    end_op(ROOTDEV);
    800052c4:	4501                	li	a0,0
    800052c6:	fffff097          	auipc	ra,0xfffff
    800052ca:	bd4080e7          	jalr	-1068(ra) # 80003e9a <end_op>
    return -1;
    800052ce:	57fd                	li	a5,-1
    800052d0:	a8a1                	j	80005328 <sys_link+0x146>
    iunlockput(ip);
    800052d2:	8526                	mv	a0,s1
    800052d4:	ffffe097          	auipc	ra,0xffffe
    800052d8:	2b2080e7          	jalr	690(ra) # 80003586 <iunlockput>
    end_op(ROOTDEV);
    800052dc:	4501                	li	a0,0
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	bbc080e7          	jalr	-1092(ra) # 80003e9a <end_op>
    return -1;
    800052e6:	57fd                	li	a5,-1
    800052e8:	a081                	j	80005328 <sys_link+0x146>
    iunlockput(dp);
    800052ea:	854a                	mv	a0,s2
    800052ec:	ffffe097          	auipc	ra,0xffffe
    800052f0:	29a080e7          	jalr	666(ra) # 80003586 <iunlockput>
  ilock(ip);
    800052f4:	8526                	mv	a0,s1
    800052f6:	ffffe097          	auipc	ra,0xffffe
    800052fa:	052080e7          	jalr	82(ra) # 80003348 <ilock>
  ip->nlink--;
    800052fe:	04a4d783          	lhu	a5,74(s1)
    80005302:	37fd                	addiw	a5,a5,-1
    80005304:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005308:	8526                	mv	a0,s1
    8000530a:	ffffe097          	auipc	ra,0xffffe
    8000530e:	f74080e7          	jalr	-140(ra) # 8000327e <iupdate>
  iunlockput(ip);
    80005312:	8526                	mv	a0,s1
    80005314:	ffffe097          	auipc	ra,0xffffe
    80005318:	272080e7          	jalr	626(ra) # 80003586 <iunlockput>
  end_op(ROOTDEV);
    8000531c:	4501                	li	a0,0
    8000531e:	fffff097          	auipc	ra,0xfffff
    80005322:	b7c080e7          	jalr	-1156(ra) # 80003e9a <end_op>
  return -1;
    80005326:	57fd                	li	a5,-1
}
    80005328:	853e                	mv	a0,a5
    8000532a:	70b2                	ld	ra,296(sp)
    8000532c:	7412                	ld	s0,288(sp)
    8000532e:	64f2                	ld	s1,280(sp)
    80005330:	6952                	ld	s2,272(sp)
    80005332:	6155                	addi	sp,sp,304
    80005334:	8082                	ret

0000000080005336 <sys_unlink>:
{
    80005336:	7151                	addi	sp,sp,-240
    80005338:	f586                	sd	ra,232(sp)
    8000533a:	f1a2                	sd	s0,224(sp)
    8000533c:	eda6                	sd	s1,216(sp)
    8000533e:	e9ca                	sd	s2,208(sp)
    80005340:	e5ce                	sd	s3,200(sp)
    80005342:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005344:	08000613          	li	a2,128
    80005348:	f3040593          	addi	a1,s0,-208
    8000534c:	4501                	li	a0,0
    8000534e:	ffffd097          	auipc	ra,0xffffd
    80005352:	4ca080e7          	jalr	1226(ra) # 80002818 <argstr>
    80005356:	18054463          	bltz	a0,800054de <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    8000535a:	4501                	li	a0,0
    8000535c:	fffff097          	auipc	ra,0xfffff
    80005360:	a94080e7          	jalr	-1388(ra) # 80003df0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005364:	fb040593          	addi	a1,s0,-80
    80005368:	f3040513          	addi	a0,s0,-208
    8000536c:	ffffe097          	auipc	ra,0xffffe
    80005370:	786080e7          	jalr	1926(ra) # 80003af2 <nameiparent>
    80005374:	84aa                	mv	s1,a0
    80005376:	cd61                	beqz	a0,8000544e <sys_unlink+0x118>
  ilock(dp);
    80005378:	ffffe097          	auipc	ra,0xffffe
    8000537c:	fd0080e7          	jalr	-48(ra) # 80003348 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005380:	00002597          	auipc	a1,0x2
    80005384:	3d058593          	addi	a1,a1,976 # 80007750 <userret+0x6c0>
    80005388:	fb040513          	addi	a0,s0,-80
    8000538c:	ffffe097          	auipc	ra,0xffffe
    80005390:	45c080e7          	jalr	1116(ra) # 800037e8 <namecmp>
    80005394:	14050c63          	beqz	a0,800054ec <sys_unlink+0x1b6>
    80005398:	00002597          	auipc	a1,0x2
    8000539c:	3c058593          	addi	a1,a1,960 # 80007758 <userret+0x6c8>
    800053a0:	fb040513          	addi	a0,s0,-80
    800053a4:	ffffe097          	auipc	ra,0xffffe
    800053a8:	444080e7          	jalr	1092(ra) # 800037e8 <namecmp>
    800053ac:	14050063          	beqz	a0,800054ec <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800053b0:	f2c40613          	addi	a2,s0,-212
    800053b4:	fb040593          	addi	a1,s0,-80
    800053b8:	8526                	mv	a0,s1
    800053ba:	ffffe097          	auipc	ra,0xffffe
    800053be:	448080e7          	jalr	1096(ra) # 80003802 <dirlookup>
    800053c2:	892a                	mv	s2,a0
    800053c4:	12050463          	beqz	a0,800054ec <sys_unlink+0x1b6>
  ilock(ip);
    800053c8:	ffffe097          	auipc	ra,0xffffe
    800053cc:	f80080e7          	jalr	-128(ra) # 80003348 <ilock>
  if(ip->nlink < 1)
    800053d0:	04a91783          	lh	a5,74(s2)
    800053d4:	08f05463          	blez	a5,8000545c <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800053d8:	04491703          	lh	a4,68(s2)
    800053dc:	4785                	li	a5,1
    800053de:	08f70763          	beq	a4,a5,8000546c <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    800053e2:	4641                	li	a2,16
    800053e4:	4581                	li	a1,0
    800053e6:	fc040513          	addi	a0,s0,-64
    800053ea:	ffffb097          	auipc	ra,0xffffb
    800053ee:	696080e7          	jalr	1686(ra) # 80000a80 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800053f2:	4741                	li	a4,16
    800053f4:	f2c42683          	lw	a3,-212(s0)
    800053f8:	fc040613          	addi	a2,s0,-64
    800053fc:	4581                	li	a1,0
    800053fe:	8526                	mv	a0,s1
    80005400:	ffffe097          	auipc	ra,0xffffe
    80005404:	2cc080e7          	jalr	716(ra) # 800036cc <writei>
    80005408:	47c1                	li	a5,16
    8000540a:	0af51763          	bne	a0,a5,800054b8 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    8000540e:	04491703          	lh	a4,68(s2)
    80005412:	4785                	li	a5,1
    80005414:	0af70a63          	beq	a4,a5,800054c8 <sys_unlink+0x192>
  iunlockput(dp);
    80005418:	8526                	mv	a0,s1
    8000541a:	ffffe097          	auipc	ra,0xffffe
    8000541e:	16c080e7          	jalr	364(ra) # 80003586 <iunlockput>
  ip->nlink--;
    80005422:	04a95783          	lhu	a5,74(s2)
    80005426:	37fd                	addiw	a5,a5,-1
    80005428:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000542c:	854a                	mv	a0,s2
    8000542e:	ffffe097          	auipc	ra,0xffffe
    80005432:	e50080e7          	jalr	-432(ra) # 8000327e <iupdate>
  iunlockput(ip);
    80005436:	854a                	mv	a0,s2
    80005438:	ffffe097          	auipc	ra,0xffffe
    8000543c:	14e080e7          	jalr	334(ra) # 80003586 <iunlockput>
  end_op(ROOTDEV);
    80005440:	4501                	li	a0,0
    80005442:	fffff097          	auipc	ra,0xfffff
    80005446:	a58080e7          	jalr	-1448(ra) # 80003e9a <end_op>
  return 0;
    8000544a:	4501                	li	a0,0
    8000544c:	a85d                	j	80005502 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    8000544e:	4501                	li	a0,0
    80005450:	fffff097          	auipc	ra,0xfffff
    80005454:	a4a080e7          	jalr	-1462(ra) # 80003e9a <end_op>
    return -1;
    80005458:	557d                	li	a0,-1
    8000545a:	a065                	j	80005502 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    8000545c:	00002517          	auipc	a0,0x2
    80005460:	32450513          	addi	a0,a0,804 # 80007780 <userret+0x6f0>
    80005464:	ffffb097          	auipc	ra,0xffffb
    80005468:	0e4080e7          	jalr	228(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000546c:	04c92703          	lw	a4,76(s2)
    80005470:	02000793          	li	a5,32
    80005474:	f6e7f7e3          	bgeu	a5,a4,800053e2 <sys_unlink+0xac>
    80005478:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000547c:	4741                	li	a4,16
    8000547e:	86ce                	mv	a3,s3
    80005480:	f1840613          	addi	a2,s0,-232
    80005484:	4581                	li	a1,0
    80005486:	854a                	mv	a0,s2
    80005488:	ffffe097          	auipc	ra,0xffffe
    8000548c:	150080e7          	jalr	336(ra) # 800035d8 <readi>
    80005490:	47c1                	li	a5,16
    80005492:	00f51b63          	bne	a0,a5,800054a8 <sys_unlink+0x172>
    if(de.inum != 0)
    80005496:	f1845783          	lhu	a5,-232(s0)
    8000549a:	e7a1                	bnez	a5,800054e2 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000549c:	29c1                	addiw	s3,s3,16
    8000549e:	04c92783          	lw	a5,76(s2)
    800054a2:	fcf9ede3          	bltu	s3,a5,8000547c <sys_unlink+0x146>
    800054a6:	bf35                	j	800053e2 <sys_unlink+0xac>
      panic("isdirempty: readi");
    800054a8:	00002517          	auipc	a0,0x2
    800054ac:	2f050513          	addi	a0,a0,752 # 80007798 <userret+0x708>
    800054b0:	ffffb097          	auipc	ra,0xffffb
    800054b4:	098080e7          	jalr	152(ra) # 80000548 <panic>
    panic("unlink: writei");
    800054b8:	00002517          	auipc	a0,0x2
    800054bc:	2f850513          	addi	a0,a0,760 # 800077b0 <userret+0x720>
    800054c0:	ffffb097          	auipc	ra,0xffffb
    800054c4:	088080e7          	jalr	136(ra) # 80000548 <panic>
    dp->nlink--;
    800054c8:	04a4d783          	lhu	a5,74(s1)
    800054cc:	37fd                	addiw	a5,a5,-1
    800054ce:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054d2:	8526                	mv	a0,s1
    800054d4:	ffffe097          	auipc	ra,0xffffe
    800054d8:	daa080e7          	jalr	-598(ra) # 8000327e <iupdate>
    800054dc:	bf35                	j	80005418 <sys_unlink+0xe2>
    return -1;
    800054de:	557d                	li	a0,-1
    800054e0:	a00d                	j	80005502 <sys_unlink+0x1cc>
    iunlockput(ip);
    800054e2:	854a                	mv	a0,s2
    800054e4:	ffffe097          	auipc	ra,0xffffe
    800054e8:	0a2080e7          	jalr	162(ra) # 80003586 <iunlockput>
  iunlockput(dp);
    800054ec:	8526                	mv	a0,s1
    800054ee:	ffffe097          	auipc	ra,0xffffe
    800054f2:	098080e7          	jalr	152(ra) # 80003586 <iunlockput>
  end_op(ROOTDEV);
    800054f6:	4501                	li	a0,0
    800054f8:	fffff097          	auipc	ra,0xfffff
    800054fc:	9a2080e7          	jalr	-1630(ra) # 80003e9a <end_op>
  return -1;
    80005500:	557d                	li	a0,-1
}
    80005502:	70ae                	ld	ra,232(sp)
    80005504:	740e                	ld	s0,224(sp)
    80005506:	64ee                	ld	s1,216(sp)
    80005508:	694e                	ld	s2,208(sp)
    8000550a:	69ae                	ld	s3,200(sp)
    8000550c:	616d                	addi	sp,sp,240
    8000550e:	8082                	ret

0000000080005510 <sys_open>:

uint64
sys_open(void)
{
    80005510:	7131                	addi	sp,sp,-192
    80005512:	fd06                	sd	ra,184(sp)
    80005514:	f922                	sd	s0,176(sp)
    80005516:	f526                	sd	s1,168(sp)
    80005518:	f14a                	sd	s2,160(sp)
    8000551a:	ed4e                	sd	s3,152(sp)
    8000551c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000551e:	08000613          	li	a2,128
    80005522:	f5040593          	addi	a1,s0,-176
    80005526:	4501                	li	a0,0
    80005528:	ffffd097          	auipc	ra,0xffffd
    8000552c:	2f0080e7          	jalr	752(ra) # 80002818 <argstr>
    return -1;
    80005530:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005532:	0a054963          	bltz	a0,800055e4 <sys_open+0xd4>
    80005536:	f4c40593          	addi	a1,s0,-180
    8000553a:	4505                	li	a0,1
    8000553c:	ffffd097          	auipc	ra,0xffffd
    80005540:	298080e7          	jalr	664(ra) # 800027d4 <argint>
    80005544:	0a054063          	bltz	a0,800055e4 <sys_open+0xd4>

  begin_op(ROOTDEV);
    80005548:	4501                	li	a0,0
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	8a6080e7          	jalr	-1882(ra) # 80003df0 <begin_op>

  if(omode & O_CREATE){
    80005552:	f4c42783          	lw	a5,-180(s0)
    80005556:	2007f793          	andi	a5,a5,512
    8000555a:	c3dd                	beqz	a5,80005600 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    8000555c:	4681                	li	a3,0
    8000555e:	4601                	li	a2,0
    80005560:	4589                	li	a1,2
    80005562:	f5040513          	addi	a0,s0,-176
    80005566:	00000097          	auipc	ra,0x0
    8000556a:	960080e7          	jalr	-1696(ra) # 80004ec6 <create>
    8000556e:	892a                	mv	s2,a0
    if(ip == 0){
    80005570:	c151                	beqz	a0,800055f4 <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005572:	04491703          	lh	a4,68(s2)
    80005576:	478d                	li	a5,3
    80005578:	00f71763          	bne	a4,a5,80005586 <sys_open+0x76>
    8000557c:	04695703          	lhu	a4,70(s2)
    80005580:	47a5                	li	a5,9
    80005582:	0ce7e663          	bltu	a5,a4,8000564e <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005586:	fffff097          	auipc	ra,0xfffff
    8000558a:	dd6080e7          	jalr	-554(ra) # 8000435c <filealloc>
    8000558e:	89aa                	mv	s3,a0
    80005590:	c57d                	beqz	a0,8000567e <sys_open+0x16e>
    80005592:	00000097          	auipc	ra,0x0
    80005596:	8f2080e7          	jalr	-1806(ra) # 80004e84 <fdalloc>
    8000559a:	84aa                	mv	s1,a0
    8000559c:	0c054c63          	bltz	a0,80005674 <sys_open+0x164>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    800055a0:	04491703          	lh	a4,68(s2)
    800055a4:	478d                	li	a5,3
    800055a6:	0cf70063          	beq	a4,a5,80005666 <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800055aa:	4789                	li	a5,2
    800055ac:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800055b0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800055b4:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800055b8:	f4c42783          	lw	a5,-180(s0)
    800055bc:	0017c713          	xori	a4,a5,1
    800055c0:	8b05                	andi	a4,a4,1
    800055c2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800055c6:	8b8d                	andi	a5,a5,3
    800055c8:	00f037b3          	snez	a5,a5
    800055cc:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    800055d0:	854a                	mv	a0,s2
    800055d2:	ffffe097          	auipc	ra,0xffffe
    800055d6:	e38080e7          	jalr	-456(ra) # 8000340a <iunlock>
  end_op(ROOTDEV);
    800055da:	4501                	li	a0,0
    800055dc:	fffff097          	auipc	ra,0xfffff
    800055e0:	8be080e7          	jalr	-1858(ra) # 80003e9a <end_op>

  return fd;
}
    800055e4:	8526                	mv	a0,s1
    800055e6:	70ea                	ld	ra,184(sp)
    800055e8:	744a                	ld	s0,176(sp)
    800055ea:	74aa                	ld	s1,168(sp)
    800055ec:	790a                	ld	s2,160(sp)
    800055ee:	69ea                	ld	s3,152(sp)
    800055f0:	6129                	addi	sp,sp,192
    800055f2:	8082                	ret
      end_op(ROOTDEV);
    800055f4:	4501                	li	a0,0
    800055f6:	fffff097          	auipc	ra,0xfffff
    800055fa:	8a4080e7          	jalr	-1884(ra) # 80003e9a <end_op>
      return -1;
    800055fe:	b7dd                	j	800055e4 <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005600:	f5040513          	addi	a0,s0,-176
    80005604:	ffffe097          	auipc	ra,0xffffe
    80005608:	4d0080e7          	jalr	1232(ra) # 80003ad4 <namei>
    8000560c:	892a                	mv	s2,a0
    8000560e:	c90d                	beqz	a0,80005640 <sys_open+0x130>
    ilock(ip);
    80005610:	ffffe097          	auipc	ra,0xffffe
    80005614:	d38080e7          	jalr	-712(ra) # 80003348 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005618:	04491703          	lh	a4,68(s2)
    8000561c:	4785                	li	a5,1
    8000561e:	f4f71ae3          	bne	a4,a5,80005572 <sys_open+0x62>
    80005622:	f4c42783          	lw	a5,-180(s0)
    80005626:	d3a5                	beqz	a5,80005586 <sys_open+0x76>
      iunlockput(ip);
    80005628:	854a                	mv	a0,s2
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	f5c080e7          	jalr	-164(ra) # 80003586 <iunlockput>
      end_op(ROOTDEV);
    80005632:	4501                	li	a0,0
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	866080e7          	jalr	-1946(ra) # 80003e9a <end_op>
      return -1;
    8000563c:	54fd                	li	s1,-1
    8000563e:	b75d                	j	800055e4 <sys_open+0xd4>
      end_op(ROOTDEV);
    80005640:	4501                	li	a0,0
    80005642:	fffff097          	auipc	ra,0xfffff
    80005646:	858080e7          	jalr	-1960(ra) # 80003e9a <end_op>
      return -1;
    8000564a:	54fd                	li	s1,-1
    8000564c:	bf61                	j	800055e4 <sys_open+0xd4>
    iunlockput(ip);
    8000564e:	854a                	mv	a0,s2
    80005650:	ffffe097          	auipc	ra,0xffffe
    80005654:	f36080e7          	jalr	-202(ra) # 80003586 <iunlockput>
    end_op(ROOTDEV);
    80005658:	4501                	li	a0,0
    8000565a:	fffff097          	auipc	ra,0xfffff
    8000565e:	840080e7          	jalr	-1984(ra) # 80003e9a <end_op>
    return -1;
    80005662:	54fd                	li	s1,-1
    80005664:	b741                	j	800055e4 <sys_open+0xd4>
    f->type = FD_DEVICE;
    80005666:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000566a:	04691783          	lh	a5,70(s2)
    8000566e:	02f99223          	sh	a5,36(s3)
    80005672:	b789                	j	800055b4 <sys_open+0xa4>
      fileclose(f);
    80005674:	854e                	mv	a0,s3
    80005676:	fffff097          	auipc	ra,0xfffff
    8000567a:	d98080e7          	jalr	-616(ra) # 8000440e <fileclose>
    iunlockput(ip);
    8000567e:	854a                	mv	a0,s2
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	f06080e7          	jalr	-250(ra) # 80003586 <iunlockput>
    end_op(ROOTDEV);
    80005688:	4501                	li	a0,0
    8000568a:	fffff097          	auipc	ra,0xfffff
    8000568e:	810080e7          	jalr	-2032(ra) # 80003e9a <end_op>
    return -1;
    80005692:	54fd                	li	s1,-1
    80005694:	bf81                	j	800055e4 <sys_open+0xd4>

0000000080005696 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005696:	7175                	addi	sp,sp,-144
    80005698:	e506                	sd	ra,136(sp)
    8000569a:	e122                	sd	s0,128(sp)
    8000569c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    8000569e:	4501                	li	a0,0
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	750080e7          	jalr	1872(ra) # 80003df0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800056a8:	08000613          	li	a2,128
    800056ac:	f7040593          	addi	a1,s0,-144
    800056b0:	4501                	li	a0,0
    800056b2:	ffffd097          	auipc	ra,0xffffd
    800056b6:	166080e7          	jalr	358(ra) # 80002818 <argstr>
    800056ba:	02054a63          	bltz	a0,800056ee <sys_mkdir+0x58>
    800056be:	4681                	li	a3,0
    800056c0:	4601                	li	a2,0
    800056c2:	4585                	li	a1,1
    800056c4:	f7040513          	addi	a0,s0,-144
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	7fe080e7          	jalr	2046(ra) # 80004ec6 <create>
    800056d0:	cd19                	beqz	a0,800056ee <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    800056d2:	ffffe097          	auipc	ra,0xffffe
    800056d6:	eb4080e7          	jalr	-332(ra) # 80003586 <iunlockput>
  end_op(ROOTDEV);
    800056da:	4501                	li	a0,0
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	7be080e7          	jalr	1982(ra) # 80003e9a <end_op>
  return 0;
    800056e4:	4501                	li	a0,0
}
    800056e6:	60aa                	ld	ra,136(sp)
    800056e8:	640a                	ld	s0,128(sp)
    800056ea:	6149                	addi	sp,sp,144
    800056ec:	8082                	ret
    end_op(ROOTDEV);
    800056ee:	4501                	li	a0,0
    800056f0:	ffffe097          	auipc	ra,0xffffe
    800056f4:	7aa080e7          	jalr	1962(ra) # 80003e9a <end_op>
    return -1;
    800056f8:	557d                	li	a0,-1
    800056fa:	b7f5                	j	800056e6 <sys_mkdir+0x50>

00000000800056fc <sys_mknod>:

uint64
sys_mknod(void)
{
    800056fc:	7135                	addi	sp,sp,-160
    800056fe:	ed06                	sd	ra,152(sp)
    80005700:	e922                	sd	s0,144(sp)
    80005702:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005704:	4501                	li	a0,0
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	6ea080e7          	jalr	1770(ra) # 80003df0 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000570e:	08000613          	li	a2,128
    80005712:	f7040593          	addi	a1,s0,-144
    80005716:	4501                	li	a0,0
    80005718:	ffffd097          	auipc	ra,0xffffd
    8000571c:	100080e7          	jalr	256(ra) # 80002818 <argstr>
    80005720:	04054b63          	bltz	a0,80005776 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80005724:	f6c40593          	addi	a1,s0,-148
    80005728:	4505                	li	a0,1
    8000572a:	ffffd097          	auipc	ra,0xffffd
    8000572e:	0aa080e7          	jalr	170(ra) # 800027d4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005732:	04054263          	bltz	a0,80005776 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005736:	f6840593          	addi	a1,s0,-152
    8000573a:	4509                	li	a0,2
    8000573c:	ffffd097          	auipc	ra,0xffffd
    80005740:	098080e7          	jalr	152(ra) # 800027d4 <argint>
     argint(1, &major) < 0 ||
    80005744:	02054963          	bltz	a0,80005776 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005748:	f6841683          	lh	a3,-152(s0)
    8000574c:	f6c41603          	lh	a2,-148(s0)
    80005750:	458d                	li	a1,3
    80005752:	f7040513          	addi	a0,s0,-144
    80005756:	fffff097          	auipc	ra,0xfffff
    8000575a:	770080e7          	jalr	1904(ra) # 80004ec6 <create>
     argint(2, &minor) < 0 ||
    8000575e:	cd01                	beqz	a0,80005776 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005760:	ffffe097          	auipc	ra,0xffffe
    80005764:	e26080e7          	jalr	-474(ra) # 80003586 <iunlockput>
  end_op(ROOTDEV);
    80005768:	4501                	li	a0,0
    8000576a:	ffffe097          	auipc	ra,0xffffe
    8000576e:	730080e7          	jalr	1840(ra) # 80003e9a <end_op>
  return 0;
    80005772:	4501                	li	a0,0
    80005774:	a039                	j	80005782 <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005776:	4501                	li	a0,0
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	722080e7          	jalr	1826(ra) # 80003e9a <end_op>
    return -1;
    80005780:	557d                	li	a0,-1
}
    80005782:	60ea                	ld	ra,152(sp)
    80005784:	644a                	ld	s0,144(sp)
    80005786:	610d                	addi	sp,sp,160
    80005788:	8082                	ret

000000008000578a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000578a:	7135                	addi	sp,sp,-160
    8000578c:	ed06                	sd	ra,152(sp)
    8000578e:	e922                	sd	s0,144(sp)
    80005790:	e526                	sd	s1,136(sp)
    80005792:	e14a                	sd	s2,128(sp)
    80005794:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005796:	ffffc097          	auipc	ra,0xffffc
    8000579a:	f86080e7          	jalr	-122(ra) # 8000171c <myproc>
    8000579e:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    800057a0:	4501                	li	a0,0
    800057a2:	ffffe097          	auipc	ra,0xffffe
    800057a6:	64e080e7          	jalr	1614(ra) # 80003df0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800057aa:	08000613          	li	a2,128
    800057ae:	f6040593          	addi	a1,s0,-160
    800057b2:	4501                	li	a0,0
    800057b4:	ffffd097          	auipc	ra,0xffffd
    800057b8:	064080e7          	jalr	100(ra) # 80002818 <argstr>
    800057bc:	04054c63          	bltz	a0,80005814 <sys_chdir+0x8a>
    800057c0:	f6040513          	addi	a0,s0,-160
    800057c4:	ffffe097          	auipc	ra,0xffffe
    800057c8:	310080e7          	jalr	784(ra) # 80003ad4 <namei>
    800057cc:	84aa                	mv	s1,a0
    800057ce:	c139                	beqz	a0,80005814 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    800057d0:	ffffe097          	auipc	ra,0xffffe
    800057d4:	b78080e7          	jalr	-1160(ra) # 80003348 <ilock>
  if(ip->type != T_DIR){
    800057d8:	04449703          	lh	a4,68(s1)
    800057dc:	4785                	li	a5,1
    800057de:	04f71263          	bne	a4,a5,80005822 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    800057e2:	8526                	mv	a0,s1
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	c26080e7          	jalr	-986(ra) # 8000340a <iunlock>
  iput(p->cwd);
    800057ec:	15093503          	ld	a0,336(s2)
    800057f0:	ffffe097          	auipc	ra,0xffffe
    800057f4:	c66080e7          	jalr	-922(ra) # 80003456 <iput>
  end_op(ROOTDEV);
    800057f8:	4501                	li	a0,0
    800057fa:	ffffe097          	auipc	ra,0xffffe
    800057fe:	6a0080e7          	jalr	1696(ra) # 80003e9a <end_op>
  p->cwd = ip;
    80005802:	14993823          	sd	s1,336(s2)
  return 0;
    80005806:	4501                	li	a0,0
}
    80005808:	60ea                	ld	ra,152(sp)
    8000580a:	644a                	ld	s0,144(sp)
    8000580c:	64aa                	ld	s1,136(sp)
    8000580e:	690a                	ld	s2,128(sp)
    80005810:	610d                	addi	sp,sp,160
    80005812:	8082                	ret
    end_op(ROOTDEV);
    80005814:	4501                	li	a0,0
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	684080e7          	jalr	1668(ra) # 80003e9a <end_op>
    return -1;
    8000581e:	557d                	li	a0,-1
    80005820:	b7e5                	j	80005808 <sys_chdir+0x7e>
    iunlockput(ip);
    80005822:	8526                	mv	a0,s1
    80005824:	ffffe097          	auipc	ra,0xffffe
    80005828:	d62080e7          	jalr	-670(ra) # 80003586 <iunlockput>
    end_op(ROOTDEV);
    8000582c:	4501                	li	a0,0
    8000582e:	ffffe097          	auipc	ra,0xffffe
    80005832:	66c080e7          	jalr	1644(ra) # 80003e9a <end_op>
    return -1;
    80005836:	557d                	li	a0,-1
    80005838:	bfc1                	j	80005808 <sys_chdir+0x7e>

000000008000583a <sys_exec>:

uint64
sys_exec(void)
{
    8000583a:	7145                	addi	sp,sp,-464
    8000583c:	e786                	sd	ra,456(sp)
    8000583e:	e3a2                	sd	s0,448(sp)
    80005840:	ff26                	sd	s1,440(sp)
    80005842:	fb4a                	sd	s2,432(sp)
    80005844:	f74e                	sd	s3,424(sp)
    80005846:	f352                	sd	s4,416(sp)
    80005848:	ef56                	sd	s5,408(sp)
    8000584a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000584c:	08000613          	li	a2,128
    80005850:	f4040593          	addi	a1,s0,-192
    80005854:	4501                	li	a0,0
    80005856:	ffffd097          	auipc	ra,0xffffd
    8000585a:	fc2080e7          	jalr	-62(ra) # 80002818 <argstr>
    8000585e:	0c054863          	bltz	a0,8000592e <sys_exec+0xf4>
    80005862:	e3840593          	addi	a1,s0,-456
    80005866:	4505                	li	a0,1
    80005868:	ffffd097          	auipc	ra,0xffffd
    8000586c:	f8e080e7          	jalr	-114(ra) # 800027f6 <argaddr>
    80005870:	0c054963          	bltz	a0,80005942 <sys_exec+0x108>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005874:	10000613          	li	a2,256
    80005878:	4581                	li	a1,0
    8000587a:	e4040513          	addi	a0,s0,-448
    8000587e:	ffffb097          	auipc	ra,0xffffb
    80005882:	202080e7          	jalr	514(ra) # 80000a80 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005886:	e4040993          	addi	s3,s0,-448
  memset(argv, 0, sizeof(argv));
    8000588a:	894e                	mv	s2,s3
    8000588c:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    8000588e:	02000a13          	li	s4,32
    80005892:	00048a9b          	sext.w	s5,s1
      return -1;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005896:	00349793          	slli	a5,s1,0x3
    8000589a:	e3040593          	addi	a1,s0,-464
    8000589e:	e3843503          	ld	a0,-456(s0)
    800058a2:	953e                	add	a0,a0,a5
    800058a4:	ffffd097          	auipc	ra,0xffffd
    800058a8:	e96080e7          	jalr	-362(ra) # 8000273a <fetchaddr>
    800058ac:	08054d63          	bltz	a0,80005946 <sys_exec+0x10c>
      return -1;
    }
    if(uarg == 0){
    800058b0:	e3043783          	ld	a5,-464(s0)
    800058b4:	cb85                	beqz	a5,800058e4 <sys_exec+0xaa>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800058b6:	ffffb097          	auipc	ra,0xffffb
    800058ba:	fde080e7          	jalr	-34(ra) # 80000894 <kalloc>
    800058be:	85aa                	mv	a1,a0
    800058c0:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    800058c4:	cd29                	beqz	a0,8000591e <sys_exec+0xe4>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    800058c6:	6605                	lui	a2,0x1
    800058c8:	e3043503          	ld	a0,-464(s0)
    800058cc:	ffffd097          	auipc	ra,0xffffd
    800058d0:	ec0080e7          	jalr	-320(ra) # 8000278c <fetchstr>
    800058d4:	06054b63          	bltz	a0,8000594a <sys_exec+0x110>
    if(i >= NELEM(argv)){
    800058d8:	0485                	addi	s1,s1,1
    800058da:	0921                	addi	s2,s2,8
    800058dc:	fb449be3          	bne	s1,s4,80005892 <sys_exec+0x58>
      return -1;
    800058e0:	557d                	li	a0,-1
    800058e2:	a0b9                	j	80005930 <sys_exec+0xf6>
      argv[i] = 0;
    800058e4:	0a8e                	slli	s5,s5,0x3
    800058e6:	fc040793          	addi	a5,s0,-64
    800058ea:	9abe                	add	s5,s5,a5
    800058ec:	e80ab023          	sd	zero,-384(s5)
      return -1;
    }
  }

  int ret = exec(path, argv);
    800058f0:	e4040593          	addi	a1,s0,-448
    800058f4:	f4040513          	addi	a0,s0,-192
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	198080e7          	jalr	408(ra) # 80004a90 <exec>
    80005900:	84aa                	mv	s1,a0

  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005902:	10098913          	addi	s2,s3,256
    80005906:	0009b503          	ld	a0,0(s3)
    8000590a:	c901                	beqz	a0,8000591a <sys_exec+0xe0>
    kfree(argv[i]);
    8000590c:	ffffb097          	auipc	ra,0xffffb
    80005910:	f70080e7          	jalr	-144(ra) # 8000087c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005914:	09a1                	addi	s3,s3,8
    80005916:	ff2998e3          	bne	s3,s2,80005906 <sys_exec+0xcc>

  return ret;
    8000591a:	8526                	mv	a0,s1
    8000591c:	a811                	j	80005930 <sys_exec+0xf6>
      panic("sys_exec kalloc");
    8000591e:	00002517          	auipc	a0,0x2
    80005922:	ea250513          	addi	a0,a0,-350 # 800077c0 <userret+0x730>
    80005926:	ffffb097          	auipc	ra,0xffffb
    8000592a:	c22080e7          	jalr	-990(ra) # 80000548 <panic>
    return -1;
    8000592e:	557d                	li	a0,-1
}
    80005930:	60be                	ld	ra,456(sp)
    80005932:	641e                	ld	s0,448(sp)
    80005934:	74fa                	ld	s1,440(sp)
    80005936:	795a                	ld	s2,432(sp)
    80005938:	79ba                	ld	s3,424(sp)
    8000593a:	7a1a                	ld	s4,416(sp)
    8000593c:	6afa                	ld	s5,408(sp)
    8000593e:	6179                	addi	sp,sp,464
    80005940:	8082                	ret
    return -1;
    80005942:	557d                	li	a0,-1
    80005944:	b7f5                	j	80005930 <sys_exec+0xf6>
      return -1;
    80005946:	557d                	li	a0,-1
    80005948:	b7e5                	j	80005930 <sys_exec+0xf6>
      return -1;
    8000594a:	557d                	li	a0,-1
    8000594c:	b7d5                	j	80005930 <sys_exec+0xf6>

000000008000594e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000594e:	7139                	addi	sp,sp,-64
    80005950:	fc06                	sd	ra,56(sp)
    80005952:	f822                	sd	s0,48(sp)
    80005954:	f426                	sd	s1,40(sp)
    80005956:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005958:	ffffc097          	auipc	ra,0xffffc
    8000595c:	dc4080e7          	jalr	-572(ra) # 8000171c <myproc>
    80005960:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005962:	fd840593          	addi	a1,s0,-40
    80005966:	4501                	li	a0,0
    80005968:	ffffd097          	auipc	ra,0xffffd
    8000596c:	e8e080e7          	jalr	-370(ra) # 800027f6 <argaddr>
    return -1;
    80005970:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005972:	0e054063          	bltz	a0,80005a52 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005976:	fc840593          	addi	a1,s0,-56
    8000597a:	fd040513          	addi	a0,s0,-48
    8000597e:	fffff097          	auipc	ra,0xfffff
    80005982:	dce080e7          	jalr	-562(ra) # 8000474c <pipealloc>
    return -1;
    80005986:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005988:	0c054563          	bltz	a0,80005a52 <sys_pipe+0x104>
  fd0 = -1;
    8000598c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005990:	fd043503          	ld	a0,-48(s0)
    80005994:	fffff097          	auipc	ra,0xfffff
    80005998:	4f0080e7          	jalr	1264(ra) # 80004e84 <fdalloc>
    8000599c:	fca42223          	sw	a0,-60(s0)
    800059a0:	08054c63          	bltz	a0,80005a38 <sys_pipe+0xea>
    800059a4:	fc843503          	ld	a0,-56(s0)
    800059a8:	fffff097          	auipc	ra,0xfffff
    800059ac:	4dc080e7          	jalr	1244(ra) # 80004e84 <fdalloc>
    800059b0:	fca42023          	sw	a0,-64(s0)
    800059b4:	06054863          	bltz	a0,80005a24 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800059b8:	4691                	li	a3,4
    800059ba:	fc440613          	addi	a2,s0,-60
    800059be:	fd843583          	ld	a1,-40(s0)
    800059c2:	68a8                	ld	a0,80(s1)
    800059c4:	ffffc097          	auipc	ra,0xffffc
    800059c8:	a7c080e7          	jalr	-1412(ra) # 80001440 <copyout>
    800059cc:	02054063          	bltz	a0,800059ec <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800059d0:	4691                	li	a3,4
    800059d2:	fc040613          	addi	a2,s0,-64
    800059d6:	fd843583          	ld	a1,-40(s0)
    800059da:	0591                	addi	a1,a1,4
    800059dc:	68a8                	ld	a0,80(s1)
    800059de:	ffffc097          	auipc	ra,0xffffc
    800059e2:	a62080e7          	jalr	-1438(ra) # 80001440 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800059e6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800059e8:	06055563          	bgez	a0,80005a52 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800059ec:	fc442783          	lw	a5,-60(s0)
    800059f0:	07e9                	addi	a5,a5,26
    800059f2:	078e                	slli	a5,a5,0x3
    800059f4:	97a6                	add	a5,a5,s1
    800059f6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800059fa:	fc042503          	lw	a0,-64(s0)
    800059fe:	0569                	addi	a0,a0,26
    80005a00:	050e                	slli	a0,a0,0x3
    80005a02:	9526                	add	a0,a0,s1
    80005a04:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005a08:	fd043503          	ld	a0,-48(s0)
    80005a0c:	fffff097          	auipc	ra,0xfffff
    80005a10:	a02080e7          	jalr	-1534(ra) # 8000440e <fileclose>
    fileclose(wf);
    80005a14:	fc843503          	ld	a0,-56(s0)
    80005a18:	fffff097          	auipc	ra,0xfffff
    80005a1c:	9f6080e7          	jalr	-1546(ra) # 8000440e <fileclose>
    return -1;
    80005a20:	57fd                	li	a5,-1
    80005a22:	a805                	j	80005a52 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005a24:	fc442783          	lw	a5,-60(s0)
    80005a28:	0007c863          	bltz	a5,80005a38 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005a2c:	01a78513          	addi	a0,a5,26
    80005a30:	050e                	slli	a0,a0,0x3
    80005a32:	9526                	add	a0,a0,s1
    80005a34:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005a38:	fd043503          	ld	a0,-48(s0)
    80005a3c:	fffff097          	auipc	ra,0xfffff
    80005a40:	9d2080e7          	jalr	-1582(ra) # 8000440e <fileclose>
    fileclose(wf);
    80005a44:	fc843503          	ld	a0,-56(s0)
    80005a48:	fffff097          	auipc	ra,0xfffff
    80005a4c:	9c6080e7          	jalr	-1594(ra) # 8000440e <fileclose>
    return -1;
    80005a50:	57fd                	li	a5,-1
}
    80005a52:	853e                	mv	a0,a5
    80005a54:	70e2                	ld	ra,56(sp)
    80005a56:	7442                	ld	s0,48(sp)
    80005a58:	74a2                	ld	s1,40(sp)
    80005a5a:	6121                	addi	sp,sp,64
    80005a5c:	8082                	ret

0000000080005a5e <sys_crash>:

// system call to test crashes
uint64
sys_crash(void)
{
    80005a5e:	7171                	addi	sp,sp,-176
    80005a60:	f506                	sd	ra,168(sp)
    80005a62:	f122                	sd	s0,160(sp)
    80005a64:	ed26                	sd	s1,152(sp)
    80005a66:	1900                	addi	s0,sp,176
  char path[MAXPATH];
  struct inode *ip;
  int crash;
  
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005a68:	08000613          	li	a2,128
    80005a6c:	f6040593          	addi	a1,s0,-160
    80005a70:	4501                	li	a0,0
    80005a72:	ffffd097          	auipc	ra,0xffffd
    80005a76:	da6080e7          	jalr	-602(ra) # 80002818 <argstr>
    return -1;
    80005a7a:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005a7c:	04054363          	bltz	a0,80005ac2 <sys_crash+0x64>
    80005a80:	f5c40593          	addi	a1,s0,-164
    80005a84:	4505                	li	a0,1
    80005a86:	ffffd097          	auipc	ra,0xffffd
    80005a8a:	d4e080e7          	jalr	-690(ra) # 800027d4 <argint>
    return -1;
    80005a8e:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005a90:	02054963          	bltz	a0,80005ac2 <sys_crash+0x64>
  ip = create(path, T_FILE, 0, 0);
    80005a94:	4681                	li	a3,0
    80005a96:	4601                	li	a2,0
    80005a98:	4589                	li	a1,2
    80005a9a:	f6040513          	addi	a0,s0,-160
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	428080e7          	jalr	1064(ra) # 80004ec6 <create>
    80005aa6:	84aa                	mv	s1,a0
  if(ip == 0){
    80005aa8:	c11d                	beqz	a0,80005ace <sys_crash+0x70>
    return -1;
  }
  iunlockput(ip);
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	adc080e7          	jalr	-1316(ra) # 80003586 <iunlockput>
  crash_op(ip->dev, crash);
    80005ab2:	f5c42583          	lw	a1,-164(s0)
    80005ab6:	4088                	lw	a0,0(s1)
    80005ab8:	ffffe097          	auipc	ra,0xffffe
    80005abc:	634080e7          	jalr	1588(ra) # 800040ec <crash_op>
  return 0;
    80005ac0:	4781                	li	a5,0
}
    80005ac2:	853e                	mv	a0,a5
    80005ac4:	70aa                	ld	ra,168(sp)
    80005ac6:	740a                	ld	s0,160(sp)
    80005ac8:	64ea                	ld	s1,152(sp)
    80005aca:	614d                	addi	sp,sp,176
    80005acc:	8082                	ret
    return -1;
    80005ace:	57fd                	li	a5,-1
    80005ad0:	bfcd                	j	80005ac2 <sys_crash+0x64>
	...

0000000080005ae0 <kernelvec>:
    80005ae0:	7111                	addi	sp,sp,-256
    80005ae2:	e006                	sd	ra,0(sp)
    80005ae4:	e40a                	sd	sp,8(sp)
    80005ae6:	e80e                	sd	gp,16(sp)
    80005ae8:	ec12                	sd	tp,24(sp)
    80005aea:	f016                	sd	t0,32(sp)
    80005aec:	f41a                	sd	t1,40(sp)
    80005aee:	f81e                	sd	t2,48(sp)
    80005af0:	fc22                	sd	s0,56(sp)
    80005af2:	e0a6                	sd	s1,64(sp)
    80005af4:	e4aa                	sd	a0,72(sp)
    80005af6:	e8ae                	sd	a1,80(sp)
    80005af8:	ecb2                	sd	a2,88(sp)
    80005afa:	f0b6                	sd	a3,96(sp)
    80005afc:	f4ba                	sd	a4,104(sp)
    80005afe:	f8be                	sd	a5,112(sp)
    80005b00:	fcc2                	sd	a6,120(sp)
    80005b02:	e146                	sd	a7,128(sp)
    80005b04:	e54a                	sd	s2,136(sp)
    80005b06:	e94e                	sd	s3,144(sp)
    80005b08:	ed52                	sd	s4,152(sp)
    80005b0a:	f156                	sd	s5,160(sp)
    80005b0c:	f55a                	sd	s6,168(sp)
    80005b0e:	f95e                	sd	s7,176(sp)
    80005b10:	fd62                	sd	s8,184(sp)
    80005b12:	e1e6                	sd	s9,192(sp)
    80005b14:	e5ea                	sd	s10,200(sp)
    80005b16:	e9ee                	sd	s11,208(sp)
    80005b18:	edf2                	sd	t3,216(sp)
    80005b1a:	f1f6                	sd	t4,224(sp)
    80005b1c:	f5fa                	sd	t5,232(sp)
    80005b1e:	f9fe                	sd	t6,240(sp)
    80005b20:	ae7fc0ef          	jal	ra,80002606 <kerneltrap>
    80005b24:	6082                	ld	ra,0(sp)
    80005b26:	6122                	ld	sp,8(sp)
    80005b28:	61c2                	ld	gp,16(sp)
    80005b2a:	7282                	ld	t0,32(sp)
    80005b2c:	7322                	ld	t1,40(sp)
    80005b2e:	73c2                	ld	t2,48(sp)
    80005b30:	7462                	ld	s0,56(sp)
    80005b32:	6486                	ld	s1,64(sp)
    80005b34:	6526                	ld	a0,72(sp)
    80005b36:	65c6                	ld	a1,80(sp)
    80005b38:	6666                	ld	a2,88(sp)
    80005b3a:	7686                	ld	a3,96(sp)
    80005b3c:	7726                	ld	a4,104(sp)
    80005b3e:	77c6                	ld	a5,112(sp)
    80005b40:	7866                	ld	a6,120(sp)
    80005b42:	688a                	ld	a7,128(sp)
    80005b44:	692a                	ld	s2,136(sp)
    80005b46:	69ca                	ld	s3,144(sp)
    80005b48:	6a6a                	ld	s4,152(sp)
    80005b4a:	7a8a                	ld	s5,160(sp)
    80005b4c:	7b2a                	ld	s6,168(sp)
    80005b4e:	7bca                	ld	s7,176(sp)
    80005b50:	7c6a                	ld	s8,184(sp)
    80005b52:	6c8e                	ld	s9,192(sp)
    80005b54:	6d2e                	ld	s10,200(sp)
    80005b56:	6dce                	ld	s11,208(sp)
    80005b58:	6e6e                	ld	t3,216(sp)
    80005b5a:	7e8e                	ld	t4,224(sp)
    80005b5c:	7f2e                	ld	t5,232(sp)
    80005b5e:	7fce                	ld	t6,240(sp)
    80005b60:	6111                	addi	sp,sp,256
    80005b62:	10200073          	sret
    80005b66:	00000013          	nop
    80005b6a:	00000013          	nop
    80005b6e:	0001                	nop

0000000080005b70 <timervec>:
    80005b70:	34051573          	csrrw	a0,mscratch,a0
    80005b74:	e10c                	sd	a1,0(a0)
    80005b76:	e510                	sd	a2,8(a0)
    80005b78:	e914                	sd	a3,16(a0)
    80005b7a:	710c                	ld	a1,32(a0)
    80005b7c:	7510                	ld	a2,40(a0)
    80005b7e:	6194                	ld	a3,0(a1)
    80005b80:	96b2                	add	a3,a3,a2
    80005b82:	e194                	sd	a3,0(a1)
    80005b84:	4589                	li	a1,2
    80005b86:	14459073          	csrw	sip,a1
    80005b8a:	6914                	ld	a3,16(a0)
    80005b8c:	6510                	ld	a2,8(a0)
    80005b8e:	610c                	ld	a1,0(a0)
    80005b90:	34051573          	csrrw	a0,mscratch,a0
    80005b94:	30200073          	mret
	...

0000000080005b9a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005b9a:	1141                	addi	sp,sp,-16
    80005b9c:	e422                	sd	s0,8(sp)
    80005b9e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ba0:	0c0007b7          	lui	a5,0xc000
    80005ba4:	4705                	li	a4,1
    80005ba6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ba8:	c3d8                	sw	a4,4(a5)
}
    80005baa:	6422                	ld	s0,8(sp)
    80005bac:	0141                	addi	sp,sp,16
    80005bae:	8082                	ret

0000000080005bb0 <plicinithart>:

void
plicinithart(void)
{
    80005bb0:	1141                	addi	sp,sp,-16
    80005bb2:	e406                	sd	ra,8(sp)
    80005bb4:	e022                	sd	s0,0(sp)
    80005bb6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bb8:	ffffc097          	auipc	ra,0xffffc
    80005bbc:	b38080e7          	jalr	-1224(ra) # 800016f0 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005bc0:	0085171b          	slliw	a4,a0,0x8
    80005bc4:	0c0027b7          	lui	a5,0xc002
    80005bc8:	97ba                	add	a5,a5,a4
    80005bca:	40200713          	li	a4,1026
    80005bce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005bd2:	00d5151b          	slliw	a0,a0,0xd
    80005bd6:	0c2017b7          	lui	a5,0xc201
    80005bda:	953e                	add	a0,a0,a5
    80005bdc:	00052023          	sw	zero,0(a0)
}
    80005be0:	60a2                	ld	ra,8(sp)
    80005be2:	6402                	ld	s0,0(sp)
    80005be4:	0141                	addi	sp,sp,16
    80005be6:	8082                	ret

0000000080005be8 <plic_pending>:

// return a bitmap of which IRQs are waiting
// to be served.
uint64
plic_pending(void)
{
    80005be8:	1141                	addi	sp,sp,-16
    80005bea:	e422                	sd	s0,8(sp)
    80005bec:	0800                	addi	s0,sp,16
  //mask = *(uint32*)(PLIC + 0x1000);
  //mask |= (uint64)*(uint32*)(PLIC + 0x1004) << 32;
  mask = *(uint64*)PLIC_PENDING;

  return mask;
}
    80005bee:	0c0017b7          	lui	a5,0xc001
    80005bf2:	6388                	ld	a0,0(a5)
    80005bf4:	6422                	ld	s0,8(sp)
    80005bf6:	0141                	addi	sp,sp,16
    80005bf8:	8082                	ret

0000000080005bfa <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005bfa:	1141                	addi	sp,sp,-16
    80005bfc:	e406                	sd	ra,8(sp)
    80005bfe:	e022                	sd	s0,0(sp)
    80005c00:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c02:	ffffc097          	auipc	ra,0xffffc
    80005c06:	aee080e7          	jalr	-1298(ra) # 800016f0 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c0a:	00d5179b          	slliw	a5,a0,0xd
    80005c0e:	0c201537          	lui	a0,0xc201
    80005c12:	953e                	add	a0,a0,a5
  return irq;
}
    80005c14:	4148                	lw	a0,4(a0)
    80005c16:	60a2                	ld	ra,8(sp)
    80005c18:	6402                	ld	s0,0(sp)
    80005c1a:	0141                	addi	sp,sp,16
    80005c1c:	8082                	ret

0000000080005c1e <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c1e:	1101                	addi	sp,sp,-32
    80005c20:	ec06                	sd	ra,24(sp)
    80005c22:	e822                	sd	s0,16(sp)
    80005c24:	e426                	sd	s1,8(sp)
    80005c26:	1000                	addi	s0,sp,32
    80005c28:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c2a:	ffffc097          	auipc	ra,0xffffc
    80005c2e:	ac6080e7          	jalr	-1338(ra) # 800016f0 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c32:	00d5151b          	slliw	a0,a0,0xd
    80005c36:	0c2017b7          	lui	a5,0xc201
    80005c3a:	97aa                	add	a5,a5,a0
    80005c3c:	c3c4                	sw	s1,4(a5)
}
    80005c3e:	60e2                	ld	ra,24(sp)
    80005c40:	6442                	ld	s0,16(sp)
    80005c42:	64a2                	ld	s1,8(sp)
    80005c44:	6105                	addi	sp,sp,32
    80005c46:	8082                	ret

0000000080005c48 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80005c48:	1141                	addi	sp,sp,-16
    80005c4a:	e406                	sd	ra,8(sp)
    80005c4c:	e022                	sd	s0,0(sp)
    80005c4e:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c50:	479d                	li	a5,7
    80005c52:	06b7c963          	blt	a5,a1,80005cc4 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80005c56:	00151793          	slli	a5,a0,0x1
    80005c5a:	97aa                	add	a5,a5,a0
    80005c5c:	00c79713          	slli	a4,a5,0xc
    80005c60:	0001c797          	auipc	a5,0x1c
    80005c64:	3a078793          	addi	a5,a5,928 # 80022000 <disk>
    80005c68:	97ba                	add	a5,a5,a4
    80005c6a:	97ae                	add	a5,a5,a1
    80005c6c:	6709                	lui	a4,0x2
    80005c6e:	97ba                	add	a5,a5,a4
    80005c70:	0187c783          	lbu	a5,24(a5)
    80005c74:	e3a5                	bnez	a5,80005cd4 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80005c76:	0001c817          	auipc	a6,0x1c
    80005c7a:	38a80813          	addi	a6,a6,906 # 80022000 <disk>
    80005c7e:	00151693          	slli	a3,a0,0x1
    80005c82:	00a68733          	add	a4,a3,a0
    80005c86:	0732                	slli	a4,a4,0xc
    80005c88:	00e807b3          	add	a5,a6,a4
    80005c8c:	6709                	lui	a4,0x2
    80005c8e:	00f70633          	add	a2,a4,a5
    80005c92:	6210                	ld	a2,0(a2)
    80005c94:	00459893          	slli	a7,a1,0x4
    80005c98:	9646                	add	a2,a2,a7
    80005c9a:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    80005c9e:	97ae                	add	a5,a5,a1
    80005ca0:	97ba                	add	a5,a5,a4
    80005ca2:	4605                	li	a2,1
    80005ca4:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80005ca8:	96aa                	add	a3,a3,a0
    80005caa:	06b2                	slli	a3,a3,0xc
    80005cac:	0761                	addi	a4,a4,24
    80005cae:	96ba                	add	a3,a3,a4
    80005cb0:	00d80533          	add	a0,a6,a3
    80005cb4:	ffffc097          	auipc	ra,0xffffc
    80005cb8:	3fe080e7          	jalr	1022(ra) # 800020b2 <wakeup>
}
    80005cbc:	60a2                	ld	ra,8(sp)
    80005cbe:	6402                	ld	s0,0(sp)
    80005cc0:	0141                	addi	sp,sp,16
    80005cc2:	8082                	ret
    panic("virtio_disk_intr 1");
    80005cc4:	00002517          	auipc	a0,0x2
    80005cc8:	b0c50513          	addi	a0,a0,-1268 # 800077d0 <userret+0x740>
    80005ccc:	ffffb097          	auipc	ra,0xffffb
    80005cd0:	87c080e7          	jalr	-1924(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80005cd4:	00002517          	auipc	a0,0x2
    80005cd8:	b1450513          	addi	a0,a0,-1260 # 800077e8 <userret+0x758>
    80005cdc:	ffffb097          	auipc	ra,0xffffb
    80005ce0:	86c080e7          	jalr	-1940(ra) # 80000548 <panic>

0000000080005ce4 <virtio_disk_init>:
  __sync_synchronize();
    80005ce4:	0ff0000f          	fence
  if(disk[n].init)
    80005ce8:	00151793          	slli	a5,a0,0x1
    80005cec:	97aa                	add	a5,a5,a0
    80005cee:	07b2                	slli	a5,a5,0xc
    80005cf0:	0001c717          	auipc	a4,0x1c
    80005cf4:	31070713          	addi	a4,a4,784 # 80022000 <disk>
    80005cf8:	973e                	add	a4,a4,a5
    80005cfa:	6789                	lui	a5,0x2
    80005cfc:	97ba                	add	a5,a5,a4
    80005cfe:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80005d02:	c391                	beqz	a5,80005d06 <virtio_disk_init+0x22>
    80005d04:	8082                	ret
{
    80005d06:	7139                	addi	sp,sp,-64
    80005d08:	fc06                	sd	ra,56(sp)
    80005d0a:	f822                	sd	s0,48(sp)
    80005d0c:	f426                	sd	s1,40(sp)
    80005d0e:	f04a                	sd	s2,32(sp)
    80005d10:	ec4e                	sd	s3,24(sp)
    80005d12:	e852                	sd	s4,16(sp)
    80005d14:	e456                	sd	s5,8(sp)
    80005d16:	0080                	addi	s0,sp,64
    80005d18:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80005d1a:	85aa                	mv	a1,a0
    80005d1c:	00002517          	auipc	a0,0x2
    80005d20:	ae450513          	addi	a0,a0,-1308 # 80007800 <userret+0x770>
    80005d24:	ffffb097          	auipc	ra,0xffffb
    80005d28:	86e080e7          	jalr	-1938(ra) # 80000592 <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    80005d2c:	00149993          	slli	s3,s1,0x1
    80005d30:	99a6                	add	s3,s3,s1
    80005d32:	09b2                	slli	s3,s3,0xc
    80005d34:	6789                	lui	a5,0x2
    80005d36:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80005d3a:	97ce                	add	a5,a5,s3
    80005d3c:	00002597          	auipc	a1,0x2
    80005d40:	adc58593          	addi	a1,a1,-1316 # 80007818 <userret+0x788>
    80005d44:	0001c517          	auipc	a0,0x1c
    80005d48:	2bc50513          	addi	a0,a0,700 # 80022000 <disk>
    80005d4c:	953e                	add	a0,a0,a5
    80005d4e:	ffffb097          	auipc	ra,0xffffb
    80005d52:	b60080e7          	jalr	-1184(ra) # 800008ae <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d56:	0014891b          	addiw	s2,s1,1
    80005d5a:	00c9191b          	slliw	s2,s2,0xc
    80005d5e:	100007b7          	lui	a5,0x10000
    80005d62:	97ca                	add	a5,a5,s2
    80005d64:	4398                	lw	a4,0(a5)
    80005d66:	2701                	sext.w	a4,a4
    80005d68:	747277b7          	lui	a5,0x74727
    80005d6c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d70:	12f71663          	bne	a4,a5,80005e9c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80005d74:	100007b7          	lui	a5,0x10000
    80005d78:	0791                	addi	a5,a5,4
    80005d7a:	97ca                	add	a5,a5,s2
    80005d7c:	439c                	lw	a5,0(a5)
    80005d7e:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d80:	4705                	li	a4,1
    80005d82:	10e79d63          	bne	a5,a4,80005e9c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d86:	100007b7          	lui	a5,0x10000
    80005d8a:	07a1                	addi	a5,a5,8
    80005d8c:	97ca                	add	a5,a5,s2
    80005d8e:	439c                	lw	a5,0(a5)
    80005d90:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80005d92:	4709                	li	a4,2
    80005d94:	10e79463          	bne	a5,a4,80005e9c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d98:	100007b7          	lui	a5,0x10000
    80005d9c:	07b1                	addi	a5,a5,12
    80005d9e:	97ca                	add	a5,a5,s2
    80005da0:	4398                	lw	a4,0(a5)
    80005da2:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005da4:	554d47b7          	lui	a5,0x554d4
    80005da8:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005dac:	0ef71863          	bne	a4,a5,80005e9c <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005db0:	100007b7          	lui	a5,0x10000
    80005db4:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80005db8:	96ca                	add	a3,a3,s2
    80005dba:	4705                	li	a4,1
    80005dbc:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005dbe:	470d                	li	a4,3
    80005dc0:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    80005dc2:	01078713          	addi	a4,a5,16
    80005dc6:	974a                	add	a4,a4,s2
    80005dc8:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005dca:	02078613          	addi	a2,a5,32
    80005dce:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005dd0:	c7ffe737          	lui	a4,0xc7ffe
    80005dd4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd6703>
    80005dd8:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005dda:	2701                	sext.w	a4,a4
    80005ddc:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005dde:	472d                	li	a4,11
    80005de0:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005de2:	473d                	li	a4,15
    80005de4:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005de6:	02878713          	addi	a4,a5,40
    80005dea:	974a                	add	a4,a4,s2
    80005dec:	6685                	lui	a3,0x1
    80005dee:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005df0:	03078713          	addi	a4,a5,48
    80005df4:	974a                	add	a4,a4,s2
    80005df6:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005dfa:	03478793          	addi	a5,a5,52
    80005dfe:	97ca                	add	a5,a5,s2
    80005e00:	439c                	lw	a5,0(a5)
    80005e02:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e04:	c7c5                	beqz	a5,80005eac <virtio_disk_init+0x1c8>
  if(max < NUM)
    80005e06:	471d                	li	a4,7
    80005e08:	0af77a63          	bgeu	a4,a5,80005ebc <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e0c:	10000ab7          	lui	s5,0x10000
    80005e10:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80005e14:	97ca                	add	a5,a5,s2
    80005e16:	4721                	li	a4,8
    80005e18:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80005e1a:	0001ca17          	auipc	s4,0x1c
    80005e1e:	1e6a0a13          	addi	s4,s4,486 # 80022000 <disk>
    80005e22:	99d2                	add	s3,s3,s4
    80005e24:	6609                	lui	a2,0x2
    80005e26:	4581                	li	a1,0
    80005e28:	854e                	mv	a0,s3
    80005e2a:	ffffb097          	auipc	ra,0xffffb
    80005e2e:	c56080e7          	jalr	-938(ra) # 80000a80 <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    80005e32:	040a8a93          	addi	s5,s5,64
    80005e36:	9956                	add	s2,s2,s5
    80005e38:	00c9d793          	srli	a5,s3,0xc
    80005e3c:	2781                	sext.w	a5,a5
    80005e3e:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80005e42:	00149693          	slli	a3,s1,0x1
    80005e46:	009687b3          	add	a5,a3,s1
    80005e4a:	07b2                	slli	a5,a5,0xc
    80005e4c:	97d2                	add	a5,a5,s4
    80005e4e:	6609                	lui	a2,0x2
    80005e50:	97b2                	add	a5,a5,a2
    80005e52:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80005e56:	08098713          	addi	a4,s3,128
    80005e5a:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    80005e5c:	6705                	lui	a4,0x1
    80005e5e:	99ba                	add	s3,s3,a4
    80005e60:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80005e64:	4705                	li	a4,1
    80005e66:	00e78c23          	sb	a4,24(a5)
    80005e6a:	00e78ca3          	sb	a4,25(a5)
    80005e6e:	00e78d23          	sb	a4,26(a5)
    80005e72:	00e78da3          	sb	a4,27(a5)
    80005e76:	00e78e23          	sb	a4,28(a5)
    80005e7a:	00e78ea3          	sb	a4,29(a5)
    80005e7e:	00e78f23          	sb	a4,30(a5)
    80005e82:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80005e86:	0ae7a423          	sw	a4,168(a5)
}
    80005e8a:	70e2                	ld	ra,56(sp)
    80005e8c:	7442                	ld	s0,48(sp)
    80005e8e:	74a2                	ld	s1,40(sp)
    80005e90:	7902                	ld	s2,32(sp)
    80005e92:	69e2                	ld	s3,24(sp)
    80005e94:	6a42                	ld	s4,16(sp)
    80005e96:	6aa2                	ld	s5,8(sp)
    80005e98:	6121                	addi	sp,sp,64
    80005e9a:	8082                	ret
    panic("could not find virtio disk");
    80005e9c:	00002517          	auipc	a0,0x2
    80005ea0:	98c50513          	addi	a0,a0,-1652 # 80007828 <userret+0x798>
    80005ea4:	ffffa097          	auipc	ra,0xffffa
    80005ea8:	6a4080e7          	jalr	1700(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    80005eac:	00002517          	auipc	a0,0x2
    80005eb0:	99c50513          	addi	a0,a0,-1636 # 80007848 <userret+0x7b8>
    80005eb4:	ffffa097          	auipc	ra,0xffffa
    80005eb8:	694080e7          	jalr	1684(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    80005ebc:	00002517          	auipc	a0,0x2
    80005ec0:	9ac50513          	addi	a0,a0,-1620 # 80007868 <userret+0x7d8>
    80005ec4:	ffffa097          	auipc	ra,0xffffa
    80005ec8:	684080e7          	jalr	1668(ra) # 80000548 <panic>

0000000080005ecc <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    80005ecc:	7135                	addi	sp,sp,-160
    80005ece:	ed06                	sd	ra,152(sp)
    80005ed0:	e922                	sd	s0,144(sp)
    80005ed2:	e526                	sd	s1,136(sp)
    80005ed4:	e14a                	sd	s2,128(sp)
    80005ed6:	fcce                	sd	s3,120(sp)
    80005ed8:	f8d2                	sd	s4,112(sp)
    80005eda:	f4d6                	sd	s5,104(sp)
    80005edc:	f0da                	sd	s6,96(sp)
    80005ede:	ecde                	sd	s7,88(sp)
    80005ee0:	e8e2                	sd	s8,80(sp)
    80005ee2:	e4e6                	sd	s9,72(sp)
    80005ee4:	e0ea                	sd	s10,64(sp)
    80005ee6:	fc6e                	sd	s11,56(sp)
    80005ee8:	1100                	addi	s0,sp,160
    80005eea:	8aaa                	mv	s5,a0
    80005eec:	8c2e                	mv	s8,a1
    80005eee:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ef0:	45dc                	lw	a5,12(a1)
    80005ef2:	0017979b          	slliw	a5,a5,0x1
    80005ef6:	1782                	slli	a5,a5,0x20
    80005ef8:	9381                	srli	a5,a5,0x20
    80005efa:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    80005efe:	00151493          	slli	s1,a0,0x1
    80005f02:	94aa                	add	s1,s1,a0
    80005f04:	04b2                	slli	s1,s1,0xc
    80005f06:	6909                	lui	s2,0x2
    80005f08:	0b090c93          	addi	s9,s2,176 # 20b0 <_entry-0x7fffdf50>
    80005f0c:	9ca6                	add	s9,s9,s1
    80005f0e:	0001c997          	auipc	s3,0x1c
    80005f12:	0f298993          	addi	s3,s3,242 # 80022000 <disk>
    80005f16:	9cce                	add	s9,s9,s3
    80005f18:	8566                	mv	a0,s9
    80005f1a:	ffffb097          	auipc	ra,0xffffb
    80005f1e:	aa2080e7          	jalr	-1374(ra) # 800009bc <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80005f22:	0961                	addi	s2,s2,24
    80005f24:	94ca                	add	s1,s1,s2
    80005f26:	99a6                	add	s3,s3,s1
  for(int i = 0; i < 3; i++){
    80005f28:	4a01                	li	s4,0
  for(int i = 0; i < NUM; i++){
    80005f2a:	44a1                	li	s1,8
      disk[n].free[i] = 0;
    80005f2c:	001a9793          	slli	a5,s5,0x1
    80005f30:	97d6                	add	a5,a5,s5
    80005f32:	07b2                	slli	a5,a5,0xc
    80005f34:	0001cb97          	auipc	s7,0x1c
    80005f38:	0ccb8b93          	addi	s7,s7,204 # 80022000 <disk>
    80005f3c:	9bbe                	add	s7,s7,a5
    80005f3e:	a8a9                	j	80005f98 <virtio_disk_rw+0xcc>
    80005f40:	00fb8733          	add	a4,s7,a5
    80005f44:	9742                	add	a4,a4,a6
    80005f46:	00070c23          	sb	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    idx[i] = alloc_desc(n);
    80005f4a:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005f4c:	0207c263          	bltz	a5,80005f70 <virtio_disk_rw+0xa4>
  for(int i = 0; i < 3; i++){
    80005f50:	2905                	addiw	s2,s2,1
    80005f52:	0611                	addi	a2,a2,4
    80005f54:	1ca90463          	beq	s2,a0,8000611c <virtio_disk_rw+0x250>
    idx[i] = alloc_desc(n);
    80005f58:	85b2                	mv	a1,a2
    80005f5a:	874e                	mv	a4,s3
  for(int i = 0; i < NUM; i++){
    80005f5c:	87d2                	mv	a5,s4
    if(disk[n].free[i]){
    80005f5e:	00074683          	lbu	a3,0(a4)
    80005f62:	fef9                	bnez	a3,80005f40 <virtio_disk_rw+0x74>
  for(int i = 0; i < NUM; i++){
    80005f64:	2785                	addiw	a5,a5,1
    80005f66:	0705                	addi	a4,a4,1
    80005f68:	fe979be3          	bne	a5,s1,80005f5e <virtio_disk_rw+0x92>
    idx[i] = alloc_desc(n);
    80005f6c:	57fd                	li	a5,-1
    80005f6e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005f70:	01205e63          	blez	s2,80005f8c <virtio_disk_rw+0xc0>
    80005f74:	8d52                	mv	s10,s4
        free_desc(n, idx[j]);
    80005f76:	000b2583          	lw	a1,0(s6)
    80005f7a:	8556                	mv	a0,s5
    80005f7c:	00000097          	auipc	ra,0x0
    80005f80:	ccc080e7          	jalr	-820(ra) # 80005c48 <free_desc>
      for(int j = 0; j < i; j++)
    80005f84:	2d05                	addiw	s10,s10,1
    80005f86:	0b11                	addi	s6,s6,4
    80005f88:	ffa917e3          	bne	s2,s10,80005f76 <virtio_disk_rw+0xaa>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80005f8c:	85e6                	mv	a1,s9
    80005f8e:	854e                	mv	a0,s3
    80005f90:	ffffc097          	auipc	ra,0xffffc
    80005f94:	fa2080e7          	jalr	-94(ra) # 80001f32 <sleep>
  for(int i = 0; i < 3; i++){
    80005f98:	f8040b13          	addi	s6,s0,-128
{
    80005f9c:	865a                	mv	a2,s6
  for(int i = 0; i < 3; i++){
    80005f9e:	8952                	mv	s2,s4
      disk[n].free[i] = 0;
    80005fa0:	6809                	lui	a6,0x2
  for(int i = 0; i < 3; i++){
    80005fa2:	450d                	li	a0,3
    80005fa4:	bf55                	j	80005f58 <virtio_disk_rw+0x8c>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80005fa6:	001a9793          	slli	a5,s5,0x1
    80005faa:	97d6                	add	a5,a5,s5
    80005fac:	07b2                	slli	a5,a5,0xc
    80005fae:	0001c717          	auipc	a4,0x1c
    80005fb2:	05270713          	addi	a4,a4,82 # 80022000 <disk>
    80005fb6:	973e                	add	a4,a4,a5
    80005fb8:	6789                	lui	a5,0x2
    80005fba:	97ba                	add	a5,a5,a4
    80005fbc:	639c                	ld	a5,0(a5)
    80005fbe:	97b6                	add	a5,a5,a3
    80005fc0:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005fc4:	0001c517          	auipc	a0,0x1c
    80005fc8:	03c50513          	addi	a0,a0,60 # 80022000 <disk>
    80005fcc:	001a9793          	slli	a5,s5,0x1
    80005fd0:	01578733          	add	a4,a5,s5
    80005fd4:	0732                	slli	a4,a4,0xc
    80005fd6:	972a                	add	a4,a4,a0
    80005fd8:	6609                	lui	a2,0x2
    80005fda:	9732                	add	a4,a4,a2
    80005fdc:	6310                	ld	a2,0(a4)
    80005fde:	9636                	add	a2,a2,a3
    80005fe0:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80005fe4:	0015e593          	ori	a1,a1,1
    80005fe8:	00b61623          	sh	a1,12(a2)
  disk[n].desc[idx[1]].next = idx[2];
    80005fec:	f8842603          	lw	a2,-120(s0)
    80005ff0:	630c                	ld	a1,0(a4)
    80005ff2:	96ae                	add	a3,a3,a1
    80005ff4:	00c69723          	sh	a2,14(a3) # 100e <_entry-0x7fffeff2>

  disk[n].info[idx[0]].status = 0;
    80005ff8:	97d6                	add	a5,a5,s5
    80005ffa:	07a2                	slli	a5,a5,0x8
    80005ffc:	97a6                	add	a5,a5,s1
    80005ffe:	20078793          	addi	a5,a5,512
    80006002:	0792                	slli	a5,a5,0x4
    80006004:	97aa                	add	a5,a5,a0
    80006006:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    8000600a:	00461693          	slli	a3,a2,0x4
    8000600e:	00073803          	ld	a6,0(a4)
    80006012:	9836                	add	a6,a6,a3
    80006014:	20348613          	addi	a2,s1,515
    80006018:	001a9593          	slli	a1,s5,0x1
    8000601c:	95d6                	add	a1,a1,s5
    8000601e:	05a2                	slli	a1,a1,0x8
    80006020:	962e                	add	a2,a2,a1
    80006022:	0612                	slli	a2,a2,0x4
    80006024:	962a                	add	a2,a2,a0
    80006026:	00c83023          	sd	a2,0(a6) # 2000 <_entry-0x7fffe000>
  disk[n].desc[idx[2]].len = 1;
    8000602a:	630c                	ld	a1,0(a4)
    8000602c:	95b6                	add	a1,a1,a3
    8000602e:	4605                	li	a2,1
    80006030:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006032:	630c                	ld	a1,0(a4)
    80006034:	95b6                	add	a1,a1,a3
    80006036:	4509                	li	a0,2
    80006038:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    8000603c:	630c                	ld	a1,0(a4)
    8000603e:	96ae                	add	a3,a3,a1
    80006040:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006044:	00cc2223          	sw	a2,4(s8) # fffffffffffff004 <end+0xffffffff7ffd6fa8>
  disk[n].info[idx[0]].b = b;
    80006048:	0387b423          	sd	s8,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    8000604c:	6714                	ld	a3,8(a4)
    8000604e:	0026d783          	lhu	a5,2(a3)
    80006052:	8b9d                	andi	a5,a5,7
    80006054:	0789                	addi	a5,a5,2
    80006056:	0786                	slli	a5,a5,0x1
    80006058:	97b6                	add	a5,a5,a3
    8000605a:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    8000605e:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006062:	6718                	ld	a4,8(a4)
    80006064:	00275783          	lhu	a5,2(a4)
    80006068:	2785                	addiw	a5,a5,1
    8000606a:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000606e:	001a879b          	addiw	a5,s5,1
    80006072:	00c7979b          	slliw	a5,a5,0xc
    80006076:	10000737          	lui	a4,0x10000
    8000607a:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    8000607e:	97ba                	add	a5,a5,a4
    80006080:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006084:	004c2783          	lw	a5,4(s8)
    80006088:	00c79d63          	bne	a5,a2,800060a2 <virtio_disk_rw+0x1d6>
    8000608c:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    8000608e:	85e6                	mv	a1,s9
    80006090:	8562                	mv	a0,s8
    80006092:	ffffc097          	auipc	ra,0xffffc
    80006096:	ea0080e7          	jalr	-352(ra) # 80001f32 <sleep>
  while(b->disk == 1) {
    8000609a:	004c2783          	lw	a5,4(s8)
    8000609e:	fe9788e3          	beq	a5,s1,8000608e <virtio_disk_rw+0x1c2>
  }

  disk[n].info[idx[0]].b = 0;
    800060a2:	f8042483          	lw	s1,-128(s0)
    800060a6:	001a9793          	slli	a5,s5,0x1
    800060aa:	97d6                	add	a5,a5,s5
    800060ac:	07a2                	slli	a5,a5,0x8
    800060ae:	97a6                	add	a5,a5,s1
    800060b0:	20078793          	addi	a5,a5,512
    800060b4:	0792                	slli	a5,a5,0x4
    800060b6:	0001c717          	auipc	a4,0x1c
    800060ba:	f4a70713          	addi	a4,a4,-182 # 80022000 <disk>
    800060be:	97ba                	add	a5,a5,a4
    800060c0:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800060c4:	001a9793          	slli	a5,s5,0x1
    800060c8:	97d6                	add	a5,a5,s5
    800060ca:	07b2                	slli	a5,a5,0xc
    800060cc:	97ba                	add	a5,a5,a4
    800060ce:	6909                	lui	s2,0x2
    800060d0:	993e                	add	s2,s2,a5
    800060d2:	a019                	j	800060d8 <virtio_disk_rw+0x20c>
      i = disk[n].desc[i].next;
    800060d4:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    800060d8:	85a6                	mv	a1,s1
    800060da:	8556                	mv	a0,s5
    800060dc:	00000097          	auipc	ra,0x0
    800060e0:	b6c080e7          	jalr	-1172(ra) # 80005c48 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800060e4:	0492                	slli	s1,s1,0x4
    800060e6:	00093783          	ld	a5,0(s2) # 2000 <_entry-0x7fffe000>
    800060ea:	94be                	add	s1,s1,a5
    800060ec:	00c4d783          	lhu	a5,12(s1)
    800060f0:	8b85                	andi	a5,a5,1
    800060f2:	f3ed                	bnez	a5,800060d4 <virtio_disk_rw+0x208>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    800060f4:	8566                	mv	a0,s9
    800060f6:	ffffb097          	auipc	ra,0xffffb
    800060fa:	92e080e7          	jalr	-1746(ra) # 80000a24 <release>
}
    800060fe:	60ea                	ld	ra,152(sp)
    80006100:	644a                	ld	s0,144(sp)
    80006102:	64aa                	ld	s1,136(sp)
    80006104:	690a                	ld	s2,128(sp)
    80006106:	79e6                	ld	s3,120(sp)
    80006108:	7a46                	ld	s4,112(sp)
    8000610a:	7aa6                	ld	s5,104(sp)
    8000610c:	7b06                	ld	s6,96(sp)
    8000610e:	6be6                	ld	s7,88(sp)
    80006110:	6c46                	ld	s8,80(sp)
    80006112:	6ca6                	ld	s9,72(sp)
    80006114:	6d06                	ld	s10,64(sp)
    80006116:	7de2                	ld	s11,56(sp)
    80006118:	610d                	addi	sp,sp,160
    8000611a:	8082                	ret
  if(write)
    8000611c:	01b037b3          	snez	a5,s11
    80006120:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006124:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006128:	f6843783          	ld	a5,-152(s0)
    8000612c:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006130:	f8042483          	lw	s1,-128(s0)
    80006134:	00449993          	slli	s3,s1,0x4
    80006138:	001a9793          	slli	a5,s5,0x1
    8000613c:	97d6                	add	a5,a5,s5
    8000613e:	07b2                	slli	a5,a5,0xc
    80006140:	0001c917          	auipc	s2,0x1c
    80006144:	ec090913          	addi	s2,s2,-320 # 80022000 <disk>
    80006148:	97ca                	add	a5,a5,s2
    8000614a:	6909                	lui	s2,0x2
    8000614c:	993e                	add	s2,s2,a5
    8000614e:	00093a03          	ld	s4,0(s2) # 2000 <_entry-0x7fffe000>
    80006152:	9a4e                	add	s4,s4,s3
    80006154:	f7040513          	addi	a0,s0,-144
    80006158:	ffffb097          	auipc	ra,0xffffb
    8000615c:	d58080e7          	jalr	-680(ra) # 80000eb0 <kvmpa>
    80006160:	00aa3023          	sd	a0,0(s4)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006164:	00093783          	ld	a5,0(s2)
    80006168:	97ce                	add	a5,a5,s3
    8000616a:	4741                	li	a4,16
    8000616c:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000616e:	00093783          	ld	a5,0(s2)
    80006172:	97ce                	add	a5,a5,s3
    80006174:	4705                	li	a4,1
    80006176:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    8000617a:	f8442683          	lw	a3,-124(s0)
    8000617e:	00093783          	ld	a5,0(s2)
    80006182:	99be                	add	s3,s3,a5
    80006184:	00d99723          	sh	a3,14(s3)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006188:	0692                	slli	a3,a3,0x4
    8000618a:	00093783          	ld	a5,0(s2)
    8000618e:	97b6                	add	a5,a5,a3
    80006190:	060c0713          	addi	a4,s8,96
    80006194:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006196:	00093783          	ld	a5,0(s2)
    8000619a:	97b6                	add	a5,a5,a3
    8000619c:	40000713          	li	a4,1024
    800061a0:	c798                	sw	a4,8(a5)
  if(write)
    800061a2:	e00d92e3          	bnez	s11,80005fa6 <virtio_disk_rw+0xda>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800061a6:	001a9793          	slli	a5,s5,0x1
    800061aa:	97d6                	add	a5,a5,s5
    800061ac:	07b2                	slli	a5,a5,0xc
    800061ae:	0001c717          	auipc	a4,0x1c
    800061b2:	e5270713          	addi	a4,a4,-430 # 80022000 <disk>
    800061b6:	973e                	add	a4,a4,a5
    800061b8:	6789                	lui	a5,0x2
    800061ba:	97ba                	add	a5,a5,a4
    800061bc:	639c                	ld	a5,0(a5)
    800061be:	97b6                	add	a5,a5,a3
    800061c0:	4709                	li	a4,2
    800061c2:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    800061c6:	bbfd                	j	80005fc4 <virtio_disk_rw+0xf8>

00000000800061c8 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    800061c8:	7139                	addi	sp,sp,-64
    800061ca:	fc06                	sd	ra,56(sp)
    800061cc:	f822                	sd	s0,48(sp)
    800061ce:	f426                	sd	s1,40(sp)
    800061d0:	f04a                	sd	s2,32(sp)
    800061d2:	ec4e                	sd	s3,24(sp)
    800061d4:	e852                	sd	s4,16(sp)
    800061d6:	e456                	sd	s5,8(sp)
    800061d8:	0080                	addi	s0,sp,64
    800061da:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    800061dc:	00151913          	slli	s2,a0,0x1
    800061e0:	00a90a33          	add	s4,s2,a0
    800061e4:	0a32                	slli	s4,s4,0xc
    800061e6:	6989                	lui	s3,0x2
    800061e8:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    800061ec:	9a3e                	add	s4,s4,a5
    800061ee:	0001ca97          	auipc	s5,0x1c
    800061f2:	e12a8a93          	addi	s5,s5,-494 # 80022000 <disk>
    800061f6:	9a56                	add	s4,s4,s5
    800061f8:	8552                	mv	a0,s4
    800061fa:	ffffa097          	auipc	ra,0xffffa
    800061fe:	7c2080e7          	jalr	1986(ra) # 800009bc <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006202:	9926                	add	s2,s2,s1
    80006204:	0932                	slli	s2,s2,0xc
    80006206:	9956                	add	s2,s2,s5
    80006208:	99ca                	add	s3,s3,s2
    8000620a:	0209d783          	lhu	a5,32(s3)
    8000620e:	0109b703          	ld	a4,16(s3)
    80006212:	00275683          	lhu	a3,2(a4)
    80006216:	8ebd                	xor	a3,a3,a5
    80006218:	8a9d                	andi	a3,a3,7
    8000621a:	c2a5                	beqz	a3,8000627a <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    8000621c:	8956                	mv	s2,s5
    8000621e:	00149693          	slli	a3,s1,0x1
    80006222:	96a6                	add	a3,a3,s1
    80006224:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006228:	06b2                	slli	a3,a3,0xc
    8000622a:	96d6                	add	a3,a3,s5
    8000622c:	6489                	lui	s1,0x2
    8000622e:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006230:	078e                	slli	a5,a5,0x3
    80006232:	97ba                	add	a5,a5,a4
    80006234:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006236:	00f98733          	add	a4,s3,a5
    8000623a:	20070713          	addi	a4,a4,512
    8000623e:	0712                	slli	a4,a4,0x4
    80006240:	974a                	add	a4,a4,s2
    80006242:	03074703          	lbu	a4,48(a4)
    80006246:	eb21                	bnez	a4,80006296 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006248:	97ce                	add	a5,a5,s3
    8000624a:	20078793          	addi	a5,a5,512
    8000624e:	0792                	slli	a5,a5,0x4
    80006250:	97ca                	add	a5,a5,s2
    80006252:	7798                	ld	a4,40(a5)
    80006254:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006258:	7788                	ld	a0,40(a5)
    8000625a:	ffffc097          	auipc	ra,0xffffc
    8000625e:	e58080e7          	jalr	-424(ra) # 800020b2 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006262:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006266:	2785                	addiw	a5,a5,1
    80006268:	8b9d                	andi	a5,a5,7
    8000626a:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    8000626e:	6898                	ld	a4,16(s1)
    80006270:	00275683          	lhu	a3,2(a4)
    80006274:	8a9d                	andi	a3,a3,7
    80006276:	faf69de3          	bne	a3,a5,80006230 <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    8000627a:	8552                	mv	a0,s4
    8000627c:	ffffa097          	auipc	ra,0xffffa
    80006280:	7a8080e7          	jalr	1960(ra) # 80000a24 <release>
}
    80006284:	70e2                	ld	ra,56(sp)
    80006286:	7442                	ld	s0,48(sp)
    80006288:	74a2                	ld	s1,40(sp)
    8000628a:	7902                	ld	s2,32(sp)
    8000628c:	69e2                	ld	s3,24(sp)
    8000628e:	6a42                	ld	s4,16(sp)
    80006290:	6aa2                	ld	s5,8(sp)
    80006292:	6121                	addi	sp,sp,64
    80006294:	8082                	ret
      panic("virtio_disk_intr status");
    80006296:	00001517          	auipc	a0,0x1
    8000629a:	5f250513          	addi	a0,a0,1522 # 80007888 <userret+0x7f8>
    8000629e:	ffffa097          	auipc	ra,0xffffa
    800062a2:	2aa080e7          	jalr	682(ra) # 80000548 <panic>

00000000800062a6 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    800062a6:	1141                	addi	sp,sp,-16
    800062a8:	e422                	sd	s0,8(sp)
    800062aa:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    800062ac:	41f5d79b          	sraiw	a5,a1,0x1f
    800062b0:	01d7d79b          	srliw	a5,a5,0x1d
    800062b4:	9dbd                	addw	a1,a1,a5
    800062b6:	0075f713          	andi	a4,a1,7
    800062ba:	9f1d                	subw	a4,a4,a5
    800062bc:	4785                	li	a5,1
    800062be:	00e797bb          	sllw	a5,a5,a4
    800062c2:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    800062c6:	4035d59b          	sraiw	a1,a1,0x3
    800062ca:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    800062cc:	0005c503          	lbu	a0,0(a1)
    800062d0:	8d7d                	and	a0,a0,a5
    800062d2:	8d1d                	sub	a0,a0,a5
}
    800062d4:	00153513          	seqz	a0,a0
    800062d8:	6422                	ld	s0,8(sp)
    800062da:	0141                	addi	sp,sp,16
    800062dc:	8082                	ret

00000000800062de <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    800062de:	1141                	addi	sp,sp,-16
    800062e0:	e422                	sd	s0,8(sp)
    800062e2:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800062e4:	41f5d79b          	sraiw	a5,a1,0x1f
    800062e8:	01d7d79b          	srliw	a5,a5,0x1d
    800062ec:	9dbd                	addw	a1,a1,a5
    800062ee:	4035d71b          	sraiw	a4,a1,0x3
    800062f2:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800062f4:	899d                	andi	a1,a1,7
    800062f6:	9d9d                	subw	a1,a1,a5
    800062f8:	4785                	li	a5,1
    800062fa:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    800062fe:	00054783          	lbu	a5,0(a0)
    80006302:	8ddd                	or	a1,a1,a5
    80006304:	00b50023          	sb	a1,0(a0)
}
    80006308:	6422                	ld	s0,8(sp)
    8000630a:	0141                	addi	sp,sp,16
    8000630c:	8082                	ret

000000008000630e <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    8000630e:	1141                	addi	sp,sp,-16
    80006310:	e422                	sd	s0,8(sp)
    80006312:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006314:	41f5d79b          	sraiw	a5,a1,0x1f
    80006318:	01d7d79b          	srliw	a5,a5,0x1d
    8000631c:	9dbd                	addw	a1,a1,a5
    8000631e:	4035d71b          	sraiw	a4,a1,0x3
    80006322:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006324:	899d                	andi	a1,a1,7
    80006326:	9d9d                	subw	a1,a1,a5
    80006328:	4785                	li	a5,1
    8000632a:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    8000632e:	fff5c593          	not	a1,a1
    80006332:	00054783          	lbu	a5,0(a0)
    80006336:	8dfd                	and	a1,a1,a5
    80006338:	00b50023          	sb	a1,0(a0)
}
    8000633c:	6422                	ld	s0,8(sp)
    8000633e:	0141                	addi	sp,sp,16
    80006340:	8082                	ret

0000000080006342 <bit_toggle>:

// toggle bit at position index in array
void bit_toggle(char *array,int index){
    80006342:	1141                	addi	sp,sp,-16
    80006344:	e422                	sd	s0,8(sp)
    80006346:	0800                	addi	s0,sp,16
  index/=2;
    80006348:	01f5d79b          	srliw	a5,a1,0x1f
    8000634c:	9dbd                	addw	a1,a1,a5
    8000634e:	4015d79b          	sraiw	a5,a1,0x1
  char b = array[index/8];
    80006352:	41f5d59b          	sraiw	a1,a1,0x1f
    80006356:	01d5d59b          	srliw	a1,a1,0x1d
    8000635a:	9fad                	addw	a5,a5,a1
    8000635c:	4037d71b          	sraiw	a4,a5,0x3
    80006360:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006362:	8b9d                	andi	a5,a5,7
    80006364:	40b785bb          	subw	a1,a5,a1
    80006368:	4785                	li	a5,1
    8000636a:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b ^ m);
    8000636e:	00054783          	lbu	a5,0(a0)
    80006372:	8dbd                	xor	a1,a1,a5
    80006374:	00b50023          	sb	a1,0(a0)
}
    80006378:	6422                	ld	s0,8(sp)
    8000637a:	0141                	addi	sp,sp,16
    8000637c:	8082                	ret

000000008000637e <bit_get>:

// return 1 if the bit at position index in array is 1
// which indicates one is free , the other is allocated
int bit_get(char *array,int index){
    8000637e:	1141                	addi	sp,sp,-16
    80006380:	e422                	sd	s0,8(sp)
    80006382:	0800                	addi	s0,sp,16
  index/=2;
    80006384:	01f5d79b          	srliw	a5,a1,0x1f
    80006388:	9dbd                	addw	a1,a1,a5
    8000638a:	4015d79b          	sraiw	a5,a1,0x1
  char b = array[index/8];
  char m = (1 << (index % 8));
    8000638e:	41f5d59b          	sraiw	a1,a1,0x1f
    80006392:	01d5d59b          	srliw	a1,a1,0x1d
    80006396:	9fad                	addw	a5,a5,a1
    80006398:	0077f713          	andi	a4,a5,7
    8000639c:	9f0d                	subw	a4,a4,a1
    8000639e:	4585                	li	a1,1
    800063a0:	00e595bb          	sllw	a1,a1,a4
    800063a4:	0ff5f593          	andi	a1,a1,255
  char b = array[index/8];
    800063a8:	4037d79b          	sraiw	a5,a5,0x3
    800063ac:	97aa                	add	a5,a5,a0
  return (b & m) == m;
    800063ae:	0007c503          	lbu	a0,0(a5)
    800063b2:	8d6d                	and	a0,a0,a1
    800063b4:	8d0d                	sub	a0,a0,a1
}
    800063b6:	00153513          	seqz	a0,a0
    800063ba:	6422                	ld	s0,8(sp)
    800063bc:	0141                	addi	sp,sp,16
    800063be:	8082                	ret

00000000800063c0 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    800063c0:	715d                	addi	sp,sp,-80
    800063c2:	e486                	sd	ra,72(sp)
    800063c4:	e0a2                	sd	s0,64(sp)
    800063c6:	fc26                	sd	s1,56(sp)
    800063c8:	f84a                	sd	s2,48(sp)
    800063ca:	f44e                	sd	s3,40(sp)
    800063cc:	f052                	sd	s4,32(sp)
    800063ce:	ec56                	sd	s5,24(sp)
    800063d0:	e85a                	sd	s6,16(sp)
    800063d2:	e45e                	sd	s7,8(sp)
    800063d4:	0880                	addi	s0,sp,80
    800063d6:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    800063d8:	08b05b63          	blez	a1,8000646e <bd_print_vector+0xae>
    800063dc:	89aa                	mv	s3,a0
    800063de:	4481                	li	s1,0
  lb = 0;
    800063e0:	4a81                	li	s5,0
  last = 1;
    800063e2:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    800063e4:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    800063e6:	00001b97          	auipc	s7,0x1
    800063ea:	4bab8b93          	addi	s7,s7,1210 # 800078a0 <userret+0x810>
    800063ee:	a821                	j	80006406 <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    800063f0:	85a6                	mv	a1,s1
    800063f2:	854e                	mv	a0,s3
    800063f4:	00000097          	auipc	ra,0x0
    800063f8:	eb2080e7          	jalr	-334(ra) # 800062a6 <bit_isset>
    800063fc:	892a                	mv	s2,a0
    800063fe:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006400:	2485                	addiw	s1,s1,1
    80006402:	029a0463          	beq	s4,s1,8000642a <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006406:	85a6                	mv	a1,s1
    80006408:	854e                	mv	a0,s3
    8000640a:	00000097          	auipc	ra,0x0
    8000640e:	e9c080e7          	jalr	-356(ra) # 800062a6 <bit_isset>
    80006412:	ff2507e3          	beq	a0,s2,80006400 <bd_print_vector+0x40>
    if(last == 1)
    80006416:	fd691de3          	bne	s2,s6,800063f0 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    8000641a:	8626                	mv	a2,s1
    8000641c:	85d6                	mv	a1,s5
    8000641e:	855e                	mv	a0,s7
    80006420:	ffffa097          	auipc	ra,0xffffa
    80006424:	172080e7          	jalr	370(ra) # 80000592 <printf>
    80006428:	b7e1                	j	800063f0 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    8000642a:	000a8563          	beqz	s5,80006434 <bd_print_vector+0x74>
    8000642e:	4785                	li	a5,1
    80006430:	00f91c63          	bne	s2,a5,80006448 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006434:	8652                	mv	a2,s4
    80006436:	85d6                	mv	a1,s5
    80006438:	00001517          	auipc	a0,0x1
    8000643c:	46850513          	addi	a0,a0,1128 # 800078a0 <userret+0x810>
    80006440:	ffffa097          	auipc	ra,0xffffa
    80006444:	152080e7          	jalr	338(ra) # 80000592 <printf>
  }
  printf("\n");
    80006448:	00001517          	auipc	a0,0x1
    8000644c:	d5850513          	addi	a0,a0,-680 # 800071a0 <userret+0x110>
    80006450:	ffffa097          	auipc	ra,0xffffa
    80006454:	142080e7          	jalr	322(ra) # 80000592 <printf>
}
    80006458:	60a6                	ld	ra,72(sp)
    8000645a:	6406                	ld	s0,64(sp)
    8000645c:	74e2                	ld	s1,56(sp)
    8000645e:	7942                	ld	s2,48(sp)
    80006460:	79a2                	ld	s3,40(sp)
    80006462:	7a02                	ld	s4,32(sp)
    80006464:	6ae2                	ld	s5,24(sp)
    80006466:	6b42                	ld	s6,16(sp)
    80006468:	6ba2                	ld	s7,8(sp)
    8000646a:	6161                	addi	sp,sp,80
    8000646c:	8082                	ret
  lb = 0;
    8000646e:	4a81                	li	s5,0
    80006470:	b7d1                	j	80006434 <bd_print_vector+0x74>

0000000080006472 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    80006472:	00022697          	auipc	a3,0x22
    80006476:	be66a683          	lw	a3,-1050(a3) # 80028058 <nsizes>
    8000647a:	10d05063          	blez	a3,8000657a <bd_print+0x108>
bd_print() {
    8000647e:	711d                	addi	sp,sp,-96
    80006480:	ec86                	sd	ra,88(sp)
    80006482:	e8a2                	sd	s0,80(sp)
    80006484:	e4a6                	sd	s1,72(sp)
    80006486:	e0ca                	sd	s2,64(sp)
    80006488:	fc4e                	sd	s3,56(sp)
    8000648a:	f852                	sd	s4,48(sp)
    8000648c:	f456                	sd	s5,40(sp)
    8000648e:	f05a                	sd	s6,32(sp)
    80006490:	ec5e                	sd	s7,24(sp)
    80006492:	e862                	sd	s8,16(sp)
    80006494:	e466                	sd	s9,8(sp)
    80006496:	e06a                	sd	s10,0(sp)
    80006498:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    8000649a:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    8000649c:	4a85                	li	s5,1
    8000649e:	4c41                	li	s8,16
    800064a0:	00001b97          	auipc	s7,0x1
    800064a4:	410b8b93          	addi	s7,s7,1040 # 800078b0 <userret+0x820>
    lst_print(&bd_sizes[k].free);
    800064a8:	00022a17          	auipc	s4,0x22
    800064ac:	ba8a0a13          	addi	s4,s4,-1112 # 80028050 <bd_sizes>
    printf("  alloc:");
    800064b0:	00001b17          	auipc	s6,0x1
    800064b4:	428b0b13          	addi	s6,s6,1064 # 800078d8 <userret+0x848>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800064b8:	00022997          	auipc	s3,0x22
    800064bc:	ba098993          	addi	s3,s3,-1120 # 80028058 <nsizes>
    if(k > 0) {
      printf("  split:");
    800064c0:	00001c97          	auipc	s9,0x1
    800064c4:	428c8c93          	addi	s9,s9,1064 # 800078e8 <userret+0x858>
    800064c8:	a801                	j	800064d8 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    800064ca:	0009a683          	lw	a3,0(s3)
    800064ce:	0485                	addi	s1,s1,1
    800064d0:	0004879b          	sext.w	a5,s1
    800064d4:	08d7d563          	bge	a5,a3,8000655e <bd_print+0xec>
    800064d8:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800064dc:	36fd                	addiw	a3,a3,-1
    800064de:	9e85                	subw	a3,a3,s1
    800064e0:	00da96bb          	sllw	a3,s5,a3
    800064e4:	009c1633          	sll	a2,s8,s1
    800064e8:	85ca                	mv	a1,s2
    800064ea:	855e                	mv	a0,s7
    800064ec:	ffffa097          	auipc	ra,0xffffa
    800064f0:	0a6080e7          	jalr	166(ra) # 80000592 <printf>
    lst_print(&bd_sizes[k].free);
    800064f4:	00549d13          	slli	s10,s1,0x5
    800064f8:	000a3503          	ld	a0,0(s4)
    800064fc:	956a                	add	a0,a0,s10
    800064fe:	00001097          	auipc	ra,0x1
    80006502:	a84080e7          	jalr	-1404(ra) # 80006f82 <lst_print>
    printf("  alloc:");
    80006506:	855a                	mv	a0,s6
    80006508:	ffffa097          	auipc	ra,0xffffa
    8000650c:	08a080e7          	jalr	138(ra) # 80000592 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006510:	0009a583          	lw	a1,0(s3)
    80006514:	35fd                	addiw	a1,a1,-1
    80006516:	412585bb          	subw	a1,a1,s2
    8000651a:	000a3783          	ld	a5,0(s4)
    8000651e:	97ea                	add	a5,a5,s10
    80006520:	00ba95bb          	sllw	a1,s5,a1
    80006524:	6b88                	ld	a0,16(a5)
    80006526:	00000097          	auipc	ra,0x0
    8000652a:	e9a080e7          	jalr	-358(ra) # 800063c0 <bd_print_vector>
    if(k > 0) {
    8000652e:	f9205ee3          	blez	s2,800064ca <bd_print+0x58>
      printf("  split:");
    80006532:	8566                	mv	a0,s9
    80006534:	ffffa097          	auipc	ra,0xffffa
    80006538:	05e080e7          	jalr	94(ra) # 80000592 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    8000653c:	0009a583          	lw	a1,0(s3)
    80006540:	35fd                	addiw	a1,a1,-1
    80006542:	412585bb          	subw	a1,a1,s2
    80006546:	000a3783          	ld	a5,0(s4)
    8000654a:	9d3e                	add	s10,s10,a5
    8000654c:	00ba95bb          	sllw	a1,s5,a1
    80006550:	018d3503          	ld	a0,24(s10)
    80006554:	00000097          	auipc	ra,0x0
    80006558:	e6c080e7          	jalr	-404(ra) # 800063c0 <bd_print_vector>
    8000655c:	b7bd                	j	800064ca <bd_print+0x58>
    }
  }
}
    8000655e:	60e6                	ld	ra,88(sp)
    80006560:	6446                	ld	s0,80(sp)
    80006562:	64a6                	ld	s1,72(sp)
    80006564:	6906                	ld	s2,64(sp)
    80006566:	79e2                	ld	s3,56(sp)
    80006568:	7a42                	ld	s4,48(sp)
    8000656a:	7aa2                	ld	s5,40(sp)
    8000656c:	7b02                	ld	s6,32(sp)
    8000656e:	6be2                	ld	s7,24(sp)
    80006570:	6c42                	ld	s8,16(sp)
    80006572:	6ca2                	ld	s9,8(sp)
    80006574:	6d02                	ld	s10,0(sp)
    80006576:	6125                	addi	sp,sp,96
    80006578:	8082                	ret
    8000657a:	8082                	ret

000000008000657c <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    8000657c:	1141                	addi	sp,sp,-16
    8000657e:	e422                	sd	s0,8(sp)
    80006580:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006582:	47c1                	li	a5,16
    80006584:	00a7fb63          	bgeu	a5,a0,8000659a <firstk+0x1e>
    80006588:	872a                	mv	a4,a0
  int k = 0;
    8000658a:	4501                	li	a0,0
    k++;
    8000658c:	2505                	addiw	a0,a0,1
    size *= 2;
    8000658e:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006590:	fee7eee3          	bltu	a5,a4,8000658c <firstk+0x10>
  }
  return k;
}
    80006594:	6422                	ld	s0,8(sp)
    80006596:	0141                	addi	sp,sp,16
    80006598:	8082                	ret
  int k = 0;
    8000659a:	4501                	li	a0,0
    8000659c:	bfe5                	j	80006594 <firstk+0x18>

000000008000659e <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    8000659e:	1141                	addi	sp,sp,-16
    800065a0:	e422                	sd	s0,8(sp)
    800065a2:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    800065a4:	00022797          	auipc	a5,0x22
    800065a8:	aa47b783          	ld	a5,-1372(a5) # 80028048 <bd_base>
    800065ac:	9d9d                	subw	a1,a1,a5
    800065ae:	47c1                	li	a5,16
    800065b0:	00a797b3          	sll	a5,a5,a0
    800065b4:	02f5c5b3          	div	a1,a1,a5
}
    800065b8:	0005851b          	sext.w	a0,a1
    800065bc:	6422                	ld	s0,8(sp)
    800065be:	0141                	addi	sp,sp,16
    800065c0:	8082                	ret

00000000800065c2 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    800065c2:	1141                	addi	sp,sp,-16
    800065c4:	e422                	sd	s0,8(sp)
    800065c6:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    800065c8:	47c1                	li	a5,16
    800065ca:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    800065ce:	02b787bb          	mulw	a5,a5,a1
}
    800065d2:	00022517          	auipc	a0,0x22
    800065d6:	a7653503          	ld	a0,-1418(a0) # 80028048 <bd_base>
    800065da:	953e                	add	a0,a0,a5
    800065dc:	6422                	ld	s0,8(sp)
    800065de:	0141                	addi	sp,sp,16
    800065e0:	8082                	ret

00000000800065e2 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    800065e2:	7159                	addi	sp,sp,-112
    800065e4:	f486                	sd	ra,104(sp)
    800065e6:	f0a2                	sd	s0,96(sp)
    800065e8:	eca6                	sd	s1,88(sp)
    800065ea:	e8ca                	sd	s2,80(sp)
    800065ec:	e4ce                	sd	s3,72(sp)
    800065ee:	e0d2                	sd	s4,64(sp)
    800065f0:	fc56                	sd	s5,56(sp)
    800065f2:	f85a                	sd	s6,48(sp)
    800065f4:	f45e                	sd	s7,40(sp)
    800065f6:	f062                	sd	s8,32(sp)
    800065f8:	ec66                	sd	s9,24(sp)
    800065fa:	e86a                	sd	s10,16(sp)
    800065fc:	e46e                	sd	s11,8(sp)
    800065fe:	1880                	addi	s0,sp,112
    80006600:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006602:	00022517          	auipc	a0,0x22
    80006606:	9fe50513          	addi	a0,a0,-1538 # 80028000 <lock>
    8000660a:	ffffa097          	auipc	ra,0xffffa
    8000660e:	3b2080e7          	jalr	946(ra) # 800009bc <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006612:	8526                	mv	a0,s1
    80006614:	00000097          	auipc	ra,0x0
    80006618:	f68080e7          	jalr	-152(ra) # 8000657c <firstk>
  for (k = fk; k < nsizes; k++) {
    8000661c:	00022797          	auipc	a5,0x22
    80006620:	a3c7a783          	lw	a5,-1476(a5) # 80028058 <nsizes>
    80006624:	02f55d63          	bge	a0,a5,8000665e <bd_malloc+0x7c>
    80006628:	8c2a                	mv	s8,a0
    8000662a:	00551913          	slli	s2,a0,0x5
    8000662e:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006630:	00022997          	auipc	s3,0x22
    80006634:	a2098993          	addi	s3,s3,-1504 # 80028050 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006638:	00022a17          	auipc	s4,0x22
    8000663c:	a20a0a13          	addi	s4,s4,-1504 # 80028058 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006640:	0009b503          	ld	a0,0(s3)
    80006644:	954a                	add	a0,a0,s2
    80006646:	00001097          	auipc	ra,0x1
    8000664a:	8c2080e7          	jalr	-1854(ra) # 80006f08 <lst_empty>
    8000664e:	c115                	beqz	a0,80006672 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006650:	2485                	addiw	s1,s1,1
    80006652:	02090913          	addi	s2,s2,32
    80006656:	000a2783          	lw	a5,0(s4)
    8000665a:	fef4c3e3          	blt	s1,a5,80006640 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    8000665e:	00022517          	auipc	a0,0x22
    80006662:	9a250513          	addi	a0,a0,-1630 # 80028000 <lock>
    80006666:	ffffa097          	auipc	ra,0xffffa
    8000666a:	3be080e7          	jalr	958(ra) # 80000a24 <release>
    return 0;
    8000666e:	4b01                	li	s6,0
    80006670:	a0e1                	j	80006738 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80006672:	00022797          	auipc	a5,0x22
    80006676:	9e67a783          	lw	a5,-1562(a5) # 80028058 <nsizes>
    8000667a:	fef4d2e3          	bge	s1,a5,8000665e <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    8000667e:	00549993          	slli	s3,s1,0x5
    80006682:	00022917          	auipc	s2,0x22
    80006686:	9ce90913          	addi	s2,s2,-1586 # 80028050 <bd_sizes>
    8000668a:	00093503          	ld	a0,0(s2)
    8000668e:	954e                	add	a0,a0,s3
    80006690:	00001097          	auipc	ra,0x1
    80006694:	8a4080e7          	jalr	-1884(ra) # 80006f34 <lst_pop>
    80006698:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    8000669a:	00022597          	auipc	a1,0x22
    8000669e:	9ae5b583          	ld	a1,-1618(a1) # 80028048 <bd_base>
    800066a2:	40b505bb          	subw	a1,a0,a1
    800066a6:	47c1                	li	a5,16
    800066a8:	009797b3          	sll	a5,a5,s1
    800066ac:	02f5c5b3          	div	a1,a1,a5
  // bit_set(bd_sizes[k].alloc, blk_index(k, p));
  bit_toggle(bd_sizes[k].alloc, blk_index(k, p));
    800066b0:	00093783          	ld	a5,0(s2)
    800066b4:	97ce                	add	a5,a5,s3
    800066b6:	2581                	sext.w	a1,a1
    800066b8:	6b88                	ld	a0,16(a5)
    800066ba:	00000097          	auipc	ra,0x0
    800066be:	c88080e7          	jalr	-888(ra) # 80006342 <bit_toggle>
  for(; k > fk; k--) {
    800066c2:	069c5363          	bge	s8,s1,80006728 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800066c6:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800066c8:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    800066ca:	00022d17          	auipc	s10,0x22
    800066ce:	97ed0d13          	addi	s10,s10,-1666 # 80028048 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800066d2:	85a6                	mv	a1,s1
    800066d4:	34fd                	addiw	s1,s1,-1
    800066d6:	009b9ab3          	sll	s5,s7,s1
    800066da:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800066de:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
  int n = p - (char *) bd_base;
    800066e2:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    800066e6:	412b093b          	subw	s2,s6,s2
    800066ea:	00bb95b3          	sll	a1,s7,a1
    800066ee:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800066f2:	013a07b3          	add	a5,s4,s3
    800066f6:	2581                	sext.w	a1,a1
    800066f8:	6f88                	ld	a0,24(a5)
    800066fa:	00000097          	auipc	ra,0x0
    800066fe:	be4080e7          	jalr	-1052(ra) # 800062de <bit_set>
    // bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    bit_toggle(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006702:	1981                	addi	s3,s3,-32
    80006704:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006706:	035945b3          	div	a1,s2,s5
    bit_toggle(bd_sizes[k-1].alloc, blk_index(k-1, p));
    8000670a:	2581                	sext.w	a1,a1
    8000670c:	010a3503          	ld	a0,16(s4)
    80006710:	00000097          	auipc	ra,0x0
    80006714:	c32080e7          	jalr	-974(ra) # 80006342 <bit_toggle>
    lst_push(&bd_sizes[k-1].free, q);
    80006718:	85e6                	mv	a1,s9
    8000671a:	8552                	mv	a0,s4
    8000671c:	00001097          	auipc	ra,0x1
    80006720:	84e080e7          	jalr	-1970(ra) # 80006f6a <lst_push>
  for(; k > fk; k--) {
    80006724:	fb8497e3          	bne	s1,s8,800066d2 <bd_malloc+0xf0>
  }
  release(&lock);
    80006728:	00022517          	auipc	a0,0x22
    8000672c:	8d850513          	addi	a0,a0,-1832 # 80028000 <lock>
    80006730:	ffffa097          	auipc	ra,0xffffa
    80006734:	2f4080e7          	jalr	756(ra) # 80000a24 <release>

  return p;
}
    80006738:	855a                	mv	a0,s6
    8000673a:	70a6                	ld	ra,104(sp)
    8000673c:	7406                	ld	s0,96(sp)
    8000673e:	64e6                	ld	s1,88(sp)
    80006740:	6946                	ld	s2,80(sp)
    80006742:	69a6                	ld	s3,72(sp)
    80006744:	6a06                	ld	s4,64(sp)
    80006746:	7ae2                	ld	s5,56(sp)
    80006748:	7b42                	ld	s6,48(sp)
    8000674a:	7ba2                	ld	s7,40(sp)
    8000674c:	7c02                	ld	s8,32(sp)
    8000674e:	6ce2                	ld	s9,24(sp)
    80006750:	6d42                	ld	s10,16(sp)
    80006752:	6da2                	ld	s11,8(sp)
    80006754:	6165                	addi	sp,sp,112
    80006756:	8082                	ret

0000000080006758 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006758:	7139                	addi	sp,sp,-64
    8000675a:	fc06                	sd	ra,56(sp)
    8000675c:	f822                	sd	s0,48(sp)
    8000675e:	f426                	sd	s1,40(sp)
    80006760:	f04a                	sd	s2,32(sp)
    80006762:	ec4e                	sd	s3,24(sp)
    80006764:	e852                	sd	s4,16(sp)
    80006766:	e456                	sd	s5,8(sp)
    80006768:	e05a                	sd	s6,0(sp)
    8000676a:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    8000676c:	00022a97          	auipc	s5,0x22
    80006770:	8ecaaa83          	lw	s5,-1812(s5) # 80028058 <nsizes>
  return n / BLK_SIZE(k);
    80006774:	00022a17          	auipc	s4,0x22
    80006778:	8d4a3a03          	ld	s4,-1836(s4) # 80028048 <bd_base>
    8000677c:	41450a3b          	subw	s4,a0,s4
    80006780:	00022497          	auipc	s1,0x22
    80006784:	8d04b483          	ld	s1,-1840(s1) # 80028050 <bd_sizes>
    80006788:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    8000678c:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    8000678e:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006790:	03595363          	bge	s2,s5,800067b6 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006794:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006798:	013b15b3          	sll	a1,s6,s3
    8000679c:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800067a0:	2581                	sext.w	a1,a1
    800067a2:	6088                	ld	a0,0(s1)
    800067a4:	00000097          	auipc	ra,0x0
    800067a8:	b02080e7          	jalr	-1278(ra) # 800062a6 <bit_isset>
    800067ac:	02048493          	addi	s1,s1,32
    800067b0:	e501                	bnez	a0,800067b8 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    800067b2:	894e                	mv	s2,s3
    800067b4:	bff1                	j	80006790 <size+0x38>
      return k;
    }
  }
  return 0;
    800067b6:	4901                	li	s2,0
}
    800067b8:	854a                	mv	a0,s2
    800067ba:	70e2                	ld	ra,56(sp)
    800067bc:	7442                	ld	s0,48(sp)
    800067be:	74a2                	ld	s1,40(sp)
    800067c0:	7902                	ld	s2,32(sp)
    800067c2:	69e2                	ld	s3,24(sp)
    800067c4:	6a42                	ld	s4,16(sp)
    800067c6:	6aa2                	ld	s5,8(sp)
    800067c8:	6b02                	ld	s6,0(sp)
    800067ca:	6121                	addi	sp,sp,64
    800067cc:	8082                	ret

00000000800067ce <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    800067ce:	7159                	addi	sp,sp,-112
    800067d0:	f486                	sd	ra,104(sp)
    800067d2:	f0a2                	sd	s0,96(sp)
    800067d4:	eca6                	sd	s1,88(sp)
    800067d6:	e8ca                	sd	s2,80(sp)
    800067d8:	e4ce                	sd	s3,72(sp)
    800067da:	e0d2                	sd	s4,64(sp)
    800067dc:	fc56                	sd	s5,56(sp)
    800067de:	f85a                	sd	s6,48(sp)
    800067e0:	f45e                	sd	s7,40(sp)
    800067e2:	f062                	sd	s8,32(sp)
    800067e4:	ec66                	sd	s9,24(sp)
    800067e6:	e86a                	sd	s10,16(sp)
    800067e8:	e46e                	sd	s11,8(sp)
    800067ea:	1880                	addi	s0,sp,112
    800067ec:	8baa                	mv	s7,a0
  void *q;
  int k;

  acquire(&lock);
    800067ee:	00022517          	auipc	a0,0x22
    800067f2:	81250513          	addi	a0,a0,-2030 # 80028000 <lock>
    800067f6:	ffffa097          	auipc	ra,0xffffa
    800067fa:	1c6080e7          	jalr	454(ra) # 800009bc <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    800067fe:	855e                	mv	a0,s7
    80006800:	00000097          	auipc	ra,0x0
    80006804:	f58080e7          	jalr	-168(ra) # 80006758 <size>
    80006808:	84aa                	mv	s1,a0
    8000680a:	00022797          	auipc	a5,0x22
    8000680e:	84e7a783          	lw	a5,-1970(a5) # 80028058 <nsizes>
    80006812:	37fd                	addiw	a5,a5,-1
    80006814:	0cf55063          	bge	a0,a5,800068d4 <bd_free+0x106>
    80006818:	00150a93          	addi	s5,a0,1
    8000681c:	0a96                	slli	s5,s5,0x5
  int n = p - (char *) bd_base;
    8000681e:	00022d97          	auipc	s11,0x22
    80006822:	82ad8d93          	addi	s11,s11,-2006 # 80028048 <bd_base>
  return n / BLK_SIZE(k);
    80006826:	4d41                	li	s10,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    // bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    bit_toggle(bd_sizes[k].alloc, bi);  // free p at size k
    80006828:	00022c97          	auipc	s9,0x22
    8000682c:	828c8c93          	addi	s9,s9,-2008 # 80028050 <bd_sizes>
    80006830:	a081                	j	80006870 <bd_free+0xa2>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006832:	fffb0c1b          	addiw	s8,s6,-1
    80006836:	a899                	j	8000688c <bd_free+0xbe>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006838:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    8000683a:	000db583          	ld	a1,0(s11)
  return n / BLK_SIZE(k);
    8000683e:	40bb85bb          	subw	a1,s7,a1
    80006842:	009d17b3          	sll	a5,s10,s1
    80006846:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    8000684a:	000cb783          	ld	a5,0(s9)
    8000684e:	97d6                	add	a5,a5,s5
    80006850:	2581                	sext.w	a1,a1
    80006852:	6f88                	ld	a0,24(a5)
    80006854:	00000097          	auipc	ra,0x0
    80006858:	aba080e7          	jalr	-1350(ra) # 8000630e <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    8000685c:	020a8a93          	addi	s5,s5,32
    80006860:	00021797          	auipc	a5,0x21
    80006864:	7f878793          	addi	a5,a5,2040 # 80028058 <nsizes>
    80006868:	439c                	lw	a5,0(a5)
    8000686a:	37fd                	addiw	a5,a5,-1
    8000686c:	06f4d463          	bge	s1,a5,800068d4 <bd_free+0x106>
  int n = p - (char *) bd_base;
    80006870:	000db903          	ld	s2,0(s11)
  return n / BLK_SIZE(k);
    80006874:	009d1a33          	sll	s4,s10,s1
    80006878:	412b87bb          	subw	a5,s7,s2
    8000687c:	0347c7b3          	div	a5,a5,s4
    80006880:	00078b1b          	sext.w	s6,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006884:	8b85                	andi	a5,a5,1
    80006886:	f7d5                	bnez	a5,80006832 <bd_free+0x64>
    80006888:	001b0c1b          	addiw	s8,s6,1
    bit_toggle(bd_sizes[k].alloc, bi);  // free p at size k
    8000688c:	fe0a8993          	addi	s3,s5,-32
    80006890:	000cb783          	ld	a5,0(s9)
    80006894:	99be                	add	s3,s3,a5
    80006896:	85da                	mv	a1,s6
    80006898:	0109b503          	ld	a0,16(s3)
    8000689c:	00000097          	auipc	ra,0x0
    800068a0:	aa6080e7          	jalr	-1370(ra) # 80006342 <bit_toggle>
    if (bit_get(bd_sizes[k].alloc, bi)) {  // is buddy allocated?
    800068a4:	85da                	mv	a1,s6
    800068a6:	0109b503          	ld	a0,16(s3)
    800068aa:	00000097          	auipc	ra,0x0
    800068ae:	ad4080e7          	jalr	-1324(ra) # 8000637e <bit_get>
    800068b2:	e10d                	bnez	a0,800068d4 <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    800068b4:	000c099b          	sext.w	s3,s8
  return (char *) bd_base + n;
    800068b8:	038a0a3b          	mulw	s4,s4,s8
    800068bc:	9952                	add	s2,s2,s4
    lst_remove(q);    // remove buddy from free list
    800068be:	854a                	mv	a0,s2
    800068c0:	00000097          	auipc	ra,0x0
    800068c4:	65e080e7          	jalr	1630(ra) # 80006f1e <lst_remove>
    if(buddy % 2 == 0) {
    800068c8:	0019f993          	andi	s3,s3,1
    800068cc:	f60996e3          	bnez	s3,80006838 <bd_free+0x6a>
      p = q;
    800068d0:	8bca                	mv	s7,s2
    800068d2:	b79d                	j	80006838 <bd_free+0x6a>
  }
  lst_push(&bd_sizes[k].free, p);
    800068d4:	0496                	slli	s1,s1,0x5
    800068d6:	85de                	mv	a1,s7
    800068d8:	00021517          	auipc	a0,0x21
    800068dc:	77853503          	ld	a0,1912(a0) # 80028050 <bd_sizes>
    800068e0:	9526                	add	a0,a0,s1
    800068e2:	00000097          	auipc	ra,0x0
    800068e6:	688080e7          	jalr	1672(ra) # 80006f6a <lst_push>
  release(&lock);
    800068ea:	00021517          	auipc	a0,0x21
    800068ee:	71650513          	addi	a0,a0,1814 # 80028000 <lock>
    800068f2:	ffffa097          	auipc	ra,0xffffa
    800068f6:	132080e7          	jalr	306(ra) # 80000a24 <release>
}
    800068fa:	70a6                	ld	ra,104(sp)
    800068fc:	7406                	ld	s0,96(sp)
    800068fe:	64e6                	ld	s1,88(sp)
    80006900:	6946                	ld	s2,80(sp)
    80006902:	69a6                	ld	s3,72(sp)
    80006904:	6a06                	ld	s4,64(sp)
    80006906:	7ae2                	ld	s5,56(sp)
    80006908:	7b42                	ld	s6,48(sp)
    8000690a:	7ba2                	ld	s7,40(sp)
    8000690c:	7c02                	ld	s8,32(sp)
    8000690e:	6ce2                	ld	s9,24(sp)
    80006910:	6d42                	ld	s10,16(sp)
    80006912:	6da2                	ld	s11,8(sp)
    80006914:	6165                	addi	sp,sp,112
    80006916:	8082                	ret

0000000080006918 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006918:	1141                	addi	sp,sp,-16
    8000691a:	e422                	sd	s0,8(sp)
    8000691c:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    8000691e:	00021797          	auipc	a5,0x21
    80006922:	72a7b783          	ld	a5,1834(a5) # 80028048 <bd_base>
    80006926:	8d9d                	sub	a1,a1,a5
    80006928:	47c1                	li	a5,16
    8000692a:	00a797b3          	sll	a5,a5,a0
    8000692e:	02f5c533          	div	a0,a1,a5
    80006932:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006934:	02f5e5b3          	rem	a1,a1,a5
    80006938:	c191                	beqz	a1,8000693c <blk_index_next+0x24>
      n++;
    8000693a:	2505                	addiw	a0,a0,1
  return n ;
}
    8000693c:	6422                	ld	s0,8(sp)
    8000693e:	0141                	addi	sp,sp,16
    80006940:	8082                	ret

0000000080006942 <log2>:

int
log2(uint64 n) {
    80006942:	1141                	addi	sp,sp,-16
    80006944:	e422                	sd	s0,8(sp)
    80006946:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006948:	4705                	li	a4,1
    8000694a:	00a77b63          	bgeu	a4,a0,80006960 <log2+0x1e>
    8000694e:	87aa                	mv	a5,a0
  int k = 0;
    80006950:	4501                	li	a0,0
    k++;
    80006952:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006954:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006956:	fef76ee3          	bltu	a4,a5,80006952 <log2+0x10>
  }
  return k;
}
    8000695a:	6422                	ld	s0,8(sp)
    8000695c:	0141                	addi	sp,sp,16
    8000695e:	8082                	ret
  int k = 0;
    80006960:	4501                	li	a0,0
    80006962:	bfe5                	j	8000695a <log2+0x18>

0000000080006964 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006964:	711d                	addi	sp,sp,-96
    80006966:	ec86                	sd	ra,88(sp)
    80006968:	e8a2                	sd	s0,80(sp)
    8000696a:	e4a6                	sd	s1,72(sp)
    8000696c:	e0ca                	sd	s2,64(sp)
    8000696e:	fc4e                	sd	s3,56(sp)
    80006970:	f852                	sd	s4,48(sp)
    80006972:	f456                	sd	s5,40(sp)
    80006974:	f05a                	sd	s6,32(sp)
    80006976:	ec5e                	sd	s7,24(sp)
    80006978:	e862                	sd	s8,16(sp)
    8000697a:	e466                	sd	s9,8(sp)
    8000697c:	e06a                	sd	s10,0(sp)
    8000697e:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006980:	00b56933          	or	s2,a0,a1
    80006984:	00f97913          	andi	s2,s2,15
    80006988:	04091263          	bnez	s2,800069cc <bd_mark+0x68>
    8000698c:	8b2a                	mv	s6,a0
    8000698e:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006990:	00021c17          	auipc	s8,0x21
    80006994:	6c8c2c03          	lw	s8,1736(s8) # 80028058 <nsizes>
    80006998:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    8000699a:	00021d17          	auipc	s10,0x21
    8000699e:	6aed0d13          	addi	s10,s10,1710 # 80028048 <bd_base>
  return n / BLK_SIZE(k);
    800069a2:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    800069a4:	00021a97          	auipc	s5,0x21
    800069a8:	6aca8a93          	addi	s5,s5,1708 # 80028050 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    800069ac:	07804563          	bgtz	s8,80006a16 <bd_mark+0xb2>
      }
      // bit_set(bd_sizes[k].alloc, bi);
      bit_toggle(bd_sizes[k].alloc,bi);
    }
  }
} 
    800069b0:	60e6                	ld	ra,88(sp)
    800069b2:	6446                	ld	s0,80(sp)
    800069b4:	64a6                	ld	s1,72(sp)
    800069b6:	6906                	ld	s2,64(sp)
    800069b8:	79e2                	ld	s3,56(sp)
    800069ba:	7a42                	ld	s4,48(sp)
    800069bc:	7aa2                	ld	s5,40(sp)
    800069be:	7b02                	ld	s6,32(sp)
    800069c0:	6be2                	ld	s7,24(sp)
    800069c2:	6c42                	ld	s8,16(sp)
    800069c4:	6ca2                	ld	s9,8(sp)
    800069c6:	6d02                	ld	s10,0(sp)
    800069c8:	6125                	addi	sp,sp,96
    800069ca:	8082                	ret
    panic("bd_mark");
    800069cc:	00001517          	auipc	a0,0x1
    800069d0:	f2c50513          	addi	a0,a0,-212 # 800078f8 <userret+0x868>
    800069d4:	ffffa097          	auipc	ra,0xffffa
    800069d8:	b74080e7          	jalr	-1164(ra) # 80000548 <panic>
      bit_toggle(bd_sizes[k].alloc,bi);
    800069dc:	000ab783          	ld	a5,0(s5)
    800069e0:	97ca                	add	a5,a5,s2
    800069e2:	85a6                	mv	a1,s1
    800069e4:	6b88                	ld	a0,16(a5)
    800069e6:	00000097          	auipc	ra,0x0
    800069ea:	95c080e7          	jalr	-1700(ra) # 80006342 <bit_toggle>
    for(; bi < bj; bi++) {
    800069ee:	2485                	addiw	s1,s1,1
    800069f0:	009a0e63          	beq	s4,s1,80006a0c <bd_mark+0xa8>
      if(k > 0) {
    800069f4:	ff3054e3          	blez	s3,800069dc <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    800069f8:	000ab783          	ld	a5,0(s5)
    800069fc:	97ca                	add	a5,a5,s2
    800069fe:	85a6                	mv	a1,s1
    80006a00:	6f88                	ld	a0,24(a5)
    80006a02:	00000097          	auipc	ra,0x0
    80006a06:	8dc080e7          	jalr	-1828(ra) # 800062de <bit_set>
    80006a0a:	bfc9                	j	800069dc <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006a0c:	2985                	addiw	s3,s3,1
    80006a0e:	02090913          	addi	s2,s2,32
    80006a12:	f9898fe3          	beq	s3,s8,800069b0 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006a16:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006a1a:	409b04bb          	subw	s1,s6,s1
    80006a1e:	013c97b3          	sll	a5,s9,s3
    80006a22:	02f4c4b3          	div	s1,s1,a5
    80006a26:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006a28:	85de                	mv	a1,s7
    80006a2a:	854e                	mv	a0,s3
    80006a2c:	00000097          	auipc	ra,0x0
    80006a30:	eec080e7          	jalr	-276(ra) # 80006918 <blk_index_next>
    80006a34:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006a36:	faa4cfe3          	blt	s1,a0,800069f4 <bd_mark+0x90>
    80006a3a:	bfc9                	j	80006a0c <bd_mark+0xa8>

0000000080006a3c <addr_in_range>:

// return 1 if addr is in range (left,right)
int addr_in_range(void *addr,void *left,void *right,int size){
    80006a3c:	1141                	addi	sp,sp,-16
    80006a3e:	e422                	sd	s0,8(sp)
    80006a40:	0800                	addi	s0,sp,16
  return (addr>=left)&&((addr+size)<right);
    80006a42:	00b56863          	bltu	a0,a1,80006a52 <addr_in_range+0x16>
    80006a46:	9536                	add	a0,a0,a3
    80006a48:	00c53533          	sltu	a0,a0,a2
}
    80006a4c:	6422                	ld	s0,8(sp)
    80006a4e:	0141                	addi	sp,sp,16
    80006a50:	8082                	ret
  return (addr>=left)&&((addr+size)<right);
    80006a52:	4501                	li	a0,0
    80006a54:	bfe5                	j	80006a4c <addr_in_range+0x10>

0000000080006a56 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi,void *left,void *right) {
    80006a56:	715d                	addi	sp,sp,-80
    80006a58:	e486                	sd	ra,72(sp)
    80006a5a:	e0a2                	sd	s0,64(sp)
    80006a5c:	fc26                	sd	s1,56(sp)
    80006a5e:	f84a                	sd	s2,48(sp)
    80006a60:	f44e                	sd	s3,40(sp)
    80006a62:	f052                	sd	s4,32(sp)
    80006a64:	ec56                	sd	s5,24(sp)
    80006a66:	e85a                	sd	s6,16(sp)
    80006a68:	e45e                	sd	s7,8(sp)
    80006a6a:	0880                	addi	s0,sp,80
    80006a6c:	8b2a                	mv	s6,a0
    80006a6e:	89b2                	mv	s3,a2
    80006a70:	8a36                	mv	s4,a3
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006a72:	00058b9b          	sext.w	s7,a1
    80006a76:	0015f793          	andi	a5,a1,1
    80006a7a:	ebb1                	bnez	a5,80006ace <bd_initfree_pair+0x78>
    80006a7c:	00158a9b          	addiw	s5,a1,1
  int free = 0;
  // if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
  if(bit_get(bd_sizes[k].alloc,bi)){
    80006a80:	005b1793          	slli	a5,s6,0x5
    80006a84:	00021917          	auipc	s2,0x21
    80006a88:	5cc93903          	ld	s2,1484(s2) # 80028050 <bd_sizes>
    80006a8c:	993e                	add	s2,s2,a5
    80006a8e:	01093503          	ld	a0,16(s2)
    80006a92:	00000097          	auipc	ra,0x0
    80006a96:	8ec080e7          	jalr	-1812(ra) # 8000637e <bit_get>
    80006a9a:	84aa                	mv	s1,a0
    80006a9c:	c529                	beqz	a0,80006ae6 <bd_initfree_pair+0x90>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006a9e:	44c1                	li	s1,16
    80006aa0:	016494b3          	sll	s1,s1,s6
    80006aa4:	2481                	sext.w	s1,s1
  int n = bi * BLK_SIZE(k);
    80006aa6:	8726                	mv	a4,s1
  return (char *) bd_base + n;
    80006aa8:	00021797          	auipc	a5,0x21
    80006aac:	5a07b783          	ld	a5,1440(a5) # 80028048 <bd_base>
    80006ab0:	029b85bb          	mulw	a1,s7,s1
    80006ab4:	95be                	add	a1,a1,a5
  return (addr>=left)&&((addr+size)<right);
    80006ab6:	0135ef63          	bltu	a1,s3,80006ad4 <bd_initfree_pair+0x7e>
    80006aba:	009586b3          	add	a3,a1,s1
    80006abe:	0146fb63          	bgeu	a3,s4,80006ad4 <bd_initfree_pair+0x7e>
    // printf("bi (%p,%p,in range:%d)\tbuddy(%p,%p,in range:%d)\n",addr(k,bi),addr(k,bi)+free,addr_in_range(addr(k,bi),left,right,free),addr(k,buddy),addr(k,buddy)+free,addr_in_range(addr(k,buddy),left,right,free));
    if(addr_in_range(addr(k,bi),left,right,free)){
      lst_push(&bd_sizes[k].free, addr(k, bi)); 
    80006ac2:	854a                	mv	a0,s2
    80006ac4:	00000097          	auipc	ra,0x0
    80006ac8:	4a6080e7          	jalr	1190(ra) # 80006f6a <lst_push>
    80006acc:	a829                	j	80006ae6 <bd_initfree_pair+0x90>
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006ace:	fff58a9b          	addiw	s5,a1,-1
    80006ad2:	b77d                	j	80006a80 <bd_initfree_pair+0x2a>
  return (char *) bd_base + n;
    80006ad4:	02ea8abb          	mulw	s5,s5,a4
    }else{
      lst_push(&bd_sizes[k].free, addr(k, buddy)); 
    80006ad8:	015785b3          	add	a1,a5,s5
    80006adc:	854a                	mv	a0,s2
    80006ade:	00000097          	auipc	ra,0x0
    80006ae2:	48c080e7          	jalr	1164(ra) # 80006f6a <lst_push>
    //   lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    // else
    //   lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006ae6:	8526                	mv	a0,s1
    80006ae8:	60a6                	ld	ra,72(sp)
    80006aea:	6406                	ld	s0,64(sp)
    80006aec:	74e2                	ld	s1,56(sp)
    80006aee:	7942                	ld	s2,48(sp)
    80006af0:	79a2                	ld	s3,40(sp)
    80006af2:	7a02                	ld	s4,32(sp)
    80006af4:	6ae2                	ld	s5,24(sp)
    80006af6:	6b42                	ld	s6,16(sp)
    80006af8:	6ba2                	ld	s7,8(sp)
    80006afa:	6161                	addi	sp,sp,80
    80006afc:	8082                	ret

0000000080006afe <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006afe:	711d                	addi	sp,sp,-96
    80006b00:	ec86                	sd	ra,88(sp)
    80006b02:	e8a2                	sd	s0,80(sp)
    80006b04:	e4a6                	sd	s1,72(sp)
    80006b06:	e0ca                	sd	s2,64(sp)
    80006b08:	fc4e                	sd	s3,56(sp)
    80006b0a:	f852                	sd	s4,48(sp)
    80006b0c:	f456                	sd	s5,40(sp)
    80006b0e:	f05a                	sd	s6,32(sp)
    80006b10:	ec5e                	sd	s7,24(sp)
    80006b12:	e862                	sd	s8,16(sp)
    80006b14:	e466                	sd	s9,8(sp)
    80006b16:	e06a                	sd	s10,0(sp)
    80006b18:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006b1a:	00021717          	auipc	a4,0x21
    80006b1e:	53e72703          	lw	a4,1342(a4) # 80028058 <nsizes>
    80006b22:	4785                	li	a5,1
    80006b24:	06e7df63          	bge	a5,a4,80006ba2 <bd_initfree+0xa4>
    80006b28:	8aaa                	mv	s5,a0
    80006b2a:	8b2e                	mv	s6,a1
    80006b2c:	4901                	li	s2,0
  int free = 0;
    80006b2e:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006b30:	00021c97          	auipc	s9,0x21
    80006b34:	518c8c93          	addi	s9,s9,1304 # 80028048 <bd_base>
  return n / BLK_SIZE(k);
    80006b38:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006b3a:	00021b97          	auipc	s7,0x21
    80006b3e:	51eb8b93          	addi	s7,s7,1310 # 80028058 <nsizes>
    80006b42:	a039                	j	80006b50 <bd_initfree+0x52>
    80006b44:	2905                	addiw	s2,s2,1
    80006b46:	000ba783          	lw	a5,0(s7)
    80006b4a:	37fd                	addiw	a5,a5,-1
    80006b4c:	04f95c63          	bge	s2,a5,80006ba4 <bd_initfree+0xa6>
    int left = blk_index_next(k, bd_left);
    80006b50:	85d6                	mv	a1,s5
    80006b52:	854a                	mv	a0,s2
    80006b54:	00000097          	auipc	ra,0x0
    80006b58:	dc4080e7          	jalr	-572(ra) # 80006918 <blk_index_next>
    80006b5c:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006b5e:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006b62:	409b04bb          	subw	s1,s6,s1
    80006b66:	012c17b3          	sll	a5,s8,s2
    80006b6a:	02f4c4b3          	div	s1,s1,a5
    80006b6e:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left,bd_left,bd_right);
    80006b70:	86da                	mv	a3,s6
    80006b72:	8656                	mv	a2,s5
    80006b74:	85aa                	mv	a1,a0
    80006b76:	854a                	mv	a0,s2
    80006b78:	00000097          	auipc	ra,0x0
    80006b7c:	ede080e7          	jalr	-290(ra) # 80006a56 <bd_initfree_pair>
    80006b80:	01450d3b          	addw	s10,a0,s4
    80006b84:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006b88:	fa99dee3          	bge	s3,s1,80006b44 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right,bd_left,bd_right);
    80006b8c:	86da                	mv	a3,s6
    80006b8e:	8656                	mv	a2,s5
    80006b90:	85a6                	mv	a1,s1
    80006b92:	854a                	mv	a0,s2
    80006b94:	00000097          	auipc	ra,0x0
    80006b98:	ec2080e7          	jalr	-318(ra) # 80006a56 <bd_initfree_pair>
    80006b9c:	00ad0a3b          	addw	s4,s10,a0
    80006ba0:	b755                	j	80006b44 <bd_initfree+0x46>
  int free = 0;
    80006ba2:	4a01                	li	s4,0
  }
  return free;
}
    80006ba4:	8552                	mv	a0,s4
    80006ba6:	60e6                	ld	ra,88(sp)
    80006ba8:	6446                	ld	s0,80(sp)
    80006baa:	64a6                	ld	s1,72(sp)
    80006bac:	6906                	ld	s2,64(sp)
    80006bae:	79e2                	ld	s3,56(sp)
    80006bb0:	7a42                	ld	s4,48(sp)
    80006bb2:	7aa2                	ld	s5,40(sp)
    80006bb4:	7b02                	ld	s6,32(sp)
    80006bb6:	6be2                	ld	s7,24(sp)
    80006bb8:	6c42                	ld	s8,16(sp)
    80006bba:	6ca2                	ld	s9,8(sp)
    80006bbc:	6d02                	ld	s10,0(sp)
    80006bbe:	6125                	addi	sp,sp,96
    80006bc0:	8082                	ret

0000000080006bc2 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006bc2:	7179                	addi	sp,sp,-48
    80006bc4:	f406                	sd	ra,40(sp)
    80006bc6:	f022                	sd	s0,32(sp)
    80006bc8:	ec26                	sd	s1,24(sp)
    80006bca:	e84a                	sd	s2,16(sp)
    80006bcc:	e44e                	sd	s3,8(sp)
    80006bce:	1800                	addi	s0,sp,48
    80006bd0:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006bd2:	00021997          	auipc	s3,0x21
    80006bd6:	47698993          	addi	s3,s3,1142 # 80028048 <bd_base>
    80006bda:	0009b483          	ld	s1,0(s3)
    80006bde:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006be2:	00021797          	auipc	a5,0x21
    80006be6:	4767a783          	lw	a5,1142(a5) # 80028058 <nsizes>
    80006bea:	37fd                	addiw	a5,a5,-1
    80006bec:	4641                	li	a2,16
    80006bee:	00f61633          	sll	a2,a2,a5
    80006bf2:	85a6                	mv	a1,s1
    80006bf4:	00001517          	auipc	a0,0x1
    80006bf8:	d0c50513          	addi	a0,a0,-756 # 80007900 <userret+0x870>
    80006bfc:	ffffa097          	auipc	ra,0xffffa
    80006c00:	996080e7          	jalr	-1642(ra) # 80000592 <printf>
  bd_mark(bd_base, p);
    80006c04:	85ca                	mv	a1,s2
    80006c06:	0009b503          	ld	a0,0(s3)
    80006c0a:	00000097          	auipc	ra,0x0
    80006c0e:	d5a080e7          	jalr	-678(ra) # 80006964 <bd_mark>
  return meta;
}
    80006c12:	8526                	mv	a0,s1
    80006c14:	70a2                	ld	ra,40(sp)
    80006c16:	7402                	ld	s0,32(sp)
    80006c18:	64e2                	ld	s1,24(sp)
    80006c1a:	6942                	ld	s2,16(sp)
    80006c1c:	69a2                	ld	s3,8(sp)
    80006c1e:	6145                	addi	sp,sp,48
    80006c20:	8082                	ret

0000000080006c22 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006c22:	1101                	addi	sp,sp,-32
    80006c24:	ec06                	sd	ra,24(sp)
    80006c26:	e822                	sd	s0,16(sp)
    80006c28:	e426                	sd	s1,8(sp)
    80006c2a:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006c2c:	00021497          	auipc	s1,0x21
    80006c30:	42c4a483          	lw	s1,1068(s1) # 80028058 <nsizes>
    80006c34:	fff4879b          	addiw	a5,s1,-1
    80006c38:	44c1                	li	s1,16
    80006c3a:	00f494b3          	sll	s1,s1,a5
    80006c3e:	00021797          	auipc	a5,0x21
    80006c42:	40a7b783          	ld	a5,1034(a5) # 80028048 <bd_base>
    80006c46:	8d1d                	sub	a0,a0,a5
    80006c48:	40a4853b          	subw	a0,s1,a0
    80006c4c:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006c50:	00905a63          	blez	s1,80006c64 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006c54:	357d                	addiw	a0,a0,-1
    80006c56:	41f5549b          	sraiw	s1,a0,0x1f
    80006c5a:	01c4d49b          	srliw	s1,s1,0x1c
    80006c5e:	9ca9                	addw	s1,s1,a0
    80006c60:	98c1                	andi	s1,s1,-16
    80006c62:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006c64:	85a6                	mv	a1,s1
    80006c66:	00001517          	auipc	a0,0x1
    80006c6a:	cd250513          	addi	a0,a0,-814 # 80007938 <userret+0x8a8>
    80006c6e:	ffffa097          	auipc	ra,0xffffa
    80006c72:	924080e7          	jalr	-1756(ra) # 80000592 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006c76:	00021717          	auipc	a4,0x21
    80006c7a:	3d273703          	ld	a4,978(a4) # 80028048 <bd_base>
    80006c7e:	00021597          	auipc	a1,0x21
    80006c82:	3da5a583          	lw	a1,986(a1) # 80028058 <nsizes>
    80006c86:	fff5879b          	addiw	a5,a1,-1
    80006c8a:	45c1                	li	a1,16
    80006c8c:	00f595b3          	sll	a1,a1,a5
    80006c90:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006c94:	95ba                	add	a1,a1,a4
    80006c96:	953a                	add	a0,a0,a4
    80006c98:	00000097          	auipc	ra,0x0
    80006c9c:	ccc080e7          	jalr	-820(ra) # 80006964 <bd_mark>
  return unavailable;
}
    80006ca0:	8526                	mv	a0,s1
    80006ca2:	60e2                	ld	ra,24(sp)
    80006ca4:	6442                	ld	s0,16(sp)
    80006ca6:	64a2                	ld	s1,8(sp)
    80006ca8:	6105                	addi	sp,sp,32
    80006caa:	8082                	ret

0000000080006cac <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80006cac:	715d                	addi	sp,sp,-80
    80006cae:	e486                	sd	ra,72(sp)
    80006cb0:	e0a2                	sd	s0,64(sp)
    80006cb2:	fc26                	sd	s1,56(sp)
    80006cb4:	f84a                	sd	s2,48(sp)
    80006cb6:	f44e                	sd	s3,40(sp)
    80006cb8:	f052                	sd	s4,32(sp)
    80006cba:	ec56                	sd	s5,24(sp)
    80006cbc:	e85a                	sd	s6,16(sp)
    80006cbe:	e45e                	sd	s7,8(sp)
    80006cc0:	e062                	sd	s8,0(sp)
    80006cc2:	0880                	addi	s0,sp,80
    80006cc4:	84aa                	mv	s1,a0
    80006cc6:	8c2e                	mv	s8,a1

  printf("[bd_init] Input Range: 0x%p → 0x%p\n", base, end);
    80006cc8:	862e                	mv	a2,a1
    80006cca:	85aa                	mv	a1,a0
    80006ccc:	00001517          	auipc	a0,0x1
    80006cd0:	c8c50513          	addi	a0,a0,-884 # 80007958 <userret+0x8c8>
    80006cd4:	ffffa097          	auipc	ra,0xffffa
    80006cd8:	8be080e7          	jalr	-1858(ra) # 80000592 <printf>

  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80006cdc:	14fd                	addi	s1,s1,-1
    80006cde:	98c1                	andi	s1,s1,-16
    80006ce0:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80006ce2:	00001597          	auipc	a1,0x1
    80006ce6:	c9e58593          	addi	a1,a1,-866 # 80007980 <userret+0x8f0>
    80006cea:	00021517          	auipc	a0,0x21
    80006cee:	31650513          	addi	a0,a0,790 # 80028000 <lock>
    80006cf2:	ffffa097          	auipc	ra,0xffffa
    80006cf6:	bbc080e7          	jalr	-1092(ra) # 800008ae <initlock>
  bd_base = (void *) p;
    80006cfa:	00021797          	auipc	a5,0x21
    80006cfe:	3497b723          	sd	s1,846(a5) # 80028048 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006d02:	409c0933          	sub	s2,s8,s1
    80006d06:	43f95513          	srai	a0,s2,0x3f
    80006d0a:	893d                	andi	a0,a0,15
    80006d0c:	954a                	add	a0,a0,s2
    80006d0e:	8511                	srai	a0,a0,0x4
    80006d10:	00000097          	auipc	ra,0x0
    80006d14:	c32080e7          	jalr	-974(ra) # 80006942 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80006d18:	47c1                	li	a5,16
    80006d1a:	00a797b3          	sll	a5,a5,a0
    80006d1e:	1b27c663          	blt	a5,s2,80006eca <bd_init+0x21e>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006d22:	2505                	addiw	a0,a0,1
    80006d24:	00021797          	auipc	a5,0x21
    80006d28:	32a7aa23          	sw	a0,820(a5) # 80028058 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80006d2c:	00021997          	auipc	s3,0x21
    80006d30:	32c98993          	addi	s3,s3,812 # 80028058 <nsizes>
    80006d34:	0009a603          	lw	a2,0(s3)
    80006d38:	85ca                	mv	a1,s2
    80006d3a:	00001517          	auipc	a0,0x1
    80006d3e:	c4e50513          	addi	a0,a0,-946 # 80007988 <userret+0x8f8>
    80006d42:	ffffa097          	auipc	ra,0xffffa
    80006d46:	850080e7          	jalr	-1968(ra) # 80000592 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80006d4a:	00021797          	auipc	a5,0x21
    80006d4e:	3097b323          	sd	s1,774(a5) # 80028050 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80006d52:	0009a603          	lw	a2,0(s3)
    80006d56:	00561913          	slli	s2,a2,0x5
    80006d5a:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80006d5c:	0056161b          	slliw	a2,a2,0x5
    80006d60:	4581                	li	a1,0
    80006d62:	8526                	mv	a0,s1
    80006d64:	ffffa097          	auipc	ra,0xffffa
    80006d68:	d1c080e7          	jalr	-740(ra) # 80000a80 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80006d6c:	0009a783          	lw	a5,0(s3)
    80006d70:	06f05a63          	blez	a5,80006de4 <bd_init+0x138>
    80006d74:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80006d76:	00021a97          	auipc	s5,0x21
    80006d7a:	2daa8a93          	addi	s5,s5,730 # 80028050 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 16)/16;
    80006d7e:	00021a17          	auipc	s4,0x21
    80006d82:	2daa0a13          	addi	s4,s4,730 # 80028058 <nsizes>
    80006d86:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80006d88:	00599b93          	slli	s7,s3,0x5
    80006d8c:	000ab503          	ld	a0,0(s5)
    80006d90:	955e                	add	a0,a0,s7
    80006d92:	00000097          	auipc	ra,0x0
    80006d96:	166080e7          	jalr	358(ra) # 80006ef8 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 16)/16;
    80006d9a:	000a2483          	lw	s1,0(s4)
    80006d9e:	34fd                	addiw	s1,s1,-1
    80006da0:	413484bb          	subw	s1,s1,s3
    80006da4:	009b14bb          	sllw	s1,s6,s1
    80006da8:	fff4879b          	addiw	a5,s1,-1
    80006dac:	41f7d49b          	sraiw	s1,a5,0x1f
    80006db0:	01c4d49b          	srliw	s1,s1,0x1c
    80006db4:	9cbd                	addw	s1,s1,a5
    80006db6:	98c1                	andi	s1,s1,-16
    80006db8:	24c1                	addiw	s1,s1,16
    bd_sizes[k].alloc = p;
    80006dba:	000ab783          	ld	a5,0(s5)
    80006dbe:	9bbe                	add	s7,s7,a5
    80006dc0:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80006dc4:	8491                	srai	s1,s1,0x4
    80006dc6:	8626                	mv	a2,s1
    80006dc8:	4581                	li	a1,0
    80006dca:	854a                	mv	a0,s2
    80006dcc:	ffffa097          	auipc	ra,0xffffa
    80006dd0:	cb4080e7          	jalr	-844(ra) # 80000a80 <memset>
    p += sz;
    80006dd4:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80006dd6:	0985                	addi	s3,s3,1
    80006dd8:	000a2703          	lw	a4,0(s4)
    80006ddc:	0009879b          	sext.w	a5,s3
    80006de0:	fae7c4e3          	blt	a5,a4,80006d88 <bd_init+0xdc>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80006de4:	00021797          	auipc	a5,0x21
    80006de8:	2747a783          	lw	a5,628(a5) # 80028058 <nsizes>
    80006dec:	4705                	li	a4,1
    80006dee:	06f75163          	bge	a4,a5,80006e50 <bd_init+0x1a4>
    80006df2:	02000a13          	li	s4,32
    80006df6:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006df8:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80006dfa:	00021b17          	auipc	s6,0x21
    80006dfe:	256b0b13          	addi	s6,s6,598 # 80028050 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80006e02:	00021a97          	auipc	s5,0x21
    80006e06:	256a8a93          	addi	s5,s5,598 # 80028058 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006e0a:	37fd                	addiw	a5,a5,-1
    80006e0c:	413787bb          	subw	a5,a5,s3
    80006e10:	00fb94bb          	sllw	s1,s7,a5
    80006e14:	fff4879b          	addiw	a5,s1,-1
    80006e18:	41f7d49b          	sraiw	s1,a5,0x1f
    80006e1c:	01d4d49b          	srliw	s1,s1,0x1d
    80006e20:	9cbd                	addw	s1,s1,a5
    80006e22:	98e1                	andi	s1,s1,-8
    80006e24:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80006e26:	000b3783          	ld	a5,0(s6)
    80006e2a:	97d2                	add	a5,a5,s4
    80006e2c:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80006e30:	848d                	srai	s1,s1,0x3
    80006e32:	8626                	mv	a2,s1
    80006e34:	4581                	li	a1,0
    80006e36:	854a                	mv	a0,s2
    80006e38:	ffffa097          	auipc	ra,0xffffa
    80006e3c:	c48080e7          	jalr	-952(ra) # 80000a80 <memset>
    p += sz;
    80006e40:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80006e42:	2985                	addiw	s3,s3,1
    80006e44:	000aa783          	lw	a5,0(s5)
    80006e48:	020a0a13          	addi	s4,s4,32
    80006e4c:	faf9cfe3          	blt	s3,a5,80006e0a <bd_init+0x15e>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80006e50:	197d                	addi	s2,s2,-1
    80006e52:	ff097913          	andi	s2,s2,-16
    80006e56:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80006e58:	854a                	mv	a0,s2
    80006e5a:	00000097          	auipc	ra,0x0
    80006e5e:	d68080e7          	jalr	-664(ra) # 80006bc2 <bd_mark_data_structures>
    80006e62:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80006e64:	85ca                	mv	a1,s2
    80006e66:	8562                	mv	a0,s8
    80006e68:	00000097          	auipc	ra,0x0
    80006e6c:	dba080e7          	jalr	-582(ra) # 80006c22 <bd_mark_unavailable>
    80006e70:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006e72:	00021a97          	auipc	s5,0x21
    80006e76:	1e6a8a93          	addi	s5,s5,486 # 80028058 <nsizes>
    80006e7a:	000aa783          	lw	a5,0(s5)
    80006e7e:	37fd                	addiw	a5,a5,-1
    80006e80:	44c1                	li	s1,16
    80006e82:	00f497b3          	sll	a5,s1,a5
    80006e86:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80006e88:	00021597          	auipc	a1,0x21
    80006e8c:	1c05b583          	ld	a1,448(a1) # 80028048 <bd_base>
    80006e90:	95be                	add	a1,a1,a5
    80006e92:	854a                	mv	a0,s2
    80006e94:	00000097          	auipc	ra,0x0
    80006e98:	c6a080e7          	jalr	-918(ra) # 80006afe <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80006e9c:	000aa603          	lw	a2,0(s5)
    80006ea0:	367d                	addiw	a2,a2,-1
    80006ea2:	00c49633          	sll	a2,s1,a2
    80006ea6:	41460633          	sub	a2,a2,s4
    80006eaa:	41360633          	sub	a2,a2,s3
    80006eae:	02c51463          	bne	a0,a2,80006ed6 <bd_init+0x22a>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
    80006eb2:	60a6                	ld	ra,72(sp)
    80006eb4:	6406                	ld	s0,64(sp)
    80006eb6:	74e2                	ld	s1,56(sp)
    80006eb8:	7942                	ld	s2,48(sp)
    80006eba:	79a2                	ld	s3,40(sp)
    80006ebc:	7a02                	ld	s4,32(sp)
    80006ebe:	6ae2                	ld	s5,24(sp)
    80006ec0:	6b42                	ld	s6,16(sp)
    80006ec2:	6ba2                	ld	s7,8(sp)
    80006ec4:	6c02                	ld	s8,0(sp)
    80006ec6:	6161                	addi	sp,sp,80
    80006ec8:	8082                	ret
    nsizes++;  // round up to the next power of 2
    80006eca:	2509                	addiw	a0,a0,2
    80006ecc:	00021797          	auipc	a5,0x21
    80006ed0:	18a7a623          	sw	a0,396(a5) # 80028058 <nsizes>
    80006ed4:	bda1                	j	80006d2c <bd_init+0x80>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80006ed6:	85aa                	mv	a1,a0
    80006ed8:	00001517          	auipc	a0,0x1
    80006edc:	af050513          	addi	a0,a0,-1296 # 800079c8 <userret+0x938>
    80006ee0:	ffff9097          	auipc	ra,0xffff9
    80006ee4:	6b2080e7          	jalr	1714(ra) # 80000592 <printf>
    panic("bd_init: free mem");
    80006ee8:	00001517          	auipc	a0,0x1
    80006eec:	af050513          	addi	a0,a0,-1296 # 800079d8 <userret+0x948>
    80006ef0:	ffff9097          	auipc	ra,0xffff9
    80006ef4:	658080e7          	jalr	1624(ra) # 80000548 <panic>

0000000080006ef8 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80006ef8:	1141                	addi	sp,sp,-16
    80006efa:	e422                	sd	s0,8(sp)
    80006efc:	0800                	addi	s0,sp,16
  lst->next = lst;
    80006efe:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80006f00:	e508                	sd	a0,8(a0)
}
    80006f02:	6422                	ld	s0,8(sp)
    80006f04:	0141                	addi	sp,sp,16
    80006f06:	8082                	ret

0000000080006f08 <lst_empty>:

int
lst_empty(struct list *lst) {
    80006f08:	1141                	addi	sp,sp,-16
    80006f0a:	e422                	sd	s0,8(sp)
    80006f0c:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80006f0e:	611c                	ld	a5,0(a0)
    80006f10:	40a78533          	sub	a0,a5,a0
}
    80006f14:	00153513          	seqz	a0,a0
    80006f18:	6422                	ld	s0,8(sp)
    80006f1a:	0141                	addi	sp,sp,16
    80006f1c:	8082                	ret

0000000080006f1e <lst_remove>:

void
lst_remove(struct list *e) {
    80006f1e:	1141                	addi	sp,sp,-16
    80006f20:	e422                	sd	s0,8(sp)
    80006f22:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80006f24:	6518                	ld	a4,8(a0)
    80006f26:	611c                	ld	a5,0(a0)
    80006f28:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80006f2a:	6518                	ld	a4,8(a0)
    80006f2c:	e798                	sd	a4,8(a5)
}
    80006f2e:	6422                	ld	s0,8(sp)
    80006f30:	0141                	addi	sp,sp,16
    80006f32:	8082                	ret

0000000080006f34 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80006f34:	1101                	addi	sp,sp,-32
    80006f36:	ec06                	sd	ra,24(sp)
    80006f38:	e822                	sd	s0,16(sp)
    80006f3a:	e426                	sd	s1,8(sp)
    80006f3c:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80006f3e:	6104                	ld	s1,0(a0)
    80006f40:	00a48d63          	beq	s1,a0,80006f5a <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80006f44:	8526                	mv	a0,s1
    80006f46:	00000097          	auipc	ra,0x0
    80006f4a:	fd8080e7          	jalr	-40(ra) # 80006f1e <lst_remove>
  return (void *)p;
}
    80006f4e:	8526                	mv	a0,s1
    80006f50:	60e2                	ld	ra,24(sp)
    80006f52:	6442                	ld	s0,16(sp)
    80006f54:	64a2                	ld	s1,8(sp)
    80006f56:	6105                	addi	sp,sp,32
    80006f58:	8082                	ret
    panic("lst_pop");
    80006f5a:	00001517          	auipc	a0,0x1
    80006f5e:	a9650513          	addi	a0,a0,-1386 # 800079f0 <userret+0x960>
    80006f62:	ffff9097          	auipc	ra,0xffff9
    80006f66:	5e6080e7          	jalr	1510(ra) # 80000548 <panic>

0000000080006f6a <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80006f6a:	1141                	addi	sp,sp,-16
    80006f6c:	e422                	sd	s0,8(sp)
    80006f6e:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    80006f70:	611c                	ld	a5,0(a0)
    80006f72:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    80006f74:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80006f76:	611c                	ld	a5,0(a0)
    80006f78:	e78c                	sd	a1,8(a5)
  lst->next = e;
    80006f7a:	e10c                	sd	a1,0(a0)
}
    80006f7c:	6422                	ld	s0,8(sp)
    80006f7e:	0141                	addi	sp,sp,16
    80006f80:	8082                	ret

0000000080006f82 <lst_print>:

void
lst_print(struct list *lst)
{
    80006f82:	7179                	addi	sp,sp,-48
    80006f84:	f406                	sd	ra,40(sp)
    80006f86:	f022                	sd	s0,32(sp)
    80006f88:	ec26                	sd	s1,24(sp)
    80006f8a:	e84a                	sd	s2,16(sp)
    80006f8c:	e44e                	sd	s3,8(sp)
    80006f8e:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80006f90:	6104                	ld	s1,0(a0)
    80006f92:	02950063          	beq	a0,s1,80006fb2 <lst_print+0x30>
    80006f96:	892a                	mv	s2,a0
    printf(" %p", p);
    80006f98:	00001997          	auipc	s3,0x1
    80006f9c:	a6098993          	addi	s3,s3,-1440 # 800079f8 <userret+0x968>
    80006fa0:	85a6                	mv	a1,s1
    80006fa2:	854e                	mv	a0,s3
    80006fa4:	ffff9097          	auipc	ra,0xffff9
    80006fa8:	5ee080e7          	jalr	1518(ra) # 80000592 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80006fac:	6084                	ld	s1,0(s1)
    80006fae:	fe9919e3          	bne	s2,s1,80006fa0 <lst_print+0x1e>
  }
  printf("\n");
    80006fb2:	00000517          	auipc	a0,0x0
    80006fb6:	1ee50513          	addi	a0,a0,494 # 800071a0 <userret+0x110>
    80006fba:	ffff9097          	auipc	ra,0xffff9
    80006fbe:	5d8080e7          	jalr	1496(ra) # 80000592 <printf>
}
    80006fc2:	70a2                	ld	ra,40(sp)
    80006fc4:	7402                	ld	s0,32(sp)
    80006fc6:	64e2                	ld	s1,24(sp)
    80006fc8:	6942                	ld	s2,16(sp)
    80006fca:	69a2                	ld	s3,8(sp)
    80006fcc:	6145                	addi	sp,sp,48
    80006fce:	8082                	ret
	...

0000000080007000 <trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
