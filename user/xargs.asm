
user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <read_line>:

#define MAX_LINE 512  // 单行最大长度
#define MAX_ARGS 32   // 最大参数数量

// 自定义读取函数，正确处理EOF(Ctrl+D)
int read_line(char *buf, int max) {
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	e85a                	sd	s6,16(sp)
  12:	0880                	addi	s0,sp,80
  14:	8b2a                	mv	s6,a0
    int i = 0;
    char c;
    
    while(i < max - 1) {
  16:	4785                	li	a5,1
  18:	04b7dd63          	bge	a5,a1,72 <read_line+0x72>
  1c:	892a                	mv	s2,a0
  1e:	fff5899b          	addiw	s3,a1,-1
    int i = 0;
  22:	4481                	li	s1,0
        int n = read(0, &c, 1);
        if(n <= 0) return n;  // EOF或错误
        if(c == '\n' || c == '\r') break;
  24:	4a29                	li	s4,10
  26:	4ab5                	li	s5,13
        int n = read(0, &c, 1);
  28:	4605                	li	a2,1
  2a:	fbf40593          	addi	a1,s0,-65
  2e:	4501                	li	a0,0
  30:	00000097          	auipc	ra,0x0
  34:	448080e7          	jalr	1096(ra) # 478 <read>
        if(n <= 0) return n;  // EOF或错误
  38:	02a05f63          	blez	a0,76 <read_line+0x76>
        if(c == '\n' || c == '\r') break;
  3c:	fbf44783          	lbu	a5,-65(s0)
  40:	01478b63          	beq	a5,s4,56 <read_line+0x56>
  44:	01578963          	beq	a5,s5,56 <read_line+0x56>
        buf[i++] = c;
  48:	2485                	addiw	s1,s1,1
  4a:	00f90023          	sb	a5,0(s2)
    while(i < max - 1) {
  4e:	0905                	addi	s2,s2,1
  50:	fd349ce3          	bne	s1,s3,28 <read_line+0x28>
        buf[i++] = c;
  54:	84ce                	mv	s1,s3
    }
    buf[i] = '\0';
  56:	9b26                	add	s6,s6,s1
  58:	000b0023          	sb	zero,0(s6)
    return i;
}
  5c:	8526                	mv	a0,s1
  5e:	60a6                	ld	ra,72(sp)
  60:	6406                	ld	s0,64(sp)
  62:	74e2                	ld	s1,56(sp)
  64:	7942                	ld	s2,48(sp)
  66:	79a2                	ld	s3,40(sp)
  68:	7a02                	ld	s4,32(sp)
  6a:	6ae2                	ld	s5,24(sp)
  6c:	6b42                	ld	s6,16(sp)
  6e:	6161                	addi	sp,sp,80
  70:	8082                	ret
    int i = 0;
  72:	4481                	li	s1,0
  74:	b7cd                	j	56 <read_line+0x56>
        int n = read(0, &c, 1);
  76:	84aa                	mv	s1,a0
  78:	b7d5                	j	5c <read_line+0x5c>

000000000000007a <main>:

int main(int argc, char *argv[]) {
  7a:	cd010113          	addi	sp,sp,-816
  7e:	32113423          	sd	ra,808(sp)
  82:	32813023          	sd	s0,800(sp)
  86:	30913c23          	sd	s1,792(sp)
  8a:	31213823          	sd	s2,784(sp)
  8e:	31313423          	sd	s3,776(sp)
  92:	31413023          	sd	s4,768(sp)
  96:	1e00                	addi	s0,sp,816
    char line[MAX_LINE];
    char *args[MAX_ARGS];
    int arg_count;
    
    // 1. 初始化基础命令参数
    if(argc < 2) {
  98:	4785                	li	a5,1
  9a:	02a7db63          	bge	a5,a0,d0 <main+0x56>
        fprintf(2, "Usage: xargs command [args...]\n");
        exit(1);
    }

    // 复制原始命令参数(跳过argv[0]的"xargs")
    for(arg_count = 0; arg_count < argc - 1; arg_count++) {
  9e:	fff50a1b          	addiw	s4,a0,-1
  a2:	00858713          	addi	a4,a1,8
  a6:	cd040793          	addi	a5,s0,-816
  aa:	0005091b          	sext.w	s2,a0
  ae:	ffe5069b          	addiw	a3,a0,-2
  b2:	1682                	slli	a3,a3,0x20
  b4:	9281                	srli	a3,a3,0x20
  b6:	068e                	slli	a3,a3,0x3
  b8:	cd840613          	addi	a2,s0,-808
  bc:	96b2                	add	a3,a3,a2
        args[arg_count] = argv[arg_count + 1];
  be:	6310                	ld	a2,0(a4)
  c0:	e390                	sd	a2,0(a5)
    for(arg_count = 0; arg_count < argc - 1; arg_count++) {
  c2:	0721                	addi	a4,a4,8
  c4:	07a1                	addi	a5,a5,8
  c6:	fed79ce3          	bne	a5,a3,be <main+0x44>
  ca:	397d                	addiw	s2,s2,-1
        if(strlen(line) == 0) continue;

        // 3. 分割当前行参数
        char *p = line;
        char *arg;
        while((arg = strchr(p, ' ')) != 0 && arg_count < MAX_ARGS - 1) {
  cc:	49f9                	li	s3,30
  ce:	a849                	j	160 <main+0xe6>
        fprintf(2, "Usage: xargs command [args...]\n");
  d0:	00001597          	auipc	a1,0x1
  d4:	8b858593          	addi	a1,a1,-1864 # 988 <malloc+0xea>
  d8:	4509                	li	a0,2
  da:	00000097          	auipc	ra,0x0
  de:	6d8080e7          	jalr	1752(ra) # 7b2 <fprintf>
        exit(1);
  e2:	4505                	li	a0,1
  e4:	00000097          	auipc	ra,0x0
  e8:	37c080e7          	jalr	892(ra) # 460 <exit>
            *arg = '\0';
            if(*p != '\0') {
                args[arg_count++] = p;
            }
            p = arg + 1;
  ec:	00150493          	addi	s1,a0,1
        while((arg = strchr(p, ' ')) != 0 && arg_count < MAX_ARGS - 1) {
  f0:	02000593          	li	a1,32
  f4:	8526                	mv	a0,s1
  f6:	00000097          	auipc	ra,0x0
  fa:	190080e7          	jalr	400(ra) # 286 <strchr>
  fe:	c10d                	beqz	a0,120 <main+0xa6>
 100:	0329cd63          	blt	s3,s2,13a <main+0xc0>
            *arg = '\0';
 104:	00050023          	sb	zero,0(a0)
            if(*p != '\0') {
 108:	0004c783          	lbu	a5,0(s1)
 10c:	d3e5                	beqz	a5,ec <main+0x72>
                args[arg_count++] = p;
 10e:	00391793          	slli	a5,s2,0x3
 112:	fd040713          	addi	a4,s0,-48
 116:	97ba                	add	a5,a5,a4
 118:	d097b023          	sd	s1,-768(a5)
 11c:	2905                	addiw	s2,s2,1
 11e:	b7f9                	j	ec <main+0x72>
        }

        // 添加最后一个参数
        if(*p != '\0' && arg_count < MAX_ARGS - 1) {
 120:	0004c783          	lbu	a5,0(s1)
 124:	cb99                	beqz	a5,13a <main+0xc0>
 126:	0129ca63          	blt	s3,s2,13a <main+0xc0>
            args[arg_count++] = p;
 12a:	00391793          	slli	a5,s2,0x3
 12e:	fd040713          	addi	a4,s0,-48
 132:	97ba                	add	a5,a5,a4
 134:	d097b023          	sd	s1,-768(a5)
 138:	2905                	addiw	s2,s2,1
        }

        // 4. 执行命令
        args[arg_count] = 0;  // NULL终止
 13a:	090e                	slli	s2,s2,0x3
 13c:	fd040793          	addi	a5,s0,-48
 140:	993e                	add	s2,s2,a5
 142:	d0093023          	sd	zero,-768(s2)
        int pid = fork();
 146:	00000097          	auipc	ra,0x0
 14a:	312080e7          	jalr	786(ra) # 458 <fork>
        if(pid < 0) {
 14e:	04054763          	bltz	a0,19c <main+0x122>
            fprintf(2, "xargs: fork failed\n");
            exit(1);
        } else if(pid == 0) {
 152:	c13d                	beqz	a0,1b8 <main+0x13e>
            exec(args[0], args);
            fprintf(2, "xargs: exec %s failed\n", args[0]);
            exit(1);
        } else {
            wait(0);
 154:	4501                	li	a0,0
 156:	00000097          	auipc	ra,0x0
 15a:	312080e7          	jalr	786(ra) # 468 <wait>
 15e:	8952                	mv	s2,s4
        memset(line, 0, sizeof(line));
 160:	20000613          	li	a2,512
 164:	4581                	li	a1,0
 166:	dd040513          	addi	a0,s0,-560
 16a:	00000097          	auipc	ra,0x0
 16e:	0fa080e7          	jalr	250(ra) # 264 <memset>
        int ret = read_line(line, sizeof(line));
 172:	20000593          	li	a1,512
 176:	dd040513          	addi	a0,s0,-560
 17a:	00000097          	auipc	ra,0x0
 17e:	e86080e7          	jalr	-378(ra) # 0 <read_line>
        if(ret <= 0) break;
 182:	06a05363          	blez	a0,1e8 <main+0x16e>
        if(strlen(line) == 0) continue;
 186:	dd040513          	addi	a0,s0,-560
 18a:	00000097          	auipc	ra,0x0
 18e:	0b0080e7          	jalr	176(ra) # 23a <strlen>
 192:	2501                	sext.w	a0,a0
        char *p = line;
 194:	dd040493          	addi	s1,s0,-560
        if(strlen(line) == 0) continue;
 198:	d561                	beqz	a0,160 <main+0xe6>
 19a:	bf99                	j	f0 <main+0x76>
            fprintf(2, "xargs: fork failed\n");
 19c:	00001597          	auipc	a1,0x1
 1a0:	80c58593          	addi	a1,a1,-2036 # 9a8 <malloc+0x10a>
 1a4:	4509                	li	a0,2
 1a6:	00000097          	auipc	ra,0x0
 1aa:	60c080e7          	jalr	1548(ra) # 7b2 <fprintf>
            exit(1);
 1ae:	4505                	li	a0,1
 1b0:	00000097          	auipc	ra,0x0
 1b4:	2b0080e7          	jalr	688(ra) # 460 <exit>
            exec(args[0], args);
 1b8:	cd040593          	addi	a1,s0,-816
 1bc:	cd043503          	ld	a0,-816(s0)
 1c0:	00000097          	auipc	ra,0x0
 1c4:	2d8080e7          	jalr	728(ra) # 498 <exec>
            fprintf(2, "xargs: exec %s failed\n", args[0]);
 1c8:	cd043603          	ld	a2,-816(s0)
 1cc:	00000597          	auipc	a1,0x0
 1d0:	7f458593          	addi	a1,a1,2036 # 9c0 <malloc+0x122>
 1d4:	4509                	li	a0,2
 1d6:	00000097          	auipc	ra,0x0
 1da:	5dc080e7          	jalr	1500(ra) # 7b2 <fprintf>
            exit(1);
 1de:	4505                	li	a0,1
 1e0:	00000097          	auipc	ra,0x0
 1e4:	280080e7          	jalr	640(ra) # 460 <exit>

        // 5. 重置参数计数器(保留原始命令参数)
        arg_count = argc - 1;
    }

    exit(0);
 1e8:	4501                	li	a0,0
 1ea:	00000097          	auipc	ra,0x0
 1ee:	276080e7          	jalr	630(ra) # 460 <exit>

00000000000001f2 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1f8:	87aa                	mv	a5,a0
 1fa:	0585                	addi	a1,a1,1
 1fc:	0785                	addi	a5,a5,1
 1fe:	fff5c703          	lbu	a4,-1(a1)
 202:	fee78fa3          	sb	a4,-1(a5)
 206:	fb75                	bnez	a4,1fa <strcpy+0x8>
    ;
  return os;
}
 208:	6422                	ld	s0,8(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret

000000000000020e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20e:	1141                	addi	sp,sp,-16
 210:	e422                	sd	s0,8(sp)
 212:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 214:	00054783          	lbu	a5,0(a0)
 218:	cb91                	beqz	a5,22c <strcmp+0x1e>
 21a:	0005c703          	lbu	a4,0(a1)
 21e:	00f71763          	bne	a4,a5,22c <strcmp+0x1e>
    p++, q++;
 222:	0505                	addi	a0,a0,1
 224:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 226:	00054783          	lbu	a5,0(a0)
 22a:	fbe5                	bnez	a5,21a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 22c:	0005c503          	lbu	a0,0(a1)
}
 230:	40a7853b          	subw	a0,a5,a0
 234:	6422                	ld	s0,8(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret

000000000000023a <strlen>:

uint
strlen(const char *s)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 240:	00054783          	lbu	a5,0(a0)
 244:	cf91                	beqz	a5,260 <strlen+0x26>
 246:	0505                	addi	a0,a0,1
 248:	87aa                	mv	a5,a0
 24a:	4685                	li	a3,1
 24c:	9e89                	subw	a3,a3,a0
 24e:	00f6853b          	addw	a0,a3,a5
 252:	0785                	addi	a5,a5,1
 254:	fff7c703          	lbu	a4,-1(a5)
 258:	fb7d                	bnez	a4,24e <strlen+0x14>
    ;
  return n;
}
 25a:	6422                	ld	s0,8(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret
  for(n = 0; s[n]; n++)
 260:	4501                	li	a0,0
 262:	bfe5                	j	25a <strlen+0x20>

0000000000000264 <memset>:

void*
memset(void *dst, int c, uint n)
{
 264:	1141                	addi	sp,sp,-16
 266:	e422                	sd	s0,8(sp)
 268:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 26a:	ca19                	beqz	a2,280 <memset+0x1c>
 26c:	87aa                	mv	a5,a0
 26e:	1602                	slli	a2,a2,0x20
 270:	9201                	srli	a2,a2,0x20
 272:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 276:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 27a:	0785                	addi	a5,a5,1
 27c:	fee79de3          	bne	a5,a4,276 <memset+0x12>
  }
  return dst;
}
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <strchr>:

char*
strchr(const char *s, char c)
{
 286:	1141                	addi	sp,sp,-16
 288:	e422                	sd	s0,8(sp)
 28a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 28c:	00054783          	lbu	a5,0(a0)
 290:	cb99                	beqz	a5,2a6 <strchr+0x20>
    if(*s == c)
 292:	00f58763          	beq	a1,a5,2a0 <strchr+0x1a>
  for(; *s; s++)
 296:	0505                	addi	a0,a0,1
 298:	00054783          	lbu	a5,0(a0)
 29c:	fbfd                	bnez	a5,292 <strchr+0xc>
      return (char*)s;
  return 0;
 29e:	4501                	li	a0,0
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret
  return 0;
 2a6:	4501                	li	a0,0
 2a8:	bfe5                	j	2a0 <strchr+0x1a>

00000000000002aa <gets>:

char*
gets(char *buf, int max)
{
 2aa:	711d                	addi	sp,sp,-96
 2ac:	ec86                	sd	ra,88(sp)
 2ae:	e8a2                	sd	s0,80(sp)
 2b0:	e4a6                	sd	s1,72(sp)
 2b2:	e0ca                	sd	s2,64(sp)
 2b4:	fc4e                	sd	s3,56(sp)
 2b6:	f852                	sd	s4,48(sp)
 2b8:	f456                	sd	s5,40(sp)
 2ba:	f05a                	sd	s6,32(sp)
 2bc:	ec5e                	sd	s7,24(sp)
 2be:	1080                	addi	s0,sp,96
 2c0:	8baa                	mv	s7,a0
 2c2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c4:	892a                	mv	s2,a0
 2c6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2c8:	4aa9                	li	s5,10
 2ca:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2cc:	89a6                	mv	s3,s1
 2ce:	2485                	addiw	s1,s1,1
 2d0:	0344d863          	bge	s1,s4,300 <gets+0x56>
    cc = read(0, &c, 1);
 2d4:	4605                	li	a2,1
 2d6:	faf40593          	addi	a1,s0,-81
 2da:	4501                	li	a0,0
 2dc:	00000097          	auipc	ra,0x0
 2e0:	19c080e7          	jalr	412(ra) # 478 <read>
    if(cc < 1)
 2e4:	00a05e63          	blez	a0,300 <gets+0x56>
    buf[i++] = c;
 2e8:	faf44783          	lbu	a5,-81(s0)
 2ec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2f0:	01578763          	beq	a5,s5,2fe <gets+0x54>
 2f4:	0905                	addi	s2,s2,1
 2f6:	fd679be3          	bne	a5,s6,2cc <gets+0x22>
  for(i=0; i+1 < max; ){
 2fa:	89a6                	mv	s3,s1
 2fc:	a011                	j	300 <gets+0x56>
 2fe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 300:	99de                	add	s3,s3,s7
 302:	00098023          	sb	zero,0(s3)
  return buf;
}
 306:	855e                	mv	a0,s7
 308:	60e6                	ld	ra,88(sp)
 30a:	6446                	ld	s0,80(sp)
 30c:	64a6                	ld	s1,72(sp)
 30e:	6906                	ld	s2,64(sp)
 310:	79e2                	ld	s3,56(sp)
 312:	7a42                	ld	s4,48(sp)
 314:	7aa2                	ld	s5,40(sp)
 316:	7b02                	ld	s6,32(sp)
 318:	6be2                	ld	s7,24(sp)
 31a:	6125                	addi	sp,sp,96
 31c:	8082                	ret

000000000000031e <stat>:

int
stat(const char *n, struct stat *st)
{
 31e:	1101                	addi	sp,sp,-32
 320:	ec06                	sd	ra,24(sp)
 322:	e822                	sd	s0,16(sp)
 324:	e426                	sd	s1,8(sp)
 326:	e04a                	sd	s2,0(sp)
 328:	1000                	addi	s0,sp,32
 32a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 32c:	4581                	li	a1,0
 32e:	00000097          	auipc	ra,0x0
 332:	172080e7          	jalr	370(ra) # 4a0 <open>
  if(fd < 0)
 336:	02054563          	bltz	a0,360 <stat+0x42>
 33a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 33c:	85ca                	mv	a1,s2
 33e:	00000097          	auipc	ra,0x0
 342:	17a080e7          	jalr	378(ra) # 4b8 <fstat>
 346:	892a                	mv	s2,a0
  close(fd);
 348:	8526                	mv	a0,s1
 34a:	00000097          	auipc	ra,0x0
 34e:	13e080e7          	jalr	318(ra) # 488 <close>
  return r;
}
 352:	854a                	mv	a0,s2
 354:	60e2                	ld	ra,24(sp)
 356:	6442                	ld	s0,16(sp)
 358:	64a2                	ld	s1,8(sp)
 35a:	6902                	ld	s2,0(sp)
 35c:	6105                	addi	sp,sp,32
 35e:	8082                	ret
    return -1;
 360:	597d                	li	s2,-1
 362:	bfc5                	j	352 <stat+0x34>

0000000000000364 <atoi>:

int
atoi(const char *s)
{
 364:	1141                	addi	sp,sp,-16
 366:	e422                	sd	s0,8(sp)
 368:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 36a:	00054603          	lbu	a2,0(a0)
 36e:	fd06079b          	addiw	a5,a2,-48
 372:	0ff7f793          	andi	a5,a5,255
 376:	4725                	li	a4,9
 378:	02f76963          	bltu	a4,a5,3aa <atoi+0x46>
 37c:	86aa                	mv	a3,a0
  n = 0;
 37e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 380:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 382:	0685                	addi	a3,a3,1
 384:	0025179b          	slliw	a5,a0,0x2
 388:	9fa9                	addw	a5,a5,a0
 38a:	0017979b          	slliw	a5,a5,0x1
 38e:	9fb1                	addw	a5,a5,a2
 390:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 394:	0006c603          	lbu	a2,0(a3)
 398:	fd06071b          	addiw	a4,a2,-48
 39c:	0ff77713          	andi	a4,a4,255
 3a0:	fee5f1e3          	bgeu	a1,a4,382 <atoi+0x1e>
  return n;
}
 3a4:	6422                	ld	s0,8(sp)
 3a6:	0141                	addi	sp,sp,16
 3a8:	8082                	ret
  n = 0;
 3aa:	4501                	li	a0,0
 3ac:	bfe5                	j	3a4 <atoi+0x40>

00000000000003ae <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e422                	sd	s0,8(sp)
 3b2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3b4:	02b57463          	bgeu	a0,a1,3dc <memmove+0x2e>
    while(n-- > 0)
 3b8:	00c05f63          	blez	a2,3d6 <memmove+0x28>
 3bc:	1602                	slli	a2,a2,0x20
 3be:	9201                	srli	a2,a2,0x20
 3c0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3c6:	0585                	addi	a1,a1,1
 3c8:	0705                	addi	a4,a4,1
 3ca:	fff5c683          	lbu	a3,-1(a1)
 3ce:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3d2:	fee79ae3          	bne	a5,a4,3c6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3d6:	6422                	ld	s0,8(sp)
 3d8:	0141                	addi	sp,sp,16
 3da:	8082                	ret
    dst += n;
 3dc:	00c50733          	add	a4,a0,a2
    src += n;
 3e0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3e2:	fec05ae3          	blez	a2,3d6 <memmove+0x28>
 3e6:	fff6079b          	addiw	a5,a2,-1
 3ea:	1782                	slli	a5,a5,0x20
 3ec:	9381                	srli	a5,a5,0x20
 3ee:	fff7c793          	not	a5,a5
 3f2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3f4:	15fd                	addi	a1,a1,-1
 3f6:	177d                	addi	a4,a4,-1
 3f8:	0005c683          	lbu	a3,0(a1)
 3fc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 400:	fee79ae3          	bne	a5,a4,3f4 <memmove+0x46>
 404:	bfc9                	j	3d6 <memmove+0x28>

0000000000000406 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 406:	1141                	addi	sp,sp,-16
 408:	e422                	sd	s0,8(sp)
 40a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 40c:	ca05                	beqz	a2,43c <memcmp+0x36>
 40e:	fff6069b          	addiw	a3,a2,-1
 412:	1682                	slli	a3,a3,0x20
 414:	9281                	srli	a3,a3,0x20
 416:	0685                	addi	a3,a3,1
 418:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 41a:	00054783          	lbu	a5,0(a0)
 41e:	0005c703          	lbu	a4,0(a1)
 422:	00e79863          	bne	a5,a4,432 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 426:	0505                	addi	a0,a0,1
    p2++;
 428:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 42a:	fed518e3          	bne	a0,a3,41a <memcmp+0x14>
  }
  return 0;
 42e:	4501                	li	a0,0
 430:	a019                	j	436 <memcmp+0x30>
      return *p1 - *p2;
 432:	40e7853b          	subw	a0,a5,a4
}
 436:	6422                	ld	s0,8(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret
  return 0;
 43c:	4501                	li	a0,0
 43e:	bfe5                	j	436 <memcmp+0x30>

0000000000000440 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 440:	1141                	addi	sp,sp,-16
 442:	e406                	sd	ra,8(sp)
 444:	e022                	sd	s0,0(sp)
 446:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 448:	00000097          	auipc	ra,0x0
 44c:	f66080e7          	jalr	-154(ra) # 3ae <memmove>
}
 450:	60a2                	ld	ra,8(sp)
 452:	6402                	ld	s0,0(sp)
 454:	0141                	addi	sp,sp,16
 456:	8082                	ret

0000000000000458 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 458:	4885                	li	a7,1
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <exit>:
.global exit
exit:
 li a7, SYS_exit
 460:	4889                	li	a7,2
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <wait>:
.global wait
wait:
 li a7, SYS_wait
 468:	488d                	li	a7,3
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 470:	4891                	li	a7,4
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <read>:
.global read
read:
 li a7, SYS_read
 478:	4895                	li	a7,5
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <write>:
.global write
write:
 li a7, SYS_write
 480:	48c1                	li	a7,16
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <close>:
.global close
close:
 li a7, SYS_close
 488:	48d5                	li	a7,21
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <kill>:
.global kill
kill:
 li a7, SYS_kill
 490:	4899                	li	a7,6
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <exec>:
.global exec
exec:
 li a7, SYS_exec
 498:	489d                	li	a7,7
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <open>:
.global open
open:
 li a7, SYS_open
 4a0:	48bd                	li	a7,15
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4a8:	48c5                	li	a7,17
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b0:	48c9                	li	a7,18
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4b8:	48a1                	li	a7,8
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <link>:
.global link
link:
 li a7, SYS_link
 4c0:	48cd                	li	a7,19
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4c8:	48d1                	li	a7,20
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d0:	48a5                	li	a7,9
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4d8:	48a9                	li	a7,10
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e0:	48ad                	li	a7,11
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4e8:	48b1                	li	a7,12
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f0:	48b5                	li	a7,13
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4f8:	48b9                	li	a7,14
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 500:	48d9                	li	a7,22
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 508:	1101                	addi	sp,sp,-32
 50a:	ec06                	sd	ra,24(sp)
 50c:	e822                	sd	s0,16(sp)
 50e:	1000                	addi	s0,sp,32
 510:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 514:	4605                	li	a2,1
 516:	fef40593          	addi	a1,s0,-17
 51a:	00000097          	auipc	ra,0x0
 51e:	f66080e7          	jalr	-154(ra) # 480 <write>
}
 522:	60e2                	ld	ra,24(sp)
 524:	6442                	ld	s0,16(sp)
 526:	6105                	addi	sp,sp,32
 528:	8082                	ret

000000000000052a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 52a:	7139                	addi	sp,sp,-64
 52c:	fc06                	sd	ra,56(sp)
 52e:	f822                	sd	s0,48(sp)
 530:	f426                	sd	s1,40(sp)
 532:	f04a                	sd	s2,32(sp)
 534:	ec4e                	sd	s3,24(sp)
 536:	0080                	addi	s0,sp,64
 538:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 53a:	c299                	beqz	a3,540 <printint+0x16>
 53c:	0805c863          	bltz	a1,5cc <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 540:	2581                	sext.w	a1,a1
  neg = 0;
 542:	4881                	li	a7,0
 544:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 548:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 54a:	2601                	sext.w	a2,a2
 54c:	00000517          	auipc	a0,0x0
 550:	49450513          	addi	a0,a0,1172 # 9e0 <digits>
 554:	883a                	mv	a6,a4
 556:	2705                	addiw	a4,a4,1
 558:	02c5f7bb          	remuw	a5,a1,a2
 55c:	1782                	slli	a5,a5,0x20
 55e:	9381                	srli	a5,a5,0x20
 560:	97aa                	add	a5,a5,a0
 562:	0007c783          	lbu	a5,0(a5)
 566:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 56a:	0005879b          	sext.w	a5,a1
 56e:	02c5d5bb          	divuw	a1,a1,a2
 572:	0685                	addi	a3,a3,1
 574:	fec7f0e3          	bgeu	a5,a2,554 <printint+0x2a>
  if(neg)
 578:	00088b63          	beqz	a7,58e <printint+0x64>
    buf[i++] = '-';
 57c:	fd040793          	addi	a5,s0,-48
 580:	973e                	add	a4,a4,a5
 582:	02d00793          	li	a5,45
 586:	fef70823          	sb	a5,-16(a4)
 58a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 58e:	02e05863          	blez	a4,5be <printint+0x94>
 592:	fc040793          	addi	a5,s0,-64
 596:	00e78933          	add	s2,a5,a4
 59a:	fff78993          	addi	s3,a5,-1
 59e:	99ba                	add	s3,s3,a4
 5a0:	377d                	addiw	a4,a4,-1
 5a2:	1702                	slli	a4,a4,0x20
 5a4:	9301                	srli	a4,a4,0x20
 5a6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5aa:	fff94583          	lbu	a1,-1(s2)
 5ae:	8526                	mv	a0,s1
 5b0:	00000097          	auipc	ra,0x0
 5b4:	f58080e7          	jalr	-168(ra) # 508 <putc>
  while(--i >= 0)
 5b8:	197d                	addi	s2,s2,-1
 5ba:	ff3918e3          	bne	s2,s3,5aa <printint+0x80>
}
 5be:	70e2                	ld	ra,56(sp)
 5c0:	7442                	ld	s0,48(sp)
 5c2:	74a2                	ld	s1,40(sp)
 5c4:	7902                	ld	s2,32(sp)
 5c6:	69e2                	ld	s3,24(sp)
 5c8:	6121                	addi	sp,sp,64
 5ca:	8082                	ret
    x = -xx;
 5cc:	40b005bb          	negw	a1,a1
    neg = 1;
 5d0:	4885                	li	a7,1
    x = -xx;
 5d2:	bf8d                	j	544 <printint+0x1a>

00000000000005d4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d4:	7119                	addi	sp,sp,-128
 5d6:	fc86                	sd	ra,120(sp)
 5d8:	f8a2                	sd	s0,112(sp)
 5da:	f4a6                	sd	s1,104(sp)
 5dc:	f0ca                	sd	s2,96(sp)
 5de:	ecce                	sd	s3,88(sp)
 5e0:	e8d2                	sd	s4,80(sp)
 5e2:	e4d6                	sd	s5,72(sp)
 5e4:	e0da                	sd	s6,64(sp)
 5e6:	fc5e                	sd	s7,56(sp)
 5e8:	f862                	sd	s8,48(sp)
 5ea:	f466                	sd	s9,40(sp)
 5ec:	f06a                	sd	s10,32(sp)
 5ee:	ec6e                	sd	s11,24(sp)
 5f0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5f2:	0005c903          	lbu	s2,0(a1)
 5f6:	18090f63          	beqz	s2,794 <vprintf+0x1c0>
 5fa:	8aaa                	mv	s5,a0
 5fc:	8b32                	mv	s6,a2
 5fe:	00158493          	addi	s1,a1,1
  state = 0;
 602:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 604:	02500a13          	li	s4,37
      if(c == 'd'){
 608:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 60c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 610:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 614:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 618:	00000b97          	auipc	s7,0x0
 61c:	3c8b8b93          	addi	s7,s7,968 # 9e0 <digits>
 620:	a839                	j	63e <vprintf+0x6a>
        putc(fd, c);
 622:	85ca                	mv	a1,s2
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	ee2080e7          	jalr	-286(ra) # 508 <putc>
 62e:	a019                	j	634 <vprintf+0x60>
    } else if(state == '%'){
 630:	01498f63          	beq	s3,s4,64e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 634:	0485                	addi	s1,s1,1
 636:	fff4c903          	lbu	s2,-1(s1)
 63a:	14090d63          	beqz	s2,794 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 63e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 642:	fe0997e3          	bnez	s3,630 <vprintf+0x5c>
      if(c == '%'){
 646:	fd479ee3          	bne	a5,s4,622 <vprintf+0x4e>
        state = '%';
 64a:	89be                	mv	s3,a5
 64c:	b7e5                	j	634 <vprintf+0x60>
      if(c == 'd'){
 64e:	05878063          	beq	a5,s8,68e <vprintf+0xba>
      } else if(c == 'l') {
 652:	05978c63          	beq	a5,s9,6aa <vprintf+0xd6>
      } else if(c == 'x') {
 656:	07a78863          	beq	a5,s10,6c6 <vprintf+0xf2>
      } else if(c == 'p') {
 65a:	09b78463          	beq	a5,s11,6e2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 65e:	07300713          	li	a4,115
 662:	0ce78663          	beq	a5,a4,72e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 666:	06300713          	li	a4,99
 66a:	0ee78e63          	beq	a5,a4,766 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 66e:	11478863          	beq	a5,s4,77e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 672:	85d2                	mv	a1,s4
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	e92080e7          	jalr	-366(ra) # 508 <putc>
        putc(fd, c);
 67e:	85ca                	mv	a1,s2
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e86080e7          	jalr	-378(ra) # 508 <putc>
      }
      state = 0;
 68a:	4981                	li	s3,0
 68c:	b765                	j	634 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 68e:	008b0913          	addi	s2,s6,8
 692:	4685                	li	a3,1
 694:	4629                	li	a2,10
 696:	000b2583          	lw	a1,0(s6)
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	e8e080e7          	jalr	-370(ra) # 52a <printint>
 6a4:	8b4a                	mv	s6,s2
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	b771                	j	634 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6aa:	008b0913          	addi	s2,s6,8
 6ae:	4681                	li	a3,0
 6b0:	4629                	li	a2,10
 6b2:	000b2583          	lw	a1,0(s6)
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	e72080e7          	jalr	-398(ra) # 52a <printint>
 6c0:	8b4a                	mv	s6,s2
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	bf85                	j	634 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6c6:	008b0913          	addi	s2,s6,8
 6ca:	4681                	li	a3,0
 6cc:	4641                	li	a2,16
 6ce:	000b2583          	lw	a1,0(s6)
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	e56080e7          	jalr	-426(ra) # 52a <printint>
 6dc:	8b4a                	mv	s6,s2
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	bf91                	j	634 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6e2:	008b0793          	addi	a5,s6,8
 6e6:	f8f43423          	sd	a5,-120(s0)
 6ea:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6ee:	03000593          	li	a1,48
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	e14080e7          	jalr	-492(ra) # 508 <putc>
  putc(fd, 'x');
 6fc:	85ea                	mv	a1,s10
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	e08080e7          	jalr	-504(ra) # 508 <putc>
 708:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70a:	03c9d793          	srli	a5,s3,0x3c
 70e:	97de                	add	a5,a5,s7
 710:	0007c583          	lbu	a1,0(a5)
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	df2080e7          	jalr	-526(ra) # 508 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 71e:	0992                	slli	s3,s3,0x4
 720:	397d                	addiw	s2,s2,-1
 722:	fe0914e3          	bnez	s2,70a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 726:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b721                	j	634 <vprintf+0x60>
        s = va_arg(ap, char*);
 72e:	008b0993          	addi	s3,s6,8
 732:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 736:	02090163          	beqz	s2,758 <vprintf+0x184>
        while(*s != 0){
 73a:	00094583          	lbu	a1,0(s2)
 73e:	c9a1                	beqz	a1,78e <vprintf+0x1ba>
          putc(fd, *s);
 740:	8556                	mv	a0,s5
 742:	00000097          	auipc	ra,0x0
 746:	dc6080e7          	jalr	-570(ra) # 508 <putc>
          s++;
 74a:	0905                	addi	s2,s2,1
        while(*s != 0){
 74c:	00094583          	lbu	a1,0(s2)
 750:	f9e5                	bnez	a1,740 <vprintf+0x16c>
        s = va_arg(ap, char*);
 752:	8b4e                	mv	s6,s3
      state = 0;
 754:	4981                	li	s3,0
 756:	bdf9                	j	634 <vprintf+0x60>
          s = "(null)";
 758:	00000917          	auipc	s2,0x0
 75c:	28090913          	addi	s2,s2,640 # 9d8 <malloc+0x13a>
        while(*s != 0){
 760:	02800593          	li	a1,40
 764:	bff1                	j	740 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 766:	008b0913          	addi	s2,s6,8
 76a:	000b4583          	lbu	a1,0(s6)
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	d98080e7          	jalr	-616(ra) # 508 <putc>
 778:	8b4a                	mv	s6,s2
      state = 0;
 77a:	4981                	li	s3,0
 77c:	bd65                	j	634 <vprintf+0x60>
        putc(fd, c);
 77e:	85d2                	mv	a1,s4
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	d86080e7          	jalr	-634(ra) # 508 <putc>
      state = 0;
 78a:	4981                	li	s3,0
 78c:	b565                	j	634 <vprintf+0x60>
        s = va_arg(ap, char*);
 78e:	8b4e                	mv	s6,s3
      state = 0;
 790:	4981                	li	s3,0
 792:	b54d                	j	634 <vprintf+0x60>
    }
  }
}
 794:	70e6                	ld	ra,120(sp)
 796:	7446                	ld	s0,112(sp)
 798:	74a6                	ld	s1,104(sp)
 79a:	7906                	ld	s2,96(sp)
 79c:	69e6                	ld	s3,88(sp)
 79e:	6a46                	ld	s4,80(sp)
 7a0:	6aa6                	ld	s5,72(sp)
 7a2:	6b06                	ld	s6,64(sp)
 7a4:	7be2                	ld	s7,56(sp)
 7a6:	7c42                	ld	s8,48(sp)
 7a8:	7ca2                	ld	s9,40(sp)
 7aa:	7d02                	ld	s10,32(sp)
 7ac:	6de2                	ld	s11,24(sp)
 7ae:	6109                	addi	sp,sp,128
 7b0:	8082                	ret

00000000000007b2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b2:	715d                	addi	sp,sp,-80
 7b4:	ec06                	sd	ra,24(sp)
 7b6:	e822                	sd	s0,16(sp)
 7b8:	1000                	addi	s0,sp,32
 7ba:	e010                	sd	a2,0(s0)
 7bc:	e414                	sd	a3,8(s0)
 7be:	e818                	sd	a4,16(s0)
 7c0:	ec1c                	sd	a5,24(s0)
 7c2:	03043023          	sd	a6,32(s0)
 7c6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ca:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ce:	8622                	mv	a2,s0
 7d0:	00000097          	auipc	ra,0x0
 7d4:	e04080e7          	jalr	-508(ra) # 5d4 <vprintf>
}
 7d8:	60e2                	ld	ra,24(sp)
 7da:	6442                	ld	s0,16(sp)
 7dc:	6161                	addi	sp,sp,80
 7de:	8082                	ret

00000000000007e0 <printf>:

void
printf(const char *fmt, ...)
{
 7e0:	711d                	addi	sp,sp,-96
 7e2:	ec06                	sd	ra,24(sp)
 7e4:	e822                	sd	s0,16(sp)
 7e6:	1000                	addi	s0,sp,32
 7e8:	e40c                	sd	a1,8(s0)
 7ea:	e810                	sd	a2,16(s0)
 7ec:	ec14                	sd	a3,24(s0)
 7ee:	f018                	sd	a4,32(s0)
 7f0:	f41c                	sd	a5,40(s0)
 7f2:	03043823          	sd	a6,48(s0)
 7f6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fa:	00840613          	addi	a2,s0,8
 7fe:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 802:	85aa                	mv	a1,a0
 804:	4505                	li	a0,1
 806:	00000097          	auipc	ra,0x0
 80a:	dce080e7          	jalr	-562(ra) # 5d4 <vprintf>
}
 80e:	60e2                	ld	ra,24(sp)
 810:	6442                	ld	s0,16(sp)
 812:	6125                	addi	sp,sp,96
 814:	8082                	ret

0000000000000816 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 816:	1141                	addi	sp,sp,-16
 818:	e422                	sd	s0,8(sp)
 81a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	00000797          	auipc	a5,0x0
 824:	1d87b783          	ld	a5,472(a5) # 9f8 <freep>
 828:	a805                	j	858 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 82a:	4618                	lw	a4,8(a2)
 82c:	9db9                	addw	a1,a1,a4
 82e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 832:	6398                	ld	a4,0(a5)
 834:	6318                	ld	a4,0(a4)
 836:	fee53823          	sd	a4,-16(a0)
 83a:	a091                	j	87e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 83c:	ff852703          	lw	a4,-8(a0)
 840:	9e39                	addw	a2,a2,a4
 842:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 844:	ff053703          	ld	a4,-16(a0)
 848:	e398                	sd	a4,0(a5)
 84a:	a099                	j	890 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84c:	6398                	ld	a4,0(a5)
 84e:	00e7e463          	bltu	a5,a4,856 <free+0x40>
 852:	00e6ea63          	bltu	a3,a4,866 <free+0x50>
{
 856:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 858:	fed7fae3          	bgeu	a5,a3,84c <free+0x36>
 85c:	6398                	ld	a4,0(a5)
 85e:	00e6e463          	bltu	a3,a4,866 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 862:	fee7eae3          	bltu	a5,a4,856 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 866:	ff852583          	lw	a1,-8(a0)
 86a:	6390                	ld	a2,0(a5)
 86c:	02059713          	slli	a4,a1,0x20
 870:	9301                	srli	a4,a4,0x20
 872:	0712                	slli	a4,a4,0x4
 874:	9736                	add	a4,a4,a3
 876:	fae60ae3          	beq	a2,a4,82a <free+0x14>
    bp->s.ptr = p->s.ptr;
 87a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 87e:	4790                	lw	a2,8(a5)
 880:	02061713          	slli	a4,a2,0x20
 884:	9301                	srli	a4,a4,0x20
 886:	0712                	slli	a4,a4,0x4
 888:	973e                	add	a4,a4,a5
 88a:	fae689e3          	beq	a3,a4,83c <free+0x26>
  } else
    p->s.ptr = bp;
 88e:	e394                	sd	a3,0(a5)
  freep = p;
 890:	00000717          	auipc	a4,0x0
 894:	16f73423          	sd	a5,360(a4) # 9f8 <freep>
}
 898:	6422                	ld	s0,8(sp)
 89a:	0141                	addi	sp,sp,16
 89c:	8082                	ret

000000000000089e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 89e:	7139                	addi	sp,sp,-64
 8a0:	fc06                	sd	ra,56(sp)
 8a2:	f822                	sd	s0,48(sp)
 8a4:	f426                	sd	s1,40(sp)
 8a6:	f04a                	sd	s2,32(sp)
 8a8:	ec4e                	sd	s3,24(sp)
 8aa:	e852                	sd	s4,16(sp)
 8ac:	e456                	sd	s5,8(sp)
 8ae:	e05a                	sd	s6,0(sp)
 8b0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b2:	02051493          	slli	s1,a0,0x20
 8b6:	9081                	srli	s1,s1,0x20
 8b8:	04bd                	addi	s1,s1,15
 8ba:	8091                	srli	s1,s1,0x4
 8bc:	0014899b          	addiw	s3,s1,1
 8c0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8c2:	00000517          	auipc	a0,0x0
 8c6:	13653503          	ld	a0,310(a0) # 9f8 <freep>
 8ca:	c515                	beqz	a0,8f6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ce:	4798                	lw	a4,8(a5)
 8d0:	02977f63          	bgeu	a4,s1,90e <malloc+0x70>
 8d4:	8a4e                	mv	s4,s3
 8d6:	0009871b          	sext.w	a4,s3
 8da:	6685                	lui	a3,0x1
 8dc:	00d77363          	bgeu	a4,a3,8e2 <malloc+0x44>
 8e0:	6a05                	lui	s4,0x1
 8e2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ea:	00000917          	auipc	s2,0x0
 8ee:	10e90913          	addi	s2,s2,270 # 9f8 <freep>
  if(p == (char*)-1)
 8f2:	5afd                	li	s5,-1
 8f4:	a88d                	j	966 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8f6:	00000797          	auipc	a5,0x0
 8fa:	10a78793          	addi	a5,a5,266 # a00 <base>
 8fe:	00000717          	auipc	a4,0x0
 902:	0ef73d23          	sd	a5,250(a4) # 9f8 <freep>
 906:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 908:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 90c:	b7e1                	j	8d4 <malloc+0x36>
      if(p->s.size == nunits)
 90e:	02e48b63          	beq	s1,a4,944 <malloc+0xa6>
        p->s.size -= nunits;
 912:	4137073b          	subw	a4,a4,s3
 916:	c798                	sw	a4,8(a5)
        p += p->s.size;
 918:	1702                	slli	a4,a4,0x20
 91a:	9301                	srli	a4,a4,0x20
 91c:	0712                	slli	a4,a4,0x4
 91e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 920:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 924:	00000717          	auipc	a4,0x0
 928:	0ca73a23          	sd	a0,212(a4) # 9f8 <freep>
      return (void*)(p + 1);
 92c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 930:	70e2                	ld	ra,56(sp)
 932:	7442                	ld	s0,48(sp)
 934:	74a2                	ld	s1,40(sp)
 936:	7902                	ld	s2,32(sp)
 938:	69e2                	ld	s3,24(sp)
 93a:	6a42                	ld	s4,16(sp)
 93c:	6aa2                	ld	s5,8(sp)
 93e:	6b02                	ld	s6,0(sp)
 940:	6121                	addi	sp,sp,64
 942:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 944:	6398                	ld	a4,0(a5)
 946:	e118                	sd	a4,0(a0)
 948:	bff1                	j	924 <malloc+0x86>
  hp->s.size = nu;
 94a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 94e:	0541                	addi	a0,a0,16
 950:	00000097          	auipc	ra,0x0
 954:	ec6080e7          	jalr	-314(ra) # 816 <free>
  return freep;
 958:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 95c:	d971                	beqz	a0,930 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 960:	4798                	lw	a4,8(a5)
 962:	fa9776e3          	bgeu	a4,s1,90e <malloc+0x70>
    if(p == freep)
 966:	00093703          	ld	a4,0(s2)
 96a:	853e                	mv	a0,a5
 96c:	fef719e3          	bne	a4,a5,95e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 970:	8552                	mv	a0,s4
 972:	00000097          	auipc	ra,0x0
 976:	b76080e7          	jalr	-1162(ra) # 4e8 <sbrk>
  if(p == (char*)-1)
 97a:	fd5518e3          	bne	a0,s5,94a <malloc+0xac>
        return 0;
 97e:	4501                	li	a0,0
 980:	bf45                	j	930 <malloc+0x92>
