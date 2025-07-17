
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
    80000060:	f2478793          	addi	a5,a5,-220 # 80005f80 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffcd7a3>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e8078793          	addi	a5,a5,-384 # 80000f26 <main>
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
    80000112:	a00080e7          	jalr	-1536(ra) # 80000b0e <acquire>
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
    80000140:	926080e7          	jalr	-1754(ra) # 80001a62 <myproc>
    80000144:	5d1c                	lw	a5,56(a0)
    80000146:	e7b5                	bnez	a5,800001b2 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    80000148:	85a6                	mv	a1,s1
    8000014a:	854a                	mv	a0,s2
    8000014c:	00002097          	auipc	ra,0x2
    80000150:	0fa080e7          	jalr	250(ra) # 80002246 <sleep>
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
    8000018c:	318080e7          	jalr	792(ra) # 800024a0 <either_copyout>
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
    800001a8:	9da080e7          	jalr	-1574(ra) # 80000b7e <release>

  return target - n;
    800001ac:	413b053b          	subw	a0,s6,s3
    800001b0:	a811                	j	800001c4 <consoleread+0xe4>
        release(&cons.lock);
    800001b2:	00012517          	auipc	a0,0x12
    800001b6:	64e50513          	addi	a0,a0,1614 # 80012800 <cons>
    800001ba:	00001097          	auipc	ra,0x1
    800001be:	9c4080e7          	jalr	-1596(ra) # 80000b7e <release>
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
    800001f2:	00031797          	auipc	a5,0x31
    800001f6:	e2e7a783          	lw	a5,-466(a5) # 80031020 <panicked>
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
    80000264:	8ae080e7          	jalr	-1874(ra) # 80000b0e <acquire>
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
    8000028a:	270080e7          	jalr	624(ra) # 800024f6 <either_copyin>
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
    800002b0:	8d2080e7          	jalr	-1838(ra) # 80000b7e <release>
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
    800002e2:	830080e7          	jalr	-2000(ra) # 80000b0e <acquire>

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
    80000300:	250080e7          	jalr	592(ra) # 8000254c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00012517          	auipc	a0,0x12
    80000308:	4fc50513          	addi	a0,a0,1276 # 80012800 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	872080e7          	jalr	-1934(ra) # 80000b7e <release>
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
    80000454:	f76080e7          	jalr	-138(ra) # 800023c6 <wakeup>
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
    80000476:	54e080e7          	jalr	1358(ra) # 800009c0 <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	33a080e7          	jalr	826(ra) # 800007b4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00029797          	auipc	a5,0x29
    80000486:	77e78793          	addi	a5,a5,1918 # 80029c00 <devsw>
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
    800004c8:	67c60613          	addi	a2,a2,1660 # 80008b40 <digits>
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
    8000057a:	d9250513          	addi	a0,a0,-622 # 80008308 <userret+0x278>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	024080e7          	jalr	36(ra) # 800005a2 <printf>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    80000586:	00008517          	auipc	a0,0x8
    8000058a:	ba250513          	addi	a0,a0,-1118 # 80008128 <userret+0x98>
    8000058e:	00000097          	auipc	ra,0x0
    80000592:	014080e7          	jalr	20(ra) # 800005a2 <printf>
  panicked = 1; // freeze other CPUs
    80000596:	4785                	li	a5,1
    80000598:	00031717          	auipc	a4,0x31
    8000059c:	a8f72423          	sw	a5,-1400(a4) # 80031020 <panicked>
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
    80000604:	540b0b13          	addi	s6,s6,1344 # 80008b40 <digits>
    switch(c){
    80000608:	07300c93          	li	s9,115
    8000060c:	06400c13          	li	s8,100
    80000610:	a82d                	j	8000064a <printf+0xa8>
    acquire(&pr.lock);
    80000612:	00012517          	auipc	a0,0x12
    80000616:	29e50513          	addi	a0,a0,670 # 800128b0 <pr>
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	4f4080e7          	jalr	1268(ra) # 80000b0e <acquire>
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
    8000077c:	406080e7          	jalr	1030(ra) # 80000b7e <release>
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
    800007a2:	222080e7          	jalr	546(ra) # 800009c0 <initlock>
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

0000000080000864 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000864:	1101                	addi	sp,sp,-32
    80000866:	ec06                	sd	ra,24(sp)
    80000868:	e822                	sd	s0,16(sp)
    8000086a:	e426                	sd	s1,8(sp)
    8000086c:	e04a                	sd	s2,0(sp)
    8000086e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000870:	03451793          	slli	a5,a0,0x34
    80000874:	ebb9                	bnez	a5,800008ca <kfree+0x66>
    80000876:	84aa                	mv	s1,a0
    80000878:	00030797          	auipc	a5,0x30
    8000087c:	7e478793          	addi	a5,a5,2020 # 8003105c <end>
    80000880:	04f56563          	bltu	a0,a5,800008ca <kfree+0x66>
    80000884:	47c5                	li	a5,17
    80000886:	07ee                	slli	a5,a5,0x1b
    80000888:	04f57163          	bgeu	a0,a5,800008ca <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    8000088c:	6605                	lui	a2,0x1
    8000088e:	4585                	li	a1,1
    80000890:	00000097          	auipc	ra,0x0
    80000894:	4e8080e7          	jalr	1256(ra) # 80000d78 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000898:	00012917          	auipc	s2,0x12
    8000089c:	04090913          	addi	s2,s2,64 # 800128d8 <kmem>
    800008a0:	854a                	mv	a0,s2
    800008a2:	00000097          	auipc	ra,0x0
    800008a6:	26c080e7          	jalr	620(ra) # 80000b0e <acquire>
  r->next = kmem.freelist;
    800008aa:	02093783          	ld	a5,32(s2)
    800008ae:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800008b0:	02993023          	sd	s1,32(s2)
  release(&kmem.lock);
    800008b4:	854a                	mv	a0,s2
    800008b6:	00000097          	auipc	ra,0x0
    800008ba:	2c8080e7          	jalr	712(ra) # 80000b7e <release>
}
    800008be:	60e2                	ld	ra,24(sp)
    800008c0:	6442                	ld	s0,16(sp)
    800008c2:	64a2                	ld	s1,8(sp)
    800008c4:	6902                	ld	s2,0(sp)
    800008c6:	6105                	addi	sp,sp,32
    800008c8:	8082                	ret
    panic("kfree");
    800008ca:	00008517          	auipc	a0,0x8
    800008ce:	94e50513          	addi	a0,a0,-1714 # 80008218 <userret+0x188>
    800008d2:	00000097          	auipc	ra,0x0
    800008d6:	c76080e7          	jalr	-906(ra) # 80000548 <panic>

00000000800008da <freerange>:
{
    800008da:	7179                	addi	sp,sp,-48
    800008dc:	f406                	sd	ra,40(sp)
    800008de:	f022                	sd	s0,32(sp)
    800008e0:	ec26                	sd	s1,24(sp)
    800008e2:	e84a                	sd	s2,16(sp)
    800008e4:	e44e                	sd	s3,8(sp)
    800008e6:	e052                	sd	s4,0(sp)
    800008e8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800008ea:	6785                	lui	a5,0x1
    800008ec:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800008f0:	94aa                	add	s1,s1,a0
    800008f2:	757d                	lui	a0,0xfffff
    800008f4:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800008f6:	94be                	add	s1,s1,a5
    800008f8:	0095ee63          	bltu	a1,s1,80000914 <freerange+0x3a>
    800008fc:	892e                	mv	s2,a1
    kfree(p);
    800008fe:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000900:	6985                	lui	s3,0x1
    kfree(p);
    80000902:	01448533          	add	a0,s1,s4
    80000906:	00000097          	auipc	ra,0x0
    8000090a:	f5e080e7          	jalr	-162(ra) # 80000864 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000090e:	94ce                	add	s1,s1,s3
    80000910:	fe9979e3          	bgeu	s2,s1,80000902 <freerange+0x28>
}
    80000914:	70a2                	ld	ra,40(sp)
    80000916:	7402                	ld	s0,32(sp)
    80000918:	64e2                	ld	s1,24(sp)
    8000091a:	6942                	ld	s2,16(sp)
    8000091c:	69a2                	ld	s3,8(sp)
    8000091e:	6a02                	ld	s4,0(sp)
    80000920:	6145                	addi	sp,sp,48
    80000922:	8082                	ret

0000000080000924 <kinit>:
{
    80000924:	1141                	addi	sp,sp,-16
    80000926:	e406                	sd	ra,8(sp)
    80000928:	e022                	sd	s0,0(sp)
    8000092a:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    8000092c:	00008597          	auipc	a1,0x8
    80000930:	8f458593          	addi	a1,a1,-1804 # 80008220 <userret+0x190>
    80000934:	00012517          	auipc	a0,0x12
    80000938:	fa450513          	addi	a0,a0,-92 # 800128d8 <kmem>
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	084080e7          	jalr	132(ra) # 800009c0 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000944:	45c5                	li	a1,17
    80000946:	05ee                	slli	a1,a1,0x1b
    80000948:	00030517          	auipc	a0,0x30
    8000094c:	71450513          	addi	a0,a0,1812 # 8003105c <end>
    80000950:	00000097          	auipc	ra,0x0
    80000954:	f8a080e7          	jalr	-118(ra) # 800008da <freerange>
}
    80000958:	60a2                	ld	ra,8(sp)
    8000095a:	6402                	ld	s0,0(sp)
    8000095c:	0141                	addi	sp,sp,16
    8000095e:	8082                	ret

0000000080000960 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000960:	1101                	addi	sp,sp,-32
    80000962:	ec06                	sd	ra,24(sp)
    80000964:	e822                	sd	s0,16(sp)
    80000966:	e426                	sd	s1,8(sp)
    80000968:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    8000096a:	00012497          	auipc	s1,0x12
    8000096e:	f6e48493          	addi	s1,s1,-146 # 800128d8 <kmem>
    80000972:	8526                	mv	a0,s1
    80000974:	00000097          	auipc	ra,0x0
    80000978:	19a080e7          	jalr	410(ra) # 80000b0e <acquire>
  r = kmem.freelist;
    8000097c:	7084                	ld	s1,32(s1)
  if(r)
    8000097e:	c885                	beqz	s1,800009ae <kalloc+0x4e>
    kmem.freelist = r->next;
    80000980:	609c                	ld	a5,0(s1)
    80000982:	00012517          	auipc	a0,0x12
    80000986:	f5650513          	addi	a0,a0,-170 # 800128d8 <kmem>
    8000098a:	f11c                	sd	a5,32(a0)
  release(&kmem.lock);
    8000098c:	00000097          	auipc	ra,0x0
    80000990:	1f2080e7          	jalr	498(ra) # 80000b7e <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000994:	6605                	lui	a2,0x1
    80000996:	4595                	li	a1,5
    80000998:	8526                	mv	a0,s1
    8000099a:	00000097          	auipc	ra,0x0
    8000099e:	3de080e7          	jalr	990(ra) # 80000d78 <memset>
  return (void*)r;
}
    800009a2:	8526                	mv	a0,s1
    800009a4:	60e2                	ld	ra,24(sp)
    800009a6:	6442                	ld	s0,16(sp)
    800009a8:	64a2                	ld	s1,8(sp)
    800009aa:	6105                	addi	sp,sp,32
    800009ac:	8082                	ret
  release(&kmem.lock);
    800009ae:	00012517          	auipc	a0,0x12
    800009b2:	f2a50513          	addi	a0,a0,-214 # 800128d8 <kmem>
    800009b6:	00000097          	auipc	ra,0x0
    800009ba:	1c8080e7          	jalr	456(ra) # 80000b7e <release>
  if(r)
    800009be:	b7d5                	j	800009a2 <kalloc+0x42>

00000000800009c0 <initlock>:

// assumes locks are not freed
void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
    800009c0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800009c2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800009c6:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    800009ca:	00052e23          	sw	zero,28(a0)
  lk->n = 0;
    800009ce:	00052c23          	sw	zero,24(a0)
  if(nlock >= NLOCK)
    800009d2:	00030797          	auipc	a5,0x30
    800009d6:	6527a783          	lw	a5,1618(a5) # 80031024 <nlock>
    800009da:	3e700713          	li	a4,999
    800009de:	02f74063          	blt	a4,a5,800009fe <initlock+0x3e>
    panic("initlock");
  locks[nlock] = lk;
    800009e2:	00379693          	slli	a3,a5,0x3
    800009e6:	00012717          	auipc	a4,0x12
    800009ea:	f1a70713          	addi	a4,a4,-230 # 80012900 <locks>
    800009ee:	9736                	add	a4,a4,a3
    800009f0:	e308                	sd	a0,0(a4)
  nlock++;
    800009f2:	2785                	addiw	a5,a5,1
    800009f4:	00030717          	auipc	a4,0x30
    800009f8:	62f72823          	sw	a5,1584(a4) # 80031024 <nlock>
    800009fc:	8082                	ret
{
    800009fe:	1141                	addi	sp,sp,-16
    80000a00:	e406                	sd	ra,8(sp)
    80000a02:	e022                	sd	s0,0(sp)
    80000a04:	0800                	addi	s0,sp,16
    panic("initlock");
    80000a06:	00008517          	auipc	a0,0x8
    80000a0a:	82250513          	addi	a0,a0,-2014 # 80008228 <userret+0x198>
    80000a0e:	00000097          	auipc	ra,0x0
    80000a12:	b3a080e7          	jalr	-1222(ra) # 80000548 <panic>

0000000080000a16 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000a16:	1101                	addi	sp,sp,-32
    80000a18:	ec06                	sd	ra,24(sp)
    80000a1a:	e822                	sd	s0,16(sp)
    80000a1c:	e426                	sd	s1,8(sp)
    80000a1e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a20:	100024f3          	csrr	s1,sstatus
    80000a24:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000a28:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000a2a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000a2e:	00001097          	auipc	ra,0x1
    80000a32:	018080e7          	jalr	24(ra) # 80001a46 <mycpu>
    80000a36:	5d3c                	lw	a5,120(a0)
    80000a38:	cf89                	beqz	a5,80000a52 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000a3a:	00001097          	auipc	ra,0x1
    80000a3e:	00c080e7          	jalr	12(ra) # 80001a46 <mycpu>
    80000a42:	5d3c                	lw	a5,120(a0)
    80000a44:	2785                	addiw	a5,a5,1
    80000a46:	dd3c                	sw	a5,120(a0)
}
    80000a48:	60e2                	ld	ra,24(sp)
    80000a4a:	6442                	ld	s0,16(sp)
    80000a4c:	64a2                	ld	s1,8(sp)
    80000a4e:	6105                	addi	sp,sp,32
    80000a50:	8082                	ret
    mycpu()->intena = old;
    80000a52:	00001097          	auipc	ra,0x1
    80000a56:	ff4080e7          	jalr	-12(ra) # 80001a46 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000a5a:	8085                	srli	s1,s1,0x1
    80000a5c:	8885                	andi	s1,s1,1
    80000a5e:	dd64                	sw	s1,124(a0)
    80000a60:	bfe9                	j	80000a3a <push_off+0x24>

0000000080000a62 <pop_off>:

void
pop_off(void)
{
    80000a62:	1141                	addi	sp,sp,-16
    80000a64:	e406                	sd	ra,8(sp)
    80000a66:	e022                	sd	s0,0(sp)
    80000a68:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000a6a:	00001097          	auipc	ra,0x1
    80000a6e:	fdc080e7          	jalr	-36(ra) # 80001a46 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a72:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000a76:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000a78:	eb9d                	bnez	a5,80000aae <pop_off+0x4c>
    panic("pop_off - interruptible");
  c->noff -= 1;
    80000a7a:	5d3c                	lw	a5,120(a0)
    80000a7c:	37fd                	addiw	a5,a5,-1
    80000a7e:	0007871b          	sext.w	a4,a5
    80000a82:	dd3c                	sw	a5,120(a0)
  if(c->noff < 0)
    80000a84:	02074d63          	bltz	a4,80000abe <pop_off+0x5c>
    panic("pop_off");
  if(c->noff == 0 && c->intena)
    80000a88:	ef19                	bnez	a4,80000aa6 <pop_off+0x44>
    80000a8a:	5d7c                	lw	a5,124(a0)
    80000a8c:	cf89                	beqz	a5,80000aa6 <pop_off+0x44>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000a8e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000a92:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000a96:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a9a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000a9e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000aa2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000aa6:	60a2                	ld	ra,8(sp)
    80000aa8:	6402                	ld	s0,0(sp)
    80000aaa:	0141                	addi	sp,sp,16
    80000aac:	8082                	ret
    panic("pop_off - interruptible");
    80000aae:	00007517          	auipc	a0,0x7
    80000ab2:	78a50513          	addi	a0,a0,1930 # 80008238 <userret+0x1a8>
    80000ab6:	00000097          	auipc	ra,0x0
    80000aba:	a92080e7          	jalr	-1390(ra) # 80000548 <panic>
    panic("pop_off");
    80000abe:	00007517          	auipc	a0,0x7
    80000ac2:	79250513          	addi	a0,a0,1938 # 80008250 <userret+0x1c0>
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	a82080e7          	jalr	-1406(ra) # 80000548 <panic>

0000000080000ace <holding>:
{
    80000ace:	1101                	addi	sp,sp,-32
    80000ad0:	ec06                	sd	ra,24(sp)
    80000ad2:	e822                	sd	s0,16(sp)
    80000ad4:	e426                	sd	s1,8(sp)
    80000ad6:	1000                	addi	s0,sp,32
    80000ad8:	84aa                	mv	s1,a0
  push_off();
    80000ada:	00000097          	auipc	ra,0x0
    80000ade:	f3c080e7          	jalr	-196(ra) # 80000a16 <push_off>
  r = (lk->locked && lk->cpu == mycpu());
    80000ae2:	409c                	lw	a5,0(s1)
    80000ae4:	ef81                	bnez	a5,80000afc <holding+0x2e>
    80000ae6:	4481                	li	s1,0
  pop_off();
    80000ae8:	00000097          	auipc	ra,0x0
    80000aec:	f7a080e7          	jalr	-134(ra) # 80000a62 <pop_off>
}
    80000af0:	8526                	mv	a0,s1
    80000af2:	60e2                	ld	ra,24(sp)
    80000af4:	6442                	ld	s0,16(sp)
    80000af6:	64a2                	ld	s1,8(sp)
    80000af8:	6105                	addi	sp,sp,32
    80000afa:	8082                	ret
  r = (lk->locked && lk->cpu == mycpu());
    80000afc:	6884                	ld	s1,16(s1)
    80000afe:	00001097          	auipc	ra,0x1
    80000b02:	f48080e7          	jalr	-184(ra) # 80001a46 <mycpu>
    80000b06:	8c89                	sub	s1,s1,a0
    80000b08:	0014b493          	seqz	s1,s1
    80000b0c:	bff1                	j	80000ae8 <holding+0x1a>

0000000080000b0e <acquire>:
{
    80000b0e:	1101                	addi	sp,sp,-32
    80000b10:	ec06                	sd	ra,24(sp)
    80000b12:	e822                	sd	s0,16(sp)
    80000b14:	e426                	sd	s1,8(sp)
    80000b16:	1000                	addi	s0,sp,32
    80000b18:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	efc080e7          	jalr	-260(ra) # 80000a16 <push_off>
  if(holding(lk))
    80000b22:	8526                	mv	a0,s1
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	faa080e7          	jalr	-86(ra) # 80000ace <holding>
    80000b2c:	e911                	bnez	a0,80000b40 <acquire+0x32>
  __sync_fetch_and_add(&(lk->n), 1);
    80000b2e:	4785                	li	a5,1
    80000b30:	01848713          	addi	a4,s1,24
    80000b34:	0f50000f          	fence	iorw,ow
    80000b38:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000b3c:	4705                	li	a4,1
    80000b3e:	a839                	j	80000b5c <acquire+0x4e>
    panic("acquire");
    80000b40:	00007517          	auipc	a0,0x7
    80000b44:	71850513          	addi	a0,a0,1816 # 80008258 <userret+0x1c8>
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	a00080e7          	jalr	-1536(ra) # 80000548 <panic>
     __sync_fetch_and_add(&lk->nts, 1);
    80000b50:	01c48793          	addi	a5,s1,28
    80000b54:	0f50000f          	fence	iorw,ow
    80000b58:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000b5c:	87ba                	mv	a5,a4
    80000b5e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b62:	2781                	sext.w	a5,a5
    80000b64:	f7f5                	bnez	a5,80000b50 <acquire+0x42>
  __sync_synchronize();
    80000b66:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b6a:	00001097          	auipc	ra,0x1
    80000b6e:	edc080e7          	jalr	-292(ra) # 80001a46 <mycpu>
    80000b72:	e888                	sd	a0,16(s1)
}
    80000b74:	60e2                	ld	ra,24(sp)
    80000b76:	6442                	ld	s0,16(sp)
    80000b78:	64a2                	ld	s1,8(sp)
    80000b7a:	6105                	addi	sp,sp,32
    80000b7c:	8082                	ret

0000000080000b7e <release>:
{
    80000b7e:	1101                	addi	sp,sp,-32
    80000b80:	ec06                	sd	ra,24(sp)
    80000b82:	e822                	sd	s0,16(sp)
    80000b84:	e426                	sd	s1,8(sp)
    80000b86:	1000                	addi	s0,sp,32
    80000b88:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000b8a:	00000097          	auipc	ra,0x0
    80000b8e:	f44080e7          	jalr	-188(ra) # 80000ace <holding>
    80000b92:	c115                	beqz	a0,80000bb6 <release+0x38>
  lk->cpu = 0;
    80000b94:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000b98:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000b9c:	0f50000f          	fence	iorw,ow
    80000ba0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000ba4:	00000097          	auipc	ra,0x0
    80000ba8:	ebe080e7          	jalr	-322(ra) # 80000a62 <pop_off>
}
    80000bac:	60e2                	ld	ra,24(sp)
    80000bae:	6442                	ld	s0,16(sp)
    80000bb0:	64a2                	ld	s1,8(sp)
    80000bb2:	6105                	addi	sp,sp,32
    80000bb4:	8082                	ret
    panic("release");
    80000bb6:	00007517          	auipc	a0,0x7
    80000bba:	6aa50513          	addi	a0,a0,1706 # 80008260 <userret+0x1d0>
    80000bbe:	00000097          	auipc	ra,0x0
    80000bc2:	98a080e7          	jalr	-1654(ra) # 80000548 <panic>

0000000080000bc6 <print_lock>:

void
print_lock(struct spinlock *lk)
{
  if(lk->n > 0) 
    80000bc6:	4d14                	lw	a3,24(a0)
    80000bc8:	e291                	bnez	a3,80000bcc <print_lock+0x6>
    80000bca:	8082                	ret
{
    80000bcc:	1141                	addi	sp,sp,-16
    80000bce:	e406                	sd	ra,8(sp)
    80000bd0:	e022                	sd	s0,0(sp)
    80000bd2:	0800                	addi	s0,sp,16
    printf("lock: %s: #fetch-and-add %d #acquire() %d\n", lk->name, lk->nts, lk->n);
    80000bd4:	4d50                	lw	a2,28(a0)
    80000bd6:	650c                	ld	a1,8(a0)
    80000bd8:	00007517          	auipc	a0,0x7
    80000bdc:	69050513          	addi	a0,a0,1680 # 80008268 <userret+0x1d8>
    80000be0:	00000097          	auipc	ra,0x0
    80000be4:	9c2080e7          	jalr	-1598(ra) # 800005a2 <printf>
}
    80000be8:	60a2                	ld	ra,8(sp)
    80000bea:	6402                	ld	s0,0(sp)
    80000bec:	0141                	addi	sp,sp,16
    80000bee:	8082                	ret

0000000080000bf0 <sys_ntas>:

uint64
sys_ntas(void)
{
    80000bf0:	711d                	addi	sp,sp,-96
    80000bf2:	ec86                	sd	ra,88(sp)
    80000bf4:	e8a2                	sd	s0,80(sp)
    80000bf6:	e4a6                	sd	s1,72(sp)
    80000bf8:	e0ca                	sd	s2,64(sp)
    80000bfa:	fc4e                	sd	s3,56(sp)
    80000bfc:	f852                	sd	s4,48(sp)
    80000bfe:	f456                	sd	s5,40(sp)
    80000c00:	f05a                	sd	s6,32(sp)
    80000c02:	ec5e                	sd	s7,24(sp)
    80000c04:	e862                	sd	s8,16(sp)
    80000c06:	1080                	addi	s0,sp,96
  int zero = 0;
    80000c08:	fa042623          	sw	zero,-84(s0)
  int tot = 0;
  
  if (argint(0, &zero) < 0) {
    80000c0c:	fac40593          	addi	a1,s0,-84
    80000c10:	4501                	li	a0,0
    80000c12:	00002097          	auipc	ra,0x2
    80000c16:	f0a080e7          	jalr	-246(ra) # 80002b1c <argint>
    80000c1a:	14054b63          	bltz	a0,80000d70 <sys_ntas+0x180>
    return -1;
  }
  if(zero == 0) {
    80000c1e:	fac42783          	lw	a5,-84(s0)
    80000c22:	e39d                	bnez	a5,80000c48 <sys_ntas+0x58>
    80000c24:	00012797          	auipc	a5,0x12
    80000c28:	cdc78793          	addi	a5,a5,-804 # 80012900 <locks>
    80000c2c:	00014697          	auipc	a3,0x14
    80000c30:	c1468693          	addi	a3,a3,-1004 # 80014840 <pid_lock>
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    80000c34:	6398                	ld	a4,0(a5)
    80000c36:	12070f63          	beqz	a4,80000d74 <sys_ntas+0x184>
        break;
      locks[i]->nts = 0;
    80000c3a:	00072e23          	sw	zero,28(a4)
    for(int i = 0; i < NLOCK; i++) {
    80000c3e:	07a1                	addi	a5,a5,8
    80000c40:	fed79ae3          	bne	a5,a3,80000c34 <sys_ntas+0x44>
    }
    return 0;
    80000c44:	4501                	li	a0,0
    80000c46:	aa09                	j	80000d58 <sys_ntas+0x168>
  }

  printf("=== lock kmem/bcache stats\n");
    80000c48:	00007517          	auipc	a0,0x7
    80000c4c:	65050513          	addi	a0,a0,1616 # 80008298 <userret+0x208>
    80000c50:	00000097          	auipc	ra,0x0
    80000c54:	952080e7          	jalr	-1710(ra) # 800005a2 <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000c58:	00012b17          	auipc	s6,0x12
    80000c5c:	ca8b0b13          	addi	s6,s6,-856 # 80012900 <locks>
    80000c60:	00014b97          	auipc	s7,0x14
    80000c64:	be0b8b93          	addi	s7,s7,-1056 # 80014840 <pid_lock>
  printf("=== lock kmem/bcache stats\n");
    80000c68:	84da                	mv	s1,s6
  int tot = 0;
    80000c6a:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000c6c:	00007a17          	auipc	s4,0x7
    80000c70:	64ca0a13          	addi	s4,s4,1612 # 800082b8 <userret+0x228>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000c74:	00007c17          	auipc	s8,0x7
    80000c78:	5acc0c13          	addi	s8,s8,1452 # 80008220 <userret+0x190>
    80000c7c:	a829                	j	80000c96 <sys_ntas+0xa6>
      tot += locks[i]->nts;
    80000c7e:	00093503          	ld	a0,0(s2)
    80000c82:	4d5c                	lw	a5,28(a0)
    80000c84:	013789bb          	addw	s3,a5,s3
      print_lock(locks[i]);
    80000c88:	00000097          	auipc	ra,0x0
    80000c8c:	f3e080e7          	jalr	-194(ra) # 80000bc6 <print_lock>
  for(int i = 0; i < NLOCK; i++) {
    80000c90:	04a1                	addi	s1,s1,8
    80000c92:	05748763          	beq	s1,s7,80000ce0 <sys_ntas+0xf0>
    if(locks[i] == 0)
    80000c96:	8926                	mv	s2,s1
    80000c98:	609c                	ld	a5,0(s1)
    80000c9a:	c3b9                	beqz	a5,80000ce0 <sys_ntas+0xf0>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000c9c:	0087ba83          	ld	s5,8(a5)
    80000ca0:	8552                	mv	a0,s4
    80000ca2:	00000097          	auipc	ra,0x0
    80000ca6:	25a080e7          	jalr	602(ra) # 80000efc <strlen>
    80000caa:	0005061b          	sext.w	a2,a0
    80000cae:	85d2                	mv	a1,s4
    80000cb0:	8556                	mv	a0,s5
    80000cb2:	00000097          	auipc	ra,0x0
    80000cb6:	19e080e7          	jalr	414(ra) # 80000e50 <strncmp>
    80000cba:	d171                	beqz	a0,80000c7e <sys_ntas+0x8e>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000cbc:	609c                	ld	a5,0(s1)
    80000cbe:	0087ba83          	ld	s5,8(a5)
    80000cc2:	8562                	mv	a0,s8
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	238080e7          	jalr	568(ra) # 80000efc <strlen>
    80000ccc:	0005061b          	sext.w	a2,a0
    80000cd0:	85e2                	mv	a1,s8
    80000cd2:	8556                	mv	a0,s5
    80000cd4:	00000097          	auipc	ra,0x0
    80000cd8:	17c080e7          	jalr	380(ra) # 80000e50 <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000cdc:	f955                	bnez	a0,80000c90 <sys_ntas+0xa0>
    80000cde:	b745                	j	80000c7e <sys_ntas+0x8e>
    }
  }

  printf("=== top 5 contended locks:\n");
    80000ce0:	00007517          	auipc	a0,0x7
    80000ce4:	5e050513          	addi	a0,a0,1504 # 800082c0 <userret+0x230>
    80000ce8:	00000097          	auipc	ra,0x0
    80000cec:	8ba080e7          	jalr	-1862(ra) # 800005a2 <printf>
    80000cf0:	4a15                	li	s4,5
  int last = 100000000;
    80000cf2:	05f5e537          	lui	a0,0x5f5e
    80000cf6:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t= 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    80000cfa:	4a81                	li	s5,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000cfc:	00012497          	auipc	s1,0x12
    80000d00:	c0448493          	addi	s1,s1,-1020 # 80012900 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80000d04:	3e800913          	li	s2,1000
    80000d08:	a091                	j	80000d4c <sys_ntas+0x15c>
    80000d0a:	2705                	addiw	a4,a4,1
    80000d0c:	06a1                	addi	a3,a3,8
    80000d0e:	03270063          	beq	a4,s2,80000d2e <sys_ntas+0x13e>
      if(locks[i] == 0)
    80000d12:	629c                	ld	a5,0(a3)
    80000d14:	cf89                	beqz	a5,80000d2e <sys_ntas+0x13e>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000d16:	4fd0                	lw	a2,28(a5)
    80000d18:	00359793          	slli	a5,a1,0x3
    80000d1c:	97a6                	add	a5,a5,s1
    80000d1e:	639c                	ld	a5,0(a5)
    80000d20:	4fdc                	lw	a5,28(a5)
    80000d22:	fec7f4e3          	bgeu	a5,a2,80000d0a <sys_ntas+0x11a>
    80000d26:	fea672e3          	bgeu	a2,a0,80000d0a <sys_ntas+0x11a>
    80000d2a:	85ba                	mv	a1,a4
    80000d2c:	bff9                	j	80000d0a <sys_ntas+0x11a>
        top = i;
      }
    }
    print_lock(locks[top]);
    80000d2e:	058e                	slli	a1,a1,0x3
    80000d30:	00b48bb3          	add	s7,s1,a1
    80000d34:	000bb503          	ld	a0,0(s7)
    80000d38:	00000097          	auipc	ra,0x0
    80000d3c:	e8e080e7          	jalr	-370(ra) # 80000bc6 <print_lock>
    last = locks[top]->nts;
    80000d40:	000bb783          	ld	a5,0(s7)
    80000d44:	4fc8                	lw	a0,28(a5)
  for(int t= 0; t < 5; t++) {
    80000d46:	3a7d                	addiw	s4,s4,-1
    80000d48:	000a0763          	beqz	s4,80000d56 <sys_ntas+0x166>
  int tot = 0;
    80000d4c:	86da                	mv	a3,s6
    for(int i = 0; i < NLOCK; i++) {
    80000d4e:	8756                	mv	a4,s5
    int top = 0;
    80000d50:	85d6                	mv	a1,s5
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000d52:	2501                	sext.w	a0,a0
    80000d54:	bf7d                	j	80000d12 <sys_ntas+0x122>
  }
  return tot;
    80000d56:	854e                	mv	a0,s3
}
    80000d58:	60e6                	ld	ra,88(sp)
    80000d5a:	6446                	ld	s0,80(sp)
    80000d5c:	64a6                	ld	s1,72(sp)
    80000d5e:	6906                	ld	s2,64(sp)
    80000d60:	79e2                	ld	s3,56(sp)
    80000d62:	7a42                	ld	s4,48(sp)
    80000d64:	7aa2                	ld	s5,40(sp)
    80000d66:	7b02                	ld	s6,32(sp)
    80000d68:	6be2                	ld	s7,24(sp)
    80000d6a:	6c42                	ld	s8,16(sp)
    80000d6c:	6125                	addi	sp,sp,96
    80000d6e:	8082                	ret
    return -1;
    80000d70:	557d                	li	a0,-1
    80000d72:	b7dd                	j	80000d58 <sys_ntas+0x168>
    return 0;
    80000d74:	4501                	li	a0,0
    80000d76:	b7cd                	j	80000d58 <sys_ntas+0x168>

0000000080000d78 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d78:	1141                	addi	sp,sp,-16
    80000d7a:	e422                	sd	s0,8(sp)
    80000d7c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d7e:	ca19                	beqz	a2,80000d94 <memset+0x1c>
    80000d80:	87aa                	mv	a5,a0
    80000d82:	1602                	slli	a2,a2,0x20
    80000d84:	9201                	srli	a2,a2,0x20
    80000d86:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d8a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d8e:	0785                	addi	a5,a5,1
    80000d90:	fee79de3          	bne	a5,a4,80000d8a <memset+0x12>
  }
  return dst;
}
    80000d94:	6422                	ld	s0,8(sp)
    80000d96:	0141                	addi	sp,sp,16
    80000d98:	8082                	ret

0000000080000d9a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d9a:	1141                	addi	sp,sp,-16
    80000d9c:	e422                	sd	s0,8(sp)
    80000d9e:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000da0:	ca05                	beqz	a2,80000dd0 <memcmp+0x36>
    80000da2:	fff6069b          	addiw	a3,a2,-1
    80000da6:	1682                	slli	a3,a3,0x20
    80000da8:	9281                	srli	a3,a3,0x20
    80000daa:	0685                	addi	a3,a3,1
    80000dac:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000dae:	00054783          	lbu	a5,0(a0)
    80000db2:	0005c703          	lbu	a4,0(a1)
    80000db6:	00e79863          	bne	a5,a4,80000dc6 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dbe:	fed518e3          	bne	a0,a3,80000dae <memcmp+0x14>
  }

  return 0;
    80000dc2:	4501                	li	a0,0
    80000dc4:	a019                	j	80000dca <memcmp+0x30>
      return *s1 - *s2;
    80000dc6:	40e7853b          	subw	a0,a5,a4
}
    80000dca:	6422                	ld	s0,8(sp)
    80000dcc:	0141                	addi	sp,sp,16
    80000dce:	8082                	ret
  return 0;
    80000dd0:	4501                	li	a0,0
    80000dd2:	bfe5                	j	80000dca <memcmp+0x30>

0000000080000dd4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dd4:	1141                	addi	sp,sp,-16
    80000dd6:	e422                	sd	s0,8(sp)
    80000dd8:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dda:	02a5e563          	bltu	a1,a0,80000e04 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dde:	fff6069b          	addiw	a3,a2,-1
    80000de2:	ce11                	beqz	a2,80000dfe <memmove+0x2a>
    80000de4:	1682                	slli	a3,a3,0x20
    80000de6:	9281                	srli	a3,a3,0x20
    80000de8:	0685                	addi	a3,a3,1
    80000dea:	96ae                	add	a3,a3,a1
    80000dec:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000dee:	0585                	addi	a1,a1,1
    80000df0:	0785                	addi	a5,a5,1
    80000df2:	fff5c703          	lbu	a4,-1(a1)
    80000df6:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000dfa:	fed59ae3          	bne	a1,a3,80000dee <memmove+0x1a>

  return dst;
}
    80000dfe:	6422                	ld	s0,8(sp)
    80000e00:	0141                	addi	sp,sp,16
    80000e02:	8082                	ret
  if(s < d && s + n > d){
    80000e04:	02061713          	slli	a4,a2,0x20
    80000e08:	9301                	srli	a4,a4,0x20
    80000e0a:	00e587b3          	add	a5,a1,a4
    80000e0e:	fcf578e3          	bgeu	a0,a5,80000dde <memmove+0xa>
    d += n;
    80000e12:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e14:	fff6069b          	addiw	a3,a2,-1
    80000e18:	d27d                	beqz	a2,80000dfe <memmove+0x2a>
    80000e1a:	02069613          	slli	a2,a3,0x20
    80000e1e:	9201                	srli	a2,a2,0x20
    80000e20:	fff64613          	not	a2,a2
    80000e24:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e26:	17fd                	addi	a5,a5,-1
    80000e28:	177d                	addi	a4,a4,-1
    80000e2a:	0007c683          	lbu	a3,0(a5)
    80000e2e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e32:	fef61ae3          	bne	a2,a5,80000e26 <memmove+0x52>
    80000e36:	b7e1                	j	80000dfe <memmove+0x2a>

0000000080000e38 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e406                	sd	ra,8(sp)
    80000e3c:	e022                	sd	s0,0(sp)
    80000e3e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e40:	00000097          	auipc	ra,0x0
    80000e44:	f94080e7          	jalr	-108(ra) # 80000dd4 <memmove>
}
    80000e48:	60a2                	ld	ra,8(sp)
    80000e4a:	6402                	ld	s0,0(sp)
    80000e4c:	0141                	addi	sp,sp,16
    80000e4e:	8082                	ret

0000000080000e50 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e50:	1141                	addi	sp,sp,-16
    80000e52:	e422                	sd	s0,8(sp)
    80000e54:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e56:	ce11                	beqz	a2,80000e72 <strncmp+0x22>
    80000e58:	00054783          	lbu	a5,0(a0)
    80000e5c:	cf89                	beqz	a5,80000e76 <strncmp+0x26>
    80000e5e:	0005c703          	lbu	a4,0(a1)
    80000e62:	00f71a63          	bne	a4,a5,80000e76 <strncmp+0x26>
    n--, p++, q++;
    80000e66:	367d                	addiw	a2,a2,-1
    80000e68:	0505                	addi	a0,a0,1
    80000e6a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e6c:	f675                	bnez	a2,80000e58 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e6e:	4501                	li	a0,0
    80000e70:	a809                	j	80000e82 <strncmp+0x32>
    80000e72:	4501                	li	a0,0
    80000e74:	a039                	j	80000e82 <strncmp+0x32>
  if(n == 0)
    80000e76:	ca09                	beqz	a2,80000e88 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e78:	00054503          	lbu	a0,0(a0)
    80000e7c:	0005c783          	lbu	a5,0(a1)
    80000e80:	9d1d                	subw	a0,a0,a5
}
    80000e82:	6422                	ld	s0,8(sp)
    80000e84:	0141                	addi	sp,sp,16
    80000e86:	8082                	ret
    return 0;
    80000e88:	4501                	li	a0,0
    80000e8a:	bfe5                	j	80000e82 <strncmp+0x32>

0000000080000e8c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e8c:	1141                	addi	sp,sp,-16
    80000e8e:	e422                	sd	s0,8(sp)
    80000e90:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e92:	872a                	mv	a4,a0
    80000e94:	8832                	mv	a6,a2
    80000e96:	367d                	addiw	a2,a2,-1
    80000e98:	01005963          	blez	a6,80000eaa <strncpy+0x1e>
    80000e9c:	0705                	addi	a4,a4,1
    80000e9e:	0005c783          	lbu	a5,0(a1)
    80000ea2:	fef70fa3          	sb	a5,-1(a4)
    80000ea6:	0585                	addi	a1,a1,1
    80000ea8:	f7f5                	bnez	a5,80000e94 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000eaa:	86ba                	mv	a3,a4
    80000eac:	00c05c63          	blez	a2,80000ec4 <strncpy+0x38>
    *s++ = 0;
    80000eb0:	0685                	addi	a3,a3,1
    80000eb2:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000eb6:	fff6c793          	not	a5,a3
    80000eba:	9fb9                	addw	a5,a5,a4
    80000ebc:	010787bb          	addw	a5,a5,a6
    80000ec0:	fef048e3          	bgtz	a5,80000eb0 <strncpy+0x24>
  return os;
}
    80000ec4:	6422                	ld	s0,8(sp)
    80000ec6:	0141                	addi	sp,sp,16
    80000ec8:	8082                	ret

0000000080000eca <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000eca:	1141                	addi	sp,sp,-16
    80000ecc:	e422                	sd	s0,8(sp)
    80000ece:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ed0:	02c05363          	blez	a2,80000ef6 <safestrcpy+0x2c>
    80000ed4:	fff6069b          	addiw	a3,a2,-1
    80000ed8:	1682                	slli	a3,a3,0x20
    80000eda:	9281                	srli	a3,a3,0x20
    80000edc:	96ae                	add	a3,a3,a1
    80000ede:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ee0:	00d58963          	beq	a1,a3,80000ef2 <safestrcpy+0x28>
    80000ee4:	0585                	addi	a1,a1,1
    80000ee6:	0785                	addi	a5,a5,1
    80000ee8:	fff5c703          	lbu	a4,-1(a1)
    80000eec:	fee78fa3          	sb	a4,-1(a5)
    80000ef0:	fb65                	bnez	a4,80000ee0 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ef2:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ef6:	6422                	ld	s0,8(sp)
    80000ef8:	0141                	addi	sp,sp,16
    80000efa:	8082                	ret

0000000080000efc <strlen>:

int
strlen(const char *s)
{
    80000efc:	1141                	addi	sp,sp,-16
    80000efe:	e422                	sd	s0,8(sp)
    80000f00:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f02:	00054783          	lbu	a5,0(a0)
    80000f06:	cf91                	beqz	a5,80000f22 <strlen+0x26>
    80000f08:	0505                	addi	a0,a0,1
    80000f0a:	87aa                	mv	a5,a0
    80000f0c:	4685                	li	a3,1
    80000f0e:	9e89                	subw	a3,a3,a0
    80000f10:	00f6853b          	addw	a0,a3,a5
    80000f14:	0785                	addi	a5,a5,1
    80000f16:	fff7c703          	lbu	a4,-1(a5)
    80000f1a:	fb7d                	bnez	a4,80000f10 <strlen+0x14>
    ;
  return n;
}
    80000f1c:	6422                	ld	s0,8(sp)
    80000f1e:	0141                	addi	sp,sp,16
    80000f20:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f22:	4501                	li	a0,0
    80000f24:	bfe5                	j	80000f1c <strlen+0x20>

0000000080000f26 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f26:	1141                	addi	sp,sp,-16
    80000f28:	e406                	sd	ra,8(sp)
    80000f2a:	e022                	sd	s0,0(sp)
    80000f2c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	b08080e7          	jalr	-1272(ra) # 80001a36 <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f36:	00030717          	auipc	a4,0x30
    80000f3a:	0f270713          	addi	a4,a4,242 # 80031028 <started>
  if(cpuid() == 0){
    80000f3e:	c139                	beqz	a0,80000f84 <main+0x5e>
    while(started == 0)
    80000f40:	431c                	lw	a5,0(a4)
    80000f42:	2781                	sext.w	a5,a5
    80000f44:	dff5                	beqz	a5,80000f40 <main+0x1a>
      ;
    __sync_synchronize();
    80000f46:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	aec080e7          	jalr	-1300(ra) # 80001a36 <cpuid>
    80000f52:	85aa                	mv	a1,a0
    80000f54:	00007517          	auipc	a0,0x7
    80000f58:	3a450513          	addi	a0,a0,932 # 800082f8 <userret+0x268>
    80000f5c:	fffff097          	auipc	ra,0xfffff
    80000f60:	646080e7          	jalr	1606(ra) # 800005a2 <printf>
    kvminithart();    // turn on paging
    80000f64:	00000097          	auipc	ra,0x0
    80000f68:	1ea080e7          	jalr	490(ra) # 8000114e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f6c:	00001097          	auipc	ra,0x1
    80000f70:	720080e7          	jalr	1824(ra) # 8000268c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f74:	00005097          	auipc	ra,0x5
    80000f78:	04c080e7          	jalr	76(ra) # 80005fc0 <plicinithart>
  }

  scheduler();        
    80000f7c:	00001097          	auipc	ra,0x1
    80000f80:	fd2080e7          	jalr	-46(ra) # 80001f4e <scheduler>
    consoleinit();
    80000f84:	fffff097          	auipc	ra,0xfffff
    80000f88:	4d6080e7          	jalr	1238(ra) # 8000045a <consoleinit>
    printfinit();
    80000f8c:	fffff097          	auipc	ra,0xfffff
    80000f90:	7f6080e7          	jalr	2038(ra) # 80000782 <printfinit>
    printf("\n");
    80000f94:	00007517          	auipc	a0,0x7
    80000f98:	37450513          	addi	a0,a0,884 # 80008308 <userret+0x278>
    80000f9c:	fffff097          	auipc	ra,0xfffff
    80000fa0:	606080e7          	jalr	1542(ra) # 800005a2 <printf>
    printf("xv6 kernel is booting\n");
    80000fa4:	00007517          	auipc	a0,0x7
    80000fa8:	33c50513          	addi	a0,a0,828 # 800082e0 <userret+0x250>
    80000fac:	fffff097          	auipc	ra,0xfffff
    80000fb0:	5f6080e7          	jalr	1526(ra) # 800005a2 <printf>
    printf("\n");
    80000fb4:	00007517          	auipc	a0,0x7
    80000fb8:	35450513          	addi	a0,a0,852 # 80008308 <userret+0x278>
    80000fbc:	fffff097          	auipc	ra,0xfffff
    80000fc0:	5e6080e7          	jalr	1510(ra) # 800005a2 <printf>
    kinit();         // physical page allocator
    80000fc4:	00000097          	auipc	ra,0x0
    80000fc8:	960080e7          	jalr	-1696(ra) # 80000924 <kinit>
    kvminit();       // create kernel page table
    80000fcc:	00000097          	auipc	ra,0x0
    80000fd0:	30c080e7          	jalr	780(ra) # 800012d8 <kvminit>
    kvminithart();   // turn on paging
    80000fd4:	00000097          	auipc	ra,0x0
    80000fd8:	17a080e7          	jalr	378(ra) # 8000114e <kvminithart>
    procinit();      // process table
    80000fdc:	00001097          	auipc	ra,0x1
    80000fe0:	98a080e7          	jalr	-1654(ra) # 80001966 <procinit>
    trapinit();      // trap vectors
    80000fe4:	00001097          	auipc	ra,0x1
    80000fe8:	680080e7          	jalr	1664(ra) # 80002664 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fec:	00001097          	auipc	ra,0x1
    80000ff0:	6a0080e7          	jalr	1696(ra) # 8000268c <trapinithart>
    plicinit();      // set up interrupt controller
    80000ff4:	00005097          	auipc	ra,0x5
    80000ff8:	fb6080e7          	jalr	-74(ra) # 80005faa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ffc:	00005097          	auipc	ra,0x5
    80001000:	fc4080e7          	jalr	-60(ra) # 80005fc0 <plicinithart>
    binit();         // buffer cache
    80001004:	00002097          	auipc	ra,0x2
    80001008:	df8080e7          	jalr	-520(ra) # 80002dfc <binit>
    iinit();         // inode cache
    8000100c:	00002097          	auipc	ra,0x2
    80001010:	48c080e7          	jalr	1164(ra) # 80003498 <iinit>
    fileinit();      // file table
    80001014:	00003097          	auipc	ra,0x3
    80001018:	666080e7          	jalr	1638(ra) # 8000467a <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    8000101c:	4501                	li	a0,0
    8000101e:	00005097          	auipc	ra,0x5
    80001022:	0c4080e7          	jalr	196(ra) # 800060e2 <virtio_disk_init>
    userinit();      // first user process
    80001026:	00001097          	auipc	ra,0x1
    8000102a:	cbe080e7          	jalr	-834(ra) # 80001ce4 <userinit>
    __sync_synchronize();
    8000102e:	0ff0000f          	fence
    started = 1;
    80001032:	4785                	li	a5,1
    80001034:	00030717          	auipc	a4,0x30
    80001038:	fef72a23          	sw	a5,-12(a4) # 80031028 <started>
    8000103c:	b781                	j	80000f7c <main+0x56>

000000008000103e <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000103e:	7139                	addi	sp,sp,-64
    80001040:	fc06                	sd	ra,56(sp)
    80001042:	f822                	sd	s0,48(sp)
    80001044:	f426                	sd	s1,40(sp)
    80001046:	f04a                	sd	s2,32(sp)
    80001048:	ec4e                	sd	s3,24(sp)
    8000104a:	e852                	sd	s4,16(sp)
    8000104c:	e456                	sd	s5,8(sp)
    8000104e:	e05a                	sd	s6,0(sp)
    80001050:	0080                	addi	s0,sp,64
    80001052:	84aa                	mv	s1,a0
    80001054:	89ae                	mv	s3,a1
    80001056:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001058:	57fd                	li	a5,-1
    8000105a:	83e9                	srli	a5,a5,0x1a
    8000105c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000105e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001060:	04b7f263          	bgeu	a5,a1,800010a4 <walk+0x66>
    panic("walk");
    80001064:	00007517          	auipc	a0,0x7
    80001068:	2ac50513          	addi	a0,a0,684 # 80008310 <userret+0x280>
    8000106c:	fffff097          	auipc	ra,0xfffff
    80001070:	4dc080e7          	jalr	1244(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001074:	060a8663          	beqz	s5,800010e0 <walk+0xa2>
    80001078:	00000097          	auipc	ra,0x0
    8000107c:	8e8080e7          	jalr	-1816(ra) # 80000960 <kalloc>
    80001080:	84aa                	mv	s1,a0
    80001082:	c529                	beqz	a0,800010cc <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001084:	6605                	lui	a2,0x1
    80001086:	4581                	li	a1,0
    80001088:	00000097          	auipc	ra,0x0
    8000108c:	cf0080e7          	jalr	-784(ra) # 80000d78 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001090:	00c4d793          	srli	a5,s1,0xc
    80001094:	07aa                	slli	a5,a5,0xa
    80001096:	0017e793          	ori	a5,a5,1
    8000109a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000109e:	3a5d                	addiw	s4,s4,-9
    800010a0:	036a0063          	beq	s4,s6,800010c0 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010a4:	0149d933          	srl	s2,s3,s4
    800010a8:	1ff97913          	andi	s2,s2,511
    800010ac:	090e                	slli	s2,s2,0x3
    800010ae:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010b0:	00093483          	ld	s1,0(s2)
    800010b4:	0014f793          	andi	a5,s1,1
    800010b8:	dfd5                	beqz	a5,80001074 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010ba:	80a9                	srli	s1,s1,0xa
    800010bc:	04b2                	slli	s1,s1,0xc
    800010be:	b7c5                	j	8000109e <walk+0x60>
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
    800010e2:	b7ed                	j	800010cc <walk+0x8e>

00000000800010e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    800010e4:	7179                	addi	sp,sp,-48
    800010e6:	f406                	sd	ra,40(sp)
    800010e8:	f022                	sd	s0,32(sp)
    800010ea:	ec26                	sd	s1,24(sp)
    800010ec:	e84a                	sd	s2,16(sp)
    800010ee:	e44e                	sd	s3,8(sp)
    800010f0:	e052                	sd	s4,0(sp)
    800010f2:	1800                	addi	s0,sp,48
    800010f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800010f6:	84aa                	mv	s1,a0
    800010f8:	6905                	lui	s2,0x1
    800010fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800010fc:	4985                	li	s3,1
    800010fe:	a821                	j	80001116 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001100:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001102:	0532                	slli	a0,a0,0xc
    80001104:	00000097          	auipc	ra,0x0
    80001108:	fe0080e7          	jalr	-32(ra) # 800010e4 <freewalk>
      pagetable[i] = 0;
    8000110c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001110:	04a1                	addi	s1,s1,8
    80001112:	03248163          	beq	s1,s2,80001134 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001116:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001118:	00f57793          	andi	a5,a0,15
    8000111c:	ff3782e3          	beq	a5,s3,80001100 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001120:	8905                	andi	a0,a0,1
    80001122:	d57d                	beqz	a0,80001110 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001124:	00007517          	auipc	a0,0x7
    80001128:	1f450513          	addi	a0,a0,500 # 80008318 <userret+0x288>
    8000112c:	fffff097          	auipc	ra,0xfffff
    80001130:	41c080e7          	jalr	1052(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    80001134:	8552                	mv	a0,s4
    80001136:	fffff097          	auipc	ra,0xfffff
    8000113a:	72e080e7          	jalr	1838(ra) # 80000864 <kfree>
}
    8000113e:	70a2                	ld	ra,40(sp)
    80001140:	7402                	ld	s0,32(sp)
    80001142:	64e2                	ld	s1,24(sp)
    80001144:	6942                	ld	s2,16(sp)
    80001146:	69a2                	ld	s3,8(sp)
    80001148:	6a02                	ld	s4,0(sp)
    8000114a:	6145                	addi	sp,sp,48
    8000114c:	8082                	ret

000000008000114e <kvminithart>:
{
    8000114e:	1141                	addi	sp,sp,-16
    80001150:	e422                	sd	s0,8(sp)
    80001152:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001154:	00030797          	auipc	a5,0x30
    80001158:	edc7b783          	ld	a5,-292(a5) # 80031030 <kernel_pagetable>
    8000115c:	83b1                	srli	a5,a5,0xc
    8000115e:	577d                	li	a4,-1
    80001160:	177e                	slli	a4,a4,0x3f
    80001162:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001164:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001168:	12000073          	sfence.vma
}
    8000116c:	6422                	ld	s0,8(sp)
    8000116e:	0141                	addi	sp,sp,16
    80001170:	8082                	ret

0000000080001172 <walkaddr>:
  if(va >= MAXVA)
    80001172:	57fd                	li	a5,-1
    80001174:	83e9                	srli	a5,a5,0x1a
    80001176:	00b7f463          	bgeu	a5,a1,8000117e <walkaddr+0xc>
    return 0;
    8000117a:	4501                	li	a0,0
}
    8000117c:	8082                	ret
{
    8000117e:	1141                	addi	sp,sp,-16
    80001180:	e406                	sd	ra,8(sp)
    80001182:	e022                	sd	s0,0(sp)
    80001184:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001186:	4601                	li	a2,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	eb6080e7          	jalr	-330(ra) # 8000103e <walk>
  if(pte == 0)
    80001190:	c105                	beqz	a0,800011b0 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001192:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001194:	0117f693          	andi	a3,a5,17
    80001198:	4745                	li	a4,17
    return 0;
    8000119a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000119c:	00e68663          	beq	a3,a4,800011a8 <walkaddr+0x36>
}
    800011a0:	60a2                	ld	ra,8(sp)
    800011a2:	6402                	ld	s0,0(sp)
    800011a4:	0141                	addi	sp,sp,16
    800011a6:	8082                	ret
  pa = PTE2PA(*pte);
    800011a8:	00a7d513          	srli	a0,a5,0xa
    800011ac:	0532                	slli	a0,a0,0xc
  return pa;
    800011ae:	bfcd                	j	800011a0 <walkaddr+0x2e>
    return 0;
    800011b0:	4501                	li	a0,0
    800011b2:	b7fd                	j	800011a0 <walkaddr+0x2e>

00000000800011b4 <kvmpa>:
{
    800011b4:	1101                	addi	sp,sp,-32
    800011b6:	ec06                	sd	ra,24(sp)
    800011b8:	e822                	sd	s0,16(sp)
    800011ba:	e426                	sd	s1,8(sp)
    800011bc:	1000                	addi	s0,sp,32
    800011be:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800011c0:	1552                	slli	a0,a0,0x34
    800011c2:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    800011c6:	4601                	li	a2,0
    800011c8:	00030517          	auipc	a0,0x30
    800011cc:	e6853503          	ld	a0,-408(a0) # 80031030 <kernel_pagetable>
    800011d0:	00000097          	auipc	ra,0x0
    800011d4:	e6e080e7          	jalr	-402(ra) # 8000103e <walk>
  if(pte == 0)
    800011d8:	cd09                	beqz	a0,800011f2 <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    800011da:	6108                	ld	a0,0(a0)
    800011dc:	00157793          	andi	a5,a0,1
    800011e0:	c38d                	beqz	a5,80001202 <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    800011e2:	8129                	srli	a0,a0,0xa
    800011e4:	0532                	slli	a0,a0,0xc
}
    800011e6:	9526                	add	a0,a0,s1
    800011e8:	60e2                	ld	ra,24(sp)
    800011ea:	6442                	ld	s0,16(sp)
    800011ec:	64a2                	ld	s1,8(sp)
    800011ee:	6105                	addi	sp,sp,32
    800011f0:	8082                	ret
    panic("kvmpa");
    800011f2:	00007517          	auipc	a0,0x7
    800011f6:	13650513          	addi	a0,a0,310 # 80008328 <userret+0x298>
    800011fa:	fffff097          	auipc	ra,0xfffff
    800011fe:	34e080e7          	jalr	846(ra) # 80000548 <panic>
    panic("kvmpa");
    80001202:	00007517          	auipc	a0,0x7
    80001206:	12650513          	addi	a0,a0,294 # 80008328 <userret+0x298>
    8000120a:	fffff097          	auipc	ra,0xfffff
    8000120e:	33e080e7          	jalr	830(ra) # 80000548 <panic>

0000000080001212 <mappages>:
{
    80001212:	715d                	addi	sp,sp,-80
    80001214:	e486                	sd	ra,72(sp)
    80001216:	e0a2                	sd	s0,64(sp)
    80001218:	fc26                	sd	s1,56(sp)
    8000121a:	f84a                	sd	s2,48(sp)
    8000121c:	f44e                	sd	s3,40(sp)
    8000121e:	f052                	sd	s4,32(sp)
    80001220:	ec56                	sd	s5,24(sp)
    80001222:	e85a                	sd	s6,16(sp)
    80001224:	e45e                	sd	s7,8(sp)
    80001226:	0880                	addi	s0,sp,80
    80001228:	8aaa                	mv	s5,a0
    8000122a:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    8000122c:	777d                	lui	a4,0xfffff
    8000122e:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001232:	167d                	addi	a2,a2,-1
    80001234:	00b609b3          	add	s3,a2,a1
    80001238:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000123c:	893e                	mv	s2,a5
    8000123e:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    80001242:	6b85                	lui	s7,0x1
    80001244:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001248:	4605                	li	a2,1
    8000124a:	85ca                	mv	a1,s2
    8000124c:	8556                	mv	a0,s5
    8000124e:	00000097          	auipc	ra,0x0
    80001252:	df0080e7          	jalr	-528(ra) # 8000103e <walk>
    80001256:	c51d                	beqz	a0,80001284 <mappages+0x72>
    if(*pte & PTE_V)
    80001258:	611c                	ld	a5,0(a0)
    8000125a:	8b85                	andi	a5,a5,1
    8000125c:	ef81                	bnez	a5,80001274 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000125e:	80b1                	srli	s1,s1,0xc
    80001260:	04aa                	slli	s1,s1,0xa
    80001262:	0164e4b3          	or	s1,s1,s6
    80001266:	0014e493          	ori	s1,s1,1
    8000126a:	e104                	sd	s1,0(a0)
    if(a == last)
    8000126c:	03390863          	beq	s2,s3,8000129c <mappages+0x8a>
    a += PGSIZE;
    80001270:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001272:	bfc9                	j	80001244 <mappages+0x32>
      panic("remap");
    80001274:	00007517          	auipc	a0,0x7
    80001278:	0bc50513          	addi	a0,a0,188 # 80008330 <userret+0x2a0>
    8000127c:	fffff097          	auipc	ra,0xfffff
    80001280:	2cc080e7          	jalr	716(ra) # 80000548 <panic>
      return -1;
    80001284:	557d                	li	a0,-1
}
    80001286:	60a6                	ld	ra,72(sp)
    80001288:	6406                	ld	s0,64(sp)
    8000128a:	74e2                	ld	s1,56(sp)
    8000128c:	7942                	ld	s2,48(sp)
    8000128e:	79a2                	ld	s3,40(sp)
    80001290:	7a02                	ld	s4,32(sp)
    80001292:	6ae2                	ld	s5,24(sp)
    80001294:	6b42                	ld	s6,16(sp)
    80001296:	6ba2                	ld	s7,8(sp)
    80001298:	6161                	addi	sp,sp,80
    8000129a:	8082                	ret
  return 0;
    8000129c:	4501                	li	a0,0
    8000129e:	b7e5                	j	80001286 <mappages+0x74>

00000000800012a0 <kvmmap>:
{
    800012a0:	1141                	addi	sp,sp,-16
    800012a2:	e406                	sd	ra,8(sp)
    800012a4:	e022                	sd	s0,0(sp)
    800012a6:	0800                	addi	s0,sp,16
    800012a8:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800012aa:	86ae                	mv	a3,a1
    800012ac:	85aa                	mv	a1,a0
    800012ae:	00030517          	auipc	a0,0x30
    800012b2:	d8253503          	ld	a0,-638(a0) # 80031030 <kernel_pagetable>
    800012b6:	00000097          	auipc	ra,0x0
    800012ba:	f5c080e7          	jalr	-164(ra) # 80001212 <mappages>
    800012be:	e509                	bnez	a0,800012c8 <kvmmap+0x28>
}
    800012c0:	60a2                	ld	ra,8(sp)
    800012c2:	6402                	ld	s0,0(sp)
    800012c4:	0141                	addi	sp,sp,16
    800012c6:	8082                	ret
    panic("kvmmap");
    800012c8:	00007517          	auipc	a0,0x7
    800012cc:	07050513          	addi	a0,a0,112 # 80008338 <userret+0x2a8>
    800012d0:	fffff097          	auipc	ra,0xfffff
    800012d4:	278080e7          	jalr	632(ra) # 80000548 <panic>

00000000800012d8 <kvminit>:
{
    800012d8:	1101                	addi	sp,sp,-32
    800012da:	ec06                	sd	ra,24(sp)
    800012dc:	e822                	sd	s0,16(sp)
    800012de:	e426                	sd	s1,8(sp)
    800012e0:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	67e080e7          	jalr	1662(ra) # 80000960 <kalloc>
    800012ea:	00030797          	auipc	a5,0x30
    800012ee:	d4a7b323          	sd	a0,-698(a5) # 80031030 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800012f2:	6605                	lui	a2,0x1
    800012f4:	4581                	li	a1,0
    800012f6:	00000097          	auipc	ra,0x0
    800012fa:	a82080e7          	jalr	-1406(ra) # 80000d78 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012fe:	4699                	li	a3,6
    80001300:	6605                	lui	a2,0x1
    80001302:	100005b7          	lui	a1,0x10000
    80001306:	10000537          	lui	a0,0x10000
    8000130a:	00000097          	auipc	ra,0x0
    8000130e:	f96080e7          	jalr	-106(ra) # 800012a0 <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    80001312:	4699                	li	a3,6
    80001314:	6605                	lui	a2,0x1
    80001316:	100015b7          	lui	a1,0x10001
    8000131a:	10001537          	lui	a0,0x10001
    8000131e:	00000097          	auipc	ra,0x0
    80001322:	f82080e7          	jalr	-126(ra) # 800012a0 <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    80001326:	4699                	li	a3,6
    80001328:	6605                	lui	a2,0x1
    8000132a:	100025b7          	lui	a1,0x10002
    8000132e:	10002537          	lui	a0,0x10002
    80001332:	00000097          	auipc	ra,0x0
    80001336:	f6e080e7          	jalr	-146(ra) # 800012a0 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000133a:	4699                	li	a3,6
    8000133c:	6641                	lui	a2,0x10
    8000133e:	020005b7          	lui	a1,0x2000
    80001342:	02000537          	lui	a0,0x2000
    80001346:	00000097          	auipc	ra,0x0
    8000134a:	f5a080e7          	jalr	-166(ra) # 800012a0 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000134e:	4699                	li	a3,6
    80001350:	00400637          	lui	a2,0x400
    80001354:	0c0005b7          	lui	a1,0xc000
    80001358:	0c000537          	lui	a0,0xc000
    8000135c:	00000097          	auipc	ra,0x0
    80001360:	f44080e7          	jalr	-188(ra) # 800012a0 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001364:	00008497          	auipc	s1,0x8
    80001368:	c9c48493          	addi	s1,s1,-868 # 80009000 <initcode>
    8000136c:	46a9                	li	a3,10
    8000136e:	80008617          	auipc	a2,0x80008
    80001372:	c9260613          	addi	a2,a2,-878 # 9000 <_entry-0x7fff7000>
    80001376:	4585                	li	a1,1
    80001378:	05fe                	slli	a1,a1,0x1f
    8000137a:	852e                	mv	a0,a1
    8000137c:	00000097          	auipc	ra,0x0
    80001380:	f24080e7          	jalr	-220(ra) # 800012a0 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001384:	4699                	li	a3,6
    80001386:	4645                	li	a2,17
    80001388:	066e                	slli	a2,a2,0x1b
    8000138a:	8e05                	sub	a2,a2,s1
    8000138c:	85a6                	mv	a1,s1
    8000138e:	8526                	mv	a0,s1
    80001390:	00000097          	auipc	ra,0x0
    80001394:	f10080e7          	jalr	-240(ra) # 800012a0 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001398:	46a9                	li	a3,10
    8000139a:	6605                	lui	a2,0x1
    8000139c:	00007597          	auipc	a1,0x7
    800013a0:	c6458593          	addi	a1,a1,-924 # 80008000 <trampoline>
    800013a4:	04000537          	lui	a0,0x4000
    800013a8:	157d                	addi	a0,a0,-1
    800013aa:	0532                	slli	a0,a0,0xc
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	ef4080e7          	jalr	-268(ra) # 800012a0 <kvmmap>
}
    800013b4:	60e2                	ld	ra,24(sp)
    800013b6:	6442                	ld	s0,16(sp)
    800013b8:	64a2                	ld	s1,8(sp)
    800013ba:	6105                	addi	sp,sp,32
    800013bc:	8082                	ret

00000000800013be <uvmunmap>:
{
    800013be:	715d                	addi	sp,sp,-80
    800013c0:	e486                	sd	ra,72(sp)
    800013c2:	e0a2                	sd	s0,64(sp)
    800013c4:	fc26                	sd	s1,56(sp)
    800013c6:	f84a                	sd	s2,48(sp)
    800013c8:	f44e                	sd	s3,40(sp)
    800013ca:	f052                	sd	s4,32(sp)
    800013cc:	ec56                	sd	s5,24(sp)
    800013ce:	e85a                	sd	s6,16(sp)
    800013d0:	e45e                	sd	s7,8(sp)
    800013d2:	0880                	addi	s0,sp,80
    800013d4:	8a2a                	mv	s4,a0
    800013d6:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    800013d8:	77fd                	lui	a5,0xfffff
    800013da:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800013de:	167d                	addi	a2,a2,-1
    800013e0:	00b609b3          	add	s3,a2,a1
    800013e4:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    800013e8:	4b05                	li	s6,1
    a += PGSIZE;
    800013ea:	6b85                	lui	s7,0x1
    800013ec:	a0b9                	j	8000143a <uvmunmap+0x7c>
      panic("uvmunmap: walk");
    800013ee:	00007517          	auipc	a0,0x7
    800013f2:	f5250513          	addi	a0,a0,-174 # 80008340 <userret+0x2b0>
    800013f6:	fffff097          	auipc	ra,0xfffff
    800013fa:	152080e7          	jalr	338(ra) # 80000548 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800013fe:	85ca                	mv	a1,s2
    80001400:	00007517          	auipc	a0,0x7
    80001404:	f5050513          	addi	a0,a0,-176 # 80008350 <userret+0x2c0>
    80001408:	fffff097          	auipc	ra,0xfffff
    8000140c:	19a080e7          	jalr	410(ra) # 800005a2 <printf>
      panic("uvmunmap: not mapped");
    80001410:	00007517          	auipc	a0,0x7
    80001414:	f5050513          	addi	a0,a0,-176 # 80008360 <userret+0x2d0>
    80001418:	fffff097          	auipc	ra,0xfffff
    8000141c:	130080e7          	jalr	304(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    80001420:	00007517          	auipc	a0,0x7
    80001424:	f5850513          	addi	a0,a0,-168 # 80008378 <userret+0x2e8>
    80001428:	fffff097          	auipc	ra,0xfffff
    8000142c:	120080e7          	jalr	288(ra) # 80000548 <panic>
    *pte = 0;
    80001430:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001434:	03390e63          	beq	s2,s3,80001470 <uvmunmap+0xb2>
    a += PGSIZE;
    80001438:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    8000143a:	4601                	li	a2,0
    8000143c:	85ca                	mv	a1,s2
    8000143e:	8552                	mv	a0,s4
    80001440:	00000097          	auipc	ra,0x0
    80001444:	bfe080e7          	jalr	-1026(ra) # 8000103e <walk>
    80001448:	84aa                	mv	s1,a0
    8000144a:	d155                	beqz	a0,800013ee <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    8000144c:	6110                	ld	a2,0(a0)
    8000144e:	00167793          	andi	a5,a2,1
    80001452:	d7d5                	beqz	a5,800013fe <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001454:	3ff67793          	andi	a5,a2,1023
    80001458:	fd6784e3          	beq	a5,s6,80001420 <uvmunmap+0x62>
    if(do_free){
    8000145c:	fc0a8ae3          	beqz	s5,80001430 <uvmunmap+0x72>
      pa = PTE2PA(*pte);
    80001460:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    80001462:	00c61513          	slli	a0,a2,0xc
    80001466:	fffff097          	auipc	ra,0xfffff
    8000146a:	3fe080e7          	jalr	1022(ra) # 80000864 <kfree>
    8000146e:	b7c9                	j	80001430 <uvmunmap+0x72>
}
    80001470:	60a6                	ld	ra,72(sp)
    80001472:	6406                	ld	s0,64(sp)
    80001474:	74e2                	ld	s1,56(sp)
    80001476:	7942                	ld	s2,48(sp)
    80001478:	79a2                	ld	s3,40(sp)
    8000147a:	7a02                	ld	s4,32(sp)
    8000147c:	6ae2                	ld	s5,24(sp)
    8000147e:	6b42                	ld	s6,16(sp)
    80001480:	6ba2                	ld	s7,8(sp)
    80001482:	6161                	addi	sp,sp,80
    80001484:	8082                	ret

0000000080001486 <uvmcreate>:
{
    80001486:	1101                	addi	sp,sp,-32
    80001488:	ec06                	sd	ra,24(sp)
    8000148a:	e822                	sd	s0,16(sp)
    8000148c:	e426                	sd	s1,8(sp)
    8000148e:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    80001490:	fffff097          	auipc	ra,0xfffff
    80001494:	4d0080e7          	jalr	1232(ra) # 80000960 <kalloc>
  if(pagetable == 0)
    80001498:	cd11                	beqz	a0,800014b4 <uvmcreate+0x2e>
    8000149a:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    8000149c:	6605                	lui	a2,0x1
    8000149e:	4581                	li	a1,0
    800014a0:	00000097          	auipc	ra,0x0
    800014a4:	8d8080e7          	jalr	-1832(ra) # 80000d78 <memset>
}
    800014a8:	8526                	mv	a0,s1
    800014aa:	60e2                	ld	ra,24(sp)
    800014ac:	6442                	ld	s0,16(sp)
    800014ae:	64a2                	ld	s1,8(sp)
    800014b0:	6105                	addi	sp,sp,32
    800014b2:	8082                	ret
    panic("uvmcreate: out of memory");
    800014b4:	00007517          	auipc	a0,0x7
    800014b8:	edc50513          	addi	a0,a0,-292 # 80008390 <userret+0x300>
    800014bc:	fffff097          	auipc	ra,0xfffff
    800014c0:	08c080e7          	jalr	140(ra) # 80000548 <panic>

00000000800014c4 <uvminit>:
{
    800014c4:	7179                	addi	sp,sp,-48
    800014c6:	f406                	sd	ra,40(sp)
    800014c8:	f022                	sd	s0,32(sp)
    800014ca:	ec26                	sd	s1,24(sp)
    800014cc:	e84a                	sd	s2,16(sp)
    800014ce:	e44e                	sd	s3,8(sp)
    800014d0:	e052                	sd	s4,0(sp)
    800014d2:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    800014d4:	6785                	lui	a5,0x1
    800014d6:	04f67863          	bgeu	a2,a5,80001526 <uvminit+0x62>
    800014da:	8a2a                	mv	s4,a0
    800014dc:	89ae                	mv	s3,a1
    800014de:	84b2                	mv	s1,a2
  mem = kalloc();
    800014e0:	fffff097          	auipc	ra,0xfffff
    800014e4:	480080e7          	jalr	1152(ra) # 80000960 <kalloc>
    800014e8:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014ea:	6605                	lui	a2,0x1
    800014ec:	4581                	li	a1,0
    800014ee:	00000097          	auipc	ra,0x0
    800014f2:	88a080e7          	jalr	-1910(ra) # 80000d78 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014f6:	4779                	li	a4,30
    800014f8:	86ca                	mv	a3,s2
    800014fa:	6605                	lui	a2,0x1
    800014fc:	4581                	li	a1,0
    800014fe:	8552                	mv	a0,s4
    80001500:	00000097          	auipc	ra,0x0
    80001504:	d12080e7          	jalr	-750(ra) # 80001212 <mappages>
  memmove(mem, src, sz);
    80001508:	8626                	mv	a2,s1
    8000150a:	85ce                	mv	a1,s3
    8000150c:	854a                	mv	a0,s2
    8000150e:	00000097          	auipc	ra,0x0
    80001512:	8c6080e7          	jalr	-1850(ra) # 80000dd4 <memmove>
}
    80001516:	70a2                	ld	ra,40(sp)
    80001518:	7402                	ld	s0,32(sp)
    8000151a:	64e2                	ld	s1,24(sp)
    8000151c:	6942                	ld	s2,16(sp)
    8000151e:	69a2                	ld	s3,8(sp)
    80001520:	6a02                	ld	s4,0(sp)
    80001522:	6145                	addi	sp,sp,48
    80001524:	8082                	ret
    panic("inituvm: more than a page");
    80001526:	00007517          	auipc	a0,0x7
    8000152a:	e8a50513          	addi	a0,a0,-374 # 800083b0 <userret+0x320>
    8000152e:	fffff097          	auipc	ra,0xfffff
    80001532:	01a080e7          	jalr	26(ra) # 80000548 <panic>

0000000080001536 <uvmdealloc>:
{
    80001536:	1101                	addi	sp,sp,-32
    80001538:	ec06                	sd	ra,24(sp)
    8000153a:	e822                	sd	s0,16(sp)
    8000153c:	e426                	sd	s1,8(sp)
    8000153e:	1000                	addi	s0,sp,32
    return oldsz;
    80001540:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001542:	00b67d63          	bgeu	a2,a1,8000155c <uvmdealloc+0x26>
    80001546:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    80001548:	6785                	lui	a5,0x1
    8000154a:	17fd                	addi	a5,a5,-1
    8000154c:	00f60733          	add	a4,a2,a5
    80001550:	76fd                	lui	a3,0xfffff
    80001552:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    80001554:	97ae                	add	a5,a5,a1
    80001556:	8ff5                	and	a5,a5,a3
    80001558:	00f76863          	bltu	a4,a5,80001568 <uvmdealloc+0x32>
}
    8000155c:	8526                	mv	a0,s1
    8000155e:	60e2                	ld	ra,24(sp)
    80001560:	6442                	ld	s0,16(sp)
    80001562:	64a2                	ld	s1,8(sp)
    80001564:	6105                	addi	sp,sp,32
    80001566:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    80001568:	4685                	li	a3,1
    8000156a:	40e58633          	sub	a2,a1,a4
    8000156e:	85ba                	mv	a1,a4
    80001570:	00000097          	auipc	ra,0x0
    80001574:	e4e080e7          	jalr	-434(ra) # 800013be <uvmunmap>
    80001578:	b7d5                	j	8000155c <uvmdealloc+0x26>

000000008000157a <uvmalloc>:
  if(newsz < oldsz)
    8000157a:	0ab66163          	bltu	a2,a1,8000161c <uvmalloc+0xa2>
{
    8000157e:	7139                	addi	sp,sp,-64
    80001580:	fc06                	sd	ra,56(sp)
    80001582:	f822                	sd	s0,48(sp)
    80001584:	f426                	sd	s1,40(sp)
    80001586:	f04a                	sd	s2,32(sp)
    80001588:	ec4e                	sd	s3,24(sp)
    8000158a:	e852                	sd	s4,16(sp)
    8000158c:	e456                	sd	s5,8(sp)
    8000158e:	0080                	addi	s0,sp,64
    80001590:	8aaa                	mv	s5,a0
    80001592:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001594:	6985                	lui	s3,0x1
    80001596:	19fd                	addi	s3,s3,-1
    80001598:	95ce                	add	a1,a1,s3
    8000159a:	79fd                	lui	s3,0xfffff
    8000159c:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    800015a0:	08c9f063          	bgeu	s3,a2,80001620 <uvmalloc+0xa6>
  a = oldsz;
    800015a4:	894e                	mv	s2,s3
    mem = kalloc();
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	3ba080e7          	jalr	954(ra) # 80000960 <kalloc>
    800015ae:	84aa                	mv	s1,a0
    if(mem == 0){
    800015b0:	c51d                	beqz	a0,800015de <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	4581                	li	a1,0
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	7c2080e7          	jalr	1986(ra) # 80000d78 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800015be:	4779                	li	a4,30
    800015c0:	86a6                	mv	a3,s1
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85ca                	mv	a1,s2
    800015c6:	8556                	mv	a0,s5
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	c4a080e7          	jalr	-950(ra) # 80001212 <mappages>
    800015d0:	e905                	bnez	a0,80001600 <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	993e                	add	s2,s2,a5
    800015d6:	fd4968e3          	bltu	s2,s4,800015a6 <uvmalloc+0x2c>
  return newsz;
    800015da:	8552                	mv	a0,s4
    800015dc:	a809                	j	800015ee <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800015de:	864e                	mv	a2,s3
    800015e0:	85ca                	mv	a1,s2
    800015e2:	8556                	mv	a0,s5
    800015e4:	00000097          	auipc	ra,0x0
    800015e8:	f52080e7          	jalr	-174(ra) # 80001536 <uvmdealloc>
      return 0;
    800015ec:	4501                	li	a0,0
}
    800015ee:	70e2                	ld	ra,56(sp)
    800015f0:	7442                	ld	s0,48(sp)
    800015f2:	74a2                	ld	s1,40(sp)
    800015f4:	7902                	ld	s2,32(sp)
    800015f6:	69e2                	ld	s3,24(sp)
    800015f8:	6a42                	ld	s4,16(sp)
    800015fa:	6aa2                	ld	s5,8(sp)
    800015fc:	6121                	addi	sp,sp,64
    800015fe:	8082                	ret
      kfree(mem);
    80001600:	8526                	mv	a0,s1
    80001602:	fffff097          	auipc	ra,0xfffff
    80001606:	262080e7          	jalr	610(ra) # 80000864 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000160a:	864e                	mv	a2,s3
    8000160c:	85ca                	mv	a1,s2
    8000160e:	8556                	mv	a0,s5
    80001610:	00000097          	auipc	ra,0x0
    80001614:	f26080e7          	jalr	-218(ra) # 80001536 <uvmdealloc>
      return 0;
    80001618:	4501                	li	a0,0
    8000161a:	bfd1                	j	800015ee <uvmalloc+0x74>
    return oldsz;
    8000161c:	852e                	mv	a0,a1
}
    8000161e:	8082                	ret
  return newsz;
    80001620:	8532                	mv	a0,a2
    80001622:	b7f1                	j	800015ee <uvmalloc+0x74>

0000000080001624 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001624:	1101                	addi	sp,sp,-32
    80001626:	ec06                	sd	ra,24(sp)
    80001628:	e822                	sd	s0,16(sp)
    8000162a:	e426                	sd	s1,8(sp)
    8000162c:	1000                	addi	s0,sp,32
    8000162e:	84aa                	mv	s1,a0
    80001630:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001632:	4685                	li	a3,1
    80001634:	4581                	li	a1,0
    80001636:	00000097          	auipc	ra,0x0
    8000163a:	d88080e7          	jalr	-632(ra) # 800013be <uvmunmap>
  freewalk(pagetable);
    8000163e:	8526                	mv	a0,s1
    80001640:	00000097          	auipc	ra,0x0
    80001644:	aa4080e7          	jalr	-1372(ra) # 800010e4 <freewalk>
}
    80001648:	60e2                	ld	ra,24(sp)
    8000164a:	6442                	ld	s0,16(sp)
    8000164c:	64a2                	ld	s1,8(sp)
    8000164e:	6105                	addi	sp,sp,32
    80001650:	8082                	ret

0000000080001652 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001652:	c671                	beqz	a2,8000171e <uvmcopy+0xcc>
{
    80001654:	715d                	addi	sp,sp,-80
    80001656:	e486                	sd	ra,72(sp)
    80001658:	e0a2                	sd	s0,64(sp)
    8000165a:	fc26                	sd	s1,56(sp)
    8000165c:	f84a                	sd	s2,48(sp)
    8000165e:	f44e                	sd	s3,40(sp)
    80001660:	f052                	sd	s4,32(sp)
    80001662:	ec56                	sd	s5,24(sp)
    80001664:	e85a                	sd	s6,16(sp)
    80001666:	e45e                	sd	s7,8(sp)
    80001668:	0880                	addi	s0,sp,80
    8000166a:	8b2a                	mv	s6,a0
    8000166c:	8aae                	mv	s5,a1
    8000166e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001670:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001672:	4601                	li	a2,0
    80001674:	85ce                	mv	a1,s3
    80001676:	855a                	mv	a0,s6
    80001678:	00000097          	auipc	ra,0x0
    8000167c:	9c6080e7          	jalr	-1594(ra) # 8000103e <walk>
    80001680:	c531                	beqz	a0,800016cc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001682:	6118                	ld	a4,0(a0)
    80001684:	00177793          	andi	a5,a4,1
    80001688:	cbb1                	beqz	a5,800016dc <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000168a:	00a75593          	srli	a1,a4,0xa
    8000168e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001692:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001696:	fffff097          	auipc	ra,0xfffff
    8000169a:	2ca080e7          	jalr	714(ra) # 80000960 <kalloc>
    8000169e:	892a                	mv	s2,a0
    800016a0:	c939                	beqz	a0,800016f6 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016a2:	6605                	lui	a2,0x1
    800016a4:	85de                	mv	a1,s7
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	72e080e7          	jalr	1838(ra) # 80000dd4 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016ae:	8726                	mv	a4,s1
    800016b0:	86ca                	mv	a3,s2
    800016b2:	6605                	lui	a2,0x1
    800016b4:	85ce                	mv	a1,s3
    800016b6:	8556                	mv	a0,s5
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	b5a080e7          	jalr	-1190(ra) # 80001212 <mappages>
    800016c0:	e515                	bnez	a0,800016ec <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800016c2:	6785                	lui	a5,0x1
    800016c4:	99be                	add	s3,s3,a5
    800016c6:	fb49e6e3          	bltu	s3,s4,80001672 <uvmcopy+0x20>
    800016ca:	a83d                	j	80001708 <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    800016cc:	00007517          	auipc	a0,0x7
    800016d0:	d0450513          	addi	a0,a0,-764 # 800083d0 <userret+0x340>
    800016d4:	fffff097          	auipc	ra,0xfffff
    800016d8:	e74080e7          	jalr	-396(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    800016dc:	00007517          	auipc	a0,0x7
    800016e0:	d1450513          	addi	a0,a0,-748 # 800083f0 <userret+0x360>
    800016e4:	fffff097          	auipc	ra,0xfffff
    800016e8:	e64080e7          	jalr	-412(ra) # 80000548 <panic>
      kfree(mem);
    800016ec:	854a                	mv	a0,s2
    800016ee:	fffff097          	auipc	ra,0xfffff
    800016f2:	176080e7          	jalr	374(ra) # 80000864 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800016f6:	4685                	li	a3,1
    800016f8:	864e                	mv	a2,s3
    800016fa:	4581                	li	a1,0
    800016fc:	8556                	mv	a0,s5
    800016fe:	00000097          	auipc	ra,0x0
    80001702:	cc0080e7          	jalr	-832(ra) # 800013be <uvmunmap>
  return -1;
    80001706:	557d                	li	a0,-1
}
    80001708:	60a6                	ld	ra,72(sp)
    8000170a:	6406                	ld	s0,64(sp)
    8000170c:	74e2                	ld	s1,56(sp)
    8000170e:	7942                	ld	s2,48(sp)
    80001710:	79a2                	ld	s3,40(sp)
    80001712:	7a02                	ld	s4,32(sp)
    80001714:	6ae2                	ld	s5,24(sp)
    80001716:	6b42                	ld	s6,16(sp)
    80001718:	6ba2                	ld	s7,8(sp)
    8000171a:	6161                	addi	sp,sp,80
    8000171c:	8082                	ret
  return 0;
    8000171e:	4501                	li	a0,0
}
    80001720:	8082                	ret

0000000080001722 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001722:	1141                	addi	sp,sp,-16
    80001724:	e406                	sd	ra,8(sp)
    80001726:	e022                	sd	s0,0(sp)
    80001728:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000172a:	4601                	li	a2,0
    8000172c:	00000097          	auipc	ra,0x0
    80001730:	912080e7          	jalr	-1774(ra) # 8000103e <walk>
  if(pte == 0)
    80001734:	c901                	beqz	a0,80001744 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001736:	611c                	ld	a5,0(a0)
    80001738:	9bbd                	andi	a5,a5,-17
    8000173a:	e11c                	sd	a5,0(a0)
}
    8000173c:	60a2                	ld	ra,8(sp)
    8000173e:	6402                	ld	s0,0(sp)
    80001740:	0141                	addi	sp,sp,16
    80001742:	8082                	ret
    panic("uvmclear");
    80001744:	00007517          	auipc	a0,0x7
    80001748:	ccc50513          	addi	a0,a0,-820 # 80008410 <userret+0x380>
    8000174c:	fffff097          	auipc	ra,0xfffff
    80001750:	dfc080e7          	jalr	-516(ra) # 80000548 <panic>

0000000080001754 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001754:	c6bd                	beqz	a3,800017c2 <copyout+0x6e>
{
    80001756:	715d                	addi	sp,sp,-80
    80001758:	e486                	sd	ra,72(sp)
    8000175a:	e0a2                	sd	s0,64(sp)
    8000175c:	fc26                	sd	s1,56(sp)
    8000175e:	f84a                	sd	s2,48(sp)
    80001760:	f44e                	sd	s3,40(sp)
    80001762:	f052                	sd	s4,32(sp)
    80001764:	ec56                	sd	s5,24(sp)
    80001766:	e85a                	sd	s6,16(sp)
    80001768:	e45e                	sd	s7,8(sp)
    8000176a:	e062                	sd	s8,0(sp)
    8000176c:	0880                	addi	s0,sp,80
    8000176e:	8b2a                	mv	s6,a0
    80001770:	8c2e                	mv	s8,a1
    80001772:	8a32                	mv	s4,a2
    80001774:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001776:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001778:	6a85                	lui	s5,0x1
    8000177a:	a015                	j	8000179e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000177c:	9562                	add	a0,a0,s8
    8000177e:	0004861b          	sext.w	a2,s1
    80001782:	85d2                	mv	a1,s4
    80001784:	41250533          	sub	a0,a0,s2
    80001788:	fffff097          	auipc	ra,0xfffff
    8000178c:	64c080e7          	jalr	1612(ra) # 80000dd4 <memmove>

    len -= n;
    80001790:	409989b3          	sub	s3,s3,s1
    src += n;
    80001794:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001796:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000179a:	02098263          	beqz	s3,800017be <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000179e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017a2:	85ca                	mv	a1,s2
    800017a4:	855a                	mv	a0,s6
    800017a6:	00000097          	auipc	ra,0x0
    800017aa:	9cc080e7          	jalr	-1588(ra) # 80001172 <walkaddr>
    if(pa0 == 0)
    800017ae:	cd01                	beqz	a0,800017c6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800017b0:	418904b3          	sub	s1,s2,s8
    800017b4:	94d6                	add	s1,s1,s5
    if(n > len)
    800017b6:	fc99f3e3          	bgeu	s3,s1,8000177c <copyout+0x28>
    800017ba:	84ce                	mv	s1,s3
    800017bc:	b7c1                	j	8000177c <copyout+0x28>
  }
  return 0;
    800017be:	4501                	li	a0,0
    800017c0:	a021                	j	800017c8 <copyout+0x74>
    800017c2:	4501                	li	a0,0
}
    800017c4:	8082                	ret
      return -1;
    800017c6:	557d                	li	a0,-1
}
    800017c8:	60a6                	ld	ra,72(sp)
    800017ca:	6406                	ld	s0,64(sp)
    800017cc:	74e2                	ld	s1,56(sp)
    800017ce:	7942                	ld	s2,48(sp)
    800017d0:	79a2                	ld	s3,40(sp)
    800017d2:	7a02                	ld	s4,32(sp)
    800017d4:	6ae2                	ld	s5,24(sp)
    800017d6:	6b42                	ld	s6,16(sp)
    800017d8:	6ba2                	ld	s7,8(sp)
    800017da:	6c02                	ld	s8,0(sp)
    800017dc:	6161                	addi	sp,sp,80
    800017de:	8082                	ret

00000000800017e0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017e0:	caa5                	beqz	a3,80001850 <copyin+0x70>
{
    800017e2:	715d                	addi	sp,sp,-80
    800017e4:	e486                	sd	ra,72(sp)
    800017e6:	e0a2                	sd	s0,64(sp)
    800017e8:	fc26                	sd	s1,56(sp)
    800017ea:	f84a                	sd	s2,48(sp)
    800017ec:	f44e                	sd	s3,40(sp)
    800017ee:	f052                	sd	s4,32(sp)
    800017f0:	ec56                	sd	s5,24(sp)
    800017f2:	e85a                	sd	s6,16(sp)
    800017f4:	e45e                	sd	s7,8(sp)
    800017f6:	e062                	sd	s8,0(sp)
    800017f8:	0880                	addi	s0,sp,80
    800017fa:	8b2a                	mv	s6,a0
    800017fc:	8a2e                	mv	s4,a1
    800017fe:	8c32                	mv	s8,a2
    80001800:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001802:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001804:	6a85                	lui	s5,0x1
    80001806:	a01d                	j	8000182c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001808:	018505b3          	add	a1,a0,s8
    8000180c:	0004861b          	sext.w	a2,s1
    80001810:	412585b3          	sub	a1,a1,s2
    80001814:	8552                	mv	a0,s4
    80001816:	fffff097          	auipc	ra,0xfffff
    8000181a:	5be080e7          	jalr	1470(ra) # 80000dd4 <memmove>

    len -= n;
    8000181e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001822:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001824:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001828:	02098263          	beqz	s3,8000184c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000182c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001830:	85ca                	mv	a1,s2
    80001832:	855a                	mv	a0,s6
    80001834:	00000097          	auipc	ra,0x0
    80001838:	93e080e7          	jalr	-1730(ra) # 80001172 <walkaddr>
    if(pa0 == 0)
    8000183c:	cd01                	beqz	a0,80001854 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000183e:	418904b3          	sub	s1,s2,s8
    80001842:	94d6                	add	s1,s1,s5
    if(n > len)
    80001844:	fc99f2e3          	bgeu	s3,s1,80001808 <copyin+0x28>
    80001848:	84ce                	mv	s1,s3
    8000184a:	bf7d                	j	80001808 <copyin+0x28>
  }
  return 0;
    8000184c:	4501                	li	a0,0
    8000184e:	a021                	j	80001856 <copyin+0x76>
    80001850:	4501                	li	a0,0
}
    80001852:	8082                	ret
      return -1;
    80001854:	557d                	li	a0,-1
}
    80001856:	60a6                	ld	ra,72(sp)
    80001858:	6406                	ld	s0,64(sp)
    8000185a:	74e2                	ld	s1,56(sp)
    8000185c:	7942                	ld	s2,48(sp)
    8000185e:	79a2                	ld	s3,40(sp)
    80001860:	7a02                	ld	s4,32(sp)
    80001862:	6ae2                	ld	s5,24(sp)
    80001864:	6b42                	ld	s6,16(sp)
    80001866:	6ba2                	ld	s7,8(sp)
    80001868:	6c02                	ld	s8,0(sp)
    8000186a:	6161                	addi	sp,sp,80
    8000186c:	8082                	ret

000000008000186e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000186e:	c6c5                	beqz	a3,80001916 <copyinstr+0xa8>
{
    80001870:	715d                	addi	sp,sp,-80
    80001872:	e486                	sd	ra,72(sp)
    80001874:	e0a2                	sd	s0,64(sp)
    80001876:	fc26                	sd	s1,56(sp)
    80001878:	f84a                	sd	s2,48(sp)
    8000187a:	f44e                	sd	s3,40(sp)
    8000187c:	f052                	sd	s4,32(sp)
    8000187e:	ec56                	sd	s5,24(sp)
    80001880:	e85a                	sd	s6,16(sp)
    80001882:	e45e                	sd	s7,8(sp)
    80001884:	0880                	addi	s0,sp,80
    80001886:	8a2a                	mv	s4,a0
    80001888:	8b2e                	mv	s6,a1
    8000188a:	8bb2                	mv	s7,a2
    8000188c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000188e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001890:	6985                	lui	s3,0x1
    80001892:	a035                	j	800018be <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001894:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001898:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000189a:	0017b793          	seqz	a5,a5
    8000189e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800018a2:	60a6                	ld	ra,72(sp)
    800018a4:	6406                	ld	s0,64(sp)
    800018a6:	74e2                	ld	s1,56(sp)
    800018a8:	7942                	ld	s2,48(sp)
    800018aa:	79a2                	ld	s3,40(sp)
    800018ac:	7a02                	ld	s4,32(sp)
    800018ae:	6ae2                	ld	s5,24(sp)
    800018b0:	6b42                	ld	s6,16(sp)
    800018b2:	6ba2                	ld	s7,8(sp)
    800018b4:	6161                	addi	sp,sp,80
    800018b6:	8082                	ret
    srcva = va0 + PGSIZE;
    800018b8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800018bc:	c8a9                	beqz	s1,8000190e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800018be:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018c2:	85ca                	mv	a1,s2
    800018c4:	8552                	mv	a0,s4
    800018c6:	00000097          	auipc	ra,0x0
    800018ca:	8ac080e7          	jalr	-1876(ra) # 80001172 <walkaddr>
    if(pa0 == 0)
    800018ce:	c131                	beqz	a0,80001912 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800018d0:	41790833          	sub	a6,s2,s7
    800018d4:	984e                	add	a6,a6,s3
    if(n > max)
    800018d6:	0104f363          	bgeu	s1,a6,800018dc <copyinstr+0x6e>
    800018da:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018dc:	955e                	add	a0,a0,s7
    800018de:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018e2:	fc080be3          	beqz	a6,800018b8 <copyinstr+0x4a>
    800018e6:	985a                	add	a6,a6,s6
    800018e8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018ea:	41650633          	sub	a2,a0,s6
    800018ee:	14fd                	addi	s1,s1,-1
    800018f0:	9b26                	add	s6,s6,s1
    800018f2:	00f60733          	add	a4,a2,a5
    800018f6:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffcdfa4>
    800018fa:	df49                	beqz	a4,80001894 <copyinstr+0x26>
        *dst = *p;
    800018fc:	00e78023          	sb	a4,0(a5)
      --max;
    80001900:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001904:	0785                	addi	a5,a5,1
    while(n > 0){
    80001906:	ff0796e3          	bne	a5,a6,800018f2 <copyinstr+0x84>
      dst++;
    8000190a:	8b42                	mv	s6,a6
    8000190c:	b775                	j	800018b8 <copyinstr+0x4a>
    8000190e:	4781                	li	a5,0
    80001910:	b769                	j	8000189a <copyinstr+0x2c>
      return -1;
    80001912:	557d                	li	a0,-1
    80001914:	b779                	j	800018a2 <copyinstr+0x34>
  int got_null = 0;
    80001916:	4781                	li	a5,0
  if(got_null){
    80001918:	0017b793          	seqz	a5,a5
    8000191c:	40f00533          	neg	a0,a5
}
    80001920:	8082                	ret

0000000080001922 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001922:	1101                	addi	sp,sp,-32
    80001924:	ec06                	sd	ra,24(sp)
    80001926:	e822                	sd	s0,16(sp)
    80001928:	e426                	sd	s1,8(sp)
    8000192a:	1000                	addi	s0,sp,32
    8000192c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	1a0080e7          	jalr	416(ra) # 80000ace <holding>
    80001936:	c909                	beqz	a0,80001948 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001938:	789c                	ld	a5,48(s1)
    8000193a:	00978f63          	beq	a5,s1,80001958 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    8000193e:	60e2                	ld	ra,24(sp)
    80001940:	6442                	ld	s0,16(sp)
    80001942:	64a2                	ld	s1,8(sp)
    80001944:	6105                	addi	sp,sp,32
    80001946:	8082                	ret
    panic("wakeup1");
    80001948:	00007517          	auipc	a0,0x7
    8000194c:	ad850513          	addi	a0,a0,-1320 # 80008420 <userret+0x390>
    80001950:	fffff097          	auipc	ra,0xfffff
    80001954:	bf8080e7          	jalr	-1032(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001958:	5098                	lw	a4,32(s1)
    8000195a:	4785                	li	a5,1
    8000195c:	fef711e3          	bne	a4,a5,8000193e <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001960:	4789                	li	a5,2
    80001962:	d09c                	sw	a5,32(s1)
}
    80001964:	bfe9                	j	8000193e <wakeup1+0x1c>

0000000080001966 <procinit>:
{
    80001966:	715d                	addi	sp,sp,-80
    80001968:	e486                	sd	ra,72(sp)
    8000196a:	e0a2                	sd	s0,64(sp)
    8000196c:	fc26                	sd	s1,56(sp)
    8000196e:	f84a                	sd	s2,48(sp)
    80001970:	f44e                	sd	s3,40(sp)
    80001972:	f052                	sd	s4,32(sp)
    80001974:	ec56                	sd	s5,24(sp)
    80001976:	e85a                	sd	s6,16(sp)
    80001978:	e45e                	sd	s7,8(sp)
    8000197a:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    8000197c:	00007597          	auipc	a1,0x7
    80001980:	aac58593          	addi	a1,a1,-1364 # 80008428 <userret+0x398>
    80001984:	00013517          	auipc	a0,0x13
    80001988:	ebc50513          	addi	a0,a0,-324 # 80014840 <pid_lock>
    8000198c:	fffff097          	auipc	ra,0xfffff
    80001990:	034080e7          	jalr	52(ra) # 800009c0 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001994:	00013917          	auipc	s2,0x13
    80001998:	2cc90913          	addi	s2,s2,716 # 80014c60 <proc>
      initlock(&p->lock, "proc");
    8000199c:	00007b97          	auipc	s7,0x7
    800019a0:	a94b8b93          	addi	s7,s7,-1388 # 80008430 <userret+0x3a0>
      uint64 va = KSTACK((int) (p - proc));
    800019a4:	8b4a                	mv	s6,s2
    800019a6:	00007a97          	auipc	s5,0x7
    800019aa:	2d2a8a93          	addi	s5,s5,722 # 80008c78 <syscalls+0xe0>
    800019ae:	040009b7          	lui	s3,0x4000
    800019b2:	19fd                	addi	s3,s3,-1
    800019b4:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b6:	0001ea17          	auipc	s4,0x1e
    800019ba:	caaa0a13          	addi	s4,s4,-854 # 8001f660 <tickslock>
      initlock(&p->lock, "proc");
    800019be:	85de                	mv	a1,s7
    800019c0:	854a                	mv	a0,s2
    800019c2:	fffff097          	auipc	ra,0xfffff
    800019c6:	ffe080e7          	jalr	-2(ra) # 800009c0 <initlock>
      char *pa = kalloc();
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	f96080e7          	jalr	-106(ra) # 80000960 <kalloc>
    800019d2:	85aa                	mv	a1,a0
      if(pa == 0)
    800019d4:	c929                	beqz	a0,80001a26 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800019d6:	416904b3          	sub	s1,s2,s6
    800019da:	848d                	srai	s1,s1,0x3
    800019dc:	000ab783          	ld	a5,0(s5)
    800019e0:	02f484b3          	mul	s1,s1,a5
    800019e4:	2485                	addiw	s1,s1,1
    800019e6:	00d4949b          	slliw	s1,s1,0xd
    800019ea:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019ee:	4699                	li	a3,6
    800019f0:	6605                	lui	a2,0x1
    800019f2:	8526                	mv	a0,s1
    800019f4:	00000097          	auipc	ra,0x0
    800019f8:	8ac080e7          	jalr	-1876(ra) # 800012a0 <kvmmap>
      p->kstack = va;
    800019fc:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a00:	2a890913          	addi	s2,s2,680
    80001a04:	fb491de3          	bne	s2,s4,800019be <procinit+0x58>
  kvminithart();
    80001a08:	fffff097          	auipc	ra,0xfffff
    80001a0c:	746080e7          	jalr	1862(ra) # 8000114e <kvminithart>
}
    80001a10:	60a6                	ld	ra,72(sp)
    80001a12:	6406                	ld	s0,64(sp)
    80001a14:	74e2                	ld	s1,56(sp)
    80001a16:	7942                	ld	s2,48(sp)
    80001a18:	79a2                	ld	s3,40(sp)
    80001a1a:	7a02                	ld	s4,32(sp)
    80001a1c:	6ae2                	ld	s5,24(sp)
    80001a1e:	6b42                	ld	s6,16(sp)
    80001a20:	6ba2                	ld	s7,8(sp)
    80001a22:	6161                	addi	sp,sp,80
    80001a24:	8082                	ret
        panic("kalloc");
    80001a26:	00007517          	auipc	a0,0x7
    80001a2a:	a1250513          	addi	a0,a0,-1518 # 80008438 <userret+0x3a8>
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	b1a080e7          	jalr	-1254(ra) # 80000548 <panic>

0000000080001a36 <cpuid>:
{
    80001a36:	1141                	addi	sp,sp,-16
    80001a38:	e422                	sd	s0,8(sp)
    80001a3a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a3c:	8512                	mv	a0,tp
}
    80001a3e:	2501                	sext.w	a0,a0
    80001a40:	6422                	ld	s0,8(sp)
    80001a42:	0141                	addi	sp,sp,16
    80001a44:	8082                	ret

0000000080001a46 <mycpu>:
mycpu(void) {
    80001a46:	1141                	addi	sp,sp,-16
    80001a48:	e422                	sd	s0,8(sp)
    80001a4a:	0800                	addi	s0,sp,16
    80001a4c:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a4e:	2781                	sext.w	a5,a5
    80001a50:	079e                	slli	a5,a5,0x7
}
    80001a52:	00013517          	auipc	a0,0x13
    80001a56:	e0e50513          	addi	a0,a0,-498 # 80014860 <cpus>
    80001a5a:	953e                	add	a0,a0,a5
    80001a5c:	6422                	ld	s0,8(sp)
    80001a5e:	0141                	addi	sp,sp,16
    80001a60:	8082                	ret

0000000080001a62 <myproc>:
myproc(void) {
    80001a62:	1101                	addi	sp,sp,-32
    80001a64:	ec06                	sd	ra,24(sp)
    80001a66:	e822                	sd	s0,16(sp)
    80001a68:	e426                	sd	s1,8(sp)
    80001a6a:	1000                	addi	s0,sp,32
  push_off();
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	faa080e7          	jalr	-86(ra) # 80000a16 <push_off>
    80001a74:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a76:	2781                	sext.w	a5,a5
    80001a78:	079e                	slli	a5,a5,0x7
    80001a7a:	00013717          	auipc	a4,0x13
    80001a7e:	dc670713          	addi	a4,a4,-570 # 80014840 <pid_lock>
    80001a82:	97ba                	add	a5,a5,a4
    80001a84:	7384                	ld	s1,32(a5)
  pop_off();
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	fdc080e7          	jalr	-36(ra) # 80000a62 <pop_off>
}
    80001a8e:	8526                	mv	a0,s1
    80001a90:	60e2                	ld	ra,24(sp)
    80001a92:	6442                	ld	s0,16(sp)
    80001a94:	64a2                	ld	s1,8(sp)
    80001a96:	6105                	addi	sp,sp,32
    80001a98:	8082                	ret

0000000080001a9a <forkret>:
{
    80001a9a:	1141                	addi	sp,sp,-16
    80001a9c:	e406                	sd	ra,8(sp)
    80001a9e:	e022                	sd	s0,0(sp)
    80001aa0:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001aa2:	00000097          	auipc	ra,0x0
    80001aa6:	fc0080e7          	jalr	-64(ra) # 80001a62 <myproc>
    80001aaa:	fffff097          	auipc	ra,0xfffff
    80001aae:	0d4080e7          	jalr	212(ra) # 80000b7e <release>
  if (first) {
    80001ab2:	00007797          	auipc	a5,0x7
    80001ab6:	5827a783          	lw	a5,1410(a5) # 80009034 <first.1>
    80001aba:	eb89                	bnez	a5,80001acc <forkret+0x32>
  usertrapret();
    80001abc:	00001097          	auipc	ra,0x1
    80001ac0:	be8080e7          	jalr	-1048(ra) # 800026a4 <usertrapret>
}
    80001ac4:	60a2                	ld	ra,8(sp)
    80001ac6:	6402                	ld	s0,0(sp)
    80001ac8:	0141                	addi	sp,sp,16
    80001aca:	8082                	ret
    first = 0;
    80001acc:	00007797          	auipc	a5,0x7
    80001ad0:	5607a423          	sw	zero,1384(a5) # 80009034 <first.1>
    fsinit(minor(ROOTDEV));
    80001ad4:	4501                	li	a0,0
    80001ad6:	00002097          	auipc	ra,0x2
    80001ada:	942080e7          	jalr	-1726(ra) # 80003418 <fsinit>
    80001ade:	bff9                	j	80001abc <forkret+0x22>

0000000080001ae0 <allocpid>:
allocpid() {
    80001ae0:	1101                	addi	sp,sp,-32
    80001ae2:	ec06                	sd	ra,24(sp)
    80001ae4:	e822                	sd	s0,16(sp)
    80001ae6:	e426                	sd	s1,8(sp)
    80001ae8:	e04a                	sd	s2,0(sp)
    80001aea:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001aec:	00013917          	auipc	s2,0x13
    80001af0:	d5490913          	addi	s2,s2,-684 # 80014840 <pid_lock>
    80001af4:	854a                	mv	a0,s2
    80001af6:	fffff097          	auipc	ra,0xfffff
    80001afa:	018080e7          	jalr	24(ra) # 80000b0e <acquire>
  pid = nextpid;
    80001afe:	00007797          	auipc	a5,0x7
    80001b02:	53a78793          	addi	a5,a5,1338 # 80009038 <nextpid>
    80001b06:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b08:	0014871b          	addiw	a4,s1,1
    80001b0c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b0e:	854a                	mv	a0,s2
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	06e080e7          	jalr	110(ra) # 80000b7e <release>
}
    80001b18:	8526                	mv	a0,s1
    80001b1a:	60e2                	ld	ra,24(sp)
    80001b1c:	6442                	ld	s0,16(sp)
    80001b1e:	64a2                	ld	s1,8(sp)
    80001b20:	6902                	ld	s2,0(sp)
    80001b22:	6105                	addi	sp,sp,32
    80001b24:	8082                	ret

0000000080001b26 <proc_pagetable>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
    80001b32:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b34:	00000097          	auipc	ra,0x0
    80001b38:	952080e7          	jalr	-1710(ra) # 80001486 <uvmcreate>
    80001b3c:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b3e:	4729                	li	a4,10
    80001b40:	00006697          	auipc	a3,0x6
    80001b44:	4c068693          	addi	a3,a3,1216 # 80008000 <trampoline>
    80001b48:	6605                	lui	a2,0x1
    80001b4a:	040005b7          	lui	a1,0x4000
    80001b4e:	15fd                	addi	a1,a1,-1
    80001b50:	05b2                	slli	a1,a1,0xc
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	6c0080e7          	jalr	1728(ra) # 80001212 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b5a:	4719                	li	a4,6
    80001b5c:	06093683          	ld	a3,96(s2)
    80001b60:	6605                	lui	a2,0x1
    80001b62:	020005b7          	lui	a1,0x2000
    80001b66:	15fd                	addi	a1,a1,-1
    80001b68:	05b6                	slli	a1,a1,0xd
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	fffff097          	auipc	ra,0xfffff
    80001b70:	6a6080e7          	jalr	1702(ra) # 80001212 <mappages>
}
    80001b74:	8526                	mv	a0,s1
    80001b76:	60e2                	ld	ra,24(sp)
    80001b78:	6442                	ld	s0,16(sp)
    80001b7a:	64a2                	ld	s1,8(sp)
    80001b7c:	6902                	ld	s2,0(sp)
    80001b7e:	6105                	addi	sp,sp,32
    80001b80:	8082                	ret

0000000080001b82 <allocproc>:
{
    80001b82:	1101                	addi	sp,sp,-32
    80001b84:	ec06                	sd	ra,24(sp)
    80001b86:	e822                	sd	s0,16(sp)
    80001b88:	e426                	sd	s1,8(sp)
    80001b8a:	e04a                	sd	s2,0(sp)
    80001b8c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b8e:	00013497          	auipc	s1,0x13
    80001b92:	0d248493          	addi	s1,s1,210 # 80014c60 <proc>
    80001b96:	0001e917          	auipc	s2,0x1e
    80001b9a:	aca90913          	addi	s2,s2,-1334 # 8001f660 <tickslock>
    acquire(&p->lock);
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	fffff097          	auipc	ra,0xfffff
    80001ba4:	f6e080e7          	jalr	-146(ra) # 80000b0e <acquire>
    if(p->state == UNUSED) {
    80001ba8:	509c                	lw	a5,32(s1)
    80001baa:	cf81                	beqz	a5,80001bc2 <allocproc+0x40>
      release(&p->lock);
    80001bac:	8526                	mv	a0,s1
    80001bae:	fffff097          	auipc	ra,0xfffff
    80001bb2:	fd0080e7          	jalr	-48(ra) # 80000b7e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bb6:	2a848493          	addi	s1,s1,680
    80001bba:	ff2492e3          	bne	s1,s2,80001b9e <allocproc+0x1c>
  return 0;
    80001bbe:	4481                	li	s1,0
    80001bc0:	a8a1                	j	80001c18 <allocproc+0x96>
  p->pid = allocpid();
    80001bc2:	00000097          	auipc	ra,0x0
    80001bc6:	f1e080e7          	jalr	-226(ra) # 80001ae0 <allocpid>
    80001bca:	c0a8                	sw	a0,64(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001bcc:	fffff097          	auipc	ra,0xfffff
    80001bd0:	d94080e7          	jalr	-620(ra) # 80000960 <kalloc>
    80001bd4:	892a                	mv	s2,a0
    80001bd6:	f0a8                	sd	a0,96(s1)
    80001bd8:	c539                	beqz	a0,80001c26 <allocproc+0xa4>
  p->pagetable = proc_pagetable(p);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	00000097          	auipc	ra,0x0
    80001be0:	f4a080e7          	jalr	-182(ra) # 80001b26 <proc_pagetable>
    80001be4:	eca8                	sd	a0,88(s1)
  memset(&p->context, 0, sizeof p->context);
    80001be6:	07000613          	li	a2,112
    80001bea:	4581                	li	a1,0
    80001bec:	06848513          	addi	a0,s1,104
    80001bf0:	fffff097          	auipc	ra,0xfffff
    80001bf4:	188080e7          	jalr	392(ra) # 80000d78 <memset>
  p->context.ra = (uint64)forkret;
    80001bf8:	00000797          	auipc	a5,0x0
    80001bfc:	ea278793          	addi	a5,a5,-350 # 80001a9a <forkret>
    80001c00:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c02:	64bc                	ld	a5,72(s1)
    80001c04:	6705                	lui	a4,0x1
    80001c06:	97ba                	add	a5,a5,a4
    80001c08:	f8bc                	sd	a5,112(s1)
  p->ticks = -1;
    80001c0a:	57fd                	li	a5,-1
    80001c0c:	16f4a823          	sw	a5,368(s1)
  p->tickpassed = 0;
    80001c10:	1804a023          	sw	zero,384(s1)
  p->handler = 0;
    80001c14:	1604bc23          	sd	zero,376(s1)
}
    80001c18:	8526                	mv	a0,s1
    80001c1a:	60e2                	ld	ra,24(sp)
    80001c1c:	6442                	ld	s0,16(sp)
    80001c1e:	64a2                	ld	s1,8(sp)
    80001c20:	6902                	ld	s2,0(sp)
    80001c22:	6105                	addi	sp,sp,32
    80001c24:	8082                	ret
    release(&p->lock);
    80001c26:	8526                	mv	a0,s1
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	f56080e7          	jalr	-170(ra) # 80000b7e <release>
    return 0;
    80001c30:	84ca                	mv	s1,s2
    80001c32:	b7dd                	j	80001c18 <allocproc+0x96>

0000000080001c34 <proc_freepagetable>:
{
    80001c34:	1101                	addi	sp,sp,-32
    80001c36:	ec06                	sd	ra,24(sp)
    80001c38:	e822                	sd	s0,16(sp)
    80001c3a:	e426                	sd	s1,8(sp)
    80001c3c:	e04a                	sd	s2,0(sp)
    80001c3e:	1000                	addi	s0,sp,32
    80001c40:	84aa                	mv	s1,a0
    80001c42:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001c44:	4681                	li	a3,0
    80001c46:	6605                	lui	a2,0x1
    80001c48:	040005b7          	lui	a1,0x4000
    80001c4c:	15fd                	addi	a1,a1,-1
    80001c4e:	05b2                	slli	a1,a1,0xc
    80001c50:	fffff097          	auipc	ra,0xfffff
    80001c54:	76e080e7          	jalr	1902(ra) # 800013be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001c58:	4681                	li	a3,0
    80001c5a:	6605                	lui	a2,0x1
    80001c5c:	020005b7          	lui	a1,0x2000
    80001c60:	15fd                	addi	a1,a1,-1
    80001c62:	05b6                	slli	a1,a1,0xd
    80001c64:	8526                	mv	a0,s1
    80001c66:	fffff097          	auipc	ra,0xfffff
    80001c6a:	758080e7          	jalr	1880(ra) # 800013be <uvmunmap>
  if(sz > 0)
    80001c6e:	00091863          	bnez	s2,80001c7e <proc_freepagetable+0x4a>
}
    80001c72:	60e2                	ld	ra,24(sp)
    80001c74:	6442                	ld	s0,16(sp)
    80001c76:	64a2                	ld	s1,8(sp)
    80001c78:	6902                	ld	s2,0(sp)
    80001c7a:	6105                	addi	sp,sp,32
    80001c7c:	8082                	ret
    uvmfree(pagetable, sz);
    80001c7e:	85ca                	mv	a1,s2
    80001c80:	8526                	mv	a0,s1
    80001c82:	00000097          	auipc	ra,0x0
    80001c86:	9a2080e7          	jalr	-1630(ra) # 80001624 <uvmfree>
}
    80001c8a:	b7e5                	j	80001c72 <proc_freepagetable+0x3e>

0000000080001c8c <freeproc>:
{
    80001c8c:	1101                	addi	sp,sp,-32
    80001c8e:	ec06                	sd	ra,24(sp)
    80001c90:	e822                	sd	s0,16(sp)
    80001c92:	e426                	sd	s1,8(sp)
    80001c94:	1000                	addi	s0,sp,32
    80001c96:	84aa                	mv	s1,a0
  if(p->tf)
    80001c98:	7128                	ld	a0,96(a0)
    80001c9a:	c509                	beqz	a0,80001ca4 <freeproc+0x18>
    kfree((void*)p->tf);
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	bc8080e7          	jalr	-1080(ra) # 80000864 <kfree>
  p->tf = 0;
    80001ca4:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001ca8:	6ca8                	ld	a0,88(s1)
    80001caa:	c511                	beqz	a0,80001cb6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001cac:	68ac                	ld	a1,80(s1)
    80001cae:	00000097          	auipc	ra,0x0
    80001cb2:	f86080e7          	jalr	-122(ra) # 80001c34 <proc_freepagetable>
  p->pagetable = 0;
    80001cb6:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001cba:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001cbe:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001cc2:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001cc6:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001cca:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001cce:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001cd2:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001cd6:	0204a023          	sw	zero,32(s1)
}
    80001cda:	60e2                	ld	ra,24(sp)
    80001cdc:	6442                	ld	s0,16(sp)
    80001cde:	64a2                	ld	s1,8(sp)
    80001ce0:	6105                	addi	sp,sp,32
    80001ce2:	8082                	ret

0000000080001ce4 <userinit>:
{
    80001ce4:	1101                	addi	sp,sp,-32
    80001ce6:	ec06                	sd	ra,24(sp)
    80001ce8:	e822                	sd	s0,16(sp)
    80001cea:	e426                	sd	s1,8(sp)
    80001cec:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cee:	00000097          	auipc	ra,0x0
    80001cf2:	e94080e7          	jalr	-364(ra) # 80001b82 <allocproc>
    80001cf6:	84aa                	mv	s1,a0
  initproc = p;
    80001cf8:	0002f797          	auipc	a5,0x2f
    80001cfc:	34a7b023          	sd	a0,832(a5) # 80031038 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d00:	03300613          	li	a2,51
    80001d04:	00007597          	auipc	a1,0x7
    80001d08:	2fc58593          	addi	a1,a1,764 # 80009000 <initcode>
    80001d0c:	6d28                	ld	a0,88(a0)
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	7b6080e7          	jalr	1974(ra) # 800014c4 <uvminit>
  p->sz = PGSIZE;
    80001d16:	6785                	lui	a5,0x1
    80001d18:	e8bc                	sd	a5,80(s1)
  p->tf->epc = 0;      // user program counter
    80001d1a:	70b8                	ld	a4,96(s1)
    80001d1c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001d20:	70b8                	ld	a4,96(s1)
    80001d22:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d24:	4641                	li	a2,16
    80001d26:	00006597          	auipc	a1,0x6
    80001d2a:	71a58593          	addi	a1,a1,1818 # 80008440 <userret+0x3b0>
    80001d2e:	16048513          	addi	a0,s1,352
    80001d32:	fffff097          	auipc	ra,0xfffff
    80001d36:	198080e7          	jalr	408(ra) # 80000eca <safestrcpy>
  p->cwd = namei("/");
    80001d3a:	00006517          	auipc	a0,0x6
    80001d3e:	71650513          	addi	a0,a0,1814 # 80008450 <userret+0x3c0>
    80001d42:	00002097          	auipc	ra,0x2
    80001d46:	0d8080e7          	jalr	216(ra) # 80003e1a <namei>
    80001d4a:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d4e:	4789                	li	a5,2
    80001d50:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001d52:	8526                	mv	a0,s1
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	e2a080e7          	jalr	-470(ra) # 80000b7e <release>
}
    80001d5c:	60e2                	ld	ra,24(sp)
    80001d5e:	6442                	ld	s0,16(sp)
    80001d60:	64a2                	ld	s1,8(sp)
    80001d62:	6105                	addi	sp,sp,32
    80001d64:	8082                	ret

0000000080001d66 <growproc>:
{
    80001d66:	1101                	addi	sp,sp,-32
    80001d68:	ec06                	sd	ra,24(sp)
    80001d6a:	e822                	sd	s0,16(sp)
    80001d6c:	e426                	sd	s1,8(sp)
    80001d6e:	e04a                	sd	s2,0(sp)
    80001d70:	1000                	addi	s0,sp,32
    80001d72:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	cee080e7          	jalr	-786(ra) # 80001a62 <myproc>
    80001d7c:	892a                	mv	s2,a0
  sz = p->sz;
    80001d7e:	692c                	ld	a1,80(a0)
    80001d80:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d84:	00904f63          	bgtz	s1,80001da2 <growproc+0x3c>
  } else if(n < 0){
    80001d88:	0204cc63          	bltz	s1,80001dc0 <growproc+0x5a>
  p->sz = sz;
    80001d8c:	1602                	slli	a2,a2,0x20
    80001d8e:	9201                	srli	a2,a2,0x20
    80001d90:	04c93823          	sd	a2,80(s2)
  return 0;
    80001d94:	4501                	li	a0,0
}
    80001d96:	60e2                	ld	ra,24(sp)
    80001d98:	6442                	ld	s0,16(sp)
    80001d9a:	64a2                	ld	s1,8(sp)
    80001d9c:	6902                	ld	s2,0(sp)
    80001d9e:	6105                	addi	sp,sp,32
    80001da0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001da2:	9e25                	addw	a2,a2,s1
    80001da4:	1602                	slli	a2,a2,0x20
    80001da6:	9201                	srli	a2,a2,0x20
    80001da8:	1582                	slli	a1,a1,0x20
    80001daa:	9181                	srli	a1,a1,0x20
    80001dac:	6d28                	ld	a0,88(a0)
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	7cc080e7          	jalr	1996(ra) # 8000157a <uvmalloc>
    80001db6:	0005061b          	sext.w	a2,a0
    80001dba:	fa69                	bnez	a2,80001d8c <growproc+0x26>
      return -1;
    80001dbc:	557d                	li	a0,-1
    80001dbe:	bfe1                	j	80001d96 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dc0:	9e25                	addw	a2,a2,s1
    80001dc2:	1602                	slli	a2,a2,0x20
    80001dc4:	9201                	srli	a2,a2,0x20
    80001dc6:	1582                	slli	a1,a1,0x20
    80001dc8:	9181                	srli	a1,a1,0x20
    80001dca:	6d28                	ld	a0,88(a0)
    80001dcc:	fffff097          	auipc	ra,0xfffff
    80001dd0:	76a080e7          	jalr	1898(ra) # 80001536 <uvmdealloc>
    80001dd4:	0005061b          	sext.w	a2,a0
    80001dd8:	bf55                	j	80001d8c <growproc+0x26>

0000000080001dda <fork>:
{
    80001dda:	7139                	addi	sp,sp,-64
    80001ddc:	fc06                	sd	ra,56(sp)
    80001dde:	f822                	sd	s0,48(sp)
    80001de0:	f426                	sd	s1,40(sp)
    80001de2:	f04a                	sd	s2,32(sp)
    80001de4:	ec4e                	sd	s3,24(sp)
    80001de6:	e852                	sd	s4,16(sp)
    80001de8:	e456                	sd	s5,8(sp)
    80001dea:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dec:	00000097          	auipc	ra,0x0
    80001df0:	c76080e7          	jalr	-906(ra) # 80001a62 <myproc>
    80001df4:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001df6:	00000097          	auipc	ra,0x0
    80001dfa:	d8c080e7          	jalr	-628(ra) # 80001b82 <allocproc>
    80001dfe:	c17d                	beqz	a0,80001ee4 <fork+0x10a>
    80001e00:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e02:	050ab603          	ld	a2,80(s5)
    80001e06:	6d2c                	ld	a1,88(a0)
    80001e08:	058ab503          	ld	a0,88(s5)
    80001e0c:	00000097          	auipc	ra,0x0
    80001e10:	846080e7          	jalr	-1978(ra) # 80001652 <uvmcopy>
    80001e14:	04054a63          	bltz	a0,80001e68 <fork+0x8e>
  np->sz = p->sz;
    80001e18:	050ab783          	ld	a5,80(s5)
    80001e1c:	04fa3823          	sd	a5,80(s4)
  np->parent = p;
    80001e20:	035a3423          	sd	s5,40(s4)
  *(np->tf) = *(p->tf);
    80001e24:	060ab683          	ld	a3,96(s5)
    80001e28:	87b6                	mv	a5,a3
    80001e2a:	060a3703          	ld	a4,96(s4)
    80001e2e:	12068693          	addi	a3,a3,288
    80001e32:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e36:	6788                	ld	a0,8(a5)
    80001e38:	6b8c                	ld	a1,16(a5)
    80001e3a:	6f90                	ld	a2,24(a5)
    80001e3c:	01073023          	sd	a6,0(a4)
    80001e40:	e708                	sd	a0,8(a4)
    80001e42:	eb0c                	sd	a1,16(a4)
    80001e44:	ef10                	sd	a2,24(a4)
    80001e46:	02078793          	addi	a5,a5,32
    80001e4a:	02070713          	addi	a4,a4,32
    80001e4e:	fed792e3          	bne	a5,a3,80001e32 <fork+0x58>
  np->tf->a0 = 0;
    80001e52:	060a3783          	ld	a5,96(s4)
    80001e56:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e5a:	0d8a8493          	addi	s1,s5,216
    80001e5e:	0d8a0913          	addi	s2,s4,216
    80001e62:	158a8993          	addi	s3,s5,344
    80001e66:	a00d                	j	80001e88 <fork+0xae>
    freeproc(np);
    80001e68:	8552                	mv	a0,s4
    80001e6a:	00000097          	auipc	ra,0x0
    80001e6e:	e22080e7          	jalr	-478(ra) # 80001c8c <freeproc>
    release(&np->lock);
    80001e72:	8552                	mv	a0,s4
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	d0a080e7          	jalr	-758(ra) # 80000b7e <release>
    return -1;
    80001e7c:	54fd                	li	s1,-1
    80001e7e:	a889                	j	80001ed0 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001e80:	04a1                	addi	s1,s1,8
    80001e82:	0921                	addi	s2,s2,8
    80001e84:	01348b63          	beq	s1,s3,80001e9a <fork+0xc0>
    if(p->ofile[i])
    80001e88:	6088                	ld	a0,0(s1)
    80001e8a:	d97d                	beqz	a0,80001e80 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e8c:	00003097          	auipc	ra,0x3
    80001e90:	880080e7          	jalr	-1920(ra) # 8000470c <filedup>
    80001e94:	00a93023          	sd	a0,0(s2)
    80001e98:	b7e5                	j	80001e80 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001e9a:	158ab503          	ld	a0,344(s5)
    80001e9e:	00001097          	auipc	ra,0x1
    80001ea2:	7b4080e7          	jalr	1972(ra) # 80003652 <idup>
    80001ea6:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eaa:	4641                	li	a2,16
    80001eac:	160a8593          	addi	a1,s5,352
    80001eb0:	160a0513          	addi	a0,s4,352
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	016080e7          	jalr	22(ra) # 80000eca <safestrcpy>
  pid = np->pid;
    80001ebc:	040a2483          	lw	s1,64(s4)
  np->state = RUNNABLE;
    80001ec0:	4789                	li	a5,2
    80001ec2:	02fa2023          	sw	a5,32(s4)
  release(&np->lock);
    80001ec6:	8552                	mv	a0,s4
    80001ec8:	fffff097          	auipc	ra,0xfffff
    80001ecc:	cb6080e7          	jalr	-842(ra) # 80000b7e <release>
}
    80001ed0:	8526                	mv	a0,s1
    80001ed2:	70e2                	ld	ra,56(sp)
    80001ed4:	7442                	ld	s0,48(sp)
    80001ed6:	74a2                	ld	s1,40(sp)
    80001ed8:	7902                	ld	s2,32(sp)
    80001eda:	69e2                	ld	s3,24(sp)
    80001edc:	6a42                	ld	s4,16(sp)
    80001ede:	6aa2                	ld	s5,8(sp)
    80001ee0:	6121                	addi	sp,sp,64
    80001ee2:	8082                	ret
    return -1;
    80001ee4:	54fd                	li	s1,-1
    80001ee6:	b7ed                	j	80001ed0 <fork+0xf6>

0000000080001ee8 <reparent>:
{
    80001ee8:	7179                	addi	sp,sp,-48
    80001eea:	f406                	sd	ra,40(sp)
    80001eec:	f022                	sd	s0,32(sp)
    80001eee:	ec26                	sd	s1,24(sp)
    80001ef0:	e84a                	sd	s2,16(sp)
    80001ef2:	e44e                	sd	s3,8(sp)
    80001ef4:	e052                	sd	s4,0(sp)
    80001ef6:	1800                	addi	s0,sp,48
    80001ef8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001efa:	00013497          	auipc	s1,0x13
    80001efe:	d6648493          	addi	s1,s1,-666 # 80014c60 <proc>
      pp->parent = initproc;
    80001f02:	0002fa17          	auipc	s4,0x2f
    80001f06:	136a0a13          	addi	s4,s4,310 # 80031038 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f0a:	0001d997          	auipc	s3,0x1d
    80001f0e:	75698993          	addi	s3,s3,1878 # 8001f660 <tickslock>
    80001f12:	a029                	j	80001f1c <reparent+0x34>
    80001f14:	2a848493          	addi	s1,s1,680
    80001f18:	03348363          	beq	s1,s3,80001f3e <reparent+0x56>
    if(pp->parent == p){
    80001f1c:	749c                	ld	a5,40(s1)
    80001f1e:	ff279be3          	bne	a5,s2,80001f14 <reparent+0x2c>
      acquire(&pp->lock);
    80001f22:	8526                	mv	a0,s1
    80001f24:	fffff097          	auipc	ra,0xfffff
    80001f28:	bea080e7          	jalr	-1046(ra) # 80000b0e <acquire>
      pp->parent = initproc;
    80001f2c:	000a3783          	ld	a5,0(s4)
    80001f30:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80001f32:	8526                	mv	a0,s1
    80001f34:	fffff097          	auipc	ra,0xfffff
    80001f38:	c4a080e7          	jalr	-950(ra) # 80000b7e <release>
    80001f3c:	bfe1                	j	80001f14 <reparent+0x2c>
}
    80001f3e:	70a2                	ld	ra,40(sp)
    80001f40:	7402                	ld	s0,32(sp)
    80001f42:	64e2                	ld	s1,24(sp)
    80001f44:	6942                	ld	s2,16(sp)
    80001f46:	69a2                	ld	s3,8(sp)
    80001f48:	6a02                	ld	s4,0(sp)
    80001f4a:	6145                	addi	sp,sp,48
    80001f4c:	8082                	ret

0000000080001f4e <scheduler>:
{
    80001f4e:	715d                	addi	sp,sp,-80
    80001f50:	e486                	sd	ra,72(sp)
    80001f52:	e0a2                	sd	s0,64(sp)
    80001f54:	fc26                	sd	s1,56(sp)
    80001f56:	f84a                	sd	s2,48(sp)
    80001f58:	f44e                	sd	s3,40(sp)
    80001f5a:	f052                	sd	s4,32(sp)
    80001f5c:	ec56                	sd	s5,24(sp)
    80001f5e:	e85a                	sd	s6,16(sp)
    80001f60:	e45e                	sd	s7,8(sp)
    80001f62:	e062                	sd	s8,0(sp)
    80001f64:	0880                	addi	s0,sp,80
    80001f66:	8792                	mv	a5,tp
  int id = r_tp();
    80001f68:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f6a:	00779b13          	slli	s6,a5,0x7
    80001f6e:	00013717          	auipc	a4,0x13
    80001f72:	8d270713          	addi	a4,a4,-1838 # 80014840 <pid_lock>
    80001f76:	975a                	add	a4,a4,s6
    80001f78:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    80001f7c:	00013717          	auipc	a4,0x13
    80001f80:	8ec70713          	addi	a4,a4,-1812 # 80014868 <cpus+0x8>
    80001f84:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f86:	4c0d                	li	s8,3
        c->proc = p;
    80001f88:	079e                	slli	a5,a5,0x7
    80001f8a:	00013a17          	auipc	s4,0x13
    80001f8e:	8b6a0a13          	addi	s4,s4,-1866 # 80014840 <pid_lock>
    80001f92:	9a3e                	add	s4,s4,a5
        found = 1;
    80001f94:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f96:	0001d997          	auipc	s3,0x1d
    80001f9a:	6ca98993          	addi	s3,s3,1738 # 8001f660 <tickslock>
    80001f9e:	a08d                	j	80002000 <scheduler+0xb2>
      release(&p->lock);
    80001fa0:	8526                	mv	a0,s1
    80001fa2:	fffff097          	auipc	ra,0xfffff
    80001fa6:	bdc080e7          	jalr	-1060(ra) # 80000b7e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001faa:	2a848493          	addi	s1,s1,680
    80001fae:	03348963          	beq	s1,s3,80001fe0 <scheduler+0x92>
      acquire(&p->lock);
    80001fb2:	8526                	mv	a0,s1
    80001fb4:	fffff097          	auipc	ra,0xfffff
    80001fb8:	b5a080e7          	jalr	-1190(ra) # 80000b0e <acquire>
      if(p->state == RUNNABLE) {
    80001fbc:	509c                	lw	a5,32(s1)
    80001fbe:	ff2791e3          	bne	a5,s2,80001fa0 <scheduler+0x52>
        p->state = RUNNING;
    80001fc2:	0384a023          	sw	s8,32(s1)
        c->proc = p;
    80001fc6:	029a3023          	sd	s1,32(s4)
        swtch(&c->scheduler, &p->context);
    80001fca:	06848593          	addi	a1,s1,104
    80001fce:	855a                	mv	a0,s6
    80001fd0:	00000097          	auipc	ra,0x0
    80001fd4:	62a080e7          	jalr	1578(ra) # 800025fa <swtch>
        c->proc = 0;
    80001fd8:	020a3023          	sd	zero,32(s4)
        found = 1;
    80001fdc:	8ade                	mv	s5,s7
    80001fde:	b7c9                	j	80001fa0 <scheduler+0x52>
    if(found == 0){
    80001fe0:	020a9063          	bnez	s5,80002000 <scheduler+0xb2>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001fe4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001fe8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001fec:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ff0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ff4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ff8:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001ffc:	10500073          	wfi
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002000:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80002004:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80002008:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000200c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002010:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002014:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002018:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000201a:	00013497          	auipc	s1,0x13
    8000201e:	c4648493          	addi	s1,s1,-954 # 80014c60 <proc>
      if(p->state == RUNNABLE) {
    80002022:	4909                	li	s2,2
    80002024:	b779                	j	80001fb2 <scheduler+0x64>

0000000080002026 <sched>:
{
    80002026:	7179                	addi	sp,sp,-48
    80002028:	f406                	sd	ra,40(sp)
    8000202a:	f022                	sd	s0,32(sp)
    8000202c:	ec26                	sd	s1,24(sp)
    8000202e:	e84a                	sd	s2,16(sp)
    80002030:	e44e                	sd	s3,8(sp)
    80002032:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002034:	00000097          	auipc	ra,0x0
    80002038:	a2e080e7          	jalr	-1490(ra) # 80001a62 <myproc>
    8000203c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000203e:	fffff097          	auipc	ra,0xfffff
    80002042:	a90080e7          	jalr	-1392(ra) # 80000ace <holding>
    80002046:	c93d                	beqz	a0,800020bc <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002048:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000204a:	2781                	sext.w	a5,a5
    8000204c:	079e                	slli	a5,a5,0x7
    8000204e:	00012717          	auipc	a4,0x12
    80002052:	7f270713          	addi	a4,a4,2034 # 80014840 <pid_lock>
    80002056:	97ba                	add	a5,a5,a4
    80002058:	0987a703          	lw	a4,152(a5)
    8000205c:	4785                	li	a5,1
    8000205e:	06f71763          	bne	a4,a5,800020cc <sched+0xa6>
  if(p->state == RUNNING)
    80002062:	5098                	lw	a4,32(s1)
    80002064:	478d                	li	a5,3
    80002066:	06f70b63          	beq	a4,a5,800020dc <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000206a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000206e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002070:	efb5                	bnez	a5,800020ec <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002072:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002074:	00012917          	auipc	s2,0x12
    80002078:	7cc90913          	addi	s2,s2,1996 # 80014840 <pid_lock>
    8000207c:	2781                	sext.w	a5,a5
    8000207e:	079e                	slli	a5,a5,0x7
    80002080:	97ca                	add	a5,a5,s2
    80002082:	09c7a983          	lw	s3,156(a5)
    80002086:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80002088:	2781                	sext.w	a5,a5
    8000208a:	079e                	slli	a5,a5,0x7
    8000208c:	00012597          	auipc	a1,0x12
    80002090:	7dc58593          	addi	a1,a1,2012 # 80014868 <cpus+0x8>
    80002094:	95be                	add	a1,a1,a5
    80002096:	06848513          	addi	a0,s1,104
    8000209a:	00000097          	auipc	ra,0x0
    8000209e:	560080e7          	jalr	1376(ra) # 800025fa <swtch>
    800020a2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020a4:	2781                	sext.w	a5,a5
    800020a6:	079e                	slli	a5,a5,0x7
    800020a8:	97ca                	add	a5,a5,s2
    800020aa:	0937ae23          	sw	s3,156(a5)
}
    800020ae:	70a2                	ld	ra,40(sp)
    800020b0:	7402                	ld	s0,32(sp)
    800020b2:	64e2                	ld	s1,24(sp)
    800020b4:	6942                	ld	s2,16(sp)
    800020b6:	69a2                	ld	s3,8(sp)
    800020b8:	6145                	addi	sp,sp,48
    800020ba:	8082                	ret
    panic("sched p->lock");
    800020bc:	00006517          	auipc	a0,0x6
    800020c0:	39c50513          	addi	a0,a0,924 # 80008458 <userret+0x3c8>
    800020c4:	ffffe097          	auipc	ra,0xffffe
    800020c8:	484080e7          	jalr	1156(ra) # 80000548 <panic>
    panic("sched locks");
    800020cc:	00006517          	auipc	a0,0x6
    800020d0:	39c50513          	addi	a0,a0,924 # 80008468 <userret+0x3d8>
    800020d4:	ffffe097          	auipc	ra,0xffffe
    800020d8:	474080e7          	jalr	1140(ra) # 80000548 <panic>
    panic("sched running");
    800020dc:	00006517          	auipc	a0,0x6
    800020e0:	39c50513          	addi	a0,a0,924 # 80008478 <userret+0x3e8>
    800020e4:	ffffe097          	auipc	ra,0xffffe
    800020e8:	464080e7          	jalr	1124(ra) # 80000548 <panic>
    panic("sched interruptible");
    800020ec:	00006517          	auipc	a0,0x6
    800020f0:	39c50513          	addi	a0,a0,924 # 80008488 <userret+0x3f8>
    800020f4:	ffffe097          	auipc	ra,0xffffe
    800020f8:	454080e7          	jalr	1108(ra) # 80000548 <panic>

00000000800020fc <exit>:
{
    800020fc:	7179                	addi	sp,sp,-48
    800020fe:	f406                	sd	ra,40(sp)
    80002100:	f022                	sd	s0,32(sp)
    80002102:	ec26                	sd	s1,24(sp)
    80002104:	e84a                	sd	s2,16(sp)
    80002106:	e44e                	sd	s3,8(sp)
    80002108:	e052                	sd	s4,0(sp)
    8000210a:	1800                	addi	s0,sp,48
    8000210c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000210e:	00000097          	auipc	ra,0x0
    80002112:	954080e7          	jalr	-1708(ra) # 80001a62 <myproc>
    80002116:	89aa                	mv	s3,a0
  if(p == initproc)
    80002118:	0002f797          	auipc	a5,0x2f
    8000211c:	f207b783          	ld	a5,-224(a5) # 80031038 <initproc>
    80002120:	0d850493          	addi	s1,a0,216
    80002124:	15850913          	addi	s2,a0,344
    80002128:	02a79363          	bne	a5,a0,8000214e <exit+0x52>
    panic("init exiting");
    8000212c:	00006517          	auipc	a0,0x6
    80002130:	37450513          	addi	a0,a0,884 # 800084a0 <userret+0x410>
    80002134:	ffffe097          	auipc	ra,0xffffe
    80002138:	414080e7          	jalr	1044(ra) # 80000548 <panic>
      fileclose(f);
    8000213c:	00002097          	auipc	ra,0x2
    80002140:	622080e7          	jalr	1570(ra) # 8000475e <fileclose>
      p->ofile[fd] = 0;
    80002144:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002148:	04a1                	addi	s1,s1,8
    8000214a:	01248563          	beq	s1,s2,80002154 <exit+0x58>
    if(p->ofile[fd]){
    8000214e:	6088                	ld	a0,0(s1)
    80002150:	f575                	bnez	a0,8000213c <exit+0x40>
    80002152:	bfdd                	j	80002148 <exit+0x4c>
  begin_op(ROOTDEV);
    80002154:	4501                	li	a0,0
    80002156:	00002097          	auipc	ra,0x2
    8000215a:	fe0080e7          	jalr	-32(ra) # 80004136 <begin_op>
  iput(p->cwd);
    8000215e:	1589b503          	ld	a0,344(s3)
    80002162:	00001097          	auipc	ra,0x1
    80002166:	63c080e7          	jalr	1596(ra) # 8000379e <iput>
  end_op(ROOTDEV);
    8000216a:	4501                	li	a0,0
    8000216c:	00002097          	auipc	ra,0x2
    80002170:	074080e7          	jalr	116(ra) # 800041e0 <end_op>
  p->cwd = 0;
    80002174:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    80002178:	0002f497          	auipc	s1,0x2f
    8000217c:	ec048493          	addi	s1,s1,-320 # 80031038 <initproc>
    80002180:	6088                	ld	a0,0(s1)
    80002182:	fffff097          	auipc	ra,0xfffff
    80002186:	98c080e7          	jalr	-1652(ra) # 80000b0e <acquire>
  wakeup1(initproc);
    8000218a:	6088                	ld	a0,0(s1)
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	796080e7          	jalr	1942(ra) # 80001922 <wakeup1>
  release(&initproc->lock);
    80002194:	6088                	ld	a0,0(s1)
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	9e8080e7          	jalr	-1560(ra) # 80000b7e <release>
  acquire(&p->lock);
    8000219e:	854e                	mv	a0,s3
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	96e080e7          	jalr	-1682(ra) # 80000b0e <acquire>
  struct proc *original_parent = p->parent;
    800021a8:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800021ac:	854e                	mv	a0,s3
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	9d0080e7          	jalr	-1584(ra) # 80000b7e <release>
  acquire(&original_parent->lock);
    800021b6:	8526                	mv	a0,s1
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	956080e7          	jalr	-1706(ra) # 80000b0e <acquire>
  acquire(&p->lock);
    800021c0:	854e                	mv	a0,s3
    800021c2:	fffff097          	auipc	ra,0xfffff
    800021c6:	94c080e7          	jalr	-1716(ra) # 80000b0e <acquire>
  reparent(p);
    800021ca:	854e                	mv	a0,s3
    800021cc:	00000097          	auipc	ra,0x0
    800021d0:	d1c080e7          	jalr	-740(ra) # 80001ee8 <reparent>
  wakeup1(original_parent);
    800021d4:	8526                	mv	a0,s1
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	74c080e7          	jalr	1868(ra) # 80001922 <wakeup1>
  p->xstate = status;
    800021de:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800021e2:	4791                	li	a5,4
    800021e4:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800021e8:	8526                	mv	a0,s1
    800021ea:	fffff097          	auipc	ra,0xfffff
    800021ee:	994080e7          	jalr	-1644(ra) # 80000b7e <release>
  sched();
    800021f2:	00000097          	auipc	ra,0x0
    800021f6:	e34080e7          	jalr	-460(ra) # 80002026 <sched>
  panic("zombie exit");
    800021fa:	00006517          	auipc	a0,0x6
    800021fe:	2b650513          	addi	a0,a0,694 # 800084b0 <userret+0x420>
    80002202:	ffffe097          	auipc	ra,0xffffe
    80002206:	346080e7          	jalr	838(ra) # 80000548 <panic>

000000008000220a <yield>:
{
    8000220a:	1101                	addi	sp,sp,-32
    8000220c:	ec06                	sd	ra,24(sp)
    8000220e:	e822                	sd	s0,16(sp)
    80002210:	e426                	sd	s1,8(sp)
    80002212:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002214:	00000097          	auipc	ra,0x0
    80002218:	84e080e7          	jalr	-1970(ra) # 80001a62 <myproc>
    8000221c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	8f0080e7          	jalr	-1808(ra) # 80000b0e <acquire>
  p->state = RUNNABLE;
    80002226:	4789                	li	a5,2
    80002228:	d09c                	sw	a5,32(s1)
  sched();
    8000222a:	00000097          	auipc	ra,0x0
    8000222e:	dfc080e7          	jalr	-516(ra) # 80002026 <sched>
  release(&p->lock);
    80002232:	8526                	mv	a0,s1
    80002234:	fffff097          	auipc	ra,0xfffff
    80002238:	94a080e7          	jalr	-1718(ra) # 80000b7e <release>
}
    8000223c:	60e2                	ld	ra,24(sp)
    8000223e:	6442                	ld	s0,16(sp)
    80002240:	64a2                	ld	s1,8(sp)
    80002242:	6105                	addi	sp,sp,32
    80002244:	8082                	ret

0000000080002246 <sleep>:
{
    80002246:	7179                	addi	sp,sp,-48
    80002248:	f406                	sd	ra,40(sp)
    8000224a:	f022                	sd	s0,32(sp)
    8000224c:	ec26                	sd	s1,24(sp)
    8000224e:	e84a                	sd	s2,16(sp)
    80002250:	e44e                	sd	s3,8(sp)
    80002252:	1800                	addi	s0,sp,48
    80002254:	89aa                	mv	s3,a0
    80002256:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002258:	00000097          	auipc	ra,0x0
    8000225c:	80a080e7          	jalr	-2038(ra) # 80001a62 <myproc>
    80002260:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002262:	05250663          	beq	a0,s2,800022ae <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002266:	fffff097          	auipc	ra,0xfffff
    8000226a:	8a8080e7          	jalr	-1880(ra) # 80000b0e <acquire>
    release(lk);
    8000226e:	854a                	mv	a0,s2
    80002270:	fffff097          	auipc	ra,0xfffff
    80002274:	90e080e7          	jalr	-1778(ra) # 80000b7e <release>
  p->chan = chan;
    80002278:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000227c:	4785                	li	a5,1
    8000227e:	d09c                	sw	a5,32(s1)
  sched();
    80002280:	00000097          	auipc	ra,0x0
    80002284:	da6080e7          	jalr	-602(ra) # 80002026 <sched>
  p->chan = 0;
    80002288:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    8000228c:	8526                	mv	a0,s1
    8000228e:	fffff097          	auipc	ra,0xfffff
    80002292:	8f0080e7          	jalr	-1808(ra) # 80000b7e <release>
    acquire(lk);
    80002296:	854a                	mv	a0,s2
    80002298:	fffff097          	auipc	ra,0xfffff
    8000229c:	876080e7          	jalr	-1930(ra) # 80000b0e <acquire>
}
    800022a0:	70a2                	ld	ra,40(sp)
    800022a2:	7402                	ld	s0,32(sp)
    800022a4:	64e2                	ld	s1,24(sp)
    800022a6:	6942                	ld	s2,16(sp)
    800022a8:	69a2                	ld	s3,8(sp)
    800022aa:	6145                	addi	sp,sp,48
    800022ac:	8082                	ret
  p->chan = chan;
    800022ae:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800022b2:	4785                	li	a5,1
    800022b4:	d11c                	sw	a5,32(a0)
  sched();
    800022b6:	00000097          	auipc	ra,0x0
    800022ba:	d70080e7          	jalr	-656(ra) # 80002026 <sched>
  p->chan = 0;
    800022be:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800022c2:	bff9                	j	800022a0 <sleep+0x5a>

00000000800022c4 <wait>:
{
    800022c4:	715d                	addi	sp,sp,-80
    800022c6:	e486                	sd	ra,72(sp)
    800022c8:	e0a2                	sd	s0,64(sp)
    800022ca:	fc26                	sd	s1,56(sp)
    800022cc:	f84a                	sd	s2,48(sp)
    800022ce:	f44e                	sd	s3,40(sp)
    800022d0:	f052                	sd	s4,32(sp)
    800022d2:	ec56                	sd	s5,24(sp)
    800022d4:	e85a                	sd	s6,16(sp)
    800022d6:	e45e                	sd	s7,8(sp)
    800022d8:	0880                	addi	s0,sp,80
    800022da:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	786080e7          	jalr	1926(ra) # 80001a62 <myproc>
    800022e4:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	828080e7          	jalr	-2008(ra) # 80000b0e <acquire>
    havekids = 0;
    800022ee:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022f0:	4a11                	li	s4,4
        havekids = 1;
    800022f2:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800022f4:	0001d997          	auipc	s3,0x1d
    800022f8:	36c98993          	addi	s3,s3,876 # 8001f660 <tickslock>
    havekids = 0;
    800022fc:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022fe:	00013497          	auipc	s1,0x13
    80002302:	96248493          	addi	s1,s1,-1694 # 80014c60 <proc>
    80002306:	a08d                	j	80002368 <wait+0xa4>
          pid = np->pid;
    80002308:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000230c:	000b0e63          	beqz	s6,80002328 <wait+0x64>
    80002310:	4691                	li	a3,4
    80002312:	03c48613          	addi	a2,s1,60
    80002316:	85da                	mv	a1,s6
    80002318:	05893503          	ld	a0,88(s2)
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	438080e7          	jalr	1080(ra) # 80001754 <copyout>
    80002324:	02054263          	bltz	a0,80002348 <wait+0x84>
          freeproc(np);
    80002328:	8526                	mv	a0,s1
    8000232a:	00000097          	auipc	ra,0x0
    8000232e:	962080e7          	jalr	-1694(ra) # 80001c8c <freeproc>
          release(&np->lock);
    80002332:	8526                	mv	a0,s1
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	84a080e7          	jalr	-1974(ra) # 80000b7e <release>
          release(&p->lock);
    8000233c:	854a                	mv	a0,s2
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	840080e7          	jalr	-1984(ra) # 80000b7e <release>
          return pid;
    80002346:	a8a9                	j	800023a0 <wait+0xdc>
            release(&np->lock);
    80002348:	8526                	mv	a0,s1
    8000234a:	fffff097          	auipc	ra,0xfffff
    8000234e:	834080e7          	jalr	-1996(ra) # 80000b7e <release>
            release(&p->lock);
    80002352:	854a                	mv	a0,s2
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	82a080e7          	jalr	-2006(ra) # 80000b7e <release>
            return -1;
    8000235c:	59fd                	li	s3,-1
    8000235e:	a089                	j	800023a0 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002360:	2a848493          	addi	s1,s1,680
    80002364:	03348463          	beq	s1,s3,8000238c <wait+0xc8>
      if(np->parent == p){
    80002368:	749c                	ld	a5,40(s1)
    8000236a:	ff279be3          	bne	a5,s2,80002360 <wait+0x9c>
        acquire(&np->lock);
    8000236e:	8526                	mv	a0,s1
    80002370:	ffffe097          	auipc	ra,0xffffe
    80002374:	79e080e7          	jalr	1950(ra) # 80000b0e <acquire>
        if(np->state == ZOMBIE){
    80002378:	509c                	lw	a5,32(s1)
    8000237a:	f94787e3          	beq	a5,s4,80002308 <wait+0x44>
        release(&np->lock);
    8000237e:	8526                	mv	a0,s1
    80002380:	ffffe097          	auipc	ra,0xffffe
    80002384:	7fe080e7          	jalr	2046(ra) # 80000b7e <release>
        havekids = 1;
    80002388:	8756                	mv	a4,s5
    8000238a:	bfd9                	j	80002360 <wait+0x9c>
    if(!havekids || p->killed){
    8000238c:	c701                	beqz	a4,80002394 <wait+0xd0>
    8000238e:	03892783          	lw	a5,56(s2)
    80002392:	c39d                	beqz	a5,800023b8 <wait+0xf4>
      release(&p->lock);
    80002394:	854a                	mv	a0,s2
    80002396:	ffffe097          	auipc	ra,0xffffe
    8000239a:	7e8080e7          	jalr	2024(ra) # 80000b7e <release>
      return -1;
    8000239e:	59fd                	li	s3,-1
}
    800023a0:	854e                	mv	a0,s3
    800023a2:	60a6                	ld	ra,72(sp)
    800023a4:	6406                	ld	s0,64(sp)
    800023a6:	74e2                	ld	s1,56(sp)
    800023a8:	7942                	ld	s2,48(sp)
    800023aa:	79a2                	ld	s3,40(sp)
    800023ac:	7a02                	ld	s4,32(sp)
    800023ae:	6ae2                	ld	s5,24(sp)
    800023b0:	6b42                	ld	s6,16(sp)
    800023b2:	6ba2                	ld	s7,8(sp)
    800023b4:	6161                	addi	sp,sp,80
    800023b6:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023b8:	85ca                	mv	a1,s2
    800023ba:	854a                	mv	a0,s2
    800023bc:	00000097          	auipc	ra,0x0
    800023c0:	e8a080e7          	jalr	-374(ra) # 80002246 <sleep>
    havekids = 0;
    800023c4:	bf25                	j	800022fc <wait+0x38>

00000000800023c6 <wakeup>:
{
    800023c6:	7139                	addi	sp,sp,-64
    800023c8:	fc06                	sd	ra,56(sp)
    800023ca:	f822                	sd	s0,48(sp)
    800023cc:	f426                	sd	s1,40(sp)
    800023ce:	f04a                	sd	s2,32(sp)
    800023d0:	ec4e                	sd	s3,24(sp)
    800023d2:	e852                	sd	s4,16(sp)
    800023d4:	e456                	sd	s5,8(sp)
    800023d6:	0080                	addi	s0,sp,64
    800023d8:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023da:	00013497          	auipc	s1,0x13
    800023de:	88648493          	addi	s1,s1,-1914 # 80014c60 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023e2:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023e4:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023e6:	0001d917          	auipc	s2,0x1d
    800023ea:	27a90913          	addi	s2,s2,634 # 8001f660 <tickslock>
    800023ee:	a811                	j	80002402 <wakeup+0x3c>
    release(&p->lock);
    800023f0:	8526                	mv	a0,s1
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	78c080e7          	jalr	1932(ra) # 80000b7e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023fa:	2a848493          	addi	s1,s1,680
    800023fe:	03248063          	beq	s1,s2,8000241e <wakeup+0x58>
    acquire(&p->lock);
    80002402:	8526                	mv	a0,s1
    80002404:	ffffe097          	auipc	ra,0xffffe
    80002408:	70a080e7          	jalr	1802(ra) # 80000b0e <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000240c:	509c                	lw	a5,32(s1)
    8000240e:	ff3791e3          	bne	a5,s3,800023f0 <wakeup+0x2a>
    80002412:	789c                	ld	a5,48(s1)
    80002414:	fd479ee3          	bne	a5,s4,800023f0 <wakeup+0x2a>
      p->state = RUNNABLE;
    80002418:	0354a023          	sw	s5,32(s1)
    8000241c:	bfd1                	j	800023f0 <wakeup+0x2a>
}
    8000241e:	70e2                	ld	ra,56(sp)
    80002420:	7442                	ld	s0,48(sp)
    80002422:	74a2                	ld	s1,40(sp)
    80002424:	7902                	ld	s2,32(sp)
    80002426:	69e2                	ld	s3,24(sp)
    80002428:	6a42                	ld	s4,16(sp)
    8000242a:	6aa2                	ld	s5,8(sp)
    8000242c:	6121                	addi	sp,sp,64
    8000242e:	8082                	ret

0000000080002430 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002430:	7179                	addi	sp,sp,-48
    80002432:	f406                	sd	ra,40(sp)
    80002434:	f022                	sd	s0,32(sp)
    80002436:	ec26                	sd	s1,24(sp)
    80002438:	e84a                	sd	s2,16(sp)
    8000243a:	e44e                	sd	s3,8(sp)
    8000243c:	1800                	addi	s0,sp,48
    8000243e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002440:	00013497          	auipc	s1,0x13
    80002444:	82048493          	addi	s1,s1,-2016 # 80014c60 <proc>
    80002448:	0001d997          	auipc	s3,0x1d
    8000244c:	21898993          	addi	s3,s3,536 # 8001f660 <tickslock>
    acquire(&p->lock);
    80002450:	8526                	mv	a0,s1
    80002452:	ffffe097          	auipc	ra,0xffffe
    80002456:	6bc080e7          	jalr	1724(ra) # 80000b0e <acquire>
    if(p->pid == pid){
    8000245a:	40bc                	lw	a5,64(s1)
    8000245c:	01278d63          	beq	a5,s2,80002476 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	ffffe097          	auipc	ra,0xffffe
    80002466:	71c080e7          	jalr	1820(ra) # 80000b7e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000246a:	2a848493          	addi	s1,s1,680
    8000246e:	ff3491e3          	bne	s1,s3,80002450 <kill+0x20>
  }
  return -1;
    80002472:	557d                	li	a0,-1
    80002474:	a821                	j	8000248c <kill+0x5c>
      p->killed = 1;
    80002476:	4785                	li	a5,1
    80002478:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    8000247a:	5098                	lw	a4,32(s1)
    8000247c:	00f70f63          	beq	a4,a5,8000249a <kill+0x6a>
      release(&p->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	ffffe097          	auipc	ra,0xffffe
    80002486:	6fc080e7          	jalr	1788(ra) # 80000b7e <release>
      return 0;
    8000248a:	4501                	li	a0,0
}
    8000248c:	70a2                	ld	ra,40(sp)
    8000248e:	7402                	ld	s0,32(sp)
    80002490:	64e2                	ld	s1,24(sp)
    80002492:	6942                	ld	s2,16(sp)
    80002494:	69a2                	ld	s3,8(sp)
    80002496:	6145                	addi	sp,sp,48
    80002498:	8082                	ret
        p->state = RUNNABLE;
    8000249a:	4789                	li	a5,2
    8000249c:	d09c                	sw	a5,32(s1)
    8000249e:	b7cd                	j	80002480 <kill+0x50>

00000000800024a0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024a0:	7179                	addi	sp,sp,-48
    800024a2:	f406                	sd	ra,40(sp)
    800024a4:	f022                	sd	s0,32(sp)
    800024a6:	ec26                	sd	s1,24(sp)
    800024a8:	e84a                	sd	s2,16(sp)
    800024aa:	e44e                	sd	s3,8(sp)
    800024ac:	e052                	sd	s4,0(sp)
    800024ae:	1800                	addi	s0,sp,48
    800024b0:	84aa                	mv	s1,a0
    800024b2:	892e                	mv	s2,a1
    800024b4:	89b2                	mv	s3,a2
    800024b6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024b8:	fffff097          	auipc	ra,0xfffff
    800024bc:	5aa080e7          	jalr	1450(ra) # 80001a62 <myproc>
  if(user_dst){
    800024c0:	c08d                	beqz	s1,800024e2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024c2:	86d2                	mv	a3,s4
    800024c4:	864e                	mv	a2,s3
    800024c6:	85ca                	mv	a1,s2
    800024c8:	6d28                	ld	a0,88(a0)
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	28a080e7          	jalr	650(ra) # 80001754 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024d2:	70a2                	ld	ra,40(sp)
    800024d4:	7402                	ld	s0,32(sp)
    800024d6:	64e2                	ld	s1,24(sp)
    800024d8:	6942                	ld	s2,16(sp)
    800024da:	69a2                	ld	s3,8(sp)
    800024dc:	6a02                	ld	s4,0(sp)
    800024de:	6145                	addi	sp,sp,48
    800024e0:	8082                	ret
    memmove((char *)dst, src, len);
    800024e2:	000a061b          	sext.w	a2,s4
    800024e6:	85ce                	mv	a1,s3
    800024e8:	854a                	mv	a0,s2
    800024ea:	fffff097          	auipc	ra,0xfffff
    800024ee:	8ea080e7          	jalr	-1814(ra) # 80000dd4 <memmove>
    return 0;
    800024f2:	8526                	mv	a0,s1
    800024f4:	bff9                	j	800024d2 <either_copyout+0x32>

00000000800024f6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024f6:	7179                	addi	sp,sp,-48
    800024f8:	f406                	sd	ra,40(sp)
    800024fa:	f022                	sd	s0,32(sp)
    800024fc:	ec26                	sd	s1,24(sp)
    800024fe:	e84a                	sd	s2,16(sp)
    80002500:	e44e                	sd	s3,8(sp)
    80002502:	e052                	sd	s4,0(sp)
    80002504:	1800                	addi	s0,sp,48
    80002506:	892a                	mv	s2,a0
    80002508:	84ae                	mv	s1,a1
    8000250a:	89b2                	mv	s3,a2
    8000250c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000250e:	fffff097          	auipc	ra,0xfffff
    80002512:	554080e7          	jalr	1364(ra) # 80001a62 <myproc>
  if(user_src){
    80002516:	c08d                	beqz	s1,80002538 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002518:	86d2                	mv	a3,s4
    8000251a:	864e                	mv	a2,s3
    8000251c:	85ca                	mv	a1,s2
    8000251e:	6d28                	ld	a0,88(a0)
    80002520:	fffff097          	auipc	ra,0xfffff
    80002524:	2c0080e7          	jalr	704(ra) # 800017e0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002528:	70a2                	ld	ra,40(sp)
    8000252a:	7402                	ld	s0,32(sp)
    8000252c:	64e2                	ld	s1,24(sp)
    8000252e:	6942                	ld	s2,16(sp)
    80002530:	69a2                	ld	s3,8(sp)
    80002532:	6a02                	ld	s4,0(sp)
    80002534:	6145                	addi	sp,sp,48
    80002536:	8082                	ret
    memmove(dst, (char*)src, len);
    80002538:	000a061b          	sext.w	a2,s4
    8000253c:	85ce                	mv	a1,s3
    8000253e:	854a                	mv	a0,s2
    80002540:	fffff097          	auipc	ra,0xfffff
    80002544:	894080e7          	jalr	-1900(ra) # 80000dd4 <memmove>
    return 0;
    80002548:	8526                	mv	a0,s1
    8000254a:	bff9                	j	80002528 <either_copyin+0x32>

000000008000254c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000254c:	715d                	addi	sp,sp,-80
    8000254e:	e486                	sd	ra,72(sp)
    80002550:	e0a2                	sd	s0,64(sp)
    80002552:	fc26                	sd	s1,56(sp)
    80002554:	f84a                	sd	s2,48(sp)
    80002556:	f44e                	sd	s3,40(sp)
    80002558:	f052                	sd	s4,32(sp)
    8000255a:	ec56                	sd	s5,24(sp)
    8000255c:	e85a                	sd	s6,16(sp)
    8000255e:	e45e                	sd	s7,8(sp)
    80002560:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002562:	00006517          	auipc	a0,0x6
    80002566:	da650513          	addi	a0,a0,-602 # 80008308 <userret+0x278>
    8000256a:	ffffe097          	auipc	ra,0xffffe
    8000256e:	038080e7          	jalr	56(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002572:	00013497          	auipc	s1,0x13
    80002576:	84e48493          	addi	s1,s1,-1970 # 80014dc0 <proc+0x160>
    8000257a:	0001d917          	auipc	s2,0x1d
    8000257e:	24690913          	addi	s2,s2,582 # 8001f7c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002582:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002584:	00006997          	auipc	s3,0x6
    80002588:	f3c98993          	addi	s3,s3,-196 # 800084c0 <userret+0x430>
    printf("%d %s %s", p->pid, state, p->name);
    8000258c:	00006a97          	auipc	s5,0x6
    80002590:	f3ca8a93          	addi	s5,s5,-196 # 800084c8 <userret+0x438>
    printf("\n");
    80002594:	00006a17          	auipc	s4,0x6
    80002598:	d74a0a13          	addi	s4,s4,-652 # 80008308 <userret+0x278>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000259c:	00006b97          	auipc	s7,0x6
    800025a0:	5bcb8b93          	addi	s7,s7,1468 # 80008b58 <states.0>
    800025a4:	a00d                	j	800025c6 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025a6:	ee06a583          	lw	a1,-288(a3)
    800025aa:	8556                	mv	a0,s5
    800025ac:	ffffe097          	auipc	ra,0xffffe
    800025b0:	ff6080e7          	jalr	-10(ra) # 800005a2 <printf>
    printf("\n");
    800025b4:	8552                	mv	a0,s4
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	fec080e7          	jalr	-20(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025be:	2a848493          	addi	s1,s1,680
    800025c2:	03248163          	beq	s1,s2,800025e4 <procdump+0x98>
    if(p->state == UNUSED)
    800025c6:	86a6                	mv	a3,s1
    800025c8:	ec04a783          	lw	a5,-320(s1)
    800025cc:	dbed                	beqz	a5,800025be <procdump+0x72>
      state = "???";
    800025ce:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025d0:	fcfb6be3          	bltu	s6,a5,800025a6 <procdump+0x5a>
    800025d4:	1782                	slli	a5,a5,0x20
    800025d6:	9381                	srli	a5,a5,0x20
    800025d8:	078e                	slli	a5,a5,0x3
    800025da:	97de                	add	a5,a5,s7
    800025dc:	6390                	ld	a2,0(a5)
    800025de:	f661                	bnez	a2,800025a6 <procdump+0x5a>
      state = "???";
    800025e0:	864e                	mv	a2,s3
    800025e2:	b7d1                	j	800025a6 <procdump+0x5a>
  }
}
    800025e4:	60a6                	ld	ra,72(sp)
    800025e6:	6406                	ld	s0,64(sp)
    800025e8:	74e2                	ld	s1,56(sp)
    800025ea:	7942                	ld	s2,48(sp)
    800025ec:	79a2                	ld	s3,40(sp)
    800025ee:	7a02                	ld	s4,32(sp)
    800025f0:	6ae2                	ld	s5,24(sp)
    800025f2:	6b42                	ld	s6,16(sp)
    800025f4:	6ba2                	ld	s7,8(sp)
    800025f6:	6161                	addi	sp,sp,80
    800025f8:	8082                	ret

00000000800025fa <swtch>:
    800025fa:	00153023          	sd	ra,0(a0)
    800025fe:	00253423          	sd	sp,8(a0)
    80002602:	e900                	sd	s0,16(a0)
    80002604:	ed04                	sd	s1,24(a0)
    80002606:	03253023          	sd	s2,32(a0)
    8000260a:	03353423          	sd	s3,40(a0)
    8000260e:	03453823          	sd	s4,48(a0)
    80002612:	03553c23          	sd	s5,56(a0)
    80002616:	05653023          	sd	s6,64(a0)
    8000261a:	05753423          	sd	s7,72(a0)
    8000261e:	05853823          	sd	s8,80(a0)
    80002622:	05953c23          	sd	s9,88(a0)
    80002626:	07a53023          	sd	s10,96(a0)
    8000262a:	07b53423          	sd	s11,104(a0)
    8000262e:	0005b083          	ld	ra,0(a1)
    80002632:	0085b103          	ld	sp,8(a1)
    80002636:	6980                	ld	s0,16(a1)
    80002638:	6d84                	ld	s1,24(a1)
    8000263a:	0205b903          	ld	s2,32(a1)
    8000263e:	0285b983          	ld	s3,40(a1)
    80002642:	0305ba03          	ld	s4,48(a1)
    80002646:	0385ba83          	ld	s5,56(a1)
    8000264a:	0405bb03          	ld	s6,64(a1)
    8000264e:	0485bb83          	ld	s7,72(a1)
    80002652:	0505bc03          	ld	s8,80(a1)
    80002656:	0585bc83          	ld	s9,88(a1)
    8000265a:	0605bd03          	ld	s10,96(a1)
    8000265e:	0685bd83          	ld	s11,104(a1)
    80002662:	8082                	ret

0000000080002664 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002664:	1141                	addi	sp,sp,-16
    80002666:	e406                	sd	ra,8(sp)
    80002668:	e022                	sd	s0,0(sp)
    8000266a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000266c:	00006597          	auipc	a1,0x6
    80002670:	e9458593          	addi	a1,a1,-364 # 80008500 <userret+0x470>
    80002674:	0001d517          	auipc	a0,0x1d
    80002678:	fec50513          	addi	a0,a0,-20 # 8001f660 <tickslock>
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	344080e7          	jalr	836(ra) # 800009c0 <initlock>
}
    80002684:	60a2                	ld	ra,8(sp)
    80002686:	6402                	ld	s0,0(sp)
    80002688:	0141                	addi	sp,sp,16
    8000268a:	8082                	ret

000000008000268c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000268c:	1141                	addi	sp,sp,-16
    8000268e:	e422                	sd	s0,8(sp)
    80002690:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002692:	00004797          	auipc	a5,0x4
    80002696:	85e78793          	addi	a5,a5,-1954 # 80005ef0 <kernelvec>
    8000269a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000269e:	6422                	ld	s0,8(sp)
    800026a0:	0141                	addi	sp,sp,16
    800026a2:	8082                	ret

00000000800026a4 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026a4:	1141                	addi	sp,sp,-16
    800026a6:	e406                	sd	ra,8(sp)
    800026a8:	e022                	sd	s0,0(sp)
    800026aa:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026ac:	fffff097          	auipc	ra,0xfffff
    800026b0:	3b6080e7          	jalr	950(ra) # 80001a62 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026b8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ba:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026be:	00006617          	auipc	a2,0x6
    800026c2:	94260613          	addi	a2,a2,-1726 # 80008000 <trampoline>
    800026c6:	00006697          	auipc	a3,0x6
    800026ca:	93a68693          	addi	a3,a3,-1734 # 80008000 <trampoline>
    800026ce:	8e91                	sub	a3,a3,a2
    800026d0:	040007b7          	lui	a5,0x4000
    800026d4:	17fd                	addi	a5,a5,-1
    800026d6:	07b2                	slli	a5,a5,0xc
    800026d8:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026da:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    800026de:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026e0:	180026f3          	csrr	a3,satp
    800026e4:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026e6:	7138                	ld	a4,96(a0)
    800026e8:	6534                	ld	a3,72(a0)
    800026ea:	6585                	lui	a1,0x1
    800026ec:	96ae                	add	a3,a3,a1
    800026ee:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    800026f0:	7138                	ld	a4,96(a0)
    800026f2:	00000697          	auipc	a3,0x0
    800026f6:	12868693          	addi	a3,a3,296 # 8000281a <usertrap>
    800026fa:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    800026fc:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026fe:	8692                	mv	a3,tp
    80002700:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002702:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002706:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000270a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000270e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    80002712:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002714:	6f18                	ld	a4,24(a4)
    80002716:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000271a:	6d2c                	ld	a1,88(a0)
    8000271c:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000271e:	00006717          	auipc	a4,0x6
    80002722:	97270713          	addi	a4,a4,-1678 # 80008090 <userret>
    80002726:	8f11                	sub	a4,a4,a2
    80002728:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000272a:	577d                	li	a4,-1
    8000272c:	177e                	slli	a4,a4,0x3f
    8000272e:	8dd9                	or	a1,a1,a4
    80002730:	02000537          	lui	a0,0x2000
    80002734:	157d                	addi	a0,a0,-1
    80002736:	0536                	slli	a0,a0,0xd
    80002738:	9782                	jalr	a5
}
    8000273a:	60a2                	ld	ra,8(sp)
    8000273c:	6402                	ld	s0,0(sp)
    8000273e:	0141                	addi	sp,sp,16
    80002740:	8082                	ret

0000000080002742 <clockintr>:
  /** 返回kernelvec.S 48行  */
}

void
clockintr()
{
    80002742:	1101                	addi	sp,sp,-32
    80002744:	ec06                	sd	ra,24(sp)
    80002746:	e822                	sd	s0,16(sp)
    80002748:	e426                	sd	s1,8(sp)
    8000274a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000274c:	0001d497          	auipc	s1,0x1d
    80002750:	f1448493          	addi	s1,s1,-236 # 8001f660 <tickslock>
    80002754:	8526                	mv	a0,s1
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	3b8080e7          	jalr	952(ra) # 80000b0e <acquire>
  ticks++;
    8000275e:	0002f517          	auipc	a0,0x2f
    80002762:	8e250513          	addi	a0,a0,-1822 # 80031040 <ticks>
    80002766:	411c                	lw	a5,0(a0)
    80002768:	2785                	addiw	a5,a5,1
    8000276a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000276c:	00000097          	auipc	ra,0x0
    80002770:	c5a080e7          	jalr	-934(ra) # 800023c6 <wakeup>
  release(&tickslock);
    80002774:	8526                	mv	a0,s1
    80002776:	ffffe097          	auipc	ra,0xffffe
    8000277a:	408080e7          	jalr	1032(ra) # 80000b7e <release>
}
    8000277e:	60e2                	ld	ra,24(sp)
    80002780:	6442                	ld	s0,16(sp)
    80002782:	64a2                	ld	s1,8(sp)
    80002784:	6105                	addi	sp,sp,32
    80002786:	8082                	ret

0000000080002788 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002788:	1101                	addi	sp,sp,-32
    8000278a:	ec06                	sd	ra,24(sp)
    8000278c:	e822                	sd	s0,16(sp)
    8000278e:	e426                	sd	s1,8(sp)
    80002790:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002792:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002796:	00074d63          	bltz	a4,800027b0 <devintr+0x28>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    }

    plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000001L){
    8000279a:	57fd                	li	a5,-1
    8000279c:	17fe                	slli	a5,a5,0x3f
    8000279e:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027a0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027a2:	04f70b63          	beq	a4,a5,800027f8 <devintr+0x70>
  }
}
    800027a6:	60e2                	ld	ra,24(sp)
    800027a8:	6442                	ld	s0,16(sp)
    800027aa:	64a2                	ld	s1,8(sp)
    800027ac:	6105                	addi	sp,sp,32
    800027ae:	8082                	ret
     (scause & 0xff) == 9){
    800027b0:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027b4:	46a5                	li	a3,9
    800027b6:	fed792e3          	bne	a5,a3,8000279a <devintr+0x12>
    int irq = plic_claim();
    800027ba:	00004097          	auipc	ra,0x4
    800027be:	83e080e7          	jalr	-1986(ra) # 80005ff8 <plic_claim>
    800027c2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027c4:	47a9                	li	a5,10
    800027c6:	00f50e63          	beq	a0,a5,800027e2 <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    800027ca:	fff5079b          	addiw	a5,a0,-1
    800027ce:	4705                	li	a4,1
    800027d0:	00f77e63          	bgeu	a4,a5,800027ec <devintr+0x64>
    plic_complete(irq);
    800027d4:	8526                	mv	a0,s1
    800027d6:	00004097          	auipc	ra,0x4
    800027da:	846080e7          	jalr	-1978(ra) # 8000601c <plic_complete>
    return 1;
    800027de:	4505                	li	a0,1
    800027e0:	b7d9                	j	800027a6 <devintr+0x1e>
      uartintr();
    800027e2:	ffffe097          	auipc	ra,0xffffe
    800027e6:	056080e7          	jalr	86(ra) # 80000838 <uartintr>
    800027ea:	b7ed                	j	800027d4 <devintr+0x4c>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800027ec:	853e                	mv	a0,a5
    800027ee:	00004097          	auipc	ra,0x4
    800027f2:	dd8080e7          	jalr	-552(ra) # 800065c6 <virtio_disk_intr>
    800027f6:	bff9                	j	800027d4 <devintr+0x4c>
    if(cpuid() == 0){
    800027f8:	fffff097          	auipc	ra,0xfffff
    800027fc:	23e080e7          	jalr	574(ra) # 80001a36 <cpuid>
    80002800:	c901                	beqz	a0,80002810 <devintr+0x88>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002802:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002806:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002808:	14479073          	csrw	sip,a5
    return 2;
    8000280c:	4509                	li	a0,2
    8000280e:	bf61                	j	800027a6 <devintr+0x1e>
      clockintr();
    80002810:	00000097          	auipc	ra,0x0
    80002814:	f32080e7          	jalr	-206(ra) # 80002742 <clockintr>
    80002818:	b7ed                	j	80002802 <devintr+0x7a>

000000008000281a <usertrap>:
{
    8000281a:	1101                	addi	sp,sp,-32
    8000281c:	ec06                	sd	ra,24(sp)
    8000281e:	e822                	sd	s0,16(sp)
    80002820:	e426                	sd	s1,8(sp)
    80002822:	e04a                	sd	s2,0(sp)
    80002824:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002826:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000282a:	1007f793          	andi	a5,a5,256
    8000282e:	e7bd                	bnez	a5,8000289c <usertrap+0x82>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002830:	00003797          	auipc	a5,0x3
    80002834:	6c078793          	addi	a5,a5,1728 # 80005ef0 <kernelvec>
    80002838:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000283c:	fffff097          	auipc	ra,0xfffff
    80002840:	226080e7          	jalr	550(ra) # 80001a62 <myproc>
    80002844:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002846:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002848:	14102773          	csrr	a4,sepc
    8000284c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000284e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002852:	47a1                	li	a5,8
    80002854:	06f71263          	bne	a4,a5,800028b8 <usertrap+0x9e>
    if(p->killed)
    80002858:	5d1c                	lw	a5,56(a0)
    8000285a:	eba9                	bnez	a5,800028ac <usertrap+0x92>
    p->tf->epc += 4;
    8000285c:	70b8                	ld	a4,96(s1)
    8000285e:	6f1c                	ld	a5,24(a4)
    80002860:	0791                	addi	a5,a5,4
    80002862:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002864:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80002868:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000286c:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002870:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002874:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002878:	10079073          	csrw	sstatus,a5
    syscall();
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	314080e7          	jalr	788(ra) # 80002b90 <syscall>
  if(p->killed)
    80002884:	5c9c                	lw	a5,56(s1)
    80002886:	e7c5                	bnez	a5,8000292e <usertrap+0x114>
  usertrapret();
    80002888:	00000097          	auipc	ra,0x0
    8000288c:	e1c080e7          	jalr	-484(ra) # 800026a4 <usertrapret>
}
    80002890:	60e2                	ld	ra,24(sp)
    80002892:	6442                	ld	s0,16(sp)
    80002894:	64a2                	ld	s1,8(sp)
    80002896:	6902                	ld	s2,0(sp)
    80002898:	6105                	addi	sp,sp,32
    8000289a:	8082                	ret
    panic("usertrap: not from user mode");
    8000289c:	00006517          	auipc	a0,0x6
    800028a0:	c6c50513          	addi	a0,a0,-916 # 80008508 <userret+0x478>
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	ca4080e7          	jalr	-860(ra) # 80000548 <panic>
      exit(-1);
    800028ac:	557d                	li	a0,-1
    800028ae:	00000097          	auipc	ra,0x0
    800028b2:	84e080e7          	jalr	-1970(ra) # 800020fc <exit>
    800028b6:	b75d                	j	8000285c <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028b8:	00000097          	auipc	ra,0x0
    800028bc:	ed0080e7          	jalr	-304(ra) # 80002788 <devintr>
    800028c0:	892a                	mv	s2,a0
    800028c2:	c501                	beqz	a0,800028ca <usertrap+0xb0>
  if(p->killed)
    800028c4:	5c9c                	lw	a5,56(s1)
    800028c6:	c3a1                	beqz	a5,80002906 <usertrap+0xec>
    800028c8:	a815                	j	800028fc <usertrap+0xe2>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028ca:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028ce:	40b0                	lw	a2,64(s1)
    800028d0:	00006517          	auipc	a0,0x6
    800028d4:	c5850513          	addi	a0,a0,-936 # 80008528 <userret+0x498>
    800028d8:	ffffe097          	auipc	ra,0xffffe
    800028dc:	cca080e7          	jalr	-822(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028e0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028e4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028e8:	00006517          	auipc	a0,0x6
    800028ec:	c7050513          	addi	a0,a0,-912 # 80008558 <userret+0x4c8>
    800028f0:	ffffe097          	auipc	ra,0xffffe
    800028f4:	cb2080e7          	jalr	-846(ra) # 800005a2 <printf>
    p->killed = 1;
    800028f8:	4785                	li	a5,1
    800028fa:	dc9c                	sw	a5,56(s1)
    exit(-1);
    800028fc:	557d                	li	a0,-1
    800028fe:	fffff097          	auipc	ra,0xfffff
    80002902:	7fe080e7          	jalr	2046(ra) # 800020fc <exit>
  if(which_dev == 2){
    80002906:	4789                	li	a5,2
    80002908:	f8f910e3          	bne	s2,a5,80002888 <usertrap+0x6e>
    p->tickpassed++;
    8000290c:	1804a783          	lw	a5,384(s1)
    80002910:	2785                	addiw	a5,a5,1
    80002912:	0007871b          	sext.w	a4,a5
    80002916:	18f4a023          	sw	a5,384(s1)
    if(p->ticks != 0){
    8000291a:	1704a783          	lw	a5,368(s1)
    8000291e:	c399                	beqz	a5,80002924 <usertrap+0x10a>
      if(p->tickpassed == p->ticks){
    80002920:	00f70963          	beq	a4,a5,80002932 <usertrap+0x118>
    yield();
    80002924:	00000097          	auipc	ra,0x0
    80002928:	8e6080e7          	jalr	-1818(ra) # 8000220a <yield>
    8000292c:	bfb1                	j	80002888 <usertrap+0x6e>
  int which_dev = 0;
    8000292e:	4901                	li	s2,0
    80002930:	b7f1                	j	800028fc <usertrap+0xe2>
        memmove(&p->savedtf, p->tf, sizeof(struct trapframe));
    80002932:	12000613          	li	a2,288
    80002936:	70ac                	ld	a1,96(s1)
    80002938:	18848513          	addi	a0,s1,392
    8000293c:	ffffe097          	auipc	ra,0xffffe
    80002940:	498080e7          	jalr	1176(ra) # 80000dd4 <memmove>
        p->tf->epc = (uint64)p->handler;
    80002944:	70bc                	ld	a5,96(s1)
    80002946:	1784b703          	ld	a4,376(s1)
    8000294a:	ef98                	sd	a4,24(a5)
    8000294c:	bfe1                	j	80002924 <usertrap+0x10a>

000000008000294e <kerneltrap>:
{
    8000294e:	7179                	addi	sp,sp,-48
    80002950:	f406                	sd	ra,40(sp)
    80002952:	f022                	sd	s0,32(sp)
    80002954:	ec26                	sd	s1,24(sp)
    80002956:	e84a                	sd	s2,16(sp)
    80002958:	e44e                	sd	s3,8(sp)
    8000295a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000295c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002960:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002964:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002968:	1004f793          	andi	a5,s1,256
    8000296c:	cb85                	beqz	a5,8000299c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000296e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002972:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002974:	ef85                	bnez	a5,800029ac <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002976:	00000097          	auipc	ra,0x0
    8000297a:	e12080e7          	jalr	-494(ra) # 80002788 <devintr>
    8000297e:	cd1d                	beqz	a0,800029bc <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002980:	4789                	li	a5,2
    80002982:	06f50a63          	beq	a0,a5,800029f6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002986:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000298a:	10049073          	csrw	sstatus,s1
}
    8000298e:	70a2                	ld	ra,40(sp)
    80002990:	7402                	ld	s0,32(sp)
    80002992:	64e2                	ld	s1,24(sp)
    80002994:	6942                	ld	s2,16(sp)
    80002996:	69a2                	ld	s3,8(sp)
    80002998:	6145                	addi	sp,sp,48
    8000299a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000299c:	00006517          	auipc	a0,0x6
    800029a0:	bdc50513          	addi	a0,a0,-1060 # 80008578 <userret+0x4e8>
    800029a4:	ffffe097          	auipc	ra,0xffffe
    800029a8:	ba4080e7          	jalr	-1116(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    800029ac:	00006517          	auipc	a0,0x6
    800029b0:	bf450513          	addi	a0,a0,-1036 # 800085a0 <userret+0x510>
    800029b4:	ffffe097          	auipc	ra,0xffffe
    800029b8:	b94080e7          	jalr	-1132(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    800029bc:	85ce                	mv	a1,s3
    800029be:	00006517          	auipc	a0,0x6
    800029c2:	c0250513          	addi	a0,a0,-1022 # 800085c0 <userret+0x530>
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	bdc080e7          	jalr	-1060(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ce:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029d2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029d6:	00006517          	auipc	a0,0x6
    800029da:	bfa50513          	addi	a0,a0,-1030 # 800085d0 <userret+0x540>
    800029de:	ffffe097          	auipc	ra,0xffffe
    800029e2:	bc4080e7          	jalr	-1084(ra) # 800005a2 <printf>
    panic("kerneltrap");
    800029e6:	00006517          	auipc	a0,0x6
    800029ea:	c0250513          	addi	a0,a0,-1022 # 800085e8 <userret+0x558>
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	b5a080e7          	jalr	-1190(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029f6:	fffff097          	auipc	ra,0xfffff
    800029fa:	06c080e7          	jalr	108(ra) # 80001a62 <myproc>
    800029fe:	d541                	beqz	a0,80002986 <kerneltrap+0x38>
    80002a00:	fffff097          	auipc	ra,0xfffff
    80002a04:	062080e7          	jalr	98(ra) # 80001a62 <myproc>
    80002a08:	5118                	lw	a4,32(a0)
    80002a0a:	478d                	li	a5,3
    80002a0c:	f6f71de3          	bne	a4,a5,80002986 <kerneltrap+0x38>
    yield();
    80002a10:	fffff097          	auipc	ra,0xfffff
    80002a14:	7fa080e7          	jalr	2042(ra) # 8000220a <yield>
    80002a18:	b7bd                	j	80002986 <kerneltrap+0x38>

0000000080002a1a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a1a:	1101                	addi	sp,sp,-32
    80002a1c:	ec06                	sd	ra,24(sp)
    80002a1e:	e822                	sd	s0,16(sp)
    80002a20:	e426                	sd	s1,8(sp)
    80002a22:	1000                	addi	s0,sp,32
    80002a24:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a26:	fffff097          	auipc	ra,0xfffff
    80002a2a:	03c080e7          	jalr	60(ra) # 80001a62 <myproc>
  switch (n) {
    80002a2e:	4795                	li	a5,5
    80002a30:	0497e163          	bltu	a5,s1,80002a72 <argraw+0x58>
    80002a34:	048a                	slli	s1,s1,0x2
    80002a36:	00006717          	auipc	a4,0x6
    80002a3a:	14a70713          	addi	a4,a4,330 # 80008b80 <states.0+0x28>
    80002a3e:	94ba                	add	s1,s1,a4
    80002a40:	409c                	lw	a5,0(s1)
    80002a42:	97ba                	add	a5,a5,a4
    80002a44:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002a46:	713c                	ld	a5,96(a0)
    80002a48:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002a4a:	60e2                	ld	ra,24(sp)
    80002a4c:	6442                	ld	s0,16(sp)
    80002a4e:	64a2                	ld	s1,8(sp)
    80002a50:	6105                	addi	sp,sp,32
    80002a52:	8082                	ret
    return p->tf->a1;
    80002a54:	713c                	ld	a5,96(a0)
    80002a56:	7fa8                	ld	a0,120(a5)
    80002a58:	bfcd                	j	80002a4a <argraw+0x30>
    return p->tf->a2;
    80002a5a:	713c                	ld	a5,96(a0)
    80002a5c:	63c8                	ld	a0,128(a5)
    80002a5e:	b7f5                	j	80002a4a <argraw+0x30>
    return p->tf->a3;
    80002a60:	713c                	ld	a5,96(a0)
    80002a62:	67c8                	ld	a0,136(a5)
    80002a64:	b7dd                	j	80002a4a <argraw+0x30>
    return p->tf->a4;
    80002a66:	713c                	ld	a5,96(a0)
    80002a68:	6bc8                	ld	a0,144(a5)
    80002a6a:	b7c5                	j	80002a4a <argraw+0x30>
    return p->tf->a5;
    80002a6c:	713c                	ld	a5,96(a0)
    80002a6e:	6fc8                	ld	a0,152(a5)
    80002a70:	bfe9                	j	80002a4a <argraw+0x30>
  panic("argraw");
    80002a72:	00006517          	auipc	a0,0x6
    80002a76:	b8650513          	addi	a0,a0,-1146 # 800085f8 <userret+0x568>
    80002a7a:	ffffe097          	auipc	ra,0xffffe
    80002a7e:	ace080e7          	jalr	-1330(ra) # 80000548 <panic>

0000000080002a82 <fetchaddr>:
{
    80002a82:	1101                	addi	sp,sp,-32
    80002a84:	ec06                	sd	ra,24(sp)
    80002a86:	e822                	sd	s0,16(sp)
    80002a88:	e426                	sd	s1,8(sp)
    80002a8a:	e04a                	sd	s2,0(sp)
    80002a8c:	1000                	addi	s0,sp,32
    80002a8e:	84aa                	mv	s1,a0
    80002a90:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	fd0080e7          	jalr	-48(ra) # 80001a62 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a9a:	693c                	ld	a5,80(a0)
    80002a9c:	02f4f863          	bgeu	s1,a5,80002acc <fetchaddr+0x4a>
    80002aa0:	00848713          	addi	a4,s1,8
    80002aa4:	02e7e663          	bltu	a5,a4,80002ad0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002aa8:	46a1                	li	a3,8
    80002aaa:	8626                	mv	a2,s1
    80002aac:	85ca                	mv	a1,s2
    80002aae:	6d28                	ld	a0,88(a0)
    80002ab0:	fffff097          	auipc	ra,0xfffff
    80002ab4:	d30080e7          	jalr	-720(ra) # 800017e0 <copyin>
    80002ab8:	00a03533          	snez	a0,a0
    80002abc:	40a00533          	neg	a0,a0
}
    80002ac0:	60e2                	ld	ra,24(sp)
    80002ac2:	6442                	ld	s0,16(sp)
    80002ac4:	64a2                	ld	s1,8(sp)
    80002ac6:	6902                	ld	s2,0(sp)
    80002ac8:	6105                	addi	sp,sp,32
    80002aca:	8082                	ret
    return -1;
    80002acc:	557d                	li	a0,-1
    80002ace:	bfcd                	j	80002ac0 <fetchaddr+0x3e>
    80002ad0:	557d                	li	a0,-1
    80002ad2:	b7fd                	j	80002ac0 <fetchaddr+0x3e>

0000000080002ad4 <fetchstr>:
{
    80002ad4:	7179                	addi	sp,sp,-48
    80002ad6:	f406                	sd	ra,40(sp)
    80002ad8:	f022                	sd	s0,32(sp)
    80002ada:	ec26                	sd	s1,24(sp)
    80002adc:	e84a                	sd	s2,16(sp)
    80002ade:	e44e                	sd	s3,8(sp)
    80002ae0:	1800                	addi	s0,sp,48
    80002ae2:	892a                	mv	s2,a0
    80002ae4:	84ae                	mv	s1,a1
    80002ae6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ae8:	fffff097          	auipc	ra,0xfffff
    80002aec:	f7a080e7          	jalr	-134(ra) # 80001a62 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002af0:	86ce                	mv	a3,s3
    80002af2:	864a                	mv	a2,s2
    80002af4:	85a6                	mv	a1,s1
    80002af6:	6d28                	ld	a0,88(a0)
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	d76080e7          	jalr	-650(ra) # 8000186e <copyinstr>
  if(err < 0)
    80002b00:	00054763          	bltz	a0,80002b0e <fetchstr+0x3a>
  return strlen(buf);
    80002b04:	8526                	mv	a0,s1
    80002b06:	ffffe097          	auipc	ra,0xffffe
    80002b0a:	3f6080e7          	jalr	1014(ra) # 80000efc <strlen>
}
    80002b0e:	70a2                	ld	ra,40(sp)
    80002b10:	7402                	ld	s0,32(sp)
    80002b12:	64e2                	ld	s1,24(sp)
    80002b14:	6942                	ld	s2,16(sp)
    80002b16:	69a2                	ld	s3,8(sp)
    80002b18:	6145                	addi	sp,sp,48
    80002b1a:	8082                	ret

0000000080002b1c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b1c:	1101                	addi	sp,sp,-32
    80002b1e:	ec06                	sd	ra,24(sp)
    80002b20:	e822                	sd	s0,16(sp)
    80002b22:	e426                	sd	s1,8(sp)
    80002b24:	1000                	addi	s0,sp,32
    80002b26:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b28:	00000097          	auipc	ra,0x0
    80002b2c:	ef2080e7          	jalr	-270(ra) # 80002a1a <argraw>
    80002b30:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b32:	4501                	li	a0,0
    80002b34:	60e2                	ld	ra,24(sp)
    80002b36:	6442                	ld	s0,16(sp)
    80002b38:	64a2                	ld	s1,8(sp)
    80002b3a:	6105                	addi	sp,sp,32
    80002b3c:	8082                	ret

0000000080002b3e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b3e:	1101                	addi	sp,sp,-32
    80002b40:	ec06                	sd	ra,24(sp)
    80002b42:	e822                	sd	s0,16(sp)
    80002b44:	e426                	sd	s1,8(sp)
    80002b46:	1000                	addi	s0,sp,32
    80002b48:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b4a:	00000097          	auipc	ra,0x0
    80002b4e:	ed0080e7          	jalr	-304(ra) # 80002a1a <argraw>
    80002b52:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b54:	4501                	li	a0,0
    80002b56:	60e2                	ld	ra,24(sp)
    80002b58:	6442                	ld	s0,16(sp)
    80002b5a:	64a2                	ld	s1,8(sp)
    80002b5c:	6105                	addi	sp,sp,32
    80002b5e:	8082                	ret

0000000080002b60 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b60:	1101                	addi	sp,sp,-32
    80002b62:	ec06                	sd	ra,24(sp)
    80002b64:	e822                	sd	s0,16(sp)
    80002b66:	e426                	sd	s1,8(sp)
    80002b68:	e04a                	sd	s2,0(sp)
    80002b6a:	1000                	addi	s0,sp,32
    80002b6c:	84ae                	mv	s1,a1
    80002b6e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b70:	00000097          	auipc	ra,0x0
    80002b74:	eaa080e7          	jalr	-342(ra) # 80002a1a <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b78:	864a                	mv	a2,s2
    80002b7a:	85a6                	mv	a1,s1
    80002b7c:	00000097          	auipc	ra,0x0
    80002b80:	f58080e7          	jalr	-168(ra) # 80002ad4 <fetchstr>
}
    80002b84:	60e2                	ld	ra,24(sp)
    80002b86:	6442                	ld	s0,16(sp)
    80002b88:	64a2                	ld	s1,8(sp)
    80002b8a:	6902                	ld	s2,0(sp)
    80002b8c:	6105                	addi	sp,sp,32
    80002b8e:	8082                	ret

0000000080002b90 <syscall>:
[SYS_sigreturn] sys_sigreturn
};

void
syscall(void)
{
    80002b90:	1101                	addi	sp,sp,-32
    80002b92:	ec06                	sd	ra,24(sp)
    80002b94:	e822                	sd	s0,16(sp)
    80002b96:	e426                	sd	s1,8(sp)
    80002b98:	e04a                	sd	s2,0(sp)
    80002b9a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b9c:	fffff097          	auipc	ra,0xfffff
    80002ba0:	ec6080e7          	jalr	-314(ra) # 80001a62 <myproc>
    80002ba4:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002ba6:	06053903          	ld	s2,96(a0)
    80002baa:	0a893783          	ld	a5,168(s2)
    80002bae:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bb2:	37fd                	addiw	a5,a5,-1
    80002bb4:	4769                	li	a4,26
    80002bb6:	00f76f63          	bltu	a4,a5,80002bd4 <syscall+0x44>
    80002bba:	00369713          	slli	a4,a3,0x3
    80002bbe:	00006797          	auipc	a5,0x6
    80002bc2:	fda78793          	addi	a5,a5,-38 # 80008b98 <syscalls>
    80002bc6:	97ba                	add	a5,a5,a4
    80002bc8:	639c                	ld	a5,0(a5)
    80002bca:	c789                	beqz	a5,80002bd4 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002bcc:	9782                	jalr	a5
    80002bce:	06a93823          	sd	a0,112(s2)
    80002bd2:	a839                	j	80002bf0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bd4:	16048613          	addi	a2,s1,352
    80002bd8:	40ac                	lw	a1,64(s1)
    80002bda:	00006517          	auipc	a0,0x6
    80002bde:	a2650513          	addi	a0,a0,-1498 # 80008600 <userret+0x570>
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	9c0080e7          	jalr	-1600(ra) # 800005a2 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002bea:	70bc                	ld	a5,96(s1)
    80002bec:	577d                	li	a4,-1
    80002bee:	fbb8                	sd	a4,112(a5)
  }
}
    80002bf0:	60e2                	ld	ra,24(sp)
    80002bf2:	6442                	ld	s0,16(sp)
    80002bf4:	64a2                	ld	s1,8(sp)
    80002bf6:	6902                	ld	s2,0(sp)
    80002bf8:	6105                	addi	sp,sp,32
    80002bfa:	8082                	ret

0000000080002bfc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bfc:	1101                	addi	sp,sp,-32
    80002bfe:	ec06                	sd	ra,24(sp)
    80002c00:	e822                	sd	s0,16(sp)
    80002c02:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c04:	fec40593          	addi	a1,s0,-20
    80002c08:	4501                	li	a0,0
    80002c0a:	00000097          	auipc	ra,0x0
    80002c0e:	f12080e7          	jalr	-238(ra) # 80002b1c <argint>
    return -1;
    80002c12:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c14:	00054963          	bltz	a0,80002c26 <sys_exit+0x2a>
  exit(n);
    80002c18:	fec42503          	lw	a0,-20(s0)
    80002c1c:	fffff097          	auipc	ra,0xfffff
    80002c20:	4e0080e7          	jalr	1248(ra) # 800020fc <exit>
  return 0;  // not reached
    80002c24:	4781                	li	a5,0
}
    80002c26:	853e                	mv	a0,a5
    80002c28:	60e2                	ld	ra,24(sp)
    80002c2a:	6442                	ld	s0,16(sp)
    80002c2c:	6105                	addi	sp,sp,32
    80002c2e:	8082                	ret

0000000080002c30 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c30:	1141                	addi	sp,sp,-16
    80002c32:	e406                	sd	ra,8(sp)
    80002c34:	e022                	sd	s0,0(sp)
    80002c36:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c38:	fffff097          	auipc	ra,0xfffff
    80002c3c:	e2a080e7          	jalr	-470(ra) # 80001a62 <myproc>
}
    80002c40:	4128                	lw	a0,64(a0)
    80002c42:	60a2                	ld	ra,8(sp)
    80002c44:	6402                	ld	s0,0(sp)
    80002c46:	0141                	addi	sp,sp,16
    80002c48:	8082                	ret

0000000080002c4a <sys_fork>:

uint64
sys_fork(void)
{
    80002c4a:	1141                	addi	sp,sp,-16
    80002c4c:	e406                	sd	ra,8(sp)
    80002c4e:	e022                	sd	s0,0(sp)
    80002c50:	0800                	addi	s0,sp,16
  return fork();
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	188080e7          	jalr	392(ra) # 80001dda <fork>
}
    80002c5a:	60a2                	ld	ra,8(sp)
    80002c5c:	6402                	ld	s0,0(sp)
    80002c5e:	0141                	addi	sp,sp,16
    80002c60:	8082                	ret

0000000080002c62 <sys_wait>:

uint64
sys_wait(void)
{
    80002c62:	1101                	addi	sp,sp,-32
    80002c64:	ec06                	sd	ra,24(sp)
    80002c66:	e822                	sd	s0,16(sp)
    80002c68:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c6a:	fe840593          	addi	a1,s0,-24
    80002c6e:	4501                	li	a0,0
    80002c70:	00000097          	auipc	ra,0x0
    80002c74:	ece080e7          	jalr	-306(ra) # 80002b3e <argaddr>
    80002c78:	87aa                	mv	a5,a0
    return -1;
    80002c7a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002c7c:	0007c863          	bltz	a5,80002c8c <sys_wait+0x2a>
  return wait(p);
    80002c80:	fe843503          	ld	a0,-24(s0)
    80002c84:	fffff097          	auipc	ra,0xfffff
    80002c88:	640080e7          	jalr	1600(ra) # 800022c4 <wait>
}
    80002c8c:	60e2                	ld	ra,24(sp)
    80002c8e:	6442                	ld	s0,16(sp)
    80002c90:	6105                	addi	sp,sp,32
    80002c92:	8082                	ret

0000000080002c94 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c94:	7179                	addi	sp,sp,-48
    80002c96:	f406                	sd	ra,40(sp)
    80002c98:	f022                	sd	s0,32(sp)
    80002c9a:	ec26                	sd	s1,24(sp)
    80002c9c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c9e:	fdc40593          	addi	a1,s0,-36
    80002ca2:	4501                	li	a0,0
    80002ca4:	00000097          	auipc	ra,0x0
    80002ca8:	e78080e7          	jalr	-392(ra) # 80002b1c <argint>
    return -1;
    80002cac:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002cae:	00054f63          	bltz	a0,80002ccc <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002cb2:	fffff097          	auipc	ra,0xfffff
    80002cb6:	db0080e7          	jalr	-592(ra) # 80001a62 <myproc>
    80002cba:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002cbc:	fdc42503          	lw	a0,-36(s0)
    80002cc0:	fffff097          	auipc	ra,0xfffff
    80002cc4:	0a6080e7          	jalr	166(ra) # 80001d66 <growproc>
    80002cc8:	00054863          	bltz	a0,80002cd8 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002ccc:	8526                	mv	a0,s1
    80002cce:	70a2                	ld	ra,40(sp)
    80002cd0:	7402                	ld	s0,32(sp)
    80002cd2:	64e2                	ld	s1,24(sp)
    80002cd4:	6145                	addi	sp,sp,48
    80002cd6:	8082                	ret
    return -1;
    80002cd8:	54fd                	li	s1,-1
    80002cda:	bfcd                	j	80002ccc <sys_sbrk+0x38>

0000000080002cdc <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cdc:	7139                	addi	sp,sp,-64
    80002cde:	fc06                	sd	ra,56(sp)
    80002ce0:	f822                	sd	s0,48(sp)
    80002ce2:	f426                	sd	s1,40(sp)
    80002ce4:	f04a                	sd	s2,32(sp)
    80002ce6:	ec4e                	sd	s3,24(sp)
    80002ce8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002cea:	fcc40593          	addi	a1,s0,-52
    80002cee:	4501                	li	a0,0
    80002cf0:	00000097          	auipc	ra,0x0
    80002cf4:	e2c080e7          	jalr	-468(ra) # 80002b1c <argint>
    return -1;
    80002cf8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cfa:	06054563          	bltz	a0,80002d64 <sys_sleep+0x88>
  acquire(&tickslock);
    80002cfe:	0001d517          	auipc	a0,0x1d
    80002d02:	96250513          	addi	a0,a0,-1694 # 8001f660 <tickslock>
    80002d06:	ffffe097          	auipc	ra,0xffffe
    80002d0a:	e08080e7          	jalr	-504(ra) # 80000b0e <acquire>
  ticks0 = ticks;
    80002d0e:	0002e917          	auipc	s2,0x2e
    80002d12:	33292903          	lw	s2,818(s2) # 80031040 <ticks>
  while(ticks - ticks0 < n){
    80002d16:	fcc42783          	lw	a5,-52(s0)
    80002d1a:	cf85                	beqz	a5,80002d52 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d1c:	0001d997          	auipc	s3,0x1d
    80002d20:	94498993          	addi	s3,s3,-1724 # 8001f660 <tickslock>
    80002d24:	0002e497          	auipc	s1,0x2e
    80002d28:	31c48493          	addi	s1,s1,796 # 80031040 <ticks>
    if(myproc()->killed){
    80002d2c:	fffff097          	auipc	ra,0xfffff
    80002d30:	d36080e7          	jalr	-714(ra) # 80001a62 <myproc>
    80002d34:	5d1c                	lw	a5,56(a0)
    80002d36:	ef9d                	bnez	a5,80002d74 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d38:	85ce                	mv	a1,s3
    80002d3a:	8526                	mv	a0,s1
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	50a080e7          	jalr	1290(ra) # 80002246 <sleep>
  while(ticks - ticks0 < n){
    80002d44:	409c                	lw	a5,0(s1)
    80002d46:	412787bb          	subw	a5,a5,s2
    80002d4a:	fcc42703          	lw	a4,-52(s0)
    80002d4e:	fce7efe3          	bltu	a5,a4,80002d2c <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d52:	0001d517          	auipc	a0,0x1d
    80002d56:	90e50513          	addi	a0,a0,-1778 # 8001f660 <tickslock>
    80002d5a:	ffffe097          	auipc	ra,0xffffe
    80002d5e:	e24080e7          	jalr	-476(ra) # 80000b7e <release>
  return 0;
    80002d62:	4781                	li	a5,0
}
    80002d64:	853e                	mv	a0,a5
    80002d66:	70e2                	ld	ra,56(sp)
    80002d68:	7442                	ld	s0,48(sp)
    80002d6a:	74a2                	ld	s1,40(sp)
    80002d6c:	7902                	ld	s2,32(sp)
    80002d6e:	69e2                	ld	s3,24(sp)
    80002d70:	6121                	addi	sp,sp,64
    80002d72:	8082                	ret
      release(&tickslock);
    80002d74:	0001d517          	auipc	a0,0x1d
    80002d78:	8ec50513          	addi	a0,a0,-1812 # 8001f660 <tickslock>
    80002d7c:	ffffe097          	auipc	ra,0xffffe
    80002d80:	e02080e7          	jalr	-510(ra) # 80000b7e <release>
      return -1;
    80002d84:	57fd                	li	a5,-1
    80002d86:	bff9                	j	80002d64 <sys_sleep+0x88>

0000000080002d88 <sys_kill>:

uint64
sys_kill(void)
{
    80002d88:	1101                	addi	sp,sp,-32
    80002d8a:	ec06                	sd	ra,24(sp)
    80002d8c:	e822                	sd	s0,16(sp)
    80002d8e:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d90:	fec40593          	addi	a1,s0,-20
    80002d94:	4501                	li	a0,0
    80002d96:	00000097          	auipc	ra,0x0
    80002d9a:	d86080e7          	jalr	-634(ra) # 80002b1c <argint>
    80002d9e:	87aa                	mv	a5,a0
    return -1;
    80002da0:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002da2:	0007c863          	bltz	a5,80002db2 <sys_kill+0x2a>
  return kill(pid);
    80002da6:	fec42503          	lw	a0,-20(s0)
    80002daa:	fffff097          	auipc	ra,0xfffff
    80002dae:	686080e7          	jalr	1670(ra) # 80002430 <kill>
}
    80002db2:	60e2                	ld	ra,24(sp)
    80002db4:	6442                	ld	s0,16(sp)
    80002db6:	6105                	addi	sp,sp,32
    80002db8:	8082                	ret

0000000080002dba <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dba:	1101                	addi	sp,sp,-32
    80002dbc:	ec06                	sd	ra,24(sp)
    80002dbe:	e822                	sd	s0,16(sp)
    80002dc0:	e426                	sd	s1,8(sp)
    80002dc2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dc4:	0001d517          	auipc	a0,0x1d
    80002dc8:	89c50513          	addi	a0,a0,-1892 # 8001f660 <tickslock>
    80002dcc:	ffffe097          	auipc	ra,0xffffe
    80002dd0:	d42080e7          	jalr	-702(ra) # 80000b0e <acquire>
  xticks = ticks;
    80002dd4:	0002e497          	auipc	s1,0x2e
    80002dd8:	26c4a483          	lw	s1,620(s1) # 80031040 <ticks>
  release(&tickslock);
    80002ddc:	0001d517          	auipc	a0,0x1d
    80002de0:	88450513          	addi	a0,a0,-1916 # 8001f660 <tickslock>
    80002de4:	ffffe097          	auipc	ra,0xffffe
    80002de8:	d9a080e7          	jalr	-614(ra) # 80000b7e <release>
  return xticks;
}
    80002dec:	02049513          	slli	a0,s1,0x20
    80002df0:	9101                	srli	a0,a0,0x20
    80002df2:	60e2                	ld	ra,24(sp)
    80002df4:	6442                	ld	s0,16(sp)
    80002df6:	64a2                	ld	s1,8(sp)
    80002df8:	6105                	addi	sp,sp,32
    80002dfa:	8082                	ret

0000000080002dfc <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002dfc:	7179                	addi	sp,sp,-48
    80002dfe:	f406                	sd	ra,40(sp)
    80002e00:	f022                	sd	s0,32(sp)
    80002e02:	ec26                	sd	s1,24(sp)
    80002e04:	e84a                	sd	s2,16(sp)
    80002e06:	e44e                	sd	s3,8(sp)
    80002e08:	e052                	sd	s4,0(sp)
    80002e0a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e0c:	00005597          	auipc	a1,0x5
    80002e10:	4ac58593          	addi	a1,a1,1196 # 800082b8 <userret+0x228>
    80002e14:	0001d517          	auipc	a0,0x1d
    80002e18:	86c50513          	addi	a0,a0,-1940 # 8001f680 <bcache>
    80002e1c:	ffffe097          	auipc	ra,0xffffe
    80002e20:	ba4080e7          	jalr	-1116(ra) # 800009c0 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e24:	00025797          	auipc	a5,0x25
    80002e28:	85c78793          	addi	a5,a5,-1956 # 80027680 <bcache+0x8000>
    80002e2c:	00025717          	auipc	a4,0x25
    80002e30:	bb470713          	addi	a4,a4,-1100 # 800279e0 <bcache+0x8360>
    80002e34:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    80002e38:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e3c:	0001d497          	auipc	s1,0x1d
    80002e40:	86448493          	addi	s1,s1,-1948 # 8001f6a0 <bcache+0x20>
    b->next = bcache.head.next;
    80002e44:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e46:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e48:	00005a17          	auipc	s4,0x5
    80002e4c:	7d8a0a13          	addi	s4,s4,2008 # 80008620 <userret+0x590>
    b->next = bcache.head.next;
    80002e50:	3b893783          	ld	a5,952(s2)
    80002e54:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    80002e56:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    80002e5a:	85d2                	mv	a1,s4
    80002e5c:	01048513          	addi	a0,s1,16
    80002e60:	00001097          	auipc	ra,0x1
    80002e64:	6f0080e7          	jalr	1776(ra) # 80004550 <initsleeplock>
    bcache.head.next->prev = b;
    80002e68:	3b893783          	ld	a5,952(s2)
    80002e6c:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    80002e6e:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e72:	46048493          	addi	s1,s1,1120
    80002e76:	fd349de3          	bne	s1,s3,80002e50 <binit+0x54>
  }
}
    80002e7a:	70a2                	ld	ra,40(sp)
    80002e7c:	7402                	ld	s0,32(sp)
    80002e7e:	64e2                	ld	s1,24(sp)
    80002e80:	6942                	ld	s2,16(sp)
    80002e82:	69a2                	ld	s3,8(sp)
    80002e84:	6a02                	ld	s4,0(sp)
    80002e86:	6145                	addi	sp,sp,48
    80002e88:	8082                	ret

0000000080002e8a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e8a:	7179                	addi	sp,sp,-48
    80002e8c:	f406                	sd	ra,40(sp)
    80002e8e:	f022                	sd	s0,32(sp)
    80002e90:	ec26                	sd	s1,24(sp)
    80002e92:	e84a                	sd	s2,16(sp)
    80002e94:	e44e                	sd	s3,8(sp)
    80002e96:	1800                	addi	s0,sp,48
    80002e98:	892a                	mv	s2,a0
    80002e9a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e9c:	0001c517          	auipc	a0,0x1c
    80002ea0:	7e450513          	addi	a0,a0,2020 # 8001f680 <bcache>
    80002ea4:	ffffe097          	auipc	ra,0xffffe
    80002ea8:	c6a080e7          	jalr	-918(ra) # 80000b0e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002eac:	00025497          	auipc	s1,0x25
    80002eb0:	b8c4b483          	ld	s1,-1140(s1) # 80027a38 <bcache+0x83b8>
    80002eb4:	00025797          	auipc	a5,0x25
    80002eb8:	b2c78793          	addi	a5,a5,-1236 # 800279e0 <bcache+0x8360>
    80002ebc:	02f48f63          	beq	s1,a5,80002efa <bread+0x70>
    80002ec0:	873e                	mv	a4,a5
    80002ec2:	a021                	j	80002eca <bread+0x40>
    80002ec4:	6ca4                	ld	s1,88(s1)
    80002ec6:	02e48a63          	beq	s1,a4,80002efa <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002eca:	449c                	lw	a5,8(s1)
    80002ecc:	ff279ce3          	bne	a5,s2,80002ec4 <bread+0x3a>
    80002ed0:	44dc                	lw	a5,12(s1)
    80002ed2:	ff3799e3          	bne	a5,s3,80002ec4 <bread+0x3a>
      b->refcnt++;
    80002ed6:	44bc                	lw	a5,72(s1)
    80002ed8:	2785                	addiw	a5,a5,1
    80002eda:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002edc:	0001c517          	auipc	a0,0x1c
    80002ee0:	7a450513          	addi	a0,a0,1956 # 8001f680 <bcache>
    80002ee4:	ffffe097          	auipc	ra,0xffffe
    80002ee8:	c9a080e7          	jalr	-870(ra) # 80000b7e <release>
      acquiresleep(&b->lock);
    80002eec:	01048513          	addi	a0,s1,16
    80002ef0:	00001097          	auipc	ra,0x1
    80002ef4:	69a080e7          	jalr	1690(ra) # 8000458a <acquiresleep>
      return b;
    80002ef8:	a8b9                	j	80002f56 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002efa:	00025497          	auipc	s1,0x25
    80002efe:	b364b483          	ld	s1,-1226(s1) # 80027a30 <bcache+0x83b0>
    80002f02:	00025797          	auipc	a5,0x25
    80002f06:	ade78793          	addi	a5,a5,-1314 # 800279e0 <bcache+0x8360>
    80002f0a:	00f48863          	beq	s1,a5,80002f1a <bread+0x90>
    80002f0e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f10:	44bc                	lw	a5,72(s1)
    80002f12:	cf81                	beqz	a5,80002f2a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f14:	68a4                	ld	s1,80(s1)
    80002f16:	fee49de3          	bne	s1,a4,80002f10 <bread+0x86>
  panic("bget: no buffers");
    80002f1a:	00005517          	auipc	a0,0x5
    80002f1e:	70e50513          	addi	a0,a0,1806 # 80008628 <userret+0x598>
    80002f22:	ffffd097          	auipc	ra,0xffffd
    80002f26:	626080e7          	jalr	1574(ra) # 80000548 <panic>
      b->dev = dev;
    80002f2a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f2e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f32:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f36:	4785                	li	a5,1
    80002f38:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80002f3a:	0001c517          	auipc	a0,0x1c
    80002f3e:	74650513          	addi	a0,a0,1862 # 8001f680 <bcache>
    80002f42:	ffffe097          	auipc	ra,0xffffe
    80002f46:	c3c080e7          	jalr	-964(ra) # 80000b7e <release>
      acquiresleep(&b->lock);
    80002f4a:	01048513          	addi	a0,s1,16
    80002f4e:	00001097          	auipc	ra,0x1
    80002f52:	63c080e7          	jalr	1596(ra) # 8000458a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f56:	409c                	lw	a5,0(s1)
    80002f58:	cb89                	beqz	a5,80002f6a <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f5a:	8526                	mv	a0,s1
    80002f5c:	70a2                	ld	ra,40(sp)
    80002f5e:	7402                	ld	s0,32(sp)
    80002f60:	64e2                	ld	s1,24(sp)
    80002f62:	6942                	ld	s2,16(sp)
    80002f64:	69a2                	ld	s3,8(sp)
    80002f66:	6145                	addi	sp,sp,48
    80002f68:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    80002f6a:	4601                	li	a2,0
    80002f6c:	85a6                	mv	a1,s1
    80002f6e:	4488                	lw	a0,8(s1)
    80002f70:	00003097          	auipc	ra,0x3
    80002f74:	35a080e7          	jalr	858(ra) # 800062ca <virtio_disk_rw>
    b->valid = 1;
    80002f78:	4785                	li	a5,1
    80002f7a:	c09c                	sw	a5,0(s1)
  return b;
    80002f7c:	bff9                	j	80002f5a <bread+0xd0>

0000000080002f7e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f7e:	1101                	addi	sp,sp,-32
    80002f80:	ec06                	sd	ra,24(sp)
    80002f82:	e822                	sd	s0,16(sp)
    80002f84:	e426                	sd	s1,8(sp)
    80002f86:	1000                	addi	s0,sp,32
    80002f88:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f8a:	0541                	addi	a0,a0,16
    80002f8c:	00001097          	auipc	ra,0x1
    80002f90:	698080e7          	jalr	1688(ra) # 80004624 <holdingsleep>
    80002f94:	cd09                	beqz	a0,80002fae <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80002f96:	4605                	li	a2,1
    80002f98:	85a6                	mv	a1,s1
    80002f9a:	4488                	lw	a0,8(s1)
    80002f9c:	00003097          	auipc	ra,0x3
    80002fa0:	32e080e7          	jalr	814(ra) # 800062ca <virtio_disk_rw>
}
    80002fa4:	60e2                	ld	ra,24(sp)
    80002fa6:	6442                	ld	s0,16(sp)
    80002fa8:	64a2                	ld	s1,8(sp)
    80002faa:	6105                	addi	sp,sp,32
    80002fac:	8082                	ret
    panic("bwrite");
    80002fae:	00005517          	auipc	a0,0x5
    80002fb2:	69250513          	addi	a0,a0,1682 # 80008640 <userret+0x5b0>
    80002fb6:	ffffd097          	auipc	ra,0xffffd
    80002fba:	592080e7          	jalr	1426(ra) # 80000548 <panic>

0000000080002fbe <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80002fbe:	1101                	addi	sp,sp,-32
    80002fc0:	ec06                	sd	ra,24(sp)
    80002fc2:	e822                	sd	s0,16(sp)
    80002fc4:	e426                	sd	s1,8(sp)
    80002fc6:	e04a                	sd	s2,0(sp)
    80002fc8:	1000                	addi	s0,sp,32
    80002fca:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fcc:	01050913          	addi	s2,a0,16
    80002fd0:	854a                	mv	a0,s2
    80002fd2:	00001097          	auipc	ra,0x1
    80002fd6:	652080e7          	jalr	1618(ra) # 80004624 <holdingsleep>
    80002fda:	c92d                	beqz	a0,8000304c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002fdc:	854a                	mv	a0,s2
    80002fde:	00001097          	auipc	ra,0x1
    80002fe2:	602080e7          	jalr	1538(ra) # 800045e0 <releasesleep>

  acquire(&bcache.lock);
    80002fe6:	0001c517          	auipc	a0,0x1c
    80002fea:	69a50513          	addi	a0,a0,1690 # 8001f680 <bcache>
    80002fee:	ffffe097          	auipc	ra,0xffffe
    80002ff2:	b20080e7          	jalr	-1248(ra) # 80000b0e <acquire>
  b->refcnt--;
    80002ff6:	44bc                	lw	a5,72(s1)
    80002ff8:	37fd                	addiw	a5,a5,-1
    80002ffa:	0007871b          	sext.w	a4,a5
    80002ffe:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    80003000:	eb05                	bnez	a4,80003030 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003002:	6cbc                	ld	a5,88(s1)
    80003004:	68b8                	ld	a4,80(s1)
    80003006:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    80003008:	68bc                	ld	a5,80(s1)
    8000300a:	6cb8                	ld	a4,88(s1)
    8000300c:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    8000300e:	00024797          	auipc	a5,0x24
    80003012:	67278793          	addi	a5,a5,1650 # 80027680 <bcache+0x8000>
    80003016:	3b87b703          	ld	a4,952(a5)
    8000301a:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    8000301c:	00025717          	auipc	a4,0x25
    80003020:	9c470713          	addi	a4,a4,-1596 # 800279e0 <bcache+0x8360>
    80003024:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    80003026:	3b87b703          	ld	a4,952(a5)
    8000302a:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    8000302c:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    80003030:	0001c517          	auipc	a0,0x1c
    80003034:	65050513          	addi	a0,a0,1616 # 8001f680 <bcache>
    80003038:	ffffe097          	auipc	ra,0xffffe
    8000303c:	b46080e7          	jalr	-1210(ra) # 80000b7e <release>
}
    80003040:	60e2                	ld	ra,24(sp)
    80003042:	6442                	ld	s0,16(sp)
    80003044:	64a2                	ld	s1,8(sp)
    80003046:	6902                	ld	s2,0(sp)
    80003048:	6105                	addi	sp,sp,32
    8000304a:	8082                	ret
    panic("brelse");
    8000304c:	00005517          	auipc	a0,0x5
    80003050:	5fc50513          	addi	a0,a0,1532 # 80008648 <userret+0x5b8>
    80003054:	ffffd097          	auipc	ra,0xffffd
    80003058:	4f4080e7          	jalr	1268(ra) # 80000548 <panic>

000000008000305c <bpin>:

void
bpin(struct buf *b) {
    8000305c:	1101                	addi	sp,sp,-32
    8000305e:	ec06                	sd	ra,24(sp)
    80003060:	e822                	sd	s0,16(sp)
    80003062:	e426                	sd	s1,8(sp)
    80003064:	1000                	addi	s0,sp,32
    80003066:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003068:	0001c517          	auipc	a0,0x1c
    8000306c:	61850513          	addi	a0,a0,1560 # 8001f680 <bcache>
    80003070:	ffffe097          	auipc	ra,0xffffe
    80003074:	a9e080e7          	jalr	-1378(ra) # 80000b0e <acquire>
  b->refcnt++;
    80003078:	44bc                	lw	a5,72(s1)
    8000307a:	2785                	addiw	a5,a5,1
    8000307c:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    8000307e:	0001c517          	auipc	a0,0x1c
    80003082:	60250513          	addi	a0,a0,1538 # 8001f680 <bcache>
    80003086:	ffffe097          	auipc	ra,0xffffe
    8000308a:	af8080e7          	jalr	-1288(ra) # 80000b7e <release>
}
    8000308e:	60e2                	ld	ra,24(sp)
    80003090:	6442                	ld	s0,16(sp)
    80003092:	64a2                	ld	s1,8(sp)
    80003094:	6105                	addi	sp,sp,32
    80003096:	8082                	ret

0000000080003098 <bunpin>:

void
bunpin(struct buf *b) {
    80003098:	1101                	addi	sp,sp,-32
    8000309a:	ec06                	sd	ra,24(sp)
    8000309c:	e822                	sd	s0,16(sp)
    8000309e:	e426                	sd	s1,8(sp)
    800030a0:	1000                	addi	s0,sp,32
    800030a2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030a4:	0001c517          	auipc	a0,0x1c
    800030a8:	5dc50513          	addi	a0,a0,1500 # 8001f680 <bcache>
    800030ac:	ffffe097          	auipc	ra,0xffffe
    800030b0:	a62080e7          	jalr	-1438(ra) # 80000b0e <acquire>
  b->refcnt--;
    800030b4:	44bc                	lw	a5,72(s1)
    800030b6:	37fd                	addiw	a5,a5,-1
    800030b8:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    800030ba:	0001c517          	auipc	a0,0x1c
    800030be:	5c650513          	addi	a0,a0,1478 # 8001f680 <bcache>
    800030c2:	ffffe097          	auipc	ra,0xffffe
    800030c6:	abc080e7          	jalr	-1348(ra) # 80000b7e <release>
}
    800030ca:	60e2                	ld	ra,24(sp)
    800030cc:	6442                	ld	s0,16(sp)
    800030ce:	64a2                	ld	s1,8(sp)
    800030d0:	6105                	addi	sp,sp,32
    800030d2:	8082                	ret

00000000800030d4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030d4:	1101                	addi	sp,sp,-32
    800030d6:	ec06                	sd	ra,24(sp)
    800030d8:	e822                	sd	s0,16(sp)
    800030da:	e426                	sd	s1,8(sp)
    800030dc:	e04a                	sd	s2,0(sp)
    800030de:	1000                	addi	s0,sp,32
    800030e0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030e2:	00d5d59b          	srliw	a1,a1,0xd
    800030e6:	00025797          	auipc	a5,0x25
    800030ea:	d767a783          	lw	a5,-650(a5) # 80027e5c <sb+0x1c>
    800030ee:	9dbd                	addw	a1,a1,a5
    800030f0:	00000097          	auipc	ra,0x0
    800030f4:	d9a080e7          	jalr	-614(ra) # 80002e8a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030f8:	0074f713          	andi	a4,s1,7
    800030fc:	4785                	li	a5,1
    800030fe:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003102:	14ce                	slli	s1,s1,0x33
    80003104:	90d9                	srli	s1,s1,0x36
    80003106:	00950733          	add	a4,a0,s1
    8000310a:	06074703          	lbu	a4,96(a4)
    8000310e:	00e7f6b3          	and	a3,a5,a4
    80003112:	c69d                	beqz	a3,80003140 <bfree+0x6c>
    80003114:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003116:	94aa                	add	s1,s1,a0
    80003118:	fff7c793          	not	a5,a5
    8000311c:	8ff9                	and	a5,a5,a4
    8000311e:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80003122:	00001097          	auipc	ra,0x1
    80003126:	1d0080e7          	jalr	464(ra) # 800042f2 <log_write>
  brelse(bp);
    8000312a:	854a                	mv	a0,s2
    8000312c:	00000097          	auipc	ra,0x0
    80003130:	e92080e7          	jalr	-366(ra) # 80002fbe <brelse>
}
    80003134:	60e2                	ld	ra,24(sp)
    80003136:	6442                	ld	s0,16(sp)
    80003138:	64a2                	ld	s1,8(sp)
    8000313a:	6902                	ld	s2,0(sp)
    8000313c:	6105                	addi	sp,sp,32
    8000313e:	8082                	ret
    panic("freeing free block");
    80003140:	00005517          	auipc	a0,0x5
    80003144:	51050513          	addi	a0,a0,1296 # 80008650 <userret+0x5c0>
    80003148:	ffffd097          	auipc	ra,0xffffd
    8000314c:	400080e7          	jalr	1024(ra) # 80000548 <panic>

0000000080003150 <balloc>:
{
    80003150:	711d                	addi	sp,sp,-96
    80003152:	ec86                	sd	ra,88(sp)
    80003154:	e8a2                	sd	s0,80(sp)
    80003156:	e4a6                	sd	s1,72(sp)
    80003158:	e0ca                	sd	s2,64(sp)
    8000315a:	fc4e                	sd	s3,56(sp)
    8000315c:	f852                	sd	s4,48(sp)
    8000315e:	f456                	sd	s5,40(sp)
    80003160:	f05a                	sd	s6,32(sp)
    80003162:	ec5e                	sd	s7,24(sp)
    80003164:	e862                	sd	s8,16(sp)
    80003166:	e466                	sd	s9,8(sp)
    80003168:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000316a:	00025797          	auipc	a5,0x25
    8000316e:	cda7a783          	lw	a5,-806(a5) # 80027e44 <sb+0x4>
    80003172:	cbd1                	beqz	a5,80003206 <balloc+0xb6>
    80003174:	8baa                	mv	s7,a0
    80003176:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003178:	00025b17          	auipc	s6,0x25
    8000317c:	cc8b0b13          	addi	s6,s6,-824 # 80027e40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003180:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003182:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003184:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003186:	6c89                	lui	s9,0x2
    80003188:	a831                	j	800031a4 <balloc+0x54>
    brelse(bp);
    8000318a:	854a                	mv	a0,s2
    8000318c:	00000097          	auipc	ra,0x0
    80003190:	e32080e7          	jalr	-462(ra) # 80002fbe <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003194:	015c87bb          	addw	a5,s9,s5
    80003198:	00078a9b          	sext.w	s5,a5
    8000319c:	004b2703          	lw	a4,4(s6)
    800031a0:	06eaf363          	bgeu	s5,a4,80003206 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800031a4:	41fad79b          	sraiw	a5,s5,0x1f
    800031a8:	0137d79b          	srliw	a5,a5,0x13
    800031ac:	015787bb          	addw	a5,a5,s5
    800031b0:	40d7d79b          	sraiw	a5,a5,0xd
    800031b4:	01cb2583          	lw	a1,28(s6)
    800031b8:	9dbd                	addw	a1,a1,a5
    800031ba:	855e                	mv	a0,s7
    800031bc:	00000097          	auipc	ra,0x0
    800031c0:	cce080e7          	jalr	-818(ra) # 80002e8a <bread>
    800031c4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031c6:	004b2503          	lw	a0,4(s6)
    800031ca:	000a849b          	sext.w	s1,s5
    800031ce:	8662                	mv	a2,s8
    800031d0:	faa4fde3          	bgeu	s1,a0,8000318a <balloc+0x3a>
      m = 1 << (bi % 8);
    800031d4:	41f6579b          	sraiw	a5,a2,0x1f
    800031d8:	01d7d69b          	srliw	a3,a5,0x1d
    800031dc:	00c6873b          	addw	a4,a3,a2
    800031e0:	00777793          	andi	a5,a4,7
    800031e4:	9f95                	subw	a5,a5,a3
    800031e6:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031ea:	4037571b          	sraiw	a4,a4,0x3
    800031ee:	00e906b3          	add	a3,s2,a4
    800031f2:	0606c683          	lbu	a3,96(a3)
    800031f6:	00d7f5b3          	and	a1,a5,a3
    800031fa:	cd91                	beqz	a1,80003216 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031fc:	2605                	addiw	a2,a2,1
    800031fe:	2485                	addiw	s1,s1,1
    80003200:	fd4618e3          	bne	a2,s4,800031d0 <balloc+0x80>
    80003204:	b759                	j	8000318a <balloc+0x3a>
  panic("balloc: out of blocks");
    80003206:	00005517          	auipc	a0,0x5
    8000320a:	46250513          	addi	a0,a0,1122 # 80008668 <userret+0x5d8>
    8000320e:	ffffd097          	auipc	ra,0xffffd
    80003212:	33a080e7          	jalr	826(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003216:	974a                	add	a4,a4,s2
    80003218:	8fd5                	or	a5,a5,a3
    8000321a:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    8000321e:	854a                	mv	a0,s2
    80003220:	00001097          	auipc	ra,0x1
    80003224:	0d2080e7          	jalr	210(ra) # 800042f2 <log_write>
        brelse(bp);
    80003228:	854a                	mv	a0,s2
    8000322a:	00000097          	auipc	ra,0x0
    8000322e:	d94080e7          	jalr	-620(ra) # 80002fbe <brelse>
  bp = bread(dev, bno);
    80003232:	85a6                	mv	a1,s1
    80003234:	855e                	mv	a0,s7
    80003236:	00000097          	auipc	ra,0x0
    8000323a:	c54080e7          	jalr	-940(ra) # 80002e8a <bread>
    8000323e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003240:	40000613          	li	a2,1024
    80003244:	4581                	li	a1,0
    80003246:	06050513          	addi	a0,a0,96
    8000324a:	ffffe097          	auipc	ra,0xffffe
    8000324e:	b2e080e7          	jalr	-1234(ra) # 80000d78 <memset>
  log_write(bp);
    80003252:	854a                	mv	a0,s2
    80003254:	00001097          	auipc	ra,0x1
    80003258:	09e080e7          	jalr	158(ra) # 800042f2 <log_write>
  brelse(bp);
    8000325c:	854a                	mv	a0,s2
    8000325e:	00000097          	auipc	ra,0x0
    80003262:	d60080e7          	jalr	-672(ra) # 80002fbe <brelse>
}
    80003266:	8526                	mv	a0,s1
    80003268:	60e6                	ld	ra,88(sp)
    8000326a:	6446                	ld	s0,80(sp)
    8000326c:	64a6                	ld	s1,72(sp)
    8000326e:	6906                	ld	s2,64(sp)
    80003270:	79e2                	ld	s3,56(sp)
    80003272:	7a42                	ld	s4,48(sp)
    80003274:	7aa2                	ld	s5,40(sp)
    80003276:	7b02                	ld	s6,32(sp)
    80003278:	6be2                	ld	s7,24(sp)
    8000327a:	6c42                	ld	s8,16(sp)
    8000327c:	6ca2                	ld	s9,8(sp)
    8000327e:	6125                	addi	sp,sp,96
    80003280:	8082                	ret

0000000080003282 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003282:	7179                	addi	sp,sp,-48
    80003284:	f406                	sd	ra,40(sp)
    80003286:	f022                	sd	s0,32(sp)
    80003288:	ec26                	sd	s1,24(sp)
    8000328a:	e84a                	sd	s2,16(sp)
    8000328c:	e44e                	sd	s3,8(sp)
    8000328e:	e052                	sd	s4,0(sp)
    80003290:	1800                	addi	s0,sp,48
    80003292:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003294:	47ad                	li	a5,11
    80003296:	04b7fe63          	bgeu	a5,a1,800032f2 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000329a:	ff45849b          	addiw	s1,a1,-12
    8000329e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032a2:	0ff00793          	li	a5,255
    800032a6:	0ae7e363          	bltu	a5,a4,8000334c <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800032aa:	08852583          	lw	a1,136(a0)
    800032ae:	c5ad                	beqz	a1,80003318 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800032b0:	00092503          	lw	a0,0(s2)
    800032b4:	00000097          	auipc	ra,0x0
    800032b8:	bd6080e7          	jalr	-1066(ra) # 80002e8a <bread>
    800032bc:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032be:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    800032c2:	02049593          	slli	a1,s1,0x20
    800032c6:	9181                	srli	a1,a1,0x20
    800032c8:	058a                	slli	a1,a1,0x2
    800032ca:	00b784b3          	add	s1,a5,a1
    800032ce:	0004a983          	lw	s3,0(s1)
    800032d2:	04098d63          	beqz	s3,8000332c <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800032d6:	8552                	mv	a0,s4
    800032d8:	00000097          	auipc	ra,0x0
    800032dc:	ce6080e7          	jalr	-794(ra) # 80002fbe <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032e0:	854e                	mv	a0,s3
    800032e2:	70a2                	ld	ra,40(sp)
    800032e4:	7402                	ld	s0,32(sp)
    800032e6:	64e2                	ld	s1,24(sp)
    800032e8:	6942                	ld	s2,16(sp)
    800032ea:	69a2                	ld	s3,8(sp)
    800032ec:	6a02                	ld	s4,0(sp)
    800032ee:	6145                	addi	sp,sp,48
    800032f0:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800032f2:	02059493          	slli	s1,a1,0x20
    800032f6:	9081                	srli	s1,s1,0x20
    800032f8:	048a                	slli	s1,s1,0x2
    800032fa:	94aa                	add	s1,s1,a0
    800032fc:	0584a983          	lw	s3,88(s1)
    80003300:	fe0990e3          	bnez	s3,800032e0 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003304:	4108                	lw	a0,0(a0)
    80003306:	00000097          	auipc	ra,0x0
    8000330a:	e4a080e7          	jalr	-438(ra) # 80003150 <balloc>
    8000330e:	0005099b          	sext.w	s3,a0
    80003312:	0534ac23          	sw	s3,88(s1)
    80003316:	b7e9                	j	800032e0 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003318:	4108                	lw	a0,0(a0)
    8000331a:	00000097          	auipc	ra,0x0
    8000331e:	e36080e7          	jalr	-458(ra) # 80003150 <balloc>
    80003322:	0005059b          	sext.w	a1,a0
    80003326:	08b92423          	sw	a1,136(s2)
    8000332a:	b759                	j	800032b0 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000332c:	00092503          	lw	a0,0(s2)
    80003330:	00000097          	auipc	ra,0x0
    80003334:	e20080e7          	jalr	-480(ra) # 80003150 <balloc>
    80003338:	0005099b          	sext.w	s3,a0
    8000333c:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003340:	8552                	mv	a0,s4
    80003342:	00001097          	auipc	ra,0x1
    80003346:	fb0080e7          	jalr	-80(ra) # 800042f2 <log_write>
    8000334a:	b771                	j	800032d6 <bmap+0x54>
  panic("bmap: out of range");
    8000334c:	00005517          	auipc	a0,0x5
    80003350:	33450513          	addi	a0,a0,820 # 80008680 <userret+0x5f0>
    80003354:	ffffd097          	auipc	ra,0xffffd
    80003358:	1f4080e7          	jalr	500(ra) # 80000548 <panic>

000000008000335c <iget>:
{
    8000335c:	7179                	addi	sp,sp,-48
    8000335e:	f406                	sd	ra,40(sp)
    80003360:	f022                	sd	s0,32(sp)
    80003362:	ec26                	sd	s1,24(sp)
    80003364:	e84a                	sd	s2,16(sp)
    80003366:	e44e                	sd	s3,8(sp)
    80003368:	e052                	sd	s4,0(sp)
    8000336a:	1800                	addi	s0,sp,48
    8000336c:	89aa                	mv	s3,a0
    8000336e:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003370:	00025517          	auipc	a0,0x25
    80003374:	af050513          	addi	a0,a0,-1296 # 80027e60 <icache>
    80003378:	ffffd097          	auipc	ra,0xffffd
    8000337c:	796080e7          	jalr	1942(ra) # 80000b0e <acquire>
  empty = 0;
    80003380:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003382:	00025497          	auipc	s1,0x25
    80003386:	afe48493          	addi	s1,s1,-1282 # 80027e80 <icache+0x20>
    8000338a:	00026697          	auipc	a3,0x26
    8000338e:	71668693          	addi	a3,a3,1814 # 80029aa0 <log>
    80003392:	a039                	j	800033a0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003394:	02090b63          	beqz	s2,800033ca <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003398:	09048493          	addi	s1,s1,144
    8000339c:	02d48a63          	beq	s1,a3,800033d0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033a0:	449c                	lw	a5,8(s1)
    800033a2:	fef059e3          	blez	a5,80003394 <iget+0x38>
    800033a6:	4098                	lw	a4,0(s1)
    800033a8:	ff3716e3          	bne	a4,s3,80003394 <iget+0x38>
    800033ac:	40d8                	lw	a4,4(s1)
    800033ae:	ff4713e3          	bne	a4,s4,80003394 <iget+0x38>
      ip->ref++;
    800033b2:	2785                	addiw	a5,a5,1
    800033b4:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800033b6:	00025517          	auipc	a0,0x25
    800033ba:	aaa50513          	addi	a0,a0,-1366 # 80027e60 <icache>
    800033be:	ffffd097          	auipc	ra,0xffffd
    800033c2:	7c0080e7          	jalr	1984(ra) # 80000b7e <release>
      return ip;
    800033c6:	8926                	mv	s2,s1
    800033c8:	a03d                	j	800033f6 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033ca:	f7f9                	bnez	a5,80003398 <iget+0x3c>
    800033cc:	8926                	mv	s2,s1
    800033ce:	b7e9                	j	80003398 <iget+0x3c>
  if(empty == 0)
    800033d0:	02090c63          	beqz	s2,80003408 <iget+0xac>
  ip->dev = dev;
    800033d4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033d8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033dc:	4785                	li	a5,1
    800033de:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033e2:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    800033e6:	00025517          	auipc	a0,0x25
    800033ea:	a7a50513          	addi	a0,a0,-1414 # 80027e60 <icache>
    800033ee:	ffffd097          	auipc	ra,0xffffd
    800033f2:	790080e7          	jalr	1936(ra) # 80000b7e <release>
}
    800033f6:	854a                	mv	a0,s2
    800033f8:	70a2                	ld	ra,40(sp)
    800033fa:	7402                	ld	s0,32(sp)
    800033fc:	64e2                	ld	s1,24(sp)
    800033fe:	6942                	ld	s2,16(sp)
    80003400:	69a2                	ld	s3,8(sp)
    80003402:	6a02                	ld	s4,0(sp)
    80003404:	6145                	addi	sp,sp,48
    80003406:	8082                	ret
    panic("iget: no inodes");
    80003408:	00005517          	auipc	a0,0x5
    8000340c:	29050513          	addi	a0,a0,656 # 80008698 <userret+0x608>
    80003410:	ffffd097          	auipc	ra,0xffffd
    80003414:	138080e7          	jalr	312(ra) # 80000548 <panic>

0000000080003418 <fsinit>:
fsinit(int dev) {
    80003418:	7179                	addi	sp,sp,-48
    8000341a:	f406                	sd	ra,40(sp)
    8000341c:	f022                	sd	s0,32(sp)
    8000341e:	ec26                	sd	s1,24(sp)
    80003420:	e84a                	sd	s2,16(sp)
    80003422:	e44e                	sd	s3,8(sp)
    80003424:	1800                	addi	s0,sp,48
    80003426:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003428:	4585                	li	a1,1
    8000342a:	00000097          	auipc	ra,0x0
    8000342e:	a60080e7          	jalr	-1440(ra) # 80002e8a <bread>
    80003432:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003434:	00025997          	auipc	s3,0x25
    80003438:	a0c98993          	addi	s3,s3,-1524 # 80027e40 <sb>
    8000343c:	02000613          	li	a2,32
    80003440:	06050593          	addi	a1,a0,96
    80003444:	854e                	mv	a0,s3
    80003446:	ffffe097          	auipc	ra,0xffffe
    8000344a:	98e080e7          	jalr	-1650(ra) # 80000dd4 <memmove>
  brelse(bp);
    8000344e:	8526                	mv	a0,s1
    80003450:	00000097          	auipc	ra,0x0
    80003454:	b6e080e7          	jalr	-1170(ra) # 80002fbe <brelse>
  if(sb.magic != FSMAGIC)
    80003458:	0009a703          	lw	a4,0(s3)
    8000345c:	102037b7          	lui	a5,0x10203
    80003460:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003464:	02f71263          	bne	a4,a5,80003488 <fsinit+0x70>
  initlog(dev, &sb);
    80003468:	00025597          	auipc	a1,0x25
    8000346c:	9d858593          	addi	a1,a1,-1576 # 80027e40 <sb>
    80003470:	854a                	mv	a0,s2
    80003472:	00001097          	auipc	ra,0x1
    80003476:	bfa080e7          	jalr	-1030(ra) # 8000406c <initlog>
}
    8000347a:	70a2                	ld	ra,40(sp)
    8000347c:	7402                	ld	s0,32(sp)
    8000347e:	64e2                	ld	s1,24(sp)
    80003480:	6942                	ld	s2,16(sp)
    80003482:	69a2                	ld	s3,8(sp)
    80003484:	6145                	addi	sp,sp,48
    80003486:	8082                	ret
    panic("invalid file system");
    80003488:	00005517          	auipc	a0,0x5
    8000348c:	22050513          	addi	a0,a0,544 # 800086a8 <userret+0x618>
    80003490:	ffffd097          	auipc	ra,0xffffd
    80003494:	0b8080e7          	jalr	184(ra) # 80000548 <panic>

0000000080003498 <iinit>:
{
    80003498:	7179                	addi	sp,sp,-48
    8000349a:	f406                	sd	ra,40(sp)
    8000349c:	f022                	sd	s0,32(sp)
    8000349e:	ec26                	sd	s1,24(sp)
    800034a0:	e84a                	sd	s2,16(sp)
    800034a2:	e44e                	sd	s3,8(sp)
    800034a4:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800034a6:	00005597          	auipc	a1,0x5
    800034aa:	21a58593          	addi	a1,a1,538 # 800086c0 <userret+0x630>
    800034ae:	00025517          	auipc	a0,0x25
    800034b2:	9b250513          	addi	a0,a0,-1614 # 80027e60 <icache>
    800034b6:	ffffd097          	auipc	ra,0xffffd
    800034ba:	50a080e7          	jalr	1290(ra) # 800009c0 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034be:	00025497          	auipc	s1,0x25
    800034c2:	9d248493          	addi	s1,s1,-1582 # 80027e90 <icache+0x30>
    800034c6:	00026997          	auipc	s3,0x26
    800034ca:	5ea98993          	addi	s3,s3,1514 # 80029ab0 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800034ce:	00005917          	auipc	s2,0x5
    800034d2:	1fa90913          	addi	s2,s2,506 # 800086c8 <userret+0x638>
    800034d6:	85ca                	mv	a1,s2
    800034d8:	8526                	mv	a0,s1
    800034da:	00001097          	auipc	ra,0x1
    800034de:	076080e7          	jalr	118(ra) # 80004550 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034e2:	09048493          	addi	s1,s1,144
    800034e6:	ff3498e3          	bne	s1,s3,800034d6 <iinit+0x3e>
}
    800034ea:	70a2                	ld	ra,40(sp)
    800034ec:	7402                	ld	s0,32(sp)
    800034ee:	64e2                	ld	s1,24(sp)
    800034f0:	6942                	ld	s2,16(sp)
    800034f2:	69a2                	ld	s3,8(sp)
    800034f4:	6145                	addi	sp,sp,48
    800034f6:	8082                	ret

00000000800034f8 <ialloc>:
{
    800034f8:	715d                	addi	sp,sp,-80
    800034fa:	e486                	sd	ra,72(sp)
    800034fc:	e0a2                	sd	s0,64(sp)
    800034fe:	fc26                	sd	s1,56(sp)
    80003500:	f84a                	sd	s2,48(sp)
    80003502:	f44e                	sd	s3,40(sp)
    80003504:	f052                	sd	s4,32(sp)
    80003506:	ec56                	sd	s5,24(sp)
    80003508:	e85a                	sd	s6,16(sp)
    8000350a:	e45e                	sd	s7,8(sp)
    8000350c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000350e:	00025717          	auipc	a4,0x25
    80003512:	93e72703          	lw	a4,-1730(a4) # 80027e4c <sb+0xc>
    80003516:	4785                	li	a5,1
    80003518:	04e7fa63          	bgeu	a5,a4,8000356c <ialloc+0x74>
    8000351c:	8aaa                	mv	s5,a0
    8000351e:	8bae                	mv	s7,a1
    80003520:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003522:	00025a17          	auipc	s4,0x25
    80003526:	91ea0a13          	addi	s4,s4,-1762 # 80027e40 <sb>
    8000352a:	00048b1b          	sext.w	s6,s1
    8000352e:	0044d793          	srli	a5,s1,0x4
    80003532:	018a2583          	lw	a1,24(s4)
    80003536:	9dbd                	addw	a1,a1,a5
    80003538:	8556                	mv	a0,s5
    8000353a:	00000097          	auipc	ra,0x0
    8000353e:	950080e7          	jalr	-1712(ra) # 80002e8a <bread>
    80003542:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003544:	06050993          	addi	s3,a0,96
    80003548:	00f4f793          	andi	a5,s1,15
    8000354c:	079a                	slli	a5,a5,0x6
    8000354e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003550:	00099783          	lh	a5,0(s3)
    80003554:	c785                	beqz	a5,8000357c <ialloc+0x84>
    brelse(bp);
    80003556:	00000097          	auipc	ra,0x0
    8000355a:	a68080e7          	jalr	-1432(ra) # 80002fbe <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000355e:	0485                	addi	s1,s1,1
    80003560:	00ca2703          	lw	a4,12(s4)
    80003564:	0004879b          	sext.w	a5,s1
    80003568:	fce7e1e3          	bltu	a5,a4,8000352a <ialloc+0x32>
  panic("ialloc: no inodes");
    8000356c:	00005517          	auipc	a0,0x5
    80003570:	16450513          	addi	a0,a0,356 # 800086d0 <userret+0x640>
    80003574:	ffffd097          	auipc	ra,0xffffd
    80003578:	fd4080e7          	jalr	-44(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    8000357c:	04000613          	li	a2,64
    80003580:	4581                	li	a1,0
    80003582:	854e                	mv	a0,s3
    80003584:	ffffd097          	auipc	ra,0xffffd
    80003588:	7f4080e7          	jalr	2036(ra) # 80000d78 <memset>
      dip->type = type;
    8000358c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003590:	854a                	mv	a0,s2
    80003592:	00001097          	auipc	ra,0x1
    80003596:	d60080e7          	jalr	-672(ra) # 800042f2 <log_write>
      brelse(bp);
    8000359a:	854a                	mv	a0,s2
    8000359c:	00000097          	auipc	ra,0x0
    800035a0:	a22080e7          	jalr	-1502(ra) # 80002fbe <brelse>
      return iget(dev, inum);
    800035a4:	85da                	mv	a1,s6
    800035a6:	8556                	mv	a0,s5
    800035a8:	00000097          	auipc	ra,0x0
    800035ac:	db4080e7          	jalr	-588(ra) # 8000335c <iget>
}
    800035b0:	60a6                	ld	ra,72(sp)
    800035b2:	6406                	ld	s0,64(sp)
    800035b4:	74e2                	ld	s1,56(sp)
    800035b6:	7942                	ld	s2,48(sp)
    800035b8:	79a2                	ld	s3,40(sp)
    800035ba:	7a02                	ld	s4,32(sp)
    800035bc:	6ae2                	ld	s5,24(sp)
    800035be:	6b42                	ld	s6,16(sp)
    800035c0:	6ba2                	ld	s7,8(sp)
    800035c2:	6161                	addi	sp,sp,80
    800035c4:	8082                	ret

00000000800035c6 <iupdate>:
{
    800035c6:	1101                	addi	sp,sp,-32
    800035c8:	ec06                	sd	ra,24(sp)
    800035ca:	e822                	sd	s0,16(sp)
    800035cc:	e426                	sd	s1,8(sp)
    800035ce:	e04a                	sd	s2,0(sp)
    800035d0:	1000                	addi	s0,sp,32
    800035d2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035d4:	415c                	lw	a5,4(a0)
    800035d6:	0047d79b          	srliw	a5,a5,0x4
    800035da:	00025597          	auipc	a1,0x25
    800035de:	87e5a583          	lw	a1,-1922(a1) # 80027e58 <sb+0x18>
    800035e2:	9dbd                	addw	a1,a1,a5
    800035e4:	4108                	lw	a0,0(a0)
    800035e6:	00000097          	auipc	ra,0x0
    800035ea:	8a4080e7          	jalr	-1884(ra) # 80002e8a <bread>
    800035ee:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035f0:	06050793          	addi	a5,a0,96
    800035f4:	40c8                	lw	a0,4(s1)
    800035f6:	893d                	andi	a0,a0,15
    800035f8:	051a                	slli	a0,a0,0x6
    800035fa:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800035fc:	04c49703          	lh	a4,76(s1)
    80003600:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003604:	04e49703          	lh	a4,78(s1)
    80003608:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000360c:	05049703          	lh	a4,80(s1)
    80003610:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003614:	05249703          	lh	a4,82(s1)
    80003618:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000361c:	48f8                	lw	a4,84(s1)
    8000361e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003620:	03400613          	li	a2,52
    80003624:	05848593          	addi	a1,s1,88
    80003628:	0531                	addi	a0,a0,12
    8000362a:	ffffd097          	auipc	ra,0xffffd
    8000362e:	7aa080e7          	jalr	1962(ra) # 80000dd4 <memmove>
  log_write(bp);
    80003632:	854a                	mv	a0,s2
    80003634:	00001097          	auipc	ra,0x1
    80003638:	cbe080e7          	jalr	-834(ra) # 800042f2 <log_write>
  brelse(bp);
    8000363c:	854a                	mv	a0,s2
    8000363e:	00000097          	auipc	ra,0x0
    80003642:	980080e7          	jalr	-1664(ra) # 80002fbe <brelse>
}
    80003646:	60e2                	ld	ra,24(sp)
    80003648:	6442                	ld	s0,16(sp)
    8000364a:	64a2                	ld	s1,8(sp)
    8000364c:	6902                	ld	s2,0(sp)
    8000364e:	6105                	addi	sp,sp,32
    80003650:	8082                	ret

0000000080003652 <idup>:
{
    80003652:	1101                	addi	sp,sp,-32
    80003654:	ec06                	sd	ra,24(sp)
    80003656:	e822                	sd	s0,16(sp)
    80003658:	e426                	sd	s1,8(sp)
    8000365a:	1000                	addi	s0,sp,32
    8000365c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000365e:	00025517          	auipc	a0,0x25
    80003662:	80250513          	addi	a0,a0,-2046 # 80027e60 <icache>
    80003666:	ffffd097          	auipc	ra,0xffffd
    8000366a:	4a8080e7          	jalr	1192(ra) # 80000b0e <acquire>
  ip->ref++;
    8000366e:	449c                	lw	a5,8(s1)
    80003670:	2785                	addiw	a5,a5,1
    80003672:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003674:	00024517          	auipc	a0,0x24
    80003678:	7ec50513          	addi	a0,a0,2028 # 80027e60 <icache>
    8000367c:	ffffd097          	auipc	ra,0xffffd
    80003680:	502080e7          	jalr	1282(ra) # 80000b7e <release>
}
    80003684:	8526                	mv	a0,s1
    80003686:	60e2                	ld	ra,24(sp)
    80003688:	6442                	ld	s0,16(sp)
    8000368a:	64a2                	ld	s1,8(sp)
    8000368c:	6105                	addi	sp,sp,32
    8000368e:	8082                	ret

0000000080003690 <ilock>:
{
    80003690:	1101                	addi	sp,sp,-32
    80003692:	ec06                	sd	ra,24(sp)
    80003694:	e822                	sd	s0,16(sp)
    80003696:	e426                	sd	s1,8(sp)
    80003698:	e04a                	sd	s2,0(sp)
    8000369a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000369c:	c115                	beqz	a0,800036c0 <ilock+0x30>
    8000369e:	84aa                	mv	s1,a0
    800036a0:	451c                	lw	a5,8(a0)
    800036a2:	00f05f63          	blez	a5,800036c0 <ilock+0x30>
  acquiresleep(&ip->lock);
    800036a6:	0541                	addi	a0,a0,16
    800036a8:	00001097          	auipc	ra,0x1
    800036ac:	ee2080e7          	jalr	-286(ra) # 8000458a <acquiresleep>
  if(ip->valid == 0){
    800036b0:	44bc                	lw	a5,72(s1)
    800036b2:	cf99                	beqz	a5,800036d0 <ilock+0x40>
}
    800036b4:	60e2                	ld	ra,24(sp)
    800036b6:	6442                	ld	s0,16(sp)
    800036b8:	64a2                	ld	s1,8(sp)
    800036ba:	6902                	ld	s2,0(sp)
    800036bc:	6105                	addi	sp,sp,32
    800036be:	8082                	ret
    panic("ilock");
    800036c0:	00005517          	auipc	a0,0x5
    800036c4:	02850513          	addi	a0,a0,40 # 800086e8 <userret+0x658>
    800036c8:	ffffd097          	auipc	ra,0xffffd
    800036cc:	e80080e7          	jalr	-384(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036d0:	40dc                	lw	a5,4(s1)
    800036d2:	0047d79b          	srliw	a5,a5,0x4
    800036d6:	00024597          	auipc	a1,0x24
    800036da:	7825a583          	lw	a1,1922(a1) # 80027e58 <sb+0x18>
    800036de:	9dbd                	addw	a1,a1,a5
    800036e0:	4088                	lw	a0,0(s1)
    800036e2:	fffff097          	auipc	ra,0xfffff
    800036e6:	7a8080e7          	jalr	1960(ra) # 80002e8a <bread>
    800036ea:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036ec:	06050593          	addi	a1,a0,96
    800036f0:	40dc                	lw	a5,4(s1)
    800036f2:	8bbd                	andi	a5,a5,15
    800036f4:	079a                	slli	a5,a5,0x6
    800036f6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036f8:	00059783          	lh	a5,0(a1)
    800036fc:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003700:	00259783          	lh	a5,2(a1)
    80003704:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003708:	00459783          	lh	a5,4(a1)
    8000370c:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003710:	00659783          	lh	a5,6(a1)
    80003714:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003718:	459c                	lw	a5,8(a1)
    8000371a:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000371c:	03400613          	li	a2,52
    80003720:	05b1                	addi	a1,a1,12
    80003722:	05848513          	addi	a0,s1,88
    80003726:	ffffd097          	auipc	ra,0xffffd
    8000372a:	6ae080e7          	jalr	1710(ra) # 80000dd4 <memmove>
    brelse(bp);
    8000372e:	854a                	mv	a0,s2
    80003730:	00000097          	auipc	ra,0x0
    80003734:	88e080e7          	jalr	-1906(ra) # 80002fbe <brelse>
    ip->valid = 1;
    80003738:	4785                	li	a5,1
    8000373a:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    8000373c:	04c49783          	lh	a5,76(s1)
    80003740:	fbb5                	bnez	a5,800036b4 <ilock+0x24>
      panic("ilock: no type");
    80003742:	00005517          	auipc	a0,0x5
    80003746:	fae50513          	addi	a0,a0,-82 # 800086f0 <userret+0x660>
    8000374a:	ffffd097          	auipc	ra,0xffffd
    8000374e:	dfe080e7          	jalr	-514(ra) # 80000548 <panic>

0000000080003752 <iunlock>:
{
    80003752:	1101                	addi	sp,sp,-32
    80003754:	ec06                	sd	ra,24(sp)
    80003756:	e822                	sd	s0,16(sp)
    80003758:	e426                	sd	s1,8(sp)
    8000375a:	e04a                	sd	s2,0(sp)
    8000375c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000375e:	c905                	beqz	a0,8000378e <iunlock+0x3c>
    80003760:	84aa                	mv	s1,a0
    80003762:	01050913          	addi	s2,a0,16
    80003766:	854a                	mv	a0,s2
    80003768:	00001097          	auipc	ra,0x1
    8000376c:	ebc080e7          	jalr	-324(ra) # 80004624 <holdingsleep>
    80003770:	cd19                	beqz	a0,8000378e <iunlock+0x3c>
    80003772:	449c                	lw	a5,8(s1)
    80003774:	00f05d63          	blez	a5,8000378e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003778:	854a                	mv	a0,s2
    8000377a:	00001097          	auipc	ra,0x1
    8000377e:	e66080e7          	jalr	-410(ra) # 800045e0 <releasesleep>
}
    80003782:	60e2                	ld	ra,24(sp)
    80003784:	6442                	ld	s0,16(sp)
    80003786:	64a2                	ld	s1,8(sp)
    80003788:	6902                	ld	s2,0(sp)
    8000378a:	6105                	addi	sp,sp,32
    8000378c:	8082                	ret
    panic("iunlock");
    8000378e:	00005517          	auipc	a0,0x5
    80003792:	f7250513          	addi	a0,a0,-142 # 80008700 <userret+0x670>
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	db2080e7          	jalr	-590(ra) # 80000548 <panic>

000000008000379e <iput>:
{
    8000379e:	7139                	addi	sp,sp,-64
    800037a0:	fc06                	sd	ra,56(sp)
    800037a2:	f822                	sd	s0,48(sp)
    800037a4:	f426                	sd	s1,40(sp)
    800037a6:	f04a                	sd	s2,32(sp)
    800037a8:	ec4e                	sd	s3,24(sp)
    800037aa:	e852                	sd	s4,16(sp)
    800037ac:	e456                	sd	s5,8(sp)
    800037ae:	0080                	addi	s0,sp,64
    800037b0:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800037b2:	00024517          	auipc	a0,0x24
    800037b6:	6ae50513          	addi	a0,a0,1710 # 80027e60 <icache>
    800037ba:	ffffd097          	auipc	ra,0xffffd
    800037be:	354080e7          	jalr	852(ra) # 80000b0e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037c2:	4498                	lw	a4,8(s1)
    800037c4:	4785                	li	a5,1
    800037c6:	02f70663          	beq	a4,a5,800037f2 <iput+0x54>
  ip->ref--;
    800037ca:	449c                	lw	a5,8(s1)
    800037cc:	37fd                	addiw	a5,a5,-1
    800037ce:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800037d0:	00024517          	auipc	a0,0x24
    800037d4:	69050513          	addi	a0,a0,1680 # 80027e60 <icache>
    800037d8:	ffffd097          	auipc	ra,0xffffd
    800037dc:	3a6080e7          	jalr	934(ra) # 80000b7e <release>
}
    800037e0:	70e2                	ld	ra,56(sp)
    800037e2:	7442                	ld	s0,48(sp)
    800037e4:	74a2                	ld	s1,40(sp)
    800037e6:	7902                	ld	s2,32(sp)
    800037e8:	69e2                	ld	s3,24(sp)
    800037ea:	6a42                	ld	s4,16(sp)
    800037ec:	6aa2                	ld	s5,8(sp)
    800037ee:	6121                	addi	sp,sp,64
    800037f0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037f2:	44bc                	lw	a5,72(s1)
    800037f4:	dbf9                	beqz	a5,800037ca <iput+0x2c>
    800037f6:	05249783          	lh	a5,82(s1)
    800037fa:	fbe1                	bnez	a5,800037ca <iput+0x2c>
    acquiresleep(&ip->lock);
    800037fc:	01048a13          	addi	s4,s1,16
    80003800:	8552                	mv	a0,s4
    80003802:	00001097          	auipc	ra,0x1
    80003806:	d88080e7          	jalr	-632(ra) # 8000458a <acquiresleep>
    release(&icache.lock);
    8000380a:	00024517          	auipc	a0,0x24
    8000380e:	65650513          	addi	a0,a0,1622 # 80027e60 <icache>
    80003812:	ffffd097          	auipc	ra,0xffffd
    80003816:	36c080e7          	jalr	876(ra) # 80000b7e <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000381a:	05848913          	addi	s2,s1,88
    8000381e:	08848993          	addi	s3,s1,136
    80003822:	a021                	j	8000382a <iput+0x8c>
    80003824:	0911                	addi	s2,s2,4
    80003826:	01390d63          	beq	s2,s3,80003840 <iput+0xa2>
    if(ip->addrs[i]){
    8000382a:	00092583          	lw	a1,0(s2)
    8000382e:	d9fd                	beqz	a1,80003824 <iput+0x86>
      bfree(ip->dev, ip->addrs[i]);
    80003830:	4088                	lw	a0,0(s1)
    80003832:	00000097          	auipc	ra,0x0
    80003836:	8a2080e7          	jalr	-1886(ra) # 800030d4 <bfree>
      ip->addrs[i] = 0;
    8000383a:	00092023          	sw	zero,0(s2)
    8000383e:	b7dd                	j	80003824 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003840:	0884a583          	lw	a1,136(s1)
    80003844:	ed9d                	bnez	a1,80003882 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003846:	0404aa23          	sw	zero,84(s1)
  iupdate(ip);
    8000384a:	8526                	mv	a0,s1
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	d7a080e7          	jalr	-646(ra) # 800035c6 <iupdate>
    ip->type = 0;
    80003854:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003858:	8526                	mv	a0,s1
    8000385a:	00000097          	auipc	ra,0x0
    8000385e:	d6c080e7          	jalr	-660(ra) # 800035c6 <iupdate>
    ip->valid = 0;
    80003862:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003866:	8552                	mv	a0,s4
    80003868:	00001097          	auipc	ra,0x1
    8000386c:	d78080e7          	jalr	-648(ra) # 800045e0 <releasesleep>
    acquire(&icache.lock);
    80003870:	00024517          	auipc	a0,0x24
    80003874:	5f050513          	addi	a0,a0,1520 # 80027e60 <icache>
    80003878:	ffffd097          	auipc	ra,0xffffd
    8000387c:	296080e7          	jalr	662(ra) # 80000b0e <acquire>
    80003880:	b7a9                	j	800037ca <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003882:	4088                	lw	a0,0(s1)
    80003884:	fffff097          	auipc	ra,0xfffff
    80003888:	606080e7          	jalr	1542(ra) # 80002e8a <bread>
    8000388c:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    8000388e:	06050913          	addi	s2,a0,96
    80003892:	46050993          	addi	s3,a0,1120
    80003896:	a021                	j	8000389e <iput+0x100>
    80003898:	0911                	addi	s2,s2,4
    8000389a:	01390b63          	beq	s2,s3,800038b0 <iput+0x112>
      if(a[j])
    8000389e:	00092583          	lw	a1,0(s2)
    800038a2:	d9fd                	beqz	a1,80003898 <iput+0xfa>
        bfree(ip->dev, a[j]);
    800038a4:	4088                	lw	a0,0(s1)
    800038a6:	00000097          	auipc	ra,0x0
    800038aa:	82e080e7          	jalr	-2002(ra) # 800030d4 <bfree>
    800038ae:	b7ed                	j	80003898 <iput+0xfa>
    brelse(bp);
    800038b0:	8556                	mv	a0,s5
    800038b2:	fffff097          	auipc	ra,0xfffff
    800038b6:	70c080e7          	jalr	1804(ra) # 80002fbe <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038ba:	0884a583          	lw	a1,136(s1)
    800038be:	4088                	lw	a0,0(s1)
    800038c0:	00000097          	auipc	ra,0x0
    800038c4:	814080e7          	jalr	-2028(ra) # 800030d4 <bfree>
    ip->addrs[NDIRECT] = 0;
    800038c8:	0804a423          	sw	zero,136(s1)
    800038cc:	bfad                	j	80003846 <iput+0xa8>

00000000800038ce <iunlockput>:
{
    800038ce:	1101                	addi	sp,sp,-32
    800038d0:	ec06                	sd	ra,24(sp)
    800038d2:	e822                	sd	s0,16(sp)
    800038d4:	e426                	sd	s1,8(sp)
    800038d6:	1000                	addi	s0,sp,32
    800038d8:	84aa                	mv	s1,a0
  iunlock(ip);
    800038da:	00000097          	auipc	ra,0x0
    800038de:	e78080e7          	jalr	-392(ra) # 80003752 <iunlock>
  iput(ip);
    800038e2:	8526                	mv	a0,s1
    800038e4:	00000097          	auipc	ra,0x0
    800038e8:	eba080e7          	jalr	-326(ra) # 8000379e <iput>
}
    800038ec:	60e2                	ld	ra,24(sp)
    800038ee:	6442                	ld	s0,16(sp)
    800038f0:	64a2                	ld	s1,8(sp)
    800038f2:	6105                	addi	sp,sp,32
    800038f4:	8082                	ret

00000000800038f6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038f6:	1141                	addi	sp,sp,-16
    800038f8:	e422                	sd	s0,8(sp)
    800038fa:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038fc:	411c                	lw	a5,0(a0)
    800038fe:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003900:	415c                	lw	a5,4(a0)
    80003902:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003904:	04c51783          	lh	a5,76(a0)
    80003908:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000390c:	05251783          	lh	a5,82(a0)
    80003910:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003914:	05456783          	lwu	a5,84(a0)
    80003918:	e99c                	sd	a5,16(a1)
}
    8000391a:	6422                	ld	s0,8(sp)
    8000391c:	0141                	addi	sp,sp,16
    8000391e:	8082                	ret

0000000080003920 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003920:	497c                	lw	a5,84(a0)
    80003922:	0ed7e563          	bltu	a5,a3,80003a0c <readi+0xec>
{
    80003926:	7159                	addi	sp,sp,-112
    80003928:	f486                	sd	ra,104(sp)
    8000392a:	f0a2                	sd	s0,96(sp)
    8000392c:	eca6                	sd	s1,88(sp)
    8000392e:	e8ca                	sd	s2,80(sp)
    80003930:	e4ce                	sd	s3,72(sp)
    80003932:	e0d2                	sd	s4,64(sp)
    80003934:	fc56                	sd	s5,56(sp)
    80003936:	f85a                	sd	s6,48(sp)
    80003938:	f45e                	sd	s7,40(sp)
    8000393a:	f062                	sd	s8,32(sp)
    8000393c:	ec66                	sd	s9,24(sp)
    8000393e:	e86a                	sd	s10,16(sp)
    80003940:	e46e                	sd	s11,8(sp)
    80003942:	1880                	addi	s0,sp,112
    80003944:	8baa                	mv	s7,a0
    80003946:	8c2e                	mv	s8,a1
    80003948:	8ab2                	mv	s5,a2
    8000394a:	8936                	mv	s2,a3
    8000394c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000394e:	9f35                	addw	a4,a4,a3
    80003950:	0cd76063          	bltu	a4,a3,80003a10 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    80003954:	00e7f463          	bgeu	a5,a4,8000395c <readi+0x3c>
    n = ip->size - off;
    80003958:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000395c:	080b0763          	beqz	s6,800039ea <readi+0xca>
    80003960:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003962:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003966:	5cfd                	li	s9,-1
    80003968:	a82d                	j	800039a2 <readi+0x82>
    8000396a:	02099d93          	slli	s11,s3,0x20
    8000396e:	020ddd93          	srli	s11,s11,0x20
    80003972:	06048793          	addi	a5,s1,96
    80003976:	86ee                	mv	a3,s11
    80003978:	963e                	add	a2,a2,a5
    8000397a:	85d6                	mv	a1,s5
    8000397c:	8562                	mv	a0,s8
    8000397e:	fffff097          	auipc	ra,0xfffff
    80003982:	b22080e7          	jalr	-1246(ra) # 800024a0 <either_copyout>
    80003986:	05950d63          	beq	a0,s9,800039e0 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    8000398a:	8526                	mv	a0,s1
    8000398c:	fffff097          	auipc	ra,0xfffff
    80003990:	632080e7          	jalr	1586(ra) # 80002fbe <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003994:	01498a3b          	addw	s4,s3,s4
    80003998:	0129893b          	addw	s2,s3,s2
    8000399c:	9aee                	add	s5,s5,s11
    8000399e:	056a7663          	bgeu	s4,s6,800039ea <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800039a2:	000ba483          	lw	s1,0(s7)
    800039a6:	00a9559b          	srliw	a1,s2,0xa
    800039aa:	855e                	mv	a0,s7
    800039ac:	00000097          	auipc	ra,0x0
    800039b0:	8d6080e7          	jalr	-1834(ra) # 80003282 <bmap>
    800039b4:	0005059b          	sext.w	a1,a0
    800039b8:	8526                	mv	a0,s1
    800039ba:	fffff097          	auipc	ra,0xfffff
    800039be:	4d0080e7          	jalr	1232(ra) # 80002e8a <bread>
    800039c2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039c4:	3ff97613          	andi	a2,s2,1023
    800039c8:	40cd07bb          	subw	a5,s10,a2
    800039cc:	414b073b          	subw	a4,s6,s4
    800039d0:	89be                	mv	s3,a5
    800039d2:	2781                	sext.w	a5,a5
    800039d4:	0007069b          	sext.w	a3,a4
    800039d8:	f8f6f9e3          	bgeu	a3,a5,8000396a <readi+0x4a>
    800039dc:	89ba                	mv	s3,a4
    800039de:	b771                	j	8000396a <readi+0x4a>
      brelse(bp);
    800039e0:	8526                	mv	a0,s1
    800039e2:	fffff097          	auipc	ra,0xfffff
    800039e6:	5dc080e7          	jalr	1500(ra) # 80002fbe <brelse>
  }
  return n;
    800039ea:	000b051b          	sext.w	a0,s6
}
    800039ee:	70a6                	ld	ra,104(sp)
    800039f0:	7406                	ld	s0,96(sp)
    800039f2:	64e6                	ld	s1,88(sp)
    800039f4:	6946                	ld	s2,80(sp)
    800039f6:	69a6                	ld	s3,72(sp)
    800039f8:	6a06                	ld	s4,64(sp)
    800039fa:	7ae2                	ld	s5,56(sp)
    800039fc:	7b42                	ld	s6,48(sp)
    800039fe:	7ba2                	ld	s7,40(sp)
    80003a00:	7c02                	ld	s8,32(sp)
    80003a02:	6ce2                	ld	s9,24(sp)
    80003a04:	6d42                	ld	s10,16(sp)
    80003a06:	6da2                	ld	s11,8(sp)
    80003a08:	6165                	addi	sp,sp,112
    80003a0a:	8082                	ret
    return -1;
    80003a0c:	557d                	li	a0,-1
}
    80003a0e:	8082                	ret
    return -1;
    80003a10:	557d                	li	a0,-1
    80003a12:	bff1                	j	800039ee <readi+0xce>

0000000080003a14 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a14:	497c                	lw	a5,84(a0)
    80003a16:	10d7e663          	bltu	a5,a3,80003b22 <writei+0x10e>
{
    80003a1a:	7159                	addi	sp,sp,-112
    80003a1c:	f486                	sd	ra,104(sp)
    80003a1e:	f0a2                	sd	s0,96(sp)
    80003a20:	eca6                	sd	s1,88(sp)
    80003a22:	e8ca                	sd	s2,80(sp)
    80003a24:	e4ce                	sd	s3,72(sp)
    80003a26:	e0d2                	sd	s4,64(sp)
    80003a28:	fc56                	sd	s5,56(sp)
    80003a2a:	f85a                	sd	s6,48(sp)
    80003a2c:	f45e                	sd	s7,40(sp)
    80003a2e:	f062                	sd	s8,32(sp)
    80003a30:	ec66                	sd	s9,24(sp)
    80003a32:	e86a                	sd	s10,16(sp)
    80003a34:	e46e                	sd	s11,8(sp)
    80003a36:	1880                	addi	s0,sp,112
    80003a38:	8baa                	mv	s7,a0
    80003a3a:	8c2e                	mv	s8,a1
    80003a3c:	8ab2                	mv	s5,a2
    80003a3e:	8936                	mv	s2,a3
    80003a40:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a42:	00e687bb          	addw	a5,a3,a4
    80003a46:	0ed7e063          	bltu	a5,a3,80003b26 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a4a:	00043737          	lui	a4,0x43
    80003a4e:	0cf76e63          	bltu	a4,a5,80003b2a <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a52:	0a0b0763          	beqz	s6,80003b00 <writei+0xec>
    80003a56:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a58:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a5c:	5cfd                	li	s9,-1
    80003a5e:	a091                	j	80003aa2 <writei+0x8e>
    80003a60:	02099d93          	slli	s11,s3,0x20
    80003a64:	020ddd93          	srli	s11,s11,0x20
    80003a68:	06048793          	addi	a5,s1,96
    80003a6c:	86ee                	mv	a3,s11
    80003a6e:	8656                	mv	a2,s5
    80003a70:	85e2                	mv	a1,s8
    80003a72:	953e                	add	a0,a0,a5
    80003a74:	fffff097          	auipc	ra,0xfffff
    80003a78:	a82080e7          	jalr	-1406(ra) # 800024f6 <either_copyin>
    80003a7c:	07950263          	beq	a0,s9,80003ae0 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a80:	8526                	mv	a0,s1
    80003a82:	00001097          	auipc	ra,0x1
    80003a86:	870080e7          	jalr	-1936(ra) # 800042f2 <log_write>
    brelse(bp);
    80003a8a:	8526                	mv	a0,s1
    80003a8c:	fffff097          	auipc	ra,0xfffff
    80003a90:	532080e7          	jalr	1330(ra) # 80002fbe <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a94:	01498a3b          	addw	s4,s3,s4
    80003a98:	0129893b          	addw	s2,s3,s2
    80003a9c:	9aee                	add	s5,s5,s11
    80003a9e:	056a7663          	bgeu	s4,s6,80003aea <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003aa2:	000ba483          	lw	s1,0(s7)
    80003aa6:	00a9559b          	srliw	a1,s2,0xa
    80003aaa:	855e                	mv	a0,s7
    80003aac:	fffff097          	auipc	ra,0xfffff
    80003ab0:	7d6080e7          	jalr	2006(ra) # 80003282 <bmap>
    80003ab4:	0005059b          	sext.w	a1,a0
    80003ab8:	8526                	mv	a0,s1
    80003aba:	fffff097          	auipc	ra,0xfffff
    80003abe:	3d0080e7          	jalr	976(ra) # 80002e8a <bread>
    80003ac2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ac4:	3ff97513          	andi	a0,s2,1023
    80003ac8:	40ad07bb          	subw	a5,s10,a0
    80003acc:	414b073b          	subw	a4,s6,s4
    80003ad0:	89be                	mv	s3,a5
    80003ad2:	2781                	sext.w	a5,a5
    80003ad4:	0007069b          	sext.w	a3,a4
    80003ad8:	f8f6f4e3          	bgeu	a3,a5,80003a60 <writei+0x4c>
    80003adc:	89ba                	mv	s3,a4
    80003ade:	b749                	j	80003a60 <writei+0x4c>
      brelse(bp);
    80003ae0:	8526                	mv	a0,s1
    80003ae2:	fffff097          	auipc	ra,0xfffff
    80003ae6:	4dc080e7          	jalr	1244(ra) # 80002fbe <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003aea:	054ba783          	lw	a5,84(s7)
    80003aee:	0127f463          	bgeu	a5,s2,80003af6 <writei+0xe2>
      ip->size = off;
    80003af2:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003af6:	855e                	mv	a0,s7
    80003af8:	00000097          	auipc	ra,0x0
    80003afc:	ace080e7          	jalr	-1330(ra) # 800035c6 <iupdate>
  }

  return n;
    80003b00:	000b051b          	sext.w	a0,s6
}
    80003b04:	70a6                	ld	ra,104(sp)
    80003b06:	7406                	ld	s0,96(sp)
    80003b08:	64e6                	ld	s1,88(sp)
    80003b0a:	6946                	ld	s2,80(sp)
    80003b0c:	69a6                	ld	s3,72(sp)
    80003b0e:	6a06                	ld	s4,64(sp)
    80003b10:	7ae2                	ld	s5,56(sp)
    80003b12:	7b42                	ld	s6,48(sp)
    80003b14:	7ba2                	ld	s7,40(sp)
    80003b16:	7c02                	ld	s8,32(sp)
    80003b18:	6ce2                	ld	s9,24(sp)
    80003b1a:	6d42                	ld	s10,16(sp)
    80003b1c:	6da2                	ld	s11,8(sp)
    80003b1e:	6165                	addi	sp,sp,112
    80003b20:	8082                	ret
    return -1;
    80003b22:	557d                	li	a0,-1
}
    80003b24:	8082                	ret
    return -1;
    80003b26:	557d                	li	a0,-1
    80003b28:	bff1                	j	80003b04 <writei+0xf0>
    return -1;
    80003b2a:	557d                	li	a0,-1
    80003b2c:	bfe1                	j	80003b04 <writei+0xf0>

0000000080003b2e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b2e:	1141                	addi	sp,sp,-16
    80003b30:	e406                	sd	ra,8(sp)
    80003b32:	e022                	sd	s0,0(sp)
    80003b34:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b36:	4639                	li	a2,14
    80003b38:	ffffd097          	auipc	ra,0xffffd
    80003b3c:	318080e7          	jalr	792(ra) # 80000e50 <strncmp>
}
    80003b40:	60a2                	ld	ra,8(sp)
    80003b42:	6402                	ld	s0,0(sp)
    80003b44:	0141                	addi	sp,sp,16
    80003b46:	8082                	ret

0000000080003b48 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b48:	7139                	addi	sp,sp,-64
    80003b4a:	fc06                	sd	ra,56(sp)
    80003b4c:	f822                	sd	s0,48(sp)
    80003b4e:	f426                	sd	s1,40(sp)
    80003b50:	f04a                	sd	s2,32(sp)
    80003b52:	ec4e                	sd	s3,24(sp)
    80003b54:	e852                	sd	s4,16(sp)
    80003b56:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b58:	04c51703          	lh	a4,76(a0)
    80003b5c:	4785                	li	a5,1
    80003b5e:	00f71a63          	bne	a4,a5,80003b72 <dirlookup+0x2a>
    80003b62:	892a                	mv	s2,a0
    80003b64:	89ae                	mv	s3,a1
    80003b66:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b68:	497c                	lw	a5,84(a0)
    80003b6a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b6c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b6e:	e79d                	bnez	a5,80003b9c <dirlookup+0x54>
    80003b70:	a8a5                	j	80003be8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b72:	00005517          	auipc	a0,0x5
    80003b76:	b9650513          	addi	a0,a0,-1130 # 80008708 <userret+0x678>
    80003b7a:	ffffd097          	auipc	ra,0xffffd
    80003b7e:	9ce080e7          	jalr	-1586(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003b82:	00005517          	auipc	a0,0x5
    80003b86:	b9e50513          	addi	a0,a0,-1122 # 80008720 <userret+0x690>
    80003b8a:	ffffd097          	auipc	ra,0xffffd
    80003b8e:	9be080e7          	jalr	-1602(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b92:	24c1                	addiw	s1,s1,16
    80003b94:	05492783          	lw	a5,84(s2)
    80003b98:	04f4f763          	bgeu	s1,a5,80003be6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b9c:	4741                	li	a4,16
    80003b9e:	86a6                	mv	a3,s1
    80003ba0:	fc040613          	addi	a2,s0,-64
    80003ba4:	4581                	li	a1,0
    80003ba6:	854a                	mv	a0,s2
    80003ba8:	00000097          	auipc	ra,0x0
    80003bac:	d78080e7          	jalr	-648(ra) # 80003920 <readi>
    80003bb0:	47c1                	li	a5,16
    80003bb2:	fcf518e3          	bne	a0,a5,80003b82 <dirlookup+0x3a>
    if(de.inum == 0)
    80003bb6:	fc045783          	lhu	a5,-64(s0)
    80003bba:	dfe1                	beqz	a5,80003b92 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003bbc:	fc240593          	addi	a1,s0,-62
    80003bc0:	854e                	mv	a0,s3
    80003bc2:	00000097          	auipc	ra,0x0
    80003bc6:	f6c080e7          	jalr	-148(ra) # 80003b2e <namecmp>
    80003bca:	f561                	bnez	a0,80003b92 <dirlookup+0x4a>
      if(poff)
    80003bcc:	000a0463          	beqz	s4,80003bd4 <dirlookup+0x8c>
        *poff = off;
    80003bd0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bd4:	fc045583          	lhu	a1,-64(s0)
    80003bd8:	00092503          	lw	a0,0(s2)
    80003bdc:	fffff097          	auipc	ra,0xfffff
    80003be0:	780080e7          	jalr	1920(ra) # 8000335c <iget>
    80003be4:	a011                	j	80003be8 <dirlookup+0xa0>
  return 0;
    80003be6:	4501                	li	a0,0
}
    80003be8:	70e2                	ld	ra,56(sp)
    80003bea:	7442                	ld	s0,48(sp)
    80003bec:	74a2                	ld	s1,40(sp)
    80003bee:	7902                	ld	s2,32(sp)
    80003bf0:	69e2                	ld	s3,24(sp)
    80003bf2:	6a42                	ld	s4,16(sp)
    80003bf4:	6121                	addi	sp,sp,64
    80003bf6:	8082                	ret

0000000080003bf8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003bf8:	711d                	addi	sp,sp,-96
    80003bfa:	ec86                	sd	ra,88(sp)
    80003bfc:	e8a2                	sd	s0,80(sp)
    80003bfe:	e4a6                	sd	s1,72(sp)
    80003c00:	e0ca                	sd	s2,64(sp)
    80003c02:	fc4e                	sd	s3,56(sp)
    80003c04:	f852                	sd	s4,48(sp)
    80003c06:	f456                	sd	s5,40(sp)
    80003c08:	f05a                	sd	s6,32(sp)
    80003c0a:	ec5e                	sd	s7,24(sp)
    80003c0c:	e862                	sd	s8,16(sp)
    80003c0e:	e466                	sd	s9,8(sp)
    80003c10:	1080                	addi	s0,sp,96
    80003c12:	84aa                	mv	s1,a0
    80003c14:	8aae                	mv	s5,a1
    80003c16:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c18:	00054703          	lbu	a4,0(a0)
    80003c1c:	02f00793          	li	a5,47
    80003c20:	02f70363          	beq	a4,a5,80003c46 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c24:	ffffe097          	auipc	ra,0xffffe
    80003c28:	e3e080e7          	jalr	-450(ra) # 80001a62 <myproc>
    80003c2c:	15853503          	ld	a0,344(a0)
    80003c30:	00000097          	auipc	ra,0x0
    80003c34:	a22080e7          	jalr	-1502(ra) # 80003652 <idup>
    80003c38:	89aa                	mv	s3,a0
  while(*path == '/')
    80003c3a:	02f00913          	li	s2,47
  len = path - s;
    80003c3e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003c40:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c42:	4b85                	li	s7,1
    80003c44:	a865                	j	80003cfc <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003c46:	4585                	li	a1,1
    80003c48:	4501                	li	a0,0
    80003c4a:	fffff097          	auipc	ra,0xfffff
    80003c4e:	712080e7          	jalr	1810(ra) # 8000335c <iget>
    80003c52:	89aa                	mv	s3,a0
    80003c54:	b7dd                	j	80003c3a <namex+0x42>
      iunlockput(ip);
    80003c56:	854e                	mv	a0,s3
    80003c58:	00000097          	auipc	ra,0x0
    80003c5c:	c76080e7          	jalr	-906(ra) # 800038ce <iunlockput>
      return 0;
    80003c60:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c62:	854e                	mv	a0,s3
    80003c64:	60e6                	ld	ra,88(sp)
    80003c66:	6446                	ld	s0,80(sp)
    80003c68:	64a6                	ld	s1,72(sp)
    80003c6a:	6906                	ld	s2,64(sp)
    80003c6c:	79e2                	ld	s3,56(sp)
    80003c6e:	7a42                	ld	s4,48(sp)
    80003c70:	7aa2                	ld	s5,40(sp)
    80003c72:	7b02                	ld	s6,32(sp)
    80003c74:	6be2                	ld	s7,24(sp)
    80003c76:	6c42                	ld	s8,16(sp)
    80003c78:	6ca2                	ld	s9,8(sp)
    80003c7a:	6125                	addi	sp,sp,96
    80003c7c:	8082                	ret
      iunlock(ip);
    80003c7e:	854e                	mv	a0,s3
    80003c80:	00000097          	auipc	ra,0x0
    80003c84:	ad2080e7          	jalr	-1326(ra) # 80003752 <iunlock>
      return ip;
    80003c88:	bfe9                	j	80003c62 <namex+0x6a>
      iunlockput(ip);
    80003c8a:	854e                	mv	a0,s3
    80003c8c:	00000097          	auipc	ra,0x0
    80003c90:	c42080e7          	jalr	-958(ra) # 800038ce <iunlockput>
      return 0;
    80003c94:	89e6                	mv	s3,s9
    80003c96:	b7f1                	j	80003c62 <namex+0x6a>
  len = path - s;
    80003c98:	40b48633          	sub	a2,s1,a1
    80003c9c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003ca0:	099c5463          	bge	s8,s9,80003d28 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003ca4:	4639                	li	a2,14
    80003ca6:	8552                	mv	a0,s4
    80003ca8:	ffffd097          	auipc	ra,0xffffd
    80003cac:	12c080e7          	jalr	300(ra) # 80000dd4 <memmove>
  while(*path == '/')
    80003cb0:	0004c783          	lbu	a5,0(s1)
    80003cb4:	01279763          	bne	a5,s2,80003cc2 <namex+0xca>
    path++;
    80003cb8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cba:	0004c783          	lbu	a5,0(s1)
    80003cbe:	ff278de3          	beq	a5,s2,80003cb8 <namex+0xc0>
    ilock(ip);
    80003cc2:	854e                	mv	a0,s3
    80003cc4:	00000097          	auipc	ra,0x0
    80003cc8:	9cc080e7          	jalr	-1588(ra) # 80003690 <ilock>
    if(ip->type != T_DIR){
    80003ccc:	04c99783          	lh	a5,76(s3)
    80003cd0:	f97793e3          	bne	a5,s7,80003c56 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003cd4:	000a8563          	beqz	s5,80003cde <namex+0xe6>
    80003cd8:	0004c783          	lbu	a5,0(s1)
    80003cdc:	d3cd                	beqz	a5,80003c7e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003cde:	865a                	mv	a2,s6
    80003ce0:	85d2                	mv	a1,s4
    80003ce2:	854e                	mv	a0,s3
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	e64080e7          	jalr	-412(ra) # 80003b48 <dirlookup>
    80003cec:	8caa                	mv	s9,a0
    80003cee:	dd51                	beqz	a0,80003c8a <namex+0x92>
    iunlockput(ip);
    80003cf0:	854e                	mv	a0,s3
    80003cf2:	00000097          	auipc	ra,0x0
    80003cf6:	bdc080e7          	jalr	-1060(ra) # 800038ce <iunlockput>
    ip = next;
    80003cfa:	89e6                	mv	s3,s9
  while(*path == '/')
    80003cfc:	0004c783          	lbu	a5,0(s1)
    80003d00:	05279763          	bne	a5,s2,80003d4e <namex+0x156>
    path++;
    80003d04:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d06:	0004c783          	lbu	a5,0(s1)
    80003d0a:	ff278de3          	beq	a5,s2,80003d04 <namex+0x10c>
  if(*path == 0)
    80003d0e:	c79d                	beqz	a5,80003d3c <namex+0x144>
    path++;
    80003d10:	85a6                	mv	a1,s1
  len = path - s;
    80003d12:	8cda                	mv	s9,s6
    80003d14:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003d16:	01278963          	beq	a5,s2,80003d28 <namex+0x130>
    80003d1a:	dfbd                	beqz	a5,80003c98 <namex+0xa0>
    path++;
    80003d1c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003d1e:	0004c783          	lbu	a5,0(s1)
    80003d22:	ff279ce3          	bne	a5,s2,80003d1a <namex+0x122>
    80003d26:	bf8d                	j	80003c98 <namex+0xa0>
    memmove(name, s, len);
    80003d28:	2601                	sext.w	a2,a2
    80003d2a:	8552                	mv	a0,s4
    80003d2c:	ffffd097          	auipc	ra,0xffffd
    80003d30:	0a8080e7          	jalr	168(ra) # 80000dd4 <memmove>
    name[len] = 0;
    80003d34:	9cd2                	add	s9,s9,s4
    80003d36:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d3a:	bf9d                	j	80003cb0 <namex+0xb8>
  if(nameiparent){
    80003d3c:	f20a83e3          	beqz	s5,80003c62 <namex+0x6a>
    iput(ip);
    80003d40:	854e                	mv	a0,s3
    80003d42:	00000097          	auipc	ra,0x0
    80003d46:	a5c080e7          	jalr	-1444(ra) # 8000379e <iput>
    return 0;
    80003d4a:	4981                	li	s3,0
    80003d4c:	bf19                	j	80003c62 <namex+0x6a>
  if(*path == 0)
    80003d4e:	d7fd                	beqz	a5,80003d3c <namex+0x144>
  while(*path != '/' && *path != 0)
    80003d50:	0004c783          	lbu	a5,0(s1)
    80003d54:	85a6                	mv	a1,s1
    80003d56:	b7d1                	j	80003d1a <namex+0x122>

0000000080003d58 <dirlink>:
{
    80003d58:	7139                	addi	sp,sp,-64
    80003d5a:	fc06                	sd	ra,56(sp)
    80003d5c:	f822                	sd	s0,48(sp)
    80003d5e:	f426                	sd	s1,40(sp)
    80003d60:	f04a                	sd	s2,32(sp)
    80003d62:	ec4e                	sd	s3,24(sp)
    80003d64:	e852                	sd	s4,16(sp)
    80003d66:	0080                	addi	s0,sp,64
    80003d68:	892a                	mv	s2,a0
    80003d6a:	8a2e                	mv	s4,a1
    80003d6c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d6e:	4601                	li	a2,0
    80003d70:	00000097          	auipc	ra,0x0
    80003d74:	dd8080e7          	jalr	-552(ra) # 80003b48 <dirlookup>
    80003d78:	e93d                	bnez	a0,80003dee <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d7a:	05492483          	lw	s1,84(s2)
    80003d7e:	c49d                	beqz	s1,80003dac <dirlink+0x54>
    80003d80:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d82:	4741                	li	a4,16
    80003d84:	86a6                	mv	a3,s1
    80003d86:	fc040613          	addi	a2,s0,-64
    80003d8a:	4581                	li	a1,0
    80003d8c:	854a                	mv	a0,s2
    80003d8e:	00000097          	auipc	ra,0x0
    80003d92:	b92080e7          	jalr	-1134(ra) # 80003920 <readi>
    80003d96:	47c1                	li	a5,16
    80003d98:	06f51163          	bne	a0,a5,80003dfa <dirlink+0xa2>
    if(de.inum == 0)
    80003d9c:	fc045783          	lhu	a5,-64(s0)
    80003da0:	c791                	beqz	a5,80003dac <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da2:	24c1                	addiw	s1,s1,16
    80003da4:	05492783          	lw	a5,84(s2)
    80003da8:	fcf4ede3          	bltu	s1,a5,80003d82 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003dac:	4639                	li	a2,14
    80003dae:	85d2                	mv	a1,s4
    80003db0:	fc240513          	addi	a0,s0,-62
    80003db4:	ffffd097          	auipc	ra,0xffffd
    80003db8:	0d8080e7          	jalr	216(ra) # 80000e8c <strncpy>
  de.inum = inum;
    80003dbc:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dc0:	4741                	li	a4,16
    80003dc2:	86a6                	mv	a3,s1
    80003dc4:	fc040613          	addi	a2,s0,-64
    80003dc8:	4581                	li	a1,0
    80003dca:	854a                	mv	a0,s2
    80003dcc:	00000097          	auipc	ra,0x0
    80003dd0:	c48080e7          	jalr	-952(ra) # 80003a14 <writei>
    80003dd4:	872a                	mv	a4,a0
    80003dd6:	47c1                	li	a5,16
  return 0;
    80003dd8:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dda:	02f71863          	bne	a4,a5,80003e0a <dirlink+0xb2>
}
    80003dde:	70e2                	ld	ra,56(sp)
    80003de0:	7442                	ld	s0,48(sp)
    80003de2:	74a2                	ld	s1,40(sp)
    80003de4:	7902                	ld	s2,32(sp)
    80003de6:	69e2                	ld	s3,24(sp)
    80003de8:	6a42                	ld	s4,16(sp)
    80003dea:	6121                	addi	sp,sp,64
    80003dec:	8082                	ret
    iput(ip);
    80003dee:	00000097          	auipc	ra,0x0
    80003df2:	9b0080e7          	jalr	-1616(ra) # 8000379e <iput>
    return -1;
    80003df6:	557d                	li	a0,-1
    80003df8:	b7dd                	j	80003dde <dirlink+0x86>
      panic("dirlink read");
    80003dfa:	00005517          	auipc	a0,0x5
    80003dfe:	93650513          	addi	a0,a0,-1738 # 80008730 <userret+0x6a0>
    80003e02:	ffffc097          	auipc	ra,0xffffc
    80003e06:	746080e7          	jalr	1862(ra) # 80000548 <panic>
    panic("dirlink");
    80003e0a:	00005517          	auipc	a0,0x5
    80003e0e:	ad650513          	addi	a0,a0,-1322 # 800088e0 <userret+0x850>
    80003e12:	ffffc097          	auipc	ra,0xffffc
    80003e16:	736080e7          	jalr	1846(ra) # 80000548 <panic>

0000000080003e1a <namei>:

struct inode*
namei(char *path)
{
    80003e1a:	1101                	addi	sp,sp,-32
    80003e1c:	ec06                	sd	ra,24(sp)
    80003e1e:	e822                	sd	s0,16(sp)
    80003e20:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e22:	fe040613          	addi	a2,s0,-32
    80003e26:	4581                	li	a1,0
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	dd0080e7          	jalr	-560(ra) # 80003bf8 <namex>
}
    80003e30:	60e2                	ld	ra,24(sp)
    80003e32:	6442                	ld	s0,16(sp)
    80003e34:	6105                	addi	sp,sp,32
    80003e36:	8082                	ret

0000000080003e38 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e38:	1141                	addi	sp,sp,-16
    80003e3a:	e406                	sd	ra,8(sp)
    80003e3c:	e022                	sd	s0,0(sp)
    80003e3e:	0800                	addi	s0,sp,16
    80003e40:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e42:	4585                	li	a1,1
    80003e44:	00000097          	auipc	ra,0x0
    80003e48:	db4080e7          	jalr	-588(ra) # 80003bf8 <namex>
}
    80003e4c:	60a2                	ld	ra,8(sp)
    80003e4e:	6402                	ld	s0,0(sp)
    80003e50:	0141                	addi	sp,sp,16
    80003e52:	8082                	ret

0000000080003e54 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80003e54:	7179                	addi	sp,sp,-48
    80003e56:	f406                	sd	ra,40(sp)
    80003e58:	f022                	sd	s0,32(sp)
    80003e5a:	ec26                	sd	s1,24(sp)
    80003e5c:	e84a                	sd	s2,16(sp)
    80003e5e:	e44e                	sd	s3,8(sp)
    80003e60:	1800                	addi	s0,sp,48
    80003e62:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80003e64:	0b000993          	li	s3,176
    80003e68:	033507b3          	mul	a5,a0,s3
    80003e6c:	00026997          	auipc	s3,0x26
    80003e70:	c3498993          	addi	s3,s3,-972 # 80029aa0 <log>
    80003e74:	99be                	add	s3,s3,a5
    80003e76:	0209a583          	lw	a1,32(s3)
    80003e7a:	fffff097          	auipc	ra,0xfffff
    80003e7e:	010080e7          	jalr	16(ra) # 80002e8a <bread>
    80003e82:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80003e84:	0349a783          	lw	a5,52(s3)
    80003e88:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003e8a:	0349a783          	lw	a5,52(s3)
    80003e8e:	02f05763          	blez	a5,80003ebc <write_head+0x68>
    80003e92:	0b000793          	li	a5,176
    80003e96:	02f487b3          	mul	a5,s1,a5
    80003e9a:	00026717          	auipc	a4,0x26
    80003e9e:	c3e70713          	addi	a4,a4,-962 # 80029ad8 <log+0x38>
    80003ea2:	97ba                	add	a5,a5,a4
    80003ea4:	06450693          	addi	a3,a0,100
    80003ea8:	4701                	li	a4,0
    80003eaa:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80003eac:	4390                	lw	a2,0(a5)
    80003eae:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003eb0:	2705                	addiw	a4,a4,1
    80003eb2:	0791                	addi	a5,a5,4
    80003eb4:	0691                	addi	a3,a3,4
    80003eb6:	59d0                	lw	a2,52(a1)
    80003eb8:	fec74ae3          	blt	a4,a2,80003eac <write_head+0x58>
  }
  bwrite(buf);
    80003ebc:	854a                	mv	a0,s2
    80003ebe:	fffff097          	auipc	ra,0xfffff
    80003ec2:	0c0080e7          	jalr	192(ra) # 80002f7e <bwrite>
  brelse(buf);
    80003ec6:	854a                	mv	a0,s2
    80003ec8:	fffff097          	auipc	ra,0xfffff
    80003ecc:	0f6080e7          	jalr	246(ra) # 80002fbe <brelse>
}
    80003ed0:	70a2                	ld	ra,40(sp)
    80003ed2:	7402                	ld	s0,32(sp)
    80003ed4:	64e2                	ld	s1,24(sp)
    80003ed6:	6942                	ld	s2,16(sp)
    80003ed8:	69a2                	ld	s3,8(sp)
    80003eda:	6145                	addi	sp,sp,48
    80003edc:	8082                	ret

0000000080003ede <write_log>:
static void
write_log(int dev)
{
  int tail;

  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003ede:	0b000793          	li	a5,176
    80003ee2:	02f50733          	mul	a4,a0,a5
    80003ee6:	00026797          	auipc	a5,0x26
    80003eea:	bba78793          	addi	a5,a5,-1094 # 80029aa0 <log>
    80003eee:	97ba                	add	a5,a5,a4
    80003ef0:	5bdc                	lw	a5,52(a5)
    80003ef2:	0af05663          	blez	a5,80003f9e <write_log+0xc0>
{
    80003ef6:	7139                	addi	sp,sp,-64
    80003ef8:	fc06                	sd	ra,56(sp)
    80003efa:	f822                	sd	s0,48(sp)
    80003efc:	f426                	sd	s1,40(sp)
    80003efe:	f04a                	sd	s2,32(sp)
    80003f00:	ec4e                	sd	s3,24(sp)
    80003f02:	e852                	sd	s4,16(sp)
    80003f04:	e456                	sd	s5,8(sp)
    80003f06:	e05a                	sd	s6,0(sp)
    80003f08:	0080                	addi	s0,sp,64
    80003f0a:	00026797          	auipc	a5,0x26
    80003f0e:	bce78793          	addi	a5,a5,-1074 # 80029ad8 <log+0x38>
    80003f12:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003f16:	4981                	li	s3,0
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80003f18:	00050b1b          	sext.w	s6,a0
    80003f1c:	00026a97          	auipc	s5,0x26
    80003f20:	b84a8a93          	addi	s5,s5,-1148 # 80029aa0 <log>
    80003f24:	9aba                	add	s5,s5,a4
    80003f26:	020aa583          	lw	a1,32(s5)
    80003f2a:	013585bb          	addw	a1,a1,s3
    80003f2e:	2585                	addiw	a1,a1,1
    80003f30:	855a                	mv	a0,s6
    80003f32:	fffff097          	auipc	ra,0xfffff
    80003f36:	f58080e7          	jalr	-168(ra) # 80002e8a <bread>
    80003f3a:	84aa                	mv	s1,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    80003f3c:	000a2583          	lw	a1,0(s4)
    80003f40:	855a                	mv	a0,s6
    80003f42:	fffff097          	auipc	ra,0xfffff
    80003f46:	f48080e7          	jalr	-184(ra) # 80002e8a <bread>
    80003f4a:	892a                	mv	s2,a0
    memmove(to->data, from->data, BSIZE);
    80003f4c:	40000613          	li	a2,1024
    80003f50:	06050593          	addi	a1,a0,96
    80003f54:	06048513          	addi	a0,s1,96
    80003f58:	ffffd097          	auipc	ra,0xffffd
    80003f5c:	e7c080e7          	jalr	-388(ra) # 80000dd4 <memmove>
    bwrite(to);  // write the log
    80003f60:	8526                	mv	a0,s1
    80003f62:	fffff097          	auipc	ra,0xfffff
    80003f66:	01c080e7          	jalr	28(ra) # 80002f7e <bwrite>
    brelse(from);
    80003f6a:	854a                	mv	a0,s2
    80003f6c:	fffff097          	auipc	ra,0xfffff
    80003f70:	052080e7          	jalr	82(ra) # 80002fbe <brelse>
    brelse(to);
    80003f74:	8526                	mv	a0,s1
    80003f76:	fffff097          	auipc	ra,0xfffff
    80003f7a:	048080e7          	jalr	72(ra) # 80002fbe <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003f7e:	2985                	addiw	s3,s3,1
    80003f80:	0a11                	addi	s4,s4,4
    80003f82:	034aa783          	lw	a5,52(s5)
    80003f86:	faf9c0e3          	blt	s3,a5,80003f26 <write_log+0x48>
  }
}
    80003f8a:	70e2                	ld	ra,56(sp)
    80003f8c:	7442                	ld	s0,48(sp)
    80003f8e:	74a2                	ld	s1,40(sp)
    80003f90:	7902                	ld	s2,32(sp)
    80003f92:	69e2                	ld	s3,24(sp)
    80003f94:	6a42                	ld	s4,16(sp)
    80003f96:	6aa2                	ld	s5,8(sp)
    80003f98:	6b02                	ld	s6,0(sp)
    80003f9a:	6121                	addi	sp,sp,64
    80003f9c:	8082                	ret
    80003f9e:	8082                	ret

0000000080003fa0 <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003fa0:	0b000793          	li	a5,176
    80003fa4:	02f50733          	mul	a4,a0,a5
    80003fa8:	00026797          	auipc	a5,0x26
    80003fac:	af878793          	addi	a5,a5,-1288 # 80029aa0 <log>
    80003fb0:	97ba                	add	a5,a5,a4
    80003fb2:	5bdc                	lw	a5,52(a5)
    80003fb4:	0af05b63          	blez	a5,8000406a <install_trans+0xca>
{
    80003fb8:	7139                	addi	sp,sp,-64
    80003fba:	fc06                	sd	ra,56(sp)
    80003fbc:	f822                	sd	s0,48(sp)
    80003fbe:	f426                	sd	s1,40(sp)
    80003fc0:	f04a                	sd	s2,32(sp)
    80003fc2:	ec4e                	sd	s3,24(sp)
    80003fc4:	e852                	sd	s4,16(sp)
    80003fc6:	e456                	sd	s5,8(sp)
    80003fc8:	e05a                	sd	s6,0(sp)
    80003fca:	0080                	addi	s0,sp,64
    80003fcc:	00026797          	auipc	a5,0x26
    80003fd0:	b0c78793          	addi	a5,a5,-1268 # 80029ad8 <log+0x38>
    80003fd4:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003fd8:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80003fda:	00050b1b          	sext.w	s6,a0
    80003fde:	00026a97          	auipc	s5,0x26
    80003fe2:	ac2a8a93          	addi	s5,s5,-1342 # 80029aa0 <log>
    80003fe6:	9aba                	add	s5,s5,a4
    80003fe8:	020aa583          	lw	a1,32(s5)
    80003fec:	013585bb          	addw	a1,a1,s3
    80003ff0:	2585                	addiw	a1,a1,1
    80003ff2:	855a                	mv	a0,s6
    80003ff4:	fffff097          	auipc	ra,0xfffff
    80003ff8:	e96080e7          	jalr	-362(ra) # 80002e8a <bread>
    80003ffc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80003ffe:	000a2583          	lw	a1,0(s4)
    80004002:	855a                	mv	a0,s6
    80004004:	fffff097          	auipc	ra,0xfffff
    80004008:	e86080e7          	jalr	-378(ra) # 80002e8a <bread>
    8000400c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000400e:	40000613          	li	a2,1024
    80004012:	06090593          	addi	a1,s2,96
    80004016:	06050513          	addi	a0,a0,96
    8000401a:	ffffd097          	auipc	ra,0xffffd
    8000401e:	dba080e7          	jalr	-582(ra) # 80000dd4 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004022:	8526                	mv	a0,s1
    80004024:	fffff097          	auipc	ra,0xfffff
    80004028:	f5a080e7          	jalr	-166(ra) # 80002f7e <bwrite>
    bunpin(dbuf);
    8000402c:	8526                	mv	a0,s1
    8000402e:	fffff097          	auipc	ra,0xfffff
    80004032:	06a080e7          	jalr	106(ra) # 80003098 <bunpin>
    brelse(lbuf);
    80004036:	854a                	mv	a0,s2
    80004038:	fffff097          	auipc	ra,0xfffff
    8000403c:	f86080e7          	jalr	-122(ra) # 80002fbe <brelse>
    brelse(dbuf);
    80004040:	8526                	mv	a0,s1
    80004042:	fffff097          	auipc	ra,0xfffff
    80004046:	f7c080e7          	jalr	-132(ra) # 80002fbe <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000404a:	2985                	addiw	s3,s3,1
    8000404c:	0a11                	addi	s4,s4,4
    8000404e:	034aa783          	lw	a5,52(s5)
    80004052:	f8f9cbe3          	blt	s3,a5,80003fe8 <install_trans+0x48>
}
    80004056:	70e2                	ld	ra,56(sp)
    80004058:	7442                	ld	s0,48(sp)
    8000405a:	74a2                	ld	s1,40(sp)
    8000405c:	7902                	ld	s2,32(sp)
    8000405e:	69e2                	ld	s3,24(sp)
    80004060:	6a42                	ld	s4,16(sp)
    80004062:	6aa2                	ld	s5,8(sp)
    80004064:	6b02                	ld	s6,0(sp)
    80004066:	6121                	addi	sp,sp,64
    80004068:	8082                	ret
    8000406a:	8082                	ret

000000008000406c <initlog>:
{
    8000406c:	7179                	addi	sp,sp,-48
    8000406e:	f406                	sd	ra,40(sp)
    80004070:	f022                	sd	s0,32(sp)
    80004072:	ec26                	sd	s1,24(sp)
    80004074:	e84a                	sd	s2,16(sp)
    80004076:	e44e                	sd	s3,8(sp)
    80004078:	e052                	sd	s4,0(sp)
    8000407a:	1800                	addi	s0,sp,48
    8000407c:	892a                	mv	s2,a0
    8000407e:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80004080:	0b000713          	li	a4,176
    80004084:	02e504b3          	mul	s1,a0,a4
    80004088:	00026997          	auipc	s3,0x26
    8000408c:	a1898993          	addi	s3,s3,-1512 # 80029aa0 <log>
    80004090:	99a6                	add	s3,s3,s1
    80004092:	00004597          	auipc	a1,0x4
    80004096:	6ae58593          	addi	a1,a1,1710 # 80008740 <userret+0x6b0>
    8000409a:	854e                	mv	a0,s3
    8000409c:	ffffd097          	auipc	ra,0xffffd
    800040a0:	924080e7          	jalr	-1756(ra) # 800009c0 <initlock>
  log[dev].start = sb->logstart;
    800040a4:	014a2583          	lw	a1,20(s4)
    800040a8:	02b9a023          	sw	a1,32(s3)
  log[dev].size = sb->nlog;
    800040ac:	010a2783          	lw	a5,16(s4)
    800040b0:	02f9a223          	sw	a5,36(s3)
  log[dev].dev = dev;
    800040b4:	0329a823          	sw	s2,48(s3)
  struct buf *buf = bread(dev, log[dev].start);
    800040b8:	854a                	mv	a0,s2
    800040ba:	fffff097          	auipc	ra,0xfffff
    800040be:	dd0080e7          	jalr	-560(ra) # 80002e8a <bread>
  log[dev].lh.n = lh->n;
    800040c2:	5134                	lw	a3,96(a0)
    800040c4:	02d9aa23          	sw	a3,52(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    800040c8:	02d05663          	blez	a3,800040f4 <initlog+0x88>
    800040cc:	06450793          	addi	a5,a0,100
    800040d0:	00026717          	auipc	a4,0x26
    800040d4:	a0870713          	addi	a4,a4,-1528 # 80029ad8 <log+0x38>
    800040d8:	9726                	add	a4,a4,s1
    800040da:	36fd                	addiw	a3,a3,-1
    800040dc:	1682                	slli	a3,a3,0x20
    800040de:	9281                	srli	a3,a3,0x20
    800040e0:	068a                	slli	a3,a3,0x2
    800040e2:	06850613          	addi	a2,a0,104
    800040e6:	96b2                	add	a3,a3,a2
    log[dev].lh.block[i] = lh->block[i];
    800040e8:	4390                	lw	a2,0(a5)
    800040ea:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    800040ec:	0791                	addi	a5,a5,4
    800040ee:	0711                	addi	a4,a4,4
    800040f0:	fed79ce3          	bne	a5,a3,800040e8 <initlog+0x7c>
  brelse(buf);
    800040f4:	fffff097          	auipc	ra,0xfffff
    800040f8:	eca080e7          	jalr	-310(ra) # 80002fbe <brelse>
  install_trans(dev); // if committed, copy from log to disk
    800040fc:	854a                	mv	a0,s2
    800040fe:	00000097          	auipc	ra,0x0
    80004102:	ea2080e7          	jalr	-350(ra) # 80003fa0 <install_trans>
  log[dev].lh.n = 0;
    80004106:	0b000793          	li	a5,176
    8000410a:	02f90733          	mul	a4,s2,a5
    8000410e:	00026797          	auipc	a5,0x26
    80004112:	99278793          	addi	a5,a5,-1646 # 80029aa0 <log>
    80004116:	97ba                	add	a5,a5,a4
    80004118:	0207aa23          	sw	zero,52(a5)
  write_head(dev); // clear the log
    8000411c:	854a                	mv	a0,s2
    8000411e:	00000097          	auipc	ra,0x0
    80004122:	d36080e7          	jalr	-714(ra) # 80003e54 <write_head>
}
    80004126:	70a2                	ld	ra,40(sp)
    80004128:	7402                	ld	s0,32(sp)
    8000412a:	64e2                	ld	s1,24(sp)
    8000412c:	6942                	ld	s2,16(sp)
    8000412e:	69a2                	ld	s3,8(sp)
    80004130:	6a02                	ld	s4,0(sp)
    80004132:	6145                	addi	sp,sp,48
    80004134:	8082                	ret

0000000080004136 <begin_op>:
{
    80004136:	7139                	addi	sp,sp,-64
    80004138:	fc06                	sd	ra,56(sp)
    8000413a:	f822                	sd	s0,48(sp)
    8000413c:	f426                	sd	s1,40(sp)
    8000413e:	f04a                	sd	s2,32(sp)
    80004140:	ec4e                	sd	s3,24(sp)
    80004142:	e852                	sd	s4,16(sp)
    80004144:	e456                	sd	s5,8(sp)
    80004146:	0080                	addi	s0,sp,64
    80004148:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    8000414a:	0b000913          	li	s2,176
    8000414e:	032507b3          	mul	a5,a0,s2
    80004152:	00026917          	auipc	s2,0x26
    80004156:	94e90913          	addi	s2,s2,-1714 # 80029aa0 <log>
    8000415a:	993e                	add	s2,s2,a5
    8000415c:	854a                	mv	a0,s2
    8000415e:	ffffd097          	auipc	ra,0xffffd
    80004162:	9b0080e7          	jalr	-1616(ra) # 80000b0e <acquire>
    if(log[dev].committing){
    80004166:	00026997          	auipc	s3,0x26
    8000416a:	93a98993          	addi	s3,s3,-1734 # 80029aa0 <log>
    8000416e:	84ca                	mv	s1,s2
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004170:	4a79                	li	s4,30
    80004172:	a039                	j	80004180 <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    80004174:	85ca                	mv	a1,s2
    80004176:	854e                	mv	a0,s3
    80004178:	ffffe097          	auipc	ra,0xffffe
    8000417c:	0ce080e7          	jalr	206(ra) # 80002246 <sleep>
    if(log[dev].committing){
    80004180:	54dc                	lw	a5,44(s1)
    80004182:	fbed                	bnez	a5,80004174 <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004184:	549c                	lw	a5,40(s1)
    80004186:	0017871b          	addiw	a4,a5,1
    8000418a:	0007069b          	sext.w	a3,a4
    8000418e:	0027179b          	slliw	a5,a4,0x2
    80004192:	9fb9                	addw	a5,a5,a4
    80004194:	0017979b          	slliw	a5,a5,0x1
    80004198:	58d8                	lw	a4,52(s1)
    8000419a:	9fb9                	addw	a5,a5,a4
    8000419c:	00fa5963          	bge	s4,a5,800041ae <begin_op+0x78>
      sleep(&log, &log[dev].lock);
    800041a0:	85ca                	mv	a1,s2
    800041a2:	854e                	mv	a0,s3
    800041a4:	ffffe097          	auipc	ra,0xffffe
    800041a8:	0a2080e7          	jalr	162(ra) # 80002246 <sleep>
    800041ac:	bfd1                	j	80004180 <begin_op+0x4a>
      log[dev].outstanding += 1;
    800041ae:	0b000513          	li	a0,176
    800041b2:	02aa8ab3          	mul	s5,s5,a0
    800041b6:	00026797          	auipc	a5,0x26
    800041ba:	8ea78793          	addi	a5,a5,-1814 # 80029aa0 <log>
    800041be:	9abe                	add	s5,s5,a5
    800041c0:	02daa423          	sw	a3,40(s5)
      release(&log[dev].lock);
    800041c4:	854a                	mv	a0,s2
    800041c6:	ffffd097          	auipc	ra,0xffffd
    800041ca:	9b8080e7          	jalr	-1608(ra) # 80000b7e <release>
}
    800041ce:	70e2                	ld	ra,56(sp)
    800041d0:	7442                	ld	s0,48(sp)
    800041d2:	74a2                	ld	s1,40(sp)
    800041d4:	7902                	ld	s2,32(sp)
    800041d6:	69e2                	ld	s3,24(sp)
    800041d8:	6a42                	ld	s4,16(sp)
    800041da:	6aa2                	ld	s5,8(sp)
    800041dc:	6121                	addi	sp,sp,64
    800041de:	8082                	ret

00000000800041e0 <end_op>:
{
    800041e0:	7179                	addi	sp,sp,-48
    800041e2:	f406                	sd	ra,40(sp)
    800041e4:	f022                	sd	s0,32(sp)
    800041e6:	ec26                	sd	s1,24(sp)
    800041e8:	e84a                	sd	s2,16(sp)
    800041ea:	e44e                	sd	s3,8(sp)
    800041ec:	1800                	addi	s0,sp,48
    800041ee:	892a                	mv	s2,a0
  acquire(&log[dev].lock);
    800041f0:	0b000493          	li	s1,176
    800041f4:	029507b3          	mul	a5,a0,s1
    800041f8:	00026497          	auipc	s1,0x26
    800041fc:	8a848493          	addi	s1,s1,-1880 # 80029aa0 <log>
    80004200:	94be                	add	s1,s1,a5
    80004202:	8526                	mv	a0,s1
    80004204:	ffffd097          	auipc	ra,0xffffd
    80004208:	90a080e7          	jalr	-1782(ra) # 80000b0e <acquire>
  log[dev].outstanding -= 1;
    8000420c:	549c                	lw	a5,40(s1)
    8000420e:	37fd                	addiw	a5,a5,-1
    80004210:	0007871b          	sext.w	a4,a5
    80004214:	d49c                	sw	a5,40(s1)
  if(log[dev].committing)
    80004216:	54dc                	lw	a5,44(s1)
    80004218:	e3ad                	bnez	a5,8000427a <end_op+0x9a>
  if(log[dev].outstanding == 0){
    8000421a:	eb25                	bnez	a4,8000428a <end_op+0xaa>
    log[dev].committing = 1;
    8000421c:	0b000993          	li	s3,176
    80004220:	033907b3          	mul	a5,s2,s3
    80004224:	00026997          	auipc	s3,0x26
    80004228:	87c98993          	addi	s3,s3,-1924 # 80029aa0 <log>
    8000422c:	99be                	add	s3,s3,a5
    8000422e:	4785                	li	a5,1
    80004230:	02f9a623          	sw	a5,44(s3)
  release(&log[dev].lock);
    80004234:	8526                	mv	a0,s1
    80004236:	ffffd097          	auipc	ra,0xffffd
    8000423a:	948080e7          	jalr	-1720(ra) # 80000b7e <release>

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    8000423e:	0349a783          	lw	a5,52(s3)
    80004242:	06f04863          	bgtz	a5,800042b2 <end_op+0xd2>
    acquire(&log[dev].lock);
    80004246:	8526                	mv	a0,s1
    80004248:	ffffd097          	auipc	ra,0xffffd
    8000424c:	8c6080e7          	jalr	-1850(ra) # 80000b0e <acquire>
    log[dev].committing = 0;
    80004250:	00026517          	auipc	a0,0x26
    80004254:	85050513          	addi	a0,a0,-1968 # 80029aa0 <log>
    80004258:	0b000793          	li	a5,176
    8000425c:	02f90933          	mul	s2,s2,a5
    80004260:	992a                	add	s2,s2,a0
    80004262:	02092623          	sw	zero,44(s2)
    wakeup(&log);
    80004266:	ffffe097          	auipc	ra,0xffffe
    8000426a:	160080e7          	jalr	352(ra) # 800023c6 <wakeup>
    release(&log[dev].lock);
    8000426e:	8526                	mv	a0,s1
    80004270:	ffffd097          	auipc	ra,0xffffd
    80004274:	90e080e7          	jalr	-1778(ra) # 80000b7e <release>
}
    80004278:	a035                	j	800042a4 <end_op+0xc4>
    panic("log[dev].committing");
    8000427a:	00004517          	auipc	a0,0x4
    8000427e:	4ce50513          	addi	a0,a0,1230 # 80008748 <userret+0x6b8>
    80004282:	ffffc097          	auipc	ra,0xffffc
    80004286:	2c6080e7          	jalr	710(ra) # 80000548 <panic>
    wakeup(&log);
    8000428a:	00026517          	auipc	a0,0x26
    8000428e:	81650513          	addi	a0,a0,-2026 # 80029aa0 <log>
    80004292:	ffffe097          	auipc	ra,0xffffe
    80004296:	134080e7          	jalr	308(ra) # 800023c6 <wakeup>
  release(&log[dev].lock);
    8000429a:	8526                	mv	a0,s1
    8000429c:	ffffd097          	auipc	ra,0xffffd
    800042a0:	8e2080e7          	jalr	-1822(ra) # 80000b7e <release>
}
    800042a4:	70a2                	ld	ra,40(sp)
    800042a6:	7402                	ld	s0,32(sp)
    800042a8:	64e2                	ld	s1,24(sp)
    800042aa:	6942                	ld	s2,16(sp)
    800042ac:	69a2                	ld	s3,8(sp)
    800042ae:	6145                	addi	sp,sp,48
    800042b0:	8082                	ret
    write_log(dev);     // Write modified blocks from cache to log
    800042b2:	854a                	mv	a0,s2
    800042b4:	00000097          	auipc	ra,0x0
    800042b8:	c2a080e7          	jalr	-982(ra) # 80003ede <write_log>
    write_head(dev);    // Write header to disk -- the real commit
    800042bc:	854a                	mv	a0,s2
    800042be:	00000097          	auipc	ra,0x0
    800042c2:	b96080e7          	jalr	-1130(ra) # 80003e54 <write_head>
    install_trans(dev); // Now install writes to home locations
    800042c6:	854a                	mv	a0,s2
    800042c8:	00000097          	auipc	ra,0x0
    800042cc:	cd8080e7          	jalr	-808(ra) # 80003fa0 <install_trans>
    log[dev].lh.n = 0;
    800042d0:	0b000793          	li	a5,176
    800042d4:	02f90733          	mul	a4,s2,a5
    800042d8:	00025797          	auipc	a5,0x25
    800042dc:	7c878793          	addi	a5,a5,1992 # 80029aa0 <log>
    800042e0:	97ba                	add	a5,a5,a4
    800042e2:	0207aa23          	sw	zero,52(a5)
    write_head(dev);    // Erase the transaction from the log
    800042e6:	854a                	mv	a0,s2
    800042e8:	00000097          	auipc	ra,0x0
    800042ec:	b6c080e7          	jalr	-1172(ra) # 80003e54 <write_head>
    800042f0:	bf99                	j	80004246 <end_op+0x66>

00000000800042f2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042f2:	7179                	addi	sp,sp,-48
    800042f4:	f406                	sd	ra,40(sp)
    800042f6:	f022                	sd	s0,32(sp)
    800042f8:	ec26                	sd	s1,24(sp)
    800042fa:	e84a                	sd	s2,16(sp)
    800042fc:	e44e                	sd	s3,8(sp)
    800042fe:	e052                	sd	s4,0(sp)
    80004300:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004302:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004306:	0b000793          	li	a5,176
    8000430a:	02f90733          	mul	a4,s2,a5
    8000430e:	00025797          	auipc	a5,0x25
    80004312:	79278793          	addi	a5,a5,1938 # 80029aa0 <log>
    80004316:	97ba                	add	a5,a5,a4
    80004318:	5bd4                	lw	a3,52(a5)
    8000431a:	47f5                	li	a5,29
    8000431c:	0ad7cc63          	blt	a5,a3,800043d4 <log_write+0xe2>
    80004320:	89aa                	mv	s3,a0
    80004322:	00025797          	auipc	a5,0x25
    80004326:	77e78793          	addi	a5,a5,1918 # 80029aa0 <log>
    8000432a:	97ba                	add	a5,a5,a4
    8000432c:	53dc                	lw	a5,36(a5)
    8000432e:	37fd                	addiw	a5,a5,-1
    80004330:	0af6d263          	bge	a3,a5,800043d4 <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004334:	0b000793          	li	a5,176
    80004338:	02f90733          	mul	a4,s2,a5
    8000433c:	00025797          	auipc	a5,0x25
    80004340:	76478793          	addi	a5,a5,1892 # 80029aa0 <log>
    80004344:	97ba                	add	a5,a5,a4
    80004346:	579c                	lw	a5,40(a5)
    80004348:	08f05e63          	blez	a5,800043e4 <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    8000434c:	0b000793          	li	a5,176
    80004350:	02f904b3          	mul	s1,s2,a5
    80004354:	00025a17          	auipc	s4,0x25
    80004358:	74ca0a13          	addi	s4,s4,1868 # 80029aa0 <log>
    8000435c:	9a26                	add	s4,s4,s1
    8000435e:	8552                	mv	a0,s4
    80004360:	ffffc097          	auipc	ra,0xffffc
    80004364:	7ae080e7          	jalr	1966(ra) # 80000b0e <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004368:	034a2603          	lw	a2,52(s4)
    8000436c:	08c05463          	blez	a2,800043f4 <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004370:	00c9a583          	lw	a1,12(s3)
    80004374:	00025797          	auipc	a5,0x25
    80004378:	76478793          	addi	a5,a5,1892 # 80029ad8 <log+0x38>
    8000437c:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    8000437e:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004380:	4394                	lw	a3,0(a5)
    80004382:	06b68a63          	beq	a3,a1,800043f6 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004386:	2705                	addiw	a4,a4,1
    80004388:	0791                	addi	a5,a5,4
    8000438a:	fec71be3          	bne	a4,a2,80004380 <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    8000438e:	02c00793          	li	a5,44
    80004392:	02f907b3          	mul	a5,s2,a5
    80004396:	97b2                	add	a5,a5,a2
    80004398:	07b1                	addi	a5,a5,12
    8000439a:	078a                	slli	a5,a5,0x2
    8000439c:	00025717          	auipc	a4,0x25
    800043a0:	70470713          	addi	a4,a4,1796 # 80029aa0 <log>
    800043a4:	97ba                	add	a5,a5,a4
    800043a6:	00c9a703          	lw	a4,12(s3)
    800043aa:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    800043ac:	854e                	mv	a0,s3
    800043ae:	fffff097          	auipc	ra,0xfffff
    800043b2:	cae080e7          	jalr	-850(ra) # 8000305c <bpin>
    log[dev].lh.n++;
    800043b6:	0b000793          	li	a5,176
    800043ba:	02f90933          	mul	s2,s2,a5
    800043be:	00025797          	auipc	a5,0x25
    800043c2:	6e278793          	addi	a5,a5,1762 # 80029aa0 <log>
    800043c6:	993e                	add	s2,s2,a5
    800043c8:	03492783          	lw	a5,52(s2)
    800043cc:	2785                	addiw	a5,a5,1
    800043ce:	02f92a23          	sw	a5,52(s2)
    800043d2:	a099                	j	80004418 <log_write+0x126>
    panic("too big a transaction");
    800043d4:	00004517          	auipc	a0,0x4
    800043d8:	38c50513          	addi	a0,a0,908 # 80008760 <userret+0x6d0>
    800043dc:	ffffc097          	auipc	ra,0xffffc
    800043e0:	16c080e7          	jalr	364(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    800043e4:	00004517          	auipc	a0,0x4
    800043e8:	39450513          	addi	a0,a0,916 # 80008778 <userret+0x6e8>
    800043ec:	ffffc097          	auipc	ra,0xffffc
    800043f0:	15c080e7          	jalr	348(ra) # 80000548 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    800043f4:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    800043f6:	02c00793          	li	a5,44
    800043fa:	02f907b3          	mul	a5,s2,a5
    800043fe:	97ba                	add	a5,a5,a4
    80004400:	07b1                	addi	a5,a5,12
    80004402:	078a                	slli	a5,a5,0x2
    80004404:	00025697          	auipc	a3,0x25
    80004408:	69c68693          	addi	a3,a3,1692 # 80029aa0 <log>
    8000440c:	97b6                	add	a5,a5,a3
    8000440e:	00c9a683          	lw	a3,12(s3)
    80004412:	c794                	sw	a3,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004414:	f8e60ce3          	beq	a2,a4,800043ac <log_write+0xba>
  }
  release(&log[dev].lock);
    80004418:	8552                	mv	a0,s4
    8000441a:	ffffc097          	auipc	ra,0xffffc
    8000441e:	764080e7          	jalr	1892(ra) # 80000b7e <release>
}
    80004422:	70a2                	ld	ra,40(sp)
    80004424:	7402                	ld	s0,32(sp)
    80004426:	64e2                	ld	s1,24(sp)
    80004428:	6942                	ld	s2,16(sp)
    8000442a:	69a2                	ld	s3,8(sp)
    8000442c:	6a02                	ld	s4,0(sp)
    8000442e:	6145                	addi	sp,sp,48
    80004430:	8082                	ret

0000000080004432 <crash_op>:

// crash before commit or after commit
void
crash_op(int dev, int docommit)
{
    80004432:	7179                	addi	sp,sp,-48
    80004434:	f406                	sd	ra,40(sp)
    80004436:	f022                	sd	s0,32(sp)
    80004438:	ec26                	sd	s1,24(sp)
    8000443a:	e84a                	sd	s2,16(sp)
    8000443c:	e44e                	sd	s3,8(sp)
    8000443e:	1800                	addi	s0,sp,48
    80004440:	84aa                	mv	s1,a0
    80004442:	89ae                	mv	s3,a1
  int do_commit = 0;
    
  acquire(&log[dev].lock);
    80004444:	0b000913          	li	s2,176
    80004448:	032507b3          	mul	a5,a0,s2
    8000444c:	00025917          	auipc	s2,0x25
    80004450:	65490913          	addi	s2,s2,1620 # 80029aa0 <log>
    80004454:	993e                	add	s2,s2,a5
    80004456:	854a                	mv	a0,s2
    80004458:	ffffc097          	auipc	ra,0xffffc
    8000445c:	6b6080e7          	jalr	1718(ra) # 80000b0e <acquire>

  if (dev < 0 || dev >= NDISK)
    80004460:	0004871b          	sext.w	a4,s1
    80004464:	4785                	li	a5,1
    80004466:	0ae7e063          	bltu	a5,a4,80004506 <crash_op+0xd4>
    panic("end_op: invalid disk");
  if(log[dev].outstanding == 0)
    8000446a:	0b000793          	li	a5,176
    8000446e:	02f48733          	mul	a4,s1,a5
    80004472:	00025797          	auipc	a5,0x25
    80004476:	62e78793          	addi	a5,a5,1582 # 80029aa0 <log>
    8000447a:	97ba                	add	a5,a5,a4
    8000447c:	579c                	lw	a5,40(a5)
    8000447e:	cfc1                	beqz	a5,80004516 <crash_op+0xe4>
    panic("end_op: already closed");
  log[dev].outstanding -= 1;
    80004480:	37fd                	addiw	a5,a5,-1
    80004482:	0007861b          	sext.w	a2,a5
    80004486:	0b000713          	li	a4,176
    8000448a:	02e486b3          	mul	a3,s1,a4
    8000448e:	00025717          	auipc	a4,0x25
    80004492:	61270713          	addi	a4,a4,1554 # 80029aa0 <log>
    80004496:	9736                	add	a4,a4,a3
    80004498:	d71c                	sw	a5,40(a4)
  if(log[dev].committing)
    8000449a:	575c                	lw	a5,44(a4)
    8000449c:	e7c9                	bnez	a5,80004526 <crash_op+0xf4>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    8000449e:	ee41                	bnez	a2,80004536 <crash_op+0x104>
    do_commit = 1;
    log[dev].committing = 1;
    800044a0:	0b000793          	li	a5,176
    800044a4:	02f48733          	mul	a4,s1,a5
    800044a8:	00025797          	auipc	a5,0x25
    800044ac:	5f878793          	addi	a5,a5,1528 # 80029aa0 <log>
    800044b0:	97ba                	add	a5,a5,a4
    800044b2:	4705                	li	a4,1
    800044b4:	d7d8                	sw	a4,44(a5)
  }
  
  release(&log[dev].lock);
    800044b6:	854a                	mv	a0,s2
    800044b8:	ffffc097          	auipc	ra,0xffffc
    800044bc:	6c6080e7          	jalr	1734(ra) # 80000b7e <release>

  if(docommit & do_commit){
    800044c0:	0019f993          	andi	s3,s3,1
    800044c4:	06098e63          	beqz	s3,80004540 <crash_op+0x10e>
    printf("crash_op: commit\n");
    800044c8:	00004517          	auipc	a0,0x4
    800044cc:	30050513          	addi	a0,a0,768 # 800087c8 <userret+0x738>
    800044d0:	ffffc097          	auipc	ra,0xffffc
    800044d4:	0d2080e7          	jalr	210(ra) # 800005a2 <printf>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.

    if (log[dev].lh.n > 0) {
    800044d8:	0b000793          	li	a5,176
    800044dc:	02f48733          	mul	a4,s1,a5
    800044e0:	00025797          	auipc	a5,0x25
    800044e4:	5c078793          	addi	a5,a5,1472 # 80029aa0 <log>
    800044e8:	97ba                	add	a5,a5,a4
    800044ea:	5bdc                	lw	a5,52(a5)
    800044ec:	04f05a63          	blez	a5,80004540 <crash_op+0x10e>
      write_log(dev);     // Write modified blocks from cache to log
    800044f0:	8526                	mv	a0,s1
    800044f2:	00000097          	auipc	ra,0x0
    800044f6:	9ec080e7          	jalr	-1556(ra) # 80003ede <write_log>
      write_head(dev);    // Write header to disk -- the real commit
    800044fa:	8526                	mv	a0,s1
    800044fc:	00000097          	auipc	ra,0x0
    80004500:	958080e7          	jalr	-1704(ra) # 80003e54 <write_head>
    80004504:	a835                	j	80004540 <crash_op+0x10e>
    panic("end_op: invalid disk");
    80004506:	00004517          	auipc	a0,0x4
    8000450a:	29250513          	addi	a0,a0,658 # 80008798 <userret+0x708>
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	03a080e7          	jalr	58(ra) # 80000548 <panic>
    panic("end_op: already closed");
    80004516:	00004517          	auipc	a0,0x4
    8000451a:	29a50513          	addi	a0,a0,666 # 800087b0 <userret+0x720>
    8000451e:	ffffc097          	auipc	ra,0xffffc
    80004522:	02a080e7          	jalr	42(ra) # 80000548 <panic>
    panic("log[dev].committing");
    80004526:	00004517          	auipc	a0,0x4
    8000452a:	22250513          	addi	a0,a0,546 # 80008748 <userret+0x6b8>
    8000452e:	ffffc097          	auipc	ra,0xffffc
    80004532:	01a080e7          	jalr	26(ra) # 80000548 <panic>
  release(&log[dev].lock);
    80004536:	854a                	mv	a0,s2
    80004538:	ffffc097          	auipc	ra,0xffffc
    8000453c:	646080e7          	jalr	1606(ra) # 80000b7e <release>
    }
  }
  panic("crashed file system; please restart xv6 and run crashtest\n");
    80004540:	00004517          	auipc	a0,0x4
    80004544:	2a050513          	addi	a0,a0,672 # 800087e0 <userret+0x750>
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	000080e7          	jalr	ra # 80000548 <panic>

0000000080004550 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004550:	1101                	addi	sp,sp,-32
    80004552:	ec06                	sd	ra,24(sp)
    80004554:	e822                	sd	s0,16(sp)
    80004556:	e426                	sd	s1,8(sp)
    80004558:	e04a                	sd	s2,0(sp)
    8000455a:	1000                	addi	s0,sp,32
    8000455c:	84aa                	mv	s1,a0
    8000455e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004560:	00004597          	auipc	a1,0x4
    80004564:	2c058593          	addi	a1,a1,704 # 80008820 <userret+0x790>
    80004568:	0521                	addi	a0,a0,8
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	456080e7          	jalr	1110(ra) # 800009c0 <initlock>
  lk->name = name;
    80004572:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004576:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000457a:	0204a823          	sw	zero,48(s1)
}
    8000457e:	60e2                	ld	ra,24(sp)
    80004580:	6442                	ld	s0,16(sp)
    80004582:	64a2                	ld	s1,8(sp)
    80004584:	6902                	ld	s2,0(sp)
    80004586:	6105                	addi	sp,sp,32
    80004588:	8082                	ret

000000008000458a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000458a:	1101                	addi	sp,sp,-32
    8000458c:	ec06                	sd	ra,24(sp)
    8000458e:	e822                	sd	s0,16(sp)
    80004590:	e426                	sd	s1,8(sp)
    80004592:	e04a                	sd	s2,0(sp)
    80004594:	1000                	addi	s0,sp,32
    80004596:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004598:	00850913          	addi	s2,a0,8
    8000459c:	854a                	mv	a0,s2
    8000459e:	ffffc097          	auipc	ra,0xffffc
    800045a2:	570080e7          	jalr	1392(ra) # 80000b0e <acquire>
  while (lk->locked) {
    800045a6:	409c                	lw	a5,0(s1)
    800045a8:	cb89                	beqz	a5,800045ba <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045aa:	85ca                	mv	a1,s2
    800045ac:	8526                	mv	a0,s1
    800045ae:	ffffe097          	auipc	ra,0xffffe
    800045b2:	c98080e7          	jalr	-872(ra) # 80002246 <sleep>
  while (lk->locked) {
    800045b6:	409c                	lw	a5,0(s1)
    800045b8:	fbed                	bnez	a5,800045aa <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045ba:	4785                	li	a5,1
    800045bc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045be:	ffffd097          	auipc	ra,0xffffd
    800045c2:	4a4080e7          	jalr	1188(ra) # 80001a62 <myproc>
    800045c6:	413c                	lw	a5,64(a0)
    800045c8:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    800045ca:	854a                	mv	a0,s2
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	5b2080e7          	jalr	1458(ra) # 80000b7e <release>
}
    800045d4:	60e2                	ld	ra,24(sp)
    800045d6:	6442                	ld	s0,16(sp)
    800045d8:	64a2                	ld	s1,8(sp)
    800045da:	6902                	ld	s2,0(sp)
    800045dc:	6105                	addi	sp,sp,32
    800045de:	8082                	ret

00000000800045e0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045e0:	1101                	addi	sp,sp,-32
    800045e2:	ec06                	sd	ra,24(sp)
    800045e4:	e822                	sd	s0,16(sp)
    800045e6:	e426                	sd	s1,8(sp)
    800045e8:	e04a                	sd	s2,0(sp)
    800045ea:	1000                	addi	s0,sp,32
    800045ec:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045ee:	00850913          	addi	s2,a0,8
    800045f2:	854a                	mv	a0,s2
    800045f4:	ffffc097          	auipc	ra,0xffffc
    800045f8:	51a080e7          	jalr	1306(ra) # 80000b0e <acquire>
  lk->locked = 0;
    800045fc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004600:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    80004604:	8526                	mv	a0,s1
    80004606:	ffffe097          	auipc	ra,0xffffe
    8000460a:	dc0080e7          	jalr	-576(ra) # 800023c6 <wakeup>
  release(&lk->lk);
    8000460e:	854a                	mv	a0,s2
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	56e080e7          	jalr	1390(ra) # 80000b7e <release>
}
    80004618:	60e2                	ld	ra,24(sp)
    8000461a:	6442                	ld	s0,16(sp)
    8000461c:	64a2                	ld	s1,8(sp)
    8000461e:	6902                	ld	s2,0(sp)
    80004620:	6105                	addi	sp,sp,32
    80004622:	8082                	ret

0000000080004624 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004624:	7179                	addi	sp,sp,-48
    80004626:	f406                	sd	ra,40(sp)
    80004628:	f022                	sd	s0,32(sp)
    8000462a:	ec26                	sd	s1,24(sp)
    8000462c:	e84a                	sd	s2,16(sp)
    8000462e:	e44e                	sd	s3,8(sp)
    80004630:	1800                	addi	s0,sp,48
    80004632:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004634:	00850913          	addi	s2,a0,8
    80004638:	854a                	mv	a0,s2
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	4d4080e7          	jalr	1236(ra) # 80000b0e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004642:	409c                	lw	a5,0(s1)
    80004644:	ef99                	bnez	a5,80004662 <holdingsleep+0x3e>
    80004646:	4481                	li	s1,0
  release(&lk->lk);
    80004648:	854a                	mv	a0,s2
    8000464a:	ffffc097          	auipc	ra,0xffffc
    8000464e:	534080e7          	jalr	1332(ra) # 80000b7e <release>
  return r;
}
    80004652:	8526                	mv	a0,s1
    80004654:	70a2                	ld	ra,40(sp)
    80004656:	7402                	ld	s0,32(sp)
    80004658:	64e2                	ld	s1,24(sp)
    8000465a:	6942                	ld	s2,16(sp)
    8000465c:	69a2                	ld	s3,8(sp)
    8000465e:	6145                	addi	sp,sp,48
    80004660:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004662:	0304a983          	lw	s3,48(s1)
    80004666:	ffffd097          	auipc	ra,0xffffd
    8000466a:	3fc080e7          	jalr	1020(ra) # 80001a62 <myproc>
    8000466e:	4124                	lw	s1,64(a0)
    80004670:	413484b3          	sub	s1,s1,s3
    80004674:	0014b493          	seqz	s1,s1
    80004678:	bfc1                	j	80004648 <holdingsleep+0x24>

000000008000467a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000467a:	1141                	addi	sp,sp,-16
    8000467c:	e406                	sd	ra,8(sp)
    8000467e:	e022                	sd	s0,0(sp)
    80004680:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004682:	00004597          	auipc	a1,0x4
    80004686:	1ae58593          	addi	a1,a1,430 # 80008830 <userret+0x7a0>
    8000468a:	00025517          	auipc	a0,0x25
    8000468e:	61650513          	addi	a0,a0,1558 # 80029ca0 <ftable>
    80004692:	ffffc097          	auipc	ra,0xffffc
    80004696:	32e080e7          	jalr	814(ra) # 800009c0 <initlock>
}
    8000469a:	60a2                	ld	ra,8(sp)
    8000469c:	6402                	ld	s0,0(sp)
    8000469e:	0141                	addi	sp,sp,16
    800046a0:	8082                	ret

00000000800046a2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046a2:	1101                	addi	sp,sp,-32
    800046a4:	ec06                	sd	ra,24(sp)
    800046a6:	e822                	sd	s0,16(sp)
    800046a8:	e426                	sd	s1,8(sp)
    800046aa:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046ac:	00025517          	auipc	a0,0x25
    800046b0:	5f450513          	addi	a0,a0,1524 # 80029ca0 <ftable>
    800046b4:	ffffc097          	auipc	ra,0xffffc
    800046b8:	45a080e7          	jalr	1114(ra) # 80000b0e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046bc:	00025497          	auipc	s1,0x25
    800046c0:	60448493          	addi	s1,s1,1540 # 80029cc0 <ftable+0x20>
    800046c4:	00026717          	auipc	a4,0x26
    800046c8:	59c70713          	addi	a4,a4,1436 # 8002ac60 <ftable+0xfc0>
    if(f->ref == 0){
    800046cc:	40dc                	lw	a5,4(s1)
    800046ce:	cf99                	beqz	a5,800046ec <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046d0:	02848493          	addi	s1,s1,40
    800046d4:	fee49ce3          	bne	s1,a4,800046cc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046d8:	00025517          	auipc	a0,0x25
    800046dc:	5c850513          	addi	a0,a0,1480 # 80029ca0 <ftable>
    800046e0:	ffffc097          	auipc	ra,0xffffc
    800046e4:	49e080e7          	jalr	1182(ra) # 80000b7e <release>
  return 0;
    800046e8:	4481                	li	s1,0
    800046ea:	a819                	j	80004700 <filealloc+0x5e>
      f->ref = 1;
    800046ec:	4785                	li	a5,1
    800046ee:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046f0:	00025517          	auipc	a0,0x25
    800046f4:	5b050513          	addi	a0,a0,1456 # 80029ca0 <ftable>
    800046f8:	ffffc097          	auipc	ra,0xffffc
    800046fc:	486080e7          	jalr	1158(ra) # 80000b7e <release>
}
    80004700:	8526                	mv	a0,s1
    80004702:	60e2                	ld	ra,24(sp)
    80004704:	6442                	ld	s0,16(sp)
    80004706:	64a2                	ld	s1,8(sp)
    80004708:	6105                	addi	sp,sp,32
    8000470a:	8082                	ret

000000008000470c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000470c:	1101                	addi	sp,sp,-32
    8000470e:	ec06                	sd	ra,24(sp)
    80004710:	e822                	sd	s0,16(sp)
    80004712:	e426                	sd	s1,8(sp)
    80004714:	1000                	addi	s0,sp,32
    80004716:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004718:	00025517          	auipc	a0,0x25
    8000471c:	58850513          	addi	a0,a0,1416 # 80029ca0 <ftable>
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	3ee080e7          	jalr	1006(ra) # 80000b0e <acquire>
  if(f->ref < 1)
    80004728:	40dc                	lw	a5,4(s1)
    8000472a:	02f05263          	blez	a5,8000474e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000472e:	2785                	addiw	a5,a5,1
    80004730:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004732:	00025517          	auipc	a0,0x25
    80004736:	56e50513          	addi	a0,a0,1390 # 80029ca0 <ftable>
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	444080e7          	jalr	1092(ra) # 80000b7e <release>
  return f;
}
    80004742:	8526                	mv	a0,s1
    80004744:	60e2                	ld	ra,24(sp)
    80004746:	6442                	ld	s0,16(sp)
    80004748:	64a2                	ld	s1,8(sp)
    8000474a:	6105                	addi	sp,sp,32
    8000474c:	8082                	ret
    panic("filedup");
    8000474e:	00004517          	auipc	a0,0x4
    80004752:	0ea50513          	addi	a0,a0,234 # 80008838 <userret+0x7a8>
    80004756:	ffffc097          	auipc	ra,0xffffc
    8000475a:	df2080e7          	jalr	-526(ra) # 80000548 <panic>

000000008000475e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000475e:	7139                	addi	sp,sp,-64
    80004760:	fc06                	sd	ra,56(sp)
    80004762:	f822                	sd	s0,48(sp)
    80004764:	f426                	sd	s1,40(sp)
    80004766:	f04a                	sd	s2,32(sp)
    80004768:	ec4e                	sd	s3,24(sp)
    8000476a:	e852                	sd	s4,16(sp)
    8000476c:	e456                	sd	s5,8(sp)
    8000476e:	0080                	addi	s0,sp,64
    80004770:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004772:	00025517          	auipc	a0,0x25
    80004776:	52e50513          	addi	a0,a0,1326 # 80029ca0 <ftable>
    8000477a:	ffffc097          	auipc	ra,0xffffc
    8000477e:	394080e7          	jalr	916(ra) # 80000b0e <acquire>
  if(f->ref < 1)
    80004782:	40dc                	lw	a5,4(s1)
    80004784:	06f05563          	blez	a5,800047ee <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004788:	37fd                	addiw	a5,a5,-1
    8000478a:	0007871b          	sext.w	a4,a5
    8000478e:	c0dc                	sw	a5,4(s1)
    80004790:	06e04763          	bgtz	a4,800047fe <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004794:	0004a903          	lw	s2,0(s1)
    80004798:	0094ca83          	lbu	s5,9(s1)
    8000479c:	0104ba03          	ld	s4,16(s1)
    800047a0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047a4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047a8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047ac:	00025517          	auipc	a0,0x25
    800047b0:	4f450513          	addi	a0,a0,1268 # 80029ca0 <ftable>
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	3ca080e7          	jalr	970(ra) # 80000b7e <release>

  if(ff.type == FD_PIPE){
    800047bc:	4785                	li	a5,1
    800047be:	06f90163          	beq	s2,a5,80004820 <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047c2:	3979                	addiw	s2,s2,-2
    800047c4:	4785                	li	a5,1
    800047c6:	0527e463          	bltu	a5,s2,8000480e <fileclose+0xb0>
    begin_op(ff.ip->dev);
    800047ca:	0009a503          	lw	a0,0(s3)
    800047ce:	00000097          	auipc	ra,0x0
    800047d2:	968080e7          	jalr	-1688(ra) # 80004136 <begin_op>
    iput(ff.ip);
    800047d6:	854e                	mv	a0,s3
    800047d8:	fffff097          	auipc	ra,0xfffff
    800047dc:	fc6080e7          	jalr	-58(ra) # 8000379e <iput>
    end_op(ff.ip->dev);
    800047e0:	0009a503          	lw	a0,0(s3)
    800047e4:	00000097          	auipc	ra,0x0
    800047e8:	9fc080e7          	jalr	-1540(ra) # 800041e0 <end_op>
    800047ec:	a00d                	j	8000480e <fileclose+0xb0>
    panic("fileclose");
    800047ee:	00004517          	auipc	a0,0x4
    800047f2:	05250513          	addi	a0,a0,82 # 80008840 <userret+0x7b0>
    800047f6:	ffffc097          	auipc	ra,0xffffc
    800047fa:	d52080e7          	jalr	-686(ra) # 80000548 <panic>
    release(&ftable.lock);
    800047fe:	00025517          	auipc	a0,0x25
    80004802:	4a250513          	addi	a0,a0,1186 # 80029ca0 <ftable>
    80004806:	ffffc097          	auipc	ra,0xffffc
    8000480a:	378080e7          	jalr	888(ra) # 80000b7e <release>
  }
}
    8000480e:	70e2                	ld	ra,56(sp)
    80004810:	7442                	ld	s0,48(sp)
    80004812:	74a2                	ld	s1,40(sp)
    80004814:	7902                	ld	s2,32(sp)
    80004816:	69e2                	ld	s3,24(sp)
    80004818:	6a42                	ld	s4,16(sp)
    8000481a:	6aa2                	ld	s5,8(sp)
    8000481c:	6121                	addi	sp,sp,64
    8000481e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004820:	85d6                	mv	a1,s5
    80004822:	8552                	mv	a0,s4
    80004824:	00000097          	auipc	ra,0x0
    80004828:	378080e7          	jalr	888(ra) # 80004b9c <pipeclose>
    8000482c:	b7cd                	j	8000480e <fileclose+0xb0>

000000008000482e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000482e:	715d                	addi	sp,sp,-80
    80004830:	e486                	sd	ra,72(sp)
    80004832:	e0a2                	sd	s0,64(sp)
    80004834:	fc26                	sd	s1,56(sp)
    80004836:	f84a                	sd	s2,48(sp)
    80004838:	f44e                	sd	s3,40(sp)
    8000483a:	0880                	addi	s0,sp,80
    8000483c:	84aa                	mv	s1,a0
    8000483e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004840:	ffffd097          	auipc	ra,0xffffd
    80004844:	222080e7          	jalr	546(ra) # 80001a62 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004848:	409c                	lw	a5,0(s1)
    8000484a:	37f9                	addiw	a5,a5,-2
    8000484c:	4705                	li	a4,1
    8000484e:	04f76763          	bltu	a4,a5,8000489c <filestat+0x6e>
    80004852:	892a                	mv	s2,a0
    ilock(f->ip);
    80004854:	6c88                	ld	a0,24(s1)
    80004856:	fffff097          	auipc	ra,0xfffff
    8000485a:	e3a080e7          	jalr	-454(ra) # 80003690 <ilock>
    stati(f->ip, &st);
    8000485e:	fb840593          	addi	a1,s0,-72
    80004862:	6c88                	ld	a0,24(s1)
    80004864:	fffff097          	auipc	ra,0xfffff
    80004868:	092080e7          	jalr	146(ra) # 800038f6 <stati>
    iunlock(f->ip);
    8000486c:	6c88                	ld	a0,24(s1)
    8000486e:	fffff097          	auipc	ra,0xfffff
    80004872:	ee4080e7          	jalr	-284(ra) # 80003752 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004876:	46e1                	li	a3,24
    80004878:	fb840613          	addi	a2,s0,-72
    8000487c:	85ce                	mv	a1,s3
    8000487e:	05893503          	ld	a0,88(s2)
    80004882:	ffffd097          	auipc	ra,0xffffd
    80004886:	ed2080e7          	jalr	-302(ra) # 80001754 <copyout>
    8000488a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000488e:	60a6                	ld	ra,72(sp)
    80004890:	6406                	ld	s0,64(sp)
    80004892:	74e2                	ld	s1,56(sp)
    80004894:	7942                	ld	s2,48(sp)
    80004896:	79a2                	ld	s3,40(sp)
    80004898:	6161                	addi	sp,sp,80
    8000489a:	8082                	ret
  return -1;
    8000489c:	557d                	li	a0,-1
    8000489e:	bfc5                	j	8000488e <filestat+0x60>

00000000800048a0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048a0:	7179                	addi	sp,sp,-48
    800048a2:	f406                	sd	ra,40(sp)
    800048a4:	f022                	sd	s0,32(sp)
    800048a6:	ec26                	sd	s1,24(sp)
    800048a8:	e84a                	sd	s2,16(sp)
    800048aa:	e44e                	sd	s3,8(sp)
    800048ac:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048ae:	00854783          	lbu	a5,8(a0)
    800048b2:	c7c5                	beqz	a5,8000495a <fileread+0xba>
    800048b4:	84aa                	mv	s1,a0
    800048b6:	89ae                	mv	s3,a1
    800048b8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048ba:	411c                	lw	a5,0(a0)
    800048bc:	4705                	li	a4,1
    800048be:	04e78963          	beq	a5,a4,80004910 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048c2:	470d                	li	a4,3
    800048c4:	04e78d63          	beq	a5,a4,8000491e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800048c8:	4709                	li	a4,2
    800048ca:	08e79063          	bne	a5,a4,8000494a <fileread+0xaa>
    ilock(f->ip);
    800048ce:	6d08                	ld	a0,24(a0)
    800048d0:	fffff097          	auipc	ra,0xfffff
    800048d4:	dc0080e7          	jalr	-576(ra) # 80003690 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048d8:	874a                	mv	a4,s2
    800048da:	5094                	lw	a3,32(s1)
    800048dc:	864e                	mv	a2,s3
    800048de:	4585                	li	a1,1
    800048e0:	6c88                	ld	a0,24(s1)
    800048e2:	fffff097          	auipc	ra,0xfffff
    800048e6:	03e080e7          	jalr	62(ra) # 80003920 <readi>
    800048ea:	892a                	mv	s2,a0
    800048ec:	00a05563          	blez	a0,800048f6 <fileread+0x56>
      f->off += r;
    800048f0:	509c                	lw	a5,32(s1)
    800048f2:	9fa9                	addw	a5,a5,a0
    800048f4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048f6:	6c88                	ld	a0,24(s1)
    800048f8:	fffff097          	auipc	ra,0xfffff
    800048fc:	e5a080e7          	jalr	-422(ra) # 80003752 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004900:	854a                	mv	a0,s2
    80004902:	70a2                	ld	ra,40(sp)
    80004904:	7402                	ld	s0,32(sp)
    80004906:	64e2                	ld	s1,24(sp)
    80004908:	6942                	ld	s2,16(sp)
    8000490a:	69a2                	ld	s3,8(sp)
    8000490c:	6145                	addi	sp,sp,48
    8000490e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004910:	6908                	ld	a0,16(a0)
    80004912:	00000097          	auipc	ra,0x0
    80004916:	408080e7          	jalr	1032(ra) # 80004d1a <piperead>
    8000491a:	892a                	mv	s2,a0
    8000491c:	b7d5                	j	80004900 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000491e:	02451783          	lh	a5,36(a0)
    80004922:	03079693          	slli	a3,a5,0x30
    80004926:	92c1                	srli	a3,a3,0x30
    80004928:	4725                	li	a4,9
    8000492a:	02d76a63          	bltu	a4,a3,8000495e <fileread+0xbe>
    8000492e:	0792                	slli	a5,a5,0x4
    80004930:	00025717          	auipc	a4,0x25
    80004934:	2d070713          	addi	a4,a4,720 # 80029c00 <devsw>
    80004938:	97ba                	add	a5,a5,a4
    8000493a:	639c                	ld	a5,0(a5)
    8000493c:	c39d                	beqz	a5,80004962 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    8000493e:	86b2                	mv	a3,a2
    80004940:	862e                	mv	a2,a1
    80004942:	4585                	li	a1,1
    80004944:	9782                	jalr	a5
    80004946:	892a                	mv	s2,a0
    80004948:	bf65                	j	80004900 <fileread+0x60>
    panic("fileread");
    8000494a:	00004517          	auipc	a0,0x4
    8000494e:	f0650513          	addi	a0,a0,-250 # 80008850 <userret+0x7c0>
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	bf6080e7          	jalr	-1034(ra) # 80000548 <panic>
    return -1;
    8000495a:	597d                	li	s2,-1
    8000495c:	b755                	j	80004900 <fileread+0x60>
      return -1;
    8000495e:	597d                	li	s2,-1
    80004960:	b745                	j	80004900 <fileread+0x60>
    80004962:	597d                	li	s2,-1
    80004964:	bf71                	j	80004900 <fileread+0x60>

0000000080004966 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004966:	00954783          	lbu	a5,9(a0)
    8000496a:	14078663          	beqz	a5,80004ab6 <filewrite+0x150>
{
    8000496e:	715d                	addi	sp,sp,-80
    80004970:	e486                	sd	ra,72(sp)
    80004972:	e0a2                	sd	s0,64(sp)
    80004974:	fc26                	sd	s1,56(sp)
    80004976:	f84a                	sd	s2,48(sp)
    80004978:	f44e                	sd	s3,40(sp)
    8000497a:	f052                	sd	s4,32(sp)
    8000497c:	ec56                	sd	s5,24(sp)
    8000497e:	e85a                	sd	s6,16(sp)
    80004980:	e45e                	sd	s7,8(sp)
    80004982:	e062                	sd	s8,0(sp)
    80004984:	0880                	addi	s0,sp,80
    80004986:	84aa                	mv	s1,a0
    80004988:	8aae                	mv	s5,a1
    8000498a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000498c:	411c                	lw	a5,0(a0)
    8000498e:	4705                	li	a4,1
    80004990:	02e78263          	beq	a5,a4,800049b4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004994:	470d                	li	a4,3
    80004996:	02e78563          	beq	a5,a4,800049c0 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    8000499a:	4709                	li	a4,2
    8000499c:	10e79563          	bne	a5,a4,80004aa6 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049a0:	0ec05f63          	blez	a2,80004a9e <filewrite+0x138>
    int i = 0;
    800049a4:	4981                	li	s3,0
    800049a6:	6b05                	lui	s6,0x1
    800049a8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800049ac:	6b85                	lui	s7,0x1
    800049ae:	c00b8b9b          	addiw	s7,s7,-1024
    800049b2:	a851                	j	80004a46 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800049b4:	6908                	ld	a0,16(a0)
    800049b6:	00000097          	auipc	ra,0x0
    800049ba:	256080e7          	jalr	598(ra) # 80004c0c <pipewrite>
    800049be:	a865                	j	80004a76 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049c0:	02451783          	lh	a5,36(a0)
    800049c4:	03079693          	slli	a3,a5,0x30
    800049c8:	92c1                	srli	a3,a3,0x30
    800049ca:	4725                	li	a4,9
    800049cc:	0ed76763          	bltu	a4,a3,80004aba <filewrite+0x154>
    800049d0:	0792                	slli	a5,a5,0x4
    800049d2:	00025717          	auipc	a4,0x25
    800049d6:	22e70713          	addi	a4,a4,558 # 80029c00 <devsw>
    800049da:	97ba                	add	a5,a5,a4
    800049dc:	679c                	ld	a5,8(a5)
    800049de:	c3e5                	beqz	a5,80004abe <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    800049e0:	86b2                	mv	a3,a2
    800049e2:	862e                	mv	a2,a1
    800049e4:	4585                	li	a1,1
    800049e6:	9782                	jalr	a5
    800049e8:	a079                	j	80004a76 <filewrite+0x110>
    800049ea:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    800049ee:	6c9c                	ld	a5,24(s1)
    800049f0:	4388                	lw	a0,0(a5)
    800049f2:	fffff097          	auipc	ra,0xfffff
    800049f6:	744080e7          	jalr	1860(ra) # 80004136 <begin_op>
      ilock(f->ip);
    800049fa:	6c88                	ld	a0,24(s1)
    800049fc:	fffff097          	auipc	ra,0xfffff
    80004a00:	c94080e7          	jalr	-876(ra) # 80003690 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a04:	8762                	mv	a4,s8
    80004a06:	5094                	lw	a3,32(s1)
    80004a08:	01598633          	add	a2,s3,s5
    80004a0c:	4585                	li	a1,1
    80004a0e:	6c88                	ld	a0,24(s1)
    80004a10:	fffff097          	auipc	ra,0xfffff
    80004a14:	004080e7          	jalr	4(ra) # 80003a14 <writei>
    80004a18:	892a                	mv	s2,a0
    80004a1a:	02a05e63          	blez	a0,80004a56 <filewrite+0xf0>
        f->off += r;
    80004a1e:	509c                	lw	a5,32(s1)
    80004a20:	9fa9                	addw	a5,a5,a0
    80004a22:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004a24:	6c88                	ld	a0,24(s1)
    80004a26:	fffff097          	auipc	ra,0xfffff
    80004a2a:	d2c080e7          	jalr	-724(ra) # 80003752 <iunlock>
      end_op(f->ip->dev);
    80004a2e:	6c9c                	ld	a5,24(s1)
    80004a30:	4388                	lw	a0,0(a5)
    80004a32:	fffff097          	auipc	ra,0xfffff
    80004a36:	7ae080e7          	jalr	1966(ra) # 800041e0 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004a3a:	052c1a63          	bne	s8,s2,80004a8e <filewrite+0x128>
        panic("short filewrite");
      i += r;
    80004a3e:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80004a42:	0349d763          	bge	s3,s4,80004a70 <filewrite+0x10a>
      int n1 = n - i;
    80004a46:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a4a:	893e                	mv	s2,a5
    80004a4c:	2781                	sext.w	a5,a5
    80004a4e:	f8fb5ee3          	bge	s6,a5,800049ea <filewrite+0x84>
    80004a52:	895e                	mv	s2,s7
    80004a54:	bf59                	j	800049ea <filewrite+0x84>
      iunlock(f->ip);
    80004a56:	6c88                	ld	a0,24(s1)
    80004a58:	fffff097          	auipc	ra,0xfffff
    80004a5c:	cfa080e7          	jalr	-774(ra) # 80003752 <iunlock>
      end_op(f->ip->dev);
    80004a60:	6c9c                	ld	a5,24(s1)
    80004a62:	4388                	lw	a0,0(a5)
    80004a64:	fffff097          	auipc	ra,0xfffff
    80004a68:	77c080e7          	jalr	1916(ra) # 800041e0 <end_op>
      if(r < 0)
    80004a6c:	fc0957e3          	bgez	s2,80004a3a <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004a70:	8552                	mv	a0,s4
    80004a72:	033a1863          	bne	s4,s3,80004aa2 <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a76:	60a6                	ld	ra,72(sp)
    80004a78:	6406                	ld	s0,64(sp)
    80004a7a:	74e2                	ld	s1,56(sp)
    80004a7c:	7942                	ld	s2,48(sp)
    80004a7e:	79a2                	ld	s3,40(sp)
    80004a80:	7a02                	ld	s4,32(sp)
    80004a82:	6ae2                	ld	s5,24(sp)
    80004a84:	6b42                	ld	s6,16(sp)
    80004a86:	6ba2                	ld	s7,8(sp)
    80004a88:	6c02                	ld	s8,0(sp)
    80004a8a:	6161                	addi	sp,sp,80
    80004a8c:	8082                	ret
        panic("short filewrite");
    80004a8e:	00004517          	auipc	a0,0x4
    80004a92:	dd250513          	addi	a0,a0,-558 # 80008860 <userret+0x7d0>
    80004a96:	ffffc097          	auipc	ra,0xffffc
    80004a9a:	ab2080e7          	jalr	-1358(ra) # 80000548 <panic>
    int i = 0;
    80004a9e:	4981                	li	s3,0
    80004aa0:	bfc1                	j	80004a70 <filewrite+0x10a>
    ret = (i == n ? n : -1);
    80004aa2:	557d                	li	a0,-1
    80004aa4:	bfc9                	j	80004a76 <filewrite+0x110>
    panic("filewrite");
    80004aa6:	00004517          	auipc	a0,0x4
    80004aaa:	dca50513          	addi	a0,a0,-566 # 80008870 <userret+0x7e0>
    80004aae:	ffffc097          	auipc	ra,0xffffc
    80004ab2:	a9a080e7          	jalr	-1382(ra) # 80000548 <panic>
    return -1;
    80004ab6:	557d                	li	a0,-1
}
    80004ab8:	8082                	ret
      return -1;
    80004aba:	557d                	li	a0,-1
    80004abc:	bf6d                	j	80004a76 <filewrite+0x110>
    80004abe:	557d                	li	a0,-1
    80004ac0:	bf5d                	j	80004a76 <filewrite+0x110>

0000000080004ac2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ac2:	7179                	addi	sp,sp,-48
    80004ac4:	f406                	sd	ra,40(sp)
    80004ac6:	f022                	sd	s0,32(sp)
    80004ac8:	ec26                	sd	s1,24(sp)
    80004aca:	e84a                	sd	s2,16(sp)
    80004acc:	e44e                	sd	s3,8(sp)
    80004ace:	e052                	sd	s4,0(sp)
    80004ad0:	1800                	addi	s0,sp,48
    80004ad2:	84aa                	mv	s1,a0
    80004ad4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ad6:	0005b023          	sd	zero,0(a1)
    80004ada:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ade:	00000097          	auipc	ra,0x0
    80004ae2:	bc4080e7          	jalr	-1084(ra) # 800046a2 <filealloc>
    80004ae6:	e088                	sd	a0,0(s1)
    80004ae8:	c551                	beqz	a0,80004b74 <pipealloc+0xb2>
    80004aea:	00000097          	auipc	ra,0x0
    80004aee:	bb8080e7          	jalr	-1096(ra) # 800046a2 <filealloc>
    80004af2:	00aa3023          	sd	a0,0(s4)
    80004af6:	c92d                	beqz	a0,80004b68 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004af8:	ffffc097          	auipc	ra,0xffffc
    80004afc:	e68080e7          	jalr	-408(ra) # 80000960 <kalloc>
    80004b00:	892a                	mv	s2,a0
    80004b02:	c125                	beqz	a0,80004b62 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b04:	4985                	li	s3,1
    80004b06:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004b0a:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004b0e:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004b12:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004b16:	00004597          	auipc	a1,0x4
    80004b1a:	d6a58593          	addi	a1,a1,-662 # 80008880 <userret+0x7f0>
    80004b1e:	ffffc097          	auipc	ra,0xffffc
    80004b22:	ea2080e7          	jalr	-350(ra) # 800009c0 <initlock>
  (*f0)->type = FD_PIPE;
    80004b26:	609c                	ld	a5,0(s1)
    80004b28:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b2c:	609c                	ld	a5,0(s1)
    80004b2e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b32:	609c                	ld	a5,0(s1)
    80004b34:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b38:	609c                	ld	a5,0(s1)
    80004b3a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b3e:	000a3783          	ld	a5,0(s4)
    80004b42:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b46:	000a3783          	ld	a5,0(s4)
    80004b4a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b4e:	000a3783          	ld	a5,0(s4)
    80004b52:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b56:	000a3783          	ld	a5,0(s4)
    80004b5a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b5e:	4501                	li	a0,0
    80004b60:	a025                	j	80004b88 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b62:	6088                	ld	a0,0(s1)
    80004b64:	e501                	bnez	a0,80004b6c <pipealloc+0xaa>
    80004b66:	a039                	j	80004b74 <pipealloc+0xb2>
    80004b68:	6088                	ld	a0,0(s1)
    80004b6a:	c51d                	beqz	a0,80004b98 <pipealloc+0xd6>
    fileclose(*f0);
    80004b6c:	00000097          	auipc	ra,0x0
    80004b70:	bf2080e7          	jalr	-1038(ra) # 8000475e <fileclose>
  if(*f1)
    80004b74:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b78:	557d                	li	a0,-1
  if(*f1)
    80004b7a:	c799                	beqz	a5,80004b88 <pipealloc+0xc6>
    fileclose(*f1);
    80004b7c:	853e                	mv	a0,a5
    80004b7e:	00000097          	auipc	ra,0x0
    80004b82:	be0080e7          	jalr	-1056(ra) # 8000475e <fileclose>
  return -1;
    80004b86:	557d                	li	a0,-1
}
    80004b88:	70a2                	ld	ra,40(sp)
    80004b8a:	7402                	ld	s0,32(sp)
    80004b8c:	64e2                	ld	s1,24(sp)
    80004b8e:	6942                	ld	s2,16(sp)
    80004b90:	69a2                	ld	s3,8(sp)
    80004b92:	6a02                	ld	s4,0(sp)
    80004b94:	6145                	addi	sp,sp,48
    80004b96:	8082                	ret
  return -1;
    80004b98:	557d                	li	a0,-1
    80004b9a:	b7fd                	j	80004b88 <pipealloc+0xc6>

0000000080004b9c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b9c:	1101                	addi	sp,sp,-32
    80004b9e:	ec06                	sd	ra,24(sp)
    80004ba0:	e822                	sd	s0,16(sp)
    80004ba2:	e426                	sd	s1,8(sp)
    80004ba4:	e04a                	sd	s2,0(sp)
    80004ba6:	1000                	addi	s0,sp,32
    80004ba8:	84aa                	mv	s1,a0
    80004baa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	f62080e7          	jalr	-158(ra) # 80000b0e <acquire>
  if(writable){
    80004bb4:	02090d63          	beqz	s2,80004bee <pipeclose+0x52>
    pi->writeopen = 0;
    80004bb8:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004bbc:	22048513          	addi	a0,s1,544
    80004bc0:	ffffe097          	auipc	ra,0xffffe
    80004bc4:	806080e7          	jalr	-2042(ra) # 800023c6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bc8:	2284b783          	ld	a5,552(s1)
    80004bcc:	eb95                	bnez	a5,80004c00 <pipeclose+0x64>
    release(&pi->lock);
    80004bce:	8526                	mv	a0,s1
    80004bd0:	ffffc097          	auipc	ra,0xffffc
    80004bd4:	fae080e7          	jalr	-82(ra) # 80000b7e <release>
    kfree((char*)pi);
    80004bd8:	8526                	mv	a0,s1
    80004bda:	ffffc097          	auipc	ra,0xffffc
    80004bde:	c8a080e7          	jalr	-886(ra) # 80000864 <kfree>
  } else
    release(&pi->lock);
}
    80004be2:	60e2                	ld	ra,24(sp)
    80004be4:	6442                	ld	s0,16(sp)
    80004be6:	64a2                	ld	s1,8(sp)
    80004be8:	6902                	ld	s2,0(sp)
    80004bea:	6105                	addi	sp,sp,32
    80004bec:	8082                	ret
    pi->readopen = 0;
    80004bee:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004bf2:	22448513          	addi	a0,s1,548
    80004bf6:	ffffd097          	auipc	ra,0xffffd
    80004bfa:	7d0080e7          	jalr	2000(ra) # 800023c6 <wakeup>
    80004bfe:	b7e9                	j	80004bc8 <pipeclose+0x2c>
    release(&pi->lock);
    80004c00:	8526                	mv	a0,s1
    80004c02:	ffffc097          	auipc	ra,0xffffc
    80004c06:	f7c080e7          	jalr	-132(ra) # 80000b7e <release>
}
    80004c0a:	bfe1                	j	80004be2 <pipeclose+0x46>

0000000080004c0c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c0c:	711d                	addi	sp,sp,-96
    80004c0e:	ec86                	sd	ra,88(sp)
    80004c10:	e8a2                	sd	s0,80(sp)
    80004c12:	e4a6                	sd	s1,72(sp)
    80004c14:	e0ca                	sd	s2,64(sp)
    80004c16:	fc4e                	sd	s3,56(sp)
    80004c18:	f852                	sd	s4,48(sp)
    80004c1a:	f456                	sd	s5,40(sp)
    80004c1c:	f05a                	sd	s6,32(sp)
    80004c1e:	ec5e                	sd	s7,24(sp)
    80004c20:	e862                	sd	s8,16(sp)
    80004c22:	1080                	addi	s0,sp,96
    80004c24:	84aa                	mv	s1,a0
    80004c26:	8aae                	mv	s5,a1
    80004c28:	8a32                	mv	s4,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004c2a:	ffffd097          	auipc	ra,0xffffd
    80004c2e:	e38080e7          	jalr	-456(ra) # 80001a62 <myproc>
    80004c32:	8baa                	mv	s7,a0

  acquire(&pi->lock);
    80004c34:	8526                	mv	a0,s1
    80004c36:	ffffc097          	auipc	ra,0xffffc
    80004c3a:	ed8080e7          	jalr	-296(ra) # 80000b0e <acquire>
  for(i = 0; i < n; i++){
    80004c3e:	09405f63          	blez	s4,80004cdc <pipewrite+0xd0>
    80004c42:	fffa0b1b          	addiw	s6,s4,-1
    80004c46:	1b02                	slli	s6,s6,0x20
    80004c48:	020b5b13          	srli	s6,s6,0x20
    80004c4c:	001a8793          	addi	a5,s5,1
    80004c50:	9b3e                	add	s6,s6,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c52:	22048993          	addi	s3,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004c56:	22448913          	addi	s2,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c5a:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c5c:	2204a783          	lw	a5,544(s1)
    80004c60:	2244a703          	lw	a4,548(s1)
    80004c64:	2007879b          	addiw	a5,a5,512
    80004c68:	02f71e63          	bne	a4,a5,80004ca4 <pipewrite+0x98>
      if(pi->readopen == 0 || myproc()->killed){
    80004c6c:	2284a783          	lw	a5,552(s1)
    80004c70:	c3d9                	beqz	a5,80004cf6 <pipewrite+0xea>
    80004c72:	ffffd097          	auipc	ra,0xffffd
    80004c76:	df0080e7          	jalr	-528(ra) # 80001a62 <myproc>
    80004c7a:	5d1c                	lw	a5,56(a0)
    80004c7c:	efad                	bnez	a5,80004cf6 <pipewrite+0xea>
      wakeup(&pi->nread);
    80004c7e:	854e                	mv	a0,s3
    80004c80:	ffffd097          	auipc	ra,0xffffd
    80004c84:	746080e7          	jalr	1862(ra) # 800023c6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c88:	85a6                	mv	a1,s1
    80004c8a:	854a                	mv	a0,s2
    80004c8c:	ffffd097          	auipc	ra,0xffffd
    80004c90:	5ba080e7          	jalr	1466(ra) # 80002246 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c94:	2204a783          	lw	a5,544(s1)
    80004c98:	2244a703          	lw	a4,548(s1)
    80004c9c:	2007879b          	addiw	a5,a5,512
    80004ca0:	fcf706e3          	beq	a4,a5,80004c6c <pipewrite+0x60>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ca4:	4685                	li	a3,1
    80004ca6:	8656                	mv	a2,s5
    80004ca8:	faf40593          	addi	a1,s0,-81
    80004cac:	058bb503          	ld	a0,88(s7) # 1058 <_entry-0x7fffefa8>
    80004cb0:	ffffd097          	auipc	ra,0xffffd
    80004cb4:	b30080e7          	jalr	-1232(ra) # 800017e0 <copyin>
    80004cb8:	03850263          	beq	a0,s8,80004cdc <pipewrite+0xd0>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cbc:	2244a783          	lw	a5,548(s1)
    80004cc0:	0017871b          	addiw	a4,a5,1
    80004cc4:	22e4a223          	sw	a4,548(s1)
    80004cc8:	1ff7f793          	andi	a5,a5,511
    80004ccc:	97a6                	add	a5,a5,s1
    80004cce:	faf44703          	lbu	a4,-81(s0)
    80004cd2:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004cd6:	0a85                	addi	s5,s5,1
    80004cd8:	f96a92e3          	bne	s5,s6,80004c5c <pipewrite+0x50>
  }
  wakeup(&pi->nread);
    80004cdc:	22048513          	addi	a0,s1,544
    80004ce0:	ffffd097          	auipc	ra,0xffffd
    80004ce4:	6e6080e7          	jalr	1766(ra) # 800023c6 <wakeup>
  release(&pi->lock);
    80004ce8:	8526                	mv	a0,s1
    80004cea:	ffffc097          	auipc	ra,0xffffc
    80004cee:	e94080e7          	jalr	-364(ra) # 80000b7e <release>
  return n;
    80004cf2:	8552                	mv	a0,s4
    80004cf4:	a039                	j	80004d02 <pipewrite+0xf6>
        release(&pi->lock);
    80004cf6:	8526                	mv	a0,s1
    80004cf8:	ffffc097          	auipc	ra,0xffffc
    80004cfc:	e86080e7          	jalr	-378(ra) # 80000b7e <release>
        return -1;
    80004d00:	557d                	li	a0,-1
}
    80004d02:	60e6                	ld	ra,88(sp)
    80004d04:	6446                	ld	s0,80(sp)
    80004d06:	64a6                	ld	s1,72(sp)
    80004d08:	6906                	ld	s2,64(sp)
    80004d0a:	79e2                	ld	s3,56(sp)
    80004d0c:	7a42                	ld	s4,48(sp)
    80004d0e:	7aa2                	ld	s5,40(sp)
    80004d10:	7b02                	ld	s6,32(sp)
    80004d12:	6be2                	ld	s7,24(sp)
    80004d14:	6c42                	ld	s8,16(sp)
    80004d16:	6125                	addi	sp,sp,96
    80004d18:	8082                	ret

0000000080004d1a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d1a:	715d                	addi	sp,sp,-80
    80004d1c:	e486                	sd	ra,72(sp)
    80004d1e:	e0a2                	sd	s0,64(sp)
    80004d20:	fc26                	sd	s1,56(sp)
    80004d22:	f84a                	sd	s2,48(sp)
    80004d24:	f44e                	sd	s3,40(sp)
    80004d26:	f052                	sd	s4,32(sp)
    80004d28:	ec56                	sd	s5,24(sp)
    80004d2a:	e85a                	sd	s6,16(sp)
    80004d2c:	0880                	addi	s0,sp,80
    80004d2e:	84aa                	mv	s1,a0
    80004d30:	892e                	mv	s2,a1
    80004d32:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004d34:	ffffd097          	auipc	ra,0xffffd
    80004d38:	d2e080e7          	jalr	-722(ra) # 80001a62 <myproc>
    80004d3c:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004d3e:	8526                	mv	a0,s1
    80004d40:	ffffc097          	auipc	ra,0xffffc
    80004d44:	dce080e7          	jalr	-562(ra) # 80000b0e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d48:	2204a703          	lw	a4,544(s1)
    80004d4c:	2244a783          	lw	a5,548(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d50:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d54:	02f71763          	bne	a4,a5,80004d82 <piperead+0x68>
    80004d58:	22c4a783          	lw	a5,556(s1)
    80004d5c:	c39d                	beqz	a5,80004d82 <piperead+0x68>
    if(myproc()->killed){
    80004d5e:	ffffd097          	auipc	ra,0xffffd
    80004d62:	d04080e7          	jalr	-764(ra) # 80001a62 <myproc>
    80004d66:	5d1c                	lw	a5,56(a0)
    80004d68:	ebc1                	bnez	a5,80004df8 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d6a:	85a6                	mv	a1,s1
    80004d6c:	854e                	mv	a0,s3
    80004d6e:	ffffd097          	auipc	ra,0xffffd
    80004d72:	4d8080e7          	jalr	1240(ra) # 80002246 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d76:	2204a703          	lw	a4,544(s1)
    80004d7a:	2244a783          	lw	a5,548(s1)
    80004d7e:	fcf70de3          	beq	a4,a5,80004d58 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d82:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d84:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d86:	05405363          	blez	s4,80004dcc <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004d8a:	2204a783          	lw	a5,544(s1)
    80004d8e:	2244a703          	lw	a4,548(s1)
    80004d92:	02f70d63          	beq	a4,a5,80004dcc <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d96:	0017871b          	addiw	a4,a5,1
    80004d9a:	22e4a023          	sw	a4,544(s1)
    80004d9e:	1ff7f793          	andi	a5,a5,511
    80004da2:	97a6                	add	a5,a5,s1
    80004da4:	0207c783          	lbu	a5,32(a5)
    80004da8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dac:	4685                	li	a3,1
    80004dae:	fbf40613          	addi	a2,s0,-65
    80004db2:	85ca                	mv	a1,s2
    80004db4:	058ab503          	ld	a0,88(s5)
    80004db8:	ffffd097          	auipc	ra,0xffffd
    80004dbc:	99c080e7          	jalr	-1636(ra) # 80001754 <copyout>
    80004dc0:	01650663          	beq	a0,s6,80004dcc <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dc4:	2985                	addiw	s3,s3,1
    80004dc6:	0905                	addi	s2,s2,1
    80004dc8:	fd3a11e3          	bne	s4,s3,80004d8a <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dcc:	22448513          	addi	a0,s1,548
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	5f6080e7          	jalr	1526(ra) # 800023c6 <wakeup>
  release(&pi->lock);
    80004dd8:	8526                	mv	a0,s1
    80004dda:	ffffc097          	auipc	ra,0xffffc
    80004dde:	da4080e7          	jalr	-604(ra) # 80000b7e <release>
  return i;
}
    80004de2:	854e                	mv	a0,s3
    80004de4:	60a6                	ld	ra,72(sp)
    80004de6:	6406                	ld	s0,64(sp)
    80004de8:	74e2                	ld	s1,56(sp)
    80004dea:	7942                	ld	s2,48(sp)
    80004dec:	79a2                	ld	s3,40(sp)
    80004dee:	7a02                	ld	s4,32(sp)
    80004df0:	6ae2                	ld	s5,24(sp)
    80004df2:	6b42                	ld	s6,16(sp)
    80004df4:	6161                	addi	sp,sp,80
    80004df6:	8082                	ret
      release(&pi->lock);
    80004df8:	8526                	mv	a0,s1
    80004dfa:	ffffc097          	auipc	ra,0xffffc
    80004dfe:	d84080e7          	jalr	-636(ra) # 80000b7e <release>
      return -1;
    80004e02:	59fd                	li	s3,-1
    80004e04:	bff9                	j	80004de2 <piperead+0xc8>

0000000080004e06 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e06:	de010113          	addi	sp,sp,-544
    80004e0a:	20113c23          	sd	ra,536(sp)
    80004e0e:	20813823          	sd	s0,528(sp)
    80004e12:	20913423          	sd	s1,520(sp)
    80004e16:	21213023          	sd	s2,512(sp)
    80004e1a:	ffce                	sd	s3,504(sp)
    80004e1c:	fbd2                	sd	s4,496(sp)
    80004e1e:	f7d6                	sd	s5,488(sp)
    80004e20:	f3da                	sd	s6,480(sp)
    80004e22:	efde                	sd	s7,472(sp)
    80004e24:	ebe2                	sd	s8,464(sp)
    80004e26:	e7e6                	sd	s9,456(sp)
    80004e28:	e3ea                	sd	s10,448(sp)
    80004e2a:	ff6e                	sd	s11,440(sp)
    80004e2c:	1400                	addi	s0,sp,544
    80004e2e:	892a                	mv	s2,a0
    80004e30:	dea43423          	sd	a0,-536(s0)
    80004e34:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e38:	ffffd097          	auipc	ra,0xffffd
    80004e3c:	c2a080e7          	jalr	-982(ra) # 80001a62 <myproc>
    80004e40:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    80004e42:	4501                	li	a0,0
    80004e44:	fffff097          	auipc	ra,0xfffff
    80004e48:	2f2080e7          	jalr	754(ra) # 80004136 <begin_op>

  if((ip = namei(path)) == 0){
    80004e4c:	854a                	mv	a0,s2
    80004e4e:	fffff097          	auipc	ra,0xfffff
    80004e52:	fcc080e7          	jalr	-52(ra) # 80003e1a <namei>
    80004e56:	cd25                	beqz	a0,80004ece <exec+0xc8>
    80004e58:	8aaa                	mv	s5,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004e5a:	fffff097          	auipc	ra,0xfffff
    80004e5e:	836080e7          	jalr	-1994(ra) # 80003690 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e62:	04000713          	li	a4,64
    80004e66:	4681                	li	a3,0
    80004e68:	e4840613          	addi	a2,s0,-440
    80004e6c:	4581                	li	a1,0
    80004e6e:	8556                	mv	a0,s5
    80004e70:	fffff097          	auipc	ra,0xfffff
    80004e74:	ab0080e7          	jalr	-1360(ra) # 80003920 <readi>
    80004e78:	04000793          	li	a5,64
    80004e7c:	00f51a63          	bne	a0,a5,80004e90 <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e80:	e4842703          	lw	a4,-440(s0)
    80004e84:	464c47b7          	lui	a5,0x464c4
    80004e88:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e8c:	04f70863          	beq	a4,a5,80004edc <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e90:	8556                	mv	a0,s5
    80004e92:	fffff097          	auipc	ra,0xfffff
    80004e96:	a3c080e7          	jalr	-1476(ra) # 800038ce <iunlockput>
    end_op(ROOTDEV);
    80004e9a:	4501                	li	a0,0
    80004e9c:	fffff097          	auipc	ra,0xfffff
    80004ea0:	344080e7          	jalr	836(ra) # 800041e0 <end_op>
  }
  return -1;
    80004ea4:	557d                	li	a0,-1
}
    80004ea6:	21813083          	ld	ra,536(sp)
    80004eaa:	21013403          	ld	s0,528(sp)
    80004eae:	20813483          	ld	s1,520(sp)
    80004eb2:	20013903          	ld	s2,512(sp)
    80004eb6:	79fe                	ld	s3,504(sp)
    80004eb8:	7a5e                	ld	s4,496(sp)
    80004eba:	7abe                	ld	s5,488(sp)
    80004ebc:	7b1e                	ld	s6,480(sp)
    80004ebe:	6bfe                	ld	s7,472(sp)
    80004ec0:	6c5e                	ld	s8,464(sp)
    80004ec2:	6cbe                	ld	s9,456(sp)
    80004ec4:	6d1e                	ld	s10,448(sp)
    80004ec6:	7dfa                	ld	s11,440(sp)
    80004ec8:	22010113          	addi	sp,sp,544
    80004ecc:	8082                	ret
    end_op(ROOTDEV);
    80004ece:	4501                	li	a0,0
    80004ed0:	fffff097          	auipc	ra,0xfffff
    80004ed4:	310080e7          	jalr	784(ra) # 800041e0 <end_op>
    return -1;
    80004ed8:	557d                	li	a0,-1
    80004eda:	b7f1                	j	80004ea6 <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    80004edc:	8526                	mv	a0,s1
    80004ede:	ffffd097          	auipc	ra,0xffffd
    80004ee2:	c48080e7          	jalr	-952(ra) # 80001b26 <proc_pagetable>
    80004ee6:	8b2a                	mv	s6,a0
    80004ee8:	d545                	beqz	a0,80004e90 <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004eea:	e6842783          	lw	a5,-408(s0)
    80004eee:	e8045703          	lhu	a4,-384(s0)
    80004ef2:	10070263          	beqz	a4,80004ff6 <exec+0x1f0>
  sz = 0;
    80004ef6:	de043c23          	sd	zero,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004efa:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004efe:	6a05                	lui	s4,0x1
    80004f00:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f04:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004f08:	6d85                	lui	s11,0x1
    80004f0a:	7d7d                	lui	s10,0xfffff
    80004f0c:	a88d                	j	80004f7e <exec+0x178>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f0e:	00004517          	auipc	a0,0x4
    80004f12:	97a50513          	addi	a0,a0,-1670 # 80008888 <userret+0x7f8>
    80004f16:	ffffb097          	auipc	ra,0xffffb
    80004f1a:	632080e7          	jalr	1586(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f1e:	874a                	mv	a4,s2
    80004f20:	009c86bb          	addw	a3,s9,s1
    80004f24:	4581                	li	a1,0
    80004f26:	8556                	mv	a0,s5
    80004f28:	fffff097          	auipc	ra,0xfffff
    80004f2c:	9f8080e7          	jalr	-1544(ra) # 80003920 <readi>
    80004f30:	2501                	sext.w	a0,a0
    80004f32:	10a91863          	bne	s2,a0,80005042 <exec+0x23c>
  for(i = 0; i < sz; i += PGSIZE){
    80004f36:	009d84bb          	addw	s1,s11,s1
    80004f3a:	013d09bb          	addw	s3,s10,s3
    80004f3e:	0374f263          	bgeu	s1,s7,80004f62 <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    80004f42:	02049593          	slli	a1,s1,0x20
    80004f46:	9181                	srli	a1,a1,0x20
    80004f48:	95e2                	add	a1,a1,s8
    80004f4a:	855a                	mv	a0,s6
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	226080e7          	jalr	550(ra) # 80001172 <walkaddr>
    80004f54:	862a                	mv	a2,a0
    if(pa == 0)
    80004f56:	dd45                	beqz	a0,80004f0e <exec+0x108>
      n = PGSIZE;
    80004f58:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f5a:	fd49f2e3          	bgeu	s3,s4,80004f1e <exec+0x118>
      n = sz - i;
    80004f5e:	894e                	mv	s2,s3
    80004f60:	bf7d                	j	80004f1e <exec+0x118>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f62:	e0843783          	ld	a5,-504(s0)
    80004f66:	0017869b          	addiw	a3,a5,1
    80004f6a:	e0d43423          	sd	a3,-504(s0)
    80004f6e:	e0043783          	ld	a5,-512(s0)
    80004f72:	0387879b          	addiw	a5,a5,56
    80004f76:	e8045703          	lhu	a4,-384(s0)
    80004f7a:	08e6d063          	bge	a3,a4,80004ffa <exec+0x1f4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f7e:	2781                	sext.w	a5,a5
    80004f80:	e0f43023          	sd	a5,-512(s0)
    80004f84:	03800713          	li	a4,56
    80004f88:	86be                	mv	a3,a5
    80004f8a:	e1040613          	addi	a2,s0,-496
    80004f8e:	4581                	li	a1,0
    80004f90:	8556                	mv	a0,s5
    80004f92:	fffff097          	auipc	ra,0xfffff
    80004f96:	98e080e7          	jalr	-1650(ra) # 80003920 <readi>
    80004f9a:	03800793          	li	a5,56
    80004f9e:	0af51263          	bne	a0,a5,80005042 <exec+0x23c>
    if(ph.type != ELF_PROG_LOAD)
    80004fa2:	e1042783          	lw	a5,-496(s0)
    80004fa6:	4705                	li	a4,1
    80004fa8:	fae79de3          	bne	a5,a4,80004f62 <exec+0x15c>
    if(ph.memsz < ph.filesz)
    80004fac:	e3843603          	ld	a2,-456(s0)
    80004fb0:	e3043783          	ld	a5,-464(s0)
    80004fb4:	08f66763          	bltu	a2,a5,80005042 <exec+0x23c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fb8:	e2043783          	ld	a5,-480(s0)
    80004fbc:	963e                	add	a2,a2,a5
    80004fbe:	08f66263          	bltu	a2,a5,80005042 <exec+0x23c>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fc2:	df843583          	ld	a1,-520(s0)
    80004fc6:	855a                	mv	a0,s6
    80004fc8:	ffffc097          	auipc	ra,0xffffc
    80004fcc:	5b2080e7          	jalr	1458(ra) # 8000157a <uvmalloc>
    80004fd0:	dea43c23          	sd	a0,-520(s0)
    80004fd4:	c53d                	beqz	a0,80005042 <exec+0x23c>
    if(ph.vaddr % PGSIZE != 0)
    80004fd6:	e2043c03          	ld	s8,-480(s0)
    80004fda:	de043783          	ld	a5,-544(s0)
    80004fde:	00fc77b3          	and	a5,s8,a5
    80004fe2:	e3a5                	bnez	a5,80005042 <exec+0x23c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fe4:	e1842c83          	lw	s9,-488(s0)
    80004fe8:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fec:	f60b8be3          	beqz	s7,80004f62 <exec+0x15c>
    80004ff0:	89de                	mv	s3,s7
    80004ff2:	4481                	li	s1,0
    80004ff4:	b7b9                	j	80004f42 <exec+0x13c>
  sz = 0;
    80004ff6:	de043c23          	sd	zero,-520(s0)
  iunlockput(ip);
    80004ffa:	8556                	mv	a0,s5
    80004ffc:	fffff097          	auipc	ra,0xfffff
    80005000:	8d2080e7          	jalr	-1838(ra) # 800038ce <iunlockput>
  end_op(ROOTDEV);
    80005004:	4501                	li	a0,0
    80005006:	fffff097          	auipc	ra,0xfffff
    8000500a:	1da080e7          	jalr	474(ra) # 800041e0 <end_op>
  p = myproc();
    8000500e:	ffffd097          	auipc	ra,0xffffd
    80005012:	a54080e7          	jalr	-1452(ra) # 80001a62 <myproc>
    80005016:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005018:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    8000501c:	6585                	lui	a1,0x1
    8000501e:	15fd                	addi	a1,a1,-1
    80005020:	df843783          	ld	a5,-520(s0)
    80005024:	95be                	add	a1,a1,a5
    80005026:	77fd                	lui	a5,0xfffff
    80005028:	8dfd                	and	a1,a1,a5
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000502a:	6609                	lui	a2,0x2
    8000502c:	962e                	add	a2,a2,a1
    8000502e:	855a                	mv	a0,s6
    80005030:	ffffc097          	auipc	ra,0xffffc
    80005034:	54a080e7          	jalr	1354(ra) # 8000157a <uvmalloc>
    80005038:	892a                	mv	s2,a0
    8000503a:	dea43c23          	sd	a0,-520(s0)
  ip = 0;
    8000503e:	4a81                	li	s5,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005040:	ed01                	bnez	a0,80005058 <exec+0x252>
    proc_freepagetable(pagetable, sz);
    80005042:	df843583          	ld	a1,-520(s0)
    80005046:	855a                	mv	a0,s6
    80005048:	ffffd097          	auipc	ra,0xffffd
    8000504c:	bec080e7          	jalr	-1044(ra) # 80001c34 <proc_freepagetable>
  if(ip){
    80005050:	e40a90e3          	bnez	s5,80004e90 <exec+0x8a>
  return -1;
    80005054:	557d                	li	a0,-1
    80005056:	bd81                	j	80004ea6 <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005058:	75f9                	lui	a1,0xffffe
    8000505a:	95aa                	add	a1,a1,a0
    8000505c:	855a                	mv	a0,s6
    8000505e:	ffffc097          	auipc	ra,0xffffc
    80005062:	6c4080e7          	jalr	1732(ra) # 80001722 <uvmclear>
  stackbase = sp - PGSIZE;
    80005066:	7c7d                	lui	s8,0xfffff
    80005068:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    8000506a:	df043783          	ld	a5,-528(s0)
    8000506e:	6388                	ld	a0,0(a5)
    80005070:	c52d                	beqz	a0,800050da <exec+0x2d4>
    80005072:	e8840993          	addi	s3,s0,-376
    80005076:	f8840a93          	addi	s5,s0,-120
    8000507a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000507c:	ffffc097          	auipc	ra,0xffffc
    80005080:	e80080e7          	jalr	-384(ra) # 80000efc <strlen>
    80005084:	0015079b          	addiw	a5,a0,1
    80005088:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000508c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005090:	0f896b63          	bltu	s2,s8,80005186 <exec+0x380>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005094:	df043d03          	ld	s10,-528(s0)
    80005098:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7ffcdfa4>
    8000509c:	8552                	mv	a0,s4
    8000509e:	ffffc097          	auipc	ra,0xffffc
    800050a2:	e5e080e7          	jalr	-418(ra) # 80000efc <strlen>
    800050a6:	0015069b          	addiw	a3,a0,1
    800050aa:	8652                	mv	a2,s4
    800050ac:	85ca                	mv	a1,s2
    800050ae:	855a                	mv	a0,s6
    800050b0:	ffffc097          	auipc	ra,0xffffc
    800050b4:	6a4080e7          	jalr	1700(ra) # 80001754 <copyout>
    800050b8:	0c054963          	bltz	a0,8000518a <exec+0x384>
    ustack[argc] = sp;
    800050bc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050c0:	0485                	addi	s1,s1,1
    800050c2:	008d0793          	addi	a5,s10,8
    800050c6:	def43823          	sd	a5,-528(s0)
    800050ca:	008d3503          	ld	a0,8(s10)
    800050ce:	c909                	beqz	a0,800050e0 <exec+0x2da>
    if(argc >= MAXARG)
    800050d0:	09a1                	addi	s3,s3,8
    800050d2:	fb3a95e3          	bne	s5,s3,8000507c <exec+0x276>
  ip = 0;
    800050d6:	4a81                	li	s5,0
    800050d8:	b7ad                	j	80005042 <exec+0x23c>
  sp = sz;
    800050da:	df843903          	ld	s2,-520(s0)
  for(argc = 0; argv[argc]; argc++) {
    800050de:	4481                	li	s1,0
  ustack[argc] = 0;
    800050e0:	00349793          	slli	a5,s1,0x3
    800050e4:	f9040713          	addi	a4,s0,-112
    800050e8:	97ba                	add	a5,a5,a4
    800050ea:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcde9c>
  sp -= (argc+1) * sizeof(uint64);
    800050ee:	00148693          	addi	a3,s1,1
    800050f2:	068e                	slli	a3,a3,0x3
    800050f4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050f8:	ff097913          	andi	s2,s2,-16
  ip = 0;
    800050fc:	4a81                	li	s5,0
  if(sp < stackbase)
    800050fe:	f58962e3          	bltu	s2,s8,80005042 <exec+0x23c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005102:	e8840613          	addi	a2,s0,-376
    80005106:	85ca                	mv	a1,s2
    80005108:	855a                	mv	a0,s6
    8000510a:	ffffc097          	auipc	ra,0xffffc
    8000510e:	64a080e7          	jalr	1610(ra) # 80001754 <copyout>
    80005112:	06054e63          	bltz	a0,8000518e <exec+0x388>
  p->tf->a1 = sp;
    80005116:	060bb783          	ld	a5,96(s7)
    8000511a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000511e:	de843783          	ld	a5,-536(s0)
    80005122:	0007c703          	lbu	a4,0(a5)
    80005126:	cf11                	beqz	a4,80005142 <exec+0x33c>
    80005128:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000512a:	02f00693          	li	a3,47
    8000512e:	a039                	j	8000513c <exec+0x336>
      last = s+1;
    80005130:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005134:	0785                	addi	a5,a5,1
    80005136:	fff7c703          	lbu	a4,-1(a5)
    8000513a:	c701                	beqz	a4,80005142 <exec+0x33c>
    if(*s == '/')
    8000513c:	fed71ce3          	bne	a4,a3,80005134 <exec+0x32e>
    80005140:	bfc5                	j	80005130 <exec+0x32a>
  safestrcpy(p->name, last, sizeof(p->name));
    80005142:	4641                	li	a2,16
    80005144:	de843583          	ld	a1,-536(s0)
    80005148:	160b8513          	addi	a0,s7,352
    8000514c:	ffffc097          	auipc	ra,0xffffc
    80005150:	d7e080e7          	jalr	-642(ra) # 80000eca <safestrcpy>
  oldpagetable = p->pagetable;
    80005154:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80005158:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    8000515c:	df843783          	ld	a5,-520(s0)
    80005160:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80005164:	060bb783          	ld	a5,96(s7)
    80005168:	e6043703          	ld	a4,-416(s0)
    8000516c:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    8000516e:	060bb783          	ld	a5,96(s7)
    80005172:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005176:	85e6                	mv	a1,s9
    80005178:	ffffd097          	auipc	ra,0xffffd
    8000517c:	abc080e7          	jalr	-1348(ra) # 80001c34 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005180:	0004851b          	sext.w	a0,s1
    80005184:	b30d                	j	80004ea6 <exec+0xa0>
  ip = 0;
    80005186:	4a81                	li	s5,0
    80005188:	bd6d                	j	80005042 <exec+0x23c>
    8000518a:	4a81                	li	s5,0
    8000518c:	bd5d                	j	80005042 <exec+0x23c>
    8000518e:	4a81                	li	s5,0
    80005190:	bd4d                	j	80005042 <exec+0x23c>

0000000080005192 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005192:	7179                	addi	sp,sp,-48
    80005194:	f406                	sd	ra,40(sp)
    80005196:	f022                	sd	s0,32(sp)
    80005198:	ec26                	sd	s1,24(sp)
    8000519a:	e84a                	sd	s2,16(sp)
    8000519c:	1800                	addi	s0,sp,48
    8000519e:	892e                	mv	s2,a1
    800051a0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051a2:	fdc40593          	addi	a1,s0,-36
    800051a6:	ffffe097          	auipc	ra,0xffffe
    800051aa:	976080e7          	jalr	-1674(ra) # 80002b1c <argint>
    800051ae:	04054063          	bltz	a0,800051ee <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051b2:	fdc42703          	lw	a4,-36(s0)
    800051b6:	47bd                	li	a5,15
    800051b8:	02e7ed63          	bltu	a5,a4,800051f2 <argfd+0x60>
    800051bc:	ffffd097          	auipc	ra,0xffffd
    800051c0:	8a6080e7          	jalr	-1882(ra) # 80001a62 <myproc>
    800051c4:	fdc42703          	lw	a4,-36(s0)
    800051c8:	01a70793          	addi	a5,a4,26
    800051cc:	078e                	slli	a5,a5,0x3
    800051ce:	953e                	add	a0,a0,a5
    800051d0:	651c                	ld	a5,8(a0)
    800051d2:	c395                	beqz	a5,800051f6 <argfd+0x64>
    return -1;
  if(pfd)
    800051d4:	00090463          	beqz	s2,800051dc <argfd+0x4a>
    *pfd = fd;
    800051d8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051dc:	4501                	li	a0,0
  if(pf)
    800051de:	c091                	beqz	s1,800051e2 <argfd+0x50>
    *pf = f;
    800051e0:	e09c                	sd	a5,0(s1)
}
    800051e2:	70a2                	ld	ra,40(sp)
    800051e4:	7402                	ld	s0,32(sp)
    800051e6:	64e2                	ld	s1,24(sp)
    800051e8:	6942                	ld	s2,16(sp)
    800051ea:	6145                	addi	sp,sp,48
    800051ec:	8082                	ret
    return -1;
    800051ee:	557d                	li	a0,-1
    800051f0:	bfcd                	j	800051e2 <argfd+0x50>
    return -1;
    800051f2:	557d                	li	a0,-1
    800051f4:	b7fd                	j	800051e2 <argfd+0x50>
    800051f6:	557d                	li	a0,-1
    800051f8:	b7ed                	j	800051e2 <argfd+0x50>

00000000800051fa <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051fa:	1101                	addi	sp,sp,-32
    800051fc:	ec06                	sd	ra,24(sp)
    800051fe:	e822                	sd	s0,16(sp)
    80005200:	e426                	sd	s1,8(sp)
    80005202:	1000                	addi	s0,sp,32
    80005204:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005206:	ffffd097          	auipc	ra,0xffffd
    8000520a:	85c080e7          	jalr	-1956(ra) # 80001a62 <myproc>
    8000520e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005210:	0d850793          	addi	a5,a0,216
    80005214:	4501                	li	a0,0
    80005216:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005218:	6398                	ld	a4,0(a5)
    8000521a:	cb19                	beqz	a4,80005230 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000521c:	2505                	addiw	a0,a0,1
    8000521e:	07a1                	addi	a5,a5,8
    80005220:	fed51ce3          	bne	a0,a3,80005218 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005224:	557d                	li	a0,-1
}
    80005226:	60e2                	ld	ra,24(sp)
    80005228:	6442                	ld	s0,16(sp)
    8000522a:	64a2                	ld	s1,8(sp)
    8000522c:	6105                	addi	sp,sp,32
    8000522e:	8082                	ret
      p->ofile[fd] = f;
    80005230:	01a50793          	addi	a5,a0,26
    80005234:	078e                	slli	a5,a5,0x3
    80005236:	963e                	add	a2,a2,a5
    80005238:	e604                	sd	s1,8(a2)
      return fd;
    8000523a:	b7f5                	j	80005226 <fdalloc+0x2c>

000000008000523c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000523c:	715d                	addi	sp,sp,-80
    8000523e:	e486                	sd	ra,72(sp)
    80005240:	e0a2                	sd	s0,64(sp)
    80005242:	fc26                	sd	s1,56(sp)
    80005244:	f84a                	sd	s2,48(sp)
    80005246:	f44e                	sd	s3,40(sp)
    80005248:	f052                	sd	s4,32(sp)
    8000524a:	ec56                	sd	s5,24(sp)
    8000524c:	0880                	addi	s0,sp,80
    8000524e:	89ae                	mv	s3,a1
    80005250:	8ab2                	mv	s5,a2
    80005252:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005254:	fb040593          	addi	a1,s0,-80
    80005258:	fffff097          	auipc	ra,0xfffff
    8000525c:	be0080e7          	jalr	-1056(ra) # 80003e38 <nameiparent>
    80005260:	892a                	mv	s2,a0
    80005262:	12050e63          	beqz	a0,8000539e <create+0x162>
    return 0;

  ilock(dp);
    80005266:	ffffe097          	auipc	ra,0xffffe
    8000526a:	42a080e7          	jalr	1066(ra) # 80003690 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000526e:	4601                	li	a2,0
    80005270:	fb040593          	addi	a1,s0,-80
    80005274:	854a                	mv	a0,s2
    80005276:	fffff097          	auipc	ra,0xfffff
    8000527a:	8d2080e7          	jalr	-1838(ra) # 80003b48 <dirlookup>
    8000527e:	84aa                	mv	s1,a0
    80005280:	c921                	beqz	a0,800052d0 <create+0x94>
    iunlockput(dp);
    80005282:	854a                	mv	a0,s2
    80005284:	ffffe097          	auipc	ra,0xffffe
    80005288:	64a080e7          	jalr	1610(ra) # 800038ce <iunlockput>
    ilock(ip);
    8000528c:	8526                	mv	a0,s1
    8000528e:	ffffe097          	auipc	ra,0xffffe
    80005292:	402080e7          	jalr	1026(ra) # 80003690 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005296:	2981                	sext.w	s3,s3
    80005298:	4789                	li	a5,2
    8000529a:	02f99463          	bne	s3,a5,800052c2 <create+0x86>
    8000529e:	04c4d783          	lhu	a5,76(s1)
    800052a2:	37f9                	addiw	a5,a5,-2
    800052a4:	17c2                	slli	a5,a5,0x30
    800052a6:	93c1                	srli	a5,a5,0x30
    800052a8:	4705                	li	a4,1
    800052aa:	00f76c63          	bltu	a4,a5,800052c2 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052ae:	8526                	mv	a0,s1
    800052b0:	60a6                	ld	ra,72(sp)
    800052b2:	6406                	ld	s0,64(sp)
    800052b4:	74e2                	ld	s1,56(sp)
    800052b6:	7942                	ld	s2,48(sp)
    800052b8:	79a2                	ld	s3,40(sp)
    800052ba:	7a02                	ld	s4,32(sp)
    800052bc:	6ae2                	ld	s5,24(sp)
    800052be:	6161                	addi	sp,sp,80
    800052c0:	8082                	ret
    iunlockput(ip);
    800052c2:	8526                	mv	a0,s1
    800052c4:	ffffe097          	auipc	ra,0xffffe
    800052c8:	60a080e7          	jalr	1546(ra) # 800038ce <iunlockput>
    return 0;
    800052cc:	4481                	li	s1,0
    800052ce:	b7c5                	j	800052ae <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052d0:	85ce                	mv	a1,s3
    800052d2:	00092503          	lw	a0,0(s2)
    800052d6:	ffffe097          	auipc	ra,0xffffe
    800052da:	222080e7          	jalr	546(ra) # 800034f8 <ialloc>
    800052de:	84aa                	mv	s1,a0
    800052e0:	c521                	beqz	a0,80005328 <create+0xec>
  ilock(ip);
    800052e2:	ffffe097          	auipc	ra,0xffffe
    800052e6:	3ae080e7          	jalr	942(ra) # 80003690 <ilock>
  ip->major = major;
    800052ea:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    800052ee:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    800052f2:	4a05                	li	s4,1
    800052f4:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    800052f8:	8526                	mv	a0,s1
    800052fa:	ffffe097          	auipc	ra,0xffffe
    800052fe:	2cc080e7          	jalr	716(ra) # 800035c6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005302:	2981                	sext.w	s3,s3
    80005304:	03498a63          	beq	s3,s4,80005338 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005308:	40d0                	lw	a2,4(s1)
    8000530a:	fb040593          	addi	a1,s0,-80
    8000530e:	854a                	mv	a0,s2
    80005310:	fffff097          	auipc	ra,0xfffff
    80005314:	a48080e7          	jalr	-1464(ra) # 80003d58 <dirlink>
    80005318:	06054b63          	bltz	a0,8000538e <create+0x152>
  iunlockput(dp);
    8000531c:	854a                	mv	a0,s2
    8000531e:	ffffe097          	auipc	ra,0xffffe
    80005322:	5b0080e7          	jalr	1456(ra) # 800038ce <iunlockput>
  return ip;
    80005326:	b761                	j	800052ae <create+0x72>
    panic("create: ialloc");
    80005328:	00003517          	auipc	a0,0x3
    8000532c:	58050513          	addi	a0,a0,1408 # 800088a8 <userret+0x818>
    80005330:	ffffb097          	auipc	ra,0xffffb
    80005334:	218080e7          	jalr	536(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    80005338:	05295783          	lhu	a5,82(s2)
    8000533c:	2785                	addiw	a5,a5,1
    8000533e:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    80005342:	854a                	mv	a0,s2
    80005344:	ffffe097          	auipc	ra,0xffffe
    80005348:	282080e7          	jalr	642(ra) # 800035c6 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000534c:	40d0                	lw	a2,4(s1)
    8000534e:	00003597          	auipc	a1,0x3
    80005352:	56a58593          	addi	a1,a1,1386 # 800088b8 <userret+0x828>
    80005356:	8526                	mv	a0,s1
    80005358:	fffff097          	auipc	ra,0xfffff
    8000535c:	a00080e7          	jalr	-1536(ra) # 80003d58 <dirlink>
    80005360:	00054f63          	bltz	a0,8000537e <create+0x142>
    80005364:	00492603          	lw	a2,4(s2)
    80005368:	00003597          	auipc	a1,0x3
    8000536c:	55858593          	addi	a1,a1,1368 # 800088c0 <userret+0x830>
    80005370:	8526                	mv	a0,s1
    80005372:	fffff097          	auipc	ra,0xfffff
    80005376:	9e6080e7          	jalr	-1562(ra) # 80003d58 <dirlink>
    8000537a:	f80557e3          	bgez	a0,80005308 <create+0xcc>
      panic("create dots");
    8000537e:	00003517          	auipc	a0,0x3
    80005382:	54a50513          	addi	a0,a0,1354 # 800088c8 <userret+0x838>
    80005386:	ffffb097          	auipc	ra,0xffffb
    8000538a:	1c2080e7          	jalr	450(ra) # 80000548 <panic>
    panic("create: dirlink");
    8000538e:	00003517          	auipc	a0,0x3
    80005392:	54a50513          	addi	a0,a0,1354 # 800088d8 <userret+0x848>
    80005396:	ffffb097          	auipc	ra,0xffffb
    8000539a:	1b2080e7          	jalr	434(ra) # 80000548 <panic>
    return 0;
    8000539e:	84aa                	mv	s1,a0
    800053a0:	b739                	j	800052ae <create+0x72>

00000000800053a2 <sys_dup>:
{
    800053a2:	7179                	addi	sp,sp,-48
    800053a4:	f406                	sd	ra,40(sp)
    800053a6:	f022                	sd	s0,32(sp)
    800053a8:	ec26                	sd	s1,24(sp)
    800053aa:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053ac:	fd840613          	addi	a2,s0,-40
    800053b0:	4581                	li	a1,0
    800053b2:	4501                	li	a0,0
    800053b4:	00000097          	auipc	ra,0x0
    800053b8:	dde080e7          	jalr	-546(ra) # 80005192 <argfd>
    return -1;
    800053bc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053be:	02054363          	bltz	a0,800053e4 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053c2:	fd843503          	ld	a0,-40(s0)
    800053c6:	00000097          	auipc	ra,0x0
    800053ca:	e34080e7          	jalr	-460(ra) # 800051fa <fdalloc>
    800053ce:	84aa                	mv	s1,a0
    return -1;
    800053d0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053d2:	00054963          	bltz	a0,800053e4 <sys_dup+0x42>
  filedup(f);
    800053d6:	fd843503          	ld	a0,-40(s0)
    800053da:	fffff097          	auipc	ra,0xfffff
    800053de:	332080e7          	jalr	818(ra) # 8000470c <filedup>
  return fd;
    800053e2:	87a6                	mv	a5,s1
}
    800053e4:	853e                	mv	a0,a5
    800053e6:	70a2                	ld	ra,40(sp)
    800053e8:	7402                	ld	s0,32(sp)
    800053ea:	64e2                	ld	s1,24(sp)
    800053ec:	6145                	addi	sp,sp,48
    800053ee:	8082                	ret

00000000800053f0 <sys_read>:
{
    800053f0:	7179                	addi	sp,sp,-48
    800053f2:	f406                	sd	ra,40(sp)
    800053f4:	f022                	sd	s0,32(sp)
    800053f6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053f8:	fe840613          	addi	a2,s0,-24
    800053fc:	4581                	li	a1,0
    800053fe:	4501                	li	a0,0
    80005400:	00000097          	auipc	ra,0x0
    80005404:	d92080e7          	jalr	-622(ra) # 80005192 <argfd>
    return -1;
    80005408:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000540a:	04054163          	bltz	a0,8000544c <sys_read+0x5c>
    8000540e:	fe440593          	addi	a1,s0,-28
    80005412:	4509                	li	a0,2
    80005414:	ffffd097          	auipc	ra,0xffffd
    80005418:	708080e7          	jalr	1800(ra) # 80002b1c <argint>
    return -1;
    8000541c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000541e:	02054763          	bltz	a0,8000544c <sys_read+0x5c>
    80005422:	fd840593          	addi	a1,s0,-40
    80005426:	4505                	li	a0,1
    80005428:	ffffd097          	auipc	ra,0xffffd
    8000542c:	716080e7          	jalr	1814(ra) # 80002b3e <argaddr>
    return -1;
    80005430:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005432:	00054d63          	bltz	a0,8000544c <sys_read+0x5c>
  return fileread(f, p, n);
    80005436:	fe442603          	lw	a2,-28(s0)
    8000543a:	fd843583          	ld	a1,-40(s0)
    8000543e:	fe843503          	ld	a0,-24(s0)
    80005442:	fffff097          	auipc	ra,0xfffff
    80005446:	45e080e7          	jalr	1118(ra) # 800048a0 <fileread>
    8000544a:	87aa                	mv	a5,a0
}
    8000544c:	853e                	mv	a0,a5
    8000544e:	70a2                	ld	ra,40(sp)
    80005450:	7402                	ld	s0,32(sp)
    80005452:	6145                	addi	sp,sp,48
    80005454:	8082                	ret

0000000080005456 <sys_write>:
{
    80005456:	7179                	addi	sp,sp,-48
    80005458:	f406                	sd	ra,40(sp)
    8000545a:	f022                	sd	s0,32(sp)
    8000545c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000545e:	fe840613          	addi	a2,s0,-24
    80005462:	4581                	li	a1,0
    80005464:	4501                	li	a0,0
    80005466:	00000097          	auipc	ra,0x0
    8000546a:	d2c080e7          	jalr	-724(ra) # 80005192 <argfd>
    return -1;
    8000546e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005470:	04054163          	bltz	a0,800054b2 <sys_write+0x5c>
    80005474:	fe440593          	addi	a1,s0,-28
    80005478:	4509                	li	a0,2
    8000547a:	ffffd097          	auipc	ra,0xffffd
    8000547e:	6a2080e7          	jalr	1698(ra) # 80002b1c <argint>
    return -1;
    80005482:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005484:	02054763          	bltz	a0,800054b2 <sys_write+0x5c>
    80005488:	fd840593          	addi	a1,s0,-40
    8000548c:	4505                	li	a0,1
    8000548e:	ffffd097          	auipc	ra,0xffffd
    80005492:	6b0080e7          	jalr	1712(ra) # 80002b3e <argaddr>
    return -1;
    80005496:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005498:	00054d63          	bltz	a0,800054b2 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000549c:	fe442603          	lw	a2,-28(s0)
    800054a0:	fd843583          	ld	a1,-40(s0)
    800054a4:	fe843503          	ld	a0,-24(s0)
    800054a8:	fffff097          	auipc	ra,0xfffff
    800054ac:	4be080e7          	jalr	1214(ra) # 80004966 <filewrite>
    800054b0:	87aa                	mv	a5,a0
}
    800054b2:	853e                	mv	a0,a5
    800054b4:	70a2                	ld	ra,40(sp)
    800054b6:	7402                	ld	s0,32(sp)
    800054b8:	6145                	addi	sp,sp,48
    800054ba:	8082                	ret

00000000800054bc <sys_close>:
{
    800054bc:	1101                	addi	sp,sp,-32
    800054be:	ec06                	sd	ra,24(sp)
    800054c0:	e822                	sd	s0,16(sp)
    800054c2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054c4:	fe040613          	addi	a2,s0,-32
    800054c8:	fec40593          	addi	a1,s0,-20
    800054cc:	4501                	li	a0,0
    800054ce:	00000097          	auipc	ra,0x0
    800054d2:	cc4080e7          	jalr	-828(ra) # 80005192 <argfd>
    return -1;
    800054d6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054d8:	02054463          	bltz	a0,80005500 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054dc:	ffffc097          	auipc	ra,0xffffc
    800054e0:	586080e7          	jalr	1414(ra) # 80001a62 <myproc>
    800054e4:	fec42783          	lw	a5,-20(s0)
    800054e8:	07e9                	addi	a5,a5,26
    800054ea:	078e                	slli	a5,a5,0x3
    800054ec:	97aa                	add	a5,a5,a0
    800054ee:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800054f2:	fe043503          	ld	a0,-32(s0)
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	268080e7          	jalr	616(ra) # 8000475e <fileclose>
  return 0;
    800054fe:	4781                	li	a5,0
}
    80005500:	853e                	mv	a0,a5
    80005502:	60e2                	ld	ra,24(sp)
    80005504:	6442                	ld	s0,16(sp)
    80005506:	6105                	addi	sp,sp,32
    80005508:	8082                	ret

000000008000550a <sys_fstat>:
{
    8000550a:	1101                	addi	sp,sp,-32
    8000550c:	ec06                	sd	ra,24(sp)
    8000550e:	e822                	sd	s0,16(sp)
    80005510:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005512:	fe840613          	addi	a2,s0,-24
    80005516:	4581                	li	a1,0
    80005518:	4501                	li	a0,0
    8000551a:	00000097          	auipc	ra,0x0
    8000551e:	c78080e7          	jalr	-904(ra) # 80005192 <argfd>
    return -1;
    80005522:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005524:	02054563          	bltz	a0,8000554e <sys_fstat+0x44>
    80005528:	fe040593          	addi	a1,s0,-32
    8000552c:	4505                	li	a0,1
    8000552e:	ffffd097          	auipc	ra,0xffffd
    80005532:	610080e7          	jalr	1552(ra) # 80002b3e <argaddr>
    return -1;
    80005536:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005538:	00054b63          	bltz	a0,8000554e <sys_fstat+0x44>
  return filestat(f, st);
    8000553c:	fe043583          	ld	a1,-32(s0)
    80005540:	fe843503          	ld	a0,-24(s0)
    80005544:	fffff097          	auipc	ra,0xfffff
    80005548:	2ea080e7          	jalr	746(ra) # 8000482e <filestat>
    8000554c:	87aa                	mv	a5,a0
}
    8000554e:	853e                	mv	a0,a5
    80005550:	60e2                	ld	ra,24(sp)
    80005552:	6442                	ld	s0,16(sp)
    80005554:	6105                	addi	sp,sp,32
    80005556:	8082                	ret

0000000080005558 <sys_link>:
{
    80005558:	7169                	addi	sp,sp,-304
    8000555a:	f606                	sd	ra,296(sp)
    8000555c:	f222                	sd	s0,288(sp)
    8000555e:	ee26                	sd	s1,280(sp)
    80005560:	ea4a                	sd	s2,272(sp)
    80005562:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005564:	08000613          	li	a2,128
    80005568:	ed040593          	addi	a1,s0,-304
    8000556c:	4501                	li	a0,0
    8000556e:	ffffd097          	auipc	ra,0xffffd
    80005572:	5f2080e7          	jalr	1522(ra) # 80002b60 <argstr>
    return -1;
    80005576:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005578:	12054363          	bltz	a0,8000569e <sys_link+0x146>
    8000557c:	08000613          	li	a2,128
    80005580:	f5040593          	addi	a1,s0,-176
    80005584:	4505                	li	a0,1
    80005586:	ffffd097          	auipc	ra,0xffffd
    8000558a:	5da080e7          	jalr	1498(ra) # 80002b60 <argstr>
    return -1;
    8000558e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005590:	10054763          	bltz	a0,8000569e <sys_link+0x146>
  begin_op(ROOTDEV);
    80005594:	4501                	li	a0,0
    80005596:	fffff097          	auipc	ra,0xfffff
    8000559a:	ba0080e7          	jalr	-1120(ra) # 80004136 <begin_op>
  if((ip = namei(old)) == 0){
    8000559e:	ed040513          	addi	a0,s0,-304
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	878080e7          	jalr	-1928(ra) # 80003e1a <namei>
    800055aa:	84aa                	mv	s1,a0
    800055ac:	c559                	beqz	a0,8000563a <sys_link+0xe2>
  ilock(ip);
    800055ae:	ffffe097          	auipc	ra,0xffffe
    800055b2:	0e2080e7          	jalr	226(ra) # 80003690 <ilock>
  if(ip->type == T_DIR){
    800055b6:	04c49703          	lh	a4,76(s1)
    800055ba:	4785                	li	a5,1
    800055bc:	08f70663          	beq	a4,a5,80005648 <sys_link+0xf0>
  ip->nlink++;
    800055c0:	0524d783          	lhu	a5,82(s1)
    800055c4:	2785                	addiw	a5,a5,1
    800055c6:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800055ca:	8526                	mv	a0,s1
    800055cc:	ffffe097          	auipc	ra,0xffffe
    800055d0:	ffa080e7          	jalr	-6(ra) # 800035c6 <iupdate>
  iunlock(ip);
    800055d4:	8526                	mv	a0,s1
    800055d6:	ffffe097          	auipc	ra,0xffffe
    800055da:	17c080e7          	jalr	380(ra) # 80003752 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055de:	fd040593          	addi	a1,s0,-48
    800055e2:	f5040513          	addi	a0,s0,-176
    800055e6:	fffff097          	auipc	ra,0xfffff
    800055ea:	852080e7          	jalr	-1966(ra) # 80003e38 <nameiparent>
    800055ee:	892a                	mv	s2,a0
    800055f0:	cd2d                	beqz	a0,8000566a <sys_link+0x112>
  ilock(dp);
    800055f2:	ffffe097          	auipc	ra,0xffffe
    800055f6:	09e080e7          	jalr	158(ra) # 80003690 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055fa:	00092703          	lw	a4,0(s2)
    800055fe:	409c                	lw	a5,0(s1)
    80005600:	06f71063          	bne	a4,a5,80005660 <sys_link+0x108>
    80005604:	40d0                	lw	a2,4(s1)
    80005606:	fd040593          	addi	a1,s0,-48
    8000560a:	854a                	mv	a0,s2
    8000560c:	ffffe097          	auipc	ra,0xffffe
    80005610:	74c080e7          	jalr	1868(ra) # 80003d58 <dirlink>
    80005614:	04054663          	bltz	a0,80005660 <sys_link+0x108>
  iunlockput(dp);
    80005618:	854a                	mv	a0,s2
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	2b4080e7          	jalr	692(ra) # 800038ce <iunlockput>
  iput(ip);
    80005622:	8526                	mv	a0,s1
    80005624:	ffffe097          	auipc	ra,0xffffe
    80005628:	17a080e7          	jalr	378(ra) # 8000379e <iput>
  end_op(ROOTDEV);
    8000562c:	4501                	li	a0,0
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	bb2080e7          	jalr	-1102(ra) # 800041e0 <end_op>
  return 0;
    80005636:	4781                	li	a5,0
    80005638:	a09d                	j	8000569e <sys_link+0x146>
    end_op(ROOTDEV);
    8000563a:	4501                	li	a0,0
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	ba4080e7          	jalr	-1116(ra) # 800041e0 <end_op>
    return -1;
    80005644:	57fd                	li	a5,-1
    80005646:	a8a1                	j	8000569e <sys_link+0x146>
    iunlockput(ip);
    80005648:	8526                	mv	a0,s1
    8000564a:	ffffe097          	auipc	ra,0xffffe
    8000564e:	284080e7          	jalr	644(ra) # 800038ce <iunlockput>
    end_op(ROOTDEV);
    80005652:	4501                	li	a0,0
    80005654:	fffff097          	auipc	ra,0xfffff
    80005658:	b8c080e7          	jalr	-1140(ra) # 800041e0 <end_op>
    return -1;
    8000565c:	57fd                	li	a5,-1
    8000565e:	a081                	j	8000569e <sys_link+0x146>
    iunlockput(dp);
    80005660:	854a                	mv	a0,s2
    80005662:	ffffe097          	auipc	ra,0xffffe
    80005666:	26c080e7          	jalr	620(ra) # 800038ce <iunlockput>
  ilock(ip);
    8000566a:	8526                	mv	a0,s1
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	024080e7          	jalr	36(ra) # 80003690 <ilock>
  ip->nlink--;
    80005674:	0524d783          	lhu	a5,82(s1)
    80005678:	37fd                	addiw	a5,a5,-1
    8000567a:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000567e:	8526                	mv	a0,s1
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	f46080e7          	jalr	-186(ra) # 800035c6 <iupdate>
  iunlockput(ip);
    80005688:	8526                	mv	a0,s1
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	244080e7          	jalr	580(ra) # 800038ce <iunlockput>
  end_op(ROOTDEV);
    80005692:	4501                	li	a0,0
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	b4c080e7          	jalr	-1204(ra) # 800041e0 <end_op>
  return -1;
    8000569c:	57fd                	li	a5,-1
}
    8000569e:	853e                	mv	a0,a5
    800056a0:	70b2                	ld	ra,296(sp)
    800056a2:	7412                	ld	s0,288(sp)
    800056a4:	64f2                	ld	s1,280(sp)
    800056a6:	6952                	ld	s2,272(sp)
    800056a8:	6155                	addi	sp,sp,304
    800056aa:	8082                	ret

00000000800056ac <sys_unlink>:
{
    800056ac:	7151                	addi	sp,sp,-240
    800056ae:	f586                	sd	ra,232(sp)
    800056b0:	f1a2                	sd	s0,224(sp)
    800056b2:	eda6                	sd	s1,216(sp)
    800056b4:	e9ca                	sd	s2,208(sp)
    800056b6:	e5ce                	sd	s3,200(sp)
    800056b8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056ba:	08000613          	li	a2,128
    800056be:	f3040593          	addi	a1,s0,-208
    800056c2:	4501                	li	a0,0
    800056c4:	ffffd097          	auipc	ra,0xffffd
    800056c8:	49c080e7          	jalr	1180(ra) # 80002b60 <argstr>
    800056cc:	18054463          	bltz	a0,80005854 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    800056d0:	4501                	li	a0,0
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	a64080e7          	jalr	-1436(ra) # 80004136 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056da:	fb040593          	addi	a1,s0,-80
    800056de:	f3040513          	addi	a0,s0,-208
    800056e2:	ffffe097          	auipc	ra,0xffffe
    800056e6:	756080e7          	jalr	1878(ra) # 80003e38 <nameiparent>
    800056ea:	84aa                	mv	s1,a0
    800056ec:	cd61                	beqz	a0,800057c4 <sys_unlink+0x118>
  ilock(dp);
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	fa2080e7          	jalr	-94(ra) # 80003690 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056f6:	00003597          	auipc	a1,0x3
    800056fa:	1c258593          	addi	a1,a1,450 # 800088b8 <userret+0x828>
    800056fe:	fb040513          	addi	a0,s0,-80
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	42c080e7          	jalr	1068(ra) # 80003b2e <namecmp>
    8000570a:	14050c63          	beqz	a0,80005862 <sys_unlink+0x1b6>
    8000570e:	00003597          	auipc	a1,0x3
    80005712:	1b258593          	addi	a1,a1,434 # 800088c0 <userret+0x830>
    80005716:	fb040513          	addi	a0,s0,-80
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	414080e7          	jalr	1044(ra) # 80003b2e <namecmp>
    80005722:	14050063          	beqz	a0,80005862 <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005726:	f2c40613          	addi	a2,s0,-212
    8000572a:	fb040593          	addi	a1,s0,-80
    8000572e:	8526                	mv	a0,s1
    80005730:	ffffe097          	auipc	ra,0xffffe
    80005734:	418080e7          	jalr	1048(ra) # 80003b48 <dirlookup>
    80005738:	892a                	mv	s2,a0
    8000573a:	12050463          	beqz	a0,80005862 <sys_unlink+0x1b6>
  ilock(ip);
    8000573e:	ffffe097          	auipc	ra,0xffffe
    80005742:	f52080e7          	jalr	-174(ra) # 80003690 <ilock>
  if(ip->nlink < 1)
    80005746:	05291783          	lh	a5,82(s2)
    8000574a:	08f05463          	blez	a5,800057d2 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000574e:	04c91703          	lh	a4,76(s2)
    80005752:	4785                	li	a5,1
    80005754:	08f70763          	beq	a4,a5,800057e2 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005758:	4641                	li	a2,16
    8000575a:	4581                	li	a1,0
    8000575c:	fc040513          	addi	a0,s0,-64
    80005760:	ffffb097          	auipc	ra,0xffffb
    80005764:	618080e7          	jalr	1560(ra) # 80000d78 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005768:	4741                	li	a4,16
    8000576a:	f2c42683          	lw	a3,-212(s0)
    8000576e:	fc040613          	addi	a2,s0,-64
    80005772:	4581                	li	a1,0
    80005774:	8526                	mv	a0,s1
    80005776:	ffffe097          	auipc	ra,0xffffe
    8000577a:	29e080e7          	jalr	670(ra) # 80003a14 <writei>
    8000577e:	47c1                	li	a5,16
    80005780:	0af51763          	bne	a0,a5,8000582e <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005784:	04c91703          	lh	a4,76(s2)
    80005788:	4785                	li	a5,1
    8000578a:	0af70a63          	beq	a4,a5,8000583e <sys_unlink+0x192>
  iunlockput(dp);
    8000578e:	8526                	mv	a0,s1
    80005790:	ffffe097          	auipc	ra,0xffffe
    80005794:	13e080e7          	jalr	318(ra) # 800038ce <iunlockput>
  ip->nlink--;
    80005798:	05295783          	lhu	a5,82(s2)
    8000579c:	37fd                	addiw	a5,a5,-1
    8000579e:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    800057a2:	854a                	mv	a0,s2
    800057a4:	ffffe097          	auipc	ra,0xffffe
    800057a8:	e22080e7          	jalr	-478(ra) # 800035c6 <iupdate>
  iunlockput(ip);
    800057ac:	854a                	mv	a0,s2
    800057ae:	ffffe097          	auipc	ra,0xffffe
    800057b2:	120080e7          	jalr	288(ra) # 800038ce <iunlockput>
  end_op(ROOTDEV);
    800057b6:	4501                	li	a0,0
    800057b8:	fffff097          	auipc	ra,0xfffff
    800057bc:	a28080e7          	jalr	-1496(ra) # 800041e0 <end_op>
  return 0;
    800057c0:	4501                	li	a0,0
    800057c2:	a85d                	j	80005878 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    800057c4:	4501                	li	a0,0
    800057c6:	fffff097          	auipc	ra,0xfffff
    800057ca:	a1a080e7          	jalr	-1510(ra) # 800041e0 <end_op>
    return -1;
    800057ce:	557d                	li	a0,-1
    800057d0:	a065                	j	80005878 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    800057d2:	00003517          	auipc	a0,0x3
    800057d6:	11650513          	addi	a0,a0,278 # 800088e8 <userret+0x858>
    800057da:	ffffb097          	auipc	ra,0xffffb
    800057de:	d6e080e7          	jalr	-658(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057e2:	05492703          	lw	a4,84(s2)
    800057e6:	02000793          	li	a5,32
    800057ea:	f6e7f7e3          	bgeu	a5,a4,80005758 <sys_unlink+0xac>
    800057ee:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057f2:	4741                	li	a4,16
    800057f4:	86ce                	mv	a3,s3
    800057f6:	f1840613          	addi	a2,s0,-232
    800057fa:	4581                	li	a1,0
    800057fc:	854a                	mv	a0,s2
    800057fe:	ffffe097          	auipc	ra,0xffffe
    80005802:	122080e7          	jalr	290(ra) # 80003920 <readi>
    80005806:	47c1                	li	a5,16
    80005808:	00f51b63          	bne	a0,a5,8000581e <sys_unlink+0x172>
    if(de.inum != 0)
    8000580c:	f1845783          	lhu	a5,-232(s0)
    80005810:	e7a1                	bnez	a5,80005858 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005812:	29c1                	addiw	s3,s3,16
    80005814:	05492783          	lw	a5,84(s2)
    80005818:	fcf9ede3          	bltu	s3,a5,800057f2 <sys_unlink+0x146>
    8000581c:	bf35                	j	80005758 <sys_unlink+0xac>
      panic("isdirempty: readi");
    8000581e:	00003517          	auipc	a0,0x3
    80005822:	0e250513          	addi	a0,a0,226 # 80008900 <userret+0x870>
    80005826:	ffffb097          	auipc	ra,0xffffb
    8000582a:	d22080e7          	jalr	-734(ra) # 80000548 <panic>
    panic("unlink: writei");
    8000582e:	00003517          	auipc	a0,0x3
    80005832:	0ea50513          	addi	a0,a0,234 # 80008918 <userret+0x888>
    80005836:	ffffb097          	auipc	ra,0xffffb
    8000583a:	d12080e7          	jalr	-750(ra) # 80000548 <panic>
    dp->nlink--;
    8000583e:	0524d783          	lhu	a5,82(s1)
    80005842:	37fd                	addiw	a5,a5,-1
    80005844:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005848:	8526                	mv	a0,s1
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	d7c080e7          	jalr	-644(ra) # 800035c6 <iupdate>
    80005852:	bf35                	j	8000578e <sys_unlink+0xe2>
    return -1;
    80005854:	557d                	li	a0,-1
    80005856:	a00d                	j	80005878 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005858:	854a                	mv	a0,s2
    8000585a:	ffffe097          	auipc	ra,0xffffe
    8000585e:	074080e7          	jalr	116(ra) # 800038ce <iunlockput>
  iunlockput(dp);
    80005862:	8526                	mv	a0,s1
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	06a080e7          	jalr	106(ra) # 800038ce <iunlockput>
  end_op(ROOTDEV);
    8000586c:	4501                	li	a0,0
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	972080e7          	jalr	-1678(ra) # 800041e0 <end_op>
  return -1;
    80005876:	557d                	li	a0,-1
}
    80005878:	70ae                	ld	ra,232(sp)
    8000587a:	740e                	ld	s0,224(sp)
    8000587c:	64ee                	ld	s1,216(sp)
    8000587e:	694e                	ld	s2,208(sp)
    80005880:	69ae                	ld	s3,200(sp)
    80005882:	616d                	addi	sp,sp,240
    80005884:	8082                	ret

0000000080005886 <sys_open>:

uint64
sys_open(void)
{
    80005886:	7131                	addi	sp,sp,-192
    80005888:	fd06                	sd	ra,184(sp)
    8000588a:	f922                	sd	s0,176(sp)
    8000588c:	f526                	sd	s1,168(sp)
    8000588e:	f14a                	sd	s2,160(sp)
    80005890:	ed4e                	sd	s3,152(sp)
    80005892:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005894:	08000613          	li	a2,128
    80005898:	f5040593          	addi	a1,s0,-176
    8000589c:	4501                	li	a0,0
    8000589e:	ffffd097          	auipc	ra,0xffffd
    800058a2:	2c2080e7          	jalr	706(ra) # 80002b60 <argstr>
    return -1;
    800058a6:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058a8:	0a054963          	bltz	a0,8000595a <sys_open+0xd4>
    800058ac:	f4c40593          	addi	a1,s0,-180
    800058b0:	4505                	li	a0,1
    800058b2:	ffffd097          	auipc	ra,0xffffd
    800058b6:	26a080e7          	jalr	618(ra) # 80002b1c <argint>
    800058ba:	0a054063          	bltz	a0,8000595a <sys_open+0xd4>

  begin_op(ROOTDEV);
    800058be:	4501                	li	a0,0
    800058c0:	fffff097          	auipc	ra,0xfffff
    800058c4:	876080e7          	jalr	-1930(ra) # 80004136 <begin_op>

  if(omode & O_CREATE){
    800058c8:	f4c42783          	lw	a5,-180(s0)
    800058cc:	2007f793          	andi	a5,a5,512
    800058d0:	c3dd                	beqz	a5,80005976 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    800058d2:	4681                	li	a3,0
    800058d4:	4601                	li	a2,0
    800058d6:	4589                	li	a1,2
    800058d8:	f5040513          	addi	a0,s0,-176
    800058dc:	00000097          	auipc	ra,0x0
    800058e0:	960080e7          	jalr	-1696(ra) # 8000523c <create>
    800058e4:	892a                	mv	s2,a0
    if(ip == 0){
    800058e6:	c151                	beqz	a0,8000596a <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058e8:	04c91703          	lh	a4,76(s2)
    800058ec:	478d                	li	a5,3
    800058ee:	00f71763          	bne	a4,a5,800058fc <sys_open+0x76>
    800058f2:	04e95703          	lhu	a4,78(s2)
    800058f6:	47a5                	li	a5,9
    800058f8:	0ce7e663          	bltu	a5,a4,800059c4 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058fc:	fffff097          	auipc	ra,0xfffff
    80005900:	da6080e7          	jalr	-602(ra) # 800046a2 <filealloc>
    80005904:	89aa                	mv	s3,a0
    80005906:	c97d                	beqz	a0,800059fc <sys_open+0x176>
    80005908:	00000097          	auipc	ra,0x0
    8000590c:	8f2080e7          	jalr	-1806(ra) # 800051fa <fdalloc>
    80005910:	84aa                	mv	s1,a0
    80005912:	0e054063          	bltz	a0,800059f2 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005916:	04c91703          	lh	a4,76(s2)
    8000591a:	478d                	li	a5,3
    8000591c:	0cf70063          	beq	a4,a5,800059dc <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005920:	4789                	li	a5,2
    80005922:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005926:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    8000592a:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    8000592e:	f4c42783          	lw	a5,-180(s0)
    80005932:	0017c713          	xori	a4,a5,1
    80005936:	8b05                	andi	a4,a4,1
    80005938:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000593c:	8b8d                	andi	a5,a5,3
    8000593e:	00f037b3          	snez	a5,a5
    80005942:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005946:	854a                	mv	a0,s2
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	e0a080e7          	jalr	-502(ra) # 80003752 <iunlock>
  end_op(ROOTDEV);
    80005950:	4501                	li	a0,0
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	88e080e7          	jalr	-1906(ra) # 800041e0 <end_op>

  return fd;
}
    8000595a:	8526                	mv	a0,s1
    8000595c:	70ea                	ld	ra,184(sp)
    8000595e:	744a                	ld	s0,176(sp)
    80005960:	74aa                	ld	s1,168(sp)
    80005962:	790a                	ld	s2,160(sp)
    80005964:	69ea                	ld	s3,152(sp)
    80005966:	6129                	addi	sp,sp,192
    80005968:	8082                	ret
      end_op(ROOTDEV);
    8000596a:	4501                	li	a0,0
    8000596c:	fffff097          	auipc	ra,0xfffff
    80005970:	874080e7          	jalr	-1932(ra) # 800041e0 <end_op>
      return -1;
    80005974:	b7dd                	j	8000595a <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005976:	f5040513          	addi	a0,s0,-176
    8000597a:	ffffe097          	auipc	ra,0xffffe
    8000597e:	4a0080e7          	jalr	1184(ra) # 80003e1a <namei>
    80005982:	892a                	mv	s2,a0
    80005984:	c90d                	beqz	a0,800059b6 <sys_open+0x130>
    ilock(ip);
    80005986:	ffffe097          	auipc	ra,0xffffe
    8000598a:	d0a080e7          	jalr	-758(ra) # 80003690 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000598e:	04c91703          	lh	a4,76(s2)
    80005992:	4785                	li	a5,1
    80005994:	f4f71ae3          	bne	a4,a5,800058e8 <sys_open+0x62>
    80005998:	f4c42783          	lw	a5,-180(s0)
    8000599c:	d3a5                	beqz	a5,800058fc <sys_open+0x76>
      iunlockput(ip);
    8000599e:	854a                	mv	a0,s2
    800059a0:	ffffe097          	auipc	ra,0xffffe
    800059a4:	f2e080e7          	jalr	-210(ra) # 800038ce <iunlockput>
      end_op(ROOTDEV);
    800059a8:	4501                	li	a0,0
    800059aa:	fffff097          	auipc	ra,0xfffff
    800059ae:	836080e7          	jalr	-1994(ra) # 800041e0 <end_op>
      return -1;
    800059b2:	54fd                	li	s1,-1
    800059b4:	b75d                	j	8000595a <sys_open+0xd4>
      end_op(ROOTDEV);
    800059b6:	4501                	li	a0,0
    800059b8:	fffff097          	auipc	ra,0xfffff
    800059bc:	828080e7          	jalr	-2008(ra) # 800041e0 <end_op>
      return -1;
    800059c0:	54fd                	li	s1,-1
    800059c2:	bf61                	j	8000595a <sys_open+0xd4>
    iunlockput(ip);
    800059c4:	854a                	mv	a0,s2
    800059c6:	ffffe097          	auipc	ra,0xffffe
    800059ca:	f08080e7          	jalr	-248(ra) # 800038ce <iunlockput>
    end_op(ROOTDEV);
    800059ce:	4501                	li	a0,0
    800059d0:	fffff097          	auipc	ra,0xfffff
    800059d4:	810080e7          	jalr	-2032(ra) # 800041e0 <end_op>
    return -1;
    800059d8:	54fd                	li	s1,-1
    800059da:	b741                	j	8000595a <sys_open+0xd4>
    f->type = FD_DEVICE;
    800059dc:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059e0:	04e91783          	lh	a5,78(s2)
    800059e4:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    800059e8:	05091783          	lh	a5,80(s2)
    800059ec:	02f99323          	sh	a5,38(s3)
    800059f0:	bf1d                	j	80005926 <sys_open+0xa0>
      fileclose(f);
    800059f2:	854e                	mv	a0,s3
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	d6a080e7          	jalr	-662(ra) # 8000475e <fileclose>
    iunlockput(ip);
    800059fc:	854a                	mv	a0,s2
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	ed0080e7          	jalr	-304(ra) # 800038ce <iunlockput>
    end_op(ROOTDEV);
    80005a06:	4501                	li	a0,0
    80005a08:	ffffe097          	auipc	ra,0xffffe
    80005a0c:	7d8080e7          	jalr	2008(ra) # 800041e0 <end_op>
    return -1;
    80005a10:	54fd                	li	s1,-1
    80005a12:	b7a1                	j	8000595a <sys_open+0xd4>

0000000080005a14 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a14:	7175                	addi	sp,sp,-144
    80005a16:	e506                	sd	ra,136(sp)
    80005a18:	e122                	sd	s0,128(sp)
    80005a1a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005a1c:	4501                	li	a0,0
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	718080e7          	jalr	1816(ra) # 80004136 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a26:	08000613          	li	a2,128
    80005a2a:	f7040593          	addi	a1,s0,-144
    80005a2e:	4501                	li	a0,0
    80005a30:	ffffd097          	auipc	ra,0xffffd
    80005a34:	130080e7          	jalr	304(ra) # 80002b60 <argstr>
    80005a38:	02054a63          	bltz	a0,80005a6c <sys_mkdir+0x58>
    80005a3c:	4681                	li	a3,0
    80005a3e:	4601                	li	a2,0
    80005a40:	4585                	li	a1,1
    80005a42:	f7040513          	addi	a0,s0,-144
    80005a46:	fffff097          	auipc	ra,0xfffff
    80005a4a:	7f6080e7          	jalr	2038(ra) # 8000523c <create>
    80005a4e:	cd19                	beqz	a0,80005a6c <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005a50:	ffffe097          	auipc	ra,0xffffe
    80005a54:	e7e080e7          	jalr	-386(ra) # 800038ce <iunlockput>
  end_op(ROOTDEV);
    80005a58:	4501                	li	a0,0
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	786080e7          	jalr	1926(ra) # 800041e0 <end_op>
  return 0;
    80005a62:	4501                	li	a0,0
}
    80005a64:	60aa                	ld	ra,136(sp)
    80005a66:	640a                	ld	s0,128(sp)
    80005a68:	6149                	addi	sp,sp,144
    80005a6a:	8082                	ret
    end_op(ROOTDEV);
    80005a6c:	4501                	li	a0,0
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	772080e7          	jalr	1906(ra) # 800041e0 <end_op>
    return -1;
    80005a76:	557d                	li	a0,-1
    80005a78:	b7f5                	j	80005a64 <sys_mkdir+0x50>

0000000080005a7a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a7a:	7135                	addi	sp,sp,-160
    80005a7c:	ed06                	sd	ra,152(sp)
    80005a7e:	e922                	sd	s0,144(sp)
    80005a80:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005a82:	4501                	li	a0,0
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	6b2080e7          	jalr	1714(ra) # 80004136 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a8c:	08000613          	li	a2,128
    80005a90:	f7040593          	addi	a1,s0,-144
    80005a94:	4501                	li	a0,0
    80005a96:	ffffd097          	auipc	ra,0xffffd
    80005a9a:	0ca080e7          	jalr	202(ra) # 80002b60 <argstr>
    80005a9e:	04054b63          	bltz	a0,80005af4 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80005aa2:	f6c40593          	addi	a1,s0,-148
    80005aa6:	4505                	li	a0,1
    80005aa8:	ffffd097          	auipc	ra,0xffffd
    80005aac:	074080e7          	jalr	116(ra) # 80002b1c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ab0:	04054263          	bltz	a0,80005af4 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005ab4:	f6840593          	addi	a1,s0,-152
    80005ab8:	4509                	li	a0,2
    80005aba:	ffffd097          	auipc	ra,0xffffd
    80005abe:	062080e7          	jalr	98(ra) # 80002b1c <argint>
     argint(1, &major) < 0 ||
    80005ac2:	02054963          	bltz	a0,80005af4 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ac6:	f6841683          	lh	a3,-152(s0)
    80005aca:	f6c41603          	lh	a2,-148(s0)
    80005ace:	458d                	li	a1,3
    80005ad0:	f7040513          	addi	a0,s0,-144
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	768080e7          	jalr	1896(ra) # 8000523c <create>
     argint(2, &minor) < 0 ||
    80005adc:	cd01                	beqz	a0,80005af4 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005ade:	ffffe097          	auipc	ra,0xffffe
    80005ae2:	df0080e7          	jalr	-528(ra) # 800038ce <iunlockput>
  end_op(ROOTDEV);
    80005ae6:	4501                	li	a0,0
    80005ae8:	ffffe097          	auipc	ra,0xffffe
    80005aec:	6f8080e7          	jalr	1784(ra) # 800041e0 <end_op>
  return 0;
    80005af0:	4501                	li	a0,0
    80005af2:	a039                	j	80005b00 <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005af4:	4501                	li	a0,0
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	6ea080e7          	jalr	1770(ra) # 800041e0 <end_op>
    return -1;
    80005afe:	557d                	li	a0,-1
}
    80005b00:	60ea                	ld	ra,152(sp)
    80005b02:	644a                	ld	s0,144(sp)
    80005b04:	610d                	addi	sp,sp,160
    80005b06:	8082                	ret

0000000080005b08 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b08:	7135                	addi	sp,sp,-160
    80005b0a:	ed06                	sd	ra,152(sp)
    80005b0c:	e922                	sd	s0,144(sp)
    80005b0e:	e526                	sd	s1,136(sp)
    80005b10:	e14a                	sd	s2,128(sp)
    80005b12:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b14:	ffffc097          	auipc	ra,0xffffc
    80005b18:	f4e080e7          	jalr	-178(ra) # 80001a62 <myproc>
    80005b1c:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005b1e:	4501                	li	a0,0
    80005b20:	ffffe097          	auipc	ra,0xffffe
    80005b24:	616080e7          	jalr	1558(ra) # 80004136 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b28:	08000613          	li	a2,128
    80005b2c:	f6040593          	addi	a1,s0,-160
    80005b30:	4501                	li	a0,0
    80005b32:	ffffd097          	auipc	ra,0xffffd
    80005b36:	02e080e7          	jalr	46(ra) # 80002b60 <argstr>
    80005b3a:	04054c63          	bltz	a0,80005b92 <sys_chdir+0x8a>
    80005b3e:	f6040513          	addi	a0,s0,-160
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	2d8080e7          	jalr	728(ra) # 80003e1a <namei>
    80005b4a:	84aa                	mv	s1,a0
    80005b4c:	c139                	beqz	a0,80005b92 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005b4e:	ffffe097          	auipc	ra,0xffffe
    80005b52:	b42080e7          	jalr	-1214(ra) # 80003690 <ilock>
  if(ip->type != T_DIR){
    80005b56:	04c49703          	lh	a4,76(s1)
    80005b5a:	4785                	li	a5,1
    80005b5c:	04f71263          	bne	a4,a5,80005ba0 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005b60:	8526                	mv	a0,s1
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	bf0080e7          	jalr	-1040(ra) # 80003752 <iunlock>
  iput(p->cwd);
    80005b6a:	15893503          	ld	a0,344(s2)
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	c30080e7          	jalr	-976(ra) # 8000379e <iput>
  end_op(ROOTDEV);
    80005b76:	4501                	li	a0,0
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	668080e7          	jalr	1640(ra) # 800041e0 <end_op>
  p->cwd = ip;
    80005b80:	14993c23          	sd	s1,344(s2)
  return 0;
    80005b84:	4501                	li	a0,0
}
    80005b86:	60ea                	ld	ra,152(sp)
    80005b88:	644a                	ld	s0,144(sp)
    80005b8a:	64aa                	ld	s1,136(sp)
    80005b8c:	690a                	ld	s2,128(sp)
    80005b8e:	610d                	addi	sp,sp,160
    80005b90:	8082                	ret
    end_op(ROOTDEV);
    80005b92:	4501                	li	a0,0
    80005b94:	ffffe097          	auipc	ra,0xffffe
    80005b98:	64c080e7          	jalr	1612(ra) # 800041e0 <end_op>
    return -1;
    80005b9c:	557d                	li	a0,-1
    80005b9e:	b7e5                	j	80005b86 <sys_chdir+0x7e>
    iunlockput(ip);
    80005ba0:	8526                	mv	a0,s1
    80005ba2:	ffffe097          	auipc	ra,0xffffe
    80005ba6:	d2c080e7          	jalr	-724(ra) # 800038ce <iunlockput>
    end_op(ROOTDEV);
    80005baa:	4501                	li	a0,0
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	634080e7          	jalr	1588(ra) # 800041e0 <end_op>
    return -1;
    80005bb4:	557d                	li	a0,-1
    80005bb6:	bfc1                	j	80005b86 <sys_chdir+0x7e>

0000000080005bb8 <sys_exec>:

uint64
sys_exec(void)
{
    80005bb8:	7145                	addi	sp,sp,-464
    80005bba:	e786                	sd	ra,456(sp)
    80005bbc:	e3a2                	sd	s0,448(sp)
    80005bbe:	ff26                	sd	s1,440(sp)
    80005bc0:	fb4a                	sd	s2,432(sp)
    80005bc2:	f74e                	sd	s3,424(sp)
    80005bc4:	f352                	sd	s4,416(sp)
    80005bc6:	ef56                	sd	s5,408(sp)
    80005bc8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bca:	08000613          	li	a2,128
    80005bce:	f4040593          	addi	a1,s0,-192
    80005bd2:	4501                	li	a0,0
    80005bd4:	ffffd097          	auipc	ra,0xffffd
    80005bd8:	f8c080e7          	jalr	-116(ra) # 80002b60 <argstr>
    80005bdc:	0e054663          	bltz	a0,80005cc8 <sys_exec+0x110>
    80005be0:	e3840593          	addi	a1,s0,-456
    80005be4:	4505                	li	a0,1
    80005be6:	ffffd097          	auipc	ra,0xffffd
    80005bea:	f58080e7          	jalr	-168(ra) # 80002b3e <argaddr>
    80005bee:	0e054763          	bltz	a0,80005cdc <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005bf2:	10000613          	li	a2,256
    80005bf6:	4581                	li	a1,0
    80005bf8:	e4040513          	addi	a0,s0,-448
    80005bfc:	ffffb097          	auipc	ra,0xffffb
    80005c00:	17c080e7          	jalr	380(ra) # 80000d78 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c04:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c08:	89ca                	mv	s3,s2
    80005c0a:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005c0c:	02000a13          	li	s4,32
    80005c10:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c14:	00349793          	slli	a5,s1,0x3
    80005c18:	e3040593          	addi	a1,s0,-464
    80005c1c:	e3843503          	ld	a0,-456(s0)
    80005c20:	953e                	add	a0,a0,a5
    80005c22:	ffffd097          	auipc	ra,0xffffd
    80005c26:	e60080e7          	jalr	-416(ra) # 80002a82 <fetchaddr>
    80005c2a:	02054a63          	bltz	a0,80005c5e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c2e:	e3043783          	ld	a5,-464(s0)
    80005c32:	c7a1                	beqz	a5,80005c7a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c34:	ffffb097          	auipc	ra,0xffffb
    80005c38:	d2c080e7          	jalr	-724(ra) # 80000960 <kalloc>
    80005c3c:	85aa                	mv	a1,a0
    80005c3e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c42:	c92d                	beqz	a0,80005cb4 <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005c44:	6605                	lui	a2,0x1
    80005c46:	e3043503          	ld	a0,-464(s0)
    80005c4a:	ffffd097          	auipc	ra,0xffffd
    80005c4e:	e8a080e7          	jalr	-374(ra) # 80002ad4 <fetchstr>
    80005c52:	00054663          	bltz	a0,80005c5e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c56:	0485                	addi	s1,s1,1
    80005c58:	09a1                	addi	s3,s3,8
    80005c5a:	fb449be3          	bne	s1,s4,80005c10 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c5e:	10090493          	addi	s1,s2,256
    80005c62:	00093503          	ld	a0,0(s2)
    80005c66:	cd39                	beqz	a0,80005cc4 <sys_exec+0x10c>
    kfree(argv[i]);
    80005c68:	ffffb097          	auipc	ra,0xffffb
    80005c6c:	bfc080e7          	jalr	-1028(ra) # 80000864 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c70:	0921                	addi	s2,s2,8
    80005c72:	fe9918e3          	bne	s2,s1,80005c62 <sys_exec+0xaa>
  return -1;
    80005c76:	557d                	li	a0,-1
    80005c78:	a889                	j	80005cca <sys_exec+0x112>
      argv[i] = 0;
    80005c7a:	0a8e                	slli	s5,s5,0x3
    80005c7c:	fc040793          	addi	a5,s0,-64
    80005c80:	9abe                	add	s5,s5,a5
    80005c82:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c86:	e4040593          	addi	a1,s0,-448
    80005c8a:	f4040513          	addi	a0,s0,-192
    80005c8e:	fffff097          	auipc	ra,0xfffff
    80005c92:	178080e7          	jalr	376(ra) # 80004e06 <exec>
    80005c96:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c98:	10090993          	addi	s3,s2,256
    80005c9c:	00093503          	ld	a0,0(s2)
    80005ca0:	c901                	beqz	a0,80005cb0 <sys_exec+0xf8>
    kfree(argv[i]);
    80005ca2:	ffffb097          	auipc	ra,0xffffb
    80005ca6:	bc2080e7          	jalr	-1086(ra) # 80000864 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005caa:	0921                	addi	s2,s2,8
    80005cac:	ff3918e3          	bne	s2,s3,80005c9c <sys_exec+0xe4>
  return ret;
    80005cb0:	8526                	mv	a0,s1
    80005cb2:	a821                	j	80005cca <sys_exec+0x112>
      panic("sys_exec kalloc");
    80005cb4:	00003517          	auipc	a0,0x3
    80005cb8:	c7450513          	addi	a0,a0,-908 # 80008928 <userret+0x898>
    80005cbc:	ffffb097          	auipc	ra,0xffffb
    80005cc0:	88c080e7          	jalr	-1908(ra) # 80000548 <panic>
  return -1;
    80005cc4:	557d                	li	a0,-1
    80005cc6:	a011                	j	80005cca <sys_exec+0x112>
    return -1;
    80005cc8:	557d                	li	a0,-1
}
    80005cca:	60be                	ld	ra,456(sp)
    80005ccc:	641e                	ld	s0,448(sp)
    80005cce:	74fa                	ld	s1,440(sp)
    80005cd0:	795a                	ld	s2,432(sp)
    80005cd2:	79ba                	ld	s3,424(sp)
    80005cd4:	7a1a                	ld	s4,416(sp)
    80005cd6:	6afa                	ld	s5,408(sp)
    80005cd8:	6179                	addi	sp,sp,464
    80005cda:	8082                	ret
    return -1;
    80005cdc:	557d                	li	a0,-1
    80005cde:	b7f5                	j	80005cca <sys_exec+0x112>

0000000080005ce0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ce0:	7139                	addi	sp,sp,-64
    80005ce2:	fc06                	sd	ra,56(sp)
    80005ce4:	f822                	sd	s0,48(sp)
    80005ce6:	f426                	sd	s1,40(sp)
    80005ce8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cea:	ffffc097          	auipc	ra,0xffffc
    80005cee:	d78080e7          	jalr	-648(ra) # 80001a62 <myproc>
    80005cf2:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005cf4:	fd840593          	addi	a1,s0,-40
    80005cf8:	4501                	li	a0,0
    80005cfa:	ffffd097          	auipc	ra,0xffffd
    80005cfe:	e44080e7          	jalr	-444(ra) # 80002b3e <argaddr>
    return -1;
    80005d02:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d04:	0e054063          	bltz	a0,80005de4 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d08:	fc840593          	addi	a1,s0,-56
    80005d0c:	fd040513          	addi	a0,s0,-48
    80005d10:	fffff097          	auipc	ra,0xfffff
    80005d14:	db2080e7          	jalr	-590(ra) # 80004ac2 <pipealloc>
    return -1;
    80005d18:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d1a:	0c054563          	bltz	a0,80005de4 <sys_pipe+0x104>
  fd0 = -1;
    80005d1e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d22:	fd043503          	ld	a0,-48(s0)
    80005d26:	fffff097          	auipc	ra,0xfffff
    80005d2a:	4d4080e7          	jalr	1236(ra) # 800051fa <fdalloc>
    80005d2e:	fca42223          	sw	a0,-60(s0)
    80005d32:	08054c63          	bltz	a0,80005dca <sys_pipe+0xea>
    80005d36:	fc843503          	ld	a0,-56(s0)
    80005d3a:	fffff097          	auipc	ra,0xfffff
    80005d3e:	4c0080e7          	jalr	1216(ra) # 800051fa <fdalloc>
    80005d42:	fca42023          	sw	a0,-64(s0)
    80005d46:	06054863          	bltz	a0,80005db6 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d4a:	4691                	li	a3,4
    80005d4c:	fc440613          	addi	a2,s0,-60
    80005d50:	fd843583          	ld	a1,-40(s0)
    80005d54:	6ca8                	ld	a0,88(s1)
    80005d56:	ffffc097          	auipc	ra,0xffffc
    80005d5a:	9fe080e7          	jalr	-1538(ra) # 80001754 <copyout>
    80005d5e:	02054063          	bltz	a0,80005d7e <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d62:	4691                	li	a3,4
    80005d64:	fc040613          	addi	a2,s0,-64
    80005d68:	fd843583          	ld	a1,-40(s0)
    80005d6c:	0591                	addi	a1,a1,4
    80005d6e:	6ca8                	ld	a0,88(s1)
    80005d70:	ffffc097          	auipc	ra,0xffffc
    80005d74:	9e4080e7          	jalr	-1564(ra) # 80001754 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d78:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d7a:	06055563          	bgez	a0,80005de4 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d7e:	fc442783          	lw	a5,-60(s0)
    80005d82:	07e9                	addi	a5,a5,26
    80005d84:	078e                	slli	a5,a5,0x3
    80005d86:	97a6                	add	a5,a5,s1
    80005d88:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005d8c:	fc042503          	lw	a0,-64(s0)
    80005d90:	0569                	addi	a0,a0,26
    80005d92:	050e                	slli	a0,a0,0x3
    80005d94:	9526                	add	a0,a0,s1
    80005d96:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005d9a:	fd043503          	ld	a0,-48(s0)
    80005d9e:	fffff097          	auipc	ra,0xfffff
    80005da2:	9c0080e7          	jalr	-1600(ra) # 8000475e <fileclose>
    fileclose(wf);
    80005da6:	fc843503          	ld	a0,-56(s0)
    80005daa:	fffff097          	auipc	ra,0xfffff
    80005dae:	9b4080e7          	jalr	-1612(ra) # 8000475e <fileclose>
    return -1;
    80005db2:	57fd                	li	a5,-1
    80005db4:	a805                	j	80005de4 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005db6:	fc442783          	lw	a5,-60(s0)
    80005dba:	0007c863          	bltz	a5,80005dca <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005dbe:	01a78513          	addi	a0,a5,26
    80005dc2:	050e                	slli	a0,a0,0x3
    80005dc4:	9526                	add	a0,a0,s1
    80005dc6:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005dca:	fd043503          	ld	a0,-48(s0)
    80005dce:	fffff097          	auipc	ra,0xfffff
    80005dd2:	990080e7          	jalr	-1648(ra) # 8000475e <fileclose>
    fileclose(wf);
    80005dd6:	fc843503          	ld	a0,-56(s0)
    80005dda:	fffff097          	auipc	ra,0xfffff
    80005dde:	984080e7          	jalr	-1660(ra) # 8000475e <fileclose>
    return -1;
    80005de2:	57fd                	li	a5,-1
}
    80005de4:	853e                	mv	a0,a5
    80005de6:	70e2                	ld	ra,56(sp)
    80005de8:	7442                	ld	s0,48(sp)
    80005dea:	74a2                	ld	s1,40(sp)
    80005dec:	6121                	addi	sp,sp,64
    80005dee:	8082                	ret

0000000080005df0 <sys_crash>:

// system call to test crashes
uint64
sys_crash(void)
{
    80005df0:	7171                	addi	sp,sp,-176
    80005df2:	f506                	sd	ra,168(sp)
    80005df4:	f122                	sd	s0,160(sp)
    80005df6:	ed26                	sd	s1,152(sp)
    80005df8:	1900                	addi	s0,sp,176
  char path[MAXPATH];
  struct inode *ip;
  int crash;
  
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005dfa:	08000613          	li	a2,128
    80005dfe:	f6040593          	addi	a1,s0,-160
    80005e02:	4501                	li	a0,0
    80005e04:	ffffd097          	auipc	ra,0xffffd
    80005e08:	d5c080e7          	jalr	-676(ra) # 80002b60 <argstr>
    return -1;
    80005e0c:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005e0e:	04054363          	bltz	a0,80005e54 <sys_crash+0x64>
    80005e12:	f5c40593          	addi	a1,s0,-164
    80005e16:	4505                	li	a0,1
    80005e18:	ffffd097          	auipc	ra,0xffffd
    80005e1c:	d04080e7          	jalr	-764(ra) # 80002b1c <argint>
    return -1;
    80005e20:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005e22:	02054963          	bltz	a0,80005e54 <sys_crash+0x64>
  ip = create(path, T_FILE, 0, 0);
    80005e26:	4681                	li	a3,0
    80005e28:	4601                	li	a2,0
    80005e2a:	4589                	li	a1,2
    80005e2c:	f6040513          	addi	a0,s0,-160
    80005e30:	fffff097          	auipc	ra,0xfffff
    80005e34:	40c080e7          	jalr	1036(ra) # 8000523c <create>
    80005e38:	84aa                	mv	s1,a0
  if(ip == 0){
    80005e3a:	c11d                	beqz	a0,80005e60 <sys_crash+0x70>
    return -1;
  }
  iunlockput(ip);
    80005e3c:	ffffe097          	auipc	ra,0xffffe
    80005e40:	a92080e7          	jalr	-1390(ra) # 800038ce <iunlockput>
  crash_op(ip->dev, crash);
    80005e44:	f5c42583          	lw	a1,-164(s0)
    80005e48:	4088                	lw	a0,0(s1)
    80005e4a:	ffffe097          	auipc	ra,0xffffe
    80005e4e:	5e8080e7          	jalr	1512(ra) # 80004432 <crash_op>
  return 0;
    80005e52:	4781                	li	a5,0
}
    80005e54:	853e                	mv	a0,a5
    80005e56:	70aa                	ld	ra,168(sp)
    80005e58:	740a                	ld	s0,160(sp)
    80005e5a:	64ea                	ld	s1,152(sp)
    80005e5c:	614d                	addi	sp,sp,176
    80005e5e:	8082                	ret
    return -1;
    80005e60:	57fd                	li	a5,-1
    80005e62:	bfcd                	j	80005e54 <sys_crash+0x64>

0000000080005e64 <sys_sigalarm>:

/** AlarmTest  */
uint64 
sys_sigalarm(void){
    80005e64:	7179                	addi	sp,sp,-48
    80005e66:	f406                	sd	ra,40(sp)
    80005e68:	f022                	sd	s0,32(sp)
    80005e6a:	ec26                	sd	s1,24(sp)
    80005e6c:	1800                	addi	s0,sp,48
 struct proc *p = myproc();
    80005e6e:	ffffc097          	auipc	ra,0xffffc
    80005e72:	bf4080e7          	jalr	-1036(ra) # 80001a62 <myproc>
    80005e76:	84aa                	mv	s1,a0
  uint64 handler;
  int ticks;

  if(argint(0, &ticks) < 0)
    80005e78:	fd440593          	addi	a1,s0,-44
    80005e7c:	4501                	li	a0,0
    80005e7e:	ffffd097          	auipc	ra,0xffffd
    80005e82:	c9e080e7          	jalr	-866(ra) # 80002b1c <argint>
    return -1;
    80005e86:	57fd                	li	a5,-1
  if(argint(0, &ticks) < 0)
    80005e88:	02054463          	bltz	a0,80005eb0 <sys_sigalarm+0x4c>
  
  if(argaddr(1, &handler) < 0)
    80005e8c:	fd840593          	addi	a1,s0,-40
    80005e90:	4505                	li	a0,1
    80005e92:	ffffd097          	auipc	ra,0xffffd
    80005e96:	cac080e7          	jalr	-852(ra) # 80002b3e <argaddr>
    80005e9a:	02054163          	bltz	a0,80005ebc <sys_sigalarm+0x58>
    return -1;
 
  p->ticks = ticks;
    80005e9e:	fd442783          	lw	a5,-44(s0)
    80005ea2:	16f4a823          	sw	a5,368(s1)
  p->handler = (void *)handler;
    80005ea6:	fd843783          	ld	a5,-40(s0)
    80005eaa:	16f4bc23          	sd	a5,376(s1)
  return 0;
    80005eae:	4781                	li	a5,0
}
    80005eb0:	853e                	mv	a0,a5
    80005eb2:	70a2                	ld	ra,40(sp)
    80005eb4:	7402                	ld	s0,32(sp)
    80005eb6:	64e2                	ld	s1,24(sp)
    80005eb8:	6145                	addi	sp,sp,48
    80005eba:	8082                	ret
    return -1;
    80005ebc:	57fd                	li	a5,-1
    80005ebe:	bfcd                	j	80005eb0 <sys_sigalarm+0x4c>

0000000080005ec0 <sys_sigreturn>:

uint64 
sys_sigreturn(void){
    80005ec0:	1141                	addi	sp,sp,-16
    80005ec2:	e406                	sd	ra,8(sp)
    80005ec4:	e022                	sd	s0,0(sp)
    80005ec6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80005ec8:	ffffc097          	auipc	ra,0xffffc
    80005ecc:	b9a080e7          	jalr	-1126(ra) # 80001a62 <myproc>
  p->tickpassed = 0;
    80005ed0:	18052023          	sw	zero,384(a0)
  memmove(p->tf, &p->savedtf, sizeof(struct trapframe));
    80005ed4:	12000613          	li	a2,288
    80005ed8:	18850593          	addi	a1,a0,392
    80005edc:	7128                	ld	a0,96(a0)
    80005ede:	ffffb097          	auipc	ra,0xffffb
    80005ee2:	ef6080e7          	jalr	-266(ra) # 80000dd4 <memmove>
  // printf("call return;\n");
  return 0;
    80005ee6:	4501                	li	a0,0
    80005ee8:	60a2                	ld	ra,8(sp)
    80005eea:	6402                	ld	s0,0(sp)
    80005eec:	0141                	addi	sp,sp,16
    80005eee:	8082                	ret

0000000080005ef0 <kernelvec>:
    80005ef0:	7111                	addi	sp,sp,-256
    80005ef2:	e006                	sd	ra,0(sp)
    80005ef4:	e40a                	sd	sp,8(sp)
    80005ef6:	e80e                	sd	gp,16(sp)
    80005ef8:	ec12                	sd	tp,24(sp)
    80005efa:	f016                	sd	t0,32(sp)
    80005efc:	f41a                	sd	t1,40(sp)
    80005efe:	f81e                	sd	t2,48(sp)
    80005f00:	fc22                	sd	s0,56(sp)
    80005f02:	e0a6                	sd	s1,64(sp)
    80005f04:	e4aa                	sd	a0,72(sp)
    80005f06:	e8ae                	sd	a1,80(sp)
    80005f08:	ecb2                	sd	a2,88(sp)
    80005f0a:	f0b6                	sd	a3,96(sp)
    80005f0c:	f4ba                	sd	a4,104(sp)
    80005f0e:	f8be                	sd	a5,112(sp)
    80005f10:	fcc2                	sd	a6,120(sp)
    80005f12:	e146                	sd	a7,128(sp)
    80005f14:	e54a                	sd	s2,136(sp)
    80005f16:	e94e                	sd	s3,144(sp)
    80005f18:	ed52                	sd	s4,152(sp)
    80005f1a:	f156                	sd	s5,160(sp)
    80005f1c:	f55a                	sd	s6,168(sp)
    80005f1e:	f95e                	sd	s7,176(sp)
    80005f20:	fd62                	sd	s8,184(sp)
    80005f22:	e1e6                	sd	s9,192(sp)
    80005f24:	e5ea                	sd	s10,200(sp)
    80005f26:	e9ee                	sd	s11,208(sp)
    80005f28:	edf2                	sd	t3,216(sp)
    80005f2a:	f1f6                	sd	t4,224(sp)
    80005f2c:	f5fa                	sd	t5,232(sp)
    80005f2e:	f9fe                	sd	t6,240(sp)
    80005f30:	a1ffc0ef          	jal	ra,8000294e <kerneltrap>
    80005f34:	6082                	ld	ra,0(sp)
    80005f36:	6122                	ld	sp,8(sp)
    80005f38:	61c2                	ld	gp,16(sp)
    80005f3a:	7282                	ld	t0,32(sp)
    80005f3c:	7322                	ld	t1,40(sp)
    80005f3e:	73c2                	ld	t2,48(sp)
    80005f40:	7462                	ld	s0,56(sp)
    80005f42:	6486                	ld	s1,64(sp)
    80005f44:	6526                	ld	a0,72(sp)
    80005f46:	65c6                	ld	a1,80(sp)
    80005f48:	6666                	ld	a2,88(sp)
    80005f4a:	7686                	ld	a3,96(sp)
    80005f4c:	7726                	ld	a4,104(sp)
    80005f4e:	77c6                	ld	a5,112(sp)
    80005f50:	7866                	ld	a6,120(sp)
    80005f52:	688a                	ld	a7,128(sp)
    80005f54:	692a                	ld	s2,136(sp)
    80005f56:	69ca                	ld	s3,144(sp)
    80005f58:	6a6a                	ld	s4,152(sp)
    80005f5a:	7a8a                	ld	s5,160(sp)
    80005f5c:	7b2a                	ld	s6,168(sp)
    80005f5e:	7bca                	ld	s7,176(sp)
    80005f60:	7c6a                	ld	s8,184(sp)
    80005f62:	6c8e                	ld	s9,192(sp)
    80005f64:	6d2e                	ld	s10,200(sp)
    80005f66:	6dce                	ld	s11,208(sp)
    80005f68:	6e6e                	ld	t3,216(sp)
    80005f6a:	7e8e                	ld	t4,224(sp)
    80005f6c:	7f2e                	ld	t5,232(sp)
    80005f6e:	7fce                	ld	t6,240(sp)
    80005f70:	6111                	addi	sp,sp,256
    80005f72:	10200073          	sret
    80005f76:	00000013          	nop
    80005f7a:	00000013          	nop
    80005f7e:	0001                	nop

0000000080005f80 <timervec>:
    80005f80:	34051573          	csrrw	a0,mscratch,a0
    80005f84:	e10c                	sd	a1,0(a0)
    80005f86:	e510                	sd	a2,8(a0)
    80005f88:	e914                	sd	a3,16(a0)
    80005f8a:	710c                	ld	a1,32(a0)
    80005f8c:	7510                	ld	a2,40(a0)
    80005f8e:	6194                	ld	a3,0(a1)
    80005f90:	96b2                	add	a3,a3,a2
    80005f92:	e194                	sd	a3,0(a1)
    80005f94:	4589                	li	a1,2
    80005f96:	14459073          	csrw	sip,a1
    80005f9a:	6914                	ld	a3,16(a0)
    80005f9c:	6510                	ld	a2,8(a0)
    80005f9e:	610c                	ld	a1,0(a0)
    80005fa0:	34051573          	csrrw	a0,mscratch,a0
    80005fa4:	30200073          	mret
	...

0000000080005faa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005faa:	1141                	addi	sp,sp,-16
    80005fac:	e422                	sd	s0,8(sp)
    80005fae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005fb0:	0c0007b7          	lui	a5,0xc000
    80005fb4:	4705                	li	a4,1
    80005fb6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005fb8:	c3d8                	sw	a4,4(a5)
}
    80005fba:	6422                	ld	s0,8(sp)
    80005fbc:	0141                	addi	sp,sp,16
    80005fbe:	8082                	ret

0000000080005fc0 <plicinithart>:

void
plicinithart(void)
{
    80005fc0:	1141                	addi	sp,sp,-16
    80005fc2:	e406                	sd	ra,8(sp)
    80005fc4:	e022                	sd	s0,0(sp)
    80005fc6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fc8:	ffffc097          	auipc	ra,0xffffc
    80005fcc:	a6e080e7          	jalr	-1426(ra) # 80001a36 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fd0:	0085171b          	slliw	a4,a0,0x8
    80005fd4:	0c0027b7          	lui	a5,0xc002
    80005fd8:	97ba                	add	a5,a5,a4
    80005fda:	40200713          	li	a4,1026
    80005fde:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fe2:	00d5151b          	slliw	a0,a0,0xd
    80005fe6:	0c2017b7          	lui	a5,0xc201
    80005fea:	953e                	add	a0,a0,a5
    80005fec:	00052023          	sw	zero,0(a0)
}
    80005ff0:	60a2                	ld	ra,8(sp)
    80005ff2:	6402                	ld	s0,0(sp)
    80005ff4:	0141                	addi	sp,sp,16
    80005ff6:	8082                	ret

0000000080005ff8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ff8:	1141                	addi	sp,sp,-16
    80005ffa:	e406                	sd	ra,8(sp)
    80005ffc:	e022                	sd	s0,0(sp)
    80005ffe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006000:	ffffc097          	auipc	ra,0xffffc
    80006004:	a36080e7          	jalr	-1482(ra) # 80001a36 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006008:	00d5179b          	slliw	a5,a0,0xd
    8000600c:	0c201537          	lui	a0,0xc201
    80006010:	953e                	add	a0,a0,a5
  return irq;
}
    80006012:	4148                	lw	a0,4(a0)
    80006014:	60a2                	ld	ra,8(sp)
    80006016:	6402                	ld	s0,0(sp)
    80006018:	0141                	addi	sp,sp,16
    8000601a:	8082                	ret

000000008000601c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000601c:	1101                	addi	sp,sp,-32
    8000601e:	ec06                	sd	ra,24(sp)
    80006020:	e822                	sd	s0,16(sp)
    80006022:	e426                	sd	s1,8(sp)
    80006024:	1000                	addi	s0,sp,32
    80006026:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006028:	ffffc097          	auipc	ra,0xffffc
    8000602c:	a0e080e7          	jalr	-1522(ra) # 80001a36 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006030:	00d5151b          	slliw	a0,a0,0xd
    80006034:	0c2017b7          	lui	a5,0xc201
    80006038:	97aa                	add	a5,a5,a0
    8000603a:	c3c4                	sw	s1,4(a5)
}
    8000603c:	60e2                	ld	ra,24(sp)
    8000603e:	6442                	ld	s0,16(sp)
    80006040:	64a2                	ld	s1,8(sp)
    80006042:	6105                	addi	sp,sp,32
    80006044:	8082                	ret

0000000080006046 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80006046:	1141                	addi	sp,sp,-16
    80006048:	e406                	sd	ra,8(sp)
    8000604a:	e022                	sd	s0,0(sp)
    8000604c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000604e:	479d                	li	a5,7
    80006050:	06b7c963          	blt	a5,a1,800060c2 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80006054:	00151793          	slli	a5,a0,0x1
    80006058:	97aa                	add	a5,a5,a0
    8000605a:	00c79713          	slli	a4,a5,0xc
    8000605e:	00025797          	auipc	a5,0x25
    80006062:	fa278793          	addi	a5,a5,-94 # 8002b000 <disk>
    80006066:	97ba                	add	a5,a5,a4
    80006068:	97ae                	add	a5,a5,a1
    8000606a:	6709                	lui	a4,0x2
    8000606c:	97ba                	add	a5,a5,a4
    8000606e:	0187c783          	lbu	a5,24(a5)
    80006072:	e3a5                	bnez	a5,800060d2 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80006074:	00025817          	auipc	a6,0x25
    80006078:	f8c80813          	addi	a6,a6,-116 # 8002b000 <disk>
    8000607c:	00151693          	slli	a3,a0,0x1
    80006080:	00a68733          	add	a4,a3,a0
    80006084:	0732                	slli	a4,a4,0xc
    80006086:	00e807b3          	add	a5,a6,a4
    8000608a:	6709                	lui	a4,0x2
    8000608c:	00f70633          	add	a2,a4,a5
    80006090:	6210                	ld	a2,0(a2)
    80006092:	00459893          	slli	a7,a1,0x4
    80006096:	9646                	add	a2,a2,a7
    80006098:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    8000609c:	97ae                	add	a5,a5,a1
    8000609e:	97ba                	add	a5,a5,a4
    800060a0:	4605                	li	a2,1
    800060a2:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    800060a6:	96aa                	add	a3,a3,a0
    800060a8:	06b2                	slli	a3,a3,0xc
    800060aa:	0761                	addi	a4,a4,24
    800060ac:	96ba                	add	a3,a3,a4
    800060ae:	00d80533          	add	a0,a6,a3
    800060b2:	ffffc097          	auipc	ra,0xffffc
    800060b6:	314080e7          	jalr	788(ra) # 800023c6 <wakeup>
}
    800060ba:	60a2                	ld	ra,8(sp)
    800060bc:	6402                	ld	s0,0(sp)
    800060be:	0141                	addi	sp,sp,16
    800060c0:	8082                	ret
    panic("virtio_disk_intr 1");
    800060c2:	00003517          	auipc	a0,0x3
    800060c6:	87650513          	addi	a0,a0,-1930 # 80008938 <userret+0x8a8>
    800060ca:	ffffa097          	auipc	ra,0xffffa
    800060ce:	47e080e7          	jalr	1150(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    800060d2:	00003517          	auipc	a0,0x3
    800060d6:	87e50513          	addi	a0,a0,-1922 # 80008950 <userret+0x8c0>
    800060da:	ffffa097          	auipc	ra,0xffffa
    800060de:	46e080e7          	jalr	1134(ra) # 80000548 <panic>

00000000800060e2 <virtio_disk_init>:
  __sync_synchronize();
    800060e2:	0ff0000f          	fence
  if(disk[n].init)
    800060e6:	00151793          	slli	a5,a0,0x1
    800060ea:	97aa                	add	a5,a5,a0
    800060ec:	07b2                	slli	a5,a5,0xc
    800060ee:	00025717          	auipc	a4,0x25
    800060f2:	f1270713          	addi	a4,a4,-238 # 8002b000 <disk>
    800060f6:	973e                	add	a4,a4,a5
    800060f8:	6789                	lui	a5,0x2
    800060fa:	97ba                	add	a5,a5,a4
    800060fc:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80006100:	c391                	beqz	a5,80006104 <virtio_disk_init+0x22>
    80006102:	8082                	ret
{
    80006104:	7139                	addi	sp,sp,-64
    80006106:	fc06                	sd	ra,56(sp)
    80006108:	f822                	sd	s0,48(sp)
    8000610a:	f426                	sd	s1,40(sp)
    8000610c:	f04a                	sd	s2,32(sp)
    8000610e:	ec4e                	sd	s3,24(sp)
    80006110:	e852                	sd	s4,16(sp)
    80006112:	e456                	sd	s5,8(sp)
    80006114:	0080                	addi	s0,sp,64
    80006116:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80006118:	85aa                	mv	a1,a0
    8000611a:	00003517          	auipc	a0,0x3
    8000611e:	84e50513          	addi	a0,a0,-1970 # 80008968 <userret+0x8d8>
    80006122:	ffffa097          	auipc	ra,0xffffa
    80006126:	480080e7          	jalr	1152(ra) # 800005a2 <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    8000612a:	00149993          	slli	s3,s1,0x1
    8000612e:	99a6                	add	s3,s3,s1
    80006130:	09b2                	slli	s3,s3,0xc
    80006132:	6789                	lui	a5,0x2
    80006134:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80006138:	97ce                	add	a5,a5,s3
    8000613a:	00003597          	auipc	a1,0x3
    8000613e:	84658593          	addi	a1,a1,-1978 # 80008980 <userret+0x8f0>
    80006142:	00025517          	auipc	a0,0x25
    80006146:	ebe50513          	addi	a0,a0,-322 # 8002b000 <disk>
    8000614a:	953e                	add	a0,a0,a5
    8000614c:	ffffb097          	auipc	ra,0xffffb
    80006150:	874080e7          	jalr	-1932(ra) # 800009c0 <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006154:	0014891b          	addiw	s2,s1,1
    80006158:	00c9191b          	slliw	s2,s2,0xc
    8000615c:	100007b7          	lui	a5,0x10000
    80006160:	97ca                	add	a5,a5,s2
    80006162:	4398                	lw	a4,0(a5)
    80006164:	2701                	sext.w	a4,a4
    80006166:	747277b7          	lui	a5,0x74727
    8000616a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000616e:	12f71663          	bne	a4,a5,8000629a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006172:	100007b7          	lui	a5,0x10000
    80006176:	0791                	addi	a5,a5,4
    80006178:	97ca                	add	a5,a5,s2
    8000617a:	439c                	lw	a5,0(a5)
    8000617c:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000617e:	4705                	li	a4,1
    80006180:	10e79d63          	bne	a5,a4,8000629a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006184:	100007b7          	lui	a5,0x10000
    80006188:	07a1                	addi	a5,a5,8
    8000618a:	97ca                	add	a5,a5,s2
    8000618c:	439c                	lw	a5,0(a5)
    8000618e:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006190:	4709                	li	a4,2
    80006192:	10e79463          	bne	a5,a4,8000629a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006196:	100007b7          	lui	a5,0x10000
    8000619a:	07b1                	addi	a5,a5,12
    8000619c:	97ca                	add	a5,a5,s2
    8000619e:	4398                	lw	a4,0(a5)
    800061a0:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061a2:	554d47b7          	lui	a5,0x554d4
    800061a6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061aa:	0ef71863          	bne	a4,a5,8000629a <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800061ae:	100007b7          	lui	a5,0x10000
    800061b2:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    800061b6:	96ca                	add	a3,a3,s2
    800061b8:	4705                	li	a4,1
    800061ba:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800061bc:	470d                	li	a4,3
    800061be:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    800061c0:	01078713          	addi	a4,a5,16
    800061c4:	974a                	add	a4,a4,s2
    800061c6:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061c8:	02078613          	addi	a2,a5,32
    800061cc:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061ce:	c7ffe737          	lui	a4,0xc7ffe
    800061d2:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fcd703>
    800061d6:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061d8:	2701                	sext.w	a4,a4
    800061da:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800061dc:	472d                	li	a4,11
    800061de:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800061e0:	473d                	li	a4,15
    800061e2:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800061e4:	02878713          	addi	a4,a5,40
    800061e8:	974a                	add	a4,a4,s2
    800061ea:	6685                	lui	a3,0x1
    800061ec:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061ee:	03078713          	addi	a4,a5,48
    800061f2:	974a                	add	a4,a4,s2
    800061f4:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061f8:	03478793          	addi	a5,a5,52
    800061fc:	97ca                	add	a5,a5,s2
    800061fe:	439c                	lw	a5,0(a5)
    80006200:	2781                	sext.w	a5,a5
  if(max == 0)
    80006202:	c7c5                	beqz	a5,800062aa <virtio_disk_init+0x1c8>
  if(max < NUM)
    80006204:	471d                	li	a4,7
    80006206:	0af77a63          	bgeu	a4,a5,800062ba <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000620a:	10000ab7          	lui	s5,0x10000
    8000620e:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80006212:	97ca                	add	a5,a5,s2
    80006214:	4721                	li	a4,8
    80006216:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80006218:	00025a17          	auipc	s4,0x25
    8000621c:	de8a0a13          	addi	s4,s4,-536 # 8002b000 <disk>
    80006220:	99d2                	add	s3,s3,s4
    80006222:	6609                	lui	a2,0x2
    80006224:	4581                	li	a1,0
    80006226:	854e                	mv	a0,s3
    80006228:	ffffb097          	auipc	ra,0xffffb
    8000622c:	b50080e7          	jalr	-1200(ra) # 80000d78 <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    80006230:	040a8a93          	addi	s5,s5,64
    80006234:	9956                	add	s2,s2,s5
    80006236:	00c9d793          	srli	a5,s3,0xc
    8000623a:	2781                	sext.w	a5,a5
    8000623c:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80006240:	00149693          	slli	a3,s1,0x1
    80006244:	009687b3          	add	a5,a3,s1
    80006248:	07b2                	slli	a5,a5,0xc
    8000624a:	97d2                	add	a5,a5,s4
    8000624c:	6609                	lui	a2,0x2
    8000624e:	97b2                	add	a5,a5,a2
    80006250:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006254:	08098713          	addi	a4,s3,128
    80006258:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    8000625a:	6705                	lui	a4,0x1
    8000625c:	99ba                	add	s3,s3,a4
    8000625e:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80006262:	4705                	li	a4,1
    80006264:	00e78c23          	sb	a4,24(a5)
    80006268:	00e78ca3          	sb	a4,25(a5)
    8000626c:	00e78d23          	sb	a4,26(a5)
    80006270:	00e78da3          	sb	a4,27(a5)
    80006274:	00e78e23          	sb	a4,28(a5)
    80006278:	00e78ea3          	sb	a4,29(a5)
    8000627c:	00e78f23          	sb	a4,30(a5)
    80006280:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80006284:	0ae7a423          	sw	a4,168(a5)
}
    80006288:	70e2                	ld	ra,56(sp)
    8000628a:	7442                	ld	s0,48(sp)
    8000628c:	74a2                	ld	s1,40(sp)
    8000628e:	7902                	ld	s2,32(sp)
    80006290:	69e2                	ld	s3,24(sp)
    80006292:	6a42                	ld	s4,16(sp)
    80006294:	6aa2                	ld	s5,8(sp)
    80006296:	6121                	addi	sp,sp,64
    80006298:	8082                	ret
    panic("could not find virtio disk");
    8000629a:	00002517          	auipc	a0,0x2
    8000629e:	6f650513          	addi	a0,a0,1782 # 80008990 <userret+0x900>
    800062a2:	ffffa097          	auipc	ra,0xffffa
    800062a6:	2a6080e7          	jalr	678(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    800062aa:	00002517          	auipc	a0,0x2
    800062ae:	70650513          	addi	a0,a0,1798 # 800089b0 <userret+0x920>
    800062b2:	ffffa097          	auipc	ra,0xffffa
    800062b6:	296080e7          	jalr	662(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    800062ba:	00002517          	auipc	a0,0x2
    800062be:	71650513          	addi	a0,a0,1814 # 800089d0 <userret+0x940>
    800062c2:	ffffa097          	auipc	ra,0xffffa
    800062c6:	286080e7          	jalr	646(ra) # 80000548 <panic>

00000000800062ca <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    800062ca:	7135                	addi	sp,sp,-160
    800062cc:	ed06                	sd	ra,152(sp)
    800062ce:	e922                	sd	s0,144(sp)
    800062d0:	e526                	sd	s1,136(sp)
    800062d2:	e14a                	sd	s2,128(sp)
    800062d4:	fcce                	sd	s3,120(sp)
    800062d6:	f8d2                	sd	s4,112(sp)
    800062d8:	f4d6                	sd	s5,104(sp)
    800062da:	f0da                	sd	s6,96(sp)
    800062dc:	ecde                	sd	s7,88(sp)
    800062de:	e8e2                	sd	s8,80(sp)
    800062e0:	e4e6                	sd	s9,72(sp)
    800062e2:	e0ea                	sd	s10,64(sp)
    800062e4:	fc6e                	sd	s11,56(sp)
    800062e6:	1100                	addi	s0,sp,160
    800062e8:	8aaa                	mv	s5,a0
    800062ea:	8c2e                	mv	s8,a1
    800062ec:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    800062ee:	45dc                	lw	a5,12(a1)
    800062f0:	0017979b          	slliw	a5,a5,0x1
    800062f4:	1782                	slli	a5,a5,0x20
    800062f6:	9381                	srli	a5,a5,0x20
    800062f8:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    800062fc:	00151493          	slli	s1,a0,0x1
    80006300:	94aa                	add	s1,s1,a0
    80006302:	04b2                	slli	s1,s1,0xc
    80006304:	6909                	lui	s2,0x2
    80006306:	0b090c93          	addi	s9,s2,176 # 20b0 <_entry-0x7fffdf50>
    8000630a:	9ca6                	add	s9,s9,s1
    8000630c:	00025997          	auipc	s3,0x25
    80006310:	cf498993          	addi	s3,s3,-780 # 8002b000 <disk>
    80006314:	9cce                	add	s9,s9,s3
    80006316:	8566                	mv	a0,s9
    80006318:	ffffa097          	auipc	ra,0xffffa
    8000631c:	7f6080e7          	jalr	2038(ra) # 80000b0e <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006320:	0961                	addi	s2,s2,24
    80006322:	94ca                	add	s1,s1,s2
    80006324:	99a6                	add	s3,s3,s1
  for(int i = 0; i < 3; i++){
    80006326:	4a01                	li	s4,0
  for(int i = 0; i < NUM; i++){
    80006328:	44a1                	li	s1,8
      disk[n].free[i] = 0;
    8000632a:	001a9793          	slli	a5,s5,0x1
    8000632e:	97d6                	add	a5,a5,s5
    80006330:	07b2                	slli	a5,a5,0xc
    80006332:	00025b97          	auipc	s7,0x25
    80006336:	cceb8b93          	addi	s7,s7,-818 # 8002b000 <disk>
    8000633a:	9bbe                	add	s7,s7,a5
    8000633c:	a8a9                	j	80006396 <virtio_disk_rw+0xcc>
    8000633e:	00fb8733          	add	a4,s7,a5
    80006342:	9742                	add	a4,a4,a6
    80006344:	00070c23          	sb	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    idx[i] = alloc_desc(n);
    80006348:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000634a:	0207c263          	bltz	a5,8000636e <virtio_disk_rw+0xa4>
  for(int i = 0; i < 3; i++){
    8000634e:	2905                	addiw	s2,s2,1
    80006350:	0611                	addi	a2,a2,4
    80006352:	1ca90463          	beq	s2,a0,8000651a <virtio_disk_rw+0x250>
    idx[i] = alloc_desc(n);
    80006356:	85b2                	mv	a1,a2
    80006358:	874e                	mv	a4,s3
  for(int i = 0; i < NUM; i++){
    8000635a:	87d2                	mv	a5,s4
    if(disk[n].free[i]){
    8000635c:	00074683          	lbu	a3,0(a4)
    80006360:	fef9                	bnez	a3,8000633e <virtio_disk_rw+0x74>
  for(int i = 0; i < NUM; i++){
    80006362:	2785                	addiw	a5,a5,1
    80006364:	0705                	addi	a4,a4,1
    80006366:	fe979be3          	bne	a5,s1,8000635c <virtio_disk_rw+0x92>
    idx[i] = alloc_desc(n);
    8000636a:	57fd                	li	a5,-1
    8000636c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000636e:	01205e63          	blez	s2,8000638a <virtio_disk_rw+0xc0>
    80006372:	8d52                	mv	s10,s4
        free_desc(n, idx[j]);
    80006374:	000b2583          	lw	a1,0(s6)
    80006378:	8556                	mv	a0,s5
    8000637a:	00000097          	auipc	ra,0x0
    8000637e:	ccc080e7          	jalr	-820(ra) # 80006046 <free_desc>
      for(int j = 0; j < i; j++)
    80006382:	2d05                	addiw	s10,s10,1
    80006384:	0b11                	addi	s6,s6,4
    80006386:	ffa917e3          	bne	s2,s10,80006374 <virtio_disk_rw+0xaa>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    8000638a:	85e6                	mv	a1,s9
    8000638c:	854e                	mv	a0,s3
    8000638e:	ffffc097          	auipc	ra,0xffffc
    80006392:	eb8080e7          	jalr	-328(ra) # 80002246 <sleep>
  for(int i = 0; i < 3; i++){
    80006396:	f8040b13          	addi	s6,s0,-128
{
    8000639a:	865a                	mv	a2,s6
  for(int i = 0; i < 3; i++){
    8000639c:	8952                	mv	s2,s4
      disk[n].free[i] = 0;
    8000639e:	6809                	lui	a6,0x2
  for(int i = 0; i < 3; i++){
    800063a0:	450d                	li	a0,3
    800063a2:	bf55                	j	80006356 <virtio_disk_rw+0x8c>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    800063a4:	001a9793          	slli	a5,s5,0x1
    800063a8:	97d6                	add	a5,a5,s5
    800063aa:	07b2                	slli	a5,a5,0xc
    800063ac:	00025717          	auipc	a4,0x25
    800063b0:	c5470713          	addi	a4,a4,-940 # 8002b000 <disk>
    800063b4:	973e                	add	a4,a4,a5
    800063b6:	6789                	lui	a5,0x2
    800063b8:	97ba                	add	a5,a5,a4
    800063ba:	639c                	ld	a5,0(a5)
    800063bc:	97b6                	add	a5,a5,a3
    800063be:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063c2:	00025517          	auipc	a0,0x25
    800063c6:	c3e50513          	addi	a0,a0,-962 # 8002b000 <disk>
    800063ca:	001a9793          	slli	a5,s5,0x1
    800063ce:	01578733          	add	a4,a5,s5
    800063d2:	0732                	slli	a4,a4,0xc
    800063d4:	972a                	add	a4,a4,a0
    800063d6:	6609                	lui	a2,0x2
    800063d8:	9732                	add	a4,a4,a2
    800063da:	6310                	ld	a2,0(a4)
    800063dc:	9636                	add	a2,a2,a3
    800063de:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800063e2:	0015e593          	ori	a1,a1,1
    800063e6:	00b61623          	sh	a1,12(a2)
  disk[n].desc[idx[1]].next = idx[2];
    800063ea:	f8842603          	lw	a2,-120(s0)
    800063ee:	630c                	ld	a1,0(a4)
    800063f0:	96ae                	add	a3,a3,a1
    800063f2:	00c69723          	sh	a2,14(a3) # 100e <_entry-0x7fffeff2>

  disk[n].info[idx[0]].status = 0;
    800063f6:	97d6                	add	a5,a5,s5
    800063f8:	07a2                	slli	a5,a5,0x8
    800063fa:	97a6                	add	a5,a5,s1
    800063fc:	20078793          	addi	a5,a5,512
    80006400:	0792                	slli	a5,a5,0x4
    80006402:	97aa                	add	a5,a5,a0
    80006404:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006408:	00461693          	slli	a3,a2,0x4
    8000640c:	00073803          	ld	a6,0(a4)
    80006410:	9836                	add	a6,a6,a3
    80006412:	20348613          	addi	a2,s1,515
    80006416:	001a9593          	slli	a1,s5,0x1
    8000641a:	95d6                	add	a1,a1,s5
    8000641c:	05a2                	slli	a1,a1,0x8
    8000641e:	962e                	add	a2,a2,a1
    80006420:	0612                	slli	a2,a2,0x4
    80006422:	962a                	add	a2,a2,a0
    80006424:	00c83023          	sd	a2,0(a6) # 2000 <_entry-0x7fffe000>
  disk[n].desc[idx[2]].len = 1;
    80006428:	630c                	ld	a1,0(a4)
    8000642a:	95b6                	add	a1,a1,a3
    8000642c:	4605                	li	a2,1
    8000642e:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006430:	630c                	ld	a1,0(a4)
    80006432:	95b6                	add	a1,a1,a3
    80006434:	4509                	li	a0,2
    80006436:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    8000643a:	630c                	ld	a1,0(a4)
    8000643c:	96ae                	add	a3,a3,a1
    8000643e:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006442:	00cc2223          	sw	a2,4(s8) # fffffffffffff004 <end+0xffffffff7ffcdfa8>
  disk[n].info[idx[0]].b = b;
    80006446:	0387b423          	sd	s8,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    8000644a:	6714                	ld	a3,8(a4)
    8000644c:	0026d783          	lhu	a5,2(a3)
    80006450:	8b9d                	andi	a5,a5,7
    80006452:	0789                	addi	a5,a5,2
    80006454:	0786                	slli	a5,a5,0x1
    80006456:	97b6                	add	a5,a5,a3
    80006458:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    8000645c:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006460:	6718                	ld	a4,8(a4)
    80006462:	00275783          	lhu	a5,2(a4)
    80006466:	2785                	addiw	a5,a5,1
    80006468:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000646c:	001a879b          	addiw	a5,s5,1
    80006470:	00c7979b          	slliw	a5,a5,0xc
    80006474:	10000737          	lui	a4,0x10000
    80006478:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    8000647c:	97ba                	add	a5,a5,a4
    8000647e:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006482:	004c2783          	lw	a5,4(s8)
    80006486:	00c79d63          	bne	a5,a2,800064a0 <virtio_disk_rw+0x1d6>
    8000648a:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    8000648c:	85e6                	mv	a1,s9
    8000648e:	8562                	mv	a0,s8
    80006490:	ffffc097          	auipc	ra,0xffffc
    80006494:	db6080e7          	jalr	-586(ra) # 80002246 <sleep>
  while(b->disk == 1) {
    80006498:	004c2783          	lw	a5,4(s8)
    8000649c:	fe9788e3          	beq	a5,s1,8000648c <virtio_disk_rw+0x1c2>
  }

  disk[n].info[idx[0]].b = 0;
    800064a0:	f8042483          	lw	s1,-128(s0)
    800064a4:	001a9793          	slli	a5,s5,0x1
    800064a8:	97d6                	add	a5,a5,s5
    800064aa:	07a2                	slli	a5,a5,0x8
    800064ac:	97a6                	add	a5,a5,s1
    800064ae:	20078793          	addi	a5,a5,512
    800064b2:	0792                	slli	a5,a5,0x4
    800064b4:	00025717          	auipc	a4,0x25
    800064b8:	b4c70713          	addi	a4,a4,-1204 # 8002b000 <disk>
    800064bc:	97ba                	add	a5,a5,a4
    800064be:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800064c2:	001a9793          	slli	a5,s5,0x1
    800064c6:	97d6                	add	a5,a5,s5
    800064c8:	07b2                	slli	a5,a5,0xc
    800064ca:	97ba                	add	a5,a5,a4
    800064cc:	6909                	lui	s2,0x2
    800064ce:	993e                	add	s2,s2,a5
    800064d0:	a019                	j	800064d6 <virtio_disk_rw+0x20c>
      i = disk[n].desc[i].next;
    800064d2:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    800064d6:	85a6                	mv	a1,s1
    800064d8:	8556                	mv	a0,s5
    800064da:	00000097          	auipc	ra,0x0
    800064de:	b6c080e7          	jalr	-1172(ra) # 80006046 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800064e2:	0492                	slli	s1,s1,0x4
    800064e4:	00093783          	ld	a5,0(s2) # 2000 <_entry-0x7fffe000>
    800064e8:	94be                	add	s1,s1,a5
    800064ea:	00c4d783          	lhu	a5,12(s1)
    800064ee:	8b85                	andi	a5,a5,1
    800064f0:	f3ed                	bnez	a5,800064d2 <virtio_disk_rw+0x208>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    800064f2:	8566                	mv	a0,s9
    800064f4:	ffffa097          	auipc	ra,0xffffa
    800064f8:	68a080e7          	jalr	1674(ra) # 80000b7e <release>
}
    800064fc:	60ea                	ld	ra,152(sp)
    800064fe:	644a                	ld	s0,144(sp)
    80006500:	64aa                	ld	s1,136(sp)
    80006502:	690a                	ld	s2,128(sp)
    80006504:	79e6                	ld	s3,120(sp)
    80006506:	7a46                	ld	s4,112(sp)
    80006508:	7aa6                	ld	s5,104(sp)
    8000650a:	7b06                	ld	s6,96(sp)
    8000650c:	6be6                	ld	s7,88(sp)
    8000650e:	6c46                	ld	s8,80(sp)
    80006510:	6ca6                	ld	s9,72(sp)
    80006512:	6d06                	ld	s10,64(sp)
    80006514:	7de2                	ld	s11,56(sp)
    80006516:	610d                	addi	sp,sp,160
    80006518:	8082                	ret
  if(write)
    8000651a:	01b037b3          	snez	a5,s11
    8000651e:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006522:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006526:	f6843783          	ld	a5,-152(s0)
    8000652a:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000652e:	f8042483          	lw	s1,-128(s0)
    80006532:	00449993          	slli	s3,s1,0x4
    80006536:	001a9793          	slli	a5,s5,0x1
    8000653a:	97d6                	add	a5,a5,s5
    8000653c:	07b2                	slli	a5,a5,0xc
    8000653e:	00025917          	auipc	s2,0x25
    80006542:	ac290913          	addi	s2,s2,-1342 # 8002b000 <disk>
    80006546:	97ca                	add	a5,a5,s2
    80006548:	6909                	lui	s2,0x2
    8000654a:	993e                	add	s2,s2,a5
    8000654c:	00093a03          	ld	s4,0(s2) # 2000 <_entry-0x7fffe000>
    80006550:	9a4e                	add	s4,s4,s3
    80006552:	f7040513          	addi	a0,s0,-144
    80006556:	ffffb097          	auipc	ra,0xffffb
    8000655a:	c5e080e7          	jalr	-930(ra) # 800011b4 <kvmpa>
    8000655e:	00aa3023          	sd	a0,0(s4)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006562:	00093783          	ld	a5,0(s2)
    80006566:	97ce                	add	a5,a5,s3
    80006568:	4741                	li	a4,16
    8000656a:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000656c:	00093783          	ld	a5,0(s2)
    80006570:	97ce                	add	a5,a5,s3
    80006572:	4705                	li	a4,1
    80006574:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    80006578:	f8442683          	lw	a3,-124(s0)
    8000657c:	00093783          	ld	a5,0(s2)
    80006580:	99be                	add	s3,s3,a5
    80006582:	00d99723          	sh	a3,14(s3)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006586:	0692                	slli	a3,a3,0x4
    80006588:	00093783          	ld	a5,0(s2)
    8000658c:	97b6                	add	a5,a5,a3
    8000658e:	060c0713          	addi	a4,s8,96
    80006592:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006594:	00093783          	ld	a5,0(s2)
    80006598:	97b6                	add	a5,a5,a3
    8000659a:	40000713          	li	a4,1024
    8000659e:	c798                	sw	a4,8(a5)
  if(write)
    800065a0:	e00d92e3          	bnez	s11,800063a4 <virtio_disk_rw+0xda>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800065a4:	001a9793          	slli	a5,s5,0x1
    800065a8:	97d6                	add	a5,a5,s5
    800065aa:	07b2                	slli	a5,a5,0xc
    800065ac:	00025717          	auipc	a4,0x25
    800065b0:	a5470713          	addi	a4,a4,-1452 # 8002b000 <disk>
    800065b4:	973e                	add	a4,a4,a5
    800065b6:	6789                	lui	a5,0x2
    800065b8:	97ba                	add	a5,a5,a4
    800065ba:	639c                	ld	a5,0(a5)
    800065bc:	97b6                	add	a5,a5,a3
    800065be:	4709                	li	a4,2
    800065c0:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    800065c4:	bbfd                	j	800063c2 <virtio_disk_rw+0xf8>

00000000800065c6 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    800065c6:	7139                	addi	sp,sp,-64
    800065c8:	fc06                	sd	ra,56(sp)
    800065ca:	f822                	sd	s0,48(sp)
    800065cc:	f426                	sd	s1,40(sp)
    800065ce:	f04a                	sd	s2,32(sp)
    800065d0:	ec4e                	sd	s3,24(sp)
    800065d2:	e852                	sd	s4,16(sp)
    800065d4:	e456                	sd	s5,8(sp)
    800065d6:	0080                	addi	s0,sp,64
    800065d8:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    800065da:	00151913          	slli	s2,a0,0x1
    800065de:	00a90a33          	add	s4,s2,a0
    800065e2:	0a32                	slli	s4,s4,0xc
    800065e4:	6989                	lui	s3,0x2
    800065e6:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    800065ea:	9a3e                	add	s4,s4,a5
    800065ec:	00025a97          	auipc	s5,0x25
    800065f0:	a14a8a93          	addi	s5,s5,-1516 # 8002b000 <disk>
    800065f4:	9a56                	add	s4,s4,s5
    800065f6:	8552                	mv	a0,s4
    800065f8:	ffffa097          	auipc	ra,0xffffa
    800065fc:	516080e7          	jalr	1302(ra) # 80000b0e <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006600:	9926                	add	s2,s2,s1
    80006602:	0932                	slli	s2,s2,0xc
    80006604:	9956                	add	s2,s2,s5
    80006606:	99ca                	add	s3,s3,s2
    80006608:	0209d783          	lhu	a5,32(s3)
    8000660c:	0109b703          	ld	a4,16(s3)
    80006610:	00275683          	lhu	a3,2(a4)
    80006614:	8ebd                	xor	a3,a3,a5
    80006616:	8a9d                	andi	a3,a3,7
    80006618:	c2a5                	beqz	a3,80006678 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    8000661a:	8956                	mv	s2,s5
    8000661c:	00149693          	slli	a3,s1,0x1
    80006620:	96a6                	add	a3,a3,s1
    80006622:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006626:	06b2                	slli	a3,a3,0xc
    80006628:	96d6                	add	a3,a3,s5
    8000662a:	6489                	lui	s1,0x2
    8000662c:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    8000662e:	078e                	slli	a5,a5,0x3
    80006630:	97ba                	add	a5,a5,a4
    80006632:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006634:	00f98733          	add	a4,s3,a5
    80006638:	20070713          	addi	a4,a4,512
    8000663c:	0712                	slli	a4,a4,0x4
    8000663e:	974a                	add	a4,a4,s2
    80006640:	03074703          	lbu	a4,48(a4)
    80006644:	eb21                	bnez	a4,80006694 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006646:	97ce                	add	a5,a5,s3
    80006648:	20078793          	addi	a5,a5,512
    8000664c:	0792                	slli	a5,a5,0x4
    8000664e:	97ca                	add	a5,a5,s2
    80006650:	7798                	ld	a4,40(a5)
    80006652:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006656:	7788                	ld	a0,40(a5)
    80006658:	ffffc097          	auipc	ra,0xffffc
    8000665c:	d6e080e7          	jalr	-658(ra) # 800023c6 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006660:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006664:	2785                	addiw	a5,a5,1
    80006666:	8b9d                	andi	a5,a5,7
    80006668:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    8000666c:	6898                	ld	a4,16(s1)
    8000666e:	00275683          	lhu	a3,2(a4)
    80006672:	8a9d                	andi	a3,a3,7
    80006674:	faf69de3          	bne	a3,a5,8000662e <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    80006678:	8552                	mv	a0,s4
    8000667a:	ffffa097          	auipc	ra,0xffffa
    8000667e:	504080e7          	jalr	1284(ra) # 80000b7e <release>
}
    80006682:	70e2                	ld	ra,56(sp)
    80006684:	7442                	ld	s0,48(sp)
    80006686:	74a2                	ld	s1,40(sp)
    80006688:	7902                	ld	s2,32(sp)
    8000668a:	69e2                	ld	s3,24(sp)
    8000668c:	6a42                	ld	s4,16(sp)
    8000668e:	6aa2                	ld	s5,8(sp)
    80006690:	6121                	addi	sp,sp,64
    80006692:	8082                	ret
      panic("virtio_disk_intr status");
    80006694:	00002517          	auipc	a0,0x2
    80006698:	35c50513          	addi	a0,a0,860 # 800089f0 <userret+0x960>
    8000669c:	ffffa097          	auipc	ra,0xffffa
    800066a0:	eac080e7          	jalr	-340(ra) # 80000548 <panic>

00000000800066a4 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    800066a4:	1141                	addi	sp,sp,-16
    800066a6:	e422                	sd	s0,8(sp)
    800066a8:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    800066aa:	41f5d79b          	sraiw	a5,a1,0x1f
    800066ae:	01d7d79b          	srliw	a5,a5,0x1d
    800066b2:	9dbd                	addw	a1,a1,a5
    800066b4:	0075f713          	andi	a4,a1,7
    800066b8:	9f1d                	subw	a4,a4,a5
    800066ba:	4785                	li	a5,1
    800066bc:	00e797bb          	sllw	a5,a5,a4
    800066c0:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    800066c4:	4035d59b          	sraiw	a1,a1,0x3
    800066c8:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    800066ca:	0005c503          	lbu	a0,0(a1)
    800066ce:	8d7d                	and	a0,a0,a5
    800066d0:	8d1d                	sub	a0,a0,a5
}
    800066d2:	00153513          	seqz	a0,a0
    800066d6:	6422                	ld	s0,8(sp)
    800066d8:	0141                	addi	sp,sp,16
    800066da:	8082                	ret

00000000800066dc <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    800066dc:	1141                	addi	sp,sp,-16
    800066de:	e422                	sd	s0,8(sp)
    800066e0:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800066e2:	41f5d79b          	sraiw	a5,a1,0x1f
    800066e6:	01d7d79b          	srliw	a5,a5,0x1d
    800066ea:	9dbd                	addw	a1,a1,a5
    800066ec:	4035d71b          	sraiw	a4,a1,0x3
    800066f0:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800066f2:	899d                	andi	a1,a1,7
    800066f4:	9d9d                	subw	a1,a1,a5
    800066f6:	4785                	li	a5,1
    800066f8:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    800066fc:	00054783          	lbu	a5,0(a0)
    80006700:	8ddd                	or	a1,a1,a5
    80006702:	00b50023          	sb	a1,0(a0)
}
    80006706:	6422                	ld	s0,8(sp)
    80006708:	0141                	addi	sp,sp,16
    8000670a:	8082                	ret

000000008000670c <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    8000670c:	1141                	addi	sp,sp,-16
    8000670e:	e422                	sd	s0,8(sp)
    80006710:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006712:	41f5d79b          	sraiw	a5,a1,0x1f
    80006716:	01d7d79b          	srliw	a5,a5,0x1d
    8000671a:	9dbd                	addw	a1,a1,a5
    8000671c:	4035d71b          	sraiw	a4,a1,0x3
    80006720:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006722:	899d                	andi	a1,a1,7
    80006724:	9d9d                	subw	a1,a1,a5
    80006726:	4785                	li	a5,1
    80006728:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    8000672c:	fff5c593          	not	a1,a1
    80006730:	00054783          	lbu	a5,0(a0)
    80006734:	8dfd                	and	a1,a1,a5
    80006736:	00b50023          	sb	a1,0(a0)
}
    8000673a:	6422                	ld	s0,8(sp)
    8000673c:	0141                	addi	sp,sp,16
    8000673e:	8082                	ret

0000000080006740 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006740:	715d                	addi	sp,sp,-80
    80006742:	e486                	sd	ra,72(sp)
    80006744:	e0a2                	sd	s0,64(sp)
    80006746:	fc26                	sd	s1,56(sp)
    80006748:	f84a                	sd	s2,48(sp)
    8000674a:	f44e                	sd	s3,40(sp)
    8000674c:	f052                	sd	s4,32(sp)
    8000674e:	ec56                	sd	s5,24(sp)
    80006750:	e85a                	sd	s6,16(sp)
    80006752:	e45e                	sd	s7,8(sp)
    80006754:	0880                	addi	s0,sp,80
    80006756:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006758:	08b05b63          	blez	a1,800067ee <bd_print_vector+0xae>
    8000675c:	89aa                	mv	s3,a0
    8000675e:	4481                	li	s1,0
  lb = 0;
    80006760:	4a81                	li	s5,0
  last = 1;
    80006762:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006764:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006766:	00002b97          	auipc	s7,0x2
    8000676a:	2a2b8b93          	addi	s7,s7,674 # 80008a08 <userret+0x978>
    8000676e:	a821                	j	80006786 <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80006770:	85a6                	mv	a1,s1
    80006772:	854e                	mv	a0,s3
    80006774:	00000097          	auipc	ra,0x0
    80006778:	f30080e7          	jalr	-208(ra) # 800066a4 <bit_isset>
    8000677c:	892a                	mv	s2,a0
    8000677e:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006780:	2485                	addiw	s1,s1,1
    80006782:	029a0463          	beq	s4,s1,800067aa <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006786:	85a6                	mv	a1,s1
    80006788:	854e                	mv	a0,s3
    8000678a:	00000097          	auipc	ra,0x0
    8000678e:	f1a080e7          	jalr	-230(ra) # 800066a4 <bit_isset>
    80006792:	ff2507e3          	beq	a0,s2,80006780 <bd_print_vector+0x40>
    if(last == 1)
    80006796:	fd691de3          	bne	s2,s6,80006770 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    8000679a:	8626                	mv	a2,s1
    8000679c:	85d6                	mv	a1,s5
    8000679e:	855e                	mv	a0,s7
    800067a0:	ffffa097          	auipc	ra,0xffffa
    800067a4:	e02080e7          	jalr	-510(ra) # 800005a2 <printf>
    800067a8:	b7e1                	j	80006770 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    800067aa:	000a8563          	beqz	s5,800067b4 <bd_print_vector+0x74>
    800067ae:	4785                	li	a5,1
    800067b0:	00f91c63          	bne	s2,a5,800067c8 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    800067b4:	8652                	mv	a2,s4
    800067b6:	85d6                	mv	a1,s5
    800067b8:	00002517          	auipc	a0,0x2
    800067bc:	25050513          	addi	a0,a0,592 # 80008a08 <userret+0x978>
    800067c0:	ffffa097          	auipc	ra,0xffffa
    800067c4:	de2080e7          	jalr	-542(ra) # 800005a2 <printf>
  }
  printf("\n");
    800067c8:	00002517          	auipc	a0,0x2
    800067cc:	b4050513          	addi	a0,a0,-1216 # 80008308 <userret+0x278>
    800067d0:	ffffa097          	auipc	ra,0xffffa
    800067d4:	dd2080e7          	jalr	-558(ra) # 800005a2 <printf>
}
    800067d8:	60a6                	ld	ra,72(sp)
    800067da:	6406                	ld	s0,64(sp)
    800067dc:	74e2                	ld	s1,56(sp)
    800067de:	7942                	ld	s2,48(sp)
    800067e0:	79a2                	ld	s3,40(sp)
    800067e2:	7a02                	ld	s4,32(sp)
    800067e4:	6ae2                	ld	s5,24(sp)
    800067e6:	6b42                	ld	s6,16(sp)
    800067e8:	6ba2                	ld	s7,8(sp)
    800067ea:	6161                	addi	sp,sp,80
    800067ec:	8082                	ret
  lb = 0;
    800067ee:	4a81                	li	s5,0
    800067f0:	b7d1                	j	800067b4 <bd_print_vector+0x74>

00000000800067f2 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    800067f2:	0002b697          	auipc	a3,0x2b
    800067f6:	8666a683          	lw	a3,-1946(a3) # 80031058 <nsizes>
    800067fa:	10d05063          	blez	a3,800068fa <bd_print+0x108>
bd_print() {
    800067fe:	711d                	addi	sp,sp,-96
    80006800:	ec86                	sd	ra,88(sp)
    80006802:	e8a2                	sd	s0,80(sp)
    80006804:	e4a6                	sd	s1,72(sp)
    80006806:	e0ca                	sd	s2,64(sp)
    80006808:	fc4e                	sd	s3,56(sp)
    8000680a:	f852                	sd	s4,48(sp)
    8000680c:	f456                	sd	s5,40(sp)
    8000680e:	f05a                	sd	s6,32(sp)
    80006810:	ec5e                	sd	s7,24(sp)
    80006812:	e862                	sd	s8,16(sp)
    80006814:	e466                	sd	s9,8(sp)
    80006816:	e06a                	sd	s10,0(sp)
    80006818:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    8000681a:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    8000681c:	4a85                	li	s5,1
    8000681e:	4c41                	li	s8,16
    80006820:	00002b97          	auipc	s7,0x2
    80006824:	1f8b8b93          	addi	s7,s7,504 # 80008a18 <userret+0x988>
    lst_print(&bd_sizes[k].free);
    80006828:	0002ba17          	auipc	s4,0x2b
    8000682c:	828a0a13          	addi	s4,s4,-2008 # 80031050 <bd_sizes>
    printf("  alloc:");
    80006830:	00002b17          	auipc	s6,0x2
    80006834:	210b0b13          	addi	s6,s6,528 # 80008a40 <userret+0x9b0>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006838:	0002b997          	auipc	s3,0x2b
    8000683c:	82098993          	addi	s3,s3,-2016 # 80031058 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006840:	00002c97          	auipc	s9,0x2
    80006844:	210c8c93          	addi	s9,s9,528 # 80008a50 <userret+0x9c0>
    80006848:	a801                	j	80006858 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    8000684a:	0009a683          	lw	a3,0(s3)
    8000684e:	0485                	addi	s1,s1,1
    80006850:	0004879b          	sext.w	a5,s1
    80006854:	08d7d563          	bge	a5,a3,800068de <bd_print+0xec>
    80006858:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    8000685c:	36fd                	addiw	a3,a3,-1
    8000685e:	9e85                	subw	a3,a3,s1
    80006860:	00da96bb          	sllw	a3,s5,a3
    80006864:	009c1633          	sll	a2,s8,s1
    80006868:	85ca                	mv	a1,s2
    8000686a:	855e                	mv	a0,s7
    8000686c:	ffffa097          	auipc	ra,0xffffa
    80006870:	d36080e7          	jalr	-714(ra) # 800005a2 <printf>
    lst_print(&bd_sizes[k].free);
    80006874:	00549d13          	slli	s10,s1,0x5
    80006878:	000a3503          	ld	a0,0(s4)
    8000687c:	956a                	add	a0,a0,s10
    8000687e:	00001097          	auipc	ra,0x1
    80006882:	a56080e7          	jalr	-1450(ra) # 800072d4 <lst_print>
    printf("  alloc:");
    80006886:	855a                	mv	a0,s6
    80006888:	ffffa097          	auipc	ra,0xffffa
    8000688c:	d1a080e7          	jalr	-742(ra) # 800005a2 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006890:	0009a583          	lw	a1,0(s3)
    80006894:	35fd                	addiw	a1,a1,-1
    80006896:	412585bb          	subw	a1,a1,s2
    8000689a:	000a3783          	ld	a5,0(s4)
    8000689e:	97ea                	add	a5,a5,s10
    800068a0:	00ba95bb          	sllw	a1,s5,a1
    800068a4:	6b88                	ld	a0,16(a5)
    800068a6:	00000097          	auipc	ra,0x0
    800068aa:	e9a080e7          	jalr	-358(ra) # 80006740 <bd_print_vector>
    if(k > 0) {
    800068ae:	f9205ee3          	blez	s2,8000684a <bd_print+0x58>
      printf("  split:");
    800068b2:	8566                	mv	a0,s9
    800068b4:	ffffa097          	auipc	ra,0xffffa
    800068b8:	cee080e7          	jalr	-786(ra) # 800005a2 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    800068bc:	0009a583          	lw	a1,0(s3)
    800068c0:	35fd                	addiw	a1,a1,-1
    800068c2:	412585bb          	subw	a1,a1,s2
    800068c6:	000a3783          	ld	a5,0(s4)
    800068ca:	9d3e                	add	s10,s10,a5
    800068cc:	00ba95bb          	sllw	a1,s5,a1
    800068d0:	018d3503          	ld	a0,24(s10)
    800068d4:	00000097          	auipc	ra,0x0
    800068d8:	e6c080e7          	jalr	-404(ra) # 80006740 <bd_print_vector>
    800068dc:	b7bd                	j	8000684a <bd_print+0x58>
    }
  }
}
    800068de:	60e6                	ld	ra,88(sp)
    800068e0:	6446                	ld	s0,80(sp)
    800068e2:	64a6                	ld	s1,72(sp)
    800068e4:	6906                	ld	s2,64(sp)
    800068e6:	79e2                	ld	s3,56(sp)
    800068e8:	7a42                	ld	s4,48(sp)
    800068ea:	7aa2                	ld	s5,40(sp)
    800068ec:	7b02                	ld	s6,32(sp)
    800068ee:	6be2                	ld	s7,24(sp)
    800068f0:	6c42                	ld	s8,16(sp)
    800068f2:	6ca2                	ld	s9,8(sp)
    800068f4:	6d02                	ld	s10,0(sp)
    800068f6:	6125                	addi	sp,sp,96
    800068f8:	8082                	ret
    800068fa:	8082                	ret

00000000800068fc <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800068fc:	1141                	addi	sp,sp,-16
    800068fe:	e422                	sd	s0,8(sp)
    80006900:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006902:	47c1                	li	a5,16
    80006904:	00a7fb63          	bgeu	a5,a0,8000691a <firstk+0x1e>
    80006908:	872a                	mv	a4,a0
  int k = 0;
    8000690a:	4501                	li	a0,0
    k++;
    8000690c:	2505                	addiw	a0,a0,1
    size *= 2;
    8000690e:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006910:	fee7eee3          	bltu	a5,a4,8000690c <firstk+0x10>
  }
  return k;
}
    80006914:	6422                	ld	s0,8(sp)
    80006916:	0141                	addi	sp,sp,16
    80006918:	8082                	ret
  int k = 0;
    8000691a:	4501                	li	a0,0
    8000691c:	bfe5                	j	80006914 <firstk+0x18>

000000008000691e <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    8000691e:	1141                	addi	sp,sp,-16
    80006920:	e422                	sd	s0,8(sp)
    80006922:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006924:	0002a797          	auipc	a5,0x2a
    80006928:	7247b783          	ld	a5,1828(a5) # 80031048 <bd_base>
    8000692c:	9d9d                	subw	a1,a1,a5
    8000692e:	47c1                	li	a5,16
    80006930:	00a797b3          	sll	a5,a5,a0
    80006934:	02f5c5b3          	div	a1,a1,a5
}
    80006938:	0005851b          	sext.w	a0,a1
    8000693c:	6422                	ld	s0,8(sp)
    8000693e:	0141                	addi	sp,sp,16
    80006940:	8082                	ret

0000000080006942 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006942:	1141                	addi	sp,sp,-16
    80006944:	e422                	sd	s0,8(sp)
    80006946:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006948:	47c1                	li	a5,16
    8000694a:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    8000694e:	02b787bb          	mulw	a5,a5,a1
}
    80006952:	0002a517          	auipc	a0,0x2a
    80006956:	6f653503          	ld	a0,1782(a0) # 80031048 <bd_base>
    8000695a:	953e                	add	a0,a0,a5
    8000695c:	6422                	ld	s0,8(sp)
    8000695e:	0141                	addi	sp,sp,16
    80006960:	8082                	ret

0000000080006962 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006962:	7159                	addi	sp,sp,-112
    80006964:	f486                	sd	ra,104(sp)
    80006966:	f0a2                	sd	s0,96(sp)
    80006968:	eca6                	sd	s1,88(sp)
    8000696a:	e8ca                	sd	s2,80(sp)
    8000696c:	e4ce                	sd	s3,72(sp)
    8000696e:	e0d2                	sd	s4,64(sp)
    80006970:	fc56                	sd	s5,56(sp)
    80006972:	f85a                	sd	s6,48(sp)
    80006974:	f45e                	sd	s7,40(sp)
    80006976:	f062                	sd	s8,32(sp)
    80006978:	ec66                	sd	s9,24(sp)
    8000697a:	e86a                	sd	s10,16(sp)
    8000697c:	e46e                	sd	s11,8(sp)
    8000697e:	1880                	addi	s0,sp,112
    80006980:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006982:	0002a517          	auipc	a0,0x2a
    80006986:	67e50513          	addi	a0,a0,1662 # 80031000 <lock>
    8000698a:	ffffa097          	auipc	ra,0xffffa
    8000698e:	184080e7          	jalr	388(ra) # 80000b0e <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006992:	8526                	mv	a0,s1
    80006994:	00000097          	auipc	ra,0x0
    80006998:	f68080e7          	jalr	-152(ra) # 800068fc <firstk>
  for (k = fk; k < nsizes; k++) {
    8000699c:	0002a797          	auipc	a5,0x2a
    800069a0:	6bc7a783          	lw	a5,1724(a5) # 80031058 <nsizes>
    800069a4:	02f55d63          	bge	a0,a5,800069de <bd_malloc+0x7c>
    800069a8:	8c2a                	mv	s8,a0
    800069aa:	00551913          	slli	s2,a0,0x5
    800069ae:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    800069b0:	0002a997          	auipc	s3,0x2a
    800069b4:	6a098993          	addi	s3,s3,1696 # 80031050 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    800069b8:	0002aa17          	auipc	s4,0x2a
    800069bc:	6a0a0a13          	addi	s4,s4,1696 # 80031058 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    800069c0:	0009b503          	ld	a0,0(s3)
    800069c4:	954a                	add	a0,a0,s2
    800069c6:	00001097          	auipc	ra,0x1
    800069ca:	894080e7          	jalr	-1900(ra) # 8000725a <lst_empty>
    800069ce:	c115                	beqz	a0,800069f2 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    800069d0:	2485                	addiw	s1,s1,1
    800069d2:	02090913          	addi	s2,s2,32
    800069d6:	000a2783          	lw	a5,0(s4)
    800069da:	fef4c3e3          	blt	s1,a5,800069c0 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    800069de:	0002a517          	auipc	a0,0x2a
    800069e2:	62250513          	addi	a0,a0,1570 # 80031000 <lock>
    800069e6:	ffffa097          	auipc	ra,0xffffa
    800069ea:	198080e7          	jalr	408(ra) # 80000b7e <release>
    return 0;
    800069ee:	4b01                	li	s6,0
    800069f0:	a0e1                	j	80006ab8 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    800069f2:	0002a797          	auipc	a5,0x2a
    800069f6:	6667a783          	lw	a5,1638(a5) # 80031058 <nsizes>
    800069fa:	fef4d2e3          	bge	s1,a5,800069de <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    800069fe:	00549993          	slli	s3,s1,0x5
    80006a02:	0002a917          	auipc	s2,0x2a
    80006a06:	64e90913          	addi	s2,s2,1614 # 80031050 <bd_sizes>
    80006a0a:	00093503          	ld	a0,0(s2)
    80006a0e:	954e                	add	a0,a0,s3
    80006a10:	00001097          	auipc	ra,0x1
    80006a14:	876080e7          	jalr	-1930(ra) # 80007286 <lst_pop>
    80006a18:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006a1a:	0002a597          	auipc	a1,0x2a
    80006a1e:	62e5b583          	ld	a1,1582(a1) # 80031048 <bd_base>
    80006a22:	40b505bb          	subw	a1,a0,a1
    80006a26:	47c1                	li	a5,16
    80006a28:	009797b3          	sll	a5,a5,s1
    80006a2c:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006a30:	00093783          	ld	a5,0(s2)
    80006a34:	97ce                	add	a5,a5,s3
    80006a36:	2581                	sext.w	a1,a1
    80006a38:	6b88                	ld	a0,16(a5)
    80006a3a:	00000097          	auipc	ra,0x0
    80006a3e:	ca2080e7          	jalr	-862(ra) # 800066dc <bit_set>
  for(; k > fk; k--) {
    80006a42:	069c5363          	bge	s8,s1,80006aa8 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006a46:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006a48:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006a4a:	0002ad17          	auipc	s10,0x2a
    80006a4e:	5fed0d13          	addi	s10,s10,1534 # 80031048 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006a52:	85a6                	mv	a1,s1
    80006a54:	34fd                	addiw	s1,s1,-1
    80006a56:	009b9ab3          	sll	s5,s7,s1
    80006a5a:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006a5e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
  int n = p - (char *) bd_base;
    80006a62:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006a66:	412b093b          	subw	s2,s6,s2
    80006a6a:	00bb95b3          	sll	a1,s7,a1
    80006a6e:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006a72:	013a07b3          	add	a5,s4,s3
    80006a76:	2581                	sext.w	a1,a1
    80006a78:	6f88                	ld	a0,24(a5)
    80006a7a:	00000097          	auipc	ra,0x0
    80006a7e:	c62080e7          	jalr	-926(ra) # 800066dc <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006a82:	1981                	addi	s3,s3,-32
    80006a84:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006a86:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006a8a:	2581                	sext.w	a1,a1
    80006a8c:	010a3503          	ld	a0,16(s4)
    80006a90:	00000097          	auipc	ra,0x0
    80006a94:	c4c080e7          	jalr	-948(ra) # 800066dc <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006a98:	85e6                	mv	a1,s9
    80006a9a:	8552                	mv	a0,s4
    80006a9c:	00001097          	auipc	ra,0x1
    80006aa0:	820080e7          	jalr	-2016(ra) # 800072bc <lst_push>
  for(; k > fk; k--) {
    80006aa4:	fb8497e3          	bne	s1,s8,80006a52 <bd_malloc+0xf0>
  }
  release(&lock);
    80006aa8:	0002a517          	auipc	a0,0x2a
    80006aac:	55850513          	addi	a0,a0,1368 # 80031000 <lock>
    80006ab0:	ffffa097          	auipc	ra,0xffffa
    80006ab4:	0ce080e7          	jalr	206(ra) # 80000b7e <release>

  return p;
}
    80006ab8:	855a                	mv	a0,s6
    80006aba:	70a6                	ld	ra,104(sp)
    80006abc:	7406                	ld	s0,96(sp)
    80006abe:	64e6                	ld	s1,88(sp)
    80006ac0:	6946                	ld	s2,80(sp)
    80006ac2:	69a6                	ld	s3,72(sp)
    80006ac4:	6a06                	ld	s4,64(sp)
    80006ac6:	7ae2                	ld	s5,56(sp)
    80006ac8:	7b42                	ld	s6,48(sp)
    80006aca:	7ba2                	ld	s7,40(sp)
    80006acc:	7c02                	ld	s8,32(sp)
    80006ace:	6ce2                	ld	s9,24(sp)
    80006ad0:	6d42                	ld	s10,16(sp)
    80006ad2:	6da2                	ld	s11,8(sp)
    80006ad4:	6165                	addi	sp,sp,112
    80006ad6:	8082                	ret

0000000080006ad8 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006ad8:	7139                	addi	sp,sp,-64
    80006ada:	fc06                	sd	ra,56(sp)
    80006adc:	f822                	sd	s0,48(sp)
    80006ade:	f426                	sd	s1,40(sp)
    80006ae0:	f04a                	sd	s2,32(sp)
    80006ae2:	ec4e                	sd	s3,24(sp)
    80006ae4:	e852                	sd	s4,16(sp)
    80006ae6:	e456                	sd	s5,8(sp)
    80006ae8:	e05a                	sd	s6,0(sp)
    80006aea:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006aec:	0002aa97          	auipc	s5,0x2a
    80006af0:	56caaa83          	lw	s5,1388(s5) # 80031058 <nsizes>
  return n / BLK_SIZE(k);
    80006af4:	0002aa17          	auipc	s4,0x2a
    80006af8:	554a3a03          	ld	s4,1364(s4) # 80031048 <bd_base>
    80006afc:	41450a3b          	subw	s4,a0,s4
    80006b00:	0002a497          	auipc	s1,0x2a
    80006b04:	5504b483          	ld	s1,1360(s1) # 80031050 <bd_sizes>
    80006b08:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006b0c:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006b0e:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006b10:	03595363          	bge	s2,s5,80006b36 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006b14:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006b18:	013b15b3          	sll	a1,s6,s3
    80006b1c:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006b20:	2581                	sext.w	a1,a1
    80006b22:	6088                	ld	a0,0(s1)
    80006b24:	00000097          	auipc	ra,0x0
    80006b28:	b80080e7          	jalr	-1152(ra) # 800066a4 <bit_isset>
    80006b2c:	02048493          	addi	s1,s1,32
    80006b30:	e501                	bnez	a0,80006b38 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006b32:	894e                	mv	s2,s3
    80006b34:	bff1                	j	80006b10 <size+0x38>
      return k;
    }
  }
  return 0;
    80006b36:	4901                	li	s2,0
}
    80006b38:	854a                	mv	a0,s2
    80006b3a:	70e2                	ld	ra,56(sp)
    80006b3c:	7442                	ld	s0,48(sp)
    80006b3e:	74a2                	ld	s1,40(sp)
    80006b40:	7902                	ld	s2,32(sp)
    80006b42:	69e2                	ld	s3,24(sp)
    80006b44:	6a42                	ld	s4,16(sp)
    80006b46:	6aa2                	ld	s5,8(sp)
    80006b48:	6b02                	ld	s6,0(sp)
    80006b4a:	6121                	addi	sp,sp,64
    80006b4c:	8082                	ret

0000000080006b4e <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006b4e:	7159                	addi	sp,sp,-112
    80006b50:	f486                	sd	ra,104(sp)
    80006b52:	f0a2                	sd	s0,96(sp)
    80006b54:	eca6                	sd	s1,88(sp)
    80006b56:	e8ca                	sd	s2,80(sp)
    80006b58:	e4ce                	sd	s3,72(sp)
    80006b5a:	e0d2                	sd	s4,64(sp)
    80006b5c:	fc56                	sd	s5,56(sp)
    80006b5e:	f85a                	sd	s6,48(sp)
    80006b60:	f45e                	sd	s7,40(sp)
    80006b62:	f062                	sd	s8,32(sp)
    80006b64:	ec66                	sd	s9,24(sp)
    80006b66:	e86a                	sd	s10,16(sp)
    80006b68:	e46e                	sd	s11,8(sp)
    80006b6a:	1880                	addi	s0,sp,112
    80006b6c:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006b6e:	0002a517          	auipc	a0,0x2a
    80006b72:	49250513          	addi	a0,a0,1170 # 80031000 <lock>
    80006b76:	ffffa097          	auipc	ra,0xffffa
    80006b7a:	f98080e7          	jalr	-104(ra) # 80000b0e <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80006b7e:	8556                	mv	a0,s5
    80006b80:	00000097          	auipc	ra,0x0
    80006b84:	f58080e7          	jalr	-168(ra) # 80006ad8 <size>
    80006b88:	84aa                	mv	s1,a0
    80006b8a:	0002a797          	auipc	a5,0x2a
    80006b8e:	4ce7a783          	lw	a5,1230(a5) # 80031058 <nsizes>
    80006b92:	37fd                	addiw	a5,a5,-1
    80006b94:	0cf55063          	bge	a0,a5,80006c54 <bd_free+0x106>
    80006b98:	00150a13          	addi	s4,a0,1
    80006b9c:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    80006b9e:	0002ac17          	auipc	s8,0x2a
    80006ba2:	4aac0c13          	addi	s8,s8,1194 # 80031048 <bd_base>
  return n / BLK_SIZE(k);
    80006ba6:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006ba8:	0002ab17          	auipc	s6,0x2a
    80006bac:	4a8b0b13          	addi	s6,s6,1192 # 80031050 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006bb0:	0002ac97          	auipc	s9,0x2a
    80006bb4:	4a8c8c93          	addi	s9,s9,1192 # 80031058 <nsizes>
    80006bb8:	a82d                	j	80006bf2 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006bba:	fff58d9b          	addiw	s11,a1,-1
    80006bbe:	a881                	j	80006c0e <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006bc0:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80006bc2:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80006bc6:	40ba85bb          	subw	a1,s5,a1
    80006bca:	009b97b3          	sll	a5,s7,s1
    80006bce:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006bd2:	000b3783          	ld	a5,0(s6)
    80006bd6:	97d2                	add	a5,a5,s4
    80006bd8:	2581                	sext.w	a1,a1
    80006bda:	6f88                	ld	a0,24(a5)
    80006bdc:	00000097          	auipc	ra,0x0
    80006be0:	b30080e7          	jalr	-1232(ra) # 8000670c <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006be4:	020a0a13          	addi	s4,s4,32
    80006be8:	000ca783          	lw	a5,0(s9)
    80006bec:	37fd                	addiw	a5,a5,-1
    80006bee:	06f4d363          	bge	s1,a5,80006c54 <bd_free+0x106>
  int n = p - (char *) bd_base;
    80006bf2:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006bf6:	009b99b3          	sll	s3,s7,s1
    80006bfa:	412a87bb          	subw	a5,s5,s2
    80006bfe:	0337c7b3          	div	a5,a5,s3
    80006c02:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006c06:	8b85                	andi	a5,a5,1
    80006c08:	fbcd                	bnez	a5,80006bba <bd_free+0x6c>
    80006c0a:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006c0e:	fe0a0d13          	addi	s10,s4,-32
    80006c12:	000b3783          	ld	a5,0(s6)
    80006c16:	9d3e                	add	s10,s10,a5
    80006c18:	010d3503          	ld	a0,16(s10)
    80006c1c:	00000097          	auipc	ra,0x0
    80006c20:	af0080e7          	jalr	-1296(ra) # 8000670c <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006c24:	85ee                	mv	a1,s11
    80006c26:	010d3503          	ld	a0,16(s10)
    80006c2a:	00000097          	auipc	ra,0x0
    80006c2e:	a7a080e7          	jalr	-1414(ra) # 800066a4 <bit_isset>
    80006c32:	e10d                	bnez	a0,80006c54 <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    80006c34:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006c38:	03b989bb          	mulw	s3,s3,s11
    80006c3c:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006c3e:	854a                	mv	a0,s2
    80006c40:	00000097          	auipc	ra,0x0
    80006c44:	630080e7          	jalr	1584(ra) # 80007270 <lst_remove>
    if(buddy % 2 == 0) {
    80006c48:	001d7d13          	andi	s10,s10,1
    80006c4c:	f60d1ae3          	bnez	s10,80006bc0 <bd_free+0x72>
      p = q;
    80006c50:	8aca                	mv	s5,s2
    80006c52:	b7bd                	j	80006bc0 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    80006c54:	0496                	slli	s1,s1,0x5
    80006c56:	85d6                	mv	a1,s5
    80006c58:	0002a517          	auipc	a0,0x2a
    80006c5c:	3f853503          	ld	a0,1016(a0) # 80031050 <bd_sizes>
    80006c60:	9526                	add	a0,a0,s1
    80006c62:	00000097          	auipc	ra,0x0
    80006c66:	65a080e7          	jalr	1626(ra) # 800072bc <lst_push>
  release(&lock);
    80006c6a:	0002a517          	auipc	a0,0x2a
    80006c6e:	39650513          	addi	a0,a0,918 # 80031000 <lock>
    80006c72:	ffffa097          	auipc	ra,0xffffa
    80006c76:	f0c080e7          	jalr	-244(ra) # 80000b7e <release>
}
    80006c7a:	70a6                	ld	ra,104(sp)
    80006c7c:	7406                	ld	s0,96(sp)
    80006c7e:	64e6                	ld	s1,88(sp)
    80006c80:	6946                	ld	s2,80(sp)
    80006c82:	69a6                	ld	s3,72(sp)
    80006c84:	6a06                	ld	s4,64(sp)
    80006c86:	7ae2                	ld	s5,56(sp)
    80006c88:	7b42                	ld	s6,48(sp)
    80006c8a:	7ba2                	ld	s7,40(sp)
    80006c8c:	7c02                	ld	s8,32(sp)
    80006c8e:	6ce2                	ld	s9,24(sp)
    80006c90:	6d42                	ld	s10,16(sp)
    80006c92:	6da2                	ld	s11,8(sp)
    80006c94:	6165                	addi	sp,sp,112
    80006c96:	8082                	ret

0000000080006c98 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006c98:	1141                	addi	sp,sp,-16
    80006c9a:	e422                	sd	s0,8(sp)
    80006c9c:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006c9e:	0002a797          	auipc	a5,0x2a
    80006ca2:	3aa7b783          	ld	a5,938(a5) # 80031048 <bd_base>
    80006ca6:	8d9d                	sub	a1,a1,a5
    80006ca8:	47c1                	li	a5,16
    80006caa:	00a797b3          	sll	a5,a5,a0
    80006cae:	02f5c533          	div	a0,a1,a5
    80006cb2:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006cb4:	02f5e5b3          	rem	a1,a1,a5
    80006cb8:	c191                	beqz	a1,80006cbc <blk_index_next+0x24>
      n++;
    80006cba:	2505                	addiw	a0,a0,1
  return n ;
}
    80006cbc:	6422                	ld	s0,8(sp)
    80006cbe:	0141                	addi	sp,sp,16
    80006cc0:	8082                	ret

0000000080006cc2 <log2>:

int
log2(uint64 n) {
    80006cc2:	1141                	addi	sp,sp,-16
    80006cc4:	e422                	sd	s0,8(sp)
    80006cc6:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006cc8:	4705                	li	a4,1
    80006cca:	00a77b63          	bgeu	a4,a0,80006ce0 <log2+0x1e>
    80006cce:	87aa                	mv	a5,a0
  int k = 0;
    80006cd0:	4501                	li	a0,0
    k++;
    80006cd2:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006cd4:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006cd6:	fef76ee3          	bltu	a4,a5,80006cd2 <log2+0x10>
  }
  return k;
}
    80006cda:	6422                	ld	s0,8(sp)
    80006cdc:	0141                	addi	sp,sp,16
    80006cde:	8082                	ret
  int k = 0;
    80006ce0:	4501                	li	a0,0
    80006ce2:	bfe5                	j	80006cda <log2+0x18>

0000000080006ce4 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006ce4:	711d                	addi	sp,sp,-96
    80006ce6:	ec86                	sd	ra,88(sp)
    80006ce8:	e8a2                	sd	s0,80(sp)
    80006cea:	e4a6                	sd	s1,72(sp)
    80006cec:	e0ca                	sd	s2,64(sp)
    80006cee:	fc4e                	sd	s3,56(sp)
    80006cf0:	f852                	sd	s4,48(sp)
    80006cf2:	f456                	sd	s5,40(sp)
    80006cf4:	f05a                	sd	s6,32(sp)
    80006cf6:	ec5e                	sd	s7,24(sp)
    80006cf8:	e862                	sd	s8,16(sp)
    80006cfa:	e466                	sd	s9,8(sp)
    80006cfc:	e06a                	sd	s10,0(sp)
    80006cfe:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006d00:	00b56933          	or	s2,a0,a1
    80006d04:	00f97913          	andi	s2,s2,15
    80006d08:	04091263          	bnez	s2,80006d4c <bd_mark+0x68>
    80006d0c:	8b2a                	mv	s6,a0
    80006d0e:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006d10:	0002ac17          	auipc	s8,0x2a
    80006d14:	348c2c03          	lw	s8,840(s8) # 80031058 <nsizes>
    80006d18:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006d1a:	0002ad17          	auipc	s10,0x2a
    80006d1e:	32ed0d13          	addi	s10,s10,814 # 80031048 <bd_base>
  return n / BLK_SIZE(k);
    80006d22:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006d24:	0002aa97          	auipc	s5,0x2a
    80006d28:	32ca8a93          	addi	s5,s5,812 # 80031050 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006d2c:	07804563          	bgtz	s8,80006d96 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006d30:	60e6                	ld	ra,88(sp)
    80006d32:	6446                	ld	s0,80(sp)
    80006d34:	64a6                	ld	s1,72(sp)
    80006d36:	6906                	ld	s2,64(sp)
    80006d38:	79e2                	ld	s3,56(sp)
    80006d3a:	7a42                	ld	s4,48(sp)
    80006d3c:	7aa2                	ld	s5,40(sp)
    80006d3e:	7b02                	ld	s6,32(sp)
    80006d40:	6be2                	ld	s7,24(sp)
    80006d42:	6c42                	ld	s8,16(sp)
    80006d44:	6ca2                	ld	s9,8(sp)
    80006d46:	6d02                	ld	s10,0(sp)
    80006d48:	6125                	addi	sp,sp,96
    80006d4a:	8082                	ret
    panic("bd_mark");
    80006d4c:	00002517          	auipc	a0,0x2
    80006d50:	d1450513          	addi	a0,a0,-748 # 80008a60 <userret+0x9d0>
    80006d54:	ffff9097          	auipc	ra,0xffff9
    80006d58:	7f4080e7          	jalr	2036(ra) # 80000548 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006d5c:	000ab783          	ld	a5,0(s5)
    80006d60:	97ca                	add	a5,a5,s2
    80006d62:	85a6                	mv	a1,s1
    80006d64:	6b88                	ld	a0,16(a5)
    80006d66:	00000097          	auipc	ra,0x0
    80006d6a:	976080e7          	jalr	-1674(ra) # 800066dc <bit_set>
    for(; bi < bj; bi++) {
    80006d6e:	2485                	addiw	s1,s1,1
    80006d70:	009a0e63          	beq	s4,s1,80006d8c <bd_mark+0xa8>
      if(k > 0) {
    80006d74:	ff3054e3          	blez	s3,80006d5c <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006d78:	000ab783          	ld	a5,0(s5)
    80006d7c:	97ca                	add	a5,a5,s2
    80006d7e:	85a6                	mv	a1,s1
    80006d80:	6f88                	ld	a0,24(a5)
    80006d82:	00000097          	auipc	ra,0x0
    80006d86:	95a080e7          	jalr	-1702(ra) # 800066dc <bit_set>
    80006d8a:	bfc9                	j	80006d5c <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006d8c:	2985                	addiw	s3,s3,1
    80006d8e:	02090913          	addi	s2,s2,32
    80006d92:	f9898fe3          	beq	s3,s8,80006d30 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006d96:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006d9a:	409b04bb          	subw	s1,s6,s1
    80006d9e:	013c97b3          	sll	a5,s9,s3
    80006da2:	02f4c4b3          	div	s1,s1,a5
    80006da6:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006da8:	85de                	mv	a1,s7
    80006daa:	854e                	mv	a0,s3
    80006dac:	00000097          	auipc	ra,0x0
    80006db0:	eec080e7          	jalr	-276(ra) # 80006c98 <blk_index_next>
    80006db4:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006db6:	faa4cfe3          	blt	s1,a0,80006d74 <bd_mark+0x90>
    80006dba:	bfc9                	j	80006d8c <bd_mark+0xa8>

0000000080006dbc <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006dbc:	7139                	addi	sp,sp,-64
    80006dbe:	fc06                	sd	ra,56(sp)
    80006dc0:	f822                	sd	s0,48(sp)
    80006dc2:	f426                	sd	s1,40(sp)
    80006dc4:	f04a                	sd	s2,32(sp)
    80006dc6:	ec4e                	sd	s3,24(sp)
    80006dc8:	e852                	sd	s4,16(sp)
    80006dca:	e456                	sd	s5,8(sp)
    80006dcc:	e05a                	sd	s6,0(sp)
    80006dce:	0080                	addi	s0,sp,64
    80006dd0:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006dd2:	00058a9b          	sext.w	s5,a1
    80006dd6:	0015f793          	andi	a5,a1,1
    80006dda:	ebad                	bnez	a5,80006e4c <bd_initfree_pair+0x90>
    80006ddc:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006de0:	00599493          	slli	s1,s3,0x5
    80006de4:	0002a797          	auipc	a5,0x2a
    80006de8:	26c7b783          	ld	a5,620(a5) # 80031050 <bd_sizes>
    80006dec:	94be                	add	s1,s1,a5
    80006dee:	0104bb03          	ld	s6,16(s1)
    80006df2:	855a                	mv	a0,s6
    80006df4:	00000097          	auipc	ra,0x0
    80006df8:	8b0080e7          	jalr	-1872(ra) # 800066a4 <bit_isset>
    80006dfc:	892a                	mv	s2,a0
    80006dfe:	85d2                	mv	a1,s4
    80006e00:	855a                	mv	a0,s6
    80006e02:	00000097          	auipc	ra,0x0
    80006e06:	8a2080e7          	jalr	-1886(ra) # 800066a4 <bit_isset>
  int free = 0;
    80006e0a:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006e0c:	02a90563          	beq	s2,a0,80006e36 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006e10:	45c1                	li	a1,16
    80006e12:	013599b3          	sll	s3,a1,s3
    80006e16:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006e1a:	02090c63          	beqz	s2,80006e52 <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006e1e:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006e22:	0002a597          	auipc	a1,0x2a
    80006e26:	2265b583          	ld	a1,550(a1) # 80031048 <bd_base>
    80006e2a:	95ce                	add	a1,a1,s3
    80006e2c:	8526                	mv	a0,s1
    80006e2e:	00000097          	auipc	ra,0x0
    80006e32:	48e080e7          	jalr	1166(ra) # 800072bc <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006e36:	855a                	mv	a0,s6
    80006e38:	70e2                	ld	ra,56(sp)
    80006e3a:	7442                	ld	s0,48(sp)
    80006e3c:	74a2                	ld	s1,40(sp)
    80006e3e:	7902                	ld	s2,32(sp)
    80006e40:	69e2                	ld	s3,24(sp)
    80006e42:	6a42                	ld	s4,16(sp)
    80006e44:	6aa2                	ld	s5,8(sp)
    80006e46:	6b02                	ld	s6,0(sp)
    80006e48:	6121                	addi	sp,sp,64
    80006e4a:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006e4c:	fff58a1b          	addiw	s4,a1,-1
    80006e50:	bf41                	j	80006de0 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006e52:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006e56:	0002a597          	auipc	a1,0x2a
    80006e5a:	1f25b583          	ld	a1,498(a1) # 80031048 <bd_base>
    80006e5e:	95ce                	add	a1,a1,s3
    80006e60:	8526                	mv	a0,s1
    80006e62:	00000097          	auipc	ra,0x0
    80006e66:	45a080e7          	jalr	1114(ra) # 800072bc <lst_push>
    80006e6a:	b7f1                	j	80006e36 <bd_initfree_pair+0x7a>

0000000080006e6c <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006e6c:	711d                	addi	sp,sp,-96
    80006e6e:	ec86                	sd	ra,88(sp)
    80006e70:	e8a2                	sd	s0,80(sp)
    80006e72:	e4a6                	sd	s1,72(sp)
    80006e74:	e0ca                	sd	s2,64(sp)
    80006e76:	fc4e                	sd	s3,56(sp)
    80006e78:	f852                	sd	s4,48(sp)
    80006e7a:	f456                	sd	s5,40(sp)
    80006e7c:	f05a                	sd	s6,32(sp)
    80006e7e:	ec5e                	sd	s7,24(sp)
    80006e80:	e862                	sd	s8,16(sp)
    80006e82:	e466                	sd	s9,8(sp)
    80006e84:	e06a                	sd	s10,0(sp)
    80006e86:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006e88:	0002a717          	auipc	a4,0x2a
    80006e8c:	1d072703          	lw	a4,464(a4) # 80031058 <nsizes>
    80006e90:	4785                	li	a5,1
    80006e92:	06e7db63          	bge	a5,a4,80006f08 <bd_initfree+0x9c>
    80006e96:	8aaa                	mv	s5,a0
    80006e98:	8b2e                	mv	s6,a1
    80006e9a:	4901                	li	s2,0
  int free = 0;
    80006e9c:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006e9e:	0002ac97          	auipc	s9,0x2a
    80006ea2:	1aac8c93          	addi	s9,s9,426 # 80031048 <bd_base>
  return n / BLK_SIZE(k);
    80006ea6:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006ea8:	0002ab97          	auipc	s7,0x2a
    80006eac:	1b0b8b93          	addi	s7,s7,432 # 80031058 <nsizes>
    80006eb0:	a039                	j	80006ebe <bd_initfree+0x52>
    80006eb2:	2905                	addiw	s2,s2,1
    80006eb4:	000ba783          	lw	a5,0(s7)
    80006eb8:	37fd                	addiw	a5,a5,-1
    80006eba:	04f95863          	bge	s2,a5,80006f0a <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006ebe:	85d6                	mv	a1,s5
    80006ec0:	854a                	mv	a0,s2
    80006ec2:	00000097          	auipc	ra,0x0
    80006ec6:	dd6080e7          	jalr	-554(ra) # 80006c98 <blk_index_next>
    80006eca:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006ecc:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006ed0:	409b04bb          	subw	s1,s6,s1
    80006ed4:	012c17b3          	sll	a5,s8,s2
    80006ed8:	02f4c4b3          	div	s1,s1,a5
    80006edc:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006ede:	85aa                	mv	a1,a0
    80006ee0:	854a                	mv	a0,s2
    80006ee2:	00000097          	auipc	ra,0x0
    80006ee6:	eda080e7          	jalr	-294(ra) # 80006dbc <bd_initfree_pair>
    80006eea:	01450d3b          	addw	s10,a0,s4
    80006eee:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006ef2:	fc99d0e3          	bge	s3,s1,80006eb2 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006ef6:	85a6                	mv	a1,s1
    80006ef8:	854a                	mv	a0,s2
    80006efa:	00000097          	auipc	ra,0x0
    80006efe:	ec2080e7          	jalr	-318(ra) # 80006dbc <bd_initfree_pair>
    80006f02:	00ad0a3b          	addw	s4,s10,a0
    80006f06:	b775                	j	80006eb2 <bd_initfree+0x46>
  int free = 0;
    80006f08:	4a01                	li	s4,0
  }
  return free;
}
    80006f0a:	8552                	mv	a0,s4
    80006f0c:	60e6                	ld	ra,88(sp)
    80006f0e:	6446                	ld	s0,80(sp)
    80006f10:	64a6                	ld	s1,72(sp)
    80006f12:	6906                	ld	s2,64(sp)
    80006f14:	79e2                	ld	s3,56(sp)
    80006f16:	7a42                	ld	s4,48(sp)
    80006f18:	7aa2                	ld	s5,40(sp)
    80006f1a:	7b02                	ld	s6,32(sp)
    80006f1c:	6be2                	ld	s7,24(sp)
    80006f1e:	6c42                	ld	s8,16(sp)
    80006f20:	6ca2                	ld	s9,8(sp)
    80006f22:	6d02                	ld	s10,0(sp)
    80006f24:	6125                	addi	sp,sp,96
    80006f26:	8082                	ret

0000000080006f28 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006f28:	7179                	addi	sp,sp,-48
    80006f2a:	f406                	sd	ra,40(sp)
    80006f2c:	f022                	sd	s0,32(sp)
    80006f2e:	ec26                	sd	s1,24(sp)
    80006f30:	e84a                	sd	s2,16(sp)
    80006f32:	e44e                	sd	s3,8(sp)
    80006f34:	1800                	addi	s0,sp,48
    80006f36:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006f38:	0002a997          	auipc	s3,0x2a
    80006f3c:	11098993          	addi	s3,s3,272 # 80031048 <bd_base>
    80006f40:	0009b483          	ld	s1,0(s3)
    80006f44:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006f48:	0002a797          	auipc	a5,0x2a
    80006f4c:	1107a783          	lw	a5,272(a5) # 80031058 <nsizes>
    80006f50:	37fd                	addiw	a5,a5,-1
    80006f52:	4641                	li	a2,16
    80006f54:	00f61633          	sll	a2,a2,a5
    80006f58:	85a6                	mv	a1,s1
    80006f5a:	00002517          	auipc	a0,0x2
    80006f5e:	b0e50513          	addi	a0,a0,-1266 # 80008a68 <userret+0x9d8>
    80006f62:	ffff9097          	auipc	ra,0xffff9
    80006f66:	640080e7          	jalr	1600(ra) # 800005a2 <printf>
  bd_mark(bd_base, p);
    80006f6a:	85ca                	mv	a1,s2
    80006f6c:	0009b503          	ld	a0,0(s3)
    80006f70:	00000097          	auipc	ra,0x0
    80006f74:	d74080e7          	jalr	-652(ra) # 80006ce4 <bd_mark>
  return meta;
}
    80006f78:	8526                	mv	a0,s1
    80006f7a:	70a2                	ld	ra,40(sp)
    80006f7c:	7402                	ld	s0,32(sp)
    80006f7e:	64e2                	ld	s1,24(sp)
    80006f80:	6942                	ld	s2,16(sp)
    80006f82:	69a2                	ld	s3,8(sp)
    80006f84:	6145                	addi	sp,sp,48
    80006f86:	8082                	ret

0000000080006f88 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006f88:	1101                	addi	sp,sp,-32
    80006f8a:	ec06                	sd	ra,24(sp)
    80006f8c:	e822                	sd	s0,16(sp)
    80006f8e:	e426                	sd	s1,8(sp)
    80006f90:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006f92:	0002a497          	auipc	s1,0x2a
    80006f96:	0c64a483          	lw	s1,198(s1) # 80031058 <nsizes>
    80006f9a:	fff4879b          	addiw	a5,s1,-1
    80006f9e:	44c1                	li	s1,16
    80006fa0:	00f494b3          	sll	s1,s1,a5
    80006fa4:	0002a797          	auipc	a5,0x2a
    80006fa8:	0a47b783          	ld	a5,164(a5) # 80031048 <bd_base>
    80006fac:	8d1d                	sub	a0,a0,a5
    80006fae:	40a4853b          	subw	a0,s1,a0
    80006fb2:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006fb6:	00905a63          	blez	s1,80006fca <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006fba:	357d                	addiw	a0,a0,-1
    80006fbc:	41f5549b          	sraiw	s1,a0,0x1f
    80006fc0:	01c4d49b          	srliw	s1,s1,0x1c
    80006fc4:	9ca9                	addw	s1,s1,a0
    80006fc6:	98c1                	andi	s1,s1,-16
    80006fc8:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006fca:	85a6                	mv	a1,s1
    80006fcc:	00002517          	auipc	a0,0x2
    80006fd0:	ad450513          	addi	a0,a0,-1324 # 80008aa0 <userret+0xa10>
    80006fd4:	ffff9097          	auipc	ra,0xffff9
    80006fd8:	5ce080e7          	jalr	1486(ra) # 800005a2 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006fdc:	0002a717          	auipc	a4,0x2a
    80006fe0:	06c73703          	ld	a4,108(a4) # 80031048 <bd_base>
    80006fe4:	0002a597          	auipc	a1,0x2a
    80006fe8:	0745a583          	lw	a1,116(a1) # 80031058 <nsizes>
    80006fec:	fff5879b          	addiw	a5,a1,-1
    80006ff0:	45c1                	li	a1,16
    80006ff2:	00f595b3          	sll	a1,a1,a5
    80006ff6:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006ffa:	95ba                	add	a1,a1,a4
    80006ffc:	953a                	add	a0,a0,a4
    80006ffe:	00000097          	auipc	ra,0x0
    80007002:	ce6080e7          	jalr	-794(ra) # 80006ce4 <bd_mark>
  return unavailable;
}
    80007006:	8526                	mv	a0,s1
    80007008:	60e2                	ld	ra,24(sp)
    8000700a:	6442                	ld	s0,16(sp)
    8000700c:	64a2                	ld	s1,8(sp)
    8000700e:	6105                	addi	sp,sp,32
    80007010:	8082                	ret

0000000080007012 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80007012:	715d                	addi	sp,sp,-80
    80007014:	e486                	sd	ra,72(sp)
    80007016:	e0a2                	sd	s0,64(sp)
    80007018:	fc26                	sd	s1,56(sp)
    8000701a:	f84a                	sd	s2,48(sp)
    8000701c:	f44e                	sd	s3,40(sp)
    8000701e:	f052                	sd	s4,32(sp)
    80007020:	ec56                	sd	s5,24(sp)
    80007022:	e85a                	sd	s6,16(sp)
    80007024:	e45e                	sd	s7,8(sp)
    80007026:	e062                	sd	s8,0(sp)
    80007028:	0880                	addi	s0,sp,80
    8000702a:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    8000702c:	fff50493          	addi	s1,a0,-1
    80007030:	98c1                	andi	s1,s1,-16
    80007032:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80007034:	00002597          	auipc	a1,0x2
    80007038:	a8c58593          	addi	a1,a1,-1396 # 80008ac0 <userret+0xa30>
    8000703c:	0002a517          	auipc	a0,0x2a
    80007040:	fc450513          	addi	a0,a0,-60 # 80031000 <lock>
    80007044:	ffffa097          	auipc	ra,0xffffa
    80007048:	97c080e7          	jalr	-1668(ra) # 800009c0 <initlock>
  bd_base = (void *) p;
    8000704c:	0002a797          	auipc	a5,0x2a
    80007050:	fe97be23          	sd	s1,-4(a5) # 80031048 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007054:	409c0933          	sub	s2,s8,s1
    80007058:	43f95513          	srai	a0,s2,0x3f
    8000705c:	893d                	andi	a0,a0,15
    8000705e:	954a                	add	a0,a0,s2
    80007060:	8511                	srai	a0,a0,0x4
    80007062:	00000097          	auipc	ra,0x0
    80007066:	c60080e7          	jalr	-928(ra) # 80006cc2 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    8000706a:	47c1                	li	a5,16
    8000706c:	00a797b3          	sll	a5,a5,a0
    80007070:	1b27c663          	blt	a5,s2,8000721c <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007074:	2505                	addiw	a0,a0,1
    80007076:	0002a797          	auipc	a5,0x2a
    8000707a:	fea7a123          	sw	a0,-30(a5) # 80031058 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    8000707e:	0002a997          	auipc	s3,0x2a
    80007082:	fda98993          	addi	s3,s3,-38 # 80031058 <nsizes>
    80007086:	0009a603          	lw	a2,0(s3)
    8000708a:	85ca                	mv	a1,s2
    8000708c:	00002517          	auipc	a0,0x2
    80007090:	a3c50513          	addi	a0,a0,-1476 # 80008ac8 <userret+0xa38>
    80007094:	ffff9097          	auipc	ra,0xffff9
    80007098:	50e080e7          	jalr	1294(ra) # 800005a2 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    8000709c:	0002a797          	auipc	a5,0x2a
    800070a0:	fa97ba23          	sd	s1,-76(a5) # 80031050 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    800070a4:	0009a603          	lw	a2,0(s3)
    800070a8:	00561913          	slli	s2,a2,0x5
    800070ac:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    800070ae:	0056161b          	slliw	a2,a2,0x5
    800070b2:	4581                	li	a1,0
    800070b4:	8526                	mv	a0,s1
    800070b6:	ffffa097          	auipc	ra,0xffffa
    800070ba:	cc2080e7          	jalr	-830(ra) # 80000d78 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    800070be:	0009a783          	lw	a5,0(s3)
    800070c2:	06f05a63          	blez	a5,80007136 <bd_init+0x124>
    800070c6:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    800070c8:	0002aa97          	auipc	s5,0x2a
    800070cc:	f88a8a93          	addi	s5,s5,-120 # 80031050 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800070d0:	0002aa17          	auipc	s4,0x2a
    800070d4:	f88a0a13          	addi	s4,s4,-120 # 80031058 <nsizes>
    800070d8:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    800070da:	00599b93          	slli	s7,s3,0x5
    800070de:	000ab503          	ld	a0,0(s5)
    800070e2:	955e                	add	a0,a0,s7
    800070e4:	00000097          	auipc	ra,0x0
    800070e8:	166080e7          	jalr	358(ra) # 8000724a <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800070ec:	000a2483          	lw	s1,0(s4)
    800070f0:	34fd                	addiw	s1,s1,-1
    800070f2:	413484bb          	subw	s1,s1,s3
    800070f6:	009b14bb          	sllw	s1,s6,s1
    800070fa:	fff4879b          	addiw	a5,s1,-1
    800070fe:	41f7d49b          	sraiw	s1,a5,0x1f
    80007102:	01d4d49b          	srliw	s1,s1,0x1d
    80007106:	9cbd                	addw	s1,s1,a5
    80007108:	98e1                	andi	s1,s1,-8
    8000710a:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    8000710c:	000ab783          	ld	a5,0(s5)
    80007110:	9bbe                	add	s7,s7,a5
    80007112:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80007116:	848d                	srai	s1,s1,0x3
    80007118:	8626                	mv	a2,s1
    8000711a:	4581                	li	a1,0
    8000711c:	854a                	mv	a0,s2
    8000711e:	ffffa097          	auipc	ra,0xffffa
    80007122:	c5a080e7          	jalr	-934(ra) # 80000d78 <memset>
    p += sz;
    80007126:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80007128:	0985                	addi	s3,s3,1
    8000712a:	000a2703          	lw	a4,0(s4)
    8000712e:	0009879b          	sext.w	a5,s3
    80007132:	fae7c4e3          	blt	a5,a4,800070da <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80007136:	0002a797          	auipc	a5,0x2a
    8000713a:	f227a783          	lw	a5,-222(a5) # 80031058 <nsizes>
    8000713e:	4705                	li	a4,1
    80007140:	06f75163          	bge	a4,a5,800071a2 <bd_init+0x190>
    80007144:	02000a13          	li	s4,32
    80007148:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000714a:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    8000714c:	0002ab17          	auipc	s6,0x2a
    80007150:	f04b0b13          	addi	s6,s6,-252 # 80031050 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80007154:	0002aa97          	auipc	s5,0x2a
    80007158:	f04a8a93          	addi	s5,s5,-252 # 80031058 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000715c:	37fd                	addiw	a5,a5,-1
    8000715e:	413787bb          	subw	a5,a5,s3
    80007162:	00fb94bb          	sllw	s1,s7,a5
    80007166:	fff4879b          	addiw	a5,s1,-1
    8000716a:	41f7d49b          	sraiw	s1,a5,0x1f
    8000716e:	01d4d49b          	srliw	s1,s1,0x1d
    80007172:	9cbd                	addw	s1,s1,a5
    80007174:	98e1                	andi	s1,s1,-8
    80007176:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80007178:	000b3783          	ld	a5,0(s6)
    8000717c:	97d2                	add	a5,a5,s4
    8000717e:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80007182:	848d                	srai	s1,s1,0x3
    80007184:	8626                	mv	a2,s1
    80007186:	4581                	li	a1,0
    80007188:	854a                	mv	a0,s2
    8000718a:	ffffa097          	auipc	ra,0xffffa
    8000718e:	bee080e7          	jalr	-1042(ra) # 80000d78 <memset>
    p += sz;
    80007192:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80007194:	2985                	addiw	s3,s3,1
    80007196:	000aa783          	lw	a5,0(s5)
    8000719a:	020a0a13          	addi	s4,s4,32
    8000719e:	faf9cfe3          	blt	s3,a5,8000715c <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    800071a2:	197d                	addi	s2,s2,-1
    800071a4:	ff097913          	andi	s2,s2,-16
    800071a8:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    800071aa:	854a                	mv	a0,s2
    800071ac:	00000097          	auipc	ra,0x0
    800071b0:	d7c080e7          	jalr	-644(ra) # 80006f28 <bd_mark_data_structures>
    800071b4:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    800071b6:	85ca                	mv	a1,s2
    800071b8:	8562                	mv	a0,s8
    800071ba:	00000097          	auipc	ra,0x0
    800071be:	dce080e7          	jalr	-562(ra) # 80006f88 <bd_mark_unavailable>
    800071c2:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    800071c4:	0002aa97          	auipc	s5,0x2a
    800071c8:	e94a8a93          	addi	s5,s5,-364 # 80031058 <nsizes>
    800071cc:	000aa783          	lw	a5,0(s5)
    800071d0:	37fd                	addiw	a5,a5,-1
    800071d2:	44c1                	li	s1,16
    800071d4:	00f497b3          	sll	a5,s1,a5
    800071d8:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    800071da:	0002a597          	auipc	a1,0x2a
    800071de:	e6e5b583          	ld	a1,-402(a1) # 80031048 <bd_base>
    800071e2:	95be                	add	a1,a1,a5
    800071e4:	854a                	mv	a0,s2
    800071e6:	00000097          	auipc	ra,0x0
    800071ea:	c86080e7          	jalr	-890(ra) # 80006e6c <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    800071ee:	000aa603          	lw	a2,0(s5)
    800071f2:	367d                	addiw	a2,a2,-1
    800071f4:	00c49633          	sll	a2,s1,a2
    800071f8:	41460633          	sub	a2,a2,s4
    800071fc:	41360633          	sub	a2,a2,s3
    80007200:	02c51463          	bne	a0,a2,80007228 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80007204:	60a6                	ld	ra,72(sp)
    80007206:	6406                	ld	s0,64(sp)
    80007208:	74e2                	ld	s1,56(sp)
    8000720a:	7942                	ld	s2,48(sp)
    8000720c:	79a2                	ld	s3,40(sp)
    8000720e:	7a02                	ld	s4,32(sp)
    80007210:	6ae2                	ld	s5,24(sp)
    80007212:	6b42                	ld	s6,16(sp)
    80007214:	6ba2                	ld	s7,8(sp)
    80007216:	6c02                	ld	s8,0(sp)
    80007218:	6161                	addi	sp,sp,80
    8000721a:	8082                	ret
    nsizes++;  // round up to the next power of 2
    8000721c:	2509                	addiw	a0,a0,2
    8000721e:	0002a797          	auipc	a5,0x2a
    80007222:	e2a7ad23          	sw	a0,-454(a5) # 80031058 <nsizes>
    80007226:	bda1                	j	8000707e <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007228:	85aa                	mv	a1,a0
    8000722a:	00002517          	auipc	a0,0x2
    8000722e:	8de50513          	addi	a0,a0,-1826 # 80008b08 <userret+0xa78>
    80007232:	ffff9097          	auipc	ra,0xffff9
    80007236:	370080e7          	jalr	880(ra) # 800005a2 <printf>
    panic("bd_init: free mem");
    8000723a:	00002517          	auipc	a0,0x2
    8000723e:	8de50513          	addi	a0,a0,-1826 # 80008b18 <userret+0xa88>
    80007242:	ffff9097          	auipc	ra,0xffff9
    80007246:	306080e7          	jalr	774(ra) # 80000548 <panic>

000000008000724a <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    8000724a:	1141                	addi	sp,sp,-16
    8000724c:	e422                	sd	s0,8(sp)
    8000724e:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007250:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80007252:	e508                	sd	a0,8(a0)
}
    80007254:	6422                	ld	s0,8(sp)
    80007256:	0141                	addi	sp,sp,16
    80007258:	8082                	ret

000000008000725a <lst_empty>:

int
lst_empty(struct list *lst) {
    8000725a:	1141                	addi	sp,sp,-16
    8000725c:	e422                	sd	s0,8(sp)
    8000725e:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007260:	611c                	ld	a5,0(a0)
    80007262:	40a78533          	sub	a0,a5,a0
}
    80007266:	00153513          	seqz	a0,a0
    8000726a:	6422                	ld	s0,8(sp)
    8000726c:	0141                	addi	sp,sp,16
    8000726e:	8082                	ret

0000000080007270 <lst_remove>:

void
lst_remove(struct list *e) {
    80007270:	1141                	addi	sp,sp,-16
    80007272:	e422                	sd	s0,8(sp)
    80007274:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007276:	6518                	ld	a4,8(a0)
    80007278:	611c                	ld	a5,0(a0)
    8000727a:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    8000727c:	6518                	ld	a4,8(a0)
    8000727e:	e798                	sd	a4,8(a5)
}
    80007280:	6422                	ld	s0,8(sp)
    80007282:	0141                	addi	sp,sp,16
    80007284:	8082                	ret

0000000080007286 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007286:	1101                	addi	sp,sp,-32
    80007288:	ec06                	sd	ra,24(sp)
    8000728a:	e822                	sd	s0,16(sp)
    8000728c:	e426                	sd	s1,8(sp)
    8000728e:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007290:	6104                	ld	s1,0(a0)
    80007292:	00a48d63          	beq	s1,a0,800072ac <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007296:	8526                	mv	a0,s1
    80007298:	00000097          	auipc	ra,0x0
    8000729c:	fd8080e7          	jalr	-40(ra) # 80007270 <lst_remove>
  return (void *)p;
}
    800072a0:	8526                	mv	a0,s1
    800072a2:	60e2                	ld	ra,24(sp)
    800072a4:	6442                	ld	s0,16(sp)
    800072a6:	64a2                	ld	s1,8(sp)
    800072a8:	6105                	addi	sp,sp,32
    800072aa:	8082                	ret
    panic("lst_pop");
    800072ac:	00002517          	auipc	a0,0x2
    800072b0:	88450513          	addi	a0,a0,-1916 # 80008b30 <userret+0xaa0>
    800072b4:	ffff9097          	auipc	ra,0xffff9
    800072b8:	294080e7          	jalr	660(ra) # 80000548 <panic>

00000000800072bc <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    800072bc:	1141                	addi	sp,sp,-16
    800072be:	e422                	sd	s0,8(sp)
    800072c0:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    800072c2:	611c                	ld	a5,0(a0)
    800072c4:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    800072c6:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    800072c8:	611c                	ld	a5,0(a0)
    800072ca:	e78c                	sd	a1,8(a5)
  lst->next = e;
    800072cc:	e10c                	sd	a1,0(a0)
}
    800072ce:	6422                	ld	s0,8(sp)
    800072d0:	0141                	addi	sp,sp,16
    800072d2:	8082                	ret

00000000800072d4 <lst_print>:

void
lst_print(struct list *lst)
{
    800072d4:	7179                	addi	sp,sp,-48
    800072d6:	f406                	sd	ra,40(sp)
    800072d8:	f022                	sd	s0,32(sp)
    800072da:	ec26                	sd	s1,24(sp)
    800072dc:	e84a                	sd	s2,16(sp)
    800072de:	e44e                	sd	s3,8(sp)
    800072e0:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800072e2:	6104                	ld	s1,0(a0)
    800072e4:	02950063          	beq	a0,s1,80007304 <lst_print+0x30>
    800072e8:	892a                	mv	s2,a0
    printf(" %p", p);
    800072ea:	00002997          	auipc	s3,0x2
    800072ee:	84e98993          	addi	s3,s3,-1970 # 80008b38 <userret+0xaa8>
    800072f2:	85a6                	mv	a1,s1
    800072f4:	854e                	mv	a0,s3
    800072f6:	ffff9097          	auipc	ra,0xffff9
    800072fa:	2ac080e7          	jalr	684(ra) # 800005a2 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800072fe:	6084                	ld	s1,0(s1)
    80007300:	fe9919e3          	bne	s2,s1,800072f2 <lst_print+0x1e>
  }
  printf("\n");
    80007304:	00001517          	auipc	a0,0x1
    80007308:	00450513          	addi	a0,a0,4 # 80008308 <userret+0x278>
    8000730c:	ffff9097          	auipc	ra,0xffff9
    80007310:	296080e7          	jalr	662(ra) # 800005a2 <printf>
}
    80007314:	70a2                	ld	ra,40(sp)
    80007316:	7402                	ld	s0,32(sp)
    80007318:	64e2                	ld	s1,24(sp)
    8000731a:	6942                	ld	s2,16(sp)
    8000731c:	69a2                	ld	s3,8(sp)
    8000731e:	6145                	addi	sp,sp,48
    80007320:	8082                	ret
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
