
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
    80000060:	22478793          	addi	a5,a5,548 # 80006280 <timervec>
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
    800000aa:	00e78793          	addi	a5,a5,14 # 800010b4 <main>
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
    80000112:	b8e080e7          	jalr	-1138(ra) # 80000c9c <acquire>
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
    80000140:	b86080e7          	jalr	-1146(ra) # 80001cc2 <myproc>
    80000144:	5d1c                	lw	a5,56(a0)
    80000146:	e7b5                	bnez	a5,800001b2 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    80000148:	85a6                	mv	a1,s1
    8000014a:	854a                	mv	a0,s2
    8000014c:	00002097          	auipc	ra,0x2
    80000150:	34c080e7          	jalr	844(ra) # 80002498 <sleep>
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
    8000018c:	56a080e7          	jalr	1386(ra) # 800026f2 <either_copyout>
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
    800001a8:	b68080e7          	jalr	-1176(ra) # 80000d0c <release>

  return target - n;
    800001ac:	413b053b          	subw	a0,s6,s3
    800001b0:	a811                	j	800001c4 <consoleread+0xe4>
        release(&cons.lock);
    800001b2:	00012517          	auipc	a0,0x12
    800001b6:	64e50513          	addi	a0,a0,1614 # 80012800 <cons>
    800001ba:	00001097          	auipc	ra,0x1
    800001be:	b52080e7          	jalr	-1198(ra) # 80000d0c <release>
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
    800001f2:	00034797          	auipc	a5,0x34
    800001f6:	e2e7a783          	lw	a5,-466(a5) # 80034020 <panicked>
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
    80000264:	a3c080e7          	jalr	-1476(ra) # 80000c9c <acquire>
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
    8000028a:	4c2080e7          	jalr	1218(ra) # 80002748 <either_copyin>
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
    800002b0:	a60080e7          	jalr	-1440(ra) # 80000d0c <release>
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
    800002e2:	9be080e7          	jalr	-1602(ra) # 80000c9c <acquire>

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
    80000300:	4a2080e7          	jalr	1186(ra) # 8000279e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00012517          	auipc	a0,0x12
    80000308:	4fc50513          	addi	a0,a0,1276 # 80012800 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	a00080e7          	jalr	-1536(ra) # 80000d0c <release>
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
    80000454:	1c8080e7          	jalr	456(ra) # 80002618 <wakeup>
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
    80000476:	6dc080e7          	jalr	1756(ra) # 80000b4e <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	33a080e7          	jalr	826(ra) # 800007b4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	0002d797          	auipc	a5,0x2d
    80000486:	95678793          	addi	a5,a5,-1706 # 8002cdd8 <devsw>
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
    800004c8:	7fc60613          	addi	a2,a2,2044 # 80008cc0 <digits>
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
    8000057a:	05a50513          	addi	a0,a0,90 # 800085d0 <userret+0x540>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	024080e7          	jalr	36(ra) # 800005a2 <printf>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    80000586:	00008517          	auipc	a0,0x8
    8000058a:	ba250513          	addi	a0,a0,-1118 # 80008128 <userret+0x98>
    8000058e:	00000097          	auipc	ra,0x0
    80000592:	014080e7          	jalr	20(ra) # 800005a2 <printf>
  panicked = 1; // freeze other CPUs
    80000596:	4785                	li	a5,1
    80000598:	00034717          	auipc	a4,0x34
    8000059c:	a8f72423          	sw	a5,-1400(a4) # 80034020 <panicked>
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
    80000604:	6c0b0b13          	addi	s6,s6,1728 # 80008cc0 <digits>
    switch(c){
    80000608:	07300c93          	li	s9,115
    8000060c:	06400c13          	li	s8,100
    80000610:	a82d                	j	8000064a <printf+0xa8>
    acquire(&pr.lock);
    80000612:	00012517          	auipc	a0,0x12
    80000616:	29e50513          	addi	a0,a0,670 # 800128b0 <pr>
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	682080e7          	jalr	1666(ra) # 80000c9c <acquire>
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
    8000077c:	594080e7          	jalr	1428(ra) # 80000d0c <release>
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
    800007a2:	3b0080e7          	jalr	944(ra) # 80000b4e <initlock>
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

0000000080000864 <getrefindex>:
  struct run *freelist;
} kmem;


int
getrefindex(void *pa){
    80000864:	1141                	addi	sp,sp,-16
    80000866:	e422                	sd	s0,8(sp)
    80000868:	0800                	addi	s0,sp,16
  int index = ((char*)pa - (char*)PGROUNDUP((uint64)end)) / PGSIZE;
    8000086a:	00034797          	auipc	a5,0x34
    8000086e:	7f178793          	addi	a5,a5,2033 # 8003505b <end+0xfff>
    80000872:	777d                	lui	a4,0xfffff
    80000874:	8ff9                	and	a5,a5,a4
    80000876:	40f507b3          	sub	a5,a0,a5
    8000087a:	43f7d513          	srai	a0,a5,0x3f
    8000087e:	6705                	lui	a4,0x1
    80000880:	177d                	addi	a4,a4,-1
    80000882:	8d79                	and	a0,a0,a4
    80000884:	953e                	add	a0,a0,a5
    80000886:	8531                	srai	a0,a0,0xc
  return index;
}
    80000888:	2501                	sext.w	a0,a0
    8000088a:	6422                	ld	s0,8(sp)
    8000088c:	0141                	addi	sp,sp,16
    8000088e:	8082                	ret

0000000080000890 <getref>:

int
getref(void *pa){
    80000890:	1141                	addi	sp,sp,-16
    80000892:	e422                	sd	s0,8(sp)
    80000894:	0800                	addi	s0,sp,16
  int index = ((char*)pa - (char*)PGROUNDUP((uint64)end)) / PGSIZE;
    80000896:	00034797          	auipc	a5,0x34
    8000089a:	7c578793          	addi	a5,a5,1989 # 8003505b <end+0xfff>
    8000089e:	777d                	lui	a4,0xfffff
    800008a0:	8ff9                	and	a5,a5,a4
    800008a2:	8d1d                	sub	a0,a0,a5
    800008a4:	43f55793          	srai	a5,a0,0x3f
    800008a8:	6705                	lui	a4,0x1
    800008aa:	177d                	addi	a4,a4,-1
    800008ac:	8ff9                	and	a5,a5,a4
    800008ae:	97aa                	add	a5,a5,a0
    800008b0:	87b1                	srai	a5,a5,0xc
  return reference[getrefindex(pa)];
    800008b2:	2781                	sext.w	a5,a5
    800008b4:	00012717          	auipc	a4,0x12
    800008b8:	04c70713          	addi	a4,a4,76 # 80012900 <reference>
    800008bc:	97ba                	add	a5,a5,a4
}
    800008be:	0007c503          	lbu	a0,0(a5)
    800008c2:	6422                	ld	s0,8(sp)
    800008c4:	0141                	addi	sp,sp,16
    800008c6:	8082                	ret

00000000800008c8 <addref>:


void
addref(char *tip, void *pa){
    800008c8:	1141                	addi	sp,sp,-16
    800008ca:	e422                	sd	s0,8(sp)
    800008cc:	0800                	addi	s0,sp,16
  int index = ((char*)pa - (char*)PGROUNDUP((uint64)end)) / PGSIZE;
    800008ce:	00034797          	auipc	a5,0x34
    800008d2:	78d78793          	addi	a5,a5,1933 # 8003505b <end+0xfff>
    800008d6:	777d                	lui	a4,0xfffff
    800008d8:	8ff9                	and	a5,a5,a4
    800008da:	8d9d                	sub	a1,a1,a5
    800008dc:	43f5d793          	srai	a5,a1,0x3f
    800008e0:	6705                	lui	a4,0x1
    800008e2:	177d                	addi	a4,a4,-1
    800008e4:	8ff9                	and	a5,a5,a4
    800008e6:	97ae                	add	a5,a5,a1
    800008e8:	87b1                	srai	a5,a5,0xc
    800008ea:	2781                	sext.w	a5,a5
  
  reference[getrefindex(pa)]++;
    800008ec:	00012717          	auipc	a4,0x12
    800008f0:	01470713          	addi	a4,a4,20 # 80012900 <reference>
    800008f4:	97ba                	add	a5,a5,a4
    800008f6:	0007c703          	lbu	a4,0(a5)
    800008fa:	2705                	addiw	a4,a4,1
    800008fc:	00e78023          	sb	a4,0(a5)
  // printf("%s: addref: %d, pa: %p \n",tip,  reference[index], pa); 
  //((struct run*)pa)->ref_count++;
  //printf("%s: addref: %d, pa: %p \n", tip, ((struct run*)pa)->ref_count, pa);
}
    80000900:	6422                	ld	s0,8(sp)
    80000902:	0141                	addi	sp,sp,16
    80000904:	8082                	ret

0000000080000906 <subref>:

void
subref(char *tip,void *pa){
    80000906:	1141                	addi	sp,sp,-16
    80000908:	e422                	sd	s0,8(sp)
    8000090a:	0800                	addi	s0,sp,16
  int index = ((char*)pa - (char*)PGROUNDUP((uint64)end)) / PGSIZE;
    8000090c:	00034797          	auipc	a5,0x34
    80000910:	74f78793          	addi	a5,a5,1871 # 8003505b <end+0xfff>
    80000914:	777d                	lui	a4,0xfffff
    80000916:	8ff9                	and	a5,a5,a4
    80000918:	8d9d                	sub	a1,a1,a5
    8000091a:	43f5d793          	srai	a5,a1,0x3f
    8000091e:	6705                	lui	a4,0x1
    80000920:	177d                	addi	a4,a4,-1
    80000922:	8ff9                	and	a5,a5,a4
    80000924:	97ae                	add	a5,a5,a1
    80000926:	87b1                	srai	a5,a5,0xc
    80000928:	2781                	sext.w	a5,a5
  int index = getrefindex(pa);
  if(reference[index] == 0)
    8000092a:	00012717          	auipc	a4,0x12
    8000092e:	fd670713          	addi	a4,a4,-42 # 80012900 <reference>
    80000932:	973e                	add	a4,a4,a5
    80000934:	00074703          	lbu	a4,0(a4)
    80000938:	cb09                	beqz	a4,8000094a <subref+0x44>
    return;
  reference[index]--;
    8000093a:	00012697          	auipc	a3,0x12
    8000093e:	fc668693          	addi	a3,a3,-58 # 80012900 <reference>
    80000942:	97b6                	add	a5,a5,a3
    80000944:	377d                	addiw	a4,a4,-1
    80000946:	00e78023          	sb	a4,0(a5)
  /* if(((struct run*)pa)->ref_count == 0){
    return;
  }
  ((struct run*)pa)->ref_count--;
  printf("%s: subref: %d, pa: %p \n",tip, ((struct run*)pa)->ref_count,pa); */
}
    8000094a:	6422                	ld	s0,8(sp)
    8000094c:	0141                	addi	sp,sp,16
    8000094e:	8082                	ret

0000000080000950 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000950:	1101                	addi	sp,sp,-32
    80000952:	ec06                	sd	ra,24(sp)
    80000954:	e822                	sd	s0,16(sp)
    80000956:	e426                	sd	s1,8(sp)
    80000958:	e04a                	sd	s2,0(sp)
    8000095a:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    8000095c:	03451793          	slli	a5,a0,0x34
    80000960:	e3a9                	bnez	a5,800009a2 <kfree+0x52>
    80000962:	84aa                	mv	s1,a0
    80000964:	00033797          	auipc	a5,0x33
    80000968:	6f878793          	addi	a5,a5,1784 # 8003405c <end>
    8000096c:	02f56b63          	bltu	a0,a5,800009a2 <kfree+0x52>
    80000970:	47c5                	li	a5,17
    80000972:	07ee                	slli	a5,a5,0x1b
    80000974:	02f57763          	bgeu	a0,a5,800009a2 <kfree+0x52>
  /** 
   * 
   * 大坑：一定要在kfree中减，因为其他很多程序也会调用kfree，如此一来，那些程序就无法kfree掉
   * 鸣谢：刘俊杰同学
   * */
  subref("kfree()", (void *) pa);
    80000978:	85aa                	mv	a1,a0
    8000097a:	00008517          	auipc	a0,0x8
    8000097e:	8a650513          	addi	a0,a0,-1882 # 80008220 <userret+0x190>
    80000982:	00000097          	auipc	ra,0x0
    80000986:	f84080e7          	jalr	-124(ra) # 80000906 <subref>
  int ref_count = getref(pa);
    8000098a:	8526                	mv	a0,s1
    8000098c:	00000097          	auipc	ra,0x0
    80000990:	f04080e7          	jalr	-252(ra) # 80000890 <getref>
  if(ref_count == 0){
    80000994:	cd19                	beqz	a0,800009b2 <kfree+0x62>
  // r->ref_count = 0;
  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock); */
}
    80000996:	60e2                	ld	ra,24(sp)
    80000998:	6442                	ld	s0,16(sp)
    8000099a:	64a2                	ld	s1,8(sp)
    8000099c:	6902                	ld	s2,0(sp)
    8000099e:	6105                	addi	sp,sp,32
    800009a0:	8082                	ret
    panic("kfree");
    800009a2:	00008517          	auipc	a0,0x8
    800009a6:	87650513          	addi	a0,a0,-1930 # 80008218 <userret+0x188>
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	b9e080e7          	jalr	-1122(ra) # 80000548 <panic>
    memset(pa, 1, PGSIZE);
    800009b2:	6605                	lui	a2,0x1
    800009b4:	4585                	li	a1,1
    800009b6:	8526                	mv	a0,s1
    800009b8:	00000097          	auipc	ra,0x0
    800009bc:	54e080e7          	jalr	1358(ra) # 80000f06 <memset>
    acquire(&kmem.lock);
    800009c0:	00012917          	auipc	s2,0x12
    800009c4:	f1890913          	addi	s2,s2,-232 # 800128d8 <kmem>
    800009c8:	854a                	mv	a0,s2
    800009ca:	00000097          	auipc	ra,0x0
    800009ce:	2d2080e7          	jalr	722(ra) # 80000c9c <acquire>
    r->next = kmem.freelist;
    800009d2:	02093783          	ld	a5,32(s2)
    800009d6:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    800009d8:	02993023          	sd	s1,32(s2)
    release(&kmem.lock);
    800009dc:	854a                	mv	a0,s2
    800009de:	00000097          	auipc	ra,0x0
    800009e2:	32e080e7          	jalr	814(ra) # 80000d0c <release>
}
    800009e6:	bf45                	j	80000996 <kfree+0x46>

00000000800009e8 <freerange>:
{
    800009e8:	715d                	addi	sp,sp,-80
    800009ea:	e486                	sd	ra,72(sp)
    800009ec:	e0a2                	sd	s0,64(sp)
    800009ee:	fc26                	sd	s1,56(sp)
    800009f0:	f84a                	sd	s2,48(sp)
    800009f2:	f44e                	sd	s3,40(sp)
    800009f4:	f052                	sd	s4,32(sp)
    800009f6:	ec56                	sd	s5,24(sp)
    800009f8:	e85a                	sd	s6,16(sp)
    800009fa:	e45e                	sd	s7,8(sp)
    800009fc:	0880                	addi	s0,sp,80
    800009fe:	892e                	mv	s2,a1
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a00:	6985                	lui	s3,0x1
    80000a02:	fff98493          	addi	s1,s3,-1 # fff <_entry-0x7ffff001>
    80000a06:	94aa                	add	s1,s1,a0
    80000a08:	757d                	lui	a0,0xfffff
    80000a0a:	8ce9                	and	s1,s1,a0
  printf("start ~ end:%p ~ %p\n", p, pa_end);
    80000a0c:	862e                	mv	a2,a1
    80000a0e:	85a6                	mv	a1,s1
    80000a10:	00008517          	auipc	a0,0x8
    80000a14:	81850513          	addi	a0,a0,-2024 # 80008228 <userret+0x198>
    80000a18:	00000097          	auipc	ra,0x0
    80000a1c:	b8a080e7          	jalr	-1142(ra) # 800005a2 <printf>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000a20:	94ce                	add	s1,s1,s3
    80000a22:	04996563          	bltu	s2,s1,80000a6c <freerange+0x84>
    80000a26:	7a7d                	lui	s4,0xfffff
    reference[getrefindex(p)] = 0;
    80000a28:	00012b97          	auipc	s7,0x12
    80000a2c:	ed8b8b93          	addi	s7,s7,-296 # 80012900 <reference>
  int index = ((char*)pa - (char*)PGROUNDUP((uint64)end)) / PGSIZE;
    80000a30:	6a85                	lui	s5,0x1
    80000a32:	fffa8b13          	addi	s6,s5,-1 # fff <_entry-0x7ffff001>
    80000a36:	00034997          	auipc	s3,0x34
    80000a3a:	62598993          	addi	s3,s3,1573 # 8003505b <end+0xfff>
    80000a3e:	0149f9b3          	and	s3,s3,s4
    80000a42:	01448533          	add	a0,s1,s4
    80000a46:	41350733          	sub	a4,a0,s3
    80000a4a:	43f75793          	srai	a5,a4,0x3f
    80000a4e:	0167f7b3          	and	a5,a5,s6
    80000a52:	97ba                	add	a5,a5,a4
    80000a54:	87b1                	srai	a5,a5,0xc
    reference[getrefindex(p)] = 0;
    80000a56:	2781                	sext.w	a5,a5
    80000a58:	97de                	add	a5,a5,s7
    80000a5a:	00078023          	sb	zero,0(a5)
    kfree(p);
    80000a5e:	00000097          	auipc	ra,0x0
    80000a62:	ef2080e7          	jalr	-270(ra) # 80000950 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000a66:	94d6                	add	s1,s1,s5
    80000a68:	fc997de3          	bgeu	s2,s1,80000a42 <freerange+0x5a>
}
    80000a6c:	60a6                	ld	ra,72(sp)
    80000a6e:	6406                	ld	s0,64(sp)
    80000a70:	74e2                	ld	s1,56(sp)
    80000a72:	7942                	ld	s2,48(sp)
    80000a74:	79a2                	ld	s3,40(sp)
    80000a76:	7a02                	ld	s4,32(sp)
    80000a78:	6ae2                	ld	s5,24(sp)
    80000a7a:	6b42                	ld	s6,16(sp)
    80000a7c:	6ba2                	ld	s7,8(sp)
    80000a7e:	6161                	addi	sp,sp,80
    80000a80:	8082                	ret

0000000080000a82 <kinit>:
{
    80000a82:	1141                	addi	sp,sp,-16
    80000a84:	e406                	sd	ra,8(sp)
    80000a86:	e022                	sd	s0,0(sp)
    80000a88:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a8a:	00007597          	auipc	a1,0x7
    80000a8e:	7b658593          	addi	a1,a1,1974 # 80008240 <userret+0x1b0>
    80000a92:	00012517          	auipc	a0,0x12
    80000a96:	e4650513          	addi	a0,a0,-442 # 800128d8 <kmem>
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	0b4080e7          	jalr	180(ra) # 80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aa2:	45c5                	li	a1,17
    80000aa4:	05ee                	slli	a1,a1,0x1b
    80000aa6:	00033517          	auipc	a0,0x33
    80000aaa:	5b650513          	addi	a0,a0,1462 # 8003405c <end>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	f3a080e7          	jalr	-198(ra) # 800009e8 <freerange>
}
    80000ab6:	60a2                	ld	ra,8(sp)
    80000ab8:	6402                	ld	s0,0(sp)
    80000aba:	0141                	addi	sp,sp,16
    80000abc:	8082                	ret

0000000080000abe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000abe:	1101                	addi	sp,sp,-32
    80000ac0:	ec06                	sd	ra,24(sp)
    80000ac2:	e822                	sd	s0,16(sp)
    80000ac4:	e426                	sd	s1,8(sp)
    80000ac6:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ac8:	00012497          	auipc	s1,0x12
    80000acc:	e1048493          	addi	s1,s1,-496 # 800128d8 <kmem>
    80000ad0:	8526                	mv	a0,s1
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	1ca080e7          	jalr	458(ra) # 80000c9c <acquire>
  r = kmem.freelist;
    80000ada:	7084                	ld	s1,32(s1)
  if(r)
    80000adc:	c0a5                	beqz	s1,80000b3c <kalloc+0x7e>
    kmem.freelist = r->next;
    80000ade:	609c                	ld	a5,0(s1)
    80000ae0:	00012517          	auipc	a0,0x12
    80000ae4:	df850513          	addi	a0,a0,-520 # 800128d8 <kmem>
    80000ae8:	f11c                	sd	a5,32(a0)
  release(&kmem.lock);
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	222080e7          	jalr	546(ra) # 80000d0c <release>
  /** implementation of ref count  */
  /** r is the start of physical page  */
  if(r){
    //int ref_count = r->ref_count;
    //printf("r->ref_count: %d\n",ref_count);
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000af2:	6605                	lui	a2,0x1
    80000af4:	4595                	li	a1,5
    80000af6:	8526                	mv	a0,s1
    80000af8:	00000097          	auipc	ra,0x0
    80000afc:	40e080e7          	jalr	1038(ra) # 80000f06 <memset>
  int index = ((char*)pa - (char*)PGROUNDUP((uint64)end)) / PGSIZE;
    80000b00:	00034797          	auipc	a5,0x34
    80000b04:	55b78793          	addi	a5,a5,1371 # 8003505b <end+0xfff>
    80000b08:	777d                	lui	a4,0xfffff
    80000b0a:	8ff9                	and	a5,a5,a4
    80000b0c:	40f48733          	sub	a4,s1,a5
    80000b10:	43f75793          	srai	a5,a4,0x3f
    80000b14:	6685                	lui	a3,0x1
    80000b16:	16fd                	addi	a3,a3,-1
    80000b18:	8ff5                	and	a5,a5,a3
    80000b1a:	97ba                	add	a5,a5,a4
    80000b1c:	87b1                	srai	a5,a5,0xc
    int index = getrefindex((void *)r);
    reference[index] = 1;
    80000b1e:	2781                	sext.w	a5,a5
    80000b20:	00012717          	auipc	a4,0x12
    80000b24:	de070713          	addi	a4,a4,-544 # 80012900 <reference>
    80000b28:	97ba                	add	a5,a5,a4
    80000b2a:	4705                	li	a4,1
    80000b2c:	00e78023          	sb	a4,0(a5)
    //r->ref_count = ref_count + 1; 
    //printf("r->ref_count: %d\n",ref_count);  
  }
  /** r出去后会被修改 */
  return (void*)r;
}
    80000b30:	8526                	mv	a0,s1
    80000b32:	60e2                	ld	ra,24(sp)
    80000b34:	6442                	ld	s0,16(sp)
    80000b36:	64a2                	ld	s1,8(sp)
    80000b38:	6105                	addi	sp,sp,32
    80000b3a:	8082                	ret
  release(&kmem.lock);
    80000b3c:	00012517          	auipc	a0,0x12
    80000b40:	d9c50513          	addi	a0,a0,-612 # 800128d8 <kmem>
    80000b44:	00000097          	auipc	ra,0x0
    80000b48:	1c8080e7          	jalr	456(ra) # 80000d0c <release>
  if(r){
    80000b4c:	b7d5                	j	80000b30 <kalloc+0x72>

0000000080000b4e <initlock>:

// assumes locks are not freed
void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
    80000b4e:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b50:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b54:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000b58:	00052e23          	sw	zero,28(a0)
  lk->n = 0;
    80000b5c:	00052c23          	sw	zero,24(a0)
  if(nlock >= NLOCK)
    80000b60:	00033797          	auipc	a5,0x33
    80000b64:	4c47a783          	lw	a5,1220(a5) # 80034024 <nlock>
    80000b68:	3e700713          	li	a4,999
    80000b6c:	02f74063          	blt	a4,a5,80000b8c <initlock+0x3e>
    panic("initlock");
  locks[nlock] = lk;
    80000b70:	00379693          	slli	a3,a5,0x3
    80000b74:	0001a717          	auipc	a4,0x1a
    80000b78:	d6470713          	addi	a4,a4,-668 # 8001a8d8 <locks>
    80000b7c:	9736                	add	a4,a4,a3
    80000b7e:	e308                	sd	a0,0(a4)
  nlock++;
    80000b80:	2785                	addiw	a5,a5,1
    80000b82:	00033717          	auipc	a4,0x33
    80000b86:	4af72123          	sw	a5,1186(a4) # 80034024 <nlock>
    80000b8a:	8082                	ret
{
    80000b8c:	1141                	addi	sp,sp,-16
    80000b8e:	e406                	sd	ra,8(sp)
    80000b90:	e022                	sd	s0,0(sp)
    80000b92:	0800                	addi	s0,sp,16
    panic("initlock");
    80000b94:	00007517          	auipc	a0,0x7
    80000b98:	6b450513          	addi	a0,a0,1716 # 80008248 <userret+0x1b8>
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	9ac080e7          	jalr	-1620(ra) # 80000548 <panic>

0000000080000ba4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000ba4:	1101                	addi	sp,sp,-32
    80000ba6:	ec06                	sd	ra,24(sp)
    80000ba8:	e822                	sd	s0,16(sp)
    80000baa:	e426                	sd	s1,8(sp)
    80000bac:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bae:	100024f3          	csrr	s1,sstatus
    80000bb2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bb6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bb8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bbc:	00001097          	auipc	ra,0x1
    80000bc0:	0ea080e7          	jalr	234(ra) # 80001ca6 <mycpu>
    80000bc4:	5d3c                	lw	a5,120(a0)
    80000bc6:	cf89                	beqz	a5,80000be0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc8:	00001097          	auipc	ra,0x1
    80000bcc:	0de080e7          	jalr	222(ra) # 80001ca6 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	2785                	addiw	a5,a5,1
    80000bd4:	dd3c                	sw	a5,120(a0)
}
    80000bd6:	60e2                	ld	ra,24(sp)
    80000bd8:	6442                	ld	s0,16(sp)
    80000bda:	64a2                	ld	s1,8(sp)
    80000bdc:	6105                	addi	sp,sp,32
    80000bde:	8082                	ret
    mycpu()->intena = old;
    80000be0:	00001097          	auipc	ra,0x1
    80000be4:	0c6080e7          	jalr	198(ra) # 80001ca6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000be8:	8085                	srli	s1,s1,0x1
    80000bea:	8885                	andi	s1,s1,1
    80000bec:	dd64                	sw	s1,124(a0)
    80000bee:	bfe9                	j	80000bc8 <push_off+0x24>

0000000080000bf0 <pop_off>:

void
pop_off(void)
{
    80000bf0:	1141                	addi	sp,sp,-16
    80000bf2:	e406                	sd	ra,8(sp)
    80000bf4:	e022                	sd	s0,0(sp)
    80000bf6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bf8:	00001097          	auipc	ra,0x1
    80000bfc:	0ae080e7          	jalr	174(ra) # 80001ca6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c00:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c04:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c06:	eb9d                	bnez	a5,80000c3c <pop_off+0x4c>
    panic("pop_off - interruptible");
  c->noff -= 1;
    80000c08:	5d3c                	lw	a5,120(a0)
    80000c0a:	37fd                	addiw	a5,a5,-1
    80000c0c:	0007871b          	sext.w	a4,a5
    80000c10:	dd3c                	sw	a5,120(a0)
  if(c->noff < 0)
    80000c12:	02074d63          	bltz	a4,80000c4c <pop_off+0x5c>
    panic("pop_off");
  if(c->noff == 0 && c->intena)
    80000c16:	ef19                	bnez	a4,80000c34 <pop_off+0x44>
    80000c18:	5d7c                	lw	a5,124(a0)
    80000c1a:	cf89                	beqz	a5,80000c34 <pop_off+0x44>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000c1c:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000c20:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000c24:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c28:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c2c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c30:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c34:	60a2                	ld	ra,8(sp)
    80000c36:	6402                	ld	s0,0(sp)
    80000c38:	0141                	addi	sp,sp,16
    80000c3a:	8082                	ret
    panic("pop_off - interruptible");
    80000c3c:	00007517          	auipc	a0,0x7
    80000c40:	61c50513          	addi	a0,a0,1564 # 80008258 <userret+0x1c8>
    80000c44:	00000097          	auipc	ra,0x0
    80000c48:	904080e7          	jalr	-1788(ra) # 80000548 <panic>
    panic("pop_off");
    80000c4c:	00007517          	auipc	a0,0x7
    80000c50:	62450513          	addi	a0,a0,1572 # 80008270 <userret+0x1e0>
    80000c54:	00000097          	auipc	ra,0x0
    80000c58:	8f4080e7          	jalr	-1804(ra) # 80000548 <panic>

0000000080000c5c <holding>:
{
    80000c5c:	1101                	addi	sp,sp,-32
    80000c5e:	ec06                	sd	ra,24(sp)
    80000c60:	e822                	sd	s0,16(sp)
    80000c62:	e426                	sd	s1,8(sp)
    80000c64:	1000                	addi	s0,sp,32
    80000c66:	84aa                	mv	s1,a0
  push_off();
    80000c68:	00000097          	auipc	ra,0x0
    80000c6c:	f3c080e7          	jalr	-196(ra) # 80000ba4 <push_off>
  r = (lk->locked && lk->cpu == mycpu());
    80000c70:	409c                	lw	a5,0(s1)
    80000c72:	ef81                	bnez	a5,80000c8a <holding+0x2e>
    80000c74:	4481                	li	s1,0
  pop_off();
    80000c76:	00000097          	auipc	ra,0x0
    80000c7a:	f7a080e7          	jalr	-134(ra) # 80000bf0 <pop_off>
}
    80000c7e:	8526                	mv	a0,s1
    80000c80:	60e2                	ld	ra,24(sp)
    80000c82:	6442                	ld	s0,16(sp)
    80000c84:	64a2                	ld	s1,8(sp)
    80000c86:	6105                	addi	sp,sp,32
    80000c88:	8082                	ret
  r = (lk->locked && lk->cpu == mycpu());
    80000c8a:	6884                	ld	s1,16(s1)
    80000c8c:	00001097          	auipc	ra,0x1
    80000c90:	01a080e7          	jalr	26(ra) # 80001ca6 <mycpu>
    80000c94:	8c89                	sub	s1,s1,a0
    80000c96:	0014b493          	seqz	s1,s1
    80000c9a:	bff1                	j	80000c76 <holding+0x1a>

0000000080000c9c <acquire>:
{
    80000c9c:	1101                	addi	sp,sp,-32
    80000c9e:	ec06                	sd	ra,24(sp)
    80000ca0:	e822                	sd	s0,16(sp)
    80000ca2:	e426                	sd	s1,8(sp)
    80000ca4:	1000                	addi	s0,sp,32
    80000ca6:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	efc080e7          	jalr	-260(ra) # 80000ba4 <push_off>
  if(holding(lk))
    80000cb0:	8526                	mv	a0,s1
    80000cb2:	00000097          	auipc	ra,0x0
    80000cb6:	faa080e7          	jalr	-86(ra) # 80000c5c <holding>
    80000cba:	e911                	bnez	a0,80000cce <acquire+0x32>
  __sync_fetch_and_add(&(lk->n), 1);
    80000cbc:	4785                	li	a5,1
    80000cbe:	01848713          	addi	a4,s1,24
    80000cc2:	0f50000f          	fence	iorw,ow
    80000cc6:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000cca:	4705                	li	a4,1
    80000ccc:	a839                	j	80000cea <acquire+0x4e>
    panic("acquire");
    80000cce:	00007517          	auipc	a0,0x7
    80000cd2:	5aa50513          	addi	a0,a0,1450 # 80008278 <userret+0x1e8>
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	872080e7          	jalr	-1934(ra) # 80000548 <panic>
     __sync_fetch_and_add(&lk->nts, 1);
    80000cde:	01c48793          	addi	a5,s1,28
    80000ce2:	0f50000f          	fence	iorw,ow
    80000ce6:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000cea:	87ba                	mv	a5,a4
    80000cec:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cf0:	2781                	sext.w	a5,a5
    80000cf2:	f7f5                	bnez	a5,80000cde <acquire+0x42>
  __sync_synchronize();
    80000cf4:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cf8:	00001097          	auipc	ra,0x1
    80000cfc:	fae080e7          	jalr	-82(ra) # 80001ca6 <mycpu>
    80000d00:	e888                	sd	a0,16(s1)
}
    80000d02:	60e2                	ld	ra,24(sp)
    80000d04:	6442                	ld	s0,16(sp)
    80000d06:	64a2                	ld	s1,8(sp)
    80000d08:	6105                	addi	sp,sp,32
    80000d0a:	8082                	ret

0000000080000d0c <release>:
{
    80000d0c:	1101                	addi	sp,sp,-32
    80000d0e:	ec06                	sd	ra,24(sp)
    80000d10:	e822                	sd	s0,16(sp)
    80000d12:	e426                	sd	s1,8(sp)
    80000d14:	1000                	addi	s0,sp,32
    80000d16:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d18:	00000097          	auipc	ra,0x0
    80000d1c:	f44080e7          	jalr	-188(ra) # 80000c5c <holding>
    80000d20:	c115                	beqz	a0,80000d44 <release+0x38>
  lk->cpu = 0;
    80000d22:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d26:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d2a:	0f50000f          	fence	iorw,ow
    80000d2e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d32:	00000097          	auipc	ra,0x0
    80000d36:	ebe080e7          	jalr	-322(ra) # 80000bf0 <pop_off>
}
    80000d3a:	60e2                	ld	ra,24(sp)
    80000d3c:	6442                	ld	s0,16(sp)
    80000d3e:	64a2                	ld	s1,8(sp)
    80000d40:	6105                	addi	sp,sp,32
    80000d42:	8082                	ret
    panic("release");
    80000d44:	00007517          	auipc	a0,0x7
    80000d48:	53c50513          	addi	a0,a0,1340 # 80008280 <userret+0x1f0>
    80000d4c:	fffff097          	auipc	ra,0xfffff
    80000d50:	7fc080e7          	jalr	2044(ra) # 80000548 <panic>

0000000080000d54 <print_lock>:

void
print_lock(struct spinlock *lk)
{
  if(lk->n > 0) 
    80000d54:	4d14                	lw	a3,24(a0)
    80000d56:	e291                	bnez	a3,80000d5a <print_lock+0x6>
    80000d58:	8082                	ret
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
    printf("lock: %s: #fetch-and-add %d #acquire() %d\n", lk->name, lk->nts, lk->n);
    80000d62:	4d50                	lw	a2,28(a0)
    80000d64:	650c                	ld	a1,8(a0)
    80000d66:	00007517          	auipc	a0,0x7
    80000d6a:	52250513          	addi	a0,a0,1314 # 80008288 <userret+0x1f8>
    80000d6e:	00000097          	auipc	ra,0x0
    80000d72:	834080e7          	jalr	-1996(ra) # 800005a2 <printf>
}
    80000d76:	60a2                	ld	ra,8(sp)
    80000d78:	6402                	ld	s0,0(sp)
    80000d7a:	0141                	addi	sp,sp,16
    80000d7c:	8082                	ret

0000000080000d7e <sys_ntas>:

uint64
sys_ntas(void)
{
    80000d7e:	711d                	addi	sp,sp,-96
    80000d80:	ec86                	sd	ra,88(sp)
    80000d82:	e8a2                	sd	s0,80(sp)
    80000d84:	e4a6                	sd	s1,72(sp)
    80000d86:	e0ca                	sd	s2,64(sp)
    80000d88:	fc4e                	sd	s3,56(sp)
    80000d8a:	f852                	sd	s4,48(sp)
    80000d8c:	f456                	sd	s5,40(sp)
    80000d8e:	f05a                	sd	s6,32(sp)
    80000d90:	ec5e                	sd	s7,24(sp)
    80000d92:	e862                	sd	s8,16(sp)
    80000d94:	1080                	addi	s0,sp,96
  int zero = 0;
    80000d96:	fa042623          	sw	zero,-84(s0)
  int tot = 0;
  
  if (argint(0, &zero) < 0) {
    80000d9a:	fac40593          	addi	a1,s0,-84
    80000d9e:	4501                	li	a0,0
    80000da0:	00002097          	auipc	ra,0x2
    80000da4:	0fc080e7          	jalr	252(ra) # 80002e9c <argint>
    80000da8:	14054b63          	bltz	a0,80000efe <sys_ntas+0x180>
    return -1;
  }
  if(zero == 0) {
    80000dac:	fac42783          	lw	a5,-84(s0)
    80000db0:	e39d                	bnez	a5,80000dd6 <sys_ntas+0x58>
    80000db2:	0001a797          	auipc	a5,0x1a
    80000db6:	b2678793          	addi	a5,a5,-1242 # 8001a8d8 <locks>
    80000dba:	0001c697          	auipc	a3,0x1c
    80000dbe:	a5e68693          	addi	a3,a3,-1442 # 8001c818 <pid_lock>
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    80000dc2:	6398                	ld	a4,0(a5)
    80000dc4:	12070f63          	beqz	a4,80000f02 <sys_ntas+0x184>
        break;
      locks[i]->nts = 0;
    80000dc8:	00072e23          	sw	zero,28(a4)
    for(int i = 0; i < NLOCK; i++) {
    80000dcc:	07a1                	addi	a5,a5,8
    80000dce:	fed79ae3          	bne	a5,a3,80000dc2 <sys_ntas+0x44>
    }
    return 0;
    80000dd2:	4501                	li	a0,0
    80000dd4:	aa09                	j	80000ee6 <sys_ntas+0x168>
  }

  printf("=== lock kmem/bcache stats\n");
    80000dd6:	00007517          	auipc	a0,0x7
    80000dda:	4e250513          	addi	a0,a0,1250 # 800082b8 <userret+0x228>
    80000dde:	fffff097          	auipc	ra,0xfffff
    80000de2:	7c4080e7          	jalr	1988(ra) # 800005a2 <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000de6:	0001ab17          	auipc	s6,0x1a
    80000dea:	af2b0b13          	addi	s6,s6,-1294 # 8001a8d8 <locks>
    80000dee:	0001cb97          	auipc	s7,0x1c
    80000df2:	a2ab8b93          	addi	s7,s7,-1494 # 8001c818 <pid_lock>
  printf("=== lock kmem/bcache stats\n");
    80000df6:	84da                	mv	s1,s6
  int tot = 0;
    80000df8:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000dfa:	00007a17          	auipc	s4,0x7
    80000dfe:	4dea0a13          	addi	s4,s4,1246 # 800082d8 <userret+0x248>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000e02:	00007c17          	auipc	s8,0x7
    80000e06:	43ec0c13          	addi	s8,s8,1086 # 80008240 <userret+0x1b0>
    80000e0a:	a829                	j	80000e24 <sys_ntas+0xa6>
      tot += locks[i]->nts;
    80000e0c:	00093503          	ld	a0,0(s2)
    80000e10:	4d5c                	lw	a5,28(a0)
    80000e12:	013789bb          	addw	s3,a5,s3
      print_lock(locks[i]);
    80000e16:	00000097          	auipc	ra,0x0
    80000e1a:	f3e080e7          	jalr	-194(ra) # 80000d54 <print_lock>
  for(int i = 0; i < NLOCK; i++) {
    80000e1e:	04a1                	addi	s1,s1,8
    80000e20:	05748763          	beq	s1,s7,80000e6e <sys_ntas+0xf0>
    if(locks[i] == 0)
    80000e24:	8926                	mv	s2,s1
    80000e26:	609c                	ld	a5,0(s1)
    80000e28:	c3b9                	beqz	a5,80000e6e <sys_ntas+0xf0>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000e2a:	0087ba83          	ld	s5,8(a5)
    80000e2e:	8552                	mv	a0,s4
    80000e30:	00000097          	auipc	ra,0x0
    80000e34:	25a080e7          	jalr	602(ra) # 8000108a <strlen>
    80000e38:	0005061b          	sext.w	a2,a0
    80000e3c:	85d2                	mv	a1,s4
    80000e3e:	8556                	mv	a0,s5
    80000e40:	00000097          	auipc	ra,0x0
    80000e44:	19e080e7          	jalr	414(ra) # 80000fde <strncmp>
    80000e48:	d171                	beqz	a0,80000e0c <sys_ntas+0x8e>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000e4a:	609c                	ld	a5,0(s1)
    80000e4c:	0087ba83          	ld	s5,8(a5)
    80000e50:	8562                	mv	a0,s8
    80000e52:	00000097          	auipc	ra,0x0
    80000e56:	238080e7          	jalr	568(ra) # 8000108a <strlen>
    80000e5a:	0005061b          	sext.w	a2,a0
    80000e5e:	85e2                	mv	a1,s8
    80000e60:	8556                	mv	a0,s5
    80000e62:	00000097          	auipc	ra,0x0
    80000e66:	17c080e7          	jalr	380(ra) # 80000fde <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000e6a:	f955                	bnez	a0,80000e1e <sys_ntas+0xa0>
    80000e6c:	b745                	j	80000e0c <sys_ntas+0x8e>
    }
  }

  printf("=== top 5 contended locks:\n");
    80000e6e:	00007517          	auipc	a0,0x7
    80000e72:	47250513          	addi	a0,a0,1138 # 800082e0 <userret+0x250>
    80000e76:	fffff097          	auipc	ra,0xfffff
    80000e7a:	72c080e7          	jalr	1836(ra) # 800005a2 <printf>
    80000e7e:	4a15                	li	s4,5
  int last = 100000000;
    80000e80:	05f5e537          	lui	a0,0x5f5e
    80000e84:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t= 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    80000e88:	4a81                	li	s5,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000e8a:	0001a497          	auipc	s1,0x1a
    80000e8e:	a4e48493          	addi	s1,s1,-1458 # 8001a8d8 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80000e92:	3e800913          	li	s2,1000
    80000e96:	a091                	j	80000eda <sys_ntas+0x15c>
    80000e98:	2705                	addiw	a4,a4,1
    80000e9a:	06a1                	addi	a3,a3,8
    80000e9c:	03270063          	beq	a4,s2,80000ebc <sys_ntas+0x13e>
      if(locks[i] == 0)
    80000ea0:	629c                	ld	a5,0(a3)
    80000ea2:	cf89                	beqz	a5,80000ebc <sys_ntas+0x13e>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000ea4:	4fd0                	lw	a2,28(a5)
    80000ea6:	00359793          	slli	a5,a1,0x3
    80000eaa:	97a6                	add	a5,a5,s1
    80000eac:	639c                	ld	a5,0(a5)
    80000eae:	4fdc                	lw	a5,28(a5)
    80000eb0:	fec7f4e3          	bgeu	a5,a2,80000e98 <sys_ntas+0x11a>
    80000eb4:	fea672e3          	bgeu	a2,a0,80000e98 <sys_ntas+0x11a>
    80000eb8:	85ba                	mv	a1,a4
    80000eba:	bff9                	j	80000e98 <sys_ntas+0x11a>
        top = i;
      }
    }
    print_lock(locks[top]);
    80000ebc:	058e                	slli	a1,a1,0x3
    80000ebe:	00b48bb3          	add	s7,s1,a1
    80000ec2:	000bb503          	ld	a0,0(s7)
    80000ec6:	00000097          	auipc	ra,0x0
    80000eca:	e8e080e7          	jalr	-370(ra) # 80000d54 <print_lock>
    last = locks[top]->nts;
    80000ece:	000bb783          	ld	a5,0(s7)
    80000ed2:	4fc8                	lw	a0,28(a5)
  for(int t= 0; t < 5; t++) {
    80000ed4:	3a7d                	addiw	s4,s4,-1
    80000ed6:	000a0763          	beqz	s4,80000ee4 <sys_ntas+0x166>
  int tot = 0;
    80000eda:	86da                	mv	a3,s6
    for(int i = 0; i < NLOCK; i++) {
    80000edc:	8756                	mv	a4,s5
    int top = 0;
    80000ede:	85d6                	mv	a1,s5
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000ee0:	2501                	sext.w	a0,a0
    80000ee2:	bf7d                	j	80000ea0 <sys_ntas+0x122>
  }
  return tot;
    80000ee4:	854e                	mv	a0,s3
}
    80000ee6:	60e6                	ld	ra,88(sp)
    80000ee8:	6446                	ld	s0,80(sp)
    80000eea:	64a6                	ld	s1,72(sp)
    80000eec:	6906                	ld	s2,64(sp)
    80000eee:	79e2                	ld	s3,56(sp)
    80000ef0:	7a42                	ld	s4,48(sp)
    80000ef2:	7aa2                	ld	s5,40(sp)
    80000ef4:	7b02                	ld	s6,32(sp)
    80000ef6:	6be2                	ld	s7,24(sp)
    80000ef8:	6c42                	ld	s8,16(sp)
    80000efa:	6125                	addi	sp,sp,96
    80000efc:	8082                	ret
    return -1;
    80000efe:	557d                	li	a0,-1
    80000f00:	b7dd                	j	80000ee6 <sys_ntas+0x168>
    return 0;
    80000f02:	4501                	li	a0,0
    80000f04:	b7cd                	j	80000ee6 <sys_ntas+0x168>

0000000080000f06 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000f06:	1141                	addi	sp,sp,-16
    80000f08:	e422                	sd	s0,8(sp)
    80000f0a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000f0c:	ca19                	beqz	a2,80000f22 <memset+0x1c>
    80000f0e:	87aa                	mv	a5,a0
    80000f10:	1602                	slli	a2,a2,0x20
    80000f12:	9201                	srli	a2,a2,0x20
    80000f14:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000f18:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000f1c:	0785                	addi	a5,a5,1
    80000f1e:	fee79de3          	bne	a5,a4,80000f18 <memset+0x12>
  }
  return dst;
}
    80000f22:	6422                	ld	s0,8(sp)
    80000f24:	0141                	addi	sp,sp,16
    80000f26:	8082                	ret

0000000080000f28 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000f28:	1141                	addi	sp,sp,-16
    80000f2a:	e422                	sd	s0,8(sp)
    80000f2c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000f2e:	ca05                	beqz	a2,80000f5e <memcmp+0x36>
    80000f30:	fff6069b          	addiw	a3,a2,-1
    80000f34:	1682                	slli	a3,a3,0x20
    80000f36:	9281                	srli	a3,a3,0x20
    80000f38:	0685                	addi	a3,a3,1
    80000f3a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000f3c:	00054783          	lbu	a5,0(a0)
    80000f40:	0005c703          	lbu	a4,0(a1)
    80000f44:	00e79863          	bne	a5,a4,80000f54 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000f48:	0505                	addi	a0,a0,1
    80000f4a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000f4c:	fed518e3          	bne	a0,a3,80000f3c <memcmp+0x14>
  }

  return 0;
    80000f50:	4501                	li	a0,0
    80000f52:	a019                	j	80000f58 <memcmp+0x30>
      return *s1 - *s2;
    80000f54:	40e7853b          	subw	a0,a5,a4
}
    80000f58:	6422                	ld	s0,8(sp)
    80000f5a:	0141                	addi	sp,sp,16
    80000f5c:	8082                	ret
  return 0;
    80000f5e:	4501                	li	a0,0
    80000f60:	bfe5                	j	80000f58 <memcmp+0x30>

0000000080000f62 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000f62:	1141                	addi	sp,sp,-16
    80000f64:	e422                	sd	s0,8(sp)
    80000f66:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000f68:	02a5e563          	bltu	a1,a0,80000f92 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f6c:	fff6069b          	addiw	a3,a2,-1
    80000f70:	ce11                	beqz	a2,80000f8c <memmove+0x2a>
    80000f72:	1682                	slli	a3,a3,0x20
    80000f74:	9281                	srli	a3,a3,0x20
    80000f76:	0685                	addi	a3,a3,1
    80000f78:	96ae                	add	a3,a3,a1
    80000f7a:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000f7c:	0585                	addi	a1,a1,1
    80000f7e:	0785                	addi	a5,a5,1
    80000f80:	fff5c703          	lbu	a4,-1(a1)
    80000f84:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000f88:	fed59ae3          	bne	a1,a3,80000f7c <memmove+0x1a>

  return dst;
}
    80000f8c:	6422                	ld	s0,8(sp)
    80000f8e:	0141                	addi	sp,sp,16
    80000f90:	8082                	ret
  if(s < d && s + n > d){
    80000f92:	02061713          	slli	a4,a2,0x20
    80000f96:	9301                	srli	a4,a4,0x20
    80000f98:	00e587b3          	add	a5,a1,a4
    80000f9c:	fcf578e3          	bgeu	a0,a5,80000f6c <memmove+0xa>
    d += n;
    80000fa0:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000fa2:	fff6069b          	addiw	a3,a2,-1
    80000fa6:	d27d                	beqz	a2,80000f8c <memmove+0x2a>
    80000fa8:	02069613          	slli	a2,a3,0x20
    80000fac:	9201                	srli	a2,a2,0x20
    80000fae:	fff64613          	not	a2,a2
    80000fb2:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000fb4:	17fd                	addi	a5,a5,-1
    80000fb6:	177d                	addi	a4,a4,-1
    80000fb8:	0007c683          	lbu	a3,0(a5)
    80000fbc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000fc0:	fef61ae3          	bne	a2,a5,80000fb4 <memmove+0x52>
    80000fc4:	b7e1                	j	80000f8c <memmove+0x2a>

0000000080000fc6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000fc6:	1141                	addi	sp,sp,-16
    80000fc8:	e406                	sd	ra,8(sp)
    80000fca:	e022                	sd	s0,0(sp)
    80000fcc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000fce:	00000097          	auipc	ra,0x0
    80000fd2:	f94080e7          	jalr	-108(ra) # 80000f62 <memmove>
}
    80000fd6:	60a2                	ld	ra,8(sp)
    80000fd8:	6402                	ld	s0,0(sp)
    80000fda:	0141                	addi	sp,sp,16
    80000fdc:	8082                	ret

0000000080000fde <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000fde:	1141                	addi	sp,sp,-16
    80000fe0:	e422                	sd	s0,8(sp)
    80000fe2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000fe4:	ce11                	beqz	a2,80001000 <strncmp+0x22>
    80000fe6:	00054783          	lbu	a5,0(a0)
    80000fea:	cf89                	beqz	a5,80001004 <strncmp+0x26>
    80000fec:	0005c703          	lbu	a4,0(a1)
    80000ff0:	00f71a63          	bne	a4,a5,80001004 <strncmp+0x26>
    n--, p++, q++;
    80000ff4:	367d                	addiw	a2,a2,-1
    80000ff6:	0505                	addi	a0,a0,1
    80000ff8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ffa:	f675                	bnez	a2,80000fe6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ffc:	4501                	li	a0,0
    80000ffe:	a809                	j	80001010 <strncmp+0x32>
    80001000:	4501                	li	a0,0
    80001002:	a039                	j	80001010 <strncmp+0x32>
  if(n == 0)
    80001004:	ca09                	beqz	a2,80001016 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80001006:	00054503          	lbu	a0,0(a0)
    8000100a:	0005c783          	lbu	a5,0(a1)
    8000100e:	9d1d                	subw	a0,a0,a5
}
    80001010:	6422                	ld	s0,8(sp)
    80001012:	0141                	addi	sp,sp,16
    80001014:	8082                	ret
    return 0;
    80001016:	4501                	li	a0,0
    80001018:	bfe5                	j	80001010 <strncmp+0x32>

000000008000101a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000101a:	1141                	addi	sp,sp,-16
    8000101c:	e422                	sd	s0,8(sp)
    8000101e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80001020:	872a                	mv	a4,a0
    80001022:	8832                	mv	a6,a2
    80001024:	367d                	addiw	a2,a2,-1
    80001026:	01005963          	blez	a6,80001038 <strncpy+0x1e>
    8000102a:	0705                	addi	a4,a4,1
    8000102c:	0005c783          	lbu	a5,0(a1)
    80001030:	fef70fa3          	sb	a5,-1(a4)
    80001034:	0585                	addi	a1,a1,1
    80001036:	f7f5                	bnez	a5,80001022 <strncpy+0x8>
    ;
  while(n-- > 0)
    80001038:	86ba                	mv	a3,a4
    8000103a:	00c05c63          	blez	a2,80001052 <strncpy+0x38>
    *s++ = 0;
    8000103e:	0685                	addi	a3,a3,1
    80001040:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80001044:	fff6c793          	not	a5,a3
    80001048:	9fb9                	addw	a5,a5,a4
    8000104a:	010787bb          	addw	a5,a5,a6
    8000104e:	fef048e3          	bgtz	a5,8000103e <strncpy+0x24>
  return os;
}
    80001052:	6422                	ld	s0,8(sp)
    80001054:	0141                	addi	sp,sp,16
    80001056:	8082                	ret

0000000080001058 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80001058:	1141                	addi	sp,sp,-16
    8000105a:	e422                	sd	s0,8(sp)
    8000105c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000105e:	02c05363          	blez	a2,80001084 <safestrcpy+0x2c>
    80001062:	fff6069b          	addiw	a3,a2,-1
    80001066:	1682                	slli	a3,a3,0x20
    80001068:	9281                	srli	a3,a3,0x20
    8000106a:	96ae                	add	a3,a3,a1
    8000106c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000106e:	00d58963          	beq	a1,a3,80001080 <safestrcpy+0x28>
    80001072:	0585                	addi	a1,a1,1
    80001074:	0785                	addi	a5,a5,1
    80001076:	fff5c703          	lbu	a4,-1(a1)
    8000107a:	fee78fa3          	sb	a4,-1(a5)
    8000107e:	fb65                	bnez	a4,8000106e <safestrcpy+0x16>
    ;
  *s = 0;
    80001080:	00078023          	sb	zero,0(a5)
  return os;
}
    80001084:	6422                	ld	s0,8(sp)
    80001086:	0141                	addi	sp,sp,16
    80001088:	8082                	ret

000000008000108a <strlen>:

int
strlen(const char *s)
{
    8000108a:	1141                	addi	sp,sp,-16
    8000108c:	e422                	sd	s0,8(sp)
    8000108e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001090:	00054783          	lbu	a5,0(a0)
    80001094:	cf91                	beqz	a5,800010b0 <strlen+0x26>
    80001096:	0505                	addi	a0,a0,1
    80001098:	87aa                	mv	a5,a0
    8000109a:	4685                	li	a3,1
    8000109c:	9e89                	subw	a3,a3,a0
    8000109e:	00f6853b          	addw	a0,a3,a5
    800010a2:	0785                	addi	a5,a5,1
    800010a4:	fff7c703          	lbu	a4,-1(a5)
    800010a8:	fb7d                	bnez	a4,8000109e <strlen+0x14>
    ;
  return n;
}
    800010aa:	6422                	ld	s0,8(sp)
    800010ac:	0141                	addi	sp,sp,16
    800010ae:	8082                	ret
  for(n = 0; s[n]; n++)
    800010b0:	4501                	li	a0,0
    800010b2:	bfe5                	j	800010aa <strlen+0x20>

00000000800010b4 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800010b4:	1141                	addi	sp,sp,-16
    800010b6:	e406                	sd	ra,8(sp)
    800010b8:	e022                	sd	s0,0(sp)
    800010ba:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800010bc:	00001097          	auipc	ra,0x1
    800010c0:	bda080e7          	jalr	-1062(ra) # 80001c96 <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800010c4:	00033717          	auipc	a4,0x33
    800010c8:	f6470713          	addi	a4,a4,-156 # 80034028 <started>
  if(cpuid() == 0){
    800010cc:	c139                	beqz	a0,80001112 <main+0x5e>
    while(started == 0)
    800010ce:	431c                	lw	a5,0(a4)
    800010d0:	2781                	sext.w	a5,a5
    800010d2:	dff5                	beqz	a5,800010ce <main+0x1a>
      ;
    __sync_synchronize();
    800010d4:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800010d8:	00001097          	auipc	ra,0x1
    800010dc:	bbe080e7          	jalr	-1090(ra) # 80001c96 <cpuid>
    800010e0:	85aa                	mv	a1,a0
    800010e2:	00007517          	auipc	a0,0x7
    800010e6:	23650513          	addi	a0,a0,566 # 80008318 <userret+0x288>
    800010ea:	fffff097          	auipc	ra,0xfffff
    800010ee:	4b8080e7          	jalr	1208(ra) # 800005a2 <printf>
    kvminithart();    // turn on paging
    800010f2:	00000097          	auipc	ra,0x0
    800010f6:	144080e7          	jalr	324(ra) # 80001236 <kvminithart>
    trapinithart();   // install kernel trap vector
    800010fa:	00001097          	auipc	ra,0x1
    800010fe:	7e4080e7          	jalr	2020(ra) # 800028de <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001102:	00005097          	auipc	ra,0x5
    80001106:	1be080e7          	jalr	446(ra) # 800062c0 <plicinithart>
  }

  scheduler();        
    8000110a:	00001097          	auipc	ra,0x1
    8000110e:	096080e7          	jalr	150(ra) # 800021a0 <scheduler>
    consoleinit();
    80001112:	fffff097          	auipc	ra,0xfffff
    80001116:	348080e7          	jalr	840(ra) # 8000045a <consoleinit>
    printfinit();
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	668080e7          	jalr	1640(ra) # 80000782 <printfinit>
    printf("\n");
    80001122:	00007517          	auipc	a0,0x7
    80001126:	4ae50513          	addi	a0,a0,1198 # 800085d0 <userret+0x540>
    8000112a:	fffff097          	auipc	ra,0xfffff
    8000112e:	478080e7          	jalr	1144(ra) # 800005a2 <printf>
    printf("xv6 kernel is booting\n");
    80001132:	00007517          	auipc	a0,0x7
    80001136:	1ce50513          	addi	a0,a0,462 # 80008300 <userret+0x270>
    8000113a:	fffff097          	auipc	ra,0xfffff
    8000113e:	468080e7          	jalr	1128(ra) # 800005a2 <printf>
    printf("\n");
    80001142:	00007517          	auipc	a0,0x7
    80001146:	48e50513          	addi	a0,a0,1166 # 800085d0 <userret+0x540>
    8000114a:	fffff097          	auipc	ra,0xfffff
    8000114e:	458080e7          	jalr	1112(ra) # 800005a2 <printf>
    kinit();         // physical page allocator
    80001152:	00000097          	auipc	ra,0x0
    80001156:	930080e7          	jalr	-1744(ra) # 80000a82 <kinit>
    kvminit();       // create kernel page table
    8000115a:	00000097          	auipc	ra,0x0
    8000115e:	312080e7          	jalr	786(ra) # 8000146c <kvminit>
    kvminithart();   // turn on paging
    80001162:	00000097          	auipc	ra,0x0
    80001166:	0d4080e7          	jalr	212(ra) # 80001236 <kvminithart>
    procinit();      // process table
    8000116a:	00001097          	auipc	ra,0x1
    8000116e:	a5c080e7          	jalr	-1444(ra) # 80001bc6 <procinit>
    trapinit();      // trap vectors
    80001172:	00001097          	auipc	ra,0x1
    80001176:	744080e7          	jalr	1860(ra) # 800028b6 <trapinit>
    trapinithart();  // install kernel trap vector
    8000117a:	00001097          	auipc	ra,0x1
    8000117e:	764080e7          	jalr	1892(ra) # 800028de <trapinithart>
    plicinit();      // set up interrupt controller
    80001182:	00005097          	auipc	ra,0x5
    80001186:	128080e7          	jalr	296(ra) # 800062aa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000118a:	00005097          	auipc	ra,0x5
    8000118e:	136080e7          	jalr	310(ra) # 800062c0 <plicinithart>
    binit();         // buffer cache
    80001192:	00002097          	auipc	ra,0x2
    80001196:	fea080e7          	jalr	-22(ra) # 8000317c <binit>
    iinit();         // inode cache
    8000119a:	00002097          	auipc	ra,0x2
    8000119e:	67e080e7          	jalr	1662(ra) # 80003818 <iinit>
    fileinit();      // file table
    800011a2:	00004097          	auipc	ra,0x4
    800011a6:	858080e7          	jalr	-1960(ra) # 800049fa <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    800011aa:	4501                	li	a0,0
    800011ac:	00005097          	auipc	ra,0x5
    800011b0:	248080e7          	jalr	584(ra) # 800063f4 <virtio_disk_init>
    userinit();      // first user process
    800011b4:	00001097          	auipc	ra,0x1
    800011b8:	d82080e7          	jalr	-638(ra) # 80001f36 <userinit>
    __sync_synchronize();
    800011bc:	0ff0000f          	fence
    started = 1;
    800011c0:	4785                	li	a5,1
    800011c2:	00033717          	auipc	a4,0x33
    800011c6:	e6f72323          	sw	a5,-410(a4) # 80034028 <started>
    800011ca:	b781                	j	8000110a <main+0x56>

00000000800011cc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    800011cc:	7179                	addi	sp,sp,-48
    800011ce:	f406                	sd	ra,40(sp)
    800011d0:	f022                	sd	s0,32(sp)
    800011d2:	ec26                	sd	s1,24(sp)
    800011d4:	e84a                	sd	s2,16(sp)
    800011d6:	e44e                	sd	s3,8(sp)
    800011d8:	e052                	sd	s4,0(sp)
    800011da:	1800                	addi	s0,sp,48
    800011dc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800011de:	84aa                	mv	s1,a0
    800011e0:	6905                	lui	s2,0x1
    800011e2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800011e4:	4985                	li	s3,1
    800011e6:	a821                	j	800011fe <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800011e8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800011ea:	0532                	slli	a0,a0,0xc
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	fe0080e7          	jalr	-32(ra) # 800011cc <freewalk>
      pagetable[i] = 0;
    800011f4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800011f8:	04a1                	addi	s1,s1,8
    800011fa:	03248163          	beq	s1,s2,8000121c <freewalk+0x50>
    pte_t pte = pagetable[i];
    800011fe:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001200:	00f57793          	andi	a5,a0,15
    80001204:	ff3782e3          	beq	a5,s3,800011e8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001208:	8905                	andi	a0,a0,1
    8000120a:	d57d                	beqz	a0,800011f8 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000120c:	00007517          	auipc	a0,0x7
    80001210:	12450513          	addi	a0,a0,292 # 80008330 <userret+0x2a0>
    80001214:	fffff097          	auipc	ra,0xfffff
    80001218:	334080e7          	jalr	820(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    8000121c:	8552                	mv	a0,s4
    8000121e:	fffff097          	auipc	ra,0xfffff
    80001222:	732080e7          	jalr	1842(ra) # 80000950 <kfree>
}
    80001226:	70a2                	ld	ra,40(sp)
    80001228:	7402                	ld	s0,32(sp)
    8000122a:	64e2                	ld	s1,24(sp)
    8000122c:	6942                	ld	s2,16(sp)
    8000122e:	69a2                	ld	s3,8(sp)
    80001230:	6a02                	ld	s4,0(sp)
    80001232:	6145                	addi	sp,sp,48
    80001234:	8082                	ret

0000000080001236 <kvminithart>:
{
    80001236:	1141                	addi	sp,sp,-16
    80001238:	e422                	sd	s0,8(sp)
    8000123a:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000123c:	00033797          	auipc	a5,0x33
    80001240:	df47b783          	ld	a5,-524(a5) # 80034030 <kernel_pagetable>
    80001244:	83b1                	srli	a5,a5,0xc
    80001246:	577d                	li	a4,-1
    80001248:	177e                	slli	a4,a4,0x3f
    8000124a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000124c:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001250:	12000073          	sfence.vma
}
    80001254:	6422                	ld	s0,8(sp)
    80001256:	0141                	addi	sp,sp,16
    80001258:	8082                	ret

000000008000125a <walk>:
{
    8000125a:	7139                	addi	sp,sp,-64
    8000125c:	fc06                	sd	ra,56(sp)
    8000125e:	f822                	sd	s0,48(sp)
    80001260:	f426                	sd	s1,40(sp)
    80001262:	f04a                	sd	s2,32(sp)
    80001264:	ec4e                	sd	s3,24(sp)
    80001266:	e852                	sd	s4,16(sp)
    80001268:	e456                	sd	s5,8(sp)
    8000126a:	e05a                	sd	s6,0(sp)
    8000126c:	0080                	addi	s0,sp,64
    8000126e:	84aa                	mv	s1,a0
    80001270:	89ae                	mv	s3,a1
    80001272:	8ab2                	mv	s5,a2
  if(va >= MAXVA){
    80001274:	57fd                	li	a5,-1
    80001276:	83e9                	srli	a5,a5,0x1a
    80001278:	4a79                	li	s4,30
  for(int level = 2; level > 0; level--) {
    8000127a:	4b31                	li	s6,12
  if(va >= MAXVA){
    8000127c:	04b7f263          	bgeu	a5,a1,800012c0 <walk+0x66>
    panic("walk");
    80001280:	00007517          	auipc	a0,0x7
    80001284:	0c050513          	addi	a0,a0,192 # 80008340 <userret+0x2b0>
    80001288:	fffff097          	auipc	ra,0xfffff
    8000128c:	2c0080e7          	jalr	704(ra) # 80000548 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001290:	060a8663          	beqz	s5,800012fc <walk+0xa2>
    80001294:	00000097          	auipc	ra,0x0
    80001298:	82a080e7          	jalr	-2006(ra) # 80000abe <kalloc>
    8000129c:	84aa                	mv	s1,a0
    8000129e:	c529                	beqz	a0,800012e8 <walk+0x8e>
      memset(pagetable, 0, PGSIZE);
    800012a0:	6605                	lui	a2,0x1
    800012a2:	4581                	li	a1,0
    800012a4:	00000097          	auipc	ra,0x0
    800012a8:	c62080e7          	jalr	-926(ra) # 80000f06 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800012ac:	00c4d793          	srli	a5,s1,0xc
    800012b0:	07aa                	slli	a5,a5,0xa
    800012b2:	0017e793          	ori	a5,a5,1
    800012b6:	00f93023          	sd	a5,0(s2) # 1000 <_entry-0x7ffff000>
  for(int level = 2; level > 0; level--) {
    800012ba:	3a5d                	addiw	s4,s4,-9
    800012bc:	036a0063          	beq	s4,s6,800012dc <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800012c0:	0149d933          	srl	s2,s3,s4
    800012c4:	1ff97913          	andi	s2,s2,511
    800012c8:	090e                	slli	s2,s2,0x3
    800012ca:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800012cc:	00093483          	ld	s1,0(s2)
    800012d0:	0014f793          	andi	a5,s1,1
    800012d4:	dfd5                	beqz	a5,80001290 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800012d6:	80a9                	srli	s1,s1,0xa
    800012d8:	04b2                	slli	s1,s1,0xc
    800012da:	b7c5                	j	800012ba <walk+0x60>
  return &pagetable[PX(0, va)];
    800012dc:	00c9d513          	srli	a0,s3,0xc
    800012e0:	1ff57513          	andi	a0,a0,511
    800012e4:	050e                	slli	a0,a0,0x3
    800012e6:	9526                	add	a0,a0,s1
}
    800012e8:	70e2                	ld	ra,56(sp)
    800012ea:	7442                	ld	s0,48(sp)
    800012ec:	74a2                	ld	s1,40(sp)
    800012ee:	7902                	ld	s2,32(sp)
    800012f0:	69e2                	ld	s3,24(sp)
    800012f2:	6a42                	ld	s4,16(sp)
    800012f4:	6aa2                	ld	s5,8(sp)
    800012f6:	6b02                	ld	s6,0(sp)
    800012f8:	6121                	addi	sp,sp,64
    800012fa:	8082                	ret
        return 0;
    800012fc:	4501                	li	a0,0
    800012fe:	b7ed                	j	800012e8 <walk+0x8e>

0000000080001300 <walkaddr>:
  if(va >= MAXVA)
    80001300:	57fd                	li	a5,-1
    80001302:	83e9                	srli	a5,a5,0x1a
    80001304:	00b7f463          	bgeu	a5,a1,8000130c <walkaddr+0xc>
    return 0;
    80001308:	4501                	li	a0,0
}
    8000130a:	8082                	ret
{
    8000130c:	1141                	addi	sp,sp,-16
    8000130e:	e406                	sd	ra,8(sp)
    80001310:	e022                	sd	s0,0(sp)
    80001312:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001314:	4601                	li	a2,0
    80001316:	00000097          	auipc	ra,0x0
    8000131a:	f44080e7          	jalr	-188(ra) # 8000125a <walk>
  if(pte == 0)
    8000131e:	c105                	beqz	a0,8000133e <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001320:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001322:	0117f693          	andi	a3,a5,17
    80001326:	4745                	li	a4,17
    return 0;
    80001328:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000132a:	00e68663          	beq	a3,a4,80001336 <walkaddr+0x36>
}
    8000132e:	60a2                	ld	ra,8(sp)
    80001330:	6402                	ld	s0,0(sp)
    80001332:	0141                	addi	sp,sp,16
    80001334:	8082                	ret
  pa = PTE2PA(*pte);
    80001336:	00a7d513          	srli	a0,a5,0xa
    8000133a:	0532                	slli	a0,a0,0xc
  return pa;
    8000133c:	bfcd                	j	8000132e <walkaddr+0x2e>
    return 0;
    8000133e:	4501                	li	a0,0
    80001340:	b7fd                	j	8000132e <walkaddr+0x2e>

0000000080001342 <kvmpa>:
{
    80001342:	1101                	addi	sp,sp,-32
    80001344:	ec06                	sd	ra,24(sp)
    80001346:	e822                	sd	s0,16(sp)
    80001348:	e426                	sd	s1,8(sp)
    8000134a:	1000                	addi	s0,sp,32
    8000134c:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    8000134e:	1552                	slli	a0,a0,0x34
    80001350:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    80001354:	4601                	li	a2,0
    80001356:	00033517          	auipc	a0,0x33
    8000135a:	cda53503          	ld	a0,-806(a0) # 80034030 <kernel_pagetable>
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	efc080e7          	jalr	-260(ra) # 8000125a <walk>
  if(pte == 0)
    80001366:	cd09                	beqz	a0,80001380 <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    80001368:	6108                	ld	a0,0(a0)
    8000136a:	00157793          	andi	a5,a0,1
    8000136e:	c38d                	beqz	a5,80001390 <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    80001370:	8129                	srli	a0,a0,0xa
    80001372:	0532                	slli	a0,a0,0xc
}
    80001374:	9526                	add	a0,a0,s1
    80001376:	60e2                	ld	ra,24(sp)
    80001378:	6442                	ld	s0,16(sp)
    8000137a:	64a2                	ld	s1,8(sp)
    8000137c:	6105                	addi	sp,sp,32
    8000137e:	8082                	ret
    panic("kvmpa");
    80001380:	00007517          	auipc	a0,0x7
    80001384:	fc850513          	addi	a0,a0,-56 # 80008348 <userret+0x2b8>
    80001388:	fffff097          	auipc	ra,0xfffff
    8000138c:	1c0080e7          	jalr	448(ra) # 80000548 <panic>
    panic("kvmpa");
    80001390:	00007517          	auipc	a0,0x7
    80001394:	fb850513          	addi	a0,a0,-72 # 80008348 <userret+0x2b8>
    80001398:	fffff097          	auipc	ra,0xfffff
    8000139c:	1b0080e7          	jalr	432(ra) # 80000548 <panic>

00000000800013a0 <mappages>:
{
    800013a0:	715d                	addi	sp,sp,-80
    800013a2:	e486                	sd	ra,72(sp)
    800013a4:	e0a2                	sd	s0,64(sp)
    800013a6:	fc26                	sd	s1,56(sp)
    800013a8:	f84a                	sd	s2,48(sp)
    800013aa:	f44e                	sd	s3,40(sp)
    800013ac:	f052                	sd	s4,32(sp)
    800013ae:	ec56                	sd	s5,24(sp)
    800013b0:	e85a                	sd	s6,16(sp)
    800013b2:	e45e                	sd	s7,8(sp)
    800013b4:	0880                	addi	s0,sp,80
    800013b6:	8aaa                	mv	s5,a0
    800013b8:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    800013ba:	777d                	lui	a4,0xfffff
    800013bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800013c0:	167d                	addi	a2,a2,-1
    800013c2:	00b609b3          	add	s3,a2,a1
    800013c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800013ca:	893e                	mv	s2,a5
    800013cc:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    800013d0:	6b85                	lui	s7,0x1
    800013d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800013d6:	4605                	li	a2,1
    800013d8:	85ca                	mv	a1,s2
    800013da:	8556                	mv	a0,s5
    800013dc:	00000097          	auipc	ra,0x0
    800013e0:	e7e080e7          	jalr	-386(ra) # 8000125a <walk>
    800013e4:	c915                	beqz	a0,80001418 <mappages+0x78>
    if((*pte & PTE_COW) == 0 &&  *pte & PTE_V)
    800013e6:	611c                	ld	a5,0(a0)
    800013e8:	1017f793          	andi	a5,a5,257
    800013ec:	4705                	li	a4,1
    800013ee:	00e78d63          	beq	a5,a4,80001408 <mappages+0x68>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800013f2:	80b1                	srli	s1,s1,0xc
    800013f4:	04aa                	slli	s1,s1,0xa
    800013f6:	0164e4b3          	or	s1,s1,s6
    800013fa:	0014e493          	ori	s1,s1,1
    800013fe:	e104                	sd	s1,0(a0)
    if(a == last)
    80001400:	03390863          	beq	s2,s3,80001430 <mappages+0x90>
    a += PGSIZE;
    80001404:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001406:	b7f1                	j	800013d2 <mappages+0x32>
      panic("remap");
    80001408:	00007517          	auipc	a0,0x7
    8000140c:	f4850513          	addi	a0,a0,-184 # 80008350 <userret+0x2c0>
    80001410:	fffff097          	auipc	ra,0xfffff
    80001414:	138080e7          	jalr	312(ra) # 80000548 <panic>
      return -1;
    80001418:	557d                	li	a0,-1
}
    8000141a:	60a6                	ld	ra,72(sp)
    8000141c:	6406                	ld	s0,64(sp)
    8000141e:	74e2                	ld	s1,56(sp)
    80001420:	7942                	ld	s2,48(sp)
    80001422:	79a2                	ld	s3,40(sp)
    80001424:	7a02                	ld	s4,32(sp)
    80001426:	6ae2                	ld	s5,24(sp)
    80001428:	6b42                	ld	s6,16(sp)
    8000142a:	6ba2                	ld	s7,8(sp)
    8000142c:	6161                	addi	sp,sp,80
    8000142e:	8082                	ret
  return 0;
    80001430:	4501                	li	a0,0
    80001432:	b7e5                	j	8000141a <mappages+0x7a>

0000000080001434 <kvmmap>:
{
    80001434:	1141                	addi	sp,sp,-16
    80001436:	e406                	sd	ra,8(sp)
    80001438:	e022                	sd	s0,0(sp)
    8000143a:	0800                	addi	s0,sp,16
    8000143c:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000143e:	86ae                	mv	a3,a1
    80001440:	85aa                	mv	a1,a0
    80001442:	00033517          	auipc	a0,0x33
    80001446:	bee53503          	ld	a0,-1042(a0) # 80034030 <kernel_pagetable>
    8000144a:	00000097          	auipc	ra,0x0
    8000144e:	f56080e7          	jalr	-170(ra) # 800013a0 <mappages>
    80001452:	e509                	bnez	a0,8000145c <kvmmap+0x28>
}
    80001454:	60a2                	ld	ra,8(sp)
    80001456:	6402                	ld	s0,0(sp)
    80001458:	0141                	addi	sp,sp,16
    8000145a:	8082                	ret
    panic("kvmmap");
    8000145c:	00007517          	auipc	a0,0x7
    80001460:	efc50513          	addi	a0,a0,-260 # 80008358 <userret+0x2c8>
    80001464:	fffff097          	auipc	ra,0xfffff
    80001468:	0e4080e7          	jalr	228(ra) # 80000548 <panic>

000000008000146c <kvminit>:
{
    8000146c:	1101                	addi	sp,sp,-32
    8000146e:	ec06                	sd	ra,24(sp)
    80001470:	e822                	sd	s0,16(sp)
    80001472:	e426                	sd	s1,8(sp)
    80001474:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001476:	fffff097          	auipc	ra,0xfffff
    8000147a:	648080e7          	jalr	1608(ra) # 80000abe <kalloc>
    8000147e:	00033797          	auipc	a5,0x33
    80001482:	baa7b923          	sd	a0,-1102(a5) # 80034030 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001486:	6605                	lui	a2,0x1
    80001488:	4581                	li	a1,0
    8000148a:	00000097          	auipc	ra,0x0
    8000148e:	a7c080e7          	jalr	-1412(ra) # 80000f06 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001492:	4699                	li	a3,6
    80001494:	6605                	lui	a2,0x1
    80001496:	100005b7          	lui	a1,0x10000
    8000149a:	10000537          	lui	a0,0x10000
    8000149e:	00000097          	auipc	ra,0x0
    800014a2:	f96080e7          	jalr	-106(ra) # 80001434 <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    800014a6:	4699                	li	a3,6
    800014a8:	6605                	lui	a2,0x1
    800014aa:	100015b7          	lui	a1,0x10001
    800014ae:	10001537          	lui	a0,0x10001
    800014b2:	00000097          	auipc	ra,0x0
    800014b6:	f82080e7          	jalr	-126(ra) # 80001434 <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    800014ba:	4699                	li	a3,6
    800014bc:	6605                	lui	a2,0x1
    800014be:	100025b7          	lui	a1,0x10002
    800014c2:	10002537          	lui	a0,0x10002
    800014c6:	00000097          	auipc	ra,0x0
    800014ca:	f6e080e7          	jalr	-146(ra) # 80001434 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800014ce:	4699                	li	a3,6
    800014d0:	6641                	lui	a2,0x10
    800014d2:	020005b7          	lui	a1,0x2000
    800014d6:	02000537          	lui	a0,0x2000
    800014da:	00000097          	auipc	ra,0x0
    800014de:	f5a080e7          	jalr	-166(ra) # 80001434 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800014e2:	4699                	li	a3,6
    800014e4:	00400637          	lui	a2,0x400
    800014e8:	0c0005b7          	lui	a1,0xc000
    800014ec:	0c000537          	lui	a0,0xc000
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	f44080e7          	jalr	-188(ra) # 80001434 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800014f8:	00008497          	auipc	s1,0x8
    800014fc:	b0848493          	addi	s1,s1,-1272 # 80009000 <initcode>
    80001500:	46a9                	li	a3,10
    80001502:	80008617          	auipc	a2,0x80008
    80001506:	afe60613          	addi	a2,a2,-1282 # 9000 <_entry-0x7fff7000>
    8000150a:	4585                	li	a1,1
    8000150c:	05fe                	slli	a1,a1,0x1f
    8000150e:	852e                	mv	a0,a1
    80001510:	00000097          	auipc	ra,0x0
    80001514:	f24080e7          	jalr	-220(ra) # 80001434 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001518:	4699                	li	a3,6
    8000151a:	4645                	li	a2,17
    8000151c:	066e                	slli	a2,a2,0x1b
    8000151e:	8e05                	sub	a2,a2,s1
    80001520:	85a6                	mv	a1,s1
    80001522:	8526                	mv	a0,s1
    80001524:	00000097          	auipc	ra,0x0
    80001528:	f10080e7          	jalr	-240(ra) # 80001434 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000152c:	46a9                	li	a3,10
    8000152e:	6605                	lui	a2,0x1
    80001530:	00007597          	auipc	a1,0x7
    80001534:	ad058593          	addi	a1,a1,-1328 # 80008000 <trampoline>
    80001538:	04000537          	lui	a0,0x4000
    8000153c:	157d                	addi	a0,a0,-1
    8000153e:	0532                	slli	a0,a0,0xc
    80001540:	00000097          	auipc	ra,0x0
    80001544:	ef4080e7          	jalr	-268(ra) # 80001434 <kvmmap>
}
    80001548:	60e2                	ld	ra,24(sp)
    8000154a:	6442                	ld	s0,16(sp)
    8000154c:	64a2                	ld	s1,8(sp)
    8000154e:	6105                	addi	sp,sp,32
    80001550:	8082                	ret

0000000080001552 <uvmunmap>:
{
    80001552:	715d                	addi	sp,sp,-80
    80001554:	e486                	sd	ra,72(sp)
    80001556:	e0a2                	sd	s0,64(sp)
    80001558:	fc26                	sd	s1,56(sp)
    8000155a:	f84a                	sd	s2,48(sp)
    8000155c:	f44e                	sd	s3,40(sp)
    8000155e:	f052                	sd	s4,32(sp)
    80001560:	ec56                	sd	s5,24(sp)
    80001562:	e85a                	sd	s6,16(sp)
    80001564:	e45e                	sd	s7,8(sp)
    80001566:	0880                	addi	s0,sp,80
    80001568:	8a2a                	mv	s4,a0
    8000156a:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    8000156c:	77fd                	lui	a5,0xfffff
    8000156e:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    80001572:	167d                	addi	a2,a2,-1
    80001574:	00b609b3          	add	s3,a2,a1
    80001578:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    8000157c:	4b05                	li	s6,1
    a += PGSIZE;
    8000157e:	6b85                	lui	s7,0x1
    80001580:	a0b9                	j	800015ce <uvmunmap+0x7c>
      panic("uvmunmap: walk");
    80001582:	00007517          	auipc	a0,0x7
    80001586:	dde50513          	addi	a0,a0,-546 # 80008360 <userret+0x2d0>
    8000158a:	fffff097          	auipc	ra,0xfffff
    8000158e:	fbe080e7          	jalr	-66(ra) # 80000548 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    80001592:	85ca                	mv	a1,s2
    80001594:	00007517          	auipc	a0,0x7
    80001598:	ddc50513          	addi	a0,a0,-548 # 80008370 <userret+0x2e0>
    8000159c:	fffff097          	auipc	ra,0xfffff
    800015a0:	006080e7          	jalr	6(ra) # 800005a2 <printf>
      panic("uvmunmap: not mapped");
    800015a4:	00007517          	auipc	a0,0x7
    800015a8:	ddc50513          	addi	a0,a0,-548 # 80008380 <userret+0x2f0>
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	f9c080e7          	jalr	-100(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    800015b4:	00007517          	auipc	a0,0x7
    800015b8:	de450513          	addi	a0,a0,-540 # 80008398 <userret+0x308>
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	f8c080e7          	jalr	-116(ra) # 80000548 <panic>
    *pte = 0;
    800015c4:	0004b023          	sd	zero,0(s1)
    if(a == last)
    800015c8:	03390e63          	beq	s2,s3,80001604 <uvmunmap+0xb2>
    a += PGSIZE;
    800015cc:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    800015ce:	4601                	li	a2,0
    800015d0:	85ca                	mv	a1,s2
    800015d2:	8552                	mv	a0,s4
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	c86080e7          	jalr	-890(ra) # 8000125a <walk>
    800015dc:	84aa                	mv	s1,a0
    800015de:	d155                	beqz	a0,80001582 <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    800015e0:	6110                	ld	a2,0(a0)
    800015e2:	00167793          	andi	a5,a2,1
    800015e6:	d7d5                	beqz	a5,80001592 <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    800015e8:	3ff67793          	andi	a5,a2,1023
    800015ec:	fd6784e3          	beq	a5,s6,800015b4 <uvmunmap+0x62>
    if(do_free){
    800015f0:	fc0a8ae3          	beqz	s5,800015c4 <uvmunmap+0x72>
      pa = PTE2PA(*pte);
    800015f4:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    800015f6:	00c61513          	slli	a0,a2,0xc
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	356080e7          	jalr	854(ra) # 80000950 <kfree>
    80001602:	b7c9                	j	800015c4 <uvmunmap+0x72>
}
    80001604:	60a6                	ld	ra,72(sp)
    80001606:	6406                	ld	s0,64(sp)
    80001608:	74e2                	ld	s1,56(sp)
    8000160a:	7942                	ld	s2,48(sp)
    8000160c:	79a2                	ld	s3,40(sp)
    8000160e:	7a02                	ld	s4,32(sp)
    80001610:	6ae2                	ld	s5,24(sp)
    80001612:	6b42                	ld	s6,16(sp)
    80001614:	6ba2                	ld	s7,8(sp)
    80001616:	6161                	addi	sp,sp,80
    80001618:	8082                	ret

000000008000161a <uvmcreate>:
{
    8000161a:	1101                	addi	sp,sp,-32
    8000161c:	ec06                	sd	ra,24(sp)
    8000161e:	e822                	sd	s0,16(sp)
    80001620:	e426                	sd	s1,8(sp)
    80001622:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    80001624:	fffff097          	auipc	ra,0xfffff
    80001628:	49a080e7          	jalr	1178(ra) # 80000abe <kalloc>
  if(pagetable == 0)
    8000162c:	cd11                	beqz	a0,80001648 <uvmcreate+0x2e>
    8000162e:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    80001630:	6605                	lui	a2,0x1
    80001632:	4581                	li	a1,0
    80001634:	00000097          	auipc	ra,0x0
    80001638:	8d2080e7          	jalr	-1838(ra) # 80000f06 <memset>
}
    8000163c:	8526                	mv	a0,s1
    8000163e:	60e2                	ld	ra,24(sp)
    80001640:	6442                	ld	s0,16(sp)
    80001642:	64a2                	ld	s1,8(sp)
    80001644:	6105                	addi	sp,sp,32
    80001646:	8082                	ret
    panic("uvmcreate: out of memory");
    80001648:	00007517          	auipc	a0,0x7
    8000164c:	d6850513          	addi	a0,a0,-664 # 800083b0 <userret+0x320>
    80001650:	fffff097          	auipc	ra,0xfffff
    80001654:	ef8080e7          	jalr	-264(ra) # 80000548 <panic>

0000000080001658 <uvminit>:
{
    80001658:	7179                	addi	sp,sp,-48
    8000165a:	f406                	sd	ra,40(sp)
    8000165c:	f022                	sd	s0,32(sp)
    8000165e:	ec26                	sd	s1,24(sp)
    80001660:	e84a                	sd	s2,16(sp)
    80001662:	e44e                	sd	s3,8(sp)
    80001664:	e052                	sd	s4,0(sp)
    80001666:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    80001668:	6785                	lui	a5,0x1
    8000166a:	04f67863          	bgeu	a2,a5,800016ba <uvminit+0x62>
    8000166e:	8a2a                	mv	s4,a0
    80001670:	89ae                	mv	s3,a1
    80001672:	84b2                	mv	s1,a2
  mem = kalloc();
    80001674:	fffff097          	auipc	ra,0xfffff
    80001678:	44a080e7          	jalr	1098(ra) # 80000abe <kalloc>
    8000167c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000167e:	6605                	lui	a2,0x1
    80001680:	4581                	li	a1,0
    80001682:	00000097          	auipc	ra,0x0
    80001686:	884080e7          	jalr	-1916(ra) # 80000f06 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000168a:	4779                	li	a4,30
    8000168c:	86ca                	mv	a3,s2
    8000168e:	6605                	lui	a2,0x1
    80001690:	4581                	li	a1,0
    80001692:	8552                	mv	a0,s4
    80001694:	00000097          	auipc	ra,0x0
    80001698:	d0c080e7          	jalr	-756(ra) # 800013a0 <mappages>
  memmove(mem, src, sz);
    8000169c:	8626                	mv	a2,s1
    8000169e:	85ce                	mv	a1,s3
    800016a0:	854a                	mv	a0,s2
    800016a2:	00000097          	auipc	ra,0x0
    800016a6:	8c0080e7          	jalr	-1856(ra) # 80000f62 <memmove>
}
    800016aa:	70a2                	ld	ra,40(sp)
    800016ac:	7402                	ld	s0,32(sp)
    800016ae:	64e2                	ld	s1,24(sp)
    800016b0:	6942                	ld	s2,16(sp)
    800016b2:	69a2                	ld	s3,8(sp)
    800016b4:	6a02                	ld	s4,0(sp)
    800016b6:	6145                	addi	sp,sp,48
    800016b8:	8082                	ret
    panic("inituvm: more than a page");
    800016ba:	00007517          	auipc	a0,0x7
    800016be:	d1650513          	addi	a0,a0,-746 # 800083d0 <userret+0x340>
    800016c2:	fffff097          	auipc	ra,0xfffff
    800016c6:	e86080e7          	jalr	-378(ra) # 80000548 <panic>

00000000800016ca <uvmdealloc>:
{
    800016ca:	1101                	addi	sp,sp,-32
    800016cc:	ec06                	sd	ra,24(sp)
    800016ce:	e822                	sd	s0,16(sp)
    800016d0:	e426                	sd	s1,8(sp)
    800016d2:	1000                	addi	s0,sp,32
    return oldsz;
    800016d4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800016d6:	00b67d63          	bgeu	a2,a1,800016f0 <uvmdealloc+0x26>
    800016da:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    800016dc:	6785                	lui	a5,0x1
    800016de:	17fd                	addi	a5,a5,-1
    800016e0:	00f60733          	add	a4,a2,a5
    800016e4:	76fd                	lui	a3,0xfffff
    800016e6:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    800016e8:	97ae                	add	a5,a5,a1
    800016ea:	8ff5                	and	a5,a5,a3
    800016ec:	00f76863          	bltu	a4,a5,800016fc <uvmdealloc+0x32>
}
    800016f0:	8526                	mv	a0,s1
    800016f2:	60e2                	ld	ra,24(sp)
    800016f4:	6442                	ld	s0,16(sp)
    800016f6:	64a2                	ld	s1,8(sp)
    800016f8:	6105                	addi	sp,sp,32
    800016fa:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    800016fc:	4685                	li	a3,1
    800016fe:	40e58633          	sub	a2,a1,a4
    80001702:	85ba                	mv	a1,a4
    80001704:	00000097          	auipc	ra,0x0
    80001708:	e4e080e7          	jalr	-434(ra) # 80001552 <uvmunmap>
    8000170c:	b7d5                	j	800016f0 <uvmdealloc+0x26>

000000008000170e <uvmalloc>:
  if(newsz < oldsz)
    8000170e:	0ab66163          	bltu	a2,a1,800017b0 <uvmalloc+0xa2>
{
    80001712:	7139                	addi	sp,sp,-64
    80001714:	fc06                	sd	ra,56(sp)
    80001716:	f822                	sd	s0,48(sp)
    80001718:	f426                	sd	s1,40(sp)
    8000171a:	f04a                	sd	s2,32(sp)
    8000171c:	ec4e                	sd	s3,24(sp)
    8000171e:	e852                	sd	s4,16(sp)
    80001720:	e456                	sd	s5,8(sp)
    80001722:	0080                	addi	s0,sp,64
    80001724:	8aaa                	mv	s5,a0
    80001726:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001728:	6985                	lui	s3,0x1
    8000172a:	19fd                	addi	s3,s3,-1
    8000172c:	95ce                	add	a1,a1,s3
    8000172e:	79fd                	lui	s3,0xfffff
    80001730:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    80001734:	08c9f063          	bgeu	s3,a2,800017b4 <uvmalloc+0xa6>
  a = oldsz;
    80001738:	894e                	mv	s2,s3
    mem = kalloc();
    8000173a:	fffff097          	auipc	ra,0xfffff
    8000173e:	384080e7          	jalr	900(ra) # 80000abe <kalloc>
    80001742:	84aa                	mv	s1,a0
    if(mem == 0){
    80001744:	c51d                	beqz	a0,80001772 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001746:	6605                	lui	a2,0x1
    80001748:	4581                	li	a1,0
    8000174a:	fffff097          	auipc	ra,0xfffff
    8000174e:	7bc080e7          	jalr	1980(ra) # 80000f06 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001752:	4779                	li	a4,30
    80001754:	86a6                	mv	a3,s1
    80001756:	6605                	lui	a2,0x1
    80001758:	85ca                	mv	a1,s2
    8000175a:	8556                	mv	a0,s5
    8000175c:	00000097          	auipc	ra,0x0
    80001760:	c44080e7          	jalr	-956(ra) # 800013a0 <mappages>
    80001764:	e905                	bnez	a0,80001794 <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    80001766:	6785                	lui	a5,0x1
    80001768:	993e                	add	s2,s2,a5
    8000176a:	fd4968e3          	bltu	s2,s4,8000173a <uvmalloc+0x2c>
  return newsz;
    8000176e:	8552                	mv	a0,s4
    80001770:	a809                	j	80001782 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001772:	864e                	mv	a2,s3
    80001774:	85ca                	mv	a1,s2
    80001776:	8556                	mv	a0,s5
    80001778:	00000097          	auipc	ra,0x0
    8000177c:	f52080e7          	jalr	-174(ra) # 800016ca <uvmdealloc>
      return 0;
    80001780:	4501                	li	a0,0
}
    80001782:	70e2                	ld	ra,56(sp)
    80001784:	7442                	ld	s0,48(sp)
    80001786:	74a2                	ld	s1,40(sp)
    80001788:	7902                	ld	s2,32(sp)
    8000178a:	69e2                	ld	s3,24(sp)
    8000178c:	6a42                	ld	s4,16(sp)
    8000178e:	6aa2                	ld	s5,8(sp)
    80001790:	6121                	addi	sp,sp,64
    80001792:	8082                	ret
      kfree(mem);
    80001794:	8526                	mv	a0,s1
    80001796:	fffff097          	auipc	ra,0xfffff
    8000179a:	1ba080e7          	jalr	442(ra) # 80000950 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000179e:	864e                	mv	a2,s3
    800017a0:	85ca                	mv	a1,s2
    800017a2:	8556                	mv	a0,s5
    800017a4:	00000097          	auipc	ra,0x0
    800017a8:	f26080e7          	jalr	-218(ra) # 800016ca <uvmdealloc>
      return 0;
    800017ac:	4501                	li	a0,0
    800017ae:	bfd1                	j	80001782 <uvmalloc+0x74>
    return oldsz;
    800017b0:	852e                	mv	a0,a1
}
    800017b2:	8082                	ret
  return newsz;
    800017b4:	8532                	mv	a0,a2
    800017b6:	b7f1                	j	80001782 <uvmalloc+0x74>

00000000800017b8 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800017b8:	1101                	addi	sp,sp,-32
    800017ba:	ec06                	sd	ra,24(sp)
    800017bc:	e822                	sd	s0,16(sp)
    800017be:	e426                	sd	s1,8(sp)
    800017c0:	1000                	addi	s0,sp,32
    800017c2:	84aa                	mv	s1,a0
    800017c4:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    800017c6:	4685                	li	a3,1
    800017c8:	4581                	li	a1,0
    800017ca:	00000097          	auipc	ra,0x0
    800017ce:	d88080e7          	jalr	-632(ra) # 80001552 <uvmunmap>
  freewalk(pagetable);
    800017d2:	8526                	mv	a0,s1
    800017d4:	00000097          	auipc	ra,0x0
    800017d8:	9f8080e7          	jalr	-1544(ra) # 800011cc <freewalk>
}
    800017dc:	60e2                	ld	ra,24(sp)
    800017de:	6442                	ld	s0,16(sp)
    800017e0:	64a2                	ld	s1,8(sp)
    800017e2:	6105                	addi	sp,sp,32
    800017e4:	8082                	ret

00000000800017e6 <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    800017e6:	715d                	addi	sp,sp,-80
    800017e8:	e486                	sd	ra,72(sp)
    800017ea:	e0a2                	sd	s0,64(sp)
    800017ec:	fc26                	sd	s1,56(sp)
    800017ee:	f84a                	sd	s2,48(sp)
    800017f0:	f44e                	sd	s3,40(sp)
    800017f2:	f052                	sd	s4,32(sp)
    800017f4:	ec56                	sd	s5,24(sp)
    800017f6:	e85a                	sd	s6,16(sp)
    800017f8:	e45e                	sd	s7,8(sp)
    800017fa:	0880                	addi	s0,sp,80
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  /** char *mem; */

  for(i = 0; i < sz; i += PGSIZE){
    800017fc:	c269                	beqz	a2,800018be <uvmcopy+0xd8>
    800017fe:	8aaa                	mv	s5,a0
    80001800:	8a2e                	mv	s4,a1
    80001802:	89b2                	mv	s3,a2
    80001804:	4481                	li	s1,0
    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0){
      /** kfree(mem); */
      printf("uvmcopy():can not map page\n");
      goto err;
    }
    addref("uvmcopy()",(void*)pa);
    80001806:	00007b17          	auipc	s6,0x7
    8000180a:	c4ab0b13          	addi	s6,s6,-950 # 80008450 <userret+0x3c0>
    if((pte = walk(old, i, 0)) == 0)
    8000180e:	4601                	li	a2,0
    80001810:	85a6                	mv	a1,s1
    80001812:	8556                	mv	a0,s5
    80001814:	00000097          	auipc	ra,0x0
    80001818:	a46080e7          	jalr	-1466(ra) # 8000125a <walk>
    8000181c:	c521                	beqz	a0,80001864 <uvmcopy+0x7e>
    if((*pte & PTE_V) == 0)
    8000181e:	6118                	ld	a4,0(a0)
    80001820:	00177793          	andi	a5,a4,1
    80001824:	cba1                	beqz	a5,80001874 <uvmcopy+0x8e>
    pa = PTE2PA(*pte);
    80001826:	00a75913          	srli	s2,a4,0xa
    8000182a:	0932                	slli	s2,s2,0xc
    *pte = (*pte & ~PTE_W) | PTE_COW;
    8000182c:	efb77713          	andi	a4,a4,-261
    80001830:	10076713          	ori	a4,a4,256
    80001834:	e118                	sd	a4,0(a0)
    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0){
    80001836:	3fb77713          	andi	a4,a4,1019
    8000183a:	86ca                	mv	a3,s2
    8000183c:	6605                	lui	a2,0x1
    8000183e:	85a6                	mv	a1,s1
    80001840:	8552                	mv	a0,s4
    80001842:	00000097          	auipc	ra,0x0
    80001846:	b5e080e7          	jalr	-1186(ra) # 800013a0 <mappages>
    8000184a:	8baa                	mv	s7,a0
    8000184c:	ed05                	bnez	a0,80001884 <uvmcopy+0x9e>
    addref("uvmcopy()",(void*)pa);
    8000184e:	85ca                	mv	a1,s2
    80001850:	855a                	mv	a0,s6
    80001852:	fffff097          	auipc	ra,0xfffff
    80001856:	076080e7          	jalr	118(ra) # 800008c8 <addref>
  for(i = 0; i < sz; i += PGSIZE){
    8000185a:	6785                	lui	a5,0x1
    8000185c:	94be                	add	s1,s1,a5
    8000185e:	fb34e8e3          	bltu	s1,s3,8000180e <uvmcopy+0x28>
    80001862:	a091                	j	800018a6 <uvmcopy+0xc0>
      panic("uvmcopy: pte should exist");
    80001864:	00007517          	auipc	a0,0x7
    80001868:	b8c50513          	addi	a0,a0,-1140 # 800083f0 <userret+0x360>
    8000186c:	fffff097          	auipc	ra,0xfffff
    80001870:	cdc080e7          	jalr	-804(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    80001874:	00007517          	auipc	a0,0x7
    80001878:	b9c50513          	addi	a0,a0,-1124 # 80008410 <userret+0x380>
    8000187c:	fffff097          	auipc	ra,0xfffff
    80001880:	ccc080e7          	jalr	-820(ra) # 80000548 <panic>
      printf("uvmcopy():can not map page\n");
    80001884:	00007517          	auipc	a0,0x7
    80001888:	bac50513          	addi	a0,a0,-1108 # 80008430 <userret+0x3a0>
    8000188c:	fffff097          	auipc	ra,0xfffff
    80001890:	d16080e7          	jalr	-746(ra) # 800005a2 <printf>
    printf("origin perm & PTE_COW: %d, new perm & PTE_COW %d \n", PTE_FLAGS(*walk(old,i,0)) & PTE_COW, PTE_FLAGS(*walk(new,i,0)) & PTE_COW); */
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    80001894:	4685                	li	a3,1
    80001896:	8626                	mv	a2,s1
    80001898:	4581                	li	a1,0
    8000189a:	8552                	mv	a0,s4
    8000189c:	00000097          	auipc	ra,0x0
    800018a0:	cb6080e7          	jalr	-842(ra) # 80001552 <uvmunmap>
  return -1;
    800018a4:	5bfd                	li	s7,-1
}
    800018a6:	855e                	mv	a0,s7
    800018a8:	60a6                	ld	ra,72(sp)
    800018aa:	6406                	ld	s0,64(sp)
    800018ac:	74e2                	ld	s1,56(sp)
    800018ae:	7942                	ld	s2,48(sp)
    800018b0:	79a2                	ld	s3,40(sp)
    800018b2:	7a02                	ld	s4,32(sp)
    800018b4:	6ae2                	ld	s5,24(sp)
    800018b6:	6b42                	ld	s6,16(sp)
    800018b8:	6ba2                	ld	s7,8(sp)
    800018ba:	6161                	addi	sp,sp,80
    800018bc:	8082                	ret
  return 0;
    800018be:	4b81                	li	s7,0
    800018c0:	b7dd                	j	800018a6 <uvmcopy+0xc0>

00000000800018c2 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800018c2:	1141                	addi	sp,sp,-16
    800018c4:	e406                	sd	ra,8(sp)
    800018c6:	e022                	sd	s0,0(sp)
    800018c8:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800018ca:	4601                	li	a2,0
    800018cc:	00000097          	auipc	ra,0x0
    800018d0:	98e080e7          	jalr	-1650(ra) # 8000125a <walk>
  if(pte == 0)
    800018d4:	c901                	beqz	a0,800018e4 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800018d6:	611c                	ld	a5,0(a0)
    800018d8:	9bbd                	andi	a5,a5,-17
    800018da:	e11c                	sd	a5,0(a0)
}
    800018dc:	60a2                	ld	ra,8(sp)
    800018de:	6402                	ld	s0,0(sp)
    800018e0:	0141                	addi	sp,sp,16
    800018e2:	8082                	ret
    panic("uvmclear");
    800018e4:	00007517          	auipc	a0,0x7
    800018e8:	b7c50513          	addi	a0,a0,-1156 # 80008460 <userret+0x3d0>
    800018ec:	fffff097          	auipc	ra,0xfffff
    800018f0:	c5c080e7          	jalr	-932(ra) # 80000548 <panic>

00000000800018f4 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;
  while(len > 0){
    800018f4:	12068263          	beqz	a3,80001a18 <copyout+0x124>
{
    800018f8:	711d                	addi	sp,sp,-96
    800018fa:	ec86                	sd	ra,88(sp)
    800018fc:	e8a2                	sd	s0,80(sp)
    800018fe:	e4a6                	sd	s1,72(sp)
    80001900:	e0ca                	sd	s2,64(sp)
    80001902:	fc4e                	sd	s3,56(sp)
    80001904:	f852                	sd	s4,48(sp)
    80001906:	f456                	sd	s5,40(sp)
    80001908:	f05a                	sd	s6,32(sp)
    8000190a:	ec5e                	sd	s7,24(sp)
    8000190c:	e862                	sd	s8,16(sp)
    8000190e:	e466                	sd	s9,8(sp)
    80001910:	1080                	addi	s0,sp,96
    80001912:	8baa                	mv	s7,a0
    80001914:	8aae                	mv	s5,a1
    80001916:	8b32                	mv	s6,a2
    80001918:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    8000191a:	74fd                	lui	s1,0xfffff
    8000191c:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA){
    8000191e:	57fd                	li	a5,-1
    80001920:	83e9                	srli	a5,a5,0x1a
    80001922:	0e97ed63          	bltu	a5,s1,80001a1c <copyout+0x128>
    80001926:	8c3e                	mv	s8,a5
    80001928:	a08d                	j	8000198a <copyout+0x96>
    if(*pte & PTE_COW){
      //printf("copyout(): got page COW faults at %p\n", va0);
      char *mem;
      if((mem = kalloc()) == 0)
      {
        printf("copyout(): memery alloc fault\n");
    8000192a:	00007517          	auipc	a0,0x7
    8000192e:	b4650513          	addi	a0,a0,-1210 # 80008470 <userret+0x3e0>
    80001932:	fffff097          	auipc	ra,0xfffff
    80001936:	c70080e7          	jalr	-912(ra) # 800005a2 <printf>
        return -1;
    8000193a:	557d                	li	a0,-1
    8000193c:	a0ed                	j	80001a26 <copyout+0x132>
        if(mappages(pagetable, va0, PGSIZE, (uint64)mem, perm) != 0){
          printf("copyout(): can not map page\n");
          kfree(mem); 
          return -1;
        }
        kfree((void*) pa);
    8000193e:	8566                	mv	a0,s9
    80001940:	fffff097          	auipc	ra,0xfffff
    80001944:	010080e7          	jalr	16(ra) # 80000950 <kfree>
      }
    }
    pa0 = walkaddr(pagetable, va0);
    80001948:	85a6                	mv	a1,s1
    8000194a:	855e                	mv	a0,s7
    8000194c:	00000097          	auipc	ra,0x0
    80001950:	9b4080e7          	jalr	-1612(ra) # 80001300 <walkaddr>
    if(pa0 == 0)
    80001954:	c961                	beqz	a0,80001a24 <copyout+0x130>
      return -1;
    n = PGSIZE - (dstva - va0);
    80001956:	6905                	lui	s2,0x1
    80001958:	9926                	add	s2,s2,s1
    8000195a:	415909b3          	sub	s3,s2,s5
    if(n > len)
    8000195e:	013a7363          	bgeu	s4,s3,80001964 <copyout+0x70>
    80001962:	89d2                	mv	s3,s4
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001964:	409a84b3          	sub	s1,s5,s1
    80001968:	0009861b          	sext.w	a2,s3
    8000196c:	85da                	mv	a1,s6
    8000196e:	9526                	add	a0,a0,s1
    80001970:	fffff097          	auipc	ra,0xfffff
    80001974:	5f2080e7          	jalr	1522(ra) # 80000f62 <memmove>

    len -= n;
    80001978:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000197c:	9b4e                	add	s6,s6,s3
  while(len > 0){
    8000197e:	080a0b63          	beqz	s4,80001a14 <copyout+0x120>
    if(va0 >= MAXVA){
    80001982:	092c6f63          	bltu	s8,s2,80001a20 <copyout+0x12c>
    va0 = PGROUNDDOWN(dstva);
    80001986:	84ca                	mv	s1,s2
    dstva = va0 + PGSIZE;
    80001988:	8aca                	mv	s5,s2
    pte = walk(pagetable, va0, 0);
    8000198a:	4601                	li	a2,0
    8000198c:	85a6                	mv	a1,s1
    8000198e:	855e                	mv	a0,s7
    80001990:	00000097          	auipc	ra,0x0
    80001994:	8ca080e7          	jalr	-1846(ra) # 8000125a <walk>
    80001998:	892a                	mv	s2,a0
    if(*pte & PTE_COW){
    8000199a:	611c                	ld	a5,0(a0)
    8000199c:	1007f793          	andi	a5,a5,256
    800019a0:	d7c5                	beqz	a5,80001948 <copyout+0x54>
      if((mem = kalloc()) == 0)
    800019a2:	fffff097          	auipc	ra,0xfffff
    800019a6:	11c080e7          	jalr	284(ra) # 80000abe <kalloc>
    800019aa:	89aa                	mv	s3,a0
    800019ac:	dd3d                	beqz	a0,8000192a <copyout+0x36>
      memset(mem, 0, sizeof(mem));
    800019ae:	4621                	li	a2,8
    800019b0:	4581                	li	a1,0
    800019b2:	fffff097          	auipc	ra,0xfffff
    800019b6:	554080e7          	jalr	1364(ra) # 80000f06 <memset>
      uint64 pa = walkaddr(pagetable, va0);
    800019ba:	85a6                	mv	a1,s1
    800019bc:	855e                	mv	a0,s7
    800019be:	00000097          	auipc	ra,0x0
    800019c2:	942080e7          	jalr	-1726(ra) # 80001300 <walkaddr>
    800019c6:	8caa                	mv	s9,a0
      if(pa){
    800019c8:	d141                	beqz	a0,80001948 <copyout+0x54>
        memmove(mem, (char*)pa, PGSIZE);
    800019ca:	6605                	lui	a2,0x1
    800019cc:	85aa                	mv	a1,a0
    800019ce:	854e                	mv	a0,s3
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	592080e7          	jalr	1426(ra) # 80000f62 <memmove>
        int perm = PTE_FLAGS(*pte);
    800019d8:	00093703          	ld	a4,0(s2) # 1000 <_entry-0x7ffff000>
        perm &= ~PTE_COW;
    800019dc:	2ff77713          	andi	a4,a4,767
        if(mappages(pagetable, va0, PGSIZE, (uint64)mem, perm) != 0){
    800019e0:	00476713          	ori	a4,a4,4
    800019e4:	86ce                	mv	a3,s3
    800019e6:	6605                	lui	a2,0x1
    800019e8:	85a6                	mv	a1,s1
    800019ea:	855e                	mv	a0,s7
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	9b4080e7          	jalr	-1612(ra) # 800013a0 <mappages>
    800019f4:	d529                	beqz	a0,8000193e <copyout+0x4a>
          printf("copyout(): can not map page\n");
    800019f6:	00007517          	auipc	a0,0x7
    800019fa:	a9a50513          	addi	a0,a0,-1382 # 80008490 <userret+0x400>
    800019fe:	fffff097          	auipc	ra,0xfffff
    80001a02:	ba4080e7          	jalr	-1116(ra) # 800005a2 <printf>
          kfree(mem); 
    80001a06:	854e                	mv	a0,s3
    80001a08:	fffff097          	auipc	ra,0xfffff
    80001a0c:	f48080e7          	jalr	-184(ra) # 80000950 <kfree>
          return -1;
    80001a10:	557d                	li	a0,-1
    80001a12:	a811                	j	80001a26 <copyout+0x132>
  }
  return 0;
    80001a14:	4501                	li	a0,0
    80001a16:	a801                	j	80001a26 <copyout+0x132>
    80001a18:	4501                	li	a0,0
}
    80001a1a:	8082                	ret
      return -1;
    80001a1c:	557d                	li	a0,-1
    80001a1e:	a021                	j	80001a26 <copyout+0x132>
    80001a20:	557d                	li	a0,-1
    80001a22:	a011                	j	80001a26 <copyout+0x132>
      return -1;
    80001a24:	557d                	li	a0,-1
}
    80001a26:	60e6                	ld	ra,88(sp)
    80001a28:	6446                	ld	s0,80(sp)
    80001a2a:	64a6                	ld	s1,72(sp)
    80001a2c:	6906                	ld	s2,64(sp)
    80001a2e:	79e2                	ld	s3,56(sp)
    80001a30:	7a42                	ld	s4,48(sp)
    80001a32:	7aa2                	ld	s5,40(sp)
    80001a34:	7b02                	ld	s6,32(sp)
    80001a36:	6be2                	ld	s7,24(sp)
    80001a38:	6c42                	ld	s8,16(sp)
    80001a3a:	6ca2                	ld	s9,8(sp)
    80001a3c:	6125                	addi	sp,sp,96
    80001a3e:	8082                	ret

0000000080001a40 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001a40:	caa5                	beqz	a3,80001ab0 <copyin+0x70>
{
    80001a42:	715d                	addi	sp,sp,-80
    80001a44:	e486                	sd	ra,72(sp)
    80001a46:	e0a2                	sd	s0,64(sp)
    80001a48:	fc26                	sd	s1,56(sp)
    80001a4a:	f84a                	sd	s2,48(sp)
    80001a4c:	f44e                	sd	s3,40(sp)
    80001a4e:	f052                	sd	s4,32(sp)
    80001a50:	ec56                	sd	s5,24(sp)
    80001a52:	e85a                	sd	s6,16(sp)
    80001a54:	e45e                	sd	s7,8(sp)
    80001a56:	e062                	sd	s8,0(sp)
    80001a58:	0880                	addi	s0,sp,80
    80001a5a:	8b2a                	mv	s6,a0
    80001a5c:	8a2e                	mv	s4,a1
    80001a5e:	8c32                	mv	s8,a2
    80001a60:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001a62:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a64:	6a85                	lui	s5,0x1
    80001a66:	a01d                	j	80001a8c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001a68:	018505b3          	add	a1,a0,s8
    80001a6c:	0004861b          	sext.w	a2,s1
    80001a70:	412585b3          	sub	a1,a1,s2
    80001a74:	8552                	mv	a0,s4
    80001a76:	fffff097          	auipc	ra,0xfffff
    80001a7a:	4ec080e7          	jalr	1260(ra) # 80000f62 <memmove>

    len -= n;
    80001a7e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001a82:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001a84:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001a88:	02098263          	beqz	s3,80001aac <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001a8c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001a90:	85ca                	mv	a1,s2
    80001a92:	855a                	mv	a0,s6
    80001a94:	00000097          	auipc	ra,0x0
    80001a98:	86c080e7          	jalr	-1940(ra) # 80001300 <walkaddr>
    if(pa0 == 0)
    80001a9c:	cd01                	beqz	a0,80001ab4 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001a9e:	418904b3          	sub	s1,s2,s8
    80001aa2:	94d6                	add	s1,s1,s5
    if(n > len)
    80001aa4:	fc99f2e3          	bgeu	s3,s1,80001a68 <copyin+0x28>
    80001aa8:	84ce                	mv	s1,s3
    80001aaa:	bf7d                	j	80001a68 <copyin+0x28>
  }
  return 0;
    80001aac:	4501                	li	a0,0
    80001aae:	a021                	j	80001ab6 <copyin+0x76>
    80001ab0:	4501                	li	a0,0
}
    80001ab2:	8082                	ret
      return -1;
    80001ab4:	557d                	li	a0,-1
}
    80001ab6:	60a6                	ld	ra,72(sp)
    80001ab8:	6406                	ld	s0,64(sp)
    80001aba:	74e2                	ld	s1,56(sp)
    80001abc:	7942                	ld	s2,48(sp)
    80001abe:	79a2                	ld	s3,40(sp)
    80001ac0:	7a02                	ld	s4,32(sp)
    80001ac2:	6ae2                	ld	s5,24(sp)
    80001ac4:	6b42                	ld	s6,16(sp)
    80001ac6:	6ba2                	ld	s7,8(sp)
    80001ac8:	6c02                	ld	s8,0(sp)
    80001aca:	6161                	addi	sp,sp,80
    80001acc:	8082                	ret

0000000080001ace <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001ace:	c6c5                	beqz	a3,80001b76 <copyinstr+0xa8>
{
    80001ad0:	715d                	addi	sp,sp,-80
    80001ad2:	e486                	sd	ra,72(sp)
    80001ad4:	e0a2                	sd	s0,64(sp)
    80001ad6:	fc26                	sd	s1,56(sp)
    80001ad8:	f84a                	sd	s2,48(sp)
    80001ada:	f44e                	sd	s3,40(sp)
    80001adc:	f052                	sd	s4,32(sp)
    80001ade:	ec56                	sd	s5,24(sp)
    80001ae0:	e85a                	sd	s6,16(sp)
    80001ae2:	e45e                	sd	s7,8(sp)
    80001ae4:	0880                	addi	s0,sp,80
    80001ae6:	8a2a                	mv	s4,a0
    80001ae8:	8b2e                	mv	s6,a1
    80001aea:	8bb2                	mv	s7,a2
    80001aec:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001aee:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001af0:	6985                	lui	s3,0x1
    80001af2:	a035                	j	80001b1e <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001af4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001af8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001afa:	0017b793          	seqz	a5,a5
    80001afe:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
    80001b02:	60a6                	ld	ra,72(sp)
    80001b04:	6406                	ld	s0,64(sp)
    80001b06:	74e2                	ld	s1,56(sp)
    80001b08:	7942                	ld	s2,48(sp)
    80001b0a:	79a2                	ld	s3,40(sp)
    80001b0c:	7a02                	ld	s4,32(sp)
    80001b0e:	6ae2                	ld	s5,24(sp)
    80001b10:	6b42                	ld	s6,16(sp)
    80001b12:	6ba2                	ld	s7,8(sp)
    80001b14:	6161                	addi	sp,sp,80
    80001b16:	8082                	ret
    srcva = va0 + PGSIZE;
    80001b18:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001b1c:	c8a9                	beqz	s1,80001b6e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001b1e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001b22:	85ca                	mv	a1,s2
    80001b24:	8552                	mv	a0,s4
    80001b26:	fffff097          	auipc	ra,0xfffff
    80001b2a:	7da080e7          	jalr	2010(ra) # 80001300 <walkaddr>
    if(pa0 == 0)
    80001b2e:	c131                	beqz	a0,80001b72 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001b30:	41790833          	sub	a6,s2,s7
    80001b34:	984e                	add	a6,a6,s3
    if(n > max)
    80001b36:	0104f363          	bgeu	s1,a6,80001b3c <copyinstr+0x6e>
    80001b3a:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001b3c:	955e                	add	a0,a0,s7
    80001b3e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001b42:	fc080be3          	beqz	a6,80001b18 <copyinstr+0x4a>
    80001b46:	985a                	add	a6,a6,s6
    80001b48:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001b4a:	41650633          	sub	a2,a0,s6
    80001b4e:	14fd                	addi	s1,s1,-1
    80001b50:	9b26                	add	s6,s6,s1
    80001b52:	00f60733          	add	a4,a2,a5
    80001b56:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffcafa4>
    80001b5a:	df49                	beqz	a4,80001af4 <copyinstr+0x26>
        *dst = *p;
    80001b5c:	00e78023          	sb	a4,0(a5)
      --max;
    80001b60:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001b64:	0785                	addi	a5,a5,1
    while(n > 0){
    80001b66:	ff0796e3          	bne	a5,a6,80001b52 <copyinstr+0x84>
      dst++;
    80001b6a:	8b42                	mv	s6,a6
    80001b6c:	b775                	j	80001b18 <copyinstr+0x4a>
    80001b6e:	4781                	li	a5,0
    80001b70:	b769                	j	80001afa <copyinstr+0x2c>
      return -1;
    80001b72:	557d                	li	a0,-1
    80001b74:	b779                	j	80001b02 <copyinstr+0x34>
  int got_null = 0;
    80001b76:	4781                	li	a5,0
  if(got_null){
    80001b78:	0017b793          	seqz	a5,a5
    80001b7c:	40f00533          	neg	a0,a5
    80001b80:	8082                	ret

0000000080001b82 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001b82:	1101                	addi	sp,sp,-32
    80001b84:	ec06                	sd	ra,24(sp)
    80001b86:	e822                	sd	s0,16(sp)
    80001b88:	e426                	sd	s1,8(sp)
    80001b8a:	1000                	addi	s0,sp,32
    80001b8c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001b8e:	fffff097          	auipc	ra,0xfffff
    80001b92:	0ce080e7          	jalr	206(ra) # 80000c5c <holding>
    80001b96:	c909                	beqz	a0,80001ba8 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001b98:	789c                	ld	a5,48(s1)
    80001b9a:	00978f63          	beq	a5,s1,80001bb8 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001b9e:	60e2                	ld	ra,24(sp)
    80001ba0:	6442                	ld	s0,16(sp)
    80001ba2:	64a2                	ld	s1,8(sp)
    80001ba4:	6105                	addi	sp,sp,32
    80001ba6:	8082                	ret
    panic("wakeup1");
    80001ba8:	00007517          	auipc	a0,0x7
    80001bac:	90850513          	addi	a0,a0,-1784 # 800084b0 <userret+0x420>
    80001bb0:	fffff097          	auipc	ra,0xfffff
    80001bb4:	998080e7          	jalr	-1640(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001bb8:	5098                	lw	a4,32(s1)
    80001bba:	4785                	li	a5,1
    80001bbc:	fef711e3          	bne	a4,a5,80001b9e <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001bc0:	4789                	li	a5,2
    80001bc2:	d09c                	sw	a5,32(s1)
}
    80001bc4:	bfe9                	j	80001b9e <wakeup1+0x1c>

0000000080001bc6 <procinit>:
{
    80001bc6:	715d                	addi	sp,sp,-80
    80001bc8:	e486                	sd	ra,72(sp)
    80001bca:	e0a2                	sd	s0,64(sp)
    80001bcc:	fc26                	sd	s1,56(sp)
    80001bce:	f84a                	sd	s2,48(sp)
    80001bd0:	f44e                	sd	s3,40(sp)
    80001bd2:	f052                	sd	s4,32(sp)
    80001bd4:	ec56                	sd	s5,24(sp)
    80001bd6:	e85a                	sd	s6,16(sp)
    80001bd8:	e45e                	sd	s7,8(sp)
    80001bda:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001bdc:	00007597          	auipc	a1,0x7
    80001be0:	8dc58593          	addi	a1,a1,-1828 # 800084b8 <userret+0x428>
    80001be4:	0001b517          	auipc	a0,0x1b
    80001be8:	c3450513          	addi	a0,a0,-972 # 8001c818 <pid_lock>
    80001bec:	fffff097          	auipc	ra,0xfffff
    80001bf0:	f62080e7          	jalr	-158(ra) # 80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf4:	0001b917          	auipc	s2,0x1b
    80001bf8:	04490913          	addi	s2,s2,68 # 8001cc38 <proc>
      initlock(&p->lock, "proc");
    80001bfc:	00007b97          	auipc	s7,0x7
    80001c00:	8c4b8b93          	addi	s7,s7,-1852 # 800084c0 <userret+0x430>
      uint64 va = KSTACK((int) (p - proc));
    80001c04:	8b4a                	mv	s6,s2
    80001c06:	00007a97          	auipc	s5,0x7
    80001c0a:	1d2a8a93          	addi	s5,s5,466 # 80008dd8 <syscalls+0xc0>
    80001c0e:	040009b7          	lui	s3,0x4000
    80001c12:	19fd                	addi	s3,s3,-1
    80001c14:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c16:	00021a17          	auipc	s4,0x21
    80001c1a:	c22a0a13          	addi	s4,s4,-990 # 80022838 <tickslock>
      initlock(&p->lock, "proc");
    80001c1e:	85de                	mv	a1,s7
    80001c20:	854a                	mv	a0,s2
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	f2c080e7          	jalr	-212(ra) # 80000b4e <initlock>
      char *pa = kalloc();
    80001c2a:	fffff097          	auipc	ra,0xfffff
    80001c2e:	e94080e7          	jalr	-364(ra) # 80000abe <kalloc>
    80001c32:	85aa                	mv	a1,a0
      if(pa == 0)
    80001c34:	c929                	beqz	a0,80001c86 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001c36:	416904b3          	sub	s1,s2,s6
    80001c3a:	8491                	srai	s1,s1,0x4
    80001c3c:	000ab783          	ld	a5,0(s5)
    80001c40:	02f484b3          	mul	s1,s1,a5
    80001c44:	2485                	addiw	s1,s1,1
    80001c46:	00d4949b          	slliw	s1,s1,0xd
    80001c4a:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c4e:	4699                	li	a3,6
    80001c50:	6605                	lui	a2,0x1
    80001c52:	8526                	mv	a0,s1
    80001c54:	fffff097          	auipc	ra,0xfffff
    80001c58:	7e0080e7          	jalr	2016(ra) # 80001434 <kvmmap>
      p->kstack = va;
    80001c5c:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c60:	17090913          	addi	s2,s2,368
    80001c64:	fb491de3          	bne	s2,s4,80001c1e <procinit+0x58>
  kvminithart();
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	5ce080e7          	jalr	1486(ra) # 80001236 <kvminithart>
}
    80001c70:	60a6                	ld	ra,72(sp)
    80001c72:	6406                	ld	s0,64(sp)
    80001c74:	74e2                	ld	s1,56(sp)
    80001c76:	7942                	ld	s2,48(sp)
    80001c78:	79a2                	ld	s3,40(sp)
    80001c7a:	7a02                	ld	s4,32(sp)
    80001c7c:	6ae2                	ld	s5,24(sp)
    80001c7e:	6b42                	ld	s6,16(sp)
    80001c80:	6ba2                	ld	s7,8(sp)
    80001c82:	6161                	addi	sp,sp,80
    80001c84:	8082                	ret
        panic("kalloc");
    80001c86:	00007517          	auipc	a0,0x7
    80001c8a:	84250513          	addi	a0,a0,-1982 # 800084c8 <userret+0x438>
    80001c8e:	fffff097          	auipc	ra,0xfffff
    80001c92:	8ba080e7          	jalr	-1862(ra) # 80000548 <panic>

0000000080001c96 <cpuid>:
{
    80001c96:	1141                	addi	sp,sp,-16
    80001c98:	e422                	sd	s0,8(sp)
    80001c9a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c9c:	8512                	mv	a0,tp
}
    80001c9e:	2501                	sext.w	a0,a0
    80001ca0:	6422                	ld	s0,8(sp)
    80001ca2:	0141                	addi	sp,sp,16
    80001ca4:	8082                	ret

0000000080001ca6 <mycpu>:
mycpu(void) {
    80001ca6:	1141                	addi	sp,sp,-16
    80001ca8:	e422                	sd	s0,8(sp)
    80001caa:	0800                	addi	s0,sp,16
    80001cac:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001cae:	2781                	sext.w	a5,a5
    80001cb0:	079e                	slli	a5,a5,0x7
}
    80001cb2:	0001b517          	auipc	a0,0x1b
    80001cb6:	b8650513          	addi	a0,a0,-1146 # 8001c838 <cpus>
    80001cba:	953e                	add	a0,a0,a5
    80001cbc:	6422                	ld	s0,8(sp)
    80001cbe:	0141                	addi	sp,sp,16
    80001cc0:	8082                	ret

0000000080001cc2 <myproc>:
myproc(void) {
    80001cc2:	1101                	addi	sp,sp,-32
    80001cc4:	ec06                	sd	ra,24(sp)
    80001cc6:	e822                	sd	s0,16(sp)
    80001cc8:	e426                	sd	s1,8(sp)
    80001cca:	1000                	addi	s0,sp,32
  push_off();
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	ed8080e7          	jalr	-296(ra) # 80000ba4 <push_off>
    80001cd4:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001cd6:	2781                	sext.w	a5,a5
    80001cd8:	079e                	slli	a5,a5,0x7
    80001cda:	0001b717          	auipc	a4,0x1b
    80001cde:	b3e70713          	addi	a4,a4,-1218 # 8001c818 <pid_lock>
    80001ce2:	97ba                	add	a5,a5,a4
    80001ce4:	7384                	ld	s1,32(a5)
  pop_off();
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	f0a080e7          	jalr	-246(ra) # 80000bf0 <pop_off>
}
    80001cee:	8526                	mv	a0,s1
    80001cf0:	60e2                	ld	ra,24(sp)
    80001cf2:	6442                	ld	s0,16(sp)
    80001cf4:	64a2                	ld	s1,8(sp)
    80001cf6:	6105                	addi	sp,sp,32
    80001cf8:	8082                	ret

0000000080001cfa <forkret>:
{
    80001cfa:	1141                	addi	sp,sp,-16
    80001cfc:	e406                	sd	ra,8(sp)
    80001cfe:	e022                	sd	s0,0(sp)
    80001d00:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001d02:	00000097          	auipc	ra,0x0
    80001d06:	fc0080e7          	jalr	-64(ra) # 80001cc2 <myproc>
    80001d0a:	fffff097          	auipc	ra,0xfffff
    80001d0e:	002080e7          	jalr	2(ra) # 80000d0c <release>
  if (first) {
    80001d12:	00007797          	auipc	a5,0x7
    80001d16:	3227a783          	lw	a5,802(a5) # 80009034 <first.1>
    80001d1a:	eb89                	bnez	a5,80001d2c <forkret+0x32>
  usertrapret();
    80001d1c:	00001097          	auipc	ra,0x1
    80001d20:	bda080e7          	jalr	-1062(ra) # 800028f6 <usertrapret>
}
    80001d24:	60a2                	ld	ra,8(sp)
    80001d26:	6402                	ld	s0,0(sp)
    80001d28:	0141                	addi	sp,sp,16
    80001d2a:	8082                	ret
    first = 0;
    80001d2c:	00007797          	auipc	a5,0x7
    80001d30:	3007a423          	sw	zero,776(a5) # 80009034 <first.1>
    fsinit(minor(ROOTDEV));
    80001d34:	4501                	li	a0,0
    80001d36:	00002097          	auipc	ra,0x2
    80001d3a:	a62080e7          	jalr	-1438(ra) # 80003798 <fsinit>
    80001d3e:	bff9                	j	80001d1c <forkret+0x22>

0000000080001d40 <allocpid>:
allocpid() {
    80001d40:	1101                	addi	sp,sp,-32
    80001d42:	ec06                	sd	ra,24(sp)
    80001d44:	e822                	sd	s0,16(sp)
    80001d46:	e426                	sd	s1,8(sp)
    80001d48:	e04a                	sd	s2,0(sp)
    80001d4a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001d4c:	0001b917          	auipc	s2,0x1b
    80001d50:	acc90913          	addi	s2,s2,-1332 # 8001c818 <pid_lock>
    80001d54:	854a                	mv	a0,s2
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	f46080e7          	jalr	-186(ra) # 80000c9c <acquire>
  pid = nextpid;
    80001d5e:	00007797          	auipc	a5,0x7
    80001d62:	2da78793          	addi	a5,a5,730 # 80009038 <nextpid>
    80001d66:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d68:	0014871b          	addiw	a4,s1,1
    80001d6c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d6e:	854a                	mv	a0,s2
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	f9c080e7          	jalr	-100(ra) # 80000d0c <release>
}
    80001d78:	8526                	mv	a0,s1
    80001d7a:	60e2                	ld	ra,24(sp)
    80001d7c:	6442                	ld	s0,16(sp)
    80001d7e:	64a2                	ld	s1,8(sp)
    80001d80:	6902                	ld	s2,0(sp)
    80001d82:	6105                	addi	sp,sp,32
    80001d84:	8082                	ret

0000000080001d86 <proc_pagetable>:
{
    80001d86:	1101                	addi	sp,sp,-32
    80001d88:	ec06                	sd	ra,24(sp)
    80001d8a:	e822                	sd	s0,16(sp)
    80001d8c:	e426                	sd	s1,8(sp)
    80001d8e:	e04a                	sd	s2,0(sp)
    80001d90:	1000                	addi	s0,sp,32
    80001d92:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d94:	00000097          	auipc	ra,0x0
    80001d98:	886080e7          	jalr	-1914(ra) # 8000161a <uvmcreate>
    80001d9c:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d9e:	4729                	li	a4,10
    80001da0:	00006697          	auipc	a3,0x6
    80001da4:	26068693          	addi	a3,a3,608 # 80008000 <trampoline>
    80001da8:	6605                	lui	a2,0x1
    80001daa:	040005b7          	lui	a1,0x4000
    80001dae:	15fd                	addi	a1,a1,-1
    80001db0:	05b2                	slli	a1,a1,0xc
    80001db2:	fffff097          	auipc	ra,0xfffff
    80001db6:	5ee080e7          	jalr	1518(ra) # 800013a0 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001dba:	4719                	li	a4,6
    80001dbc:	06093683          	ld	a3,96(s2)
    80001dc0:	6605                	lui	a2,0x1
    80001dc2:	020005b7          	lui	a1,0x2000
    80001dc6:	15fd                	addi	a1,a1,-1
    80001dc8:	05b6                	slli	a1,a1,0xd
    80001dca:	8526                	mv	a0,s1
    80001dcc:	fffff097          	auipc	ra,0xfffff
    80001dd0:	5d4080e7          	jalr	1492(ra) # 800013a0 <mappages>
}
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	60e2                	ld	ra,24(sp)
    80001dd8:	6442                	ld	s0,16(sp)
    80001dda:	64a2                	ld	s1,8(sp)
    80001ddc:	6902                	ld	s2,0(sp)
    80001dde:	6105                	addi	sp,sp,32
    80001de0:	8082                	ret

0000000080001de2 <allocproc>:
{
    80001de2:	1101                	addi	sp,sp,-32
    80001de4:	ec06                	sd	ra,24(sp)
    80001de6:	e822                	sd	s0,16(sp)
    80001de8:	e426                	sd	s1,8(sp)
    80001dea:	e04a                	sd	s2,0(sp)
    80001dec:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dee:	0001b497          	auipc	s1,0x1b
    80001df2:	e4a48493          	addi	s1,s1,-438 # 8001cc38 <proc>
    80001df6:	00021917          	auipc	s2,0x21
    80001dfa:	a4290913          	addi	s2,s2,-1470 # 80022838 <tickslock>
    acquire(&p->lock);
    80001dfe:	8526                	mv	a0,s1
    80001e00:	fffff097          	auipc	ra,0xfffff
    80001e04:	e9c080e7          	jalr	-356(ra) # 80000c9c <acquire>
    if(p->state == UNUSED) {
    80001e08:	509c                	lw	a5,32(s1)
    80001e0a:	cf81                	beqz	a5,80001e22 <allocproc+0x40>
      release(&p->lock);
    80001e0c:	8526                	mv	a0,s1
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	efe080e7          	jalr	-258(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e16:	17048493          	addi	s1,s1,368
    80001e1a:	ff2492e3          	bne	s1,s2,80001dfe <allocproc+0x1c>
  return 0;
    80001e1e:	4481                	li	s1,0
    80001e20:	a0a9                	j	80001e6a <allocproc+0x88>
  p->pid = allocpid();
    80001e22:	00000097          	auipc	ra,0x0
    80001e26:	f1e080e7          	jalr	-226(ra) # 80001d40 <allocpid>
    80001e2a:	c0a8                	sw	a0,64(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001e2c:	fffff097          	auipc	ra,0xfffff
    80001e30:	c92080e7          	jalr	-878(ra) # 80000abe <kalloc>
    80001e34:	892a                	mv	s2,a0
    80001e36:	f0a8                	sd	a0,96(s1)
    80001e38:	c121                	beqz	a0,80001e78 <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001e3a:	8526                	mv	a0,s1
    80001e3c:	00000097          	auipc	ra,0x0
    80001e40:	f4a080e7          	jalr	-182(ra) # 80001d86 <proc_pagetable>
    80001e44:	eca8                	sd	a0,88(s1)
  memset(&p->context, 0, sizeof p->context);
    80001e46:	07000613          	li	a2,112
    80001e4a:	4581                	li	a1,0
    80001e4c:	06848513          	addi	a0,s1,104
    80001e50:	fffff097          	auipc	ra,0xfffff
    80001e54:	0b6080e7          	jalr	182(ra) # 80000f06 <memset>
  p->context.ra = (uint64)forkret;
    80001e58:	00000797          	auipc	a5,0x0
    80001e5c:	ea278793          	addi	a5,a5,-350 # 80001cfa <forkret>
    80001e60:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e62:	64bc                	ld	a5,72(s1)
    80001e64:	6705                	lui	a4,0x1
    80001e66:	97ba                	add	a5,a5,a4
    80001e68:	f8bc                	sd	a5,112(s1)
}
    80001e6a:	8526                	mv	a0,s1
    80001e6c:	60e2                	ld	ra,24(sp)
    80001e6e:	6442                	ld	s0,16(sp)
    80001e70:	64a2                	ld	s1,8(sp)
    80001e72:	6902                	ld	s2,0(sp)
    80001e74:	6105                	addi	sp,sp,32
    80001e76:	8082                	ret
    release(&p->lock);
    80001e78:	8526                	mv	a0,s1
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	e92080e7          	jalr	-366(ra) # 80000d0c <release>
    return 0;
    80001e82:	84ca                	mv	s1,s2
    80001e84:	b7dd                	j	80001e6a <allocproc+0x88>

0000000080001e86 <proc_freepagetable>:
{
    80001e86:	1101                	addi	sp,sp,-32
    80001e88:	ec06                	sd	ra,24(sp)
    80001e8a:	e822                	sd	s0,16(sp)
    80001e8c:	e426                	sd	s1,8(sp)
    80001e8e:	e04a                	sd	s2,0(sp)
    80001e90:	1000                	addi	s0,sp,32
    80001e92:	84aa                	mv	s1,a0
    80001e94:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001e96:	4681                	li	a3,0
    80001e98:	6605                	lui	a2,0x1
    80001e9a:	040005b7          	lui	a1,0x4000
    80001e9e:	15fd                	addi	a1,a1,-1
    80001ea0:	05b2                	slli	a1,a1,0xc
    80001ea2:	fffff097          	auipc	ra,0xfffff
    80001ea6:	6b0080e7          	jalr	1712(ra) # 80001552 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001eaa:	4681                	li	a3,0
    80001eac:	6605                	lui	a2,0x1
    80001eae:	020005b7          	lui	a1,0x2000
    80001eb2:	15fd                	addi	a1,a1,-1
    80001eb4:	05b6                	slli	a1,a1,0xd
    80001eb6:	8526                	mv	a0,s1
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	69a080e7          	jalr	1690(ra) # 80001552 <uvmunmap>
  if(sz > 0)
    80001ec0:	00091863          	bnez	s2,80001ed0 <proc_freepagetable+0x4a>
}
    80001ec4:	60e2                	ld	ra,24(sp)
    80001ec6:	6442                	ld	s0,16(sp)
    80001ec8:	64a2                	ld	s1,8(sp)
    80001eca:	6902                	ld	s2,0(sp)
    80001ecc:	6105                	addi	sp,sp,32
    80001ece:	8082                	ret
    uvmfree(pagetable, sz);
    80001ed0:	85ca                	mv	a1,s2
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	00000097          	auipc	ra,0x0
    80001ed8:	8e4080e7          	jalr	-1820(ra) # 800017b8 <uvmfree>
}
    80001edc:	b7e5                	j	80001ec4 <proc_freepagetable+0x3e>

0000000080001ede <freeproc>:
{
    80001ede:	1101                	addi	sp,sp,-32
    80001ee0:	ec06                	sd	ra,24(sp)
    80001ee2:	e822                	sd	s0,16(sp)
    80001ee4:	e426                	sd	s1,8(sp)
    80001ee6:	1000                	addi	s0,sp,32
    80001ee8:	84aa                	mv	s1,a0
  if(p->tf)
    80001eea:	7128                	ld	a0,96(a0)
    80001eec:	c509                	beqz	a0,80001ef6 <freeproc+0x18>
    kfree((void*)p->tf);
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	a62080e7          	jalr	-1438(ra) # 80000950 <kfree>
  p->tf = 0;
    80001ef6:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001efa:	6ca8                	ld	a0,88(s1)
    80001efc:	c511                	beqz	a0,80001f08 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001efe:	68ac                	ld	a1,80(s1)
    80001f00:	00000097          	auipc	ra,0x0
    80001f04:	f86080e7          	jalr	-122(ra) # 80001e86 <proc_freepagetable>
  p->pagetable = 0;
    80001f08:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001f0c:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001f10:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001f14:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001f18:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001f1c:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001f20:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001f24:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001f28:	0204a023          	sw	zero,32(s1)
}
    80001f2c:	60e2                	ld	ra,24(sp)
    80001f2e:	6442                	ld	s0,16(sp)
    80001f30:	64a2                	ld	s1,8(sp)
    80001f32:	6105                	addi	sp,sp,32
    80001f34:	8082                	ret

0000000080001f36 <userinit>:
{
    80001f36:	1101                	addi	sp,sp,-32
    80001f38:	ec06                	sd	ra,24(sp)
    80001f3a:	e822                	sd	s0,16(sp)
    80001f3c:	e426                	sd	s1,8(sp)
    80001f3e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f40:	00000097          	auipc	ra,0x0
    80001f44:	ea2080e7          	jalr	-350(ra) # 80001de2 <allocproc>
    80001f48:	84aa                	mv	s1,a0
  initproc = p;
    80001f4a:	00032797          	auipc	a5,0x32
    80001f4e:	0ea7b723          	sd	a0,238(a5) # 80034038 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f52:	03300613          	li	a2,51
    80001f56:	00007597          	auipc	a1,0x7
    80001f5a:	0aa58593          	addi	a1,a1,170 # 80009000 <initcode>
    80001f5e:	6d28                	ld	a0,88(a0)
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	6f8080e7          	jalr	1784(ra) # 80001658 <uvminit>
  p->sz = PGSIZE;
    80001f68:	6785                	lui	a5,0x1
    80001f6a:	e8bc                	sd	a5,80(s1)
  p->tf->epc = 0;      // user program counter
    80001f6c:	70b8                	ld	a4,96(s1)
    80001f6e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001f72:	70b8                	ld	a4,96(s1)
    80001f74:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f76:	4641                	li	a2,16
    80001f78:	00006597          	auipc	a1,0x6
    80001f7c:	55858593          	addi	a1,a1,1368 # 800084d0 <userret+0x440>
    80001f80:	16048513          	addi	a0,s1,352
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	0d4080e7          	jalr	212(ra) # 80001058 <safestrcpy>
  p->cwd = namei("/");
    80001f8c:	00006517          	auipc	a0,0x6
    80001f90:	55450513          	addi	a0,a0,1364 # 800084e0 <userret+0x450>
    80001f94:	00002097          	auipc	ra,0x2
    80001f98:	206080e7          	jalr	518(ra) # 8000419a <namei>
    80001f9c:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001fa0:	4789                	li	a5,2
    80001fa2:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	d66080e7          	jalr	-666(ra) # 80000d0c <release>
}
    80001fae:	60e2                	ld	ra,24(sp)
    80001fb0:	6442                	ld	s0,16(sp)
    80001fb2:	64a2                	ld	s1,8(sp)
    80001fb4:	6105                	addi	sp,sp,32
    80001fb6:	8082                	ret

0000000080001fb8 <growproc>:
{
    80001fb8:	1101                	addi	sp,sp,-32
    80001fba:	ec06                	sd	ra,24(sp)
    80001fbc:	e822                	sd	s0,16(sp)
    80001fbe:	e426                	sd	s1,8(sp)
    80001fc0:	e04a                	sd	s2,0(sp)
    80001fc2:	1000                	addi	s0,sp,32
    80001fc4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fc6:	00000097          	auipc	ra,0x0
    80001fca:	cfc080e7          	jalr	-772(ra) # 80001cc2 <myproc>
    80001fce:	892a                	mv	s2,a0
  sz = p->sz;
    80001fd0:	692c                	ld	a1,80(a0)
    80001fd2:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001fd6:	00904f63          	bgtz	s1,80001ff4 <growproc+0x3c>
  } else if(n < 0){
    80001fda:	0204cc63          	bltz	s1,80002012 <growproc+0x5a>
  p->sz = sz;
    80001fde:	1602                	slli	a2,a2,0x20
    80001fe0:	9201                	srli	a2,a2,0x20
    80001fe2:	04c93823          	sd	a2,80(s2)
  return 0;
    80001fe6:	4501                	li	a0,0
}
    80001fe8:	60e2                	ld	ra,24(sp)
    80001fea:	6442                	ld	s0,16(sp)
    80001fec:	64a2                	ld	s1,8(sp)
    80001fee:	6902                	ld	s2,0(sp)
    80001ff0:	6105                	addi	sp,sp,32
    80001ff2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001ff4:	9e25                	addw	a2,a2,s1
    80001ff6:	1602                	slli	a2,a2,0x20
    80001ff8:	9201                	srli	a2,a2,0x20
    80001ffa:	1582                	slli	a1,a1,0x20
    80001ffc:	9181                	srli	a1,a1,0x20
    80001ffe:	6d28                	ld	a0,88(a0)
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	70e080e7          	jalr	1806(ra) # 8000170e <uvmalloc>
    80002008:	0005061b          	sext.w	a2,a0
    8000200c:	fa69                	bnez	a2,80001fde <growproc+0x26>
      return -1;
    8000200e:	557d                	li	a0,-1
    80002010:	bfe1                	j	80001fe8 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002012:	9e25                	addw	a2,a2,s1
    80002014:	1602                	slli	a2,a2,0x20
    80002016:	9201                	srli	a2,a2,0x20
    80002018:	1582                	slli	a1,a1,0x20
    8000201a:	9181                	srli	a1,a1,0x20
    8000201c:	6d28                	ld	a0,88(a0)
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	6ac080e7          	jalr	1708(ra) # 800016ca <uvmdealloc>
    80002026:	0005061b          	sext.w	a2,a0
    8000202a:	bf55                	j	80001fde <growproc+0x26>

000000008000202c <fork>:
{
    8000202c:	7139                	addi	sp,sp,-64
    8000202e:	fc06                	sd	ra,56(sp)
    80002030:	f822                	sd	s0,48(sp)
    80002032:	f426                	sd	s1,40(sp)
    80002034:	f04a                	sd	s2,32(sp)
    80002036:	ec4e                	sd	s3,24(sp)
    80002038:	e852                	sd	s4,16(sp)
    8000203a:	e456                	sd	s5,8(sp)
    8000203c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000203e:	00000097          	auipc	ra,0x0
    80002042:	c84080e7          	jalr	-892(ra) # 80001cc2 <myproc>
    80002046:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80002048:	00000097          	auipc	ra,0x0
    8000204c:	d9a080e7          	jalr	-614(ra) # 80001de2 <allocproc>
    80002050:	c17d                	beqz	a0,80002136 <fork+0x10a>
    80002052:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002054:	050ab603          	ld	a2,80(s5)
    80002058:	6d2c                	ld	a1,88(a0)
    8000205a:	058ab503          	ld	a0,88(s5)
    8000205e:	fffff097          	auipc	ra,0xfffff
    80002062:	788080e7          	jalr	1928(ra) # 800017e6 <uvmcopy>
    80002066:	04054a63          	bltz	a0,800020ba <fork+0x8e>
  np->sz = p->sz;
    8000206a:	050ab783          	ld	a5,80(s5)
    8000206e:	04fa3823          	sd	a5,80(s4)
  np->parent = p;
    80002072:	035a3423          	sd	s5,40(s4)
  *(np->tf) = *(p->tf);
    80002076:	060ab683          	ld	a3,96(s5)
    8000207a:	87b6                	mv	a5,a3
    8000207c:	060a3703          	ld	a4,96(s4)
    80002080:	12068693          	addi	a3,a3,288
    80002084:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002088:	6788                	ld	a0,8(a5)
    8000208a:	6b8c                	ld	a1,16(a5)
    8000208c:	6f90                	ld	a2,24(a5)
    8000208e:	01073023          	sd	a6,0(a4)
    80002092:	e708                	sd	a0,8(a4)
    80002094:	eb0c                	sd	a1,16(a4)
    80002096:	ef10                	sd	a2,24(a4)
    80002098:	02078793          	addi	a5,a5,32
    8000209c:	02070713          	addi	a4,a4,32
    800020a0:	fed792e3          	bne	a5,a3,80002084 <fork+0x58>
  np->tf->a0 = 0;
    800020a4:	060a3783          	ld	a5,96(s4)
    800020a8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800020ac:	0d8a8493          	addi	s1,s5,216
    800020b0:	0d8a0913          	addi	s2,s4,216
    800020b4:	158a8993          	addi	s3,s5,344
    800020b8:	a00d                	j	800020da <fork+0xae>
    freeproc(np);
    800020ba:	8552                	mv	a0,s4
    800020bc:	00000097          	auipc	ra,0x0
    800020c0:	e22080e7          	jalr	-478(ra) # 80001ede <freeproc>
    release(&np->lock);
    800020c4:	8552                	mv	a0,s4
    800020c6:	fffff097          	auipc	ra,0xfffff
    800020ca:	c46080e7          	jalr	-954(ra) # 80000d0c <release>
    return -1;
    800020ce:	54fd                	li	s1,-1
    800020d0:	a889                	j	80002122 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    800020d2:	04a1                	addi	s1,s1,8
    800020d4:	0921                	addi	s2,s2,8
    800020d6:	01348b63          	beq	s1,s3,800020ec <fork+0xc0>
    if(p->ofile[i])
    800020da:	6088                	ld	a0,0(s1)
    800020dc:	d97d                	beqz	a0,800020d2 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    800020de:	00003097          	auipc	ra,0x3
    800020e2:	9ae080e7          	jalr	-1618(ra) # 80004a8c <filedup>
    800020e6:	00a93023          	sd	a0,0(s2)
    800020ea:	b7e5                	j	800020d2 <fork+0xa6>
  np->cwd = idup(p->cwd);
    800020ec:	158ab503          	ld	a0,344(s5)
    800020f0:	00002097          	auipc	ra,0x2
    800020f4:	8e2080e7          	jalr	-1822(ra) # 800039d2 <idup>
    800020f8:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020fc:	4641                	li	a2,16
    800020fe:	160a8593          	addi	a1,s5,352
    80002102:	160a0513          	addi	a0,s4,352
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	f52080e7          	jalr	-174(ra) # 80001058 <safestrcpy>
  pid = np->pid;
    8000210e:	040a2483          	lw	s1,64(s4)
  np->state = RUNNABLE;
    80002112:	4789                	li	a5,2
    80002114:	02fa2023          	sw	a5,32(s4)
  release(&np->lock);
    80002118:	8552                	mv	a0,s4
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	bf2080e7          	jalr	-1038(ra) # 80000d0c <release>
}
    80002122:	8526                	mv	a0,s1
    80002124:	70e2                	ld	ra,56(sp)
    80002126:	7442                	ld	s0,48(sp)
    80002128:	74a2                	ld	s1,40(sp)
    8000212a:	7902                	ld	s2,32(sp)
    8000212c:	69e2                	ld	s3,24(sp)
    8000212e:	6a42                	ld	s4,16(sp)
    80002130:	6aa2                	ld	s5,8(sp)
    80002132:	6121                	addi	sp,sp,64
    80002134:	8082                	ret
    return -1;
    80002136:	54fd                	li	s1,-1
    80002138:	b7ed                	j	80002122 <fork+0xf6>

000000008000213a <reparent>:
{
    8000213a:	7179                	addi	sp,sp,-48
    8000213c:	f406                	sd	ra,40(sp)
    8000213e:	f022                	sd	s0,32(sp)
    80002140:	ec26                	sd	s1,24(sp)
    80002142:	e84a                	sd	s2,16(sp)
    80002144:	e44e                	sd	s3,8(sp)
    80002146:	e052                	sd	s4,0(sp)
    80002148:	1800                	addi	s0,sp,48
    8000214a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000214c:	0001b497          	auipc	s1,0x1b
    80002150:	aec48493          	addi	s1,s1,-1300 # 8001cc38 <proc>
      pp->parent = initproc;
    80002154:	00032a17          	auipc	s4,0x32
    80002158:	ee4a0a13          	addi	s4,s4,-284 # 80034038 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000215c:	00020997          	auipc	s3,0x20
    80002160:	6dc98993          	addi	s3,s3,1756 # 80022838 <tickslock>
    80002164:	a029                	j	8000216e <reparent+0x34>
    80002166:	17048493          	addi	s1,s1,368
    8000216a:	03348363          	beq	s1,s3,80002190 <reparent+0x56>
    if(pp->parent == p){
    8000216e:	749c                	ld	a5,40(s1)
    80002170:	ff279be3          	bne	a5,s2,80002166 <reparent+0x2c>
      acquire(&pp->lock);
    80002174:	8526                	mv	a0,s1
    80002176:	fffff097          	auipc	ra,0xfffff
    8000217a:	b26080e7          	jalr	-1242(ra) # 80000c9c <acquire>
      pp->parent = initproc;
    8000217e:	000a3783          	ld	a5,0(s4)
    80002182:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80002184:	8526                	mv	a0,s1
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	b86080e7          	jalr	-1146(ra) # 80000d0c <release>
    8000218e:	bfe1                	j	80002166 <reparent+0x2c>
}
    80002190:	70a2                	ld	ra,40(sp)
    80002192:	7402                	ld	s0,32(sp)
    80002194:	64e2                	ld	s1,24(sp)
    80002196:	6942                	ld	s2,16(sp)
    80002198:	69a2                	ld	s3,8(sp)
    8000219a:	6a02                	ld	s4,0(sp)
    8000219c:	6145                	addi	sp,sp,48
    8000219e:	8082                	ret

00000000800021a0 <scheduler>:
{
    800021a0:	715d                	addi	sp,sp,-80
    800021a2:	e486                	sd	ra,72(sp)
    800021a4:	e0a2                	sd	s0,64(sp)
    800021a6:	fc26                	sd	s1,56(sp)
    800021a8:	f84a                	sd	s2,48(sp)
    800021aa:	f44e                	sd	s3,40(sp)
    800021ac:	f052                	sd	s4,32(sp)
    800021ae:	ec56                	sd	s5,24(sp)
    800021b0:	e85a                	sd	s6,16(sp)
    800021b2:	e45e                	sd	s7,8(sp)
    800021b4:	e062                	sd	s8,0(sp)
    800021b6:	0880                	addi	s0,sp,80
    800021b8:	8792                	mv	a5,tp
  int id = r_tp();
    800021ba:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021bc:	00779b13          	slli	s6,a5,0x7
    800021c0:	0001a717          	auipc	a4,0x1a
    800021c4:	65870713          	addi	a4,a4,1624 # 8001c818 <pid_lock>
    800021c8:	975a                	add	a4,a4,s6
    800021ca:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    800021ce:	0001a717          	auipc	a4,0x1a
    800021d2:	67270713          	addi	a4,a4,1650 # 8001c840 <cpus+0x8>
    800021d6:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800021d8:	4c0d                	li	s8,3
        c->proc = p;
    800021da:	079e                	slli	a5,a5,0x7
    800021dc:	0001aa17          	auipc	s4,0x1a
    800021e0:	63ca0a13          	addi	s4,s4,1596 # 8001c818 <pid_lock>
    800021e4:	9a3e                	add	s4,s4,a5
        found = 1;
    800021e6:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800021e8:	00020997          	auipc	s3,0x20
    800021ec:	65098993          	addi	s3,s3,1616 # 80022838 <tickslock>
    800021f0:	a08d                	j	80002252 <scheduler+0xb2>
      release(&p->lock);
    800021f2:	8526                	mv	a0,s1
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	b18080e7          	jalr	-1256(ra) # 80000d0c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800021fc:	17048493          	addi	s1,s1,368
    80002200:	03348963          	beq	s1,s3,80002232 <scheduler+0x92>
      acquire(&p->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	a96080e7          	jalr	-1386(ra) # 80000c9c <acquire>
      if(p->state == RUNNABLE) {
    8000220e:	509c                	lw	a5,32(s1)
    80002210:	ff2791e3          	bne	a5,s2,800021f2 <scheduler+0x52>
        p->state = RUNNING;
    80002214:	0384a023          	sw	s8,32(s1)
        c->proc = p;
    80002218:	029a3023          	sd	s1,32(s4)
        swtch(&c->scheduler, &p->context);
    8000221c:	06848593          	addi	a1,s1,104
    80002220:	855a                	mv	a0,s6
    80002222:	00000097          	auipc	ra,0x0
    80002226:	62a080e7          	jalr	1578(ra) # 8000284c <swtch>
        c->proc = 0;
    8000222a:	020a3023          	sd	zero,32(s4)
        found = 1;
    8000222e:	8ade                	mv	s5,s7
    80002230:	b7c9                	j	800021f2 <scheduler+0x52>
    if(found == 0){
    80002232:	020a9063          	bnez	s5,80002252 <scheduler+0xb2>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002236:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    8000223a:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000223e:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002242:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002246:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000224a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000224e:	10500073          	wfi
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002252:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80002256:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000225a:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000225e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002262:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002266:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000226a:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000226c:	0001b497          	auipc	s1,0x1b
    80002270:	9cc48493          	addi	s1,s1,-1588 # 8001cc38 <proc>
      if(p->state == RUNNABLE) {
    80002274:	4909                	li	s2,2
    80002276:	b779                	j	80002204 <scheduler+0x64>

0000000080002278 <sched>:
{
    80002278:	7179                	addi	sp,sp,-48
    8000227a:	f406                	sd	ra,40(sp)
    8000227c:	f022                	sd	s0,32(sp)
    8000227e:	ec26                	sd	s1,24(sp)
    80002280:	e84a                	sd	s2,16(sp)
    80002282:	e44e                	sd	s3,8(sp)
    80002284:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002286:	00000097          	auipc	ra,0x0
    8000228a:	a3c080e7          	jalr	-1476(ra) # 80001cc2 <myproc>
    8000228e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	9cc080e7          	jalr	-1588(ra) # 80000c5c <holding>
    80002298:	c93d                	beqz	a0,8000230e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000229a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000229c:	2781                	sext.w	a5,a5
    8000229e:	079e                	slli	a5,a5,0x7
    800022a0:	0001a717          	auipc	a4,0x1a
    800022a4:	57870713          	addi	a4,a4,1400 # 8001c818 <pid_lock>
    800022a8:	97ba                	add	a5,a5,a4
    800022aa:	0987a703          	lw	a4,152(a5)
    800022ae:	4785                	li	a5,1
    800022b0:	06f71763          	bne	a4,a5,8000231e <sched+0xa6>
  if(p->state == RUNNING)
    800022b4:	5098                	lw	a4,32(s1)
    800022b6:	478d                	li	a5,3
    800022b8:	06f70b63          	beq	a4,a5,8000232e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022bc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022c0:	8b89                	andi	a5,a5,2
  if(intr_get())
    800022c2:	efb5                	bnez	a5,8000233e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022c4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800022c6:	0001a917          	auipc	s2,0x1a
    800022ca:	55290913          	addi	s2,s2,1362 # 8001c818 <pid_lock>
    800022ce:	2781                	sext.w	a5,a5
    800022d0:	079e                	slli	a5,a5,0x7
    800022d2:	97ca                	add	a5,a5,s2
    800022d4:	09c7a983          	lw	s3,156(a5)
    800022d8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    800022da:	2781                	sext.w	a5,a5
    800022dc:	079e                	slli	a5,a5,0x7
    800022de:	0001a597          	auipc	a1,0x1a
    800022e2:	56258593          	addi	a1,a1,1378 # 8001c840 <cpus+0x8>
    800022e6:	95be                	add	a1,a1,a5
    800022e8:	06848513          	addi	a0,s1,104
    800022ec:	00000097          	auipc	ra,0x0
    800022f0:	560080e7          	jalr	1376(ra) # 8000284c <swtch>
    800022f4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800022f6:	2781                	sext.w	a5,a5
    800022f8:	079e                	slli	a5,a5,0x7
    800022fa:	97ca                	add	a5,a5,s2
    800022fc:	0937ae23          	sw	s3,156(a5)
}
    80002300:	70a2                	ld	ra,40(sp)
    80002302:	7402                	ld	s0,32(sp)
    80002304:	64e2                	ld	s1,24(sp)
    80002306:	6942                	ld	s2,16(sp)
    80002308:	69a2                	ld	s3,8(sp)
    8000230a:	6145                	addi	sp,sp,48
    8000230c:	8082                	ret
    panic("sched p->lock");
    8000230e:	00006517          	auipc	a0,0x6
    80002312:	1da50513          	addi	a0,a0,474 # 800084e8 <userret+0x458>
    80002316:	ffffe097          	auipc	ra,0xffffe
    8000231a:	232080e7          	jalr	562(ra) # 80000548 <panic>
    panic("sched locks");
    8000231e:	00006517          	auipc	a0,0x6
    80002322:	1da50513          	addi	a0,a0,474 # 800084f8 <userret+0x468>
    80002326:	ffffe097          	auipc	ra,0xffffe
    8000232a:	222080e7          	jalr	546(ra) # 80000548 <panic>
    panic("sched running");
    8000232e:	00006517          	auipc	a0,0x6
    80002332:	1da50513          	addi	a0,a0,474 # 80008508 <userret+0x478>
    80002336:	ffffe097          	auipc	ra,0xffffe
    8000233a:	212080e7          	jalr	530(ra) # 80000548 <panic>
    panic("sched interruptible");
    8000233e:	00006517          	auipc	a0,0x6
    80002342:	1da50513          	addi	a0,a0,474 # 80008518 <userret+0x488>
    80002346:	ffffe097          	auipc	ra,0xffffe
    8000234a:	202080e7          	jalr	514(ra) # 80000548 <panic>

000000008000234e <exit>:
{
    8000234e:	7179                	addi	sp,sp,-48
    80002350:	f406                	sd	ra,40(sp)
    80002352:	f022                	sd	s0,32(sp)
    80002354:	ec26                	sd	s1,24(sp)
    80002356:	e84a                	sd	s2,16(sp)
    80002358:	e44e                	sd	s3,8(sp)
    8000235a:	e052                	sd	s4,0(sp)
    8000235c:	1800                	addi	s0,sp,48
    8000235e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002360:	00000097          	auipc	ra,0x0
    80002364:	962080e7          	jalr	-1694(ra) # 80001cc2 <myproc>
    80002368:	89aa                	mv	s3,a0
  if(p == initproc)
    8000236a:	00032797          	auipc	a5,0x32
    8000236e:	cce7b783          	ld	a5,-818(a5) # 80034038 <initproc>
    80002372:	0d850493          	addi	s1,a0,216
    80002376:	15850913          	addi	s2,a0,344
    8000237a:	02a79363          	bne	a5,a0,800023a0 <exit+0x52>
    panic("init exiting");
    8000237e:	00006517          	auipc	a0,0x6
    80002382:	1b250513          	addi	a0,a0,434 # 80008530 <userret+0x4a0>
    80002386:	ffffe097          	auipc	ra,0xffffe
    8000238a:	1c2080e7          	jalr	450(ra) # 80000548 <panic>
      fileclose(f);
    8000238e:	00002097          	auipc	ra,0x2
    80002392:	750080e7          	jalr	1872(ra) # 80004ade <fileclose>
      p->ofile[fd] = 0;
    80002396:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000239a:	04a1                	addi	s1,s1,8
    8000239c:	01248563          	beq	s1,s2,800023a6 <exit+0x58>
    if(p->ofile[fd]){
    800023a0:	6088                	ld	a0,0(s1)
    800023a2:	f575                	bnez	a0,8000238e <exit+0x40>
    800023a4:	bfdd                	j	8000239a <exit+0x4c>
  begin_op(ROOTDEV);
    800023a6:	4501                	li	a0,0
    800023a8:	00002097          	auipc	ra,0x2
    800023ac:	10e080e7          	jalr	270(ra) # 800044b6 <begin_op>
  iput(p->cwd);
    800023b0:	1589b503          	ld	a0,344(s3)
    800023b4:	00001097          	auipc	ra,0x1
    800023b8:	76a080e7          	jalr	1898(ra) # 80003b1e <iput>
  end_op(ROOTDEV);
    800023bc:	4501                	li	a0,0
    800023be:	00002097          	auipc	ra,0x2
    800023c2:	1a2080e7          	jalr	418(ra) # 80004560 <end_op>
  p->cwd = 0;
    800023c6:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    800023ca:	00032497          	auipc	s1,0x32
    800023ce:	c6e48493          	addi	s1,s1,-914 # 80034038 <initproc>
    800023d2:	6088                	ld	a0,0(s1)
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	8c8080e7          	jalr	-1848(ra) # 80000c9c <acquire>
  wakeup1(initproc);
    800023dc:	6088                	ld	a0,0(s1)
    800023de:	fffff097          	auipc	ra,0xfffff
    800023e2:	7a4080e7          	jalr	1956(ra) # 80001b82 <wakeup1>
  release(&initproc->lock);
    800023e6:	6088                	ld	a0,0(s1)
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	924080e7          	jalr	-1756(ra) # 80000d0c <release>
  acquire(&p->lock);
    800023f0:	854e                	mv	a0,s3
    800023f2:	fffff097          	auipc	ra,0xfffff
    800023f6:	8aa080e7          	jalr	-1878(ra) # 80000c9c <acquire>
  struct proc *original_parent = p->parent;
    800023fa:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800023fe:	854e                	mv	a0,s3
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	90c080e7          	jalr	-1780(ra) # 80000d0c <release>
  acquire(&original_parent->lock);
    80002408:	8526                	mv	a0,s1
    8000240a:	fffff097          	auipc	ra,0xfffff
    8000240e:	892080e7          	jalr	-1902(ra) # 80000c9c <acquire>
  acquire(&p->lock);
    80002412:	854e                	mv	a0,s3
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	888080e7          	jalr	-1912(ra) # 80000c9c <acquire>
  reparent(p);
    8000241c:	854e                	mv	a0,s3
    8000241e:	00000097          	auipc	ra,0x0
    80002422:	d1c080e7          	jalr	-740(ra) # 8000213a <reparent>
  wakeup1(original_parent);
    80002426:	8526                	mv	a0,s1
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	75a080e7          	jalr	1882(ra) # 80001b82 <wakeup1>
  p->xstate = status;
    80002430:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    80002434:	4791                	li	a5,4
    80002436:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    8000243a:	8526                	mv	a0,s1
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	8d0080e7          	jalr	-1840(ra) # 80000d0c <release>
  sched();
    80002444:	00000097          	auipc	ra,0x0
    80002448:	e34080e7          	jalr	-460(ra) # 80002278 <sched>
  panic("zombie exit");
    8000244c:	00006517          	auipc	a0,0x6
    80002450:	0f450513          	addi	a0,a0,244 # 80008540 <userret+0x4b0>
    80002454:	ffffe097          	auipc	ra,0xffffe
    80002458:	0f4080e7          	jalr	244(ra) # 80000548 <panic>

000000008000245c <yield>:
{
    8000245c:	1101                	addi	sp,sp,-32
    8000245e:	ec06                	sd	ra,24(sp)
    80002460:	e822                	sd	s0,16(sp)
    80002462:	e426                	sd	s1,8(sp)
    80002464:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002466:	00000097          	auipc	ra,0x0
    8000246a:	85c080e7          	jalr	-1956(ra) # 80001cc2 <myproc>
    8000246e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002470:	fffff097          	auipc	ra,0xfffff
    80002474:	82c080e7          	jalr	-2004(ra) # 80000c9c <acquire>
  p->state = RUNNABLE;
    80002478:	4789                	li	a5,2
    8000247a:	d09c                	sw	a5,32(s1)
  sched();
    8000247c:	00000097          	auipc	ra,0x0
    80002480:	dfc080e7          	jalr	-516(ra) # 80002278 <sched>
  release(&p->lock);
    80002484:	8526                	mv	a0,s1
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	886080e7          	jalr	-1914(ra) # 80000d0c <release>
}
    8000248e:	60e2                	ld	ra,24(sp)
    80002490:	6442                	ld	s0,16(sp)
    80002492:	64a2                	ld	s1,8(sp)
    80002494:	6105                	addi	sp,sp,32
    80002496:	8082                	ret

0000000080002498 <sleep>:
{
    80002498:	7179                	addi	sp,sp,-48
    8000249a:	f406                	sd	ra,40(sp)
    8000249c:	f022                	sd	s0,32(sp)
    8000249e:	ec26                	sd	s1,24(sp)
    800024a0:	e84a                	sd	s2,16(sp)
    800024a2:	e44e                	sd	s3,8(sp)
    800024a4:	1800                	addi	s0,sp,48
    800024a6:	89aa                	mv	s3,a0
    800024a8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024aa:	00000097          	auipc	ra,0x0
    800024ae:	818080e7          	jalr	-2024(ra) # 80001cc2 <myproc>
    800024b2:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800024b4:	05250663          	beq	a0,s2,80002500 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	7e4080e7          	jalr	2020(ra) # 80000c9c <acquire>
    release(lk);
    800024c0:	854a                	mv	a0,s2
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	84a080e7          	jalr	-1974(ra) # 80000d0c <release>
  p->chan = chan;
    800024ca:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    800024ce:	4785                	li	a5,1
    800024d0:	d09c                	sw	a5,32(s1)
  sched();
    800024d2:	00000097          	auipc	ra,0x0
    800024d6:	da6080e7          	jalr	-602(ra) # 80002278 <sched>
  p->chan = 0;
    800024da:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    800024de:	8526                	mv	a0,s1
    800024e0:	fffff097          	auipc	ra,0xfffff
    800024e4:	82c080e7          	jalr	-2004(ra) # 80000d0c <release>
    acquire(lk);
    800024e8:	854a                	mv	a0,s2
    800024ea:	ffffe097          	auipc	ra,0xffffe
    800024ee:	7b2080e7          	jalr	1970(ra) # 80000c9c <acquire>
}
    800024f2:	70a2                	ld	ra,40(sp)
    800024f4:	7402                	ld	s0,32(sp)
    800024f6:	64e2                	ld	s1,24(sp)
    800024f8:	6942                	ld	s2,16(sp)
    800024fa:	69a2                	ld	s3,8(sp)
    800024fc:	6145                	addi	sp,sp,48
    800024fe:	8082                	ret
  p->chan = chan;
    80002500:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    80002504:	4785                	li	a5,1
    80002506:	d11c                	sw	a5,32(a0)
  sched();
    80002508:	00000097          	auipc	ra,0x0
    8000250c:	d70080e7          	jalr	-656(ra) # 80002278 <sched>
  p->chan = 0;
    80002510:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    80002514:	bff9                	j	800024f2 <sleep+0x5a>

0000000080002516 <wait>:
{
    80002516:	715d                	addi	sp,sp,-80
    80002518:	e486                	sd	ra,72(sp)
    8000251a:	e0a2                	sd	s0,64(sp)
    8000251c:	fc26                	sd	s1,56(sp)
    8000251e:	f84a                	sd	s2,48(sp)
    80002520:	f44e                	sd	s3,40(sp)
    80002522:	f052                	sd	s4,32(sp)
    80002524:	ec56                	sd	s5,24(sp)
    80002526:	e85a                	sd	s6,16(sp)
    80002528:	e45e                	sd	s7,8(sp)
    8000252a:	0880                	addi	s0,sp,80
    8000252c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000252e:	fffff097          	auipc	ra,0xfffff
    80002532:	794080e7          	jalr	1940(ra) # 80001cc2 <myproc>
    80002536:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002538:	ffffe097          	auipc	ra,0xffffe
    8000253c:	764080e7          	jalr	1892(ra) # 80000c9c <acquire>
    havekids = 0;
    80002540:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002542:	4a11                	li	s4,4
        havekids = 1;
    80002544:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002546:	00020997          	auipc	s3,0x20
    8000254a:	2f298993          	addi	s3,s3,754 # 80022838 <tickslock>
    havekids = 0;
    8000254e:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002550:	0001a497          	auipc	s1,0x1a
    80002554:	6e848493          	addi	s1,s1,1768 # 8001cc38 <proc>
    80002558:	a08d                	j	800025ba <wait+0xa4>
          pid = np->pid;
    8000255a:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000255e:	000b0e63          	beqz	s6,8000257a <wait+0x64>
    80002562:	4691                	li	a3,4
    80002564:	03c48613          	addi	a2,s1,60
    80002568:	85da                	mv	a1,s6
    8000256a:	05893503          	ld	a0,88(s2)
    8000256e:	fffff097          	auipc	ra,0xfffff
    80002572:	386080e7          	jalr	902(ra) # 800018f4 <copyout>
    80002576:	02054263          	bltz	a0,8000259a <wait+0x84>
          freeproc(np);
    8000257a:	8526                	mv	a0,s1
    8000257c:	00000097          	auipc	ra,0x0
    80002580:	962080e7          	jalr	-1694(ra) # 80001ede <freeproc>
          release(&np->lock);
    80002584:	8526                	mv	a0,s1
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	786080e7          	jalr	1926(ra) # 80000d0c <release>
          release(&p->lock);
    8000258e:	854a                	mv	a0,s2
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	77c080e7          	jalr	1916(ra) # 80000d0c <release>
          return pid;
    80002598:	a8a9                	j	800025f2 <wait+0xdc>
            release(&np->lock);
    8000259a:	8526                	mv	a0,s1
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	770080e7          	jalr	1904(ra) # 80000d0c <release>
            release(&p->lock);
    800025a4:	854a                	mv	a0,s2
    800025a6:	ffffe097          	auipc	ra,0xffffe
    800025aa:	766080e7          	jalr	1894(ra) # 80000d0c <release>
            return -1;
    800025ae:	59fd                	li	s3,-1
    800025b0:	a089                	j	800025f2 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    800025b2:	17048493          	addi	s1,s1,368
    800025b6:	03348463          	beq	s1,s3,800025de <wait+0xc8>
      if(np->parent == p){
    800025ba:	749c                	ld	a5,40(s1)
    800025bc:	ff279be3          	bne	a5,s2,800025b2 <wait+0x9c>
        acquire(&np->lock);
    800025c0:	8526                	mv	a0,s1
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	6da080e7          	jalr	1754(ra) # 80000c9c <acquire>
        if(np->state == ZOMBIE){
    800025ca:	509c                	lw	a5,32(s1)
    800025cc:	f94787e3          	beq	a5,s4,8000255a <wait+0x44>
        release(&np->lock);
    800025d0:	8526                	mv	a0,s1
    800025d2:	ffffe097          	auipc	ra,0xffffe
    800025d6:	73a080e7          	jalr	1850(ra) # 80000d0c <release>
        havekids = 1;
    800025da:	8756                	mv	a4,s5
    800025dc:	bfd9                	j	800025b2 <wait+0x9c>
    if(!havekids || p->killed){
    800025de:	c701                	beqz	a4,800025e6 <wait+0xd0>
    800025e0:	03892783          	lw	a5,56(s2)
    800025e4:	c39d                	beqz	a5,8000260a <wait+0xf4>
      release(&p->lock);
    800025e6:	854a                	mv	a0,s2
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	724080e7          	jalr	1828(ra) # 80000d0c <release>
      return -1;
    800025f0:	59fd                	li	s3,-1
}
    800025f2:	854e                	mv	a0,s3
    800025f4:	60a6                	ld	ra,72(sp)
    800025f6:	6406                	ld	s0,64(sp)
    800025f8:	74e2                	ld	s1,56(sp)
    800025fa:	7942                	ld	s2,48(sp)
    800025fc:	79a2                	ld	s3,40(sp)
    800025fe:	7a02                	ld	s4,32(sp)
    80002600:	6ae2                	ld	s5,24(sp)
    80002602:	6b42                	ld	s6,16(sp)
    80002604:	6ba2                	ld	s7,8(sp)
    80002606:	6161                	addi	sp,sp,80
    80002608:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000260a:	85ca                	mv	a1,s2
    8000260c:	854a                	mv	a0,s2
    8000260e:	00000097          	auipc	ra,0x0
    80002612:	e8a080e7          	jalr	-374(ra) # 80002498 <sleep>
    havekids = 0;
    80002616:	bf25                	j	8000254e <wait+0x38>

0000000080002618 <wakeup>:
{
    80002618:	7139                	addi	sp,sp,-64
    8000261a:	fc06                	sd	ra,56(sp)
    8000261c:	f822                	sd	s0,48(sp)
    8000261e:	f426                	sd	s1,40(sp)
    80002620:	f04a                	sd	s2,32(sp)
    80002622:	ec4e                	sd	s3,24(sp)
    80002624:	e852                	sd	s4,16(sp)
    80002626:	e456                	sd	s5,8(sp)
    80002628:	0080                	addi	s0,sp,64
    8000262a:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000262c:	0001a497          	auipc	s1,0x1a
    80002630:	60c48493          	addi	s1,s1,1548 # 8001cc38 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002634:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002636:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002638:	00020917          	auipc	s2,0x20
    8000263c:	20090913          	addi	s2,s2,512 # 80022838 <tickslock>
    80002640:	a811                	j	80002654 <wakeup+0x3c>
    release(&p->lock);
    80002642:	8526                	mv	a0,s1
    80002644:	ffffe097          	auipc	ra,0xffffe
    80002648:	6c8080e7          	jalr	1736(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000264c:	17048493          	addi	s1,s1,368
    80002650:	03248063          	beq	s1,s2,80002670 <wakeup+0x58>
    acquire(&p->lock);
    80002654:	8526                	mv	a0,s1
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	646080e7          	jalr	1606(ra) # 80000c9c <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000265e:	509c                	lw	a5,32(s1)
    80002660:	ff3791e3          	bne	a5,s3,80002642 <wakeup+0x2a>
    80002664:	789c                	ld	a5,48(s1)
    80002666:	fd479ee3          	bne	a5,s4,80002642 <wakeup+0x2a>
      p->state = RUNNABLE;
    8000266a:	0354a023          	sw	s5,32(s1)
    8000266e:	bfd1                	j	80002642 <wakeup+0x2a>
}
    80002670:	70e2                	ld	ra,56(sp)
    80002672:	7442                	ld	s0,48(sp)
    80002674:	74a2                	ld	s1,40(sp)
    80002676:	7902                	ld	s2,32(sp)
    80002678:	69e2                	ld	s3,24(sp)
    8000267a:	6a42                	ld	s4,16(sp)
    8000267c:	6aa2                	ld	s5,8(sp)
    8000267e:	6121                	addi	sp,sp,64
    80002680:	8082                	ret

0000000080002682 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002682:	7179                	addi	sp,sp,-48
    80002684:	f406                	sd	ra,40(sp)
    80002686:	f022                	sd	s0,32(sp)
    80002688:	ec26                	sd	s1,24(sp)
    8000268a:	e84a                	sd	s2,16(sp)
    8000268c:	e44e                	sd	s3,8(sp)
    8000268e:	1800                	addi	s0,sp,48
    80002690:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002692:	0001a497          	auipc	s1,0x1a
    80002696:	5a648493          	addi	s1,s1,1446 # 8001cc38 <proc>
    8000269a:	00020997          	auipc	s3,0x20
    8000269e:	19e98993          	addi	s3,s3,414 # 80022838 <tickslock>
    acquire(&p->lock);
    800026a2:	8526                	mv	a0,s1
    800026a4:	ffffe097          	auipc	ra,0xffffe
    800026a8:	5f8080e7          	jalr	1528(ra) # 80000c9c <acquire>
    if(p->pid == pid){
    800026ac:	40bc                	lw	a5,64(s1)
    800026ae:	01278d63          	beq	a5,s2,800026c8 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800026b2:	8526                	mv	a0,s1
    800026b4:	ffffe097          	auipc	ra,0xffffe
    800026b8:	658080e7          	jalr	1624(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800026bc:	17048493          	addi	s1,s1,368
    800026c0:	ff3491e3          	bne	s1,s3,800026a2 <kill+0x20>
  }
  return -1;
    800026c4:	557d                	li	a0,-1
    800026c6:	a821                	j	800026de <kill+0x5c>
      p->killed = 1;
    800026c8:	4785                	li	a5,1
    800026ca:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    800026cc:	5098                	lw	a4,32(s1)
    800026ce:	00f70f63          	beq	a4,a5,800026ec <kill+0x6a>
      release(&p->lock);
    800026d2:	8526                	mv	a0,s1
    800026d4:	ffffe097          	auipc	ra,0xffffe
    800026d8:	638080e7          	jalr	1592(ra) # 80000d0c <release>
      return 0;
    800026dc:	4501                	li	a0,0
}
    800026de:	70a2                	ld	ra,40(sp)
    800026e0:	7402                	ld	s0,32(sp)
    800026e2:	64e2                	ld	s1,24(sp)
    800026e4:	6942                	ld	s2,16(sp)
    800026e6:	69a2                	ld	s3,8(sp)
    800026e8:	6145                	addi	sp,sp,48
    800026ea:	8082                	ret
        p->state = RUNNABLE;
    800026ec:	4789                	li	a5,2
    800026ee:	d09c                	sw	a5,32(s1)
    800026f0:	b7cd                	j	800026d2 <kill+0x50>

00000000800026f2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026f2:	7179                	addi	sp,sp,-48
    800026f4:	f406                	sd	ra,40(sp)
    800026f6:	f022                	sd	s0,32(sp)
    800026f8:	ec26                	sd	s1,24(sp)
    800026fa:	e84a                	sd	s2,16(sp)
    800026fc:	e44e                	sd	s3,8(sp)
    800026fe:	e052                	sd	s4,0(sp)
    80002700:	1800                	addi	s0,sp,48
    80002702:	84aa                	mv	s1,a0
    80002704:	892e                	mv	s2,a1
    80002706:	89b2                	mv	s3,a2
    80002708:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000270a:	fffff097          	auipc	ra,0xfffff
    8000270e:	5b8080e7          	jalr	1464(ra) # 80001cc2 <myproc>
  if(user_dst){
    80002712:	c08d                	beqz	s1,80002734 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002714:	86d2                	mv	a3,s4
    80002716:	864e                	mv	a2,s3
    80002718:	85ca                	mv	a1,s2
    8000271a:	6d28                	ld	a0,88(a0)
    8000271c:	fffff097          	auipc	ra,0xfffff
    80002720:	1d8080e7          	jalr	472(ra) # 800018f4 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002724:	70a2                	ld	ra,40(sp)
    80002726:	7402                	ld	s0,32(sp)
    80002728:	64e2                	ld	s1,24(sp)
    8000272a:	6942                	ld	s2,16(sp)
    8000272c:	69a2                	ld	s3,8(sp)
    8000272e:	6a02                	ld	s4,0(sp)
    80002730:	6145                	addi	sp,sp,48
    80002732:	8082                	ret
    memmove((char *)dst, src, len);
    80002734:	000a061b          	sext.w	a2,s4
    80002738:	85ce                	mv	a1,s3
    8000273a:	854a                	mv	a0,s2
    8000273c:	fffff097          	auipc	ra,0xfffff
    80002740:	826080e7          	jalr	-2010(ra) # 80000f62 <memmove>
    return 0;
    80002744:	8526                	mv	a0,s1
    80002746:	bff9                	j	80002724 <either_copyout+0x32>

0000000080002748 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002748:	7179                	addi	sp,sp,-48
    8000274a:	f406                	sd	ra,40(sp)
    8000274c:	f022                	sd	s0,32(sp)
    8000274e:	ec26                	sd	s1,24(sp)
    80002750:	e84a                	sd	s2,16(sp)
    80002752:	e44e                	sd	s3,8(sp)
    80002754:	e052                	sd	s4,0(sp)
    80002756:	1800                	addi	s0,sp,48
    80002758:	892a                	mv	s2,a0
    8000275a:	84ae                	mv	s1,a1
    8000275c:	89b2                	mv	s3,a2
    8000275e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002760:	fffff097          	auipc	ra,0xfffff
    80002764:	562080e7          	jalr	1378(ra) # 80001cc2 <myproc>
  if(user_src){
    80002768:	c08d                	beqz	s1,8000278a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000276a:	86d2                	mv	a3,s4
    8000276c:	864e                	mv	a2,s3
    8000276e:	85ca                	mv	a1,s2
    80002770:	6d28                	ld	a0,88(a0)
    80002772:	fffff097          	auipc	ra,0xfffff
    80002776:	2ce080e7          	jalr	718(ra) # 80001a40 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000277a:	70a2                	ld	ra,40(sp)
    8000277c:	7402                	ld	s0,32(sp)
    8000277e:	64e2                	ld	s1,24(sp)
    80002780:	6942                	ld	s2,16(sp)
    80002782:	69a2                	ld	s3,8(sp)
    80002784:	6a02                	ld	s4,0(sp)
    80002786:	6145                	addi	sp,sp,48
    80002788:	8082                	ret
    memmove(dst, (char*)src, len);
    8000278a:	000a061b          	sext.w	a2,s4
    8000278e:	85ce                	mv	a1,s3
    80002790:	854a                	mv	a0,s2
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	7d0080e7          	jalr	2000(ra) # 80000f62 <memmove>
    return 0;
    8000279a:	8526                	mv	a0,s1
    8000279c:	bff9                	j	8000277a <either_copyin+0x32>

000000008000279e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000279e:	715d                	addi	sp,sp,-80
    800027a0:	e486                	sd	ra,72(sp)
    800027a2:	e0a2                	sd	s0,64(sp)
    800027a4:	fc26                	sd	s1,56(sp)
    800027a6:	f84a                	sd	s2,48(sp)
    800027a8:	f44e                	sd	s3,40(sp)
    800027aa:	f052                	sd	s4,32(sp)
    800027ac:	ec56                	sd	s5,24(sp)
    800027ae:	e85a                	sd	s6,16(sp)
    800027b0:	e45e                	sd	s7,8(sp)
    800027b2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800027b4:	00006517          	auipc	a0,0x6
    800027b8:	e1c50513          	addi	a0,a0,-484 # 800085d0 <userret+0x540>
    800027bc:	ffffe097          	auipc	ra,0xffffe
    800027c0:	de6080e7          	jalr	-538(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027c4:	0001a497          	auipc	s1,0x1a
    800027c8:	5d448493          	addi	s1,s1,1492 # 8001cd98 <proc+0x160>
    800027cc:	00020917          	auipc	s2,0x20
    800027d0:	1cc90913          	addi	s2,s2,460 # 80022998 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027d4:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800027d6:	00006997          	auipc	s3,0x6
    800027da:	d7a98993          	addi	s3,s3,-646 # 80008550 <userret+0x4c0>
    printf("%d %s %s", p->pid, state, p->name);
    800027de:	00006a97          	auipc	s5,0x6
    800027e2:	d7aa8a93          	addi	s5,s5,-646 # 80008558 <userret+0x4c8>
    printf("\n");
    800027e6:	00006a17          	auipc	s4,0x6
    800027ea:	deaa0a13          	addi	s4,s4,-534 # 800085d0 <userret+0x540>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027ee:	00006b97          	auipc	s7,0x6
    800027f2:	4eab8b93          	addi	s7,s7,1258 # 80008cd8 <states.0>
    800027f6:	a00d                	j	80002818 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800027f8:	ee06a583          	lw	a1,-288(a3)
    800027fc:	8556                	mv	a0,s5
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	da4080e7          	jalr	-604(ra) # 800005a2 <printf>
    printf("\n");
    80002806:	8552                	mv	a0,s4
    80002808:	ffffe097          	auipc	ra,0xffffe
    8000280c:	d9a080e7          	jalr	-614(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002810:	17048493          	addi	s1,s1,368
    80002814:	03248163          	beq	s1,s2,80002836 <procdump+0x98>
    if(p->state == UNUSED)
    80002818:	86a6                	mv	a3,s1
    8000281a:	ec04a783          	lw	a5,-320(s1)
    8000281e:	dbed                	beqz	a5,80002810 <procdump+0x72>
      state = "???";
    80002820:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002822:	fcfb6be3          	bltu	s6,a5,800027f8 <procdump+0x5a>
    80002826:	1782                	slli	a5,a5,0x20
    80002828:	9381                	srli	a5,a5,0x20
    8000282a:	078e                	slli	a5,a5,0x3
    8000282c:	97de                	add	a5,a5,s7
    8000282e:	6390                	ld	a2,0(a5)
    80002830:	f661                	bnez	a2,800027f8 <procdump+0x5a>
      state = "???";
    80002832:	864e                	mv	a2,s3
    80002834:	b7d1                	j	800027f8 <procdump+0x5a>
  }
}
    80002836:	60a6                	ld	ra,72(sp)
    80002838:	6406                	ld	s0,64(sp)
    8000283a:	74e2                	ld	s1,56(sp)
    8000283c:	7942                	ld	s2,48(sp)
    8000283e:	79a2                	ld	s3,40(sp)
    80002840:	7a02                	ld	s4,32(sp)
    80002842:	6ae2                	ld	s5,24(sp)
    80002844:	6b42                	ld	s6,16(sp)
    80002846:	6ba2                	ld	s7,8(sp)
    80002848:	6161                	addi	sp,sp,80
    8000284a:	8082                	ret

000000008000284c <swtch>:
    8000284c:	00153023          	sd	ra,0(a0)
    80002850:	00253423          	sd	sp,8(a0)
    80002854:	e900                	sd	s0,16(a0)
    80002856:	ed04                	sd	s1,24(a0)
    80002858:	03253023          	sd	s2,32(a0)
    8000285c:	03353423          	sd	s3,40(a0)
    80002860:	03453823          	sd	s4,48(a0)
    80002864:	03553c23          	sd	s5,56(a0)
    80002868:	05653023          	sd	s6,64(a0)
    8000286c:	05753423          	sd	s7,72(a0)
    80002870:	05853823          	sd	s8,80(a0)
    80002874:	05953c23          	sd	s9,88(a0)
    80002878:	07a53023          	sd	s10,96(a0)
    8000287c:	07b53423          	sd	s11,104(a0)
    80002880:	0005b083          	ld	ra,0(a1)
    80002884:	0085b103          	ld	sp,8(a1)
    80002888:	6980                	ld	s0,16(a1)
    8000288a:	6d84                	ld	s1,24(a1)
    8000288c:	0205b903          	ld	s2,32(a1)
    80002890:	0285b983          	ld	s3,40(a1)
    80002894:	0305ba03          	ld	s4,48(a1)
    80002898:	0385ba83          	ld	s5,56(a1)
    8000289c:	0405bb03          	ld	s6,64(a1)
    800028a0:	0485bb83          	ld	s7,72(a1)
    800028a4:	0505bc03          	ld	s8,80(a1)
    800028a8:	0585bc83          	ld	s9,88(a1)
    800028ac:	0605bd03          	ld	s10,96(a1)
    800028b0:	0685bd83          	ld	s11,104(a1)
    800028b4:	8082                	ret

00000000800028b6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028b6:	1141                	addi	sp,sp,-16
    800028b8:	e406                	sd	ra,8(sp)
    800028ba:	e022                	sd	s0,0(sp)
    800028bc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028be:	00006597          	auipc	a1,0x6
    800028c2:	cd258593          	addi	a1,a1,-814 # 80008590 <userret+0x500>
    800028c6:	00020517          	auipc	a0,0x20
    800028ca:	f7250513          	addi	a0,a0,-142 # 80022838 <tickslock>
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	280080e7          	jalr	640(ra) # 80000b4e <initlock>
}
    800028d6:	60a2                	ld	ra,8(sp)
    800028d8:	6402                	ld	s0,0(sp)
    800028da:	0141                	addi	sp,sp,16
    800028dc:	8082                	ret

00000000800028de <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028de:	1141                	addi	sp,sp,-16
    800028e0:	e422                	sd	s0,8(sp)
    800028e2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028e4:	00004797          	auipc	a5,0x4
    800028e8:	90c78793          	addi	a5,a5,-1780 # 800061f0 <kernelvec>
    800028ec:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028f0:	6422                	ld	s0,8(sp)
    800028f2:	0141                	addi	sp,sp,16
    800028f4:	8082                	ret

00000000800028f6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028f6:	1141                	addi	sp,sp,-16
    800028f8:	e406                	sd	ra,8(sp)
    800028fa:	e022                	sd	s0,0(sp)
    800028fc:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028fe:	fffff097          	auipc	ra,0xfffff
    80002902:	3c4080e7          	jalr	964(ra) # 80001cc2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002906:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000290a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000290c:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002910:	00005617          	auipc	a2,0x5
    80002914:	6f060613          	addi	a2,a2,1776 # 80008000 <trampoline>
    80002918:	00005697          	auipc	a3,0x5
    8000291c:	6e868693          	addi	a3,a3,1768 # 80008000 <trampoline>
    80002920:	8e91                	sub	a3,a3,a2
    80002922:	040007b7          	lui	a5,0x4000
    80002926:	17fd                	addi	a5,a5,-1
    80002928:	07b2                	slli	a5,a5,0xc
    8000292a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000292c:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    80002930:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002932:	180026f3          	csrr	a3,satp
    80002936:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002938:	7138                	ld	a4,96(a0)
    8000293a:	6534                	ld	a3,72(a0)
    8000293c:	6585                	lui	a1,0x1
    8000293e:	96ae                	add	a3,a3,a1
    80002940:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    80002942:	7138                	ld	a4,96(a0)
    80002944:	00000697          	auipc	a3,0x0
    80002948:	12868693          	addi	a3,a3,296 # 80002a6c <usertrap>
    8000294c:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    8000294e:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002950:	8692                	mv	a3,tp
    80002952:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002954:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002958:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000295c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002960:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    80002964:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002966:	6f18                	ld	a4,24(a4)
    80002968:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000296c:	6d2c                	ld	a1,88(a0)
    8000296e:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002970:	00005717          	auipc	a4,0x5
    80002974:	72070713          	addi	a4,a4,1824 # 80008090 <userret>
    80002978:	8f11                	sub	a4,a4,a2
    8000297a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000297c:	577d                	li	a4,-1
    8000297e:	177e                	slli	a4,a4,0x3f
    80002980:	8dd9                	or	a1,a1,a4
    80002982:	02000537          	lui	a0,0x2000
    80002986:	157d                	addi	a0,a0,-1
    80002988:	0536                	slli	a0,a0,0xd
    8000298a:	9782                	jalr	a5
}
    8000298c:	60a2                	ld	ra,8(sp)
    8000298e:	6402                	ld	s0,0(sp)
    80002990:	0141                	addi	sp,sp,16
    80002992:	8082                	ret

0000000080002994 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002994:	1101                	addi	sp,sp,-32
    80002996:	ec06                	sd	ra,24(sp)
    80002998:	e822                	sd	s0,16(sp)
    8000299a:	e426                	sd	s1,8(sp)
    8000299c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000299e:	00020497          	auipc	s1,0x20
    800029a2:	e9a48493          	addi	s1,s1,-358 # 80022838 <tickslock>
    800029a6:	8526                	mv	a0,s1
    800029a8:	ffffe097          	auipc	ra,0xffffe
    800029ac:	2f4080e7          	jalr	756(ra) # 80000c9c <acquire>
  ticks++;
    800029b0:	00031517          	auipc	a0,0x31
    800029b4:	69050513          	addi	a0,a0,1680 # 80034040 <ticks>
    800029b8:	411c                	lw	a5,0(a0)
    800029ba:	2785                	addiw	a5,a5,1
    800029bc:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800029be:	00000097          	auipc	ra,0x0
    800029c2:	c5a080e7          	jalr	-934(ra) # 80002618 <wakeup>
  release(&tickslock);
    800029c6:	8526                	mv	a0,s1
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	344080e7          	jalr	836(ra) # 80000d0c <release>
}
    800029d0:	60e2                	ld	ra,24(sp)
    800029d2:	6442                	ld	s0,16(sp)
    800029d4:	64a2                	ld	s1,8(sp)
    800029d6:	6105                	addi	sp,sp,32
    800029d8:	8082                	ret

00000000800029da <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029da:	1101                	addi	sp,sp,-32
    800029dc:	ec06                	sd	ra,24(sp)
    800029de:	e822                	sd	s0,16(sp)
    800029e0:	e426                	sd	s1,8(sp)
    800029e2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029e4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800029e8:	00074d63          	bltz	a4,80002a02 <devintr+0x28>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    }

    plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000001L){
    800029ec:	57fd                	li	a5,-1
    800029ee:	17fe                	slli	a5,a5,0x3f
    800029f0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029f2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029f4:	04f70b63          	beq	a4,a5,80002a4a <devintr+0x70>
  }
}
    800029f8:	60e2                	ld	ra,24(sp)
    800029fa:	6442                	ld	s0,16(sp)
    800029fc:	64a2                	ld	s1,8(sp)
    800029fe:	6105                	addi	sp,sp,32
    80002a00:	8082                	ret
     (scause & 0xff) == 9){
    80002a02:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a06:	46a5                	li	a3,9
    80002a08:	fed792e3          	bne	a5,a3,800029ec <devintr+0x12>
    int irq = plic_claim();
    80002a0c:	00004097          	auipc	ra,0x4
    80002a10:	8fe080e7          	jalr	-1794(ra) # 8000630a <plic_claim>
    80002a14:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a16:	47a9                	li	a5,10
    80002a18:	00f50e63          	beq	a0,a5,80002a34 <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    80002a1c:	fff5079b          	addiw	a5,a0,-1
    80002a20:	4705                	li	a4,1
    80002a22:	00f77e63          	bgeu	a4,a5,80002a3e <devintr+0x64>
    plic_complete(irq);
    80002a26:	8526                	mv	a0,s1
    80002a28:	00004097          	auipc	ra,0x4
    80002a2c:	906080e7          	jalr	-1786(ra) # 8000632e <plic_complete>
    return 1;
    80002a30:	4505                	li	a0,1
    80002a32:	b7d9                	j	800029f8 <devintr+0x1e>
      uartintr();
    80002a34:	ffffe097          	auipc	ra,0xffffe
    80002a38:	e04080e7          	jalr	-508(ra) # 80000838 <uartintr>
    80002a3c:	b7ed                	j	80002a26 <devintr+0x4c>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    80002a3e:	853e                	mv	a0,a5
    80002a40:	00004097          	auipc	ra,0x4
    80002a44:	e98080e7          	jalr	-360(ra) # 800068d8 <virtio_disk_intr>
    80002a48:	bff9                	j	80002a26 <devintr+0x4c>
    if(cpuid() == 0){
    80002a4a:	fffff097          	auipc	ra,0xfffff
    80002a4e:	24c080e7          	jalr	588(ra) # 80001c96 <cpuid>
    80002a52:	c901                	beqz	a0,80002a62 <devintr+0x88>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a54:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a58:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a5a:	14479073          	csrw	sip,a5
    return 2;
    80002a5e:	4509                	li	a0,2
    80002a60:	bf61                	j	800029f8 <devintr+0x1e>
      clockintr();
    80002a62:	00000097          	auipc	ra,0x0
    80002a66:	f32080e7          	jalr	-206(ra) # 80002994 <clockintr>
    80002a6a:	b7ed                	j	80002a54 <devintr+0x7a>

0000000080002a6c <usertrap>:
{
    80002a6c:	7139                	addi	sp,sp,-64
    80002a6e:	fc06                	sd	ra,56(sp)
    80002a70:	f822                	sd	s0,48(sp)
    80002a72:	f426                	sd	s1,40(sp)
    80002a74:	f04a                	sd	s2,32(sp)
    80002a76:	ec4e                	sd	s3,24(sp)
    80002a78:	e852                	sd	s4,16(sp)
    80002a7a:	e456                	sd	s5,8(sp)
    80002a7c:	e05a                	sd	s6,0(sp)
    80002a7e:	0080                	addi	s0,sp,64
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a80:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a84:	1007f793          	andi	a5,a5,256
    80002a88:	efa5                	bnez	a5,80002b00 <usertrap+0x94>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a8a:	00003797          	auipc	a5,0x3
    80002a8e:	76678793          	addi	a5,a5,1894 # 800061f0 <kernelvec>
    80002a92:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a96:	fffff097          	auipc	ra,0xfffff
    80002a9a:	22c080e7          	jalr	556(ra) # 80001cc2 <myproc>
    80002a9e:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002aa0:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aa2:	14102773          	csrr	a4,sepc
    80002aa6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aa8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002aac:	47a1                	li	a5,8
    80002aae:	06f71763          	bne	a4,a5,80002b1c <usertrap+0xb0>
    if(p->killed)
    80002ab2:	5d1c                	lw	a5,56(a0)
    80002ab4:	efb1                	bnez	a5,80002b10 <usertrap+0xa4>
    p->tf->epc += 4;
    80002ab6:	70b8                	ld	a4,96(s1)
    80002ab8:	6f1c                	ld	a5,24(a4)
    80002aba:	0791                	addi	a5,a5,4
    80002abc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002abe:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80002ac2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80002ac6:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ace:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ad2:	10079073          	csrw	sstatus,a5
    syscall();
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	43a080e7          	jalr	1082(ra) # 80002f10 <syscall>
  if(p->killed)
    80002ade:	5c9c                	lw	a5,56(s1)
    80002ae0:	1e079563          	bnez	a5,80002cca <usertrap+0x25e>
  usertrapret();
    80002ae4:	00000097          	auipc	ra,0x0
    80002ae8:	e12080e7          	jalr	-494(ra) # 800028f6 <usertrapret>
}
    80002aec:	70e2                	ld	ra,56(sp)
    80002aee:	7442                	ld	s0,48(sp)
    80002af0:	74a2                	ld	s1,40(sp)
    80002af2:	7902                	ld	s2,32(sp)
    80002af4:	69e2                	ld	s3,24(sp)
    80002af6:	6a42                	ld	s4,16(sp)
    80002af8:	6aa2                	ld	s5,8(sp)
    80002afa:	6b02                	ld	s6,0(sp)
    80002afc:	6121                	addi	sp,sp,64
    80002afe:	8082                	ret
    panic("usertrap: not from user mode");
    80002b00:	00006517          	auipc	a0,0x6
    80002b04:	a9850513          	addi	a0,a0,-1384 # 80008598 <userret+0x508>
    80002b08:	ffffe097          	auipc	ra,0xffffe
    80002b0c:	a40080e7          	jalr	-1472(ra) # 80000548 <panic>
      exit(-1);
    80002b10:	557d                	li	a0,-1
    80002b12:	00000097          	auipc	ra,0x0
    80002b16:	83c080e7          	jalr	-1988(ra) # 8000234e <exit>
    80002b1a:	bf71                	j	80002ab6 <usertrap+0x4a>
  } else if((which_dev = devintr()) != 0){
    80002b1c:	00000097          	auipc	ra,0x0
    80002b20:	ebe080e7          	jalr	-322(ra) # 800029da <devintr>
    80002b24:	892a                	mv	s2,a0
    80002b26:	18051f63          	bnez	a0,80002cc4 <usertrap+0x258>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b2a:	14202773          	csrr	a4,scause
  } else if (r_scause() == 15) {
    80002b2e:	47bd                	li	a5,15
    80002b30:	14f71463          	bne	a4,a5,80002c78 <usertrap+0x20c>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b34:	143029f3          	csrr	s3,stval
    uint64 va = PGROUNDDOWN(r_stval());
    80002b38:	77fd                	lui	a5,0xfffff
    80002b3a:	00f9f9b3          	and	s3,s3,a5
    if (va >= MAXVA){
    80002b3e:	57fd                	li	a5,-1
    80002b40:	83e9                	srli	a5,a5,0x1a
    80002b42:	0537e063          	bltu	a5,s3,80002b82 <usertrap+0x116>
    if (va > p->sz){
    80002b46:	68bc                	ld	a5,80(s1)
    80002b48:	0537e863          	bltu	a5,s3,80002b98 <usertrap+0x12c>
    pte = walk(p->pagetable, va, 0);
    80002b4c:	4601                	li	a2,0
    80002b4e:	85ce                	mv	a1,s3
    80002b50:	6ca8                	ld	a0,88(s1)
    80002b52:	ffffe097          	auipc	ra,0xffffe
    80002b56:	708080e7          	jalr	1800(ra) # 8000125a <walk>
    80002b5a:	8a2a                	mv	s4,a0
    if(pte == 0 || ((*pte) & PTE_COW) == 0 || ((*pte) & PTE_V) == 0 || ((*pte) & PTE_U)==0){
    80002b5c:	c901                	beqz	a0,80002b6c <usertrap+0x100>
    80002b5e:	611c                	ld	a5,0(a0)
    80002b60:	1117f693          	andi	a3,a5,273
    80002b64:	11100713          	li	a4,273
    80002b68:	04e68363          	beq	a3,a4,80002bae <usertrap+0x142>
      printf("usertrap: pte not exist or it's not cow page\n");
    80002b6c:	00006517          	auipc	a0,0x6
    80002b70:	a8450513          	addi	a0,a0,-1404 # 800085f0 <userret+0x560>
    80002b74:	ffffe097          	auipc	ra,0xffffe
    80002b78:	a2e080e7          	jalr	-1490(ra) # 800005a2 <printf>
      p->killed=1;
    80002b7c:	4785                	li	a5,1
    80002b7e:	dc9c                	sw	a5,56(s1)
      goto end;
    80002b80:	a22d                	j	80002caa <usertrap+0x23e>
      printf("va is larger than MAXVA!\n");
    80002b82:	00006517          	auipc	a0,0x6
    80002b86:	a3650513          	addi	a0,a0,-1482 # 800085b8 <userret+0x528>
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	a18080e7          	jalr	-1512(ra) # 800005a2 <printf>
      p->killed = 1;
    80002b92:	4785                	li	a5,1
    80002b94:	dc9c                	sw	a5,56(s1)
      goto end;
    80002b96:	aa11                	j	80002caa <usertrap+0x23e>
      printf("va is larger than sz!\n");
    80002b98:	00006517          	auipc	a0,0x6
    80002b9c:	a4050513          	addi	a0,a0,-1472 # 800085d8 <userret+0x548>
    80002ba0:	ffffe097          	auipc	ra,0xffffe
    80002ba4:	a02080e7          	jalr	-1534(ra) # 800005a2 <printf>
      p->killed = 1;
    80002ba8:	4785                	li	a5,1
    80002baa:	dc9c                	sw	a5,56(s1)
      goto end;
    80002bac:	a8fd                	j	80002caa <usertrap+0x23e>
    if(*pte & PTE_COW){
    80002bae:	1007f793          	andi	a5,a5,256
    80002bb2:	cbc5                	beqz	a5,80002c62 <usertrap+0x1f6>
      if((mem = kalloc()) == 0)
    80002bb4:	ffffe097          	auipc	ra,0xffffe
    80002bb8:	f0a080e7          	jalr	-246(ra) # 80000abe <kalloc>
    80002bbc:	8aaa                	mv	s5,a0
    80002bbe:	c939                	beqz	a0,80002c14 <usertrap+0x1a8>
      memset(mem, 0, PGSIZE);
    80002bc0:	6605                	lui	a2,0x1
    80002bc2:	4581                	li	a1,0
    80002bc4:	ffffe097          	auipc	ra,0xffffe
    80002bc8:	342080e7          	jalr	834(ra) # 80000f06 <memset>
      uint64 pa = walkaddr(p->pagetable, va);
    80002bcc:	85ce                	mv	a1,s3
    80002bce:	6ca8                	ld	a0,88(s1)
    80002bd0:	ffffe097          	auipc	ra,0xffffe
    80002bd4:	730080e7          	jalr	1840(ra) # 80001300 <walkaddr>
    80002bd8:	8b2a                	mv	s6,a0
      if(pa){
    80002bda:	c925                	beqz	a0,80002c4a <usertrap+0x1de>
        memmove(mem, (char*)pa, PGSIZE);
    80002bdc:	6605                	lui	a2,0x1
    80002bde:	85aa                	mv	a1,a0
    80002be0:	8556                	mv	a0,s5
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	380080e7          	jalr	896(ra) # 80000f62 <memmove>
        int perm = PTE_FLAGS(*pte);
    80002bea:	000a3703          	ld	a4,0(s4)
        perm &= ~PTE_COW;
    80002bee:	2ff77713          	andi	a4,a4,767
        if(mappages(p->pagetable, va, PGSIZE, (uint64)mem, perm) != 0){
    80002bf2:	00476713          	ori	a4,a4,4
    80002bf6:	86d6                	mv	a3,s5
    80002bf8:	6605                	lui	a2,0x1
    80002bfa:	85ce                	mv	a1,s3
    80002bfc:	6ca8                	ld	a0,88(s1)
    80002bfe:	ffffe097          	auipc	ra,0xffffe
    80002c02:	7a2080e7          	jalr	1954(ra) # 800013a0 <mappages>
    80002c06:	e115                	bnez	a0,80002c2a <usertrap+0x1be>
        kfree((void*) pa);
    80002c08:	855a                	mv	a0,s6
    80002c0a:	ffffe097          	auipc	ra,0xffffe
    80002c0e:	d46080e7          	jalr	-698(ra) # 80000950 <kfree>
    80002c12:	b5f1                	j	80002ade <usertrap+0x72>
        printf("usertrap(): memery alloc fault\n");
    80002c14:	00006517          	auipc	a0,0x6
    80002c18:	a0c50513          	addi	a0,a0,-1524 # 80008620 <userret+0x590>
    80002c1c:	ffffe097          	auipc	ra,0xffffe
    80002c20:	986080e7          	jalr	-1658(ra) # 800005a2 <printf>
        p->killed = 1;
    80002c24:	4785                	li	a5,1
    80002c26:	dc9c                	sw	a5,56(s1)
        goto end;
    80002c28:	a049                	j	80002caa <usertrap+0x23e>
          printf("usertrap(): can not map page\n");
    80002c2a:	00006517          	auipc	a0,0x6
    80002c2e:	a1650513          	addi	a0,a0,-1514 # 80008640 <userret+0x5b0>
    80002c32:	ffffe097          	auipc	ra,0xffffe
    80002c36:	970080e7          	jalr	-1680(ra) # 800005a2 <printf>
          kfree(mem); 
    80002c3a:	8556                	mv	a0,s5
    80002c3c:	ffffe097          	auipc	ra,0xffffe
    80002c40:	d14080e7          	jalr	-748(ra) # 80000950 <kfree>
          p->killed = 1;
    80002c44:	4785                	li	a5,1
    80002c46:	dc9c                	sw	a5,56(s1)
          goto end;
    80002c48:	a08d                	j	80002caa <usertrap+0x23e>
        printf("usertrap(): can not map va: %p \n", va);
    80002c4a:	85ce                	mv	a1,s3
    80002c4c:	00006517          	auipc	a0,0x6
    80002c50:	a1450513          	addi	a0,a0,-1516 # 80008660 <userret+0x5d0>
    80002c54:	ffffe097          	auipc	ra,0xffffe
    80002c58:	94e080e7          	jalr	-1714(ra) # 800005a2 <printf>
        p->killed = 1;
    80002c5c:	4785                	li	a5,1
    80002c5e:	dc9c                	sw	a5,56(s1)
        goto end;
    80002c60:	a0a9                	j	80002caa <usertrap+0x23e>
      printf("usertrap(): not caused by cow \n");
    80002c62:	00006517          	auipc	a0,0x6
    80002c66:	a2650513          	addi	a0,a0,-1498 # 80008688 <userret+0x5f8>
    80002c6a:	ffffe097          	auipc	ra,0xffffe
    80002c6e:	938080e7          	jalr	-1736(ra) # 800005a2 <printf>
      p->killed = 1;
    80002c72:	4785                	li	a5,1
    80002c74:	dc9c                	sw	a5,56(s1)
      goto end;
    80002c76:	a815                	j	80002caa <usertrap+0x23e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c78:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c7c:	40b0                	lw	a2,64(s1)
    80002c7e:	00006517          	auipc	a0,0x6
    80002c82:	a2a50513          	addi	a0,a0,-1494 # 800086a8 <userret+0x618>
    80002c86:	ffffe097          	auipc	ra,0xffffe
    80002c8a:	91c080e7          	jalr	-1764(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c8e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c92:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval()); 
    80002c96:	00006517          	auipc	a0,0x6
    80002c9a:	a4250513          	addi	a0,a0,-1470 # 800086d8 <userret+0x648>
    80002c9e:	ffffe097          	auipc	ra,0xffffe
    80002ca2:	904080e7          	jalr	-1788(ra) # 800005a2 <printf>
    p->killed = 1;
    80002ca6:	4785                	li	a5,1
    80002ca8:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002caa:	557d                	li	a0,-1
    80002cac:	fffff097          	auipc	ra,0xfffff
    80002cb0:	6a2080e7          	jalr	1698(ra) # 8000234e <exit>
  if(which_dev == 2)
    80002cb4:	4789                	li	a5,2
    80002cb6:	e2f917e3          	bne	s2,a5,80002ae4 <usertrap+0x78>
    yield();
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	7a2080e7          	jalr	1954(ra) # 8000245c <yield>
    80002cc2:	b50d                	j	80002ae4 <usertrap+0x78>
  if(p->killed)
    80002cc4:	5c9c                	lw	a5,56(s1)
    80002cc6:	d7fd                	beqz	a5,80002cb4 <usertrap+0x248>
    80002cc8:	b7cd                	j	80002caa <usertrap+0x23e>
    80002cca:	4901                	li	s2,0
    80002ccc:	bff9                	j	80002caa <usertrap+0x23e>

0000000080002cce <kerneltrap>:
{
    80002cce:	7179                	addi	sp,sp,-48
    80002cd0:	f406                	sd	ra,40(sp)
    80002cd2:	f022                	sd	s0,32(sp)
    80002cd4:	ec26                	sd	s1,24(sp)
    80002cd6:	e84a                	sd	s2,16(sp)
    80002cd8:	e44e                	sd	s3,8(sp)
    80002cda:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cdc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ce0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ce4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ce8:	1004f793          	andi	a5,s1,256
    80002cec:	cb85                	beqz	a5,80002d1c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cf2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002cf4:	ef85                	bnez	a5,80002d2c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002cf6:	00000097          	auipc	ra,0x0
    80002cfa:	ce4080e7          	jalr	-796(ra) # 800029da <devintr>
    80002cfe:	cd1d                	beqz	a0,80002d3c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d00:	4789                	li	a5,2
    80002d02:	06f50a63          	beq	a0,a5,80002d76 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d06:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d0a:	10049073          	csrw	sstatus,s1
}
    80002d0e:	70a2                	ld	ra,40(sp)
    80002d10:	7402                	ld	s0,32(sp)
    80002d12:	64e2                	ld	s1,24(sp)
    80002d14:	6942                	ld	s2,16(sp)
    80002d16:	69a2                	ld	s3,8(sp)
    80002d18:	6145                	addi	sp,sp,48
    80002d1a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d1c:	00006517          	auipc	a0,0x6
    80002d20:	9dc50513          	addi	a0,a0,-1572 # 800086f8 <userret+0x668>
    80002d24:	ffffe097          	auipc	ra,0xffffe
    80002d28:	824080e7          	jalr	-2012(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d2c:	00006517          	auipc	a0,0x6
    80002d30:	9f450513          	addi	a0,a0,-1548 # 80008720 <userret+0x690>
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	814080e7          	jalr	-2028(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002d3c:	85ce                	mv	a1,s3
    80002d3e:	00006517          	auipc	a0,0x6
    80002d42:	a0250513          	addi	a0,a0,-1534 # 80008740 <userret+0x6b0>
    80002d46:	ffffe097          	auipc	ra,0xffffe
    80002d4a:	85c080e7          	jalr	-1956(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d4e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d52:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d56:	00006517          	auipc	a0,0x6
    80002d5a:	9fa50513          	addi	a0,a0,-1542 # 80008750 <userret+0x6c0>
    80002d5e:	ffffe097          	auipc	ra,0xffffe
    80002d62:	844080e7          	jalr	-1980(ra) # 800005a2 <printf>
    panic("kerneltrap");
    80002d66:	00006517          	auipc	a0,0x6
    80002d6a:	a0250513          	addi	a0,a0,-1534 # 80008768 <userret+0x6d8>
    80002d6e:	ffffd097          	auipc	ra,0xffffd
    80002d72:	7da080e7          	jalr	2010(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d76:	fffff097          	auipc	ra,0xfffff
    80002d7a:	f4c080e7          	jalr	-180(ra) # 80001cc2 <myproc>
    80002d7e:	d541                	beqz	a0,80002d06 <kerneltrap+0x38>
    80002d80:	fffff097          	auipc	ra,0xfffff
    80002d84:	f42080e7          	jalr	-190(ra) # 80001cc2 <myproc>
    80002d88:	5118                	lw	a4,32(a0)
    80002d8a:	478d                	li	a5,3
    80002d8c:	f6f71de3          	bne	a4,a5,80002d06 <kerneltrap+0x38>
    yield();
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	6cc080e7          	jalr	1740(ra) # 8000245c <yield>
    80002d98:	b7bd                	j	80002d06 <kerneltrap+0x38>

0000000080002d9a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d9a:	1101                	addi	sp,sp,-32
    80002d9c:	ec06                	sd	ra,24(sp)
    80002d9e:	e822                	sd	s0,16(sp)
    80002da0:	e426                	sd	s1,8(sp)
    80002da2:	1000                	addi	s0,sp,32
    80002da4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002da6:	fffff097          	auipc	ra,0xfffff
    80002daa:	f1c080e7          	jalr	-228(ra) # 80001cc2 <myproc>
  switch (n) {
    80002dae:	4795                	li	a5,5
    80002db0:	0497e163          	bltu	a5,s1,80002df2 <argraw+0x58>
    80002db4:	048a                	slli	s1,s1,0x2
    80002db6:	00006717          	auipc	a4,0x6
    80002dba:	f4a70713          	addi	a4,a4,-182 # 80008d00 <states.0+0x28>
    80002dbe:	94ba                	add	s1,s1,a4
    80002dc0:	409c                	lw	a5,0(s1)
    80002dc2:	97ba                	add	a5,a5,a4
    80002dc4:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002dc6:	713c                	ld	a5,96(a0)
    80002dc8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002dca:	60e2                	ld	ra,24(sp)
    80002dcc:	6442                	ld	s0,16(sp)
    80002dce:	64a2                	ld	s1,8(sp)
    80002dd0:	6105                	addi	sp,sp,32
    80002dd2:	8082                	ret
    return p->tf->a1;
    80002dd4:	713c                	ld	a5,96(a0)
    80002dd6:	7fa8                	ld	a0,120(a5)
    80002dd8:	bfcd                	j	80002dca <argraw+0x30>
    return p->tf->a2;
    80002dda:	713c                	ld	a5,96(a0)
    80002ddc:	63c8                	ld	a0,128(a5)
    80002dde:	b7f5                	j	80002dca <argraw+0x30>
    return p->tf->a3;
    80002de0:	713c                	ld	a5,96(a0)
    80002de2:	67c8                	ld	a0,136(a5)
    80002de4:	b7dd                	j	80002dca <argraw+0x30>
    return p->tf->a4;
    80002de6:	713c                	ld	a5,96(a0)
    80002de8:	6bc8                	ld	a0,144(a5)
    80002dea:	b7c5                	j	80002dca <argraw+0x30>
    return p->tf->a5;
    80002dec:	713c                	ld	a5,96(a0)
    80002dee:	6fc8                	ld	a0,152(a5)
    80002df0:	bfe9                	j	80002dca <argraw+0x30>
  panic("argraw");
    80002df2:	00006517          	auipc	a0,0x6
    80002df6:	98650513          	addi	a0,a0,-1658 # 80008778 <userret+0x6e8>
    80002dfa:	ffffd097          	auipc	ra,0xffffd
    80002dfe:	74e080e7          	jalr	1870(ra) # 80000548 <panic>

0000000080002e02 <fetchaddr>:
{
    80002e02:	1101                	addi	sp,sp,-32
    80002e04:	ec06                	sd	ra,24(sp)
    80002e06:	e822                	sd	s0,16(sp)
    80002e08:	e426                	sd	s1,8(sp)
    80002e0a:	e04a                	sd	s2,0(sp)
    80002e0c:	1000                	addi	s0,sp,32
    80002e0e:	84aa                	mv	s1,a0
    80002e10:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e12:	fffff097          	auipc	ra,0xfffff
    80002e16:	eb0080e7          	jalr	-336(ra) # 80001cc2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002e1a:	693c                	ld	a5,80(a0)
    80002e1c:	02f4f863          	bgeu	s1,a5,80002e4c <fetchaddr+0x4a>
    80002e20:	00848713          	addi	a4,s1,8
    80002e24:	02e7e663          	bltu	a5,a4,80002e50 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e28:	46a1                	li	a3,8
    80002e2a:	8626                	mv	a2,s1
    80002e2c:	85ca                	mv	a1,s2
    80002e2e:	6d28                	ld	a0,88(a0)
    80002e30:	fffff097          	auipc	ra,0xfffff
    80002e34:	c10080e7          	jalr	-1008(ra) # 80001a40 <copyin>
    80002e38:	00a03533          	snez	a0,a0
    80002e3c:	40a00533          	neg	a0,a0
}
    80002e40:	60e2                	ld	ra,24(sp)
    80002e42:	6442                	ld	s0,16(sp)
    80002e44:	64a2                	ld	s1,8(sp)
    80002e46:	6902                	ld	s2,0(sp)
    80002e48:	6105                	addi	sp,sp,32
    80002e4a:	8082                	ret
    return -1;
    80002e4c:	557d                	li	a0,-1
    80002e4e:	bfcd                	j	80002e40 <fetchaddr+0x3e>
    80002e50:	557d                	li	a0,-1
    80002e52:	b7fd                	j	80002e40 <fetchaddr+0x3e>

0000000080002e54 <fetchstr>:
{
    80002e54:	7179                	addi	sp,sp,-48
    80002e56:	f406                	sd	ra,40(sp)
    80002e58:	f022                	sd	s0,32(sp)
    80002e5a:	ec26                	sd	s1,24(sp)
    80002e5c:	e84a                	sd	s2,16(sp)
    80002e5e:	e44e                	sd	s3,8(sp)
    80002e60:	1800                	addi	s0,sp,48
    80002e62:	892a                	mv	s2,a0
    80002e64:	84ae                	mv	s1,a1
    80002e66:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e68:	fffff097          	auipc	ra,0xfffff
    80002e6c:	e5a080e7          	jalr	-422(ra) # 80001cc2 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002e70:	86ce                	mv	a3,s3
    80002e72:	864a                	mv	a2,s2
    80002e74:	85a6                	mv	a1,s1
    80002e76:	6d28                	ld	a0,88(a0)
    80002e78:	fffff097          	auipc	ra,0xfffff
    80002e7c:	c56080e7          	jalr	-938(ra) # 80001ace <copyinstr>
  if(err < 0)
    80002e80:	00054763          	bltz	a0,80002e8e <fetchstr+0x3a>
  return strlen(buf);
    80002e84:	8526                	mv	a0,s1
    80002e86:	ffffe097          	auipc	ra,0xffffe
    80002e8a:	204080e7          	jalr	516(ra) # 8000108a <strlen>
}
    80002e8e:	70a2                	ld	ra,40(sp)
    80002e90:	7402                	ld	s0,32(sp)
    80002e92:	64e2                	ld	s1,24(sp)
    80002e94:	6942                	ld	s2,16(sp)
    80002e96:	69a2                	ld	s3,8(sp)
    80002e98:	6145                	addi	sp,sp,48
    80002e9a:	8082                	ret

0000000080002e9c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e9c:	1101                	addi	sp,sp,-32
    80002e9e:	ec06                	sd	ra,24(sp)
    80002ea0:	e822                	sd	s0,16(sp)
    80002ea2:	e426                	sd	s1,8(sp)
    80002ea4:	1000                	addi	s0,sp,32
    80002ea6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ea8:	00000097          	auipc	ra,0x0
    80002eac:	ef2080e7          	jalr	-270(ra) # 80002d9a <argraw>
    80002eb0:	c088                	sw	a0,0(s1)
  return 0;
}
    80002eb2:	4501                	li	a0,0
    80002eb4:	60e2                	ld	ra,24(sp)
    80002eb6:	6442                	ld	s0,16(sp)
    80002eb8:	64a2                	ld	s1,8(sp)
    80002eba:	6105                	addi	sp,sp,32
    80002ebc:	8082                	ret

0000000080002ebe <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002ebe:	1101                	addi	sp,sp,-32
    80002ec0:	ec06                	sd	ra,24(sp)
    80002ec2:	e822                	sd	s0,16(sp)
    80002ec4:	e426                	sd	s1,8(sp)
    80002ec6:	1000                	addi	s0,sp,32
    80002ec8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eca:	00000097          	auipc	ra,0x0
    80002ece:	ed0080e7          	jalr	-304(ra) # 80002d9a <argraw>
    80002ed2:	e088                	sd	a0,0(s1)
  return 0;
}
    80002ed4:	4501                	li	a0,0
    80002ed6:	60e2                	ld	ra,24(sp)
    80002ed8:	6442                	ld	s0,16(sp)
    80002eda:	64a2                	ld	s1,8(sp)
    80002edc:	6105                	addi	sp,sp,32
    80002ede:	8082                	ret

0000000080002ee0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ee0:	1101                	addi	sp,sp,-32
    80002ee2:	ec06                	sd	ra,24(sp)
    80002ee4:	e822                	sd	s0,16(sp)
    80002ee6:	e426                	sd	s1,8(sp)
    80002ee8:	e04a                	sd	s2,0(sp)
    80002eea:	1000                	addi	s0,sp,32
    80002eec:	84ae                	mv	s1,a1
    80002eee:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002ef0:	00000097          	auipc	ra,0x0
    80002ef4:	eaa080e7          	jalr	-342(ra) # 80002d9a <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002ef8:	864a                	mv	a2,s2
    80002efa:	85a6                	mv	a1,s1
    80002efc:	00000097          	auipc	ra,0x0
    80002f00:	f58080e7          	jalr	-168(ra) # 80002e54 <fetchstr>
}
    80002f04:	60e2                	ld	ra,24(sp)
    80002f06:	6442                	ld	s0,16(sp)
    80002f08:	64a2                	ld	s1,8(sp)
    80002f0a:	6902                	ld	s2,0(sp)
    80002f0c:	6105                	addi	sp,sp,32
    80002f0e:	8082                	ret

0000000080002f10 <syscall>:
[SYS_crash]   sys_crash,
};

void
syscall(void)
{
    80002f10:	1101                	addi	sp,sp,-32
    80002f12:	ec06                	sd	ra,24(sp)
    80002f14:	e822                	sd	s0,16(sp)
    80002f16:	e426                	sd	s1,8(sp)
    80002f18:	e04a                	sd	s2,0(sp)
    80002f1a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002f1c:	fffff097          	auipc	ra,0xfffff
    80002f20:	da6080e7          	jalr	-602(ra) # 80001cc2 <myproc>
    80002f24:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002f26:	06053903          	ld	s2,96(a0)
    80002f2a:	0a893783          	ld	a5,168(s2)
    80002f2e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f32:	37fd                	addiw	a5,a5,-1
    80002f34:	4759                	li	a4,22
    80002f36:	00f76f63          	bltu	a4,a5,80002f54 <syscall+0x44>
    80002f3a:	00369713          	slli	a4,a3,0x3
    80002f3e:	00006797          	auipc	a5,0x6
    80002f42:	dda78793          	addi	a5,a5,-550 # 80008d18 <syscalls>
    80002f46:	97ba                	add	a5,a5,a4
    80002f48:	639c                	ld	a5,0(a5)
    80002f4a:	c789                	beqz	a5,80002f54 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002f4c:	9782                	jalr	a5
    80002f4e:	06a93823          	sd	a0,112(s2)
    80002f52:	a839                	j	80002f70 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f54:	16048613          	addi	a2,s1,352
    80002f58:	40ac                	lw	a1,64(s1)
    80002f5a:	00006517          	auipc	a0,0x6
    80002f5e:	82650513          	addi	a0,a0,-2010 # 80008780 <userret+0x6f0>
    80002f62:	ffffd097          	auipc	ra,0xffffd
    80002f66:	640080e7          	jalr	1600(ra) # 800005a2 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002f6a:	70bc                	ld	a5,96(s1)
    80002f6c:	577d                	li	a4,-1
    80002f6e:	fbb8                	sd	a4,112(a5)
  }
}
    80002f70:	60e2                	ld	ra,24(sp)
    80002f72:	6442                	ld	s0,16(sp)
    80002f74:	64a2                	ld	s1,8(sp)
    80002f76:	6902                	ld	s2,0(sp)
    80002f78:	6105                	addi	sp,sp,32
    80002f7a:	8082                	ret

0000000080002f7c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f7c:	1101                	addi	sp,sp,-32
    80002f7e:	ec06                	sd	ra,24(sp)
    80002f80:	e822                	sd	s0,16(sp)
    80002f82:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f84:	fec40593          	addi	a1,s0,-20
    80002f88:	4501                	li	a0,0
    80002f8a:	00000097          	auipc	ra,0x0
    80002f8e:	f12080e7          	jalr	-238(ra) # 80002e9c <argint>
    return -1;
    80002f92:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f94:	00054963          	bltz	a0,80002fa6 <sys_exit+0x2a>
  exit(n);
    80002f98:	fec42503          	lw	a0,-20(s0)
    80002f9c:	fffff097          	auipc	ra,0xfffff
    80002fa0:	3b2080e7          	jalr	946(ra) # 8000234e <exit>
  return 0;  // not reached
    80002fa4:	4781                	li	a5,0
}
    80002fa6:	853e                	mv	a0,a5
    80002fa8:	60e2                	ld	ra,24(sp)
    80002faa:	6442                	ld	s0,16(sp)
    80002fac:	6105                	addi	sp,sp,32
    80002fae:	8082                	ret

0000000080002fb0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002fb0:	1141                	addi	sp,sp,-16
    80002fb2:	e406                	sd	ra,8(sp)
    80002fb4:	e022                	sd	s0,0(sp)
    80002fb6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002fb8:	fffff097          	auipc	ra,0xfffff
    80002fbc:	d0a080e7          	jalr	-758(ra) # 80001cc2 <myproc>
}
    80002fc0:	4128                	lw	a0,64(a0)
    80002fc2:	60a2                	ld	ra,8(sp)
    80002fc4:	6402                	ld	s0,0(sp)
    80002fc6:	0141                	addi	sp,sp,16
    80002fc8:	8082                	ret

0000000080002fca <sys_fork>:

uint64
sys_fork(void)
{
    80002fca:	1141                	addi	sp,sp,-16
    80002fcc:	e406                	sd	ra,8(sp)
    80002fce:	e022                	sd	s0,0(sp)
    80002fd0:	0800                	addi	s0,sp,16
  return fork();
    80002fd2:	fffff097          	auipc	ra,0xfffff
    80002fd6:	05a080e7          	jalr	90(ra) # 8000202c <fork>
}
    80002fda:	60a2                	ld	ra,8(sp)
    80002fdc:	6402                	ld	s0,0(sp)
    80002fde:	0141                	addi	sp,sp,16
    80002fe0:	8082                	ret

0000000080002fe2 <sys_wait>:

uint64
sys_wait(void)
{
    80002fe2:	1101                	addi	sp,sp,-32
    80002fe4:	ec06                	sd	ra,24(sp)
    80002fe6:	e822                	sd	s0,16(sp)
    80002fe8:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002fea:	fe840593          	addi	a1,s0,-24
    80002fee:	4501                	li	a0,0
    80002ff0:	00000097          	auipc	ra,0x0
    80002ff4:	ece080e7          	jalr	-306(ra) # 80002ebe <argaddr>
    80002ff8:	87aa                	mv	a5,a0
    return -1;
    80002ffa:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002ffc:	0007c863          	bltz	a5,8000300c <sys_wait+0x2a>
  return wait(p);
    80003000:	fe843503          	ld	a0,-24(s0)
    80003004:	fffff097          	auipc	ra,0xfffff
    80003008:	512080e7          	jalr	1298(ra) # 80002516 <wait>
}
    8000300c:	60e2                	ld	ra,24(sp)
    8000300e:	6442                	ld	s0,16(sp)
    80003010:	6105                	addi	sp,sp,32
    80003012:	8082                	ret

0000000080003014 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003014:	7179                	addi	sp,sp,-48
    80003016:	f406                	sd	ra,40(sp)
    80003018:	f022                	sd	s0,32(sp)
    8000301a:	ec26                	sd	s1,24(sp)
    8000301c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000301e:	fdc40593          	addi	a1,s0,-36
    80003022:	4501                	li	a0,0
    80003024:	00000097          	auipc	ra,0x0
    80003028:	e78080e7          	jalr	-392(ra) # 80002e9c <argint>
    return -1;
    8000302c:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000302e:	00054f63          	bltz	a0,8000304c <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003032:	fffff097          	auipc	ra,0xfffff
    80003036:	c90080e7          	jalr	-880(ra) # 80001cc2 <myproc>
    8000303a:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    8000303c:	fdc42503          	lw	a0,-36(s0)
    80003040:	fffff097          	auipc	ra,0xfffff
    80003044:	f78080e7          	jalr	-136(ra) # 80001fb8 <growproc>
    80003048:	00054863          	bltz	a0,80003058 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    8000304c:	8526                	mv	a0,s1
    8000304e:	70a2                	ld	ra,40(sp)
    80003050:	7402                	ld	s0,32(sp)
    80003052:	64e2                	ld	s1,24(sp)
    80003054:	6145                	addi	sp,sp,48
    80003056:	8082                	ret
    return -1;
    80003058:	54fd                	li	s1,-1
    8000305a:	bfcd                	j	8000304c <sys_sbrk+0x38>

000000008000305c <sys_sleep>:

uint64
sys_sleep(void)
{
    8000305c:	7139                	addi	sp,sp,-64
    8000305e:	fc06                	sd	ra,56(sp)
    80003060:	f822                	sd	s0,48(sp)
    80003062:	f426                	sd	s1,40(sp)
    80003064:	f04a                	sd	s2,32(sp)
    80003066:	ec4e                	sd	s3,24(sp)
    80003068:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000306a:	fcc40593          	addi	a1,s0,-52
    8000306e:	4501                	li	a0,0
    80003070:	00000097          	auipc	ra,0x0
    80003074:	e2c080e7          	jalr	-468(ra) # 80002e9c <argint>
    return -1;
    80003078:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000307a:	06054563          	bltz	a0,800030e4 <sys_sleep+0x88>
  acquire(&tickslock);
    8000307e:	0001f517          	auipc	a0,0x1f
    80003082:	7ba50513          	addi	a0,a0,1978 # 80022838 <tickslock>
    80003086:	ffffe097          	auipc	ra,0xffffe
    8000308a:	c16080e7          	jalr	-1002(ra) # 80000c9c <acquire>
  ticks0 = ticks;
    8000308e:	00031917          	auipc	s2,0x31
    80003092:	fb292903          	lw	s2,-78(s2) # 80034040 <ticks>
  while(ticks - ticks0 < n){
    80003096:	fcc42783          	lw	a5,-52(s0)
    8000309a:	cf85                	beqz	a5,800030d2 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000309c:	0001f997          	auipc	s3,0x1f
    800030a0:	79c98993          	addi	s3,s3,1948 # 80022838 <tickslock>
    800030a4:	00031497          	auipc	s1,0x31
    800030a8:	f9c48493          	addi	s1,s1,-100 # 80034040 <ticks>
    if(myproc()->killed){
    800030ac:	fffff097          	auipc	ra,0xfffff
    800030b0:	c16080e7          	jalr	-1002(ra) # 80001cc2 <myproc>
    800030b4:	5d1c                	lw	a5,56(a0)
    800030b6:	ef9d                	bnez	a5,800030f4 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800030b8:	85ce                	mv	a1,s3
    800030ba:	8526                	mv	a0,s1
    800030bc:	fffff097          	auipc	ra,0xfffff
    800030c0:	3dc080e7          	jalr	988(ra) # 80002498 <sleep>
  while(ticks - ticks0 < n){
    800030c4:	409c                	lw	a5,0(s1)
    800030c6:	412787bb          	subw	a5,a5,s2
    800030ca:	fcc42703          	lw	a4,-52(s0)
    800030ce:	fce7efe3          	bltu	a5,a4,800030ac <sys_sleep+0x50>
  }
  release(&tickslock);
    800030d2:	0001f517          	auipc	a0,0x1f
    800030d6:	76650513          	addi	a0,a0,1894 # 80022838 <tickslock>
    800030da:	ffffe097          	auipc	ra,0xffffe
    800030de:	c32080e7          	jalr	-974(ra) # 80000d0c <release>
  return 0;
    800030e2:	4781                	li	a5,0
}
    800030e4:	853e                	mv	a0,a5
    800030e6:	70e2                	ld	ra,56(sp)
    800030e8:	7442                	ld	s0,48(sp)
    800030ea:	74a2                	ld	s1,40(sp)
    800030ec:	7902                	ld	s2,32(sp)
    800030ee:	69e2                	ld	s3,24(sp)
    800030f0:	6121                	addi	sp,sp,64
    800030f2:	8082                	ret
      release(&tickslock);
    800030f4:	0001f517          	auipc	a0,0x1f
    800030f8:	74450513          	addi	a0,a0,1860 # 80022838 <tickslock>
    800030fc:	ffffe097          	auipc	ra,0xffffe
    80003100:	c10080e7          	jalr	-1008(ra) # 80000d0c <release>
      return -1;
    80003104:	57fd                	li	a5,-1
    80003106:	bff9                	j	800030e4 <sys_sleep+0x88>

0000000080003108 <sys_kill>:

uint64
sys_kill(void)
{
    80003108:	1101                	addi	sp,sp,-32
    8000310a:	ec06                	sd	ra,24(sp)
    8000310c:	e822                	sd	s0,16(sp)
    8000310e:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003110:	fec40593          	addi	a1,s0,-20
    80003114:	4501                	li	a0,0
    80003116:	00000097          	auipc	ra,0x0
    8000311a:	d86080e7          	jalr	-634(ra) # 80002e9c <argint>
    8000311e:	87aa                	mv	a5,a0
    return -1;
    80003120:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003122:	0007c863          	bltz	a5,80003132 <sys_kill+0x2a>
  return kill(pid);
    80003126:	fec42503          	lw	a0,-20(s0)
    8000312a:	fffff097          	auipc	ra,0xfffff
    8000312e:	558080e7          	jalr	1368(ra) # 80002682 <kill>
}
    80003132:	60e2                	ld	ra,24(sp)
    80003134:	6442                	ld	s0,16(sp)
    80003136:	6105                	addi	sp,sp,32
    80003138:	8082                	ret

000000008000313a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000313a:	1101                	addi	sp,sp,-32
    8000313c:	ec06                	sd	ra,24(sp)
    8000313e:	e822                	sd	s0,16(sp)
    80003140:	e426                	sd	s1,8(sp)
    80003142:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003144:	0001f517          	auipc	a0,0x1f
    80003148:	6f450513          	addi	a0,a0,1780 # 80022838 <tickslock>
    8000314c:	ffffe097          	auipc	ra,0xffffe
    80003150:	b50080e7          	jalr	-1200(ra) # 80000c9c <acquire>
  xticks = ticks;
    80003154:	00031497          	auipc	s1,0x31
    80003158:	eec4a483          	lw	s1,-276(s1) # 80034040 <ticks>
  release(&tickslock);
    8000315c:	0001f517          	auipc	a0,0x1f
    80003160:	6dc50513          	addi	a0,a0,1756 # 80022838 <tickslock>
    80003164:	ffffe097          	auipc	ra,0xffffe
    80003168:	ba8080e7          	jalr	-1112(ra) # 80000d0c <release>
  return xticks;
}
    8000316c:	02049513          	slli	a0,s1,0x20
    80003170:	9101                	srli	a0,a0,0x20
    80003172:	60e2                	ld	ra,24(sp)
    80003174:	6442                	ld	s0,16(sp)
    80003176:	64a2                	ld	s1,8(sp)
    80003178:	6105                	addi	sp,sp,32
    8000317a:	8082                	ret

000000008000317c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000317c:	7179                	addi	sp,sp,-48
    8000317e:	f406                	sd	ra,40(sp)
    80003180:	f022                	sd	s0,32(sp)
    80003182:	ec26                	sd	s1,24(sp)
    80003184:	e84a                	sd	s2,16(sp)
    80003186:	e44e                	sd	s3,8(sp)
    80003188:	e052                	sd	s4,0(sp)
    8000318a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000318c:	00005597          	auipc	a1,0x5
    80003190:	14c58593          	addi	a1,a1,332 # 800082d8 <userret+0x248>
    80003194:	0001f517          	auipc	a0,0x1f
    80003198:	6c450513          	addi	a0,a0,1732 # 80022858 <bcache>
    8000319c:	ffffe097          	auipc	ra,0xffffe
    800031a0:	9b2080e7          	jalr	-1614(ra) # 80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800031a4:	00027797          	auipc	a5,0x27
    800031a8:	6b478793          	addi	a5,a5,1716 # 8002a858 <bcache+0x8000>
    800031ac:	00028717          	auipc	a4,0x28
    800031b0:	a0c70713          	addi	a4,a4,-1524 # 8002abb8 <bcache+0x8360>
    800031b4:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    800031b8:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031bc:	0001f497          	auipc	s1,0x1f
    800031c0:	6bc48493          	addi	s1,s1,1724 # 80022878 <bcache+0x20>
    b->next = bcache.head.next;
    800031c4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800031c6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800031c8:	00005a17          	auipc	s4,0x5
    800031cc:	5d8a0a13          	addi	s4,s4,1496 # 800087a0 <userret+0x710>
    b->next = bcache.head.next;
    800031d0:	3b893783          	ld	a5,952(s2)
    800031d4:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    800031d6:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    800031da:	85d2                	mv	a1,s4
    800031dc:	01048513          	addi	a0,s1,16
    800031e0:	00001097          	auipc	ra,0x1
    800031e4:	6f0080e7          	jalr	1776(ra) # 800048d0 <initsleeplock>
    bcache.head.next->prev = b;
    800031e8:	3b893783          	ld	a5,952(s2)
    800031ec:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    800031ee:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031f2:	46048493          	addi	s1,s1,1120
    800031f6:	fd349de3          	bne	s1,s3,800031d0 <binit+0x54>
  }
}
    800031fa:	70a2                	ld	ra,40(sp)
    800031fc:	7402                	ld	s0,32(sp)
    800031fe:	64e2                	ld	s1,24(sp)
    80003200:	6942                	ld	s2,16(sp)
    80003202:	69a2                	ld	s3,8(sp)
    80003204:	6a02                	ld	s4,0(sp)
    80003206:	6145                	addi	sp,sp,48
    80003208:	8082                	ret

000000008000320a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000320a:	7179                	addi	sp,sp,-48
    8000320c:	f406                	sd	ra,40(sp)
    8000320e:	f022                	sd	s0,32(sp)
    80003210:	ec26                	sd	s1,24(sp)
    80003212:	e84a                	sd	s2,16(sp)
    80003214:	e44e                	sd	s3,8(sp)
    80003216:	1800                	addi	s0,sp,48
    80003218:	892a                	mv	s2,a0
    8000321a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000321c:	0001f517          	auipc	a0,0x1f
    80003220:	63c50513          	addi	a0,a0,1596 # 80022858 <bcache>
    80003224:	ffffe097          	auipc	ra,0xffffe
    80003228:	a78080e7          	jalr	-1416(ra) # 80000c9c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000322c:	00028497          	auipc	s1,0x28
    80003230:	9e44b483          	ld	s1,-1564(s1) # 8002ac10 <bcache+0x83b8>
    80003234:	00028797          	auipc	a5,0x28
    80003238:	98478793          	addi	a5,a5,-1660 # 8002abb8 <bcache+0x8360>
    8000323c:	02f48f63          	beq	s1,a5,8000327a <bread+0x70>
    80003240:	873e                	mv	a4,a5
    80003242:	a021                	j	8000324a <bread+0x40>
    80003244:	6ca4                	ld	s1,88(s1)
    80003246:	02e48a63          	beq	s1,a4,8000327a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000324a:	449c                	lw	a5,8(s1)
    8000324c:	ff279ce3          	bne	a5,s2,80003244 <bread+0x3a>
    80003250:	44dc                	lw	a5,12(s1)
    80003252:	ff3799e3          	bne	a5,s3,80003244 <bread+0x3a>
      b->refcnt++;
    80003256:	44bc                	lw	a5,72(s1)
    80003258:	2785                	addiw	a5,a5,1
    8000325a:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    8000325c:	0001f517          	auipc	a0,0x1f
    80003260:	5fc50513          	addi	a0,a0,1532 # 80022858 <bcache>
    80003264:	ffffe097          	auipc	ra,0xffffe
    80003268:	aa8080e7          	jalr	-1368(ra) # 80000d0c <release>
      acquiresleep(&b->lock);
    8000326c:	01048513          	addi	a0,s1,16
    80003270:	00001097          	auipc	ra,0x1
    80003274:	69a080e7          	jalr	1690(ra) # 8000490a <acquiresleep>
      return b;
    80003278:	a8b9                	j	800032d6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000327a:	00028497          	auipc	s1,0x28
    8000327e:	98e4b483          	ld	s1,-1650(s1) # 8002ac08 <bcache+0x83b0>
    80003282:	00028797          	auipc	a5,0x28
    80003286:	93678793          	addi	a5,a5,-1738 # 8002abb8 <bcache+0x8360>
    8000328a:	00f48863          	beq	s1,a5,8000329a <bread+0x90>
    8000328e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003290:	44bc                	lw	a5,72(s1)
    80003292:	cf81                	beqz	a5,800032aa <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003294:	68a4                	ld	s1,80(s1)
    80003296:	fee49de3          	bne	s1,a4,80003290 <bread+0x86>
  panic("bget: no buffers");
    8000329a:	00005517          	auipc	a0,0x5
    8000329e:	50e50513          	addi	a0,a0,1294 # 800087a8 <userret+0x718>
    800032a2:	ffffd097          	auipc	ra,0xffffd
    800032a6:	2a6080e7          	jalr	678(ra) # 80000548 <panic>
      b->dev = dev;
    800032aa:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800032ae:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800032b2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800032b6:	4785                	li	a5,1
    800032b8:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    800032ba:	0001f517          	auipc	a0,0x1f
    800032be:	59e50513          	addi	a0,a0,1438 # 80022858 <bcache>
    800032c2:	ffffe097          	auipc	ra,0xffffe
    800032c6:	a4a080e7          	jalr	-1462(ra) # 80000d0c <release>
      acquiresleep(&b->lock);
    800032ca:	01048513          	addi	a0,s1,16
    800032ce:	00001097          	auipc	ra,0x1
    800032d2:	63c080e7          	jalr	1596(ra) # 8000490a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800032d6:	409c                	lw	a5,0(s1)
    800032d8:	cb89                	beqz	a5,800032ea <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    800032da:	8526                	mv	a0,s1
    800032dc:	70a2                	ld	ra,40(sp)
    800032de:	7402                	ld	s0,32(sp)
    800032e0:	64e2                	ld	s1,24(sp)
    800032e2:	6942                	ld	s2,16(sp)
    800032e4:	69a2                	ld	s3,8(sp)
    800032e6:	6145                	addi	sp,sp,48
    800032e8:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    800032ea:	4601                	li	a2,0
    800032ec:	85a6                	mv	a1,s1
    800032ee:	4488                	lw	a0,8(s1)
    800032f0:	00003097          	auipc	ra,0x3
    800032f4:	2ec080e7          	jalr	748(ra) # 800065dc <virtio_disk_rw>
    b->valid = 1;
    800032f8:	4785                	li	a5,1
    800032fa:	c09c                	sw	a5,0(s1)
  return b;
    800032fc:	bff9                	j	800032da <bread+0xd0>

00000000800032fe <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032fe:	1101                	addi	sp,sp,-32
    80003300:	ec06                	sd	ra,24(sp)
    80003302:	e822                	sd	s0,16(sp)
    80003304:	e426                	sd	s1,8(sp)
    80003306:	1000                	addi	s0,sp,32
    80003308:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000330a:	0541                	addi	a0,a0,16
    8000330c:	00001097          	auipc	ra,0x1
    80003310:	698080e7          	jalr	1688(ra) # 800049a4 <holdingsleep>
    80003314:	cd09                	beqz	a0,8000332e <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80003316:	4605                	li	a2,1
    80003318:	85a6                	mv	a1,s1
    8000331a:	4488                	lw	a0,8(s1)
    8000331c:	00003097          	auipc	ra,0x3
    80003320:	2c0080e7          	jalr	704(ra) # 800065dc <virtio_disk_rw>
}
    80003324:	60e2                	ld	ra,24(sp)
    80003326:	6442                	ld	s0,16(sp)
    80003328:	64a2                	ld	s1,8(sp)
    8000332a:	6105                	addi	sp,sp,32
    8000332c:	8082                	ret
    panic("bwrite");
    8000332e:	00005517          	auipc	a0,0x5
    80003332:	49250513          	addi	a0,a0,1170 # 800087c0 <userret+0x730>
    80003336:	ffffd097          	auipc	ra,0xffffd
    8000333a:	212080e7          	jalr	530(ra) # 80000548 <panic>

000000008000333e <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    8000333e:	1101                	addi	sp,sp,-32
    80003340:	ec06                	sd	ra,24(sp)
    80003342:	e822                	sd	s0,16(sp)
    80003344:	e426                	sd	s1,8(sp)
    80003346:	e04a                	sd	s2,0(sp)
    80003348:	1000                	addi	s0,sp,32
    8000334a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000334c:	01050913          	addi	s2,a0,16
    80003350:	854a                	mv	a0,s2
    80003352:	00001097          	auipc	ra,0x1
    80003356:	652080e7          	jalr	1618(ra) # 800049a4 <holdingsleep>
    8000335a:	c92d                	beqz	a0,800033cc <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000335c:	854a                	mv	a0,s2
    8000335e:	00001097          	auipc	ra,0x1
    80003362:	602080e7          	jalr	1538(ra) # 80004960 <releasesleep>

  acquire(&bcache.lock);
    80003366:	0001f517          	auipc	a0,0x1f
    8000336a:	4f250513          	addi	a0,a0,1266 # 80022858 <bcache>
    8000336e:	ffffe097          	auipc	ra,0xffffe
    80003372:	92e080e7          	jalr	-1746(ra) # 80000c9c <acquire>
  b->refcnt--;
    80003376:	44bc                	lw	a5,72(s1)
    80003378:	37fd                	addiw	a5,a5,-1
    8000337a:	0007871b          	sext.w	a4,a5
    8000337e:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    80003380:	eb05                	bnez	a4,800033b0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003382:	6cbc                	ld	a5,88(s1)
    80003384:	68b8                	ld	a4,80(s1)
    80003386:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    80003388:	68bc                	ld	a5,80(s1)
    8000338a:	6cb8                	ld	a4,88(s1)
    8000338c:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    8000338e:	00027797          	auipc	a5,0x27
    80003392:	4ca78793          	addi	a5,a5,1226 # 8002a858 <bcache+0x8000>
    80003396:	3b87b703          	ld	a4,952(a5)
    8000339a:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    8000339c:	00028717          	auipc	a4,0x28
    800033a0:	81c70713          	addi	a4,a4,-2020 # 8002abb8 <bcache+0x8360>
    800033a4:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    800033a6:	3b87b703          	ld	a4,952(a5)
    800033aa:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    800033ac:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    800033b0:	0001f517          	auipc	a0,0x1f
    800033b4:	4a850513          	addi	a0,a0,1192 # 80022858 <bcache>
    800033b8:	ffffe097          	auipc	ra,0xffffe
    800033bc:	954080e7          	jalr	-1708(ra) # 80000d0c <release>
}
    800033c0:	60e2                	ld	ra,24(sp)
    800033c2:	6442                	ld	s0,16(sp)
    800033c4:	64a2                	ld	s1,8(sp)
    800033c6:	6902                	ld	s2,0(sp)
    800033c8:	6105                	addi	sp,sp,32
    800033ca:	8082                	ret
    panic("brelse");
    800033cc:	00005517          	auipc	a0,0x5
    800033d0:	3fc50513          	addi	a0,a0,1020 # 800087c8 <userret+0x738>
    800033d4:	ffffd097          	auipc	ra,0xffffd
    800033d8:	174080e7          	jalr	372(ra) # 80000548 <panic>

00000000800033dc <bpin>:

void
bpin(struct buf *b) {
    800033dc:	1101                	addi	sp,sp,-32
    800033de:	ec06                	sd	ra,24(sp)
    800033e0:	e822                	sd	s0,16(sp)
    800033e2:	e426                	sd	s1,8(sp)
    800033e4:	1000                	addi	s0,sp,32
    800033e6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033e8:	0001f517          	auipc	a0,0x1f
    800033ec:	47050513          	addi	a0,a0,1136 # 80022858 <bcache>
    800033f0:	ffffe097          	auipc	ra,0xffffe
    800033f4:	8ac080e7          	jalr	-1876(ra) # 80000c9c <acquire>
  b->refcnt++;
    800033f8:	44bc                	lw	a5,72(s1)
    800033fa:	2785                	addiw	a5,a5,1
    800033fc:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    800033fe:	0001f517          	auipc	a0,0x1f
    80003402:	45a50513          	addi	a0,a0,1114 # 80022858 <bcache>
    80003406:	ffffe097          	auipc	ra,0xffffe
    8000340a:	906080e7          	jalr	-1786(ra) # 80000d0c <release>
}
    8000340e:	60e2                	ld	ra,24(sp)
    80003410:	6442                	ld	s0,16(sp)
    80003412:	64a2                	ld	s1,8(sp)
    80003414:	6105                	addi	sp,sp,32
    80003416:	8082                	ret

0000000080003418 <bunpin>:

void
bunpin(struct buf *b) {
    80003418:	1101                	addi	sp,sp,-32
    8000341a:	ec06                	sd	ra,24(sp)
    8000341c:	e822                	sd	s0,16(sp)
    8000341e:	e426                	sd	s1,8(sp)
    80003420:	1000                	addi	s0,sp,32
    80003422:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003424:	0001f517          	auipc	a0,0x1f
    80003428:	43450513          	addi	a0,a0,1076 # 80022858 <bcache>
    8000342c:	ffffe097          	auipc	ra,0xffffe
    80003430:	870080e7          	jalr	-1936(ra) # 80000c9c <acquire>
  b->refcnt--;
    80003434:	44bc                	lw	a5,72(s1)
    80003436:	37fd                	addiw	a5,a5,-1
    80003438:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    8000343a:	0001f517          	auipc	a0,0x1f
    8000343e:	41e50513          	addi	a0,a0,1054 # 80022858 <bcache>
    80003442:	ffffe097          	auipc	ra,0xffffe
    80003446:	8ca080e7          	jalr	-1846(ra) # 80000d0c <release>
}
    8000344a:	60e2                	ld	ra,24(sp)
    8000344c:	6442                	ld	s0,16(sp)
    8000344e:	64a2                	ld	s1,8(sp)
    80003450:	6105                	addi	sp,sp,32
    80003452:	8082                	ret

0000000080003454 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003454:	1101                	addi	sp,sp,-32
    80003456:	ec06                	sd	ra,24(sp)
    80003458:	e822                	sd	s0,16(sp)
    8000345a:	e426                	sd	s1,8(sp)
    8000345c:	e04a                	sd	s2,0(sp)
    8000345e:	1000                	addi	s0,sp,32
    80003460:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003462:	00d5d59b          	srliw	a1,a1,0xd
    80003466:	00028797          	auipc	a5,0x28
    8000346a:	bce7a783          	lw	a5,-1074(a5) # 8002b034 <sb+0x1c>
    8000346e:	9dbd                	addw	a1,a1,a5
    80003470:	00000097          	auipc	ra,0x0
    80003474:	d9a080e7          	jalr	-614(ra) # 8000320a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003478:	0074f713          	andi	a4,s1,7
    8000347c:	4785                	li	a5,1
    8000347e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003482:	14ce                	slli	s1,s1,0x33
    80003484:	90d9                	srli	s1,s1,0x36
    80003486:	00950733          	add	a4,a0,s1
    8000348a:	06074703          	lbu	a4,96(a4)
    8000348e:	00e7f6b3          	and	a3,a5,a4
    80003492:	c69d                	beqz	a3,800034c0 <bfree+0x6c>
    80003494:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003496:	94aa                	add	s1,s1,a0
    80003498:	fff7c793          	not	a5,a5
    8000349c:	8ff9                	and	a5,a5,a4
    8000349e:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    800034a2:	00001097          	auipc	ra,0x1
    800034a6:	1d0080e7          	jalr	464(ra) # 80004672 <log_write>
  brelse(bp);
    800034aa:	854a                	mv	a0,s2
    800034ac:	00000097          	auipc	ra,0x0
    800034b0:	e92080e7          	jalr	-366(ra) # 8000333e <brelse>
}
    800034b4:	60e2                	ld	ra,24(sp)
    800034b6:	6442                	ld	s0,16(sp)
    800034b8:	64a2                	ld	s1,8(sp)
    800034ba:	6902                	ld	s2,0(sp)
    800034bc:	6105                	addi	sp,sp,32
    800034be:	8082                	ret
    panic("freeing free block");
    800034c0:	00005517          	auipc	a0,0x5
    800034c4:	31050513          	addi	a0,a0,784 # 800087d0 <userret+0x740>
    800034c8:	ffffd097          	auipc	ra,0xffffd
    800034cc:	080080e7          	jalr	128(ra) # 80000548 <panic>

00000000800034d0 <balloc>:
{
    800034d0:	711d                	addi	sp,sp,-96
    800034d2:	ec86                	sd	ra,88(sp)
    800034d4:	e8a2                	sd	s0,80(sp)
    800034d6:	e4a6                	sd	s1,72(sp)
    800034d8:	e0ca                	sd	s2,64(sp)
    800034da:	fc4e                	sd	s3,56(sp)
    800034dc:	f852                	sd	s4,48(sp)
    800034de:	f456                	sd	s5,40(sp)
    800034e0:	f05a                	sd	s6,32(sp)
    800034e2:	ec5e                	sd	s7,24(sp)
    800034e4:	e862                	sd	s8,16(sp)
    800034e6:	e466                	sd	s9,8(sp)
    800034e8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034ea:	00028797          	auipc	a5,0x28
    800034ee:	b327a783          	lw	a5,-1230(a5) # 8002b01c <sb+0x4>
    800034f2:	cbd1                	beqz	a5,80003586 <balloc+0xb6>
    800034f4:	8baa                	mv	s7,a0
    800034f6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034f8:	00028b17          	auipc	s6,0x28
    800034fc:	b20b0b13          	addi	s6,s6,-1248 # 8002b018 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003500:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003502:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003504:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003506:	6c89                	lui	s9,0x2
    80003508:	a831                	j	80003524 <balloc+0x54>
    brelse(bp);
    8000350a:	854a                	mv	a0,s2
    8000350c:	00000097          	auipc	ra,0x0
    80003510:	e32080e7          	jalr	-462(ra) # 8000333e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003514:	015c87bb          	addw	a5,s9,s5
    80003518:	00078a9b          	sext.w	s5,a5
    8000351c:	004b2703          	lw	a4,4(s6)
    80003520:	06eaf363          	bgeu	s5,a4,80003586 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003524:	41fad79b          	sraiw	a5,s5,0x1f
    80003528:	0137d79b          	srliw	a5,a5,0x13
    8000352c:	015787bb          	addw	a5,a5,s5
    80003530:	40d7d79b          	sraiw	a5,a5,0xd
    80003534:	01cb2583          	lw	a1,28(s6)
    80003538:	9dbd                	addw	a1,a1,a5
    8000353a:	855e                	mv	a0,s7
    8000353c:	00000097          	auipc	ra,0x0
    80003540:	cce080e7          	jalr	-818(ra) # 8000320a <bread>
    80003544:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003546:	004b2503          	lw	a0,4(s6)
    8000354a:	000a849b          	sext.w	s1,s5
    8000354e:	8662                	mv	a2,s8
    80003550:	faa4fde3          	bgeu	s1,a0,8000350a <balloc+0x3a>
      m = 1 << (bi % 8);
    80003554:	41f6579b          	sraiw	a5,a2,0x1f
    80003558:	01d7d69b          	srliw	a3,a5,0x1d
    8000355c:	00c6873b          	addw	a4,a3,a2
    80003560:	00777793          	andi	a5,a4,7
    80003564:	9f95                	subw	a5,a5,a3
    80003566:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000356a:	4037571b          	sraiw	a4,a4,0x3
    8000356e:	00e906b3          	add	a3,s2,a4
    80003572:	0606c683          	lbu	a3,96(a3)
    80003576:	00d7f5b3          	and	a1,a5,a3
    8000357a:	cd91                	beqz	a1,80003596 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000357c:	2605                	addiw	a2,a2,1
    8000357e:	2485                	addiw	s1,s1,1
    80003580:	fd4618e3          	bne	a2,s4,80003550 <balloc+0x80>
    80003584:	b759                	j	8000350a <balloc+0x3a>
  panic("balloc: out of blocks");
    80003586:	00005517          	auipc	a0,0x5
    8000358a:	26250513          	addi	a0,a0,610 # 800087e8 <userret+0x758>
    8000358e:	ffffd097          	auipc	ra,0xffffd
    80003592:	fba080e7          	jalr	-70(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003596:	974a                	add	a4,a4,s2
    80003598:	8fd5                	or	a5,a5,a3
    8000359a:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    8000359e:	854a                	mv	a0,s2
    800035a0:	00001097          	auipc	ra,0x1
    800035a4:	0d2080e7          	jalr	210(ra) # 80004672 <log_write>
        brelse(bp);
    800035a8:	854a                	mv	a0,s2
    800035aa:	00000097          	auipc	ra,0x0
    800035ae:	d94080e7          	jalr	-620(ra) # 8000333e <brelse>
  bp = bread(dev, bno);
    800035b2:	85a6                	mv	a1,s1
    800035b4:	855e                	mv	a0,s7
    800035b6:	00000097          	auipc	ra,0x0
    800035ba:	c54080e7          	jalr	-940(ra) # 8000320a <bread>
    800035be:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800035c0:	40000613          	li	a2,1024
    800035c4:	4581                	li	a1,0
    800035c6:	06050513          	addi	a0,a0,96
    800035ca:	ffffe097          	auipc	ra,0xffffe
    800035ce:	93c080e7          	jalr	-1732(ra) # 80000f06 <memset>
  log_write(bp);
    800035d2:	854a                	mv	a0,s2
    800035d4:	00001097          	auipc	ra,0x1
    800035d8:	09e080e7          	jalr	158(ra) # 80004672 <log_write>
  brelse(bp);
    800035dc:	854a                	mv	a0,s2
    800035de:	00000097          	auipc	ra,0x0
    800035e2:	d60080e7          	jalr	-672(ra) # 8000333e <brelse>
}
    800035e6:	8526                	mv	a0,s1
    800035e8:	60e6                	ld	ra,88(sp)
    800035ea:	6446                	ld	s0,80(sp)
    800035ec:	64a6                	ld	s1,72(sp)
    800035ee:	6906                	ld	s2,64(sp)
    800035f0:	79e2                	ld	s3,56(sp)
    800035f2:	7a42                	ld	s4,48(sp)
    800035f4:	7aa2                	ld	s5,40(sp)
    800035f6:	7b02                	ld	s6,32(sp)
    800035f8:	6be2                	ld	s7,24(sp)
    800035fa:	6c42                	ld	s8,16(sp)
    800035fc:	6ca2                	ld	s9,8(sp)
    800035fe:	6125                	addi	sp,sp,96
    80003600:	8082                	ret

0000000080003602 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003602:	7179                	addi	sp,sp,-48
    80003604:	f406                	sd	ra,40(sp)
    80003606:	f022                	sd	s0,32(sp)
    80003608:	ec26                	sd	s1,24(sp)
    8000360a:	e84a                	sd	s2,16(sp)
    8000360c:	e44e                	sd	s3,8(sp)
    8000360e:	e052                	sd	s4,0(sp)
    80003610:	1800                	addi	s0,sp,48
    80003612:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003614:	47ad                	li	a5,11
    80003616:	04b7fe63          	bgeu	a5,a1,80003672 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000361a:	ff45849b          	addiw	s1,a1,-12
    8000361e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003622:	0ff00793          	li	a5,255
    80003626:	0ae7e363          	bltu	a5,a4,800036cc <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000362a:	08852583          	lw	a1,136(a0)
    8000362e:	c5ad                	beqz	a1,80003698 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003630:	00092503          	lw	a0,0(s2)
    80003634:	00000097          	auipc	ra,0x0
    80003638:	bd6080e7          	jalr	-1066(ra) # 8000320a <bread>
    8000363c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000363e:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003642:	02049593          	slli	a1,s1,0x20
    80003646:	9181                	srli	a1,a1,0x20
    80003648:	058a                	slli	a1,a1,0x2
    8000364a:	00b784b3          	add	s1,a5,a1
    8000364e:	0004a983          	lw	s3,0(s1)
    80003652:	04098d63          	beqz	s3,800036ac <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003656:	8552                	mv	a0,s4
    80003658:	00000097          	auipc	ra,0x0
    8000365c:	ce6080e7          	jalr	-794(ra) # 8000333e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003660:	854e                	mv	a0,s3
    80003662:	70a2                	ld	ra,40(sp)
    80003664:	7402                	ld	s0,32(sp)
    80003666:	64e2                	ld	s1,24(sp)
    80003668:	6942                	ld	s2,16(sp)
    8000366a:	69a2                	ld	s3,8(sp)
    8000366c:	6a02                	ld	s4,0(sp)
    8000366e:	6145                	addi	sp,sp,48
    80003670:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003672:	02059493          	slli	s1,a1,0x20
    80003676:	9081                	srli	s1,s1,0x20
    80003678:	048a                	slli	s1,s1,0x2
    8000367a:	94aa                	add	s1,s1,a0
    8000367c:	0584a983          	lw	s3,88(s1)
    80003680:	fe0990e3          	bnez	s3,80003660 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003684:	4108                	lw	a0,0(a0)
    80003686:	00000097          	auipc	ra,0x0
    8000368a:	e4a080e7          	jalr	-438(ra) # 800034d0 <balloc>
    8000368e:	0005099b          	sext.w	s3,a0
    80003692:	0534ac23          	sw	s3,88(s1)
    80003696:	b7e9                	j	80003660 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003698:	4108                	lw	a0,0(a0)
    8000369a:	00000097          	auipc	ra,0x0
    8000369e:	e36080e7          	jalr	-458(ra) # 800034d0 <balloc>
    800036a2:	0005059b          	sext.w	a1,a0
    800036a6:	08b92423          	sw	a1,136(s2)
    800036aa:	b759                	j	80003630 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800036ac:	00092503          	lw	a0,0(s2)
    800036b0:	00000097          	auipc	ra,0x0
    800036b4:	e20080e7          	jalr	-480(ra) # 800034d0 <balloc>
    800036b8:	0005099b          	sext.w	s3,a0
    800036bc:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800036c0:	8552                	mv	a0,s4
    800036c2:	00001097          	auipc	ra,0x1
    800036c6:	fb0080e7          	jalr	-80(ra) # 80004672 <log_write>
    800036ca:	b771                	j	80003656 <bmap+0x54>
  panic("bmap: out of range");
    800036cc:	00005517          	auipc	a0,0x5
    800036d0:	13450513          	addi	a0,a0,308 # 80008800 <userret+0x770>
    800036d4:	ffffd097          	auipc	ra,0xffffd
    800036d8:	e74080e7          	jalr	-396(ra) # 80000548 <panic>

00000000800036dc <iget>:
{
    800036dc:	7179                	addi	sp,sp,-48
    800036de:	f406                	sd	ra,40(sp)
    800036e0:	f022                	sd	s0,32(sp)
    800036e2:	ec26                	sd	s1,24(sp)
    800036e4:	e84a                	sd	s2,16(sp)
    800036e6:	e44e                	sd	s3,8(sp)
    800036e8:	e052                	sd	s4,0(sp)
    800036ea:	1800                	addi	s0,sp,48
    800036ec:	89aa                	mv	s3,a0
    800036ee:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800036f0:	00028517          	auipc	a0,0x28
    800036f4:	94850513          	addi	a0,a0,-1720 # 8002b038 <icache>
    800036f8:	ffffd097          	auipc	ra,0xffffd
    800036fc:	5a4080e7          	jalr	1444(ra) # 80000c9c <acquire>
  empty = 0;
    80003700:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003702:	00028497          	auipc	s1,0x28
    80003706:	95648493          	addi	s1,s1,-1706 # 8002b058 <icache+0x20>
    8000370a:	00029697          	auipc	a3,0x29
    8000370e:	56e68693          	addi	a3,a3,1390 # 8002cc78 <log>
    80003712:	a039                	j	80003720 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003714:	02090b63          	beqz	s2,8000374a <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003718:	09048493          	addi	s1,s1,144
    8000371c:	02d48a63          	beq	s1,a3,80003750 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003720:	449c                	lw	a5,8(s1)
    80003722:	fef059e3          	blez	a5,80003714 <iget+0x38>
    80003726:	4098                	lw	a4,0(s1)
    80003728:	ff3716e3          	bne	a4,s3,80003714 <iget+0x38>
    8000372c:	40d8                	lw	a4,4(s1)
    8000372e:	ff4713e3          	bne	a4,s4,80003714 <iget+0x38>
      ip->ref++;
    80003732:	2785                	addiw	a5,a5,1
    80003734:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003736:	00028517          	auipc	a0,0x28
    8000373a:	90250513          	addi	a0,a0,-1790 # 8002b038 <icache>
    8000373e:	ffffd097          	auipc	ra,0xffffd
    80003742:	5ce080e7          	jalr	1486(ra) # 80000d0c <release>
      return ip;
    80003746:	8926                	mv	s2,s1
    80003748:	a03d                	j	80003776 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000374a:	f7f9                	bnez	a5,80003718 <iget+0x3c>
    8000374c:	8926                	mv	s2,s1
    8000374e:	b7e9                	j	80003718 <iget+0x3c>
  if(empty == 0)
    80003750:	02090c63          	beqz	s2,80003788 <iget+0xac>
  ip->dev = dev;
    80003754:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003758:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000375c:	4785                	li	a5,1
    8000375e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003762:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    80003766:	00028517          	auipc	a0,0x28
    8000376a:	8d250513          	addi	a0,a0,-1838 # 8002b038 <icache>
    8000376e:	ffffd097          	auipc	ra,0xffffd
    80003772:	59e080e7          	jalr	1438(ra) # 80000d0c <release>
}
    80003776:	854a                	mv	a0,s2
    80003778:	70a2                	ld	ra,40(sp)
    8000377a:	7402                	ld	s0,32(sp)
    8000377c:	64e2                	ld	s1,24(sp)
    8000377e:	6942                	ld	s2,16(sp)
    80003780:	69a2                	ld	s3,8(sp)
    80003782:	6a02                	ld	s4,0(sp)
    80003784:	6145                	addi	sp,sp,48
    80003786:	8082                	ret
    panic("iget: no inodes");
    80003788:	00005517          	auipc	a0,0x5
    8000378c:	09050513          	addi	a0,a0,144 # 80008818 <userret+0x788>
    80003790:	ffffd097          	auipc	ra,0xffffd
    80003794:	db8080e7          	jalr	-584(ra) # 80000548 <panic>

0000000080003798 <fsinit>:
fsinit(int dev) {
    80003798:	7179                	addi	sp,sp,-48
    8000379a:	f406                	sd	ra,40(sp)
    8000379c:	f022                	sd	s0,32(sp)
    8000379e:	ec26                	sd	s1,24(sp)
    800037a0:	e84a                	sd	s2,16(sp)
    800037a2:	e44e                	sd	s3,8(sp)
    800037a4:	1800                	addi	s0,sp,48
    800037a6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800037a8:	4585                	li	a1,1
    800037aa:	00000097          	auipc	ra,0x0
    800037ae:	a60080e7          	jalr	-1440(ra) # 8000320a <bread>
    800037b2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037b4:	00028997          	auipc	s3,0x28
    800037b8:	86498993          	addi	s3,s3,-1948 # 8002b018 <sb>
    800037bc:	02000613          	li	a2,32
    800037c0:	06050593          	addi	a1,a0,96
    800037c4:	854e                	mv	a0,s3
    800037c6:	ffffd097          	auipc	ra,0xffffd
    800037ca:	79c080e7          	jalr	1948(ra) # 80000f62 <memmove>
  brelse(bp);
    800037ce:	8526                	mv	a0,s1
    800037d0:	00000097          	auipc	ra,0x0
    800037d4:	b6e080e7          	jalr	-1170(ra) # 8000333e <brelse>
  if(sb.magic != FSMAGIC)
    800037d8:	0009a703          	lw	a4,0(s3)
    800037dc:	102037b7          	lui	a5,0x10203
    800037e0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037e4:	02f71263          	bne	a4,a5,80003808 <fsinit+0x70>
  initlog(dev, &sb);
    800037e8:	00028597          	auipc	a1,0x28
    800037ec:	83058593          	addi	a1,a1,-2000 # 8002b018 <sb>
    800037f0:	854a                	mv	a0,s2
    800037f2:	00001097          	auipc	ra,0x1
    800037f6:	bfa080e7          	jalr	-1030(ra) # 800043ec <initlog>
}
    800037fa:	70a2                	ld	ra,40(sp)
    800037fc:	7402                	ld	s0,32(sp)
    800037fe:	64e2                	ld	s1,24(sp)
    80003800:	6942                	ld	s2,16(sp)
    80003802:	69a2                	ld	s3,8(sp)
    80003804:	6145                	addi	sp,sp,48
    80003806:	8082                	ret
    panic("invalid file system");
    80003808:	00005517          	auipc	a0,0x5
    8000380c:	02050513          	addi	a0,a0,32 # 80008828 <userret+0x798>
    80003810:	ffffd097          	auipc	ra,0xffffd
    80003814:	d38080e7          	jalr	-712(ra) # 80000548 <panic>

0000000080003818 <iinit>:
{
    80003818:	7179                	addi	sp,sp,-48
    8000381a:	f406                	sd	ra,40(sp)
    8000381c:	f022                	sd	s0,32(sp)
    8000381e:	ec26                	sd	s1,24(sp)
    80003820:	e84a                	sd	s2,16(sp)
    80003822:	e44e                	sd	s3,8(sp)
    80003824:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003826:	00005597          	auipc	a1,0x5
    8000382a:	01a58593          	addi	a1,a1,26 # 80008840 <userret+0x7b0>
    8000382e:	00028517          	auipc	a0,0x28
    80003832:	80a50513          	addi	a0,a0,-2038 # 8002b038 <icache>
    80003836:	ffffd097          	auipc	ra,0xffffd
    8000383a:	318080e7          	jalr	792(ra) # 80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    8000383e:	00028497          	auipc	s1,0x28
    80003842:	82a48493          	addi	s1,s1,-2006 # 8002b068 <icache+0x30>
    80003846:	00029997          	auipc	s3,0x29
    8000384a:	44298993          	addi	s3,s3,1090 # 8002cc88 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000384e:	00005917          	auipc	s2,0x5
    80003852:	ffa90913          	addi	s2,s2,-6 # 80008848 <userret+0x7b8>
    80003856:	85ca                	mv	a1,s2
    80003858:	8526                	mv	a0,s1
    8000385a:	00001097          	auipc	ra,0x1
    8000385e:	076080e7          	jalr	118(ra) # 800048d0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003862:	09048493          	addi	s1,s1,144
    80003866:	ff3498e3          	bne	s1,s3,80003856 <iinit+0x3e>
}
    8000386a:	70a2                	ld	ra,40(sp)
    8000386c:	7402                	ld	s0,32(sp)
    8000386e:	64e2                	ld	s1,24(sp)
    80003870:	6942                	ld	s2,16(sp)
    80003872:	69a2                	ld	s3,8(sp)
    80003874:	6145                	addi	sp,sp,48
    80003876:	8082                	ret

0000000080003878 <ialloc>:
{
    80003878:	715d                	addi	sp,sp,-80
    8000387a:	e486                	sd	ra,72(sp)
    8000387c:	e0a2                	sd	s0,64(sp)
    8000387e:	fc26                	sd	s1,56(sp)
    80003880:	f84a                	sd	s2,48(sp)
    80003882:	f44e                	sd	s3,40(sp)
    80003884:	f052                	sd	s4,32(sp)
    80003886:	ec56                	sd	s5,24(sp)
    80003888:	e85a                	sd	s6,16(sp)
    8000388a:	e45e                	sd	s7,8(sp)
    8000388c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000388e:	00027717          	auipc	a4,0x27
    80003892:	79672703          	lw	a4,1942(a4) # 8002b024 <sb+0xc>
    80003896:	4785                	li	a5,1
    80003898:	04e7fa63          	bgeu	a5,a4,800038ec <ialloc+0x74>
    8000389c:	8aaa                	mv	s5,a0
    8000389e:	8bae                	mv	s7,a1
    800038a0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800038a2:	00027a17          	auipc	s4,0x27
    800038a6:	776a0a13          	addi	s4,s4,1910 # 8002b018 <sb>
    800038aa:	00048b1b          	sext.w	s6,s1
    800038ae:	0044d793          	srli	a5,s1,0x4
    800038b2:	018a2583          	lw	a1,24(s4)
    800038b6:	9dbd                	addw	a1,a1,a5
    800038b8:	8556                	mv	a0,s5
    800038ba:	00000097          	auipc	ra,0x0
    800038be:	950080e7          	jalr	-1712(ra) # 8000320a <bread>
    800038c2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800038c4:	06050993          	addi	s3,a0,96
    800038c8:	00f4f793          	andi	a5,s1,15
    800038cc:	079a                	slli	a5,a5,0x6
    800038ce:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800038d0:	00099783          	lh	a5,0(s3)
    800038d4:	c785                	beqz	a5,800038fc <ialloc+0x84>
    brelse(bp);
    800038d6:	00000097          	auipc	ra,0x0
    800038da:	a68080e7          	jalr	-1432(ra) # 8000333e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038de:	0485                	addi	s1,s1,1
    800038e0:	00ca2703          	lw	a4,12(s4)
    800038e4:	0004879b          	sext.w	a5,s1
    800038e8:	fce7e1e3          	bltu	a5,a4,800038aa <ialloc+0x32>
  panic("ialloc: no inodes");
    800038ec:	00005517          	auipc	a0,0x5
    800038f0:	f6450513          	addi	a0,a0,-156 # 80008850 <userret+0x7c0>
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	c54080e7          	jalr	-940(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    800038fc:	04000613          	li	a2,64
    80003900:	4581                	li	a1,0
    80003902:	854e                	mv	a0,s3
    80003904:	ffffd097          	auipc	ra,0xffffd
    80003908:	602080e7          	jalr	1538(ra) # 80000f06 <memset>
      dip->type = type;
    8000390c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003910:	854a                	mv	a0,s2
    80003912:	00001097          	auipc	ra,0x1
    80003916:	d60080e7          	jalr	-672(ra) # 80004672 <log_write>
      brelse(bp);
    8000391a:	854a                	mv	a0,s2
    8000391c:	00000097          	auipc	ra,0x0
    80003920:	a22080e7          	jalr	-1502(ra) # 8000333e <brelse>
      return iget(dev, inum);
    80003924:	85da                	mv	a1,s6
    80003926:	8556                	mv	a0,s5
    80003928:	00000097          	auipc	ra,0x0
    8000392c:	db4080e7          	jalr	-588(ra) # 800036dc <iget>
}
    80003930:	60a6                	ld	ra,72(sp)
    80003932:	6406                	ld	s0,64(sp)
    80003934:	74e2                	ld	s1,56(sp)
    80003936:	7942                	ld	s2,48(sp)
    80003938:	79a2                	ld	s3,40(sp)
    8000393a:	7a02                	ld	s4,32(sp)
    8000393c:	6ae2                	ld	s5,24(sp)
    8000393e:	6b42                	ld	s6,16(sp)
    80003940:	6ba2                	ld	s7,8(sp)
    80003942:	6161                	addi	sp,sp,80
    80003944:	8082                	ret

0000000080003946 <iupdate>:
{
    80003946:	1101                	addi	sp,sp,-32
    80003948:	ec06                	sd	ra,24(sp)
    8000394a:	e822                	sd	s0,16(sp)
    8000394c:	e426                	sd	s1,8(sp)
    8000394e:	e04a                	sd	s2,0(sp)
    80003950:	1000                	addi	s0,sp,32
    80003952:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003954:	415c                	lw	a5,4(a0)
    80003956:	0047d79b          	srliw	a5,a5,0x4
    8000395a:	00027597          	auipc	a1,0x27
    8000395e:	6d65a583          	lw	a1,1750(a1) # 8002b030 <sb+0x18>
    80003962:	9dbd                	addw	a1,a1,a5
    80003964:	4108                	lw	a0,0(a0)
    80003966:	00000097          	auipc	ra,0x0
    8000396a:	8a4080e7          	jalr	-1884(ra) # 8000320a <bread>
    8000396e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003970:	06050793          	addi	a5,a0,96
    80003974:	40c8                	lw	a0,4(s1)
    80003976:	893d                	andi	a0,a0,15
    80003978:	051a                	slli	a0,a0,0x6
    8000397a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000397c:	04c49703          	lh	a4,76(s1)
    80003980:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003984:	04e49703          	lh	a4,78(s1)
    80003988:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000398c:	05049703          	lh	a4,80(s1)
    80003990:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003994:	05249703          	lh	a4,82(s1)
    80003998:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000399c:	48f8                	lw	a4,84(s1)
    8000399e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800039a0:	03400613          	li	a2,52
    800039a4:	05848593          	addi	a1,s1,88
    800039a8:	0531                	addi	a0,a0,12
    800039aa:	ffffd097          	auipc	ra,0xffffd
    800039ae:	5b8080e7          	jalr	1464(ra) # 80000f62 <memmove>
  log_write(bp);
    800039b2:	854a                	mv	a0,s2
    800039b4:	00001097          	auipc	ra,0x1
    800039b8:	cbe080e7          	jalr	-834(ra) # 80004672 <log_write>
  brelse(bp);
    800039bc:	854a                	mv	a0,s2
    800039be:	00000097          	auipc	ra,0x0
    800039c2:	980080e7          	jalr	-1664(ra) # 8000333e <brelse>
}
    800039c6:	60e2                	ld	ra,24(sp)
    800039c8:	6442                	ld	s0,16(sp)
    800039ca:	64a2                	ld	s1,8(sp)
    800039cc:	6902                	ld	s2,0(sp)
    800039ce:	6105                	addi	sp,sp,32
    800039d0:	8082                	ret

00000000800039d2 <idup>:
{
    800039d2:	1101                	addi	sp,sp,-32
    800039d4:	ec06                	sd	ra,24(sp)
    800039d6:	e822                	sd	s0,16(sp)
    800039d8:	e426                	sd	s1,8(sp)
    800039da:	1000                	addi	s0,sp,32
    800039dc:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800039de:	00027517          	auipc	a0,0x27
    800039e2:	65a50513          	addi	a0,a0,1626 # 8002b038 <icache>
    800039e6:	ffffd097          	auipc	ra,0xffffd
    800039ea:	2b6080e7          	jalr	694(ra) # 80000c9c <acquire>
  ip->ref++;
    800039ee:	449c                	lw	a5,8(s1)
    800039f0:	2785                	addiw	a5,a5,1
    800039f2:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800039f4:	00027517          	auipc	a0,0x27
    800039f8:	64450513          	addi	a0,a0,1604 # 8002b038 <icache>
    800039fc:	ffffd097          	auipc	ra,0xffffd
    80003a00:	310080e7          	jalr	784(ra) # 80000d0c <release>
}
    80003a04:	8526                	mv	a0,s1
    80003a06:	60e2                	ld	ra,24(sp)
    80003a08:	6442                	ld	s0,16(sp)
    80003a0a:	64a2                	ld	s1,8(sp)
    80003a0c:	6105                	addi	sp,sp,32
    80003a0e:	8082                	ret

0000000080003a10 <ilock>:
{
    80003a10:	1101                	addi	sp,sp,-32
    80003a12:	ec06                	sd	ra,24(sp)
    80003a14:	e822                	sd	s0,16(sp)
    80003a16:	e426                	sd	s1,8(sp)
    80003a18:	e04a                	sd	s2,0(sp)
    80003a1a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a1c:	c115                	beqz	a0,80003a40 <ilock+0x30>
    80003a1e:	84aa                	mv	s1,a0
    80003a20:	451c                	lw	a5,8(a0)
    80003a22:	00f05f63          	blez	a5,80003a40 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a26:	0541                	addi	a0,a0,16
    80003a28:	00001097          	auipc	ra,0x1
    80003a2c:	ee2080e7          	jalr	-286(ra) # 8000490a <acquiresleep>
  if(ip->valid == 0){
    80003a30:	44bc                	lw	a5,72(s1)
    80003a32:	cf99                	beqz	a5,80003a50 <ilock+0x40>
}
    80003a34:	60e2                	ld	ra,24(sp)
    80003a36:	6442                	ld	s0,16(sp)
    80003a38:	64a2                	ld	s1,8(sp)
    80003a3a:	6902                	ld	s2,0(sp)
    80003a3c:	6105                	addi	sp,sp,32
    80003a3e:	8082                	ret
    panic("ilock");
    80003a40:	00005517          	auipc	a0,0x5
    80003a44:	e2850513          	addi	a0,a0,-472 # 80008868 <userret+0x7d8>
    80003a48:	ffffd097          	auipc	ra,0xffffd
    80003a4c:	b00080e7          	jalr	-1280(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a50:	40dc                	lw	a5,4(s1)
    80003a52:	0047d79b          	srliw	a5,a5,0x4
    80003a56:	00027597          	auipc	a1,0x27
    80003a5a:	5da5a583          	lw	a1,1498(a1) # 8002b030 <sb+0x18>
    80003a5e:	9dbd                	addw	a1,a1,a5
    80003a60:	4088                	lw	a0,0(s1)
    80003a62:	fffff097          	auipc	ra,0xfffff
    80003a66:	7a8080e7          	jalr	1960(ra) # 8000320a <bread>
    80003a6a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a6c:	06050593          	addi	a1,a0,96
    80003a70:	40dc                	lw	a5,4(s1)
    80003a72:	8bbd                	andi	a5,a5,15
    80003a74:	079a                	slli	a5,a5,0x6
    80003a76:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a78:	00059783          	lh	a5,0(a1)
    80003a7c:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003a80:	00259783          	lh	a5,2(a1)
    80003a84:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003a88:	00459783          	lh	a5,4(a1)
    80003a8c:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003a90:	00659783          	lh	a5,6(a1)
    80003a94:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003a98:	459c                	lw	a5,8(a1)
    80003a9a:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a9c:	03400613          	li	a2,52
    80003aa0:	05b1                	addi	a1,a1,12
    80003aa2:	05848513          	addi	a0,s1,88
    80003aa6:	ffffd097          	auipc	ra,0xffffd
    80003aaa:	4bc080e7          	jalr	1212(ra) # 80000f62 <memmove>
    brelse(bp);
    80003aae:	854a                	mv	a0,s2
    80003ab0:	00000097          	auipc	ra,0x0
    80003ab4:	88e080e7          	jalr	-1906(ra) # 8000333e <brelse>
    ip->valid = 1;
    80003ab8:	4785                	li	a5,1
    80003aba:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003abc:	04c49783          	lh	a5,76(s1)
    80003ac0:	fbb5                	bnez	a5,80003a34 <ilock+0x24>
      panic("ilock: no type");
    80003ac2:	00005517          	auipc	a0,0x5
    80003ac6:	dae50513          	addi	a0,a0,-594 # 80008870 <userret+0x7e0>
    80003aca:	ffffd097          	auipc	ra,0xffffd
    80003ace:	a7e080e7          	jalr	-1410(ra) # 80000548 <panic>

0000000080003ad2 <iunlock>:
{
    80003ad2:	1101                	addi	sp,sp,-32
    80003ad4:	ec06                	sd	ra,24(sp)
    80003ad6:	e822                	sd	s0,16(sp)
    80003ad8:	e426                	sd	s1,8(sp)
    80003ada:	e04a                	sd	s2,0(sp)
    80003adc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ade:	c905                	beqz	a0,80003b0e <iunlock+0x3c>
    80003ae0:	84aa                	mv	s1,a0
    80003ae2:	01050913          	addi	s2,a0,16
    80003ae6:	854a                	mv	a0,s2
    80003ae8:	00001097          	auipc	ra,0x1
    80003aec:	ebc080e7          	jalr	-324(ra) # 800049a4 <holdingsleep>
    80003af0:	cd19                	beqz	a0,80003b0e <iunlock+0x3c>
    80003af2:	449c                	lw	a5,8(s1)
    80003af4:	00f05d63          	blez	a5,80003b0e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003af8:	854a                	mv	a0,s2
    80003afa:	00001097          	auipc	ra,0x1
    80003afe:	e66080e7          	jalr	-410(ra) # 80004960 <releasesleep>
}
    80003b02:	60e2                	ld	ra,24(sp)
    80003b04:	6442                	ld	s0,16(sp)
    80003b06:	64a2                	ld	s1,8(sp)
    80003b08:	6902                	ld	s2,0(sp)
    80003b0a:	6105                	addi	sp,sp,32
    80003b0c:	8082                	ret
    panic("iunlock");
    80003b0e:	00005517          	auipc	a0,0x5
    80003b12:	d7250513          	addi	a0,a0,-654 # 80008880 <userret+0x7f0>
    80003b16:	ffffd097          	auipc	ra,0xffffd
    80003b1a:	a32080e7          	jalr	-1486(ra) # 80000548 <panic>

0000000080003b1e <iput>:
{
    80003b1e:	7139                	addi	sp,sp,-64
    80003b20:	fc06                	sd	ra,56(sp)
    80003b22:	f822                	sd	s0,48(sp)
    80003b24:	f426                	sd	s1,40(sp)
    80003b26:	f04a                	sd	s2,32(sp)
    80003b28:	ec4e                	sd	s3,24(sp)
    80003b2a:	e852                	sd	s4,16(sp)
    80003b2c:	e456                	sd	s5,8(sp)
    80003b2e:	0080                	addi	s0,sp,64
    80003b30:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003b32:	00027517          	auipc	a0,0x27
    80003b36:	50650513          	addi	a0,a0,1286 # 8002b038 <icache>
    80003b3a:	ffffd097          	auipc	ra,0xffffd
    80003b3e:	162080e7          	jalr	354(ra) # 80000c9c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b42:	4498                	lw	a4,8(s1)
    80003b44:	4785                	li	a5,1
    80003b46:	02f70663          	beq	a4,a5,80003b72 <iput+0x54>
  ip->ref--;
    80003b4a:	449c                	lw	a5,8(s1)
    80003b4c:	37fd                	addiw	a5,a5,-1
    80003b4e:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b50:	00027517          	auipc	a0,0x27
    80003b54:	4e850513          	addi	a0,a0,1256 # 8002b038 <icache>
    80003b58:	ffffd097          	auipc	ra,0xffffd
    80003b5c:	1b4080e7          	jalr	436(ra) # 80000d0c <release>
}
    80003b60:	70e2                	ld	ra,56(sp)
    80003b62:	7442                	ld	s0,48(sp)
    80003b64:	74a2                	ld	s1,40(sp)
    80003b66:	7902                	ld	s2,32(sp)
    80003b68:	69e2                	ld	s3,24(sp)
    80003b6a:	6a42                	ld	s4,16(sp)
    80003b6c:	6aa2                	ld	s5,8(sp)
    80003b6e:	6121                	addi	sp,sp,64
    80003b70:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b72:	44bc                	lw	a5,72(s1)
    80003b74:	dbf9                	beqz	a5,80003b4a <iput+0x2c>
    80003b76:	05249783          	lh	a5,82(s1)
    80003b7a:	fbe1                	bnez	a5,80003b4a <iput+0x2c>
    acquiresleep(&ip->lock);
    80003b7c:	01048a13          	addi	s4,s1,16
    80003b80:	8552                	mv	a0,s4
    80003b82:	00001097          	auipc	ra,0x1
    80003b86:	d88080e7          	jalr	-632(ra) # 8000490a <acquiresleep>
    release(&icache.lock);
    80003b8a:	00027517          	auipc	a0,0x27
    80003b8e:	4ae50513          	addi	a0,a0,1198 # 8002b038 <icache>
    80003b92:	ffffd097          	auipc	ra,0xffffd
    80003b96:	17a080e7          	jalr	378(ra) # 80000d0c <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b9a:	05848913          	addi	s2,s1,88
    80003b9e:	08848993          	addi	s3,s1,136
    80003ba2:	a021                	j	80003baa <iput+0x8c>
    80003ba4:	0911                	addi	s2,s2,4
    80003ba6:	01390d63          	beq	s2,s3,80003bc0 <iput+0xa2>
    if(ip->addrs[i]){
    80003baa:	00092583          	lw	a1,0(s2)
    80003bae:	d9fd                	beqz	a1,80003ba4 <iput+0x86>
      bfree(ip->dev, ip->addrs[i]);
    80003bb0:	4088                	lw	a0,0(s1)
    80003bb2:	00000097          	auipc	ra,0x0
    80003bb6:	8a2080e7          	jalr	-1886(ra) # 80003454 <bfree>
      ip->addrs[i] = 0;
    80003bba:	00092023          	sw	zero,0(s2)
    80003bbe:	b7dd                	j	80003ba4 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003bc0:	0884a583          	lw	a1,136(s1)
    80003bc4:	ed9d                	bnez	a1,80003c02 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003bc6:	0404aa23          	sw	zero,84(s1)
  iupdate(ip);
    80003bca:	8526                	mv	a0,s1
    80003bcc:	00000097          	auipc	ra,0x0
    80003bd0:	d7a080e7          	jalr	-646(ra) # 80003946 <iupdate>
    ip->type = 0;
    80003bd4:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003bd8:	8526                	mv	a0,s1
    80003bda:	00000097          	auipc	ra,0x0
    80003bde:	d6c080e7          	jalr	-660(ra) # 80003946 <iupdate>
    ip->valid = 0;
    80003be2:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003be6:	8552                	mv	a0,s4
    80003be8:	00001097          	auipc	ra,0x1
    80003bec:	d78080e7          	jalr	-648(ra) # 80004960 <releasesleep>
    acquire(&icache.lock);
    80003bf0:	00027517          	auipc	a0,0x27
    80003bf4:	44850513          	addi	a0,a0,1096 # 8002b038 <icache>
    80003bf8:	ffffd097          	auipc	ra,0xffffd
    80003bfc:	0a4080e7          	jalr	164(ra) # 80000c9c <acquire>
    80003c00:	b7a9                	j	80003b4a <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c02:	4088                	lw	a0,0(s1)
    80003c04:	fffff097          	auipc	ra,0xfffff
    80003c08:	606080e7          	jalr	1542(ra) # 8000320a <bread>
    80003c0c:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c0e:	06050913          	addi	s2,a0,96
    80003c12:	46050993          	addi	s3,a0,1120
    80003c16:	a021                	j	80003c1e <iput+0x100>
    80003c18:	0911                	addi	s2,s2,4
    80003c1a:	01390b63          	beq	s2,s3,80003c30 <iput+0x112>
      if(a[j])
    80003c1e:	00092583          	lw	a1,0(s2)
    80003c22:	d9fd                	beqz	a1,80003c18 <iput+0xfa>
        bfree(ip->dev, a[j]);
    80003c24:	4088                	lw	a0,0(s1)
    80003c26:	00000097          	auipc	ra,0x0
    80003c2a:	82e080e7          	jalr	-2002(ra) # 80003454 <bfree>
    80003c2e:	b7ed                	j	80003c18 <iput+0xfa>
    brelse(bp);
    80003c30:	8556                	mv	a0,s5
    80003c32:	fffff097          	auipc	ra,0xfffff
    80003c36:	70c080e7          	jalr	1804(ra) # 8000333e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c3a:	0884a583          	lw	a1,136(s1)
    80003c3e:	4088                	lw	a0,0(s1)
    80003c40:	00000097          	auipc	ra,0x0
    80003c44:	814080e7          	jalr	-2028(ra) # 80003454 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c48:	0804a423          	sw	zero,136(s1)
    80003c4c:	bfad                	j	80003bc6 <iput+0xa8>

0000000080003c4e <iunlockput>:
{
    80003c4e:	1101                	addi	sp,sp,-32
    80003c50:	ec06                	sd	ra,24(sp)
    80003c52:	e822                	sd	s0,16(sp)
    80003c54:	e426                	sd	s1,8(sp)
    80003c56:	1000                	addi	s0,sp,32
    80003c58:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c5a:	00000097          	auipc	ra,0x0
    80003c5e:	e78080e7          	jalr	-392(ra) # 80003ad2 <iunlock>
  iput(ip);
    80003c62:	8526                	mv	a0,s1
    80003c64:	00000097          	auipc	ra,0x0
    80003c68:	eba080e7          	jalr	-326(ra) # 80003b1e <iput>
}
    80003c6c:	60e2                	ld	ra,24(sp)
    80003c6e:	6442                	ld	s0,16(sp)
    80003c70:	64a2                	ld	s1,8(sp)
    80003c72:	6105                	addi	sp,sp,32
    80003c74:	8082                	ret

0000000080003c76 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c76:	1141                	addi	sp,sp,-16
    80003c78:	e422                	sd	s0,8(sp)
    80003c7a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c7c:	411c                	lw	a5,0(a0)
    80003c7e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c80:	415c                	lw	a5,4(a0)
    80003c82:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c84:	04c51783          	lh	a5,76(a0)
    80003c88:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c8c:	05251783          	lh	a5,82(a0)
    80003c90:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c94:	05456783          	lwu	a5,84(a0)
    80003c98:	e99c                	sd	a5,16(a1)
}
    80003c9a:	6422                	ld	s0,8(sp)
    80003c9c:	0141                	addi	sp,sp,16
    80003c9e:	8082                	ret

0000000080003ca0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ca0:	497c                	lw	a5,84(a0)
    80003ca2:	0ed7e563          	bltu	a5,a3,80003d8c <readi+0xec>
{
    80003ca6:	7159                	addi	sp,sp,-112
    80003ca8:	f486                	sd	ra,104(sp)
    80003caa:	f0a2                	sd	s0,96(sp)
    80003cac:	eca6                	sd	s1,88(sp)
    80003cae:	e8ca                	sd	s2,80(sp)
    80003cb0:	e4ce                	sd	s3,72(sp)
    80003cb2:	e0d2                	sd	s4,64(sp)
    80003cb4:	fc56                	sd	s5,56(sp)
    80003cb6:	f85a                	sd	s6,48(sp)
    80003cb8:	f45e                	sd	s7,40(sp)
    80003cba:	f062                	sd	s8,32(sp)
    80003cbc:	ec66                	sd	s9,24(sp)
    80003cbe:	e86a                	sd	s10,16(sp)
    80003cc0:	e46e                	sd	s11,8(sp)
    80003cc2:	1880                	addi	s0,sp,112
    80003cc4:	8baa                	mv	s7,a0
    80003cc6:	8c2e                	mv	s8,a1
    80003cc8:	8ab2                	mv	s5,a2
    80003cca:	8936                	mv	s2,a3
    80003ccc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cce:	9f35                	addw	a4,a4,a3
    80003cd0:	0cd76063          	bltu	a4,a3,80003d90 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    80003cd4:	00e7f463          	bgeu	a5,a4,80003cdc <readi+0x3c>
    n = ip->size - off;
    80003cd8:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cdc:	080b0763          	beqz	s6,80003d6a <readi+0xca>
    80003ce0:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ce2:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ce6:	5cfd                	li	s9,-1
    80003ce8:	a82d                	j	80003d22 <readi+0x82>
    80003cea:	02099d93          	slli	s11,s3,0x20
    80003cee:	020ddd93          	srli	s11,s11,0x20
    80003cf2:	06048793          	addi	a5,s1,96
    80003cf6:	86ee                	mv	a3,s11
    80003cf8:	963e                	add	a2,a2,a5
    80003cfa:	85d6                	mv	a1,s5
    80003cfc:	8562                	mv	a0,s8
    80003cfe:	fffff097          	auipc	ra,0xfffff
    80003d02:	9f4080e7          	jalr	-1548(ra) # 800026f2 <either_copyout>
    80003d06:	05950d63          	beq	a0,s9,80003d60 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003d0a:	8526                	mv	a0,s1
    80003d0c:	fffff097          	auipc	ra,0xfffff
    80003d10:	632080e7          	jalr	1586(ra) # 8000333e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d14:	01498a3b          	addw	s4,s3,s4
    80003d18:	0129893b          	addw	s2,s3,s2
    80003d1c:	9aee                	add	s5,s5,s11
    80003d1e:	056a7663          	bgeu	s4,s6,80003d6a <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d22:	000ba483          	lw	s1,0(s7)
    80003d26:	00a9559b          	srliw	a1,s2,0xa
    80003d2a:	855e                	mv	a0,s7
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	8d6080e7          	jalr	-1834(ra) # 80003602 <bmap>
    80003d34:	0005059b          	sext.w	a1,a0
    80003d38:	8526                	mv	a0,s1
    80003d3a:	fffff097          	auipc	ra,0xfffff
    80003d3e:	4d0080e7          	jalr	1232(ra) # 8000320a <bread>
    80003d42:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d44:	3ff97613          	andi	a2,s2,1023
    80003d48:	40cd07bb          	subw	a5,s10,a2
    80003d4c:	414b073b          	subw	a4,s6,s4
    80003d50:	89be                	mv	s3,a5
    80003d52:	2781                	sext.w	a5,a5
    80003d54:	0007069b          	sext.w	a3,a4
    80003d58:	f8f6f9e3          	bgeu	a3,a5,80003cea <readi+0x4a>
    80003d5c:	89ba                	mv	s3,a4
    80003d5e:	b771                	j	80003cea <readi+0x4a>
      brelse(bp);
    80003d60:	8526                	mv	a0,s1
    80003d62:	fffff097          	auipc	ra,0xfffff
    80003d66:	5dc080e7          	jalr	1500(ra) # 8000333e <brelse>
  }
  return n;
    80003d6a:	000b051b          	sext.w	a0,s6
}
    80003d6e:	70a6                	ld	ra,104(sp)
    80003d70:	7406                	ld	s0,96(sp)
    80003d72:	64e6                	ld	s1,88(sp)
    80003d74:	6946                	ld	s2,80(sp)
    80003d76:	69a6                	ld	s3,72(sp)
    80003d78:	6a06                	ld	s4,64(sp)
    80003d7a:	7ae2                	ld	s5,56(sp)
    80003d7c:	7b42                	ld	s6,48(sp)
    80003d7e:	7ba2                	ld	s7,40(sp)
    80003d80:	7c02                	ld	s8,32(sp)
    80003d82:	6ce2                	ld	s9,24(sp)
    80003d84:	6d42                	ld	s10,16(sp)
    80003d86:	6da2                	ld	s11,8(sp)
    80003d88:	6165                	addi	sp,sp,112
    80003d8a:	8082                	ret
    return -1;
    80003d8c:	557d                	li	a0,-1
}
    80003d8e:	8082                	ret
    return -1;
    80003d90:	557d                	li	a0,-1
    80003d92:	bff1                	j	80003d6e <readi+0xce>

0000000080003d94 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d94:	497c                	lw	a5,84(a0)
    80003d96:	10d7e663          	bltu	a5,a3,80003ea2 <writei+0x10e>
{
    80003d9a:	7159                	addi	sp,sp,-112
    80003d9c:	f486                	sd	ra,104(sp)
    80003d9e:	f0a2                	sd	s0,96(sp)
    80003da0:	eca6                	sd	s1,88(sp)
    80003da2:	e8ca                	sd	s2,80(sp)
    80003da4:	e4ce                	sd	s3,72(sp)
    80003da6:	e0d2                	sd	s4,64(sp)
    80003da8:	fc56                	sd	s5,56(sp)
    80003daa:	f85a                	sd	s6,48(sp)
    80003dac:	f45e                	sd	s7,40(sp)
    80003dae:	f062                	sd	s8,32(sp)
    80003db0:	ec66                	sd	s9,24(sp)
    80003db2:	e86a                	sd	s10,16(sp)
    80003db4:	e46e                	sd	s11,8(sp)
    80003db6:	1880                	addi	s0,sp,112
    80003db8:	8baa                	mv	s7,a0
    80003dba:	8c2e                	mv	s8,a1
    80003dbc:	8ab2                	mv	s5,a2
    80003dbe:	8936                	mv	s2,a3
    80003dc0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003dc2:	00e687bb          	addw	a5,a3,a4
    80003dc6:	0ed7e063          	bltu	a5,a3,80003ea6 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003dca:	00043737          	lui	a4,0x43
    80003dce:	0cf76e63          	bltu	a4,a5,80003eaa <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dd2:	0a0b0763          	beqz	s6,80003e80 <writei+0xec>
    80003dd6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dd8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ddc:	5cfd                	li	s9,-1
    80003dde:	a091                	j	80003e22 <writei+0x8e>
    80003de0:	02099d93          	slli	s11,s3,0x20
    80003de4:	020ddd93          	srli	s11,s11,0x20
    80003de8:	06048793          	addi	a5,s1,96
    80003dec:	86ee                	mv	a3,s11
    80003dee:	8656                	mv	a2,s5
    80003df0:	85e2                	mv	a1,s8
    80003df2:	953e                	add	a0,a0,a5
    80003df4:	fffff097          	auipc	ra,0xfffff
    80003df8:	954080e7          	jalr	-1708(ra) # 80002748 <either_copyin>
    80003dfc:	07950263          	beq	a0,s9,80003e60 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e00:	8526                	mv	a0,s1
    80003e02:	00001097          	auipc	ra,0x1
    80003e06:	870080e7          	jalr	-1936(ra) # 80004672 <log_write>
    brelse(bp);
    80003e0a:	8526                	mv	a0,s1
    80003e0c:	fffff097          	auipc	ra,0xfffff
    80003e10:	532080e7          	jalr	1330(ra) # 8000333e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e14:	01498a3b          	addw	s4,s3,s4
    80003e18:	0129893b          	addw	s2,s3,s2
    80003e1c:	9aee                	add	s5,s5,s11
    80003e1e:	056a7663          	bgeu	s4,s6,80003e6a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e22:	000ba483          	lw	s1,0(s7)
    80003e26:	00a9559b          	srliw	a1,s2,0xa
    80003e2a:	855e                	mv	a0,s7
    80003e2c:	fffff097          	auipc	ra,0xfffff
    80003e30:	7d6080e7          	jalr	2006(ra) # 80003602 <bmap>
    80003e34:	0005059b          	sext.w	a1,a0
    80003e38:	8526                	mv	a0,s1
    80003e3a:	fffff097          	auipc	ra,0xfffff
    80003e3e:	3d0080e7          	jalr	976(ra) # 8000320a <bread>
    80003e42:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e44:	3ff97513          	andi	a0,s2,1023
    80003e48:	40ad07bb          	subw	a5,s10,a0
    80003e4c:	414b073b          	subw	a4,s6,s4
    80003e50:	89be                	mv	s3,a5
    80003e52:	2781                	sext.w	a5,a5
    80003e54:	0007069b          	sext.w	a3,a4
    80003e58:	f8f6f4e3          	bgeu	a3,a5,80003de0 <writei+0x4c>
    80003e5c:	89ba                	mv	s3,a4
    80003e5e:	b749                	j	80003de0 <writei+0x4c>
      brelse(bp);
    80003e60:	8526                	mv	a0,s1
    80003e62:	fffff097          	auipc	ra,0xfffff
    80003e66:	4dc080e7          	jalr	1244(ra) # 8000333e <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003e6a:	054ba783          	lw	a5,84(s7)
    80003e6e:	0127f463          	bgeu	a5,s2,80003e76 <writei+0xe2>
      ip->size = off;
    80003e72:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003e76:	855e                	mv	a0,s7
    80003e78:	00000097          	auipc	ra,0x0
    80003e7c:	ace080e7          	jalr	-1330(ra) # 80003946 <iupdate>
  }

  return n;
    80003e80:	000b051b          	sext.w	a0,s6
}
    80003e84:	70a6                	ld	ra,104(sp)
    80003e86:	7406                	ld	s0,96(sp)
    80003e88:	64e6                	ld	s1,88(sp)
    80003e8a:	6946                	ld	s2,80(sp)
    80003e8c:	69a6                	ld	s3,72(sp)
    80003e8e:	6a06                	ld	s4,64(sp)
    80003e90:	7ae2                	ld	s5,56(sp)
    80003e92:	7b42                	ld	s6,48(sp)
    80003e94:	7ba2                	ld	s7,40(sp)
    80003e96:	7c02                	ld	s8,32(sp)
    80003e98:	6ce2                	ld	s9,24(sp)
    80003e9a:	6d42                	ld	s10,16(sp)
    80003e9c:	6da2                	ld	s11,8(sp)
    80003e9e:	6165                	addi	sp,sp,112
    80003ea0:	8082                	ret
    return -1;
    80003ea2:	557d                	li	a0,-1
}
    80003ea4:	8082                	ret
    return -1;
    80003ea6:	557d                	li	a0,-1
    80003ea8:	bff1                	j	80003e84 <writei+0xf0>
    return -1;
    80003eaa:	557d                	li	a0,-1
    80003eac:	bfe1                	j	80003e84 <writei+0xf0>

0000000080003eae <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003eae:	1141                	addi	sp,sp,-16
    80003eb0:	e406                	sd	ra,8(sp)
    80003eb2:	e022                	sd	s0,0(sp)
    80003eb4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003eb6:	4639                	li	a2,14
    80003eb8:	ffffd097          	auipc	ra,0xffffd
    80003ebc:	126080e7          	jalr	294(ra) # 80000fde <strncmp>
}
    80003ec0:	60a2                	ld	ra,8(sp)
    80003ec2:	6402                	ld	s0,0(sp)
    80003ec4:	0141                	addi	sp,sp,16
    80003ec6:	8082                	ret

0000000080003ec8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ec8:	7139                	addi	sp,sp,-64
    80003eca:	fc06                	sd	ra,56(sp)
    80003ecc:	f822                	sd	s0,48(sp)
    80003ece:	f426                	sd	s1,40(sp)
    80003ed0:	f04a                	sd	s2,32(sp)
    80003ed2:	ec4e                	sd	s3,24(sp)
    80003ed4:	e852                	sd	s4,16(sp)
    80003ed6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ed8:	04c51703          	lh	a4,76(a0)
    80003edc:	4785                	li	a5,1
    80003ede:	00f71a63          	bne	a4,a5,80003ef2 <dirlookup+0x2a>
    80003ee2:	892a                	mv	s2,a0
    80003ee4:	89ae                	mv	s3,a1
    80003ee6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ee8:	497c                	lw	a5,84(a0)
    80003eea:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003eec:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eee:	e79d                	bnez	a5,80003f1c <dirlookup+0x54>
    80003ef0:	a8a5                	j	80003f68 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ef2:	00005517          	auipc	a0,0x5
    80003ef6:	99650513          	addi	a0,a0,-1642 # 80008888 <userret+0x7f8>
    80003efa:	ffffc097          	auipc	ra,0xffffc
    80003efe:	64e080e7          	jalr	1614(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003f02:	00005517          	auipc	a0,0x5
    80003f06:	99e50513          	addi	a0,a0,-1634 # 800088a0 <userret+0x810>
    80003f0a:	ffffc097          	auipc	ra,0xffffc
    80003f0e:	63e080e7          	jalr	1598(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f12:	24c1                	addiw	s1,s1,16
    80003f14:	05492783          	lw	a5,84(s2)
    80003f18:	04f4f763          	bgeu	s1,a5,80003f66 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f1c:	4741                	li	a4,16
    80003f1e:	86a6                	mv	a3,s1
    80003f20:	fc040613          	addi	a2,s0,-64
    80003f24:	4581                	li	a1,0
    80003f26:	854a                	mv	a0,s2
    80003f28:	00000097          	auipc	ra,0x0
    80003f2c:	d78080e7          	jalr	-648(ra) # 80003ca0 <readi>
    80003f30:	47c1                	li	a5,16
    80003f32:	fcf518e3          	bne	a0,a5,80003f02 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f36:	fc045783          	lhu	a5,-64(s0)
    80003f3a:	dfe1                	beqz	a5,80003f12 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f3c:	fc240593          	addi	a1,s0,-62
    80003f40:	854e                	mv	a0,s3
    80003f42:	00000097          	auipc	ra,0x0
    80003f46:	f6c080e7          	jalr	-148(ra) # 80003eae <namecmp>
    80003f4a:	f561                	bnez	a0,80003f12 <dirlookup+0x4a>
      if(poff)
    80003f4c:	000a0463          	beqz	s4,80003f54 <dirlookup+0x8c>
        *poff = off;
    80003f50:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f54:	fc045583          	lhu	a1,-64(s0)
    80003f58:	00092503          	lw	a0,0(s2)
    80003f5c:	fffff097          	auipc	ra,0xfffff
    80003f60:	780080e7          	jalr	1920(ra) # 800036dc <iget>
    80003f64:	a011                	j	80003f68 <dirlookup+0xa0>
  return 0;
    80003f66:	4501                	li	a0,0
}
    80003f68:	70e2                	ld	ra,56(sp)
    80003f6a:	7442                	ld	s0,48(sp)
    80003f6c:	74a2                	ld	s1,40(sp)
    80003f6e:	7902                	ld	s2,32(sp)
    80003f70:	69e2                	ld	s3,24(sp)
    80003f72:	6a42                	ld	s4,16(sp)
    80003f74:	6121                	addi	sp,sp,64
    80003f76:	8082                	ret

0000000080003f78 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f78:	711d                	addi	sp,sp,-96
    80003f7a:	ec86                	sd	ra,88(sp)
    80003f7c:	e8a2                	sd	s0,80(sp)
    80003f7e:	e4a6                	sd	s1,72(sp)
    80003f80:	e0ca                	sd	s2,64(sp)
    80003f82:	fc4e                	sd	s3,56(sp)
    80003f84:	f852                	sd	s4,48(sp)
    80003f86:	f456                	sd	s5,40(sp)
    80003f88:	f05a                	sd	s6,32(sp)
    80003f8a:	ec5e                	sd	s7,24(sp)
    80003f8c:	e862                	sd	s8,16(sp)
    80003f8e:	e466                	sd	s9,8(sp)
    80003f90:	1080                	addi	s0,sp,96
    80003f92:	84aa                	mv	s1,a0
    80003f94:	8aae                	mv	s5,a1
    80003f96:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f98:	00054703          	lbu	a4,0(a0)
    80003f9c:	02f00793          	li	a5,47
    80003fa0:	02f70363          	beq	a4,a5,80003fc6 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003fa4:	ffffe097          	auipc	ra,0xffffe
    80003fa8:	d1e080e7          	jalr	-738(ra) # 80001cc2 <myproc>
    80003fac:	15853503          	ld	a0,344(a0)
    80003fb0:	00000097          	auipc	ra,0x0
    80003fb4:	a22080e7          	jalr	-1502(ra) # 800039d2 <idup>
    80003fb8:	89aa                	mv	s3,a0
  while(*path == '/')
    80003fba:	02f00913          	li	s2,47
  len = path - s;
    80003fbe:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003fc0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003fc2:	4b85                	li	s7,1
    80003fc4:	a865                	j	8000407c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003fc6:	4585                	li	a1,1
    80003fc8:	4501                	li	a0,0
    80003fca:	fffff097          	auipc	ra,0xfffff
    80003fce:	712080e7          	jalr	1810(ra) # 800036dc <iget>
    80003fd2:	89aa                	mv	s3,a0
    80003fd4:	b7dd                	j	80003fba <namex+0x42>
      iunlockput(ip);
    80003fd6:	854e                	mv	a0,s3
    80003fd8:	00000097          	auipc	ra,0x0
    80003fdc:	c76080e7          	jalr	-906(ra) # 80003c4e <iunlockput>
      return 0;
    80003fe0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003fe2:	854e                	mv	a0,s3
    80003fe4:	60e6                	ld	ra,88(sp)
    80003fe6:	6446                	ld	s0,80(sp)
    80003fe8:	64a6                	ld	s1,72(sp)
    80003fea:	6906                	ld	s2,64(sp)
    80003fec:	79e2                	ld	s3,56(sp)
    80003fee:	7a42                	ld	s4,48(sp)
    80003ff0:	7aa2                	ld	s5,40(sp)
    80003ff2:	7b02                	ld	s6,32(sp)
    80003ff4:	6be2                	ld	s7,24(sp)
    80003ff6:	6c42                	ld	s8,16(sp)
    80003ff8:	6ca2                	ld	s9,8(sp)
    80003ffa:	6125                	addi	sp,sp,96
    80003ffc:	8082                	ret
      iunlock(ip);
    80003ffe:	854e                	mv	a0,s3
    80004000:	00000097          	auipc	ra,0x0
    80004004:	ad2080e7          	jalr	-1326(ra) # 80003ad2 <iunlock>
      return ip;
    80004008:	bfe9                	j	80003fe2 <namex+0x6a>
      iunlockput(ip);
    8000400a:	854e                	mv	a0,s3
    8000400c:	00000097          	auipc	ra,0x0
    80004010:	c42080e7          	jalr	-958(ra) # 80003c4e <iunlockput>
      return 0;
    80004014:	89e6                	mv	s3,s9
    80004016:	b7f1                	j	80003fe2 <namex+0x6a>
  len = path - s;
    80004018:	40b48633          	sub	a2,s1,a1
    8000401c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004020:	099c5463          	bge	s8,s9,800040a8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004024:	4639                	li	a2,14
    80004026:	8552                	mv	a0,s4
    80004028:	ffffd097          	auipc	ra,0xffffd
    8000402c:	f3a080e7          	jalr	-198(ra) # 80000f62 <memmove>
  while(*path == '/')
    80004030:	0004c783          	lbu	a5,0(s1)
    80004034:	01279763          	bne	a5,s2,80004042 <namex+0xca>
    path++;
    80004038:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000403a:	0004c783          	lbu	a5,0(s1)
    8000403e:	ff278de3          	beq	a5,s2,80004038 <namex+0xc0>
    ilock(ip);
    80004042:	854e                	mv	a0,s3
    80004044:	00000097          	auipc	ra,0x0
    80004048:	9cc080e7          	jalr	-1588(ra) # 80003a10 <ilock>
    if(ip->type != T_DIR){
    8000404c:	04c99783          	lh	a5,76(s3)
    80004050:	f97793e3          	bne	a5,s7,80003fd6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004054:	000a8563          	beqz	s5,8000405e <namex+0xe6>
    80004058:	0004c783          	lbu	a5,0(s1)
    8000405c:	d3cd                	beqz	a5,80003ffe <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000405e:	865a                	mv	a2,s6
    80004060:	85d2                	mv	a1,s4
    80004062:	854e                	mv	a0,s3
    80004064:	00000097          	auipc	ra,0x0
    80004068:	e64080e7          	jalr	-412(ra) # 80003ec8 <dirlookup>
    8000406c:	8caa                	mv	s9,a0
    8000406e:	dd51                	beqz	a0,8000400a <namex+0x92>
    iunlockput(ip);
    80004070:	854e                	mv	a0,s3
    80004072:	00000097          	auipc	ra,0x0
    80004076:	bdc080e7          	jalr	-1060(ra) # 80003c4e <iunlockput>
    ip = next;
    8000407a:	89e6                	mv	s3,s9
  while(*path == '/')
    8000407c:	0004c783          	lbu	a5,0(s1)
    80004080:	05279763          	bne	a5,s2,800040ce <namex+0x156>
    path++;
    80004084:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004086:	0004c783          	lbu	a5,0(s1)
    8000408a:	ff278de3          	beq	a5,s2,80004084 <namex+0x10c>
  if(*path == 0)
    8000408e:	c79d                	beqz	a5,800040bc <namex+0x144>
    path++;
    80004090:	85a6                	mv	a1,s1
  len = path - s;
    80004092:	8cda                	mv	s9,s6
    80004094:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004096:	01278963          	beq	a5,s2,800040a8 <namex+0x130>
    8000409a:	dfbd                	beqz	a5,80004018 <namex+0xa0>
    path++;
    8000409c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000409e:	0004c783          	lbu	a5,0(s1)
    800040a2:	ff279ce3          	bne	a5,s2,8000409a <namex+0x122>
    800040a6:	bf8d                	j	80004018 <namex+0xa0>
    memmove(name, s, len);
    800040a8:	2601                	sext.w	a2,a2
    800040aa:	8552                	mv	a0,s4
    800040ac:	ffffd097          	auipc	ra,0xffffd
    800040b0:	eb6080e7          	jalr	-330(ra) # 80000f62 <memmove>
    name[len] = 0;
    800040b4:	9cd2                	add	s9,s9,s4
    800040b6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800040ba:	bf9d                	j	80004030 <namex+0xb8>
  if(nameiparent){
    800040bc:	f20a83e3          	beqz	s5,80003fe2 <namex+0x6a>
    iput(ip);
    800040c0:	854e                	mv	a0,s3
    800040c2:	00000097          	auipc	ra,0x0
    800040c6:	a5c080e7          	jalr	-1444(ra) # 80003b1e <iput>
    return 0;
    800040ca:	4981                	li	s3,0
    800040cc:	bf19                	j	80003fe2 <namex+0x6a>
  if(*path == 0)
    800040ce:	d7fd                	beqz	a5,800040bc <namex+0x144>
  while(*path != '/' && *path != 0)
    800040d0:	0004c783          	lbu	a5,0(s1)
    800040d4:	85a6                	mv	a1,s1
    800040d6:	b7d1                	j	8000409a <namex+0x122>

00000000800040d8 <dirlink>:
{
    800040d8:	7139                	addi	sp,sp,-64
    800040da:	fc06                	sd	ra,56(sp)
    800040dc:	f822                	sd	s0,48(sp)
    800040de:	f426                	sd	s1,40(sp)
    800040e0:	f04a                	sd	s2,32(sp)
    800040e2:	ec4e                	sd	s3,24(sp)
    800040e4:	e852                	sd	s4,16(sp)
    800040e6:	0080                	addi	s0,sp,64
    800040e8:	892a                	mv	s2,a0
    800040ea:	8a2e                	mv	s4,a1
    800040ec:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040ee:	4601                	li	a2,0
    800040f0:	00000097          	auipc	ra,0x0
    800040f4:	dd8080e7          	jalr	-552(ra) # 80003ec8 <dirlookup>
    800040f8:	e93d                	bnez	a0,8000416e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040fa:	05492483          	lw	s1,84(s2)
    800040fe:	c49d                	beqz	s1,8000412c <dirlink+0x54>
    80004100:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004102:	4741                	li	a4,16
    80004104:	86a6                	mv	a3,s1
    80004106:	fc040613          	addi	a2,s0,-64
    8000410a:	4581                	li	a1,0
    8000410c:	854a                	mv	a0,s2
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	b92080e7          	jalr	-1134(ra) # 80003ca0 <readi>
    80004116:	47c1                	li	a5,16
    80004118:	06f51163          	bne	a0,a5,8000417a <dirlink+0xa2>
    if(de.inum == 0)
    8000411c:	fc045783          	lhu	a5,-64(s0)
    80004120:	c791                	beqz	a5,8000412c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004122:	24c1                	addiw	s1,s1,16
    80004124:	05492783          	lw	a5,84(s2)
    80004128:	fcf4ede3          	bltu	s1,a5,80004102 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000412c:	4639                	li	a2,14
    8000412e:	85d2                	mv	a1,s4
    80004130:	fc240513          	addi	a0,s0,-62
    80004134:	ffffd097          	auipc	ra,0xffffd
    80004138:	ee6080e7          	jalr	-282(ra) # 8000101a <strncpy>
  de.inum = inum;
    8000413c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004140:	4741                	li	a4,16
    80004142:	86a6                	mv	a3,s1
    80004144:	fc040613          	addi	a2,s0,-64
    80004148:	4581                	li	a1,0
    8000414a:	854a                	mv	a0,s2
    8000414c:	00000097          	auipc	ra,0x0
    80004150:	c48080e7          	jalr	-952(ra) # 80003d94 <writei>
    80004154:	872a                	mv	a4,a0
    80004156:	47c1                	li	a5,16
  return 0;
    80004158:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000415a:	02f71863          	bne	a4,a5,8000418a <dirlink+0xb2>
}
    8000415e:	70e2                	ld	ra,56(sp)
    80004160:	7442                	ld	s0,48(sp)
    80004162:	74a2                	ld	s1,40(sp)
    80004164:	7902                	ld	s2,32(sp)
    80004166:	69e2                	ld	s3,24(sp)
    80004168:	6a42                	ld	s4,16(sp)
    8000416a:	6121                	addi	sp,sp,64
    8000416c:	8082                	ret
    iput(ip);
    8000416e:	00000097          	auipc	ra,0x0
    80004172:	9b0080e7          	jalr	-1616(ra) # 80003b1e <iput>
    return -1;
    80004176:	557d                	li	a0,-1
    80004178:	b7dd                	j	8000415e <dirlink+0x86>
      panic("dirlink read");
    8000417a:	00004517          	auipc	a0,0x4
    8000417e:	73650513          	addi	a0,a0,1846 # 800088b0 <userret+0x820>
    80004182:	ffffc097          	auipc	ra,0xffffc
    80004186:	3c6080e7          	jalr	966(ra) # 80000548 <panic>
    panic("dirlink");
    8000418a:	00005517          	auipc	a0,0x5
    8000418e:	8d650513          	addi	a0,a0,-1834 # 80008a60 <userret+0x9d0>
    80004192:	ffffc097          	auipc	ra,0xffffc
    80004196:	3b6080e7          	jalr	950(ra) # 80000548 <panic>

000000008000419a <namei>:

struct inode*
namei(char *path)
{
    8000419a:	1101                	addi	sp,sp,-32
    8000419c:	ec06                	sd	ra,24(sp)
    8000419e:	e822                	sd	s0,16(sp)
    800041a0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800041a2:	fe040613          	addi	a2,s0,-32
    800041a6:	4581                	li	a1,0
    800041a8:	00000097          	auipc	ra,0x0
    800041ac:	dd0080e7          	jalr	-560(ra) # 80003f78 <namex>
}
    800041b0:	60e2                	ld	ra,24(sp)
    800041b2:	6442                	ld	s0,16(sp)
    800041b4:	6105                	addi	sp,sp,32
    800041b6:	8082                	ret

00000000800041b8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800041b8:	1141                	addi	sp,sp,-16
    800041ba:	e406                	sd	ra,8(sp)
    800041bc:	e022                	sd	s0,0(sp)
    800041be:	0800                	addi	s0,sp,16
    800041c0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041c2:	4585                	li	a1,1
    800041c4:	00000097          	auipc	ra,0x0
    800041c8:	db4080e7          	jalr	-588(ra) # 80003f78 <namex>
}
    800041cc:	60a2                	ld	ra,8(sp)
    800041ce:	6402                	ld	s0,0(sp)
    800041d0:	0141                	addi	sp,sp,16
    800041d2:	8082                	ret

00000000800041d4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    800041d4:	7179                	addi	sp,sp,-48
    800041d6:	f406                	sd	ra,40(sp)
    800041d8:	f022                	sd	s0,32(sp)
    800041da:	ec26                	sd	s1,24(sp)
    800041dc:	e84a                	sd	s2,16(sp)
    800041de:	e44e                	sd	s3,8(sp)
    800041e0:	1800                	addi	s0,sp,48
    800041e2:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    800041e4:	0b000993          	li	s3,176
    800041e8:	033507b3          	mul	a5,a0,s3
    800041ec:	00029997          	auipc	s3,0x29
    800041f0:	a8c98993          	addi	s3,s3,-1396 # 8002cc78 <log>
    800041f4:	99be                	add	s3,s3,a5
    800041f6:	0209a583          	lw	a1,32(s3)
    800041fa:	fffff097          	auipc	ra,0xfffff
    800041fe:	010080e7          	jalr	16(ra) # 8000320a <bread>
    80004202:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80004204:	0349a783          	lw	a5,52(s3)
    80004208:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000420a:	0349a783          	lw	a5,52(s3)
    8000420e:	02f05763          	blez	a5,8000423c <write_head+0x68>
    80004212:	0b000793          	li	a5,176
    80004216:	02f487b3          	mul	a5,s1,a5
    8000421a:	00029717          	auipc	a4,0x29
    8000421e:	a9670713          	addi	a4,a4,-1386 # 8002ccb0 <log+0x38>
    80004222:	97ba                	add	a5,a5,a4
    80004224:	06450693          	addi	a3,a0,100
    80004228:	4701                	li	a4,0
    8000422a:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    8000422c:	4390                	lw	a2,0(a5)
    8000422e:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004230:	2705                	addiw	a4,a4,1
    80004232:	0791                	addi	a5,a5,4
    80004234:	0691                	addi	a3,a3,4
    80004236:	59d0                	lw	a2,52(a1)
    80004238:	fec74ae3          	blt	a4,a2,8000422c <write_head+0x58>
  }
  bwrite(buf);
    8000423c:	854a                	mv	a0,s2
    8000423e:	fffff097          	auipc	ra,0xfffff
    80004242:	0c0080e7          	jalr	192(ra) # 800032fe <bwrite>
  brelse(buf);
    80004246:	854a                	mv	a0,s2
    80004248:	fffff097          	auipc	ra,0xfffff
    8000424c:	0f6080e7          	jalr	246(ra) # 8000333e <brelse>
}
    80004250:	70a2                	ld	ra,40(sp)
    80004252:	7402                	ld	s0,32(sp)
    80004254:	64e2                	ld	s1,24(sp)
    80004256:	6942                	ld	s2,16(sp)
    80004258:	69a2                	ld	s3,8(sp)
    8000425a:	6145                	addi	sp,sp,48
    8000425c:	8082                	ret

000000008000425e <write_log>:
static void
write_log(int dev)
{
  int tail;

  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000425e:	0b000793          	li	a5,176
    80004262:	02f50733          	mul	a4,a0,a5
    80004266:	00029797          	auipc	a5,0x29
    8000426a:	a1278793          	addi	a5,a5,-1518 # 8002cc78 <log>
    8000426e:	97ba                	add	a5,a5,a4
    80004270:	5bdc                	lw	a5,52(a5)
    80004272:	0af05663          	blez	a5,8000431e <write_log+0xc0>
{
    80004276:	7139                	addi	sp,sp,-64
    80004278:	fc06                	sd	ra,56(sp)
    8000427a:	f822                	sd	s0,48(sp)
    8000427c:	f426                	sd	s1,40(sp)
    8000427e:	f04a                	sd	s2,32(sp)
    80004280:	ec4e                	sd	s3,24(sp)
    80004282:	e852                	sd	s4,16(sp)
    80004284:	e456                	sd	s5,8(sp)
    80004286:	e05a                	sd	s6,0(sp)
    80004288:	0080                	addi	s0,sp,64
    8000428a:	00029797          	auipc	a5,0x29
    8000428e:	a2678793          	addi	a5,a5,-1498 # 8002ccb0 <log+0x38>
    80004292:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004296:	4981                	li	s3,0
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80004298:	00050b1b          	sext.w	s6,a0
    8000429c:	00029a97          	auipc	s5,0x29
    800042a0:	9dca8a93          	addi	s5,s5,-1572 # 8002cc78 <log>
    800042a4:	9aba                	add	s5,s5,a4
    800042a6:	020aa583          	lw	a1,32(s5)
    800042aa:	013585bb          	addw	a1,a1,s3
    800042ae:	2585                	addiw	a1,a1,1
    800042b0:	855a                	mv	a0,s6
    800042b2:	fffff097          	auipc	ra,0xfffff
    800042b6:	f58080e7          	jalr	-168(ra) # 8000320a <bread>
    800042ba:	84aa                	mv	s1,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    800042bc:	000a2583          	lw	a1,0(s4)
    800042c0:	855a                	mv	a0,s6
    800042c2:	fffff097          	auipc	ra,0xfffff
    800042c6:	f48080e7          	jalr	-184(ra) # 8000320a <bread>
    800042ca:	892a                	mv	s2,a0
    memmove(to->data, from->data, BSIZE);
    800042cc:	40000613          	li	a2,1024
    800042d0:	06050593          	addi	a1,a0,96
    800042d4:	06048513          	addi	a0,s1,96
    800042d8:	ffffd097          	auipc	ra,0xffffd
    800042dc:	c8a080e7          	jalr	-886(ra) # 80000f62 <memmove>
    bwrite(to);  // write the log
    800042e0:	8526                	mv	a0,s1
    800042e2:	fffff097          	auipc	ra,0xfffff
    800042e6:	01c080e7          	jalr	28(ra) # 800032fe <bwrite>
    brelse(from);
    800042ea:	854a                	mv	a0,s2
    800042ec:	fffff097          	auipc	ra,0xfffff
    800042f0:	052080e7          	jalr	82(ra) # 8000333e <brelse>
    brelse(to);
    800042f4:	8526                	mv	a0,s1
    800042f6:	fffff097          	auipc	ra,0xfffff
    800042fa:	048080e7          	jalr	72(ra) # 8000333e <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800042fe:	2985                	addiw	s3,s3,1
    80004300:	0a11                	addi	s4,s4,4
    80004302:	034aa783          	lw	a5,52(s5)
    80004306:	faf9c0e3          	blt	s3,a5,800042a6 <write_log+0x48>
  }
}
    8000430a:	70e2                	ld	ra,56(sp)
    8000430c:	7442                	ld	s0,48(sp)
    8000430e:	74a2                	ld	s1,40(sp)
    80004310:	7902                	ld	s2,32(sp)
    80004312:	69e2                	ld	s3,24(sp)
    80004314:	6a42                	ld	s4,16(sp)
    80004316:	6aa2                	ld	s5,8(sp)
    80004318:	6b02                	ld	s6,0(sp)
    8000431a:	6121                	addi	sp,sp,64
    8000431c:	8082                	ret
    8000431e:	8082                	ret

0000000080004320 <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004320:	0b000793          	li	a5,176
    80004324:	02f50733          	mul	a4,a0,a5
    80004328:	00029797          	auipc	a5,0x29
    8000432c:	95078793          	addi	a5,a5,-1712 # 8002cc78 <log>
    80004330:	97ba                	add	a5,a5,a4
    80004332:	5bdc                	lw	a5,52(a5)
    80004334:	0af05b63          	blez	a5,800043ea <install_trans+0xca>
{
    80004338:	7139                	addi	sp,sp,-64
    8000433a:	fc06                	sd	ra,56(sp)
    8000433c:	f822                	sd	s0,48(sp)
    8000433e:	f426                	sd	s1,40(sp)
    80004340:	f04a                	sd	s2,32(sp)
    80004342:	ec4e                	sd	s3,24(sp)
    80004344:	e852                	sd	s4,16(sp)
    80004346:	e456                	sd	s5,8(sp)
    80004348:	e05a                	sd	s6,0(sp)
    8000434a:	0080                	addi	s0,sp,64
    8000434c:	00029797          	auipc	a5,0x29
    80004350:	96478793          	addi	a5,a5,-1692 # 8002ccb0 <log+0x38>
    80004354:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004358:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    8000435a:	00050b1b          	sext.w	s6,a0
    8000435e:	00029a97          	auipc	s5,0x29
    80004362:	91aa8a93          	addi	s5,s5,-1766 # 8002cc78 <log>
    80004366:	9aba                	add	s5,s5,a4
    80004368:	020aa583          	lw	a1,32(s5)
    8000436c:	013585bb          	addw	a1,a1,s3
    80004370:	2585                	addiw	a1,a1,1
    80004372:	855a                	mv	a0,s6
    80004374:	fffff097          	auipc	ra,0xfffff
    80004378:	e96080e7          	jalr	-362(ra) # 8000320a <bread>
    8000437c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    8000437e:	000a2583          	lw	a1,0(s4)
    80004382:	855a                	mv	a0,s6
    80004384:	fffff097          	auipc	ra,0xfffff
    80004388:	e86080e7          	jalr	-378(ra) # 8000320a <bread>
    8000438c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000438e:	40000613          	li	a2,1024
    80004392:	06090593          	addi	a1,s2,96
    80004396:	06050513          	addi	a0,a0,96
    8000439a:	ffffd097          	auipc	ra,0xffffd
    8000439e:	bc8080e7          	jalr	-1080(ra) # 80000f62 <memmove>
    bwrite(dbuf);  // write dst to disk
    800043a2:	8526                	mv	a0,s1
    800043a4:	fffff097          	auipc	ra,0xfffff
    800043a8:	f5a080e7          	jalr	-166(ra) # 800032fe <bwrite>
    bunpin(dbuf);
    800043ac:	8526                	mv	a0,s1
    800043ae:	fffff097          	auipc	ra,0xfffff
    800043b2:	06a080e7          	jalr	106(ra) # 80003418 <bunpin>
    brelse(lbuf);
    800043b6:	854a                	mv	a0,s2
    800043b8:	fffff097          	auipc	ra,0xfffff
    800043bc:	f86080e7          	jalr	-122(ra) # 8000333e <brelse>
    brelse(dbuf);
    800043c0:	8526                	mv	a0,s1
    800043c2:	fffff097          	auipc	ra,0xfffff
    800043c6:	f7c080e7          	jalr	-132(ra) # 8000333e <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800043ca:	2985                	addiw	s3,s3,1
    800043cc:	0a11                	addi	s4,s4,4
    800043ce:	034aa783          	lw	a5,52(s5)
    800043d2:	f8f9cbe3          	blt	s3,a5,80004368 <install_trans+0x48>
}
    800043d6:	70e2                	ld	ra,56(sp)
    800043d8:	7442                	ld	s0,48(sp)
    800043da:	74a2                	ld	s1,40(sp)
    800043dc:	7902                	ld	s2,32(sp)
    800043de:	69e2                	ld	s3,24(sp)
    800043e0:	6a42                	ld	s4,16(sp)
    800043e2:	6aa2                	ld	s5,8(sp)
    800043e4:	6b02                	ld	s6,0(sp)
    800043e6:	6121                	addi	sp,sp,64
    800043e8:	8082                	ret
    800043ea:	8082                	ret

00000000800043ec <initlog>:
{
    800043ec:	7179                	addi	sp,sp,-48
    800043ee:	f406                	sd	ra,40(sp)
    800043f0:	f022                	sd	s0,32(sp)
    800043f2:	ec26                	sd	s1,24(sp)
    800043f4:	e84a                	sd	s2,16(sp)
    800043f6:	e44e                	sd	s3,8(sp)
    800043f8:	e052                	sd	s4,0(sp)
    800043fa:	1800                	addi	s0,sp,48
    800043fc:	892a                	mv	s2,a0
    800043fe:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80004400:	0b000713          	li	a4,176
    80004404:	02e504b3          	mul	s1,a0,a4
    80004408:	00029997          	auipc	s3,0x29
    8000440c:	87098993          	addi	s3,s3,-1936 # 8002cc78 <log>
    80004410:	99a6                	add	s3,s3,s1
    80004412:	00004597          	auipc	a1,0x4
    80004416:	4ae58593          	addi	a1,a1,1198 # 800088c0 <userret+0x830>
    8000441a:	854e                	mv	a0,s3
    8000441c:	ffffc097          	auipc	ra,0xffffc
    80004420:	732080e7          	jalr	1842(ra) # 80000b4e <initlock>
  log[dev].start = sb->logstart;
    80004424:	014a2583          	lw	a1,20(s4)
    80004428:	02b9a023          	sw	a1,32(s3)
  log[dev].size = sb->nlog;
    8000442c:	010a2783          	lw	a5,16(s4)
    80004430:	02f9a223          	sw	a5,36(s3)
  log[dev].dev = dev;
    80004434:	0329a823          	sw	s2,48(s3)
  struct buf *buf = bread(dev, log[dev].start);
    80004438:	854a                	mv	a0,s2
    8000443a:	fffff097          	auipc	ra,0xfffff
    8000443e:	dd0080e7          	jalr	-560(ra) # 8000320a <bread>
  log[dev].lh.n = lh->n;
    80004442:	5134                	lw	a3,96(a0)
    80004444:	02d9aa23          	sw	a3,52(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004448:	02d05663          	blez	a3,80004474 <initlog+0x88>
    8000444c:	06450793          	addi	a5,a0,100
    80004450:	00029717          	auipc	a4,0x29
    80004454:	86070713          	addi	a4,a4,-1952 # 8002ccb0 <log+0x38>
    80004458:	9726                	add	a4,a4,s1
    8000445a:	36fd                	addiw	a3,a3,-1
    8000445c:	1682                	slli	a3,a3,0x20
    8000445e:	9281                	srli	a3,a3,0x20
    80004460:	068a                	slli	a3,a3,0x2
    80004462:	06850613          	addi	a2,a0,104
    80004466:	96b2                	add	a3,a3,a2
    log[dev].lh.block[i] = lh->block[i];
    80004468:	4390                	lw	a2,0(a5)
    8000446a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000446c:	0791                	addi	a5,a5,4
    8000446e:	0711                	addi	a4,a4,4
    80004470:	fed79ce3          	bne	a5,a3,80004468 <initlog+0x7c>
  brelse(buf);
    80004474:	fffff097          	auipc	ra,0xfffff
    80004478:	eca080e7          	jalr	-310(ra) # 8000333e <brelse>
  install_trans(dev); // if committed, copy from log to disk
    8000447c:	854a                	mv	a0,s2
    8000447e:	00000097          	auipc	ra,0x0
    80004482:	ea2080e7          	jalr	-350(ra) # 80004320 <install_trans>
  log[dev].lh.n = 0;
    80004486:	0b000793          	li	a5,176
    8000448a:	02f90733          	mul	a4,s2,a5
    8000448e:	00028797          	auipc	a5,0x28
    80004492:	7ea78793          	addi	a5,a5,2026 # 8002cc78 <log>
    80004496:	97ba                	add	a5,a5,a4
    80004498:	0207aa23          	sw	zero,52(a5)
  write_head(dev); // clear the log
    8000449c:	854a                	mv	a0,s2
    8000449e:	00000097          	auipc	ra,0x0
    800044a2:	d36080e7          	jalr	-714(ra) # 800041d4 <write_head>
}
    800044a6:	70a2                	ld	ra,40(sp)
    800044a8:	7402                	ld	s0,32(sp)
    800044aa:	64e2                	ld	s1,24(sp)
    800044ac:	6942                	ld	s2,16(sp)
    800044ae:	69a2                	ld	s3,8(sp)
    800044b0:	6a02                	ld	s4,0(sp)
    800044b2:	6145                	addi	sp,sp,48
    800044b4:	8082                	ret

00000000800044b6 <begin_op>:
{
    800044b6:	7139                	addi	sp,sp,-64
    800044b8:	fc06                	sd	ra,56(sp)
    800044ba:	f822                	sd	s0,48(sp)
    800044bc:	f426                	sd	s1,40(sp)
    800044be:	f04a                	sd	s2,32(sp)
    800044c0:	ec4e                	sd	s3,24(sp)
    800044c2:	e852                	sd	s4,16(sp)
    800044c4:	e456                	sd	s5,8(sp)
    800044c6:	0080                	addi	s0,sp,64
    800044c8:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    800044ca:	0b000913          	li	s2,176
    800044ce:	032507b3          	mul	a5,a0,s2
    800044d2:	00028917          	auipc	s2,0x28
    800044d6:	7a690913          	addi	s2,s2,1958 # 8002cc78 <log>
    800044da:	993e                	add	s2,s2,a5
    800044dc:	854a                	mv	a0,s2
    800044de:	ffffc097          	auipc	ra,0xffffc
    800044e2:	7be080e7          	jalr	1982(ra) # 80000c9c <acquire>
    if(log[dev].committing){
    800044e6:	00028997          	auipc	s3,0x28
    800044ea:	79298993          	addi	s3,s3,1938 # 8002cc78 <log>
    800044ee:	84ca                	mv	s1,s2
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044f0:	4a79                	li	s4,30
    800044f2:	a039                	j	80004500 <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    800044f4:	85ca                	mv	a1,s2
    800044f6:	854e                	mv	a0,s3
    800044f8:	ffffe097          	auipc	ra,0xffffe
    800044fc:	fa0080e7          	jalr	-96(ra) # 80002498 <sleep>
    if(log[dev].committing){
    80004500:	54dc                	lw	a5,44(s1)
    80004502:	fbed                	bnez	a5,800044f4 <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004504:	549c                	lw	a5,40(s1)
    80004506:	0017871b          	addiw	a4,a5,1
    8000450a:	0007069b          	sext.w	a3,a4
    8000450e:	0027179b          	slliw	a5,a4,0x2
    80004512:	9fb9                	addw	a5,a5,a4
    80004514:	0017979b          	slliw	a5,a5,0x1
    80004518:	58d8                	lw	a4,52(s1)
    8000451a:	9fb9                	addw	a5,a5,a4
    8000451c:	00fa5963          	bge	s4,a5,8000452e <begin_op+0x78>
      sleep(&log, &log[dev].lock);
    80004520:	85ca                	mv	a1,s2
    80004522:	854e                	mv	a0,s3
    80004524:	ffffe097          	auipc	ra,0xffffe
    80004528:	f74080e7          	jalr	-140(ra) # 80002498 <sleep>
    8000452c:	bfd1                	j	80004500 <begin_op+0x4a>
      log[dev].outstanding += 1;
    8000452e:	0b000513          	li	a0,176
    80004532:	02aa8ab3          	mul	s5,s5,a0
    80004536:	00028797          	auipc	a5,0x28
    8000453a:	74278793          	addi	a5,a5,1858 # 8002cc78 <log>
    8000453e:	9abe                	add	s5,s5,a5
    80004540:	02daa423          	sw	a3,40(s5)
      release(&log[dev].lock);
    80004544:	854a                	mv	a0,s2
    80004546:	ffffc097          	auipc	ra,0xffffc
    8000454a:	7c6080e7          	jalr	1990(ra) # 80000d0c <release>
}
    8000454e:	70e2                	ld	ra,56(sp)
    80004550:	7442                	ld	s0,48(sp)
    80004552:	74a2                	ld	s1,40(sp)
    80004554:	7902                	ld	s2,32(sp)
    80004556:	69e2                	ld	s3,24(sp)
    80004558:	6a42                	ld	s4,16(sp)
    8000455a:	6aa2                	ld	s5,8(sp)
    8000455c:	6121                	addi	sp,sp,64
    8000455e:	8082                	ret

0000000080004560 <end_op>:
{
    80004560:	7179                	addi	sp,sp,-48
    80004562:	f406                	sd	ra,40(sp)
    80004564:	f022                	sd	s0,32(sp)
    80004566:	ec26                	sd	s1,24(sp)
    80004568:	e84a                	sd	s2,16(sp)
    8000456a:	e44e                	sd	s3,8(sp)
    8000456c:	1800                	addi	s0,sp,48
    8000456e:	892a                	mv	s2,a0
  acquire(&log[dev].lock);
    80004570:	0b000493          	li	s1,176
    80004574:	029507b3          	mul	a5,a0,s1
    80004578:	00028497          	auipc	s1,0x28
    8000457c:	70048493          	addi	s1,s1,1792 # 8002cc78 <log>
    80004580:	94be                	add	s1,s1,a5
    80004582:	8526                	mv	a0,s1
    80004584:	ffffc097          	auipc	ra,0xffffc
    80004588:	718080e7          	jalr	1816(ra) # 80000c9c <acquire>
  log[dev].outstanding -= 1;
    8000458c:	549c                	lw	a5,40(s1)
    8000458e:	37fd                	addiw	a5,a5,-1
    80004590:	0007871b          	sext.w	a4,a5
    80004594:	d49c                	sw	a5,40(s1)
  if(log[dev].committing)
    80004596:	54dc                	lw	a5,44(s1)
    80004598:	e3ad                	bnez	a5,800045fa <end_op+0x9a>
  if(log[dev].outstanding == 0){
    8000459a:	eb25                	bnez	a4,8000460a <end_op+0xaa>
    log[dev].committing = 1;
    8000459c:	0b000993          	li	s3,176
    800045a0:	033907b3          	mul	a5,s2,s3
    800045a4:	00028997          	auipc	s3,0x28
    800045a8:	6d498993          	addi	s3,s3,1748 # 8002cc78 <log>
    800045ac:	99be                	add	s3,s3,a5
    800045ae:	4785                	li	a5,1
    800045b0:	02f9a623          	sw	a5,44(s3)
  release(&log[dev].lock);
    800045b4:	8526                	mv	a0,s1
    800045b6:	ffffc097          	auipc	ra,0xffffc
    800045ba:	756080e7          	jalr	1878(ra) # 80000d0c <release>

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    800045be:	0349a783          	lw	a5,52(s3)
    800045c2:	06f04863          	bgtz	a5,80004632 <end_op+0xd2>
    acquire(&log[dev].lock);
    800045c6:	8526                	mv	a0,s1
    800045c8:	ffffc097          	auipc	ra,0xffffc
    800045cc:	6d4080e7          	jalr	1748(ra) # 80000c9c <acquire>
    log[dev].committing = 0;
    800045d0:	00028517          	auipc	a0,0x28
    800045d4:	6a850513          	addi	a0,a0,1704 # 8002cc78 <log>
    800045d8:	0b000793          	li	a5,176
    800045dc:	02f90933          	mul	s2,s2,a5
    800045e0:	992a                	add	s2,s2,a0
    800045e2:	02092623          	sw	zero,44(s2)
    wakeup(&log);
    800045e6:	ffffe097          	auipc	ra,0xffffe
    800045ea:	032080e7          	jalr	50(ra) # 80002618 <wakeup>
    release(&log[dev].lock);
    800045ee:	8526                	mv	a0,s1
    800045f0:	ffffc097          	auipc	ra,0xffffc
    800045f4:	71c080e7          	jalr	1820(ra) # 80000d0c <release>
}
    800045f8:	a035                	j	80004624 <end_op+0xc4>
    panic("log[dev].committing");
    800045fa:	00004517          	auipc	a0,0x4
    800045fe:	2ce50513          	addi	a0,a0,718 # 800088c8 <userret+0x838>
    80004602:	ffffc097          	auipc	ra,0xffffc
    80004606:	f46080e7          	jalr	-186(ra) # 80000548 <panic>
    wakeup(&log);
    8000460a:	00028517          	auipc	a0,0x28
    8000460e:	66e50513          	addi	a0,a0,1646 # 8002cc78 <log>
    80004612:	ffffe097          	auipc	ra,0xffffe
    80004616:	006080e7          	jalr	6(ra) # 80002618 <wakeup>
  release(&log[dev].lock);
    8000461a:	8526                	mv	a0,s1
    8000461c:	ffffc097          	auipc	ra,0xffffc
    80004620:	6f0080e7          	jalr	1776(ra) # 80000d0c <release>
}
    80004624:	70a2                	ld	ra,40(sp)
    80004626:	7402                	ld	s0,32(sp)
    80004628:	64e2                	ld	s1,24(sp)
    8000462a:	6942                	ld	s2,16(sp)
    8000462c:	69a2                	ld	s3,8(sp)
    8000462e:	6145                	addi	sp,sp,48
    80004630:	8082                	ret
    write_log(dev);     // Write modified blocks from cache to log
    80004632:	854a                	mv	a0,s2
    80004634:	00000097          	auipc	ra,0x0
    80004638:	c2a080e7          	jalr	-982(ra) # 8000425e <write_log>
    write_head(dev);    // Write header to disk -- the real commit
    8000463c:	854a                	mv	a0,s2
    8000463e:	00000097          	auipc	ra,0x0
    80004642:	b96080e7          	jalr	-1130(ra) # 800041d4 <write_head>
    install_trans(dev); // Now install writes to home locations
    80004646:	854a                	mv	a0,s2
    80004648:	00000097          	auipc	ra,0x0
    8000464c:	cd8080e7          	jalr	-808(ra) # 80004320 <install_trans>
    log[dev].lh.n = 0;
    80004650:	0b000793          	li	a5,176
    80004654:	02f90733          	mul	a4,s2,a5
    80004658:	00028797          	auipc	a5,0x28
    8000465c:	62078793          	addi	a5,a5,1568 # 8002cc78 <log>
    80004660:	97ba                	add	a5,a5,a4
    80004662:	0207aa23          	sw	zero,52(a5)
    write_head(dev);    // Erase the transaction from the log
    80004666:	854a                	mv	a0,s2
    80004668:	00000097          	auipc	ra,0x0
    8000466c:	b6c080e7          	jalr	-1172(ra) # 800041d4 <write_head>
    80004670:	bf99                	j	800045c6 <end_op+0x66>

0000000080004672 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004672:	7179                	addi	sp,sp,-48
    80004674:	f406                	sd	ra,40(sp)
    80004676:	f022                	sd	s0,32(sp)
    80004678:	ec26                	sd	s1,24(sp)
    8000467a:	e84a                	sd	s2,16(sp)
    8000467c:	e44e                	sd	s3,8(sp)
    8000467e:	e052                	sd	s4,0(sp)
    80004680:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    80004682:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    80004686:	0b000793          	li	a5,176
    8000468a:	02f90733          	mul	a4,s2,a5
    8000468e:	00028797          	auipc	a5,0x28
    80004692:	5ea78793          	addi	a5,a5,1514 # 8002cc78 <log>
    80004696:	97ba                	add	a5,a5,a4
    80004698:	5bd4                	lw	a3,52(a5)
    8000469a:	47f5                	li	a5,29
    8000469c:	0ad7cc63          	blt	a5,a3,80004754 <log_write+0xe2>
    800046a0:	89aa                	mv	s3,a0
    800046a2:	00028797          	auipc	a5,0x28
    800046a6:	5d678793          	addi	a5,a5,1494 # 8002cc78 <log>
    800046aa:	97ba                	add	a5,a5,a4
    800046ac:	53dc                	lw	a5,36(a5)
    800046ae:	37fd                	addiw	a5,a5,-1
    800046b0:	0af6d263          	bge	a3,a5,80004754 <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    800046b4:	0b000793          	li	a5,176
    800046b8:	02f90733          	mul	a4,s2,a5
    800046bc:	00028797          	auipc	a5,0x28
    800046c0:	5bc78793          	addi	a5,a5,1468 # 8002cc78 <log>
    800046c4:	97ba                	add	a5,a5,a4
    800046c6:	579c                	lw	a5,40(a5)
    800046c8:	08f05e63          	blez	a5,80004764 <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    800046cc:	0b000793          	li	a5,176
    800046d0:	02f904b3          	mul	s1,s2,a5
    800046d4:	00028a17          	auipc	s4,0x28
    800046d8:	5a4a0a13          	addi	s4,s4,1444 # 8002cc78 <log>
    800046dc:	9a26                	add	s4,s4,s1
    800046de:	8552                	mv	a0,s4
    800046e0:	ffffc097          	auipc	ra,0xffffc
    800046e4:	5bc080e7          	jalr	1468(ra) # 80000c9c <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    800046e8:	034a2603          	lw	a2,52(s4)
    800046ec:	08c05463          	blez	a2,80004774 <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800046f0:	00c9a583          	lw	a1,12(s3)
    800046f4:	00028797          	auipc	a5,0x28
    800046f8:	5bc78793          	addi	a5,a5,1468 # 8002ccb0 <log+0x38>
    800046fc:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    800046fe:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    80004700:	4394                	lw	a3,0(a5)
    80004702:	06b68a63          	beq	a3,a1,80004776 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004706:	2705                	addiw	a4,a4,1
    80004708:	0791                	addi	a5,a5,4
    8000470a:	fec71be3          	bne	a4,a2,80004700 <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    8000470e:	02c00793          	li	a5,44
    80004712:	02f907b3          	mul	a5,s2,a5
    80004716:	97b2                	add	a5,a5,a2
    80004718:	07b1                	addi	a5,a5,12
    8000471a:	078a                	slli	a5,a5,0x2
    8000471c:	00028717          	auipc	a4,0x28
    80004720:	55c70713          	addi	a4,a4,1372 # 8002cc78 <log>
    80004724:	97ba                	add	a5,a5,a4
    80004726:	00c9a703          	lw	a4,12(s3)
    8000472a:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    8000472c:	854e                	mv	a0,s3
    8000472e:	fffff097          	auipc	ra,0xfffff
    80004732:	cae080e7          	jalr	-850(ra) # 800033dc <bpin>
    log[dev].lh.n++;
    80004736:	0b000793          	li	a5,176
    8000473a:	02f90933          	mul	s2,s2,a5
    8000473e:	00028797          	auipc	a5,0x28
    80004742:	53a78793          	addi	a5,a5,1338 # 8002cc78 <log>
    80004746:	993e                	add	s2,s2,a5
    80004748:	03492783          	lw	a5,52(s2)
    8000474c:	2785                	addiw	a5,a5,1
    8000474e:	02f92a23          	sw	a5,52(s2)
    80004752:	a099                	j	80004798 <log_write+0x126>
    panic("too big a transaction");
    80004754:	00004517          	auipc	a0,0x4
    80004758:	18c50513          	addi	a0,a0,396 # 800088e0 <userret+0x850>
    8000475c:	ffffc097          	auipc	ra,0xffffc
    80004760:	dec080e7          	jalr	-532(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    80004764:	00004517          	auipc	a0,0x4
    80004768:	19450513          	addi	a0,a0,404 # 800088f8 <userret+0x868>
    8000476c:	ffffc097          	auipc	ra,0xffffc
    80004770:	ddc080e7          	jalr	-548(ra) # 80000548 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004774:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    80004776:	02c00793          	li	a5,44
    8000477a:	02f907b3          	mul	a5,s2,a5
    8000477e:	97ba                	add	a5,a5,a4
    80004780:	07b1                	addi	a5,a5,12
    80004782:	078a                	slli	a5,a5,0x2
    80004784:	00028697          	auipc	a3,0x28
    80004788:	4f468693          	addi	a3,a3,1268 # 8002cc78 <log>
    8000478c:	97b6                	add	a5,a5,a3
    8000478e:	00c9a683          	lw	a3,12(s3)
    80004792:	c794                	sw	a3,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004794:	f8e60ce3          	beq	a2,a4,8000472c <log_write+0xba>
  }
  release(&log[dev].lock);
    80004798:	8552                	mv	a0,s4
    8000479a:	ffffc097          	auipc	ra,0xffffc
    8000479e:	572080e7          	jalr	1394(ra) # 80000d0c <release>
}
    800047a2:	70a2                	ld	ra,40(sp)
    800047a4:	7402                	ld	s0,32(sp)
    800047a6:	64e2                	ld	s1,24(sp)
    800047a8:	6942                	ld	s2,16(sp)
    800047aa:	69a2                	ld	s3,8(sp)
    800047ac:	6a02                	ld	s4,0(sp)
    800047ae:	6145                	addi	sp,sp,48
    800047b0:	8082                	ret

00000000800047b2 <crash_op>:

// crash before commit or after commit
void
crash_op(int dev, int docommit)
{
    800047b2:	7179                	addi	sp,sp,-48
    800047b4:	f406                	sd	ra,40(sp)
    800047b6:	f022                	sd	s0,32(sp)
    800047b8:	ec26                	sd	s1,24(sp)
    800047ba:	e84a                	sd	s2,16(sp)
    800047bc:	e44e                	sd	s3,8(sp)
    800047be:	1800                	addi	s0,sp,48
    800047c0:	84aa                	mv	s1,a0
    800047c2:	89ae                	mv	s3,a1
  int do_commit = 0;
    
  acquire(&log[dev].lock);
    800047c4:	0b000913          	li	s2,176
    800047c8:	032507b3          	mul	a5,a0,s2
    800047cc:	00028917          	auipc	s2,0x28
    800047d0:	4ac90913          	addi	s2,s2,1196 # 8002cc78 <log>
    800047d4:	993e                	add	s2,s2,a5
    800047d6:	854a                	mv	a0,s2
    800047d8:	ffffc097          	auipc	ra,0xffffc
    800047dc:	4c4080e7          	jalr	1220(ra) # 80000c9c <acquire>

  if (dev < 0 || dev >= NDISK)
    800047e0:	0004871b          	sext.w	a4,s1
    800047e4:	4785                	li	a5,1
    800047e6:	0ae7e063          	bltu	a5,a4,80004886 <crash_op+0xd4>
    panic("end_op: invalid disk");
  if(log[dev].outstanding == 0)
    800047ea:	0b000793          	li	a5,176
    800047ee:	02f48733          	mul	a4,s1,a5
    800047f2:	00028797          	auipc	a5,0x28
    800047f6:	48678793          	addi	a5,a5,1158 # 8002cc78 <log>
    800047fa:	97ba                	add	a5,a5,a4
    800047fc:	579c                	lw	a5,40(a5)
    800047fe:	cfc1                	beqz	a5,80004896 <crash_op+0xe4>
    panic("end_op: already closed");
  log[dev].outstanding -= 1;
    80004800:	37fd                	addiw	a5,a5,-1
    80004802:	0007861b          	sext.w	a2,a5
    80004806:	0b000713          	li	a4,176
    8000480a:	02e486b3          	mul	a3,s1,a4
    8000480e:	00028717          	auipc	a4,0x28
    80004812:	46a70713          	addi	a4,a4,1130 # 8002cc78 <log>
    80004816:	9736                	add	a4,a4,a3
    80004818:	d71c                	sw	a5,40(a4)
  if(log[dev].committing)
    8000481a:	575c                	lw	a5,44(a4)
    8000481c:	e7c9                	bnez	a5,800048a6 <crash_op+0xf4>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    8000481e:	ee41                	bnez	a2,800048b6 <crash_op+0x104>
    do_commit = 1;
    log[dev].committing = 1;
    80004820:	0b000793          	li	a5,176
    80004824:	02f48733          	mul	a4,s1,a5
    80004828:	00028797          	auipc	a5,0x28
    8000482c:	45078793          	addi	a5,a5,1104 # 8002cc78 <log>
    80004830:	97ba                	add	a5,a5,a4
    80004832:	4705                	li	a4,1
    80004834:	d7d8                	sw	a4,44(a5)
  }
  
  release(&log[dev].lock);
    80004836:	854a                	mv	a0,s2
    80004838:	ffffc097          	auipc	ra,0xffffc
    8000483c:	4d4080e7          	jalr	1236(ra) # 80000d0c <release>

  if(docommit & do_commit){
    80004840:	0019f993          	andi	s3,s3,1
    80004844:	06098e63          	beqz	s3,800048c0 <crash_op+0x10e>
    printf("crash_op: commit\n");
    80004848:	00004517          	auipc	a0,0x4
    8000484c:	10050513          	addi	a0,a0,256 # 80008948 <userret+0x8b8>
    80004850:	ffffc097          	auipc	ra,0xffffc
    80004854:	d52080e7          	jalr	-686(ra) # 800005a2 <printf>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.

    if (log[dev].lh.n > 0) {
    80004858:	0b000793          	li	a5,176
    8000485c:	02f48733          	mul	a4,s1,a5
    80004860:	00028797          	auipc	a5,0x28
    80004864:	41878793          	addi	a5,a5,1048 # 8002cc78 <log>
    80004868:	97ba                	add	a5,a5,a4
    8000486a:	5bdc                	lw	a5,52(a5)
    8000486c:	04f05a63          	blez	a5,800048c0 <crash_op+0x10e>
      write_log(dev);     // Write modified blocks from cache to log
    80004870:	8526                	mv	a0,s1
    80004872:	00000097          	auipc	ra,0x0
    80004876:	9ec080e7          	jalr	-1556(ra) # 8000425e <write_log>
      write_head(dev);    // Write header to disk -- the real commit
    8000487a:	8526                	mv	a0,s1
    8000487c:	00000097          	auipc	ra,0x0
    80004880:	958080e7          	jalr	-1704(ra) # 800041d4 <write_head>
    80004884:	a835                	j	800048c0 <crash_op+0x10e>
    panic("end_op: invalid disk");
    80004886:	00004517          	auipc	a0,0x4
    8000488a:	09250513          	addi	a0,a0,146 # 80008918 <userret+0x888>
    8000488e:	ffffc097          	auipc	ra,0xffffc
    80004892:	cba080e7          	jalr	-838(ra) # 80000548 <panic>
    panic("end_op: already closed");
    80004896:	00004517          	auipc	a0,0x4
    8000489a:	09a50513          	addi	a0,a0,154 # 80008930 <userret+0x8a0>
    8000489e:	ffffc097          	auipc	ra,0xffffc
    800048a2:	caa080e7          	jalr	-854(ra) # 80000548 <panic>
    panic("log[dev].committing");
    800048a6:	00004517          	auipc	a0,0x4
    800048aa:	02250513          	addi	a0,a0,34 # 800088c8 <userret+0x838>
    800048ae:	ffffc097          	auipc	ra,0xffffc
    800048b2:	c9a080e7          	jalr	-870(ra) # 80000548 <panic>
  release(&log[dev].lock);
    800048b6:	854a                	mv	a0,s2
    800048b8:	ffffc097          	auipc	ra,0xffffc
    800048bc:	454080e7          	jalr	1108(ra) # 80000d0c <release>
    }
  }
  panic("crashed file system; please restart xv6 and run crashtest\n");
    800048c0:	00004517          	auipc	a0,0x4
    800048c4:	0a050513          	addi	a0,a0,160 # 80008960 <userret+0x8d0>
    800048c8:	ffffc097          	auipc	ra,0xffffc
    800048cc:	c80080e7          	jalr	-896(ra) # 80000548 <panic>

00000000800048d0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800048d0:	1101                	addi	sp,sp,-32
    800048d2:	ec06                	sd	ra,24(sp)
    800048d4:	e822                	sd	s0,16(sp)
    800048d6:	e426                	sd	s1,8(sp)
    800048d8:	e04a                	sd	s2,0(sp)
    800048da:	1000                	addi	s0,sp,32
    800048dc:	84aa                	mv	s1,a0
    800048de:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048e0:	00004597          	auipc	a1,0x4
    800048e4:	0c058593          	addi	a1,a1,192 # 800089a0 <userret+0x910>
    800048e8:	0521                	addi	a0,a0,8
    800048ea:	ffffc097          	auipc	ra,0xffffc
    800048ee:	264080e7          	jalr	612(ra) # 80000b4e <initlock>
  lk->name = name;
    800048f2:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    800048f6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048fa:	0204a823          	sw	zero,48(s1)
}
    800048fe:	60e2                	ld	ra,24(sp)
    80004900:	6442                	ld	s0,16(sp)
    80004902:	64a2                	ld	s1,8(sp)
    80004904:	6902                	ld	s2,0(sp)
    80004906:	6105                	addi	sp,sp,32
    80004908:	8082                	ret

000000008000490a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000490a:	1101                	addi	sp,sp,-32
    8000490c:	ec06                	sd	ra,24(sp)
    8000490e:	e822                	sd	s0,16(sp)
    80004910:	e426                	sd	s1,8(sp)
    80004912:	e04a                	sd	s2,0(sp)
    80004914:	1000                	addi	s0,sp,32
    80004916:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004918:	00850913          	addi	s2,a0,8
    8000491c:	854a                	mv	a0,s2
    8000491e:	ffffc097          	auipc	ra,0xffffc
    80004922:	37e080e7          	jalr	894(ra) # 80000c9c <acquire>
  while (lk->locked) {
    80004926:	409c                	lw	a5,0(s1)
    80004928:	cb89                	beqz	a5,8000493a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000492a:	85ca                	mv	a1,s2
    8000492c:	8526                	mv	a0,s1
    8000492e:	ffffe097          	auipc	ra,0xffffe
    80004932:	b6a080e7          	jalr	-1174(ra) # 80002498 <sleep>
  while (lk->locked) {
    80004936:	409c                	lw	a5,0(s1)
    80004938:	fbed                	bnez	a5,8000492a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000493a:	4785                	li	a5,1
    8000493c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000493e:	ffffd097          	auipc	ra,0xffffd
    80004942:	384080e7          	jalr	900(ra) # 80001cc2 <myproc>
    80004946:	413c                	lw	a5,64(a0)
    80004948:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    8000494a:	854a                	mv	a0,s2
    8000494c:	ffffc097          	auipc	ra,0xffffc
    80004950:	3c0080e7          	jalr	960(ra) # 80000d0c <release>
}
    80004954:	60e2                	ld	ra,24(sp)
    80004956:	6442                	ld	s0,16(sp)
    80004958:	64a2                	ld	s1,8(sp)
    8000495a:	6902                	ld	s2,0(sp)
    8000495c:	6105                	addi	sp,sp,32
    8000495e:	8082                	ret

0000000080004960 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004960:	1101                	addi	sp,sp,-32
    80004962:	ec06                	sd	ra,24(sp)
    80004964:	e822                	sd	s0,16(sp)
    80004966:	e426                	sd	s1,8(sp)
    80004968:	e04a                	sd	s2,0(sp)
    8000496a:	1000                	addi	s0,sp,32
    8000496c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000496e:	00850913          	addi	s2,a0,8
    80004972:	854a                	mv	a0,s2
    80004974:	ffffc097          	auipc	ra,0xffffc
    80004978:	328080e7          	jalr	808(ra) # 80000c9c <acquire>
  lk->locked = 0;
    8000497c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004980:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    80004984:	8526                	mv	a0,s1
    80004986:	ffffe097          	auipc	ra,0xffffe
    8000498a:	c92080e7          	jalr	-878(ra) # 80002618 <wakeup>
  release(&lk->lk);
    8000498e:	854a                	mv	a0,s2
    80004990:	ffffc097          	auipc	ra,0xffffc
    80004994:	37c080e7          	jalr	892(ra) # 80000d0c <release>
}
    80004998:	60e2                	ld	ra,24(sp)
    8000499a:	6442                	ld	s0,16(sp)
    8000499c:	64a2                	ld	s1,8(sp)
    8000499e:	6902                	ld	s2,0(sp)
    800049a0:	6105                	addi	sp,sp,32
    800049a2:	8082                	ret

00000000800049a4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800049a4:	7179                	addi	sp,sp,-48
    800049a6:	f406                	sd	ra,40(sp)
    800049a8:	f022                	sd	s0,32(sp)
    800049aa:	ec26                	sd	s1,24(sp)
    800049ac:	e84a                	sd	s2,16(sp)
    800049ae:	e44e                	sd	s3,8(sp)
    800049b0:	1800                	addi	s0,sp,48
    800049b2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049b4:	00850913          	addi	s2,a0,8
    800049b8:	854a                	mv	a0,s2
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	2e2080e7          	jalr	738(ra) # 80000c9c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800049c2:	409c                	lw	a5,0(s1)
    800049c4:	ef99                	bnez	a5,800049e2 <holdingsleep+0x3e>
    800049c6:	4481                	li	s1,0
  release(&lk->lk);
    800049c8:	854a                	mv	a0,s2
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	342080e7          	jalr	834(ra) # 80000d0c <release>
  return r;
}
    800049d2:	8526                	mv	a0,s1
    800049d4:	70a2                	ld	ra,40(sp)
    800049d6:	7402                	ld	s0,32(sp)
    800049d8:	64e2                	ld	s1,24(sp)
    800049da:	6942                	ld	s2,16(sp)
    800049dc:	69a2                	ld	s3,8(sp)
    800049de:	6145                	addi	sp,sp,48
    800049e0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800049e2:	0304a983          	lw	s3,48(s1)
    800049e6:	ffffd097          	auipc	ra,0xffffd
    800049ea:	2dc080e7          	jalr	732(ra) # 80001cc2 <myproc>
    800049ee:	4124                	lw	s1,64(a0)
    800049f0:	413484b3          	sub	s1,s1,s3
    800049f4:	0014b493          	seqz	s1,s1
    800049f8:	bfc1                	j	800049c8 <holdingsleep+0x24>

00000000800049fa <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800049fa:	1141                	addi	sp,sp,-16
    800049fc:	e406                	sd	ra,8(sp)
    800049fe:	e022                	sd	s0,0(sp)
    80004a00:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a02:	00004597          	auipc	a1,0x4
    80004a06:	fae58593          	addi	a1,a1,-82 # 800089b0 <userret+0x920>
    80004a0a:	00028517          	auipc	a0,0x28
    80004a0e:	46e50513          	addi	a0,a0,1134 # 8002ce78 <ftable>
    80004a12:	ffffc097          	auipc	ra,0xffffc
    80004a16:	13c080e7          	jalr	316(ra) # 80000b4e <initlock>
}
    80004a1a:	60a2                	ld	ra,8(sp)
    80004a1c:	6402                	ld	s0,0(sp)
    80004a1e:	0141                	addi	sp,sp,16
    80004a20:	8082                	ret

0000000080004a22 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a22:	1101                	addi	sp,sp,-32
    80004a24:	ec06                	sd	ra,24(sp)
    80004a26:	e822                	sd	s0,16(sp)
    80004a28:	e426                	sd	s1,8(sp)
    80004a2a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a2c:	00028517          	auipc	a0,0x28
    80004a30:	44c50513          	addi	a0,a0,1100 # 8002ce78 <ftable>
    80004a34:	ffffc097          	auipc	ra,0xffffc
    80004a38:	268080e7          	jalr	616(ra) # 80000c9c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a3c:	00028497          	auipc	s1,0x28
    80004a40:	45c48493          	addi	s1,s1,1116 # 8002ce98 <ftable+0x20>
    80004a44:	00029717          	auipc	a4,0x29
    80004a48:	3f470713          	addi	a4,a4,1012 # 8002de38 <ftable+0xfc0>
    if(f->ref == 0){
    80004a4c:	40dc                	lw	a5,4(s1)
    80004a4e:	cf99                	beqz	a5,80004a6c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a50:	02848493          	addi	s1,s1,40
    80004a54:	fee49ce3          	bne	s1,a4,80004a4c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a58:	00028517          	auipc	a0,0x28
    80004a5c:	42050513          	addi	a0,a0,1056 # 8002ce78 <ftable>
    80004a60:	ffffc097          	auipc	ra,0xffffc
    80004a64:	2ac080e7          	jalr	684(ra) # 80000d0c <release>
  return 0;
    80004a68:	4481                	li	s1,0
    80004a6a:	a819                	j	80004a80 <filealloc+0x5e>
      f->ref = 1;
    80004a6c:	4785                	li	a5,1
    80004a6e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a70:	00028517          	auipc	a0,0x28
    80004a74:	40850513          	addi	a0,a0,1032 # 8002ce78 <ftable>
    80004a78:	ffffc097          	auipc	ra,0xffffc
    80004a7c:	294080e7          	jalr	660(ra) # 80000d0c <release>
}
    80004a80:	8526                	mv	a0,s1
    80004a82:	60e2                	ld	ra,24(sp)
    80004a84:	6442                	ld	s0,16(sp)
    80004a86:	64a2                	ld	s1,8(sp)
    80004a88:	6105                	addi	sp,sp,32
    80004a8a:	8082                	ret

0000000080004a8c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a8c:	1101                	addi	sp,sp,-32
    80004a8e:	ec06                	sd	ra,24(sp)
    80004a90:	e822                	sd	s0,16(sp)
    80004a92:	e426                	sd	s1,8(sp)
    80004a94:	1000                	addi	s0,sp,32
    80004a96:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a98:	00028517          	auipc	a0,0x28
    80004a9c:	3e050513          	addi	a0,a0,992 # 8002ce78 <ftable>
    80004aa0:	ffffc097          	auipc	ra,0xffffc
    80004aa4:	1fc080e7          	jalr	508(ra) # 80000c9c <acquire>
  if(f->ref < 1)
    80004aa8:	40dc                	lw	a5,4(s1)
    80004aaa:	02f05263          	blez	a5,80004ace <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004aae:	2785                	addiw	a5,a5,1
    80004ab0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004ab2:	00028517          	auipc	a0,0x28
    80004ab6:	3c650513          	addi	a0,a0,966 # 8002ce78 <ftable>
    80004aba:	ffffc097          	auipc	ra,0xffffc
    80004abe:	252080e7          	jalr	594(ra) # 80000d0c <release>
  return f;
}
    80004ac2:	8526                	mv	a0,s1
    80004ac4:	60e2                	ld	ra,24(sp)
    80004ac6:	6442                	ld	s0,16(sp)
    80004ac8:	64a2                	ld	s1,8(sp)
    80004aca:	6105                	addi	sp,sp,32
    80004acc:	8082                	ret
    panic("filedup");
    80004ace:	00004517          	auipc	a0,0x4
    80004ad2:	eea50513          	addi	a0,a0,-278 # 800089b8 <userret+0x928>
    80004ad6:	ffffc097          	auipc	ra,0xffffc
    80004ada:	a72080e7          	jalr	-1422(ra) # 80000548 <panic>

0000000080004ade <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004ade:	7139                	addi	sp,sp,-64
    80004ae0:	fc06                	sd	ra,56(sp)
    80004ae2:	f822                	sd	s0,48(sp)
    80004ae4:	f426                	sd	s1,40(sp)
    80004ae6:	f04a                	sd	s2,32(sp)
    80004ae8:	ec4e                	sd	s3,24(sp)
    80004aea:	e852                	sd	s4,16(sp)
    80004aec:	e456                	sd	s5,8(sp)
    80004aee:	0080                	addi	s0,sp,64
    80004af0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004af2:	00028517          	auipc	a0,0x28
    80004af6:	38650513          	addi	a0,a0,902 # 8002ce78 <ftable>
    80004afa:	ffffc097          	auipc	ra,0xffffc
    80004afe:	1a2080e7          	jalr	418(ra) # 80000c9c <acquire>
  if(f->ref < 1)
    80004b02:	40dc                	lw	a5,4(s1)
    80004b04:	06f05563          	blez	a5,80004b6e <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004b08:	37fd                	addiw	a5,a5,-1
    80004b0a:	0007871b          	sext.w	a4,a5
    80004b0e:	c0dc                	sw	a5,4(s1)
    80004b10:	06e04763          	bgtz	a4,80004b7e <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b14:	0004a903          	lw	s2,0(s1)
    80004b18:	0094ca83          	lbu	s5,9(s1)
    80004b1c:	0104ba03          	ld	s4,16(s1)
    80004b20:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b24:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b28:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b2c:	00028517          	auipc	a0,0x28
    80004b30:	34c50513          	addi	a0,a0,844 # 8002ce78 <ftable>
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	1d8080e7          	jalr	472(ra) # 80000d0c <release>

  if(ff.type == FD_PIPE){
    80004b3c:	4785                	li	a5,1
    80004b3e:	06f90163          	beq	s2,a5,80004ba0 <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b42:	3979                	addiw	s2,s2,-2
    80004b44:	4785                	li	a5,1
    80004b46:	0527e463          	bltu	a5,s2,80004b8e <fileclose+0xb0>
    begin_op(ff.ip->dev);
    80004b4a:	0009a503          	lw	a0,0(s3)
    80004b4e:	00000097          	auipc	ra,0x0
    80004b52:	968080e7          	jalr	-1688(ra) # 800044b6 <begin_op>
    iput(ff.ip);
    80004b56:	854e                	mv	a0,s3
    80004b58:	fffff097          	auipc	ra,0xfffff
    80004b5c:	fc6080e7          	jalr	-58(ra) # 80003b1e <iput>
    end_op(ff.ip->dev);
    80004b60:	0009a503          	lw	a0,0(s3)
    80004b64:	00000097          	auipc	ra,0x0
    80004b68:	9fc080e7          	jalr	-1540(ra) # 80004560 <end_op>
    80004b6c:	a00d                	j	80004b8e <fileclose+0xb0>
    panic("fileclose");
    80004b6e:	00004517          	auipc	a0,0x4
    80004b72:	e5250513          	addi	a0,a0,-430 # 800089c0 <userret+0x930>
    80004b76:	ffffc097          	auipc	ra,0xffffc
    80004b7a:	9d2080e7          	jalr	-1582(ra) # 80000548 <panic>
    release(&ftable.lock);
    80004b7e:	00028517          	auipc	a0,0x28
    80004b82:	2fa50513          	addi	a0,a0,762 # 8002ce78 <ftable>
    80004b86:	ffffc097          	auipc	ra,0xffffc
    80004b8a:	186080e7          	jalr	390(ra) # 80000d0c <release>
  }
}
    80004b8e:	70e2                	ld	ra,56(sp)
    80004b90:	7442                	ld	s0,48(sp)
    80004b92:	74a2                	ld	s1,40(sp)
    80004b94:	7902                	ld	s2,32(sp)
    80004b96:	69e2                	ld	s3,24(sp)
    80004b98:	6a42                	ld	s4,16(sp)
    80004b9a:	6aa2                	ld	s5,8(sp)
    80004b9c:	6121                	addi	sp,sp,64
    80004b9e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ba0:	85d6                	mv	a1,s5
    80004ba2:	8552                	mv	a0,s4
    80004ba4:	00000097          	auipc	ra,0x0
    80004ba8:	378080e7          	jalr	888(ra) # 80004f1c <pipeclose>
    80004bac:	b7cd                	j	80004b8e <fileclose+0xb0>

0000000080004bae <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004bae:	715d                	addi	sp,sp,-80
    80004bb0:	e486                	sd	ra,72(sp)
    80004bb2:	e0a2                	sd	s0,64(sp)
    80004bb4:	fc26                	sd	s1,56(sp)
    80004bb6:	f84a                	sd	s2,48(sp)
    80004bb8:	f44e                	sd	s3,40(sp)
    80004bba:	0880                	addi	s0,sp,80
    80004bbc:	84aa                	mv	s1,a0
    80004bbe:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004bc0:	ffffd097          	auipc	ra,0xffffd
    80004bc4:	102080e7          	jalr	258(ra) # 80001cc2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004bc8:	409c                	lw	a5,0(s1)
    80004bca:	37f9                	addiw	a5,a5,-2
    80004bcc:	4705                	li	a4,1
    80004bce:	04f76763          	bltu	a4,a5,80004c1c <filestat+0x6e>
    80004bd2:	892a                	mv	s2,a0
    ilock(f->ip);
    80004bd4:	6c88                	ld	a0,24(s1)
    80004bd6:	fffff097          	auipc	ra,0xfffff
    80004bda:	e3a080e7          	jalr	-454(ra) # 80003a10 <ilock>
    stati(f->ip, &st);
    80004bde:	fb840593          	addi	a1,s0,-72
    80004be2:	6c88                	ld	a0,24(s1)
    80004be4:	fffff097          	auipc	ra,0xfffff
    80004be8:	092080e7          	jalr	146(ra) # 80003c76 <stati>
    iunlock(f->ip);
    80004bec:	6c88                	ld	a0,24(s1)
    80004bee:	fffff097          	auipc	ra,0xfffff
    80004bf2:	ee4080e7          	jalr	-284(ra) # 80003ad2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004bf6:	46e1                	li	a3,24
    80004bf8:	fb840613          	addi	a2,s0,-72
    80004bfc:	85ce                	mv	a1,s3
    80004bfe:	05893503          	ld	a0,88(s2)
    80004c02:	ffffd097          	auipc	ra,0xffffd
    80004c06:	cf2080e7          	jalr	-782(ra) # 800018f4 <copyout>
    80004c0a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c0e:	60a6                	ld	ra,72(sp)
    80004c10:	6406                	ld	s0,64(sp)
    80004c12:	74e2                	ld	s1,56(sp)
    80004c14:	7942                	ld	s2,48(sp)
    80004c16:	79a2                	ld	s3,40(sp)
    80004c18:	6161                	addi	sp,sp,80
    80004c1a:	8082                	ret
  return -1;
    80004c1c:	557d                	li	a0,-1
    80004c1e:	bfc5                	j	80004c0e <filestat+0x60>

0000000080004c20 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c20:	7179                	addi	sp,sp,-48
    80004c22:	f406                	sd	ra,40(sp)
    80004c24:	f022                	sd	s0,32(sp)
    80004c26:	ec26                	sd	s1,24(sp)
    80004c28:	e84a                	sd	s2,16(sp)
    80004c2a:	e44e                	sd	s3,8(sp)
    80004c2c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c2e:	00854783          	lbu	a5,8(a0)
    80004c32:	c7c5                	beqz	a5,80004cda <fileread+0xba>
    80004c34:	84aa                	mv	s1,a0
    80004c36:	89ae                	mv	s3,a1
    80004c38:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c3a:	411c                	lw	a5,0(a0)
    80004c3c:	4705                	li	a4,1
    80004c3e:	04e78963          	beq	a5,a4,80004c90 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c42:	470d                	li	a4,3
    80004c44:	04e78d63          	beq	a5,a4,80004c9e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004c48:	4709                	li	a4,2
    80004c4a:	08e79063          	bne	a5,a4,80004cca <fileread+0xaa>
    ilock(f->ip);
    80004c4e:	6d08                	ld	a0,24(a0)
    80004c50:	fffff097          	auipc	ra,0xfffff
    80004c54:	dc0080e7          	jalr	-576(ra) # 80003a10 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c58:	874a                	mv	a4,s2
    80004c5a:	5094                	lw	a3,32(s1)
    80004c5c:	864e                	mv	a2,s3
    80004c5e:	4585                	li	a1,1
    80004c60:	6c88                	ld	a0,24(s1)
    80004c62:	fffff097          	auipc	ra,0xfffff
    80004c66:	03e080e7          	jalr	62(ra) # 80003ca0 <readi>
    80004c6a:	892a                	mv	s2,a0
    80004c6c:	00a05563          	blez	a0,80004c76 <fileread+0x56>
      f->off += r;
    80004c70:	509c                	lw	a5,32(s1)
    80004c72:	9fa9                	addw	a5,a5,a0
    80004c74:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c76:	6c88                	ld	a0,24(s1)
    80004c78:	fffff097          	auipc	ra,0xfffff
    80004c7c:	e5a080e7          	jalr	-422(ra) # 80003ad2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c80:	854a                	mv	a0,s2
    80004c82:	70a2                	ld	ra,40(sp)
    80004c84:	7402                	ld	s0,32(sp)
    80004c86:	64e2                	ld	s1,24(sp)
    80004c88:	6942                	ld	s2,16(sp)
    80004c8a:	69a2                	ld	s3,8(sp)
    80004c8c:	6145                	addi	sp,sp,48
    80004c8e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c90:	6908                	ld	a0,16(a0)
    80004c92:	00000097          	auipc	ra,0x0
    80004c96:	408080e7          	jalr	1032(ra) # 8000509a <piperead>
    80004c9a:	892a                	mv	s2,a0
    80004c9c:	b7d5                	j	80004c80 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c9e:	02451783          	lh	a5,36(a0)
    80004ca2:	03079693          	slli	a3,a5,0x30
    80004ca6:	92c1                	srli	a3,a3,0x30
    80004ca8:	4725                	li	a4,9
    80004caa:	02d76a63          	bltu	a4,a3,80004cde <fileread+0xbe>
    80004cae:	0792                	slli	a5,a5,0x4
    80004cb0:	00028717          	auipc	a4,0x28
    80004cb4:	12870713          	addi	a4,a4,296 # 8002cdd8 <devsw>
    80004cb8:	97ba                	add	a5,a5,a4
    80004cba:	639c                	ld	a5,0(a5)
    80004cbc:	c39d                	beqz	a5,80004ce2 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80004cbe:	86b2                	mv	a3,a2
    80004cc0:	862e                	mv	a2,a1
    80004cc2:	4585                	li	a1,1
    80004cc4:	9782                	jalr	a5
    80004cc6:	892a                	mv	s2,a0
    80004cc8:	bf65                	j	80004c80 <fileread+0x60>
    panic("fileread");
    80004cca:	00004517          	auipc	a0,0x4
    80004cce:	d0650513          	addi	a0,a0,-762 # 800089d0 <userret+0x940>
    80004cd2:	ffffc097          	auipc	ra,0xffffc
    80004cd6:	876080e7          	jalr	-1930(ra) # 80000548 <panic>
    return -1;
    80004cda:	597d                	li	s2,-1
    80004cdc:	b755                	j	80004c80 <fileread+0x60>
      return -1;
    80004cde:	597d                	li	s2,-1
    80004ce0:	b745                	j	80004c80 <fileread+0x60>
    80004ce2:	597d                	li	s2,-1
    80004ce4:	bf71                	j	80004c80 <fileread+0x60>

0000000080004ce6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004ce6:	00954783          	lbu	a5,9(a0)
    80004cea:	14078663          	beqz	a5,80004e36 <filewrite+0x150>
{
    80004cee:	715d                	addi	sp,sp,-80
    80004cf0:	e486                	sd	ra,72(sp)
    80004cf2:	e0a2                	sd	s0,64(sp)
    80004cf4:	fc26                	sd	s1,56(sp)
    80004cf6:	f84a                	sd	s2,48(sp)
    80004cf8:	f44e                	sd	s3,40(sp)
    80004cfa:	f052                	sd	s4,32(sp)
    80004cfc:	ec56                	sd	s5,24(sp)
    80004cfe:	e85a                	sd	s6,16(sp)
    80004d00:	e45e                	sd	s7,8(sp)
    80004d02:	e062                	sd	s8,0(sp)
    80004d04:	0880                	addi	s0,sp,80
    80004d06:	84aa                	mv	s1,a0
    80004d08:	8aae                	mv	s5,a1
    80004d0a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d0c:	411c                	lw	a5,0(a0)
    80004d0e:	4705                	li	a4,1
    80004d10:	02e78263          	beq	a5,a4,80004d34 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d14:	470d                	li	a4,3
    80004d16:	02e78563          	beq	a5,a4,80004d40 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004d1a:	4709                	li	a4,2
    80004d1c:	10e79563          	bne	a5,a4,80004e26 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d20:	0ec05f63          	blez	a2,80004e1e <filewrite+0x138>
    int i = 0;
    80004d24:	4981                	li	s3,0
    80004d26:	6b05                	lui	s6,0x1
    80004d28:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d2c:	6b85                	lui	s7,0x1
    80004d2e:	c00b8b9b          	addiw	s7,s7,-1024
    80004d32:	a851                	j	80004dc6 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004d34:	6908                	ld	a0,16(a0)
    80004d36:	00000097          	auipc	ra,0x0
    80004d3a:	256080e7          	jalr	598(ra) # 80004f8c <pipewrite>
    80004d3e:	a865                	j	80004df6 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d40:	02451783          	lh	a5,36(a0)
    80004d44:	03079693          	slli	a3,a5,0x30
    80004d48:	92c1                	srli	a3,a3,0x30
    80004d4a:	4725                	li	a4,9
    80004d4c:	0ed76763          	bltu	a4,a3,80004e3a <filewrite+0x154>
    80004d50:	0792                	slli	a5,a5,0x4
    80004d52:	00028717          	auipc	a4,0x28
    80004d56:	08670713          	addi	a4,a4,134 # 8002cdd8 <devsw>
    80004d5a:	97ba                	add	a5,a5,a4
    80004d5c:	679c                	ld	a5,8(a5)
    80004d5e:	c3e5                	beqz	a5,80004e3e <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004d60:	86b2                	mv	a3,a2
    80004d62:	862e                	mv	a2,a1
    80004d64:	4585                	li	a1,1
    80004d66:	9782                	jalr	a5
    80004d68:	a079                	j	80004df6 <filewrite+0x110>
    80004d6a:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    80004d6e:	6c9c                	ld	a5,24(s1)
    80004d70:	4388                	lw	a0,0(a5)
    80004d72:	fffff097          	auipc	ra,0xfffff
    80004d76:	744080e7          	jalr	1860(ra) # 800044b6 <begin_op>
      ilock(f->ip);
    80004d7a:	6c88                	ld	a0,24(s1)
    80004d7c:	fffff097          	auipc	ra,0xfffff
    80004d80:	c94080e7          	jalr	-876(ra) # 80003a10 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d84:	8762                	mv	a4,s8
    80004d86:	5094                	lw	a3,32(s1)
    80004d88:	01598633          	add	a2,s3,s5
    80004d8c:	4585                	li	a1,1
    80004d8e:	6c88                	ld	a0,24(s1)
    80004d90:	fffff097          	auipc	ra,0xfffff
    80004d94:	004080e7          	jalr	4(ra) # 80003d94 <writei>
    80004d98:	892a                	mv	s2,a0
    80004d9a:	02a05e63          	blez	a0,80004dd6 <filewrite+0xf0>
        f->off += r;
    80004d9e:	509c                	lw	a5,32(s1)
    80004da0:	9fa9                	addw	a5,a5,a0
    80004da2:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004da4:	6c88                	ld	a0,24(s1)
    80004da6:	fffff097          	auipc	ra,0xfffff
    80004daa:	d2c080e7          	jalr	-724(ra) # 80003ad2 <iunlock>
      end_op(f->ip->dev);
    80004dae:	6c9c                	ld	a5,24(s1)
    80004db0:	4388                	lw	a0,0(a5)
    80004db2:	fffff097          	auipc	ra,0xfffff
    80004db6:	7ae080e7          	jalr	1966(ra) # 80004560 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004dba:	052c1a63          	bne	s8,s2,80004e0e <filewrite+0x128>
        panic("short filewrite");
      i += r;
    80004dbe:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80004dc2:	0349d763          	bge	s3,s4,80004df0 <filewrite+0x10a>
      int n1 = n - i;
    80004dc6:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004dca:	893e                	mv	s2,a5
    80004dcc:	2781                	sext.w	a5,a5
    80004dce:	f8fb5ee3          	bge	s6,a5,80004d6a <filewrite+0x84>
    80004dd2:	895e                	mv	s2,s7
    80004dd4:	bf59                	j	80004d6a <filewrite+0x84>
      iunlock(f->ip);
    80004dd6:	6c88                	ld	a0,24(s1)
    80004dd8:	fffff097          	auipc	ra,0xfffff
    80004ddc:	cfa080e7          	jalr	-774(ra) # 80003ad2 <iunlock>
      end_op(f->ip->dev);
    80004de0:	6c9c                	ld	a5,24(s1)
    80004de2:	4388                	lw	a0,0(a5)
    80004de4:	fffff097          	auipc	ra,0xfffff
    80004de8:	77c080e7          	jalr	1916(ra) # 80004560 <end_op>
      if(r < 0)
    80004dec:	fc0957e3          	bgez	s2,80004dba <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004df0:	8552                	mv	a0,s4
    80004df2:	033a1863          	bne	s4,s3,80004e22 <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004df6:	60a6                	ld	ra,72(sp)
    80004df8:	6406                	ld	s0,64(sp)
    80004dfa:	74e2                	ld	s1,56(sp)
    80004dfc:	7942                	ld	s2,48(sp)
    80004dfe:	79a2                	ld	s3,40(sp)
    80004e00:	7a02                	ld	s4,32(sp)
    80004e02:	6ae2                	ld	s5,24(sp)
    80004e04:	6b42                	ld	s6,16(sp)
    80004e06:	6ba2                	ld	s7,8(sp)
    80004e08:	6c02                	ld	s8,0(sp)
    80004e0a:	6161                	addi	sp,sp,80
    80004e0c:	8082                	ret
        panic("short filewrite");
    80004e0e:	00004517          	auipc	a0,0x4
    80004e12:	bd250513          	addi	a0,a0,-1070 # 800089e0 <userret+0x950>
    80004e16:	ffffb097          	auipc	ra,0xffffb
    80004e1a:	732080e7          	jalr	1842(ra) # 80000548 <panic>
    int i = 0;
    80004e1e:	4981                	li	s3,0
    80004e20:	bfc1                	j	80004df0 <filewrite+0x10a>
    ret = (i == n ? n : -1);
    80004e22:	557d                	li	a0,-1
    80004e24:	bfc9                	j	80004df6 <filewrite+0x110>
    panic("filewrite");
    80004e26:	00004517          	auipc	a0,0x4
    80004e2a:	bca50513          	addi	a0,a0,-1078 # 800089f0 <userret+0x960>
    80004e2e:	ffffb097          	auipc	ra,0xffffb
    80004e32:	71a080e7          	jalr	1818(ra) # 80000548 <panic>
    return -1;
    80004e36:	557d                	li	a0,-1
}
    80004e38:	8082                	ret
      return -1;
    80004e3a:	557d                	li	a0,-1
    80004e3c:	bf6d                	j	80004df6 <filewrite+0x110>
    80004e3e:	557d                	li	a0,-1
    80004e40:	bf5d                	j	80004df6 <filewrite+0x110>

0000000080004e42 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e42:	7179                	addi	sp,sp,-48
    80004e44:	f406                	sd	ra,40(sp)
    80004e46:	f022                	sd	s0,32(sp)
    80004e48:	ec26                	sd	s1,24(sp)
    80004e4a:	e84a                	sd	s2,16(sp)
    80004e4c:	e44e                	sd	s3,8(sp)
    80004e4e:	e052                	sd	s4,0(sp)
    80004e50:	1800                	addi	s0,sp,48
    80004e52:	84aa                	mv	s1,a0
    80004e54:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e56:	0005b023          	sd	zero,0(a1)
    80004e5a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e5e:	00000097          	auipc	ra,0x0
    80004e62:	bc4080e7          	jalr	-1084(ra) # 80004a22 <filealloc>
    80004e66:	e088                	sd	a0,0(s1)
    80004e68:	c551                	beqz	a0,80004ef4 <pipealloc+0xb2>
    80004e6a:	00000097          	auipc	ra,0x0
    80004e6e:	bb8080e7          	jalr	-1096(ra) # 80004a22 <filealloc>
    80004e72:	00aa3023          	sd	a0,0(s4)
    80004e76:	c92d                	beqz	a0,80004ee8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e78:	ffffc097          	auipc	ra,0xffffc
    80004e7c:	c46080e7          	jalr	-954(ra) # 80000abe <kalloc>
    80004e80:	892a                	mv	s2,a0
    80004e82:	c125                	beqz	a0,80004ee2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e84:	4985                	li	s3,1
    80004e86:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004e8a:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004e8e:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004e92:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004e96:	00004597          	auipc	a1,0x4
    80004e9a:	b6a58593          	addi	a1,a1,-1174 # 80008a00 <userret+0x970>
    80004e9e:	ffffc097          	auipc	ra,0xffffc
    80004ea2:	cb0080e7          	jalr	-848(ra) # 80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    80004ea6:	609c                	ld	a5,0(s1)
    80004ea8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004eac:	609c                	ld	a5,0(s1)
    80004eae:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004eb2:	609c                	ld	a5,0(s1)
    80004eb4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004eb8:	609c                	ld	a5,0(s1)
    80004eba:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ebe:	000a3783          	ld	a5,0(s4)
    80004ec2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ec6:	000a3783          	ld	a5,0(s4)
    80004eca:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ece:	000a3783          	ld	a5,0(s4)
    80004ed2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ed6:	000a3783          	ld	a5,0(s4)
    80004eda:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ede:	4501                	li	a0,0
    80004ee0:	a025                	j	80004f08 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ee2:	6088                	ld	a0,0(s1)
    80004ee4:	e501                	bnez	a0,80004eec <pipealloc+0xaa>
    80004ee6:	a039                	j	80004ef4 <pipealloc+0xb2>
    80004ee8:	6088                	ld	a0,0(s1)
    80004eea:	c51d                	beqz	a0,80004f18 <pipealloc+0xd6>
    fileclose(*f0);
    80004eec:	00000097          	auipc	ra,0x0
    80004ef0:	bf2080e7          	jalr	-1038(ra) # 80004ade <fileclose>
  if(*f1)
    80004ef4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ef8:	557d                	li	a0,-1
  if(*f1)
    80004efa:	c799                	beqz	a5,80004f08 <pipealloc+0xc6>
    fileclose(*f1);
    80004efc:	853e                	mv	a0,a5
    80004efe:	00000097          	auipc	ra,0x0
    80004f02:	be0080e7          	jalr	-1056(ra) # 80004ade <fileclose>
  return -1;
    80004f06:	557d                	li	a0,-1
}
    80004f08:	70a2                	ld	ra,40(sp)
    80004f0a:	7402                	ld	s0,32(sp)
    80004f0c:	64e2                	ld	s1,24(sp)
    80004f0e:	6942                	ld	s2,16(sp)
    80004f10:	69a2                	ld	s3,8(sp)
    80004f12:	6a02                	ld	s4,0(sp)
    80004f14:	6145                	addi	sp,sp,48
    80004f16:	8082                	ret
  return -1;
    80004f18:	557d                	li	a0,-1
    80004f1a:	b7fd                	j	80004f08 <pipealloc+0xc6>

0000000080004f1c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f1c:	1101                	addi	sp,sp,-32
    80004f1e:	ec06                	sd	ra,24(sp)
    80004f20:	e822                	sd	s0,16(sp)
    80004f22:	e426                	sd	s1,8(sp)
    80004f24:	e04a                	sd	s2,0(sp)
    80004f26:	1000                	addi	s0,sp,32
    80004f28:	84aa                	mv	s1,a0
    80004f2a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f2c:	ffffc097          	auipc	ra,0xffffc
    80004f30:	d70080e7          	jalr	-656(ra) # 80000c9c <acquire>
  if(writable){
    80004f34:	02090d63          	beqz	s2,80004f6e <pipeclose+0x52>
    pi->writeopen = 0;
    80004f38:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004f3c:	22048513          	addi	a0,s1,544
    80004f40:	ffffd097          	auipc	ra,0xffffd
    80004f44:	6d8080e7          	jalr	1752(ra) # 80002618 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f48:	2284b783          	ld	a5,552(s1)
    80004f4c:	eb95                	bnez	a5,80004f80 <pipeclose+0x64>
    release(&pi->lock);
    80004f4e:	8526                	mv	a0,s1
    80004f50:	ffffc097          	auipc	ra,0xffffc
    80004f54:	dbc080e7          	jalr	-580(ra) # 80000d0c <release>
    kfree((char*)pi);
    80004f58:	8526                	mv	a0,s1
    80004f5a:	ffffc097          	auipc	ra,0xffffc
    80004f5e:	9f6080e7          	jalr	-1546(ra) # 80000950 <kfree>
  } else
    release(&pi->lock);
}
    80004f62:	60e2                	ld	ra,24(sp)
    80004f64:	6442                	ld	s0,16(sp)
    80004f66:	64a2                	ld	s1,8(sp)
    80004f68:	6902                	ld	s2,0(sp)
    80004f6a:	6105                	addi	sp,sp,32
    80004f6c:	8082                	ret
    pi->readopen = 0;
    80004f6e:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004f72:	22448513          	addi	a0,s1,548
    80004f76:	ffffd097          	auipc	ra,0xffffd
    80004f7a:	6a2080e7          	jalr	1698(ra) # 80002618 <wakeup>
    80004f7e:	b7e9                	j	80004f48 <pipeclose+0x2c>
    release(&pi->lock);
    80004f80:	8526                	mv	a0,s1
    80004f82:	ffffc097          	auipc	ra,0xffffc
    80004f86:	d8a080e7          	jalr	-630(ra) # 80000d0c <release>
}
    80004f8a:	bfe1                	j	80004f62 <pipeclose+0x46>

0000000080004f8c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f8c:	711d                	addi	sp,sp,-96
    80004f8e:	ec86                	sd	ra,88(sp)
    80004f90:	e8a2                	sd	s0,80(sp)
    80004f92:	e4a6                	sd	s1,72(sp)
    80004f94:	e0ca                	sd	s2,64(sp)
    80004f96:	fc4e                	sd	s3,56(sp)
    80004f98:	f852                	sd	s4,48(sp)
    80004f9a:	f456                	sd	s5,40(sp)
    80004f9c:	f05a                	sd	s6,32(sp)
    80004f9e:	ec5e                	sd	s7,24(sp)
    80004fa0:	e862                	sd	s8,16(sp)
    80004fa2:	1080                	addi	s0,sp,96
    80004fa4:	84aa                	mv	s1,a0
    80004fa6:	8aae                	mv	s5,a1
    80004fa8:	8a32                	mv	s4,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004faa:	ffffd097          	auipc	ra,0xffffd
    80004fae:	d18080e7          	jalr	-744(ra) # 80001cc2 <myproc>
    80004fb2:	8baa                	mv	s7,a0

  acquire(&pi->lock);
    80004fb4:	8526                	mv	a0,s1
    80004fb6:	ffffc097          	auipc	ra,0xffffc
    80004fba:	ce6080e7          	jalr	-794(ra) # 80000c9c <acquire>
  for(i = 0; i < n; i++){
    80004fbe:	09405f63          	blez	s4,8000505c <pipewrite+0xd0>
    80004fc2:	fffa0b1b          	addiw	s6,s4,-1
    80004fc6:	1b02                	slli	s6,s6,0x20
    80004fc8:	020b5b13          	srli	s6,s6,0x20
    80004fcc:	001a8793          	addi	a5,s5,1
    80004fd0:	9b3e                	add	s6,s6,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004fd2:	22048993          	addi	s3,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004fd6:	22448913          	addi	s2,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fda:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004fdc:	2204a783          	lw	a5,544(s1)
    80004fe0:	2244a703          	lw	a4,548(s1)
    80004fe4:	2007879b          	addiw	a5,a5,512
    80004fe8:	02f71e63          	bne	a4,a5,80005024 <pipewrite+0x98>
      if(pi->readopen == 0 || myproc()->killed){
    80004fec:	2284a783          	lw	a5,552(s1)
    80004ff0:	c3d9                	beqz	a5,80005076 <pipewrite+0xea>
    80004ff2:	ffffd097          	auipc	ra,0xffffd
    80004ff6:	cd0080e7          	jalr	-816(ra) # 80001cc2 <myproc>
    80004ffa:	5d1c                	lw	a5,56(a0)
    80004ffc:	efad                	bnez	a5,80005076 <pipewrite+0xea>
      wakeup(&pi->nread);
    80004ffe:	854e                	mv	a0,s3
    80005000:	ffffd097          	auipc	ra,0xffffd
    80005004:	618080e7          	jalr	1560(ra) # 80002618 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005008:	85a6                	mv	a1,s1
    8000500a:	854a                	mv	a0,s2
    8000500c:	ffffd097          	auipc	ra,0xffffd
    80005010:	48c080e7          	jalr	1164(ra) # 80002498 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80005014:	2204a783          	lw	a5,544(s1)
    80005018:	2244a703          	lw	a4,548(s1)
    8000501c:	2007879b          	addiw	a5,a5,512
    80005020:	fcf706e3          	beq	a4,a5,80004fec <pipewrite+0x60>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005024:	4685                	li	a3,1
    80005026:	8656                	mv	a2,s5
    80005028:	faf40593          	addi	a1,s0,-81
    8000502c:	058bb503          	ld	a0,88(s7) # 1058 <_entry-0x7fffefa8>
    80005030:	ffffd097          	auipc	ra,0xffffd
    80005034:	a10080e7          	jalr	-1520(ra) # 80001a40 <copyin>
    80005038:	03850263          	beq	a0,s8,8000505c <pipewrite+0xd0>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000503c:	2244a783          	lw	a5,548(s1)
    80005040:	0017871b          	addiw	a4,a5,1
    80005044:	22e4a223          	sw	a4,548(s1)
    80005048:	1ff7f793          	andi	a5,a5,511
    8000504c:	97a6                	add	a5,a5,s1
    8000504e:	faf44703          	lbu	a4,-81(s0)
    80005052:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80005056:	0a85                	addi	s5,s5,1
    80005058:	f96a92e3          	bne	s5,s6,80004fdc <pipewrite+0x50>
  }
  wakeup(&pi->nread);
    8000505c:	22048513          	addi	a0,s1,544
    80005060:	ffffd097          	auipc	ra,0xffffd
    80005064:	5b8080e7          	jalr	1464(ra) # 80002618 <wakeup>
  release(&pi->lock);
    80005068:	8526                	mv	a0,s1
    8000506a:	ffffc097          	auipc	ra,0xffffc
    8000506e:	ca2080e7          	jalr	-862(ra) # 80000d0c <release>
  return n;
    80005072:	8552                	mv	a0,s4
    80005074:	a039                	j	80005082 <pipewrite+0xf6>
        release(&pi->lock);
    80005076:	8526                	mv	a0,s1
    80005078:	ffffc097          	auipc	ra,0xffffc
    8000507c:	c94080e7          	jalr	-876(ra) # 80000d0c <release>
        return -1;
    80005080:	557d                	li	a0,-1
}
    80005082:	60e6                	ld	ra,88(sp)
    80005084:	6446                	ld	s0,80(sp)
    80005086:	64a6                	ld	s1,72(sp)
    80005088:	6906                	ld	s2,64(sp)
    8000508a:	79e2                	ld	s3,56(sp)
    8000508c:	7a42                	ld	s4,48(sp)
    8000508e:	7aa2                	ld	s5,40(sp)
    80005090:	7b02                	ld	s6,32(sp)
    80005092:	6be2                	ld	s7,24(sp)
    80005094:	6c42                	ld	s8,16(sp)
    80005096:	6125                	addi	sp,sp,96
    80005098:	8082                	ret

000000008000509a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000509a:	715d                	addi	sp,sp,-80
    8000509c:	e486                	sd	ra,72(sp)
    8000509e:	e0a2                	sd	s0,64(sp)
    800050a0:	fc26                	sd	s1,56(sp)
    800050a2:	f84a                	sd	s2,48(sp)
    800050a4:	f44e                	sd	s3,40(sp)
    800050a6:	f052                	sd	s4,32(sp)
    800050a8:	ec56                	sd	s5,24(sp)
    800050aa:	e85a                	sd	s6,16(sp)
    800050ac:	0880                	addi	s0,sp,80
    800050ae:	84aa                	mv	s1,a0
    800050b0:	892e                	mv	s2,a1
    800050b2:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    800050b4:	ffffd097          	auipc	ra,0xffffd
    800050b8:	c0e080e7          	jalr	-1010(ra) # 80001cc2 <myproc>
    800050bc:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    800050be:	8526                	mv	a0,s1
    800050c0:	ffffc097          	auipc	ra,0xffffc
    800050c4:	bdc080e7          	jalr	-1060(ra) # 80000c9c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050c8:	2204a703          	lw	a4,544(s1)
    800050cc:	2244a783          	lw	a5,548(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050d0:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050d4:	02f71763          	bne	a4,a5,80005102 <piperead+0x68>
    800050d8:	22c4a783          	lw	a5,556(s1)
    800050dc:	c39d                	beqz	a5,80005102 <piperead+0x68>
    if(myproc()->killed){
    800050de:	ffffd097          	auipc	ra,0xffffd
    800050e2:	be4080e7          	jalr	-1052(ra) # 80001cc2 <myproc>
    800050e6:	5d1c                	lw	a5,56(a0)
    800050e8:	ebc1                	bnez	a5,80005178 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050ea:	85a6                	mv	a1,s1
    800050ec:	854e                	mv	a0,s3
    800050ee:	ffffd097          	auipc	ra,0xffffd
    800050f2:	3aa080e7          	jalr	938(ra) # 80002498 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050f6:	2204a703          	lw	a4,544(s1)
    800050fa:	2244a783          	lw	a5,548(s1)
    800050fe:	fcf70de3          	beq	a4,a5,800050d8 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005102:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005104:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005106:	05405363          	blez	s4,8000514c <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000510a:	2204a783          	lw	a5,544(s1)
    8000510e:	2244a703          	lw	a4,548(s1)
    80005112:	02f70d63          	beq	a4,a5,8000514c <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005116:	0017871b          	addiw	a4,a5,1
    8000511a:	22e4a023          	sw	a4,544(s1)
    8000511e:	1ff7f793          	andi	a5,a5,511
    80005122:	97a6                	add	a5,a5,s1
    80005124:	0207c783          	lbu	a5,32(a5)
    80005128:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000512c:	4685                	li	a3,1
    8000512e:	fbf40613          	addi	a2,s0,-65
    80005132:	85ca                	mv	a1,s2
    80005134:	058ab503          	ld	a0,88(s5)
    80005138:	ffffc097          	auipc	ra,0xffffc
    8000513c:	7bc080e7          	jalr	1980(ra) # 800018f4 <copyout>
    80005140:	01650663          	beq	a0,s6,8000514c <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005144:	2985                	addiw	s3,s3,1
    80005146:	0905                	addi	s2,s2,1
    80005148:	fd3a11e3          	bne	s4,s3,8000510a <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000514c:	22448513          	addi	a0,s1,548
    80005150:	ffffd097          	auipc	ra,0xffffd
    80005154:	4c8080e7          	jalr	1224(ra) # 80002618 <wakeup>
  release(&pi->lock);
    80005158:	8526                	mv	a0,s1
    8000515a:	ffffc097          	auipc	ra,0xffffc
    8000515e:	bb2080e7          	jalr	-1102(ra) # 80000d0c <release>
  return i;
}
    80005162:	854e                	mv	a0,s3
    80005164:	60a6                	ld	ra,72(sp)
    80005166:	6406                	ld	s0,64(sp)
    80005168:	74e2                	ld	s1,56(sp)
    8000516a:	7942                	ld	s2,48(sp)
    8000516c:	79a2                	ld	s3,40(sp)
    8000516e:	7a02                	ld	s4,32(sp)
    80005170:	6ae2                	ld	s5,24(sp)
    80005172:	6b42                	ld	s6,16(sp)
    80005174:	6161                	addi	sp,sp,80
    80005176:	8082                	ret
      release(&pi->lock);
    80005178:	8526                	mv	a0,s1
    8000517a:	ffffc097          	auipc	ra,0xffffc
    8000517e:	b92080e7          	jalr	-1134(ra) # 80000d0c <release>
      return -1;
    80005182:	59fd                	li	s3,-1
    80005184:	bff9                	j	80005162 <piperead+0xc8>

0000000080005186 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005186:	de010113          	addi	sp,sp,-544
    8000518a:	20113c23          	sd	ra,536(sp)
    8000518e:	20813823          	sd	s0,528(sp)
    80005192:	20913423          	sd	s1,520(sp)
    80005196:	21213023          	sd	s2,512(sp)
    8000519a:	ffce                	sd	s3,504(sp)
    8000519c:	fbd2                	sd	s4,496(sp)
    8000519e:	f7d6                	sd	s5,488(sp)
    800051a0:	f3da                	sd	s6,480(sp)
    800051a2:	efde                	sd	s7,472(sp)
    800051a4:	ebe2                	sd	s8,464(sp)
    800051a6:	e7e6                	sd	s9,456(sp)
    800051a8:	e3ea                	sd	s10,448(sp)
    800051aa:	ff6e                	sd	s11,440(sp)
    800051ac:	1400                	addi	s0,sp,544
    800051ae:	892a                	mv	s2,a0
    800051b0:	dea43423          	sd	a0,-536(s0)
    800051b4:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800051b8:	ffffd097          	auipc	ra,0xffffd
    800051bc:	b0a080e7          	jalr	-1270(ra) # 80001cc2 <myproc>
    800051c0:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    800051c2:	4501                	li	a0,0
    800051c4:	fffff097          	auipc	ra,0xfffff
    800051c8:	2f2080e7          	jalr	754(ra) # 800044b6 <begin_op>

  if((ip = namei(path)) == 0){
    800051cc:	854a                	mv	a0,s2
    800051ce:	fffff097          	auipc	ra,0xfffff
    800051d2:	fcc080e7          	jalr	-52(ra) # 8000419a <namei>
    800051d6:	cd25                	beqz	a0,8000524e <exec+0xc8>
    800051d8:	8aaa                	mv	s5,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    800051da:	fffff097          	auipc	ra,0xfffff
    800051de:	836080e7          	jalr	-1994(ra) # 80003a10 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800051e2:	04000713          	li	a4,64
    800051e6:	4681                	li	a3,0
    800051e8:	e4840613          	addi	a2,s0,-440
    800051ec:	4581                	li	a1,0
    800051ee:	8556                	mv	a0,s5
    800051f0:	fffff097          	auipc	ra,0xfffff
    800051f4:	ab0080e7          	jalr	-1360(ra) # 80003ca0 <readi>
    800051f8:	04000793          	li	a5,64
    800051fc:	00f51a63          	bne	a0,a5,80005210 <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005200:	e4842703          	lw	a4,-440(s0)
    80005204:	464c47b7          	lui	a5,0x464c4
    80005208:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000520c:	04f70863          	beq	a4,a5,8000525c <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005210:	8556                	mv	a0,s5
    80005212:	fffff097          	auipc	ra,0xfffff
    80005216:	a3c080e7          	jalr	-1476(ra) # 80003c4e <iunlockput>
    end_op(ROOTDEV);
    8000521a:	4501                	li	a0,0
    8000521c:	fffff097          	auipc	ra,0xfffff
    80005220:	344080e7          	jalr	836(ra) # 80004560 <end_op>
  }
  return -1;
    80005224:	557d                	li	a0,-1
}
    80005226:	21813083          	ld	ra,536(sp)
    8000522a:	21013403          	ld	s0,528(sp)
    8000522e:	20813483          	ld	s1,520(sp)
    80005232:	20013903          	ld	s2,512(sp)
    80005236:	79fe                	ld	s3,504(sp)
    80005238:	7a5e                	ld	s4,496(sp)
    8000523a:	7abe                	ld	s5,488(sp)
    8000523c:	7b1e                	ld	s6,480(sp)
    8000523e:	6bfe                	ld	s7,472(sp)
    80005240:	6c5e                	ld	s8,464(sp)
    80005242:	6cbe                	ld	s9,456(sp)
    80005244:	6d1e                	ld	s10,448(sp)
    80005246:	7dfa                	ld	s11,440(sp)
    80005248:	22010113          	addi	sp,sp,544
    8000524c:	8082                	ret
    end_op(ROOTDEV);
    8000524e:	4501                	li	a0,0
    80005250:	fffff097          	auipc	ra,0xfffff
    80005254:	310080e7          	jalr	784(ra) # 80004560 <end_op>
    return -1;
    80005258:	557d                	li	a0,-1
    8000525a:	b7f1                	j	80005226 <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    8000525c:	8526                	mv	a0,s1
    8000525e:	ffffd097          	auipc	ra,0xffffd
    80005262:	b28080e7          	jalr	-1240(ra) # 80001d86 <proc_pagetable>
    80005266:	8b2a                	mv	s6,a0
    80005268:	d545                	beqz	a0,80005210 <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000526a:	e6842783          	lw	a5,-408(s0)
    8000526e:	e8045703          	lhu	a4,-384(s0)
    80005272:	10070263          	beqz	a4,80005376 <exec+0x1f0>
  sz = 0;
    80005276:	de043c23          	sd	zero,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000527a:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000527e:	6a05                	lui	s4,0x1
    80005280:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005284:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005288:	6d85                	lui	s11,0x1
    8000528a:	7d7d                	lui	s10,0xfffff
    8000528c:	a88d                	j	800052fe <exec+0x178>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000528e:	00003517          	auipc	a0,0x3
    80005292:	77a50513          	addi	a0,a0,1914 # 80008a08 <userret+0x978>
    80005296:	ffffb097          	auipc	ra,0xffffb
    8000529a:	2b2080e7          	jalr	690(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000529e:	874a                	mv	a4,s2
    800052a0:	009c86bb          	addw	a3,s9,s1
    800052a4:	4581                	li	a1,0
    800052a6:	8556                	mv	a0,s5
    800052a8:	fffff097          	auipc	ra,0xfffff
    800052ac:	9f8080e7          	jalr	-1544(ra) # 80003ca0 <readi>
    800052b0:	2501                	sext.w	a0,a0
    800052b2:	10a91863          	bne	s2,a0,800053c2 <exec+0x23c>
  for(i = 0; i < sz; i += PGSIZE){
    800052b6:	009d84bb          	addw	s1,s11,s1
    800052ba:	013d09bb          	addw	s3,s10,s3
    800052be:	0374f263          	bgeu	s1,s7,800052e2 <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    800052c2:	02049593          	slli	a1,s1,0x20
    800052c6:	9181                	srli	a1,a1,0x20
    800052c8:	95e2                	add	a1,a1,s8
    800052ca:	855a                	mv	a0,s6
    800052cc:	ffffc097          	auipc	ra,0xffffc
    800052d0:	034080e7          	jalr	52(ra) # 80001300 <walkaddr>
    800052d4:	862a                	mv	a2,a0
    if(pa == 0)
    800052d6:	dd45                	beqz	a0,8000528e <exec+0x108>
      n = PGSIZE;
    800052d8:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800052da:	fd49f2e3          	bgeu	s3,s4,8000529e <exec+0x118>
      n = sz - i;
    800052de:	894e                	mv	s2,s3
    800052e0:	bf7d                	j	8000529e <exec+0x118>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052e2:	e0843783          	ld	a5,-504(s0)
    800052e6:	0017869b          	addiw	a3,a5,1
    800052ea:	e0d43423          	sd	a3,-504(s0)
    800052ee:	e0043783          	ld	a5,-512(s0)
    800052f2:	0387879b          	addiw	a5,a5,56
    800052f6:	e8045703          	lhu	a4,-384(s0)
    800052fa:	08e6d063          	bge	a3,a4,8000537a <exec+0x1f4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052fe:	2781                	sext.w	a5,a5
    80005300:	e0f43023          	sd	a5,-512(s0)
    80005304:	03800713          	li	a4,56
    80005308:	86be                	mv	a3,a5
    8000530a:	e1040613          	addi	a2,s0,-496
    8000530e:	4581                	li	a1,0
    80005310:	8556                	mv	a0,s5
    80005312:	fffff097          	auipc	ra,0xfffff
    80005316:	98e080e7          	jalr	-1650(ra) # 80003ca0 <readi>
    8000531a:	03800793          	li	a5,56
    8000531e:	0af51263          	bne	a0,a5,800053c2 <exec+0x23c>
    if(ph.type != ELF_PROG_LOAD)
    80005322:	e1042783          	lw	a5,-496(s0)
    80005326:	4705                	li	a4,1
    80005328:	fae79de3          	bne	a5,a4,800052e2 <exec+0x15c>
    if(ph.memsz < ph.filesz)
    8000532c:	e3843603          	ld	a2,-456(s0)
    80005330:	e3043783          	ld	a5,-464(s0)
    80005334:	08f66763          	bltu	a2,a5,800053c2 <exec+0x23c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005338:	e2043783          	ld	a5,-480(s0)
    8000533c:	963e                	add	a2,a2,a5
    8000533e:	08f66263          	bltu	a2,a5,800053c2 <exec+0x23c>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005342:	df843583          	ld	a1,-520(s0)
    80005346:	855a                	mv	a0,s6
    80005348:	ffffc097          	auipc	ra,0xffffc
    8000534c:	3c6080e7          	jalr	966(ra) # 8000170e <uvmalloc>
    80005350:	dea43c23          	sd	a0,-520(s0)
    80005354:	c53d                	beqz	a0,800053c2 <exec+0x23c>
    if(ph.vaddr % PGSIZE != 0)
    80005356:	e2043c03          	ld	s8,-480(s0)
    8000535a:	de043783          	ld	a5,-544(s0)
    8000535e:	00fc77b3          	and	a5,s8,a5
    80005362:	e3a5                	bnez	a5,800053c2 <exec+0x23c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005364:	e1842c83          	lw	s9,-488(s0)
    80005368:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000536c:	f60b8be3          	beqz	s7,800052e2 <exec+0x15c>
    80005370:	89de                	mv	s3,s7
    80005372:	4481                	li	s1,0
    80005374:	b7b9                	j	800052c2 <exec+0x13c>
  sz = 0;
    80005376:	de043c23          	sd	zero,-520(s0)
  iunlockput(ip);
    8000537a:	8556                	mv	a0,s5
    8000537c:	fffff097          	auipc	ra,0xfffff
    80005380:	8d2080e7          	jalr	-1838(ra) # 80003c4e <iunlockput>
  end_op(ROOTDEV);
    80005384:	4501                	li	a0,0
    80005386:	fffff097          	auipc	ra,0xfffff
    8000538a:	1da080e7          	jalr	474(ra) # 80004560 <end_op>
  p = myproc();
    8000538e:	ffffd097          	auipc	ra,0xffffd
    80005392:	934080e7          	jalr	-1740(ra) # 80001cc2 <myproc>
    80005396:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005398:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    8000539c:	6585                	lui	a1,0x1
    8000539e:	15fd                	addi	a1,a1,-1
    800053a0:	df843783          	ld	a5,-520(s0)
    800053a4:	95be                	add	a1,a1,a5
    800053a6:	77fd                	lui	a5,0xfffff
    800053a8:	8dfd                	and	a1,a1,a5
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800053aa:	6609                	lui	a2,0x2
    800053ac:	962e                	add	a2,a2,a1
    800053ae:	855a                	mv	a0,s6
    800053b0:	ffffc097          	auipc	ra,0xffffc
    800053b4:	35e080e7          	jalr	862(ra) # 8000170e <uvmalloc>
    800053b8:	892a                	mv	s2,a0
    800053ba:	dea43c23          	sd	a0,-520(s0)
  ip = 0;
    800053be:	4a81                	li	s5,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800053c0:	ed01                	bnez	a0,800053d8 <exec+0x252>
    proc_freepagetable(pagetable, sz);
    800053c2:	df843583          	ld	a1,-520(s0)
    800053c6:	855a                	mv	a0,s6
    800053c8:	ffffd097          	auipc	ra,0xffffd
    800053cc:	abe080e7          	jalr	-1346(ra) # 80001e86 <proc_freepagetable>
  if(ip){
    800053d0:	e40a90e3          	bnez	s5,80005210 <exec+0x8a>
  return -1;
    800053d4:	557d                	li	a0,-1
    800053d6:	bd81                	j	80005226 <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    800053d8:	75f9                	lui	a1,0xffffe
    800053da:	95aa                	add	a1,a1,a0
    800053dc:	855a                	mv	a0,s6
    800053de:	ffffc097          	auipc	ra,0xffffc
    800053e2:	4e4080e7          	jalr	1252(ra) # 800018c2 <uvmclear>
  stackbase = sp - PGSIZE;
    800053e6:	7c7d                	lui	s8,0xfffff
    800053e8:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    800053ea:	df043783          	ld	a5,-528(s0)
    800053ee:	6388                	ld	a0,0(a5)
    800053f0:	c52d                	beqz	a0,8000545a <exec+0x2d4>
    800053f2:	e8840993          	addi	s3,s0,-376
    800053f6:	f8840a93          	addi	s5,s0,-120
    800053fa:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800053fc:	ffffc097          	auipc	ra,0xffffc
    80005400:	c8e080e7          	jalr	-882(ra) # 8000108a <strlen>
    80005404:	0015079b          	addiw	a5,a0,1
    80005408:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000540c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005410:	0f896b63          	bltu	s2,s8,80005506 <exec+0x380>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005414:	df043d03          	ld	s10,-528(s0)
    80005418:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7ffcafa4>
    8000541c:	8552                	mv	a0,s4
    8000541e:	ffffc097          	auipc	ra,0xffffc
    80005422:	c6c080e7          	jalr	-916(ra) # 8000108a <strlen>
    80005426:	0015069b          	addiw	a3,a0,1
    8000542a:	8652                	mv	a2,s4
    8000542c:	85ca                	mv	a1,s2
    8000542e:	855a                	mv	a0,s6
    80005430:	ffffc097          	auipc	ra,0xffffc
    80005434:	4c4080e7          	jalr	1220(ra) # 800018f4 <copyout>
    80005438:	0c054963          	bltz	a0,8000550a <exec+0x384>
    ustack[argc] = sp;
    8000543c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005440:	0485                	addi	s1,s1,1
    80005442:	008d0793          	addi	a5,s10,8
    80005446:	def43823          	sd	a5,-528(s0)
    8000544a:	008d3503          	ld	a0,8(s10)
    8000544e:	c909                	beqz	a0,80005460 <exec+0x2da>
    if(argc >= MAXARG)
    80005450:	09a1                	addi	s3,s3,8
    80005452:	fb3a95e3          	bne	s5,s3,800053fc <exec+0x276>
  ip = 0;
    80005456:	4a81                	li	s5,0
    80005458:	b7ad                	j	800053c2 <exec+0x23c>
  sp = sz;
    8000545a:	df843903          	ld	s2,-520(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000545e:	4481                	li	s1,0
  ustack[argc] = 0;
    80005460:	00349793          	slli	a5,s1,0x3
    80005464:	f9040713          	addi	a4,s0,-112
    80005468:	97ba                	add	a5,a5,a4
    8000546a:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcae9c>
  sp -= (argc+1) * sizeof(uint64);
    8000546e:	00148693          	addi	a3,s1,1
    80005472:	068e                	slli	a3,a3,0x3
    80005474:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005478:	ff097913          	andi	s2,s2,-16
  ip = 0;
    8000547c:	4a81                	li	s5,0
  if(sp < stackbase)
    8000547e:	f58962e3          	bltu	s2,s8,800053c2 <exec+0x23c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005482:	e8840613          	addi	a2,s0,-376
    80005486:	85ca                	mv	a1,s2
    80005488:	855a                	mv	a0,s6
    8000548a:	ffffc097          	auipc	ra,0xffffc
    8000548e:	46a080e7          	jalr	1130(ra) # 800018f4 <copyout>
    80005492:	06054e63          	bltz	a0,8000550e <exec+0x388>
  p->tf->a1 = sp;
    80005496:	060bb783          	ld	a5,96(s7)
    8000549a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000549e:	de843783          	ld	a5,-536(s0)
    800054a2:	0007c703          	lbu	a4,0(a5)
    800054a6:	cf11                	beqz	a4,800054c2 <exec+0x33c>
    800054a8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800054aa:	02f00693          	li	a3,47
    800054ae:	a039                	j	800054bc <exec+0x336>
      last = s+1;
    800054b0:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800054b4:	0785                	addi	a5,a5,1
    800054b6:	fff7c703          	lbu	a4,-1(a5)
    800054ba:	c701                	beqz	a4,800054c2 <exec+0x33c>
    if(*s == '/')
    800054bc:	fed71ce3          	bne	a4,a3,800054b4 <exec+0x32e>
    800054c0:	bfc5                	j	800054b0 <exec+0x32a>
  safestrcpy(p->name, last, sizeof(p->name));
    800054c2:	4641                	li	a2,16
    800054c4:	de843583          	ld	a1,-536(s0)
    800054c8:	160b8513          	addi	a0,s7,352
    800054cc:	ffffc097          	auipc	ra,0xffffc
    800054d0:	b8c080e7          	jalr	-1140(ra) # 80001058 <safestrcpy>
  oldpagetable = p->pagetable;
    800054d4:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    800054d8:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    800054dc:	df843783          	ld	a5,-520(s0)
    800054e0:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    800054e4:	060bb783          	ld	a5,96(s7)
    800054e8:	e6043703          	ld	a4,-416(s0)
    800054ec:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    800054ee:	060bb783          	ld	a5,96(s7)
    800054f2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800054f6:	85e6                	mv	a1,s9
    800054f8:	ffffd097          	auipc	ra,0xffffd
    800054fc:	98e080e7          	jalr	-1650(ra) # 80001e86 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005500:	0004851b          	sext.w	a0,s1
    80005504:	b30d                	j	80005226 <exec+0xa0>
  ip = 0;
    80005506:	4a81                	li	s5,0
    80005508:	bd6d                	j	800053c2 <exec+0x23c>
    8000550a:	4a81                	li	s5,0
    8000550c:	bd5d                	j	800053c2 <exec+0x23c>
    8000550e:	4a81                	li	s5,0
    80005510:	bd4d                	j	800053c2 <exec+0x23c>

0000000080005512 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005512:	7179                	addi	sp,sp,-48
    80005514:	f406                	sd	ra,40(sp)
    80005516:	f022                	sd	s0,32(sp)
    80005518:	ec26                	sd	s1,24(sp)
    8000551a:	e84a                	sd	s2,16(sp)
    8000551c:	1800                	addi	s0,sp,48
    8000551e:	892e                	mv	s2,a1
    80005520:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005522:	fdc40593          	addi	a1,s0,-36
    80005526:	ffffe097          	auipc	ra,0xffffe
    8000552a:	976080e7          	jalr	-1674(ra) # 80002e9c <argint>
    8000552e:	04054063          	bltz	a0,8000556e <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005532:	fdc42703          	lw	a4,-36(s0)
    80005536:	47bd                	li	a5,15
    80005538:	02e7ed63          	bltu	a5,a4,80005572 <argfd+0x60>
    8000553c:	ffffc097          	auipc	ra,0xffffc
    80005540:	786080e7          	jalr	1926(ra) # 80001cc2 <myproc>
    80005544:	fdc42703          	lw	a4,-36(s0)
    80005548:	01a70793          	addi	a5,a4,26
    8000554c:	078e                	slli	a5,a5,0x3
    8000554e:	953e                	add	a0,a0,a5
    80005550:	651c                	ld	a5,8(a0)
    80005552:	c395                	beqz	a5,80005576 <argfd+0x64>
    return -1;
  if(pfd)
    80005554:	00090463          	beqz	s2,8000555c <argfd+0x4a>
    *pfd = fd;
    80005558:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000555c:	4501                	li	a0,0
  if(pf)
    8000555e:	c091                	beqz	s1,80005562 <argfd+0x50>
    *pf = f;
    80005560:	e09c                	sd	a5,0(s1)
}
    80005562:	70a2                	ld	ra,40(sp)
    80005564:	7402                	ld	s0,32(sp)
    80005566:	64e2                	ld	s1,24(sp)
    80005568:	6942                	ld	s2,16(sp)
    8000556a:	6145                	addi	sp,sp,48
    8000556c:	8082                	ret
    return -1;
    8000556e:	557d                	li	a0,-1
    80005570:	bfcd                	j	80005562 <argfd+0x50>
    return -1;
    80005572:	557d                	li	a0,-1
    80005574:	b7fd                	j	80005562 <argfd+0x50>
    80005576:	557d                	li	a0,-1
    80005578:	b7ed                	j	80005562 <argfd+0x50>

000000008000557a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000557a:	1101                	addi	sp,sp,-32
    8000557c:	ec06                	sd	ra,24(sp)
    8000557e:	e822                	sd	s0,16(sp)
    80005580:	e426                	sd	s1,8(sp)
    80005582:	1000                	addi	s0,sp,32
    80005584:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005586:	ffffc097          	auipc	ra,0xffffc
    8000558a:	73c080e7          	jalr	1852(ra) # 80001cc2 <myproc>
    8000558e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005590:	0d850793          	addi	a5,a0,216
    80005594:	4501                	li	a0,0
    80005596:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005598:	6398                	ld	a4,0(a5)
    8000559a:	cb19                	beqz	a4,800055b0 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000559c:	2505                	addiw	a0,a0,1
    8000559e:	07a1                	addi	a5,a5,8
    800055a0:	fed51ce3          	bne	a0,a3,80005598 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800055a4:	557d                	li	a0,-1
}
    800055a6:	60e2                	ld	ra,24(sp)
    800055a8:	6442                	ld	s0,16(sp)
    800055aa:	64a2                	ld	s1,8(sp)
    800055ac:	6105                	addi	sp,sp,32
    800055ae:	8082                	ret
      p->ofile[fd] = f;
    800055b0:	01a50793          	addi	a5,a0,26
    800055b4:	078e                	slli	a5,a5,0x3
    800055b6:	963e                	add	a2,a2,a5
    800055b8:	e604                	sd	s1,8(a2)
      return fd;
    800055ba:	b7f5                	j	800055a6 <fdalloc+0x2c>

00000000800055bc <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055bc:	715d                	addi	sp,sp,-80
    800055be:	e486                	sd	ra,72(sp)
    800055c0:	e0a2                	sd	s0,64(sp)
    800055c2:	fc26                	sd	s1,56(sp)
    800055c4:	f84a                	sd	s2,48(sp)
    800055c6:	f44e                	sd	s3,40(sp)
    800055c8:	f052                	sd	s4,32(sp)
    800055ca:	ec56                	sd	s5,24(sp)
    800055cc:	0880                	addi	s0,sp,80
    800055ce:	89ae                	mv	s3,a1
    800055d0:	8ab2                	mv	s5,a2
    800055d2:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800055d4:	fb040593          	addi	a1,s0,-80
    800055d8:	fffff097          	auipc	ra,0xfffff
    800055dc:	be0080e7          	jalr	-1056(ra) # 800041b8 <nameiparent>
    800055e0:	892a                	mv	s2,a0
    800055e2:	12050e63          	beqz	a0,8000571e <create+0x162>
    return 0;

  ilock(dp);
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	42a080e7          	jalr	1066(ra) # 80003a10 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055ee:	4601                	li	a2,0
    800055f0:	fb040593          	addi	a1,s0,-80
    800055f4:	854a                	mv	a0,s2
    800055f6:	fffff097          	auipc	ra,0xfffff
    800055fa:	8d2080e7          	jalr	-1838(ra) # 80003ec8 <dirlookup>
    800055fe:	84aa                	mv	s1,a0
    80005600:	c921                	beqz	a0,80005650 <create+0x94>
    iunlockput(dp);
    80005602:	854a                	mv	a0,s2
    80005604:	ffffe097          	auipc	ra,0xffffe
    80005608:	64a080e7          	jalr	1610(ra) # 80003c4e <iunlockput>
    ilock(ip);
    8000560c:	8526                	mv	a0,s1
    8000560e:	ffffe097          	auipc	ra,0xffffe
    80005612:	402080e7          	jalr	1026(ra) # 80003a10 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005616:	2981                	sext.w	s3,s3
    80005618:	4789                	li	a5,2
    8000561a:	02f99463          	bne	s3,a5,80005642 <create+0x86>
    8000561e:	04c4d783          	lhu	a5,76(s1)
    80005622:	37f9                	addiw	a5,a5,-2
    80005624:	17c2                	slli	a5,a5,0x30
    80005626:	93c1                	srli	a5,a5,0x30
    80005628:	4705                	li	a4,1
    8000562a:	00f76c63          	bltu	a4,a5,80005642 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000562e:	8526                	mv	a0,s1
    80005630:	60a6                	ld	ra,72(sp)
    80005632:	6406                	ld	s0,64(sp)
    80005634:	74e2                	ld	s1,56(sp)
    80005636:	7942                	ld	s2,48(sp)
    80005638:	79a2                	ld	s3,40(sp)
    8000563a:	7a02                	ld	s4,32(sp)
    8000563c:	6ae2                	ld	s5,24(sp)
    8000563e:	6161                	addi	sp,sp,80
    80005640:	8082                	ret
    iunlockput(ip);
    80005642:	8526                	mv	a0,s1
    80005644:	ffffe097          	auipc	ra,0xffffe
    80005648:	60a080e7          	jalr	1546(ra) # 80003c4e <iunlockput>
    return 0;
    8000564c:	4481                	li	s1,0
    8000564e:	b7c5                	j	8000562e <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005650:	85ce                	mv	a1,s3
    80005652:	00092503          	lw	a0,0(s2)
    80005656:	ffffe097          	auipc	ra,0xffffe
    8000565a:	222080e7          	jalr	546(ra) # 80003878 <ialloc>
    8000565e:	84aa                	mv	s1,a0
    80005660:	c521                	beqz	a0,800056a8 <create+0xec>
  ilock(ip);
    80005662:	ffffe097          	auipc	ra,0xffffe
    80005666:	3ae080e7          	jalr	942(ra) # 80003a10 <ilock>
  ip->major = major;
    8000566a:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    8000566e:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    80005672:	4a05                	li	s4,1
    80005674:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    80005678:	8526                	mv	a0,s1
    8000567a:	ffffe097          	auipc	ra,0xffffe
    8000567e:	2cc080e7          	jalr	716(ra) # 80003946 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005682:	2981                	sext.w	s3,s3
    80005684:	03498a63          	beq	s3,s4,800056b8 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005688:	40d0                	lw	a2,4(s1)
    8000568a:	fb040593          	addi	a1,s0,-80
    8000568e:	854a                	mv	a0,s2
    80005690:	fffff097          	auipc	ra,0xfffff
    80005694:	a48080e7          	jalr	-1464(ra) # 800040d8 <dirlink>
    80005698:	06054b63          	bltz	a0,8000570e <create+0x152>
  iunlockput(dp);
    8000569c:	854a                	mv	a0,s2
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	5b0080e7          	jalr	1456(ra) # 80003c4e <iunlockput>
  return ip;
    800056a6:	b761                	j	8000562e <create+0x72>
    panic("create: ialloc");
    800056a8:	00003517          	auipc	a0,0x3
    800056ac:	38050513          	addi	a0,a0,896 # 80008a28 <userret+0x998>
    800056b0:	ffffb097          	auipc	ra,0xffffb
    800056b4:	e98080e7          	jalr	-360(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    800056b8:	05295783          	lhu	a5,82(s2)
    800056bc:	2785                	addiw	a5,a5,1
    800056be:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    800056c2:	854a                	mv	a0,s2
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	282080e7          	jalr	642(ra) # 80003946 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056cc:	40d0                	lw	a2,4(s1)
    800056ce:	00003597          	auipc	a1,0x3
    800056d2:	36a58593          	addi	a1,a1,874 # 80008a38 <userret+0x9a8>
    800056d6:	8526                	mv	a0,s1
    800056d8:	fffff097          	auipc	ra,0xfffff
    800056dc:	a00080e7          	jalr	-1536(ra) # 800040d8 <dirlink>
    800056e0:	00054f63          	bltz	a0,800056fe <create+0x142>
    800056e4:	00492603          	lw	a2,4(s2)
    800056e8:	00003597          	auipc	a1,0x3
    800056ec:	35858593          	addi	a1,a1,856 # 80008a40 <userret+0x9b0>
    800056f0:	8526                	mv	a0,s1
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	9e6080e7          	jalr	-1562(ra) # 800040d8 <dirlink>
    800056fa:	f80557e3          	bgez	a0,80005688 <create+0xcc>
      panic("create dots");
    800056fe:	00003517          	auipc	a0,0x3
    80005702:	34a50513          	addi	a0,a0,842 # 80008a48 <userret+0x9b8>
    80005706:	ffffb097          	auipc	ra,0xffffb
    8000570a:	e42080e7          	jalr	-446(ra) # 80000548 <panic>
    panic("create: dirlink");
    8000570e:	00003517          	auipc	a0,0x3
    80005712:	34a50513          	addi	a0,a0,842 # 80008a58 <userret+0x9c8>
    80005716:	ffffb097          	auipc	ra,0xffffb
    8000571a:	e32080e7          	jalr	-462(ra) # 80000548 <panic>
    return 0;
    8000571e:	84aa                	mv	s1,a0
    80005720:	b739                	j	8000562e <create+0x72>

0000000080005722 <sys_dup>:
{
    80005722:	7179                	addi	sp,sp,-48
    80005724:	f406                	sd	ra,40(sp)
    80005726:	f022                	sd	s0,32(sp)
    80005728:	ec26                	sd	s1,24(sp)
    8000572a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000572c:	fd840613          	addi	a2,s0,-40
    80005730:	4581                	li	a1,0
    80005732:	4501                	li	a0,0
    80005734:	00000097          	auipc	ra,0x0
    80005738:	dde080e7          	jalr	-546(ra) # 80005512 <argfd>
    return -1;
    8000573c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000573e:	02054363          	bltz	a0,80005764 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005742:	fd843503          	ld	a0,-40(s0)
    80005746:	00000097          	auipc	ra,0x0
    8000574a:	e34080e7          	jalr	-460(ra) # 8000557a <fdalloc>
    8000574e:	84aa                	mv	s1,a0
    return -1;
    80005750:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005752:	00054963          	bltz	a0,80005764 <sys_dup+0x42>
  filedup(f);
    80005756:	fd843503          	ld	a0,-40(s0)
    8000575a:	fffff097          	auipc	ra,0xfffff
    8000575e:	332080e7          	jalr	818(ra) # 80004a8c <filedup>
  return fd;
    80005762:	87a6                	mv	a5,s1
}
    80005764:	853e                	mv	a0,a5
    80005766:	70a2                	ld	ra,40(sp)
    80005768:	7402                	ld	s0,32(sp)
    8000576a:	64e2                	ld	s1,24(sp)
    8000576c:	6145                	addi	sp,sp,48
    8000576e:	8082                	ret

0000000080005770 <sys_read>:
{
    80005770:	7179                	addi	sp,sp,-48
    80005772:	f406                	sd	ra,40(sp)
    80005774:	f022                	sd	s0,32(sp)
    80005776:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005778:	fe840613          	addi	a2,s0,-24
    8000577c:	4581                	li	a1,0
    8000577e:	4501                	li	a0,0
    80005780:	00000097          	auipc	ra,0x0
    80005784:	d92080e7          	jalr	-622(ra) # 80005512 <argfd>
    return -1;
    80005788:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000578a:	04054163          	bltz	a0,800057cc <sys_read+0x5c>
    8000578e:	fe440593          	addi	a1,s0,-28
    80005792:	4509                	li	a0,2
    80005794:	ffffd097          	auipc	ra,0xffffd
    80005798:	708080e7          	jalr	1800(ra) # 80002e9c <argint>
    return -1;
    8000579c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000579e:	02054763          	bltz	a0,800057cc <sys_read+0x5c>
    800057a2:	fd840593          	addi	a1,s0,-40
    800057a6:	4505                	li	a0,1
    800057a8:	ffffd097          	auipc	ra,0xffffd
    800057ac:	716080e7          	jalr	1814(ra) # 80002ebe <argaddr>
    return -1;
    800057b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057b2:	00054d63          	bltz	a0,800057cc <sys_read+0x5c>
  return fileread(f, p, n);
    800057b6:	fe442603          	lw	a2,-28(s0)
    800057ba:	fd843583          	ld	a1,-40(s0)
    800057be:	fe843503          	ld	a0,-24(s0)
    800057c2:	fffff097          	auipc	ra,0xfffff
    800057c6:	45e080e7          	jalr	1118(ra) # 80004c20 <fileread>
    800057ca:	87aa                	mv	a5,a0
}
    800057cc:	853e                	mv	a0,a5
    800057ce:	70a2                	ld	ra,40(sp)
    800057d0:	7402                	ld	s0,32(sp)
    800057d2:	6145                	addi	sp,sp,48
    800057d4:	8082                	ret

00000000800057d6 <sys_write>:
{
    800057d6:	7179                	addi	sp,sp,-48
    800057d8:	f406                	sd	ra,40(sp)
    800057da:	f022                	sd	s0,32(sp)
    800057dc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057de:	fe840613          	addi	a2,s0,-24
    800057e2:	4581                	li	a1,0
    800057e4:	4501                	li	a0,0
    800057e6:	00000097          	auipc	ra,0x0
    800057ea:	d2c080e7          	jalr	-724(ra) # 80005512 <argfd>
    return -1;
    800057ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057f0:	04054163          	bltz	a0,80005832 <sys_write+0x5c>
    800057f4:	fe440593          	addi	a1,s0,-28
    800057f8:	4509                	li	a0,2
    800057fa:	ffffd097          	auipc	ra,0xffffd
    800057fe:	6a2080e7          	jalr	1698(ra) # 80002e9c <argint>
    return -1;
    80005802:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005804:	02054763          	bltz	a0,80005832 <sys_write+0x5c>
    80005808:	fd840593          	addi	a1,s0,-40
    8000580c:	4505                	li	a0,1
    8000580e:	ffffd097          	auipc	ra,0xffffd
    80005812:	6b0080e7          	jalr	1712(ra) # 80002ebe <argaddr>
    return -1;
    80005816:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005818:	00054d63          	bltz	a0,80005832 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000581c:	fe442603          	lw	a2,-28(s0)
    80005820:	fd843583          	ld	a1,-40(s0)
    80005824:	fe843503          	ld	a0,-24(s0)
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	4be080e7          	jalr	1214(ra) # 80004ce6 <filewrite>
    80005830:	87aa                	mv	a5,a0
}
    80005832:	853e                	mv	a0,a5
    80005834:	70a2                	ld	ra,40(sp)
    80005836:	7402                	ld	s0,32(sp)
    80005838:	6145                	addi	sp,sp,48
    8000583a:	8082                	ret

000000008000583c <sys_close>:
{
    8000583c:	1101                	addi	sp,sp,-32
    8000583e:	ec06                	sd	ra,24(sp)
    80005840:	e822                	sd	s0,16(sp)
    80005842:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005844:	fe040613          	addi	a2,s0,-32
    80005848:	fec40593          	addi	a1,s0,-20
    8000584c:	4501                	li	a0,0
    8000584e:	00000097          	auipc	ra,0x0
    80005852:	cc4080e7          	jalr	-828(ra) # 80005512 <argfd>
    return -1;
    80005856:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005858:	02054463          	bltz	a0,80005880 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000585c:	ffffc097          	auipc	ra,0xffffc
    80005860:	466080e7          	jalr	1126(ra) # 80001cc2 <myproc>
    80005864:	fec42783          	lw	a5,-20(s0)
    80005868:	07e9                	addi	a5,a5,26
    8000586a:	078e                	slli	a5,a5,0x3
    8000586c:	97aa                	add	a5,a5,a0
    8000586e:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005872:	fe043503          	ld	a0,-32(s0)
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	268080e7          	jalr	616(ra) # 80004ade <fileclose>
  return 0;
    8000587e:	4781                	li	a5,0
}
    80005880:	853e                	mv	a0,a5
    80005882:	60e2                	ld	ra,24(sp)
    80005884:	6442                	ld	s0,16(sp)
    80005886:	6105                	addi	sp,sp,32
    80005888:	8082                	ret

000000008000588a <sys_fstat>:
{
    8000588a:	1101                	addi	sp,sp,-32
    8000588c:	ec06                	sd	ra,24(sp)
    8000588e:	e822                	sd	s0,16(sp)
    80005890:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005892:	fe840613          	addi	a2,s0,-24
    80005896:	4581                	li	a1,0
    80005898:	4501                	li	a0,0
    8000589a:	00000097          	auipc	ra,0x0
    8000589e:	c78080e7          	jalr	-904(ra) # 80005512 <argfd>
    return -1;
    800058a2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058a4:	02054563          	bltz	a0,800058ce <sys_fstat+0x44>
    800058a8:	fe040593          	addi	a1,s0,-32
    800058ac:	4505                	li	a0,1
    800058ae:	ffffd097          	auipc	ra,0xffffd
    800058b2:	610080e7          	jalr	1552(ra) # 80002ebe <argaddr>
    return -1;
    800058b6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058b8:	00054b63          	bltz	a0,800058ce <sys_fstat+0x44>
  return filestat(f, st);
    800058bc:	fe043583          	ld	a1,-32(s0)
    800058c0:	fe843503          	ld	a0,-24(s0)
    800058c4:	fffff097          	auipc	ra,0xfffff
    800058c8:	2ea080e7          	jalr	746(ra) # 80004bae <filestat>
    800058cc:	87aa                	mv	a5,a0
}
    800058ce:	853e                	mv	a0,a5
    800058d0:	60e2                	ld	ra,24(sp)
    800058d2:	6442                	ld	s0,16(sp)
    800058d4:	6105                	addi	sp,sp,32
    800058d6:	8082                	ret

00000000800058d8 <sys_link>:
{
    800058d8:	7169                	addi	sp,sp,-304
    800058da:	f606                	sd	ra,296(sp)
    800058dc:	f222                	sd	s0,288(sp)
    800058de:	ee26                	sd	s1,280(sp)
    800058e0:	ea4a                	sd	s2,272(sp)
    800058e2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058e4:	08000613          	li	a2,128
    800058e8:	ed040593          	addi	a1,s0,-304
    800058ec:	4501                	li	a0,0
    800058ee:	ffffd097          	auipc	ra,0xffffd
    800058f2:	5f2080e7          	jalr	1522(ra) # 80002ee0 <argstr>
    return -1;
    800058f6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058f8:	12054363          	bltz	a0,80005a1e <sys_link+0x146>
    800058fc:	08000613          	li	a2,128
    80005900:	f5040593          	addi	a1,s0,-176
    80005904:	4505                	li	a0,1
    80005906:	ffffd097          	auipc	ra,0xffffd
    8000590a:	5da080e7          	jalr	1498(ra) # 80002ee0 <argstr>
    return -1;
    8000590e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005910:	10054763          	bltz	a0,80005a1e <sys_link+0x146>
  begin_op(ROOTDEV);
    80005914:	4501                	li	a0,0
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	ba0080e7          	jalr	-1120(ra) # 800044b6 <begin_op>
  if((ip = namei(old)) == 0){
    8000591e:	ed040513          	addi	a0,s0,-304
    80005922:	fffff097          	auipc	ra,0xfffff
    80005926:	878080e7          	jalr	-1928(ra) # 8000419a <namei>
    8000592a:	84aa                	mv	s1,a0
    8000592c:	c559                	beqz	a0,800059ba <sys_link+0xe2>
  ilock(ip);
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	0e2080e7          	jalr	226(ra) # 80003a10 <ilock>
  if(ip->type == T_DIR){
    80005936:	04c49703          	lh	a4,76(s1)
    8000593a:	4785                	li	a5,1
    8000593c:	08f70663          	beq	a4,a5,800059c8 <sys_link+0xf0>
  ip->nlink++;
    80005940:	0524d783          	lhu	a5,82(s1)
    80005944:	2785                	addiw	a5,a5,1
    80005946:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000594a:	8526                	mv	a0,s1
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	ffa080e7          	jalr	-6(ra) # 80003946 <iupdate>
  iunlock(ip);
    80005954:	8526                	mv	a0,s1
    80005956:	ffffe097          	auipc	ra,0xffffe
    8000595a:	17c080e7          	jalr	380(ra) # 80003ad2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000595e:	fd040593          	addi	a1,s0,-48
    80005962:	f5040513          	addi	a0,s0,-176
    80005966:	fffff097          	auipc	ra,0xfffff
    8000596a:	852080e7          	jalr	-1966(ra) # 800041b8 <nameiparent>
    8000596e:	892a                	mv	s2,a0
    80005970:	cd2d                	beqz	a0,800059ea <sys_link+0x112>
  ilock(dp);
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	09e080e7          	jalr	158(ra) # 80003a10 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000597a:	00092703          	lw	a4,0(s2)
    8000597e:	409c                	lw	a5,0(s1)
    80005980:	06f71063          	bne	a4,a5,800059e0 <sys_link+0x108>
    80005984:	40d0                	lw	a2,4(s1)
    80005986:	fd040593          	addi	a1,s0,-48
    8000598a:	854a                	mv	a0,s2
    8000598c:	ffffe097          	auipc	ra,0xffffe
    80005990:	74c080e7          	jalr	1868(ra) # 800040d8 <dirlink>
    80005994:	04054663          	bltz	a0,800059e0 <sys_link+0x108>
  iunlockput(dp);
    80005998:	854a                	mv	a0,s2
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	2b4080e7          	jalr	692(ra) # 80003c4e <iunlockput>
  iput(ip);
    800059a2:	8526                	mv	a0,s1
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	17a080e7          	jalr	378(ra) # 80003b1e <iput>
  end_op(ROOTDEV);
    800059ac:	4501                	li	a0,0
    800059ae:	fffff097          	auipc	ra,0xfffff
    800059b2:	bb2080e7          	jalr	-1102(ra) # 80004560 <end_op>
  return 0;
    800059b6:	4781                	li	a5,0
    800059b8:	a09d                	j	80005a1e <sys_link+0x146>
    end_op(ROOTDEV);
    800059ba:	4501                	li	a0,0
    800059bc:	fffff097          	auipc	ra,0xfffff
    800059c0:	ba4080e7          	jalr	-1116(ra) # 80004560 <end_op>
    return -1;
    800059c4:	57fd                	li	a5,-1
    800059c6:	a8a1                	j	80005a1e <sys_link+0x146>
    iunlockput(ip);
    800059c8:	8526                	mv	a0,s1
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	284080e7          	jalr	644(ra) # 80003c4e <iunlockput>
    end_op(ROOTDEV);
    800059d2:	4501                	li	a0,0
    800059d4:	fffff097          	auipc	ra,0xfffff
    800059d8:	b8c080e7          	jalr	-1140(ra) # 80004560 <end_op>
    return -1;
    800059dc:	57fd                	li	a5,-1
    800059de:	a081                	j	80005a1e <sys_link+0x146>
    iunlockput(dp);
    800059e0:	854a                	mv	a0,s2
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	26c080e7          	jalr	620(ra) # 80003c4e <iunlockput>
  ilock(ip);
    800059ea:	8526                	mv	a0,s1
    800059ec:	ffffe097          	auipc	ra,0xffffe
    800059f0:	024080e7          	jalr	36(ra) # 80003a10 <ilock>
  ip->nlink--;
    800059f4:	0524d783          	lhu	a5,82(s1)
    800059f8:	37fd                	addiw	a5,a5,-1
    800059fa:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800059fe:	8526                	mv	a0,s1
    80005a00:	ffffe097          	auipc	ra,0xffffe
    80005a04:	f46080e7          	jalr	-186(ra) # 80003946 <iupdate>
  iunlockput(ip);
    80005a08:	8526                	mv	a0,s1
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	244080e7          	jalr	580(ra) # 80003c4e <iunlockput>
  end_op(ROOTDEV);
    80005a12:	4501                	li	a0,0
    80005a14:	fffff097          	auipc	ra,0xfffff
    80005a18:	b4c080e7          	jalr	-1204(ra) # 80004560 <end_op>
  return -1;
    80005a1c:	57fd                	li	a5,-1
}
    80005a1e:	853e                	mv	a0,a5
    80005a20:	70b2                	ld	ra,296(sp)
    80005a22:	7412                	ld	s0,288(sp)
    80005a24:	64f2                	ld	s1,280(sp)
    80005a26:	6952                	ld	s2,272(sp)
    80005a28:	6155                	addi	sp,sp,304
    80005a2a:	8082                	ret

0000000080005a2c <sys_unlink>:
{
    80005a2c:	7151                	addi	sp,sp,-240
    80005a2e:	f586                	sd	ra,232(sp)
    80005a30:	f1a2                	sd	s0,224(sp)
    80005a32:	eda6                	sd	s1,216(sp)
    80005a34:	e9ca                	sd	s2,208(sp)
    80005a36:	e5ce                	sd	s3,200(sp)
    80005a38:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a3a:	08000613          	li	a2,128
    80005a3e:	f3040593          	addi	a1,s0,-208
    80005a42:	4501                	li	a0,0
    80005a44:	ffffd097          	auipc	ra,0xffffd
    80005a48:	49c080e7          	jalr	1180(ra) # 80002ee0 <argstr>
    80005a4c:	18054463          	bltz	a0,80005bd4 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    80005a50:	4501                	li	a0,0
    80005a52:	fffff097          	auipc	ra,0xfffff
    80005a56:	a64080e7          	jalr	-1436(ra) # 800044b6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a5a:	fb040593          	addi	a1,s0,-80
    80005a5e:	f3040513          	addi	a0,s0,-208
    80005a62:	ffffe097          	auipc	ra,0xffffe
    80005a66:	756080e7          	jalr	1878(ra) # 800041b8 <nameiparent>
    80005a6a:	84aa                	mv	s1,a0
    80005a6c:	cd61                	beqz	a0,80005b44 <sys_unlink+0x118>
  ilock(dp);
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	fa2080e7          	jalr	-94(ra) # 80003a10 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a76:	00003597          	auipc	a1,0x3
    80005a7a:	fc258593          	addi	a1,a1,-62 # 80008a38 <userret+0x9a8>
    80005a7e:	fb040513          	addi	a0,s0,-80
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	42c080e7          	jalr	1068(ra) # 80003eae <namecmp>
    80005a8a:	14050c63          	beqz	a0,80005be2 <sys_unlink+0x1b6>
    80005a8e:	00003597          	auipc	a1,0x3
    80005a92:	fb258593          	addi	a1,a1,-78 # 80008a40 <userret+0x9b0>
    80005a96:	fb040513          	addi	a0,s0,-80
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	414080e7          	jalr	1044(ra) # 80003eae <namecmp>
    80005aa2:	14050063          	beqz	a0,80005be2 <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005aa6:	f2c40613          	addi	a2,s0,-212
    80005aaa:	fb040593          	addi	a1,s0,-80
    80005aae:	8526                	mv	a0,s1
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	418080e7          	jalr	1048(ra) # 80003ec8 <dirlookup>
    80005ab8:	892a                	mv	s2,a0
    80005aba:	12050463          	beqz	a0,80005be2 <sys_unlink+0x1b6>
  ilock(ip);
    80005abe:	ffffe097          	auipc	ra,0xffffe
    80005ac2:	f52080e7          	jalr	-174(ra) # 80003a10 <ilock>
  if(ip->nlink < 1)
    80005ac6:	05291783          	lh	a5,82(s2)
    80005aca:	08f05463          	blez	a5,80005b52 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005ace:	04c91703          	lh	a4,76(s2)
    80005ad2:	4785                	li	a5,1
    80005ad4:	08f70763          	beq	a4,a5,80005b62 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005ad8:	4641                	li	a2,16
    80005ada:	4581                	li	a1,0
    80005adc:	fc040513          	addi	a0,s0,-64
    80005ae0:	ffffb097          	auipc	ra,0xffffb
    80005ae4:	426080e7          	jalr	1062(ra) # 80000f06 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ae8:	4741                	li	a4,16
    80005aea:	f2c42683          	lw	a3,-212(s0)
    80005aee:	fc040613          	addi	a2,s0,-64
    80005af2:	4581                	li	a1,0
    80005af4:	8526                	mv	a0,s1
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	29e080e7          	jalr	670(ra) # 80003d94 <writei>
    80005afe:	47c1                	li	a5,16
    80005b00:	0af51763          	bne	a0,a5,80005bae <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005b04:	04c91703          	lh	a4,76(s2)
    80005b08:	4785                	li	a5,1
    80005b0a:	0af70a63          	beq	a4,a5,80005bbe <sys_unlink+0x192>
  iunlockput(dp);
    80005b0e:	8526                	mv	a0,s1
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	13e080e7          	jalr	318(ra) # 80003c4e <iunlockput>
  ip->nlink--;
    80005b18:	05295783          	lhu	a5,82(s2)
    80005b1c:	37fd                	addiw	a5,a5,-1
    80005b1e:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    80005b22:	854a                	mv	a0,s2
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	e22080e7          	jalr	-478(ra) # 80003946 <iupdate>
  iunlockput(ip);
    80005b2c:	854a                	mv	a0,s2
    80005b2e:	ffffe097          	auipc	ra,0xffffe
    80005b32:	120080e7          	jalr	288(ra) # 80003c4e <iunlockput>
  end_op(ROOTDEV);
    80005b36:	4501                	li	a0,0
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	a28080e7          	jalr	-1496(ra) # 80004560 <end_op>
  return 0;
    80005b40:	4501                	li	a0,0
    80005b42:	a85d                	j	80005bf8 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    80005b44:	4501                	li	a0,0
    80005b46:	fffff097          	auipc	ra,0xfffff
    80005b4a:	a1a080e7          	jalr	-1510(ra) # 80004560 <end_op>
    return -1;
    80005b4e:	557d                	li	a0,-1
    80005b50:	a065                	j	80005bf8 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    80005b52:	00003517          	auipc	a0,0x3
    80005b56:	f1650513          	addi	a0,a0,-234 # 80008a68 <userret+0x9d8>
    80005b5a:	ffffb097          	auipc	ra,0xffffb
    80005b5e:	9ee080e7          	jalr	-1554(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b62:	05492703          	lw	a4,84(s2)
    80005b66:	02000793          	li	a5,32
    80005b6a:	f6e7f7e3          	bgeu	a5,a4,80005ad8 <sys_unlink+0xac>
    80005b6e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b72:	4741                	li	a4,16
    80005b74:	86ce                	mv	a3,s3
    80005b76:	f1840613          	addi	a2,s0,-232
    80005b7a:	4581                	li	a1,0
    80005b7c:	854a                	mv	a0,s2
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	122080e7          	jalr	290(ra) # 80003ca0 <readi>
    80005b86:	47c1                	li	a5,16
    80005b88:	00f51b63          	bne	a0,a5,80005b9e <sys_unlink+0x172>
    if(de.inum != 0)
    80005b8c:	f1845783          	lhu	a5,-232(s0)
    80005b90:	e7a1                	bnez	a5,80005bd8 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b92:	29c1                	addiw	s3,s3,16
    80005b94:	05492783          	lw	a5,84(s2)
    80005b98:	fcf9ede3          	bltu	s3,a5,80005b72 <sys_unlink+0x146>
    80005b9c:	bf35                	j	80005ad8 <sys_unlink+0xac>
      panic("isdirempty: readi");
    80005b9e:	00003517          	auipc	a0,0x3
    80005ba2:	ee250513          	addi	a0,a0,-286 # 80008a80 <userret+0x9f0>
    80005ba6:	ffffb097          	auipc	ra,0xffffb
    80005baa:	9a2080e7          	jalr	-1630(ra) # 80000548 <panic>
    panic("unlink: writei");
    80005bae:	00003517          	auipc	a0,0x3
    80005bb2:	eea50513          	addi	a0,a0,-278 # 80008a98 <userret+0xa08>
    80005bb6:	ffffb097          	auipc	ra,0xffffb
    80005bba:	992080e7          	jalr	-1646(ra) # 80000548 <panic>
    dp->nlink--;
    80005bbe:	0524d783          	lhu	a5,82(s1)
    80005bc2:	37fd                	addiw	a5,a5,-1
    80005bc4:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005bc8:	8526                	mv	a0,s1
    80005bca:	ffffe097          	auipc	ra,0xffffe
    80005bce:	d7c080e7          	jalr	-644(ra) # 80003946 <iupdate>
    80005bd2:	bf35                	j	80005b0e <sys_unlink+0xe2>
    return -1;
    80005bd4:	557d                	li	a0,-1
    80005bd6:	a00d                	j	80005bf8 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005bd8:	854a                	mv	a0,s2
    80005bda:	ffffe097          	auipc	ra,0xffffe
    80005bde:	074080e7          	jalr	116(ra) # 80003c4e <iunlockput>
  iunlockput(dp);
    80005be2:	8526                	mv	a0,s1
    80005be4:	ffffe097          	auipc	ra,0xffffe
    80005be8:	06a080e7          	jalr	106(ra) # 80003c4e <iunlockput>
  end_op(ROOTDEV);
    80005bec:	4501                	li	a0,0
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	972080e7          	jalr	-1678(ra) # 80004560 <end_op>
  return -1;
    80005bf6:	557d                	li	a0,-1
}
    80005bf8:	70ae                	ld	ra,232(sp)
    80005bfa:	740e                	ld	s0,224(sp)
    80005bfc:	64ee                	ld	s1,216(sp)
    80005bfe:	694e                	ld	s2,208(sp)
    80005c00:	69ae                	ld	s3,200(sp)
    80005c02:	616d                	addi	sp,sp,240
    80005c04:	8082                	ret

0000000080005c06 <sys_open>:

uint64
sys_open(void)
{
    80005c06:	7131                	addi	sp,sp,-192
    80005c08:	fd06                	sd	ra,184(sp)
    80005c0a:	f922                	sd	s0,176(sp)
    80005c0c:	f526                	sd	s1,168(sp)
    80005c0e:	f14a                	sd	s2,160(sp)
    80005c10:	ed4e                	sd	s3,152(sp)
    80005c12:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c14:	08000613          	li	a2,128
    80005c18:	f5040593          	addi	a1,s0,-176
    80005c1c:	4501                	li	a0,0
    80005c1e:	ffffd097          	auipc	ra,0xffffd
    80005c22:	2c2080e7          	jalr	706(ra) # 80002ee0 <argstr>
    return -1;
    80005c26:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c28:	0a054963          	bltz	a0,80005cda <sys_open+0xd4>
    80005c2c:	f4c40593          	addi	a1,s0,-180
    80005c30:	4505                	li	a0,1
    80005c32:	ffffd097          	auipc	ra,0xffffd
    80005c36:	26a080e7          	jalr	618(ra) # 80002e9c <argint>
    80005c3a:	0a054063          	bltz	a0,80005cda <sys_open+0xd4>

  begin_op(ROOTDEV);
    80005c3e:	4501                	li	a0,0
    80005c40:	fffff097          	auipc	ra,0xfffff
    80005c44:	876080e7          	jalr	-1930(ra) # 800044b6 <begin_op>

  if(omode & O_CREATE){
    80005c48:	f4c42783          	lw	a5,-180(s0)
    80005c4c:	2007f793          	andi	a5,a5,512
    80005c50:	c3dd                	beqz	a5,80005cf6 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    80005c52:	4681                	li	a3,0
    80005c54:	4601                	li	a2,0
    80005c56:	4589                	li	a1,2
    80005c58:	f5040513          	addi	a0,s0,-176
    80005c5c:	00000097          	auipc	ra,0x0
    80005c60:	960080e7          	jalr	-1696(ra) # 800055bc <create>
    80005c64:	892a                	mv	s2,a0
    if(ip == 0){
    80005c66:	c151                	beqz	a0,80005cea <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c68:	04c91703          	lh	a4,76(s2)
    80005c6c:	478d                	li	a5,3
    80005c6e:	00f71763          	bne	a4,a5,80005c7c <sys_open+0x76>
    80005c72:	04e95703          	lhu	a4,78(s2)
    80005c76:	47a5                	li	a5,9
    80005c78:	0ce7e663          	bltu	a5,a4,80005d44 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c7c:	fffff097          	auipc	ra,0xfffff
    80005c80:	da6080e7          	jalr	-602(ra) # 80004a22 <filealloc>
    80005c84:	89aa                	mv	s3,a0
    80005c86:	c97d                	beqz	a0,80005d7c <sys_open+0x176>
    80005c88:	00000097          	auipc	ra,0x0
    80005c8c:	8f2080e7          	jalr	-1806(ra) # 8000557a <fdalloc>
    80005c90:	84aa                	mv	s1,a0
    80005c92:	0e054063          	bltz	a0,80005d72 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c96:	04c91703          	lh	a4,76(s2)
    80005c9a:	478d                	li	a5,3
    80005c9c:	0cf70063          	beq	a4,a5,80005d5c <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005ca0:	4789                	li	a5,2
    80005ca2:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005ca6:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005caa:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005cae:	f4c42783          	lw	a5,-180(s0)
    80005cb2:	0017c713          	xori	a4,a5,1
    80005cb6:	8b05                	andi	a4,a4,1
    80005cb8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005cbc:	8b8d                	andi	a5,a5,3
    80005cbe:	00f037b3          	snez	a5,a5
    80005cc2:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005cc6:	854a                	mv	a0,s2
    80005cc8:	ffffe097          	auipc	ra,0xffffe
    80005ccc:	e0a080e7          	jalr	-502(ra) # 80003ad2 <iunlock>
  end_op(ROOTDEV);
    80005cd0:	4501                	li	a0,0
    80005cd2:	fffff097          	auipc	ra,0xfffff
    80005cd6:	88e080e7          	jalr	-1906(ra) # 80004560 <end_op>

  return fd;
}
    80005cda:	8526                	mv	a0,s1
    80005cdc:	70ea                	ld	ra,184(sp)
    80005cde:	744a                	ld	s0,176(sp)
    80005ce0:	74aa                	ld	s1,168(sp)
    80005ce2:	790a                	ld	s2,160(sp)
    80005ce4:	69ea                	ld	s3,152(sp)
    80005ce6:	6129                	addi	sp,sp,192
    80005ce8:	8082                	ret
      end_op(ROOTDEV);
    80005cea:	4501                	li	a0,0
    80005cec:	fffff097          	auipc	ra,0xfffff
    80005cf0:	874080e7          	jalr	-1932(ra) # 80004560 <end_op>
      return -1;
    80005cf4:	b7dd                	j	80005cda <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005cf6:	f5040513          	addi	a0,s0,-176
    80005cfa:	ffffe097          	auipc	ra,0xffffe
    80005cfe:	4a0080e7          	jalr	1184(ra) # 8000419a <namei>
    80005d02:	892a                	mv	s2,a0
    80005d04:	c90d                	beqz	a0,80005d36 <sys_open+0x130>
    ilock(ip);
    80005d06:	ffffe097          	auipc	ra,0xffffe
    80005d0a:	d0a080e7          	jalr	-758(ra) # 80003a10 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d0e:	04c91703          	lh	a4,76(s2)
    80005d12:	4785                	li	a5,1
    80005d14:	f4f71ae3          	bne	a4,a5,80005c68 <sys_open+0x62>
    80005d18:	f4c42783          	lw	a5,-180(s0)
    80005d1c:	d3a5                	beqz	a5,80005c7c <sys_open+0x76>
      iunlockput(ip);
    80005d1e:	854a                	mv	a0,s2
    80005d20:	ffffe097          	auipc	ra,0xffffe
    80005d24:	f2e080e7          	jalr	-210(ra) # 80003c4e <iunlockput>
      end_op(ROOTDEV);
    80005d28:	4501                	li	a0,0
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	836080e7          	jalr	-1994(ra) # 80004560 <end_op>
      return -1;
    80005d32:	54fd                	li	s1,-1
    80005d34:	b75d                	j	80005cda <sys_open+0xd4>
      end_op(ROOTDEV);
    80005d36:	4501                	li	a0,0
    80005d38:	fffff097          	auipc	ra,0xfffff
    80005d3c:	828080e7          	jalr	-2008(ra) # 80004560 <end_op>
      return -1;
    80005d40:	54fd                	li	s1,-1
    80005d42:	bf61                	j	80005cda <sys_open+0xd4>
    iunlockput(ip);
    80005d44:	854a                	mv	a0,s2
    80005d46:	ffffe097          	auipc	ra,0xffffe
    80005d4a:	f08080e7          	jalr	-248(ra) # 80003c4e <iunlockput>
    end_op(ROOTDEV);
    80005d4e:	4501                	li	a0,0
    80005d50:	fffff097          	auipc	ra,0xfffff
    80005d54:	810080e7          	jalr	-2032(ra) # 80004560 <end_op>
    return -1;
    80005d58:	54fd                	li	s1,-1
    80005d5a:	b741                	j	80005cda <sys_open+0xd4>
    f->type = FD_DEVICE;
    80005d5c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d60:	04e91783          	lh	a5,78(s2)
    80005d64:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005d68:	05091783          	lh	a5,80(s2)
    80005d6c:	02f99323          	sh	a5,38(s3)
    80005d70:	bf1d                	j	80005ca6 <sys_open+0xa0>
      fileclose(f);
    80005d72:	854e                	mv	a0,s3
    80005d74:	fffff097          	auipc	ra,0xfffff
    80005d78:	d6a080e7          	jalr	-662(ra) # 80004ade <fileclose>
    iunlockput(ip);
    80005d7c:	854a                	mv	a0,s2
    80005d7e:	ffffe097          	auipc	ra,0xffffe
    80005d82:	ed0080e7          	jalr	-304(ra) # 80003c4e <iunlockput>
    end_op(ROOTDEV);
    80005d86:	4501                	li	a0,0
    80005d88:	ffffe097          	auipc	ra,0xffffe
    80005d8c:	7d8080e7          	jalr	2008(ra) # 80004560 <end_op>
    return -1;
    80005d90:	54fd                	li	s1,-1
    80005d92:	b7a1                	j	80005cda <sys_open+0xd4>

0000000080005d94 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d94:	7175                	addi	sp,sp,-144
    80005d96:	e506                	sd	ra,136(sp)
    80005d98:	e122                	sd	s0,128(sp)
    80005d9a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005d9c:	4501                	li	a0,0
    80005d9e:	ffffe097          	auipc	ra,0xffffe
    80005da2:	718080e7          	jalr	1816(ra) # 800044b6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005da6:	08000613          	li	a2,128
    80005daa:	f7040593          	addi	a1,s0,-144
    80005dae:	4501                	li	a0,0
    80005db0:	ffffd097          	auipc	ra,0xffffd
    80005db4:	130080e7          	jalr	304(ra) # 80002ee0 <argstr>
    80005db8:	02054a63          	bltz	a0,80005dec <sys_mkdir+0x58>
    80005dbc:	4681                	li	a3,0
    80005dbe:	4601                	li	a2,0
    80005dc0:	4585                	li	a1,1
    80005dc2:	f7040513          	addi	a0,s0,-144
    80005dc6:	fffff097          	auipc	ra,0xfffff
    80005dca:	7f6080e7          	jalr	2038(ra) # 800055bc <create>
    80005dce:	cd19                	beqz	a0,80005dec <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005dd0:	ffffe097          	auipc	ra,0xffffe
    80005dd4:	e7e080e7          	jalr	-386(ra) # 80003c4e <iunlockput>
  end_op(ROOTDEV);
    80005dd8:	4501                	li	a0,0
    80005dda:	ffffe097          	auipc	ra,0xffffe
    80005dde:	786080e7          	jalr	1926(ra) # 80004560 <end_op>
  return 0;
    80005de2:	4501                	li	a0,0
}
    80005de4:	60aa                	ld	ra,136(sp)
    80005de6:	640a                	ld	s0,128(sp)
    80005de8:	6149                	addi	sp,sp,144
    80005dea:	8082                	ret
    end_op(ROOTDEV);
    80005dec:	4501                	li	a0,0
    80005dee:	ffffe097          	auipc	ra,0xffffe
    80005df2:	772080e7          	jalr	1906(ra) # 80004560 <end_op>
    return -1;
    80005df6:	557d                	li	a0,-1
    80005df8:	b7f5                	j	80005de4 <sys_mkdir+0x50>

0000000080005dfa <sys_mknod>:

uint64
sys_mknod(void)
{
    80005dfa:	7135                	addi	sp,sp,-160
    80005dfc:	ed06                	sd	ra,152(sp)
    80005dfe:	e922                	sd	s0,144(sp)
    80005e00:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005e02:	4501                	li	a0,0
    80005e04:	ffffe097          	auipc	ra,0xffffe
    80005e08:	6b2080e7          	jalr	1714(ra) # 800044b6 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e0c:	08000613          	li	a2,128
    80005e10:	f7040593          	addi	a1,s0,-144
    80005e14:	4501                	li	a0,0
    80005e16:	ffffd097          	auipc	ra,0xffffd
    80005e1a:	0ca080e7          	jalr	202(ra) # 80002ee0 <argstr>
    80005e1e:	04054b63          	bltz	a0,80005e74 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80005e22:	f6c40593          	addi	a1,s0,-148
    80005e26:	4505                	li	a0,1
    80005e28:	ffffd097          	auipc	ra,0xffffd
    80005e2c:	074080e7          	jalr	116(ra) # 80002e9c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e30:	04054263          	bltz	a0,80005e74 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005e34:	f6840593          	addi	a1,s0,-152
    80005e38:	4509                	li	a0,2
    80005e3a:	ffffd097          	auipc	ra,0xffffd
    80005e3e:	062080e7          	jalr	98(ra) # 80002e9c <argint>
     argint(1, &major) < 0 ||
    80005e42:	02054963          	bltz	a0,80005e74 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e46:	f6841683          	lh	a3,-152(s0)
    80005e4a:	f6c41603          	lh	a2,-148(s0)
    80005e4e:	458d                	li	a1,3
    80005e50:	f7040513          	addi	a0,s0,-144
    80005e54:	fffff097          	auipc	ra,0xfffff
    80005e58:	768080e7          	jalr	1896(ra) # 800055bc <create>
     argint(2, &minor) < 0 ||
    80005e5c:	cd01                	beqz	a0,80005e74 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005e5e:	ffffe097          	auipc	ra,0xffffe
    80005e62:	df0080e7          	jalr	-528(ra) # 80003c4e <iunlockput>
  end_op(ROOTDEV);
    80005e66:	4501                	li	a0,0
    80005e68:	ffffe097          	auipc	ra,0xffffe
    80005e6c:	6f8080e7          	jalr	1784(ra) # 80004560 <end_op>
  return 0;
    80005e70:	4501                	li	a0,0
    80005e72:	a039                	j	80005e80 <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005e74:	4501                	li	a0,0
    80005e76:	ffffe097          	auipc	ra,0xffffe
    80005e7a:	6ea080e7          	jalr	1770(ra) # 80004560 <end_op>
    return -1;
    80005e7e:	557d                	li	a0,-1
}
    80005e80:	60ea                	ld	ra,152(sp)
    80005e82:	644a                	ld	s0,144(sp)
    80005e84:	610d                	addi	sp,sp,160
    80005e86:	8082                	ret

0000000080005e88 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e88:	7135                	addi	sp,sp,-160
    80005e8a:	ed06                	sd	ra,152(sp)
    80005e8c:	e922                	sd	s0,144(sp)
    80005e8e:	e526                	sd	s1,136(sp)
    80005e90:	e14a                	sd	s2,128(sp)
    80005e92:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e94:	ffffc097          	auipc	ra,0xffffc
    80005e98:	e2e080e7          	jalr	-466(ra) # 80001cc2 <myproc>
    80005e9c:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005e9e:	4501                	li	a0,0
    80005ea0:	ffffe097          	auipc	ra,0xffffe
    80005ea4:	616080e7          	jalr	1558(ra) # 800044b6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ea8:	08000613          	li	a2,128
    80005eac:	f6040593          	addi	a1,s0,-160
    80005eb0:	4501                	li	a0,0
    80005eb2:	ffffd097          	auipc	ra,0xffffd
    80005eb6:	02e080e7          	jalr	46(ra) # 80002ee0 <argstr>
    80005eba:	04054c63          	bltz	a0,80005f12 <sys_chdir+0x8a>
    80005ebe:	f6040513          	addi	a0,s0,-160
    80005ec2:	ffffe097          	auipc	ra,0xffffe
    80005ec6:	2d8080e7          	jalr	728(ra) # 8000419a <namei>
    80005eca:	84aa                	mv	s1,a0
    80005ecc:	c139                	beqz	a0,80005f12 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005ece:	ffffe097          	auipc	ra,0xffffe
    80005ed2:	b42080e7          	jalr	-1214(ra) # 80003a10 <ilock>
  if(ip->type != T_DIR){
    80005ed6:	04c49703          	lh	a4,76(s1)
    80005eda:	4785                	li	a5,1
    80005edc:	04f71263          	bne	a4,a5,80005f20 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005ee0:	8526                	mv	a0,s1
    80005ee2:	ffffe097          	auipc	ra,0xffffe
    80005ee6:	bf0080e7          	jalr	-1040(ra) # 80003ad2 <iunlock>
  iput(p->cwd);
    80005eea:	15893503          	ld	a0,344(s2)
    80005eee:	ffffe097          	auipc	ra,0xffffe
    80005ef2:	c30080e7          	jalr	-976(ra) # 80003b1e <iput>
  end_op(ROOTDEV);
    80005ef6:	4501                	li	a0,0
    80005ef8:	ffffe097          	auipc	ra,0xffffe
    80005efc:	668080e7          	jalr	1640(ra) # 80004560 <end_op>
  p->cwd = ip;
    80005f00:	14993c23          	sd	s1,344(s2)
  return 0;
    80005f04:	4501                	li	a0,0
}
    80005f06:	60ea                	ld	ra,152(sp)
    80005f08:	644a                	ld	s0,144(sp)
    80005f0a:	64aa                	ld	s1,136(sp)
    80005f0c:	690a                	ld	s2,128(sp)
    80005f0e:	610d                	addi	sp,sp,160
    80005f10:	8082                	ret
    end_op(ROOTDEV);
    80005f12:	4501                	li	a0,0
    80005f14:	ffffe097          	auipc	ra,0xffffe
    80005f18:	64c080e7          	jalr	1612(ra) # 80004560 <end_op>
    return -1;
    80005f1c:	557d                	li	a0,-1
    80005f1e:	b7e5                	j	80005f06 <sys_chdir+0x7e>
    iunlockput(ip);
    80005f20:	8526                	mv	a0,s1
    80005f22:	ffffe097          	auipc	ra,0xffffe
    80005f26:	d2c080e7          	jalr	-724(ra) # 80003c4e <iunlockput>
    end_op(ROOTDEV);
    80005f2a:	4501                	li	a0,0
    80005f2c:	ffffe097          	auipc	ra,0xffffe
    80005f30:	634080e7          	jalr	1588(ra) # 80004560 <end_op>
    return -1;
    80005f34:	557d                	li	a0,-1
    80005f36:	bfc1                	j	80005f06 <sys_chdir+0x7e>

0000000080005f38 <sys_exec>:

uint64
sys_exec(void)
{
    80005f38:	7145                	addi	sp,sp,-464
    80005f3a:	e786                	sd	ra,456(sp)
    80005f3c:	e3a2                	sd	s0,448(sp)
    80005f3e:	ff26                	sd	s1,440(sp)
    80005f40:	fb4a                	sd	s2,432(sp)
    80005f42:	f74e                	sd	s3,424(sp)
    80005f44:	f352                	sd	s4,416(sp)
    80005f46:	ef56                	sd	s5,408(sp)
    80005f48:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f4a:	08000613          	li	a2,128
    80005f4e:	f4040593          	addi	a1,s0,-192
    80005f52:	4501                	li	a0,0
    80005f54:	ffffd097          	auipc	ra,0xffffd
    80005f58:	f8c080e7          	jalr	-116(ra) # 80002ee0 <argstr>
    80005f5c:	0e054663          	bltz	a0,80006048 <sys_exec+0x110>
    80005f60:	e3840593          	addi	a1,s0,-456
    80005f64:	4505                	li	a0,1
    80005f66:	ffffd097          	auipc	ra,0xffffd
    80005f6a:	f58080e7          	jalr	-168(ra) # 80002ebe <argaddr>
    80005f6e:	0e054763          	bltz	a0,8000605c <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005f72:	10000613          	li	a2,256
    80005f76:	4581                	li	a1,0
    80005f78:	e4040513          	addi	a0,s0,-448
    80005f7c:	ffffb097          	auipc	ra,0xffffb
    80005f80:	f8a080e7          	jalr	-118(ra) # 80000f06 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f84:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f88:	89ca                	mv	s3,s2
    80005f8a:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005f8c:	02000a13          	li	s4,32
    80005f90:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f94:	00349793          	slli	a5,s1,0x3
    80005f98:	e3040593          	addi	a1,s0,-464
    80005f9c:	e3843503          	ld	a0,-456(s0)
    80005fa0:	953e                	add	a0,a0,a5
    80005fa2:	ffffd097          	auipc	ra,0xffffd
    80005fa6:	e60080e7          	jalr	-416(ra) # 80002e02 <fetchaddr>
    80005faa:	02054a63          	bltz	a0,80005fde <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005fae:	e3043783          	ld	a5,-464(s0)
    80005fb2:	c7a1                	beqz	a5,80005ffa <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005fb4:	ffffb097          	auipc	ra,0xffffb
    80005fb8:	b0a080e7          	jalr	-1270(ra) # 80000abe <kalloc>
    80005fbc:	85aa                	mv	a1,a0
    80005fbe:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005fc2:	c92d                	beqz	a0,80006034 <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005fc4:	6605                	lui	a2,0x1
    80005fc6:	e3043503          	ld	a0,-464(s0)
    80005fca:	ffffd097          	auipc	ra,0xffffd
    80005fce:	e8a080e7          	jalr	-374(ra) # 80002e54 <fetchstr>
    80005fd2:	00054663          	bltz	a0,80005fde <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005fd6:	0485                	addi	s1,s1,1
    80005fd8:	09a1                	addi	s3,s3,8
    80005fda:	fb449be3          	bne	s1,s4,80005f90 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fde:	10090493          	addi	s1,s2,256
    80005fe2:	00093503          	ld	a0,0(s2)
    80005fe6:	cd39                	beqz	a0,80006044 <sys_exec+0x10c>
    kfree(argv[i]);
    80005fe8:	ffffb097          	auipc	ra,0xffffb
    80005fec:	968080e7          	jalr	-1688(ra) # 80000950 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ff0:	0921                	addi	s2,s2,8
    80005ff2:	fe9918e3          	bne	s2,s1,80005fe2 <sys_exec+0xaa>
  return -1;
    80005ff6:	557d                	li	a0,-1
    80005ff8:	a889                	j	8000604a <sys_exec+0x112>
      argv[i] = 0;
    80005ffa:	0a8e                	slli	s5,s5,0x3
    80005ffc:	fc040793          	addi	a5,s0,-64
    80006000:	9abe                	add	s5,s5,a5
    80006002:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006006:	e4040593          	addi	a1,s0,-448
    8000600a:	f4040513          	addi	a0,s0,-192
    8000600e:	fffff097          	auipc	ra,0xfffff
    80006012:	178080e7          	jalr	376(ra) # 80005186 <exec>
    80006016:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006018:	10090993          	addi	s3,s2,256
    8000601c:	00093503          	ld	a0,0(s2)
    80006020:	c901                	beqz	a0,80006030 <sys_exec+0xf8>
    kfree(argv[i]);
    80006022:	ffffb097          	auipc	ra,0xffffb
    80006026:	92e080e7          	jalr	-1746(ra) # 80000950 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000602a:	0921                	addi	s2,s2,8
    8000602c:	ff3918e3          	bne	s2,s3,8000601c <sys_exec+0xe4>
  return ret;
    80006030:	8526                	mv	a0,s1
    80006032:	a821                	j	8000604a <sys_exec+0x112>
      panic("sys_exec kalloc");
    80006034:	00003517          	auipc	a0,0x3
    80006038:	a7450513          	addi	a0,a0,-1420 # 80008aa8 <userret+0xa18>
    8000603c:	ffffa097          	auipc	ra,0xffffa
    80006040:	50c080e7          	jalr	1292(ra) # 80000548 <panic>
  return -1;
    80006044:	557d                	li	a0,-1
    80006046:	a011                	j	8000604a <sys_exec+0x112>
    return -1;
    80006048:	557d                	li	a0,-1
}
    8000604a:	60be                	ld	ra,456(sp)
    8000604c:	641e                	ld	s0,448(sp)
    8000604e:	74fa                	ld	s1,440(sp)
    80006050:	795a                	ld	s2,432(sp)
    80006052:	79ba                	ld	s3,424(sp)
    80006054:	7a1a                	ld	s4,416(sp)
    80006056:	6afa                	ld	s5,408(sp)
    80006058:	6179                	addi	sp,sp,464
    8000605a:	8082                	ret
    return -1;
    8000605c:	557d                	li	a0,-1
    8000605e:	b7f5                	j	8000604a <sys_exec+0x112>

0000000080006060 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006060:	7139                	addi	sp,sp,-64
    80006062:	fc06                	sd	ra,56(sp)
    80006064:	f822                	sd	s0,48(sp)
    80006066:	f426                	sd	s1,40(sp)
    80006068:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000606a:	ffffc097          	auipc	ra,0xffffc
    8000606e:	c58080e7          	jalr	-936(ra) # 80001cc2 <myproc>
    80006072:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006074:	fd840593          	addi	a1,s0,-40
    80006078:	4501                	li	a0,0
    8000607a:	ffffd097          	auipc	ra,0xffffd
    8000607e:	e44080e7          	jalr	-444(ra) # 80002ebe <argaddr>
    return -1;
    80006082:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006084:	0e054063          	bltz	a0,80006164 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006088:	fc840593          	addi	a1,s0,-56
    8000608c:	fd040513          	addi	a0,s0,-48
    80006090:	fffff097          	auipc	ra,0xfffff
    80006094:	db2080e7          	jalr	-590(ra) # 80004e42 <pipealloc>
    return -1;
    80006098:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000609a:	0c054563          	bltz	a0,80006164 <sys_pipe+0x104>
  fd0 = -1;
    8000609e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800060a2:	fd043503          	ld	a0,-48(s0)
    800060a6:	fffff097          	auipc	ra,0xfffff
    800060aa:	4d4080e7          	jalr	1236(ra) # 8000557a <fdalloc>
    800060ae:	fca42223          	sw	a0,-60(s0)
    800060b2:	08054c63          	bltz	a0,8000614a <sys_pipe+0xea>
    800060b6:	fc843503          	ld	a0,-56(s0)
    800060ba:	fffff097          	auipc	ra,0xfffff
    800060be:	4c0080e7          	jalr	1216(ra) # 8000557a <fdalloc>
    800060c2:	fca42023          	sw	a0,-64(s0)
    800060c6:	06054863          	bltz	a0,80006136 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060ca:	4691                	li	a3,4
    800060cc:	fc440613          	addi	a2,s0,-60
    800060d0:	fd843583          	ld	a1,-40(s0)
    800060d4:	6ca8                	ld	a0,88(s1)
    800060d6:	ffffc097          	auipc	ra,0xffffc
    800060da:	81e080e7          	jalr	-2018(ra) # 800018f4 <copyout>
    800060de:	02054063          	bltz	a0,800060fe <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800060e2:	4691                	li	a3,4
    800060e4:	fc040613          	addi	a2,s0,-64
    800060e8:	fd843583          	ld	a1,-40(s0)
    800060ec:	0591                	addi	a1,a1,4
    800060ee:	6ca8                	ld	a0,88(s1)
    800060f0:	ffffc097          	auipc	ra,0xffffc
    800060f4:	804080e7          	jalr	-2044(ra) # 800018f4 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800060f8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060fa:	06055563          	bgez	a0,80006164 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800060fe:	fc442783          	lw	a5,-60(s0)
    80006102:	07e9                	addi	a5,a5,26
    80006104:	078e                	slli	a5,a5,0x3
    80006106:	97a6                	add	a5,a5,s1
    80006108:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    8000610c:	fc042503          	lw	a0,-64(s0)
    80006110:	0569                	addi	a0,a0,26
    80006112:	050e                	slli	a0,a0,0x3
    80006114:	9526                	add	a0,a0,s1
    80006116:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    8000611a:	fd043503          	ld	a0,-48(s0)
    8000611e:	fffff097          	auipc	ra,0xfffff
    80006122:	9c0080e7          	jalr	-1600(ra) # 80004ade <fileclose>
    fileclose(wf);
    80006126:	fc843503          	ld	a0,-56(s0)
    8000612a:	fffff097          	auipc	ra,0xfffff
    8000612e:	9b4080e7          	jalr	-1612(ra) # 80004ade <fileclose>
    return -1;
    80006132:	57fd                	li	a5,-1
    80006134:	a805                	j	80006164 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006136:	fc442783          	lw	a5,-60(s0)
    8000613a:	0007c863          	bltz	a5,8000614a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    8000613e:	01a78513          	addi	a0,a5,26
    80006142:	050e                	slli	a0,a0,0x3
    80006144:	9526                	add	a0,a0,s1
    80006146:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    8000614a:	fd043503          	ld	a0,-48(s0)
    8000614e:	fffff097          	auipc	ra,0xfffff
    80006152:	990080e7          	jalr	-1648(ra) # 80004ade <fileclose>
    fileclose(wf);
    80006156:	fc843503          	ld	a0,-56(s0)
    8000615a:	fffff097          	auipc	ra,0xfffff
    8000615e:	984080e7          	jalr	-1660(ra) # 80004ade <fileclose>
    return -1;
    80006162:	57fd                	li	a5,-1
}
    80006164:	853e                	mv	a0,a5
    80006166:	70e2                	ld	ra,56(sp)
    80006168:	7442                	ld	s0,48(sp)
    8000616a:	74a2                	ld	s1,40(sp)
    8000616c:	6121                	addi	sp,sp,64
    8000616e:	8082                	ret

0000000080006170 <sys_crash>:

// system call to test crashes
uint64
sys_crash(void)
{
    80006170:	7171                	addi	sp,sp,-176
    80006172:	f506                	sd	ra,168(sp)
    80006174:	f122                	sd	s0,160(sp)
    80006176:	ed26                	sd	s1,152(sp)
    80006178:	1900                	addi	s0,sp,176
  char path[MAXPATH];
  struct inode *ip;
  int crash;
  
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    8000617a:	08000613          	li	a2,128
    8000617e:	f6040593          	addi	a1,s0,-160
    80006182:	4501                	li	a0,0
    80006184:	ffffd097          	auipc	ra,0xffffd
    80006188:	d5c080e7          	jalr	-676(ra) # 80002ee0 <argstr>
    return -1;
    8000618c:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    8000618e:	04054363          	bltz	a0,800061d4 <sys_crash+0x64>
    80006192:	f5c40593          	addi	a1,s0,-164
    80006196:	4505                	li	a0,1
    80006198:	ffffd097          	auipc	ra,0xffffd
    8000619c:	d04080e7          	jalr	-764(ra) # 80002e9c <argint>
    return -1;
    800061a0:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    800061a2:	02054963          	bltz	a0,800061d4 <sys_crash+0x64>
  ip = create(path, T_FILE, 0, 0);
    800061a6:	4681                	li	a3,0
    800061a8:	4601                	li	a2,0
    800061aa:	4589                	li	a1,2
    800061ac:	f6040513          	addi	a0,s0,-160
    800061b0:	fffff097          	auipc	ra,0xfffff
    800061b4:	40c080e7          	jalr	1036(ra) # 800055bc <create>
    800061b8:	84aa                	mv	s1,a0
  if(ip == 0){
    800061ba:	c11d                	beqz	a0,800061e0 <sys_crash+0x70>
    return -1;
  }
  iunlockput(ip);
    800061bc:	ffffe097          	auipc	ra,0xffffe
    800061c0:	a92080e7          	jalr	-1390(ra) # 80003c4e <iunlockput>
  crash_op(ip->dev, crash);
    800061c4:	f5c42583          	lw	a1,-164(s0)
    800061c8:	4088                	lw	a0,0(s1)
    800061ca:	ffffe097          	auipc	ra,0xffffe
    800061ce:	5e8080e7          	jalr	1512(ra) # 800047b2 <crash_op>
  return 0;
    800061d2:	4781                	li	a5,0
}
    800061d4:	853e                	mv	a0,a5
    800061d6:	70aa                	ld	ra,168(sp)
    800061d8:	740a                	ld	s0,160(sp)
    800061da:	64ea                	ld	s1,152(sp)
    800061dc:	614d                	addi	sp,sp,176
    800061de:	8082                	ret
    return -1;
    800061e0:	57fd                	li	a5,-1
    800061e2:	bfcd                	j	800061d4 <sys_crash+0x64>
	...

00000000800061f0 <kernelvec>:
    800061f0:	7111                	addi	sp,sp,-256
    800061f2:	e006                	sd	ra,0(sp)
    800061f4:	e40a                	sd	sp,8(sp)
    800061f6:	e80e                	sd	gp,16(sp)
    800061f8:	ec12                	sd	tp,24(sp)
    800061fa:	f016                	sd	t0,32(sp)
    800061fc:	f41a                	sd	t1,40(sp)
    800061fe:	f81e                	sd	t2,48(sp)
    80006200:	fc22                	sd	s0,56(sp)
    80006202:	e0a6                	sd	s1,64(sp)
    80006204:	e4aa                	sd	a0,72(sp)
    80006206:	e8ae                	sd	a1,80(sp)
    80006208:	ecb2                	sd	a2,88(sp)
    8000620a:	f0b6                	sd	a3,96(sp)
    8000620c:	f4ba                	sd	a4,104(sp)
    8000620e:	f8be                	sd	a5,112(sp)
    80006210:	fcc2                	sd	a6,120(sp)
    80006212:	e146                	sd	a7,128(sp)
    80006214:	e54a                	sd	s2,136(sp)
    80006216:	e94e                	sd	s3,144(sp)
    80006218:	ed52                	sd	s4,152(sp)
    8000621a:	f156                	sd	s5,160(sp)
    8000621c:	f55a                	sd	s6,168(sp)
    8000621e:	f95e                	sd	s7,176(sp)
    80006220:	fd62                	sd	s8,184(sp)
    80006222:	e1e6                	sd	s9,192(sp)
    80006224:	e5ea                	sd	s10,200(sp)
    80006226:	e9ee                	sd	s11,208(sp)
    80006228:	edf2                	sd	t3,216(sp)
    8000622a:	f1f6                	sd	t4,224(sp)
    8000622c:	f5fa                	sd	t5,232(sp)
    8000622e:	f9fe                	sd	t6,240(sp)
    80006230:	a9ffc0ef          	jal	ra,80002cce <kerneltrap>
    80006234:	6082                	ld	ra,0(sp)
    80006236:	6122                	ld	sp,8(sp)
    80006238:	61c2                	ld	gp,16(sp)
    8000623a:	7282                	ld	t0,32(sp)
    8000623c:	7322                	ld	t1,40(sp)
    8000623e:	73c2                	ld	t2,48(sp)
    80006240:	7462                	ld	s0,56(sp)
    80006242:	6486                	ld	s1,64(sp)
    80006244:	6526                	ld	a0,72(sp)
    80006246:	65c6                	ld	a1,80(sp)
    80006248:	6666                	ld	a2,88(sp)
    8000624a:	7686                	ld	a3,96(sp)
    8000624c:	7726                	ld	a4,104(sp)
    8000624e:	77c6                	ld	a5,112(sp)
    80006250:	7866                	ld	a6,120(sp)
    80006252:	688a                	ld	a7,128(sp)
    80006254:	692a                	ld	s2,136(sp)
    80006256:	69ca                	ld	s3,144(sp)
    80006258:	6a6a                	ld	s4,152(sp)
    8000625a:	7a8a                	ld	s5,160(sp)
    8000625c:	7b2a                	ld	s6,168(sp)
    8000625e:	7bca                	ld	s7,176(sp)
    80006260:	7c6a                	ld	s8,184(sp)
    80006262:	6c8e                	ld	s9,192(sp)
    80006264:	6d2e                	ld	s10,200(sp)
    80006266:	6dce                	ld	s11,208(sp)
    80006268:	6e6e                	ld	t3,216(sp)
    8000626a:	7e8e                	ld	t4,224(sp)
    8000626c:	7f2e                	ld	t5,232(sp)
    8000626e:	7fce                	ld	t6,240(sp)
    80006270:	6111                	addi	sp,sp,256
    80006272:	10200073          	sret
    80006276:	00000013          	nop
    8000627a:	00000013          	nop
    8000627e:	0001                	nop

0000000080006280 <timervec>:
    80006280:	34051573          	csrrw	a0,mscratch,a0
    80006284:	e10c                	sd	a1,0(a0)
    80006286:	e510                	sd	a2,8(a0)
    80006288:	e914                	sd	a3,16(a0)
    8000628a:	710c                	ld	a1,32(a0)
    8000628c:	7510                	ld	a2,40(a0)
    8000628e:	6194                	ld	a3,0(a1)
    80006290:	96b2                	add	a3,a3,a2
    80006292:	e194                	sd	a3,0(a1)
    80006294:	4589                	li	a1,2
    80006296:	14459073          	csrw	sip,a1
    8000629a:	6914                	ld	a3,16(a0)
    8000629c:	6510                	ld	a2,8(a0)
    8000629e:	610c                	ld	a1,0(a0)
    800062a0:	34051573          	csrrw	a0,mscratch,a0
    800062a4:	30200073          	mret
	...

00000000800062aa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800062aa:	1141                	addi	sp,sp,-16
    800062ac:	e422                	sd	s0,8(sp)
    800062ae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800062b0:	0c0007b7          	lui	a5,0xc000
    800062b4:	4705                	li	a4,1
    800062b6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800062b8:	c3d8                	sw	a4,4(a5)
}
    800062ba:	6422                	ld	s0,8(sp)
    800062bc:	0141                	addi	sp,sp,16
    800062be:	8082                	ret

00000000800062c0 <plicinithart>:

void
plicinithart(void)
{
    800062c0:	1141                	addi	sp,sp,-16
    800062c2:	e406                	sd	ra,8(sp)
    800062c4:	e022                	sd	s0,0(sp)
    800062c6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062c8:	ffffc097          	auipc	ra,0xffffc
    800062cc:	9ce080e7          	jalr	-1586(ra) # 80001c96 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800062d0:	0085171b          	slliw	a4,a0,0x8
    800062d4:	0c0027b7          	lui	a5,0xc002
    800062d8:	97ba                	add	a5,a5,a4
    800062da:	40200713          	li	a4,1026
    800062de:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800062e2:	00d5151b          	slliw	a0,a0,0xd
    800062e6:	0c2017b7          	lui	a5,0xc201
    800062ea:	953e                	add	a0,a0,a5
    800062ec:	00052023          	sw	zero,0(a0)
}
    800062f0:	60a2                	ld	ra,8(sp)
    800062f2:	6402                	ld	s0,0(sp)
    800062f4:	0141                	addi	sp,sp,16
    800062f6:	8082                	ret

00000000800062f8 <plic_pending>:

// return a bitmap of which IRQs are waiting
// to be served.
uint64
plic_pending(void)
{
    800062f8:	1141                	addi	sp,sp,-16
    800062fa:	e422                	sd	s0,8(sp)
    800062fc:	0800                	addi	s0,sp,16
  //mask = *(uint32*)(PLIC + 0x1000);
  //mask |= (uint64)*(uint32*)(PLIC + 0x1004) << 32;
  mask = *(uint64*)PLIC_PENDING;

  return mask;
}
    800062fe:	0c0017b7          	lui	a5,0xc001
    80006302:	6388                	ld	a0,0(a5)
    80006304:	6422                	ld	s0,8(sp)
    80006306:	0141                	addi	sp,sp,16
    80006308:	8082                	ret

000000008000630a <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000630a:	1141                	addi	sp,sp,-16
    8000630c:	e406                	sd	ra,8(sp)
    8000630e:	e022                	sd	s0,0(sp)
    80006310:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006312:	ffffc097          	auipc	ra,0xffffc
    80006316:	984080e7          	jalr	-1660(ra) # 80001c96 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    8000631a:	00d5179b          	slliw	a5,a0,0xd
    8000631e:	0c201537          	lui	a0,0xc201
    80006322:	953e                	add	a0,a0,a5
  return irq;
}
    80006324:	4148                	lw	a0,4(a0)
    80006326:	60a2                	ld	ra,8(sp)
    80006328:	6402                	ld	s0,0(sp)
    8000632a:	0141                	addi	sp,sp,16
    8000632c:	8082                	ret

000000008000632e <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000632e:	1101                	addi	sp,sp,-32
    80006330:	ec06                	sd	ra,24(sp)
    80006332:	e822                	sd	s0,16(sp)
    80006334:	e426                	sd	s1,8(sp)
    80006336:	1000                	addi	s0,sp,32
    80006338:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000633a:	ffffc097          	auipc	ra,0xffffc
    8000633e:	95c080e7          	jalr	-1700(ra) # 80001c96 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006342:	00d5151b          	slliw	a0,a0,0xd
    80006346:	0c2017b7          	lui	a5,0xc201
    8000634a:	97aa                	add	a5,a5,a0
    8000634c:	c3c4                	sw	s1,4(a5)
}
    8000634e:	60e2                	ld	ra,24(sp)
    80006350:	6442                	ld	s0,16(sp)
    80006352:	64a2                	ld	s1,8(sp)
    80006354:	6105                	addi	sp,sp,32
    80006356:	8082                	ret

0000000080006358 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80006358:	1141                	addi	sp,sp,-16
    8000635a:	e406                	sd	ra,8(sp)
    8000635c:	e022                	sd	s0,0(sp)
    8000635e:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006360:	479d                	li	a5,7
    80006362:	06b7c963          	blt	a5,a1,800063d4 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80006366:	00151793          	slli	a5,a0,0x1
    8000636a:	97aa                	add	a5,a5,a0
    8000636c:	00c79713          	slli	a4,a5,0xc
    80006370:	00028797          	auipc	a5,0x28
    80006374:	c9078793          	addi	a5,a5,-880 # 8002e000 <disk>
    80006378:	97ba                	add	a5,a5,a4
    8000637a:	97ae                	add	a5,a5,a1
    8000637c:	6709                	lui	a4,0x2
    8000637e:	97ba                	add	a5,a5,a4
    80006380:	0187c783          	lbu	a5,24(a5)
    80006384:	e3a5                	bnez	a5,800063e4 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80006386:	00028817          	auipc	a6,0x28
    8000638a:	c7a80813          	addi	a6,a6,-902 # 8002e000 <disk>
    8000638e:	00151693          	slli	a3,a0,0x1
    80006392:	00a68733          	add	a4,a3,a0
    80006396:	0732                	slli	a4,a4,0xc
    80006398:	00e807b3          	add	a5,a6,a4
    8000639c:	6709                	lui	a4,0x2
    8000639e:	00f70633          	add	a2,a4,a5
    800063a2:	6210                	ld	a2,0(a2)
    800063a4:	00459893          	slli	a7,a1,0x4
    800063a8:	9646                	add	a2,a2,a7
    800063aa:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    800063ae:	97ae                	add	a5,a5,a1
    800063b0:	97ba                	add	a5,a5,a4
    800063b2:	4605                	li	a2,1
    800063b4:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    800063b8:	96aa                	add	a3,a3,a0
    800063ba:	06b2                	slli	a3,a3,0xc
    800063bc:	0761                	addi	a4,a4,24
    800063be:	96ba                	add	a3,a3,a4
    800063c0:	00d80533          	add	a0,a6,a3
    800063c4:	ffffc097          	auipc	ra,0xffffc
    800063c8:	254080e7          	jalr	596(ra) # 80002618 <wakeup>
}
    800063cc:	60a2                	ld	ra,8(sp)
    800063ce:	6402                	ld	s0,0(sp)
    800063d0:	0141                	addi	sp,sp,16
    800063d2:	8082                	ret
    panic("virtio_disk_intr 1");
    800063d4:	00002517          	auipc	a0,0x2
    800063d8:	6e450513          	addi	a0,a0,1764 # 80008ab8 <userret+0xa28>
    800063dc:	ffffa097          	auipc	ra,0xffffa
    800063e0:	16c080e7          	jalr	364(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    800063e4:	00002517          	auipc	a0,0x2
    800063e8:	6ec50513          	addi	a0,a0,1772 # 80008ad0 <userret+0xa40>
    800063ec:	ffffa097          	auipc	ra,0xffffa
    800063f0:	15c080e7          	jalr	348(ra) # 80000548 <panic>

00000000800063f4 <virtio_disk_init>:
  __sync_synchronize();
    800063f4:	0ff0000f          	fence
  if(disk[n].init)
    800063f8:	00151793          	slli	a5,a0,0x1
    800063fc:	97aa                	add	a5,a5,a0
    800063fe:	07b2                	slli	a5,a5,0xc
    80006400:	00028717          	auipc	a4,0x28
    80006404:	c0070713          	addi	a4,a4,-1024 # 8002e000 <disk>
    80006408:	973e                	add	a4,a4,a5
    8000640a:	6789                	lui	a5,0x2
    8000640c:	97ba                	add	a5,a5,a4
    8000640e:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80006412:	c391                	beqz	a5,80006416 <virtio_disk_init+0x22>
    80006414:	8082                	ret
{
    80006416:	7139                	addi	sp,sp,-64
    80006418:	fc06                	sd	ra,56(sp)
    8000641a:	f822                	sd	s0,48(sp)
    8000641c:	f426                	sd	s1,40(sp)
    8000641e:	f04a                	sd	s2,32(sp)
    80006420:	ec4e                	sd	s3,24(sp)
    80006422:	e852                	sd	s4,16(sp)
    80006424:	e456                	sd	s5,8(sp)
    80006426:	0080                	addi	s0,sp,64
    80006428:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    8000642a:	85aa                	mv	a1,a0
    8000642c:	00002517          	auipc	a0,0x2
    80006430:	6bc50513          	addi	a0,a0,1724 # 80008ae8 <userret+0xa58>
    80006434:	ffffa097          	auipc	ra,0xffffa
    80006438:	16e080e7          	jalr	366(ra) # 800005a2 <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    8000643c:	00149993          	slli	s3,s1,0x1
    80006440:	99a6                	add	s3,s3,s1
    80006442:	09b2                	slli	s3,s3,0xc
    80006444:	6789                	lui	a5,0x2
    80006446:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    8000644a:	97ce                	add	a5,a5,s3
    8000644c:	00002597          	auipc	a1,0x2
    80006450:	6b458593          	addi	a1,a1,1716 # 80008b00 <userret+0xa70>
    80006454:	00028517          	auipc	a0,0x28
    80006458:	bac50513          	addi	a0,a0,-1108 # 8002e000 <disk>
    8000645c:	953e                	add	a0,a0,a5
    8000645e:	ffffa097          	auipc	ra,0xffffa
    80006462:	6f0080e7          	jalr	1776(ra) # 80000b4e <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006466:	0014891b          	addiw	s2,s1,1
    8000646a:	00c9191b          	slliw	s2,s2,0xc
    8000646e:	100007b7          	lui	a5,0x10000
    80006472:	97ca                	add	a5,a5,s2
    80006474:	4398                	lw	a4,0(a5)
    80006476:	2701                	sext.w	a4,a4
    80006478:	747277b7          	lui	a5,0x74727
    8000647c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006480:	12f71663          	bne	a4,a5,800065ac <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006484:	100007b7          	lui	a5,0x10000
    80006488:	0791                	addi	a5,a5,4
    8000648a:	97ca                	add	a5,a5,s2
    8000648c:	439c                	lw	a5,0(a5)
    8000648e:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006490:	4705                	li	a4,1
    80006492:	10e79d63          	bne	a5,a4,800065ac <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006496:	100007b7          	lui	a5,0x10000
    8000649a:	07a1                	addi	a5,a5,8
    8000649c:	97ca                	add	a5,a5,s2
    8000649e:	439c                	lw	a5,0(a5)
    800064a0:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    800064a2:	4709                	li	a4,2
    800064a4:	10e79463          	bne	a5,a4,800065ac <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800064a8:	100007b7          	lui	a5,0x10000
    800064ac:	07b1                	addi	a5,a5,12
    800064ae:	97ca                	add	a5,a5,s2
    800064b0:	4398                	lw	a4,0(a5)
    800064b2:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064b4:	554d47b7          	lui	a5,0x554d4
    800064b8:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800064bc:	0ef71863          	bne	a4,a5,800065ac <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800064c0:	100007b7          	lui	a5,0x10000
    800064c4:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    800064c8:	96ca                	add	a3,a3,s2
    800064ca:	4705                	li	a4,1
    800064cc:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800064ce:	470d                	li	a4,3
    800064d0:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    800064d2:	01078713          	addi	a4,a5,16
    800064d6:	974a                	add	a4,a4,s2
    800064d8:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800064da:	02078613          	addi	a2,a5,32
    800064de:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800064e0:	c7ffe737          	lui	a4,0xc7ffe
    800064e4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fca703>
    800064e8:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800064ea:	2701                	sext.w	a4,a4
    800064ec:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800064ee:	472d                	li	a4,11
    800064f0:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800064f2:	473d                	li	a4,15
    800064f4:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800064f6:	02878713          	addi	a4,a5,40
    800064fa:	974a                	add	a4,a4,s2
    800064fc:	6685                	lui	a3,0x1
    800064fe:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006500:	03078713          	addi	a4,a5,48
    80006504:	974a                	add	a4,a4,s2
    80006506:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000650a:	03478793          	addi	a5,a5,52
    8000650e:	97ca                	add	a5,a5,s2
    80006510:	439c                	lw	a5,0(a5)
    80006512:	2781                	sext.w	a5,a5
  if(max == 0)
    80006514:	c7c5                	beqz	a5,800065bc <virtio_disk_init+0x1c8>
  if(max < NUM)
    80006516:	471d                	li	a4,7
    80006518:	0af77a63          	bgeu	a4,a5,800065cc <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000651c:	10000ab7          	lui	s5,0x10000
    80006520:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80006524:	97ca                	add	a5,a5,s2
    80006526:	4721                	li	a4,8
    80006528:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    8000652a:	00028a17          	auipc	s4,0x28
    8000652e:	ad6a0a13          	addi	s4,s4,-1322 # 8002e000 <disk>
    80006532:	99d2                	add	s3,s3,s4
    80006534:	6609                	lui	a2,0x2
    80006536:	4581                	li	a1,0
    80006538:	854e                	mv	a0,s3
    8000653a:	ffffb097          	auipc	ra,0xffffb
    8000653e:	9cc080e7          	jalr	-1588(ra) # 80000f06 <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    80006542:	040a8a93          	addi	s5,s5,64
    80006546:	9956                	add	s2,s2,s5
    80006548:	00c9d793          	srli	a5,s3,0xc
    8000654c:	2781                	sext.w	a5,a5
    8000654e:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80006552:	00149693          	slli	a3,s1,0x1
    80006556:	009687b3          	add	a5,a3,s1
    8000655a:	07b2                	slli	a5,a5,0xc
    8000655c:	97d2                	add	a5,a5,s4
    8000655e:	6609                	lui	a2,0x2
    80006560:	97b2                	add	a5,a5,a2
    80006562:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006566:	08098713          	addi	a4,s3,128
    8000656a:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    8000656c:	6705                	lui	a4,0x1
    8000656e:	99ba                	add	s3,s3,a4
    80006570:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80006574:	4705                	li	a4,1
    80006576:	00e78c23          	sb	a4,24(a5)
    8000657a:	00e78ca3          	sb	a4,25(a5)
    8000657e:	00e78d23          	sb	a4,26(a5)
    80006582:	00e78da3          	sb	a4,27(a5)
    80006586:	00e78e23          	sb	a4,28(a5)
    8000658a:	00e78ea3          	sb	a4,29(a5)
    8000658e:	00e78f23          	sb	a4,30(a5)
    80006592:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80006596:	0ae7a423          	sw	a4,168(a5)
}
    8000659a:	70e2                	ld	ra,56(sp)
    8000659c:	7442                	ld	s0,48(sp)
    8000659e:	74a2                	ld	s1,40(sp)
    800065a0:	7902                	ld	s2,32(sp)
    800065a2:	69e2                	ld	s3,24(sp)
    800065a4:	6a42                	ld	s4,16(sp)
    800065a6:	6aa2                	ld	s5,8(sp)
    800065a8:	6121                	addi	sp,sp,64
    800065aa:	8082                	ret
    panic("could not find virtio disk");
    800065ac:	00002517          	auipc	a0,0x2
    800065b0:	56450513          	addi	a0,a0,1380 # 80008b10 <userret+0xa80>
    800065b4:	ffffa097          	auipc	ra,0xffffa
    800065b8:	f94080e7          	jalr	-108(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    800065bc:	00002517          	auipc	a0,0x2
    800065c0:	57450513          	addi	a0,a0,1396 # 80008b30 <userret+0xaa0>
    800065c4:	ffffa097          	auipc	ra,0xffffa
    800065c8:	f84080e7          	jalr	-124(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    800065cc:	00002517          	auipc	a0,0x2
    800065d0:	58450513          	addi	a0,a0,1412 # 80008b50 <userret+0xac0>
    800065d4:	ffffa097          	auipc	ra,0xffffa
    800065d8:	f74080e7          	jalr	-140(ra) # 80000548 <panic>

00000000800065dc <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    800065dc:	7135                	addi	sp,sp,-160
    800065de:	ed06                	sd	ra,152(sp)
    800065e0:	e922                	sd	s0,144(sp)
    800065e2:	e526                	sd	s1,136(sp)
    800065e4:	e14a                	sd	s2,128(sp)
    800065e6:	fcce                	sd	s3,120(sp)
    800065e8:	f8d2                	sd	s4,112(sp)
    800065ea:	f4d6                	sd	s5,104(sp)
    800065ec:	f0da                	sd	s6,96(sp)
    800065ee:	ecde                	sd	s7,88(sp)
    800065f0:	e8e2                	sd	s8,80(sp)
    800065f2:	e4e6                	sd	s9,72(sp)
    800065f4:	e0ea                	sd	s10,64(sp)
    800065f6:	fc6e                	sd	s11,56(sp)
    800065f8:	1100                	addi	s0,sp,160
    800065fa:	8aaa                	mv	s5,a0
    800065fc:	8c2e                	mv	s8,a1
    800065fe:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80006600:	45dc                	lw	a5,12(a1)
    80006602:	0017979b          	slliw	a5,a5,0x1
    80006606:	1782                	slli	a5,a5,0x20
    80006608:	9381                	srli	a5,a5,0x20
    8000660a:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    8000660e:	00151493          	slli	s1,a0,0x1
    80006612:	94aa                	add	s1,s1,a0
    80006614:	04b2                	slli	s1,s1,0xc
    80006616:	6909                	lui	s2,0x2
    80006618:	0b090c93          	addi	s9,s2,176 # 20b0 <_entry-0x7fffdf50>
    8000661c:	9ca6                	add	s9,s9,s1
    8000661e:	00028997          	auipc	s3,0x28
    80006622:	9e298993          	addi	s3,s3,-1566 # 8002e000 <disk>
    80006626:	9cce                	add	s9,s9,s3
    80006628:	8566                	mv	a0,s9
    8000662a:	ffffa097          	auipc	ra,0xffffa
    8000662e:	672080e7          	jalr	1650(ra) # 80000c9c <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006632:	0961                	addi	s2,s2,24
    80006634:	94ca                	add	s1,s1,s2
    80006636:	99a6                	add	s3,s3,s1
  for(int i = 0; i < 3; i++){
    80006638:	4a01                	li	s4,0
  for(int i = 0; i < NUM; i++){
    8000663a:	44a1                	li	s1,8
      disk[n].free[i] = 0;
    8000663c:	001a9793          	slli	a5,s5,0x1
    80006640:	97d6                	add	a5,a5,s5
    80006642:	07b2                	slli	a5,a5,0xc
    80006644:	00028b97          	auipc	s7,0x28
    80006648:	9bcb8b93          	addi	s7,s7,-1604 # 8002e000 <disk>
    8000664c:	9bbe                	add	s7,s7,a5
    8000664e:	a8a9                	j	800066a8 <virtio_disk_rw+0xcc>
    80006650:	00fb8733          	add	a4,s7,a5
    80006654:	9742                	add	a4,a4,a6
    80006656:	00070c23          	sb	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    idx[i] = alloc_desc(n);
    8000665a:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000665c:	0207c263          	bltz	a5,80006680 <virtio_disk_rw+0xa4>
  for(int i = 0; i < 3; i++){
    80006660:	2905                	addiw	s2,s2,1
    80006662:	0611                	addi	a2,a2,4
    80006664:	1ca90463          	beq	s2,a0,8000682c <virtio_disk_rw+0x250>
    idx[i] = alloc_desc(n);
    80006668:	85b2                	mv	a1,a2
    8000666a:	874e                	mv	a4,s3
  for(int i = 0; i < NUM; i++){
    8000666c:	87d2                	mv	a5,s4
    if(disk[n].free[i]){
    8000666e:	00074683          	lbu	a3,0(a4)
    80006672:	fef9                	bnez	a3,80006650 <virtio_disk_rw+0x74>
  for(int i = 0; i < NUM; i++){
    80006674:	2785                	addiw	a5,a5,1
    80006676:	0705                	addi	a4,a4,1
    80006678:	fe979be3          	bne	a5,s1,8000666e <virtio_disk_rw+0x92>
    idx[i] = alloc_desc(n);
    8000667c:	57fd                	li	a5,-1
    8000667e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006680:	01205e63          	blez	s2,8000669c <virtio_disk_rw+0xc0>
    80006684:	8d52                	mv	s10,s4
        free_desc(n, idx[j]);
    80006686:	000b2583          	lw	a1,0(s6)
    8000668a:	8556                	mv	a0,s5
    8000668c:	00000097          	auipc	ra,0x0
    80006690:	ccc080e7          	jalr	-820(ra) # 80006358 <free_desc>
      for(int j = 0; j < i; j++)
    80006694:	2d05                	addiw	s10,s10,1
    80006696:	0b11                	addi	s6,s6,4
    80006698:	ffa917e3          	bne	s2,s10,80006686 <virtio_disk_rw+0xaa>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    8000669c:	85e6                	mv	a1,s9
    8000669e:	854e                	mv	a0,s3
    800066a0:	ffffc097          	auipc	ra,0xffffc
    800066a4:	df8080e7          	jalr	-520(ra) # 80002498 <sleep>
  for(int i = 0; i < 3; i++){
    800066a8:	f8040b13          	addi	s6,s0,-128
{
    800066ac:	865a                	mv	a2,s6
  for(int i = 0; i < 3; i++){
    800066ae:	8952                	mv	s2,s4
      disk[n].free[i] = 0;
    800066b0:	6809                	lui	a6,0x2
  for(int i = 0; i < 3; i++){
    800066b2:	450d                	li	a0,3
    800066b4:	bf55                	j	80006668 <virtio_disk_rw+0x8c>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    800066b6:	001a9793          	slli	a5,s5,0x1
    800066ba:	97d6                	add	a5,a5,s5
    800066bc:	07b2                	slli	a5,a5,0xc
    800066be:	00028717          	auipc	a4,0x28
    800066c2:	94270713          	addi	a4,a4,-1726 # 8002e000 <disk>
    800066c6:	973e                	add	a4,a4,a5
    800066c8:	6789                	lui	a5,0x2
    800066ca:	97ba                	add	a5,a5,a4
    800066cc:	639c                	ld	a5,0(a5)
    800066ce:	97b6                	add	a5,a5,a3
    800066d0:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800066d4:	00028517          	auipc	a0,0x28
    800066d8:	92c50513          	addi	a0,a0,-1748 # 8002e000 <disk>
    800066dc:	001a9793          	slli	a5,s5,0x1
    800066e0:	01578733          	add	a4,a5,s5
    800066e4:	0732                	slli	a4,a4,0xc
    800066e6:	972a                	add	a4,a4,a0
    800066e8:	6609                	lui	a2,0x2
    800066ea:	9732                	add	a4,a4,a2
    800066ec:	6310                	ld	a2,0(a4)
    800066ee:	9636                	add	a2,a2,a3
    800066f0:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800066f4:	0015e593          	ori	a1,a1,1
    800066f8:	00b61623          	sh	a1,12(a2)
  disk[n].desc[idx[1]].next = idx[2];
    800066fc:	f8842603          	lw	a2,-120(s0)
    80006700:	630c                	ld	a1,0(a4)
    80006702:	96ae                	add	a3,a3,a1
    80006704:	00c69723          	sh	a2,14(a3) # 100e <_entry-0x7fffeff2>

  disk[n].info[idx[0]].status = 0;
    80006708:	97d6                	add	a5,a5,s5
    8000670a:	07a2                	slli	a5,a5,0x8
    8000670c:	97a6                	add	a5,a5,s1
    8000670e:	20078793          	addi	a5,a5,512
    80006712:	0792                	slli	a5,a5,0x4
    80006714:	97aa                	add	a5,a5,a0
    80006716:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    8000671a:	00461693          	slli	a3,a2,0x4
    8000671e:	00073803          	ld	a6,0(a4)
    80006722:	9836                	add	a6,a6,a3
    80006724:	20348613          	addi	a2,s1,515
    80006728:	001a9593          	slli	a1,s5,0x1
    8000672c:	95d6                	add	a1,a1,s5
    8000672e:	05a2                	slli	a1,a1,0x8
    80006730:	962e                	add	a2,a2,a1
    80006732:	0612                	slli	a2,a2,0x4
    80006734:	962a                	add	a2,a2,a0
    80006736:	00c83023          	sd	a2,0(a6) # 2000 <_entry-0x7fffe000>
  disk[n].desc[idx[2]].len = 1;
    8000673a:	630c                	ld	a1,0(a4)
    8000673c:	95b6                	add	a1,a1,a3
    8000673e:	4605                	li	a2,1
    80006740:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006742:	630c                	ld	a1,0(a4)
    80006744:	95b6                	add	a1,a1,a3
    80006746:	4509                	li	a0,2
    80006748:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    8000674c:	630c                	ld	a1,0(a4)
    8000674e:	96ae                	add	a3,a3,a1
    80006750:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006754:	00cc2223          	sw	a2,4(s8) # fffffffffffff004 <end+0xffffffff7ffcafa8>
  disk[n].info[idx[0]].b = b;
    80006758:	0387b423          	sd	s8,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    8000675c:	6714                	ld	a3,8(a4)
    8000675e:	0026d783          	lhu	a5,2(a3)
    80006762:	8b9d                	andi	a5,a5,7
    80006764:	0789                	addi	a5,a5,2
    80006766:	0786                	slli	a5,a5,0x1
    80006768:	97b6                	add	a5,a5,a3
    8000676a:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    8000676e:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006772:	6718                	ld	a4,8(a4)
    80006774:	00275783          	lhu	a5,2(a4)
    80006778:	2785                	addiw	a5,a5,1
    8000677a:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000677e:	001a879b          	addiw	a5,s5,1
    80006782:	00c7979b          	slliw	a5,a5,0xc
    80006786:	10000737          	lui	a4,0x10000
    8000678a:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    8000678e:	97ba                	add	a5,a5,a4
    80006790:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006794:	004c2783          	lw	a5,4(s8)
    80006798:	00c79d63          	bne	a5,a2,800067b2 <virtio_disk_rw+0x1d6>
    8000679c:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    8000679e:	85e6                	mv	a1,s9
    800067a0:	8562                	mv	a0,s8
    800067a2:	ffffc097          	auipc	ra,0xffffc
    800067a6:	cf6080e7          	jalr	-778(ra) # 80002498 <sleep>
  while(b->disk == 1) {
    800067aa:	004c2783          	lw	a5,4(s8)
    800067ae:	fe9788e3          	beq	a5,s1,8000679e <virtio_disk_rw+0x1c2>
  }

  disk[n].info[idx[0]].b = 0;
    800067b2:	f8042483          	lw	s1,-128(s0)
    800067b6:	001a9793          	slli	a5,s5,0x1
    800067ba:	97d6                	add	a5,a5,s5
    800067bc:	07a2                	slli	a5,a5,0x8
    800067be:	97a6                	add	a5,a5,s1
    800067c0:	20078793          	addi	a5,a5,512
    800067c4:	0792                	slli	a5,a5,0x4
    800067c6:	00028717          	auipc	a4,0x28
    800067ca:	83a70713          	addi	a4,a4,-1990 # 8002e000 <disk>
    800067ce:	97ba                	add	a5,a5,a4
    800067d0:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800067d4:	001a9793          	slli	a5,s5,0x1
    800067d8:	97d6                	add	a5,a5,s5
    800067da:	07b2                	slli	a5,a5,0xc
    800067dc:	97ba                	add	a5,a5,a4
    800067de:	6909                	lui	s2,0x2
    800067e0:	993e                	add	s2,s2,a5
    800067e2:	a019                	j	800067e8 <virtio_disk_rw+0x20c>
      i = disk[n].desc[i].next;
    800067e4:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    800067e8:	85a6                	mv	a1,s1
    800067ea:	8556                	mv	a0,s5
    800067ec:	00000097          	auipc	ra,0x0
    800067f0:	b6c080e7          	jalr	-1172(ra) # 80006358 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800067f4:	0492                	slli	s1,s1,0x4
    800067f6:	00093783          	ld	a5,0(s2) # 2000 <_entry-0x7fffe000>
    800067fa:	94be                	add	s1,s1,a5
    800067fc:	00c4d783          	lhu	a5,12(s1)
    80006800:	8b85                	andi	a5,a5,1
    80006802:	f3ed                	bnez	a5,800067e4 <virtio_disk_rw+0x208>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    80006804:	8566                	mv	a0,s9
    80006806:	ffffa097          	auipc	ra,0xffffa
    8000680a:	506080e7          	jalr	1286(ra) # 80000d0c <release>
}
    8000680e:	60ea                	ld	ra,152(sp)
    80006810:	644a                	ld	s0,144(sp)
    80006812:	64aa                	ld	s1,136(sp)
    80006814:	690a                	ld	s2,128(sp)
    80006816:	79e6                	ld	s3,120(sp)
    80006818:	7a46                	ld	s4,112(sp)
    8000681a:	7aa6                	ld	s5,104(sp)
    8000681c:	7b06                	ld	s6,96(sp)
    8000681e:	6be6                	ld	s7,88(sp)
    80006820:	6c46                	ld	s8,80(sp)
    80006822:	6ca6                	ld	s9,72(sp)
    80006824:	6d06                	ld	s10,64(sp)
    80006826:	7de2                	ld	s11,56(sp)
    80006828:	610d                	addi	sp,sp,160
    8000682a:	8082                	ret
  if(write)
    8000682c:	01b037b3          	snez	a5,s11
    80006830:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006834:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006838:	f6843783          	ld	a5,-152(s0)
    8000683c:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006840:	f8042483          	lw	s1,-128(s0)
    80006844:	00449993          	slli	s3,s1,0x4
    80006848:	001a9793          	slli	a5,s5,0x1
    8000684c:	97d6                	add	a5,a5,s5
    8000684e:	07b2                	slli	a5,a5,0xc
    80006850:	00027917          	auipc	s2,0x27
    80006854:	7b090913          	addi	s2,s2,1968 # 8002e000 <disk>
    80006858:	97ca                	add	a5,a5,s2
    8000685a:	6909                	lui	s2,0x2
    8000685c:	993e                	add	s2,s2,a5
    8000685e:	00093a03          	ld	s4,0(s2) # 2000 <_entry-0x7fffe000>
    80006862:	9a4e                	add	s4,s4,s3
    80006864:	f7040513          	addi	a0,s0,-144
    80006868:	ffffb097          	auipc	ra,0xffffb
    8000686c:	ada080e7          	jalr	-1318(ra) # 80001342 <kvmpa>
    80006870:	00aa3023          	sd	a0,0(s4)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006874:	00093783          	ld	a5,0(s2)
    80006878:	97ce                	add	a5,a5,s3
    8000687a:	4741                	li	a4,16
    8000687c:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000687e:	00093783          	ld	a5,0(s2)
    80006882:	97ce                	add	a5,a5,s3
    80006884:	4705                	li	a4,1
    80006886:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    8000688a:	f8442683          	lw	a3,-124(s0)
    8000688e:	00093783          	ld	a5,0(s2)
    80006892:	99be                	add	s3,s3,a5
    80006894:	00d99723          	sh	a3,14(s3)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006898:	0692                	slli	a3,a3,0x4
    8000689a:	00093783          	ld	a5,0(s2)
    8000689e:	97b6                	add	a5,a5,a3
    800068a0:	060c0713          	addi	a4,s8,96
    800068a4:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    800068a6:	00093783          	ld	a5,0(s2)
    800068aa:	97b6                	add	a5,a5,a3
    800068ac:	40000713          	li	a4,1024
    800068b0:	c798                	sw	a4,8(a5)
  if(write)
    800068b2:	e00d92e3          	bnez	s11,800066b6 <virtio_disk_rw+0xda>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800068b6:	001a9793          	slli	a5,s5,0x1
    800068ba:	97d6                	add	a5,a5,s5
    800068bc:	07b2                	slli	a5,a5,0xc
    800068be:	00027717          	auipc	a4,0x27
    800068c2:	74270713          	addi	a4,a4,1858 # 8002e000 <disk>
    800068c6:	973e                	add	a4,a4,a5
    800068c8:	6789                	lui	a5,0x2
    800068ca:	97ba                	add	a5,a5,a4
    800068cc:	639c                	ld	a5,0(a5)
    800068ce:	97b6                	add	a5,a5,a3
    800068d0:	4709                	li	a4,2
    800068d2:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    800068d6:	bbfd                	j	800066d4 <virtio_disk_rw+0xf8>

00000000800068d8 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    800068d8:	7139                	addi	sp,sp,-64
    800068da:	fc06                	sd	ra,56(sp)
    800068dc:	f822                	sd	s0,48(sp)
    800068de:	f426                	sd	s1,40(sp)
    800068e0:	f04a                	sd	s2,32(sp)
    800068e2:	ec4e                	sd	s3,24(sp)
    800068e4:	e852                	sd	s4,16(sp)
    800068e6:	e456                	sd	s5,8(sp)
    800068e8:	0080                	addi	s0,sp,64
    800068ea:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    800068ec:	00151913          	slli	s2,a0,0x1
    800068f0:	00a90a33          	add	s4,s2,a0
    800068f4:	0a32                	slli	s4,s4,0xc
    800068f6:	6989                	lui	s3,0x2
    800068f8:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    800068fc:	9a3e                	add	s4,s4,a5
    800068fe:	00027a97          	auipc	s5,0x27
    80006902:	702a8a93          	addi	s5,s5,1794 # 8002e000 <disk>
    80006906:	9a56                	add	s4,s4,s5
    80006908:	8552                	mv	a0,s4
    8000690a:	ffffa097          	auipc	ra,0xffffa
    8000690e:	392080e7          	jalr	914(ra) # 80000c9c <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006912:	9926                	add	s2,s2,s1
    80006914:	0932                	slli	s2,s2,0xc
    80006916:	9956                	add	s2,s2,s5
    80006918:	99ca                	add	s3,s3,s2
    8000691a:	0209d783          	lhu	a5,32(s3)
    8000691e:	0109b703          	ld	a4,16(s3)
    80006922:	00275683          	lhu	a3,2(a4)
    80006926:	8ebd                	xor	a3,a3,a5
    80006928:	8a9d                	andi	a3,a3,7
    8000692a:	c2a5                	beqz	a3,8000698a <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    8000692c:	8956                	mv	s2,s5
    8000692e:	00149693          	slli	a3,s1,0x1
    80006932:	96a6                	add	a3,a3,s1
    80006934:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006938:	06b2                	slli	a3,a3,0xc
    8000693a:	96d6                	add	a3,a3,s5
    8000693c:	6489                	lui	s1,0x2
    8000693e:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006940:	078e                	slli	a5,a5,0x3
    80006942:	97ba                	add	a5,a5,a4
    80006944:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    80006946:	00f98733          	add	a4,s3,a5
    8000694a:	20070713          	addi	a4,a4,512
    8000694e:	0712                	slli	a4,a4,0x4
    80006950:	974a                	add	a4,a4,s2
    80006952:	03074703          	lbu	a4,48(a4)
    80006956:	eb21                	bnez	a4,800069a6 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006958:	97ce                	add	a5,a5,s3
    8000695a:	20078793          	addi	a5,a5,512
    8000695e:	0792                	slli	a5,a5,0x4
    80006960:	97ca                	add	a5,a5,s2
    80006962:	7798                	ld	a4,40(a5)
    80006964:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006968:	7788                	ld	a0,40(a5)
    8000696a:	ffffc097          	auipc	ra,0xffffc
    8000696e:	cae080e7          	jalr	-850(ra) # 80002618 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006972:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006976:	2785                	addiw	a5,a5,1
    80006978:	8b9d                	andi	a5,a5,7
    8000697a:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    8000697e:	6898                	ld	a4,16(s1)
    80006980:	00275683          	lhu	a3,2(a4)
    80006984:	8a9d                	andi	a3,a3,7
    80006986:	faf69de3          	bne	a3,a5,80006940 <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    8000698a:	8552                	mv	a0,s4
    8000698c:	ffffa097          	auipc	ra,0xffffa
    80006990:	380080e7          	jalr	896(ra) # 80000d0c <release>
}
    80006994:	70e2                	ld	ra,56(sp)
    80006996:	7442                	ld	s0,48(sp)
    80006998:	74a2                	ld	s1,40(sp)
    8000699a:	7902                	ld	s2,32(sp)
    8000699c:	69e2                	ld	s3,24(sp)
    8000699e:	6a42                	ld	s4,16(sp)
    800069a0:	6aa2                	ld	s5,8(sp)
    800069a2:	6121                	addi	sp,sp,64
    800069a4:	8082                	ret
      panic("virtio_disk_intr status");
    800069a6:	00002517          	auipc	a0,0x2
    800069aa:	1ca50513          	addi	a0,a0,458 # 80008b70 <userret+0xae0>
    800069ae:	ffffa097          	auipc	ra,0xffffa
    800069b2:	b9a080e7          	jalr	-1126(ra) # 80000548 <panic>

00000000800069b6 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    800069b6:	1141                	addi	sp,sp,-16
    800069b8:	e422                	sd	s0,8(sp)
    800069ba:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    800069bc:	41f5d79b          	sraiw	a5,a1,0x1f
    800069c0:	01d7d79b          	srliw	a5,a5,0x1d
    800069c4:	9dbd                	addw	a1,a1,a5
    800069c6:	0075f713          	andi	a4,a1,7
    800069ca:	9f1d                	subw	a4,a4,a5
    800069cc:	4785                	li	a5,1
    800069ce:	00e797bb          	sllw	a5,a5,a4
    800069d2:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    800069d6:	4035d59b          	sraiw	a1,a1,0x3
    800069da:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    800069dc:	0005c503          	lbu	a0,0(a1)
    800069e0:	8d7d                	and	a0,a0,a5
    800069e2:	8d1d                	sub	a0,a0,a5
}
    800069e4:	00153513          	seqz	a0,a0
    800069e8:	6422                	ld	s0,8(sp)
    800069ea:	0141                	addi	sp,sp,16
    800069ec:	8082                	ret

00000000800069ee <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    800069ee:	1141                	addi	sp,sp,-16
    800069f0:	e422                	sd	s0,8(sp)
    800069f2:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800069f4:	41f5d79b          	sraiw	a5,a1,0x1f
    800069f8:	01d7d79b          	srliw	a5,a5,0x1d
    800069fc:	9dbd                	addw	a1,a1,a5
    800069fe:	4035d71b          	sraiw	a4,a1,0x3
    80006a02:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006a04:	899d                	andi	a1,a1,7
    80006a06:	9d9d                	subw	a1,a1,a5
    80006a08:	4785                	li	a5,1
    80006a0a:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    80006a0e:	00054783          	lbu	a5,0(a0)
    80006a12:	8ddd                	or	a1,a1,a5
    80006a14:	00b50023          	sb	a1,0(a0)
}
    80006a18:	6422                	ld	s0,8(sp)
    80006a1a:	0141                	addi	sp,sp,16
    80006a1c:	8082                	ret

0000000080006a1e <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80006a1e:	1141                	addi	sp,sp,-16
    80006a20:	e422                	sd	s0,8(sp)
    80006a22:	0800                	addi	s0,sp,16
  char b = array[index/8];
    80006a24:	41f5d79b          	sraiw	a5,a1,0x1f
    80006a28:	01d7d79b          	srliw	a5,a5,0x1d
    80006a2c:	9dbd                	addw	a1,a1,a5
    80006a2e:	4035d71b          	sraiw	a4,a1,0x3
    80006a32:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    80006a34:	899d                	andi	a1,a1,7
    80006a36:	9d9d                	subw	a1,a1,a5
    80006a38:	4785                	li	a5,1
    80006a3a:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    80006a3e:	fff5c593          	not	a1,a1
    80006a42:	00054783          	lbu	a5,0(a0)
    80006a46:	8dfd                	and	a1,a1,a5
    80006a48:	00b50023          	sb	a1,0(a0)
}
    80006a4c:	6422                	ld	s0,8(sp)
    80006a4e:	0141                	addi	sp,sp,16
    80006a50:	8082                	ret

0000000080006a52 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006a52:	715d                	addi	sp,sp,-80
    80006a54:	e486                	sd	ra,72(sp)
    80006a56:	e0a2                	sd	s0,64(sp)
    80006a58:	fc26                	sd	s1,56(sp)
    80006a5a:	f84a                	sd	s2,48(sp)
    80006a5c:	f44e                	sd	s3,40(sp)
    80006a5e:	f052                	sd	s4,32(sp)
    80006a60:	ec56                	sd	s5,24(sp)
    80006a62:	e85a                	sd	s6,16(sp)
    80006a64:	e45e                	sd	s7,8(sp)
    80006a66:	0880                	addi	s0,sp,80
    80006a68:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006a6a:	08b05b63          	blez	a1,80006b00 <bd_print_vector+0xae>
    80006a6e:	89aa                	mv	s3,a0
    80006a70:	4481                	li	s1,0
  lb = 0;
    80006a72:	4a81                	li	s5,0
  last = 1;
    80006a74:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006a76:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006a78:	00002b97          	auipc	s7,0x2
    80006a7c:	110b8b93          	addi	s7,s7,272 # 80008b88 <userret+0xaf8>
    80006a80:	a821                	j	80006a98 <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80006a82:	85a6                	mv	a1,s1
    80006a84:	854e                	mv	a0,s3
    80006a86:	00000097          	auipc	ra,0x0
    80006a8a:	f30080e7          	jalr	-208(ra) # 800069b6 <bit_isset>
    80006a8e:	892a                	mv	s2,a0
    80006a90:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006a92:	2485                	addiw	s1,s1,1
    80006a94:	029a0463          	beq	s4,s1,80006abc <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006a98:	85a6                	mv	a1,s1
    80006a9a:	854e                	mv	a0,s3
    80006a9c:	00000097          	auipc	ra,0x0
    80006aa0:	f1a080e7          	jalr	-230(ra) # 800069b6 <bit_isset>
    80006aa4:	ff2507e3          	beq	a0,s2,80006a92 <bd_print_vector+0x40>
    if(last == 1)
    80006aa8:	fd691de3          	bne	s2,s6,80006a82 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    80006aac:	8626                	mv	a2,s1
    80006aae:	85d6                	mv	a1,s5
    80006ab0:	855e                	mv	a0,s7
    80006ab2:	ffffa097          	auipc	ra,0xffffa
    80006ab6:	af0080e7          	jalr	-1296(ra) # 800005a2 <printf>
    80006aba:	b7e1                	j	80006a82 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80006abc:	000a8563          	beqz	s5,80006ac6 <bd_print_vector+0x74>
    80006ac0:	4785                	li	a5,1
    80006ac2:	00f91c63          	bne	s2,a5,80006ada <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006ac6:	8652                	mv	a2,s4
    80006ac8:	85d6                	mv	a1,s5
    80006aca:	00002517          	auipc	a0,0x2
    80006ace:	0be50513          	addi	a0,a0,190 # 80008b88 <userret+0xaf8>
    80006ad2:	ffffa097          	auipc	ra,0xffffa
    80006ad6:	ad0080e7          	jalr	-1328(ra) # 800005a2 <printf>
  }
  printf("\n");
    80006ada:	00002517          	auipc	a0,0x2
    80006ade:	af650513          	addi	a0,a0,-1290 # 800085d0 <userret+0x540>
    80006ae2:	ffffa097          	auipc	ra,0xffffa
    80006ae6:	ac0080e7          	jalr	-1344(ra) # 800005a2 <printf>
}
    80006aea:	60a6                	ld	ra,72(sp)
    80006aec:	6406                	ld	s0,64(sp)
    80006aee:	74e2                	ld	s1,56(sp)
    80006af0:	7942                	ld	s2,48(sp)
    80006af2:	79a2                	ld	s3,40(sp)
    80006af4:	7a02                	ld	s4,32(sp)
    80006af6:	6ae2                	ld	s5,24(sp)
    80006af8:	6b42                	ld	s6,16(sp)
    80006afa:	6ba2                	ld	s7,8(sp)
    80006afc:	6161                	addi	sp,sp,80
    80006afe:	8082                	ret
  lb = 0;
    80006b00:	4a81                	li	s5,0
    80006b02:	b7d1                	j	80006ac6 <bd_print_vector+0x74>

0000000080006b04 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    80006b04:	0002d697          	auipc	a3,0x2d
    80006b08:	5546a683          	lw	a3,1364(a3) # 80034058 <nsizes>
    80006b0c:	10d05063          	blez	a3,80006c0c <bd_print+0x108>
bd_print() {
    80006b10:	711d                	addi	sp,sp,-96
    80006b12:	ec86                	sd	ra,88(sp)
    80006b14:	e8a2                	sd	s0,80(sp)
    80006b16:	e4a6                	sd	s1,72(sp)
    80006b18:	e0ca                	sd	s2,64(sp)
    80006b1a:	fc4e                	sd	s3,56(sp)
    80006b1c:	f852                	sd	s4,48(sp)
    80006b1e:	f456                	sd	s5,40(sp)
    80006b20:	f05a                	sd	s6,32(sp)
    80006b22:	ec5e                	sd	s7,24(sp)
    80006b24:	e862                	sd	s8,16(sp)
    80006b26:	e466                	sd	s9,8(sp)
    80006b28:	e06a                	sd	s10,0(sp)
    80006b2a:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    80006b2c:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006b2e:	4a85                	li	s5,1
    80006b30:	4c41                	li	s8,16
    80006b32:	00002b97          	auipc	s7,0x2
    80006b36:	066b8b93          	addi	s7,s7,102 # 80008b98 <userret+0xb08>
    lst_print(&bd_sizes[k].free);
    80006b3a:	0002da17          	auipc	s4,0x2d
    80006b3e:	516a0a13          	addi	s4,s4,1302 # 80034050 <bd_sizes>
    printf("  alloc:");
    80006b42:	00002b17          	auipc	s6,0x2
    80006b46:	07eb0b13          	addi	s6,s6,126 # 80008bc0 <userret+0xb30>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006b4a:	0002d997          	auipc	s3,0x2d
    80006b4e:	50e98993          	addi	s3,s3,1294 # 80034058 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006b52:	00002c97          	auipc	s9,0x2
    80006b56:	07ec8c93          	addi	s9,s9,126 # 80008bd0 <userret+0xb40>
    80006b5a:	a801                	j	80006b6a <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    80006b5c:	0009a683          	lw	a3,0(s3)
    80006b60:	0485                	addi	s1,s1,1
    80006b62:	0004879b          	sext.w	a5,s1
    80006b66:	08d7d563          	bge	a5,a3,80006bf0 <bd_print+0xec>
    80006b6a:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006b6e:	36fd                	addiw	a3,a3,-1
    80006b70:	9e85                	subw	a3,a3,s1
    80006b72:	00da96bb          	sllw	a3,s5,a3
    80006b76:	009c1633          	sll	a2,s8,s1
    80006b7a:	85ca                	mv	a1,s2
    80006b7c:	855e                	mv	a0,s7
    80006b7e:	ffffa097          	auipc	ra,0xffffa
    80006b82:	a24080e7          	jalr	-1500(ra) # 800005a2 <printf>
    lst_print(&bd_sizes[k].free);
    80006b86:	00549d13          	slli	s10,s1,0x5
    80006b8a:	000a3503          	ld	a0,0(s4)
    80006b8e:	956a                	add	a0,a0,s10
    80006b90:	00001097          	auipc	ra,0x1
    80006b94:	a56080e7          	jalr	-1450(ra) # 800075e6 <lst_print>
    printf("  alloc:");
    80006b98:	855a                	mv	a0,s6
    80006b9a:	ffffa097          	auipc	ra,0xffffa
    80006b9e:	a08080e7          	jalr	-1528(ra) # 800005a2 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006ba2:	0009a583          	lw	a1,0(s3)
    80006ba6:	35fd                	addiw	a1,a1,-1
    80006ba8:	412585bb          	subw	a1,a1,s2
    80006bac:	000a3783          	ld	a5,0(s4)
    80006bb0:	97ea                	add	a5,a5,s10
    80006bb2:	00ba95bb          	sllw	a1,s5,a1
    80006bb6:	6b88                	ld	a0,16(a5)
    80006bb8:	00000097          	auipc	ra,0x0
    80006bbc:	e9a080e7          	jalr	-358(ra) # 80006a52 <bd_print_vector>
    if(k > 0) {
    80006bc0:	f9205ee3          	blez	s2,80006b5c <bd_print+0x58>
      printf("  split:");
    80006bc4:	8566                	mv	a0,s9
    80006bc6:	ffffa097          	auipc	ra,0xffffa
    80006bca:	9dc080e7          	jalr	-1572(ra) # 800005a2 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80006bce:	0009a583          	lw	a1,0(s3)
    80006bd2:	35fd                	addiw	a1,a1,-1
    80006bd4:	412585bb          	subw	a1,a1,s2
    80006bd8:	000a3783          	ld	a5,0(s4)
    80006bdc:	9d3e                	add	s10,s10,a5
    80006bde:	00ba95bb          	sllw	a1,s5,a1
    80006be2:	018d3503          	ld	a0,24(s10)
    80006be6:	00000097          	auipc	ra,0x0
    80006bea:	e6c080e7          	jalr	-404(ra) # 80006a52 <bd_print_vector>
    80006bee:	b7bd                	j	80006b5c <bd_print+0x58>
    }
  }
}
    80006bf0:	60e6                	ld	ra,88(sp)
    80006bf2:	6446                	ld	s0,80(sp)
    80006bf4:	64a6                	ld	s1,72(sp)
    80006bf6:	6906                	ld	s2,64(sp)
    80006bf8:	79e2                	ld	s3,56(sp)
    80006bfa:	7a42                	ld	s4,48(sp)
    80006bfc:	7aa2                	ld	s5,40(sp)
    80006bfe:	7b02                	ld	s6,32(sp)
    80006c00:	6be2                	ld	s7,24(sp)
    80006c02:	6c42                	ld	s8,16(sp)
    80006c04:	6ca2                	ld	s9,8(sp)
    80006c06:	6d02                	ld	s10,0(sp)
    80006c08:	6125                	addi	sp,sp,96
    80006c0a:	8082                	ret
    80006c0c:	8082                	ret

0000000080006c0e <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80006c0e:	1141                	addi	sp,sp,-16
    80006c10:	e422                	sd	s0,8(sp)
    80006c12:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    80006c14:	47c1                	li	a5,16
    80006c16:	00a7fb63          	bgeu	a5,a0,80006c2c <firstk+0x1e>
    80006c1a:	872a                	mv	a4,a0
  int k = 0;
    80006c1c:	4501                	li	a0,0
    k++;
    80006c1e:	2505                	addiw	a0,a0,1
    size *= 2;
    80006c20:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006c22:	fee7eee3          	bltu	a5,a4,80006c1e <firstk+0x10>
  }
  return k;
}
    80006c26:	6422                	ld	s0,8(sp)
    80006c28:	0141                	addi	sp,sp,16
    80006c2a:	8082                	ret
  int k = 0;
    80006c2c:	4501                	li	a0,0
    80006c2e:	bfe5                	j	80006c26 <firstk+0x18>

0000000080006c30 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006c30:	1141                	addi	sp,sp,-16
    80006c32:	e422                	sd	s0,8(sp)
    80006c34:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    80006c36:	0002d797          	auipc	a5,0x2d
    80006c3a:	4127b783          	ld	a5,1042(a5) # 80034048 <bd_base>
    80006c3e:	9d9d                	subw	a1,a1,a5
    80006c40:	47c1                	li	a5,16
    80006c42:	00a797b3          	sll	a5,a5,a0
    80006c46:	02f5c5b3          	div	a1,a1,a5
}
    80006c4a:	0005851b          	sext.w	a0,a1
    80006c4e:	6422                	ld	s0,8(sp)
    80006c50:	0141                	addi	sp,sp,16
    80006c52:	8082                	ret

0000000080006c54 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006c54:	1141                	addi	sp,sp,-16
    80006c56:	e422                	sd	s0,8(sp)
    80006c58:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006c5a:	47c1                	li	a5,16
    80006c5c:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006c60:	02b787bb          	mulw	a5,a5,a1
}
    80006c64:	0002d517          	auipc	a0,0x2d
    80006c68:	3e453503          	ld	a0,996(a0) # 80034048 <bd_base>
    80006c6c:	953e                	add	a0,a0,a5
    80006c6e:	6422                	ld	s0,8(sp)
    80006c70:	0141                	addi	sp,sp,16
    80006c72:	8082                	ret

0000000080006c74 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006c74:	7159                	addi	sp,sp,-112
    80006c76:	f486                	sd	ra,104(sp)
    80006c78:	f0a2                	sd	s0,96(sp)
    80006c7a:	eca6                	sd	s1,88(sp)
    80006c7c:	e8ca                	sd	s2,80(sp)
    80006c7e:	e4ce                	sd	s3,72(sp)
    80006c80:	e0d2                	sd	s4,64(sp)
    80006c82:	fc56                	sd	s5,56(sp)
    80006c84:	f85a                	sd	s6,48(sp)
    80006c86:	f45e                	sd	s7,40(sp)
    80006c88:	f062                	sd	s8,32(sp)
    80006c8a:	ec66                	sd	s9,24(sp)
    80006c8c:	e86a                	sd	s10,16(sp)
    80006c8e:	e46e                	sd	s11,8(sp)
    80006c90:	1880                	addi	s0,sp,112
    80006c92:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006c94:	0002d517          	auipc	a0,0x2d
    80006c98:	36c50513          	addi	a0,a0,876 # 80034000 <lock>
    80006c9c:	ffffa097          	auipc	ra,0xffffa
    80006ca0:	000080e7          	jalr	ra # 80000c9c <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006ca4:	8526                	mv	a0,s1
    80006ca6:	00000097          	auipc	ra,0x0
    80006caa:	f68080e7          	jalr	-152(ra) # 80006c0e <firstk>
  for (k = fk; k < nsizes; k++) {
    80006cae:	0002d797          	auipc	a5,0x2d
    80006cb2:	3aa7a783          	lw	a5,938(a5) # 80034058 <nsizes>
    80006cb6:	02f55d63          	bge	a0,a5,80006cf0 <bd_malloc+0x7c>
    80006cba:	8c2a                	mv	s8,a0
    80006cbc:	00551913          	slli	s2,a0,0x5
    80006cc0:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006cc2:	0002d997          	auipc	s3,0x2d
    80006cc6:	38e98993          	addi	s3,s3,910 # 80034050 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006cca:	0002da17          	auipc	s4,0x2d
    80006cce:	38ea0a13          	addi	s4,s4,910 # 80034058 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006cd2:	0009b503          	ld	a0,0(s3)
    80006cd6:	954a                	add	a0,a0,s2
    80006cd8:	00001097          	auipc	ra,0x1
    80006cdc:	894080e7          	jalr	-1900(ra) # 8000756c <lst_empty>
    80006ce0:	c115                	beqz	a0,80006d04 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006ce2:	2485                	addiw	s1,s1,1
    80006ce4:	02090913          	addi	s2,s2,32
    80006ce8:	000a2783          	lw	a5,0(s4)
    80006cec:	fef4c3e3          	blt	s1,a5,80006cd2 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006cf0:	0002d517          	auipc	a0,0x2d
    80006cf4:	31050513          	addi	a0,a0,784 # 80034000 <lock>
    80006cf8:	ffffa097          	auipc	ra,0xffffa
    80006cfc:	014080e7          	jalr	20(ra) # 80000d0c <release>
    return 0;
    80006d00:	4b01                	li	s6,0
    80006d02:	a0e1                	j	80006dca <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80006d04:	0002d797          	auipc	a5,0x2d
    80006d08:	3547a783          	lw	a5,852(a5) # 80034058 <nsizes>
    80006d0c:	fef4d2e3          	bge	s1,a5,80006cf0 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006d10:	00549993          	slli	s3,s1,0x5
    80006d14:	0002d917          	auipc	s2,0x2d
    80006d18:	33c90913          	addi	s2,s2,828 # 80034050 <bd_sizes>
    80006d1c:	00093503          	ld	a0,0(s2)
    80006d20:	954e                	add	a0,a0,s3
    80006d22:	00001097          	auipc	ra,0x1
    80006d26:	876080e7          	jalr	-1930(ra) # 80007598 <lst_pop>
    80006d2a:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006d2c:	0002d597          	auipc	a1,0x2d
    80006d30:	31c5b583          	ld	a1,796(a1) # 80034048 <bd_base>
    80006d34:	40b505bb          	subw	a1,a0,a1
    80006d38:	47c1                	li	a5,16
    80006d3a:	009797b3          	sll	a5,a5,s1
    80006d3e:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006d42:	00093783          	ld	a5,0(s2)
    80006d46:	97ce                	add	a5,a5,s3
    80006d48:	2581                	sext.w	a1,a1
    80006d4a:	6b88                	ld	a0,16(a5)
    80006d4c:	00000097          	auipc	ra,0x0
    80006d50:	ca2080e7          	jalr	-862(ra) # 800069ee <bit_set>
  for(; k > fk; k--) {
    80006d54:	069c5363          	bge	s8,s1,80006dba <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006d58:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006d5a:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006d5c:	0002dd17          	auipc	s10,0x2d
    80006d60:	2ecd0d13          	addi	s10,s10,748 # 80034048 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006d64:	85a6                	mv	a1,s1
    80006d66:	34fd                	addiw	s1,s1,-1
    80006d68:	009b9ab3          	sll	s5,s7,s1
    80006d6c:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006d70:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
  int n = p - (char *) bd_base;
    80006d74:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006d78:	412b093b          	subw	s2,s6,s2
    80006d7c:	00bb95b3          	sll	a1,s7,a1
    80006d80:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006d84:	013a07b3          	add	a5,s4,s3
    80006d88:	2581                	sext.w	a1,a1
    80006d8a:	6f88                	ld	a0,24(a5)
    80006d8c:	00000097          	auipc	ra,0x0
    80006d90:	c62080e7          	jalr	-926(ra) # 800069ee <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006d94:	1981                	addi	s3,s3,-32
    80006d96:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006d98:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006d9c:	2581                	sext.w	a1,a1
    80006d9e:	010a3503          	ld	a0,16(s4)
    80006da2:	00000097          	auipc	ra,0x0
    80006da6:	c4c080e7          	jalr	-948(ra) # 800069ee <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006daa:	85e6                	mv	a1,s9
    80006dac:	8552                	mv	a0,s4
    80006dae:	00001097          	auipc	ra,0x1
    80006db2:	820080e7          	jalr	-2016(ra) # 800075ce <lst_push>
  for(; k > fk; k--) {
    80006db6:	fb8497e3          	bne	s1,s8,80006d64 <bd_malloc+0xf0>
  }
  release(&lock);
    80006dba:	0002d517          	auipc	a0,0x2d
    80006dbe:	24650513          	addi	a0,a0,582 # 80034000 <lock>
    80006dc2:	ffffa097          	auipc	ra,0xffffa
    80006dc6:	f4a080e7          	jalr	-182(ra) # 80000d0c <release>

  return p;
}
    80006dca:	855a                	mv	a0,s6
    80006dcc:	70a6                	ld	ra,104(sp)
    80006dce:	7406                	ld	s0,96(sp)
    80006dd0:	64e6                	ld	s1,88(sp)
    80006dd2:	6946                	ld	s2,80(sp)
    80006dd4:	69a6                	ld	s3,72(sp)
    80006dd6:	6a06                	ld	s4,64(sp)
    80006dd8:	7ae2                	ld	s5,56(sp)
    80006dda:	7b42                	ld	s6,48(sp)
    80006ddc:	7ba2                	ld	s7,40(sp)
    80006dde:	7c02                	ld	s8,32(sp)
    80006de0:	6ce2                	ld	s9,24(sp)
    80006de2:	6d42                	ld	s10,16(sp)
    80006de4:	6da2                	ld	s11,8(sp)
    80006de6:	6165                	addi	sp,sp,112
    80006de8:	8082                	ret

0000000080006dea <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006dea:	7139                	addi	sp,sp,-64
    80006dec:	fc06                	sd	ra,56(sp)
    80006dee:	f822                	sd	s0,48(sp)
    80006df0:	f426                	sd	s1,40(sp)
    80006df2:	f04a                	sd	s2,32(sp)
    80006df4:	ec4e                	sd	s3,24(sp)
    80006df6:	e852                	sd	s4,16(sp)
    80006df8:	e456                	sd	s5,8(sp)
    80006dfa:	e05a                	sd	s6,0(sp)
    80006dfc:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006dfe:	0002da97          	auipc	s5,0x2d
    80006e02:	25aaaa83          	lw	s5,602(s5) # 80034058 <nsizes>
  return n / BLK_SIZE(k);
    80006e06:	0002da17          	auipc	s4,0x2d
    80006e0a:	242a3a03          	ld	s4,578(s4) # 80034048 <bd_base>
    80006e0e:	41450a3b          	subw	s4,a0,s4
    80006e12:	0002d497          	auipc	s1,0x2d
    80006e16:	23e4b483          	ld	s1,574(s1) # 80034050 <bd_sizes>
    80006e1a:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006e1e:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006e20:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006e22:	03595363          	bge	s2,s5,80006e48 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006e26:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006e2a:	013b15b3          	sll	a1,s6,s3
    80006e2e:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006e32:	2581                	sext.w	a1,a1
    80006e34:	6088                	ld	a0,0(s1)
    80006e36:	00000097          	auipc	ra,0x0
    80006e3a:	b80080e7          	jalr	-1152(ra) # 800069b6 <bit_isset>
    80006e3e:	02048493          	addi	s1,s1,32
    80006e42:	e501                	bnez	a0,80006e4a <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006e44:	894e                	mv	s2,s3
    80006e46:	bff1                	j	80006e22 <size+0x38>
      return k;
    }
  }
  return 0;
    80006e48:	4901                	li	s2,0
}
    80006e4a:	854a                	mv	a0,s2
    80006e4c:	70e2                	ld	ra,56(sp)
    80006e4e:	7442                	ld	s0,48(sp)
    80006e50:	74a2                	ld	s1,40(sp)
    80006e52:	7902                	ld	s2,32(sp)
    80006e54:	69e2                	ld	s3,24(sp)
    80006e56:	6a42                	ld	s4,16(sp)
    80006e58:	6aa2                	ld	s5,8(sp)
    80006e5a:	6b02                	ld	s6,0(sp)
    80006e5c:	6121                	addi	sp,sp,64
    80006e5e:	8082                	ret

0000000080006e60 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006e60:	7159                	addi	sp,sp,-112
    80006e62:	f486                	sd	ra,104(sp)
    80006e64:	f0a2                	sd	s0,96(sp)
    80006e66:	eca6                	sd	s1,88(sp)
    80006e68:	e8ca                	sd	s2,80(sp)
    80006e6a:	e4ce                	sd	s3,72(sp)
    80006e6c:	e0d2                	sd	s4,64(sp)
    80006e6e:	fc56                	sd	s5,56(sp)
    80006e70:	f85a                	sd	s6,48(sp)
    80006e72:	f45e                	sd	s7,40(sp)
    80006e74:	f062                	sd	s8,32(sp)
    80006e76:	ec66                	sd	s9,24(sp)
    80006e78:	e86a                	sd	s10,16(sp)
    80006e7a:	e46e                	sd	s11,8(sp)
    80006e7c:	1880                	addi	s0,sp,112
    80006e7e:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006e80:	0002d517          	auipc	a0,0x2d
    80006e84:	18050513          	addi	a0,a0,384 # 80034000 <lock>
    80006e88:	ffffa097          	auipc	ra,0xffffa
    80006e8c:	e14080e7          	jalr	-492(ra) # 80000c9c <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80006e90:	8556                	mv	a0,s5
    80006e92:	00000097          	auipc	ra,0x0
    80006e96:	f58080e7          	jalr	-168(ra) # 80006dea <size>
    80006e9a:	84aa                	mv	s1,a0
    80006e9c:	0002d797          	auipc	a5,0x2d
    80006ea0:	1bc7a783          	lw	a5,444(a5) # 80034058 <nsizes>
    80006ea4:	37fd                	addiw	a5,a5,-1
    80006ea6:	0cf55063          	bge	a0,a5,80006f66 <bd_free+0x106>
    80006eaa:	00150a13          	addi	s4,a0,1
    80006eae:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    80006eb0:	0002dc17          	auipc	s8,0x2d
    80006eb4:	198c0c13          	addi	s8,s8,408 # 80034048 <bd_base>
  return n / BLK_SIZE(k);
    80006eb8:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006eba:	0002db17          	auipc	s6,0x2d
    80006ebe:	196b0b13          	addi	s6,s6,406 # 80034050 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006ec2:	0002dc97          	auipc	s9,0x2d
    80006ec6:	196c8c93          	addi	s9,s9,406 # 80034058 <nsizes>
    80006eca:	a82d                	j	80006f04 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006ecc:	fff58d9b          	addiw	s11,a1,-1
    80006ed0:	a881                	j	80006f20 <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006ed2:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80006ed4:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80006ed8:	40ba85bb          	subw	a1,s5,a1
    80006edc:	009b97b3          	sll	a5,s7,s1
    80006ee0:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006ee4:	000b3783          	ld	a5,0(s6)
    80006ee8:	97d2                	add	a5,a5,s4
    80006eea:	2581                	sext.w	a1,a1
    80006eec:	6f88                	ld	a0,24(a5)
    80006eee:	00000097          	auipc	ra,0x0
    80006ef2:	b30080e7          	jalr	-1232(ra) # 80006a1e <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006ef6:	020a0a13          	addi	s4,s4,32
    80006efa:	000ca783          	lw	a5,0(s9)
    80006efe:	37fd                	addiw	a5,a5,-1
    80006f00:	06f4d363          	bge	s1,a5,80006f66 <bd_free+0x106>
  int n = p - (char *) bd_base;
    80006f04:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006f08:	009b99b3          	sll	s3,s7,s1
    80006f0c:	412a87bb          	subw	a5,s5,s2
    80006f10:	0337c7b3          	div	a5,a5,s3
    80006f14:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006f18:	8b85                	andi	a5,a5,1
    80006f1a:	fbcd                	bnez	a5,80006ecc <bd_free+0x6c>
    80006f1c:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006f20:	fe0a0d13          	addi	s10,s4,-32
    80006f24:	000b3783          	ld	a5,0(s6)
    80006f28:	9d3e                	add	s10,s10,a5
    80006f2a:	010d3503          	ld	a0,16(s10)
    80006f2e:	00000097          	auipc	ra,0x0
    80006f32:	af0080e7          	jalr	-1296(ra) # 80006a1e <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006f36:	85ee                	mv	a1,s11
    80006f38:	010d3503          	ld	a0,16(s10)
    80006f3c:	00000097          	auipc	ra,0x0
    80006f40:	a7a080e7          	jalr	-1414(ra) # 800069b6 <bit_isset>
    80006f44:	e10d                	bnez	a0,80006f66 <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    80006f46:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006f4a:	03b989bb          	mulw	s3,s3,s11
    80006f4e:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006f50:	854a                	mv	a0,s2
    80006f52:	00000097          	auipc	ra,0x0
    80006f56:	630080e7          	jalr	1584(ra) # 80007582 <lst_remove>
    if(buddy % 2 == 0) {
    80006f5a:	001d7d13          	andi	s10,s10,1
    80006f5e:	f60d1ae3          	bnez	s10,80006ed2 <bd_free+0x72>
      p = q;
    80006f62:	8aca                	mv	s5,s2
    80006f64:	b7bd                	j	80006ed2 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    80006f66:	0496                	slli	s1,s1,0x5
    80006f68:	85d6                	mv	a1,s5
    80006f6a:	0002d517          	auipc	a0,0x2d
    80006f6e:	0e653503          	ld	a0,230(a0) # 80034050 <bd_sizes>
    80006f72:	9526                	add	a0,a0,s1
    80006f74:	00000097          	auipc	ra,0x0
    80006f78:	65a080e7          	jalr	1626(ra) # 800075ce <lst_push>
  release(&lock);
    80006f7c:	0002d517          	auipc	a0,0x2d
    80006f80:	08450513          	addi	a0,a0,132 # 80034000 <lock>
    80006f84:	ffffa097          	auipc	ra,0xffffa
    80006f88:	d88080e7          	jalr	-632(ra) # 80000d0c <release>
}
    80006f8c:	70a6                	ld	ra,104(sp)
    80006f8e:	7406                	ld	s0,96(sp)
    80006f90:	64e6                	ld	s1,88(sp)
    80006f92:	6946                	ld	s2,80(sp)
    80006f94:	69a6                	ld	s3,72(sp)
    80006f96:	6a06                	ld	s4,64(sp)
    80006f98:	7ae2                	ld	s5,56(sp)
    80006f9a:	7b42                	ld	s6,48(sp)
    80006f9c:	7ba2                	ld	s7,40(sp)
    80006f9e:	7c02                	ld	s8,32(sp)
    80006fa0:	6ce2                	ld	s9,24(sp)
    80006fa2:	6d42                	ld	s10,16(sp)
    80006fa4:	6da2                	ld	s11,8(sp)
    80006fa6:	6165                	addi	sp,sp,112
    80006fa8:	8082                	ret

0000000080006faa <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006faa:	1141                	addi	sp,sp,-16
    80006fac:	e422                	sd	s0,8(sp)
    80006fae:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006fb0:	0002d797          	auipc	a5,0x2d
    80006fb4:	0987b783          	ld	a5,152(a5) # 80034048 <bd_base>
    80006fb8:	8d9d                	sub	a1,a1,a5
    80006fba:	47c1                	li	a5,16
    80006fbc:	00a797b3          	sll	a5,a5,a0
    80006fc0:	02f5c533          	div	a0,a1,a5
    80006fc4:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006fc6:	02f5e5b3          	rem	a1,a1,a5
    80006fca:	c191                	beqz	a1,80006fce <blk_index_next+0x24>
      n++;
    80006fcc:	2505                	addiw	a0,a0,1
  return n ;
}
    80006fce:	6422                	ld	s0,8(sp)
    80006fd0:	0141                	addi	sp,sp,16
    80006fd2:	8082                	ret

0000000080006fd4 <log2>:

int
log2(uint64 n) {
    80006fd4:	1141                	addi	sp,sp,-16
    80006fd6:	e422                	sd	s0,8(sp)
    80006fd8:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006fda:	4705                	li	a4,1
    80006fdc:	00a77b63          	bgeu	a4,a0,80006ff2 <log2+0x1e>
    80006fe0:	87aa                	mv	a5,a0
  int k = 0;
    80006fe2:	4501                	li	a0,0
    k++;
    80006fe4:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006fe6:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006fe8:	fef76ee3          	bltu	a4,a5,80006fe4 <log2+0x10>
  }
  return k;
}
    80006fec:	6422                	ld	s0,8(sp)
    80006fee:	0141                	addi	sp,sp,16
    80006ff0:	8082                	ret
  int k = 0;
    80006ff2:	4501                	li	a0,0
    80006ff4:	bfe5                	j	80006fec <log2+0x18>

0000000080006ff6 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006ff6:	711d                	addi	sp,sp,-96
    80006ff8:	ec86                	sd	ra,88(sp)
    80006ffa:	e8a2                	sd	s0,80(sp)
    80006ffc:	e4a6                	sd	s1,72(sp)
    80006ffe:	e0ca                	sd	s2,64(sp)
    80007000:	fc4e                	sd	s3,56(sp)
    80007002:	f852                	sd	s4,48(sp)
    80007004:	f456                	sd	s5,40(sp)
    80007006:	f05a                	sd	s6,32(sp)
    80007008:	ec5e                	sd	s7,24(sp)
    8000700a:	e862                	sd	s8,16(sp)
    8000700c:	e466                	sd	s9,8(sp)
    8000700e:	e06a                	sd	s10,0(sp)
    80007010:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80007012:	00b56933          	or	s2,a0,a1
    80007016:	00f97913          	andi	s2,s2,15
    8000701a:	04091263          	bnez	s2,8000705e <bd_mark+0x68>
    8000701e:	8b2a                	mv	s6,a0
    80007020:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80007022:	0002dc17          	auipc	s8,0x2d
    80007026:	036c2c03          	lw	s8,54(s8) # 80034058 <nsizes>
    8000702a:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    8000702c:	0002dd17          	auipc	s10,0x2d
    80007030:	01cd0d13          	addi	s10,s10,28 # 80034048 <bd_base>
  return n / BLK_SIZE(k);
    80007034:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80007036:	0002da97          	auipc	s5,0x2d
    8000703a:	01aa8a93          	addi	s5,s5,26 # 80034050 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    8000703e:	07804563          	bgtz	s8,800070a8 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80007042:	60e6                	ld	ra,88(sp)
    80007044:	6446                	ld	s0,80(sp)
    80007046:	64a6                	ld	s1,72(sp)
    80007048:	6906                	ld	s2,64(sp)
    8000704a:	79e2                	ld	s3,56(sp)
    8000704c:	7a42                	ld	s4,48(sp)
    8000704e:	7aa2                	ld	s5,40(sp)
    80007050:	7b02                	ld	s6,32(sp)
    80007052:	6be2                	ld	s7,24(sp)
    80007054:	6c42                	ld	s8,16(sp)
    80007056:	6ca2                	ld	s9,8(sp)
    80007058:	6d02                	ld	s10,0(sp)
    8000705a:	6125                	addi	sp,sp,96
    8000705c:	8082                	ret
    panic("bd_mark");
    8000705e:	00002517          	auipc	a0,0x2
    80007062:	b8250513          	addi	a0,a0,-1150 # 80008be0 <userret+0xb50>
    80007066:	ffff9097          	auipc	ra,0xffff9
    8000706a:	4e2080e7          	jalr	1250(ra) # 80000548 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    8000706e:	000ab783          	ld	a5,0(s5)
    80007072:	97ca                	add	a5,a5,s2
    80007074:	85a6                	mv	a1,s1
    80007076:	6b88                	ld	a0,16(a5)
    80007078:	00000097          	auipc	ra,0x0
    8000707c:	976080e7          	jalr	-1674(ra) # 800069ee <bit_set>
    for(; bi < bj; bi++) {
    80007080:	2485                	addiw	s1,s1,1
    80007082:	009a0e63          	beq	s4,s1,8000709e <bd_mark+0xa8>
      if(k > 0) {
    80007086:	ff3054e3          	blez	s3,8000706e <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    8000708a:	000ab783          	ld	a5,0(s5)
    8000708e:	97ca                	add	a5,a5,s2
    80007090:	85a6                	mv	a1,s1
    80007092:	6f88                	ld	a0,24(a5)
    80007094:	00000097          	auipc	ra,0x0
    80007098:	95a080e7          	jalr	-1702(ra) # 800069ee <bit_set>
    8000709c:	bfc9                	j	8000706e <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    8000709e:	2985                	addiw	s3,s3,1
    800070a0:	02090913          	addi	s2,s2,32
    800070a4:	f9898fe3          	beq	s3,s8,80007042 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    800070a8:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    800070ac:	409b04bb          	subw	s1,s6,s1
    800070b0:	013c97b3          	sll	a5,s9,s3
    800070b4:	02f4c4b3          	div	s1,s1,a5
    800070b8:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    800070ba:	85de                	mv	a1,s7
    800070bc:	854e                	mv	a0,s3
    800070be:	00000097          	auipc	ra,0x0
    800070c2:	eec080e7          	jalr	-276(ra) # 80006faa <blk_index_next>
    800070c6:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    800070c8:	faa4cfe3          	blt	s1,a0,80007086 <bd_mark+0x90>
    800070cc:	bfc9                	j	8000709e <bd_mark+0xa8>

00000000800070ce <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    800070ce:	7139                	addi	sp,sp,-64
    800070d0:	fc06                	sd	ra,56(sp)
    800070d2:	f822                	sd	s0,48(sp)
    800070d4:	f426                	sd	s1,40(sp)
    800070d6:	f04a                	sd	s2,32(sp)
    800070d8:	ec4e                	sd	s3,24(sp)
    800070da:	e852                	sd	s4,16(sp)
    800070dc:	e456                	sd	s5,8(sp)
    800070de:	e05a                	sd	s6,0(sp)
    800070e0:	0080                	addi	s0,sp,64
    800070e2:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800070e4:	00058a9b          	sext.w	s5,a1
    800070e8:	0015f793          	andi	a5,a1,1
    800070ec:	ebad                	bnez	a5,8000715e <bd_initfree_pair+0x90>
    800070ee:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    800070f2:	00599493          	slli	s1,s3,0x5
    800070f6:	0002d797          	auipc	a5,0x2d
    800070fa:	f5a7b783          	ld	a5,-166(a5) # 80034050 <bd_sizes>
    800070fe:	94be                	add	s1,s1,a5
    80007100:	0104bb03          	ld	s6,16(s1)
    80007104:	855a                	mv	a0,s6
    80007106:	00000097          	auipc	ra,0x0
    8000710a:	8b0080e7          	jalr	-1872(ra) # 800069b6 <bit_isset>
    8000710e:	892a                	mv	s2,a0
    80007110:	85d2                	mv	a1,s4
    80007112:	855a                	mv	a0,s6
    80007114:	00000097          	auipc	ra,0x0
    80007118:	8a2080e7          	jalr	-1886(ra) # 800069b6 <bit_isset>
  int free = 0;
    8000711c:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    8000711e:	02a90563          	beq	s2,a0,80007148 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80007122:	45c1                	li	a1,16
    80007124:	013599b3          	sll	s3,a1,s3
    80007128:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    8000712c:	02090c63          	beqz	s2,80007164 <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80007130:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80007134:	0002d597          	auipc	a1,0x2d
    80007138:	f145b583          	ld	a1,-236(a1) # 80034048 <bd_base>
    8000713c:	95ce                	add	a1,a1,s3
    8000713e:	8526                	mv	a0,s1
    80007140:	00000097          	auipc	ra,0x0
    80007144:	48e080e7          	jalr	1166(ra) # 800075ce <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80007148:	855a                	mv	a0,s6
    8000714a:	70e2                	ld	ra,56(sp)
    8000714c:	7442                	ld	s0,48(sp)
    8000714e:	74a2                	ld	s1,40(sp)
    80007150:	7902                	ld	s2,32(sp)
    80007152:	69e2                	ld	s3,24(sp)
    80007154:	6a42                	ld	s4,16(sp)
    80007156:	6aa2                	ld	s5,8(sp)
    80007158:	6b02                	ld	s6,0(sp)
    8000715a:	6121                	addi	sp,sp,64
    8000715c:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    8000715e:	fff58a1b          	addiw	s4,a1,-1
    80007162:	bf41                	j	800070f2 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80007164:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80007168:	0002d597          	auipc	a1,0x2d
    8000716c:	ee05b583          	ld	a1,-288(a1) # 80034048 <bd_base>
    80007170:	95ce                	add	a1,a1,s3
    80007172:	8526                	mv	a0,s1
    80007174:	00000097          	auipc	ra,0x0
    80007178:	45a080e7          	jalr	1114(ra) # 800075ce <lst_push>
    8000717c:	b7f1                	j	80007148 <bd_initfree_pair+0x7a>

000000008000717e <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    8000717e:	711d                	addi	sp,sp,-96
    80007180:	ec86                	sd	ra,88(sp)
    80007182:	e8a2                	sd	s0,80(sp)
    80007184:	e4a6                	sd	s1,72(sp)
    80007186:	e0ca                	sd	s2,64(sp)
    80007188:	fc4e                	sd	s3,56(sp)
    8000718a:	f852                	sd	s4,48(sp)
    8000718c:	f456                	sd	s5,40(sp)
    8000718e:	f05a                	sd	s6,32(sp)
    80007190:	ec5e                	sd	s7,24(sp)
    80007192:	e862                	sd	s8,16(sp)
    80007194:	e466                	sd	s9,8(sp)
    80007196:	e06a                	sd	s10,0(sp)
    80007198:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    8000719a:	0002d717          	auipc	a4,0x2d
    8000719e:	ebe72703          	lw	a4,-322(a4) # 80034058 <nsizes>
    800071a2:	4785                	li	a5,1
    800071a4:	06e7db63          	bge	a5,a4,8000721a <bd_initfree+0x9c>
    800071a8:	8aaa                	mv	s5,a0
    800071aa:	8b2e                	mv	s6,a1
    800071ac:	4901                	li	s2,0
  int free = 0;
    800071ae:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    800071b0:	0002dc97          	auipc	s9,0x2d
    800071b4:	e98c8c93          	addi	s9,s9,-360 # 80034048 <bd_base>
  return n / BLK_SIZE(k);
    800071b8:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    800071ba:	0002db97          	auipc	s7,0x2d
    800071be:	e9eb8b93          	addi	s7,s7,-354 # 80034058 <nsizes>
    800071c2:	a039                	j	800071d0 <bd_initfree+0x52>
    800071c4:	2905                	addiw	s2,s2,1
    800071c6:	000ba783          	lw	a5,0(s7)
    800071ca:	37fd                	addiw	a5,a5,-1
    800071cc:	04f95863          	bge	s2,a5,8000721c <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    800071d0:	85d6                	mv	a1,s5
    800071d2:	854a                	mv	a0,s2
    800071d4:	00000097          	auipc	ra,0x0
    800071d8:	dd6080e7          	jalr	-554(ra) # 80006faa <blk_index_next>
    800071dc:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    800071de:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    800071e2:	409b04bb          	subw	s1,s6,s1
    800071e6:	012c17b3          	sll	a5,s8,s2
    800071ea:	02f4c4b3          	div	s1,s1,a5
    800071ee:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    800071f0:	85aa                	mv	a1,a0
    800071f2:	854a                	mv	a0,s2
    800071f4:	00000097          	auipc	ra,0x0
    800071f8:	eda080e7          	jalr	-294(ra) # 800070ce <bd_initfree_pair>
    800071fc:	01450d3b          	addw	s10,a0,s4
    80007200:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80007204:	fc99d0e3          	bge	s3,s1,800071c4 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80007208:	85a6                	mv	a1,s1
    8000720a:	854a                	mv	a0,s2
    8000720c:	00000097          	auipc	ra,0x0
    80007210:	ec2080e7          	jalr	-318(ra) # 800070ce <bd_initfree_pair>
    80007214:	00ad0a3b          	addw	s4,s10,a0
    80007218:	b775                	j	800071c4 <bd_initfree+0x46>
  int free = 0;
    8000721a:	4a01                	li	s4,0
  }
  return free;
}
    8000721c:	8552                	mv	a0,s4
    8000721e:	60e6                	ld	ra,88(sp)
    80007220:	6446                	ld	s0,80(sp)
    80007222:	64a6                	ld	s1,72(sp)
    80007224:	6906                	ld	s2,64(sp)
    80007226:	79e2                	ld	s3,56(sp)
    80007228:	7a42                	ld	s4,48(sp)
    8000722a:	7aa2                	ld	s5,40(sp)
    8000722c:	7b02                	ld	s6,32(sp)
    8000722e:	6be2                	ld	s7,24(sp)
    80007230:	6c42                	ld	s8,16(sp)
    80007232:	6ca2                	ld	s9,8(sp)
    80007234:	6d02                	ld	s10,0(sp)
    80007236:	6125                	addi	sp,sp,96
    80007238:	8082                	ret

000000008000723a <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    8000723a:	7179                	addi	sp,sp,-48
    8000723c:	f406                	sd	ra,40(sp)
    8000723e:	f022                	sd	s0,32(sp)
    80007240:	ec26                	sd	s1,24(sp)
    80007242:	e84a                	sd	s2,16(sp)
    80007244:	e44e                	sd	s3,8(sp)
    80007246:	1800                	addi	s0,sp,48
    80007248:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    8000724a:	0002d997          	auipc	s3,0x2d
    8000724e:	dfe98993          	addi	s3,s3,-514 # 80034048 <bd_base>
    80007252:	0009b483          	ld	s1,0(s3)
    80007256:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    8000725a:	0002d797          	auipc	a5,0x2d
    8000725e:	dfe7a783          	lw	a5,-514(a5) # 80034058 <nsizes>
    80007262:	37fd                	addiw	a5,a5,-1
    80007264:	4641                	li	a2,16
    80007266:	00f61633          	sll	a2,a2,a5
    8000726a:	85a6                	mv	a1,s1
    8000726c:	00002517          	auipc	a0,0x2
    80007270:	97c50513          	addi	a0,a0,-1668 # 80008be8 <userret+0xb58>
    80007274:	ffff9097          	auipc	ra,0xffff9
    80007278:	32e080e7          	jalr	814(ra) # 800005a2 <printf>
  bd_mark(bd_base, p);
    8000727c:	85ca                	mv	a1,s2
    8000727e:	0009b503          	ld	a0,0(s3)
    80007282:	00000097          	auipc	ra,0x0
    80007286:	d74080e7          	jalr	-652(ra) # 80006ff6 <bd_mark>
  return meta;
}
    8000728a:	8526                	mv	a0,s1
    8000728c:	70a2                	ld	ra,40(sp)
    8000728e:	7402                	ld	s0,32(sp)
    80007290:	64e2                	ld	s1,24(sp)
    80007292:	6942                	ld	s2,16(sp)
    80007294:	69a2                	ld	s3,8(sp)
    80007296:	6145                	addi	sp,sp,48
    80007298:	8082                	ret

000000008000729a <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    8000729a:	1101                	addi	sp,sp,-32
    8000729c:	ec06                	sd	ra,24(sp)
    8000729e:	e822                	sd	s0,16(sp)
    800072a0:	e426                	sd	s1,8(sp)
    800072a2:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    800072a4:	0002d497          	auipc	s1,0x2d
    800072a8:	db44a483          	lw	s1,-588(s1) # 80034058 <nsizes>
    800072ac:	fff4879b          	addiw	a5,s1,-1
    800072b0:	44c1                	li	s1,16
    800072b2:	00f494b3          	sll	s1,s1,a5
    800072b6:	0002d797          	auipc	a5,0x2d
    800072ba:	d927b783          	ld	a5,-622(a5) # 80034048 <bd_base>
    800072be:	8d1d                	sub	a0,a0,a5
    800072c0:	40a4853b          	subw	a0,s1,a0
    800072c4:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    800072c8:	00905a63          	blez	s1,800072dc <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    800072cc:	357d                	addiw	a0,a0,-1
    800072ce:	41f5549b          	sraiw	s1,a0,0x1f
    800072d2:	01c4d49b          	srliw	s1,s1,0x1c
    800072d6:	9ca9                	addw	s1,s1,a0
    800072d8:	98c1                	andi	s1,s1,-16
    800072da:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    800072dc:	85a6                	mv	a1,s1
    800072de:	00002517          	auipc	a0,0x2
    800072e2:	94250513          	addi	a0,a0,-1726 # 80008c20 <userret+0xb90>
    800072e6:	ffff9097          	auipc	ra,0xffff9
    800072ea:	2bc080e7          	jalr	700(ra) # 800005a2 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    800072ee:	0002d717          	auipc	a4,0x2d
    800072f2:	d5a73703          	ld	a4,-678(a4) # 80034048 <bd_base>
    800072f6:	0002d597          	auipc	a1,0x2d
    800072fa:	d625a583          	lw	a1,-670(a1) # 80034058 <nsizes>
    800072fe:	fff5879b          	addiw	a5,a1,-1
    80007302:	45c1                	li	a1,16
    80007304:	00f595b3          	sll	a1,a1,a5
    80007308:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    8000730c:	95ba                	add	a1,a1,a4
    8000730e:	953a                	add	a0,a0,a4
    80007310:	00000097          	auipc	ra,0x0
    80007314:	ce6080e7          	jalr	-794(ra) # 80006ff6 <bd_mark>
  return unavailable;
}
    80007318:	8526                	mv	a0,s1
    8000731a:	60e2                	ld	ra,24(sp)
    8000731c:	6442                	ld	s0,16(sp)
    8000731e:	64a2                	ld	s1,8(sp)
    80007320:	6105                	addi	sp,sp,32
    80007322:	8082                	ret

0000000080007324 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80007324:	715d                	addi	sp,sp,-80
    80007326:	e486                	sd	ra,72(sp)
    80007328:	e0a2                	sd	s0,64(sp)
    8000732a:	fc26                	sd	s1,56(sp)
    8000732c:	f84a                	sd	s2,48(sp)
    8000732e:	f44e                	sd	s3,40(sp)
    80007330:	f052                	sd	s4,32(sp)
    80007332:	ec56                	sd	s5,24(sp)
    80007334:	e85a                	sd	s6,16(sp)
    80007336:	e45e                	sd	s7,8(sp)
    80007338:	e062                	sd	s8,0(sp)
    8000733a:	0880                	addi	s0,sp,80
    8000733c:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    8000733e:	fff50493          	addi	s1,a0,-1
    80007342:	98c1                	andi	s1,s1,-16
    80007344:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80007346:	00002597          	auipc	a1,0x2
    8000734a:	8fa58593          	addi	a1,a1,-1798 # 80008c40 <userret+0xbb0>
    8000734e:	0002d517          	auipc	a0,0x2d
    80007352:	cb250513          	addi	a0,a0,-846 # 80034000 <lock>
    80007356:	ffff9097          	auipc	ra,0xffff9
    8000735a:	7f8080e7          	jalr	2040(ra) # 80000b4e <initlock>
  bd_base = (void *) p;
    8000735e:	0002d797          	auipc	a5,0x2d
    80007362:	ce97b523          	sd	s1,-790(a5) # 80034048 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007366:	409c0933          	sub	s2,s8,s1
    8000736a:	43f95513          	srai	a0,s2,0x3f
    8000736e:	893d                	andi	a0,a0,15
    80007370:	954a                	add	a0,a0,s2
    80007372:	8511                	srai	a0,a0,0x4
    80007374:	00000097          	auipc	ra,0x0
    80007378:	c60080e7          	jalr	-928(ra) # 80006fd4 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    8000737c:	47c1                	li	a5,16
    8000737e:	00a797b3          	sll	a5,a5,a0
    80007382:	1b27c663          	blt	a5,s2,8000752e <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007386:	2505                	addiw	a0,a0,1
    80007388:	0002d797          	auipc	a5,0x2d
    8000738c:	cca7a823          	sw	a0,-816(a5) # 80034058 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80007390:	0002d997          	auipc	s3,0x2d
    80007394:	cc898993          	addi	s3,s3,-824 # 80034058 <nsizes>
    80007398:	0009a603          	lw	a2,0(s3)
    8000739c:	85ca                	mv	a1,s2
    8000739e:	00002517          	auipc	a0,0x2
    800073a2:	8aa50513          	addi	a0,a0,-1878 # 80008c48 <userret+0xbb8>
    800073a6:	ffff9097          	auipc	ra,0xffff9
    800073aa:	1fc080e7          	jalr	508(ra) # 800005a2 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    800073ae:	0002d797          	auipc	a5,0x2d
    800073b2:	ca97b123          	sd	s1,-862(a5) # 80034050 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    800073b6:	0009a603          	lw	a2,0(s3)
    800073ba:	00561913          	slli	s2,a2,0x5
    800073be:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    800073c0:	0056161b          	slliw	a2,a2,0x5
    800073c4:	4581                	li	a1,0
    800073c6:	8526                	mv	a0,s1
    800073c8:	ffffa097          	auipc	ra,0xffffa
    800073cc:	b3e080e7          	jalr	-1218(ra) # 80000f06 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    800073d0:	0009a783          	lw	a5,0(s3)
    800073d4:	06f05a63          	blez	a5,80007448 <bd_init+0x124>
    800073d8:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    800073da:	0002da97          	auipc	s5,0x2d
    800073de:	c76a8a93          	addi	s5,s5,-906 # 80034050 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800073e2:	0002da17          	auipc	s4,0x2d
    800073e6:	c76a0a13          	addi	s4,s4,-906 # 80034058 <nsizes>
    800073ea:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    800073ec:	00599b93          	slli	s7,s3,0x5
    800073f0:	000ab503          	ld	a0,0(s5)
    800073f4:	955e                	add	a0,a0,s7
    800073f6:	00000097          	auipc	ra,0x0
    800073fa:	166080e7          	jalr	358(ra) # 8000755c <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800073fe:	000a2483          	lw	s1,0(s4)
    80007402:	34fd                	addiw	s1,s1,-1
    80007404:	413484bb          	subw	s1,s1,s3
    80007408:	009b14bb          	sllw	s1,s6,s1
    8000740c:	fff4879b          	addiw	a5,s1,-1
    80007410:	41f7d49b          	sraiw	s1,a5,0x1f
    80007414:	01d4d49b          	srliw	s1,s1,0x1d
    80007418:	9cbd                	addw	s1,s1,a5
    8000741a:	98e1                	andi	s1,s1,-8
    8000741c:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    8000741e:	000ab783          	ld	a5,0(s5)
    80007422:	9bbe                	add	s7,s7,a5
    80007424:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80007428:	848d                	srai	s1,s1,0x3
    8000742a:	8626                	mv	a2,s1
    8000742c:	4581                	li	a1,0
    8000742e:	854a                	mv	a0,s2
    80007430:	ffffa097          	auipc	ra,0xffffa
    80007434:	ad6080e7          	jalr	-1322(ra) # 80000f06 <memset>
    p += sz;
    80007438:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    8000743a:	0985                	addi	s3,s3,1
    8000743c:	000a2703          	lw	a4,0(s4)
    80007440:	0009879b          	sext.w	a5,s3
    80007444:	fae7c4e3          	blt	a5,a4,800073ec <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80007448:	0002d797          	auipc	a5,0x2d
    8000744c:	c107a783          	lw	a5,-1008(a5) # 80034058 <nsizes>
    80007450:	4705                	li	a4,1
    80007452:	06f75163          	bge	a4,a5,800074b4 <bd_init+0x190>
    80007456:	02000a13          	li	s4,32
    8000745a:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000745c:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    8000745e:	0002db17          	auipc	s6,0x2d
    80007462:	bf2b0b13          	addi	s6,s6,-1038 # 80034050 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80007466:	0002da97          	auipc	s5,0x2d
    8000746a:	bf2a8a93          	addi	s5,s5,-1038 # 80034058 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000746e:	37fd                	addiw	a5,a5,-1
    80007470:	413787bb          	subw	a5,a5,s3
    80007474:	00fb94bb          	sllw	s1,s7,a5
    80007478:	fff4879b          	addiw	a5,s1,-1
    8000747c:	41f7d49b          	sraiw	s1,a5,0x1f
    80007480:	01d4d49b          	srliw	s1,s1,0x1d
    80007484:	9cbd                	addw	s1,s1,a5
    80007486:	98e1                	andi	s1,s1,-8
    80007488:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    8000748a:	000b3783          	ld	a5,0(s6)
    8000748e:	97d2                	add	a5,a5,s4
    80007490:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80007494:	848d                	srai	s1,s1,0x3
    80007496:	8626                	mv	a2,s1
    80007498:	4581                	li	a1,0
    8000749a:	854a                	mv	a0,s2
    8000749c:	ffffa097          	auipc	ra,0xffffa
    800074a0:	a6a080e7          	jalr	-1430(ra) # 80000f06 <memset>
    p += sz;
    800074a4:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    800074a6:	2985                	addiw	s3,s3,1
    800074a8:	000aa783          	lw	a5,0(s5)
    800074ac:	020a0a13          	addi	s4,s4,32
    800074b0:	faf9cfe3          	blt	s3,a5,8000746e <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    800074b4:	197d                	addi	s2,s2,-1
    800074b6:	ff097913          	andi	s2,s2,-16
    800074ba:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    800074bc:	854a                	mv	a0,s2
    800074be:	00000097          	auipc	ra,0x0
    800074c2:	d7c080e7          	jalr	-644(ra) # 8000723a <bd_mark_data_structures>
    800074c6:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    800074c8:	85ca                	mv	a1,s2
    800074ca:	8562                	mv	a0,s8
    800074cc:	00000097          	auipc	ra,0x0
    800074d0:	dce080e7          	jalr	-562(ra) # 8000729a <bd_mark_unavailable>
    800074d4:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    800074d6:	0002da97          	auipc	s5,0x2d
    800074da:	b82a8a93          	addi	s5,s5,-1150 # 80034058 <nsizes>
    800074de:	000aa783          	lw	a5,0(s5)
    800074e2:	37fd                	addiw	a5,a5,-1
    800074e4:	44c1                	li	s1,16
    800074e6:	00f497b3          	sll	a5,s1,a5
    800074ea:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    800074ec:	0002d597          	auipc	a1,0x2d
    800074f0:	b5c5b583          	ld	a1,-1188(a1) # 80034048 <bd_base>
    800074f4:	95be                	add	a1,a1,a5
    800074f6:	854a                	mv	a0,s2
    800074f8:	00000097          	auipc	ra,0x0
    800074fc:	c86080e7          	jalr	-890(ra) # 8000717e <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80007500:	000aa603          	lw	a2,0(s5)
    80007504:	367d                	addiw	a2,a2,-1
    80007506:	00c49633          	sll	a2,s1,a2
    8000750a:	41460633          	sub	a2,a2,s4
    8000750e:	41360633          	sub	a2,a2,s3
    80007512:	02c51463          	bne	a0,a2,8000753a <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80007516:	60a6                	ld	ra,72(sp)
    80007518:	6406                	ld	s0,64(sp)
    8000751a:	74e2                	ld	s1,56(sp)
    8000751c:	7942                	ld	s2,48(sp)
    8000751e:	79a2                	ld	s3,40(sp)
    80007520:	7a02                	ld	s4,32(sp)
    80007522:	6ae2                	ld	s5,24(sp)
    80007524:	6b42                	ld	s6,16(sp)
    80007526:	6ba2                	ld	s7,8(sp)
    80007528:	6c02                	ld	s8,0(sp)
    8000752a:	6161                	addi	sp,sp,80
    8000752c:	8082                	ret
    nsizes++;  // round up to the next power of 2
    8000752e:	2509                	addiw	a0,a0,2
    80007530:	0002d797          	auipc	a5,0x2d
    80007534:	b2a7a423          	sw	a0,-1240(a5) # 80034058 <nsizes>
    80007538:	bda1                	j	80007390 <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    8000753a:	85aa                	mv	a1,a0
    8000753c:	00001517          	auipc	a0,0x1
    80007540:	74c50513          	addi	a0,a0,1868 # 80008c88 <userret+0xbf8>
    80007544:	ffff9097          	auipc	ra,0xffff9
    80007548:	05e080e7          	jalr	94(ra) # 800005a2 <printf>
    panic("bd_init: free mem");
    8000754c:	00001517          	auipc	a0,0x1
    80007550:	74c50513          	addi	a0,a0,1868 # 80008c98 <userret+0xc08>
    80007554:	ffff9097          	auipc	ra,0xffff9
    80007558:	ff4080e7          	jalr	-12(ra) # 80000548 <panic>

000000008000755c <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    8000755c:	1141                	addi	sp,sp,-16
    8000755e:	e422                	sd	s0,8(sp)
    80007560:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007562:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80007564:	e508                	sd	a0,8(a0)
}
    80007566:	6422                	ld	s0,8(sp)
    80007568:	0141                	addi	sp,sp,16
    8000756a:	8082                	ret

000000008000756c <lst_empty>:

int
lst_empty(struct list *lst) {
    8000756c:	1141                	addi	sp,sp,-16
    8000756e:	e422                	sd	s0,8(sp)
    80007570:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007572:	611c                	ld	a5,0(a0)
    80007574:	40a78533          	sub	a0,a5,a0
}
    80007578:	00153513          	seqz	a0,a0
    8000757c:	6422                	ld	s0,8(sp)
    8000757e:	0141                	addi	sp,sp,16
    80007580:	8082                	ret

0000000080007582 <lst_remove>:

void
lst_remove(struct list *e) {
    80007582:	1141                	addi	sp,sp,-16
    80007584:	e422                	sd	s0,8(sp)
    80007586:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007588:	6518                	ld	a4,8(a0)
    8000758a:	611c                	ld	a5,0(a0)
    8000758c:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    8000758e:	6518                	ld	a4,8(a0)
    80007590:	e798                	sd	a4,8(a5)
}
    80007592:	6422                	ld	s0,8(sp)
    80007594:	0141                	addi	sp,sp,16
    80007596:	8082                	ret

0000000080007598 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007598:	1101                	addi	sp,sp,-32
    8000759a:	ec06                	sd	ra,24(sp)
    8000759c:	e822                	sd	s0,16(sp)
    8000759e:	e426                	sd	s1,8(sp)
    800075a0:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    800075a2:	6104                	ld	s1,0(a0)
    800075a4:	00a48d63          	beq	s1,a0,800075be <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    800075a8:	8526                	mv	a0,s1
    800075aa:	00000097          	auipc	ra,0x0
    800075ae:	fd8080e7          	jalr	-40(ra) # 80007582 <lst_remove>
  return (void *)p;
}
    800075b2:	8526                	mv	a0,s1
    800075b4:	60e2                	ld	ra,24(sp)
    800075b6:	6442                	ld	s0,16(sp)
    800075b8:	64a2                	ld	s1,8(sp)
    800075ba:	6105                	addi	sp,sp,32
    800075bc:	8082                	ret
    panic("lst_pop");
    800075be:	00001517          	auipc	a0,0x1
    800075c2:	6f250513          	addi	a0,a0,1778 # 80008cb0 <userret+0xc20>
    800075c6:	ffff9097          	auipc	ra,0xffff9
    800075ca:	f82080e7          	jalr	-126(ra) # 80000548 <panic>

00000000800075ce <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    800075ce:	1141                	addi	sp,sp,-16
    800075d0:	e422                	sd	s0,8(sp)
    800075d2:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    800075d4:	611c                	ld	a5,0(a0)
    800075d6:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    800075d8:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    800075da:	611c                	ld	a5,0(a0)
    800075dc:	e78c                	sd	a1,8(a5)
  lst->next = e;
    800075de:	e10c                	sd	a1,0(a0)
}
    800075e0:	6422                	ld	s0,8(sp)
    800075e2:	0141                	addi	sp,sp,16
    800075e4:	8082                	ret

00000000800075e6 <lst_print>:

void
lst_print(struct list *lst)
{
    800075e6:	7179                	addi	sp,sp,-48
    800075e8:	f406                	sd	ra,40(sp)
    800075ea:	f022                	sd	s0,32(sp)
    800075ec:	ec26                	sd	s1,24(sp)
    800075ee:	e84a                	sd	s2,16(sp)
    800075f0:	e44e                	sd	s3,8(sp)
    800075f2:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800075f4:	6104                	ld	s1,0(a0)
    800075f6:	02950063          	beq	a0,s1,80007616 <lst_print+0x30>
    800075fa:	892a                	mv	s2,a0
    printf(" %p", p);
    800075fc:	00001997          	auipc	s3,0x1
    80007600:	6bc98993          	addi	s3,s3,1724 # 80008cb8 <userret+0xc28>
    80007604:	85a6                	mv	a1,s1
    80007606:	854e                	mv	a0,s3
    80007608:	ffff9097          	auipc	ra,0xffff9
    8000760c:	f9a080e7          	jalr	-102(ra) # 800005a2 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007610:	6084                	ld	s1,0(s1)
    80007612:	fe9919e3          	bne	s2,s1,80007604 <lst_print+0x1e>
  }
  printf("\n");
    80007616:	00001517          	auipc	a0,0x1
    8000761a:	fba50513          	addi	a0,a0,-70 # 800085d0 <userret+0x540>
    8000761e:	ffff9097          	auipc	ra,0xffff9
    80007622:	f84080e7          	jalr	-124(ra) # 800005a2 <printf>
}
    80007626:	70a2                	ld	ra,40(sp)
    80007628:	7402                	ld	s0,32(sp)
    8000762a:	64e2                	ld	s1,24(sp)
    8000762c:	6942                	ld	s2,16(sp)
    8000762e:	69a2                	ld	s3,8(sp)
    80007630:	6145                	addi	sp,sp,48
    80007632:	8082                	ret
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
