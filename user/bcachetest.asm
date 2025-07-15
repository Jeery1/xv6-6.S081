
user/_bcachetest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <createfile>:
  exit(0);
}

void
createfile(char *file, int nblock)
{
   0:	bd010113          	addi	sp,sp,-1072
   4:	42113423          	sd	ra,1064(sp)
   8:	42813023          	sd	s0,1056(sp)
   c:	40913c23          	sd	s1,1048(sp)
  10:	41213823          	sd	s2,1040(sp)
  14:	41313423          	sd	s3,1032(sp)
  18:	41413023          	sd	s4,1024(sp)
  1c:	43010413          	addi	s0,sp,1072
  20:	8a2a                	mv	s4,a0
  22:	89ae                	mv	s3,a1
  int fd;
  char buf[BSIZE];
  int i;
  
  fd = open(file, O_CREATE | O_RDWR);
  24:	20200593          	li	a1,514
  28:	00000097          	auipc	ra,0x0
  2c:	6c6080e7          	jalr	1734(ra) # 6ee <open>
  if(fd < 0){
  30:	04054a63          	bltz	a0,84 <createfile+0x84>
  34:	892a                	mv	s2,a0
    printf("test0 create %s failed\n", file);
    exit(-1);
  }
  for(i = 0; i < nblock; i++) {
  36:	4481                	li	s1,0
  38:	03305263          	blez	s3,5c <createfile+0x5c>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)) {
  3c:	40000613          	li	a2,1024
  40:	bd040593          	addi	a1,s0,-1072
  44:	854a                	mv	a0,s2
  46:	00000097          	auipc	ra,0x0
  4a:	688080e7          	jalr	1672(ra) # 6ce <write>
  4e:	40000793          	li	a5,1024
  52:	04f51763          	bne	a0,a5,a0 <createfile+0xa0>
  for(i = 0; i < nblock; i++) {
  56:	2485                	addiw	s1,s1,1
  58:	fe9992e3          	bne	s3,s1,3c <createfile+0x3c>
      printf("write %s failed\n", file);
      exit(-1);
    }
  }
  close(fd);
  5c:	854a                	mv	a0,s2
  5e:	00000097          	auipc	ra,0x0
  62:	678080e7          	jalr	1656(ra) # 6d6 <close>
}
  66:	42813083          	ld	ra,1064(sp)
  6a:	42013403          	ld	s0,1056(sp)
  6e:	41813483          	ld	s1,1048(sp)
  72:	41013903          	ld	s2,1040(sp)
  76:	40813983          	ld	s3,1032(sp)
  7a:	40013a03          	ld	s4,1024(sp)
  7e:	43010113          	addi	sp,sp,1072
  82:	8082                	ret
    printf("test0 create %s failed\n", file);
  84:	85d2                	mv	a1,s4
  86:	00001517          	auipc	a0,0x1
  8a:	b6250513          	addi	a0,a0,-1182 # be8 <malloc+0xe4>
  8e:	00001097          	auipc	ra,0x1
  92:	9b8080e7          	jalr	-1608(ra) # a46 <printf>
    exit(-1);
  96:	557d                	li	a0,-1
  98:	00000097          	auipc	ra,0x0
  9c:	616080e7          	jalr	1558(ra) # 6ae <exit>
      printf("write %s failed\n", file);
  a0:	85d2                	mv	a1,s4
  a2:	00001517          	auipc	a0,0x1
  a6:	b5e50513          	addi	a0,a0,-1186 # c00 <malloc+0xfc>
  aa:	00001097          	auipc	ra,0x1
  ae:	99c080e7          	jalr	-1636(ra) # a46 <printf>
      exit(-1);
  b2:	557d                	li	a0,-1
  b4:	00000097          	auipc	ra,0x0
  b8:	5fa080e7          	jalr	1530(ra) # 6ae <exit>

00000000000000bc <readfile>:

