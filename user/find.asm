
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	addi	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	addi	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	addi	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	addi	a1,a1,1
  ba:	00178513          	addi	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <match>:
{
  cc:	1101                	addi	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	addi	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  if(re[0] == '^')
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
    if(matchhere(re, text))
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  }while(*text++ != '\0');
  f6:	0485                	addi	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
    return matchhere(re+1, text);
 100:	0505                	addi	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
      return 1;
 10c:	4505                	li	a0,1
}
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	addi	sp,sp,32
 118:	8082                	ret

000000000000011a <fmtname>:
}

// 对ls中的fmtname，去掉了空白字符串
char*
fmtname(char *path)
{
 11a:	1101                	addi	sp,sp,-32
 11c:	ec06                	sd	ra,24(sp)
 11e:	e822                	sd	s0,16(sp)
 120:	e426                	sd	s1,8(sp)
 122:	e04a                	sd	s2,0(sp)
 124:	1000                	addi	s0,sp,32
 126:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
 128:	00000097          	auipc	ra,0x0
 12c:	2fe080e7          	jalr	766(ra) # 426 <strlen>
 130:	02051593          	slli	a1,a0,0x20
 134:	9181                	srli	a1,a1,0x20
 136:	95a6                	add	a1,a1,s1
 138:	02f00713          	li	a4,47
 13c:	0095e963          	bltu	a1,s1,14e <fmtname+0x34>
 140:	0005c783          	lbu	a5,0(a1)
 144:	00e78563          	beq	a5,a4,14e <fmtname+0x34>
 148:	15fd                	addi	a1,a1,-1
 14a:	fe95fbe3          	bgeu	a1,s1,140 <fmtname+0x26>
    ;
  p++;
 14e:	00158493          	addi	s1,a1,1
  // printf("len of p: %d\n", strlen(p));
  if(strlen(p) >= DIRSIZ)
 152:	8526                	mv	a0,s1
 154:	00000097          	auipc	ra,0x0
 158:	2d2080e7          	jalr	722(ra) # 426 <strlen>
 15c:	2501                	sext.w	a0,a0
 15e:	47b5                	li	a5,13
 160:	00a7f963          	bgeu	a5,a0,172 <fmtname+0x58>
    return p;
  memset(buf, 0, sizeof(buf));
  memmove(buf, p, strlen(p));
  //memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
 164:	8526                	mv	a0,s1
 166:	60e2                	ld	ra,24(sp)
 168:	6442                	ld	s0,16(sp)
 16a:	64a2                	ld	s1,8(sp)
 16c:	6902                	ld	s2,0(sp)
 16e:	6105                	addi	sp,sp,32
 170:	8082                	ret
  memset(buf, 0, sizeof(buf));
 172:	00001917          	auipc	s2,0x1
 176:	aa690913          	addi	s2,s2,-1370 # c18 <buf.0>
 17a:	463d                	li	a2,15
 17c:	4581                	li	a1,0
 17e:	854a                	mv	a0,s2
 180:	00000097          	auipc	ra,0x0
 184:	2d0080e7          	jalr	720(ra) # 450 <memset>
  memmove(buf, p, strlen(p));
 188:	8526                	mv	a0,s1
 18a:	00000097          	auipc	ra,0x0
 18e:	29c080e7          	jalr	668(ra) # 426 <strlen>
 192:	0005061b          	sext.w	a2,a0
 196:	85a6                	mv	a1,s1
 198:	854a                	mv	a0,s2
 19a:	00000097          	auipc	ra,0x0
 19e:	400080e7          	jalr	1024(ra) # 59a <memmove>
  return buf;
 1a2:	84ca                	mv	s1,s2
 1a4:	b7c1                	j	164 <fmtname+0x4a>

00000000000001a6 <find>:

void 
find(char *path, char *re){
 1a6:	d8010113          	addi	sp,sp,-640
 1aa:	26113c23          	sd	ra,632(sp)
 1ae:	26813823          	sd	s0,624(sp)
 1b2:	26913423          	sd	s1,616(sp)
 1b6:	27213023          	sd	s2,608(sp)
 1ba:	25313c23          	sd	s3,600(sp)
 1be:	25413823          	sd	s4,592(sp)
 1c2:	25513423          	sd	s5,584(sp)
 1c6:	25613023          	sd	s6,576(sp)
 1ca:	23713c23          	sd	s7,568(sp)
 1ce:	23813823          	sd	s8,560(sp)
 1d2:	0500                	addi	s0,sp,640
 1d4:	892a                	mv	s2,a0
 1d6:	89ae                	mv	s3,a1
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  
  if((fd = open(path, 0)) < 0){
 1d8:	4581                	li	a1,0
 1da:	00000097          	auipc	ra,0x0
 1de:	4b2080e7          	jalr	1202(ra) # 68c <open>
 1e2:	06054d63          	bltz	a0,25c <find+0xb6>
 1e6:	84aa                	mv	s1,a0
      fprintf(2, "find: cannot open %s\n", path);
      return;
  }

  if(fstat(fd, &st) < 0){
 1e8:	d8840593          	addi	a1,s0,-632
 1ec:	00000097          	auipc	ra,0x0
 1f0:	4b8080e7          	jalr	1208(ra) # 6a4 <fstat>
 1f4:	06054f63          	bltz	a0,272 <find+0xcc>
      fprintf(2, "find: cannot stat %s\n", path);
      close(fd);
      return;
  }
  
  switch(st.type){
 1f8:	d9041783          	lh	a5,-624(s0)
 1fc:	0007869b          	sext.w	a3,a5
 200:	4705                	li	a4,1
 202:	0ae68263          	beq	a3,a4,2a6 <find+0x100>
 206:	4709                	li	a4,2
 208:	00e69e63          	bne	a3,a4,224 <find+0x7e>
  case T_FILE:
      //printf("File re: %s, fmtpath: %s\n", re, fmtname(path));
      if(match(re, fmtname(path)))
 20c:	854a                	mv	a0,s2
 20e:	00000097          	auipc	ra,0x0
 212:	f0c080e7          	jalr	-244(ra) # 11a <fmtname>
 216:	85aa                	mv	a1,a0
 218:	854e                	mv	a0,s3
 21a:	00000097          	auipc	ra,0x0
 21e:	eb2080e7          	jalr	-334(ra) # cc <match>
 222:	e925                	bnez	a0,292 <find+0xec>
          }
          //printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
      }
      break;
  }
  close(fd);
 224:	8526                	mv	a0,s1
 226:	00000097          	auipc	ra,0x0
 22a:	44e080e7          	jalr	1102(ra) # 674 <close>
}
 22e:	27813083          	ld	ra,632(sp)
 232:	27013403          	ld	s0,624(sp)
 236:	26813483          	ld	s1,616(sp)
 23a:	26013903          	ld	s2,608(sp)
 23e:	25813983          	ld	s3,600(sp)
 242:	25013a03          	ld	s4,592(sp)
 246:	24813a83          	ld	s5,584(sp)
 24a:	24013b03          	ld	s6,576(sp)
 24e:	23813b83          	ld	s7,568(sp)
 252:	23013c03          	ld	s8,560(sp)
 256:	28010113          	addi	sp,sp,640
 25a:	8082                	ret
      fprintf(2, "find: cannot open %s\n", path);
 25c:	864a                	mv	a2,s2
 25e:	00001597          	auipc	a1,0x1
 262:	91258593          	addi	a1,a1,-1774 # b70 <malloc+0xe6>
 266:	4509                	li	a0,2
 268:	00000097          	auipc	ra,0x0
 26c:	736080e7          	jalr	1846(ra) # 99e <fprintf>
      return;
 270:	bf7d                	j	22e <find+0x88>
      fprintf(2, "find: cannot stat %s\n", path);
 272:	864a                	mv	a2,s2
 274:	00001597          	auipc	a1,0x1
 278:	91458593          	addi	a1,a1,-1772 # b88 <malloc+0xfe>
 27c:	4509                	li	a0,2
 27e:	00000097          	auipc	ra,0x0
 282:	720080e7          	jalr	1824(ra) # 99e <fprintf>
      close(fd);
 286:	8526                	mv	a0,s1
 288:	00000097          	auipc	ra,0x0
 28c:	3ec080e7          	jalr	1004(ra) # 674 <close>
      return;
 290:	bf79                	j	22e <find+0x88>
          printf("%s\n", path);
 292:	85ca                	mv	a1,s2
 294:	00001517          	auipc	a0,0x1
 298:	90c50513          	addi	a0,a0,-1780 # ba0 <malloc+0x116>
 29c:	00000097          	auipc	ra,0x0
 2a0:	730080e7          	jalr	1840(ra) # 9cc <printf>
 2a4:	b741                	j	224 <find+0x7e>
      if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 2a6:	854a                	mv	a0,s2
 2a8:	00000097          	auipc	ra,0x0
 2ac:	17e080e7          	jalr	382(ra) # 426 <strlen>
 2b0:	2541                	addiw	a0,a0,16
 2b2:	20000793          	li	a5,512
 2b6:	00a7fb63          	bgeu	a5,a0,2cc <find+0x126>
          printf("find: path too long\n");
 2ba:	00001517          	auipc	a0,0x1
 2be:	8ee50513          	addi	a0,a0,-1810 # ba8 <malloc+0x11e>
 2c2:	00000097          	auipc	ra,0x0
 2c6:	70a080e7          	jalr	1802(ra) # 9cc <printf>
          break;
 2ca:	bfa9                	j	224 <find+0x7e>
      strcpy(buf, path);
 2cc:	85ca                	mv	a1,s2
 2ce:	db040513          	addi	a0,s0,-592
 2d2:	00000097          	auipc	ra,0x0
 2d6:	10c080e7          	jalr	268(ra) # 3de <strcpy>
      p = buf + strlen(buf);
 2da:	db040513          	addi	a0,s0,-592
 2de:	00000097          	auipc	ra,0x0
 2e2:	148080e7          	jalr	328(ra) # 426 <strlen>
 2e6:	02051913          	slli	s2,a0,0x20
 2ea:	02095913          	srli	s2,s2,0x20
 2ee:	db040793          	addi	a5,s0,-592
 2f2:	993e                	add	s2,s2,a5
      *p++ = '/';
 2f4:	00190a93          	addi	s5,s2,1
 2f8:	02f00793          	li	a5,47
 2fc:	00f90023          	sb	a5,0(s2)
          if(strcmp(".", lstname) == 0 || strcmp("..", lstname) == 0){
 300:	00001b17          	auipc	s6,0x1
 304:	8c0b0b13          	addi	s6,s6,-1856 # bc0 <malloc+0x136>
 308:	00001b97          	auipc	s7,0x1
 30c:	8c0b8b93          	addi	s7,s7,-1856 # bc8 <malloc+0x13e>
              printf("find: cannot stat %s\n", buf);
 310:	00001c17          	auipc	s8,0x1
 314:	878c0c13          	addi	s8,s8,-1928 # b88 <malloc+0xfe>
      while(read(fd, &de, sizeof(de)) == sizeof(de)){
 318:	4641                	li	a2,16
 31a:	da040593          	addi	a1,s0,-608
 31e:	8526                	mv	a0,s1
 320:	00000097          	auipc	ra,0x0
 324:	344080e7          	jalr	836(ra) # 664 <read>
 328:	47c1                	li	a5,16
 32a:	eef51de3          	bne	a0,a5,224 <find+0x7e>
          if(de.inum == 0)
 32e:	da045783          	lhu	a5,-608(s0)
 332:	d3fd                	beqz	a5,318 <find+0x172>
          memmove(p, de.name, DIRSIZ);
 334:	4639                	li	a2,14
 336:	da240593          	addi	a1,s0,-606
 33a:	8556                	mv	a0,s5
 33c:	00000097          	auipc	ra,0x0
 340:	25e080e7          	jalr	606(ra) # 59a <memmove>
          p[DIRSIZ] = 0;
 344:	000907a3          	sb	zero,15(s2)
          if(stat(buf, &st) < 0){
 348:	d8840593          	addi	a1,s0,-632
 34c:	db040513          	addi	a0,s0,-592
 350:	00000097          	auipc	ra,0x0
 354:	1ba080e7          	jalr	442(ra) # 50a <stat>
 358:	02054f63          	bltz	a0,396 <find+0x1f0>
          char* lstname = fmtname(buf);
 35c:	db040513          	addi	a0,s0,-592
 360:	00000097          	auipc	ra,0x0
 364:	dba080e7          	jalr	-582(ra) # 11a <fmtname>
 368:	8a2a                	mv	s4,a0
          if(strcmp(".", lstname) == 0 || strcmp("..", lstname) == 0){
 36a:	85aa                	mv	a1,a0
 36c:	855a                	mv	a0,s6
 36e:	00000097          	auipc	ra,0x0
 372:	08c080e7          	jalr	140(ra) # 3fa <strcmp>
 376:	d14d                	beqz	a0,318 <find+0x172>
 378:	85d2                	mv	a1,s4
 37a:	855e                	mv	a0,s7
 37c:	00000097          	auipc	ra,0x0
 380:	07e080e7          	jalr	126(ra) # 3fa <strcmp>
 384:	d951                	beqz	a0,318 <find+0x172>
            find(buf, re);
 386:	85ce                	mv	a1,s3
 388:	db040513          	addi	a0,s0,-592
 38c:	00000097          	auipc	ra,0x0
 390:	e1a080e7          	jalr	-486(ra) # 1a6 <find>
 394:	b751                	j	318 <find+0x172>
              printf("find: cannot stat %s\n", buf);
 396:	db040593          	addi	a1,s0,-592
 39a:	8562                	mv	a0,s8
 39c:	00000097          	auipc	ra,0x0
 3a0:	630080e7          	jalr	1584(ra) # 9cc <printf>
              continue;
 3a4:	bf95                	j	318 <find+0x172>

00000000000003a6 <main>:
main(int argc, char** argv){
 3a6:	1141                	addi	sp,sp,-16
 3a8:	e406                	sd	ra,8(sp)
 3aa:	e022                	sd	s0,0(sp)
 3ac:	0800                	addi	s0,sp,16
    if(argc < 2){
 3ae:	4705                	li	a4,1
 3b0:	00a75e63          	bge	a4,a0,3cc <main+0x26>
 3b4:	87ae                	mv	a5,a1
      find(argv[1], argv[2]);
 3b6:	698c                	ld	a1,16(a1)
 3b8:	6788                	ld	a0,8(a5)
 3ba:	00000097          	auipc	ra,0x0
 3be:	dec080e7          	jalr	-532(ra) # 1a6 <find>
    exit(0);
 3c2:	4501                	li	a0,0
 3c4:	00000097          	auipc	ra,0x0
 3c8:	288080e7          	jalr	648(ra) # 64c <exit>
      printf("Parameters are not enough\n");
 3cc:	00001517          	auipc	a0,0x1
 3d0:	80450513          	addi	a0,a0,-2044 # bd0 <malloc+0x146>
 3d4:	00000097          	auipc	ra,0x0
 3d8:	5f8080e7          	jalr	1528(ra) # 9cc <printf>
 3dc:	b7dd                	j	3c2 <main+0x1c>

00000000000003de <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e422                	sd	s0,8(sp)
 3e2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3e4:	87aa                	mv	a5,a0
 3e6:	0585                	addi	a1,a1,1
 3e8:	0785                	addi	a5,a5,1
 3ea:	fff5c703          	lbu	a4,-1(a1)
 3ee:	fee78fa3          	sb	a4,-1(a5)
 3f2:	fb75                	bnez	a4,3e6 <strcpy+0x8>
    ;
  return os;
}
 3f4:	6422                	ld	s0,8(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret

00000000000003fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3fa:	1141                	addi	sp,sp,-16
 3fc:	e422                	sd	s0,8(sp)
 3fe:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 400:	00054783          	lbu	a5,0(a0)
 404:	cb91                	beqz	a5,418 <strcmp+0x1e>
 406:	0005c703          	lbu	a4,0(a1)
 40a:	00f71763          	bne	a4,a5,418 <strcmp+0x1e>
    p++, q++;
 40e:	0505                	addi	a0,a0,1
 410:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 412:	00054783          	lbu	a5,0(a0)
 416:	fbe5                	bnez	a5,406 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 418:	0005c503          	lbu	a0,0(a1)
}
 41c:	40a7853b          	subw	a0,a5,a0
 420:	6422                	ld	s0,8(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret

0000000000000426 <strlen>:

uint
strlen(const char *s)
{
 426:	1141                	addi	sp,sp,-16
 428:	e422                	sd	s0,8(sp)
 42a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 42c:	00054783          	lbu	a5,0(a0)
 430:	cf91                	beqz	a5,44c <strlen+0x26>
 432:	0505                	addi	a0,a0,1
 434:	87aa                	mv	a5,a0
 436:	4685                	li	a3,1
 438:	9e89                	subw	a3,a3,a0
 43a:	00f6853b          	addw	a0,a3,a5
 43e:	0785                	addi	a5,a5,1
 440:	fff7c703          	lbu	a4,-1(a5)
 444:	fb7d                	bnez	a4,43a <strlen+0x14>
    ;
  return n;
}
 446:	6422                	ld	s0,8(sp)
 448:	0141                	addi	sp,sp,16
 44a:	8082                	ret
  for(n = 0; s[n]; n++)
 44c:	4501                	li	a0,0
 44e:	bfe5                	j	446 <strlen+0x20>

0000000000000450 <memset>:

void*
memset(void *dst, int c, uint n)
{
 450:	1141                	addi	sp,sp,-16
 452:	e422                	sd	s0,8(sp)
 454:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 456:	ca19                	beqz	a2,46c <memset+0x1c>
 458:	87aa                	mv	a5,a0
 45a:	1602                	slli	a2,a2,0x20
 45c:	9201                	srli	a2,a2,0x20
 45e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 462:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 466:	0785                	addi	a5,a5,1
 468:	fee79de3          	bne	a5,a4,462 <memset+0x12>
  }
  return dst;
}
 46c:	6422                	ld	s0,8(sp)
 46e:	0141                	addi	sp,sp,16
 470:	8082                	ret

0000000000000472 <strchr>:

char*
strchr(const char *s, char c)
{
 472:	1141                	addi	sp,sp,-16
 474:	e422                	sd	s0,8(sp)
 476:	0800                	addi	s0,sp,16
  for(; *s; s++)
 478:	00054783          	lbu	a5,0(a0)
 47c:	cb99                	beqz	a5,492 <strchr+0x20>
    if(*s == c)
 47e:	00f58763          	beq	a1,a5,48c <strchr+0x1a>
  for(; *s; s++)
 482:	0505                	addi	a0,a0,1
 484:	00054783          	lbu	a5,0(a0)
 488:	fbfd                	bnez	a5,47e <strchr+0xc>
      return (char*)s;
  return 0;
 48a:	4501                	li	a0,0
}
 48c:	6422                	ld	s0,8(sp)
 48e:	0141                	addi	sp,sp,16
 490:	8082                	ret
  return 0;
 492:	4501                	li	a0,0
 494:	bfe5                	j	48c <strchr+0x1a>

0000000000000496 <gets>:

char*
gets(char *buf, int max)
{
 496:	711d                	addi	sp,sp,-96
 498:	ec86                	sd	ra,88(sp)
 49a:	e8a2                	sd	s0,80(sp)
 49c:	e4a6                	sd	s1,72(sp)
 49e:	e0ca                	sd	s2,64(sp)
 4a0:	fc4e                	sd	s3,56(sp)
 4a2:	f852                	sd	s4,48(sp)
 4a4:	f456                	sd	s5,40(sp)
 4a6:	f05a                	sd	s6,32(sp)
 4a8:	ec5e                	sd	s7,24(sp)
 4aa:	1080                	addi	s0,sp,96
 4ac:	8baa                	mv	s7,a0
 4ae:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4b0:	892a                	mv	s2,a0
 4b2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 4b4:	4aa9                	li	s5,10
 4b6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 4b8:	89a6                	mv	s3,s1
 4ba:	2485                	addiw	s1,s1,1
 4bc:	0344d863          	bge	s1,s4,4ec <gets+0x56>
    cc = read(0, &c, 1);
 4c0:	4605                	li	a2,1
 4c2:	faf40593          	addi	a1,s0,-81
 4c6:	4501                	li	a0,0
 4c8:	00000097          	auipc	ra,0x0
 4cc:	19c080e7          	jalr	412(ra) # 664 <read>
    if(cc < 1)
 4d0:	00a05e63          	blez	a0,4ec <gets+0x56>
    buf[i++] = c;
 4d4:	faf44783          	lbu	a5,-81(s0)
 4d8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 4dc:	01578763          	beq	a5,s5,4ea <gets+0x54>
 4e0:	0905                	addi	s2,s2,1
 4e2:	fd679be3          	bne	a5,s6,4b8 <gets+0x22>
  for(i=0; i+1 < max; ){
 4e6:	89a6                	mv	s3,s1
 4e8:	a011                	j	4ec <gets+0x56>
 4ea:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 4ec:	99de                	add	s3,s3,s7
 4ee:	00098023          	sb	zero,0(s3)
  return buf;
}
 4f2:	855e                	mv	a0,s7
 4f4:	60e6                	ld	ra,88(sp)
 4f6:	6446                	ld	s0,80(sp)
 4f8:	64a6                	ld	s1,72(sp)
 4fa:	6906                	ld	s2,64(sp)
 4fc:	79e2                	ld	s3,56(sp)
 4fe:	7a42                	ld	s4,48(sp)
 500:	7aa2                	ld	s5,40(sp)
 502:	7b02                	ld	s6,32(sp)
 504:	6be2                	ld	s7,24(sp)
 506:	6125                	addi	sp,sp,96
 508:	8082                	ret

000000000000050a <stat>:

int
stat(const char *n, struct stat *st)
{
 50a:	1101                	addi	sp,sp,-32
 50c:	ec06                	sd	ra,24(sp)
 50e:	e822                	sd	s0,16(sp)
 510:	e426                	sd	s1,8(sp)
 512:	e04a                	sd	s2,0(sp)
 514:	1000                	addi	s0,sp,32
 516:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 518:	4581                	li	a1,0
 51a:	00000097          	auipc	ra,0x0
 51e:	172080e7          	jalr	370(ra) # 68c <open>
  if(fd < 0)
 522:	02054563          	bltz	a0,54c <stat+0x42>
 526:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 528:	85ca                	mv	a1,s2
 52a:	00000097          	auipc	ra,0x0
 52e:	17a080e7          	jalr	378(ra) # 6a4 <fstat>
 532:	892a                	mv	s2,a0
  close(fd);
 534:	8526                	mv	a0,s1
 536:	00000097          	auipc	ra,0x0
 53a:	13e080e7          	jalr	318(ra) # 674 <close>
  return r;
}
 53e:	854a                	mv	a0,s2
 540:	60e2                	ld	ra,24(sp)
 542:	6442                	ld	s0,16(sp)
 544:	64a2                	ld	s1,8(sp)
 546:	6902                	ld	s2,0(sp)
 548:	6105                	addi	sp,sp,32
 54a:	8082                	ret
    return -1;
 54c:	597d                	li	s2,-1
 54e:	bfc5                	j	53e <stat+0x34>

0000000000000550 <atoi>:

int
atoi(const char *s)
{
 550:	1141                	addi	sp,sp,-16
 552:	e422                	sd	s0,8(sp)
 554:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 556:	00054603          	lbu	a2,0(a0)
 55a:	fd06079b          	addiw	a5,a2,-48
 55e:	0ff7f793          	andi	a5,a5,255
 562:	4725                	li	a4,9
 564:	02f76963          	bltu	a4,a5,596 <atoi+0x46>
 568:	86aa                	mv	a3,a0
  n = 0;
 56a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 56c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 56e:	0685                	addi	a3,a3,1
 570:	0025179b          	slliw	a5,a0,0x2
 574:	9fa9                	addw	a5,a5,a0
 576:	0017979b          	slliw	a5,a5,0x1
 57a:	9fb1                	addw	a5,a5,a2
 57c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 580:	0006c603          	lbu	a2,0(a3)
 584:	fd06071b          	addiw	a4,a2,-48
 588:	0ff77713          	andi	a4,a4,255
 58c:	fee5f1e3          	bgeu	a1,a4,56e <atoi+0x1e>
  return n;
}
 590:	6422                	ld	s0,8(sp)
 592:	0141                	addi	sp,sp,16
 594:	8082                	ret
  n = 0;
 596:	4501                	li	a0,0
 598:	bfe5                	j	590 <atoi+0x40>

000000000000059a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 59a:	1141                	addi	sp,sp,-16
 59c:	e422                	sd	s0,8(sp)
 59e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 5a0:	02b57463          	bgeu	a0,a1,5c8 <memmove+0x2e>
    while(n-- > 0)
 5a4:	00c05f63          	blez	a2,5c2 <memmove+0x28>
 5a8:	1602                	slli	a2,a2,0x20
 5aa:	9201                	srli	a2,a2,0x20
 5ac:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 5b0:	872a                	mv	a4,a0
      *dst++ = *src++;
 5b2:	0585                	addi	a1,a1,1
 5b4:	0705                	addi	a4,a4,1
 5b6:	fff5c683          	lbu	a3,-1(a1)
 5ba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 5be:	fee79ae3          	bne	a5,a4,5b2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 5c2:	6422                	ld	s0,8(sp)
 5c4:	0141                	addi	sp,sp,16
 5c6:	8082                	ret
    dst += n;
 5c8:	00c50733          	add	a4,a0,a2
    src += n;
 5cc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 5ce:	fec05ae3          	blez	a2,5c2 <memmove+0x28>
 5d2:	fff6079b          	addiw	a5,a2,-1
 5d6:	1782                	slli	a5,a5,0x20
 5d8:	9381                	srli	a5,a5,0x20
 5da:	fff7c793          	not	a5,a5
 5de:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 5e0:	15fd                	addi	a1,a1,-1
 5e2:	177d                	addi	a4,a4,-1
 5e4:	0005c683          	lbu	a3,0(a1)
 5e8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 5ec:	fee79ae3          	bne	a5,a4,5e0 <memmove+0x46>
 5f0:	bfc9                	j	5c2 <memmove+0x28>

00000000000005f2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 5f2:	1141                	addi	sp,sp,-16
 5f4:	e422                	sd	s0,8(sp)
 5f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 5f8:	ca05                	beqz	a2,628 <memcmp+0x36>
 5fa:	fff6069b          	addiw	a3,a2,-1
 5fe:	1682                	slli	a3,a3,0x20
 600:	9281                	srli	a3,a3,0x20
 602:	0685                	addi	a3,a3,1
 604:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 606:	00054783          	lbu	a5,0(a0)
 60a:	0005c703          	lbu	a4,0(a1)
 60e:	00e79863          	bne	a5,a4,61e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 612:	0505                	addi	a0,a0,1
    p2++;
 614:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 616:	fed518e3          	bne	a0,a3,606 <memcmp+0x14>
  }
  return 0;
 61a:	4501                	li	a0,0
 61c:	a019                	j	622 <memcmp+0x30>
      return *p1 - *p2;
 61e:	40e7853b          	subw	a0,a5,a4
}
 622:	6422                	ld	s0,8(sp)
 624:	0141                	addi	sp,sp,16
 626:	8082                	ret
  return 0;
 628:	4501                	li	a0,0
 62a:	bfe5                	j	622 <memcmp+0x30>

000000000000062c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 62c:	1141                	addi	sp,sp,-16
 62e:	e406                	sd	ra,8(sp)
 630:	e022                	sd	s0,0(sp)
 632:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 634:	00000097          	auipc	ra,0x0
 638:	f66080e7          	jalr	-154(ra) # 59a <memmove>
}
 63c:	60a2                	ld	ra,8(sp)
 63e:	6402                	ld	s0,0(sp)
 640:	0141                	addi	sp,sp,16
 642:	8082                	ret

0000000000000644 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 644:	4885                	li	a7,1
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <exit>:
.global exit
exit:
 li a7, SYS_exit
 64c:	4889                	li	a7,2
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <wait>:
.global wait
wait:
 li a7, SYS_wait
 654:	488d                	li	a7,3
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 65c:	4891                	li	a7,4
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <read>:
.global read
read:
 li a7, SYS_read
 664:	4895                	li	a7,5
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <write>:
.global write
write:
 li a7, SYS_write
 66c:	48c1                	li	a7,16
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <close>:
.global close
close:
 li a7, SYS_close
 674:	48d5                	li	a7,21
 ecall
 676:	00000073          	ecall
 ret
 67a:	8082                	ret

000000000000067c <kill>:
.global kill
kill:
 li a7, SYS_kill
 67c:	4899                	li	a7,6
 ecall
 67e:	00000073          	ecall
 ret
 682:	8082                	ret

0000000000000684 <exec>:
.global exec
exec:
 li a7, SYS_exec
 684:	489d                	li	a7,7
 ecall
 686:	00000073          	ecall
 ret
 68a:	8082                	ret

000000000000068c <open>:
.global open
open:
 li a7, SYS_open
 68c:	48bd                	li	a7,15
 ecall
 68e:	00000073          	ecall
 ret
 692:	8082                	ret

0000000000000694 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 694:	48c5                	li	a7,17
 ecall
 696:	00000073          	ecall
 ret
 69a:	8082                	ret

000000000000069c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 69c:	48c9                	li	a7,18
 ecall
 69e:	00000073          	ecall
 ret
 6a2:	8082                	ret

00000000000006a4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 6a4:	48a1                	li	a7,8
 ecall
 6a6:	00000073          	ecall
 ret
 6aa:	8082                	ret

00000000000006ac <link>:
.global link
link:
 li a7, SYS_link
 6ac:	48cd                	li	a7,19
 ecall
 6ae:	00000073          	ecall
 ret
 6b2:	8082                	ret

00000000000006b4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 6b4:	48d1                	li	a7,20
 ecall
 6b6:	00000073          	ecall
 ret
 6ba:	8082                	ret

00000000000006bc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 6bc:	48a5                	li	a7,9
 ecall
 6be:	00000073          	ecall
 ret
 6c2:	8082                	ret

00000000000006c4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 6c4:	48a9                	li	a7,10
 ecall
 6c6:	00000073          	ecall
 ret
 6ca:	8082                	ret

00000000000006cc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 6cc:	48ad                	li	a7,11
 ecall
 6ce:	00000073          	ecall
 ret
 6d2:	8082                	ret

00000000000006d4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 6d4:	48b1                	li	a7,12
 ecall
 6d6:	00000073          	ecall
 ret
 6da:	8082                	ret

00000000000006dc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 6dc:	48b5                	li	a7,13
 ecall
 6de:	00000073          	ecall
 ret
 6e2:	8082                	ret

00000000000006e4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6e4:	48b9                	li	a7,14
 ecall
 6e6:	00000073          	ecall
 ret
 6ea:	8082                	ret

00000000000006ec <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 6ec:	48d9                	li	a7,22
 ecall
 6ee:	00000073          	ecall
 ret
 6f2:	8082                	ret

00000000000006f4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6f4:	1101                	addi	sp,sp,-32
 6f6:	ec06                	sd	ra,24(sp)
 6f8:	e822                	sd	s0,16(sp)
 6fa:	1000                	addi	s0,sp,32
 6fc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 700:	4605                	li	a2,1
 702:	fef40593          	addi	a1,s0,-17
 706:	00000097          	auipc	ra,0x0
 70a:	f66080e7          	jalr	-154(ra) # 66c <write>
}
 70e:	60e2                	ld	ra,24(sp)
 710:	6442                	ld	s0,16(sp)
 712:	6105                	addi	sp,sp,32
 714:	8082                	ret

0000000000000716 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 716:	7139                	addi	sp,sp,-64
 718:	fc06                	sd	ra,56(sp)
 71a:	f822                	sd	s0,48(sp)
 71c:	f426                	sd	s1,40(sp)
 71e:	f04a                	sd	s2,32(sp)
 720:	ec4e                	sd	s3,24(sp)
 722:	0080                	addi	s0,sp,64
 724:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 726:	c299                	beqz	a3,72c <printint+0x16>
 728:	0805c863          	bltz	a1,7b8 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 72c:	2581                	sext.w	a1,a1
  neg = 0;
 72e:	4881                	li	a7,0
 730:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 734:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 736:	2601                	sext.w	a2,a2
 738:	00000517          	auipc	a0,0x0
 73c:	4c050513          	addi	a0,a0,1216 # bf8 <digits>
 740:	883a                	mv	a6,a4
 742:	2705                	addiw	a4,a4,1
 744:	02c5f7bb          	remuw	a5,a1,a2
 748:	1782                	slli	a5,a5,0x20
 74a:	9381                	srli	a5,a5,0x20
 74c:	97aa                	add	a5,a5,a0
 74e:	0007c783          	lbu	a5,0(a5)
 752:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 756:	0005879b          	sext.w	a5,a1
 75a:	02c5d5bb          	divuw	a1,a1,a2
 75e:	0685                	addi	a3,a3,1
 760:	fec7f0e3          	bgeu	a5,a2,740 <printint+0x2a>
  if(neg)
 764:	00088b63          	beqz	a7,77a <printint+0x64>
    buf[i++] = '-';
 768:	fd040793          	addi	a5,s0,-48
 76c:	973e                	add	a4,a4,a5
 76e:	02d00793          	li	a5,45
 772:	fef70823          	sb	a5,-16(a4)
 776:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 77a:	02e05863          	blez	a4,7aa <printint+0x94>
 77e:	fc040793          	addi	a5,s0,-64
 782:	00e78933          	add	s2,a5,a4
 786:	fff78993          	addi	s3,a5,-1
 78a:	99ba                	add	s3,s3,a4
 78c:	377d                	addiw	a4,a4,-1
 78e:	1702                	slli	a4,a4,0x20
 790:	9301                	srli	a4,a4,0x20
 792:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 796:	fff94583          	lbu	a1,-1(s2)
 79a:	8526                	mv	a0,s1
 79c:	00000097          	auipc	ra,0x0
 7a0:	f58080e7          	jalr	-168(ra) # 6f4 <putc>
  while(--i >= 0)
 7a4:	197d                	addi	s2,s2,-1
 7a6:	ff3918e3          	bne	s2,s3,796 <printint+0x80>
}
 7aa:	70e2                	ld	ra,56(sp)
 7ac:	7442                	ld	s0,48(sp)
 7ae:	74a2                	ld	s1,40(sp)
 7b0:	7902                	ld	s2,32(sp)
 7b2:	69e2                	ld	s3,24(sp)
 7b4:	6121                	addi	sp,sp,64
 7b6:	8082                	ret
    x = -xx;
 7b8:	40b005bb          	negw	a1,a1
    neg = 1;
 7bc:	4885                	li	a7,1
    x = -xx;
 7be:	bf8d                	j	730 <printint+0x1a>

00000000000007c0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7c0:	7119                	addi	sp,sp,-128
 7c2:	fc86                	sd	ra,120(sp)
 7c4:	f8a2                	sd	s0,112(sp)
 7c6:	f4a6                	sd	s1,104(sp)
 7c8:	f0ca                	sd	s2,96(sp)
 7ca:	ecce                	sd	s3,88(sp)
 7cc:	e8d2                	sd	s4,80(sp)
 7ce:	e4d6                	sd	s5,72(sp)
 7d0:	e0da                	sd	s6,64(sp)
 7d2:	fc5e                	sd	s7,56(sp)
 7d4:	f862                	sd	s8,48(sp)
 7d6:	f466                	sd	s9,40(sp)
 7d8:	f06a                	sd	s10,32(sp)
 7da:	ec6e                	sd	s11,24(sp)
 7dc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7de:	0005c903          	lbu	s2,0(a1)
 7e2:	18090f63          	beqz	s2,980 <vprintf+0x1c0>
 7e6:	8aaa                	mv	s5,a0
 7e8:	8b32                	mv	s6,a2
 7ea:	00158493          	addi	s1,a1,1
  state = 0;
 7ee:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 7f0:	02500a13          	li	s4,37
      if(c == 'd'){
 7f4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 7f8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 7fc:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 800:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 804:	00000b97          	auipc	s7,0x0
 808:	3f4b8b93          	addi	s7,s7,1012 # bf8 <digits>
 80c:	a839                	j	82a <vprintf+0x6a>
        putc(fd, c);
 80e:	85ca                	mv	a1,s2
 810:	8556                	mv	a0,s5
 812:	00000097          	auipc	ra,0x0
 816:	ee2080e7          	jalr	-286(ra) # 6f4 <putc>
 81a:	a019                	j	820 <vprintf+0x60>
    } else if(state == '%'){
 81c:	01498f63          	beq	s3,s4,83a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 820:	0485                	addi	s1,s1,1
 822:	fff4c903          	lbu	s2,-1(s1)
 826:	14090d63          	beqz	s2,980 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 82a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 82e:	fe0997e3          	bnez	s3,81c <vprintf+0x5c>
      if(c == '%'){
 832:	fd479ee3          	bne	a5,s4,80e <vprintf+0x4e>
        state = '%';
 836:	89be                	mv	s3,a5
 838:	b7e5                	j	820 <vprintf+0x60>
      if(c == 'd'){
 83a:	05878063          	beq	a5,s8,87a <vprintf+0xba>
      } else if(c == 'l') {
 83e:	05978c63          	beq	a5,s9,896 <vprintf+0xd6>
      } else if(c == 'x') {
 842:	07a78863          	beq	a5,s10,8b2 <vprintf+0xf2>
      } else if(c == 'p') {
 846:	09b78463          	beq	a5,s11,8ce <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 84a:	07300713          	li	a4,115
 84e:	0ce78663          	beq	a5,a4,91a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 852:	06300713          	li	a4,99
 856:	0ee78e63          	beq	a5,a4,952 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 85a:	11478863          	beq	a5,s4,96a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 85e:	85d2                	mv	a1,s4
 860:	8556                	mv	a0,s5
 862:	00000097          	auipc	ra,0x0
 866:	e92080e7          	jalr	-366(ra) # 6f4 <putc>
        putc(fd, c);
 86a:	85ca                	mv	a1,s2
 86c:	8556                	mv	a0,s5
 86e:	00000097          	auipc	ra,0x0
 872:	e86080e7          	jalr	-378(ra) # 6f4 <putc>
      }
      state = 0;
 876:	4981                	li	s3,0
 878:	b765                	j	820 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 87a:	008b0913          	addi	s2,s6,8
 87e:	4685                	li	a3,1
 880:	4629                	li	a2,10
 882:	000b2583          	lw	a1,0(s6)
 886:	8556                	mv	a0,s5
 888:	00000097          	auipc	ra,0x0
 88c:	e8e080e7          	jalr	-370(ra) # 716 <printint>
 890:	8b4a                	mv	s6,s2
      state = 0;
 892:	4981                	li	s3,0
 894:	b771                	j	820 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 896:	008b0913          	addi	s2,s6,8
 89a:	4681                	li	a3,0
 89c:	4629                	li	a2,10
 89e:	000b2583          	lw	a1,0(s6)
 8a2:	8556                	mv	a0,s5
 8a4:	00000097          	auipc	ra,0x0
 8a8:	e72080e7          	jalr	-398(ra) # 716 <printint>
 8ac:	8b4a                	mv	s6,s2
      state = 0;
 8ae:	4981                	li	s3,0
 8b0:	bf85                	j	820 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 8b2:	008b0913          	addi	s2,s6,8
 8b6:	4681                	li	a3,0
 8b8:	4641                	li	a2,16
 8ba:	000b2583          	lw	a1,0(s6)
 8be:	8556                	mv	a0,s5
 8c0:	00000097          	auipc	ra,0x0
 8c4:	e56080e7          	jalr	-426(ra) # 716 <printint>
 8c8:	8b4a                	mv	s6,s2
      state = 0;
 8ca:	4981                	li	s3,0
 8cc:	bf91                	j	820 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 8ce:	008b0793          	addi	a5,s6,8
 8d2:	f8f43423          	sd	a5,-120(s0)
 8d6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 8da:	03000593          	li	a1,48
 8de:	8556                	mv	a0,s5
 8e0:	00000097          	auipc	ra,0x0
 8e4:	e14080e7          	jalr	-492(ra) # 6f4 <putc>
  putc(fd, 'x');
 8e8:	85ea                	mv	a1,s10
 8ea:	8556                	mv	a0,s5
 8ec:	00000097          	auipc	ra,0x0
 8f0:	e08080e7          	jalr	-504(ra) # 6f4 <putc>
 8f4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8f6:	03c9d793          	srli	a5,s3,0x3c
 8fa:	97de                	add	a5,a5,s7
 8fc:	0007c583          	lbu	a1,0(a5)
 900:	8556                	mv	a0,s5
 902:	00000097          	auipc	ra,0x0
 906:	df2080e7          	jalr	-526(ra) # 6f4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 90a:	0992                	slli	s3,s3,0x4
 90c:	397d                	addiw	s2,s2,-1
 90e:	fe0914e3          	bnez	s2,8f6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 912:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 916:	4981                	li	s3,0
 918:	b721                	j	820 <vprintf+0x60>
        s = va_arg(ap, char*);
 91a:	008b0993          	addi	s3,s6,8
 91e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 922:	02090163          	beqz	s2,944 <vprintf+0x184>
        while(*s != 0){
 926:	00094583          	lbu	a1,0(s2)
 92a:	c9a1                	beqz	a1,97a <vprintf+0x1ba>
          putc(fd, *s);
 92c:	8556                	mv	a0,s5
 92e:	00000097          	auipc	ra,0x0
 932:	dc6080e7          	jalr	-570(ra) # 6f4 <putc>
          s++;
 936:	0905                	addi	s2,s2,1
        while(*s != 0){
 938:	00094583          	lbu	a1,0(s2)
 93c:	f9e5                	bnez	a1,92c <vprintf+0x16c>
        s = va_arg(ap, char*);
 93e:	8b4e                	mv	s6,s3
      state = 0;
 940:	4981                	li	s3,0
 942:	bdf9                	j	820 <vprintf+0x60>
          s = "(null)";
 944:	00000917          	auipc	s2,0x0
 948:	2ac90913          	addi	s2,s2,684 # bf0 <malloc+0x166>
        while(*s != 0){
 94c:	02800593          	li	a1,40
 950:	bff1                	j	92c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 952:	008b0913          	addi	s2,s6,8
 956:	000b4583          	lbu	a1,0(s6)
 95a:	8556                	mv	a0,s5
 95c:	00000097          	auipc	ra,0x0
 960:	d98080e7          	jalr	-616(ra) # 6f4 <putc>
 964:	8b4a                	mv	s6,s2
      state = 0;
 966:	4981                	li	s3,0
 968:	bd65                	j	820 <vprintf+0x60>
        putc(fd, c);
 96a:	85d2                	mv	a1,s4
 96c:	8556                	mv	a0,s5
 96e:	00000097          	auipc	ra,0x0
 972:	d86080e7          	jalr	-634(ra) # 6f4 <putc>
      state = 0;
 976:	4981                	li	s3,0
 978:	b565                	j	820 <vprintf+0x60>
        s = va_arg(ap, char*);
 97a:	8b4e                	mv	s6,s3
      state = 0;
 97c:	4981                	li	s3,0
 97e:	b54d                	j	820 <vprintf+0x60>
    }
  }
}
 980:	70e6                	ld	ra,120(sp)
 982:	7446                	ld	s0,112(sp)
 984:	74a6                	ld	s1,104(sp)
 986:	7906                	ld	s2,96(sp)
 988:	69e6                	ld	s3,88(sp)
 98a:	6a46                	ld	s4,80(sp)
 98c:	6aa6                	ld	s5,72(sp)
 98e:	6b06                	ld	s6,64(sp)
 990:	7be2                	ld	s7,56(sp)
 992:	7c42                	ld	s8,48(sp)
 994:	7ca2                	ld	s9,40(sp)
 996:	7d02                	ld	s10,32(sp)
 998:	6de2                	ld	s11,24(sp)
 99a:	6109                	addi	sp,sp,128
 99c:	8082                	ret

000000000000099e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 99e:	715d                	addi	sp,sp,-80
 9a0:	ec06                	sd	ra,24(sp)
 9a2:	e822                	sd	s0,16(sp)
 9a4:	1000                	addi	s0,sp,32
 9a6:	e010                	sd	a2,0(s0)
 9a8:	e414                	sd	a3,8(s0)
 9aa:	e818                	sd	a4,16(s0)
 9ac:	ec1c                	sd	a5,24(s0)
 9ae:	03043023          	sd	a6,32(s0)
 9b2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9b6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9ba:	8622                	mv	a2,s0
 9bc:	00000097          	auipc	ra,0x0
 9c0:	e04080e7          	jalr	-508(ra) # 7c0 <vprintf>
}
 9c4:	60e2                	ld	ra,24(sp)
 9c6:	6442                	ld	s0,16(sp)
 9c8:	6161                	addi	sp,sp,80
 9ca:	8082                	ret

00000000000009cc <printf>:

void
printf(const char *fmt, ...)
{
 9cc:	711d                	addi	sp,sp,-96
 9ce:	ec06                	sd	ra,24(sp)
 9d0:	e822                	sd	s0,16(sp)
 9d2:	1000                	addi	s0,sp,32
 9d4:	e40c                	sd	a1,8(s0)
 9d6:	e810                	sd	a2,16(s0)
 9d8:	ec14                	sd	a3,24(s0)
 9da:	f018                	sd	a4,32(s0)
 9dc:	f41c                	sd	a5,40(s0)
 9de:	03043823          	sd	a6,48(s0)
 9e2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9e6:	00840613          	addi	a2,s0,8
 9ea:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9ee:	85aa                	mv	a1,a0
 9f0:	4505                	li	a0,1
 9f2:	00000097          	auipc	ra,0x0
 9f6:	dce080e7          	jalr	-562(ra) # 7c0 <vprintf>
}
 9fa:	60e2                	ld	ra,24(sp)
 9fc:	6442                	ld	s0,16(sp)
 9fe:	6125                	addi	sp,sp,96
 a00:	8082                	ret

0000000000000a02 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a02:	1141                	addi	sp,sp,-16
 a04:	e422                	sd	s0,8(sp)
 a06:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a08:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a0c:	00000797          	auipc	a5,0x0
 a10:	2047b783          	ld	a5,516(a5) # c10 <freep>
 a14:	a805                	j	a44 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a16:	4618                	lw	a4,8(a2)
 a18:	9db9                	addw	a1,a1,a4
 a1a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a1e:	6398                	ld	a4,0(a5)
 a20:	6318                	ld	a4,0(a4)
 a22:	fee53823          	sd	a4,-16(a0)
 a26:	a091                	j	a6a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a28:	ff852703          	lw	a4,-8(a0)
 a2c:	9e39                	addw	a2,a2,a4
 a2e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a30:	ff053703          	ld	a4,-16(a0)
 a34:	e398                	sd	a4,0(a5)
 a36:	a099                	j	a7c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a38:	6398                	ld	a4,0(a5)
 a3a:	00e7e463          	bltu	a5,a4,a42 <free+0x40>
 a3e:	00e6ea63          	bltu	a3,a4,a52 <free+0x50>
{
 a42:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a44:	fed7fae3          	bgeu	a5,a3,a38 <free+0x36>
 a48:	6398                	ld	a4,0(a5)
 a4a:	00e6e463          	bltu	a3,a4,a52 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a4e:	fee7eae3          	bltu	a5,a4,a42 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 a52:	ff852583          	lw	a1,-8(a0)
 a56:	6390                	ld	a2,0(a5)
 a58:	02059713          	slli	a4,a1,0x20
 a5c:	9301                	srli	a4,a4,0x20
 a5e:	0712                	slli	a4,a4,0x4
 a60:	9736                	add	a4,a4,a3
 a62:	fae60ae3          	beq	a2,a4,a16 <free+0x14>
    bp->s.ptr = p->s.ptr;
 a66:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a6a:	4790                	lw	a2,8(a5)
 a6c:	02061713          	slli	a4,a2,0x20
 a70:	9301                	srli	a4,a4,0x20
 a72:	0712                	slli	a4,a4,0x4
 a74:	973e                	add	a4,a4,a5
 a76:	fae689e3          	beq	a3,a4,a28 <free+0x26>
  } else
    p->s.ptr = bp;
 a7a:	e394                	sd	a3,0(a5)
  freep = p;
 a7c:	00000717          	auipc	a4,0x0
 a80:	18f73a23          	sd	a5,404(a4) # c10 <freep>
}
 a84:	6422                	ld	s0,8(sp)
 a86:	0141                	addi	sp,sp,16
 a88:	8082                	ret

0000000000000a8a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a8a:	7139                	addi	sp,sp,-64
 a8c:	fc06                	sd	ra,56(sp)
 a8e:	f822                	sd	s0,48(sp)
 a90:	f426                	sd	s1,40(sp)
 a92:	f04a                	sd	s2,32(sp)
 a94:	ec4e                	sd	s3,24(sp)
 a96:	e852                	sd	s4,16(sp)
 a98:	e456                	sd	s5,8(sp)
 a9a:	e05a                	sd	s6,0(sp)
 a9c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a9e:	02051493          	slli	s1,a0,0x20
 aa2:	9081                	srli	s1,s1,0x20
 aa4:	04bd                	addi	s1,s1,15
 aa6:	8091                	srli	s1,s1,0x4
 aa8:	0014899b          	addiw	s3,s1,1
 aac:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 aae:	00000517          	auipc	a0,0x0
 ab2:	16253503          	ld	a0,354(a0) # c10 <freep>
 ab6:	c515                	beqz	a0,ae2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aba:	4798                	lw	a4,8(a5)
 abc:	02977f63          	bgeu	a4,s1,afa <malloc+0x70>
 ac0:	8a4e                	mv	s4,s3
 ac2:	0009871b          	sext.w	a4,s3
 ac6:	6685                	lui	a3,0x1
 ac8:	00d77363          	bgeu	a4,a3,ace <malloc+0x44>
 acc:	6a05                	lui	s4,0x1
 ace:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ad2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ad6:	00000917          	auipc	s2,0x0
 ada:	13a90913          	addi	s2,s2,314 # c10 <freep>
  if(p == (char*)-1)
 ade:	5afd                	li	s5,-1
 ae0:	a88d                	j	b52 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 ae2:	00000797          	auipc	a5,0x0
 ae6:	54678793          	addi	a5,a5,1350 # 1028 <base>
 aea:	00000717          	auipc	a4,0x0
 aee:	12f73323          	sd	a5,294(a4) # c10 <freep>
 af2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 af4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 af8:	b7e1                	j	ac0 <malloc+0x36>
      if(p->s.size == nunits)
 afa:	02e48b63          	beq	s1,a4,b30 <malloc+0xa6>
        p->s.size -= nunits;
 afe:	4137073b          	subw	a4,a4,s3
 b02:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b04:	1702                	slli	a4,a4,0x20
 b06:	9301                	srli	a4,a4,0x20
 b08:	0712                	slli	a4,a4,0x4
 b0a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b0c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b10:	00000717          	auipc	a4,0x0
 b14:	10a73023          	sd	a0,256(a4) # c10 <freep>
      return (void*)(p + 1);
 b18:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b1c:	70e2                	ld	ra,56(sp)
 b1e:	7442                	ld	s0,48(sp)
 b20:	74a2                	ld	s1,40(sp)
 b22:	7902                	ld	s2,32(sp)
 b24:	69e2                	ld	s3,24(sp)
 b26:	6a42                	ld	s4,16(sp)
 b28:	6aa2                	ld	s5,8(sp)
 b2a:	6b02                	ld	s6,0(sp)
 b2c:	6121                	addi	sp,sp,64
 b2e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b30:	6398                	ld	a4,0(a5)
 b32:	e118                	sd	a4,0(a0)
 b34:	bff1                	j	b10 <malloc+0x86>
  hp->s.size = nu;
 b36:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b3a:	0541                	addi	a0,a0,16
 b3c:	00000097          	auipc	ra,0x0
 b40:	ec6080e7          	jalr	-314(ra) # a02 <free>
  return freep;
 b44:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b48:	d971                	beqz	a0,b1c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b4a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b4c:	4798                	lw	a4,8(a5)
 b4e:	fa9776e3          	bgeu	a4,s1,afa <malloc+0x70>
    if(p == freep)
 b52:	00093703          	ld	a4,0(s2)
 b56:	853e                	mv	a0,a5
 b58:	fef719e3          	bne	a4,a5,b4a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 b5c:	8552                	mv	a0,s4
 b5e:	00000097          	auipc	ra,0x0
 b62:	b76080e7          	jalr	-1162(ra) # 6d4 <sbrk>
  if(p == (char*)-1)
 b66:	fd5518e3          	bne	a0,s5,b36 <malloc+0xac>
        return 0;
 b6a:	4501                	li	a0,0
 b6c:	bf45                	j	b1c <malloc+0x92>
