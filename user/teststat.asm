
user/_teststat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
  uint ino;    // Inode number
  short nlink; // Number of links to file
  uint size;   // Size of file in bytes
};

int main() {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
  struct stat st;
  int fd = open("/", 0);
   a:	4581                	li	a1,0
   c:	00000517          	auipc	a0,0x0
  10:	7dc50513          	addi	a0,a0,2012 # 7e8 <malloc+0xe6>
  14:	00000097          	auipc	ra,0x0
  18:	2f0080e7          	jalr	752(ra) # 304 <open>
  1c:	84aa                	mv	s1,a0
  fstat(fd, &st);
  1e:	fc840593          	addi	a1,s0,-56
  22:	00000097          	auipc	ra,0x0
  26:	2fa080e7          	jalr	762(ra) # 31c <fstat>
  printf("type=%d ino=%d\n", st.type, st.ino);
  2a:	fd042603          	lw	a2,-48(s0)
  2e:	fc841583          	lh	a1,-56(s0)
  32:	00000517          	auipc	a0,0x0
  36:	7be50513          	addi	a0,a0,1982 # 7f0 <malloc+0xee>
  3a:	00000097          	auipc	ra,0x0
  3e:	60a080e7          	jalr	1546(ra) # 644 <printf>
  close(fd);
  42:	8526                	mv	a0,s1
  44:	00000097          	auipc	ra,0x0
  48:	2a8080e7          	jalr	680(ra) # 2ec <close>
  exit(0);
  4c:	4501                	li	a0,0
  4e:	00000097          	auipc	ra,0x0
  52:	276080e7          	jalr	630(ra) # 2c4 <exit>

0000000000000056 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  56:	1141                	addi	sp,sp,-16
  58:	e422                	sd	s0,8(sp)
  5a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  5c:	87aa                	mv	a5,a0
  5e:	0585                	addi	a1,a1,1
  60:	0785                	addi	a5,a5,1
  62:	fff5c703          	lbu	a4,-1(a1)
  66:	fee78fa3          	sb	a4,-1(a5)
  6a:	fb75                	bnez	a4,5e <strcpy+0x8>
    ;
  return os;
}
  6c:	6422                	ld	s0,8(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret

0000000000000072 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  78:	00054783          	lbu	a5,0(a0)
  7c:	cb91                	beqz	a5,90 <strcmp+0x1e>
  7e:	0005c703          	lbu	a4,0(a1)
  82:	00f71763          	bne	a4,a5,90 <strcmp+0x1e>
    p++, q++;
  86:	0505                	addi	a0,a0,1
  88:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  8a:	00054783          	lbu	a5,0(a0)
  8e:	fbe5                	bnez	a5,7e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  90:	0005c503          	lbu	a0,0(a1)
}
  94:	40a7853b          	subw	a0,a5,a0
  98:	6422                	ld	s0,8(sp)
  9a:	0141                	addi	sp,sp,16
  9c:	8082                	ret

000000000000009e <strlen>:

uint
strlen(const char *s)
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e422                	sd	s0,8(sp)
  a2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  a4:	00054783          	lbu	a5,0(a0)
  a8:	cf91                	beqz	a5,c4 <strlen+0x26>
  aa:	0505                	addi	a0,a0,1
  ac:	87aa                	mv	a5,a0
  ae:	4685                	li	a3,1
  b0:	9e89                	subw	a3,a3,a0
  b2:	00f6853b          	addw	a0,a3,a5
  b6:	0785                	addi	a5,a5,1
  b8:	fff7c703          	lbu	a4,-1(a5)
  bc:	fb7d                	bnez	a4,b2 <strlen+0x14>
    ;
  return n;
}
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret
  for(n = 0; s[n]; n++)
  c4:	4501                	li	a0,0
  c6:	bfe5                	j	be <strlen+0x20>

00000000000000c8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ce:	ca19                	beqz	a2,e4 <memset+0x1c>
  d0:	87aa                	mv	a5,a0
  d2:	1602                	slli	a2,a2,0x20
  d4:	9201                	srli	a2,a2,0x20
  d6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  da:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  de:	0785                	addi	a5,a5,1
  e0:	fee79de3          	bne	a5,a4,da <memset+0x12>
  }
  return dst;
}
  e4:	6422                	ld	s0,8(sp)
  e6:	0141                	addi	sp,sp,16
  e8:	8082                	ret

00000000000000ea <strchr>:

