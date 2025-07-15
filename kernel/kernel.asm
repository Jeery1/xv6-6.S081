
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
    80000060:	ec478793          	addi	a5,a5,-316 # 80005f20 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd47a3>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	c8a78793          	addi	a5,a5,-886 # 80000d30 <main>
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
consoleread(struct file *f, int user_dst, uint64 dst, int n)
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
    800000fc:	8aae                	mv	s5,a1
    800000fe:	8a32                	mv	s4,a2
    80000100:	89b6                	mv	s3,a3
  uint target;
  int c;
  char cbuf;

  target = n;
    80000102:	00068b1b          	sext.w	s6,a3
  acquire(&cons.lock);
    80000106:	00012517          	auipc	a0,0x12
    8000010a:	6fa50513          	addi	a0,a0,1786 # 80012800 <cons>
    8000010e:	00001097          	auipc	ra,0x1
    80000112:	9b0080e7          	jalr	-1616(ra) # 80000abe <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000116:	00012497          	auipc	s1,0x12
    8000011a:	6ea48493          	addi	s1,s1,1770 # 80012800 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000011e:	00012917          	auipc	s2,0x12
    80000122:	77a90913          	addi	s2,s2,1914 # 80012898 <cons+0x98>
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
    8000013c:	00002097          	auipc	ra,0x2
    80000140:	8ee080e7          	jalr	-1810(ra) # 80001a2a <myproc>
    80000144:	591c                	lw	a5,48(a0)
    80000146:	e7b5                	bnez	a5,800001b2 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    80000148:	85a6                	mv	a1,s1
    8000014a:	854a                	mv	a0,s2
    8000014c:	00002097          	auipc	ra,0x2
    80000150:	0bc080e7          	jalr	188(ra) # 80002208 <sleep>
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
    8000018c:	2da080e7          	jalr	730(ra) # 80002462 <either_copyout>
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
    8000019c:	00012517          	auipc	a0,0x12
    800001a0:	66450513          	addi	a0,a0,1636 # 80012800 <cons>
    800001a4:	00001097          	auipc	ra,0x1
    800001a8:	982080e7          	jalr	-1662(ra) # 80000b26 <release>

  return target - n;
    800001ac:	413b053b          	subw	a0,s6,s3
    800001b0:	a811                	j	800001c4 <consoleread+0xe4>
        release(&cons.lock);
    800001b2:	00012517          	auipc	a0,0x12
    800001b6:	64e50513          	addi	a0,a0,1614 # 80012800 <cons>
    800001ba:	00001097          	auipc	ra,0x1
    800001be:	96c080e7          	jalr	-1684(ra) # 80000b26 <release>
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
    800001e8:	00012717          	auipc	a4,0x12
    800001ec:	6af72823          	sw	a5,1712(a4) # 80012898 <cons+0x98>
    800001f0:	b775                	j	8000019c <consoleread+0xbc>

00000000800001f2 <consputc>:
  if(panicked){
    800001f2:	0002a797          	auipc	a5,0x2a
    800001f6:	e267a783          	lw	a5,-474(a5) # 8002a018 <panicked>
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
    80000252:	89ae                	mv	s3,a1
    80000254:	84b2                	mv	s1,a2
    80000256:	8ab6                	mv	s5,a3
  acquire(&cons.lock);
    80000258:	00012517          	auipc	a0,0x12
    8000025c:	5a850513          	addi	a0,a0,1448 # 80012800 <cons>
    80000260:	00001097          	auipc	ra,0x1
    80000264:	85e080e7          	jalr	-1954(ra) # 80000abe <acquire>
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
    8000028a:	232080e7          	jalr	562(ra) # 800024b8 <either_copyin>
    8000028e:	01450b63          	beq	a0,s4,800002a4 <consolewrite+0x64>
    consputc(c);
    80000292:	fbf44503          	lbu	a0,-65(s0)
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	f5c080e7          	jalr	-164(ra) # 800001f2 <consputc>
  for(i = 0; i < n; i++){
    8000029e:	0485                	addi	s1,s1,1
    800002a0:	fd249ee3          	bne	s1,s2,8000027c <consolewrite+0x3c>
  release(&cons.lock);
    800002a4:	00012517          	auipc	a0,0x12
    800002a8:	55c50513          	addi	a0,a0,1372 # 80012800 <cons>
    800002ac:	00001097          	auipc	ra,0x1
    800002b0:	87a080e7          	jalr	-1926(ra) # 80000b26 <release>
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
    800002d6:	00012517          	auipc	a0,0x12
    800002da:	52a50513          	addi	a0,a0,1322 # 80012800 <cons>
    800002de:	00000097          	auipc	ra,0x0
    800002e2:	7e0080e7          	jalr	2016(ra) # 80000abe <acquire>

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
    80000300:	212080e7          	jalr	530(ra) # 8000250e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00012517          	auipc	a0,0x12
    80000308:	4fc50513          	addi	a0,a0,1276 # 80012800 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	81a080e7          	jalr	-2022(ra) # 80000b26 <release>
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
    80000328:	00012717          	auipc	a4,0x12
    8000032c:	4d870713          	addi	a4,a4,1240 # 80012800 <cons>
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
    80000352:	00012797          	auipc	a5,0x12
    80000356:	4ae78793          	addi	a5,a5,1198 # 80012800 <cons>
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
    80000380:	00012797          	auipc	a5,0x12
    80000384:	5187a783          	lw	a5,1304(a5) # 80012898 <cons+0x98>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00012717          	auipc	a4,0x12
    80000398:	46c70713          	addi	a4,a4,1132 # 80012800 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a4:	00012497          	auipc	s1,0x12
    800003a8:	45c48493          	addi	s1,s1,1116 # 80012800 <cons>
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
    800003e0:	00012717          	auipc	a4,0x12
    800003e4:	42070713          	addi	a4,a4,1056 # 80012800 <cons>
    800003e8:	0a072783          	lw	a5,160(a4)
    800003ec:	09c72703          	lw	a4,156(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00012717          	auipc	a4,0x12
    800003fa:	4af72523          	sw	a5,1194(a4) # 800128a0 <cons+0xa0>
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
    8000041c:	00012797          	auipc	a5,0x12
    80000420:	3e478793          	addi	a5,a5,996 # 80012800 <cons>
    80000424:	0a07a703          	lw	a4,160(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a023          	sw	a3,160(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000440:	00012797          	auipc	a5,0x12
    80000444:	44c7ae23          	sw	a2,1116(a5) # 8001289c <cons+0x9c>
        wakeup(&cons.r);
    80000448:	00012517          	auipc	a0,0x12
    8000044c:	45050513          	addi	a0,a0,1104 # 80012898 <cons+0x98>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	f38080e7          	jalr	-200(ra) # 80002388 <wakeup>
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
    80000462:	00008597          	auipc	a1,0x8
    80000466:	cb658593          	addi	a1,a1,-842 # 80008118 <userret+0x88>
    8000046a:	00012517          	auipc	a0,0x12
    8000046e:	39650513          	addi	a0,a0,918 # 80012800 <cons>
    80000472:	00000097          	auipc	ra,0x0
    80000476:	53e080e7          	jalr	1342(ra) # 800009b0 <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	32a080e7          	jalr	810(ra) # 800007a4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00023797          	auipc	a5,0x23
    80000486:	86678793          	addi	a5,a5,-1946 # 80022ce8 <devsw>
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
    800004c4:	00008617          	auipc	a2,0x8
    800004c8:	57460613          	addi	a2,a2,1396 # 80008a38 <digits>
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
    80000554:	00012797          	auipc	a5,0x12
    80000558:	3607a623          	sw	zero,876(a5) # 800128c0 <pr+0x18>
  printf("panic: ");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	bc450513          	addi	a0,a0,-1084 # 80008120 <userret+0x90>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	c3a50513          	addi	a0,a0,-966 # 800081b0 <userret+0x120>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
  panicked = 1; // freeze other CPUs
    80000586:	4785                	li	a5,1
    80000588:	0002a717          	auipc	a4,0x2a
    8000058c:	a8f72823          	sw	a5,-1392(a4) # 8002a018 <panicked>
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
    800005c4:	00012d97          	auipc	s11,0x12
    800005c8:	2fcdad83          	lw	s11,764(s11) # 800128c0 <pr+0x18>
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
    800005f0:	00008b17          	auipc	s6,0x8
    800005f4:	448b0b13          	addi	s6,s6,1096 # 80008a38 <digits>
    switch(c){
    800005f8:	07300c93          	li	s9,115
    800005fc:	06400c13          	li	s8,100
    80000600:	a82d                	j	8000063a <printf+0xa8>
    acquire(&pr.lock);
    80000602:	00012517          	auipc	a0,0x12
    80000606:	2a650513          	addi	a0,a0,678 # 800128a8 <pr>
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	4b4080e7          	jalr	1204(ra) # 80000abe <acquire>
    80000612:	bf7d                	j	800005d0 <printf+0x3e>
    panic("null fmt");
    80000614:	00008517          	auipc	a0,0x8
    80000618:	b1c50513          	addi	a0,a0,-1252 # 80008130 <userret+0xa0>
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
    8000070e:	00008497          	auipc	s1,0x8
    80000712:	a1a48493          	addi	s1,s1,-1510 # 80008128 <userret+0x98>
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
    80000760:	00012517          	auipc	a0,0x12
    80000764:	14850513          	addi	a0,a0,328 # 800128a8 <pr>
    80000768:	00000097          	auipc	ra,0x0
    8000076c:	3be080e7          	jalr	958(ra) # 80000b26 <release>
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
    8000077c:	00012497          	auipc	s1,0x12
    80000780:	12c48493          	addi	s1,s1,300 # 800128a8 <pr>
    80000784:	00008597          	auipc	a1,0x8
    80000788:	9bc58593          	addi	a1,a1,-1604 # 80008140 <userret+0xb0>
    8000078c:	8526                	mv	a0,s1
    8000078e:	00000097          	auipc	ra,0x0
    80000792:	222080e7          	jalr	546(ra) # 800009b0 <initlock>
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

0000000080000854 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	e04a                	sd	s2,0(sp)
    8000085e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000860:	03451793          	slli	a5,a0,0x34
    80000864:	ebb9                	bnez	a5,800008ba <kfree+0x66>
    80000866:	84aa                	mv	s1,a0
    80000868:	00029797          	auipc	a5,0x29
    8000086c:	7f478793          	addi	a5,a5,2036 # 8002a05c <end>
    80000870:	04f56563          	bltu	a0,a5,800008ba <kfree+0x66>
    80000874:	47c5                	li	a5,17
    80000876:	07ee                	slli	a5,a5,0x1b
    80000878:	04f57163          	bgeu	a0,a5,800008ba <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    8000087c:	6605                	lui	a2,0x1
    8000087e:	4585                	li	a1,1
    80000880:	00000097          	auipc	ra,0x0
    80000884:	302080e7          	jalr	770(ra) # 80000b82 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000888:	00012917          	auipc	s2,0x12
    8000088c:	04090913          	addi	s2,s2,64 # 800128c8 <kmem>
    80000890:	854a                	mv	a0,s2
    80000892:	00000097          	auipc	ra,0x0
    80000896:	22c080e7          	jalr	556(ra) # 80000abe <acquire>
  r->next = kmem.freelist;
    8000089a:	01893783          	ld	a5,24(s2)
    8000089e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800008a0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    800008a4:	854a                	mv	a0,s2
    800008a6:	00000097          	auipc	ra,0x0
    800008aa:	280080e7          	jalr	640(ra) # 80000b26 <release>
}
    800008ae:	60e2                	ld	ra,24(sp)
    800008b0:	6442                	ld	s0,16(sp)
    800008b2:	64a2                	ld	s1,8(sp)
    800008b4:	6902                	ld	s2,0(sp)
    800008b6:	6105                	addi	sp,sp,32
    800008b8:	8082                	ret
    panic("kfree");
    800008ba:	00008517          	auipc	a0,0x8
    800008be:	88e50513          	addi	a0,a0,-1906 # 80008148 <userret+0xb8>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	c86080e7          	jalr	-890(ra) # 80000548 <panic>

00000000800008ca <freerange>:
{
    800008ca:	7179                	addi	sp,sp,-48
    800008cc:	f406                	sd	ra,40(sp)
    800008ce:	f022                	sd	s0,32(sp)
    800008d0:	ec26                	sd	s1,24(sp)
    800008d2:	e84a                	sd	s2,16(sp)
    800008d4:	e44e                	sd	s3,8(sp)
    800008d6:	e052                	sd	s4,0(sp)
    800008d8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800008da:	6785                	lui	a5,0x1
    800008dc:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800008e0:	94aa                	add	s1,s1,a0
    800008e2:	757d                	lui	a0,0xfffff
    800008e4:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800008e6:	94be                	add	s1,s1,a5
    800008e8:	0095ee63          	bltu	a1,s1,80000904 <freerange+0x3a>
    800008ec:	892e                	mv	s2,a1
    kfree(p);
    800008ee:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800008f0:	6985                	lui	s3,0x1
    kfree(p);
    800008f2:	01448533          	add	a0,s1,s4
    800008f6:	00000097          	auipc	ra,0x0
    800008fa:	f5e080e7          	jalr	-162(ra) # 80000854 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800008fe:	94ce                	add	s1,s1,s3
    80000900:	fe9979e3          	bgeu	s2,s1,800008f2 <freerange+0x28>
}
    80000904:	70a2                	ld	ra,40(sp)
    80000906:	7402                	ld	s0,32(sp)
    80000908:	64e2                	ld	s1,24(sp)
    8000090a:	6942                	ld	s2,16(sp)
    8000090c:	69a2                	ld	s3,8(sp)
    8000090e:	6a02                	ld	s4,0(sp)
    80000910:	6145                	addi	sp,sp,48
    80000912:	8082                	ret

0000000080000914 <kinit>:
{
    80000914:	1141                	addi	sp,sp,-16
    80000916:	e406                	sd	ra,8(sp)
    80000918:	e022                	sd	s0,0(sp)
    8000091a:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    8000091c:	00008597          	auipc	a1,0x8
    80000920:	83458593          	addi	a1,a1,-1996 # 80008150 <userret+0xc0>
    80000924:	00012517          	auipc	a0,0x12
    80000928:	fa450513          	addi	a0,a0,-92 # 800128c8 <kmem>
    8000092c:	00000097          	auipc	ra,0x0
    80000930:	084080e7          	jalr	132(ra) # 800009b0 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000934:	45c5                	li	a1,17
    80000936:	05ee                	slli	a1,a1,0x1b
    80000938:	00029517          	auipc	a0,0x29
    8000093c:	72450513          	addi	a0,a0,1828 # 8002a05c <end>
    80000940:	00000097          	auipc	ra,0x0
    80000944:	f8a080e7          	jalr	-118(ra) # 800008ca <freerange>
}
    80000948:	60a2                	ld	ra,8(sp)
    8000094a:	6402                	ld	s0,0(sp)
    8000094c:	0141                	addi	sp,sp,16
    8000094e:	8082                	ret

0000000080000950 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000950:	1101                	addi	sp,sp,-32
    80000952:	ec06                	sd	ra,24(sp)
    80000954:	e822                	sd	s0,16(sp)
    80000956:	e426                	sd	s1,8(sp)
    80000958:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    8000095a:	00012497          	auipc	s1,0x12
    8000095e:	f6e48493          	addi	s1,s1,-146 # 800128c8 <kmem>
    80000962:	8526                	mv	a0,s1
    80000964:	00000097          	auipc	ra,0x0
    80000968:	15a080e7          	jalr	346(ra) # 80000abe <acquire>
  r = kmem.freelist;
    8000096c:	6c84                	ld	s1,24(s1)
  if(r)
    8000096e:	c885                	beqz	s1,8000099e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000970:	609c                	ld	a5,0(s1)
    80000972:	00012517          	auipc	a0,0x12
    80000976:	f5650513          	addi	a0,a0,-170 # 800128c8 <kmem>
    8000097a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    8000097c:	00000097          	auipc	ra,0x0
    80000980:	1aa080e7          	jalr	426(ra) # 80000b26 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000984:	6605                	lui	a2,0x1
    80000986:	4595                	li	a1,5
    80000988:	8526                	mv	a0,s1
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	1f8080e7          	jalr	504(ra) # 80000b82 <memset>
  return (void*)r;
}
    80000992:	8526                	mv	a0,s1
    80000994:	60e2                	ld	ra,24(sp)
    80000996:	6442                	ld	s0,16(sp)
    80000998:	64a2                	ld	s1,8(sp)
    8000099a:	6105                	addi	sp,sp,32
    8000099c:	8082                	ret
  release(&kmem.lock);
    8000099e:	00012517          	auipc	a0,0x12
    800009a2:	f2a50513          	addi	a0,a0,-214 # 800128c8 <kmem>
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	180080e7          	jalr	384(ra) # 80000b26 <release>
  if(r)
    800009ae:	b7d5                	j	80000992 <kalloc+0x42>

00000000800009b0 <initlock>:

uint64 ntest_and_set;

void
initlock(struct spinlock *lk, char *name)
{
    800009b0:	1141                	addi	sp,sp,-16
    800009b2:	e422                	sd	s0,8(sp)
    800009b4:	0800                	addi	s0,sp,16
  lk->name = name;
    800009b6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800009b8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800009bc:	00053823          	sd	zero,16(a0)
}
    800009c0:	6422                	ld	s0,8(sp)
    800009c2:	0141                	addi	sp,sp,16
    800009c4:	8082                	ret

00000000800009c6 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800009c6:	1101                	addi	sp,sp,-32
    800009c8:	ec06                	sd	ra,24(sp)
    800009ca:	e822                	sd	s0,16(sp)
    800009cc:	e426                	sd	s1,8(sp)
    800009ce:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800009d0:	100024f3          	csrr	s1,sstatus
    800009d4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800009d8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800009da:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800009de:	00001097          	auipc	ra,0x1
    800009e2:	030080e7          	jalr	48(ra) # 80001a0e <mycpu>
    800009e6:	5d3c                	lw	a5,120(a0)
    800009e8:	cf89                	beqz	a5,80000a02 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800009ea:	00001097          	auipc	ra,0x1
    800009ee:	024080e7          	jalr	36(ra) # 80001a0e <mycpu>
    800009f2:	5d3c                	lw	a5,120(a0)
    800009f4:	2785                	addiw	a5,a5,1
    800009f6:	dd3c                	sw	a5,120(a0)
}
    800009f8:	60e2                	ld	ra,24(sp)
    800009fa:	6442                	ld	s0,16(sp)
    800009fc:	64a2                	ld	s1,8(sp)
    800009fe:	6105                	addi	sp,sp,32
    80000a00:	8082                	ret
    mycpu()->intena = old;
    80000a02:	00001097          	auipc	ra,0x1
    80000a06:	00c080e7          	jalr	12(ra) # 80001a0e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000a0a:	8085                	srli	s1,s1,0x1
    80000a0c:	8885                	andi	s1,s1,1
    80000a0e:	dd64                	sw	s1,124(a0)
    80000a10:	bfe9                	j	800009ea <push_off+0x24>

0000000080000a12 <pop_off>:

void
pop_off(void)
{
    80000a12:	1141                	addi	sp,sp,-16
    80000a14:	e406                	sd	ra,8(sp)
    80000a16:	e022                	sd	s0,0(sp)
    80000a18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000a1a:	00001097          	auipc	ra,0x1
    80000a1e:	ff4080e7          	jalr	-12(ra) # 80001a0e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a22:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000a26:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000a28:	eb9d                	bnez	a5,80000a5e <pop_off+0x4c>
    panic("pop_off - interruptible");
  c->noff -= 1;
    80000a2a:	5d3c                	lw	a5,120(a0)
    80000a2c:	37fd                	addiw	a5,a5,-1
    80000a2e:	0007871b          	sext.w	a4,a5
    80000a32:	dd3c                	sw	a5,120(a0)
  if(c->noff < 0)
    80000a34:	02074d63          	bltz	a4,80000a6e <pop_off+0x5c>
    panic("pop_off");
  if(c->noff == 0 && c->intena)
    80000a38:	ef19                	bnez	a4,80000a56 <pop_off+0x44>
    80000a3a:	5d7c                	lw	a5,124(a0)
    80000a3c:	cf89                	beqz	a5,80000a56 <pop_off+0x44>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000a3e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000a42:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000a46:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a4a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000a4e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000a52:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000a56:	60a2                	ld	ra,8(sp)
    80000a58:	6402                	ld	s0,0(sp)
    80000a5a:	0141                	addi	sp,sp,16
    80000a5c:	8082                	ret
    panic("pop_off - interruptible");
    80000a5e:	00007517          	auipc	a0,0x7
    80000a62:	6fa50513          	addi	a0,a0,1786 # 80008158 <userret+0xc8>
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	ae2080e7          	jalr	-1310(ra) # 80000548 <panic>
    panic("pop_off");
    80000a6e:	00007517          	auipc	a0,0x7
    80000a72:	70250513          	addi	a0,a0,1794 # 80008170 <userret+0xe0>
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	ad2080e7          	jalr	-1326(ra) # 80000548 <panic>

0000000080000a7e <holding>:
{
    80000a7e:	1101                	addi	sp,sp,-32
    80000a80:	ec06                	sd	ra,24(sp)
    80000a82:	e822                	sd	s0,16(sp)
    80000a84:	e426                	sd	s1,8(sp)
    80000a86:	1000                	addi	s0,sp,32
    80000a88:	84aa                	mv	s1,a0
  push_off();
    80000a8a:	00000097          	auipc	ra,0x0
    80000a8e:	f3c080e7          	jalr	-196(ra) # 800009c6 <push_off>
  r = (lk->locked && lk->cpu == mycpu());
    80000a92:	409c                	lw	a5,0(s1)
    80000a94:	ef81                	bnez	a5,80000aac <holding+0x2e>
    80000a96:	4481                	li	s1,0
  pop_off();
    80000a98:	00000097          	auipc	ra,0x0
    80000a9c:	f7a080e7          	jalr	-134(ra) # 80000a12 <pop_off>
}
    80000aa0:	8526                	mv	a0,s1
    80000aa2:	60e2                	ld	ra,24(sp)
    80000aa4:	6442                	ld	s0,16(sp)
    80000aa6:	64a2                	ld	s1,8(sp)
    80000aa8:	6105                	addi	sp,sp,32
    80000aaa:	8082                	ret
  r = (lk->locked && lk->cpu == mycpu());
    80000aac:	6884                	ld	s1,16(s1)
    80000aae:	00001097          	auipc	ra,0x1
    80000ab2:	f60080e7          	jalr	-160(ra) # 80001a0e <mycpu>
    80000ab6:	8c89                	sub	s1,s1,a0
    80000ab8:	0014b493          	seqz	s1,s1
    80000abc:	bff1                	j	80000a98 <holding+0x1a>

0000000080000abe <acquire>:
{
    80000abe:	1101                	addi	sp,sp,-32
    80000ac0:	ec06                	sd	ra,24(sp)
    80000ac2:	e822                	sd	s0,16(sp)
    80000ac4:	e426                	sd	s1,8(sp)
    80000ac6:	1000                	addi	s0,sp,32
    80000ac8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000aca:	00000097          	auipc	ra,0x0
    80000ace:	efc080e7          	jalr	-260(ra) # 800009c6 <push_off>
  if(holding(lk))
    80000ad2:	8526                	mv	a0,s1
    80000ad4:	00000097          	auipc	ra,0x0
    80000ad8:	faa080e7          	jalr	-86(ra) # 80000a7e <holding>
    80000adc:	e901                	bnez	a0,80000aec <acquire+0x2e>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000ade:	4685                	li	a3,1
     __sync_fetch_and_add(&ntest_and_set, 1);
    80000ae0:	00029717          	auipc	a4,0x29
    80000ae4:	54070713          	addi	a4,a4,1344 # 8002a020 <ntest_and_set>
    80000ae8:	4605                	li	a2,1
    80000aea:	a829                	j	80000b04 <acquire+0x46>
    panic("acquire");
    80000aec:	00007517          	auipc	a0,0x7
    80000af0:	68c50513          	addi	a0,a0,1676 # 80008178 <userret+0xe8>
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	a54080e7          	jalr	-1452(ra) # 80000548 <panic>
     __sync_fetch_and_add(&ntest_and_set, 1);
    80000afc:	0f50000f          	fence	iorw,ow
    80000b00:	04c7302f          	amoadd.d.aq	zero,a2,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000b04:	87b6                	mv	a5,a3
    80000b06:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b0a:	2781                	sext.w	a5,a5
    80000b0c:	fbe5                	bnez	a5,80000afc <acquire+0x3e>
  __sync_synchronize();
    80000b0e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b12:	00001097          	auipc	ra,0x1
    80000b16:	efc080e7          	jalr	-260(ra) # 80001a0e <mycpu>
    80000b1a:	e888                	sd	a0,16(s1)
}
    80000b1c:	60e2                	ld	ra,24(sp)
    80000b1e:	6442                	ld	s0,16(sp)
    80000b20:	64a2                	ld	s1,8(sp)
    80000b22:	6105                	addi	sp,sp,32
    80000b24:	8082                	ret

0000000080000b26 <release>:
{
    80000b26:	1101                	addi	sp,sp,-32
    80000b28:	ec06                	sd	ra,24(sp)
    80000b2a:	e822                	sd	s0,16(sp)
    80000b2c:	e426                	sd	s1,8(sp)
    80000b2e:	1000                	addi	s0,sp,32
    80000b30:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000b32:	00000097          	auipc	ra,0x0
    80000b36:	f4c080e7          	jalr	-180(ra) # 80000a7e <holding>
    80000b3a:	c115                	beqz	a0,80000b5e <release+0x38>
  lk->cpu = 0;
    80000b3c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000b40:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000b44:	0f50000f          	fence	iorw,ow
    80000b48:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000b4c:	00000097          	auipc	ra,0x0
    80000b50:	ec6080e7          	jalr	-314(ra) # 80000a12 <pop_off>
}
    80000b54:	60e2                	ld	ra,24(sp)
    80000b56:	6442                	ld	s0,16(sp)
    80000b58:	64a2                	ld	s1,8(sp)
    80000b5a:	6105                	addi	sp,sp,32
    80000b5c:	8082                	ret
    panic("release");
    80000b5e:	00007517          	auipc	a0,0x7
    80000b62:	62250513          	addi	a0,a0,1570 # 80008180 <userret+0xf0>
    80000b66:	00000097          	auipc	ra,0x0
    80000b6a:	9e2080e7          	jalr	-1566(ra) # 80000548 <panic>

0000000080000b6e <sys_ntas>:

uint64
sys_ntas(void)
{
    80000b6e:	1141                	addi	sp,sp,-16
    80000b70:	e422                	sd	s0,8(sp)
    80000b72:	0800                	addi	s0,sp,16
  return ntest_and_set;
}
    80000b74:	00029517          	auipc	a0,0x29
    80000b78:	4ac53503          	ld	a0,1196(a0) # 8002a020 <ntest_and_set>
    80000b7c:	6422                	ld	s0,8(sp)
    80000b7e:	0141                	addi	sp,sp,16
    80000b80:	8082                	ret

0000000080000b82 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000b82:	1141                	addi	sp,sp,-16
    80000b84:	e422                	sd	s0,8(sp)
    80000b86:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000b88:	ca19                	beqz	a2,80000b9e <memset+0x1c>
    80000b8a:	87aa                	mv	a5,a0
    80000b8c:	1602                	slli	a2,a2,0x20
    80000b8e:	9201                	srli	a2,a2,0x20
    80000b90:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000b94:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000b98:	0785                	addi	a5,a5,1
    80000b9a:	fee79de3          	bne	a5,a4,80000b94 <memset+0x12>
  }
  return dst;
}
    80000b9e:	6422                	ld	s0,8(sp)
    80000ba0:	0141                	addi	sp,sp,16
    80000ba2:	8082                	ret

0000000080000ba4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ba4:	1141                	addi	sp,sp,-16
    80000ba6:	e422                	sd	s0,8(sp)
    80000ba8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000baa:	ca05                	beqz	a2,80000bda <memcmp+0x36>
    80000bac:	fff6069b          	addiw	a3,a2,-1
    80000bb0:	1682                	slli	a3,a3,0x20
    80000bb2:	9281                	srli	a3,a3,0x20
    80000bb4:	0685                	addi	a3,a3,1
    80000bb6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000bb8:	00054783          	lbu	a5,0(a0)
    80000bbc:	0005c703          	lbu	a4,0(a1)
    80000bc0:	00e79863          	bne	a5,a4,80000bd0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000bc4:	0505                	addi	a0,a0,1
    80000bc6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000bc8:	fed518e3          	bne	a0,a3,80000bb8 <memcmp+0x14>
  }

  return 0;
    80000bcc:	4501                	li	a0,0
    80000bce:	a019                	j	80000bd4 <memcmp+0x30>
      return *s1 - *s2;
    80000bd0:	40e7853b          	subw	a0,a5,a4
}
    80000bd4:	6422                	ld	s0,8(sp)
    80000bd6:	0141                	addi	sp,sp,16
    80000bd8:	8082                	ret
  return 0;
    80000bda:	4501                	li	a0,0
    80000bdc:	bfe5                	j	80000bd4 <memcmp+0x30>

0000000080000bde <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000bde:	1141                	addi	sp,sp,-16
    80000be0:	e422                	sd	s0,8(sp)
    80000be2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000be4:	02a5e563          	bltu	a1,a0,80000c0e <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000be8:	fff6069b          	addiw	a3,a2,-1
    80000bec:	ce11                	beqz	a2,80000c08 <memmove+0x2a>
    80000bee:	1682                	slli	a3,a3,0x20
    80000bf0:	9281                	srli	a3,a3,0x20
    80000bf2:	0685                	addi	a3,a3,1
    80000bf4:	96ae                	add	a3,a3,a1
    80000bf6:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000bf8:	0585                	addi	a1,a1,1
    80000bfa:	0785                	addi	a5,a5,1
    80000bfc:	fff5c703          	lbu	a4,-1(a1)
    80000c00:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000c04:	fed59ae3          	bne	a1,a3,80000bf8 <memmove+0x1a>

  return dst;
}
    80000c08:	6422                	ld	s0,8(sp)
    80000c0a:	0141                	addi	sp,sp,16
    80000c0c:	8082                	ret
  if(s < d && s + n > d){
    80000c0e:	02061713          	slli	a4,a2,0x20
    80000c12:	9301                	srli	a4,a4,0x20
    80000c14:	00e587b3          	add	a5,a1,a4
    80000c18:	fcf578e3          	bgeu	a0,a5,80000be8 <memmove+0xa>
    d += n;
    80000c1c:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000c1e:	fff6069b          	addiw	a3,a2,-1
    80000c22:	d27d                	beqz	a2,80000c08 <memmove+0x2a>
    80000c24:	02069613          	slli	a2,a3,0x20
    80000c28:	9201                	srli	a2,a2,0x20
    80000c2a:	fff64613          	not	a2,a2
    80000c2e:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000c30:	17fd                	addi	a5,a5,-1
    80000c32:	177d                	addi	a4,a4,-1
    80000c34:	0007c683          	lbu	a3,0(a5)
    80000c38:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000c3c:	fef61ae3          	bne	a2,a5,80000c30 <memmove+0x52>
    80000c40:	b7e1                	j	80000c08 <memmove+0x2a>

0000000080000c42 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000c42:	1141                	addi	sp,sp,-16
    80000c44:	e406                	sd	ra,8(sp)
    80000c46:	e022                	sd	s0,0(sp)
    80000c48:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000c4a:	00000097          	auipc	ra,0x0
    80000c4e:	f94080e7          	jalr	-108(ra) # 80000bde <memmove>
}
    80000c52:	60a2                	ld	ra,8(sp)
    80000c54:	6402                	ld	s0,0(sp)
    80000c56:	0141                	addi	sp,sp,16
    80000c58:	8082                	ret

0000000080000c5a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000c5a:	1141                	addi	sp,sp,-16
    80000c5c:	e422                	sd	s0,8(sp)
    80000c5e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000c60:	ce11                	beqz	a2,80000c7c <strncmp+0x22>
    80000c62:	00054783          	lbu	a5,0(a0)
    80000c66:	cf89                	beqz	a5,80000c80 <strncmp+0x26>
    80000c68:	0005c703          	lbu	a4,0(a1)
    80000c6c:	00f71a63          	bne	a4,a5,80000c80 <strncmp+0x26>
    n--, p++, q++;
    80000c70:	367d                	addiw	a2,a2,-1
    80000c72:	0505                	addi	a0,a0,1
    80000c74:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000c76:	f675                	bnez	a2,80000c62 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000c78:	4501                	li	a0,0
    80000c7a:	a809                	j	80000c8c <strncmp+0x32>
    80000c7c:	4501                	li	a0,0
    80000c7e:	a039                	j	80000c8c <strncmp+0x32>
  if(n == 0)
    80000c80:	ca09                	beqz	a2,80000c92 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000c82:	00054503          	lbu	a0,0(a0)
    80000c86:	0005c783          	lbu	a5,0(a1)
    80000c8a:	9d1d                	subw	a0,a0,a5
}
    80000c8c:	6422                	ld	s0,8(sp)
    80000c8e:	0141                	addi	sp,sp,16
    80000c90:	8082                	ret
    return 0;
    80000c92:	4501                	li	a0,0
    80000c94:	bfe5                	j	80000c8c <strncmp+0x32>

0000000080000c96 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000c96:	1141                	addi	sp,sp,-16
    80000c98:	e422                	sd	s0,8(sp)
    80000c9a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000c9c:	872a                	mv	a4,a0
    80000c9e:	8832                	mv	a6,a2
    80000ca0:	367d                	addiw	a2,a2,-1
    80000ca2:	01005963          	blez	a6,80000cb4 <strncpy+0x1e>
    80000ca6:	0705                	addi	a4,a4,1
    80000ca8:	0005c783          	lbu	a5,0(a1)
    80000cac:	fef70fa3          	sb	a5,-1(a4)
    80000cb0:	0585                	addi	a1,a1,1
    80000cb2:	f7f5                	bnez	a5,80000c9e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000cb4:	86ba                	mv	a3,a4
    80000cb6:	00c05c63          	blez	a2,80000cce <strncpy+0x38>
    *s++ = 0;
    80000cba:	0685                	addi	a3,a3,1
    80000cbc:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000cc0:	fff6c793          	not	a5,a3
    80000cc4:	9fb9                	addw	a5,a5,a4
    80000cc6:	010787bb          	addw	a5,a5,a6
    80000cca:	fef048e3          	bgtz	a5,80000cba <strncpy+0x24>
  return os;
}
    80000cce:	6422                	ld	s0,8(sp)
    80000cd0:	0141                	addi	sp,sp,16
    80000cd2:	8082                	ret

0000000080000cd4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000cd4:	1141                	addi	sp,sp,-16
    80000cd6:	e422                	sd	s0,8(sp)
    80000cd8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000cda:	02c05363          	blez	a2,80000d00 <safestrcpy+0x2c>
    80000cde:	fff6069b          	addiw	a3,a2,-1
    80000ce2:	1682                	slli	a3,a3,0x20
    80000ce4:	9281                	srli	a3,a3,0x20
    80000ce6:	96ae                	add	a3,a3,a1
    80000ce8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000cea:	00d58963          	beq	a1,a3,80000cfc <safestrcpy+0x28>
    80000cee:	0585                	addi	a1,a1,1
    80000cf0:	0785                	addi	a5,a5,1
    80000cf2:	fff5c703          	lbu	a4,-1(a1)
    80000cf6:	fee78fa3          	sb	a4,-1(a5)
    80000cfa:	fb65                	bnez	a4,80000cea <safestrcpy+0x16>
    ;
  *s = 0;
    80000cfc:	00078023          	sb	zero,0(a5)
  return os;
}
    80000d00:	6422                	ld	s0,8(sp)
    80000d02:	0141                	addi	sp,sp,16
    80000d04:	8082                	ret

0000000080000d06 <strlen>:

int
strlen(const char *s)
{
    80000d06:	1141                	addi	sp,sp,-16
    80000d08:	e422                	sd	s0,8(sp)
    80000d0a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000d0c:	00054783          	lbu	a5,0(a0)
    80000d10:	cf91                	beqz	a5,80000d2c <strlen+0x26>
    80000d12:	0505                	addi	a0,a0,1
    80000d14:	87aa                	mv	a5,a0
    80000d16:	4685                	li	a3,1
    80000d18:	9e89                	subw	a3,a3,a0
    80000d1a:	00f6853b          	addw	a0,a3,a5
    80000d1e:	0785                	addi	a5,a5,1
    80000d20:	fff7c703          	lbu	a4,-1(a5)
    80000d24:	fb7d                	bnez	a4,80000d1a <strlen+0x14>
    ;
  return n;
}
    80000d26:	6422                	ld	s0,8(sp)
    80000d28:	0141                	addi	sp,sp,16
    80000d2a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000d2c:	4501                	li	a0,0
    80000d2e:	bfe5                	j	80000d26 <strlen+0x20>

0000000080000d30 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000d30:	1141                	addi	sp,sp,-16
    80000d32:	e406                	sd	ra,8(sp)
    80000d34:	e022                	sd	s0,0(sp)
    80000d36:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000d38:	00001097          	auipc	ra,0x1
    80000d3c:	cc6080e7          	jalr	-826(ra) # 800019fe <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000d40:	00029717          	auipc	a4,0x29
    80000d44:	2e870713          	addi	a4,a4,744 # 8002a028 <started>
  if(cpuid() == 0){
    80000d48:	c139                	beqz	a0,80000d8e <main+0x5e>
    while(started == 0)
    80000d4a:	431c                	lw	a5,0(a4)
    80000d4c:	2781                	sext.w	a5,a5
    80000d4e:	dff5                	beqz	a5,80000d4a <main+0x1a>
      ;
    __sync_synchronize();
    80000d50:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000d54:	00001097          	auipc	ra,0x1
    80000d58:	caa080e7          	jalr	-854(ra) # 800019fe <cpuid>
    80000d5c:	85aa                	mv	a1,a0
    80000d5e:	00007517          	auipc	a0,0x7
    80000d62:	44250513          	addi	a0,a0,1090 # 800081a0 <userret+0x110>
    80000d66:	00000097          	auipc	ra,0x0
    80000d6a:	82c080e7          	jalr	-2004(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80000d6e:	00000097          	auipc	ra,0x0
    80000d72:	1ea080e7          	jalr	490(ra) # 80000f58 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000d76:	00002097          	auipc	ra,0x2
    80000d7a:	8d8080e7          	jalr	-1832(ra) # 8000264e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000d7e:	00005097          	auipc	ra,0x5
    80000d82:	1e2080e7          	jalr	482(ra) # 80005f60 <plicinithart>
  }

  scheduler();        
    80000d86:	00001097          	auipc	ra,0x1
    80000d8a:	18a080e7          	jalr	394(ra) # 80001f10 <scheduler>
    consoleinit();
    80000d8e:	fffff097          	auipc	ra,0xfffff
    80000d92:	6cc080e7          	jalr	1740(ra) # 8000045a <consoleinit>
    printfinit();
    80000d96:	00000097          	auipc	ra,0x0
    80000d9a:	9dc080e7          	jalr	-1572(ra) # 80000772 <printfinit>
    printf("\n");
    80000d9e:	00007517          	auipc	a0,0x7
    80000da2:	41250513          	addi	a0,a0,1042 # 800081b0 <userret+0x120>
    80000da6:	fffff097          	auipc	ra,0xfffff
    80000daa:	7ec080e7          	jalr	2028(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    80000dae:	00007517          	auipc	a0,0x7
    80000db2:	3da50513          	addi	a0,a0,986 # 80008188 <userret+0xf8>
    80000db6:	fffff097          	auipc	ra,0xfffff
    80000dba:	7dc080e7          	jalr	2012(ra) # 80000592 <printf>
    printf("\n");
    80000dbe:	00007517          	auipc	a0,0x7
    80000dc2:	3f250513          	addi	a0,a0,1010 # 800081b0 <userret+0x120>
    80000dc6:	fffff097          	auipc	ra,0xfffff
    80000dca:	7cc080e7          	jalr	1996(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    80000dce:	00000097          	auipc	ra,0x0
    80000dd2:	b46080e7          	jalr	-1210(ra) # 80000914 <kinit>
    kvminit();       // create kernel page table
    80000dd6:	00000097          	auipc	ra,0x0
    80000dda:	30c080e7          	jalr	780(ra) # 800010e2 <kvminit>
    kvminithart();   // turn on paging
    80000dde:	00000097          	auipc	ra,0x0
    80000de2:	17a080e7          	jalr	378(ra) # 80000f58 <kvminithart>
    procinit();      // process table
    80000de6:	00001097          	auipc	ra,0x1
    80000dea:	b48080e7          	jalr	-1208(ra) # 8000192e <procinit>
    trapinit();      // trap vectors
    80000dee:	00002097          	auipc	ra,0x2
    80000df2:	838080e7          	jalr	-1992(ra) # 80002626 <trapinit>
    trapinithart();  // install kernel trap vector
    80000df6:	00002097          	auipc	ra,0x2
    80000dfa:	858080e7          	jalr	-1960(ra) # 8000264e <trapinithart>
    plicinit();      // set up interrupt controller
    80000dfe:	00005097          	auipc	ra,0x5
    80000e02:	14c080e7          	jalr	332(ra) # 80005f4a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e06:	00005097          	auipc	ra,0x5
    80000e0a:	15a080e7          	jalr	346(ra) # 80005f60 <plicinithart>
    binit();         // buffer cache
    80000e0e:	00002097          	auipc	ra,0x2
    80000e12:	ff4080e7          	jalr	-12(ra) # 80002e02 <binit>
    iinit();         // inode cache
    80000e16:	00002097          	auipc	ra,0x2
    80000e1a:	688080e7          	jalr	1672(ra) # 8000349e <iinit>
    fileinit();      // file table
    80000e1e:	00004097          	auipc	ra,0x4
    80000e22:	862080e7          	jalr	-1950(ra) # 80004680 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80000e26:	4501                	li	a0,0
    80000e28:	00005097          	auipc	ra,0x5
    80000e2c:	26c080e7          	jalr	620(ra) # 80006094 <virtio_disk_init>
    userinit();      // first user process
    80000e30:	00001097          	auipc	ra,0x1
    80000e34:	e6e080e7          	jalr	-402(ra) # 80001c9e <userinit>
    __sync_synchronize();
    80000e38:	0ff0000f          	fence
    started = 1;
    80000e3c:	4785                	li	a5,1
    80000e3e:	00029717          	auipc	a4,0x29
    80000e42:	1ef72523          	sw	a5,490(a4) # 8002a028 <started>
    80000e46:	b781                	j	80000d86 <main+0x56>

0000000080000e48 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000e48:	7139                	addi	sp,sp,-64
    80000e4a:	fc06                	sd	ra,56(sp)
    80000e4c:	f822                	sd	s0,48(sp)
    80000e4e:	f426                	sd	s1,40(sp)
    80000e50:	f04a                	sd	s2,32(sp)
    80000e52:	ec4e                	sd	s3,24(sp)
    80000e54:	e852                	sd	s4,16(sp)
    80000e56:	e456                	sd	s5,8(sp)
    80000e58:	e05a                	sd	s6,0(sp)
    80000e5a:	0080                	addi	s0,sp,64
    80000e5c:	84aa                	mv	s1,a0
    80000e5e:	89ae                	mv	s3,a1
    80000e60:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000e62:	57fd                	li	a5,-1
    80000e64:	83e9                	srli	a5,a5,0x1a
    80000e66:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000e68:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000e6a:	04b7f263          	bgeu	a5,a1,80000eae <walk+0x66>
    panic("walk");
    80000e6e:	00007517          	auipc	a0,0x7
    80000e72:	34a50513          	addi	a0,a0,842 # 800081b8 <userret+0x128>
    80000e76:	fffff097          	auipc	ra,0xfffff
    80000e7a:	6d2080e7          	jalr	1746(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000e7e:	060a8663          	beqz	s5,80000eea <walk+0xa2>
    80000e82:	00000097          	auipc	ra,0x0
    80000e86:	ace080e7          	jalr	-1330(ra) # 80000950 <kalloc>
    80000e8a:	84aa                	mv	s1,a0
    80000e8c:	c529                	beqz	a0,80000ed6 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000e8e:	6605                	lui	a2,0x1
    80000e90:	4581                	li	a1,0
    80000e92:	00000097          	auipc	ra,0x0
    80000e96:	cf0080e7          	jalr	-784(ra) # 80000b82 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000e9a:	00c4d793          	srli	a5,s1,0xc
    80000e9e:	07aa                	slli	a5,a5,0xa
    80000ea0:	0017e793          	ori	a5,a5,1
    80000ea4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000ea8:	3a5d                	addiw	s4,s4,-9
    80000eaa:	036a0063          	beq	s4,s6,80000eca <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80000eae:	0149d933          	srl	s2,s3,s4
    80000eb2:	1ff97913          	andi	s2,s2,511
    80000eb6:	090e                	slli	s2,s2,0x3
    80000eb8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000eba:	00093483          	ld	s1,0(s2)
    80000ebe:	0014f793          	andi	a5,s1,1
    80000ec2:	dfd5                	beqz	a5,80000e7e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000ec4:	80a9                	srli	s1,s1,0xa
    80000ec6:	04b2                	slli	s1,s1,0xc
    80000ec8:	b7c5                	j	80000ea8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80000eca:	00c9d513          	srli	a0,s3,0xc
    80000ece:	1ff57513          	andi	a0,a0,511
    80000ed2:	050e                	slli	a0,a0,0x3
    80000ed4:	9526                	add	a0,a0,s1
}
    80000ed6:	70e2                	ld	ra,56(sp)
    80000ed8:	7442                	ld	s0,48(sp)
    80000eda:	74a2                	ld	s1,40(sp)
    80000edc:	7902                	ld	s2,32(sp)
    80000ede:	69e2                	ld	s3,24(sp)
    80000ee0:	6a42                	ld	s4,16(sp)
    80000ee2:	6aa2                	ld	s5,8(sp)
    80000ee4:	6b02                	ld	s6,0(sp)
    80000ee6:	6121                	addi	sp,sp,64
    80000ee8:	8082                	ret
        return 0;
    80000eea:	4501                	li	a0,0
    80000eec:	b7ed                	j	80000ed6 <walk+0x8e>

0000000080000eee <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    80000eee:	7179                	addi	sp,sp,-48
    80000ef0:	f406                	sd	ra,40(sp)
    80000ef2:	f022                	sd	s0,32(sp)
    80000ef4:	ec26                	sd	s1,24(sp)
    80000ef6:	e84a                	sd	s2,16(sp)
    80000ef8:	e44e                	sd	s3,8(sp)
    80000efa:	e052                	sd	s4,0(sp)
    80000efc:	1800                	addi	s0,sp,48
    80000efe:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000f00:	84aa                	mv	s1,a0
    80000f02:	6905                	lui	s2,0x1
    80000f04:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000f06:	4985                	li	s3,1
    80000f08:	a821                	j	80000f20 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000f0a:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000f0c:	0532                	slli	a0,a0,0xc
    80000f0e:	00000097          	auipc	ra,0x0
    80000f12:	fe0080e7          	jalr	-32(ra) # 80000eee <freewalk>
      pagetable[i] = 0;
    80000f16:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000f1a:	04a1                	addi	s1,s1,8
    80000f1c:	03248163          	beq	s1,s2,80000f3e <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000f20:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000f22:	00f57793          	andi	a5,a0,15
    80000f26:	ff3782e3          	beq	a5,s3,80000f0a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000f2a:	8905                	andi	a0,a0,1
    80000f2c:	d57d                	beqz	a0,80000f1a <freewalk+0x2c>
      panic("freewalk: leaf");
    80000f2e:	00007517          	auipc	a0,0x7
    80000f32:	29250513          	addi	a0,a0,658 # 800081c0 <userret+0x130>
    80000f36:	fffff097          	auipc	ra,0xfffff
    80000f3a:	612080e7          	jalr	1554(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    80000f3e:	8552                	mv	a0,s4
    80000f40:	00000097          	auipc	ra,0x0
    80000f44:	914080e7          	jalr	-1772(ra) # 80000854 <kfree>
}
    80000f48:	70a2                	ld	ra,40(sp)
    80000f4a:	7402                	ld	s0,32(sp)
    80000f4c:	64e2                	ld	s1,24(sp)
    80000f4e:	6942                	ld	s2,16(sp)
    80000f50:	69a2                	ld	s3,8(sp)
    80000f52:	6a02                	ld	s4,0(sp)
    80000f54:	6145                	addi	sp,sp,48
    80000f56:	8082                	ret

0000000080000f58 <kvminithart>:
{
    80000f58:	1141                	addi	sp,sp,-16
    80000f5a:	e422                	sd	s0,8(sp)
    80000f5c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f5e:	00029797          	auipc	a5,0x29
    80000f62:	0d27b783          	ld	a5,210(a5) # 8002a030 <kernel_pagetable>
    80000f66:	83b1                	srli	a5,a5,0xc
    80000f68:	577d                	li	a4,-1
    80000f6a:	177e                	slli	a4,a4,0x3f
    80000f6c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f6e:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f72:	12000073          	sfence.vma
}
    80000f76:	6422                	ld	s0,8(sp)
    80000f78:	0141                	addi	sp,sp,16
    80000f7a:	8082                	ret

0000000080000f7c <walkaddr>:
  if(va >= MAXVA)
    80000f7c:	57fd                	li	a5,-1
    80000f7e:	83e9                	srli	a5,a5,0x1a
    80000f80:	00b7f463          	bgeu	a5,a1,80000f88 <walkaddr+0xc>
    return 0;
    80000f84:	4501                	li	a0,0
}
    80000f86:	8082                	ret
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e406                	sd	ra,8(sp)
    80000f8c:	e022                	sd	s0,0(sp)
    80000f8e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f90:	4601                	li	a2,0
    80000f92:	00000097          	auipc	ra,0x0
    80000f96:	eb6080e7          	jalr	-330(ra) # 80000e48 <walk>
  if(pte == 0)
    80000f9a:	c105                	beqz	a0,80000fba <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80000f9c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000f9e:	0117f693          	andi	a3,a5,17
    80000fa2:	4745                	li	a4,17
    return 0;
    80000fa4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fa6:	00e68663          	beq	a3,a4,80000fb2 <walkaddr+0x36>
}
    80000faa:	60a2                	ld	ra,8(sp)
    80000fac:	6402                	ld	s0,0(sp)
    80000fae:	0141                	addi	sp,sp,16
    80000fb0:	8082                	ret
  pa = PTE2PA(*pte);
    80000fb2:	00a7d513          	srli	a0,a5,0xa
    80000fb6:	0532                	slli	a0,a0,0xc
  return pa;
    80000fb8:	bfcd                	j	80000faa <walkaddr+0x2e>
    return 0;
    80000fba:	4501                	li	a0,0
    80000fbc:	b7fd                	j	80000faa <walkaddr+0x2e>

0000000080000fbe <kvmpa>:
{
    80000fbe:	1101                	addi	sp,sp,-32
    80000fc0:	ec06                	sd	ra,24(sp)
    80000fc2:	e822                	sd	s0,16(sp)
    80000fc4:	e426                	sd	s1,8(sp)
    80000fc6:	1000                	addi	s0,sp,32
    80000fc8:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80000fca:	1552                	slli	a0,a0,0x34
    80000fcc:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    80000fd0:	4601                	li	a2,0
    80000fd2:	00029517          	auipc	a0,0x29
    80000fd6:	05e53503          	ld	a0,94(a0) # 8002a030 <kernel_pagetable>
    80000fda:	00000097          	auipc	ra,0x0
    80000fde:	e6e080e7          	jalr	-402(ra) # 80000e48 <walk>
  if(pte == 0)
    80000fe2:	cd09                	beqz	a0,80000ffc <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    80000fe4:	6108                	ld	a0,0(a0)
    80000fe6:	00157793          	andi	a5,a0,1
    80000fea:	c38d                	beqz	a5,8000100c <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    80000fec:	8129                	srli	a0,a0,0xa
    80000fee:	0532                	slli	a0,a0,0xc
}
    80000ff0:	9526                	add	a0,a0,s1
    80000ff2:	60e2                	ld	ra,24(sp)
    80000ff4:	6442                	ld	s0,16(sp)
    80000ff6:	64a2                	ld	s1,8(sp)
    80000ff8:	6105                	addi	sp,sp,32
    80000ffa:	8082                	ret
    panic("kvmpa");
    80000ffc:	00007517          	auipc	a0,0x7
    80001000:	1d450513          	addi	a0,a0,468 # 800081d0 <userret+0x140>
    80001004:	fffff097          	auipc	ra,0xfffff
    80001008:	544080e7          	jalr	1348(ra) # 80000548 <panic>
    panic("kvmpa");
    8000100c:	00007517          	auipc	a0,0x7
    80001010:	1c450513          	addi	a0,a0,452 # 800081d0 <userret+0x140>
    80001014:	fffff097          	auipc	ra,0xfffff
    80001018:	534080e7          	jalr	1332(ra) # 80000548 <panic>

000000008000101c <mappages>:
{
    8000101c:	715d                	addi	sp,sp,-80
    8000101e:	e486                	sd	ra,72(sp)
    80001020:	e0a2                	sd	s0,64(sp)
    80001022:	fc26                	sd	s1,56(sp)
    80001024:	f84a                	sd	s2,48(sp)
    80001026:	f44e                	sd	s3,40(sp)
    80001028:	f052                	sd	s4,32(sp)
    8000102a:	ec56                	sd	s5,24(sp)
    8000102c:	e85a                	sd	s6,16(sp)
    8000102e:	e45e                	sd	s7,8(sp)
    80001030:	0880                	addi	s0,sp,80
    80001032:	8aaa                	mv	s5,a0
    80001034:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    80001036:	777d                	lui	a4,0xfffff
    80001038:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000103c:	167d                	addi	a2,a2,-1
    8000103e:	00b609b3          	add	s3,a2,a1
    80001042:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001046:	893e                	mv	s2,a5
    80001048:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    8000104c:	6b85                	lui	s7,0x1
    8000104e:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001052:	4605                	li	a2,1
    80001054:	85ca                	mv	a1,s2
    80001056:	8556                	mv	a0,s5
    80001058:	00000097          	auipc	ra,0x0
    8000105c:	df0080e7          	jalr	-528(ra) # 80000e48 <walk>
    80001060:	c51d                	beqz	a0,8000108e <mappages+0x72>
    if(*pte & PTE_V)
    80001062:	611c                	ld	a5,0(a0)
    80001064:	8b85                	andi	a5,a5,1
    80001066:	ef81                	bnez	a5,8000107e <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001068:	80b1                	srli	s1,s1,0xc
    8000106a:	04aa                	slli	s1,s1,0xa
    8000106c:	0164e4b3          	or	s1,s1,s6
    80001070:	0014e493          	ori	s1,s1,1
    80001074:	e104                	sd	s1,0(a0)
    if(a == last)
    80001076:	03390863          	beq	s2,s3,800010a6 <mappages+0x8a>
    a += PGSIZE;
    8000107a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000107c:	bfc9                	j	8000104e <mappages+0x32>
      panic("remap");
    8000107e:	00007517          	auipc	a0,0x7
    80001082:	15a50513          	addi	a0,a0,346 # 800081d8 <userret+0x148>
    80001086:	fffff097          	auipc	ra,0xfffff
    8000108a:	4c2080e7          	jalr	1218(ra) # 80000548 <panic>
      return -1;
    8000108e:	557d                	li	a0,-1
}
    80001090:	60a6                	ld	ra,72(sp)
    80001092:	6406                	ld	s0,64(sp)
    80001094:	74e2                	ld	s1,56(sp)
    80001096:	7942                	ld	s2,48(sp)
    80001098:	79a2                	ld	s3,40(sp)
    8000109a:	7a02                	ld	s4,32(sp)
    8000109c:	6ae2                	ld	s5,24(sp)
    8000109e:	6b42                	ld	s6,16(sp)
    800010a0:	6ba2                	ld	s7,8(sp)
    800010a2:	6161                	addi	sp,sp,80
    800010a4:	8082                	ret
  return 0;
    800010a6:	4501                	li	a0,0
    800010a8:	b7e5                	j	80001090 <mappages+0x74>

00000000800010aa <kvmmap>:
{
    800010aa:	1141                	addi	sp,sp,-16
    800010ac:	e406                	sd	ra,8(sp)
    800010ae:	e022                	sd	s0,0(sp)
    800010b0:	0800                	addi	s0,sp,16
    800010b2:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800010b4:	86ae                	mv	a3,a1
    800010b6:	85aa                	mv	a1,a0
    800010b8:	00029517          	auipc	a0,0x29
    800010bc:	f7853503          	ld	a0,-136(a0) # 8002a030 <kernel_pagetable>
    800010c0:	00000097          	auipc	ra,0x0
    800010c4:	f5c080e7          	jalr	-164(ra) # 8000101c <mappages>
    800010c8:	e509                	bnez	a0,800010d2 <kvmmap+0x28>
}
    800010ca:	60a2                	ld	ra,8(sp)
    800010cc:	6402                	ld	s0,0(sp)
    800010ce:	0141                	addi	sp,sp,16
    800010d0:	8082                	ret
    panic("kvmmap");
    800010d2:	00007517          	auipc	a0,0x7
    800010d6:	10e50513          	addi	a0,a0,270 # 800081e0 <userret+0x150>
    800010da:	fffff097          	auipc	ra,0xfffff
    800010de:	46e080e7          	jalr	1134(ra) # 80000548 <panic>

00000000800010e2 <kvminit>:
{
    800010e2:	1101                	addi	sp,sp,-32
    800010e4:	ec06                	sd	ra,24(sp)
    800010e6:	e822                	sd	s0,16(sp)
    800010e8:	e426                	sd	s1,8(sp)
    800010ea:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800010ec:	00000097          	auipc	ra,0x0
    800010f0:	864080e7          	jalr	-1948(ra) # 80000950 <kalloc>
    800010f4:	00029797          	auipc	a5,0x29
    800010f8:	f2a7be23          	sd	a0,-196(a5) # 8002a030 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800010fc:	6605                	lui	a2,0x1
    800010fe:	4581                	li	a1,0
    80001100:	00000097          	auipc	ra,0x0
    80001104:	a82080e7          	jalr	-1406(ra) # 80000b82 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001108:	4699                	li	a3,6
    8000110a:	6605                	lui	a2,0x1
    8000110c:	100005b7          	lui	a1,0x10000
    80001110:	10000537          	lui	a0,0x10000
    80001114:	00000097          	auipc	ra,0x0
    80001118:	f96080e7          	jalr	-106(ra) # 800010aa <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    8000111c:	4699                	li	a3,6
    8000111e:	6605                	lui	a2,0x1
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	10001537          	lui	a0,0x10001
    80001128:	00000097          	auipc	ra,0x0
    8000112c:	f82080e7          	jalr	-126(ra) # 800010aa <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    80001130:	4699                	li	a3,6
    80001132:	6605                	lui	a2,0x1
    80001134:	100025b7          	lui	a1,0x10002
    80001138:	10002537          	lui	a0,0x10002
    8000113c:	00000097          	auipc	ra,0x0
    80001140:	f6e080e7          	jalr	-146(ra) # 800010aa <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001144:	4699                	li	a3,6
    80001146:	6641                	lui	a2,0x10
    80001148:	020005b7          	lui	a1,0x2000
    8000114c:	02000537          	lui	a0,0x2000
    80001150:	00000097          	auipc	ra,0x0
    80001154:	f5a080e7          	jalr	-166(ra) # 800010aa <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001158:	4699                	li	a3,6
    8000115a:	00400637          	lui	a2,0x400
    8000115e:	0c0005b7          	lui	a1,0xc000
    80001162:	0c000537          	lui	a0,0xc000
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	f44080e7          	jalr	-188(ra) # 800010aa <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000116e:	00008497          	auipc	s1,0x8
    80001172:	e9248493          	addi	s1,s1,-366 # 80009000 <initcode>
    80001176:	46a9                	li	a3,10
    80001178:	80008617          	auipc	a2,0x80008
    8000117c:	e8860613          	addi	a2,a2,-376 # 9000 <_entry-0x7fff7000>
    80001180:	4585                	li	a1,1
    80001182:	05fe                	slli	a1,a1,0x1f
    80001184:	852e                	mv	a0,a1
    80001186:	00000097          	auipc	ra,0x0
    8000118a:	f24080e7          	jalr	-220(ra) # 800010aa <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000118e:	4699                	li	a3,6
    80001190:	4645                	li	a2,17
    80001192:	066e                	slli	a2,a2,0x1b
    80001194:	8e05                	sub	a2,a2,s1
    80001196:	85a6                	mv	a1,s1
    80001198:	8526                	mv	a0,s1
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	f10080e7          	jalr	-240(ra) # 800010aa <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011a2:	46a9                	li	a3,10
    800011a4:	6605                	lui	a2,0x1
    800011a6:	00007597          	auipc	a1,0x7
    800011aa:	e5a58593          	addi	a1,a1,-422 # 80008000 <trampoline>
    800011ae:	04000537          	lui	a0,0x4000
    800011b2:	157d                	addi	a0,a0,-1
    800011b4:	0532                	slli	a0,a0,0xc
    800011b6:	00000097          	auipc	ra,0x0
    800011ba:	ef4080e7          	jalr	-268(ra) # 800010aa <kvmmap>
}
    800011be:	60e2                	ld	ra,24(sp)
    800011c0:	6442                	ld	s0,16(sp)
    800011c2:	64a2                	ld	s1,8(sp)
    800011c4:	6105                	addi	sp,sp,32
    800011c6:	8082                	ret

00000000800011c8 <uvmunmap>:
{
    800011c8:	715d                	addi	sp,sp,-80
    800011ca:	e486                	sd	ra,72(sp)
    800011cc:	e0a2                	sd	s0,64(sp)
    800011ce:	fc26                	sd	s1,56(sp)
    800011d0:	f84a                	sd	s2,48(sp)
    800011d2:	f44e                	sd	s3,40(sp)
    800011d4:	f052                	sd	s4,32(sp)
    800011d6:	ec56                	sd	s5,24(sp)
    800011d8:	e85a                	sd	s6,16(sp)
    800011da:	e45e                	sd	s7,8(sp)
    800011dc:	0880                	addi	s0,sp,80
    800011de:	8a2a                	mv	s4,a0
    800011e0:	8b36                	mv	s6,a3
  a = PGROUNDDOWN(va);
    800011e2:	77fd                	lui	a5,0xfffff
    800011e4:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800011e8:	167d                	addi	a2,a2,-1
    800011ea:	00b609b3          	add	s3,a2,a1
    800011ee:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    800011f2:	4b85                	li	s7,1
    a += PGSIZE;
    800011f4:	6a85                	lui	s5,0x1
    800011f6:	a831                	j	80001212 <uvmunmap+0x4a>
      panic("uvmunmap: not a leaf");
    800011f8:	00007517          	auipc	a0,0x7
    800011fc:	ff050513          	addi	a0,a0,-16 # 800081e8 <userret+0x158>
    80001200:	fffff097          	auipc	ra,0xfffff
    80001204:	348080e7          	jalr	840(ra) # 80000548 <panic>
    *pte = 0;
    80001208:	0004b023          	sd	zero,0(s1)
    if(a == last)
    8000120c:	03390e63          	beq	s2,s3,80001248 <uvmunmap+0x80>
    a += PGSIZE;
    80001210:	9956                	add	s2,s2,s5
    if((pte = walk(pagetable, a, 0)) == 0)
    80001212:	4601                	li	a2,0
    80001214:	85ca                	mv	a1,s2
    80001216:	8552                	mv	a0,s4
    80001218:	00000097          	auipc	ra,0x0
    8000121c:	c30080e7          	jalr	-976(ra) # 80000e48 <walk>
    80001220:	84aa                	mv	s1,a0
    80001222:	d56d                	beqz	a0,8000120c <uvmunmap+0x44>
    if((*pte & PTE_V) == 0){
    80001224:	611c                	ld	a5,0(a0)
    80001226:	0017f713          	andi	a4,a5,1
    8000122a:	d36d                	beqz	a4,8000120c <uvmunmap+0x44>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000122c:	3ff7f713          	andi	a4,a5,1023
    80001230:	fd7704e3          	beq	a4,s7,800011f8 <uvmunmap+0x30>
    if(do_free){
    80001234:	fc0b0ae3          	beqz	s6,80001208 <uvmunmap+0x40>
      pa = PTE2PA(*pte);
    80001238:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000123a:	00c79513          	slli	a0,a5,0xc
    8000123e:	fffff097          	auipc	ra,0xfffff
    80001242:	616080e7          	jalr	1558(ra) # 80000854 <kfree>
    80001246:	b7c9                	j	80001208 <uvmunmap+0x40>
}
    80001248:	60a6                	ld	ra,72(sp)
    8000124a:	6406                	ld	s0,64(sp)
    8000124c:	74e2                	ld	s1,56(sp)
    8000124e:	7942                	ld	s2,48(sp)
    80001250:	79a2                	ld	s3,40(sp)
    80001252:	7a02                	ld	s4,32(sp)
    80001254:	6ae2                	ld	s5,24(sp)
    80001256:	6b42                	ld	s6,16(sp)
    80001258:	6ba2                	ld	s7,8(sp)
    8000125a:	6161                	addi	sp,sp,80
    8000125c:	8082                	ret

000000008000125e <uvmcreate>:
{
    8000125e:	1101                	addi	sp,sp,-32
    80001260:	ec06                	sd	ra,24(sp)
    80001262:	e822                	sd	s0,16(sp)
    80001264:	e426                	sd	s1,8(sp)
    80001266:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    80001268:	fffff097          	auipc	ra,0xfffff
    8000126c:	6e8080e7          	jalr	1768(ra) # 80000950 <kalloc>
  if(pagetable == 0)
    80001270:	cd11                	beqz	a0,8000128c <uvmcreate+0x2e>
    80001272:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    80001274:	6605                	lui	a2,0x1
    80001276:	4581                	li	a1,0
    80001278:	00000097          	auipc	ra,0x0
    8000127c:	90a080e7          	jalr	-1782(ra) # 80000b82 <memset>
}
    80001280:	8526                	mv	a0,s1
    80001282:	60e2                	ld	ra,24(sp)
    80001284:	6442                	ld	s0,16(sp)
    80001286:	64a2                	ld	s1,8(sp)
    80001288:	6105                	addi	sp,sp,32
    8000128a:	8082                	ret
    panic("uvmcreate: out of memory");
    8000128c:	00007517          	auipc	a0,0x7
    80001290:	f7450513          	addi	a0,a0,-140 # 80008200 <userret+0x170>
    80001294:	fffff097          	auipc	ra,0xfffff
    80001298:	2b4080e7          	jalr	692(ra) # 80000548 <panic>

000000008000129c <uvminit>:
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67863          	bgeu	a2,a5,800012fe <uvminit+0x62>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
  mem = kalloc();
    800012b8:	fffff097          	auipc	ra,0xfffff
    800012bc:	698080e7          	jalr	1688(ra) # 80000950 <kalloc>
    800012c0:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012c2:	6605                	lui	a2,0x1
    800012c4:	4581                	li	a1,0
    800012c6:	00000097          	auipc	ra,0x0
    800012ca:	8bc080e7          	jalr	-1860(ra) # 80000b82 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012ce:	4779                	li	a4,30
    800012d0:	86ca                	mv	a3,s2
    800012d2:	6605                	lui	a2,0x1
    800012d4:	4581                	li	a1,0
    800012d6:	8552                	mv	a0,s4
    800012d8:	00000097          	auipc	ra,0x0
    800012dc:	d44080e7          	jalr	-700(ra) # 8000101c <mappages>
  memmove(mem, src, sz);
    800012e0:	8626                	mv	a2,s1
    800012e2:	85ce                	mv	a1,s3
    800012e4:	854a                	mv	a0,s2
    800012e6:	00000097          	auipc	ra,0x0
    800012ea:	8f8080e7          	jalr	-1800(ra) # 80000bde <memmove>
}
    800012ee:	70a2                	ld	ra,40(sp)
    800012f0:	7402                	ld	s0,32(sp)
    800012f2:	64e2                	ld	s1,24(sp)
    800012f4:	6942                	ld	s2,16(sp)
    800012f6:	69a2                	ld	s3,8(sp)
    800012f8:	6a02                	ld	s4,0(sp)
    800012fa:	6145                	addi	sp,sp,48
    800012fc:	8082                	ret
    panic("inituvm: more than a page");
    800012fe:	00007517          	auipc	a0,0x7
    80001302:	f2250513          	addi	a0,a0,-222 # 80008220 <userret+0x190>
    80001306:	fffff097          	auipc	ra,0xfffff
    8000130a:	242080e7          	jalr	578(ra) # 80000548 <panic>

000000008000130e <uvmdealloc>:
{
    8000130e:	1101                	addi	sp,sp,-32
    80001310:	ec06                	sd	ra,24(sp)
    80001312:	e822                	sd	s0,16(sp)
    80001314:	e426                	sd	s1,8(sp)
    80001316:	1000                	addi	s0,sp,32
    return oldsz;
    80001318:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000131a:	00b67d63          	bgeu	a2,a1,80001334 <uvmdealloc+0x26>
    8000131e:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    80001320:	6785                	lui	a5,0x1
    80001322:	17fd                	addi	a5,a5,-1
    80001324:	00f60733          	add	a4,a2,a5
    80001328:	76fd                	lui	a3,0xfffff
    8000132a:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    8000132c:	97ae                	add	a5,a5,a1
    8000132e:	8ff5                	and	a5,a5,a3
    80001330:	00f76863          	bltu	a4,a5,80001340 <uvmdealloc+0x32>
}
    80001334:	8526                	mv	a0,s1
    80001336:	60e2                	ld	ra,24(sp)
    80001338:	6442                	ld	s0,16(sp)
    8000133a:	64a2                	ld	s1,8(sp)
    8000133c:	6105                	addi	sp,sp,32
    8000133e:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    80001340:	4685                	li	a3,1
    80001342:	40e58633          	sub	a2,a1,a4
    80001346:	85ba                	mv	a1,a4
    80001348:	00000097          	auipc	ra,0x0
    8000134c:	e80080e7          	jalr	-384(ra) # 800011c8 <uvmunmap>
    80001350:	b7d5                	j	80001334 <uvmdealloc+0x26>

0000000080001352 <uvmalloc>:
  if(newsz < oldsz)
    80001352:	0ab66163          	bltu	a2,a1,800013f4 <uvmalloc+0xa2>
{
    80001356:	7139                	addi	sp,sp,-64
    80001358:	fc06                	sd	ra,56(sp)
    8000135a:	f822                	sd	s0,48(sp)
    8000135c:	f426                	sd	s1,40(sp)
    8000135e:	f04a                	sd	s2,32(sp)
    80001360:	ec4e                	sd	s3,24(sp)
    80001362:	e852                	sd	s4,16(sp)
    80001364:	e456                	sd	s5,8(sp)
    80001366:	0080                	addi	s0,sp,64
    80001368:	8aaa                	mv	s5,a0
    8000136a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000136c:	6985                	lui	s3,0x1
    8000136e:	19fd                	addi	s3,s3,-1
    80001370:	95ce                	add	a1,a1,s3
    80001372:	79fd                	lui	s3,0xfffff
    80001374:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    80001378:	08c9f063          	bgeu	s3,a2,800013f8 <uvmalloc+0xa6>
  a = oldsz;
    8000137c:	894e                	mv	s2,s3
    mem = kalloc();
    8000137e:	fffff097          	auipc	ra,0xfffff
    80001382:	5d2080e7          	jalr	1490(ra) # 80000950 <kalloc>
    80001386:	84aa                	mv	s1,a0
    if(mem == 0){
    80001388:	c51d                	beqz	a0,800013b6 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000138a:	6605                	lui	a2,0x1
    8000138c:	4581                	li	a1,0
    8000138e:	fffff097          	auipc	ra,0xfffff
    80001392:	7f4080e7          	jalr	2036(ra) # 80000b82 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001396:	4779                	li	a4,30
    80001398:	86a6                	mv	a3,s1
    8000139a:	6605                	lui	a2,0x1
    8000139c:	85ca                	mv	a1,s2
    8000139e:	8556                	mv	a0,s5
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	c7c080e7          	jalr	-900(ra) # 8000101c <mappages>
    800013a8:	e905                	bnez	a0,800013d8 <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    800013aa:	6785                	lui	a5,0x1
    800013ac:	993e                	add	s2,s2,a5
    800013ae:	fd4968e3          	bltu	s2,s4,8000137e <uvmalloc+0x2c>
  return newsz;
    800013b2:	8552                	mv	a0,s4
    800013b4:	a809                	j	800013c6 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800013b6:	864e                	mv	a2,s3
    800013b8:	85ca                	mv	a1,s2
    800013ba:	8556                	mv	a0,s5
    800013bc:	00000097          	auipc	ra,0x0
    800013c0:	f52080e7          	jalr	-174(ra) # 8000130e <uvmdealloc>
      return 0;
    800013c4:	4501                	li	a0,0
}
    800013c6:	70e2                	ld	ra,56(sp)
    800013c8:	7442                	ld	s0,48(sp)
    800013ca:	74a2                	ld	s1,40(sp)
    800013cc:	7902                	ld	s2,32(sp)
    800013ce:	69e2                	ld	s3,24(sp)
    800013d0:	6a42                	ld	s4,16(sp)
    800013d2:	6aa2                	ld	s5,8(sp)
    800013d4:	6121                	addi	sp,sp,64
    800013d6:	8082                	ret
      kfree(mem);
    800013d8:	8526                	mv	a0,s1
    800013da:	fffff097          	auipc	ra,0xfffff
    800013de:	47a080e7          	jalr	1146(ra) # 80000854 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013e2:	864e                	mv	a2,s3
    800013e4:	85ca                	mv	a1,s2
    800013e6:	8556                	mv	a0,s5
    800013e8:	00000097          	auipc	ra,0x0
    800013ec:	f26080e7          	jalr	-218(ra) # 8000130e <uvmdealloc>
      return 0;
    800013f0:	4501                	li	a0,0
    800013f2:	bfd1                	j	800013c6 <uvmalloc+0x74>
    return oldsz;
    800013f4:	852e                	mv	a0,a1
}
    800013f6:	8082                	ret
  return newsz;
    800013f8:	8532                	mv	a0,a2
    800013fa:	b7f1                	j	800013c6 <uvmalloc+0x74>

00000000800013fc <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013fc:	1101                	addi	sp,sp,-32
    800013fe:	ec06                	sd	ra,24(sp)
    80001400:	e822                	sd	s0,16(sp)
    80001402:	e426                	sd	s1,8(sp)
    80001404:	1000                	addi	s0,sp,32
    80001406:	84aa                	mv	s1,a0
    80001408:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    8000140a:	4685                	li	a3,1
    8000140c:	4581                	li	a1,0
    8000140e:	00000097          	auipc	ra,0x0
    80001412:	dba080e7          	jalr	-582(ra) # 800011c8 <uvmunmap>
  freewalk(pagetable);
    80001416:	8526                	mv	a0,s1
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	ad6080e7          	jalr	-1322(ra) # 80000eee <freewalk>
}
    80001420:	60e2                	ld	ra,24(sp)
    80001422:	6442                	ld	s0,16(sp)
    80001424:	64a2                	ld	s1,8(sp)
    80001426:	6105                	addi	sp,sp,32
    80001428:	8082                	ret

000000008000142a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000142a:	ca45                	beqz	a2,800014da <uvmcopy+0xb0>
{
    8000142c:	715d                	addi	sp,sp,-80
    8000142e:	e486                	sd	ra,72(sp)
    80001430:	e0a2                	sd	s0,64(sp)
    80001432:	fc26                	sd	s1,56(sp)
    80001434:	f84a                	sd	s2,48(sp)
    80001436:	f44e                	sd	s3,40(sp)
    80001438:	f052                	sd	s4,32(sp)
    8000143a:	ec56                	sd	s5,24(sp)
    8000143c:	e85a                	sd	s6,16(sp)
    8000143e:	e45e                	sd	s7,8(sp)
    80001440:	0880                	addi	s0,sp,80
    80001442:	8aaa                	mv	s5,a0
    80001444:	8b2e                	mv	s6,a1
    80001446:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001448:	4481                	li	s1,0
    8000144a:	a029                	j	80001454 <uvmcopy+0x2a>
    8000144c:	6785                	lui	a5,0x1
    8000144e:	94be                	add	s1,s1,a5
    80001450:	0744f963          	bgeu	s1,s4,800014c2 <uvmcopy+0x98>
    if((pte = walk(old, i, 0)) == 0)
    80001454:	4601                	li	a2,0
    80001456:	85a6                	mv	a1,s1
    80001458:	8556                	mv	a0,s5
    8000145a:	00000097          	auipc	ra,0x0
    8000145e:	9ee080e7          	jalr	-1554(ra) # 80000e48 <walk>
    80001462:	d56d                	beqz	a0,8000144c <uvmcopy+0x22>
      //panic("uvmcopy: pte should exist");
      continue;
    if((*pte & PTE_V) == 0)
    80001464:	6118                	ld	a4,0(a0)
    80001466:	00177793          	andi	a5,a4,1
    8000146a:	d3ed                	beqz	a5,8000144c <uvmcopy+0x22>
      //panic("uvmcopy: page not present");
      continue;
    pa = PTE2PA(*pte);
    8000146c:	00a75593          	srli	a1,a4,0xa
    80001470:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001474:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    80001478:	fffff097          	auipc	ra,0xfffff
    8000147c:	4d8080e7          	jalr	1240(ra) # 80000950 <kalloc>
    80001480:	89aa                	mv	s3,a0
    80001482:	c515                	beqz	a0,800014ae <uvmcopy+0x84>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001484:	6605                	lui	a2,0x1
    80001486:	85de                	mv	a1,s7
    80001488:	fffff097          	auipc	ra,0xfffff
    8000148c:	756080e7          	jalr	1878(ra) # 80000bde <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001490:	874a                	mv	a4,s2
    80001492:	86ce                	mv	a3,s3
    80001494:	6605                	lui	a2,0x1
    80001496:	85a6                	mv	a1,s1
    80001498:	855a                	mv	a0,s6
    8000149a:	00000097          	auipc	ra,0x0
    8000149e:	b82080e7          	jalr	-1150(ra) # 8000101c <mappages>
    800014a2:	d54d                	beqz	a0,8000144c <uvmcopy+0x22>
      kfree(mem);
    800014a4:	854e                	mv	a0,s3
    800014a6:	fffff097          	auipc	ra,0xfffff
    800014aa:	3ae080e7          	jalr	942(ra) # 80000854 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800014ae:	4685                	li	a3,1
    800014b0:	8626                	mv	a2,s1
    800014b2:	4581                	li	a1,0
    800014b4:	855a                	mv	a0,s6
    800014b6:	00000097          	auipc	ra,0x0
    800014ba:	d12080e7          	jalr	-750(ra) # 800011c8 <uvmunmap>
  return -1;
    800014be:	557d                	li	a0,-1
    800014c0:	a011                	j	800014c4 <uvmcopy+0x9a>
  return 0;
    800014c2:	4501                	li	a0,0
}
    800014c4:	60a6                	ld	ra,72(sp)
    800014c6:	6406                	ld	s0,64(sp)
    800014c8:	74e2                	ld	s1,56(sp)
    800014ca:	7942                	ld	s2,48(sp)
    800014cc:	79a2                	ld	s3,40(sp)
    800014ce:	7a02                	ld	s4,32(sp)
    800014d0:	6ae2                	ld	s5,24(sp)
    800014d2:	6b42                	ld	s6,16(sp)
    800014d4:	6ba2                	ld	s7,8(sp)
    800014d6:	6161                	addi	sp,sp,80
    800014d8:	8082                	ret
  return 0;
    800014da:	4501                	li	a0,0
}
    800014dc:	8082                	ret

00000000800014de <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014de:	1141                	addi	sp,sp,-16
    800014e0:	e406                	sd	ra,8(sp)
    800014e2:	e022                	sd	s0,0(sp)
    800014e4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014e6:	4601                	li	a2,0
    800014e8:	00000097          	auipc	ra,0x0
    800014ec:	960080e7          	jalr	-1696(ra) # 80000e48 <walk>
  if(pte == 0)
    800014f0:	c901                	beqz	a0,80001500 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014f2:	611c                	ld	a5,0(a0)
    800014f4:	9bbd                	andi	a5,a5,-17
    800014f6:	e11c                	sd	a5,0(a0)
}
    800014f8:	60a2                	ld	ra,8(sp)
    800014fa:	6402                	ld	s0,0(sp)
    800014fc:	0141                	addi	sp,sp,16
    800014fe:	8082                	ret
    panic("uvmclear");
    80001500:	00007517          	auipc	a0,0x7
    80001504:	d4050513          	addi	a0,a0,-704 # 80008240 <userret+0x1b0>
    80001508:	fffff097          	auipc	ra,0xfffff
    8000150c:	040080e7          	jalr	64(ra) # 80000548 <panic>

0000000080001510 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001510:	c6c5                	beqz	a3,800015b8 <copyinstr+0xa8>
{
    80001512:	715d                	addi	sp,sp,-80
    80001514:	e486                	sd	ra,72(sp)
    80001516:	e0a2                	sd	s0,64(sp)
    80001518:	fc26                	sd	s1,56(sp)
    8000151a:	f84a                	sd	s2,48(sp)
    8000151c:	f44e                	sd	s3,40(sp)
    8000151e:	f052                	sd	s4,32(sp)
    80001520:	ec56                	sd	s5,24(sp)
    80001522:	e85a                	sd	s6,16(sp)
    80001524:	e45e                	sd	s7,8(sp)
    80001526:	0880                	addi	s0,sp,80
    80001528:	8a2a                	mv	s4,a0
    8000152a:	8b2e                	mv	s6,a1
    8000152c:	8bb2                	mv	s7,a2
    8000152e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001530:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001532:	6985                	lui	s3,0x1
    80001534:	a035                	j	80001560 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001536:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000153a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000153c:	0017b793          	seqz	a5,a5
    80001540:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001544:	60a6                	ld	ra,72(sp)
    80001546:	6406                	ld	s0,64(sp)
    80001548:	74e2                	ld	s1,56(sp)
    8000154a:	7942                	ld	s2,48(sp)
    8000154c:	79a2                	ld	s3,40(sp)
    8000154e:	7a02                	ld	s4,32(sp)
    80001550:	6ae2                	ld	s5,24(sp)
    80001552:	6b42                	ld	s6,16(sp)
    80001554:	6ba2                	ld	s7,8(sp)
    80001556:	6161                	addi	sp,sp,80
    80001558:	8082                	ret
    srcva = va0 + PGSIZE;
    8000155a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000155e:	c8a9                	beqz	s1,800015b0 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001560:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001564:	85ca                	mv	a1,s2
    80001566:	8552                	mv	a0,s4
    80001568:	00000097          	auipc	ra,0x0
    8000156c:	a14080e7          	jalr	-1516(ra) # 80000f7c <walkaddr>
    if(pa0 == 0)
    80001570:	c131                	beqz	a0,800015b4 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001572:	41790833          	sub	a6,s2,s7
    80001576:	984e                	add	a6,a6,s3
    if(n > max)
    80001578:	0104f363          	bgeu	s1,a6,8000157e <copyinstr+0x6e>
    8000157c:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000157e:	955e                	add	a0,a0,s7
    80001580:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001584:	fc080be3          	beqz	a6,8000155a <copyinstr+0x4a>
    80001588:	985a                	add	a6,a6,s6
    8000158a:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000158c:	41650633          	sub	a2,a0,s6
    80001590:	14fd                	addi	s1,s1,-1
    80001592:	9b26                	add	s6,s6,s1
    80001594:	00f60733          	add	a4,a2,a5
    80001598:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd4fa4>
    8000159c:	df49                	beqz	a4,80001536 <copyinstr+0x26>
        *dst = *p;
    8000159e:	00e78023          	sb	a4,0(a5)
      --max;
    800015a2:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800015a6:	0785                	addi	a5,a5,1
    while(n > 0){
    800015a8:	ff0796e3          	bne	a5,a6,80001594 <copyinstr+0x84>
      dst++;
    800015ac:	8b42                	mv	s6,a6
    800015ae:	b775                	j	8000155a <copyinstr+0x4a>
    800015b0:	4781                	li	a5,0
    800015b2:	b769                	j	8000153c <copyinstr+0x2c>
      return -1;
    800015b4:	557d                	li	a0,-1
    800015b6:	b779                	j	80001544 <copyinstr+0x34>
  int got_null = 0;
    800015b8:	4781                	li	a5,0
  if(got_null){
    800015ba:	0017b793          	seqz	a5,a5
    800015be:	40f00533          	neg	a0,a5
}
    800015c2:	8082                	ret

00000000800015c4 <vmprint>:

int layer = 1;

void
vmprint(pagetable_t pagetable, int isinit){
    800015c4:	711d                	addi	sp,sp,-96
    800015c6:	ec86                	sd	ra,88(sp)
    800015c8:	e8a2                	sd	s0,80(sp)
    800015ca:	e4a6                	sd	s1,72(sp)
    800015cc:	e0ca                	sd	s2,64(sp)
    800015ce:	fc4e                	sd	s3,56(sp)
    800015d0:	f852                	sd	s4,48(sp)
    800015d2:	f456                	sd	s5,40(sp)
    800015d4:	f05a                	sd	s6,32(sp)
    800015d6:	ec5e                	sd	s7,24(sp)
    800015d8:	e862                	sd	s8,16(sp)
    800015da:	e466                	sd	s9,8(sp)
    800015dc:	1080                	addi	s0,sp,96
    800015de:	8a2a                	mv	s4,a0
  if(isinit){
    800015e0:	e195                	bnez	a1,80001604 <vmprint+0x40>
vmprint(pagetable_t pagetable, int isinit){
    800015e2:	4981                	li	s3,0
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    /* 如果该PTE是有效映射 */
    if(pte & PTE_V){
      /* 打印PTE信息 */
      for (int i = 0; i < layer; i++)
    800015e4:	00008a97          	auipc	s5,0x8
    800015e8:	a50a8a93          	addi	s5,s5,-1456 # 80009034 <layer>
          printf("..");
        else
          printf(".. "); */
        printf(" ..");
      }
      printf("%d: pte %p pa %p\n",i, pte, PTE2PA(pte));
    800015ec:	00007c97          	auipc	s9,0x7
    800015f0:	c7cc8c93          	addi	s9,s9,-900 # 80008268 <userret+0x1d8>
      /* 这个PTE有孩子 */
      if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015f4:	4c05                	li	s8,1
        printf(" ..");
    800015f6:	00007b17          	auipc	s6,0x7
    800015fa:	c6ab0b13          	addi	s6,s6,-918 # 80008260 <userret+0x1d0>
  for(int i = 0; i < 512; i++){
    800015fe:	20000b93          	li	s7,512
    80001602:	a839                	j	80001620 <vmprint+0x5c>
    printf("page table %p\n", pagetable);
    80001604:	85aa                	mv	a1,a0
    80001606:	00007517          	auipc	a0,0x7
    8000160a:	c4a50513          	addi	a0,a0,-950 # 80008250 <userret+0x1c0>
    8000160e:	fffff097          	auipc	ra,0xfffff
    80001612:	f84080e7          	jalr	-124(ra) # 80000592 <printf>
    isinit = 0;
    80001616:	b7f1                	j	800015e2 <vmprint+0x1e>
  for(int i = 0; i < 512; i++){
    80001618:	2985                	addiw	s3,s3,1
    8000161a:	0a21                	addi	s4,s4,8
    8000161c:	07798663          	beq	s3,s7,80001688 <vmprint+0xc4>
    pte_t pte = pagetable[i];
    80001620:	000a3903          	ld	s2,0(s4) # fffffffffffff000 <end+0xffffffff7ffd4fa4>
    if(pte & PTE_V){
    80001624:	00197793          	andi	a5,s2,1
    80001628:	dbe5                	beqz	a5,80001618 <vmprint+0x54>
      for (int i = 0; i < layer; i++)
    8000162a:	000aa783          	lw	a5,0(s5)
    8000162e:	00f05d63          	blez	a5,80001648 <vmprint+0x84>
    80001632:	4481                	li	s1,0
        printf(" ..");
    80001634:	855a                	mv	a0,s6
    80001636:	fffff097          	auipc	ra,0xfffff
    8000163a:	f5c080e7          	jalr	-164(ra) # 80000592 <printf>
      for (int i = 0; i < layer; i++)
    8000163e:	2485                	addiw	s1,s1,1
    80001640:	000aa783          	lw	a5,0(s5)
    80001644:	fef4c8e3          	blt	s1,a5,80001634 <vmprint+0x70>
      printf("%d: pte %p pa %p\n",i, pte, PTE2PA(pte));
    80001648:	00a95493          	srli	s1,s2,0xa
    8000164c:	04b2                	slli	s1,s1,0xc
    8000164e:	86a6                	mv	a3,s1
    80001650:	864a                	mv	a2,s2
    80001652:	85ce                	mv	a1,s3
    80001654:	8566                	mv	a0,s9
    80001656:	fffff097          	auipc	ra,0xfffff
    8000165a:	f3c080e7          	jalr	-196(ra) # 80000592 <printf>
      if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000165e:	00f97913          	andi	s2,s2,15
    80001662:	fb891be3          	bne	s2,s8,80001618 <vmprint+0x54>
        // this PTE points to a lower-level page table.
        uint64 child = PTE2PA(pte);
        layer++;
    80001666:	000aa783          	lw	a5,0(s5)
    8000166a:	2785                	addiw	a5,a5,1
    8000166c:	00faa023          	sw	a5,0(s5)
        vmprint((pagetable_t)child, 0);
    80001670:	4581                	li	a1,0
    80001672:	8526                	mv	a0,s1
    80001674:	00000097          	auipc	ra,0x0
    80001678:	f50080e7          	jalr	-176(ra) # 800015c4 <vmprint>
        layer--;
    8000167c:	000aa783          	lw	a5,0(s5)
    80001680:	37fd                	addiw	a5,a5,-1
    80001682:	00faa023          	sw	a5,0(s5)
    80001686:	bf49                	j	80001618 <vmprint+0x54>
      } 
    }
  } 
}
    80001688:	60e6                	ld	ra,88(sp)
    8000168a:	6446                	ld	s0,80(sp)
    8000168c:	64a6                	ld	s1,72(sp)
    8000168e:	6906                	ld	s2,64(sp)
    80001690:	79e2                	ld	s3,56(sp)
    80001692:	7a42                	ld	s4,48(sp)
    80001694:	7aa2                	ld	s5,40(sp)
    80001696:	7b02                	ld	s6,32(sp)
    80001698:	6be2                	ld	s7,24(sp)
    8000169a:	6c42                	ld	s8,16(sp)
    8000169c:	6ca2                	ld	s9,8(sp)
    8000169e:	6125                	addi	sp,sp,96
    800016a0:	8082                	ret

00000000800016a2 <lazyalloc>:

int
lazyalloc(pagetable_t pagetable, uint64 va){ 
    800016a2:	7179                	addi	sp,sp,-48
    800016a4:	f406                	sd	ra,40(sp)
    800016a6:	f022                	sd	s0,32(sp)
    800016a8:	ec26                	sd	s1,24(sp)
    800016aa:	e84a                	sd	s2,16(sp)
    800016ac:	e44e                	sd	s3,8(sp)
    800016ae:	1800                	addi	s0,sp,48
    800016b0:	892a                	mv	s2,a0
    800016b2:	84ae                	mv	s1,a1
  if(va >= myproc()->sz){
    800016b4:	00000097          	auipc	ra,0x0
    800016b8:	376080e7          	jalr	886(ra) # 80001a2a <myproc>
    800016bc:	693c                	ld	a5,80(a0)
    800016be:	08f4f663          	bgeu	s1,a5,8000174a <lazyalloc+0xa8>
    printf("lazyalloc: va is bigger than proc sz\n");
    return -1;
  }

  if(va < myproc()->ustack_top){
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	368080e7          	jalr	872(ra) # 80001a2a <myproc>
    800016ca:	653c                	ld	a5,72(a0)
    800016cc:	08f4ef63          	bltu	s1,a5,8000176a <lazyalloc+0xc8>
    printf("lazyalloc: va is enter guard page!\n");
    return -1;
  }
  
  if(walkaddr(pagetable, va) != 0)
    800016d0:	85a6                	mv	a1,s1
    800016d2:	854a                	mv	a0,s2
    800016d4:	00000097          	auipc	ra,0x0
    800016d8:	8a8080e7          	jalr	-1880(ra) # 80000f7c <walkaddr>
    800016dc:	87aa                	mv	a5,a0
    return 0;
    800016de:	4501                	li	a0,0
  if(walkaddr(pagetable, va) != 0)
    800016e0:	efb5                	bnez	a5,8000175c <lazyalloc+0xba>
  
  char *mem;
  mem = kalloc();
    800016e2:	fffff097          	auipc	ra,0xfffff
    800016e6:	26e080e7          	jalr	622(ra) # 80000950 <kalloc>
    800016ea:	89aa                	mv	s3,a0
  va = PGROUNDDOWN(va);
    800016ec:	75fd                	lui	a1,0xfffff
    800016ee:	8ced                	and	s1,s1,a1
  if(mem != 0){
    800016f0:	c559                	beqz	a0,8000177e <lazyalloc+0xdc>
    memset(mem, 0, PGSIZE);
    800016f2:	6605                	lui	a2,0x1
    800016f4:	4581                	li	a1,0
    800016f6:	fffff097          	auipc	ra,0xfffff
    800016fa:	48c080e7          	jalr	1164(ra) # 80000b82 <memset>
    if(mappages(pagetable, va, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800016fe:	4779                	li	a4,30
    80001700:	86ce                	mv	a3,s3
    80001702:	6605                	lui	a2,0x1
    80001704:	85a6                	mv	a1,s1
    80001706:	854a                	mv	a0,s2
    80001708:	00000097          	auipc	ra,0x0
    8000170c:	914080e7          	jalr	-1772(ra) # 8000101c <mappages>
    80001710:	87aa                	mv	a5,a0
     * Handle the kalloc is invalid
     */
    printf("Mem is not enough \n");
    return -1;
  }
  return 1;
    80001712:	4505                	li	a0,1
    if(mappages(pagetable, va, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001714:	c7a1                	beqz	a5,8000175c <lazyalloc+0xba>
      printf("There is no page mapped");
    80001716:	00007517          	auipc	a0,0x7
    8000171a:	bba50513          	addi	a0,a0,-1094 # 800082d0 <userret+0x240>
    8000171e:	fffff097          	auipc	ra,0xfffff
    80001722:	e74080e7          	jalr	-396(ra) # 80000592 <printf>
      kfree(mem);
    80001726:	854e                	mv	a0,s3
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	12c080e7          	jalr	300(ra) # 80000854 <kfree>
      uvmdealloc(pagetable, va, myproc()->sz);
    80001730:	00000097          	auipc	ra,0x0
    80001734:	2fa080e7          	jalr	762(ra) # 80001a2a <myproc>
    80001738:	6930                	ld	a2,80(a0)
    8000173a:	85a6                	mv	a1,s1
    8000173c:	854a                	mv	a0,s2
    8000173e:	00000097          	auipc	ra,0x0
    80001742:	bd0080e7          	jalr	-1072(ra) # 8000130e <uvmdealloc>
      return -1;
    80001746:	557d                	li	a0,-1
    80001748:	a811                	j	8000175c <lazyalloc+0xba>
    printf("lazyalloc: va is bigger than proc sz\n");
    8000174a:	00007517          	auipc	a0,0x7
    8000174e:	b3650513          	addi	a0,a0,-1226 # 80008280 <userret+0x1f0>
    80001752:	fffff097          	auipc	ra,0xfffff
    80001756:	e40080e7          	jalr	-448(ra) # 80000592 <printf>
    return -1;
    8000175a:	557d                	li	a0,-1
}
    8000175c:	70a2                	ld	ra,40(sp)
    8000175e:	7402                	ld	s0,32(sp)
    80001760:	64e2                	ld	s1,24(sp)
    80001762:	6942                	ld	s2,16(sp)
    80001764:	69a2                	ld	s3,8(sp)
    80001766:	6145                	addi	sp,sp,48
    80001768:	8082                	ret
    printf("lazyalloc: va is enter guard page!\n");
    8000176a:	00007517          	auipc	a0,0x7
    8000176e:	b3e50513          	addi	a0,a0,-1218 # 800082a8 <userret+0x218>
    80001772:	fffff097          	auipc	ra,0xfffff
    80001776:	e20080e7          	jalr	-480(ra) # 80000592 <printf>
    return -1;
    8000177a:	557d                	li	a0,-1
    8000177c:	b7c5                	j	8000175c <lazyalloc+0xba>
    printf("Mem is not enough \n");
    8000177e:	00007517          	auipc	a0,0x7
    80001782:	b6a50513          	addi	a0,a0,-1174 # 800082e8 <userret+0x258>
    80001786:	fffff097          	auipc	ra,0xfffff
    8000178a:	e0c080e7          	jalr	-500(ra) # 80000592 <printf>
    return -1;
    8000178e:	557d                	li	a0,-1
    80001790:	b7f1                	j	8000175c <lazyalloc+0xba>

0000000080001792 <copyout>:
  while(len > 0){
    80001792:	c2d5                	beqz	a3,80001836 <copyout+0xa4>
{
    80001794:	715d                	addi	sp,sp,-80
    80001796:	e486                	sd	ra,72(sp)
    80001798:	e0a2                	sd	s0,64(sp)
    8000179a:	fc26                	sd	s1,56(sp)
    8000179c:	f84a                	sd	s2,48(sp)
    8000179e:	f44e                	sd	s3,40(sp)
    800017a0:	f052                	sd	s4,32(sp)
    800017a2:	ec56                	sd	s5,24(sp)
    800017a4:	e85a                	sd	s6,16(sp)
    800017a6:	e45e                	sd	s7,8(sp)
    800017a8:	e062                	sd	s8,0(sp)
    800017aa:	0880                	addi	s0,sp,80
    800017ac:	8baa                	mv	s7,a0
    800017ae:	892e                	mv	s2,a1
    800017b0:	8ab2                	mv	s5,a2
    800017b2:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800017b4:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - offset;
    800017b6:	6b05                	lui	s6,0x1
    800017b8:	a8a9                	j	80001812 <copyout+0x80>
      if(lazyalloc(pagetable, va0)){
    800017ba:	85ce                	mv	a1,s3
    800017bc:	855e                	mv	a0,s7
    800017be:	00000097          	auipc	ra,0x0
    800017c2:	ee4080e7          	jalr	-284(ra) # 800016a2 <lazyalloc>
    800017c6:	c935                	beqz	a0,8000183a <copyout+0xa8>
        pa0 = walkaddr(pagetable, va0);
    800017c8:	85ce                	mv	a1,s3
    800017ca:	855e                	mv	a0,s7
    800017cc:	fffff097          	auipc	ra,0xfffff
    800017d0:	7b0080e7          	jalr	1968(ra) # 80000f7c <walkaddr>
    if(pa0 == 0){
    800017d4:	e921                	bnez	a0,80001824 <copyout+0x92>
      return -1;
    800017d6:	557d                	li	a0,-1
}
    800017d8:	60a6                	ld	ra,72(sp)
    800017da:	6406                	ld	s0,64(sp)
    800017dc:	74e2                	ld	s1,56(sp)
    800017de:	7942                	ld	s2,48(sp)
    800017e0:	79a2                	ld	s3,40(sp)
    800017e2:	7a02                	ld	s4,32(sp)
    800017e4:	6ae2                	ld	s5,24(sp)
    800017e6:	6b42                	ld	s6,16(sp)
    800017e8:	6ba2                	ld	s7,8(sp)
    800017ea:	6c02                	ld	s8,0(sp)
    800017ec:	6161                	addi	sp,sp,80
    800017ee:	8082                	ret
    uint64 offset = (dstva - va0);
    800017f0:	41390933          	sub	s2,s2,s3
    memmove((void *)(pa0 + offset), src, n);
    800017f4:	0004861b          	sext.w	a2,s1
    800017f8:	85d6                	mv	a1,s5
    800017fa:	954a                	add	a0,a0,s2
    800017fc:	fffff097          	auipc	ra,0xfffff
    80001800:	3e2080e7          	jalr	994(ra) # 80000bde <memmove>
    len -= n;
    80001804:	409a0a33          	sub	s4,s4,s1
    src += n;
    80001808:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    8000180a:	01698933          	add	s2,s3,s6
  while(len > 0){
    8000180e:	020a0263          	beqz	s4,80001832 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    80001812:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001816:	85ce                	mv	a1,s3
    80001818:	855e                	mv	a0,s7
    8000181a:	fffff097          	auipc	ra,0xfffff
    8000181e:	762080e7          	jalr	1890(ra) # 80000f7c <walkaddr>
    if(pa0 == 0){
    80001822:	dd41                	beqz	a0,800017ba <copyout+0x28>
    n = PGSIZE - offset;
    80001824:	412984b3          	sub	s1,s3,s2
    80001828:	94da                	add	s1,s1,s6
    if(n > len)
    8000182a:	fc9a73e3          	bgeu	s4,s1,800017f0 <copyout+0x5e>
    8000182e:	84d2                	mv	s1,s4
    80001830:	b7c1                	j	800017f0 <copyout+0x5e>
  return 0;
    80001832:	4501                	li	a0,0
    80001834:	b755                	j	800017d8 <copyout+0x46>
    80001836:	4501                	li	a0,0
}
    80001838:	8082                	ret
        return -1;
    8000183a:	557d                	li	a0,-1
    8000183c:	bf71                	j	800017d8 <copyout+0x46>

000000008000183e <copyin>:
  while(len > 0){
    8000183e:	c2d5                	beqz	a3,800018e2 <copyin+0xa4>
{
    80001840:	715d                	addi	sp,sp,-80
    80001842:	e486                	sd	ra,72(sp)
    80001844:	e0a2                	sd	s0,64(sp)
    80001846:	fc26                	sd	s1,56(sp)
    80001848:	f84a                	sd	s2,48(sp)
    8000184a:	f44e                	sd	s3,40(sp)
    8000184c:	f052                	sd	s4,32(sp)
    8000184e:	ec56                	sd	s5,24(sp)
    80001850:	e85a                	sd	s6,16(sp)
    80001852:	e45e                	sd	s7,8(sp)
    80001854:	e062                	sd	s8,0(sp)
    80001856:	0880                	addi	s0,sp,80
    80001858:	8baa                	mv	s7,a0
    8000185a:	8aae                	mv	s5,a1
    8000185c:	8932                	mv	s2,a2
    8000185e:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001860:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001862:	6b05                	lui	s6,0x1
    80001864:	a8a9                	j	800018be <copyin+0x80>
      if(lazyalloc(pagetable, va0)){
    80001866:	85ce                	mv	a1,s3
    80001868:	855e                	mv	a0,s7
    8000186a:	00000097          	auipc	ra,0x0
    8000186e:	e38080e7          	jalr	-456(ra) # 800016a2 <lazyalloc>
    80001872:	c935                	beqz	a0,800018e6 <copyin+0xa8>
        pa0 = walkaddr(pagetable, va0);
    80001874:	85ce                	mv	a1,s3
    80001876:	855e                	mv	a0,s7
    80001878:	fffff097          	auipc	ra,0xfffff
    8000187c:	704080e7          	jalr	1796(ra) # 80000f7c <walkaddr>
    if(pa0 == 0){
    80001880:	e921                	bnez	a0,800018d0 <copyin+0x92>
      return -1;
    80001882:	557d                	li	a0,-1
}
    80001884:	60a6                	ld	ra,72(sp)
    80001886:	6406                	ld	s0,64(sp)
    80001888:	74e2                	ld	s1,56(sp)
    8000188a:	7942                	ld	s2,48(sp)
    8000188c:	79a2                	ld	s3,40(sp)
    8000188e:	7a02                	ld	s4,32(sp)
    80001890:	6ae2                	ld	s5,24(sp)
    80001892:	6b42                	ld	s6,16(sp)
    80001894:	6ba2                	ld	s7,8(sp)
    80001896:	6c02                	ld	s8,0(sp)
    80001898:	6161                	addi	sp,sp,80
    8000189a:	8082                	ret
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000189c:	413905b3          	sub	a1,s2,s3
    800018a0:	0004861b          	sext.w	a2,s1
    800018a4:	95aa                	add	a1,a1,a0
    800018a6:	8556                	mv	a0,s5
    800018a8:	fffff097          	auipc	ra,0xfffff
    800018ac:	336080e7          	jalr	822(ra) # 80000bde <memmove>
    len -= n;
    800018b0:	409a0a33          	sub	s4,s4,s1
    dst += n;
    800018b4:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    800018b6:	01698933          	add	s2,s3,s6
  while(len > 0){
    800018ba:	020a0263          	beqz	s4,800018de <copyin+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800018be:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    800018c2:	85ce                	mv	a1,s3
    800018c4:	855e                	mv	a0,s7
    800018c6:	fffff097          	auipc	ra,0xfffff
    800018ca:	6b6080e7          	jalr	1718(ra) # 80000f7c <walkaddr>
    if(pa0 == 0){
    800018ce:	dd41                	beqz	a0,80001866 <copyin+0x28>
    n = PGSIZE - (srcva - va0);
    800018d0:	412984b3          	sub	s1,s3,s2
    800018d4:	94da                	add	s1,s1,s6
    if(n > len)
    800018d6:	fc9a73e3          	bgeu	s4,s1,8000189c <copyin+0x5e>
    800018da:	84d2                	mv	s1,s4
    800018dc:	b7c1                	j	8000189c <copyin+0x5e>
  return 0;
    800018de:	4501                	li	a0,0
    800018e0:	b755                	j	80001884 <copyin+0x46>
    800018e2:	4501                	li	a0,0
}
    800018e4:	8082                	ret
        return -1;
    800018e6:	557d                	li	a0,-1
    800018e8:	bf71                	j	80001884 <copyin+0x46>

00000000800018ea <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018ea:	1101                	addi	sp,sp,-32
    800018ec:	ec06                	sd	ra,24(sp)
    800018ee:	e822                	sd	s0,16(sp)
    800018f0:	e426                	sd	s1,8(sp)
    800018f2:	1000                	addi	s0,sp,32
    800018f4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018f6:	fffff097          	auipc	ra,0xfffff
    800018fa:	188080e7          	jalr	392(ra) # 80000a7e <holding>
    800018fe:	c909                	beqz	a0,80001910 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001900:	749c                	ld	a5,40(s1)
    80001902:	00978f63          	beq	a5,s1,80001920 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret
    panic("wakeup1");
    80001910:	00007517          	auipc	a0,0x7
    80001914:	9f050513          	addi	a0,a0,-1552 # 80008300 <userret+0x270>
    80001918:	fffff097          	auipc	ra,0xfffff
    8000191c:	c30080e7          	jalr	-976(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001920:	4c98                	lw	a4,24(s1)
    80001922:	4785                	li	a5,1
    80001924:	fef711e3          	bne	a4,a5,80001906 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001928:	4789                	li	a5,2
    8000192a:	cc9c                	sw	a5,24(s1)
}
    8000192c:	bfe9                	j	80001906 <wakeup1+0x1c>

000000008000192e <procinit>:
{
    8000192e:	715d                	addi	sp,sp,-80
    80001930:	e486                	sd	ra,72(sp)
    80001932:	e0a2                	sd	s0,64(sp)
    80001934:	fc26                	sd	s1,56(sp)
    80001936:	f84a                	sd	s2,48(sp)
    80001938:	f44e                	sd	s3,40(sp)
    8000193a:	f052                	sd	s4,32(sp)
    8000193c:	ec56                	sd	s5,24(sp)
    8000193e:	e85a                	sd	s6,16(sp)
    80001940:	e45e                	sd	s7,8(sp)
    80001942:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001944:	00007597          	auipc	a1,0x7
    80001948:	9c458593          	addi	a1,a1,-1596 # 80008308 <userret+0x278>
    8000194c:	00011517          	auipc	a0,0x11
    80001950:	f9c50513          	addi	a0,a0,-100 # 800128e8 <pid_lock>
    80001954:	fffff097          	auipc	ra,0xfffff
    80001958:	05c080e7          	jalr	92(ra) # 800009b0 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195c:	00011917          	auipc	s2,0x11
    80001960:	3a490913          	addi	s2,s2,932 # 80012d00 <proc>
      initlock(&p->lock, "proc");
    80001964:	00007b97          	auipc	s7,0x7
    80001968:	9acb8b93          	addi	s7,s7,-1620 # 80008310 <userret+0x280>
      uint64 va = KSTACK((int) (p - proc));
    8000196c:	8b4a                	mv	s6,s2
    8000196e:	00007a97          	auipc	s5,0x7
    80001972:	1e2a8a93          	addi	s5,s5,482 # 80008b50 <syscalls+0xc0>
    80001976:	040009b7          	lui	s3,0x4000
    8000197a:	19fd                	addi	s3,s3,-1
    8000197c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197e:	00017a17          	auipc	s4,0x17
    80001982:	f82a0a13          	addi	s4,s4,-126 # 80018900 <tickslock>
      initlock(&p->lock, "proc");
    80001986:	85de                	mv	a1,s7
    80001988:	854a                	mv	a0,s2
    8000198a:	fffff097          	auipc	ra,0xfffff
    8000198e:	026080e7          	jalr	38(ra) # 800009b0 <initlock>
      char *pa = kalloc();
    80001992:	fffff097          	auipc	ra,0xfffff
    80001996:	fbe080e7          	jalr	-66(ra) # 80000950 <kalloc>
    8000199a:	85aa                	mv	a1,a0
      if(pa == 0)
    8000199c:	c929                	beqz	a0,800019ee <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    8000199e:	416904b3          	sub	s1,s2,s6
    800019a2:	8491                	srai	s1,s1,0x4
    800019a4:	000ab783          	ld	a5,0(s5)
    800019a8:	02f484b3          	mul	s1,s1,a5
    800019ac:	2485                	addiw	s1,s1,1
    800019ae:	00d4949b          	slliw	s1,s1,0xd
    800019b2:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019b6:	4699                	li	a3,6
    800019b8:	6605                	lui	a2,0x1
    800019ba:	8526                	mv	a0,s1
    800019bc:	fffff097          	auipc	ra,0xfffff
    800019c0:	6ee080e7          	jalr	1774(ra) # 800010aa <kvmmap>
      p->kstack = va;
    800019c4:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019c8:	17090913          	addi	s2,s2,368
    800019cc:	fb491de3          	bne	s2,s4,80001986 <procinit+0x58>
  kvminithart();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	588080e7          	jalr	1416(ra) # 80000f58 <kvminithart>
}
    800019d8:	60a6                	ld	ra,72(sp)
    800019da:	6406                	ld	s0,64(sp)
    800019dc:	74e2                	ld	s1,56(sp)
    800019de:	7942                	ld	s2,48(sp)
    800019e0:	79a2                	ld	s3,40(sp)
    800019e2:	7a02                	ld	s4,32(sp)
    800019e4:	6ae2                	ld	s5,24(sp)
    800019e6:	6b42                	ld	s6,16(sp)
    800019e8:	6ba2                	ld	s7,8(sp)
    800019ea:	6161                	addi	sp,sp,80
    800019ec:	8082                	ret
        panic("kalloc");
    800019ee:	00007517          	auipc	a0,0x7
    800019f2:	92a50513          	addi	a0,a0,-1750 # 80008318 <userret+0x288>
    800019f6:	fffff097          	auipc	ra,0xfffff
    800019fa:	b52080e7          	jalr	-1198(ra) # 80000548 <panic>

00000000800019fe <cpuid>:
{
    800019fe:	1141                	addi	sp,sp,-16
    80001a00:	e422                	sd	s0,8(sp)
    80001a02:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a04:	8512                	mv	a0,tp
}
    80001a06:	2501                	sext.w	a0,a0
    80001a08:	6422                	ld	s0,8(sp)
    80001a0a:	0141                	addi	sp,sp,16
    80001a0c:	8082                	ret

0000000080001a0e <mycpu>:
mycpu(void) {
    80001a0e:	1141                	addi	sp,sp,-16
    80001a10:	e422                	sd	s0,8(sp)
    80001a12:	0800                	addi	s0,sp,16
    80001a14:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a16:	2781                	sext.w	a5,a5
    80001a18:	079e                	slli	a5,a5,0x7
}
    80001a1a:	00011517          	auipc	a0,0x11
    80001a1e:	ee650513          	addi	a0,a0,-282 # 80012900 <cpus>
    80001a22:	953e                	add	a0,a0,a5
    80001a24:	6422                	ld	s0,8(sp)
    80001a26:	0141                	addi	sp,sp,16
    80001a28:	8082                	ret

0000000080001a2a <myproc>:
myproc(void) {
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	1000                	addi	s0,sp,32
  push_off();
    80001a34:	fffff097          	auipc	ra,0xfffff
    80001a38:	f92080e7          	jalr	-110(ra) # 800009c6 <push_off>
    80001a3c:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a3e:	2781                	sext.w	a5,a5
    80001a40:	079e                	slli	a5,a5,0x7
    80001a42:	00011717          	auipc	a4,0x11
    80001a46:	ea670713          	addi	a4,a4,-346 # 800128e8 <pid_lock>
    80001a4a:	97ba                	add	a5,a5,a4
    80001a4c:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a4e:	fffff097          	auipc	ra,0xfffff
    80001a52:	fc4080e7          	jalr	-60(ra) # 80000a12 <pop_off>
}
    80001a56:	8526                	mv	a0,s1
    80001a58:	60e2                	ld	ra,24(sp)
    80001a5a:	6442                	ld	s0,16(sp)
    80001a5c:	64a2                	ld	s1,8(sp)
    80001a5e:	6105                	addi	sp,sp,32
    80001a60:	8082                	ret

0000000080001a62 <forkret>:
{
    80001a62:	1141                	addi	sp,sp,-16
    80001a64:	e406                	sd	ra,8(sp)
    80001a66:	e022                	sd	s0,0(sp)
    80001a68:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a6a:	00000097          	auipc	ra,0x0
    80001a6e:	fc0080e7          	jalr	-64(ra) # 80001a2a <myproc>
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	0b4080e7          	jalr	180(ra) # 80000b26 <release>
  if (first) {
    80001a7a:	00007797          	auipc	a5,0x7
    80001a7e:	5be7a783          	lw	a5,1470(a5) # 80009038 <first.1>
    80001a82:	eb89                	bnez	a5,80001a94 <forkret+0x32>
  usertrapret();
    80001a84:	00001097          	auipc	ra,0x1
    80001a88:	be2080e7          	jalr	-1054(ra) # 80002666 <usertrapret>
}
    80001a8c:	60a2                	ld	ra,8(sp)
    80001a8e:	6402                	ld	s0,0(sp)
    80001a90:	0141                	addi	sp,sp,16
    80001a92:	8082                	ret
    first = 0;
    80001a94:	00007797          	auipc	a5,0x7
    80001a98:	5a07a223          	sw	zero,1444(a5) # 80009038 <first.1>
    fsinit(minor(ROOTDEV));
    80001a9c:	4501                	li	a0,0
    80001a9e:	00002097          	auipc	ra,0x2
    80001aa2:	980080e7          	jalr	-1664(ra) # 8000341e <fsinit>
    80001aa6:	bff9                	j	80001a84 <forkret+0x22>

0000000080001aa8 <allocpid>:
allocpid() {
    80001aa8:	1101                	addi	sp,sp,-32
    80001aaa:	ec06                	sd	ra,24(sp)
    80001aac:	e822                	sd	s0,16(sp)
    80001aae:	e426                	sd	s1,8(sp)
    80001ab0:	e04a                	sd	s2,0(sp)
    80001ab2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ab4:	00011917          	auipc	s2,0x11
    80001ab8:	e3490913          	addi	s2,s2,-460 # 800128e8 <pid_lock>
    80001abc:	854a                	mv	a0,s2
    80001abe:	fffff097          	auipc	ra,0xfffff
    80001ac2:	000080e7          	jalr	ra # 80000abe <acquire>
  pid = nextpid;
    80001ac6:	00007797          	auipc	a5,0x7
    80001aca:	57678793          	addi	a5,a5,1398 # 8000903c <nextpid>
    80001ace:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ad0:	0014871b          	addiw	a4,s1,1
    80001ad4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ad6:	854a                	mv	a0,s2
    80001ad8:	fffff097          	auipc	ra,0xfffff
    80001adc:	04e080e7          	jalr	78(ra) # 80000b26 <release>
}
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	60e2                	ld	ra,24(sp)
    80001ae4:	6442                	ld	s0,16(sp)
    80001ae6:	64a2                	ld	s1,8(sp)
    80001ae8:	6902                	ld	s2,0(sp)
    80001aea:	6105                	addi	sp,sp,32
    80001aec:	8082                	ret

0000000080001aee <proc_pagetable>:
{
    80001aee:	1101                	addi	sp,sp,-32
    80001af0:	ec06                	sd	ra,24(sp)
    80001af2:	e822                	sd	s0,16(sp)
    80001af4:	e426                	sd	s1,8(sp)
    80001af6:	e04a                	sd	s2,0(sp)
    80001af8:	1000                	addi	s0,sp,32
    80001afa:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	762080e7          	jalr	1890(ra) # 8000125e <uvmcreate>
    80001b04:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b06:	4729                	li	a4,10
    80001b08:	00006697          	auipc	a3,0x6
    80001b0c:	4f868693          	addi	a3,a3,1272 # 80008000 <trampoline>
    80001b10:	6605                	lui	a2,0x1
    80001b12:	040005b7          	lui	a1,0x4000
    80001b16:	15fd                	addi	a1,a1,-1
    80001b18:	05b2                	slli	a1,a1,0xc
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	502080e7          	jalr	1282(ra) # 8000101c <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b22:	4719                	li	a4,6
    80001b24:	06093683          	ld	a3,96(s2)
    80001b28:	6605                	lui	a2,0x1
    80001b2a:	020005b7          	lui	a1,0x2000
    80001b2e:	15fd                	addi	a1,a1,-1
    80001b30:	05b6                	slli	a1,a1,0xd
    80001b32:	8526                	mv	a0,s1
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	4e8080e7          	jalr	1256(ra) # 8000101c <mappages>
}
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	60e2                	ld	ra,24(sp)
    80001b40:	6442                	ld	s0,16(sp)
    80001b42:	64a2                	ld	s1,8(sp)
    80001b44:	6902                	ld	s2,0(sp)
    80001b46:	6105                	addi	sp,sp,32
    80001b48:	8082                	ret

0000000080001b4a <allocproc>:
{
    80001b4a:	1101                	addi	sp,sp,-32
    80001b4c:	ec06                	sd	ra,24(sp)
    80001b4e:	e822                	sd	s0,16(sp)
    80001b50:	e426                	sd	s1,8(sp)
    80001b52:	e04a                	sd	s2,0(sp)
    80001b54:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b56:	00011497          	auipc	s1,0x11
    80001b5a:	1aa48493          	addi	s1,s1,426 # 80012d00 <proc>
    80001b5e:	00017917          	auipc	s2,0x17
    80001b62:	da290913          	addi	s2,s2,-606 # 80018900 <tickslock>
    acquire(&p->lock);
    80001b66:	8526                	mv	a0,s1
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	f56080e7          	jalr	-170(ra) # 80000abe <acquire>
    if(p->state == UNUSED) {
    80001b70:	4c9c                	lw	a5,24(s1)
    80001b72:	cf81                	beqz	a5,80001b8a <allocproc+0x40>
      release(&p->lock);
    80001b74:	8526                	mv	a0,s1
    80001b76:	fffff097          	auipc	ra,0xfffff
    80001b7a:	fb0080e7          	jalr	-80(ra) # 80000b26 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b7e:	17048493          	addi	s1,s1,368
    80001b82:	ff2492e3          	bne	s1,s2,80001b66 <allocproc+0x1c>
  return 0;
    80001b86:	4481                	li	s1,0
    80001b88:	a0a9                	j	80001bd2 <allocproc+0x88>
  p->pid = allocpid();
    80001b8a:	00000097          	auipc	ra,0x0
    80001b8e:	f1e080e7          	jalr	-226(ra) # 80001aa8 <allocpid>
    80001b92:	dc88                	sw	a0,56(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001b94:	fffff097          	auipc	ra,0xfffff
    80001b98:	dbc080e7          	jalr	-580(ra) # 80000950 <kalloc>
    80001b9c:	892a                	mv	s2,a0
    80001b9e:	f0a8                	sd	a0,96(s1)
    80001ba0:	c121                	beqz	a0,80001be0 <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	00000097          	auipc	ra,0x0
    80001ba8:	f4a080e7          	jalr	-182(ra) # 80001aee <proc_pagetable>
    80001bac:	eca8                	sd	a0,88(s1)
  memset(&p->context, 0, sizeof p->context);
    80001bae:	07000613          	li	a2,112
    80001bb2:	4581                	li	a1,0
    80001bb4:	06848513          	addi	a0,s1,104
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	fca080e7          	jalr	-54(ra) # 80000b82 <memset>
  p->context.ra = (uint64)forkret;
    80001bc0:	00000797          	auipc	a5,0x0
    80001bc4:	ea278793          	addi	a5,a5,-350 # 80001a62 <forkret>
    80001bc8:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bca:	60bc                	ld	a5,64(s1)
    80001bcc:	6705                	lui	a4,0x1
    80001bce:	97ba                	add	a5,a5,a4
    80001bd0:	f8bc                	sd	a5,112(s1)
}
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	60e2                	ld	ra,24(sp)
    80001bd6:	6442                	ld	s0,16(sp)
    80001bd8:	64a2                	ld	s1,8(sp)
    80001bda:	6902                	ld	s2,0(sp)
    80001bdc:	6105                	addi	sp,sp,32
    80001bde:	8082                	ret
    release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	f44080e7          	jalr	-188(ra) # 80000b26 <release>
    return 0;
    80001bea:	84ca                	mv	s1,s2
    80001bec:	b7dd                	j	80001bd2 <allocproc+0x88>

0000000080001bee <proc_freepagetable>:
{
    80001bee:	1101                	addi	sp,sp,-32
    80001bf0:	ec06                	sd	ra,24(sp)
    80001bf2:	e822                	sd	s0,16(sp)
    80001bf4:	e426                	sd	s1,8(sp)
    80001bf6:	e04a                	sd	s2,0(sp)
    80001bf8:	1000                	addi	s0,sp,32
    80001bfa:	84aa                	mv	s1,a0
    80001bfc:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001bfe:	4681                	li	a3,0
    80001c00:	6605                	lui	a2,0x1
    80001c02:	040005b7          	lui	a1,0x4000
    80001c06:	15fd                	addi	a1,a1,-1
    80001c08:	05b2                	slli	a1,a1,0xc
    80001c0a:	fffff097          	auipc	ra,0xfffff
    80001c0e:	5be080e7          	jalr	1470(ra) # 800011c8 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001c12:	4681                	li	a3,0
    80001c14:	6605                	lui	a2,0x1
    80001c16:	020005b7          	lui	a1,0x2000
    80001c1a:	15fd                	addi	a1,a1,-1
    80001c1c:	05b6                	slli	a1,a1,0xd
    80001c1e:	8526                	mv	a0,s1
    80001c20:	fffff097          	auipc	ra,0xfffff
    80001c24:	5a8080e7          	jalr	1448(ra) # 800011c8 <uvmunmap>
  if(sz > 0)
    80001c28:	00091863          	bnez	s2,80001c38 <proc_freepagetable+0x4a>
}
    80001c2c:	60e2                	ld	ra,24(sp)
    80001c2e:	6442                	ld	s0,16(sp)
    80001c30:	64a2                	ld	s1,8(sp)
    80001c32:	6902                	ld	s2,0(sp)
    80001c34:	6105                	addi	sp,sp,32
    80001c36:	8082                	ret
    uvmfree(pagetable, sz);
    80001c38:	85ca                	mv	a1,s2
    80001c3a:	8526                	mv	a0,s1
    80001c3c:	fffff097          	auipc	ra,0xfffff
    80001c40:	7c0080e7          	jalr	1984(ra) # 800013fc <uvmfree>
}
    80001c44:	b7e5                	j	80001c2c <proc_freepagetable+0x3e>

0000000080001c46 <freeproc>:
{
    80001c46:	1101                	addi	sp,sp,-32
    80001c48:	ec06                	sd	ra,24(sp)
    80001c4a:	e822                	sd	s0,16(sp)
    80001c4c:	e426                	sd	s1,8(sp)
    80001c4e:	1000                	addi	s0,sp,32
    80001c50:	84aa                	mv	s1,a0
  if(p->tf)
    80001c52:	7128                	ld	a0,96(a0)
    80001c54:	c509                	beqz	a0,80001c5e <freeproc+0x18>
    kfree((void*)p->tf);
    80001c56:	fffff097          	auipc	ra,0xfffff
    80001c5a:	bfe080e7          	jalr	-1026(ra) # 80000854 <kfree>
  p->tf = 0;
    80001c5e:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001c62:	6ca8                	ld	a0,88(s1)
    80001c64:	c511                	beqz	a0,80001c70 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c66:	68ac                	ld	a1,80(s1)
    80001c68:	00000097          	auipc	ra,0x0
    80001c6c:	f86080e7          	jalr	-122(ra) # 80001bee <proc_freepagetable>
  p->pagetable = 0;
    80001c70:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001c74:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001c78:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c7c:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c80:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001c84:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c88:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c8c:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c90:	0004ac23          	sw	zero,24(s1)
}
    80001c94:	60e2                	ld	ra,24(sp)
    80001c96:	6442                	ld	s0,16(sp)
    80001c98:	64a2                	ld	s1,8(sp)
    80001c9a:	6105                	addi	sp,sp,32
    80001c9c:	8082                	ret

0000000080001c9e <userinit>:
{
    80001c9e:	1101                	addi	sp,sp,-32
    80001ca0:	ec06                	sd	ra,24(sp)
    80001ca2:	e822                	sd	s0,16(sp)
    80001ca4:	e426                	sd	s1,8(sp)
    80001ca6:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ca8:	00000097          	auipc	ra,0x0
    80001cac:	ea2080e7          	jalr	-350(ra) # 80001b4a <allocproc>
    80001cb0:	84aa                	mv	s1,a0
  initproc = p;
    80001cb2:	00028797          	auipc	a5,0x28
    80001cb6:	38a7b323          	sd	a0,902(a5) # 8002a038 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cba:	03300613          	li	a2,51
    80001cbe:	00007597          	auipc	a1,0x7
    80001cc2:	34258593          	addi	a1,a1,834 # 80009000 <initcode>
    80001cc6:	6d28                	ld	a0,88(a0)
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	5d4080e7          	jalr	1492(ra) # 8000129c <uvminit>
  p->sz = PGSIZE;
    80001cd0:	6785                	lui	a5,0x1
    80001cd2:	e8bc                	sd	a5,80(s1)
  p->tf->epc = 0;      // user program counter
    80001cd4:	70b8                	ld	a4,96(s1)
    80001cd6:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001cda:	70b8                	ld	a4,96(s1)
    80001cdc:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cde:	4641                	li	a2,16
    80001ce0:	00006597          	auipc	a1,0x6
    80001ce4:	64058593          	addi	a1,a1,1600 # 80008320 <userret+0x290>
    80001ce8:	16048513          	addi	a0,s1,352
    80001cec:	fffff097          	auipc	ra,0xfffff
    80001cf0:	fe8080e7          	jalr	-24(ra) # 80000cd4 <safestrcpy>
  p->cwd = namei("/");
    80001cf4:	00006517          	auipc	a0,0x6
    80001cf8:	63c50513          	addi	a0,a0,1596 # 80008330 <userret+0x2a0>
    80001cfc:	00002097          	auipc	ra,0x2
    80001d00:	124080e7          	jalr	292(ra) # 80003e20 <namei>
    80001d04:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d08:	4789                	li	a5,2
    80001d0a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	e18080e7          	jalr	-488(ra) # 80000b26 <release>
}
    80001d16:	60e2                	ld	ra,24(sp)
    80001d18:	6442                	ld	s0,16(sp)
    80001d1a:	64a2                	ld	s1,8(sp)
    80001d1c:	6105                	addi	sp,sp,32
    80001d1e:	8082                	ret

0000000080001d20 <growproc>:
{
    80001d20:	1101                	addi	sp,sp,-32
    80001d22:	ec06                	sd	ra,24(sp)
    80001d24:	e822                	sd	s0,16(sp)
    80001d26:	e426                	sd	s1,8(sp)
    80001d28:	e04a                	sd	s2,0(sp)
    80001d2a:	1000                	addi	s0,sp,32
    80001d2c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d2e:	00000097          	auipc	ra,0x0
    80001d32:	cfc080e7          	jalr	-772(ra) # 80001a2a <myproc>
    80001d36:	892a                	mv	s2,a0
  sz = p->sz;
    80001d38:	692c                	ld	a1,80(a0)
    80001d3a:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d3e:	00904f63          	bgtz	s1,80001d5c <growproc+0x3c>
  } else if(n < 0){
    80001d42:	0204cc63          	bltz	s1,80001d7a <growproc+0x5a>
  p->sz = sz;
    80001d46:	1602                	slli	a2,a2,0x20
    80001d48:	9201                	srli	a2,a2,0x20
    80001d4a:	04c93823          	sd	a2,80(s2)
  return 0;
    80001d4e:	4501                	li	a0,0
}
    80001d50:	60e2                	ld	ra,24(sp)
    80001d52:	6442                	ld	s0,16(sp)
    80001d54:	64a2                	ld	s1,8(sp)
    80001d56:	6902                	ld	s2,0(sp)
    80001d58:	6105                	addi	sp,sp,32
    80001d5a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d5c:	9e25                	addw	a2,a2,s1
    80001d5e:	1602                	slli	a2,a2,0x20
    80001d60:	9201                	srli	a2,a2,0x20
    80001d62:	1582                	slli	a1,a1,0x20
    80001d64:	9181                	srli	a1,a1,0x20
    80001d66:	6d28                	ld	a0,88(a0)
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	5ea080e7          	jalr	1514(ra) # 80001352 <uvmalloc>
    80001d70:	0005061b          	sext.w	a2,a0
    80001d74:	fa69                	bnez	a2,80001d46 <growproc+0x26>
      return -1;
    80001d76:	557d                	li	a0,-1
    80001d78:	bfe1                	j	80001d50 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d7a:	9e25                	addw	a2,a2,s1
    80001d7c:	1602                	slli	a2,a2,0x20
    80001d7e:	9201                	srli	a2,a2,0x20
    80001d80:	1582                	slli	a1,a1,0x20
    80001d82:	9181                	srli	a1,a1,0x20
    80001d84:	6d28                	ld	a0,88(a0)
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	588080e7          	jalr	1416(ra) # 8000130e <uvmdealloc>
    80001d8e:	0005061b          	sext.w	a2,a0
    80001d92:	bf55                	j	80001d46 <growproc+0x26>

0000000080001d94 <fork>:
{
    80001d94:	7139                	addi	sp,sp,-64
    80001d96:	fc06                	sd	ra,56(sp)
    80001d98:	f822                	sd	s0,48(sp)
    80001d9a:	f426                	sd	s1,40(sp)
    80001d9c:	f04a                	sd	s2,32(sp)
    80001d9e:	ec4e                	sd	s3,24(sp)
    80001da0:	e852                	sd	s4,16(sp)
    80001da2:	e456                	sd	s5,8(sp)
    80001da4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001da6:	00000097          	auipc	ra,0x0
    80001daa:	c84080e7          	jalr	-892(ra) # 80001a2a <myproc>
    80001dae:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001db0:	00000097          	auipc	ra,0x0
    80001db4:	d9a080e7          	jalr	-614(ra) # 80001b4a <allocproc>
    80001db8:	c57d                	beqz	a0,80001ea6 <fork+0x112>
    80001dba:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dbc:	050ab603          	ld	a2,80(s5)
    80001dc0:	6d2c                	ld	a1,88(a0)
    80001dc2:	058ab503          	ld	a0,88(s5)
    80001dc6:	fffff097          	auipc	ra,0xfffff
    80001dca:	664080e7          	jalr	1636(ra) # 8000142a <uvmcopy>
    80001dce:	04054e63          	bltz	a0,80001e2a <fork+0x96>
  np->sz = p->sz;
    80001dd2:	050ab783          	ld	a5,80(s5)
    80001dd6:	04fa3823          	sd	a5,80(s4)
  np->parent = p;
    80001dda:	035a3023          	sd	s5,32(s4)
  *(np->tf) = *(p->tf);
    80001dde:	060ab683          	ld	a3,96(s5)
    80001de2:	87b6                	mv	a5,a3
    80001de4:	060a3703          	ld	a4,96(s4)
    80001de8:	12068693          	addi	a3,a3,288
    80001dec:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001df0:	6788                	ld	a0,8(a5)
    80001df2:	6b8c                	ld	a1,16(a5)
    80001df4:	6f90                	ld	a2,24(a5)
    80001df6:	01073023          	sd	a6,0(a4)
    80001dfa:	e708                	sd	a0,8(a4)
    80001dfc:	eb0c                	sd	a1,16(a4)
    80001dfe:	ef10                	sd	a2,24(a4)
    80001e00:	02078793          	addi	a5,a5,32
    80001e04:	02070713          	addi	a4,a4,32
    80001e08:	fed792e3          	bne	a5,a3,80001dec <fork+0x58>
  np->tf->a0 = 0;
    80001e0c:	060a3783          	ld	a5,96(s4)
    80001e10:	0607b823          	sd	zero,112(a5)
  np->ustack_top = p->ustack_top; // inherit the user stack top
    80001e14:	048ab783          	ld	a5,72(s5)
    80001e18:	04fa3423          	sd	a5,72(s4)
  for(i = 0; i < NOFILE; i++)
    80001e1c:	0d8a8493          	addi	s1,s5,216
    80001e20:	0d8a0913          	addi	s2,s4,216
    80001e24:	158a8993          	addi	s3,s5,344
    80001e28:	a00d                	j	80001e4a <fork+0xb6>
    freeproc(np);
    80001e2a:	8552                	mv	a0,s4
    80001e2c:	00000097          	auipc	ra,0x0
    80001e30:	e1a080e7          	jalr	-486(ra) # 80001c46 <freeproc>
    release(&np->lock);
    80001e34:	8552                	mv	a0,s4
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	cf0080e7          	jalr	-784(ra) # 80000b26 <release>
    return -1;
    80001e3e:	54fd                	li	s1,-1
    80001e40:	a889                	j	80001e92 <fork+0xfe>
  for(i = 0; i < NOFILE; i++)
    80001e42:	04a1                	addi	s1,s1,8
    80001e44:	0921                	addi	s2,s2,8
    80001e46:	01348b63          	beq	s1,s3,80001e5c <fork+0xc8>
    if(p->ofile[i])
    80001e4a:	6088                	ld	a0,0(s1)
    80001e4c:	d97d                	beqz	a0,80001e42 <fork+0xae>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e4e:	00003097          	auipc	ra,0x3
    80001e52:	8c4080e7          	jalr	-1852(ra) # 80004712 <filedup>
    80001e56:	00a93023          	sd	a0,0(s2)
    80001e5a:	b7e5                	j	80001e42 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001e5c:	158ab503          	ld	a0,344(s5)
    80001e60:	00001097          	auipc	ra,0x1
    80001e64:	7f8080e7          	jalr	2040(ra) # 80003658 <idup>
    80001e68:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e6c:	4641                	li	a2,16
    80001e6e:	160a8593          	addi	a1,s5,352
    80001e72:	160a0513          	addi	a0,s4,352
    80001e76:	fffff097          	auipc	ra,0xfffff
    80001e7a:	e5e080e7          	jalr	-418(ra) # 80000cd4 <safestrcpy>
  pid = np->pid;
    80001e7e:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001e82:	4789                	li	a5,2
    80001e84:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e88:	8552                	mv	a0,s4
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	c9c080e7          	jalr	-868(ra) # 80000b26 <release>
}
    80001e92:	8526                	mv	a0,s1
    80001e94:	70e2                	ld	ra,56(sp)
    80001e96:	7442                	ld	s0,48(sp)
    80001e98:	74a2                	ld	s1,40(sp)
    80001e9a:	7902                	ld	s2,32(sp)
    80001e9c:	69e2                	ld	s3,24(sp)
    80001e9e:	6a42                	ld	s4,16(sp)
    80001ea0:	6aa2                	ld	s5,8(sp)
    80001ea2:	6121                	addi	sp,sp,64
    80001ea4:	8082                	ret
    return -1;
    80001ea6:	54fd                	li	s1,-1
    80001ea8:	b7ed                	j	80001e92 <fork+0xfe>

0000000080001eaa <reparent>:
{
    80001eaa:	7179                	addi	sp,sp,-48
    80001eac:	f406                	sd	ra,40(sp)
    80001eae:	f022                	sd	s0,32(sp)
    80001eb0:	ec26                	sd	s1,24(sp)
    80001eb2:	e84a                	sd	s2,16(sp)
    80001eb4:	e44e                	sd	s3,8(sp)
    80001eb6:	e052                	sd	s4,0(sp)
    80001eb8:	1800                	addi	s0,sp,48
    80001eba:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ebc:	00011497          	auipc	s1,0x11
    80001ec0:	e4448493          	addi	s1,s1,-444 # 80012d00 <proc>
      pp->parent = initproc;
    80001ec4:	00028a17          	auipc	s4,0x28
    80001ec8:	174a0a13          	addi	s4,s4,372 # 8002a038 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ecc:	00017997          	auipc	s3,0x17
    80001ed0:	a3498993          	addi	s3,s3,-1484 # 80018900 <tickslock>
    80001ed4:	a029                	j	80001ede <reparent+0x34>
    80001ed6:	17048493          	addi	s1,s1,368
    80001eda:	03348363          	beq	s1,s3,80001f00 <reparent+0x56>
    if(pp->parent == p){
    80001ede:	709c                	ld	a5,32(s1)
    80001ee0:	ff279be3          	bne	a5,s2,80001ed6 <reparent+0x2c>
      acquire(&pp->lock);
    80001ee4:	8526                	mv	a0,s1
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	bd8080e7          	jalr	-1064(ra) # 80000abe <acquire>
      pp->parent = initproc;
    80001eee:	000a3783          	ld	a5,0(s4)
    80001ef2:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001ef4:	8526                	mv	a0,s1
    80001ef6:	fffff097          	auipc	ra,0xfffff
    80001efa:	c30080e7          	jalr	-976(ra) # 80000b26 <release>
    80001efe:	bfe1                	j	80001ed6 <reparent+0x2c>
}
    80001f00:	70a2                	ld	ra,40(sp)
    80001f02:	7402                	ld	s0,32(sp)
    80001f04:	64e2                	ld	s1,24(sp)
    80001f06:	6942                	ld	s2,16(sp)
    80001f08:	69a2                	ld	s3,8(sp)
    80001f0a:	6a02                	ld	s4,0(sp)
    80001f0c:	6145                	addi	sp,sp,48
    80001f0e:	8082                	ret

0000000080001f10 <scheduler>:
{
    80001f10:	715d                	addi	sp,sp,-80
    80001f12:	e486                	sd	ra,72(sp)
    80001f14:	e0a2                	sd	s0,64(sp)
    80001f16:	fc26                	sd	s1,56(sp)
    80001f18:	f84a                	sd	s2,48(sp)
    80001f1a:	f44e                	sd	s3,40(sp)
    80001f1c:	f052                	sd	s4,32(sp)
    80001f1e:	ec56                	sd	s5,24(sp)
    80001f20:	e85a                	sd	s6,16(sp)
    80001f22:	e45e                	sd	s7,8(sp)
    80001f24:	e062                	sd	s8,0(sp)
    80001f26:	0880                	addi	s0,sp,80
    80001f28:	8792                	mv	a5,tp
  int id = r_tp();
    80001f2a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f2c:	00779b13          	slli	s6,a5,0x7
    80001f30:	00011717          	auipc	a4,0x11
    80001f34:	9b870713          	addi	a4,a4,-1608 # 800128e8 <pid_lock>
    80001f38:	975a                	add	a4,a4,s6
    80001f3a:	00073c23          	sd	zero,24(a4)
        swtch(&c->scheduler, &p->context);
    80001f3e:	00011717          	auipc	a4,0x11
    80001f42:	9ca70713          	addi	a4,a4,-1590 # 80012908 <cpus+0x8>
    80001f46:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f48:	4c0d                	li	s8,3
        c->proc = p;
    80001f4a:	079e                	slli	a5,a5,0x7
    80001f4c:	00011a17          	auipc	s4,0x11
    80001f50:	99ca0a13          	addi	s4,s4,-1636 # 800128e8 <pid_lock>
    80001f54:	9a3e                	add	s4,s4,a5
        found = 1;
    80001f56:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f58:	00017997          	auipc	s3,0x17
    80001f5c:	9a898993          	addi	s3,s3,-1624 # 80018900 <tickslock>
    80001f60:	a08d                	j	80001fc2 <scheduler+0xb2>
      release(&p->lock);
    80001f62:	8526                	mv	a0,s1
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	bc2080e7          	jalr	-1086(ra) # 80000b26 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f6c:	17048493          	addi	s1,s1,368
    80001f70:	03348963          	beq	s1,s3,80001fa2 <scheduler+0x92>
      acquire(&p->lock);
    80001f74:	8526                	mv	a0,s1
    80001f76:	fffff097          	auipc	ra,0xfffff
    80001f7a:	b48080e7          	jalr	-1208(ra) # 80000abe <acquire>
      if(p->state == RUNNABLE) {
    80001f7e:	4c9c                	lw	a5,24(s1)
    80001f80:	ff2791e3          	bne	a5,s2,80001f62 <scheduler+0x52>
        p->state = RUNNING;
    80001f84:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001f88:	009a3c23          	sd	s1,24(s4)
        swtch(&c->scheduler, &p->context);
    80001f8c:	06848593          	addi	a1,s1,104
    80001f90:	855a                	mv	a0,s6
    80001f92:	00000097          	auipc	ra,0x0
    80001f96:	62a080e7          	jalr	1578(ra) # 800025bc <swtch>
        c->proc = 0;
    80001f9a:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001f9e:	8ade                	mv	s5,s7
    80001fa0:	b7c9                	j	80001f62 <scheduler+0x52>
    if(found == 0){
    80001fa2:	020a9063          	bnez	s5,80001fc2 <scheduler+0xb2>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001fa6:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001faa:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001fae:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fb2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fb6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fba:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001fbe:	10500073          	wfi
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001fc2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001fc6:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001fca:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fd2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fd6:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001fda:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fdc:	00011497          	auipc	s1,0x11
    80001fe0:	d2448493          	addi	s1,s1,-732 # 80012d00 <proc>
      if(p->state == RUNNABLE) {
    80001fe4:	4909                	li	s2,2
    80001fe6:	b779                	j	80001f74 <scheduler+0x64>

0000000080001fe8 <sched>:
{
    80001fe8:	7179                	addi	sp,sp,-48
    80001fea:	f406                	sd	ra,40(sp)
    80001fec:	f022                	sd	s0,32(sp)
    80001fee:	ec26                	sd	s1,24(sp)
    80001ff0:	e84a                	sd	s2,16(sp)
    80001ff2:	e44e                	sd	s3,8(sp)
    80001ff4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ff6:	00000097          	auipc	ra,0x0
    80001ffa:	a34080e7          	jalr	-1484(ra) # 80001a2a <myproc>
    80001ffe:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	a7e080e7          	jalr	-1410(ra) # 80000a7e <holding>
    80002008:	c93d                	beqz	a0,8000207e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000200a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000200c:	2781                	sext.w	a5,a5
    8000200e:	079e                	slli	a5,a5,0x7
    80002010:	00011717          	auipc	a4,0x11
    80002014:	8d870713          	addi	a4,a4,-1832 # 800128e8 <pid_lock>
    80002018:	97ba                	add	a5,a5,a4
    8000201a:	0907a703          	lw	a4,144(a5)
    8000201e:	4785                	li	a5,1
    80002020:	06f71763          	bne	a4,a5,8000208e <sched+0xa6>
  if(p->state == RUNNING)
    80002024:	4c98                	lw	a4,24(s1)
    80002026:	478d                	li	a5,3
    80002028:	06f70b63          	beq	a4,a5,8000209e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000202c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002030:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002032:	efb5                	bnez	a5,800020ae <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002034:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002036:	00011917          	auipc	s2,0x11
    8000203a:	8b290913          	addi	s2,s2,-1870 # 800128e8 <pid_lock>
    8000203e:	2781                	sext.w	a5,a5
    80002040:	079e                	slli	a5,a5,0x7
    80002042:	97ca                	add	a5,a5,s2
    80002044:	0947a983          	lw	s3,148(a5)
    80002048:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    8000204a:	2781                	sext.w	a5,a5
    8000204c:	079e                	slli	a5,a5,0x7
    8000204e:	00011597          	auipc	a1,0x11
    80002052:	8ba58593          	addi	a1,a1,-1862 # 80012908 <cpus+0x8>
    80002056:	95be                	add	a1,a1,a5
    80002058:	06848513          	addi	a0,s1,104
    8000205c:	00000097          	auipc	ra,0x0
    80002060:	560080e7          	jalr	1376(ra) # 800025bc <swtch>
    80002064:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002066:	2781                	sext.w	a5,a5
    80002068:	079e                	slli	a5,a5,0x7
    8000206a:	97ca                	add	a5,a5,s2
    8000206c:	0937aa23          	sw	s3,148(a5)
}
    80002070:	70a2                	ld	ra,40(sp)
    80002072:	7402                	ld	s0,32(sp)
    80002074:	64e2                	ld	s1,24(sp)
    80002076:	6942                	ld	s2,16(sp)
    80002078:	69a2                	ld	s3,8(sp)
    8000207a:	6145                	addi	sp,sp,48
    8000207c:	8082                	ret
    panic("sched p->lock");
    8000207e:	00006517          	auipc	a0,0x6
    80002082:	2ba50513          	addi	a0,a0,698 # 80008338 <userret+0x2a8>
    80002086:	ffffe097          	auipc	ra,0xffffe
    8000208a:	4c2080e7          	jalr	1218(ra) # 80000548 <panic>
    panic("sched locks");
    8000208e:	00006517          	auipc	a0,0x6
    80002092:	2ba50513          	addi	a0,a0,698 # 80008348 <userret+0x2b8>
    80002096:	ffffe097          	auipc	ra,0xffffe
    8000209a:	4b2080e7          	jalr	1202(ra) # 80000548 <panic>
    panic("sched running");
    8000209e:	00006517          	auipc	a0,0x6
    800020a2:	2ba50513          	addi	a0,a0,698 # 80008358 <userret+0x2c8>
    800020a6:	ffffe097          	auipc	ra,0xffffe
    800020aa:	4a2080e7          	jalr	1186(ra) # 80000548 <panic>
    panic("sched interruptible");
    800020ae:	00006517          	auipc	a0,0x6
    800020b2:	2ba50513          	addi	a0,a0,698 # 80008368 <userret+0x2d8>
    800020b6:	ffffe097          	auipc	ra,0xffffe
    800020ba:	492080e7          	jalr	1170(ra) # 80000548 <panic>

00000000800020be <exit>:
{
    800020be:	7179                	addi	sp,sp,-48
    800020c0:	f406                	sd	ra,40(sp)
    800020c2:	f022                	sd	s0,32(sp)
    800020c4:	ec26                	sd	s1,24(sp)
    800020c6:	e84a                	sd	s2,16(sp)
    800020c8:	e44e                	sd	s3,8(sp)
    800020ca:	e052                	sd	s4,0(sp)
    800020cc:	1800                	addi	s0,sp,48
    800020ce:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	95a080e7          	jalr	-1702(ra) # 80001a2a <myproc>
    800020d8:	89aa                	mv	s3,a0
  if(p == initproc)
    800020da:	00028797          	auipc	a5,0x28
    800020de:	f5e7b783          	ld	a5,-162(a5) # 8002a038 <initproc>
    800020e2:	0d850493          	addi	s1,a0,216
    800020e6:	15850913          	addi	s2,a0,344
    800020ea:	02a79363          	bne	a5,a0,80002110 <exit+0x52>
    panic("init exiting");
    800020ee:	00006517          	auipc	a0,0x6
    800020f2:	29250513          	addi	a0,a0,658 # 80008380 <userret+0x2f0>
    800020f6:	ffffe097          	auipc	ra,0xffffe
    800020fa:	452080e7          	jalr	1106(ra) # 80000548 <panic>
      fileclose(f);
    800020fe:	00002097          	auipc	ra,0x2
    80002102:	666080e7          	jalr	1638(ra) # 80004764 <fileclose>
      p->ofile[fd] = 0;
    80002106:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000210a:	04a1                	addi	s1,s1,8
    8000210c:	01248563          	beq	s1,s2,80002116 <exit+0x58>
    if(p->ofile[fd]){
    80002110:	6088                	ld	a0,0(s1)
    80002112:	f575                	bnez	a0,800020fe <exit+0x40>
    80002114:	bfdd                	j	8000210a <exit+0x4c>
  begin_op(ROOTDEV);
    80002116:	4501                	li	a0,0
    80002118:	00002097          	auipc	ra,0x2
    8000211c:	024080e7          	jalr	36(ra) # 8000413c <begin_op>
  iput(p->cwd);
    80002120:	1589b503          	ld	a0,344(s3)
    80002124:	00001097          	auipc	ra,0x1
    80002128:	680080e7          	jalr	1664(ra) # 800037a4 <iput>
  end_op(ROOTDEV);
    8000212c:	4501                	li	a0,0
    8000212e:	00002097          	auipc	ra,0x2
    80002132:	0b8080e7          	jalr	184(ra) # 800041e6 <end_op>
  p->cwd = 0;
    80002136:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    8000213a:	00028497          	auipc	s1,0x28
    8000213e:	efe48493          	addi	s1,s1,-258 # 8002a038 <initproc>
    80002142:	6088                	ld	a0,0(s1)
    80002144:	fffff097          	auipc	ra,0xfffff
    80002148:	97a080e7          	jalr	-1670(ra) # 80000abe <acquire>
  wakeup1(initproc);
    8000214c:	6088                	ld	a0,0(s1)
    8000214e:	fffff097          	auipc	ra,0xfffff
    80002152:	79c080e7          	jalr	1948(ra) # 800018ea <wakeup1>
  release(&initproc->lock);
    80002156:	6088                	ld	a0,0(s1)
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	9ce080e7          	jalr	-1586(ra) # 80000b26 <release>
  acquire(&p->lock);
    80002160:	854e                	mv	a0,s3
    80002162:	fffff097          	auipc	ra,0xfffff
    80002166:	95c080e7          	jalr	-1700(ra) # 80000abe <acquire>
  struct proc *original_parent = p->parent;
    8000216a:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    8000216e:	854e                	mv	a0,s3
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	9b6080e7          	jalr	-1610(ra) # 80000b26 <release>
  acquire(&original_parent->lock);
    80002178:	8526                	mv	a0,s1
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	944080e7          	jalr	-1724(ra) # 80000abe <acquire>
  acquire(&p->lock);
    80002182:	854e                	mv	a0,s3
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	93a080e7          	jalr	-1734(ra) # 80000abe <acquire>
  reparent(p);
    8000218c:	854e                	mv	a0,s3
    8000218e:	00000097          	auipc	ra,0x0
    80002192:	d1c080e7          	jalr	-740(ra) # 80001eaa <reparent>
  wakeup1(original_parent);
    80002196:	8526                	mv	a0,s1
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	752080e7          	jalr	1874(ra) # 800018ea <wakeup1>
  p->xstate = status;
    800021a0:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800021a4:	4791                	li	a5,4
    800021a6:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800021aa:	8526                	mv	a0,s1
    800021ac:	fffff097          	auipc	ra,0xfffff
    800021b0:	97a080e7          	jalr	-1670(ra) # 80000b26 <release>
  sched();
    800021b4:	00000097          	auipc	ra,0x0
    800021b8:	e34080e7          	jalr	-460(ra) # 80001fe8 <sched>
  panic("zombie exit");
    800021bc:	00006517          	auipc	a0,0x6
    800021c0:	1d450513          	addi	a0,a0,468 # 80008390 <userret+0x300>
    800021c4:	ffffe097          	auipc	ra,0xffffe
    800021c8:	384080e7          	jalr	900(ra) # 80000548 <panic>

00000000800021cc <yield>:
{
    800021cc:	1101                	addi	sp,sp,-32
    800021ce:	ec06                	sd	ra,24(sp)
    800021d0:	e822                	sd	s0,16(sp)
    800021d2:	e426                	sd	s1,8(sp)
    800021d4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021d6:	00000097          	auipc	ra,0x0
    800021da:	854080e7          	jalr	-1964(ra) # 80001a2a <myproc>
    800021de:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	8de080e7          	jalr	-1826(ra) # 80000abe <acquire>
  p->state = RUNNABLE;
    800021e8:	4789                	li	a5,2
    800021ea:	cc9c                	sw	a5,24(s1)
  sched();
    800021ec:	00000097          	auipc	ra,0x0
    800021f0:	dfc080e7          	jalr	-516(ra) # 80001fe8 <sched>
  release(&p->lock);
    800021f4:	8526                	mv	a0,s1
    800021f6:	fffff097          	auipc	ra,0xfffff
    800021fa:	930080e7          	jalr	-1744(ra) # 80000b26 <release>
}
    800021fe:	60e2                	ld	ra,24(sp)
    80002200:	6442                	ld	s0,16(sp)
    80002202:	64a2                	ld	s1,8(sp)
    80002204:	6105                	addi	sp,sp,32
    80002206:	8082                	ret

0000000080002208 <sleep>:
{
    80002208:	7179                	addi	sp,sp,-48
    8000220a:	f406                	sd	ra,40(sp)
    8000220c:	f022                	sd	s0,32(sp)
    8000220e:	ec26                	sd	s1,24(sp)
    80002210:	e84a                	sd	s2,16(sp)
    80002212:	e44e                	sd	s3,8(sp)
    80002214:	1800                	addi	s0,sp,48
    80002216:	89aa                	mv	s3,a0
    80002218:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000221a:	00000097          	auipc	ra,0x0
    8000221e:	810080e7          	jalr	-2032(ra) # 80001a2a <myproc>
    80002222:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002224:	05250663          	beq	a0,s2,80002270 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	896080e7          	jalr	-1898(ra) # 80000abe <acquire>
    release(lk);
    80002230:	854a                	mv	a0,s2
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	8f4080e7          	jalr	-1804(ra) # 80000b26 <release>
  p->chan = chan;
    8000223a:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000223e:	4785                	li	a5,1
    80002240:	cc9c                	sw	a5,24(s1)
  sched();
    80002242:	00000097          	auipc	ra,0x0
    80002246:	da6080e7          	jalr	-602(ra) # 80001fe8 <sched>
  p->chan = 0;
    8000224a:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    8000224e:	8526                	mv	a0,s1
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	8d6080e7          	jalr	-1834(ra) # 80000b26 <release>
    acquire(lk);
    80002258:	854a                	mv	a0,s2
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	864080e7          	jalr	-1948(ra) # 80000abe <acquire>
}
    80002262:	70a2                	ld	ra,40(sp)
    80002264:	7402                	ld	s0,32(sp)
    80002266:	64e2                	ld	s1,24(sp)
    80002268:	6942                	ld	s2,16(sp)
    8000226a:	69a2                	ld	s3,8(sp)
    8000226c:	6145                	addi	sp,sp,48
    8000226e:	8082                	ret
  p->chan = chan;
    80002270:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002274:	4785                	li	a5,1
    80002276:	cd1c                	sw	a5,24(a0)
  sched();
    80002278:	00000097          	auipc	ra,0x0
    8000227c:	d70080e7          	jalr	-656(ra) # 80001fe8 <sched>
  p->chan = 0;
    80002280:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002284:	bff9                	j	80002262 <sleep+0x5a>

0000000080002286 <wait>:
{
    80002286:	715d                	addi	sp,sp,-80
    80002288:	e486                	sd	ra,72(sp)
    8000228a:	e0a2                	sd	s0,64(sp)
    8000228c:	fc26                	sd	s1,56(sp)
    8000228e:	f84a                	sd	s2,48(sp)
    80002290:	f44e                	sd	s3,40(sp)
    80002292:	f052                	sd	s4,32(sp)
    80002294:	ec56                	sd	s5,24(sp)
    80002296:	e85a                	sd	s6,16(sp)
    80002298:	e45e                	sd	s7,8(sp)
    8000229a:	0880                	addi	s0,sp,80
    8000229c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	78c080e7          	jalr	1932(ra) # 80001a2a <myproc>
    800022a6:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	816080e7          	jalr	-2026(ra) # 80000abe <acquire>
    havekids = 0;
    800022b0:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022b2:	4a11                	li	s4,4
        havekids = 1;
    800022b4:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800022b6:	00016997          	auipc	s3,0x16
    800022ba:	64a98993          	addi	s3,s3,1610 # 80018900 <tickslock>
    havekids = 0;
    800022be:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022c0:	00011497          	auipc	s1,0x11
    800022c4:	a4048493          	addi	s1,s1,-1472 # 80012d00 <proc>
    800022c8:	a08d                	j	8000232a <wait+0xa4>
          pid = np->pid;
    800022ca:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022ce:	000b0e63          	beqz	s6,800022ea <wait+0x64>
    800022d2:	4691                	li	a3,4
    800022d4:	03448613          	addi	a2,s1,52
    800022d8:	85da                	mv	a1,s6
    800022da:	05893503          	ld	a0,88(s2)
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	4b4080e7          	jalr	1204(ra) # 80001792 <copyout>
    800022e6:	02054263          	bltz	a0,8000230a <wait+0x84>
          freeproc(np);
    800022ea:	8526                	mv	a0,s1
    800022ec:	00000097          	auipc	ra,0x0
    800022f0:	95a080e7          	jalr	-1702(ra) # 80001c46 <freeproc>
          release(&np->lock);
    800022f4:	8526                	mv	a0,s1
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	830080e7          	jalr	-2000(ra) # 80000b26 <release>
          release(&p->lock);
    800022fe:	854a                	mv	a0,s2
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	826080e7          	jalr	-2010(ra) # 80000b26 <release>
          return pid;
    80002308:	a8a9                	j	80002362 <wait+0xdc>
            release(&np->lock);
    8000230a:	8526                	mv	a0,s1
    8000230c:	fffff097          	auipc	ra,0xfffff
    80002310:	81a080e7          	jalr	-2022(ra) # 80000b26 <release>
            release(&p->lock);
    80002314:	854a                	mv	a0,s2
    80002316:	fffff097          	auipc	ra,0xfffff
    8000231a:	810080e7          	jalr	-2032(ra) # 80000b26 <release>
            return -1;
    8000231e:	59fd                	li	s3,-1
    80002320:	a089                	j	80002362 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002322:	17048493          	addi	s1,s1,368
    80002326:	03348463          	beq	s1,s3,8000234e <wait+0xc8>
      if(np->parent == p){
    8000232a:	709c                	ld	a5,32(s1)
    8000232c:	ff279be3          	bne	a5,s2,80002322 <wait+0x9c>
        acquire(&np->lock);
    80002330:	8526                	mv	a0,s1
    80002332:	ffffe097          	auipc	ra,0xffffe
    80002336:	78c080e7          	jalr	1932(ra) # 80000abe <acquire>
        if(np->state == ZOMBIE){
    8000233a:	4c9c                	lw	a5,24(s1)
    8000233c:	f94787e3          	beq	a5,s4,800022ca <wait+0x44>
        release(&np->lock);
    80002340:	8526                	mv	a0,s1
    80002342:	ffffe097          	auipc	ra,0xffffe
    80002346:	7e4080e7          	jalr	2020(ra) # 80000b26 <release>
        havekids = 1;
    8000234a:	8756                	mv	a4,s5
    8000234c:	bfd9                	j	80002322 <wait+0x9c>
    if(!havekids || p->killed){
    8000234e:	c701                	beqz	a4,80002356 <wait+0xd0>
    80002350:	03092783          	lw	a5,48(s2)
    80002354:	c39d                	beqz	a5,8000237a <wait+0xf4>
      release(&p->lock);
    80002356:	854a                	mv	a0,s2
    80002358:	ffffe097          	auipc	ra,0xffffe
    8000235c:	7ce080e7          	jalr	1998(ra) # 80000b26 <release>
      return -1;
    80002360:	59fd                	li	s3,-1
}
    80002362:	854e                	mv	a0,s3
    80002364:	60a6                	ld	ra,72(sp)
    80002366:	6406                	ld	s0,64(sp)
    80002368:	74e2                	ld	s1,56(sp)
    8000236a:	7942                	ld	s2,48(sp)
    8000236c:	79a2                	ld	s3,40(sp)
    8000236e:	7a02                	ld	s4,32(sp)
    80002370:	6ae2                	ld	s5,24(sp)
    80002372:	6b42                	ld	s6,16(sp)
    80002374:	6ba2                	ld	s7,8(sp)
    80002376:	6161                	addi	sp,sp,80
    80002378:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000237a:	85ca                	mv	a1,s2
    8000237c:	854a                	mv	a0,s2
    8000237e:	00000097          	auipc	ra,0x0
    80002382:	e8a080e7          	jalr	-374(ra) # 80002208 <sleep>
    havekids = 0;
    80002386:	bf25                	j	800022be <wait+0x38>

0000000080002388 <wakeup>:
{
    80002388:	7139                	addi	sp,sp,-64
    8000238a:	fc06                	sd	ra,56(sp)
    8000238c:	f822                	sd	s0,48(sp)
    8000238e:	f426                	sd	s1,40(sp)
    80002390:	f04a                	sd	s2,32(sp)
    80002392:	ec4e                	sd	s3,24(sp)
    80002394:	e852                	sd	s4,16(sp)
    80002396:	e456                	sd	s5,8(sp)
    80002398:	0080                	addi	s0,sp,64
    8000239a:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000239c:	00011497          	auipc	s1,0x11
    800023a0:	96448493          	addi	s1,s1,-1692 # 80012d00 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023a4:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023a6:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023a8:	00016917          	auipc	s2,0x16
    800023ac:	55890913          	addi	s2,s2,1368 # 80018900 <tickslock>
    800023b0:	a811                	j	800023c4 <wakeup+0x3c>
    release(&p->lock);
    800023b2:	8526                	mv	a0,s1
    800023b4:	ffffe097          	auipc	ra,0xffffe
    800023b8:	772080e7          	jalr	1906(ra) # 80000b26 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023bc:	17048493          	addi	s1,s1,368
    800023c0:	03248063          	beq	s1,s2,800023e0 <wakeup+0x58>
    acquire(&p->lock);
    800023c4:	8526                	mv	a0,s1
    800023c6:	ffffe097          	auipc	ra,0xffffe
    800023ca:	6f8080e7          	jalr	1784(ra) # 80000abe <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800023ce:	4c9c                	lw	a5,24(s1)
    800023d0:	ff3791e3          	bne	a5,s3,800023b2 <wakeup+0x2a>
    800023d4:	749c                	ld	a5,40(s1)
    800023d6:	fd479ee3          	bne	a5,s4,800023b2 <wakeup+0x2a>
      p->state = RUNNABLE;
    800023da:	0154ac23          	sw	s5,24(s1)
    800023de:	bfd1                	j	800023b2 <wakeup+0x2a>
}
    800023e0:	70e2                	ld	ra,56(sp)
    800023e2:	7442                	ld	s0,48(sp)
    800023e4:	74a2                	ld	s1,40(sp)
    800023e6:	7902                	ld	s2,32(sp)
    800023e8:	69e2                	ld	s3,24(sp)
    800023ea:	6a42                	ld	s4,16(sp)
    800023ec:	6aa2                	ld	s5,8(sp)
    800023ee:	6121                	addi	sp,sp,64
    800023f0:	8082                	ret

00000000800023f2 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023f2:	7179                	addi	sp,sp,-48
    800023f4:	f406                	sd	ra,40(sp)
    800023f6:	f022                	sd	s0,32(sp)
    800023f8:	ec26                	sd	s1,24(sp)
    800023fa:	e84a                	sd	s2,16(sp)
    800023fc:	e44e                	sd	s3,8(sp)
    800023fe:	1800                	addi	s0,sp,48
    80002400:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002402:	00011497          	auipc	s1,0x11
    80002406:	8fe48493          	addi	s1,s1,-1794 # 80012d00 <proc>
    8000240a:	00016997          	auipc	s3,0x16
    8000240e:	4f698993          	addi	s3,s3,1270 # 80018900 <tickslock>
    acquire(&p->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	ffffe097          	auipc	ra,0xffffe
    80002418:	6aa080e7          	jalr	1706(ra) # 80000abe <acquire>
    if(p->pid == pid){
    8000241c:	5c9c                	lw	a5,56(s1)
    8000241e:	01278d63          	beq	a5,s2,80002438 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002422:	8526                	mv	a0,s1
    80002424:	ffffe097          	auipc	ra,0xffffe
    80002428:	702080e7          	jalr	1794(ra) # 80000b26 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000242c:	17048493          	addi	s1,s1,368
    80002430:	ff3491e3          	bne	s1,s3,80002412 <kill+0x20>
  }
  return -1;
    80002434:	557d                	li	a0,-1
    80002436:	a821                	j	8000244e <kill+0x5c>
      p->killed = 1;
    80002438:	4785                	li	a5,1
    8000243a:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000243c:	4c98                	lw	a4,24(s1)
    8000243e:	00f70f63          	beq	a4,a5,8000245c <kill+0x6a>
      release(&p->lock);
    80002442:	8526                	mv	a0,s1
    80002444:	ffffe097          	auipc	ra,0xffffe
    80002448:	6e2080e7          	jalr	1762(ra) # 80000b26 <release>
      return 0;
    8000244c:	4501                	li	a0,0
}
    8000244e:	70a2                	ld	ra,40(sp)
    80002450:	7402                	ld	s0,32(sp)
    80002452:	64e2                	ld	s1,24(sp)
    80002454:	6942                	ld	s2,16(sp)
    80002456:	69a2                	ld	s3,8(sp)
    80002458:	6145                	addi	sp,sp,48
    8000245a:	8082                	ret
        p->state = RUNNABLE;
    8000245c:	4789                	li	a5,2
    8000245e:	cc9c                	sw	a5,24(s1)
    80002460:	b7cd                	j	80002442 <kill+0x50>

0000000080002462 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002462:	7179                	addi	sp,sp,-48
    80002464:	f406                	sd	ra,40(sp)
    80002466:	f022                	sd	s0,32(sp)
    80002468:	ec26                	sd	s1,24(sp)
    8000246a:	e84a                	sd	s2,16(sp)
    8000246c:	e44e                	sd	s3,8(sp)
    8000246e:	e052                	sd	s4,0(sp)
    80002470:	1800                	addi	s0,sp,48
    80002472:	84aa                	mv	s1,a0
    80002474:	892e                	mv	s2,a1
    80002476:	89b2                	mv	s3,a2
    80002478:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	5b0080e7          	jalr	1456(ra) # 80001a2a <myproc>
  if(user_dst){
    80002482:	c08d                	beqz	s1,800024a4 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002484:	86d2                	mv	a3,s4
    80002486:	864e                	mv	a2,s3
    80002488:	85ca                	mv	a1,s2
    8000248a:	6d28                	ld	a0,88(a0)
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	306080e7          	jalr	774(ra) # 80001792 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002494:	70a2                	ld	ra,40(sp)
    80002496:	7402                	ld	s0,32(sp)
    80002498:	64e2                	ld	s1,24(sp)
    8000249a:	6942                	ld	s2,16(sp)
    8000249c:	69a2                	ld	s3,8(sp)
    8000249e:	6a02                	ld	s4,0(sp)
    800024a0:	6145                	addi	sp,sp,48
    800024a2:	8082                	ret
    memmove((char *)dst, src, len);
    800024a4:	000a061b          	sext.w	a2,s4
    800024a8:	85ce                	mv	a1,s3
    800024aa:	854a                	mv	a0,s2
    800024ac:	ffffe097          	auipc	ra,0xffffe
    800024b0:	732080e7          	jalr	1842(ra) # 80000bde <memmove>
    return 0;
    800024b4:	8526                	mv	a0,s1
    800024b6:	bff9                	j	80002494 <either_copyout+0x32>

00000000800024b8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024b8:	7179                	addi	sp,sp,-48
    800024ba:	f406                	sd	ra,40(sp)
    800024bc:	f022                	sd	s0,32(sp)
    800024be:	ec26                	sd	s1,24(sp)
    800024c0:	e84a                	sd	s2,16(sp)
    800024c2:	e44e                	sd	s3,8(sp)
    800024c4:	e052                	sd	s4,0(sp)
    800024c6:	1800                	addi	s0,sp,48
    800024c8:	892a                	mv	s2,a0
    800024ca:	84ae                	mv	s1,a1
    800024cc:	89b2                	mv	s3,a2
    800024ce:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	55a080e7          	jalr	1370(ra) # 80001a2a <myproc>
  if(user_src){
    800024d8:	c08d                	beqz	s1,800024fa <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024da:	86d2                	mv	a3,s4
    800024dc:	864e                	mv	a2,s3
    800024de:	85ca                	mv	a1,s2
    800024e0:	6d28                	ld	a0,88(a0)
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	35c080e7          	jalr	860(ra) # 8000183e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024ea:	70a2                	ld	ra,40(sp)
    800024ec:	7402                	ld	s0,32(sp)
    800024ee:	64e2                	ld	s1,24(sp)
    800024f0:	6942                	ld	s2,16(sp)
    800024f2:	69a2                	ld	s3,8(sp)
    800024f4:	6a02                	ld	s4,0(sp)
    800024f6:	6145                	addi	sp,sp,48
    800024f8:	8082                	ret
    memmove(dst, (char*)src, len);
    800024fa:	000a061b          	sext.w	a2,s4
    800024fe:	85ce                	mv	a1,s3
    80002500:	854a                	mv	a0,s2
    80002502:	ffffe097          	auipc	ra,0xffffe
    80002506:	6dc080e7          	jalr	1756(ra) # 80000bde <memmove>
    return 0;
    8000250a:	8526                	mv	a0,s1
    8000250c:	bff9                	j	800024ea <either_copyin+0x32>

000000008000250e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000250e:	715d                	addi	sp,sp,-80
    80002510:	e486                	sd	ra,72(sp)
    80002512:	e0a2                	sd	s0,64(sp)
    80002514:	fc26                	sd	s1,56(sp)
    80002516:	f84a                	sd	s2,48(sp)
    80002518:	f44e                	sd	s3,40(sp)
    8000251a:	f052                	sd	s4,32(sp)
    8000251c:	ec56                	sd	s5,24(sp)
    8000251e:	e85a                	sd	s6,16(sp)
    80002520:	e45e                	sd	s7,8(sp)
    80002522:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002524:	00006517          	auipc	a0,0x6
    80002528:	c8c50513          	addi	a0,a0,-884 # 800081b0 <userret+0x120>
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	066080e7          	jalr	102(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002534:	00011497          	auipc	s1,0x11
    80002538:	92c48493          	addi	s1,s1,-1748 # 80012e60 <proc+0x160>
    8000253c:	00016917          	auipc	s2,0x16
    80002540:	52490913          	addi	s2,s2,1316 # 80018a60 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002544:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002546:	00006997          	auipc	s3,0x6
    8000254a:	e5a98993          	addi	s3,s3,-422 # 800083a0 <userret+0x310>
    printf("%d %s %s", p->pid, state, p->name);
    8000254e:	00006a97          	auipc	s5,0x6
    80002552:	e5aa8a93          	addi	s5,s5,-422 # 800083a8 <userret+0x318>
    printf("\n");
    80002556:	00006a17          	auipc	s4,0x6
    8000255a:	c5aa0a13          	addi	s4,s4,-934 # 800081b0 <userret+0x120>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000255e:	00006b97          	auipc	s7,0x6
    80002562:	4f2b8b93          	addi	s7,s7,1266 # 80008a50 <states.0>
    80002566:	a00d                	j	80002588 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002568:	ed86a583          	lw	a1,-296(a3)
    8000256c:	8556                	mv	a0,s5
    8000256e:	ffffe097          	auipc	ra,0xffffe
    80002572:	024080e7          	jalr	36(ra) # 80000592 <printf>
    printf("\n");
    80002576:	8552                	mv	a0,s4
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	01a080e7          	jalr	26(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002580:	17048493          	addi	s1,s1,368
    80002584:	03248163          	beq	s1,s2,800025a6 <procdump+0x98>
    if(p->state == UNUSED)
    80002588:	86a6                	mv	a3,s1
    8000258a:	eb84a783          	lw	a5,-328(s1)
    8000258e:	dbed                	beqz	a5,80002580 <procdump+0x72>
      state = "???";
    80002590:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002592:	fcfb6be3          	bltu	s6,a5,80002568 <procdump+0x5a>
    80002596:	1782                	slli	a5,a5,0x20
    80002598:	9381                	srli	a5,a5,0x20
    8000259a:	078e                	slli	a5,a5,0x3
    8000259c:	97de                	add	a5,a5,s7
    8000259e:	6390                	ld	a2,0(a5)
    800025a0:	f661                	bnez	a2,80002568 <procdump+0x5a>
      state = "???";
    800025a2:	864e                	mv	a2,s3
    800025a4:	b7d1                	j	80002568 <procdump+0x5a>
  }
}
    800025a6:	60a6                	ld	ra,72(sp)
    800025a8:	6406                	ld	s0,64(sp)
    800025aa:	74e2                	ld	s1,56(sp)
    800025ac:	7942                	ld	s2,48(sp)
    800025ae:	79a2                	ld	s3,40(sp)
    800025b0:	7a02                	ld	s4,32(sp)
    800025b2:	6ae2                	ld	s5,24(sp)
    800025b4:	6b42                	ld	s6,16(sp)
    800025b6:	6ba2                	ld	s7,8(sp)
    800025b8:	6161                	addi	sp,sp,80
    800025ba:	8082                	ret

00000000800025bc <swtch>:
    800025bc:	00153023          	sd	ra,0(a0)
    800025c0:	00253423          	sd	sp,8(a0)
    800025c4:	e900                	sd	s0,16(a0)
    800025c6:	ed04                	sd	s1,24(a0)
    800025c8:	03253023          	sd	s2,32(a0)
    800025cc:	03353423          	sd	s3,40(a0)
    800025d0:	03453823          	sd	s4,48(a0)
    800025d4:	03553c23          	sd	s5,56(a0)
    800025d8:	05653023          	sd	s6,64(a0)
    800025dc:	05753423          	sd	s7,72(a0)
    800025e0:	05853823          	sd	s8,80(a0)
    800025e4:	05953c23          	sd	s9,88(a0)
    800025e8:	07a53023          	sd	s10,96(a0)
    800025ec:	07b53423          	sd	s11,104(a0)
    800025f0:	0005b083          	ld	ra,0(a1)
    800025f4:	0085b103          	ld	sp,8(a1)
    800025f8:	6980                	ld	s0,16(a1)
    800025fa:	6d84                	ld	s1,24(a1)
    800025fc:	0205b903          	ld	s2,32(a1)
    80002600:	0285b983          	ld	s3,40(a1)
    80002604:	0305ba03          	ld	s4,48(a1)
    80002608:	0385ba83          	ld	s5,56(a1)
    8000260c:	0405bb03          	ld	s6,64(a1)
    80002610:	0485bb83          	ld	s7,72(a1)
    80002614:	0505bc03          	ld	s8,80(a1)
    80002618:	0585bc83          	ld	s9,88(a1)
    8000261c:	0605bd03          	ld	s10,96(a1)
    80002620:	0685bd83          	ld	s11,104(a1)
    80002624:	8082                	ret

0000000080002626 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002626:	1141                	addi	sp,sp,-16
    80002628:	e406                	sd	ra,8(sp)
    8000262a:	e022                	sd	s0,0(sp)
    8000262c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000262e:	00006597          	auipc	a1,0x6
    80002632:	db258593          	addi	a1,a1,-590 # 800083e0 <userret+0x350>
    80002636:	00016517          	auipc	a0,0x16
    8000263a:	2ca50513          	addi	a0,a0,714 # 80018900 <tickslock>
    8000263e:	ffffe097          	auipc	ra,0xffffe
    80002642:	372080e7          	jalr	882(ra) # 800009b0 <initlock>
}
    80002646:	60a2                	ld	ra,8(sp)
    80002648:	6402                	ld	s0,0(sp)
    8000264a:	0141                	addi	sp,sp,16
    8000264c:	8082                	ret

000000008000264e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000264e:	1141                	addi	sp,sp,-16
    80002650:	e422                	sd	s0,8(sp)
    80002652:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002654:	00004797          	auipc	a5,0x4
    80002658:	83c78793          	addi	a5,a5,-1988 # 80005e90 <kernelvec>
    8000265c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002660:	6422                	ld	s0,8(sp)
    80002662:	0141                	addi	sp,sp,16
    80002664:	8082                	ret

0000000080002666 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002666:	1141                	addi	sp,sp,-16
    80002668:	e406                	sd	ra,8(sp)
    8000266a:	e022                	sd	s0,0(sp)
    8000266c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000266e:	fffff097          	auipc	ra,0xfffff
    80002672:	3bc080e7          	jalr	956(ra) # 80001a2a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002676:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000267a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000267c:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002680:	00006617          	auipc	a2,0x6
    80002684:	98060613          	addi	a2,a2,-1664 # 80008000 <trampoline>
    80002688:	00006697          	auipc	a3,0x6
    8000268c:	97868693          	addi	a3,a3,-1672 # 80008000 <trampoline>
    80002690:	8e91                	sub	a3,a3,a2
    80002692:	040007b7          	lui	a5,0x4000
    80002696:	17fd                	addi	a5,a5,-1
    80002698:	07b2                	slli	a5,a5,0xc
    8000269a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000269c:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    800026a0:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026a2:	180026f3          	csrr	a3,satp
    800026a6:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026a8:	7138                	ld	a4,96(a0)
    800026aa:	6134                	ld	a3,64(a0)
    800026ac:	6585                	lui	a1,0x1
    800026ae:	96ae                	add	a3,a3,a1
    800026b0:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    800026b2:	7138                	ld	a4,96(a0)
    800026b4:	00000697          	auipc	a3,0x0
    800026b8:	12868693          	addi	a3,a3,296 # 800027dc <usertrap>
    800026bc:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    800026be:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026c0:	8692                	mv	a3,tp
    800026c2:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c4:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026c8:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026cc:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d0:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    800026d4:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026d6:	6f18                	ld	a4,24(a4)
    800026d8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026dc:	6d2c                	ld	a1,88(a0)
    800026de:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800026e0:	00006717          	auipc	a4,0x6
    800026e4:	9b070713          	addi	a4,a4,-1616 # 80008090 <userret>
    800026e8:	8f11                	sub	a4,a4,a2
    800026ea:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800026ec:	577d                	li	a4,-1
    800026ee:	177e                	slli	a4,a4,0x3f
    800026f0:	8dd9                	or	a1,a1,a4
    800026f2:	02000537          	lui	a0,0x2000
    800026f6:	157d                	addi	a0,a0,-1
    800026f8:	0536                	slli	a0,a0,0xd
    800026fa:	9782                	jalr	a5
}
    800026fc:	60a2                	ld	ra,8(sp)
    800026fe:	6402                	ld	s0,0(sp)
    80002700:	0141                	addi	sp,sp,16
    80002702:	8082                	ret

0000000080002704 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002704:	1101                	addi	sp,sp,-32
    80002706:	ec06                	sd	ra,24(sp)
    80002708:	e822                	sd	s0,16(sp)
    8000270a:	e426                	sd	s1,8(sp)
    8000270c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000270e:	00016497          	auipc	s1,0x16
    80002712:	1f248493          	addi	s1,s1,498 # 80018900 <tickslock>
    80002716:	8526                	mv	a0,s1
    80002718:	ffffe097          	auipc	ra,0xffffe
    8000271c:	3a6080e7          	jalr	934(ra) # 80000abe <acquire>
  ticks++;
    80002720:	00028517          	auipc	a0,0x28
    80002724:	92050513          	addi	a0,a0,-1760 # 8002a040 <ticks>
    80002728:	411c                	lw	a5,0(a0)
    8000272a:	2785                	addiw	a5,a5,1
    8000272c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000272e:	00000097          	auipc	ra,0x0
    80002732:	c5a080e7          	jalr	-934(ra) # 80002388 <wakeup>
  release(&tickslock);
    80002736:	8526                	mv	a0,s1
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	3ee080e7          	jalr	1006(ra) # 80000b26 <release>
}
    80002740:	60e2                	ld	ra,24(sp)
    80002742:	6442                	ld	s0,16(sp)
    80002744:	64a2                	ld	s1,8(sp)
    80002746:	6105                	addi	sp,sp,32
    80002748:	8082                	ret

000000008000274a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000274a:	1101                	addi	sp,sp,-32
    8000274c:	ec06                	sd	ra,24(sp)
    8000274e:	e822                	sd	s0,16(sp)
    80002750:	e426                	sd	s1,8(sp)
    80002752:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002754:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002758:	00074d63          	bltz	a4,80002772 <devintr+0x28>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    }

    plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000001L){
    8000275c:	57fd                	li	a5,-1
    8000275e:	17fe                	slli	a5,a5,0x3f
    80002760:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002762:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002764:	04f70b63          	beq	a4,a5,800027ba <devintr+0x70>
  }
}
    80002768:	60e2                	ld	ra,24(sp)
    8000276a:	6442                	ld	s0,16(sp)
    8000276c:	64a2                	ld	s1,8(sp)
    8000276e:	6105                	addi	sp,sp,32
    80002770:	8082                	ret
     (scause & 0xff) == 9){
    80002772:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002776:	46a5                	li	a3,9
    80002778:	fed792e3          	bne	a5,a3,8000275c <devintr+0x12>
    int irq = plic_claim();
    8000277c:	00004097          	auipc	ra,0x4
    80002780:	82e080e7          	jalr	-2002(ra) # 80005faa <plic_claim>
    80002784:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002786:	47a9                	li	a5,10
    80002788:	00f50e63          	beq	a0,a5,800027a4 <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    8000278c:	fff5079b          	addiw	a5,a0,-1
    80002790:	4705                	li	a4,1
    80002792:	00f77e63          	bgeu	a4,a5,800027ae <devintr+0x64>
    plic_complete(irq);
    80002796:	8526                	mv	a0,s1
    80002798:	00004097          	auipc	ra,0x4
    8000279c:	836080e7          	jalr	-1994(ra) # 80005fce <plic_complete>
    return 1;
    800027a0:	4505                	li	a0,1
    800027a2:	b7d9                	j	80002768 <devintr+0x1e>
      uartintr();
    800027a4:	ffffe097          	auipc	ra,0xffffe
    800027a8:	084080e7          	jalr	132(ra) # 80000828 <uartintr>
    800027ac:	b7ed                	j	80002796 <devintr+0x4c>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800027ae:	853e                	mv	a0,a5
    800027b0:	00004097          	auipc	ra,0x4
    800027b4:	dc8080e7          	jalr	-568(ra) # 80006578 <virtio_disk_intr>
    800027b8:	bff9                	j	80002796 <devintr+0x4c>
    if(cpuid() == 0){
    800027ba:	fffff097          	auipc	ra,0xfffff
    800027be:	244080e7          	jalr	580(ra) # 800019fe <cpuid>
    800027c2:	c901                	beqz	a0,800027d2 <devintr+0x88>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027c4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027c8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027ca:	14479073          	csrw	sip,a5
    return 2;
    800027ce:	4509                	li	a0,2
    800027d0:	bf61                	j	80002768 <devintr+0x1e>
      clockintr();
    800027d2:	00000097          	auipc	ra,0x0
    800027d6:	f32080e7          	jalr	-206(ra) # 80002704 <clockintr>
    800027da:	b7ed                	j	800027c4 <devintr+0x7a>

00000000800027dc <usertrap>:
{
    800027dc:	1101                	addi	sp,sp,-32
    800027de:	ec06                	sd	ra,24(sp)
    800027e0:	e822                	sd	s0,16(sp)
    800027e2:	e426                	sd	s1,8(sp)
    800027e4:	e04a                	sd	s2,0(sp)
    800027e6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027e8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027ec:	1007f793          	andi	a5,a5,256
    800027f0:	e7bd                	bnez	a5,8000285e <usertrap+0x82>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027f2:	00003797          	auipc	a5,0x3
    800027f6:	69e78793          	addi	a5,a5,1694 # 80005e90 <kernelvec>
    800027fa:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027fe:	fffff097          	auipc	ra,0xfffff
    80002802:	22c080e7          	jalr	556(ra) # 80001a2a <myproc>
    80002806:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002808:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000280a:	14102773          	csrr	a4,sepc
    8000280e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002810:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002814:	47a1                	li	a5,8
    80002816:	06f71263          	bne	a4,a5,8000287a <usertrap+0x9e>
    if(p->killed)
    8000281a:	591c                	lw	a5,48(a0)
    8000281c:	eba9                	bnez	a5,8000286e <usertrap+0x92>
    p->tf->epc += 4;
    8000281e:	70b8                	ld	a4,96(s1)
    80002820:	6f1c                	ld	a5,24(a4)
    80002822:	0791                	addi	a5,a5,4
    80002824:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002826:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    8000282a:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000282e:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002832:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002836:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000283a:	10079073          	csrw	sstatus,a5
    syscall();
    8000283e:	00000097          	auipc	ra,0x0
    80002842:	338080e7          	jalr	824(ra) # 80002b76 <syscall>
  if(p->killed)
    80002846:	589c                	lw	a5,48(s1)
    80002848:	e7e5                	bnez	a5,80002930 <usertrap+0x154>
  usertrapret();
    8000284a:	00000097          	auipc	ra,0x0
    8000284e:	e1c080e7          	jalr	-484(ra) # 80002666 <usertrapret>
}
    80002852:	60e2                	ld	ra,24(sp)
    80002854:	6442                	ld	s0,16(sp)
    80002856:	64a2                	ld	s1,8(sp)
    80002858:	6902                	ld	s2,0(sp)
    8000285a:	6105                	addi	sp,sp,32
    8000285c:	8082                	ret
    panic("usertrap: not from user mode");
    8000285e:	00006517          	auipc	a0,0x6
    80002862:	b8a50513          	addi	a0,a0,-1142 # 800083e8 <userret+0x358>
    80002866:	ffffe097          	auipc	ra,0xffffe
    8000286a:	ce2080e7          	jalr	-798(ra) # 80000548 <panic>
      exit(-1);
    8000286e:	557d                	li	a0,-1
    80002870:	00000097          	auipc	ra,0x0
    80002874:	84e080e7          	jalr	-1970(ra) # 800020be <exit>
    80002878:	b75d                	j	8000281e <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    8000287a:	00000097          	auipc	ra,0x0
    8000287e:	ed0080e7          	jalr	-304(ra) # 8000274a <devintr>
    80002882:	892a                	mv	s2,a0
    80002884:	e15d                	bnez	a0,8000292a <usertrap+0x14e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002886:	14202773          	csrr	a4,scause
  } else if(r_scause() == 13||r_scause() == 15){
    8000288a:	47b5                	li	a5,13
    8000288c:	00f70763          	beq	a4,a5,8000289a <usertrap+0xbe>
    80002890:	14202773          	csrr	a4,scause
    80002894:	47bd                	li	a5,15
    80002896:	06f71063          	bne	a4,a5,800028f6 <usertrap+0x11a>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000289a:	143027f3          	csrr	a5,stval
    if(va >= p->sz)
    8000289e:	68b8                	ld	a4,80(s1)
    800028a0:	02e7e163          	bltu	a5,a4,800028c2 <usertrap+0xe6>
      p->killed = 1;
    800028a4:	4785                	li	a5,1
    800028a6:	d89c                	sw	a5,48(s1)
    exit(-1);
    800028a8:	557d                	li	a0,-1
    800028aa:	00000097          	auipc	ra,0x0
    800028ae:	814080e7          	jalr	-2028(ra) # 800020be <exit>
  if(which_dev == 2)
    800028b2:	4789                	li	a5,2
    800028b4:	f8f91be3          	bne	s2,a5,8000284a <usertrap+0x6e>
    yield();
    800028b8:	00000097          	auipc	ra,0x0
    800028bc:	914080e7          	jalr	-1772(ra) # 800021cc <yield>
    800028c0:	b769                	j	8000284a <usertrap+0x6e>
    else if (va < p->ustack_top)
    800028c2:	64b8                	ld	a4,72(s1)
    800028c4:	00e7fd63          	bgeu	a5,a4,800028de <usertrap+0x102>
      printf("Guard page!");
    800028c8:	00006517          	auipc	a0,0x6
    800028cc:	b4050513          	addi	a0,a0,-1216 # 80008408 <userret+0x378>
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	cc2080e7          	jalr	-830(ra) # 80000592 <printf>
      p->killed = 1;
    800028d8:	4785                	li	a5,1
    800028da:	d89c                	sw	a5,48(s1)
    800028dc:	b7f1                	j	800028a8 <usertrap+0xcc>
      if(lazyalloc(p->pagetable, va_boundry) < 0){
    800028de:	75fd                	lui	a1,0xfffff
    800028e0:	8dfd                	and	a1,a1,a5
    800028e2:	6ca8                	ld	a0,88(s1)
    800028e4:	fffff097          	auipc	ra,0xfffff
    800028e8:	dbe080e7          	jalr	-578(ra) # 800016a2 <lazyalloc>
    800028ec:	f4055de3          	bgez	a0,80002846 <usertrap+0x6a>
        p->killed = 1;
    800028f0:	4785                	li	a5,1
    800028f2:	d89c                	sw	a5,48(s1)
    800028f4:	bf55                	j	800028a8 <usertrap+0xcc>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028f6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028fa:	5c90                	lw	a2,56(s1)
    800028fc:	00006517          	auipc	a0,0x6
    80002900:	b1c50513          	addi	a0,a0,-1252 # 80008418 <userret+0x388>
    80002904:	ffffe097          	auipc	ra,0xffffe
    80002908:	c8e080e7          	jalr	-882(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000290c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002910:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002914:	00006517          	auipc	a0,0x6
    80002918:	b3450513          	addi	a0,a0,-1228 # 80008448 <userret+0x3b8>
    8000291c:	ffffe097          	auipc	ra,0xffffe
    80002920:	c76080e7          	jalr	-906(ra) # 80000592 <printf>
    p->killed = 1;
    80002924:	4785                	li	a5,1
    80002926:	d89c                	sw	a5,48(s1)
    80002928:	b741                	j	800028a8 <usertrap+0xcc>
  if(p->killed)
    8000292a:	589c                	lw	a5,48(s1)
    8000292c:	d3d9                	beqz	a5,800028b2 <usertrap+0xd6>
    8000292e:	bfad                	j	800028a8 <usertrap+0xcc>
    80002930:	4901                	li	s2,0
    80002932:	bf9d                	j	800028a8 <usertrap+0xcc>

0000000080002934 <kerneltrap>:
{
    80002934:	7179                	addi	sp,sp,-48
    80002936:	f406                	sd	ra,40(sp)
    80002938:	f022                	sd	s0,32(sp)
    8000293a:	ec26                	sd	s1,24(sp)
    8000293c:	e84a                	sd	s2,16(sp)
    8000293e:	e44e                	sd	s3,8(sp)
    80002940:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002942:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002946:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000294a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000294e:	1004f793          	andi	a5,s1,256
    80002952:	cb85                	beqz	a5,80002982 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002954:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002958:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000295a:	ef85                	bnez	a5,80002992 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000295c:	00000097          	auipc	ra,0x0
    80002960:	dee080e7          	jalr	-530(ra) # 8000274a <devintr>
    80002964:	cd1d                	beqz	a0,800029a2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002966:	4789                	li	a5,2
    80002968:	06f50a63          	beq	a0,a5,800029dc <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000296c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002970:	10049073          	csrw	sstatus,s1
}
    80002974:	70a2                	ld	ra,40(sp)
    80002976:	7402                	ld	s0,32(sp)
    80002978:	64e2                	ld	s1,24(sp)
    8000297a:	6942                	ld	s2,16(sp)
    8000297c:	69a2                	ld	s3,8(sp)
    8000297e:	6145                	addi	sp,sp,48
    80002980:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002982:	00006517          	auipc	a0,0x6
    80002986:	ae650513          	addi	a0,a0,-1306 # 80008468 <userret+0x3d8>
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	bbe080e7          	jalr	-1090(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002992:	00006517          	auipc	a0,0x6
    80002996:	afe50513          	addi	a0,a0,-1282 # 80008490 <userret+0x400>
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	bae080e7          	jalr	-1106(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    800029a2:	85ce                	mv	a1,s3
    800029a4:	00006517          	auipc	a0,0x6
    800029a8:	b0c50513          	addi	a0,a0,-1268 # 800084b0 <userret+0x420>
    800029ac:	ffffe097          	auipc	ra,0xffffe
    800029b0:	be6080e7          	jalr	-1050(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029b4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029b8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029bc:	00006517          	auipc	a0,0x6
    800029c0:	b0450513          	addi	a0,a0,-1276 # 800084c0 <userret+0x430>
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	bce080e7          	jalr	-1074(ra) # 80000592 <printf>
    panic("kerneltrap");
    800029cc:	00006517          	auipc	a0,0x6
    800029d0:	b0c50513          	addi	a0,a0,-1268 # 800084d8 <userret+0x448>
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	b74080e7          	jalr	-1164(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029dc:	fffff097          	auipc	ra,0xfffff
    800029e0:	04e080e7          	jalr	78(ra) # 80001a2a <myproc>
    800029e4:	d541                	beqz	a0,8000296c <kerneltrap+0x38>
    800029e6:	fffff097          	auipc	ra,0xfffff
    800029ea:	044080e7          	jalr	68(ra) # 80001a2a <myproc>
    800029ee:	4d18                	lw	a4,24(a0)
    800029f0:	478d                	li	a5,3
    800029f2:	f6f71de3          	bne	a4,a5,8000296c <kerneltrap+0x38>
    yield();
    800029f6:	fffff097          	auipc	ra,0xfffff
    800029fa:	7d6080e7          	jalr	2006(ra) # 800021cc <yield>
    800029fe:	b7bd                	j	8000296c <kerneltrap+0x38>

0000000080002a00 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a00:	1101                	addi	sp,sp,-32
    80002a02:	ec06                	sd	ra,24(sp)
    80002a04:	e822                	sd	s0,16(sp)
    80002a06:	e426                	sd	s1,8(sp)
    80002a08:	1000                	addi	s0,sp,32
    80002a0a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a0c:	fffff097          	auipc	ra,0xfffff
    80002a10:	01e080e7          	jalr	30(ra) # 80001a2a <myproc>
  switch (n) {
    80002a14:	4795                	li	a5,5
    80002a16:	0497e163          	bltu	a5,s1,80002a58 <argraw+0x58>
    80002a1a:	048a                	slli	s1,s1,0x2
    80002a1c:	00006717          	auipc	a4,0x6
    80002a20:	05c70713          	addi	a4,a4,92 # 80008a78 <states.0+0x28>
    80002a24:	94ba                	add	s1,s1,a4
    80002a26:	409c                	lw	a5,0(s1)
    80002a28:	97ba                	add	a5,a5,a4
    80002a2a:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002a2c:	713c                	ld	a5,96(a0)
    80002a2e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002a30:	60e2                	ld	ra,24(sp)
    80002a32:	6442                	ld	s0,16(sp)
    80002a34:	64a2                	ld	s1,8(sp)
    80002a36:	6105                	addi	sp,sp,32
    80002a38:	8082                	ret
    return p->tf->a1;
    80002a3a:	713c                	ld	a5,96(a0)
    80002a3c:	7fa8                	ld	a0,120(a5)
    80002a3e:	bfcd                	j	80002a30 <argraw+0x30>
    return p->tf->a2;
    80002a40:	713c                	ld	a5,96(a0)
    80002a42:	63c8                	ld	a0,128(a5)
    80002a44:	b7f5                	j	80002a30 <argraw+0x30>
    return p->tf->a3;
    80002a46:	713c                	ld	a5,96(a0)
    80002a48:	67c8                	ld	a0,136(a5)
    80002a4a:	b7dd                	j	80002a30 <argraw+0x30>
    return p->tf->a4;
    80002a4c:	713c                	ld	a5,96(a0)
    80002a4e:	6bc8                	ld	a0,144(a5)
    80002a50:	b7c5                	j	80002a30 <argraw+0x30>
    return p->tf->a5;
    80002a52:	713c                	ld	a5,96(a0)
    80002a54:	6fc8                	ld	a0,152(a5)
    80002a56:	bfe9                	j	80002a30 <argraw+0x30>
  panic("argraw");
    80002a58:	00006517          	auipc	a0,0x6
    80002a5c:	a9050513          	addi	a0,a0,-1392 # 800084e8 <userret+0x458>
    80002a60:	ffffe097          	auipc	ra,0xffffe
    80002a64:	ae8080e7          	jalr	-1304(ra) # 80000548 <panic>

0000000080002a68 <fetchaddr>:
{
    80002a68:	1101                	addi	sp,sp,-32
    80002a6a:	ec06                	sd	ra,24(sp)
    80002a6c:	e822                	sd	s0,16(sp)
    80002a6e:	e426                	sd	s1,8(sp)
    80002a70:	e04a                	sd	s2,0(sp)
    80002a72:	1000                	addi	s0,sp,32
    80002a74:	84aa                	mv	s1,a0
    80002a76:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a78:	fffff097          	auipc	ra,0xfffff
    80002a7c:	fb2080e7          	jalr	-78(ra) # 80001a2a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a80:	693c                	ld	a5,80(a0)
    80002a82:	02f4f863          	bgeu	s1,a5,80002ab2 <fetchaddr+0x4a>
    80002a86:	00848713          	addi	a4,s1,8
    80002a8a:	02e7e663          	bltu	a5,a4,80002ab6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a8e:	46a1                	li	a3,8
    80002a90:	8626                	mv	a2,s1
    80002a92:	85ca                	mv	a1,s2
    80002a94:	6d28                	ld	a0,88(a0)
    80002a96:	fffff097          	auipc	ra,0xfffff
    80002a9a:	da8080e7          	jalr	-600(ra) # 8000183e <copyin>
    80002a9e:	00a03533          	snez	a0,a0
    80002aa2:	40a00533          	neg	a0,a0
}
    80002aa6:	60e2                	ld	ra,24(sp)
    80002aa8:	6442                	ld	s0,16(sp)
    80002aaa:	64a2                	ld	s1,8(sp)
    80002aac:	6902                	ld	s2,0(sp)
    80002aae:	6105                	addi	sp,sp,32
    80002ab0:	8082                	ret
    return -1;
    80002ab2:	557d                	li	a0,-1
    80002ab4:	bfcd                	j	80002aa6 <fetchaddr+0x3e>
    80002ab6:	557d                	li	a0,-1
    80002ab8:	b7fd                	j	80002aa6 <fetchaddr+0x3e>

0000000080002aba <fetchstr>:
{
    80002aba:	7179                	addi	sp,sp,-48
    80002abc:	f406                	sd	ra,40(sp)
    80002abe:	f022                	sd	s0,32(sp)
    80002ac0:	ec26                	sd	s1,24(sp)
    80002ac2:	e84a                	sd	s2,16(sp)
    80002ac4:	e44e                	sd	s3,8(sp)
    80002ac6:	1800                	addi	s0,sp,48
    80002ac8:	892a                	mv	s2,a0
    80002aca:	84ae                	mv	s1,a1
    80002acc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ace:	fffff097          	auipc	ra,0xfffff
    80002ad2:	f5c080e7          	jalr	-164(ra) # 80001a2a <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ad6:	86ce                	mv	a3,s3
    80002ad8:	864a                	mv	a2,s2
    80002ada:	85a6                	mv	a1,s1
    80002adc:	6d28                	ld	a0,88(a0)
    80002ade:	fffff097          	auipc	ra,0xfffff
    80002ae2:	a32080e7          	jalr	-1486(ra) # 80001510 <copyinstr>
  if(err < 0)
    80002ae6:	00054763          	bltz	a0,80002af4 <fetchstr+0x3a>
  return strlen(buf);
    80002aea:	8526                	mv	a0,s1
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	21a080e7          	jalr	538(ra) # 80000d06 <strlen>
}
    80002af4:	70a2                	ld	ra,40(sp)
    80002af6:	7402                	ld	s0,32(sp)
    80002af8:	64e2                	ld	s1,24(sp)
    80002afa:	6942                	ld	s2,16(sp)
    80002afc:	69a2                	ld	s3,8(sp)
    80002afe:	6145                	addi	sp,sp,48
    80002b00:	8082                	ret

0000000080002b02 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b02:	1101                	addi	sp,sp,-32
    80002b04:	ec06                	sd	ra,24(sp)
    80002b06:	e822                	sd	s0,16(sp)
    80002b08:	e426                	sd	s1,8(sp)
    80002b0a:	1000                	addi	s0,sp,32
    80002b0c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b0e:	00000097          	auipc	ra,0x0
    80002b12:	ef2080e7          	jalr	-270(ra) # 80002a00 <argraw>
    80002b16:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b18:	4501                	li	a0,0
    80002b1a:	60e2                	ld	ra,24(sp)
    80002b1c:	6442                	ld	s0,16(sp)
    80002b1e:	64a2                	ld	s1,8(sp)
    80002b20:	6105                	addi	sp,sp,32
    80002b22:	8082                	ret

0000000080002b24 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b24:	1101                	addi	sp,sp,-32
    80002b26:	ec06                	sd	ra,24(sp)
    80002b28:	e822                	sd	s0,16(sp)
    80002b2a:	e426                	sd	s1,8(sp)
    80002b2c:	1000                	addi	s0,sp,32
    80002b2e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b30:	00000097          	auipc	ra,0x0
    80002b34:	ed0080e7          	jalr	-304(ra) # 80002a00 <argraw>
    80002b38:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b3a:	4501                	li	a0,0
    80002b3c:	60e2                	ld	ra,24(sp)
    80002b3e:	6442                	ld	s0,16(sp)
    80002b40:	64a2                	ld	s1,8(sp)
    80002b42:	6105                	addi	sp,sp,32
    80002b44:	8082                	ret

0000000080002b46 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b46:	1101                	addi	sp,sp,-32
    80002b48:	ec06                	sd	ra,24(sp)
    80002b4a:	e822                	sd	s0,16(sp)
    80002b4c:	e426                	sd	s1,8(sp)
    80002b4e:	e04a                	sd	s2,0(sp)
    80002b50:	1000                	addi	s0,sp,32
    80002b52:	84ae                	mv	s1,a1
    80002b54:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b56:	00000097          	auipc	ra,0x0
    80002b5a:	eaa080e7          	jalr	-342(ra) # 80002a00 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b5e:	864a                	mv	a2,s2
    80002b60:	85a6                	mv	a1,s1
    80002b62:	00000097          	auipc	ra,0x0
    80002b66:	f58080e7          	jalr	-168(ra) # 80002aba <fetchstr>
}
    80002b6a:	60e2                	ld	ra,24(sp)
    80002b6c:	6442                	ld	s0,16(sp)
    80002b6e:	64a2                	ld	s1,8(sp)
    80002b70:	6902                	ld	s2,0(sp)
    80002b72:	6105                	addi	sp,sp,32
    80002b74:	8082                	ret

0000000080002b76 <syscall>:
[SYS_crash]   sys_crash,
};

void
syscall(void)
{
    80002b76:	1101                	addi	sp,sp,-32
    80002b78:	ec06                	sd	ra,24(sp)
    80002b7a:	e822                	sd	s0,16(sp)
    80002b7c:	e426                	sd	s1,8(sp)
    80002b7e:	e04a                	sd	s2,0(sp)
    80002b80:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b82:	fffff097          	auipc	ra,0xfffff
    80002b86:	ea8080e7          	jalr	-344(ra) # 80001a2a <myproc>
    80002b8a:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002b8c:	06053903          	ld	s2,96(a0)
    80002b90:	0a893783          	ld	a5,168(s2)
    80002b94:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b98:	37fd                	addiw	a5,a5,-1
    80002b9a:	4759                	li	a4,22
    80002b9c:	00f76f63          	bltu	a4,a5,80002bba <syscall+0x44>
    80002ba0:	00369713          	slli	a4,a3,0x3
    80002ba4:	00006797          	auipc	a5,0x6
    80002ba8:	eec78793          	addi	a5,a5,-276 # 80008a90 <syscalls>
    80002bac:	97ba                	add	a5,a5,a4
    80002bae:	639c                	ld	a5,0(a5)
    80002bb0:	c789                	beqz	a5,80002bba <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002bb2:	9782                	jalr	a5
    80002bb4:	06a93823          	sd	a0,112(s2)
    80002bb8:	a839                	j	80002bd6 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bba:	16048613          	addi	a2,s1,352
    80002bbe:	5c8c                	lw	a1,56(s1)
    80002bc0:	00006517          	auipc	a0,0x6
    80002bc4:	93050513          	addi	a0,a0,-1744 # 800084f0 <userret+0x460>
    80002bc8:	ffffe097          	auipc	ra,0xffffe
    80002bcc:	9ca080e7          	jalr	-1590(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002bd0:	70bc                	ld	a5,96(s1)
    80002bd2:	577d                	li	a4,-1
    80002bd4:	fbb8                	sd	a4,112(a5)
  }
}
    80002bd6:	60e2                	ld	ra,24(sp)
    80002bd8:	6442                	ld	s0,16(sp)
    80002bda:	64a2                	ld	s1,8(sp)
    80002bdc:	6902                	ld	s2,0(sp)
    80002bde:	6105                	addi	sp,sp,32
    80002be0:	8082                	ret

0000000080002be2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002be2:	1101                	addi	sp,sp,-32
    80002be4:	ec06                	sd	ra,24(sp)
    80002be6:	e822                	sd	s0,16(sp)
    80002be8:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002bea:	fec40593          	addi	a1,s0,-20
    80002bee:	4501                	li	a0,0
    80002bf0:	00000097          	auipc	ra,0x0
    80002bf4:	f12080e7          	jalr	-238(ra) # 80002b02 <argint>
    return -1;
    80002bf8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002bfa:	00054963          	bltz	a0,80002c0c <sys_exit+0x2a>
  exit(n);
    80002bfe:	fec42503          	lw	a0,-20(s0)
    80002c02:	fffff097          	auipc	ra,0xfffff
    80002c06:	4bc080e7          	jalr	1212(ra) # 800020be <exit>
  return 0;  // not reached
    80002c0a:	4781                	li	a5,0
}
    80002c0c:	853e                	mv	a0,a5
    80002c0e:	60e2                	ld	ra,24(sp)
    80002c10:	6442                	ld	s0,16(sp)
    80002c12:	6105                	addi	sp,sp,32
    80002c14:	8082                	ret

0000000080002c16 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c16:	1141                	addi	sp,sp,-16
    80002c18:	e406                	sd	ra,8(sp)
    80002c1a:	e022                	sd	s0,0(sp)
    80002c1c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c1e:	fffff097          	auipc	ra,0xfffff
    80002c22:	e0c080e7          	jalr	-500(ra) # 80001a2a <myproc>
}
    80002c26:	5d08                	lw	a0,56(a0)
    80002c28:	60a2                	ld	ra,8(sp)
    80002c2a:	6402                	ld	s0,0(sp)
    80002c2c:	0141                	addi	sp,sp,16
    80002c2e:	8082                	ret

0000000080002c30 <sys_fork>:

uint64
sys_fork(void)
{
    80002c30:	1141                	addi	sp,sp,-16
    80002c32:	e406                	sd	ra,8(sp)
    80002c34:	e022                	sd	s0,0(sp)
    80002c36:	0800                	addi	s0,sp,16
  return fork();
    80002c38:	fffff097          	auipc	ra,0xfffff
    80002c3c:	15c080e7          	jalr	348(ra) # 80001d94 <fork>
}
    80002c40:	60a2                	ld	ra,8(sp)
    80002c42:	6402                	ld	s0,0(sp)
    80002c44:	0141                	addi	sp,sp,16
    80002c46:	8082                	ret

0000000080002c48 <sys_wait>:

uint64
sys_wait(void)
{
    80002c48:	1101                	addi	sp,sp,-32
    80002c4a:	ec06                	sd	ra,24(sp)
    80002c4c:	e822                	sd	s0,16(sp)
    80002c4e:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c50:	fe840593          	addi	a1,s0,-24
    80002c54:	4501                	li	a0,0
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	ece080e7          	jalr	-306(ra) # 80002b24 <argaddr>
    80002c5e:	87aa                	mv	a5,a0
    return -1;
    80002c60:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002c62:	0007c863          	bltz	a5,80002c72 <sys_wait+0x2a>
  return wait(p);
    80002c66:	fe843503          	ld	a0,-24(s0)
    80002c6a:	fffff097          	auipc	ra,0xfffff
    80002c6e:	61c080e7          	jalr	1564(ra) # 80002286 <wait>
}
    80002c72:	60e2                	ld	ra,24(sp)
    80002c74:	6442                	ld	s0,16(sp)
    80002c76:	6105                	addi	sp,sp,32
    80002c78:	8082                	ret

0000000080002c7a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c7a:	7179                	addi	sp,sp,-48
    80002c7c:	f406                	sd	ra,40(sp)
    80002c7e:	f022                	sd	s0,32(sp)
    80002c80:	ec26                	sd	s1,24(sp)
    80002c82:	1800                	addi	s0,sp,48
  int addr;
  int n;
  
  if(argint(0, &n) < 0)
    80002c84:	fdc40593          	addi	a1,s0,-36
    80002c88:	4501                	li	a0,0
    80002c8a:	00000097          	auipc	ra,0x0
    80002c8e:	e78080e7          	jalr	-392(ra) # 80002b02 <argint>
    80002c92:	87aa                	mv	a5,a0
    return -1;
    80002c94:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002c96:	0207c363          	bltz	a5,80002cbc <sys_sbrk+0x42>
  addr = myproc()->sz;
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	d90080e7          	jalr	-624(ra) # 80001a2a <myproc>
    80002ca2:	4924                	lw	s1,80(a0)
  myproc()->sz += n;
    80002ca4:	fffff097          	auipc	ra,0xfffff
    80002ca8:	d86080e7          	jalr	-634(ra) # 80001a2a <myproc>
    80002cac:	fdc42703          	lw	a4,-36(s0)
    80002cb0:	693c                	ld	a5,80(a0)
    80002cb2:	97ba                	add	a5,a5,a4
    80002cb4:	e93c                	sd	a5,80(a0)
  /**
   * 
   * Handle negtive sbrk
   */
  if(n < 0){
    80002cb6:	00074863          	bltz	a4,80002cc6 <sys_sbrk+0x4c>
    //printf("n:%d\n",n);
    //printf("oldsz:%d, newsz:%d\n ", addr, addr + n);
    uvmdealloc(myproc()->pagetable, addr, addr + n);
  }
  return addr;
    80002cba:	8526                	mv	a0,s1
}
    80002cbc:	70a2                	ld	ra,40(sp)
    80002cbe:	7402                	ld	s0,32(sp)
    80002cc0:	64e2                	ld	s1,24(sp)
    80002cc2:	6145                	addi	sp,sp,48
    80002cc4:	8082                	ret
    uvmdealloc(myproc()->pagetable, addr, addr + n);
    80002cc6:	fffff097          	auipc	ra,0xfffff
    80002cca:	d64080e7          	jalr	-668(ra) # 80001a2a <myproc>
    80002cce:	fdc42603          	lw	a2,-36(s0)
    80002cd2:	9e25                	addw	a2,a2,s1
    80002cd4:	85a6                	mv	a1,s1
    80002cd6:	6d28                	ld	a0,88(a0)
    80002cd8:	ffffe097          	auipc	ra,0xffffe
    80002cdc:	636080e7          	jalr	1590(ra) # 8000130e <uvmdealloc>
    80002ce0:	bfe9                	j	80002cba <sys_sbrk+0x40>

0000000080002ce2 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ce2:	7139                	addi	sp,sp,-64
    80002ce4:	fc06                	sd	ra,56(sp)
    80002ce6:	f822                	sd	s0,48(sp)
    80002ce8:	f426                	sd	s1,40(sp)
    80002cea:	f04a                	sd	s2,32(sp)
    80002cec:	ec4e                	sd	s3,24(sp)
    80002cee:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002cf0:	fcc40593          	addi	a1,s0,-52
    80002cf4:	4501                	li	a0,0
    80002cf6:	00000097          	auipc	ra,0x0
    80002cfa:	e0c080e7          	jalr	-500(ra) # 80002b02 <argint>
    return -1;
    80002cfe:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d00:	06054563          	bltz	a0,80002d6a <sys_sleep+0x88>
  acquire(&tickslock);
    80002d04:	00016517          	auipc	a0,0x16
    80002d08:	bfc50513          	addi	a0,a0,-1028 # 80018900 <tickslock>
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	db2080e7          	jalr	-590(ra) # 80000abe <acquire>
  ticks0 = ticks;
    80002d14:	00027917          	auipc	s2,0x27
    80002d18:	32c92903          	lw	s2,812(s2) # 8002a040 <ticks>
  while(ticks - ticks0 < n){
    80002d1c:	fcc42783          	lw	a5,-52(s0)
    80002d20:	cf85                	beqz	a5,80002d58 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d22:	00016997          	auipc	s3,0x16
    80002d26:	bde98993          	addi	s3,s3,-1058 # 80018900 <tickslock>
    80002d2a:	00027497          	auipc	s1,0x27
    80002d2e:	31648493          	addi	s1,s1,790 # 8002a040 <ticks>
    if(myproc()->killed){
    80002d32:	fffff097          	auipc	ra,0xfffff
    80002d36:	cf8080e7          	jalr	-776(ra) # 80001a2a <myproc>
    80002d3a:	591c                	lw	a5,48(a0)
    80002d3c:	ef9d                	bnez	a5,80002d7a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d3e:	85ce                	mv	a1,s3
    80002d40:	8526                	mv	a0,s1
    80002d42:	fffff097          	auipc	ra,0xfffff
    80002d46:	4c6080e7          	jalr	1222(ra) # 80002208 <sleep>
  while(ticks - ticks0 < n){
    80002d4a:	409c                	lw	a5,0(s1)
    80002d4c:	412787bb          	subw	a5,a5,s2
    80002d50:	fcc42703          	lw	a4,-52(s0)
    80002d54:	fce7efe3          	bltu	a5,a4,80002d32 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d58:	00016517          	auipc	a0,0x16
    80002d5c:	ba850513          	addi	a0,a0,-1112 # 80018900 <tickslock>
    80002d60:	ffffe097          	auipc	ra,0xffffe
    80002d64:	dc6080e7          	jalr	-570(ra) # 80000b26 <release>
  return 0;
    80002d68:	4781                	li	a5,0
}
    80002d6a:	853e                	mv	a0,a5
    80002d6c:	70e2                	ld	ra,56(sp)
    80002d6e:	7442                	ld	s0,48(sp)
    80002d70:	74a2                	ld	s1,40(sp)
    80002d72:	7902                	ld	s2,32(sp)
    80002d74:	69e2                	ld	s3,24(sp)
    80002d76:	6121                	addi	sp,sp,64
    80002d78:	8082                	ret
      release(&tickslock);
    80002d7a:	00016517          	auipc	a0,0x16
    80002d7e:	b8650513          	addi	a0,a0,-1146 # 80018900 <tickslock>
    80002d82:	ffffe097          	auipc	ra,0xffffe
    80002d86:	da4080e7          	jalr	-604(ra) # 80000b26 <release>
      return -1;
    80002d8a:	57fd                	li	a5,-1
    80002d8c:	bff9                	j	80002d6a <sys_sleep+0x88>

0000000080002d8e <sys_kill>:

uint64
sys_kill(void)
{
    80002d8e:	1101                	addi	sp,sp,-32
    80002d90:	ec06                	sd	ra,24(sp)
    80002d92:	e822                	sd	s0,16(sp)
    80002d94:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d96:	fec40593          	addi	a1,s0,-20
    80002d9a:	4501                	li	a0,0
    80002d9c:	00000097          	auipc	ra,0x0
    80002da0:	d66080e7          	jalr	-666(ra) # 80002b02 <argint>
    80002da4:	87aa                	mv	a5,a0
    return -1;
    80002da6:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002da8:	0007c863          	bltz	a5,80002db8 <sys_kill+0x2a>
  return kill(pid);
    80002dac:	fec42503          	lw	a0,-20(s0)
    80002db0:	fffff097          	auipc	ra,0xfffff
    80002db4:	642080e7          	jalr	1602(ra) # 800023f2 <kill>
}
    80002db8:	60e2                	ld	ra,24(sp)
    80002dba:	6442                	ld	s0,16(sp)
    80002dbc:	6105                	addi	sp,sp,32
    80002dbe:	8082                	ret

0000000080002dc0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dc0:	1101                	addi	sp,sp,-32
    80002dc2:	ec06                	sd	ra,24(sp)
    80002dc4:	e822                	sd	s0,16(sp)
    80002dc6:	e426                	sd	s1,8(sp)
    80002dc8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dca:	00016517          	auipc	a0,0x16
    80002dce:	b3650513          	addi	a0,a0,-1226 # 80018900 <tickslock>
    80002dd2:	ffffe097          	auipc	ra,0xffffe
    80002dd6:	cec080e7          	jalr	-788(ra) # 80000abe <acquire>
  xticks = ticks;
    80002dda:	00027497          	auipc	s1,0x27
    80002dde:	2664a483          	lw	s1,614(s1) # 8002a040 <ticks>
  release(&tickslock);
    80002de2:	00016517          	auipc	a0,0x16
    80002de6:	b1e50513          	addi	a0,a0,-1250 # 80018900 <tickslock>
    80002dea:	ffffe097          	auipc	ra,0xffffe
    80002dee:	d3c080e7          	jalr	-708(ra) # 80000b26 <release>
  return xticks;
}
    80002df2:	02049513          	slli	a0,s1,0x20
    80002df6:	9101                	srli	a0,a0,0x20
    80002df8:	60e2                	ld	ra,24(sp)
    80002dfa:	6442                	ld	s0,16(sp)
    80002dfc:	64a2                	ld	s1,8(sp)
    80002dfe:	6105                	addi	sp,sp,32
    80002e00:	8082                	ret

0000000080002e02 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e02:	7179                	addi	sp,sp,-48
    80002e04:	f406                	sd	ra,40(sp)
    80002e06:	f022                	sd	s0,32(sp)
    80002e08:	ec26                	sd	s1,24(sp)
    80002e0a:	e84a                	sd	s2,16(sp)
    80002e0c:	e44e                	sd	s3,8(sp)
    80002e0e:	e052                	sd	s4,0(sp)
    80002e10:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e12:	00005597          	auipc	a1,0x5
    80002e16:	6fe58593          	addi	a1,a1,1790 # 80008510 <userret+0x480>
    80002e1a:	00016517          	auipc	a0,0x16
    80002e1e:	afe50513          	addi	a0,a0,-1282 # 80018918 <bcache>
    80002e22:	ffffe097          	auipc	ra,0xffffe
    80002e26:	b8e080e7          	jalr	-1138(ra) # 800009b0 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e2a:	0001e797          	auipc	a5,0x1e
    80002e2e:	aee78793          	addi	a5,a5,-1298 # 80020918 <bcache+0x8000>
    80002e32:	0001e717          	auipc	a4,0x1e
    80002e36:	e3e70713          	addi	a4,a4,-450 # 80020c70 <bcache+0x8358>
    80002e3a:	3ae7b023          	sd	a4,928(a5)
  bcache.head.next = &bcache.head;
    80002e3e:	3ae7b423          	sd	a4,936(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e42:	00016497          	auipc	s1,0x16
    80002e46:	aee48493          	addi	s1,s1,-1298 # 80018930 <bcache+0x18>
    b->next = bcache.head.next;
    80002e4a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e4c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e4e:	00005a17          	auipc	s4,0x5
    80002e52:	6caa0a13          	addi	s4,s4,1738 # 80008518 <userret+0x488>
    b->next = bcache.head.next;
    80002e56:	3a893783          	ld	a5,936(s2)
    80002e5a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e5c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e60:	85d2                	mv	a1,s4
    80002e62:	01048513          	addi	a0,s1,16
    80002e66:	00001097          	auipc	ra,0x1
    80002e6a:	6f0080e7          	jalr	1776(ra) # 80004556 <initsleeplock>
    bcache.head.next->prev = b;
    80002e6e:	3a893783          	ld	a5,936(s2)
    80002e72:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e74:	3a993423          	sd	s1,936(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e78:	46048493          	addi	s1,s1,1120
    80002e7c:	fd349de3          	bne	s1,s3,80002e56 <binit+0x54>
  }
}
    80002e80:	70a2                	ld	ra,40(sp)
    80002e82:	7402                	ld	s0,32(sp)
    80002e84:	64e2                	ld	s1,24(sp)
    80002e86:	6942                	ld	s2,16(sp)
    80002e88:	69a2                	ld	s3,8(sp)
    80002e8a:	6a02                	ld	s4,0(sp)
    80002e8c:	6145                	addi	sp,sp,48
    80002e8e:	8082                	ret

0000000080002e90 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e90:	7179                	addi	sp,sp,-48
    80002e92:	f406                	sd	ra,40(sp)
    80002e94:	f022                	sd	s0,32(sp)
    80002e96:	ec26                	sd	s1,24(sp)
    80002e98:	e84a                	sd	s2,16(sp)
    80002e9a:	e44e                	sd	s3,8(sp)
    80002e9c:	1800                	addi	s0,sp,48
    80002e9e:	892a                	mv	s2,a0
    80002ea0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ea2:	00016517          	auipc	a0,0x16
    80002ea6:	a7650513          	addi	a0,a0,-1418 # 80018918 <bcache>
    80002eaa:	ffffe097          	auipc	ra,0xffffe
    80002eae:	c14080e7          	jalr	-1004(ra) # 80000abe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002eb2:	0001e497          	auipc	s1,0x1e
    80002eb6:	e0e4b483          	ld	s1,-498(s1) # 80020cc0 <bcache+0x83a8>
    80002eba:	0001e797          	auipc	a5,0x1e
    80002ebe:	db678793          	addi	a5,a5,-586 # 80020c70 <bcache+0x8358>
    80002ec2:	02f48f63          	beq	s1,a5,80002f00 <bread+0x70>
    80002ec6:	873e                	mv	a4,a5
    80002ec8:	a021                	j	80002ed0 <bread+0x40>
    80002eca:	68a4                	ld	s1,80(s1)
    80002ecc:	02e48a63          	beq	s1,a4,80002f00 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002ed0:	449c                	lw	a5,8(s1)
    80002ed2:	ff279ce3          	bne	a5,s2,80002eca <bread+0x3a>
    80002ed6:	44dc                	lw	a5,12(s1)
    80002ed8:	ff3799e3          	bne	a5,s3,80002eca <bread+0x3a>
      b->refcnt++;
    80002edc:	40bc                	lw	a5,64(s1)
    80002ede:	2785                	addiw	a5,a5,1
    80002ee0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ee2:	00016517          	auipc	a0,0x16
    80002ee6:	a3650513          	addi	a0,a0,-1482 # 80018918 <bcache>
    80002eea:	ffffe097          	auipc	ra,0xffffe
    80002eee:	c3c080e7          	jalr	-964(ra) # 80000b26 <release>
      acquiresleep(&b->lock);
    80002ef2:	01048513          	addi	a0,s1,16
    80002ef6:	00001097          	auipc	ra,0x1
    80002efa:	69a080e7          	jalr	1690(ra) # 80004590 <acquiresleep>
      return b;
    80002efe:	a8b9                	j	80002f5c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f00:	0001e497          	auipc	s1,0x1e
    80002f04:	db84b483          	ld	s1,-584(s1) # 80020cb8 <bcache+0x83a0>
    80002f08:	0001e797          	auipc	a5,0x1e
    80002f0c:	d6878793          	addi	a5,a5,-664 # 80020c70 <bcache+0x8358>
    80002f10:	00f48863          	beq	s1,a5,80002f20 <bread+0x90>
    80002f14:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f16:	40bc                	lw	a5,64(s1)
    80002f18:	cf81                	beqz	a5,80002f30 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f1a:	64a4                	ld	s1,72(s1)
    80002f1c:	fee49de3          	bne	s1,a4,80002f16 <bread+0x86>
  panic("bget: no buffers");
    80002f20:	00005517          	auipc	a0,0x5
    80002f24:	60050513          	addi	a0,a0,1536 # 80008520 <userret+0x490>
    80002f28:	ffffd097          	auipc	ra,0xffffd
    80002f2c:	620080e7          	jalr	1568(ra) # 80000548 <panic>
      b->dev = dev;
    80002f30:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f34:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f38:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f3c:	4785                	li	a5,1
    80002f3e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f40:	00016517          	auipc	a0,0x16
    80002f44:	9d850513          	addi	a0,a0,-1576 # 80018918 <bcache>
    80002f48:	ffffe097          	auipc	ra,0xffffe
    80002f4c:	bde080e7          	jalr	-1058(ra) # 80000b26 <release>
      acquiresleep(&b->lock);
    80002f50:	01048513          	addi	a0,s1,16
    80002f54:	00001097          	auipc	ra,0x1
    80002f58:	63c080e7          	jalr	1596(ra) # 80004590 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f5c:	409c                	lw	a5,0(s1)
    80002f5e:	cb89                	beqz	a5,80002f70 <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f60:	8526                	mv	a0,s1
    80002f62:	70a2                	ld	ra,40(sp)
    80002f64:	7402                	ld	s0,32(sp)
    80002f66:	64e2                	ld	s1,24(sp)
    80002f68:	6942                	ld	s2,16(sp)
    80002f6a:	69a2                	ld	s3,8(sp)
    80002f6c:	6145                	addi	sp,sp,48
    80002f6e:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    80002f70:	4601                	li	a2,0
    80002f72:	85a6                	mv	a1,s1
    80002f74:	4488                	lw	a0,8(s1)
    80002f76:	00003097          	auipc	ra,0x3
    80002f7a:	306080e7          	jalr	774(ra) # 8000627c <virtio_disk_rw>
    b->valid = 1;
    80002f7e:	4785                	li	a5,1
    80002f80:	c09c                	sw	a5,0(s1)
  return b;
    80002f82:	bff9                	j	80002f60 <bread+0xd0>

0000000080002f84 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f84:	1101                	addi	sp,sp,-32
    80002f86:	ec06                	sd	ra,24(sp)
    80002f88:	e822                	sd	s0,16(sp)
    80002f8a:	e426                	sd	s1,8(sp)
    80002f8c:	1000                	addi	s0,sp,32
    80002f8e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f90:	0541                	addi	a0,a0,16
    80002f92:	00001097          	auipc	ra,0x1
    80002f96:	698080e7          	jalr	1688(ra) # 8000462a <holdingsleep>
    80002f9a:	cd09                	beqz	a0,80002fb4 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80002f9c:	4605                	li	a2,1
    80002f9e:	85a6                	mv	a1,s1
    80002fa0:	4488                	lw	a0,8(s1)
    80002fa2:	00003097          	auipc	ra,0x3
    80002fa6:	2da080e7          	jalr	730(ra) # 8000627c <virtio_disk_rw>
}
    80002faa:	60e2                	ld	ra,24(sp)
    80002fac:	6442                	ld	s0,16(sp)
    80002fae:	64a2                	ld	s1,8(sp)
    80002fb0:	6105                	addi	sp,sp,32
    80002fb2:	8082                	ret
    panic("bwrite");
    80002fb4:	00005517          	auipc	a0,0x5
    80002fb8:	58450513          	addi	a0,a0,1412 # 80008538 <userret+0x4a8>
    80002fbc:	ffffd097          	auipc	ra,0xffffd
    80002fc0:	58c080e7          	jalr	1420(ra) # 80000548 <panic>

0000000080002fc4 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80002fc4:	1101                	addi	sp,sp,-32
    80002fc6:	ec06                	sd	ra,24(sp)
    80002fc8:	e822                	sd	s0,16(sp)
    80002fca:	e426                	sd	s1,8(sp)
    80002fcc:	e04a                	sd	s2,0(sp)
    80002fce:	1000                	addi	s0,sp,32
    80002fd0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fd2:	01050913          	addi	s2,a0,16
    80002fd6:	854a                	mv	a0,s2
    80002fd8:	00001097          	auipc	ra,0x1
    80002fdc:	652080e7          	jalr	1618(ra) # 8000462a <holdingsleep>
    80002fe0:	c92d                	beqz	a0,80003052 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002fe2:	854a                	mv	a0,s2
    80002fe4:	00001097          	auipc	ra,0x1
    80002fe8:	602080e7          	jalr	1538(ra) # 800045e6 <releasesleep>

  acquire(&bcache.lock);
    80002fec:	00016517          	auipc	a0,0x16
    80002ff0:	92c50513          	addi	a0,a0,-1748 # 80018918 <bcache>
    80002ff4:	ffffe097          	auipc	ra,0xffffe
    80002ff8:	aca080e7          	jalr	-1334(ra) # 80000abe <acquire>
  b->refcnt--;
    80002ffc:	40bc                	lw	a5,64(s1)
    80002ffe:	37fd                	addiw	a5,a5,-1
    80003000:	0007871b          	sext.w	a4,a5
    80003004:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003006:	eb05                	bnez	a4,80003036 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003008:	68bc                	ld	a5,80(s1)
    8000300a:	64b8                	ld	a4,72(s1)
    8000300c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000300e:	64bc                	ld	a5,72(s1)
    80003010:	68b8                	ld	a4,80(s1)
    80003012:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003014:	0001e797          	auipc	a5,0x1e
    80003018:	90478793          	addi	a5,a5,-1788 # 80020918 <bcache+0x8000>
    8000301c:	3a87b703          	ld	a4,936(a5)
    80003020:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003022:	0001e717          	auipc	a4,0x1e
    80003026:	c4e70713          	addi	a4,a4,-946 # 80020c70 <bcache+0x8358>
    8000302a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000302c:	3a87b703          	ld	a4,936(a5)
    80003030:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003032:	3a97b423          	sd	s1,936(a5)
  }
  
  release(&bcache.lock);
    80003036:	00016517          	auipc	a0,0x16
    8000303a:	8e250513          	addi	a0,a0,-1822 # 80018918 <bcache>
    8000303e:	ffffe097          	auipc	ra,0xffffe
    80003042:	ae8080e7          	jalr	-1304(ra) # 80000b26 <release>
}
    80003046:	60e2                	ld	ra,24(sp)
    80003048:	6442                	ld	s0,16(sp)
    8000304a:	64a2                	ld	s1,8(sp)
    8000304c:	6902                	ld	s2,0(sp)
    8000304e:	6105                	addi	sp,sp,32
    80003050:	8082                	ret
    panic("brelse");
    80003052:	00005517          	auipc	a0,0x5
    80003056:	4ee50513          	addi	a0,a0,1262 # 80008540 <userret+0x4b0>
    8000305a:	ffffd097          	auipc	ra,0xffffd
    8000305e:	4ee080e7          	jalr	1262(ra) # 80000548 <panic>

0000000080003062 <bpin>:

void
bpin(struct buf *b) {
    80003062:	1101                	addi	sp,sp,-32
    80003064:	ec06                	sd	ra,24(sp)
    80003066:	e822                	sd	s0,16(sp)
    80003068:	e426                	sd	s1,8(sp)
    8000306a:	1000                	addi	s0,sp,32
    8000306c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000306e:	00016517          	auipc	a0,0x16
    80003072:	8aa50513          	addi	a0,a0,-1878 # 80018918 <bcache>
    80003076:	ffffe097          	auipc	ra,0xffffe
    8000307a:	a48080e7          	jalr	-1464(ra) # 80000abe <acquire>
  b->refcnt++;
    8000307e:	40bc                	lw	a5,64(s1)
    80003080:	2785                	addiw	a5,a5,1
    80003082:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003084:	00016517          	auipc	a0,0x16
    80003088:	89450513          	addi	a0,a0,-1900 # 80018918 <bcache>
    8000308c:	ffffe097          	auipc	ra,0xffffe
    80003090:	a9a080e7          	jalr	-1382(ra) # 80000b26 <release>
}
    80003094:	60e2                	ld	ra,24(sp)
    80003096:	6442                	ld	s0,16(sp)
    80003098:	64a2                	ld	s1,8(sp)
    8000309a:	6105                	addi	sp,sp,32
    8000309c:	8082                	ret

000000008000309e <bunpin>:

void
bunpin(struct buf *b) {
    8000309e:	1101                	addi	sp,sp,-32
    800030a0:	ec06                	sd	ra,24(sp)
    800030a2:	e822                	sd	s0,16(sp)
    800030a4:	e426                	sd	s1,8(sp)
    800030a6:	1000                	addi	s0,sp,32
    800030a8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030aa:	00016517          	auipc	a0,0x16
    800030ae:	86e50513          	addi	a0,a0,-1938 # 80018918 <bcache>
    800030b2:	ffffe097          	auipc	ra,0xffffe
    800030b6:	a0c080e7          	jalr	-1524(ra) # 80000abe <acquire>
  b->refcnt--;
    800030ba:	40bc                	lw	a5,64(s1)
    800030bc:	37fd                	addiw	a5,a5,-1
    800030be:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030c0:	00016517          	auipc	a0,0x16
    800030c4:	85850513          	addi	a0,a0,-1960 # 80018918 <bcache>
    800030c8:	ffffe097          	auipc	ra,0xffffe
    800030cc:	a5e080e7          	jalr	-1442(ra) # 80000b26 <release>
}
    800030d0:	60e2                	ld	ra,24(sp)
    800030d2:	6442                	ld	s0,16(sp)
    800030d4:	64a2                	ld	s1,8(sp)
    800030d6:	6105                	addi	sp,sp,32
    800030d8:	8082                	ret

00000000800030da <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030da:	1101                	addi	sp,sp,-32
    800030dc:	ec06                	sd	ra,24(sp)
    800030de:	e822                	sd	s0,16(sp)
    800030e0:	e426                	sd	s1,8(sp)
    800030e2:	e04a                	sd	s2,0(sp)
    800030e4:	1000                	addi	s0,sp,32
    800030e6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030e8:	00d5d59b          	srliw	a1,a1,0xd
    800030ec:	0001e797          	auipc	a5,0x1e
    800030f0:	0007a783          	lw	a5,0(a5) # 800210ec <sb+0x1c>
    800030f4:	9dbd                	addw	a1,a1,a5
    800030f6:	00000097          	auipc	ra,0x0
    800030fa:	d9a080e7          	jalr	-614(ra) # 80002e90 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030fe:	0074f713          	andi	a4,s1,7
    80003102:	4785                	li	a5,1
    80003104:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003108:	14ce                	slli	s1,s1,0x33
    8000310a:	90d9                	srli	s1,s1,0x36
    8000310c:	00950733          	add	a4,a0,s1
    80003110:	06074703          	lbu	a4,96(a4)
    80003114:	00e7f6b3          	and	a3,a5,a4
    80003118:	c69d                	beqz	a3,80003146 <bfree+0x6c>
    8000311a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000311c:	94aa                	add	s1,s1,a0
    8000311e:	fff7c793          	not	a5,a5
    80003122:	8ff9                	and	a5,a5,a4
    80003124:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80003128:	00001097          	auipc	ra,0x1
    8000312c:	1d0080e7          	jalr	464(ra) # 800042f8 <log_write>
  brelse(bp);
    80003130:	854a                	mv	a0,s2
    80003132:	00000097          	auipc	ra,0x0
    80003136:	e92080e7          	jalr	-366(ra) # 80002fc4 <brelse>
}
    8000313a:	60e2                	ld	ra,24(sp)
    8000313c:	6442                	ld	s0,16(sp)
    8000313e:	64a2                	ld	s1,8(sp)
    80003140:	6902                	ld	s2,0(sp)
    80003142:	6105                	addi	sp,sp,32
    80003144:	8082                	ret
    panic("freeing free block");
    80003146:	00005517          	auipc	a0,0x5
    8000314a:	40250513          	addi	a0,a0,1026 # 80008548 <userret+0x4b8>
    8000314e:	ffffd097          	auipc	ra,0xffffd
    80003152:	3fa080e7          	jalr	1018(ra) # 80000548 <panic>

0000000080003156 <balloc>:
{
    80003156:	711d                	addi	sp,sp,-96
    80003158:	ec86                	sd	ra,88(sp)
    8000315a:	e8a2                	sd	s0,80(sp)
    8000315c:	e4a6                	sd	s1,72(sp)
    8000315e:	e0ca                	sd	s2,64(sp)
    80003160:	fc4e                	sd	s3,56(sp)
    80003162:	f852                	sd	s4,48(sp)
    80003164:	f456                	sd	s5,40(sp)
    80003166:	f05a                	sd	s6,32(sp)
    80003168:	ec5e                	sd	s7,24(sp)
    8000316a:	e862                	sd	s8,16(sp)
    8000316c:	e466                	sd	s9,8(sp)
    8000316e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003170:	0001e797          	auipc	a5,0x1e
    80003174:	f647a783          	lw	a5,-156(a5) # 800210d4 <sb+0x4>
    80003178:	cbd1                	beqz	a5,8000320c <balloc+0xb6>
    8000317a:	8baa                	mv	s7,a0
    8000317c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000317e:	0001eb17          	auipc	s6,0x1e
    80003182:	f52b0b13          	addi	s6,s6,-174 # 800210d0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003186:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003188:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000318a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000318c:	6c89                	lui	s9,0x2
    8000318e:	a831                	j	800031aa <balloc+0x54>
    brelse(bp);
    80003190:	854a                	mv	a0,s2
    80003192:	00000097          	auipc	ra,0x0
    80003196:	e32080e7          	jalr	-462(ra) # 80002fc4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000319a:	015c87bb          	addw	a5,s9,s5
    8000319e:	00078a9b          	sext.w	s5,a5
    800031a2:	004b2703          	lw	a4,4(s6)
    800031a6:	06eaf363          	bgeu	s5,a4,8000320c <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800031aa:	41fad79b          	sraiw	a5,s5,0x1f
    800031ae:	0137d79b          	srliw	a5,a5,0x13
    800031b2:	015787bb          	addw	a5,a5,s5
    800031b6:	40d7d79b          	sraiw	a5,a5,0xd
    800031ba:	01cb2583          	lw	a1,28(s6)
    800031be:	9dbd                	addw	a1,a1,a5
    800031c0:	855e                	mv	a0,s7
    800031c2:	00000097          	auipc	ra,0x0
    800031c6:	cce080e7          	jalr	-818(ra) # 80002e90 <bread>
    800031ca:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031cc:	004b2503          	lw	a0,4(s6)
    800031d0:	000a849b          	sext.w	s1,s5
    800031d4:	8662                	mv	a2,s8
    800031d6:	faa4fde3          	bgeu	s1,a0,80003190 <balloc+0x3a>
      m = 1 << (bi % 8);
    800031da:	41f6579b          	sraiw	a5,a2,0x1f
    800031de:	01d7d69b          	srliw	a3,a5,0x1d
    800031e2:	00c6873b          	addw	a4,a3,a2
    800031e6:	00777793          	andi	a5,a4,7
    800031ea:	9f95                	subw	a5,a5,a3
    800031ec:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031f0:	4037571b          	sraiw	a4,a4,0x3
    800031f4:	00e906b3          	add	a3,s2,a4
    800031f8:	0606c683          	lbu	a3,96(a3)
    800031fc:	00d7f5b3          	and	a1,a5,a3
    80003200:	cd91                	beqz	a1,8000321c <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003202:	2605                	addiw	a2,a2,1
    80003204:	2485                	addiw	s1,s1,1
    80003206:	fd4618e3          	bne	a2,s4,800031d6 <balloc+0x80>
    8000320a:	b759                	j	80003190 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000320c:	00005517          	auipc	a0,0x5
    80003210:	35450513          	addi	a0,a0,852 # 80008560 <userret+0x4d0>
    80003214:	ffffd097          	auipc	ra,0xffffd
    80003218:	334080e7          	jalr	820(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000321c:	974a                	add	a4,a4,s2
    8000321e:	8fd5                	or	a5,a5,a3
    80003220:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    80003224:	854a                	mv	a0,s2
    80003226:	00001097          	auipc	ra,0x1
    8000322a:	0d2080e7          	jalr	210(ra) # 800042f8 <log_write>
        brelse(bp);
    8000322e:	854a                	mv	a0,s2
    80003230:	00000097          	auipc	ra,0x0
    80003234:	d94080e7          	jalr	-620(ra) # 80002fc4 <brelse>
  bp = bread(dev, bno);
    80003238:	85a6                	mv	a1,s1
    8000323a:	855e                	mv	a0,s7
    8000323c:	00000097          	auipc	ra,0x0
    80003240:	c54080e7          	jalr	-940(ra) # 80002e90 <bread>
    80003244:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003246:	40000613          	li	a2,1024
    8000324a:	4581                	li	a1,0
    8000324c:	06050513          	addi	a0,a0,96
    80003250:	ffffe097          	auipc	ra,0xffffe
    80003254:	932080e7          	jalr	-1742(ra) # 80000b82 <memset>
  log_write(bp);
    80003258:	854a                	mv	a0,s2
    8000325a:	00001097          	auipc	ra,0x1
    8000325e:	09e080e7          	jalr	158(ra) # 800042f8 <log_write>
  brelse(bp);
    80003262:	854a                	mv	a0,s2
    80003264:	00000097          	auipc	ra,0x0
    80003268:	d60080e7          	jalr	-672(ra) # 80002fc4 <brelse>
}
    8000326c:	8526                	mv	a0,s1
    8000326e:	60e6                	ld	ra,88(sp)
    80003270:	6446                	ld	s0,80(sp)
    80003272:	64a6                	ld	s1,72(sp)
    80003274:	6906                	ld	s2,64(sp)
    80003276:	79e2                	ld	s3,56(sp)
    80003278:	7a42                	ld	s4,48(sp)
    8000327a:	7aa2                	ld	s5,40(sp)
    8000327c:	7b02                	ld	s6,32(sp)
    8000327e:	6be2                	ld	s7,24(sp)
    80003280:	6c42                	ld	s8,16(sp)
    80003282:	6ca2                	ld	s9,8(sp)
    80003284:	6125                	addi	sp,sp,96
    80003286:	8082                	ret

0000000080003288 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003288:	7179                	addi	sp,sp,-48
    8000328a:	f406                	sd	ra,40(sp)
    8000328c:	f022                	sd	s0,32(sp)
    8000328e:	ec26                	sd	s1,24(sp)
    80003290:	e84a                	sd	s2,16(sp)
    80003292:	e44e                	sd	s3,8(sp)
    80003294:	e052                	sd	s4,0(sp)
    80003296:	1800                	addi	s0,sp,48
    80003298:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000329a:	47ad                	li	a5,11
    8000329c:	04b7fe63          	bgeu	a5,a1,800032f8 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800032a0:	ff45849b          	addiw	s1,a1,-12
    800032a4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032a8:	0ff00793          	li	a5,255
    800032ac:	0ae7e363          	bltu	a5,a4,80003352 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800032b0:	08052583          	lw	a1,128(a0)
    800032b4:	c5ad                	beqz	a1,8000331e <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800032b6:	00092503          	lw	a0,0(s2)
    800032ba:	00000097          	auipc	ra,0x0
    800032be:	bd6080e7          	jalr	-1066(ra) # 80002e90 <bread>
    800032c2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032c4:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    800032c8:	02049593          	slli	a1,s1,0x20
    800032cc:	9181                	srli	a1,a1,0x20
    800032ce:	058a                	slli	a1,a1,0x2
    800032d0:	00b784b3          	add	s1,a5,a1
    800032d4:	0004a983          	lw	s3,0(s1)
    800032d8:	04098d63          	beqz	s3,80003332 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800032dc:	8552                	mv	a0,s4
    800032de:	00000097          	auipc	ra,0x0
    800032e2:	ce6080e7          	jalr	-794(ra) # 80002fc4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032e6:	854e                	mv	a0,s3
    800032e8:	70a2                	ld	ra,40(sp)
    800032ea:	7402                	ld	s0,32(sp)
    800032ec:	64e2                	ld	s1,24(sp)
    800032ee:	6942                	ld	s2,16(sp)
    800032f0:	69a2                	ld	s3,8(sp)
    800032f2:	6a02                	ld	s4,0(sp)
    800032f4:	6145                	addi	sp,sp,48
    800032f6:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800032f8:	02059493          	slli	s1,a1,0x20
    800032fc:	9081                	srli	s1,s1,0x20
    800032fe:	048a                	slli	s1,s1,0x2
    80003300:	94aa                	add	s1,s1,a0
    80003302:	0504a983          	lw	s3,80(s1)
    80003306:	fe0990e3          	bnez	s3,800032e6 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000330a:	4108                	lw	a0,0(a0)
    8000330c:	00000097          	auipc	ra,0x0
    80003310:	e4a080e7          	jalr	-438(ra) # 80003156 <balloc>
    80003314:	0005099b          	sext.w	s3,a0
    80003318:	0534a823          	sw	s3,80(s1)
    8000331c:	b7e9                	j	800032e6 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000331e:	4108                	lw	a0,0(a0)
    80003320:	00000097          	auipc	ra,0x0
    80003324:	e36080e7          	jalr	-458(ra) # 80003156 <balloc>
    80003328:	0005059b          	sext.w	a1,a0
    8000332c:	08b92023          	sw	a1,128(s2)
    80003330:	b759                	j	800032b6 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003332:	00092503          	lw	a0,0(s2)
    80003336:	00000097          	auipc	ra,0x0
    8000333a:	e20080e7          	jalr	-480(ra) # 80003156 <balloc>
    8000333e:	0005099b          	sext.w	s3,a0
    80003342:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003346:	8552                	mv	a0,s4
    80003348:	00001097          	auipc	ra,0x1
    8000334c:	fb0080e7          	jalr	-80(ra) # 800042f8 <log_write>
    80003350:	b771                	j	800032dc <bmap+0x54>
  panic("bmap: out of range");
    80003352:	00005517          	auipc	a0,0x5
    80003356:	22650513          	addi	a0,a0,550 # 80008578 <userret+0x4e8>
    8000335a:	ffffd097          	auipc	ra,0xffffd
    8000335e:	1ee080e7          	jalr	494(ra) # 80000548 <panic>

0000000080003362 <iget>:
{
    80003362:	7179                	addi	sp,sp,-48
    80003364:	f406                	sd	ra,40(sp)
    80003366:	f022                	sd	s0,32(sp)
    80003368:	ec26                	sd	s1,24(sp)
    8000336a:	e84a                	sd	s2,16(sp)
    8000336c:	e44e                	sd	s3,8(sp)
    8000336e:	e052                	sd	s4,0(sp)
    80003370:	1800                	addi	s0,sp,48
    80003372:	89aa                	mv	s3,a0
    80003374:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003376:	0001e517          	auipc	a0,0x1e
    8000337a:	d7a50513          	addi	a0,a0,-646 # 800210f0 <icache>
    8000337e:	ffffd097          	auipc	ra,0xffffd
    80003382:	740080e7          	jalr	1856(ra) # 80000abe <acquire>
  empty = 0;
    80003386:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003388:	0001e497          	auipc	s1,0x1e
    8000338c:	d8048493          	addi	s1,s1,-640 # 80021108 <icache+0x18>
    80003390:	00020697          	auipc	a3,0x20
    80003394:	80868693          	addi	a3,a3,-2040 # 80022b98 <log>
    80003398:	a039                	j	800033a6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000339a:	02090b63          	beqz	s2,800033d0 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000339e:	08848493          	addi	s1,s1,136
    800033a2:	02d48a63          	beq	s1,a3,800033d6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033a6:	449c                	lw	a5,8(s1)
    800033a8:	fef059e3          	blez	a5,8000339a <iget+0x38>
    800033ac:	4098                	lw	a4,0(s1)
    800033ae:	ff3716e3          	bne	a4,s3,8000339a <iget+0x38>
    800033b2:	40d8                	lw	a4,4(s1)
    800033b4:	ff4713e3          	bne	a4,s4,8000339a <iget+0x38>
      ip->ref++;
    800033b8:	2785                	addiw	a5,a5,1
    800033ba:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800033bc:	0001e517          	auipc	a0,0x1e
    800033c0:	d3450513          	addi	a0,a0,-716 # 800210f0 <icache>
    800033c4:	ffffd097          	auipc	ra,0xffffd
    800033c8:	762080e7          	jalr	1890(ra) # 80000b26 <release>
      return ip;
    800033cc:	8926                	mv	s2,s1
    800033ce:	a03d                	j	800033fc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033d0:	f7f9                	bnez	a5,8000339e <iget+0x3c>
    800033d2:	8926                	mv	s2,s1
    800033d4:	b7e9                	j	8000339e <iget+0x3c>
  if(empty == 0)
    800033d6:	02090c63          	beqz	s2,8000340e <iget+0xac>
  ip->dev = dev;
    800033da:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033de:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033e2:	4785                	li	a5,1
    800033e4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033e8:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800033ec:	0001e517          	auipc	a0,0x1e
    800033f0:	d0450513          	addi	a0,a0,-764 # 800210f0 <icache>
    800033f4:	ffffd097          	auipc	ra,0xffffd
    800033f8:	732080e7          	jalr	1842(ra) # 80000b26 <release>
}
    800033fc:	854a                	mv	a0,s2
    800033fe:	70a2                	ld	ra,40(sp)
    80003400:	7402                	ld	s0,32(sp)
    80003402:	64e2                	ld	s1,24(sp)
    80003404:	6942                	ld	s2,16(sp)
    80003406:	69a2                	ld	s3,8(sp)
    80003408:	6a02                	ld	s4,0(sp)
    8000340a:	6145                	addi	sp,sp,48
    8000340c:	8082                	ret
    panic("iget: no inodes");
    8000340e:	00005517          	auipc	a0,0x5
    80003412:	18250513          	addi	a0,a0,386 # 80008590 <userret+0x500>
    80003416:	ffffd097          	auipc	ra,0xffffd
    8000341a:	132080e7          	jalr	306(ra) # 80000548 <panic>

000000008000341e <fsinit>:
fsinit(int dev) {
    8000341e:	7179                	addi	sp,sp,-48
    80003420:	f406                	sd	ra,40(sp)
    80003422:	f022                	sd	s0,32(sp)
    80003424:	ec26                	sd	s1,24(sp)
    80003426:	e84a                	sd	s2,16(sp)
    80003428:	e44e                	sd	s3,8(sp)
    8000342a:	1800                	addi	s0,sp,48
    8000342c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000342e:	4585                	li	a1,1
    80003430:	00000097          	auipc	ra,0x0
    80003434:	a60080e7          	jalr	-1440(ra) # 80002e90 <bread>
    80003438:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000343a:	0001e997          	auipc	s3,0x1e
    8000343e:	c9698993          	addi	s3,s3,-874 # 800210d0 <sb>
    80003442:	02000613          	li	a2,32
    80003446:	06050593          	addi	a1,a0,96
    8000344a:	854e                	mv	a0,s3
    8000344c:	ffffd097          	auipc	ra,0xffffd
    80003450:	792080e7          	jalr	1938(ra) # 80000bde <memmove>
  brelse(bp);
    80003454:	8526                	mv	a0,s1
    80003456:	00000097          	auipc	ra,0x0
    8000345a:	b6e080e7          	jalr	-1170(ra) # 80002fc4 <brelse>
  if(sb.magic != FSMAGIC)
    8000345e:	0009a703          	lw	a4,0(s3)
    80003462:	102037b7          	lui	a5,0x10203
    80003466:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000346a:	02f71263          	bne	a4,a5,8000348e <fsinit+0x70>
  initlog(dev, &sb);
    8000346e:	0001e597          	auipc	a1,0x1e
    80003472:	c6258593          	addi	a1,a1,-926 # 800210d0 <sb>
    80003476:	854a                	mv	a0,s2
    80003478:	00001097          	auipc	ra,0x1
    8000347c:	bfa080e7          	jalr	-1030(ra) # 80004072 <initlog>
}
    80003480:	70a2                	ld	ra,40(sp)
    80003482:	7402                	ld	s0,32(sp)
    80003484:	64e2                	ld	s1,24(sp)
    80003486:	6942                	ld	s2,16(sp)
    80003488:	69a2                	ld	s3,8(sp)
    8000348a:	6145                	addi	sp,sp,48
    8000348c:	8082                	ret
    panic("invalid file system");
    8000348e:	00005517          	auipc	a0,0x5
    80003492:	11250513          	addi	a0,a0,274 # 800085a0 <userret+0x510>
    80003496:	ffffd097          	auipc	ra,0xffffd
    8000349a:	0b2080e7          	jalr	178(ra) # 80000548 <panic>

000000008000349e <iinit>:
{
    8000349e:	7179                	addi	sp,sp,-48
    800034a0:	f406                	sd	ra,40(sp)
    800034a2:	f022                	sd	s0,32(sp)
    800034a4:	ec26                	sd	s1,24(sp)
    800034a6:	e84a                	sd	s2,16(sp)
    800034a8:	e44e                	sd	s3,8(sp)
    800034aa:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800034ac:	00005597          	auipc	a1,0x5
    800034b0:	10c58593          	addi	a1,a1,268 # 800085b8 <userret+0x528>
    800034b4:	0001e517          	auipc	a0,0x1e
    800034b8:	c3c50513          	addi	a0,a0,-964 # 800210f0 <icache>
    800034bc:	ffffd097          	auipc	ra,0xffffd
    800034c0:	4f4080e7          	jalr	1268(ra) # 800009b0 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034c4:	0001e497          	auipc	s1,0x1e
    800034c8:	c5448493          	addi	s1,s1,-940 # 80021118 <icache+0x28>
    800034cc:	0001f997          	auipc	s3,0x1f
    800034d0:	6dc98993          	addi	s3,s3,1756 # 80022ba8 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800034d4:	00005917          	auipc	s2,0x5
    800034d8:	0ec90913          	addi	s2,s2,236 # 800085c0 <userret+0x530>
    800034dc:	85ca                	mv	a1,s2
    800034de:	8526                	mv	a0,s1
    800034e0:	00001097          	auipc	ra,0x1
    800034e4:	076080e7          	jalr	118(ra) # 80004556 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034e8:	08848493          	addi	s1,s1,136
    800034ec:	ff3498e3          	bne	s1,s3,800034dc <iinit+0x3e>
}
    800034f0:	70a2                	ld	ra,40(sp)
    800034f2:	7402                	ld	s0,32(sp)
    800034f4:	64e2                	ld	s1,24(sp)
    800034f6:	6942                	ld	s2,16(sp)
    800034f8:	69a2                	ld	s3,8(sp)
    800034fa:	6145                	addi	sp,sp,48
    800034fc:	8082                	ret

00000000800034fe <ialloc>:
{
    800034fe:	715d                	addi	sp,sp,-80
    80003500:	e486                	sd	ra,72(sp)
    80003502:	e0a2                	sd	s0,64(sp)
    80003504:	fc26                	sd	s1,56(sp)
    80003506:	f84a                	sd	s2,48(sp)
    80003508:	f44e                	sd	s3,40(sp)
    8000350a:	f052                	sd	s4,32(sp)
    8000350c:	ec56                	sd	s5,24(sp)
    8000350e:	e85a                	sd	s6,16(sp)
    80003510:	e45e                	sd	s7,8(sp)
    80003512:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003514:	0001e717          	auipc	a4,0x1e
    80003518:	bc872703          	lw	a4,-1080(a4) # 800210dc <sb+0xc>
    8000351c:	4785                	li	a5,1
    8000351e:	04e7fa63          	bgeu	a5,a4,80003572 <ialloc+0x74>
    80003522:	8aaa                	mv	s5,a0
    80003524:	8bae                	mv	s7,a1
    80003526:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003528:	0001ea17          	auipc	s4,0x1e
    8000352c:	ba8a0a13          	addi	s4,s4,-1112 # 800210d0 <sb>
    80003530:	00048b1b          	sext.w	s6,s1
    80003534:	0044d793          	srli	a5,s1,0x4
    80003538:	018a2583          	lw	a1,24(s4)
    8000353c:	9dbd                	addw	a1,a1,a5
    8000353e:	8556                	mv	a0,s5
    80003540:	00000097          	auipc	ra,0x0
    80003544:	950080e7          	jalr	-1712(ra) # 80002e90 <bread>
    80003548:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000354a:	06050993          	addi	s3,a0,96
    8000354e:	00f4f793          	andi	a5,s1,15
    80003552:	079a                	slli	a5,a5,0x6
    80003554:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003556:	00099783          	lh	a5,0(s3)
    8000355a:	c785                	beqz	a5,80003582 <ialloc+0x84>
    brelse(bp);
    8000355c:	00000097          	auipc	ra,0x0
    80003560:	a68080e7          	jalr	-1432(ra) # 80002fc4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003564:	0485                	addi	s1,s1,1
    80003566:	00ca2703          	lw	a4,12(s4)
    8000356a:	0004879b          	sext.w	a5,s1
    8000356e:	fce7e1e3          	bltu	a5,a4,80003530 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003572:	00005517          	auipc	a0,0x5
    80003576:	05650513          	addi	a0,a0,86 # 800085c8 <userret+0x538>
    8000357a:	ffffd097          	auipc	ra,0xffffd
    8000357e:	fce080e7          	jalr	-50(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    80003582:	04000613          	li	a2,64
    80003586:	4581                	li	a1,0
    80003588:	854e                	mv	a0,s3
    8000358a:	ffffd097          	auipc	ra,0xffffd
    8000358e:	5f8080e7          	jalr	1528(ra) # 80000b82 <memset>
      dip->type = type;
    80003592:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003596:	854a                	mv	a0,s2
    80003598:	00001097          	auipc	ra,0x1
    8000359c:	d60080e7          	jalr	-672(ra) # 800042f8 <log_write>
      brelse(bp);
    800035a0:	854a                	mv	a0,s2
    800035a2:	00000097          	auipc	ra,0x0
    800035a6:	a22080e7          	jalr	-1502(ra) # 80002fc4 <brelse>
      return iget(dev, inum);
    800035aa:	85da                	mv	a1,s6
    800035ac:	8556                	mv	a0,s5
    800035ae:	00000097          	auipc	ra,0x0
    800035b2:	db4080e7          	jalr	-588(ra) # 80003362 <iget>
}
    800035b6:	60a6                	ld	ra,72(sp)
    800035b8:	6406                	ld	s0,64(sp)
    800035ba:	74e2                	ld	s1,56(sp)
    800035bc:	7942                	ld	s2,48(sp)
    800035be:	79a2                	ld	s3,40(sp)
    800035c0:	7a02                	ld	s4,32(sp)
    800035c2:	6ae2                	ld	s5,24(sp)
    800035c4:	6b42                	ld	s6,16(sp)
    800035c6:	6ba2                	ld	s7,8(sp)
    800035c8:	6161                	addi	sp,sp,80
    800035ca:	8082                	ret

00000000800035cc <iupdate>:
{
    800035cc:	1101                	addi	sp,sp,-32
    800035ce:	ec06                	sd	ra,24(sp)
    800035d0:	e822                	sd	s0,16(sp)
    800035d2:	e426                	sd	s1,8(sp)
    800035d4:	e04a                	sd	s2,0(sp)
    800035d6:	1000                	addi	s0,sp,32
    800035d8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035da:	415c                	lw	a5,4(a0)
    800035dc:	0047d79b          	srliw	a5,a5,0x4
    800035e0:	0001e597          	auipc	a1,0x1e
    800035e4:	b085a583          	lw	a1,-1272(a1) # 800210e8 <sb+0x18>
    800035e8:	9dbd                	addw	a1,a1,a5
    800035ea:	4108                	lw	a0,0(a0)
    800035ec:	00000097          	auipc	ra,0x0
    800035f0:	8a4080e7          	jalr	-1884(ra) # 80002e90 <bread>
    800035f4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035f6:	06050793          	addi	a5,a0,96
    800035fa:	40c8                	lw	a0,4(s1)
    800035fc:	893d                	andi	a0,a0,15
    800035fe:	051a                	slli	a0,a0,0x6
    80003600:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003602:	04449703          	lh	a4,68(s1)
    80003606:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000360a:	04649703          	lh	a4,70(s1)
    8000360e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003612:	04849703          	lh	a4,72(s1)
    80003616:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000361a:	04a49703          	lh	a4,74(s1)
    8000361e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003622:	44f8                	lw	a4,76(s1)
    80003624:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003626:	03400613          	li	a2,52
    8000362a:	05048593          	addi	a1,s1,80
    8000362e:	0531                	addi	a0,a0,12
    80003630:	ffffd097          	auipc	ra,0xffffd
    80003634:	5ae080e7          	jalr	1454(ra) # 80000bde <memmove>
  log_write(bp);
    80003638:	854a                	mv	a0,s2
    8000363a:	00001097          	auipc	ra,0x1
    8000363e:	cbe080e7          	jalr	-834(ra) # 800042f8 <log_write>
  brelse(bp);
    80003642:	854a                	mv	a0,s2
    80003644:	00000097          	auipc	ra,0x0
    80003648:	980080e7          	jalr	-1664(ra) # 80002fc4 <brelse>
}
    8000364c:	60e2                	ld	ra,24(sp)
    8000364e:	6442                	ld	s0,16(sp)
    80003650:	64a2                	ld	s1,8(sp)
    80003652:	6902                	ld	s2,0(sp)
    80003654:	6105                	addi	sp,sp,32
    80003656:	8082                	ret

0000000080003658 <idup>:
{
    80003658:	1101                	addi	sp,sp,-32
    8000365a:	ec06                	sd	ra,24(sp)
    8000365c:	e822                	sd	s0,16(sp)
    8000365e:	e426                	sd	s1,8(sp)
    80003660:	1000                	addi	s0,sp,32
    80003662:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003664:	0001e517          	auipc	a0,0x1e
    80003668:	a8c50513          	addi	a0,a0,-1396 # 800210f0 <icache>
    8000366c:	ffffd097          	auipc	ra,0xffffd
    80003670:	452080e7          	jalr	1106(ra) # 80000abe <acquire>
  ip->ref++;
    80003674:	449c                	lw	a5,8(s1)
    80003676:	2785                	addiw	a5,a5,1
    80003678:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000367a:	0001e517          	auipc	a0,0x1e
    8000367e:	a7650513          	addi	a0,a0,-1418 # 800210f0 <icache>
    80003682:	ffffd097          	auipc	ra,0xffffd
    80003686:	4a4080e7          	jalr	1188(ra) # 80000b26 <release>
}
    8000368a:	8526                	mv	a0,s1
    8000368c:	60e2                	ld	ra,24(sp)
    8000368e:	6442                	ld	s0,16(sp)
    80003690:	64a2                	ld	s1,8(sp)
    80003692:	6105                	addi	sp,sp,32
    80003694:	8082                	ret

0000000080003696 <ilock>:
{
    80003696:	1101                	addi	sp,sp,-32
    80003698:	ec06                	sd	ra,24(sp)
    8000369a:	e822                	sd	s0,16(sp)
    8000369c:	e426                	sd	s1,8(sp)
    8000369e:	e04a                	sd	s2,0(sp)
    800036a0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036a2:	c115                	beqz	a0,800036c6 <ilock+0x30>
    800036a4:	84aa                	mv	s1,a0
    800036a6:	451c                	lw	a5,8(a0)
    800036a8:	00f05f63          	blez	a5,800036c6 <ilock+0x30>
  acquiresleep(&ip->lock);
    800036ac:	0541                	addi	a0,a0,16
    800036ae:	00001097          	auipc	ra,0x1
    800036b2:	ee2080e7          	jalr	-286(ra) # 80004590 <acquiresleep>
  if(ip->valid == 0){
    800036b6:	40bc                	lw	a5,64(s1)
    800036b8:	cf99                	beqz	a5,800036d6 <ilock+0x40>
}
    800036ba:	60e2                	ld	ra,24(sp)
    800036bc:	6442                	ld	s0,16(sp)
    800036be:	64a2                	ld	s1,8(sp)
    800036c0:	6902                	ld	s2,0(sp)
    800036c2:	6105                	addi	sp,sp,32
    800036c4:	8082                	ret
    panic("ilock");
    800036c6:	00005517          	auipc	a0,0x5
    800036ca:	f1a50513          	addi	a0,a0,-230 # 800085e0 <userret+0x550>
    800036ce:	ffffd097          	auipc	ra,0xffffd
    800036d2:	e7a080e7          	jalr	-390(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036d6:	40dc                	lw	a5,4(s1)
    800036d8:	0047d79b          	srliw	a5,a5,0x4
    800036dc:	0001e597          	auipc	a1,0x1e
    800036e0:	a0c5a583          	lw	a1,-1524(a1) # 800210e8 <sb+0x18>
    800036e4:	9dbd                	addw	a1,a1,a5
    800036e6:	4088                	lw	a0,0(s1)
    800036e8:	fffff097          	auipc	ra,0xfffff
    800036ec:	7a8080e7          	jalr	1960(ra) # 80002e90 <bread>
    800036f0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036f2:	06050593          	addi	a1,a0,96
    800036f6:	40dc                	lw	a5,4(s1)
    800036f8:	8bbd                	andi	a5,a5,15
    800036fa:	079a                	slli	a5,a5,0x6
    800036fc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036fe:	00059783          	lh	a5,0(a1)
    80003702:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003706:	00259783          	lh	a5,2(a1)
    8000370a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000370e:	00459783          	lh	a5,4(a1)
    80003712:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003716:	00659783          	lh	a5,6(a1)
    8000371a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000371e:	459c                	lw	a5,8(a1)
    80003720:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003722:	03400613          	li	a2,52
    80003726:	05b1                	addi	a1,a1,12
    80003728:	05048513          	addi	a0,s1,80
    8000372c:	ffffd097          	auipc	ra,0xffffd
    80003730:	4b2080e7          	jalr	1202(ra) # 80000bde <memmove>
    brelse(bp);
    80003734:	854a                	mv	a0,s2
    80003736:	00000097          	auipc	ra,0x0
    8000373a:	88e080e7          	jalr	-1906(ra) # 80002fc4 <brelse>
    ip->valid = 1;
    8000373e:	4785                	li	a5,1
    80003740:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003742:	04449783          	lh	a5,68(s1)
    80003746:	fbb5                	bnez	a5,800036ba <ilock+0x24>
      panic("ilock: no type");
    80003748:	00005517          	auipc	a0,0x5
    8000374c:	ea050513          	addi	a0,a0,-352 # 800085e8 <userret+0x558>
    80003750:	ffffd097          	auipc	ra,0xffffd
    80003754:	df8080e7          	jalr	-520(ra) # 80000548 <panic>

0000000080003758 <iunlock>:
{
    80003758:	1101                	addi	sp,sp,-32
    8000375a:	ec06                	sd	ra,24(sp)
    8000375c:	e822                	sd	s0,16(sp)
    8000375e:	e426                	sd	s1,8(sp)
    80003760:	e04a                	sd	s2,0(sp)
    80003762:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003764:	c905                	beqz	a0,80003794 <iunlock+0x3c>
    80003766:	84aa                	mv	s1,a0
    80003768:	01050913          	addi	s2,a0,16
    8000376c:	854a                	mv	a0,s2
    8000376e:	00001097          	auipc	ra,0x1
    80003772:	ebc080e7          	jalr	-324(ra) # 8000462a <holdingsleep>
    80003776:	cd19                	beqz	a0,80003794 <iunlock+0x3c>
    80003778:	449c                	lw	a5,8(s1)
    8000377a:	00f05d63          	blez	a5,80003794 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000377e:	854a                	mv	a0,s2
    80003780:	00001097          	auipc	ra,0x1
    80003784:	e66080e7          	jalr	-410(ra) # 800045e6 <releasesleep>
}
    80003788:	60e2                	ld	ra,24(sp)
    8000378a:	6442                	ld	s0,16(sp)
    8000378c:	64a2                	ld	s1,8(sp)
    8000378e:	6902                	ld	s2,0(sp)
    80003790:	6105                	addi	sp,sp,32
    80003792:	8082                	ret
    panic("iunlock");
    80003794:	00005517          	auipc	a0,0x5
    80003798:	e6450513          	addi	a0,a0,-412 # 800085f8 <userret+0x568>
    8000379c:	ffffd097          	auipc	ra,0xffffd
    800037a0:	dac080e7          	jalr	-596(ra) # 80000548 <panic>

00000000800037a4 <iput>:
{
    800037a4:	7139                	addi	sp,sp,-64
    800037a6:	fc06                	sd	ra,56(sp)
    800037a8:	f822                	sd	s0,48(sp)
    800037aa:	f426                	sd	s1,40(sp)
    800037ac:	f04a                	sd	s2,32(sp)
    800037ae:	ec4e                	sd	s3,24(sp)
    800037b0:	e852                	sd	s4,16(sp)
    800037b2:	e456                	sd	s5,8(sp)
    800037b4:	0080                	addi	s0,sp,64
    800037b6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800037b8:	0001e517          	auipc	a0,0x1e
    800037bc:	93850513          	addi	a0,a0,-1736 # 800210f0 <icache>
    800037c0:	ffffd097          	auipc	ra,0xffffd
    800037c4:	2fe080e7          	jalr	766(ra) # 80000abe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037c8:	4498                	lw	a4,8(s1)
    800037ca:	4785                	li	a5,1
    800037cc:	02f70663          	beq	a4,a5,800037f8 <iput+0x54>
  ip->ref--;
    800037d0:	449c                	lw	a5,8(s1)
    800037d2:	37fd                	addiw	a5,a5,-1
    800037d4:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800037d6:	0001e517          	auipc	a0,0x1e
    800037da:	91a50513          	addi	a0,a0,-1766 # 800210f0 <icache>
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	348080e7          	jalr	840(ra) # 80000b26 <release>
}
    800037e6:	70e2                	ld	ra,56(sp)
    800037e8:	7442                	ld	s0,48(sp)
    800037ea:	74a2                	ld	s1,40(sp)
    800037ec:	7902                	ld	s2,32(sp)
    800037ee:	69e2                	ld	s3,24(sp)
    800037f0:	6a42                	ld	s4,16(sp)
    800037f2:	6aa2                	ld	s5,8(sp)
    800037f4:	6121                	addi	sp,sp,64
    800037f6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037f8:	40bc                	lw	a5,64(s1)
    800037fa:	dbf9                	beqz	a5,800037d0 <iput+0x2c>
    800037fc:	04a49783          	lh	a5,74(s1)
    80003800:	fbe1                	bnez	a5,800037d0 <iput+0x2c>
    acquiresleep(&ip->lock);
    80003802:	01048a13          	addi	s4,s1,16
    80003806:	8552                	mv	a0,s4
    80003808:	00001097          	auipc	ra,0x1
    8000380c:	d88080e7          	jalr	-632(ra) # 80004590 <acquiresleep>
    release(&icache.lock);
    80003810:	0001e517          	auipc	a0,0x1e
    80003814:	8e050513          	addi	a0,a0,-1824 # 800210f0 <icache>
    80003818:	ffffd097          	auipc	ra,0xffffd
    8000381c:	30e080e7          	jalr	782(ra) # 80000b26 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003820:	05048913          	addi	s2,s1,80
    80003824:	08048993          	addi	s3,s1,128
    80003828:	a021                	j	80003830 <iput+0x8c>
    8000382a:	0911                	addi	s2,s2,4
    8000382c:	01390d63          	beq	s2,s3,80003846 <iput+0xa2>
    if(ip->addrs[i]){
    80003830:	00092583          	lw	a1,0(s2)
    80003834:	d9fd                	beqz	a1,8000382a <iput+0x86>
      bfree(ip->dev, ip->addrs[i]);
    80003836:	4088                	lw	a0,0(s1)
    80003838:	00000097          	auipc	ra,0x0
    8000383c:	8a2080e7          	jalr	-1886(ra) # 800030da <bfree>
      ip->addrs[i] = 0;
    80003840:	00092023          	sw	zero,0(s2)
    80003844:	b7dd                	j	8000382a <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003846:	0804a583          	lw	a1,128(s1)
    8000384a:	ed9d                	bnez	a1,80003888 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000384c:	0404a623          	sw	zero,76(s1)
  iupdate(ip);
    80003850:	8526                	mv	a0,s1
    80003852:	00000097          	auipc	ra,0x0
    80003856:	d7a080e7          	jalr	-646(ra) # 800035cc <iupdate>
    ip->type = 0;
    8000385a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000385e:	8526                	mv	a0,s1
    80003860:	00000097          	auipc	ra,0x0
    80003864:	d6c080e7          	jalr	-660(ra) # 800035cc <iupdate>
    ip->valid = 0;
    80003868:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000386c:	8552                	mv	a0,s4
    8000386e:	00001097          	auipc	ra,0x1
    80003872:	d78080e7          	jalr	-648(ra) # 800045e6 <releasesleep>
    acquire(&icache.lock);
    80003876:	0001e517          	auipc	a0,0x1e
    8000387a:	87a50513          	addi	a0,a0,-1926 # 800210f0 <icache>
    8000387e:	ffffd097          	auipc	ra,0xffffd
    80003882:	240080e7          	jalr	576(ra) # 80000abe <acquire>
    80003886:	b7a9                	j	800037d0 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003888:	4088                	lw	a0,0(s1)
    8000388a:	fffff097          	auipc	ra,0xfffff
    8000388e:	606080e7          	jalr	1542(ra) # 80002e90 <bread>
    80003892:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003894:	06050913          	addi	s2,a0,96
    80003898:	46050993          	addi	s3,a0,1120
    8000389c:	a021                	j	800038a4 <iput+0x100>
    8000389e:	0911                	addi	s2,s2,4
    800038a0:	01390b63          	beq	s2,s3,800038b6 <iput+0x112>
      if(a[j])
    800038a4:	00092583          	lw	a1,0(s2)
    800038a8:	d9fd                	beqz	a1,8000389e <iput+0xfa>
        bfree(ip->dev, a[j]);
    800038aa:	4088                	lw	a0,0(s1)
    800038ac:	00000097          	auipc	ra,0x0
    800038b0:	82e080e7          	jalr	-2002(ra) # 800030da <bfree>
    800038b4:	b7ed                	j	8000389e <iput+0xfa>
    brelse(bp);
    800038b6:	8556                	mv	a0,s5
    800038b8:	fffff097          	auipc	ra,0xfffff
    800038bc:	70c080e7          	jalr	1804(ra) # 80002fc4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038c0:	0804a583          	lw	a1,128(s1)
    800038c4:	4088                	lw	a0,0(s1)
    800038c6:	00000097          	auipc	ra,0x0
    800038ca:	814080e7          	jalr	-2028(ra) # 800030da <bfree>
    ip->addrs[NDIRECT] = 0;
    800038ce:	0804a023          	sw	zero,128(s1)
    800038d2:	bfad                	j	8000384c <iput+0xa8>

00000000800038d4 <iunlockput>:
{
    800038d4:	1101                	addi	sp,sp,-32
    800038d6:	ec06                	sd	ra,24(sp)
    800038d8:	e822                	sd	s0,16(sp)
    800038da:	e426                	sd	s1,8(sp)
    800038dc:	1000                	addi	s0,sp,32
    800038de:	84aa                	mv	s1,a0
  iunlock(ip);
    800038e0:	00000097          	auipc	ra,0x0
    800038e4:	e78080e7          	jalr	-392(ra) # 80003758 <iunlock>
  iput(ip);
    800038e8:	8526                	mv	a0,s1
    800038ea:	00000097          	auipc	ra,0x0
    800038ee:	eba080e7          	jalr	-326(ra) # 800037a4 <iput>
}
    800038f2:	60e2                	ld	ra,24(sp)
    800038f4:	6442                	ld	s0,16(sp)
    800038f6:	64a2                	ld	s1,8(sp)
    800038f8:	6105                	addi	sp,sp,32
    800038fa:	8082                	ret

00000000800038fc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038fc:	1141                	addi	sp,sp,-16
    800038fe:	e422                	sd	s0,8(sp)
    80003900:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003902:	411c                	lw	a5,0(a0)
    80003904:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003906:	415c                	lw	a5,4(a0)
    80003908:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000390a:	04451783          	lh	a5,68(a0)
    8000390e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003912:	04a51783          	lh	a5,74(a0)
    80003916:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000391a:	04c56783          	lwu	a5,76(a0)
    8000391e:	e99c                	sd	a5,16(a1)
}
    80003920:	6422                	ld	s0,8(sp)
    80003922:	0141                	addi	sp,sp,16
    80003924:	8082                	ret

0000000080003926 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003926:	457c                	lw	a5,76(a0)
    80003928:	0ed7e563          	bltu	a5,a3,80003a12 <readi+0xec>
{
    8000392c:	7159                	addi	sp,sp,-112
    8000392e:	f486                	sd	ra,104(sp)
    80003930:	f0a2                	sd	s0,96(sp)
    80003932:	eca6                	sd	s1,88(sp)
    80003934:	e8ca                	sd	s2,80(sp)
    80003936:	e4ce                	sd	s3,72(sp)
    80003938:	e0d2                	sd	s4,64(sp)
    8000393a:	fc56                	sd	s5,56(sp)
    8000393c:	f85a                	sd	s6,48(sp)
    8000393e:	f45e                	sd	s7,40(sp)
    80003940:	f062                	sd	s8,32(sp)
    80003942:	ec66                	sd	s9,24(sp)
    80003944:	e86a                	sd	s10,16(sp)
    80003946:	e46e                	sd	s11,8(sp)
    80003948:	1880                	addi	s0,sp,112
    8000394a:	8baa                	mv	s7,a0
    8000394c:	8c2e                	mv	s8,a1
    8000394e:	8ab2                	mv	s5,a2
    80003950:	8936                	mv	s2,a3
    80003952:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003954:	9f35                	addw	a4,a4,a3
    80003956:	0cd76063          	bltu	a4,a3,80003a16 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    8000395a:	00e7f463          	bgeu	a5,a4,80003962 <readi+0x3c>
    n = ip->size - off;
    8000395e:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003962:	080b0763          	beqz	s6,800039f0 <readi+0xca>
    80003966:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003968:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000396c:	5cfd                	li	s9,-1
    8000396e:	a82d                	j	800039a8 <readi+0x82>
    80003970:	02099d93          	slli	s11,s3,0x20
    80003974:	020ddd93          	srli	s11,s11,0x20
    80003978:	06048793          	addi	a5,s1,96
    8000397c:	86ee                	mv	a3,s11
    8000397e:	963e                	add	a2,a2,a5
    80003980:	85d6                	mv	a1,s5
    80003982:	8562                	mv	a0,s8
    80003984:	fffff097          	auipc	ra,0xfffff
    80003988:	ade080e7          	jalr	-1314(ra) # 80002462 <either_copyout>
    8000398c:	05950d63          	beq	a0,s9,800039e6 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003990:	8526                	mv	a0,s1
    80003992:	fffff097          	auipc	ra,0xfffff
    80003996:	632080e7          	jalr	1586(ra) # 80002fc4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000399a:	01498a3b          	addw	s4,s3,s4
    8000399e:	0129893b          	addw	s2,s3,s2
    800039a2:	9aee                	add	s5,s5,s11
    800039a4:	056a7663          	bgeu	s4,s6,800039f0 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800039a8:	000ba483          	lw	s1,0(s7)
    800039ac:	00a9559b          	srliw	a1,s2,0xa
    800039b0:	855e                	mv	a0,s7
    800039b2:	00000097          	auipc	ra,0x0
    800039b6:	8d6080e7          	jalr	-1834(ra) # 80003288 <bmap>
    800039ba:	0005059b          	sext.w	a1,a0
    800039be:	8526                	mv	a0,s1
    800039c0:	fffff097          	auipc	ra,0xfffff
    800039c4:	4d0080e7          	jalr	1232(ra) # 80002e90 <bread>
    800039c8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ca:	3ff97613          	andi	a2,s2,1023
    800039ce:	40cd07bb          	subw	a5,s10,a2
    800039d2:	414b073b          	subw	a4,s6,s4
    800039d6:	89be                	mv	s3,a5
    800039d8:	2781                	sext.w	a5,a5
    800039da:	0007069b          	sext.w	a3,a4
    800039de:	f8f6f9e3          	bgeu	a3,a5,80003970 <readi+0x4a>
    800039e2:	89ba                	mv	s3,a4
    800039e4:	b771                	j	80003970 <readi+0x4a>
      brelse(bp);
    800039e6:	8526                	mv	a0,s1
    800039e8:	fffff097          	auipc	ra,0xfffff
    800039ec:	5dc080e7          	jalr	1500(ra) # 80002fc4 <brelse>
  }
  return n;
    800039f0:	000b051b          	sext.w	a0,s6
}
    800039f4:	70a6                	ld	ra,104(sp)
    800039f6:	7406                	ld	s0,96(sp)
    800039f8:	64e6                	ld	s1,88(sp)
    800039fa:	6946                	ld	s2,80(sp)
    800039fc:	69a6                	ld	s3,72(sp)
    800039fe:	6a06                	ld	s4,64(sp)
    80003a00:	7ae2                	ld	s5,56(sp)
    80003a02:	7b42                	ld	s6,48(sp)
    80003a04:	7ba2                	ld	s7,40(sp)
    80003a06:	7c02                	ld	s8,32(sp)
    80003a08:	6ce2                	ld	s9,24(sp)
    80003a0a:	6d42                	ld	s10,16(sp)
    80003a0c:	6da2                	ld	s11,8(sp)
    80003a0e:	6165                	addi	sp,sp,112
    80003a10:	8082                	ret
    return -1;
    80003a12:	557d                	li	a0,-1
}
    80003a14:	8082                	ret
    return -1;
    80003a16:	557d                	li	a0,-1
    80003a18:	bff1                	j	800039f4 <readi+0xce>

0000000080003a1a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a1a:	457c                	lw	a5,76(a0)
    80003a1c:	10d7e663          	bltu	a5,a3,80003b28 <writei+0x10e>
{
    80003a20:	7159                	addi	sp,sp,-112
    80003a22:	f486                	sd	ra,104(sp)
    80003a24:	f0a2                	sd	s0,96(sp)
    80003a26:	eca6                	sd	s1,88(sp)
    80003a28:	e8ca                	sd	s2,80(sp)
    80003a2a:	e4ce                	sd	s3,72(sp)
    80003a2c:	e0d2                	sd	s4,64(sp)
    80003a2e:	fc56                	sd	s5,56(sp)
    80003a30:	f85a                	sd	s6,48(sp)
    80003a32:	f45e                	sd	s7,40(sp)
    80003a34:	f062                	sd	s8,32(sp)
    80003a36:	ec66                	sd	s9,24(sp)
    80003a38:	e86a                	sd	s10,16(sp)
    80003a3a:	e46e                	sd	s11,8(sp)
    80003a3c:	1880                	addi	s0,sp,112
    80003a3e:	8baa                	mv	s7,a0
    80003a40:	8c2e                	mv	s8,a1
    80003a42:	8ab2                	mv	s5,a2
    80003a44:	8936                	mv	s2,a3
    80003a46:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a48:	00e687bb          	addw	a5,a3,a4
    80003a4c:	0ed7e063          	bltu	a5,a3,80003b2c <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a50:	00043737          	lui	a4,0x43
    80003a54:	0cf76e63          	bltu	a4,a5,80003b30 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a58:	0a0b0763          	beqz	s6,80003b06 <writei+0xec>
    80003a5c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a5e:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a62:	5cfd                	li	s9,-1
    80003a64:	a091                	j	80003aa8 <writei+0x8e>
    80003a66:	02099d93          	slli	s11,s3,0x20
    80003a6a:	020ddd93          	srli	s11,s11,0x20
    80003a6e:	06048793          	addi	a5,s1,96
    80003a72:	86ee                	mv	a3,s11
    80003a74:	8656                	mv	a2,s5
    80003a76:	85e2                	mv	a1,s8
    80003a78:	953e                	add	a0,a0,a5
    80003a7a:	fffff097          	auipc	ra,0xfffff
    80003a7e:	a3e080e7          	jalr	-1474(ra) # 800024b8 <either_copyin>
    80003a82:	07950263          	beq	a0,s9,80003ae6 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a86:	8526                	mv	a0,s1
    80003a88:	00001097          	auipc	ra,0x1
    80003a8c:	870080e7          	jalr	-1936(ra) # 800042f8 <log_write>
    brelse(bp);
    80003a90:	8526                	mv	a0,s1
    80003a92:	fffff097          	auipc	ra,0xfffff
    80003a96:	532080e7          	jalr	1330(ra) # 80002fc4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a9a:	01498a3b          	addw	s4,s3,s4
    80003a9e:	0129893b          	addw	s2,s3,s2
    80003aa2:	9aee                	add	s5,s5,s11
    80003aa4:	056a7663          	bgeu	s4,s6,80003af0 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003aa8:	000ba483          	lw	s1,0(s7)
    80003aac:	00a9559b          	srliw	a1,s2,0xa
    80003ab0:	855e                	mv	a0,s7
    80003ab2:	fffff097          	auipc	ra,0xfffff
    80003ab6:	7d6080e7          	jalr	2006(ra) # 80003288 <bmap>
    80003aba:	0005059b          	sext.w	a1,a0
    80003abe:	8526                	mv	a0,s1
    80003ac0:	fffff097          	auipc	ra,0xfffff
    80003ac4:	3d0080e7          	jalr	976(ra) # 80002e90 <bread>
    80003ac8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aca:	3ff97513          	andi	a0,s2,1023
    80003ace:	40ad07bb          	subw	a5,s10,a0
    80003ad2:	414b073b          	subw	a4,s6,s4
    80003ad6:	89be                	mv	s3,a5
    80003ad8:	2781                	sext.w	a5,a5
    80003ada:	0007069b          	sext.w	a3,a4
    80003ade:	f8f6f4e3          	bgeu	a3,a5,80003a66 <writei+0x4c>
    80003ae2:	89ba                	mv	s3,a4
    80003ae4:	b749                	j	80003a66 <writei+0x4c>
      brelse(bp);
    80003ae6:	8526                	mv	a0,s1
    80003ae8:	fffff097          	auipc	ra,0xfffff
    80003aec:	4dc080e7          	jalr	1244(ra) # 80002fc4 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003af0:	04cba783          	lw	a5,76(s7)
    80003af4:	0127f463          	bgeu	a5,s2,80003afc <writei+0xe2>
      ip->size = off;
    80003af8:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003afc:	855e                	mv	a0,s7
    80003afe:	00000097          	auipc	ra,0x0
    80003b02:	ace080e7          	jalr	-1330(ra) # 800035cc <iupdate>
  }

  return n;
    80003b06:	000b051b          	sext.w	a0,s6
}
    80003b0a:	70a6                	ld	ra,104(sp)
    80003b0c:	7406                	ld	s0,96(sp)
    80003b0e:	64e6                	ld	s1,88(sp)
    80003b10:	6946                	ld	s2,80(sp)
    80003b12:	69a6                	ld	s3,72(sp)
    80003b14:	6a06                	ld	s4,64(sp)
    80003b16:	7ae2                	ld	s5,56(sp)
    80003b18:	7b42                	ld	s6,48(sp)
    80003b1a:	7ba2                	ld	s7,40(sp)
    80003b1c:	7c02                	ld	s8,32(sp)
    80003b1e:	6ce2                	ld	s9,24(sp)
    80003b20:	6d42                	ld	s10,16(sp)
    80003b22:	6da2                	ld	s11,8(sp)
    80003b24:	6165                	addi	sp,sp,112
    80003b26:	8082                	ret
    return -1;
    80003b28:	557d                	li	a0,-1
}
    80003b2a:	8082                	ret
    return -1;
    80003b2c:	557d                	li	a0,-1
    80003b2e:	bff1                	j	80003b0a <writei+0xf0>
    return -1;
    80003b30:	557d                	li	a0,-1
    80003b32:	bfe1                	j	80003b0a <writei+0xf0>

0000000080003b34 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b34:	1141                	addi	sp,sp,-16
    80003b36:	e406                	sd	ra,8(sp)
    80003b38:	e022                	sd	s0,0(sp)
    80003b3a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b3c:	4639                	li	a2,14
    80003b3e:	ffffd097          	auipc	ra,0xffffd
    80003b42:	11c080e7          	jalr	284(ra) # 80000c5a <strncmp>
}
    80003b46:	60a2                	ld	ra,8(sp)
    80003b48:	6402                	ld	s0,0(sp)
    80003b4a:	0141                	addi	sp,sp,16
    80003b4c:	8082                	ret

0000000080003b4e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b4e:	7139                	addi	sp,sp,-64
    80003b50:	fc06                	sd	ra,56(sp)
    80003b52:	f822                	sd	s0,48(sp)
    80003b54:	f426                	sd	s1,40(sp)
    80003b56:	f04a                	sd	s2,32(sp)
    80003b58:	ec4e                	sd	s3,24(sp)
    80003b5a:	e852                	sd	s4,16(sp)
    80003b5c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b5e:	04451703          	lh	a4,68(a0)
    80003b62:	4785                	li	a5,1
    80003b64:	00f71a63          	bne	a4,a5,80003b78 <dirlookup+0x2a>
    80003b68:	892a                	mv	s2,a0
    80003b6a:	89ae                	mv	s3,a1
    80003b6c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b6e:	457c                	lw	a5,76(a0)
    80003b70:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b72:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b74:	e79d                	bnez	a5,80003ba2 <dirlookup+0x54>
    80003b76:	a8a5                	j	80003bee <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b78:	00005517          	auipc	a0,0x5
    80003b7c:	a8850513          	addi	a0,a0,-1400 # 80008600 <userret+0x570>
    80003b80:	ffffd097          	auipc	ra,0xffffd
    80003b84:	9c8080e7          	jalr	-1592(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003b88:	00005517          	auipc	a0,0x5
    80003b8c:	a9050513          	addi	a0,a0,-1392 # 80008618 <userret+0x588>
    80003b90:	ffffd097          	auipc	ra,0xffffd
    80003b94:	9b8080e7          	jalr	-1608(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b98:	24c1                	addiw	s1,s1,16
    80003b9a:	04c92783          	lw	a5,76(s2)
    80003b9e:	04f4f763          	bgeu	s1,a5,80003bec <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ba2:	4741                	li	a4,16
    80003ba4:	86a6                	mv	a3,s1
    80003ba6:	fc040613          	addi	a2,s0,-64
    80003baa:	4581                	li	a1,0
    80003bac:	854a                	mv	a0,s2
    80003bae:	00000097          	auipc	ra,0x0
    80003bb2:	d78080e7          	jalr	-648(ra) # 80003926 <readi>
    80003bb6:	47c1                	li	a5,16
    80003bb8:	fcf518e3          	bne	a0,a5,80003b88 <dirlookup+0x3a>
    if(de.inum == 0)
    80003bbc:	fc045783          	lhu	a5,-64(s0)
    80003bc0:	dfe1                	beqz	a5,80003b98 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003bc2:	fc240593          	addi	a1,s0,-62
    80003bc6:	854e                	mv	a0,s3
    80003bc8:	00000097          	auipc	ra,0x0
    80003bcc:	f6c080e7          	jalr	-148(ra) # 80003b34 <namecmp>
    80003bd0:	f561                	bnez	a0,80003b98 <dirlookup+0x4a>
      if(poff)
    80003bd2:	000a0463          	beqz	s4,80003bda <dirlookup+0x8c>
        *poff = off;
    80003bd6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bda:	fc045583          	lhu	a1,-64(s0)
    80003bde:	00092503          	lw	a0,0(s2)
    80003be2:	fffff097          	auipc	ra,0xfffff
    80003be6:	780080e7          	jalr	1920(ra) # 80003362 <iget>
    80003bea:	a011                	j	80003bee <dirlookup+0xa0>
  return 0;
    80003bec:	4501                	li	a0,0
}
    80003bee:	70e2                	ld	ra,56(sp)
    80003bf0:	7442                	ld	s0,48(sp)
    80003bf2:	74a2                	ld	s1,40(sp)
    80003bf4:	7902                	ld	s2,32(sp)
    80003bf6:	69e2                	ld	s3,24(sp)
    80003bf8:	6a42                	ld	s4,16(sp)
    80003bfa:	6121                	addi	sp,sp,64
    80003bfc:	8082                	ret

0000000080003bfe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003bfe:	711d                	addi	sp,sp,-96
    80003c00:	ec86                	sd	ra,88(sp)
    80003c02:	e8a2                	sd	s0,80(sp)
    80003c04:	e4a6                	sd	s1,72(sp)
    80003c06:	e0ca                	sd	s2,64(sp)
    80003c08:	fc4e                	sd	s3,56(sp)
    80003c0a:	f852                	sd	s4,48(sp)
    80003c0c:	f456                	sd	s5,40(sp)
    80003c0e:	f05a                	sd	s6,32(sp)
    80003c10:	ec5e                	sd	s7,24(sp)
    80003c12:	e862                	sd	s8,16(sp)
    80003c14:	e466                	sd	s9,8(sp)
    80003c16:	1080                	addi	s0,sp,96
    80003c18:	84aa                	mv	s1,a0
    80003c1a:	8aae                	mv	s5,a1
    80003c1c:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c1e:	00054703          	lbu	a4,0(a0)
    80003c22:	02f00793          	li	a5,47
    80003c26:	02f70363          	beq	a4,a5,80003c4c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c2a:	ffffe097          	auipc	ra,0xffffe
    80003c2e:	e00080e7          	jalr	-512(ra) # 80001a2a <myproc>
    80003c32:	15853503          	ld	a0,344(a0)
    80003c36:	00000097          	auipc	ra,0x0
    80003c3a:	a22080e7          	jalr	-1502(ra) # 80003658 <idup>
    80003c3e:	89aa                	mv	s3,a0
  while(*path == '/')
    80003c40:	02f00913          	li	s2,47
  len = path - s;
    80003c44:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003c46:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c48:	4b85                	li	s7,1
    80003c4a:	a865                	j	80003d02 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003c4c:	4585                	li	a1,1
    80003c4e:	4501                	li	a0,0
    80003c50:	fffff097          	auipc	ra,0xfffff
    80003c54:	712080e7          	jalr	1810(ra) # 80003362 <iget>
    80003c58:	89aa                	mv	s3,a0
    80003c5a:	b7dd                	j	80003c40 <namex+0x42>
      iunlockput(ip);
    80003c5c:	854e                	mv	a0,s3
    80003c5e:	00000097          	auipc	ra,0x0
    80003c62:	c76080e7          	jalr	-906(ra) # 800038d4 <iunlockput>
      return 0;
    80003c66:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c68:	854e                	mv	a0,s3
    80003c6a:	60e6                	ld	ra,88(sp)
    80003c6c:	6446                	ld	s0,80(sp)
    80003c6e:	64a6                	ld	s1,72(sp)
    80003c70:	6906                	ld	s2,64(sp)
    80003c72:	79e2                	ld	s3,56(sp)
    80003c74:	7a42                	ld	s4,48(sp)
    80003c76:	7aa2                	ld	s5,40(sp)
    80003c78:	7b02                	ld	s6,32(sp)
    80003c7a:	6be2                	ld	s7,24(sp)
    80003c7c:	6c42                	ld	s8,16(sp)
    80003c7e:	6ca2                	ld	s9,8(sp)
    80003c80:	6125                	addi	sp,sp,96
    80003c82:	8082                	ret
      iunlock(ip);
    80003c84:	854e                	mv	a0,s3
    80003c86:	00000097          	auipc	ra,0x0
    80003c8a:	ad2080e7          	jalr	-1326(ra) # 80003758 <iunlock>
      return ip;
    80003c8e:	bfe9                	j	80003c68 <namex+0x6a>
      iunlockput(ip);
    80003c90:	854e                	mv	a0,s3
    80003c92:	00000097          	auipc	ra,0x0
    80003c96:	c42080e7          	jalr	-958(ra) # 800038d4 <iunlockput>
      return 0;
    80003c9a:	89e6                	mv	s3,s9
    80003c9c:	b7f1                	j	80003c68 <namex+0x6a>
  len = path - s;
    80003c9e:	40b48633          	sub	a2,s1,a1
    80003ca2:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003ca6:	099c5463          	bge	s8,s9,80003d2e <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003caa:	4639                	li	a2,14
    80003cac:	8552                	mv	a0,s4
    80003cae:	ffffd097          	auipc	ra,0xffffd
    80003cb2:	f30080e7          	jalr	-208(ra) # 80000bde <memmove>
  while(*path == '/')
    80003cb6:	0004c783          	lbu	a5,0(s1)
    80003cba:	01279763          	bne	a5,s2,80003cc8 <namex+0xca>
    path++;
    80003cbe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cc0:	0004c783          	lbu	a5,0(s1)
    80003cc4:	ff278de3          	beq	a5,s2,80003cbe <namex+0xc0>
    ilock(ip);
    80003cc8:	854e                	mv	a0,s3
    80003cca:	00000097          	auipc	ra,0x0
    80003cce:	9cc080e7          	jalr	-1588(ra) # 80003696 <ilock>
    if(ip->type != T_DIR){
    80003cd2:	04499783          	lh	a5,68(s3)
    80003cd6:	f97793e3          	bne	a5,s7,80003c5c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003cda:	000a8563          	beqz	s5,80003ce4 <namex+0xe6>
    80003cde:	0004c783          	lbu	a5,0(s1)
    80003ce2:	d3cd                	beqz	a5,80003c84 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ce4:	865a                	mv	a2,s6
    80003ce6:	85d2                	mv	a1,s4
    80003ce8:	854e                	mv	a0,s3
    80003cea:	00000097          	auipc	ra,0x0
    80003cee:	e64080e7          	jalr	-412(ra) # 80003b4e <dirlookup>
    80003cf2:	8caa                	mv	s9,a0
    80003cf4:	dd51                	beqz	a0,80003c90 <namex+0x92>
    iunlockput(ip);
    80003cf6:	854e                	mv	a0,s3
    80003cf8:	00000097          	auipc	ra,0x0
    80003cfc:	bdc080e7          	jalr	-1060(ra) # 800038d4 <iunlockput>
    ip = next;
    80003d00:	89e6                	mv	s3,s9
  while(*path == '/')
    80003d02:	0004c783          	lbu	a5,0(s1)
    80003d06:	05279763          	bne	a5,s2,80003d54 <namex+0x156>
    path++;
    80003d0a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d0c:	0004c783          	lbu	a5,0(s1)
    80003d10:	ff278de3          	beq	a5,s2,80003d0a <namex+0x10c>
  if(*path == 0)
    80003d14:	c79d                	beqz	a5,80003d42 <namex+0x144>
    path++;
    80003d16:	85a6                	mv	a1,s1
  len = path - s;
    80003d18:	8cda                	mv	s9,s6
    80003d1a:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003d1c:	01278963          	beq	a5,s2,80003d2e <namex+0x130>
    80003d20:	dfbd                	beqz	a5,80003c9e <namex+0xa0>
    path++;
    80003d22:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003d24:	0004c783          	lbu	a5,0(s1)
    80003d28:	ff279ce3          	bne	a5,s2,80003d20 <namex+0x122>
    80003d2c:	bf8d                	j	80003c9e <namex+0xa0>
    memmove(name, s, len);
    80003d2e:	2601                	sext.w	a2,a2
    80003d30:	8552                	mv	a0,s4
    80003d32:	ffffd097          	auipc	ra,0xffffd
    80003d36:	eac080e7          	jalr	-340(ra) # 80000bde <memmove>
    name[len] = 0;
    80003d3a:	9cd2                	add	s9,s9,s4
    80003d3c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d40:	bf9d                	j	80003cb6 <namex+0xb8>
  if(nameiparent){
    80003d42:	f20a83e3          	beqz	s5,80003c68 <namex+0x6a>
    iput(ip);
    80003d46:	854e                	mv	a0,s3
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	a5c080e7          	jalr	-1444(ra) # 800037a4 <iput>
    return 0;
    80003d50:	4981                	li	s3,0
    80003d52:	bf19                	j	80003c68 <namex+0x6a>
  if(*path == 0)
    80003d54:	d7fd                	beqz	a5,80003d42 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003d56:	0004c783          	lbu	a5,0(s1)
    80003d5a:	85a6                	mv	a1,s1
    80003d5c:	b7d1                	j	80003d20 <namex+0x122>

0000000080003d5e <dirlink>:
{
    80003d5e:	7139                	addi	sp,sp,-64
    80003d60:	fc06                	sd	ra,56(sp)
    80003d62:	f822                	sd	s0,48(sp)
    80003d64:	f426                	sd	s1,40(sp)
    80003d66:	f04a                	sd	s2,32(sp)
    80003d68:	ec4e                	sd	s3,24(sp)
    80003d6a:	e852                	sd	s4,16(sp)
    80003d6c:	0080                	addi	s0,sp,64
    80003d6e:	892a                	mv	s2,a0
    80003d70:	8a2e                	mv	s4,a1
    80003d72:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d74:	4601                	li	a2,0
    80003d76:	00000097          	auipc	ra,0x0
    80003d7a:	dd8080e7          	jalr	-552(ra) # 80003b4e <dirlookup>
    80003d7e:	e93d                	bnez	a0,80003df4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d80:	04c92483          	lw	s1,76(s2)
    80003d84:	c49d                	beqz	s1,80003db2 <dirlink+0x54>
    80003d86:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d88:	4741                	li	a4,16
    80003d8a:	86a6                	mv	a3,s1
    80003d8c:	fc040613          	addi	a2,s0,-64
    80003d90:	4581                	li	a1,0
    80003d92:	854a                	mv	a0,s2
    80003d94:	00000097          	auipc	ra,0x0
    80003d98:	b92080e7          	jalr	-1134(ra) # 80003926 <readi>
    80003d9c:	47c1                	li	a5,16
    80003d9e:	06f51163          	bne	a0,a5,80003e00 <dirlink+0xa2>
    if(de.inum == 0)
    80003da2:	fc045783          	lhu	a5,-64(s0)
    80003da6:	c791                	beqz	a5,80003db2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da8:	24c1                	addiw	s1,s1,16
    80003daa:	04c92783          	lw	a5,76(s2)
    80003dae:	fcf4ede3          	bltu	s1,a5,80003d88 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003db2:	4639                	li	a2,14
    80003db4:	85d2                	mv	a1,s4
    80003db6:	fc240513          	addi	a0,s0,-62
    80003dba:	ffffd097          	auipc	ra,0xffffd
    80003dbe:	edc080e7          	jalr	-292(ra) # 80000c96 <strncpy>
  de.inum = inum;
    80003dc2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dc6:	4741                	li	a4,16
    80003dc8:	86a6                	mv	a3,s1
    80003dca:	fc040613          	addi	a2,s0,-64
    80003dce:	4581                	li	a1,0
    80003dd0:	854a                	mv	a0,s2
    80003dd2:	00000097          	auipc	ra,0x0
    80003dd6:	c48080e7          	jalr	-952(ra) # 80003a1a <writei>
    80003dda:	872a                	mv	a4,a0
    80003ddc:	47c1                	li	a5,16
  return 0;
    80003dde:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003de0:	02f71863          	bne	a4,a5,80003e10 <dirlink+0xb2>
}
    80003de4:	70e2                	ld	ra,56(sp)
    80003de6:	7442                	ld	s0,48(sp)
    80003de8:	74a2                	ld	s1,40(sp)
    80003dea:	7902                	ld	s2,32(sp)
    80003dec:	69e2                	ld	s3,24(sp)
    80003dee:	6a42                	ld	s4,16(sp)
    80003df0:	6121                	addi	sp,sp,64
    80003df2:	8082                	ret
    iput(ip);
    80003df4:	00000097          	auipc	ra,0x0
    80003df8:	9b0080e7          	jalr	-1616(ra) # 800037a4 <iput>
    return -1;
    80003dfc:	557d                	li	a0,-1
    80003dfe:	b7dd                	j	80003de4 <dirlink+0x86>
      panic("dirlink read");
    80003e00:	00005517          	auipc	a0,0x5
    80003e04:	82850513          	addi	a0,a0,-2008 # 80008628 <userret+0x598>
    80003e08:	ffffc097          	auipc	ra,0xffffc
    80003e0c:	740080e7          	jalr	1856(ra) # 80000548 <panic>
    panic("dirlink");
    80003e10:	00005517          	auipc	a0,0x5
    80003e14:	9c850513          	addi	a0,a0,-1592 # 800087d8 <userret+0x748>
    80003e18:	ffffc097          	auipc	ra,0xffffc
    80003e1c:	730080e7          	jalr	1840(ra) # 80000548 <panic>

0000000080003e20 <namei>:

struct inode*
namei(char *path)
{
    80003e20:	1101                	addi	sp,sp,-32
    80003e22:	ec06                	sd	ra,24(sp)
    80003e24:	e822                	sd	s0,16(sp)
    80003e26:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e28:	fe040613          	addi	a2,s0,-32
    80003e2c:	4581                	li	a1,0
    80003e2e:	00000097          	auipc	ra,0x0
    80003e32:	dd0080e7          	jalr	-560(ra) # 80003bfe <namex>
}
    80003e36:	60e2                	ld	ra,24(sp)
    80003e38:	6442                	ld	s0,16(sp)
    80003e3a:	6105                	addi	sp,sp,32
    80003e3c:	8082                	ret

0000000080003e3e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e3e:	1141                	addi	sp,sp,-16
    80003e40:	e406                	sd	ra,8(sp)
    80003e42:	e022                	sd	s0,0(sp)
    80003e44:	0800                	addi	s0,sp,16
    80003e46:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e48:	4585                	li	a1,1
    80003e4a:	00000097          	auipc	ra,0x0
    80003e4e:	db4080e7          	jalr	-588(ra) # 80003bfe <namex>
}
    80003e52:	60a2                	ld	ra,8(sp)
    80003e54:	6402                	ld	s0,0(sp)
    80003e56:	0141                	addi	sp,sp,16
    80003e58:	8082                	ret

0000000080003e5a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80003e5a:	7179                	addi	sp,sp,-48
    80003e5c:	f406                	sd	ra,40(sp)
    80003e5e:	f022                	sd	s0,32(sp)
    80003e60:	ec26                	sd	s1,24(sp)
    80003e62:	e84a                	sd	s2,16(sp)
    80003e64:	e44e                	sd	s3,8(sp)
    80003e66:	1800                	addi	s0,sp,48
    80003e68:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80003e6a:	0a800993          	li	s3,168
    80003e6e:	033507b3          	mul	a5,a0,s3
    80003e72:	0001f997          	auipc	s3,0x1f
    80003e76:	d2698993          	addi	s3,s3,-730 # 80022b98 <log>
    80003e7a:	99be                	add	s3,s3,a5
    80003e7c:	0189a583          	lw	a1,24(s3)
    80003e80:	fffff097          	auipc	ra,0xfffff
    80003e84:	010080e7          	jalr	16(ra) # 80002e90 <bread>
    80003e88:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80003e8a:	02c9a783          	lw	a5,44(s3)
    80003e8e:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003e90:	02c9a783          	lw	a5,44(s3)
    80003e94:	02f05763          	blez	a5,80003ec2 <write_head+0x68>
    80003e98:	0a800793          	li	a5,168
    80003e9c:	02f487b3          	mul	a5,s1,a5
    80003ea0:	0001f717          	auipc	a4,0x1f
    80003ea4:	d2870713          	addi	a4,a4,-728 # 80022bc8 <log+0x30>
    80003ea8:	97ba                	add	a5,a5,a4
    80003eaa:	06450693          	addi	a3,a0,100
    80003eae:	4701                	li	a4,0
    80003eb0:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80003eb2:	4390                	lw	a2,0(a5)
    80003eb4:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003eb6:	2705                	addiw	a4,a4,1
    80003eb8:	0791                	addi	a5,a5,4
    80003eba:	0691                	addi	a3,a3,4
    80003ebc:	55d0                	lw	a2,44(a1)
    80003ebe:	fec74ae3          	blt	a4,a2,80003eb2 <write_head+0x58>
  }
  bwrite(buf);
    80003ec2:	854a                	mv	a0,s2
    80003ec4:	fffff097          	auipc	ra,0xfffff
    80003ec8:	0c0080e7          	jalr	192(ra) # 80002f84 <bwrite>
  brelse(buf);
    80003ecc:	854a                	mv	a0,s2
    80003ece:	fffff097          	auipc	ra,0xfffff
    80003ed2:	0f6080e7          	jalr	246(ra) # 80002fc4 <brelse>
}
    80003ed6:	70a2                	ld	ra,40(sp)
    80003ed8:	7402                	ld	s0,32(sp)
    80003eda:	64e2                	ld	s1,24(sp)
    80003edc:	6942                	ld	s2,16(sp)
    80003ede:	69a2                	ld	s3,8(sp)
    80003ee0:	6145                	addi	sp,sp,48
    80003ee2:	8082                	ret

0000000080003ee4 <write_log>:
static void
write_log(int dev)
{
  int tail;

  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003ee4:	0a800793          	li	a5,168
    80003ee8:	02f50733          	mul	a4,a0,a5
    80003eec:	0001f797          	auipc	a5,0x1f
    80003ef0:	cac78793          	addi	a5,a5,-852 # 80022b98 <log>
    80003ef4:	97ba                	add	a5,a5,a4
    80003ef6:	57dc                	lw	a5,44(a5)
    80003ef8:	0af05663          	blez	a5,80003fa4 <write_log+0xc0>
{
    80003efc:	7139                	addi	sp,sp,-64
    80003efe:	fc06                	sd	ra,56(sp)
    80003f00:	f822                	sd	s0,48(sp)
    80003f02:	f426                	sd	s1,40(sp)
    80003f04:	f04a                	sd	s2,32(sp)
    80003f06:	ec4e                	sd	s3,24(sp)
    80003f08:	e852                	sd	s4,16(sp)
    80003f0a:	e456                	sd	s5,8(sp)
    80003f0c:	e05a                	sd	s6,0(sp)
    80003f0e:	0080                	addi	s0,sp,64
    80003f10:	0001f797          	auipc	a5,0x1f
    80003f14:	cb878793          	addi	a5,a5,-840 # 80022bc8 <log+0x30>
    80003f18:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003f1c:	4981                	li	s3,0
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80003f1e:	00050b1b          	sext.w	s6,a0
    80003f22:	0001fa97          	auipc	s5,0x1f
    80003f26:	c76a8a93          	addi	s5,s5,-906 # 80022b98 <log>
    80003f2a:	9aba                	add	s5,s5,a4
    80003f2c:	018aa583          	lw	a1,24(s5)
    80003f30:	013585bb          	addw	a1,a1,s3
    80003f34:	2585                	addiw	a1,a1,1
    80003f36:	855a                	mv	a0,s6
    80003f38:	fffff097          	auipc	ra,0xfffff
    80003f3c:	f58080e7          	jalr	-168(ra) # 80002e90 <bread>
    80003f40:	84aa                	mv	s1,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    80003f42:	000a2583          	lw	a1,0(s4)
    80003f46:	855a                	mv	a0,s6
    80003f48:	fffff097          	auipc	ra,0xfffff
    80003f4c:	f48080e7          	jalr	-184(ra) # 80002e90 <bread>
    80003f50:	892a                	mv	s2,a0
    memmove(to->data, from->data, BSIZE);
    80003f52:	40000613          	li	a2,1024
    80003f56:	06050593          	addi	a1,a0,96
    80003f5a:	06048513          	addi	a0,s1,96
    80003f5e:	ffffd097          	auipc	ra,0xffffd
    80003f62:	c80080e7          	jalr	-896(ra) # 80000bde <memmove>
    bwrite(to);  // write the log
    80003f66:	8526                	mv	a0,s1
    80003f68:	fffff097          	auipc	ra,0xfffff
    80003f6c:	01c080e7          	jalr	28(ra) # 80002f84 <bwrite>
    brelse(from);
    80003f70:	854a                	mv	a0,s2
    80003f72:	fffff097          	auipc	ra,0xfffff
    80003f76:	052080e7          	jalr	82(ra) # 80002fc4 <brelse>
    brelse(to);
    80003f7a:	8526                	mv	a0,s1
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	048080e7          	jalr	72(ra) # 80002fc4 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003f84:	2985                	addiw	s3,s3,1
    80003f86:	0a11                	addi	s4,s4,4
    80003f88:	02caa783          	lw	a5,44(s5)
    80003f8c:	faf9c0e3          	blt	s3,a5,80003f2c <write_log+0x48>
  }
}
    80003f90:	70e2                	ld	ra,56(sp)
    80003f92:	7442                	ld	s0,48(sp)
    80003f94:	74a2                	ld	s1,40(sp)
    80003f96:	7902                	ld	s2,32(sp)
    80003f98:	69e2                	ld	s3,24(sp)
    80003f9a:	6a42                	ld	s4,16(sp)
    80003f9c:	6aa2                	ld	s5,8(sp)
    80003f9e:	6b02                	ld	s6,0(sp)
    80003fa0:	6121                	addi	sp,sp,64
    80003fa2:	8082                	ret
    80003fa4:	8082                	ret

0000000080003fa6 <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003fa6:	0a800793          	li	a5,168
    80003faa:	02f50733          	mul	a4,a0,a5
    80003fae:	0001f797          	auipc	a5,0x1f
    80003fb2:	bea78793          	addi	a5,a5,-1046 # 80022b98 <log>
    80003fb6:	97ba                	add	a5,a5,a4
    80003fb8:	57dc                	lw	a5,44(a5)
    80003fba:	0af05b63          	blez	a5,80004070 <install_trans+0xca>
{
    80003fbe:	7139                	addi	sp,sp,-64
    80003fc0:	fc06                	sd	ra,56(sp)
    80003fc2:	f822                	sd	s0,48(sp)
    80003fc4:	f426                	sd	s1,40(sp)
    80003fc6:	f04a                	sd	s2,32(sp)
    80003fc8:	ec4e                	sd	s3,24(sp)
    80003fca:	e852                	sd	s4,16(sp)
    80003fcc:	e456                	sd	s5,8(sp)
    80003fce:	e05a                	sd	s6,0(sp)
    80003fd0:	0080                	addi	s0,sp,64
    80003fd2:	0001f797          	auipc	a5,0x1f
    80003fd6:	bf678793          	addi	a5,a5,-1034 # 80022bc8 <log+0x30>
    80003fda:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003fde:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80003fe0:	00050b1b          	sext.w	s6,a0
    80003fe4:	0001fa97          	auipc	s5,0x1f
    80003fe8:	bb4a8a93          	addi	s5,s5,-1100 # 80022b98 <log>
    80003fec:	9aba                	add	s5,s5,a4
    80003fee:	018aa583          	lw	a1,24(s5)
    80003ff2:	013585bb          	addw	a1,a1,s3
    80003ff6:	2585                	addiw	a1,a1,1
    80003ff8:	855a                	mv	a0,s6
    80003ffa:	fffff097          	auipc	ra,0xfffff
    80003ffe:	e96080e7          	jalr	-362(ra) # 80002e90 <bread>
    80004002:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80004004:	000a2583          	lw	a1,0(s4)
    80004008:	855a                	mv	a0,s6
    8000400a:	fffff097          	auipc	ra,0xfffff
    8000400e:	e86080e7          	jalr	-378(ra) # 80002e90 <bread>
    80004012:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004014:	40000613          	li	a2,1024
    80004018:	06090593          	addi	a1,s2,96
    8000401c:	06050513          	addi	a0,a0,96
    80004020:	ffffd097          	auipc	ra,0xffffd
    80004024:	bbe080e7          	jalr	-1090(ra) # 80000bde <memmove>
    bwrite(dbuf);  // write dst to disk
    80004028:	8526                	mv	a0,s1
    8000402a:	fffff097          	auipc	ra,0xfffff
    8000402e:	f5a080e7          	jalr	-166(ra) # 80002f84 <bwrite>
    bunpin(dbuf);
    80004032:	8526                	mv	a0,s1
    80004034:	fffff097          	auipc	ra,0xfffff
    80004038:	06a080e7          	jalr	106(ra) # 8000309e <bunpin>
    brelse(lbuf);
    8000403c:	854a                	mv	a0,s2
    8000403e:	fffff097          	auipc	ra,0xfffff
    80004042:	f86080e7          	jalr	-122(ra) # 80002fc4 <brelse>
    brelse(dbuf);
    80004046:	8526                	mv	a0,s1
    80004048:	fffff097          	auipc	ra,0xfffff
    8000404c:	f7c080e7          	jalr	-132(ra) # 80002fc4 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004050:	2985                	addiw	s3,s3,1
    80004052:	0a11                	addi	s4,s4,4
    80004054:	02caa783          	lw	a5,44(s5)
    80004058:	f8f9cbe3          	blt	s3,a5,80003fee <install_trans+0x48>
}
    8000405c:	70e2                	ld	ra,56(sp)
    8000405e:	7442                	ld	s0,48(sp)
    80004060:	74a2                	ld	s1,40(sp)
    80004062:	7902                	ld	s2,32(sp)
    80004064:	69e2                	ld	s3,24(sp)
    80004066:	6a42                	ld	s4,16(sp)
    80004068:	6aa2                	ld	s5,8(sp)
    8000406a:	6b02                	ld	s6,0(sp)
    8000406c:	6121                	addi	sp,sp,64
    8000406e:	8082                	ret
    80004070:	8082                	ret

0000000080004072 <initlog>:
{
    80004072:	7179                	addi	sp,sp,-48
    80004074:	f406                	sd	ra,40(sp)
    80004076:	f022                	sd	s0,32(sp)
    80004078:	ec26                	sd	s1,24(sp)
    8000407a:	e84a                	sd	s2,16(sp)
    8000407c:	e44e                	sd	s3,8(sp)
    8000407e:	e052                	sd	s4,0(sp)
    80004080:	1800                	addi	s0,sp,48
    80004082:	892a                	mv	s2,a0
    80004084:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80004086:	0a800713          	li	a4,168
    8000408a:	02e504b3          	mul	s1,a0,a4
    8000408e:	0001f997          	auipc	s3,0x1f
    80004092:	b0a98993          	addi	s3,s3,-1270 # 80022b98 <log>
    80004096:	99a6                	add	s3,s3,s1
    80004098:	00004597          	auipc	a1,0x4
    8000409c:	5a058593          	addi	a1,a1,1440 # 80008638 <userret+0x5a8>
    800040a0:	854e                	mv	a0,s3
    800040a2:	ffffd097          	auipc	ra,0xffffd
    800040a6:	90e080e7          	jalr	-1778(ra) # 800009b0 <initlock>
  log[dev].start = sb->logstart;
    800040aa:	014a2583          	lw	a1,20(s4)
    800040ae:	00b9ac23          	sw	a1,24(s3)
  log[dev].size = sb->nlog;
    800040b2:	010a2783          	lw	a5,16(s4)
    800040b6:	00f9ae23          	sw	a5,28(s3)
  log[dev].dev = dev;
    800040ba:	0329a423          	sw	s2,40(s3)
  struct buf *buf = bread(dev, log[dev].start);
    800040be:	854a                	mv	a0,s2
    800040c0:	fffff097          	auipc	ra,0xfffff
    800040c4:	dd0080e7          	jalr	-560(ra) # 80002e90 <bread>
  log[dev].lh.n = lh->n;
    800040c8:	5134                	lw	a3,96(a0)
    800040ca:	02d9a623          	sw	a3,44(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    800040ce:	02d05663          	blez	a3,800040fa <initlog+0x88>
    800040d2:	06450793          	addi	a5,a0,100
    800040d6:	0001f717          	auipc	a4,0x1f
    800040da:	af270713          	addi	a4,a4,-1294 # 80022bc8 <log+0x30>
    800040de:	9726                	add	a4,a4,s1
    800040e0:	36fd                	addiw	a3,a3,-1
    800040e2:	1682                	slli	a3,a3,0x20
    800040e4:	9281                	srli	a3,a3,0x20
    800040e6:	068a                	slli	a3,a3,0x2
    800040e8:	06850613          	addi	a2,a0,104
    800040ec:	96b2                	add	a3,a3,a2
    log[dev].lh.block[i] = lh->block[i];
    800040ee:	4390                	lw	a2,0(a5)
    800040f0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    800040f2:	0791                	addi	a5,a5,4
    800040f4:	0711                	addi	a4,a4,4
    800040f6:	fed79ce3          	bne	a5,a3,800040ee <initlog+0x7c>
  brelse(buf);
    800040fa:	fffff097          	auipc	ra,0xfffff
    800040fe:	eca080e7          	jalr	-310(ra) # 80002fc4 <brelse>
  install_trans(dev); // if committed, copy from log to disk
    80004102:	854a                	mv	a0,s2
    80004104:	00000097          	auipc	ra,0x0
    80004108:	ea2080e7          	jalr	-350(ra) # 80003fa6 <install_trans>
  log[dev].lh.n = 0;
    8000410c:	0a800793          	li	a5,168
    80004110:	02f90733          	mul	a4,s2,a5
    80004114:	0001f797          	auipc	a5,0x1f
    80004118:	a8478793          	addi	a5,a5,-1404 # 80022b98 <log>
    8000411c:	97ba                	add	a5,a5,a4
    8000411e:	0207a623          	sw	zero,44(a5)
  write_head(dev); // clear the log
    80004122:	854a                	mv	a0,s2
    80004124:	00000097          	auipc	ra,0x0
    80004128:	d36080e7          	jalr	-714(ra) # 80003e5a <write_head>
}
    8000412c:	70a2                	ld	ra,40(sp)
    8000412e:	7402                	ld	s0,32(sp)
    80004130:	64e2                	ld	s1,24(sp)
    80004132:	6942                	ld	s2,16(sp)
    80004134:	69a2                	ld	s3,8(sp)
    80004136:	6a02                	ld	s4,0(sp)
    80004138:	6145                	addi	sp,sp,48
    8000413a:	8082                	ret

000000008000413c <begin_op>:
{
    8000413c:	7139                	addi	sp,sp,-64
    8000413e:	fc06                	sd	ra,56(sp)
    80004140:	f822                	sd	s0,48(sp)
    80004142:	f426                	sd	s1,40(sp)
    80004144:	f04a                	sd	s2,32(sp)
    80004146:	ec4e                	sd	s3,24(sp)
    80004148:	e852                	sd	s4,16(sp)
    8000414a:	e456                	sd	s5,8(sp)
    8000414c:	0080                	addi	s0,sp,64
    8000414e:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    80004150:	0a800913          	li	s2,168
    80004154:	032507b3          	mul	a5,a0,s2
    80004158:	0001f917          	auipc	s2,0x1f
    8000415c:	a4090913          	addi	s2,s2,-1472 # 80022b98 <log>
    80004160:	993e                	add	s2,s2,a5
    80004162:	854a                	mv	a0,s2
    80004164:	ffffd097          	auipc	ra,0xffffd
    80004168:	95a080e7          	jalr	-1702(ra) # 80000abe <acquire>
    if(log[dev].committing){
    8000416c:	0001f997          	auipc	s3,0x1f
    80004170:	a2c98993          	addi	s3,s3,-1492 # 80022b98 <log>
    80004174:	84ca                	mv	s1,s2
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004176:	4a79                	li	s4,30
    80004178:	a039                	j	80004186 <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    8000417a:	85ca                	mv	a1,s2
    8000417c:	854e                	mv	a0,s3
    8000417e:	ffffe097          	auipc	ra,0xffffe
    80004182:	08a080e7          	jalr	138(ra) # 80002208 <sleep>
    if(log[dev].committing){
    80004186:	50dc                	lw	a5,36(s1)
    80004188:	fbed                	bnez	a5,8000417a <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000418a:	509c                	lw	a5,32(s1)
    8000418c:	0017871b          	addiw	a4,a5,1
    80004190:	0007069b          	sext.w	a3,a4
    80004194:	0027179b          	slliw	a5,a4,0x2
    80004198:	9fb9                	addw	a5,a5,a4
    8000419a:	0017979b          	slliw	a5,a5,0x1
    8000419e:	54d8                	lw	a4,44(s1)
    800041a0:	9fb9                	addw	a5,a5,a4
    800041a2:	00fa5963          	bge	s4,a5,800041b4 <begin_op+0x78>
      sleep(&log, &log[dev].lock);
    800041a6:	85ca                	mv	a1,s2
    800041a8:	854e                	mv	a0,s3
    800041aa:	ffffe097          	auipc	ra,0xffffe
    800041ae:	05e080e7          	jalr	94(ra) # 80002208 <sleep>
    800041b2:	bfd1                	j	80004186 <begin_op+0x4a>
      log[dev].outstanding += 1;
    800041b4:	0a800513          	li	a0,168
    800041b8:	02aa8ab3          	mul	s5,s5,a0
    800041bc:	0001f797          	auipc	a5,0x1f
    800041c0:	9dc78793          	addi	a5,a5,-1572 # 80022b98 <log>
    800041c4:	9abe                	add	s5,s5,a5
    800041c6:	02daa023          	sw	a3,32(s5)
      release(&log[dev].lock);
    800041ca:	854a                	mv	a0,s2
    800041cc:	ffffd097          	auipc	ra,0xffffd
    800041d0:	95a080e7          	jalr	-1702(ra) # 80000b26 <release>
}
    800041d4:	70e2                	ld	ra,56(sp)
    800041d6:	7442                	ld	s0,48(sp)
    800041d8:	74a2                	ld	s1,40(sp)
    800041da:	7902                	ld	s2,32(sp)
    800041dc:	69e2                	ld	s3,24(sp)
    800041de:	6a42                	ld	s4,16(sp)
    800041e0:	6aa2                	ld	s5,8(sp)
    800041e2:	6121                	addi	sp,sp,64
    800041e4:	8082                	ret

00000000800041e6 <end_op>:
{
    800041e6:	7179                	addi	sp,sp,-48
    800041e8:	f406                	sd	ra,40(sp)
    800041ea:	f022                	sd	s0,32(sp)
    800041ec:	ec26                	sd	s1,24(sp)
    800041ee:	e84a                	sd	s2,16(sp)
    800041f0:	e44e                	sd	s3,8(sp)
    800041f2:	1800                	addi	s0,sp,48
    800041f4:	892a                	mv	s2,a0
  acquire(&log[dev].lock);
    800041f6:	0a800493          	li	s1,168
    800041fa:	029507b3          	mul	a5,a0,s1
    800041fe:	0001f497          	auipc	s1,0x1f
    80004202:	99a48493          	addi	s1,s1,-1638 # 80022b98 <log>
    80004206:	94be                	add	s1,s1,a5
    80004208:	8526                	mv	a0,s1
    8000420a:	ffffd097          	auipc	ra,0xffffd
    8000420e:	8b4080e7          	jalr	-1868(ra) # 80000abe <acquire>
  log[dev].outstanding -= 1;
    80004212:	509c                	lw	a5,32(s1)
    80004214:	37fd                	addiw	a5,a5,-1
    80004216:	0007871b          	sext.w	a4,a5
    8000421a:	d09c                	sw	a5,32(s1)
  if(log[dev].committing)
    8000421c:	50dc                	lw	a5,36(s1)
    8000421e:	e3ad                	bnez	a5,80004280 <end_op+0x9a>
  if(log[dev].outstanding == 0){
    80004220:	eb25                	bnez	a4,80004290 <end_op+0xaa>
    log[dev].committing = 1;
    80004222:	0a800993          	li	s3,168
    80004226:	033907b3          	mul	a5,s2,s3
    8000422a:	0001f997          	auipc	s3,0x1f
    8000422e:	96e98993          	addi	s3,s3,-1682 # 80022b98 <log>
    80004232:	99be                	add	s3,s3,a5
    80004234:	4785                	li	a5,1
    80004236:	02f9a223          	sw	a5,36(s3)
  release(&log[dev].lock);
    8000423a:	8526                	mv	a0,s1
    8000423c:	ffffd097          	auipc	ra,0xffffd
    80004240:	8ea080e7          	jalr	-1814(ra) # 80000b26 <release>

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    80004244:	02c9a783          	lw	a5,44(s3)
    80004248:	06f04863          	bgtz	a5,800042b8 <end_op+0xd2>
    acquire(&log[dev].lock);
    8000424c:	8526                	mv	a0,s1
    8000424e:	ffffd097          	auipc	ra,0xffffd
    80004252:	870080e7          	jalr	-1936(ra) # 80000abe <acquire>
    log[dev].committing = 0;
    80004256:	0001f517          	auipc	a0,0x1f
    8000425a:	94250513          	addi	a0,a0,-1726 # 80022b98 <log>
    8000425e:	0a800793          	li	a5,168
    80004262:	02f90933          	mul	s2,s2,a5
    80004266:	992a                	add	s2,s2,a0
    80004268:	02092223          	sw	zero,36(s2)
    wakeup(&log);
    8000426c:	ffffe097          	auipc	ra,0xffffe
    80004270:	11c080e7          	jalr	284(ra) # 80002388 <wakeup>
    release(&log[dev].lock);
    80004274:	8526                	mv	a0,s1
    80004276:	ffffd097          	auipc	ra,0xffffd
    8000427a:	8b0080e7          	jalr	-1872(ra) # 80000b26 <release>
}
    8000427e:	a035                	j	800042aa <end_op+0xc4>
    panic("log[dev].committing");
    80004280:	00004517          	auipc	a0,0x4
    80004284:	3c050513          	addi	a0,a0,960 # 80008640 <userret+0x5b0>
    80004288:	ffffc097          	auipc	ra,0xffffc
    8000428c:	2c0080e7          	jalr	704(ra) # 80000548 <panic>
    wakeup(&log);
    80004290:	0001f517          	auipc	a0,0x1f
    80004294:	90850513          	addi	a0,a0,-1784 # 80022b98 <log>
    80004298:	ffffe097          	auipc	ra,0xffffe
    8000429c:	0f0080e7          	jalr	240(ra) # 80002388 <wakeup>
  release(&log[dev].lock);
    800042a0:	8526                	mv	a0,s1
    800042a2:	ffffd097          	auipc	ra,0xffffd
    800042a6:	884080e7          	jalr	-1916(ra) # 80000b26 <release>
}
    800042aa:	70a2                	ld	ra,40(sp)
    800042ac:	7402                	ld	s0,32(sp)
    800042ae:	64e2                	ld	s1,24(sp)
    800042b0:	6942                	ld	s2,16(sp)
    800042b2:	69a2                	ld	s3,8(sp)
    800042b4:	6145                	addi	sp,sp,48
    800042b6:	8082                	ret
    write_log(dev);     // Write modified blocks from cache to log
    800042b8:	854a                	mv	a0,s2
    800042ba:	00000097          	auipc	ra,0x0
    800042be:	c2a080e7          	jalr	-982(ra) # 80003ee4 <write_log>
    write_head(dev);    // Write header to disk -- the real commit
    800042c2:	854a                	mv	a0,s2
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	b96080e7          	jalr	-1130(ra) # 80003e5a <write_head>
    install_trans(dev); // Now install writes to home locations
    800042cc:	854a                	mv	a0,s2
    800042ce:	00000097          	auipc	ra,0x0
    800042d2:	cd8080e7          	jalr	-808(ra) # 80003fa6 <install_trans>
    log[dev].lh.n = 0;
    800042d6:	0a800793          	li	a5,168
    800042da:	02f90733          	mul	a4,s2,a5
    800042de:	0001f797          	auipc	a5,0x1f
    800042e2:	8ba78793          	addi	a5,a5,-1862 # 80022b98 <log>
    800042e6:	97ba                	add	a5,a5,a4
    800042e8:	0207a623          	sw	zero,44(a5)
    write_head(dev);    // Erase the transaction from the log
    800042ec:	854a                	mv	a0,s2
    800042ee:	00000097          	auipc	ra,0x0
    800042f2:	b6c080e7          	jalr	-1172(ra) # 80003e5a <write_head>
    800042f6:	bf99                	j	8000424c <end_op+0x66>

00000000800042f8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042f8:	7179                	addi	sp,sp,-48
    800042fa:	f406                	sd	ra,40(sp)
    800042fc:	f022                	sd	s0,32(sp)
    800042fe:	ec26                	sd	s1,24(sp)
    80004300:	e84a                	sd	s2,16(sp)
    80004302:	e44e                	sd	s3,8(sp)
    80004304:	e052                	sd	s4,0(sp)
    80004306:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004308:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    8000430c:	0a800793          	li	a5,168
    80004310:	02f90733          	mul	a4,s2,a5
    80004314:	0001f797          	auipc	a5,0x1f
    80004318:	88478793          	addi	a5,a5,-1916 # 80022b98 <log>
    8000431c:	97ba                	add	a5,a5,a4
    8000431e:	57d4                	lw	a3,44(a5)
    80004320:	47f5                	li	a5,29
    80004322:	0ad7cc63          	blt	a5,a3,800043da <log_write+0xe2>
    80004326:	89aa                	mv	s3,a0
    80004328:	0001f797          	auipc	a5,0x1f
    8000432c:	87078793          	addi	a5,a5,-1936 # 80022b98 <log>
    80004330:	97ba                	add	a5,a5,a4
    80004332:	4fdc                	lw	a5,28(a5)
    80004334:	37fd                	addiw	a5,a5,-1
    80004336:	0af6d263          	bge	a3,a5,800043da <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    8000433a:	0a800793          	li	a5,168
    8000433e:	02f90733          	mul	a4,s2,a5
    80004342:	0001f797          	auipc	a5,0x1f
    80004346:	85678793          	addi	a5,a5,-1962 # 80022b98 <log>
    8000434a:	97ba                	add	a5,a5,a4
    8000434c:	539c                	lw	a5,32(a5)
    8000434e:	08f05e63          	blez	a5,800043ea <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    80004352:	0a800793          	li	a5,168
    80004356:	02f904b3          	mul	s1,s2,a5
    8000435a:	0001fa17          	auipc	s4,0x1f
    8000435e:	83ea0a13          	addi	s4,s4,-1986 # 80022b98 <log>
    80004362:	9a26                	add	s4,s4,s1
    80004364:	8552                	mv	a0,s4
    80004366:	ffffc097          	auipc	ra,0xffffc
    8000436a:	758080e7          	jalr	1880(ra) # 80000abe <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    8000436e:	02ca2603          	lw	a2,44(s4)
    80004372:	08c05463          	blez	a2,800043fa <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004376:	00c9a583          	lw	a1,12(s3)
    8000437a:	0001f797          	auipc	a5,0x1f
    8000437e:	84e78793          	addi	a5,a5,-1970 # 80022bc8 <log+0x30>
    80004382:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    80004384:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004386:	4394                	lw	a3,0(a5)
    80004388:	06b68a63          	beq	a3,a1,800043fc <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    8000438c:	2705                	addiw	a4,a4,1
    8000438e:	0791                	addi	a5,a5,4
    80004390:	fec71be3          	bne	a4,a2,80004386 <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    80004394:	02a00793          	li	a5,42
    80004398:	02f907b3          	mul	a5,s2,a5
    8000439c:	97b2                	add	a5,a5,a2
    8000439e:	07a1                	addi	a5,a5,8
    800043a0:	078a                	slli	a5,a5,0x2
    800043a2:	0001e717          	auipc	a4,0x1e
    800043a6:	7f670713          	addi	a4,a4,2038 # 80022b98 <log>
    800043aa:	97ba                	add	a5,a5,a4
    800043ac:	00c9a703          	lw	a4,12(s3)
    800043b0:	cb98                	sw	a4,16(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    800043b2:	854e                	mv	a0,s3
    800043b4:	fffff097          	auipc	ra,0xfffff
    800043b8:	cae080e7          	jalr	-850(ra) # 80003062 <bpin>
    log[dev].lh.n++;
    800043bc:	0a800793          	li	a5,168
    800043c0:	02f90933          	mul	s2,s2,a5
    800043c4:	0001e797          	auipc	a5,0x1e
    800043c8:	7d478793          	addi	a5,a5,2004 # 80022b98 <log>
    800043cc:	993e                	add	s2,s2,a5
    800043ce:	02c92783          	lw	a5,44(s2)
    800043d2:	2785                	addiw	a5,a5,1
    800043d4:	02f92623          	sw	a5,44(s2)
    800043d8:	a099                	j	8000441e <log_write+0x126>
    panic("too big a transaction");
    800043da:	00004517          	auipc	a0,0x4
    800043de:	27e50513          	addi	a0,a0,638 # 80008658 <userret+0x5c8>
    800043e2:	ffffc097          	auipc	ra,0xffffc
    800043e6:	166080e7          	jalr	358(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    800043ea:	00004517          	auipc	a0,0x4
    800043ee:	28650513          	addi	a0,a0,646 # 80008670 <userret+0x5e0>
    800043f2:	ffffc097          	auipc	ra,0xffffc
    800043f6:	156080e7          	jalr	342(ra) # 80000548 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    800043fa:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    800043fc:	02a00793          	li	a5,42
    80004400:	02f907b3          	mul	a5,s2,a5
    80004404:	97ba                	add	a5,a5,a4
    80004406:	07a1                	addi	a5,a5,8
    80004408:	078a                	slli	a5,a5,0x2
    8000440a:	0001e697          	auipc	a3,0x1e
    8000440e:	78e68693          	addi	a3,a3,1934 # 80022b98 <log>
    80004412:	97b6                	add	a5,a5,a3
    80004414:	00c9a683          	lw	a3,12(s3)
    80004418:	cb94                	sw	a3,16(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    8000441a:	f8e60ce3          	beq	a2,a4,800043b2 <log_write+0xba>
  }
  release(&log[dev].lock);
    8000441e:	8552                	mv	a0,s4
    80004420:	ffffc097          	auipc	ra,0xffffc
    80004424:	706080e7          	jalr	1798(ra) # 80000b26 <release>
}
    80004428:	70a2                	ld	ra,40(sp)
    8000442a:	7402                	ld	s0,32(sp)
    8000442c:	64e2                	ld	s1,24(sp)
    8000442e:	6942                	ld	s2,16(sp)
    80004430:	69a2                	ld	s3,8(sp)
    80004432:	6a02                	ld	s4,0(sp)
    80004434:	6145                	addi	sp,sp,48
    80004436:	8082                	ret

0000000080004438 <crash_op>:

// crash before commit or after commit
void
crash_op(int dev, int docommit)
{
    80004438:	7179                	addi	sp,sp,-48
    8000443a:	f406                	sd	ra,40(sp)
    8000443c:	f022                	sd	s0,32(sp)
    8000443e:	ec26                	sd	s1,24(sp)
    80004440:	e84a                	sd	s2,16(sp)
    80004442:	e44e                	sd	s3,8(sp)
    80004444:	1800                	addi	s0,sp,48
    80004446:	84aa                	mv	s1,a0
    80004448:	89ae                	mv	s3,a1
  int do_commit = 0;
    
  acquire(&log[dev].lock);
    8000444a:	0a800913          	li	s2,168
    8000444e:	032507b3          	mul	a5,a0,s2
    80004452:	0001e917          	auipc	s2,0x1e
    80004456:	74690913          	addi	s2,s2,1862 # 80022b98 <log>
    8000445a:	993e                	add	s2,s2,a5
    8000445c:	854a                	mv	a0,s2
    8000445e:	ffffc097          	auipc	ra,0xffffc
    80004462:	660080e7          	jalr	1632(ra) # 80000abe <acquire>

  if (dev < 0 || dev >= NDISK)
    80004466:	0004871b          	sext.w	a4,s1
    8000446a:	4785                	li	a5,1
    8000446c:	0ae7e063          	bltu	a5,a4,8000450c <crash_op+0xd4>
    panic("end_op: invalid disk");
  if(log[dev].outstanding == 0)
    80004470:	0a800793          	li	a5,168
    80004474:	02f48733          	mul	a4,s1,a5
    80004478:	0001e797          	auipc	a5,0x1e
    8000447c:	72078793          	addi	a5,a5,1824 # 80022b98 <log>
    80004480:	97ba                	add	a5,a5,a4
    80004482:	539c                	lw	a5,32(a5)
    80004484:	cfc1                	beqz	a5,8000451c <crash_op+0xe4>
    panic("end_op: already closed");
  log[dev].outstanding -= 1;
    80004486:	37fd                	addiw	a5,a5,-1
    80004488:	0007861b          	sext.w	a2,a5
    8000448c:	0a800713          	li	a4,168
    80004490:	02e486b3          	mul	a3,s1,a4
    80004494:	0001e717          	auipc	a4,0x1e
    80004498:	70470713          	addi	a4,a4,1796 # 80022b98 <log>
    8000449c:	9736                	add	a4,a4,a3
    8000449e:	d31c                	sw	a5,32(a4)
  if(log[dev].committing)
    800044a0:	535c                	lw	a5,36(a4)
    800044a2:	e7c9                	bnez	a5,8000452c <crash_op+0xf4>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    800044a4:	ee41                	bnez	a2,8000453c <crash_op+0x104>
    do_commit = 1;
    log[dev].committing = 1;
    800044a6:	0a800793          	li	a5,168
    800044aa:	02f48733          	mul	a4,s1,a5
    800044ae:	0001e797          	auipc	a5,0x1e
    800044b2:	6ea78793          	addi	a5,a5,1770 # 80022b98 <log>
    800044b6:	97ba                	add	a5,a5,a4
    800044b8:	4705                	li	a4,1
    800044ba:	d3d8                	sw	a4,36(a5)
  }
  
  release(&log[dev].lock);
    800044bc:	854a                	mv	a0,s2
    800044be:	ffffc097          	auipc	ra,0xffffc
    800044c2:	668080e7          	jalr	1640(ra) # 80000b26 <release>

  if(docommit & do_commit){
    800044c6:	0019f993          	andi	s3,s3,1
    800044ca:	06098e63          	beqz	s3,80004546 <crash_op+0x10e>
    printf("crash_op: commit\n");
    800044ce:	00004517          	auipc	a0,0x4
    800044d2:	1f250513          	addi	a0,a0,498 # 800086c0 <userret+0x630>
    800044d6:	ffffc097          	auipc	ra,0xffffc
    800044da:	0bc080e7          	jalr	188(ra) # 80000592 <printf>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.

    if (log[dev].lh.n > 0) {
    800044de:	0a800793          	li	a5,168
    800044e2:	02f48733          	mul	a4,s1,a5
    800044e6:	0001e797          	auipc	a5,0x1e
    800044ea:	6b278793          	addi	a5,a5,1714 # 80022b98 <log>
    800044ee:	97ba                	add	a5,a5,a4
    800044f0:	57dc                	lw	a5,44(a5)
    800044f2:	04f05a63          	blez	a5,80004546 <crash_op+0x10e>
      write_log(dev);     // Write modified blocks from cache to log
    800044f6:	8526                	mv	a0,s1
    800044f8:	00000097          	auipc	ra,0x0
    800044fc:	9ec080e7          	jalr	-1556(ra) # 80003ee4 <write_log>
      write_head(dev);    // Write header to disk -- the real commit
    80004500:	8526                	mv	a0,s1
    80004502:	00000097          	auipc	ra,0x0
    80004506:	958080e7          	jalr	-1704(ra) # 80003e5a <write_head>
    8000450a:	a835                	j	80004546 <crash_op+0x10e>
    panic("end_op: invalid disk");
    8000450c:	00004517          	auipc	a0,0x4
    80004510:	18450513          	addi	a0,a0,388 # 80008690 <userret+0x600>
    80004514:	ffffc097          	auipc	ra,0xffffc
    80004518:	034080e7          	jalr	52(ra) # 80000548 <panic>
    panic("end_op: already closed");
    8000451c:	00004517          	auipc	a0,0x4
    80004520:	18c50513          	addi	a0,a0,396 # 800086a8 <userret+0x618>
    80004524:	ffffc097          	auipc	ra,0xffffc
    80004528:	024080e7          	jalr	36(ra) # 80000548 <panic>
    panic("log[dev].committing");
    8000452c:	00004517          	auipc	a0,0x4
    80004530:	11450513          	addi	a0,a0,276 # 80008640 <userret+0x5b0>
    80004534:	ffffc097          	auipc	ra,0xffffc
    80004538:	014080e7          	jalr	20(ra) # 80000548 <panic>
  release(&log[dev].lock);
    8000453c:	854a                	mv	a0,s2
    8000453e:	ffffc097          	auipc	ra,0xffffc
    80004542:	5e8080e7          	jalr	1512(ra) # 80000b26 <release>
    }
  }
  panic("crashed file system; please restart xv6 and run crashtest\n");
    80004546:	00004517          	auipc	a0,0x4
    8000454a:	19250513          	addi	a0,a0,402 # 800086d8 <userret+0x648>
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	ffa080e7          	jalr	-6(ra) # 80000548 <panic>

0000000080004556 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004556:	1101                	addi	sp,sp,-32
    80004558:	ec06                	sd	ra,24(sp)
    8000455a:	e822                	sd	s0,16(sp)
    8000455c:	e426                	sd	s1,8(sp)
    8000455e:	e04a                	sd	s2,0(sp)
    80004560:	1000                	addi	s0,sp,32
    80004562:	84aa                	mv	s1,a0
    80004564:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004566:	00004597          	auipc	a1,0x4
    8000456a:	1b258593          	addi	a1,a1,434 # 80008718 <userret+0x688>
    8000456e:	0521                	addi	a0,a0,8
    80004570:	ffffc097          	auipc	ra,0xffffc
    80004574:	440080e7          	jalr	1088(ra) # 800009b0 <initlock>
  lk->name = name;
    80004578:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000457c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004580:	0204a423          	sw	zero,40(s1)
}
    80004584:	60e2                	ld	ra,24(sp)
    80004586:	6442                	ld	s0,16(sp)
    80004588:	64a2                	ld	s1,8(sp)
    8000458a:	6902                	ld	s2,0(sp)
    8000458c:	6105                	addi	sp,sp,32
    8000458e:	8082                	ret

0000000080004590 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004590:	1101                	addi	sp,sp,-32
    80004592:	ec06                	sd	ra,24(sp)
    80004594:	e822                	sd	s0,16(sp)
    80004596:	e426                	sd	s1,8(sp)
    80004598:	e04a                	sd	s2,0(sp)
    8000459a:	1000                	addi	s0,sp,32
    8000459c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000459e:	00850913          	addi	s2,a0,8
    800045a2:	854a                	mv	a0,s2
    800045a4:	ffffc097          	auipc	ra,0xffffc
    800045a8:	51a080e7          	jalr	1306(ra) # 80000abe <acquire>
  while (lk->locked) {
    800045ac:	409c                	lw	a5,0(s1)
    800045ae:	cb89                	beqz	a5,800045c0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045b0:	85ca                	mv	a1,s2
    800045b2:	8526                	mv	a0,s1
    800045b4:	ffffe097          	auipc	ra,0xffffe
    800045b8:	c54080e7          	jalr	-940(ra) # 80002208 <sleep>
  while (lk->locked) {
    800045bc:	409c                	lw	a5,0(s1)
    800045be:	fbed                	bnez	a5,800045b0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045c0:	4785                	li	a5,1
    800045c2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045c4:	ffffd097          	auipc	ra,0xffffd
    800045c8:	466080e7          	jalr	1126(ra) # 80001a2a <myproc>
    800045cc:	5d1c                	lw	a5,56(a0)
    800045ce:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045d0:	854a                	mv	a0,s2
    800045d2:	ffffc097          	auipc	ra,0xffffc
    800045d6:	554080e7          	jalr	1364(ra) # 80000b26 <release>
}
    800045da:	60e2                	ld	ra,24(sp)
    800045dc:	6442                	ld	s0,16(sp)
    800045de:	64a2                	ld	s1,8(sp)
    800045e0:	6902                	ld	s2,0(sp)
    800045e2:	6105                	addi	sp,sp,32
    800045e4:	8082                	ret

00000000800045e6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045e6:	1101                	addi	sp,sp,-32
    800045e8:	ec06                	sd	ra,24(sp)
    800045ea:	e822                	sd	s0,16(sp)
    800045ec:	e426                	sd	s1,8(sp)
    800045ee:	e04a                	sd	s2,0(sp)
    800045f0:	1000                	addi	s0,sp,32
    800045f2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045f4:	00850913          	addi	s2,a0,8
    800045f8:	854a                	mv	a0,s2
    800045fa:	ffffc097          	auipc	ra,0xffffc
    800045fe:	4c4080e7          	jalr	1220(ra) # 80000abe <acquire>
  lk->locked = 0;
    80004602:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004606:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000460a:	8526                	mv	a0,s1
    8000460c:	ffffe097          	auipc	ra,0xffffe
    80004610:	d7c080e7          	jalr	-644(ra) # 80002388 <wakeup>
  release(&lk->lk);
    80004614:	854a                	mv	a0,s2
    80004616:	ffffc097          	auipc	ra,0xffffc
    8000461a:	510080e7          	jalr	1296(ra) # 80000b26 <release>
}
    8000461e:	60e2                	ld	ra,24(sp)
    80004620:	6442                	ld	s0,16(sp)
    80004622:	64a2                	ld	s1,8(sp)
    80004624:	6902                	ld	s2,0(sp)
    80004626:	6105                	addi	sp,sp,32
    80004628:	8082                	ret

000000008000462a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000462a:	7179                	addi	sp,sp,-48
    8000462c:	f406                	sd	ra,40(sp)
    8000462e:	f022                	sd	s0,32(sp)
    80004630:	ec26                	sd	s1,24(sp)
    80004632:	e84a                	sd	s2,16(sp)
    80004634:	e44e                	sd	s3,8(sp)
    80004636:	1800                	addi	s0,sp,48
    80004638:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000463a:	00850913          	addi	s2,a0,8
    8000463e:	854a                	mv	a0,s2
    80004640:	ffffc097          	auipc	ra,0xffffc
    80004644:	47e080e7          	jalr	1150(ra) # 80000abe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004648:	409c                	lw	a5,0(s1)
    8000464a:	ef99                	bnez	a5,80004668 <holdingsleep+0x3e>
    8000464c:	4481                	li	s1,0
  release(&lk->lk);
    8000464e:	854a                	mv	a0,s2
    80004650:	ffffc097          	auipc	ra,0xffffc
    80004654:	4d6080e7          	jalr	1238(ra) # 80000b26 <release>
  return r;
}
    80004658:	8526                	mv	a0,s1
    8000465a:	70a2                	ld	ra,40(sp)
    8000465c:	7402                	ld	s0,32(sp)
    8000465e:	64e2                	ld	s1,24(sp)
    80004660:	6942                	ld	s2,16(sp)
    80004662:	69a2                	ld	s3,8(sp)
    80004664:	6145                	addi	sp,sp,48
    80004666:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004668:	0284a983          	lw	s3,40(s1)
    8000466c:	ffffd097          	auipc	ra,0xffffd
    80004670:	3be080e7          	jalr	958(ra) # 80001a2a <myproc>
    80004674:	5d04                	lw	s1,56(a0)
    80004676:	413484b3          	sub	s1,s1,s3
    8000467a:	0014b493          	seqz	s1,s1
    8000467e:	bfc1                	j	8000464e <holdingsleep+0x24>

0000000080004680 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004680:	1141                	addi	sp,sp,-16
    80004682:	e406                	sd	ra,8(sp)
    80004684:	e022                	sd	s0,0(sp)
    80004686:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004688:	00004597          	auipc	a1,0x4
    8000468c:	0a058593          	addi	a1,a1,160 # 80008728 <userret+0x698>
    80004690:	0001e517          	auipc	a0,0x1e
    80004694:	6f850513          	addi	a0,a0,1784 # 80022d88 <ftable>
    80004698:	ffffc097          	auipc	ra,0xffffc
    8000469c:	318080e7          	jalr	792(ra) # 800009b0 <initlock>
}
    800046a0:	60a2                	ld	ra,8(sp)
    800046a2:	6402                	ld	s0,0(sp)
    800046a4:	0141                	addi	sp,sp,16
    800046a6:	8082                	ret

00000000800046a8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046a8:	1101                	addi	sp,sp,-32
    800046aa:	ec06                	sd	ra,24(sp)
    800046ac:	e822                	sd	s0,16(sp)
    800046ae:	e426                	sd	s1,8(sp)
    800046b0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046b2:	0001e517          	auipc	a0,0x1e
    800046b6:	6d650513          	addi	a0,a0,1750 # 80022d88 <ftable>
    800046ba:	ffffc097          	auipc	ra,0xffffc
    800046be:	404080e7          	jalr	1028(ra) # 80000abe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046c2:	0001e497          	auipc	s1,0x1e
    800046c6:	6de48493          	addi	s1,s1,1758 # 80022da0 <ftable+0x18>
    800046ca:	0001f717          	auipc	a4,0x1f
    800046ce:	67670713          	addi	a4,a4,1654 # 80023d40 <ftable+0xfb8>
    if(f->ref == 0){
    800046d2:	40dc                	lw	a5,4(s1)
    800046d4:	cf99                	beqz	a5,800046f2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046d6:	02848493          	addi	s1,s1,40
    800046da:	fee49ce3          	bne	s1,a4,800046d2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046de:	0001e517          	auipc	a0,0x1e
    800046e2:	6aa50513          	addi	a0,a0,1706 # 80022d88 <ftable>
    800046e6:	ffffc097          	auipc	ra,0xffffc
    800046ea:	440080e7          	jalr	1088(ra) # 80000b26 <release>
  return 0;
    800046ee:	4481                	li	s1,0
    800046f0:	a819                	j	80004706 <filealloc+0x5e>
      f->ref = 1;
    800046f2:	4785                	li	a5,1
    800046f4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046f6:	0001e517          	auipc	a0,0x1e
    800046fa:	69250513          	addi	a0,a0,1682 # 80022d88 <ftable>
    800046fe:	ffffc097          	auipc	ra,0xffffc
    80004702:	428080e7          	jalr	1064(ra) # 80000b26 <release>
}
    80004706:	8526                	mv	a0,s1
    80004708:	60e2                	ld	ra,24(sp)
    8000470a:	6442                	ld	s0,16(sp)
    8000470c:	64a2                	ld	s1,8(sp)
    8000470e:	6105                	addi	sp,sp,32
    80004710:	8082                	ret

0000000080004712 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004712:	1101                	addi	sp,sp,-32
    80004714:	ec06                	sd	ra,24(sp)
    80004716:	e822                	sd	s0,16(sp)
    80004718:	e426                	sd	s1,8(sp)
    8000471a:	1000                	addi	s0,sp,32
    8000471c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000471e:	0001e517          	auipc	a0,0x1e
    80004722:	66a50513          	addi	a0,a0,1642 # 80022d88 <ftable>
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	398080e7          	jalr	920(ra) # 80000abe <acquire>
  if(f->ref < 1)
    8000472e:	40dc                	lw	a5,4(s1)
    80004730:	02f05263          	blez	a5,80004754 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004734:	2785                	addiw	a5,a5,1
    80004736:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004738:	0001e517          	auipc	a0,0x1e
    8000473c:	65050513          	addi	a0,a0,1616 # 80022d88 <ftable>
    80004740:	ffffc097          	auipc	ra,0xffffc
    80004744:	3e6080e7          	jalr	998(ra) # 80000b26 <release>
  return f;
}
    80004748:	8526                	mv	a0,s1
    8000474a:	60e2                	ld	ra,24(sp)
    8000474c:	6442                	ld	s0,16(sp)
    8000474e:	64a2                	ld	s1,8(sp)
    80004750:	6105                	addi	sp,sp,32
    80004752:	8082                	ret
    panic("filedup");
    80004754:	00004517          	auipc	a0,0x4
    80004758:	fdc50513          	addi	a0,a0,-36 # 80008730 <userret+0x6a0>
    8000475c:	ffffc097          	auipc	ra,0xffffc
    80004760:	dec080e7          	jalr	-532(ra) # 80000548 <panic>

0000000080004764 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004764:	7139                	addi	sp,sp,-64
    80004766:	fc06                	sd	ra,56(sp)
    80004768:	f822                	sd	s0,48(sp)
    8000476a:	f426                	sd	s1,40(sp)
    8000476c:	f04a                	sd	s2,32(sp)
    8000476e:	ec4e                	sd	s3,24(sp)
    80004770:	e852                	sd	s4,16(sp)
    80004772:	e456                	sd	s5,8(sp)
    80004774:	0080                	addi	s0,sp,64
    80004776:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004778:	0001e517          	auipc	a0,0x1e
    8000477c:	61050513          	addi	a0,a0,1552 # 80022d88 <ftable>
    80004780:	ffffc097          	auipc	ra,0xffffc
    80004784:	33e080e7          	jalr	830(ra) # 80000abe <acquire>
  if(f->ref < 1)
    80004788:	40dc                	lw	a5,4(s1)
    8000478a:	06f05563          	blez	a5,800047f4 <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    8000478e:	37fd                	addiw	a5,a5,-1
    80004790:	0007871b          	sext.w	a4,a5
    80004794:	c0dc                	sw	a5,4(s1)
    80004796:	06e04763          	bgtz	a4,80004804 <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000479a:	0004a903          	lw	s2,0(s1)
    8000479e:	0094ca83          	lbu	s5,9(s1)
    800047a2:	0104ba03          	ld	s4,16(s1)
    800047a6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047aa:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047ae:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047b2:	0001e517          	auipc	a0,0x1e
    800047b6:	5d650513          	addi	a0,a0,1494 # 80022d88 <ftable>
    800047ba:	ffffc097          	auipc	ra,0xffffc
    800047be:	36c080e7          	jalr	876(ra) # 80000b26 <release>

  if(ff.type == FD_PIPE){
    800047c2:	4785                	li	a5,1
    800047c4:	06f90163          	beq	s2,a5,80004826 <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047c8:	3979                	addiw	s2,s2,-2
    800047ca:	4785                	li	a5,1
    800047cc:	0527e463          	bltu	a5,s2,80004814 <fileclose+0xb0>
    begin_op(ff.ip->dev);
    800047d0:	0009a503          	lw	a0,0(s3)
    800047d4:	00000097          	auipc	ra,0x0
    800047d8:	968080e7          	jalr	-1688(ra) # 8000413c <begin_op>
    iput(ff.ip);
    800047dc:	854e                	mv	a0,s3
    800047de:	fffff097          	auipc	ra,0xfffff
    800047e2:	fc6080e7          	jalr	-58(ra) # 800037a4 <iput>
    end_op(ff.ip->dev);
    800047e6:	0009a503          	lw	a0,0(s3)
    800047ea:	00000097          	auipc	ra,0x0
    800047ee:	9fc080e7          	jalr	-1540(ra) # 800041e6 <end_op>
    800047f2:	a00d                	j	80004814 <fileclose+0xb0>
    panic("fileclose");
    800047f4:	00004517          	auipc	a0,0x4
    800047f8:	f4450513          	addi	a0,a0,-188 # 80008738 <userret+0x6a8>
    800047fc:	ffffc097          	auipc	ra,0xffffc
    80004800:	d4c080e7          	jalr	-692(ra) # 80000548 <panic>
    release(&ftable.lock);
    80004804:	0001e517          	auipc	a0,0x1e
    80004808:	58450513          	addi	a0,a0,1412 # 80022d88 <ftable>
    8000480c:	ffffc097          	auipc	ra,0xffffc
    80004810:	31a080e7          	jalr	794(ra) # 80000b26 <release>
  }
}
    80004814:	70e2                	ld	ra,56(sp)
    80004816:	7442                	ld	s0,48(sp)
    80004818:	74a2                	ld	s1,40(sp)
    8000481a:	7902                	ld	s2,32(sp)
    8000481c:	69e2                	ld	s3,24(sp)
    8000481e:	6a42                	ld	s4,16(sp)
    80004820:	6aa2                	ld	s5,8(sp)
    80004822:	6121                	addi	sp,sp,64
    80004824:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004826:	85d6                	mv	a1,s5
    80004828:	8552                	mv	a0,s4
    8000482a:	00000097          	auipc	ra,0x0
    8000482e:	378080e7          	jalr	888(ra) # 80004ba2 <pipeclose>
    80004832:	b7cd                	j	80004814 <fileclose+0xb0>

0000000080004834 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004834:	715d                	addi	sp,sp,-80
    80004836:	e486                	sd	ra,72(sp)
    80004838:	e0a2                	sd	s0,64(sp)
    8000483a:	fc26                	sd	s1,56(sp)
    8000483c:	f84a                	sd	s2,48(sp)
    8000483e:	f44e                	sd	s3,40(sp)
    80004840:	0880                	addi	s0,sp,80
    80004842:	84aa                	mv	s1,a0
    80004844:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004846:	ffffd097          	auipc	ra,0xffffd
    8000484a:	1e4080e7          	jalr	484(ra) # 80001a2a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000484e:	409c                	lw	a5,0(s1)
    80004850:	37f9                	addiw	a5,a5,-2
    80004852:	4705                	li	a4,1
    80004854:	04f76763          	bltu	a4,a5,800048a2 <filestat+0x6e>
    80004858:	892a                	mv	s2,a0
    ilock(f->ip);
    8000485a:	6c88                	ld	a0,24(s1)
    8000485c:	fffff097          	auipc	ra,0xfffff
    80004860:	e3a080e7          	jalr	-454(ra) # 80003696 <ilock>
    stati(f->ip, &st);
    80004864:	fb840593          	addi	a1,s0,-72
    80004868:	6c88                	ld	a0,24(s1)
    8000486a:	fffff097          	auipc	ra,0xfffff
    8000486e:	092080e7          	jalr	146(ra) # 800038fc <stati>
    iunlock(f->ip);
    80004872:	6c88                	ld	a0,24(s1)
    80004874:	fffff097          	auipc	ra,0xfffff
    80004878:	ee4080e7          	jalr	-284(ra) # 80003758 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000487c:	46e1                	li	a3,24
    8000487e:	fb840613          	addi	a2,s0,-72
    80004882:	85ce                	mv	a1,s3
    80004884:	05893503          	ld	a0,88(s2)
    80004888:	ffffd097          	auipc	ra,0xffffd
    8000488c:	f0a080e7          	jalr	-246(ra) # 80001792 <copyout>
    80004890:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004894:	60a6                	ld	ra,72(sp)
    80004896:	6406                	ld	s0,64(sp)
    80004898:	74e2                	ld	s1,56(sp)
    8000489a:	7942                	ld	s2,48(sp)
    8000489c:	79a2                	ld	s3,40(sp)
    8000489e:	6161                	addi	sp,sp,80
    800048a0:	8082                	ret
  return -1;
    800048a2:	557d                	li	a0,-1
    800048a4:	bfc5                	j	80004894 <filestat+0x60>

00000000800048a6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048a6:	7179                	addi	sp,sp,-48
    800048a8:	f406                	sd	ra,40(sp)
    800048aa:	f022                	sd	s0,32(sp)
    800048ac:	ec26                	sd	s1,24(sp)
    800048ae:	e84a                	sd	s2,16(sp)
    800048b0:	e44e                	sd	s3,8(sp)
    800048b2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048b4:	00854783          	lbu	a5,8(a0)
    800048b8:	c7c5                	beqz	a5,80004960 <fileread+0xba>
    800048ba:	84aa                	mv	s1,a0
    800048bc:	89ae                	mv	s3,a1
    800048be:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048c0:	411c                	lw	a5,0(a0)
    800048c2:	4705                	li	a4,1
    800048c4:	04e78963          	beq	a5,a4,80004916 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048c8:	470d                	li	a4,3
    800048ca:	04e78d63          	beq	a5,a4,80004924 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800048ce:	4709                	li	a4,2
    800048d0:	08e79063          	bne	a5,a4,80004950 <fileread+0xaa>
    ilock(f->ip);
    800048d4:	6d08                	ld	a0,24(a0)
    800048d6:	fffff097          	auipc	ra,0xfffff
    800048da:	dc0080e7          	jalr	-576(ra) # 80003696 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048de:	874a                	mv	a4,s2
    800048e0:	5094                	lw	a3,32(s1)
    800048e2:	864e                	mv	a2,s3
    800048e4:	4585                	li	a1,1
    800048e6:	6c88                	ld	a0,24(s1)
    800048e8:	fffff097          	auipc	ra,0xfffff
    800048ec:	03e080e7          	jalr	62(ra) # 80003926 <readi>
    800048f0:	892a                	mv	s2,a0
    800048f2:	00a05563          	blez	a0,800048fc <fileread+0x56>
      f->off += r;
    800048f6:	509c                	lw	a5,32(s1)
    800048f8:	9fa9                	addw	a5,a5,a0
    800048fa:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048fc:	6c88                	ld	a0,24(s1)
    800048fe:	fffff097          	auipc	ra,0xfffff
    80004902:	e5a080e7          	jalr	-422(ra) # 80003758 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004906:	854a                	mv	a0,s2
    80004908:	70a2                	ld	ra,40(sp)
    8000490a:	7402                	ld	s0,32(sp)
    8000490c:	64e2                	ld	s1,24(sp)
    8000490e:	6942                	ld	s2,16(sp)
    80004910:	69a2                	ld	s3,8(sp)
    80004912:	6145                	addi	sp,sp,48
    80004914:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004916:	6908                	ld	a0,16(a0)
    80004918:	00000097          	auipc	ra,0x0
    8000491c:	408080e7          	jalr	1032(ra) # 80004d20 <piperead>
    80004920:	892a                	mv	s2,a0
    80004922:	b7d5                	j	80004906 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004924:	02451783          	lh	a5,36(a0)
    80004928:	03079693          	slli	a3,a5,0x30
    8000492c:	92c1                	srli	a3,a3,0x30
    8000492e:	4725                	li	a4,9
    80004930:	02d76a63          	bltu	a4,a3,80004964 <fileread+0xbe>
    80004934:	0792                	slli	a5,a5,0x4
    80004936:	0001e717          	auipc	a4,0x1e
    8000493a:	3b270713          	addi	a4,a4,946 # 80022ce8 <devsw>
    8000493e:	97ba                	add	a5,a5,a4
    80004940:	639c                	ld	a5,0(a5)
    80004942:	c39d                	beqz	a5,80004968 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80004944:	86b2                	mv	a3,a2
    80004946:	862e                	mv	a2,a1
    80004948:	4585                	li	a1,1
    8000494a:	9782                	jalr	a5
    8000494c:	892a                	mv	s2,a0
    8000494e:	bf65                	j	80004906 <fileread+0x60>
    panic("fileread");
    80004950:	00004517          	auipc	a0,0x4
    80004954:	df850513          	addi	a0,a0,-520 # 80008748 <userret+0x6b8>
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	bf0080e7          	jalr	-1040(ra) # 80000548 <panic>
    return -1;
    80004960:	597d                	li	s2,-1
    80004962:	b755                	j	80004906 <fileread+0x60>
      return -1;
    80004964:	597d                	li	s2,-1
    80004966:	b745                	j	80004906 <fileread+0x60>
    80004968:	597d                	li	s2,-1
    8000496a:	bf71                	j	80004906 <fileread+0x60>

000000008000496c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000496c:	00954783          	lbu	a5,9(a0)
    80004970:	14078663          	beqz	a5,80004abc <filewrite+0x150>
{
    80004974:	715d                	addi	sp,sp,-80
    80004976:	e486                	sd	ra,72(sp)
    80004978:	e0a2                	sd	s0,64(sp)
    8000497a:	fc26                	sd	s1,56(sp)
    8000497c:	f84a                	sd	s2,48(sp)
    8000497e:	f44e                	sd	s3,40(sp)
    80004980:	f052                	sd	s4,32(sp)
    80004982:	ec56                	sd	s5,24(sp)
    80004984:	e85a                	sd	s6,16(sp)
    80004986:	e45e                	sd	s7,8(sp)
    80004988:	e062                	sd	s8,0(sp)
    8000498a:	0880                	addi	s0,sp,80
    8000498c:	84aa                	mv	s1,a0
    8000498e:	8aae                	mv	s5,a1
    80004990:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004992:	411c                	lw	a5,0(a0)
    80004994:	4705                	li	a4,1
    80004996:	02e78263          	beq	a5,a4,800049ba <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000499a:	470d                	li	a4,3
    8000499c:	02e78563          	beq	a5,a4,800049c6 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800049a0:	4709                	li	a4,2
    800049a2:	10e79563          	bne	a5,a4,80004aac <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049a6:	0ec05f63          	blez	a2,80004aa4 <filewrite+0x138>
    int i = 0;
    800049aa:	4981                	li	s3,0
    800049ac:	6b05                	lui	s6,0x1
    800049ae:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049b2:	6b85                	lui	s7,0x1
    800049b4:	c00b8b9b          	addiw	s7,s7,-1024
    800049b8:	a851                	j	80004a4c <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800049ba:	6908                	ld	a0,16(a0)
    800049bc:	00000097          	auipc	ra,0x0
    800049c0:	256080e7          	jalr	598(ra) # 80004c12 <pipewrite>
    800049c4:	a865                	j	80004a7c <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049c6:	02451783          	lh	a5,36(a0)
    800049ca:	03079693          	slli	a3,a5,0x30
    800049ce:	92c1                	srli	a3,a3,0x30
    800049d0:	4725                	li	a4,9
    800049d2:	0ed76763          	bltu	a4,a3,80004ac0 <filewrite+0x154>
    800049d6:	0792                	slli	a5,a5,0x4
    800049d8:	0001e717          	auipc	a4,0x1e
    800049dc:	31070713          	addi	a4,a4,784 # 80022ce8 <devsw>
    800049e0:	97ba                	add	a5,a5,a4
    800049e2:	679c                	ld	a5,8(a5)
    800049e4:	c3e5                	beqz	a5,80004ac4 <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    800049e6:	86b2                	mv	a3,a2
    800049e8:	862e                	mv	a2,a1
    800049ea:	4585                	li	a1,1
    800049ec:	9782                	jalr	a5
    800049ee:	a079                	j	80004a7c <filewrite+0x110>
    800049f0:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    800049f4:	6c9c                	ld	a5,24(s1)
    800049f6:	4388                	lw	a0,0(a5)
    800049f8:	fffff097          	auipc	ra,0xfffff
    800049fc:	744080e7          	jalr	1860(ra) # 8000413c <begin_op>
      ilock(f->ip);
    80004a00:	6c88                	ld	a0,24(s1)
    80004a02:	fffff097          	auipc	ra,0xfffff
    80004a06:	c94080e7          	jalr	-876(ra) # 80003696 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a0a:	8762                	mv	a4,s8
    80004a0c:	5094                	lw	a3,32(s1)
    80004a0e:	01598633          	add	a2,s3,s5
    80004a12:	4585                	li	a1,1
    80004a14:	6c88                	ld	a0,24(s1)
    80004a16:	fffff097          	auipc	ra,0xfffff
    80004a1a:	004080e7          	jalr	4(ra) # 80003a1a <writei>
    80004a1e:	892a                	mv	s2,a0
    80004a20:	02a05e63          	blez	a0,80004a5c <filewrite+0xf0>
        f->off += r;
    80004a24:	509c                	lw	a5,32(s1)
    80004a26:	9fa9                	addw	a5,a5,a0
    80004a28:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004a2a:	6c88                	ld	a0,24(s1)
    80004a2c:	fffff097          	auipc	ra,0xfffff
    80004a30:	d2c080e7          	jalr	-724(ra) # 80003758 <iunlock>
      end_op(f->ip->dev);
    80004a34:	6c9c                	ld	a5,24(s1)
    80004a36:	4388                	lw	a0,0(a5)
    80004a38:	fffff097          	auipc	ra,0xfffff
    80004a3c:	7ae080e7          	jalr	1966(ra) # 800041e6 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004a40:	052c1a63          	bne	s8,s2,80004a94 <filewrite+0x128>
        panic("short filewrite");
      i += r;
    80004a44:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80004a48:	0349d763          	bge	s3,s4,80004a76 <filewrite+0x10a>
      int n1 = n - i;
    80004a4c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a50:	893e                	mv	s2,a5
    80004a52:	2781                	sext.w	a5,a5
    80004a54:	f8fb5ee3          	bge	s6,a5,800049f0 <filewrite+0x84>
    80004a58:	895e                	mv	s2,s7
    80004a5a:	bf59                	j	800049f0 <filewrite+0x84>
      iunlock(f->ip);
    80004a5c:	6c88                	ld	a0,24(s1)
    80004a5e:	fffff097          	auipc	ra,0xfffff
    80004a62:	cfa080e7          	jalr	-774(ra) # 80003758 <iunlock>
      end_op(f->ip->dev);
    80004a66:	6c9c                	ld	a5,24(s1)
    80004a68:	4388                	lw	a0,0(a5)
    80004a6a:	fffff097          	auipc	ra,0xfffff
    80004a6e:	77c080e7          	jalr	1916(ra) # 800041e6 <end_op>
      if(r < 0)
    80004a72:	fc0957e3          	bgez	s2,80004a40 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004a76:	8552                	mv	a0,s4
    80004a78:	033a1863          	bne	s4,s3,80004aa8 <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a7c:	60a6                	ld	ra,72(sp)
    80004a7e:	6406                	ld	s0,64(sp)
    80004a80:	74e2                	ld	s1,56(sp)
    80004a82:	7942                	ld	s2,48(sp)
    80004a84:	79a2                	ld	s3,40(sp)
    80004a86:	7a02                	ld	s4,32(sp)
    80004a88:	6ae2                	ld	s5,24(sp)
    80004a8a:	6b42                	ld	s6,16(sp)
    80004a8c:	6ba2                	ld	s7,8(sp)
    80004a8e:	6c02                	ld	s8,0(sp)
    80004a90:	6161                	addi	sp,sp,80
    80004a92:	8082                	ret
        panic("short filewrite");
    80004a94:	00004517          	auipc	a0,0x4
    80004a98:	cc450513          	addi	a0,a0,-828 # 80008758 <userret+0x6c8>
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	aac080e7          	jalr	-1364(ra) # 80000548 <panic>
    int i = 0;
    80004aa4:	4981                	li	s3,0
    80004aa6:	bfc1                	j	80004a76 <filewrite+0x10a>
    ret = (i == n ? n : -1);
    80004aa8:	557d                	li	a0,-1
    80004aaa:	bfc9                	j	80004a7c <filewrite+0x110>
    panic("filewrite");
    80004aac:	00004517          	auipc	a0,0x4
    80004ab0:	cbc50513          	addi	a0,a0,-836 # 80008768 <userret+0x6d8>
    80004ab4:	ffffc097          	auipc	ra,0xffffc
    80004ab8:	a94080e7          	jalr	-1388(ra) # 80000548 <panic>
    return -1;
    80004abc:	557d                	li	a0,-1
}
    80004abe:	8082                	ret
      return -1;
    80004ac0:	557d                	li	a0,-1
    80004ac2:	bf6d                	j	80004a7c <filewrite+0x110>
    80004ac4:	557d                	li	a0,-1
    80004ac6:	bf5d                	j	80004a7c <filewrite+0x110>

0000000080004ac8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ac8:	7179                	addi	sp,sp,-48
    80004aca:	f406                	sd	ra,40(sp)
    80004acc:	f022                	sd	s0,32(sp)
    80004ace:	ec26                	sd	s1,24(sp)
    80004ad0:	e84a                	sd	s2,16(sp)
    80004ad2:	e44e                	sd	s3,8(sp)
    80004ad4:	e052                	sd	s4,0(sp)
    80004ad6:	1800                	addi	s0,sp,48
    80004ad8:	84aa                	mv	s1,a0
    80004ada:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004adc:	0005b023          	sd	zero,0(a1)
    80004ae0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ae4:	00000097          	auipc	ra,0x0
    80004ae8:	bc4080e7          	jalr	-1084(ra) # 800046a8 <filealloc>
    80004aec:	e088                	sd	a0,0(s1)
    80004aee:	c551                	beqz	a0,80004b7a <pipealloc+0xb2>
    80004af0:	00000097          	auipc	ra,0x0
    80004af4:	bb8080e7          	jalr	-1096(ra) # 800046a8 <filealloc>
    80004af8:	00aa3023          	sd	a0,0(s4)
    80004afc:	c92d                	beqz	a0,80004b6e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004afe:	ffffc097          	auipc	ra,0xffffc
    80004b02:	e52080e7          	jalr	-430(ra) # 80000950 <kalloc>
    80004b06:	892a                	mv	s2,a0
    80004b08:	c125                	beqz	a0,80004b68 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b0a:	4985                	li	s3,1
    80004b0c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b10:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b14:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b18:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b1c:	00004597          	auipc	a1,0x4
    80004b20:	c5c58593          	addi	a1,a1,-932 # 80008778 <userret+0x6e8>
    80004b24:	ffffc097          	auipc	ra,0xffffc
    80004b28:	e8c080e7          	jalr	-372(ra) # 800009b0 <initlock>
  (*f0)->type = FD_PIPE;
    80004b2c:	609c                	ld	a5,0(s1)
    80004b2e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b32:	609c                	ld	a5,0(s1)
    80004b34:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b38:	609c                	ld	a5,0(s1)
    80004b3a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b3e:	609c                	ld	a5,0(s1)
    80004b40:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b44:	000a3783          	ld	a5,0(s4)
    80004b48:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b4c:	000a3783          	ld	a5,0(s4)
    80004b50:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b54:	000a3783          	ld	a5,0(s4)
    80004b58:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b5c:	000a3783          	ld	a5,0(s4)
    80004b60:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b64:	4501                	li	a0,0
    80004b66:	a025                	j	80004b8e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b68:	6088                	ld	a0,0(s1)
    80004b6a:	e501                	bnez	a0,80004b72 <pipealloc+0xaa>
    80004b6c:	a039                	j	80004b7a <pipealloc+0xb2>
    80004b6e:	6088                	ld	a0,0(s1)
    80004b70:	c51d                	beqz	a0,80004b9e <pipealloc+0xd6>
    fileclose(*f0);
    80004b72:	00000097          	auipc	ra,0x0
    80004b76:	bf2080e7          	jalr	-1038(ra) # 80004764 <fileclose>
  if(*f1)
    80004b7a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b7e:	557d                	li	a0,-1
  if(*f1)
    80004b80:	c799                	beqz	a5,80004b8e <pipealloc+0xc6>
    fileclose(*f1);
    80004b82:	853e                	mv	a0,a5
    80004b84:	00000097          	auipc	ra,0x0
    80004b88:	be0080e7          	jalr	-1056(ra) # 80004764 <fileclose>
  return -1;
    80004b8c:	557d                	li	a0,-1
}
    80004b8e:	70a2                	ld	ra,40(sp)
    80004b90:	7402                	ld	s0,32(sp)
    80004b92:	64e2                	ld	s1,24(sp)
    80004b94:	6942                	ld	s2,16(sp)
    80004b96:	69a2                	ld	s3,8(sp)
    80004b98:	6a02                	ld	s4,0(sp)
    80004b9a:	6145                	addi	sp,sp,48
    80004b9c:	8082                	ret
  return -1;
    80004b9e:	557d                	li	a0,-1
    80004ba0:	b7fd                	j	80004b8e <pipealloc+0xc6>

0000000080004ba2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ba2:	1101                	addi	sp,sp,-32
    80004ba4:	ec06                	sd	ra,24(sp)
    80004ba6:	e822                	sd	s0,16(sp)
    80004ba8:	e426                	sd	s1,8(sp)
    80004baa:	e04a                	sd	s2,0(sp)
    80004bac:	1000                	addi	s0,sp,32
    80004bae:	84aa                	mv	s1,a0
    80004bb0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bb2:	ffffc097          	auipc	ra,0xffffc
    80004bb6:	f0c080e7          	jalr	-244(ra) # 80000abe <acquire>
  if(writable){
    80004bba:	02090d63          	beqz	s2,80004bf4 <pipeclose+0x52>
    pi->writeopen = 0;
    80004bbe:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bc2:	21848513          	addi	a0,s1,536
    80004bc6:	ffffd097          	auipc	ra,0xffffd
    80004bca:	7c2080e7          	jalr	1986(ra) # 80002388 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bce:	2204b783          	ld	a5,544(s1)
    80004bd2:	eb95                	bnez	a5,80004c06 <pipeclose+0x64>
    release(&pi->lock);
    80004bd4:	8526                	mv	a0,s1
    80004bd6:	ffffc097          	auipc	ra,0xffffc
    80004bda:	f50080e7          	jalr	-176(ra) # 80000b26 <release>
    kfree((char*)pi);
    80004bde:	8526                	mv	a0,s1
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	c74080e7          	jalr	-908(ra) # 80000854 <kfree>
  } else
    release(&pi->lock);
}
    80004be8:	60e2                	ld	ra,24(sp)
    80004bea:	6442                	ld	s0,16(sp)
    80004bec:	64a2                	ld	s1,8(sp)
    80004bee:	6902                	ld	s2,0(sp)
    80004bf0:	6105                	addi	sp,sp,32
    80004bf2:	8082                	ret
    pi->readopen = 0;
    80004bf4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004bf8:	21c48513          	addi	a0,s1,540
    80004bfc:	ffffd097          	auipc	ra,0xffffd
    80004c00:	78c080e7          	jalr	1932(ra) # 80002388 <wakeup>
    80004c04:	b7e9                	j	80004bce <pipeclose+0x2c>
    release(&pi->lock);
    80004c06:	8526                	mv	a0,s1
    80004c08:	ffffc097          	auipc	ra,0xffffc
    80004c0c:	f1e080e7          	jalr	-226(ra) # 80000b26 <release>
}
    80004c10:	bfe1                	j	80004be8 <pipeclose+0x46>

0000000080004c12 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c12:	711d                	addi	sp,sp,-96
    80004c14:	ec86                	sd	ra,88(sp)
    80004c16:	e8a2                	sd	s0,80(sp)
    80004c18:	e4a6                	sd	s1,72(sp)
    80004c1a:	e0ca                	sd	s2,64(sp)
    80004c1c:	fc4e                	sd	s3,56(sp)
    80004c1e:	f852                	sd	s4,48(sp)
    80004c20:	f456                	sd	s5,40(sp)
    80004c22:	f05a                	sd	s6,32(sp)
    80004c24:	ec5e                	sd	s7,24(sp)
    80004c26:	e862                	sd	s8,16(sp)
    80004c28:	1080                	addi	s0,sp,96
    80004c2a:	84aa                	mv	s1,a0
    80004c2c:	8aae                	mv	s5,a1
    80004c2e:	8a32                	mv	s4,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004c30:	ffffd097          	auipc	ra,0xffffd
    80004c34:	dfa080e7          	jalr	-518(ra) # 80001a2a <myproc>
    80004c38:	8baa                	mv	s7,a0

  acquire(&pi->lock);
    80004c3a:	8526                	mv	a0,s1
    80004c3c:	ffffc097          	auipc	ra,0xffffc
    80004c40:	e82080e7          	jalr	-382(ra) # 80000abe <acquire>
  for(i = 0; i < n; i++){
    80004c44:	09405f63          	blez	s4,80004ce2 <pipewrite+0xd0>
    80004c48:	fffa0b1b          	addiw	s6,s4,-1
    80004c4c:	1b02                	slli	s6,s6,0x20
    80004c4e:	020b5b13          	srli	s6,s6,0x20
    80004c52:	001a8793          	addi	a5,s5,1
    80004c56:	9b3e                	add	s6,s6,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c58:	21848993          	addi	s3,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c5c:	21c48913          	addi	s2,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c60:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c62:	2184a783          	lw	a5,536(s1)
    80004c66:	21c4a703          	lw	a4,540(s1)
    80004c6a:	2007879b          	addiw	a5,a5,512
    80004c6e:	02f71e63          	bne	a4,a5,80004caa <pipewrite+0x98>
      if(pi->readopen == 0 || myproc()->killed){
    80004c72:	2204a783          	lw	a5,544(s1)
    80004c76:	c3d9                	beqz	a5,80004cfc <pipewrite+0xea>
    80004c78:	ffffd097          	auipc	ra,0xffffd
    80004c7c:	db2080e7          	jalr	-590(ra) # 80001a2a <myproc>
    80004c80:	591c                	lw	a5,48(a0)
    80004c82:	efad                	bnez	a5,80004cfc <pipewrite+0xea>
      wakeup(&pi->nread);
    80004c84:	854e                	mv	a0,s3
    80004c86:	ffffd097          	auipc	ra,0xffffd
    80004c8a:	702080e7          	jalr	1794(ra) # 80002388 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c8e:	85a6                	mv	a1,s1
    80004c90:	854a                	mv	a0,s2
    80004c92:	ffffd097          	auipc	ra,0xffffd
    80004c96:	576080e7          	jalr	1398(ra) # 80002208 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c9a:	2184a783          	lw	a5,536(s1)
    80004c9e:	21c4a703          	lw	a4,540(s1)
    80004ca2:	2007879b          	addiw	a5,a5,512
    80004ca6:	fcf706e3          	beq	a4,a5,80004c72 <pipewrite+0x60>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004caa:	4685                	li	a3,1
    80004cac:	8656                	mv	a2,s5
    80004cae:	faf40593          	addi	a1,s0,-81
    80004cb2:	058bb503          	ld	a0,88(s7) # 1058 <_entry-0x7fffefa8>
    80004cb6:	ffffd097          	auipc	ra,0xffffd
    80004cba:	b88080e7          	jalr	-1144(ra) # 8000183e <copyin>
    80004cbe:	03850263          	beq	a0,s8,80004ce2 <pipewrite+0xd0>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cc2:	21c4a783          	lw	a5,540(s1)
    80004cc6:	0017871b          	addiw	a4,a5,1
    80004cca:	20e4ae23          	sw	a4,540(s1)
    80004cce:	1ff7f793          	andi	a5,a5,511
    80004cd2:	97a6                	add	a5,a5,s1
    80004cd4:	faf44703          	lbu	a4,-81(s0)
    80004cd8:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004cdc:	0a85                	addi	s5,s5,1
    80004cde:	f96a92e3          	bne	s5,s6,80004c62 <pipewrite+0x50>
  }
  wakeup(&pi->nread);
    80004ce2:	21848513          	addi	a0,s1,536
    80004ce6:	ffffd097          	auipc	ra,0xffffd
    80004cea:	6a2080e7          	jalr	1698(ra) # 80002388 <wakeup>
  release(&pi->lock);
    80004cee:	8526                	mv	a0,s1
    80004cf0:	ffffc097          	auipc	ra,0xffffc
    80004cf4:	e36080e7          	jalr	-458(ra) # 80000b26 <release>
  return n;
    80004cf8:	8552                	mv	a0,s4
    80004cfa:	a039                	j	80004d08 <pipewrite+0xf6>
        release(&pi->lock);
    80004cfc:	8526                	mv	a0,s1
    80004cfe:	ffffc097          	auipc	ra,0xffffc
    80004d02:	e28080e7          	jalr	-472(ra) # 80000b26 <release>
        return -1;
    80004d06:	557d                	li	a0,-1
}
    80004d08:	60e6                	ld	ra,88(sp)
    80004d0a:	6446                	ld	s0,80(sp)
    80004d0c:	64a6                	ld	s1,72(sp)
    80004d0e:	6906                	ld	s2,64(sp)
    80004d10:	79e2                	ld	s3,56(sp)
    80004d12:	7a42                	ld	s4,48(sp)
    80004d14:	7aa2                	ld	s5,40(sp)
    80004d16:	7b02                	ld	s6,32(sp)
    80004d18:	6be2                	ld	s7,24(sp)
    80004d1a:	6c42                	ld	s8,16(sp)
    80004d1c:	6125                	addi	sp,sp,96
    80004d1e:	8082                	ret

0000000080004d20 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d20:	715d                	addi	sp,sp,-80
    80004d22:	e486                	sd	ra,72(sp)
    80004d24:	e0a2                	sd	s0,64(sp)
    80004d26:	fc26                	sd	s1,56(sp)
    80004d28:	f84a                	sd	s2,48(sp)
    80004d2a:	f44e                	sd	s3,40(sp)
    80004d2c:	f052                	sd	s4,32(sp)
    80004d2e:	ec56                	sd	s5,24(sp)
    80004d30:	e85a                	sd	s6,16(sp)
    80004d32:	0880                	addi	s0,sp,80
    80004d34:	84aa                	mv	s1,a0
    80004d36:	892e                	mv	s2,a1
    80004d38:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004d3a:	ffffd097          	auipc	ra,0xffffd
    80004d3e:	cf0080e7          	jalr	-784(ra) # 80001a2a <myproc>
    80004d42:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004d44:	8526                	mv	a0,s1
    80004d46:	ffffc097          	auipc	ra,0xffffc
    80004d4a:	d78080e7          	jalr	-648(ra) # 80000abe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d4e:	2184a703          	lw	a4,536(s1)
    80004d52:	21c4a783          	lw	a5,540(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d56:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d5a:	02f71763          	bne	a4,a5,80004d88 <piperead+0x68>
    80004d5e:	2244a783          	lw	a5,548(s1)
    80004d62:	c39d                	beqz	a5,80004d88 <piperead+0x68>
    if(myproc()->killed){
    80004d64:	ffffd097          	auipc	ra,0xffffd
    80004d68:	cc6080e7          	jalr	-826(ra) # 80001a2a <myproc>
    80004d6c:	591c                	lw	a5,48(a0)
    80004d6e:	ebc1                	bnez	a5,80004dfe <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d70:	85a6                	mv	a1,s1
    80004d72:	854e                	mv	a0,s3
    80004d74:	ffffd097          	auipc	ra,0xffffd
    80004d78:	494080e7          	jalr	1172(ra) # 80002208 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d7c:	2184a703          	lw	a4,536(s1)
    80004d80:	21c4a783          	lw	a5,540(s1)
    80004d84:	fcf70de3          	beq	a4,a5,80004d5e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d88:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d8a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d8c:	05405363          	blez	s4,80004dd2 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004d90:	2184a783          	lw	a5,536(s1)
    80004d94:	21c4a703          	lw	a4,540(s1)
    80004d98:	02f70d63          	beq	a4,a5,80004dd2 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d9c:	0017871b          	addiw	a4,a5,1
    80004da0:	20e4ac23          	sw	a4,536(s1)
    80004da4:	1ff7f793          	andi	a5,a5,511
    80004da8:	97a6                	add	a5,a5,s1
    80004daa:	0187c783          	lbu	a5,24(a5)
    80004dae:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004db2:	4685                	li	a3,1
    80004db4:	fbf40613          	addi	a2,s0,-65
    80004db8:	85ca                	mv	a1,s2
    80004dba:	058ab503          	ld	a0,88(s5)
    80004dbe:	ffffd097          	auipc	ra,0xffffd
    80004dc2:	9d4080e7          	jalr	-1580(ra) # 80001792 <copyout>
    80004dc6:	01650663          	beq	a0,s6,80004dd2 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dca:	2985                	addiw	s3,s3,1
    80004dcc:	0905                	addi	s2,s2,1
    80004dce:	fd3a11e3          	bne	s4,s3,80004d90 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dd2:	21c48513          	addi	a0,s1,540
    80004dd6:	ffffd097          	auipc	ra,0xffffd
    80004dda:	5b2080e7          	jalr	1458(ra) # 80002388 <wakeup>
  release(&pi->lock);
    80004dde:	8526                	mv	a0,s1
    80004de0:	ffffc097          	auipc	ra,0xffffc
    80004de4:	d46080e7          	jalr	-698(ra) # 80000b26 <release>
  return i;
}
    80004de8:	854e                	mv	a0,s3
    80004dea:	60a6                	ld	ra,72(sp)
    80004dec:	6406                	ld	s0,64(sp)
    80004dee:	74e2                	ld	s1,56(sp)
    80004df0:	7942                	ld	s2,48(sp)
    80004df2:	79a2                	ld	s3,40(sp)
    80004df4:	7a02                	ld	s4,32(sp)
    80004df6:	6ae2                	ld	s5,24(sp)
    80004df8:	6b42                	ld	s6,16(sp)
    80004dfa:	6161                	addi	sp,sp,80
    80004dfc:	8082                	ret
      release(&pi->lock);
    80004dfe:	8526                	mv	a0,s1
    80004e00:	ffffc097          	auipc	ra,0xffffc
    80004e04:	d26080e7          	jalr	-730(ra) # 80000b26 <release>
      return -1;
    80004e08:	59fd                	li	s3,-1
    80004e0a:	bff9                	j	80004de8 <piperead+0xc8>

0000000080004e0c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e0c:	de010113          	addi	sp,sp,-544
    80004e10:	20113c23          	sd	ra,536(sp)
    80004e14:	20813823          	sd	s0,528(sp)
    80004e18:	20913423          	sd	s1,520(sp)
    80004e1c:	21213023          	sd	s2,512(sp)
    80004e20:	ffce                	sd	s3,504(sp)
    80004e22:	fbd2                	sd	s4,496(sp)
    80004e24:	f7d6                	sd	s5,488(sp)
    80004e26:	f3da                	sd	s6,480(sp)
    80004e28:	efde                	sd	s7,472(sp)
    80004e2a:	ebe2                	sd	s8,464(sp)
    80004e2c:	e7e6                	sd	s9,456(sp)
    80004e2e:	e3ea                	sd	s10,448(sp)
    80004e30:	ff6e                	sd	s11,440(sp)
    80004e32:	1400                	addi	s0,sp,544
    80004e34:	892a                	mv	s2,a0
    80004e36:	dea43423          	sd	a0,-536(s0)
    80004e3a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e3e:	ffffd097          	auipc	ra,0xffffd
    80004e42:	bec080e7          	jalr	-1044(ra) # 80001a2a <myproc>
    80004e46:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    80004e48:	4501                	li	a0,0
    80004e4a:	fffff097          	auipc	ra,0xfffff
    80004e4e:	2f2080e7          	jalr	754(ra) # 8000413c <begin_op>

  if((ip = namei(path)) == 0){
    80004e52:	854a                	mv	a0,s2
    80004e54:	fffff097          	auipc	ra,0xfffff
    80004e58:	fcc080e7          	jalr	-52(ra) # 80003e20 <namei>
    80004e5c:	cd25                	beqz	a0,80004ed4 <exec+0xc8>
    80004e5e:	8aaa                	mv	s5,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004e60:	fffff097          	auipc	ra,0xfffff
    80004e64:	836080e7          	jalr	-1994(ra) # 80003696 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e68:	04000713          	li	a4,64
    80004e6c:	4681                	li	a3,0
    80004e6e:	e4840613          	addi	a2,s0,-440
    80004e72:	4581                	li	a1,0
    80004e74:	8556                	mv	a0,s5
    80004e76:	fffff097          	auipc	ra,0xfffff
    80004e7a:	ab0080e7          	jalr	-1360(ra) # 80003926 <readi>
    80004e7e:	04000793          	li	a5,64
    80004e82:	00f51a63          	bne	a0,a5,80004e96 <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e86:	e4842703          	lw	a4,-440(s0)
    80004e8a:	464c47b7          	lui	a5,0x464c4
    80004e8e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e92:	04f70863          	beq	a4,a5,80004ee2 <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e96:	8556                	mv	a0,s5
    80004e98:	fffff097          	auipc	ra,0xfffff
    80004e9c:	a3c080e7          	jalr	-1476(ra) # 800038d4 <iunlockput>
    end_op(ROOTDEV);
    80004ea0:	4501                	li	a0,0
    80004ea2:	fffff097          	auipc	ra,0xfffff
    80004ea6:	344080e7          	jalr	836(ra) # 800041e6 <end_op>
  }
  return -1;
    80004eaa:	557d                	li	a0,-1
}
    80004eac:	21813083          	ld	ra,536(sp)
    80004eb0:	21013403          	ld	s0,528(sp)
    80004eb4:	20813483          	ld	s1,520(sp)
    80004eb8:	20013903          	ld	s2,512(sp)
    80004ebc:	79fe                	ld	s3,504(sp)
    80004ebe:	7a5e                	ld	s4,496(sp)
    80004ec0:	7abe                	ld	s5,488(sp)
    80004ec2:	7b1e                	ld	s6,480(sp)
    80004ec4:	6bfe                	ld	s7,472(sp)
    80004ec6:	6c5e                	ld	s8,464(sp)
    80004ec8:	6cbe                	ld	s9,456(sp)
    80004eca:	6d1e                	ld	s10,448(sp)
    80004ecc:	7dfa                	ld	s11,440(sp)
    80004ece:	22010113          	addi	sp,sp,544
    80004ed2:	8082                	ret
    end_op(ROOTDEV);
    80004ed4:	4501                	li	a0,0
    80004ed6:	fffff097          	auipc	ra,0xfffff
    80004eda:	310080e7          	jalr	784(ra) # 800041e6 <end_op>
    return -1;
    80004ede:	557d                	li	a0,-1
    80004ee0:	b7f1                	j	80004eac <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	ffffd097          	auipc	ra,0xffffd
    80004ee8:	c0a080e7          	jalr	-1014(ra) # 80001aee <proc_pagetable>
    80004eec:	8b2a                	mv	s6,a0
    80004eee:	d545                	beqz	a0,80004e96 <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ef0:	e6842783          	lw	a5,-408(s0)
    80004ef4:	e8045703          	lhu	a4,-384(s0)
    80004ef8:	10070263          	beqz	a4,80004ffc <exec+0x1f0>
  sz = 0;
    80004efc:	de043c23          	sd	zero,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f00:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f04:	6a05                	lui	s4,0x1
    80004f06:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f0a:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004f0e:	6d85                	lui	s11,0x1
    80004f10:	7d7d                	lui	s10,0xfffff
    80004f12:	a88d                	j	80004f84 <exec+0x178>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f14:	00004517          	auipc	a0,0x4
    80004f18:	86c50513          	addi	a0,a0,-1940 # 80008780 <userret+0x6f0>
    80004f1c:	ffffb097          	auipc	ra,0xffffb
    80004f20:	62c080e7          	jalr	1580(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f24:	874a                	mv	a4,s2
    80004f26:	009c86bb          	addw	a3,s9,s1
    80004f2a:	4581                	li	a1,0
    80004f2c:	8556                	mv	a0,s5
    80004f2e:	fffff097          	auipc	ra,0xfffff
    80004f32:	9f8080e7          	jalr	-1544(ra) # 80003926 <readi>
    80004f36:	2501                	sext.w	a0,a0
    80004f38:	10a91863          	bne	s2,a0,80005048 <exec+0x23c>
  for(i = 0; i < sz; i += PGSIZE){
    80004f3c:	009d84bb          	addw	s1,s11,s1
    80004f40:	013d09bb          	addw	s3,s10,s3
    80004f44:	0374f263          	bgeu	s1,s7,80004f68 <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    80004f48:	02049593          	slli	a1,s1,0x20
    80004f4c:	9181                	srli	a1,a1,0x20
    80004f4e:	95e2                	add	a1,a1,s8
    80004f50:	855a                	mv	a0,s6
    80004f52:	ffffc097          	auipc	ra,0xffffc
    80004f56:	02a080e7          	jalr	42(ra) # 80000f7c <walkaddr>
    80004f5a:	862a                	mv	a2,a0
    if(pa == 0)
    80004f5c:	dd45                	beqz	a0,80004f14 <exec+0x108>
      n = PGSIZE;
    80004f5e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f60:	fd49f2e3          	bgeu	s3,s4,80004f24 <exec+0x118>
      n = sz - i;
    80004f64:	894e                	mv	s2,s3
    80004f66:	bf7d                	j	80004f24 <exec+0x118>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f68:	e0843783          	ld	a5,-504(s0)
    80004f6c:	0017869b          	addiw	a3,a5,1
    80004f70:	e0d43423          	sd	a3,-504(s0)
    80004f74:	e0043783          	ld	a5,-512(s0)
    80004f78:	0387879b          	addiw	a5,a5,56
    80004f7c:	e8045703          	lhu	a4,-384(s0)
    80004f80:	08e6d063          	bge	a3,a4,80005000 <exec+0x1f4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f84:	2781                	sext.w	a5,a5
    80004f86:	e0f43023          	sd	a5,-512(s0)
    80004f8a:	03800713          	li	a4,56
    80004f8e:	86be                	mv	a3,a5
    80004f90:	e1040613          	addi	a2,s0,-496
    80004f94:	4581                	li	a1,0
    80004f96:	8556                	mv	a0,s5
    80004f98:	fffff097          	auipc	ra,0xfffff
    80004f9c:	98e080e7          	jalr	-1650(ra) # 80003926 <readi>
    80004fa0:	03800793          	li	a5,56
    80004fa4:	0af51263          	bne	a0,a5,80005048 <exec+0x23c>
    if(ph.type != ELF_PROG_LOAD)
    80004fa8:	e1042783          	lw	a5,-496(s0)
    80004fac:	4705                	li	a4,1
    80004fae:	fae79de3          	bne	a5,a4,80004f68 <exec+0x15c>
    if(ph.memsz < ph.filesz)
    80004fb2:	e3843603          	ld	a2,-456(s0)
    80004fb6:	e3043783          	ld	a5,-464(s0)
    80004fba:	08f66763          	bltu	a2,a5,80005048 <exec+0x23c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fbe:	e2043783          	ld	a5,-480(s0)
    80004fc2:	963e                	add	a2,a2,a5
    80004fc4:	08f66263          	bltu	a2,a5,80005048 <exec+0x23c>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fc8:	df843583          	ld	a1,-520(s0)
    80004fcc:	855a                	mv	a0,s6
    80004fce:	ffffc097          	auipc	ra,0xffffc
    80004fd2:	384080e7          	jalr	900(ra) # 80001352 <uvmalloc>
    80004fd6:	dea43c23          	sd	a0,-520(s0)
    80004fda:	c53d                	beqz	a0,80005048 <exec+0x23c>
    if(ph.vaddr % PGSIZE != 0)
    80004fdc:	e2043c03          	ld	s8,-480(s0)
    80004fe0:	de043783          	ld	a5,-544(s0)
    80004fe4:	00fc77b3          	and	a5,s8,a5
    80004fe8:	e3a5                	bnez	a5,80005048 <exec+0x23c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fea:	e1842c83          	lw	s9,-488(s0)
    80004fee:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ff2:	f60b8be3          	beqz	s7,80004f68 <exec+0x15c>
    80004ff6:	89de                	mv	s3,s7
    80004ff8:	4481                	li	s1,0
    80004ffa:	b7b9                	j	80004f48 <exec+0x13c>
  sz = 0;
    80004ffc:	de043c23          	sd	zero,-520(s0)
  iunlockput(ip);
    80005000:	8556                	mv	a0,s5
    80005002:	fffff097          	auipc	ra,0xfffff
    80005006:	8d2080e7          	jalr	-1838(ra) # 800038d4 <iunlockput>
  end_op(ROOTDEV);
    8000500a:	4501                	li	a0,0
    8000500c:	fffff097          	auipc	ra,0xfffff
    80005010:	1da080e7          	jalr	474(ra) # 800041e6 <end_op>
  p = myproc();
    80005014:	ffffd097          	auipc	ra,0xffffd
    80005018:	a16080e7          	jalr	-1514(ra) # 80001a2a <myproc>
    8000501c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000501e:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    80005022:	6585                	lui	a1,0x1
    80005024:	15fd                	addi	a1,a1,-1
    80005026:	df843783          	ld	a5,-520(s0)
    8000502a:	95be                	add	a1,a1,a5
    8000502c:	77fd                	lui	a5,0xfffff
    8000502e:	8dfd                	and	a1,a1,a5
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005030:	6609                	lui	a2,0x2
    80005032:	962e                	add	a2,a2,a1
    80005034:	855a                	mv	a0,s6
    80005036:	ffffc097          	auipc	ra,0xffffc
    8000503a:	31c080e7          	jalr	796(ra) # 80001352 <uvmalloc>
    8000503e:	892a                	mv	s2,a0
    80005040:	dea43c23          	sd	a0,-520(s0)
  ip = 0;
    80005044:	4a81                	li	s5,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005046:	ed01                	bnez	a0,8000505e <exec+0x252>
    proc_freepagetable(pagetable, sz);
    80005048:	df843583          	ld	a1,-520(s0)
    8000504c:	855a                	mv	a0,s6
    8000504e:	ffffd097          	auipc	ra,0xffffd
    80005052:	ba0080e7          	jalr	-1120(ra) # 80001bee <proc_freepagetable>
  if(ip){
    80005056:	e40a90e3          	bnez	s5,80004e96 <exec+0x8a>
  return -1;
    8000505a:	557d                	li	a0,-1
    8000505c:	bd81                	j	80004eac <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000505e:	75f9                	lui	a1,0xffffe
    80005060:	95aa                	add	a1,a1,a0
    80005062:	855a                	mv	a0,s6
    80005064:	ffffc097          	auipc	ra,0xffffc
    80005068:	47a080e7          	jalr	1146(ra) # 800014de <uvmclear>
  stackbase = sp - PGSIZE;
    8000506c:	7c7d                	lui	s8,0xfffff
    8000506e:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    80005070:	df043783          	ld	a5,-528(s0)
    80005074:	6388                	ld	a0,0(a5)
    80005076:	c52d                	beqz	a0,800050e0 <exec+0x2d4>
    80005078:	e8840993          	addi	s3,s0,-376
    8000507c:	f8840a93          	addi	s5,s0,-120
    80005080:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005082:	ffffc097          	auipc	ra,0xffffc
    80005086:	c84080e7          	jalr	-892(ra) # 80000d06 <strlen>
    8000508a:	0015079b          	addiw	a5,a0,1
    8000508e:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005092:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005096:	11896c63          	bltu	s2,s8,800051ae <exec+0x3a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000509a:	df043d03          	ld	s10,-528(s0)
    8000509e:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7ffd4fa4>
    800050a2:	8552                	mv	a0,s4
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	c62080e7          	jalr	-926(ra) # 80000d06 <strlen>
    800050ac:	0015069b          	addiw	a3,a0,1
    800050b0:	8652                	mv	a2,s4
    800050b2:	85ca                	mv	a1,s2
    800050b4:	855a                	mv	a0,s6
    800050b6:	ffffc097          	auipc	ra,0xffffc
    800050ba:	6dc080e7          	jalr	1756(ra) # 80001792 <copyout>
    800050be:	0e054a63          	bltz	a0,800051b2 <exec+0x3a6>
    ustack[argc] = sp;
    800050c2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050c6:	0485                	addi	s1,s1,1
    800050c8:	008d0793          	addi	a5,s10,8
    800050cc:	def43823          	sd	a5,-528(s0)
    800050d0:	008d3503          	ld	a0,8(s10)
    800050d4:	c909                	beqz	a0,800050e6 <exec+0x2da>
    if(argc >= MAXARG)
    800050d6:	09a1                	addi	s3,s3,8
    800050d8:	fb3a95e3          	bne	s5,s3,80005082 <exec+0x276>
  ip = 0;
    800050dc:	4a81                	li	s5,0
    800050de:	b7ad                	j	80005048 <exec+0x23c>
  sp = sz;
    800050e0:	df843903          	ld	s2,-520(s0)
  for(argc = 0; argv[argc]; argc++) {
    800050e4:	4481                	li	s1,0
  ustack[argc] = 0;
    800050e6:	00349793          	slli	a5,s1,0x3
    800050ea:	f9040713          	addi	a4,s0,-112
    800050ee:	97ba                	add	a5,a5,a4
    800050f0:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd4e9c>
  sp -= (argc+1) * sizeof(uint64);
    800050f4:	00148693          	addi	a3,s1,1
    800050f8:	068e                	slli	a3,a3,0x3
    800050fa:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050fe:	ff097913          	andi	s2,s2,-16
  ip = 0;
    80005102:	4a81                	li	s5,0
  if(sp < stackbase)
    80005104:	f58962e3          	bltu	s2,s8,80005048 <exec+0x23c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005108:	e8840613          	addi	a2,s0,-376
    8000510c:	85ca                	mv	a1,s2
    8000510e:	855a                	mv	a0,s6
    80005110:	ffffc097          	auipc	ra,0xffffc
    80005114:	682080e7          	jalr	1666(ra) # 80001792 <copyout>
    80005118:	08054f63          	bltz	a0,800051b6 <exec+0x3aa>
  p->tf->a1 = sp;
    8000511c:	060bb783          	ld	a5,96(s7)
    80005120:	0727bc23          	sd	s2,120(a5)
  p->ustack_top = stackbase + PGSIZE;
    80005124:	df843783          	ld	a5,-520(s0)
    80005128:	04fbb423          	sd	a5,72(s7)
  for(last=s=path; *s; s++)
    8000512c:	de843783          	ld	a5,-536(s0)
    80005130:	0007c703          	lbu	a4,0(a5)
    80005134:	cf11                	beqz	a4,80005150 <exec+0x344>
    80005136:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005138:	02f00693          	li	a3,47
    8000513c:	a039                	j	8000514a <exec+0x33e>
      last = s+1;
    8000513e:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005142:	0785                	addi	a5,a5,1
    80005144:	fff7c703          	lbu	a4,-1(a5)
    80005148:	c701                	beqz	a4,80005150 <exec+0x344>
    if(*s == '/')
    8000514a:	fed71ce3          	bne	a4,a3,80005142 <exec+0x336>
    8000514e:	bfc5                	j	8000513e <exec+0x332>
  safestrcpy(p->name, last, sizeof(p->name));
    80005150:	4641                	li	a2,16
    80005152:	de843583          	ld	a1,-536(s0)
    80005156:	160b8513          	addi	a0,s7,352
    8000515a:	ffffc097          	auipc	ra,0xffffc
    8000515e:	b7a080e7          	jalr	-1158(ra) # 80000cd4 <safestrcpy>
  oldpagetable = p->pagetable;
    80005162:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80005166:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    8000516a:	df843783          	ld	a5,-520(s0)
    8000516e:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80005172:	060bb783          	ld	a5,96(s7)
    80005176:	e6043703          	ld	a4,-416(s0)
    8000517a:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    8000517c:	060bb783          	ld	a5,96(s7)
    80005180:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005184:	85e6                	mv	a1,s9
    80005186:	ffffd097          	auipc	ra,0xffffd
    8000518a:	a68080e7          	jalr	-1432(ra) # 80001bee <proc_freepagetable>
  if(p->pid == 1){
    8000518e:	038ba703          	lw	a4,56(s7)
    80005192:	4785                	li	a5,1
    80005194:	00f70563          	beq	a4,a5,8000519e <exec+0x392>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005198:	0004851b          	sext.w	a0,s1
    8000519c:	bb01                	j	80004eac <exec+0xa0>
    vmprint(p->pagetable,1); // print the page table for the init process
    8000519e:	4585                	li	a1,1
    800051a0:	058bb503          	ld	a0,88(s7)
    800051a4:	ffffc097          	auipc	ra,0xffffc
    800051a8:	420080e7          	jalr	1056(ra) # 800015c4 <vmprint>
    800051ac:	b7f5                	j	80005198 <exec+0x38c>
  ip = 0;
    800051ae:	4a81                	li	s5,0
    800051b0:	bd61                	j	80005048 <exec+0x23c>
    800051b2:	4a81                	li	s5,0
    800051b4:	bd51                	j	80005048 <exec+0x23c>
    800051b6:	4a81                	li	s5,0
    800051b8:	bd41                	j	80005048 <exec+0x23c>

00000000800051ba <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051ba:	7179                	addi	sp,sp,-48
    800051bc:	f406                	sd	ra,40(sp)
    800051be:	f022                	sd	s0,32(sp)
    800051c0:	ec26                	sd	s1,24(sp)
    800051c2:	e84a                	sd	s2,16(sp)
    800051c4:	1800                	addi	s0,sp,48
    800051c6:	892e                	mv	s2,a1
    800051c8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051ca:	fdc40593          	addi	a1,s0,-36
    800051ce:	ffffe097          	auipc	ra,0xffffe
    800051d2:	934080e7          	jalr	-1740(ra) # 80002b02 <argint>
    800051d6:	04054063          	bltz	a0,80005216 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051da:	fdc42703          	lw	a4,-36(s0)
    800051de:	47bd                	li	a5,15
    800051e0:	02e7ed63          	bltu	a5,a4,8000521a <argfd+0x60>
    800051e4:	ffffd097          	auipc	ra,0xffffd
    800051e8:	846080e7          	jalr	-1978(ra) # 80001a2a <myproc>
    800051ec:	fdc42703          	lw	a4,-36(s0)
    800051f0:	01a70793          	addi	a5,a4,26
    800051f4:	078e                	slli	a5,a5,0x3
    800051f6:	953e                	add	a0,a0,a5
    800051f8:	651c                	ld	a5,8(a0)
    800051fa:	c395                	beqz	a5,8000521e <argfd+0x64>
    return -1;
  if(pfd)
    800051fc:	00090463          	beqz	s2,80005204 <argfd+0x4a>
    *pfd = fd;
    80005200:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005204:	4501                	li	a0,0
  if(pf)
    80005206:	c091                	beqz	s1,8000520a <argfd+0x50>
    *pf = f;
    80005208:	e09c                	sd	a5,0(s1)
}
    8000520a:	70a2                	ld	ra,40(sp)
    8000520c:	7402                	ld	s0,32(sp)
    8000520e:	64e2                	ld	s1,24(sp)
    80005210:	6942                	ld	s2,16(sp)
    80005212:	6145                	addi	sp,sp,48
    80005214:	8082                	ret
    return -1;
    80005216:	557d                	li	a0,-1
    80005218:	bfcd                	j	8000520a <argfd+0x50>
    return -1;
    8000521a:	557d                	li	a0,-1
    8000521c:	b7fd                	j	8000520a <argfd+0x50>
    8000521e:	557d                	li	a0,-1
    80005220:	b7ed                	j	8000520a <argfd+0x50>

0000000080005222 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005222:	1101                	addi	sp,sp,-32
    80005224:	ec06                	sd	ra,24(sp)
    80005226:	e822                	sd	s0,16(sp)
    80005228:	e426                	sd	s1,8(sp)
    8000522a:	1000                	addi	s0,sp,32
    8000522c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000522e:	ffffc097          	auipc	ra,0xffffc
    80005232:	7fc080e7          	jalr	2044(ra) # 80001a2a <myproc>
    80005236:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005238:	0d850793          	addi	a5,a0,216
    8000523c:	4501                	li	a0,0
    8000523e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005240:	6398                	ld	a4,0(a5)
    80005242:	cb19                	beqz	a4,80005258 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005244:	2505                	addiw	a0,a0,1
    80005246:	07a1                	addi	a5,a5,8
    80005248:	fed51ce3          	bne	a0,a3,80005240 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000524c:	557d                	li	a0,-1
}
    8000524e:	60e2                	ld	ra,24(sp)
    80005250:	6442                	ld	s0,16(sp)
    80005252:	64a2                	ld	s1,8(sp)
    80005254:	6105                	addi	sp,sp,32
    80005256:	8082                	ret
      p->ofile[fd] = f;
    80005258:	01a50793          	addi	a5,a0,26
    8000525c:	078e                	slli	a5,a5,0x3
    8000525e:	963e                	add	a2,a2,a5
    80005260:	e604                	sd	s1,8(a2)
      return fd;
    80005262:	b7f5                	j	8000524e <fdalloc+0x2c>

0000000080005264 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005264:	715d                	addi	sp,sp,-80
    80005266:	e486                	sd	ra,72(sp)
    80005268:	e0a2                	sd	s0,64(sp)
    8000526a:	fc26                	sd	s1,56(sp)
    8000526c:	f84a                	sd	s2,48(sp)
    8000526e:	f44e                	sd	s3,40(sp)
    80005270:	f052                	sd	s4,32(sp)
    80005272:	ec56                	sd	s5,24(sp)
    80005274:	0880                	addi	s0,sp,80
    80005276:	89ae                	mv	s3,a1
    80005278:	8ab2                	mv	s5,a2
    8000527a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000527c:	fb040593          	addi	a1,s0,-80
    80005280:	fffff097          	auipc	ra,0xfffff
    80005284:	bbe080e7          	jalr	-1090(ra) # 80003e3e <nameiparent>
    80005288:	892a                	mv	s2,a0
    8000528a:	12050e63          	beqz	a0,800053c6 <create+0x162>
    return 0;

  ilock(dp);
    8000528e:	ffffe097          	auipc	ra,0xffffe
    80005292:	408080e7          	jalr	1032(ra) # 80003696 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005296:	4601                	li	a2,0
    80005298:	fb040593          	addi	a1,s0,-80
    8000529c:	854a                	mv	a0,s2
    8000529e:	fffff097          	auipc	ra,0xfffff
    800052a2:	8b0080e7          	jalr	-1872(ra) # 80003b4e <dirlookup>
    800052a6:	84aa                	mv	s1,a0
    800052a8:	c921                	beqz	a0,800052f8 <create+0x94>
    iunlockput(dp);
    800052aa:	854a                	mv	a0,s2
    800052ac:	ffffe097          	auipc	ra,0xffffe
    800052b0:	628080e7          	jalr	1576(ra) # 800038d4 <iunlockput>
    ilock(ip);
    800052b4:	8526                	mv	a0,s1
    800052b6:	ffffe097          	auipc	ra,0xffffe
    800052ba:	3e0080e7          	jalr	992(ra) # 80003696 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052be:	2981                	sext.w	s3,s3
    800052c0:	4789                	li	a5,2
    800052c2:	02f99463          	bne	s3,a5,800052ea <create+0x86>
    800052c6:	0444d783          	lhu	a5,68(s1)
    800052ca:	37f9                	addiw	a5,a5,-2
    800052cc:	17c2                	slli	a5,a5,0x30
    800052ce:	93c1                	srli	a5,a5,0x30
    800052d0:	4705                	li	a4,1
    800052d2:	00f76c63          	bltu	a4,a5,800052ea <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052d6:	8526                	mv	a0,s1
    800052d8:	60a6                	ld	ra,72(sp)
    800052da:	6406                	ld	s0,64(sp)
    800052dc:	74e2                	ld	s1,56(sp)
    800052de:	7942                	ld	s2,48(sp)
    800052e0:	79a2                	ld	s3,40(sp)
    800052e2:	7a02                	ld	s4,32(sp)
    800052e4:	6ae2                	ld	s5,24(sp)
    800052e6:	6161                	addi	sp,sp,80
    800052e8:	8082                	ret
    iunlockput(ip);
    800052ea:	8526                	mv	a0,s1
    800052ec:	ffffe097          	auipc	ra,0xffffe
    800052f0:	5e8080e7          	jalr	1512(ra) # 800038d4 <iunlockput>
    return 0;
    800052f4:	4481                	li	s1,0
    800052f6:	b7c5                	j	800052d6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052f8:	85ce                	mv	a1,s3
    800052fa:	00092503          	lw	a0,0(s2)
    800052fe:	ffffe097          	auipc	ra,0xffffe
    80005302:	200080e7          	jalr	512(ra) # 800034fe <ialloc>
    80005306:	84aa                	mv	s1,a0
    80005308:	c521                	beqz	a0,80005350 <create+0xec>
  ilock(ip);
    8000530a:	ffffe097          	auipc	ra,0xffffe
    8000530e:	38c080e7          	jalr	908(ra) # 80003696 <ilock>
  ip->major = major;
    80005312:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005316:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000531a:	4a05                	li	s4,1
    8000531c:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005320:	8526                	mv	a0,s1
    80005322:	ffffe097          	auipc	ra,0xffffe
    80005326:	2aa080e7          	jalr	682(ra) # 800035cc <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000532a:	2981                	sext.w	s3,s3
    8000532c:	03498a63          	beq	s3,s4,80005360 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005330:	40d0                	lw	a2,4(s1)
    80005332:	fb040593          	addi	a1,s0,-80
    80005336:	854a                	mv	a0,s2
    80005338:	fffff097          	auipc	ra,0xfffff
    8000533c:	a26080e7          	jalr	-1498(ra) # 80003d5e <dirlink>
    80005340:	06054b63          	bltz	a0,800053b6 <create+0x152>
  iunlockput(dp);
    80005344:	854a                	mv	a0,s2
    80005346:	ffffe097          	auipc	ra,0xffffe
    8000534a:	58e080e7          	jalr	1422(ra) # 800038d4 <iunlockput>
  return ip;
    8000534e:	b761                	j	800052d6 <create+0x72>
    panic("create: ialloc");
    80005350:	00003517          	auipc	a0,0x3
    80005354:	45050513          	addi	a0,a0,1104 # 800087a0 <userret+0x710>
    80005358:	ffffb097          	auipc	ra,0xffffb
    8000535c:	1f0080e7          	jalr	496(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    80005360:	04a95783          	lhu	a5,74(s2)
    80005364:	2785                	addiw	a5,a5,1
    80005366:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000536a:	854a                	mv	a0,s2
    8000536c:	ffffe097          	auipc	ra,0xffffe
    80005370:	260080e7          	jalr	608(ra) # 800035cc <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005374:	40d0                	lw	a2,4(s1)
    80005376:	00003597          	auipc	a1,0x3
    8000537a:	43a58593          	addi	a1,a1,1082 # 800087b0 <userret+0x720>
    8000537e:	8526                	mv	a0,s1
    80005380:	fffff097          	auipc	ra,0xfffff
    80005384:	9de080e7          	jalr	-1570(ra) # 80003d5e <dirlink>
    80005388:	00054f63          	bltz	a0,800053a6 <create+0x142>
    8000538c:	00492603          	lw	a2,4(s2)
    80005390:	00003597          	auipc	a1,0x3
    80005394:	42858593          	addi	a1,a1,1064 # 800087b8 <userret+0x728>
    80005398:	8526                	mv	a0,s1
    8000539a:	fffff097          	auipc	ra,0xfffff
    8000539e:	9c4080e7          	jalr	-1596(ra) # 80003d5e <dirlink>
    800053a2:	f80557e3          	bgez	a0,80005330 <create+0xcc>
      panic("create dots");
    800053a6:	00003517          	auipc	a0,0x3
    800053aa:	41a50513          	addi	a0,a0,1050 # 800087c0 <userret+0x730>
    800053ae:	ffffb097          	auipc	ra,0xffffb
    800053b2:	19a080e7          	jalr	410(ra) # 80000548 <panic>
    panic("create: dirlink");
    800053b6:	00003517          	auipc	a0,0x3
    800053ba:	41a50513          	addi	a0,a0,1050 # 800087d0 <userret+0x740>
    800053be:	ffffb097          	auipc	ra,0xffffb
    800053c2:	18a080e7          	jalr	394(ra) # 80000548 <panic>
    return 0;
    800053c6:	84aa                	mv	s1,a0
    800053c8:	b739                	j	800052d6 <create+0x72>

00000000800053ca <sys_dup>:
{
    800053ca:	7179                	addi	sp,sp,-48
    800053cc:	f406                	sd	ra,40(sp)
    800053ce:	f022                	sd	s0,32(sp)
    800053d0:	ec26                	sd	s1,24(sp)
    800053d2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053d4:	fd840613          	addi	a2,s0,-40
    800053d8:	4581                	li	a1,0
    800053da:	4501                	li	a0,0
    800053dc:	00000097          	auipc	ra,0x0
    800053e0:	dde080e7          	jalr	-546(ra) # 800051ba <argfd>
    return -1;
    800053e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053e6:	02054363          	bltz	a0,8000540c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053ea:	fd843503          	ld	a0,-40(s0)
    800053ee:	00000097          	auipc	ra,0x0
    800053f2:	e34080e7          	jalr	-460(ra) # 80005222 <fdalloc>
    800053f6:	84aa                	mv	s1,a0
    return -1;
    800053f8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053fa:	00054963          	bltz	a0,8000540c <sys_dup+0x42>
  filedup(f);
    800053fe:	fd843503          	ld	a0,-40(s0)
    80005402:	fffff097          	auipc	ra,0xfffff
    80005406:	310080e7          	jalr	784(ra) # 80004712 <filedup>
  return fd;
    8000540a:	87a6                	mv	a5,s1
}
    8000540c:	853e                	mv	a0,a5
    8000540e:	70a2                	ld	ra,40(sp)
    80005410:	7402                	ld	s0,32(sp)
    80005412:	64e2                	ld	s1,24(sp)
    80005414:	6145                	addi	sp,sp,48
    80005416:	8082                	ret

0000000080005418 <sys_read>:
{
    80005418:	7179                	addi	sp,sp,-48
    8000541a:	f406                	sd	ra,40(sp)
    8000541c:	f022                	sd	s0,32(sp)
    8000541e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005420:	fe840613          	addi	a2,s0,-24
    80005424:	4581                	li	a1,0
    80005426:	4501                	li	a0,0
    80005428:	00000097          	auipc	ra,0x0
    8000542c:	d92080e7          	jalr	-622(ra) # 800051ba <argfd>
    return -1;
    80005430:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005432:	04054163          	bltz	a0,80005474 <sys_read+0x5c>
    80005436:	fe440593          	addi	a1,s0,-28
    8000543a:	4509                	li	a0,2
    8000543c:	ffffd097          	auipc	ra,0xffffd
    80005440:	6c6080e7          	jalr	1734(ra) # 80002b02 <argint>
    return -1;
    80005444:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005446:	02054763          	bltz	a0,80005474 <sys_read+0x5c>
    8000544a:	fd840593          	addi	a1,s0,-40
    8000544e:	4505                	li	a0,1
    80005450:	ffffd097          	auipc	ra,0xffffd
    80005454:	6d4080e7          	jalr	1748(ra) # 80002b24 <argaddr>
    return -1;
    80005458:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000545a:	00054d63          	bltz	a0,80005474 <sys_read+0x5c>
  return fileread(f, p, n);
    8000545e:	fe442603          	lw	a2,-28(s0)
    80005462:	fd843583          	ld	a1,-40(s0)
    80005466:	fe843503          	ld	a0,-24(s0)
    8000546a:	fffff097          	auipc	ra,0xfffff
    8000546e:	43c080e7          	jalr	1084(ra) # 800048a6 <fileread>
    80005472:	87aa                	mv	a5,a0
}
    80005474:	853e                	mv	a0,a5
    80005476:	70a2                	ld	ra,40(sp)
    80005478:	7402                	ld	s0,32(sp)
    8000547a:	6145                	addi	sp,sp,48
    8000547c:	8082                	ret

000000008000547e <sys_write>:
{
    8000547e:	7179                	addi	sp,sp,-48
    80005480:	f406                	sd	ra,40(sp)
    80005482:	f022                	sd	s0,32(sp)
    80005484:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005486:	fe840613          	addi	a2,s0,-24
    8000548a:	4581                	li	a1,0
    8000548c:	4501                	li	a0,0
    8000548e:	00000097          	auipc	ra,0x0
    80005492:	d2c080e7          	jalr	-724(ra) # 800051ba <argfd>
    return -1;
    80005496:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005498:	04054163          	bltz	a0,800054da <sys_write+0x5c>
    8000549c:	fe440593          	addi	a1,s0,-28
    800054a0:	4509                	li	a0,2
    800054a2:	ffffd097          	auipc	ra,0xffffd
    800054a6:	660080e7          	jalr	1632(ra) # 80002b02 <argint>
    return -1;
    800054aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ac:	02054763          	bltz	a0,800054da <sys_write+0x5c>
    800054b0:	fd840593          	addi	a1,s0,-40
    800054b4:	4505                	li	a0,1
    800054b6:	ffffd097          	auipc	ra,0xffffd
    800054ba:	66e080e7          	jalr	1646(ra) # 80002b24 <argaddr>
    return -1;
    800054be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054c0:	00054d63          	bltz	a0,800054da <sys_write+0x5c>
  return filewrite(f, p, n);
    800054c4:	fe442603          	lw	a2,-28(s0)
    800054c8:	fd843583          	ld	a1,-40(s0)
    800054cc:	fe843503          	ld	a0,-24(s0)
    800054d0:	fffff097          	auipc	ra,0xfffff
    800054d4:	49c080e7          	jalr	1180(ra) # 8000496c <filewrite>
    800054d8:	87aa                	mv	a5,a0
}
    800054da:	853e                	mv	a0,a5
    800054dc:	70a2                	ld	ra,40(sp)
    800054de:	7402                	ld	s0,32(sp)
    800054e0:	6145                	addi	sp,sp,48
    800054e2:	8082                	ret

00000000800054e4 <sys_close>:
{
    800054e4:	1101                	addi	sp,sp,-32
    800054e6:	ec06                	sd	ra,24(sp)
    800054e8:	e822                	sd	s0,16(sp)
    800054ea:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054ec:	fe040613          	addi	a2,s0,-32
    800054f0:	fec40593          	addi	a1,s0,-20
    800054f4:	4501                	li	a0,0
    800054f6:	00000097          	auipc	ra,0x0
    800054fa:	cc4080e7          	jalr	-828(ra) # 800051ba <argfd>
    return -1;
    800054fe:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005500:	02054463          	bltz	a0,80005528 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005504:	ffffc097          	auipc	ra,0xffffc
    80005508:	526080e7          	jalr	1318(ra) # 80001a2a <myproc>
    8000550c:	fec42783          	lw	a5,-20(s0)
    80005510:	07e9                	addi	a5,a5,26
    80005512:	078e                	slli	a5,a5,0x3
    80005514:	97aa                	add	a5,a5,a0
    80005516:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000551a:	fe043503          	ld	a0,-32(s0)
    8000551e:	fffff097          	auipc	ra,0xfffff
    80005522:	246080e7          	jalr	582(ra) # 80004764 <fileclose>
  return 0;
    80005526:	4781                	li	a5,0
}
    80005528:	853e                	mv	a0,a5
    8000552a:	60e2                	ld	ra,24(sp)
    8000552c:	6442                	ld	s0,16(sp)
    8000552e:	6105                	addi	sp,sp,32
    80005530:	8082                	ret

0000000080005532 <sys_fstat>:
{
    80005532:	1101                	addi	sp,sp,-32
    80005534:	ec06                	sd	ra,24(sp)
    80005536:	e822                	sd	s0,16(sp)
    80005538:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000553a:	fe840613          	addi	a2,s0,-24
    8000553e:	4581                	li	a1,0
    80005540:	4501                	li	a0,0
    80005542:	00000097          	auipc	ra,0x0
    80005546:	c78080e7          	jalr	-904(ra) # 800051ba <argfd>
    return -1;
    8000554a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000554c:	02054563          	bltz	a0,80005576 <sys_fstat+0x44>
    80005550:	fe040593          	addi	a1,s0,-32
    80005554:	4505                	li	a0,1
    80005556:	ffffd097          	auipc	ra,0xffffd
    8000555a:	5ce080e7          	jalr	1486(ra) # 80002b24 <argaddr>
    return -1;
    8000555e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005560:	00054b63          	bltz	a0,80005576 <sys_fstat+0x44>
  return filestat(f, st);
    80005564:	fe043583          	ld	a1,-32(s0)
    80005568:	fe843503          	ld	a0,-24(s0)
    8000556c:	fffff097          	auipc	ra,0xfffff
    80005570:	2c8080e7          	jalr	712(ra) # 80004834 <filestat>
    80005574:	87aa                	mv	a5,a0
}
    80005576:	853e                	mv	a0,a5
    80005578:	60e2                	ld	ra,24(sp)
    8000557a:	6442                	ld	s0,16(sp)
    8000557c:	6105                	addi	sp,sp,32
    8000557e:	8082                	ret

0000000080005580 <sys_link>:
{
    80005580:	7169                	addi	sp,sp,-304
    80005582:	f606                	sd	ra,296(sp)
    80005584:	f222                	sd	s0,288(sp)
    80005586:	ee26                	sd	s1,280(sp)
    80005588:	ea4a                	sd	s2,272(sp)
    8000558a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000558c:	08000613          	li	a2,128
    80005590:	ed040593          	addi	a1,s0,-304
    80005594:	4501                	li	a0,0
    80005596:	ffffd097          	auipc	ra,0xffffd
    8000559a:	5b0080e7          	jalr	1456(ra) # 80002b46 <argstr>
    return -1;
    8000559e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055a0:	12054363          	bltz	a0,800056c6 <sys_link+0x146>
    800055a4:	08000613          	li	a2,128
    800055a8:	f5040593          	addi	a1,s0,-176
    800055ac:	4505                	li	a0,1
    800055ae:	ffffd097          	auipc	ra,0xffffd
    800055b2:	598080e7          	jalr	1432(ra) # 80002b46 <argstr>
    return -1;
    800055b6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055b8:	10054763          	bltz	a0,800056c6 <sys_link+0x146>
  begin_op(ROOTDEV);
    800055bc:	4501                	li	a0,0
    800055be:	fffff097          	auipc	ra,0xfffff
    800055c2:	b7e080e7          	jalr	-1154(ra) # 8000413c <begin_op>
  if((ip = namei(old)) == 0){
    800055c6:	ed040513          	addi	a0,s0,-304
    800055ca:	fffff097          	auipc	ra,0xfffff
    800055ce:	856080e7          	jalr	-1962(ra) # 80003e20 <namei>
    800055d2:	84aa                	mv	s1,a0
    800055d4:	c559                	beqz	a0,80005662 <sys_link+0xe2>
  ilock(ip);
    800055d6:	ffffe097          	auipc	ra,0xffffe
    800055da:	0c0080e7          	jalr	192(ra) # 80003696 <ilock>
  if(ip->type == T_DIR){
    800055de:	04449703          	lh	a4,68(s1)
    800055e2:	4785                	li	a5,1
    800055e4:	08f70663          	beq	a4,a5,80005670 <sys_link+0xf0>
  ip->nlink++;
    800055e8:	04a4d783          	lhu	a5,74(s1)
    800055ec:	2785                	addiw	a5,a5,1
    800055ee:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055f2:	8526                	mv	a0,s1
    800055f4:	ffffe097          	auipc	ra,0xffffe
    800055f8:	fd8080e7          	jalr	-40(ra) # 800035cc <iupdate>
  iunlock(ip);
    800055fc:	8526                	mv	a0,s1
    800055fe:	ffffe097          	auipc	ra,0xffffe
    80005602:	15a080e7          	jalr	346(ra) # 80003758 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005606:	fd040593          	addi	a1,s0,-48
    8000560a:	f5040513          	addi	a0,s0,-176
    8000560e:	fffff097          	auipc	ra,0xfffff
    80005612:	830080e7          	jalr	-2000(ra) # 80003e3e <nameiparent>
    80005616:	892a                	mv	s2,a0
    80005618:	cd2d                	beqz	a0,80005692 <sys_link+0x112>
  ilock(dp);
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	07c080e7          	jalr	124(ra) # 80003696 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005622:	00092703          	lw	a4,0(s2)
    80005626:	409c                	lw	a5,0(s1)
    80005628:	06f71063          	bne	a4,a5,80005688 <sys_link+0x108>
    8000562c:	40d0                	lw	a2,4(s1)
    8000562e:	fd040593          	addi	a1,s0,-48
    80005632:	854a                	mv	a0,s2
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	72a080e7          	jalr	1834(ra) # 80003d5e <dirlink>
    8000563c:	04054663          	bltz	a0,80005688 <sys_link+0x108>
  iunlockput(dp);
    80005640:	854a                	mv	a0,s2
    80005642:	ffffe097          	auipc	ra,0xffffe
    80005646:	292080e7          	jalr	658(ra) # 800038d4 <iunlockput>
  iput(ip);
    8000564a:	8526                	mv	a0,s1
    8000564c:	ffffe097          	auipc	ra,0xffffe
    80005650:	158080e7          	jalr	344(ra) # 800037a4 <iput>
  end_op(ROOTDEV);
    80005654:	4501                	li	a0,0
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	b90080e7          	jalr	-1136(ra) # 800041e6 <end_op>
  return 0;
    8000565e:	4781                	li	a5,0
    80005660:	a09d                	j	800056c6 <sys_link+0x146>
    end_op(ROOTDEV);
    80005662:	4501                	li	a0,0
    80005664:	fffff097          	auipc	ra,0xfffff
    80005668:	b82080e7          	jalr	-1150(ra) # 800041e6 <end_op>
    return -1;
    8000566c:	57fd                	li	a5,-1
    8000566e:	a8a1                	j	800056c6 <sys_link+0x146>
    iunlockput(ip);
    80005670:	8526                	mv	a0,s1
    80005672:	ffffe097          	auipc	ra,0xffffe
    80005676:	262080e7          	jalr	610(ra) # 800038d4 <iunlockput>
    end_op(ROOTDEV);
    8000567a:	4501                	li	a0,0
    8000567c:	fffff097          	auipc	ra,0xfffff
    80005680:	b6a080e7          	jalr	-1174(ra) # 800041e6 <end_op>
    return -1;
    80005684:	57fd                	li	a5,-1
    80005686:	a081                	j	800056c6 <sys_link+0x146>
    iunlockput(dp);
    80005688:	854a                	mv	a0,s2
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	24a080e7          	jalr	586(ra) # 800038d4 <iunlockput>
  ilock(ip);
    80005692:	8526                	mv	a0,s1
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	002080e7          	jalr	2(ra) # 80003696 <ilock>
  ip->nlink--;
    8000569c:	04a4d783          	lhu	a5,74(s1)
    800056a0:	37fd                	addiw	a5,a5,-1
    800056a2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056a6:	8526                	mv	a0,s1
    800056a8:	ffffe097          	auipc	ra,0xffffe
    800056ac:	f24080e7          	jalr	-220(ra) # 800035cc <iupdate>
  iunlockput(ip);
    800056b0:	8526                	mv	a0,s1
    800056b2:	ffffe097          	auipc	ra,0xffffe
    800056b6:	222080e7          	jalr	546(ra) # 800038d4 <iunlockput>
  end_op(ROOTDEV);
    800056ba:	4501                	li	a0,0
    800056bc:	fffff097          	auipc	ra,0xfffff
    800056c0:	b2a080e7          	jalr	-1238(ra) # 800041e6 <end_op>
  return -1;
    800056c4:	57fd                	li	a5,-1
}
    800056c6:	853e                	mv	a0,a5
    800056c8:	70b2                	ld	ra,296(sp)
    800056ca:	7412                	ld	s0,288(sp)
    800056cc:	64f2                	ld	s1,280(sp)
    800056ce:	6952                	ld	s2,272(sp)
    800056d0:	6155                	addi	sp,sp,304
    800056d2:	8082                	ret

00000000800056d4 <sys_unlink>:
{
    800056d4:	7151                	addi	sp,sp,-240
    800056d6:	f586                	sd	ra,232(sp)
    800056d8:	f1a2                	sd	s0,224(sp)
    800056da:	eda6                	sd	s1,216(sp)
    800056dc:	e9ca                	sd	s2,208(sp)
    800056de:	e5ce                	sd	s3,200(sp)
    800056e0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056e2:	08000613          	li	a2,128
    800056e6:	f3040593          	addi	a1,s0,-208
    800056ea:	4501                	li	a0,0
    800056ec:	ffffd097          	auipc	ra,0xffffd
    800056f0:	45a080e7          	jalr	1114(ra) # 80002b46 <argstr>
    800056f4:	18054463          	bltz	a0,8000587c <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    800056f8:	4501                	li	a0,0
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	a42080e7          	jalr	-1470(ra) # 8000413c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005702:	fb040593          	addi	a1,s0,-80
    80005706:	f3040513          	addi	a0,s0,-208
    8000570a:	ffffe097          	auipc	ra,0xffffe
    8000570e:	734080e7          	jalr	1844(ra) # 80003e3e <nameiparent>
    80005712:	84aa                	mv	s1,a0
    80005714:	cd61                	beqz	a0,800057ec <sys_unlink+0x118>
  ilock(dp);
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	f80080e7          	jalr	-128(ra) # 80003696 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000571e:	00003597          	auipc	a1,0x3
    80005722:	09258593          	addi	a1,a1,146 # 800087b0 <userret+0x720>
    80005726:	fb040513          	addi	a0,s0,-80
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	40a080e7          	jalr	1034(ra) # 80003b34 <namecmp>
    80005732:	14050c63          	beqz	a0,8000588a <sys_unlink+0x1b6>
    80005736:	00003597          	auipc	a1,0x3
    8000573a:	08258593          	addi	a1,a1,130 # 800087b8 <userret+0x728>
    8000573e:	fb040513          	addi	a0,s0,-80
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	3f2080e7          	jalr	1010(ra) # 80003b34 <namecmp>
    8000574a:	14050063          	beqz	a0,8000588a <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000574e:	f2c40613          	addi	a2,s0,-212
    80005752:	fb040593          	addi	a1,s0,-80
    80005756:	8526                	mv	a0,s1
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	3f6080e7          	jalr	1014(ra) # 80003b4e <dirlookup>
    80005760:	892a                	mv	s2,a0
    80005762:	12050463          	beqz	a0,8000588a <sys_unlink+0x1b6>
  ilock(ip);
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	f30080e7          	jalr	-208(ra) # 80003696 <ilock>
  if(ip->nlink < 1)
    8000576e:	04a91783          	lh	a5,74(s2)
    80005772:	08f05463          	blez	a5,800057fa <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005776:	04491703          	lh	a4,68(s2)
    8000577a:	4785                	li	a5,1
    8000577c:	08f70763          	beq	a4,a5,8000580a <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005780:	4641                	li	a2,16
    80005782:	4581                	li	a1,0
    80005784:	fc040513          	addi	a0,s0,-64
    80005788:	ffffb097          	auipc	ra,0xffffb
    8000578c:	3fa080e7          	jalr	1018(ra) # 80000b82 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005790:	4741                	li	a4,16
    80005792:	f2c42683          	lw	a3,-212(s0)
    80005796:	fc040613          	addi	a2,s0,-64
    8000579a:	4581                	li	a1,0
    8000579c:	8526                	mv	a0,s1
    8000579e:	ffffe097          	auipc	ra,0xffffe
    800057a2:	27c080e7          	jalr	636(ra) # 80003a1a <writei>
    800057a6:	47c1                	li	a5,16
    800057a8:	0af51763          	bne	a0,a5,80005856 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    800057ac:	04491703          	lh	a4,68(s2)
    800057b0:	4785                	li	a5,1
    800057b2:	0af70a63          	beq	a4,a5,80005866 <sys_unlink+0x192>
  iunlockput(dp);
    800057b6:	8526                	mv	a0,s1
    800057b8:	ffffe097          	auipc	ra,0xffffe
    800057bc:	11c080e7          	jalr	284(ra) # 800038d4 <iunlockput>
  ip->nlink--;
    800057c0:	04a95783          	lhu	a5,74(s2)
    800057c4:	37fd                	addiw	a5,a5,-1
    800057c6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057ca:	854a                	mv	a0,s2
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	e00080e7          	jalr	-512(ra) # 800035cc <iupdate>
  iunlockput(ip);
    800057d4:	854a                	mv	a0,s2
    800057d6:	ffffe097          	auipc	ra,0xffffe
    800057da:	0fe080e7          	jalr	254(ra) # 800038d4 <iunlockput>
  end_op(ROOTDEV);
    800057de:	4501                	li	a0,0
    800057e0:	fffff097          	auipc	ra,0xfffff
    800057e4:	a06080e7          	jalr	-1530(ra) # 800041e6 <end_op>
  return 0;
    800057e8:	4501                	li	a0,0
    800057ea:	a85d                	j	800058a0 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    800057ec:	4501                	li	a0,0
    800057ee:	fffff097          	auipc	ra,0xfffff
    800057f2:	9f8080e7          	jalr	-1544(ra) # 800041e6 <end_op>
    return -1;
    800057f6:	557d                	li	a0,-1
    800057f8:	a065                	j	800058a0 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    800057fa:	00003517          	auipc	a0,0x3
    800057fe:	fe650513          	addi	a0,a0,-26 # 800087e0 <userret+0x750>
    80005802:	ffffb097          	auipc	ra,0xffffb
    80005806:	d46080e7          	jalr	-698(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000580a:	04c92703          	lw	a4,76(s2)
    8000580e:	02000793          	li	a5,32
    80005812:	f6e7f7e3          	bgeu	a5,a4,80005780 <sys_unlink+0xac>
    80005816:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000581a:	4741                	li	a4,16
    8000581c:	86ce                	mv	a3,s3
    8000581e:	f1840613          	addi	a2,s0,-232
    80005822:	4581                	li	a1,0
    80005824:	854a                	mv	a0,s2
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	100080e7          	jalr	256(ra) # 80003926 <readi>
    8000582e:	47c1                	li	a5,16
    80005830:	00f51b63          	bne	a0,a5,80005846 <sys_unlink+0x172>
    if(de.inum != 0)
    80005834:	f1845783          	lhu	a5,-232(s0)
    80005838:	e7a1                	bnez	a5,80005880 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000583a:	29c1                	addiw	s3,s3,16
    8000583c:	04c92783          	lw	a5,76(s2)
    80005840:	fcf9ede3          	bltu	s3,a5,8000581a <sys_unlink+0x146>
    80005844:	bf35                	j	80005780 <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005846:	00003517          	auipc	a0,0x3
    8000584a:	fb250513          	addi	a0,a0,-78 # 800087f8 <userret+0x768>
    8000584e:	ffffb097          	auipc	ra,0xffffb
    80005852:	cfa080e7          	jalr	-774(ra) # 80000548 <panic>
    panic("unlink: writei");
    80005856:	00003517          	auipc	a0,0x3
    8000585a:	fba50513          	addi	a0,a0,-70 # 80008810 <userret+0x780>
    8000585e:	ffffb097          	auipc	ra,0xffffb
    80005862:	cea080e7          	jalr	-790(ra) # 80000548 <panic>
    dp->nlink--;
    80005866:	04a4d783          	lhu	a5,74(s1)
    8000586a:	37fd                	addiw	a5,a5,-1
    8000586c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005870:	8526                	mv	a0,s1
    80005872:	ffffe097          	auipc	ra,0xffffe
    80005876:	d5a080e7          	jalr	-678(ra) # 800035cc <iupdate>
    8000587a:	bf35                	j	800057b6 <sys_unlink+0xe2>
    return -1;
    8000587c:	557d                	li	a0,-1
    8000587e:	a00d                	j	800058a0 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005880:	854a                	mv	a0,s2
    80005882:	ffffe097          	auipc	ra,0xffffe
    80005886:	052080e7          	jalr	82(ra) # 800038d4 <iunlockput>
  iunlockput(dp);
    8000588a:	8526                	mv	a0,s1
    8000588c:	ffffe097          	auipc	ra,0xffffe
    80005890:	048080e7          	jalr	72(ra) # 800038d4 <iunlockput>
  end_op(ROOTDEV);
    80005894:	4501                	li	a0,0
    80005896:	fffff097          	auipc	ra,0xfffff
    8000589a:	950080e7          	jalr	-1712(ra) # 800041e6 <end_op>
  return -1;
    8000589e:	557d                	li	a0,-1
}
    800058a0:	70ae                	ld	ra,232(sp)
    800058a2:	740e                	ld	s0,224(sp)
    800058a4:	64ee                	ld	s1,216(sp)
    800058a6:	694e                	ld	s2,208(sp)
    800058a8:	69ae                	ld	s3,200(sp)
    800058aa:	616d                	addi	sp,sp,240
    800058ac:	8082                	ret

00000000800058ae <sys_open>:

uint64
sys_open(void)
{
    800058ae:	7131                	addi	sp,sp,-192
    800058b0:	fd06                	sd	ra,184(sp)
    800058b2:	f922                	sd	s0,176(sp)
    800058b4:	f526                	sd	s1,168(sp)
    800058b6:	f14a                	sd	s2,160(sp)
    800058b8:	ed4e                	sd	s3,152(sp)
    800058ba:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058bc:	08000613          	li	a2,128
    800058c0:	f5040593          	addi	a1,s0,-176
    800058c4:	4501                	li	a0,0
    800058c6:	ffffd097          	auipc	ra,0xffffd
    800058ca:	280080e7          	jalr	640(ra) # 80002b46 <argstr>
    return -1;
    800058ce:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058d0:	0a054963          	bltz	a0,80005982 <sys_open+0xd4>
    800058d4:	f4c40593          	addi	a1,s0,-180
    800058d8:	4505                	li	a0,1
    800058da:	ffffd097          	auipc	ra,0xffffd
    800058de:	228080e7          	jalr	552(ra) # 80002b02 <argint>
    800058e2:	0a054063          	bltz	a0,80005982 <sys_open+0xd4>

  begin_op(ROOTDEV);
    800058e6:	4501                	li	a0,0
    800058e8:	fffff097          	auipc	ra,0xfffff
    800058ec:	854080e7          	jalr	-1964(ra) # 8000413c <begin_op>

  if(omode & O_CREATE){
    800058f0:	f4c42783          	lw	a5,-180(s0)
    800058f4:	2007f793          	andi	a5,a5,512
    800058f8:	c3dd                	beqz	a5,8000599e <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    800058fa:	4681                	li	a3,0
    800058fc:	4601                	li	a2,0
    800058fe:	4589                	li	a1,2
    80005900:	f5040513          	addi	a0,s0,-176
    80005904:	00000097          	auipc	ra,0x0
    80005908:	960080e7          	jalr	-1696(ra) # 80005264 <create>
    8000590c:	892a                	mv	s2,a0
    if(ip == 0){
    8000590e:	c151                	beqz	a0,80005992 <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005910:	04491703          	lh	a4,68(s2)
    80005914:	478d                	li	a5,3
    80005916:	00f71763          	bne	a4,a5,80005924 <sys_open+0x76>
    8000591a:	04695703          	lhu	a4,70(s2)
    8000591e:	47a5                	li	a5,9
    80005920:	0ce7e663          	bltu	a5,a4,800059ec <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005924:	fffff097          	auipc	ra,0xfffff
    80005928:	d84080e7          	jalr	-636(ra) # 800046a8 <filealloc>
    8000592c:	89aa                	mv	s3,a0
    8000592e:	c97d                	beqz	a0,80005a24 <sys_open+0x176>
    80005930:	00000097          	auipc	ra,0x0
    80005934:	8f2080e7          	jalr	-1806(ra) # 80005222 <fdalloc>
    80005938:	84aa                	mv	s1,a0
    8000593a:	0e054063          	bltz	a0,80005a1a <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000593e:	04491703          	lh	a4,68(s2)
    80005942:	478d                	li	a5,3
    80005944:	0cf70063          	beq	a4,a5,80005a04 <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005948:	4789                	li	a5,2
    8000594a:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    8000594e:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005952:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005956:	f4c42783          	lw	a5,-180(s0)
    8000595a:	0017c713          	xori	a4,a5,1
    8000595e:	8b05                	andi	a4,a4,1
    80005960:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005964:	8b8d                	andi	a5,a5,3
    80005966:	00f037b3          	snez	a5,a5
    8000596a:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    8000596e:	854a                	mv	a0,s2
    80005970:	ffffe097          	auipc	ra,0xffffe
    80005974:	de8080e7          	jalr	-536(ra) # 80003758 <iunlock>
  end_op(ROOTDEV);
    80005978:	4501                	li	a0,0
    8000597a:	fffff097          	auipc	ra,0xfffff
    8000597e:	86c080e7          	jalr	-1940(ra) # 800041e6 <end_op>

  return fd;
}
    80005982:	8526                	mv	a0,s1
    80005984:	70ea                	ld	ra,184(sp)
    80005986:	744a                	ld	s0,176(sp)
    80005988:	74aa                	ld	s1,168(sp)
    8000598a:	790a                	ld	s2,160(sp)
    8000598c:	69ea                	ld	s3,152(sp)
    8000598e:	6129                	addi	sp,sp,192
    80005990:	8082                	ret
      end_op(ROOTDEV);
    80005992:	4501                	li	a0,0
    80005994:	fffff097          	auipc	ra,0xfffff
    80005998:	852080e7          	jalr	-1966(ra) # 800041e6 <end_op>
      return -1;
    8000599c:	b7dd                	j	80005982 <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    8000599e:	f5040513          	addi	a0,s0,-176
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	47e080e7          	jalr	1150(ra) # 80003e20 <namei>
    800059aa:	892a                	mv	s2,a0
    800059ac:	c90d                	beqz	a0,800059de <sys_open+0x130>
    ilock(ip);
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	ce8080e7          	jalr	-792(ra) # 80003696 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059b6:	04491703          	lh	a4,68(s2)
    800059ba:	4785                	li	a5,1
    800059bc:	f4f71ae3          	bne	a4,a5,80005910 <sys_open+0x62>
    800059c0:	f4c42783          	lw	a5,-180(s0)
    800059c4:	d3a5                	beqz	a5,80005924 <sys_open+0x76>
      iunlockput(ip);
    800059c6:	854a                	mv	a0,s2
    800059c8:	ffffe097          	auipc	ra,0xffffe
    800059cc:	f0c080e7          	jalr	-244(ra) # 800038d4 <iunlockput>
      end_op(ROOTDEV);
    800059d0:	4501                	li	a0,0
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	814080e7          	jalr	-2028(ra) # 800041e6 <end_op>
      return -1;
    800059da:	54fd                	li	s1,-1
    800059dc:	b75d                	j	80005982 <sys_open+0xd4>
      end_op(ROOTDEV);
    800059de:	4501                	li	a0,0
    800059e0:	fffff097          	auipc	ra,0xfffff
    800059e4:	806080e7          	jalr	-2042(ra) # 800041e6 <end_op>
      return -1;
    800059e8:	54fd                	li	s1,-1
    800059ea:	bf61                	j	80005982 <sys_open+0xd4>
    iunlockput(ip);
    800059ec:	854a                	mv	a0,s2
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	ee6080e7          	jalr	-282(ra) # 800038d4 <iunlockput>
    end_op(ROOTDEV);
    800059f6:	4501                	li	a0,0
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	7ee080e7          	jalr	2030(ra) # 800041e6 <end_op>
    return -1;
    80005a00:	54fd                	li	s1,-1
    80005a02:	b741                	j	80005982 <sys_open+0xd4>
    f->type = FD_DEVICE;
    80005a04:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a08:	04691783          	lh	a5,70(s2)
    80005a0c:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005a10:	04891783          	lh	a5,72(s2)
    80005a14:	02f99323          	sh	a5,38(s3)
    80005a18:	bf1d                	j	8000594e <sys_open+0xa0>
      fileclose(f);
    80005a1a:	854e                	mv	a0,s3
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	d48080e7          	jalr	-696(ra) # 80004764 <fileclose>
    iunlockput(ip);
    80005a24:	854a                	mv	a0,s2
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	eae080e7          	jalr	-338(ra) # 800038d4 <iunlockput>
    end_op(ROOTDEV);
    80005a2e:	4501                	li	a0,0
    80005a30:	ffffe097          	auipc	ra,0xffffe
    80005a34:	7b6080e7          	jalr	1974(ra) # 800041e6 <end_op>
    return -1;
    80005a38:	54fd                	li	s1,-1
    80005a3a:	b7a1                	j	80005982 <sys_open+0xd4>

0000000080005a3c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a3c:	7175                	addi	sp,sp,-144
    80005a3e:	e506                	sd	ra,136(sp)
    80005a40:	e122                	sd	s0,128(sp)
    80005a42:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005a44:	4501                	li	a0,0
    80005a46:	ffffe097          	auipc	ra,0xffffe
    80005a4a:	6f6080e7          	jalr	1782(ra) # 8000413c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a4e:	08000613          	li	a2,128
    80005a52:	f7040593          	addi	a1,s0,-144
    80005a56:	4501                	li	a0,0
    80005a58:	ffffd097          	auipc	ra,0xffffd
    80005a5c:	0ee080e7          	jalr	238(ra) # 80002b46 <argstr>
    80005a60:	02054a63          	bltz	a0,80005a94 <sys_mkdir+0x58>
    80005a64:	4681                	li	a3,0
    80005a66:	4601                	li	a2,0
    80005a68:	4585                	li	a1,1
    80005a6a:	f7040513          	addi	a0,s0,-144
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	7f6080e7          	jalr	2038(ra) # 80005264 <create>
    80005a76:	cd19                	beqz	a0,80005a94 <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005a78:	ffffe097          	auipc	ra,0xffffe
    80005a7c:	e5c080e7          	jalr	-420(ra) # 800038d4 <iunlockput>
  end_op(ROOTDEV);
    80005a80:	4501                	li	a0,0
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	764080e7          	jalr	1892(ra) # 800041e6 <end_op>
  return 0;
    80005a8a:	4501                	li	a0,0
}
    80005a8c:	60aa                	ld	ra,136(sp)
    80005a8e:	640a                	ld	s0,128(sp)
    80005a90:	6149                	addi	sp,sp,144
    80005a92:	8082                	ret
    end_op(ROOTDEV);
    80005a94:	4501                	li	a0,0
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	750080e7          	jalr	1872(ra) # 800041e6 <end_op>
    return -1;
    80005a9e:	557d                	li	a0,-1
    80005aa0:	b7f5                	j	80005a8c <sys_mkdir+0x50>

0000000080005aa2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005aa2:	7135                	addi	sp,sp,-160
    80005aa4:	ed06                	sd	ra,152(sp)
    80005aa6:	e922                	sd	s0,144(sp)
    80005aa8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005aaa:	4501                	li	a0,0
    80005aac:	ffffe097          	auipc	ra,0xffffe
    80005ab0:	690080e7          	jalr	1680(ra) # 8000413c <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ab4:	08000613          	li	a2,128
    80005ab8:	f7040593          	addi	a1,s0,-144
    80005abc:	4501                	li	a0,0
    80005abe:	ffffd097          	auipc	ra,0xffffd
    80005ac2:	088080e7          	jalr	136(ra) # 80002b46 <argstr>
    80005ac6:	04054b63          	bltz	a0,80005b1c <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80005aca:	f6c40593          	addi	a1,s0,-148
    80005ace:	4505                	li	a0,1
    80005ad0:	ffffd097          	auipc	ra,0xffffd
    80005ad4:	032080e7          	jalr	50(ra) # 80002b02 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ad8:	04054263          	bltz	a0,80005b1c <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005adc:	f6840593          	addi	a1,s0,-152
    80005ae0:	4509                	li	a0,2
    80005ae2:	ffffd097          	auipc	ra,0xffffd
    80005ae6:	020080e7          	jalr	32(ra) # 80002b02 <argint>
     argint(1, &major) < 0 ||
    80005aea:	02054963          	bltz	a0,80005b1c <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005aee:	f6841683          	lh	a3,-152(s0)
    80005af2:	f6c41603          	lh	a2,-148(s0)
    80005af6:	458d                	li	a1,3
    80005af8:	f7040513          	addi	a0,s0,-144
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	768080e7          	jalr	1896(ra) # 80005264 <create>
     argint(2, &minor) < 0 ||
    80005b04:	cd01                	beqz	a0,80005b1c <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005b06:	ffffe097          	auipc	ra,0xffffe
    80005b0a:	dce080e7          	jalr	-562(ra) # 800038d4 <iunlockput>
  end_op(ROOTDEV);
    80005b0e:	4501                	li	a0,0
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	6d6080e7          	jalr	1750(ra) # 800041e6 <end_op>
  return 0;
    80005b18:	4501                	li	a0,0
    80005b1a:	a039                	j	80005b28 <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005b1c:	4501                	li	a0,0
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	6c8080e7          	jalr	1736(ra) # 800041e6 <end_op>
    return -1;
    80005b26:	557d                	li	a0,-1
}
    80005b28:	60ea                	ld	ra,152(sp)
    80005b2a:	644a                	ld	s0,144(sp)
    80005b2c:	610d                	addi	sp,sp,160
    80005b2e:	8082                	ret

0000000080005b30 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b30:	7135                	addi	sp,sp,-160
    80005b32:	ed06                	sd	ra,152(sp)
    80005b34:	e922                	sd	s0,144(sp)
    80005b36:	e526                	sd	s1,136(sp)
    80005b38:	e14a                	sd	s2,128(sp)
    80005b3a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b3c:	ffffc097          	auipc	ra,0xffffc
    80005b40:	eee080e7          	jalr	-274(ra) # 80001a2a <myproc>
    80005b44:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005b46:	4501                	li	a0,0
    80005b48:	ffffe097          	auipc	ra,0xffffe
    80005b4c:	5f4080e7          	jalr	1524(ra) # 8000413c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b50:	08000613          	li	a2,128
    80005b54:	f6040593          	addi	a1,s0,-160
    80005b58:	4501                	li	a0,0
    80005b5a:	ffffd097          	auipc	ra,0xffffd
    80005b5e:	fec080e7          	jalr	-20(ra) # 80002b46 <argstr>
    80005b62:	04054c63          	bltz	a0,80005bba <sys_chdir+0x8a>
    80005b66:	f6040513          	addi	a0,s0,-160
    80005b6a:	ffffe097          	auipc	ra,0xffffe
    80005b6e:	2b6080e7          	jalr	694(ra) # 80003e20 <namei>
    80005b72:	84aa                	mv	s1,a0
    80005b74:	c139                	beqz	a0,80005bba <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	b20080e7          	jalr	-1248(ra) # 80003696 <ilock>
  if(ip->type != T_DIR){
    80005b7e:	04449703          	lh	a4,68(s1)
    80005b82:	4785                	li	a5,1
    80005b84:	04f71263          	bne	a4,a5,80005bc8 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005b88:	8526                	mv	a0,s1
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	bce080e7          	jalr	-1074(ra) # 80003758 <iunlock>
  iput(p->cwd);
    80005b92:	15893503          	ld	a0,344(s2)
    80005b96:	ffffe097          	auipc	ra,0xffffe
    80005b9a:	c0e080e7          	jalr	-1010(ra) # 800037a4 <iput>
  end_op(ROOTDEV);
    80005b9e:	4501                	li	a0,0
    80005ba0:	ffffe097          	auipc	ra,0xffffe
    80005ba4:	646080e7          	jalr	1606(ra) # 800041e6 <end_op>
  p->cwd = ip;
    80005ba8:	14993c23          	sd	s1,344(s2)
  return 0;
    80005bac:	4501                	li	a0,0
}
    80005bae:	60ea                	ld	ra,152(sp)
    80005bb0:	644a                	ld	s0,144(sp)
    80005bb2:	64aa                	ld	s1,136(sp)
    80005bb4:	690a                	ld	s2,128(sp)
    80005bb6:	610d                	addi	sp,sp,160
    80005bb8:	8082                	ret
    end_op(ROOTDEV);
    80005bba:	4501                	li	a0,0
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	62a080e7          	jalr	1578(ra) # 800041e6 <end_op>
    return -1;
    80005bc4:	557d                	li	a0,-1
    80005bc6:	b7e5                	j	80005bae <sys_chdir+0x7e>
    iunlockput(ip);
    80005bc8:	8526                	mv	a0,s1
    80005bca:	ffffe097          	auipc	ra,0xffffe
    80005bce:	d0a080e7          	jalr	-758(ra) # 800038d4 <iunlockput>
    end_op(ROOTDEV);
    80005bd2:	4501                	li	a0,0
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	612080e7          	jalr	1554(ra) # 800041e6 <end_op>
    return -1;
    80005bdc:	557d                	li	a0,-1
    80005bde:	bfc1                	j	80005bae <sys_chdir+0x7e>

0000000080005be0 <sys_exec>:

uint64
sys_exec(void)
{
    80005be0:	7145                	addi	sp,sp,-464
    80005be2:	e786                	sd	ra,456(sp)
    80005be4:	e3a2                	sd	s0,448(sp)
    80005be6:	ff26                	sd	s1,440(sp)
    80005be8:	fb4a                	sd	s2,432(sp)
    80005bea:	f74e                	sd	s3,424(sp)
    80005bec:	f352                	sd	s4,416(sp)
    80005bee:	ef56                	sd	s5,408(sp)
    80005bf0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bf2:	08000613          	li	a2,128
    80005bf6:	f4040593          	addi	a1,s0,-192
    80005bfa:	4501                	li	a0,0
    80005bfc:	ffffd097          	auipc	ra,0xffffd
    80005c00:	f4a080e7          	jalr	-182(ra) # 80002b46 <argstr>
    80005c04:	0e054663          	bltz	a0,80005cf0 <sys_exec+0x110>
    80005c08:	e3840593          	addi	a1,s0,-456
    80005c0c:	4505                	li	a0,1
    80005c0e:	ffffd097          	auipc	ra,0xffffd
    80005c12:	f16080e7          	jalr	-234(ra) # 80002b24 <argaddr>
    80005c16:	0e054763          	bltz	a0,80005d04 <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005c1a:	10000613          	li	a2,256
    80005c1e:	4581                	li	a1,0
    80005c20:	e4040513          	addi	a0,s0,-448
    80005c24:	ffffb097          	auipc	ra,0xffffb
    80005c28:	f5e080e7          	jalr	-162(ra) # 80000b82 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c2c:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c30:	89ca                	mv	s3,s2
    80005c32:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005c34:	02000a13          	li	s4,32
    80005c38:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c3c:	00349793          	slli	a5,s1,0x3
    80005c40:	e3040593          	addi	a1,s0,-464
    80005c44:	e3843503          	ld	a0,-456(s0)
    80005c48:	953e                	add	a0,a0,a5
    80005c4a:	ffffd097          	auipc	ra,0xffffd
    80005c4e:	e1e080e7          	jalr	-482(ra) # 80002a68 <fetchaddr>
    80005c52:	02054a63          	bltz	a0,80005c86 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c56:	e3043783          	ld	a5,-464(s0)
    80005c5a:	c7a1                	beqz	a5,80005ca2 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c5c:	ffffb097          	auipc	ra,0xffffb
    80005c60:	cf4080e7          	jalr	-780(ra) # 80000950 <kalloc>
    80005c64:	85aa                	mv	a1,a0
    80005c66:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c6a:	c92d                	beqz	a0,80005cdc <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005c6c:	6605                	lui	a2,0x1
    80005c6e:	e3043503          	ld	a0,-464(s0)
    80005c72:	ffffd097          	auipc	ra,0xffffd
    80005c76:	e48080e7          	jalr	-440(ra) # 80002aba <fetchstr>
    80005c7a:	00054663          	bltz	a0,80005c86 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c7e:	0485                	addi	s1,s1,1
    80005c80:	09a1                	addi	s3,s3,8
    80005c82:	fb449be3          	bne	s1,s4,80005c38 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c86:	10090493          	addi	s1,s2,256
    80005c8a:	00093503          	ld	a0,0(s2)
    80005c8e:	cd39                	beqz	a0,80005cec <sys_exec+0x10c>
    kfree(argv[i]);
    80005c90:	ffffb097          	auipc	ra,0xffffb
    80005c94:	bc4080e7          	jalr	-1084(ra) # 80000854 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c98:	0921                	addi	s2,s2,8
    80005c9a:	fe9918e3          	bne	s2,s1,80005c8a <sys_exec+0xaa>
  return -1;
    80005c9e:	557d                	li	a0,-1
    80005ca0:	a889                	j	80005cf2 <sys_exec+0x112>
      argv[i] = 0;
    80005ca2:	0a8e                	slli	s5,s5,0x3
    80005ca4:	fc040793          	addi	a5,s0,-64
    80005ca8:	9abe                	add	s5,s5,a5
    80005caa:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005cae:	e4040593          	addi	a1,s0,-448
    80005cb2:	f4040513          	addi	a0,s0,-192
    80005cb6:	fffff097          	auipc	ra,0xfffff
    80005cba:	156080e7          	jalr	342(ra) # 80004e0c <exec>
    80005cbe:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cc0:	10090993          	addi	s3,s2,256
    80005cc4:	00093503          	ld	a0,0(s2)
    80005cc8:	c901                	beqz	a0,80005cd8 <sys_exec+0xf8>
    kfree(argv[i]);
    80005cca:	ffffb097          	auipc	ra,0xffffb
    80005cce:	b8a080e7          	jalr	-1142(ra) # 80000854 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cd2:	0921                	addi	s2,s2,8
    80005cd4:	ff3918e3          	bne	s2,s3,80005cc4 <sys_exec+0xe4>
  return ret;
    80005cd8:	8526                	mv	a0,s1
    80005cda:	a821                	j	80005cf2 <sys_exec+0x112>
      panic("sys_exec kalloc");
    80005cdc:	00003517          	auipc	a0,0x3
    80005ce0:	b4450513          	addi	a0,a0,-1212 # 80008820 <userret+0x790>
    80005ce4:	ffffb097          	auipc	ra,0xffffb
    80005ce8:	864080e7          	jalr	-1948(ra) # 80000548 <panic>
  return -1;
    80005cec:	557d                	li	a0,-1
    80005cee:	a011                	j	80005cf2 <sys_exec+0x112>
    return -1;
    80005cf0:	557d                	li	a0,-1
}
    80005cf2:	60be                	ld	ra,456(sp)
    80005cf4:	641e                	ld	s0,448(sp)
    80005cf6:	74fa                	ld	s1,440(sp)
    80005cf8:	795a                	ld	s2,432(sp)
    80005cfa:	79ba                	ld	s3,424(sp)
    80005cfc:	7a1a                	ld	s4,416(sp)
    80005cfe:	6afa                	ld	s5,408(sp)
    80005d00:	6179                	addi	sp,sp,464
    80005d02:	8082                	ret
    return -1;
    80005d04:	557d                	li	a0,-1
    80005d06:	b7f5                	j	80005cf2 <sys_exec+0x112>

0000000080005d08 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d08:	7139                	addi	sp,sp,-64
    80005d0a:	fc06                	sd	ra,56(sp)
    80005d0c:	f822                	sd	s0,48(sp)
    80005d0e:	f426                	sd	s1,40(sp)
    80005d10:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d12:	ffffc097          	auipc	ra,0xffffc
    80005d16:	d18080e7          	jalr	-744(ra) # 80001a2a <myproc>
    80005d1a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d1c:	fd840593          	addi	a1,s0,-40
    80005d20:	4501                	li	a0,0
    80005d22:	ffffd097          	auipc	ra,0xffffd
    80005d26:	e02080e7          	jalr	-510(ra) # 80002b24 <argaddr>
    return -1;
    80005d2a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d2c:	0e054063          	bltz	a0,80005e0c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d30:	fc840593          	addi	a1,s0,-56
    80005d34:	fd040513          	addi	a0,s0,-48
    80005d38:	fffff097          	auipc	ra,0xfffff
    80005d3c:	d90080e7          	jalr	-624(ra) # 80004ac8 <pipealloc>
    return -1;
    80005d40:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d42:	0c054563          	bltz	a0,80005e0c <sys_pipe+0x104>
  fd0 = -1;
    80005d46:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d4a:	fd043503          	ld	a0,-48(s0)
    80005d4e:	fffff097          	auipc	ra,0xfffff
    80005d52:	4d4080e7          	jalr	1236(ra) # 80005222 <fdalloc>
    80005d56:	fca42223          	sw	a0,-60(s0)
    80005d5a:	08054c63          	bltz	a0,80005df2 <sys_pipe+0xea>
    80005d5e:	fc843503          	ld	a0,-56(s0)
    80005d62:	fffff097          	auipc	ra,0xfffff
    80005d66:	4c0080e7          	jalr	1216(ra) # 80005222 <fdalloc>
    80005d6a:	fca42023          	sw	a0,-64(s0)
    80005d6e:	06054863          	bltz	a0,80005dde <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d72:	4691                	li	a3,4
    80005d74:	fc440613          	addi	a2,s0,-60
    80005d78:	fd843583          	ld	a1,-40(s0)
    80005d7c:	6ca8                	ld	a0,88(s1)
    80005d7e:	ffffc097          	auipc	ra,0xffffc
    80005d82:	a14080e7          	jalr	-1516(ra) # 80001792 <copyout>
    80005d86:	02054063          	bltz	a0,80005da6 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d8a:	4691                	li	a3,4
    80005d8c:	fc040613          	addi	a2,s0,-64
    80005d90:	fd843583          	ld	a1,-40(s0)
    80005d94:	0591                	addi	a1,a1,4
    80005d96:	6ca8                	ld	a0,88(s1)
    80005d98:	ffffc097          	auipc	ra,0xffffc
    80005d9c:	9fa080e7          	jalr	-1542(ra) # 80001792 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005da0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005da2:	06055563          	bgez	a0,80005e0c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005da6:	fc442783          	lw	a5,-60(s0)
    80005daa:	07e9                	addi	a5,a5,26
    80005dac:	078e                	slli	a5,a5,0x3
    80005dae:	97a6                	add	a5,a5,s1
    80005db0:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005db4:	fc042503          	lw	a0,-64(s0)
    80005db8:	0569                	addi	a0,a0,26
    80005dba:	050e                	slli	a0,a0,0x3
    80005dbc:	9526                	add	a0,a0,s1
    80005dbe:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005dc2:	fd043503          	ld	a0,-48(s0)
    80005dc6:	fffff097          	auipc	ra,0xfffff
    80005dca:	99e080e7          	jalr	-1634(ra) # 80004764 <fileclose>
    fileclose(wf);
    80005dce:	fc843503          	ld	a0,-56(s0)
    80005dd2:	fffff097          	auipc	ra,0xfffff
    80005dd6:	992080e7          	jalr	-1646(ra) # 80004764 <fileclose>
    return -1;
    80005dda:	57fd                	li	a5,-1
    80005ddc:	a805                	j	80005e0c <sys_pipe+0x104>
    if(fd0 >= 0)
    80005dde:	fc442783          	lw	a5,-60(s0)
    80005de2:	0007c863          	bltz	a5,80005df2 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005de6:	01a78513          	addi	a0,a5,26
    80005dea:	050e                	slli	a0,a0,0x3
    80005dec:	9526                	add	a0,a0,s1
    80005dee:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005df2:	fd043503          	ld	a0,-48(s0)
    80005df6:	fffff097          	auipc	ra,0xfffff
    80005dfa:	96e080e7          	jalr	-1682(ra) # 80004764 <fileclose>
    fileclose(wf);
    80005dfe:	fc843503          	ld	a0,-56(s0)
    80005e02:	fffff097          	auipc	ra,0xfffff
    80005e06:	962080e7          	jalr	-1694(ra) # 80004764 <fileclose>
    return -1;
    80005e0a:	57fd                	li	a5,-1
}
    80005e0c:	853e                	mv	a0,a5
    80005e0e:	70e2                	ld	ra,56(sp)
    80005e10:	7442                	ld	s0,48(sp)
    80005e12:	74a2                	ld	s1,40(sp)
    80005e14:	6121                	addi	sp,sp,64
    80005e16:	8082                	ret

0000000080005e18 <sys_crash>:

// system call to test crashes
uint64
sys_crash(void)
{
    80005e18:	7171                	addi	sp,sp,-176
    80005e1a:	f506                	sd	ra,168(sp)
    80005e1c:	f122                	sd	s0,160(sp)
    80005e1e:	ed26                	sd	s1,152(sp)
    80005e20:	1900                	addi	s0,sp,176
  char path[MAXPATH];
  struct inode *ip;
  int crash;
  
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005e22:	08000613          	li	a2,128
    80005e26:	f6040593          	addi	a1,s0,-160
    80005e2a:	4501                	li	a0,0
    80005e2c:	ffffd097          	auipc	ra,0xffffd
    80005e30:	d1a080e7          	jalr	-742(ra) # 80002b46 <argstr>
    return -1;
    80005e34:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005e36:	04054363          	bltz	a0,80005e7c <sys_crash+0x64>
    80005e3a:	f5c40593          	addi	a1,s0,-164
    80005e3e:	4505                	li	a0,1
    80005e40:	ffffd097          	auipc	ra,0xffffd
    80005e44:	cc2080e7          	jalr	-830(ra) # 80002b02 <argint>
    return -1;
    80005e48:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005e4a:	02054963          	bltz	a0,80005e7c <sys_crash+0x64>
  ip = create(path, T_FILE, 0, 0);
    80005e4e:	4681                	li	a3,0
    80005e50:	4601                	li	a2,0
    80005e52:	4589                	li	a1,2
    80005e54:	f6040513          	addi	a0,s0,-160
    80005e58:	fffff097          	auipc	ra,0xfffff
    80005e5c:	40c080e7          	jalr	1036(ra) # 80005264 <create>
    80005e60:	84aa                	mv	s1,a0
  if(ip == 0){
    80005e62:	c11d                	beqz	a0,80005e88 <sys_crash+0x70>
    return -1;
  }
  iunlockput(ip);
    80005e64:	ffffe097          	auipc	ra,0xffffe
    80005e68:	a70080e7          	jalr	-1424(ra) # 800038d4 <iunlockput>
  crash_op(ip->dev, crash);
    80005e6c:	f5c42583          	lw	a1,-164(s0)
    80005e70:	4088                	lw	a0,0(s1)
    80005e72:	ffffe097          	auipc	ra,0xffffe
    80005e76:	5c6080e7          	jalr	1478(ra) # 80004438 <crash_op>
  return 0;
    80005e7a:	4781                	li	a5,0
}
    80005e7c:	853e                	mv	a0,a5
    80005e7e:	70aa                	ld	ra,168(sp)
    80005e80:	740a                	ld	s0,160(sp)
    80005e82:	64ea                	ld	s1,152(sp)
    80005e84:	614d                	addi	sp,sp,176
    80005e86:	8082                	ret
    return -1;
    80005e88:	57fd                	li	a5,-1
    80005e8a:	bfcd                	j	80005e7c <sys_crash+0x64>
    80005e8c:	0000                	unimp
	...

0000000080005e90 <kernelvec>:
    80005e90:	7111                	addi	sp,sp,-256
    80005e92:	e006                	sd	ra,0(sp)
    80005e94:	e40a                	sd	sp,8(sp)
    80005e96:	e80e                	sd	gp,16(sp)
    80005e98:	ec12                	sd	tp,24(sp)
    80005e9a:	f016                	sd	t0,32(sp)
    80005e9c:	f41a                	sd	t1,40(sp)
    80005e9e:	f81e                	sd	t2,48(sp)
    80005ea0:	fc22                	sd	s0,56(sp)
    80005ea2:	e0a6                	sd	s1,64(sp)
    80005ea4:	e4aa                	sd	a0,72(sp)
    80005ea6:	e8ae                	sd	a1,80(sp)
    80005ea8:	ecb2                	sd	a2,88(sp)
    80005eaa:	f0b6                	sd	a3,96(sp)
    80005eac:	f4ba                	sd	a4,104(sp)
    80005eae:	f8be                	sd	a5,112(sp)
    80005eb0:	fcc2                	sd	a6,120(sp)
    80005eb2:	e146                	sd	a7,128(sp)
    80005eb4:	e54a                	sd	s2,136(sp)
    80005eb6:	e94e                	sd	s3,144(sp)
    80005eb8:	ed52                	sd	s4,152(sp)
    80005eba:	f156                	sd	s5,160(sp)
    80005ebc:	f55a                	sd	s6,168(sp)
    80005ebe:	f95e                	sd	s7,176(sp)
    80005ec0:	fd62                	sd	s8,184(sp)
    80005ec2:	e1e6                	sd	s9,192(sp)
    80005ec4:	e5ea                	sd	s10,200(sp)
    80005ec6:	e9ee                	sd	s11,208(sp)
    80005ec8:	edf2                	sd	t3,216(sp)
    80005eca:	f1f6                	sd	t4,224(sp)
    80005ecc:	f5fa                	sd	t5,232(sp)
    80005ece:	f9fe                	sd	t6,240(sp)
    80005ed0:	a65fc0ef          	jal	ra,80002934 <kerneltrap>
    80005ed4:	6082                	ld	ra,0(sp)
    80005ed6:	6122                	ld	sp,8(sp)
    80005ed8:	61c2                	ld	gp,16(sp)
    80005eda:	7282                	ld	t0,32(sp)
    80005edc:	7322                	ld	t1,40(sp)
    80005ede:	73c2                	ld	t2,48(sp)
    80005ee0:	7462                	ld	s0,56(sp)
    80005ee2:	6486                	ld	s1,64(sp)
    80005ee4:	6526                	ld	a0,72(sp)
    80005ee6:	65c6                	ld	a1,80(sp)
    80005ee8:	6666                	ld	a2,88(sp)
    80005eea:	7686                	ld	a3,96(sp)
    80005eec:	7726                	ld	a4,104(sp)
    80005eee:	77c6                	ld	a5,112(sp)
    80005ef0:	7866                	ld	a6,120(sp)
    80005ef2:	688a                	ld	a7,128(sp)
    80005ef4:	692a                	ld	s2,136(sp)
    80005ef6:	69ca                	ld	s3,144(sp)
    80005ef8:	6a6a                	ld	s4,152(sp)
    80005efa:	7a8a                	ld	s5,160(sp)
    80005efc:	7b2a                	ld	s6,168(sp)
    80005efe:	7bca                	ld	s7,176(sp)
    80005f00:	7c6a                	ld	s8,184(sp)
    80005f02:	6c8e                	ld	s9,192(sp)
    80005f04:	6d2e                	ld	s10,200(sp)
    80005f06:	6dce                	ld	s11,208(sp)
    80005f08:	6e6e                	ld	t3,216(sp)
    80005f0a:	7e8e                	ld	t4,224(sp)
    80005f0c:	7f2e                	ld	t5,232(sp)
    80005f0e:	7fce                	ld	t6,240(sp)
    80005f10:	6111                	addi	sp,sp,256
    80005f12:	10200073          	sret
    80005f16:	00000013          	nop
    80005f1a:	00000013          	nop
    80005f1e:	0001                	nop

0000000080005f20 <timervec>:
    80005f20:	34051573          	csrrw	a0,mscratch,a0
    80005f24:	e10c                	sd	a1,0(a0)
    80005f26:	e510                	sd	a2,8(a0)
    80005f28:	e914                	sd	a3,16(a0)
    80005f2a:	710c                	ld	a1,32(a0)
    80005f2c:	7510                	ld	a2,40(a0)
    80005f2e:	6194                	ld	a3,0(a1)
    80005f30:	96b2                	add	a3,a3,a2
    80005f32:	e194                	sd	a3,0(a1)
    80005f34:	4589                	li	a1,2
    80005f36:	14459073          	csrw	sip,a1
    80005f3a:	6914                	ld	a3,16(a0)
    80005f3c:	6510                	ld	a2,8(a0)
    80005f3e:	610c                	ld	a1,0(a0)
    80005f40:	34051573          	csrrw	a0,mscratch,a0
    80005f44:	30200073          	mret
	...

0000000080005f4a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f4a:	1141                	addi	sp,sp,-16
    80005f4c:	e422                	sd	s0,8(sp)
    80005f4e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f50:	0c0007b7          	lui	a5,0xc000
    80005f54:	4705                	li	a4,1
    80005f56:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f58:	c3d8                	sw	a4,4(a5)
}
    80005f5a:	6422                	ld	s0,8(sp)
    80005f5c:	0141                	addi	sp,sp,16
    80005f5e:	8082                	ret

0000000080005f60 <plicinithart>:

void
plicinithart(void)
{
    80005f60:	1141                	addi	sp,sp,-16
    80005f62:	e406                	sd	ra,8(sp)
    80005f64:	e022                	sd	s0,0(sp)
    80005f66:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f68:	ffffc097          	auipc	ra,0xffffc
    80005f6c:	a96080e7          	jalr	-1386(ra) # 800019fe <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f70:	0085171b          	slliw	a4,a0,0x8
    80005f74:	0c0027b7          	lui	a5,0xc002
    80005f78:	97ba                	add	a5,a5,a4
    80005f7a:	40200713          	li	a4,1026
    80005f7e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f82:	00d5151b          	slliw	a0,a0,0xd
    80005f86:	0c2017b7          	lui	a5,0xc201
    80005f8a:	953e                	add	a0,a0,a5
    80005f8c:	00052023          	sw	zero,0(a0)
}
    80005f90:	60a2                	ld	ra,8(sp)
    80005f92:	6402                	ld	s0,0(sp)
    80005f94:	0141                	addi	sp,sp,16
    80005f96:	8082                	ret

0000000080005f98 <plic_pending>:

// return a bitmap of which IRQs are waiting
// to be served.
uint64
plic_pending(void)
{
    80005f98:	1141                	addi	sp,sp,-16
    80005f9a:	e422                	sd	s0,8(sp)
    80005f9c:	0800                	addi	s0,sp,16
  //mask = *(uint32*)(PLIC + 0x1000);
  //mask |= (uint64)*(uint32*)(PLIC + 0x1004) << 32;
  mask = *(uint64*)PLIC_PENDING;

  return mask;
}
    80005f9e:	0c0017b7          	lui	a5,0xc001
    80005fa2:	6388                	ld	a0,0(a5)
    80005fa4:	6422                	ld	s0,8(sp)
    80005fa6:	0141                	addi	sp,sp,16
    80005fa8:	8082                	ret

0000000080005faa <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005faa:	1141                	addi	sp,sp,-16
    80005fac:	e406                	sd	ra,8(sp)
    80005fae:	e022                	sd	s0,0(sp)
    80005fb0:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fb2:	ffffc097          	auipc	ra,0xffffc
    80005fb6:	a4c080e7          	jalr	-1460(ra) # 800019fe <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005fba:	00d5179b          	slliw	a5,a0,0xd
    80005fbe:	0c201537          	lui	a0,0xc201
    80005fc2:	953e                	add	a0,a0,a5
  return irq;
}
    80005fc4:	4148                	lw	a0,4(a0)
    80005fc6:	60a2                	ld	ra,8(sp)
    80005fc8:	6402                	ld	s0,0(sp)
    80005fca:	0141                	addi	sp,sp,16
    80005fcc:	8082                	ret

0000000080005fce <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005fce:	1101                	addi	sp,sp,-32
    80005fd0:	ec06                	sd	ra,24(sp)
    80005fd2:	e822                	sd	s0,16(sp)
    80005fd4:	e426                	sd	s1,8(sp)
    80005fd6:	1000                	addi	s0,sp,32
    80005fd8:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fda:	ffffc097          	auipc	ra,0xffffc
    80005fde:	a24080e7          	jalr	-1500(ra) # 800019fe <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fe2:	00d5151b          	slliw	a0,a0,0xd
    80005fe6:	0c2017b7          	lui	a5,0xc201
    80005fea:	97aa                	add	a5,a5,a0
    80005fec:	c3c4                	sw	s1,4(a5)
}
    80005fee:	60e2                	ld	ra,24(sp)
    80005ff0:	6442                	ld	s0,16(sp)
    80005ff2:	64a2                	ld	s1,8(sp)
    80005ff4:	6105                	addi	sp,sp,32
    80005ff6:	8082                	ret

0000000080005ff8 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80005ff8:	1141                	addi	sp,sp,-16
    80005ffa:	e406                	sd	ra,8(sp)
    80005ffc:	e022                	sd	s0,0(sp)
    80005ffe:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006000:	479d                	li	a5,7
    80006002:	06b7c963          	blt	a5,a1,80006074 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80006006:	00151793          	slli	a5,a0,0x1
    8000600a:	97aa                	add	a5,a5,a0
    8000600c:	00c79713          	slli	a4,a5,0xc
    80006010:	0001e797          	auipc	a5,0x1e
    80006014:	ff078793          	addi	a5,a5,-16 # 80024000 <disk>
    80006018:	97ba                	add	a5,a5,a4
    8000601a:	97ae                	add	a5,a5,a1
    8000601c:	6709                	lui	a4,0x2
    8000601e:	97ba                	add	a5,a5,a4
    80006020:	0187c783          	lbu	a5,24(a5)
    80006024:	e3a5                	bnez	a5,80006084 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80006026:	0001e817          	auipc	a6,0x1e
    8000602a:	fda80813          	addi	a6,a6,-38 # 80024000 <disk>
    8000602e:	00151693          	slli	a3,a0,0x1
    80006032:	00a68733          	add	a4,a3,a0
    80006036:	0732                	slli	a4,a4,0xc
    80006038:	00e807b3          	add	a5,a6,a4
    8000603c:	6709                	lui	a4,0x2
    8000603e:	00f70633          	add	a2,a4,a5
    80006042:	6210                	ld	a2,0(a2)
    80006044:	00459893          	slli	a7,a1,0x4
    80006048:	9646                	add	a2,a2,a7
    8000604a:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    8000604e:	97ae                	add	a5,a5,a1
    80006050:	97ba                	add	a5,a5,a4
    80006052:	4605                	li	a2,1
    80006054:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80006058:	96aa                	add	a3,a3,a0
    8000605a:	06b2                	slli	a3,a3,0xc
    8000605c:	0761                	addi	a4,a4,24
    8000605e:	96ba                	add	a3,a3,a4
    80006060:	00d80533          	add	a0,a6,a3
    80006064:	ffffc097          	auipc	ra,0xffffc
    80006068:	324080e7          	jalr	804(ra) # 80002388 <wakeup>
}
    8000606c:	60a2                	ld	ra,8(sp)
    8000606e:	6402                	ld	s0,0(sp)
    80006070:	0141                	addi	sp,sp,16
    80006072:	8082                	ret
    panic("virtio_disk_intr 1");
    80006074:	00002517          	auipc	a0,0x2
    80006078:	7bc50513          	addi	a0,a0,1980 # 80008830 <userret+0x7a0>
    8000607c:	ffffa097          	auipc	ra,0xffffa
    80006080:	4cc080e7          	jalr	1228(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80006084:	00002517          	auipc	a0,0x2
    80006088:	7c450513          	addi	a0,a0,1988 # 80008848 <userret+0x7b8>
    8000608c:	ffffa097          	auipc	ra,0xffffa
    80006090:	4bc080e7          	jalr	1212(ra) # 80000548 <panic>

0000000080006094 <virtio_disk_init>:
  __sync_synchronize();
    80006094:	0ff0000f          	fence
  if(disk[n].init)
    80006098:	00151793          	slli	a5,a0,0x1
    8000609c:	97aa                	add	a5,a5,a0
    8000609e:	07b2                	slli	a5,a5,0xc
    800060a0:	0001e717          	auipc	a4,0x1e
    800060a4:	f6070713          	addi	a4,a4,-160 # 80024000 <disk>
    800060a8:	973e                	add	a4,a4,a5
    800060aa:	6789                	lui	a5,0x2
    800060ac:	97ba                	add	a5,a5,a4
    800060ae:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    800060b2:	c391                	beqz	a5,800060b6 <virtio_disk_init+0x22>
    800060b4:	8082                	ret
{
    800060b6:	7139                	addi	sp,sp,-64
    800060b8:	fc06                	sd	ra,56(sp)
    800060ba:	f822                	sd	s0,48(sp)
    800060bc:	f426                	sd	s1,40(sp)
    800060be:	f04a                	sd	s2,32(sp)
    800060c0:	ec4e                	sd	s3,24(sp)
    800060c2:	e852                	sd	s4,16(sp)
    800060c4:	e456                	sd	s5,8(sp)
    800060c6:	0080                	addi	s0,sp,64
    800060c8:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    800060ca:	85aa                	mv	a1,a0
    800060cc:	00002517          	auipc	a0,0x2
    800060d0:	79450513          	addi	a0,a0,1940 # 80008860 <userret+0x7d0>
    800060d4:	ffffa097          	auipc	ra,0xffffa
    800060d8:	4be080e7          	jalr	1214(ra) # 80000592 <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    800060dc:	00149993          	slli	s3,s1,0x1
    800060e0:	99a6                	add	s3,s3,s1
    800060e2:	09b2                	slli	s3,s3,0xc
    800060e4:	6789                	lui	a5,0x2
    800060e6:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    800060ea:	97ce                	add	a5,a5,s3
    800060ec:	00002597          	auipc	a1,0x2
    800060f0:	78c58593          	addi	a1,a1,1932 # 80008878 <userret+0x7e8>
    800060f4:	0001e517          	auipc	a0,0x1e
    800060f8:	f0c50513          	addi	a0,a0,-244 # 80024000 <disk>
    800060fc:	953e                	add	a0,a0,a5
    800060fe:	ffffb097          	auipc	ra,0xffffb
    80006102:	8b2080e7          	jalr	-1870(ra) # 800009b0 <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006106:	0014891b          	addiw	s2,s1,1
    8000610a:	00c9191b          	slliw	s2,s2,0xc
    8000610e:	100007b7          	lui	a5,0x10000
    80006112:	97ca                	add	a5,a5,s2
    80006114:	4398                	lw	a4,0(a5)
    80006116:	2701                	sext.w	a4,a4
    80006118:	747277b7          	lui	a5,0x74727
    8000611c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006120:	12f71663          	bne	a4,a5,8000624c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006124:	100007b7          	lui	a5,0x10000
    80006128:	0791                	addi	a5,a5,4
    8000612a:	97ca                	add	a5,a5,s2
    8000612c:	439c                	lw	a5,0(a5)
    8000612e:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006130:	4705                	li	a4,1
    80006132:	10e79d63          	bne	a5,a4,8000624c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006136:	100007b7          	lui	a5,0x10000
    8000613a:	07a1                	addi	a5,a5,8
    8000613c:	97ca                	add	a5,a5,s2
    8000613e:	439c                	lw	a5,0(a5)
    80006140:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006142:	4709                	li	a4,2
    80006144:	10e79463          	bne	a5,a4,8000624c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006148:	100007b7          	lui	a5,0x10000
    8000614c:	07b1                	addi	a5,a5,12
    8000614e:	97ca                	add	a5,a5,s2
    80006150:	4398                	lw	a4,0(a5)
    80006152:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006154:	554d47b7          	lui	a5,0x554d4
    80006158:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000615c:	0ef71863          	bne	a4,a5,8000624c <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006160:	100007b7          	lui	a5,0x10000
    80006164:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80006168:	96ca                	add	a3,a3,s2
    8000616a:	4705                	li	a4,1
    8000616c:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000616e:	470d                	li	a4,3
    80006170:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    80006172:	01078713          	addi	a4,a5,16
    80006176:	974a                	add	a4,a4,s2
    80006178:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000617a:	02078613          	addi	a2,a5,32
    8000617e:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006180:	c7ffe737          	lui	a4,0xc7ffe
    80006184:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd4703>
    80006188:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000618a:	2701                	sext.w	a4,a4
    8000618c:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000618e:	472d                	li	a4,11
    80006190:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006192:	473d                	li	a4,15
    80006194:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006196:	02878713          	addi	a4,a5,40
    8000619a:	974a                	add	a4,a4,s2
    8000619c:	6685                	lui	a3,0x1
    8000619e:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061a0:	03078713          	addi	a4,a5,48
    800061a4:	974a                	add	a4,a4,s2
    800061a6:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061aa:	03478793          	addi	a5,a5,52
    800061ae:	97ca                	add	a5,a5,s2
    800061b0:	439c                	lw	a5,0(a5)
    800061b2:	2781                	sext.w	a5,a5
  if(max == 0)
    800061b4:	c7c5                	beqz	a5,8000625c <virtio_disk_init+0x1c8>
  if(max < NUM)
    800061b6:	471d                	li	a4,7
    800061b8:	0af77a63          	bgeu	a4,a5,8000626c <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061bc:	10000ab7          	lui	s5,0x10000
    800061c0:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    800061c4:	97ca                	add	a5,a5,s2
    800061c6:	4721                	li	a4,8
    800061c8:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    800061ca:	0001ea17          	auipc	s4,0x1e
    800061ce:	e36a0a13          	addi	s4,s4,-458 # 80024000 <disk>
    800061d2:	99d2                	add	s3,s3,s4
    800061d4:	6609                	lui	a2,0x2
    800061d6:	4581                	li	a1,0
    800061d8:	854e                	mv	a0,s3
    800061da:	ffffb097          	auipc	ra,0xffffb
    800061de:	9a8080e7          	jalr	-1624(ra) # 80000b82 <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    800061e2:	040a8a93          	addi	s5,s5,64
    800061e6:	9956                	add	s2,s2,s5
    800061e8:	00c9d793          	srli	a5,s3,0xc
    800061ec:	2781                	sext.w	a5,a5
    800061ee:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    800061f2:	00149693          	slli	a3,s1,0x1
    800061f6:	009687b3          	add	a5,a3,s1
    800061fa:	07b2                	slli	a5,a5,0xc
    800061fc:	97d2                	add	a5,a5,s4
    800061fe:	6609                	lui	a2,0x2
    80006200:	97b2                	add	a5,a5,a2
    80006202:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006206:	08098713          	addi	a4,s3,128
    8000620a:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    8000620c:	6705                	lui	a4,0x1
    8000620e:	99ba                	add	s3,s3,a4
    80006210:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80006214:	4705                	li	a4,1
    80006216:	00e78c23          	sb	a4,24(a5)
    8000621a:	00e78ca3          	sb	a4,25(a5)
    8000621e:	00e78d23          	sb	a4,26(a5)
    80006222:	00e78da3          	sb	a4,27(a5)
    80006226:	00e78e23          	sb	a4,28(a5)
    8000622a:	00e78ea3          	sb	a4,29(a5)
    8000622e:	00e78f23          	sb	a4,30(a5)
    80006232:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80006236:	0ae7a423          	sw	a4,168(a5)
}
    8000623a:	70e2                	ld	ra,56(sp)
    8000623c:	7442                	ld	s0,48(sp)
    8000623e:	74a2                	ld	s1,40(sp)
    80006240:	7902                	ld	s2,32(sp)
    80006242:	69e2                	ld	s3,24(sp)
    80006244:	6a42                	ld	s4,16(sp)
    80006246:	6aa2                	ld	s5,8(sp)
    80006248:	6121                	addi	sp,sp,64
    8000624a:	8082                	ret
    panic("could not find virtio disk");
    8000624c:	00002517          	auipc	a0,0x2
    80006250:	63c50513          	addi	a0,a0,1596 # 80008888 <userret+0x7f8>
    80006254:	ffffa097          	auipc	ra,0xffffa
    80006258:	2f4080e7          	jalr	756(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    8000625c:	00002517          	auipc	a0,0x2
    80006260:	64c50513          	addi	a0,a0,1612 # 800088a8 <userret+0x818>
    80006264:	ffffa097          	auipc	ra,0xffffa
    80006268:	2e4080e7          	jalr	740(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    8000626c:	00002517          	auipc	a0,0x2
    80006270:	65c50513          	addi	a0,a0,1628 # 800088c8 <userret+0x838>
    80006274:	ffffa097          	auipc	ra,0xffffa
    80006278:	2d4080e7          	jalr	724(ra) # 80000548 <panic>

000000008000627c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    8000627c:	7135                	addi	sp,sp,-160
    8000627e:	ed06                	sd	ra,152(sp)
    80006280:	e922                	sd	s0,144(sp)
    80006282:	e526                	sd	s1,136(sp)
    80006284:	e14a                	sd	s2,128(sp)
    80006286:	fcce                	sd	s3,120(sp)
    80006288:	f8d2                	sd	s4,112(sp)
    8000628a:	f4d6                	sd	s5,104(sp)
    8000628c:	f0da                	sd	s6,96(sp)
    8000628e:	ecde                	sd	s7,88(sp)
    80006290:	e8e2                	sd	s8,80(sp)
    80006292:	e4e6                	sd	s9,72(sp)
    80006294:	e0ea                	sd	s10,64(sp)
    80006296:	fc6e                	sd	s11,56(sp)
    80006298:	1100                	addi	s0,sp,160
    8000629a:	8aaa                	mv	s5,a0
    8000629c:	8c2e                	mv	s8,a1
    8000629e:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    800062a0:	45dc                	lw	a5,12(a1)
    800062a2:	0017979b          	slliw	a5,a5,0x1
    800062a6:	1782                	slli	a5,a5,0x20
    800062a8:	9381                	srli	a5,a5,0x20
    800062aa:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    800062ae:	00151493          	slli	s1,a0,0x1
    800062b2:	94aa                	add	s1,s1,a0
    800062b4:	04b2                	slli	s1,s1,0xc
    800062b6:	6909                	lui	s2,0x2
    800062b8:	0b090c93          	addi	s9,s2,176 # 20b0 <_entry-0x7fffdf50>
    800062bc:	9ca6                	add	s9,s9,s1
    800062be:	0001e997          	auipc	s3,0x1e
    800062c2:	d4298993          	addi	s3,s3,-702 # 80024000 <disk>
    800062c6:	9cce                	add	s9,s9,s3
    800062c8:	8566                	mv	a0,s9
    800062ca:	ffffa097          	auipc	ra,0xffffa
    800062ce:	7f4080e7          	jalr	2036(ra) # 80000abe <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    800062d2:	0961                	addi	s2,s2,24
    800062d4:	94ca                	add	s1,s1,s2
    800062d6:	99a6                	add	s3,s3,s1
  for(int i = 0; i < 3; i++){
    800062d8:	4a01                	li	s4,0
  for(int i = 0; i < NUM; i++){
    800062da:	44a1                	li	s1,8
      disk[n].free[i] = 0;
    800062dc:	001a9793          	slli	a5,s5,0x1
    800062e0:	97d6                	add	a5,a5,s5
    800062e2:	07b2                	slli	a5,a5,0xc
    800062e4:	0001eb97          	auipc	s7,0x1e
    800062e8:	d1cb8b93          	addi	s7,s7,-740 # 80024000 <disk>
    800062ec:	9bbe                	add	s7,s7,a5
    800062ee:	a8a9                	j	80006348 <virtio_disk_rw+0xcc>
    800062f0:	00fb8733          	add	a4,s7,a5
    800062f4:	9742                	add	a4,a4,a6
    800062f6:	00070c23          	sb	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    idx[i] = alloc_desc(n);
    800062fa:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800062fc:	0207c263          	bltz	a5,80006320 <virtio_disk_rw+0xa4>
  for(int i = 0; i < 3; i++){
    80006300:	2905                	addiw	s2,s2,1
    80006302:	0611                	addi	a2,a2,4
    80006304:	1ca90463          	beq	s2,a0,800064cc <virtio_disk_rw+0x250>
    idx[i] = alloc_desc(n);
    80006308:	85b2                	mv	a1,a2
    8000630a:	874e                	mv	a4,s3
  for(int i = 0; i < NUM; i++){
    8000630c:	87d2                	mv	a5,s4
    if(disk[n].free[i]){
    8000630e:	00074683          	lbu	a3,0(a4)
    80006312:	fef9                	bnez	a3,800062f0 <virtio_disk_rw+0x74>
  for(int i = 0; i < NUM; i++){
    80006314:	2785                	addiw	a5,a5,1
    80006316:	0705                	addi	a4,a4,1
    80006318:	fe979be3          	bne	a5,s1,8000630e <virtio_disk_rw+0x92>
    idx[i] = alloc_desc(n);
    8000631c:	57fd                	li	a5,-1
    8000631e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006320:	01205e63          	blez	s2,8000633c <virtio_disk_rw+0xc0>
    80006324:	8d52                	mv	s10,s4
        free_desc(n, idx[j]);
    80006326:	000b2583          	lw	a1,0(s6)
    8000632a:	8556                	mv	a0,s5
    8000632c:	00000097          	auipc	ra,0x0
    80006330:	ccc080e7          	jalr	-820(ra) # 80005ff8 <free_desc>
      for(int j = 0; j < i; j++)
    80006334:	2d05                	addiw	s10,s10,1
    80006336:	0b11                	addi	s6,s6,4
    80006338:	ffa917e3          	bne	s2,s10,80006326 <virtio_disk_rw+0xaa>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    8000633c:	85e6                	mv	a1,s9
    8000633e:	854e                	mv	a0,s3
    80006340:	ffffc097          	auipc	ra,0xffffc
    80006344:	ec8080e7          	jalr	-312(ra) # 80002208 <sleep>
  for(int i = 0; i < 3; i++){
    80006348:	f8040b13          	addi	s6,s0,-128
{
    8000634c:	865a                	mv	a2,s6
  for(int i = 0; i < 3; i++){
    8000634e:	8952                	mv	s2,s4
      disk[n].free[i] = 0;
    80006350:	6809                	lui	a6,0x2
  for(int i = 0; i < 3; i++){
    80006352:	450d                	li	a0,3
    80006354:	bf55                	j	80006308 <virtio_disk_rw+0x8c>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80006356:	001a9793          	slli	a5,s5,0x1
    8000635a:	97d6                	add	a5,a5,s5
    8000635c:	07b2                	slli	a5,a5,0xc
    8000635e:	0001e717          	auipc	a4,0x1e
    80006362:	ca270713          	addi	a4,a4,-862 # 80024000 <disk>
    80006366:	973e                	add	a4,a4,a5
    80006368:	6789                	lui	a5,0x2
    8000636a:	97ba                	add	a5,a5,a4
    8000636c:	639c                	ld	a5,0(a5)
    8000636e:	97b6                	add	a5,a5,a3
    80006370:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006374:	0001e517          	auipc	a0,0x1e
    80006378:	c8c50513          	addi	a0,a0,-884 # 80024000 <disk>
    8000637c:	001a9793          	slli	a5,s5,0x1
    80006380:	01578733          	add	a4,a5,s5
    80006384:	0732                	slli	a4,a4,0xc
    80006386:	972a                	add	a4,a4,a0
    80006388:	6609                	lui	a2,0x2
    8000638a:	9732                	add	a4,a4,a2
    8000638c:	6310                	ld	a2,0(a4)
    8000638e:	9636                	add	a2,a2,a3
    80006390:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006394:	0015e593          	ori	a1,a1,1
    80006398:	00b61623          	sh	a1,12(a2)
  disk[n].desc[idx[1]].next = idx[2];
    8000639c:	f8842603          	lw	a2,-120(s0)
    800063a0:	630c                	ld	a1,0(a4)
    800063a2:	96ae                	add	a3,a3,a1
    800063a4:	00c69723          	sh	a2,14(a3) # 100e <_entry-0x7fffeff2>

  disk[n].info[idx[0]].status = 0;
    800063a8:	97d6                	add	a5,a5,s5
    800063aa:	07a2                	slli	a5,a5,0x8
    800063ac:	97a6                	add	a5,a5,s1
    800063ae:	20078793          	addi	a5,a5,512
    800063b2:	0792                	slli	a5,a5,0x4
    800063b4:	97aa                	add	a5,a5,a0
    800063b6:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    800063ba:	00461693          	slli	a3,a2,0x4
    800063be:	00073803          	ld	a6,0(a4)
    800063c2:	9836                	add	a6,a6,a3
    800063c4:	20348613          	addi	a2,s1,515
    800063c8:	001a9593          	slli	a1,s5,0x1
    800063cc:	95d6                	add	a1,a1,s5
    800063ce:	05a2                	slli	a1,a1,0x8
    800063d0:	962e                	add	a2,a2,a1
    800063d2:	0612                	slli	a2,a2,0x4
    800063d4:	962a                	add	a2,a2,a0
    800063d6:	00c83023          	sd	a2,0(a6) # 2000 <_entry-0x7fffe000>
  disk[n].desc[idx[2]].len = 1;
    800063da:	630c                	ld	a1,0(a4)
    800063dc:	95b6                	add	a1,a1,a3
    800063de:	4605                	li	a2,1
    800063e0:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063e2:	630c                	ld	a1,0(a4)
    800063e4:	95b6                	add	a1,a1,a3
    800063e6:	4509                	li	a0,2
    800063e8:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    800063ec:	630c                	ld	a1,0(a4)
    800063ee:	96ae                	add	a3,a3,a1
    800063f0:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063f4:	00cc2223          	sw	a2,4(s8) # fffffffffffff004 <end+0xffffffff7ffd4fa8>
  disk[n].info[idx[0]].b = b;
    800063f8:	0387b423          	sd	s8,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    800063fc:	6714                	ld	a3,8(a4)
    800063fe:	0026d783          	lhu	a5,2(a3)
    80006402:	8b9d                	andi	a5,a5,7
    80006404:	0789                	addi	a5,a5,2
    80006406:	0786                	slli	a5,a5,0x1
    80006408:	97b6                	add	a5,a5,a3
    8000640a:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    8000640e:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006412:	6718                	ld	a4,8(a4)
    80006414:	00275783          	lhu	a5,2(a4)
    80006418:	2785                	addiw	a5,a5,1
    8000641a:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000641e:	001a879b          	addiw	a5,s5,1
    80006422:	00c7979b          	slliw	a5,a5,0xc
    80006426:	10000737          	lui	a4,0x10000
    8000642a:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    8000642e:	97ba                	add	a5,a5,a4
    80006430:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006434:	004c2783          	lw	a5,4(s8)
    80006438:	00c79d63          	bne	a5,a2,80006452 <virtio_disk_rw+0x1d6>
    8000643c:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    8000643e:	85e6                	mv	a1,s9
    80006440:	8562                	mv	a0,s8
    80006442:	ffffc097          	auipc	ra,0xffffc
    80006446:	dc6080e7          	jalr	-570(ra) # 80002208 <sleep>
  while(b->disk == 1) {
    8000644a:	004c2783          	lw	a5,4(s8)
    8000644e:	fe9788e3          	beq	a5,s1,8000643e <virtio_disk_rw+0x1c2>
  }

  disk[n].info[idx[0]].b = 0;
    80006452:	f8042483          	lw	s1,-128(s0)
    80006456:	001a9793          	slli	a5,s5,0x1
    8000645a:	97d6                	add	a5,a5,s5
    8000645c:	07a2                	slli	a5,a5,0x8
    8000645e:	97a6                	add	a5,a5,s1
    80006460:	20078793          	addi	a5,a5,512
    80006464:	0792                	slli	a5,a5,0x4
    80006466:	0001e717          	auipc	a4,0x1e
    8000646a:	b9a70713          	addi	a4,a4,-1126 # 80024000 <disk>
    8000646e:	97ba                	add	a5,a5,a4
    80006470:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006474:	001a9793          	slli	a5,s5,0x1
    80006478:	97d6                	add	a5,a5,s5
    8000647a:	07b2                	slli	a5,a5,0xc
    8000647c:	97ba                	add	a5,a5,a4
    8000647e:	6909                	lui	s2,0x2
    80006480:	993e                	add	s2,s2,a5
    80006482:	a019                	j	80006488 <virtio_disk_rw+0x20c>
      i = disk[n].desc[i].next;
    80006484:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    80006488:	85a6                	mv	a1,s1
    8000648a:	8556                	mv	a0,s5
    8000648c:	00000097          	auipc	ra,0x0
    80006490:	b6c080e7          	jalr	-1172(ra) # 80005ff8 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006494:	0492                	slli	s1,s1,0x4
    80006496:	00093783          	ld	a5,0(s2) # 2000 <_entry-0x7fffe000>
    8000649a:	94be                	add	s1,s1,a5
    8000649c:	00c4d783          	lhu	a5,12(s1)
    800064a0:	8b85                	andi	a5,a5,1
    800064a2:	f3ed                	bnez	a5,80006484 <virtio_disk_rw+0x208>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    800064a4:	8566                	mv	a0,s9
    800064a6:	ffffa097          	auipc	ra,0xffffa
    800064aa:	680080e7          	jalr	1664(ra) # 80000b26 <release>
}
    800064ae:	60ea                	ld	ra,152(sp)
    800064b0:	644a                	ld	s0,144(sp)
    800064b2:	64aa                	ld	s1,136(sp)
    800064b4:	690a                	ld	s2,128(sp)
    800064b6:	79e6                	ld	s3,120(sp)
    800064b8:	7a46                	ld	s4,112(sp)
    800064ba:	7aa6                	ld	s5,104(sp)
    800064bc:	7b06                	ld	s6,96(sp)
    800064be:	6be6                	ld	s7,88(sp)
    800064c0:	6c46                	ld	s8,80(sp)
    800064c2:	6ca6                	ld	s9,72(sp)
    800064c4:	6d06                	ld	s10,64(sp)
    800064c6:	7de2                	ld	s11,56(sp)
    800064c8:	610d                	addi	sp,sp,160
    800064ca:	8082                	ret
  if(write)
    800064cc:	01b037b3          	snez	a5,s11
    800064d0:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    800064d4:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    800064d8:	f6843783          	ld	a5,-152(s0)
    800064dc:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    800064e0:	f8042483          	lw	s1,-128(s0)
    800064e4:	00449993          	slli	s3,s1,0x4
    800064e8:	001a9793          	slli	a5,s5,0x1
    800064ec:	97d6                	add	a5,a5,s5
    800064ee:	07b2                	slli	a5,a5,0xc
    800064f0:	0001e917          	auipc	s2,0x1e
    800064f4:	b1090913          	addi	s2,s2,-1264 # 80024000 <disk>
    800064f8:	97ca                	add	a5,a5,s2
    800064fa:	6909                	lui	s2,0x2
    800064fc:	993e                	add	s2,s2,a5
    800064fe:	00093a03          	ld	s4,0(s2) # 2000 <_entry-0x7fffe000>
    80006502:	9a4e                	add	s4,s4,s3
    80006504:	f7040513          	addi	a0,s0,-144
    80006508:	ffffb097          	auipc	ra,0xffffb
    8000650c:	ab6080e7          	jalr	-1354(ra) # 80000fbe <kvmpa>
    80006510:	00aa3023          	sd	a0,0(s4)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006514:	00093783          	ld	a5,0(s2)
    80006518:	97ce                	add	a5,a5,s3
    8000651a:	4741                	li	a4,16
    8000651c:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000651e:	00093783          	ld	a5,0(s2)
    80006522:	97ce                	add	a5,a5,s3
    80006524:	4705                	li	a4,1
    80006526:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    8000652a:	f8442683          	lw	a3,-124(s0)
    8000652e:	00093783          	ld	a5,0(s2)
    80006532:	99be                	add	s3,s3,a5
    80006534:	00d99723          	sh	a3,14(s3)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006538:	0692                	slli	a3,a3,0x4
    8000653a:	00093783          	ld	a5,0(s2)
    8000653e:	97b6                	add	a5,a5,a3
    80006540:	060c0713          	addi	a4,s8,96
    80006544:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006546:	00093783          	ld	a5,0(s2)
    8000654a:	97b6                	add	a5,a5,a3
    8000654c:	40000713          	li	a4,1024
    80006550:	c798                	sw	a4,8(a5)
  if(write)
    80006552:	e00d92e3          	bnez	s11,80006356 <virtio_disk_rw+0xda>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006556:	001a9793          	slli	a5,s5,0x1
    8000655a:	97d6                	add	a5,a5,s5
    8000655c:	07b2                	slli	a5,a5,0xc
    8000655e:	0001e717          	auipc	a4,0x1e
    80006562:	aa270713          	addi	a4,a4,-1374 # 80024000 <disk>
    80006566:	973e                	add	a4,a4,a5
    80006568:	6789                	lui	a5,0x2
    8000656a:	97ba                	add	a5,a5,a4
    8000656c:	639c                	ld	a5,0(a5)
    8000656e:	97b6                	add	a5,a5,a3
    80006570:	4709                	li	a4,2
    80006572:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    80006576:	bbfd                	j	80006374 <virtio_disk_rw+0xf8>

0000000080006578 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006578:	7139                	addi	sp,sp,-64
    8000657a:	fc06                	sd	ra,56(sp)
    8000657c:	f822                	sd	s0,48(sp)
    8000657e:	f426                	sd	s1,40(sp)
    80006580:	f04a                	sd	s2,32(sp)
    80006582:	ec4e                	sd	s3,24(sp)
    80006584:	e852                	sd	s4,16(sp)
    80006586:	e456                	sd	s5,8(sp)
    80006588:	0080                	addi	s0,sp,64
    8000658a:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    8000658c:	00151913          	slli	s2,a0,0x1
    80006590:	00a90a33          	add	s4,s2,a0
    80006594:	0a32                	slli	s4,s4,0xc
    80006596:	6989                	lui	s3,0x2
    80006598:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    8000659c:	9a3e                	add	s4,s4,a5
    8000659e:	0001ea97          	auipc	s5,0x1e
    800065a2:	a62a8a93          	addi	s5,s5,-1438 # 80024000 <disk>
    800065a6:	9a56                	add	s4,s4,s5
    800065a8:	8552                	mv	a0,s4
    800065aa:	ffffa097          	auipc	ra,0xffffa
    800065ae:	514080e7          	jalr	1300(ra) # 80000abe <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    800065b2:	9926                	add	s2,s2,s1
    800065b4:	0932                	slli	s2,s2,0xc
    800065b6:	9956                	add	s2,s2,s5
    800065b8:	99ca                	add	s3,s3,s2
    800065ba:	0209d783          	lhu	a5,32(s3)
    800065be:	0109b703          	ld	a4,16(s3)
    800065c2:	00275683          	lhu	a3,2(a4)
    800065c6:	8ebd                	xor	a3,a3,a5
    800065c8:	8a9d                	andi	a3,a3,7
    800065ca:	c2a5                	beqz	a3,8000662a <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    800065cc:	8956                	mv	s2,s5
    800065ce:	00149693          	slli	a3,s1,0x1
    800065d2:	96a6                	add	a3,a3,s1
    800065d4:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    800065d8:	06b2                	slli	a3,a3,0xc
    800065da:	96d6                	add	a3,a3,s5
    800065dc:	6489                	lui	s1,0x2
    800065de:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    800065e0:	078e                	slli	a5,a5,0x3
    800065e2:	97ba                	add	a5,a5,a4
    800065e4:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    800065e6:	00f98733          	add	a4,s3,a5
    800065ea:	20070713          	addi	a4,a4,512
    800065ee:	0712                	slli	a4,a4,0x4
    800065f0:	974a                	add	a4,a4,s2
    800065f2:	03074703          	lbu	a4,48(a4)
    800065f6:	eb21                	bnez	a4,80006646 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    800065f8:	97ce                	add	a5,a5,s3
    800065fa:	20078793          	addi	a5,a5,512
    800065fe:	0792                	slli	a5,a5,0x4
    80006600:	97ca                	add	a5,a5,s2
    80006602:	7798                	ld	a4,40(a5)
    80006604:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006608:	7788                	ld	a0,40(a5)
    8000660a:	ffffc097          	auipc	ra,0xffffc
    8000660e:	d7e080e7          	jalr	-642(ra) # 80002388 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006612:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006616:	2785                	addiw	a5,a5,1
    80006618:	8b9d                	andi	a5,a5,7
    8000661a:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    8000661e:	6898                	ld	a4,16(s1)
    80006620:	00275683          	lhu	a3,2(a4)
    80006624:	8a9d                	andi	a3,a3,7
    80006626:	faf69de3          	bne	a3,a5,800065e0 <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    8000662a:	8552                	mv	a0,s4
    8000662c:	ffffa097          	auipc	ra,0xffffa
    80006630:	4fa080e7          	jalr	1274(ra) # 80000b26 <release>
}
    80006634:	70e2                	ld	ra,56(sp)
    80006636:	7442                	ld	s0,48(sp)
    80006638:	74a2                	ld	s1,40(sp)
    8000663a:	7902                	ld	s2,32(sp)
    8000663c:	69e2                	ld	s3,24(sp)
    8000663e:	6a42                	ld	s4,16(sp)
    80006640:	6aa2                	ld	s5,8(sp)
    80006642:	6121                	addi	sp,sp,64
    80006644:	8082                	ret
      panic("virtio_disk_intr status");
    80006646:	00002517          	auipc	a0,0x2
    8000664a:	2a250513          	addi	a0,a0,674 # 800088e8 <userret+0x858>
    8000664e:	ffffa097          	auipc	ra,0xffffa
    80006652:	efa080e7          	jalr	-262(ra) # 80000548 <panic>

0000000080006656 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80006656:	1141                	addi	sp,sp,-16
    80006658:	e422                	sd	s0,8(sp)
    8000665a:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    8000665c:	41f5d79b          	sraiw	a5,a1,0x1f
    80006660:	01d7d79b          	srliw	a5,a5,0x1d
    80006664:	9dbd                	addw	a1,a1,a5
    80006666:	0075f713          	andi	a4,a1,7
    8000666a:	9f1d                	subw	a4,a4,a5
    8000666c:	4785                	li	a5,1
    8000666e:	00e797bb          	sllw	a5,a5,a4
    80006672:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    80006676:	4035d59b          	sraiw	a1,a1,0x3
    8000667a:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    8000667c:	0005c503          	lbu	a0,0(a1)
    80006680:	8d7d                	and	a0,a0,a5
    80006682:	8d1d                	sub	a0,a0,a5
}
    80006684:	00153513          	seqz	a0,a0
    80006688:	6422                	ld	s0,8(sp)
    8000668a:	0141                	addi	sp,sp,16
    8000668c:	8082                	ret

000000008000668e <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    8000668e:	1141                	addi	sp,sp,-16
    80006690:	e422                	sd	s0,8(sp)
    80006692:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006694:	41f5d79b          	sraiw	a5,a1,0x1f
    80006698:	01d7d79b          	srliw	a5,a5,0x1d
    8000669c:	9dbd                	addw	a1,a1,a5
    8000669e:	4035d71b          	sraiw	a4,a1,0x3
    800066a2:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800066a4:	899d                	andi	a1,a1,7
    800066a6:	9d9d                	subw	a1,a1,a5
    800066a8:	4785                	li	a5,1
    800066aa:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    800066ae:	00054783          	lbu	a5,0(a0)
    800066b2:	8ddd                	or	a1,a1,a5
    800066b4:	00b50023          	sb	a1,0(a0)
}
    800066b8:	6422                	ld	s0,8(sp)
    800066ba:	0141                	addi	sp,sp,16
    800066bc:	8082                	ret

00000000800066be <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    800066be:	1141                	addi	sp,sp,-16
    800066c0:	e422                	sd	s0,8(sp)
    800066c2:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800066c4:	41f5d79b          	sraiw	a5,a1,0x1f
    800066c8:	01d7d79b          	srliw	a5,a5,0x1d
    800066cc:	9dbd                	addw	a1,a1,a5
    800066ce:	4035d71b          	sraiw	a4,a1,0x3
    800066d2:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800066d4:	899d                	andi	a1,a1,7
    800066d6:	9d9d                	subw	a1,a1,a5
    800066d8:	4785                	li	a5,1
    800066da:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    800066de:	fff5c593          	not	a1,a1
    800066e2:	00054783          	lbu	a5,0(a0)
    800066e6:	8dfd                	and	a1,a1,a5
    800066e8:	00b50023          	sb	a1,0(a0)
}
    800066ec:	6422                	ld	s0,8(sp)
    800066ee:	0141                	addi	sp,sp,16
    800066f0:	8082                	ret

00000000800066f2 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    800066f2:	715d                	addi	sp,sp,-80
    800066f4:	e486                	sd	ra,72(sp)
    800066f6:	e0a2                	sd	s0,64(sp)
    800066f8:	fc26                	sd	s1,56(sp)
    800066fa:	f84a                	sd	s2,48(sp)
    800066fc:	f44e                	sd	s3,40(sp)
    800066fe:	f052                	sd	s4,32(sp)
    80006700:	ec56                	sd	s5,24(sp)
    80006702:	e85a                	sd	s6,16(sp)
    80006704:	e45e                	sd	s7,8(sp)
    80006706:	0880                	addi	s0,sp,80
    80006708:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    8000670a:	08b05b63          	blez	a1,800067a0 <bd_print_vector+0xae>
    8000670e:	89aa                	mv	s3,a0
    80006710:	4481                	li	s1,0
  lb = 0;
    80006712:	4a81                	li	s5,0
  last = 1;
    80006714:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006716:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006718:	00002b97          	auipc	s7,0x2
    8000671c:	1e8b8b93          	addi	s7,s7,488 # 80008900 <userret+0x870>
    80006720:	a821                	j	80006738 <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80006722:	85a6                	mv	a1,s1
    80006724:	854e                	mv	a0,s3
    80006726:	00000097          	auipc	ra,0x0
    8000672a:	f30080e7          	jalr	-208(ra) # 80006656 <bit_isset>
    8000672e:	892a                	mv	s2,a0
    80006730:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006732:	2485                	addiw	s1,s1,1
    80006734:	029a0463          	beq	s4,s1,8000675c <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006738:	85a6                	mv	a1,s1
    8000673a:	854e                	mv	a0,s3
    8000673c:	00000097          	auipc	ra,0x0
    80006740:	f1a080e7          	jalr	-230(ra) # 80006656 <bit_isset>
    80006744:	ff2507e3          	beq	a0,s2,80006732 <bd_print_vector+0x40>
    if(last == 1)
    80006748:	fd691de3          	bne	s2,s6,80006722 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    8000674c:	8626                	mv	a2,s1
    8000674e:	85d6                	mv	a1,s5
    80006750:	855e                	mv	a0,s7
    80006752:	ffffa097          	auipc	ra,0xffffa
    80006756:	e40080e7          	jalr	-448(ra) # 80000592 <printf>
    8000675a:	b7e1                	j	80006722 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    8000675c:	000a8563          	beqz	s5,80006766 <bd_print_vector+0x74>
    80006760:	4785                	li	a5,1
    80006762:	00f91c63          	bne	s2,a5,8000677a <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006766:	8652                	mv	a2,s4
    80006768:	85d6                	mv	a1,s5
    8000676a:	00002517          	auipc	a0,0x2
    8000676e:	19650513          	addi	a0,a0,406 # 80008900 <userret+0x870>
    80006772:	ffffa097          	auipc	ra,0xffffa
    80006776:	e20080e7          	jalr	-480(ra) # 80000592 <printf>
  }
  printf("\n");
    8000677a:	00002517          	auipc	a0,0x2
    8000677e:	a3650513          	addi	a0,a0,-1482 # 800081b0 <userret+0x120>
    80006782:	ffffa097          	auipc	ra,0xffffa
    80006786:	e10080e7          	jalr	-496(ra) # 80000592 <printf>
}
    8000678a:	60a6                	ld	ra,72(sp)
    8000678c:	6406                	ld	s0,64(sp)
    8000678e:	74e2                	ld	s1,56(sp)
    80006790:	7942                	ld	s2,48(sp)
    80006792:	79a2                	ld	s3,40(sp)
    80006794:	7a02                	ld	s4,32(sp)
    80006796:	6ae2                	ld	s5,24(sp)
    80006798:	6b42                	ld	s6,16(sp)
    8000679a:	6ba2                	ld	s7,8(sp)
    8000679c:	6161                	addi	sp,sp,80
    8000679e:	8082                	ret
  lb = 0;
    800067a0:	4a81                	li	s5,0
    800067a2:	b7d1                	j	80006766 <bd_print_vector+0x74>

00000000800067a4 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    800067a4:	00024697          	auipc	a3,0x24
    800067a8:	8b46a683          	lw	a3,-1868(a3) # 8002a058 <nsizes>
    800067ac:	10d05063          	blez	a3,800068ac <bd_print+0x108>
bd_print() {
    800067b0:	711d                	addi	sp,sp,-96
    800067b2:	ec86                	sd	ra,88(sp)
    800067b4:	e8a2                	sd	s0,80(sp)
    800067b6:	e4a6                	sd	s1,72(sp)
    800067b8:	e0ca                	sd	s2,64(sp)
    800067ba:	fc4e                	sd	s3,56(sp)
    800067bc:	f852                	sd	s4,48(sp)
    800067be:	f456                	sd	s5,40(sp)
    800067c0:	f05a                	sd	s6,32(sp)
    800067c2:	ec5e                	sd	s7,24(sp)
    800067c4:	e862                	sd	s8,16(sp)
    800067c6:	e466                	sd	s9,8(sp)
    800067c8:	e06a                	sd	s10,0(sp)
    800067ca:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    800067cc:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800067ce:	4a85                	li	s5,1
    800067d0:	4c41                	li	s8,16
    800067d2:	00002b97          	auipc	s7,0x2
    800067d6:	13eb8b93          	addi	s7,s7,318 # 80008910 <userret+0x880>
    lst_print(&bd_sizes[k].free);
    800067da:	00024a17          	auipc	s4,0x24
    800067de:	876a0a13          	addi	s4,s4,-1930 # 8002a050 <bd_sizes>
    printf("  alloc:");
    800067e2:	00002b17          	auipc	s6,0x2
    800067e6:	156b0b13          	addi	s6,s6,342 # 80008938 <userret+0x8a8>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800067ea:	00024997          	auipc	s3,0x24
    800067ee:	86e98993          	addi	s3,s3,-1938 # 8002a058 <nsizes>
    if(k > 0) {
      printf("  split:");
    800067f2:	00002c97          	auipc	s9,0x2
    800067f6:	156c8c93          	addi	s9,s9,342 # 80008948 <userret+0x8b8>
    800067fa:	a801                	j	8000680a <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    800067fc:	0009a683          	lw	a3,0(s3)
    80006800:	0485                	addi	s1,s1,1
    80006802:	0004879b          	sext.w	a5,s1
    80006806:	08d7d563          	bge	a5,a3,80006890 <bd_print+0xec>
    8000680a:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    8000680e:	36fd                	addiw	a3,a3,-1
    80006810:	9e85                	subw	a3,a3,s1
    80006812:	00da96bb          	sllw	a3,s5,a3
    80006816:	009c1633          	sll	a2,s8,s1
    8000681a:	85ca                	mv	a1,s2
    8000681c:	855e                	mv	a0,s7
    8000681e:	ffffa097          	auipc	ra,0xffffa
    80006822:	d74080e7          	jalr	-652(ra) # 80000592 <printf>
    lst_print(&bd_sizes[k].free);
    80006826:	00549d13          	slli	s10,s1,0x5
    8000682a:	000a3503          	ld	a0,0(s4)
    8000682e:	956a                	add	a0,a0,s10
    80006830:	00001097          	auipc	ra,0x1
    80006834:	a56080e7          	jalr	-1450(ra) # 80007286 <lst_print>
    printf("  alloc:");
    80006838:	855a                	mv	a0,s6
    8000683a:	ffffa097          	auipc	ra,0xffffa
    8000683e:	d58080e7          	jalr	-680(ra) # 80000592 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006842:	0009a583          	lw	a1,0(s3)
    80006846:	35fd                	addiw	a1,a1,-1
    80006848:	412585bb          	subw	a1,a1,s2
    8000684c:	000a3783          	ld	a5,0(s4)
    80006850:	97ea                	add	a5,a5,s10
    80006852:	00ba95bb          	sllw	a1,s5,a1
    80006856:	6b88                	ld	a0,16(a5)
    80006858:	00000097          	auipc	ra,0x0
    8000685c:	e9a080e7          	jalr	-358(ra) # 800066f2 <bd_print_vector>
    if(k > 0) {
    80006860:	f9205ee3          	blez	s2,800067fc <bd_print+0x58>
      printf("  split:");
    80006864:	8566                	mv	a0,s9
    80006866:	ffffa097          	auipc	ra,0xffffa
    8000686a:	d2c080e7          	jalr	-724(ra) # 80000592 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    8000686e:	0009a583          	lw	a1,0(s3)
    80006872:	35fd                	addiw	a1,a1,-1
    80006874:	412585bb          	subw	a1,a1,s2
    80006878:	000a3783          	ld	a5,0(s4)
    8000687c:	9d3e                	add	s10,s10,a5
    8000687e:	00ba95bb          	sllw	a1,s5,a1
    80006882:	018d3503          	ld	a0,24(s10)
    80006886:	00000097          	auipc	ra,0x0
    8000688a:	e6c080e7          	jalr	-404(ra) # 800066f2 <bd_print_vector>
    8000688e:	b7bd                	j	800067fc <bd_print+0x58>
    }
  }
}
    80006890:	60e6                	ld	ra,88(sp)
    80006892:	6446                	ld	s0,80(sp)
    80006894:	64a6                	ld	s1,72(sp)
    80006896:	6906                	ld	s2,64(sp)
    80006898:	79e2                	ld	s3,56(sp)
    8000689a:	7a42                	ld	s4,48(sp)
    8000689c:	7aa2                	ld	s5,40(sp)
    8000689e:	7b02                	ld	s6,32(sp)
    800068a0:	6be2                	ld	s7,24(sp)
    800068a2:	6c42                	ld	s8,16(sp)
    800068a4:	6ca2                	ld	s9,8(sp)
    800068a6:	6d02                	ld	s10,0(sp)
    800068a8:	6125                	addi	sp,sp,96
    800068aa:	8082                	ret
    800068ac:	8082                	ret

00000000800068ae <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800068ae:	1141                	addi	sp,sp,-16
    800068b0:	e422                	sd	s0,8(sp)
    800068b2:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    800068b4:	47c1                	li	a5,16
    800068b6:	00a7fb63          	bgeu	a5,a0,800068cc <firstk+0x1e>
    800068ba:	872a                	mv	a4,a0
  int k = 0;
    800068bc:	4501                	li	a0,0
    k++;
    800068be:	2505                	addiw	a0,a0,1
    size *= 2;
    800068c0:	0786                	slli	a5,a5,0x1
  while (size < n) {
    800068c2:	fee7eee3          	bltu	a5,a4,800068be <firstk+0x10>
  }
  return k;
}
    800068c6:	6422                	ld	s0,8(sp)
    800068c8:	0141                	addi	sp,sp,16
    800068ca:	8082                	ret
  int k = 0;
    800068cc:	4501                	li	a0,0
    800068ce:	bfe5                	j	800068c6 <firstk+0x18>

00000000800068d0 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    800068d0:	1141                	addi	sp,sp,-16
    800068d2:	e422                	sd	s0,8(sp)
    800068d4:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    800068d6:	00023797          	auipc	a5,0x23
    800068da:	7727b783          	ld	a5,1906(a5) # 8002a048 <bd_base>
    800068de:	9d9d                	subw	a1,a1,a5
    800068e0:	47c1                	li	a5,16
    800068e2:	00a797b3          	sll	a5,a5,a0
    800068e6:	02f5c5b3          	div	a1,a1,a5
}
    800068ea:	0005851b          	sext.w	a0,a1
    800068ee:	6422                	ld	s0,8(sp)
    800068f0:	0141                	addi	sp,sp,16
    800068f2:	8082                	ret

00000000800068f4 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    800068f4:	1141                	addi	sp,sp,-16
    800068f6:	e422                	sd	s0,8(sp)
    800068f8:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    800068fa:	47c1                	li	a5,16
    800068fc:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006900:	02b787bb          	mulw	a5,a5,a1
}
    80006904:	00023517          	auipc	a0,0x23
    80006908:	74453503          	ld	a0,1860(a0) # 8002a048 <bd_base>
    8000690c:	953e                	add	a0,a0,a5
    8000690e:	6422                	ld	s0,8(sp)
    80006910:	0141                	addi	sp,sp,16
    80006912:	8082                	ret

0000000080006914 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006914:	7159                	addi	sp,sp,-112
    80006916:	f486                	sd	ra,104(sp)
    80006918:	f0a2                	sd	s0,96(sp)
    8000691a:	eca6                	sd	s1,88(sp)
    8000691c:	e8ca                	sd	s2,80(sp)
    8000691e:	e4ce                	sd	s3,72(sp)
    80006920:	e0d2                	sd	s4,64(sp)
    80006922:	fc56                	sd	s5,56(sp)
    80006924:	f85a                	sd	s6,48(sp)
    80006926:	f45e                	sd	s7,40(sp)
    80006928:	f062                	sd	s8,32(sp)
    8000692a:	ec66                	sd	s9,24(sp)
    8000692c:	e86a                	sd	s10,16(sp)
    8000692e:	e46e                	sd	s11,8(sp)
    80006930:	1880                	addi	s0,sp,112
    80006932:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006934:	00023517          	auipc	a0,0x23
    80006938:	6cc50513          	addi	a0,a0,1740 # 8002a000 <lock>
    8000693c:	ffffa097          	auipc	ra,0xffffa
    80006940:	182080e7          	jalr	386(ra) # 80000abe <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006944:	8526                	mv	a0,s1
    80006946:	00000097          	auipc	ra,0x0
    8000694a:	f68080e7          	jalr	-152(ra) # 800068ae <firstk>
  for (k = fk; k < nsizes; k++) {
    8000694e:	00023797          	auipc	a5,0x23
    80006952:	70a7a783          	lw	a5,1802(a5) # 8002a058 <nsizes>
    80006956:	02f55d63          	bge	a0,a5,80006990 <bd_malloc+0x7c>
    8000695a:	8c2a                	mv	s8,a0
    8000695c:	00551913          	slli	s2,a0,0x5
    80006960:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006962:	00023997          	auipc	s3,0x23
    80006966:	6ee98993          	addi	s3,s3,1774 # 8002a050 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    8000696a:	00023a17          	auipc	s4,0x23
    8000696e:	6eea0a13          	addi	s4,s4,1774 # 8002a058 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006972:	0009b503          	ld	a0,0(s3)
    80006976:	954a                	add	a0,a0,s2
    80006978:	00001097          	auipc	ra,0x1
    8000697c:	894080e7          	jalr	-1900(ra) # 8000720c <lst_empty>
    80006980:	c115                	beqz	a0,800069a4 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006982:	2485                	addiw	s1,s1,1
    80006984:	02090913          	addi	s2,s2,32
    80006988:	000a2783          	lw	a5,0(s4)
    8000698c:	fef4c3e3          	blt	s1,a5,80006972 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006990:	00023517          	auipc	a0,0x23
    80006994:	67050513          	addi	a0,a0,1648 # 8002a000 <lock>
    80006998:	ffffa097          	auipc	ra,0xffffa
    8000699c:	18e080e7          	jalr	398(ra) # 80000b26 <release>
    return 0;
    800069a0:	4b01                	li	s6,0
    800069a2:	a0e1                	j	80006a6a <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    800069a4:	00023797          	auipc	a5,0x23
    800069a8:	6b47a783          	lw	a5,1716(a5) # 8002a058 <nsizes>
    800069ac:	fef4d2e3          	bge	s1,a5,80006990 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    800069b0:	00549993          	slli	s3,s1,0x5
    800069b4:	00023917          	auipc	s2,0x23
    800069b8:	69c90913          	addi	s2,s2,1692 # 8002a050 <bd_sizes>
    800069bc:	00093503          	ld	a0,0(s2)
    800069c0:	954e                	add	a0,a0,s3
    800069c2:	00001097          	auipc	ra,0x1
    800069c6:	876080e7          	jalr	-1930(ra) # 80007238 <lst_pop>
    800069ca:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    800069cc:	00023597          	auipc	a1,0x23
    800069d0:	67c5b583          	ld	a1,1660(a1) # 8002a048 <bd_base>
    800069d4:	40b505bb          	subw	a1,a0,a1
    800069d8:	47c1                	li	a5,16
    800069da:	009797b3          	sll	a5,a5,s1
    800069de:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    800069e2:	00093783          	ld	a5,0(s2)
    800069e6:	97ce                	add	a5,a5,s3
    800069e8:	2581                	sext.w	a1,a1
    800069ea:	6b88                	ld	a0,16(a5)
    800069ec:	00000097          	auipc	ra,0x0
    800069f0:	ca2080e7          	jalr	-862(ra) # 8000668e <bit_set>
  for(; k > fk; k--) {
    800069f4:	069c5363          	bge	s8,s1,80006a5a <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800069f8:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800069fa:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    800069fc:	00023d17          	auipc	s10,0x23
    80006a00:	64cd0d13          	addi	s10,s10,1612 # 8002a048 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006a04:	85a6                	mv	a1,s1
    80006a06:	34fd                	addiw	s1,s1,-1
    80006a08:	009b9ab3          	sll	s5,s7,s1
    80006a0c:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006a10:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
  int n = p - (char *) bd_base;
    80006a14:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006a18:	412b093b          	subw	s2,s6,s2
    80006a1c:	00bb95b3          	sll	a1,s7,a1
    80006a20:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006a24:	013a07b3          	add	a5,s4,s3
    80006a28:	2581                	sext.w	a1,a1
    80006a2a:	6f88                	ld	a0,24(a5)
    80006a2c:	00000097          	auipc	ra,0x0
    80006a30:	c62080e7          	jalr	-926(ra) # 8000668e <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006a34:	1981                	addi	s3,s3,-32
    80006a36:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006a38:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006a3c:	2581                	sext.w	a1,a1
    80006a3e:	010a3503          	ld	a0,16(s4)
    80006a42:	00000097          	auipc	ra,0x0
    80006a46:	c4c080e7          	jalr	-948(ra) # 8000668e <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006a4a:	85e6                	mv	a1,s9
    80006a4c:	8552                	mv	a0,s4
    80006a4e:	00001097          	auipc	ra,0x1
    80006a52:	820080e7          	jalr	-2016(ra) # 8000726e <lst_push>
  for(; k > fk; k--) {
    80006a56:	fb8497e3          	bne	s1,s8,80006a04 <bd_malloc+0xf0>
  }
  release(&lock);
    80006a5a:	00023517          	auipc	a0,0x23
    80006a5e:	5a650513          	addi	a0,a0,1446 # 8002a000 <lock>
    80006a62:	ffffa097          	auipc	ra,0xffffa
    80006a66:	0c4080e7          	jalr	196(ra) # 80000b26 <release>

  return p;
}
    80006a6a:	855a                	mv	a0,s6
    80006a6c:	70a6                	ld	ra,104(sp)
    80006a6e:	7406                	ld	s0,96(sp)
    80006a70:	64e6                	ld	s1,88(sp)
    80006a72:	6946                	ld	s2,80(sp)
    80006a74:	69a6                	ld	s3,72(sp)
    80006a76:	6a06                	ld	s4,64(sp)
    80006a78:	7ae2                	ld	s5,56(sp)
    80006a7a:	7b42                	ld	s6,48(sp)
    80006a7c:	7ba2                	ld	s7,40(sp)
    80006a7e:	7c02                	ld	s8,32(sp)
    80006a80:	6ce2                	ld	s9,24(sp)
    80006a82:	6d42                	ld	s10,16(sp)
    80006a84:	6da2                	ld	s11,8(sp)
    80006a86:	6165                	addi	sp,sp,112
    80006a88:	8082                	ret

0000000080006a8a <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006a8a:	7139                	addi	sp,sp,-64
    80006a8c:	fc06                	sd	ra,56(sp)
    80006a8e:	f822                	sd	s0,48(sp)
    80006a90:	f426                	sd	s1,40(sp)
    80006a92:	f04a                	sd	s2,32(sp)
    80006a94:	ec4e                	sd	s3,24(sp)
    80006a96:	e852                	sd	s4,16(sp)
    80006a98:	e456                	sd	s5,8(sp)
    80006a9a:	e05a                	sd	s6,0(sp)
    80006a9c:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006a9e:	00023a97          	auipc	s5,0x23
    80006aa2:	5baaaa83          	lw	s5,1466(s5) # 8002a058 <nsizes>
  return n / BLK_SIZE(k);
    80006aa6:	00023a17          	auipc	s4,0x23
    80006aaa:	5a2a3a03          	ld	s4,1442(s4) # 8002a048 <bd_base>
    80006aae:	41450a3b          	subw	s4,a0,s4
    80006ab2:	00023497          	auipc	s1,0x23
    80006ab6:	59e4b483          	ld	s1,1438(s1) # 8002a050 <bd_sizes>
    80006aba:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006abe:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006ac0:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006ac2:	03595363          	bge	s2,s5,80006ae8 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006ac6:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006aca:	013b15b3          	sll	a1,s6,s3
    80006ace:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006ad2:	2581                	sext.w	a1,a1
    80006ad4:	6088                	ld	a0,0(s1)
    80006ad6:	00000097          	auipc	ra,0x0
    80006ada:	b80080e7          	jalr	-1152(ra) # 80006656 <bit_isset>
    80006ade:	02048493          	addi	s1,s1,32
    80006ae2:	e501                	bnez	a0,80006aea <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006ae4:	894e                	mv	s2,s3
    80006ae6:	bff1                	j	80006ac2 <size+0x38>
      return k;
    }
  }
  return 0;
    80006ae8:	4901                	li	s2,0
}
    80006aea:	854a                	mv	a0,s2
    80006aec:	70e2                	ld	ra,56(sp)
    80006aee:	7442                	ld	s0,48(sp)
    80006af0:	74a2                	ld	s1,40(sp)
    80006af2:	7902                	ld	s2,32(sp)
    80006af4:	69e2                	ld	s3,24(sp)
    80006af6:	6a42                	ld	s4,16(sp)
    80006af8:	6aa2                	ld	s5,8(sp)
    80006afa:	6b02                	ld	s6,0(sp)
    80006afc:	6121                	addi	sp,sp,64
    80006afe:	8082                	ret

0000000080006b00 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006b00:	7159                	addi	sp,sp,-112
    80006b02:	f486                	sd	ra,104(sp)
    80006b04:	f0a2                	sd	s0,96(sp)
    80006b06:	eca6                	sd	s1,88(sp)
    80006b08:	e8ca                	sd	s2,80(sp)
    80006b0a:	e4ce                	sd	s3,72(sp)
    80006b0c:	e0d2                	sd	s4,64(sp)
    80006b0e:	fc56                	sd	s5,56(sp)
    80006b10:	f85a                	sd	s6,48(sp)
    80006b12:	f45e                	sd	s7,40(sp)
    80006b14:	f062                	sd	s8,32(sp)
    80006b16:	ec66                	sd	s9,24(sp)
    80006b18:	e86a                	sd	s10,16(sp)
    80006b1a:	e46e                	sd	s11,8(sp)
    80006b1c:	1880                	addi	s0,sp,112
    80006b1e:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006b20:	00023517          	auipc	a0,0x23
    80006b24:	4e050513          	addi	a0,a0,1248 # 8002a000 <lock>
    80006b28:	ffffa097          	auipc	ra,0xffffa
    80006b2c:	f96080e7          	jalr	-106(ra) # 80000abe <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80006b30:	8556                	mv	a0,s5
    80006b32:	00000097          	auipc	ra,0x0
    80006b36:	f58080e7          	jalr	-168(ra) # 80006a8a <size>
    80006b3a:	84aa                	mv	s1,a0
    80006b3c:	00023797          	auipc	a5,0x23
    80006b40:	51c7a783          	lw	a5,1308(a5) # 8002a058 <nsizes>
    80006b44:	37fd                	addiw	a5,a5,-1
    80006b46:	0cf55063          	bge	a0,a5,80006c06 <bd_free+0x106>
    80006b4a:	00150a13          	addi	s4,a0,1
    80006b4e:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    80006b50:	00023c17          	auipc	s8,0x23
    80006b54:	4f8c0c13          	addi	s8,s8,1272 # 8002a048 <bd_base>
  return n / BLK_SIZE(k);
    80006b58:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006b5a:	00023b17          	auipc	s6,0x23
    80006b5e:	4f6b0b13          	addi	s6,s6,1270 # 8002a050 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006b62:	00023c97          	auipc	s9,0x23
    80006b66:	4f6c8c93          	addi	s9,s9,1270 # 8002a058 <nsizes>
    80006b6a:	a82d                	j	80006ba4 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006b6c:	fff58d9b          	addiw	s11,a1,-1
    80006b70:	a881                	j	80006bc0 <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006b72:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80006b74:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80006b78:	40ba85bb          	subw	a1,s5,a1
    80006b7c:	009b97b3          	sll	a5,s7,s1
    80006b80:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006b84:	000b3783          	ld	a5,0(s6)
    80006b88:	97d2                	add	a5,a5,s4
    80006b8a:	2581                	sext.w	a1,a1
    80006b8c:	6f88                	ld	a0,24(a5)
    80006b8e:	00000097          	auipc	ra,0x0
    80006b92:	b30080e7          	jalr	-1232(ra) # 800066be <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006b96:	020a0a13          	addi	s4,s4,32
    80006b9a:	000ca783          	lw	a5,0(s9)
    80006b9e:	37fd                	addiw	a5,a5,-1
    80006ba0:	06f4d363          	bge	s1,a5,80006c06 <bd_free+0x106>
  int n = p - (char *) bd_base;
    80006ba4:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006ba8:	009b99b3          	sll	s3,s7,s1
    80006bac:	412a87bb          	subw	a5,s5,s2
    80006bb0:	0337c7b3          	div	a5,a5,s3
    80006bb4:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006bb8:	8b85                	andi	a5,a5,1
    80006bba:	fbcd                	bnez	a5,80006b6c <bd_free+0x6c>
    80006bbc:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006bc0:	fe0a0d13          	addi	s10,s4,-32
    80006bc4:	000b3783          	ld	a5,0(s6)
    80006bc8:	9d3e                	add	s10,s10,a5
    80006bca:	010d3503          	ld	a0,16(s10)
    80006bce:	00000097          	auipc	ra,0x0
    80006bd2:	af0080e7          	jalr	-1296(ra) # 800066be <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006bd6:	85ee                	mv	a1,s11
    80006bd8:	010d3503          	ld	a0,16(s10)
    80006bdc:	00000097          	auipc	ra,0x0
    80006be0:	a7a080e7          	jalr	-1414(ra) # 80006656 <bit_isset>
    80006be4:	e10d                	bnez	a0,80006c06 <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    80006be6:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006bea:	03b989bb          	mulw	s3,s3,s11
    80006bee:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006bf0:	854a                	mv	a0,s2
    80006bf2:	00000097          	auipc	ra,0x0
    80006bf6:	630080e7          	jalr	1584(ra) # 80007222 <lst_remove>
    if(buddy % 2 == 0) {
    80006bfa:	001d7d13          	andi	s10,s10,1
    80006bfe:	f60d1ae3          	bnez	s10,80006b72 <bd_free+0x72>
      p = q;
    80006c02:	8aca                	mv	s5,s2
    80006c04:	b7bd                	j	80006b72 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    80006c06:	0496                	slli	s1,s1,0x5
    80006c08:	85d6                	mv	a1,s5
    80006c0a:	00023517          	auipc	a0,0x23
    80006c0e:	44653503          	ld	a0,1094(a0) # 8002a050 <bd_sizes>
    80006c12:	9526                	add	a0,a0,s1
    80006c14:	00000097          	auipc	ra,0x0
    80006c18:	65a080e7          	jalr	1626(ra) # 8000726e <lst_push>
  release(&lock);
    80006c1c:	00023517          	auipc	a0,0x23
    80006c20:	3e450513          	addi	a0,a0,996 # 8002a000 <lock>
    80006c24:	ffffa097          	auipc	ra,0xffffa
    80006c28:	f02080e7          	jalr	-254(ra) # 80000b26 <release>
}
    80006c2c:	70a6                	ld	ra,104(sp)
    80006c2e:	7406                	ld	s0,96(sp)
    80006c30:	64e6                	ld	s1,88(sp)
    80006c32:	6946                	ld	s2,80(sp)
    80006c34:	69a6                	ld	s3,72(sp)
    80006c36:	6a06                	ld	s4,64(sp)
    80006c38:	7ae2                	ld	s5,56(sp)
    80006c3a:	7b42                	ld	s6,48(sp)
    80006c3c:	7ba2                	ld	s7,40(sp)
    80006c3e:	7c02                	ld	s8,32(sp)
    80006c40:	6ce2                	ld	s9,24(sp)
    80006c42:	6d42                	ld	s10,16(sp)
    80006c44:	6da2                	ld	s11,8(sp)
    80006c46:	6165                	addi	sp,sp,112
    80006c48:	8082                	ret

0000000080006c4a <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006c4a:	1141                	addi	sp,sp,-16
    80006c4c:	e422                	sd	s0,8(sp)
    80006c4e:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006c50:	00023797          	auipc	a5,0x23
    80006c54:	3f87b783          	ld	a5,1016(a5) # 8002a048 <bd_base>
    80006c58:	8d9d                	sub	a1,a1,a5
    80006c5a:	47c1                	li	a5,16
    80006c5c:	00a797b3          	sll	a5,a5,a0
    80006c60:	02f5c533          	div	a0,a1,a5
    80006c64:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006c66:	02f5e5b3          	rem	a1,a1,a5
    80006c6a:	c191                	beqz	a1,80006c6e <blk_index_next+0x24>
      n++;
    80006c6c:	2505                	addiw	a0,a0,1
  return n ;
}
    80006c6e:	6422                	ld	s0,8(sp)
    80006c70:	0141                	addi	sp,sp,16
    80006c72:	8082                	ret

0000000080006c74 <log2>:

int
log2(uint64 n) {
    80006c74:	1141                	addi	sp,sp,-16
    80006c76:	e422                	sd	s0,8(sp)
    80006c78:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006c7a:	4705                	li	a4,1
    80006c7c:	00a77b63          	bgeu	a4,a0,80006c92 <log2+0x1e>
    80006c80:	87aa                	mv	a5,a0
  int k = 0;
    80006c82:	4501                	li	a0,0
    k++;
    80006c84:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006c86:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006c88:	fef76ee3          	bltu	a4,a5,80006c84 <log2+0x10>
  }
  return k;
}
    80006c8c:	6422                	ld	s0,8(sp)
    80006c8e:	0141                	addi	sp,sp,16
    80006c90:	8082                	ret
  int k = 0;
    80006c92:	4501                	li	a0,0
    80006c94:	bfe5                	j	80006c8c <log2+0x18>

0000000080006c96 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006c96:	711d                	addi	sp,sp,-96
    80006c98:	ec86                	sd	ra,88(sp)
    80006c9a:	e8a2                	sd	s0,80(sp)
    80006c9c:	e4a6                	sd	s1,72(sp)
    80006c9e:	e0ca                	sd	s2,64(sp)
    80006ca0:	fc4e                	sd	s3,56(sp)
    80006ca2:	f852                	sd	s4,48(sp)
    80006ca4:	f456                	sd	s5,40(sp)
    80006ca6:	f05a                	sd	s6,32(sp)
    80006ca8:	ec5e                	sd	s7,24(sp)
    80006caa:	e862                	sd	s8,16(sp)
    80006cac:	e466                	sd	s9,8(sp)
    80006cae:	e06a                	sd	s10,0(sp)
    80006cb0:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006cb2:	00b56933          	or	s2,a0,a1
    80006cb6:	00f97913          	andi	s2,s2,15
    80006cba:	04091263          	bnez	s2,80006cfe <bd_mark+0x68>
    80006cbe:	8b2a                	mv	s6,a0
    80006cc0:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006cc2:	00023c17          	auipc	s8,0x23
    80006cc6:	396c2c03          	lw	s8,918(s8) # 8002a058 <nsizes>
    80006cca:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006ccc:	00023d17          	auipc	s10,0x23
    80006cd0:	37cd0d13          	addi	s10,s10,892 # 8002a048 <bd_base>
  return n / BLK_SIZE(k);
    80006cd4:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006cd6:	00023a97          	auipc	s5,0x23
    80006cda:	37aa8a93          	addi	s5,s5,890 # 8002a050 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006cde:	07804563          	bgtz	s8,80006d48 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006ce2:	60e6                	ld	ra,88(sp)
    80006ce4:	6446                	ld	s0,80(sp)
    80006ce6:	64a6                	ld	s1,72(sp)
    80006ce8:	6906                	ld	s2,64(sp)
    80006cea:	79e2                	ld	s3,56(sp)
    80006cec:	7a42                	ld	s4,48(sp)
    80006cee:	7aa2                	ld	s5,40(sp)
    80006cf0:	7b02                	ld	s6,32(sp)
    80006cf2:	6be2                	ld	s7,24(sp)
    80006cf4:	6c42                	ld	s8,16(sp)
    80006cf6:	6ca2                	ld	s9,8(sp)
    80006cf8:	6d02                	ld	s10,0(sp)
    80006cfa:	6125                	addi	sp,sp,96
    80006cfc:	8082                	ret
    panic("bd_mark");
    80006cfe:	00002517          	auipc	a0,0x2
    80006d02:	c5a50513          	addi	a0,a0,-934 # 80008958 <userret+0x8c8>
    80006d06:	ffffa097          	auipc	ra,0xffffa
    80006d0a:	842080e7          	jalr	-1982(ra) # 80000548 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006d0e:	000ab783          	ld	a5,0(s5)
    80006d12:	97ca                	add	a5,a5,s2
    80006d14:	85a6                	mv	a1,s1
    80006d16:	6b88                	ld	a0,16(a5)
    80006d18:	00000097          	auipc	ra,0x0
    80006d1c:	976080e7          	jalr	-1674(ra) # 8000668e <bit_set>
    for(; bi < bj; bi++) {
    80006d20:	2485                	addiw	s1,s1,1
    80006d22:	009a0e63          	beq	s4,s1,80006d3e <bd_mark+0xa8>
      if(k > 0) {
    80006d26:	ff3054e3          	blez	s3,80006d0e <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006d2a:	000ab783          	ld	a5,0(s5)
    80006d2e:	97ca                	add	a5,a5,s2
    80006d30:	85a6                	mv	a1,s1
    80006d32:	6f88                	ld	a0,24(a5)
    80006d34:	00000097          	auipc	ra,0x0
    80006d38:	95a080e7          	jalr	-1702(ra) # 8000668e <bit_set>
    80006d3c:	bfc9                	j	80006d0e <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006d3e:	2985                	addiw	s3,s3,1
    80006d40:	02090913          	addi	s2,s2,32
    80006d44:	f9898fe3          	beq	s3,s8,80006ce2 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006d48:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006d4c:	409b04bb          	subw	s1,s6,s1
    80006d50:	013c97b3          	sll	a5,s9,s3
    80006d54:	02f4c4b3          	div	s1,s1,a5
    80006d58:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006d5a:	85de                	mv	a1,s7
    80006d5c:	854e                	mv	a0,s3
    80006d5e:	00000097          	auipc	ra,0x0
    80006d62:	eec080e7          	jalr	-276(ra) # 80006c4a <blk_index_next>
    80006d66:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006d68:	faa4cfe3          	blt	s1,a0,80006d26 <bd_mark+0x90>
    80006d6c:	bfc9                	j	80006d3e <bd_mark+0xa8>

0000000080006d6e <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006d6e:	7139                	addi	sp,sp,-64
    80006d70:	fc06                	sd	ra,56(sp)
    80006d72:	f822                	sd	s0,48(sp)
    80006d74:	f426                	sd	s1,40(sp)
    80006d76:	f04a                	sd	s2,32(sp)
    80006d78:	ec4e                	sd	s3,24(sp)
    80006d7a:	e852                	sd	s4,16(sp)
    80006d7c:	e456                	sd	s5,8(sp)
    80006d7e:	e05a                	sd	s6,0(sp)
    80006d80:	0080                	addi	s0,sp,64
    80006d82:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006d84:	00058a9b          	sext.w	s5,a1
    80006d88:	0015f793          	andi	a5,a1,1
    80006d8c:	ebad                	bnez	a5,80006dfe <bd_initfree_pair+0x90>
    80006d8e:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006d92:	00599493          	slli	s1,s3,0x5
    80006d96:	00023797          	auipc	a5,0x23
    80006d9a:	2ba7b783          	ld	a5,698(a5) # 8002a050 <bd_sizes>
    80006d9e:	94be                	add	s1,s1,a5
    80006da0:	0104bb03          	ld	s6,16(s1)
    80006da4:	855a                	mv	a0,s6
    80006da6:	00000097          	auipc	ra,0x0
    80006daa:	8b0080e7          	jalr	-1872(ra) # 80006656 <bit_isset>
    80006dae:	892a                	mv	s2,a0
    80006db0:	85d2                	mv	a1,s4
    80006db2:	855a                	mv	a0,s6
    80006db4:	00000097          	auipc	ra,0x0
    80006db8:	8a2080e7          	jalr	-1886(ra) # 80006656 <bit_isset>
  int free = 0;
    80006dbc:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006dbe:	02a90563          	beq	s2,a0,80006de8 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006dc2:	45c1                	li	a1,16
    80006dc4:	013599b3          	sll	s3,a1,s3
    80006dc8:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006dcc:	02090c63          	beqz	s2,80006e04 <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006dd0:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006dd4:	00023597          	auipc	a1,0x23
    80006dd8:	2745b583          	ld	a1,628(a1) # 8002a048 <bd_base>
    80006ddc:	95ce                	add	a1,a1,s3
    80006dde:	8526                	mv	a0,s1
    80006de0:	00000097          	auipc	ra,0x0
    80006de4:	48e080e7          	jalr	1166(ra) # 8000726e <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006de8:	855a                	mv	a0,s6
    80006dea:	70e2                	ld	ra,56(sp)
    80006dec:	7442                	ld	s0,48(sp)
    80006dee:	74a2                	ld	s1,40(sp)
    80006df0:	7902                	ld	s2,32(sp)
    80006df2:	69e2                	ld	s3,24(sp)
    80006df4:	6a42                	ld	s4,16(sp)
    80006df6:	6aa2                	ld	s5,8(sp)
    80006df8:	6b02                	ld	s6,0(sp)
    80006dfa:	6121                	addi	sp,sp,64
    80006dfc:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006dfe:	fff58a1b          	addiw	s4,a1,-1
    80006e02:	bf41                	j	80006d92 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006e04:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006e08:	00023597          	auipc	a1,0x23
    80006e0c:	2405b583          	ld	a1,576(a1) # 8002a048 <bd_base>
    80006e10:	95ce                	add	a1,a1,s3
    80006e12:	8526                	mv	a0,s1
    80006e14:	00000097          	auipc	ra,0x0
    80006e18:	45a080e7          	jalr	1114(ra) # 8000726e <lst_push>
    80006e1c:	b7f1                	j	80006de8 <bd_initfree_pair+0x7a>

0000000080006e1e <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006e1e:	711d                	addi	sp,sp,-96
    80006e20:	ec86                	sd	ra,88(sp)
    80006e22:	e8a2                	sd	s0,80(sp)
    80006e24:	e4a6                	sd	s1,72(sp)
    80006e26:	e0ca                	sd	s2,64(sp)
    80006e28:	fc4e                	sd	s3,56(sp)
    80006e2a:	f852                	sd	s4,48(sp)
    80006e2c:	f456                	sd	s5,40(sp)
    80006e2e:	f05a                	sd	s6,32(sp)
    80006e30:	ec5e                	sd	s7,24(sp)
    80006e32:	e862                	sd	s8,16(sp)
    80006e34:	e466                	sd	s9,8(sp)
    80006e36:	e06a                	sd	s10,0(sp)
    80006e38:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006e3a:	00023717          	auipc	a4,0x23
    80006e3e:	21e72703          	lw	a4,542(a4) # 8002a058 <nsizes>
    80006e42:	4785                	li	a5,1
    80006e44:	06e7db63          	bge	a5,a4,80006eba <bd_initfree+0x9c>
    80006e48:	8aaa                	mv	s5,a0
    80006e4a:	8b2e                	mv	s6,a1
    80006e4c:	4901                	li	s2,0
  int free = 0;
    80006e4e:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006e50:	00023c97          	auipc	s9,0x23
    80006e54:	1f8c8c93          	addi	s9,s9,504 # 8002a048 <bd_base>
  return n / BLK_SIZE(k);
    80006e58:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006e5a:	00023b97          	auipc	s7,0x23
    80006e5e:	1feb8b93          	addi	s7,s7,510 # 8002a058 <nsizes>
    80006e62:	a039                	j	80006e70 <bd_initfree+0x52>
    80006e64:	2905                	addiw	s2,s2,1
    80006e66:	000ba783          	lw	a5,0(s7)
    80006e6a:	37fd                	addiw	a5,a5,-1
    80006e6c:	04f95863          	bge	s2,a5,80006ebc <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006e70:	85d6                	mv	a1,s5
    80006e72:	854a                	mv	a0,s2
    80006e74:	00000097          	auipc	ra,0x0
    80006e78:	dd6080e7          	jalr	-554(ra) # 80006c4a <blk_index_next>
    80006e7c:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006e7e:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006e82:	409b04bb          	subw	s1,s6,s1
    80006e86:	012c17b3          	sll	a5,s8,s2
    80006e8a:	02f4c4b3          	div	s1,s1,a5
    80006e8e:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006e90:	85aa                	mv	a1,a0
    80006e92:	854a                	mv	a0,s2
    80006e94:	00000097          	auipc	ra,0x0
    80006e98:	eda080e7          	jalr	-294(ra) # 80006d6e <bd_initfree_pair>
    80006e9c:	01450d3b          	addw	s10,a0,s4
    80006ea0:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006ea4:	fc99d0e3          	bge	s3,s1,80006e64 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006ea8:	85a6                	mv	a1,s1
    80006eaa:	854a                	mv	a0,s2
    80006eac:	00000097          	auipc	ra,0x0
    80006eb0:	ec2080e7          	jalr	-318(ra) # 80006d6e <bd_initfree_pair>
    80006eb4:	00ad0a3b          	addw	s4,s10,a0
    80006eb8:	b775                	j	80006e64 <bd_initfree+0x46>
  int free = 0;
    80006eba:	4a01                	li	s4,0
  }
  return free;
}
    80006ebc:	8552                	mv	a0,s4
    80006ebe:	60e6                	ld	ra,88(sp)
    80006ec0:	6446                	ld	s0,80(sp)
    80006ec2:	64a6                	ld	s1,72(sp)
    80006ec4:	6906                	ld	s2,64(sp)
    80006ec6:	79e2                	ld	s3,56(sp)
    80006ec8:	7a42                	ld	s4,48(sp)
    80006eca:	7aa2                	ld	s5,40(sp)
    80006ecc:	7b02                	ld	s6,32(sp)
    80006ece:	6be2                	ld	s7,24(sp)
    80006ed0:	6c42                	ld	s8,16(sp)
    80006ed2:	6ca2                	ld	s9,8(sp)
    80006ed4:	6d02                	ld	s10,0(sp)
    80006ed6:	6125                	addi	sp,sp,96
    80006ed8:	8082                	ret

0000000080006eda <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006eda:	7179                	addi	sp,sp,-48
    80006edc:	f406                	sd	ra,40(sp)
    80006ede:	f022                	sd	s0,32(sp)
    80006ee0:	ec26                	sd	s1,24(sp)
    80006ee2:	e84a                	sd	s2,16(sp)
    80006ee4:	e44e                	sd	s3,8(sp)
    80006ee6:	1800                	addi	s0,sp,48
    80006ee8:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006eea:	00023997          	auipc	s3,0x23
    80006eee:	15e98993          	addi	s3,s3,350 # 8002a048 <bd_base>
    80006ef2:	0009b483          	ld	s1,0(s3)
    80006ef6:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006efa:	00023797          	auipc	a5,0x23
    80006efe:	15e7a783          	lw	a5,350(a5) # 8002a058 <nsizes>
    80006f02:	37fd                	addiw	a5,a5,-1
    80006f04:	4641                	li	a2,16
    80006f06:	00f61633          	sll	a2,a2,a5
    80006f0a:	85a6                	mv	a1,s1
    80006f0c:	00002517          	auipc	a0,0x2
    80006f10:	a5450513          	addi	a0,a0,-1452 # 80008960 <userret+0x8d0>
    80006f14:	ffff9097          	auipc	ra,0xffff9
    80006f18:	67e080e7          	jalr	1662(ra) # 80000592 <printf>
  bd_mark(bd_base, p);
    80006f1c:	85ca                	mv	a1,s2
    80006f1e:	0009b503          	ld	a0,0(s3)
    80006f22:	00000097          	auipc	ra,0x0
    80006f26:	d74080e7          	jalr	-652(ra) # 80006c96 <bd_mark>
  return meta;
}
    80006f2a:	8526                	mv	a0,s1
    80006f2c:	70a2                	ld	ra,40(sp)
    80006f2e:	7402                	ld	s0,32(sp)
    80006f30:	64e2                	ld	s1,24(sp)
    80006f32:	6942                	ld	s2,16(sp)
    80006f34:	69a2                	ld	s3,8(sp)
    80006f36:	6145                	addi	sp,sp,48
    80006f38:	8082                	ret

0000000080006f3a <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006f3a:	1101                	addi	sp,sp,-32
    80006f3c:	ec06                	sd	ra,24(sp)
    80006f3e:	e822                	sd	s0,16(sp)
    80006f40:	e426                	sd	s1,8(sp)
    80006f42:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006f44:	00023497          	auipc	s1,0x23
    80006f48:	1144a483          	lw	s1,276(s1) # 8002a058 <nsizes>
    80006f4c:	fff4879b          	addiw	a5,s1,-1
    80006f50:	44c1                	li	s1,16
    80006f52:	00f494b3          	sll	s1,s1,a5
    80006f56:	00023797          	auipc	a5,0x23
    80006f5a:	0f27b783          	ld	a5,242(a5) # 8002a048 <bd_base>
    80006f5e:	8d1d                	sub	a0,a0,a5
    80006f60:	40a4853b          	subw	a0,s1,a0
    80006f64:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006f68:	00905a63          	blez	s1,80006f7c <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006f6c:	357d                	addiw	a0,a0,-1
    80006f6e:	41f5549b          	sraiw	s1,a0,0x1f
    80006f72:	01c4d49b          	srliw	s1,s1,0x1c
    80006f76:	9ca9                	addw	s1,s1,a0
    80006f78:	98c1                	andi	s1,s1,-16
    80006f7a:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006f7c:	85a6                	mv	a1,s1
    80006f7e:	00002517          	auipc	a0,0x2
    80006f82:	a1a50513          	addi	a0,a0,-1510 # 80008998 <userret+0x908>
    80006f86:	ffff9097          	auipc	ra,0xffff9
    80006f8a:	60c080e7          	jalr	1548(ra) # 80000592 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006f8e:	00023717          	auipc	a4,0x23
    80006f92:	0ba73703          	ld	a4,186(a4) # 8002a048 <bd_base>
    80006f96:	00023597          	auipc	a1,0x23
    80006f9a:	0c25a583          	lw	a1,194(a1) # 8002a058 <nsizes>
    80006f9e:	fff5879b          	addiw	a5,a1,-1
    80006fa2:	45c1                	li	a1,16
    80006fa4:	00f595b3          	sll	a1,a1,a5
    80006fa8:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006fac:	95ba                	add	a1,a1,a4
    80006fae:	953a                	add	a0,a0,a4
    80006fb0:	00000097          	auipc	ra,0x0
    80006fb4:	ce6080e7          	jalr	-794(ra) # 80006c96 <bd_mark>
  return unavailable;
}
    80006fb8:	8526                	mv	a0,s1
    80006fba:	60e2                	ld	ra,24(sp)
    80006fbc:	6442                	ld	s0,16(sp)
    80006fbe:	64a2                	ld	s1,8(sp)
    80006fc0:	6105                	addi	sp,sp,32
    80006fc2:	8082                	ret

0000000080006fc4 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80006fc4:	715d                	addi	sp,sp,-80
    80006fc6:	e486                	sd	ra,72(sp)
    80006fc8:	e0a2                	sd	s0,64(sp)
    80006fca:	fc26                	sd	s1,56(sp)
    80006fcc:	f84a                	sd	s2,48(sp)
    80006fce:	f44e                	sd	s3,40(sp)
    80006fd0:	f052                	sd	s4,32(sp)
    80006fd2:	ec56                	sd	s5,24(sp)
    80006fd4:	e85a                	sd	s6,16(sp)
    80006fd6:	e45e                	sd	s7,8(sp)
    80006fd8:	e062                	sd	s8,0(sp)
    80006fda:	0880                	addi	s0,sp,80
    80006fdc:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80006fde:	fff50493          	addi	s1,a0,-1
    80006fe2:	98c1                	andi	s1,s1,-16
    80006fe4:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80006fe6:	00002597          	auipc	a1,0x2
    80006fea:	9d258593          	addi	a1,a1,-1582 # 800089b8 <userret+0x928>
    80006fee:	00023517          	auipc	a0,0x23
    80006ff2:	01250513          	addi	a0,a0,18 # 8002a000 <lock>
    80006ff6:	ffffa097          	auipc	ra,0xffffa
    80006ffa:	9ba080e7          	jalr	-1606(ra) # 800009b0 <initlock>
  bd_base = (void *) p;
    80006ffe:	00023797          	auipc	a5,0x23
    80007002:	0497b523          	sd	s1,74(a5) # 8002a048 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007006:	409c0933          	sub	s2,s8,s1
    8000700a:	43f95513          	srai	a0,s2,0x3f
    8000700e:	893d                	andi	a0,a0,15
    80007010:	954a                	add	a0,a0,s2
    80007012:	8511                	srai	a0,a0,0x4
    80007014:	00000097          	auipc	ra,0x0
    80007018:	c60080e7          	jalr	-928(ra) # 80006c74 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    8000701c:	47c1                	li	a5,16
    8000701e:	00a797b3          	sll	a5,a5,a0
    80007022:	1b27c663          	blt	a5,s2,800071ce <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007026:	2505                	addiw	a0,a0,1
    80007028:	00023797          	auipc	a5,0x23
    8000702c:	02a7a823          	sw	a0,48(a5) # 8002a058 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80007030:	00023997          	auipc	s3,0x23
    80007034:	02898993          	addi	s3,s3,40 # 8002a058 <nsizes>
    80007038:	0009a603          	lw	a2,0(s3)
    8000703c:	85ca                	mv	a1,s2
    8000703e:	00002517          	auipc	a0,0x2
    80007042:	98250513          	addi	a0,a0,-1662 # 800089c0 <userret+0x930>
    80007046:	ffff9097          	auipc	ra,0xffff9
    8000704a:	54c080e7          	jalr	1356(ra) # 80000592 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    8000704e:	00023797          	auipc	a5,0x23
    80007052:	0097b123          	sd	s1,2(a5) # 8002a050 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80007056:	0009a603          	lw	a2,0(s3)
    8000705a:	00561913          	slli	s2,a2,0x5
    8000705e:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80007060:	0056161b          	slliw	a2,a2,0x5
    80007064:	4581                	li	a1,0
    80007066:	8526                	mv	a0,s1
    80007068:	ffffa097          	auipc	ra,0xffffa
    8000706c:	b1a080e7          	jalr	-1254(ra) # 80000b82 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80007070:	0009a783          	lw	a5,0(s3)
    80007074:	06f05a63          	blez	a5,800070e8 <bd_init+0x124>
    80007078:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    8000707a:	00023a97          	auipc	s5,0x23
    8000707e:	fd6a8a93          	addi	s5,s5,-42 # 8002a050 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007082:	00023a17          	auipc	s4,0x23
    80007086:	fd6a0a13          	addi	s4,s4,-42 # 8002a058 <nsizes>
    8000708a:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    8000708c:	00599b93          	slli	s7,s3,0x5
    80007090:	000ab503          	ld	a0,0(s5)
    80007094:	955e                	add	a0,a0,s7
    80007096:	00000097          	auipc	ra,0x0
    8000709a:	166080e7          	jalr	358(ra) # 800071fc <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    8000709e:	000a2483          	lw	s1,0(s4)
    800070a2:	34fd                	addiw	s1,s1,-1
    800070a4:	413484bb          	subw	s1,s1,s3
    800070a8:	009b14bb          	sllw	s1,s6,s1
    800070ac:	fff4879b          	addiw	a5,s1,-1
    800070b0:	41f7d49b          	sraiw	s1,a5,0x1f
    800070b4:	01d4d49b          	srliw	s1,s1,0x1d
    800070b8:	9cbd                	addw	s1,s1,a5
    800070ba:	98e1                	andi	s1,s1,-8
    800070bc:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    800070be:	000ab783          	ld	a5,0(s5)
    800070c2:	9bbe                	add	s7,s7,a5
    800070c4:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    800070c8:	848d                	srai	s1,s1,0x3
    800070ca:	8626                	mv	a2,s1
    800070cc:	4581                	li	a1,0
    800070ce:	854a                	mv	a0,s2
    800070d0:	ffffa097          	auipc	ra,0xffffa
    800070d4:	ab2080e7          	jalr	-1358(ra) # 80000b82 <memset>
    p += sz;
    800070d8:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    800070da:	0985                	addi	s3,s3,1
    800070dc:	000a2703          	lw	a4,0(s4)
    800070e0:	0009879b          	sext.w	a5,s3
    800070e4:	fae7c4e3          	blt	a5,a4,8000708c <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    800070e8:	00023797          	auipc	a5,0x23
    800070ec:	f707a783          	lw	a5,-144(a5) # 8002a058 <nsizes>
    800070f0:	4705                	li	a4,1
    800070f2:	06f75163          	bge	a4,a5,80007154 <bd_init+0x190>
    800070f6:	02000a13          	li	s4,32
    800070fa:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    800070fc:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    800070fe:	00023b17          	auipc	s6,0x23
    80007102:	f52b0b13          	addi	s6,s6,-174 # 8002a050 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80007106:	00023a97          	auipc	s5,0x23
    8000710a:	f52a8a93          	addi	s5,s5,-174 # 8002a058 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000710e:	37fd                	addiw	a5,a5,-1
    80007110:	413787bb          	subw	a5,a5,s3
    80007114:	00fb94bb          	sllw	s1,s7,a5
    80007118:	fff4879b          	addiw	a5,s1,-1
    8000711c:	41f7d49b          	sraiw	s1,a5,0x1f
    80007120:	01d4d49b          	srliw	s1,s1,0x1d
    80007124:	9cbd                	addw	s1,s1,a5
    80007126:	98e1                	andi	s1,s1,-8
    80007128:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    8000712a:	000b3783          	ld	a5,0(s6)
    8000712e:	97d2                	add	a5,a5,s4
    80007130:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80007134:	848d                	srai	s1,s1,0x3
    80007136:	8626                	mv	a2,s1
    80007138:	4581                	li	a1,0
    8000713a:	854a                	mv	a0,s2
    8000713c:	ffffa097          	auipc	ra,0xffffa
    80007140:	a46080e7          	jalr	-1466(ra) # 80000b82 <memset>
    p += sz;
    80007144:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80007146:	2985                	addiw	s3,s3,1
    80007148:	000aa783          	lw	a5,0(s5)
    8000714c:	020a0a13          	addi	s4,s4,32
    80007150:	faf9cfe3          	blt	s3,a5,8000710e <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80007154:	197d                	addi	s2,s2,-1
    80007156:	ff097913          	andi	s2,s2,-16
    8000715a:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    8000715c:	854a                	mv	a0,s2
    8000715e:	00000097          	auipc	ra,0x0
    80007162:	d7c080e7          	jalr	-644(ra) # 80006eda <bd_mark_data_structures>
    80007166:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80007168:	85ca                	mv	a1,s2
    8000716a:	8562                	mv	a0,s8
    8000716c:	00000097          	auipc	ra,0x0
    80007170:	dce080e7          	jalr	-562(ra) # 80006f3a <bd_mark_unavailable>
    80007174:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007176:	00023a97          	auipc	s5,0x23
    8000717a:	ee2a8a93          	addi	s5,s5,-286 # 8002a058 <nsizes>
    8000717e:	000aa783          	lw	a5,0(s5)
    80007182:	37fd                	addiw	a5,a5,-1
    80007184:	44c1                	li	s1,16
    80007186:	00f497b3          	sll	a5,s1,a5
    8000718a:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    8000718c:	00023597          	auipc	a1,0x23
    80007190:	ebc5b583          	ld	a1,-324(a1) # 8002a048 <bd_base>
    80007194:	95be                	add	a1,a1,a5
    80007196:	854a                	mv	a0,s2
    80007198:	00000097          	auipc	ra,0x0
    8000719c:	c86080e7          	jalr	-890(ra) # 80006e1e <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    800071a0:	000aa603          	lw	a2,0(s5)
    800071a4:	367d                	addiw	a2,a2,-1
    800071a6:	00c49633          	sll	a2,s1,a2
    800071aa:	41460633          	sub	a2,a2,s4
    800071ae:	41360633          	sub	a2,a2,s3
    800071b2:	02c51463          	bne	a0,a2,800071da <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    800071b6:	60a6                	ld	ra,72(sp)
    800071b8:	6406                	ld	s0,64(sp)
    800071ba:	74e2                	ld	s1,56(sp)
    800071bc:	7942                	ld	s2,48(sp)
    800071be:	79a2                	ld	s3,40(sp)
    800071c0:	7a02                	ld	s4,32(sp)
    800071c2:	6ae2                	ld	s5,24(sp)
    800071c4:	6b42                	ld	s6,16(sp)
    800071c6:	6ba2                	ld	s7,8(sp)
    800071c8:	6c02                	ld	s8,0(sp)
    800071ca:	6161                	addi	sp,sp,80
    800071cc:	8082                	ret
    nsizes++;  // round up to the next power of 2
    800071ce:	2509                	addiw	a0,a0,2
    800071d0:	00023797          	auipc	a5,0x23
    800071d4:	e8a7a423          	sw	a0,-376(a5) # 8002a058 <nsizes>
    800071d8:	bda1                	j	80007030 <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    800071da:	85aa                	mv	a1,a0
    800071dc:	00002517          	auipc	a0,0x2
    800071e0:	82450513          	addi	a0,a0,-2012 # 80008a00 <userret+0x970>
    800071e4:	ffff9097          	auipc	ra,0xffff9
    800071e8:	3ae080e7          	jalr	942(ra) # 80000592 <printf>
    panic("bd_init: free mem");
    800071ec:	00002517          	auipc	a0,0x2
    800071f0:	82450513          	addi	a0,a0,-2012 # 80008a10 <userret+0x980>
    800071f4:	ffff9097          	auipc	ra,0xffff9
    800071f8:	354080e7          	jalr	852(ra) # 80000548 <panic>

00000000800071fc <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    800071fc:	1141                	addi	sp,sp,-16
    800071fe:	e422                	sd	s0,8(sp)
    80007200:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007202:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80007204:	e508                	sd	a0,8(a0)
}
    80007206:	6422                	ld	s0,8(sp)
    80007208:	0141                	addi	sp,sp,16
    8000720a:	8082                	ret

000000008000720c <lst_empty>:

int
lst_empty(struct list *lst) {
    8000720c:	1141                	addi	sp,sp,-16
    8000720e:	e422                	sd	s0,8(sp)
    80007210:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007212:	611c                	ld	a5,0(a0)
    80007214:	40a78533          	sub	a0,a5,a0
}
    80007218:	00153513          	seqz	a0,a0
    8000721c:	6422                	ld	s0,8(sp)
    8000721e:	0141                	addi	sp,sp,16
    80007220:	8082                	ret

0000000080007222 <lst_remove>:

void
lst_remove(struct list *e) {
    80007222:	1141                	addi	sp,sp,-16
    80007224:	e422                	sd	s0,8(sp)
    80007226:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007228:	6518                	ld	a4,8(a0)
    8000722a:	611c                	ld	a5,0(a0)
    8000722c:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    8000722e:	6518                	ld	a4,8(a0)
    80007230:	e798                	sd	a4,8(a5)
}
    80007232:	6422                	ld	s0,8(sp)
    80007234:	0141                	addi	sp,sp,16
    80007236:	8082                	ret

0000000080007238 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007238:	1101                	addi	sp,sp,-32
    8000723a:	ec06                	sd	ra,24(sp)
    8000723c:	e822                	sd	s0,16(sp)
    8000723e:	e426                	sd	s1,8(sp)
    80007240:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007242:	6104                	ld	s1,0(a0)
    80007244:	00a48d63          	beq	s1,a0,8000725e <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007248:	8526                	mv	a0,s1
    8000724a:	00000097          	auipc	ra,0x0
    8000724e:	fd8080e7          	jalr	-40(ra) # 80007222 <lst_remove>
  return (void *)p;
}
    80007252:	8526                	mv	a0,s1
    80007254:	60e2                	ld	ra,24(sp)
    80007256:	6442                	ld	s0,16(sp)
    80007258:	64a2                	ld	s1,8(sp)
    8000725a:	6105                	addi	sp,sp,32
    8000725c:	8082                	ret
    panic("lst_pop");
    8000725e:	00001517          	auipc	a0,0x1
    80007262:	7ca50513          	addi	a0,a0,1994 # 80008a28 <userret+0x998>
    80007266:	ffff9097          	auipc	ra,0xffff9
    8000726a:	2e2080e7          	jalr	738(ra) # 80000548 <panic>

000000008000726e <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    8000726e:	1141                	addi	sp,sp,-16
    80007270:	e422                	sd	s0,8(sp)
    80007272:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    80007274:	611c                	ld	a5,0(a0)
    80007276:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    80007278:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    8000727a:	611c                	ld	a5,0(a0)
    8000727c:	e78c                	sd	a1,8(a5)
  lst->next = e;
    8000727e:	e10c                	sd	a1,0(a0)
}
    80007280:	6422                	ld	s0,8(sp)
    80007282:	0141                	addi	sp,sp,16
    80007284:	8082                	ret

0000000080007286 <lst_print>:

void
lst_print(struct list *lst)
{
    80007286:	7179                	addi	sp,sp,-48
    80007288:	f406                	sd	ra,40(sp)
    8000728a:	f022                	sd	s0,32(sp)
    8000728c:	ec26                	sd	s1,24(sp)
    8000728e:	e84a                	sd	s2,16(sp)
    80007290:	e44e                	sd	s3,8(sp)
    80007292:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007294:	6104                	ld	s1,0(a0)
    80007296:	02950063          	beq	a0,s1,800072b6 <lst_print+0x30>
    8000729a:	892a                	mv	s2,a0
    printf(" %p", p);
    8000729c:	00001997          	auipc	s3,0x1
    800072a0:	79498993          	addi	s3,s3,1940 # 80008a30 <userret+0x9a0>
    800072a4:	85a6                	mv	a1,s1
    800072a6:	854e                	mv	a0,s3
    800072a8:	ffff9097          	auipc	ra,0xffff9
    800072ac:	2ea080e7          	jalr	746(ra) # 80000592 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800072b0:	6084                	ld	s1,0(s1)
    800072b2:	fe9919e3          	bne	s2,s1,800072a4 <lst_print+0x1e>
  }
  printf("\n");
    800072b6:	00001517          	auipc	a0,0x1
    800072ba:	efa50513          	addi	a0,a0,-262 # 800081b0 <userret+0x120>
    800072be:	ffff9097          	auipc	ra,0xffff9
    800072c2:	2d4080e7          	jalr	724(ra) # 80000592 <printf>
}
    800072c6:	70a2                	ld	ra,40(sp)
    800072c8:	7402                	ld	s0,32(sp)
    800072ca:	64e2                	ld	s1,24(sp)
    800072cc:	6942                	ld	s2,16(sp)
    800072ce:	69a2                	ld	s3,8(sp)
    800072d0:	6145                	addi	sp,sp,48
    800072d2:	8082                	ret
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
