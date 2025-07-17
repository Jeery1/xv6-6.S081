
user/_alloctest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test0>:
#include "kernel/fcntl.h"
#include "kernel/memlayout.h"
#include "user/user.h"

void
test0() {
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	0880                	addi	s0,sp,80
  enum { NCHILD = 50, NFD = 10};
  int i, j;
  int fd;

  printf("filetest: start\n");
  12:	00001517          	auipc	a0,0x1
  16:	9fe50513          	addi	a0,a0,-1538 # a10 <malloc+0xe4>
  1a:	00001097          	auipc	ra,0x1
  1e:	854080e7          	jalr	-1964(ra) # 86e <printf>
  22:	03200493          	li	s1,50
    printf("test setup is wrong\n");
    exit(1);
  }

  for (i = 0; i < NCHILD; i++) {
    int pid = fork();
  26:	00000097          	auipc	ra,0x0
  2a:	498080e7          	jalr	1176(ra) # 4be <fork>
    if(pid < 0){
  2e:	00054f63          	bltz	a0,4c <test0+0x4c>
      printf("fork failed");
      exit(1);
    }
    if(pid == 0){
  32:	c915                	beqz	a0,66 <test0+0x66>
  for (i = 0; i < NCHILD; i++) {
  34:	34fd                	addiw	s1,s1,-1
  36:	f8e5                	bnez	s1,26 <test0+0x26>
  38:	03200493          	li	s1,50
      sleep(10);
      exit(0);  // no errors; exit with 0.
    }
  }

  int all_ok = 1;
  3c:	4905                	li	s2,1
  for(int i = 0; i < NCHILD; i++){
    int xstatus;
    wait(&xstatus);
    if(xstatus != 0) {
      if(all_ok == 1)
  3e:	4985                	li	s3,1
        printf("filetest: FAILED\n");
  40:	00001a97          	auipc	s5,0x1
  44:	a00a8a93          	addi	s5,s5,-1536 # a40 <malloc+0x114>
      all_ok = 0;
  48:	4a01                	li	s4,0
  4a:	a8b1                	j	a6 <test0+0xa6>
      printf("fork failed");
  4c:	00001517          	auipc	a0,0x1
  50:	9dc50513          	addi	a0,a0,-1572 # a28 <malloc+0xfc>
  54:	00001097          	auipc	ra,0x1
  58:	81a080e7          	jalr	-2022(ra) # 86e <printf>
      exit(1);
  5c:	4505                	li	a0,1
  5e:	00000097          	auipc	ra,0x0
  62:	468080e7          	jalr	1128(ra) # 4c6 <exit>
  66:	44a9                	li	s1,10
        if ((fd = open("README", O_RDONLY)) < 0) {
  68:	00001917          	auipc	s2,0x1
  6c:	9d090913          	addi	s2,s2,-1584 # a38 <malloc+0x10c>
  70:	4581                	li	a1,0
  72:	854a                	mv	a0,s2
  74:	00000097          	auipc	ra,0x0
  78:	492080e7          	jalr	1170(ra) # 506 <open>
  7c:	00054e63          	bltz	a0,98 <test0+0x98>
      for(j = 0; j < NFD; j++) {
  80:	34fd                	addiw	s1,s1,-1
  82:	f4fd                	bnez	s1,70 <test0+0x70>
      sleep(10);
  84:	4529                	li	a0,10
  86:	00000097          	auipc	ra,0x0
  8a:	4d0080e7          	jalr	1232(ra) # 556 <sleep>
      exit(0);  // no errors; exit with 0.
  8e:	4501                	li	a0,0
  90:	00000097          	auipc	ra,0x0
  94:	436080e7          	jalr	1078(ra) # 4c6 <exit>
          exit(1);
  98:	4505                	li	a0,1
  9a:	00000097          	auipc	ra,0x0
  9e:	42c080e7          	jalr	1068(ra) # 4c6 <exit>
  for(int i = 0; i < NCHILD; i++){
  a2:	34fd                	addiw	s1,s1,-1
  a4:	c09d                	beqz	s1,ca <test0+0xca>
    wait(&xstatus);
  a6:	fbc40513          	addi	a0,s0,-68
  aa:	00000097          	auipc	ra,0x0
  ae:	424080e7          	jalr	1060(ra) # 4ce <wait>
    if(xstatus != 0) {
  b2:	fbc42783          	lw	a5,-68(s0)
  b6:	d7f5                	beqz	a5,a2 <test0+0xa2>
      if(all_ok == 1)
  b8:	ff3915e3          	bne	s2,s3,a2 <test0+0xa2>
        printf("filetest: FAILED\n");
  bc:	8556                	mv	a0,s5
  be:	00000097          	auipc	ra,0x0
  c2:	7b0080e7          	jalr	1968(ra) # 86e <printf>
      all_ok = 0;
  c6:	8952                	mv	s2,s4
  c8:	bfe9                	j	a2 <test0+0xa2>
    }
  }

  if(all_ok)
  ca:	00091b63          	bnez	s2,e0 <test0+0xe0>
    printf("filetest: OK\n");
}
  ce:	60a6                	ld	ra,72(sp)
  d0:	6406                	ld	s0,64(sp)
  d2:	74e2                	ld	s1,56(sp)
  d4:	7942                	ld	s2,48(sp)
  d6:	79a2                	ld	s3,40(sp)
  d8:	7a02                	ld	s4,32(sp)
  da:	6ae2                	ld	s5,24(sp)
  dc:	6161                	addi	sp,sp,80
  de:	8082                	ret
    printf("filetest: OK\n");
  e0:	00001517          	auipc	a0,0x1
  e4:	97850513          	addi	a0,a0,-1672 # a58 <malloc+0x12c>
  e8:	00000097          	auipc	ra,0x0
  ec:	786080e7          	jalr	1926(ra) # 86e <printf>
}
  f0:	bff9                	j	ce <test0+0xce>

00000000000000f2 <test1>:

// Allocate all free memory and count how it is
void test1()
{
  f2:	7139                	addi	sp,sp,-64
  f4:	fc06                	sd	ra,56(sp)
  f6:	f822                	sd	s0,48(sp)
  f8:	f426                	sd	s1,40(sp)
  fa:	f04a                	sd	s2,32(sp)
  fc:	ec4e                	sd	s3,24(sp)
  fe:	0080                	addi	s0,sp,64
  void *a;
  int tot = 0;
  char buf[1];
  int fds[2];
  
  printf("memtest: start\n");  
 100:	00001517          	auipc	a0,0x1
 104:	96850513          	addi	a0,a0,-1688 # a68 <malloc+0x13c>
 108:	00000097          	auipc	ra,0x0
 10c:	766080e7          	jalr	1894(ra) # 86e <printf>
  if(pipe(fds) != 0){
 110:	fc040513          	addi	a0,s0,-64
 114:	00000097          	auipc	ra,0x0
 118:	3c2080e7          	jalr	962(ra) # 4d6 <pipe>
 11c:	e525                	bnez	a0,184 <test1+0x92>
 11e:	84aa                	mv	s1,a0
    printf("pipe() failed\n");
    exit(1);
  }
  int pid = fork();
 120:	00000097          	auipc	ra,0x0
 124:	39e080e7          	jalr	926(ra) # 4be <fork>
  if(pid < 0){
 128:	06054b63          	bltz	a0,19e <test1+0xac>
    printf("fork failed");
    exit(1);
  }
  if(pid == 0){
 12c:	e959                	bnez	a0,1c2 <test1+0xd0>
      close(fds[0]);
 12e:	fc042503          	lw	a0,-64(s0)
 132:	00000097          	auipc	ra,0x0
 136:	3bc080e7          	jalr	956(ra) # 4ee <close>
      while(1) {
        a = sbrk(PGSIZE);
        if (a == (char*)0xffffffffffffffffL)
 13a:	597d                	li	s2,-1
          exit(0);
        *(int *)(a+4) = 1;
 13c:	4485                	li	s1,1
        if (write(fds[1], "x", 1) != 1) {
 13e:	00001997          	auipc	s3,0x1
 142:	94a98993          	addi	s3,s3,-1718 # a88 <malloc+0x15c>
        a = sbrk(PGSIZE);
 146:	6505                	lui	a0,0x1
 148:	00000097          	auipc	ra,0x0
 14c:	406080e7          	jalr	1030(ra) # 54e <sbrk>
        if (a == (char*)0xffffffffffffffffL)
 150:	07250463          	beq	a0,s2,1b8 <test1+0xc6>
        *(int *)(a+4) = 1;
 154:	c144                	sw	s1,4(a0)
        if (write(fds[1], "x", 1) != 1) {
 156:	8626                	mv	a2,s1
 158:	85ce                	mv	a1,s3
 15a:	fc442503          	lw	a0,-60(s0)
 15e:	00000097          	auipc	ra,0x0
 162:	388080e7          	jalr	904(ra) # 4e6 <write>
 166:	fe9500e3          	beq	a0,s1,146 <test1+0x54>
          printf("write failed");
 16a:	00001517          	auipc	a0,0x1
 16e:	92650513          	addi	a0,a0,-1754 # a90 <malloc+0x164>
 172:	00000097          	auipc	ra,0x0
 176:	6fc080e7          	jalr	1788(ra) # 86e <printf>
          exit(1);
 17a:	4505                	li	a0,1
 17c:	00000097          	auipc	ra,0x0
 180:	34a080e7          	jalr	842(ra) # 4c6 <exit>
    printf("pipe() failed\n");
 184:	00001517          	auipc	a0,0x1
 188:	8f450513          	addi	a0,a0,-1804 # a78 <malloc+0x14c>
 18c:	00000097          	auipc	ra,0x0
 190:	6e2080e7          	jalr	1762(ra) # 86e <printf>
    exit(1);
 194:	4505                	li	a0,1
 196:	00000097          	auipc	ra,0x0
 19a:	330080e7          	jalr	816(ra) # 4c6 <exit>
    printf("fork failed");
 19e:	00001517          	auipc	a0,0x1
 1a2:	88a50513          	addi	a0,a0,-1910 # a28 <malloc+0xfc>
 1a6:	00000097          	auipc	ra,0x0
 1aa:	6c8080e7          	jalr	1736(ra) # 86e <printf>
    exit(1);
 1ae:	4505                	li	a0,1
 1b0:	00000097          	auipc	ra,0x0
 1b4:	316080e7          	jalr	790(ra) # 4c6 <exit>
          exit(0);
 1b8:	4501                	li	a0,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	30c080e7          	jalr	780(ra) # 4c6 <exit>
        }
      }
      exit(0);
  }
  close(fds[1]);
 1c2:	fc442503          	lw	a0,-60(s0)
 1c6:	00000097          	auipc	ra,0x0
 1ca:	328080e7          	jalr	808(ra) # 4ee <close>
  while(1) {
      if (read(fds[0], buf, 1) != 1) {
 1ce:	4605                	li	a2,1
 1d0:	fc840593          	addi	a1,s0,-56
 1d4:	fc042503          	lw	a0,-64(s0)
 1d8:	00000097          	auipc	ra,0x0
 1dc:	306080e7          	jalr	774(ra) # 4de <read>
 1e0:	4785                	li	a5,1
 1e2:	00f51463          	bne	a0,a5,1ea <test1+0xf8>
        break;
      } else {
        tot += 1;
 1e6:	2485                	addiw	s1,s1,1
      if (read(fds[0], buf, 1) != 1) {
 1e8:	b7dd                	j	1ce <test1+0xdc>
      }
  }
  //int n = (PHYSTOP-KERNBASE)/PGSIZE;
  //printf("allocated %d out of %d pages\n", tot, n);
  if(tot < 31950) {
 1ea:	67a1                	lui	a5,0x8
 1ec:	ccd78793          	addi	a5,a5,-819 # 7ccd <__global_pointer$+0x69b4>
 1f0:	0297ca63          	blt	a5,s1,224 <test1+0x132>
    printf("expected to allocate at least 31950, only got %d\n", tot);
 1f4:	85a6                	mv	a1,s1
 1f6:	00001517          	auipc	a0,0x1
 1fa:	8aa50513          	addi	a0,a0,-1878 # aa0 <malloc+0x174>
 1fe:	00000097          	auipc	ra,0x0
 202:	670080e7          	jalr	1648(ra) # 86e <printf>
    printf("memtest: FAILED\n");  
 206:	00001517          	auipc	a0,0x1
 20a:	8d250513          	addi	a0,a0,-1838 # ad8 <malloc+0x1ac>
 20e:	00000097          	auipc	ra,0x0
 212:	660080e7          	jalr	1632(ra) # 86e <printf>
  } else {
    printf("memtest: OK\n");  
  }
}
 216:	70e2                	ld	ra,56(sp)
 218:	7442                	ld	s0,48(sp)
 21a:	74a2                	ld	s1,40(sp)
 21c:	7902                	ld	s2,32(sp)
 21e:	69e2                	ld	s3,24(sp)
 220:	6121                	addi	sp,sp,64
 222:	8082                	ret
    printf("memtest: OK\n");  
 224:	00001517          	auipc	a0,0x1
 228:	8cc50513          	addi	a0,a0,-1844 # af0 <malloc+0x1c4>
 22c:	00000097          	auipc	ra,0x0
 230:	642080e7          	jalr	1602(ra) # 86e <printf>
}
 234:	b7cd                	j	216 <test1+0x124>

0000000000000236 <main>:

int
main(int argc, char *argv[])
{
 236:	1141                	addi	sp,sp,-16
 238:	e406                	sd	ra,8(sp)
 23a:	e022                	sd	s0,0(sp)
 23c:	0800                	addi	s0,sp,16
  test0();
 23e:	00000097          	auipc	ra,0x0
 242:	dc2080e7          	jalr	-574(ra) # 0 <test0>
  test1();
 246:	00000097          	auipc	ra,0x0
 24a:	eac080e7          	jalr	-340(ra) # f2 <test1>
  exit(0);
 24e:	4501                	li	a0,0
 250:	00000097          	auipc	ra,0x0
 254:	276080e7          	jalr	630(ra) # 4c6 <exit>

0000000000000258 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 25e:	87aa                	mv	a5,a0
 260:	0585                	addi	a1,a1,1
 262:	0785                	addi	a5,a5,1
 264:	fff5c703          	lbu	a4,-1(a1)
 268:	fee78fa3          	sb	a4,-1(a5)
 26c:	fb75                	bnez	a4,260 <strcpy+0x8>
    ;
  return os;
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret

0000000000000274 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 27a:	00054783          	lbu	a5,0(a0)
 27e:	cb91                	beqz	a5,292 <strcmp+0x1e>
 280:	0005c703          	lbu	a4,0(a1)
 284:	00f71763          	bne	a4,a5,292 <strcmp+0x1e>
    p++, q++;
 288:	0505                	addi	a0,a0,1
 28a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 28c:	00054783          	lbu	a5,0(a0)
 290:	fbe5                	bnez	a5,280 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 292:	0005c503          	lbu	a0,0(a1)
}
 296:	40a7853b          	subw	a0,a5,a0
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret

00000000000002a0 <strlen>:

uint
strlen(const char *s)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	cf91                	beqz	a5,2c6 <strlen+0x26>
 2ac:	0505                	addi	a0,a0,1
 2ae:	87aa                	mv	a5,a0
 2b0:	4685                	li	a3,1
 2b2:	9e89                	subw	a3,a3,a0
 2b4:	00f6853b          	addw	a0,a3,a5
 2b8:	0785                	addi	a5,a5,1
 2ba:	fff7c703          	lbu	a4,-1(a5)
 2be:	fb7d                	bnez	a4,2b4 <strlen+0x14>
    ;
  return n;
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
  for(n = 0; s[n]; n++)
 2c6:	4501                	li	a0,0
 2c8:	bfe5                	j	2c0 <strlen+0x20>

00000000000002ca <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e422                	sd	s0,8(sp)
 2ce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2d0:	ca19                	beqz	a2,2e6 <memset+0x1c>
 2d2:	87aa                	mv	a5,a0
 2d4:	1602                	slli	a2,a2,0x20
 2d6:	9201                	srli	a2,a2,0x20
 2d8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2dc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2e0:	0785                	addi	a5,a5,1
 2e2:	fee79de3          	bne	a5,a4,2dc <memset+0x12>
  }
  return dst;
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret

00000000000002ec <strchr>:

char*
strchr(const char *s, char c)
{
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2f2:	00054783          	lbu	a5,0(a0)
 2f6:	cb99                	beqz	a5,30c <strchr+0x20>
    if(*s == c)
 2f8:	00f58763          	beq	a1,a5,306 <strchr+0x1a>
  for(; *s; s++)
 2fc:	0505                	addi	a0,a0,1
 2fe:	00054783          	lbu	a5,0(a0)
 302:	fbfd                	bnez	a5,2f8 <strchr+0xc>
      return (char*)s;
  return 0;
 304:	4501                	li	a0,0
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  return 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <strchr+0x1a>

0000000000000310 <gets>:

char*
gets(char *buf, int max)
{
 310:	711d                	addi	sp,sp,-96
 312:	ec86                	sd	ra,88(sp)
 314:	e8a2                	sd	s0,80(sp)
 316:	e4a6                	sd	s1,72(sp)
 318:	e0ca                	sd	s2,64(sp)
 31a:	fc4e                	sd	s3,56(sp)
 31c:	f852                	sd	s4,48(sp)
 31e:	f456                	sd	s5,40(sp)
 320:	f05a                	sd	s6,32(sp)
 322:	ec5e                	sd	s7,24(sp)
 324:	1080                	addi	s0,sp,96
 326:	8baa                	mv	s7,a0
 328:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 32a:	892a                	mv	s2,a0
 32c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 32e:	4aa9                	li	s5,10
 330:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 332:	89a6                	mv	s3,s1
 334:	2485                	addiw	s1,s1,1
 336:	0344d863          	bge	s1,s4,366 <gets+0x56>
    cc = read(0, &c, 1);
 33a:	4605                	li	a2,1
 33c:	faf40593          	addi	a1,s0,-81
 340:	4501                	li	a0,0
 342:	00000097          	auipc	ra,0x0
 346:	19c080e7          	jalr	412(ra) # 4de <read>
    if(cc < 1)
 34a:	00a05e63          	blez	a0,366 <gets+0x56>
    buf[i++] = c;
 34e:	faf44783          	lbu	a5,-81(s0)
 352:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 356:	01578763          	beq	a5,s5,364 <gets+0x54>
 35a:	0905                	addi	s2,s2,1
 35c:	fd679be3          	bne	a5,s6,332 <gets+0x22>
  for(i=0; i+1 < max; ){
 360:	89a6                	mv	s3,s1
 362:	a011                	j	366 <gets+0x56>
 364:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 366:	99de                	add	s3,s3,s7
 368:	00098023          	sb	zero,0(s3)
  return buf;
}
 36c:	855e                	mv	a0,s7
 36e:	60e6                	ld	ra,88(sp)
 370:	6446                	ld	s0,80(sp)
 372:	64a6                	ld	s1,72(sp)
 374:	6906                	ld	s2,64(sp)
 376:	79e2                	ld	s3,56(sp)
 378:	7a42                	ld	s4,48(sp)
 37a:	7aa2                	ld	s5,40(sp)
 37c:	7b02                	ld	s6,32(sp)
 37e:	6be2                	ld	s7,24(sp)
 380:	6125                	addi	sp,sp,96
 382:	8082                	ret

0000000000000384 <stat>:

int
stat(const char *n, struct stat *st)
{
 384:	1101                	addi	sp,sp,-32
 386:	ec06                	sd	ra,24(sp)
 388:	e822                	sd	s0,16(sp)
 38a:	e426                	sd	s1,8(sp)
 38c:	e04a                	sd	s2,0(sp)
 38e:	1000                	addi	s0,sp,32
 390:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 392:	4581                	li	a1,0
 394:	00000097          	auipc	ra,0x0
 398:	172080e7          	jalr	370(ra) # 506 <open>
  if(fd < 0)
 39c:	02054563          	bltz	a0,3c6 <stat+0x42>
 3a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3a2:	85ca                	mv	a1,s2
 3a4:	00000097          	auipc	ra,0x0
 3a8:	17a080e7          	jalr	378(ra) # 51e <fstat>
 3ac:	892a                	mv	s2,a0
  close(fd);
 3ae:	8526                	mv	a0,s1
 3b0:	00000097          	auipc	ra,0x0
 3b4:	13e080e7          	jalr	318(ra) # 4ee <close>
  return r;
}
 3b8:	854a                	mv	a0,s2
 3ba:	60e2                	ld	ra,24(sp)
 3bc:	6442                	ld	s0,16(sp)
 3be:	64a2                	ld	s1,8(sp)
 3c0:	6902                	ld	s2,0(sp)
 3c2:	6105                	addi	sp,sp,32
 3c4:	8082                	ret
    return -1;
 3c6:	597d                	li	s2,-1
 3c8:	bfc5                	j	3b8 <stat+0x34>

00000000000003ca <atoi>:

int
atoi(const char *s)
{
 3ca:	1141                	addi	sp,sp,-16
 3cc:	e422                	sd	s0,8(sp)
 3ce:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3d0:	00054603          	lbu	a2,0(a0)
 3d4:	fd06079b          	addiw	a5,a2,-48
 3d8:	0ff7f793          	andi	a5,a5,255
 3dc:	4725                	li	a4,9
 3de:	02f76963          	bltu	a4,a5,410 <atoi+0x46>
 3e2:	86aa                	mv	a3,a0
  n = 0;
 3e4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3e6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3e8:	0685                	addi	a3,a3,1
 3ea:	0025179b          	slliw	a5,a0,0x2
 3ee:	9fa9                	addw	a5,a5,a0
 3f0:	0017979b          	slliw	a5,a5,0x1
 3f4:	9fb1                	addw	a5,a5,a2
 3f6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3fa:	0006c603          	lbu	a2,0(a3)
 3fe:	fd06071b          	addiw	a4,a2,-48
 402:	0ff77713          	andi	a4,a4,255
 406:	fee5f1e3          	bgeu	a1,a4,3e8 <atoi+0x1e>
  return n;
}
 40a:	6422                	ld	s0,8(sp)
 40c:	0141                	addi	sp,sp,16
 40e:	8082                	ret
  n = 0;
 410:	4501                	li	a0,0
 412:	bfe5                	j	40a <atoi+0x40>

0000000000000414 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 414:	1141                	addi	sp,sp,-16
 416:	e422                	sd	s0,8(sp)
 418:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 41a:	02b57463          	bgeu	a0,a1,442 <memmove+0x2e>
    while(n-- > 0)
 41e:	00c05f63          	blez	a2,43c <memmove+0x28>
 422:	1602                	slli	a2,a2,0x20
 424:	9201                	srli	a2,a2,0x20
 426:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 42a:	872a                	mv	a4,a0
      *dst++ = *src++;
 42c:	0585                	addi	a1,a1,1
 42e:	0705                	addi	a4,a4,1
 430:	fff5c683          	lbu	a3,-1(a1)
 434:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 438:	fee79ae3          	bne	a5,a4,42c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 43c:	6422                	ld	s0,8(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret
    dst += n;
 442:	00c50733          	add	a4,a0,a2
    src += n;
 446:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 448:	fec05ae3          	blez	a2,43c <memmove+0x28>
 44c:	fff6079b          	addiw	a5,a2,-1
 450:	1782                	slli	a5,a5,0x20
 452:	9381                	srli	a5,a5,0x20
 454:	fff7c793          	not	a5,a5
 458:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 45a:	15fd                	addi	a1,a1,-1
 45c:	177d                	addi	a4,a4,-1
 45e:	0005c683          	lbu	a3,0(a1)
 462:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 466:	fee79ae3          	bne	a5,a4,45a <memmove+0x46>
 46a:	bfc9                	j	43c <memmove+0x28>

000000000000046c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 46c:	1141                	addi	sp,sp,-16
 46e:	e422                	sd	s0,8(sp)
 470:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 472:	ca05                	beqz	a2,4a2 <memcmp+0x36>
 474:	fff6069b          	addiw	a3,a2,-1
 478:	1682                	slli	a3,a3,0x20
 47a:	9281                	srli	a3,a3,0x20
 47c:	0685                	addi	a3,a3,1
 47e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 480:	00054783          	lbu	a5,0(a0)
 484:	0005c703          	lbu	a4,0(a1)
 488:	00e79863          	bne	a5,a4,498 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 48c:	0505                	addi	a0,a0,1
    p2++;
 48e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 490:	fed518e3          	bne	a0,a3,480 <memcmp+0x14>
  }
  return 0;
 494:	4501                	li	a0,0
 496:	a019                	j	49c <memcmp+0x30>
      return *p1 - *p2;
 498:	40e7853b          	subw	a0,a5,a4
}
 49c:	6422                	ld	s0,8(sp)
 49e:	0141                	addi	sp,sp,16
 4a0:	8082                	ret
  return 0;
 4a2:	4501                	li	a0,0
 4a4:	bfe5                	j	49c <memcmp+0x30>

00000000000004a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4a6:	1141                	addi	sp,sp,-16
 4a8:	e406                	sd	ra,8(sp)
 4aa:	e022                	sd	s0,0(sp)
 4ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4ae:	00000097          	auipc	ra,0x0
 4b2:	f66080e7          	jalr	-154(ra) # 414 <memmove>
}
 4b6:	60a2                	ld	ra,8(sp)
 4b8:	6402                	ld	s0,0(sp)
 4ba:	0141                	addi	sp,sp,16
 4bc:	8082                	ret

00000000000004be <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4be:	4885                	li	a7,1
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4c6:	4889                	li	a7,2
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ce:	488d                	li	a7,3
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4d6:	4891                	li	a7,4
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <read>:
.global read
read:
 li a7, SYS_read
 4de:	4895                	li	a7,5
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <write>:
.global write
write:
 li a7, SYS_write
 4e6:	48c1                	li	a7,16
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <close>:
.global close
close:
 li a7, SYS_close
 4ee:	48d5                	li	a7,21
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4f6:	4899                	li	a7,6
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <exec>:
.global exec
exec:
 li a7, SYS_exec
 4fe:	489d                	li	a7,7
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <open>:
.global open
open:
 li a7, SYS_open
 506:	48bd                	li	a7,15
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 50e:	48c5                	li	a7,17
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 516:	48c9                	li	a7,18
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 51e:	48a1                	li	a7,8
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <link>:
.global link
link:
 li a7, SYS_link
 526:	48cd                	li	a7,19
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 52e:	48d1                	li	a7,20
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 536:	48a5                	li	a7,9
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <dup>:
.global dup
dup:
 li a7, SYS_dup
 53e:	48a9                	li	a7,10
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 546:	48ad                	li	a7,11
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 54e:	48b1                	li	a7,12
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 556:	48b5                	li	a7,13
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 55e:	48b9                	li	a7,14
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 566:	48d9                	li	a7,22
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <crash>:
.global crash
crash:
 li a7, SYS_crash
 56e:	48dd                	li	a7,23
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <mount>:
.global mount
mount:
 li a7, SYS_mount
 576:	48e1                	li	a7,24
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <umount>:
.global umount
umount:
 li a7, SYS_umount
 57e:	48e5                	li	a7,25
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 586:	48e9                	li	a7,26
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 58e:	48ed                	li	a7,27
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 596:	1101                	addi	sp,sp,-32
 598:	ec06                	sd	ra,24(sp)
 59a:	e822                	sd	s0,16(sp)
 59c:	1000                	addi	s0,sp,32
 59e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5a2:	4605                	li	a2,1
 5a4:	fef40593          	addi	a1,s0,-17
 5a8:	00000097          	auipc	ra,0x0
 5ac:	f3e080e7          	jalr	-194(ra) # 4e6 <write>
}
 5b0:	60e2                	ld	ra,24(sp)
 5b2:	6442                	ld	s0,16(sp)
 5b4:	6105                	addi	sp,sp,32
 5b6:	8082                	ret

00000000000005b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5b8:	7139                	addi	sp,sp,-64
 5ba:	fc06                	sd	ra,56(sp)
 5bc:	f822                	sd	s0,48(sp)
 5be:	f426                	sd	s1,40(sp)
 5c0:	f04a                	sd	s2,32(sp)
 5c2:	ec4e                	sd	s3,24(sp)
 5c4:	0080                	addi	s0,sp,64
 5c6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5c8:	c299                	beqz	a3,5ce <printint+0x16>
 5ca:	0805c863          	bltz	a1,65a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5ce:	2581                	sext.w	a1,a1
  neg = 0;
 5d0:	4881                	li	a7,0
 5d2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5d6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5d8:	2601                	sext.w	a2,a2
 5da:	00000517          	auipc	a0,0x0
 5de:	52e50513          	addi	a0,a0,1326 # b08 <digits>
 5e2:	883a                	mv	a6,a4
 5e4:	2705                	addiw	a4,a4,1
 5e6:	02c5f7bb          	remuw	a5,a1,a2
 5ea:	1782                	slli	a5,a5,0x20
 5ec:	9381                	srli	a5,a5,0x20
 5ee:	97aa                	add	a5,a5,a0
 5f0:	0007c783          	lbu	a5,0(a5)
 5f4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5f8:	0005879b          	sext.w	a5,a1
 5fc:	02c5d5bb          	divuw	a1,a1,a2
 600:	0685                	addi	a3,a3,1
 602:	fec7f0e3          	bgeu	a5,a2,5e2 <printint+0x2a>
  if(neg)
 606:	00088b63          	beqz	a7,61c <printint+0x64>
    buf[i++] = '-';
 60a:	fd040793          	addi	a5,s0,-48
 60e:	973e                	add	a4,a4,a5
 610:	02d00793          	li	a5,45
 614:	fef70823          	sb	a5,-16(a4)
 618:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 61c:	02e05863          	blez	a4,64c <printint+0x94>
 620:	fc040793          	addi	a5,s0,-64
 624:	00e78933          	add	s2,a5,a4
 628:	fff78993          	addi	s3,a5,-1
 62c:	99ba                	add	s3,s3,a4
 62e:	377d                	addiw	a4,a4,-1
 630:	1702                	slli	a4,a4,0x20
 632:	9301                	srli	a4,a4,0x20
 634:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 638:	fff94583          	lbu	a1,-1(s2)
 63c:	8526                	mv	a0,s1
 63e:	00000097          	auipc	ra,0x0
 642:	f58080e7          	jalr	-168(ra) # 596 <putc>
  while(--i >= 0)
 646:	197d                	addi	s2,s2,-1
 648:	ff3918e3          	bne	s2,s3,638 <printint+0x80>
}
 64c:	70e2                	ld	ra,56(sp)
 64e:	7442                	ld	s0,48(sp)
 650:	74a2                	ld	s1,40(sp)
 652:	7902                	ld	s2,32(sp)
 654:	69e2                	ld	s3,24(sp)
 656:	6121                	addi	sp,sp,64
 658:	8082                	ret
    x = -xx;
 65a:	40b005bb          	negw	a1,a1
    neg = 1;
 65e:	4885                	li	a7,1
    x = -xx;
 660:	bf8d                	j	5d2 <printint+0x1a>

0000000000000662 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 662:	7119                	addi	sp,sp,-128
 664:	fc86                	sd	ra,120(sp)
 666:	f8a2                	sd	s0,112(sp)
 668:	f4a6                	sd	s1,104(sp)
 66a:	f0ca                	sd	s2,96(sp)
 66c:	ecce                	sd	s3,88(sp)
 66e:	e8d2                	sd	s4,80(sp)
 670:	e4d6                	sd	s5,72(sp)
 672:	e0da                	sd	s6,64(sp)
 674:	fc5e                	sd	s7,56(sp)
 676:	f862                	sd	s8,48(sp)
 678:	f466                	sd	s9,40(sp)
 67a:	f06a                	sd	s10,32(sp)
 67c:	ec6e                	sd	s11,24(sp)
 67e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 680:	0005c903          	lbu	s2,0(a1)
 684:	18090f63          	beqz	s2,822 <vprintf+0x1c0>
 688:	8aaa                	mv	s5,a0
 68a:	8b32                	mv	s6,a2
 68c:	00158493          	addi	s1,a1,1
  state = 0;
 690:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 692:	02500a13          	li	s4,37
      if(c == 'd'){
 696:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 69a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 69e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6a2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a6:	00000b97          	auipc	s7,0x0
 6aa:	462b8b93          	addi	s7,s7,1122 # b08 <digits>
 6ae:	a839                	j	6cc <vprintf+0x6a>
        putc(fd, c);
 6b0:	85ca                	mv	a1,s2
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	ee2080e7          	jalr	-286(ra) # 596 <putc>
 6bc:	a019                	j	6c2 <vprintf+0x60>
    } else if(state == '%'){
 6be:	01498f63          	beq	s3,s4,6dc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6c2:	0485                	addi	s1,s1,1
 6c4:	fff4c903          	lbu	s2,-1(s1)
 6c8:	14090d63          	beqz	s2,822 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 6cc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6d0:	fe0997e3          	bnez	s3,6be <vprintf+0x5c>
      if(c == '%'){
 6d4:	fd479ee3          	bne	a5,s4,6b0 <vprintf+0x4e>
        state = '%';
 6d8:	89be                	mv	s3,a5
 6da:	b7e5                	j	6c2 <vprintf+0x60>
      if(c == 'd'){
 6dc:	05878063          	beq	a5,s8,71c <vprintf+0xba>
      } else if(c == 'l') {
 6e0:	05978c63          	beq	a5,s9,738 <vprintf+0xd6>
      } else if(c == 'x') {
 6e4:	07a78863          	beq	a5,s10,754 <vprintf+0xf2>
      } else if(c == 'p') {
 6e8:	09b78463          	beq	a5,s11,770 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6ec:	07300713          	li	a4,115
 6f0:	0ce78663          	beq	a5,a4,7bc <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6f4:	06300713          	li	a4,99
 6f8:	0ee78e63          	beq	a5,a4,7f4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6fc:	11478863          	beq	a5,s4,80c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 700:	85d2                	mv	a1,s4
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	e92080e7          	jalr	-366(ra) # 596 <putc>
        putc(fd, c);
 70c:	85ca                	mv	a1,s2
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	e86080e7          	jalr	-378(ra) # 596 <putc>
      }
      state = 0;
 718:	4981                	li	s3,0
 71a:	b765                	j	6c2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 71c:	008b0913          	addi	s2,s6,8
 720:	4685                	li	a3,1
 722:	4629                	li	a2,10
 724:	000b2583          	lw	a1,0(s6)
 728:	8556                	mv	a0,s5
 72a:	00000097          	auipc	ra,0x0
 72e:	e8e080e7          	jalr	-370(ra) # 5b8 <printint>
 732:	8b4a                	mv	s6,s2
      state = 0;
 734:	4981                	li	s3,0
 736:	b771                	j	6c2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 738:	008b0913          	addi	s2,s6,8
 73c:	4681                	li	a3,0
 73e:	4629                	li	a2,10
 740:	000b2583          	lw	a1,0(s6)
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	e72080e7          	jalr	-398(ra) # 5b8 <printint>
 74e:	8b4a                	mv	s6,s2
      state = 0;
 750:	4981                	li	s3,0
 752:	bf85                	j	6c2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 754:	008b0913          	addi	s2,s6,8
 758:	4681                	li	a3,0
 75a:	4641                	li	a2,16
 75c:	000b2583          	lw	a1,0(s6)
 760:	8556                	mv	a0,s5
 762:	00000097          	auipc	ra,0x0
 766:	e56080e7          	jalr	-426(ra) # 5b8 <printint>
 76a:	8b4a                	mv	s6,s2
      state = 0;
 76c:	4981                	li	s3,0
 76e:	bf91                	j	6c2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 770:	008b0793          	addi	a5,s6,8
 774:	f8f43423          	sd	a5,-120(s0)
 778:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 77c:	03000593          	li	a1,48
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	e14080e7          	jalr	-492(ra) # 596 <putc>
  putc(fd, 'x');
 78a:	85ea                	mv	a1,s10
 78c:	8556                	mv	a0,s5
 78e:	00000097          	auipc	ra,0x0
 792:	e08080e7          	jalr	-504(ra) # 596 <putc>
 796:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 798:	03c9d793          	srli	a5,s3,0x3c
 79c:	97de                	add	a5,a5,s7
 79e:	0007c583          	lbu	a1,0(a5)
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	df2080e7          	jalr	-526(ra) # 596 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ac:	0992                	slli	s3,s3,0x4
 7ae:	397d                	addiw	s2,s2,-1
 7b0:	fe0914e3          	bnez	s2,798 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 7b4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7b8:	4981                	li	s3,0
 7ba:	b721                	j	6c2 <vprintf+0x60>
        s = va_arg(ap, char*);
 7bc:	008b0993          	addi	s3,s6,8
 7c0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 7c4:	02090163          	beqz	s2,7e6 <vprintf+0x184>
        while(*s != 0){
 7c8:	00094583          	lbu	a1,0(s2)
 7cc:	c9a1                	beqz	a1,81c <vprintf+0x1ba>
          putc(fd, *s);
 7ce:	8556                	mv	a0,s5
 7d0:	00000097          	auipc	ra,0x0
 7d4:	dc6080e7          	jalr	-570(ra) # 596 <putc>
          s++;
 7d8:	0905                	addi	s2,s2,1
        while(*s != 0){
 7da:	00094583          	lbu	a1,0(s2)
 7de:	f9e5                	bnez	a1,7ce <vprintf+0x16c>
        s = va_arg(ap, char*);
 7e0:	8b4e                	mv	s6,s3
      state = 0;
 7e2:	4981                	li	s3,0
 7e4:	bdf9                	j	6c2 <vprintf+0x60>
          s = "(null)";
 7e6:	00000917          	auipc	s2,0x0
 7ea:	31a90913          	addi	s2,s2,794 # b00 <malloc+0x1d4>
        while(*s != 0){
 7ee:	02800593          	li	a1,40
 7f2:	bff1                	j	7ce <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7f4:	008b0913          	addi	s2,s6,8
 7f8:	000b4583          	lbu	a1,0(s6)
 7fc:	8556                	mv	a0,s5
 7fe:	00000097          	auipc	ra,0x0
 802:	d98080e7          	jalr	-616(ra) # 596 <putc>
 806:	8b4a                	mv	s6,s2
      state = 0;
 808:	4981                	li	s3,0
 80a:	bd65                	j	6c2 <vprintf+0x60>
        putc(fd, c);
 80c:	85d2                	mv	a1,s4
 80e:	8556                	mv	a0,s5
 810:	00000097          	auipc	ra,0x0
 814:	d86080e7          	jalr	-634(ra) # 596 <putc>
      state = 0;
 818:	4981                	li	s3,0
 81a:	b565                	j	6c2 <vprintf+0x60>
        s = va_arg(ap, char*);
 81c:	8b4e                	mv	s6,s3
      state = 0;
 81e:	4981                	li	s3,0
 820:	b54d                	j	6c2 <vprintf+0x60>
    }
  }
}
 822:	70e6                	ld	ra,120(sp)
 824:	7446                	ld	s0,112(sp)
 826:	74a6                	ld	s1,104(sp)
 828:	7906                	ld	s2,96(sp)
 82a:	69e6                	ld	s3,88(sp)
 82c:	6a46                	ld	s4,80(sp)
 82e:	6aa6                	ld	s5,72(sp)
 830:	6b06                	ld	s6,64(sp)
 832:	7be2                	ld	s7,56(sp)
 834:	7c42                	ld	s8,48(sp)
 836:	7ca2                	ld	s9,40(sp)
 838:	7d02                	ld	s10,32(sp)
 83a:	6de2                	ld	s11,24(sp)
 83c:	6109                	addi	sp,sp,128
 83e:	8082                	ret

0000000000000840 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 840:	715d                	addi	sp,sp,-80
 842:	ec06                	sd	ra,24(sp)
 844:	e822                	sd	s0,16(sp)
 846:	1000                	addi	s0,sp,32
 848:	e010                	sd	a2,0(s0)
 84a:	e414                	sd	a3,8(s0)
 84c:	e818                	sd	a4,16(s0)
 84e:	ec1c                	sd	a5,24(s0)
 850:	03043023          	sd	a6,32(s0)
 854:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 858:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 85c:	8622                	mv	a2,s0
 85e:	00000097          	auipc	ra,0x0
 862:	e04080e7          	jalr	-508(ra) # 662 <vprintf>
}
 866:	60e2                	ld	ra,24(sp)
 868:	6442                	ld	s0,16(sp)
 86a:	6161                	addi	sp,sp,80
 86c:	8082                	ret

000000000000086e <printf>:

void
printf(const char *fmt, ...)
{
 86e:	711d                	addi	sp,sp,-96
 870:	ec06                	sd	ra,24(sp)
 872:	e822                	sd	s0,16(sp)
 874:	1000                	addi	s0,sp,32
 876:	e40c                	sd	a1,8(s0)
 878:	e810                	sd	a2,16(s0)
 87a:	ec14                	sd	a3,24(s0)
 87c:	f018                	sd	a4,32(s0)
 87e:	f41c                	sd	a5,40(s0)
 880:	03043823          	sd	a6,48(s0)
 884:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 888:	00840613          	addi	a2,s0,8
 88c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 890:	85aa                	mv	a1,a0
 892:	4505                	li	a0,1
 894:	00000097          	auipc	ra,0x0
 898:	dce080e7          	jalr	-562(ra) # 662 <vprintf>
}
 89c:	60e2                	ld	ra,24(sp)
 89e:	6442                	ld	s0,16(sp)
 8a0:	6125                	addi	sp,sp,96
 8a2:	8082                	ret

00000000000008a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8a4:	1141                	addi	sp,sp,-16
 8a6:	e422                	sd	s0,8(sp)
 8a8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8aa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ae:	00000797          	auipc	a5,0x0
 8b2:	2727b783          	ld	a5,626(a5) # b20 <freep>
 8b6:	a805                	j	8e6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8b8:	4618                	lw	a4,8(a2)
 8ba:	9db9                	addw	a1,a1,a4
 8bc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c0:	6398                	ld	a4,0(a5)
 8c2:	6318                	ld	a4,0(a4)
 8c4:	fee53823          	sd	a4,-16(a0)
 8c8:	a091                	j	90c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8ca:	ff852703          	lw	a4,-8(a0)
 8ce:	9e39                	addw	a2,a2,a4
 8d0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8d2:	ff053703          	ld	a4,-16(a0)
 8d6:	e398                	sd	a4,0(a5)
 8d8:	a099                	j	91e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8da:	6398                	ld	a4,0(a5)
 8dc:	00e7e463          	bltu	a5,a4,8e4 <free+0x40>
 8e0:	00e6ea63          	bltu	a3,a4,8f4 <free+0x50>
{
 8e4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e6:	fed7fae3          	bgeu	a5,a3,8da <free+0x36>
 8ea:	6398                	ld	a4,0(a5)
 8ec:	00e6e463          	bltu	a3,a4,8f4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f0:	fee7eae3          	bltu	a5,a4,8e4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8f4:	ff852583          	lw	a1,-8(a0)
 8f8:	6390                	ld	a2,0(a5)
 8fa:	02059713          	slli	a4,a1,0x20
 8fe:	9301                	srli	a4,a4,0x20
 900:	0712                	slli	a4,a4,0x4
 902:	9736                	add	a4,a4,a3
 904:	fae60ae3          	beq	a2,a4,8b8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 908:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 90c:	4790                	lw	a2,8(a5)
 90e:	02061713          	slli	a4,a2,0x20
 912:	9301                	srli	a4,a4,0x20
 914:	0712                	slli	a4,a4,0x4
 916:	973e                	add	a4,a4,a5
 918:	fae689e3          	beq	a3,a4,8ca <free+0x26>
  } else
    p->s.ptr = bp;
 91c:	e394                	sd	a3,0(a5)
  freep = p;
 91e:	00000717          	auipc	a4,0x0
 922:	20f73123          	sd	a5,514(a4) # b20 <freep>
}
 926:	6422                	ld	s0,8(sp)
 928:	0141                	addi	sp,sp,16
 92a:	8082                	ret

000000000000092c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 92c:	7139                	addi	sp,sp,-64
 92e:	fc06                	sd	ra,56(sp)
 930:	f822                	sd	s0,48(sp)
 932:	f426                	sd	s1,40(sp)
 934:	f04a                	sd	s2,32(sp)
 936:	ec4e                	sd	s3,24(sp)
 938:	e852                	sd	s4,16(sp)
 93a:	e456                	sd	s5,8(sp)
 93c:	e05a                	sd	s6,0(sp)
 93e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 940:	02051493          	slli	s1,a0,0x20
 944:	9081                	srli	s1,s1,0x20
 946:	04bd                	addi	s1,s1,15
 948:	8091                	srli	s1,s1,0x4
 94a:	0014899b          	addiw	s3,s1,1
 94e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 950:	00000517          	auipc	a0,0x0
 954:	1d053503          	ld	a0,464(a0) # b20 <freep>
 958:	c515                	beqz	a0,984 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95c:	4798                	lw	a4,8(a5)
 95e:	02977f63          	bgeu	a4,s1,99c <malloc+0x70>
 962:	8a4e                	mv	s4,s3
 964:	0009871b          	sext.w	a4,s3
 968:	6685                	lui	a3,0x1
 96a:	00d77363          	bgeu	a4,a3,970 <malloc+0x44>
 96e:	6a05                	lui	s4,0x1
 970:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 974:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 978:	00000917          	auipc	s2,0x0
 97c:	1a890913          	addi	s2,s2,424 # b20 <freep>
  if(p == (char*)-1)
 980:	5afd                	li	s5,-1
 982:	a88d                	j	9f4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 984:	00000797          	auipc	a5,0x0
 988:	1a478793          	addi	a5,a5,420 # b28 <base>
 98c:	00000717          	auipc	a4,0x0
 990:	18f73a23          	sd	a5,404(a4) # b20 <freep>
 994:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 996:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 99a:	b7e1                	j	962 <malloc+0x36>
      if(p->s.size == nunits)
 99c:	02e48b63          	beq	s1,a4,9d2 <malloc+0xa6>
        p->s.size -= nunits;
 9a0:	4137073b          	subw	a4,a4,s3
 9a4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9a6:	1702                	slli	a4,a4,0x20
 9a8:	9301                	srli	a4,a4,0x20
 9aa:	0712                	slli	a4,a4,0x4
 9ac:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9ae:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9b2:	00000717          	auipc	a4,0x0
 9b6:	16a73723          	sd	a0,366(a4) # b20 <freep>
      return (void*)(p + 1);
 9ba:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9be:	70e2                	ld	ra,56(sp)
 9c0:	7442                	ld	s0,48(sp)
 9c2:	74a2                	ld	s1,40(sp)
 9c4:	7902                	ld	s2,32(sp)
 9c6:	69e2                	ld	s3,24(sp)
 9c8:	6a42                	ld	s4,16(sp)
 9ca:	6aa2                	ld	s5,8(sp)
 9cc:	6b02                	ld	s6,0(sp)
 9ce:	6121                	addi	sp,sp,64
 9d0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9d2:	6398                	ld	a4,0(a5)
 9d4:	e118                	sd	a4,0(a0)
 9d6:	bff1                	j	9b2 <malloc+0x86>
  hp->s.size = nu;
 9d8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9dc:	0541                	addi	a0,a0,16
 9de:	00000097          	auipc	ra,0x0
 9e2:	ec6080e7          	jalr	-314(ra) # 8a4 <free>
  return freep;
 9e6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ea:	d971                	beqz	a0,9be <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ee:	4798                	lw	a4,8(a5)
 9f0:	fa9776e3          	bgeu	a4,s1,99c <malloc+0x70>
    if(p == freep)
 9f4:	00093703          	ld	a4,0(s2)
 9f8:	853e                	mv	a0,a5
 9fa:	fef719e3          	bne	a4,a5,9ec <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9fe:	8552                	mv	a0,s4
 a00:	00000097          	auipc	ra,0x0
 a04:	b4e080e7          	jalr	-1202(ra) # 54e <sbrk>
  if(p == (char*)-1)
 a08:	fd5518e3          	bne	a0,s5,9d8 <malloc+0xac>
        return 0;
 a0c:	4501                	li	a0,0
 a0e:	bf45                	j	9be <malloc+0x92>
