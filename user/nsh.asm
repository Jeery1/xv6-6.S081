
user/_nsh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <evaluate>:
/******************* 处理cmd ******************/
void 
evaluate(cmd *parsedcmd){
  int pd[2];

  if(parsedcmd->type == NULLcmd){
   0:	411c                	lw	a5,0(a0)
   2:	470d                	li	a4,3
   4:	12e78363          	beq	a5,a4,12a <evaluate+0x12a>
evaluate(cmd *parsedcmd){
   8:	7179                	addi	sp,sp,-48
   a:	f406                	sd	ra,40(sp)
   c:	f022                	sd	s0,32(sp)
   e:	ec26                	sd	s1,24(sp)
  10:	1800                	addi	s0,sp,48
  12:	84aa                	mv	s1,a0
    return ;
  }
  
  switch (parsedcmd->type)
  14:	4705                	li	a4,1
  16:	0ae78d63          	beq	a5,a4,d0 <evaluate+0xd0>
  1a:	4709                	li	a4,2
  1c:	00e78863          	beq	a5,a4,2c <evaluate+0x2c>
  20:	c3c5                	beqz	a5,c0 <evaluate+0xc0>
    break;
  default:
    break;
  }
  
}
  22:	70a2                	ld	ra,40(sp)
  24:	7402                	ld	s0,32(sp)
  26:	64e2                	ld	s1,24(sp)
  28:	6145                	addi	sp,sp,48
  2a:	8082                	ret
    pipe(pd);
  2c:	fd840513          	addi	a0,s0,-40
  30:	00001097          	auipc	ra,0x1
  34:	906080e7          	jalr	-1786(ra) # 936 <pipe>
    if(fork() == 0){
  38:	00001097          	auipc	ra,0x1
  3c:	8e6080e7          	jalr	-1818(ra) # 91e <fork>
  40:	e139                	bnez	a0,86 <evaluate+0x86>
      close(1);
  42:	4505                	li	a0,1
  44:	00001097          	auipc	ra,0x1
  48:	90a080e7          	jalr	-1782(ra) # 94e <close>
      dup(pd[1]);
  4c:	fdc42503          	lw	a0,-36(s0)
  50:	00001097          	auipc	ra,0x1
  54:	94e080e7          	jalr	-1714(ra) # 99e <dup>
      close(pd[0]);
  58:	fd842503          	lw	a0,-40(s0)
  5c:	00001097          	auipc	ra,0x1
  60:	8f2080e7          	jalr	-1806(ra) # 94e <close>
      close(pd[1]);
  64:	fdc42503          	lw	a0,-36(s0)
  68:	00001097          	auipc	ra,0x1
  6c:	8e6080e7          	jalr	-1818(ra) # 94e <close>
      evaluate(parsedcmd->cmdcontent.pipecmd.leftcmd);
  70:	6488                	ld	a0,8(s1)
  72:	00000097          	auipc	ra,0x0
  76:	f8e080e7          	jalr	-114(ra) # 0 <evaluate>
    wait(0);
  7a:	4501                	li	a0,0
  7c:	00001097          	auipc	ra,0x1
  80:	8b2080e7          	jalr	-1870(ra) # 92e <wait>
    break;
  84:	bf79                	j	22 <evaluate+0x22>
      close(0);
  86:	4501                	li	a0,0
  88:	00001097          	auipc	ra,0x1
  8c:	8c6080e7          	jalr	-1850(ra) # 94e <close>
      dup(pd[0]);
  90:	fd842503          	lw	a0,-40(s0)
  94:	00001097          	auipc	ra,0x1
  98:	90a080e7          	jalr	-1782(ra) # 99e <dup>
      close(pd[0]);
  9c:	fd842503          	lw	a0,-40(s0)
  a0:	00001097          	auipc	ra,0x1
  a4:	8ae080e7          	jalr	-1874(ra) # 94e <close>
      close(pd[1]);
  a8:	fdc42503          	lw	a0,-36(s0)
  ac:	00001097          	auipc	ra,0x1
  b0:	8a2080e7          	jalr	-1886(ra) # 94e <close>
      evaluate(parsedcmd->cmdcontent.pipecmd.rightcmd);
  b4:	6888                	ld	a0,16(s1)
  b6:	00000097          	auipc	ra,0x0
  ba:	f4a080e7          	jalr	-182(ra) # 0 <evaluate>
  be:	bf75                	j	7a <evaluate+0x7a>
    exec(parsedcmd->cmdcontent.execcmd.argv[0], parsedcmd->cmdcontent.execcmd.argv);
  c0:	00850593          	addi	a1,a0,8
  c4:	6508                	ld	a0,8(a0)
  c6:	00001097          	auipc	ra,0x1
  ca:	898080e7          	jalr	-1896(ra) # 95e <exec>
    break;
  ce:	bf91                	j	22 <evaluate+0x22>
    close(parsedcmd->cmdcontent.redircmd.fd);
  d0:	4d48                	lw	a0,28(a0)
  d2:	00001097          	auipc	ra,0x1
  d6:	87c080e7          	jalr	-1924(ra) # 94e <close>
    if(open(parsedcmd->cmdcontent.redircmd.file, parsedcmd->cmdcontent.redircmd.mode) < 0){
  da:	548c                	lw	a1,40(s1)
  dc:	7088                	ld	a0,32(s1)
  de:	00001097          	auipc	ra,0x1
  e2:	888080e7          	jalr	-1912(ra) # 966 <open>
  e6:	00054d63          	bltz	a0,100 <evaluate+0x100>
    if(parsedcmd->cmdcontent.redircmd.redirtype == File2stdin){
  ea:	4c9c                	lw	a5,24(s1)
  ec:	4705                	li	a4,1
  ee:	02e78863          	beq	a5,a4,11e <evaluate+0x11e>
    else if(parsedcmd->cmdcontent.redircmd.redirtype == Stdout2file)
  f2:	fb85                	bnez	a5,22 <evaluate+0x22>
      evaluate(parsedcmd->cmdcontent.redircmd.stdoutcmd);
  f4:	6888                	ld	a0,16(s1)
  f6:	00000097          	auipc	ra,0x0
  fa:	f0a080e7          	jalr	-246(ra) # 0 <evaluate>
  fe:	b715                	j	22 <evaluate+0x22>
      fprintf(2, "open %s failed\n", parsedcmd->cmdcontent.redircmd.file);
 100:	7090                	ld	a2,32(s1)
 102:	00001597          	auipc	a1,0x1
 106:	d4658593          	addi	a1,a1,-698 # e48 <malloc+0xe4>
 10a:	4509                	li	a0,2
 10c:	00001097          	auipc	ra,0x1
 110:	b6c080e7          	jalr	-1172(ra) # c78 <fprintf>
      exit(-1);
 114:	557d                	li	a0,-1
 116:	00001097          	auipc	ra,0x1
 11a:	810080e7          	jalr	-2032(ra) # 926 <exit>
      evaluate(parsedcmd->cmdcontent.redircmd.stdincmd);
 11e:	6488                	ld	a0,8(s1)
 120:	00000097          	auipc	ra,0x0
 124:	ee0080e7          	jalr	-288(ra) # 0 <evaluate>
 128:	bded                	j	22 <evaluate+0x22>
 12a:	8082                	ret

000000000000012c <init>:
  }
  return &cmdstack[currentstackpointer];
}

void 
init(){
 12c:	1141                	addi	sp,sp,-16
 12e:	e406                	sd	ra,8(sp)
 130:	e022                	sd	s0,0(sp)
 132:	0800                	addi	s0,sp,16
  memset(tokens, 0, sizeof(tokens));
 134:	50000613          	li	a2,1280
 138:	4581                	li	a1,0
 13a:	00001517          	auipc	a0,0x1
 13e:	d7650513          	addi	a0,a0,-650 # eb0 <tokens>
 142:	00000097          	auipc	ra,0x0
 146:	5e8080e7          	jalr	1512(ra) # 72a <memset>
  memset(files, 0, sizeof(files));
 14a:	50000613          	li	a2,1280
 14e:	4581                	li	a1,0
 150:	00001517          	auipc	a0,0x1
 154:	26050513          	addi	a0,a0,608 # 13b0 <files>
 158:	00000097          	auipc	ra,0x0
 15c:	5d2080e7          	jalr	1490(ra) # 72a <memset>
  memset(cmdstack, 0, sizeof(cmdstack));
 160:	6609                	lui	a2,0x2
 162:	26060613          	addi	a2,a2,608 # 2260 <cmdstack+0x958>
 166:	4581                	li	a1,0
 168:	00001517          	auipc	a0,0x1
 16c:	7a050513          	addi	a0,a0,1952 # 1908 <cmdstack>
 170:	00000097          	auipc	ra,0x0
 174:	5ba080e7          	jalr	1466(ra) # 72a <memset>
  for (int i = 0; i < MAXSTACKSIZ; i++)
 178:	00001797          	auipc	a5,0x1
 17c:	79078793          	addi	a5,a5,1936 # 1908 <cmdstack>
 180:	00004697          	auipc	a3,0x4
 184:	9e868693          	addi	a3,a3,-1560 # 3b68 <base>
  {
    /* code */
    cmdstack[i].type = NULLcmd;
 188:	470d                	li	a4,3
 18a:	c398                	sw	a4,0(a5)
  for (int i = 0; i < MAXSTACKSIZ; i++)
 18c:	05878793          	addi	a5,a5,88
 190:	fed79de3          	bne	a5,a3,18a <init+0x5e>
  }
}
 194:	60a2                	ld	ra,8(sp)
 196:	6402                	ld	s0,0(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret

000000000000019c <allocatestack>:
/* 分配栈 */
int
allocatestack(){
 19c:	1141                	addi	sp,sp,-16
 19e:	e422                	sd	s0,8(sp)
 1a0:	0800                	addi	s0,sp,16
  int newpointer = 0;
  while(cmdstack[newpointer].type != NULLcmd) newpointer++;
 1a2:	00001717          	auipc	a4,0x1
 1a6:	76672703          	lw	a4,1894(a4) # 1908 <cmdstack>
 1aa:	478d                	li	a5,3
 1ac:	02f70263          	beq	a4,a5,1d0 <allocatestack+0x34>
 1b0:	00001797          	auipc	a5,0x1
 1b4:	7b078793          	addi	a5,a5,1968 # 1960 <cmdstack+0x58>
  int newpointer = 0;
 1b8:	4501                	li	a0,0
  while(cmdstack[newpointer].type != NULLcmd) newpointer++;
 1ba:	468d                	li	a3,3
 1bc:	2505                	addiw	a0,a0,1
 1be:	05878793          	addi	a5,a5,88
 1c2:	fa87a703          	lw	a4,-88(a5)
 1c6:	fed71be3          	bne	a4,a3,1bc <allocatestack+0x20>
  return newpointer;
}
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret
  int newpointer = 0;
 1d0:	4501                	li	a0,0
 1d2:	bfe5                	j	1ca <allocatestack+0x2e>

00000000000001d4 <allocatetokens>:

int
allocatetokens(){
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e422                	sd	s0,8(sp)
 1d8:	0800                	addi	s0,sp,16
  int newpointer = 0;
  while(tokens[newpointer][0] != 0) newpointer++;
 1da:	00001797          	auipc	a5,0x1
 1de:	cd67c783          	lbu	a5,-810(a5) # eb0 <tokens>
 1e2:	cf99                	beqz	a5,200 <allocatetokens+0x2c>
 1e4:	00001797          	auipc	a5,0x1
 1e8:	ccc78793          	addi	a5,a5,-820 # eb0 <tokens>
  int newpointer = 0;
 1ec:	4501                	li	a0,0
  while(tokens[newpointer][0] != 0) newpointer++;
 1ee:	2505                	addiw	a0,a0,1
 1f0:	08078793          	addi	a5,a5,128
 1f4:	0007c703          	lbu	a4,0(a5)
 1f8:	fb7d                	bnez	a4,1ee <allocatetokens+0x1a>
  return newpointer;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret
  int newpointer = 0;
 200:	4501                	li	a0,0
 202:	bfe5                	j	1fa <allocatetokens+0x26>

0000000000000204 <allocatefiles>:

int
allocatefiles(){
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  int newpointer = 0;
  while(files[newpointer][0] != 0) newpointer++;
 20a:	00001797          	auipc	a5,0x1
 20e:	1a67c783          	lbu	a5,422(a5) # 13b0 <files>
 212:	cf99                	beqz	a5,230 <allocatefiles+0x2c>
 214:	00001797          	auipc	a5,0x1
 218:	19c78793          	addi	a5,a5,412 # 13b0 <files>
  int newpointer = 0;
 21c:	4501                	li	a0,0
  while(files[newpointer][0] != 0) newpointer++;
 21e:	2505                	addiw	a0,a0,1
 220:	08078793          	addi	a5,a5,128
 224:	0007c703          	lbu	a4,0(a5)
 228:	fb7d                	bnez	a4,21e <allocatefiles+0x1a>
  return newpointer;
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret
  int newpointer = 0;
 230:	4501                	li	a0,0
 232:	bfe5                	j	22a <allocatefiles+0x26>

0000000000000234 <preprocessCmd>:

/* 去掉回车符 */
void
preprocessCmd(char *cmd){
 234:	1101                	addi	sp,sp,-32
 236:	ec06                	sd	ra,24(sp)
 238:	e822                	sd	s0,16(sp)
 23a:	e426                	sd	s1,8(sp)
 23c:	1000                	addi	s0,sp,32
 23e:	84aa                	mv	s1,a0
  int n = strlen(cmd);
 240:	00000097          	auipc	ra,0x0
 244:	4c0080e7          	jalr	1216(ra) # 700 <strlen>
 248:	0005079b          	sext.w	a5,a0
  if(n > MAXBUFSIZ){
 24c:	10000713          	li	a4,256
 250:	00f74e63          	blt	a4,a5,26c <preprocessCmd+0x38>
      exit(0);
  }
  else
  {
      /* code */
      if(cmd[n - 1] == '\n'){
 254:	17fd                	addi	a5,a5,-1
 256:	97a6                	add	a5,a5,s1
 258:	0007c683          	lbu	a3,0(a5)
 25c:	4729                	li	a4,10
 25e:	02e68463          	beq	a3,a4,286 <preprocessCmd+0x52>
          cmd[n - 1] = '\0';
      }
  }
}
 262:	60e2                	ld	ra,24(sp)
 264:	6442                	ld	s0,16(sp)
 266:	64a2                	ld	s1,8(sp)
 268:	6105                	addi	sp,sp,32
 26a:	8082                	ret
      printf("command too long!");
 26c:	00001517          	auipc	a0,0x1
 270:	bec50513          	addi	a0,a0,-1044 # e58 <malloc+0xf4>
 274:	00001097          	auipc	ra,0x1
 278:	a32080e7          	jalr	-1486(ra) # ca6 <printf>
      exit(0);
 27c:	4501                	li	a0,0
 27e:	00000097          	auipc	ra,0x0
 282:	6a8080e7          	jalr	1704(ra) # 926 <exit>
          cmd[n - 1] = '\0';
 286:	00078023          	sb	zero,0(a5)
}
 28a:	bfe1                	j	262 <preprocessCmd+0x2e>

000000000000028c <parsetoken>:

/************************* Utils **************************/
void parsetoken(char **token, char *endoftoken, char *parsedtoken){
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  //printf("gettoken: ");
  char *s = *token;
 292:	611c                	ld	a5,0(a0)
  for (; s < endoftoken; s++)
 294:	02b7f263          	bgeu	a5,a1,2b8 <parsetoken+0x2c>
 298:	8d9d                	sub	a1,a1,a5
 29a:	00b60733          	add	a4,a2,a1
  {
    *(parsedtoken++) = *s;
 29e:	0605                	addi	a2,a2,1
 2a0:	0007c683          	lbu	a3,0(a5)
 2a4:	fed60fa3          	sb	a3,-1(a2)
  for (; s < endoftoken; s++)
 2a8:	0785                	addi	a5,a5,1
 2aa:	fee61ae3          	bne	a2,a4,29e <parsetoken+0x12>
    //printf("%c", *s);
  }
  *parsedtoken = '\0';
 2ae:	00070023          	sb	zero,0(a4)
  //printf("\n");
}
 2b2:	6422                	ld	s0,8(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret
  for (; s < endoftoken; s++)
 2b8:	8732                	mv	a4,a2
 2ba:	bfd5                	j	2ae <parsetoken+0x22>

00000000000002bc <gettoken>:

int
gettoken(char **ps, char *es, int startpos, char **token, char **endoftoken)
{
 2bc:	7139                	addi	sp,sp,-64
 2be:	fc06                	sd	ra,56(sp)
 2c0:	f822                	sd	s0,48(sp)
 2c2:	f426                	sd	s1,40(sp)
 2c4:	f04a                	sd	s2,32(sp)
 2c6:	ec4e                	sd	s3,24(sp)
 2c8:	e852                	sd	s4,16(sp)
 2ca:	e456                	sd	s5,8(sp)
 2cc:	e05a                	sd	s6,0(sp)
 2ce:	0080                	addi	s0,sp,64
 2d0:	89ae                	mv	s3,a1
 2d2:	8932                	mv	s2,a2
 2d4:	8b36                	mv	s6,a3
 2d6:	8aba                	mv	s5,a4
  char *s;
  int pos = startpos;
  s = *ps + startpos;
 2d8:	6104                	ld	s1,0(a0)
 2da:	94b2                	add	s1,s1,a2
  /* 清理所有s的空格 trim */
  while(s < es && strchr(whitespace, *s)){
 2dc:	00001a17          	auipc	s4,0x1
 2e0:	bc4a0a13          	addi	s4,s4,-1084 # ea0 <whitespace>
 2e4:	00b4fe63          	bgeu	s1,a1,300 <gettoken+0x44>
 2e8:	0004c583          	lbu	a1,0(s1)
 2ec:	8552                	mv	a0,s4
 2ee:	00000097          	auipc	ra,0x0
 2f2:	45e080e7          	jalr	1118(ra) # 74c <strchr>
 2f6:	c909                	beqz	a0,308 <gettoken+0x4c>
    s++;
 2f8:	0485                	addi	s1,s1,1
    pos++;
 2fa:	2905                	addiw	s2,s2,1
  while(s < es && strchr(whitespace, *s)){
 2fc:	fe9996e3          	bne	s3,s1,2e8 <gettoken+0x2c>
  }
  *token = s;
 300:	009b3023          	sd	s1,0(s6)
 304:	854a                	mv	a0,s2
 306:	a80d                	j	338 <gettoken+0x7c>
 308:	009b3023          	sd	s1,0(s6)
  while (s < es && !strchr(whitespace, *s))
 30c:	00001a17          	auipc	s4,0x1
 310:	b94a0a13          	addi	s4,s4,-1132 # ea0 <whitespace>
 314:	854a                	mv	a0,s2
 316:	0334f163          	bgeu	s1,s3,338 <gettoken+0x7c>
 31a:	0004c583          	lbu	a1,0(s1)
 31e:	8552                	mv	a0,s4
 320:	00000097          	auipc	ra,0x0
 324:	42c080e7          	jalr	1068(ra) # 74c <strchr>
 328:	e519                	bnez	a0,336 <gettoken+0x7a>
  {
    /* code */
    s++;
 32a:	0485                	addi	s1,s1,1
    pos++;
 32c:	2905                	addiw	s2,s2,1
  while (s < es && !strchr(whitespace, *s))
 32e:	fe9996e3          	bne	s3,s1,31a <gettoken+0x5e>
    pos++;
 332:	854a                	mv	a0,s2
 334:	a011                	j	338 <gettoken+0x7c>
 336:	854a                	mv	a0,s2
  }
  *endoftoken = s;
 338:	009ab023          	sd	s1,0(s5)
  return pos;
}  
 33c:	70e2                	ld	ra,56(sp)
 33e:	7442                	ld	s0,48(sp)
 340:	74a2                	ld	s1,40(sp)
 342:	7902                	ld	s2,32(sp)
 344:	69e2                	ld	s3,24(sp)
 346:	6a42                	ld	s4,16(sp)
 348:	6aa2                	ld	s5,8(sp)
 34a:	6b02                	ld	s6,0(sp)
 34c:	6121                	addi	sp,sp,64
 34e:	8082                	ret

0000000000000350 <parsecmd>:
parsecmd(char *_cmd, char *_endofcmd, int currentstackpointer){
 350:	7159                	addi	sp,sp,-112
 352:	f486                	sd	ra,104(sp)
 354:	f0a2                	sd	s0,96(sp)
 356:	eca6                	sd	s1,88(sp)
 358:	e8ca                	sd	s2,80(sp)
 35a:	e4ce                	sd	s3,72(sp)
 35c:	e0d2                	sd	s4,64(sp)
 35e:	fc56                	sd	s5,56(sp)
 360:	f85a                	sd	s6,48(sp)
 362:	f45e                	sd	s7,40(sp)
 364:	f062                	sd	s8,32(sp)
 366:	1880                	addi	s0,sp,112
 368:	f8a43c23          	sd	a0,-104(s0)
 36c:	8a2e                	mv	s4,a1
 36e:	89b2                	mv	s3,a2
  for(; s >= _cmd; s--){
 370:	8b2a                	mv	s6,a0
 372:	02a5e863          	bltu	a1,a0,3a2 <parsecmd+0x52>
  s = _endofcmd;
 376:	84ae                	mv	s1,a1
    if (*s == '|')
 378:	07c00713          	li	a4,124
 37c:	0004c783          	lbu	a5,0(s1)
 380:	04e78d63          	beq	a5,a4,3da <parsecmd+0x8a>
  for(; s >= _cmd; s--){
 384:	14fd                	addi	s1,s1,-1
 386:	ff64fbe3          	bgeu	s1,s6,37c <parsecmd+0x2c>
 38a:	84d2                	mv	s1,s4
      if (*s == '<' || *s == '>')
 38c:	03c00713          	li	a4,60
 390:	0004c783          	lbu	a5,0(s1)
 394:	0fd7f793          	andi	a5,a5,253
 398:	0ae78e63          	beq	a5,a4,454 <parsecmd+0x104>
    for (; s >= _cmd; s--)
 39c:	14fd                	addi	s1,s1,-1
 39e:	ff64f9e3          	bgeu	s1,s6,390 <parsecmd+0x40>
      cmdstack[currentstackpointer].type = Execcmd;
 3a2:	05800793          	li	a5,88
 3a6:	02f98733          	mul	a4,s3,a5
 3aa:	00001797          	auipc	a5,0x1
 3ae:	55e78793          	addi	a5,a5,1374 # 1908 <cmdstack>
 3b2:	97ba                	add	a5,a5,a4
 3b4:	0007a023          	sw	zero,0(a5)
      int totallen = _endofcmd - _cmd;
 3b8:	416a0b3b          	subw	s6,s4,s6
      while (startpos < totallen)
 3bc:	21605a63          	blez	s6,5d0 <parsecmd+0x280>
      int count = 0;
 3c0:	4a81                	li	s5,0
      int startpos = 0;
 3c2:	4481                	li	s1,0
          parsetoken(&token, endoftoken, tokens[pos]);
 3c4:	00001c17          	auipc	s8,0x1
 3c8:	aecc0c13          	addi	s8,s8,-1300 # eb0 <tokens>
          cmdstack[currentstackpointer].cmdcontent.execcmd.argv[count] = tokens[pos];
 3cc:	00199b93          	slli	s7,s3,0x1
 3d0:	9bce                	add	s7,s7,s3
 3d2:	0b8a                	slli	s7,s7,0x2
 3d4:	413b8bb3          	sub	s7,s7,s3
 3d8:	aa51                	j	56c <parsecmd+0x21c>
      cmdstack[currentstackpointer].type = Pipecmd;
 3da:	05800a93          	li	s5,88
 3de:	035987b3          	mul	a5,s3,s5
 3e2:	00001a97          	auipc	s5,0x1
 3e6:	526a8a93          	addi	s5,s5,1318 # 1908 <cmdstack>
 3ea:	9abe                	add	s5,s5,a5
 3ec:	4789                	li	a5,2
 3ee:	00faa023          	sw	a5,0(s5)
      cmdstack[currentstackpointer].cmdcontent.pipecmd.leftcmd = parsecmd(_cmd, s - 1, allocatestack());
 3f2:	00000097          	auipc	ra,0x0
 3f6:	daa080e7          	jalr	-598(ra) # 19c <allocatestack>
 3fa:	862a                	mv	a2,a0
 3fc:	fff48593          	addi	a1,s1,-1
 400:	855a                	mv	a0,s6
 402:	00000097          	auipc	ra,0x0
 406:	f4e080e7          	jalr	-178(ra) # 350 <parsecmd>
 40a:	00aab423          	sd	a0,8(s5)
      cmdstack[currentstackpointer].cmdcontent.pipecmd.rightcmd = parsecmd(s + 1, _endofcmd, allocatestack());
 40e:	00000097          	auipc	ra,0x0
 412:	d8e080e7          	jalr	-626(ra) # 19c <allocatestack>
 416:	862a                	mv	a2,a0
 418:	85d2                	mv	a1,s4
 41a:	00148513          	addi	a0,s1,1
 41e:	00000097          	auipc	ra,0x0
 422:	f32080e7          	jalr	-206(ra) # 350 <parsecmd>
 426:	00aab823          	sd	a0,16(s5)
  return &cmdstack[currentstackpointer];
 42a:	05800513          	li	a0,88
 42e:	02a989b3          	mul	s3,s3,a0
}
 432:	00001517          	auipc	a0,0x1
 436:	4d650513          	addi	a0,a0,1238 # 1908 <cmdstack>
 43a:	954e                	add	a0,a0,s3
 43c:	70a6                	ld	ra,104(sp)
 43e:	7406                	ld	s0,96(sp)
 440:	64e6                	ld	s1,88(sp)
 442:	6946                	ld	s2,80(sp)
 444:	69a6                	ld	s3,72(sp)
 446:	6a06                	ld	s4,64(sp)
 448:	7ae2                	ld	s5,56(sp)
 44a:	7b42                	ld	s6,48(sp)
 44c:	7ba2                	ld	s7,40(sp)
 44e:	7c02                	ld	s8,32(sp)
 450:	6165                	addi	sp,sp,112
 452:	8082                	ret
        cmdstack[currentstackpointer].type = Redircmd;
 454:	05800793          	li	a5,88
 458:	02f98733          	mul	a4,s3,a5
 45c:	00001797          	auipc	a5,0x1
 460:	4ac78793          	addi	a5,a5,1196 # 1908 <cmdstack>
 464:	97ba                	add	a5,a5,a4
 466:	4705                	li	a4,1
 468:	c398                	sw	a4,0(a5)
        if(*s == '<'){
 46a:	0004c703          	lbu	a4,0(s1)
 46e:	03c00793          	li	a5,60
 472:	0af70663          	beq	a4,a5,51e <parsecmd+0x1ce>
          cmdstack[currentstackpointer].cmdcontent.redircmd.redirtype = Stdout2file;
 476:	05800a93          	li	s5,88
 47a:	035987b3          	mul	a5,s3,s5
 47e:	00001a97          	auipc	s5,0x1
 482:	48aa8a93          	addi	s5,s5,1162 # 1908 <cmdstack>
 486:	9abe                	add	s5,s5,a5
 488:	000aac23          	sw	zero,24(s5)
          cmdstack[currentstackpointer].cmdcontent.redircmd.fd = 1;
 48c:	4785                	li	a5,1
 48e:	00faae23          	sw	a5,28(s5)
          cmdstack[currentstackpointer].cmdcontent.redircmd.stdincmd = &nullcmd;
 492:	00001797          	auipc	a5,0x1
 496:	41e78793          	addi	a5,a5,1054 # 18b0 <nullcmd>
 49a:	00fab423          	sd	a5,8(s5)
          cmdstack[currentstackpointer].cmdcontent.redircmd.stdoutcmd = parsecmd(_cmd, s - 1, allocatestack());
 49e:	00000097          	auipc	ra,0x0
 4a2:	cfe080e7          	jalr	-770(ra) # 19c <allocatestack>
 4a6:	862a                	mv	a2,a0
 4a8:	fff48593          	addi	a1,s1,-1
 4ac:	855a                	mv	a0,s6
 4ae:	00000097          	auipc	ra,0x0
 4b2:	ea2080e7          	jalr	-350(ra) # 350 <parsecmd>
 4b6:	00aab823          	sd	a0,16(s5)
          cmdstack[currentstackpointer].cmdcontent.redircmd.mode = O_WRONLY|O_CREATE;
 4ba:	20100793          	li	a5,513
 4be:	02faa423          	sw	a5,40(s5)
        gettoken(&_cmd, _endofcmd,  s - _cmd + 1, &file, &endoffile);
 4c2:	f9843603          	ld	a2,-104(s0)
 4c6:	40c48633          	sub	a2,s1,a2
 4ca:	fa840713          	addi	a4,s0,-88
 4ce:	fa040693          	addi	a3,s0,-96
 4d2:	2605                	addiw	a2,a2,1
 4d4:	85d2                	mv	a1,s4
 4d6:	f9840513          	addi	a0,s0,-104
 4da:	00000097          	auipc	ra,0x0
 4de:	de2080e7          	jalr	-542(ra) # 2bc <gettoken>
        int pos = allocatefiles();
 4e2:	00000097          	auipc	ra,0x0
 4e6:	d22080e7          	jalr	-734(ra) # 204 <allocatefiles>
        parsetoken(&file, endoffile, files[pos]);
 4ea:	051e                	slli	a0,a0,0x7
 4ec:	00001497          	auipc	s1,0x1
 4f0:	ec448493          	addi	s1,s1,-316 # 13b0 <files>
 4f4:	94aa                	add	s1,s1,a0
 4f6:	8626                	mv	a2,s1
 4f8:	fa843583          	ld	a1,-88(s0)
 4fc:	fa040513          	addi	a0,s0,-96
 500:	00000097          	auipc	ra,0x0
 504:	d8c080e7          	jalr	-628(ra) # 28c <parsetoken>
        cmdstack[currentstackpointer].cmdcontent.redircmd.file = files[pos]; 
 508:	05800793          	li	a5,88
 50c:	02f98733          	mul	a4,s3,a5
 510:	00001797          	auipc	a5,0x1
 514:	3f878793          	addi	a5,a5,1016 # 1908 <cmdstack>
 518:	97ba                	add	a5,a5,a4
 51a:	f384                	sd	s1,32(a5)
    if(isexec){
 51c:	b739                	j	42a <parsecmd+0xda>
          cmdstack[currentstackpointer].cmdcontent.redircmd.redirtype = File2stdin;
 51e:	05800793          	li	a5,88
 522:	02f987b3          	mul	a5,s3,a5
 526:	00001a97          	auipc	s5,0x1
 52a:	3e2a8a93          	addi	s5,s5,994 # 1908 <cmdstack>
 52e:	9abe                	add	s5,s5,a5
 530:	4785                	li	a5,1
 532:	00faac23          	sw	a5,24(s5)
          cmdstack[currentstackpointer].cmdcontent.redircmd.fd = 0;
 536:	000aae23          	sw	zero,28(s5)
          cmdstack[currentstackpointer].cmdcontent.redircmd.stdincmd = parsecmd(_cmd, s - 1, allocatestack());
 53a:	00000097          	auipc	ra,0x0
 53e:	c62080e7          	jalr	-926(ra) # 19c <allocatestack>
 542:	862a                	mv	a2,a0
 544:	fff48593          	addi	a1,s1,-1
 548:	855a                	mv	a0,s6
 54a:	00000097          	auipc	ra,0x0
 54e:	e06080e7          	jalr	-506(ra) # 350 <parsecmd>
 552:	00aab423          	sd	a0,8(s5)
          cmdstack[currentstackpointer].cmdcontent.redircmd.stdoutcmd = &nullcmd;
 556:	00001797          	auipc	a5,0x1
 55a:	35a78793          	addi	a5,a5,858 # 18b0 <nullcmd>
 55e:	00fab823          	sd	a5,16(s5)
          cmdstack[currentstackpointer].cmdcontent.redircmd.mode = O_RDONLY;
 562:	020aa423          	sw	zero,40(s5)
 566:	bfb1                	j	4c2 <parsecmd+0x172>
      while (startpos < totallen)
 568:	0764d563          	bge	s1,s6,5d2 <parsecmd+0x282>
        startpos = gettoken(&_cmd, _endofcmd, startpos, &token, &endoftoken);
 56c:	fa840713          	addi	a4,s0,-88
 570:	fa040693          	addi	a3,s0,-96
 574:	8626                	mv	a2,s1
 576:	85d2                	mv	a1,s4
 578:	f9840513          	addi	a0,s0,-104
 57c:	00000097          	auipc	ra,0x0
 580:	d40080e7          	jalr	-704(ra) # 2bc <gettoken>
 584:	84aa                	mv	s1,a0
        if(*token != ' '){
 586:	fa043783          	ld	a5,-96(s0)
 58a:	0007c703          	lbu	a4,0(a5)
 58e:	02000793          	li	a5,32
 592:	fcf70be3          	beq	a4,a5,568 <parsecmd+0x218>
          int pos = allocatetokens();
 596:	00000097          	auipc	ra,0x0
 59a:	c3e080e7          	jalr	-962(ra) # 1d4 <allocatetokens>
          parsetoken(&token, endoftoken, tokens[pos]);
 59e:	00751913          	slli	s2,a0,0x7
 5a2:	9962                	add	s2,s2,s8
 5a4:	864a                	mv	a2,s2
 5a6:	fa843583          	ld	a1,-88(s0)
 5aa:	fa040513          	addi	a0,s0,-96
 5ae:	00000097          	auipc	ra,0x0
 5b2:	cde080e7          	jalr	-802(ra) # 28c <parsetoken>
          cmdstack[currentstackpointer].cmdcontent.execcmd.argv[count] = tokens[pos];
 5b6:	015b87b3          	add	a5,s7,s5
 5ba:	00379713          	slli	a4,a5,0x3
 5be:	00001797          	auipc	a5,0x1
 5c2:	34a78793          	addi	a5,a5,842 # 1908 <cmdstack>
 5c6:	97ba                	add	a5,a5,a4
 5c8:	0127b423          	sd	s2,8(a5)
          count++;
 5cc:	2a85                	addiw	s5,s5,1
 5ce:	bf69                	j	568 <parsecmd+0x218>
      int count = 0;
 5d0:	4a81                	li	s5,0
      cmdstack[currentstackpointer].cmdcontent.execcmd.argv[count] = 0;
 5d2:	00199793          	slli	a5,s3,0x1
 5d6:	97ce                	add	a5,a5,s3
 5d8:	078a                	slli	a5,a5,0x2
 5da:	413787b3          	sub	a5,a5,s3
 5de:	9abe                	add	s5,s5,a5
 5e0:	0a8e                	slli	s5,s5,0x3
 5e2:	00001797          	auipc	a5,0x1
 5e6:	32678793          	addi	a5,a5,806 # 1908 <cmdstack>
 5ea:	9abe                	add	s5,s5,a5
 5ec:	000ab423          	sd	zero,8(s5)
 5f0:	bd2d                	j	42a <parsecmd+0xda>

00000000000005f2 <main>:
main() { 
 5f2:	712d                	addi	sp,sp,-288
 5f4:	ee06                	sd	ra,280(sp)
 5f6:	ea22                	sd	s0,272(sp)
 5f8:	e626                	sd	s1,264(sp)
 5fa:	e24a                	sd	s2,256(sp)
 5fc:	1200                	addi	s0,sp,288
  nullcmd.type = NULLcmd;
 5fe:	478d                	li	a5,3
 600:	00001717          	auipc	a4,0x1
 604:	2af72823          	sw	a5,688(a4) # 18b0 <nullcmd>
      printf("@ ");
 608:	00001917          	auipc	s2,0x1
 60c:	86890913          	addi	s2,s2,-1944 # e70 <malloc+0x10c>
 610:	a819                	j	626 <main+0x34>
          exit(0);
 612:	4501                	li	a0,0
 614:	00000097          	auipc	ra,0x0
 618:	312080e7          	jalr	786(ra) # 926 <exit>
      wait(0);
 61c:	4501                	li	a0,0
 61e:	00000097          	auipc	ra,0x0
 622:	310080e7          	jalr	784(ra) # 92e <wait>
      memset(_cmd, 0, sizeof(_cmd));
 626:	10000613          	li	a2,256
 62a:	4581                	li	a1,0
 62c:	ee040513          	addi	a0,s0,-288
 630:	00000097          	auipc	ra,0x0
 634:	0fa080e7          	jalr	250(ra) # 72a <memset>
      printf("@ ");
 638:	854a                	mv	a0,s2
 63a:	00000097          	auipc	ra,0x0
 63e:	66c080e7          	jalr	1644(ra) # ca6 <printf>
      gets(_cmd, MAXBUFSIZ);
 642:	10000593          	li	a1,256
 646:	ee040513          	addi	a0,s0,-288
 64a:	00000097          	auipc	ra,0x0
 64e:	126080e7          	jalr	294(ra) # 770 <gets>
      preprocessCmd(_cmd);
 652:	ee040513          	addi	a0,s0,-288
 656:	00000097          	auipc	ra,0x0
 65a:	bde080e7          	jalr	-1058(ra) # 234 <preprocessCmd>
      if(strlen(_cmd) == 0 || _cmd[0] == 0){
 65e:	ee040513          	addi	a0,s0,-288
 662:	00000097          	auipc	ra,0x0
 666:	09e080e7          	jalr	158(ra) # 700 <strlen>
 66a:	2501                	sext.w	a0,a0
 66c:	d15d                	beqz	a0,612 <main+0x20>
 66e:	ee044783          	lbu	a5,-288(s0)
 672:	d3c5                	beqz	a5,612 <main+0x20>
      init();
 674:	00000097          	auipc	ra,0x0
 678:	ab8080e7          	jalr	-1352(ra) # 12c <init>
      endofcmd = _cmd + strlen(_cmd);
 67c:	ee040513          	addi	a0,s0,-288
 680:	00000097          	auipc	ra,0x0
 684:	080080e7          	jalr	128(ra) # 700 <strlen>
 688:	02051593          	slli	a1,a0,0x20
 68c:	9181                	srli	a1,a1,0x20
      cmd* parsedcmd = parsecmd(_cmd, endofcmd, 0);
 68e:	4601                	li	a2,0
 690:	ee040793          	addi	a5,s0,-288
 694:	95be                	add	a1,a1,a5
 696:	853e                	mv	a0,a5
 698:	00000097          	auipc	ra,0x0
 69c:	cb8080e7          	jalr	-840(ra) # 350 <parsecmd>
 6a0:	84aa                	mv	s1,a0
      if(fork() == 0)
 6a2:	00000097          	auipc	ra,0x0
 6a6:	27c080e7          	jalr	636(ra) # 91e <fork>
 6aa:	f92d                	bnez	a0,61c <main+0x2a>
        evaluate(parsedcmd);
 6ac:	8526                	mv	a0,s1
 6ae:	00000097          	auipc	ra,0x0
 6b2:	952080e7          	jalr	-1710(ra) # 0 <evaluate>
 6b6:	b79d                	j	61c <main+0x2a>

00000000000006b8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 6b8:	1141                	addi	sp,sp,-16
 6ba:	e422                	sd	s0,8(sp)
 6bc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 6be:	87aa                	mv	a5,a0
 6c0:	0585                	addi	a1,a1,1
 6c2:	0785                	addi	a5,a5,1
 6c4:	fff5c703          	lbu	a4,-1(a1)
 6c8:	fee78fa3          	sb	a4,-1(a5)
 6cc:	fb75                	bnez	a4,6c0 <strcpy+0x8>
    ;
  return os;
}
 6ce:	6422                	ld	s0,8(sp)
 6d0:	0141                	addi	sp,sp,16
 6d2:	8082                	ret

00000000000006d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 6d4:	1141                	addi	sp,sp,-16
 6d6:	e422                	sd	s0,8(sp)
 6d8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 6da:	00054783          	lbu	a5,0(a0)
 6de:	cb91                	beqz	a5,6f2 <strcmp+0x1e>
 6e0:	0005c703          	lbu	a4,0(a1)
 6e4:	00f71763          	bne	a4,a5,6f2 <strcmp+0x1e>
    p++, q++;
 6e8:	0505                	addi	a0,a0,1
 6ea:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 6ec:	00054783          	lbu	a5,0(a0)
 6f0:	fbe5                	bnez	a5,6e0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 6f2:	0005c503          	lbu	a0,0(a1)
}
 6f6:	40a7853b          	subw	a0,a5,a0
 6fa:	6422                	ld	s0,8(sp)
 6fc:	0141                	addi	sp,sp,16
 6fe:	8082                	ret

0000000000000700 <strlen>:

uint
strlen(const char *s)
{
 700:	1141                	addi	sp,sp,-16
 702:	e422                	sd	s0,8(sp)
 704:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 706:	00054783          	lbu	a5,0(a0)
 70a:	cf91                	beqz	a5,726 <strlen+0x26>
 70c:	0505                	addi	a0,a0,1
 70e:	87aa                	mv	a5,a0
 710:	4685                	li	a3,1
 712:	9e89                	subw	a3,a3,a0
 714:	00f6853b          	addw	a0,a3,a5
 718:	0785                	addi	a5,a5,1
 71a:	fff7c703          	lbu	a4,-1(a5)
 71e:	fb7d                	bnez	a4,714 <strlen+0x14>
    ;
  return n;
}
 720:	6422                	ld	s0,8(sp)
 722:	0141                	addi	sp,sp,16
 724:	8082                	ret
  for(n = 0; s[n]; n++)
 726:	4501                	li	a0,0
 728:	bfe5                	j	720 <strlen+0x20>

000000000000072a <memset>:

void*
memset(void *dst, int c, uint n)
{
 72a:	1141                	addi	sp,sp,-16
 72c:	e422                	sd	s0,8(sp)
 72e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 730:	ca19                	beqz	a2,746 <memset+0x1c>
 732:	87aa                	mv	a5,a0
 734:	1602                	slli	a2,a2,0x20
 736:	9201                	srli	a2,a2,0x20
 738:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 73c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 740:	0785                	addi	a5,a5,1
 742:	fee79de3          	bne	a5,a4,73c <memset+0x12>
  }
  return dst;
}
 746:	6422                	ld	s0,8(sp)
 748:	0141                	addi	sp,sp,16
 74a:	8082                	ret

000000000000074c <strchr>:

char*
strchr(const char *s, char c)
{
 74c:	1141                	addi	sp,sp,-16
 74e:	e422                	sd	s0,8(sp)
 750:	0800                	addi	s0,sp,16
  for(; *s; s++)
 752:	00054783          	lbu	a5,0(a0)
 756:	cb99                	beqz	a5,76c <strchr+0x20>
    if(*s == c)
 758:	00f58763          	beq	a1,a5,766 <strchr+0x1a>
  for(; *s; s++)
 75c:	0505                	addi	a0,a0,1
 75e:	00054783          	lbu	a5,0(a0)
 762:	fbfd                	bnez	a5,758 <strchr+0xc>
      return (char*)s;
  return 0;
 764:	4501                	li	a0,0
}
 766:	6422                	ld	s0,8(sp)
 768:	0141                	addi	sp,sp,16
 76a:	8082                	ret
  return 0;
 76c:	4501                	li	a0,0
 76e:	bfe5                	j	766 <strchr+0x1a>

0000000000000770 <gets>:

char*
gets(char *buf, int max)
{
 770:	711d                	addi	sp,sp,-96
 772:	ec86                	sd	ra,88(sp)
 774:	e8a2                	sd	s0,80(sp)
 776:	e4a6                	sd	s1,72(sp)
 778:	e0ca                	sd	s2,64(sp)
 77a:	fc4e                	sd	s3,56(sp)
 77c:	f852                	sd	s4,48(sp)
 77e:	f456                	sd	s5,40(sp)
 780:	f05a                	sd	s6,32(sp)
 782:	ec5e                	sd	s7,24(sp)
 784:	1080                	addi	s0,sp,96
 786:	8baa                	mv	s7,a0
 788:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 78a:	892a                	mv	s2,a0
 78c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 78e:	4aa9                	li	s5,10
 790:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 792:	89a6                	mv	s3,s1
 794:	2485                	addiw	s1,s1,1
 796:	0344d863          	bge	s1,s4,7c6 <gets+0x56>
    cc = read(0, &c, 1);
 79a:	4605                	li	a2,1
 79c:	faf40593          	addi	a1,s0,-81
 7a0:	4501                	li	a0,0
 7a2:	00000097          	auipc	ra,0x0
 7a6:	19c080e7          	jalr	412(ra) # 93e <read>
    if(cc < 1)
 7aa:	00a05e63          	blez	a0,7c6 <gets+0x56>
    buf[i++] = c;
 7ae:	faf44783          	lbu	a5,-81(s0)
 7b2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 7b6:	01578763          	beq	a5,s5,7c4 <gets+0x54>
 7ba:	0905                	addi	s2,s2,1
 7bc:	fd679be3          	bne	a5,s6,792 <gets+0x22>
  for(i=0; i+1 < max; ){
 7c0:	89a6                	mv	s3,s1
 7c2:	a011                	j	7c6 <gets+0x56>
 7c4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 7c6:	99de                	add	s3,s3,s7
 7c8:	00098023          	sb	zero,0(s3)
  return buf;
}
 7cc:	855e                	mv	a0,s7
 7ce:	60e6                	ld	ra,88(sp)
 7d0:	6446                	ld	s0,80(sp)
 7d2:	64a6                	ld	s1,72(sp)
 7d4:	6906                	ld	s2,64(sp)
 7d6:	79e2                	ld	s3,56(sp)
 7d8:	7a42                	ld	s4,48(sp)
 7da:	7aa2                	ld	s5,40(sp)
 7dc:	7b02                	ld	s6,32(sp)
 7de:	6be2                	ld	s7,24(sp)
 7e0:	6125                	addi	sp,sp,96
 7e2:	8082                	ret

00000000000007e4 <stat>:

int
stat(const char *n, struct stat *st)
{
 7e4:	1101                	addi	sp,sp,-32
 7e6:	ec06                	sd	ra,24(sp)
 7e8:	e822                	sd	s0,16(sp)
 7ea:	e426                	sd	s1,8(sp)
 7ec:	e04a                	sd	s2,0(sp)
 7ee:	1000                	addi	s0,sp,32
 7f0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7f2:	4581                	li	a1,0
 7f4:	00000097          	auipc	ra,0x0
 7f8:	172080e7          	jalr	370(ra) # 966 <open>
  if(fd < 0)
 7fc:	02054563          	bltz	a0,826 <stat+0x42>
 800:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 802:	85ca                	mv	a1,s2
 804:	00000097          	auipc	ra,0x0
 808:	17a080e7          	jalr	378(ra) # 97e <fstat>
 80c:	892a                	mv	s2,a0
  close(fd);
 80e:	8526                	mv	a0,s1
 810:	00000097          	auipc	ra,0x0
 814:	13e080e7          	jalr	318(ra) # 94e <close>
  return r;
}
 818:	854a                	mv	a0,s2
 81a:	60e2                	ld	ra,24(sp)
 81c:	6442                	ld	s0,16(sp)
 81e:	64a2                	ld	s1,8(sp)
 820:	6902                	ld	s2,0(sp)
 822:	6105                	addi	sp,sp,32
 824:	8082                	ret
    return -1;
 826:	597d                	li	s2,-1
 828:	bfc5                	j	818 <stat+0x34>

000000000000082a <atoi>:

int
atoi(const char *s)
{
 82a:	1141                	addi	sp,sp,-16
 82c:	e422                	sd	s0,8(sp)
 82e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 830:	00054603          	lbu	a2,0(a0)
 834:	fd06079b          	addiw	a5,a2,-48
 838:	0ff7f793          	andi	a5,a5,255
 83c:	4725                	li	a4,9
 83e:	02f76963          	bltu	a4,a5,870 <atoi+0x46>
 842:	86aa                	mv	a3,a0
  n = 0;
 844:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 846:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 848:	0685                	addi	a3,a3,1
 84a:	0025179b          	slliw	a5,a0,0x2
 84e:	9fa9                	addw	a5,a5,a0
 850:	0017979b          	slliw	a5,a5,0x1
 854:	9fb1                	addw	a5,a5,a2
 856:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 85a:	0006c603          	lbu	a2,0(a3)
 85e:	fd06071b          	addiw	a4,a2,-48
 862:	0ff77713          	andi	a4,a4,255
 866:	fee5f1e3          	bgeu	a1,a4,848 <atoi+0x1e>
  return n;
}
 86a:	6422                	ld	s0,8(sp)
 86c:	0141                	addi	sp,sp,16
 86e:	8082                	ret
  n = 0;
 870:	4501                	li	a0,0
 872:	bfe5                	j	86a <atoi+0x40>

0000000000000874 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 874:	1141                	addi	sp,sp,-16
 876:	e422                	sd	s0,8(sp)
 878:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 87a:	02b57463          	bgeu	a0,a1,8a2 <memmove+0x2e>
    while(n-- > 0)
 87e:	00c05f63          	blez	a2,89c <memmove+0x28>
 882:	1602                	slli	a2,a2,0x20
 884:	9201                	srli	a2,a2,0x20
 886:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 88a:	872a                	mv	a4,a0
      *dst++ = *src++;
 88c:	0585                	addi	a1,a1,1
 88e:	0705                	addi	a4,a4,1
 890:	fff5c683          	lbu	a3,-1(a1)
 894:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 898:	fee79ae3          	bne	a5,a4,88c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 89c:	6422                	ld	s0,8(sp)
 89e:	0141                	addi	sp,sp,16
 8a0:	8082                	ret
    dst += n;
 8a2:	00c50733          	add	a4,a0,a2
    src += n;
 8a6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 8a8:	fec05ae3          	blez	a2,89c <memmove+0x28>
 8ac:	fff6079b          	addiw	a5,a2,-1
 8b0:	1782                	slli	a5,a5,0x20
 8b2:	9381                	srli	a5,a5,0x20
 8b4:	fff7c793          	not	a5,a5
 8b8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 8ba:	15fd                	addi	a1,a1,-1
 8bc:	177d                	addi	a4,a4,-1
 8be:	0005c683          	lbu	a3,0(a1)
 8c2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 8c6:	fee79ae3          	bne	a5,a4,8ba <memmove+0x46>
 8ca:	bfc9                	j	89c <memmove+0x28>

00000000000008cc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 8cc:	1141                	addi	sp,sp,-16
 8ce:	e422                	sd	s0,8(sp)
 8d0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 8d2:	ca05                	beqz	a2,902 <memcmp+0x36>
 8d4:	fff6069b          	addiw	a3,a2,-1
 8d8:	1682                	slli	a3,a3,0x20
 8da:	9281                	srli	a3,a3,0x20
 8dc:	0685                	addi	a3,a3,1
 8de:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 8e0:	00054783          	lbu	a5,0(a0)
 8e4:	0005c703          	lbu	a4,0(a1)
 8e8:	00e79863          	bne	a5,a4,8f8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 8ec:	0505                	addi	a0,a0,1
    p2++;
 8ee:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 8f0:	fed518e3          	bne	a0,a3,8e0 <memcmp+0x14>
  }
  return 0;
 8f4:	4501                	li	a0,0
 8f6:	a019                	j	8fc <memcmp+0x30>
      return *p1 - *p2;
 8f8:	40e7853b          	subw	a0,a5,a4
}
 8fc:	6422                	ld	s0,8(sp)
 8fe:	0141                	addi	sp,sp,16
 900:	8082                	ret
  return 0;
 902:	4501                	li	a0,0
 904:	bfe5                	j	8fc <memcmp+0x30>

0000000000000906 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 906:	1141                	addi	sp,sp,-16
 908:	e406                	sd	ra,8(sp)
 90a:	e022                	sd	s0,0(sp)
 90c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 90e:	00000097          	auipc	ra,0x0
 912:	f66080e7          	jalr	-154(ra) # 874 <memmove>
}
 916:	60a2                	ld	ra,8(sp)
 918:	6402                	ld	s0,0(sp)
 91a:	0141                	addi	sp,sp,16
 91c:	8082                	ret

000000000000091e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 91e:	4885                	li	a7,1
 ecall
 920:	00000073          	ecall
 ret
 924:	8082                	ret

0000000000000926 <exit>:
.global exit
exit:
 li a7, SYS_exit
 926:	4889                	li	a7,2
 ecall
 928:	00000073          	ecall
 ret
 92c:	8082                	ret

000000000000092e <wait>:
.global wait
wait:
 li a7, SYS_wait
 92e:	488d                	li	a7,3
 ecall
 930:	00000073          	ecall
 ret
 934:	8082                	ret

0000000000000936 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 936:	4891                	li	a7,4
 ecall
 938:	00000073          	ecall
 ret
 93c:	8082                	ret

000000000000093e <read>:
.global read
read:
 li a7, SYS_read
 93e:	4895                	li	a7,5
 ecall
 940:	00000073          	ecall
 ret
 944:	8082                	ret

0000000000000946 <write>:
.global write
write:
 li a7, SYS_write
 946:	48c1                	li	a7,16
 ecall
 948:	00000073          	ecall
 ret
 94c:	8082                	ret

000000000000094e <close>:
.global close
close:
 li a7, SYS_close
 94e:	48d5                	li	a7,21
 ecall
 950:	00000073          	ecall
 ret
 954:	8082                	ret

0000000000000956 <kill>:
.global kill
kill:
 li a7, SYS_kill
 956:	4899                	li	a7,6
 ecall
 958:	00000073          	ecall
 ret
 95c:	8082                	ret

000000000000095e <exec>:
.global exec
exec:
 li a7, SYS_exec
 95e:	489d                	li	a7,7
 ecall
 960:	00000073          	ecall
 ret
 964:	8082                	ret

0000000000000966 <open>:
.global open
open:
 li a7, SYS_open
 966:	48bd                	li	a7,15
 ecall
 968:	00000073          	ecall
 ret
 96c:	8082                	ret

000000000000096e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 96e:	48c5                	li	a7,17
 ecall
 970:	00000073          	ecall
 ret
 974:	8082                	ret

0000000000000976 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 976:	48c9                	li	a7,18
 ecall
 978:	00000073          	ecall
 ret
 97c:	8082                	ret

000000000000097e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 97e:	48a1                	li	a7,8
 ecall
 980:	00000073          	ecall
 ret
 984:	8082                	ret

0000000000000986 <link>:
.global link
link:
 li a7, SYS_link
 986:	48cd                	li	a7,19
 ecall
 988:	00000073          	ecall
 ret
 98c:	8082                	ret

000000000000098e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 98e:	48d1                	li	a7,20
 ecall
 990:	00000073          	ecall
 ret
 994:	8082                	ret

0000000000000996 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 996:	48a5                	li	a7,9
 ecall
 998:	00000073          	ecall
 ret
 99c:	8082                	ret

000000000000099e <dup>:
.global dup
dup:
 li a7, SYS_dup
 99e:	48a9                	li	a7,10
 ecall
 9a0:	00000073          	ecall
 ret
 9a4:	8082                	ret

00000000000009a6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 9a6:	48ad                	li	a7,11
 ecall
 9a8:	00000073          	ecall
 ret
 9ac:	8082                	ret

00000000000009ae <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 9ae:	48b1                	li	a7,12
 ecall
 9b0:	00000073          	ecall
 ret
 9b4:	8082                	ret

00000000000009b6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 9b6:	48b5                	li	a7,13
 ecall
 9b8:	00000073          	ecall
 ret
 9bc:	8082                	ret

00000000000009be <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 9be:	48b9                	li	a7,14
 ecall
 9c0:	00000073          	ecall
 ret
 9c4:	8082                	ret

00000000000009c6 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 9c6:	48d9                	li	a7,22
 ecall
 9c8:	00000073          	ecall
 ret
 9cc:	8082                	ret

00000000000009ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9ce:	1101                	addi	sp,sp,-32
 9d0:	ec06                	sd	ra,24(sp)
 9d2:	e822                	sd	s0,16(sp)
 9d4:	1000                	addi	s0,sp,32
 9d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9da:	4605                	li	a2,1
 9dc:	fef40593          	addi	a1,s0,-17
 9e0:	00000097          	auipc	ra,0x0
 9e4:	f66080e7          	jalr	-154(ra) # 946 <write>
}
 9e8:	60e2                	ld	ra,24(sp)
 9ea:	6442                	ld	s0,16(sp)
 9ec:	6105                	addi	sp,sp,32
 9ee:	8082                	ret

00000000000009f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9f0:	7139                	addi	sp,sp,-64
 9f2:	fc06                	sd	ra,56(sp)
 9f4:	f822                	sd	s0,48(sp)
 9f6:	f426                	sd	s1,40(sp)
 9f8:	f04a                	sd	s2,32(sp)
 9fa:	ec4e                	sd	s3,24(sp)
 9fc:	0080                	addi	s0,sp,64
 9fe:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 a00:	c299                	beqz	a3,a06 <printint+0x16>
 a02:	0805c863          	bltz	a1,a92 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 a06:	2581                	sext.w	a1,a1
  neg = 0;
 a08:	4881                	li	a7,0
 a0a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 a0e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 a10:	2601                	sext.w	a2,a2
 a12:	00000517          	auipc	a0,0x0
 a16:	46e50513          	addi	a0,a0,1134 # e80 <digits>
 a1a:	883a                	mv	a6,a4
 a1c:	2705                	addiw	a4,a4,1
 a1e:	02c5f7bb          	remuw	a5,a1,a2
 a22:	1782                	slli	a5,a5,0x20
 a24:	9381                	srli	a5,a5,0x20
 a26:	97aa                	add	a5,a5,a0
 a28:	0007c783          	lbu	a5,0(a5)
 a2c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a30:	0005879b          	sext.w	a5,a1
 a34:	02c5d5bb          	divuw	a1,a1,a2
 a38:	0685                	addi	a3,a3,1
 a3a:	fec7f0e3          	bgeu	a5,a2,a1a <printint+0x2a>
  if(neg)
 a3e:	00088b63          	beqz	a7,a54 <printint+0x64>
    buf[i++] = '-';
 a42:	fd040793          	addi	a5,s0,-48
 a46:	973e                	add	a4,a4,a5
 a48:	02d00793          	li	a5,45
 a4c:	fef70823          	sb	a5,-16(a4)
 a50:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a54:	02e05863          	blez	a4,a84 <printint+0x94>
 a58:	fc040793          	addi	a5,s0,-64
 a5c:	00e78933          	add	s2,a5,a4
 a60:	fff78993          	addi	s3,a5,-1
 a64:	99ba                	add	s3,s3,a4
 a66:	377d                	addiw	a4,a4,-1
 a68:	1702                	slli	a4,a4,0x20
 a6a:	9301                	srli	a4,a4,0x20
 a6c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a70:	fff94583          	lbu	a1,-1(s2)
 a74:	8526                	mv	a0,s1
 a76:	00000097          	auipc	ra,0x0
 a7a:	f58080e7          	jalr	-168(ra) # 9ce <putc>
  while(--i >= 0)
 a7e:	197d                	addi	s2,s2,-1
 a80:	ff3918e3          	bne	s2,s3,a70 <printint+0x80>
}
 a84:	70e2                	ld	ra,56(sp)
 a86:	7442                	ld	s0,48(sp)
 a88:	74a2                	ld	s1,40(sp)
 a8a:	7902                	ld	s2,32(sp)
 a8c:	69e2                	ld	s3,24(sp)
 a8e:	6121                	addi	sp,sp,64
 a90:	8082                	ret
    x = -xx;
 a92:	40b005bb          	negw	a1,a1
    neg = 1;
 a96:	4885                	li	a7,1
    x = -xx;
 a98:	bf8d                	j	a0a <printint+0x1a>

0000000000000a9a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 a9a:	7119                	addi	sp,sp,-128
 a9c:	fc86                	sd	ra,120(sp)
 a9e:	f8a2                	sd	s0,112(sp)
 aa0:	f4a6                	sd	s1,104(sp)
 aa2:	f0ca                	sd	s2,96(sp)
 aa4:	ecce                	sd	s3,88(sp)
 aa6:	e8d2                	sd	s4,80(sp)
 aa8:	e4d6                	sd	s5,72(sp)
 aaa:	e0da                	sd	s6,64(sp)
 aac:	fc5e                	sd	s7,56(sp)
 aae:	f862                	sd	s8,48(sp)
 ab0:	f466                	sd	s9,40(sp)
 ab2:	f06a                	sd	s10,32(sp)
 ab4:	ec6e                	sd	s11,24(sp)
 ab6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 ab8:	0005c903          	lbu	s2,0(a1)
 abc:	18090f63          	beqz	s2,c5a <vprintf+0x1c0>
 ac0:	8aaa                	mv	s5,a0
 ac2:	8b32                	mv	s6,a2
 ac4:	00158493          	addi	s1,a1,1
  state = 0;
 ac8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 aca:	02500a13          	li	s4,37
      if(c == 'd'){
 ace:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 ad2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 ad6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 ada:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ade:	00000b97          	auipc	s7,0x0
 ae2:	3a2b8b93          	addi	s7,s7,930 # e80 <digits>
 ae6:	a839                	j	b04 <vprintf+0x6a>
        putc(fd, c);
 ae8:	85ca                	mv	a1,s2
 aea:	8556                	mv	a0,s5
 aec:	00000097          	auipc	ra,0x0
 af0:	ee2080e7          	jalr	-286(ra) # 9ce <putc>
 af4:	a019                	j	afa <vprintf+0x60>
    } else if(state == '%'){
 af6:	01498f63          	beq	s3,s4,b14 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 afa:	0485                	addi	s1,s1,1
 afc:	fff4c903          	lbu	s2,-1(s1)
 b00:	14090d63          	beqz	s2,c5a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 b04:	0009079b          	sext.w	a5,s2
    if(state == 0){
 b08:	fe0997e3          	bnez	s3,af6 <vprintf+0x5c>
      if(c == '%'){
 b0c:	fd479ee3          	bne	a5,s4,ae8 <vprintf+0x4e>
        state = '%';
 b10:	89be                	mv	s3,a5
 b12:	b7e5                	j	afa <vprintf+0x60>
      if(c == 'd'){
 b14:	05878063          	beq	a5,s8,b54 <vprintf+0xba>
      } else if(c == 'l') {
 b18:	05978c63          	beq	a5,s9,b70 <vprintf+0xd6>
      } else if(c == 'x') {
 b1c:	07a78863          	beq	a5,s10,b8c <vprintf+0xf2>
      } else if(c == 'p') {
 b20:	09b78463          	beq	a5,s11,ba8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 b24:	07300713          	li	a4,115
 b28:	0ce78663          	beq	a5,a4,bf4 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b2c:	06300713          	li	a4,99
 b30:	0ee78e63          	beq	a5,a4,c2c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 b34:	11478863          	beq	a5,s4,c44 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b38:	85d2                	mv	a1,s4
 b3a:	8556                	mv	a0,s5
 b3c:	00000097          	auipc	ra,0x0
 b40:	e92080e7          	jalr	-366(ra) # 9ce <putc>
        putc(fd, c);
 b44:	85ca                	mv	a1,s2
 b46:	8556                	mv	a0,s5
 b48:	00000097          	auipc	ra,0x0
 b4c:	e86080e7          	jalr	-378(ra) # 9ce <putc>
      }
      state = 0;
 b50:	4981                	li	s3,0
 b52:	b765                	j	afa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 b54:	008b0913          	addi	s2,s6,8
 b58:	4685                	li	a3,1
 b5a:	4629                	li	a2,10
 b5c:	000b2583          	lw	a1,0(s6)
 b60:	8556                	mv	a0,s5
 b62:	00000097          	auipc	ra,0x0
 b66:	e8e080e7          	jalr	-370(ra) # 9f0 <printint>
 b6a:	8b4a                	mv	s6,s2
      state = 0;
 b6c:	4981                	li	s3,0
 b6e:	b771                	j	afa <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b70:	008b0913          	addi	s2,s6,8
 b74:	4681                	li	a3,0
 b76:	4629                	li	a2,10
 b78:	000b2583          	lw	a1,0(s6)
 b7c:	8556                	mv	a0,s5
 b7e:	00000097          	auipc	ra,0x0
 b82:	e72080e7          	jalr	-398(ra) # 9f0 <printint>
 b86:	8b4a                	mv	s6,s2
      state = 0;
 b88:	4981                	li	s3,0
 b8a:	bf85                	j	afa <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 b8c:	008b0913          	addi	s2,s6,8
 b90:	4681                	li	a3,0
 b92:	4641                	li	a2,16
 b94:	000b2583          	lw	a1,0(s6)
 b98:	8556                	mv	a0,s5
 b9a:	00000097          	auipc	ra,0x0
 b9e:	e56080e7          	jalr	-426(ra) # 9f0 <printint>
 ba2:	8b4a                	mv	s6,s2
      state = 0;
 ba4:	4981                	li	s3,0
 ba6:	bf91                	j	afa <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 ba8:	008b0793          	addi	a5,s6,8
 bac:	f8f43423          	sd	a5,-120(s0)
 bb0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 bb4:	03000593          	li	a1,48
 bb8:	8556                	mv	a0,s5
 bba:	00000097          	auipc	ra,0x0
 bbe:	e14080e7          	jalr	-492(ra) # 9ce <putc>
  putc(fd, 'x');
 bc2:	85ea                	mv	a1,s10
 bc4:	8556                	mv	a0,s5
 bc6:	00000097          	auipc	ra,0x0
 bca:	e08080e7          	jalr	-504(ra) # 9ce <putc>
 bce:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bd0:	03c9d793          	srli	a5,s3,0x3c
 bd4:	97de                	add	a5,a5,s7
 bd6:	0007c583          	lbu	a1,0(a5)
 bda:	8556                	mv	a0,s5
 bdc:	00000097          	auipc	ra,0x0
 be0:	df2080e7          	jalr	-526(ra) # 9ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 be4:	0992                	slli	s3,s3,0x4
 be6:	397d                	addiw	s2,s2,-1
 be8:	fe0914e3          	bnez	s2,bd0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 bec:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 bf0:	4981                	li	s3,0
 bf2:	b721                	j	afa <vprintf+0x60>
        s = va_arg(ap, char*);
 bf4:	008b0993          	addi	s3,s6,8
 bf8:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 bfc:	02090163          	beqz	s2,c1e <vprintf+0x184>
        while(*s != 0){
 c00:	00094583          	lbu	a1,0(s2)
 c04:	c9a1                	beqz	a1,c54 <vprintf+0x1ba>
          putc(fd, *s);
 c06:	8556                	mv	a0,s5
 c08:	00000097          	auipc	ra,0x0
 c0c:	dc6080e7          	jalr	-570(ra) # 9ce <putc>
          s++;
 c10:	0905                	addi	s2,s2,1
        while(*s != 0){
 c12:	00094583          	lbu	a1,0(s2)
 c16:	f9e5                	bnez	a1,c06 <vprintf+0x16c>
        s = va_arg(ap, char*);
 c18:	8b4e                	mv	s6,s3
      state = 0;
 c1a:	4981                	li	s3,0
 c1c:	bdf9                	j	afa <vprintf+0x60>
          s = "(null)";
 c1e:	00000917          	auipc	s2,0x0
 c22:	25a90913          	addi	s2,s2,602 # e78 <malloc+0x114>
        while(*s != 0){
 c26:	02800593          	li	a1,40
 c2a:	bff1                	j	c06 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 c2c:	008b0913          	addi	s2,s6,8
 c30:	000b4583          	lbu	a1,0(s6)
 c34:	8556                	mv	a0,s5
 c36:	00000097          	auipc	ra,0x0
 c3a:	d98080e7          	jalr	-616(ra) # 9ce <putc>
 c3e:	8b4a                	mv	s6,s2
      state = 0;
 c40:	4981                	li	s3,0
 c42:	bd65                	j	afa <vprintf+0x60>
        putc(fd, c);
 c44:	85d2                	mv	a1,s4
 c46:	8556                	mv	a0,s5
 c48:	00000097          	auipc	ra,0x0
 c4c:	d86080e7          	jalr	-634(ra) # 9ce <putc>
      state = 0;
 c50:	4981                	li	s3,0
 c52:	b565                	j	afa <vprintf+0x60>
        s = va_arg(ap, char*);
 c54:	8b4e                	mv	s6,s3
      state = 0;
 c56:	4981                	li	s3,0
 c58:	b54d                	j	afa <vprintf+0x60>
    }
  }
}
 c5a:	70e6                	ld	ra,120(sp)
 c5c:	7446                	ld	s0,112(sp)
 c5e:	74a6                	ld	s1,104(sp)
 c60:	7906                	ld	s2,96(sp)
 c62:	69e6                	ld	s3,88(sp)
 c64:	6a46                	ld	s4,80(sp)
 c66:	6aa6                	ld	s5,72(sp)
 c68:	6b06                	ld	s6,64(sp)
 c6a:	7be2                	ld	s7,56(sp)
 c6c:	7c42                	ld	s8,48(sp)
 c6e:	7ca2                	ld	s9,40(sp)
 c70:	7d02                	ld	s10,32(sp)
 c72:	6de2                	ld	s11,24(sp)
 c74:	6109                	addi	sp,sp,128
 c76:	8082                	ret

0000000000000c78 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c78:	715d                	addi	sp,sp,-80
 c7a:	ec06                	sd	ra,24(sp)
 c7c:	e822                	sd	s0,16(sp)
 c7e:	1000                	addi	s0,sp,32
 c80:	e010                	sd	a2,0(s0)
 c82:	e414                	sd	a3,8(s0)
 c84:	e818                	sd	a4,16(s0)
 c86:	ec1c                	sd	a5,24(s0)
 c88:	03043023          	sd	a6,32(s0)
 c8c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c90:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c94:	8622                	mv	a2,s0
 c96:	00000097          	auipc	ra,0x0
 c9a:	e04080e7          	jalr	-508(ra) # a9a <vprintf>
}
 c9e:	60e2                	ld	ra,24(sp)
 ca0:	6442                	ld	s0,16(sp)
 ca2:	6161                	addi	sp,sp,80
 ca4:	8082                	ret

0000000000000ca6 <printf>:

void
printf(const char *fmt, ...)
{
 ca6:	711d                	addi	sp,sp,-96
 ca8:	ec06                	sd	ra,24(sp)
 caa:	e822                	sd	s0,16(sp)
 cac:	1000                	addi	s0,sp,32
 cae:	e40c                	sd	a1,8(s0)
 cb0:	e810                	sd	a2,16(s0)
 cb2:	ec14                	sd	a3,24(s0)
 cb4:	f018                	sd	a4,32(s0)
 cb6:	f41c                	sd	a5,40(s0)
 cb8:	03043823          	sd	a6,48(s0)
 cbc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 cc0:	00840613          	addi	a2,s0,8
 cc4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 cc8:	85aa                	mv	a1,a0
 cca:	4505                	li	a0,1
 ccc:	00000097          	auipc	ra,0x0
 cd0:	dce080e7          	jalr	-562(ra) # a9a <vprintf>
}
 cd4:	60e2                	ld	ra,24(sp)
 cd6:	6442                	ld	s0,16(sp)
 cd8:	6125                	addi	sp,sp,96
 cda:	8082                	ret

0000000000000cdc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cdc:	1141                	addi	sp,sp,-16
 cde:	e422                	sd	s0,8(sp)
 ce0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ce2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ce6:	00000797          	auipc	a5,0x0
 cea:	1c27b783          	ld	a5,450(a5) # ea8 <freep>
 cee:	a805                	j	d1e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cf0:	4618                	lw	a4,8(a2)
 cf2:	9db9                	addw	a1,a1,a4
 cf4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 cf8:	6398                	ld	a4,0(a5)
 cfa:	6318                	ld	a4,0(a4)
 cfc:	fee53823          	sd	a4,-16(a0)
 d00:	a091                	j	d44 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 d02:	ff852703          	lw	a4,-8(a0)
 d06:	9e39                	addw	a2,a2,a4
 d08:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 d0a:	ff053703          	ld	a4,-16(a0)
 d0e:	e398                	sd	a4,0(a5)
 d10:	a099                	j	d56 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d12:	6398                	ld	a4,0(a5)
 d14:	00e7e463          	bltu	a5,a4,d1c <free+0x40>
 d18:	00e6ea63          	bltu	a3,a4,d2c <free+0x50>
{
 d1c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d1e:	fed7fae3          	bgeu	a5,a3,d12 <free+0x36>
 d22:	6398                	ld	a4,0(a5)
 d24:	00e6e463          	bltu	a3,a4,d2c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d28:	fee7eae3          	bltu	a5,a4,d1c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 d2c:	ff852583          	lw	a1,-8(a0)
 d30:	6390                	ld	a2,0(a5)
 d32:	02059713          	slli	a4,a1,0x20
 d36:	9301                	srli	a4,a4,0x20
 d38:	0712                	slli	a4,a4,0x4
 d3a:	9736                	add	a4,a4,a3
 d3c:	fae60ae3          	beq	a2,a4,cf0 <free+0x14>
    bp->s.ptr = p->s.ptr;
 d40:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d44:	4790                	lw	a2,8(a5)
 d46:	02061713          	slli	a4,a2,0x20
 d4a:	9301                	srli	a4,a4,0x20
 d4c:	0712                	slli	a4,a4,0x4
 d4e:	973e                	add	a4,a4,a5
 d50:	fae689e3          	beq	a3,a4,d02 <free+0x26>
  } else
    p->s.ptr = bp;
 d54:	e394                	sd	a3,0(a5)
  freep = p;
 d56:	00000717          	auipc	a4,0x0
 d5a:	14f73923          	sd	a5,338(a4) # ea8 <freep>
}
 d5e:	6422                	ld	s0,8(sp)
 d60:	0141                	addi	sp,sp,16
 d62:	8082                	ret

0000000000000d64 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d64:	7139                	addi	sp,sp,-64
 d66:	fc06                	sd	ra,56(sp)
 d68:	f822                	sd	s0,48(sp)
 d6a:	f426                	sd	s1,40(sp)
 d6c:	f04a                	sd	s2,32(sp)
 d6e:	ec4e                	sd	s3,24(sp)
 d70:	e852                	sd	s4,16(sp)
 d72:	e456                	sd	s5,8(sp)
 d74:	e05a                	sd	s6,0(sp)
 d76:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d78:	02051493          	slli	s1,a0,0x20
 d7c:	9081                	srli	s1,s1,0x20
 d7e:	04bd                	addi	s1,s1,15
 d80:	8091                	srli	s1,s1,0x4
 d82:	0014899b          	addiw	s3,s1,1
 d86:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d88:	00000517          	auipc	a0,0x0
 d8c:	12053503          	ld	a0,288(a0) # ea8 <freep>
 d90:	c515                	beqz	a0,dbc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d92:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d94:	4798                	lw	a4,8(a5)
 d96:	02977f63          	bgeu	a4,s1,dd4 <malloc+0x70>
 d9a:	8a4e                	mv	s4,s3
 d9c:	0009871b          	sext.w	a4,s3
 da0:	6685                	lui	a3,0x1
 da2:	00d77363          	bgeu	a4,a3,da8 <malloc+0x44>
 da6:	6a05                	lui	s4,0x1
 da8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 dac:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 db0:	00000917          	auipc	s2,0x0
 db4:	0f890913          	addi	s2,s2,248 # ea8 <freep>
  if(p == (char*)-1)
 db8:	5afd                	li	s5,-1
 dba:	a88d                	j	e2c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 dbc:	00003797          	auipc	a5,0x3
 dc0:	dac78793          	addi	a5,a5,-596 # 3b68 <base>
 dc4:	00000717          	auipc	a4,0x0
 dc8:	0ef73223          	sd	a5,228(a4) # ea8 <freep>
 dcc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 dce:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 dd2:	b7e1                	j	d9a <malloc+0x36>
      if(p->s.size == nunits)
 dd4:	02e48b63          	beq	s1,a4,e0a <malloc+0xa6>
        p->s.size -= nunits;
 dd8:	4137073b          	subw	a4,a4,s3
 ddc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 dde:	1702                	slli	a4,a4,0x20
 de0:	9301                	srli	a4,a4,0x20
 de2:	0712                	slli	a4,a4,0x4
 de4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 de6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 dea:	00000717          	auipc	a4,0x0
 dee:	0aa73f23          	sd	a0,190(a4) # ea8 <freep>
      return (void*)(p + 1);
 df2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 df6:	70e2                	ld	ra,56(sp)
 df8:	7442                	ld	s0,48(sp)
 dfa:	74a2                	ld	s1,40(sp)
 dfc:	7902                	ld	s2,32(sp)
 dfe:	69e2                	ld	s3,24(sp)
 e00:	6a42                	ld	s4,16(sp)
 e02:	6aa2                	ld	s5,8(sp)
 e04:	6b02                	ld	s6,0(sp)
 e06:	6121                	addi	sp,sp,64
 e08:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 e0a:	6398                	ld	a4,0(a5)
 e0c:	e118                	sd	a4,0(a0)
 e0e:	bff1                	j	dea <malloc+0x86>
  hp->s.size = nu;
 e10:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 e14:	0541                	addi	a0,a0,16
 e16:	00000097          	auipc	ra,0x0
 e1a:	ec6080e7          	jalr	-314(ra) # cdc <free>
  return freep;
 e1e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 e22:	d971                	beqz	a0,df6 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e24:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e26:	4798                	lw	a4,8(a5)
 e28:	fa9776e3          	bgeu	a4,s1,dd4 <malloc+0x70>
    if(p == freep)
 e2c:	00093703          	ld	a4,0(s2)
 e30:	853e                	mv	a0,a5
 e32:	fef719e3          	bne	a4,a5,e24 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 e36:	8552                	mv	a0,s4
 e38:	00000097          	auipc	ra,0x0
 e3c:	b76080e7          	jalr	-1162(ra) # 9ae <sbrk>
  if(p == (char*)-1)
 e40:	fd5518e3          	bne	a0,s5,e10 <malloc+0xac>
        return 0;
 e44:	4501                	li	a0,0
 e46:	bf45                	j	df6 <malloc+0x92>
