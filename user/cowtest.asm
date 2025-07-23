
user/_cowtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <simpletest>:
// allocate more than half of physical memory,
// then fork. this will fail in the default
// kernel, which does not support copy-on-write.
void
simpletest()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  uint64 phys_size = PHYSTOP - KERNBASE;
  int sz = (phys_size / 3) * 2;

  printf("simple: ");
   e:	00001517          	auipc	a0,0x1
  12:	c6a50513          	addi	a0,a0,-918 # c78 <malloc+0xe8>
  16:	00001097          	auipc	ra,0x1
  1a:	abc080e7          	jalr	-1348(ra) # ad2 <printf>
  
  char *p = sbrk(sz);
  1e:	05555537          	lui	a0,0x5555
  22:	55450513          	addi	a0,a0,1364 # 5555554 <__BSS_END__+0x555076c>
  26:	00000097          	auipc	ra,0x0
  2a:	7a4080e7          	jalr	1956(ra) # 7ca <sbrk>
  if(p == (char*)0xffffffffffffffffL){
  2e:	57fd                	li	a5,-1
  30:	06f50563          	beq	a0,a5,9a <simpletest+0x9a>
  34:	84aa                	mv	s1,a0
    printf("sbrk(%d) failed\n", sz);
    exit(-1);
  }

  for(char *q = p; q < p + sz; q += 4096){
  36:	05556937          	lui	s2,0x5556
  3a:	992a                	add	s2,s2,a0
  3c:	6985                	lui	s3,0x1
    *(int*)q = getpid();
  3e:	00000097          	auipc	ra,0x0
  42:	784080e7          	jalr	1924(ra) # 7c2 <getpid>
  46:	c088                	sw	a0,0(s1)
  for(char *q = p; q < p + sz; q += 4096){
  48:	94ce                	add	s1,s1,s3
  4a:	fe991ae3          	bne	s2,s1,3e <simpletest+0x3e>
  }

  int pid = fork();
  4e:	00000097          	auipc	ra,0x0
  52:	6ec080e7          	jalr	1772(ra) # 73a <fork>
  if(pid < 0){
  56:	06054363          	bltz	a0,bc <simpletest+0xbc>
    printf("fork() failed\n");
    exit(-1);
  }

  if(pid == 0)
  5a:	cd35                	beqz	a0,d6 <simpletest+0xd6>
    exit(0);

  wait(0);
  5c:	4501                	li	a0,0
  5e:	00000097          	auipc	ra,0x0
  62:	6ec080e7          	jalr	1772(ra) # 74a <wait>

  if(sbrk(-sz) == (char*)0xffffffffffffffffL){
  66:	faaab537          	lui	a0,0xfaaab
  6a:	aac50513          	addi	a0,a0,-1364 # fffffffffaaaaaac <__BSS_END__+0xfffffffffaaa5cc4>
  6e:	00000097          	auipc	ra,0x0
  72:	75c080e7          	jalr	1884(ra) # 7ca <sbrk>
  76:	57fd                	li	a5,-1
  78:	06f50363          	beq	a0,a5,de <simpletest+0xde>
    printf("sbrk(-%d) failed\n", sz);
    exit(-1);
  }

  printf("ok\n");
  7c:	00001517          	auipc	a0,0x1
  80:	c4c50513          	addi	a0,a0,-948 # cc8 <malloc+0x138>
  84:	00001097          	auipc	ra,0x1
  88:	a4e080e7          	jalr	-1458(ra) # ad2 <printf>
}
  8c:	70a2                	ld	ra,40(sp)
  8e:	7402                	ld	s0,32(sp)
  90:	64e2                	ld	s1,24(sp)
  92:	6942                	ld	s2,16(sp)
  94:	69a2                	ld	s3,8(sp)
  96:	6145                	addi	sp,sp,48
  98:	8082                	ret
    printf("sbrk(%d) failed\n", sz);
  9a:	055555b7          	lui	a1,0x5555
  9e:	55458593          	addi	a1,a1,1364 # 5555554 <__BSS_END__+0x555076c>
  a2:	00001517          	auipc	a0,0x1
  a6:	be650513          	addi	a0,a0,-1050 # c88 <malloc+0xf8>
  aa:	00001097          	auipc	ra,0x1
  ae:	a28080e7          	jalr	-1496(ra) # ad2 <printf>
    exit(-1);
  b2:	557d                	li	a0,-1
  b4:	00000097          	auipc	ra,0x0
  b8:	68e080e7          	jalr	1678(ra) # 742 <exit>
    printf("fork() failed\n");
  bc:	00001517          	auipc	a0,0x1
  c0:	be450513          	addi	a0,a0,-1052 # ca0 <malloc+0x110>
  c4:	00001097          	auipc	ra,0x1
  c8:	a0e080e7          	jalr	-1522(ra) # ad2 <printf>
    exit(-1);
  cc:	557d                	li	a0,-1
  ce:	00000097          	auipc	ra,0x0
  d2:	674080e7          	jalr	1652(ra) # 742 <exit>
    exit(0);
  d6:	00000097          	auipc	ra,0x0
  da:	66c080e7          	jalr	1644(ra) # 742 <exit>
    printf("sbrk(-%d) failed\n", sz);
  de:	055555b7          	lui	a1,0x5555
  e2:	55458593          	addi	a1,a1,1364 # 5555554 <__BSS_END__+0x555076c>
  e6:	00001517          	auipc	a0,0x1
  ea:	bca50513          	addi	a0,a0,-1078 # cb0 <malloc+0x120>
  ee:	00001097          	auipc	ra,0x1
  f2:	9e4080e7          	jalr	-1564(ra) # ad2 <printf>
    exit(-1);
  f6:	557d                	li	a0,-1
  f8:	00000097          	auipc	ra,0x0
  fc:	64a080e7          	jalr	1610(ra) # 742 <exit>

