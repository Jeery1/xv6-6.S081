
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
    80000060:	02478793          	addi	a5,a5,36 # 80006080 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffce7a3>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	05e78793          	addi	a5,a5,94 # 80001104 <main>
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
    80000112:	bda080e7          	jalr	-1062(ra) # 80000ce8 <acquire>
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
    80000122:	78290913          	addi	s2,s2,1922 # 800128a0 <cons+0xa0>
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
    80000130:	0a04a783          	lw	a5,160(s1)
    80000134:	0a44a703          	lw	a4,164(s1)
    80000138:	02f71463          	bne	a4,a5,80000160 <consoleread+0x80>
      if(myproc()->killed){
    8000013c:	00002097          	auipc	ra,0x2
    80000140:	b04080e7          	jalr	-1276(ra) # 80001c40 <myproc>
    80000144:	5d1c                	lw	a5,56(a0)
    80000146:	e7b5                	bnez	a5,800001b2 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    80000148:	85a6                	mv	a1,s1
    8000014a:	854a                	mv	a0,s2
    8000014c:	00002097          	auipc	ra,0x2
    80000150:	2ca080e7          	jalr	714(ra) # 80002416 <sleep>
    while(cons.r == cons.w){
    80000154:	0a04a783          	lw	a5,160(s1)
    80000158:	0a44a703          	lw	a4,164(s1)
    8000015c:	fef700e3          	beq	a4,a5,8000013c <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80000160:	0017871b          	addiw	a4,a5,1
    80000164:	0ae4a023          	sw	a4,160(s1)
    80000168:	07f7f713          	andi	a4,a5,127
    8000016c:	9726                	add	a4,a4,s1
    8000016e:	02074703          	lbu	a4,32(a4)
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
    8000018c:	4e8080e7          	jalr	1256(ra) # 80002670 <either_copyout>
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
    800001a8:	bb4080e7          	jalr	-1100(ra) # 80000d58 <release>

  return target - n;
    800001ac:	413b053b          	subw	a0,s6,s3
    800001b0:	a811                	j	800001c4 <consoleread+0xe4>
        release(&cons.lock);
    800001b2:	00012517          	auipc	a0,0x12
    800001b6:	64e50513          	addi	a0,a0,1614 # 80012800 <cons>
    800001ba:	00001097          	auipc	ra,0x1
    800001be:	b9e080e7          	jalr	-1122(ra) # 80000d58 <release>
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
    800001ec:	6af72c23          	sw	a5,1720(a4) # 800128a0 <cons+0xa0>
    800001f0:	b775                	j	8000019c <consoleread+0xbc>

00000000800001f2 <consputc>:
  if(panicked){
    800001f2:	00030797          	auipc	a5,0x30
    800001f6:	e2e7a783          	lw	a5,-466(a5) # 80030020 <panicked>
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
    80000212:	5dc080e7          	jalr	1500(ra) # 800007ea <uartputc>
}
    80000216:	60a2                	ld	ra,8(sp)
    80000218:	6402                	ld	s0,0(sp)
    8000021a:	0141                	addi	sp,sp,16
    8000021c:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    8000021e:	4521                	li	a0,8
    80000220:	00000097          	auipc	ra,0x0
    80000224:	5ca080e7          	jalr	1482(ra) # 800007ea <uartputc>
    80000228:	02000513          	li	a0,32
    8000022c:	00000097          	auipc	ra,0x0
    80000230:	5be080e7          	jalr	1470(ra) # 800007ea <uartputc>
    80000234:	4521                	li	a0,8
    80000236:	00000097          	auipc	ra,0x0
    8000023a:	5b4080e7          	jalr	1460(ra) # 800007ea <uartputc>
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
    80000264:	a88080e7          	jalr	-1400(ra) # 80000ce8 <acquire>
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
    8000028a:	440080e7          	jalr	1088(ra) # 800026c6 <either_copyin>
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
    800002b0:	aac080e7          	jalr	-1364(ra) # 80000d58 <release>
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
    800002de:	00001097          	auipc	ra,0x1
    800002e2:	a0a080e7          	jalr	-1526(ra) # 80000ce8 <acquire>

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
    80000300:	420080e7          	jalr	1056(ra) # 8000271c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00012517          	auipc	a0,0x12
    80000308:	4fc50513          	addi	a0,a0,1276 # 80012800 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	a4c080e7          	jalr	-1460(ra) # 80000d58 <release>
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
    80000330:	0a872783          	lw	a5,168(a4)
    80000334:	0a072703          	lw	a4,160(a4)
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
    8000035a:	0a87a703          	lw	a4,168(a5)
    8000035e:	0017069b          	addiw	a3,a4,1
    80000362:	0006861b          	sext.w	a2,a3
    80000366:	0ad7a423          	sw	a3,168(a5)
    8000036a:	07f77713          	andi	a4,a4,127
    8000036e:	97ba                	add	a5,a5,a4
    80000370:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000374:	47a9                	li	a5,10
    80000376:	0cf48563          	beq	s1,a5,80000440 <consoleintr+0x178>
    8000037a:	4791                	li	a5,4
    8000037c:	0cf48263          	beq	s1,a5,80000440 <consoleintr+0x178>
    80000380:	00012797          	auipc	a5,0x12
    80000384:	5207a783          	lw	a5,1312(a5) # 800128a0 <cons+0xa0>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00012717          	auipc	a4,0x12
    80000398:	46c70713          	addi	a4,a4,1132 # 80012800 <cons>
    8000039c:	0a872783          	lw	a5,168(a4)
    800003a0:	0a472703          	lw	a4,164(a4)
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
    800003ba:	02074703          	lbu	a4,32(a4)
    800003be:	f52703e3          	beq	a4,s2,80000304 <consoleintr+0x3c>
      cons.e--;
    800003c2:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	00000097          	auipc	ra,0x0
    800003ce:	e28080e7          	jalr	-472(ra) # 800001f2 <consputc>
    while(cons.e != cons.w &&
    800003d2:	0a84a783          	lw	a5,168(s1)
    800003d6:	0a44a703          	lw	a4,164(s1)
    800003da:	fcf71ce3          	bne	a4,a5,800003b2 <consoleintr+0xea>
    800003de:	b71d                	j	80000304 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e0:	00012717          	auipc	a4,0x12
    800003e4:	42070713          	addi	a4,a4,1056 # 80012800 <cons>
    800003e8:	0a872783          	lw	a5,168(a4)
    800003ec:	0a472703          	lw	a4,164(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00012717          	auipc	a4,0x12
    800003fa:	4af72923          	sw	a5,1202(a4) # 800128a8 <cons+0xa8>
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
    80000424:	0a87a703          	lw	a4,168(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a423          	sw	a3,168(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    80000440:	00012797          	auipc	a5,0x12
    80000444:	46c7a223          	sw	a2,1124(a5) # 800128a4 <cons+0xa4>
        wakeup(&cons.r);
    80000448:	00012517          	auipc	a0,0x12
    8000044c:	45850513          	addi	a0,a0,1112 # 800128a0 <cons+0xa0>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	146080e7          	jalr	326(ra) # 80002596 <wakeup>
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
    80000476:	728080e7          	jalr	1832(ra) # 80000b9a <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	33a080e7          	jalr	826(ra) # 800007b4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00028797          	auipc	a5,0x28
    80000486:	23678793          	addi	a5,a5,566 # 800286b8 <devsw>
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
    800004c8:	66460613          	addi	a2,a2,1636 # 80008b28 <digits>
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
    80000558:	3607ae23          	sw	zero,892(a5) # 800128d0 <pr+0x20>
  printf("PANIC: ");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	bc450513          	addi	a0,a0,-1084 # 80008120 <userret+0x90>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	03e080e7          	jalr	62(ra) # 800005a2 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	034080e7          	jalr	52(ra) # 800005a2 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	d6a50513          	addi	a0,a0,-662 # 800082e0 <userret+0x250>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	024080e7          	jalr	36(ra) # 800005a2 <printf>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    80000586:	00008517          	auipc	a0,0x8
    8000058a:	ba250513          	addi	a0,a0,-1118 # 80008128 <userret+0x98>
    8000058e:	00000097          	auipc	ra,0x0
    80000592:	014080e7          	jalr	20(ra) # 800005a2 <printf>
  panicked = 1; // freeze other CPUs
    80000596:	4785                	li	a5,1
    80000598:	00030717          	auipc	a4,0x30
    8000059c:	a8f72423          	sw	a5,-1400(a4) # 80030020 <panicked>
  for(;;)
    800005a0:	a001                	j	800005a0 <panic+0x58>

00000000800005a2 <printf>:
{
    800005a2:	7131                	addi	sp,sp,-192
    800005a4:	fc86                	sd	ra,120(sp)
    800005a6:	f8a2                	sd	s0,112(sp)
    800005a8:	f4a6                	sd	s1,104(sp)
    800005aa:	f0ca                	sd	s2,96(sp)
    800005ac:	ecce                	sd	s3,88(sp)
    800005ae:	e8d2                	sd	s4,80(sp)
    800005b0:	e4d6                	sd	s5,72(sp)
    800005b2:	e0da                	sd	s6,64(sp)
    800005b4:	fc5e                	sd	s7,56(sp)
    800005b6:	f862                	sd	s8,48(sp)
    800005b8:	f466                	sd	s9,40(sp)
    800005ba:	f06a                	sd	s10,32(sp)
    800005bc:	ec6e                	sd	s11,24(sp)
    800005be:	0100                	addi	s0,sp,128
    800005c0:	8a2a                	mv	s4,a0
    800005c2:	e40c                	sd	a1,8(s0)
    800005c4:	e810                	sd	a2,16(s0)
    800005c6:	ec14                	sd	a3,24(s0)
    800005c8:	f018                	sd	a4,32(s0)
    800005ca:	f41c                	sd	a5,40(s0)
    800005cc:	03043823          	sd	a6,48(s0)
    800005d0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005d4:	00012d97          	auipc	s11,0x12
    800005d8:	2fcdad83          	lw	s11,764(s11) # 800128d0 <pr+0x20>
  if(locking)
    800005dc:	020d9b63          	bnez	s11,80000612 <printf+0x70>
  if (fmt == 0)
    800005e0:	040a0263          	beqz	s4,80000624 <printf+0x82>
  va_start(ap, fmt);
    800005e4:	00840793          	addi	a5,s0,8
    800005e8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005ec:	000a4503          	lbu	a0,0(s4)
    800005f0:	14050f63          	beqz	a0,8000074e <printf+0x1ac>
    800005f4:	4981                	li	s3,0
    if(c != '%'){
    800005f6:	02500a93          	li	s5,37
    switch(c){
    800005fa:	07000b93          	li	s7,112
  consputc('x');
    800005fe:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000600:	00008b17          	auipc	s6,0x8
    80000604:	528b0b13          	addi	s6,s6,1320 # 80008b28 <digits>
    switch(c){
    80000608:	07300c93          	li	s9,115
    8000060c:	06400c13          	li	s8,100
    80000610:	a82d                	j	8000064a <printf+0xa8>
    acquire(&pr.lock);
    80000612:	00012517          	auipc	a0,0x12
    80000616:	29e50513          	addi	a0,a0,670 # 800128b0 <pr>
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	6ce080e7          	jalr	1742(ra) # 80000ce8 <acquire>
    80000622:	bf7d                	j	800005e0 <printf+0x3e>
    panic("null fmt");
    80000624:	00008517          	auipc	a0,0x8
    80000628:	bdc50513          	addi	a0,a0,-1060 # 80008200 <userret+0x170>
    8000062c:	00000097          	auipc	ra,0x0
    80000630:	f1c080e7          	jalr	-228(ra) # 80000548 <panic>
      consputc(c);
    80000634:	00000097          	auipc	ra,0x0
    80000638:	bbe080e7          	jalr	-1090(ra) # 800001f2 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000063c:	2985                	addiw	s3,s3,1
    8000063e:	013a07b3          	add	a5,s4,s3
    80000642:	0007c503          	lbu	a0,0(a5)
    80000646:	10050463          	beqz	a0,8000074e <printf+0x1ac>
    if(c != '%'){
    8000064a:	ff5515e3          	bne	a0,s5,80000634 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000064e:	2985                	addiw	s3,s3,1
    80000650:	013a07b3          	add	a5,s4,s3
    80000654:	0007c783          	lbu	a5,0(a5)
    80000658:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000065c:	cbed                	beqz	a5,8000074e <printf+0x1ac>
    switch(c){
    8000065e:	05778a63          	beq	a5,s7,800006b2 <printf+0x110>
    80000662:	02fbf663          	bgeu	s7,a5,8000068e <printf+0xec>
    80000666:	09978863          	beq	a5,s9,800006f6 <printf+0x154>
    8000066a:	07800713          	li	a4,120
    8000066e:	0ce79563          	bne	a5,a4,80000738 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000672:	f8843783          	ld	a5,-120(s0)
    80000676:	00878713          	addi	a4,a5,8
    8000067a:	f8e43423          	sd	a4,-120(s0)
    8000067e:	4605                	li	a2,1
    80000680:	85ea                	mv	a1,s10
    80000682:	4388                	lw	a0,0(a5)
    80000684:	00000097          	auipc	ra,0x0
    80000688:	e22080e7          	jalr	-478(ra) # 800004a6 <printint>
      break;
    8000068c:	bf45                	j	8000063c <printf+0x9a>
    switch(c){
    8000068e:	09578f63          	beq	a5,s5,8000072c <printf+0x18a>
    80000692:	0b879363          	bne	a5,s8,80000738 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4605                	li	a2,1
    800006a4:	45a9                	li	a1,10
    800006a6:	4388                	lw	a0,0(a5)
    800006a8:	00000097          	auipc	ra,0x0
    800006ac:	dfe080e7          	jalr	-514(ra) # 800004a6 <printint>
      break;
    800006b0:	b771                	j	8000063c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006c2:	03000513          	li	a0,48
    800006c6:	00000097          	auipc	ra,0x0
    800006ca:	b2c080e7          	jalr	-1236(ra) # 800001f2 <consputc>
  consputc('x');
    800006ce:	07800513          	li	a0,120
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	b20080e7          	jalr	-1248(ra) # 800001f2 <consputc>
    800006da:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006dc:	03c95793          	srli	a5,s2,0x3c
    800006e0:	97da                	add	a5,a5,s6
    800006e2:	0007c503          	lbu	a0,0(a5)
    800006e6:	00000097          	auipc	ra,0x0
    800006ea:	b0c080e7          	jalr	-1268(ra) # 800001f2 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006ee:	0912                	slli	s2,s2,0x4
    800006f0:	34fd                	addiw	s1,s1,-1
    800006f2:	f4ed                	bnez	s1,800006dc <printf+0x13a>
    800006f4:	b7a1                	j	8000063c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006f6:	f8843783          	ld	a5,-120(s0)
    800006fa:	00878713          	addi	a4,a5,8
    800006fe:	f8e43423          	sd	a4,-120(s0)
    80000702:	6384                	ld	s1,0(a5)
    80000704:	cc89                	beqz	s1,8000071e <printf+0x17c>
      for(; *s; s++)
    80000706:	0004c503          	lbu	a0,0(s1)
    8000070a:	d90d                	beqz	a0,8000063c <printf+0x9a>
        consputc(*s);
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	ae6080e7          	jalr	-1306(ra) # 800001f2 <consputc>
      for(; *s; s++)
    80000714:	0485                	addi	s1,s1,1
    80000716:	0004c503          	lbu	a0,0(s1)
    8000071a:	f96d                	bnez	a0,8000070c <printf+0x16a>
    8000071c:	b705                	j	8000063c <printf+0x9a>
        s = "(null)";
    8000071e:	00008497          	auipc	s1,0x8
    80000722:	ada48493          	addi	s1,s1,-1318 # 800081f8 <userret+0x168>
      for(; *s; s++)
    80000726:	02800513          	li	a0,40
    8000072a:	b7cd                	j	8000070c <printf+0x16a>
      consputc('%');
    8000072c:	8556                	mv	a0,s5
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	ac4080e7          	jalr	-1340(ra) # 800001f2 <consputc>
      break;
    80000736:	b719                	j	8000063c <printf+0x9a>
      consputc('%');
    80000738:	8556                	mv	a0,s5
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	ab8080e7          	jalr	-1352(ra) # 800001f2 <consputc>
      consputc(c);
    80000742:	8526                	mv	a0,s1
    80000744:	00000097          	auipc	ra,0x0
    80000748:	aae080e7          	jalr	-1362(ra) # 800001f2 <consputc>
      break;
    8000074c:	bdc5                	j	8000063c <printf+0x9a>
  if(locking)
    8000074e:	020d9163          	bnez	s11,80000770 <printf+0x1ce>
}
    80000752:	70e6                	ld	ra,120(sp)
    80000754:	7446                	ld	s0,112(sp)
    80000756:	74a6                	ld	s1,104(sp)
    80000758:	7906                	ld	s2,96(sp)
    8000075a:	69e6                	ld	s3,88(sp)
    8000075c:	6a46                	ld	s4,80(sp)
    8000075e:	6aa6                	ld	s5,72(sp)
    80000760:	6b06                	ld	s6,64(sp)
    80000762:	7be2                	ld	s7,56(sp)
    80000764:	7c42                	ld	s8,48(sp)
    80000766:	7ca2                	ld	s9,40(sp)
    80000768:	7d02                	ld	s10,32(sp)
    8000076a:	6de2                	ld	s11,24(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    release(&pr.lock);
    80000770:	00012517          	auipc	a0,0x12
    80000774:	14050513          	addi	a0,a0,320 # 800128b0 <pr>
    80000778:	00000097          	auipc	ra,0x0
    8000077c:	5e0080e7          	jalr	1504(ra) # 80000d58 <release>
}
    80000780:	bfc9                	j	80000752 <printf+0x1b0>

0000000080000782 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000782:	1101                	addi	sp,sp,-32
    80000784:	ec06                	sd	ra,24(sp)
    80000786:	e822                	sd	s0,16(sp)
    80000788:	e426                	sd	s1,8(sp)
    8000078a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000078c:	00012497          	auipc	s1,0x12
    80000790:	12448493          	addi	s1,s1,292 # 800128b0 <pr>
    80000794:	00008597          	auipc	a1,0x8
    80000798:	a7c58593          	addi	a1,a1,-1412 # 80008210 <userret+0x180>
    8000079c:	8526                	mv	a0,s1
    8000079e:	00000097          	auipc	ra,0x0
    800007a2:	3fc080e7          	jalr	1020(ra) # 80000b9a <initlock>
  pr.locking = 1;
    800007a6:	4785                	li	a5,1
    800007a8:	d09c                	sw	a5,32(s1)
}
    800007aa:	60e2                	ld	ra,24(sp)
    800007ac:	6442                	ld	s0,16(sp)
    800007ae:	64a2                	ld	s1,8(sp)
    800007b0:	6105                	addi	sp,sp,32
    800007b2:	8082                	ret

00000000800007b4 <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    800007b4:	1141                	addi	sp,sp,-16
    800007b6:	e422                	sd	s0,8(sp)
    800007b8:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ba:	100007b7          	lui	a5,0x10000
    800007be:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    800007c2:	f8000713          	li	a4,-128
    800007c6:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ca:	470d                	li	a4,3
    800007cc:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007d0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    800007d4:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    800007d8:	471d                	li	a4,7
    800007da:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    800007de:	4705                	li	a4,1
    800007e0:	00e780a3          	sb	a4,1(a5)
}
    800007e4:	6422                	ld	s0,8(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    800007ea:	1141                	addi	sp,sp,-16
    800007ec:	e422                	sd	s0,8(sp)
    800007ee:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    800007f0:	10000737          	lui	a4,0x10000
    800007f4:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007f8:	0207f793          	andi	a5,a5,32
    800007fc:	dfe5                	beqz	a5,800007f4 <uartputc+0xa>
    ;
  WriteReg(THR, c);
    800007fe:	0ff57513          	andi	a0,a0,255
    80000802:	100007b7          	lui	a5,0x10000
    80000806:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    8000080a:	6422                	ld	s0,8(sp)
    8000080c:	0141                	addi	sp,sp,16
    8000080e:	8082                	ret

0000000080000810 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000810:	1141                	addi	sp,sp,-16
    80000812:	e422                	sd	s0,8(sp)
    80000814:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000816:	100007b7          	lui	a5,0x10000
    8000081a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000081e:	8b85                	andi	a5,a5,1
    80000820:	cb91                	beqz	a5,80000834 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000822:	100007b7          	lui	a5,0x10000
    80000826:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000082a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000082e:	6422                	ld	s0,8(sp)
    80000830:	0141                	addi	sp,sp,16
    80000832:	8082                	ret
    return -1;
    80000834:	557d                	li	a0,-1
    80000836:	bfe5                	j	8000082e <uartgetc+0x1e>

0000000080000838 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000838:	1101                	addi	sp,sp,-32
    8000083a:	ec06                	sd	ra,24(sp)
    8000083c:	e822                	sd	s0,16(sp)
    8000083e:	e426                	sd	s1,8(sp)
    80000840:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000842:	54fd                	li	s1,-1
    80000844:	a029                	j	8000084e <uartintr+0x16>
      break;
    consoleintr(c);
    80000846:	00000097          	auipc	ra,0x0
    8000084a:	a82080e7          	jalr	-1406(ra) # 800002c8 <consoleintr>
    int c = uartgetc();
    8000084e:	00000097          	auipc	ra,0x0
    80000852:	fc2080e7          	jalr	-62(ra) # 80000810 <uartgetc>
    if(c == -1)
    80000856:	fe9518e3          	bne	a0,s1,80000846 <uartintr+0xe>
  }
}
    8000085a:	60e2                	ld	ra,24(sp)
    8000085c:	6442                	ld	s0,16(sp)
    8000085e:	64a2                	ld	s1,8(sp)
    80000860:	6105                	addi	sp,sp,32
    80000862:	8082                	ret

0000000080000864 <checkfreelist>:

struct kmem kmems[NCPU];


int 
checkfreelist(int cpuid, struct run *freelist){
    80000864:	1101                	addi	sp,sp,-32
    80000866:	ec06                	sd	ra,24(sp)
    80000868:	e822                	sd	s0,16(sp)
    8000086a:	e426                	sd	s1,8(sp)
    8000086c:	1000                	addi	s0,sp,32
    8000086e:	84ae                	mv	s1,a1
  struct run *r = freelist;
  int count = 0;
  printf("check cpu %d:", cpuid);
    80000870:	85aa                	mv	a1,a0
    80000872:	00008517          	auipc	a0,0x8
    80000876:	9a650513          	addi	a0,a0,-1626 # 80008218 <userret+0x188>
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	d28080e7          	jalr	-728(ra) # 800005a2 <printf>
  while (r)
    80000882:	c891                	beqz	s1,80000896 <checkfreelist+0x32>
  int count = 0;
    80000884:	4501                	li	a0,0
  {
    /* code */
    //printf("run->");
    count++;
    80000886:	2505                	addiw	a0,a0,1
    r = r->next;
    80000888:	6084                	ld	s1,0(s1)
  while (r)
    8000088a:	fcf5                	bnez	s1,80000886 <checkfreelist+0x22>
  }
  return count;
}
    8000088c:	60e2                	ld	ra,24(sp)
    8000088e:	6442                	ld	s0,16(sp)
    80000890:	64a2                	ld	s1,8(sp)
    80000892:	6105                	addi	sp,sp,32
    80000894:	8082                	ret
  int count = 0;
    80000896:	4501                	li	a0,0
    80000898:	bfd5                	j	8000088c <checkfreelist+0x28>

000000008000089a <trypopr>:
    kfree(p);
}

// To remove lock contention, you will have to redesign 
// the memory allocator to avoid a single lock and list.
struct run* trypopr(int id){
    8000089a:	1141                	addi	sp,sp,-16
    8000089c:	e422                	sd	s0,8(sp)
    8000089e:	0800                	addi	s0,sp,16
    800008a0:	87aa                	mv	a5,a0
  struct run *r;
  r = kmems[id].freelist;
    800008a2:	00251713          	slli	a4,a0,0x2
    800008a6:	972a                	add	a4,a4,a0
    800008a8:	070e                	slli	a4,a4,0x3
    800008aa:	00012697          	auipc	a3,0x12
    800008ae:	02e68693          	addi	a3,a3,46 # 800128d8 <kmems>
    800008b2:	9736                	add	a4,a4,a3
    800008b4:	7308                	ld	a0,32(a4)
  if(r)
    800008b6:	cd01                	beqz	a0,800008ce <trypopr+0x34>
    kmems[id].freelist = r->next;
    800008b8:	6114                	ld	a3,0(a0)
    800008ba:	00279713          	slli	a4,a5,0x2
    800008be:	97ba                	add	a5,a5,a4
    800008c0:	078e                	slli	a5,a5,0x3
    800008c2:	00012717          	auipc	a4,0x12
    800008c6:	01670713          	addi	a4,a4,22 # 800128d8 <kmems>
    800008ca:	97ba                	add	a5,a5,a4
    800008cc:	f394                	sd	a3,32(a5)
  return r;
}
    800008ce:	6422                	ld	s0,8(sp)
    800008d0:	0141                	addi	sp,sp,16
    800008d2:	8082                	ret

00000000800008d4 <trypushr>:

void trypushr(int id, struct run* r){
  if(r){
    800008d4:	c195                	beqz	a1,800008f8 <trypushr+0x24>
    r->next = kmems[id].freelist;
    800008d6:	00012697          	auipc	a3,0x12
    800008da:	00268693          	addi	a3,a3,2 # 800128d8 <kmems>
    800008de:	00251793          	slli	a5,a0,0x2
    800008e2:	00a78733          	add	a4,a5,a0
    800008e6:	070e                	slli	a4,a4,0x3
    800008e8:	9736                	add	a4,a4,a3
    800008ea:	7318                	ld	a4,32(a4)
    800008ec:	e198                	sd	a4,0(a1)
    kmems[id].freelist = r;
    800008ee:	97aa                	add	a5,a5,a0
    800008f0:	078e                	slli	a5,a5,0x3
    800008f2:	97b6                	add	a5,a5,a3
    800008f4:	f38c                	sd	a1,32(a5)
    800008f6:	8082                	ret
void trypushr(int id, struct run* r){
    800008f8:	1141                	addi	sp,sp,-16
    800008fa:	e406                	sd	ra,8(sp)
    800008fc:	e022                	sd	s0,0(sp)
    800008fe:	0800                	addi	s0,sp,16
  }
  else
  {
    panic("cannot push null run");
    80000900:	00008517          	auipc	a0,0x8
    80000904:	92850513          	addi	a0,a0,-1752 # 80008228 <userret+0x198>
    80000908:	00000097          	auipc	ra,0x0
    8000090c:	c40080e7          	jalr	-960(ra) # 80000548 <panic>

0000000080000910 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000910:	7179                	addi	sp,sp,-48
    80000912:	f406                	sd	ra,40(sp)
    80000914:	f022                	sd	s0,32(sp)
    80000916:	ec26                	sd	s1,24(sp)
    80000918:	e84a                	sd	s2,16(sp)
    8000091a:	e44e                	sd	s3,8(sp)
    8000091c:	1800                	addi	s0,sp,48
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    8000091e:	03451793          	slli	a5,a0,0x34
    80000922:	efbd                	bnez	a5,800009a0 <kfree+0x90>
    80000924:	84aa                	mv	s1,a0
    80000926:	0002f797          	auipc	a5,0x2f
    8000092a:	73678793          	addi	a5,a5,1846 # 8003005c <end>
    8000092e:	06f56963          	bltu	a0,a5,800009a0 <kfree+0x90>
    80000932:	47c5                	li	a5,17
    80000934:	07ee                	slli	a5,a5,0x1b
    80000936:	06f57563          	bgeu	a0,a5,800009a0 <kfree+0x90>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    8000093a:	6605                	lui	a2,0x1
    8000093c:	4585                	li	a1,1
    8000093e:	00000097          	auipc	ra,0x0
    80000942:	618080e7          	jalr	1560(ra) # 80000f56 <memset>
  /* acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);  */
  
  push_off();
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	2aa080e7          	jalr	682(ra) # 80000bf0 <push_off>
  int currentid = cpuid();
    8000094e:	00001097          	auipc	ra,0x1
    80000952:	2c6080e7          	jalr	710(ra) # 80001c14 <cpuid>
    80000956:	892a                	mv	s2,a0
  pop_off();
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	2e4080e7          	jalr	740(ra) # 80000c3c <pop_off>
  
  acquire(&kmems[currentid].lock);
    80000960:	00291793          	slli	a5,s2,0x2
    80000964:	97ca                	add	a5,a5,s2
    80000966:	078e                	slli	a5,a5,0x3
    80000968:	00012997          	auipc	s3,0x12
    8000096c:	f7098993          	addi	s3,s3,-144 # 800128d8 <kmems>
    80000970:	99be                	add	s3,s3,a5
    80000972:	854e                	mv	a0,s3
    80000974:	00000097          	auipc	ra,0x0
    80000978:	374080e7          	jalr	884(ra) # 80000ce8 <acquire>
  /* r->next = kmems[currentid].freelist;
  kmems[currentid].freelist = r; */
  trypushr(currentid, r);
    8000097c:	85a6                	mv	a1,s1
    8000097e:	854a                	mv	a0,s2
    80000980:	00000097          	auipc	ra,0x0
    80000984:	f54080e7          	jalr	-172(ra) # 800008d4 <trypushr>
  release(&kmems[currentid].lock);
    80000988:	854e                	mv	a0,s3
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	3ce080e7          	jalr	974(ra) # 80000d58 <release>
  
}
    80000992:	70a2                	ld	ra,40(sp)
    80000994:	7402                	ld	s0,32(sp)
    80000996:	64e2                	ld	s1,24(sp)
    80000998:	6942                	ld	s2,16(sp)
    8000099a:	69a2                	ld	s3,8(sp)
    8000099c:	6145                	addi	sp,sp,48
    8000099e:	8082                	ret
    panic("kfree");
    800009a0:	00008517          	auipc	a0,0x8
    800009a4:	8a050513          	addi	a0,a0,-1888 # 80008240 <userret+0x1b0>
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	ba0080e7          	jalr	-1120(ra) # 80000548 <panic>

00000000800009b0 <freerange>:
{
    800009b0:	7179                	addi	sp,sp,-48
    800009b2:	f406                	sd	ra,40(sp)
    800009b4:	f022                	sd	s0,32(sp)
    800009b6:	ec26                	sd	s1,24(sp)
    800009b8:	e84a                	sd	s2,16(sp)
    800009ba:	e44e                	sd	s3,8(sp)
    800009bc:	e052                	sd	s4,0(sp)
    800009be:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800009c0:	6785                	lui	a5,0x1
    800009c2:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800009c6:	94aa                	add	s1,s1,a0
    800009c8:	757d                	lui	a0,0xfffff
    800009ca:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800009cc:	94be                	add	s1,s1,a5
    800009ce:	0095ee63          	bltu	a1,s1,800009ea <freerange+0x3a>
    800009d2:	892e                	mv	s2,a1
    kfree(p);
    800009d4:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800009d6:	6985                	lui	s3,0x1
    kfree(p);
    800009d8:	01448533          	add	a0,s1,s4
    800009dc:	00000097          	auipc	ra,0x0
    800009e0:	f34080e7          	jalr	-204(ra) # 80000910 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800009e4:	94ce                	add	s1,s1,s3
    800009e6:	fe9979e3          	bgeu	s2,s1,800009d8 <freerange+0x28>
}
    800009ea:	70a2                	ld	ra,40(sp)
    800009ec:	7402                	ld	s0,32(sp)
    800009ee:	64e2                	ld	s1,24(sp)
    800009f0:	6942                	ld	s2,16(sp)
    800009f2:	69a2                	ld	s3,8(sp)
    800009f4:	6a02                	ld	s4,0(sp)
    800009f6:	6145                	addi	sp,sp,48
    800009f8:	8082                	ret

00000000800009fa <kinit>:
{
    800009fa:	7179                	addi	sp,sp,-48
    800009fc:	f406                	sd	ra,40(sp)
    800009fe:	f022                	sd	s0,32(sp)
    80000a00:	ec26                	sd	s1,24(sp)
    80000a02:	e84a                	sd	s2,16(sp)
    80000a04:	e44e                	sd	s3,8(sp)
    80000a06:	e052                	sd	s4,0(sp)
    80000a08:	1800                	addi	s0,sp,48
  push_off();
    80000a0a:	00000097          	auipc	ra,0x0
    80000a0e:	1e6080e7          	jalr	486(ra) # 80000bf0 <push_off>
  int currentid = cpuid();
    80000a12:	00001097          	auipc	ra,0x1
    80000a16:	202080e7          	jalr	514(ra) # 80001c14 <cpuid>
    80000a1a:	8a2a                	mv	s4,a0
  pop_off();
    80000a1c:	00000097          	auipc	ra,0x0
    80000a20:	220080e7          	jalr	544(ra) # 80000c3c <pop_off>
  printf("# cpuId:%d \n",currentid);
    80000a24:	85d2                	mv	a1,s4
    80000a26:	00008517          	auipc	a0,0x8
    80000a2a:	82250513          	addi	a0,a0,-2014 # 80008248 <userret+0x1b8>
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	b74080e7          	jalr	-1164(ra) # 800005a2 <printf>
  for (int i = 0; i < NCPU; i++)
    80000a36:	00012497          	auipc	s1,0x12
    80000a3a:	ea248493          	addi	s1,s1,-350 # 800128d8 <kmems>
    80000a3e:	00012997          	auipc	s3,0x12
    80000a42:	fda98993          	addi	s3,s3,-38 # 80012a18 <kmem>
    initlock(&kmems[i].lock, "kmem");
    80000a46:	00008917          	auipc	s2,0x8
    80000a4a:	81290913          	addi	s2,s2,-2030 # 80008258 <userret+0x1c8>
    80000a4e:	85ca                	mv	a1,s2
    80000a50:	8526                	mv	a0,s1
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	148080e7          	jalr	328(ra) # 80000b9a <initlock>
  for (int i = 0; i < NCPU; i++)
    80000a5a:	02848493          	addi	s1,s1,40
    80000a5e:	ff3498e3          	bne	s1,s3,80000a4e <kinit+0x54>
  freerange(end, (void*)PHYSTOP);
    80000a62:	45c5                	li	a1,17
    80000a64:	05ee                	slli	a1,a1,0x1b
    80000a66:	0002f517          	auipc	a0,0x2f
    80000a6a:	5f650513          	addi	a0,a0,1526 # 8003005c <end>
    80000a6e:	00000097          	auipc	ra,0x0
    80000a72:	f42080e7          	jalr	-190(ra) # 800009b0 <freerange>
  printf("# kinit end:%d \n",currentid);
    80000a76:	85d2                	mv	a1,s4
    80000a78:	00007517          	auipc	a0,0x7
    80000a7c:	7e850513          	addi	a0,a0,2024 # 80008260 <userret+0x1d0>
    80000a80:	00000097          	auipc	ra,0x0
    80000a84:	b22080e7          	jalr	-1246(ra) # 800005a2 <printf>
}
    80000a88:	70a2                	ld	ra,40(sp)
    80000a8a:	7402                	ld	s0,32(sp)
    80000a8c:	64e2                	ld	s1,24(sp)
    80000a8e:	6942                	ld	s2,16(sp)
    80000a90:	69a2                	ld	s3,8(sp)
    80000a92:	6a02                	ld	s4,0(sp)
    80000a94:	6145                	addi	sp,sp,48
    80000a96:	8082                	ret

0000000080000a98 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000a98:	7179                	addi	sp,sp,-48
    80000a9a:	f406                	sd	ra,40(sp)
    80000a9c:	f022                	sd	s0,32(sp)
    80000a9e:	ec26                	sd	s1,24(sp)
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	1800                	addi	s0,sp,48
  struct run *r;
  int issteal = 0;/** 标识是否为偷盗 */
  push_off();
    80000aa8:	00000097          	auipc	ra,0x0
    80000aac:	148080e7          	jalr	328(ra) # 80000bf0 <push_off>
  int currentid = cpuid();
    80000ab0:	00001097          	auipc	ra,0x1
    80000ab4:	164080e7          	jalr	356(ra) # 80001c14 <cpuid>
    80000ab8:	84aa                	mv	s1,a0
  pop_off();
    80000aba:	00000097          	auipc	ra,0x0
    80000abe:	182080e7          	jalr	386(ra) # 80000c3c <pop_off>

  acquire(&kmems[currentid].lock);
    80000ac2:	00249793          	slli	a5,s1,0x2
    80000ac6:	97a6                	add	a5,a5,s1
    80000ac8:	078e                	slli	a5,a5,0x3
    80000aca:	00012a17          	auipc	s4,0x12
    80000ace:	e0ea0a13          	addi	s4,s4,-498 # 800128d8 <kmems>
    80000ad2:	9a3e                	add	s4,s4,a5
    80000ad4:	8552                	mv	a0,s4
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	212080e7          	jalr	530(ra) # 80000ce8 <acquire>
  
  r = trypopr(currentid);
    80000ade:	8526                	mv	a0,s1
    80000ae0:	00000097          	auipc	ra,0x0
    80000ae4:	dba080e7          	jalr	-582(ra) # 8000089a <trypopr>
    80000ae8:	89aa                	mv	s3,a0

  if(!r){
    80000aea:	c515                	beqz	a0,80000b16 <kalloc+0x7e>
  }
  /** 如果是偷盗的，则把currentid的freelist释放出来  */
  if(issteal)
    r = trypopr(currentid);
  
  release(&kmems[currentid].lock);
    80000aec:	8552                	mv	a0,s4
    80000aee:	00000097          	auipc	ra,0x0
    80000af2:	26a080e7          	jalr	618(ra) # 80000d58 <release>
  
  if(r){
    //printf("currentid: %d, r: %p\n", currentid, r);
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000af6:	6605                	lui	a2,0x1
    80000af8:	4595                	li	a1,5
    80000afa:	854e                	mv	a0,s3
    80000afc:	00000097          	auipc	ra,0x0
    80000b00:	45a080e7          	jalr	1114(ra) # 80000f56 <memset>
  }
  /** 返回该page  */
  //printf("issteal: %d \n", issteal);
  return (void*)r;
}
    80000b04:	854e                	mv	a0,s3
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6942                	ld	s2,16(sp)
    80000b0e:	69a2                	ld	s3,8(sp)
    80000b10:	6a02                	ld	s4,0(sp)
    80000b12:	6145                	addi	sp,sp,48
    80000b14:	8082                	ret
    80000b16:	00012797          	auipc	a5,0x12
    80000b1a:	dc278793          	addi	a5,a5,-574 # 800128d8 <kmems>
    for (int id = 0; id < NCPU; id++)
    80000b1e:	4901                	li	s2,0
    80000b20:	46a1                	li	a3,8
    80000b22:	a031                	j	80000b2e <kalloc+0x96>
    80000b24:	2905                	addiw	s2,s2,1
    80000b26:	02878793          	addi	a5,a5,40
    80000b2a:	06d90263          	beq	s2,a3,80000b8e <kalloc+0xf6>
      if(id != currentid){
    80000b2e:	ff248be3          	beq	s1,s2,80000b24 <kalloc+0x8c>
        if(kmems[id].freelist){
    80000b32:	7398                	ld	a4,32(a5)
    80000b34:	db65                	beqz	a4,80000b24 <kalloc+0x8c>
          acquire(&kmems[id].lock);
    80000b36:	00291793          	slli	a5,s2,0x2
    80000b3a:	97ca                	add	a5,a5,s2
    80000b3c:	078e                	slli	a5,a5,0x3
    80000b3e:	00012997          	auipc	s3,0x12
    80000b42:	d9a98993          	addi	s3,s3,-614 # 800128d8 <kmems>
    80000b46:	99be                	add	s3,s3,a5
    80000b48:	854e                	mv	a0,s3
    80000b4a:	00000097          	auipc	ra,0x0
    80000b4e:	19e080e7          	jalr	414(ra) # 80000ce8 <acquire>
          r = trypopr(id);
    80000b52:	854a                	mv	a0,s2
    80000b54:	00000097          	auipc	ra,0x0
    80000b58:	d46080e7          	jalr	-698(ra) # 8000089a <trypopr>
    80000b5c:	85aa                	mv	a1,a0
          trypushr(currentid, r);
    80000b5e:	8526                	mv	a0,s1
    80000b60:	00000097          	auipc	ra,0x0
    80000b64:	d74080e7          	jalr	-652(ra) # 800008d4 <trypushr>
          release(&kmems[id].lock);
    80000b68:	854e                	mv	a0,s3
    80000b6a:	00000097          	auipc	ra,0x0
    80000b6e:	1ee080e7          	jalr	494(ra) # 80000d58 <release>
    r = trypopr(currentid);
    80000b72:	8526                	mv	a0,s1
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	d26080e7          	jalr	-730(ra) # 8000089a <trypopr>
    80000b7c:	89aa                	mv	s3,a0
  release(&kmems[currentid].lock);
    80000b7e:	8552                	mv	a0,s4
    80000b80:	00000097          	auipc	ra,0x0
    80000b84:	1d8080e7          	jalr	472(ra) # 80000d58 <release>
  if(r){
    80000b88:	f6098ee3          	beqz	s3,80000b04 <kalloc+0x6c>
    80000b8c:	b7ad                	j	80000af6 <kalloc+0x5e>
  release(&kmems[currentid].lock);
    80000b8e:	8552                	mv	a0,s4
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	1c8080e7          	jalr	456(ra) # 80000d58 <release>
  if(r){
    80000b98:	b7b5                	j	80000b04 <kalloc+0x6c>

0000000080000b9a <initlock>:

// assumes locks are not freed
void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
    80000b9a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b9c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000ba0:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000ba4:	00052e23          	sw	zero,28(a0)
  lk->n = 0;
    80000ba8:	00052c23          	sw	zero,24(a0)
  if(nlock >= NLOCK)
    80000bac:	0002f797          	auipc	a5,0x2f
    80000bb0:	4787a783          	lw	a5,1144(a5) # 80030024 <nlock>
    80000bb4:	3e700713          	li	a4,999
    80000bb8:	02f74063          	blt	a4,a5,80000bd8 <initlock+0x3e>
    panic("initlock");
  locks[nlock] = lk;
    80000bbc:	00379693          	slli	a3,a5,0x3
    80000bc0:	00012717          	auipc	a4,0x12
    80000bc4:	e8070713          	addi	a4,a4,-384 # 80012a40 <locks>
    80000bc8:	9736                	add	a4,a4,a3
    80000bca:	e308                	sd	a0,0(a4)
  nlock++;
    80000bcc:	2785                	addiw	a5,a5,1
    80000bce:	0002f717          	auipc	a4,0x2f
    80000bd2:	44f72b23          	sw	a5,1110(a4) # 80030024 <nlock>
    80000bd6:	8082                	ret
{
    80000bd8:	1141                	addi	sp,sp,-16
    80000bda:	e406                	sd	ra,8(sp)
    80000bdc:	e022                	sd	s0,0(sp)
    80000bde:	0800                	addi	s0,sp,16
    panic("initlock");
    80000be0:	00007517          	auipc	a0,0x7
    80000be4:	69850513          	addi	a0,a0,1688 # 80008278 <userret+0x1e8>
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	960080e7          	jalr	-1696(ra) # 80000548 <panic>

0000000080000bf0 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bf0:	1101                	addi	sp,sp,-32
    80000bf2:	ec06                	sd	ra,24(sp)
    80000bf4:	e822                	sd	s0,16(sp)
    80000bf6:	e426                	sd	s1,8(sp)
    80000bf8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bfa:	100024f3          	csrr	s1,sstatus
    80000bfe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c02:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c04:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c08:	00001097          	auipc	ra,0x1
    80000c0c:	01c080e7          	jalr	28(ra) # 80001c24 <mycpu>
    80000c10:	5d3c                	lw	a5,120(a0)
    80000c12:	cf89                	beqz	a5,80000c2c <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c14:	00001097          	auipc	ra,0x1
    80000c18:	010080e7          	jalr	16(ra) # 80001c24 <mycpu>
    80000c1c:	5d3c                	lw	a5,120(a0)
    80000c1e:	2785                	addiw	a5,a5,1
    80000c20:	dd3c                	sw	a5,120(a0)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    mycpu()->intena = old;
    80000c2c:	00001097          	auipc	ra,0x1
    80000c30:	ff8080e7          	jalr	-8(ra) # 80001c24 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c34:	8085                	srli	s1,s1,0x1
    80000c36:	8885                	andi	s1,s1,1
    80000c38:	dd64                	sw	s1,124(a0)
    80000c3a:	bfe9                	j	80000c14 <push_off+0x24>

0000000080000c3c <pop_off>:

void
pop_off(void)
{
    80000c3c:	1141                	addi	sp,sp,-16
    80000c3e:	e406                	sd	ra,8(sp)
    80000c40:	e022                	sd	s0,0(sp)
    80000c42:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c44:	00001097          	auipc	ra,0x1
    80000c48:	fe0080e7          	jalr	-32(ra) # 80001c24 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c50:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c52:	eb9d                	bnez	a5,80000c88 <pop_off+0x4c>
    panic("pop_off - interruptible");
  c->noff -= 1;
    80000c54:	5d3c                	lw	a5,120(a0)
    80000c56:	37fd                	addiw	a5,a5,-1
    80000c58:	0007871b          	sext.w	a4,a5
    80000c5c:	dd3c                	sw	a5,120(a0)
  if(c->noff < 0)
    80000c5e:	02074d63          	bltz	a4,80000c98 <pop_off+0x5c>
    panic("pop_off");
  if(c->noff == 0 && c->intena)
    80000c62:	ef19                	bnez	a4,80000c80 <pop_off+0x44>
    80000c64:	5d7c                	lw	a5,124(a0)
    80000c66:	cf89                	beqz	a5,80000c80 <pop_off+0x44>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000c68:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000c6c:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000c70:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c74:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c78:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c7c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c80:	60a2                	ld	ra,8(sp)
    80000c82:	6402                	ld	s0,0(sp)
    80000c84:	0141                	addi	sp,sp,16
    80000c86:	8082                	ret
    panic("pop_off - interruptible");
    80000c88:	00007517          	auipc	a0,0x7
    80000c8c:	60050513          	addi	a0,a0,1536 # 80008288 <userret+0x1f8>
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	8b8080e7          	jalr	-1864(ra) # 80000548 <panic>
    panic("pop_off");
    80000c98:	00007517          	auipc	a0,0x7
    80000c9c:	60850513          	addi	a0,a0,1544 # 800082a0 <userret+0x210>
    80000ca0:	00000097          	auipc	ra,0x0
    80000ca4:	8a8080e7          	jalr	-1880(ra) # 80000548 <panic>

0000000080000ca8 <holding>:
{
    80000ca8:	1101                	addi	sp,sp,-32
    80000caa:	ec06                	sd	ra,24(sp)
    80000cac:	e822                	sd	s0,16(sp)
    80000cae:	e426                	sd	s1,8(sp)
    80000cb0:	1000                	addi	s0,sp,32
    80000cb2:	84aa                	mv	s1,a0
  push_off();
    80000cb4:	00000097          	auipc	ra,0x0
    80000cb8:	f3c080e7          	jalr	-196(ra) # 80000bf0 <push_off>
  r = (lk->locked && lk->cpu == mycpu());
    80000cbc:	409c                	lw	a5,0(s1)
    80000cbe:	ef81                	bnez	a5,80000cd6 <holding+0x2e>
    80000cc0:	4481                	li	s1,0
  pop_off();
    80000cc2:	00000097          	auipc	ra,0x0
    80000cc6:	f7a080e7          	jalr	-134(ra) # 80000c3c <pop_off>
}
    80000cca:	8526                	mv	a0,s1
    80000ccc:	60e2                	ld	ra,24(sp)
    80000cce:	6442                	ld	s0,16(sp)
    80000cd0:	64a2                	ld	s1,8(sp)
    80000cd2:	6105                	addi	sp,sp,32
    80000cd4:	8082                	ret
  r = (lk->locked && lk->cpu == mycpu());
    80000cd6:	6884                	ld	s1,16(s1)
    80000cd8:	00001097          	auipc	ra,0x1
    80000cdc:	f4c080e7          	jalr	-180(ra) # 80001c24 <mycpu>
    80000ce0:	8c89                	sub	s1,s1,a0
    80000ce2:	0014b493          	seqz	s1,s1
    80000ce6:	bff1                	j	80000cc2 <holding+0x1a>

0000000080000ce8 <acquire>:
{
    80000ce8:	1101                	addi	sp,sp,-32
    80000cea:	ec06                	sd	ra,24(sp)
    80000cec:	e822                	sd	s0,16(sp)
    80000cee:	e426                	sd	s1,8(sp)
    80000cf0:	1000                	addi	s0,sp,32
    80000cf2:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cf4:	00000097          	auipc	ra,0x0
    80000cf8:	efc080e7          	jalr	-260(ra) # 80000bf0 <push_off>
  if(holding(lk))
    80000cfc:	8526                	mv	a0,s1
    80000cfe:	00000097          	auipc	ra,0x0
    80000d02:	faa080e7          	jalr	-86(ra) # 80000ca8 <holding>
    80000d06:	e911                	bnez	a0,80000d1a <acquire+0x32>
  __sync_fetch_and_add(&(lk->n), 1);
    80000d08:	4785                	li	a5,1
    80000d0a:	01848713          	addi	a4,s1,24
    80000d0e:	0f50000f          	fence	iorw,ow
    80000d12:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000d16:	4705                	li	a4,1
    80000d18:	a839                	j	80000d36 <acquire+0x4e>
    panic("acquire");
    80000d1a:	00007517          	auipc	a0,0x7
    80000d1e:	58e50513          	addi	a0,a0,1422 # 800082a8 <userret+0x218>
    80000d22:	00000097          	auipc	ra,0x0
    80000d26:	826080e7          	jalr	-2010(ra) # 80000548 <panic>
     __sync_fetch_and_add(&lk->nts, 1);
    80000d2a:	01c48793          	addi	a5,s1,28
    80000d2e:	0f50000f          	fence	iorw,ow
    80000d32:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000d36:	87ba                	mv	a5,a4
    80000d38:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d3c:	2781                	sext.w	a5,a5
    80000d3e:	f7f5                	bnez	a5,80000d2a <acquire+0x42>
  __sync_synchronize();
    80000d40:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d44:	00001097          	auipc	ra,0x1
    80000d48:	ee0080e7          	jalr	-288(ra) # 80001c24 <mycpu>
    80000d4c:	e888                	sd	a0,16(s1)
}
    80000d4e:	60e2                	ld	ra,24(sp)
    80000d50:	6442                	ld	s0,16(sp)
    80000d52:	64a2                	ld	s1,8(sp)
    80000d54:	6105                	addi	sp,sp,32
    80000d56:	8082                	ret

0000000080000d58 <release>:
{
    80000d58:	1101                	addi	sp,sp,-32
    80000d5a:	ec06                	sd	ra,24(sp)
    80000d5c:	e822                	sd	s0,16(sp)
    80000d5e:	e426                	sd	s1,8(sp)
    80000d60:	1000                	addi	s0,sp,32
    80000d62:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d64:	00000097          	auipc	ra,0x0
    80000d68:	f44080e7          	jalr	-188(ra) # 80000ca8 <holding>
    80000d6c:	c115                	beqz	a0,80000d90 <release+0x38>
  lk->cpu = 0;
    80000d6e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d72:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d76:	0f50000f          	fence	iorw,ow
    80000d7a:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d7e:	00000097          	auipc	ra,0x0
    80000d82:	ebe080e7          	jalr	-322(ra) # 80000c3c <pop_off>
}
    80000d86:	60e2                	ld	ra,24(sp)
    80000d88:	6442                	ld	s0,16(sp)
    80000d8a:	64a2                	ld	s1,8(sp)
    80000d8c:	6105                	addi	sp,sp,32
    80000d8e:	8082                	ret
    panic("release");
    80000d90:	00007517          	auipc	a0,0x7
    80000d94:	52050513          	addi	a0,a0,1312 # 800082b0 <userret+0x220>
    80000d98:	fffff097          	auipc	ra,0xfffff
    80000d9c:	7b0080e7          	jalr	1968(ra) # 80000548 <panic>

0000000080000da0 <print_lock>:

void
print_lock(struct spinlock *lk)
{
  if(lk->n > 0) 
    80000da0:	4d14                	lw	a3,24(a0)
    80000da2:	e291                	bnez	a3,80000da6 <print_lock+0x6>
    80000da4:	8082                	ret
{
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e406                	sd	ra,8(sp)
    80000daa:	e022                	sd	s0,0(sp)
    80000dac:	0800                	addi	s0,sp,16
    printf("lock: %s: #test-and-set %d #acquire() %d\n", lk->name, lk->nts, lk->n);
    80000dae:	4d50                	lw	a2,28(a0)
    80000db0:	650c                	ld	a1,8(a0)
    80000db2:	00007517          	auipc	a0,0x7
    80000db6:	50650513          	addi	a0,a0,1286 # 800082b8 <userret+0x228>
    80000dba:	fffff097          	auipc	ra,0xfffff
    80000dbe:	7e8080e7          	jalr	2024(ra) # 800005a2 <printf>
}
    80000dc2:	60a2                	ld	ra,8(sp)
    80000dc4:	6402                	ld	s0,0(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <sys_ntas>:

uint64
sys_ntas(void)
{
    80000dca:	711d                	addi	sp,sp,-96
    80000dcc:	ec86                	sd	ra,88(sp)
    80000dce:	e8a2                	sd	s0,80(sp)
    80000dd0:	e4a6                	sd	s1,72(sp)
    80000dd2:	e0ca                	sd	s2,64(sp)
    80000dd4:	fc4e                	sd	s3,56(sp)
    80000dd6:	f852                	sd	s4,48(sp)
    80000dd8:	f456                	sd	s5,40(sp)
    80000dda:	f05a                	sd	s6,32(sp)
    80000ddc:	ec5e                	sd	s7,24(sp)
    80000dde:	e862                	sd	s8,16(sp)
    80000de0:	1080                	addi	s0,sp,96
  int zero = 0;
    80000de2:	fa042623          	sw	zero,-84(s0)
  int tot = 0;
  
  if (argint(0, &zero) < 0) {
    80000de6:	fac40593          	addi	a1,s0,-84
    80000dea:	4501                	li	a0,0
    80000dec:	00002097          	auipc	ra,0x2
    80000df0:	ecc080e7          	jalr	-308(ra) # 80002cb8 <argint>
    80000df4:	14054d63          	bltz	a0,80000f4e <sys_ntas+0x184>
    return -1;
  }
  if(zero == 0) {
    80000df8:	fac42783          	lw	a5,-84(s0)
    80000dfc:	e78d                	bnez	a5,80000e26 <sys_ntas+0x5c>
    80000dfe:	00012797          	auipc	a5,0x12
    80000e02:	c4278793          	addi	a5,a5,-958 # 80012a40 <locks>
    80000e06:	00014697          	auipc	a3,0x14
    80000e0a:	b7a68693          	addi	a3,a3,-1158 # 80014980 <pid_lock>
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    80000e0e:	6398                	ld	a4,0(a5)
    80000e10:	14070163          	beqz	a4,80000f52 <sys_ntas+0x188>
        break;
      locks[i]->nts = 0;
    80000e14:	00072e23          	sw	zero,28(a4)
      locks[i]->n = 0;
    80000e18:	00072c23          	sw	zero,24(a4)
    for(int i = 0; i < NLOCK; i++) {
    80000e1c:	07a1                	addi	a5,a5,8
    80000e1e:	fed798e3          	bne	a5,a3,80000e0e <sys_ntas+0x44>
    }
    return 0;
    80000e22:	4501                	li	a0,0
    80000e24:	aa09                	j	80000f36 <sys_ntas+0x16c>
  }

  printf("=== lock kmem/bcache stats\n");
    80000e26:	00007517          	auipc	a0,0x7
    80000e2a:	4c250513          	addi	a0,a0,1218 # 800082e8 <userret+0x258>
    80000e2e:	fffff097          	auipc	ra,0xfffff
    80000e32:	774080e7          	jalr	1908(ra) # 800005a2 <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000e36:	00012b17          	auipc	s6,0x12
    80000e3a:	c0ab0b13          	addi	s6,s6,-1014 # 80012a40 <locks>
    80000e3e:	00014b97          	auipc	s7,0x14
    80000e42:	b42b8b93          	addi	s7,s7,-1214 # 80014980 <pid_lock>
  printf("=== lock kmem/bcache stats\n");
    80000e46:	84da                	mv	s1,s6
  int tot = 0;
    80000e48:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000e4a:	00007a17          	auipc	s4,0x7
    80000e4e:	4bea0a13          	addi	s4,s4,1214 # 80008308 <userret+0x278>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000e52:	00007c17          	auipc	s8,0x7
    80000e56:	406c0c13          	addi	s8,s8,1030 # 80008258 <userret+0x1c8>
    80000e5a:	a829                	j	80000e74 <sys_ntas+0xaa>
      tot += locks[i]->nts;
    80000e5c:	00093503          	ld	a0,0(s2)
    80000e60:	4d5c                	lw	a5,28(a0)
    80000e62:	013789bb          	addw	s3,a5,s3
      print_lock(locks[i]);
    80000e66:	00000097          	auipc	ra,0x0
    80000e6a:	f3a080e7          	jalr	-198(ra) # 80000da0 <print_lock>
  for(int i = 0; i < NLOCK; i++) {
    80000e6e:	04a1                	addi	s1,s1,8
    80000e70:	05748763          	beq	s1,s7,80000ebe <sys_ntas+0xf4>
    if(locks[i] == 0)
    80000e74:	8926                	mv	s2,s1
    80000e76:	609c                	ld	a5,0(s1)
    80000e78:	c3b9                	beqz	a5,80000ebe <sys_ntas+0xf4>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000e7a:	0087ba83          	ld	s5,8(a5)
    80000e7e:	8552                	mv	a0,s4
    80000e80:	00000097          	auipc	ra,0x0
    80000e84:	25a080e7          	jalr	602(ra) # 800010da <strlen>
    80000e88:	0005061b          	sext.w	a2,a0
    80000e8c:	85d2                	mv	a1,s4
    80000e8e:	8556                	mv	a0,s5
    80000e90:	00000097          	auipc	ra,0x0
    80000e94:	19e080e7          	jalr	414(ra) # 8000102e <strncmp>
    80000e98:	d171                	beqz	a0,80000e5c <sys_ntas+0x92>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000e9a:	609c                	ld	a5,0(s1)
    80000e9c:	0087ba83          	ld	s5,8(a5)
    80000ea0:	8562                	mv	a0,s8
    80000ea2:	00000097          	auipc	ra,0x0
    80000ea6:	238080e7          	jalr	568(ra) # 800010da <strlen>
    80000eaa:	0005061b          	sext.w	a2,a0
    80000eae:	85e2                	mv	a1,s8
    80000eb0:	8556                	mv	a0,s5
    80000eb2:	00000097          	auipc	ra,0x0
    80000eb6:	17c080e7          	jalr	380(ra) # 8000102e <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000eba:	f955                	bnez	a0,80000e6e <sys_ntas+0xa4>
    80000ebc:	b745                	j	80000e5c <sys_ntas+0x92>
    }
  }

  printf("=== top 5 contended locks:\n");
    80000ebe:	00007517          	auipc	a0,0x7
    80000ec2:	45250513          	addi	a0,a0,1106 # 80008310 <userret+0x280>
    80000ec6:	fffff097          	auipc	ra,0xfffff
    80000eca:	6dc080e7          	jalr	1756(ra) # 800005a2 <printf>
    80000ece:	4a15                	li	s4,5
  int last = 100000000;
    80000ed0:	05f5e537          	lui	a0,0x5f5e
    80000ed4:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t= 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    80000ed8:	4a81                	li	s5,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000eda:	00012497          	auipc	s1,0x12
    80000ede:	b6648493          	addi	s1,s1,-1178 # 80012a40 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80000ee2:	3e800913          	li	s2,1000
    80000ee6:	a091                	j	80000f2a <sys_ntas+0x160>
    80000ee8:	2705                	addiw	a4,a4,1
    80000eea:	06a1                	addi	a3,a3,8
    80000eec:	03270063          	beq	a4,s2,80000f0c <sys_ntas+0x142>
      if(locks[i] == 0)
    80000ef0:	629c                	ld	a5,0(a3)
    80000ef2:	cf89                	beqz	a5,80000f0c <sys_ntas+0x142>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000ef4:	4fd0                	lw	a2,28(a5)
    80000ef6:	00359793          	slli	a5,a1,0x3
    80000efa:	97a6                	add	a5,a5,s1
    80000efc:	639c                	ld	a5,0(a5)
    80000efe:	4fdc                	lw	a5,28(a5)
    80000f00:	fec7f4e3          	bgeu	a5,a2,80000ee8 <sys_ntas+0x11e>
    80000f04:	fea672e3          	bgeu	a2,a0,80000ee8 <sys_ntas+0x11e>
    80000f08:	85ba                	mv	a1,a4
    80000f0a:	bff9                	j	80000ee8 <sys_ntas+0x11e>
        top = i;
      }
    }
    print_lock(locks[top]);
    80000f0c:	058e                	slli	a1,a1,0x3
    80000f0e:	00b48bb3          	add	s7,s1,a1
    80000f12:	000bb503          	ld	a0,0(s7)
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	e8a080e7          	jalr	-374(ra) # 80000da0 <print_lock>
    last = locks[top]->nts;
    80000f1e:	000bb783          	ld	a5,0(s7)
    80000f22:	4fc8                	lw	a0,28(a5)
  for(int t= 0; t < 5; t++) {
    80000f24:	3a7d                	addiw	s4,s4,-1
    80000f26:	000a0763          	beqz	s4,80000f34 <sys_ntas+0x16a>
  int tot = 0;
    80000f2a:	86da                	mv	a3,s6
    for(int i = 0; i < NLOCK; i++) {
    80000f2c:	8756                	mv	a4,s5
    int top = 0;
    80000f2e:	85d6                	mv	a1,s5
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000f30:	2501                	sext.w	a0,a0
    80000f32:	bf7d                	j	80000ef0 <sys_ntas+0x126>
  }
  return tot;
    80000f34:	854e                	mv	a0,s3
}
    80000f36:	60e6                	ld	ra,88(sp)
    80000f38:	6446                	ld	s0,80(sp)
    80000f3a:	64a6                	ld	s1,72(sp)
    80000f3c:	6906                	ld	s2,64(sp)
    80000f3e:	79e2                	ld	s3,56(sp)
    80000f40:	7a42                	ld	s4,48(sp)
    80000f42:	7aa2                	ld	s5,40(sp)
    80000f44:	7b02                	ld	s6,32(sp)
    80000f46:	6be2                	ld	s7,24(sp)
    80000f48:	6c42                	ld	s8,16(sp)
    80000f4a:	6125                	addi	sp,sp,96
    80000f4c:	8082                	ret
    return -1;
    80000f4e:	557d                	li	a0,-1
    80000f50:	b7dd                	j	80000f36 <sys_ntas+0x16c>
    return 0;
    80000f52:	4501                	li	a0,0
    80000f54:	b7cd                	j	80000f36 <sys_ntas+0x16c>

0000000080000f56 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000f56:	1141                	addi	sp,sp,-16
    80000f58:	e422                	sd	s0,8(sp)
    80000f5a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000f5c:	ca19                	beqz	a2,80000f72 <memset+0x1c>
    80000f5e:	87aa                	mv	a5,a0
    80000f60:	1602                	slli	a2,a2,0x20
    80000f62:	9201                	srli	a2,a2,0x20
    80000f64:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000f68:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000f6c:	0785                	addi	a5,a5,1
    80000f6e:	fee79de3          	bne	a5,a4,80000f68 <memset+0x12>
  }
  return dst;
}
    80000f72:	6422                	ld	s0,8(sp)
    80000f74:	0141                	addi	sp,sp,16
    80000f76:	8082                	ret

0000000080000f78 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000f78:	1141                	addi	sp,sp,-16
    80000f7a:	e422                	sd	s0,8(sp)
    80000f7c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000f7e:	ca05                	beqz	a2,80000fae <memcmp+0x36>
    80000f80:	fff6069b          	addiw	a3,a2,-1
    80000f84:	1682                	slli	a3,a3,0x20
    80000f86:	9281                	srli	a3,a3,0x20
    80000f88:	0685                	addi	a3,a3,1
    80000f8a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000f8c:	00054783          	lbu	a5,0(a0)
    80000f90:	0005c703          	lbu	a4,0(a1)
    80000f94:	00e79863          	bne	a5,a4,80000fa4 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000f98:	0505                	addi	a0,a0,1
    80000f9a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000f9c:	fed518e3          	bne	a0,a3,80000f8c <memcmp+0x14>
  }

  return 0;
    80000fa0:	4501                	li	a0,0
    80000fa2:	a019                	j	80000fa8 <memcmp+0x30>
      return *s1 - *s2;
    80000fa4:	40e7853b          	subw	a0,a5,a4
}
    80000fa8:	6422                	ld	s0,8(sp)
    80000faa:	0141                	addi	sp,sp,16
    80000fac:	8082                	ret
  return 0;
    80000fae:	4501                	li	a0,0
    80000fb0:	bfe5                	j	80000fa8 <memcmp+0x30>

0000000080000fb2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000fb2:	1141                	addi	sp,sp,-16
    80000fb4:	e422                	sd	s0,8(sp)
    80000fb6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000fb8:	02a5e563          	bltu	a1,a0,80000fe2 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000fbc:	fff6069b          	addiw	a3,a2,-1
    80000fc0:	ce11                	beqz	a2,80000fdc <memmove+0x2a>
    80000fc2:	1682                	slli	a3,a3,0x20
    80000fc4:	9281                	srli	a3,a3,0x20
    80000fc6:	0685                	addi	a3,a3,1
    80000fc8:	96ae                	add	a3,a3,a1
    80000fca:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000fcc:	0585                	addi	a1,a1,1
    80000fce:	0785                	addi	a5,a5,1
    80000fd0:	fff5c703          	lbu	a4,-1(a1)
    80000fd4:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000fd8:	fed59ae3          	bne	a1,a3,80000fcc <memmove+0x1a>

  return dst;
}
    80000fdc:	6422                	ld	s0,8(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret
  if(s < d && s + n > d){
    80000fe2:	02061713          	slli	a4,a2,0x20
    80000fe6:	9301                	srli	a4,a4,0x20
    80000fe8:	00e587b3          	add	a5,a1,a4
    80000fec:	fcf578e3          	bgeu	a0,a5,80000fbc <memmove+0xa>
    d += n;
    80000ff0:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000ff2:	fff6069b          	addiw	a3,a2,-1
    80000ff6:	d27d                	beqz	a2,80000fdc <memmove+0x2a>
    80000ff8:	02069613          	slli	a2,a3,0x20
    80000ffc:	9201                	srli	a2,a2,0x20
    80000ffe:	fff64613          	not	a2,a2
    80001002:	963e                	add	a2,a2,a5
      *--d = *--s;
    80001004:	17fd                	addi	a5,a5,-1
    80001006:	177d                	addi	a4,a4,-1
    80001008:	0007c683          	lbu	a3,0(a5)
    8000100c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80001010:	fef61ae3          	bne	a2,a5,80001004 <memmove+0x52>
    80001014:	b7e1                	j	80000fdc <memmove+0x2a>

0000000080001016 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80001016:	1141                	addi	sp,sp,-16
    80001018:	e406                	sd	ra,8(sp)
    8000101a:	e022                	sd	s0,0(sp)
    8000101c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000101e:	00000097          	auipc	ra,0x0
    80001022:	f94080e7          	jalr	-108(ra) # 80000fb2 <memmove>
}
    80001026:	60a2                	ld	ra,8(sp)
    80001028:	6402                	ld	s0,0(sp)
    8000102a:	0141                	addi	sp,sp,16
    8000102c:	8082                	ret

000000008000102e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000102e:	1141                	addi	sp,sp,-16
    80001030:	e422                	sd	s0,8(sp)
    80001032:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001034:	ce11                	beqz	a2,80001050 <strncmp+0x22>
    80001036:	00054783          	lbu	a5,0(a0)
    8000103a:	cf89                	beqz	a5,80001054 <strncmp+0x26>
    8000103c:	0005c703          	lbu	a4,0(a1)
    80001040:	00f71a63          	bne	a4,a5,80001054 <strncmp+0x26>
    n--, p++, q++;
    80001044:	367d                	addiw	a2,a2,-1
    80001046:	0505                	addi	a0,a0,1
    80001048:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000104a:	f675                	bnez	a2,80001036 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000104c:	4501                	li	a0,0
    8000104e:	a809                	j	80001060 <strncmp+0x32>
    80001050:	4501                	li	a0,0
    80001052:	a039                	j	80001060 <strncmp+0x32>
  if(n == 0)
    80001054:	ca09                	beqz	a2,80001066 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80001056:	00054503          	lbu	a0,0(a0)
    8000105a:	0005c783          	lbu	a5,0(a1)
    8000105e:	9d1d                	subw	a0,a0,a5
}
    80001060:	6422                	ld	s0,8(sp)
    80001062:	0141                	addi	sp,sp,16
    80001064:	8082                	ret
    return 0;
    80001066:	4501                	li	a0,0
    80001068:	bfe5                	j	80001060 <strncmp+0x32>

000000008000106a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000106a:	1141                	addi	sp,sp,-16
    8000106c:	e422                	sd	s0,8(sp)
    8000106e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80001070:	872a                	mv	a4,a0
    80001072:	8832                	mv	a6,a2
    80001074:	367d                	addiw	a2,a2,-1
    80001076:	01005963          	blez	a6,80001088 <strncpy+0x1e>
    8000107a:	0705                	addi	a4,a4,1
    8000107c:	0005c783          	lbu	a5,0(a1)
    80001080:	fef70fa3          	sb	a5,-1(a4)
    80001084:	0585                	addi	a1,a1,1
    80001086:	f7f5                	bnez	a5,80001072 <strncpy+0x8>
    ;
  while(n-- > 0)
    80001088:	86ba                	mv	a3,a4
    8000108a:	00c05c63          	blez	a2,800010a2 <strncpy+0x38>
    *s++ = 0;
    8000108e:	0685                	addi	a3,a3,1
    80001090:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80001094:	fff6c793          	not	a5,a3
    80001098:	9fb9                	addw	a5,a5,a4
    8000109a:	010787bb          	addw	a5,a5,a6
    8000109e:	fef048e3          	bgtz	a5,8000108e <strncpy+0x24>
  return os;
}
    800010a2:	6422                	ld	s0,8(sp)
    800010a4:	0141                	addi	sp,sp,16
    800010a6:	8082                	ret

00000000800010a8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800010a8:	1141                	addi	sp,sp,-16
    800010aa:	e422                	sd	s0,8(sp)
    800010ac:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800010ae:	02c05363          	blez	a2,800010d4 <safestrcpy+0x2c>
    800010b2:	fff6069b          	addiw	a3,a2,-1
    800010b6:	1682                	slli	a3,a3,0x20
    800010b8:	9281                	srli	a3,a3,0x20
    800010ba:	96ae                	add	a3,a3,a1
    800010bc:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800010be:	00d58963          	beq	a1,a3,800010d0 <safestrcpy+0x28>
    800010c2:	0585                	addi	a1,a1,1
    800010c4:	0785                	addi	a5,a5,1
    800010c6:	fff5c703          	lbu	a4,-1(a1)
    800010ca:	fee78fa3          	sb	a4,-1(a5)
    800010ce:	fb65                	bnez	a4,800010be <safestrcpy+0x16>
    ;
  *s = 0;
    800010d0:	00078023          	sb	zero,0(a5)
  return os;
}
    800010d4:	6422                	ld	s0,8(sp)
    800010d6:	0141                	addi	sp,sp,16
    800010d8:	8082                	ret

00000000800010da <strlen>:

int
strlen(const char *s)
{
    800010da:	1141                	addi	sp,sp,-16
    800010dc:	e422                	sd	s0,8(sp)
    800010de:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800010e0:	00054783          	lbu	a5,0(a0)
    800010e4:	cf91                	beqz	a5,80001100 <strlen+0x26>
    800010e6:	0505                	addi	a0,a0,1
    800010e8:	87aa                	mv	a5,a0
    800010ea:	4685                	li	a3,1
    800010ec:	9e89                	subw	a3,a3,a0
    800010ee:	00f6853b          	addw	a0,a3,a5
    800010f2:	0785                	addi	a5,a5,1
    800010f4:	fff7c703          	lbu	a4,-1(a5)
    800010f8:	fb7d                	bnez	a4,800010ee <strlen+0x14>
    ;
  return n;
}
    800010fa:	6422                	ld	s0,8(sp)
    800010fc:	0141                	addi	sp,sp,16
    800010fe:	8082                	ret
  for(n = 0; s[n]; n++)
    80001100:	4501                	li	a0,0
    80001102:	bfe5                	j	800010fa <strlen+0x20>

0000000080001104 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001104:	1141                	addi	sp,sp,-16
    80001106:	e406                	sd	ra,8(sp)
    80001108:	e022                	sd	s0,0(sp)
    8000110a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000110c:	00001097          	auipc	ra,0x1
    80001110:	b08080e7          	jalr	-1272(ra) # 80001c14 <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001114:	0002f717          	auipc	a4,0x2f
    80001118:	f1470713          	addi	a4,a4,-236 # 80030028 <started>
  if(cpuid() == 0){
    8000111c:	c139                	beqz	a0,80001162 <main+0x5e>
    while(started == 0)
    8000111e:	431c                	lw	a5,0(a4)
    80001120:	2781                	sext.w	a5,a5
    80001122:	dff5                	beqz	a5,8000111e <main+0x1a>
      ;
    __sync_synchronize();
    80001124:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001128:	00001097          	auipc	ra,0x1
    8000112c:	aec080e7          	jalr	-1300(ra) # 80001c14 <cpuid>
    80001130:	85aa                	mv	a1,a0
    80001132:	00007517          	auipc	a0,0x7
    80001136:	21650513          	addi	a0,a0,534 # 80008348 <userret+0x2b8>
    8000113a:	fffff097          	auipc	ra,0xfffff
    8000113e:	468080e7          	jalr	1128(ra) # 800005a2 <printf>
    kvminithart();    // turn on paging
    80001142:	00000097          	auipc	ra,0x0
    80001146:	1ea080e7          	jalr	490(ra) # 8000132c <kvminithart>
    trapinithart();   // install kernel trap vector
    8000114a:	00001097          	auipc	ra,0x1
    8000114e:	712080e7          	jalr	1810(ra) # 8000285c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001152:	00005097          	auipc	ra,0x5
    80001156:	f6e080e7          	jalr	-146(ra) # 800060c0 <plicinithart>
  }

  scheduler();        
    8000115a:	00001097          	auipc	ra,0x1
    8000115e:	fc4080e7          	jalr	-60(ra) # 8000211e <scheduler>
    consoleinit();
    80001162:	fffff097          	auipc	ra,0xfffff
    80001166:	2f8080e7          	jalr	760(ra) # 8000045a <consoleinit>
    printfinit();
    8000116a:	fffff097          	auipc	ra,0xfffff
    8000116e:	618080e7          	jalr	1560(ra) # 80000782 <printfinit>
    printf("\n");
    80001172:	00007517          	auipc	a0,0x7
    80001176:	16e50513          	addi	a0,a0,366 # 800082e0 <userret+0x250>
    8000117a:	fffff097          	auipc	ra,0xfffff
    8000117e:	428080e7          	jalr	1064(ra) # 800005a2 <printf>
    printf("xv6 kernel is booting\n");
    80001182:	00007517          	auipc	a0,0x7
    80001186:	1ae50513          	addi	a0,a0,430 # 80008330 <userret+0x2a0>
    8000118a:	fffff097          	auipc	ra,0xfffff
    8000118e:	418080e7          	jalr	1048(ra) # 800005a2 <printf>
    printf("\n");
    80001192:	00007517          	auipc	a0,0x7
    80001196:	14e50513          	addi	a0,a0,334 # 800082e0 <userret+0x250>
    8000119a:	fffff097          	auipc	ra,0xfffff
    8000119e:	408080e7          	jalr	1032(ra) # 800005a2 <printf>
    kinit();         // physical page allocator
    800011a2:	00000097          	auipc	ra,0x0
    800011a6:	858080e7          	jalr	-1960(ra) # 800009fa <kinit>
    kvminit();       // create kernel page table
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	30c080e7          	jalr	780(ra) # 800014b6 <kvminit>
    kvminithart();   // turn on paging
    800011b2:	00000097          	auipc	ra,0x0
    800011b6:	17a080e7          	jalr	378(ra) # 8000132c <kvminithart>
    procinit();      // process table
    800011ba:	00001097          	auipc	ra,0x1
    800011be:	98a080e7          	jalr	-1654(ra) # 80001b44 <procinit>
    trapinit();      // trap vectors
    800011c2:	00001097          	auipc	ra,0x1
    800011c6:	672080e7          	jalr	1650(ra) # 80002834 <trapinit>
    trapinithart();  // install kernel trap vector
    800011ca:	00001097          	auipc	ra,0x1
    800011ce:	692080e7          	jalr	1682(ra) # 8000285c <trapinithart>
    plicinit();      // set up interrupt controller
    800011d2:	00005097          	auipc	ra,0x5
    800011d6:	ed8080e7          	jalr	-296(ra) # 800060aa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800011da:	00005097          	auipc	ra,0x5
    800011de:	ee6080e7          	jalr	-282(ra) # 800060c0 <plicinithart>
    binit();         // buffer cache
    800011e2:	00002097          	auipc	ra,0x2
    800011e6:	e70080e7          	jalr	-400(ra) # 80003052 <binit>
    iinit();         // inode cache
    800011ea:	00002097          	auipc	ra,0x2
    800011ee:	5fc080e7          	jalr	1532(ra) # 800037e6 <iinit>
    fileinit();      // file table
    800011f2:	00003097          	auipc	ra,0x3
    800011f6:	686080e7          	jalr	1670(ra) # 80004878 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    800011fa:	4501                	li	a0,0
    800011fc:	00005097          	auipc	ra,0x5
    80001200:	fe6080e7          	jalr	-26(ra) # 800061e2 <virtio_disk_init>
    userinit();      // first user process
    80001204:	00001097          	auipc	ra,0x1
    80001208:	cb0080e7          	jalr	-848(ra) # 80001eb4 <userinit>
    __sync_synchronize();
    8000120c:	0ff0000f          	fence
    started = 1;
    80001210:	4785                	li	a5,1
    80001212:	0002f717          	auipc	a4,0x2f
    80001216:	e0f72b23          	sw	a5,-490(a4) # 80030028 <started>
    8000121a:	b781                	j	8000115a <main+0x56>

000000008000121c <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000121c:	7139                	addi	sp,sp,-64
    8000121e:	fc06                	sd	ra,56(sp)
    80001220:	f822                	sd	s0,48(sp)
    80001222:	f426                	sd	s1,40(sp)
    80001224:	f04a                	sd	s2,32(sp)
    80001226:	ec4e                	sd	s3,24(sp)
    80001228:	e852                	sd	s4,16(sp)
    8000122a:	e456                	sd	s5,8(sp)
    8000122c:	e05a                	sd	s6,0(sp)
    8000122e:	0080                	addi	s0,sp,64
    80001230:	84aa                	mv	s1,a0
    80001232:	89ae                	mv	s3,a1
    80001234:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001236:	57fd                	li	a5,-1
    80001238:	83e9                	srli	a5,a5,0x1a
    8000123a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000123c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000123e:	04b7f263          	bgeu	a5,a1,80001282 <walk+0x66>
    panic("walk");
    80001242:	00007517          	auipc	a0,0x7
    80001246:	11e50513          	addi	a0,a0,286 # 80008360 <userret+0x2d0>
    8000124a:	fffff097          	auipc	ra,0xfffff
    8000124e:	2fe080e7          	jalr	766(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001252:	060a8663          	beqz	s5,800012be <walk+0xa2>
    80001256:	00000097          	auipc	ra,0x0
    8000125a:	842080e7          	jalr	-1982(ra) # 80000a98 <kalloc>
    8000125e:	84aa                	mv	s1,a0
    80001260:	c529                	beqz	a0,800012aa <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001262:	6605                	lui	a2,0x1
    80001264:	4581                	li	a1,0
    80001266:	00000097          	auipc	ra,0x0
    8000126a:	cf0080e7          	jalr	-784(ra) # 80000f56 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000126e:	00c4d793          	srli	a5,s1,0xc
    80001272:	07aa                	slli	a5,a5,0xa
    80001274:	0017e793          	ori	a5,a5,1
    80001278:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000127c:	3a5d                	addiw	s4,s4,-9
    8000127e:	036a0063          	beq	s4,s6,8000129e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001282:	0149d933          	srl	s2,s3,s4
    80001286:	1ff97913          	andi	s2,s2,511
    8000128a:	090e                	slli	s2,s2,0x3
    8000128c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000128e:	00093483          	ld	s1,0(s2)
    80001292:	0014f793          	andi	a5,s1,1
    80001296:	dfd5                	beqz	a5,80001252 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001298:	80a9                	srli	s1,s1,0xa
    8000129a:	04b2                	slli	s1,s1,0xc
    8000129c:	b7c5                	j	8000127c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000129e:	00c9d513          	srli	a0,s3,0xc
    800012a2:	1ff57513          	andi	a0,a0,511
    800012a6:	050e                	slli	a0,a0,0x3
    800012a8:	9526                	add	a0,a0,s1
}
    800012aa:	70e2                	ld	ra,56(sp)
    800012ac:	7442                	ld	s0,48(sp)
    800012ae:	74a2                	ld	s1,40(sp)
    800012b0:	7902                	ld	s2,32(sp)
    800012b2:	69e2                	ld	s3,24(sp)
    800012b4:	6a42                	ld	s4,16(sp)
    800012b6:	6aa2                	ld	s5,8(sp)
    800012b8:	6b02                	ld	s6,0(sp)
    800012ba:	6121                	addi	sp,sp,64
    800012bc:	8082                	ret
        return 0;
    800012be:	4501                	li	a0,0
    800012c0:	b7ed                	j	800012aa <walk+0x8e>

00000000800012c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    800012c2:	7179                	addi	sp,sp,-48
    800012c4:	f406                	sd	ra,40(sp)
    800012c6:	f022                	sd	s0,32(sp)
    800012c8:	ec26                	sd	s1,24(sp)
    800012ca:	e84a                	sd	s2,16(sp)
    800012cc:	e44e                	sd	s3,8(sp)
    800012ce:	e052                	sd	s4,0(sp)
    800012d0:	1800                	addi	s0,sp,48
    800012d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800012d4:	84aa                	mv	s1,a0
    800012d6:	6905                	lui	s2,0x1
    800012d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012da:	4985                	li	s3,1
    800012dc:	a821                	j	800012f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800012de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800012e0:	0532                	slli	a0,a0,0xc
    800012e2:	00000097          	auipc	ra,0x0
    800012e6:	fe0080e7          	jalr	-32(ra) # 800012c2 <freewalk>
      pagetable[i] = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800012ee:	04a1                	addi	s1,s1,8
    800012f0:	03248163          	beq	s1,s2,80001312 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800012f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800012f6:	00f57793          	andi	a5,a0,15
    800012fa:	ff3782e3          	beq	a5,s3,800012de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800012fe:	8905                	andi	a0,a0,1
    80001300:	d57d                	beqz	a0,800012ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001302:	00007517          	auipc	a0,0x7
    80001306:	06650513          	addi	a0,a0,102 # 80008368 <userret+0x2d8>
    8000130a:	fffff097          	auipc	ra,0xfffff
    8000130e:	23e080e7          	jalr	574(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    80001312:	8552                	mv	a0,s4
    80001314:	fffff097          	auipc	ra,0xfffff
    80001318:	5fc080e7          	jalr	1532(ra) # 80000910 <kfree>
}
    8000131c:	70a2                	ld	ra,40(sp)
    8000131e:	7402                	ld	s0,32(sp)
    80001320:	64e2                	ld	s1,24(sp)
    80001322:	6942                	ld	s2,16(sp)
    80001324:	69a2                	ld	s3,8(sp)
    80001326:	6a02                	ld	s4,0(sp)
    80001328:	6145                	addi	sp,sp,48
    8000132a:	8082                	ret

000000008000132c <kvminithart>:
{
    8000132c:	1141                	addi	sp,sp,-16
    8000132e:	e422                	sd	s0,8(sp)
    80001330:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001332:	0002f797          	auipc	a5,0x2f
    80001336:	cfe7b783          	ld	a5,-770(a5) # 80030030 <kernel_pagetable>
    8000133a:	83b1                	srli	a5,a5,0xc
    8000133c:	577d                	li	a4,-1
    8000133e:	177e                	slli	a4,a4,0x3f
    80001340:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001342:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001346:	12000073          	sfence.vma
}
    8000134a:	6422                	ld	s0,8(sp)
    8000134c:	0141                	addi	sp,sp,16
    8000134e:	8082                	ret

0000000080001350 <walkaddr>:
  if(va >= MAXVA)
    80001350:	57fd                	li	a5,-1
    80001352:	83e9                	srli	a5,a5,0x1a
    80001354:	00b7f463          	bgeu	a5,a1,8000135c <walkaddr+0xc>
    return 0;
    80001358:	4501                	li	a0,0
}
    8000135a:	8082                	ret
{
    8000135c:	1141                	addi	sp,sp,-16
    8000135e:	e406                	sd	ra,8(sp)
    80001360:	e022                	sd	s0,0(sp)
    80001362:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001364:	4601                	li	a2,0
    80001366:	00000097          	auipc	ra,0x0
    8000136a:	eb6080e7          	jalr	-330(ra) # 8000121c <walk>
  if(pte == 0)
    8000136e:	c105                	beqz	a0,8000138e <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001370:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001372:	0117f693          	andi	a3,a5,17
    80001376:	4745                	li	a4,17
    return 0;
    80001378:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000137a:	00e68663          	beq	a3,a4,80001386 <walkaddr+0x36>
}
    8000137e:	60a2                	ld	ra,8(sp)
    80001380:	6402                	ld	s0,0(sp)
    80001382:	0141                	addi	sp,sp,16
    80001384:	8082                	ret
  pa = PTE2PA(*pte);
    80001386:	00a7d513          	srli	a0,a5,0xa
    8000138a:	0532                	slli	a0,a0,0xc
  return pa;
    8000138c:	bfcd                	j	8000137e <walkaddr+0x2e>
    return 0;
    8000138e:	4501                	li	a0,0
    80001390:	b7fd                	j	8000137e <walkaddr+0x2e>

0000000080001392 <kvmpa>:
{
    80001392:	1101                	addi	sp,sp,-32
    80001394:	ec06                	sd	ra,24(sp)
    80001396:	e822                	sd	s0,16(sp)
    80001398:	e426                	sd	s1,8(sp)
    8000139a:	1000                	addi	s0,sp,32
    8000139c:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    8000139e:	1552                	slli	a0,a0,0x34
    800013a0:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    800013a4:	4601                	li	a2,0
    800013a6:	0002f517          	auipc	a0,0x2f
    800013aa:	c8a53503          	ld	a0,-886(a0) # 80030030 <kernel_pagetable>
    800013ae:	00000097          	auipc	ra,0x0
    800013b2:	e6e080e7          	jalr	-402(ra) # 8000121c <walk>
  if(pte == 0)
    800013b6:	cd09                	beqz	a0,800013d0 <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    800013b8:	6108                	ld	a0,0(a0)
    800013ba:	00157793          	andi	a5,a0,1
    800013be:	c38d                	beqz	a5,800013e0 <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    800013c0:	8129                	srli	a0,a0,0xa
    800013c2:	0532                	slli	a0,a0,0xc
}
    800013c4:	9526                	add	a0,a0,s1
    800013c6:	60e2                	ld	ra,24(sp)
    800013c8:	6442                	ld	s0,16(sp)
    800013ca:	64a2                	ld	s1,8(sp)
    800013cc:	6105                	addi	sp,sp,32
    800013ce:	8082                	ret
    panic("kvmpa");
    800013d0:	00007517          	auipc	a0,0x7
    800013d4:	fa850513          	addi	a0,a0,-88 # 80008378 <userret+0x2e8>
    800013d8:	fffff097          	auipc	ra,0xfffff
    800013dc:	170080e7          	jalr	368(ra) # 80000548 <panic>
    panic("kvmpa");
    800013e0:	00007517          	auipc	a0,0x7
    800013e4:	f9850513          	addi	a0,a0,-104 # 80008378 <userret+0x2e8>
    800013e8:	fffff097          	auipc	ra,0xfffff
    800013ec:	160080e7          	jalr	352(ra) # 80000548 <panic>

00000000800013f0 <mappages>:
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
    80001406:	8aaa                	mv	s5,a0
    80001408:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    8000140a:	777d                	lui	a4,0xfffff
    8000140c:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001410:	167d                	addi	a2,a2,-1
    80001412:	00b609b3          	add	s3,a2,a1
    80001416:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000141a:	893e                	mv	s2,a5
    8000141c:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    80001420:	6b85                	lui	s7,0x1
    80001422:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001426:	4605                	li	a2,1
    80001428:	85ca                	mv	a1,s2
    8000142a:	8556                	mv	a0,s5
    8000142c:	00000097          	auipc	ra,0x0
    80001430:	df0080e7          	jalr	-528(ra) # 8000121c <walk>
    80001434:	c51d                	beqz	a0,80001462 <mappages+0x72>
    if(*pte & PTE_V)
    80001436:	611c                	ld	a5,0(a0)
    80001438:	8b85                	andi	a5,a5,1
    8000143a:	ef81                	bnez	a5,80001452 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000143c:	80b1                	srli	s1,s1,0xc
    8000143e:	04aa                	slli	s1,s1,0xa
    80001440:	0164e4b3          	or	s1,s1,s6
    80001444:	0014e493          	ori	s1,s1,1
    80001448:	e104                	sd	s1,0(a0)
    if(a == last)
    8000144a:	03390863          	beq	s2,s3,8000147a <mappages+0x8a>
    a += PGSIZE;
    8000144e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001450:	bfc9                	j	80001422 <mappages+0x32>
      panic("remap");
    80001452:	00007517          	auipc	a0,0x7
    80001456:	f2e50513          	addi	a0,a0,-210 # 80008380 <userret+0x2f0>
    8000145a:	fffff097          	auipc	ra,0xfffff
    8000145e:	0ee080e7          	jalr	238(ra) # 80000548 <panic>
      return -1;
    80001462:	557d                	li	a0,-1
}
    80001464:	60a6                	ld	ra,72(sp)
    80001466:	6406                	ld	s0,64(sp)
    80001468:	74e2                	ld	s1,56(sp)
    8000146a:	7942                	ld	s2,48(sp)
    8000146c:	79a2                	ld	s3,40(sp)
    8000146e:	7a02                	ld	s4,32(sp)
    80001470:	6ae2                	ld	s5,24(sp)
    80001472:	6b42                	ld	s6,16(sp)
    80001474:	6ba2                	ld	s7,8(sp)
    80001476:	6161                	addi	sp,sp,80
    80001478:	8082                	ret
  return 0;
    8000147a:	4501                	li	a0,0
    8000147c:	b7e5                	j	80001464 <mappages+0x74>

000000008000147e <kvmmap>:
{
    8000147e:	1141                	addi	sp,sp,-16
    80001480:	e406                	sd	ra,8(sp)
    80001482:	e022                	sd	s0,0(sp)
    80001484:	0800                	addi	s0,sp,16
    80001486:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001488:	86ae                	mv	a3,a1
    8000148a:	85aa                	mv	a1,a0
    8000148c:	0002f517          	auipc	a0,0x2f
    80001490:	ba453503          	ld	a0,-1116(a0) # 80030030 <kernel_pagetable>
    80001494:	00000097          	auipc	ra,0x0
    80001498:	f5c080e7          	jalr	-164(ra) # 800013f0 <mappages>
    8000149c:	e509                	bnez	a0,800014a6 <kvmmap+0x28>
}
    8000149e:	60a2                	ld	ra,8(sp)
    800014a0:	6402                	ld	s0,0(sp)
    800014a2:	0141                	addi	sp,sp,16
    800014a4:	8082                	ret
    panic("kvmmap");
    800014a6:	00007517          	auipc	a0,0x7
    800014aa:	ee250513          	addi	a0,a0,-286 # 80008388 <userret+0x2f8>
    800014ae:	fffff097          	auipc	ra,0xfffff
    800014b2:	09a080e7          	jalr	154(ra) # 80000548 <panic>

00000000800014b6 <kvminit>:
{
    800014b6:	1101                	addi	sp,sp,-32
    800014b8:	ec06                	sd	ra,24(sp)
    800014ba:	e822                	sd	s0,16(sp)
    800014bc:	e426                	sd	s1,8(sp)
    800014be:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800014c0:	fffff097          	auipc	ra,0xfffff
    800014c4:	5d8080e7          	jalr	1496(ra) # 80000a98 <kalloc>
    800014c8:	0002f797          	auipc	a5,0x2f
    800014cc:	b6a7b423          	sd	a0,-1176(a5) # 80030030 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800014d0:	6605                	lui	a2,0x1
    800014d2:	4581                	li	a1,0
    800014d4:	00000097          	auipc	ra,0x0
    800014d8:	a82080e7          	jalr	-1406(ra) # 80000f56 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800014dc:	4699                	li	a3,6
    800014de:	6605                	lui	a2,0x1
    800014e0:	100005b7          	lui	a1,0x10000
    800014e4:	10000537          	lui	a0,0x10000
    800014e8:	00000097          	auipc	ra,0x0
    800014ec:	f96080e7          	jalr	-106(ra) # 8000147e <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    800014f0:	4699                	li	a3,6
    800014f2:	6605                	lui	a2,0x1
    800014f4:	100015b7          	lui	a1,0x10001
    800014f8:	10001537          	lui	a0,0x10001
    800014fc:	00000097          	auipc	ra,0x0
    80001500:	f82080e7          	jalr	-126(ra) # 8000147e <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    80001504:	4699                	li	a3,6
    80001506:	6605                	lui	a2,0x1
    80001508:	100025b7          	lui	a1,0x10002
    8000150c:	10002537          	lui	a0,0x10002
    80001510:	00000097          	auipc	ra,0x0
    80001514:	f6e080e7          	jalr	-146(ra) # 8000147e <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001518:	4699                	li	a3,6
    8000151a:	6641                	lui	a2,0x10
    8000151c:	020005b7          	lui	a1,0x2000
    80001520:	02000537          	lui	a0,0x2000
    80001524:	00000097          	auipc	ra,0x0
    80001528:	f5a080e7          	jalr	-166(ra) # 8000147e <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000152c:	4699                	li	a3,6
    8000152e:	00400637          	lui	a2,0x400
    80001532:	0c0005b7          	lui	a1,0xc000
    80001536:	0c000537          	lui	a0,0xc000
    8000153a:	00000097          	auipc	ra,0x0
    8000153e:	f44080e7          	jalr	-188(ra) # 8000147e <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001542:	00008497          	auipc	s1,0x8
    80001546:	abe48493          	addi	s1,s1,-1346 # 80009000 <initcode>
    8000154a:	46a9                	li	a3,10
    8000154c:	80008617          	auipc	a2,0x80008
    80001550:	ab460613          	addi	a2,a2,-1356 # 9000 <_entry-0x7fff7000>
    80001554:	4585                	li	a1,1
    80001556:	05fe                	slli	a1,a1,0x1f
    80001558:	852e                	mv	a0,a1
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	f24080e7          	jalr	-220(ra) # 8000147e <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001562:	4699                	li	a3,6
    80001564:	4645                	li	a2,17
    80001566:	066e                	slli	a2,a2,0x1b
    80001568:	8e05                	sub	a2,a2,s1
    8000156a:	85a6                	mv	a1,s1
    8000156c:	8526                	mv	a0,s1
    8000156e:	00000097          	auipc	ra,0x0
    80001572:	f10080e7          	jalr	-240(ra) # 8000147e <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001576:	46a9                	li	a3,10
    80001578:	6605                	lui	a2,0x1
    8000157a:	00007597          	auipc	a1,0x7
    8000157e:	a8658593          	addi	a1,a1,-1402 # 80008000 <trampoline>
    80001582:	04000537          	lui	a0,0x4000
    80001586:	157d                	addi	a0,a0,-1
    80001588:	0532                	slli	a0,a0,0xc
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	ef4080e7          	jalr	-268(ra) # 8000147e <kvmmap>
}
    80001592:	60e2                	ld	ra,24(sp)
    80001594:	6442                	ld	s0,16(sp)
    80001596:	64a2                	ld	s1,8(sp)
    80001598:	6105                	addi	sp,sp,32
    8000159a:	8082                	ret

000000008000159c <uvmunmap>:
{
    8000159c:	715d                	addi	sp,sp,-80
    8000159e:	e486                	sd	ra,72(sp)
    800015a0:	e0a2                	sd	s0,64(sp)
    800015a2:	fc26                	sd	s1,56(sp)
    800015a4:	f84a                	sd	s2,48(sp)
    800015a6:	f44e                	sd	s3,40(sp)
    800015a8:	f052                	sd	s4,32(sp)
    800015aa:	ec56                	sd	s5,24(sp)
    800015ac:	e85a                	sd	s6,16(sp)
    800015ae:	e45e                	sd	s7,8(sp)
    800015b0:	0880                	addi	s0,sp,80
    800015b2:	8a2a                	mv	s4,a0
    800015b4:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    800015b6:	77fd                	lui	a5,0xfffff
    800015b8:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800015bc:	167d                	addi	a2,a2,-1
    800015be:	00b609b3          	add	s3,a2,a1
    800015c2:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    800015c6:	4b05                	li	s6,1
    a += PGSIZE;
    800015c8:	6b85                	lui	s7,0x1
    800015ca:	a0b9                	j	80001618 <uvmunmap+0x7c>
      panic("uvmunmap: walk");
    800015cc:	00007517          	auipc	a0,0x7
    800015d0:	dc450513          	addi	a0,a0,-572 # 80008390 <userret+0x300>
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	f74080e7          	jalr	-140(ra) # 80000548 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800015dc:	85ca                	mv	a1,s2
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	dc250513          	addi	a0,a0,-574 # 800083a0 <userret+0x310>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	fbc080e7          	jalr	-68(ra) # 800005a2 <printf>
      panic("uvmunmap: not mapped");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	dc250513          	addi	a0,a0,-574 # 800083b0 <userret+0x320>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f52080e7          	jalr	-174(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    800015fe:	00007517          	auipc	a0,0x7
    80001602:	dca50513          	addi	a0,a0,-566 # 800083c8 <userret+0x338>
    80001606:	fffff097          	auipc	ra,0xfffff
    8000160a:	f42080e7          	jalr	-190(ra) # 80000548 <panic>
    *pte = 0;
    8000160e:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001612:	03390e63          	beq	s2,s3,8000164e <uvmunmap+0xb2>
    a += PGSIZE;
    80001616:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    80001618:	4601                	li	a2,0
    8000161a:	85ca                	mv	a1,s2
    8000161c:	8552                	mv	a0,s4
    8000161e:	00000097          	auipc	ra,0x0
    80001622:	bfe080e7          	jalr	-1026(ra) # 8000121c <walk>
    80001626:	84aa                	mv	s1,a0
    80001628:	d155                	beqz	a0,800015cc <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    8000162a:	6110                	ld	a2,0(a0)
    8000162c:	00167793          	andi	a5,a2,1
    80001630:	d7d5                	beqz	a5,800015dc <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001632:	3ff67793          	andi	a5,a2,1023
    80001636:	fd6784e3          	beq	a5,s6,800015fe <uvmunmap+0x62>
    if(do_free){
    8000163a:	fc0a8ae3          	beqz	s5,8000160e <uvmunmap+0x72>
      pa = PTE2PA(*pte);
    8000163e:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    80001640:	00c61513          	slli	a0,a2,0xc
    80001644:	fffff097          	auipc	ra,0xfffff
    80001648:	2cc080e7          	jalr	716(ra) # 80000910 <kfree>
    8000164c:	b7c9                	j	8000160e <uvmunmap+0x72>
}
    8000164e:	60a6                	ld	ra,72(sp)
    80001650:	6406                	ld	s0,64(sp)
    80001652:	74e2                	ld	s1,56(sp)
    80001654:	7942                	ld	s2,48(sp)
    80001656:	79a2                	ld	s3,40(sp)
    80001658:	7a02                	ld	s4,32(sp)
    8000165a:	6ae2                	ld	s5,24(sp)
    8000165c:	6b42                	ld	s6,16(sp)
    8000165e:	6ba2                	ld	s7,8(sp)
    80001660:	6161                	addi	sp,sp,80
    80001662:	8082                	ret

0000000080001664 <uvmcreate>:
{
    80001664:	1101                	addi	sp,sp,-32
    80001666:	ec06                	sd	ra,24(sp)
    80001668:	e822                	sd	s0,16(sp)
    8000166a:	e426                	sd	s1,8(sp)
    8000166c:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    8000166e:	fffff097          	auipc	ra,0xfffff
    80001672:	42a080e7          	jalr	1066(ra) # 80000a98 <kalloc>
  if(pagetable == 0)
    80001676:	cd11                	beqz	a0,80001692 <uvmcreate+0x2e>
    80001678:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    8000167a:	6605                	lui	a2,0x1
    8000167c:	4581                	li	a1,0
    8000167e:	00000097          	auipc	ra,0x0
    80001682:	8d8080e7          	jalr	-1832(ra) # 80000f56 <memset>
}
    80001686:	8526                	mv	a0,s1
    80001688:	60e2                	ld	ra,24(sp)
    8000168a:	6442                	ld	s0,16(sp)
    8000168c:	64a2                	ld	s1,8(sp)
    8000168e:	6105                	addi	sp,sp,32
    80001690:	8082                	ret
    panic("uvmcreate: out of memory");
    80001692:	00007517          	auipc	a0,0x7
    80001696:	d4e50513          	addi	a0,a0,-690 # 800083e0 <userret+0x350>
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	eae080e7          	jalr	-338(ra) # 80000548 <panic>

00000000800016a2 <uvminit>:
{
    800016a2:	7179                	addi	sp,sp,-48
    800016a4:	f406                	sd	ra,40(sp)
    800016a6:	f022                	sd	s0,32(sp)
    800016a8:	ec26                	sd	s1,24(sp)
    800016aa:	e84a                	sd	s2,16(sp)
    800016ac:	e44e                	sd	s3,8(sp)
    800016ae:	e052                	sd	s4,0(sp)
    800016b0:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    800016b2:	6785                	lui	a5,0x1
    800016b4:	04f67863          	bgeu	a2,a5,80001704 <uvminit+0x62>
    800016b8:	8a2a                	mv	s4,a0
    800016ba:	89ae                	mv	s3,a1
    800016bc:	84b2                	mv	s1,a2
  mem = kalloc();
    800016be:	fffff097          	auipc	ra,0xfffff
    800016c2:	3da080e7          	jalr	986(ra) # 80000a98 <kalloc>
    800016c6:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800016c8:	6605                	lui	a2,0x1
    800016ca:	4581                	li	a1,0
    800016cc:	00000097          	auipc	ra,0x0
    800016d0:	88a080e7          	jalr	-1910(ra) # 80000f56 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800016d4:	4779                	li	a4,30
    800016d6:	86ca                	mv	a3,s2
    800016d8:	6605                	lui	a2,0x1
    800016da:	4581                	li	a1,0
    800016dc:	8552                	mv	a0,s4
    800016de:	00000097          	auipc	ra,0x0
    800016e2:	d12080e7          	jalr	-750(ra) # 800013f0 <mappages>
  memmove(mem, src, sz);
    800016e6:	8626                	mv	a2,s1
    800016e8:	85ce                	mv	a1,s3
    800016ea:	854a                	mv	a0,s2
    800016ec:	00000097          	auipc	ra,0x0
    800016f0:	8c6080e7          	jalr	-1850(ra) # 80000fb2 <memmove>
}
    800016f4:	70a2                	ld	ra,40(sp)
    800016f6:	7402                	ld	s0,32(sp)
    800016f8:	64e2                	ld	s1,24(sp)
    800016fa:	6942                	ld	s2,16(sp)
    800016fc:	69a2                	ld	s3,8(sp)
    800016fe:	6a02                	ld	s4,0(sp)
    80001700:	6145                	addi	sp,sp,48
    80001702:	8082                	ret
    panic("inituvm: more than a page");
    80001704:	00007517          	auipc	a0,0x7
    80001708:	cfc50513          	addi	a0,a0,-772 # 80008400 <userret+0x370>
    8000170c:	fffff097          	auipc	ra,0xfffff
    80001710:	e3c080e7          	jalr	-452(ra) # 80000548 <panic>

0000000080001714 <uvmdealloc>:
{
    80001714:	1101                	addi	sp,sp,-32
    80001716:	ec06                	sd	ra,24(sp)
    80001718:	e822                	sd	s0,16(sp)
    8000171a:	e426                	sd	s1,8(sp)
    8000171c:	1000                	addi	s0,sp,32
    return oldsz;
    8000171e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001720:	00b67d63          	bgeu	a2,a1,8000173a <uvmdealloc+0x26>
    80001724:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    80001726:	6785                	lui	a5,0x1
    80001728:	17fd                	addi	a5,a5,-1
    8000172a:	00f60733          	add	a4,a2,a5
    8000172e:	76fd                	lui	a3,0xfffff
    80001730:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    80001732:	97ae                	add	a5,a5,a1
    80001734:	8ff5                	and	a5,a5,a3
    80001736:	00f76863          	bltu	a4,a5,80001746 <uvmdealloc+0x32>
}
    8000173a:	8526                	mv	a0,s1
    8000173c:	60e2                	ld	ra,24(sp)
    8000173e:	6442                	ld	s0,16(sp)
    80001740:	64a2                	ld	s1,8(sp)
    80001742:	6105                	addi	sp,sp,32
    80001744:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    80001746:	4685                	li	a3,1
    80001748:	40e58633          	sub	a2,a1,a4
    8000174c:	85ba                	mv	a1,a4
    8000174e:	00000097          	auipc	ra,0x0
    80001752:	e4e080e7          	jalr	-434(ra) # 8000159c <uvmunmap>
    80001756:	b7d5                	j	8000173a <uvmdealloc+0x26>

0000000080001758 <uvmalloc>:
  if(newsz < oldsz)
    80001758:	0ab66163          	bltu	a2,a1,800017fa <uvmalloc+0xa2>
{
    8000175c:	7139                	addi	sp,sp,-64
    8000175e:	fc06                	sd	ra,56(sp)
    80001760:	f822                	sd	s0,48(sp)
    80001762:	f426                	sd	s1,40(sp)
    80001764:	f04a                	sd	s2,32(sp)
    80001766:	ec4e                	sd	s3,24(sp)
    80001768:	e852                	sd	s4,16(sp)
    8000176a:	e456                	sd	s5,8(sp)
    8000176c:	0080                	addi	s0,sp,64
    8000176e:	8aaa                	mv	s5,a0
    80001770:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001772:	6985                	lui	s3,0x1
    80001774:	19fd                	addi	s3,s3,-1
    80001776:	95ce                	add	a1,a1,s3
    80001778:	79fd                	lui	s3,0xfffff
    8000177a:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    8000177e:	08c9f063          	bgeu	s3,a2,800017fe <uvmalloc+0xa6>
  a = oldsz;
    80001782:	894e                	mv	s2,s3
    mem = kalloc();
    80001784:	fffff097          	auipc	ra,0xfffff
    80001788:	314080e7          	jalr	788(ra) # 80000a98 <kalloc>
    8000178c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000178e:	c51d                	beqz	a0,800017bc <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001790:	6605                	lui	a2,0x1
    80001792:	4581                	li	a1,0
    80001794:	fffff097          	auipc	ra,0xfffff
    80001798:	7c2080e7          	jalr	1986(ra) # 80000f56 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000179c:	4779                	li	a4,30
    8000179e:	86a6                	mv	a3,s1
    800017a0:	6605                	lui	a2,0x1
    800017a2:	85ca                	mv	a1,s2
    800017a4:	8556                	mv	a0,s5
    800017a6:	00000097          	auipc	ra,0x0
    800017aa:	c4a080e7          	jalr	-950(ra) # 800013f0 <mappages>
    800017ae:	e905                	bnez	a0,800017de <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    800017b0:	6785                	lui	a5,0x1
    800017b2:	993e                	add	s2,s2,a5
    800017b4:	fd4968e3          	bltu	s2,s4,80001784 <uvmalloc+0x2c>
  return newsz;
    800017b8:	8552                	mv	a0,s4
    800017ba:	a809                	j	800017cc <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800017bc:	864e                	mv	a2,s3
    800017be:	85ca                	mv	a1,s2
    800017c0:	8556                	mv	a0,s5
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	f52080e7          	jalr	-174(ra) # 80001714 <uvmdealloc>
      return 0;
    800017ca:	4501                	li	a0,0
}
    800017cc:	70e2                	ld	ra,56(sp)
    800017ce:	7442                	ld	s0,48(sp)
    800017d0:	74a2                	ld	s1,40(sp)
    800017d2:	7902                	ld	s2,32(sp)
    800017d4:	69e2                	ld	s3,24(sp)
    800017d6:	6a42                	ld	s4,16(sp)
    800017d8:	6aa2                	ld	s5,8(sp)
    800017da:	6121                	addi	sp,sp,64
    800017dc:	8082                	ret
      kfree(mem);
    800017de:	8526                	mv	a0,s1
    800017e0:	fffff097          	auipc	ra,0xfffff
    800017e4:	130080e7          	jalr	304(ra) # 80000910 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800017e8:	864e                	mv	a2,s3
    800017ea:	85ca                	mv	a1,s2
    800017ec:	8556                	mv	a0,s5
    800017ee:	00000097          	auipc	ra,0x0
    800017f2:	f26080e7          	jalr	-218(ra) # 80001714 <uvmdealloc>
      return 0;
    800017f6:	4501                	li	a0,0
    800017f8:	bfd1                	j	800017cc <uvmalloc+0x74>
    return oldsz;
    800017fa:	852e                	mv	a0,a1
}
    800017fc:	8082                	ret
  return newsz;
    800017fe:	8532                	mv	a0,a2
    80001800:	b7f1                	j	800017cc <uvmalloc+0x74>

0000000080001802 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001802:	1101                	addi	sp,sp,-32
    80001804:	ec06                	sd	ra,24(sp)
    80001806:	e822                	sd	s0,16(sp)
    80001808:	e426                	sd	s1,8(sp)
    8000180a:	1000                	addi	s0,sp,32
    8000180c:	84aa                	mv	s1,a0
    8000180e:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001810:	4685                	li	a3,1
    80001812:	4581                	li	a1,0
    80001814:	00000097          	auipc	ra,0x0
    80001818:	d88080e7          	jalr	-632(ra) # 8000159c <uvmunmap>
  freewalk(pagetable);
    8000181c:	8526                	mv	a0,s1
    8000181e:	00000097          	auipc	ra,0x0
    80001822:	aa4080e7          	jalr	-1372(ra) # 800012c2 <freewalk>
}
    80001826:	60e2                	ld	ra,24(sp)
    80001828:	6442                	ld	s0,16(sp)
    8000182a:	64a2                	ld	s1,8(sp)
    8000182c:	6105                	addi	sp,sp,32
    8000182e:	8082                	ret

0000000080001830 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001830:	c671                	beqz	a2,800018fc <uvmcopy+0xcc>
{
    80001832:	715d                	addi	sp,sp,-80
    80001834:	e486                	sd	ra,72(sp)
    80001836:	e0a2                	sd	s0,64(sp)
    80001838:	fc26                	sd	s1,56(sp)
    8000183a:	f84a                	sd	s2,48(sp)
    8000183c:	f44e                	sd	s3,40(sp)
    8000183e:	f052                	sd	s4,32(sp)
    80001840:	ec56                	sd	s5,24(sp)
    80001842:	e85a                	sd	s6,16(sp)
    80001844:	e45e                	sd	s7,8(sp)
    80001846:	0880                	addi	s0,sp,80
    80001848:	8b2a                	mv	s6,a0
    8000184a:	8aae                	mv	s5,a1
    8000184c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000184e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001850:	4601                	li	a2,0
    80001852:	85ce                	mv	a1,s3
    80001854:	855a                	mv	a0,s6
    80001856:	00000097          	auipc	ra,0x0
    8000185a:	9c6080e7          	jalr	-1594(ra) # 8000121c <walk>
    8000185e:	c531                	beqz	a0,800018aa <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001860:	6118                	ld	a4,0(a0)
    80001862:	00177793          	andi	a5,a4,1
    80001866:	cbb1                	beqz	a5,800018ba <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001868:	00a75593          	srli	a1,a4,0xa
    8000186c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001870:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001874:	fffff097          	auipc	ra,0xfffff
    80001878:	224080e7          	jalr	548(ra) # 80000a98 <kalloc>
    8000187c:	892a                	mv	s2,a0
    8000187e:	c939                	beqz	a0,800018d4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001880:	6605                	lui	a2,0x1
    80001882:	85de                	mv	a1,s7
    80001884:	fffff097          	auipc	ra,0xfffff
    80001888:	72e080e7          	jalr	1838(ra) # 80000fb2 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000188c:	8726                	mv	a4,s1
    8000188e:	86ca                	mv	a3,s2
    80001890:	6605                	lui	a2,0x1
    80001892:	85ce                	mv	a1,s3
    80001894:	8556                	mv	a0,s5
    80001896:	00000097          	auipc	ra,0x0
    8000189a:	b5a080e7          	jalr	-1190(ra) # 800013f0 <mappages>
    8000189e:	e515                	bnez	a0,800018ca <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800018a0:	6785                	lui	a5,0x1
    800018a2:	99be                	add	s3,s3,a5
    800018a4:	fb49e6e3          	bltu	s3,s4,80001850 <uvmcopy+0x20>
    800018a8:	a83d                	j	800018e6 <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    800018aa:	00007517          	auipc	a0,0x7
    800018ae:	b7650513          	addi	a0,a0,-1162 # 80008420 <userret+0x390>
    800018b2:	fffff097          	auipc	ra,0xfffff
    800018b6:	c96080e7          	jalr	-874(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    800018ba:	00007517          	auipc	a0,0x7
    800018be:	b8650513          	addi	a0,a0,-1146 # 80008440 <userret+0x3b0>
    800018c2:	fffff097          	auipc	ra,0xfffff
    800018c6:	c86080e7          	jalr	-890(ra) # 80000548 <panic>
      kfree(mem);
    800018ca:	854a                	mv	a0,s2
    800018cc:	fffff097          	auipc	ra,0xfffff
    800018d0:	044080e7          	jalr	68(ra) # 80000910 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800018d4:	4685                	li	a3,1
    800018d6:	864e                	mv	a2,s3
    800018d8:	4581                	li	a1,0
    800018da:	8556                	mv	a0,s5
    800018dc:	00000097          	auipc	ra,0x0
    800018e0:	cc0080e7          	jalr	-832(ra) # 8000159c <uvmunmap>
  return -1;
    800018e4:	557d                	li	a0,-1
}
    800018e6:	60a6                	ld	ra,72(sp)
    800018e8:	6406                	ld	s0,64(sp)
    800018ea:	74e2                	ld	s1,56(sp)
    800018ec:	7942                	ld	s2,48(sp)
    800018ee:	79a2                	ld	s3,40(sp)
    800018f0:	7a02                	ld	s4,32(sp)
    800018f2:	6ae2                	ld	s5,24(sp)
    800018f4:	6b42                	ld	s6,16(sp)
    800018f6:	6ba2                	ld	s7,8(sp)
    800018f8:	6161                	addi	sp,sp,80
    800018fa:	8082                	ret
  return 0;
    800018fc:	4501                	li	a0,0
}
    800018fe:	8082                	ret

0000000080001900 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001900:	1141                	addi	sp,sp,-16
    80001902:	e406                	sd	ra,8(sp)
    80001904:	e022                	sd	s0,0(sp)
    80001906:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001908:	4601                	li	a2,0
    8000190a:	00000097          	auipc	ra,0x0
    8000190e:	912080e7          	jalr	-1774(ra) # 8000121c <walk>
  if(pte == 0)
    80001912:	c901                	beqz	a0,80001922 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001914:	611c                	ld	a5,0(a0)
    80001916:	9bbd                	andi	a5,a5,-17
    80001918:	e11c                	sd	a5,0(a0)
}
    8000191a:	60a2                	ld	ra,8(sp)
    8000191c:	6402                	ld	s0,0(sp)
    8000191e:	0141                	addi	sp,sp,16
    80001920:	8082                	ret
    panic("uvmclear");
    80001922:	00007517          	auipc	a0,0x7
    80001926:	b3e50513          	addi	a0,a0,-1218 # 80008460 <userret+0x3d0>
    8000192a:	fffff097          	auipc	ra,0xfffff
    8000192e:	c1e080e7          	jalr	-994(ra) # 80000548 <panic>

0000000080001932 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001932:	c6bd                	beqz	a3,800019a0 <copyout+0x6e>
{
    80001934:	715d                	addi	sp,sp,-80
    80001936:	e486                	sd	ra,72(sp)
    80001938:	e0a2                	sd	s0,64(sp)
    8000193a:	fc26                	sd	s1,56(sp)
    8000193c:	f84a                	sd	s2,48(sp)
    8000193e:	f44e                	sd	s3,40(sp)
    80001940:	f052                	sd	s4,32(sp)
    80001942:	ec56                	sd	s5,24(sp)
    80001944:	e85a                	sd	s6,16(sp)
    80001946:	e45e                	sd	s7,8(sp)
    80001948:	e062                	sd	s8,0(sp)
    8000194a:	0880                	addi	s0,sp,80
    8000194c:	8b2a                	mv	s6,a0
    8000194e:	8c2e                	mv	s8,a1
    80001950:	8a32                	mv	s4,a2
    80001952:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001954:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001956:	6a85                	lui	s5,0x1
    80001958:	a015                	j	8000197c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000195a:	9562                	add	a0,a0,s8
    8000195c:	0004861b          	sext.w	a2,s1
    80001960:	85d2                	mv	a1,s4
    80001962:	41250533          	sub	a0,a0,s2
    80001966:	fffff097          	auipc	ra,0xfffff
    8000196a:	64c080e7          	jalr	1612(ra) # 80000fb2 <memmove>

    len -= n;
    8000196e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001972:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001974:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001978:	02098263          	beqz	s3,8000199c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000197c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001980:	85ca                	mv	a1,s2
    80001982:	855a                	mv	a0,s6
    80001984:	00000097          	auipc	ra,0x0
    80001988:	9cc080e7          	jalr	-1588(ra) # 80001350 <walkaddr>
    if(pa0 == 0)
    8000198c:	cd01                	beqz	a0,800019a4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000198e:	418904b3          	sub	s1,s2,s8
    80001992:	94d6                	add	s1,s1,s5
    if(n > len)
    80001994:	fc99f3e3          	bgeu	s3,s1,8000195a <copyout+0x28>
    80001998:	84ce                	mv	s1,s3
    8000199a:	b7c1                	j	8000195a <copyout+0x28>
  }
  return 0;
    8000199c:	4501                	li	a0,0
    8000199e:	a021                	j	800019a6 <copyout+0x74>
    800019a0:	4501                	li	a0,0
}
    800019a2:	8082                	ret
      return -1;
    800019a4:	557d                	li	a0,-1
}
    800019a6:	60a6                	ld	ra,72(sp)
    800019a8:	6406                	ld	s0,64(sp)
    800019aa:	74e2                	ld	s1,56(sp)
    800019ac:	7942                	ld	s2,48(sp)
    800019ae:	79a2                	ld	s3,40(sp)
    800019b0:	7a02                	ld	s4,32(sp)
    800019b2:	6ae2                	ld	s5,24(sp)
    800019b4:	6b42                	ld	s6,16(sp)
    800019b6:	6ba2                	ld	s7,8(sp)
    800019b8:	6c02                	ld	s8,0(sp)
    800019ba:	6161                	addi	sp,sp,80
    800019bc:	8082                	ret

00000000800019be <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800019be:	caa5                	beqz	a3,80001a2e <copyin+0x70>
{
    800019c0:	715d                	addi	sp,sp,-80
    800019c2:	e486                	sd	ra,72(sp)
    800019c4:	e0a2                	sd	s0,64(sp)
    800019c6:	fc26                	sd	s1,56(sp)
    800019c8:	f84a                	sd	s2,48(sp)
    800019ca:	f44e                	sd	s3,40(sp)
    800019cc:	f052                	sd	s4,32(sp)
    800019ce:	ec56                	sd	s5,24(sp)
    800019d0:	e85a                	sd	s6,16(sp)
    800019d2:	e45e                	sd	s7,8(sp)
    800019d4:	e062                	sd	s8,0(sp)
    800019d6:	0880                	addi	s0,sp,80
    800019d8:	8b2a                	mv	s6,a0
    800019da:	8a2e                	mv	s4,a1
    800019dc:	8c32                	mv	s8,a2
    800019de:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800019e0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800019e2:	6a85                	lui	s5,0x1
    800019e4:	a01d                	j	80001a0a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800019e6:	018505b3          	add	a1,a0,s8
    800019ea:	0004861b          	sext.w	a2,s1
    800019ee:	412585b3          	sub	a1,a1,s2
    800019f2:	8552                	mv	a0,s4
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	5be080e7          	jalr	1470(ra) # 80000fb2 <memmove>

    len -= n;
    800019fc:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001a00:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001a02:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001a06:	02098263          	beqz	s3,80001a2a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001a0a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001a0e:	85ca                	mv	a1,s2
    80001a10:	855a                	mv	a0,s6
    80001a12:	00000097          	auipc	ra,0x0
    80001a16:	93e080e7          	jalr	-1730(ra) # 80001350 <walkaddr>
    if(pa0 == 0)
    80001a1a:	cd01                	beqz	a0,80001a32 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001a1c:	418904b3          	sub	s1,s2,s8
    80001a20:	94d6                	add	s1,s1,s5
    if(n > len)
    80001a22:	fc99f2e3          	bgeu	s3,s1,800019e6 <copyin+0x28>
    80001a26:	84ce                	mv	s1,s3
    80001a28:	bf7d                	j	800019e6 <copyin+0x28>
  }
  return 0;
    80001a2a:	4501                	li	a0,0
    80001a2c:	a021                	j	80001a34 <copyin+0x76>
    80001a2e:	4501                	li	a0,0
}
    80001a30:	8082                	ret
      return -1;
    80001a32:	557d                	li	a0,-1
}
    80001a34:	60a6                	ld	ra,72(sp)
    80001a36:	6406                	ld	s0,64(sp)
    80001a38:	74e2                	ld	s1,56(sp)
    80001a3a:	7942                	ld	s2,48(sp)
    80001a3c:	79a2                	ld	s3,40(sp)
    80001a3e:	7a02                	ld	s4,32(sp)
    80001a40:	6ae2                	ld	s5,24(sp)
    80001a42:	6b42                	ld	s6,16(sp)
    80001a44:	6ba2                	ld	s7,8(sp)
    80001a46:	6c02                	ld	s8,0(sp)
    80001a48:	6161                	addi	sp,sp,80
    80001a4a:	8082                	ret

0000000080001a4c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001a4c:	c6c5                	beqz	a3,80001af4 <copyinstr+0xa8>
{
    80001a4e:	715d                	addi	sp,sp,-80
    80001a50:	e486                	sd	ra,72(sp)
    80001a52:	e0a2                	sd	s0,64(sp)
    80001a54:	fc26                	sd	s1,56(sp)
    80001a56:	f84a                	sd	s2,48(sp)
    80001a58:	f44e                	sd	s3,40(sp)
    80001a5a:	f052                	sd	s4,32(sp)
    80001a5c:	ec56                	sd	s5,24(sp)
    80001a5e:	e85a                	sd	s6,16(sp)
    80001a60:	e45e                	sd	s7,8(sp)
    80001a62:	0880                	addi	s0,sp,80
    80001a64:	8a2a                	mv	s4,a0
    80001a66:	8b2e                	mv	s6,a1
    80001a68:	8bb2                	mv	s7,a2
    80001a6a:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001a6c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a6e:	6985                	lui	s3,0x1
    80001a70:	a035                	j	80001a9c <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001a72:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001a76:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001a78:	0017b793          	seqz	a5,a5
    80001a7c:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001a80:	60a6                	ld	ra,72(sp)
    80001a82:	6406                	ld	s0,64(sp)
    80001a84:	74e2                	ld	s1,56(sp)
    80001a86:	7942                	ld	s2,48(sp)
    80001a88:	79a2                	ld	s3,40(sp)
    80001a8a:	7a02                	ld	s4,32(sp)
    80001a8c:	6ae2                	ld	s5,24(sp)
    80001a8e:	6b42                	ld	s6,16(sp)
    80001a90:	6ba2                	ld	s7,8(sp)
    80001a92:	6161                	addi	sp,sp,80
    80001a94:	8082                	ret
    srcva = va0 + PGSIZE;
    80001a96:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001a9a:	c8a9                	beqz	s1,80001aec <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001a9c:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001aa0:	85ca                	mv	a1,s2
    80001aa2:	8552                	mv	a0,s4
    80001aa4:	00000097          	auipc	ra,0x0
    80001aa8:	8ac080e7          	jalr	-1876(ra) # 80001350 <walkaddr>
    if(pa0 == 0)
    80001aac:	c131                	beqz	a0,80001af0 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001aae:	41790833          	sub	a6,s2,s7
    80001ab2:	984e                	add	a6,a6,s3
    if(n > max)
    80001ab4:	0104f363          	bgeu	s1,a6,80001aba <copyinstr+0x6e>
    80001ab8:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001aba:	955e                	add	a0,a0,s7
    80001abc:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001ac0:	fc080be3          	beqz	a6,80001a96 <copyinstr+0x4a>
    80001ac4:	985a                	add	a6,a6,s6
    80001ac6:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001ac8:	41650633          	sub	a2,a0,s6
    80001acc:	14fd                	addi	s1,s1,-1
    80001ace:	9b26                	add	s6,s6,s1
    80001ad0:	00f60733          	add	a4,a2,a5
    80001ad4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffcefa4>
    80001ad8:	df49                	beqz	a4,80001a72 <copyinstr+0x26>
        *dst = *p;
    80001ada:	00e78023          	sb	a4,0(a5)
      --max;
    80001ade:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001ae2:	0785                	addi	a5,a5,1
    while(n > 0){
    80001ae4:	ff0796e3          	bne	a5,a6,80001ad0 <copyinstr+0x84>
      dst++;
    80001ae8:	8b42                	mv	s6,a6
    80001aea:	b775                	j	80001a96 <copyinstr+0x4a>
    80001aec:	4781                	li	a5,0
    80001aee:	b769                	j	80001a78 <copyinstr+0x2c>
      return -1;
    80001af0:	557d                	li	a0,-1
    80001af2:	b779                	j	80001a80 <copyinstr+0x34>
  int got_null = 0;
    80001af4:	4781                	li	a5,0
  if(got_null){
    80001af6:	0017b793          	seqz	a5,a5
    80001afa:	40f00533          	neg	a0,a5
}
    80001afe:	8082                	ret

0000000080001b00 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001b00:	1101                	addi	sp,sp,-32
    80001b02:	ec06                	sd	ra,24(sp)
    80001b04:	e822                	sd	s0,16(sp)
    80001b06:	e426                	sd	s1,8(sp)
    80001b08:	1000                	addi	s0,sp,32
    80001b0a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	19c080e7          	jalr	412(ra) # 80000ca8 <holding>
    80001b14:	c909                	beqz	a0,80001b26 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001b16:	789c                	ld	a5,48(s1)
    80001b18:	00978f63          	beq	a5,s1,80001b36 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6105                	addi	sp,sp,32
    80001b24:	8082                	ret
    panic("wakeup1");
    80001b26:	00007517          	auipc	a0,0x7
    80001b2a:	94a50513          	addi	a0,a0,-1718 # 80008470 <userret+0x3e0>
    80001b2e:	fffff097          	auipc	ra,0xfffff
    80001b32:	a1a080e7          	jalr	-1510(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001b36:	5098                	lw	a4,32(s1)
    80001b38:	4785                	li	a5,1
    80001b3a:	fef711e3          	bne	a4,a5,80001b1c <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001b3e:	4789                	li	a5,2
    80001b40:	d09c                	sw	a5,32(s1)
}
    80001b42:	bfe9                	j	80001b1c <wakeup1+0x1c>

0000000080001b44 <procinit>:
{
    80001b44:	715d                	addi	sp,sp,-80
    80001b46:	e486                	sd	ra,72(sp)
    80001b48:	e0a2                	sd	s0,64(sp)
    80001b4a:	fc26                	sd	s1,56(sp)
    80001b4c:	f84a                	sd	s2,48(sp)
    80001b4e:	f44e                	sd	s3,40(sp)
    80001b50:	f052                	sd	s4,32(sp)
    80001b52:	ec56                	sd	s5,24(sp)
    80001b54:	e85a                	sd	s6,16(sp)
    80001b56:	e45e                	sd	s7,8(sp)
    80001b58:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001b5a:	00007597          	auipc	a1,0x7
    80001b5e:	91e58593          	addi	a1,a1,-1762 # 80008478 <userret+0x3e8>
    80001b62:	00013517          	auipc	a0,0x13
    80001b66:	e1e50513          	addi	a0,a0,-482 # 80014980 <pid_lock>
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	030080e7          	jalr	48(ra) # 80000b9a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b72:	00013917          	auipc	s2,0x13
    80001b76:	22e90913          	addi	s2,s2,558 # 80014da0 <proc>
      initlock(&p->lock, "proc");
    80001b7a:	00007b97          	auipc	s7,0x7
    80001b7e:	906b8b93          	addi	s7,s7,-1786 # 80008480 <userret+0x3f0>
      uint64 va = KSTACK((int) (p - proc));
    80001b82:	8b4a                	mv	s6,s2
    80001b84:	00007a97          	auipc	s5,0x7
    80001b88:	0b4a8a93          	addi	s5,s5,180 # 80008c38 <syscalls+0xb8>
    80001b8c:	040009b7          	lui	s3,0x4000
    80001b90:	19fd                	addi	s3,s3,-1
    80001b92:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b94:	00019a17          	auipc	s4,0x19
    80001b98:	e0ca0a13          	addi	s4,s4,-500 # 8001a9a0 <tickslock>
      initlock(&p->lock, "proc");
    80001b9c:	85de                	mv	a1,s7
    80001b9e:	854a                	mv	a0,s2
    80001ba0:	fffff097          	auipc	ra,0xfffff
    80001ba4:	ffa080e7          	jalr	-6(ra) # 80000b9a <initlock>
      char *pa = kalloc();
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	ef0080e7          	jalr	-272(ra) # 80000a98 <kalloc>
    80001bb0:	85aa                	mv	a1,a0
      if(pa == 0)
    80001bb2:	c929                	beqz	a0,80001c04 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001bb4:	416904b3          	sub	s1,s2,s6
    80001bb8:	8491                	srai	s1,s1,0x4
    80001bba:	000ab783          	ld	a5,0(s5)
    80001bbe:	02f484b3          	mul	s1,s1,a5
    80001bc2:	2485                	addiw	s1,s1,1
    80001bc4:	00d4949b          	slliw	s1,s1,0xd
    80001bc8:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001bcc:	4699                	li	a3,6
    80001bce:	6605                	lui	a2,0x1
    80001bd0:	8526                	mv	a0,s1
    80001bd2:	00000097          	auipc	ra,0x0
    80001bd6:	8ac080e7          	jalr	-1876(ra) # 8000147e <kvmmap>
      p->kstack = va;
    80001bda:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bde:	17090913          	addi	s2,s2,368
    80001be2:	fb491de3          	bne	s2,s4,80001b9c <procinit+0x58>
  kvminithart();
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	746080e7          	jalr	1862(ra) # 8000132c <kvminithart>
}
    80001bee:	60a6                	ld	ra,72(sp)
    80001bf0:	6406                	ld	s0,64(sp)
    80001bf2:	74e2                	ld	s1,56(sp)
    80001bf4:	7942                	ld	s2,48(sp)
    80001bf6:	79a2                	ld	s3,40(sp)
    80001bf8:	7a02                	ld	s4,32(sp)
    80001bfa:	6ae2                	ld	s5,24(sp)
    80001bfc:	6b42                	ld	s6,16(sp)
    80001bfe:	6ba2                	ld	s7,8(sp)
    80001c00:	6161                	addi	sp,sp,80
    80001c02:	8082                	ret
        panic("kalloc");
    80001c04:	00007517          	auipc	a0,0x7
    80001c08:	88450513          	addi	a0,a0,-1916 # 80008488 <userret+0x3f8>
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	93c080e7          	jalr	-1732(ra) # 80000548 <panic>

0000000080001c14 <cpuid>:
{
    80001c14:	1141                	addi	sp,sp,-16
    80001c16:	e422                	sd	s0,8(sp)
    80001c18:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c1a:	8512                	mv	a0,tp
}
    80001c1c:	2501                	sext.w	a0,a0
    80001c1e:	6422                	ld	s0,8(sp)
    80001c20:	0141                	addi	sp,sp,16
    80001c22:	8082                	ret

0000000080001c24 <mycpu>:
mycpu(void) {
    80001c24:	1141                	addi	sp,sp,-16
    80001c26:	e422                	sd	s0,8(sp)
    80001c28:	0800                	addi	s0,sp,16
    80001c2a:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001c2c:	2781                	sext.w	a5,a5
    80001c2e:	079e                	slli	a5,a5,0x7
}
    80001c30:	00013517          	auipc	a0,0x13
    80001c34:	d7050513          	addi	a0,a0,-656 # 800149a0 <cpus>
    80001c38:	953e                	add	a0,a0,a5
    80001c3a:	6422                	ld	s0,8(sp)
    80001c3c:	0141                	addi	sp,sp,16
    80001c3e:	8082                	ret

0000000080001c40 <myproc>:
myproc(void) {
    80001c40:	1101                	addi	sp,sp,-32
    80001c42:	ec06                	sd	ra,24(sp)
    80001c44:	e822                	sd	s0,16(sp)
    80001c46:	e426                	sd	s1,8(sp)
    80001c48:	1000                	addi	s0,sp,32
  push_off();
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	fa6080e7          	jalr	-90(ra) # 80000bf0 <push_off>
    80001c52:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001c54:	2781                	sext.w	a5,a5
    80001c56:	079e                	slli	a5,a5,0x7
    80001c58:	00013717          	auipc	a4,0x13
    80001c5c:	d2870713          	addi	a4,a4,-728 # 80014980 <pid_lock>
    80001c60:	97ba                	add	a5,a5,a4
    80001c62:	7384                	ld	s1,32(a5)
  pop_off();
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	fd8080e7          	jalr	-40(ra) # 80000c3c <pop_off>
}
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	60e2                	ld	ra,24(sp)
    80001c70:	6442                	ld	s0,16(sp)
    80001c72:	64a2                	ld	s1,8(sp)
    80001c74:	6105                	addi	sp,sp,32
    80001c76:	8082                	ret

0000000080001c78 <forkret>:
{
    80001c78:	1141                	addi	sp,sp,-16
    80001c7a:	e406                	sd	ra,8(sp)
    80001c7c:	e022                	sd	s0,0(sp)
    80001c7e:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001c80:	00000097          	auipc	ra,0x0
    80001c84:	fc0080e7          	jalr	-64(ra) # 80001c40 <myproc>
    80001c88:	fffff097          	auipc	ra,0xfffff
    80001c8c:	0d0080e7          	jalr	208(ra) # 80000d58 <release>
  if (first) {
    80001c90:	00007797          	auipc	a5,0x7
    80001c94:	3a47a783          	lw	a5,932(a5) # 80009034 <first.1>
    80001c98:	eb89                	bnez	a5,80001caa <forkret+0x32>
  usertrapret();
    80001c9a:	00001097          	auipc	ra,0x1
    80001c9e:	bda080e7          	jalr	-1062(ra) # 80002874 <usertrapret>
}
    80001ca2:	60a2                	ld	ra,8(sp)
    80001ca4:	6402                	ld	s0,0(sp)
    80001ca6:	0141                	addi	sp,sp,16
    80001ca8:	8082                	ret
    first = 0;
    80001caa:	00007797          	auipc	a5,0x7
    80001cae:	3807a523          	sw	zero,906(a5) # 80009034 <first.1>
    fsinit(minor(ROOTDEV));
    80001cb2:	4501                	li	a0,0
    80001cb4:	00002097          	auipc	ra,0x2
    80001cb8:	ab2080e7          	jalr	-1358(ra) # 80003766 <fsinit>
    80001cbc:	bff9                	j	80001c9a <forkret+0x22>

0000000080001cbe <allocpid>:
allocpid() {
    80001cbe:	1101                	addi	sp,sp,-32
    80001cc0:	ec06                	sd	ra,24(sp)
    80001cc2:	e822                	sd	s0,16(sp)
    80001cc4:	e426                	sd	s1,8(sp)
    80001cc6:	e04a                	sd	s2,0(sp)
    80001cc8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001cca:	00013917          	auipc	s2,0x13
    80001cce:	cb690913          	addi	s2,s2,-842 # 80014980 <pid_lock>
    80001cd2:	854a                	mv	a0,s2
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	014080e7          	jalr	20(ra) # 80000ce8 <acquire>
  pid = nextpid;
    80001cdc:	00007797          	auipc	a5,0x7
    80001ce0:	35c78793          	addi	a5,a5,860 # 80009038 <nextpid>
    80001ce4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ce6:	0014871b          	addiw	a4,s1,1
    80001cea:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001cec:	854a                	mv	a0,s2
    80001cee:	fffff097          	auipc	ra,0xfffff
    80001cf2:	06a080e7          	jalr	106(ra) # 80000d58 <release>
}
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	60e2                	ld	ra,24(sp)
    80001cfa:	6442                	ld	s0,16(sp)
    80001cfc:	64a2                	ld	s1,8(sp)
    80001cfe:	6902                	ld	s2,0(sp)
    80001d00:	6105                	addi	sp,sp,32
    80001d02:	8082                	ret

0000000080001d04 <proc_pagetable>:
{
    80001d04:	1101                	addi	sp,sp,-32
    80001d06:	ec06                	sd	ra,24(sp)
    80001d08:	e822                	sd	s0,16(sp)
    80001d0a:	e426                	sd	s1,8(sp)
    80001d0c:	e04a                	sd	s2,0(sp)
    80001d0e:	1000                	addi	s0,sp,32
    80001d10:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d12:	00000097          	auipc	ra,0x0
    80001d16:	952080e7          	jalr	-1710(ra) # 80001664 <uvmcreate>
    80001d1a:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d1c:	4729                	li	a4,10
    80001d1e:	00006697          	auipc	a3,0x6
    80001d22:	2e268693          	addi	a3,a3,738 # 80008000 <trampoline>
    80001d26:	6605                	lui	a2,0x1
    80001d28:	040005b7          	lui	a1,0x4000
    80001d2c:	15fd                	addi	a1,a1,-1
    80001d2e:	05b2                	slli	a1,a1,0xc
    80001d30:	fffff097          	auipc	ra,0xfffff
    80001d34:	6c0080e7          	jalr	1728(ra) # 800013f0 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d38:	4719                	li	a4,6
    80001d3a:	06093683          	ld	a3,96(s2)
    80001d3e:	6605                	lui	a2,0x1
    80001d40:	020005b7          	lui	a1,0x2000
    80001d44:	15fd                	addi	a1,a1,-1
    80001d46:	05b6                	slli	a1,a1,0xd
    80001d48:	8526                	mv	a0,s1
    80001d4a:	fffff097          	auipc	ra,0xfffff
    80001d4e:	6a6080e7          	jalr	1702(ra) # 800013f0 <mappages>
}
    80001d52:	8526                	mv	a0,s1
    80001d54:	60e2                	ld	ra,24(sp)
    80001d56:	6442                	ld	s0,16(sp)
    80001d58:	64a2                	ld	s1,8(sp)
    80001d5a:	6902                	ld	s2,0(sp)
    80001d5c:	6105                	addi	sp,sp,32
    80001d5e:	8082                	ret

0000000080001d60 <allocproc>:
{
    80001d60:	1101                	addi	sp,sp,-32
    80001d62:	ec06                	sd	ra,24(sp)
    80001d64:	e822                	sd	s0,16(sp)
    80001d66:	e426                	sd	s1,8(sp)
    80001d68:	e04a                	sd	s2,0(sp)
    80001d6a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d6c:	00013497          	auipc	s1,0x13
    80001d70:	03448493          	addi	s1,s1,52 # 80014da0 <proc>
    80001d74:	00019917          	auipc	s2,0x19
    80001d78:	c2c90913          	addi	s2,s2,-980 # 8001a9a0 <tickslock>
    acquire(&p->lock);
    80001d7c:	8526                	mv	a0,s1
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	f6a080e7          	jalr	-150(ra) # 80000ce8 <acquire>
    if(p->state == UNUSED) {
    80001d86:	509c                	lw	a5,32(s1)
    80001d88:	cf81                	beqz	a5,80001da0 <allocproc+0x40>
      release(&p->lock);
    80001d8a:	8526                	mv	a0,s1
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	fcc080e7          	jalr	-52(ra) # 80000d58 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d94:	17048493          	addi	s1,s1,368
    80001d98:	ff2492e3          	bne	s1,s2,80001d7c <allocproc+0x1c>
  return 0;
    80001d9c:	4481                	li	s1,0
    80001d9e:	a0a9                	j	80001de8 <allocproc+0x88>
  p->pid = allocpid();
    80001da0:	00000097          	auipc	ra,0x0
    80001da4:	f1e080e7          	jalr	-226(ra) # 80001cbe <allocpid>
    80001da8:	c0a8                	sw	a0,64(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001daa:	fffff097          	auipc	ra,0xfffff
    80001dae:	cee080e7          	jalr	-786(ra) # 80000a98 <kalloc>
    80001db2:	892a                	mv	s2,a0
    80001db4:	f0a8                	sd	a0,96(s1)
    80001db6:	c121                	beqz	a0,80001df6 <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001db8:	8526                	mv	a0,s1
    80001dba:	00000097          	auipc	ra,0x0
    80001dbe:	f4a080e7          	jalr	-182(ra) # 80001d04 <proc_pagetable>
    80001dc2:	eca8                	sd	a0,88(s1)
  memset(&p->context, 0, sizeof p->context);
    80001dc4:	07000613          	li	a2,112
    80001dc8:	4581                	li	a1,0
    80001dca:	06848513          	addi	a0,s1,104
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	188080e7          	jalr	392(ra) # 80000f56 <memset>
  p->context.ra = (uint64)forkret;
    80001dd6:	00000797          	auipc	a5,0x0
    80001dda:	ea278793          	addi	a5,a5,-350 # 80001c78 <forkret>
    80001dde:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001de0:	64bc                	ld	a5,72(s1)
    80001de2:	6705                	lui	a4,0x1
    80001de4:	97ba                	add	a5,a5,a4
    80001de6:	f8bc                	sd	a5,112(s1)
}
    80001de8:	8526                	mv	a0,s1
    80001dea:	60e2                	ld	ra,24(sp)
    80001dec:	6442                	ld	s0,16(sp)
    80001dee:	64a2                	ld	s1,8(sp)
    80001df0:	6902                	ld	s2,0(sp)
    80001df2:	6105                	addi	sp,sp,32
    80001df4:	8082                	ret
    release(&p->lock);
    80001df6:	8526                	mv	a0,s1
    80001df8:	fffff097          	auipc	ra,0xfffff
    80001dfc:	f60080e7          	jalr	-160(ra) # 80000d58 <release>
    return 0;
    80001e00:	84ca                	mv	s1,s2
    80001e02:	b7dd                	j	80001de8 <allocproc+0x88>

0000000080001e04 <proc_freepagetable>:
{
    80001e04:	1101                	addi	sp,sp,-32
    80001e06:	ec06                	sd	ra,24(sp)
    80001e08:	e822                	sd	s0,16(sp)
    80001e0a:	e426                	sd	s1,8(sp)
    80001e0c:	e04a                	sd	s2,0(sp)
    80001e0e:	1000                	addi	s0,sp,32
    80001e10:	84aa                	mv	s1,a0
    80001e12:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001e14:	4681                	li	a3,0
    80001e16:	6605                	lui	a2,0x1
    80001e18:	040005b7          	lui	a1,0x4000
    80001e1c:	15fd                	addi	a1,a1,-1
    80001e1e:	05b2                	slli	a1,a1,0xc
    80001e20:	fffff097          	auipc	ra,0xfffff
    80001e24:	77c080e7          	jalr	1916(ra) # 8000159c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001e28:	4681                	li	a3,0
    80001e2a:	6605                	lui	a2,0x1
    80001e2c:	020005b7          	lui	a1,0x2000
    80001e30:	15fd                	addi	a1,a1,-1
    80001e32:	05b6                	slli	a1,a1,0xd
    80001e34:	8526                	mv	a0,s1
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	766080e7          	jalr	1894(ra) # 8000159c <uvmunmap>
  if(sz > 0)
    80001e3e:	00091863          	bnez	s2,80001e4e <proc_freepagetable+0x4a>
}
    80001e42:	60e2                	ld	ra,24(sp)
    80001e44:	6442                	ld	s0,16(sp)
    80001e46:	64a2                	ld	s1,8(sp)
    80001e48:	6902                	ld	s2,0(sp)
    80001e4a:	6105                	addi	sp,sp,32
    80001e4c:	8082                	ret
    uvmfree(pagetable, sz);
    80001e4e:	85ca                	mv	a1,s2
    80001e50:	8526                	mv	a0,s1
    80001e52:	00000097          	auipc	ra,0x0
    80001e56:	9b0080e7          	jalr	-1616(ra) # 80001802 <uvmfree>
}
    80001e5a:	b7e5                	j	80001e42 <proc_freepagetable+0x3e>

0000000080001e5c <freeproc>:
{
    80001e5c:	1101                	addi	sp,sp,-32
    80001e5e:	ec06                	sd	ra,24(sp)
    80001e60:	e822                	sd	s0,16(sp)
    80001e62:	e426                	sd	s1,8(sp)
    80001e64:	1000                	addi	s0,sp,32
    80001e66:	84aa                	mv	s1,a0
  if(p->tf)
    80001e68:	7128                	ld	a0,96(a0)
    80001e6a:	c509                	beqz	a0,80001e74 <freeproc+0x18>
    kfree((void*)p->tf);
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	aa4080e7          	jalr	-1372(ra) # 80000910 <kfree>
  p->tf = 0;
    80001e74:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001e78:	6ca8                	ld	a0,88(s1)
    80001e7a:	c511                	beqz	a0,80001e86 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001e7c:	68ac                	ld	a1,80(s1)
    80001e7e:	00000097          	auipc	ra,0x0
    80001e82:	f86080e7          	jalr	-122(ra) # 80001e04 <proc_freepagetable>
  p->pagetable = 0;
    80001e86:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001e8a:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001e8e:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001e92:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001e96:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001e9a:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001e9e:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001ea2:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001ea6:	0204a023          	sw	zero,32(s1)
}
    80001eaa:	60e2                	ld	ra,24(sp)
    80001eac:	6442                	ld	s0,16(sp)
    80001eae:	64a2                	ld	s1,8(sp)
    80001eb0:	6105                	addi	sp,sp,32
    80001eb2:	8082                	ret

0000000080001eb4 <userinit>:
{
    80001eb4:	1101                	addi	sp,sp,-32
    80001eb6:	ec06                	sd	ra,24(sp)
    80001eb8:	e822                	sd	s0,16(sp)
    80001eba:	e426                	sd	s1,8(sp)
    80001ebc:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ebe:	00000097          	auipc	ra,0x0
    80001ec2:	ea2080e7          	jalr	-350(ra) # 80001d60 <allocproc>
    80001ec6:	84aa                	mv	s1,a0
  initproc = p;
    80001ec8:	0002e797          	auipc	a5,0x2e
    80001ecc:	16a7b823          	sd	a0,368(a5) # 80030038 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001ed0:	03300613          	li	a2,51
    80001ed4:	00007597          	auipc	a1,0x7
    80001ed8:	12c58593          	addi	a1,a1,300 # 80009000 <initcode>
    80001edc:	6d28                	ld	a0,88(a0)
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	7c4080e7          	jalr	1988(ra) # 800016a2 <uvminit>
  p->sz = PGSIZE;
    80001ee6:	6785                	lui	a5,0x1
    80001ee8:	e8bc                	sd	a5,80(s1)
  p->tf->epc = 0;      // user program counter
    80001eea:	70b8                	ld	a4,96(s1)
    80001eec:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001ef0:	70b8                	ld	a4,96(s1)
    80001ef2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ef4:	4641                	li	a2,16
    80001ef6:	00006597          	auipc	a1,0x6
    80001efa:	59a58593          	addi	a1,a1,1434 # 80008490 <userret+0x400>
    80001efe:	16048513          	addi	a0,s1,352
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	1a6080e7          	jalr	422(ra) # 800010a8 <safestrcpy>
  p->cwd = namei("/");
    80001f0a:	00006517          	auipc	a0,0x6
    80001f0e:	59650513          	addi	a0,a0,1430 # 800084a0 <userret+0x410>
    80001f12:	00002097          	auipc	ra,0x2
    80001f16:	256080e7          	jalr	598(ra) # 80004168 <namei>
    80001f1a:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001f1e:	4789                	li	a5,2
    80001f20:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001f22:	8526                	mv	a0,s1
    80001f24:	fffff097          	auipc	ra,0xfffff
    80001f28:	e34080e7          	jalr	-460(ra) # 80000d58 <release>
}
    80001f2c:	60e2                	ld	ra,24(sp)
    80001f2e:	6442                	ld	s0,16(sp)
    80001f30:	64a2                	ld	s1,8(sp)
    80001f32:	6105                	addi	sp,sp,32
    80001f34:	8082                	ret

0000000080001f36 <growproc>:
{
    80001f36:	1101                	addi	sp,sp,-32
    80001f38:	ec06                	sd	ra,24(sp)
    80001f3a:	e822                	sd	s0,16(sp)
    80001f3c:	e426                	sd	s1,8(sp)
    80001f3e:	e04a                	sd	s2,0(sp)
    80001f40:	1000                	addi	s0,sp,32
    80001f42:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f44:	00000097          	auipc	ra,0x0
    80001f48:	cfc080e7          	jalr	-772(ra) # 80001c40 <myproc>
    80001f4c:	892a                	mv	s2,a0
  sz = p->sz;
    80001f4e:	692c                	ld	a1,80(a0)
    80001f50:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001f54:	00904f63          	bgtz	s1,80001f72 <growproc+0x3c>
  } else if(n < 0){
    80001f58:	0204cc63          	bltz	s1,80001f90 <growproc+0x5a>
  p->sz = sz;
    80001f5c:	1602                	slli	a2,a2,0x20
    80001f5e:	9201                	srli	a2,a2,0x20
    80001f60:	04c93823          	sd	a2,80(s2)
  return 0;
    80001f64:	4501                	li	a0,0
}
    80001f66:	60e2                	ld	ra,24(sp)
    80001f68:	6442                	ld	s0,16(sp)
    80001f6a:	64a2                	ld	s1,8(sp)
    80001f6c:	6902                	ld	s2,0(sp)
    80001f6e:	6105                	addi	sp,sp,32
    80001f70:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001f72:	9e25                	addw	a2,a2,s1
    80001f74:	1602                	slli	a2,a2,0x20
    80001f76:	9201                	srli	a2,a2,0x20
    80001f78:	1582                	slli	a1,a1,0x20
    80001f7a:	9181                	srli	a1,a1,0x20
    80001f7c:	6d28                	ld	a0,88(a0)
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	7da080e7          	jalr	2010(ra) # 80001758 <uvmalloc>
    80001f86:	0005061b          	sext.w	a2,a0
    80001f8a:	fa69                	bnez	a2,80001f5c <growproc+0x26>
      return -1;
    80001f8c:	557d                	li	a0,-1
    80001f8e:	bfe1                	j	80001f66 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f90:	9e25                	addw	a2,a2,s1
    80001f92:	1602                	slli	a2,a2,0x20
    80001f94:	9201                	srli	a2,a2,0x20
    80001f96:	1582                	slli	a1,a1,0x20
    80001f98:	9181                	srli	a1,a1,0x20
    80001f9a:	6d28                	ld	a0,88(a0)
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	778080e7          	jalr	1912(ra) # 80001714 <uvmdealloc>
    80001fa4:	0005061b          	sext.w	a2,a0
    80001fa8:	bf55                	j	80001f5c <growproc+0x26>

0000000080001faa <fork>:
{
    80001faa:	7139                	addi	sp,sp,-64
    80001fac:	fc06                	sd	ra,56(sp)
    80001fae:	f822                	sd	s0,48(sp)
    80001fb0:	f426                	sd	s1,40(sp)
    80001fb2:	f04a                	sd	s2,32(sp)
    80001fb4:	ec4e                	sd	s3,24(sp)
    80001fb6:	e852                	sd	s4,16(sp)
    80001fb8:	e456                	sd	s5,8(sp)
    80001fba:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001fbc:	00000097          	auipc	ra,0x0
    80001fc0:	c84080e7          	jalr	-892(ra) # 80001c40 <myproc>
    80001fc4:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001fc6:	00000097          	auipc	ra,0x0
    80001fca:	d9a080e7          	jalr	-614(ra) # 80001d60 <allocproc>
    80001fce:	c17d                	beqz	a0,800020b4 <fork+0x10a>
    80001fd0:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001fd2:	050ab603          	ld	a2,80(s5)
    80001fd6:	6d2c                	ld	a1,88(a0)
    80001fd8:	058ab503          	ld	a0,88(s5)
    80001fdc:	00000097          	auipc	ra,0x0
    80001fe0:	854080e7          	jalr	-1964(ra) # 80001830 <uvmcopy>
    80001fe4:	04054a63          	bltz	a0,80002038 <fork+0x8e>
  np->sz = p->sz;
    80001fe8:	050ab783          	ld	a5,80(s5)
    80001fec:	04fa3823          	sd	a5,80(s4)
  np->parent = p;
    80001ff0:	035a3423          	sd	s5,40(s4)
  *(np->tf) = *(p->tf);
    80001ff4:	060ab683          	ld	a3,96(s5)
    80001ff8:	87b6                	mv	a5,a3
    80001ffa:	060a3703          	ld	a4,96(s4)
    80001ffe:	12068693          	addi	a3,a3,288
    80002002:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002006:	6788                	ld	a0,8(a5)
    80002008:	6b8c                	ld	a1,16(a5)
    8000200a:	6f90                	ld	a2,24(a5)
    8000200c:	01073023          	sd	a6,0(a4)
    80002010:	e708                	sd	a0,8(a4)
    80002012:	eb0c                	sd	a1,16(a4)
    80002014:	ef10                	sd	a2,24(a4)
    80002016:	02078793          	addi	a5,a5,32
    8000201a:	02070713          	addi	a4,a4,32
    8000201e:	fed792e3          	bne	a5,a3,80002002 <fork+0x58>
  np->tf->a0 = 0;
    80002022:	060a3783          	ld	a5,96(s4)
    80002026:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    8000202a:	0d8a8493          	addi	s1,s5,216
    8000202e:	0d8a0913          	addi	s2,s4,216
    80002032:	158a8993          	addi	s3,s5,344
    80002036:	a00d                	j	80002058 <fork+0xae>
    freeproc(np);
    80002038:	8552                	mv	a0,s4
    8000203a:	00000097          	auipc	ra,0x0
    8000203e:	e22080e7          	jalr	-478(ra) # 80001e5c <freeproc>
    release(&np->lock);
    80002042:	8552                	mv	a0,s4
    80002044:	fffff097          	auipc	ra,0xfffff
    80002048:	d14080e7          	jalr	-748(ra) # 80000d58 <release>
    return -1;
    8000204c:	54fd                	li	s1,-1
    8000204e:	a889                	j	800020a0 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80002050:	04a1                	addi	s1,s1,8
    80002052:	0921                	addi	s2,s2,8
    80002054:	01348b63          	beq	s1,s3,8000206a <fork+0xc0>
    if(p->ofile[i])
    80002058:	6088                	ld	a0,0(s1)
    8000205a:	d97d                	beqz	a0,80002050 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    8000205c:	00003097          	auipc	ra,0x3
    80002060:	8ae080e7          	jalr	-1874(ra) # 8000490a <filedup>
    80002064:	00a93023          	sd	a0,0(s2)
    80002068:	b7e5                	j	80002050 <fork+0xa6>
  np->cwd = idup(p->cwd);
    8000206a:	158ab503          	ld	a0,344(s5)
    8000206e:	00002097          	auipc	ra,0x2
    80002072:	932080e7          	jalr	-1742(ra) # 800039a0 <idup>
    80002076:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000207a:	4641                	li	a2,16
    8000207c:	160a8593          	addi	a1,s5,352
    80002080:	160a0513          	addi	a0,s4,352
    80002084:	fffff097          	auipc	ra,0xfffff
    80002088:	024080e7          	jalr	36(ra) # 800010a8 <safestrcpy>
  pid = np->pid;
    8000208c:	040a2483          	lw	s1,64(s4)
  np->state = RUNNABLE;
    80002090:	4789                	li	a5,2
    80002092:	02fa2023          	sw	a5,32(s4)
  release(&np->lock);
    80002096:	8552                	mv	a0,s4
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	cc0080e7          	jalr	-832(ra) # 80000d58 <release>
}
    800020a0:	8526                	mv	a0,s1
    800020a2:	70e2                	ld	ra,56(sp)
    800020a4:	7442                	ld	s0,48(sp)
    800020a6:	74a2                	ld	s1,40(sp)
    800020a8:	7902                	ld	s2,32(sp)
    800020aa:	69e2                	ld	s3,24(sp)
    800020ac:	6a42                	ld	s4,16(sp)
    800020ae:	6aa2                	ld	s5,8(sp)
    800020b0:	6121                	addi	sp,sp,64
    800020b2:	8082                	ret
    return -1;
    800020b4:	54fd                	li	s1,-1
    800020b6:	b7ed                	j	800020a0 <fork+0xf6>

00000000800020b8 <reparent>:
{
    800020b8:	7179                	addi	sp,sp,-48
    800020ba:	f406                	sd	ra,40(sp)
    800020bc:	f022                	sd	s0,32(sp)
    800020be:	ec26                	sd	s1,24(sp)
    800020c0:	e84a                	sd	s2,16(sp)
    800020c2:	e44e                	sd	s3,8(sp)
    800020c4:	e052                	sd	s4,0(sp)
    800020c6:	1800                	addi	s0,sp,48
    800020c8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800020ca:	00013497          	auipc	s1,0x13
    800020ce:	cd648493          	addi	s1,s1,-810 # 80014da0 <proc>
      pp->parent = initproc;
    800020d2:	0002ea17          	auipc	s4,0x2e
    800020d6:	f66a0a13          	addi	s4,s4,-154 # 80030038 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800020da:	00019997          	auipc	s3,0x19
    800020de:	8c698993          	addi	s3,s3,-1850 # 8001a9a0 <tickslock>
    800020e2:	a029                	j	800020ec <reparent+0x34>
    800020e4:	17048493          	addi	s1,s1,368
    800020e8:	03348363          	beq	s1,s3,8000210e <reparent+0x56>
    if(pp->parent == p){
    800020ec:	749c                	ld	a5,40(s1)
    800020ee:	ff279be3          	bne	a5,s2,800020e4 <reparent+0x2c>
      acquire(&pp->lock);
    800020f2:	8526                	mv	a0,s1
    800020f4:	fffff097          	auipc	ra,0xfffff
    800020f8:	bf4080e7          	jalr	-1036(ra) # 80000ce8 <acquire>
      pp->parent = initproc;
    800020fc:	000a3783          	ld	a5,0(s4)
    80002100:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80002102:	8526                	mv	a0,s1
    80002104:	fffff097          	auipc	ra,0xfffff
    80002108:	c54080e7          	jalr	-940(ra) # 80000d58 <release>
    8000210c:	bfe1                	j	800020e4 <reparent+0x2c>
}
    8000210e:	70a2                	ld	ra,40(sp)
    80002110:	7402                	ld	s0,32(sp)
    80002112:	64e2                	ld	s1,24(sp)
    80002114:	6942                	ld	s2,16(sp)
    80002116:	69a2                	ld	s3,8(sp)
    80002118:	6a02                	ld	s4,0(sp)
    8000211a:	6145                	addi	sp,sp,48
    8000211c:	8082                	ret

000000008000211e <scheduler>:
{
    8000211e:	715d                	addi	sp,sp,-80
    80002120:	e486                	sd	ra,72(sp)
    80002122:	e0a2                	sd	s0,64(sp)
    80002124:	fc26                	sd	s1,56(sp)
    80002126:	f84a                	sd	s2,48(sp)
    80002128:	f44e                	sd	s3,40(sp)
    8000212a:	f052                	sd	s4,32(sp)
    8000212c:	ec56                	sd	s5,24(sp)
    8000212e:	e85a                	sd	s6,16(sp)
    80002130:	e45e                	sd	s7,8(sp)
    80002132:	e062                	sd	s8,0(sp)
    80002134:	0880                	addi	s0,sp,80
    80002136:	8792                	mv	a5,tp
  int id = r_tp();
    80002138:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000213a:	00779b13          	slli	s6,a5,0x7
    8000213e:	00013717          	auipc	a4,0x13
    80002142:	84270713          	addi	a4,a4,-1982 # 80014980 <pid_lock>
    80002146:	975a                	add	a4,a4,s6
    80002148:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    8000214c:	00013717          	auipc	a4,0x13
    80002150:	85c70713          	addi	a4,a4,-1956 # 800149a8 <cpus+0x8>
    80002154:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80002156:	4c0d                	li	s8,3
        c->proc = p;
    80002158:	079e                	slli	a5,a5,0x7
    8000215a:	00013a17          	auipc	s4,0x13
    8000215e:	826a0a13          	addi	s4,s4,-2010 # 80014980 <pid_lock>
    80002162:	9a3e                	add	s4,s4,a5
        found = 1;
    80002164:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80002166:	00019997          	auipc	s3,0x19
    8000216a:	83a98993          	addi	s3,s3,-1990 # 8001a9a0 <tickslock>
    8000216e:	a08d                	j	800021d0 <scheduler+0xb2>
      release(&p->lock);
    80002170:	8526                	mv	a0,s1
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	be6080e7          	jalr	-1050(ra) # 80000d58 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000217a:	17048493          	addi	s1,s1,368
    8000217e:	03348963          	beq	s1,s3,800021b0 <scheduler+0x92>
      acquire(&p->lock);
    80002182:	8526                	mv	a0,s1
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	b64080e7          	jalr	-1180(ra) # 80000ce8 <acquire>
      if(p->state == RUNNABLE) {
    8000218c:	509c                	lw	a5,32(s1)
    8000218e:	ff2791e3          	bne	a5,s2,80002170 <scheduler+0x52>
        p->state = RUNNING;
    80002192:	0384a023          	sw	s8,32(s1)
        c->proc = p;
    80002196:	029a3023          	sd	s1,32(s4)
        swtch(&c->scheduler, &p->context);
    8000219a:	06848593          	addi	a1,s1,104
    8000219e:	855a                	mv	a0,s6
    800021a0:	00000097          	auipc	ra,0x0
    800021a4:	62a080e7          	jalr	1578(ra) # 800027ca <swtch>
        c->proc = 0;
    800021a8:	020a3023          	sd	zero,32(s4)
        found = 1;
    800021ac:	8ade                	mv	s5,s7
    800021ae:	b7c9                	j	80002170 <scheduler+0x52>
    if(found == 0){
    800021b0:	020a9063          	bnez	s5,800021d0 <scheduler+0xb2>
  asm volatile("csrr %0, sie" : "=r" (x) );
    800021b4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800021b8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800021bc:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021c0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800021c4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800021c8:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800021cc:	10500073          	wfi
  asm volatile("csrr %0, sie" : "=r" (x) );
    800021d0:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800021d4:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800021d8:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021dc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800021e0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800021e4:	10079073          	csrw	sstatus,a5
    int found = 0;
    800021e8:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800021ea:	00013497          	auipc	s1,0x13
    800021ee:	bb648493          	addi	s1,s1,-1098 # 80014da0 <proc>
      if(p->state == RUNNABLE) {
    800021f2:	4909                	li	s2,2
    800021f4:	b779                	j	80002182 <scheduler+0x64>

00000000800021f6 <sched>:
{
    800021f6:	7179                	addi	sp,sp,-48
    800021f8:	f406                	sd	ra,40(sp)
    800021fa:	f022                	sd	s0,32(sp)
    800021fc:	ec26                	sd	s1,24(sp)
    800021fe:	e84a                	sd	s2,16(sp)
    80002200:	e44e                	sd	s3,8(sp)
    80002202:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002204:	00000097          	auipc	ra,0x0
    80002208:	a3c080e7          	jalr	-1476(ra) # 80001c40 <myproc>
    8000220c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000220e:	fffff097          	auipc	ra,0xfffff
    80002212:	a9a080e7          	jalr	-1382(ra) # 80000ca8 <holding>
    80002216:	c93d                	beqz	a0,8000228c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002218:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000221a:	2781                	sext.w	a5,a5
    8000221c:	079e                	slli	a5,a5,0x7
    8000221e:	00012717          	auipc	a4,0x12
    80002222:	76270713          	addi	a4,a4,1890 # 80014980 <pid_lock>
    80002226:	97ba                	add	a5,a5,a4
    80002228:	0987a703          	lw	a4,152(a5)
    8000222c:	4785                	li	a5,1
    8000222e:	06f71763          	bne	a4,a5,8000229c <sched+0xa6>
  if(p->state == RUNNING)
    80002232:	5098                	lw	a4,32(s1)
    80002234:	478d                	li	a5,3
    80002236:	06f70b63          	beq	a4,a5,800022ac <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000223a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000223e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002240:	efb5                	bnez	a5,800022bc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002242:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002244:	00012917          	auipc	s2,0x12
    80002248:	73c90913          	addi	s2,s2,1852 # 80014980 <pid_lock>
    8000224c:	2781                	sext.w	a5,a5
    8000224e:	079e                	slli	a5,a5,0x7
    80002250:	97ca                	add	a5,a5,s2
    80002252:	09c7a983          	lw	s3,156(a5)
    80002256:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80002258:	2781                	sext.w	a5,a5
    8000225a:	079e                	slli	a5,a5,0x7
    8000225c:	00012597          	auipc	a1,0x12
    80002260:	74c58593          	addi	a1,a1,1868 # 800149a8 <cpus+0x8>
    80002264:	95be                	add	a1,a1,a5
    80002266:	06848513          	addi	a0,s1,104
    8000226a:	00000097          	auipc	ra,0x0
    8000226e:	560080e7          	jalr	1376(ra) # 800027ca <swtch>
    80002272:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002274:	2781                	sext.w	a5,a5
    80002276:	079e                	slli	a5,a5,0x7
    80002278:	97ca                	add	a5,a5,s2
    8000227a:	0937ae23          	sw	s3,156(a5)
}
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6145                	addi	sp,sp,48
    8000228a:	8082                	ret
    panic("sched p->lock");
    8000228c:	00006517          	auipc	a0,0x6
    80002290:	21c50513          	addi	a0,a0,540 # 800084a8 <userret+0x418>
    80002294:	ffffe097          	auipc	ra,0xffffe
    80002298:	2b4080e7          	jalr	692(ra) # 80000548 <panic>
    panic("sched locks");
    8000229c:	00006517          	auipc	a0,0x6
    800022a0:	21c50513          	addi	a0,a0,540 # 800084b8 <userret+0x428>
    800022a4:	ffffe097          	auipc	ra,0xffffe
    800022a8:	2a4080e7          	jalr	676(ra) # 80000548 <panic>
    panic("sched running");
    800022ac:	00006517          	auipc	a0,0x6
    800022b0:	21c50513          	addi	a0,a0,540 # 800084c8 <userret+0x438>
    800022b4:	ffffe097          	auipc	ra,0xffffe
    800022b8:	294080e7          	jalr	660(ra) # 80000548 <panic>
    panic("sched interruptible");
    800022bc:	00006517          	auipc	a0,0x6
    800022c0:	21c50513          	addi	a0,a0,540 # 800084d8 <userret+0x448>
    800022c4:	ffffe097          	auipc	ra,0xffffe
    800022c8:	284080e7          	jalr	644(ra) # 80000548 <panic>

00000000800022cc <exit>:
{
    800022cc:	7179                	addi	sp,sp,-48
    800022ce:	f406                	sd	ra,40(sp)
    800022d0:	f022                	sd	s0,32(sp)
    800022d2:	ec26                	sd	s1,24(sp)
    800022d4:	e84a                	sd	s2,16(sp)
    800022d6:	e44e                	sd	s3,8(sp)
    800022d8:	e052                	sd	s4,0(sp)
    800022da:	1800                	addi	s0,sp,48
    800022dc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022de:	00000097          	auipc	ra,0x0
    800022e2:	962080e7          	jalr	-1694(ra) # 80001c40 <myproc>
    800022e6:	89aa                	mv	s3,a0
  if(p == initproc)
    800022e8:	0002e797          	auipc	a5,0x2e
    800022ec:	d507b783          	ld	a5,-688(a5) # 80030038 <initproc>
    800022f0:	0d850493          	addi	s1,a0,216
    800022f4:	15850913          	addi	s2,a0,344
    800022f8:	02a79363          	bne	a5,a0,8000231e <exit+0x52>
    panic("init exiting");
    800022fc:	00006517          	auipc	a0,0x6
    80002300:	1f450513          	addi	a0,a0,500 # 800084f0 <userret+0x460>
    80002304:	ffffe097          	auipc	ra,0xffffe
    80002308:	244080e7          	jalr	580(ra) # 80000548 <panic>
      fileclose(f);
    8000230c:	00002097          	auipc	ra,0x2
    80002310:	650080e7          	jalr	1616(ra) # 8000495c <fileclose>
      p->ofile[fd] = 0;
    80002314:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002318:	04a1                	addi	s1,s1,8
    8000231a:	01248563          	beq	s1,s2,80002324 <exit+0x58>
    if(p->ofile[fd]){
    8000231e:	6088                	ld	a0,0(s1)
    80002320:	f575                	bnez	a0,8000230c <exit+0x40>
    80002322:	bfdd                	j	80002318 <exit+0x4c>
  begin_op(ROOTDEV);
    80002324:	4501                	li	a0,0
    80002326:	00002097          	auipc	ra,0x2
    8000232a:	09c080e7          	jalr	156(ra) # 800043c2 <begin_op>
  iput(p->cwd);
    8000232e:	1589b503          	ld	a0,344(s3)
    80002332:	00001097          	auipc	ra,0x1
    80002336:	7ba080e7          	jalr	1978(ra) # 80003aec <iput>
  end_op(ROOTDEV);
    8000233a:	4501                	li	a0,0
    8000233c:	00002097          	auipc	ra,0x2
    80002340:	130080e7          	jalr	304(ra) # 8000446c <end_op>
  p->cwd = 0;
    80002344:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    80002348:	0002e497          	auipc	s1,0x2e
    8000234c:	cf048493          	addi	s1,s1,-784 # 80030038 <initproc>
    80002350:	6088                	ld	a0,0(s1)
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	996080e7          	jalr	-1642(ra) # 80000ce8 <acquire>
  wakeup1(initproc);
    8000235a:	6088                	ld	a0,0(s1)
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	7a4080e7          	jalr	1956(ra) # 80001b00 <wakeup1>
  release(&initproc->lock);
    80002364:	6088                	ld	a0,0(s1)
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	9f2080e7          	jalr	-1550(ra) # 80000d58 <release>
  acquire(&p->lock);
    8000236e:	854e                	mv	a0,s3
    80002370:	fffff097          	auipc	ra,0xfffff
    80002374:	978080e7          	jalr	-1672(ra) # 80000ce8 <acquire>
  struct proc *original_parent = p->parent;
    80002378:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    8000237c:	854e                	mv	a0,s3
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	9da080e7          	jalr	-1574(ra) # 80000d58 <release>
  acquire(&original_parent->lock);
    80002386:	8526                	mv	a0,s1
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	960080e7          	jalr	-1696(ra) # 80000ce8 <acquire>
  acquire(&p->lock);
    80002390:	854e                	mv	a0,s3
    80002392:	fffff097          	auipc	ra,0xfffff
    80002396:	956080e7          	jalr	-1706(ra) # 80000ce8 <acquire>
  reparent(p);
    8000239a:	854e                	mv	a0,s3
    8000239c:	00000097          	auipc	ra,0x0
    800023a0:	d1c080e7          	jalr	-740(ra) # 800020b8 <reparent>
  wakeup1(original_parent);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	75a080e7          	jalr	1882(ra) # 80001b00 <wakeup1>
  p->xstate = status;
    800023ae:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800023b2:	4791                	li	a5,4
    800023b4:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800023b8:	8526                	mv	a0,s1
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	99e080e7          	jalr	-1634(ra) # 80000d58 <release>
  sched();
    800023c2:	00000097          	auipc	ra,0x0
    800023c6:	e34080e7          	jalr	-460(ra) # 800021f6 <sched>
  panic("zombie exit");
    800023ca:	00006517          	auipc	a0,0x6
    800023ce:	13650513          	addi	a0,a0,310 # 80008500 <userret+0x470>
    800023d2:	ffffe097          	auipc	ra,0xffffe
    800023d6:	176080e7          	jalr	374(ra) # 80000548 <panic>

00000000800023da <yield>:
{
    800023da:	1101                	addi	sp,sp,-32
    800023dc:	ec06                	sd	ra,24(sp)
    800023de:	e822                	sd	s0,16(sp)
    800023e0:	e426                	sd	s1,8(sp)
    800023e2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800023e4:	00000097          	auipc	ra,0x0
    800023e8:	85c080e7          	jalr	-1956(ra) # 80001c40 <myproc>
    800023ec:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	8fa080e7          	jalr	-1798(ra) # 80000ce8 <acquire>
  p->state = RUNNABLE;
    800023f6:	4789                	li	a5,2
    800023f8:	d09c                	sw	a5,32(s1)
  sched();
    800023fa:	00000097          	auipc	ra,0x0
    800023fe:	dfc080e7          	jalr	-516(ra) # 800021f6 <sched>
  release(&p->lock);
    80002402:	8526                	mv	a0,s1
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	954080e7          	jalr	-1708(ra) # 80000d58 <release>
}
    8000240c:	60e2                	ld	ra,24(sp)
    8000240e:	6442                	ld	s0,16(sp)
    80002410:	64a2                	ld	s1,8(sp)
    80002412:	6105                	addi	sp,sp,32
    80002414:	8082                	ret

0000000080002416 <sleep>:
{
    80002416:	7179                	addi	sp,sp,-48
    80002418:	f406                	sd	ra,40(sp)
    8000241a:	f022                	sd	s0,32(sp)
    8000241c:	ec26                	sd	s1,24(sp)
    8000241e:	e84a                	sd	s2,16(sp)
    80002420:	e44e                	sd	s3,8(sp)
    80002422:	1800                	addi	s0,sp,48
    80002424:	89aa                	mv	s3,a0
    80002426:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002428:	00000097          	auipc	ra,0x0
    8000242c:	818080e7          	jalr	-2024(ra) # 80001c40 <myproc>
    80002430:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002432:	05250663          	beq	a0,s2,8000247e <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	8b2080e7          	jalr	-1870(ra) # 80000ce8 <acquire>
    release(lk);
    8000243e:	854a                	mv	a0,s2
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	918080e7          	jalr	-1768(ra) # 80000d58 <release>
  p->chan = chan;
    80002448:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000244c:	4785                	li	a5,1
    8000244e:	d09c                	sw	a5,32(s1)
  sched();
    80002450:	00000097          	auipc	ra,0x0
    80002454:	da6080e7          	jalr	-602(ra) # 800021f6 <sched>
  p->chan = 0;
    80002458:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    8000245c:	8526                	mv	a0,s1
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	8fa080e7          	jalr	-1798(ra) # 80000d58 <release>
    acquire(lk);
    80002466:	854a                	mv	a0,s2
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	880080e7          	jalr	-1920(ra) # 80000ce8 <acquire>
}
    80002470:	70a2                	ld	ra,40(sp)
    80002472:	7402                	ld	s0,32(sp)
    80002474:	64e2                	ld	s1,24(sp)
    80002476:	6942                	ld	s2,16(sp)
    80002478:	69a2                	ld	s3,8(sp)
    8000247a:	6145                	addi	sp,sp,48
    8000247c:	8082                	ret
  p->chan = chan;
    8000247e:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    80002482:	4785                	li	a5,1
    80002484:	d11c                	sw	a5,32(a0)
  sched();
    80002486:	00000097          	auipc	ra,0x0
    8000248a:	d70080e7          	jalr	-656(ra) # 800021f6 <sched>
  p->chan = 0;
    8000248e:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    80002492:	bff9                	j	80002470 <sleep+0x5a>

0000000080002494 <wait>:
{
    80002494:	715d                	addi	sp,sp,-80
    80002496:	e486                	sd	ra,72(sp)
    80002498:	e0a2                	sd	s0,64(sp)
    8000249a:	fc26                	sd	s1,56(sp)
    8000249c:	f84a                	sd	s2,48(sp)
    8000249e:	f44e                	sd	s3,40(sp)
    800024a0:	f052                	sd	s4,32(sp)
    800024a2:	ec56                	sd	s5,24(sp)
    800024a4:	e85a                	sd	s6,16(sp)
    800024a6:	e45e                	sd	s7,8(sp)
    800024a8:	0880                	addi	s0,sp,80
    800024aa:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800024ac:	fffff097          	auipc	ra,0xfffff
    800024b0:	794080e7          	jalr	1940(ra) # 80001c40 <myproc>
    800024b4:	892a                	mv	s2,a0
  acquire(&p->lock);
    800024b6:	fffff097          	auipc	ra,0xfffff
    800024ba:	832080e7          	jalr	-1998(ra) # 80000ce8 <acquire>
    havekids = 0;
    800024be:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800024c0:	4a11                	li	s4,4
        havekids = 1;
    800024c2:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800024c4:	00018997          	auipc	s3,0x18
    800024c8:	4dc98993          	addi	s3,s3,1244 # 8001a9a0 <tickslock>
    havekids = 0;
    800024cc:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800024ce:	00013497          	auipc	s1,0x13
    800024d2:	8d248493          	addi	s1,s1,-1838 # 80014da0 <proc>
    800024d6:	a08d                	j	80002538 <wait+0xa4>
          pid = np->pid;
    800024d8:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800024dc:	000b0e63          	beqz	s6,800024f8 <wait+0x64>
    800024e0:	4691                	li	a3,4
    800024e2:	03c48613          	addi	a2,s1,60
    800024e6:	85da                	mv	a1,s6
    800024e8:	05893503          	ld	a0,88(s2)
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	446080e7          	jalr	1094(ra) # 80001932 <copyout>
    800024f4:	02054263          	bltz	a0,80002518 <wait+0x84>
          freeproc(np);
    800024f8:	8526                	mv	a0,s1
    800024fa:	00000097          	auipc	ra,0x0
    800024fe:	962080e7          	jalr	-1694(ra) # 80001e5c <freeproc>
          release(&np->lock);
    80002502:	8526                	mv	a0,s1
    80002504:	fffff097          	auipc	ra,0xfffff
    80002508:	854080e7          	jalr	-1964(ra) # 80000d58 <release>
          release(&p->lock);
    8000250c:	854a                	mv	a0,s2
    8000250e:	fffff097          	auipc	ra,0xfffff
    80002512:	84a080e7          	jalr	-1974(ra) # 80000d58 <release>
          return pid;
    80002516:	a8a9                	j	80002570 <wait+0xdc>
            release(&np->lock);
    80002518:	8526                	mv	a0,s1
    8000251a:	fffff097          	auipc	ra,0xfffff
    8000251e:	83e080e7          	jalr	-1986(ra) # 80000d58 <release>
            release(&p->lock);
    80002522:	854a                	mv	a0,s2
    80002524:	fffff097          	auipc	ra,0xfffff
    80002528:	834080e7          	jalr	-1996(ra) # 80000d58 <release>
            return -1;
    8000252c:	59fd                	li	s3,-1
    8000252e:	a089                	j	80002570 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002530:	17048493          	addi	s1,s1,368
    80002534:	03348463          	beq	s1,s3,8000255c <wait+0xc8>
      if(np->parent == p){
    80002538:	749c                	ld	a5,40(s1)
    8000253a:	ff279be3          	bne	a5,s2,80002530 <wait+0x9c>
        acquire(&np->lock);
    8000253e:	8526                	mv	a0,s1
    80002540:	ffffe097          	auipc	ra,0xffffe
    80002544:	7a8080e7          	jalr	1960(ra) # 80000ce8 <acquire>
        if(np->state == ZOMBIE){
    80002548:	509c                	lw	a5,32(s1)
    8000254a:	f94787e3          	beq	a5,s4,800024d8 <wait+0x44>
        release(&np->lock);
    8000254e:	8526                	mv	a0,s1
    80002550:	fffff097          	auipc	ra,0xfffff
    80002554:	808080e7          	jalr	-2040(ra) # 80000d58 <release>
        havekids = 1;
    80002558:	8756                	mv	a4,s5
    8000255a:	bfd9                	j	80002530 <wait+0x9c>
    if(!havekids || p->killed){
    8000255c:	c701                	beqz	a4,80002564 <wait+0xd0>
    8000255e:	03892783          	lw	a5,56(s2)
    80002562:	c39d                	beqz	a5,80002588 <wait+0xf4>
      release(&p->lock);
    80002564:	854a                	mv	a0,s2
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	7f2080e7          	jalr	2034(ra) # 80000d58 <release>
      return -1;
    8000256e:	59fd                	li	s3,-1
}
    80002570:	854e                	mv	a0,s3
    80002572:	60a6                	ld	ra,72(sp)
    80002574:	6406                	ld	s0,64(sp)
    80002576:	74e2                	ld	s1,56(sp)
    80002578:	7942                	ld	s2,48(sp)
    8000257a:	79a2                	ld	s3,40(sp)
    8000257c:	7a02                	ld	s4,32(sp)
    8000257e:	6ae2                	ld	s5,24(sp)
    80002580:	6b42                	ld	s6,16(sp)
    80002582:	6ba2                	ld	s7,8(sp)
    80002584:	6161                	addi	sp,sp,80
    80002586:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002588:	85ca                	mv	a1,s2
    8000258a:	854a                	mv	a0,s2
    8000258c:	00000097          	auipc	ra,0x0
    80002590:	e8a080e7          	jalr	-374(ra) # 80002416 <sleep>
    havekids = 0;
    80002594:	bf25                	j	800024cc <wait+0x38>

0000000080002596 <wakeup>:
{
    80002596:	7139                	addi	sp,sp,-64
    80002598:	fc06                	sd	ra,56(sp)
    8000259a:	f822                	sd	s0,48(sp)
    8000259c:	f426                	sd	s1,40(sp)
    8000259e:	f04a                	sd	s2,32(sp)
    800025a0:	ec4e                	sd	s3,24(sp)
    800025a2:	e852                	sd	s4,16(sp)
    800025a4:	e456                	sd	s5,8(sp)
    800025a6:	0080                	addi	s0,sp,64
    800025a8:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800025aa:	00012497          	auipc	s1,0x12
    800025ae:	7f648493          	addi	s1,s1,2038 # 80014da0 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800025b2:	4985                	li	s3,1
      p->state = RUNNABLE;
    800025b4:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800025b6:	00018917          	auipc	s2,0x18
    800025ba:	3ea90913          	addi	s2,s2,1002 # 8001a9a0 <tickslock>
    800025be:	a811                	j	800025d2 <wakeup+0x3c>
    release(&p->lock);
    800025c0:	8526                	mv	a0,s1
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	796080e7          	jalr	1942(ra) # 80000d58 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800025ca:	17048493          	addi	s1,s1,368
    800025ce:	03248063          	beq	s1,s2,800025ee <wakeup+0x58>
    acquire(&p->lock);
    800025d2:	8526                	mv	a0,s1
    800025d4:	ffffe097          	auipc	ra,0xffffe
    800025d8:	714080e7          	jalr	1812(ra) # 80000ce8 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800025dc:	509c                	lw	a5,32(s1)
    800025de:	ff3791e3          	bne	a5,s3,800025c0 <wakeup+0x2a>
    800025e2:	789c                	ld	a5,48(s1)
    800025e4:	fd479ee3          	bne	a5,s4,800025c0 <wakeup+0x2a>
      p->state = RUNNABLE;
    800025e8:	0354a023          	sw	s5,32(s1)
    800025ec:	bfd1                	j	800025c0 <wakeup+0x2a>
}
    800025ee:	70e2                	ld	ra,56(sp)
    800025f0:	7442                	ld	s0,48(sp)
    800025f2:	74a2                	ld	s1,40(sp)
    800025f4:	7902                	ld	s2,32(sp)
    800025f6:	69e2                	ld	s3,24(sp)
    800025f8:	6a42                	ld	s4,16(sp)
    800025fa:	6aa2                	ld	s5,8(sp)
    800025fc:	6121                	addi	sp,sp,64
    800025fe:	8082                	ret

0000000080002600 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002600:	7179                	addi	sp,sp,-48
    80002602:	f406                	sd	ra,40(sp)
    80002604:	f022                	sd	s0,32(sp)
    80002606:	ec26                	sd	s1,24(sp)
    80002608:	e84a                	sd	s2,16(sp)
    8000260a:	e44e                	sd	s3,8(sp)
    8000260c:	1800                	addi	s0,sp,48
    8000260e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002610:	00012497          	auipc	s1,0x12
    80002614:	79048493          	addi	s1,s1,1936 # 80014da0 <proc>
    80002618:	00018997          	auipc	s3,0x18
    8000261c:	38898993          	addi	s3,s3,904 # 8001a9a0 <tickslock>
    acquire(&p->lock);
    80002620:	8526                	mv	a0,s1
    80002622:	ffffe097          	auipc	ra,0xffffe
    80002626:	6c6080e7          	jalr	1734(ra) # 80000ce8 <acquire>
    if(p->pid == pid){
    8000262a:	40bc                	lw	a5,64(s1)
    8000262c:	01278d63          	beq	a5,s2,80002646 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002630:	8526                	mv	a0,s1
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	726080e7          	jalr	1830(ra) # 80000d58 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000263a:	17048493          	addi	s1,s1,368
    8000263e:	ff3491e3          	bne	s1,s3,80002620 <kill+0x20>
  }
  return -1;
    80002642:	557d                	li	a0,-1
    80002644:	a821                	j	8000265c <kill+0x5c>
      p->killed = 1;
    80002646:	4785                	li	a5,1
    80002648:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    8000264a:	5098                	lw	a4,32(s1)
    8000264c:	00f70f63          	beq	a4,a5,8000266a <kill+0x6a>
      release(&p->lock);
    80002650:	8526                	mv	a0,s1
    80002652:	ffffe097          	auipc	ra,0xffffe
    80002656:	706080e7          	jalr	1798(ra) # 80000d58 <release>
      return 0;
    8000265a:	4501                	li	a0,0
}
    8000265c:	70a2                	ld	ra,40(sp)
    8000265e:	7402                	ld	s0,32(sp)
    80002660:	64e2                	ld	s1,24(sp)
    80002662:	6942                	ld	s2,16(sp)
    80002664:	69a2                	ld	s3,8(sp)
    80002666:	6145                	addi	sp,sp,48
    80002668:	8082                	ret
        p->state = RUNNABLE;
    8000266a:	4789                	li	a5,2
    8000266c:	d09c                	sw	a5,32(s1)
    8000266e:	b7cd                	j	80002650 <kill+0x50>

0000000080002670 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002670:	7179                	addi	sp,sp,-48
    80002672:	f406                	sd	ra,40(sp)
    80002674:	f022                	sd	s0,32(sp)
    80002676:	ec26                	sd	s1,24(sp)
    80002678:	e84a                	sd	s2,16(sp)
    8000267a:	e44e                	sd	s3,8(sp)
    8000267c:	e052                	sd	s4,0(sp)
    8000267e:	1800                	addi	s0,sp,48
    80002680:	84aa                	mv	s1,a0
    80002682:	892e                	mv	s2,a1
    80002684:	89b2                	mv	s3,a2
    80002686:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002688:	fffff097          	auipc	ra,0xfffff
    8000268c:	5b8080e7          	jalr	1464(ra) # 80001c40 <myproc>
  if(user_dst){
    80002690:	c08d                	beqz	s1,800026b2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002692:	86d2                	mv	a3,s4
    80002694:	864e                	mv	a2,s3
    80002696:	85ca                	mv	a1,s2
    80002698:	6d28                	ld	a0,88(a0)
    8000269a:	fffff097          	auipc	ra,0xfffff
    8000269e:	298080e7          	jalr	664(ra) # 80001932 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026a2:	70a2                	ld	ra,40(sp)
    800026a4:	7402                	ld	s0,32(sp)
    800026a6:	64e2                	ld	s1,24(sp)
    800026a8:	6942                	ld	s2,16(sp)
    800026aa:	69a2                	ld	s3,8(sp)
    800026ac:	6a02                	ld	s4,0(sp)
    800026ae:	6145                	addi	sp,sp,48
    800026b0:	8082                	ret
    memmove((char *)dst, src, len);
    800026b2:	000a061b          	sext.w	a2,s4
    800026b6:	85ce                	mv	a1,s3
    800026b8:	854a                	mv	a0,s2
    800026ba:	fffff097          	auipc	ra,0xfffff
    800026be:	8f8080e7          	jalr	-1800(ra) # 80000fb2 <memmove>
    return 0;
    800026c2:	8526                	mv	a0,s1
    800026c4:	bff9                	j	800026a2 <either_copyout+0x32>

00000000800026c6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026c6:	7179                	addi	sp,sp,-48
    800026c8:	f406                	sd	ra,40(sp)
    800026ca:	f022                	sd	s0,32(sp)
    800026cc:	ec26                	sd	s1,24(sp)
    800026ce:	e84a                	sd	s2,16(sp)
    800026d0:	e44e                	sd	s3,8(sp)
    800026d2:	e052                	sd	s4,0(sp)
    800026d4:	1800                	addi	s0,sp,48
    800026d6:	892a                	mv	s2,a0
    800026d8:	84ae                	mv	s1,a1
    800026da:	89b2                	mv	s3,a2
    800026dc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026de:	fffff097          	auipc	ra,0xfffff
    800026e2:	562080e7          	jalr	1378(ra) # 80001c40 <myproc>
  if(user_src){
    800026e6:	c08d                	beqz	s1,80002708 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026e8:	86d2                	mv	a3,s4
    800026ea:	864e                	mv	a2,s3
    800026ec:	85ca                	mv	a1,s2
    800026ee:	6d28                	ld	a0,88(a0)
    800026f0:	fffff097          	auipc	ra,0xfffff
    800026f4:	2ce080e7          	jalr	718(ra) # 800019be <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026f8:	70a2                	ld	ra,40(sp)
    800026fa:	7402                	ld	s0,32(sp)
    800026fc:	64e2                	ld	s1,24(sp)
    800026fe:	6942                	ld	s2,16(sp)
    80002700:	69a2                	ld	s3,8(sp)
    80002702:	6a02                	ld	s4,0(sp)
    80002704:	6145                	addi	sp,sp,48
    80002706:	8082                	ret
    memmove(dst, (char*)src, len);
    80002708:	000a061b          	sext.w	a2,s4
    8000270c:	85ce                	mv	a1,s3
    8000270e:	854a                	mv	a0,s2
    80002710:	fffff097          	auipc	ra,0xfffff
    80002714:	8a2080e7          	jalr	-1886(ra) # 80000fb2 <memmove>
    return 0;
    80002718:	8526                	mv	a0,s1
    8000271a:	bff9                	j	800026f8 <either_copyin+0x32>

000000008000271c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000271c:	715d                	addi	sp,sp,-80
    8000271e:	e486                	sd	ra,72(sp)
    80002720:	e0a2                	sd	s0,64(sp)
    80002722:	fc26                	sd	s1,56(sp)
    80002724:	f84a                	sd	s2,48(sp)
    80002726:	f44e                	sd	s3,40(sp)
    80002728:	f052                	sd	s4,32(sp)
    8000272a:	ec56                	sd	s5,24(sp)
    8000272c:	e85a                	sd	s6,16(sp)
    8000272e:	e45e                	sd	s7,8(sp)
    80002730:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002732:	00006517          	auipc	a0,0x6
    80002736:	bae50513          	addi	a0,a0,-1106 # 800082e0 <userret+0x250>
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	e68080e7          	jalr	-408(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002742:	00012497          	auipc	s1,0x12
    80002746:	7be48493          	addi	s1,s1,1982 # 80014f00 <proc+0x160>
    8000274a:	00018917          	auipc	s2,0x18
    8000274e:	3b690913          	addi	s2,s2,950 # 8001ab00 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002752:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002754:	00006997          	auipc	s3,0x6
    80002758:	dbc98993          	addi	s3,s3,-580 # 80008510 <userret+0x480>
    printf("%d %s %s", p->pid, state, p->name);
    8000275c:	00006a97          	auipc	s5,0x6
    80002760:	dbca8a93          	addi	s5,s5,-580 # 80008518 <userret+0x488>
    printf("\n");
    80002764:	00006a17          	auipc	s4,0x6
    80002768:	b7ca0a13          	addi	s4,s4,-1156 # 800082e0 <userret+0x250>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000276c:	00006b97          	auipc	s7,0x6
    80002770:	3d4b8b93          	addi	s7,s7,980 # 80008b40 <states.0>
    80002774:	a00d                	j	80002796 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002776:	ee06a583          	lw	a1,-288(a3)
    8000277a:	8556                	mv	a0,s5
    8000277c:	ffffe097          	auipc	ra,0xffffe
    80002780:	e26080e7          	jalr	-474(ra) # 800005a2 <printf>
    printf("\n");
    80002784:	8552                	mv	a0,s4
    80002786:	ffffe097          	auipc	ra,0xffffe
    8000278a:	e1c080e7          	jalr	-484(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000278e:	17048493          	addi	s1,s1,368
    80002792:	03248163          	beq	s1,s2,800027b4 <procdump+0x98>
    if(p->state == UNUSED)
    80002796:	86a6                	mv	a3,s1
    80002798:	ec04a783          	lw	a5,-320(s1)
    8000279c:	dbed                	beqz	a5,8000278e <procdump+0x72>
      state = "???";
    8000279e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027a0:	fcfb6be3          	bltu	s6,a5,80002776 <procdump+0x5a>
    800027a4:	1782                	slli	a5,a5,0x20
    800027a6:	9381                	srli	a5,a5,0x20
    800027a8:	078e                	slli	a5,a5,0x3
    800027aa:	97de                	add	a5,a5,s7
    800027ac:	6390                	ld	a2,0(a5)
    800027ae:	f661                	bnez	a2,80002776 <procdump+0x5a>
      state = "???";
    800027b0:	864e                	mv	a2,s3
    800027b2:	b7d1                	j	80002776 <procdump+0x5a>
  }
}
    800027b4:	60a6                	ld	ra,72(sp)
    800027b6:	6406                	ld	s0,64(sp)
    800027b8:	74e2                	ld	s1,56(sp)
    800027ba:	7942                	ld	s2,48(sp)
    800027bc:	79a2                	ld	s3,40(sp)
    800027be:	7a02                	ld	s4,32(sp)
    800027c0:	6ae2                	ld	s5,24(sp)
    800027c2:	6b42                	ld	s6,16(sp)
    800027c4:	6ba2                	ld	s7,8(sp)
    800027c6:	6161                	addi	sp,sp,80
    800027c8:	8082                	ret

00000000800027ca <swtch>:
    800027ca:	00153023          	sd	ra,0(a0)
    800027ce:	00253423          	sd	sp,8(a0)
    800027d2:	e900                	sd	s0,16(a0)
    800027d4:	ed04                	sd	s1,24(a0)
    800027d6:	03253023          	sd	s2,32(a0)
    800027da:	03353423          	sd	s3,40(a0)
    800027de:	03453823          	sd	s4,48(a0)
    800027e2:	03553c23          	sd	s5,56(a0)
    800027e6:	05653023          	sd	s6,64(a0)
    800027ea:	05753423          	sd	s7,72(a0)
    800027ee:	05853823          	sd	s8,80(a0)
    800027f2:	05953c23          	sd	s9,88(a0)
    800027f6:	07a53023          	sd	s10,96(a0)
    800027fa:	07b53423          	sd	s11,104(a0)
    800027fe:	0005b083          	ld	ra,0(a1)
    80002802:	0085b103          	ld	sp,8(a1)
    80002806:	6980                	ld	s0,16(a1)
    80002808:	6d84                	ld	s1,24(a1)
    8000280a:	0205b903          	ld	s2,32(a1)
    8000280e:	0285b983          	ld	s3,40(a1)
    80002812:	0305ba03          	ld	s4,48(a1)
    80002816:	0385ba83          	ld	s5,56(a1)
    8000281a:	0405bb03          	ld	s6,64(a1)
    8000281e:	0485bb83          	ld	s7,72(a1)
    80002822:	0505bc03          	ld	s8,80(a1)
    80002826:	0585bc83          	ld	s9,88(a1)
    8000282a:	0605bd03          	ld	s10,96(a1)
    8000282e:	0685bd83          	ld	s11,104(a1)
    80002832:	8082                	ret

0000000080002834 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002834:	1141                	addi	sp,sp,-16
    80002836:	e406                	sd	ra,8(sp)
    80002838:	e022                	sd	s0,0(sp)
    8000283a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000283c:	00006597          	auipc	a1,0x6
    80002840:	d1458593          	addi	a1,a1,-748 # 80008550 <userret+0x4c0>
    80002844:	00018517          	auipc	a0,0x18
    80002848:	15c50513          	addi	a0,a0,348 # 8001a9a0 <tickslock>
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	34e080e7          	jalr	846(ra) # 80000b9a <initlock>
}
    80002854:	60a2                	ld	ra,8(sp)
    80002856:	6402                	ld	s0,0(sp)
    80002858:	0141                	addi	sp,sp,16
    8000285a:	8082                	ret

000000008000285c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000285c:	1141                	addi	sp,sp,-16
    8000285e:	e422                	sd	s0,8(sp)
    80002860:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002862:	00003797          	auipc	a5,0x3
    80002866:	78e78793          	addi	a5,a5,1934 # 80005ff0 <kernelvec>
    8000286a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000286e:	6422                	ld	s0,8(sp)
    80002870:	0141                	addi	sp,sp,16
    80002872:	8082                	ret

0000000080002874 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002874:	1141                	addi	sp,sp,-16
    80002876:	e406                	sd	ra,8(sp)
    80002878:	e022                	sd	s0,0(sp)
    8000287a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000287c:	fffff097          	auipc	ra,0xfffff
    80002880:	3c4080e7          	jalr	964(ra) # 80001c40 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002884:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002888:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000288a:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000288e:	00005617          	auipc	a2,0x5
    80002892:	77260613          	addi	a2,a2,1906 # 80008000 <trampoline>
    80002896:	00005697          	auipc	a3,0x5
    8000289a:	76a68693          	addi	a3,a3,1898 # 80008000 <trampoline>
    8000289e:	8e91                	sub	a3,a3,a2
    800028a0:	040007b7          	lui	a5,0x4000
    800028a4:	17fd                	addi	a5,a5,-1
    800028a6:	07b2                	slli	a5,a5,0xc
    800028a8:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028aa:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    800028ae:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028b0:	180026f3          	csrr	a3,satp
    800028b4:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028b6:	7138                	ld	a4,96(a0)
    800028b8:	6534                	ld	a3,72(a0)
    800028ba:	6585                	lui	a1,0x1
    800028bc:	96ae                	add	a3,a3,a1
    800028be:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    800028c0:	7138                	ld	a4,96(a0)
    800028c2:	00000697          	auipc	a3,0x0
    800028c6:	12868693          	addi	a3,a3,296 # 800029ea <usertrap>
    800028ca:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    800028cc:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028ce:	8692                	mv	a3,tp
    800028d0:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d2:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028d6:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028da:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028de:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    800028e2:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028e4:	6f18                	ld	a4,24(a4)
    800028e6:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028ea:	6d2c                	ld	a1,88(a0)
    800028ec:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800028ee:	00005717          	auipc	a4,0x5
    800028f2:	7a270713          	addi	a4,a4,1954 # 80008090 <userret>
    800028f6:	8f11                	sub	a4,a4,a2
    800028f8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800028fa:	577d                	li	a4,-1
    800028fc:	177e                	slli	a4,a4,0x3f
    800028fe:	8dd9                	or	a1,a1,a4
    80002900:	02000537          	lui	a0,0x2000
    80002904:	157d                	addi	a0,a0,-1
    80002906:	0536                	slli	a0,a0,0xd
    80002908:	9782                	jalr	a5
}
    8000290a:	60a2                	ld	ra,8(sp)
    8000290c:	6402                	ld	s0,0(sp)
    8000290e:	0141                	addi	sp,sp,16
    80002910:	8082                	ret

0000000080002912 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002912:	1101                	addi	sp,sp,-32
    80002914:	ec06                	sd	ra,24(sp)
    80002916:	e822                	sd	s0,16(sp)
    80002918:	e426                	sd	s1,8(sp)
    8000291a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000291c:	00018497          	auipc	s1,0x18
    80002920:	08448493          	addi	s1,s1,132 # 8001a9a0 <tickslock>
    80002924:	8526                	mv	a0,s1
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	3c2080e7          	jalr	962(ra) # 80000ce8 <acquire>
  ticks++;
    8000292e:	0002d517          	auipc	a0,0x2d
    80002932:	71250513          	addi	a0,a0,1810 # 80030040 <ticks>
    80002936:	411c                	lw	a5,0(a0)
    80002938:	2785                	addiw	a5,a5,1
    8000293a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000293c:	00000097          	auipc	ra,0x0
    80002940:	c5a080e7          	jalr	-934(ra) # 80002596 <wakeup>
  release(&tickslock);
    80002944:	8526                	mv	a0,s1
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	412080e7          	jalr	1042(ra) # 80000d58 <release>
}
    8000294e:	60e2                	ld	ra,24(sp)
    80002950:	6442                	ld	s0,16(sp)
    80002952:	64a2                	ld	s1,8(sp)
    80002954:	6105                	addi	sp,sp,32
    80002956:	8082                	ret

0000000080002958 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002958:	1101                	addi	sp,sp,-32
    8000295a:	ec06                	sd	ra,24(sp)
    8000295c:	e822                	sd	s0,16(sp)
    8000295e:	e426                	sd	s1,8(sp)
    80002960:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002962:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002966:	00074d63          	bltz	a4,80002980 <devintr+0x28>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    }

    plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000001L){
    8000296a:	57fd                	li	a5,-1
    8000296c:	17fe                	slli	a5,a5,0x3f
    8000296e:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002970:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002972:	04f70b63          	beq	a4,a5,800029c8 <devintr+0x70>
  }
}
    80002976:	60e2                	ld	ra,24(sp)
    80002978:	6442                	ld	s0,16(sp)
    8000297a:	64a2                	ld	s1,8(sp)
    8000297c:	6105                	addi	sp,sp,32
    8000297e:	8082                	ret
     (scause & 0xff) == 9){
    80002980:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002984:	46a5                	li	a3,9
    80002986:	fed792e3          	bne	a5,a3,8000296a <devintr+0x12>
    int irq = plic_claim();
    8000298a:	00003097          	auipc	ra,0x3
    8000298e:	76e080e7          	jalr	1902(ra) # 800060f8 <plic_claim>
    80002992:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002994:	47a9                	li	a5,10
    80002996:	00f50e63          	beq	a0,a5,800029b2 <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    8000299a:	fff5079b          	addiw	a5,a0,-1
    8000299e:	4705                	li	a4,1
    800029a0:	00f77e63          	bgeu	a4,a5,800029bc <devintr+0x64>
    plic_complete(irq);
    800029a4:	8526                	mv	a0,s1
    800029a6:	00003097          	auipc	ra,0x3
    800029aa:	776080e7          	jalr	1910(ra) # 8000611c <plic_complete>
    return 1;
    800029ae:	4505                	li	a0,1
    800029b0:	b7d9                	j	80002976 <devintr+0x1e>
      uartintr();
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	e86080e7          	jalr	-378(ra) # 80000838 <uartintr>
    800029ba:	b7ed                	j	800029a4 <devintr+0x4c>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800029bc:	853e                	mv	a0,a5
    800029be:	00004097          	auipc	ra,0x4
    800029c2:	d08080e7          	jalr	-760(ra) # 800066c6 <virtio_disk_intr>
    800029c6:	bff9                	j	800029a4 <devintr+0x4c>
    if(cpuid() == 0){
    800029c8:	fffff097          	auipc	ra,0xfffff
    800029cc:	24c080e7          	jalr	588(ra) # 80001c14 <cpuid>
    800029d0:	c901                	beqz	a0,800029e0 <devintr+0x88>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029d2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029d6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029d8:	14479073          	csrw	sip,a5
    return 2;
    800029dc:	4509                	li	a0,2
    800029de:	bf61                	j	80002976 <devintr+0x1e>
      clockintr();
    800029e0:	00000097          	auipc	ra,0x0
    800029e4:	f32080e7          	jalr	-206(ra) # 80002912 <clockintr>
    800029e8:	b7ed                	j	800029d2 <devintr+0x7a>

00000000800029ea <usertrap>:
{
    800029ea:	1101                	addi	sp,sp,-32
    800029ec:	ec06                	sd	ra,24(sp)
    800029ee:	e822                	sd	s0,16(sp)
    800029f0:	e426                	sd	s1,8(sp)
    800029f2:	e04a                	sd	s2,0(sp)
    800029f4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029f6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029fa:	1007f793          	andi	a5,a5,256
    800029fe:	e7bd                	bnez	a5,80002a6c <usertrap+0x82>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a00:	00003797          	auipc	a5,0x3
    80002a04:	5f078793          	addi	a5,a5,1520 # 80005ff0 <kernelvec>
    80002a08:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a0c:	fffff097          	auipc	ra,0xfffff
    80002a10:	234080e7          	jalr	564(ra) # 80001c40 <myproc>
    80002a14:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002a16:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a18:	14102773          	csrr	a4,sepc
    80002a1c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a1e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a22:	47a1                	li	a5,8
    80002a24:	06f71263          	bne	a4,a5,80002a88 <usertrap+0x9e>
    if(p->killed)
    80002a28:	5d1c                	lw	a5,56(a0)
    80002a2a:	eba9                	bnez	a5,80002a7c <usertrap+0x92>
    p->tf->epc += 4;
    80002a2c:	70b8                	ld	a4,96(s1)
    80002a2e:	6f1c                	ld	a5,24(a4)
    80002a30:	0791                	addi	a5,a5,4
    80002a32:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002a34:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80002a38:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80002a3c:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a40:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a44:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a48:	10079073          	csrw	sstatus,a5
    syscall();
    80002a4c:	00000097          	auipc	ra,0x0
    80002a50:	2e0080e7          	jalr	736(ra) # 80002d2c <syscall>
  if(p->killed)
    80002a54:	5c9c                	lw	a5,56(s1)
    80002a56:	ebc1                	bnez	a5,80002ae6 <usertrap+0xfc>
  usertrapret();
    80002a58:	00000097          	auipc	ra,0x0
    80002a5c:	e1c080e7          	jalr	-484(ra) # 80002874 <usertrapret>
}
    80002a60:	60e2                	ld	ra,24(sp)
    80002a62:	6442                	ld	s0,16(sp)
    80002a64:	64a2                	ld	s1,8(sp)
    80002a66:	6902                	ld	s2,0(sp)
    80002a68:	6105                	addi	sp,sp,32
    80002a6a:	8082                	ret
    panic("usertrap: not from user mode");
    80002a6c:	00006517          	auipc	a0,0x6
    80002a70:	aec50513          	addi	a0,a0,-1300 # 80008558 <userret+0x4c8>
    80002a74:	ffffe097          	auipc	ra,0xffffe
    80002a78:	ad4080e7          	jalr	-1324(ra) # 80000548 <panic>
      exit(-1);
    80002a7c:	557d                	li	a0,-1
    80002a7e:	00000097          	auipc	ra,0x0
    80002a82:	84e080e7          	jalr	-1970(ra) # 800022cc <exit>
    80002a86:	b75d                	j	80002a2c <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002a88:	00000097          	auipc	ra,0x0
    80002a8c:	ed0080e7          	jalr	-304(ra) # 80002958 <devintr>
    80002a90:	892a                	mv	s2,a0
    80002a92:	c501                	beqz	a0,80002a9a <usertrap+0xb0>
  if(p->killed)
    80002a94:	5c9c                	lw	a5,56(s1)
    80002a96:	c3a1                	beqz	a5,80002ad6 <usertrap+0xec>
    80002a98:	a815                	j	80002acc <usertrap+0xe2>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a9a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a9e:	40b0                	lw	a2,64(s1)
    80002aa0:	00006517          	auipc	a0,0x6
    80002aa4:	ad850513          	addi	a0,a0,-1320 # 80008578 <userret+0x4e8>
    80002aa8:	ffffe097          	auipc	ra,0xffffe
    80002aac:	afa080e7          	jalr	-1286(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ab0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ab4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ab8:	00006517          	auipc	a0,0x6
    80002abc:	af050513          	addi	a0,a0,-1296 # 800085a8 <userret+0x518>
    80002ac0:	ffffe097          	auipc	ra,0xffffe
    80002ac4:	ae2080e7          	jalr	-1310(ra) # 800005a2 <printf>
    p->killed = 1;
    80002ac8:	4785                	li	a5,1
    80002aca:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002acc:	557d                	li	a0,-1
    80002ace:	fffff097          	auipc	ra,0xfffff
    80002ad2:	7fe080e7          	jalr	2046(ra) # 800022cc <exit>
  if(which_dev == 2)
    80002ad6:	4789                	li	a5,2
    80002ad8:	f8f910e3          	bne	s2,a5,80002a58 <usertrap+0x6e>
    yield();
    80002adc:	00000097          	auipc	ra,0x0
    80002ae0:	8fe080e7          	jalr	-1794(ra) # 800023da <yield>
    80002ae4:	bf95                	j	80002a58 <usertrap+0x6e>
  int which_dev = 0;
    80002ae6:	4901                	li	s2,0
    80002ae8:	b7d5                	j	80002acc <usertrap+0xe2>

0000000080002aea <kerneltrap>:
{
    80002aea:	7179                	addi	sp,sp,-48
    80002aec:	f406                	sd	ra,40(sp)
    80002aee:	f022                	sd	s0,32(sp)
    80002af0:	ec26                	sd	s1,24(sp)
    80002af2:	e84a                	sd	s2,16(sp)
    80002af4:	e44e                	sd	s3,8(sp)
    80002af6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002af8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002afc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b00:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b04:	1004f793          	andi	a5,s1,256
    80002b08:	cb85                	beqz	a5,80002b38 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b0a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b0e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b10:	ef85                	bnez	a5,80002b48 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b12:	00000097          	auipc	ra,0x0
    80002b16:	e46080e7          	jalr	-442(ra) # 80002958 <devintr>
    80002b1a:	cd1d                	beqz	a0,80002b58 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b1c:	4789                	li	a5,2
    80002b1e:	06f50a63          	beq	a0,a5,80002b92 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b22:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b26:	10049073          	csrw	sstatus,s1
}
    80002b2a:	70a2                	ld	ra,40(sp)
    80002b2c:	7402                	ld	s0,32(sp)
    80002b2e:	64e2                	ld	s1,24(sp)
    80002b30:	6942                	ld	s2,16(sp)
    80002b32:	69a2                	ld	s3,8(sp)
    80002b34:	6145                	addi	sp,sp,48
    80002b36:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b38:	00006517          	auipc	a0,0x6
    80002b3c:	a9050513          	addi	a0,a0,-1392 # 800085c8 <userret+0x538>
    80002b40:	ffffe097          	auipc	ra,0xffffe
    80002b44:	a08080e7          	jalr	-1528(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002b48:	00006517          	auipc	a0,0x6
    80002b4c:	aa850513          	addi	a0,a0,-1368 # 800085f0 <userret+0x560>
    80002b50:	ffffe097          	auipc	ra,0xffffe
    80002b54:	9f8080e7          	jalr	-1544(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002b58:	85ce                	mv	a1,s3
    80002b5a:	00006517          	auipc	a0,0x6
    80002b5e:	ab650513          	addi	a0,a0,-1354 # 80008610 <userret+0x580>
    80002b62:	ffffe097          	auipc	ra,0xffffe
    80002b66:	a40080e7          	jalr	-1472(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b6a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b6e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b72:	00006517          	auipc	a0,0x6
    80002b76:	aae50513          	addi	a0,a0,-1362 # 80008620 <userret+0x590>
    80002b7a:	ffffe097          	auipc	ra,0xffffe
    80002b7e:	a28080e7          	jalr	-1496(ra) # 800005a2 <printf>
    panic("kerneltrap");
    80002b82:	00006517          	auipc	a0,0x6
    80002b86:	ab650513          	addi	a0,a0,-1354 # 80008638 <userret+0x5a8>
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	9be080e7          	jalr	-1602(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b92:	fffff097          	auipc	ra,0xfffff
    80002b96:	0ae080e7          	jalr	174(ra) # 80001c40 <myproc>
    80002b9a:	d541                	beqz	a0,80002b22 <kerneltrap+0x38>
    80002b9c:	fffff097          	auipc	ra,0xfffff
    80002ba0:	0a4080e7          	jalr	164(ra) # 80001c40 <myproc>
    80002ba4:	5118                	lw	a4,32(a0)
    80002ba6:	478d                	li	a5,3
    80002ba8:	f6f71de3          	bne	a4,a5,80002b22 <kerneltrap+0x38>
    yield();
    80002bac:	00000097          	auipc	ra,0x0
    80002bb0:	82e080e7          	jalr	-2002(ra) # 800023da <yield>
    80002bb4:	b7bd                	j	80002b22 <kerneltrap+0x38>

0000000080002bb6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002bb6:	1101                	addi	sp,sp,-32
    80002bb8:	ec06                	sd	ra,24(sp)
    80002bba:	e822                	sd	s0,16(sp)
    80002bbc:	e426                	sd	s1,8(sp)
    80002bbe:	1000                	addi	s0,sp,32
    80002bc0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002bc2:	fffff097          	auipc	ra,0xfffff
    80002bc6:	07e080e7          	jalr	126(ra) # 80001c40 <myproc>
  switch (n) {
    80002bca:	4795                	li	a5,5
    80002bcc:	0497e163          	bltu	a5,s1,80002c0e <argraw+0x58>
    80002bd0:	048a                	slli	s1,s1,0x2
    80002bd2:	00006717          	auipc	a4,0x6
    80002bd6:	f9670713          	addi	a4,a4,-106 # 80008b68 <states.0+0x28>
    80002bda:	94ba                	add	s1,s1,a4
    80002bdc:	409c                	lw	a5,0(s1)
    80002bde:	97ba                	add	a5,a5,a4
    80002be0:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002be2:	713c                	ld	a5,96(a0)
    80002be4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002be6:	60e2                	ld	ra,24(sp)
    80002be8:	6442                	ld	s0,16(sp)
    80002bea:	64a2                	ld	s1,8(sp)
    80002bec:	6105                	addi	sp,sp,32
    80002bee:	8082                	ret
    return p->tf->a1;
    80002bf0:	713c                	ld	a5,96(a0)
    80002bf2:	7fa8                	ld	a0,120(a5)
    80002bf4:	bfcd                	j	80002be6 <argraw+0x30>
    return p->tf->a2;
    80002bf6:	713c                	ld	a5,96(a0)
    80002bf8:	63c8                	ld	a0,128(a5)
    80002bfa:	b7f5                	j	80002be6 <argraw+0x30>
    return p->tf->a3;
    80002bfc:	713c                	ld	a5,96(a0)
    80002bfe:	67c8                	ld	a0,136(a5)
    80002c00:	b7dd                	j	80002be6 <argraw+0x30>
    return p->tf->a4;
    80002c02:	713c                	ld	a5,96(a0)
    80002c04:	6bc8                	ld	a0,144(a5)
    80002c06:	b7c5                	j	80002be6 <argraw+0x30>
    return p->tf->a5;
    80002c08:	713c                	ld	a5,96(a0)
    80002c0a:	6fc8                	ld	a0,152(a5)
    80002c0c:	bfe9                	j	80002be6 <argraw+0x30>
  panic("argraw");
    80002c0e:	00006517          	auipc	a0,0x6
    80002c12:	a3a50513          	addi	a0,a0,-1478 # 80008648 <userret+0x5b8>
    80002c16:	ffffe097          	auipc	ra,0xffffe
    80002c1a:	932080e7          	jalr	-1742(ra) # 80000548 <panic>

0000000080002c1e <fetchaddr>:
{
    80002c1e:	1101                	addi	sp,sp,-32
    80002c20:	ec06                	sd	ra,24(sp)
    80002c22:	e822                	sd	s0,16(sp)
    80002c24:	e426                	sd	s1,8(sp)
    80002c26:	e04a                	sd	s2,0(sp)
    80002c28:	1000                	addi	s0,sp,32
    80002c2a:	84aa                	mv	s1,a0
    80002c2c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c2e:	fffff097          	auipc	ra,0xfffff
    80002c32:	012080e7          	jalr	18(ra) # 80001c40 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002c36:	693c                	ld	a5,80(a0)
    80002c38:	02f4f863          	bgeu	s1,a5,80002c68 <fetchaddr+0x4a>
    80002c3c:	00848713          	addi	a4,s1,8
    80002c40:	02e7e663          	bltu	a5,a4,80002c6c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c44:	46a1                	li	a3,8
    80002c46:	8626                	mv	a2,s1
    80002c48:	85ca                	mv	a1,s2
    80002c4a:	6d28                	ld	a0,88(a0)
    80002c4c:	fffff097          	auipc	ra,0xfffff
    80002c50:	d72080e7          	jalr	-654(ra) # 800019be <copyin>
    80002c54:	00a03533          	snez	a0,a0
    80002c58:	40a00533          	neg	a0,a0
}
    80002c5c:	60e2                	ld	ra,24(sp)
    80002c5e:	6442                	ld	s0,16(sp)
    80002c60:	64a2                	ld	s1,8(sp)
    80002c62:	6902                	ld	s2,0(sp)
    80002c64:	6105                	addi	sp,sp,32
    80002c66:	8082                	ret
    return -1;
    80002c68:	557d                	li	a0,-1
    80002c6a:	bfcd                	j	80002c5c <fetchaddr+0x3e>
    80002c6c:	557d                	li	a0,-1
    80002c6e:	b7fd                	j	80002c5c <fetchaddr+0x3e>

0000000080002c70 <fetchstr>:
{
    80002c70:	7179                	addi	sp,sp,-48
    80002c72:	f406                	sd	ra,40(sp)
    80002c74:	f022                	sd	s0,32(sp)
    80002c76:	ec26                	sd	s1,24(sp)
    80002c78:	e84a                	sd	s2,16(sp)
    80002c7a:	e44e                	sd	s3,8(sp)
    80002c7c:	1800                	addi	s0,sp,48
    80002c7e:	892a                	mv	s2,a0
    80002c80:	84ae                	mv	s1,a1
    80002c82:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c84:	fffff097          	auipc	ra,0xfffff
    80002c88:	fbc080e7          	jalr	-68(ra) # 80001c40 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002c8c:	86ce                	mv	a3,s3
    80002c8e:	864a                	mv	a2,s2
    80002c90:	85a6                	mv	a1,s1
    80002c92:	6d28                	ld	a0,88(a0)
    80002c94:	fffff097          	auipc	ra,0xfffff
    80002c98:	db8080e7          	jalr	-584(ra) # 80001a4c <copyinstr>
  if(err < 0)
    80002c9c:	00054763          	bltz	a0,80002caa <fetchstr+0x3a>
  return strlen(buf);
    80002ca0:	8526                	mv	a0,s1
    80002ca2:	ffffe097          	auipc	ra,0xffffe
    80002ca6:	438080e7          	jalr	1080(ra) # 800010da <strlen>
}
    80002caa:	70a2                	ld	ra,40(sp)
    80002cac:	7402                	ld	s0,32(sp)
    80002cae:	64e2                	ld	s1,24(sp)
    80002cb0:	6942                	ld	s2,16(sp)
    80002cb2:	69a2                	ld	s3,8(sp)
    80002cb4:	6145                	addi	sp,sp,48
    80002cb6:	8082                	ret

0000000080002cb8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002cb8:	1101                	addi	sp,sp,-32
    80002cba:	ec06                	sd	ra,24(sp)
    80002cbc:	e822                	sd	s0,16(sp)
    80002cbe:	e426                	sd	s1,8(sp)
    80002cc0:	1000                	addi	s0,sp,32
    80002cc2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cc4:	00000097          	auipc	ra,0x0
    80002cc8:	ef2080e7          	jalr	-270(ra) # 80002bb6 <argraw>
    80002ccc:	c088                	sw	a0,0(s1)
  return 0;
}
    80002cce:	4501                	li	a0,0
    80002cd0:	60e2                	ld	ra,24(sp)
    80002cd2:	6442                	ld	s0,16(sp)
    80002cd4:	64a2                	ld	s1,8(sp)
    80002cd6:	6105                	addi	sp,sp,32
    80002cd8:	8082                	ret

0000000080002cda <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002cda:	1101                	addi	sp,sp,-32
    80002cdc:	ec06                	sd	ra,24(sp)
    80002cde:	e822                	sd	s0,16(sp)
    80002ce0:	e426                	sd	s1,8(sp)
    80002ce2:	1000                	addi	s0,sp,32
    80002ce4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ce6:	00000097          	auipc	ra,0x0
    80002cea:	ed0080e7          	jalr	-304(ra) # 80002bb6 <argraw>
    80002cee:	e088                	sd	a0,0(s1)
  return 0;
}
    80002cf0:	4501                	li	a0,0
    80002cf2:	60e2                	ld	ra,24(sp)
    80002cf4:	6442                	ld	s0,16(sp)
    80002cf6:	64a2                	ld	s1,8(sp)
    80002cf8:	6105                	addi	sp,sp,32
    80002cfa:	8082                	ret

0000000080002cfc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002cfc:	1101                	addi	sp,sp,-32
    80002cfe:	ec06                	sd	ra,24(sp)
    80002d00:	e822                	sd	s0,16(sp)
    80002d02:	e426                	sd	s1,8(sp)
    80002d04:	e04a                	sd	s2,0(sp)
    80002d06:	1000                	addi	s0,sp,32
    80002d08:	84ae                	mv	s1,a1
    80002d0a:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002d0c:	00000097          	auipc	ra,0x0
    80002d10:	eaa080e7          	jalr	-342(ra) # 80002bb6 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002d14:	864a                	mv	a2,s2
    80002d16:	85a6                	mv	a1,s1
    80002d18:	00000097          	auipc	ra,0x0
    80002d1c:	f58080e7          	jalr	-168(ra) # 80002c70 <fetchstr>
}
    80002d20:	60e2                	ld	ra,24(sp)
    80002d22:	6442                	ld	s0,16(sp)
    80002d24:	64a2                	ld	s1,8(sp)
    80002d26:	6902                	ld	s2,0(sp)
    80002d28:	6105                	addi	sp,sp,32
    80002d2a:	8082                	ret

0000000080002d2c <syscall>:
[SYS_ntas]    sys_ntas,
};

void
syscall(void)
{
    80002d2c:	1101                	addi	sp,sp,-32
    80002d2e:	ec06                	sd	ra,24(sp)
    80002d30:	e822                	sd	s0,16(sp)
    80002d32:	e426                	sd	s1,8(sp)
    80002d34:	e04a                	sd	s2,0(sp)
    80002d36:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d38:	fffff097          	auipc	ra,0xfffff
    80002d3c:	f08080e7          	jalr	-248(ra) # 80001c40 <myproc>
    80002d40:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002d42:	06053903          	ld	s2,96(a0)
    80002d46:	0a893783          	ld	a5,168(s2)
    80002d4a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d4e:	37fd                	addiw	a5,a5,-1
    80002d50:	4755                	li	a4,21
    80002d52:	00f76f63          	bltu	a4,a5,80002d70 <syscall+0x44>
    80002d56:	00369713          	slli	a4,a3,0x3
    80002d5a:	00006797          	auipc	a5,0x6
    80002d5e:	e2678793          	addi	a5,a5,-474 # 80008b80 <syscalls>
    80002d62:	97ba                	add	a5,a5,a4
    80002d64:	639c                	ld	a5,0(a5)
    80002d66:	c789                	beqz	a5,80002d70 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002d68:	9782                	jalr	a5
    80002d6a:	06a93823          	sd	a0,112(s2)
    80002d6e:	a839                	j	80002d8c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d70:	16048613          	addi	a2,s1,352
    80002d74:	40ac                	lw	a1,64(s1)
    80002d76:	00006517          	auipc	a0,0x6
    80002d7a:	8da50513          	addi	a0,a0,-1830 # 80008650 <userret+0x5c0>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	824080e7          	jalr	-2012(ra) # 800005a2 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002d86:	70bc                	ld	a5,96(s1)
    80002d88:	577d                	li	a4,-1
    80002d8a:	fbb8                	sd	a4,112(a5)
  }
}
    80002d8c:	60e2                	ld	ra,24(sp)
    80002d8e:	6442                	ld	s0,16(sp)
    80002d90:	64a2                	ld	s1,8(sp)
    80002d92:	6902                	ld	s2,0(sp)
    80002d94:	6105                	addi	sp,sp,32
    80002d96:	8082                	ret

0000000080002d98 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d98:	1101                	addi	sp,sp,-32
    80002d9a:	ec06                	sd	ra,24(sp)
    80002d9c:	e822                	sd	s0,16(sp)
    80002d9e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002da0:	fec40593          	addi	a1,s0,-20
    80002da4:	4501                	li	a0,0
    80002da6:	00000097          	auipc	ra,0x0
    80002daa:	f12080e7          	jalr	-238(ra) # 80002cb8 <argint>
    return -1;
    80002dae:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002db0:	00054963          	bltz	a0,80002dc2 <sys_exit+0x2a>
  exit(n);
    80002db4:	fec42503          	lw	a0,-20(s0)
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	514080e7          	jalr	1300(ra) # 800022cc <exit>
  return 0;  // not reached
    80002dc0:	4781                	li	a5,0
}
    80002dc2:	853e                	mv	a0,a5
    80002dc4:	60e2                	ld	ra,24(sp)
    80002dc6:	6442                	ld	s0,16(sp)
    80002dc8:	6105                	addi	sp,sp,32
    80002dca:	8082                	ret

0000000080002dcc <sys_getpid>:

uint64
sys_getpid(void)
{
    80002dcc:	1141                	addi	sp,sp,-16
    80002dce:	e406                	sd	ra,8(sp)
    80002dd0:	e022                	sd	s0,0(sp)
    80002dd2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dd4:	fffff097          	auipc	ra,0xfffff
    80002dd8:	e6c080e7          	jalr	-404(ra) # 80001c40 <myproc>
}
    80002ddc:	4128                	lw	a0,64(a0)
    80002dde:	60a2                	ld	ra,8(sp)
    80002de0:	6402                	ld	s0,0(sp)
    80002de2:	0141                	addi	sp,sp,16
    80002de4:	8082                	ret

0000000080002de6 <sys_fork>:

uint64
sys_fork(void)
{
    80002de6:	1141                	addi	sp,sp,-16
    80002de8:	e406                	sd	ra,8(sp)
    80002dea:	e022                	sd	s0,0(sp)
    80002dec:	0800                	addi	s0,sp,16
  return fork();
    80002dee:	fffff097          	auipc	ra,0xfffff
    80002df2:	1bc080e7          	jalr	444(ra) # 80001faa <fork>
}
    80002df6:	60a2                	ld	ra,8(sp)
    80002df8:	6402                	ld	s0,0(sp)
    80002dfa:	0141                	addi	sp,sp,16
    80002dfc:	8082                	ret

0000000080002dfe <sys_wait>:

uint64
sys_wait(void)
{
    80002dfe:	1101                	addi	sp,sp,-32
    80002e00:	ec06                	sd	ra,24(sp)
    80002e02:	e822                	sd	s0,16(sp)
    80002e04:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002e06:	fe840593          	addi	a1,s0,-24
    80002e0a:	4501                	li	a0,0
    80002e0c:	00000097          	auipc	ra,0x0
    80002e10:	ece080e7          	jalr	-306(ra) # 80002cda <argaddr>
    80002e14:	87aa                	mv	a5,a0
    return -1;
    80002e16:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002e18:	0007c863          	bltz	a5,80002e28 <sys_wait+0x2a>
  return wait(p);
    80002e1c:	fe843503          	ld	a0,-24(s0)
    80002e20:	fffff097          	auipc	ra,0xfffff
    80002e24:	674080e7          	jalr	1652(ra) # 80002494 <wait>
}
    80002e28:	60e2                	ld	ra,24(sp)
    80002e2a:	6442                	ld	s0,16(sp)
    80002e2c:	6105                	addi	sp,sp,32
    80002e2e:	8082                	ret

0000000080002e30 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e30:	7179                	addi	sp,sp,-48
    80002e32:	f406                	sd	ra,40(sp)
    80002e34:	f022                	sd	s0,32(sp)
    80002e36:	ec26                	sd	s1,24(sp)
    80002e38:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002e3a:	fdc40593          	addi	a1,s0,-36
    80002e3e:	4501                	li	a0,0
    80002e40:	00000097          	auipc	ra,0x0
    80002e44:	e78080e7          	jalr	-392(ra) # 80002cb8 <argint>
    return -1;
    80002e48:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002e4a:	00054f63          	bltz	a0,80002e68 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002e4e:	fffff097          	auipc	ra,0xfffff
    80002e52:	df2080e7          	jalr	-526(ra) # 80001c40 <myproc>
    80002e56:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002e58:	fdc42503          	lw	a0,-36(s0)
    80002e5c:	fffff097          	auipc	ra,0xfffff
    80002e60:	0da080e7          	jalr	218(ra) # 80001f36 <growproc>
    80002e64:	00054863          	bltz	a0,80002e74 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002e68:	8526                	mv	a0,s1
    80002e6a:	70a2                	ld	ra,40(sp)
    80002e6c:	7402                	ld	s0,32(sp)
    80002e6e:	64e2                	ld	s1,24(sp)
    80002e70:	6145                	addi	sp,sp,48
    80002e72:	8082                	ret
    return -1;
    80002e74:	54fd                	li	s1,-1
    80002e76:	bfcd                	j	80002e68 <sys_sbrk+0x38>

0000000080002e78 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e78:	7139                	addi	sp,sp,-64
    80002e7a:	fc06                	sd	ra,56(sp)
    80002e7c:	f822                	sd	s0,48(sp)
    80002e7e:	f426                	sd	s1,40(sp)
    80002e80:	f04a                	sd	s2,32(sp)
    80002e82:	ec4e                	sd	s3,24(sp)
    80002e84:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002e86:	fcc40593          	addi	a1,s0,-52
    80002e8a:	4501                	li	a0,0
    80002e8c:	00000097          	auipc	ra,0x0
    80002e90:	e2c080e7          	jalr	-468(ra) # 80002cb8 <argint>
    return -1;
    80002e94:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e96:	06054563          	bltz	a0,80002f00 <sys_sleep+0x88>
  acquire(&tickslock);
    80002e9a:	00018517          	auipc	a0,0x18
    80002e9e:	b0650513          	addi	a0,a0,-1274 # 8001a9a0 <tickslock>
    80002ea2:	ffffe097          	auipc	ra,0xffffe
    80002ea6:	e46080e7          	jalr	-442(ra) # 80000ce8 <acquire>
  ticks0 = ticks;
    80002eaa:	0002d917          	auipc	s2,0x2d
    80002eae:	19692903          	lw	s2,406(s2) # 80030040 <ticks>
  while(ticks - ticks0 < n){
    80002eb2:	fcc42783          	lw	a5,-52(s0)
    80002eb6:	cf85                	beqz	a5,80002eee <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002eb8:	00018997          	auipc	s3,0x18
    80002ebc:	ae898993          	addi	s3,s3,-1304 # 8001a9a0 <tickslock>
    80002ec0:	0002d497          	auipc	s1,0x2d
    80002ec4:	18048493          	addi	s1,s1,384 # 80030040 <ticks>
    if(myproc()->killed){
    80002ec8:	fffff097          	auipc	ra,0xfffff
    80002ecc:	d78080e7          	jalr	-648(ra) # 80001c40 <myproc>
    80002ed0:	5d1c                	lw	a5,56(a0)
    80002ed2:	ef9d                	bnez	a5,80002f10 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002ed4:	85ce                	mv	a1,s3
    80002ed6:	8526                	mv	a0,s1
    80002ed8:	fffff097          	auipc	ra,0xfffff
    80002edc:	53e080e7          	jalr	1342(ra) # 80002416 <sleep>
  while(ticks - ticks0 < n){
    80002ee0:	409c                	lw	a5,0(s1)
    80002ee2:	412787bb          	subw	a5,a5,s2
    80002ee6:	fcc42703          	lw	a4,-52(s0)
    80002eea:	fce7efe3          	bltu	a5,a4,80002ec8 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002eee:	00018517          	auipc	a0,0x18
    80002ef2:	ab250513          	addi	a0,a0,-1358 # 8001a9a0 <tickslock>
    80002ef6:	ffffe097          	auipc	ra,0xffffe
    80002efa:	e62080e7          	jalr	-414(ra) # 80000d58 <release>
  return 0;
    80002efe:	4781                	li	a5,0
}
    80002f00:	853e                	mv	a0,a5
    80002f02:	70e2                	ld	ra,56(sp)
    80002f04:	7442                	ld	s0,48(sp)
    80002f06:	74a2                	ld	s1,40(sp)
    80002f08:	7902                	ld	s2,32(sp)
    80002f0a:	69e2                	ld	s3,24(sp)
    80002f0c:	6121                	addi	sp,sp,64
    80002f0e:	8082                	ret
      release(&tickslock);
    80002f10:	00018517          	auipc	a0,0x18
    80002f14:	a9050513          	addi	a0,a0,-1392 # 8001a9a0 <tickslock>
    80002f18:	ffffe097          	auipc	ra,0xffffe
    80002f1c:	e40080e7          	jalr	-448(ra) # 80000d58 <release>
      return -1;
    80002f20:	57fd                	li	a5,-1
    80002f22:	bff9                	j	80002f00 <sys_sleep+0x88>

0000000080002f24 <sys_kill>:

uint64
sys_kill(void)
{
    80002f24:	1101                	addi	sp,sp,-32
    80002f26:	ec06                	sd	ra,24(sp)
    80002f28:	e822                	sd	s0,16(sp)
    80002f2a:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002f2c:	fec40593          	addi	a1,s0,-20
    80002f30:	4501                	li	a0,0
    80002f32:	00000097          	auipc	ra,0x0
    80002f36:	d86080e7          	jalr	-634(ra) # 80002cb8 <argint>
    80002f3a:	87aa                	mv	a5,a0
    return -1;
    80002f3c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002f3e:	0007c863          	bltz	a5,80002f4e <sys_kill+0x2a>
  return kill(pid);
    80002f42:	fec42503          	lw	a0,-20(s0)
    80002f46:	fffff097          	auipc	ra,0xfffff
    80002f4a:	6ba080e7          	jalr	1722(ra) # 80002600 <kill>
}
    80002f4e:	60e2                	ld	ra,24(sp)
    80002f50:	6442                	ld	s0,16(sp)
    80002f52:	6105                	addi	sp,sp,32
    80002f54:	8082                	ret

0000000080002f56 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f56:	1101                	addi	sp,sp,-32
    80002f58:	ec06                	sd	ra,24(sp)
    80002f5a:	e822                	sd	s0,16(sp)
    80002f5c:	e426                	sd	s1,8(sp)
    80002f5e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f60:	00018517          	auipc	a0,0x18
    80002f64:	a4050513          	addi	a0,a0,-1472 # 8001a9a0 <tickslock>
    80002f68:	ffffe097          	auipc	ra,0xffffe
    80002f6c:	d80080e7          	jalr	-640(ra) # 80000ce8 <acquire>
  xticks = ticks;
    80002f70:	0002d497          	auipc	s1,0x2d
    80002f74:	0d04a483          	lw	s1,208(s1) # 80030040 <ticks>
  release(&tickslock);
    80002f78:	00018517          	auipc	a0,0x18
    80002f7c:	a2850513          	addi	a0,a0,-1496 # 8001a9a0 <tickslock>
    80002f80:	ffffe097          	auipc	ra,0xffffe
    80002f84:	dd8080e7          	jalr	-552(ra) # 80000d58 <release>
  return xticks;
}
    80002f88:	02049513          	slli	a0,s1,0x20
    80002f8c:	9101                	srli	a0,a0,0x20
    80002f8e:	60e2                	ld	ra,24(sp)
    80002f90:	6442                	ld	s0,16(sp)
    80002f92:	64a2                	ld	s1,8(sp)
    80002f94:	6105                	addi	sp,sp,32
    80002f96:	8082                	ret

0000000080002f98 <getHb>:
  struct buf buckets[NBUKETS];
  struct spinlock bucketslock[NBUKETS];

} bcache;

int getHb(struct buf *b){
    80002f98:	1141                	addi	sp,sp,-16
    80002f9a:	e422                	sd	s0,8(sp)
    80002f9c:	0800                	addi	s0,sp,16
  return b->blockno % NBUKETS;
    80002f9e:	4548                	lw	a0,12(a0)
}
    80002fa0:	47b5                	li	a5,13
    80002fa2:	02f5753b          	remuw	a0,a0,a5
    80002fa6:	6422                	ld	s0,8(sp)
    80002fa8:	0141                	addi	sp,sp,16
    80002faa:	8082                	ret

0000000080002fac <getH>:

int getH(uint blockno){
    80002fac:	1141                	addi	sp,sp,-16
    80002fae:	e422                	sd	s0,8(sp)
    80002fb0:	0800                	addi	s0,sp,16
  return blockno % NBUKETS;
}
    80002fb2:	47b5                	li	a5,13
    80002fb4:	02f5753b          	remuw	a0,a0,a5
    80002fb8:	6422                	ld	s0,8(sp)
    80002fba:	0141                	addi	sp,sp,16
    80002fbc:	8082                	ret

0000000080002fbe <checkbuckets>:

void checkbuckets(){
    80002fbe:	715d                	addi	sp,sp,-80
    80002fc0:	e486                	sd	ra,72(sp)
    80002fc2:	e0a2                	sd	s0,64(sp)
    80002fc4:	fc26                	sd	s1,56(sp)
    80002fc6:	f84a                	sd	s2,48(sp)
    80002fc8:	f44e                	sd	s3,40(sp)
    80002fca:	f052                	sd	s4,32(sp)
    80002fcc:	ec56                	sd	s5,24(sp)
    80002fce:	e85a                	sd	s6,16(sp)
    80002fd0:	e45e                	sd	s7,8(sp)
    80002fd2:	e062                	sd	s8,0(sp)
    80002fd4:	0880                	addi	s0,sp,80
  struct buf *b;
  for (int i = 0; i < NBUKETS; i++)
    80002fd6:	00020a17          	auipc	s4,0x20
    80002fda:	e3aa0a13          	addi	s4,s4,-454 # 80022e10 <bcache+0x8450>
    80002fde:	4a81                	li	s5,0
  {
    printf("# bucket %d:", i);
    80002fe0:	00005c17          	auipc	s8,0x5
    80002fe4:	690c0c13          	addi	s8,s8,1680 # 80008670 <userret+0x5e0>
    for(b = bcache.buckets[i].next; b != &bcache.buckets[i]; b = b->next){
      printf("%d ",b->blockno);
    80002fe8:	00005997          	auipc	s3,0x5
    80002fec:	69898993          	addi	s3,s3,1688 # 80008680 <userret+0x5f0>
    }
    printf("\n");
    80002ff0:	00005b97          	auipc	s7,0x5
    80002ff4:	2f0b8b93          	addi	s7,s7,752 # 800082e0 <userret+0x250>
  for (int i = 0; i < NBUKETS; i++)
    80002ff8:	4b35                	li	s6,13
    80002ffa:	a819                	j	80003010 <checkbuckets+0x52>
    printf("\n");
    80002ffc:	855e                	mv	a0,s7
    80002ffe:	ffffd097          	auipc	ra,0xffffd
    80003002:	5a4080e7          	jalr	1444(ra) # 800005a2 <printf>
  for (int i = 0; i < NBUKETS; i++)
    80003006:	2a85                	addiw	s5,s5,1
    80003008:	468a0a13          	addi	s4,s4,1128
    8000300c:	036a8763          	beq	s5,s6,8000303a <checkbuckets+0x7c>
    printf("# bucket %d:", i);
    80003010:	85d6                	mv	a1,s5
    80003012:	8562                	mv	a0,s8
    80003014:	ffffd097          	auipc	ra,0xffffd
    80003018:	58e080e7          	jalr	1422(ra) # 800005a2 <printf>
    for(b = bcache.buckets[i].next; b != &bcache.buckets[i]; b = b->next){
    8000301c:	8952                	mv	s2,s4
    8000301e:	058a3483          	ld	s1,88(s4)
    80003022:	fd448de3          	beq	s1,s4,80002ffc <checkbuckets+0x3e>
      printf("%d ",b->blockno);
    80003026:	44cc                	lw	a1,12(s1)
    80003028:	854e                	mv	a0,s3
    8000302a:	ffffd097          	auipc	ra,0xffffd
    8000302e:	578080e7          	jalr	1400(ra) # 800005a2 <printf>
    for(b = bcache.buckets[i].next; b != &bcache.buckets[i]; b = b->next){
    80003032:	6ca4                	ld	s1,88(s1)
    80003034:	ff2499e3          	bne	s1,s2,80003026 <checkbuckets+0x68>
    80003038:	b7d1                	j	80002ffc <checkbuckets+0x3e>
  }
  
}
    8000303a:	60a6                	ld	ra,72(sp)
    8000303c:	6406                	ld	s0,64(sp)
    8000303e:	74e2                	ld	s1,56(sp)
    80003040:	7942                	ld	s2,48(sp)
    80003042:	79a2                	ld	s3,40(sp)
    80003044:	7a02                	ld	s4,32(sp)
    80003046:	6ae2                	ld	s5,24(sp)
    80003048:	6b42                	ld	s6,16(sp)
    8000304a:	6ba2                	ld	s7,8(sp)
    8000304c:	6c02                	ld	s8,0(sp)
    8000304e:	6161                	addi	sp,sp,80
    80003050:	8082                	ret

0000000080003052 <binit>:



void
binit(void)
{
    80003052:	711d                	addi	sp,sp,-96
    80003054:	ec86                	sd	ra,88(sp)
    80003056:	e8a2                	sd	s0,80(sp)
    80003058:	e4a6                	sd	s1,72(sp)
    8000305a:	e0ca                	sd	s2,64(sp)
    8000305c:	fc4e                	sd	s3,56(sp)
    8000305e:	f852                	sd	s4,48(sp)
    80003060:	f456                	sd	s5,40(sp)
    80003062:	f05a                	sd	s6,32(sp)
    80003064:	ec5e                	sd	s7,24(sp)
    80003066:	e862                	sd	s8,16(sp)
    80003068:	e466                	sd	s9,8(sp)
    8000306a:	e06a                	sd	s10,0(sp)
    8000306c:	1080                	addi	s0,sp,96
  struct buf *b;
  /** 在head头插入b  */
  initlock(&bcache.lock, "bcache");
    8000306e:	00005597          	auipc	a1,0x5
    80003072:	29a58593          	addi	a1,a1,666 # 80008308 <userret+0x278>
    80003076:	00018517          	auipc	a0,0x18
    8000307a:	94a50513          	addi	a0,a0,-1718 # 8001a9c0 <bcache>
    8000307e:	ffffe097          	auipc	ra,0xffffe
    80003082:	b1c080e7          	jalr	-1252(ra) # 80000b9a <initlock>
  
  for (int i = 0; i < NBUKETS; i++)
    80003086:	00023917          	auipc	s2,0x23
    8000308a:	6d290913          	addi	s2,s2,1746 # 80026758 <bcache+0xbd98>
    8000308e:	00020497          	auipc	s1,0x20
    80003092:	d8248493          	addi	s1,s1,-638 # 80022e10 <bcache+0x8450>
    80003096:	8a4a                	mv	s4,s2
  {
    initlock(&bcache.bucketslock[i], "bcache.bucket");
    80003098:	00005997          	auipc	s3,0x5
    8000309c:	5f098993          	addi	s3,s3,1520 # 80008688 <userret+0x5f8>
    800030a0:	85ce                	mv	a1,s3
    800030a2:	854a                	mv	a0,s2
    800030a4:	ffffe097          	auipc	ra,0xffffe
    800030a8:	af6080e7          	jalr	-1290(ra) # 80000b9a <initlock>
    bcache.buckets[i].prev = &bcache.buckets[i];
    800030ac:	e8a4                	sd	s1,80(s1)
    bcache.buckets[i].next = &bcache.buckets[i];
    800030ae:	eca4                	sd	s1,88(s1)
  for (int i = 0; i < NBUKETS; i++)
    800030b0:	02090913          	addi	s2,s2,32
    800030b4:	46848493          	addi	s1,s1,1128
    800030b8:	ff4494e3          	bne	s1,s4,800030a0 <binit+0x4e>
  }

  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    800030bc:	00018497          	auipc	s1,0x18
    800030c0:	92448493          	addi	s1,s1,-1756 # 8001a9e0 <bcache+0x20>
  return b->blockno % NBUKETS;
    800030c4:	4d35                	li	s10,13
  {
    int hash = getHb(b);
    b->time_stamp = ticks;
    800030c6:	0002dc97          	auipc	s9,0x2d
    800030ca:	f7ac8c93          	addi	s9,s9,-134 # 80030040 <ticks>
    b->next = bcache.buckets[hash].next;
    800030ce:	00018997          	auipc	s3,0x18
    800030d2:	8f298993          	addi	s3,s3,-1806 # 8001a9c0 <bcache>
    800030d6:	46800c13          	li	s8,1128
    800030da:	6a21                	lui	s4,0x8
    b->prev = &bcache.buckets[hash];
    800030dc:	450a0b93          	addi	s7,s4,1104 # 8450 <_entry-0x7fff7bb0>
    initsleeplock(&b->lock, "buffer");
    800030e0:	00005b17          	auipc	s6,0x5
    800030e4:	5b8b0b13          	addi	s6,s6,1464 # 80008698 <userret+0x608>
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    800030e8:	00020a97          	auipc	s5,0x20
    800030ec:	d28a8a93          	addi	s5,s5,-728 # 80022e10 <bcache+0x8450>
  return b->blockno % NBUKETS;
    800030f0:	44dc                	lw	a5,12(s1)
    800030f2:	03a7f7bb          	remuw	a5,a5,s10
    b->time_stamp = ticks;
    800030f6:	000ca703          	lw	a4,0(s9)
    800030fa:	46e4a023          	sw	a4,1120(s1)
    b->next = bcache.buckets[hash].next;
    800030fe:	038787b3          	mul	a5,a5,s8
    80003102:	00f98933          	add	s2,s3,a5
    80003106:	9952                	add	s2,s2,s4
    80003108:	4a893703          	ld	a4,1192(s2)
    8000310c:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.buckets[hash];
    8000310e:	97de                	add	a5,a5,s7
    80003110:	97ce                	add	a5,a5,s3
    80003112:	e8bc                	sd	a5,80(s1)
    initsleeplock(&b->lock, "buffer");
    80003114:	85da                	mv	a1,s6
    80003116:	01048513          	addi	a0,s1,16
    8000311a:	00001097          	auipc	ra,0x1
    8000311e:	634080e7          	jalr	1588(ra) # 8000474e <initsleeplock>
    bcache.buckets[hash].next->prev = b;
    80003122:	4a893783          	ld	a5,1192(s2)
    80003126:	eba4                	sd	s1,80(a5)
    bcache.buckets[hash].next = b;
    80003128:	4a993423          	sd	s1,1192(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
    8000312c:	46848493          	addi	s1,s1,1128
    80003130:	fd5490e3          	bne	s1,s5,800030f0 <binit+0x9e>
  }
}
    80003134:	60e6                	ld	ra,88(sp)
    80003136:	6446                	ld	s0,80(sp)
    80003138:	64a6                	ld	s1,72(sp)
    8000313a:	6906                	ld	s2,64(sp)
    8000313c:	79e2                	ld	s3,56(sp)
    8000313e:	7a42                	ld	s4,48(sp)
    80003140:	7aa2                	ld	s5,40(sp)
    80003142:	7b02                	ld	s6,32(sp)
    80003144:	6be2                	ld	s7,24(sp)
    80003146:	6c42                	ld	s8,16(sp)
    80003148:	6ca2                	ld	s9,8(sp)
    8000314a:	6d02                	ld	s10,0(sp)
    8000314c:	6125                	addi	sp,sp,96
    8000314e:	8082                	ret

0000000080003150 <bread>:
// Bread (kernel/bio.c:91) calls bget to get a buffer for the given sector (kernel/bio.c:95). If the
// buffer needs to be read from disk, bread calls virtio_disk_rw to do that before returning the
// buffer.
struct buf*
bread(uint dev, uint blockno)
{
    80003150:	7159                	addi	sp,sp,-112
    80003152:	f486                	sd	ra,104(sp)
    80003154:	f0a2                	sd	s0,96(sp)
    80003156:	eca6                	sd	s1,88(sp)
    80003158:	e8ca                	sd	s2,80(sp)
    8000315a:	e4ce                	sd	s3,72(sp)
    8000315c:	e0d2                	sd	s4,64(sp)
    8000315e:	fc56                	sd	s5,56(sp)
    80003160:	f85a                	sd	s6,48(sp)
    80003162:	f45e                	sd	s7,40(sp)
    80003164:	f062                	sd	s8,32(sp)
    80003166:	ec66                	sd	s9,24(sp)
    80003168:	e86a                	sd	s10,16(sp)
    8000316a:	e46e                	sd	s11,8(sp)
    8000316c:	1880                	addi	s0,sp,112
    8000316e:	89aa                	mv	s3,a0
    80003170:	8b2e                	mv	s6,a1
  return blockno % NBUKETS;
    80003172:	4ab5                	li	s5,13
    80003174:	0355fabb          	remuw	s5,a1,s5
  acquire(&bcache.bucketslock[hash]);
    80003178:	005a9c93          	slli	s9,s5,0x5
    8000317c:	67b1                	lui	a5,0xc
    8000317e:	d9878793          	addi	a5,a5,-616 # bd98 <_entry-0x7fff4268>
    80003182:	9cbe                	add	s9,s9,a5
    80003184:	00018a17          	auipc	s4,0x18
    80003188:	83ca0a13          	addi	s4,s4,-1988 # 8001a9c0 <bcache>
    8000318c:	9cd2                	add	s9,s9,s4
    8000318e:	8566                	mv	a0,s9
    80003190:	ffffe097          	auipc	ra,0xffffe
    80003194:	b58080e7          	jalr	-1192(ra) # 80000ce8 <acquire>
  for(b = bcache.buckets[hash].next; b != &bcache.buckets[hash]; b = b->next){
    80003198:	46800793          	li	a5,1128
    8000319c:	02fa87b3          	mul	a5,s5,a5
    800031a0:	00fa06b3          	add	a3,s4,a5
    800031a4:	6721                	lui	a4,0x8
    800031a6:	96ba                	add	a3,a3,a4
    800031a8:	4a86b483          	ld	s1,1192(a3)
    800031ac:	45070913          	addi	s2,a4,1104 # 8450 <_entry-0x7fff7bb0>
    800031b0:	97ca                	add	a5,a5,s2
    800031b2:	01478933          	add	s2,a5,s4
    800031b6:	03249063          	bne	s1,s2,800031d6 <bread+0x86>
  for (int i = 0; i < NBUKETS; i++)
    800031ba:	00023c17          	auipc	s8,0x23
    800031be:	59ec0c13          	addi	s8,s8,1438 # 80026758 <bcache+0xbd98>
    800031c2:	00020b97          	auipc	s7,0x20
    800031c6:	c4eb8b93          	addi	s7,s7,-946 # 80022e10 <bcache+0x8450>
    800031ca:	4a01                	li	s4,0
    800031cc:	4d35                	li	s10,13
    800031ce:	a0f5                	j	800032ba <bread+0x16a>
  for(b = bcache.buckets[hash].next; b != &bcache.buckets[hash]; b = b->next){
    800031d0:	6ca4                	ld	s1,88(s1)
    800031d2:	ff2484e3          	beq	s1,s2,800031ba <bread+0x6a>
    if(b->dev == dev && b->blockno == blockno){
    800031d6:	449c                	lw	a5,8(s1)
    800031d8:	ff379ce3          	bne	a5,s3,800031d0 <bread+0x80>
    800031dc:	44dc                	lw	a5,12(s1)
    800031de:	ff6799e3          	bne	a5,s6,800031d0 <bread+0x80>
      b->time_stamp = ticks;
    800031e2:	0002d797          	auipc	a5,0x2d
    800031e6:	e5e7a783          	lw	a5,-418(a5) # 80030040 <ticks>
    800031ea:	46f4a023          	sw	a5,1120(s1)
      b->refcnt++;
    800031ee:	44bc                	lw	a5,72(s1)
    800031f0:	2785                	addiw	a5,a5,1
    800031f2:	c4bc                	sw	a5,72(s1)
      release(&bcache.bucketslock[hash]);
    800031f4:	8566                	mv	a0,s9
    800031f6:	ffffe097          	auipc	ra,0xffffe
    800031fa:	b62080e7          	jalr	-1182(ra) # 80000d58 <release>
      acquiresleep(&b->lock);
    800031fe:	01048513          	addi	a0,s1,16
    80003202:	00001097          	auipc	ra,0x1
    80003206:	586080e7          	jalr	1414(ra) # 80004788 <acquiresleep>
      return b;
    8000320a:	a895                	j	8000327e <bread+0x12e>
          b->time_stamp = ticks;
    8000320c:	0002d797          	auipc	a5,0x2d
    80003210:	e347a783          	lw	a5,-460(a5) # 80030040 <ticks>
    80003214:	46f4a023          	sw	a5,1120(s1)
          b->dev = dev;
    80003218:	0134a423          	sw	s3,8(s1)
          b->blockno = blockno;
    8000321c:	0164a623          	sw	s6,12(s1)
          b->valid = 0;     //important  
    80003220:	0004a023          	sw	zero,0(s1)
          b->refcnt = 1;
    80003224:	4785                	li	a5,1
    80003226:	c4bc                	sw	a5,72(s1)
          b->next->prev = b->prev;
    80003228:	6cbc                	ld	a5,88(s1)
    8000322a:	68b8                	ld	a4,80(s1)
    8000322c:	ebb8                	sd	a4,80(a5)
          b->prev->next = b->next;
    8000322e:	68bc                	ld	a5,80(s1)
    80003230:	6cb8                	ld	a4,88(s1)
    80003232:	efb8                	sd	a4,88(a5)
          b->next = bcache.buckets[hash].next;
    80003234:	46800793          	li	a5,1128
    80003238:	02fa8ab3          	mul	s5,s5,a5
    8000323c:	00017797          	auipc	a5,0x17
    80003240:	78478793          	addi	a5,a5,1924 # 8001a9c0 <bcache>
    80003244:	97d6                	add	a5,a5,s5
    80003246:	6aa1                	lui	s5,0x8
    80003248:	9abe                	add	s5,s5,a5
    8000324a:	4a8ab783          	ld	a5,1192(s5) # 84a8 <_entry-0x7fff7b58>
    8000324e:	ecbc                	sd	a5,88(s1)
          b->prev = &bcache.buckets[hash];
    80003250:	0524b823          	sd	s2,80(s1)
          bcache.buckets[hash].next->prev = b;
    80003254:	4a8ab783          	ld	a5,1192(s5)
    80003258:	eba4                	sd	s1,80(a5)
          bcache.buckets[hash].next = b;
    8000325a:	4a9ab423          	sd	s1,1192(s5)
          release(&bcache.bucketslock[i]);
    8000325e:	856e                	mv	a0,s11
    80003260:	ffffe097          	auipc	ra,0xffffe
    80003264:	af8080e7          	jalr	-1288(ra) # 80000d58 <release>
          release(&bcache.bucketslock[hash]);
    80003268:	8566                	mv	a0,s9
    8000326a:	ffffe097          	auipc	ra,0xffffe
    8000326e:	aee080e7          	jalr	-1298(ra) # 80000d58 <release>
          acquiresleep(&b->lock);
    80003272:	01048513          	addi	a0,s1,16
    80003276:	00001097          	auipc	ra,0x1
    8000327a:	512080e7          	jalr	1298(ra) # 80004788 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000327e:	409c                	lw	a5,0(s1)
    80003280:	cba5                	beqz	a5,800032f0 <bread+0x1a0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80003282:	8526                	mv	a0,s1
    80003284:	70a6                	ld	ra,104(sp)
    80003286:	7406                	ld	s0,96(sp)
    80003288:	64e6                	ld	s1,88(sp)
    8000328a:	6946                	ld	s2,80(sp)
    8000328c:	69a6                	ld	s3,72(sp)
    8000328e:	6a06                	ld	s4,64(sp)
    80003290:	7ae2                	ld	s5,56(sp)
    80003292:	7b42                	ld	s6,48(sp)
    80003294:	7ba2                	ld	s7,40(sp)
    80003296:	7c02                	ld	s8,32(sp)
    80003298:	6ce2                	ld	s9,24(sp)
    8000329a:	6d42                	ld	s10,16(sp)
    8000329c:	6da2                	ld	s11,8(sp)
    8000329e:	6165                	addi	sp,sp,112
    800032a0:	8082                	ret
      release(&bcache.bucketslock[i]);
    800032a2:	856e                	mv	a0,s11
    800032a4:	ffffe097          	auipc	ra,0xffffe
    800032a8:	ab4080e7          	jalr	-1356(ra) # 80000d58 <release>
  for (int i = 0; i < NBUKETS; i++)
    800032ac:	2a05                	addiw	s4,s4,1
    800032ae:	020c0c13          	addi	s8,s8,32
    800032b2:	468b8b93          	addi	s7,s7,1128
    800032b6:	03aa0563          	beq	s4,s10,800032e0 <bread+0x190>
    if(i != hash){
    800032ba:	ff4a89e3          	beq	s5,s4,800032ac <bread+0x15c>
      acquire(&bcache.bucketslock[i]);
    800032be:	8de2                	mv	s11,s8
    800032c0:	8562                	mv	a0,s8
    800032c2:	ffffe097          	auipc	ra,0xffffe
    800032c6:	a26080e7          	jalr	-1498(ra) # 80000ce8 <acquire>
      for(b = bcache.buckets[i].prev; b != &bcache.buckets[i]; b = b->prev){
    800032ca:	875e                	mv	a4,s7
    800032cc:	050bb483          	ld	s1,80(s7)
    800032d0:	fd7489e3          	beq	s1,s7,800032a2 <bread+0x152>
        if(b->refcnt == 0){
    800032d4:	44bc                	lw	a5,72(s1)
    800032d6:	db9d                	beqz	a5,8000320c <bread+0xbc>
      for(b = bcache.buckets[i].prev; b != &bcache.buckets[i]; b = b->prev){
    800032d8:	68a4                	ld	s1,80(s1)
    800032da:	fee49de3          	bne	s1,a4,800032d4 <bread+0x184>
    800032de:	b7d1                	j	800032a2 <bread+0x152>
  panic("bget: no buffers");
    800032e0:	00005517          	auipc	a0,0x5
    800032e4:	3c050513          	addi	a0,a0,960 # 800086a0 <userret+0x610>
    800032e8:	ffffd097          	auipc	ra,0xffffd
    800032ec:	260080e7          	jalr	608(ra) # 80000548 <panic>
    virtio_disk_rw(b->dev, b, 0);
    800032f0:	4601                	li	a2,0
    800032f2:	85a6                	mv	a1,s1
    800032f4:	4488                	lw	a0,8(s1)
    800032f6:	00003097          	auipc	ra,0x3
    800032fa:	0d4080e7          	jalr	212(ra) # 800063ca <virtio_disk_rw>
    b->valid = 1;
    800032fe:	4785                	li	a5,1
    80003300:	c09c                	sw	a5,0(s1)
  return b;
    80003302:	b741                	j	80003282 <bread+0x132>

0000000080003304 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003304:	1101                	addi	sp,sp,-32
    80003306:	ec06                	sd	ra,24(sp)
    80003308:	e822                	sd	s0,16(sp)
    8000330a:	e426                	sd	s1,8(sp)
    8000330c:	1000                	addi	s0,sp,32
    8000330e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003310:	0541                	addi	a0,a0,16
    80003312:	00001097          	auipc	ra,0x1
    80003316:	510080e7          	jalr	1296(ra) # 80004822 <holdingsleep>
    8000331a:	cd09                	beqz	a0,80003334 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    8000331c:	4605                	li	a2,1
    8000331e:	85a6                	mv	a1,s1
    80003320:	4488                	lw	a0,8(s1)
    80003322:	00003097          	auipc	ra,0x3
    80003326:	0a8080e7          	jalr	168(ra) # 800063ca <virtio_disk_rw>
}
    8000332a:	60e2                	ld	ra,24(sp)
    8000332c:	6442                	ld	s0,16(sp)
    8000332e:	64a2                	ld	s1,8(sp)
    80003330:	6105                	addi	sp,sp,32
    80003332:	8082                	ret
    panic("bwrite");
    80003334:	00005517          	auipc	a0,0x5
    80003338:	38450513          	addi	a0,a0,900 # 800086b8 <userret+0x628>
    8000333c:	ffffd097          	auipc	ra,0xffffd
    80003340:	20c080e7          	jalr	524(ra) # 80000548 <panic>

0000000080003344 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80003344:	1101                	addi	sp,sp,-32
    80003346:	ec06                	sd	ra,24(sp)
    80003348:	e822                	sd	s0,16(sp)
    8000334a:	e426                	sd	s1,8(sp)
    8000334c:	e04a                	sd	s2,0(sp)
    8000334e:	1000                	addi	s0,sp,32
    80003350:	84aa                	mv	s1,a0
  //printf("#---------------------------------------- brelse! ----------------------------------------\n");
  if(!holdingsleep(&b->lock))
    80003352:	01050913          	addi	s2,a0,16
    80003356:	854a                	mv	a0,s2
    80003358:	00001097          	auipc	ra,0x1
    8000335c:	4ca080e7          	jalr	1226(ra) # 80004822 <holdingsleep>
    80003360:	c93d                	beqz	a0,800033d6 <brelse+0x92>
    panic("brelse");

  releasesleep(&b->lock);
    80003362:	854a                	mv	a0,s2
    80003364:	00001097          	auipc	ra,0x1
    80003368:	47a080e7          	jalr	1146(ra) # 800047de <releasesleep>
  return b->blockno % NBUKETS;
    8000336c:	44dc                	lw	a5,12(s1)
  int blockno = getHb(b);
  b->time_stamp = ticks;
    8000336e:	0002d717          	auipc	a4,0x2d
    80003372:	cd272703          	lw	a4,-814(a4) # 80030040 <ticks>
    80003376:	46e4a023          	sw	a4,1120(s1)
  if(b->time_stamp == ticks){
    b->refcnt--;
    8000337a:	44b8                	lw	a4,72(s1)
    8000337c:	377d                	addiw	a4,a4,-1
    8000337e:	0007069b          	sext.w	a3,a4
    80003382:	c4b8                	sw	a4,72(s1)
    if(b->refcnt == 0){
    80003384:	e2b9                	bnez	a3,800033ca <brelse+0x86>
  return b->blockno % NBUKETS;
    80003386:	4735                	li	a4,13
    80003388:	02e7f7bb          	remuw	a5,a5,a4
      /** 将b脱出  */
      b->next->prev = b->prev;
    8000338c:	6cb8                	ld	a4,88(s1)
    8000338e:	68b4                	ld	a3,80(s1)
    80003390:	eb34                	sd	a3,80(a4)
      b->prev->next = b->next;
    80003392:	68b8                	ld	a4,80(s1)
    80003394:	6cb4                	ld	a3,88(s1)
    80003396:	ef34                	sd	a3,88(a4)
      
      /** 将b接入  */
      b->next = bcache.buckets[blockno].next;
    80003398:	00017617          	auipc	a2,0x17
    8000339c:	62860613          	addi	a2,a2,1576 # 8001a9c0 <bcache>
    800033a0:	46800713          	li	a4,1128
    800033a4:	02e787b3          	mul	a5,a5,a4
    800033a8:	00f60733          	add	a4,a2,a5
    800033ac:	66a1                	lui	a3,0x8
    800033ae:	9736                	add	a4,a4,a3
    800033b0:	4a873583          	ld	a1,1192(a4)
    800033b4:	ecac                	sd	a1,88(s1)
      b->prev = &bcache.buckets[blockno];
    800033b6:	45068693          	addi	a3,a3,1104 # 8450 <_entry-0x7fff7bb0>
    800033ba:	97b6                	add	a5,a5,a3
    800033bc:	97b2                	add	a5,a5,a2
    800033be:	e8bc                	sd	a5,80(s1)
      bcache.buckets[blockno].next->prev = b;
    800033c0:	4a873783          	ld	a5,1192(a4)
    800033c4:	eba4                	sd	s1,80(a5)
      bcache.buckets[blockno].next = b;
    800033c6:	4a973423          	sd	s1,1192(a4)
    }
  }
}
    800033ca:	60e2                	ld	ra,24(sp)
    800033cc:	6442                	ld	s0,16(sp)
    800033ce:	64a2                	ld	s1,8(sp)
    800033d0:	6902                	ld	s2,0(sp)
    800033d2:	6105                	addi	sp,sp,32
    800033d4:	8082                	ret
    panic("brelse");
    800033d6:	00005517          	auipc	a0,0x5
    800033da:	2ea50513          	addi	a0,a0,746 # 800086c0 <userret+0x630>
    800033de:	ffffd097          	auipc	ra,0xffffd
    800033e2:	16a080e7          	jalr	362(ra) # 80000548 <panic>

00000000800033e6 <bpin>:

void
bpin(struct buf *b) {
    800033e6:	1141                	addi	sp,sp,-16
    800033e8:	e422                	sd	s0,8(sp)
    800033ea:	0800                	addi	s0,sp,16
  //printf("see if bpin work\n");
  //int hash = getHb(b);
  b->time_stamp = ticks;
    800033ec:	0002d797          	auipc	a5,0x2d
    800033f0:	c547a783          	lw	a5,-940(a5) # 80030040 <ticks>
    800033f4:	46f52023          	sw	a5,1120(a0)
  if(b->time_stamp == ticks)
    b->refcnt++;
    800033f8:	453c                	lw	a5,72(a0)
    800033fa:	2785                	addiw	a5,a5,1
    800033fc:	c53c                	sw	a5,72(a0)
}
    800033fe:	6422                	ld	s0,8(sp)
    80003400:	0141                	addi	sp,sp,16
    80003402:	8082                	ret

0000000080003404 <bunpin>:

void
bunpin(struct buf *b) {
    80003404:	1141                	addi	sp,sp,-16
    80003406:	e422                	sd	s0,8(sp)
    80003408:	0800                	addi	s0,sp,16
  //printf("see if bunpin work\n");
  b->time_stamp = ticks;
    8000340a:	0002d797          	auipc	a5,0x2d
    8000340e:	c367a783          	lw	a5,-970(a5) # 80030040 <ticks>
    80003412:	46f52023          	sw	a5,1120(a0)
  if(b->time_stamp == ticks)
    b->refcnt--;
    80003416:	453c                	lw	a5,72(a0)
    80003418:	37fd                	addiw	a5,a5,-1
    8000341a:	c53c                	sw	a5,72(a0)
}
    8000341c:	6422                	ld	s0,8(sp)
    8000341e:	0141                	addi	sp,sp,16
    80003420:	8082                	ret

0000000080003422 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003422:	1101                	addi	sp,sp,-32
    80003424:	ec06                	sd	ra,24(sp)
    80003426:	e822                	sd	s0,16(sp)
    80003428:	e426                	sd	s1,8(sp)
    8000342a:	e04a                	sd	s2,0(sp)
    8000342c:	1000                	addi	s0,sp,32
    8000342e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003430:	00d5d59b          	srliw	a1,a1,0xd
    80003434:	00023797          	auipc	a5,0x23
    80003438:	4e07a783          	lw	a5,1248(a5) # 80026914 <sb+0x1c>
    8000343c:	9dbd                	addw	a1,a1,a5
    8000343e:	00000097          	auipc	ra,0x0
    80003442:	d12080e7          	jalr	-750(ra) # 80003150 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003446:	0074f713          	andi	a4,s1,7
    8000344a:	4785                	li	a5,1
    8000344c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003450:	14ce                	slli	s1,s1,0x33
    80003452:	90d9                	srli	s1,s1,0x36
    80003454:	00950733          	add	a4,a0,s1
    80003458:	06074703          	lbu	a4,96(a4)
    8000345c:	00e7f6b3          	and	a3,a5,a4
    80003460:	c69d                	beqz	a3,8000348e <bfree+0x6c>
    80003462:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003464:	94aa                	add	s1,s1,a0
    80003466:	fff7c793          	not	a5,a5
    8000346a:	8ff9                	and	a5,a5,a4
    8000346c:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80003470:	00001097          	auipc	ra,0x1
    80003474:	19e080e7          	jalr	414(ra) # 8000460e <log_write>
  brelse(bp);
    80003478:	854a                	mv	a0,s2
    8000347a:	00000097          	auipc	ra,0x0
    8000347e:	eca080e7          	jalr	-310(ra) # 80003344 <brelse>
}
    80003482:	60e2                	ld	ra,24(sp)
    80003484:	6442                	ld	s0,16(sp)
    80003486:	64a2                	ld	s1,8(sp)
    80003488:	6902                	ld	s2,0(sp)
    8000348a:	6105                	addi	sp,sp,32
    8000348c:	8082                	ret
    panic("freeing free block");
    8000348e:	00005517          	auipc	a0,0x5
    80003492:	23a50513          	addi	a0,a0,570 # 800086c8 <userret+0x638>
    80003496:	ffffd097          	auipc	ra,0xffffd
    8000349a:	0b2080e7          	jalr	178(ra) # 80000548 <panic>

000000008000349e <balloc>:
{
    8000349e:	711d                	addi	sp,sp,-96
    800034a0:	ec86                	sd	ra,88(sp)
    800034a2:	e8a2                	sd	s0,80(sp)
    800034a4:	e4a6                	sd	s1,72(sp)
    800034a6:	e0ca                	sd	s2,64(sp)
    800034a8:	fc4e                	sd	s3,56(sp)
    800034aa:	f852                	sd	s4,48(sp)
    800034ac:	f456                	sd	s5,40(sp)
    800034ae:	f05a                	sd	s6,32(sp)
    800034b0:	ec5e                	sd	s7,24(sp)
    800034b2:	e862                	sd	s8,16(sp)
    800034b4:	e466                	sd	s9,8(sp)
    800034b6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034b8:	00023797          	auipc	a5,0x23
    800034bc:	4447a783          	lw	a5,1092(a5) # 800268fc <sb+0x4>
    800034c0:	cbd1                	beqz	a5,80003554 <balloc+0xb6>
    800034c2:	8baa                	mv	s7,a0
    800034c4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034c6:	00023b17          	auipc	s6,0x23
    800034ca:	432b0b13          	addi	s6,s6,1074 # 800268f8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ce:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034d0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034d2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034d4:	6c89                	lui	s9,0x2
    800034d6:	a831                	j	800034f2 <balloc+0x54>
    brelse(bp);
    800034d8:	854a                	mv	a0,s2
    800034da:	00000097          	auipc	ra,0x0
    800034de:	e6a080e7          	jalr	-406(ra) # 80003344 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034e2:	015c87bb          	addw	a5,s9,s5
    800034e6:	00078a9b          	sext.w	s5,a5
    800034ea:	004b2703          	lw	a4,4(s6)
    800034ee:	06eaf363          	bgeu	s5,a4,80003554 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800034f2:	41fad79b          	sraiw	a5,s5,0x1f
    800034f6:	0137d79b          	srliw	a5,a5,0x13
    800034fa:	015787bb          	addw	a5,a5,s5
    800034fe:	40d7d79b          	sraiw	a5,a5,0xd
    80003502:	01cb2583          	lw	a1,28(s6)
    80003506:	9dbd                	addw	a1,a1,a5
    80003508:	855e                	mv	a0,s7
    8000350a:	00000097          	auipc	ra,0x0
    8000350e:	c46080e7          	jalr	-954(ra) # 80003150 <bread>
    80003512:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003514:	004b2503          	lw	a0,4(s6)
    80003518:	000a849b          	sext.w	s1,s5
    8000351c:	8662                	mv	a2,s8
    8000351e:	faa4fde3          	bgeu	s1,a0,800034d8 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003522:	41f6579b          	sraiw	a5,a2,0x1f
    80003526:	01d7d69b          	srliw	a3,a5,0x1d
    8000352a:	00c6873b          	addw	a4,a3,a2
    8000352e:	00777793          	andi	a5,a4,7
    80003532:	9f95                	subw	a5,a5,a3
    80003534:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003538:	4037571b          	sraiw	a4,a4,0x3
    8000353c:	00e906b3          	add	a3,s2,a4
    80003540:	0606c683          	lbu	a3,96(a3)
    80003544:	00d7f5b3          	and	a1,a5,a3
    80003548:	cd91                	beqz	a1,80003564 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000354a:	2605                	addiw	a2,a2,1
    8000354c:	2485                	addiw	s1,s1,1
    8000354e:	fd4618e3          	bne	a2,s4,8000351e <balloc+0x80>
    80003552:	b759                	j	800034d8 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003554:	00005517          	auipc	a0,0x5
    80003558:	18c50513          	addi	a0,a0,396 # 800086e0 <userret+0x650>
    8000355c:	ffffd097          	auipc	ra,0xffffd
    80003560:	fec080e7          	jalr	-20(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003564:	974a                	add	a4,a4,s2
    80003566:	8fd5                	or	a5,a5,a3
    80003568:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    8000356c:	854a                	mv	a0,s2
    8000356e:	00001097          	auipc	ra,0x1
    80003572:	0a0080e7          	jalr	160(ra) # 8000460e <log_write>
        brelse(bp);
    80003576:	854a                	mv	a0,s2
    80003578:	00000097          	auipc	ra,0x0
    8000357c:	dcc080e7          	jalr	-564(ra) # 80003344 <brelse>
  bp = bread(dev, bno);
    80003580:	85a6                	mv	a1,s1
    80003582:	855e                	mv	a0,s7
    80003584:	00000097          	auipc	ra,0x0
    80003588:	bcc080e7          	jalr	-1076(ra) # 80003150 <bread>
    8000358c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000358e:	40000613          	li	a2,1024
    80003592:	4581                	li	a1,0
    80003594:	06050513          	addi	a0,a0,96
    80003598:	ffffe097          	auipc	ra,0xffffe
    8000359c:	9be080e7          	jalr	-1602(ra) # 80000f56 <memset>
  log_write(bp);
    800035a0:	854a                	mv	a0,s2
    800035a2:	00001097          	auipc	ra,0x1
    800035a6:	06c080e7          	jalr	108(ra) # 8000460e <log_write>
  brelse(bp);
    800035aa:	854a                	mv	a0,s2
    800035ac:	00000097          	auipc	ra,0x0
    800035b0:	d98080e7          	jalr	-616(ra) # 80003344 <brelse>
}
    800035b4:	8526                	mv	a0,s1
    800035b6:	60e6                	ld	ra,88(sp)
    800035b8:	6446                	ld	s0,80(sp)
    800035ba:	64a6                	ld	s1,72(sp)
    800035bc:	6906                	ld	s2,64(sp)
    800035be:	79e2                	ld	s3,56(sp)
    800035c0:	7a42                	ld	s4,48(sp)
    800035c2:	7aa2                	ld	s5,40(sp)
    800035c4:	7b02                	ld	s6,32(sp)
    800035c6:	6be2                	ld	s7,24(sp)
    800035c8:	6c42                	ld	s8,16(sp)
    800035ca:	6ca2                	ld	s9,8(sp)
    800035cc:	6125                	addi	sp,sp,96
    800035ce:	8082                	ret

00000000800035d0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800035d0:	7179                	addi	sp,sp,-48
    800035d2:	f406                	sd	ra,40(sp)
    800035d4:	f022                	sd	s0,32(sp)
    800035d6:	ec26                	sd	s1,24(sp)
    800035d8:	e84a                	sd	s2,16(sp)
    800035da:	e44e                	sd	s3,8(sp)
    800035dc:	e052                	sd	s4,0(sp)
    800035de:	1800                	addi	s0,sp,48
    800035e0:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035e2:	47ad                	li	a5,11
    800035e4:	04b7fe63          	bgeu	a5,a1,80003640 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800035e8:	ff45849b          	addiw	s1,a1,-12
    800035ec:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035f0:	0ff00793          	li	a5,255
    800035f4:	0ae7e363          	bltu	a5,a4,8000369a <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800035f8:	08852583          	lw	a1,136(a0)
    800035fc:	c5ad                	beqz	a1,80003666 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800035fe:	00092503          	lw	a0,0(s2)
    80003602:	00000097          	auipc	ra,0x0
    80003606:	b4e080e7          	jalr	-1202(ra) # 80003150 <bread>
    8000360a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000360c:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003610:	02049593          	slli	a1,s1,0x20
    80003614:	9181                	srli	a1,a1,0x20
    80003616:	058a                	slli	a1,a1,0x2
    80003618:	00b784b3          	add	s1,a5,a1
    8000361c:	0004a983          	lw	s3,0(s1)
    80003620:	04098d63          	beqz	s3,8000367a <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003624:	8552                	mv	a0,s4
    80003626:	00000097          	auipc	ra,0x0
    8000362a:	d1e080e7          	jalr	-738(ra) # 80003344 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000362e:	854e                	mv	a0,s3
    80003630:	70a2                	ld	ra,40(sp)
    80003632:	7402                	ld	s0,32(sp)
    80003634:	64e2                	ld	s1,24(sp)
    80003636:	6942                	ld	s2,16(sp)
    80003638:	69a2                	ld	s3,8(sp)
    8000363a:	6a02                	ld	s4,0(sp)
    8000363c:	6145                	addi	sp,sp,48
    8000363e:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003640:	02059493          	slli	s1,a1,0x20
    80003644:	9081                	srli	s1,s1,0x20
    80003646:	048a                	slli	s1,s1,0x2
    80003648:	94aa                	add	s1,s1,a0
    8000364a:	0584a983          	lw	s3,88(s1)
    8000364e:	fe0990e3          	bnez	s3,8000362e <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003652:	4108                	lw	a0,0(a0)
    80003654:	00000097          	auipc	ra,0x0
    80003658:	e4a080e7          	jalr	-438(ra) # 8000349e <balloc>
    8000365c:	0005099b          	sext.w	s3,a0
    80003660:	0534ac23          	sw	s3,88(s1)
    80003664:	b7e9                	j	8000362e <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003666:	4108                	lw	a0,0(a0)
    80003668:	00000097          	auipc	ra,0x0
    8000366c:	e36080e7          	jalr	-458(ra) # 8000349e <balloc>
    80003670:	0005059b          	sext.w	a1,a0
    80003674:	08b92423          	sw	a1,136(s2)
    80003678:	b759                	j	800035fe <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000367a:	00092503          	lw	a0,0(s2)
    8000367e:	00000097          	auipc	ra,0x0
    80003682:	e20080e7          	jalr	-480(ra) # 8000349e <balloc>
    80003686:	0005099b          	sext.w	s3,a0
    8000368a:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000368e:	8552                	mv	a0,s4
    80003690:	00001097          	auipc	ra,0x1
    80003694:	f7e080e7          	jalr	-130(ra) # 8000460e <log_write>
    80003698:	b771                	j	80003624 <bmap+0x54>
  panic("bmap: out of range");
    8000369a:	00005517          	auipc	a0,0x5
    8000369e:	05e50513          	addi	a0,a0,94 # 800086f8 <userret+0x668>
    800036a2:	ffffd097          	auipc	ra,0xffffd
    800036a6:	ea6080e7          	jalr	-346(ra) # 80000548 <panic>

00000000800036aa <iget>:
{
    800036aa:	7179                	addi	sp,sp,-48
    800036ac:	f406                	sd	ra,40(sp)
    800036ae:	f022                	sd	s0,32(sp)
    800036b0:	ec26                	sd	s1,24(sp)
    800036b2:	e84a                	sd	s2,16(sp)
    800036b4:	e44e                	sd	s3,8(sp)
    800036b6:	e052                	sd	s4,0(sp)
    800036b8:	1800                	addi	s0,sp,48
    800036ba:	89aa                	mv	s3,a0
    800036bc:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800036be:	00023517          	auipc	a0,0x23
    800036c2:	25a50513          	addi	a0,a0,602 # 80026918 <icache>
    800036c6:	ffffd097          	auipc	ra,0xffffd
    800036ca:	622080e7          	jalr	1570(ra) # 80000ce8 <acquire>
  empty = 0;
    800036ce:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800036d0:	00023497          	auipc	s1,0x23
    800036d4:	26848493          	addi	s1,s1,616 # 80026938 <icache+0x20>
    800036d8:	00025697          	auipc	a3,0x25
    800036dc:	e8068693          	addi	a3,a3,-384 # 80028558 <log>
    800036e0:	a039                	j	800036ee <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036e2:	02090b63          	beqz	s2,80003718 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800036e6:	09048493          	addi	s1,s1,144
    800036ea:	02d48a63          	beq	s1,a3,8000371e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036ee:	449c                	lw	a5,8(s1)
    800036f0:	fef059e3          	blez	a5,800036e2 <iget+0x38>
    800036f4:	4098                	lw	a4,0(s1)
    800036f6:	ff3716e3          	bne	a4,s3,800036e2 <iget+0x38>
    800036fa:	40d8                	lw	a4,4(s1)
    800036fc:	ff4713e3          	bne	a4,s4,800036e2 <iget+0x38>
      ip->ref++;
    80003700:	2785                	addiw	a5,a5,1
    80003702:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003704:	00023517          	auipc	a0,0x23
    80003708:	21450513          	addi	a0,a0,532 # 80026918 <icache>
    8000370c:	ffffd097          	auipc	ra,0xffffd
    80003710:	64c080e7          	jalr	1612(ra) # 80000d58 <release>
      return ip;
    80003714:	8926                	mv	s2,s1
    80003716:	a03d                	j	80003744 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003718:	f7f9                	bnez	a5,800036e6 <iget+0x3c>
    8000371a:	8926                	mv	s2,s1
    8000371c:	b7e9                	j	800036e6 <iget+0x3c>
  if(empty == 0)
    8000371e:	02090c63          	beqz	s2,80003756 <iget+0xac>
  ip->dev = dev;
    80003722:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003726:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000372a:	4785                	li	a5,1
    8000372c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003730:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    80003734:	00023517          	auipc	a0,0x23
    80003738:	1e450513          	addi	a0,a0,484 # 80026918 <icache>
    8000373c:	ffffd097          	auipc	ra,0xffffd
    80003740:	61c080e7          	jalr	1564(ra) # 80000d58 <release>
}
    80003744:	854a                	mv	a0,s2
    80003746:	70a2                	ld	ra,40(sp)
    80003748:	7402                	ld	s0,32(sp)
    8000374a:	64e2                	ld	s1,24(sp)
    8000374c:	6942                	ld	s2,16(sp)
    8000374e:	69a2                	ld	s3,8(sp)
    80003750:	6a02                	ld	s4,0(sp)
    80003752:	6145                	addi	sp,sp,48
    80003754:	8082                	ret
    panic("iget: no inodes");
    80003756:	00005517          	auipc	a0,0x5
    8000375a:	fba50513          	addi	a0,a0,-70 # 80008710 <userret+0x680>
    8000375e:	ffffd097          	auipc	ra,0xffffd
    80003762:	dea080e7          	jalr	-534(ra) # 80000548 <panic>

0000000080003766 <fsinit>:
fsinit(int dev) {
    80003766:	7179                	addi	sp,sp,-48
    80003768:	f406                	sd	ra,40(sp)
    8000376a:	f022                	sd	s0,32(sp)
    8000376c:	ec26                	sd	s1,24(sp)
    8000376e:	e84a                	sd	s2,16(sp)
    80003770:	e44e                	sd	s3,8(sp)
    80003772:	1800                	addi	s0,sp,48
    80003774:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003776:	4585                	li	a1,1
    80003778:	00000097          	auipc	ra,0x0
    8000377c:	9d8080e7          	jalr	-1576(ra) # 80003150 <bread>
    80003780:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003782:	00023997          	auipc	s3,0x23
    80003786:	17698993          	addi	s3,s3,374 # 800268f8 <sb>
    8000378a:	02000613          	li	a2,32
    8000378e:	06050593          	addi	a1,a0,96
    80003792:	854e                	mv	a0,s3
    80003794:	ffffe097          	auipc	ra,0xffffe
    80003798:	81e080e7          	jalr	-2018(ra) # 80000fb2 <memmove>
  brelse(bp);
    8000379c:	8526                	mv	a0,s1
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	ba6080e7          	jalr	-1114(ra) # 80003344 <brelse>
  if(sb.magic != FSMAGIC)
    800037a6:	0009a703          	lw	a4,0(s3)
    800037aa:	102037b7          	lui	a5,0x10203
    800037ae:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037b2:	02f71263          	bne	a4,a5,800037d6 <fsinit+0x70>
  initlog(dev, &sb);
    800037b6:	00023597          	auipc	a1,0x23
    800037ba:	14258593          	addi	a1,a1,322 # 800268f8 <sb>
    800037be:	854a                	mv	a0,s2
    800037c0:	00001097          	auipc	ra,0x1
    800037c4:	b38080e7          	jalr	-1224(ra) # 800042f8 <initlog>
}
    800037c8:	70a2                	ld	ra,40(sp)
    800037ca:	7402                	ld	s0,32(sp)
    800037cc:	64e2                	ld	s1,24(sp)
    800037ce:	6942                	ld	s2,16(sp)
    800037d0:	69a2                	ld	s3,8(sp)
    800037d2:	6145                	addi	sp,sp,48
    800037d4:	8082                	ret
    panic("invalid file system");
    800037d6:	00005517          	auipc	a0,0x5
    800037da:	f4a50513          	addi	a0,a0,-182 # 80008720 <userret+0x690>
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	d6a080e7          	jalr	-662(ra) # 80000548 <panic>

00000000800037e6 <iinit>:
{
    800037e6:	7179                	addi	sp,sp,-48
    800037e8:	f406                	sd	ra,40(sp)
    800037ea:	f022                	sd	s0,32(sp)
    800037ec:	ec26                	sd	s1,24(sp)
    800037ee:	e84a                	sd	s2,16(sp)
    800037f0:	e44e                	sd	s3,8(sp)
    800037f2:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800037f4:	00005597          	auipc	a1,0x5
    800037f8:	f4458593          	addi	a1,a1,-188 # 80008738 <userret+0x6a8>
    800037fc:	00023517          	auipc	a0,0x23
    80003800:	11c50513          	addi	a0,a0,284 # 80026918 <icache>
    80003804:	ffffd097          	auipc	ra,0xffffd
    80003808:	396080e7          	jalr	918(ra) # 80000b9a <initlock>
  for(i = 0; i < NINODE; i++) {
    8000380c:	00023497          	auipc	s1,0x23
    80003810:	13c48493          	addi	s1,s1,316 # 80026948 <icache+0x30>
    80003814:	00025997          	auipc	s3,0x25
    80003818:	d5498993          	addi	s3,s3,-684 # 80028568 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000381c:	00005917          	auipc	s2,0x5
    80003820:	f2490913          	addi	s2,s2,-220 # 80008740 <userret+0x6b0>
    80003824:	85ca                	mv	a1,s2
    80003826:	8526                	mv	a0,s1
    80003828:	00001097          	auipc	ra,0x1
    8000382c:	f26080e7          	jalr	-218(ra) # 8000474e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003830:	09048493          	addi	s1,s1,144
    80003834:	ff3498e3          	bne	s1,s3,80003824 <iinit+0x3e>
}
    80003838:	70a2                	ld	ra,40(sp)
    8000383a:	7402                	ld	s0,32(sp)
    8000383c:	64e2                	ld	s1,24(sp)
    8000383e:	6942                	ld	s2,16(sp)
    80003840:	69a2                	ld	s3,8(sp)
    80003842:	6145                	addi	sp,sp,48
    80003844:	8082                	ret

0000000080003846 <ialloc>:
{
    80003846:	715d                	addi	sp,sp,-80
    80003848:	e486                	sd	ra,72(sp)
    8000384a:	e0a2                	sd	s0,64(sp)
    8000384c:	fc26                	sd	s1,56(sp)
    8000384e:	f84a                	sd	s2,48(sp)
    80003850:	f44e                	sd	s3,40(sp)
    80003852:	f052                	sd	s4,32(sp)
    80003854:	ec56                	sd	s5,24(sp)
    80003856:	e85a                	sd	s6,16(sp)
    80003858:	e45e                	sd	s7,8(sp)
    8000385a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000385c:	00023717          	auipc	a4,0x23
    80003860:	0a872703          	lw	a4,168(a4) # 80026904 <sb+0xc>
    80003864:	4785                	li	a5,1
    80003866:	04e7fa63          	bgeu	a5,a4,800038ba <ialloc+0x74>
    8000386a:	8aaa                	mv	s5,a0
    8000386c:	8bae                	mv	s7,a1
    8000386e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003870:	00023a17          	auipc	s4,0x23
    80003874:	088a0a13          	addi	s4,s4,136 # 800268f8 <sb>
    80003878:	00048b1b          	sext.w	s6,s1
    8000387c:	0044d793          	srli	a5,s1,0x4
    80003880:	018a2583          	lw	a1,24(s4)
    80003884:	9dbd                	addw	a1,a1,a5
    80003886:	8556                	mv	a0,s5
    80003888:	00000097          	auipc	ra,0x0
    8000388c:	8c8080e7          	jalr	-1848(ra) # 80003150 <bread>
    80003890:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003892:	06050993          	addi	s3,a0,96
    80003896:	00f4f793          	andi	a5,s1,15
    8000389a:	079a                	slli	a5,a5,0x6
    8000389c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000389e:	00099783          	lh	a5,0(s3)
    800038a2:	c785                	beqz	a5,800038ca <ialloc+0x84>
    brelse(bp);
    800038a4:	00000097          	auipc	ra,0x0
    800038a8:	aa0080e7          	jalr	-1376(ra) # 80003344 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038ac:	0485                	addi	s1,s1,1
    800038ae:	00ca2703          	lw	a4,12(s4)
    800038b2:	0004879b          	sext.w	a5,s1
    800038b6:	fce7e1e3          	bltu	a5,a4,80003878 <ialloc+0x32>
  panic("ialloc: no inodes");
    800038ba:	00005517          	auipc	a0,0x5
    800038be:	e8e50513          	addi	a0,a0,-370 # 80008748 <userret+0x6b8>
    800038c2:	ffffd097          	auipc	ra,0xffffd
    800038c6:	c86080e7          	jalr	-890(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    800038ca:	04000613          	li	a2,64
    800038ce:	4581                	li	a1,0
    800038d0:	854e                	mv	a0,s3
    800038d2:	ffffd097          	auipc	ra,0xffffd
    800038d6:	684080e7          	jalr	1668(ra) # 80000f56 <memset>
      dip->type = type;
    800038da:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038de:	854a                	mv	a0,s2
    800038e0:	00001097          	auipc	ra,0x1
    800038e4:	d2e080e7          	jalr	-722(ra) # 8000460e <log_write>
      brelse(bp);
    800038e8:	854a                	mv	a0,s2
    800038ea:	00000097          	auipc	ra,0x0
    800038ee:	a5a080e7          	jalr	-1446(ra) # 80003344 <brelse>
      return iget(dev, inum);
    800038f2:	85da                	mv	a1,s6
    800038f4:	8556                	mv	a0,s5
    800038f6:	00000097          	auipc	ra,0x0
    800038fa:	db4080e7          	jalr	-588(ra) # 800036aa <iget>
}
    800038fe:	60a6                	ld	ra,72(sp)
    80003900:	6406                	ld	s0,64(sp)
    80003902:	74e2                	ld	s1,56(sp)
    80003904:	7942                	ld	s2,48(sp)
    80003906:	79a2                	ld	s3,40(sp)
    80003908:	7a02                	ld	s4,32(sp)
    8000390a:	6ae2                	ld	s5,24(sp)
    8000390c:	6b42                	ld	s6,16(sp)
    8000390e:	6ba2                	ld	s7,8(sp)
    80003910:	6161                	addi	sp,sp,80
    80003912:	8082                	ret

0000000080003914 <iupdate>:
{
    80003914:	1101                	addi	sp,sp,-32
    80003916:	ec06                	sd	ra,24(sp)
    80003918:	e822                	sd	s0,16(sp)
    8000391a:	e426                	sd	s1,8(sp)
    8000391c:	e04a                	sd	s2,0(sp)
    8000391e:	1000                	addi	s0,sp,32
    80003920:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003922:	415c                	lw	a5,4(a0)
    80003924:	0047d79b          	srliw	a5,a5,0x4
    80003928:	00023597          	auipc	a1,0x23
    8000392c:	fe85a583          	lw	a1,-24(a1) # 80026910 <sb+0x18>
    80003930:	9dbd                	addw	a1,a1,a5
    80003932:	4108                	lw	a0,0(a0)
    80003934:	00000097          	auipc	ra,0x0
    80003938:	81c080e7          	jalr	-2020(ra) # 80003150 <bread>
    8000393c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000393e:	06050793          	addi	a5,a0,96
    80003942:	40c8                	lw	a0,4(s1)
    80003944:	893d                	andi	a0,a0,15
    80003946:	051a                	slli	a0,a0,0x6
    80003948:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000394a:	04c49703          	lh	a4,76(s1)
    8000394e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003952:	04e49703          	lh	a4,78(s1)
    80003956:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000395a:	05049703          	lh	a4,80(s1)
    8000395e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003962:	05249703          	lh	a4,82(s1)
    80003966:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000396a:	48f8                	lw	a4,84(s1)
    8000396c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000396e:	03400613          	li	a2,52
    80003972:	05848593          	addi	a1,s1,88
    80003976:	0531                	addi	a0,a0,12
    80003978:	ffffd097          	auipc	ra,0xffffd
    8000397c:	63a080e7          	jalr	1594(ra) # 80000fb2 <memmove>
  log_write(bp);
    80003980:	854a                	mv	a0,s2
    80003982:	00001097          	auipc	ra,0x1
    80003986:	c8c080e7          	jalr	-884(ra) # 8000460e <log_write>
  brelse(bp);
    8000398a:	854a                	mv	a0,s2
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	9b8080e7          	jalr	-1608(ra) # 80003344 <brelse>
}
    80003994:	60e2                	ld	ra,24(sp)
    80003996:	6442                	ld	s0,16(sp)
    80003998:	64a2                	ld	s1,8(sp)
    8000399a:	6902                	ld	s2,0(sp)
    8000399c:	6105                	addi	sp,sp,32
    8000399e:	8082                	ret

00000000800039a0 <idup>:
{
    800039a0:	1101                	addi	sp,sp,-32
    800039a2:	ec06                	sd	ra,24(sp)
    800039a4:	e822                	sd	s0,16(sp)
    800039a6:	e426                	sd	s1,8(sp)
    800039a8:	1000                	addi	s0,sp,32
    800039aa:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800039ac:	00023517          	auipc	a0,0x23
    800039b0:	f6c50513          	addi	a0,a0,-148 # 80026918 <icache>
    800039b4:	ffffd097          	auipc	ra,0xffffd
    800039b8:	334080e7          	jalr	820(ra) # 80000ce8 <acquire>
  ip->ref++;
    800039bc:	449c                	lw	a5,8(s1)
    800039be:	2785                	addiw	a5,a5,1
    800039c0:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800039c2:	00023517          	auipc	a0,0x23
    800039c6:	f5650513          	addi	a0,a0,-170 # 80026918 <icache>
    800039ca:	ffffd097          	auipc	ra,0xffffd
    800039ce:	38e080e7          	jalr	910(ra) # 80000d58 <release>
}
    800039d2:	8526                	mv	a0,s1
    800039d4:	60e2                	ld	ra,24(sp)
    800039d6:	6442                	ld	s0,16(sp)
    800039d8:	64a2                	ld	s1,8(sp)
    800039da:	6105                	addi	sp,sp,32
    800039dc:	8082                	ret

00000000800039de <ilock>:
{
    800039de:	1101                	addi	sp,sp,-32
    800039e0:	ec06                	sd	ra,24(sp)
    800039e2:	e822                	sd	s0,16(sp)
    800039e4:	e426                	sd	s1,8(sp)
    800039e6:	e04a                	sd	s2,0(sp)
    800039e8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039ea:	c115                	beqz	a0,80003a0e <ilock+0x30>
    800039ec:	84aa                	mv	s1,a0
    800039ee:	451c                	lw	a5,8(a0)
    800039f0:	00f05f63          	blez	a5,80003a0e <ilock+0x30>
  acquiresleep(&ip->lock);
    800039f4:	0541                	addi	a0,a0,16
    800039f6:	00001097          	auipc	ra,0x1
    800039fa:	d92080e7          	jalr	-622(ra) # 80004788 <acquiresleep>
  if(ip->valid == 0){
    800039fe:	44bc                	lw	a5,72(s1)
    80003a00:	cf99                	beqz	a5,80003a1e <ilock+0x40>
}
    80003a02:	60e2                	ld	ra,24(sp)
    80003a04:	6442                	ld	s0,16(sp)
    80003a06:	64a2                	ld	s1,8(sp)
    80003a08:	6902                	ld	s2,0(sp)
    80003a0a:	6105                	addi	sp,sp,32
    80003a0c:	8082                	ret
    panic("ilock");
    80003a0e:	00005517          	auipc	a0,0x5
    80003a12:	d5250513          	addi	a0,a0,-686 # 80008760 <userret+0x6d0>
    80003a16:	ffffd097          	auipc	ra,0xffffd
    80003a1a:	b32080e7          	jalr	-1230(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a1e:	40dc                	lw	a5,4(s1)
    80003a20:	0047d79b          	srliw	a5,a5,0x4
    80003a24:	00023597          	auipc	a1,0x23
    80003a28:	eec5a583          	lw	a1,-276(a1) # 80026910 <sb+0x18>
    80003a2c:	9dbd                	addw	a1,a1,a5
    80003a2e:	4088                	lw	a0,0(s1)
    80003a30:	fffff097          	auipc	ra,0xfffff
    80003a34:	720080e7          	jalr	1824(ra) # 80003150 <bread>
    80003a38:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a3a:	06050593          	addi	a1,a0,96
    80003a3e:	40dc                	lw	a5,4(s1)
    80003a40:	8bbd                	andi	a5,a5,15
    80003a42:	079a                	slli	a5,a5,0x6
    80003a44:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a46:	00059783          	lh	a5,0(a1)
    80003a4a:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003a4e:	00259783          	lh	a5,2(a1)
    80003a52:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003a56:	00459783          	lh	a5,4(a1)
    80003a5a:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003a5e:	00659783          	lh	a5,6(a1)
    80003a62:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003a66:	459c                	lw	a5,8(a1)
    80003a68:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a6a:	03400613          	li	a2,52
    80003a6e:	05b1                	addi	a1,a1,12
    80003a70:	05848513          	addi	a0,s1,88
    80003a74:	ffffd097          	auipc	ra,0xffffd
    80003a78:	53e080e7          	jalr	1342(ra) # 80000fb2 <memmove>
    brelse(bp);
    80003a7c:	854a                	mv	a0,s2
    80003a7e:	00000097          	auipc	ra,0x0
    80003a82:	8c6080e7          	jalr	-1850(ra) # 80003344 <brelse>
    ip->valid = 1;
    80003a86:	4785                	li	a5,1
    80003a88:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003a8a:	04c49783          	lh	a5,76(s1)
    80003a8e:	fbb5                	bnez	a5,80003a02 <ilock+0x24>
      panic("ilock: no type");
    80003a90:	00005517          	auipc	a0,0x5
    80003a94:	cd850513          	addi	a0,a0,-808 # 80008768 <userret+0x6d8>
    80003a98:	ffffd097          	auipc	ra,0xffffd
    80003a9c:	ab0080e7          	jalr	-1360(ra) # 80000548 <panic>

0000000080003aa0 <iunlock>:
{
    80003aa0:	1101                	addi	sp,sp,-32
    80003aa2:	ec06                	sd	ra,24(sp)
    80003aa4:	e822                	sd	s0,16(sp)
    80003aa6:	e426                	sd	s1,8(sp)
    80003aa8:	e04a                	sd	s2,0(sp)
    80003aaa:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003aac:	c905                	beqz	a0,80003adc <iunlock+0x3c>
    80003aae:	84aa                	mv	s1,a0
    80003ab0:	01050913          	addi	s2,a0,16
    80003ab4:	854a                	mv	a0,s2
    80003ab6:	00001097          	auipc	ra,0x1
    80003aba:	d6c080e7          	jalr	-660(ra) # 80004822 <holdingsleep>
    80003abe:	cd19                	beqz	a0,80003adc <iunlock+0x3c>
    80003ac0:	449c                	lw	a5,8(s1)
    80003ac2:	00f05d63          	blez	a5,80003adc <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ac6:	854a                	mv	a0,s2
    80003ac8:	00001097          	auipc	ra,0x1
    80003acc:	d16080e7          	jalr	-746(ra) # 800047de <releasesleep>
}
    80003ad0:	60e2                	ld	ra,24(sp)
    80003ad2:	6442                	ld	s0,16(sp)
    80003ad4:	64a2                	ld	s1,8(sp)
    80003ad6:	6902                	ld	s2,0(sp)
    80003ad8:	6105                	addi	sp,sp,32
    80003ada:	8082                	ret
    panic("iunlock");
    80003adc:	00005517          	auipc	a0,0x5
    80003ae0:	c9c50513          	addi	a0,a0,-868 # 80008778 <userret+0x6e8>
    80003ae4:	ffffd097          	auipc	ra,0xffffd
    80003ae8:	a64080e7          	jalr	-1436(ra) # 80000548 <panic>

0000000080003aec <iput>:
{
    80003aec:	7139                	addi	sp,sp,-64
    80003aee:	fc06                	sd	ra,56(sp)
    80003af0:	f822                	sd	s0,48(sp)
    80003af2:	f426                	sd	s1,40(sp)
    80003af4:	f04a                	sd	s2,32(sp)
    80003af6:	ec4e                	sd	s3,24(sp)
    80003af8:	e852                	sd	s4,16(sp)
    80003afa:	e456                	sd	s5,8(sp)
    80003afc:	0080                	addi	s0,sp,64
    80003afe:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003b00:	00023517          	auipc	a0,0x23
    80003b04:	e1850513          	addi	a0,a0,-488 # 80026918 <icache>
    80003b08:	ffffd097          	auipc	ra,0xffffd
    80003b0c:	1e0080e7          	jalr	480(ra) # 80000ce8 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b10:	4498                	lw	a4,8(s1)
    80003b12:	4785                	li	a5,1
    80003b14:	02f70663          	beq	a4,a5,80003b40 <iput+0x54>
  ip->ref--;
    80003b18:	449c                	lw	a5,8(s1)
    80003b1a:	37fd                	addiw	a5,a5,-1
    80003b1c:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b1e:	00023517          	auipc	a0,0x23
    80003b22:	dfa50513          	addi	a0,a0,-518 # 80026918 <icache>
    80003b26:	ffffd097          	auipc	ra,0xffffd
    80003b2a:	232080e7          	jalr	562(ra) # 80000d58 <release>
}
    80003b2e:	70e2                	ld	ra,56(sp)
    80003b30:	7442                	ld	s0,48(sp)
    80003b32:	74a2                	ld	s1,40(sp)
    80003b34:	7902                	ld	s2,32(sp)
    80003b36:	69e2                	ld	s3,24(sp)
    80003b38:	6a42                	ld	s4,16(sp)
    80003b3a:	6aa2                	ld	s5,8(sp)
    80003b3c:	6121                	addi	sp,sp,64
    80003b3e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b40:	44bc                	lw	a5,72(s1)
    80003b42:	dbf9                	beqz	a5,80003b18 <iput+0x2c>
    80003b44:	05249783          	lh	a5,82(s1)
    80003b48:	fbe1                	bnez	a5,80003b18 <iput+0x2c>
    acquiresleep(&ip->lock);
    80003b4a:	01048a13          	addi	s4,s1,16
    80003b4e:	8552                	mv	a0,s4
    80003b50:	00001097          	auipc	ra,0x1
    80003b54:	c38080e7          	jalr	-968(ra) # 80004788 <acquiresleep>
    release(&icache.lock);
    80003b58:	00023517          	auipc	a0,0x23
    80003b5c:	dc050513          	addi	a0,a0,-576 # 80026918 <icache>
    80003b60:	ffffd097          	auipc	ra,0xffffd
    80003b64:	1f8080e7          	jalr	504(ra) # 80000d58 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b68:	05848913          	addi	s2,s1,88
    80003b6c:	08848993          	addi	s3,s1,136
    80003b70:	a021                	j	80003b78 <iput+0x8c>
    80003b72:	0911                	addi	s2,s2,4
    80003b74:	01390d63          	beq	s2,s3,80003b8e <iput+0xa2>
    if(ip->addrs[i]){
    80003b78:	00092583          	lw	a1,0(s2)
    80003b7c:	d9fd                	beqz	a1,80003b72 <iput+0x86>
      bfree(ip->dev, ip->addrs[i]);
    80003b7e:	4088                	lw	a0,0(s1)
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	8a2080e7          	jalr	-1886(ra) # 80003422 <bfree>
      ip->addrs[i] = 0;
    80003b88:	00092023          	sw	zero,0(s2)
    80003b8c:	b7dd                	j	80003b72 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b8e:	0884a583          	lw	a1,136(s1)
    80003b92:	ed9d                	bnez	a1,80003bd0 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b94:	0404aa23          	sw	zero,84(s1)
  iupdate(ip);
    80003b98:	8526                	mv	a0,s1
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	d7a080e7          	jalr	-646(ra) # 80003914 <iupdate>
    ip->type = 0;
    80003ba2:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003ba6:	8526                	mv	a0,s1
    80003ba8:	00000097          	auipc	ra,0x0
    80003bac:	d6c080e7          	jalr	-660(ra) # 80003914 <iupdate>
    ip->valid = 0;
    80003bb0:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003bb4:	8552                	mv	a0,s4
    80003bb6:	00001097          	auipc	ra,0x1
    80003bba:	c28080e7          	jalr	-984(ra) # 800047de <releasesleep>
    acquire(&icache.lock);
    80003bbe:	00023517          	auipc	a0,0x23
    80003bc2:	d5a50513          	addi	a0,a0,-678 # 80026918 <icache>
    80003bc6:	ffffd097          	auipc	ra,0xffffd
    80003bca:	122080e7          	jalr	290(ra) # 80000ce8 <acquire>
    80003bce:	b7a9                	j	80003b18 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003bd0:	4088                	lw	a0,0(s1)
    80003bd2:	fffff097          	auipc	ra,0xfffff
    80003bd6:	57e080e7          	jalr	1406(ra) # 80003150 <bread>
    80003bda:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003bdc:	06050913          	addi	s2,a0,96
    80003be0:	46050993          	addi	s3,a0,1120
    80003be4:	a021                	j	80003bec <iput+0x100>
    80003be6:	0911                	addi	s2,s2,4
    80003be8:	01390b63          	beq	s2,s3,80003bfe <iput+0x112>
      if(a[j])
    80003bec:	00092583          	lw	a1,0(s2)
    80003bf0:	d9fd                	beqz	a1,80003be6 <iput+0xfa>
        bfree(ip->dev, a[j]);
    80003bf2:	4088                	lw	a0,0(s1)
    80003bf4:	00000097          	auipc	ra,0x0
    80003bf8:	82e080e7          	jalr	-2002(ra) # 80003422 <bfree>
    80003bfc:	b7ed                	j	80003be6 <iput+0xfa>
    brelse(bp);
    80003bfe:	8556                	mv	a0,s5
    80003c00:	fffff097          	auipc	ra,0xfffff
    80003c04:	744080e7          	jalr	1860(ra) # 80003344 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c08:	0884a583          	lw	a1,136(s1)
    80003c0c:	4088                	lw	a0,0(s1)
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	814080e7          	jalr	-2028(ra) # 80003422 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c16:	0804a423          	sw	zero,136(s1)
    80003c1a:	bfad                	j	80003b94 <iput+0xa8>

0000000080003c1c <iunlockput>:
{
    80003c1c:	1101                	addi	sp,sp,-32
    80003c1e:	ec06                	sd	ra,24(sp)
    80003c20:	e822                	sd	s0,16(sp)
    80003c22:	e426                	sd	s1,8(sp)
    80003c24:	1000                	addi	s0,sp,32
    80003c26:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c28:	00000097          	auipc	ra,0x0
    80003c2c:	e78080e7          	jalr	-392(ra) # 80003aa0 <iunlock>
  iput(ip);
    80003c30:	8526                	mv	a0,s1
    80003c32:	00000097          	auipc	ra,0x0
    80003c36:	eba080e7          	jalr	-326(ra) # 80003aec <iput>
}
    80003c3a:	60e2                	ld	ra,24(sp)
    80003c3c:	6442                	ld	s0,16(sp)
    80003c3e:	64a2                	ld	s1,8(sp)
    80003c40:	6105                	addi	sp,sp,32
    80003c42:	8082                	ret

0000000080003c44 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c44:	1141                	addi	sp,sp,-16
    80003c46:	e422                	sd	s0,8(sp)
    80003c48:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c4a:	411c                	lw	a5,0(a0)
    80003c4c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c4e:	415c                	lw	a5,4(a0)
    80003c50:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c52:	04c51783          	lh	a5,76(a0)
    80003c56:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c5a:	05251783          	lh	a5,82(a0)
    80003c5e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c62:	05456783          	lwu	a5,84(a0)
    80003c66:	e99c                	sd	a5,16(a1)
}
    80003c68:	6422                	ld	s0,8(sp)
    80003c6a:	0141                	addi	sp,sp,16
    80003c6c:	8082                	ret

0000000080003c6e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c6e:	497c                	lw	a5,84(a0)
    80003c70:	0ed7e563          	bltu	a5,a3,80003d5a <readi+0xec>
{
    80003c74:	7159                	addi	sp,sp,-112
    80003c76:	f486                	sd	ra,104(sp)
    80003c78:	f0a2                	sd	s0,96(sp)
    80003c7a:	eca6                	sd	s1,88(sp)
    80003c7c:	e8ca                	sd	s2,80(sp)
    80003c7e:	e4ce                	sd	s3,72(sp)
    80003c80:	e0d2                	sd	s4,64(sp)
    80003c82:	fc56                	sd	s5,56(sp)
    80003c84:	f85a                	sd	s6,48(sp)
    80003c86:	f45e                	sd	s7,40(sp)
    80003c88:	f062                	sd	s8,32(sp)
    80003c8a:	ec66                	sd	s9,24(sp)
    80003c8c:	e86a                	sd	s10,16(sp)
    80003c8e:	e46e                	sd	s11,8(sp)
    80003c90:	1880                	addi	s0,sp,112
    80003c92:	8baa                	mv	s7,a0
    80003c94:	8c2e                	mv	s8,a1
    80003c96:	8ab2                	mv	s5,a2
    80003c98:	8936                	mv	s2,a3
    80003c9a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c9c:	9f35                	addw	a4,a4,a3
    80003c9e:	0cd76063          	bltu	a4,a3,80003d5e <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    80003ca2:	00e7f463          	bgeu	a5,a4,80003caa <readi+0x3c>
    n = ip->size - off;
    80003ca6:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003caa:	080b0763          	beqz	s6,80003d38 <readi+0xca>
    80003cae:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cb0:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cb4:	5cfd                	li	s9,-1
    80003cb6:	a82d                	j	80003cf0 <readi+0x82>
    80003cb8:	02099d93          	slli	s11,s3,0x20
    80003cbc:	020ddd93          	srli	s11,s11,0x20
    80003cc0:	06048793          	addi	a5,s1,96
    80003cc4:	86ee                	mv	a3,s11
    80003cc6:	963e                	add	a2,a2,a5
    80003cc8:	85d6                	mv	a1,s5
    80003cca:	8562                	mv	a0,s8
    80003ccc:	fffff097          	auipc	ra,0xfffff
    80003cd0:	9a4080e7          	jalr	-1628(ra) # 80002670 <either_copyout>
    80003cd4:	05950d63          	beq	a0,s9,80003d2e <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003cd8:	8526                	mv	a0,s1
    80003cda:	fffff097          	auipc	ra,0xfffff
    80003cde:	66a080e7          	jalr	1642(ra) # 80003344 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ce2:	01498a3b          	addw	s4,s3,s4
    80003ce6:	0129893b          	addw	s2,s3,s2
    80003cea:	9aee                	add	s5,s5,s11
    80003cec:	056a7663          	bgeu	s4,s6,80003d38 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cf0:	000ba483          	lw	s1,0(s7)
    80003cf4:	00a9559b          	srliw	a1,s2,0xa
    80003cf8:	855e                	mv	a0,s7
    80003cfa:	00000097          	auipc	ra,0x0
    80003cfe:	8d6080e7          	jalr	-1834(ra) # 800035d0 <bmap>
    80003d02:	0005059b          	sext.w	a1,a0
    80003d06:	8526                	mv	a0,s1
    80003d08:	fffff097          	auipc	ra,0xfffff
    80003d0c:	448080e7          	jalr	1096(ra) # 80003150 <bread>
    80003d10:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d12:	3ff97613          	andi	a2,s2,1023
    80003d16:	40cd07bb          	subw	a5,s10,a2
    80003d1a:	414b073b          	subw	a4,s6,s4
    80003d1e:	89be                	mv	s3,a5
    80003d20:	2781                	sext.w	a5,a5
    80003d22:	0007069b          	sext.w	a3,a4
    80003d26:	f8f6f9e3          	bgeu	a3,a5,80003cb8 <readi+0x4a>
    80003d2a:	89ba                	mv	s3,a4
    80003d2c:	b771                	j	80003cb8 <readi+0x4a>
      brelse(bp);
    80003d2e:	8526                	mv	a0,s1
    80003d30:	fffff097          	auipc	ra,0xfffff
    80003d34:	614080e7          	jalr	1556(ra) # 80003344 <brelse>
  }
  return n;
    80003d38:	000b051b          	sext.w	a0,s6
}
    80003d3c:	70a6                	ld	ra,104(sp)
    80003d3e:	7406                	ld	s0,96(sp)
    80003d40:	64e6                	ld	s1,88(sp)
    80003d42:	6946                	ld	s2,80(sp)
    80003d44:	69a6                	ld	s3,72(sp)
    80003d46:	6a06                	ld	s4,64(sp)
    80003d48:	7ae2                	ld	s5,56(sp)
    80003d4a:	7b42                	ld	s6,48(sp)
    80003d4c:	7ba2                	ld	s7,40(sp)
    80003d4e:	7c02                	ld	s8,32(sp)
    80003d50:	6ce2                	ld	s9,24(sp)
    80003d52:	6d42                	ld	s10,16(sp)
    80003d54:	6da2                	ld	s11,8(sp)
    80003d56:	6165                	addi	sp,sp,112
    80003d58:	8082                	ret
    return -1;
    80003d5a:	557d                	li	a0,-1
}
    80003d5c:	8082                	ret
    return -1;
    80003d5e:	557d                	li	a0,-1
    80003d60:	bff1                	j	80003d3c <readi+0xce>

0000000080003d62 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d62:	497c                	lw	a5,84(a0)
    80003d64:	10d7e663          	bltu	a5,a3,80003e70 <writei+0x10e>
{
    80003d68:	7159                	addi	sp,sp,-112
    80003d6a:	f486                	sd	ra,104(sp)
    80003d6c:	f0a2                	sd	s0,96(sp)
    80003d6e:	eca6                	sd	s1,88(sp)
    80003d70:	e8ca                	sd	s2,80(sp)
    80003d72:	e4ce                	sd	s3,72(sp)
    80003d74:	e0d2                	sd	s4,64(sp)
    80003d76:	fc56                	sd	s5,56(sp)
    80003d78:	f85a                	sd	s6,48(sp)
    80003d7a:	f45e                	sd	s7,40(sp)
    80003d7c:	f062                	sd	s8,32(sp)
    80003d7e:	ec66                	sd	s9,24(sp)
    80003d80:	e86a                	sd	s10,16(sp)
    80003d82:	e46e                	sd	s11,8(sp)
    80003d84:	1880                	addi	s0,sp,112
    80003d86:	8baa                	mv	s7,a0
    80003d88:	8c2e                	mv	s8,a1
    80003d8a:	8ab2                	mv	s5,a2
    80003d8c:	8936                	mv	s2,a3
    80003d8e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d90:	00e687bb          	addw	a5,a3,a4
    80003d94:	0ed7e063          	bltu	a5,a3,80003e74 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d98:	00043737          	lui	a4,0x43
    80003d9c:	0cf76e63          	bltu	a4,a5,80003e78 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003da0:	0a0b0763          	beqz	s6,80003e4e <writei+0xec>
    80003da4:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003da6:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003daa:	5cfd                	li	s9,-1
    80003dac:	a091                	j	80003df0 <writei+0x8e>
    80003dae:	02099d93          	slli	s11,s3,0x20
    80003db2:	020ddd93          	srli	s11,s11,0x20
    80003db6:	06048793          	addi	a5,s1,96
    80003dba:	86ee                	mv	a3,s11
    80003dbc:	8656                	mv	a2,s5
    80003dbe:	85e2                	mv	a1,s8
    80003dc0:	953e                	add	a0,a0,a5
    80003dc2:	fffff097          	auipc	ra,0xfffff
    80003dc6:	904080e7          	jalr	-1788(ra) # 800026c6 <either_copyin>
    80003dca:	07950263          	beq	a0,s9,80003e2e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003dce:	8526                	mv	a0,s1
    80003dd0:	00001097          	auipc	ra,0x1
    80003dd4:	83e080e7          	jalr	-1986(ra) # 8000460e <log_write>
    brelse(bp);
    80003dd8:	8526                	mv	a0,s1
    80003dda:	fffff097          	auipc	ra,0xfffff
    80003dde:	56a080e7          	jalr	1386(ra) # 80003344 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003de2:	01498a3b          	addw	s4,s3,s4
    80003de6:	0129893b          	addw	s2,s3,s2
    80003dea:	9aee                	add	s5,s5,s11
    80003dec:	056a7663          	bgeu	s4,s6,80003e38 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003df0:	000ba483          	lw	s1,0(s7)
    80003df4:	00a9559b          	srliw	a1,s2,0xa
    80003df8:	855e                	mv	a0,s7
    80003dfa:	fffff097          	auipc	ra,0xfffff
    80003dfe:	7d6080e7          	jalr	2006(ra) # 800035d0 <bmap>
    80003e02:	0005059b          	sext.w	a1,a0
    80003e06:	8526                	mv	a0,s1
    80003e08:	fffff097          	auipc	ra,0xfffff
    80003e0c:	348080e7          	jalr	840(ra) # 80003150 <bread>
    80003e10:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e12:	3ff97513          	andi	a0,s2,1023
    80003e16:	40ad07bb          	subw	a5,s10,a0
    80003e1a:	414b073b          	subw	a4,s6,s4
    80003e1e:	89be                	mv	s3,a5
    80003e20:	2781                	sext.w	a5,a5
    80003e22:	0007069b          	sext.w	a3,a4
    80003e26:	f8f6f4e3          	bgeu	a3,a5,80003dae <writei+0x4c>
    80003e2a:	89ba                	mv	s3,a4
    80003e2c:	b749                	j	80003dae <writei+0x4c>
      brelse(bp);
    80003e2e:	8526                	mv	a0,s1
    80003e30:	fffff097          	auipc	ra,0xfffff
    80003e34:	514080e7          	jalr	1300(ra) # 80003344 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003e38:	054ba783          	lw	a5,84(s7)
    80003e3c:	0127f463          	bgeu	a5,s2,80003e44 <writei+0xe2>
      ip->size = off;
    80003e40:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003e44:	855e                	mv	a0,s7
    80003e46:	00000097          	auipc	ra,0x0
    80003e4a:	ace080e7          	jalr	-1330(ra) # 80003914 <iupdate>
  }

  return n;
    80003e4e:	000b051b          	sext.w	a0,s6
}
    80003e52:	70a6                	ld	ra,104(sp)
    80003e54:	7406                	ld	s0,96(sp)
    80003e56:	64e6                	ld	s1,88(sp)
    80003e58:	6946                	ld	s2,80(sp)
    80003e5a:	69a6                	ld	s3,72(sp)
    80003e5c:	6a06                	ld	s4,64(sp)
    80003e5e:	7ae2                	ld	s5,56(sp)
    80003e60:	7b42                	ld	s6,48(sp)
    80003e62:	7ba2                	ld	s7,40(sp)
    80003e64:	7c02                	ld	s8,32(sp)
    80003e66:	6ce2                	ld	s9,24(sp)
    80003e68:	6d42                	ld	s10,16(sp)
    80003e6a:	6da2                	ld	s11,8(sp)
    80003e6c:	6165                	addi	sp,sp,112
    80003e6e:	8082                	ret
    return -1;
    80003e70:	557d                	li	a0,-1
}
    80003e72:	8082                	ret
    return -1;
    80003e74:	557d                	li	a0,-1
    80003e76:	bff1                	j	80003e52 <writei+0xf0>
    return -1;
    80003e78:	557d                	li	a0,-1
    80003e7a:	bfe1                	j	80003e52 <writei+0xf0>

0000000080003e7c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e7c:	1141                	addi	sp,sp,-16
    80003e7e:	e406                	sd	ra,8(sp)
    80003e80:	e022                	sd	s0,0(sp)
    80003e82:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e84:	4639                	li	a2,14
    80003e86:	ffffd097          	auipc	ra,0xffffd
    80003e8a:	1a8080e7          	jalr	424(ra) # 8000102e <strncmp>
}
    80003e8e:	60a2                	ld	ra,8(sp)
    80003e90:	6402                	ld	s0,0(sp)
    80003e92:	0141                	addi	sp,sp,16
    80003e94:	8082                	ret

0000000080003e96 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e96:	7139                	addi	sp,sp,-64
    80003e98:	fc06                	sd	ra,56(sp)
    80003e9a:	f822                	sd	s0,48(sp)
    80003e9c:	f426                	sd	s1,40(sp)
    80003e9e:	f04a                	sd	s2,32(sp)
    80003ea0:	ec4e                	sd	s3,24(sp)
    80003ea2:	e852                	sd	s4,16(sp)
    80003ea4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ea6:	04c51703          	lh	a4,76(a0)
    80003eaa:	4785                	li	a5,1
    80003eac:	00f71a63          	bne	a4,a5,80003ec0 <dirlookup+0x2a>
    80003eb0:	892a                	mv	s2,a0
    80003eb2:	89ae                	mv	s3,a1
    80003eb4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eb6:	497c                	lw	a5,84(a0)
    80003eb8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003eba:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ebc:	e79d                	bnez	a5,80003eea <dirlookup+0x54>
    80003ebe:	a8a5                	j	80003f36 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ec0:	00005517          	auipc	a0,0x5
    80003ec4:	8c050513          	addi	a0,a0,-1856 # 80008780 <userret+0x6f0>
    80003ec8:	ffffc097          	auipc	ra,0xffffc
    80003ecc:	680080e7          	jalr	1664(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003ed0:	00005517          	auipc	a0,0x5
    80003ed4:	8c850513          	addi	a0,a0,-1848 # 80008798 <userret+0x708>
    80003ed8:	ffffc097          	auipc	ra,0xffffc
    80003edc:	670080e7          	jalr	1648(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ee0:	24c1                	addiw	s1,s1,16
    80003ee2:	05492783          	lw	a5,84(s2)
    80003ee6:	04f4f763          	bgeu	s1,a5,80003f34 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eea:	4741                	li	a4,16
    80003eec:	86a6                	mv	a3,s1
    80003eee:	fc040613          	addi	a2,s0,-64
    80003ef2:	4581                	li	a1,0
    80003ef4:	854a                	mv	a0,s2
    80003ef6:	00000097          	auipc	ra,0x0
    80003efa:	d78080e7          	jalr	-648(ra) # 80003c6e <readi>
    80003efe:	47c1                	li	a5,16
    80003f00:	fcf518e3          	bne	a0,a5,80003ed0 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f04:	fc045783          	lhu	a5,-64(s0)
    80003f08:	dfe1                	beqz	a5,80003ee0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f0a:	fc240593          	addi	a1,s0,-62
    80003f0e:	854e                	mv	a0,s3
    80003f10:	00000097          	auipc	ra,0x0
    80003f14:	f6c080e7          	jalr	-148(ra) # 80003e7c <namecmp>
    80003f18:	f561                	bnez	a0,80003ee0 <dirlookup+0x4a>
      if(poff)
    80003f1a:	000a0463          	beqz	s4,80003f22 <dirlookup+0x8c>
        *poff = off;
    80003f1e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f22:	fc045583          	lhu	a1,-64(s0)
    80003f26:	00092503          	lw	a0,0(s2)
    80003f2a:	fffff097          	auipc	ra,0xfffff
    80003f2e:	780080e7          	jalr	1920(ra) # 800036aa <iget>
    80003f32:	a011                	j	80003f36 <dirlookup+0xa0>
  return 0;
    80003f34:	4501                	li	a0,0
}
    80003f36:	70e2                	ld	ra,56(sp)
    80003f38:	7442                	ld	s0,48(sp)
    80003f3a:	74a2                	ld	s1,40(sp)
    80003f3c:	7902                	ld	s2,32(sp)
    80003f3e:	69e2                	ld	s3,24(sp)
    80003f40:	6a42                	ld	s4,16(sp)
    80003f42:	6121                	addi	sp,sp,64
    80003f44:	8082                	ret

0000000080003f46 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f46:	711d                	addi	sp,sp,-96
    80003f48:	ec86                	sd	ra,88(sp)
    80003f4a:	e8a2                	sd	s0,80(sp)
    80003f4c:	e4a6                	sd	s1,72(sp)
    80003f4e:	e0ca                	sd	s2,64(sp)
    80003f50:	fc4e                	sd	s3,56(sp)
    80003f52:	f852                	sd	s4,48(sp)
    80003f54:	f456                	sd	s5,40(sp)
    80003f56:	f05a                	sd	s6,32(sp)
    80003f58:	ec5e                	sd	s7,24(sp)
    80003f5a:	e862                	sd	s8,16(sp)
    80003f5c:	e466                	sd	s9,8(sp)
    80003f5e:	1080                	addi	s0,sp,96
    80003f60:	84aa                	mv	s1,a0
    80003f62:	8aae                	mv	s5,a1
    80003f64:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f66:	00054703          	lbu	a4,0(a0)
    80003f6a:	02f00793          	li	a5,47
    80003f6e:	02f70363          	beq	a4,a5,80003f94 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f72:	ffffe097          	auipc	ra,0xffffe
    80003f76:	cce080e7          	jalr	-818(ra) # 80001c40 <myproc>
    80003f7a:	15853503          	ld	a0,344(a0)
    80003f7e:	00000097          	auipc	ra,0x0
    80003f82:	a22080e7          	jalr	-1502(ra) # 800039a0 <idup>
    80003f86:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f88:	02f00913          	li	s2,47
  len = path - s;
    80003f8c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f8e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f90:	4b85                	li	s7,1
    80003f92:	a865                	j	8000404a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f94:	4585                	li	a1,1
    80003f96:	4501                	li	a0,0
    80003f98:	fffff097          	auipc	ra,0xfffff
    80003f9c:	712080e7          	jalr	1810(ra) # 800036aa <iget>
    80003fa0:	89aa                	mv	s3,a0
    80003fa2:	b7dd                	j	80003f88 <namex+0x42>
      iunlockput(ip);
    80003fa4:	854e                	mv	a0,s3
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	c76080e7          	jalr	-906(ra) # 80003c1c <iunlockput>
      return 0;
    80003fae:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fb0:	854e                	mv	a0,s3
    80003fb2:	60e6                	ld	ra,88(sp)
    80003fb4:	6446                	ld	s0,80(sp)
    80003fb6:	64a6                	ld	s1,72(sp)
    80003fb8:	6906                	ld	s2,64(sp)
    80003fba:	79e2                	ld	s3,56(sp)
    80003fbc:	7a42                	ld	s4,48(sp)
    80003fbe:	7aa2                	ld	s5,40(sp)
    80003fc0:	7b02                	ld	s6,32(sp)
    80003fc2:	6be2                	ld	s7,24(sp)
    80003fc4:	6c42                	ld	s8,16(sp)
    80003fc6:	6ca2                	ld	s9,8(sp)
    80003fc8:	6125                	addi	sp,sp,96
    80003fca:	8082                	ret
      iunlock(ip);
    80003fcc:	854e                	mv	a0,s3
    80003fce:	00000097          	auipc	ra,0x0
    80003fd2:	ad2080e7          	jalr	-1326(ra) # 80003aa0 <iunlock>
      return ip;
    80003fd6:	bfe9                	j	80003fb0 <namex+0x6a>
      iunlockput(ip);
    80003fd8:	854e                	mv	a0,s3
    80003fda:	00000097          	auipc	ra,0x0
    80003fde:	c42080e7          	jalr	-958(ra) # 80003c1c <iunlockput>
      return 0;
    80003fe2:	89e6                	mv	s3,s9
    80003fe4:	b7f1                	j	80003fb0 <namex+0x6a>
  len = path - s;
    80003fe6:	40b48633          	sub	a2,s1,a1
    80003fea:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003fee:	099c5463          	bge	s8,s9,80004076 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003ff2:	4639                	li	a2,14
    80003ff4:	8552                	mv	a0,s4
    80003ff6:	ffffd097          	auipc	ra,0xffffd
    80003ffa:	fbc080e7          	jalr	-68(ra) # 80000fb2 <memmove>
  while(*path == '/')
    80003ffe:	0004c783          	lbu	a5,0(s1)
    80004002:	01279763          	bne	a5,s2,80004010 <namex+0xca>
    path++;
    80004006:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004008:	0004c783          	lbu	a5,0(s1)
    8000400c:	ff278de3          	beq	a5,s2,80004006 <namex+0xc0>
    ilock(ip);
    80004010:	854e                	mv	a0,s3
    80004012:	00000097          	auipc	ra,0x0
    80004016:	9cc080e7          	jalr	-1588(ra) # 800039de <ilock>
    if(ip->type != T_DIR){
    8000401a:	04c99783          	lh	a5,76(s3)
    8000401e:	f97793e3          	bne	a5,s7,80003fa4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004022:	000a8563          	beqz	s5,8000402c <namex+0xe6>
    80004026:	0004c783          	lbu	a5,0(s1)
    8000402a:	d3cd                	beqz	a5,80003fcc <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000402c:	865a                	mv	a2,s6
    8000402e:	85d2                	mv	a1,s4
    80004030:	854e                	mv	a0,s3
    80004032:	00000097          	auipc	ra,0x0
    80004036:	e64080e7          	jalr	-412(ra) # 80003e96 <dirlookup>
    8000403a:	8caa                	mv	s9,a0
    8000403c:	dd51                	beqz	a0,80003fd8 <namex+0x92>
    iunlockput(ip);
    8000403e:	854e                	mv	a0,s3
    80004040:	00000097          	auipc	ra,0x0
    80004044:	bdc080e7          	jalr	-1060(ra) # 80003c1c <iunlockput>
    ip = next;
    80004048:	89e6                	mv	s3,s9
  while(*path == '/')
    8000404a:	0004c783          	lbu	a5,0(s1)
    8000404e:	05279763          	bne	a5,s2,8000409c <namex+0x156>
    path++;
    80004052:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004054:	0004c783          	lbu	a5,0(s1)
    80004058:	ff278de3          	beq	a5,s2,80004052 <namex+0x10c>
  if(*path == 0)
    8000405c:	c79d                	beqz	a5,8000408a <namex+0x144>
    path++;
    8000405e:	85a6                	mv	a1,s1
  len = path - s;
    80004060:	8cda                	mv	s9,s6
    80004062:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004064:	01278963          	beq	a5,s2,80004076 <namex+0x130>
    80004068:	dfbd                	beqz	a5,80003fe6 <namex+0xa0>
    path++;
    8000406a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000406c:	0004c783          	lbu	a5,0(s1)
    80004070:	ff279ce3          	bne	a5,s2,80004068 <namex+0x122>
    80004074:	bf8d                	j	80003fe6 <namex+0xa0>
    memmove(name, s, len);
    80004076:	2601                	sext.w	a2,a2
    80004078:	8552                	mv	a0,s4
    8000407a:	ffffd097          	auipc	ra,0xffffd
    8000407e:	f38080e7          	jalr	-200(ra) # 80000fb2 <memmove>
    name[len] = 0;
    80004082:	9cd2                	add	s9,s9,s4
    80004084:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004088:	bf9d                	j	80003ffe <namex+0xb8>
  if(nameiparent){
    8000408a:	f20a83e3          	beqz	s5,80003fb0 <namex+0x6a>
    iput(ip);
    8000408e:	854e                	mv	a0,s3
    80004090:	00000097          	auipc	ra,0x0
    80004094:	a5c080e7          	jalr	-1444(ra) # 80003aec <iput>
    return 0;
    80004098:	4981                	li	s3,0
    8000409a:	bf19                	j	80003fb0 <namex+0x6a>
  if(*path == 0)
    8000409c:	d7fd                	beqz	a5,8000408a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000409e:	0004c783          	lbu	a5,0(s1)
    800040a2:	85a6                	mv	a1,s1
    800040a4:	b7d1                	j	80004068 <namex+0x122>

00000000800040a6 <dirlink>:
{
    800040a6:	7139                	addi	sp,sp,-64
    800040a8:	fc06                	sd	ra,56(sp)
    800040aa:	f822                	sd	s0,48(sp)
    800040ac:	f426                	sd	s1,40(sp)
    800040ae:	f04a                	sd	s2,32(sp)
    800040b0:	ec4e                	sd	s3,24(sp)
    800040b2:	e852                	sd	s4,16(sp)
    800040b4:	0080                	addi	s0,sp,64
    800040b6:	892a                	mv	s2,a0
    800040b8:	8a2e                	mv	s4,a1
    800040ba:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040bc:	4601                	li	a2,0
    800040be:	00000097          	auipc	ra,0x0
    800040c2:	dd8080e7          	jalr	-552(ra) # 80003e96 <dirlookup>
    800040c6:	e93d                	bnez	a0,8000413c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040c8:	05492483          	lw	s1,84(s2)
    800040cc:	c49d                	beqz	s1,800040fa <dirlink+0x54>
    800040ce:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040d0:	4741                	li	a4,16
    800040d2:	86a6                	mv	a3,s1
    800040d4:	fc040613          	addi	a2,s0,-64
    800040d8:	4581                	li	a1,0
    800040da:	854a                	mv	a0,s2
    800040dc:	00000097          	auipc	ra,0x0
    800040e0:	b92080e7          	jalr	-1134(ra) # 80003c6e <readi>
    800040e4:	47c1                	li	a5,16
    800040e6:	06f51163          	bne	a0,a5,80004148 <dirlink+0xa2>
    if(de.inum == 0)
    800040ea:	fc045783          	lhu	a5,-64(s0)
    800040ee:	c791                	beqz	a5,800040fa <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040f0:	24c1                	addiw	s1,s1,16
    800040f2:	05492783          	lw	a5,84(s2)
    800040f6:	fcf4ede3          	bltu	s1,a5,800040d0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040fa:	4639                	li	a2,14
    800040fc:	85d2                	mv	a1,s4
    800040fe:	fc240513          	addi	a0,s0,-62
    80004102:	ffffd097          	auipc	ra,0xffffd
    80004106:	f68080e7          	jalr	-152(ra) # 8000106a <strncpy>
  de.inum = inum;
    8000410a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000410e:	4741                	li	a4,16
    80004110:	86a6                	mv	a3,s1
    80004112:	fc040613          	addi	a2,s0,-64
    80004116:	4581                	li	a1,0
    80004118:	854a                	mv	a0,s2
    8000411a:	00000097          	auipc	ra,0x0
    8000411e:	c48080e7          	jalr	-952(ra) # 80003d62 <writei>
    80004122:	872a                	mv	a4,a0
    80004124:	47c1                	li	a5,16
  return 0;
    80004126:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004128:	02f71863          	bne	a4,a5,80004158 <dirlink+0xb2>
}
    8000412c:	70e2                	ld	ra,56(sp)
    8000412e:	7442                	ld	s0,48(sp)
    80004130:	74a2                	ld	s1,40(sp)
    80004132:	7902                	ld	s2,32(sp)
    80004134:	69e2                	ld	s3,24(sp)
    80004136:	6a42                	ld	s4,16(sp)
    80004138:	6121                	addi	sp,sp,64
    8000413a:	8082                	ret
    iput(ip);
    8000413c:	00000097          	auipc	ra,0x0
    80004140:	9b0080e7          	jalr	-1616(ra) # 80003aec <iput>
    return -1;
    80004144:	557d                	li	a0,-1
    80004146:	b7dd                	j	8000412c <dirlink+0x86>
      panic("dirlink read");
    80004148:	00004517          	auipc	a0,0x4
    8000414c:	66050513          	addi	a0,a0,1632 # 800087a8 <userret+0x718>
    80004150:	ffffc097          	auipc	ra,0xffffc
    80004154:	3f8080e7          	jalr	1016(ra) # 80000548 <panic>
    panic("dirlink");
    80004158:	00004517          	auipc	a0,0x4
    8000415c:	77050513          	addi	a0,a0,1904 # 800088c8 <userret+0x838>
    80004160:	ffffc097          	auipc	ra,0xffffc
    80004164:	3e8080e7          	jalr	1000(ra) # 80000548 <panic>

0000000080004168 <namei>:

struct inode*
namei(char *path)
{
    80004168:	1101                	addi	sp,sp,-32
    8000416a:	ec06                	sd	ra,24(sp)
    8000416c:	e822                	sd	s0,16(sp)
    8000416e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004170:	fe040613          	addi	a2,s0,-32
    80004174:	4581                	li	a1,0
    80004176:	00000097          	auipc	ra,0x0
    8000417a:	dd0080e7          	jalr	-560(ra) # 80003f46 <namex>
}
    8000417e:	60e2                	ld	ra,24(sp)
    80004180:	6442                	ld	s0,16(sp)
    80004182:	6105                	addi	sp,sp,32
    80004184:	8082                	ret

0000000080004186 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004186:	1141                	addi	sp,sp,-16
    80004188:	e406                	sd	ra,8(sp)
    8000418a:	e022                	sd	s0,0(sp)
    8000418c:	0800                	addi	s0,sp,16
    8000418e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004190:	4585                	li	a1,1
    80004192:	00000097          	auipc	ra,0x0
    80004196:	db4080e7          	jalr	-588(ra) # 80003f46 <namex>
}
    8000419a:	60a2                	ld	ra,8(sp)
    8000419c:	6402                	ld	s0,0(sp)
    8000419e:	0141                	addi	sp,sp,16
    800041a0:	8082                	ret

00000000800041a2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    800041a2:	7179                	addi	sp,sp,-48
    800041a4:	f406                	sd	ra,40(sp)
    800041a6:	f022                	sd	s0,32(sp)
    800041a8:	ec26                	sd	s1,24(sp)
    800041aa:	e84a                	sd	s2,16(sp)
    800041ac:	e44e                	sd	s3,8(sp)
    800041ae:	1800                	addi	s0,sp,48
    800041b0:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    800041b2:	0b000993          	li	s3,176
    800041b6:	033507b3          	mul	a5,a0,s3
    800041ba:	00024997          	auipc	s3,0x24
    800041be:	39e98993          	addi	s3,s3,926 # 80028558 <log>
    800041c2:	99be                	add	s3,s3,a5
    800041c4:	0209a583          	lw	a1,32(s3)
    800041c8:	fffff097          	auipc	ra,0xfffff
    800041cc:	f88080e7          	jalr	-120(ra) # 80003150 <bread>
    800041d0:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    800041d2:	0349a783          	lw	a5,52(s3)
    800041d6:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    800041d8:	0349a783          	lw	a5,52(s3)
    800041dc:	02f05763          	blez	a5,8000420a <write_head+0x68>
    800041e0:	0b000793          	li	a5,176
    800041e4:	02f487b3          	mul	a5,s1,a5
    800041e8:	00024717          	auipc	a4,0x24
    800041ec:	3a870713          	addi	a4,a4,936 # 80028590 <log+0x38>
    800041f0:	97ba                	add	a5,a5,a4
    800041f2:	06450693          	addi	a3,a0,100
    800041f6:	4701                	li	a4,0
    800041f8:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    800041fa:	4390                	lw	a2,0(a5)
    800041fc:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    800041fe:	2705                	addiw	a4,a4,1
    80004200:	0791                	addi	a5,a5,4
    80004202:	0691                	addi	a3,a3,4
    80004204:	59d0                	lw	a2,52(a1)
    80004206:	fec74ae3          	blt	a4,a2,800041fa <write_head+0x58>
  }
  bwrite(buf);
    8000420a:	854a                	mv	a0,s2
    8000420c:	fffff097          	auipc	ra,0xfffff
    80004210:	0f8080e7          	jalr	248(ra) # 80003304 <bwrite>
  brelse(buf);
    80004214:	854a                	mv	a0,s2
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	12e080e7          	jalr	302(ra) # 80003344 <brelse>
}
    8000421e:	70a2                	ld	ra,40(sp)
    80004220:	7402                	ld	s0,32(sp)
    80004222:	64e2                	ld	s1,24(sp)
    80004224:	6942                	ld	s2,16(sp)
    80004226:	69a2                	ld	s3,8(sp)
    80004228:	6145                	addi	sp,sp,48
    8000422a:	8082                	ret

000000008000422c <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000422c:	0b000793          	li	a5,176
    80004230:	02f50733          	mul	a4,a0,a5
    80004234:	00024797          	auipc	a5,0x24
    80004238:	32478793          	addi	a5,a5,804 # 80028558 <log>
    8000423c:	97ba                	add	a5,a5,a4
    8000423e:	5bdc                	lw	a5,52(a5)
    80004240:	0af05b63          	blez	a5,800042f6 <install_trans+0xca>
{
    80004244:	7139                	addi	sp,sp,-64
    80004246:	fc06                	sd	ra,56(sp)
    80004248:	f822                	sd	s0,48(sp)
    8000424a:	f426                	sd	s1,40(sp)
    8000424c:	f04a                	sd	s2,32(sp)
    8000424e:	ec4e                	sd	s3,24(sp)
    80004250:	e852                	sd	s4,16(sp)
    80004252:	e456                	sd	s5,8(sp)
    80004254:	e05a                	sd	s6,0(sp)
    80004256:	0080                	addi	s0,sp,64
    80004258:	00024797          	auipc	a5,0x24
    8000425c:	33878793          	addi	a5,a5,824 # 80028590 <log+0x38>
    80004260:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004264:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80004266:	00050b1b          	sext.w	s6,a0
    8000426a:	00024a97          	auipc	s5,0x24
    8000426e:	2eea8a93          	addi	s5,s5,750 # 80028558 <log>
    80004272:	9aba                	add	s5,s5,a4
    80004274:	020aa583          	lw	a1,32(s5)
    80004278:	013585bb          	addw	a1,a1,s3
    8000427c:	2585                	addiw	a1,a1,1
    8000427e:	855a                	mv	a0,s6
    80004280:	fffff097          	auipc	ra,0xfffff
    80004284:	ed0080e7          	jalr	-304(ra) # 80003150 <bread>
    80004288:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    8000428a:	000a2583          	lw	a1,0(s4)
    8000428e:	855a                	mv	a0,s6
    80004290:	fffff097          	auipc	ra,0xfffff
    80004294:	ec0080e7          	jalr	-320(ra) # 80003150 <bread>
    80004298:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000429a:	40000613          	li	a2,1024
    8000429e:	06090593          	addi	a1,s2,96
    800042a2:	06050513          	addi	a0,a0,96
    800042a6:	ffffd097          	auipc	ra,0xffffd
    800042aa:	d0c080e7          	jalr	-756(ra) # 80000fb2 <memmove>
    bwrite(dbuf);  // write dst to disk
    800042ae:	8526                	mv	a0,s1
    800042b0:	fffff097          	auipc	ra,0xfffff
    800042b4:	054080e7          	jalr	84(ra) # 80003304 <bwrite>
    bunpin(dbuf);
    800042b8:	8526                	mv	a0,s1
    800042ba:	fffff097          	auipc	ra,0xfffff
    800042be:	14a080e7          	jalr	330(ra) # 80003404 <bunpin>
    brelse(lbuf);
    800042c2:	854a                	mv	a0,s2
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	080080e7          	jalr	128(ra) # 80003344 <brelse>
    brelse(dbuf);
    800042cc:	8526                	mv	a0,s1
    800042ce:	fffff097          	auipc	ra,0xfffff
    800042d2:	076080e7          	jalr	118(ra) # 80003344 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800042d6:	2985                	addiw	s3,s3,1
    800042d8:	0a11                	addi	s4,s4,4
    800042da:	034aa783          	lw	a5,52(s5)
    800042de:	f8f9cbe3          	blt	s3,a5,80004274 <install_trans+0x48>
}
    800042e2:	70e2                	ld	ra,56(sp)
    800042e4:	7442                	ld	s0,48(sp)
    800042e6:	74a2                	ld	s1,40(sp)
    800042e8:	7902                	ld	s2,32(sp)
    800042ea:	69e2                	ld	s3,24(sp)
    800042ec:	6a42                	ld	s4,16(sp)
    800042ee:	6aa2                	ld	s5,8(sp)
    800042f0:	6b02                	ld	s6,0(sp)
    800042f2:	6121                	addi	sp,sp,64
    800042f4:	8082                	ret
    800042f6:	8082                	ret

00000000800042f8 <initlog>:
{
    800042f8:	7179                	addi	sp,sp,-48
    800042fa:	f406                	sd	ra,40(sp)
    800042fc:	f022                	sd	s0,32(sp)
    800042fe:	ec26                	sd	s1,24(sp)
    80004300:	e84a                	sd	s2,16(sp)
    80004302:	e44e                	sd	s3,8(sp)
    80004304:	e052                	sd	s4,0(sp)
    80004306:	1800                	addi	s0,sp,48
    80004308:	892a                	mv	s2,a0
    8000430a:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    8000430c:	0b000713          	li	a4,176
    80004310:	02e504b3          	mul	s1,a0,a4
    80004314:	00024997          	auipc	s3,0x24
    80004318:	24498993          	addi	s3,s3,580 # 80028558 <log>
    8000431c:	99a6                	add	s3,s3,s1
    8000431e:	00004597          	auipc	a1,0x4
    80004322:	49a58593          	addi	a1,a1,1178 # 800087b8 <userret+0x728>
    80004326:	854e                	mv	a0,s3
    80004328:	ffffd097          	auipc	ra,0xffffd
    8000432c:	872080e7          	jalr	-1934(ra) # 80000b9a <initlock>
  log[dev].start = sb->logstart;
    80004330:	014a2583          	lw	a1,20(s4)
    80004334:	02b9a023          	sw	a1,32(s3)
  log[dev].size = sb->nlog;
    80004338:	010a2783          	lw	a5,16(s4)
    8000433c:	02f9a223          	sw	a5,36(s3)
  log[dev].dev = dev;
    80004340:	0329a823          	sw	s2,48(s3)
  struct buf *buf = bread(dev, log[dev].start);
    80004344:	854a                	mv	a0,s2
    80004346:	fffff097          	auipc	ra,0xfffff
    8000434a:	e0a080e7          	jalr	-502(ra) # 80003150 <bread>
  log[dev].lh.n = lh->n;
    8000434e:	5134                	lw	a3,96(a0)
    80004350:	02d9aa23          	sw	a3,52(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004354:	02d05663          	blez	a3,80004380 <initlog+0x88>
    80004358:	06450793          	addi	a5,a0,100
    8000435c:	00024717          	auipc	a4,0x24
    80004360:	23470713          	addi	a4,a4,564 # 80028590 <log+0x38>
    80004364:	9726                	add	a4,a4,s1
    80004366:	36fd                	addiw	a3,a3,-1
    80004368:	1682                	slli	a3,a3,0x20
    8000436a:	9281                	srli	a3,a3,0x20
    8000436c:	068a                	slli	a3,a3,0x2
    8000436e:	06850613          	addi	a2,a0,104
    80004372:	96b2                	add	a3,a3,a2
    log[dev].lh.block[i] = lh->block[i];
    80004374:	4390                	lw	a2,0(a5)
    80004376:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004378:	0791                	addi	a5,a5,4
    8000437a:	0711                	addi	a4,a4,4
    8000437c:	fed79ce3          	bne	a5,a3,80004374 <initlog+0x7c>
  brelse(buf);
    80004380:	fffff097          	auipc	ra,0xfffff
    80004384:	fc4080e7          	jalr	-60(ra) # 80003344 <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    80004388:	854a                	mv	a0,s2
    8000438a:	00000097          	auipc	ra,0x0
    8000438e:	ea2080e7          	jalr	-350(ra) # 8000422c <install_trans>
  log[dev].lh.n = 0;
    80004392:	0b000793          	li	a5,176
    80004396:	02f90733          	mul	a4,s2,a5
    8000439a:	00024797          	auipc	a5,0x24
    8000439e:	1be78793          	addi	a5,a5,446 # 80028558 <log>
    800043a2:	97ba                	add	a5,a5,a4
    800043a4:	0207aa23          	sw	zero,52(a5)
  write_head(dev); // clear the log
    800043a8:	854a                	mv	a0,s2
    800043aa:	00000097          	auipc	ra,0x0
    800043ae:	df8080e7          	jalr	-520(ra) # 800041a2 <write_head>
}
    800043b2:	70a2                	ld	ra,40(sp)
    800043b4:	7402                	ld	s0,32(sp)
    800043b6:	64e2                	ld	s1,24(sp)
    800043b8:	6942                	ld	s2,16(sp)
    800043ba:	69a2                	ld	s3,8(sp)
    800043bc:	6a02                	ld	s4,0(sp)
    800043be:	6145                	addi	sp,sp,48
    800043c0:	8082                	ret

00000000800043c2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    800043c2:	7139                	addi	sp,sp,-64
    800043c4:	fc06                	sd	ra,56(sp)
    800043c6:	f822                	sd	s0,48(sp)
    800043c8:	f426                	sd	s1,40(sp)
    800043ca:	f04a                	sd	s2,32(sp)
    800043cc:	ec4e                	sd	s3,24(sp)
    800043ce:	e852                	sd	s4,16(sp)
    800043d0:	e456                	sd	s5,8(sp)
    800043d2:	0080                	addi	s0,sp,64
    800043d4:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    800043d6:	0b000913          	li	s2,176
    800043da:	032507b3          	mul	a5,a0,s2
    800043de:	00024917          	auipc	s2,0x24
    800043e2:	17a90913          	addi	s2,s2,378 # 80028558 <log>
    800043e6:	993e                	add	s2,s2,a5
    800043e8:	854a                	mv	a0,s2
    800043ea:	ffffd097          	auipc	ra,0xffffd
    800043ee:	8fe080e7          	jalr	-1794(ra) # 80000ce8 <acquire>
  while(1){
    if(log[dev].committing){
    800043f2:	00024997          	auipc	s3,0x24
    800043f6:	16698993          	addi	s3,s3,358 # 80028558 <log>
    800043fa:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043fc:	4a79                	li	s4,30
    800043fe:	a039                	j	8000440c <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    80004400:	85ca                	mv	a1,s2
    80004402:	854e                	mv	a0,s3
    80004404:	ffffe097          	auipc	ra,0xffffe
    80004408:	012080e7          	jalr	18(ra) # 80002416 <sleep>
    if(log[dev].committing){
    8000440c:	54dc                	lw	a5,44(s1)
    8000440e:	fbed                	bnez	a5,80004400 <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004410:	549c                	lw	a5,40(s1)
    80004412:	0017871b          	addiw	a4,a5,1
    80004416:	0007069b          	sext.w	a3,a4
    8000441a:	0027179b          	slliw	a5,a4,0x2
    8000441e:	9fb9                	addw	a5,a5,a4
    80004420:	0017979b          	slliw	a5,a5,0x1
    80004424:	58d8                	lw	a4,52(s1)
    80004426:	9fb9                	addw	a5,a5,a4
    80004428:	00fa5963          	bge	s4,a5,8000443a <begin_op+0x78>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    8000442c:	85ca                	mv	a1,s2
    8000442e:	854e                	mv	a0,s3
    80004430:	ffffe097          	auipc	ra,0xffffe
    80004434:	fe6080e7          	jalr	-26(ra) # 80002416 <sleep>
    80004438:	bfd1                	j	8000440c <begin_op+0x4a>
    } else {
      log[dev].outstanding += 1;
    8000443a:	0b000513          	li	a0,176
    8000443e:	02aa8ab3          	mul	s5,s5,a0
    80004442:	00024797          	auipc	a5,0x24
    80004446:	11678793          	addi	a5,a5,278 # 80028558 <log>
    8000444a:	9abe                	add	s5,s5,a5
    8000444c:	02daa423          	sw	a3,40(s5)
      release(&log[dev].lock);
    80004450:	854a                	mv	a0,s2
    80004452:	ffffd097          	auipc	ra,0xffffd
    80004456:	906080e7          	jalr	-1786(ra) # 80000d58 <release>
      break;
    }
  }
}
    8000445a:	70e2                	ld	ra,56(sp)
    8000445c:	7442                	ld	s0,48(sp)
    8000445e:	74a2                	ld	s1,40(sp)
    80004460:	7902                	ld	s2,32(sp)
    80004462:	69e2                	ld	s3,24(sp)
    80004464:	6a42                	ld	s4,16(sp)
    80004466:	6aa2                	ld	s5,8(sp)
    80004468:	6121                	addi	sp,sp,64
    8000446a:	8082                	ret

000000008000446c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    8000446c:	715d                	addi	sp,sp,-80
    8000446e:	e486                	sd	ra,72(sp)
    80004470:	e0a2                	sd	s0,64(sp)
    80004472:	fc26                	sd	s1,56(sp)
    80004474:	f84a                	sd	s2,48(sp)
    80004476:	f44e                	sd	s3,40(sp)
    80004478:	f052                	sd	s4,32(sp)
    8000447a:	ec56                	sd	s5,24(sp)
    8000447c:	e85a                	sd	s6,16(sp)
    8000447e:	e45e                	sd	s7,8(sp)
    80004480:	e062                	sd	s8,0(sp)
    80004482:	0880                	addi	s0,sp,80
    80004484:	89aa                	mv	s3,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    80004486:	0b000913          	li	s2,176
    8000448a:	03250933          	mul	s2,a0,s2
    8000448e:	00024497          	auipc	s1,0x24
    80004492:	0ca48493          	addi	s1,s1,202 # 80028558 <log>
    80004496:	94ca                	add	s1,s1,s2
    80004498:	8526                	mv	a0,s1
    8000449a:	ffffd097          	auipc	ra,0xffffd
    8000449e:	84e080e7          	jalr	-1970(ra) # 80000ce8 <acquire>
  log[dev].outstanding -= 1;
    800044a2:	549c                	lw	a5,40(s1)
    800044a4:	37fd                	addiw	a5,a5,-1
    800044a6:	00078a9b          	sext.w	s5,a5
    800044aa:	d49c                	sw	a5,40(s1)
  if(log[dev].committing)
    800044ac:	54dc                	lw	a5,44(s1)
    800044ae:	e3b5                	bnez	a5,80004512 <end_op+0xa6>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    800044b0:	060a9963          	bnez	s5,80004522 <end_op+0xb6>
    do_commit = 1;
    log[dev].committing = 1;
    800044b4:	0b000a13          	li	s4,176
    800044b8:	034987b3          	mul	a5,s3,s4
    800044bc:	00024a17          	auipc	s4,0x24
    800044c0:	09ca0a13          	addi	s4,s4,156 # 80028558 <log>
    800044c4:	9a3e                	add	s4,s4,a5
    800044c6:	4785                	li	a5,1
    800044c8:	02fa2623          	sw	a5,44(s4)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    800044cc:	8526                	mv	a0,s1
    800044ce:	ffffd097          	auipc	ra,0xffffd
    800044d2:	88a080e7          	jalr	-1910(ra) # 80000d58 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    800044d6:	034a2783          	lw	a5,52(s4)
    800044da:	06f04d63          	bgtz	a5,80004554 <end_op+0xe8>
    acquire(&log[dev].lock);
    800044de:	8526                	mv	a0,s1
    800044e0:	ffffd097          	auipc	ra,0xffffd
    800044e4:	808080e7          	jalr	-2040(ra) # 80000ce8 <acquire>
    log[dev].committing = 0;
    800044e8:	00024517          	auipc	a0,0x24
    800044ec:	07050513          	addi	a0,a0,112 # 80028558 <log>
    800044f0:	0b000793          	li	a5,176
    800044f4:	02f989b3          	mul	s3,s3,a5
    800044f8:	99aa                	add	s3,s3,a0
    800044fa:	0209a623          	sw	zero,44(s3)
    wakeup(&log);
    800044fe:	ffffe097          	auipc	ra,0xffffe
    80004502:	098080e7          	jalr	152(ra) # 80002596 <wakeup>
    release(&log[dev].lock);
    80004506:	8526                	mv	a0,s1
    80004508:	ffffd097          	auipc	ra,0xffffd
    8000450c:	850080e7          	jalr	-1968(ra) # 80000d58 <release>
}
    80004510:	a035                	j	8000453c <end_op+0xd0>
    panic("log[dev].committing");
    80004512:	00004517          	auipc	a0,0x4
    80004516:	2ae50513          	addi	a0,a0,686 # 800087c0 <userret+0x730>
    8000451a:	ffffc097          	auipc	ra,0xffffc
    8000451e:	02e080e7          	jalr	46(ra) # 80000548 <panic>
    wakeup(&log);
    80004522:	00024517          	auipc	a0,0x24
    80004526:	03650513          	addi	a0,a0,54 # 80028558 <log>
    8000452a:	ffffe097          	auipc	ra,0xffffe
    8000452e:	06c080e7          	jalr	108(ra) # 80002596 <wakeup>
  release(&log[dev].lock);
    80004532:	8526                	mv	a0,s1
    80004534:	ffffd097          	auipc	ra,0xffffd
    80004538:	824080e7          	jalr	-2012(ra) # 80000d58 <release>
}
    8000453c:	60a6                	ld	ra,72(sp)
    8000453e:	6406                	ld	s0,64(sp)
    80004540:	74e2                	ld	s1,56(sp)
    80004542:	7942                	ld	s2,48(sp)
    80004544:	79a2                	ld	s3,40(sp)
    80004546:	7a02                	ld	s4,32(sp)
    80004548:	6ae2                	ld	s5,24(sp)
    8000454a:	6b42                	ld	s6,16(sp)
    8000454c:	6ba2                	ld	s7,8(sp)
    8000454e:	6c02                	ld	s8,0(sp)
    80004550:	6161                	addi	sp,sp,80
    80004552:	8082                	ret
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004554:	00024797          	auipc	a5,0x24
    80004558:	03c78793          	addi	a5,a5,60 # 80028590 <log+0x38>
    8000455c:	993e                	add	s2,s2,a5
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    8000455e:	00098c1b          	sext.w	s8,s3
    80004562:	0b000b93          	li	s7,176
    80004566:	037987b3          	mul	a5,s3,s7
    8000456a:	00024b97          	auipc	s7,0x24
    8000456e:	feeb8b93          	addi	s7,s7,-18 # 80028558 <log>
    80004572:	9bbe                	add	s7,s7,a5
    80004574:	020ba583          	lw	a1,32(s7)
    80004578:	015585bb          	addw	a1,a1,s5
    8000457c:	2585                	addiw	a1,a1,1
    8000457e:	8562                	mv	a0,s8
    80004580:	fffff097          	auipc	ra,0xfffff
    80004584:	bd0080e7          	jalr	-1072(ra) # 80003150 <bread>
    80004588:	8a2a                	mv	s4,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    8000458a:	00092583          	lw	a1,0(s2)
    8000458e:	8562                	mv	a0,s8
    80004590:	fffff097          	auipc	ra,0xfffff
    80004594:	bc0080e7          	jalr	-1088(ra) # 80003150 <bread>
    80004598:	8b2a                	mv	s6,a0
    memmove(to->data, from->data, BSIZE);
    8000459a:	40000613          	li	a2,1024
    8000459e:	06050593          	addi	a1,a0,96
    800045a2:	060a0513          	addi	a0,s4,96
    800045a6:	ffffd097          	auipc	ra,0xffffd
    800045aa:	a0c080e7          	jalr	-1524(ra) # 80000fb2 <memmove>
    bwrite(to);  // write the log
    800045ae:	8552                	mv	a0,s4
    800045b0:	fffff097          	auipc	ra,0xfffff
    800045b4:	d54080e7          	jalr	-684(ra) # 80003304 <bwrite>
    brelse(from);
    800045b8:	855a                	mv	a0,s6
    800045ba:	fffff097          	auipc	ra,0xfffff
    800045be:	d8a080e7          	jalr	-630(ra) # 80003344 <brelse>
    brelse(to);
    800045c2:	8552                	mv	a0,s4
    800045c4:	fffff097          	auipc	ra,0xfffff
    800045c8:	d80080e7          	jalr	-640(ra) # 80003344 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800045cc:	2a85                	addiw	s5,s5,1
    800045ce:	0911                	addi	s2,s2,4
    800045d0:	034ba783          	lw	a5,52(s7)
    800045d4:	fafac0e3          	blt	s5,a5,80004574 <end_op+0x108>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    800045d8:	854e                	mv	a0,s3
    800045da:	00000097          	auipc	ra,0x0
    800045de:	bc8080e7          	jalr	-1080(ra) # 800041a2 <write_head>
    install_trans(dev); // Now install writes to home locations
    800045e2:	854e                	mv	a0,s3
    800045e4:	00000097          	auipc	ra,0x0
    800045e8:	c48080e7          	jalr	-952(ra) # 8000422c <install_trans>
    log[dev].lh.n = 0;
    800045ec:	0b000793          	li	a5,176
    800045f0:	02f98733          	mul	a4,s3,a5
    800045f4:	00024797          	auipc	a5,0x24
    800045f8:	f6478793          	addi	a5,a5,-156 # 80028558 <log>
    800045fc:	97ba                	add	a5,a5,a4
    800045fe:	0207aa23          	sw	zero,52(a5)
    write_head(dev);    // Erase the transaction from the log
    80004602:	854e                	mv	a0,s3
    80004604:	00000097          	auipc	ra,0x0
    80004608:	b9e080e7          	jalr	-1122(ra) # 800041a2 <write_head>
    8000460c:	bdc9                	j	800044de <end_op+0x72>

000000008000460e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000460e:	7179                	addi	sp,sp,-48
    80004610:	f406                	sd	ra,40(sp)
    80004612:	f022                	sd	s0,32(sp)
    80004614:	ec26                	sd	s1,24(sp)
    80004616:	e84a                	sd	s2,16(sp)
    80004618:	e44e                	sd	s3,8(sp)
    8000461a:	e052                	sd	s4,0(sp)
    8000461c:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    8000461e:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004622:	0b000793          	li	a5,176
    80004626:	02f90733          	mul	a4,s2,a5
    8000462a:	00024797          	auipc	a5,0x24
    8000462e:	f2e78793          	addi	a5,a5,-210 # 80028558 <log>
    80004632:	97ba                	add	a5,a5,a4
    80004634:	5bd4                	lw	a3,52(a5)
    80004636:	47f5                	li	a5,29
    80004638:	0ad7cc63          	blt	a5,a3,800046f0 <log_write+0xe2>
    8000463c:	89aa                	mv	s3,a0
    8000463e:	00024797          	auipc	a5,0x24
    80004642:	f1a78793          	addi	a5,a5,-230 # 80028558 <log>
    80004646:	97ba                	add	a5,a5,a4
    80004648:	53dc                	lw	a5,36(a5)
    8000464a:	37fd                	addiw	a5,a5,-1
    8000464c:	0af6d263          	bge	a3,a5,800046f0 <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004650:	0b000793          	li	a5,176
    80004654:	02f90733          	mul	a4,s2,a5
    80004658:	00024797          	auipc	a5,0x24
    8000465c:	f0078793          	addi	a5,a5,-256 # 80028558 <log>
    80004660:	97ba                	add	a5,a5,a4
    80004662:	579c                	lw	a5,40(a5)
    80004664:	08f05e63          	blez	a5,80004700 <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    80004668:	0b000793          	li	a5,176
    8000466c:	02f904b3          	mul	s1,s2,a5
    80004670:	00024a17          	auipc	s4,0x24
    80004674:	ee8a0a13          	addi	s4,s4,-280 # 80028558 <log>
    80004678:	9a26                	add	s4,s4,s1
    8000467a:	8552                	mv	a0,s4
    8000467c:	ffffc097          	auipc	ra,0xffffc
    80004680:	66c080e7          	jalr	1644(ra) # 80000ce8 <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004684:	034a2603          	lw	a2,52(s4)
    80004688:	08c05463          	blez	a2,80004710 <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000468c:	00c9a583          	lw	a1,12(s3)
    80004690:	00024797          	auipc	a5,0x24
    80004694:	f0078793          	addi	a5,a5,-256 # 80028590 <log+0x38>
    80004698:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    8000469a:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000469c:	4394                	lw	a3,0(a5)
    8000469e:	06b68a63          	beq	a3,a1,80004712 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    800046a2:	2705                	addiw	a4,a4,1
    800046a4:	0791                	addi	a5,a5,4
    800046a6:	fec71be3          	bne	a4,a2,8000469c <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    800046aa:	02c00793          	li	a5,44
    800046ae:	02f907b3          	mul	a5,s2,a5
    800046b2:	97b2                	add	a5,a5,a2
    800046b4:	07b1                	addi	a5,a5,12
    800046b6:	078a                	slli	a5,a5,0x2
    800046b8:	00024717          	auipc	a4,0x24
    800046bc:	ea070713          	addi	a4,a4,-352 # 80028558 <log>
    800046c0:	97ba                	add	a5,a5,a4
    800046c2:	00c9a703          	lw	a4,12(s3)
    800046c6:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    800046c8:	854e                	mv	a0,s3
    800046ca:	fffff097          	auipc	ra,0xfffff
    800046ce:	d1c080e7          	jalr	-740(ra) # 800033e6 <bpin>
    log[dev].lh.n++;
    800046d2:	0b000793          	li	a5,176
    800046d6:	02f90933          	mul	s2,s2,a5
    800046da:	00024797          	auipc	a5,0x24
    800046de:	e7e78793          	addi	a5,a5,-386 # 80028558 <log>
    800046e2:	993e                	add	s2,s2,a5
    800046e4:	03492783          	lw	a5,52(s2)
    800046e8:	2785                	addiw	a5,a5,1
    800046ea:	02f92a23          	sw	a5,52(s2)
    800046ee:	a099                	j	80004734 <log_write+0x126>
    panic("too big a transaction");
    800046f0:	00004517          	auipc	a0,0x4
    800046f4:	0e850513          	addi	a0,a0,232 # 800087d8 <userret+0x748>
    800046f8:	ffffc097          	auipc	ra,0xffffc
    800046fc:	e50080e7          	jalr	-432(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    80004700:	00004517          	auipc	a0,0x4
    80004704:	0f050513          	addi	a0,a0,240 # 800087f0 <userret+0x760>
    80004708:	ffffc097          	auipc	ra,0xffffc
    8000470c:	e40080e7          	jalr	-448(ra) # 80000548 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004710:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    80004712:	02c00793          	li	a5,44
    80004716:	02f907b3          	mul	a5,s2,a5
    8000471a:	97ba                	add	a5,a5,a4
    8000471c:	07b1                	addi	a5,a5,12
    8000471e:	078a                	slli	a5,a5,0x2
    80004720:	00024697          	auipc	a3,0x24
    80004724:	e3868693          	addi	a3,a3,-456 # 80028558 <log>
    80004728:	97b6                	add	a5,a5,a3
    8000472a:	00c9a683          	lw	a3,12(s3)
    8000472e:	c794                	sw	a3,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004730:	f8e60ce3          	beq	a2,a4,800046c8 <log_write+0xba>
  }
  release(&log[dev].lock);
    80004734:	8552                	mv	a0,s4
    80004736:	ffffc097          	auipc	ra,0xffffc
    8000473a:	622080e7          	jalr	1570(ra) # 80000d58 <release>
}
    8000473e:	70a2                	ld	ra,40(sp)
    80004740:	7402                	ld	s0,32(sp)
    80004742:	64e2                	ld	s1,24(sp)
    80004744:	6942                	ld	s2,16(sp)
    80004746:	69a2                	ld	s3,8(sp)
    80004748:	6a02                	ld	s4,0(sp)
    8000474a:	6145                	addi	sp,sp,48
    8000474c:	8082                	ret

000000008000474e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000474e:	1101                	addi	sp,sp,-32
    80004750:	ec06                	sd	ra,24(sp)
    80004752:	e822                	sd	s0,16(sp)
    80004754:	e426                	sd	s1,8(sp)
    80004756:	e04a                	sd	s2,0(sp)
    80004758:	1000                	addi	s0,sp,32
    8000475a:	84aa                	mv	s1,a0
    8000475c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000475e:	00004597          	auipc	a1,0x4
    80004762:	0b258593          	addi	a1,a1,178 # 80008810 <userret+0x780>
    80004766:	0521                	addi	a0,a0,8
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	432080e7          	jalr	1074(ra) # 80000b9a <initlock>
  lk->name = name;
    80004770:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004774:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004778:	0204a823          	sw	zero,48(s1)
}
    8000477c:	60e2                	ld	ra,24(sp)
    8000477e:	6442                	ld	s0,16(sp)
    80004780:	64a2                	ld	s1,8(sp)
    80004782:	6902                	ld	s2,0(sp)
    80004784:	6105                	addi	sp,sp,32
    80004786:	8082                	ret

0000000080004788 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004788:	1101                	addi	sp,sp,-32
    8000478a:	ec06                	sd	ra,24(sp)
    8000478c:	e822                	sd	s0,16(sp)
    8000478e:	e426                	sd	s1,8(sp)
    80004790:	e04a                	sd	s2,0(sp)
    80004792:	1000                	addi	s0,sp,32
    80004794:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004796:	00850913          	addi	s2,a0,8
    8000479a:	854a                	mv	a0,s2
    8000479c:	ffffc097          	auipc	ra,0xffffc
    800047a0:	54c080e7          	jalr	1356(ra) # 80000ce8 <acquire>
  while (lk->locked) {
    800047a4:	409c                	lw	a5,0(s1)
    800047a6:	cb89                	beqz	a5,800047b8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800047a8:	85ca                	mv	a1,s2
    800047aa:	8526                	mv	a0,s1
    800047ac:	ffffe097          	auipc	ra,0xffffe
    800047b0:	c6a080e7          	jalr	-918(ra) # 80002416 <sleep>
  while (lk->locked) {
    800047b4:	409c                	lw	a5,0(s1)
    800047b6:	fbed                	bnez	a5,800047a8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047b8:	4785                	li	a5,1
    800047ba:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047bc:	ffffd097          	auipc	ra,0xffffd
    800047c0:	484080e7          	jalr	1156(ra) # 80001c40 <myproc>
    800047c4:	413c                	lw	a5,64(a0)
    800047c6:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    800047c8:	854a                	mv	a0,s2
    800047ca:	ffffc097          	auipc	ra,0xffffc
    800047ce:	58e080e7          	jalr	1422(ra) # 80000d58 <release>
}
    800047d2:	60e2                	ld	ra,24(sp)
    800047d4:	6442                	ld	s0,16(sp)
    800047d6:	64a2                	ld	s1,8(sp)
    800047d8:	6902                	ld	s2,0(sp)
    800047da:	6105                	addi	sp,sp,32
    800047dc:	8082                	ret

00000000800047de <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800047de:	1101                	addi	sp,sp,-32
    800047e0:	ec06                	sd	ra,24(sp)
    800047e2:	e822                	sd	s0,16(sp)
    800047e4:	e426                	sd	s1,8(sp)
    800047e6:	e04a                	sd	s2,0(sp)
    800047e8:	1000                	addi	s0,sp,32
    800047ea:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047ec:	00850913          	addi	s2,a0,8
    800047f0:	854a                	mv	a0,s2
    800047f2:	ffffc097          	auipc	ra,0xffffc
    800047f6:	4f6080e7          	jalr	1270(ra) # 80000ce8 <acquire>
  lk->locked = 0;
    800047fa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047fe:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    80004802:	8526                	mv	a0,s1
    80004804:	ffffe097          	auipc	ra,0xffffe
    80004808:	d92080e7          	jalr	-622(ra) # 80002596 <wakeup>
  release(&lk->lk);
    8000480c:	854a                	mv	a0,s2
    8000480e:	ffffc097          	auipc	ra,0xffffc
    80004812:	54a080e7          	jalr	1354(ra) # 80000d58 <release>
}
    80004816:	60e2                	ld	ra,24(sp)
    80004818:	6442                	ld	s0,16(sp)
    8000481a:	64a2                	ld	s1,8(sp)
    8000481c:	6902                	ld	s2,0(sp)
    8000481e:	6105                	addi	sp,sp,32
    80004820:	8082                	ret

0000000080004822 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004822:	7179                	addi	sp,sp,-48
    80004824:	f406                	sd	ra,40(sp)
    80004826:	f022                	sd	s0,32(sp)
    80004828:	ec26                	sd	s1,24(sp)
    8000482a:	e84a                	sd	s2,16(sp)
    8000482c:	e44e                	sd	s3,8(sp)
    8000482e:	1800                	addi	s0,sp,48
    80004830:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004832:	00850913          	addi	s2,a0,8
    80004836:	854a                	mv	a0,s2
    80004838:	ffffc097          	auipc	ra,0xffffc
    8000483c:	4b0080e7          	jalr	1200(ra) # 80000ce8 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004840:	409c                	lw	a5,0(s1)
    80004842:	ef99                	bnez	a5,80004860 <holdingsleep+0x3e>
    80004844:	4481                	li	s1,0
  release(&lk->lk);
    80004846:	854a                	mv	a0,s2
    80004848:	ffffc097          	auipc	ra,0xffffc
    8000484c:	510080e7          	jalr	1296(ra) # 80000d58 <release>
  return r;
}
    80004850:	8526                	mv	a0,s1
    80004852:	70a2                	ld	ra,40(sp)
    80004854:	7402                	ld	s0,32(sp)
    80004856:	64e2                	ld	s1,24(sp)
    80004858:	6942                	ld	s2,16(sp)
    8000485a:	69a2                	ld	s3,8(sp)
    8000485c:	6145                	addi	sp,sp,48
    8000485e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004860:	0304a983          	lw	s3,48(s1)
    80004864:	ffffd097          	auipc	ra,0xffffd
    80004868:	3dc080e7          	jalr	988(ra) # 80001c40 <myproc>
    8000486c:	4124                	lw	s1,64(a0)
    8000486e:	413484b3          	sub	s1,s1,s3
    80004872:	0014b493          	seqz	s1,s1
    80004876:	bfc1                	j	80004846 <holdingsleep+0x24>

0000000080004878 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004878:	1141                	addi	sp,sp,-16
    8000487a:	e406                	sd	ra,8(sp)
    8000487c:	e022                	sd	s0,0(sp)
    8000487e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004880:	00004597          	auipc	a1,0x4
    80004884:	fa058593          	addi	a1,a1,-96 # 80008820 <userret+0x790>
    80004888:	00024517          	auipc	a0,0x24
    8000488c:	ed050513          	addi	a0,a0,-304 # 80028758 <ftable>
    80004890:	ffffc097          	auipc	ra,0xffffc
    80004894:	30a080e7          	jalr	778(ra) # 80000b9a <initlock>
}
    80004898:	60a2                	ld	ra,8(sp)
    8000489a:	6402                	ld	s0,0(sp)
    8000489c:	0141                	addi	sp,sp,16
    8000489e:	8082                	ret

00000000800048a0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800048a0:	1101                	addi	sp,sp,-32
    800048a2:	ec06                	sd	ra,24(sp)
    800048a4:	e822                	sd	s0,16(sp)
    800048a6:	e426                	sd	s1,8(sp)
    800048a8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048aa:	00024517          	auipc	a0,0x24
    800048ae:	eae50513          	addi	a0,a0,-338 # 80028758 <ftable>
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	436080e7          	jalr	1078(ra) # 80000ce8 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048ba:	00024497          	auipc	s1,0x24
    800048be:	ebe48493          	addi	s1,s1,-322 # 80028778 <ftable+0x20>
    800048c2:	00025717          	auipc	a4,0x25
    800048c6:	e5670713          	addi	a4,a4,-426 # 80029718 <ftable+0xfc0>
    if(f->ref == 0){
    800048ca:	40dc                	lw	a5,4(s1)
    800048cc:	cf99                	beqz	a5,800048ea <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048ce:	02848493          	addi	s1,s1,40
    800048d2:	fee49ce3          	bne	s1,a4,800048ca <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800048d6:	00024517          	auipc	a0,0x24
    800048da:	e8250513          	addi	a0,a0,-382 # 80028758 <ftable>
    800048de:	ffffc097          	auipc	ra,0xffffc
    800048e2:	47a080e7          	jalr	1146(ra) # 80000d58 <release>
  return 0;
    800048e6:	4481                	li	s1,0
    800048e8:	a819                	j	800048fe <filealloc+0x5e>
      f->ref = 1;
    800048ea:	4785                	li	a5,1
    800048ec:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800048ee:	00024517          	auipc	a0,0x24
    800048f2:	e6a50513          	addi	a0,a0,-406 # 80028758 <ftable>
    800048f6:	ffffc097          	auipc	ra,0xffffc
    800048fa:	462080e7          	jalr	1122(ra) # 80000d58 <release>
}
    800048fe:	8526                	mv	a0,s1
    80004900:	60e2                	ld	ra,24(sp)
    80004902:	6442                	ld	s0,16(sp)
    80004904:	64a2                	ld	s1,8(sp)
    80004906:	6105                	addi	sp,sp,32
    80004908:	8082                	ret

000000008000490a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000490a:	1101                	addi	sp,sp,-32
    8000490c:	ec06                	sd	ra,24(sp)
    8000490e:	e822                	sd	s0,16(sp)
    80004910:	e426                	sd	s1,8(sp)
    80004912:	1000                	addi	s0,sp,32
    80004914:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004916:	00024517          	auipc	a0,0x24
    8000491a:	e4250513          	addi	a0,a0,-446 # 80028758 <ftable>
    8000491e:	ffffc097          	auipc	ra,0xffffc
    80004922:	3ca080e7          	jalr	970(ra) # 80000ce8 <acquire>
  if(f->ref < 1)
    80004926:	40dc                	lw	a5,4(s1)
    80004928:	02f05263          	blez	a5,8000494c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000492c:	2785                	addiw	a5,a5,1
    8000492e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004930:	00024517          	auipc	a0,0x24
    80004934:	e2850513          	addi	a0,a0,-472 # 80028758 <ftable>
    80004938:	ffffc097          	auipc	ra,0xffffc
    8000493c:	420080e7          	jalr	1056(ra) # 80000d58 <release>
  return f;
}
    80004940:	8526                	mv	a0,s1
    80004942:	60e2                	ld	ra,24(sp)
    80004944:	6442                	ld	s0,16(sp)
    80004946:	64a2                	ld	s1,8(sp)
    80004948:	6105                	addi	sp,sp,32
    8000494a:	8082                	ret
    panic("filedup");
    8000494c:	00004517          	auipc	a0,0x4
    80004950:	edc50513          	addi	a0,a0,-292 # 80008828 <userret+0x798>
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	bf4080e7          	jalr	-1036(ra) # 80000548 <panic>

000000008000495c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000495c:	7139                	addi	sp,sp,-64
    8000495e:	fc06                	sd	ra,56(sp)
    80004960:	f822                	sd	s0,48(sp)
    80004962:	f426                	sd	s1,40(sp)
    80004964:	f04a                	sd	s2,32(sp)
    80004966:	ec4e                	sd	s3,24(sp)
    80004968:	e852                	sd	s4,16(sp)
    8000496a:	e456                	sd	s5,8(sp)
    8000496c:	0080                	addi	s0,sp,64
    8000496e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004970:	00024517          	auipc	a0,0x24
    80004974:	de850513          	addi	a0,a0,-536 # 80028758 <ftable>
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	370080e7          	jalr	880(ra) # 80000ce8 <acquire>
  if(f->ref < 1)
    80004980:	40dc                	lw	a5,4(s1)
    80004982:	06f05563          	blez	a5,800049ec <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004986:	37fd                	addiw	a5,a5,-1
    80004988:	0007871b          	sext.w	a4,a5
    8000498c:	c0dc                	sw	a5,4(s1)
    8000498e:	06e04763          	bgtz	a4,800049fc <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004992:	0004a903          	lw	s2,0(s1)
    80004996:	0094ca83          	lbu	s5,9(s1)
    8000499a:	0104ba03          	ld	s4,16(s1)
    8000499e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049a2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049a6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049aa:	00024517          	auipc	a0,0x24
    800049ae:	dae50513          	addi	a0,a0,-594 # 80028758 <ftable>
    800049b2:	ffffc097          	auipc	ra,0xffffc
    800049b6:	3a6080e7          	jalr	934(ra) # 80000d58 <release>

  if(ff.type == FD_PIPE){
    800049ba:	4785                	li	a5,1
    800049bc:	06f90163          	beq	s2,a5,80004a1e <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049c0:	3979                	addiw	s2,s2,-2
    800049c2:	4785                	li	a5,1
    800049c4:	0527e463          	bltu	a5,s2,80004a0c <fileclose+0xb0>
    begin_op(ff.ip->dev);
    800049c8:	0009a503          	lw	a0,0(s3)
    800049cc:	00000097          	auipc	ra,0x0
    800049d0:	9f6080e7          	jalr	-1546(ra) # 800043c2 <begin_op>
    iput(ff.ip);
    800049d4:	854e                	mv	a0,s3
    800049d6:	fffff097          	auipc	ra,0xfffff
    800049da:	116080e7          	jalr	278(ra) # 80003aec <iput>
    end_op(ff.ip->dev);
    800049de:	0009a503          	lw	a0,0(s3)
    800049e2:	00000097          	auipc	ra,0x0
    800049e6:	a8a080e7          	jalr	-1398(ra) # 8000446c <end_op>
    800049ea:	a00d                	j	80004a0c <fileclose+0xb0>
    panic("fileclose");
    800049ec:	00004517          	auipc	a0,0x4
    800049f0:	e4450513          	addi	a0,a0,-444 # 80008830 <userret+0x7a0>
    800049f4:	ffffc097          	auipc	ra,0xffffc
    800049f8:	b54080e7          	jalr	-1196(ra) # 80000548 <panic>
    release(&ftable.lock);
    800049fc:	00024517          	auipc	a0,0x24
    80004a00:	d5c50513          	addi	a0,a0,-676 # 80028758 <ftable>
    80004a04:	ffffc097          	auipc	ra,0xffffc
    80004a08:	354080e7          	jalr	852(ra) # 80000d58 <release>
  }
}
    80004a0c:	70e2                	ld	ra,56(sp)
    80004a0e:	7442                	ld	s0,48(sp)
    80004a10:	74a2                	ld	s1,40(sp)
    80004a12:	7902                	ld	s2,32(sp)
    80004a14:	69e2                	ld	s3,24(sp)
    80004a16:	6a42                	ld	s4,16(sp)
    80004a18:	6aa2                	ld	s5,8(sp)
    80004a1a:	6121                	addi	sp,sp,64
    80004a1c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a1e:	85d6                	mv	a1,s5
    80004a20:	8552                	mv	a0,s4
    80004a22:	00000097          	auipc	ra,0x0
    80004a26:	376080e7          	jalr	886(ra) # 80004d98 <pipeclose>
    80004a2a:	b7cd                	j	80004a0c <fileclose+0xb0>

0000000080004a2c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a2c:	715d                	addi	sp,sp,-80
    80004a2e:	e486                	sd	ra,72(sp)
    80004a30:	e0a2                	sd	s0,64(sp)
    80004a32:	fc26                	sd	s1,56(sp)
    80004a34:	f84a                	sd	s2,48(sp)
    80004a36:	f44e                	sd	s3,40(sp)
    80004a38:	0880                	addi	s0,sp,80
    80004a3a:	84aa                	mv	s1,a0
    80004a3c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a3e:	ffffd097          	auipc	ra,0xffffd
    80004a42:	202080e7          	jalr	514(ra) # 80001c40 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a46:	409c                	lw	a5,0(s1)
    80004a48:	37f9                	addiw	a5,a5,-2
    80004a4a:	4705                	li	a4,1
    80004a4c:	04f76763          	bltu	a4,a5,80004a9a <filestat+0x6e>
    80004a50:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a52:	6c88                	ld	a0,24(s1)
    80004a54:	fffff097          	auipc	ra,0xfffff
    80004a58:	f8a080e7          	jalr	-118(ra) # 800039de <ilock>
    stati(f->ip, &st);
    80004a5c:	fb840593          	addi	a1,s0,-72
    80004a60:	6c88                	ld	a0,24(s1)
    80004a62:	fffff097          	auipc	ra,0xfffff
    80004a66:	1e2080e7          	jalr	482(ra) # 80003c44 <stati>
    iunlock(f->ip);
    80004a6a:	6c88                	ld	a0,24(s1)
    80004a6c:	fffff097          	auipc	ra,0xfffff
    80004a70:	034080e7          	jalr	52(ra) # 80003aa0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a74:	46e1                	li	a3,24
    80004a76:	fb840613          	addi	a2,s0,-72
    80004a7a:	85ce                	mv	a1,s3
    80004a7c:	05893503          	ld	a0,88(s2)
    80004a80:	ffffd097          	auipc	ra,0xffffd
    80004a84:	eb2080e7          	jalr	-334(ra) # 80001932 <copyout>
    80004a88:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a8c:	60a6                	ld	ra,72(sp)
    80004a8e:	6406                	ld	s0,64(sp)
    80004a90:	74e2                	ld	s1,56(sp)
    80004a92:	7942                	ld	s2,48(sp)
    80004a94:	79a2                	ld	s3,40(sp)
    80004a96:	6161                	addi	sp,sp,80
    80004a98:	8082                	ret
  return -1;
    80004a9a:	557d                	li	a0,-1
    80004a9c:	bfc5                	j	80004a8c <filestat+0x60>

0000000080004a9e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a9e:	7179                	addi	sp,sp,-48
    80004aa0:	f406                	sd	ra,40(sp)
    80004aa2:	f022                	sd	s0,32(sp)
    80004aa4:	ec26                	sd	s1,24(sp)
    80004aa6:	e84a                	sd	s2,16(sp)
    80004aa8:	e44e                	sd	s3,8(sp)
    80004aaa:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004aac:	00854783          	lbu	a5,8(a0)
    80004ab0:	c7c5                	beqz	a5,80004b58 <fileread+0xba>
    80004ab2:	84aa                	mv	s1,a0
    80004ab4:	89ae                	mv	s3,a1
    80004ab6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ab8:	411c                	lw	a5,0(a0)
    80004aba:	4705                	li	a4,1
    80004abc:	04e78963          	beq	a5,a4,80004b0e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ac0:	470d                	li	a4,3
    80004ac2:	04e78d63          	beq	a5,a4,80004b1c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004ac6:	4709                	li	a4,2
    80004ac8:	08e79063          	bne	a5,a4,80004b48 <fileread+0xaa>
    ilock(f->ip);
    80004acc:	6d08                	ld	a0,24(a0)
    80004ace:	fffff097          	auipc	ra,0xfffff
    80004ad2:	f10080e7          	jalr	-240(ra) # 800039de <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ad6:	874a                	mv	a4,s2
    80004ad8:	5094                	lw	a3,32(s1)
    80004ada:	864e                	mv	a2,s3
    80004adc:	4585                	li	a1,1
    80004ade:	6c88                	ld	a0,24(s1)
    80004ae0:	fffff097          	auipc	ra,0xfffff
    80004ae4:	18e080e7          	jalr	398(ra) # 80003c6e <readi>
    80004ae8:	892a                	mv	s2,a0
    80004aea:	00a05563          	blez	a0,80004af4 <fileread+0x56>
      f->off += r;
    80004aee:	509c                	lw	a5,32(s1)
    80004af0:	9fa9                	addw	a5,a5,a0
    80004af2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004af4:	6c88                	ld	a0,24(s1)
    80004af6:	fffff097          	auipc	ra,0xfffff
    80004afa:	faa080e7          	jalr	-86(ra) # 80003aa0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004afe:	854a                	mv	a0,s2
    80004b00:	70a2                	ld	ra,40(sp)
    80004b02:	7402                	ld	s0,32(sp)
    80004b04:	64e2                	ld	s1,24(sp)
    80004b06:	6942                	ld	s2,16(sp)
    80004b08:	69a2                	ld	s3,8(sp)
    80004b0a:	6145                	addi	sp,sp,48
    80004b0c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b0e:	6908                	ld	a0,16(a0)
    80004b10:	00000097          	auipc	ra,0x0
    80004b14:	406080e7          	jalr	1030(ra) # 80004f16 <piperead>
    80004b18:	892a                	mv	s2,a0
    80004b1a:	b7d5                	j	80004afe <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b1c:	02451783          	lh	a5,36(a0)
    80004b20:	03079693          	slli	a3,a5,0x30
    80004b24:	92c1                	srli	a3,a3,0x30
    80004b26:	4725                	li	a4,9
    80004b28:	02d76a63          	bltu	a4,a3,80004b5c <fileread+0xbe>
    80004b2c:	0792                	slli	a5,a5,0x4
    80004b2e:	00024717          	auipc	a4,0x24
    80004b32:	b8a70713          	addi	a4,a4,-1142 # 800286b8 <devsw>
    80004b36:	97ba                	add	a5,a5,a4
    80004b38:	639c                	ld	a5,0(a5)
    80004b3a:	c39d                	beqz	a5,80004b60 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80004b3c:	86b2                	mv	a3,a2
    80004b3e:	862e                	mv	a2,a1
    80004b40:	4585                	li	a1,1
    80004b42:	9782                	jalr	a5
    80004b44:	892a                	mv	s2,a0
    80004b46:	bf65                	j	80004afe <fileread+0x60>
    panic("fileread");
    80004b48:	00004517          	auipc	a0,0x4
    80004b4c:	cf850513          	addi	a0,a0,-776 # 80008840 <userret+0x7b0>
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	9f8080e7          	jalr	-1544(ra) # 80000548 <panic>
    return -1;
    80004b58:	597d                	li	s2,-1
    80004b5a:	b755                	j	80004afe <fileread+0x60>
      return -1;
    80004b5c:	597d                	li	s2,-1
    80004b5e:	b745                	j	80004afe <fileread+0x60>
    80004b60:	597d                	li	s2,-1
    80004b62:	bf71                	j	80004afe <fileread+0x60>

0000000080004b64 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004b64:	00954783          	lbu	a5,9(a0)
    80004b68:	14078663          	beqz	a5,80004cb4 <filewrite+0x150>
{
    80004b6c:	715d                	addi	sp,sp,-80
    80004b6e:	e486                	sd	ra,72(sp)
    80004b70:	e0a2                	sd	s0,64(sp)
    80004b72:	fc26                	sd	s1,56(sp)
    80004b74:	f84a                	sd	s2,48(sp)
    80004b76:	f44e                	sd	s3,40(sp)
    80004b78:	f052                	sd	s4,32(sp)
    80004b7a:	ec56                	sd	s5,24(sp)
    80004b7c:	e85a                	sd	s6,16(sp)
    80004b7e:	e45e                	sd	s7,8(sp)
    80004b80:	e062                	sd	s8,0(sp)
    80004b82:	0880                	addi	s0,sp,80
    80004b84:	84aa                	mv	s1,a0
    80004b86:	8aae                	mv	s5,a1
    80004b88:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b8a:	411c                	lw	a5,0(a0)
    80004b8c:	4705                	li	a4,1
    80004b8e:	02e78263          	beq	a5,a4,80004bb2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b92:	470d                	li	a4,3
    80004b94:	02e78563          	beq	a5,a4,80004bbe <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004b98:	4709                	li	a4,2
    80004b9a:	10e79563          	bne	a5,a4,80004ca4 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b9e:	0ec05f63          	blez	a2,80004c9c <filewrite+0x138>
    int i = 0;
    80004ba2:	4981                	li	s3,0
    80004ba4:	6b05                	lui	s6,0x1
    80004ba6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004baa:	6b85                	lui	s7,0x1
    80004bac:	c00b8b9b          	addiw	s7,s7,-1024
    80004bb0:	a851                	j	80004c44 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004bb2:	6908                	ld	a0,16(a0)
    80004bb4:	00000097          	auipc	ra,0x0
    80004bb8:	254080e7          	jalr	596(ra) # 80004e08 <pipewrite>
    80004bbc:	a865                	j	80004c74 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004bbe:	02451783          	lh	a5,36(a0)
    80004bc2:	03079693          	slli	a3,a5,0x30
    80004bc6:	92c1                	srli	a3,a3,0x30
    80004bc8:	4725                	li	a4,9
    80004bca:	0ed76763          	bltu	a4,a3,80004cb8 <filewrite+0x154>
    80004bce:	0792                	slli	a5,a5,0x4
    80004bd0:	00024717          	auipc	a4,0x24
    80004bd4:	ae870713          	addi	a4,a4,-1304 # 800286b8 <devsw>
    80004bd8:	97ba                	add	a5,a5,a4
    80004bda:	679c                	ld	a5,8(a5)
    80004bdc:	c3e5                	beqz	a5,80004cbc <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004bde:	86b2                	mv	a3,a2
    80004be0:	862e                	mv	a2,a1
    80004be2:	4585                	li	a1,1
    80004be4:	9782                	jalr	a5
    80004be6:	a079                	j	80004c74 <filewrite+0x110>
    80004be8:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    80004bec:	6c9c                	ld	a5,24(s1)
    80004bee:	4388                	lw	a0,0(a5)
    80004bf0:	fffff097          	auipc	ra,0xfffff
    80004bf4:	7d2080e7          	jalr	2002(ra) # 800043c2 <begin_op>
      ilock(f->ip);
    80004bf8:	6c88                	ld	a0,24(s1)
    80004bfa:	fffff097          	auipc	ra,0xfffff
    80004bfe:	de4080e7          	jalr	-540(ra) # 800039de <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c02:	8762                	mv	a4,s8
    80004c04:	5094                	lw	a3,32(s1)
    80004c06:	01598633          	add	a2,s3,s5
    80004c0a:	4585                	li	a1,1
    80004c0c:	6c88                	ld	a0,24(s1)
    80004c0e:	fffff097          	auipc	ra,0xfffff
    80004c12:	154080e7          	jalr	340(ra) # 80003d62 <writei>
    80004c16:	892a                	mv	s2,a0
    80004c18:	02a05e63          	blez	a0,80004c54 <filewrite+0xf0>
        f->off += r;
    80004c1c:	509c                	lw	a5,32(s1)
    80004c1e:	9fa9                	addw	a5,a5,a0
    80004c20:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004c22:	6c88                	ld	a0,24(s1)
    80004c24:	fffff097          	auipc	ra,0xfffff
    80004c28:	e7c080e7          	jalr	-388(ra) # 80003aa0 <iunlock>
      end_op(f->ip->dev);
    80004c2c:	6c9c                	ld	a5,24(s1)
    80004c2e:	4388                	lw	a0,0(a5)
    80004c30:	00000097          	auipc	ra,0x0
    80004c34:	83c080e7          	jalr	-1988(ra) # 8000446c <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004c38:	052c1a63          	bne	s8,s2,80004c8c <filewrite+0x128>
        panic("short filewrite");
      i += r;
    80004c3c:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80004c40:	0349d763          	bge	s3,s4,80004c6e <filewrite+0x10a>
      int n1 = n - i;
    80004c44:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004c48:	893e                	mv	s2,a5
    80004c4a:	2781                	sext.w	a5,a5
    80004c4c:	f8fb5ee3          	bge	s6,a5,80004be8 <filewrite+0x84>
    80004c50:	895e                	mv	s2,s7
    80004c52:	bf59                	j	80004be8 <filewrite+0x84>
      iunlock(f->ip);
    80004c54:	6c88                	ld	a0,24(s1)
    80004c56:	fffff097          	auipc	ra,0xfffff
    80004c5a:	e4a080e7          	jalr	-438(ra) # 80003aa0 <iunlock>
      end_op(f->ip->dev);
    80004c5e:	6c9c                	ld	a5,24(s1)
    80004c60:	4388                	lw	a0,0(a5)
    80004c62:	00000097          	auipc	ra,0x0
    80004c66:	80a080e7          	jalr	-2038(ra) # 8000446c <end_op>
      if(r < 0)
    80004c6a:	fc0957e3          	bgez	s2,80004c38 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004c6e:	8552                	mv	a0,s4
    80004c70:	033a1863          	bne	s4,s3,80004ca0 <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c74:	60a6                	ld	ra,72(sp)
    80004c76:	6406                	ld	s0,64(sp)
    80004c78:	74e2                	ld	s1,56(sp)
    80004c7a:	7942                	ld	s2,48(sp)
    80004c7c:	79a2                	ld	s3,40(sp)
    80004c7e:	7a02                	ld	s4,32(sp)
    80004c80:	6ae2                	ld	s5,24(sp)
    80004c82:	6b42                	ld	s6,16(sp)
    80004c84:	6ba2                	ld	s7,8(sp)
    80004c86:	6c02                	ld	s8,0(sp)
    80004c88:	6161                	addi	sp,sp,80
    80004c8a:	8082                	ret
        panic("short filewrite");
    80004c8c:	00004517          	auipc	a0,0x4
    80004c90:	bc450513          	addi	a0,a0,-1084 # 80008850 <userret+0x7c0>
    80004c94:	ffffc097          	auipc	ra,0xffffc
    80004c98:	8b4080e7          	jalr	-1868(ra) # 80000548 <panic>
    int i = 0;
    80004c9c:	4981                	li	s3,0
    80004c9e:	bfc1                	j	80004c6e <filewrite+0x10a>
    ret = (i == n ? n : -1);
    80004ca0:	557d                	li	a0,-1
    80004ca2:	bfc9                	j	80004c74 <filewrite+0x110>
    panic("filewrite");
    80004ca4:	00004517          	auipc	a0,0x4
    80004ca8:	bbc50513          	addi	a0,a0,-1092 # 80008860 <userret+0x7d0>
    80004cac:	ffffc097          	auipc	ra,0xffffc
    80004cb0:	89c080e7          	jalr	-1892(ra) # 80000548 <panic>
    return -1;
    80004cb4:	557d                	li	a0,-1
}
    80004cb6:	8082                	ret
      return -1;
    80004cb8:	557d                	li	a0,-1
    80004cba:	bf6d                	j	80004c74 <filewrite+0x110>
    80004cbc:	557d                	li	a0,-1
    80004cbe:	bf5d                	j	80004c74 <filewrite+0x110>

0000000080004cc0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004cc0:	7179                	addi	sp,sp,-48
    80004cc2:	f406                	sd	ra,40(sp)
    80004cc4:	f022                	sd	s0,32(sp)
    80004cc6:	ec26                	sd	s1,24(sp)
    80004cc8:	e84a                	sd	s2,16(sp)
    80004cca:	e44e                	sd	s3,8(sp)
    80004ccc:	e052                	sd	s4,0(sp)
    80004cce:	1800                	addi	s0,sp,48
    80004cd0:	84aa                	mv	s1,a0
    80004cd2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004cd4:	0005b023          	sd	zero,0(a1)
    80004cd8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004cdc:	00000097          	auipc	ra,0x0
    80004ce0:	bc4080e7          	jalr	-1084(ra) # 800048a0 <filealloc>
    80004ce4:	e088                	sd	a0,0(s1)
    80004ce6:	c549                	beqz	a0,80004d70 <pipealloc+0xb0>
    80004ce8:	00000097          	auipc	ra,0x0
    80004cec:	bb8080e7          	jalr	-1096(ra) # 800048a0 <filealloc>
    80004cf0:	00aa3023          	sd	a0,0(s4)
    80004cf4:	c925                	beqz	a0,80004d64 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004cf6:	ffffc097          	auipc	ra,0xffffc
    80004cfa:	da2080e7          	jalr	-606(ra) # 80000a98 <kalloc>
    80004cfe:	892a                	mv	s2,a0
    80004d00:	cd39                	beqz	a0,80004d5e <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    80004d02:	4985                	li	s3,1
    80004d04:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004d08:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004d0c:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004d10:	22052023          	sw	zero,544(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    80004d14:	02000613          	li	a2,32
    80004d18:	4581                	li	a1,0
    80004d1a:	ffffc097          	auipc	ra,0xffffc
    80004d1e:	23c080e7          	jalr	572(ra) # 80000f56 <memset>
  (*f0)->type = FD_PIPE;
    80004d22:	609c                	ld	a5,0(s1)
    80004d24:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d28:	609c                	ld	a5,0(s1)
    80004d2a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d2e:	609c                	ld	a5,0(s1)
    80004d30:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d34:	609c                	ld	a5,0(s1)
    80004d36:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d3a:	000a3783          	ld	a5,0(s4)
    80004d3e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d42:	000a3783          	ld	a5,0(s4)
    80004d46:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d4a:	000a3783          	ld	a5,0(s4)
    80004d4e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d52:	000a3783          	ld	a5,0(s4)
    80004d56:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d5a:	4501                	li	a0,0
    80004d5c:	a025                	j	80004d84 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d5e:	6088                	ld	a0,0(s1)
    80004d60:	e501                	bnez	a0,80004d68 <pipealloc+0xa8>
    80004d62:	a039                	j	80004d70 <pipealloc+0xb0>
    80004d64:	6088                	ld	a0,0(s1)
    80004d66:	c51d                	beqz	a0,80004d94 <pipealloc+0xd4>
    fileclose(*f0);
    80004d68:	00000097          	auipc	ra,0x0
    80004d6c:	bf4080e7          	jalr	-1036(ra) # 8000495c <fileclose>
  if(*f1)
    80004d70:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d74:	557d                	li	a0,-1
  if(*f1)
    80004d76:	c799                	beqz	a5,80004d84 <pipealloc+0xc4>
    fileclose(*f1);
    80004d78:	853e                	mv	a0,a5
    80004d7a:	00000097          	auipc	ra,0x0
    80004d7e:	be2080e7          	jalr	-1054(ra) # 8000495c <fileclose>
  return -1;
    80004d82:	557d                	li	a0,-1
}
    80004d84:	70a2                	ld	ra,40(sp)
    80004d86:	7402                	ld	s0,32(sp)
    80004d88:	64e2                	ld	s1,24(sp)
    80004d8a:	6942                	ld	s2,16(sp)
    80004d8c:	69a2                	ld	s3,8(sp)
    80004d8e:	6a02                	ld	s4,0(sp)
    80004d90:	6145                	addi	sp,sp,48
    80004d92:	8082                	ret
  return -1;
    80004d94:	557d                	li	a0,-1
    80004d96:	b7fd                	j	80004d84 <pipealloc+0xc4>

0000000080004d98 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d98:	1101                	addi	sp,sp,-32
    80004d9a:	ec06                	sd	ra,24(sp)
    80004d9c:	e822                	sd	s0,16(sp)
    80004d9e:	e426                	sd	s1,8(sp)
    80004da0:	e04a                	sd	s2,0(sp)
    80004da2:	1000                	addi	s0,sp,32
    80004da4:	84aa                	mv	s1,a0
    80004da6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004da8:	ffffc097          	auipc	ra,0xffffc
    80004dac:	f40080e7          	jalr	-192(ra) # 80000ce8 <acquire>
  if(writable){
    80004db0:	02090d63          	beqz	s2,80004dea <pipeclose+0x52>
    pi->writeopen = 0;
    80004db4:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004db8:	22048513          	addi	a0,s1,544
    80004dbc:	ffffd097          	auipc	ra,0xffffd
    80004dc0:	7da080e7          	jalr	2010(ra) # 80002596 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004dc4:	2284b783          	ld	a5,552(s1)
    80004dc8:	eb95                	bnez	a5,80004dfc <pipeclose+0x64>
    release(&pi->lock);
    80004dca:	8526                	mv	a0,s1
    80004dcc:	ffffc097          	auipc	ra,0xffffc
    80004dd0:	f8c080e7          	jalr	-116(ra) # 80000d58 <release>
    kfree((char*)pi);
    80004dd4:	8526                	mv	a0,s1
    80004dd6:	ffffc097          	auipc	ra,0xffffc
    80004dda:	b3a080e7          	jalr	-1222(ra) # 80000910 <kfree>
  } else
    release(&pi->lock);
}
    80004dde:	60e2                	ld	ra,24(sp)
    80004de0:	6442                	ld	s0,16(sp)
    80004de2:	64a2                	ld	s1,8(sp)
    80004de4:	6902                	ld	s2,0(sp)
    80004de6:	6105                	addi	sp,sp,32
    80004de8:	8082                	ret
    pi->readopen = 0;
    80004dea:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004dee:	22448513          	addi	a0,s1,548
    80004df2:	ffffd097          	auipc	ra,0xffffd
    80004df6:	7a4080e7          	jalr	1956(ra) # 80002596 <wakeup>
    80004dfa:	b7e9                	j	80004dc4 <pipeclose+0x2c>
    release(&pi->lock);
    80004dfc:	8526                	mv	a0,s1
    80004dfe:	ffffc097          	auipc	ra,0xffffc
    80004e02:	f5a080e7          	jalr	-166(ra) # 80000d58 <release>
}
    80004e06:	bfe1                	j	80004dde <pipeclose+0x46>

0000000080004e08 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e08:	711d                	addi	sp,sp,-96
    80004e0a:	ec86                	sd	ra,88(sp)
    80004e0c:	e8a2                	sd	s0,80(sp)
    80004e0e:	e4a6                	sd	s1,72(sp)
    80004e10:	e0ca                	sd	s2,64(sp)
    80004e12:	fc4e                	sd	s3,56(sp)
    80004e14:	f852                	sd	s4,48(sp)
    80004e16:	f456                	sd	s5,40(sp)
    80004e18:	f05a                	sd	s6,32(sp)
    80004e1a:	ec5e                	sd	s7,24(sp)
    80004e1c:	e862                	sd	s8,16(sp)
    80004e1e:	1080                	addi	s0,sp,96
    80004e20:	84aa                	mv	s1,a0
    80004e22:	8aae                	mv	s5,a1
    80004e24:	8a32                	mv	s4,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004e26:	ffffd097          	auipc	ra,0xffffd
    80004e2a:	e1a080e7          	jalr	-486(ra) # 80001c40 <myproc>
    80004e2e:	8baa                	mv	s7,a0

  acquire(&pi->lock);
    80004e30:	8526                	mv	a0,s1
    80004e32:	ffffc097          	auipc	ra,0xffffc
    80004e36:	eb6080e7          	jalr	-330(ra) # 80000ce8 <acquire>
  for(i = 0; i < n; i++){
    80004e3a:	09405f63          	blez	s4,80004ed8 <pipewrite+0xd0>
    80004e3e:	fffa0b1b          	addiw	s6,s4,-1
    80004e42:	1b02                	slli	s6,s6,0x20
    80004e44:	020b5b13          	srli	s6,s6,0x20
    80004e48:	001a8793          	addi	a5,s5,1
    80004e4c:	9b3e                	add	s6,s6,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004e4e:	22048993          	addi	s3,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004e52:	22448913          	addi	s2,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e56:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004e58:	2204a783          	lw	a5,544(s1)
    80004e5c:	2244a703          	lw	a4,548(s1)
    80004e60:	2007879b          	addiw	a5,a5,512
    80004e64:	02f71e63          	bne	a4,a5,80004ea0 <pipewrite+0x98>
      if(pi->readopen == 0 || myproc()->killed){
    80004e68:	2284a783          	lw	a5,552(s1)
    80004e6c:	c3d9                	beqz	a5,80004ef2 <pipewrite+0xea>
    80004e6e:	ffffd097          	auipc	ra,0xffffd
    80004e72:	dd2080e7          	jalr	-558(ra) # 80001c40 <myproc>
    80004e76:	5d1c                	lw	a5,56(a0)
    80004e78:	efad                	bnez	a5,80004ef2 <pipewrite+0xea>
      wakeup(&pi->nread);
    80004e7a:	854e                	mv	a0,s3
    80004e7c:	ffffd097          	auipc	ra,0xffffd
    80004e80:	71a080e7          	jalr	1818(ra) # 80002596 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e84:	85a6                	mv	a1,s1
    80004e86:	854a                	mv	a0,s2
    80004e88:	ffffd097          	auipc	ra,0xffffd
    80004e8c:	58e080e7          	jalr	1422(ra) # 80002416 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004e90:	2204a783          	lw	a5,544(s1)
    80004e94:	2244a703          	lw	a4,548(s1)
    80004e98:	2007879b          	addiw	a5,a5,512
    80004e9c:	fcf706e3          	beq	a4,a5,80004e68 <pipewrite+0x60>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ea0:	4685                	li	a3,1
    80004ea2:	8656                	mv	a2,s5
    80004ea4:	faf40593          	addi	a1,s0,-81
    80004ea8:	058bb503          	ld	a0,88(s7) # 1058 <_entry-0x7fffefa8>
    80004eac:	ffffd097          	auipc	ra,0xffffd
    80004eb0:	b12080e7          	jalr	-1262(ra) # 800019be <copyin>
    80004eb4:	03850263          	beq	a0,s8,80004ed8 <pipewrite+0xd0>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004eb8:	2244a783          	lw	a5,548(s1)
    80004ebc:	0017871b          	addiw	a4,a5,1
    80004ec0:	22e4a223          	sw	a4,548(s1)
    80004ec4:	1ff7f793          	andi	a5,a5,511
    80004ec8:	97a6                	add	a5,a5,s1
    80004eca:	faf44703          	lbu	a4,-81(s0)
    80004ece:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004ed2:	0a85                	addi	s5,s5,1
    80004ed4:	f96a92e3          	bne	s5,s6,80004e58 <pipewrite+0x50>
  }
  wakeup(&pi->nread);
    80004ed8:	22048513          	addi	a0,s1,544
    80004edc:	ffffd097          	auipc	ra,0xffffd
    80004ee0:	6ba080e7          	jalr	1722(ra) # 80002596 <wakeup>
  release(&pi->lock);
    80004ee4:	8526                	mv	a0,s1
    80004ee6:	ffffc097          	auipc	ra,0xffffc
    80004eea:	e72080e7          	jalr	-398(ra) # 80000d58 <release>
  return n;
    80004eee:	8552                	mv	a0,s4
    80004ef0:	a039                	j	80004efe <pipewrite+0xf6>
        release(&pi->lock);
    80004ef2:	8526                	mv	a0,s1
    80004ef4:	ffffc097          	auipc	ra,0xffffc
    80004ef8:	e64080e7          	jalr	-412(ra) # 80000d58 <release>
        return -1;
    80004efc:	557d                	li	a0,-1
}
    80004efe:	60e6                	ld	ra,88(sp)
    80004f00:	6446                	ld	s0,80(sp)
    80004f02:	64a6                	ld	s1,72(sp)
    80004f04:	6906                	ld	s2,64(sp)
    80004f06:	79e2                	ld	s3,56(sp)
    80004f08:	7a42                	ld	s4,48(sp)
    80004f0a:	7aa2                	ld	s5,40(sp)
    80004f0c:	7b02                	ld	s6,32(sp)
    80004f0e:	6be2                	ld	s7,24(sp)
    80004f10:	6c42                	ld	s8,16(sp)
    80004f12:	6125                	addi	sp,sp,96
    80004f14:	8082                	ret

0000000080004f16 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f16:	715d                	addi	sp,sp,-80
    80004f18:	e486                	sd	ra,72(sp)
    80004f1a:	e0a2                	sd	s0,64(sp)
    80004f1c:	fc26                	sd	s1,56(sp)
    80004f1e:	f84a                	sd	s2,48(sp)
    80004f20:	f44e                	sd	s3,40(sp)
    80004f22:	f052                	sd	s4,32(sp)
    80004f24:	ec56                	sd	s5,24(sp)
    80004f26:	e85a                	sd	s6,16(sp)
    80004f28:	0880                	addi	s0,sp,80
    80004f2a:	84aa                	mv	s1,a0
    80004f2c:	892e                	mv	s2,a1
    80004f2e:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004f30:	ffffd097          	auipc	ra,0xffffd
    80004f34:	d10080e7          	jalr	-752(ra) # 80001c40 <myproc>
    80004f38:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	ffffc097          	auipc	ra,0xffffc
    80004f40:	dac080e7          	jalr	-596(ra) # 80000ce8 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f44:	2204a703          	lw	a4,544(s1)
    80004f48:	2244a783          	lw	a5,548(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f4c:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f50:	02f71763          	bne	a4,a5,80004f7e <piperead+0x68>
    80004f54:	22c4a783          	lw	a5,556(s1)
    80004f58:	c39d                	beqz	a5,80004f7e <piperead+0x68>
    if(myproc()->killed){
    80004f5a:	ffffd097          	auipc	ra,0xffffd
    80004f5e:	ce6080e7          	jalr	-794(ra) # 80001c40 <myproc>
    80004f62:	5d1c                	lw	a5,56(a0)
    80004f64:	ebc1                	bnez	a5,80004ff4 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f66:	85a6                	mv	a1,s1
    80004f68:	854e                	mv	a0,s3
    80004f6a:	ffffd097          	auipc	ra,0xffffd
    80004f6e:	4ac080e7          	jalr	1196(ra) # 80002416 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f72:	2204a703          	lw	a4,544(s1)
    80004f76:	2244a783          	lw	a5,548(s1)
    80004f7a:	fcf70de3          	beq	a4,a5,80004f54 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f7e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f80:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f82:	05405363          	blez	s4,80004fc8 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004f86:	2204a783          	lw	a5,544(s1)
    80004f8a:	2244a703          	lw	a4,548(s1)
    80004f8e:	02f70d63          	beq	a4,a5,80004fc8 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f92:	0017871b          	addiw	a4,a5,1
    80004f96:	22e4a023          	sw	a4,544(s1)
    80004f9a:	1ff7f793          	andi	a5,a5,511
    80004f9e:	97a6                	add	a5,a5,s1
    80004fa0:	0207c783          	lbu	a5,32(a5)
    80004fa4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fa8:	4685                	li	a3,1
    80004faa:	fbf40613          	addi	a2,s0,-65
    80004fae:	85ca                	mv	a1,s2
    80004fb0:	058ab503          	ld	a0,88(s5)
    80004fb4:	ffffd097          	auipc	ra,0xffffd
    80004fb8:	97e080e7          	jalr	-1666(ra) # 80001932 <copyout>
    80004fbc:	01650663          	beq	a0,s6,80004fc8 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fc0:	2985                	addiw	s3,s3,1
    80004fc2:	0905                	addi	s2,s2,1
    80004fc4:	fd3a11e3          	bne	s4,s3,80004f86 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004fc8:	22448513          	addi	a0,s1,548
    80004fcc:	ffffd097          	auipc	ra,0xffffd
    80004fd0:	5ca080e7          	jalr	1482(ra) # 80002596 <wakeup>
  release(&pi->lock);
    80004fd4:	8526                	mv	a0,s1
    80004fd6:	ffffc097          	auipc	ra,0xffffc
    80004fda:	d82080e7          	jalr	-638(ra) # 80000d58 <release>
  return i;
}
    80004fde:	854e                	mv	a0,s3
    80004fe0:	60a6                	ld	ra,72(sp)
    80004fe2:	6406                	ld	s0,64(sp)
    80004fe4:	74e2                	ld	s1,56(sp)
    80004fe6:	7942                	ld	s2,48(sp)
    80004fe8:	79a2                	ld	s3,40(sp)
    80004fea:	7a02                	ld	s4,32(sp)
    80004fec:	6ae2                	ld	s5,24(sp)
    80004fee:	6b42                	ld	s6,16(sp)
    80004ff0:	6161                	addi	sp,sp,80
    80004ff2:	8082                	ret
      release(&pi->lock);
    80004ff4:	8526                	mv	a0,s1
    80004ff6:	ffffc097          	auipc	ra,0xffffc
    80004ffa:	d62080e7          	jalr	-670(ra) # 80000d58 <release>
      return -1;
    80004ffe:	59fd                	li	s3,-1
    80005000:	bff9                	j	80004fde <piperead+0xc8>

0000000080005002 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005002:	de010113          	addi	sp,sp,-544
    80005006:	20113c23          	sd	ra,536(sp)
    8000500a:	20813823          	sd	s0,528(sp)
    8000500e:	20913423          	sd	s1,520(sp)
    80005012:	21213023          	sd	s2,512(sp)
    80005016:	ffce                	sd	s3,504(sp)
    80005018:	fbd2                	sd	s4,496(sp)
    8000501a:	f7d6                	sd	s5,488(sp)
    8000501c:	f3da                	sd	s6,480(sp)
    8000501e:	efde                	sd	s7,472(sp)
    80005020:	ebe2                	sd	s8,464(sp)
    80005022:	e7e6                	sd	s9,456(sp)
    80005024:	e3ea                	sd	s10,448(sp)
    80005026:	ff6e                	sd	s11,440(sp)
    80005028:	1400                	addi	s0,sp,544
    8000502a:	892a                	mv	s2,a0
    8000502c:	dea43423          	sd	a0,-536(s0)
    80005030:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005034:	ffffd097          	auipc	ra,0xffffd
    80005038:	c0c080e7          	jalr	-1012(ra) # 80001c40 <myproc>
    8000503c:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    8000503e:	4501                	li	a0,0
    80005040:	fffff097          	auipc	ra,0xfffff
    80005044:	382080e7          	jalr	898(ra) # 800043c2 <begin_op>

  if((ip = namei(path)) == 0){
    80005048:	854a                	mv	a0,s2
    8000504a:	fffff097          	auipc	ra,0xfffff
    8000504e:	11e080e7          	jalr	286(ra) # 80004168 <namei>
    80005052:	cd25                	beqz	a0,800050ca <exec+0xc8>
    80005054:	8aaa                	mv	s5,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005056:	fffff097          	auipc	ra,0xfffff
    8000505a:	988080e7          	jalr	-1656(ra) # 800039de <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000505e:	04000713          	li	a4,64
    80005062:	4681                	li	a3,0
    80005064:	e4840613          	addi	a2,s0,-440
    80005068:	4581                	li	a1,0
    8000506a:	8556                	mv	a0,s5
    8000506c:	fffff097          	auipc	ra,0xfffff
    80005070:	c02080e7          	jalr	-1022(ra) # 80003c6e <readi>
    80005074:	04000793          	li	a5,64
    80005078:	00f51a63          	bne	a0,a5,8000508c <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000507c:	e4842703          	lw	a4,-440(s0)
    80005080:	464c47b7          	lui	a5,0x464c4
    80005084:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005088:	04f70863          	beq	a4,a5,800050d8 <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000508c:	8556                	mv	a0,s5
    8000508e:	fffff097          	auipc	ra,0xfffff
    80005092:	b8e080e7          	jalr	-1138(ra) # 80003c1c <iunlockput>
    end_op(ROOTDEV);
    80005096:	4501                	li	a0,0
    80005098:	fffff097          	auipc	ra,0xfffff
    8000509c:	3d4080e7          	jalr	980(ra) # 8000446c <end_op>
  }
  return -1;
    800050a0:	557d                	li	a0,-1
}
    800050a2:	21813083          	ld	ra,536(sp)
    800050a6:	21013403          	ld	s0,528(sp)
    800050aa:	20813483          	ld	s1,520(sp)
    800050ae:	20013903          	ld	s2,512(sp)
    800050b2:	79fe                	ld	s3,504(sp)
    800050b4:	7a5e                	ld	s4,496(sp)
    800050b6:	7abe                	ld	s5,488(sp)
    800050b8:	7b1e                	ld	s6,480(sp)
    800050ba:	6bfe                	ld	s7,472(sp)
    800050bc:	6c5e                	ld	s8,464(sp)
    800050be:	6cbe                	ld	s9,456(sp)
    800050c0:	6d1e                	ld	s10,448(sp)
    800050c2:	7dfa                	ld	s11,440(sp)
    800050c4:	22010113          	addi	sp,sp,544
    800050c8:	8082                	ret
    end_op(ROOTDEV);
    800050ca:	4501                	li	a0,0
    800050cc:	fffff097          	auipc	ra,0xfffff
    800050d0:	3a0080e7          	jalr	928(ra) # 8000446c <end_op>
    return -1;
    800050d4:	557d                	li	a0,-1
    800050d6:	b7f1                	j	800050a2 <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    800050d8:	8526                	mv	a0,s1
    800050da:	ffffd097          	auipc	ra,0xffffd
    800050de:	c2a080e7          	jalr	-982(ra) # 80001d04 <proc_pagetable>
    800050e2:	8b2a                	mv	s6,a0
    800050e4:	d545                	beqz	a0,8000508c <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050e6:	e6842783          	lw	a5,-408(s0)
    800050ea:	e8045703          	lhu	a4,-384(s0)
    800050ee:	10070263          	beqz	a4,800051f2 <exec+0x1f0>
  sz = 0;
    800050f2:	de043c23          	sd	zero,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050f6:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800050fa:	6a05                	lui	s4,0x1
    800050fc:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005100:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005104:	6d85                	lui	s11,0x1
    80005106:	7d7d                	lui	s10,0xfffff
    80005108:	a88d                	j	8000517a <exec+0x178>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000510a:	00003517          	auipc	a0,0x3
    8000510e:	76650513          	addi	a0,a0,1894 # 80008870 <userret+0x7e0>
    80005112:	ffffb097          	auipc	ra,0xffffb
    80005116:	436080e7          	jalr	1078(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000511a:	874a                	mv	a4,s2
    8000511c:	009c86bb          	addw	a3,s9,s1
    80005120:	4581                	li	a1,0
    80005122:	8556                	mv	a0,s5
    80005124:	fffff097          	auipc	ra,0xfffff
    80005128:	b4a080e7          	jalr	-1206(ra) # 80003c6e <readi>
    8000512c:	2501                	sext.w	a0,a0
    8000512e:	10a91863          	bne	s2,a0,8000523e <exec+0x23c>
  for(i = 0; i < sz; i += PGSIZE){
    80005132:	009d84bb          	addw	s1,s11,s1
    80005136:	013d09bb          	addw	s3,s10,s3
    8000513a:	0374f263          	bgeu	s1,s7,8000515e <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    8000513e:	02049593          	slli	a1,s1,0x20
    80005142:	9181                	srli	a1,a1,0x20
    80005144:	95e2                	add	a1,a1,s8
    80005146:	855a                	mv	a0,s6
    80005148:	ffffc097          	auipc	ra,0xffffc
    8000514c:	208080e7          	jalr	520(ra) # 80001350 <walkaddr>
    80005150:	862a                	mv	a2,a0
    if(pa == 0)
    80005152:	dd45                	beqz	a0,8000510a <exec+0x108>
      n = PGSIZE;
    80005154:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005156:	fd49f2e3          	bgeu	s3,s4,8000511a <exec+0x118>
      n = sz - i;
    8000515a:	894e                	mv	s2,s3
    8000515c:	bf7d                	j	8000511a <exec+0x118>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000515e:	e0843783          	ld	a5,-504(s0)
    80005162:	0017869b          	addiw	a3,a5,1
    80005166:	e0d43423          	sd	a3,-504(s0)
    8000516a:	e0043783          	ld	a5,-512(s0)
    8000516e:	0387879b          	addiw	a5,a5,56
    80005172:	e8045703          	lhu	a4,-384(s0)
    80005176:	08e6d063          	bge	a3,a4,800051f6 <exec+0x1f4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000517a:	2781                	sext.w	a5,a5
    8000517c:	e0f43023          	sd	a5,-512(s0)
    80005180:	03800713          	li	a4,56
    80005184:	86be                	mv	a3,a5
    80005186:	e1040613          	addi	a2,s0,-496
    8000518a:	4581                	li	a1,0
    8000518c:	8556                	mv	a0,s5
    8000518e:	fffff097          	auipc	ra,0xfffff
    80005192:	ae0080e7          	jalr	-1312(ra) # 80003c6e <readi>
    80005196:	03800793          	li	a5,56
    8000519a:	0af51263          	bne	a0,a5,8000523e <exec+0x23c>
    if(ph.type != ELF_PROG_LOAD)
    8000519e:	e1042783          	lw	a5,-496(s0)
    800051a2:	4705                	li	a4,1
    800051a4:	fae79de3          	bne	a5,a4,8000515e <exec+0x15c>
    if(ph.memsz < ph.filesz)
    800051a8:	e3843603          	ld	a2,-456(s0)
    800051ac:	e3043783          	ld	a5,-464(s0)
    800051b0:	08f66763          	bltu	a2,a5,8000523e <exec+0x23c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051b4:	e2043783          	ld	a5,-480(s0)
    800051b8:	963e                	add	a2,a2,a5
    800051ba:	08f66263          	bltu	a2,a5,8000523e <exec+0x23c>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051be:	df843583          	ld	a1,-520(s0)
    800051c2:	855a                	mv	a0,s6
    800051c4:	ffffc097          	auipc	ra,0xffffc
    800051c8:	594080e7          	jalr	1428(ra) # 80001758 <uvmalloc>
    800051cc:	dea43c23          	sd	a0,-520(s0)
    800051d0:	c53d                	beqz	a0,8000523e <exec+0x23c>
    if(ph.vaddr % PGSIZE != 0)
    800051d2:	e2043c03          	ld	s8,-480(s0)
    800051d6:	de043783          	ld	a5,-544(s0)
    800051da:	00fc77b3          	and	a5,s8,a5
    800051de:	e3a5                	bnez	a5,8000523e <exec+0x23c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051e0:	e1842c83          	lw	s9,-488(s0)
    800051e4:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051e8:	f60b8be3          	beqz	s7,8000515e <exec+0x15c>
    800051ec:	89de                	mv	s3,s7
    800051ee:	4481                	li	s1,0
    800051f0:	b7b9                	j	8000513e <exec+0x13c>
  sz = 0;
    800051f2:	de043c23          	sd	zero,-520(s0)
  iunlockput(ip);
    800051f6:	8556                	mv	a0,s5
    800051f8:	fffff097          	auipc	ra,0xfffff
    800051fc:	a24080e7          	jalr	-1500(ra) # 80003c1c <iunlockput>
  end_op(ROOTDEV);
    80005200:	4501                	li	a0,0
    80005202:	fffff097          	auipc	ra,0xfffff
    80005206:	26a080e7          	jalr	618(ra) # 8000446c <end_op>
  p = myproc();
    8000520a:	ffffd097          	auipc	ra,0xffffd
    8000520e:	a36080e7          	jalr	-1482(ra) # 80001c40 <myproc>
    80005212:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005214:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    80005218:	6585                	lui	a1,0x1
    8000521a:	15fd                	addi	a1,a1,-1
    8000521c:	df843783          	ld	a5,-520(s0)
    80005220:	95be                	add	a1,a1,a5
    80005222:	77fd                	lui	a5,0xfffff
    80005224:	8dfd                	and	a1,a1,a5
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005226:	6609                	lui	a2,0x2
    80005228:	962e                	add	a2,a2,a1
    8000522a:	855a                	mv	a0,s6
    8000522c:	ffffc097          	auipc	ra,0xffffc
    80005230:	52c080e7          	jalr	1324(ra) # 80001758 <uvmalloc>
    80005234:	892a                	mv	s2,a0
    80005236:	dea43c23          	sd	a0,-520(s0)
  ip = 0;
    8000523a:	4a81                	li	s5,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000523c:	ed01                	bnez	a0,80005254 <exec+0x252>
    proc_freepagetable(pagetable, sz);
    8000523e:	df843583          	ld	a1,-520(s0)
    80005242:	855a                	mv	a0,s6
    80005244:	ffffd097          	auipc	ra,0xffffd
    80005248:	bc0080e7          	jalr	-1088(ra) # 80001e04 <proc_freepagetable>
  if(ip){
    8000524c:	e40a90e3          	bnez	s5,8000508c <exec+0x8a>
  return -1;
    80005250:	557d                	li	a0,-1
    80005252:	bd81                	j	800050a2 <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005254:	75f9                	lui	a1,0xffffe
    80005256:	95aa                	add	a1,a1,a0
    80005258:	855a                	mv	a0,s6
    8000525a:	ffffc097          	auipc	ra,0xffffc
    8000525e:	6a6080e7          	jalr	1702(ra) # 80001900 <uvmclear>
  stackbase = sp - PGSIZE;
    80005262:	7c7d                	lui	s8,0xfffff
    80005264:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    80005266:	df043783          	ld	a5,-528(s0)
    8000526a:	6388                	ld	a0,0(a5)
    8000526c:	c52d                	beqz	a0,800052d6 <exec+0x2d4>
    8000526e:	e8840993          	addi	s3,s0,-376
    80005272:	f8840a93          	addi	s5,s0,-120
    80005276:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005278:	ffffc097          	auipc	ra,0xffffc
    8000527c:	e62080e7          	jalr	-414(ra) # 800010da <strlen>
    80005280:	0015079b          	addiw	a5,a0,1
    80005284:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005288:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000528c:	0f896b63          	bltu	s2,s8,80005382 <exec+0x380>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005290:	df043d03          	ld	s10,-528(s0)
    80005294:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7ffcefa4>
    80005298:	8552                	mv	a0,s4
    8000529a:	ffffc097          	auipc	ra,0xffffc
    8000529e:	e40080e7          	jalr	-448(ra) # 800010da <strlen>
    800052a2:	0015069b          	addiw	a3,a0,1
    800052a6:	8652                	mv	a2,s4
    800052a8:	85ca                	mv	a1,s2
    800052aa:	855a                	mv	a0,s6
    800052ac:	ffffc097          	auipc	ra,0xffffc
    800052b0:	686080e7          	jalr	1670(ra) # 80001932 <copyout>
    800052b4:	0c054963          	bltz	a0,80005386 <exec+0x384>
    ustack[argc] = sp;
    800052b8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800052bc:	0485                	addi	s1,s1,1
    800052be:	008d0793          	addi	a5,s10,8
    800052c2:	def43823          	sd	a5,-528(s0)
    800052c6:	008d3503          	ld	a0,8(s10)
    800052ca:	c909                	beqz	a0,800052dc <exec+0x2da>
    if(argc >= MAXARG)
    800052cc:	09a1                	addi	s3,s3,8
    800052ce:	fb3a95e3          	bne	s5,s3,80005278 <exec+0x276>
  ip = 0;
    800052d2:	4a81                	li	s5,0
    800052d4:	b7ad                	j	8000523e <exec+0x23c>
  sp = sz;
    800052d6:	df843903          	ld	s2,-520(s0)
  for(argc = 0; argv[argc]; argc++) {
    800052da:	4481                	li	s1,0
  ustack[argc] = 0;
    800052dc:	00349793          	slli	a5,s1,0x3
    800052e0:	f9040713          	addi	a4,s0,-112
    800052e4:	97ba                	add	a5,a5,a4
    800052e6:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcee9c>
  sp -= (argc+1) * sizeof(uint64);
    800052ea:	00148693          	addi	a3,s1,1
    800052ee:	068e                	slli	a3,a3,0x3
    800052f0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800052f4:	ff097913          	andi	s2,s2,-16
  ip = 0;
    800052f8:	4a81                	li	s5,0
  if(sp < stackbase)
    800052fa:	f58962e3          	bltu	s2,s8,8000523e <exec+0x23c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800052fe:	e8840613          	addi	a2,s0,-376
    80005302:	85ca                	mv	a1,s2
    80005304:	855a                	mv	a0,s6
    80005306:	ffffc097          	auipc	ra,0xffffc
    8000530a:	62c080e7          	jalr	1580(ra) # 80001932 <copyout>
    8000530e:	06054e63          	bltz	a0,8000538a <exec+0x388>
  p->tf->a1 = sp;
    80005312:	060bb783          	ld	a5,96(s7)
    80005316:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000531a:	de843783          	ld	a5,-536(s0)
    8000531e:	0007c703          	lbu	a4,0(a5)
    80005322:	cf11                	beqz	a4,8000533e <exec+0x33c>
    80005324:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005326:	02f00693          	li	a3,47
    8000532a:	a039                	j	80005338 <exec+0x336>
      last = s+1;
    8000532c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005330:	0785                	addi	a5,a5,1
    80005332:	fff7c703          	lbu	a4,-1(a5)
    80005336:	c701                	beqz	a4,8000533e <exec+0x33c>
    if(*s == '/')
    80005338:	fed71ce3          	bne	a4,a3,80005330 <exec+0x32e>
    8000533c:	bfc5                	j	8000532c <exec+0x32a>
  safestrcpy(p->name, last, sizeof(p->name));
    8000533e:	4641                	li	a2,16
    80005340:	de843583          	ld	a1,-536(s0)
    80005344:	160b8513          	addi	a0,s7,352
    80005348:	ffffc097          	auipc	ra,0xffffc
    8000534c:	d60080e7          	jalr	-672(ra) # 800010a8 <safestrcpy>
  oldpagetable = p->pagetable;
    80005350:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80005354:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    80005358:	df843783          	ld	a5,-520(s0)
    8000535c:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80005360:	060bb783          	ld	a5,96(s7)
    80005364:	e6043703          	ld	a4,-416(s0)
    80005368:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    8000536a:	060bb783          	ld	a5,96(s7)
    8000536e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005372:	85e6                	mv	a1,s9
    80005374:	ffffd097          	auipc	ra,0xffffd
    80005378:	a90080e7          	jalr	-1392(ra) # 80001e04 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000537c:	0004851b          	sext.w	a0,s1
    80005380:	b30d                	j	800050a2 <exec+0xa0>
  ip = 0;
    80005382:	4a81                	li	s5,0
    80005384:	bd6d                	j	8000523e <exec+0x23c>
    80005386:	4a81                	li	s5,0
    80005388:	bd5d                	j	8000523e <exec+0x23c>
    8000538a:	4a81                	li	s5,0
    8000538c:	bd4d                	j	8000523e <exec+0x23c>

000000008000538e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000538e:	7179                	addi	sp,sp,-48
    80005390:	f406                	sd	ra,40(sp)
    80005392:	f022                	sd	s0,32(sp)
    80005394:	ec26                	sd	s1,24(sp)
    80005396:	e84a                	sd	s2,16(sp)
    80005398:	1800                	addi	s0,sp,48
    8000539a:	892e                	mv	s2,a1
    8000539c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000539e:	fdc40593          	addi	a1,s0,-36
    800053a2:	ffffe097          	auipc	ra,0xffffe
    800053a6:	916080e7          	jalr	-1770(ra) # 80002cb8 <argint>
    800053aa:	04054063          	bltz	a0,800053ea <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800053ae:	fdc42703          	lw	a4,-36(s0)
    800053b2:	47bd                	li	a5,15
    800053b4:	02e7ed63          	bltu	a5,a4,800053ee <argfd+0x60>
    800053b8:	ffffd097          	auipc	ra,0xffffd
    800053bc:	888080e7          	jalr	-1912(ra) # 80001c40 <myproc>
    800053c0:	fdc42703          	lw	a4,-36(s0)
    800053c4:	01a70793          	addi	a5,a4,26
    800053c8:	078e                	slli	a5,a5,0x3
    800053ca:	953e                	add	a0,a0,a5
    800053cc:	651c                	ld	a5,8(a0)
    800053ce:	c395                	beqz	a5,800053f2 <argfd+0x64>
    return -1;
  if(pfd)
    800053d0:	00090463          	beqz	s2,800053d8 <argfd+0x4a>
    *pfd = fd;
    800053d4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800053d8:	4501                	li	a0,0
  if(pf)
    800053da:	c091                	beqz	s1,800053de <argfd+0x50>
    *pf = f;
    800053dc:	e09c                	sd	a5,0(s1)
}
    800053de:	70a2                	ld	ra,40(sp)
    800053e0:	7402                	ld	s0,32(sp)
    800053e2:	64e2                	ld	s1,24(sp)
    800053e4:	6942                	ld	s2,16(sp)
    800053e6:	6145                	addi	sp,sp,48
    800053e8:	8082                	ret
    return -1;
    800053ea:	557d                	li	a0,-1
    800053ec:	bfcd                	j	800053de <argfd+0x50>
    return -1;
    800053ee:	557d                	li	a0,-1
    800053f0:	b7fd                	j	800053de <argfd+0x50>
    800053f2:	557d                	li	a0,-1
    800053f4:	b7ed                	j	800053de <argfd+0x50>

00000000800053f6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053f6:	1101                	addi	sp,sp,-32
    800053f8:	ec06                	sd	ra,24(sp)
    800053fa:	e822                	sd	s0,16(sp)
    800053fc:	e426                	sd	s1,8(sp)
    800053fe:	1000                	addi	s0,sp,32
    80005400:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005402:	ffffd097          	auipc	ra,0xffffd
    80005406:	83e080e7          	jalr	-1986(ra) # 80001c40 <myproc>
    8000540a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000540c:	0d850793          	addi	a5,a0,216
    80005410:	4501                	li	a0,0
    80005412:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005414:	6398                	ld	a4,0(a5)
    80005416:	cb19                	beqz	a4,8000542c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005418:	2505                	addiw	a0,a0,1
    8000541a:	07a1                	addi	a5,a5,8
    8000541c:	fed51ce3          	bne	a0,a3,80005414 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005420:	557d                	li	a0,-1
}
    80005422:	60e2                	ld	ra,24(sp)
    80005424:	6442                	ld	s0,16(sp)
    80005426:	64a2                	ld	s1,8(sp)
    80005428:	6105                	addi	sp,sp,32
    8000542a:	8082                	ret
      p->ofile[fd] = f;
    8000542c:	01a50793          	addi	a5,a0,26
    80005430:	078e                	slli	a5,a5,0x3
    80005432:	963e                	add	a2,a2,a5
    80005434:	e604                	sd	s1,8(a2)
      return fd;
    80005436:	b7f5                	j	80005422 <fdalloc+0x2c>

0000000080005438 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005438:	715d                	addi	sp,sp,-80
    8000543a:	e486                	sd	ra,72(sp)
    8000543c:	e0a2                	sd	s0,64(sp)
    8000543e:	fc26                	sd	s1,56(sp)
    80005440:	f84a                	sd	s2,48(sp)
    80005442:	f44e                	sd	s3,40(sp)
    80005444:	f052                	sd	s4,32(sp)
    80005446:	ec56                	sd	s5,24(sp)
    80005448:	0880                	addi	s0,sp,80
    8000544a:	89ae                	mv	s3,a1
    8000544c:	8ab2                	mv	s5,a2
    8000544e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005450:	fb040593          	addi	a1,s0,-80
    80005454:	fffff097          	auipc	ra,0xfffff
    80005458:	d32080e7          	jalr	-718(ra) # 80004186 <nameiparent>
    8000545c:	892a                	mv	s2,a0
    8000545e:	12050e63          	beqz	a0,8000559a <create+0x162>
    return 0;

  ilock(dp);
    80005462:	ffffe097          	auipc	ra,0xffffe
    80005466:	57c080e7          	jalr	1404(ra) # 800039de <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000546a:	4601                	li	a2,0
    8000546c:	fb040593          	addi	a1,s0,-80
    80005470:	854a                	mv	a0,s2
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	a24080e7          	jalr	-1500(ra) # 80003e96 <dirlookup>
    8000547a:	84aa                	mv	s1,a0
    8000547c:	c921                	beqz	a0,800054cc <create+0x94>
    iunlockput(dp);
    8000547e:	854a                	mv	a0,s2
    80005480:	ffffe097          	auipc	ra,0xffffe
    80005484:	79c080e7          	jalr	1948(ra) # 80003c1c <iunlockput>
    ilock(ip);
    80005488:	8526                	mv	a0,s1
    8000548a:	ffffe097          	auipc	ra,0xffffe
    8000548e:	554080e7          	jalr	1364(ra) # 800039de <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005492:	2981                	sext.w	s3,s3
    80005494:	4789                	li	a5,2
    80005496:	02f99463          	bne	s3,a5,800054be <create+0x86>
    8000549a:	04c4d783          	lhu	a5,76(s1)
    8000549e:	37f9                	addiw	a5,a5,-2
    800054a0:	17c2                	slli	a5,a5,0x30
    800054a2:	93c1                	srli	a5,a5,0x30
    800054a4:	4705                	li	a4,1
    800054a6:	00f76c63          	bltu	a4,a5,800054be <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800054aa:	8526                	mv	a0,s1
    800054ac:	60a6                	ld	ra,72(sp)
    800054ae:	6406                	ld	s0,64(sp)
    800054b0:	74e2                	ld	s1,56(sp)
    800054b2:	7942                	ld	s2,48(sp)
    800054b4:	79a2                	ld	s3,40(sp)
    800054b6:	7a02                	ld	s4,32(sp)
    800054b8:	6ae2                	ld	s5,24(sp)
    800054ba:	6161                	addi	sp,sp,80
    800054bc:	8082                	ret
    iunlockput(ip);
    800054be:	8526                	mv	a0,s1
    800054c0:	ffffe097          	auipc	ra,0xffffe
    800054c4:	75c080e7          	jalr	1884(ra) # 80003c1c <iunlockput>
    return 0;
    800054c8:	4481                	li	s1,0
    800054ca:	b7c5                	j	800054aa <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800054cc:	85ce                	mv	a1,s3
    800054ce:	00092503          	lw	a0,0(s2)
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	374080e7          	jalr	884(ra) # 80003846 <ialloc>
    800054da:	84aa                	mv	s1,a0
    800054dc:	c521                	beqz	a0,80005524 <create+0xec>
  ilock(ip);
    800054de:	ffffe097          	auipc	ra,0xffffe
    800054e2:	500080e7          	jalr	1280(ra) # 800039de <ilock>
  ip->major = major;
    800054e6:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    800054ea:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    800054ee:	4a05                	li	s4,1
    800054f0:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    800054f4:	8526                	mv	a0,s1
    800054f6:	ffffe097          	auipc	ra,0xffffe
    800054fa:	41e080e7          	jalr	1054(ra) # 80003914 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054fe:	2981                	sext.w	s3,s3
    80005500:	03498a63          	beq	s3,s4,80005534 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005504:	40d0                	lw	a2,4(s1)
    80005506:	fb040593          	addi	a1,s0,-80
    8000550a:	854a                	mv	a0,s2
    8000550c:	fffff097          	auipc	ra,0xfffff
    80005510:	b9a080e7          	jalr	-1126(ra) # 800040a6 <dirlink>
    80005514:	06054b63          	bltz	a0,8000558a <create+0x152>
  iunlockput(dp);
    80005518:	854a                	mv	a0,s2
    8000551a:	ffffe097          	auipc	ra,0xffffe
    8000551e:	702080e7          	jalr	1794(ra) # 80003c1c <iunlockput>
  return ip;
    80005522:	b761                	j	800054aa <create+0x72>
    panic("create: ialloc");
    80005524:	00003517          	auipc	a0,0x3
    80005528:	36c50513          	addi	a0,a0,876 # 80008890 <userret+0x800>
    8000552c:	ffffb097          	auipc	ra,0xffffb
    80005530:	01c080e7          	jalr	28(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    80005534:	05295783          	lhu	a5,82(s2)
    80005538:	2785                	addiw	a5,a5,1
    8000553a:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    8000553e:	854a                	mv	a0,s2
    80005540:	ffffe097          	auipc	ra,0xffffe
    80005544:	3d4080e7          	jalr	980(ra) # 80003914 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005548:	40d0                	lw	a2,4(s1)
    8000554a:	00003597          	auipc	a1,0x3
    8000554e:	35658593          	addi	a1,a1,854 # 800088a0 <userret+0x810>
    80005552:	8526                	mv	a0,s1
    80005554:	fffff097          	auipc	ra,0xfffff
    80005558:	b52080e7          	jalr	-1198(ra) # 800040a6 <dirlink>
    8000555c:	00054f63          	bltz	a0,8000557a <create+0x142>
    80005560:	00492603          	lw	a2,4(s2)
    80005564:	00003597          	auipc	a1,0x3
    80005568:	34458593          	addi	a1,a1,836 # 800088a8 <userret+0x818>
    8000556c:	8526                	mv	a0,s1
    8000556e:	fffff097          	auipc	ra,0xfffff
    80005572:	b38080e7          	jalr	-1224(ra) # 800040a6 <dirlink>
    80005576:	f80557e3          	bgez	a0,80005504 <create+0xcc>
      panic("create dots");
    8000557a:	00003517          	auipc	a0,0x3
    8000557e:	33650513          	addi	a0,a0,822 # 800088b0 <userret+0x820>
    80005582:	ffffb097          	auipc	ra,0xffffb
    80005586:	fc6080e7          	jalr	-58(ra) # 80000548 <panic>
    panic("create: dirlink");
    8000558a:	00003517          	auipc	a0,0x3
    8000558e:	33650513          	addi	a0,a0,822 # 800088c0 <userret+0x830>
    80005592:	ffffb097          	auipc	ra,0xffffb
    80005596:	fb6080e7          	jalr	-74(ra) # 80000548 <panic>
    return 0;
    8000559a:	84aa                	mv	s1,a0
    8000559c:	b739                	j	800054aa <create+0x72>

000000008000559e <sys_dup>:
{
    8000559e:	7179                	addi	sp,sp,-48
    800055a0:	f406                	sd	ra,40(sp)
    800055a2:	f022                	sd	s0,32(sp)
    800055a4:	ec26                	sd	s1,24(sp)
    800055a6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800055a8:	fd840613          	addi	a2,s0,-40
    800055ac:	4581                	li	a1,0
    800055ae:	4501                	li	a0,0
    800055b0:	00000097          	auipc	ra,0x0
    800055b4:	dde080e7          	jalr	-546(ra) # 8000538e <argfd>
    return -1;
    800055b8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800055ba:	02054363          	bltz	a0,800055e0 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800055be:	fd843503          	ld	a0,-40(s0)
    800055c2:	00000097          	auipc	ra,0x0
    800055c6:	e34080e7          	jalr	-460(ra) # 800053f6 <fdalloc>
    800055ca:	84aa                	mv	s1,a0
    return -1;
    800055cc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800055ce:	00054963          	bltz	a0,800055e0 <sys_dup+0x42>
  filedup(f);
    800055d2:	fd843503          	ld	a0,-40(s0)
    800055d6:	fffff097          	auipc	ra,0xfffff
    800055da:	334080e7          	jalr	820(ra) # 8000490a <filedup>
  return fd;
    800055de:	87a6                	mv	a5,s1
}
    800055e0:	853e                	mv	a0,a5
    800055e2:	70a2                	ld	ra,40(sp)
    800055e4:	7402                	ld	s0,32(sp)
    800055e6:	64e2                	ld	s1,24(sp)
    800055e8:	6145                	addi	sp,sp,48
    800055ea:	8082                	ret

00000000800055ec <sys_read>:
{
    800055ec:	7179                	addi	sp,sp,-48
    800055ee:	f406                	sd	ra,40(sp)
    800055f0:	f022                	sd	s0,32(sp)
    800055f2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055f4:	fe840613          	addi	a2,s0,-24
    800055f8:	4581                	li	a1,0
    800055fa:	4501                	li	a0,0
    800055fc:	00000097          	auipc	ra,0x0
    80005600:	d92080e7          	jalr	-622(ra) # 8000538e <argfd>
    return -1;
    80005604:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005606:	04054163          	bltz	a0,80005648 <sys_read+0x5c>
    8000560a:	fe440593          	addi	a1,s0,-28
    8000560e:	4509                	li	a0,2
    80005610:	ffffd097          	auipc	ra,0xffffd
    80005614:	6a8080e7          	jalr	1704(ra) # 80002cb8 <argint>
    return -1;
    80005618:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000561a:	02054763          	bltz	a0,80005648 <sys_read+0x5c>
    8000561e:	fd840593          	addi	a1,s0,-40
    80005622:	4505                	li	a0,1
    80005624:	ffffd097          	auipc	ra,0xffffd
    80005628:	6b6080e7          	jalr	1718(ra) # 80002cda <argaddr>
    return -1;
    8000562c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000562e:	00054d63          	bltz	a0,80005648 <sys_read+0x5c>
  return fileread(f, p, n);
    80005632:	fe442603          	lw	a2,-28(s0)
    80005636:	fd843583          	ld	a1,-40(s0)
    8000563a:	fe843503          	ld	a0,-24(s0)
    8000563e:	fffff097          	auipc	ra,0xfffff
    80005642:	460080e7          	jalr	1120(ra) # 80004a9e <fileread>
    80005646:	87aa                	mv	a5,a0
}
    80005648:	853e                	mv	a0,a5
    8000564a:	70a2                	ld	ra,40(sp)
    8000564c:	7402                	ld	s0,32(sp)
    8000564e:	6145                	addi	sp,sp,48
    80005650:	8082                	ret

0000000080005652 <sys_write>:
{
    80005652:	7179                	addi	sp,sp,-48
    80005654:	f406                	sd	ra,40(sp)
    80005656:	f022                	sd	s0,32(sp)
    80005658:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000565a:	fe840613          	addi	a2,s0,-24
    8000565e:	4581                	li	a1,0
    80005660:	4501                	li	a0,0
    80005662:	00000097          	auipc	ra,0x0
    80005666:	d2c080e7          	jalr	-724(ra) # 8000538e <argfd>
    return -1;
    8000566a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000566c:	04054163          	bltz	a0,800056ae <sys_write+0x5c>
    80005670:	fe440593          	addi	a1,s0,-28
    80005674:	4509                	li	a0,2
    80005676:	ffffd097          	auipc	ra,0xffffd
    8000567a:	642080e7          	jalr	1602(ra) # 80002cb8 <argint>
    return -1;
    8000567e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005680:	02054763          	bltz	a0,800056ae <sys_write+0x5c>
    80005684:	fd840593          	addi	a1,s0,-40
    80005688:	4505                	li	a0,1
    8000568a:	ffffd097          	auipc	ra,0xffffd
    8000568e:	650080e7          	jalr	1616(ra) # 80002cda <argaddr>
    return -1;
    80005692:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005694:	00054d63          	bltz	a0,800056ae <sys_write+0x5c>
  return filewrite(f, p, n);
    80005698:	fe442603          	lw	a2,-28(s0)
    8000569c:	fd843583          	ld	a1,-40(s0)
    800056a0:	fe843503          	ld	a0,-24(s0)
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	4c0080e7          	jalr	1216(ra) # 80004b64 <filewrite>
    800056ac:	87aa                	mv	a5,a0
}
    800056ae:	853e                	mv	a0,a5
    800056b0:	70a2                	ld	ra,40(sp)
    800056b2:	7402                	ld	s0,32(sp)
    800056b4:	6145                	addi	sp,sp,48
    800056b6:	8082                	ret

00000000800056b8 <sys_close>:
{
    800056b8:	1101                	addi	sp,sp,-32
    800056ba:	ec06                	sd	ra,24(sp)
    800056bc:	e822                	sd	s0,16(sp)
    800056be:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800056c0:	fe040613          	addi	a2,s0,-32
    800056c4:	fec40593          	addi	a1,s0,-20
    800056c8:	4501                	li	a0,0
    800056ca:	00000097          	auipc	ra,0x0
    800056ce:	cc4080e7          	jalr	-828(ra) # 8000538e <argfd>
    return -1;
    800056d2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800056d4:	02054463          	bltz	a0,800056fc <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800056d8:	ffffc097          	auipc	ra,0xffffc
    800056dc:	568080e7          	jalr	1384(ra) # 80001c40 <myproc>
    800056e0:	fec42783          	lw	a5,-20(s0)
    800056e4:	07e9                	addi	a5,a5,26
    800056e6:	078e                	slli	a5,a5,0x3
    800056e8:	97aa                	add	a5,a5,a0
    800056ea:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800056ee:	fe043503          	ld	a0,-32(s0)
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	26a080e7          	jalr	618(ra) # 8000495c <fileclose>
  return 0;
    800056fa:	4781                	li	a5,0
}
    800056fc:	853e                	mv	a0,a5
    800056fe:	60e2                	ld	ra,24(sp)
    80005700:	6442                	ld	s0,16(sp)
    80005702:	6105                	addi	sp,sp,32
    80005704:	8082                	ret

0000000080005706 <sys_fstat>:
{
    80005706:	1101                	addi	sp,sp,-32
    80005708:	ec06                	sd	ra,24(sp)
    8000570a:	e822                	sd	s0,16(sp)
    8000570c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000570e:	fe840613          	addi	a2,s0,-24
    80005712:	4581                	li	a1,0
    80005714:	4501                	li	a0,0
    80005716:	00000097          	auipc	ra,0x0
    8000571a:	c78080e7          	jalr	-904(ra) # 8000538e <argfd>
    return -1;
    8000571e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005720:	02054563          	bltz	a0,8000574a <sys_fstat+0x44>
    80005724:	fe040593          	addi	a1,s0,-32
    80005728:	4505                	li	a0,1
    8000572a:	ffffd097          	auipc	ra,0xffffd
    8000572e:	5b0080e7          	jalr	1456(ra) # 80002cda <argaddr>
    return -1;
    80005732:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005734:	00054b63          	bltz	a0,8000574a <sys_fstat+0x44>
  return filestat(f, st);
    80005738:	fe043583          	ld	a1,-32(s0)
    8000573c:	fe843503          	ld	a0,-24(s0)
    80005740:	fffff097          	auipc	ra,0xfffff
    80005744:	2ec080e7          	jalr	748(ra) # 80004a2c <filestat>
    80005748:	87aa                	mv	a5,a0
}
    8000574a:	853e                	mv	a0,a5
    8000574c:	60e2                	ld	ra,24(sp)
    8000574e:	6442                	ld	s0,16(sp)
    80005750:	6105                	addi	sp,sp,32
    80005752:	8082                	ret

0000000080005754 <sys_link>:
{
    80005754:	7169                	addi	sp,sp,-304
    80005756:	f606                	sd	ra,296(sp)
    80005758:	f222                	sd	s0,288(sp)
    8000575a:	ee26                	sd	s1,280(sp)
    8000575c:	ea4a                	sd	s2,272(sp)
    8000575e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005760:	08000613          	li	a2,128
    80005764:	ed040593          	addi	a1,s0,-304
    80005768:	4501                	li	a0,0
    8000576a:	ffffd097          	auipc	ra,0xffffd
    8000576e:	592080e7          	jalr	1426(ra) # 80002cfc <argstr>
    return -1;
    80005772:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005774:	12054363          	bltz	a0,8000589a <sys_link+0x146>
    80005778:	08000613          	li	a2,128
    8000577c:	f5040593          	addi	a1,s0,-176
    80005780:	4505                	li	a0,1
    80005782:	ffffd097          	auipc	ra,0xffffd
    80005786:	57a080e7          	jalr	1402(ra) # 80002cfc <argstr>
    return -1;
    8000578a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000578c:	10054763          	bltz	a0,8000589a <sys_link+0x146>
  begin_op(ROOTDEV);
    80005790:	4501                	li	a0,0
    80005792:	fffff097          	auipc	ra,0xfffff
    80005796:	c30080e7          	jalr	-976(ra) # 800043c2 <begin_op>
  if((ip = namei(old)) == 0){
    8000579a:	ed040513          	addi	a0,s0,-304
    8000579e:	fffff097          	auipc	ra,0xfffff
    800057a2:	9ca080e7          	jalr	-1590(ra) # 80004168 <namei>
    800057a6:	84aa                	mv	s1,a0
    800057a8:	c559                	beqz	a0,80005836 <sys_link+0xe2>
  ilock(ip);
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	234080e7          	jalr	564(ra) # 800039de <ilock>
  if(ip->type == T_DIR){
    800057b2:	04c49703          	lh	a4,76(s1)
    800057b6:	4785                	li	a5,1
    800057b8:	08f70663          	beq	a4,a5,80005844 <sys_link+0xf0>
  ip->nlink++;
    800057bc:	0524d783          	lhu	a5,82(s1)
    800057c0:	2785                	addiw	a5,a5,1
    800057c2:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800057c6:	8526                	mv	a0,s1
    800057c8:	ffffe097          	auipc	ra,0xffffe
    800057cc:	14c080e7          	jalr	332(ra) # 80003914 <iupdate>
  iunlock(ip);
    800057d0:	8526                	mv	a0,s1
    800057d2:	ffffe097          	auipc	ra,0xffffe
    800057d6:	2ce080e7          	jalr	718(ra) # 80003aa0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800057da:	fd040593          	addi	a1,s0,-48
    800057de:	f5040513          	addi	a0,s0,-176
    800057e2:	fffff097          	auipc	ra,0xfffff
    800057e6:	9a4080e7          	jalr	-1628(ra) # 80004186 <nameiparent>
    800057ea:	892a                	mv	s2,a0
    800057ec:	cd2d                	beqz	a0,80005866 <sys_link+0x112>
  ilock(dp);
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	1f0080e7          	jalr	496(ra) # 800039de <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057f6:	00092703          	lw	a4,0(s2)
    800057fa:	409c                	lw	a5,0(s1)
    800057fc:	06f71063          	bne	a4,a5,8000585c <sys_link+0x108>
    80005800:	40d0                	lw	a2,4(s1)
    80005802:	fd040593          	addi	a1,s0,-48
    80005806:	854a                	mv	a0,s2
    80005808:	fffff097          	auipc	ra,0xfffff
    8000580c:	89e080e7          	jalr	-1890(ra) # 800040a6 <dirlink>
    80005810:	04054663          	bltz	a0,8000585c <sys_link+0x108>
  iunlockput(dp);
    80005814:	854a                	mv	a0,s2
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	406080e7          	jalr	1030(ra) # 80003c1c <iunlockput>
  iput(ip);
    8000581e:	8526                	mv	a0,s1
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	2cc080e7          	jalr	716(ra) # 80003aec <iput>
  end_op(ROOTDEV);
    80005828:	4501                	li	a0,0
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	c42080e7          	jalr	-958(ra) # 8000446c <end_op>
  return 0;
    80005832:	4781                	li	a5,0
    80005834:	a09d                	j	8000589a <sys_link+0x146>
    end_op(ROOTDEV);
    80005836:	4501                	li	a0,0
    80005838:	fffff097          	auipc	ra,0xfffff
    8000583c:	c34080e7          	jalr	-972(ra) # 8000446c <end_op>
    return -1;
    80005840:	57fd                	li	a5,-1
    80005842:	a8a1                	j	8000589a <sys_link+0x146>
    iunlockput(ip);
    80005844:	8526                	mv	a0,s1
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	3d6080e7          	jalr	982(ra) # 80003c1c <iunlockput>
    end_op(ROOTDEV);
    8000584e:	4501                	li	a0,0
    80005850:	fffff097          	auipc	ra,0xfffff
    80005854:	c1c080e7          	jalr	-996(ra) # 8000446c <end_op>
    return -1;
    80005858:	57fd                	li	a5,-1
    8000585a:	a081                	j	8000589a <sys_link+0x146>
    iunlockput(dp);
    8000585c:	854a                	mv	a0,s2
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	3be080e7          	jalr	958(ra) # 80003c1c <iunlockput>
  ilock(ip);
    80005866:	8526                	mv	a0,s1
    80005868:	ffffe097          	auipc	ra,0xffffe
    8000586c:	176080e7          	jalr	374(ra) # 800039de <ilock>
  ip->nlink--;
    80005870:	0524d783          	lhu	a5,82(s1)
    80005874:	37fd                	addiw	a5,a5,-1
    80005876:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000587a:	8526                	mv	a0,s1
    8000587c:	ffffe097          	auipc	ra,0xffffe
    80005880:	098080e7          	jalr	152(ra) # 80003914 <iupdate>
  iunlockput(ip);
    80005884:	8526                	mv	a0,s1
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	396080e7          	jalr	918(ra) # 80003c1c <iunlockput>
  end_op(ROOTDEV);
    8000588e:	4501                	li	a0,0
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	bdc080e7          	jalr	-1060(ra) # 8000446c <end_op>
  return -1;
    80005898:	57fd                	li	a5,-1
}
    8000589a:	853e                	mv	a0,a5
    8000589c:	70b2                	ld	ra,296(sp)
    8000589e:	7412                	ld	s0,288(sp)
    800058a0:	64f2                	ld	s1,280(sp)
    800058a2:	6952                	ld	s2,272(sp)
    800058a4:	6155                	addi	sp,sp,304
    800058a6:	8082                	ret

00000000800058a8 <sys_unlink>:
{
    800058a8:	7151                	addi	sp,sp,-240
    800058aa:	f586                	sd	ra,232(sp)
    800058ac:	f1a2                	sd	s0,224(sp)
    800058ae:	eda6                	sd	s1,216(sp)
    800058b0:	e9ca                	sd	s2,208(sp)
    800058b2:	e5ce                	sd	s3,200(sp)
    800058b4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800058b6:	08000613          	li	a2,128
    800058ba:	f3040593          	addi	a1,s0,-208
    800058be:	4501                	li	a0,0
    800058c0:	ffffd097          	auipc	ra,0xffffd
    800058c4:	43c080e7          	jalr	1084(ra) # 80002cfc <argstr>
    800058c8:	18054463          	bltz	a0,80005a50 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    800058cc:	4501                	li	a0,0
    800058ce:	fffff097          	auipc	ra,0xfffff
    800058d2:	af4080e7          	jalr	-1292(ra) # 800043c2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800058d6:	fb040593          	addi	a1,s0,-80
    800058da:	f3040513          	addi	a0,s0,-208
    800058de:	fffff097          	auipc	ra,0xfffff
    800058e2:	8a8080e7          	jalr	-1880(ra) # 80004186 <nameiparent>
    800058e6:	84aa                	mv	s1,a0
    800058e8:	cd61                	beqz	a0,800059c0 <sys_unlink+0x118>
  ilock(dp);
    800058ea:	ffffe097          	auipc	ra,0xffffe
    800058ee:	0f4080e7          	jalr	244(ra) # 800039de <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058f2:	00003597          	auipc	a1,0x3
    800058f6:	fae58593          	addi	a1,a1,-82 # 800088a0 <userret+0x810>
    800058fa:	fb040513          	addi	a0,s0,-80
    800058fe:	ffffe097          	auipc	ra,0xffffe
    80005902:	57e080e7          	jalr	1406(ra) # 80003e7c <namecmp>
    80005906:	14050c63          	beqz	a0,80005a5e <sys_unlink+0x1b6>
    8000590a:	00003597          	auipc	a1,0x3
    8000590e:	f9e58593          	addi	a1,a1,-98 # 800088a8 <userret+0x818>
    80005912:	fb040513          	addi	a0,s0,-80
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	566080e7          	jalr	1382(ra) # 80003e7c <namecmp>
    8000591e:	14050063          	beqz	a0,80005a5e <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005922:	f2c40613          	addi	a2,s0,-212
    80005926:	fb040593          	addi	a1,s0,-80
    8000592a:	8526                	mv	a0,s1
    8000592c:	ffffe097          	auipc	ra,0xffffe
    80005930:	56a080e7          	jalr	1386(ra) # 80003e96 <dirlookup>
    80005934:	892a                	mv	s2,a0
    80005936:	12050463          	beqz	a0,80005a5e <sys_unlink+0x1b6>
  ilock(ip);
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	0a4080e7          	jalr	164(ra) # 800039de <ilock>
  if(ip->nlink < 1)
    80005942:	05291783          	lh	a5,82(s2)
    80005946:	08f05463          	blez	a5,800059ce <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000594a:	04c91703          	lh	a4,76(s2)
    8000594e:	4785                	li	a5,1
    80005950:	08f70763          	beq	a4,a5,800059de <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005954:	4641                	li	a2,16
    80005956:	4581                	li	a1,0
    80005958:	fc040513          	addi	a0,s0,-64
    8000595c:	ffffb097          	auipc	ra,0xffffb
    80005960:	5fa080e7          	jalr	1530(ra) # 80000f56 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005964:	4741                	li	a4,16
    80005966:	f2c42683          	lw	a3,-212(s0)
    8000596a:	fc040613          	addi	a2,s0,-64
    8000596e:	4581                	li	a1,0
    80005970:	8526                	mv	a0,s1
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	3f0080e7          	jalr	1008(ra) # 80003d62 <writei>
    8000597a:	47c1                	li	a5,16
    8000597c:	0af51763          	bne	a0,a5,80005a2a <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005980:	04c91703          	lh	a4,76(s2)
    80005984:	4785                	li	a5,1
    80005986:	0af70a63          	beq	a4,a5,80005a3a <sys_unlink+0x192>
  iunlockput(dp);
    8000598a:	8526                	mv	a0,s1
    8000598c:	ffffe097          	auipc	ra,0xffffe
    80005990:	290080e7          	jalr	656(ra) # 80003c1c <iunlockput>
  ip->nlink--;
    80005994:	05295783          	lhu	a5,82(s2)
    80005998:	37fd                	addiw	a5,a5,-1
    8000599a:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    8000599e:	854a                	mv	a0,s2
    800059a0:	ffffe097          	auipc	ra,0xffffe
    800059a4:	f74080e7          	jalr	-140(ra) # 80003914 <iupdate>
  iunlockput(ip);
    800059a8:	854a                	mv	a0,s2
    800059aa:	ffffe097          	auipc	ra,0xffffe
    800059ae:	272080e7          	jalr	626(ra) # 80003c1c <iunlockput>
  end_op(ROOTDEV);
    800059b2:	4501                	li	a0,0
    800059b4:	fffff097          	auipc	ra,0xfffff
    800059b8:	ab8080e7          	jalr	-1352(ra) # 8000446c <end_op>
  return 0;
    800059bc:	4501                	li	a0,0
    800059be:	a85d                	j	80005a74 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    800059c0:	4501                	li	a0,0
    800059c2:	fffff097          	auipc	ra,0xfffff
    800059c6:	aaa080e7          	jalr	-1366(ra) # 8000446c <end_op>
    return -1;
    800059ca:	557d                	li	a0,-1
    800059cc:	a065                	j	80005a74 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    800059ce:	00003517          	auipc	a0,0x3
    800059d2:	f0250513          	addi	a0,a0,-254 # 800088d0 <userret+0x840>
    800059d6:	ffffb097          	auipc	ra,0xffffb
    800059da:	b72080e7          	jalr	-1166(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059de:	05492703          	lw	a4,84(s2)
    800059e2:	02000793          	li	a5,32
    800059e6:	f6e7f7e3          	bgeu	a5,a4,80005954 <sys_unlink+0xac>
    800059ea:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059ee:	4741                	li	a4,16
    800059f0:	86ce                	mv	a3,s3
    800059f2:	f1840613          	addi	a2,s0,-232
    800059f6:	4581                	li	a1,0
    800059f8:	854a                	mv	a0,s2
    800059fa:	ffffe097          	auipc	ra,0xffffe
    800059fe:	274080e7          	jalr	628(ra) # 80003c6e <readi>
    80005a02:	47c1                	li	a5,16
    80005a04:	00f51b63          	bne	a0,a5,80005a1a <sys_unlink+0x172>
    if(de.inum != 0)
    80005a08:	f1845783          	lhu	a5,-232(s0)
    80005a0c:	e7a1                	bnez	a5,80005a54 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a0e:	29c1                	addiw	s3,s3,16
    80005a10:	05492783          	lw	a5,84(s2)
    80005a14:	fcf9ede3          	bltu	s3,a5,800059ee <sys_unlink+0x146>
    80005a18:	bf35                	j	80005954 <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005a1a:	00003517          	auipc	a0,0x3
    80005a1e:	ece50513          	addi	a0,a0,-306 # 800088e8 <userret+0x858>
    80005a22:	ffffb097          	auipc	ra,0xffffb
    80005a26:	b26080e7          	jalr	-1242(ra) # 80000548 <panic>
    panic("unlink: writei");
    80005a2a:	00003517          	auipc	a0,0x3
    80005a2e:	ed650513          	addi	a0,a0,-298 # 80008900 <userret+0x870>
    80005a32:	ffffb097          	auipc	ra,0xffffb
    80005a36:	b16080e7          	jalr	-1258(ra) # 80000548 <panic>
    dp->nlink--;
    80005a3a:	0524d783          	lhu	a5,82(s1)
    80005a3e:	37fd                	addiw	a5,a5,-1
    80005a40:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005a44:	8526                	mv	a0,s1
    80005a46:	ffffe097          	auipc	ra,0xffffe
    80005a4a:	ece080e7          	jalr	-306(ra) # 80003914 <iupdate>
    80005a4e:	bf35                	j	8000598a <sys_unlink+0xe2>
    return -1;
    80005a50:	557d                	li	a0,-1
    80005a52:	a00d                	j	80005a74 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005a54:	854a                	mv	a0,s2
    80005a56:	ffffe097          	auipc	ra,0xffffe
    80005a5a:	1c6080e7          	jalr	454(ra) # 80003c1c <iunlockput>
  iunlockput(dp);
    80005a5e:	8526                	mv	a0,s1
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	1bc080e7          	jalr	444(ra) # 80003c1c <iunlockput>
  end_op(ROOTDEV);
    80005a68:	4501                	li	a0,0
    80005a6a:	fffff097          	auipc	ra,0xfffff
    80005a6e:	a02080e7          	jalr	-1534(ra) # 8000446c <end_op>
  return -1;
    80005a72:	557d                	li	a0,-1
}
    80005a74:	70ae                	ld	ra,232(sp)
    80005a76:	740e                	ld	s0,224(sp)
    80005a78:	64ee                	ld	s1,216(sp)
    80005a7a:	694e                	ld	s2,208(sp)
    80005a7c:	69ae                	ld	s3,200(sp)
    80005a7e:	616d                	addi	sp,sp,240
    80005a80:	8082                	ret

0000000080005a82 <sys_open>:

uint64
sys_open(void)
{
    80005a82:	7131                	addi	sp,sp,-192
    80005a84:	fd06                	sd	ra,184(sp)
    80005a86:	f922                	sd	s0,176(sp)
    80005a88:	f526                	sd	s1,168(sp)
    80005a8a:	f14a                	sd	s2,160(sp)
    80005a8c:	ed4e                	sd	s3,152(sp)
    80005a8e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a90:	08000613          	li	a2,128
    80005a94:	f5040593          	addi	a1,s0,-176
    80005a98:	4501                	li	a0,0
    80005a9a:	ffffd097          	auipc	ra,0xffffd
    80005a9e:	262080e7          	jalr	610(ra) # 80002cfc <argstr>
    return -1;
    80005aa2:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005aa4:	0a054963          	bltz	a0,80005b56 <sys_open+0xd4>
    80005aa8:	f4c40593          	addi	a1,s0,-180
    80005aac:	4505                	li	a0,1
    80005aae:	ffffd097          	auipc	ra,0xffffd
    80005ab2:	20a080e7          	jalr	522(ra) # 80002cb8 <argint>
    80005ab6:	0a054063          	bltz	a0,80005b56 <sys_open+0xd4>

  begin_op(ROOTDEV);
    80005aba:	4501                	li	a0,0
    80005abc:	fffff097          	auipc	ra,0xfffff
    80005ac0:	906080e7          	jalr	-1786(ra) # 800043c2 <begin_op>

  if(omode & O_CREATE){
    80005ac4:	f4c42783          	lw	a5,-180(s0)
    80005ac8:	2007f793          	andi	a5,a5,512
    80005acc:	c3dd                	beqz	a5,80005b72 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    80005ace:	4681                	li	a3,0
    80005ad0:	4601                	li	a2,0
    80005ad2:	4589                	li	a1,2
    80005ad4:	f5040513          	addi	a0,s0,-176
    80005ad8:	00000097          	auipc	ra,0x0
    80005adc:	960080e7          	jalr	-1696(ra) # 80005438 <create>
    80005ae0:	892a                	mv	s2,a0
    if(ip == 0){
    80005ae2:	c151                	beqz	a0,80005b66 <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ae4:	04c91703          	lh	a4,76(s2)
    80005ae8:	478d                	li	a5,3
    80005aea:	00f71763          	bne	a4,a5,80005af8 <sys_open+0x76>
    80005aee:	04e95703          	lhu	a4,78(s2)
    80005af2:	47a5                	li	a5,9
    80005af4:	0ce7e663          	bltu	a5,a4,80005bc0 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005af8:	fffff097          	auipc	ra,0xfffff
    80005afc:	da8080e7          	jalr	-600(ra) # 800048a0 <filealloc>
    80005b00:	89aa                	mv	s3,a0
    80005b02:	c97d                	beqz	a0,80005bf8 <sys_open+0x176>
    80005b04:	00000097          	auipc	ra,0x0
    80005b08:	8f2080e7          	jalr	-1806(ra) # 800053f6 <fdalloc>
    80005b0c:	84aa                	mv	s1,a0
    80005b0e:	0e054063          	bltz	a0,80005bee <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b12:	04c91703          	lh	a4,76(s2)
    80005b16:	478d                	li	a5,3
    80005b18:	0cf70063          	beq	a4,a5,80005bd8 <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005b1c:	4789                	li	a5,2
    80005b1e:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005b22:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005b26:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005b2a:	f4c42783          	lw	a5,-180(s0)
    80005b2e:	0017c713          	xori	a4,a5,1
    80005b32:	8b05                	andi	a4,a4,1
    80005b34:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b38:	8b8d                	andi	a5,a5,3
    80005b3a:	00f037b3          	snez	a5,a5
    80005b3e:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005b42:	854a                	mv	a0,s2
    80005b44:	ffffe097          	auipc	ra,0xffffe
    80005b48:	f5c080e7          	jalr	-164(ra) # 80003aa0 <iunlock>
  end_op(ROOTDEV);
    80005b4c:	4501                	li	a0,0
    80005b4e:	fffff097          	auipc	ra,0xfffff
    80005b52:	91e080e7          	jalr	-1762(ra) # 8000446c <end_op>

  return fd;
}
    80005b56:	8526                	mv	a0,s1
    80005b58:	70ea                	ld	ra,184(sp)
    80005b5a:	744a                	ld	s0,176(sp)
    80005b5c:	74aa                	ld	s1,168(sp)
    80005b5e:	790a                	ld	s2,160(sp)
    80005b60:	69ea                	ld	s3,152(sp)
    80005b62:	6129                	addi	sp,sp,192
    80005b64:	8082                	ret
      end_op(ROOTDEV);
    80005b66:	4501                	li	a0,0
    80005b68:	fffff097          	auipc	ra,0xfffff
    80005b6c:	904080e7          	jalr	-1788(ra) # 8000446c <end_op>
      return -1;
    80005b70:	b7dd                	j	80005b56 <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005b72:	f5040513          	addi	a0,s0,-176
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	5f2080e7          	jalr	1522(ra) # 80004168 <namei>
    80005b7e:	892a                	mv	s2,a0
    80005b80:	c90d                	beqz	a0,80005bb2 <sys_open+0x130>
    ilock(ip);
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	e5c080e7          	jalr	-420(ra) # 800039de <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b8a:	04c91703          	lh	a4,76(s2)
    80005b8e:	4785                	li	a5,1
    80005b90:	f4f71ae3          	bne	a4,a5,80005ae4 <sys_open+0x62>
    80005b94:	f4c42783          	lw	a5,-180(s0)
    80005b98:	d3a5                	beqz	a5,80005af8 <sys_open+0x76>
      iunlockput(ip);
    80005b9a:	854a                	mv	a0,s2
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	080080e7          	jalr	128(ra) # 80003c1c <iunlockput>
      end_op(ROOTDEV);
    80005ba4:	4501                	li	a0,0
    80005ba6:	fffff097          	auipc	ra,0xfffff
    80005baa:	8c6080e7          	jalr	-1850(ra) # 8000446c <end_op>
      return -1;
    80005bae:	54fd                	li	s1,-1
    80005bb0:	b75d                	j	80005b56 <sys_open+0xd4>
      end_op(ROOTDEV);
    80005bb2:	4501                	li	a0,0
    80005bb4:	fffff097          	auipc	ra,0xfffff
    80005bb8:	8b8080e7          	jalr	-1864(ra) # 8000446c <end_op>
      return -1;
    80005bbc:	54fd                	li	s1,-1
    80005bbe:	bf61                	j	80005b56 <sys_open+0xd4>
    iunlockput(ip);
    80005bc0:	854a                	mv	a0,s2
    80005bc2:	ffffe097          	auipc	ra,0xffffe
    80005bc6:	05a080e7          	jalr	90(ra) # 80003c1c <iunlockput>
    end_op(ROOTDEV);
    80005bca:	4501                	li	a0,0
    80005bcc:	fffff097          	auipc	ra,0xfffff
    80005bd0:	8a0080e7          	jalr	-1888(ra) # 8000446c <end_op>
    return -1;
    80005bd4:	54fd                	li	s1,-1
    80005bd6:	b741                	j	80005b56 <sys_open+0xd4>
    f->type = FD_DEVICE;
    80005bd8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005bdc:	04e91783          	lh	a5,78(s2)
    80005be0:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005be4:	05091783          	lh	a5,80(s2)
    80005be8:	02f99323          	sh	a5,38(s3)
    80005bec:	bf1d                	j	80005b22 <sys_open+0xa0>
      fileclose(f);
    80005bee:	854e                	mv	a0,s3
    80005bf0:	fffff097          	auipc	ra,0xfffff
    80005bf4:	d6c080e7          	jalr	-660(ra) # 8000495c <fileclose>
    iunlockput(ip);
    80005bf8:	854a                	mv	a0,s2
    80005bfa:	ffffe097          	auipc	ra,0xffffe
    80005bfe:	022080e7          	jalr	34(ra) # 80003c1c <iunlockput>
    end_op(ROOTDEV);
    80005c02:	4501                	li	a0,0
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	868080e7          	jalr	-1944(ra) # 8000446c <end_op>
    return -1;
    80005c0c:	54fd                	li	s1,-1
    80005c0e:	b7a1                	j	80005b56 <sys_open+0xd4>

0000000080005c10 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c10:	7175                	addi	sp,sp,-144
    80005c12:	e506                	sd	ra,136(sp)
    80005c14:	e122                	sd	s0,128(sp)
    80005c16:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005c18:	4501                	li	a0,0
    80005c1a:	ffffe097          	auipc	ra,0xffffe
    80005c1e:	7a8080e7          	jalr	1960(ra) # 800043c2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c22:	08000613          	li	a2,128
    80005c26:	f7040593          	addi	a1,s0,-144
    80005c2a:	4501                	li	a0,0
    80005c2c:	ffffd097          	auipc	ra,0xffffd
    80005c30:	0d0080e7          	jalr	208(ra) # 80002cfc <argstr>
    80005c34:	02054a63          	bltz	a0,80005c68 <sys_mkdir+0x58>
    80005c38:	4681                	li	a3,0
    80005c3a:	4601                	li	a2,0
    80005c3c:	4585                	li	a1,1
    80005c3e:	f7040513          	addi	a0,s0,-144
    80005c42:	fffff097          	auipc	ra,0xfffff
    80005c46:	7f6080e7          	jalr	2038(ra) # 80005438 <create>
    80005c4a:	cd19                	beqz	a0,80005c68 <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005c4c:	ffffe097          	auipc	ra,0xffffe
    80005c50:	fd0080e7          	jalr	-48(ra) # 80003c1c <iunlockput>
  end_op(ROOTDEV);
    80005c54:	4501                	li	a0,0
    80005c56:	fffff097          	auipc	ra,0xfffff
    80005c5a:	816080e7          	jalr	-2026(ra) # 8000446c <end_op>
  return 0;
    80005c5e:	4501                	li	a0,0
}
    80005c60:	60aa                	ld	ra,136(sp)
    80005c62:	640a                	ld	s0,128(sp)
    80005c64:	6149                	addi	sp,sp,144
    80005c66:	8082                	ret
    end_op(ROOTDEV);
    80005c68:	4501                	li	a0,0
    80005c6a:	fffff097          	auipc	ra,0xfffff
    80005c6e:	802080e7          	jalr	-2046(ra) # 8000446c <end_op>
    return -1;
    80005c72:	557d                	li	a0,-1
    80005c74:	b7f5                	j	80005c60 <sys_mkdir+0x50>

0000000080005c76 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c76:	7135                	addi	sp,sp,-160
    80005c78:	ed06                	sd	ra,152(sp)
    80005c7a:	e922                	sd	s0,144(sp)
    80005c7c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005c7e:	4501                	li	a0,0
    80005c80:	ffffe097          	auipc	ra,0xffffe
    80005c84:	742080e7          	jalr	1858(ra) # 800043c2 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c88:	08000613          	li	a2,128
    80005c8c:	f7040593          	addi	a1,s0,-144
    80005c90:	4501                	li	a0,0
    80005c92:	ffffd097          	auipc	ra,0xffffd
    80005c96:	06a080e7          	jalr	106(ra) # 80002cfc <argstr>
    80005c9a:	04054b63          	bltz	a0,80005cf0 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80005c9e:	f6c40593          	addi	a1,s0,-148
    80005ca2:	4505                	li	a0,1
    80005ca4:	ffffd097          	auipc	ra,0xffffd
    80005ca8:	014080e7          	jalr	20(ra) # 80002cb8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005cac:	04054263          	bltz	a0,80005cf0 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005cb0:	f6840593          	addi	a1,s0,-152
    80005cb4:	4509                	li	a0,2
    80005cb6:	ffffd097          	auipc	ra,0xffffd
    80005cba:	002080e7          	jalr	2(ra) # 80002cb8 <argint>
     argint(1, &major) < 0 ||
    80005cbe:	02054963          	bltz	a0,80005cf0 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005cc2:	f6841683          	lh	a3,-152(s0)
    80005cc6:	f6c41603          	lh	a2,-148(s0)
    80005cca:	458d                	li	a1,3
    80005ccc:	f7040513          	addi	a0,s0,-144
    80005cd0:	fffff097          	auipc	ra,0xfffff
    80005cd4:	768080e7          	jalr	1896(ra) # 80005438 <create>
     argint(2, &minor) < 0 ||
    80005cd8:	cd01                	beqz	a0,80005cf0 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005cda:	ffffe097          	auipc	ra,0xffffe
    80005cde:	f42080e7          	jalr	-190(ra) # 80003c1c <iunlockput>
  end_op(ROOTDEV);
    80005ce2:	4501                	li	a0,0
    80005ce4:	ffffe097          	auipc	ra,0xffffe
    80005ce8:	788080e7          	jalr	1928(ra) # 8000446c <end_op>
  return 0;
    80005cec:	4501                	li	a0,0
    80005cee:	a039                	j	80005cfc <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005cf0:	4501                	li	a0,0
    80005cf2:	ffffe097          	auipc	ra,0xffffe
    80005cf6:	77a080e7          	jalr	1914(ra) # 8000446c <end_op>
    return -1;
    80005cfa:	557d                	li	a0,-1
}
    80005cfc:	60ea                	ld	ra,152(sp)
    80005cfe:	644a                	ld	s0,144(sp)
    80005d00:	610d                	addi	sp,sp,160
    80005d02:	8082                	ret

0000000080005d04 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d04:	7135                	addi	sp,sp,-160
    80005d06:	ed06                	sd	ra,152(sp)
    80005d08:	e922                	sd	s0,144(sp)
    80005d0a:	e526                	sd	s1,136(sp)
    80005d0c:	e14a                	sd	s2,128(sp)
    80005d0e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d10:	ffffc097          	auipc	ra,0xffffc
    80005d14:	f30080e7          	jalr	-208(ra) # 80001c40 <myproc>
    80005d18:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005d1a:	4501                	li	a0,0
    80005d1c:	ffffe097          	auipc	ra,0xffffe
    80005d20:	6a6080e7          	jalr	1702(ra) # 800043c2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d24:	08000613          	li	a2,128
    80005d28:	f6040593          	addi	a1,s0,-160
    80005d2c:	4501                	li	a0,0
    80005d2e:	ffffd097          	auipc	ra,0xffffd
    80005d32:	fce080e7          	jalr	-50(ra) # 80002cfc <argstr>
    80005d36:	04054c63          	bltz	a0,80005d8e <sys_chdir+0x8a>
    80005d3a:	f6040513          	addi	a0,s0,-160
    80005d3e:	ffffe097          	auipc	ra,0xffffe
    80005d42:	42a080e7          	jalr	1066(ra) # 80004168 <namei>
    80005d46:	84aa                	mv	s1,a0
    80005d48:	c139                	beqz	a0,80005d8e <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005d4a:	ffffe097          	auipc	ra,0xffffe
    80005d4e:	c94080e7          	jalr	-876(ra) # 800039de <ilock>
  if(ip->type != T_DIR){
    80005d52:	04c49703          	lh	a4,76(s1)
    80005d56:	4785                	li	a5,1
    80005d58:	04f71263          	bne	a4,a5,80005d9c <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005d5c:	8526                	mv	a0,s1
    80005d5e:	ffffe097          	auipc	ra,0xffffe
    80005d62:	d42080e7          	jalr	-702(ra) # 80003aa0 <iunlock>
  iput(p->cwd);
    80005d66:	15893503          	ld	a0,344(s2)
    80005d6a:	ffffe097          	auipc	ra,0xffffe
    80005d6e:	d82080e7          	jalr	-638(ra) # 80003aec <iput>
  end_op(ROOTDEV);
    80005d72:	4501                	li	a0,0
    80005d74:	ffffe097          	auipc	ra,0xffffe
    80005d78:	6f8080e7          	jalr	1784(ra) # 8000446c <end_op>
  p->cwd = ip;
    80005d7c:	14993c23          	sd	s1,344(s2)
  return 0;
    80005d80:	4501                	li	a0,0
}
    80005d82:	60ea                	ld	ra,152(sp)
    80005d84:	644a                	ld	s0,144(sp)
    80005d86:	64aa                	ld	s1,136(sp)
    80005d88:	690a                	ld	s2,128(sp)
    80005d8a:	610d                	addi	sp,sp,160
    80005d8c:	8082                	ret
    end_op(ROOTDEV);
    80005d8e:	4501                	li	a0,0
    80005d90:	ffffe097          	auipc	ra,0xffffe
    80005d94:	6dc080e7          	jalr	1756(ra) # 8000446c <end_op>
    return -1;
    80005d98:	557d                	li	a0,-1
    80005d9a:	b7e5                	j	80005d82 <sys_chdir+0x7e>
    iunlockput(ip);
    80005d9c:	8526                	mv	a0,s1
    80005d9e:	ffffe097          	auipc	ra,0xffffe
    80005da2:	e7e080e7          	jalr	-386(ra) # 80003c1c <iunlockput>
    end_op(ROOTDEV);
    80005da6:	4501                	li	a0,0
    80005da8:	ffffe097          	auipc	ra,0xffffe
    80005dac:	6c4080e7          	jalr	1732(ra) # 8000446c <end_op>
    return -1;
    80005db0:	557d                	li	a0,-1
    80005db2:	bfc1                	j	80005d82 <sys_chdir+0x7e>

0000000080005db4 <sys_exec>:

uint64
sys_exec(void)
{
    80005db4:	7145                	addi	sp,sp,-464
    80005db6:	e786                	sd	ra,456(sp)
    80005db8:	e3a2                	sd	s0,448(sp)
    80005dba:	ff26                	sd	s1,440(sp)
    80005dbc:	fb4a                	sd	s2,432(sp)
    80005dbe:	f74e                	sd	s3,424(sp)
    80005dc0:	f352                	sd	s4,416(sp)
    80005dc2:	ef56                	sd	s5,408(sp)
    80005dc4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005dc6:	08000613          	li	a2,128
    80005dca:	f4040593          	addi	a1,s0,-192
    80005dce:	4501                	li	a0,0
    80005dd0:	ffffd097          	auipc	ra,0xffffd
    80005dd4:	f2c080e7          	jalr	-212(ra) # 80002cfc <argstr>
    80005dd8:	0e054663          	bltz	a0,80005ec4 <sys_exec+0x110>
    80005ddc:	e3840593          	addi	a1,s0,-456
    80005de0:	4505                	li	a0,1
    80005de2:	ffffd097          	auipc	ra,0xffffd
    80005de6:	ef8080e7          	jalr	-264(ra) # 80002cda <argaddr>
    80005dea:	0e054763          	bltz	a0,80005ed8 <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005dee:	10000613          	li	a2,256
    80005df2:	4581                	li	a1,0
    80005df4:	e4040513          	addi	a0,s0,-448
    80005df8:	ffffb097          	auipc	ra,0xffffb
    80005dfc:	15e080e7          	jalr	350(ra) # 80000f56 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e00:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e04:	89ca                	mv	s3,s2
    80005e06:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005e08:	02000a13          	li	s4,32
    80005e0c:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e10:	00349793          	slli	a5,s1,0x3
    80005e14:	e3040593          	addi	a1,s0,-464
    80005e18:	e3843503          	ld	a0,-456(s0)
    80005e1c:	953e                	add	a0,a0,a5
    80005e1e:	ffffd097          	auipc	ra,0xffffd
    80005e22:	e00080e7          	jalr	-512(ra) # 80002c1e <fetchaddr>
    80005e26:	02054a63          	bltz	a0,80005e5a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005e2a:	e3043783          	ld	a5,-464(s0)
    80005e2e:	c7a1                	beqz	a5,80005e76 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e30:	ffffb097          	auipc	ra,0xffffb
    80005e34:	c68080e7          	jalr	-920(ra) # 80000a98 <kalloc>
    80005e38:	85aa                	mv	a1,a0
    80005e3a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e3e:	c92d                	beqz	a0,80005eb0 <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005e40:	6605                	lui	a2,0x1
    80005e42:	e3043503          	ld	a0,-464(s0)
    80005e46:	ffffd097          	auipc	ra,0xffffd
    80005e4a:	e2a080e7          	jalr	-470(ra) # 80002c70 <fetchstr>
    80005e4e:	00054663          	bltz	a0,80005e5a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005e52:	0485                	addi	s1,s1,1
    80005e54:	09a1                	addi	s3,s3,8
    80005e56:	fb449be3          	bne	s1,s4,80005e0c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e5a:	10090493          	addi	s1,s2,256
    80005e5e:	00093503          	ld	a0,0(s2)
    80005e62:	cd39                	beqz	a0,80005ec0 <sys_exec+0x10c>
    kfree(argv[i]);
    80005e64:	ffffb097          	auipc	ra,0xffffb
    80005e68:	aac080e7          	jalr	-1364(ra) # 80000910 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e6c:	0921                	addi	s2,s2,8
    80005e6e:	fe9918e3          	bne	s2,s1,80005e5e <sys_exec+0xaa>
  return -1;
    80005e72:	557d                	li	a0,-1
    80005e74:	a889                	j	80005ec6 <sys_exec+0x112>
      argv[i] = 0;
    80005e76:	0a8e                	slli	s5,s5,0x3
    80005e78:	fc040793          	addi	a5,s0,-64
    80005e7c:	9abe                	add	s5,s5,a5
    80005e7e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005e82:	e4040593          	addi	a1,s0,-448
    80005e86:	f4040513          	addi	a0,s0,-192
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	178080e7          	jalr	376(ra) # 80005002 <exec>
    80005e92:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e94:	10090993          	addi	s3,s2,256
    80005e98:	00093503          	ld	a0,0(s2)
    80005e9c:	c901                	beqz	a0,80005eac <sys_exec+0xf8>
    kfree(argv[i]);
    80005e9e:	ffffb097          	auipc	ra,0xffffb
    80005ea2:	a72080e7          	jalr	-1422(ra) # 80000910 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ea6:	0921                	addi	s2,s2,8
    80005ea8:	ff3918e3          	bne	s2,s3,80005e98 <sys_exec+0xe4>
  return ret;
    80005eac:	8526                	mv	a0,s1
    80005eae:	a821                	j	80005ec6 <sys_exec+0x112>
      panic("sys_exec kalloc");
    80005eb0:	00003517          	auipc	a0,0x3
    80005eb4:	a6050513          	addi	a0,a0,-1440 # 80008910 <userret+0x880>
    80005eb8:	ffffa097          	auipc	ra,0xffffa
    80005ebc:	690080e7          	jalr	1680(ra) # 80000548 <panic>
  return -1;
    80005ec0:	557d                	li	a0,-1
    80005ec2:	a011                	j	80005ec6 <sys_exec+0x112>
    return -1;
    80005ec4:	557d                	li	a0,-1
}
    80005ec6:	60be                	ld	ra,456(sp)
    80005ec8:	641e                	ld	s0,448(sp)
    80005eca:	74fa                	ld	s1,440(sp)
    80005ecc:	795a                	ld	s2,432(sp)
    80005ece:	79ba                	ld	s3,424(sp)
    80005ed0:	7a1a                	ld	s4,416(sp)
    80005ed2:	6afa                	ld	s5,408(sp)
    80005ed4:	6179                	addi	sp,sp,464
    80005ed6:	8082                	ret
    return -1;
    80005ed8:	557d                	li	a0,-1
    80005eda:	b7f5                	j	80005ec6 <sys_exec+0x112>

0000000080005edc <sys_pipe>:

uint64
sys_pipe(void)
{
    80005edc:	7139                	addi	sp,sp,-64
    80005ede:	fc06                	sd	ra,56(sp)
    80005ee0:	f822                	sd	s0,48(sp)
    80005ee2:	f426                	sd	s1,40(sp)
    80005ee4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ee6:	ffffc097          	auipc	ra,0xffffc
    80005eea:	d5a080e7          	jalr	-678(ra) # 80001c40 <myproc>
    80005eee:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005ef0:	fd840593          	addi	a1,s0,-40
    80005ef4:	4501                	li	a0,0
    80005ef6:	ffffd097          	auipc	ra,0xffffd
    80005efa:	de4080e7          	jalr	-540(ra) # 80002cda <argaddr>
    return -1;
    80005efe:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005f00:	0e054063          	bltz	a0,80005fe0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005f04:	fc840593          	addi	a1,s0,-56
    80005f08:	fd040513          	addi	a0,s0,-48
    80005f0c:	fffff097          	auipc	ra,0xfffff
    80005f10:	db4080e7          	jalr	-588(ra) # 80004cc0 <pipealloc>
    return -1;
    80005f14:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f16:	0c054563          	bltz	a0,80005fe0 <sys_pipe+0x104>
  fd0 = -1;
    80005f1a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f1e:	fd043503          	ld	a0,-48(s0)
    80005f22:	fffff097          	auipc	ra,0xfffff
    80005f26:	4d4080e7          	jalr	1236(ra) # 800053f6 <fdalloc>
    80005f2a:	fca42223          	sw	a0,-60(s0)
    80005f2e:	08054c63          	bltz	a0,80005fc6 <sys_pipe+0xea>
    80005f32:	fc843503          	ld	a0,-56(s0)
    80005f36:	fffff097          	auipc	ra,0xfffff
    80005f3a:	4c0080e7          	jalr	1216(ra) # 800053f6 <fdalloc>
    80005f3e:	fca42023          	sw	a0,-64(s0)
    80005f42:	06054863          	bltz	a0,80005fb2 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f46:	4691                	li	a3,4
    80005f48:	fc440613          	addi	a2,s0,-60
    80005f4c:	fd843583          	ld	a1,-40(s0)
    80005f50:	6ca8                	ld	a0,88(s1)
    80005f52:	ffffc097          	auipc	ra,0xffffc
    80005f56:	9e0080e7          	jalr	-1568(ra) # 80001932 <copyout>
    80005f5a:	02054063          	bltz	a0,80005f7a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f5e:	4691                	li	a3,4
    80005f60:	fc040613          	addi	a2,s0,-64
    80005f64:	fd843583          	ld	a1,-40(s0)
    80005f68:	0591                	addi	a1,a1,4
    80005f6a:	6ca8                	ld	a0,88(s1)
    80005f6c:	ffffc097          	auipc	ra,0xffffc
    80005f70:	9c6080e7          	jalr	-1594(ra) # 80001932 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f74:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f76:	06055563          	bgez	a0,80005fe0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005f7a:	fc442783          	lw	a5,-60(s0)
    80005f7e:	07e9                	addi	a5,a5,26
    80005f80:	078e                	slli	a5,a5,0x3
    80005f82:	97a6                	add	a5,a5,s1
    80005f84:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005f88:	fc042503          	lw	a0,-64(s0)
    80005f8c:	0569                	addi	a0,a0,26
    80005f8e:	050e                	slli	a0,a0,0x3
    80005f90:	9526                	add	a0,a0,s1
    80005f92:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005f96:	fd043503          	ld	a0,-48(s0)
    80005f9a:	fffff097          	auipc	ra,0xfffff
    80005f9e:	9c2080e7          	jalr	-1598(ra) # 8000495c <fileclose>
    fileclose(wf);
    80005fa2:	fc843503          	ld	a0,-56(s0)
    80005fa6:	fffff097          	auipc	ra,0xfffff
    80005faa:	9b6080e7          	jalr	-1610(ra) # 8000495c <fileclose>
    return -1;
    80005fae:	57fd                	li	a5,-1
    80005fb0:	a805                	j	80005fe0 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005fb2:	fc442783          	lw	a5,-60(s0)
    80005fb6:	0007c863          	bltz	a5,80005fc6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005fba:	01a78513          	addi	a0,a5,26
    80005fbe:	050e                	slli	a0,a0,0x3
    80005fc0:	9526                	add	a0,a0,s1
    80005fc2:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005fc6:	fd043503          	ld	a0,-48(s0)
    80005fca:	fffff097          	auipc	ra,0xfffff
    80005fce:	992080e7          	jalr	-1646(ra) # 8000495c <fileclose>
    fileclose(wf);
    80005fd2:	fc843503          	ld	a0,-56(s0)
    80005fd6:	fffff097          	auipc	ra,0xfffff
    80005fda:	986080e7          	jalr	-1658(ra) # 8000495c <fileclose>
    return -1;
    80005fde:	57fd                	li	a5,-1
}
    80005fe0:	853e                	mv	a0,a5
    80005fe2:	70e2                	ld	ra,56(sp)
    80005fe4:	7442                	ld	s0,48(sp)
    80005fe6:	74a2                	ld	s1,40(sp)
    80005fe8:	6121                	addi	sp,sp,64
    80005fea:	8082                	ret
    80005fec:	0000                	unimp
	...

0000000080005ff0 <kernelvec>:
    80005ff0:	7111                	addi	sp,sp,-256
    80005ff2:	e006                	sd	ra,0(sp)
    80005ff4:	e40a                	sd	sp,8(sp)
    80005ff6:	e80e                	sd	gp,16(sp)
    80005ff8:	ec12                	sd	tp,24(sp)
    80005ffa:	f016                	sd	t0,32(sp)
    80005ffc:	f41a                	sd	t1,40(sp)
    80005ffe:	f81e                	sd	t2,48(sp)
    80006000:	fc22                	sd	s0,56(sp)
    80006002:	e0a6                	sd	s1,64(sp)
    80006004:	e4aa                	sd	a0,72(sp)
    80006006:	e8ae                	sd	a1,80(sp)
    80006008:	ecb2                	sd	a2,88(sp)
    8000600a:	f0b6                	sd	a3,96(sp)
    8000600c:	f4ba                	sd	a4,104(sp)
    8000600e:	f8be                	sd	a5,112(sp)
    80006010:	fcc2                	sd	a6,120(sp)
    80006012:	e146                	sd	a7,128(sp)
    80006014:	e54a                	sd	s2,136(sp)
    80006016:	e94e                	sd	s3,144(sp)
    80006018:	ed52                	sd	s4,152(sp)
    8000601a:	f156                	sd	s5,160(sp)
    8000601c:	f55a                	sd	s6,168(sp)
    8000601e:	f95e                	sd	s7,176(sp)
    80006020:	fd62                	sd	s8,184(sp)
    80006022:	e1e6                	sd	s9,192(sp)
    80006024:	e5ea                	sd	s10,200(sp)
    80006026:	e9ee                	sd	s11,208(sp)
    80006028:	edf2                	sd	t3,216(sp)
    8000602a:	f1f6                	sd	t4,224(sp)
    8000602c:	f5fa                	sd	t5,232(sp)
    8000602e:	f9fe                	sd	t6,240(sp)
    80006030:	abbfc0ef          	jal	ra,80002aea <kerneltrap>
    80006034:	6082                	ld	ra,0(sp)
    80006036:	6122                	ld	sp,8(sp)
    80006038:	61c2                	ld	gp,16(sp)
    8000603a:	7282                	ld	t0,32(sp)
    8000603c:	7322                	ld	t1,40(sp)
    8000603e:	73c2                	ld	t2,48(sp)
    80006040:	7462                	ld	s0,56(sp)
    80006042:	6486                	ld	s1,64(sp)
    80006044:	6526                	ld	a0,72(sp)
    80006046:	65c6                	ld	a1,80(sp)
    80006048:	6666                	ld	a2,88(sp)
    8000604a:	7686                	ld	a3,96(sp)
    8000604c:	7726                	ld	a4,104(sp)
    8000604e:	77c6                	ld	a5,112(sp)
    80006050:	7866                	ld	a6,120(sp)
    80006052:	688a                	ld	a7,128(sp)
    80006054:	692a                	ld	s2,136(sp)
    80006056:	69ca                	ld	s3,144(sp)
    80006058:	6a6a                	ld	s4,152(sp)
    8000605a:	7a8a                	ld	s5,160(sp)
    8000605c:	7b2a                	ld	s6,168(sp)
    8000605e:	7bca                	ld	s7,176(sp)
    80006060:	7c6a                	ld	s8,184(sp)
    80006062:	6c8e                	ld	s9,192(sp)
    80006064:	6d2e                	ld	s10,200(sp)
    80006066:	6dce                	ld	s11,208(sp)
    80006068:	6e6e                	ld	t3,216(sp)
    8000606a:	7e8e                	ld	t4,224(sp)
    8000606c:	7f2e                	ld	t5,232(sp)
    8000606e:	7fce                	ld	t6,240(sp)
    80006070:	6111                	addi	sp,sp,256
    80006072:	10200073          	sret
    80006076:	00000013          	nop
    8000607a:	00000013          	nop
    8000607e:	0001                	nop

0000000080006080 <timervec>:
    80006080:	34051573          	csrrw	a0,mscratch,a0
    80006084:	e10c                	sd	a1,0(a0)
    80006086:	e510                	sd	a2,8(a0)
    80006088:	e914                	sd	a3,16(a0)
    8000608a:	710c                	ld	a1,32(a0)
    8000608c:	7510                	ld	a2,40(a0)
    8000608e:	6194                	ld	a3,0(a1)
    80006090:	96b2                	add	a3,a3,a2
    80006092:	e194                	sd	a3,0(a1)
    80006094:	4589                	li	a1,2
    80006096:	14459073          	csrw	sip,a1
    8000609a:	6914                	ld	a3,16(a0)
    8000609c:	6510                	ld	a2,8(a0)
    8000609e:	610c                	ld	a1,0(a0)
    800060a0:	34051573          	csrrw	a0,mscratch,a0
    800060a4:	30200073          	mret
	...

00000000800060aa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800060aa:	1141                	addi	sp,sp,-16
    800060ac:	e422                	sd	s0,8(sp)
    800060ae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060b0:	0c0007b7          	lui	a5,0xc000
    800060b4:	4705                	li	a4,1
    800060b6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060b8:	c3d8                	sw	a4,4(a5)
}
    800060ba:	6422                	ld	s0,8(sp)
    800060bc:	0141                	addi	sp,sp,16
    800060be:	8082                	ret

00000000800060c0 <plicinithart>:

void
plicinithart(void)
{
    800060c0:	1141                	addi	sp,sp,-16
    800060c2:	e406                	sd	ra,8(sp)
    800060c4:	e022                	sd	s0,0(sp)
    800060c6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060c8:	ffffc097          	auipc	ra,0xffffc
    800060cc:	b4c080e7          	jalr	-1204(ra) # 80001c14 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800060d0:	0085171b          	slliw	a4,a0,0x8
    800060d4:	0c0027b7          	lui	a5,0xc002
    800060d8:	97ba                	add	a5,a5,a4
    800060da:	40200713          	li	a4,1026
    800060de:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800060e2:	00d5151b          	slliw	a0,a0,0xd
    800060e6:	0c2017b7          	lui	a5,0xc201
    800060ea:	953e                	add	a0,a0,a5
    800060ec:	00052023          	sw	zero,0(a0)
}
    800060f0:	60a2                	ld	ra,8(sp)
    800060f2:	6402                	ld	s0,0(sp)
    800060f4:	0141                	addi	sp,sp,16
    800060f6:	8082                	ret

00000000800060f8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800060f8:	1141                	addi	sp,sp,-16
    800060fa:	e406                	sd	ra,8(sp)
    800060fc:	e022                	sd	s0,0(sp)
    800060fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006100:	ffffc097          	auipc	ra,0xffffc
    80006104:	b14080e7          	jalr	-1260(ra) # 80001c14 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006108:	00d5179b          	slliw	a5,a0,0xd
    8000610c:	0c201537          	lui	a0,0xc201
    80006110:	953e                	add	a0,a0,a5
  return irq;
}
    80006112:	4148                	lw	a0,4(a0)
    80006114:	60a2                	ld	ra,8(sp)
    80006116:	6402                	ld	s0,0(sp)
    80006118:	0141                	addi	sp,sp,16
    8000611a:	8082                	ret

000000008000611c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000611c:	1101                	addi	sp,sp,-32
    8000611e:	ec06                	sd	ra,24(sp)
    80006120:	e822                	sd	s0,16(sp)
    80006122:	e426                	sd	s1,8(sp)
    80006124:	1000                	addi	s0,sp,32
    80006126:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006128:	ffffc097          	auipc	ra,0xffffc
    8000612c:	aec080e7          	jalr	-1300(ra) # 80001c14 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006130:	00d5151b          	slliw	a0,a0,0xd
    80006134:	0c2017b7          	lui	a5,0xc201
    80006138:	97aa                	add	a5,a5,a0
    8000613a:	c3c4                	sw	s1,4(a5)
}
    8000613c:	60e2                	ld	ra,24(sp)
    8000613e:	6442                	ld	s0,16(sp)
    80006140:	64a2                	ld	s1,8(sp)
    80006142:	6105                	addi	sp,sp,32
    80006144:	8082                	ret

0000000080006146 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80006146:	1141                	addi	sp,sp,-16
    80006148:	e406                	sd	ra,8(sp)
    8000614a:	e022                	sd	s0,0(sp)
    8000614c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000614e:	479d                	li	a5,7
    80006150:	06b7c963          	blt	a5,a1,800061c2 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80006154:	00151793          	slli	a5,a0,0x1
    80006158:	97aa                	add	a5,a5,a0
    8000615a:	00c79713          	slli	a4,a5,0xc
    8000615e:	00024797          	auipc	a5,0x24
    80006162:	ea278793          	addi	a5,a5,-350 # 8002a000 <disk>
    80006166:	97ba                	add	a5,a5,a4
    80006168:	97ae                	add	a5,a5,a1
    8000616a:	6709                	lui	a4,0x2
    8000616c:	97ba                	add	a5,a5,a4
    8000616e:	0187c783          	lbu	a5,24(a5)
    80006172:	e3a5                	bnez	a5,800061d2 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80006174:	00024817          	auipc	a6,0x24
    80006178:	e8c80813          	addi	a6,a6,-372 # 8002a000 <disk>
    8000617c:	00151693          	slli	a3,a0,0x1
    80006180:	00a68733          	add	a4,a3,a0
    80006184:	0732                	slli	a4,a4,0xc
    80006186:	00e807b3          	add	a5,a6,a4
    8000618a:	6709                	lui	a4,0x2
    8000618c:	00f70633          	add	a2,a4,a5
    80006190:	6210                	ld	a2,0(a2)
    80006192:	00459893          	slli	a7,a1,0x4
    80006196:	9646                	add	a2,a2,a7
    80006198:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    8000619c:	97ae                	add	a5,a5,a1
    8000619e:	97ba                	add	a5,a5,a4
    800061a0:	4605                	li	a2,1
    800061a2:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    800061a6:	96aa                	add	a3,a3,a0
    800061a8:	06b2                	slli	a3,a3,0xc
    800061aa:	0761                	addi	a4,a4,24
    800061ac:	96ba                	add	a3,a3,a4
    800061ae:	00d80533          	add	a0,a6,a3
    800061b2:	ffffc097          	auipc	ra,0xffffc
    800061b6:	3e4080e7          	jalr	996(ra) # 80002596 <wakeup>
}
    800061ba:	60a2                	ld	ra,8(sp)
    800061bc:	6402                	ld	s0,0(sp)
    800061be:	0141                	addi	sp,sp,16
    800061c0:	8082                	ret
    panic("virtio_disk_intr 1");
    800061c2:	00002517          	auipc	a0,0x2
    800061c6:	75e50513          	addi	a0,a0,1886 # 80008920 <userret+0x890>
    800061ca:	ffffa097          	auipc	ra,0xffffa
    800061ce:	37e080e7          	jalr	894(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    800061d2:	00002517          	auipc	a0,0x2
    800061d6:	76650513          	addi	a0,a0,1894 # 80008938 <userret+0x8a8>
    800061da:	ffffa097          	auipc	ra,0xffffa
    800061de:	36e080e7          	jalr	878(ra) # 80000548 <panic>

00000000800061e2 <virtio_disk_init>:
  __sync_synchronize();
    800061e2:	0ff0000f          	fence
  if(disk[n].init)
    800061e6:	00151793          	slli	a5,a0,0x1
    800061ea:	97aa                	add	a5,a5,a0
    800061ec:	07b2                	slli	a5,a5,0xc
    800061ee:	00024717          	auipc	a4,0x24
    800061f2:	e1270713          	addi	a4,a4,-494 # 8002a000 <disk>
    800061f6:	973e                	add	a4,a4,a5
    800061f8:	6789                	lui	a5,0x2
    800061fa:	97ba                	add	a5,a5,a4
    800061fc:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80006200:	c391                	beqz	a5,80006204 <virtio_disk_init+0x22>
    80006202:	8082                	ret
{
    80006204:	7139                	addi	sp,sp,-64
    80006206:	fc06                	sd	ra,56(sp)
    80006208:	f822                	sd	s0,48(sp)
    8000620a:	f426                	sd	s1,40(sp)
    8000620c:	f04a                	sd	s2,32(sp)
    8000620e:	ec4e                	sd	s3,24(sp)
    80006210:	e852                	sd	s4,16(sp)
    80006212:	e456                	sd	s5,8(sp)
    80006214:	0080                	addi	s0,sp,64
    80006216:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80006218:	85aa                	mv	a1,a0
    8000621a:	00002517          	auipc	a0,0x2
    8000621e:	73650513          	addi	a0,a0,1846 # 80008950 <userret+0x8c0>
    80006222:	ffffa097          	auipc	ra,0xffffa
    80006226:	380080e7          	jalr	896(ra) # 800005a2 <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    8000622a:	00149993          	slli	s3,s1,0x1
    8000622e:	99a6                	add	s3,s3,s1
    80006230:	09b2                	slli	s3,s3,0xc
    80006232:	6789                	lui	a5,0x2
    80006234:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80006238:	97ce                	add	a5,a5,s3
    8000623a:	00002597          	auipc	a1,0x2
    8000623e:	72e58593          	addi	a1,a1,1838 # 80008968 <userret+0x8d8>
    80006242:	00024517          	auipc	a0,0x24
    80006246:	dbe50513          	addi	a0,a0,-578 # 8002a000 <disk>
    8000624a:	953e                	add	a0,a0,a5
    8000624c:	ffffb097          	auipc	ra,0xffffb
    80006250:	94e080e7          	jalr	-1714(ra) # 80000b9a <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006254:	0014891b          	addiw	s2,s1,1
    80006258:	00c9191b          	slliw	s2,s2,0xc
    8000625c:	100007b7          	lui	a5,0x10000
    80006260:	97ca                	add	a5,a5,s2
    80006262:	4398                	lw	a4,0(a5)
    80006264:	2701                	sext.w	a4,a4
    80006266:	747277b7          	lui	a5,0x74727
    8000626a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000626e:	12f71663          	bne	a4,a5,8000639a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006272:	100007b7          	lui	a5,0x10000
    80006276:	0791                	addi	a5,a5,4
    80006278:	97ca                	add	a5,a5,s2
    8000627a:	439c                	lw	a5,0(a5)
    8000627c:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000627e:	4705                	li	a4,1
    80006280:	10e79d63          	bne	a5,a4,8000639a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006284:	100007b7          	lui	a5,0x10000
    80006288:	07a1                	addi	a5,a5,8
    8000628a:	97ca                	add	a5,a5,s2
    8000628c:	439c                	lw	a5,0(a5)
    8000628e:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006290:	4709                	li	a4,2
    80006292:	10e79463          	bne	a5,a4,8000639a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006296:	100007b7          	lui	a5,0x10000
    8000629a:	07b1                	addi	a5,a5,12
    8000629c:	97ca                	add	a5,a5,s2
    8000629e:	4398                	lw	a4,0(a5)
    800062a0:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062a2:	554d47b7          	lui	a5,0x554d4
    800062a6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800062aa:	0ef71863          	bne	a4,a5,8000639a <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800062ae:	100007b7          	lui	a5,0x10000
    800062b2:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    800062b6:	96ca                	add	a3,a3,s2
    800062b8:	4705                	li	a4,1
    800062ba:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800062bc:	470d                	li	a4,3
    800062be:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    800062c0:	01078713          	addi	a4,a5,16
    800062c4:	974a                	add	a4,a4,s2
    800062c6:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800062c8:	02078613          	addi	a2,a5,32
    800062cc:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800062ce:	c7ffe737          	lui	a4,0xc7ffe
    800062d2:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fce703>
    800062d6:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800062d8:	2701                	sext.w	a4,a4
    800062da:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800062dc:	472d                	li	a4,11
    800062de:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800062e0:	473d                	li	a4,15
    800062e2:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800062e4:	02878713          	addi	a4,a5,40
    800062e8:	974a                	add	a4,a4,s2
    800062ea:	6685                	lui	a3,0x1
    800062ec:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    800062ee:	03078713          	addi	a4,a5,48
    800062f2:	974a                	add	a4,a4,s2
    800062f4:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    800062f8:	03478793          	addi	a5,a5,52
    800062fc:	97ca                	add	a5,a5,s2
    800062fe:	439c                	lw	a5,0(a5)
    80006300:	2781                	sext.w	a5,a5
  if(max == 0)
    80006302:	c7c5                	beqz	a5,800063aa <virtio_disk_init+0x1c8>
  if(max < NUM)
    80006304:	471d                	li	a4,7
    80006306:	0af77a63          	bgeu	a4,a5,800063ba <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000630a:	10000ab7          	lui	s5,0x10000
    8000630e:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80006312:	97ca                	add	a5,a5,s2
    80006314:	4721                	li	a4,8
    80006316:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006318:	00024a17          	auipc	s4,0x24
    8000631c:	ce8a0a13          	addi	s4,s4,-792 # 8002a000 <disk>
    80006320:	99d2                	add	s3,s3,s4
    80006322:	6609                	lui	a2,0x2
    80006324:	4581                	li	a1,0
    80006326:	854e                	mv	a0,s3
    80006328:	ffffb097          	auipc	ra,0xffffb
    8000632c:	c2e080e7          	jalr	-978(ra) # 80000f56 <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    80006330:	040a8a93          	addi	s5,s5,64
    80006334:	9956                	add	s2,s2,s5
    80006336:	00c9d793          	srli	a5,s3,0xc
    8000633a:	2781                	sext.w	a5,a5
    8000633c:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80006340:	00149693          	slli	a3,s1,0x1
    80006344:	009687b3          	add	a5,a3,s1
    80006348:	07b2                	slli	a5,a5,0xc
    8000634a:	97d2                	add	a5,a5,s4
    8000634c:	6609                	lui	a2,0x2
    8000634e:	97b2                	add	a5,a5,a2
    80006350:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006354:	08098713          	addi	a4,s3,128
    80006358:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    8000635a:	6705                	lui	a4,0x1
    8000635c:	99ba                	add	s3,s3,a4
    8000635e:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80006362:	4705                	li	a4,1
    80006364:	00e78c23          	sb	a4,24(a5)
    80006368:	00e78ca3          	sb	a4,25(a5)
    8000636c:	00e78d23          	sb	a4,26(a5)
    80006370:	00e78da3          	sb	a4,27(a5)
    80006374:	00e78e23          	sb	a4,28(a5)
    80006378:	00e78ea3          	sb	a4,29(a5)
    8000637c:	00e78f23          	sb	a4,30(a5)
    80006380:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80006384:	0ae7a423          	sw	a4,168(a5)
}
    80006388:	70e2                	ld	ra,56(sp)
    8000638a:	7442                	ld	s0,48(sp)
    8000638c:	74a2                	ld	s1,40(sp)
    8000638e:	7902                	ld	s2,32(sp)
    80006390:	69e2                	ld	s3,24(sp)
    80006392:	6a42                	ld	s4,16(sp)
    80006394:	6aa2                	ld	s5,8(sp)
    80006396:	6121                	addi	sp,sp,64
    80006398:	8082                	ret
    panic("could not find virtio disk");
    8000639a:	00002517          	auipc	a0,0x2
    8000639e:	5de50513          	addi	a0,a0,1502 # 80008978 <userret+0x8e8>
    800063a2:	ffffa097          	auipc	ra,0xffffa
    800063a6:	1a6080e7          	jalr	422(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    800063aa:	00002517          	auipc	a0,0x2
    800063ae:	5ee50513          	addi	a0,a0,1518 # 80008998 <userret+0x908>
    800063b2:	ffffa097          	auipc	ra,0xffffa
    800063b6:	196080e7          	jalr	406(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    800063ba:	00002517          	auipc	a0,0x2
    800063be:	5fe50513          	addi	a0,a0,1534 # 800089b8 <userret+0x928>
    800063c2:	ffffa097          	auipc	ra,0xffffa
    800063c6:	186080e7          	jalr	390(ra) # 80000548 <panic>

00000000800063ca <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    800063ca:	7135                	addi	sp,sp,-160
    800063cc:	ed06                	sd	ra,152(sp)
    800063ce:	e922                	sd	s0,144(sp)
    800063d0:	e526                	sd	s1,136(sp)
    800063d2:	e14a                	sd	s2,128(sp)
    800063d4:	fcce                	sd	s3,120(sp)
    800063d6:	f8d2                	sd	s4,112(sp)
    800063d8:	f4d6                	sd	s5,104(sp)
    800063da:	f0da                	sd	s6,96(sp)
    800063dc:	ecde                	sd	s7,88(sp)
    800063de:	e8e2                	sd	s8,80(sp)
    800063e0:	e4e6                	sd	s9,72(sp)
    800063e2:	e0ea                	sd	s10,64(sp)
    800063e4:	fc6e                	sd	s11,56(sp)
    800063e6:	1100                	addi	s0,sp,160
    800063e8:	8aaa                	mv	s5,a0
    800063ea:	8c2e                	mv	s8,a1
    800063ec:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    800063ee:	45dc                	lw	a5,12(a1)
    800063f0:	0017979b          	slliw	a5,a5,0x1
    800063f4:	1782                	slli	a5,a5,0x20
    800063f6:	9381                	srli	a5,a5,0x20
    800063f8:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    800063fc:	00151493          	slli	s1,a0,0x1
    80006400:	94aa                	add	s1,s1,a0
    80006402:	04b2                	slli	s1,s1,0xc
    80006404:	6909                	lui	s2,0x2
    80006406:	0b090c93          	addi	s9,s2,176 # 20b0 <_entry-0x7fffdf50>
    8000640a:	9ca6                	add	s9,s9,s1
    8000640c:	00024997          	auipc	s3,0x24
    80006410:	bf498993          	addi	s3,s3,-1036 # 8002a000 <disk>
    80006414:	9cce                	add	s9,s9,s3
    80006416:	8566                	mv	a0,s9
    80006418:	ffffb097          	auipc	ra,0xffffb
    8000641c:	8d0080e7          	jalr	-1840(ra) # 80000ce8 <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006420:	0961                	addi	s2,s2,24
    80006422:	94ca                	add	s1,s1,s2
    80006424:	99a6                	add	s3,s3,s1
  for(int i = 0; i < 3; i++){
    80006426:	4a01                	li	s4,0
  for(int i = 0; i < NUM; i++){
    80006428:	44a1                	li	s1,8
      disk[n].free[i] = 0;
    8000642a:	001a9793          	slli	a5,s5,0x1
    8000642e:	97d6                	add	a5,a5,s5
    80006430:	07b2                	slli	a5,a5,0xc
    80006432:	00024b97          	auipc	s7,0x24
    80006436:	bceb8b93          	addi	s7,s7,-1074 # 8002a000 <disk>
    8000643a:	9bbe                	add	s7,s7,a5
    8000643c:	a8a9                	j	80006496 <virtio_disk_rw+0xcc>
    8000643e:	00fb8733          	add	a4,s7,a5
    80006442:	9742                	add	a4,a4,a6
    80006444:	00070c23          	sb	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    idx[i] = alloc_desc(n);
    80006448:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000644a:	0207c263          	bltz	a5,8000646e <virtio_disk_rw+0xa4>
  for(int i = 0; i < 3; i++){
    8000644e:	2905                	addiw	s2,s2,1
    80006450:	0611                	addi	a2,a2,4
    80006452:	1ca90463          	beq	s2,a0,8000661a <virtio_disk_rw+0x250>
    idx[i] = alloc_desc(n);
    80006456:	85b2                	mv	a1,a2
    80006458:	874e                	mv	a4,s3
  for(int i = 0; i < NUM; i++){
    8000645a:	87d2                	mv	a5,s4
    if(disk[n].free[i]){
    8000645c:	00074683          	lbu	a3,0(a4)
    80006460:	fef9                	bnez	a3,8000643e <virtio_disk_rw+0x74>
  for(int i = 0; i < NUM; i++){
    80006462:	2785                	addiw	a5,a5,1
    80006464:	0705                	addi	a4,a4,1
    80006466:	fe979be3          	bne	a5,s1,8000645c <virtio_disk_rw+0x92>
    idx[i] = alloc_desc(n);
    8000646a:	57fd                	li	a5,-1
    8000646c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000646e:	01205e63          	blez	s2,8000648a <virtio_disk_rw+0xc0>
    80006472:	8d52                	mv	s10,s4
        free_desc(n, idx[j]);
    80006474:	000b2583          	lw	a1,0(s6)
    80006478:	8556                	mv	a0,s5
    8000647a:	00000097          	auipc	ra,0x0
    8000647e:	ccc080e7          	jalr	-820(ra) # 80006146 <free_desc>
      for(int j = 0; j < i; j++)
    80006482:	2d05                	addiw	s10,s10,1
    80006484:	0b11                	addi	s6,s6,4
    80006486:	ffa917e3          	bne	s2,s10,80006474 <virtio_disk_rw+0xaa>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    8000648a:	85e6                	mv	a1,s9
    8000648c:	854e                	mv	a0,s3
    8000648e:	ffffc097          	auipc	ra,0xffffc
    80006492:	f88080e7          	jalr	-120(ra) # 80002416 <sleep>
  for(int i = 0; i < 3; i++){
    80006496:	f8040b13          	addi	s6,s0,-128
{
    8000649a:	865a                	mv	a2,s6
  for(int i = 0; i < 3; i++){
    8000649c:	8952                	mv	s2,s4
      disk[n].free[i] = 0;
    8000649e:	6809                	lui	a6,0x2
  for(int i = 0; i < 3; i++){
    800064a0:	450d                	li	a0,3
    800064a2:	bf55                	j	80006456 <virtio_disk_rw+0x8c>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    800064a4:	001a9793          	slli	a5,s5,0x1
    800064a8:	97d6                	add	a5,a5,s5
    800064aa:	07b2                	slli	a5,a5,0xc
    800064ac:	00024717          	auipc	a4,0x24
    800064b0:	b5470713          	addi	a4,a4,-1196 # 8002a000 <disk>
    800064b4:	973e                	add	a4,a4,a5
    800064b6:	6789                	lui	a5,0x2
    800064b8:	97ba                	add	a5,a5,a4
    800064ba:	639c                	ld	a5,0(a5)
    800064bc:	97b6                	add	a5,a5,a3
    800064be:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800064c2:	00024517          	auipc	a0,0x24
    800064c6:	b3e50513          	addi	a0,a0,-1218 # 8002a000 <disk>
    800064ca:	001a9793          	slli	a5,s5,0x1
    800064ce:	01578733          	add	a4,a5,s5
    800064d2:	0732                	slli	a4,a4,0xc
    800064d4:	972a                	add	a4,a4,a0
    800064d6:	6609                	lui	a2,0x2
    800064d8:	9732                	add	a4,a4,a2
    800064da:	6310                	ld	a2,0(a4)
    800064dc:	9636                	add	a2,a2,a3
    800064de:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800064e2:	0015e593          	ori	a1,a1,1
    800064e6:	00b61623          	sh	a1,12(a2)
  disk[n].desc[idx[1]].next = idx[2];
    800064ea:	f8842603          	lw	a2,-120(s0)
    800064ee:	630c                	ld	a1,0(a4)
    800064f0:	96ae                	add	a3,a3,a1
    800064f2:	00c69723          	sh	a2,14(a3) # 100e <_entry-0x7fffeff2>

  disk[n].info[idx[0]].status = 0;
    800064f6:	97d6                	add	a5,a5,s5
    800064f8:	07a2                	slli	a5,a5,0x8
    800064fa:	97a6                	add	a5,a5,s1
    800064fc:	20078793          	addi	a5,a5,512
    80006500:	0792                	slli	a5,a5,0x4
    80006502:	97aa                	add	a5,a5,a0
    80006504:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006508:	00461693          	slli	a3,a2,0x4
    8000650c:	00073803          	ld	a6,0(a4)
    80006510:	9836                	add	a6,a6,a3
    80006512:	20348613          	addi	a2,s1,515
    80006516:	001a9593          	slli	a1,s5,0x1
    8000651a:	95d6                	add	a1,a1,s5
    8000651c:	05a2                	slli	a1,a1,0x8
    8000651e:	962e                	add	a2,a2,a1
    80006520:	0612                	slli	a2,a2,0x4
    80006522:	962a                	add	a2,a2,a0
    80006524:	00c83023          	sd	a2,0(a6) # 2000 <_entry-0x7fffe000>
  disk[n].desc[idx[2]].len = 1;
    80006528:	630c                	ld	a1,0(a4)
    8000652a:	95b6                	add	a1,a1,a3
    8000652c:	4605                	li	a2,1
    8000652e:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006530:	630c                	ld	a1,0(a4)
    80006532:	95b6                	add	a1,a1,a3
    80006534:	4509                	li	a0,2
    80006536:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    8000653a:	630c                	ld	a1,0(a4)
    8000653c:	96ae                	add	a3,a3,a1
    8000653e:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006542:	00cc2223          	sw	a2,4(s8) # fffffffffffff004 <end+0xffffffff7ffcefa8>
  disk[n].info[idx[0]].b = b;
    80006546:	0387b423          	sd	s8,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    8000654a:	6714                	ld	a3,8(a4)
    8000654c:	0026d783          	lhu	a5,2(a3)
    80006550:	8b9d                	andi	a5,a5,7
    80006552:	0789                	addi	a5,a5,2
    80006554:	0786                	slli	a5,a5,0x1
    80006556:	97b6                	add	a5,a5,a3
    80006558:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    8000655c:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006560:	6718                	ld	a4,8(a4)
    80006562:	00275783          	lhu	a5,2(a4)
    80006566:	2785                	addiw	a5,a5,1
    80006568:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000656c:	001a879b          	addiw	a5,s5,1
    80006570:	00c7979b          	slliw	a5,a5,0xc
    80006574:	10000737          	lui	a4,0x10000
    80006578:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    8000657c:	97ba                	add	a5,a5,a4
    8000657e:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006582:	004c2783          	lw	a5,4(s8)
    80006586:	00c79d63          	bne	a5,a2,800065a0 <virtio_disk_rw+0x1d6>
    8000658a:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    8000658c:	85e6                	mv	a1,s9
    8000658e:	8562                	mv	a0,s8
    80006590:	ffffc097          	auipc	ra,0xffffc
    80006594:	e86080e7          	jalr	-378(ra) # 80002416 <sleep>
  while(b->disk == 1) {
    80006598:	004c2783          	lw	a5,4(s8)
    8000659c:	fe9788e3          	beq	a5,s1,8000658c <virtio_disk_rw+0x1c2>
  }

  disk[n].info[idx[0]].b = 0;
    800065a0:	f8042483          	lw	s1,-128(s0)
    800065a4:	001a9793          	slli	a5,s5,0x1
    800065a8:	97d6                	add	a5,a5,s5
    800065aa:	07a2                	slli	a5,a5,0x8
    800065ac:	97a6                	add	a5,a5,s1
    800065ae:	20078793          	addi	a5,a5,512
    800065b2:	0792                	slli	a5,a5,0x4
    800065b4:	00024717          	auipc	a4,0x24
    800065b8:	a4c70713          	addi	a4,a4,-1460 # 8002a000 <disk>
    800065bc:	97ba                	add	a5,a5,a4
    800065be:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800065c2:	001a9793          	slli	a5,s5,0x1
    800065c6:	97d6                	add	a5,a5,s5
    800065c8:	07b2                	slli	a5,a5,0xc
    800065ca:	97ba                	add	a5,a5,a4
    800065cc:	6909                	lui	s2,0x2
    800065ce:	993e                	add	s2,s2,a5
    800065d0:	a019                	j	800065d6 <virtio_disk_rw+0x20c>
      i = disk[n].desc[i].next;
    800065d2:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    800065d6:	85a6                	mv	a1,s1
    800065d8:	8556                	mv	a0,s5
    800065da:	00000097          	auipc	ra,0x0
    800065de:	b6c080e7          	jalr	-1172(ra) # 80006146 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800065e2:	0492                	slli	s1,s1,0x4
    800065e4:	00093783          	ld	a5,0(s2) # 2000 <_entry-0x7fffe000>
    800065e8:	94be                	add	s1,s1,a5
    800065ea:	00c4d783          	lhu	a5,12(s1)
    800065ee:	8b85                	andi	a5,a5,1
    800065f0:	f3ed                	bnez	a5,800065d2 <virtio_disk_rw+0x208>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    800065f2:	8566                	mv	a0,s9
    800065f4:	ffffa097          	auipc	ra,0xffffa
    800065f8:	764080e7          	jalr	1892(ra) # 80000d58 <release>
}
    800065fc:	60ea                	ld	ra,152(sp)
    800065fe:	644a                	ld	s0,144(sp)
    80006600:	64aa                	ld	s1,136(sp)
    80006602:	690a                	ld	s2,128(sp)
    80006604:	79e6                	ld	s3,120(sp)
    80006606:	7a46                	ld	s4,112(sp)
    80006608:	7aa6                	ld	s5,104(sp)
    8000660a:	7b06                	ld	s6,96(sp)
    8000660c:	6be6                	ld	s7,88(sp)
    8000660e:	6c46                	ld	s8,80(sp)
    80006610:	6ca6                	ld	s9,72(sp)
    80006612:	6d06                	ld	s10,64(sp)
    80006614:	7de2                	ld	s11,56(sp)
    80006616:	610d                	addi	sp,sp,160
    80006618:	8082                	ret
  if(write)
    8000661a:	01b037b3          	snez	a5,s11
    8000661e:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006622:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006626:	f6843783          	ld	a5,-152(s0)
    8000662a:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000662e:	f8042483          	lw	s1,-128(s0)
    80006632:	00449993          	slli	s3,s1,0x4
    80006636:	001a9793          	slli	a5,s5,0x1
    8000663a:	97d6                	add	a5,a5,s5
    8000663c:	07b2                	slli	a5,a5,0xc
    8000663e:	00024917          	auipc	s2,0x24
    80006642:	9c290913          	addi	s2,s2,-1598 # 8002a000 <disk>
    80006646:	97ca                	add	a5,a5,s2
    80006648:	6909                	lui	s2,0x2
    8000664a:	993e                	add	s2,s2,a5
    8000664c:	00093a03          	ld	s4,0(s2) # 2000 <_entry-0x7fffe000>
    80006650:	9a4e                	add	s4,s4,s3
    80006652:	f7040513          	addi	a0,s0,-144
    80006656:	ffffb097          	auipc	ra,0xffffb
    8000665a:	d3c080e7          	jalr	-708(ra) # 80001392 <kvmpa>
    8000665e:	00aa3023          	sd	a0,0(s4)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006662:	00093783          	ld	a5,0(s2)
    80006666:	97ce                	add	a5,a5,s3
    80006668:	4741                	li	a4,16
    8000666a:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000666c:	00093783          	ld	a5,0(s2)
    80006670:	97ce                	add	a5,a5,s3
    80006672:	4705                	li	a4,1
    80006674:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    80006678:	f8442683          	lw	a3,-124(s0)
    8000667c:	00093783          	ld	a5,0(s2)
    80006680:	99be                	add	s3,s3,a5
    80006682:	00d99723          	sh	a3,14(s3)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006686:	0692                	slli	a3,a3,0x4
    80006688:	00093783          	ld	a5,0(s2)
    8000668c:	97b6                	add	a5,a5,a3
    8000668e:	060c0713          	addi	a4,s8,96
    80006692:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006694:	00093783          	ld	a5,0(s2)
    80006698:	97b6                	add	a5,a5,a3
    8000669a:	40000713          	li	a4,1024
    8000669e:	c798                	sw	a4,8(a5)
  if(write)
    800066a0:	e00d92e3          	bnez	s11,800064a4 <virtio_disk_rw+0xda>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800066a4:	001a9793          	slli	a5,s5,0x1
    800066a8:	97d6                	add	a5,a5,s5
    800066aa:	07b2                	slli	a5,a5,0xc
    800066ac:	00024717          	auipc	a4,0x24
    800066b0:	95470713          	addi	a4,a4,-1708 # 8002a000 <disk>
    800066b4:	973e                	add	a4,a4,a5
    800066b6:	6789                	lui	a5,0x2
    800066b8:	97ba                	add	a5,a5,a4
    800066ba:	639c                	ld	a5,0(a5)
    800066bc:	97b6                	add	a5,a5,a3
    800066be:	4709                	li	a4,2
    800066c0:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    800066c4:	bbfd                	j	800064c2 <virtio_disk_rw+0xf8>

00000000800066c6 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    800066c6:	7139                	addi	sp,sp,-64
    800066c8:	fc06                	sd	ra,56(sp)
    800066ca:	f822                	sd	s0,48(sp)
    800066cc:	f426                	sd	s1,40(sp)
    800066ce:	f04a                	sd	s2,32(sp)
    800066d0:	ec4e                	sd	s3,24(sp)
    800066d2:	e852                	sd	s4,16(sp)
    800066d4:	e456                	sd	s5,8(sp)
    800066d6:	0080                	addi	s0,sp,64
    800066d8:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    800066da:	00151913          	slli	s2,a0,0x1
    800066de:	00a90a33          	add	s4,s2,a0
    800066e2:	0a32                	slli	s4,s4,0xc
    800066e4:	6989                	lui	s3,0x2
    800066e6:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    800066ea:	9a3e                	add	s4,s4,a5
    800066ec:	00024a97          	auipc	s5,0x24
    800066f0:	914a8a93          	addi	s5,s5,-1772 # 8002a000 <disk>
    800066f4:	9a56                	add	s4,s4,s5
    800066f6:	8552                	mv	a0,s4
    800066f8:	ffffa097          	auipc	ra,0xffffa
    800066fc:	5f0080e7          	jalr	1520(ra) # 80000ce8 <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006700:	9926                	add	s2,s2,s1
    80006702:	0932                	slli	s2,s2,0xc
    80006704:	9956                	add	s2,s2,s5
    80006706:	99ca                	add	s3,s3,s2
    80006708:	0209d783          	lhu	a5,32(s3)
    8000670c:	0109b703          	ld	a4,16(s3)
    80006710:	00275683          	lhu	a3,2(a4)
    80006714:	8ebd                	xor	a3,a3,a5
    80006716:	8a9d                	andi	a3,a3,7
    80006718:	c2a5                	beqz	a3,80006778 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    8000671a:	8956                	mv	s2,s5
    8000671c:	00149693          	slli	a3,s1,0x1
    80006720:	96a6                	add	a3,a3,s1
    80006722:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006726:	06b2                	slli	a3,a3,0xc
    80006728:	96d6                	add	a3,a3,s5
    8000672a:	6489                	lui	s1,0x2
    8000672c:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    8000672e:	078e                	slli	a5,a5,0x3
    80006730:	97ba                	add	a5,a5,a4
    80006732:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006734:	00f98733          	add	a4,s3,a5
    80006738:	20070713          	addi	a4,a4,512
    8000673c:	0712                	slli	a4,a4,0x4
    8000673e:	974a                	add	a4,a4,s2
    80006740:	03074703          	lbu	a4,48(a4)
    80006744:	eb21                	bnez	a4,80006794 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006746:	97ce                	add	a5,a5,s3
    80006748:	20078793          	addi	a5,a5,512
    8000674c:	0792                	slli	a5,a5,0x4
    8000674e:	97ca                	add	a5,a5,s2
    80006750:	7798                	ld	a4,40(a5)
    80006752:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006756:	7788                	ld	a0,40(a5)
    80006758:	ffffc097          	auipc	ra,0xffffc
    8000675c:	e3e080e7          	jalr	-450(ra) # 80002596 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006760:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006764:	2785                	addiw	a5,a5,1
    80006766:	8b9d                	andi	a5,a5,7
    80006768:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    8000676c:	6898                	ld	a4,16(s1)
    8000676e:	00275683          	lhu	a3,2(a4)
    80006772:	8a9d                	andi	a3,a3,7
    80006774:	faf69de3          	bne	a3,a5,8000672e <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    80006778:	8552                	mv	a0,s4
    8000677a:	ffffa097          	auipc	ra,0xffffa
    8000677e:	5de080e7          	jalr	1502(ra) # 80000d58 <release>
}
    80006782:	70e2                	ld	ra,56(sp)
    80006784:	7442                	ld	s0,48(sp)
    80006786:	74a2                	ld	s1,40(sp)
    80006788:	7902                	ld	s2,32(sp)
    8000678a:	69e2                	ld	s3,24(sp)
    8000678c:	6a42                	ld	s4,16(sp)
    8000678e:	6aa2                	ld	s5,8(sp)
    80006790:	6121                	addi	sp,sp,64
    80006792:	8082                	ret
      panic("virtio_disk_intr status");
    80006794:	00002517          	auipc	a0,0x2
    80006798:	24450513          	addi	a0,a0,580 # 800089d8 <userret+0x948>
    8000679c:	ffffa097          	auipc	ra,0xffffa
    800067a0:	dac080e7          	jalr	-596(ra) # 80000548 <panic>

00000000800067a4 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    800067a4:	1141                	addi	sp,sp,-16
    800067a6:	e422                	sd	s0,8(sp)
    800067a8:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    800067aa:	41f5d79b          	sraiw	a5,a1,0x1f
    800067ae:	01d7d79b          	srliw	a5,a5,0x1d
    800067b2:	9dbd                	addw	a1,a1,a5
    800067b4:	0075f713          	andi	a4,a1,7
    800067b8:	9f1d                	subw	a4,a4,a5
    800067ba:	4785                	li	a5,1
    800067bc:	00e797bb          	sllw	a5,a5,a4
    800067c0:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    800067c4:	4035d59b          	sraiw	a1,a1,0x3
    800067c8:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    800067ca:	0005c503          	lbu	a0,0(a1)
    800067ce:	8d7d                	and	a0,a0,a5
    800067d0:	8d1d                	sub	a0,a0,a5
}
    800067d2:	00153513          	seqz	a0,a0
    800067d6:	6422                	ld	s0,8(sp)
    800067d8:	0141                	addi	sp,sp,16
    800067da:	8082                	ret

00000000800067dc <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    800067dc:	1141                	addi	sp,sp,-16
    800067de:	e422                	sd	s0,8(sp)
    800067e0:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800067e2:	41f5d79b          	sraiw	a5,a1,0x1f
    800067e6:	01d7d79b          	srliw	a5,a5,0x1d
    800067ea:	9dbd                	addw	a1,a1,a5
    800067ec:	4035d71b          	sraiw	a4,a1,0x3
    800067f0:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800067f2:	899d                	andi	a1,a1,7
    800067f4:	9d9d                	subw	a1,a1,a5
    800067f6:	4785                	li	a5,1
    800067f8:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    800067fc:	00054783          	lbu	a5,0(a0)
    80006800:	8ddd                	or	a1,a1,a5
    80006802:	00b50023          	sb	a1,0(a0)
}
    80006806:	6422                	ld	s0,8(sp)
    80006808:	0141                	addi	sp,sp,16
    8000680a:	8082                	ret

000000008000680c <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    8000680c:	1141                	addi	sp,sp,-16
    8000680e:	e422                	sd	s0,8(sp)
    80006810:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006812:	41f5d79b          	sraiw	a5,a1,0x1f
    80006816:	01d7d79b          	srliw	a5,a5,0x1d
    8000681a:	9dbd                	addw	a1,a1,a5
    8000681c:	4035d71b          	sraiw	a4,a1,0x3
    80006820:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006822:	899d                	andi	a1,a1,7
    80006824:	9d9d                	subw	a1,a1,a5
    80006826:	4785                	li	a5,1
    80006828:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    8000682c:	fff5c593          	not	a1,a1
    80006830:	00054783          	lbu	a5,0(a0)
    80006834:	8dfd                	and	a1,a1,a5
    80006836:	00b50023          	sb	a1,0(a0)
}
    8000683a:	6422                	ld	s0,8(sp)
    8000683c:	0141                	addi	sp,sp,16
    8000683e:	8082                	ret

0000000080006840 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006840:	715d                	addi	sp,sp,-80
    80006842:	e486                	sd	ra,72(sp)
    80006844:	e0a2                	sd	s0,64(sp)
    80006846:	fc26                	sd	s1,56(sp)
    80006848:	f84a                	sd	s2,48(sp)
    8000684a:	f44e                	sd	s3,40(sp)
    8000684c:	f052                	sd	s4,32(sp)
    8000684e:	ec56                	sd	s5,24(sp)
    80006850:	e85a                	sd	s6,16(sp)
    80006852:	e45e                	sd	s7,8(sp)
    80006854:	0880                	addi	s0,sp,80
    80006856:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006858:	08b05b63          	blez	a1,800068ee <bd_print_vector+0xae>
    8000685c:	89aa                	mv	s3,a0
    8000685e:	4481                	li	s1,0
  lb = 0;
    80006860:	4a81                	li	s5,0
  last = 1;
    80006862:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006864:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006866:	00002b97          	auipc	s7,0x2
    8000686a:	18ab8b93          	addi	s7,s7,394 # 800089f0 <userret+0x960>
    8000686e:	a821                	j	80006886 <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80006870:	85a6                	mv	a1,s1
    80006872:	854e                	mv	a0,s3
    80006874:	00000097          	auipc	ra,0x0
    80006878:	f30080e7          	jalr	-208(ra) # 800067a4 <bit_isset>
    8000687c:	892a                	mv	s2,a0
    8000687e:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006880:	2485                	addiw	s1,s1,1
    80006882:	029a0463          	beq	s4,s1,800068aa <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006886:	85a6                	mv	a1,s1
    80006888:	854e                	mv	a0,s3
    8000688a:	00000097          	auipc	ra,0x0
    8000688e:	f1a080e7          	jalr	-230(ra) # 800067a4 <bit_isset>
    80006892:	ff2507e3          	beq	a0,s2,80006880 <bd_print_vector+0x40>
    if(last == 1)
    80006896:	fd691de3          	bne	s2,s6,80006870 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    8000689a:	8626                	mv	a2,s1
    8000689c:	85d6                	mv	a1,s5
    8000689e:	855e                	mv	a0,s7
    800068a0:	ffffa097          	auipc	ra,0xffffa
    800068a4:	d02080e7          	jalr	-766(ra) # 800005a2 <printf>
    800068a8:	b7e1                	j	80006870 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    800068aa:	000a8563          	beqz	s5,800068b4 <bd_print_vector+0x74>
    800068ae:	4785                	li	a5,1
    800068b0:	00f91c63          	bne	s2,a5,800068c8 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    800068b4:	8652                	mv	a2,s4
    800068b6:	85d6                	mv	a1,s5
    800068b8:	00002517          	auipc	a0,0x2
    800068bc:	13850513          	addi	a0,a0,312 # 800089f0 <userret+0x960>
    800068c0:	ffffa097          	auipc	ra,0xffffa
    800068c4:	ce2080e7          	jalr	-798(ra) # 800005a2 <printf>
  }
  printf("\n");
    800068c8:	00002517          	auipc	a0,0x2
    800068cc:	a1850513          	addi	a0,a0,-1512 # 800082e0 <userret+0x250>
    800068d0:	ffffa097          	auipc	ra,0xffffa
    800068d4:	cd2080e7          	jalr	-814(ra) # 800005a2 <printf>
}
    800068d8:	60a6                	ld	ra,72(sp)
    800068da:	6406                	ld	s0,64(sp)
    800068dc:	74e2                	ld	s1,56(sp)
    800068de:	7942                	ld	s2,48(sp)
    800068e0:	79a2                	ld	s3,40(sp)
    800068e2:	7a02                	ld	s4,32(sp)
    800068e4:	6ae2                	ld	s5,24(sp)
    800068e6:	6b42                	ld	s6,16(sp)
    800068e8:	6ba2                	ld	s7,8(sp)
    800068ea:	6161                	addi	sp,sp,80
    800068ec:	8082                	ret
  lb = 0;
    800068ee:	4a81                	li	s5,0
    800068f0:	b7d1                	j	800068b4 <bd_print_vector+0x74>

00000000800068f2 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    800068f2:	00029697          	auipc	a3,0x29
    800068f6:	7666a683          	lw	a3,1894(a3) # 80030058 <nsizes>
    800068fa:	10d05063          	blez	a3,800069fa <bd_print+0x108>
bd_print() {
    800068fe:	711d                	addi	sp,sp,-96
    80006900:	ec86                	sd	ra,88(sp)
    80006902:	e8a2                	sd	s0,80(sp)
    80006904:	e4a6                	sd	s1,72(sp)
    80006906:	e0ca                	sd	s2,64(sp)
    80006908:	fc4e                	sd	s3,56(sp)
    8000690a:	f852                	sd	s4,48(sp)
    8000690c:	f456                	sd	s5,40(sp)
    8000690e:	f05a                	sd	s6,32(sp)
    80006910:	ec5e                	sd	s7,24(sp)
    80006912:	e862                	sd	s8,16(sp)
    80006914:	e466                	sd	s9,8(sp)
    80006916:	e06a                	sd	s10,0(sp)
    80006918:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    8000691a:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    8000691c:	4a85                	li	s5,1
    8000691e:	4c41                	li	s8,16
    80006920:	00002b97          	auipc	s7,0x2
    80006924:	0e0b8b93          	addi	s7,s7,224 # 80008a00 <userret+0x970>
    lst_print(&bd_sizes[k].free);
    80006928:	00029a17          	auipc	s4,0x29
    8000692c:	728a0a13          	addi	s4,s4,1832 # 80030050 <bd_sizes>
    printf("  alloc:");
    80006930:	00002b17          	auipc	s6,0x2
    80006934:	0f8b0b13          	addi	s6,s6,248 # 80008a28 <userret+0x998>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006938:	00029997          	auipc	s3,0x29
    8000693c:	72098993          	addi	s3,s3,1824 # 80030058 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006940:	00002c97          	auipc	s9,0x2
    80006944:	0f8c8c93          	addi	s9,s9,248 # 80008a38 <userret+0x9a8>
    80006948:	a801                	j	80006958 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    8000694a:	0009a683          	lw	a3,0(s3)
    8000694e:	0485                	addi	s1,s1,1
    80006950:	0004879b          	sext.w	a5,s1
    80006954:	08d7d563          	bge	a5,a3,800069de <bd_print+0xec>
    80006958:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    8000695c:	36fd                	addiw	a3,a3,-1
    8000695e:	9e85                	subw	a3,a3,s1
    80006960:	00da96bb          	sllw	a3,s5,a3
    80006964:	009c1633          	sll	a2,s8,s1
    80006968:	85ca                	mv	a1,s2
    8000696a:	855e                	mv	a0,s7
    8000696c:	ffffa097          	auipc	ra,0xffffa
    80006970:	c36080e7          	jalr	-970(ra) # 800005a2 <printf>
    lst_print(&bd_sizes[k].free);
    80006974:	00549d13          	slli	s10,s1,0x5
    80006978:	000a3503          	ld	a0,0(s4)
    8000697c:	956a                	add	a0,a0,s10
    8000697e:	00001097          	auipc	ra,0x1
    80006982:	a56080e7          	jalr	-1450(ra) # 800073d4 <lst_print>
    printf("  alloc:");
    80006986:	855a                	mv	a0,s6
    80006988:	ffffa097          	auipc	ra,0xffffa
    8000698c:	c1a080e7          	jalr	-998(ra) # 800005a2 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006990:	0009a583          	lw	a1,0(s3)
    80006994:	35fd                	addiw	a1,a1,-1
    80006996:	412585bb          	subw	a1,a1,s2
    8000699a:	000a3783          	ld	a5,0(s4)
    8000699e:	97ea                	add	a5,a5,s10
    800069a0:	00ba95bb          	sllw	a1,s5,a1
    800069a4:	6b88                	ld	a0,16(a5)
    800069a6:	00000097          	auipc	ra,0x0
    800069aa:	e9a080e7          	jalr	-358(ra) # 80006840 <bd_print_vector>
    if(k > 0) {
    800069ae:	f9205ee3          	blez	s2,8000694a <bd_print+0x58>
      printf("  split:");
    800069b2:	8566                	mv	a0,s9
    800069b4:	ffffa097          	auipc	ra,0xffffa
    800069b8:	bee080e7          	jalr	-1042(ra) # 800005a2 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    800069bc:	0009a583          	lw	a1,0(s3)
    800069c0:	35fd                	addiw	a1,a1,-1
    800069c2:	412585bb          	subw	a1,a1,s2
    800069c6:	000a3783          	ld	a5,0(s4)
    800069ca:	9d3e                	add	s10,s10,a5
    800069cc:	00ba95bb          	sllw	a1,s5,a1
    800069d0:	018d3503          	ld	a0,24(s10)
    800069d4:	00000097          	auipc	ra,0x0
    800069d8:	e6c080e7          	jalr	-404(ra) # 80006840 <bd_print_vector>
    800069dc:	b7bd                	j	8000694a <bd_print+0x58>
    }
  }
}
    800069de:	60e6                	ld	ra,88(sp)
    800069e0:	6446                	ld	s0,80(sp)
    800069e2:	64a6                	ld	s1,72(sp)
    800069e4:	6906                	ld	s2,64(sp)
    800069e6:	79e2                	ld	s3,56(sp)
    800069e8:	7a42                	ld	s4,48(sp)
    800069ea:	7aa2                	ld	s5,40(sp)
    800069ec:	7b02                	ld	s6,32(sp)
    800069ee:	6be2                	ld	s7,24(sp)
    800069f0:	6c42                	ld	s8,16(sp)
    800069f2:	6ca2                	ld	s9,8(sp)
    800069f4:	6d02                	ld	s10,0(sp)
    800069f6:	6125                	addi	sp,sp,96
    800069f8:	8082                	ret
    800069fa:	8082                	ret

00000000800069fc <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800069fc:	1141                	addi	sp,sp,-16
    800069fe:	e422                	sd	s0,8(sp)
    80006a00:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006a02:	47c1                	li	a5,16
    80006a04:	00a7fb63          	bgeu	a5,a0,80006a1a <firstk+0x1e>
    80006a08:	872a                	mv	a4,a0
  int k = 0;
    80006a0a:	4501                	li	a0,0
    k++;
    80006a0c:	2505                	addiw	a0,a0,1
    size *= 2;
    80006a0e:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006a10:	fee7eee3          	bltu	a5,a4,80006a0c <firstk+0x10>
  }
  return k;
}
    80006a14:	6422                	ld	s0,8(sp)
    80006a16:	0141                	addi	sp,sp,16
    80006a18:	8082                	ret
  int k = 0;
    80006a1a:	4501                	li	a0,0
    80006a1c:	bfe5                	j	80006a14 <firstk+0x18>

0000000080006a1e <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006a1e:	1141                	addi	sp,sp,-16
    80006a20:	e422                	sd	s0,8(sp)
    80006a22:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006a24:	00029797          	auipc	a5,0x29
    80006a28:	6247b783          	ld	a5,1572(a5) # 80030048 <bd_base>
    80006a2c:	9d9d                	subw	a1,a1,a5
    80006a2e:	47c1                	li	a5,16
    80006a30:	00a797b3          	sll	a5,a5,a0
    80006a34:	02f5c5b3          	div	a1,a1,a5
}
    80006a38:	0005851b          	sext.w	a0,a1
    80006a3c:	6422                	ld	s0,8(sp)
    80006a3e:	0141                	addi	sp,sp,16
    80006a40:	8082                	ret

0000000080006a42 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006a42:	1141                	addi	sp,sp,-16
    80006a44:	e422                	sd	s0,8(sp)
    80006a46:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006a48:	47c1                	li	a5,16
    80006a4a:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006a4e:	02b787bb          	mulw	a5,a5,a1
}
    80006a52:	00029517          	auipc	a0,0x29
    80006a56:	5f653503          	ld	a0,1526(a0) # 80030048 <bd_base>
    80006a5a:	953e                	add	a0,a0,a5
    80006a5c:	6422                	ld	s0,8(sp)
    80006a5e:	0141                	addi	sp,sp,16
    80006a60:	8082                	ret

0000000080006a62 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006a62:	7159                	addi	sp,sp,-112
    80006a64:	f486                	sd	ra,104(sp)
    80006a66:	f0a2                	sd	s0,96(sp)
    80006a68:	eca6                	sd	s1,88(sp)
    80006a6a:	e8ca                	sd	s2,80(sp)
    80006a6c:	e4ce                	sd	s3,72(sp)
    80006a6e:	e0d2                	sd	s4,64(sp)
    80006a70:	fc56                	sd	s5,56(sp)
    80006a72:	f85a                	sd	s6,48(sp)
    80006a74:	f45e                	sd	s7,40(sp)
    80006a76:	f062                	sd	s8,32(sp)
    80006a78:	ec66                	sd	s9,24(sp)
    80006a7a:	e86a                	sd	s10,16(sp)
    80006a7c:	e46e                	sd	s11,8(sp)
    80006a7e:	1880                	addi	s0,sp,112
    80006a80:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006a82:	00029517          	auipc	a0,0x29
    80006a86:	57e50513          	addi	a0,a0,1406 # 80030000 <lock>
    80006a8a:	ffffa097          	auipc	ra,0xffffa
    80006a8e:	25e080e7          	jalr	606(ra) # 80000ce8 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006a92:	8526                	mv	a0,s1
    80006a94:	00000097          	auipc	ra,0x0
    80006a98:	f68080e7          	jalr	-152(ra) # 800069fc <firstk>
  for (k = fk; k < nsizes; k++) {
    80006a9c:	00029797          	auipc	a5,0x29
    80006aa0:	5bc7a783          	lw	a5,1468(a5) # 80030058 <nsizes>
    80006aa4:	02f55d63          	bge	a0,a5,80006ade <bd_malloc+0x7c>
    80006aa8:	8c2a                	mv	s8,a0
    80006aaa:	00551913          	slli	s2,a0,0x5
    80006aae:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006ab0:	00029997          	auipc	s3,0x29
    80006ab4:	5a098993          	addi	s3,s3,1440 # 80030050 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006ab8:	00029a17          	auipc	s4,0x29
    80006abc:	5a0a0a13          	addi	s4,s4,1440 # 80030058 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006ac0:	0009b503          	ld	a0,0(s3)
    80006ac4:	954a                	add	a0,a0,s2
    80006ac6:	00001097          	auipc	ra,0x1
    80006aca:	894080e7          	jalr	-1900(ra) # 8000735a <lst_empty>
    80006ace:	c115                	beqz	a0,80006af2 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006ad0:	2485                	addiw	s1,s1,1
    80006ad2:	02090913          	addi	s2,s2,32
    80006ad6:	000a2783          	lw	a5,0(s4)
    80006ada:	fef4c3e3          	blt	s1,a5,80006ac0 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006ade:	00029517          	auipc	a0,0x29
    80006ae2:	52250513          	addi	a0,a0,1314 # 80030000 <lock>
    80006ae6:	ffffa097          	auipc	ra,0xffffa
    80006aea:	272080e7          	jalr	626(ra) # 80000d58 <release>
    return 0;
    80006aee:	4b01                	li	s6,0
    80006af0:	a0e1                	j	80006bb8 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80006af2:	00029797          	auipc	a5,0x29
    80006af6:	5667a783          	lw	a5,1382(a5) # 80030058 <nsizes>
    80006afa:	fef4d2e3          	bge	s1,a5,80006ade <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006afe:	00549993          	slli	s3,s1,0x5
    80006b02:	00029917          	auipc	s2,0x29
    80006b06:	54e90913          	addi	s2,s2,1358 # 80030050 <bd_sizes>
    80006b0a:	00093503          	ld	a0,0(s2)
    80006b0e:	954e                	add	a0,a0,s3
    80006b10:	00001097          	auipc	ra,0x1
    80006b14:	876080e7          	jalr	-1930(ra) # 80007386 <lst_pop>
    80006b18:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006b1a:	00029597          	auipc	a1,0x29
    80006b1e:	52e5b583          	ld	a1,1326(a1) # 80030048 <bd_base>
    80006b22:	40b505bb          	subw	a1,a0,a1
    80006b26:	47c1                	li	a5,16
    80006b28:	009797b3          	sll	a5,a5,s1
    80006b2c:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006b30:	00093783          	ld	a5,0(s2)
    80006b34:	97ce                	add	a5,a5,s3
    80006b36:	2581                	sext.w	a1,a1
    80006b38:	6b88                	ld	a0,16(a5)
    80006b3a:	00000097          	auipc	ra,0x0
    80006b3e:	ca2080e7          	jalr	-862(ra) # 800067dc <bit_set>
  for(; k > fk; k--) {
    80006b42:	069c5363          	bge	s8,s1,80006ba8 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006b46:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006b48:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006b4a:	00029d17          	auipc	s10,0x29
    80006b4e:	4fed0d13          	addi	s10,s10,1278 # 80030048 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006b52:	85a6                	mv	a1,s1
    80006b54:	34fd                	addiw	s1,s1,-1
    80006b56:	009b9ab3          	sll	s5,s7,s1
    80006b5a:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006b5e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
  int n = p - (char *) bd_base;
    80006b62:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006b66:	412b093b          	subw	s2,s6,s2
    80006b6a:	00bb95b3          	sll	a1,s7,a1
    80006b6e:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006b72:	013a07b3          	add	a5,s4,s3
    80006b76:	2581                	sext.w	a1,a1
    80006b78:	6f88                	ld	a0,24(a5)
    80006b7a:	00000097          	auipc	ra,0x0
    80006b7e:	c62080e7          	jalr	-926(ra) # 800067dc <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006b82:	1981                	addi	s3,s3,-32
    80006b84:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006b86:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006b8a:	2581                	sext.w	a1,a1
    80006b8c:	010a3503          	ld	a0,16(s4)
    80006b90:	00000097          	auipc	ra,0x0
    80006b94:	c4c080e7          	jalr	-948(ra) # 800067dc <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006b98:	85e6                	mv	a1,s9
    80006b9a:	8552                	mv	a0,s4
    80006b9c:	00001097          	auipc	ra,0x1
    80006ba0:	820080e7          	jalr	-2016(ra) # 800073bc <lst_push>
  for(; k > fk; k--) {
    80006ba4:	fb8497e3          	bne	s1,s8,80006b52 <bd_malloc+0xf0>
  }
  release(&lock);
    80006ba8:	00029517          	auipc	a0,0x29
    80006bac:	45850513          	addi	a0,a0,1112 # 80030000 <lock>
    80006bb0:	ffffa097          	auipc	ra,0xffffa
    80006bb4:	1a8080e7          	jalr	424(ra) # 80000d58 <release>

  return p;
}
    80006bb8:	855a                	mv	a0,s6
    80006bba:	70a6                	ld	ra,104(sp)
    80006bbc:	7406                	ld	s0,96(sp)
    80006bbe:	64e6                	ld	s1,88(sp)
    80006bc0:	6946                	ld	s2,80(sp)
    80006bc2:	69a6                	ld	s3,72(sp)
    80006bc4:	6a06                	ld	s4,64(sp)
    80006bc6:	7ae2                	ld	s5,56(sp)
    80006bc8:	7b42                	ld	s6,48(sp)
    80006bca:	7ba2                	ld	s7,40(sp)
    80006bcc:	7c02                	ld	s8,32(sp)
    80006bce:	6ce2                	ld	s9,24(sp)
    80006bd0:	6d42                	ld	s10,16(sp)
    80006bd2:	6da2                	ld	s11,8(sp)
    80006bd4:	6165                	addi	sp,sp,112
    80006bd6:	8082                	ret

0000000080006bd8 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006bd8:	7139                	addi	sp,sp,-64
    80006bda:	fc06                	sd	ra,56(sp)
    80006bdc:	f822                	sd	s0,48(sp)
    80006bde:	f426                	sd	s1,40(sp)
    80006be0:	f04a                	sd	s2,32(sp)
    80006be2:	ec4e                	sd	s3,24(sp)
    80006be4:	e852                	sd	s4,16(sp)
    80006be6:	e456                	sd	s5,8(sp)
    80006be8:	e05a                	sd	s6,0(sp)
    80006bea:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006bec:	00029a97          	auipc	s5,0x29
    80006bf0:	46caaa83          	lw	s5,1132(s5) # 80030058 <nsizes>
  return n / BLK_SIZE(k);
    80006bf4:	00029a17          	auipc	s4,0x29
    80006bf8:	454a3a03          	ld	s4,1108(s4) # 80030048 <bd_base>
    80006bfc:	41450a3b          	subw	s4,a0,s4
    80006c00:	00029497          	auipc	s1,0x29
    80006c04:	4504b483          	ld	s1,1104(s1) # 80030050 <bd_sizes>
    80006c08:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006c0c:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006c0e:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006c10:	03595363          	bge	s2,s5,80006c36 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006c14:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006c18:	013b15b3          	sll	a1,s6,s3
    80006c1c:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006c20:	2581                	sext.w	a1,a1
    80006c22:	6088                	ld	a0,0(s1)
    80006c24:	00000097          	auipc	ra,0x0
    80006c28:	b80080e7          	jalr	-1152(ra) # 800067a4 <bit_isset>
    80006c2c:	02048493          	addi	s1,s1,32
    80006c30:	e501                	bnez	a0,80006c38 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006c32:	894e                	mv	s2,s3
    80006c34:	bff1                	j	80006c10 <size+0x38>
      return k;
    }
  }
  return 0;
    80006c36:	4901                	li	s2,0
}
    80006c38:	854a                	mv	a0,s2
    80006c3a:	70e2                	ld	ra,56(sp)
    80006c3c:	7442                	ld	s0,48(sp)
    80006c3e:	74a2                	ld	s1,40(sp)
    80006c40:	7902                	ld	s2,32(sp)
    80006c42:	69e2                	ld	s3,24(sp)
    80006c44:	6a42                	ld	s4,16(sp)
    80006c46:	6aa2                	ld	s5,8(sp)
    80006c48:	6b02                	ld	s6,0(sp)
    80006c4a:	6121                	addi	sp,sp,64
    80006c4c:	8082                	ret

0000000080006c4e <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006c4e:	7159                	addi	sp,sp,-112
    80006c50:	f486                	sd	ra,104(sp)
    80006c52:	f0a2                	sd	s0,96(sp)
    80006c54:	eca6                	sd	s1,88(sp)
    80006c56:	e8ca                	sd	s2,80(sp)
    80006c58:	e4ce                	sd	s3,72(sp)
    80006c5a:	e0d2                	sd	s4,64(sp)
    80006c5c:	fc56                	sd	s5,56(sp)
    80006c5e:	f85a                	sd	s6,48(sp)
    80006c60:	f45e                	sd	s7,40(sp)
    80006c62:	f062                	sd	s8,32(sp)
    80006c64:	ec66                	sd	s9,24(sp)
    80006c66:	e86a                	sd	s10,16(sp)
    80006c68:	e46e                	sd	s11,8(sp)
    80006c6a:	1880                	addi	s0,sp,112
    80006c6c:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006c6e:	00029517          	auipc	a0,0x29
    80006c72:	39250513          	addi	a0,a0,914 # 80030000 <lock>
    80006c76:	ffffa097          	auipc	ra,0xffffa
    80006c7a:	072080e7          	jalr	114(ra) # 80000ce8 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80006c7e:	8556                	mv	a0,s5
    80006c80:	00000097          	auipc	ra,0x0
    80006c84:	f58080e7          	jalr	-168(ra) # 80006bd8 <size>
    80006c88:	84aa                	mv	s1,a0
    80006c8a:	00029797          	auipc	a5,0x29
    80006c8e:	3ce7a783          	lw	a5,974(a5) # 80030058 <nsizes>
    80006c92:	37fd                	addiw	a5,a5,-1
    80006c94:	0cf55063          	bge	a0,a5,80006d54 <bd_free+0x106>
    80006c98:	00150a13          	addi	s4,a0,1
    80006c9c:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    80006c9e:	00029c17          	auipc	s8,0x29
    80006ca2:	3aac0c13          	addi	s8,s8,938 # 80030048 <bd_base>
  return n / BLK_SIZE(k);
    80006ca6:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006ca8:	00029b17          	auipc	s6,0x29
    80006cac:	3a8b0b13          	addi	s6,s6,936 # 80030050 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006cb0:	00029c97          	auipc	s9,0x29
    80006cb4:	3a8c8c93          	addi	s9,s9,936 # 80030058 <nsizes>
    80006cb8:	a82d                	j	80006cf2 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006cba:	fff58d9b          	addiw	s11,a1,-1
    80006cbe:	a881                	j	80006d0e <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006cc0:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80006cc2:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80006cc6:	40ba85bb          	subw	a1,s5,a1
    80006cca:	009b97b3          	sll	a5,s7,s1
    80006cce:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006cd2:	000b3783          	ld	a5,0(s6)
    80006cd6:	97d2                	add	a5,a5,s4
    80006cd8:	2581                	sext.w	a1,a1
    80006cda:	6f88                	ld	a0,24(a5)
    80006cdc:	00000097          	auipc	ra,0x0
    80006ce0:	b30080e7          	jalr	-1232(ra) # 8000680c <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006ce4:	020a0a13          	addi	s4,s4,32
    80006ce8:	000ca783          	lw	a5,0(s9)
    80006cec:	37fd                	addiw	a5,a5,-1
    80006cee:	06f4d363          	bge	s1,a5,80006d54 <bd_free+0x106>
  int n = p - (char *) bd_base;
    80006cf2:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006cf6:	009b99b3          	sll	s3,s7,s1
    80006cfa:	412a87bb          	subw	a5,s5,s2
    80006cfe:	0337c7b3          	div	a5,a5,s3
    80006d02:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006d06:	8b85                	andi	a5,a5,1
    80006d08:	fbcd                	bnez	a5,80006cba <bd_free+0x6c>
    80006d0a:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006d0e:	fe0a0d13          	addi	s10,s4,-32
    80006d12:	000b3783          	ld	a5,0(s6)
    80006d16:	9d3e                	add	s10,s10,a5
    80006d18:	010d3503          	ld	a0,16(s10)
    80006d1c:	00000097          	auipc	ra,0x0
    80006d20:	af0080e7          	jalr	-1296(ra) # 8000680c <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006d24:	85ee                	mv	a1,s11
    80006d26:	010d3503          	ld	a0,16(s10)
    80006d2a:	00000097          	auipc	ra,0x0
    80006d2e:	a7a080e7          	jalr	-1414(ra) # 800067a4 <bit_isset>
    80006d32:	e10d                	bnez	a0,80006d54 <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    80006d34:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006d38:	03b989bb          	mulw	s3,s3,s11
    80006d3c:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006d3e:	854a                	mv	a0,s2
    80006d40:	00000097          	auipc	ra,0x0
    80006d44:	630080e7          	jalr	1584(ra) # 80007370 <lst_remove>
    if(buddy % 2 == 0) {
    80006d48:	001d7d13          	andi	s10,s10,1
    80006d4c:	f60d1ae3          	bnez	s10,80006cc0 <bd_free+0x72>
      p = q;
    80006d50:	8aca                	mv	s5,s2
    80006d52:	b7bd                	j	80006cc0 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    80006d54:	0496                	slli	s1,s1,0x5
    80006d56:	85d6                	mv	a1,s5
    80006d58:	00029517          	auipc	a0,0x29
    80006d5c:	2f853503          	ld	a0,760(a0) # 80030050 <bd_sizes>
    80006d60:	9526                	add	a0,a0,s1
    80006d62:	00000097          	auipc	ra,0x0
    80006d66:	65a080e7          	jalr	1626(ra) # 800073bc <lst_push>
  release(&lock);
    80006d6a:	00029517          	auipc	a0,0x29
    80006d6e:	29650513          	addi	a0,a0,662 # 80030000 <lock>
    80006d72:	ffffa097          	auipc	ra,0xffffa
    80006d76:	fe6080e7          	jalr	-26(ra) # 80000d58 <release>
}
    80006d7a:	70a6                	ld	ra,104(sp)
    80006d7c:	7406                	ld	s0,96(sp)
    80006d7e:	64e6                	ld	s1,88(sp)
    80006d80:	6946                	ld	s2,80(sp)
    80006d82:	69a6                	ld	s3,72(sp)
    80006d84:	6a06                	ld	s4,64(sp)
    80006d86:	7ae2                	ld	s5,56(sp)
    80006d88:	7b42                	ld	s6,48(sp)
    80006d8a:	7ba2                	ld	s7,40(sp)
    80006d8c:	7c02                	ld	s8,32(sp)
    80006d8e:	6ce2                	ld	s9,24(sp)
    80006d90:	6d42                	ld	s10,16(sp)
    80006d92:	6da2                	ld	s11,8(sp)
    80006d94:	6165                	addi	sp,sp,112
    80006d96:	8082                	ret

0000000080006d98 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006d98:	1141                	addi	sp,sp,-16
    80006d9a:	e422                	sd	s0,8(sp)
    80006d9c:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006d9e:	00029797          	auipc	a5,0x29
    80006da2:	2aa7b783          	ld	a5,682(a5) # 80030048 <bd_base>
    80006da6:	8d9d                	sub	a1,a1,a5
    80006da8:	47c1                	li	a5,16
    80006daa:	00a797b3          	sll	a5,a5,a0
    80006dae:	02f5c533          	div	a0,a1,a5
    80006db2:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006db4:	02f5e5b3          	rem	a1,a1,a5
    80006db8:	c191                	beqz	a1,80006dbc <blk_index_next+0x24>
      n++;
    80006dba:	2505                	addiw	a0,a0,1
  return n ;
}
    80006dbc:	6422                	ld	s0,8(sp)
    80006dbe:	0141                	addi	sp,sp,16
    80006dc0:	8082                	ret

0000000080006dc2 <log2>:

int
log2(uint64 n) {
    80006dc2:	1141                	addi	sp,sp,-16
    80006dc4:	e422                	sd	s0,8(sp)
    80006dc6:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006dc8:	4705                	li	a4,1
    80006dca:	00a77b63          	bgeu	a4,a0,80006de0 <log2+0x1e>
    80006dce:	87aa                	mv	a5,a0
  int k = 0;
    80006dd0:	4501                	li	a0,0
    k++;
    80006dd2:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006dd4:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006dd6:	fef76ee3          	bltu	a4,a5,80006dd2 <log2+0x10>
  }
  return k;
}
    80006dda:	6422                	ld	s0,8(sp)
    80006ddc:	0141                	addi	sp,sp,16
    80006dde:	8082                	ret
  int k = 0;
    80006de0:	4501                	li	a0,0
    80006de2:	bfe5                	j	80006dda <log2+0x18>

0000000080006de4 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006de4:	711d                	addi	sp,sp,-96
    80006de6:	ec86                	sd	ra,88(sp)
    80006de8:	e8a2                	sd	s0,80(sp)
    80006dea:	e4a6                	sd	s1,72(sp)
    80006dec:	e0ca                	sd	s2,64(sp)
    80006dee:	fc4e                	sd	s3,56(sp)
    80006df0:	f852                	sd	s4,48(sp)
    80006df2:	f456                	sd	s5,40(sp)
    80006df4:	f05a                	sd	s6,32(sp)
    80006df6:	ec5e                	sd	s7,24(sp)
    80006df8:	e862                	sd	s8,16(sp)
    80006dfa:	e466                	sd	s9,8(sp)
    80006dfc:	e06a                	sd	s10,0(sp)
    80006dfe:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006e00:	00b56933          	or	s2,a0,a1
    80006e04:	00f97913          	andi	s2,s2,15
    80006e08:	04091263          	bnez	s2,80006e4c <bd_mark+0x68>
    80006e0c:	8b2a                	mv	s6,a0
    80006e0e:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006e10:	00029c17          	auipc	s8,0x29
    80006e14:	248c2c03          	lw	s8,584(s8) # 80030058 <nsizes>
    80006e18:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006e1a:	00029d17          	auipc	s10,0x29
    80006e1e:	22ed0d13          	addi	s10,s10,558 # 80030048 <bd_base>
  return n / BLK_SIZE(k);
    80006e22:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006e24:	00029a97          	auipc	s5,0x29
    80006e28:	22ca8a93          	addi	s5,s5,556 # 80030050 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006e2c:	07804563          	bgtz	s8,80006e96 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006e30:	60e6                	ld	ra,88(sp)
    80006e32:	6446                	ld	s0,80(sp)
    80006e34:	64a6                	ld	s1,72(sp)
    80006e36:	6906                	ld	s2,64(sp)
    80006e38:	79e2                	ld	s3,56(sp)
    80006e3a:	7a42                	ld	s4,48(sp)
    80006e3c:	7aa2                	ld	s5,40(sp)
    80006e3e:	7b02                	ld	s6,32(sp)
    80006e40:	6be2                	ld	s7,24(sp)
    80006e42:	6c42                	ld	s8,16(sp)
    80006e44:	6ca2                	ld	s9,8(sp)
    80006e46:	6d02                	ld	s10,0(sp)
    80006e48:	6125                	addi	sp,sp,96
    80006e4a:	8082                	ret
    panic("bd_mark");
    80006e4c:	00002517          	auipc	a0,0x2
    80006e50:	bfc50513          	addi	a0,a0,-1028 # 80008a48 <userret+0x9b8>
    80006e54:	ffff9097          	auipc	ra,0xffff9
    80006e58:	6f4080e7          	jalr	1780(ra) # 80000548 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006e5c:	000ab783          	ld	a5,0(s5)
    80006e60:	97ca                	add	a5,a5,s2
    80006e62:	85a6                	mv	a1,s1
    80006e64:	6b88                	ld	a0,16(a5)
    80006e66:	00000097          	auipc	ra,0x0
    80006e6a:	976080e7          	jalr	-1674(ra) # 800067dc <bit_set>
    for(; bi < bj; bi++) {
    80006e6e:	2485                	addiw	s1,s1,1
    80006e70:	009a0e63          	beq	s4,s1,80006e8c <bd_mark+0xa8>
      if(k > 0) {
    80006e74:	ff3054e3          	blez	s3,80006e5c <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006e78:	000ab783          	ld	a5,0(s5)
    80006e7c:	97ca                	add	a5,a5,s2
    80006e7e:	85a6                	mv	a1,s1
    80006e80:	6f88                	ld	a0,24(a5)
    80006e82:	00000097          	auipc	ra,0x0
    80006e86:	95a080e7          	jalr	-1702(ra) # 800067dc <bit_set>
    80006e8a:	bfc9                	j	80006e5c <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006e8c:	2985                	addiw	s3,s3,1
    80006e8e:	02090913          	addi	s2,s2,32
    80006e92:	f9898fe3          	beq	s3,s8,80006e30 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006e96:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006e9a:	409b04bb          	subw	s1,s6,s1
    80006e9e:	013c97b3          	sll	a5,s9,s3
    80006ea2:	02f4c4b3          	div	s1,s1,a5
    80006ea6:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006ea8:	85de                	mv	a1,s7
    80006eaa:	854e                	mv	a0,s3
    80006eac:	00000097          	auipc	ra,0x0
    80006eb0:	eec080e7          	jalr	-276(ra) # 80006d98 <blk_index_next>
    80006eb4:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006eb6:	faa4cfe3          	blt	s1,a0,80006e74 <bd_mark+0x90>
    80006eba:	bfc9                	j	80006e8c <bd_mark+0xa8>

0000000080006ebc <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006ebc:	7139                	addi	sp,sp,-64
    80006ebe:	fc06                	sd	ra,56(sp)
    80006ec0:	f822                	sd	s0,48(sp)
    80006ec2:	f426                	sd	s1,40(sp)
    80006ec4:	f04a                	sd	s2,32(sp)
    80006ec6:	ec4e                	sd	s3,24(sp)
    80006ec8:	e852                	sd	s4,16(sp)
    80006eca:	e456                	sd	s5,8(sp)
    80006ecc:	e05a                	sd	s6,0(sp)
    80006ece:	0080                	addi	s0,sp,64
    80006ed0:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006ed2:	00058a9b          	sext.w	s5,a1
    80006ed6:	0015f793          	andi	a5,a1,1
    80006eda:	ebad                	bnez	a5,80006f4c <bd_initfree_pair+0x90>
    80006edc:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006ee0:	00599493          	slli	s1,s3,0x5
    80006ee4:	00029797          	auipc	a5,0x29
    80006ee8:	16c7b783          	ld	a5,364(a5) # 80030050 <bd_sizes>
    80006eec:	94be                	add	s1,s1,a5
    80006eee:	0104bb03          	ld	s6,16(s1)
    80006ef2:	855a                	mv	a0,s6
    80006ef4:	00000097          	auipc	ra,0x0
    80006ef8:	8b0080e7          	jalr	-1872(ra) # 800067a4 <bit_isset>
    80006efc:	892a                	mv	s2,a0
    80006efe:	85d2                	mv	a1,s4
    80006f00:	855a                	mv	a0,s6
    80006f02:	00000097          	auipc	ra,0x0
    80006f06:	8a2080e7          	jalr	-1886(ra) # 800067a4 <bit_isset>
  int free = 0;
    80006f0a:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006f0c:	02a90563          	beq	s2,a0,80006f36 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006f10:	45c1                	li	a1,16
    80006f12:	013599b3          	sll	s3,a1,s3
    80006f16:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006f1a:	02090c63          	beqz	s2,80006f52 <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006f1e:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006f22:	00029597          	auipc	a1,0x29
    80006f26:	1265b583          	ld	a1,294(a1) # 80030048 <bd_base>
    80006f2a:	95ce                	add	a1,a1,s3
    80006f2c:	8526                	mv	a0,s1
    80006f2e:	00000097          	auipc	ra,0x0
    80006f32:	48e080e7          	jalr	1166(ra) # 800073bc <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006f36:	855a                	mv	a0,s6
    80006f38:	70e2                	ld	ra,56(sp)
    80006f3a:	7442                	ld	s0,48(sp)
    80006f3c:	74a2                	ld	s1,40(sp)
    80006f3e:	7902                	ld	s2,32(sp)
    80006f40:	69e2                	ld	s3,24(sp)
    80006f42:	6a42                	ld	s4,16(sp)
    80006f44:	6aa2                	ld	s5,8(sp)
    80006f46:	6b02                	ld	s6,0(sp)
    80006f48:	6121                	addi	sp,sp,64
    80006f4a:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006f4c:	fff58a1b          	addiw	s4,a1,-1
    80006f50:	bf41                	j	80006ee0 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006f52:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006f56:	00029597          	auipc	a1,0x29
    80006f5a:	0f25b583          	ld	a1,242(a1) # 80030048 <bd_base>
    80006f5e:	95ce                	add	a1,a1,s3
    80006f60:	8526                	mv	a0,s1
    80006f62:	00000097          	auipc	ra,0x0
    80006f66:	45a080e7          	jalr	1114(ra) # 800073bc <lst_push>
    80006f6a:	b7f1                	j	80006f36 <bd_initfree_pair+0x7a>

0000000080006f6c <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006f6c:	711d                	addi	sp,sp,-96
    80006f6e:	ec86                	sd	ra,88(sp)
    80006f70:	e8a2                	sd	s0,80(sp)
    80006f72:	e4a6                	sd	s1,72(sp)
    80006f74:	e0ca                	sd	s2,64(sp)
    80006f76:	fc4e                	sd	s3,56(sp)
    80006f78:	f852                	sd	s4,48(sp)
    80006f7a:	f456                	sd	s5,40(sp)
    80006f7c:	f05a                	sd	s6,32(sp)
    80006f7e:	ec5e                	sd	s7,24(sp)
    80006f80:	e862                	sd	s8,16(sp)
    80006f82:	e466                	sd	s9,8(sp)
    80006f84:	e06a                	sd	s10,0(sp)
    80006f86:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006f88:	00029717          	auipc	a4,0x29
    80006f8c:	0d072703          	lw	a4,208(a4) # 80030058 <nsizes>
    80006f90:	4785                	li	a5,1
    80006f92:	06e7db63          	bge	a5,a4,80007008 <bd_initfree+0x9c>
    80006f96:	8aaa                	mv	s5,a0
    80006f98:	8b2e                	mv	s6,a1
    80006f9a:	4901                	li	s2,0
  int free = 0;
    80006f9c:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006f9e:	00029c97          	auipc	s9,0x29
    80006fa2:	0aac8c93          	addi	s9,s9,170 # 80030048 <bd_base>
  return n / BLK_SIZE(k);
    80006fa6:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006fa8:	00029b97          	auipc	s7,0x29
    80006fac:	0b0b8b93          	addi	s7,s7,176 # 80030058 <nsizes>
    80006fb0:	a039                	j	80006fbe <bd_initfree+0x52>
    80006fb2:	2905                	addiw	s2,s2,1
    80006fb4:	000ba783          	lw	a5,0(s7)
    80006fb8:	37fd                	addiw	a5,a5,-1
    80006fba:	04f95863          	bge	s2,a5,8000700a <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006fbe:	85d6                	mv	a1,s5
    80006fc0:	854a                	mv	a0,s2
    80006fc2:	00000097          	auipc	ra,0x0
    80006fc6:	dd6080e7          	jalr	-554(ra) # 80006d98 <blk_index_next>
    80006fca:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006fcc:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006fd0:	409b04bb          	subw	s1,s6,s1
    80006fd4:	012c17b3          	sll	a5,s8,s2
    80006fd8:	02f4c4b3          	div	s1,s1,a5
    80006fdc:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006fde:	85aa                	mv	a1,a0
    80006fe0:	854a                	mv	a0,s2
    80006fe2:	00000097          	auipc	ra,0x0
    80006fe6:	eda080e7          	jalr	-294(ra) # 80006ebc <bd_initfree_pair>
    80006fea:	01450d3b          	addw	s10,a0,s4
    80006fee:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006ff2:	fc99d0e3          	bge	s3,s1,80006fb2 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006ff6:	85a6                	mv	a1,s1
    80006ff8:	854a                	mv	a0,s2
    80006ffa:	00000097          	auipc	ra,0x0
    80006ffe:	ec2080e7          	jalr	-318(ra) # 80006ebc <bd_initfree_pair>
    80007002:	00ad0a3b          	addw	s4,s10,a0
    80007006:	b775                	j	80006fb2 <bd_initfree+0x46>
  int free = 0;
    80007008:	4a01                	li	s4,0
  }
  return free;
}
    8000700a:	8552                	mv	a0,s4
    8000700c:	60e6                	ld	ra,88(sp)
    8000700e:	6446                	ld	s0,80(sp)
    80007010:	64a6                	ld	s1,72(sp)
    80007012:	6906                	ld	s2,64(sp)
    80007014:	79e2                	ld	s3,56(sp)
    80007016:	7a42                	ld	s4,48(sp)
    80007018:	7aa2                	ld	s5,40(sp)
    8000701a:	7b02                	ld	s6,32(sp)
    8000701c:	6be2                	ld	s7,24(sp)
    8000701e:	6c42                	ld	s8,16(sp)
    80007020:	6ca2                	ld	s9,8(sp)
    80007022:	6d02                	ld	s10,0(sp)
    80007024:	6125                	addi	sp,sp,96
    80007026:	8082                	ret

0000000080007028 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80007028:	7179                	addi	sp,sp,-48
    8000702a:	f406                	sd	ra,40(sp)
    8000702c:	f022                	sd	s0,32(sp)
    8000702e:	ec26                	sd	s1,24(sp)
    80007030:	e84a                	sd	s2,16(sp)
    80007032:	e44e                	sd	s3,8(sp)
    80007034:	1800                	addi	s0,sp,48
    80007036:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80007038:	00029997          	auipc	s3,0x29
    8000703c:	01098993          	addi	s3,s3,16 # 80030048 <bd_base>
    80007040:	0009b483          	ld	s1,0(s3)
    80007044:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80007048:	00029797          	auipc	a5,0x29
    8000704c:	0107a783          	lw	a5,16(a5) # 80030058 <nsizes>
    80007050:	37fd                	addiw	a5,a5,-1
    80007052:	4641                	li	a2,16
    80007054:	00f61633          	sll	a2,a2,a5
    80007058:	85a6                	mv	a1,s1
    8000705a:	00002517          	auipc	a0,0x2
    8000705e:	9f650513          	addi	a0,a0,-1546 # 80008a50 <userret+0x9c0>
    80007062:	ffff9097          	auipc	ra,0xffff9
    80007066:	540080e7          	jalr	1344(ra) # 800005a2 <printf>
  bd_mark(bd_base, p);
    8000706a:	85ca                	mv	a1,s2
    8000706c:	0009b503          	ld	a0,0(s3)
    80007070:	00000097          	auipc	ra,0x0
    80007074:	d74080e7          	jalr	-652(ra) # 80006de4 <bd_mark>
  return meta;
}
    80007078:	8526                	mv	a0,s1
    8000707a:	70a2                	ld	ra,40(sp)
    8000707c:	7402                	ld	s0,32(sp)
    8000707e:	64e2                	ld	s1,24(sp)
    80007080:	6942                	ld	s2,16(sp)
    80007082:	69a2                	ld	s3,8(sp)
    80007084:	6145                	addi	sp,sp,48
    80007086:	8082                	ret

0000000080007088 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80007088:	1101                	addi	sp,sp,-32
    8000708a:	ec06                	sd	ra,24(sp)
    8000708c:	e822                	sd	s0,16(sp)
    8000708e:	e426                	sd	s1,8(sp)
    80007090:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80007092:	00029497          	auipc	s1,0x29
    80007096:	fc64a483          	lw	s1,-58(s1) # 80030058 <nsizes>
    8000709a:	fff4879b          	addiw	a5,s1,-1
    8000709e:	44c1                	li	s1,16
    800070a0:	00f494b3          	sll	s1,s1,a5
    800070a4:	00029797          	auipc	a5,0x29
    800070a8:	fa47b783          	ld	a5,-92(a5) # 80030048 <bd_base>
    800070ac:	8d1d                	sub	a0,a0,a5
    800070ae:	40a4853b          	subw	a0,s1,a0
    800070b2:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    800070b6:	00905a63          	blez	s1,800070ca <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    800070ba:	357d                	addiw	a0,a0,-1
    800070bc:	41f5549b          	sraiw	s1,a0,0x1f
    800070c0:	01c4d49b          	srliw	s1,s1,0x1c
    800070c4:	9ca9                	addw	s1,s1,a0
    800070c6:	98c1                	andi	s1,s1,-16
    800070c8:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    800070ca:	85a6                	mv	a1,s1
    800070cc:	00002517          	auipc	a0,0x2
    800070d0:	9bc50513          	addi	a0,a0,-1604 # 80008a88 <userret+0x9f8>
    800070d4:	ffff9097          	auipc	ra,0xffff9
    800070d8:	4ce080e7          	jalr	1230(ra) # 800005a2 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    800070dc:	00029717          	auipc	a4,0x29
    800070e0:	f6c73703          	ld	a4,-148(a4) # 80030048 <bd_base>
    800070e4:	00029597          	auipc	a1,0x29
    800070e8:	f745a583          	lw	a1,-140(a1) # 80030058 <nsizes>
    800070ec:	fff5879b          	addiw	a5,a1,-1
    800070f0:	45c1                	li	a1,16
    800070f2:	00f595b3          	sll	a1,a1,a5
    800070f6:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    800070fa:	95ba                	add	a1,a1,a4
    800070fc:	953a                	add	a0,a0,a4
    800070fe:	00000097          	auipc	ra,0x0
    80007102:	ce6080e7          	jalr	-794(ra) # 80006de4 <bd_mark>
  return unavailable;
}
    80007106:	8526                	mv	a0,s1
    80007108:	60e2                	ld	ra,24(sp)
    8000710a:	6442                	ld	s0,16(sp)
    8000710c:	64a2                	ld	s1,8(sp)
    8000710e:	6105                	addi	sp,sp,32
    80007110:	8082                	ret

0000000080007112 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80007112:	715d                	addi	sp,sp,-80
    80007114:	e486                	sd	ra,72(sp)
    80007116:	e0a2                	sd	s0,64(sp)
    80007118:	fc26                	sd	s1,56(sp)
    8000711a:	f84a                	sd	s2,48(sp)
    8000711c:	f44e                	sd	s3,40(sp)
    8000711e:	f052                	sd	s4,32(sp)
    80007120:	ec56                	sd	s5,24(sp)
    80007122:	e85a                	sd	s6,16(sp)
    80007124:	e45e                	sd	s7,8(sp)
    80007126:	e062                	sd	s8,0(sp)
    80007128:	0880                	addi	s0,sp,80
    8000712a:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    8000712c:	fff50493          	addi	s1,a0,-1
    80007130:	98c1                	andi	s1,s1,-16
    80007132:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80007134:	00002597          	auipc	a1,0x2
    80007138:	97458593          	addi	a1,a1,-1676 # 80008aa8 <userret+0xa18>
    8000713c:	00029517          	auipc	a0,0x29
    80007140:	ec450513          	addi	a0,a0,-316 # 80030000 <lock>
    80007144:	ffffa097          	auipc	ra,0xffffa
    80007148:	a56080e7          	jalr	-1450(ra) # 80000b9a <initlock>
  bd_base = (void *) p;
    8000714c:	00029797          	auipc	a5,0x29
    80007150:	ee97be23          	sd	s1,-260(a5) # 80030048 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007154:	409c0933          	sub	s2,s8,s1
    80007158:	43f95513          	srai	a0,s2,0x3f
    8000715c:	893d                	andi	a0,a0,15
    8000715e:	954a                	add	a0,a0,s2
    80007160:	8511                	srai	a0,a0,0x4
    80007162:	00000097          	auipc	ra,0x0
    80007166:	c60080e7          	jalr	-928(ra) # 80006dc2 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    8000716a:	47c1                	li	a5,16
    8000716c:	00a797b3          	sll	a5,a5,a0
    80007170:	1b27c663          	blt	a5,s2,8000731c <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007174:	2505                	addiw	a0,a0,1
    80007176:	00029797          	auipc	a5,0x29
    8000717a:	eea7a123          	sw	a0,-286(a5) # 80030058 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    8000717e:	00029997          	auipc	s3,0x29
    80007182:	eda98993          	addi	s3,s3,-294 # 80030058 <nsizes>
    80007186:	0009a603          	lw	a2,0(s3)
    8000718a:	85ca                	mv	a1,s2
    8000718c:	00002517          	auipc	a0,0x2
    80007190:	92450513          	addi	a0,a0,-1756 # 80008ab0 <userret+0xa20>
    80007194:	ffff9097          	auipc	ra,0xffff9
    80007198:	40e080e7          	jalr	1038(ra) # 800005a2 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    8000719c:	00029797          	auipc	a5,0x29
    800071a0:	ea97ba23          	sd	s1,-332(a5) # 80030050 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    800071a4:	0009a603          	lw	a2,0(s3)
    800071a8:	00561913          	slli	s2,a2,0x5
    800071ac:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    800071ae:	0056161b          	slliw	a2,a2,0x5
    800071b2:	4581                	li	a1,0
    800071b4:	8526                	mv	a0,s1
    800071b6:	ffffa097          	auipc	ra,0xffffa
    800071ba:	da0080e7          	jalr	-608(ra) # 80000f56 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    800071be:	0009a783          	lw	a5,0(s3)
    800071c2:	06f05a63          	blez	a5,80007236 <bd_init+0x124>
    800071c6:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    800071c8:	00029a97          	auipc	s5,0x29
    800071cc:	e88a8a93          	addi	s5,s5,-376 # 80030050 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800071d0:	00029a17          	auipc	s4,0x29
    800071d4:	e88a0a13          	addi	s4,s4,-376 # 80030058 <nsizes>
    800071d8:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    800071da:	00599b93          	slli	s7,s3,0x5
    800071de:	000ab503          	ld	a0,0(s5)
    800071e2:	955e                	add	a0,a0,s7
    800071e4:	00000097          	auipc	ra,0x0
    800071e8:	166080e7          	jalr	358(ra) # 8000734a <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800071ec:	000a2483          	lw	s1,0(s4)
    800071f0:	34fd                	addiw	s1,s1,-1
    800071f2:	413484bb          	subw	s1,s1,s3
    800071f6:	009b14bb          	sllw	s1,s6,s1
    800071fa:	fff4879b          	addiw	a5,s1,-1
    800071fe:	41f7d49b          	sraiw	s1,a5,0x1f
    80007202:	01d4d49b          	srliw	s1,s1,0x1d
    80007206:	9cbd                	addw	s1,s1,a5
    80007208:	98e1                	andi	s1,s1,-8
    8000720a:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    8000720c:	000ab783          	ld	a5,0(s5)
    80007210:	9bbe                	add	s7,s7,a5
    80007212:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80007216:	848d                	srai	s1,s1,0x3
    80007218:	8626                	mv	a2,s1
    8000721a:	4581                	li	a1,0
    8000721c:	854a                	mv	a0,s2
    8000721e:	ffffa097          	auipc	ra,0xffffa
    80007222:	d38080e7          	jalr	-712(ra) # 80000f56 <memset>
    p += sz;
    80007226:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80007228:	0985                	addi	s3,s3,1
    8000722a:	000a2703          	lw	a4,0(s4)
    8000722e:	0009879b          	sext.w	a5,s3
    80007232:	fae7c4e3          	blt	a5,a4,800071da <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80007236:	00029797          	auipc	a5,0x29
    8000723a:	e227a783          	lw	a5,-478(a5) # 80030058 <nsizes>
    8000723e:	4705                	li	a4,1
    80007240:	06f75163          	bge	a4,a5,800072a2 <bd_init+0x190>
    80007244:	02000a13          	li	s4,32
    80007248:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000724a:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    8000724c:	00029b17          	auipc	s6,0x29
    80007250:	e04b0b13          	addi	s6,s6,-508 # 80030050 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80007254:	00029a97          	auipc	s5,0x29
    80007258:	e04a8a93          	addi	s5,s5,-508 # 80030058 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000725c:	37fd                	addiw	a5,a5,-1
    8000725e:	413787bb          	subw	a5,a5,s3
    80007262:	00fb94bb          	sllw	s1,s7,a5
    80007266:	fff4879b          	addiw	a5,s1,-1
    8000726a:	41f7d49b          	sraiw	s1,a5,0x1f
    8000726e:	01d4d49b          	srliw	s1,s1,0x1d
    80007272:	9cbd                	addw	s1,s1,a5
    80007274:	98e1                	andi	s1,s1,-8
    80007276:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80007278:	000b3783          	ld	a5,0(s6)
    8000727c:	97d2                	add	a5,a5,s4
    8000727e:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80007282:	848d                	srai	s1,s1,0x3
    80007284:	8626                	mv	a2,s1
    80007286:	4581                	li	a1,0
    80007288:	854a                	mv	a0,s2
    8000728a:	ffffa097          	auipc	ra,0xffffa
    8000728e:	ccc080e7          	jalr	-820(ra) # 80000f56 <memset>
    p += sz;
    80007292:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80007294:	2985                	addiw	s3,s3,1
    80007296:	000aa783          	lw	a5,0(s5)
    8000729a:	020a0a13          	addi	s4,s4,32
    8000729e:	faf9cfe3          	blt	s3,a5,8000725c <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    800072a2:	197d                	addi	s2,s2,-1
    800072a4:	ff097913          	andi	s2,s2,-16
    800072a8:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    800072aa:	854a                	mv	a0,s2
    800072ac:	00000097          	auipc	ra,0x0
    800072b0:	d7c080e7          	jalr	-644(ra) # 80007028 <bd_mark_data_structures>
    800072b4:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    800072b6:	85ca                	mv	a1,s2
    800072b8:	8562                	mv	a0,s8
    800072ba:	00000097          	auipc	ra,0x0
    800072be:	dce080e7          	jalr	-562(ra) # 80007088 <bd_mark_unavailable>
    800072c2:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    800072c4:	00029a97          	auipc	s5,0x29
    800072c8:	d94a8a93          	addi	s5,s5,-620 # 80030058 <nsizes>
    800072cc:	000aa783          	lw	a5,0(s5)
    800072d0:	37fd                	addiw	a5,a5,-1
    800072d2:	44c1                	li	s1,16
    800072d4:	00f497b3          	sll	a5,s1,a5
    800072d8:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    800072da:	00029597          	auipc	a1,0x29
    800072de:	d6e5b583          	ld	a1,-658(a1) # 80030048 <bd_base>
    800072e2:	95be                	add	a1,a1,a5
    800072e4:	854a                	mv	a0,s2
    800072e6:	00000097          	auipc	ra,0x0
    800072ea:	c86080e7          	jalr	-890(ra) # 80006f6c <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    800072ee:	000aa603          	lw	a2,0(s5)
    800072f2:	367d                	addiw	a2,a2,-1
    800072f4:	00c49633          	sll	a2,s1,a2
    800072f8:	41460633          	sub	a2,a2,s4
    800072fc:	41360633          	sub	a2,a2,s3
    80007300:	02c51463          	bne	a0,a2,80007328 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80007304:	60a6                	ld	ra,72(sp)
    80007306:	6406                	ld	s0,64(sp)
    80007308:	74e2                	ld	s1,56(sp)
    8000730a:	7942                	ld	s2,48(sp)
    8000730c:	79a2                	ld	s3,40(sp)
    8000730e:	7a02                	ld	s4,32(sp)
    80007310:	6ae2                	ld	s5,24(sp)
    80007312:	6b42                	ld	s6,16(sp)
    80007314:	6ba2                	ld	s7,8(sp)
    80007316:	6c02                	ld	s8,0(sp)
    80007318:	6161                	addi	sp,sp,80
    8000731a:	8082                	ret
    nsizes++;  // round up to the next power of 2
    8000731c:	2509                	addiw	a0,a0,2
    8000731e:	00029797          	auipc	a5,0x29
    80007322:	d2a7ad23          	sw	a0,-710(a5) # 80030058 <nsizes>
    80007326:	bda1                	j	8000717e <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007328:	85aa                	mv	a1,a0
    8000732a:	00001517          	auipc	a0,0x1
    8000732e:	7c650513          	addi	a0,a0,1990 # 80008af0 <userret+0xa60>
    80007332:	ffff9097          	auipc	ra,0xffff9
    80007336:	270080e7          	jalr	624(ra) # 800005a2 <printf>
    panic("bd_init: free mem");
    8000733a:	00001517          	auipc	a0,0x1
    8000733e:	7c650513          	addi	a0,a0,1990 # 80008b00 <userret+0xa70>
    80007342:	ffff9097          	auipc	ra,0xffff9
    80007346:	206080e7          	jalr	518(ra) # 80000548 <panic>

000000008000734a <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    8000734a:	1141                	addi	sp,sp,-16
    8000734c:	e422                	sd	s0,8(sp)
    8000734e:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007350:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80007352:	e508                	sd	a0,8(a0)
}
    80007354:	6422                	ld	s0,8(sp)
    80007356:	0141                	addi	sp,sp,16
    80007358:	8082                	ret

000000008000735a <lst_empty>:

int
lst_empty(struct list *lst) {
    8000735a:	1141                	addi	sp,sp,-16
    8000735c:	e422                	sd	s0,8(sp)
    8000735e:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007360:	611c                	ld	a5,0(a0)
    80007362:	40a78533          	sub	a0,a5,a0
}
    80007366:	00153513          	seqz	a0,a0
    8000736a:	6422                	ld	s0,8(sp)
    8000736c:	0141                	addi	sp,sp,16
    8000736e:	8082                	ret

0000000080007370 <lst_remove>:

void
lst_remove(struct list *e) {
    80007370:	1141                	addi	sp,sp,-16
    80007372:	e422                	sd	s0,8(sp)
    80007374:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007376:	6518                	ld	a4,8(a0)
    80007378:	611c                	ld	a5,0(a0)
    8000737a:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    8000737c:	6518                	ld	a4,8(a0)
    8000737e:	e798                	sd	a4,8(a5)
}
    80007380:	6422                	ld	s0,8(sp)
    80007382:	0141                	addi	sp,sp,16
    80007384:	8082                	ret

0000000080007386 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007386:	1101                	addi	sp,sp,-32
    80007388:	ec06                	sd	ra,24(sp)
    8000738a:	e822                	sd	s0,16(sp)
    8000738c:	e426                	sd	s1,8(sp)
    8000738e:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007390:	6104                	ld	s1,0(a0)
    80007392:	00a48d63          	beq	s1,a0,800073ac <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007396:	8526                	mv	a0,s1
    80007398:	00000097          	auipc	ra,0x0
    8000739c:	fd8080e7          	jalr	-40(ra) # 80007370 <lst_remove>
  return (void *)p;
}
    800073a0:	8526                	mv	a0,s1
    800073a2:	60e2                	ld	ra,24(sp)
    800073a4:	6442                	ld	s0,16(sp)
    800073a6:	64a2                	ld	s1,8(sp)
    800073a8:	6105                	addi	sp,sp,32
    800073aa:	8082                	ret
    panic("lst_pop");
    800073ac:	00001517          	auipc	a0,0x1
    800073b0:	76c50513          	addi	a0,a0,1900 # 80008b18 <userret+0xa88>
    800073b4:	ffff9097          	auipc	ra,0xffff9
    800073b8:	194080e7          	jalr	404(ra) # 80000548 <panic>

00000000800073bc <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    800073bc:	1141                	addi	sp,sp,-16
    800073be:	e422                	sd	s0,8(sp)
    800073c0:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    800073c2:	611c                	ld	a5,0(a0)
    800073c4:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    800073c6:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    800073c8:	611c                	ld	a5,0(a0)
    800073ca:	e78c                	sd	a1,8(a5)
  lst->next = e;
    800073cc:	e10c                	sd	a1,0(a0)
}
    800073ce:	6422                	ld	s0,8(sp)
    800073d0:	0141                	addi	sp,sp,16
    800073d2:	8082                	ret

00000000800073d4 <lst_print>:

void
lst_print(struct list *lst)
{
    800073d4:	7179                	addi	sp,sp,-48
    800073d6:	f406                	sd	ra,40(sp)
    800073d8:	f022                	sd	s0,32(sp)
    800073da:	ec26                	sd	s1,24(sp)
    800073dc:	e84a                	sd	s2,16(sp)
    800073de:	e44e                	sd	s3,8(sp)
    800073e0:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800073e2:	6104                	ld	s1,0(a0)
    800073e4:	02950063          	beq	a0,s1,80007404 <lst_print+0x30>
    800073e8:	892a                	mv	s2,a0
    printf(" %p", p);
    800073ea:	00001997          	auipc	s3,0x1
    800073ee:	73698993          	addi	s3,s3,1846 # 80008b20 <userret+0xa90>
    800073f2:	85a6                	mv	a1,s1
    800073f4:	854e                	mv	a0,s3
    800073f6:	ffff9097          	auipc	ra,0xffff9
    800073fa:	1ac080e7          	jalr	428(ra) # 800005a2 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800073fe:	6084                	ld	s1,0(s1)
    80007400:	fe9919e3          	bne	s2,s1,800073f2 <lst_print+0x1e>
  }
  printf("\n");
    80007404:	00001517          	auipc	a0,0x1
    80007408:	edc50513          	addi	a0,a0,-292 # 800082e0 <userret+0x250>
    8000740c:	ffff9097          	auipc	ra,0xffff9
    80007410:	196080e7          	jalr	406(ra) # 800005a2 <printf>
}
    80007414:	70a2                	ld	ra,40(sp)
    80007416:	7402                	ld	s0,32(sp)
    80007418:	64e2                	ld	s1,24(sp)
    8000741a:	6942                	ld	s2,16(sp)
    8000741c:	69a2                	ld	s3,8(sp)
    8000741e:	6145                	addi	sp,sp,48
    80007420:	8082                	ret
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