char*
strchr(const char *s, char c)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e422                	sd	s0,8(sp)
  ee:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f0:	00054783          	lbu	a5,0(a0)
  f4:	cb99                	beqz	a5,10a <strchr+0x20>
    if(*s == c)
  f6:	00f58763          	beq	a1,a5,104 <strchr+0x1a>
  for(; *s; s++)
  fa:	0505                	addi	a0,a0,1
  fc:	00054783          	lbu	a5,0(a0)
 100:	fbfd                	bnez	a5,f6 <strchr+0xc>
      return (char*)s;
  return 0;
 102:	4501                	li	a0,0
}
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret
  return 0;
 10a:	4501                	li	a0,0
 10c:	bfe5                	j	104 <strchr+0x1a>

000000000000010e <gets>:

char*
gets(char *buf, int max)
{
 10e:	711d                	addi	sp,sp,-96
 110:	ec86                	sd	ra,88(sp)
 112:	e8a2                	sd	s0,80(sp)
 114:	e4a6                	sd	s1,72(sp)
 116:	e0ca                	sd	s2,64(sp)
 118:	fc4e                	sd	s3,56(sp)
 11a:	f852                	sd	s4,48(sp)
 11c:	f456                	sd	s5,40(sp)
 11e:	f05a                	sd	s6,32(sp)
 120:	ec5e                	sd	s7,24(sp)
 122:	1080                	addi	s0,sp,96
 124:	8baa                	mv	s7,a0
 126:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 128:	892a                	mv	s2,a0
 12a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 12c:	4aa9                	li	s5,10
 12e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 130:	89a6                	mv	s3,s1
 132:	2485                	addiw	s1,s1,1
 134:	0344d863          	bge	s1,s4,164 <gets+0x56>
    cc = read(0, &c, 1);
 138:	4605                	li	a2,1
 13a:	faf40593          	addi	a1,s0,-81
 13e:	4501                	li	a0,0
 140:	00000097          	auipc	ra,0x0
 144:	19c080e7          	jalr	412(ra) # 2dc <read>
    if(cc < 1)
 148:	00a05e63          	blez	a0,164 <gets+0x56>
    buf[i++] = c;
 14c:	faf44783          	lbu	a5,-81(s0)
 150:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 154:	01578763          	beq	a5,s5,162 <gets+0x54>
 158:	0905                	addi	s2,s2,1
 15a:	fd679be3          	bne	a5,s6,130 <gets+0x22>
  for(i=0; i+1 < max; ){
 15e:	89a6                	mv	s3,s1
 160:	a011                	j	164 <gets+0x56>
 162:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 164:	99de                	add	s3,s3,s7
 166:	00098023          	sb	zero,0(s3)
  return buf;
}
 16a:	855e                	mv	a0,s7
 16c:	60e6                	ld	ra,88(sp)
 16e:	6446                	ld	s0,80(sp)
 170:	64a6                	ld	s1,72(sp)
 172:	6906                	ld	s2,64(sp)
 174:	79e2                	ld	s3,56(sp)
 176:	7a42                	ld	s4,48(sp)
 178:	7aa2                	ld	s5,40(sp)
 17a:	7b02                	ld	s6,32(sp)
 17c:	6be2                	ld	s7,24(sp)
 17e:	6125                	addi	sp,sp,96
 180:	8082                	ret

0000000000000182 <stat>:

int
stat(const char *n, struct stat *st)
{
 182:	1101                	addi	sp,sp,-32
 184:	ec06                	sd	ra,24(sp)
 186:	e822                	sd	s0,16(sp)
 188:	e426                	sd	s1,8(sp)
 18a:	e04a                	sd	s2,0(sp)
 18c:	1000                	addi	s0,sp,32
 18e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 190:	4581                	li	a1,0
 192:	00000097          	auipc	ra,0x0
 196:	172080e7          	jalr	370(ra) # 304 <open>
  if(fd < 0)
 19a:	02054563          	bltz	a0,1c4 <stat+0x42>
 19e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a0:	85ca                	mv	a1,s2
 1a2:	00000097          	auipc	ra,0x0
 1a6:	17a080e7          	jalr	378(ra) # 31c <fstat>
 1aa:	892a                	mv	s2,a0
  close(fd);
 1ac:	8526                	mv	a0,s1
 1ae:	00000097          	auipc	ra,0x0
 1b2:	13e080e7          	jalr	318(ra) # 2ec <close>
  return r;
}
 1b6:	854a                	mv	a0,s2
 1b8:	60e2                	ld	ra,24(sp)
 1ba:	6442                	ld	s0,16(sp)
 1bc:	64a2                	ld	s1,8(sp)
 1be:	6902                	ld	s2,0(sp)
 1c0:	6105                	addi	sp,sp,32
 1c2:	8082                	ret
    return -1;
 1c4:	597d                	li	s2,-1
 1c6:	bfc5                	j	1b6 <stat+0x34>

00000000000001c8 <atoi>:

int
atoi(const char *s)
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e422                	sd	s0,8(sp)
 1cc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ce:	00054603          	lbu	a2,0(a0)
 1d2:	fd06079b          	addiw	a5,a2,-48
 1d6:	0ff7f793          	andi	a5,a5,255
 1da:	4725                	li	a4,9
 1dc:	02f76963          	bltu	a4,a5,20e <atoi+0x46>
 1e0:	86aa                	mv	a3,a0
  n = 0;
 1e2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1e4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1e6:	0685                	addi	a3,a3,1
 1e8:	0025179b          	slliw	a5,a0,0x2
 1ec:	9fa9                	addw	a5,a5,a0
 1ee:	0017979b          	slliw	a5,a5,0x1
 1f2:	9fb1                	addw	a5,a5,a2
 1f4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f8:	0006c603          	lbu	a2,0(a3)
 1fc:	fd06071b          	addiw	a4,a2,-48
 200:	0ff77713          	andi	a4,a4,255
 204:	fee5f1e3          	bgeu	a1,a4,1e6 <atoi+0x1e>
  return n;
}
 208:	6422                	ld	s0,8(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret
  n = 0;
 20e:	4501                	li	a0,0
 210:	bfe5                	j	208 <atoi+0x40>

0000000000000212 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 212:	1141                	addi	sp,sp,-16
 214:	e422                	sd	s0,8(sp)
 216:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 218:	02b57463          	bgeu	a0,a1,240 <memmove+0x2e>
    while(n-- > 0)
 21c:	00c05f63          	blez	a2,23a <memmove+0x28>
 220:	1602                	slli	a2,a2,0x20
 222:	9201                	srli	a2,a2,0x20
 224:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 228:	872a                	mv	a4,a0
      *dst++ = *src++;
 22a:	0585                	addi	a1,a1,1
 22c:	0705                	addi	a4,a4,1
 22e:	fff5c683          	lbu	a3,-1(a1)
 232:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 236:	fee79ae3          	bne	a5,a4,22a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret
    dst += n;
 240:	00c50733          	add	a4,a0,a2
    src += n;
 244:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 246:	fec05ae3          	blez	a2,23a <memmove+0x28>
 24a:	fff6079b          	addiw	a5,a2,-1
 24e:	1782                	slli	a5,a5,0x20
 250:	9381                	srli	a5,a5,0x20
 252:	fff7c793          	not	a5,a5
 256:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 258:	15fd                	addi	a1,a1,-1
 25a:	177d                	addi	a4,a4,-1
 25c:	0005c683          	lbu	a3,0(a1)
 260:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 264:	fee79ae3          	bne	a5,a4,258 <memmove+0x46>
 268:	bfc9                	j	23a <memmove+0x28>

000000000000026a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 270:	ca05                	beqz	a2,2a0 <memcmp+0x36>
 272:	fff6069b          	addiw	a3,a2,-1
 276:	1682                	slli	a3,a3,0x20
 278:	9281                	srli	a3,a3,0x20
 27a:	0685                	addi	a3,a3,1
 27c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 27e:	00054783          	lbu	a5,0(a0)
 282:	0005c703          	lbu	a4,0(a1)
 286:	00e79863          	bne	a5,a4,296 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 28a:	0505                	addi	a0,a0,1
    p2++;
 28c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 28e:	fed518e3          	bne	a0,a3,27e <memcmp+0x14>
  }
  return 0;
 292:	4501                	li	a0,0
 294:	a019                	j	29a <memcmp+0x30>
      return *p1 - *p2;
 296:	40e7853b          	subw	a0,a5,a4
}
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret
  return 0;
 2a0:	4501                	li	a0,0
 2a2:	bfe5                	j	29a <memcmp+0x30>