void
readfile(char *file, int nbytes, int inc)
{
  bc:	bc010113          	addi	sp,sp,-1088
  c0:	42113c23          	sd	ra,1080(sp)
  c4:	42813823          	sd	s0,1072(sp)
  c8:	42913423          	sd	s1,1064(sp)
  cc:	43213023          	sd	s2,1056(sp)
  d0:	41313c23          	sd	s3,1048(sp)
  d4:	41413823          	sd	s4,1040(sp)
  d8:	41513423          	sd	s5,1032(sp)
  dc:	44010413          	addi	s0,sp,1088
  char buf[BSIZE];
  int fd;
  int i;

  if(inc > BSIZE) {
  e0:	40000793          	li	a5,1024
  e4:	06c7c463          	blt	a5,a2,14c <readfile+0x90>
  e8:	8aaa                	mv	s5,a0
  ea:	8a2e                	mv	s4,a1
  ec:	84b2                	mv	s1,a2
    printf("test0: inc too large\n");
    exit(-1);
  }
  if ((fd = open(file, O_RDONLY)) < 0) {
  ee:	4581                	li	a1,0
  f0:	00000097          	auipc	ra,0x0
  f4:	5fe080e7          	jalr	1534(ra) # 6ee <open>
  f8:	89aa                	mv	s3,a0
  fa:	06054663          	bltz	a0,166 <readfile+0xaa>
    printf("test0 open %s failed\n", file);
    exit(-1);
  }
  for (i = 0; i < nbytes; i += inc) {
  fe:	4901                	li	s2,0
 100:	03405063          	blez	s4,120 <readfile+0x64>
    if(read(fd, buf, inc) != inc) {
 104:	8626                	mv	a2,s1
 106:	bc040593          	addi	a1,s0,-1088
 10a:	854e                	mv	a0,s3
 10c:	00000097          	auipc	ra,0x0
 110:	5ba080e7          	jalr	1466(ra) # 6c6 <read>
 114:	06951763          	bne	a0,s1,182 <readfile+0xc6>
  for (i = 0; i < nbytes; i += inc) {
 118:	0124893b          	addw	s2,s1,s2
 11c:	ff4944e3          	blt	s2,s4,104 <readfile+0x48>
      printf("read %s failed for block %d (%d)\n", file, i, nbytes);
      exit(-1);
    }
  }
  close(fd);
 120:	854e                	mv	a0,s3
 122:	00000097          	auipc	ra,0x0
 126:	5b4080e7          	jalr	1460(ra) # 6d6 <close>
}
 12a:	43813083          	ld	ra,1080(sp)
 12e:	43013403          	ld	s0,1072(sp)
 132:	42813483          	ld	s1,1064(sp)
 136:	42013903          	ld	s2,1056(sp)
 13a:	41813983          	ld	s3,1048(sp)
 13e:	41013a03          	ld	s4,1040(sp)
 142:	40813a83          	ld	s5,1032(sp)
 146:	44010113          	addi	sp,sp,1088
 14a:	8082                	ret
    printf("test0: inc too large\n");
 14c:	00001517          	auipc	a0,0x1
 150:	acc50513          	addi	a0,a0,-1332 # c18 <malloc+0x114>
 154:	00001097          	auipc	ra,0x1
 158:	8f2080e7          	jalr	-1806(ra) # a46 <printf>
    exit(-1);
 15c:	557d                	li	a0,-1
 15e:	00000097          	auipc	ra,0x0
 162:	550080e7          	jalr	1360(ra) # 6ae <exit>
    printf("test0 open %s failed\n", file);
 166:	85d6                	mv	a1,s5
 168:	00001517          	auipc	a0,0x1
 16c:	ac850513          	addi	a0,a0,-1336 # c30 <malloc+0x12c>
 170:	00001097          	auipc	ra,0x1
 174:	8d6080e7          	jalr	-1834(ra) # a46 <printf>
    exit(-1);
 178:	557d                	li	a0,-1
 17a:	00000097          	auipc	ra,0x0
 17e:	534080e7          	jalr	1332(ra) # 6ae <exit>
      printf("read %s failed for block %d (%d)\n", file, i, nbytes);
 182:	86d2                	mv	a3,s4
 184:	864a                	mv	a2,s2
 186:	85d6                	mv	a1,s5
 188:	00001517          	auipc	a0,0x1
 18c:	ac050513          	addi	a0,a0,-1344 # c48 <malloc+0x144>
 190:	00001097          	auipc	ra,0x1
 194:	8b6080e7          	jalr	-1866(ra) # a46 <printf>
      exit(-1);
 198:	557d                	li	a0,-1
 19a:	00000097          	auipc	ra,0x0
 19e:	514080e7          	jalr	1300(ra) # 6ae <exit>

00000000000001a2 <test0>:

void
test0()
{
 1a2:	7139                	addi	sp,sp,-64
 1a4:	fc06                	sd	ra,56(sp)
 1a6:	f822                	sd	s0,48(sp)
 1a8:	f426                	sd	s1,40(sp)
 1aa:	f04a                	sd	s2,32(sp)
 1ac:	ec4e                	sd	s3,24(sp)
 1ae:	0080                	addi	s0,sp,64
  char file[2];
  char dir[2];
  enum { N = 10, NCHILD = 3 };
  int n;

  dir[0] = '0';
 1b0:	03000793          	li	a5,48
 1b4:	fcf40023          	sb	a5,-64(s0)
  dir[1] = '\0';
 1b8:	fc0400a3          	sb	zero,-63(s0)
  file[0] = 'F';
 1bc:	04600793          	li	a5,70
 1c0:	fcf40423          	sb	a5,-56(s0)
  file[1] = '\0';
 1c4:	fc0404a3          	sb	zero,-55(s0)

  printf("start test0\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	aa850513          	addi	a0,a0,-1368 # c70 <malloc+0x16c>
 1d0:	00001097          	auipc	ra,0x1
 1d4:	876080e7          	jalr	-1930(ra) # a46 <printf>
 1d8:	03000493          	li	s1,48
    if (chdir(dir) < 0) {
      printf("chdir failed\n");
      exit(1);
    }
    createfile(file, N);
    if (chdir("..") < 0) {
 1dc:	00001997          	auipc	s3,0x1
 1e0:	ac498993          	addi	s3,s3,-1340 # ca0 <malloc+0x19c>
  for(int i = 0; i < NCHILD; i++){
 1e4:	03300913          	li	s2,51
    dir[0] = '0' + i;
 1e8:	fc940023          	sb	s1,-64(s0)
    if (mkdir(dir) < 0) {
 1ec:	fc040513          	addi	a0,s0,-64
 1f0:	00000097          	auipc	ra,0x0
 1f4:	526080e7          	jalr	1318(ra) # 716 <mkdir>
 1f8:	0c054063          	bltz	a0,2b8 <test0+0x116>
    if (chdir(dir) < 0) {
 1fc:	fc040513          	addi	a0,s0,-64
 200:	00000097          	auipc	ra,0x0
 204:	51e080e7          	jalr	1310(ra) # 71e <chdir>
 208:	0c054563          	bltz	a0,2d2 <test0+0x130>
    createfile(file, N);
 20c:	45a9                	li	a1,10
 20e:	fc840513          	addi	a0,s0,-56
 212:	00000097          	auipc	ra,0x0
 216:	dee080e7          	jalr	-530(ra) # 0 <createfile>
    if (chdir("..") < 0) {
 21a:	854e                	mv	a0,s3
 21c:	00000097          	auipc	ra,0x0
 220:	502080e7          	jalr	1282(ra) # 71e <chdir>
 224:	0c054463          	bltz	a0,2ec <test0+0x14a>
  for(int i = 0; i < NCHILD; i++){
 228:	2485                	addiw	s1,s1,1
 22a:	0ff4f493          	andi	s1,s1,255
 22e:	fb249de3          	bne	s1,s2,1e8 <test0+0x46>
      printf("chdir failed\n");
      exit(1);
    }
  }
  ntas(0);
 232:	4501                	li	a0,0
 234:	00000097          	auipc	ra,0x0
 238:	51a080e7          	jalr	1306(ra) # 74e <ntas>
 23c:	03000493          	li	s1,48
  for(int i = 0; i < NCHILD; i++){
 240:	03300913          	li	s2,51
    dir[0] = '0' + i;
 244:	fc940023          	sb	s1,-64(s0)
    int pid = fork();
 248:	00000097          	auipc	ra,0x0
 24c:	45e080e7          	jalr	1118(ra) # 6a6 <fork>
    if(pid < 0){
 250:	0a054b63          	bltz	a0,306 <test0+0x164>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
 254:	c571                	beqz	a0,320 <test0+0x17e>
  for(int i = 0; i < NCHILD; i++){
 256:	2485                	addiw	s1,s1,1
 258:	0ff4f493          	andi	s1,s1,255
 25c:	ff2494e3          	bne	s1,s2,244 <test0+0xa2>
      exit(0);
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait(0);
 260:	4501                	li	a0,0
 262:	00000097          	auipc	ra,0x0
 266:	454080e7          	jalr	1108(ra) # 6b6 <wait>
 26a:	4501                	li	a0,0
 26c:	00000097          	auipc	ra,0x0
 270:	44a080e7          	jalr	1098(ra) # 6b6 <wait>
 274:	4501                	li	a0,0
 276:	00000097          	auipc	ra,0x0
 27a:	440080e7          	jalr	1088(ra) # 6b6 <wait>
  }
  printf("test0 results:\n");
 27e:	00001517          	auipc	a0,0x1
 282:	a3a50513          	addi	a0,a0,-1478 # cb8 <malloc+0x1b4>
 286:	00000097          	auipc	ra,0x0
 28a:	7c0080e7          	jalr	1984(ra) # a46 <printf>
  n = ntas(1);
 28e:	4505                	li	a0,1
 290:	00000097          	auipc	ra,0x0
 294:	4be080e7          	jalr	1214(ra) # 74e <ntas>
  if (n == 0)
 298:	e94d                	bnez	a0,34a <test0+0x1a8>
    printf("test0: OK\n");
 29a:	00001517          	auipc	a0,0x1
 29e:	a2e50513          	addi	a0,a0,-1490 # cc8 <malloc+0x1c4>
 2a2:	00000097          	auipc	ra,0x0
 2a6:	7a4080e7          	jalr	1956(ra) # a46 <printf>
  else
    printf("test0: FAIL\n");
}
 2aa:	70e2                	ld	ra,56(sp)
 2ac:	7442                	ld	s0,48(sp)
 2ae:	74a2                	ld	s1,40(sp)
 2b0:	7902                	ld	s2,32(sp)
 2b2:	69e2                	ld	s3,24(sp)
 2b4:	6121                	addi	sp,sp,64
 2b6:	8082                	ret
      printf("mkdir failed\n");
 2b8:	00001517          	auipc	a0,0x1
 2bc:	9c850513          	addi	a0,a0,-1592 # c80 <malloc+0x17c>
 2c0:	00000097          	auipc	ra,0x0
 2c4:	786080e7          	jalr	1926(ra) # a46 <printf>
      exit(1);
 2c8:	4505                	li	a0,1
 2ca:	00000097          	auipc	ra,0x0
 2ce:	3e4080e7          	jalr	996(ra) # 6ae <exit>
      printf("chdir failed\n");
 2d2:	00001517          	auipc	a0,0x1
 2d6:	9be50513          	addi	a0,a0,-1602 # c90 <malloc+0x18c>
 2da:	00000097          	auipc	ra,0x0
 2de:	76c080e7          	jalr	1900(ra) # a46 <printf>
      exit(1);
 2e2:	4505                	li	a0,1
 2e4:	00000097          	auipc	ra,0x0
 2e8:	3ca080e7          	jalr	970(ra) # 6ae <exit>
      printf("chdir failed\n");
 2ec:	00001517          	auipc	a0,0x1
 2f0:	9a450513          	addi	a0,a0,-1628 # c90 <malloc+0x18c>
 2f4:	00000097          	auipc	ra,0x0
 2f8:	752080e7          	jalr	1874(ra) # a46 <printf>
      exit(1);
 2fc:	4505                	li	a0,1
 2fe:	00000097          	auipc	ra,0x0
 302:	3b0080e7          	jalr	944(ra) # 6ae <exit>
      printf("fork failed");
 306:	00001517          	auipc	a0,0x1
 30a:	9a250513          	addi	a0,a0,-1630 # ca8 <malloc+0x1a4>
 30e:	00000097          	auipc	ra,0x0
 312:	738080e7          	jalr	1848(ra) # a46 <printf>
      exit(-1);
 316:	557d                	li	a0,-1
 318:	00000097          	auipc	ra,0x0
 31c:	396080e7          	jalr	918(ra) # 6ae <exit>
      if (chdir(dir) < 0) {
 320:	fc040513          	addi	a0,s0,-64
 324:	00000097          	auipc	ra,0x0
 328:	3fa080e7          	jalr	1018(ra) # 71e <chdir>
 32c:	02055863          	bgez	a0,35c <test0+0x1ba>
        printf("chdir failed\n");
 330:	00001517          	auipc	a0,0x1
 334:	96050513          	addi	a0,a0,-1696 # c90 <malloc+0x18c>
 338:	00000097          	auipc	ra,0x0
 33c:	70e080e7          	jalr	1806(ra) # a46 <printf>
        exit(1);
 340:	4505                	li	a0,1
 342:	00000097          	auipc	ra,0x0
 346:	36c080e7          	jalr	876(ra) # 6ae <exit>
    printf("test0: FAIL\n");
 34a:	00001517          	auipc	a0,0x1
 34e:	98e50513          	addi	a0,a0,-1650 # cd8 <malloc+0x1d4>
 352:	00000097          	auipc	ra,0x0
 356:	6f4080e7          	jalr	1780(ra) # a46 <printf>
}
 35a:	bf81                	j	2aa <test0+0x108>
        readfile(file, N*BSIZE, 1);
 35c:	4605                	li	a2,1
 35e:	658d                	lui	a1,0x3
 360:	80058593          	addi	a1,a1,-2048 # 2800 <__global_pointer$+0x12df>
 364:	fc840513          	addi	a0,s0,-56
 368:	00000097          	auipc	ra,0x0
 36c:	d54080e7          	jalr	-684(ra) # bc <readfile>
      exit(0);
 370:	4501                	li	a0,0
 372:	00000097          	auipc	ra,0x0
 376:	33c080e7          	jalr	828(ra) # 6ae <exit>

000000000000037a <test1>:

void test1()
{
 37a:	7179                	addi	sp,sp,-48
 37c:	f406                	sd	ra,40(sp)
 37e:	f022                	sd	s0,32(sp)
 380:	ec26                	sd	s1,24(sp)
 382:	1800                	addi	s0,sp,48
  char file[3];
  enum { N = 100, BIG=100, NCHILD=2 };
  
  printf("start test1\n");
 384:	00001517          	auipc	a0,0x1
 388:	96450513          	addi	a0,a0,-1692 # ce8 <malloc+0x1e4>
 38c:	00000097          	auipc	ra,0x0
 390:	6ba080e7          	jalr	1722(ra) # a46 <printf>
  file[0] = 'B';
 394:	04200793          	li	a5,66
 398:	fcf40c23          	sb	a5,-40(s0)
  file[2] = '\0';
 39c:	fc040d23          	sb	zero,-38(s0)
  for(int i = 0; i < 2; i++){
    file[1] = '0' + i;
 3a0:	03000493          	li	s1,48
 3a4:	fc940ca3          	sb	s1,-39(s0)
    if (i == 0) {
      createfile(file, BIG);
 3a8:	06400593          	li	a1,100
 3ac:	fd840513          	addi	a0,s0,-40
 3b0:	00000097          	auipc	ra,0x0
 3b4:	c50080e7          	jalr	-944(ra) # 0 <createfile>
    file[1] = '0' + i;
 3b8:	03100793          	li	a5,49
 3bc:	fcf40ca3          	sb	a5,-39(s0)
    } else {
      createfile(file, 1);
 3c0:	4585                	li	a1,1
 3c2:	fd840513          	addi	a0,s0,-40
 3c6:	00000097          	auipc	ra,0x0
 3ca:	c3a080e7          	jalr	-966(ra) # 0 <createfile>
    }
  }
  for(int i = 0; i < NCHILD; i++){
    file[1] = '0' + i;
 3ce:	fc940ca3          	sb	s1,-39(s0)
    int pid = fork();
 3d2:	00000097          	auipc	ra,0x0
 3d6:	2d4080e7          	jalr	724(ra) # 6a6 <fork>
    if(pid < 0){
 3da:	04054563          	bltz	a0,424 <test1+0xaa>
      printf("fork failed");
      exit(-1);
    }
    if(pid == 0){
 3de:	c125                	beqz	a0,43e <test1+0xc4>
    file[1] = '0' + i;
 3e0:	03100793          	li	a5,49
 3e4:	fcf40ca3          	sb	a5,-39(s0)
    int pid = fork();
 3e8:	00000097          	auipc	ra,0x0
 3ec:	2be080e7          	jalr	702(ra) # 6a6 <fork>
    if(pid < 0){
 3f0:	02054a63          	bltz	a0,424 <test1+0xaa>
    if(pid == 0){
 3f4:	cd2d                	beqz	a0,46e <test1+0xf4>
      exit(0);
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait(0);
 3f6:	4501                	li	a0,0
 3f8:	00000097          	auipc	ra,0x0
 3fc:	2be080e7          	jalr	702(ra) # 6b6 <wait>
 400:	4501                	li	a0,0
 402:	00000097          	auipc	ra,0x0
 406:	2b4080e7          	jalr	692(ra) # 6b6 <wait>
  }
  printf("test1 OK\n");
 40a:	00001517          	auipc	a0,0x1
 40e:	8ee50513          	addi	a0,a0,-1810 # cf8 <malloc+0x1f4>
 412:	00000097          	auipc	ra,0x0
 416:	634080e7          	jalr	1588(ra) # a46 <printf>
}
 41a:	70a2                	ld	ra,40(sp)
 41c:	7402                	ld	s0,32(sp)
 41e:	64e2                	ld	s1,24(sp)
 420:	6145                	addi	sp,sp,48
 422:	8082                	ret
      printf("fork failed");
 424:	00001517          	auipc	a0,0x1
 428:	88450513          	addi	a0,a0,-1916 # ca8 <malloc+0x1a4>
 42c:	00000097          	auipc	ra,0x0
 430:	61a080e7          	jalr	1562(ra) # a46 <printf>
      exit(-1);
 434:	557d                	li	a0,-1
 436:	00000097          	auipc	ra,0x0
 43a:	278080e7          	jalr	632(ra) # 6ae <exit>
    if(pid == 0){
 43e:	06400493          	li	s1,100
          readfile(file, BIG*BSIZE, BSIZE);
 442:	40000613          	li	a2,1024
 446:	65e5                	lui	a1,0x19
 448:	fd840513          	addi	a0,s0,-40
 44c:	00000097          	auipc	ra,0x0
 450:	c70080e7          	jalr	-912(ra) # bc <readfile>
        for (i = 0; i < N; i++) {
 454:	34fd                	addiw	s1,s1,-1
 456:	f4f5                	bnez	s1,442 <test1+0xc8>
        unlink(file);
 458:	fd840513          	addi	a0,s0,-40
 45c:	00000097          	auipc	ra,0x0
 460:	2a2080e7          	jalr	674(ra) # 6fe <unlink>
        exit(0);
 464:	4501                	li	a0,0
 466:	00000097          	auipc	ra,0x0
 46a:	248080e7          	jalr	584(ra) # 6ae <exit>
 46e:	06400493          	li	s1,100
          readfile(file, 1, BSIZE);
 472:	40000613          	li	a2,1024
 476:	4585                	li	a1,1
 478:	fd840513          	addi	a0,s0,-40
 47c:	00000097          	auipc	ra,0x0
 480:	c40080e7          	jalr	-960(ra) # bc <readfile>
        for (i = 0; i < N; i++) {
 484:	34fd                	addiw	s1,s1,-1
 486:	f4f5                	bnez	s1,472 <test1+0xf8>
        unlink(file);
 488:	fd840513          	addi	a0,s0,-40
 48c:	00000097          	auipc	ra,0x0
 490:	272080e7          	jalr	626(ra) # 6fe <unlink>
      exit(0);
 494:	4501                	li	a0,0
 496:	00000097          	auipc	ra,0x0
 49a:	218080e7          	jalr	536(ra) # 6ae <exit>

000000000000049e <main>:
{
 49e:	1141                	addi	sp,sp,-16
 4a0:	e406                	sd	ra,8(sp)
 4a2:	e022                	sd	s0,0(sp)
 4a4:	0800                	addi	s0,sp,16
  test0();
 4a6:	00000097          	auipc	ra,0x0
 4aa:	cfc080e7          	jalr	-772(ra) # 1a2 <test0>
  test1();
 4ae:	00000097          	auipc	ra,0x0
 4b2:	ecc080e7          	jalr	-308(ra) # 37a <test1>
  exit(0);
 4b6:	4501                	li	a0,0
 4b8:	00000097          	auipc	ra,0x0
 4bc:	1f6080e7          	jalr	502(ra) # 6ae <exit>

00000000000004c0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 4c0:	1141                	addi	sp,sp,-16
 4c2:	e422                	sd	s0,8(sp)
 4c4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 4c6:	87aa                	mv	a5,a0
 4c8:	0585                	addi	a1,a1,1
 4ca:	0785                	addi	a5,a5,1
 4cc:	fff5c703          	lbu	a4,-1(a1) # 18fff <__global_pointer$+0x17ade>
 4d0:	fee78fa3          	sb	a4,-1(a5)
 4d4:	fb75                	bnez	a4,4c8 <strcpy+0x8>
    ;
  return os;
}
 4d6:	6422                	ld	s0,8(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret

00000000000004dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4dc:	1141                	addi	sp,sp,-16
 4de:	e422                	sd	s0,8(sp)
 4e0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4e2:	00054783          	lbu	a5,0(a0)
 4e6:	cb91                	beqz	a5,4fa <strcmp+0x1e>
 4e8:	0005c703          	lbu	a4,0(a1)
 4ec:	00f71763          	bne	a4,a5,4fa <strcmp+0x1e>
    p++, q++;
 4f0:	0505                	addi	a0,a0,1
 4f2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4f4:	00054783          	lbu	a5,0(a0)
 4f8:	fbe5                	bnez	a5,4e8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4fa:	0005c503          	lbu	a0,0(a1)
}
 4fe:	40a7853b          	subw	a0,a5,a0
 502:	6422                	ld	s0,8(sp)
 504:	0141                	addi	sp,sp,16
 506:	8082                	ret

0000000000000508 <strlen>:

uint
strlen(const char *s)
{
 508:	1141                	addi	sp,sp,-16
 50a:	e422                	sd	s0,8(sp)
 50c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 50e:	00054783          	lbu	a5,0(a0)
 512:	cf91                	beqz	a5,52e <strlen+0x26>
 514:	0505                	addi	a0,a0,1
 516:	87aa                	mv	a5,a0
 518:	4685                	li	a3,1
 51a:	9e89                	subw	a3,a3,a0
 51c:	00f6853b          	addw	a0,a3,a5
 520:	0785                	addi	a5,a5,1
 522:	fff7c703          	lbu	a4,-1(a5)
 526:	fb7d                	bnez	a4,51c <strlen+0x14>
    ;
  return n;
}
 528:	6422                	ld	s0,8(sp)
 52a:	0141                	addi	sp,sp,16
 52c:	8082                	ret
  for(n = 0; s[n]; n++)
 52e:	4501                	li	a0,0
 530:	bfe5                	j	528 <strlen+0x20>

0000000000000532 <memset>:

void*
memset(void *dst, int c, uint n)
{
 532:	1141                	addi	sp,sp,-16
 534:	e422                	sd	s0,8(sp)
 536:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 538:	ca19                	beqz	a2,54e <memset+0x1c>
 53a:	87aa                	mv	a5,a0
 53c:	1602                	slli	a2,a2,0x20
 53e:	9201                	srli	a2,a2,0x20
 540:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 544:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 548:	0785                	addi	a5,a5,1
 54a:	fee79de3          	bne	a5,a4,544 <memset+0x12>
  }
  return dst;
}
 54e:	6422                	ld	s0,8(sp)
 550:	0141                	addi	sp,sp,16
 552:	8082                	ret

0000000000000554 <strchr>:

char*
strchr(const char *s, char c)
{
 554:	1141                	addi	sp,sp,-16
 556:	e422                	sd	s0,8(sp)
 558:	0800                	addi	s0,sp,16
  for(; *s; s++)
 55a:	00054783          	lbu	a5,0(a0)
 55e:	cb99                	beqz	a5,574 <strchr+0x20>
    if(*s == c)
 560:	00f58763          	beq	a1,a5,56e <strchr+0x1a>
  for(; *s; s++)
 564:	0505                	addi	a0,a0,1
 566:	00054783          	lbu	a5,0(a0)
 56a:	fbfd                	bnez	a5,560 <strchr+0xc>
      return (char*)s;
  return 0;
 56c:	4501                	li	a0,0
}
 56e:	6422                	ld	s0,8(sp)
 570:	0141                	addi	sp,sp,16
 572:	8082                	ret
  return 0;
 574:	4501                	li	a0,0
 576:	bfe5                	j	56e <strchr+0x1a>

0000000000000578 <gets>:

char*
gets(char *buf, int max)
{
 578:	711d                	addi	sp,sp,-96
 57a:	ec86                	sd	ra,88(sp)
 57c:	e8a2                	sd	s0,80(sp)
 57e:	e4a6                	sd	s1,72(sp)
 580:	e0ca                	sd	s2,64(sp)
 582:	fc4e                	sd	s3,56(sp)
 584:	f852                	sd	s4,48(sp)
 586:	f456                	sd	s5,40(sp)
 588:	f05a                	sd	s6,32(sp)
 58a:	ec5e                	sd	s7,24(sp)
 58c:	1080                	addi	s0,sp,96
 58e:	8baa                	mv	s7,a0
 590:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 592:	892a                	mv	s2,a0
 594:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 596:	4aa9                	li	s5,10
 598:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 59a:	89a6                	mv	s3,s1
 59c:	2485                	addiw	s1,s1,1
 59e:	0344d863          	bge	s1,s4,5ce <gets+0x56>
    cc = read(0, &c, 1);
 5a2:	4605                	li	a2,1
 5a4:	faf40593          	addi	a1,s0,-81
 5a8:	4501                	li	a0,0
 5aa:	00000097          	auipc	ra,0x0
 5ae:	11c080e7          	jalr	284(ra) # 6c6 <read>
    if(cc < 1)
 5b2:	00a05e63          	blez	a0,5ce <gets+0x56>
    buf[i++] = c;
 5b6:	faf44783          	lbu	a5,-81(s0)
 5ba:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 5be:	01578763          	beq	a5,s5,5cc <gets+0x54>
 5c2:	0905                	addi	s2,s2,1
 5c4:	fd679be3          	bne	a5,s6,59a <gets+0x22>
  for(i=0; i+1 < max; ){
 5c8:	89a6                	mv	s3,s1
 5ca:	a011                	j	5ce <gets+0x56>
 5cc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 5ce:	99de                	add	s3,s3,s7
 5d0:	00098023          	sb	zero,0(s3)
  return buf;
}
 5d4:	855e                	mv	a0,s7
 5d6:	60e6                	ld	ra,88(sp)
 5d8:	6446                	ld	s0,80(sp)
 5da:	64a6                	ld	s1,72(sp)
 5dc:	6906                	ld	s2,64(sp)
 5de:	79e2                	ld	s3,56(sp)
 5e0:	7a42                	ld	s4,48(sp)
 5e2:	7aa2                	ld	s5,40(sp)
 5e4:	7b02                	ld	s6,32(sp)
 5e6:	6be2                	ld	s7,24(sp)
 5e8:	6125                	addi	sp,sp,96
 5ea:	8082                	ret

00000000000005ec <stat>:

int
stat(const char *n, struct stat *st)
{
 5ec:	1101                	addi	sp,sp,-32
 5ee:	ec06                	sd	ra,24(sp)
 5f0:	e822                	sd	s0,16(sp)
 5f2:	e426                	sd	s1,8(sp)
 5f4:	e04a                	sd	s2,0(sp)
 5f6:	1000                	addi	s0,sp,32
 5f8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5fa:	4581                	li	a1,0
 5fc:	00000097          	auipc	ra,0x0
 600:	0f2080e7          	jalr	242(ra) # 6ee <open>
  if(fd < 0)
 604:	02054563          	bltz	a0,62e <stat+0x42>
 608:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 60a:	85ca                	mv	a1,s2
 60c:	00000097          	auipc	ra,0x0
 610:	0fa080e7          	jalr	250(ra) # 706 <fstat>
 614:	892a                	mv	s2,a0
  close(fd);
 616:	8526                	mv	a0,s1
 618:	00000097          	auipc	ra,0x0
 61c:	0be080e7          	jalr	190(ra) # 6d6 <close>
  return r;
}
 620:	854a                	mv	a0,s2
 622:	60e2                	ld	ra,24(sp)
 624:	6442                	ld	s0,16(sp)
 626:	64a2                	ld	s1,8(sp)
 628:	6902                	ld	s2,0(sp)
 62a:	6105                	addi	sp,sp,32
 62c:	8082                	ret
    return -1;
 62e:	597d                	li	s2,-1
 630:	bfc5                	j	620 <stat+0x34>

0000000000000632 <atoi>:

int
atoi(const char *s)
{
 632:	1141                	addi	sp,sp,-16
 634:	e422                	sd	s0,8(sp)
 636:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 638:	00054603          	lbu	a2,0(a0)
 63c:	fd06079b          	addiw	a5,a2,-48
 640:	0ff7f793          	andi	a5,a5,255
 644:	4725                	li	a4,9
 646:	02f76963          	bltu	a4,a5,678 <atoi+0x46>
 64a:	86aa                	mv	a3,a0
  n = 0;
 64c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 64e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 650:	0685                	addi	a3,a3,1
 652:	0025179b          	slliw	a5,a0,0x2
 656:	9fa9                	addw	a5,a5,a0
 658:	0017979b          	slliw	a5,a5,0x1
 65c:	9fb1                	addw	a5,a5,a2
 65e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 662:	0006c603          	lbu	a2,0(a3)
 666:	fd06071b          	addiw	a4,a2,-48
 66a:	0ff77713          	andi	a4,a4,255
 66e:	fee5f1e3          	bgeu	a1,a4,650 <atoi+0x1e>
  return n;
}
 672:	6422                	ld	s0,8(sp)
 674:	0141                	addi	sp,sp,16
 676:	8082                	ret
  n = 0;
 678:	4501                	li	a0,0
 67a:	bfe5                	j	672 <atoi+0x40>

000000000000067c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 67c:	1141                	addi	sp,sp,-16
 67e:	e422                	sd	s0,8(sp)
 680:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 682:	00c05f63          	blez	a2,6a0 <memmove+0x24>
 686:	1602                	slli	a2,a2,0x20
 688:	9201                	srli	a2,a2,0x20
 68a:	00c506b3          	add	a3,a0,a2
  dst = vdst;
 68e:	87aa                	mv	a5,a0
    *dst++ = *src++;
 690:	0585                	addi	a1,a1,1
 692:	0785                	addi	a5,a5,1
 694:	fff5c703          	lbu	a4,-1(a1)
 698:	fee78fa3          	sb	a4,-1(a5)
  while(n-- > 0)
 69c:	fed79ae3          	bne	a5,a3,690 <memmove+0x14>
  return vdst;
}
 6a0:	6422                	ld	s0,8(sp)
 6a2:	0141                	addi	sp,sp,16
 6a4:	8082                	ret

00000000000006a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6a6:	4885                	li	a7,1
 ecall
 6a8:	00000073          	ecall
 ret
 6ac:	8082                	ret

00000000000006ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 6ae:	4889                	li	a7,2
 ecall
 6b0:	00000073          	ecall
 ret
 6b4:	8082                	ret

00000000000006b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 6b6:	488d                	li	a7,3
 ecall
 6b8:	00000073          	ecall
 ret
 6bc:	8082                	ret

00000000000006be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6be:	4891                	li	a7,4
 ecall
 6c0:	00000073          	ecall
 ret
 6c4:	8082                	ret

00000000000006c6 <read>:
.global read
read:
 li a7, SYS_read
 6c6:	4895                	li	a7,5
 ecall
 6c8:	00000073          	ecall
 ret
 6cc:	8082                	ret

00000000000006ce <write>:
.global write
write:
 li a7, SYS_write
 6ce:	48c1                	li	a7,16
 ecall
 6d0:	00000073          	ecall
 ret
 6d4:	8082                	ret

00000000000006d6 <close>:
.global close
close:
 li a7, SYS_close
 6d6:	48d5                	li	a7,21
 ecall
 6d8:	00000073          	ecall
 ret
 6dc:	8082                	ret

00000000000006de <kill>:
.global kill
kill:
 li a7, SYS_kill
 6de:	4899                	li	a7,6
 ecall
 6e0:	00000073          	ecall
 ret
 6e4:	8082                	ret

00000000000006e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 6e6:	489d                	li	a7,7
 ecall
 6e8:	00000073          	ecall
 ret
 6ec:	8082                	ret

00000000000006ee <open>:
.global open
open:
 li a7, SYS_open
 6ee:	48bd                	li	a7,15
 ecall
 6f0:	00000073          	ecall
 ret
 6f4:	8082                	ret

00000000000006f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6f6:	48c5                	li	a7,17
 ecall
 6f8:	00000073          	ecall
 ret
 6fc:	8082                	ret

00000000000006fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 6fe:	48c9                	li	a7,18
 ecall
 700:	00000073          	ecall
 ret
 704:	8082                	ret

0000000000000706 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 706:	48a1                	li	a7,8
 ecall
 708:	00000073          	ecall
 ret
 70c:	8082                	ret

000000000000070e <link>:
.global link
link:
 li a7, SYS_link
 70e:	48cd                	li	a7,19
 ecall
 710:	00000073          	ecall
 ret
 714:	8082                	ret

0000000000000716 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 716:	48d1                	li	a7,20
 ecall
 718:	00000073          	ecall
 ret
 71c:	8082                	ret

000000000000071e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 71e:	48a5                	li	a7,9
 ecall
 720:	00000073          	ecall
 ret
 724:	8082                	ret

0000000000000726 <dup>:
.global dup
dup:
 li a7, SYS_dup
 726:	48a9                	li	a7,10
 ecall
 728:	00000073          	ecall
 ret
 72c:	8082                	ret

000000000000072e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 72e:	48ad                	li	a7,11
 ecall
 730:	00000073          	ecall
 ret
 734:	8082                	ret

0000000000000736 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 736:	48b1                	li	a7,12
 ecall
 738:	00000073          	ecall
 ret
 73c:	8082                	ret

000000000000073e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 73e:	48b5                	li	a7,13
 ecall
 740:	00000073          	ecall
 ret
 744:	8082                	ret

0000000000000746 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 746:	48b9                	li	a7,14
 ecall
 748:	00000073          	ecall
 ret
 74c:	8082                	ret

000000000000074e <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 74e:	48d9                	li	a7,22
 ecall
 750:	00000073          	ecall
 ret
 754:	8082                	ret

0000000000000756 <crash>:
.global crash
crash:
 li a7, SYS_crash
 756:	48dd                	li	a7,23
 ecall
 758:	00000073          	ecall
 ret
 75c:	8082                	ret

000000000000075e <mount>:
.global mount
mount:
 li a7, SYS_mount
 75e:	48e1                	li	a7,24
 ecall
 760:	00000073          	ecall
 ret
 764:	8082                	ret

0000000000000766 <umount>:
.global umount
umount:
 li a7, SYS_umount
 766:	48e5                	li	a7,25
 ecall
 768:	00000073          	ecall
 ret
 76c:	8082                	ret

000000000000076e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 76e:	1101                	addi	sp,sp,-32
 770:	ec06                	sd	ra,24(sp)
 772:	e822                	sd	s0,16(sp)
 774:	1000                	addi	s0,sp,32
 776:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 77a:	4605                	li	a2,1
 77c:	fef40593          	addi	a1,s0,-17
 780:	00000097          	auipc	ra,0x0
 784:	f4e080e7          	jalr	-178(ra) # 6ce <write>
}
 788:	60e2                	ld	ra,24(sp)
 78a:	6442                	ld	s0,16(sp)
 78c:	6105                	addi	sp,sp,32
 78e:	8082                	ret

0000000000000790 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 790:	7139                	addi	sp,sp,-64
 792:	fc06                	sd	ra,56(sp)
 794:	f822                	sd	s0,48(sp)
 796:	f426                	sd	s1,40(sp)
 798:	f04a                	sd	s2,32(sp)
 79a:	ec4e                	sd	s3,24(sp)
 79c:	0080                	addi	s0,sp,64
 79e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7a0:	c299                	beqz	a3,7a6 <printint+0x16>
 7a2:	0805c863          	bltz	a1,832 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7a6:	2581                	sext.w	a1,a1
  neg = 0;
 7a8:	4881                	li	a7,0
 7aa:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7ae:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7b0:	2601                	sext.w	a2,a2
 7b2:	00000517          	auipc	a0,0x0
 7b6:	55e50513          	addi	a0,a0,1374 # d10 <digits>
 7ba:	883a                	mv	a6,a4
 7bc:	2705                	addiw	a4,a4,1
 7be:	02c5f7bb          	remuw	a5,a1,a2
 7c2:	1782                	slli	a5,a5,0x20
 7c4:	9381                	srli	a5,a5,0x20
 7c6:	97aa                	add	a5,a5,a0
 7c8:	0007c783          	lbu	a5,0(a5)
 7cc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 7d0:	0005879b          	sext.w	a5,a1
 7d4:	02c5d5bb          	divuw	a1,a1,a2
 7d8:	0685                	addi	a3,a3,1
 7da:	fec7f0e3          	bgeu	a5,a2,7ba <printint+0x2a>
  if(neg)
 7de:	00088b63          	beqz	a7,7f4 <printint+0x64>
    buf[i++] = '-';
 7e2:	fd040793          	addi	a5,s0,-48
 7e6:	973e                	add	a4,a4,a5
 7e8:	02d00793          	li	a5,45
 7ec:	fef70823          	sb	a5,-16(a4)
 7f0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 7f4:	02e05863          	blez	a4,824 <printint+0x94>
 7f8:	fc040793          	addi	a5,s0,-64
 7fc:	00e78933          	add	s2,a5,a4
 800:	fff78993          	addi	s3,a5,-1
 804:	99ba                	add	s3,s3,a4
 806:	377d                	addiw	a4,a4,-1
 808:	1702                	slli	a4,a4,0x20
 80a:	9301                	srli	a4,a4,0x20
 80c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 810:	fff94583          	lbu	a1,-1(s2)
 814:	8526                	mv	a0,s1
 816:	00000097          	auipc	ra,0x0
 81a:	f58080e7          	jalr	-168(ra) # 76e <putc>
  while(--i >= 0)
 81e:	197d                	addi	s2,s2,-1
 820:	ff3918e3          	bne	s2,s3,810 <printint+0x80>
}
 824:	70e2                	ld	ra,56(sp)
 826:	7442                	ld	s0,48(sp)
 828:	74a2                	ld	s1,40(sp)
 82a:	7902                	ld	s2,32(sp)
 82c:	69e2                	ld	s3,24(sp)
 82e:	6121                	addi	sp,sp,64
 830:	8082                	ret
    x = -xx;
 832:	40b005bb          	negw	a1,a1
    neg = 1;
 836:	4885                	li	a7,1
    x = -xx;
 838:	bf8d                	j	7aa <printint+0x1a>

000000000000083a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 83a:	7119                	addi	sp,sp,-128
 83c:	fc86                	sd	ra,120(sp)
 83e:	f8a2                	sd	s0,112(sp)
 840:	f4a6                	sd	s1,104(sp)
 842:	f0ca                	sd	s2,96(sp)
 844:	ecce                	sd	s3,88(sp)
 846:	e8d2                	sd	s4,80(sp)
 848:	e4d6                	sd	s5,72(sp)
 84a:	e0da                	sd	s6,64(sp)
 84c:	fc5e                	sd	s7,56(sp)
 84e:	f862                	sd	s8,48(sp)
 850:	f466                	sd	s9,40(sp)
 852:	f06a                	sd	s10,32(sp)
 854:	ec6e                	sd	s11,24(sp)
 856:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 858:	0005c903          	lbu	s2,0(a1)
 85c:	18090f63          	beqz	s2,9fa <vprintf+0x1c0>
 860:	8aaa                	mv	s5,a0
 862:	8b32                	mv	s6,a2
 864:	00158493          	addi	s1,a1,1
  state = 0;
 868:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 86a:	02500a13          	li	s4,37
      if(c == 'd'){
 86e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 872:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 876:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 87a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 87e:	00000b97          	auipc	s7,0x0
 882:	492b8b93          	addi	s7,s7,1170 # d10 <digits>
 886:	a839                	j	8a4 <vprintf+0x6a>
        putc(fd, c);
 888:	85ca                	mv	a1,s2
 88a:	8556                	mv	a0,s5
 88c:	00000097          	auipc	ra,0x0
 890:	ee2080e7          	jalr	-286(ra) # 76e <putc>
 894:	a019                	j	89a <vprintf+0x60>
    } else if(state == '%'){
 896:	01498f63          	beq	s3,s4,8b4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 89a:	0485                	addi	s1,s1,1
 89c:	fff4c903          	lbu	s2,-1(s1)
 8a0:	14090d63          	beqz	s2,9fa <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 8a4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 8a8:	fe0997e3          	bnez	s3,896 <vprintf+0x5c>
      if(c == '%'){
 8ac:	fd479ee3          	bne	a5,s4,888 <vprintf+0x4e>
        state = '%';
 8b0:	89be                	mv	s3,a5
 8b2:	b7e5                	j	89a <vprintf+0x60>
      if(c == 'd'){
 8b4:	05878063          	beq	a5,s8,8f4 <vprintf+0xba>
      } else if(c == 'l') {
 8b8:	05978c63          	beq	a5,s9,910 <vprintf+0xd6>
      } else if(c == 'x') {
 8bc:	07a78863          	beq	a5,s10,92c <vprintf+0xf2>
      } else if(c == 'p') {
 8c0:	09b78463          	beq	a5,s11,948 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 8c4:	07300713          	li	a4,115
 8c8:	0ce78663          	beq	a5,a4,994 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 8cc:	06300713          	li	a4,99
 8d0:	0ee78e63          	beq	a5,a4,9cc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 8d4:	11478863          	beq	a5,s4,9e4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8d8:	85d2                	mv	a1,s4
 8da:	8556                	mv	a0,s5
 8dc:	00000097          	auipc	ra,0x0
 8e0:	e92080e7          	jalr	-366(ra) # 76e <putc>
        putc(fd, c);
 8e4:	85ca                	mv	a1,s2
 8e6:	8556                	mv	a0,s5
 8e8:	00000097          	auipc	ra,0x0
 8ec:	e86080e7          	jalr	-378(ra) # 76e <putc>
      }
      state = 0;
 8f0:	4981                	li	s3,0
 8f2:	b765                	j	89a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 8f4:	008b0913          	addi	s2,s6,8
 8f8:	4685                	li	a3,1
 8fa:	4629                	li	a2,10
 8fc:	000b2583          	lw	a1,0(s6)
 900:	8556                	mv	a0,s5
 902:	00000097          	auipc	ra,0x0
 906:	e8e080e7          	jalr	-370(ra) # 790 <printint>
 90a:	8b4a                	mv	s6,s2
      state = 0;
 90c:	4981                	li	s3,0
 90e:	b771                	j	89a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 910:	008b0913          	addi	s2,s6,8
 914:	4681                	li	a3,0
 916:	4629                	li	a2,10
 918:	000b2583          	lw	a1,0(s6)
 91c:	8556                	mv	a0,s5
 91e:	00000097          	auipc	ra,0x0
 922:	e72080e7          	jalr	-398(ra) # 790 <printint>
 926:	8b4a                	mv	s6,s2
      state = 0;
 928:	4981                	li	s3,0
 92a:	bf85                	j	89a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 92c:	008b0913          	addi	s2,s6,8
 930:	4681                	li	a3,0
 932:	4641                	li	a2,16
 934:	000b2583          	lw	a1,0(s6)
 938:	8556                	mv	a0,s5
 93a:	00000097          	auipc	ra,0x0
 93e:	e56080e7          	jalr	-426(ra) # 790 <printint>
 942:	8b4a                	mv	s6,s2
      state = 0;
 944:	4981                	li	s3,0
 946:	bf91                	j	89a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 948:	008b0793          	addi	a5,s6,8
 94c:	f8f43423          	sd	a5,-120(s0)
 950:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 954:	03000593          	li	a1,48
 958:	8556                	mv	a0,s5
 95a:	00000097          	auipc	ra,0x0
 95e:	e14080e7          	jalr	-492(ra) # 76e <putc>
  putc(fd, 'x');
 962:	85ea                	mv	a1,s10
 964:	8556                	mv	a0,s5
 966:	00000097          	auipc	ra,0x0
 96a:	e08080e7          	jalr	-504(ra) # 76e <putc>
 96e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 970:	03c9d793          	srli	a5,s3,0x3c
 974:	97de                	add	a5,a5,s7
 976:	0007c583          	lbu	a1,0(a5)
 97a:	8556                	mv	a0,s5
 97c:	00000097          	auipc	ra,0x0
 980:	df2080e7          	jalr	-526(ra) # 76e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 984:	0992                	slli	s3,s3,0x4
 986:	397d                	addiw	s2,s2,-1
 988:	fe0914e3          	bnez	s2,970 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 98c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 990:	4981                	li	s3,0
 992:	b721                	j	89a <vprintf+0x60>
        s = va_arg(ap, char*);
 994:	008b0993          	addi	s3,s6,8
 998:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 99c:	02090163          	beqz	s2,9be <vprintf+0x184>
        while(*s != 0){
 9a0:	00094583          	lbu	a1,0(s2)
 9a4:	c9a1                	beqz	a1,9f4 <vprintf+0x1ba>
          putc(fd, *s);
 9a6:	8556                	mv	a0,s5
 9a8:	00000097          	auipc	ra,0x0
 9ac:	dc6080e7          	jalr	-570(ra) # 76e <putc>
          s++;
 9b0:	0905                	addi	s2,s2,1
        while(*s != 0){
 9b2:	00094583          	lbu	a1,0(s2)
 9b6:	f9e5                	bnez	a1,9a6 <vprintf+0x16c>
        s = va_arg(ap, char*);
 9b8:	8b4e                	mv	s6,s3
      state = 0;
 9ba:	4981                	li	s3,0
 9bc:	bdf9                	j	89a <vprintf+0x60>
          s = "(null)";
 9be:	00000917          	auipc	s2,0x0
 9c2:	34a90913          	addi	s2,s2,842 # d08 <malloc+0x204>
        while(*s != 0){
 9c6:	02800593          	li	a1,40
 9ca:	bff1                	j	9a6 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 9cc:	008b0913          	addi	s2,s6,8
 9d0:	000b4583          	lbu	a1,0(s6)
 9d4:	8556                	mv	a0,s5
 9d6:	00000097          	auipc	ra,0x0
 9da:	d98080e7          	jalr	-616(ra) # 76e <putc>
 9de:	8b4a                	mv	s6,s2
      state = 0;
 9e0:	4981                	li	s3,0
 9e2:	bd65                	j	89a <vprintf+0x60>
        putc(fd, c);
 9e4:	85d2                	mv	a1,s4
 9e6:	8556                	mv	a0,s5
 9e8:	00000097          	auipc	ra,0x0
 9ec:	d86080e7          	jalr	-634(ra) # 76e <putc>
      state = 0;
 9f0:	4981                	li	s3,0
 9f2:	b565                	j	89a <vprintf+0x60>
        s = va_arg(ap, char*);
 9f4:	8b4e                	mv	s6,s3
      state = 0;
 9f6:	4981                	li	s3,0
 9f8:	b54d                	j	89a <vprintf+0x60>
    }
  }
}
 9fa:	70e6                	ld	ra,120(sp)
 9fc:	7446                	ld	s0,112(sp)
 9fe:	74a6                	ld	s1,104(sp)
 a00:	7906                	ld	s2,96(sp)
 a02:	69e6                	ld	s3,88(sp)
 a04:	6a46                	ld	s4,80(sp)
 a06:	6aa6                	ld	s5,72(sp)
 a08:	6b06                	ld	s6,64(sp)
 a0a:	7be2                	ld	s7,56(sp)
 a0c:	7c42                	ld	s8,48(sp)
 a0e:	7ca2                	ld	s9,40(sp)
 a10:	7d02                	ld	s10,32(sp)
 a12:	6de2                	ld	s11,24(sp)
 a14:	6109                	addi	sp,sp,128
 a16:	8082                	ret

0000000000000a18 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a18:	715d                	addi	sp,sp,-80
 a1a:	ec06                	sd	ra,24(sp)
 a1c:	e822                	sd	s0,16(sp)
 a1e:	1000                	addi	s0,sp,32
 a20:	e010                	sd	a2,0(s0)
 a22:	e414                	sd	a3,8(s0)
 a24:	e818                	sd	a4,16(s0)
 a26:	ec1c                	sd	a5,24(s0)
 a28:	03043023          	sd	a6,32(s0)
 a2c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a30:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a34:	8622                	mv	a2,s0
 a36:	00000097          	auipc	ra,0x0
 a3a:	e04080e7          	jalr	-508(ra) # 83a <vprintf>
}
 a3e:	60e2                	ld	ra,24(sp)
 a40:	6442                	ld	s0,16(sp)
 a42:	6161                	addi	sp,sp,80
 a44:	8082                	ret

0000000000000a46 <printf>:

void
printf(const char *fmt, ...)
{
 a46:	711d                	addi	sp,sp,-96
 a48:	ec06                	sd	ra,24(sp)
 a4a:	e822                	sd	s0,16(sp)
 a4c:	1000                	addi	s0,sp,32
 a4e:	e40c                	sd	a1,8(s0)
 a50:	e810                	sd	a2,16(s0)
 a52:	ec14                	sd	a3,24(s0)
 a54:	f018                	sd	a4,32(s0)
 a56:	f41c                	sd	a5,40(s0)
 a58:	03043823          	sd	a6,48(s0)
 a5c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a60:	00840613          	addi	a2,s0,8
 a64:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a68:	85aa                	mv	a1,a0
 a6a:	4505                	li	a0,1
 a6c:	00000097          	auipc	ra,0x0
 a70:	dce080e7          	jalr	-562(ra) # 83a <vprintf>
}
 a74:	60e2                	ld	ra,24(sp)
 a76:	6442                	ld	s0,16(sp)
 a78:	6125                	addi	sp,sp,96
 a7a:	8082                	ret

0000000000000a7c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a7c:	1141                	addi	sp,sp,-16
 a7e:	e422                	sd	s0,8(sp)
 a80:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a82:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a86:	00000797          	auipc	a5,0x0
 a8a:	2a27b783          	ld	a5,674(a5) # d28 <freep>
 a8e:	a805                	j	abe <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a90:	4618                	lw	a4,8(a2)
 a92:	9db9                	addw	a1,a1,a4
 a94:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a98:	6398                	ld	a4,0(a5)
 a9a:	6318                	ld	a4,0(a4)
 a9c:	fee53823          	sd	a4,-16(a0)
 aa0:	a091                	j	ae4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 aa2:	ff852703          	lw	a4,-8(a0)
 aa6:	9e39                	addw	a2,a2,a4
 aa8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 aaa:	ff053703          	ld	a4,-16(a0)
 aae:	e398                	sd	a4,0(a5)
 ab0:	a099                	j	af6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ab2:	6398                	ld	a4,0(a5)
 ab4:	00e7e463          	bltu	a5,a4,abc <free+0x40>
 ab8:	00e6ea63          	bltu	a3,a4,acc <free+0x50>
{
 abc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 abe:	fed7fae3          	bgeu	a5,a3,ab2 <free+0x36>
 ac2:	6398                	ld	a4,0(a5)
 ac4:	00e6e463          	bltu	a3,a4,acc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ac8:	fee7eae3          	bltu	a5,a4,abc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 acc:	ff852583          	lw	a1,-8(a0)
 ad0:	6390                	ld	a2,0(a5)
 ad2:	02059713          	slli	a4,a1,0x20
 ad6:	9301                	srli	a4,a4,0x20
 ad8:	0712                	slli	a4,a4,0x4
 ada:	9736                	add	a4,a4,a3
 adc:	fae60ae3          	beq	a2,a4,a90 <free+0x14>
    bp->s.ptr = p->s.ptr;
 ae0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 ae4:	4790                	lw	a2,8(a5)
 ae6:	02061713          	slli	a4,a2,0x20
 aea:	9301                	srli	a4,a4,0x20
 aec:	0712                	slli	a4,a4,0x4
 aee:	973e                	add	a4,a4,a5
 af0:	fae689e3          	beq	a3,a4,aa2 <free+0x26>
  } else
    p->s.ptr = bp;
 af4:	e394                	sd	a3,0(a5)
  freep = p;
 af6:	00000717          	auipc	a4,0x0
 afa:	22f73923          	sd	a5,562(a4) # d28 <freep>
}
 afe:	6422                	ld	s0,8(sp)
 b00:	0141                	addi	sp,sp,16
 b02:	8082                	ret

0000000000000b04 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b04:	7139                	addi	sp,sp,-64
 b06:	fc06                	sd	ra,56(sp)
 b08:	f822                	sd	s0,48(sp)
 b0a:	f426                	sd	s1,40(sp)
 b0c:	f04a                	sd	s2,32(sp)
 b0e:	ec4e                	sd	s3,24(sp)
 b10:	e852                	sd	s4,16(sp)
 b12:	e456                	sd	s5,8(sp)
 b14:	e05a                	sd	s6,0(sp)
 b16:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b18:	02051493          	slli	s1,a0,0x20
 b1c:	9081                	srli	s1,s1,0x20
 b1e:	04bd                	addi	s1,s1,15
 b20:	8091                	srli	s1,s1,0x4
 b22:	0014899b          	addiw	s3,s1,1
 b26:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b28:	00000517          	auipc	a0,0x0
 b2c:	20053503          	ld	a0,512(a0) # d28 <freep>
 b30:	c515                	beqz	a0,b5c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b32:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b34:	4798                	lw	a4,8(a5)
 b36:	02977f63          	bgeu	a4,s1,b74 <malloc+0x70>
 b3a:	8a4e                	mv	s4,s3
 b3c:	0009871b          	sext.w	a4,s3
 b40:	6685                	lui	a3,0x1
 b42:	00d77363          	bgeu	a4,a3,b48 <malloc+0x44>
 b46:	6a05                	lui	s4,0x1
 b48:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b4c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b50:	00000917          	auipc	s2,0x0
 b54:	1d890913          	addi	s2,s2,472 # d28 <freep>
  if(p == (char*)-1)
 b58:	5afd                	li	s5,-1
 b5a:	a88d                	j	bcc <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 b5c:	00000797          	auipc	a5,0x0
 b60:	1d478793          	addi	a5,a5,468 # d30 <base>
 b64:	00000717          	auipc	a4,0x0
 b68:	1cf73223          	sd	a5,452(a4) # d28 <freep>
 b6c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b6e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b72:	b7e1                	j	b3a <malloc+0x36>
      if(p->s.size == nunits)
 b74:	02e48b63          	beq	s1,a4,baa <malloc+0xa6>
        p->s.size -= nunits;
 b78:	4137073b          	subw	a4,a4,s3
 b7c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b7e:	1702                	slli	a4,a4,0x20
 b80:	9301                	srli	a4,a4,0x20
 b82:	0712                	slli	a4,a4,0x4
 b84:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b86:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b8a:	00000717          	auipc	a4,0x0
 b8e:	18a73f23          	sd	a0,414(a4) # d28 <freep>
      return (void*)(p + 1);
 b92:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b96:	70e2                	ld	ra,56(sp)
 b98:	7442                	ld	s0,48(sp)
 b9a:	74a2                	ld	s1,40(sp)
 b9c:	7902                	ld	s2,32(sp)
 b9e:	69e2                	ld	s3,24(sp)
 ba0:	6a42                	ld	s4,16(sp)
 ba2:	6aa2                	ld	s5,8(sp)
 ba4:	6b02                	ld	s6,0(sp)
 ba6:	6121                	addi	sp,sp,64
 ba8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 baa:	6398                	ld	a4,0(a5)
 bac:	e118                	sd	a4,0(a0)
 bae:	bff1                	j	b8a <malloc+0x86>
  hp->s.size = nu;
 bb0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 bb4:	0541                	addi	a0,a0,16
 bb6:	00000097          	auipc	ra,0x0
 bba:	ec6080e7          	jalr	-314(ra) # a7c <free>
  return freep;
 bbe:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 bc2:	d971                	beqz	a0,b96 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bc4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bc6:	4798                	lw	a4,8(a5)
 bc8:	fa9776e3          	bgeu	a4,s1,b74 <malloc+0x70>
    if(p == freep)
 bcc:	00093703          	ld	a4,0(s2)
 bd0:	853e                	mv	a0,a5
 bd2:	fef719e3          	bne	a4,a5,bc4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 bd6:	8552                	mv	a0,s4
 bd8:	00000097          	auipc	ra,0x0
 bdc:	b5e080e7          	jalr	-1186(ra) # 736 <sbrk>
  if(p == (char*)-1)
 be0:	fd5518e3          	bne	a0,s5,bb0 <malloc+0xac>
        return 0;
 be4:	4501                	li	a0,0
 be6:	bf45                	j	b96 <malloc+0x92>
