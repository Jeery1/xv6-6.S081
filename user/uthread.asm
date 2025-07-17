
user/_uthread:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <thread_init>:
struct thread *current_thread;
extern void thread_switch(uint64, uint64);
              
void 
thread_init(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
   6:	00001797          	auipc	a5,0x1
   a:	d6a78793          	addi	a5,a5,-662 # d70 <all_thread>
   e:	00001717          	auipc	a4,0x1
  12:	d4f73923          	sd	a5,-686(a4) # d60 <current_thread>
  current_thread->state = RUNNING;
  16:	4785                	li	a5,1
  18:	00003717          	auipc	a4,0x3
  1c:	dcf72423          	sw	a5,-568(a4) # 2de0 <__global_pointer$+0x189f>
}
  20:	6422                	ld	s0,8(sp)
  22:	0141                	addi	sp,sp,16
  24:	8082                	ret

0000000000000026 <thread_schedule>:

void 
thread_schedule(void)
{
  26:	1141                	addi	sp,sp,-16
  28:	e406                	sd	ra,8(sp)
  2a:	e022                	sd	s0,0(sp)
  2c:	0800                	addi	s0,sp,16
  struct thread *t, *next_thread;

  /* Find another runnable thread. */
  next_thread = 0;
  t = current_thread + 1;
  2e:	00001517          	auipc	a0,0x1
  32:	d3253503          	ld	a0,-718(a0) # d60 <current_thread>
  36:	6589                	lui	a1,0x2
  38:	07858593          	addi	a1,a1,120 # 2078 <__global_pointer$+0xb37>
  3c:	95aa                	add	a1,a1,a0
  3e:	4791                	li	a5,4
  for(int i = 0; i < MAX_THREAD; i++){
    if(t >= all_thread + MAX_THREAD)
  40:	00009817          	auipc	a6,0x9
  44:	f1080813          	addi	a6,a6,-240 # 8f50 <base>
      t = all_thread;
    if(t->state == RUNNABLE) {
  48:	6689                	lui	a3,0x2
  4a:	4609                	li	a2,2
      next_thread = t;
      break;
    }
    t = t + 1;
  4c:	07868893          	addi	a7,a3,120 # 2078 <__global_pointer$+0xb37>
  50:	a809                	j	62 <thread_schedule+0x3c>
    if(t->state == RUNNABLE) {
  52:	00d58733          	add	a4,a1,a3
  56:	5b38                	lw	a4,112(a4)
  58:	02c70963          	beq	a4,a2,8a <thread_schedule+0x64>
    t = t + 1;
  5c:	95c6                	add	a1,a1,a7
  for(int i = 0; i < MAX_THREAD; i++){
  5e:	37fd                	addiw	a5,a5,-1
  60:	cb81                	beqz	a5,70 <thread_schedule+0x4a>
    if(t >= all_thread + MAX_THREAD)
  62:	ff05e8e3          	bltu	a1,a6,52 <thread_schedule+0x2c>
      t = all_thread;
  66:	00001597          	auipc	a1,0x1
  6a:	d0a58593          	addi	a1,a1,-758 # d70 <all_thread>
  6e:	b7d5                	j	52 <thread_schedule+0x2c>
  }

  if (next_thread == 0) {
    printf("thread_schedule: no runnable threads\n");
  70:	00001517          	auipc	a0,0x1
  74:	bb850513          	addi	a0,a0,-1096 # c28 <malloc+0xe6>
  78:	00001097          	auipc	ra,0x1
  7c:	a0c080e7          	jalr	-1524(ra) # a84 <printf>
    exit(-1);
  80:	557d                	li	a0,-1
  82:	00000097          	auipc	ra,0x0
  86:	65a080e7          	jalr	1626(ra) # 6dc <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  8a:	00b50e63          	beq	a0,a1,a6 <thread_schedule+0x80>
    next_thread->state = RUNNING;
  8e:	6789                	lui	a5,0x2
  90:	97ae                	add	a5,a5,a1
  92:	4705                	li	a4,1
  94:	dbb8                	sw	a4,112(a5)
    t = current_thread;
    current_thread = next_thread;
  96:	00001797          	auipc	a5,0x1
  9a:	ccb7b523          	sd	a1,-822(a5) # d60 <current_thread>
     * thread_switch(??, ??);
     */
    /** 
     * My Implementatioon
     */
    thread_switch((uint64)t, (uint64)next_thread);
  9e:	00000097          	auipc	ra,0x0
  a2:	366080e7          	jalr	870(ra) # 404 <thread_switch>
  } else
    next_thread = 0;
}
  a6:	60a2                	ld	ra,8(sp)
  a8:	6402                	ld	s0,0(sp)
  aa:	0141                	addi	sp,sp,16
  ac:	8082                	ret

00000000000000ae <thread_create>:

void 
thread_create(void (*func)())
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e422                	sd	s0,8(sp)
  b2:	0800                	addi	s0,sp,16
  struct thread *t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  b4:	00001797          	auipc	a5,0x1
  b8:	cbc78793          	addi	a5,a5,-836 # d70 <all_thread>
    if (t->state == FREE) break;
  bc:	6709                	lui	a4,0x2
  be:	07070613          	addi	a2,a4,112 # 2070 <__global_pointer$+0xb2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  c2:	07870713          	addi	a4,a4,120
  c6:	00009597          	auipc	a1,0x9
  ca:	e8a58593          	addi	a1,a1,-374 # 8f50 <base>
    if (t->state == FREE) break;
  ce:	00c786b3          	add	a3,a5,a2
  d2:	4294                	lw	a3,0(a3)
  d4:	c681                	beqz	a3,dc <thread_create+0x2e>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  d6:	97ba                	add	a5,a5,a4
  d8:	feb79be3          	bne	a5,a1,ce <thread_create+0x20>
  }
  t->state = RUNNABLE;
  dc:	6709                	lui	a4,0x2
  de:	00e786b3          	add	a3,a5,a4
  e2:	4609                	li	a2,2
  e4:	dab0                	sw	a2,112(a3)
  // YOUR CODE HERE
  t->ra = (uint64)func;
  e6:	e388                	sd	a0,0(a5)
  /** 栈是倒着生长 —— addi sp, sp, -STACK_SIZE  */
  t->sp = (uint64)(t->stack + STACK_SIZE);
  e8:	07070713          	addi	a4,a4,112 # 2070 <__global_pointer$+0xb2f>
  ec:	973e                	add	a4,a4,a5
  ee:	e798                	sd	a4,8(a5)
}
  f0:	6422                	ld	s0,8(sp)
  f2:	0141                	addi	sp,sp,16
  f4:	8082                	ret

00000000000000f6 <thread_yield>:

void 
thread_yield(void)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e406                	sd	ra,8(sp)
  fa:	e022                	sd	s0,0(sp)
  fc:	0800                	addi	s0,sp,16
  current_thread->state = RUNNABLE;
  fe:	00001797          	auipc	a5,0x1
 102:	c627b783          	ld	a5,-926(a5) # d60 <current_thread>
 106:	6709                	lui	a4,0x2
 108:	97ba                	add	a5,a5,a4
 10a:	4709                	li	a4,2
 10c:	dbb8                	sw	a4,112(a5)
  thread_schedule();
 10e:	00000097          	auipc	ra,0x0
 112:	f18080e7          	jalr	-232(ra) # 26 <thread_schedule>
}
 116:	60a2                	ld	ra,8(sp)
 118:	6402                	ld	s0,0(sp)
 11a:	0141                	addi	sp,sp,16
 11c:	8082                	ret

000000000000011e <thread_a>:
volatile int a_started, b_started, c_started;
volatile int a_n, b_n, c_n;