00000000000002a4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e406                	sd	ra,8(sp)
 2a8:	e022                	sd	s0,0(sp)
 2aa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ac:	00000097          	auipc	ra,0x0
 2b0:	f66080e7          	jalr	-154(ra) # 212 <memmove>
}
 2b4:	60a2                	ld	ra,8(sp)
 2b6:	6402                	ld	s0,0(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret

00000000000002bc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2bc:	4885                	li	a7,1
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2c4:	4889                	li	a7,2
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <wait>:
.global wait
wait:
 li a7, SYS_wait
 2cc:	488d                	li	a7,3
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2d4:	4891                	li	a7,4
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <read>:
.global read
read:
 li a7, SYS_read
 2dc:	4895                	li	a7,5
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <write>:
.global write
write:
 li a7, SYS_write
 2e4:	48c1                	li	a7,16
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <close>:
.global close
close:
 li a7, SYS_close
 2ec:	48d5                	li	a7,21
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2f4:	4899                	li	a7,6
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <exec>:
.global exec
exec:
 li a7, SYS_exec
 2fc:	489d                	li	a7,7
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <open>:
.global open
open:
 li a7, SYS_open
 304:	48bd                	li	a7,15
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 30c:	48c5                	li	a7,17
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 314:	48c9                	li	a7,18
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 31c:	48a1                	li	a7,8
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <link>:
.global link
link:
 li a7, SYS_link
 324:	48cd                	li	a7,19
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 32c:	48d1                	li	a7,20
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 334:	48a5                	li	a7,9
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <dup>:
.global dup
dup:
 li a7, SYS_dup
 33c:	48a9                	li	a7,10
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 344:	48ad                	li	a7,11
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 34c:	48b1                	li	a7,12
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 354:	48b5                	li	a7,13
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 35c:	48b9                	li	a7,14
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 364:	48d9                	li	a7,22
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 36c:	1101                	addi	sp,sp,-32
 36e:	ec06                	sd	ra,24(sp)
 370:	e822                	sd	s0,16(sp)
 372:	1000                	addi	s0,sp,32
 374:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 378:	4605                	li	a2,1
 37a:	fef40593          	addi	a1,s0,-17
 37e:	00000097          	auipc	ra,0x0
 382:	f66080e7          	jalr	-154(ra) # 2e4 <write>
}
 386:	60e2                	ld	ra,24(sp)
 388:	6442                	ld	s0,16(sp)
 38a:	6105                	addi	sp,sp,32
 38c:	8082                	ret