0000000000000100 <threetest>:
// this causes more than half of physical memory
// to be allocated, so it also checks whether
// copied pages are freed.
void
threetest()
{
 100:	7179                	addi	sp,sp,-48
 102:	f406                	sd	ra,40(sp)
 104:	f022                	sd	s0,32(sp)
 106:	ec26                	sd	s1,24(sp)
 108:	e84a                	sd	s2,16(sp)
 10a:	e44e                	sd	s3,8(sp)
 10c:	e052                	sd	s4,0(sp)
 10e:	1800                	addi	s0,sp,48
  uint64 phys_size = PHYSTOP - KERNBASE;
  int sz = phys_size / 4;
  int pid1, pid2;

  printf("three: ");
 110:	00001517          	auipc	a0,0x1
 114:	bc050513          	addi	a0,a0,-1088 # cd0 <malloc+0x140>
 118:	00001097          	auipc	ra,0x1
 11c:	9ba080e7          	jalr	-1606(ra) # ad2 <printf>
  
  char *p = sbrk(sz);
 120:	02000537          	lui	a0,0x2000
 124:	00000097          	auipc	ra,0x0
 128:	6a6080e7          	jalr	1702(ra) # 7ca <sbrk>
  if(p == (char*)0xffffffffffffffffL){
 12c:	57fd                	li	a5,-1
 12e:	08f50763          	beq	a0,a5,1bc <threetest+0xbc>
 132:	84aa                	mv	s1,a0
    printf("sbrk(%d) failed\n", sz);
    exit(-1);
  }

  pid1 = fork();
 134:	00000097          	auipc	ra,0x0
 138:	606080e7          	jalr	1542(ra) # 73a <fork>
  if(pid1 < 0){
 13c:	08054f63          	bltz	a0,1da <threetest+0xda>
    printf("fork failed\n");
    exit(-1);
  }
  if(pid1 == 0){
 140:	c955                	beqz	a0,1f4 <threetest+0xf4>
      *(int*)q = 9999;
    }
    exit(0);
  }

  for(char *q = p; q < p + sz; q += 4096){
 142:	020009b7          	lui	s3,0x2000
 146:	99a6                	add	s3,s3,s1
 148:	8926                	mv	s2,s1
 14a:	6a05                	lui	s4,0x1
    *(int*)q = getpid();
 14c:	00000097          	auipc	ra,0x0
 150:	676080e7          	jalr	1654(ra) # 7c2 <getpid>
 154:	00a92023          	sw	a0,0(s2) # 5556000 <__BSS_END__+0x5551218>
  for(char *q = p; q < p + sz; q += 4096){
 158:	9952                	add	s2,s2,s4
 15a:	ff3919e3          	bne	s2,s3,14c <threetest+0x4c>
  }

  wait(0);
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	5ea080e7          	jalr	1514(ra) # 74a <wait>

  sleep(1);
 168:	4505                	li	a0,1
 16a:	00000097          	auipc	ra,0x0
 16e:	668080e7          	jalr	1640(ra) # 7d2 <sleep>

  for(char *q = p; q < p + sz; q += 4096){
 172:	6a05                	lui	s4,0x1
    if(*(int*)q != getpid()){
 174:	0004a903          	lw	s2,0(s1)
 178:	00000097          	auipc	ra,0x0
 17c:	64a080e7          	jalr	1610(ra) # 7c2 <getpid>
 180:	10a91a63          	bne	s2,a0,294 <threetest+0x194>
  for(char *q = p; q < p + sz; q += 4096){
 184:	94d2                	add	s1,s1,s4
 186:	ff3497e3          	bne	s1,s3,174 <threetest+0x74>
      printf("wrong content\n");
      exit(-1);
    }
  }

  if(sbrk(-sz) == (char*)0xffffffffffffffffL){
 18a:	fe000537          	lui	a0,0xfe000
 18e:	00000097          	auipc	ra,0x0
 192:	63c080e7          	jalr	1596(ra) # 7ca <sbrk>
 196:	57fd                	li	a5,-1
 198:	10f50b63          	beq	a0,a5,2ae <threetest+0x1ae>
    printf("sbrk(-%d) failed\n", sz);
    exit(-1);
  }

  printf("ok\n");
 19c:	00001517          	auipc	a0,0x1
 1a0:	b2c50513          	addi	a0,a0,-1236 # cc8 <malloc+0x138>
 1a4:	00001097          	auipc	ra,0x1
 1a8:	92e080e7          	jalr	-1746(ra) # ad2 <printf>
}
 1ac:	70a2                	ld	ra,40(sp)
 1ae:	7402                	ld	s0,32(sp)
 1b0:	64e2                	ld	s1,24(sp)
 1b2:	6942                	ld	s2,16(sp)
 1b4:	69a2                	ld	s3,8(sp)
 1b6:	6a02                	ld	s4,0(sp)
 1b8:	6145                	addi	sp,sp,48
 1ba:	8082                	ret
    printf("sbrk(%d) failed\n", sz);
 1bc:	020005b7          	lui	a1,0x2000
 1c0:	00001517          	auipc	a0,0x1
 1c4:	ac850513          	addi	a0,a0,-1336 # c88 <malloc+0xf8>
 1c8:	00001097          	auipc	ra,0x1
 1cc:	90a080e7          	jalr	-1782(ra) # ad2 <printf>
    exit(-1);
 1d0:	557d                	li	a0,-1
 1d2:	00000097          	auipc	ra,0x0
 1d6:	570080e7          	jalr	1392(ra) # 742 <exit>
    printf("fork failed\n");
 1da:	00001517          	auipc	a0,0x1
 1de:	afe50513          	addi	a0,a0,-1282 # cd8 <malloc+0x148>
 1e2:	00001097          	auipc	ra,0x1
 1e6:	8f0080e7          	jalr	-1808(ra) # ad2 <printf>
    exit(-1);
 1ea:	557d                	li	a0,-1
 1ec:	00000097          	auipc	ra,0x0
 1f0:	556080e7          	jalr	1366(ra) # 742 <exit>
    pid2 = fork();
 1f4:	00000097          	auipc	ra,0x0
 1f8:	546080e7          	jalr	1350(ra) # 73a <fork>
    if(pid2 < 0){
 1fc:	04054263          	bltz	a0,240 <threetest+0x140>
    if(pid2 == 0){
 200:	ed29                	bnez	a0,25a <threetest+0x15a>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 202:	0199a9b7          	lui	s3,0x199a
 206:	99a6                	add	s3,s3,s1
 208:	8926                	mv	s2,s1
 20a:	6a05                	lui	s4,0x1
        *(int*)q = getpid();
 20c:	00000097          	auipc	ra,0x0
 210:	5b6080e7          	jalr	1462(ra) # 7c2 <getpid>
 214:	00a92023          	sw	a0,0(s2)
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 218:	9952                	add	s2,s2,s4
 21a:	ff2999e3          	bne	s3,s2,20c <threetest+0x10c>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 21e:	6a05                	lui	s4,0x1
        if(*(int*)q != getpid()){
 220:	0004a903          	lw	s2,0(s1)
 224:	00000097          	auipc	ra,0x0
 228:	59e080e7          	jalr	1438(ra) # 7c2 <getpid>
 22c:	04a91763          	bne	s2,a0,27a <threetest+0x17a>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 230:	94d2                	add	s1,s1,s4
 232:	fe9997e3          	bne	s3,s1,220 <threetest+0x120>
      exit(-1);
 236:	557d                	li	a0,-1
 238:	00000097          	auipc	ra,0x0
 23c:	50a080e7          	jalr	1290(ra) # 742 <exit>
      printf("fork failed");
 240:	00001517          	auipc	a0,0x1
 244:	aa850513          	addi	a0,a0,-1368 # ce8 <malloc+0x158>
 248:	00001097          	auipc	ra,0x1
 24c:	88a080e7          	jalr	-1910(ra) # ad2 <printf>
      exit(-1);
 250:	557d                	li	a0,-1
 252:	00000097          	auipc	ra,0x0
 256:	4f0080e7          	jalr	1264(ra) # 742 <exit>
    for(char *q = p; q < p + (sz/2); q += 4096){
 25a:	01000737          	lui	a4,0x1000
 25e:	9726                	add	a4,a4,s1
      *(int*)q = 9999;
 260:	6789                	lui	a5,0x2
 262:	70f78793          	addi	a5,a5,1807 # 270f <buf+0x937>
    for(char *q = p; q < p + (sz/2); q += 4096){
 266:	6685                	lui	a3,0x1
      *(int*)q = 9999;
 268:	c09c                	sw	a5,0(s1)
    for(char *q = p; q < p + (sz/2); q += 4096){
 26a:	94b6                	add	s1,s1,a3
 26c:	fee49ee3          	bne	s1,a4,268 <threetest+0x168>
    exit(0);
 270:	4501                	li	a0,0
 272:	00000097          	auipc	ra,0x0
 276:	4d0080e7          	jalr	1232(ra) # 742 <exit>
          printf("wrong content\n");
 27a:	00001517          	auipc	a0,0x1
 27e:	a7e50513          	addi	a0,a0,-1410 # cf8 <malloc+0x168>
 282:	00001097          	auipc	ra,0x1
 286:	850080e7          	jalr	-1968(ra) # ad2 <printf>
          exit(-1);
 28a:	557d                	li	a0,-1
 28c:	00000097          	auipc	ra,0x0
 290:	4b6080e7          	jalr	1206(ra) # 742 <exit>
      printf("wrong content\n");
 294:	00001517          	auipc	a0,0x1
 298:	a6450513          	addi	a0,a0,-1436 # cf8 <malloc+0x168>
 29c:	00001097          	auipc	ra,0x1
 2a0:	836080e7          	jalr	-1994(ra) # ad2 <printf>
      exit(-1);
 2a4:	557d                	li	a0,-1
 2a6:	00000097          	auipc	ra,0x0
 2aa:	49c080e7          	jalr	1180(ra) # 742 <exit>
    printf("sbrk(-%d) failed\n", sz);
 2ae:	020005b7          	lui	a1,0x2000
 2b2:	00001517          	auipc	a0,0x1
 2b6:	9fe50513          	addi	a0,a0,-1538 # cb0 <malloc+0x120>
 2ba:	00001097          	auipc	ra,0x1
 2be:	818080e7          	jalr	-2024(ra) # ad2 <printf>
    exit(-1);
 2c2:	557d                	li	a0,-1
 2c4:	00000097          	auipc	ra,0x0
 2c8:	47e080e7          	jalr	1150(ra) # 742 <exit>

00000000000002cc <filetest>:
char junk3[4096];

// test whether copyout() simulates COW faults.
void
filetest()
{
 2cc:	7179                	addi	sp,sp,-48
 2ce:	f406                	sd	ra,40(sp)
 2d0:	f022                	sd	s0,32(sp)
 2d2:	ec26                	sd	s1,24(sp)
 2d4:	e84a                	sd	s2,16(sp)
 2d6:	1800                	addi	s0,sp,48
  printf("file: ");
 2d8:	00001517          	auipc	a0,0x1
 2dc:	a3050513          	addi	a0,a0,-1488 # d08 <malloc+0x178>
 2e0:	00000097          	auipc	ra,0x0
 2e4:	7f2080e7          	jalr	2034(ra) # ad2 <printf>
  
  buf[0] = 99;
 2e8:	06300793          	li	a5,99
 2ec:	00002717          	auipc	a4,0x2
 2f0:	aef70623          	sb	a5,-1300(a4) # 1dd8 <buf>

  for(int i = 0; i < 4; i++){
 2f4:	fc042c23          	sw	zero,-40(s0)
    if(pipe(fds) != 0){
 2f8:	00001497          	auipc	s1,0x1
 2fc:	ad048493          	addi	s1,s1,-1328 # dc8 <fds>
  for(int i = 0; i < 4; i++){
 300:	490d                	li	s2,3
    if(pipe(fds) != 0){
 302:	8526                	mv	a0,s1
 304:	00000097          	auipc	ra,0x0
 308:	44e080e7          	jalr	1102(ra) # 752 <pipe>
 30c:	e149                	bnez	a0,38e <filetest+0xc2>
      printf("pipe() failed\n");
      exit(-1);
    }
    int pid = fork();
 30e:	00000097          	auipc	ra,0x0
 312:	42c080e7          	jalr	1068(ra) # 73a <fork>
    if(pid < 0){
 316:	08054963          	bltz	a0,3a8 <filetest+0xdc>
      printf("fork failed\n");
      exit(-1);
    }
    if(pid == 0){
 31a:	c545                	beqz	a0,3c2 <filetest+0xf6>
        printf("error: read the wrong value\n");
        exit(1);
      }
      exit(0);
    }
    if(write(fds[1], &i, sizeof(i)) != sizeof(i)){
 31c:	4611                	li	a2,4
 31e:	fd840593          	addi	a1,s0,-40
 322:	40c8                	lw	a0,4(s1)
 324:	00000097          	auipc	ra,0x0
 328:	43e080e7          	jalr	1086(ra) # 762 <write>
 32c:	4791                	li	a5,4
 32e:	10f51b63          	bne	a0,a5,444 <filetest+0x178>
  for(int i = 0; i < 4; i++){
 332:	fd842783          	lw	a5,-40(s0)
 336:	2785                	addiw	a5,a5,1
 338:	0007871b          	sext.w	a4,a5
 33c:	fcf42c23          	sw	a5,-40(s0)
 340:	fce951e3          	bge	s2,a4,302 <filetest+0x36>
      printf("error: write failed\n");
      exit(-1);
    }
  }

  int xstatus = 0;
 344:	fc042e23          	sw	zero,-36(s0)
 348:	4491                	li	s1,4
  for(int i = 0; i < 4; i++) {
    wait(&xstatus);
 34a:	fdc40513          	addi	a0,s0,-36
 34e:	00000097          	auipc	ra,0x0
 352:	3fc080e7          	jalr	1020(ra) # 74a <wait>
    if(xstatus != 0) {
 356:	fdc42783          	lw	a5,-36(s0)
 35a:	10079263          	bnez	a5,45e <filetest+0x192>
  for(int i = 0; i < 4; i++) {
 35e:	34fd                	addiw	s1,s1,-1
 360:	f4ed                	bnez	s1,34a <filetest+0x7e>
      exit(1);
    }
  }

  if(buf[0] != 99){
 362:	00002717          	auipc	a4,0x2
 366:	a7674703          	lbu	a4,-1418(a4) # 1dd8 <buf>
 36a:	06300793          	li	a5,99
 36e:	0ef71d63          	bne	a4,a5,468 <filetest+0x19c>
    printf("error: child overwrote parent\n");
    exit(1);
  }

  printf("ok\n");
 372:	00001517          	auipc	a0,0x1
 376:	95650513          	addi	a0,a0,-1706 # cc8 <malloc+0x138>
 37a:	00000097          	auipc	ra,0x0
 37e:	758080e7          	jalr	1880(ra) # ad2 <printf>
}
 382:	70a2                	ld	ra,40(sp)
 384:	7402                	ld	s0,32(sp)
 386:	64e2                	ld	s1,24(sp)
 388:	6942                	ld	s2,16(sp)
 38a:	6145                	addi	sp,sp,48
 38c:	8082                	ret
      printf("pipe() failed\n");
 38e:	00001517          	auipc	a0,0x1
 392:	98250513          	addi	a0,a0,-1662 # d10 <malloc+0x180>
 396:	00000097          	auipc	ra,0x0
 39a:	73c080e7          	jalr	1852(ra) # ad2 <printf>
      exit(-1);
 39e:	557d                	li	a0,-1
 3a0:	00000097          	auipc	ra,0x0
 3a4:	3a2080e7          	jalr	930(ra) # 742 <exit>
      printf("fork failed\n");
 3a8:	00001517          	auipc	a0,0x1
 3ac:	93050513          	addi	a0,a0,-1744 # cd8 <malloc+0x148>
 3b0:	00000097          	auipc	ra,0x0
 3b4:	722080e7          	jalr	1826(ra) # ad2 <printf>
      exit(-1);
 3b8:	557d                	li	a0,-1
 3ba:	00000097          	auipc	ra,0x0
 3be:	388080e7          	jalr	904(ra) # 742 <exit>
      sleep(1);
 3c2:	4505                	li	a0,1
 3c4:	00000097          	auipc	ra,0x0
 3c8:	40e080e7          	jalr	1038(ra) # 7d2 <sleep>
      if(read(fds[0], buf, sizeof(i)) != sizeof(i)){
 3cc:	4611                	li	a2,4
 3ce:	00002597          	auipc	a1,0x2
 3d2:	a0a58593          	addi	a1,a1,-1526 # 1dd8 <buf>
 3d6:	00001517          	auipc	a0,0x1
 3da:	9f252503          	lw	a0,-1550(a0) # dc8 <fds>
 3de:	00000097          	auipc	ra,0x0
 3e2:	37c080e7          	jalr	892(ra) # 75a <read>
 3e6:	4791                	li	a5,4
 3e8:	02f51c63          	bne	a0,a5,420 <filetest+0x154>
      sleep(1);
 3ec:	4505                	li	a0,1
 3ee:	00000097          	auipc	ra,0x0
 3f2:	3e4080e7          	jalr	996(ra) # 7d2 <sleep>
      if(j != i){
 3f6:	fd842703          	lw	a4,-40(s0)
 3fa:	00002797          	auipc	a5,0x2
 3fe:	9de7a783          	lw	a5,-1570(a5) # 1dd8 <buf>
 402:	02f70c63          	beq	a4,a5,43a <filetest+0x16e>
        printf("error: read the wrong value\n");
 406:	00001517          	auipc	a0,0x1
 40a:	93250513          	addi	a0,a0,-1742 # d38 <malloc+0x1a8>
 40e:	00000097          	auipc	ra,0x0
 412:	6c4080e7          	jalr	1732(ra) # ad2 <printf>
        exit(1);
 416:	4505                	li	a0,1
 418:	00000097          	auipc	ra,0x0
 41c:	32a080e7          	jalr	810(ra) # 742 <exit>
        printf("error: read failed\n");
 420:	00001517          	auipc	a0,0x1
 424:	90050513          	addi	a0,a0,-1792 # d20 <malloc+0x190>
 428:	00000097          	auipc	ra,0x0
 42c:	6aa080e7          	jalr	1706(ra) # ad2 <printf>
        exit(1);
 430:	4505                	li	a0,1
 432:	00000097          	auipc	ra,0x0
 436:	310080e7          	jalr	784(ra) # 742 <exit>
      exit(0);
 43a:	4501                	li	a0,0
 43c:	00000097          	auipc	ra,0x0
 440:	306080e7          	jalr	774(ra) # 742 <exit>
      printf("error: write failed\n");
 444:	00001517          	auipc	a0,0x1
 448:	91450513          	addi	a0,a0,-1772 # d58 <malloc+0x1c8>
 44c:	00000097          	auipc	ra,0x0
 450:	686080e7          	jalr	1670(ra) # ad2 <printf>
      exit(-1);
 454:	557d                	li	a0,-1
 456:	00000097          	auipc	ra,0x0
 45a:	2ec080e7          	jalr	748(ra) # 742 <exit>
      exit(1);
 45e:	4505                	li	a0,1
 460:	00000097          	auipc	ra,0x0
 464:	2e2080e7          	jalr	738(ra) # 742 <exit>
    printf("error: child overwrote parent\n");
 468:	00001517          	auipc	a0,0x1
 46c:	90850513          	addi	a0,a0,-1784 # d70 <malloc+0x1e0>
 470:	00000097          	auipc	ra,0x0
 474:	662080e7          	jalr	1634(ra) # ad2 <printf>
    exit(1);
 478:	4505                	li	a0,1
 47a:	00000097          	auipc	ra,0x0
 47e:	2c8080e7          	jalr	712(ra) # 742 <exit>

0000000000000482 <main>:

int
main(int argc, char *argv[])
{
 482:	1141                	addi	sp,sp,-16
 484:	e406                	sd	ra,8(sp)
 486:	e022                	sd	s0,0(sp)
 488:	0800                	addi	s0,sp,16
  simpletest();
 48a:	00000097          	auipc	ra,0x0
 48e:	b76080e7          	jalr	-1162(ra) # 0 <simpletest>

  // check that the first simpletest() freed the physical memory.
  simpletest();
 492:	00000097          	auipc	ra,0x0
 496:	b6e080e7          	jalr	-1170(ra) # 0 <simpletest>

  threetest();
 49a:	00000097          	auipc	ra,0x0
 49e:	c66080e7          	jalr	-922(ra) # 100 <threetest>
  threetest();
 4a2:	00000097          	auipc	ra,0x0
 4a6:	c5e080e7          	jalr	-930(ra) # 100 <threetest>
  threetest();
 4aa:	00000097          	auipc	ra,0x0
 4ae:	c56080e7          	jalr	-938(ra) # 100 <threetest>

  filetest();
 4b2:	00000097          	auipc	ra,0x0
 4b6:	e1a080e7          	jalr	-486(ra) # 2cc <filetest>

  printf("ALL COW TESTS PASSED\n");
 4ba:	00001517          	auipc	a0,0x1
 4be:	8d650513          	addi	a0,a0,-1834 # d90 <malloc+0x200>
 4c2:	00000097          	auipc	ra,0x0
 4c6:	610080e7          	jalr	1552(ra) # ad2 <printf>

  exit(0);
 4ca:	4501                	li	a0,0
 4cc:	00000097          	auipc	ra,0x0
 4d0:	276080e7          	jalr	630(ra) # 742 <exit>

00000000000004d4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 4d4:	1141                	addi	sp,sp,-16
 4d6:	e422                	sd	s0,8(sp)
 4d8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 4da:	87aa                	mv	a5,a0
 4dc:	0585                	addi	a1,a1,1
 4de:	0785                	addi	a5,a5,1
 4e0:	fff5c703          	lbu	a4,-1(a1)
 4e4:	fee78fa3          	sb	a4,-1(a5)
 4e8:	fb75                	bnez	a4,4dc <strcpy+0x8>
    ;
  return os;
}
 4ea:	6422                	ld	s0,8(sp)
 4ec:	0141                	addi	sp,sp,16
 4ee:	8082                	ret

00000000000004f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4f0:	1141                	addi	sp,sp,-16
 4f2:	e422                	sd	s0,8(sp)
 4f4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4f6:	00054783          	lbu	a5,0(a0)
 4fa:	cb91                	beqz	a5,50e <strcmp+0x1e>
 4fc:	0005c703          	lbu	a4,0(a1)
 500:	00f71763          	bne	a4,a5,50e <strcmp+0x1e>
    p++, q++;
 504:	0505                	addi	a0,a0,1
 506:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 508:	00054783          	lbu	a5,0(a0)
 50c:	fbe5                	bnez	a5,4fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 50e:	0005c503          	lbu	a0,0(a1)
}
 512:	40a7853b          	subw	a0,a5,a0
 516:	6422                	ld	s0,8(sp)
 518:	0141                	addi	sp,sp,16
 51a:	8082                	ret

000000000000051c <strlen>:

uint
strlen(const char *s)
{
 51c:	1141                	addi	sp,sp,-16
 51e:	e422                	sd	s0,8(sp)
 520:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 522:	00054783          	lbu	a5,0(a0)
 526:	cf91                	beqz	a5,542 <strlen+0x26>
 528:	0505                	addi	a0,a0,1
 52a:	87aa                	mv	a5,a0
 52c:	4685                	li	a3,1
 52e:	9e89                	subw	a3,a3,a0
 530:	00f6853b          	addw	a0,a3,a5
 534:	0785                	addi	a5,a5,1
 536:	fff7c703          	lbu	a4,-1(a5)
 53a:	fb7d                	bnez	a4,530 <strlen+0x14>
    ;
  return n;
}
 53c:	6422                	ld	s0,8(sp)
 53e:	0141                	addi	sp,sp,16
 540:	8082                	ret
  for(n = 0; s[n]; n++)
 542:	4501                	li	a0,0
 544:	bfe5                	j	53c <strlen+0x20>

0000000000000546 <memset>:

void*
memset(void *dst, int c, uint n)
{
 546:	1141                	addi	sp,sp,-16
 548:	e422                	sd	s0,8(sp)
 54a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 54c:	ca19                	beqz	a2,562 <memset+0x1c>
 54e:	87aa                	mv	a5,a0
 550:	1602                	slli	a2,a2,0x20
 552:	9201                	srli	a2,a2,0x20
 554:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 558:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 55c:	0785                	addi	a5,a5,1
 55e:	fee79de3          	bne	a5,a4,558 <memset+0x12>
  }
  return dst;
}
 562:	6422                	ld	s0,8(sp)
 564:	0141                	addi	sp,sp,16
 566:	8082                	ret

0000000000000568 <strchr>:

char*
strchr(const char *s, char c)
{
 568:	1141                	addi	sp,sp,-16
 56a:	e422                	sd	s0,8(sp)
 56c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 56e:	00054783          	lbu	a5,0(a0)
 572:	cb99                	beqz	a5,588 <strchr+0x20>
    if(*s == c)
 574:	00f58763          	beq	a1,a5,582 <strchr+0x1a>
  for(; *s; s++)
 578:	0505                	addi	a0,a0,1
 57a:	00054783          	lbu	a5,0(a0)
 57e:	fbfd                	bnez	a5,574 <strchr+0xc>
      return (char*)s;
  return 0;
 580:	4501                	li	a0,0
}
 582:	6422                	ld	s0,8(sp)
 584:	0141                	addi	sp,sp,16
 586:	8082                	ret
  return 0;
 588:	4501                	li	a0,0
 58a:	bfe5                	j	582 <strchr+0x1a>

000000000000058c <gets>:

char*
gets(char *buf, int max)
{
 58c:	711d                	addi	sp,sp,-96
 58e:	ec86                	sd	ra,88(sp)
 590:	e8a2                	sd	s0,80(sp)
 592:	e4a6                	sd	s1,72(sp)
 594:	e0ca                	sd	s2,64(sp)
 596:	fc4e                	sd	s3,56(sp)
 598:	f852                	sd	s4,48(sp)
 59a:	f456                	sd	s5,40(sp)
 59c:	f05a                	sd	s6,32(sp)
 59e:	ec5e                	sd	s7,24(sp)
 5a0:	1080                	addi	s0,sp,96
 5a2:	8baa                	mv	s7,a0
 5a4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5a6:	892a                	mv	s2,a0
 5a8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 5aa:	4aa9                	li	s5,10
 5ac:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 5ae:	89a6                	mv	s3,s1
 5b0:	2485                	addiw	s1,s1,1
 5b2:	0344d863          	bge	s1,s4,5e2 <gets+0x56>
    cc = read(0, &c, 1);
 5b6:	4605                	li	a2,1
 5b8:	faf40593          	addi	a1,s0,-81
 5bc:	4501                	li	a0,0
 5be:	00000097          	auipc	ra,0x0
 5c2:	19c080e7          	jalr	412(ra) # 75a <read>
    if(cc < 1)
 5c6:	00a05e63          	blez	a0,5e2 <gets+0x56>
    buf[i++] = c;
 5ca:	faf44783          	lbu	a5,-81(s0)
 5ce:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 5d2:	01578763          	beq	a5,s5,5e0 <gets+0x54>
 5d6:	0905                	addi	s2,s2,1
 5d8:	fd679be3          	bne	a5,s6,5ae <gets+0x22>
  for(i=0; i+1 < max; ){
 5dc:	89a6                	mv	s3,s1
 5de:	a011                	j	5e2 <gets+0x56>
 5e0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 5e2:	99de                	add	s3,s3,s7
 5e4:	00098023          	sb	zero,0(s3) # 199a000 <__BSS_END__+0x1995218>
  return buf;
}
 5e8:	855e                	mv	a0,s7
 5ea:	60e6                	ld	ra,88(sp)
 5ec:	6446                	ld	s0,80(sp)
 5ee:	64a6                	ld	s1,72(sp)
 5f0:	6906                	ld	s2,64(sp)
 5f2:	79e2                	ld	s3,56(sp)
 5f4:	7a42                	ld	s4,48(sp)
 5f6:	7aa2                	ld	s5,40(sp)
 5f8:	7b02                	ld	s6,32(sp)
 5fa:	6be2                	ld	s7,24(sp)
 5fc:	6125                	addi	sp,sp,96
 5fe:	8082                	ret

0000000000000600 <stat>:

int
stat(const char *n, struct stat *st)
{
 600:	1101                	addi	sp,sp,-32
 602:	ec06                	sd	ra,24(sp)
 604:	e822                	sd	s0,16(sp)
 606:	e426                	sd	s1,8(sp)
 608:	e04a                	sd	s2,0(sp)
 60a:	1000                	addi	s0,sp,32
 60c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 60e:	4581                	li	a1,0
 610:	00000097          	auipc	ra,0x0
 614:	172080e7          	jalr	370(ra) # 782 <open>
  if(fd < 0)
 618:	02054563          	bltz	a0,642 <stat+0x42>
 61c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 61e:	85ca                	mv	a1,s2
 620:	00000097          	auipc	ra,0x0
 624:	17a080e7          	jalr	378(ra) # 79a <fstat>
 628:	892a                	mv	s2,a0
  close(fd);
 62a:	8526                	mv	a0,s1
 62c:	00000097          	auipc	ra,0x0
 630:	13e080e7          	jalr	318(ra) # 76a <close>
  return r;
}
 634:	854a                	mv	a0,s2
 636:	60e2                	ld	ra,24(sp)
 638:	6442                	ld	s0,16(sp)
 63a:	64a2                	ld	s1,8(sp)
 63c:	6902                	ld	s2,0(sp)
 63e:	6105                	addi	sp,sp,32
 640:	8082                	ret
    return -1;
 642:	597d                	li	s2,-1
 644:	bfc5                	j	634 <stat+0x34>

0000000000000646 <atoi>:

int
atoi(const char *s)
{
 646:	1141                	addi	sp,sp,-16
 648:	e422                	sd	s0,8(sp)
 64a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 64c:	00054603          	lbu	a2,0(a0)
 650:	fd06079b          	addiw	a5,a2,-48
 654:	0ff7f793          	andi	a5,a5,255
 658:	4725                	li	a4,9
 65a:	02f76963          	bltu	a4,a5,68c <atoi+0x46>
 65e:	86aa                	mv	a3,a0
  n = 0;
 660:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 662:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 664:	0685                	addi	a3,a3,1
 666:	0025179b          	slliw	a5,a0,0x2
 66a:	9fa9                	addw	a5,a5,a0
 66c:	0017979b          	slliw	a5,a5,0x1
 670:	9fb1                	addw	a5,a5,a2
 672:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 676:	0006c603          	lbu	a2,0(a3) # 1000 <junk3+0x228>
 67a:	fd06071b          	addiw	a4,a2,-48
 67e:	0ff77713          	andi	a4,a4,255
 682:	fee5f1e3          	bgeu	a1,a4,664 <atoi+0x1e>
  return n;
}
 686:	6422                	ld	s0,8(sp)
 688:	0141                	addi	sp,sp,16
 68a:	8082                	ret
  n = 0;
 68c:	4501                	li	a0,0
 68e:	bfe5                	j	686 <atoi+0x40>

0000000000000690 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 690:	1141                	addi	sp,sp,-16
 692:	e422                	sd	s0,8(sp)
 694:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 696:	02b57463          	bgeu	a0,a1,6be <memmove+0x2e>
    while(n-- > 0)
 69a:	00c05f63          	blez	a2,6b8 <memmove+0x28>
 69e:	1602                	slli	a2,a2,0x20
 6a0:	9201                	srli	a2,a2,0x20
 6a2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 6a6:	872a                	mv	a4,a0
      *dst++ = *src++;
 6a8:	0585                	addi	a1,a1,1
 6aa:	0705                	addi	a4,a4,1
 6ac:	fff5c683          	lbu	a3,-1(a1)
 6b0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 6b4:	fee79ae3          	bne	a5,a4,6a8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 6b8:	6422                	ld	s0,8(sp)
 6ba:	0141                	addi	sp,sp,16
 6bc:	8082                	ret
    dst += n;
 6be:	00c50733          	add	a4,a0,a2
    src += n;
 6c2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 6c4:	fec05ae3          	blez	a2,6b8 <memmove+0x28>
 6c8:	fff6079b          	addiw	a5,a2,-1
 6cc:	1782                	slli	a5,a5,0x20
 6ce:	9381                	srli	a5,a5,0x20
 6d0:	fff7c793          	not	a5,a5
 6d4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6d6:	15fd                	addi	a1,a1,-1
 6d8:	177d                	addi	a4,a4,-1
 6da:	0005c683          	lbu	a3,0(a1)
 6de:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 6e2:	fee79ae3          	bne	a5,a4,6d6 <memmove+0x46>
 6e6:	bfc9                	j	6b8 <memmove+0x28>

00000000000006e8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 6e8:	1141                	addi	sp,sp,-16
 6ea:	e422                	sd	s0,8(sp)
 6ec:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 6ee:	ca05                	beqz	a2,71e <memcmp+0x36>
 6f0:	fff6069b          	addiw	a3,a2,-1
 6f4:	1682                	slli	a3,a3,0x20
 6f6:	9281                	srli	a3,a3,0x20
 6f8:	0685                	addi	a3,a3,1
 6fa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6fc:	00054783          	lbu	a5,0(a0)
 700:	0005c703          	lbu	a4,0(a1)
 704:	00e79863          	bne	a5,a4,714 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 708:	0505                	addi	a0,a0,1
    p2++;
 70a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 70c:	fed518e3          	bne	a0,a3,6fc <memcmp+0x14>
  }
  return 0;
 710:	4501                	li	a0,0
 712:	a019                	j	718 <memcmp+0x30>
      return *p1 - *p2;
 714:	40e7853b          	subw	a0,a5,a4
}
 718:	6422                	ld	s0,8(sp)
 71a:	0141                	addi	sp,sp,16
 71c:	8082                	ret
  return 0;
 71e:	4501                	li	a0,0
 720:	bfe5                	j	718 <memcmp+0x30>

0000000000000722 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 722:	1141                	addi	sp,sp,-16
 724:	e406                	sd	ra,8(sp)
 726:	e022                	sd	s0,0(sp)
 728:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 72a:	00000097          	auipc	ra,0x0
 72e:	f66080e7          	jalr	-154(ra) # 690 <memmove>
}
 732:	60a2                	ld	ra,8(sp)
 734:	6402                	ld	s0,0(sp)
 736:	0141                	addi	sp,sp,16
 738:	8082                	ret

000000000000073a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 73a:	4885                	li	a7,1
 ecall
 73c:	00000073          	ecall
 ret
 740:	8082                	ret

0000000000000742 <exit>:
.global exit
exit:
 li a7, SYS_exit
 742:	4889                	li	a7,2
 ecall
 744:	00000073          	ecall
 ret
 748:	8082                	ret

000000000000074a <wait>:
.global wait
wait:
 li a7, SYS_wait
 74a:	488d                	li	a7,3
 ecall
 74c:	00000073          	ecall
 ret
 750:	8082                	ret

0000000000000752 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 752:	4891                	li	a7,4
 ecall
 754:	00000073          	ecall
 ret
 758:	8082                	ret

000000000000075a <read>:
.global read
read:
 li a7, SYS_read
 75a:	4895                	li	a7,5
 ecall
 75c:	00000073          	ecall
 ret
 760:	8082                	ret

0000000000000762 <write>:
.global write
write:
 li a7, SYS_write
 762:	48c1                	li	a7,16
 ecall
 764:	00000073          	ecall
 ret
 768:	8082                	ret

000000000000076a <close>:
.global close
close:
 li a7, SYS_close
 76a:	48d5                	li	a7,21
 ecall
 76c:	00000073          	ecall
 ret
 770:	8082                	ret

0000000000000772 <kill>:
.global kill
kill:
 li a7, SYS_kill
 772:	4899                	li	a7,6
 ecall
 774:	00000073          	ecall
 ret
 778:	8082                	ret

000000000000077a <exec>:
.global exec
exec:
 li a7, SYS_exec
 77a:	489d                	li	a7,7
 ecall
 77c:	00000073          	ecall
 ret
 780:	8082                	ret

0000000000000782 <open>:
.global open
open:
 li a7, SYS_open
 782:	48bd                	li	a7,15
 ecall
 784:	00000073          	ecall
 ret
 788:	8082                	ret

000000000000078a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 78a:	48c5                	li	a7,17
 ecall
 78c:	00000073          	ecall
 ret
 790:	8082                	ret

0000000000000792 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 792:	48c9                	li	a7,18
 ecall
 794:	00000073          	ecall
 ret
 798:	8082                	ret

000000000000079a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 79a:	48a1                	li	a7,8
 ecall
 79c:	00000073          	ecall
 ret
 7a0:	8082                	ret

00000000000007a2 <link>:
.global link
link:
 li a7, SYS_link
 7a2:	48cd                	li	a7,19
 ecall
 7a4:	00000073          	ecall
 ret
 7a8:	8082                	ret

00000000000007aa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 7aa:	48d1                	li	a7,20
 ecall
 7ac:	00000073          	ecall
 ret
 7b0:	8082                	ret

00000000000007b2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 7b2:	48a5                	li	a7,9
 ecall
 7b4:	00000073          	ecall
 ret
 7b8:	8082                	ret

00000000000007ba <dup>:
.global dup
dup:
 li a7, SYS_dup
 7ba:	48a9                	li	a7,10
 ecall
 7bc:	00000073          	ecall
 ret
 7c0:	8082                	ret

00000000000007c2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7c2:	48ad                	li	a7,11
 ecall
 7c4:	00000073          	ecall
 ret
 7c8:	8082                	ret

00000000000007ca <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7ca:	48b1                	li	a7,12
 ecall
 7cc:	00000073          	ecall
 ret
 7d0:	8082                	ret

00000000000007d2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 7d2:	48b5                	li	a7,13
 ecall
 7d4:	00000073          	ecall
 ret
 7d8:	8082                	ret

00000000000007da <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7da:	48b9                	li	a7,14
 ecall
 7dc:	00000073          	ecall
 ret
 7e0:	8082                	ret

00000000000007e2 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 7e2:	48d9                	li	a7,22
 ecall
 7e4:	00000073          	ecall
 ret
 7e8:	8082                	ret

00000000000007ea <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 7ea:	48d9                	li	a7,22
 ecall
 7ec:	00000073          	ecall
 ret
 7f0:	8082                	ret

00000000000007f2 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 7f2:	48dd                	li	a7,23
 ecall
 7f4:	00000073          	ecall
 ret
 7f8:	8082                	ret

00000000000007fa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7fa:	1101                	addi	sp,sp,-32
 7fc:	ec06                	sd	ra,24(sp)
 7fe:	e822                	sd	s0,16(sp)
 800:	1000                	addi	s0,sp,32
 802:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 806:	4605                	li	a2,1
 808:	fef40593          	addi	a1,s0,-17
 80c:	00000097          	auipc	ra,0x0
 810:	f56080e7          	jalr	-170(ra) # 762 <write>
}
 814:	60e2                	ld	ra,24(sp)
 816:	6442                	ld	s0,16(sp)
 818:	6105                	addi	sp,sp,32
 81a:	8082                	ret

000000000000081c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 81c:	7139                	addi	sp,sp,-64
 81e:	fc06                	sd	ra,56(sp)
 820:	f822                	sd	s0,48(sp)
 822:	f426                	sd	s1,40(sp)
 824:	f04a                	sd	s2,32(sp)
 826:	ec4e                	sd	s3,24(sp)
 828:	0080                	addi	s0,sp,64
 82a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 82c:	c299                	beqz	a3,832 <printint+0x16>
 82e:	0805c863          	bltz	a1,8be <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 832:	2581                	sext.w	a1,a1
  neg = 0;
 834:	4881                	li	a7,0
 836:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 83a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 83c:	2601                	sext.w	a2,a2
 83e:	00000517          	auipc	a0,0x0
 842:	57250513          	addi	a0,a0,1394 # db0 <digits>
 846:	883a                	mv	a6,a4
 848:	2705                	addiw	a4,a4,1
 84a:	02c5f7bb          	remuw	a5,a1,a2
 84e:	1782                	slli	a5,a5,0x20
 850:	9381                	srli	a5,a5,0x20
 852:	97aa                	add	a5,a5,a0
 854:	0007c783          	lbu	a5,0(a5)
 858:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 85c:	0005879b          	sext.w	a5,a1
 860:	02c5d5bb          	divuw	a1,a1,a2
 864:	0685                	addi	a3,a3,1
 866:	fec7f0e3          	bgeu	a5,a2,846 <printint+0x2a>
  if(neg)
 86a:	00088b63          	beqz	a7,880 <printint+0x64>
    buf[i++] = '-';
 86e:	fd040793          	addi	a5,s0,-48
 872:	973e                	add	a4,a4,a5
 874:	02d00793          	li	a5,45
 878:	fef70823          	sb	a5,-16(a4)
 87c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 880:	02e05863          	blez	a4,8b0 <printint+0x94>
 884:	fc040793          	addi	a5,s0,-64
 888:	00e78933          	add	s2,a5,a4
 88c:	fff78993          	addi	s3,a5,-1
 890:	99ba                	add	s3,s3,a4
 892:	377d                	addiw	a4,a4,-1
 894:	1702                	slli	a4,a4,0x20
 896:	9301                	srli	a4,a4,0x20
 898:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 89c:	fff94583          	lbu	a1,-1(s2)
 8a0:	8526                	mv	a0,s1
 8a2:	00000097          	auipc	ra,0x0
 8a6:	f58080e7          	jalr	-168(ra) # 7fa <putc>
  while(--i >= 0)
 8aa:	197d                	addi	s2,s2,-1
 8ac:	ff3918e3          	bne	s2,s3,89c <printint+0x80>
}
 8b0:	70e2                	ld	ra,56(sp)
 8b2:	7442                	ld	s0,48(sp)
 8b4:	74a2                	ld	s1,40(sp)
 8b6:	7902                	ld	s2,32(sp)
 8b8:	69e2                	ld	s3,24(sp)
 8ba:	6121                	addi	sp,sp,64
 8bc:	8082                	ret
    x = -xx;
 8be:	40b005bb          	negw	a1,a1
    neg = 1;
 8c2:	4885                	li	a7,1
    x = -xx;
 8c4:	bf8d                	j	836 <printint+0x1a>

00000000000008c6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8c6:	7119                	addi	sp,sp,-128
 8c8:	fc86                	sd	ra,120(sp)
 8ca:	f8a2                	sd	s0,112(sp)
 8cc:	f4a6                	sd	s1,104(sp)
 8ce:	f0ca                	sd	s2,96(sp)
 8d0:	ecce                	sd	s3,88(sp)
 8d2:	e8d2                	sd	s4,80(sp)
 8d4:	e4d6                	sd	s5,72(sp)
 8d6:	e0da                	sd	s6,64(sp)
 8d8:	fc5e                	sd	s7,56(sp)
 8da:	f862                	sd	s8,48(sp)
 8dc:	f466                	sd	s9,40(sp)
 8de:	f06a                	sd	s10,32(sp)
 8e0:	ec6e                	sd	s11,24(sp)
 8e2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8e4:	0005c903          	lbu	s2,0(a1)
 8e8:	18090f63          	beqz	s2,a86 <vprintf+0x1c0>
 8ec:	8aaa                	mv	s5,a0
 8ee:	8b32                	mv	s6,a2
 8f0:	00158493          	addi	s1,a1,1
  state = 0;
 8f4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8f6:	02500a13          	li	s4,37
      if(c == 'd'){
 8fa:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 8fe:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 902:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 906:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 90a:	00000b97          	auipc	s7,0x0
 90e:	4a6b8b93          	addi	s7,s7,1190 # db0 <digits>
 912:	a839                	j	930 <vprintf+0x6a>
        putc(fd, c);
 914:	85ca                	mv	a1,s2
 916:	8556                	mv	a0,s5
 918:	00000097          	auipc	ra,0x0
 91c:	ee2080e7          	jalr	-286(ra) # 7fa <putc>
 920:	a019                	j	926 <vprintf+0x60>
    } else if(state == '%'){
 922:	01498f63          	beq	s3,s4,940 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 926:	0485                	addi	s1,s1,1
 928:	fff4c903          	lbu	s2,-1(s1)
 92c:	14090d63          	beqz	s2,a86 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 930:	0009079b          	sext.w	a5,s2
    if(state == 0){
 934:	fe0997e3          	bnez	s3,922 <vprintf+0x5c>
      if(c == '%'){
 938:	fd479ee3          	bne	a5,s4,914 <vprintf+0x4e>
        state = '%';
 93c:	89be                	mv	s3,a5
 93e:	b7e5                	j	926 <vprintf+0x60>
      if(c == 'd'){
 940:	05878063          	beq	a5,s8,980 <vprintf+0xba>
      } else if(c == 'l') {
 944:	05978c63          	beq	a5,s9,99c <vprintf+0xd6>
      } else if(c == 'x') {
 948:	07a78863          	beq	a5,s10,9b8 <vprintf+0xf2>
      } else if(c == 'p') {
 94c:	09b78463          	beq	a5,s11,9d4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 950:	07300713          	li	a4,115
 954:	0ce78663          	beq	a5,a4,a20 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 958:	06300713          	li	a4,99
 95c:	0ee78e63          	beq	a5,a4,a58 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 960:	11478863          	beq	a5,s4,a70 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 964:	85d2                	mv	a1,s4
 966:	8556                	mv	a0,s5
 968:	00000097          	auipc	ra,0x0
 96c:	e92080e7          	jalr	-366(ra) # 7fa <putc>
        putc(fd, c);
 970:	85ca                	mv	a1,s2
 972:	8556                	mv	a0,s5
 974:	00000097          	auipc	ra,0x0
 978:	e86080e7          	jalr	-378(ra) # 7fa <putc>
      }
      state = 0;
 97c:	4981                	li	s3,0
 97e:	b765                	j	926 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 980:	008b0913          	addi	s2,s6,8
 984:	4685                	li	a3,1
 986:	4629                	li	a2,10
 988:	000b2583          	lw	a1,0(s6)
 98c:	8556                	mv	a0,s5
 98e:	00000097          	auipc	ra,0x0
 992:	e8e080e7          	jalr	-370(ra) # 81c <printint>
 996:	8b4a                	mv	s6,s2
      state = 0;
 998:	4981                	li	s3,0
 99a:	b771                	j	926 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 99c:	008b0913          	addi	s2,s6,8
 9a0:	4681                	li	a3,0
 9a2:	4629                	li	a2,10
 9a4:	000b2583          	lw	a1,0(s6)
 9a8:	8556                	mv	a0,s5
 9aa:	00000097          	auipc	ra,0x0
 9ae:	e72080e7          	jalr	-398(ra) # 81c <printint>
 9b2:	8b4a                	mv	s6,s2
      state = 0;
 9b4:	4981                	li	s3,0
 9b6:	bf85                	j	926 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 9b8:	008b0913          	addi	s2,s6,8
 9bc:	4681                	li	a3,0
 9be:	4641                	li	a2,16
 9c0:	000b2583          	lw	a1,0(s6)
 9c4:	8556                	mv	a0,s5
 9c6:	00000097          	auipc	ra,0x0
 9ca:	e56080e7          	jalr	-426(ra) # 81c <printint>
 9ce:	8b4a                	mv	s6,s2
      state = 0;
 9d0:	4981                	li	s3,0
 9d2:	bf91                	j	926 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 9d4:	008b0793          	addi	a5,s6,8
 9d8:	f8f43423          	sd	a5,-120(s0)
 9dc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 9e0:	03000593          	li	a1,48
 9e4:	8556                	mv	a0,s5
 9e6:	00000097          	auipc	ra,0x0
 9ea:	e14080e7          	jalr	-492(ra) # 7fa <putc>
  putc(fd, 'x');
 9ee:	85ea                	mv	a1,s10
 9f0:	8556                	mv	a0,s5
 9f2:	00000097          	auipc	ra,0x0
 9f6:	e08080e7          	jalr	-504(ra) # 7fa <putc>
 9fa:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9fc:	03c9d793          	srli	a5,s3,0x3c
 a00:	97de                	add	a5,a5,s7
 a02:	0007c583          	lbu	a1,0(a5)
 a06:	8556                	mv	a0,s5
 a08:	00000097          	auipc	ra,0x0
 a0c:	df2080e7          	jalr	-526(ra) # 7fa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a10:	0992                	slli	s3,s3,0x4
 a12:	397d                	addiw	s2,s2,-1
 a14:	fe0914e3          	bnez	s2,9fc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 a18:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 a1c:	4981                	li	s3,0
 a1e:	b721                	j	926 <vprintf+0x60>
        s = va_arg(ap, char*);
 a20:	008b0993          	addi	s3,s6,8
 a24:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 a28:	02090163          	beqz	s2,a4a <vprintf+0x184>
        while(*s != 0){
 a2c:	00094583          	lbu	a1,0(s2)
 a30:	c9a1                	beqz	a1,a80 <vprintf+0x1ba>
          putc(fd, *s);
 a32:	8556                	mv	a0,s5
 a34:	00000097          	auipc	ra,0x0
 a38:	dc6080e7          	jalr	-570(ra) # 7fa <putc>
          s++;
 a3c:	0905                	addi	s2,s2,1
        while(*s != 0){
 a3e:	00094583          	lbu	a1,0(s2)
 a42:	f9e5                	bnez	a1,a32 <vprintf+0x16c>
        s = va_arg(ap, char*);
 a44:	8b4e                	mv	s6,s3
      state = 0;
 a46:	4981                	li	s3,0
 a48:	bdf9                	j	926 <vprintf+0x60>
          s = "(null)";
 a4a:	00000917          	auipc	s2,0x0
 a4e:	35e90913          	addi	s2,s2,862 # da8 <malloc+0x218>
        while(*s != 0){
 a52:	02800593          	li	a1,40
 a56:	bff1                	j	a32 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a58:	008b0913          	addi	s2,s6,8
 a5c:	000b4583          	lbu	a1,0(s6)
 a60:	8556                	mv	a0,s5
 a62:	00000097          	auipc	ra,0x0
 a66:	d98080e7          	jalr	-616(ra) # 7fa <putc>
 a6a:	8b4a                	mv	s6,s2
      state = 0;
 a6c:	4981                	li	s3,0
 a6e:	bd65                	j	926 <vprintf+0x60>
        putc(fd, c);
 a70:	85d2                	mv	a1,s4
 a72:	8556                	mv	a0,s5
 a74:	00000097          	auipc	ra,0x0
 a78:	d86080e7          	jalr	-634(ra) # 7fa <putc>
      state = 0;
 a7c:	4981                	li	s3,0
 a7e:	b565                	j	926 <vprintf+0x60>
        s = va_arg(ap, char*);
 a80:	8b4e                	mv	s6,s3
      state = 0;
 a82:	4981                	li	s3,0
 a84:	b54d                	j	926 <vprintf+0x60>
    }
  }
}
 a86:	70e6                	ld	ra,120(sp)
 a88:	7446                	ld	s0,112(sp)
 a8a:	74a6                	ld	s1,104(sp)
 a8c:	7906                	ld	s2,96(sp)
 a8e:	69e6                	ld	s3,88(sp)
 a90:	6a46                	ld	s4,80(sp)
 a92:	6aa6                	ld	s5,72(sp)
 a94:	6b06                	ld	s6,64(sp)
 a96:	7be2                	ld	s7,56(sp)
 a98:	7c42                	ld	s8,48(sp)
 a9a:	7ca2                	ld	s9,40(sp)
 a9c:	7d02                	ld	s10,32(sp)
 a9e:	6de2                	ld	s11,24(sp)
 aa0:	6109                	addi	sp,sp,128
 aa2:	8082                	ret

0000000000000aa4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 aa4:	715d                	addi	sp,sp,-80
 aa6:	ec06                	sd	ra,24(sp)
 aa8:	e822                	sd	s0,16(sp)
 aaa:	1000                	addi	s0,sp,32
 aac:	e010                	sd	a2,0(s0)
 aae:	e414                	sd	a3,8(s0)
 ab0:	e818                	sd	a4,16(s0)
 ab2:	ec1c                	sd	a5,24(s0)
 ab4:	03043023          	sd	a6,32(s0)
 ab8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 abc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ac0:	8622                	mv	a2,s0
 ac2:	00000097          	auipc	ra,0x0
 ac6:	e04080e7          	jalr	-508(ra) # 8c6 <vprintf>
}
 aca:	60e2                	ld	ra,24(sp)
 acc:	6442                	ld	s0,16(sp)
 ace:	6161                	addi	sp,sp,80
 ad0:	8082                	ret

0000000000000ad2 <printf>:

void
printf(const char *fmt, ...)
{
 ad2:	711d                	addi	sp,sp,-96
 ad4:	ec06                	sd	ra,24(sp)
 ad6:	e822                	sd	s0,16(sp)
 ad8:	1000                	addi	s0,sp,32
 ada:	e40c                	sd	a1,8(s0)
 adc:	e810                	sd	a2,16(s0)
 ade:	ec14                	sd	a3,24(s0)
 ae0:	f018                	sd	a4,32(s0)
 ae2:	f41c                	sd	a5,40(s0)
 ae4:	03043823          	sd	a6,48(s0)
 ae8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 aec:	00840613          	addi	a2,s0,8
 af0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 af4:	85aa                	mv	a1,a0
 af6:	4505                	li	a0,1
 af8:	00000097          	auipc	ra,0x0
 afc:	dce080e7          	jalr	-562(ra) # 8c6 <vprintf>
}
 b00:	60e2                	ld	ra,24(sp)
 b02:	6442                	ld	s0,16(sp)
 b04:	6125                	addi	sp,sp,96
 b06:	8082                	ret

0000000000000b08 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b08:	1141                	addi	sp,sp,-16
 b0a:	e422                	sd	s0,8(sp)
 b0c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b0e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b12:	00000797          	auipc	a5,0x0
 b16:	2be7b783          	ld	a5,702(a5) # dd0 <freep>
 b1a:	a805                	j	b4a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b1c:	4618                	lw	a4,8(a2)
 b1e:	9db9                	addw	a1,a1,a4
 b20:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b24:	6398                	ld	a4,0(a5)
 b26:	6318                	ld	a4,0(a4)
 b28:	fee53823          	sd	a4,-16(a0)
 b2c:	a091                	j	b70 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b2e:	ff852703          	lw	a4,-8(a0)
 b32:	9e39                	addw	a2,a2,a4
 b34:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 b36:	ff053703          	ld	a4,-16(a0)
 b3a:	e398                	sd	a4,0(a5)
 b3c:	a099                	j	b82 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b3e:	6398                	ld	a4,0(a5)
 b40:	00e7e463          	bltu	a5,a4,b48 <free+0x40>
 b44:	00e6ea63          	bltu	a3,a4,b58 <free+0x50>
{
 b48:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b4a:	fed7fae3          	bgeu	a5,a3,b3e <free+0x36>
 b4e:	6398                	ld	a4,0(a5)
 b50:	00e6e463          	bltu	a3,a4,b58 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b54:	fee7eae3          	bltu	a5,a4,b48 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b58:	ff852583          	lw	a1,-8(a0)
 b5c:	6390                	ld	a2,0(a5)
 b5e:	02059713          	slli	a4,a1,0x20
 b62:	9301                	srli	a4,a4,0x20
 b64:	0712                	slli	a4,a4,0x4
 b66:	9736                	add	a4,a4,a3
 b68:	fae60ae3          	beq	a2,a4,b1c <free+0x14>
    bp->s.ptr = p->s.ptr;
 b6c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b70:	4790                	lw	a2,8(a5)
 b72:	02061713          	slli	a4,a2,0x20
 b76:	9301                	srli	a4,a4,0x20
 b78:	0712                	slli	a4,a4,0x4
 b7a:	973e                	add	a4,a4,a5
 b7c:	fae689e3          	beq	a3,a4,b2e <free+0x26>
  } else
    p->s.ptr = bp;
 b80:	e394                	sd	a3,0(a5)
  freep = p;
 b82:	00000717          	auipc	a4,0x0
 b86:	24f73723          	sd	a5,590(a4) # dd0 <freep>
}
 b8a:	6422                	ld	s0,8(sp)
 b8c:	0141                	addi	sp,sp,16
 b8e:	8082                	ret

0000000000000b90 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b90:	7139                	addi	sp,sp,-64
 b92:	fc06                	sd	ra,56(sp)
 b94:	f822                	sd	s0,48(sp)
 b96:	f426                	sd	s1,40(sp)
 b98:	f04a                	sd	s2,32(sp)
 b9a:	ec4e                	sd	s3,24(sp)
 b9c:	e852                	sd	s4,16(sp)
 b9e:	e456                	sd	s5,8(sp)
 ba0:	e05a                	sd	s6,0(sp)
 ba2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ba4:	02051493          	slli	s1,a0,0x20
 ba8:	9081                	srli	s1,s1,0x20
 baa:	04bd                	addi	s1,s1,15
 bac:	8091                	srli	s1,s1,0x4
 bae:	0014899b          	addiw	s3,s1,1
 bb2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 bb4:	00000517          	auipc	a0,0x0
 bb8:	21c53503          	ld	a0,540(a0) # dd0 <freep>
 bbc:	c515                	beqz	a0,be8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bbe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bc0:	4798                	lw	a4,8(a5)
 bc2:	02977f63          	bgeu	a4,s1,c00 <malloc+0x70>
 bc6:	8a4e                	mv	s4,s3
 bc8:	0009871b          	sext.w	a4,s3
 bcc:	6685                	lui	a3,0x1
 bce:	00d77363          	bgeu	a4,a3,bd4 <malloc+0x44>
 bd2:	6a05                	lui	s4,0x1
 bd4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bd8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bdc:	00000917          	auipc	s2,0x0
 be0:	1f490913          	addi	s2,s2,500 # dd0 <freep>
  if(p == (char*)-1)
 be4:	5afd                	li	s5,-1
 be6:	a88d                	j	c58 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 be8:	00004797          	auipc	a5,0x4
 bec:	1f078793          	addi	a5,a5,496 # 4dd8 <base>
 bf0:	00000717          	auipc	a4,0x0
 bf4:	1ef73023          	sd	a5,480(a4) # dd0 <freep>
 bf8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bfa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bfe:	b7e1                	j	bc6 <malloc+0x36>
      if(p->s.size == nunits)
 c00:	02e48b63          	beq	s1,a4,c36 <malloc+0xa6>
        p->s.size -= nunits;
 c04:	4137073b          	subw	a4,a4,s3
 c08:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c0a:	1702                	slli	a4,a4,0x20
 c0c:	9301                	srli	a4,a4,0x20
 c0e:	0712                	slli	a4,a4,0x4
 c10:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c12:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c16:	00000717          	auipc	a4,0x0
 c1a:	1aa73d23          	sd	a0,442(a4) # dd0 <freep>
      return (void*)(p + 1);
 c1e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c22:	70e2                	ld	ra,56(sp)
 c24:	7442                	ld	s0,48(sp)
 c26:	74a2                	ld	s1,40(sp)
 c28:	7902                	ld	s2,32(sp)
 c2a:	69e2                	ld	s3,24(sp)
 c2c:	6a42                	ld	s4,16(sp)
 c2e:	6aa2                	ld	s5,8(sp)
 c30:	6b02                	ld	s6,0(sp)
 c32:	6121                	addi	sp,sp,64
 c34:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c36:	6398                	ld	a4,0(a5)
 c38:	e118                	sd	a4,0(a0)
 c3a:	bff1                	j	c16 <malloc+0x86>
  hp->s.size = nu;
 c3c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c40:	0541                	addi	a0,a0,16
 c42:	00000097          	auipc	ra,0x0
 c46:	ec6080e7          	jalr	-314(ra) # b08 <free>
  return freep;
 c4a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c4e:	d971                	beqz	a0,c22 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c50:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c52:	4798                	lw	a4,8(a5)
 c54:	fa9776e3          	bgeu	a4,s1,c00 <malloc+0x70>
    if(p == freep)
 c58:	00093703          	ld	a4,0(s2)
 c5c:	853e                	mv	a0,a5
 c5e:	fef719e3          	bne	a4,a5,c50 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 c62:	8552                	mv	a0,s4
 c64:	00000097          	auipc	ra,0x0
 c68:	b66080e7          	jalr	-1178(ra) # 7ca <sbrk>
  if(p == (char*)-1)
 c6c:	fd5518e3          	bne	a0,s5,c3c <malloc+0xac>
        return 0;
 c70:	4501                	li	a0,0
 c72:	bf45                	j	c22 <malloc+0x92>