void 
thread_a(void)
{
 11e:	7179                	addi	sp,sp,-48
 120:	f406                	sd	ra,40(sp)
 122:	f022                	sd	s0,32(sp)
 124:	ec26                	sd	s1,24(sp)
 126:	e84a                	sd	s2,16(sp)
 128:	e44e                	sd	s3,8(sp)
 12a:	e052                	sd	s4,0(sp)
 12c:	1800                	addi	s0,sp,48
  int i;
  printf("thread_a started\n");
 12e:	00001517          	auipc	a0,0x1
 132:	b2250513          	addi	a0,a0,-1246 # c50 <malloc+0x10e>
 136:	00001097          	auipc	ra,0x1
 13a:	94e080e7          	jalr	-1714(ra) # a84 <printf>
  a_started = 1;
 13e:	4785                	li	a5,1
 140:	00001717          	auipc	a4,0x1
 144:	c0f72e23          	sw	a5,-996(a4) # d5c <a_started>
  while(b_started == 0 || c_started == 0)
 148:	00001497          	auipc	s1,0x1
 14c:	c1048493          	addi	s1,s1,-1008 # d58 <b_started>
 150:	00001917          	auipc	s2,0x1
 154:	c0490913          	addi	s2,s2,-1020 # d54 <c_started>
 158:	a029                	j	162 <thread_a+0x44>
    thread_yield();
 15a:	00000097          	auipc	ra,0x0
 15e:	f9c080e7          	jalr	-100(ra) # f6 <thread_yield>
  while(b_started == 0 || c_started == 0)
 162:	409c                	lw	a5,0(s1)
 164:	2781                	sext.w	a5,a5
 166:	dbf5                	beqz	a5,15a <thread_a+0x3c>
 168:	00092783          	lw	a5,0(s2)
 16c:	2781                	sext.w	a5,a5
 16e:	d7f5                	beqz	a5,15a <thread_a+0x3c>
  
  for (i = 0; i < 100; i++) {
 170:	4481                	li	s1,0
    printf("thread_a %d\n", i);
 172:	00001a17          	auipc	s4,0x1
 176:	af6a0a13          	addi	s4,s4,-1290 # c68 <malloc+0x126>
    a_n += 1;
 17a:	00001917          	auipc	s2,0x1
 17e:	bd690913          	addi	s2,s2,-1066 # d50 <a_n>
  for (i = 0; i < 100; i++) {
 182:	06400993          	li	s3,100
    printf("thread_a %d\n", i);
 186:	85a6                	mv	a1,s1
 188:	8552                	mv	a0,s4
 18a:	00001097          	auipc	ra,0x1
 18e:	8fa080e7          	jalr	-1798(ra) # a84 <printf>
    a_n += 1;
 192:	00092783          	lw	a5,0(s2)
 196:	2785                	addiw	a5,a5,1
 198:	00f92023          	sw	a5,0(s2)
    thread_yield();
 19c:	00000097          	auipc	ra,0x0
 1a0:	f5a080e7          	jalr	-166(ra) # f6 <thread_yield>
  for (i = 0; i < 100; i++) {
 1a4:	2485                	addiw	s1,s1,1
 1a6:	ff3490e3          	bne	s1,s3,186 <thread_a+0x68>
  }
  printf("thread_a: exit after %d\n", a_n);
 1aa:	00001597          	auipc	a1,0x1
 1ae:	ba65a583          	lw	a1,-1114(a1) # d50 <a_n>
 1b2:	00001517          	auipc	a0,0x1
 1b6:	ac650513          	addi	a0,a0,-1338 # c78 <malloc+0x136>
 1ba:	00001097          	auipc	ra,0x1
 1be:	8ca080e7          	jalr	-1846(ra) # a84 <printf>

  current_thread->state = FREE;
 1c2:	00001797          	auipc	a5,0x1
 1c6:	b9e7b783          	ld	a5,-1122(a5) # d60 <current_thread>
 1ca:	6709                	lui	a4,0x2
 1cc:	97ba                	add	a5,a5,a4
 1ce:	0607a823          	sw	zero,112(a5)
  thread_schedule();
 1d2:	00000097          	auipc	ra,0x0
 1d6:	e54080e7          	jalr	-428(ra) # 26 <thread_schedule>
}
 1da:	70a2                	ld	ra,40(sp)
 1dc:	7402                	ld	s0,32(sp)
 1de:	64e2                	ld	s1,24(sp)
 1e0:	6942                	ld	s2,16(sp)
 1e2:	69a2                	ld	s3,8(sp)
 1e4:	6a02                	ld	s4,0(sp)
 1e6:	6145                	addi	sp,sp,48
 1e8:	8082                	ret

00000000000001ea <thread_b>:

void 
thread_b(void)
{
 1ea:	7179                	addi	sp,sp,-48
 1ec:	f406                	sd	ra,40(sp)
 1ee:	f022                	sd	s0,32(sp)
 1f0:	ec26                	sd	s1,24(sp)
 1f2:	e84a                	sd	s2,16(sp)
 1f4:	e44e                	sd	s3,8(sp)
 1f6:	e052                	sd	s4,0(sp)
 1f8:	1800                	addi	s0,sp,48
  int i;
  printf("thread_b started\n");
 1fa:	00001517          	auipc	a0,0x1
 1fe:	a9e50513          	addi	a0,a0,-1378 # c98 <malloc+0x156>
 202:	00001097          	auipc	ra,0x1
 206:	882080e7          	jalr	-1918(ra) # a84 <printf>
  b_started = 1;
 20a:	4785                	li	a5,1
 20c:	00001717          	auipc	a4,0x1
 210:	b4f72623          	sw	a5,-1204(a4) # d58 <b_started>
  while(a_started == 0 || c_started == 0)
 214:	00001497          	auipc	s1,0x1
 218:	b4848493          	addi	s1,s1,-1208 # d5c <a_started>
 21c:	00001917          	auipc	s2,0x1
 220:	b3890913          	addi	s2,s2,-1224 # d54 <c_started>
 224:	a029                	j	22e <thread_b+0x44>
    thread_yield();
 226:	00000097          	auipc	ra,0x0
 22a:	ed0080e7          	jalr	-304(ra) # f6 <thread_yield>
  while(a_started == 0 || c_started == 0)
 22e:	409c                	lw	a5,0(s1)
 230:	2781                	sext.w	a5,a5
 232:	dbf5                	beqz	a5,226 <thread_b+0x3c>
 234:	00092783          	lw	a5,0(s2)
 238:	2781                	sext.w	a5,a5
 23a:	d7f5                	beqz	a5,226 <thread_b+0x3c>
  
  for (i = 0; i < 100; i++) {
 23c:	4481                	li	s1,0
    printf("thread_b %d\n", i);
 23e:	00001a17          	auipc	s4,0x1
 242:	a72a0a13          	addi	s4,s4,-1422 # cb0 <malloc+0x16e>
    b_n += 1;
 246:	00001917          	auipc	s2,0x1
 24a:	b0690913          	addi	s2,s2,-1274 # d4c <b_n>
  for (i = 0; i < 100; i++) {
 24e:	06400993          	li	s3,100
    printf("thread_b %d\n", i);
 252:	85a6                	mv	a1,s1
 254:	8552                	mv	a0,s4
 256:	00001097          	auipc	ra,0x1
 25a:	82e080e7          	jalr	-2002(ra) # a84 <printf>
    b_n += 1;
 25e:	00092783          	lw	a5,0(s2)
 262:	2785                	addiw	a5,a5,1
 264:	00f92023          	sw	a5,0(s2)
    thread_yield();
 268:	00000097          	auipc	ra,0x0
 26c:	e8e080e7          	jalr	-370(ra) # f6 <thread_yield>
  for (i = 0; i < 100; i++) {
 270:	2485                	addiw	s1,s1,1
 272:	ff3490e3          	bne	s1,s3,252 <thread_b+0x68>
  }
  printf("thread_b: exit after %d\n", b_n);
 276:	00001597          	auipc	a1,0x1
 27a:	ad65a583          	lw	a1,-1322(a1) # d4c <b_n>
 27e:	00001517          	auipc	a0,0x1
 282:	a4250513          	addi	a0,a0,-1470 # cc0 <malloc+0x17e>
 286:	00000097          	auipc	ra,0x0
 28a:	7fe080e7          	jalr	2046(ra) # a84 <printf>

  current_thread->state = FREE;
 28e:	00001797          	auipc	a5,0x1
 292:	ad27b783          	ld	a5,-1326(a5) # d60 <current_thread>
 296:	6709                	lui	a4,0x2
 298:	97ba                	add	a5,a5,a4
 29a:	0607a823          	sw	zero,112(a5)
  thread_schedule();
 29e:	00000097          	auipc	ra,0x0
 2a2:	d88080e7          	jalr	-632(ra) # 26 <thread_schedule>
}
 2a6:	70a2                	ld	ra,40(sp)
 2a8:	7402                	ld	s0,32(sp)
 2aa:	64e2                	ld	s1,24(sp)
 2ac:	6942                	ld	s2,16(sp)
 2ae:	69a2                	ld	s3,8(sp)
 2b0:	6a02                	ld	s4,0(sp)
 2b2:	6145                	addi	sp,sp,48
 2b4:	8082                	ret

00000000000002b6 <thread_c>:

void 
thread_c(void)
{
 2b6:	7179                	addi	sp,sp,-48
 2b8:	f406                	sd	ra,40(sp)
 2ba:	f022                	sd	s0,32(sp)
 2bc:	ec26                	sd	s1,24(sp)
 2be:	e84a                	sd	s2,16(sp)
 2c0:	e44e                	sd	s3,8(sp)
 2c2:	e052                	sd	s4,0(sp)
 2c4:	1800                	addi	s0,sp,48
  int i;
  printf("thread_c started\n");
 2c6:	00001517          	auipc	a0,0x1
 2ca:	a1a50513          	addi	a0,a0,-1510 # ce0 <malloc+0x19e>
 2ce:	00000097          	auipc	ra,0x0
 2d2:	7b6080e7          	jalr	1974(ra) # a84 <printf>
  c_started = 1;
 2d6:	4785                	li	a5,1
 2d8:	00001717          	auipc	a4,0x1
 2dc:	a6f72e23          	sw	a5,-1412(a4) # d54 <c_started>
  while(a_started == 0 || b_started == 0)
 2e0:	00001497          	auipc	s1,0x1
 2e4:	a7c48493          	addi	s1,s1,-1412 # d5c <a_started>
 2e8:	00001917          	auipc	s2,0x1
 2ec:	a7090913          	addi	s2,s2,-1424 # d58 <b_started>
 2f0:	a029                	j	2fa <thread_c+0x44>
    thread_yield();
 2f2:	00000097          	auipc	ra,0x0
 2f6:	e04080e7          	jalr	-508(ra) # f6 <thread_yield>
  while(a_started == 0 || b_started == 0)
 2fa:	409c                	lw	a5,0(s1)
 2fc:	2781                	sext.w	a5,a5
 2fe:	dbf5                	beqz	a5,2f2 <thread_c+0x3c>
 300:	00092783          	lw	a5,0(s2)
 304:	2781                	sext.w	a5,a5
 306:	d7f5                	beqz	a5,2f2 <thread_c+0x3c>
  
  for (i = 0; i < 100; i++) {
 308:	4481                	li	s1,0
    printf("thread_c %d\n", i);
 30a:	00001a17          	auipc	s4,0x1
 30e:	9eea0a13          	addi	s4,s4,-1554 # cf8 <malloc+0x1b6>
    c_n += 1;
 312:	00001917          	auipc	s2,0x1
 316:	a3690913          	addi	s2,s2,-1482 # d48 <c_n>
  for (i = 0; i < 100; i++) {
 31a:	06400993          	li	s3,100
    printf("thread_c %d\n", i);
 31e:	85a6                	mv	a1,s1
 320:	8552                	mv	a0,s4
 322:	00000097          	auipc	ra,0x0
 326:	762080e7          	jalr	1890(ra) # a84 <printf>
    c_n += 1;
 32a:	00092783          	lw	a5,0(s2)
 32e:	2785                	addiw	a5,a5,1
 330:	00f92023          	sw	a5,0(s2)
    thread_yield();
 334:	00000097          	auipc	ra,0x0
 338:	dc2080e7          	jalr	-574(ra) # f6 <thread_yield>
  for (i = 0; i < 100; i++) {
 33c:	2485                	addiw	s1,s1,1
 33e:	ff3490e3          	bne	s1,s3,31e <thread_c+0x68>
  }
  printf("thread_c: exit after %d\n", c_n);
 342:	00001597          	auipc	a1,0x1
 346:	a065a583          	lw	a1,-1530(a1) # d48 <c_n>
 34a:	00001517          	auipc	a0,0x1
 34e:	9be50513          	addi	a0,a0,-1602 # d08 <malloc+0x1c6>
 352:	00000097          	auipc	ra,0x0
 356:	732080e7          	jalr	1842(ra) # a84 <printf>

  current_thread->state = FREE;
 35a:	00001797          	auipc	a5,0x1
 35e:	a067b783          	ld	a5,-1530(a5) # d60 <current_thread>
 362:	6709                	lui	a4,0x2
 364:	97ba                	add	a5,a5,a4
 366:	0607a823          	sw	zero,112(a5)
  thread_schedule();
 36a:	00000097          	auipc	ra,0x0
 36e:	cbc080e7          	jalr	-836(ra) # 26 <thread_schedule>
}
 372:	70a2                	ld	ra,40(sp)
 374:	7402                	ld	s0,32(sp)
 376:	64e2                	ld	s1,24(sp)
 378:	6942                	ld	s2,16(sp)
 37a:	69a2                	ld	s3,8(sp)
 37c:	6a02                	ld	s4,0(sp)
 37e:	6145                	addi	sp,sp,48
 380:	8082                	ret

0000000000000382 <main>:

int 
main(int argc, char *argv[]) 
{
 382:	1141                	addi	sp,sp,-16
 384:	e406                	sd	ra,8(sp)
 386:	e022                	sd	s0,0(sp)
 388:	0800                	addi	s0,sp,16
  a_started = b_started = c_started = 0;
 38a:	00001797          	auipc	a5,0x1
 38e:	9c07a523          	sw	zero,-1590(a5) # d54 <c_started>
 392:	00001797          	auipc	a5,0x1
 396:	9c07a323          	sw	zero,-1594(a5) # d58 <b_started>
 39a:	00001797          	auipc	a5,0x1
 39e:	9c07a123          	sw	zero,-1598(a5) # d5c <a_started>
  a_n = b_n = c_n = 0;
 3a2:	00001797          	auipc	a5,0x1
 3a6:	9a07a323          	sw	zero,-1626(a5) # d48 <c_n>
 3aa:	00001797          	auipc	a5,0x1
 3ae:	9a07a123          	sw	zero,-1630(a5) # d4c <b_n>
 3b2:	00001797          	auipc	a5,0x1
 3b6:	9807af23          	sw	zero,-1634(a5) # d50 <a_n>
  thread_init();
 3ba:	00000097          	auipc	ra,0x0
 3be:	c46080e7          	jalr	-954(ra) # 0 <thread_init>
  thread_create(thread_a);
 3c2:	00000517          	auipc	a0,0x0
 3c6:	d5c50513          	addi	a0,a0,-676 # 11e <thread_a>
 3ca:	00000097          	auipc	ra,0x0
 3ce:	ce4080e7          	jalr	-796(ra) # ae <thread_create>
  thread_create(thread_b);
 3d2:	00000517          	auipc	a0,0x0
 3d6:	e1850513          	addi	a0,a0,-488 # 1ea <thread_b>
 3da:	00000097          	auipc	ra,0x0
 3de:	cd4080e7          	jalr	-812(ra) # ae <thread_create>
  thread_create(thread_c);
 3e2:	00000517          	auipc	a0,0x0
 3e6:	ed450513          	addi	a0,a0,-300 # 2b6 <thread_c>
 3ea:	00000097          	auipc	ra,0x0
 3ee:	cc4080e7          	jalr	-828(ra) # ae <thread_create>
  thread_schedule();
 3f2:	00000097          	auipc	ra,0x0
 3f6:	c34080e7          	jalr	-972(ra) # 26 <thread_schedule>
  exit(0);
 3fa:	4501                	li	a0,0
 3fc:	00000097          	auipc	ra,0x0
 400:	2e0080e7          	jalr	736(ra) # 6dc <exit>

0000000000000404 <thread_switch>:
 404:	00153023          	sd	ra,0(a0)
 408:	00253423          	sd	sp,8(a0)
 40c:	e900                	sd	s0,16(a0)
 40e:	ed04                	sd	s1,24(a0)
 410:	03253023          	sd	s2,32(a0)
 414:	03353423          	sd	s3,40(a0)
 418:	03453823          	sd	s4,48(a0)
 41c:	03553c23          	sd	s5,56(a0)
 420:	05653023          	sd	s6,64(a0)
 424:	05753423          	sd	s7,72(a0)
 428:	05853823          	sd	s8,80(a0)
 42c:	05953c23          	sd	s9,88(a0)
 430:	07a53023          	sd	s10,96(a0)
 434:	07b53423          	sd	s11,104(a0)
 438:	0005b083          	ld	ra,0(a1)
 43c:	0085b103          	ld	sp,8(a1)
 440:	6980                	ld	s0,16(a1)
 442:	6d84                	ld	s1,24(a1)
 444:	0205b903          	ld	s2,32(a1)
 448:	0285b983          	ld	s3,40(a1)
 44c:	0305ba03          	ld	s4,48(a1)
 450:	0385ba83          	ld	s5,56(a1)
 454:	0405bb03          	ld	s6,64(a1)
 458:	0485bb83          	ld	s7,72(a1)
 45c:	0505bc03          	ld	s8,80(a1)
 460:	0585bc83          	ld	s9,88(a1)
 464:	0605bd03          	ld	s10,96(a1)
 468:	0685bd83          	ld	s11,104(a1)
 46c:	8082                	ret

000000000000046e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 46e:	1141                	addi	sp,sp,-16
 470:	e422                	sd	s0,8(sp)
 472:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 474:	87aa                	mv	a5,a0
 476:	0585                	addi	a1,a1,1
 478:	0785                	addi	a5,a5,1
 47a:	fff5c703          	lbu	a4,-1(a1)
 47e:	fee78fa3          	sb	a4,-1(a5)
 482:	fb75                	bnez	a4,476 <strcpy+0x8>
    ;
  return os;
}
 484:	6422                	ld	s0,8(sp)
 486:	0141                	addi	sp,sp,16
 488:	8082                	ret

000000000000048a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 48a:	1141                	addi	sp,sp,-16
 48c:	e422                	sd	s0,8(sp)
 48e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 490:	00054783          	lbu	a5,0(a0)
 494:	cb91                	beqz	a5,4a8 <strcmp+0x1e>
 496:	0005c703          	lbu	a4,0(a1)
 49a:	00f71763          	bne	a4,a5,4a8 <strcmp+0x1e>
    p++, q++;
 49e:	0505                	addi	a0,a0,1
 4a0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4a2:	00054783          	lbu	a5,0(a0)
 4a6:	fbe5                	bnez	a5,496 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4a8:	0005c503          	lbu	a0,0(a1)
}
 4ac:	40a7853b          	subw	a0,a5,a0
 4b0:	6422                	ld	s0,8(sp)
 4b2:	0141                	addi	sp,sp,16
 4b4:	8082                	ret

00000000000004b6 <strlen>:

uint
strlen(const char *s)
{
 4b6:	1141                	addi	sp,sp,-16
 4b8:	e422                	sd	s0,8(sp)
 4ba:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4bc:	00054783          	lbu	a5,0(a0)
 4c0:	cf91                	beqz	a5,4dc <strlen+0x26>
 4c2:	0505                	addi	a0,a0,1
 4c4:	87aa                	mv	a5,a0
 4c6:	4685                	li	a3,1
 4c8:	9e89                	subw	a3,a3,a0
 4ca:	00f6853b          	addw	a0,a3,a5
 4ce:	0785                	addi	a5,a5,1
 4d0:	fff7c703          	lbu	a4,-1(a5)
 4d4:	fb7d                	bnez	a4,4ca <strlen+0x14>
    ;
  return n;
}
 4d6:	6422                	ld	s0,8(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret
  for(n = 0; s[n]; n++)
 4dc:	4501                	li	a0,0
 4de:	bfe5                	j	4d6 <strlen+0x20>

00000000000004e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4e0:	1141                	addi	sp,sp,-16
 4e2:	e422                	sd	s0,8(sp)
 4e4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 4e6:	ca19                	beqz	a2,4fc <memset+0x1c>
 4e8:	87aa                	mv	a5,a0
 4ea:	1602                	slli	a2,a2,0x20
 4ec:	9201                	srli	a2,a2,0x20
 4ee:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 4f2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 4f6:	0785                	addi	a5,a5,1
 4f8:	fee79de3          	bne	a5,a4,4f2 <memset+0x12>
  }
  return dst;
}
 4fc:	6422                	ld	s0,8(sp)
 4fe:	0141                	addi	sp,sp,16
 500:	8082                	ret

0000000000000502 <strchr>:

char*
strchr(const char *s, char c)
{
 502:	1141                	addi	sp,sp,-16
 504:	e422                	sd	s0,8(sp)
 506:	0800                	addi	s0,sp,16
  for(; *s; s++)
 508:	00054783          	lbu	a5,0(a0)
 50c:	cb99                	beqz	a5,522 <strchr+0x20>
    if(*s == c)
 50e:	00f58763          	beq	a1,a5,51c <strchr+0x1a>
  for(; *s; s++)
 512:	0505                	addi	a0,a0,1
 514:	00054783          	lbu	a5,0(a0)
 518:	fbfd                	bnez	a5,50e <strchr+0xc>
      return (char*)s;
  return 0;
 51a:	4501                	li	a0,0
}
 51c:	6422                	ld	s0,8(sp)
 51e:	0141                	addi	sp,sp,16
 520:	8082                	ret
  return 0;
 522:	4501                	li	a0,0
 524:	bfe5                	j	51c <strchr+0x1a>

0000000000000526 <gets>:

char*
gets(char *buf, int max)
{
 526:	711d                	addi	sp,sp,-96
 528:	ec86                	sd	ra,88(sp)
 52a:	e8a2                	sd	s0,80(sp)
 52c:	e4a6                	sd	s1,72(sp)
 52e:	e0ca                	sd	s2,64(sp)
 530:	fc4e                	sd	s3,56(sp)
 532:	f852                	sd	s4,48(sp)
 534:	f456                	sd	s5,40(sp)
 536:	f05a                	sd	s6,32(sp)
 538:	ec5e                	sd	s7,24(sp)
 53a:	1080                	addi	s0,sp,96
 53c:	8baa                	mv	s7,a0
 53e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 540:	892a                	mv	s2,a0
 542:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 544:	4aa9                	li	s5,10
 546:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 548:	89a6                	mv	s3,s1
 54a:	2485                	addiw	s1,s1,1
 54c:	0344d863          	bge	s1,s4,57c <gets+0x56>
    cc = read(0, &c, 1);
 550:	4605                	li	a2,1
 552:	faf40593          	addi	a1,s0,-81
 556:	4501                	li	a0,0
 558:	00000097          	auipc	ra,0x0
 55c:	19c080e7          	jalr	412(ra) # 6f4 <read>
    if(cc < 1)
 560:	00a05e63          	blez	a0,57c <gets+0x56>
    buf[i++] = c;
 564:	faf44783          	lbu	a5,-81(s0)
 568:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 56c:	01578763          	beq	a5,s5,57a <gets+0x54>
 570:	0905                	addi	s2,s2,1
 572:	fd679be3          	bne	a5,s6,548 <gets+0x22>
  for(i=0; i+1 < max; ){
 576:	89a6                	mv	s3,s1
 578:	a011                	j	57c <gets+0x56>
 57a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 57c:	99de                	add	s3,s3,s7
 57e:	00098023          	sb	zero,0(s3)
  return buf;
}
 582:	855e                	mv	a0,s7
 584:	60e6                	ld	ra,88(sp)
 586:	6446                	ld	s0,80(sp)
 588:	64a6                	ld	s1,72(sp)
 58a:	6906                	ld	s2,64(sp)
 58c:	79e2                	ld	s3,56(sp)
 58e:	7a42                	ld	s4,48(sp)
 590:	7aa2                	ld	s5,40(sp)
 592:	7b02                	ld	s6,32(sp)
 594:	6be2                	ld	s7,24(sp)
 596:	6125                	addi	sp,sp,96
 598:	8082                	ret

000000000000059a <stat>:

int
stat(const char *n, struct stat *st)
{
 59a:	1101                	addi	sp,sp,-32
 59c:	ec06                	sd	ra,24(sp)
 59e:	e822                	sd	s0,16(sp)
 5a0:	e426                	sd	s1,8(sp)
 5a2:	e04a                	sd	s2,0(sp)
 5a4:	1000                	addi	s0,sp,32
 5a6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5a8:	4581                	li	a1,0
 5aa:	00000097          	auipc	ra,0x0
 5ae:	172080e7          	jalr	370(ra) # 71c <open>
  if(fd < 0)
 5b2:	02054563          	bltz	a0,5dc <stat+0x42>
 5b6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5b8:	85ca                	mv	a1,s2
 5ba:	00000097          	auipc	ra,0x0
 5be:	17a080e7          	jalr	378(ra) # 734 <fstat>
 5c2:	892a                	mv	s2,a0
  close(fd);
 5c4:	8526                	mv	a0,s1
 5c6:	00000097          	auipc	ra,0x0
 5ca:	13e080e7          	jalr	318(ra) # 704 <close>
  return r;
}
 5ce:	854a                	mv	a0,s2
 5d0:	60e2                	ld	ra,24(sp)
 5d2:	6442                	ld	s0,16(sp)
 5d4:	64a2                	ld	s1,8(sp)
 5d6:	6902                	ld	s2,0(sp)
 5d8:	6105                	addi	sp,sp,32
 5da:	8082                	ret
    return -1;
 5dc:	597d                	li	s2,-1
 5de:	bfc5                	j	5ce <stat+0x34>

00000000000005e0 <atoi>:

int
atoi(const char *s)
{
 5e0:	1141                	addi	sp,sp,-16
 5e2:	e422                	sd	s0,8(sp)
 5e4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5e6:	00054603          	lbu	a2,0(a0)
 5ea:	fd06079b          	addiw	a5,a2,-48
 5ee:	0ff7f793          	andi	a5,a5,255
 5f2:	4725                	li	a4,9
 5f4:	02f76963          	bltu	a4,a5,626 <atoi+0x46>
 5f8:	86aa                	mv	a3,a0
  n = 0;
 5fa:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 5fc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 5fe:	0685                	addi	a3,a3,1
 600:	0025179b          	slliw	a5,a0,0x2
 604:	9fa9                	addw	a5,a5,a0
 606:	0017979b          	slliw	a5,a5,0x1
 60a:	9fb1                	addw	a5,a5,a2
 60c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 610:	0006c603          	lbu	a2,0(a3)
 614:	fd06071b          	addiw	a4,a2,-48
 618:	0ff77713          	andi	a4,a4,255
 61c:	fee5f1e3          	bgeu	a1,a4,5fe <atoi+0x1e>
  return n;
}
 620:	6422                	ld	s0,8(sp)
 622:	0141                	addi	sp,sp,16
 624:	8082                	ret
  n = 0;
 626:	4501                	li	a0,0
 628:	bfe5                	j	620 <atoi+0x40>

000000000000062a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 62a:	1141                	addi	sp,sp,-16
 62c:	e422                	sd	s0,8(sp)
 62e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 630:	02b57463          	bgeu	a0,a1,658 <memmove+0x2e>
    while(n-- > 0)
 634:	00c05f63          	blez	a2,652 <memmove+0x28>
 638:	1602                	slli	a2,a2,0x20
 63a:	9201                	srli	a2,a2,0x20
 63c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 640:	872a                	mv	a4,a0
      *dst++ = *src++;
 642:	0585                	addi	a1,a1,1
 644:	0705                	addi	a4,a4,1
 646:	fff5c683          	lbu	a3,-1(a1)
 64a:	fed70fa3          	sb	a3,-1(a4) # 1fff <__global_pointer$+0xabe>
    while(n-- > 0)
 64e:	fee79ae3          	bne	a5,a4,642 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 652:	6422                	ld	s0,8(sp)
 654:	0141                	addi	sp,sp,16
 656:	8082                	ret
    dst += n;
 658:	00c50733          	add	a4,a0,a2
    src += n;
 65c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 65e:	fec05ae3          	blez	a2,652 <memmove+0x28>
 662:	fff6079b          	addiw	a5,a2,-1
 666:	1782                	slli	a5,a5,0x20
 668:	9381                	srli	a5,a5,0x20
 66a:	fff7c793          	not	a5,a5
 66e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 670:	15fd                	addi	a1,a1,-1
 672:	177d                	addi	a4,a4,-1
 674:	0005c683          	lbu	a3,0(a1)
 678:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 67c:	fee79ae3          	bne	a5,a4,670 <memmove+0x46>
 680:	bfc9                	j	652 <memmove+0x28>

0000000000000682 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 682:	1141                	addi	sp,sp,-16
 684:	e422                	sd	s0,8(sp)
 686:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 688:	ca05                	beqz	a2,6b8 <memcmp+0x36>
 68a:	fff6069b          	addiw	a3,a2,-1
 68e:	1682                	slli	a3,a3,0x20
 690:	9281                	srli	a3,a3,0x20
 692:	0685                	addi	a3,a3,1
 694:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 696:	00054783          	lbu	a5,0(a0)
 69a:	0005c703          	lbu	a4,0(a1)
 69e:	00e79863          	bne	a5,a4,6ae <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6a2:	0505                	addi	a0,a0,1
    p2++;
 6a4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6a6:	fed518e3          	bne	a0,a3,696 <memcmp+0x14>
  }
  return 0;
 6aa:	4501                	li	a0,0
 6ac:	a019                	j	6b2 <memcmp+0x30>
      return *p1 - *p2;
 6ae:	40e7853b          	subw	a0,a5,a4
}
 6b2:	6422                	ld	s0,8(sp)
 6b4:	0141                	addi	sp,sp,16
 6b6:	8082                	ret
  return 0;
 6b8:	4501                	li	a0,0
 6ba:	bfe5                	j	6b2 <memcmp+0x30>

00000000000006bc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6bc:	1141                	addi	sp,sp,-16
 6be:	e406                	sd	ra,8(sp)
 6c0:	e022                	sd	s0,0(sp)
 6c2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6c4:	00000097          	auipc	ra,0x0
 6c8:	f66080e7          	jalr	-154(ra) # 62a <memmove>
}
 6cc:	60a2                	ld	ra,8(sp)
 6ce:	6402                	ld	s0,0(sp)
 6d0:	0141                	addi	sp,sp,16
 6d2:	8082                	ret

00000000000006d4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6d4:	4885                	li	a7,1
 ecall
 6d6:	00000073          	ecall
 ret
 6da:	8082                	ret

00000000000006dc <exit>:
.global exit
exit:
 li a7, SYS_exit
 6dc:	4889                	li	a7,2
 ecall
 6de:	00000073          	ecall
 ret
 6e2:	8082                	ret

00000000000006e4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 6e4:	488d                	li	a7,3
 ecall
 6e6:	00000073          	ecall
 ret
 6ea:	8082                	ret

00000000000006ec <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6ec:	4891                	li	a7,4
 ecall
 6ee:	00000073          	ecall
 ret
 6f2:	8082                	ret

00000000000006f4 <read>:
.global read
read:
 li a7, SYS_read
 6f4:	4895                	li	a7,5
 ecall
 6f6:	00000073          	ecall
 ret
 6fa:	8082                	ret

00000000000006fc <write>:
.global write
write:
 li a7, SYS_write
 6fc:	48c1                	li	a7,16
 ecall
 6fe:	00000073          	ecall
 ret
 702:	8082                	ret

0000000000000704 <close>:
.global close
close:
 li a7, SYS_close
 704:	48d5                	li	a7,21
 ecall
 706:	00000073          	ecall
 ret
 70a:	8082                	ret

000000000000070c <kill>:
.global kill
kill:
 li a7, SYS_kill
 70c:	4899                	li	a7,6
 ecall
 70e:	00000073          	ecall
 ret
 712:	8082                	ret

0000000000000714 <exec>:
.global exec
exec:
 li a7, SYS_exec
 714:	489d                	li	a7,7
 ecall
 716:	00000073          	ecall
 ret
 71a:	8082                	ret

000000000000071c <open>:
.global open
open:
 li a7, SYS_open
 71c:	48bd                	li	a7,15
 ecall
 71e:	00000073          	ecall
 ret
 722:	8082                	ret

0000000000000724 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 724:	48c5                	li	a7,17
 ecall
 726:	00000073          	ecall
 ret
 72a:	8082                	ret

000000000000072c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 72c:	48c9                	li	a7,18
 ecall
 72e:	00000073          	ecall
 ret
 732:	8082                	ret

0000000000000734 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 734:	48a1                	li	a7,8
 ecall
 736:	00000073          	ecall
 ret
 73a:	8082                	ret

000000000000073c <link>:
.global link
link:
 li a7, SYS_link
 73c:	48cd                	li	a7,19
 ecall
 73e:	00000073          	ecall
 ret
 742:	8082                	ret

0000000000000744 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 744:	48d1                	li	a7,20
 ecall
 746:	00000073          	ecall
 ret
 74a:	8082                	ret

000000000000074c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 74c:	48a5                	li	a7,9
 ecall
 74e:	00000073          	ecall
 ret
 752:	8082                	ret

0000000000000754 <dup>:
.global dup
dup:
 li a7, SYS_dup
 754:	48a9                	li	a7,10
 ecall
 756:	00000073          	ecall
 ret
 75a:	8082                	ret

000000000000075c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 75c:	48ad                	li	a7,11
 ecall
 75e:	00000073          	ecall
 ret
 762:	8082                	ret

0000000000000764 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 764:	48b1                	li	a7,12
 ecall
 766:	00000073          	ecall
 ret
 76a:	8082                	ret

000000000000076c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 76c:	48b5                	li	a7,13
 ecall
 76e:	00000073          	ecall
 ret
 772:	8082                	ret

0000000000000774 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 774:	48b9                	li	a7,14
 ecall
 776:	00000073          	ecall
 ret
 77a:	8082                	ret

000000000000077c <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 77c:	48d9                	li	a7,22
 ecall
 77e:	00000073          	ecall
 ret
 782:	8082                	ret

0000000000000784 <crash>:
.global crash
crash:
 li a7, SYS_crash
 784:	48dd                	li	a7,23
 ecall
 786:	00000073          	ecall
 ret
 78a:	8082                	ret

000000000000078c <mount>:
.global mount
mount:
 li a7, SYS_mount
 78c:	48e1                	li	a7,24
 ecall
 78e:	00000073          	ecall
 ret
 792:	8082                	ret

0000000000000794 <umount>:
.global umount
umount:
 li a7, SYS_umount
 794:	48e5                	li	a7,25
 ecall
 796:	00000073          	ecall
 ret
 79a:	8082                	ret

000000000000079c <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 79c:	48e9                	li	a7,26
 ecall
 79e:	00000073          	ecall
 ret
 7a2:	8082                	ret

00000000000007a4 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 7a4:	48ed                	li	a7,27
 ecall
 7a6:	00000073          	ecall
 ret
 7aa:	8082                	ret

00000000000007ac <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7ac:	1101                	addi	sp,sp,-32
 7ae:	ec06                	sd	ra,24(sp)
 7b0:	e822                	sd	s0,16(sp)
 7b2:	1000                	addi	s0,sp,32
 7b4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7b8:	4605                	li	a2,1
 7ba:	fef40593          	addi	a1,s0,-17
 7be:	00000097          	auipc	ra,0x0
 7c2:	f3e080e7          	jalr	-194(ra) # 6fc <write>
}
 7c6:	60e2                	ld	ra,24(sp)
 7c8:	6442                	ld	s0,16(sp)
 7ca:	6105                	addi	sp,sp,32
 7cc:	8082                	ret

00000000000007ce <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7ce:	7139                	addi	sp,sp,-64
 7d0:	fc06                	sd	ra,56(sp)
 7d2:	f822                	sd	s0,48(sp)
 7d4:	f426                	sd	s1,40(sp)
 7d6:	f04a                	sd	s2,32(sp)
 7d8:	ec4e                	sd	s3,24(sp)
 7da:	0080                	addi	s0,sp,64
 7dc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7de:	c299                	beqz	a3,7e4 <printint+0x16>
 7e0:	0805c863          	bltz	a1,870 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7e4:	2581                	sext.w	a1,a1
  neg = 0;
 7e6:	4881                	li	a7,0
 7e8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7ec:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7ee:	2601                	sext.w	a2,a2
 7f0:	00000517          	auipc	a0,0x0
 7f4:	54050513          	addi	a0,a0,1344 # d30 <digits>
 7f8:	883a                	mv	a6,a4
 7fa:	2705                	addiw	a4,a4,1
 7fc:	02c5f7bb          	remuw	a5,a1,a2
 800:	1782                	slli	a5,a5,0x20
 802:	9381                	srli	a5,a5,0x20
 804:	97aa                	add	a5,a5,a0
 806:	0007c783          	lbu	a5,0(a5)
 80a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 80e:	0005879b          	sext.w	a5,a1
 812:	02c5d5bb          	divuw	a1,a1,a2
 816:	0685                	addi	a3,a3,1
 818:	fec7f0e3          	bgeu	a5,a2,7f8 <printint+0x2a>
  if(neg)
 81c:	00088b63          	beqz	a7,832 <printint+0x64>
    buf[i++] = '-';
 820:	fd040793          	addi	a5,s0,-48
 824:	973e                	add	a4,a4,a5
 826:	02d00793          	li	a5,45
 82a:	fef70823          	sb	a5,-16(a4)
 82e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 832:	02e05863          	blez	a4,862 <printint+0x94>
 836:	fc040793          	addi	a5,s0,-64
 83a:	00e78933          	add	s2,a5,a4
 83e:	fff78993          	addi	s3,a5,-1
 842:	99ba                	add	s3,s3,a4
 844:	377d                	addiw	a4,a4,-1
 846:	1702                	slli	a4,a4,0x20
 848:	9301                	srli	a4,a4,0x20
 84a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 84e:	fff94583          	lbu	a1,-1(s2)
 852:	8526                	mv	a0,s1
 854:	00000097          	auipc	ra,0x0
 858:	f58080e7          	jalr	-168(ra) # 7ac <putc>
  while(--i >= 0)
 85c:	197d                	addi	s2,s2,-1
 85e:	ff3918e3          	bne	s2,s3,84e <printint+0x80>
}
 862:	70e2                	ld	ra,56(sp)
 864:	7442                	ld	s0,48(sp)
 866:	74a2                	ld	s1,40(sp)
 868:	7902                	ld	s2,32(sp)
 86a:	69e2                	ld	s3,24(sp)
 86c:	6121                	addi	sp,sp,64
 86e:	8082                	ret
    x = -xx;
 870:	40b005bb          	negw	a1,a1
    neg = 1;
 874:	4885                	li	a7,1
    x = -xx;
 876:	bf8d                	j	7e8 <printint+0x1a>