000000000000038e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 38e:	7139                	addi	sp,sp,-64
 390:	fc06                	sd	ra,56(sp)
 392:	f822                	sd	s0,48(sp)
 394:	f426                	sd	s1,40(sp)
 396:	f04a                	sd	s2,32(sp)
 398:	ec4e                	sd	s3,24(sp)
 39a:	0080                	addi	s0,sp,64
 39c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 39e:	c299                	beqz	a3,3a4 <printint+0x16>
 3a0:	0805c863          	bltz	a1,430 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3a4:	2581                	sext.w	a1,a1
  neg = 0;
 3a6:	4881                	li	a7,0
 3a8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3ac:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ae:	2601                	sext.w	a2,a2
 3b0:	00000517          	auipc	a0,0x0
 3b4:	45850513          	addi	a0,a0,1112 # 808 <digits>
 3b8:	883a                	mv	a6,a4
 3ba:	2705                	addiw	a4,a4,1
 3bc:	02c5f7bb          	remuw	a5,a1,a2
 3c0:	1782                	slli	a5,a5,0x20
 3c2:	9381                	srli	a5,a5,0x20
 3c4:	97aa                	add	a5,a5,a0
 3c6:	0007c783          	lbu	a5,0(a5)
 3ca:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3ce:	0005879b          	sext.w	a5,a1
 3d2:	02c5d5bb          	divuw	a1,a1,a2
 3d6:	0685                	addi	a3,a3,1
 3d8:	fec7f0e3          	bgeu	a5,a2,3b8 <printint+0x2a>
  if(neg)
 3dc:	00088b63          	beqz	a7,3f2 <printint+0x64>
    buf[i++] = '-';
 3e0:	fd040793          	addi	a5,s0,-48
 3e4:	973e                	add	a4,a4,a5
 3e6:	02d00793          	li	a5,45
 3ea:	fef70823          	sb	a5,-16(a4)
 3ee:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3f2:	02e05863          	blez	a4,422 <printint+0x94>
 3f6:	fc040793          	addi	a5,s0,-64
 3fa:	00e78933          	add	s2,a5,a4
 3fe:	fff78993          	addi	s3,a5,-1
 402:	99ba                	add	s3,s3,a4
 404:	377d                	addiw	a4,a4,-1
 406:	1702                	slli	a4,a4,0x20
 408:	9301                	srli	a4,a4,0x20
 40a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 40e:	fff94583          	lbu	a1,-1(s2)
 412:	8526                	mv	a0,s1
 414:	00000097          	auipc	ra,0x0
 418:	f58080e7          	jalr	-168(ra) # 36c <putc>
  while(--i >= 0)
 41c:	197d                	addi	s2,s2,-1
 41e:	ff3918e3          	bne	s2,s3,40e <printint+0x80>
}
 422:	70e2                	ld	ra,56(sp)
 424:	7442                	ld	s0,48(sp)
 426:	74a2                	ld	s1,40(sp)
 428:	7902                	ld	s2,32(sp)
 42a:	69e2                	ld	s3,24(sp)
 42c:	6121                	addi	sp,sp,64
 42e:	8082                	ret
    x = -xx;
 430:	40b005bb          	negw	a1,a1
    neg = 1;
 434:	4885                	li	a7,1
    x = -xx;
 436:	bf8d                	j	3a8 <printint+0x1a>

0000000000000438 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 438:	7119                	addi	sp,sp,-128
 43a:	fc86                	sd	ra,120(sp)
 43c:	f8a2                	sd	s0,112(sp)
 43e:	f4a6                	sd	s1,104(sp)
 440:	f0ca                	sd	s2,96(sp)
 442:	ecce                	sd	s3,88(sp)
 444:	e8d2                	sd	s4,80(sp)
 446:	e4d6                	sd	s5,72(sp)
 448:	e0da                	sd	s6,64(sp)
 44a:	fc5e                	sd	s7,56(sp)
 44c:	f862                	sd	s8,48(sp)
 44e:	f466                	sd	s9,40(sp)
 450:	f06a                	sd	s10,32(sp)
 452:	ec6e                	sd	s11,24(sp)
 454:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 456:	0005c903          	lbu	s2,0(a1)
 45a:	18090f63          	beqz	s2,5f8 <vprintf+0x1c0>
 45e:	8aaa                	mv	s5,a0
 460:	8b32                	mv	s6,a2
 462:	00158493          	addi	s1,a1,1
  state = 0;
 466:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 468:	02500a13          	li	s4,37
      if(c == 'd'){
 46c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 470:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 474:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 478:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 47c:	00000b97          	auipc	s7,0x0
 480:	38cb8b93          	addi	s7,s7,908 # 808 <digits>
 484:	a839                	j	4a2 <vprintf+0x6a>
        putc(fd, c);
 486:	85ca                	mv	a1,s2
 488:	8556                	mv	a0,s5
 48a:	00000097          	auipc	ra,0x0
 48e:	ee2080e7          	jalr	-286(ra) # 36c <putc>
 492:	a019                	j	498 <vprintf+0x60>
    } else if(state == '%'){
 494:	01498f63          	beq	s3,s4,4b2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 498:	0485                	addi	s1,s1,1
 49a:	fff4c903          	lbu	s2,-1(s1)
 49e:	14090d63          	beqz	s2,5f8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4a2:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4a6:	fe0997e3          	bnez	s3,494 <vprintf+0x5c>
      if(c == '%'){
 4aa:	fd479ee3          	bne	a5,s4,486 <vprintf+0x4e>
        state = '%';
 4ae:	89be                	mv	s3,a5
 4b0:	b7e5                	j	498 <vprintf+0x60>
      if(c == 'd'){
 4b2:	05878063          	beq	a5,s8,4f2 <vprintf+0xba>
      } else if(c == 'l') {
 4b6:	05978c63          	beq	a5,s9,50e <vprintf+0xd6>
      } else if(c == 'x') {
 4ba:	07a78863          	beq	a5,s10,52a <vprintf+0xf2>
      } else if(c == 'p') {
 4be:	09b78463          	beq	a5,s11,546 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4c2:	07300713          	li	a4,115
 4c6:	0ce78663          	beq	a5,a4,592 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4ca:	06300713          	li	a4,99
 4ce:	0ee78e63          	beq	a5,a4,5ca <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4d2:	11478863          	beq	a5,s4,5e2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4d6:	85d2                	mv	a1,s4
 4d8:	8556                	mv	a0,s5
 4da:	00000097          	auipc	ra,0x0
 4de:	e92080e7          	jalr	-366(ra) # 36c <putc>
        putc(fd, c);
 4e2:	85ca                	mv	a1,s2
 4e4:	8556                	mv	a0,s5
 4e6:	00000097          	auipc	ra,0x0
 4ea:	e86080e7          	jalr	-378(ra) # 36c <putc>
      }
      state = 0;
 4ee:	4981                	li	s3,0
 4f0:	b765                	j	498 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4f2:	008b0913          	addi	s2,s6,8
 4f6:	4685                	li	a3,1
 4f8:	4629                	li	a2,10
 4fa:	000b2583          	lw	a1,0(s6)
 4fe:	8556                	mv	a0,s5
 500:	00000097          	auipc	ra,0x0
 504:	e8e080e7          	jalr	-370(ra) # 38e <printint>
 508:	8b4a                	mv	s6,s2
      state = 0;
 50a:	4981                	li	s3,0
 50c:	b771                	j	498 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 50e:	008b0913          	addi	s2,s6,8
 512:	4681                	li	a3,0
 514:	4629                	li	a2,10
 516:	000b2583          	lw	a1,0(s6)
 51a:	8556                	mv	a0,s5
 51c:	00000097          	auipc	ra,0x0
 520:	e72080e7          	jalr	-398(ra) # 38e <printint>
 524:	8b4a                	mv	s6,s2
      state = 0;
 526:	4981                	li	s3,0
 528:	bf85                	j	498 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 52a:	008b0913          	addi	s2,s6,8
 52e:	4681                	li	a3,0
 530:	4641                	li	a2,16
 532:	000b2583          	lw	a1,0(s6)
 536:	8556                	mv	a0,s5
 538:	00000097          	auipc	ra,0x0
 53c:	e56080e7          	jalr	-426(ra) # 38e <printint>
 540:	8b4a                	mv	s6,s2
      state = 0;
 542:	4981                	li	s3,0
 544:	bf91                	j	498 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 546:	008b0793          	addi	a5,s6,8
 54a:	f8f43423          	sd	a5,-120(s0)
 54e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 552:	03000593          	li	a1,48
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	e14080e7          	jalr	-492(ra) # 36c <putc>
  putc(fd, 'x');
 560:	85ea                	mv	a1,s10
 562:	8556                	mv	a0,s5
 564:	00000097          	auipc	ra,0x0
 568:	e08080e7          	jalr	-504(ra) # 36c <putc>
 56c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56e:	03c9d793          	srli	a5,s3,0x3c
 572:	97de                	add	a5,a5,s7
 574:	0007c583          	lbu	a1,0(a5)
 578:	8556                	mv	a0,s5
 57a:	00000097          	auipc	ra,0x0
 57e:	df2080e7          	jalr	-526(ra) # 36c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 582:	0992                	slli	s3,s3,0x4
 584:	397d                	addiw	s2,s2,-1
 586:	fe0914e3          	bnez	s2,56e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 58a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 58e:	4981                	li	s3,0
 590:	b721                	j	498 <vprintf+0x60>
        s = va_arg(ap, char*);
 592:	008b0993          	addi	s3,s6,8
 596:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 59a:	02090163          	beqz	s2,5bc <vprintf+0x184>
        while(*s != 0){
 59e:	00094583          	lbu	a1,0(s2)
 5a2:	c9a1                	beqz	a1,5f2 <vprintf+0x1ba>
          putc(fd, *s);
 5a4:	8556                	mv	a0,s5
 5a6:	00000097          	auipc	ra,0x0
 5aa:	dc6080e7          	jalr	-570(ra) # 36c <putc>
          s++;
 5ae:	0905                	addi	s2,s2,1
        while(*s != 0){
 5b0:	00094583          	lbu	a1,0(s2)
 5b4:	f9e5                	bnez	a1,5a4 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5b6:	8b4e                	mv	s6,s3
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	bdf9                	j	498 <vprintf+0x60>
          s = "(null)";
 5bc:	00000917          	auipc	s2,0x0
 5c0:	24490913          	addi	s2,s2,580 # 800 <malloc+0xfe>
        while(*s != 0){
 5c4:	02800593          	li	a1,40
 5c8:	bff1                	j	5a4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5ca:	008b0913          	addi	s2,s6,8
 5ce:	000b4583          	lbu	a1,0(s6)
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	d98080e7          	jalr	-616(ra) # 36c <putc>
 5dc:	8b4a                	mv	s6,s2
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	bd65                	j	498 <vprintf+0x60>
        putc(fd, c);
 5e2:	85d2                	mv	a1,s4
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	d86080e7          	jalr	-634(ra) # 36c <putc>
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	b565                	j	498 <vprintf+0x60>
        s = va_arg(ap, char*);
 5f2:	8b4e                	mv	s6,s3
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b54d                	j	498 <vprintf+0x60>
    }
  }
}
 5f8:	70e6                	ld	ra,120(sp)
 5fa:	7446                	ld	s0,112(sp)
 5fc:	74a6                	ld	s1,104(sp)
 5fe:	7906                	ld	s2,96(sp)
 600:	69e6                	ld	s3,88(sp)
 602:	6a46                	ld	s4,80(sp)
 604:	6aa6                	ld	s5,72(sp)
 606:	6b06                	ld	s6,64(sp)
 608:	7be2                	ld	s7,56(sp)
 60a:	7c42                	ld	s8,48(sp)
 60c:	7ca2                	ld	s9,40(sp)
 60e:	7d02                	ld	s10,32(sp)
 610:	6de2                	ld	s11,24(sp)
 612:	6109                	addi	sp,sp,128
 614:	8082                	ret

0000000000000616 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 616:	715d                	addi	sp,sp,-80
 618:	ec06                	sd	ra,24(sp)
 61a:	e822                	sd	s0,16(sp)
 61c:	1000                	addi	s0,sp,32
 61e:	e010                	sd	a2,0(s0)
 620:	e414                	sd	a3,8(s0)
 622:	e818                	sd	a4,16(s0)
 624:	ec1c                	sd	a5,24(s0)
 626:	03043023          	sd	a6,32(s0)
 62a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 62e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 632:	8622                	mv	a2,s0
 634:	00000097          	auipc	ra,0x0
 638:	e04080e7          	jalr	-508(ra) # 438 <vprintf>
}
 63c:	60e2                	ld	ra,24(sp)
 63e:	6442                	ld	s0,16(sp)
 640:	6161                	addi	sp,sp,80
 642:	8082                	ret

0000000000000644 <printf>:

void
printf(const char *fmt, ...)
{
 644:	711d                	addi	sp,sp,-96
 646:	ec06                	sd	ra,24(sp)
 648:	e822                	sd	s0,16(sp)
 64a:	1000                	addi	s0,sp,32
 64c:	e40c                	sd	a1,8(s0)
 64e:	e810                	sd	a2,16(s0)
 650:	ec14                	sd	a3,24(s0)
 652:	f018                	sd	a4,32(s0)
 654:	f41c                	sd	a5,40(s0)
 656:	03043823          	sd	a6,48(s0)
 65a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 65e:	00840613          	addi	a2,s0,8
 662:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 666:	85aa                	mv	a1,a0
 668:	4505                	li	a0,1
 66a:	00000097          	auipc	ra,0x0
 66e:	dce080e7          	jalr	-562(ra) # 438 <vprintf>
}
 672:	60e2                	ld	ra,24(sp)
 674:	6442                	ld	s0,16(sp)
 676:	6125                	addi	sp,sp,96
 678:	8082                	ret

000000000000067a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 67a:	1141                	addi	sp,sp,-16
 67c:	e422                	sd	s0,8(sp)
 67e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 680:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 684:	00000797          	auipc	a5,0x0
 688:	19c7b783          	ld	a5,412(a5) # 820 <freep>
 68c:	a805                	j	6bc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 68e:	4618                	lw	a4,8(a2)
 690:	9db9                	addw	a1,a1,a4
 692:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 696:	6398                	ld	a4,0(a5)
 698:	6318                	ld	a4,0(a4)
 69a:	fee53823          	sd	a4,-16(a0)
 69e:	a091                	j	6e2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6a0:	ff852703          	lw	a4,-8(a0)
 6a4:	9e39                	addw	a2,a2,a4
 6a6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6a8:	ff053703          	ld	a4,-16(a0)
 6ac:	e398                	sd	a4,0(a5)
 6ae:	a099                	j	6f4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b0:	6398                	ld	a4,0(a5)
 6b2:	00e7e463          	bltu	a5,a4,6ba <free+0x40>
 6b6:	00e6ea63          	bltu	a3,a4,6ca <free+0x50>
{
 6ba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6bc:	fed7fae3          	bgeu	a5,a3,6b0 <free+0x36>
 6c0:	6398                	ld	a4,0(a5)
 6c2:	00e6e463          	bltu	a3,a4,6ca <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c6:	fee7eae3          	bltu	a5,a4,6ba <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6ca:	ff852583          	lw	a1,-8(a0)
 6ce:	6390                	ld	a2,0(a5)
 6d0:	02059713          	slli	a4,a1,0x20
 6d4:	9301                	srli	a4,a4,0x20
 6d6:	0712                	slli	a4,a4,0x4
 6d8:	9736                	add	a4,a4,a3
 6da:	fae60ae3          	beq	a2,a4,68e <free+0x14>
    bp->s.ptr = p->s.ptr;
 6de:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6e2:	4790                	lw	a2,8(a5)
 6e4:	02061713          	slli	a4,a2,0x20
 6e8:	9301                	srli	a4,a4,0x20
 6ea:	0712                	slli	a4,a4,0x4
 6ec:	973e                	add	a4,a4,a5
 6ee:	fae689e3          	beq	a3,a4,6a0 <free+0x26>
  } else
    p->s.ptr = bp;
 6f2:	e394                	sd	a3,0(a5)
  freep = p;
 6f4:	00000717          	auipc	a4,0x0
 6f8:	12f73623          	sd	a5,300(a4) # 820 <freep>
}
 6fc:	6422                	ld	s0,8(sp)
 6fe:	0141                	addi	sp,sp,16
 700:	8082                	ret