0000000000000878 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 878:	7119                	addi	sp,sp,-128
 87a:	fc86                	sd	ra,120(sp)
 87c:	f8a2                	sd	s0,112(sp)
 87e:	f4a6                	sd	s1,104(sp)
 880:	f0ca                	sd	s2,96(sp)
 882:	ecce                	sd	s3,88(sp)
 884:	e8d2                	sd	s4,80(sp)
 886:	e4d6                	sd	s5,72(sp)
 888:	e0da                	sd	s6,64(sp)
 88a:	fc5e                	sd	s7,56(sp)
 88c:	f862                	sd	s8,48(sp)
 88e:	f466                	sd	s9,40(sp)
 890:	f06a                	sd	s10,32(sp)
 892:	ec6e                	sd	s11,24(sp)
 894:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 896:	0005c903          	lbu	s2,0(a1)
 89a:	18090f63          	beqz	s2,a38 <vprintf+0x1c0>
 89e:	8aaa                	mv	s5,a0
 8a0:	8b32                	mv	s6,a2
 8a2:	00158493          	addi	s1,a1,1
  state = 0;
 8a6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8a8:	02500a13          	li	s4,37
      if(c == 'd'){
 8ac:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 8b0:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 8b4:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 8b8:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8bc:	00000b97          	auipc	s7,0x0
 8c0:	474b8b93          	addi	s7,s7,1140 # d30 <digits>
 8c4:	a839                	j	8e2 <vprintf+0x6a>
        putc(fd, c);
 8c6:	85ca                	mv	a1,s2
 8c8:	8556                	mv	a0,s5
 8ca:	00000097          	auipc	ra,0x0
 8ce:	ee2080e7          	jalr	-286(ra) # 7ac <putc>
 8d2:	a019                	j	8d8 <vprintf+0x60>
    } else if(state == '%'){
 8d4:	01498f63          	beq	s3,s4,8f2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 8d8:	0485                	addi	s1,s1,1
 8da:	fff4c903          	lbu	s2,-1(s1)
 8de:	14090d63          	beqz	s2,a38 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 8e2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 8e6:	fe0997e3          	bnez	s3,8d4 <vprintf+0x5c>
      if(c == '%'){
 8ea:	fd479ee3          	bne	a5,s4,8c6 <vprintf+0x4e>
        state = '%';
 8ee:	89be                	mv	s3,a5
 8f0:	b7e5                	j	8d8 <vprintf+0x60>
      if(c == 'd'){
 8f2:	05878063          	beq	a5,s8,932 <vprintf+0xba>
      } else if(c == 'l') {
 8f6:	05978c63          	beq	a5,s9,94e <vprintf+0xd6>
      } else if(c == 'x') {
 8fa:	07a78863          	beq	a5,s10,96a <vprintf+0xf2>
      } else if(c == 'p') {
 8fe:	09b78463          	beq	a5,s11,986 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 902:	07300713          	li	a4,115
 906:	0ce78663          	beq	a5,a4,9d2 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 90a:	06300713          	li	a4,99
 90e:	0ee78e63          	beq	a5,a4,a0a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 912:	11478863          	beq	a5,s4,a22 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 916:	85d2                	mv	a1,s4
 918:	8556                	mv	a0,s5
 91a:	00000097          	auipc	ra,0x0
 91e:	e92080e7          	jalr	-366(ra) # 7ac <putc>
        putc(fd, c);
 922:	85ca                	mv	a1,s2
 924:	8556                	mv	a0,s5
 926:	00000097          	auipc	ra,0x0
 92a:	e86080e7          	jalr	-378(ra) # 7ac <putc>
      }
      state = 0;
 92e:	4981                	li	s3,0
 930:	b765                	j	8d8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 932:	008b0913          	addi	s2,s6,8
 936:	4685                	li	a3,1
 938:	4629                	li	a2,10
 93a:	000b2583          	lw	a1,0(s6)
 93e:	8556                	mv	a0,s5
 940:	00000097          	auipc	ra,0x0
 944:	e8e080e7          	jalr	-370(ra) # 7ce <printint>
 948:	8b4a                	mv	s6,s2
      state = 0;
 94a:	4981                	li	s3,0
 94c:	b771                	j	8d8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 94e:	008b0913          	addi	s2,s6,8
 952:	4681                	li	a3,0
 954:	4629                	li	a2,10
 956:	000b2583          	lw	a1,0(s6)
 95a:	8556                	mv	a0,s5
 95c:	00000097          	auipc	ra,0x0
 960:	e72080e7          	jalr	-398(ra) # 7ce <printint>
 964:	8b4a                	mv	s6,s2
      state = 0;
 966:	4981                	li	s3,0
 968:	bf85                	j	8d8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 96a:	008b0913          	addi	s2,s6,8
 96e:	4681                	li	a3,0
 970:	4641                	li	a2,16
 972:	000b2583          	lw	a1,0(s6)
 976:	8556                	mv	a0,s5
 978:	00000097          	auipc	ra,0x0
 97c:	e56080e7          	jalr	-426(ra) # 7ce <printint>
 980:	8b4a                	mv	s6,s2
      state = 0;
 982:	4981                	li	s3,0
 984:	bf91                	j	8d8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 986:	008b0793          	addi	a5,s6,8
 98a:	f8f43423          	sd	a5,-120(s0)
 98e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 992:	03000593          	li	a1,48
 996:	8556                	mv	a0,s5
 998:	00000097          	auipc	ra,0x0
 99c:	e14080e7          	jalr	-492(ra) # 7ac <putc>
  putc(fd, 'x');
 9a0:	85ea                	mv	a1,s10
 9a2:	8556                	mv	a0,s5
 9a4:	00000097          	auipc	ra,0x0
 9a8:	e08080e7          	jalr	-504(ra) # 7ac <putc>
 9ac:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9ae:	03c9d793          	srli	a5,s3,0x3c
 9b2:	97de                	add	a5,a5,s7
 9b4:	0007c583          	lbu	a1,0(a5)
 9b8:	8556                	mv	a0,s5
 9ba:	00000097          	auipc	ra,0x0
 9be:	df2080e7          	jalr	-526(ra) # 7ac <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9c2:	0992                	slli	s3,s3,0x4
 9c4:	397d                	addiw	s2,s2,-1
 9c6:	fe0914e3          	bnez	s2,9ae <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 9ca:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 9ce:	4981                	li	s3,0
 9d0:	b721                	j	8d8 <vprintf+0x60>
        s = va_arg(ap, char*);
 9d2:	008b0993          	addi	s3,s6,8
 9d6:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 9da:	02090163          	beqz	s2,9fc <vprintf+0x184>
        while(*s != 0){
 9de:	00094583          	lbu	a1,0(s2)
 9e2:	c9a1                	beqz	a1,a32 <vprintf+0x1ba>
          putc(fd, *s);
 9e4:	8556                	mv	a0,s5
 9e6:	00000097          	auipc	ra,0x0
 9ea:	dc6080e7          	jalr	-570(ra) # 7ac <putc>
          s++;
 9ee:	0905                	addi	s2,s2,1
        while(*s != 0){
 9f0:	00094583          	lbu	a1,0(s2)
 9f4:	f9e5                	bnez	a1,9e4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 9f6:	8b4e                	mv	s6,s3
      state = 0;
 9f8:	4981                	li	s3,0
 9fa:	bdf9                	j	8d8 <vprintf+0x60>
          s = "(null)";
 9fc:	00000917          	auipc	s2,0x0
 a00:	32c90913          	addi	s2,s2,812 # d28 <malloc+0x1e6>
        while(*s != 0){
 a04:	02800593          	li	a1,40
 a08:	bff1                	j	9e4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a0a:	008b0913          	addi	s2,s6,8
 a0e:	000b4583          	lbu	a1,0(s6)
 a12:	8556                	mv	a0,s5
 a14:	00000097          	auipc	ra,0x0
 a18:	d98080e7          	jalr	-616(ra) # 7ac <putc>
 a1c:	8b4a                	mv	s6,s2
      state = 0;
 a1e:	4981                	li	s3,0
 a20:	bd65                	j	8d8 <vprintf+0x60>
        putc(fd, c);
 a22:	85d2                	mv	a1,s4
 a24:	8556                	mv	a0,s5
 a26:	00000097          	auipc	ra,0x0
 a2a:	d86080e7          	jalr	-634(ra) # 7ac <putc>
      state = 0;
 a2e:	4981                	li	s3,0
 a30:	b565                	j	8d8 <vprintf+0x60>
        s = va_arg(ap, char*);
 a32:	8b4e                	mv	s6,s3
      state = 0;
 a34:	4981                	li	s3,0
 a36:	b54d                	j	8d8 <vprintf+0x60>
    }
  }
}
 a38:	70e6                	ld	ra,120(sp)
 a3a:	7446                	ld	s0,112(sp)
 a3c:	74a6                	ld	s1,104(sp)
 a3e:	7906                	ld	s2,96(sp)
 a40:	69e6                	ld	s3,88(sp)
 a42:	6a46                	ld	s4,80(sp)
 a44:	6aa6                	ld	s5,72(sp)
 a46:	6b06                	ld	s6,64(sp)
 a48:	7be2                	ld	s7,56(sp)
 a4a:	7c42                	ld	s8,48(sp)
 a4c:	7ca2                	ld	s9,40(sp)
 a4e:	7d02                	ld	s10,32(sp)
 a50:	6de2                	ld	s11,24(sp)
 a52:	6109                	addi	sp,sp,128
 a54:	8082                	ret

0000000000000a56 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a56:	715d                	addi	sp,sp,-80
 a58:	ec06                	sd	ra,24(sp)
 a5a:	e822                	sd	s0,16(sp)
 a5c:	1000                	addi	s0,sp,32
 a5e:	e010                	sd	a2,0(s0)
 a60:	e414                	sd	a3,8(s0)
 a62:	e818                	sd	a4,16(s0)
 a64:	ec1c                	sd	a5,24(s0)
 a66:	03043023          	sd	a6,32(s0)
 a6a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a6e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a72:	8622                	mv	a2,s0
 a74:	00000097          	auipc	ra,0x0
 a78:	e04080e7          	jalr	-508(ra) # 878 <vprintf>
}
 a7c:	60e2                	ld	ra,24(sp)
 a7e:	6442                	ld	s0,16(sp)
 a80:	6161                	addi	sp,sp,80
 a82:	8082                	ret

0000000000000a84 <printf>:

void
printf(const char *fmt, ...)
{
 a84:	711d                	addi	sp,sp,-96
 a86:	ec06                	sd	ra,24(sp)
 a88:	e822                	sd	s0,16(sp)
 a8a:	1000                	addi	s0,sp,32
 a8c:	e40c                	sd	a1,8(s0)
 a8e:	e810                	sd	a2,16(s0)
 a90:	ec14                	sd	a3,24(s0)
 a92:	f018                	sd	a4,32(s0)
 a94:	f41c                	sd	a5,40(s0)
 a96:	03043823          	sd	a6,48(s0)
 a9a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a9e:	00840613          	addi	a2,s0,8
 aa2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 aa6:	85aa                	mv	a1,a0
 aa8:	4505                	li	a0,1
 aaa:	00000097          	auipc	ra,0x0
 aae:	dce080e7          	jalr	-562(ra) # 878 <vprintf>
}
 ab2:	60e2                	ld	ra,24(sp)
 ab4:	6442                	ld	s0,16(sp)
 ab6:	6125                	addi	sp,sp,96
 ab8:	8082                	ret

0000000000000aba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 aba:	1141                	addi	sp,sp,-16
 abc:	e422                	sd	s0,8(sp)
 abe:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ac0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ac4:	00000797          	auipc	a5,0x0
 ac8:	2a47b783          	ld	a5,676(a5) # d68 <freep>
 acc:	a805                	j	afc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 ace:	4618                	lw	a4,8(a2)
 ad0:	9db9                	addw	a1,a1,a4
 ad2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ad6:	6398                	ld	a4,0(a5)
 ad8:	6318                	ld	a4,0(a4)
 ada:	fee53823          	sd	a4,-16(a0)
 ade:	a091                	j	b22 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 ae0:	ff852703          	lw	a4,-8(a0)
 ae4:	9e39                	addw	a2,a2,a4
 ae6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 ae8:	ff053703          	ld	a4,-16(a0)
 aec:	e398                	sd	a4,0(a5)
 aee:	a099                	j	b34 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 af0:	6398                	ld	a4,0(a5)
 af2:	00e7e463          	bltu	a5,a4,afa <free+0x40>
 af6:	00e6ea63          	bltu	a3,a4,b0a <free+0x50>
{
 afa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 afc:	fed7fae3          	bgeu	a5,a3,af0 <free+0x36>
 b00:	6398                	ld	a4,0(a5)
 b02:	00e6e463          	bltu	a3,a4,b0a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b06:	fee7eae3          	bltu	a5,a4,afa <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b0a:	ff852583          	lw	a1,-8(a0)
 b0e:	6390                	ld	a2,0(a5)
 b10:	02059713          	slli	a4,a1,0x20
 b14:	9301                	srli	a4,a4,0x20
 b16:	0712                	slli	a4,a4,0x4
 b18:	9736                	add	a4,a4,a3
 b1a:	fae60ae3          	beq	a2,a4,ace <free+0x14>
    bp->s.ptr = p->s.ptr;
 b1e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b22:	4790                	lw	a2,8(a5)
 b24:	02061713          	slli	a4,a2,0x20
 b28:	9301                	srli	a4,a4,0x20
 b2a:	0712                	slli	a4,a4,0x4
 b2c:	973e                	add	a4,a4,a5
 b2e:	fae689e3          	beq	a3,a4,ae0 <free+0x26>
  } else
    p->s.ptr = bp;
 b32:	e394                	sd	a3,0(a5)
  freep = p;
 b34:	00000717          	auipc	a4,0x0
 b38:	22f73a23          	sd	a5,564(a4) # d68 <freep>
}
 b3c:	6422                	ld	s0,8(sp)
 b3e:	0141                	addi	sp,sp,16
 b40:	8082                	ret