0000000000000702 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 702:	7139                	addi	sp,sp,-64
 704:	fc06                	sd	ra,56(sp)
 706:	f822                	sd	s0,48(sp)
 708:	f426                	sd	s1,40(sp)
 70a:	f04a                	sd	s2,32(sp)
 70c:	ec4e                	sd	s3,24(sp)
 70e:	e852                	sd	s4,16(sp)
 710:	e456                	sd	s5,8(sp)
 712:	e05a                	sd	s6,0(sp)
 714:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 716:	02051493          	slli	s1,a0,0x20
 71a:	9081                	srli	s1,s1,0x20
 71c:	04bd                	addi	s1,s1,15
 71e:	8091                	srli	s1,s1,0x4
 720:	0014899b          	addiw	s3,s1,1
 724:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 726:	00000517          	auipc	a0,0x0
 72a:	0fa53503          	ld	a0,250(a0) # 820 <freep>
 72e:	c515                	beqz	a0,75a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 730:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 732:	4798                	lw	a4,8(a5)
 734:	02977f63          	bgeu	a4,s1,772 <malloc+0x70>
 738:	8a4e                	mv	s4,s3
 73a:	0009871b          	sext.w	a4,s3
 73e:	6685                	lui	a3,0x1
 740:	00d77363          	bgeu	a4,a3,746 <malloc+0x44>
 744:	6a05                	lui	s4,0x1
 746:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 74a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 74e:	00000917          	auipc	s2,0x0
 752:	0d290913          	addi	s2,s2,210 # 820 <freep>
  if(p == (char*)-1)
 756:	5afd                	li	s5,-1
 758:	a88d                	j	7ca <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 75a:	00000797          	auipc	a5,0x0
 75e:	0ce78793          	addi	a5,a5,206 # 828 <base>
 762:	00000717          	auipc	a4,0x0
 766:	0af73f23          	sd	a5,190(a4) # 820 <freep>
 76a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 76c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 770:	b7e1                	j	738 <malloc+0x36>
      if(p->s.size == nunits)
 772:	02e48b63          	beq	s1,a4,7a8 <malloc+0xa6>
        p->s.size -= nunits;
 776:	4137073b          	subw	a4,a4,s3
 77a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 77c:	1702                	slli	a4,a4,0x20
 77e:	9301                	srli	a4,a4,0x20
 780:	0712                	slli	a4,a4,0x4
 782:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 784:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 788:	00000717          	auipc	a4,0x0
 78c:	08a73c23          	sd	a0,152(a4) # 820 <freep>
      return (void*)(p + 1);
 790:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 794:	70e2                	ld	ra,56(sp)
 796:	7442                	ld	s0,48(sp)
 798:	74a2                	ld	s1,40(sp)
 79a:	7902                	ld	s2,32(sp)
 79c:	69e2                	ld	s3,24(sp)
 79e:	6a42                	ld	s4,16(sp)
 7a0:	6aa2                	ld	s5,8(sp)
 7a2:	6b02                	ld	s6,0(sp)
 7a4:	6121                	addi	sp,sp,64
 7a6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7a8:	6398                	ld	a4,0(a5)
 7aa:	e118                	sd	a4,0(a0)
 7ac:	bff1                	j	788 <malloc+0x86>
  hp->s.size = nu;
 7ae:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b2:	0541                	addi	a0,a0,16
 7b4:	00000097          	auipc	ra,0x0
 7b8:	ec6080e7          	jalr	-314(ra) # 67a <free>
  return freep;
 7bc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7c0:	d971                	beqz	a0,794 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c4:	4798                	lw	a4,8(a5)
 7c6:	fa9776e3          	bgeu	a4,s1,772 <malloc+0x70>
    if(p == freep)
 7ca:	00093703          	ld	a4,0(s2)
 7ce:	853e                	mv	a0,a5
 7d0:	fef719e3          	bne	a4,a5,7c2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7d4:	8552                	mv	a0,s4
 7d6:	00000097          	auipc	ra,0x0
 7da:	b76080e7          	jalr	-1162(ra) # 34c <sbrk>
  if(p == (char*)-1)
 7de:	fd5518e3          	bne	a0,s5,7ae <malloc+0xac>
        return 0;
 7e2:	4501                	li	a0,0
 7e4:	bf45                	j	794 <malloc+0x92>