0000000000000b42 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b42:	7139                	addi	sp,sp,-64
 b44:	fc06                	sd	ra,56(sp)
 b46:	f822                	sd	s0,48(sp)
 b48:	f426                	sd	s1,40(sp)
 b4a:	f04a                	sd	s2,32(sp)
 b4c:	ec4e                	sd	s3,24(sp)
 b4e:	e852                	sd	s4,16(sp)
 b50:	e456                	sd	s5,8(sp)
 b52:	e05a                	sd	s6,0(sp)
 b54:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b56:	02051493          	slli	s1,a0,0x20
 b5a:	9081                	srli	s1,s1,0x20
 b5c:	04bd                	addi	s1,s1,15
 b5e:	8091                	srli	s1,s1,0x4
 b60:	0014899b          	addiw	s3,s1,1
 b64:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b66:	00000517          	auipc	a0,0x0
 b6a:	20253503          	ld	a0,514(a0) # d68 <freep>
 b6e:	c515                	beqz	a0,b9a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b70:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b72:	4798                	lw	a4,8(a5)
 b74:	02977f63          	bgeu	a4,s1,bb2 <malloc+0x70>
 b78:	8a4e                	mv	s4,s3
 b7a:	0009871b          	sext.w	a4,s3
 b7e:	6685                	lui	a3,0x1
 b80:	00d77363          	bgeu	a4,a3,b86 <malloc+0x44>
 b84:	6a05                	lui	s4,0x1
 b86:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b8a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b8e:	00000917          	auipc	s2,0x0
 b92:	1da90913          	addi	s2,s2,474 # d68 <freep>
  if(p == (char*)-1)
 b96:	5afd                	li	s5,-1
 b98:	a88d                	j	c0a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 b9a:	00008797          	auipc	a5,0x8
 b9e:	3b678793          	addi	a5,a5,950 # 8f50 <base>
 ba2:	00000717          	auipc	a4,0x0
 ba6:	1cf73323          	sd	a5,454(a4) # d68 <freep>
 baa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bac:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bb0:	b7e1                	j	b78 <malloc+0x36>
      if(p->s.size == nunits)
 bb2:	02e48b63          	beq	s1,a4,be8 <malloc+0xa6>
        p->s.size -= nunits;
 bb6:	4137073b          	subw	a4,a4,s3
 bba:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bbc:	1702                	slli	a4,a4,0x20
 bbe:	9301                	srli	a4,a4,0x20
 bc0:	0712                	slli	a4,a4,0x4
 bc2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bc4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bc8:	00000717          	auipc	a4,0x0
 bcc:	1aa73023          	sd	a0,416(a4) # d68 <freep>
      return (void*)(p + 1);
 bd0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 bd4:	70e2                	ld	ra,56(sp)
 bd6:	7442                	ld	s0,48(sp)
 bd8:	74a2                	ld	s1,40(sp)
 bda:	7902                	ld	s2,32(sp)
 bdc:	69e2                	ld	s3,24(sp)
 bde:	6a42                	ld	s4,16(sp)
 be0:	6aa2                	ld	s5,8(sp)
 be2:	6b02                	ld	s6,0(sp)
 be4:	6121                	addi	sp,sp,64
 be6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 be8:	6398                	ld	a4,0(a5)
 bea:	e118                	sd	a4,0(a0)
 bec:	bff1                	j	bc8 <malloc+0x86>
  hp->s.size = nu;
 bee:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 bf2:	0541                	addi	a0,a0,16
 bf4:	00000097          	auipc	ra,0x0
 bf8:	ec6080e7          	jalr	-314(ra) # aba <free>
  return freep;
 bfc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c00:	d971                	beqz	a0,bd4 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c02:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c04:	4798                	lw	a4,8(a5)
 c06:	fa9776e3          	bgeu	a4,s1,bb2 <malloc+0x70>
    if(p == freep)
 c0a:	00093703          	ld	a4,0(s2)
 c0e:	853e                	mv	a0,a5
 c10:	fef719e3          	bne	a4,a5,c02 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 c14:	8552                	mv	a0,s4
 c16:	00000097          	auipc	ra,0x0
 c1a:	b4e080e7          	jalr	-1202(ra) # 764 <sbrk>
  if(p == (char*)-1)
 c1e:	fd5518e3          	bne	a0,s5,bee <malloc+0xac>
        return 0;
 c22:	4501                	li	a0,0
 c24:	bf45                	j	bd4 <malloc+0x92>
