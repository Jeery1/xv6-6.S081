
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
       0:	00007797          	auipc	a5,0x7
       4:	a7078793          	addi	a5,a5,-1424 # 6a70 <uninit>
       8:	00009697          	auipc	a3,0x9
       c:	17868693          	addi	a3,a3,376 # 9180 <buf>
    if(uninit[i] != '\0'){
      10:	0007c703          	lbu	a4,0(a5)
      14:	e709                	bnez	a4,1e <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      16:	0785                	addi	a5,a5,1
      18:	fed79ce3          	bne	a5,a3,10 <bsstest+0x10>
      1c:	8082                	ret
{
      1e:	1141                	addi	sp,sp,-16
      20:	e406                	sd	ra,8(sp)
      22:	e022                	sd	s0,0(sp)
      24:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      26:	85aa                	mv	a1,a0
      28:	00005517          	auipc	a0,0x5
      2c:	b2850513          	addi	a0,a0,-1240 # 4b50 <malloc+0x358>
      30:	00004097          	auipc	ra,0x4
      34:	70a080e7          	jalr	1802(ra) # 473a <printf>
      exit(1);
      38:	4505                	li	a0,1
      3a:	00004097          	auipc	ra,0x4
      3e:	368080e7          	jalr	872(ra) # 43a2 <exit>

0000000000000042 <iputtest>:
{
      42:	1101                	addi	sp,sp,-32
      44:	ec06                	sd	ra,24(sp)
      46:	e822                	sd	s0,16(sp)
      48:	e426                	sd	s1,8(sp)
      4a:	1000                	addi	s0,sp,32
      4c:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
      4e:	00005517          	auipc	a0,0x5
      52:	b1a50513          	addi	a0,a0,-1254 # 4b68 <malloc+0x370>
      56:	00004097          	auipc	ra,0x4
      5a:	3b4080e7          	jalr	948(ra) # 440a <mkdir>
      5e:	04054563          	bltz	a0,a8 <iputtest+0x66>
  if(chdir("iputdir") < 0){
      62:	00005517          	auipc	a0,0x5
      66:	b0650513          	addi	a0,a0,-1274 # 4b68 <malloc+0x370>
      6a:	00004097          	auipc	ra,0x4
      6e:	3a8080e7          	jalr	936(ra) # 4412 <chdir>
      72:	04054963          	bltz	a0,c4 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
      76:	00005517          	auipc	a0,0x5
      7a:	b3250513          	addi	a0,a0,-1230 # 4ba8 <malloc+0x3b0>
      7e:	00004097          	auipc	ra,0x4
      82:	374080e7          	jalr	884(ra) # 43f2 <unlink>
      86:	04054d63          	bltz	a0,e0 <iputtest+0x9e>
  if(chdir("/") < 0){
      8a:	00005517          	auipc	a0,0x5
      8e:	b4e50513          	addi	a0,a0,-1202 # 4bd8 <malloc+0x3e0>
      92:	00004097          	auipc	ra,0x4
      96:	380080e7          	jalr	896(ra) # 4412 <chdir>
      9a:	06054163          	bltz	a0,fc <iputtest+0xba>
}
      9e:	60e2                	ld	ra,24(sp)
      a0:	6442                	ld	s0,16(sp)
      a2:	64a2                	ld	s1,8(sp)
      a4:	6105                	addi	sp,sp,32
      a6:	8082                	ret
    printf("%s: mkdir failed\n", s);
      a8:	85a6                	mv	a1,s1
      aa:	00005517          	auipc	a0,0x5
      ae:	ac650513          	addi	a0,a0,-1338 # 4b70 <malloc+0x378>
      b2:	00004097          	auipc	ra,0x4
      b6:	688080e7          	jalr	1672(ra) # 473a <printf>
    exit(1);
      ba:	4505                	li	a0,1
      bc:	00004097          	auipc	ra,0x4
      c0:	2e6080e7          	jalr	742(ra) # 43a2 <exit>
    printf("%s: chdir iputdir failed\n", s);
      c4:	85a6                	mv	a1,s1
      c6:	00005517          	auipc	a0,0x5
      ca:	ac250513          	addi	a0,a0,-1342 # 4b88 <malloc+0x390>
      ce:	00004097          	auipc	ra,0x4
      d2:	66c080e7          	jalr	1644(ra) # 473a <printf>
    exit(1);
      d6:	4505                	li	a0,1
      d8:	00004097          	auipc	ra,0x4
      dc:	2ca080e7          	jalr	714(ra) # 43a2 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
      e0:	85a6                	mv	a1,s1
      e2:	00005517          	auipc	a0,0x5
      e6:	ad650513          	addi	a0,a0,-1322 # 4bb8 <malloc+0x3c0>
      ea:	00004097          	auipc	ra,0x4
      ee:	650080e7          	jalr	1616(ra) # 473a <printf>
    exit(1);
      f2:	4505                	li	a0,1
      f4:	00004097          	auipc	ra,0x4
      f8:	2ae080e7          	jalr	686(ra) # 43a2 <exit>
    printf("%s: chdir / failed\n", s);
      fc:	85a6                	mv	a1,s1
      fe:	00005517          	auipc	a0,0x5
     102:	ae250513          	addi	a0,a0,-1310 # 4be0 <malloc+0x3e8>
     106:	00004097          	auipc	ra,0x4
     10a:	634080e7          	jalr	1588(ra) # 473a <printf>
    exit(1);
     10e:	4505                	li	a0,1
     110:	00004097          	auipc	ra,0x4
     114:	292080e7          	jalr	658(ra) # 43a2 <exit>

0000000000000118 <rmdot>:
{
     118:	1101                	addi	sp,sp,-32
     11a:	ec06                	sd	ra,24(sp)
     11c:	e822                	sd	s0,16(sp)
     11e:	e426                	sd	s1,8(sp)
     120:	1000                	addi	s0,sp,32
     122:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
     124:	00005517          	auipc	a0,0x5
     128:	ad450513          	addi	a0,a0,-1324 # 4bf8 <malloc+0x400>
     12c:	00004097          	auipc	ra,0x4
     130:	2de080e7          	jalr	734(ra) # 440a <mkdir>
     134:	e549                	bnez	a0,1be <rmdot+0xa6>
  if(chdir("dots") != 0){
     136:	00005517          	auipc	a0,0x5
     13a:	ac250513          	addi	a0,a0,-1342 # 4bf8 <malloc+0x400>
     13e:	00004097          	auipc	ra,0x4
     142:	2d4080e7          	jalr	724(ra) # 4412 <chdir>
     146:	e951                	bnez	a0,1da <rmdot+0xc2>
  if(unlink(".") == 0){
     148:	00005517          	auipc	a0,0x5
     14c:	ae850513          	addi	a0,a0,-1304 # 4c30 <malloc+0x438>
     150:	00004097          	auipc	ra,0x4
     154:	2a2080e7          	jalr	674(ra) # 43f2 <unlink>
     158:	cd59                	beqz	a0,1f6 <rmdot+0xde>
  if(unlink("..") == 0){
     15a:	00005517          	auipc	a0,0x5
     15e:	af650513          	addi	a0,a0,-1290 # 4c50 <malloc+0x458>
     162:	00004097          	auipc	ra,0x4
     166:	290080e7          	jalr	656(ra) # 43f2 <unlink>
     16a:	c545                	beqz	a0,212 <rmdot+0xfa>
  if(chdir("/") != 0){
     16c:	00005517          	auipc	a0,0x5
     170:	a6c50513          	addi	a0,a0,-1428 # 4bd8 <malloc+0x3e0>
     174:	00004097          	auipc	ra,0x4
     178:	29e080e7          	jalr	670(ra) # 4412 <chdir>
     17c:	e94d                	bnez	a0,22e <rmdot+0x116>
  if(unlink("dots/.") == 0){
     17e:	00005517          	auipc	a0,0x5
     182:	af250513          	addi	a0,a0,-1294 # 4c70 <malloc+0x478>
     186:	00004097          	auipc	ra,0x4
     18a:	26c080e7          	jalr	620(ra) # 43f2 <unlink>
     18e:	cd55                	beqz	a0,24a <rmdot+0x132>
  if(unlink("dots/..") == 0){
     190:	00005517          	auipc	a0,0x5
     194:	b0850513          	addi	a0,a0,-1272 # 4c98 <malloc+0x4a0>
     198:	00004097          	auipc	ra,0x4
     19c:	25a080e7          	jalr	602(ra) # 43f2 <unlink>
     1a0:	c179                	beqz	a0,266 <rmdot+0x14e>
  if(unlink("dots") != 0){
     1a2:	00005517          	auipc	a0,0x5
     1a6:	a5650513          	addi	a0,a0,-1450 # 4bf8 <malloc+0x400>
     1aa:	00004097          	auipc	ra,0x4
     1ae:	248080e7          	jalr	584(ra) # 43f2 <unlink>
     1b2:	e961                	bnez	a0,282 <rmdot+0x16a>
}
     1b4:	60e2                	ld	ra,24(sp)
     1b6:	6442                	ld	s0,16(sp)
     1b8:	64a2                	ld	s1,8(sp)
     1ba:	6105                	addi	sp,sp,32
     1bc:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
     1be:	85a6                	mv	a1,s1
     1c0:	00005517          	auipc	a0,0x5
     1c4:	a4050513          	addi	a0,a0,-1472 # 4c00 <malloc+0x408>
     1c8:	00004097          	auipc	ra,0x4
     1cc:	572080e7          	jalr	1394(ra) # 473a <printf>
    exit(1);
     1d0:	4505                	li	a0,1
     1d2:	00004097          	auipc	ra,0x4
     1d6:	1d0080e7          	jalr	464(ra) # 43a2 <exit>
    printf("%s: chdir dots failed\n", s);
     1da:	85a6                	mv	a1,s1
     1dc:	00005517          	auipc	a0,0x5
     1e0:	a3c50513          	addi	a0,a0,-1476 # 4c18 <malloc+0x420>
     1e4:	00004097          	auipc	ra,0x4
     1e8:	556080e7          	jalr	1366(ra) # 473a <printf>
    exit(1);
     1ec:	4505                	li	a0,1
     1ee:	00004097          	auipc	ra,0x4
     1f2:	1b4080e7          	jalr	436(ra) # 43a2 <exit>
    printf("%s: rm . worked!\n", s);
     1f6:	85a6                	mv	a1,s1
     1f8:	00005517          	auipc	a0,0x5
     1fc:	a4050513          	addi	a0,a0,-1472 # 4c38 <malloc+0x440>
     200:	00004097          	auipc	ra,0x4
     204:	53a080e7          	jalr	1338(ra) # 473a <printf>
    exit(1);
     208:	4505                	li	a0,1
     20a:	00004097          	auipc	ra,0x4
     20e:	198080e7          	jalr	408(ra) # 43a2 <exit>
    printf("%s: rm .. worked!\n", s);
     212:	85a6                	mv	a1,s1
     214:	00005517          	auipc	a0,0x5
     218:	a4450513          	addi	a0,a0,-1468 # 4c58 <malloc+0x460>
     21c:	00004097          	auipc	ra,0x4
     220:	51e080e7          	jalr	1310(ra) # 473a <printf>
    exit(1);
     224:	4505                	li	a0,1
     226:	00004097          	auipc	ra,0x4
     22a:	17c080e7          	jalr	380(ra) # 43a2 <exit>
    printf("%s: chdir / failed\n", s);
     22e:	85a6                	mv	a1,s1
     230:	00005517          	auipc	a0,0x5
     234:	9b050513          	addi	a0,a0,-1616 # 4be0 <malloc+0x3e8>
     238:	00004097          	auipc	ra,0x4
     23c:	502080e7          	jalr	1282(ra) # 473a <printf>
    exit(1);
     240:	4505                	li	a0,1
     242:	00004097          	auipc	ra,0x4
     246:	160080e7          	jalr	352(ra) # 43a2 <exit>
    printf("%s: unlink dots/. worked!\n", s);
     24a:	85a6                	mv	a1,s1
     24c:	00005517          	auipc	a0,0x5
     250:	a2c50513          	addi	a0,a0,-1492 # 4c78 <malloc+0x480>
     254:	00004097          	auipc	ra,0x4
     258:	4e6080e7          	jalr	1254(ra) # 473a <printf>
    exit(1);
     25c:	4505                	li	a0,1
     25e:	00004097          	auipc	ra,0x4
     262:	144080e7          	jalr	324(ra) # 43a2 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
     266:	85a6                	mv	a1,s1
     268:	00005517          	auipc	a0,0x5
     26c:	a3850513          	addi	a0,a0,-1480 # 4ca0 <malloc+0x4a8>
     270:	00004097          	auipc	ra,0x4
     274:	4ca080e7          	jalr	1226(ra) # 473a <printf>
    exit(1);
     278:	4505                	li	a0,1
     27a:	00004097          	auipc	ra,0x4
     27e:	128080e7          	jalr	296(ra) # 43a2 <exit>
    printf("%s: unlink dots failed!\n", s);
     282:	85a6                	mv	a1,s1
     284:	00005517          	auipc	a0,0x5
     288:	a3c50513          	addi	a0,a0,-1476 # 4cc0 <malloc+0x4c8>
     28c:	00004097          	auipc	ra,0x4
     290:	4ae080e7          	jalr	1198(ra) # 473a <printf>
    exit(1);
     294:	4505                	li	a0,1
     296:	00004097          	auipc	ra,0x4
     29a:	10c080e7          	jalr	268(ra) # 43a2 <exit>

000000000000029e <exitiputtest>:
{
     29e:	7179                	addi	sp,sp,-48
     2a0:	f406                	sd	ra,40(sp)
     2a2:	f022                	sd	s0,32(sp)
     2a4:	ec26                	sd	s1,24(sp)
     2a6:	1800                	addi	s0,sp,48
     2a8:	84aa                	mv	s1,a0
  pid = fork();
     2aa:	00004097          	auipc	ra,0x4
     2ae:	0f0080e7          	jalr	240(ra) # 439a <fork>
  if(pid < 0){
     2b2:	04054663          	bltz	a0,2fe <exitiputtest+0x60>
  if(pid == 0){
     2b6:	ed45                	bnez	a0,36e <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
     2b8:	00005517          	auipc	a0,0x5
     2bc:	8b050513          	addi	a0,a0,-1872 # 4b68 <malloc+0x370>
     2c0:	00004097          	auipc	ra,0x4
     2c4:	14a080e7          	jalr	330(ra) # 440a <mkdir>
     2c8:	04054963          	bltz	a0,31a <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
     2cc:	00005517          	auipc	a0,0x5
     2d0:	89c50513          	addi	a0,a0,-1892 # 4b68 <malloc+0x370>
     2d4:	00004097          	auipc	ra,0x4
     2d8:	13e080e7          	jalr	318(ra) # 4412 <chdir>
     2dc:	04054d63          	bltz	a0,336 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
     2e0:	00005517          	auipc	a0,0x5
     2e4:	8c850513          	addi	a0,a0,-1848 # 4ba8 <malloc+0x3b0>
     2e8:	00004097          	auipc	ra,0x4
     2ec:	10a080e7          	jalr	266(ra) # 43f2 <unlink>
     2f0:	06054163          	bltz	a0,352 <exitiputtest+0xb4>
    exit(0);
     2f4:	4501                	li	a0,0
     2f6:	00004097          	auipc	ra,0x4
     2fa:	0ac080e7          	jalr	172(ra) # 43a2 <exit>
    printf("%s: fork failed\n", s);
     2fe:	85a6                	mv	a1,s1
     300:	00005517          	auipc	a0,0x5
     304:	9e050513          	addi	a0,a0,-1568 # 4ce0 <malloc+0x4e8>
     308:	00004097          	auipc	ra,0x4
     30c:	432080e7          	jalr	1074(ra) # 473a <printf>
    exit(1);
     310:	4505                	li	a0,1
     312:	00004097          	auipc	ra,0x4
     316:	090080e7          	jalr	144(ra) # 43a2 <exit>
      printf("%s: mkdir failed\n", s);
     31a:	85a6                	mv	a1,s1
     31c:	00005517          	auipc	a0,0x5
     320:	85450513          	addi	a0,a0,-1964 # 4b70 <malloc+0x378>
     324:	00004097          	auipc	ra,0x4
     328:	416080e7          	jalr	1046(ra) # 473a <printf>
      exit(1);
     32c:	4505                	li	a0,1
     32e:	00004097          	auipc	ra,0x4
     332:	074080e7          	jalr	116(ra) # 43a2 <exit>
      printf("%s: child chdir failed\n", s);
     336:	85a6                	mv	a1,s1
     338:	00005517          	auipc	a0,0x5
     33c:	9c050513          	addi	a0,a0,-1600 # 4cf8 <malloc+0x500>
     340:	00004097          	auipc	ra,0x4
     344:	3fa080e7          	jalr	1018(ra) # 473a <printf>
      exit(1);
     348:	4505                	li	a0,1
     34a:	00004097          	auipc	ra,0x4
     34e:	058080e7          	jalr	88(ra) # 43a2 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
     352:	85a6                	mv	a1,s1
     354:	00005517          	auipc	a0,0x5
     358:	86450513          	addi	a0,a0,-1948 # 4bb8 <malloc+0x3c0>
     35c:	00004097          	auipc	ra,0x4
     360:	3de080e7          	jalr	990(ra) # 473a <printf>
      exit(1);
     364:	4505                	li	a0,1
     366:	00004097          	auipc	ra,0x4
     36a:	03c080e7          	jalr	60(ra) # 43a2 <exit>
  wait(&xstatus);
     36e:	fdc40513          	addi	a0,s0,-36
     372:	00004097          	auipc	ra,0x4
     376:	038080e7          	jalr	56(ra) # 43aa <wait>
  exit(xstatus);
     37a:	fdc42503          	lw	a0,-36(s0)
     37e:	00004097          	auipc	ra,0x4
     382:	024080e7          	jalr	36(ra) # 43a2 <exit>

0000000000000386 <exitwait>:
{
     386:	7139                	addi	sp,sp,-64
     388:	fc06                	sd	ra,56(sp)
     38a:	f822                	sd	s0,48(sp)
     38c:	f426                	sd	s1,40(sp)
     38e:	f04a                	sd	s2,32(sp)
     390:	ec4e                	sd	s3,24(sp)
     392:	e852                	sd	s4,16(sp)
     394:	0080                	addi	s0,sp,64
     396:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
     398:	4901                	li	s2,0
     39a:	06400993          	li	s3,100
    pid = fork();
     39e:	00004097          	auipc	ra,0x4
     3a2:	ffc080e7          	jalr	-4(ra) # 439a <fork>
     3a6:	84aa                	mv	s1,a0
    if(pid < 0){
     3a8:	02054a63          	bltz	a0,3dc <exitwait+0x56>
    if(pid){
     3ac:	c151                	beqz	a0,430 <exitwait+0xaa>
      if(wait(&xstate) != pid){
     3ae:	fcc40513          	addi	a0,s0,-52
     3b2:	00004097          	auipc	ra,0x4
     3b6:	ff8080e7          	jalr	-8(ra) # 43aa <wait>
     3ba:	02951f63          	bne	a0,s1,3f8 <exitwait+0x72>
      if(i != xstate) {
     3be:	fcc42783          	lw	a5,-52(s0)
     3c2:	05279963          	bne	a5,s2,414 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
     3c6:	2905                	addiw	s2,s2,1
     3c8:	fd391be3          	bne	s2,s3,39e <exitwait+0x18>
}
     3cc:	70e2                	ld	ra,56(sp)
     3ce:	7442                	ld	s0,48(sp)
     3d0:	74a2                	ld	s1,40(sp)
     3d2:	7902                	ld	s2,32(sp)
     3d4:	69e2                	ld	s3,24(sp)
     3d6:	6a42                	ld	s4,16(sp)
     3d8:	6121                	addi	sp,sp,64
     3da:	8082                	ret
      printf("%s: fork failed\n", s);
     3dc:	85d2                	mv	a1,s4
     3de:	00005517          	auipc	a0,0x5
     3e2:	90250513          	addi	a0,a0,-1790 # 4ce0 <malloc+0x4e8>
     3e6:	00004097          	auipc	ra,0x4
     3ea:	354080e7          	jalr	852(ra) # 473a <printf>
      exit(1);
     3ee:	4505                	li	a0,1
     3f0:	00004097          	auipc	ra,0x4
     3f4:	fb2080e7          	jalr	-78(ra) # 43a2 <exit>
        printf("%s: wait wrong pid\n", s);
     3f8:	85d2                	mv	a1,s4
     3fa:	00005517          	auipc	a0,0x5
     3fe:	91650513          	addi	a0,a0,-1770 # 4d10 <malloc+0x518>
     402:	00004097          	auipc	ra,0x4
     406:	338080e7          	jalr	824(ra) # 473a <printf>
        exit(1);
     40a:	4505                	li	a0,1
     40c:	00004097          	auipc	ra,0x4
     410:	f96080e7          	jalr	-106(ra) # 43a2 <exit>
        printf("%s: wait wrong exit status\n", s);
     414:	85d2                	mv	a1,s4
     416:	00005517          	auipc	a0,0x5
     41a:	91250513          	addi	a0,a0,-1774 # 4d28 <malloc+0x530>
     41e:	00004097          	auipc	ra,0x4
     422:	31c080e7          	jalr	796(ra) # 473a <printf>
        exit(1);
     426:	4505                	li	a0,1
     428:	00004097          	auipc	ra,0x4
     42c:	f7a080e7          	jalr	-134(ra) # 43a2 <exit>
      exit(i);
     430:	854a                	mv	a0,s2
     432:	00004097          	auipc	ra,0x4
     436:	f70080e7          	jalr	-144(ra) # 43a2 <exit>

000000000000043a <twochildren>:
{
     43a:	1101                	addi	sp,sp,-32
     43c:	ec06                	sd	ra,24(sp)
     43e:	e822                	sd	s0,16(sp)
     440:	e426                	sd	s1,8(sp)
     442:	e04a                	sd	s2,0(sp)
     444:	1000                	addi	s0,sp,32
     446:	892a                	mv	s2,a0
     448:	3e800493          	li	s1,1000
    int pid1 = fork();
     44c:	00004097          	auipc	ra,0x4
     450:	f4e080e7          	jalr	-178(ra) # 439a <fork>
    if(pid1 < 0){
     454:	02054c63          	bltz	a0,48c <twochildren+0x52>
    if(pid1 == 0){
     458:	c921                	beqz	a0,4a8 <twochildren+0x6e>
      int pid2 = fork();
     45a:	00004097          	auipc	ra,0x4
     45e:	f40080e7          	jalr	-192(ra) # 439a <fork>
      if(pid2 < 0){
     462:	04054763          	bltz	a0,4b0 <twochildren+0x76>
      if(pid2 == 0){
     466:	c13d                	beqz	a0,4cc <twochildren+0x92>
        wait(0);
     468:	4501                	li	a0,0
     46a:	00004097          	auipc	ra,0x4
     46e:	f40080e7          	jalr	-192(ra) # 43aa <wait>
        wait(0);
     472:	4501                	li	a0,0
     474:	00004097          	auipc	ra,0x4
     478:	f36080e7          	jalr	-202(ra) # 43aa <wait>
  for(int i = 0; i < 1000; i++){
     47c:	34fd                	addiw	s1,s1,-1
     47e:	f4f9                	bnez	s1,44c <twochildren+0x12>
}
     480:	60e2                	ld	ra,24(sp)
     482:	6442                	ld	s0,16(sp)
     484:	64a2                	ld	s1,8(sp)
     486:	6902                	ld	s2,0(sp)
     488:	6105                	addi	sp,sp,32
     48a:	8082                	ret
      printf("%s: fork failed\n", s);
     48c:	85ca                	mv	a1,s2
     48e:	00005517          	auipc	a0,0x5
     492:	85250513          	addi	a0,a0,-1966 # 4ce0 <malloc+0x4e8>
     496:	00004097          	auipc	ra,0x4
     49a:	2a4080e7          	jalr	676(ra) # 473a <printf>
      exit(1);
     49e:	4505                	li	a0,1
     4a0:	00004097          	auipc	ra,0x4
     4a4:	f02080e7          	jalr	-254(ra) # 43a2 <exit>
      exit(0);
     4a8:	00004097          	auipc	ra,0x4
     4ac:	efa080e7          	jalr	-262(ra) # 43a2 <exit>
        printf("%s: fork failed\n", s);
     4b0:	85ca                	mv	a1,s2
     4b2:	00005517          	auipc	a0,0x5
     4b6:	82e50513          	addi	a0,a0,-2002 # 4ce0 <malloc+0x4e8>
     4ba:	00004097          	auipc	ra,0x4
     4be:	280080e7          	jalr	640(ra) # 473a <printf>
        exit(1);
     4c2:	4505                	li	a0,1
     4c4:	00004097          	auipc	ra,0x4
     4c8:	ede080e7          	jalr	-290(ra) # 43a2 <exit>
        exit(0);
     4cc:	00004097          	auipc	ra,0x4
     4d0:	ed6080e7          	jalr	-298(ra) # 43a2 <exit>

00000000000004d4 <forkfork>:
{
     4d4:	7179                	addi	sp,sp,-48
     4d6:	f406                	sd	ra,40(sp)
     4d8:	f022                	sd	s0,32(sp)
     4da:	ec26                	sd	s1,24(sp)
     4dc:	1800                	addi	s0,sp,48
     4de:	84aa                	mv	s1,a0
    int pid = fork();
     4e0:	00004097          	auipc	ra,0x4
     4e4:	eba080e7          	jalr	-326(ra) # 439a <fork>
    if(pid < 0){
     4e8:	04054163          	bltz	a0,52a <forkfork+0x56>
    if(pid == 0){
     4ec:	cd29                	beqz	a0,546 <forkfork+0x72>
    int pid = fork();
     4ee:	00004097          	auipc	ra,0x4
     4f2:	eac080e7          	jalr	-340(ra) # 439a <fork>
    if(pid < 0){
     4f6:	02054a63          	bltz	a0,52a <forkfork+0x56>
    if(pid == 0){
     4fa:	c531                	beqz	a0,546 <forkfork+0x72>
    wait(&xstatus);
     4fc:	fdc40513          	addi	a0,s0,-36
     500:	00004097          	auipc	ra,0x4
     504:	eaa080e7          	jalr	-342(ra) # 43aa <wait>
    if(xstatus != 0) {
     508:	fdc42783          	lw	a5,-36(s0)
     50c:	ebbd                	bnez	a5,582 <forkfork+0xae>
    wait(&xstatus);
     50e:	fdc40513          	addi	a0,s0,-36
     512:	00004097          	auipc	ra,0x4
     516:	e98080e7          	jalr	-360(ra) # 43aa <wait>
    if(xstatus != 0) {
     51a:	fdc42783          	lw	a5,-36(s0)
     51e:	e3b5                	bnez	a5,582 <forkfork+0xae>
}
     520:	70a2                	ld	ra,40(sp)
     522:	7402                	ld	s0,32(sp)
     524:	64e2                	ld	s1,24(sp)
     526:	6145                	addi	sp,sp,48
     528:	8082                	ret
      printf("%s: fork failed", s);
     52a:	85a6                	mv	a1,s1
     52c:	00005517          	auipc	a0,0x5
     530:	81c50513          	addi	a0,a0,-2020 # 4d48 <malloc+0x550>
     534:	00004097          	auipc	ra,0x4
     538:	206080e7          	jalr	518(ra) # 473a <printf>
      exit(1);
     53c:	4505                	li	a0,1
     53e:	00004097          	auipc	ra,0x4
     542:	e64080e7          	jalr	-412(ra) # 43a2 <exit>
{
     546:	0c800493          	li	s1,200
        int pid1 = fork();
     54a:	00004097          	auipc	ra,0x4
     54e:	e50080e7          	jalr	-432(ra) # 439a <fork>
        if(pid1 < 0){
     552:	00054f63          	bltz	a0,570 <forkfork+0x9c>
        if(pid1 == 0){
     556:	c115                	beqz	a0,57a <forkfork+0xa6>
        wait(0);
     558:	4501                	li	a0,0
     55a:	00004097          	auipc	ra,0x4
     55e:	e50080e7          	jalr	-432(ra) # 43aa <wait>
      for(int j = 0; j < 200; j++){
     562:	34fd                	addiw	s1,s1,-1
     564:	f0fd                	bnez	s1,54a <forkfork+0x76>
      exit(0);
     566:	4501                	li	a0,0
     568:	00004097          	auipc	ra,0x4
     56c:	e3a080e7          	jalr	-454(ra) # 43a2 <exit>
          exit(1);
     570:	4505                	li	a0,1
     572:	00004097          	auipc	ra,0x4
     576:	e30080e7          	jalr	-464(ra) # 43a2 <exit>
          exit(0);
     57a:	00004097          	auipc	ra,0x4
     57e:	e28080e7          	jalr	-472(ra) # 43a2 <exit>
      printf("%s: fork in child failed", s);
     582:	85a6                	mv	a1,s1
     584:	00004517          	auipc	a0,0x4
     588:	7d450513          	addi	a0,a0,2004 # 4d58 <malloc+0x560>
     58c:	00004097          	auipc	ra,0x4
     590:	1ae080e7          	jalr	430(ra) # 473a <printf>
      exit(1);
     594:	4505                	li	a0,1
     596:	00004097          	auipc	ra,0x4
     59a:	e0c080e7          	jalr	-500(ra) # 43a2 <exit>

000000000000059e <reparent2>:
{
     59e:	1101                	addi	sp,sp,-32
     5a0:	ec06                	sd	ra,24(sp)
     5a2:	e822                	sd	s0,16(sp)
     5a4:	e426                	sd	s1,8(sp)
     5a6:	1000                	addi	s0,sp,32
     5a8:	32000493          	li	s1,800
    int pid1 = fork();
     5ac:	00004097          	auipc	ra,0x4
     5b0:	dee080e7          	jalr	-530(ra) # 439a <fork>
    if(pid1 < 0){
     5b4:	00054f63          	bltz	a0,5d2 <reparent2+0x34>
    if(pid1 == 0){
     5b8:	c915                	beqz	a0,5ec <reparent2+0x4e>
    wait(0);
     5ba:	4501                	li	a0,0
     5bc:	00004097          	auipc	ra,0x4
     5c0:	dee080e7          	jalr	-530(ra) # 43aa <wait>
  for(int i = 0; i < 800; i++){
     5c4:	34fd                	addiw	s1,s1,-1
     5c6:	f0fd                	bnez	s1,5ac <reparent2+0xe>
  exit(0);
     5c8:	4501                	li	a0,0
     5ca:	00004097          	auipc	ra,0x4
     5ce:	dd8080e7          	jalr	-552(ra) # 43a2 <exit>
      printf("fork failed\n");
     5d2:	00005517          	auipc	a0,0x5
     5d6:	00e50513          	addi	a0,a0,14 # 55e0 <malloc+0xde8>
     5da:	00004097          	auipc	ra,0x4
     5de:	160080e7          	jalr	352(ra) # 473a <printf>
      exit(1);
     5e2:	4505                	li	a0,1
     5e4:	00004097          	auipc	ra,0x4
     5e8:	dbe080e7          	jalr	-578(ra) # 43a2 <exit>
      fork();
     5ec:	00004097          	auipc	ra,0x4
     5f0:	dae080e7          	jalr	-594(ra) # 439a <fork>
      fork();
     5f4:	00004097          	auipc	ra,0x4
     5f8:	da6080e7          	jalr	-602(ra) # 439a <fork>
      exit(0);
     5fc:	4501                	li	a0,0
     5fe:	00004097          	auipc	ra,0x4
     602:	da4080e7          	jalr	-604(ra) # 43a2 <exit>

0000000000000606 <forktest>:
{
     606:	7179                	addi	sp,sp,-48
     608:	f406                	sd	ra,40(sp)
     60a:	f022                	sd	s0,32(sp)
     60c:	ec26                	sd	s1,24(sp)
     60e:	e84a                	sd	s2,16(sp)
     610:	e44e                	sd	s3,8(sp)
     612:	1800                	addi	s0,sp,48
     614:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
     616:	4481                	li	s1,0
     618:	3e800913          	li	s2,1000
    pid = fork();
     61c:	00004097          	auipc	ra,0x4
     620:	d7e080e7          	jalr	-642(ra) # 439a <fork>
    if(pid < 0)
     624:	02054863          	bltz	a0,654 <forktest+0x4e>
    if(pid == 0)
     628:	c115                	beqz	a0,64c <forktest+0x46>
  for(n=0; n<N; n++){
     62a:	2485                	addiw	s1,s1,1
     62c:	ff2498e3          	bne	s1,s2,61c <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
     630:	85ce                	mv	a1,s3
     632:	00004517          	auipc	a0,0x4
     636:	75e50513          	addi	a0,a0,1886 # 4d90 <malloc+0x598>
     63a:	00004097          	auipc	ra,0x4
     63e:	100080e7          	jalr	256(ra) # 473a <printf>
    exit(1);
     642:	4505                	li	a0,1
     644:	00004097          	auipc	ra,0x4
     648:	d5e080e7          	jalr	-674(ra) # 43a2 <exit>
      exit(0);
     64c:	00004097          	auipc	ra,0x4
     650:	d56080e7          	jalr	-682(ra) # 43a2 <exit>
  if (n == 0) {
     654:	cc9d                	beqz	s1,692 <forktest+0x8c>
  if(n == N){
     656:	3e800793          	li	a5,1000
     65a:	fcf48be3          	beq	s1,a5,630 <forktest+0x2a>
  for(; n > 0; n--){
     65e:	00905b63          	blez	s1,674 <forktest+0x6e>
    if(wait(0) < 0){
     662:	4501                	li	a0,0
     664:	00004097          	auipc	ra,0x4
     668:	d46080e7          	jalr	-698(ra) # 43aa <wait>
     66c:	04054163          	bltz	a0,6ae <forktest+0xa8>
  for(; n > 0; n--){
     670:	34fd                	addiw	s1,s1,-1
     672:	f8e5                	bnez	s1,662 <forktest+0x5c>
  if(wait(0) != -1){
     674:	4501                	li	a0,0
     676:	00004097          	auipc	ra,0x4
     67a:	d34080e7          	jalr	-716(ra) # 43aa <wait>
     67e:	57fd                	li	a5,-1
     680:	04f51563          	bne	a0,a5,6ca <forktest+0xc4>
}
     684:	70a2                	ld	ra,40(sp)
     686:	7402                	ld	s0,32(sp)
     688:	64e2                	ld	s1,24(sp)
     68a:	6942                	ld	s2,16(sp)
     68c:	69a2                	ld	s3,8(sp)
     68e:	6145                	addi	sp,sp,48
     690:	8082                	ret
    printf("%s: no fork at all!\n", s);
     692:	85ce                	mv	a1,s3
     694:	00004517          	auipc	a0,0x4
     698:	6e450513          	addi	a0,a0,1764 # 4d78 <malloc+0x580>
     69c:	00004097          	auipc	ra,0x4
     6a0:	09e080e7          	jalr	158(ra) # 473a <printf>
    exit(1);
     6a4:	4505                	li	a0,1
     6a6:	00004097          	auipc	ra,0x4
     6aa:	cfc080e7          	jalr	-772(ra) # 43a2 <exit>
      printf("%s: wait stopped early\n", s);
     6ae:	85ce                	mv	a1,s3
     6b0:	00004517          	auipc	a0,0x4
     6b4:	70850513          	addi	a0,a0,1800 # 4db8 <malloc+0x5c0>
     6b8:	00004097          	auipc	ra,0x4
     6bc:	082080e7          	jalr	130(ra) # 473a <printf>
      exit(1);
     6c0:	4505                	li	a0,1
     6c2:	00004097          	auipc	ra,0x4
     6c6:	ce0080e7          	jalr	-800(ra) # 43a2 <exit>
    printf("%s: wait got too many\n", s);
     6ca:	85ce                	mv	a1,s3
     6cc:	00004517          	auipc	a0,0x4
     6d0:	70450513          	addi	a0,a0,1796 # 4dd0 <malloc+0x5d8>
     6d4:	00004097          	auipc	ra,0x4
     6d8:	066080e7          	jalr	102(ra) # 473a <printf>
    exit(1);
     6dc:	4505                	li	a0,1
     6de:	00004097          	auipc	ra,0x4
     6e2:	cc4080e7          	jalr	-828(ra) # 43a2 <exit>

00000000000006e6 <kernmem>:
{
     6e6:	715d                	addi	sp,sp,-80
     6e8:	e486                	sd	ra,72(sp)
     6ea:	e0a2                	sd	s0,64(sp)
     6ec:	fc26                	sd	s1,56(sp)
     6ee:	f84a                	sd	s2,48(sp)
     6f0:	f44e                	sd	s3,40(sp)
     6f2:	f052                	sd	s4,32(sp)
     6f4:	ec56                	sd	s5,24(sp)
     6f6:	0880                	addi	s0,sp,80
     6f8:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
     6fa:	4485                	li	s1,1
     6fc:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
     6fe:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
     700:	69b1                	lui	s3,0xc
     702:	35098993          	addi	s3,s3,848 # c350 <__BSS_END__+0x1c0>
     706:	1003d937          	lui	s2,0x1003d
     70a:	090e                	slli	s2,s2,0x3
     70c:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x100312f0>
    pid = fork();
     710:	00004097          	auipc	ra,0x4
     714:	c8a080e7          	jalr	-886(ra) # 439a <fork>
    if(pid < 0){
     718:	02054963          	bltz	a0,74a <kernmem+0x64>
    if(pid == 0){
     71c:	c529                	beqz	a0,766 <kernmem+0x80>
    wait(&xstatus);
     71e:	fbc40513          	addi	a0,s0,-68
     722:	00004097          	auipc	ra,0x4
     726:	c88080e7          	jalr	-888(ra) # 43aa <wait>
    if(xstatus != -1)  // did kernel kill child?
     72a:	fbc42783          	lw	a5,-68(s0)
     72e:	05579c63          	bne	a5,s5,786 <kernmem+0xa0>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
     732:	94ce                	add	s1,s1,s3
     734:	fd249ee3          	bne	s1,s2,710 <kernmem+0x2a>
}
     738:	60a6                	ld	ra,72(sp)
     73a:	6406                	ld	s0,64(sp)
     73c:	74e2                	ld	s1,56(sp)
     73e:	7942                	ld	s2,48(sp)
     740:	79a2                	ld	s3,40(sp)
     742:	7a02                	ld	s4,32(sp)
     744:	6ae2                	ld	s5,24(sp)
     746:	6161                	addi	sp,sp,80
     748:	8082                	ret
      printf("%s: fork failed\n", s);
     74a:	85d2                	mv	a1,s4
     74c:	00004517          	auipc	a0,0x4
     750:	59450513          	addi	a0,a0,1428 # 4ce0 <malloc+0x4e8>
     754:	00004097          	auipc	ra,0x4
     758:	fe6080e7          	jalr	-26(ra) # 473a <printf>
      exit(1);
     75c:	4505                	li	a0,1
     75e:	00004097          	auipc	ra,0x4
     762:	c44080e7          	jalr	-956(ra) # 43a2 <exit>
      printf("%s: oops could read %x = %x\n", a, *a);
     766:	0004c603          	lbu	a2,0(s1)
     76a:	85a6                	mv	a1,s1
     76c:	00004517          	auipc	a0,0x4
     770:	67c50513          	addi	a0,a0,1660 # 4de8 <malloc+0x5f0>
     774:	00004097          	auipc	ra,0x4
     778:	fc6080e7          	jalr	-58(ra) # 473a <printf>
      exit(1);
     77c:	4505                	li	a0,1
     77e:	00004097          	auipc	ra,0x4
     782:	c24080e7          	jalr	-988(ra) # 43a2 <exit>
      exit(1);
     786:	4505                	li	a0,1
     788:	00004097          	auipc	ra,0x4
     78c:	c1a080e7          	jalr	-998(ra) # 43a2 <exit>

0000000000000790 <stacktest>:

// check that there's an invalid page beneath
// the user stack, to catch stack overflow.
void
stacktest(char *s)
{
     790:	7179                	addi	sp,sp,-48
     792:	f406                	sd	ra,40(sp)
     794:	f022                	sd	s0,32(sp)
     796:	ec26                	sd	s1,24(sp)
     798:	1800                	addi	s0,sp,48
     79a:	84aa                	mv	s1,a0
  int pid;
  int xstatus;
  
  pid = fork();
     79c:	00004097          	auipc	ra,0x4
     7a0:	bfe080e7          	jalr	-1026(ra) # 439a <fork>
  if(pid == 0) {
     7a4:	c115                	beqz	a0,7c8 <stacktest+0x38>
    char *sp = (char *) r_sp();
    sp -= PGSIZE;
    // the *sp should cause a trap.
    printf("%s: stacktest: read below stack %p\n", *sp);
    exit(1);
  } else if(pid < 0){
     7a6:	04054363          	bltz	a0,7ec <stacktest+0x5c>
    printf("%s: fork failed\n", s);
    exit(1);
  }
  wait(&xstatus);
     7aa:	fdc40513          	addi	a0,s0,-36
     7ae:	00004097          	auipc	ra,0x4
     7b2:	bfc080e7          	jalr	-1028(ra) # 43aa <wait>
  if(xstatus == -1)  // kernel killed child?
     7b6:	fdc42503          	lw	a0,-36(s0)
     7ba:	57fd                	li	a5,-1
     7bc:	04f50663          	beq	a0,a5,808 <stacktest+0x78>
    exit(0);
  else
    exit(xstatus);
     7c0:	00004097          	auipc	ra,0x4
     7c4:	be2080e7          	jalr	-1054(ra) # 43a2 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
     7c8:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", *sp);
     7ca:	77fd                	lui	a5,0xfffff
     7cc:	97ba                	add	a5,a5,a4
     7ce:	0007c583          	lbu	a1,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff2e70>
     7d2:	00004517          	auipc	a0,0x4
     7d6:	63650513          	addi	a0,a0,1590 # 4e08 <malloc+0x610>
     7da:	00004097          	auipc	ra,0x4
     7de:	f60080e7          	jalr	-160(ra) # 473a <printf>
    exit(1);
     7e2:	4505                	li	a0,1
     7e4:	00004097          	auipc	ra,0x4
     7e8:	bbe080e7          	jalr	-1090(ra) # 43a2 <exit>
    printf("%s: fork failed\n", s);
     7ec:	85a6                	mv	a1,s1
     7ee:	00004517          	auipc	a0,0x4
     7f2:	4f250513          	addi	a0,a0,1266 # 4ce0 <malloc+0x4e8>
     7f6:	00004097          	auipc	ra,0x4
     7fa:	f44080e7          	jalr	-188(ra) # 473a <printf>
    exit(1);
     7fe:	4505                	li	a0,1
     800:	00004097          	auipc	ra,0x4
     804:	ba2080e7          	jalr	-1118(ra) # 43a2 <exit>
    exit(0);
     808:	4501                	li	a0,0
     80a:	00004097          	auipc	ra,0x4
     80e:	b98080e7          	jalr	-1128(ra) # 43a2 <exit>

0000000000000812 <openiputtest>:
{
     812:	7179                	addi	sp,sp,-48
     814:	f406                	sd	ra,40(sp)
     816:	f022                	sd	s0,32(sp)
     818:	ec26                	sd	s1,24(sp)
     81a:	1800                	addi	s0,sp,48
     81c:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
     81e:	00004517          	auipc	a0,0x4
     822:	61250513          	addi	a0,a0,1554 # 4e30 <malloc+0x638>
     826:	00004097          	auipc	ra,0x4
     82a:	be4080e7          	jalr	-1052(ra) # 440a <mkdir>
     82e:	04054263          	bltz	a0,872 <openiputtest+0x60>
  pid = fork();
     832:	00004097          	auipc	ra,0x4
     836:	b68080e7          	jalr	-1176(ra) # 439a <fork>
  if(pid < 0){
     83a:	04054a63          	bltz	a0,88e <openiputtest+0x7c>
  if(pid == 0){
     83e:	e93d                	bnez	a0,8b4 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
     840:	4589                	li	a1,2
     842:	00004517          	auipc	a0,0x4
     846:	5ee50513          	addi	a0,a0,1518 # 4e30 <malloc+0x638>
     84a:	00004097          	auipc	ra,0x4
     84e:	b98080e7          	jalr	-1128(ra) # 43e2 <open>
    if(fd >= 0){
     852:	04054c63          	bltz	a0,8aa <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
     856:	85a6                	mv	a1,s1
     858:	00004517          	auipc	a0,0x4
     85c:	5f850513          	addi	a0,a0,1528 # 4e50 <malloc+0x658>
     860:	00004097          	auipc	ra,0x4
     864:	eda080e7          	jalr	-294(ra) # 473a <printf>
      exit(1);
     868:	4505                	li	a0,1
     86a:	00004097          	auipc	ra,0x4
     86e:	b38080e7          	jalr	-1224(ra) # 43a2 <exit>
    printf("%s: mkdir oidir failed\n", s);
     872:	85a6                	mv	a1,s1
     874:	00004517          	auipc	a0,0x4
     878:	5c450513          	addi	a0,a0,1476 # 4e38 <malloc+0x640>
     87c:	00004097          	auipc	ra,0x4
     880:	ebe080e7          	jalr	-322(ra) # 473a <printf>
    exit(1);
     884:	4505                	li	a0,1
     886:	00004097          	auipc	ra,0x4
     88a:	b1c080e7          	jalr	-1252(ra) # 43a2 <exit>
    printf("%s: fork failed\n", s);
     88e:	85a6                	mv	a1,s1
     890:	00004517          	auipc	a0,0x4
     894:	45050513          	addi	a0,a0,1104 # 4ce0 <malloc+0x4e8>
     898:	00004097          	auipc	ra,0x4
     89c:	ea2080e7          	jalr	-350(ra) # 473a <printf>
    exit(1);
     8a0:	4505                	li	a0,1
     8a2:	00004097          	auipc	ra,0x4
     8a6:	b00080e7          	jalr	-1280(ra) # 43a2 <exit>
    exit(0);
     8aa:	4501                	li	a0,0
     8ac:	00004097          	auipc	ra,0x4
     8b0:	af6080e7          	jalr	-1290(ra) # 43a2 <exit>
  sleep(1);
     8b4:	4505                	li	a0,1
     8b6:	00004097          	auipc	ra,0x4
     8ba:	b7c080e7          	jalr	-1156(ra) # 4432 <sleep>
  if(unlink("oidir") != 0){
     8be:	00004517          	auipc	a0,0x4
     8c2:	57250513          	addi	a0,a0,1394 # 4e30 <malloc+0x638>
     8c6:	00004097          	auipc	ra,0x4
     8ca:	b2c080e7          	jalr	-1236(ra) # 43f2 <unlink>
     8ce:	cd19                	beqz	a0,8ec <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
     8d0:	85a6                	mv	a1,s1
     8d2:	00004517          	auipc	a0,0x4
     8d6:	5a650513          	addi	a0,a0,1446 # 4e78 <malloc+0x680>
     8da:	00004097          	auipc	ra,0x4
     8de:	e60080e7          	jalr	-416(ra) # 473a <printf>
    exit(1);
     8e2:	4505                	li	a0,1
     8e4:	00004097          	auipc	ra,0x4
     8e8:	abe080e7          	jalr	-1346(ra) # 43a2 <exit>
  wait(&xstatus);
     8ec:	fdc40513          	addi	a0,s0,-36
     8f0:	00004097          	auipc	ra,0x4
     8f4:	aba080e7          	jalr	-1350(ra) # 43aa <wait>
  exit(xstatus);
     8f8:	fdc42503          	lw	a0,-36(s0)
     8fc:	00004097          	auipc	ra,0x4
     900:	aa6080e7          	jalr	-1370(ra) # 43a2 <exit>

0000000000000904 <opentest>:
{
     904:	1101                	addi	sp,sp,-32
     906:	ec06                	sd	ra,24(sp)
     908:	e822                	sd	s0,16(sp)
     90a:	e426                	sd	s1,8(sp)
     90c:	1000                	addi	s0,sp,32
     90e:	84aa                	mv	s1,a0
  fd = open("echo", 0);
     910:	4581                	li	a1,0
     912:	00004517          	auipc	a0,0x4
     916:	57e50513          	addi	a0,a0,1406 # 4e90 <malloc+0x698>
     91a:	00004097          	auipc	ra,0x4
     91e:	ac8080e7          	jalr	-1336(ra) # 43e2 <open>
  if(fd < 0){
     922:	02054663          	bltz	a0,94e <opentest+0x4a>
  close(fd);
     926:	00004097          	auipc	ra,0x4
     92a:	aa4080e7          	jalr	-1372(ra) # 43ca <close>
  fd = open("doesnotexist", 0);
     92e:	4581                	li	a1,0
     930:	00004517          	auipc	a0,0x4
     934:	58050513          	addi	a0,a0,1408 # 4eb0 <malloc+0x6b8>
     938:	00004097          	auipc	ra,0x4
     93c:	aaa080e7          	jalr	-1366(ra) # 43e2 <open>
  if(fd >= 0){
     940:	02055563          	bgez	a0,96a <opentest+0x66>
}
     944:	60e2                	ld	ra,24(sp)
     946:	6442                	ld	s0,16(sp)
     948:	64a2                	ld	s1,8(sp)
     94a:	6105                	addi	sp,sp,32
     94c:	8082                	ret
    printf("%s: open echo failed!\n", s);
     94e:	85a6                	mv	a1,s1
     950:	00004517          	auipc	a0,0x4
     954:	54850513          	addi	a0,a0,1352 # 4e98 <malloc+0x6a0>
     958:	00004097          	auipc	ra,0x4
     95c:	de2080e7          	jalr	-542(ra) # 473a <printf>
    exit(1);
     960:	4505                	li	a0,1
     962:	00004097          	auipc	ra,0x4
     966:	a40080e7          	jalr	-1472(ra) # 43a2 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     96a:	85a6                	mv	a1,s1
     96c:	00004517          	auipc	a0,0x4
     970:	55450513          	addi	a0,a0,1364 # 4ec0 <malloc+0x6c8>
     974:	00004097          	auipc	ra,0x4
     978:	dc6080e7          	jalr	-570(ra) # 473a <printf>
    exit(1);
     97c:	4505                	li	a0,1
     97e:	00004097          	auipc	ra,0x4
     982:	a24080e7          	jalr	-1500(ra) # 43a2 <exit>

0000000000000986 <createtest>:
{
     986:	7179                	addi	sp,sp,-48
     988:	f406                	sd	ra,40(sp)
     98a:	f022                	sd	s0,32(sp)
     98c:	ec26                	sd	s1,24(sp)
     98e:	e84a                	sd	s2,16(sp)
     990:	e44e                	sd	s3,8(sp)
     992:	1800                	addi	s0,sp,48
  name[0] = 'a';
     994:	00006797          	auipc	a5,0x6
     998:	fcc78793          	addi	a5,a5,-52 # 6960 <name>
     99c:	06100713          	li	a4,97
     9a0:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     9a4:	00078123          	sb	zero,2(a5)
     9a8:	03000493          	li	s1,48
    name[1] = '0' + i;
     9ac:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     9ae:	06400993          	li	s3,100
    name[1] = '0' + i;
     9b2:	009900a3          	sb	s1,1(s2)
    fd = open(name, O_CREATE|O_RDWR);
     9b6:	20200593          	li	a1,514
     9ba:	854a                	mv	a0,s2
     9bc:	00004097          	auipc	ra,0x4
     9c0:	a26080e7          	jalr	-1498(ra) # 43e2 <open>
    close(fd);
     9c4:	00004097          	auipc	ra,0x4
     9c8:	a06080e7          	jalr	-1530(ra) # 43ca <close>
  for(i = 0; i < N; i++){
     9cc:	2485                	addiw	s1,s1,1
     9ce:	0ff4f493          	andi	s1,s1,255
     9d2:	ff3490e3          	bne	s1,s3,9b2 <createtest+0x2c>
  name[0] = 'a';
     9d6:	00006797          	auipc	a5,0x6
     9da:	f8a78793          	addi	a5,a5,-118 # 6960 <name>
     9de:	06100713          	li	a4,97
     9e2:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     9e6:	00078123          	sb	zero,2(a5)
     9ea:	03000493          	li	s1,48
    name[1] = '0' + i;
     9ee:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     9f0:	06400993          	li	s3,100
    name[1] = '0' + i;
     9f4:	009900a3          	sb	s1,1(s2)
    unlink(name);
     9f8:	854a                	mv	a0,s2
     9fa:	00004097          	auipc	ra,0x4
     9fe:	9f8080e7          	jalr	-1544(ra) # 43f2 <unlink>
  for(i = 0; i < N; i++){
     a02:	2485                	addiw	s1,s1,1
     a04:	0ff4f493          	andi	s1,s1,255
     a08:	ff3496e3          	bne	s1,s3,9f4 <createtest+0x6e>
}
     a0c:	70a2                	ld	ra,40(sp)
     a0e:	7402                	ld	s0,32(sp)
     a10:	64e2                	ld	s1,24(sp)
     a12:	6942                	ld	s2,16(sp)
     a14:	69a2                	ld	s3,8(sp)
     a16:	6145                	addi	sp,sp,48
     a18:	8082                	ret

0000000000000a1a <forkforkfork>:
{
     a1a:	1101                	addi	sp,sp,-32
     a1c:	ec06                	sd	ra,24(sp)
     a1e:	e822                	sd	s0,16(sp)
     a20:	e426                	sd	s1,8(sp)
     a22:	1000                	addi	s0,sp,32
     a24:	84aa                	mv	s1,a0
  unlink("stopforking");
     a26:	00004517          	auipc	a0,0x4
     a2a:	4c250513          	addi	a0,a0,1218 # 4ee8 <malloc+0x6f0>
     a2e:	00004097          	auipc	ra,0x4
     a32:	9c4080e7          	jalr	-1596(ra) # 43f2 <unlink>
  int pid = fork();
     a36:	00004097          	auipc	ra,0x4
     a3a:	964080e7          	jalr	-1692(ra) # 439a <fork>
  if(pid < 0){
     a3e:	04054563          	bltz	a0,a88 <forkforkfork+0x6e>
  if(pid == 0){
     a42:	c12d                	beqz	a0,aa4 <forkforkfork+0x8a>
  sleep(20); // two seconds
     a44:	4551                	li	a0,20
     a46:	00004097          	auipc	ra,0x4
     a4a:	9ec080e7          	jalr	-1556(ra) # 4432 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
     a4e:	20200593          	li	a1,514
     a52:	00004517          	auipc	a0,0x4
     a56:	49650513          	addi	a0,a0,1174 # 4ee8 <malloc+0x6f0>
     a5a:	00004097          	auipc	ra,0x4
     a5e:	988080e7          	jalr	-1656(ra) # 43e2 <open>
     a62:	00004097          	auipc	ra,0x4
     a66:	968080e7          	jalr	-1688(ra) # 43ca <close>
  wait(0);
     a6a:	4501                	li	a0,0
     a6c:	00004097          	auipc	ra,0x4
     a70:	93e080e7          	jalr	-1730(ra) # 43aa <wait>
  sleep(10); // one second
     a74:	4529                	li	a0,10
     a76:	00004097          	auipc	ra,0x4
     a7a:	9bc080e7          	jalr	-1604(ra) # 4432 <sleep>
}
     a7e:	60e2                	ld	ra,24(sp)
     a80:	6442                	ld	s0,16(sp)
     a82:	64a2                	ld	s1,8(sp)
     a84:	6105                	addi	sp,sp,32
     a86:	8082                	ret
    printf("%s: fork failed", s);
     a88:	85a6                	mv	a1,s1
     a8a:	00004517          	auipc	a0,0x4
     a8e:	2be50513          	addi	a0,a0,702 # 4d48 <malloc+0x550>
     a92:	00004097          	auipc	ra,0x4
     a96:	ca8080e7          	jalr	-856(ra) # 473a <printf>
    exit(1);
     a9a:	4505                	li	a0,1
     a9c:	00004097          	auipc	ra,0x4
     aa0:	906080e7          	jalr	-1786(ra) # 43a2 <exit>
      int fd = open("stopforking", 0);
     aa4:	00004497          	auipc	s1,0x4
     aa8:	44448493          	addi	s1,s1,1092 # 4ee8 <malloc+0x6f0>
     aac:	4581                	li	a1,0
     aae:	8526                	mv	a0,s1
     ab0:	00004097          	auipc	ra,0x4
     ab4:	932080e7          	jalr	-1742(ra) # 43e2 <open>
      if(fd >= 0){
     ab8:	02055463          	bgez	a0,ae0 <forkforkfork+0xc6>
      if(fork() < 0){
     abc:	00004097          	auipc	ra,0x4
     ac0:	8de080e7          	jalr	-1826(ra) # 439a <fork>
     ac4:	fe0554e3          	bgez	a0,aac <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
     ac8:	20200593          	li	a1,514
     acc:	8526                	mv	a0,s1
     ace:	00004097          	auipc	ra,0x4
     ad2:	914080e7          	jalr	-1772(ra) # 43e2 <open>
     ad6:	00004097          	auipc	ra,0x4
     ada:	8f4080e7          	jalr	-1804(ra) # 43ca <close>
     ade:	b7f9                	j	aac <forkforkfork+0x92>
        exit(0);
     ae0:	4501                	li	a0,0
     ae2:	00004097          	auipc	ra,0x4
     ae6:	8c0080e7          	jalr	-1856(ra) # 43a2 <exit>

0000000000000aea <createdelete>:
{
     aea:	7175                	addi	sp,sp,-144
     aec:	e506                	sd	ra,136(sp)
     aee:	e122                	sd	s0,128(sp)
     af0:	fca6                	sd	s1,120(sp)
     af2:	f8ca                	sd	s2,112(sp)
     af4:	f4ce                	sd	s3,104(sp)
     af6:	f0d2                	sd	s4,96(sp)
     af8:	ecd6                	sd	s5,88(sp)
     afa:	e8da                	sd	s6,80(sp)
     afc:	e4de                	sd	s7,72(sp)
     afe:	e0e2                	sd	s8,64(sp)
     b00:	fc66                	sd	s9,56(sp)
     b02:	0900                	addi	s0,sp,144
     b04:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
     b06:	4901                	li	s2,0
     b08:	4991                	li	s3,4
    pid = fork();
     b0a:	00004097          	auipc	ra,0x4
     b0e:	890080e7          	jalr	-1904(ra) # 439a <fork>
     b12:	84aa                	mv	s1,a0
    if(pid < 0){
     b14:	02054f63          	bltz	a0,b52 <createdelete+0x68>
    if(pid == 0){
     b18:	c939                	beqz	a0,b6e <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
     b1a:	2905                	addiw	s2,s2,1
     b1c:	ff3917e3          	bne	s2,s3,b0a <createdelete+0x20>
     b20:	4491                	li	s1,4
    wait(&xstatus);
     b22:	f7c40513          	addi	a0,s0,-132
     b26:	00004097          	auipc	ra,0x4
     b2a:	884080e7          	jalr	-1916(ra) # 43aa <wait>
    if(xstatus != 0)
     b2e:	f7c42903          	lw	s2,-132(s0)
     b32:	0e091263          	bnez	s2,c16 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
     b36:	34fd                	addiw	s1,s1,-1
     b38:	f4ed                	bnez	s1,b22 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
     b3a:	f8040123          	sb	zero,-126(s0)
     b3e:	03000993          	li	s3,48
     b42:	5a7d                	li	s4,-1
     b44:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
     b48:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
     b4a:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
     b4c:	07400a93          	li	s5,116
     b50:	a29d                	j	cb6 <createdelete+0x1cc>
      printf("fork failed\n", s);
     b52:	85e6                	mv	a1,s9
     b54:	00005517          	auipc	a0,0x5
     b58:	a8c50513          	addi	a0,a0,-1396 # 55e0 <malloc+0xde8>
     b5c:	00004097          	auipc	ra,0x4
     b60:	bde080e7          	jalr	-1058(ra) # 473a <printf>
      exit(1);
     b64:	4505                	li	a0,1
     b66:	00004097          	auipc	ra,0x4
     b6a:	83c080e7          	jalr	-1988(ra) # 43a2 <exit>
      name[0] = 'p' + pi;
     b6e:	0709091b          	addiw	s2,s2,112
     b72:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
     b76:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
     b7a:	4951                	li	s2,20
     b7c:	a015                	j	ba0 <createdelete+0xb6>
          printf("%s: create failed\n", s);
     b7e:	85e6                	mv	a1,s9
     b80:	00004517          	auipc	a0,0x4
     b84:	37850513          	addi	a0,a0,888 # 4ef8 <malloc+0x700>
     b88:	00004097          	auipc	ra,0x4
     b8c:	bb2080e7          	jalr	-1102(ra) # 473a <printf>
          exit(1);
     b90:	4505                	li	a0,1
     b92:	00004097          	auipc	ra,0x4
     b96:	810080e7          	jalr	-2032(ra) # 43a2 <exit>
      for(i = 0; i < N; i++){
     b9a:	2485                	addiw	s1,s1,1
     b9c:	07248863          	beq	s1,s2,c0c <createdelete+0x122>
        name[1] = '0' + i;
     ba0:	0304879b          	addiw	a5,s1,48
     ba4:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
     ba8:	20200593          	li	a1,514
     bac:	f8040513          	addi	a0,s0,-128
     bb0:	00004097          	auipc	ra,0x4
     bb4:	832080e7          	jalr	-1998(ra) # 43e2 <open>
        if(fd < 0){
     bb8:	fc0543e3          	bltz	a0,b7e <createdelete+0x94>
        close(fd);
     bbc:	00004097          	auipc	ra,0x4
     bc0:	80e080e7          	jalr	-2034(ra) # 43ca <close>
        if(i > 0 && (i % 2 ) == 0){
     bc4:	fc905be3          	blez	s1,b9a <createdelete+0xb0>
     bc8:	0014f793          	andi	a5,s1,1
     bcc:	f7f9                	bnez	a5,b9a <createdelete+0xb0>
          name[1] = '0' + (i / 2);
     bce:	01f4d79b          	srliw	a5,s1,0x1f
     bd2:	9fa5                	addw	a5,a5,s1
     bd4:	4017d79b          	sraiw	a5,a5,0x1
     bd8:	0307879b          	addiw	a5,a5,48
     bdc:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
     be0:	f8040513          	addi	a0,s0,-128
     be4:	00004097          	auipc	ra,0x4
     be8:	80e080e7          	jalr	-2034(ra) # 43f2 <unlink>
     bec:	fa0557e3          	bgez	a0,b9a <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
     bf0:	85e6                	mv	a1,s9
     bf2:	00004517          	auipc	a0,0x4
     bf6:	28650513          	addi	a0,a0,646 # 4e78 <malloc+0x680>
     bfa:	00004097          	auipc	ra,0x4
     bfe:	b40080e7          	jalr	-1216(ra) # 473a <printf>
            exit(1);
     c02:	4505                	li	a0,1
     c04:	00003097          	auipc	ra,0x3
     c08:	79e080e7          	jalr	1950(ra) # 43a2 <exit>
      exit(0);
     c0c:	4501                	li	a0,0
     c0e:	00003097          	auipc	ra,0x3
     c12:	794080e7          	jalr	1940(ra) # 43a2 <exit>
      exit(1);
     c16:	4505                	li	a0,1
     c18:	00003097          	auipc	ra,0x3
     c1c:	78a080e7          	jalr	1930(ra) # 43a2 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
     c20:	f8040613          	addi	a2,s0,-128
     c24:	85e6                	mv	a1,s9
     c26:	00004517          	auipc	a0,0x4
     c2a:	2ea50513          	addi	a0,a0,746 # 4f10 <malloc+0x718>
     c2e:	00004097          	auipc	ra,0x4
     c32:	b0c080e7          	jalr	-1268(ra) # 473a <printf>
        exit(1);
     c36:	4505                	li	a0,1
     c38:	00003097          	auipc	ra,0x3
     c3c:	76a080e7          	jalr	1898(ra) # 43a2 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
     c40:	054b7163          	bgeu	s6,s4,c82 <createdelete+0x198>
      if(fd >= 0)
     c44:	02055a63          	bgez	a0,c78 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
     c48:	2485                	addiw	s1,s1,1
     c4a:	0ff4f493          	andi	s1,s1,255
     c4e:	05548c63          	beq	s1,s5,ca6 <createdelete+0x1bc>
      name[0] = 'p' + pi;
     c52:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
     c56:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
     c5a:	4581                	li	a1,0
     c5c:	f8040513          	addi	a0,s0,-128
     c60:	00003097          	auipc	ra,0x3
     c64:	782080e7          	jalr	1922(ra) # 43e2 <open>
      if((i == 0 || i >= N/2) && fd < 0){
     c68:	00090463          	beqz	s2,c70 <createdelete+0x186>
     c6c:	fd2bdae3          	bge	s7,s2,c40 <createdelete+0x156>
     c70:	fa0548e3          	bltz	a0,c20 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
     c74:	014b7963          	bgeu	s6,s4,c86 <createdelete+0x19c>
        close(fd);
     c78:	00003097          	auipc	ra,0x3
     c7c:	752080e7          	jalr	1874(ra) # 43ca <close>
     c80:	b7e1                	j	c48 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
     c82:	fc0543e3          	bltz	a0,c48 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
     c86:	f8040613          	addi	a2,s0,-128
     c8a:	85e6                	mv	a1,s9
     c8c:	00004517          	auipc	a0,0x4
     c90:	2ac50513          	addi	a0,a0,684 # 4f38 <malloc+0x740>
     c94:	00004097          	auipc	ra,0x4
     c98:	aa6080e7          	jalr	-1370(ra) # 473a <printf>
        exit(1);
     c9c:	4505                	li	a0,1
     c9e:	00003097          	auipc	ra,0x3
     ca2:	704080e7          	jalr	1796(ra) # 43a2 <exit>
  for(i = 0; i < N; i++){
     ca6:	2905                	addiw	s2,s2,1
     ca8:	2a05                	addiw	s4,s4,1
     caa:	2985                	addiw	s3,s3,1
     cac:	0ff9f993          	andi	s3,s3,255
     cb0:	47d1                	li	a5,20
     cb2:	02f90a63          	beq	s2,a5,ce6 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
     cb6:	84e2                	mv	s1,s8
     cb8:	bf69                	j	c52 <createdelete+0x168>
  for(i = 0; i < N; i++){
     cba:	2905                	addiw	s2,s2,1
     cbc:	0ff97913          	andi	s2,s2,255
     cc0:	2985                	addiw	s3,s3,1
     cc2:	0ff9f993          	andi	s3,s3,255
     cc6:	03490863          	beq	s2,s4,cf6 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
     cca:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
     ccc:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
     cd0:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
     cd4:	f8040513          	addi	a0,s0,-128
     cd8:	00003097          	auipc	ra,0x3
     cdc:	71a080e7          	jalr	1818(ra) # 43f2 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
     ce0:	34fd                	addiw	s1,s1,-1
     ce2:	f4ed                	bnez	s1,ccc <createdelete+0x1e2>
     ce4:	bfd9                	j	cba <createdelete+0x1d0>
     ce6:	03000993          	li	s3,48
     cea:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
     cee:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
     cf0:	08400a13          	li	s4,132
     cf4:	bfd9                	j	cca <createdelete+0x1e0>
}
     cf6:	60aa                	ld	ra,136(sp)
     cf8:	640a                	ld	s0,128(sp)
     cfa:	74e6                	ld	s1,120(sp)
     cfc:	7946                	ld	s2,112(sp)
     cfe:	79a6                	ld	s3,104(sp)
     d00:	7a06                	ld	s4,96(sp)
     d02:	6ae6                	ld	s5,88(sp)
     d04:	6b46                	ld	s6,80(sp)
     d06:	6ba6                	ld	s7,72(sp)
     d08:	6c06                	ld	s8,64(sp)
     d0a:	7ce2                	ld	s9,56(sp)
     d0c:	6149                	addi	sp,sp,144
     d0e:	8082                	ret

0000000000000d10 <fourteen>:
{
     d10:	1101                	addi	sp,sp,-32
     d12:	ec06                	sd	ra,24(sp)
     d14:	e822                	sd	s0,16(sp)
     d16:	e426                	sd	s1,8(sp)
     d18:	1000                	addi	s0,sp,32
     d1a:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
     d1c:	00004517          	auipc	a0,0x4
     d20:	41450513          	addi	a0,a0,1044 # 5130 <malloc+0x938>
     d24:	00003097          	auipc	ra,0x3
     d28:	6e6080e7          	jalr	1766(ra) # 440a <mkdir>
     d2c:	e141                	bnez	a0,dac <fourteen+0x9c>
  if(mkdir("12345678901234/123456789012345") != 0){
     d2e:	00004517          	auipc	a0,0x4
     d32:	25a50513          	addi	a0,a0,602 # 4f88 <malloc+0x790>
     d36:	00003097          	auipc	ra,0x3
     d3a:	6d4080e7          	jalr	1748(ra) # 440a <mkdir>
     d3e:	e549                	bnez	a0,dc8 <fourteen+0xb8>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
     d40:	20000593          	li	a1,512
     d44:	00004517          	auipc	a0,0x4
     d48:	29c50513          	addi	a0,a0,668 # 4fe0 <malloc+0x7e8>
     d4c:	00003097          	auipc	ra,0x3
     d50:	696080e7          	jalr	1686(ra) # 43e2 <open>
  if(fd < 0){
     d54:	08054863          	bltz	a0,de4 <fourteen+0xd4>
  close(fd);
     d58:	00003097          	auipc	ra,0x3
     d5c:	672080e7          	jalr	1650(ra) # 43ca <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
     d60:	4581                	li	a1,0
     d62:	00004517          	auipc	a0,0x4
     d66:	2f650513          	addi	a0,a0,758 # 5058 <malloc+0x860>
     d6a:	00003097          	auipc	ra,0x3
     d6e:	678080e7          	jalr	1656(ra) # 43e2 <open>
  if(fd < 0){
     d72:	08054763          	bltz	a0,e00 <fourteen+0xf0>
  close(fd);
     d76:	00003097          	auipc	ra,0x3
     d7a:	654080e7          	jalr	1620(ra) # 43ca <close>
  if(mkdir("12345678901234/12345678901234") == 0){
     d7e:	00004517          	auipc	a0,0x4
     d82:	34a50513          	addi	a0,a0,842 # 50c8 <malloc+0x8d0>
     d86:	00003097          	auipc	ra,0x3
     d8a:	684080e7          	jalr	1668(ra) # 440a <mkdir>
     d8e:	c559                	beqz	a0,e1c <fourteen+0x10c>
  if(mkdir("123456789012345/12345678901234") == 0){
     d90:	00004517          	auipc	a0,0x4
     d94:	39050513          	addi	a0,a0,912 # 5120 <malloc+0x928>
     d98:	00003097          	auipc	ra,0x3
     d9c:	672080e7          	jalr	1650(ra) # 440a <mkdir>
     da0:	cd41                	beqz	a0,e38 <fourteen+0x128>
}
     da2:	60e2                	ld	ra,24(sp)
     da4:	6442                	ld	s0,16(sp)
     da6:	64a2                	ld	s1,8(sp)
     da8:	6105                	addi	sp,sp,32
     daa:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
     dac:	85a6                	mv	a1,s1
     dae:	00004517          	auipc	a0,0x4
     db2:	1b250513          	addi	a0,a0,434 # 4f60 <malloc+0x768>
     db6:	00004097          	auipc	ra,0x4
     dba:	984080e7          	jalr	-1660(ra) # 473a <printf>
    exit(1);
     dbe:	4505                	li	a0,1
     dc0:	00003097          	auipc	ra,0x3
     dc4:	5e2080e7          	jalr	1506(ra) # 43a2 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
     dc8:	85a6                	mv	a1,s1
     dca:	00004517          	auipc	a0,0x4
     dce:	1de50513          	addi	a0,a0,478 # 4fa8 <malloc+0x7b0>
     dd2:	00004097          	auipc	ra,0x4
     dd6:	968080e7          	jalr	-1688(ra) # 473a <printf>
    exit(1);
     dda:	4505                	li	a0,1
     ddc:	00003097          	auipc	ra,0x3
     de0:	5c6080e7          	jalr	1478(ra) # 43a2 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
     de4:	85a6                	mv	a1,s1
     de6:	00004517          	auipc	a0,0x4
     dea:	22a50513          	addi	a0,a0,554 # 5010 <malloc+0x818>
     dee:	00004097          	auipc	ra,0x4
     df2:	94c080e7          	jalr	-1716(ra) # 473a <printf>
    exit(1);
     df6:	4505                	li	a0,1
     df8:	00003097          	auipc	ra,0x3
     dfc:	5aa080e7          	jalr	1450(ra) # 43a2 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
     e00:	85a6                	mv	a1,s1
     e02:	00004517          	auipc	a0,0x4
     e06:	28650513          	addi	a0,a0,646 # 5088 <malloc+0x890>
     e0a:	00004097          	auipc	ra,0x4
     e0e:	930080e7          	jalr	-1744(ra) # 473a <printf>
    exit(1);
     e12:	4505                	li	a0,1
     e14:	00003097          	auipc	ra,0x3
     e18:	58e080e7          	jalr	1422(ra) # 43a2 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
     e1c:	85a6                	mv	a1,s1
     e1e:	00004517          	auipc	a0,0x4
     e22:	2ca50513          	addi	a0,a0,714 # 50e8 <malloc+0x8f0>
     e26:	00004097          	auipc	ra,0x4
     e2a:	914080e7          	jalr	-1772(ra) # 473a <printf>
    exit(1);
     e2e:	4505                	li	a0,1
     e30:	00003097          	auipc	ra,0x3
     e34:	572080e7          	jalr	1394(ra) # 43a2 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
     e38:	85a6                	mv	a1,s1
     e3a:	00004517          	auipc	a0,0x4
     e3e:	30650513          	addi	a0,a0,774 # 5140 <malloc+0x948>
     e42:	00004097          	auipc	ra,0x4
     e46:	8f8080e7          	jalr	-1800(ra) # 473a <printf>
    exit(1);
     e4a:	4505                	li	a0,1
     e4c:	00003097          	auipc	ra,0x3
     e50:	556080e7          	jalr	1366(ra) # 43a2 <exit>

0000000000000e54 <bigwrite>:
{
     e54:	715d                	addi	sp,sp,-80
     e56:	e486                	sd	ra,72(sp)
     e58:	e0a2                	sd	s0,64(sp)
     e5a:	fc26                	sd	s1,56(sp)
     e5c:	f84a                	sd	s2,48(sp)
     e5e:	f44e                	sd	s3,40(sp)
     e60:	f052                	sd	s4,32(sp)
     e62:	ec56                	sd	s5,24(sp)
     e64:	e85a                	sd	s6,16(sp)
     e66:	e45e                	sd	s7,8(sp)
     e68:	0880                	addi	s0,sp,80
     e6a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     e6c:	00004517          	auipc	a0,0x4
     e70:	bac50513          	addi	a0,a0,-1108 # 4a18 <malloc+0x220>
     e74:	00003097          	auipc	ra,0x3
     e78:	57e080e7          	jalr	1406(ra) # 43f2 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     e7c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     e80:	00004a97          	auipc	s5,0x4
     e84:	b98a8a93          	addi	s5,s5,-1128 # 4a18 <malloc+0x220>
      int cc = write(fd, buf, sz);
     e88:	00008a17          	auipc	s4,0x8
     e8c:	2f8a0a13          	addi	s4,s4,760 # 9180 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     e90:	6b0d                	lui	s6,0x3
     e92:	1c9b0b13          	addi	s6,s6,457 # 31c9 <dirfile+0xbb>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     e96:	20200593          	li	a1,514
     e9a:	8556                	mv	a0,s5
     e9c:	00003097          	auipc	ra,0x3
     ea0:	546080e7          	jalr	1350(ra) # 43e2 <open>
     ea4:	892a                	mv	s2,a0
    if(fd < 0){
     ea6:	04054d63          	bltz	a0,f00 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     eaa:	8626                	mv	a2,s1
     eac:	85d2                	mv	a1,s4
     eae:	00003097          	auipc	ra,0x3
     eb2:	514080e7          	jalr	1300(ra) # 43c2 <write>
     eb6:	89aa                	mv	s3,a0
      if(cc != sz){
     eb8:	06a49463          	bne	s1,a0,f20 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     ebc:	8626                	mv	a2,s1
     ebe:	85d2                	mv	a1,s4
     ec0:	854a                	mv	a0,s2
     ec2:	00003097          	auipc	ra,0x3
     ec6:	500080e7          	jalr	1280(ra) # 43c2 <write>
      if(cc != sz){
     eca:	04951963          	bne	a0,s1,f1c <bigwrite+0xc8>
    close(fd);
     ece:	854a                	mv	a0,s2
     ed0:	00003097          	auipc	ra,0x3
     ed4:	4fa080e7          	jalr	1274(ra) # 43ca <close>
    unlink("bigwrite");
     ed8:	8556                	mv	a0,s5
     eda:	00003097          	auipc	ra,0x3
     ede:	518080e7          	jalr	1304(ra) # 43f2 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     ee2:	1d74849b          	addiw	s1,s1,471
     ee6:	fb6498e3          	bne	s1,s6,e96 <bigwrite+0x42>
}
     eea:	60a6                	ld	ra,72(sp)
     eec:	6406                	ld	s0,64(sp)
     eee:	74e2                	ld	s1,56(sp)
     ef0:	7942                	ld	s2,48(sp)
     ef2:	79a2                	ld	s3,40(sp)
     ef4:	7a02                	ld	s4,32(sp)
     ef6:	6ae2                	ld	s5,24(sp)
     ef8:	6b42                	ld	s6,16(sp)
     efa:	6ba2                	ld	s7,8(sp)
     efc:	6161                	addi	sp,sp,80
     efe:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     f00:	85de                	mv	a1,s7
     f02:	00004517          	auipc	a0,0x4
     f06:	27650513          	addi	a0,a0,630 # 5178 <malloc+0x980>
     f0a:	00004097          	auipc	ra,0x4
     f0e:	830080e7          	jalr	-2000(ra) # 473a <printf>
      exit(1);
     f12:	4505                	li	a0,1
     f14:	00003097          	auipc	ra,0x3
     f18:	48e080e7          	jalr	1166(ra) # 43a2 <exit>
     f1c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     f1e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     f20:	86ce                	mv	a3,s3
     f22:	8626                	mv	a2,s1
     f24:	85de                	mv	a1,s7
     f26:	00004517          	auipc	a0,0x4
     f2a:	27250513          	addi	a0,a0,626 # 5198 <malloc+0x9a0>
     f2e:	00004097          	auipc	ra,0x4
     f32:	80c080e7          	jalr	-2036(ra) # 473a <printf>
        exit(1);
     f36:	4505                	li	a0,1
     f38:	00003097          	auipc	ra,0x3
     f3c:	46a080e7          	jalr	1130(ra) # 43a2 <exit>

0000000000000f40 <writetest>:
{
     f40:	7139                	addi	sp,sp,-64
     f42:	fc06                	sd	ra,56(sp)
     f44:	f822                	sd	s0,48(sp)
     f46:	f426                	sd	s1,40(sp)
     f48:	f04a                	sd	s2,32(sp)
     f4a:	ec4e                	sd	s3,24(sp)
     f4c:	e852                	sd	s4,16(sp)
     f4e:	e456                	sd	s5,8(sp)
     f50:	e05a                	sd	s6,0(sp)
     f52:	0080                	addi	s0,sp,64
     f54:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     f56:	20200593          	li	a1,514
     f5a:	00004517          	auipc	a0,0x4
     f5e:	25650513          	addi	a0,a0,598 # 51b0 <malloc+0x9b8>
     f62:	00003097          	auipc	ra,0x3
     f66:	480080e7          	jalr	1152(ra) # 43e2 <open>
  if(fd < 0){
     f6a:	0a054d63          	bltz	a0,1024 <writetest+0xe4>
     f6e:	892a                	mv	s2,a0
     f70:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     f72:	00004997          	auipc	s3,0x4
     f76:	26698993          	addi	s3,s3,614 # 51d8 <malloc+0x9e0>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     f7a:	00004a97          	auipc	s5,0x4
     f7e:	296a8a93          	addi	s5,s5,662 # 5210 <malloc+0xa18>
  for(i = 0; i < N; i++){
     f82:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     f86:	4629                	li	a2,10
     f88:	85ce                	mv	a1,s3
     f8a:	854a                	mv	a0,s2
     f8c:	00003097          	auipc	ra,0x3
     f90:	436080e7          	jalr	1078(ra) # 43c2 <write>
     f94:	47a9                	li	a5,10
     f96:	0af51563          	bne	a0,a5,1040 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     f9a:	4629                	li	a2,10
     f9c:	85d6                	mv	a1,s5
     f9e:	854a                	mv	a0,s2
     fa0:	00003097          	auipc	ra,0x3
     fa4:	422080e7          	jalr	1058(ra) # 43c2 <write>
     fa8:	47a9                	li	a5,10
     faa:	0af51963          	bne	a0,a5,105c <writetest+0x11c>
  for(i = 0; i < N; i++){
     fae:	2485                	addiw	s1,s1,1
     fb0:	fd449be3          	bne	s1,s4,f86 <writetest+0x46>
  close(fd);
     fb4:	854a                	mv	a0,s2
     fb6:	00003097          	auipc	ra,0x3
     fba:	414080e7          	jalr	1044(ra) # 43ca <close>
  fd = open("small", O_RDONLY);
     fbe:	4581                	li	a1,0
     fc0:	00004517          	auipc	a0,0x4
     fc4:	1f050513          	addi	a0,a0,496 # 51b0 <malloc+0x9b8>
     fc8:	00003097          	auipc	ra,0x3
     fcc:	41a080e7          	jalr	1050(ra) # 43e2 <open>
     fd0:	84aa                	mv	s1,a0
  if(fd < 0){
     fd2:	0a054363          	bltz	a0,1078 <writetest+0x138>
  i = read(fd, buf, N*SZ*2);
     fd6:	7d000613          	li	a2,2000
     fda:	00008597          	auipc	a1,0x8
     fde:	1a658593          	addi	a1,a1,422 # 9180 <buf>
     fe2:	00003097          	auipc	ra,0x3
     fe6:	3d8080e7          	jalr	984(ra) # 43ba <read>
  if(i != N*SZ*2){
     fea:	7d000793          	li	a5,2000
     fee:	0af51363          	bne	a0,a5,1094 <writetest+0x154>
  close(fd);
     ff2:	8526                	mv	a0,s1
     ff4:	00003097          	auipc	ra,0x3
     ff8:	3d6080e7          	jalr	982(ra) # 43ca <close>
  if(unlink("small") < 0){
     ffc:	00004517          	auipc	a0,0x4
    1000:	1b450513          	addi	a0,a0,436 # 51b0 <malloc+0x9b8>
    1004:	00003097          	auipc	ra,0x3
    1008:	3ee080e7          	jalr	1006(ra) # 43f2 <unlink>
    100c:	0a054263          	bltz	a0,10b0 <writetest+0x170>
}
    1010:	70e2                	ld	ra,56(sp)
    1012:	7442                	ld	s0,48(sp)
    1014:	74a2                	ld	s1,40(sp)
    1016:	7902                	ld	s2,32(sp)
    1018:	69e2                	ld	s3,24(sp)
    101a:	6a42                	ld	s4,16(sp)
    101c:	6aa2                	ld	s5,8(sp)
    101e:	6b02                	ld	s6,0(sp)
    1020:	6121                	addi	sp,sp,64
    1022:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
    1024:	85da                	mv	a1,s6
    1026:	00004517          	auipc	a0,0x4
    102a:	19250513          	addi	a0,a0,402 # 51b8 <malloc+0x9c0>
    102e:	00003097          	auipc	ra,0x3
    1032:	70c080e7          	jalr	1804(ra) # 473a <printf>
    exit(1);
    1036:	4505                	li	a0,1
    1038:	00003097          	auipc	ra,0x3
    103c:	36a080e7          	jalr	874(ra) # 43a2 <exit>
      printf("%s: error: write aa %d new file failed\n", i);
    1040:	85a6                	mv	a1,s1
    1042:	00004517          	auipc	a0,0x4
    1046:	1a650513          	addi	a0,a0,422 # 51e8 <malloc+0x9f0>
    104a:	00003097          	auipc	ra,0x3
    104e:	6f0080e7          	jalr	1776(ra) # 473a <printf>
      exit(1);
    1052:	4505                	li	a0,1
    1054:	00003097          	auipc	ra,0x3
    1058:	34e080e7          	jalr	846(ra) # 43a2 <exit>
      printf("%s: error: write bb %d new file failed\n", i);
    105c:	85a6                	mv	a1,s1
    105e:	00004517          	auipc	a0,0x4
    1062:	1c250513          	addi	a0,a0,450 # 5220 <malloc+0xa28>
    1066:	00003097          	auipc	ra,0x3
    106a:	6d4080e7          	jalr	1748(ra) # 473a <printf>
      exit(1);
    106e:	4505                	li	a0,1
    1070:	00003097          	auipc	ra,0x3
    1074:	332080e7          	jalr	818(ra) # 43a2 <exit>
    printf("%s: error: open small failed!\n", s);
    1078:	85da                	mv	a1,s6
    107a:	00004517          	auipc	a0,0x4
    107e:	1ce50513          	addi	a0,a0,462 # 5248 <malloc+0xa50>
    1082:	00003097          	auipc	ra,0x3
    1086:	6b8080e7          	jalr	1720(ra) # 473a <printf>
    exit(1);
    108a:	4505                	li	a0,1
    108c:	00003097          	auipc	ra,0x3
    1090:	316080e7          	jalr	790(ra) # 43a2 <exit>
    printf("%s: read failed\n", s);
    1094:	85da                	mv	a1,s6
    1096:	00004517          	auipc	a0,0x4
    109a:	1d250513          	addi	a0,a0,466 # 5268 <malloc+0xa70>
    109e:	00003097          	auipc	ra,0x3
    10a2:	69c080e7          	jalr	1692(ra) # 473a <printf>
    exit(1);
    10a6:	4505                	li	a0,1
    10a8:	00003097          	auipc	ra,0x3
    10ac:	2fa080e7          	jalr	762(ra) # 43a2 <exit>
    printf("%s: unlink small failed\n", s);
    10b0:	85da                	mv	a1,s6
    10b2:	00004517          	auipc	a0,0x4
    10b6:	1ce50513          	addi	a0,a0,462 # 5280 <malloc+0xa88>
    10ba:	00003097          	auipc	ra,0x3
    10be:	680080e7          	jalr	1664(ra) # 473a <printf>
    exit(1);
    10c2:	4505                	li	a0,1
    10c4:	00003097          	auipc	ra,0x3
    10c8:	2de080e7          	jalr	734(ra) # 43a2 <exit>

00000000000010cc <writebig>:
{
    10cc:	7139                	addi	sp,sp,-64
    10ce:	fc06                	sd	ra,56(sp)
    10d0:	f822                	sd	s0,48(sp)
    10d2:	f426                	sd	s1,40(sp)
    10d4:	f04a                	sd	s2,32(sp)
    10d6:	ec4e                	sd	s3,24(sp)
    10d8:	e852                	sd	s4,16(sp)
    10da:	e456                	sd	s5,8(sp)
    10dc:	0080                	addi	s0,sp,64
    10de:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
    10e0:	20200593          	li	a1,514
    10e4:	00004517          	auipc	a0,0x4
    10e8:	1bc50513          	addi	a0,a0,444 # 52a0 <malloc+0xaa8>
    10ec:	00003097          	auipc	ra,0x3
    10f0:	2f6080e7          	jalr	758(ra) # 43e2 <open>
    10f4:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
    10f6:	4481                	li	s1,0
    ((int*)buf)[0] = i;
    10f8:	00008917          	auipc	s2,0x8
    10fc:	08890913          	addi	s2,s2,136 # 9180 <buf>
  for(i = 0; i < MAXFILE; i++){
    1100:	10c00a13          	li	s4,268
  if(fd < 0){
    1104:	06054c63          	bltz	a0,117c <writebig+0xb0>
    ((int*)buf)[0] = i;
    1108:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
    110c:	40000613          	li	a2,1024
    1110:	85ca                	mv	a1,s2
    1112:	854e                	mv	a0,s3
    1114:	00003097          	auipc	ra,0x3
    1118:	2ae080e7          	jalr	686(ra) # 43c2 <write>
    111c:	40000793          	li	a5,1024
    1120:	06f51c63          	bne	a0,a5,1198 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
    1124:	2485                	addiw	s1,s1,1
    1126:	ff4491e3          	bne	s1,s4,1108 <writebig+0x3c>
  close(fd);
    112a:	854e                	mv	a0,s3
    112c:	00003097          	auipc	ra,0x3
    1130:	29e080e7          	jalr	670(ra) # 43ca <close>
  fd = open("big", O_RDONLY);
    1134:	4581                	li	a1,0
    1136:	00004517          	auipc	a0,0x4
    113a:	16a50513          	addi	a0,a0,362 # 52a0 <malloc+0xaa8>
    113e:	00003097          	auipc	ra,0x3
    1142:	2a4080e7          	jalr	676(ra) # 43e2 <open>
    1146:	89aa                	mv	s3,a0
  n = 0;
    1148:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
    114a:	00008917          	auipc	s2,0x8
    114e:	03690913          	addi	s2,s2,54 # 9180 <buf>
  if(fd < 0){
    1152:	06054163          	bltz	a0,11b4 <writebig+0xe8>
    i = read(fd, buf, BSIZE);
    1156:	40000613          	li	a2,1024
    115a:	85ca                	mv	a1,s2
    115c:	854e                	mv	a0,s3
    115e:	00003097          	auipc	ra,0x3
    1162:	25c080e7          	jalr	604(ra) # 43ba <read>
    if(i == 0){
    1166:	c52d                	beqz	a0,11d0 <writebig+0x104>
    } else if(i != BSIZE){
    1168:	40000793          	li	a5,1024
    116c:	0af51d63          	bne	a0,a5,1226 <writebig+0x15a>
    if(((int*)buf)[0] != n){
    1170:	00092603          	lw	a2,0(s2)
    1174:	0c961763          	bne	a2,s1,1242 <writebig+0x176>
    n++;
    1178:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
    117a:	bff1                	j	1156 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
    117c:	85d6                	mv	a1,s5
    117e:	00004517          	auipc	a0,0x4
    1182:	12a50513          	addi	a0,a0,298 # 52a8 <malloc+0xab0>
    1186:	00003097          	auipc	ra,0x3
    118a:	5b4080e7          	jalr	1460(ra) # 473a <printf>
    exit(1);
    118e:	4505                	li	a0,1
    1190:	00003097          	auipc	ra,0x3
    1194:	212080e7          	jalr	530(ra) # 43a2 <exit>
      printf("%s: error: write big file failed\n", i);
    1198:	85a6                	mv	a1,s1
    119a:	00004517          	auipc	a0,0x4
    119e:	12e50513          	addi	a0,a0,302 # 52c8 <malloc+0xad0>
    11a2:	00003097          	auipc	ra,0x3
    11a6:	598080e7          	jalr	1432(ra) # 473a <printf>
      exit(1);
    11aa:	4505                	li	a0,1
    11ac:	00003097          	auipc	ra,0x3
    11b0:	1f6080e7          	jalr	502(ra) # 43a2 <exit>
    printf("%s: error: open big failed!\n", s);
    11b4:	85d6                	mv	a1,s5
    11b6:	00004517          	auipc	a0,0x4
    11ba:	13a50513          	addi	a0,a0,314 # 52f0 <malloc+0xaf8>
    11be:	00003097          	auipc	ra,0x3
    11c2:	57c080e7          	jalr	1404(ra) # 473a <printf>
    exit(1);
    11c6:	4505                	li	a0,1
    11c8:	00003097          	auipc	ra,0x3
    11cc:	1da080e7          	jalr	474(ra) # 43a2 <exit>
      if(n == MAXFILE - 1){
    11d0:	10b00793          	li	a5,267
    11d4:	02f48a63          	beq	s1,a5,1208 <writebig+0x13c>
  close(fd);
    11d8:	854e                	mv	a0,s3
    11da:	00003097          	auipc	ra,0x3
    11de:	1f0080e7          	jalr	496(ra) # 43ca <close>
  if(unlink("big") < 0){
    11e2:	00004517          	auipc	a0,0x4
    11e6:	0be50513          	addi	a0,a0,190 # 52a0 <malloc+0xaa8>
    11ea:	00003097          	auipc	ra,0x3
    11ee:	208080e7          	jalr	520(ra) # 43f2 <unlink>
    11f2:	06054663          	bltz	a0,125e <writebig+0x192>
}
    11f6:	70e2                	ld	ra,56(sp)
    11f8:	7442                	ld	s0,48(sp)
    11fa:	74a2                	ld	s1,40(sp)
    11fc:	7902                	ld	s2,32(sp)
    11fe:	69e2                	ld	s3,24(sp)
    1200:	6a42                	ld	s4,16(sp)
    1202:	6aa2                	ld	s5,8(sp)
    1204:	6121                	addi	sp,sp,64
    1206:	8082                	ret
        printf("%s: read only %d blocks from big", n);
    1208:	10b00593          	li	a1,267
    120c:	00004517          	auipc	a0,0x4
    1210:	10450513          	addi	a0,a0,260 # 5310 <malloc+0xb18>
    1214:	00003097          	auipc	ra,0x3
    1218:	526080e7          	jalr	1318(ra) # 473a <printf>
        exit(1);
    121c:	4505                	li	a0,1
    121e:	00003097          	auipc	ra,0x3
    1222:	184080e7          	jalr	388(ra) # 43a2 <exit>
      printf("%s: read failed %d\n", i);
    1226:	85aa                	mv	a1,a0
    1228:	00004517          	auipc	a0,0x4
    122c:	11050513          	addi	a0,a0,272 # 5338 <malloc+0xb40>
    1230:	00003097          	auipc	ra,0x3
    1234:	50a080e7          	jalr	1290(ra) # 473a <printf>
      exit(1);
    1238:	4505                	li	a0,1
    123a:	00003097          	auipc	ra,0x3
    123e:	168080e7          	jalr	360(ra) # 43a2 <exit>
      printf("%s: read content of block %d is %d\n",
    1242:	85a6                	mv	a1,s1
    1244:	00004517          	auipc	a0,0x4
    1248:	10c50513          	addi	a0,a0,268 # 5350 <malloc+0xb58>
    124c:	00003097          	auipc	ra,0x3
    1250:	4ee080e7          	jalr	1262(ra) # 473a <printf>
      exit(1);
    1254:	4505                	li	a0,1
    1256:	00003097          	auipc	ra,0x3
    125a:	14c080e7          	jalr	332(ra) # 43a2 <exit>
    printf("%s: unlink big failed\n", s);
    125e:	85d6                	mv	a1,s5
    1260:	00004517          	auipc	a0,0x4
    1264:	11850513          	addi	a0,a0,280 # 5378 <malloc+0xb80>
    1268:	00003097          	auipc	ra,0x3
    126c:	4d2080e7          	jalr	1234(ra) # 473a <printf>
    exit(1);
    1270:	4505                	li	a0,1
    1272:	00003097          	auipc	ra,0x3
    1276:	130080e7          	jalr	304(ra) # 43a2 <exit>

000000000000127a <unlinkread>:
{
    127a:	7179                	addi	sp,sp,-48
    127c:	f406                	sd	ra,40(sp)
    127e:	f022                	sd	s0,32(sp)
    1280:	ec26                	sd	s1,24(sp)
    1282:	e84a                	sd	s2,16(sp)
    1284:	e44e                	sd	s3,8(sp)
    1286:	1800                	addi	s0,sp,48
    1288:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
    128a:	20200593          	li	a1,514
    128e:	00003517          	auipc	a0,0x3
    1292:	72250513          	addi	a0,a0,1826 # 49b0 <malloc+0x1b8>
    1296:	00003097          	auipc	ra,0x3
    129a:	14c080e7          	jalr	332(ra) # 43e2 <open>
  if(fd < 0){
    129e:	0e054563          	bltz	a0,1388 <unlinkread+0x10e>
    12a2:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
    12a4:	4615                	li	a2,5
    12a6:	00004597          	auipc	a1,0x4
    12aa:	10a58593          	addi	a1,a1,266 # 53b0 <malloc+0xbb8>
    12ae:	00003097          	auipc	ra,0x3
    12b2:	114080e7          	jalr	276(ra) # 43c2 <write>
  close(fd);
    12b6:	8526                	mv	a0,s1
    12b8:	00003097          	auipc	ra,0x3
    12bc:	112080e7          	jalr	274(ra) # 43ca <close>
  fd = open("unlinkread", O_RDWR);
    12c0:	4589                	li	a1,2
    12c2:	00003517          	auipc	a0,0x3
    12c6:	6ee50513          	addi	a0,a0,1774 # 49b0 <malloc+0x1b8>
    12ca:	00003097          	auipc	ra,0x3
    12ce:	118080e7          	jalr	280(ra) # 43e2 <open>
    12d2:	84aa                	mv	s1,a0
  if(fd < 0){
    12d4:	0c054863          	bltz	a0,13a4 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
    12d8:	00003517          	auipc	a0,0x3
    12dc:	6d850513          	addi	a0,a0,1752 # 49b0 <malloc+0x1b8>
    12e0:	00003097          	auipc	ra,0x3
    12e4:	112080e7          	jalr	274(ra) # 43f2 <unlink>
    12e8:	ed61                	bnez	a0,13c0 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    12ea:	20200593          	li	a1,514
    12ee:	00003517          	auipc	a0,0x3
    12f2:	6c250513          	addi	a0,a0,1730 # 49b0 <malloc+0x1b8>
    12f6:	00003097          	auipc	ra,0x3
    12fa:	0ec080e7          	jalr	236(ra) # 43e2 <open>
    12fe:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
    1300:	460d                	li	a2,3
    1302:	00004597          	auipc	a1,0x4
    1306:	0f658593          	addi	a1,a1,246 # 53f8 <malloc+0xc00>
    130a:	00003097          	auipc	ra,0x3
    130e:	0b8080e7          	jalr	184(ra) # 43c2 <write>
  close(fd1);
    1312:	854a                	mv	a0,s2
    1314:	00003097          	auipc	ra,0x3
    1318:	0b6080e7          	jalr	182(ra) # 43ca <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
    131c:	660d                	lui	a2,0x3
    131e:	00008597          	auipc	a1,0x8
    1322:	e6258593          	addi	a1,a1,-414 # 9180 <buf>
    1326:	8526                	mv	a0,s1
    1328:	00003097          	auipc	ra,0x3
    132c:	092080e7          	jalr	146(ra) # 43ba <read>
    1330:	4795                	li	a5,5
    1332:	0af51563          	bne	a0,a5,13dc <unlinkread+0x162>
  if(buf[0] != 'h'){
    1336:	00008717          	auipc	a4,0x8
    133a:	e4a74703          	lbu	a4,-438(a4) # 9180 <buf>
    133e:	06800793          	li	a5,104
    1342:	0af71b63          	bne	a4,a5,13f8 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
    1346:	4629                	li	a2,10
    1348:	00008597          	auipc	a1,0x8
    134c:	e3858593          	addi	a1,a1,-456 # 9180 <buf>
    1350:	8526                	mv	a0,s1
    1352:	00003097          	auipc	ra,0x3
    1356:	070080e7          	jalr	112(ra) # 43c2 <write>
    135a:	47a9                	li	a5,10
    135c:	0af51c63          	bne	a0,a5,1414 <unlinkread+0x19a>
  close(fd);
    1360:	8526                	mv	a0,s1
    1362:	00003097          	auipc	ra,0x3
    1366:	068080e7          	jalr	104(ra) # 43ca <close>
  unlink("unlinkread");
    136a:	00003517          	auipc	a0,0x3
    136e:	64650513          	addi	a0,a0,1606 # 49b0 <malloc+0x1b8>
    1372:	00003097          	auipc	ra,0x3
    1376:	080080e7          	jalr	128(ra) # 43f2 <unlink>
}
    137a:	70a2                	ld	ra,40(sp)
    137c:	7402                	ld	s0,32(sp)
    137e:	64e2                	ld	s1,24(sp)
    1380:	6942                	ld	s2,16(sp)
    1382:	69a2                	ld	s3,8(sp)
    1384:	6145                	addi	sp,sp,48
    1386:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
    1388:	85ce                	mv	a1,s3
    138a:	00004517          	auipc	a0,0x4
    138e:	00650513          	addi	a0,a0,6 # 5390 <malloc+0xb98>
    1392:	00003097          	auipc	ra,0x3
    1396:	3a8080e7          	jalr	936(ra) # 473a <printf>
    exit(1);
    139a:	4505                	li	a0,1
    139c:	00003097          	auipc	ra,0x3
    13a0:	006080e7          	jalr	6(ra) # 43a2 <exit>
    printf("%s: open unlinkread failed\n", s);
    13a4:	85ce                	mv	a1,s3
    13a6:	00004517          	auipc	a0,0x4
    13aa:	01250513          	addi	a0,a0,18 # 53b8 <malloc+0xbc0>
    13ae:	00003097          	auipc	ra,0x3
    13b2:	38c080e7          	jalr	908(ra) # 473a <printf>
    exit(1);
    13b6:	4505                	li	a0,1
    13b8:	00003097          	auipc	ra,0x3
    13bc:	fea080e7          	jalr	-22(ra) # 43a2 <exit>
    printf("%s: unlink unlinkread failed\n", s);
    13c0:	85ce                	mv	a1,s3
    13c2:	00004517          	auipc	a0,0x4
    13c6:	01650513          	addi	a0,a0,22 # 53d8 <malloc+0xbe0>
    13ca:	00003097          	auipc	ra,0x3
    13ce:	370080e7          	jalr	880(ra) # 473a <printf>
    exit(1);
    13d2:	4505                	li	a0,1
    13d4:	00003097          	auipc	ra,0x3
    13d8:	fce080e7          	jalr	-50(ra) # 43a2 <exit>
    printf("%s: unlinkread read failed", s);
    13dc:	85ce                	mv	a1,s3
    13de:	00004517          	auipc	a0,0x4
    13e2:	02250513          	addi	a0,a0,34 # 5400 <malloc+0xc08>
    13e6:	00003097          	auipc	ra,0x3
    13ea:	354080e7          	jalr	852(ra) # 473a <printf>
    exit(1);
    13ee:	4505                	li	a0,1
    13f0:	00003097          	auipc	ra,0x3
    13f4:	fb2080e7          	jalr	-78(ra) # 43a2 <exit>
    printf("%s: unlinkread wrong data\n", s);
    13f8:	85ce                	mv	a1,s3
    13fa:	00004517          	auipc	a0,0x4
    13fe:	02650513          	addi	a0,a0,38 # 5420 <malloc+0xc28>
    1402:	00003097          	auipc	ra,0x3
    1406:	338080e7          	jalr	824(ra) # 473a <printf>
    exit(1);
    140a:	4505                	li	a0,1
    140c:	00003097          	auipc	ra,0x3
    1410:	f96080e7          	jalr	-106(ra) # 43a2 <exit>
    printf("%s: unlinkread write failed\n", s);
    1414:	85ce                	mv	a1,s3
    1416:	00004517          	auipc	a0,0x4
    141a:	02a50513          	addi	a0,a0,42 # 5440 <malloc+0xc48>
    141e:	00003097          	auipc	ra,0x3
    1422:	31c080e7          	jalr	796(ra) # 473a <printf>
    exit(1);
    1426:	4505                	li	a0,1
    1428:	00003097          	auipc	ra,0x3
    142c:	f7a080e7          	jalr	-134(ra) # 43a2 <exit>

0000000000001430 <exectest>:
{
    1430:	715d                	addi	sp,sp,-80
    1432:	e486                	sd	ra,72(sp)
    1434:	e0a2                	sd	s0,64(sp)
    1436:	fc26                	sd	s1,56(sp)
    1438:	f84a                	sd	s2,48(sp)
    143a:	0880                	addi	s0,sp,80
    143c:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    143e:	00004797          	auipc	a5,0x4
    1442:	a5278793          	addi	a5,a5,-1454 # 4e90 <malloc+0x698>
    1446:	fcf43023          	sd	a5,-64(s0)
    144a:	00004797          	auipc	a5,0x4
    144e:	01678793          	addi	a5,a5,22 # 5460 <malloc+0xc68>
    1452:	fcf43423          	sd	a5,-56(s0)
    1456:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    145a:	00004517          	auipc	a0,0x4
    145e:	00e50513          	addi	a0,a0,14 # 5468 <malloc+0xc70>
    1462:	00003097          	auipc	ra,0x3
    1466:	f90080e7          	jalr	-112(ra) # 43f2 <unlink>
  pid = fork();
    146a:	00003097          	auipc	ra,0x3
    146e:	f30080e7          	jalr	-208(ra) # 439a <fork>
  if(pid < 0) {
    1472:	04054663          	bltz	a0,14be <exectest+0x8e>
    1476:	84aa                	mv	s1,a0
  if(pid == 0) {
    1478:	e959                	bnez	a0,150e <exectest+0xde>
    close(1);
    147a:	4505                	li	a0,1
    147c:	00003097          	auipc	ra,0x3
    1480:	f4e080e7          	jalr	-178(ra) # 43ca <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1484:	20100593          	li	a1,513
    1488:	00004517          	auipc	a0,0x4
    148c:	fe050513          	addi	a0,a0,-32 # 5468 <malloc+0xc70>
    1490:	00003097          	auipc	ra,0x3
    1494:	f52080e7          	jalr	-174(ra) # 43e2 <open>
    if(fd < 0) {
    1498:	04054163          	bltz	a0,14da <exectest+0xaa>
    if(fd != 1) {
    149c:	4785                	li	a5,1
    149e:	04f50c63          	beq	a0,a5,14f6 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    14a2:	85ca                	mv	a1,s2
    14a4:	00004517          	auipc	a0,0x4
    14a8:	fcc50513          	addi	a0,a0,-52 # 5470 <malloc+0xc78>
    14ac:	00003097          	auipc	ra,0x3
    14b0:	28e080e7          	jalr	654(ra) # 473a <printf>
      exit(1);
    14b4:	4505                	li	a0,1
    14b6:	00003097          	auipc	ra,0x3
    14ba:	eec080e7          	jalr	-276(ra) # 43a2 <exit>
     printf("%s: fork failed\n", s);
    14be:	85ca                	mv	a1,s2
    14c0:	00004517          	auipc	a0,0x4
    14c4:	82050513          	addi	a0,a0,-2016 # 4ce0 <malloc+0x4e8>
    14c8:	00003097          	auipc	ra,0x3
    14cc:	272080e7          	jalr	626(ra) # 473a <printf>
     exit(1);
    14d0:	4505                	li	a0,1
    14d2:	00003097          	auipc	ra,0x3
    14d6:	ed0080e7          	jalr	-304(ra) # 43a2 <exit>
      printf("%s: create failed\n", s);
    14da:	85ca                	mv	a1,s2
    14dc:	00004517          	auipc	a0,0x4
    14e0:	a1c50513          	addi	a0,a0,-1508 # 4ef8 <malloc+0x700>
    14e4:	00003097          	auipc	ra,0x3
    14e8:	256080e7          	jalr	598(ra) # 473a <printf>
      exit(1);
    14ec:	4505                	li	a0,1
    14ee:	00003097          	auipc	ra,0x3
    14f2:	eb4080e7          	jalr	-332(ra) # 43a2 <exit>
    if(exec("echo", echoargv) < 0){
    14f6:	fc040593          	addi	a1,s0,-64
    14fa:	00004517          	auipc	a0,0x4
    14fe:	99650513          	addi	a0,a0,-1642 # 4e90 <malloc+0x698>
    1502:	00003097          	auipc	ra,0x3
    1506:	ed8080e7          	jalr	-296(ra) # 43da <exec>
    150a:	02054163          	bltz	a0,152c <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    150e:	fdc40513          	addi	a0,s0,-36
    1512:	00003097          	auipc	ra,0x3
    1516:	e98080e7          	jalr	-360(ra) # 43aa <wait>
    151a:	02951763          	bne	a0,s1,1548 <exectest+0x118>
  if(xstatus != 0)
    151e:	fdc42503          	lw	a0,-36(s0)
    1522:	cd0d                	beqz	a0,155c <exectest+0x12c>
    exit(xstatus);
    1524:	00003097          	auipc	ra,0x3
    1528:	e7e080e7          	jalr	-386(ra) # 43a2 <exit>
      printf("%s: exec echo failed\n", s);
    152c:	85ca                	mv	a1,s2
    152e:	00004517          	auipc	a0,0x4
    1532:	f5250513          	addi	a0,a0,-174 # 5480 <malloc+0xc88>
    1536:	00003097          	auipc	ra,0x3
    153a:	204080e7          	jalr	516(ra) # 473a <printf>
      exit(1);
    153e:	4505                	li	a0,1
    1540:	00003097          	auipc	ra,0x3
    1544:	e62080e7          	jalr	-414(ra) # 43a2 <exit>
    printf("%s: wait failed!\n", s);
    1548:	85ca                	mv	a1,s2
    154a:	00004517          	auipc	a0,0x4
    154e:	f4e50513          	addi	a0,a0,-178 # 5498 <malloc+0xca0>
    1552:	00003097          	auipc	ra,0x3
    1556:	1e8080e7          	jalr	488(ra) # 473a <printf>
    155a:	b7d1                	j	151e <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    155c:	4581                	li	a1,0
    155e:	00004517          	auipc	a0,0x4
    1562:	f0a50513          	addi	a0,a0,-246 # 5468 <malloc+0xc70>
    1566:	00003097          	auipc	ra,0x3
    156a:	e7c080e7          	jalr	-388(ra) # 43e2 <open>
  if(fd < 0) {
    156e:	02054a63          	bltz	a0,15a2 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    1572:	4609                	li	a2,2
    1574:	fb840593          	addi	a1,s0,-72
    1578:	00003097          	auipc	ra,0x3
    157c:	e42080e7          	jalr	-446(ra) # 43ba <read>
    1580:	4789                	li	a5,2
    1582:	02f50e63          	beq	a0,a5,15be <exectest+0x18e>
    printf("%s: read failed\n", s);
    1586:	85ca                	mv	a1,s2
    1588:	00004517          	auipc	a0,0x4
    158c:	ce050513          	addi	a0,a0,-800 # 5268 <malloc+0xa70>
    1590:	00003097          	auipc	ra,0x3
    1594:	1aa080e7          	jalr	426(ra) # 473a <printf>
    exit(1);
    1598:	4505                	li	a0,1
    159a:	00003097          	auipc	ra,0x3
    159e:	e08080e7          	jalr	-504(ra) # 43a2 <exit>
    printf("%s: open failed\n", s);
    15a2:	85ca                	mv	a1,s2
    15a4:	00004517          	auipc	a0,0x4
    15a8:	f0c50513          	addi	a0,a0,-244 # 54b0 <malloc+0xcb8>
    15ac:	00003097          	auipc	ra,0x3
    15b0:	18e080e7          	jalr	398(ra) # 473a <printf>
    exit(1);
    15b4:	4505                	li	a0,1
    15b6:	00003097          	auipc	ra,0x3
    15ba:	dec080e7          	jalr	-532(ra) # 43a2 <exit>
  unlink("echo-ok");
    15be:	00004517          	auipc	a0,0x4
    15c2:	eaa50513          	addi	a0,a0,-342 # 5468 <malloc+0xc70>
    15c6:	00003097          	auipc	ra,0x3
    15ca:	e2c080e7          	jalr	-468(ra) # 43f2 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    15ce:	fb844703          	lbu	a4,-72(s0)
    15d2:	04f00793          	li	a5,79
    15d6:	00f71863          	bne	a4,a5,15e6 <exectest+0x1b6>
    15da:	fb944703          	lbu	a4,-71(s0)
    15de:	04b00793          	li	a5,75
    15e2:	02f70063          	beq	a4,a5,1602 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    15e6:	85ca                	mv	a1,s2
    15e8:	00004517          	auipc	a0,0x4
    15ec:	ee050513          	addi	a0,a0,-288 # 54c8 <malloc+0xcd0>
    15f0:	00003097          	auipc	ra,0x3
    15f4:	14a080e7          	jalr	330(ra) # 473a <printf>
    exit(1);
    15f8:	4505                	li	a0,1
    15fa:	00003097          	auipc	ra,0x3
    15fe:	da8080e7          	jalr	-600(ra) # 43a2 <exit>
    exit(0);
    1602:	4501                	li	a0,0
    1604:	00003097          	auipc	ra,0x3
    1608:	d9e080e7          	jalr	-610(ra) # 43a2 <exit>

000000000000160c <bigargtest>:
{
    160c:	7179                	addi	sp,sp,-48
    160e:	f406                	sd	ra,40(sp)
    1610:	f022                	sd	s0,32(sp)
    1612:	ec26                	sd	s1,24(sp)
    1614:	1800                	addi	s0,sp,48
    1616:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    1618:	00004517          	auipc	a0,0x4
    161c:	ec850513          	addi	a0,a0,-312 # 54e0 <malloc+0xce8>
    1620:	00003097          	auipc	ra,0x3
    1624:	dd2080e7          	jalr	-558(ra) # 43f2 <unlink>
  pid = fork();
    1628:	00003097          	auipc	ra,0x3
    162c:	d72080e7          	jalr	-654(ra) # 439a <fork>
  if(pid == 0){
    1630:	c121                	beqz	a0,1670 <bigargtest+0x64>
  } else if(pid < 0){
    1632:	0a054063          	bltz	a0,16d2 <bigargtest+0xc6>
  wait(&xstatus);
    1636:	fdc40513          	addi	a0,s0,-36
    163a:	00003097          	auipc	ra,0x3
    163e:	d70080e7          	jalr	-656(ra) # 43aa <wait>
  if(xstatus != 0)
    1642:	fdc42503          	lw	a0,-36(s0)
    1646:	e545                	bnez	a0,16ee <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    1648:	4581                	li	a1,0
    164a:	00004517          	auipc	a0,0x4
    164e:	e9650513          	addi	a0,a0,-362 # 54e0 <malloc+0xce8>
    1652:	00003097          	auipc	ra,0x3
    1656:	d90080e7          	jalr	-624(ra) # 43e2 <open>
  if(fd < 0){
    165a:	08054e63          	bltz	a0,16f6 <bigargtest+0xea>
  close(fd);
    165e:	00003097          	auipc	ra,0x3
    1662:	d6c080e7          	jalr	-660(ra) # 43ca <close>
}
    1666:	70a2                	ld	ra,40(sp)
    1668:	7402                	ld	s0,32(sp)
    166a:	64e2                	ld	s1,24(sp)
    166c:	6145                	addi	sp,sp,48
    166e:	8082                	ret
    1670:	00005797          	auipc	a5,0x5
    1674:	30078793          	addi	a5,a5,768 # 6970 <args.0>
    1678:	00005697          	auipc	a3,0x5
    167c:	3f068693          	addi	a3,a3,1008 # 6a68 <args.0+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    1680:	00004717          	auipc	a4,0x4
    1684:	e7070713          	addi	a4,a4,-400 # 54f0 <malloc+0xcf8>
    1688:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    168a:	07a1                	addi	a5,a5,8
    168c:	fed79ee3          	bne	a5,a3,1688 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    1690:	00005597          	auipc	a1,0x5
    1694:	2e058593          	addi	a1,a1,736 # 6970 <args.0>
    1698:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    169c:	00003517          	auipc	a0,0x3
    16a0:	7f450513          	addi	a0,a0,2036 # 4e90 <malloc+0x698>
    16a4:	00003097          	auipc	ra,0x3
    16a8:	d36080e7          	jalr	-714(ra) # 43da <exec>
    fd = open("bigarg-ok", O_CREATE);
    16ac:	20000593          	li	a1,512
    16b0:	00004517          	auipc	a0,0x4
    16b4:	e3050513          	addi	a0,a0,-464 # 54e0 <malloc+0xce8>
    16b8:	00003097          	auipc	ra,0x3
    16bc:	d2a080e7          	jalr	-726(ra) # 43e2 <open>
    close(fd);
    16c0:	00003097          	auipc	ra,0x3
    16c4:	d0a080e7          	jalr	-758(ra) # 43ca <close>
    exit(0);
    16c8:	4501                	li	a0,0
    16ca:	00003097          	auipc	ra,0x3
    16ce:	cd8080e7          	jalr	-808(ra) # 43a2 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    16d2:	85a6                	mv	a1,s1
    16d4:	00004517          	auipc	a0,0x4
    16d8:	efc50513          	addi	a0,a0,-260 # 55d0 <malloc+0xdd8>
    16dc:	00003097          	auipc	ra,0x3
    16e0:	05e080e7          	jalr	94(ra) # 473a <printf>
    exit(1);
    16e4:	4505                	li	a0,1
    16e6:	00003097          	auipc	ra,0x3
    16ea:	cbc080e7          	jalr	-836(ra) # 43a2 <exit>
    exit(xstatus);
    16ee:	00003097          	auipc	ra,0x3
    16f2:	cb4080e7          	jalr	-844(ra) # 43a2 <exit>
    printf("%s: bigarg test failed!\n", s);
    16f6:	85a6                	mv	a1,s1
    16f8:	00004517          	auipc	a0,0x4
    16fc:	ef850513          	addi	a0,a0,-264 # 55f0 <malloc+0xdf8>
    1700:	00003097          	auipc	ra,0x3
    1704:	03a080e7          	jalr	58(ra) # 473a <printf>
    exit(1);
    1708:	4505                	li	a0,1
    170a:	00003097          	auipc	ra,0x3
    170e:	c98080e7          	jalr	-872(ra) # 43a2 <exit>

0000000000001712 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1712:	7139                	addi	sp,sp,-64
    1714:	fc06                	sd	ra,56(sp)
    1716:	f822                	sd	s0,48(sp)
    1718:	f426                	sd	s1,40(sp)
    171a:	f04a                	sd	s2,32(sp)
    171c:	ec4e                	sd	s3,24(sp)
    171e:	0080                	addi	s0,sp,64
    1720:	64b1                	lui	s1,0xc
    1722:	35048493          	addi	s1,s1,848 # c350 <__BSS_END__+0x1c0>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1726:	597d                	li	s2,-1
    1728:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    172c:	00003997          	auipc	s3,0x3
    1730:	76498993          	addi	s3,s3,1892 # 4e90 <malloc+0x698>
    argv[0] = (char*)0xffffffff;
    1734:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1738:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    173c:	fc040593          	addi	a1,s0,-64
    1740:	854e                	mv	a0,s3
    1742:	00003097          	auipc	ra,0x3
    1746:	c98080e7          	jalr	-872(ra) # 43da <exec>
  for(int i = 0; i < 50000; i++){
    174a:	34fd                	addiw	s1,s1,-1
    174c:	f4e5                	bnez	s1,1734 <badarg+0x22>
  }
  
  exit(0);
    174e:	4501                	li	a0,0
    1750:	00003097          	auipc	ra,0x3
    1754:	c52080e7          	jalr	-942(ra) # 43a2 <exit>

0000000000001758 <pipe1>:
{
    1758:	711d                	addi	sp,sp,-96
    175a:	ec86                	sd	ra,88(sp)
    175c:	e8a2                	sd	s0,80(sp)
    175e:	e4a6                	sd	s1,72(sp)
    1760:	e0ca                	sd	s2,64(sp)
    1762:	fc4e                	sd	s3,56(sp)
    1764:	f852                	sd	s4,48(sp)
    1766:	f456                	sd	s5,40(sp)
    1768:	f05a                	sd	s6,32(sp)
    176a:	ec5e                	sd	s7,24(sp)
    176c:	1080                	addi	s0,sp,96
    176e:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1770:	fa840513          	addi	a0,s0,-88
    1774:	00003097          	auipc	ra,0x3
    1778:	c3e080e7          	jalr	-962(ra) # 43b2 <pipe>
    177c:	ed25                	bnez	a0,17f4 <pipe1+0x9c>
    177e:	84aa                	mv	s1,a0
  pid = fork();
    1780:	00003097          	auipc	ra,0x3
    1784:	c1a080e7          	jalr	-998(ra) # 439a <fork>
    1788:	8a2a                	mv	s4,a0
  if(pid == 0){
    178a:	c159                	beqz	a0,1810 <pipe1+0xb8>
  } else if(pid > 0){
    178c:	16a05e63          	blez	a0,1908 <pipe1+0x1b0>
    close(fds[1]);
    1790:	fac42503          	lw	a0,-84(s0)
    1794:	00003097          	auipc	ra,0x3
    1798:	c36080e7          	jalr	-970(ra) # 43ca <close>
    total = 0;
    179c:	8a26                	mv	s4,s1
    cc = 1;
    179e:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    17a0:	00008a97          	auipc	s5,0x8
    17a4:	9e0a8a93          	addi	s5,s5,-1568 # 9180 <buf>
      if(cc > sizeof(buf))
    17a8:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    17aa:	864e                	mv	a2,s3
    17ac:	85d6                	mv	a1,s5
    17ae:	fa842503          	lw	a0,-88(s0)
    17b2:	00003097          	auipc	ra,0x3
    17b6:	c08080e7          	jalr	-1016(ra) # 43ba <read>
    17ba:	10a05263          	blez	a0,18be <pipe1+0x166>
      for(i = 0; i < n; i++){
    17be:	00008717          	auipc	a4,0x8
    17c2:	9c270713          	addi	a4,a4,-1598 # 9180 <buf>
    17c6:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17ca:	00074683          	lbu	a3,0(a4)
    17ce:	0ff4f793          	andi	a5,s1,255
    17d2:	2485                	addiw	s1,s1,1
    17d4:	0cf69163          	bne	a3,a5,1896 <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17d8:	0705                	addi	a4,a4,1
    17da:	fec498e3          	bne	s1,a2,17ca <pipe1+0x72>
      total += n;
    17de:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17e2:	0019979b          	slliw	a5,s3,0x1
    17e6:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17ea:	013b7363          	bgeu	s6,s3,17f0 <pipe1+0x98>
        cc = sizeof(buf);
    17ee:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17f0:	84b2                	mv	s1,a2
    17f2:	bf65                	j	17aa <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17f4:	85ca                	mv	a1,s2
    17f6:	00004517          	auipc	a0,0x4
    17fa:	e1a50513          	addi	a0,a0,-486 # 5610 <malloc+0xe18>
    17fe:	00003097          	auipc	ra,0x3
    1802:	f3c080e7          	jalr	-196(ra) # 473a <printf>
    exit(1);
    1806:	4505                	li	a0,1
    1808:	00003097          	auipc	ra,0x3
    180c:	b9a080e7          	jalr	-1126(ra) # 43a2 <exit>
    close(fds[0]);
    1810:	fa842503          	lw	a0,-88(s0)
    1814:	00003097          	auipc	ra,0x3
    1818:	bb6080e7          	jalr	-1098(ra) # 43ca <close>
    for(n = 0; n < N; n++){
    181c:	00008b17          	auipc	s6,0x8
    1820:	964b0b13          	addi	s6,s6,-1692 # 9180 <buf>
    1824:	416004bb          	negw	s1,s6
    1828:	0ff4f493          	andi	s1,s1,255
    182c:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1830:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1832:	6a85                	lui	s5,0x1
    1834:	42da8a93          	addi	s5,s5,1069 # 142d <unlinkread+0x1b3>
{
    1838:	87da                	mv	a5,s6
        buf[i] = seq++;
    183a:	0097873b          	addw	a4,a5,s1
    183e:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1842:	0785                	addi	a5,a5,1
    1844:	fef99be3          	bne	s3,a5,183a <pipe1+0xe2>
        buf[i] = seq++;
    1848:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    184c:	40900613          	li	a2,1033
    1850:	85de                	mv	a1,s7
    1852:	fac42503          	lw	a0,-84(s0)
    1856:	00003097          	auipc	ra,0x3
    185a:	b6c080e7          	jalr	-1172(ra) # 43c2 <write>
    185e:	40900793          	li	a5,1033
    1862:	00f51c63          	bne	a0,a5,187a <pipe1+0x122>
    for(n = 0; n < N; n++){
    1866:	24a5                	addiw	s1,s1,9
    1868:	0ff4f493          	andi	s1,s1,255
    186c:	fd5a16e3          	bne	s4,s5,1838 <pipe1+0xe0>
    exit(0);
    1870:	4501                	li	a0,0
    1872:	00003097          	auipc	ra,0x3
    1876:	b30080e7          	jalr	-1232(ra) # 43a2 <exit>
        printf("%s: pipe1 oops 1\n", s);
    187a:	85ca                	mv	a1,s2
    187c:	00004517          	auipc	a0,0x4
    1880:	dac50513          	addi	a0,a0,-596 # 5628 <malloc+0xe30>
    1884:	00003097          	auipc	ra,0x3
    1888:	eb6080e7          	jalr	-330(ra) # 473a <printf>
        exit(1);
    188c:	4505                	li	a0,1
    188e:	00003097          	auipc	ra,0x3
    1892:	b14080e7          	jalr	-1260(ra) # 43a2 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1896:	85ca                	mv	a1,s2
    1898:	00004517          	auipc	a0,0x4
    189c:	da850513          	addi	a0,a0,-600 # 5640 <malloc+0xe48>
    18a0:	00003097          	auipc	ra,0x3
    18a4:	e9a080e7          	jalr	-358(ra) # 473a <printf>
}
    18a8:	60e6                	ld	ra,88(sp)
    18aa:	6446                	ld	s0,80(sp)
    18ac:	64a6                	ld	s1,72(sp)
    18ae:	6906                	ld	s2,64(sp)
    18b0:	79e2                	ld	s3,56(sp)
    18b2:	7a42                	ld	s4,48(sp)
    18b4:	7aa2                	ld	s5,40(sp)
    18b6:	7b02                	ld	s6,32(sp)
    18b8:	6be2                	ld	s7,24(sp)
    18ba:	6125                	addi	sp,sp,96
    18bc:	8082                	ret
    if(total != N * SZ){
    18be:	6785                	lui	a5,0x1
    18c0:	42d78793          	addi	a5,a5,1069 # 142d <unlinkread+0x1b3>
    18c4:	02fa0063          	beq	s4,a5,18e4 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18c8:	85d2                	mv	a1,s4
    18ca:	00004517          	auipc	a0,0x4
    18ce:	d8e50513          	addi	a0,a0,-626 # 5658 <malloc+0xe60>
    18d2:	00003097          	auipc	ra,0x3
    18d6:	e68080e7          	jalr	-408(ra) # 473a <printf>
      exit(1);
    18da:	4505                	li	a0,1
    18dc:	00003097          	auipc	ra,0x3
    18e0:	ac6080e7          	jalr	-1338(ra) # 43a2 <exit>
    close(fds[0]);
    18e4:	fa842503          	lw	a0,-88(s0)
    18e8:	00003097          	auipc	ra,0x3
    18ec:	ae2080e7          	jalr	-1310(ra) # 43ca <close>
    wait(&xstatus);
    18f0:	fa440513          	addi	a0,s0,-92
    18f4:	00003097          	auipc	ra,0x3
    18f8:	ab6080e7          	jalr	-1354(ra) # 43aa <wait>
    exit(xstatus);
    18fc:	fa442503          	lw	a0,-92(s0)
    1900:	00003097          	auipc	ra,0x3
    1904:	aa2080e7          	jalr	-1374(ra) # 43a2 <exit>
    printf("%s: fork() failed\n", s);
    1908:	85ca                	mv	a1,s2
    190a:	00004517          	auipc	a0,0x4
    190e:	d6e50513          	addi	a0,a0,-658 # 5678 <malloc+0xe80>
    1912:	00003097          	auipc	ra,0x3
    1916:	e28080e7          	jalr	-472(ra) # 473a <printf>
    exit(1);
    191a:	4505                	li	a0,1
    191c:	00003097          	auipc	ra,0x3
    1920:	a86080e7          	jalr	-1402(ra) # 43a2 <exit>

0000000000001924 <pgbug>:
{
    1924:	7179                	addi	sp,sp,-48
    1926:	f406                	sd	ra,40(sp)
    1928:	f022                	sd	s0,32(sp)
    192a:	ec26                	sd	s1,24(sp)
    192c:	1800                	addi	s0,sp,48
  argv[0] = 0;
    192e:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1932:	00005497          	auipc	s1,0x5
    1936:	01e4b483          	ld	s1,30(s1) # 6950 <__SDATA_BEGIN__>
    193a:	fd840593          	addi	a1,s0,-40
    193e:	8526                	mv	a0,s1
    1940:	00003097          	auipc	ra,0x3
    1944:	a9a080e7          	jalr	-1382(ra) # 43da <exec>
  pipe((int*)0xeaeb0b5b00002f5e);
    1948:	8526                	mv	a0,s1
    194a:	00003097          	auipc	ra,0x3
    194e:	a68080e7          	jalr	-1432(ra) # 43b2 <pipe>
  exit(0);
    1952:	4501                	li	a0,0
    1954:	00003097          	auipc	ra,0x3
    1958:	a4e080e7          	jalr	-1458(ra) # 43a2 <exit>

000000000000195c <preempt>:
{
    195c:	7139                	addi	sp,sp,-64
    195e:	fc06                	sd	ra,56(sp)
    1960:	f822                	sd	s0,48(sp)
    1962:	f426                	sd	s1,40(sp)
    1964:	f04a                	sd	s2,32(sp)
    1966:	ec4e                	sd	s3,24(sp)
    1968:	e852                	sd	s4,16(sp)
    196a:	0080                	addi	s0,sp,64
    196c:	892a                	mv	s2,a0
  pid1 = fork();
    196e:	00003097          	auipc	ra,0x3
    1972:	a2c080e7          	jalr	-1492(ra) # 439a <fork>
  if(pid1 < 0) {
    1976:	00054563          	bltz	a0,1980 <preempt+0x24>
    197a:	84aa                	mv	s1,a0
  if(pid1 == 0)
    197c:	ed19                	bnez	a0,199a <preempt+0x3e>
    for(;;)
    197e:	a001                	j	197e <preempt+0x22>
    printf("%s: fork failed");
    1980:	00003517          	auipc	a0,0x3
    1984:	3c850513          	addi	a0,a0,968 # 4d48 <malloc+0x550>
    1988:	00003097          	auipc	ra,0x3
    198c:	db2080e7          	jalr	-590(ra) # 473a <printf>
    exit(1);
    1990:	4505                	li	a0,1
    1992:	00003097          	auipc	ra,0x3
    1996:	a10080e7          	jalr	-1520(ra) # 43a2 <exit>
  pid2 = fork();
    199a:	00003097          	auipc	ra,0x3
    199e:	a00080e7          	jalr	-1536(ra) # 439a <fork>
    19a2:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    19a4:	00054463          	bltz	a0,19ac <preempt+0x50>
  if(pid2 == 0)
    19a8:	e105                	bnez	a0,19c8 <preempt+0x6c>
    for(;;)
    19aa:	a001                	j	19aa <preempt+0x4e>
    printf("%s: fork failed\n", s);
    19ac:	85ca                	mv	a1,s2
    19ae:	00003517          	auipc	a0,0x3
    19b2:	33250513          	addi	a0,a0,818 # 4ce0 <malloc+0x4e8>
    19b6:	00003097          	auipc	ra,0x3
    19ba:	d84080e7          	jalr	-636(ra) # 473a <printf>
    exit(1);
    19be:	4505                	li	a0,1
    19c0:	00003097          	auipc	ra,0x3
    19c4:	9e2080e7          	jalr	-1566(ra) # 43a2 <exit>
  pipe(pfds);
    19c8:	fc840513          	addi	a0,s0,-56
    19cc:	00003097          	auipc	ra,0x3
    19d0:	9e6080e7          	jalr	-1562(ra) # 43b2 <pipe>
  pid3 = fork();
    19d4:	00003097          	auipc	ra,0x3
    19d8:	9c6080e7          	jalr	-1594(ra) # 439a <fork>
    19dc:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    19de:	02054e63          	bltz	a0,1a1a <preempt+0xbe>
  if(pid3 == 0){
    19e2:	e13d                	bnez	a0,1a48 <preempt+0xec>
    close(pfds[0]);
    19e4:	fc842503          	lw	a0,-56(s0)
    19e8:	00003097          	auipc	ra,0x3
    19ec:	9e2080e7          	jalr	-1566(ra) # 43ca <close>
    if(write(pfds[1], "x", 1) != 1)
    19f0:	4605                	li	a2,1
    19f2:	00004597          	auipc	a1,0x4
    19f6:	c9e58593          	addi	a1,a1,-866 # 5690 <malloc+0xe98>
    19fa:	fcc42503          	lw	a0,-52(s0)
    19fe:	00003097          	auipc	ra,0x3
    1a02:	9c4080e7          	jalr	-1596(ra) # 43c2 <write>
    1a06:	4785                	li	a5,1
    1a08:	02f51763          	bne	a0,a5,1a36 <preempt+0xda>
    close(pfds[1]);
    1a0c:	fcc42503          	lw	a0,-52(s0)
    1a10:	00003097          	auipc	ra,0x3
    1a14:	9ba080e7          	jalr	-1606(ra) # 43ca <close>
    for(;;)
    1a18:	a001                	j	1a18 <preempt+0xbc>
     printf("%s: fork failed\n", s);
    1a1a:	85ca                	mv	a1,s2
    1a1c:	00003517          	auipc	a0,0x3
    1a20:	2c450513          	addi	a0,a0,708 # 4ce0 <malloc+0x4e8>
    1a24:	00003097          	auipc	ra,0x3
    1a28:	d16080e7          	jalr	-746(ra) # 473a <printf>
     exit(1);
    1a2c:	4505                	li	a0,1
    1a2e:	00003097          	auipc	ra,0x3
    1a32:	974080e7          	jalr	-1676(ra) # 43a2 <exit>
      printf("%s: preempt write error");
    1a36:	00004517          	auipc	a0,0x4
    1a3a:	c6250513          	addi	a0,a0,-926 # 5698 <malloc+0xea0>
    1a3e:	00003097          	auipc	ra,0x3
    1a42:	cfc080e7          	jalr	-772(ra) # 473a <printf>
    1a46:	b7d9                	j	1a0c <preempt+0xb0>
  close(pfds[1]);
    1a48:	fcc42503          	lw	a0,-52(s0)
    1a4c:	00003097          	auipc	ra,0x3
    1a50:	97e080e7          	jalr	-1666(ra) # 43ca <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    1a54:	660d                	lui	a2,0x3
    1a56:	00007597          	auipc	a1,0x7
    1a5a:	72a58593          	addi	a1,a1,1834 # 9180 <buf>
    1a5e:	fc842503          	lw	a0,-56(s0)
    1a62:	00003097          	auipc	ra,0x3
    1a66:	958080e7          	jalr	-1704(ra) # 43ba <read>
    1a6a:	4785                	li	a5,1
    1a6c:	02f50263          	beq	a0,a5,1a90 <preempt+0x134>
    printf("%s: preempt read error");
    1a70:	00004517          	auipc	a0,0x4
    1a74:	c4050513          	addi	a0,a0,-960 # 56b0 <malloc+0xeb8>
    1a78:	00003097          	auipc	ra,0x3
    1a7c:	cc2080e7          	jalr	-830(ra) # 473a <printf>
}
    1a80:	70e2                	ld	ra,56(sp)
    1a82:	7442                	ld	s0,48(sp)
    1a84:	74a2                	ld	s1,40(sp)
    1a86:	7902                	ld	s2,32(sp)
    1a88:	69e2                	ld	s3,24(sp)
    1a8a:	6a42                	ld	s4,16(sp)
    1a8c:	6121                	addi	sp,sp,64
    1a8e:	8082                	ret
  close(pfds[0]);
    1a90:	fc842503          	lw	a0,-56(s0)
    1a94:	00003097          	auipc	ra,0x3
    1a98:	936080e7          	jalr	-1738(ra) # 43ca <close>
  printf("kill... ");
    1a9c:	00004517          	auipc	a0,0x4
    1aa0:	c2c50513          	addi	a0,a0,-980 # 56c8 <malloc+0xed0>
    1aa4:	00003097          	auipc	ra,0x3
    1aa8:	c96080e7          	jalr	-874(ra) # 473a <printf>
  kill(pid1);
    1aac:	8526                	mv	a0,s1
    1aae:	00003097          	auipc	ra,0x3
    1ab2:	924080e7          	jalr	-1756(ra) # 43d2 <kill>
  kill(pid2);
    1ab6:	854e                	mv	a0,s3
    1ab8:	00003097          	auipc	ra,0x3
    1abc:	91a080e7          	jalr	-1766(ra) # 43d2 <kill>
  kill(pid3);
    1ac0:	8552                	mv	a0,s4
    1ac2:	00003097          	auipc	ra,0x3
    1ac6:	910080e7          	jalr	-1776(ra) # 43d2 <kill>
  printf("wait... ");
    1aca:	00004517          	auipc	a0,0x4
    1ace:	c0e50513          	addi	a0,a0,-1010 # 56d8 <malloc+0xee0>
    1ad2:	00003097          	auipc	ra,0x3
    1ad6:	c68080e7          	jalr	-920(ra) # 473a <printf>
  wait(0);
    1ada:	4501                	li	a0,0
    1adc:	00003097          	auipc	ra,0x3
    1ae0:	8ce080e7          	jalr	-1842(ra) # 43aa <wait>
  wait(0);
    1ae4:	4501                	li	a0,0
    1ae6:	00003097          	auipc	ra,0x3
    1aea:	8c4080e7          	jalr	-1852(ra) # 43aa <wait>
  wait(0);
    1aee:	4501                	li	a0,0
    1af0:	00003097          	auipc	ra,0x3
    1af4:	8ba080e7          	jalr	-1862(ra) # 43aa <wait>
    1af8:	b761                	j	1a80 <preempt+0x124>

0000000000001afa <reparent>:
{
    1afa:	7179                	addi	sp,sp,-48
    1afc:	f406                	sd	ra,40(sp)
    1afe:	f022                	sd	s0,32(sp)
    1b00:	ec26                	sd	s1,24(sp)
    1b02:	e84a                	sd	s2,16(sp)
    1b04:	e44e                	sd	s3,8(sp)
    1b06:	e052                	sd	s4,0(sp)
    1b08:	1800                	addi	s0,sp,48
    1b0a:	89aa                	mv	s3,a0
  int master_pid = getpid();
    1b0c:	00003097          	auipc	ra,0x3
    1b10:	916080e7          	jalr	-1770(ra) # 4422 <getpid>
    1b14:	8a2a                	mv	s4,a0
    1b16:	0c800913          	li	s2,200
    int pid = fork();
    1b1a:	00003097          	auipc	ra,0x3
    1b1e:	880080e7          	jalr	-1920(ra) # 439a <fork>
    1b22:	84aa                	mv	s1,a0
    if(pid < 0){
    1b24:	02054263          	bltz	a0,1b48 <reparent+0x4e>
    if(pid){
    1b28:	cd21                	beqz	a0,1b80 <reparent+0x86>
      if(wait(0) != pid){
    1b2a:	4501                	li	a0,0
    1b2c:	00003097          	auipc	ra,0x3
    1b30:	87e080e7          	jalr	-1922(ra) # 43aa <wait>
    1b34:	02951863          	bne	a0,s1,1b64 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    1b38:	397d                	addiw	s2,s2,-1
    1b3a:	fe0910e3          	bnez	s2,1b1a <reparent+0x20>
  exit(0);
    1b3e:	4501                	li	a0,0
    1b40:	00003097          	auipc	ra,0x3
    1b44:	862080e7          	jalr	-1950(ra) # 43a2 <exit>
      printf("%s: fork failed\n", s);
    1b48:	85ce                	mv	a1,s3
    1b4a:	00003517          	auipc	a0,0x3
    1b4e:	19650513          	addi	a0,a0,406 # 4ce0 <malloc+0x4e8>
    1b52:	00003097          	auipc	ra,0x3
    1b56:	be8080e7          	jalr	-1048(ra) # 473a <printf>
      exit(1);
    1b5a:	4505                	li	a0,1
    1b5c:	00003097          	auipc	ra,0x3
    1b60:	846080e7          	jalr	-1978(ra) # 43a2 <exit>
        printf("%s: wait wrong pid\n", s);
    1b64:	85ce                	mv	a1,s3
    1b66:	00003517          	auipc	a0,0x3
    1b6a:	1aa50513          	addi	a0,a0,426 # 4d10 <malloc+0x518>
    1b6e:	00003097          	auipc	ra,0x3
    1b72:	bcc080e7          	jalr	-1076(ra) # 473a <printf>
        exit(1);
    1b76:	4505                	li	a0,1
    1b78:	00003097          	auipc	ra,0x3
    1b7c:	82a080e7          	jalr	-2006(ra) # 43a2 <exit>
      int pid2 = fork();
    1b80:	00003097          	auipc	ra,0x3
    1b84:	81a080e7          	jalr	-2022(ra) # 439a <fork>
      if(pid2 < 0){
    1b88:	00054763          	bltz	a0,1b96 <reparent+0x9c>
      exit(0);
    1b8c:	4501                	li	a0,0
    1b8e:	00003097          	auipc	ra,0x3
    1b92:	814080e7          	jalr	-2028(ra) # 43a2 <exit>
        kill(master_pid);
    1b96:	8552                	mv	a0,s4
    1b98:	00003097          	auipc	ra,0x3
    1b9c:	83a080e7          	jalr	-1990(ra) # 43d2 <kill>
        exit(1);
    1ba0:	4505                	li	a0,1
    1ba2:	00003097          	auipc	ra,0x3
    1ba6:	800080e7          	jalr	-2048(ra) # 43a2 <exit>

0000000000001baa <sharedfd>:
{
    1baa:	7159                	addi	sp,sp,-112
    1bac:	f486                	sd	ra,104(sp)
    1bae:	f0a2                	sd	s0,96(sp)
    1bb0:	eca6                	sd	s1,88(sp)
    1bb2:	e8ca                	sd	s2,80(sp)
    1bb4:	e4ce                	sd	s3,72(sp)
    1bb6:	e0d2                	sd	s4,64(sp)
    1bb8:	fc56                	sd	s5,56(sp)
    1bba:	f85a                	sd	s6,48(sp)
    1bbc:	f45e                	sd	s7,40(sp)
    1bbe:	1880                	addi	s0,sp,112
    1bc0:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    1bc2:	00003517          	auipc	a0,0x3
    1bc6:	e2650513          	addi	a0,a0,-474 # 49e8 <malloc+0x1f0>
    1bca:	00003097          	auipc	ra,0x3
    1bce:	828080e7          	jalr	-2008(ra) # 43f2 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    1bd2:	20200593          	li	a1,514
    1bd6:	00003517          	auipc	a0,0x3
    1bda:	e1250513          	addi	a0,a0,-494 # 49e8 <malloc+0x1f0>
    1bde:	00003097          	auipc	ra,0x3
    1be2:	804080e7          	jalr	-2044(ra) # 43e2 <open>
  if(fd < 0){
    1be6:	04054a63          	bltz	a0,1c3a <sharedfd+0x90>
    1bea:	892a                	mv	s2,a0
  pid = fork();
    1bec:	00002097          	auipc	ra,0x2
    1bf0:	7ae080e7          	jalr	1966(ra) # 439a <fork>
    1bf4:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    1bf6:	06300593          	li	a1,99
    1bfa:	c119                	beqz	a0,1c00 <sharedfd+0x56>
    1bfc:	07000593          	li	a1,112
    1c00:	4629                	li	a2,10
    1c02:	fa040513          	addi	a0,s0,-96
    1c06:	00002097          	auipc	ra,0x2
    1c0a:	620080e7          	jalr	1568(ra) # 4226 <memset>
    1c0e:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    1c12:	4629                	li	a2,10
    1c14:	fa040593          	addi	a1,s0,-96
    1c18:	854a                	mv	a0,s2
    1c1a:	00002097          	auipc	ra,0x2
    1c1e:	7a8080e7          	jalr	1960(ra) # 43c2 <write>
    1c22:	47a9                	li	a5,10
    1c24:	02f51963          	bne	a0,a5,1c56 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    1c28:	34fd                	addiw	s1,s1,-1
    1c2a:	f4e5                	bnez	s1,1c12 <sharedfd+0x68>
  if(pid == 0) {
    1c2c:	04099363          	bnez	s3,1c72 <sharedfd+0xc8>
    exit(0);
    1c30:	4501                	li	a0,0
    1c32:	00002097          	auipc	ra,0x2
    1c36:	770080e7          	jalr	1904(ra) # 43a2 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    1c3a:	85d2                	mv	a1,s4
    1c3c:	00004517          	auipc	a0,0x4
    1c40:	aac50513          	addi	a0,a0,-1364 # 56e8 <malloc+0xef0>
    1c44:	00003097          	auipc	ra,0x3
    1c48:	af6080e7          	jalr	-1290(ra) # 473a <printf>
    exit(1);
    1c4c:	4505                	li	a0,1
    1c4e:	00002097          	auipc	ra,0x2
    1c52:	754080e7          	jalr	1876(ra) # 43a2 <exit>
      printf("%s: write sharedfd failed\n", s);
    1c56:	85d2                	mv	a1,s4
    1c58:	00004517          	auipc	a0,0x4
    1c5c:	ab850513          	addi	a0,a0,-1352 # 5710 <malloc+0xf18>
    1c60:	00003097          	auipc	ra,0x3
    1c64:	ada080e7          	jalr	-1318(ra) # 473a <printf>
      exit(1);
    1c68:	4505                	li	a0,1
    1c6a:	00002097          	auipc	ra,0x2
    1c6e:	738080e7          	jalr	1848(ra) # 43a2 <exit>
    wait(&xstatus);
    1c72:	f9c40513          	addi	a0,s0,-100
    1c76:	00002097          	auipc	ra,0x2
    1c7a:	734080e7          	jalr	1844(ra) # 43aa <wait>
    if(xstatus != 0)
    1c7e:	f9c42983          	lw	s3,-100(s0)
    1c82:	00098763          	beqz	s3,1c90 <sharedfd+0xe6>
      exit(xstatus);
    1c86:	854e                	mv	a0,s3
    1c88:	00002097          	auipc	ra,0x2
    1c8c:	71a080e7          	jalr	1818(ra) # 43a2 <exit>
  close(fd);
    1c90:	854a                	mv	a0,s2
    1c92:	00002097          	auipc	ra,0x2
    1c96:	738080e7          	jalr	1848(ra) # 43ca <close>
  fd = open("sharedfd", 0);
    1c9a:	4581                	li	a1,0
    1c9c:	00003517          	auipc	a0,0x3
    1ca0:	d4c50513          	addi	a0,a0,-692 # 49e8 <malloc+0x1f0>
    1ca4:	00002097          	auipc	ra,0x2
    1ca8:	73e080e7          	jalr	1854(ra) # 43e2 <open>
    1cac:	8baa                	mv	s7,a0
  nc = np = 0;
    1cae:	8ace                	mv	s5,s3
  if(fd < 0){
    1cb0:	02054563          	bltz	a0,1cda <sharedfd+0x130>
    1cb4:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    1cb8:	06300493          	li	s1,99
      if(buf[i] == 'p')
    1cbc:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    1cc0:	4629                	li	a2,10
    1cc2:	fa040593          	addi	a1,s0,-96
    1cc6:	855e                	mv	a0,s7
    1cc8:	00002097          	auipc	ra,0x2
    1ccc:	6f2080e7          	jalr	1778(ra) # 43ba <read>
    1cd0:	02a05f63          	blez	a0,1d0e <sharedfd+0x164>
    1cd4:	fa040793          	addi	a5,s0,-96
    1cd8:	a01d                	j	1cfe <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    1cda:	85d2                	mv	a1,s4
    1cdc:	00004517          	auipc	a0,0x4
    1ce0:	a5450513          	addi	a0,a0,-1452 # 5730 <malloc+0xf38>
    1ce4:	00003097          	auipc	ra,0x3
    1ce8:	a56080e7          	jalr	-1450(ra) # 473a <printf>
    exit(1);
    1cec:	4505                	li	a0,1
    1cee:	00002097          	auipc	ra,0x2
    1cf2:	6b4080e7          	jalr	1716(ra) # 43a2 <exit>
        nc++;
    1cf6:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    1cf8:	0785                	addi	a5,a5,1
    1cfa:	fd2783e3          	beq	a5,s2,1cc0 <sharedfd+0x116>
      if(buf[i] == 'c')
    1cfe:	0007c703          	lbu	a4,0(a5)
    1d02:	fe970ae3          	beq	a4,s1,1cf6 <sharedfd+0x14c>
      if(buf[i] == 'p')
    1d06:	ff6719e3          	bne	a4,s6,1cf8 <sharedfd+0x14e>
        np++;
    1d0a:	2a85                	addiw	s5,s5,1
    1d0c:	b7f5                	j	1cf8 <sharedfd+0x14e>
  close(fd);
    1d0e:	855e                	mv	a0,s7
    1d10:	00002097          	auipc	ra,0x2
    1d14:	6ba080e7          	jalr	1722(ra) # 43ca <close>
  unlink("sharedfd");
    1d18:	00003517          	auipc	a0,0x3
    1d1c:	cd050513          	addi	a0,a0,-816 # 49e8 <malloc+0x1f0>
    1d20:	00002097          	auipc	ra,0x2
    1d24:	6d2080e7          	jalr	1746(ra) # 43f2 <unlink>
  if(nc == N*SZ && np == N*SZ){
    1d28:	6789                	lui	a5,0x2
    1d2a:	71078793          	addi	a5,a5,1808 # 2710 <linkunlink+0x2a>
    1d2e:	00f99763          	bne	s3,a5,1d3c <sharedfd+0x192>
    1d32:	6789                	lui	a5,0x2
    1d34:	71078793          	addi	a5,a5,1808 # 2710 <linkunlink+0x2a>
    1d38:	02fa8063          	beq	s5,a5,1d58 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    1d3c:	85d2                	mv	a1,s4
    1d3e:	00004517          	auipc	a0,0x4
    1d42:	a1a50513          	addi	a0,a0,-1510 # 5758 <malloc+0xf60>
    1d46:	00003097          	auipc	ra,0x3
    1d4a:	9f4080e7          	jalr	-1548(ra) # 473a <printf>
    exit(1);
    1d4e:	4505                	li	a0,1
    1d50:	00002097          	auipc	ra,0x2
    1d54:	652080e7          	jalr	1618(ra) # 43a2 <exit>
    exit(0);
    1d58:	4501                	li	a0,0
    1d5a:	00002097          	auipc	ra,0x2
    1d5e:	648080e7          	jalr	1608(ra) # 43a2 <exit>

0000000000001d62 <fourfiles>:
{
    1d62:	7171                	addi	sp,sp,-176
    1d64:	f506                	sd	ra,168(sp)
    1d66:	f122                	sd	s0,160(sp)
    1d68:	ed26                	sd	s1,152(sp)
    1d6a:	e94a                	sd	s2,144(sp)
    1d6c:	e54e                	sd	s3,136(sp)
    1d6e:	e152                	sd	s4,128(sp)
    1d70:	fcd6                	sd	s5,120(sp)
    1d72:	f8da                	sd	s6,112(sp)
    1d74:	f4de                	sd	s7,104(sp)
    1d76:	f0e2                	sd	s8,96(sp)
    1d78:	ece6                	sd	s9,88(sp)
    1d7a:	e8ea                	sd	s10,80(sp)
    1d7c:	e4ee                	sd	s11,72(sp)
    1d7e:	1900                	addi	s0,sp,176
    1d80:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    1d84:	00003797          	auipc	a5,0x3
    1d88:	b5c78793          	addi	a5,a5,-1188 # 48e0 <malloc+0xe8>
    1d8c:	f6f43823          	sd	a5,-144(s0)
    1d90:	00003797          	auipc	a5,0x3
    1d94:	b5878793          	addi	a5,a5,-1192 # 48e8 <malloc+0xf0>
    1d98:	f6f43c23          	sd	a5,-136(s0)
    1d9c:	00003797          	auipc	a5,0x3
    1da0:	b5478793          	addi	a5,a5,-1196 # 48f0 <malloc+0xf8>
    1da4:	f8f43023          	sd	a5,-128(s0)
    1da8:	00003797          	auipc	a5,0x3
    1dac:	b5078793          	addi	a5,a5,-1200 # 48f8 <malloc+0x100>
    1db0:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    1db4:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    1db8:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    1dba:	4481                	li	s1,0
    1dbc:	4a11                	li	s4,4
    fname = names[pi];
    1dbe:	00093983          	ld	s3,0(s2)
    unlink(fname);
    1dc2:	854e                	mv	a0,s3
    1dc4:	00002097          	auipc	ra,0x2
    1dc8:	62e080e7          	jalr	1582(ra) # 43f2 <unlink>
    pid = fork();
    1dcc:	00002097          	auipc	ra,0x2
    1dd0:	5ce080e7          	jalr	1486(ra) # 439a <fork>
    if(pid < 0){
    1dd4:	04054463          	bltz	a0,1e1c <fourfiles+0xba>
    if(pid == 0){
    1dd8:	c12d                	beqz	a0,1e3a <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    1dda:	2485                	addiw	s1,s1,1
    1ddc:	0921                	addi	s2,s2,8
    1dde:	ff4490e3          	bne	s1,s4,1dbe <fourfiles+0x5c>
    1de2:	4491                	li	s1,4
    wait(&xstatus);
    1de4:	f6c40513          	addi	a0,s0,-148
    1de8:	00002097          	auipc	ra,0x2
    1dec:	5c2080e7          	jalr	1474(ra) # 43aa <wait>
    if(xstatus != 0)
    1df0:	f6c42b03          	lw	s6,-148(s0)
    1df4:	0c0b1e63          	bnez	s6,1ed0 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    1df8:	34fd                	addiw	s1,s1,-1
    1dfa:	f4ed                	bnez	s1,1de4 <fourfiles+0x82>
    1dfc:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    1e00:	00007a17          	auipc	s4,0x7
    1e04:	380a0a13          	addi	s4,s4,896 # 9180 <buf>
    1e08:	00007a97          	auipc	s5,0x7
    1e0c:	379a8a93          	addi	s5,s5,889 # 9181 <buf+0x1>
    if(total != N*SZ){
    1e10:	6d85                	lui	s11,0x1
    1e12:	770d8d93          	addi	s11,s11,1904 # 1770 <pipe1+0x18>
  for(i = 0; i < NCHILD; i++){
    1e16:	03400d13          	li	s10,52
    1e1a:	aa1d                	j	1f50 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    1e1c:	f5843583          	ld	a1,-168(s0)
    1e20:	00003517          	auipc	a0,0x3
    1e24:	7c050513          	addi	a0,a0,1984 # 55e0 <malloc+0xde8>
    1e28:	00003097          	auipc	ra,0x3
    1e2c:	912080e7          	jalr	-1774(ra) # 473a <printf>
      exit(1);
    1e30:	4505                	li	a0,1
    1e32:	00002097          	auipc	ra,0x2
    1e36:	570080e7          	jalr	1392(ra) # 43a2 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    1e3a:	20200593          	li	a1,514
    1e3e:	854e                	mv	a0,s3
    1e40:	00002097          	auipc	ra,0x2
    1e44:	5a2080e7          	jalr	1442(ra) # 43e2 <open>
    1e48:	892a                	mv	s2,a0
      if(fd < 0){
    1e4a:	04054763          	bltz	a0,1e98 <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    1e4e:	1f400613          	li	a2,500
    1e52:	0304859b          	addiw	a1,s1,48
    1e56:	00007517          	auipc	a0,0x7
    1e5a:	32a50513          	addi	a0,a0,810 # 9180 <buf>
    1e5e:	00002097          	auipc	ra,0x2
    1e62:	3c8080e7          	jalr	968(ra) # 4226 <memset>
    1e66:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    1e68:	00007997          	auipc	s3,0x7
    1e6c:	31898993          	addi	s3,s3,792 # 9180 <buf>
    1e70:	1f400613          	li	a2,500
    1e74:	85ce                	mv	a1,s3
    1e76:	854a                	mv	a0,s2
    1e78:	00002097          	auipc	ra,0x2
    1e7c:	54a080e7          	jalr	1354(ra) # 43c2 <write>
    1e80:	85aa                	mv	a1,a0
    1e82:	1f400793          	li	a5,500
    1e86:	02f51863          	bne	a0,a5,1eb6 <fourfiles+0x154>
      for(i = 0; i < N; i++){
    1e8a:	34fd                	addiw	s1,s1,-1
    1e8c:	f0f5                	bnez	s1,1e70 <fourfiles+0x10e>
      exit(0);
    1e8e:	4501                	li	a0,0
    1e90:	00002097          	auipc	ra,0x2
    1e94:	512080e7          	jalr	1298(ra) # 43a2 <exit>
        printf("create failed\n", s);
    1e98:	f5843583          	ld	a1,-168(s0)
    1e9c:	00004517          	auipc	a0,0x4
    1ea0:	8d450513          	addi	a0,a0,-1836 # 5770 <malloc+0xf78>
    1ea4:	00003097          	auipc	ra,0x3
    1ea8:	896080e7          	jalr	-1898(ra) # 473a <printf>
        exit(1);
    1eac:	4505                	li	a0,1
    1eae:	00002097          	auipc	ra,0x2
    1eb2:	4f4080e7          	jalr	1268(ra) # 43a2 <exit>
          printf("write failed %d\n", n);
    1eb6:	00004517          	auipc	a0,0x4
    1eba:	8ca50513          	addi	a0,a0,-1846 # 5780 <malloc+0xf88>
    1ebe:	00003097          	auipc	ra,0x3
    1ec2:	87c080e7          	jalr	-1924(ra) # 473a <printf>
          exit(1);
    1ec6:	4505                	li	a0,1
    1ec8:	00002097          	auipc	ra,0x2
    1ecc:	4da080e7          	jalr	1242(ra) # 43a2 <exit>
      exit(xstatus);
    1ed0:	855a                	mv	a0,s6
    1ed2:	00002097          	auipc	ra,0x2
    1ed6:	4d0080e7          	jalr	1232(ra) # 43a2 <exit>
          printf("wrong char\n", s);
    1eda:	f5843583          	ld	a1,-168(s0)
    1ede:	00004517          	auipc	a0,0x4
    1ee2:	8ba50513          	addi	a0,a0,-1862 # 5798 <malloc+0xfa0>
    1ee6:	00003097          	auipc	ra,0x3
    1eea:	854080e7          	jalr	-1964(ra) # 473a <printf>
          exit(1);
    1eee:	4505                	li	a0,1
    1ef0:	00002097          	auipc	ra,0x2
    1ef4:	4b2080e7          	jalr	1202(ra) # 43a2 <exit>
      total += n;
    1ef8:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    1efc:	660d                	lui	a2,0x3
    1efe:	85d2                	mv	a1,s4
    1f00:	854e                	mv	a0,s3
    1f02:	00002097          	auipc	ra,0x2
    1f06:	4b8080e7          	jalr	1208(ra) # 43ba <read>
    1f0a:	02a05363          	blez	a0,1f30 <fourfiles+0x1ce>
    1f0e:	00007797          	auipc	a5,0x7
    1f12:	27278793          	addi	a5,a5,626 # 9180 <buf>
    1f16:	fff5069b          	addiw	a3,a0,-1
    1f1a:	1682                	slli	a3,a3,0x20
    1f1c:	9281                	srli	a3,a3,0x20
    1f1e:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    1f20:	0007c703          	lbu	a4,0(a5)
    1f24:	fa971be3          	bne	a4,s1,1eda <fourfiles+0x178>
      for(j = 0; j < n; j++){
    1f28:	0785                	addi	a5,a5,1
    1f2a:	fed79be3          	bne	a5,a3,1f20 <fourfiles+0x1be>
    1f2e:	b7e9                	j	1ef8 <fourfiles+0x196>
    close(fd);
    1f30:	854e                	mv	a0,s3
    1f32:	00002097          	auipc	ra,0x2
    1f36:	498080e7          	jalr	1176(ra) # 43ca <close>
    if(total != N*SZ){
    1f3a:	03b91863          	bne	s2,s11,1f6a <fourfiles+0x208>
    unlink(fname);
    1f3e:	8566                	mv	a0,s9
    1f40:	00002097          	auipc	ra,0x2
    1f44:	4b2080e7          	jalr	1202(ra) # 43f2 <unlink>
  for(i = 0; i < NCHILD; i++){
    1f48:	0c21                	addi	s8,s8,8
    1f4a:	2b85                	addiw	s7,s7,1
    1f4c:	03ab8d63          	beq	s7,s10,1f86 <fourfiles+0x224>
    fname = names[i];
    1f50:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    1f54:	4581                	li	a1,0
    1f56:	8566                	mv	a0,s9
    1f58:	00002097          	auipc	ra,0x2
    1f5c:	48a080e7          	jalr	1162(ra) # 43e2 <open>
    1f60:	89aa                	mv	s3,a0
    total = 0;
    1f62:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    1f64:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    1f68:	bf51                	j	1efc <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    1f6a:	85ca                	mv	a1,s2
    1f6c:	00004517          	auipc	a0,0x4
    1f70:	83c50513          	addi	a0,a0,-1988 # 57a8 <malloc+0xfb0>
    1f74:	00002097          	auipc	ra,0x2
    1f78:	7c6080e7          	jalr	1990(ra) # 473a <printf>
      exit(1);
    1f7c:	4505                	li	a0,1
    1f7e:	00002097          	auipc	ra,0x2
    1f82:	424080e7          	jalr	1060(ra) # 43a2 <exit>
}
    1f86:	70aa                	ld	ra,168(sp)
    1f88:	740a                	ld	s0,160(sp)
    1f8a:	64ea                	ld	s1,152(sp)
    1f8c:	694a                	ld	s2,144(sp)
    1f8e:	69aa                	ld	s3,136(sp)
    1f90:	6a0a                	ld	s4,128(sp)
    1f92:	7ae6                	ld	s5,120(sp)
    1f94:	7b46                	ld	s6,112(sp)
    1f96:	7ba6                	ld	s7,104(sp)
    1f98:	7c06                	ld	s8,96(sp)
    1f9a:	6ce6                	ld	s9,88(sp)
    1f9c:	6d46                	ld	s10,80(sp)
    1f9e:	6da6                	ld	s11,72(sp)
    1fa0:	614d                	addi	sp,sp,176
    1fa2:	8082                	ret

0000000000001fa4 <bigfile>:
{
    1fa4:	7139                	addi	sp,sp,-64
    1fa6:	fc06                	sd	ra,56(sp)
    1fa8:	f822                	sd	s0,48(sp)
    1faa:	f426                	sd	s1,40(sp)
    1fac:	f04a                	sd	s2,32(sp)
    1fae:	ec4e                	sd	s3,24(sp)
    1fb0:	e852                	sd	s4,16(sp)
    1fb2:	e456                	sd	s5,8(sp)
    1fb4:	0080                	addi	s0,sp,64
    1fb6:	8aaa                	mv	s5,a0
  unlink("bigfile");
    1fb8:	00003517          	auipc	a0,0x3
    1fbc:	b6850513          	addi	a0,a0,-1176 # 4b20 <malloc+0x328>
    1fc0:	00002097          	auipc	ra,0x2
    1fc4:	432080e7          	jalr	1074(ra) # 43f2 <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    1fc8:	20200593          	li	a1,514
    1fcc:	00003517          	auipc	a0,0x3
    1fd0:	b5450513          	addi	a0,a0,-1196 # 4b20 <malloc+0x328>
    1fd4:	00002097          	auipc	ra,0x2
    1fd8:	40e080e7          	jalr	1038(ra) # 43e2 <open>
    1fdc:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    1fde:	4481                	li	s1,0
    memset(buf, i, SZ);
    1fe0:	00007917          	auipc	s2,0x7
    1fe4:	1a090913          	addi	s2,s2,416 # 9180 <buf>
  for(i = 0; i < N; i++){
    1fe8:	4a51                	li	s4,20
  if(fd < 0){
    1fea:	0a054063          	bltz	a0,208a <bigfile+0xe6>
    memset(buf, i, SZ);
    1fee:	25800613          	li	a2,600
    1ff2:	85a6                	mv	a1,s1
    1ff4:	854a                	mv	a0,s2
    1ff6:	00002097          	auipc	ra,0x2
    1ffa:	230080e7          	jalr	560(ra) # 4226 <memset>
    if(write(fd, buf, SZ) != SZ){
    1ffe:	25800613          	li	a2,600
    2002:	85ca                	mv	a1,s2
    2004:	854e                	mv	a0,s3
    2006:	00002097          	auipc	ra,0x2
    200a:	3bc080e7          	jalr	956(ra) # 43c2 <write>
    200e:	25800793          	li	a5,600
    2012:	08f51a63          	bne	a0,a5,20a6 <bigfile+0x102>
  for(i = 0; i < N; i++){
    2016:	2485                	addiw	s1,s1,1
    2018:	fd449be3          	bne	s1,s4,1fee <bigfile+0x4a>
  close(fd);
    201c:	854e                	mv	a0,s3
    201e:	00002097          	auipc	ra,0x2
    2022:	3ac080e7          	jalr	940(ra) # 43ca <close>
  fd = open("bigfile", 0);
    2026:	4581                	li	a1,0
    2028:	00003517          	auipc	a0,0x3
    202c:	af850513          	addi	a0,a0,-1288 # 4b20 <malloc+0x328>
    2030:	00002097          	auipc	ra,0x2
    2034:	3b2080e7          	jalr	946(ra) # 43e2 <open>
    2038:	8a2a                	mv	s4,a0
  total = 0;
    203a:	4981                	li	s3,0
  for(i = 0; ; i++){
    203c:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    203e:	00007917          	auipc	s2,0x7
    2042:	14290913          	addi	s2,s2,322 # 9180 <buf>
  if(fd < 0){
    2046:	06054e63          	bltz	a0,20c2 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    204a:	12c00613          	li	a2,300
    204e:	85ca                	mv	a1,s2
    2050:	8552                	mv	a0,s4
    2052:	00002097          	auipc	ra,0x2
    2056:	368080e7          	jalr	872(ra) # 43ba <read>
    if(cc < 0){
    205a:	08054263          	bltz	a0,20de <bigfile+0x13a>
    if(cc == 0)
    205e:	c971                	beqz	a0,2132 <bigfile+0x18e>
    if(cc != SZ/2){
    2060:	12c00793          	li	a5,300
    2064:	08f51b63          	bne	a0,a5,20fa <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    2068:	01f4d79b          	srliw	a5,s1,0x1f
    206c:	9fa5                	addw	a5,a5,s1
    206e:	4017d79b          	sraiw	a5,a5,0x1
    2072:	00094703          	lbu	a4,0(s2)
    2076:	0af71063          	bne	a4,a5,2116 <bigfile+0x172>
    207a:	12b94703          	lbu	a4,299(s2)
    207e:	08f71c63          	bne	a4,a5,2116 <bigfile+0x172>
    total += cc;
    2082:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    2086:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    2088:	b7c9                	j	204a <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    208a:	85d6                	mv	a1,s5
    208c:	00003517          	auipc	a0,0x3
    2090:	73450513          	addi	a0,a0,1844 # 57c0 <malloc+0xfc8>
    2094:	00002097          	auipc	ra,0x2
    2098:	6a6080e7          	jalr	1702(ra) # 473a <printf>
    exit(1);
    209c:	4505                	li	a0,1
    209e:	00002097          	auipc	ra,0x2
    20a2:	304080e7          	jalr	772(ra) # 43a2 <exit>
      printf("%s: write bigfile failed\n", s);
    20a6:	85d6                	mv	a1,s5
    20a8:	00003517          	auipc	a0,0x3
    20ac:	73850513          	addi	a0,a0,1848 # 57e0 <malloc+0xfe8>
    20b0:	00002097          	auipc	ra,0x2
    20b4:	68a080e7          	jalr	1674(ra) # 473a <printf>
      exit(1);
    20b8:	4505                	li	a0,1
    20ba:	00002097          	auipc	ra,0x2
    20be:	2e8080e7          	jalr	744(ra) # 43a2 <exit>
    printf("%s: cannot open bigfile\n", s);
    20c2:	85d6                	mv	a1,s5
    20c4:	00003517          	auipc	a0,0x3
    20c8:	73c50513          	addi	a0,a0,1852 # 5800 <malloc+0x1008>
    20cc:	00002097          	auipc	ra,0x2
    20d0:	66e080e7          	jalr	1646(ra) # 473a <printf>
    exit(1);
    20d4:	4505                	li	a0,1
    20d6:	00002097          	auipc	ra,0x2
    20da:	2cc080e7          	jalr	716(ra) # 43a2 <exit>
      printf("%s: read bigfile failed\n", s);
    20de:	85d6                	mv	a1,s5
    20e0:	00003517          	auipc	a0,0x3
    20e4:	74050513          	addi	a0,a0,1856 # 5820 <malloc+0x1028>
    20e8:	00002097          	auipc	ra,0x2
    20ec:	652080e7          	jalr	1618(ra) # 473a <printf>
      exit(1);
    20f0:	4505                	li	a0,1
    20f2:	00002097          	auipc	ra,0x2
    20f6:	2b0080e7          	jalr	688(ra) # 43a2 <exit>
      printf("%s: short read bigfile\n", s);
    20fa:	85d6                	mv	a1,s5
    20fc:	00003517          	auipc	a0,0x3
    2100:	74450513          	addi	a0,a0,1860 # 5840 <malloc+0x1048>
    2104:	00002097          	auipc	ra,0x2
    2108:	636080e7          	jalr	1590(ra) # 473a <printf>
      exit(1);
    210c:	4505                	li	a0,1
    210e:	00002097          	auipc	ra,0x2
    2112:	294080e7          	jalr	660(ra) # 43a2 <exit>
      printf("%s: read bigfile wrong data\n", s);
    2116:	85d6                	mv	a1,s5
    2118:	00003517          	auipc	a0,0x3
    211c:	74050513          	addi	a0,a0,1856 # 5858 <malloc+0x1060>
    2120:	00002097          	auipc	ra,0x2
    2124:	61a080e7          	jalr	1562(ra) # 473a <printf>
      exit(1);
    2128:	4505                	li	a0,1
    212a:	00002097          	auipc	ra,0x2
    212e:	278080e7          	jalr	632(ra) # 43a2 <exit>
  close(fd);
    2132:	8552                	mv	a0,s4
    2134:	00002097          	auipc	ra,0x2
    2138:	296080e7          	jalr	662(ra) # 43ca <close>
  if(total != N*SZ){
    213c:	678d                	lui	a5,0x3
    213e:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x598>
    2142:	02f99363          	bne	s3,a5,2168 <bigfile+0x1c4>
  unlink("bigfile");
    2146:	00003517          	auipc	a0,0x3
    214a:	9da50513          	addi	a0,a0,-1574 # 4b20 <malloc+0x328>
    214e:	00002097          	auipc	ra,0x2
    2152:	2a4080e7          	jalr	676(ra) # 43f2 <unlink>
}
    2156:	70e2                	ld	ra,56(sp)
    2158:	7442                	ld	s0,48(sp)
    215a:	74a2                	ld	s1,40(sp)
    215c:	7902                	ld	s2,32(sp)
    215e:	69e2                	ld	s3,24(sp)
    2160:	6a42                	ld	s4,16(sp)
    2162:	6aa2                	ld	s5,8(sp)
    2164:	6121                	addi	sp,sp,64
    2166:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    2168:	85d6                	mv	a1,s5
    216a:	00003517          	auipc	a0,0x3
    216e:	70e50513          	addi	a0,a0,1806 # 5878 <malloc+0x1080>
    2172:	00002097          	auipc	ra,0x2
    2176:	5c8080e7          	jalr	1480(ra) # 473a <printf>
    exit(1);
    217a:	4505                	li	a0,1
    217c:	00002097          	auipc	ra,0x2
    2180:	226080e7          	jalr	550(ra) # 43a2 <exit>

0000000000002184 <linktest>:
{
    2184:	1101                	addi	sp,sp,-32
    2186:	ec06                	sd	ra,24(sp)
    2188:	e822                	sd	s0,16(sp)
    218a:	e426                	sd	s1,8(sp)
    218c:	e04a                	sd	s2,0(sp)
    218e:	1000                	addi	s0,sp,32
    2190:	892a                	mv	s2,a0
  unlink("lf1");
    2192:	00003517          	auipc	a0,0x3
    2196:	70650513          	addi	a0,a0,1798 # 5898 <malloc+0x10a0>
    219a:	00002097          	auipc	ra,0x2
    219e:	258080e7          	jalr	600(ra) # 43f2 <unlink>
  unlink("lf2");
    21a2:	00003517          	auipc	a0,0x3
    21a6:	6fe50513          	addi	a0,a0,1790 # 58a0 <malloc+0x10a8>
    21aa:	00002097          	auipc	ra,0x2
    21ae:	248080e7          	jalr	584(ra) # 43f2 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
    21b2:	20200593          	li	a1,514
    21b6:	00003517          	auipc	a0,0x3
    21ba:	6e250513          	addi	a0,a0,1762 # 5898 <malloc+0x10a0>
    21be:	00002097          	auipc	ra,0x2
    21c2:	224080e7          	jalr	548(ra) # 43e2 <open>
  if(fd < 0){
    21c6:	10054763          	bltz	a0,22d4 <linktest+0x150>
    21ca:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
    21cc:	4615                	li	a2,5
    21ce:	00003597          	auipc	a1,0x3
    21d2:	1e258593          	addi	a1,a1,482 # 53b0 <malloc+0xbb8>
    21d6:	00002097          	auipc	ra,0x2
    21da:	1ec080e7          	jalr	492(ra) # 43c2 <write>
    21de:	4795                	li	a5,5
    21e0:	10f51863          	bne	a0,a5,22f0 <linktest+0x16c>
  close(fd);
    21e4:	8526                	mv	a0,s1
    21e6:	00002097          	auipc	ra,0x2
    21ea:	1e4080e7          	jalr	484(ra) # 43ca <close>
  if(link("lf1", "lf2") < 0){
    21ee:	00003597          	auipc	a1,0x3
    21f2:	6b258593          	addi	a1,a1,1714 # 58a0 <malloc+0x10a8>
    21f6:	00003517          	auipc	a0,0x3
    21fa:	6a250513          	addi	a0,a0,1698 # 5898 <malloc+0x10a0>
    21fe:	00002097          	auipc	ra,0x2
    2202:	204080e7          	jalr	516(ra) # 4402 <link>
    2206:	10054363          	bltz	a0,230c <linktest+0x188>
  unlink("lf1");
    220a:	00003517          	auipc	a0,0x3
    220e:	68e50513          	addi	a0,a0,1678 # 5898 <malloc+0x10a0>
    2212:	00002097          	auipc	ra,0x2
    2216:	1e0080e7          	jalr	480(ra) # 43f2 <unlink>
  if(open("lf1", 0) >= 0){
    221a:	4581                	li	a1,0
    221c:	00003517          	auipc	a0,0x3
    2220:	67c50513          	addi	a0,a0,1660 # 5898 <malloc+0x10a0>
    2224:	00002097          	auipc	ra,0x2
    2228:	1be080e7          	jalr	446(ra) # 43e2 <open>
    222c:	0e055e63          	bgez	a0,2328 <linktest+0x1a4>
  fd = open("lf2", 0);
    2230:	4581                	li	a1,0
    2232:	00003517          	auipc	a0,0x3
    2236:	66e50513          	addi	a0,a0,1646 # 58a0 <malloc+0x10a8>
    223a:	00002097          	auipc	ra,0x2
    223e:	1a8080e7          	jalr	424(ra) # 43e2 <open>
    2242:	84aa                	mv	s1,a0
  if(fd < 0){
    2244:	10054063          	bltz	a0,2344 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
    2248:	660d                	lui	a2,0x3
    224a:	00007597          	auipc	a1,0x7
    224e:	f3658593          	addi	a1,a1,-202 # 9180 <buf>
    2252:	00002097          	auipc	ra,0x2
    2256:	168080e7          	jalr	360(ra) # 43ba <read>
    225a:	4795                	li	a5,5
    225c:	10f51263          	bne	a0,a5,2360 <linktest+0x1dc>
  close(fd);
    2260:	8526                	mv	a0,s1
    2262:	00002097          	auipc	ra,0x2
    2266:	168080e7          	jalr	360(ra) # 43ca <close>
  if(link("lf2", "lf2") >= 0){
    226a:	00003597          	auipc	a1,0x3
    226e:	63658593          	addi	a1,a1,1590 # 58a0 <malloc+0x10a8>
    2272:	852e                	mv	a0,a1
    2274:	00002097          	auipc	ra,0x2
    2278:	18e080e7          	jalr	398(ra) # 4402 <link>
    227c:	10055063          	bgez	a0,237c <linktest+0x1f8>
  unlink("lf2");
    2280:	00003517          	auipc	a0,0x3
    2284:	62050513          	addi	a0,a0,1568 # 58a0 <malloc+0x10a8>
    2288:	00002097          	auipc	ra,0x2
    228c:	16a080e7          	jalr	362(ra) # 43f2 <unlink>
  if(link("lf2", "lf1") >= 0){
    2290:	00003597          	auipc	a1,0x3
    2294:	60858593          	addi	a1,a1,1544 # 5898 <malloc+0x10a0>
    2298:	00003517          	auipc	a0,0x3
    229c:	60850513          	addi	a0,a0,1544 # 58a0 <malloc+0x10a8>
    22a0:	00002097          	auipc	ra,0x2
    22a4:	162080e7          	jalr	354(ra) # 4402 <link>
    22a8:	0e055863          	bgez	a0,2398 <linktest+0x214>
  if(link(".", "lf1") >= 0){
    22ac:	00003597          	auipc	a1,0x3
    22b0:	5ec58593          	addi	a1,a1,1516 # 5898 <malloc+0x10a0>
    22b4:	00003517          	auipc	a0,0x3
    22b8:	97c50513          	addi	a0,a0,-1668 # 4c30 <malloc+0x438>
    22bc:	00002097          	auipc	ra,0x2
    22c0:	146080e7          	jalr	326(ra) # 4402 <link>
    22c4:	0e055863          	bgez	a0,23b4 <linktest+0x230>
}
    22c8:	60e2                	ld	ra,24(sp)
    22ca:	6442                	ld	s0,16(sp)
    22cc:	64a2                	ld	s1,8(sp)
    22ce:	6902                	ld	s2,0(sp)
    22d0:	6105                	addi	sp,sp,32
    22d2:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    22d4:	85ca                	mv	a1,s2
    22d6:	00003517          	auipc	a0,0x3
    22da:	5d250513          	addi	a0,a0,1490 # 58a8 <malloc+0x10b0>
    22de:	00002097          	auipc	ra,0x2
    22e2:	45c080e7          	jalr	1116(ra) # 473a <printf>
    exit(1);
    22e6:	4505                	li	a0,1
    22e8:	00002097          	auipc	ra,0x2
    22ec:	0ba080e7          	jalr	186(ra) # 43a2 <exit>
    printf("%s: write lf1 failed\n", s);
    22f0:	85ca                	mv	a1,s2
    22f2:	00003517          	auipc	a0,0x3
    22f6:	5ce50513          	addi	a0,a0,1486 # 58c0 <malloc+0x10c8>
    22fa:	00002097          	auipc	ra,0x2
    22fe:	440080e7          	jalr	1088(ra) # 473a <printf>
    exit(1);
    2302:	4505                	li	a0,1
    2304:	00002097          	auipc	ra,0x2
    2308:	09e080e7          	jalr	158(ra) # 43a2 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    230c:	85ca                	mv	a1,s2
    230e:	00003517          	auipc	a0,0x3
    2312:	5ca50513          	addi	a0,a0,1482 # 58d8 <malloc+0x10e0>
    2316:	00002097          	auipc	ra,0x2
    231a:	424080e7          	jalr	1060(ra) # 473a <printf>
    exit(1);
    231e:	4505                	li	a0,1
    2320:	00002097          	auipc	ra,0x2
    2324:	082080e7          	jalr	130(ra) # 43a2 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    2328:	85ca                	mv	a1,s2
    232a:	00003517          	auipc	a0,0x3
    232e:	5ce50513          	addi	a0,a0,1486 # 58f8 <malloc+0x1100>
    2332:	00002097          	auipc	ra,0x2
    2336:	408080e7          	jalr	1032(ra) # 473a <printf>
    exit(1);
    233a:	4505                	li	a0,1
    233c:	00002097          	auipc	ra,0x2
    2340:	066080e7          	jalr	102(ra) # 43a2 <exit>
    printf("%s: open lf2 failed\n", s);
    2344:	85ca                	mv	a1,s2
    2346:	00003517          	auipc	a0,0x3
    234a:	5e250513          	addi	a0,a0,1506 # 5928 <malloc+0x1130>
    234e:	00002097          	auipc	ra,0x2
    2352:	3ec080e7          	jalr	1004(ra) # 473a <printf>
    exit(1);
    2356:	4505                	li	a0,1
    2358:	00002097          	auipc	ra,0x2
    235c:	04a080e7          	jalr	74(ra) # 43a2 <exit>
    printf("%s: read lf2 failed\n", s);
    2360:	85ca                	mv	a1,s2
    2362:	00003517          	auipc	a0,0x3
    2366:	5de50513          	addi	a0,a0,1502 # 5940 <malloc+0x1148>
    236a:	00002097          	auipc	ra,0x2
    236e:	3d0080e7          	jalr	976(ra) # 473a <printf>
    exit(1);
    2372:	4505                	li	a0,1
    2374:	00002097          	auipc	ra,0x2
    2378:	02e080e7          	jalr	46(ra) # 43a2 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    237c:	85ca                	mv	a1,s2
    237e:	00003517          	auipc	a0,0x3
    2382:	5da50513          	addi	a0,a0,1498 # 5958 <malloc+0x1160>
    2386:	00002097          	auipc	ra,0x2
    238a:	3b4080e7          	jalr	948(ra) # 473a <printf>
    exit(1);
    238e:	4505                	li	a0,1
    2390:	00002097          	auipc	ra,0x2
    2394:	012080e7          	jalr	18(ra) # 43a2 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
    2398:	85ca                	mv	a1,s2
    239a:	00003517          	auipc	a0,0x3
    239e:	5e650513          	addi	a0,a0,1510 # 5980 <malloc+0x1188>
    23a2:	00002097          	auipc	ra,0x2
    23a6:	398080e7          	jalr	920(ra) # 473a <printf>
    exit(1);
    23aa:	4505                	li	a0,1
    23ac:	00002097          	auipc	ra,0x2
    23b0:	ff6080e7          	jalr	-10(ra) # 43a2 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    23b4:	85ca                	mv	a1,s2
    23b6:	00003517          	auipc	a0,0x3
    23ba:	5f250513          	addi	a0,a0,1522 # 59a8 <malloc+0x11b0>
    23be:	00002097          	auipc	ra,0x2
    23c2:	37c080e7          	jalr	892(ra) # 473a <printf>
    exit(1);
    23c6:	4505                	li	a0,1
    23c8:	00002097          	auipc	ra,0x2
    23cc:	fda080e7          	jalr	-38(ra) # 43a2 <exit>

00000000000023d0 <concreate>:
{
    23d0:	7135                	addi	sp,sp,-160
    23d2:	ed06                	sd	ra,152(sp)
    23d4:	e922                	sd	s0,144(sp)
    23d6:	e526                	sd	s1,136(sp)
    23d8:	e14a                	sd	s2,128(sp)
    23da:	fcce                	sd	s3,120(sp)
    23dc:	f8d2                	sd	s4,112(sp)
    23de:	f4d6                	sd	s5,104(sp)
    23e0:	f0da                	sd	s6,96(sp)
    23e2:	ecde                	sd	s7,88(sp)
    23e4:	1100                	addi	s0,sp,160
    23e6:	89aa                	mv	s3,a0
  file[0] = 'C';
    23e8:	04300793          	li	a5,67
    23ec:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    23f0:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    23f4:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    23f6:	4b0d                	li	s6,3
    23f8:	4a85                	li	s5,1
      link("C0", file);
    23fa:	00003b97          	auipc	s7,0x3
    23fe:	5ceb8b93          	addi	s7,s7,1486 # 59c8 <malloc+0x11d0>
  for(i = 0; i < N; i++){
    2402:	02800a13          	li	s4,40
    2406:	a471                	j	2692 <concreate+0x2c2>
      link("C0", file);
    2408:	fa840593          	addi	a1,s0,-88
    240c:	855e                	mv	a0,s7
    240e:	00002097          	auipc	ra,0x2
    2412:	ff4080e7          	jalr	-12(ra) # 4402 <link>
    if(pid == 0) {
    2416:	a48d                	j	2678 <concreate+0x2a8>
    } else if(pid == 0 && (i % 5) == 1){
    2418:	4795                	li	a5,5
    241a:	02f9693b          	remw	s2,s2,a5
    241e:	4785                	li	a5,1
    2420:	02f90b63          	beq	s2,a5,2456 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    2424:	20200593          	li	a1,514
    2428:	fa840513          	addi	a0,s0,-88
    242c:	00002097          	auipc	ra,0x2
    2430:	fb6080e7          	jalr	-74(ra) # 43e2 <open>
      if(fd < 0){
    2434:	22055963          	bgez	a0,2666 <concreate+0x296>
        printf("concreate create %s failed\n", file);
    2438:	fa840593          	addi	a1,s0,-88
    243c:	00003517          	auipc	a0,0x3
    2440:	59450513          	addi	a0,a0,1428 # 59d0 <malloc+0x11d8>
    2444:	00002097          	auipc	ra,0x2
    2448:	2f6080e7          	jalr	758(ra) # 473a <printf>
        exit(1);
    244c:	4505                	li	a0,1
    244e:	00002097          	auipc	ra,0x2
    2452:	f54080e7          	jalr	-172(ra) # 43a2 <exit>
      link("C0", file);
    2456:	fa840593          	addi	a1,s0,-88
    245a:	00003517          	auipc	a0,0x3
    245e:	56e50513          	addi	a0,a0,1390 # 59c8 <malloc+0x11d0>
    2462:	00002097          	auipc	ra,0x2
    2466:	fa0080e7          	jalr	-96(ra) # 4402 <link>
      exit(0);
    246a:	4501                	li	a0,0
    246c:	00002097          	auipc	ra,0x2
    2470:	f36080e7          	jalr	-202(ra) # 43a2 <exit>
        exit(1);
    2474:	4505                	li	a0,1
    2476:	00002097          	auipc	ra,0x2
    247a:	f2c080e7          	jalr	-212(ra) # 43a2 <exit>
  memset(fa, 0, sizeof(fa));
    247e:	02800613          	li	a2,40
    2482:	4581                	li	a1,0
    2484:	f8040513          	addi	a0,s0,-128
    2488:	00002097          	auipc	ra,0x2
    248c:	d9e080e7          	jalr	-610(ra) # 4226 <memset>
  fd = open(".", 0);
    2490:	4581                	li	a1,0
    2492:	00002517          	auipc	a0,0x2
    2496:	79e50513          	addi	a0,a0,1950 # 4c30 <malloc+0x438>
    249a:	00002097          	auipc	ra,0x2
    249e:	f48080e7          	jalr	-184(ra) # 43e2 <open>
    24a2:	892a                	mv	s2,a0
  n = 0;
    24a4:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    24a6:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    24aa:	02700b13          	li	s6,39
      fa[i] = 1;
    24ae:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    24b0:	4641                	li	a2,16
    24b2:	f7040593          	addi	a1,s0,-144
    24b6:	854a                	mv	a0,s2
    24b8:	00002097          	auipc	ra,0x2
    24bc:	f02080e7          	jalr	-254(ra) # 43ba <read>
    24c0:	08a05163          	blez	a0,2542 <concreate+0x172>
    if(de.inum == 0)
    24c4:	f7045783          	lhu	a5,-144(s0)
    24c8:	d7e5                	beqz	a5,24b0 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    24ca:	f7244783          	lbu	a5,-142(s0)
    24ce:	ff4791e3          	bne	a5,s4,24b0 <concreate+0xe0>
    24d2:	f7444783          	lbu	a5,-140(s0)
    24d6:	ffe9                	bnez	a5,24b0 <concreate+0xe0>
      i = de.name[1] - '0';
    24d8:	f7344783          	lbu	a5,-141(s0)
    24dc:	fd07879b          	addiw	a5,a5,-48
    24e0:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    24e4:	00eb6f63          	bltu	s6,a4,2502 <concreate+0x132>
      if(fa[i]){
    24e8:	fb040793          	addi	a5,s0,-80
    24ec:	97ba                	add	a5,a5,a4
    24ee:	fd07c783          	lbu	a5,-48(a5)
    24f2:	eb85                	bnez	a5,2522 <concreate+0x152>
      fa[i] = 1;
    24f4:	fb040793          	addi	a5,s0,-80
    24f8:	973e                	add	a4,a4,a5
    24fa:	fd770823          	sb	s7,-48(a4)
      n++;
    24fe:	2a85                	addiw	s5,s5,1
    2500:	bf45                	j	24b0 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    2502:	f7240613          	addi	a2,s0,-142
    2506:	85ce                	mv	a1,s3
    2508:	00003517          	auipc	a0,0x3
    250c:	4e850513          	addi	a0,a0,1256 # 59f0 <malloc+0x11f8>
    2510:	00002097          	auipc	ra,0x2
    2514:	22a080e7          	jalr	554(ra) # 473a <printf>
        exit(1);
    2518:	4505                	li	a0,1
    251a:	00002097          	auipc	ra,0x2
    251e:	e88080e7          	jalr	-376(ra) # 43a2 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    2522:	f7240613          	addi	a2,s0,-142
    2526:	85ce                	mv	a1,s3
    2528:	00003517          	auipc	a0,0x3
    252c:	4e850513          	addi	a0,a0,1256 # 5a10 <malloc+0x1218>
    2530:	00002097          	auipc	ra,0x2
    2534:	20a080e7          	jalr	522(ra) # 473a <printf>
        exit(1);
    2538:	4505                	li	a0,1
    253a:	00002097          	auipc	ra,0x2
    253e:	e68080e7          	jalr	-408(ra) # 43a2 <exit>
  close(fd);
    2542:	854a                	mv	a0,s2
    2544:	00002097          	auipc	ra,0x2
    2548:	e86080e7          	jalr	-378(ra) # 43ca <close>
  if(n != N){
    254c:	02800793          	li	a5,40
    2550:	00fa9763          	bne	s5,a5,255e <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    2554:	4a8d                	li	s5,3
    2556:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    2558:	02800a13          	li	s4,40
    255c:	a05d                	j	2602 <concreate+0x232>
    printf("%s: concreate not enough files in directory listing\n", s);
    255e:	85ce                	mv	a1,s3
    2560:	00003517          	auipc	a0,0x3
    2564:	4d850513          	addi	a0,a0,1240 # 5a38 <malloc+0x1240>
    2568:	00002097          	auipc	ra,0x2
    256c:	1d2080e7          	jalr	466(ra) # 473a <printf>
    exit(1);
    2570:	4505                	li	a0,1
    2572:	00002097          	auipc	ra,0x2
    2576:	e30080e7          	jalr	-464(ra) # 43a2 <exit>
      printf("%s: fork failed\n", s);
    257a:	85ce                	mv	a1,s3
    257c:	00002517          	auipc	a0,0x2
    2580:	76450513          	addi	a0,a0,1892 # 4ce0 <malloc+0x4e8>
    2584:	00002097          	auipc	ra,0x2
    2588:	1b6080e7          	jalr	438(ra) # 473a <printf>
      exit(1);
    258c:	4505                	li	a0,1
    258e:	00002097          	auipc	ra,0x2
    2592:	e14080e7          	jalr	-492(ra) # 43a2 <exit>
      close(open(file, 0));
    2596:	4581                	li	a1,0
    2598:	fa840513          	addi	a0,s0,-88
    259c:	00002097          	auipc	ra,0x2
    25a0:	e46080e7          	jalr	-442(ra) # 43e2 <open>
    25a4:	00002097          	auipc	ra,0x2
    25a8:	e26080e7          	jalr	-474(ra) # 43ca <close>
      close(open(file, 0));
    25ac:	4581                	li	a1,0
    25ae:	fa840513          	addi	a0,s0,-88
    25b2:	00002097          	auipc	ra,0x2
    25b6:	e30080e7          	jalr	-464(ra) # 43e2 <open>
    25ba:	00002097          	auipc	ra,0x2
    25be:	e10080e7          	jalr	-496(ra) # 43ca <close>
      close(open(file, 0));
    25c2:	4581                	li	a1,0
    25c4:	fa840513          	addi	a0,s0,-88
    25c8:	00002097          	auipc	ra,0x2
    25cc:	e1a080e7          	jalr	-486(ra) # 43e2 <open>
    25d0:	00002097          	auipc	ra,0x2
    25d4:	dfa080e7          	jalr	-518(ra) # 43ca <close>
      close(open(file, 0));
    25d8:	4581                	li	a1,0
    25da:	fa840513          	addi	a0,s0,-88
    25de:	00002097          	auipc	ra,0x2
    25e2:	e04080e7          	jalr	-508(ra) # 43e2 <open>
    25e6:	00002097          	auipc	ra,0x2
    25ea:	de4080e7          	jalr	-540(ra) # 43ca <close>
    if(pid == 0)
    25ee:	06090763          	beqz	s2,265c <concreate+0x28c>
      wait(0);
    25f2:	4501                	li	a0,0
    25f4:	00002097          	auipc	ra,0x2
    25f8:	db6080e7          	jalr	-586(ra) # 43aa <wait>
  for(i = 0; i < N; i++){
    25fc:	2485                	addiw	s1,s1,1
    25fe:	0d448963          	beq	s1,s4,26d0 <concreate+0x300>
    file[1] = '0' + i;
    2602:	0304879b          	addiw	a5,s1,48
    2606:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    260a:	00002097          	auipc	ra,0x2
    260e:	d90080e7          	jalr	-624(ra) # 439a <fork>
    2612:	892a                	mv	s2,a0
    if(pid < 0){
    2614:	f60543e3          	bltz	a0,257a <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    2618:	0354e73b          	remw	a4,s1,s5
    261c:	00a767b3          	or	a5,a4,a0
    2620:	2781                	sext.w	a5,a5
    2622:	dbb5                	beqz	a5,2596 <concreate+0x1c6>
    2624:	01671363          	bne	a4,s6,262a <concreate+0x25a>
       ((i % 3) == 1 && pid != 0)){
    2628:	f53d                	bnez	a0,2596 <concreate+0x1c6>
      unlink(file);
    262a:	fa840513          	addi	a0,s0,-88
    262e:	00002097          	auipc	ra,0x2
    2632:	dc4080e7          	jalr	-572(ra) # 43f2 <unlink>
      unlink(file);
    2636:	fa840513          	addi	a0,s0,-88
    263a:	00002097          	auipc	ra,0x2
    263e:	db8080e7          	jalr	-584(ra) # 43f2 <unlink>
      unlink(file);
    2642:	fa840513          	addi	a0,s0,-88
    2646:	00002097          	auipc	ra,0x2
    264a:	dac080e7          	jalr	-596(ra) # 43f2 <unlink>
      unlink(file);
    264e:	fa840513          	addi	a0,s0,-88
    2652:	00002097          	auipc	ra,0x2
    2656:	da0080e7          	jalr	-608(ra) # 43f2 <unlink>
    265a:	bf51                	j	25ee <concreate+0x21e>
      exit(0);
    265c:	4501                	li	a0,0
    265e:	00002097          	auipc	ra,0x2
    2662:	d44080e7          	jalr	-700(ra) # 43a2 <exit>
      close(fd);
    2666:	00002097          	auipc	ra,0x2
    266a:	d64080e7          	jalr	-668(ra) # 43ca <close>
    if(pid == 0) {
    266e:	bbf5                	j	246a <concreate+0x9a>
      close(fd);
    2670:	00002097          	auipc	ra,0x2
    2674:	d5a080e7          	jalr	-678(ra) # 43ca <close>
      wait(&xstatus);
    2678:	f6c40513          	addi	a0,s0,-148
    267c:	00002097          	auipc	ra,0x2
    2680:	d2e080e7          	jalr	-722(ra) # 43aa <wait>
      if(xstatus != 0)
    2684:	f6c42483          	lw	s1,-148(s0)
    2688:	de0496e3          	bnez	s1,2474 <concreate+0xa4>
  for(i = 0; i < N; i++){
    268c:	2905                	addiw	s2,s2,1
    268e:	df4908e3          	beq	s2,s4,247e <concreate+0xae>
    file[1] = '0' + i;
    2692:	0309079b          	addiw	a5,s2,48
    2696:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    269a:	fa840513          	addi	a0,s0,-88
    269e:	00002097          	auipc	ra,0x2
    26a2:	d54080e7          	jalr	-684(ra) # 43f2 <unlink>
    pid = fork();
    26a6:	00002097          	auipc	ra,0x2
    26aa:	cf4080e7          	jalr	-780(ra) # 439a <fork>
    if(pid && (i % 3) == 1){
    26ae:	d60505e3          	beqz	a0,2418 <concreate+0x48>
    26b2:	036967bb          	remw	a5,s2,s6
    26b6:	d55789e3          	beq	a5,s5,2408 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    26ba:	20200593          	li	a1,514
    26be:	fa840513          	addi	a0,s0,-88
    26c2:	00002097          	auipc	ra,0x2
    26c6:	d20080e7          	jalr	-736(ra) # 43e2 <open>
      if(fd < 0){
    26ca:	fa0553e3          	bgez	a0,2670 <concreate+0x2a0>
    26ce:	b3ad                	j	2438 <concreate+0x68>
}
    26d0:	60ea                	ld	ra,152(sp)
    26d2:	644a                	ld	s0,144(sp)
    26d4:	64aa                	ld	s1,136(sp)
    26d6:	690a                	ld	s2,128(sp)
    26d8:	79e6                	ld	s3,120(sp)
    26da:	7a46                	ld	s4,112(sp)
    26dc:	7aa6                	ld	s5,104(sp)
    26de:	7b06                	ld	s6,96(sp)
    26e0:	6be6                	ld	s7,88(sp)
    26e2:	610d                	addi	sp,sp,160
    26e4:	8082                	ret

00000000000026e6 <linkunlink>:
{
    26e6:	711d                	addi	sp,sp,-96
    26e8:	ec86                	sd	ra,88(sp)
    26ea:	e8a2                	sd	s0,80(sp)
    26ec:	e4a6                	sd	s1,72(sp)
    26ee:	e0ca                	sd	s2,64(sp)
    26f0:	fc4e                	sd	s3,56(sp)
    26f2:	f852                	sd	s4,48(sp)
    26f4:	f456                	sd	s5,40(sp)
    26f6:	f05a                	sd	s6,32(sp)
    26f8:	ec5e                	sd	s7,24(sp)
    26fa:	e862                	sd	s8,16(sp)
    26fc:	e466                	sd	s9,8(sp)
    26fe:	1080                	addi	s0,sp,96
    2700:	84aa                	mv	s1,a0
  unlink("x");
    2702:	00003517          	auipc	a0,0x3
    2706:	f8e50513          	addi	a0,a0,-114 # 5690 <malloc+0xe98>
    270a:	00002097          	auipc	ra,0x2
    270e:	ce8080e7          	jalr	-792(ra) # 43f2 <unlink>
  pid = fork();
    2712:	00002097          	auipc	ra,0x2
    2716:	c88080e7          	jalr	-888(ra) # 439a <fork>
  if(pid < 0){
    271a:	02054b63          	bltz	a0,2750 <linkunlink+0x6a>
    271e:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    2720:	4c85                	li	s9,1
    2722:	e119                	bnez	a0,2728 <linkunlink+0x42>
    2724:	06100c93          	li	s9,97
    2728:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    272c:	41c659b7          	lui	s3,0x41c65
    2730:	e6d9899b          	addiw	s3,s3,-403
    2734:	690d                	lui	s2,0x3
    2736:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    273a:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    273c:	4b05                	li	s6,1
      unlink("x");
    273e:	00003a97          	auipc	s5,0x3
    2742:	f52a8a93          	addi	s5,s5,-174 # 5690 <malloc+0xe98>
      link("cat", "x");
    2746:	00003b97          	auipc	s7,0x3
    274a:	32ab8b93          	addi	s7,s7,810 # 5a70 <malloc+0x1278>
    274e:	a825                	j	2786 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    2750:	85a6                	mv	a1,s1
    2752:	00002517          	auipc	a0,0x2
    2756:	58e50513          	addi	a0,a0,1422 # 4ce0 <malloc+0x4e8>
    275a:	00002097          	auipc	ra,0x2
    275e:	fe0080e7          	jalr	-32(ra) # 473a <printf>
    exit(1);
    2762:	4505                	li	a0,1
    2764:	00002097          	auipc	ra,0x2
    2768:	c3e080e7          	jalr	-962(ra) # 43a2 <exit>
      close(open("x", O_RDWR | O_CREATE));
    276c:	20200593          	li	a1,514
    2770:	8556                	mv	a0,s5
    2772:	00002097          	auipc	ra,0x2
    2776:	c70080e7          	jalr	-912(ra) # 43e2 <open>
    277a:	00002097          	auipc	ra,0x2
    277e:	c50080e7          	jalr	-944(ra) # 43ca <close>
  for(i = 0; i < 100; i++){
    2782:	34fd                	addiw	s1,s1,-1
    2784:	c88d                	beqz	s1,27b6 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    2786:	033c87bb          	mulw	a5,s9,s3
    278a:	012787bb          	addw	a5,a5,s2
    278e:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    2792:	0347f7bb          	remuw	a5,a5,s4
    2796:	dbf9                	beqz	a5,276c <linkunlink+0x86>
    } else if((x % 3) == 1){
    2798:	01678863          	beq	a5,s6,27a8 <linkunlink+0xc2>
      unlink("x");
    279c:	8556                	mv	a0,s5
    279e:	00002097          	auipc	ra,0x2
    27a2:	c54080e7          	jalr	-940(ra) # 43f2 <unlink>
    27a6:	bff1                	j	2782 <linkunlink+0x9c>
      link("cat", "x");
    27a8:	85d6                	mv	a1,s5
    27aa:	855e                	mv	a0,s7
    27ac:	00002097          	auipc	ra,0x2
    27b0:	c56080e7          	jalr	-938(ra) # 4402 <link>
    27b4:	b7f9                	j	2782 <linkunlink+0x9c>
  if(pid)
    27b6:	020c0463          	beqz	s8,27de <linkunlink+0xf8>
    wait(0);
    27ba:	4501                	li	a0,0
    27bc:	00002097          	auipc	ra,0x2
    27c0:	bee080e7          	jalr	-1042(ra) # 43aa <wait>
}
    27c4:	60e6                	ld	ra,88(sp)
    27c6:	6446                	ld	s0,80(sp)
    27c8:	64a6                	ld	s1,72(sp)
    27ca:	6906                	ld	s2,64(sp)
    27cc:	79e2                	ld	s3,56(sp)
    27ce:	7a42                	ld	s4,48(sp)
    27d0:	7aa2                	ld	s5,40(sp)
    27d2:	7b02                	ld	s6,32(sp)
    27d4:	6be2                	ld	s7,24(sp)
    27d6:	6c42                	ld	s8,16(sp)
    27d8:	6ca2                	ld	s9,8(sp)
    27da:	6125                	addi	sp,sp,96
    27dc:	8082                	ret
    exit(0);
    27de:	4501                	li	a0,0
    27e0:	00002097          	auipc	ra,0x2
    27e4:	bc2080e7          	jalr	-1086(ra) # 43a2 <exit>

00000000000027e8 <bigdir>:
{
    27e8:	715d                	addi	sp,sp,-80
    27ea:	e486                	sd	ra,72(sp)
    27ec:	e0a2                	sd	s0,64(sp)
    27ee:	fc26                	sd	s1,56(sp)
    27f0:	f84a                	sd	s2,48(sp)
    27f2:	f44e                	sd	s3,40(sp)
    27f4:	f052                	sd	s4,32(sp)
    27f6:	ec56                	sd	s5,24(sp)
    27f8:	e85a                	sd	s6,16(sp)
    27fa:	0880                	addi	s0,sp,80
    27fc:	89aa                	mv	s3,a0
  unlink("bd");
    27fe:	00003517          	auipc	a0,0x3
    2802:	27a50513          	addi	a0,a0,634 # 5a78 <malloc+0x1280>
    2806:	00002097          	auipc	ra,0x2
    280a:	bec080e7          	jalr	-1044(ra) # 43f2 <unlink>
  fd = open("bd", O_CREATE);
    280e:	20000593          	li	a1,512
    2812:	00003517          	auipc	a0,0x3
    2816:	26650513          	addi	a0,a0,614 # 5a78 <malloc+0x1280>
    281a:	00002097          	auipc	ra,0x2
    281e:	bc8080e7          	jalr	-1080(ra) # 43e2 <open>
  if(fd < 0){
    2822:	0c054963          	bltz	a0,28f4 <bigdir+0x10c>
  close(fd);
    2826:	00002097          	auipc	ra,0x2
    282a:	ba4080e7          	jalr	-1116(ra) # 43ca <close>
  for(i = 0; i < N; i++){
    282e:	4901                	li	s2,0
    name[0] = 'x';
    2830:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    2834:	00003a17          	auipc	s4,0x3
    2838:	244a0a13          	addi	s4,s4,580 # 5a78 <malloc+0x1280>
  for(i = 0; i < N; i++){
    283c:	1f400b13          	li	s6,500
    name[0] = 'x';
    2840:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    2844:	41f9579b          	sraiw	a5,s2,0x1f
    2848:	01a7d71b          	srliw	a4,a5,0x1a
    284c:	012707bb          	addw	a5,a4,s2
    2850:	4067d69b          	sraiw	a3,a5,0x6
    2854:	0306869b          	addiw	a3,a3,48
    2858:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    285c:	03f7f793          	andi	a5,a5,63
    2860:	9f99                	subw	a5,a5,a4
    2862:	0307879b          	addiw	a5,a5,48
    2866:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    286a:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    286e:	fb040593          	addi	a1,s0,-80
    2872:	8552                	mv	a0,s4
    2874:	00002097          	auipc	ra,0x2
    2878:	b8e080e7          	jalr	-1138(ra) # 4402 <link>
    287c:	84aa                	mv	s1,a0
    287e:	e949                	bnez	a0,2910 <bigdir+0x128>
  for(i = 0; i < N; i++){
    2880:	2905                	addiw	s2,s2,1
    2882:	fb691fe3          	bne	s2,s6,2840 <bigdir+0x58>
  unlink("bd");
    2886:	00003517          	auipc	a0,0x3
    288a:	1f250513          	addi	a0,a0,498 # 5a78 <malloc+0x1280>
    288e:	00002097          	auipc	ra,0x2
    2892:	b64080e7          	jalr	-1180(ra) # 43f2 <unlink>
    name[0] = 'x';
    2896:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    289a:	1f400a13          	li	s4,500
    name[0] = 'x';
    289e:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    28a2:	41f4d79b          	sraiw	a5,s1,0x1f
    28a6:	01a7d71b          	srliw	a4,a5,0x1a
    28aa:	009707bb          	addw	a5,a4,s1
    28ae:	4067d69b          	sraiw	a3,a5,0x6
    28b2:	0306869b          	addiw	a3,a3,48
    28b6:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    28ba:	03f7f793          	andi	a5,a5,63
    28be:	9f99                	subw	a5,a5,a4
    28c0:	0307879b          	addiw	a5,a5,48
    28c4:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    28c8:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    28cc:	fb040513          	addi	a0,s0,-80
    28d0:	00002097          	auipc	ra,0x2
    28d4:	b22080e7          	jalr	-1246(ra) # 43f2 <unlink>
    28d8:	e931                	bnez	a0,292c <bigdir+0x144>
  for(i = 0; i < N; i++){
    28da:	2485                	addiw	s1,s1,1
    28dc:	fd4491e3          	bne	s1,s4,289e <bigdir+0xb6>
}
    28e0:	60a6                	ld	ra,72(sp)
    28e2:	6406                	ld	s0,64(sp)
    28e4:	74e2                	ld	s1,56(sp)
    28e6:	7942                	ld	s2,48(sp)
    28e8:	79a2                	ld	s3,40(sp)
    28ea:	7a02                	ld	s4,32(sp)
    28ec:	6ae2                	ld	s5,24(sp)
    28ee:	6b42                	ld	s6,16(sp)
    28f0:	6161                	addi	sp,sp,80
    28f2:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    28f4:	85ce                	mv	a1,s3
    28f6:	00003517          	auipc	a0,0x3
    28fa:	18a50513          	addi	a0,a0,394 # 5a80 <malloc+0x1288>
    28fe:	00002097          	auipc	ra,0x2
    2902:	e3c080e7          	jalr	-452(ra) # 473a <printf>
    exit(1);
    2906:	4505                	li	a0,1
    2908:	00002097          	auipc	ra,0x2
    290c:	a9a080e7          	jalr	-1382(ra) # 43a2 <exit>
      printf("%s: bigdir link failed\n", s);
    2910:	85ce                	mv	a1,s3
    2912:	00003517          	auipc	a0,0x3
    2916:	18e50513          	addi	a0,a0,398 # 5aa0 <malloc+0x12a8>
    291a:	00002097          	auipc	ra,0x2
    291e:	e20080e7          	jalr	-480(ra) # 473a <printf>
      exit(1);
    2922:	4505                	li	a0,1
    2924:	00002097          	auipc	ra,0x2
    2928:	a7e080e7          	jalr	-1410(ra) # 43a2 <exit>
      printf("%s: bigdir unlink failed", s);
    292c:	85ce                	mv	a1,s3
    292e:	00003517          	auipc	a0,0x3
    2932:	18a50513          	addi	a0,a0,394 # 5ab8 <malloc+0x12c0>
    2936:	00002097          	auipc	ra,0x2
    293a:	e04080e7          	jalr	-508(ra) # 473a <printf>
      exit(1);
    293e:	4505                	li	a0,1
    2940:	00002097          	auipc	ra,0x2
    2944:	a62080e7          	jalr	-1438(ra) # 43a2 <exit>

0000000000002948 <subdir>:
{
    2948:	1101                	addi	sp,sp,-32
    294a:	ec06                	sd	ra,24(sp)
    294c:	e822                	sd	s0,16(sp)
    294e:	e426                	sd	s1,8(sp)
    2950:	e04a                	sd	s2,0(sp)
    2952:	1000                	addi	s0,sp,32
    2954:	892a                	mv	s2,a0
  unlink("ff");
    2956:	00003517          	auipc	a0,0x3
    295a:	2b250513          	addi	a0,a0,690 # 5c08 <malloc+0x1410>
    295e:	00002097          	auipc	ra,0x2
    2962:	a94080e7          	jalr	-1388(ra) # 43f2 <unlink>
  if(mkdir("dd") != 0){
    2966:	00003517          	auipc	a0,0x3
    296a:	17250513          	addi	a0,a0,370 # 5ad8 <malloc+0x12e0>
    296e:	00002097          	auipc	ra,0x2
    2972:	a9c080e7          	jalr	-1380(ra) # 440a <mkdir>
    2976:	38051663          	bnez	a0,2d02 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    297a:	20200593          	li	a1,514
    297e:	00003517          	auipc	a0,0x3
    2982:	17a50513          	addi	a0,a0,378 # 5af8 <malloc+0x1300>
    2986:	00002097          	auipc	ra,0x2
    298a:	a5c080e7          	jalr	-1444(ra) # 43e2 <open>
    298e:	84aa                	mv	s1,a0
  if(fd < 0){
    2990:	38054763          	bltz	a0,2d1e <subdir+0x3d6>
  write(fd, "ff", 2);
    2994:	4609                	li	a2,2
    2996:	00003597          	auipc	a1,0x3
    299a:	27258593          	addi	a1,a1,626 # 5c08 <malloc+0x1410>
    299e:	00002097          	auipc	ra,0x2
    29a2:	a24080e7          	jalr	-1500(ra) # 43c2 <write>
  close(fd);
    29a6:	8526                	mv	a0,s1
    29a8:	00002097          	auipc	ra,0x2
    29ac:	a22080e7          	jalr	-1502(ra) # 43ca <close>
  if(unlink("dd") >= 0){
    29b0:	00003517          	auipc	a0,0x3
    29b4:	12850513          	addi	a0,a0,296 # 5ad8 <malloc+0x12e0>
    29b8:	00002097          	auipc	ra,0x2
    29bc:	a3a080e7          	jalr	-1478(ra) # 43f2 <unlink>
    29c0:	36055d63          	bgez	a0,2d3a <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    29c4:	00003517          	auipc	a0,0x3
    29c8:	18c50513          	addi	a0,a0,396 # 5b50 <malloc+0x1358>
    29cc:	00002097          	auipc	ra,0x2
    29d0:	a3e080e7          	jalr	-1474(ra) # 440a <mkdir>
    29d4:	38051163          	bnez	a0,2d56 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    29d8:	20200593          	li	a1,514
    29dc:	00003517          	auipc	a0,0x3
    29e0:	19c50513          	addi	a0,a0,412 # 5b78 <malloc+0x1380>
    29e4:	00002097          	auipc	ra,0x2
    29e8:	9fe080e7          	jalr	-1538(ra) # 43e2 <open>
    29ec:	84aa                	mv	s1,a0
  if(fd < 0){
    29ee:	38054263          	bltz	a0,2d72 <subdir+0x42a>
  write(fd, "FF", 2);
    29f2:	4609                	li	a2,2
    29f4:	00003597          	auipc	a1,0x3
    29f8:	1b458593          	addi	a1,a1,436 # 5ba8 <malloc+0x13b0>
    29fc:	00002097          	auipc	ra,0x2
    2a00:	9c6080e7          	jalr	-1594(ra) # 43c2 <write>
  close(fd);
    2a04:	8526                	mv	a0,s1
    2a06:	00002097          	auipc	ra,0x2
    2a0a:	9c4080e7          	jalr	-1596(ra) # 43ca <close>
  fd = open("dd/dd/../ff", 0);
    2a0e:	4581                	li	a1,0
    2a10:	00003517          	auipc	a0,0x3
    2a14:	1a050513          	addi	a0,a0,416 # 5bb0 <malloc+0x13b8>
    2a18:	00002097          	auipc	ra,0x2
    2a1c:	9ca080e7          	jalr	-1590(ra) # 43e2 <open>
    2a20:	84aa                	mv	s1,a0
  if(fd < 0){
    2a22:	36054663          	bltz	a0,2d8e <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    2a26:	660d                	lui	a2,0x3
    2a28:	00006597          	auipc	a1,0x6
    2a2c:	75858593          	addi	a1,a1,1880 # 9180 <buf>
    2a30:	00002097          	auipc	ra,0x2
    2a34:	98a080e7          	jalr	-1654(ra) # 43ba <read>
  if(cc != 2 || buf[0] != 'f'){
    2a38:	4789                	li	a5,2
    2a3a:	36f51863          	bne	a0,a5,2daa <subdir+0x462>
    2a3e:	00006717          	auipc	a4,0x6
    2a42:	74274703          	lbu	a4,1858(a4) # 9180 <buf>
    2a46:	06600793          	li	a5,102
    2a4a:	36f71063          	bne	a4,a5,2daa <subdir+0x462>
  close(fd);
    2a4e:	8526                	mv	a0,s1
    2a50:	00002097          	auipc	ra,0x2
    2a54:	97a080e7          	jalr	-1670(ra) # 43ca <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2a58:	00003597          	auipc	a1,0x3
    2a5c:	1a858593          	addi	a1,a1,424 # 5c00 <malloc+0x1408>
    2a60:	00003517          	auipc	a0,0x3
    2a64:	11850513          	addi	a0,a0,280 # 5b78 <malloc+0x1380>
    2a68:	00002097          	auipc	ra,0x2
    2a6c:	99a080e7          	jalr	-1638(ra) # 4402 <link>
    2a70:	34051b63          	bnez	a0,2dc6 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    2a74:	00003517          	auipc	a0,0x3
    2a78:	10450513          	addi	a0,a0,260 # 5b78 <malloc+0x1380>
    2a7c:	00002097          	auipc	ra,0x2
    2a80:	976080e7          	jalr	-1674(ra) # 43f2 <unlink>
    2a84:	34051f63          	bnez	a0,2de2 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2a88:	4581                	li	a1,0
    2a8a:	00003517          	auipc	a0,0x3
    2a8e:	0ee50513          	addi	a0,a0,238 # 5b78 <malloc+0x1380>
    2a92:	00002097          	auipc	ra,0x2
    2a96:	950080e7          	jalr	-1712(ra) # 43e2 <open>
    2a9a:	36055263          	bgez	a0,2dfe <subdir+0x4b6>
  if(chdir("dd") != 0){
    2a9e:	00003517          	auipc	a0,0x3
    2aa2:	03a50513          	addi	a0,a0,58 # 5ad8 <malloc+0x12e0>
    2aa6:	00002097          	auipc	ra,0x2
    2aaa:	96c080e7          	jalr	-1684(ra) # 4412 <chdir>
    2aae:	36051663          	bnez	a0,2e1a <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    2ab2:	00003517          	auipc	a0,0x3
    2ab6:	1e650513          	addi	a0,a0,486 # 5c98 <malloc+0x14a0>
    2aba:	00002097          	auipc	ra,0x2
    2abe:	958080e7          	jalr	-1704(ra) # 4412 <chdir>
    2ac2:	36051a63          	bnez	a0,2e36 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    2ac6:	00003517          	auipc	a0,0x3
    2aca:	20250513          	addi	a0,a0,514 # 5cc8 <malloc+0x14d0>
    2ace:	00002097          	auipc	ra,0x2
    2ad2:	944080e7          	jalr	-1724(ra) # 4412 <chdir>
    2ad6:	36051e63          	bnez	a0,2e52 <subdir+0x50a>
  if(chdir("./..") != 0){
    2ada:	00003517          	auipc	a0,0x3
    2ade:	21e50513          	addi	a0,a0,542 # 5cf8 <malloc+0x1500>
    2ae2:	00002097          	auipc	ra,0x2
    2ae6:	930080e7          	jalr	-1744(ra) # 4412 <chdir>
    2aea:	38051263          	bnez	a0,2e6e <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    2aee:	4581                	li	a1,0
    2af0:	00003517          	auipc	a0,0x3
    2af4:	11050513          	addi	a0,a0,272 # 5c00 <malloc+0x1408>
    2af8:	00002097          	auipc	ra,0x2
    2afc:	8ea080e7          	jalr	-1814(ra) # 43e2 <open>
    2b00:	84aa                	mv	s1,a0
  if(fd < 0){
    2b02:	38054463          	bltz	a0,2e8a <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    2b06:	660d                	lui	a2,0x3
    2b08:	00006597          	auipc	a1,0x6
    2b0c:	67858593          	addi	a1,a1,1656 # 9180 <buf>
    2b10:	00002097          	auipc	ra,0x2
    2b14:	8aa080e7          	jalr	-1878(ra) # 43ba <read>
    2b18:	4789                	li	a5,2
    2b1a:	38f51663          	bne	a0,a5,2ea6 <subdir+0x55e>
  close(fd);
    2b1e:	8526                	mv	a0,s1
    2b20:	00002097          	auipc	ra,0x2
    2b24:	8aa080e7          	jalr	-1878(ra) # 43ca <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2b28:	4581                	li	a1,0
    2b2a:	00003517          	auipc	a0,0x3
    2b2e:	04e50513          	addi	a0,a0,78 # 5b78 <malloc+0x1380>
    2b32:	00002097          	auipc	ra,0x2
    2b36:	8b0080e7          	jalr	-1872(ra) # 43e2 <open>
    2b3a:	38055463          	bgez	a0,2ec2 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2b3e:	20200593          	li	a1,514
    2b42:	00003517          	auipc	a0,0x3
    2b46:	24650513          	addi	a0,a0,582 # 5d88 <malloc+0x1590>
    2b4a:	00002097          	auipc	ra,0x2
    2b4e:	898080e7          	jalr	-1896(ra) # 43e2 <open>
    2b52:	38055663          	bgez	a0,2ede <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2b56:	20200593          	li	a1,514
    2b5a:	00003517          	auipc	a0,0x3
    2b5e:	25e50513          	addi	a0,a0,606 # 5db8 <malloc+0x15c0>
    2b62:	00002097          	auipc	ra,0x2
    2b66:	880080e7          	jalr	-1920(ra) # 43e2 <open>
    2b6a:	38055863          	bgez	a0,2efa <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    2b6e:	20000593          	li	a1,512
    2b72:	00003517          	auipc	a0,0x3
    2b76:	f6650513          	addi	a0,a0,-154 # 5ad8 <malloc+0x12e0>
    2b7a:	00002097          	auipc	ra,0x2
    2b7e:	868080e7          	jalr	-1944(ra) # 43e2 <open>
    2b82:	38055a63          	bgez	a0,2f16 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    2b86:	4589                	li	a1,2
    2b88:	00003517          	auipc	a0,0x3
    2b8c:	f5050513          	addi	a0,a0,-176 # 5ad8 <malloc+0x12e0>
    2b90:	00002097          	auipc	ra,0x2
    2b94:	852080e7          	jalr	-1966(ra) # 43e2 <open>
    2b98:	38055d63          	bgez	a0,2f32 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    2b9c:	4585                	li	a1,1
    2b9e:	00003517          	auipc	a0,0x3
    2ba2:	f3a50513          	addi	a0,a0,-198 # 5ad8 <malloc+0x12e0>
    2ba6:	00002097          	auipc	ra,0x2
    2baa:	83c080e7          	jalr	-1988(ra) # 43e2 <open>
    2bae:	3a055063          	bgez	a0,2f4e <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2bb2:	00003597          	auipc	a1,0x3
    2bb6:	29658593          	addi	a1,a1,662 # 5e48 <malloc+0x1650>
    2bba:	00003517          	auipc	a0,0x3
    2bbe:	1ce50513          	addi	a0,a0,462 # 5d88 <malloc+0x1590>
    2bc2:	00002097          	auipc	ra,0x2
    2bc6:	840080e7          	jalr	-1984(ra) # 4402 <link>
    2bca:	3a050063          	beqz	a0,2f6a <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2bce:	00003597          	auipc	a1,0x3
    2bd2:	27a58593          	addi	a1,a1,634 # 5e48 <malloc+0x1650>
    2bd6:	00003517          	auipc	a0,0x3
    2bda:	1e250513          	addi	a0,a0,482 # 5db8 <malloc+0x15c0>
    2bde:	00002097          	auipc	ra,0x2
    2be2:	824080e7          	jalr	-2012(ra) # 4402 <link>
    2be6:	3a050063          	beqz	a0,2f86 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2bea:	00003597          	auipc	a1,0x3
    2bee:	01658593          	addi	a1,a1,22 # 5c00 <malloc+0x1408>
    2bf2:	00003517          	auipc	a0,0x3
    2bf6:	f0650513          	addi	a0,a0,-250 # 5af8 <malloc+0x1300>
    2bfa:	00002097          	auipc	ra,0x2
    2bfe:	808080e7          	jalr	-2040(ra) # 4402 <link>
    2c02:	3a050063          	beqz	a0,2fa2 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    2c06:	00003517          	auipc	a0,0x3
    2c0a:	18250513          	addi	a0,a0,386 # 5d88 <malloc+0x1590>
    2c0e:	00001097          	auipc	ra,0x1
    2c12:	7fc080e7          	jalr	2044(ra) # 440a <mkdir>
    2c16:	3a050463          	beqz	a0,2fbe <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    2c1a:	00003517          	auipc	a0,0x3
    2c1e:	19e50513          	addi	a0,a0,414 # 5db8 <malloc+0x15c0>
    2c22:	00001097          	auipc	ra,0x1
    2c26:	7e8080e7          	jalr	2024(ra) # 440a <mkdir>
    2c2a:	3a050863          	beqz	a0,2fda <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    2c2e:	00003517          	auipc	a0,0x3
    2c32:	fd250513          	addi	a0,a0,-46 # 5c00 <malloc+0x1408>
    2c36:	00001097          	auipc	ra,0x1
    2c3a:	7d4080e7          	jalr	2004(ra) # 440a <mkdir>
    2c3e:	3a050c63          	beqz	a0,2ff6 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    2c42:	00003517          	auipc	a0,0x3
    2c46:	17650513          	addi	a0,a0,374 # 5db8 <malloc+0x15c0>
    2c4a:	00001097          	auipc	ra,0x1
    2c4e:	7a8080e7          	jalr	1960(ra) # 43f2 <unlink>
    2c52:	3c050063          	beqz	a0,3012 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    2c56:	00003517          	auipc	a0,0x3
    2c5a:	13250513          	addi	a0,a0,306 # 5d88 <malloc+0x1590>
    2c5e:	00001097          	auipc	ra,0x1
    2c62:	794080e7          	jalr	1940(ra) # 43f2 <unlink>
    2c66:	3c050463          	beqz	a0,302e <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    2c6a:	00003517          	auipc	a0,0x3
    2c6e:	e8e50513          	addi	a0,a0,-370 # 5af8 <malloc+0x1300>
    2c72:	00001097          	auipc	ra,0x1
    2c76:	7a0080e7          	jalr	1952(ra) # 4412 <chdir>
    2c7a:	3c050863          	beqz	a0,304a <subdir+0x702>
  if(chdir("dd/xx") == 0){
    2c7e:	00003517          	auipc	a0,0x3
    2c82:	31a50513          	addi	a0,a0,794 # 5f98 <malloc+0x17a0>
    2c86:	00001097          	auipc	ra,0x1
    2c8a:	78c080e7          	jalr	1932(ra) # 4412 <chdir>
    2c8e:	3c050c63          	beqz	a0,3066 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    2c92:	00003517          	auipc	a0,0x3
    2c96:	f6e50513          	addi	a0,a0,-146 # 5c00 <malloc+0x1408>
    2c9a:	00001097          	auipc	ra,0x1
    2c9e:	758080e7          	jalr	1880(ra) # 43f2 <unlink>
    2ca2:	3e051063          	bnez	a0,3082 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    2ca6:	00003517          	auipc	a0,0x3
    2caa:	e5250513          	addi	a0,a0,-430 # 5af8 <malloc+0x1300>
    2cae:	00001097          	auipc	ra,0x1
    2cb2:	744080e7          	jalr	1860(ra) # 43f2 <unlink>
    2cb6:	3e051463          	bnez	a0,309e <subdir+0x756>
  if(unlink("dd") == 0){
    2cba:	00003517          	auipc	a0,0x3
    2cbe:	e1e50513          	addi	a0,a0,-482 # 5ad8 <malloc+0x12e0>
    2cc2:	00001097          	auipc	ra,0x1
    2cc6:	730080e7          	jalr	1840(ra) # 43f2 <unlink>
    2cca:	3e050863          	beqz	a0,30ba <subdir+0x772>
  if(unlink("dd/dd") < 0){
    2cce:	00003517          	auipc	a0,0x3
    2cd2:	33a50513          	addi	a0,a0,826 # 6008 <malloc+0x1810>
    2cd6:	00001097          	auipc	ra,0x1
    2cda:	71c080e7          	jalr	1820(ra) # 43f2 <unlink>
    2cde:	3e054c63          	bltz	a0,30d6 <subdir+0x78e>
  if(unlink("dd") < 0){
    2ce2:	00003517          	auipc	a0,0x3
    2ce6:	df650513          	addi	a0,a0,-522 # 5ad8 <malloc+0x12e0>
    2cea:	00001097          	auipc	ra,0x1
    2cee:	708080e7          	jalr	1800(ra) # 43f2 <unlink>
    2cf2:	40054063          	bltz	a0,30f2 <subdir+0x7aa>
}
    2cf6:	60e2                	ld	ra,24(sp)
    2cf8:	6442                	ld	s0,16(sp)
    2cfa:	64a2                	ld	s1,8(sp)
    2cfc:	6902                	ld	s2,0(sp)
    2cfe:	6105                	addi	sp,sp,32
    2d00:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    2d02:	85ca                	mv	a1,s2
    2d04:	00003517          	auipc	a0,0x3
    2d08:	ddc50513          	addi	a0,a0,-548 # 5ae0 <malloc+0x12e8>
    2d0c:	00002097          	auipc	ra,0x2
    2d10:	a2e080e7          	jalr	-1490(ra) # 473a <printf>
    exit(1);
    2d14:	4505                	li	a0,1
    2d16:	00001097          	auipc	ra,0x1
    2d1a:	68c080e7          	jalr	1676(ra) # 43a2 <exit>
    printf("%s: create dd/ff failed\n", s);
    2d1e:	85ca                	mv	a1,s2
    2d20:	00003517          	auipc	a0,0x3
    2d24:	de050513          	addi	a0,a0,-544 # 5b00 <malloc+0x1308>
    2d28:	00002097          	auipc	ra,0x2
    2d2c:	a12080e7          	jalr	-1518(ra) # 473a <printf>
    exit(1);
    2d30:	4505                	li	a0,1
    2d32:	00001097          	auipc	ra,0x1
    2d36:	670080e7          	jalr	1648(ra) # 43a2 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    2d3a:	85ca                	mv	a1,s2
    2d3c:	00003517          	auipc	a0,0x3
    2d40:	de450513          	addi	a0,a0,-540 # 5b20 <malloc+0x1328>
    2d44:	00002097          	auipc	ra,0x2
    2d48:	9f6080e7          	jalr	-1546(ra) # 473a <printf>
    exit(1);
    2d4c:	4505                	li	a0,1
    2d4e:	00001097          	auipc	ra,0x1
    2d52:	654080e7          	jalr	1620(ra) # 43a2 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    2d56:	85ca                	mv	a1,s2
    2d58:	00003517          	auipc	a0,0x3
    2d5c:	e0050513          	addi	a0,a0,-512 # 5b58 <malloc+0x1360>
    2d60:	00002097          	auipc	ra,0x2
    2d64:	9da080e7          	jalr	-1574(ra) # 473a <printf>
    exit(1);
    2d68:	4505                	li	a0,1
    2d6a:	00001097          	auipc	ra,0x1
    2d6e:	638080e7          	jalr	1592(ra) # 43a2 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    2d72:	85ca                	mv	a1,s2
    2d74:	00003517          	auipc	a0,0x3
    2d78:	e1450513          	addi	a0,a0,-492 # 5b88 <malloc+0x1390>
    2d7c:	00002097          	auipc	ra,0x2
    2d80:	9be080e7          	jalr	-1602(ra) # 473a <printf>
    exit(1);
    2d84:	4505                	li	a0,1
    2d86:	00001097          	auipc	ra,0x1
    2d8a:	61c080e7          	jalr	1564(ra) # 43a2 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    2d8e:	85ca                	mv	a1,s2
    2d90:	00003517          	auipc	a0,0x3
    2d94:	e3050513          	addi	a0,a0,-464 # 5bc0 <malloc+0x13c8>
    2d98:	00002097          	auipc	ra,0x2
    2d9c:	9a2080e7          	jalr	-1630(ra) # 473a <printf>
    exit(1);
    2da0:	4505                	li	a0,1
    2da2:	00001097          	auipc	ra,0x1
    2da6:	600080e7          	jalr	1536(ra) # 43a2 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    2daa:	85ca                	mv	a1,s2
    2dac:	00003517          	auipc	a0,0x3
    2db0:	e3450513          	addi	a0,a0,-460 # 5be0 <malloc+0x13e8>
    2db4:	00002097          	auipc	ra,0x2
    2db8:	986080e7          	jalr	-1658(ra) # 473a <printf>
    exit(1);
    2dbc:	4505                	li	a0,1
    2dbe:	00001097          	auipc	ra,0x1
    2dc2:	5e4080e7          	jalr	1508(ra) # 43a2 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    2dc6:	85ca                	mv	a1,s2
    2dc8:	00003517          	auipc	a0,0x3
    2dcc:	e4850513          	addi	a0,a0,-440 # 5c10 <malloc+0x1418>
    2dd0:	00002097          	auipc	ra,0x2
    2dd4:	96a080e7          	jalr	-1686(ra) # 473a <printf>
    exit(1);
    2dd8:	4505                	li	a0,1
    2dda:	00001097          	auipc	ra,0x1
    2dde:	5c8080e7          	jalr	1480(ra) # 43a2 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2de2:	85ca                	mv	a1,s2
    2de4:	00003517          	auipc	a0,0x3
    2de8:	e5450513          	addi	a0,a0,-428 # 5c38 <malloc+0x1440>
    2dec:	00002097          	auipc	ra,0x2
    2df0:	94e080e7          	jalr	-1714(ra) # 473a <printf>
    exit(1);
    2df4:	4505                	li	a0,1
    2df6:	00001097          	auipc	ra,0x1
    2dfa:	5ac080e7          	jalr	1452(ra) # 43a2 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    2dfe:	85ca                	mv	a1,s2
    2e00:	00003517          	auipc	a0,0x3
    2e04:	e5850513          	addi	a0,a0,-424 # 5c58 <malloc+0x1460>
    2e08:	00002097          	auipc	ra,0x2
    2e0c:	932080e7          	jalr	-1742(ra) # 473a <printf>
    exit(1);
    2e10:	4505                	li	a0,1
    2e12:	00001097          	auipc	ra,0x1
    2e16:	590080e7          	jalr	1424(ra) # 43a2 <exit>
    printf("%s: chdir dd failed\n", s);
    2e1a:	85ca                	mv	a1,s2
    2e1c:	00003517          	auipc	a0,0x3
    2e20:	e6450513          	addi	a0,a0,-412 # 5c80 <malloc+0x1488>
    2e24:	00002097          	auipc	ra,0x2
    2e28:	916080e7          	jalr	-1770(ra) # 473a <printf>
    exit(1);
    2e2c:	4505                	li	a0,1
    2e2e:	00001097          	auipc	ra,0x1
    2e32:	574080e7          	jalr	1396(ra) # 43a2 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    2e36:	85ca                	mv	a1,s2
    2e38:	00003517          	auipc	a0,0x3
    2e3c:	e7050513          	addi	a0,a0,-400 # 5ca8 <malloc+0x14b0>
    2e40:	00002097          	auipc	ra,0x2
    2e44:	8fa080e7          	jalr	-1798(ra) # 473a <printf>
    exit(1);
    2e48:	4505                	li	a0,1
    2e4a:	00001097          	auipc	ra,0x1
    2e4e:	558080e7          	jalr	1368(ra) # 43a2 <exit>
    printf("chdir dd/../../dd failed\n", s);
    2e52:	85ca                	mv	a1,s2
    2e54:	00003517          	auipc	a0,0x3
    2e58:	e8450513          	addi	a0,a0,-380 # 5cd8 <malloc+0x14e0>
    2e5c:	00002097          	auipc	ra,0x2
    2e60:	8de080e7          	jalr	-1826(ra) # 473a <printf>
    exit(1);
    2e64:	4505                	li	a0,1
    2e66:	00001097          	auipc	ra,0x1
    2e6a:	53c080e7          	jalr	1340(ra) # 43a2 <exit>
    printf("%s: chdir ./.. failed\n", s);
    2e6e:	85ca                	mv	a1,s2
    2e70:	00003517          	auipc	a0,0x3
    2e74:	e9050513          	addi	a0,a0,-368 # 5d00 <malloc+0x1508>
    2e78:	00002097          	auipc	ra,0x2
    2e7c:	8c2080e7          	jalr	-1854(ra) # 473a <printf>
    exit(1);
    2e80:	4505                	li	a0,1
    2e82:	00001097          	auipc	ra,0x1
    2e86:	520080e7          	jalr	1312(ra) # 43a2 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    2e8a:	85ca                	mv	a1,s2
    2e8c:	00003517          	auipc	a0,0x3
    2e90:	e8c50513          	addi	a0,a0,-372 # 5d18 <malloc+0x1520>
    2e94:	00002097          	auipc	ra,0x2
    2e98:	8a6080e7          	jalr	-1882(ra) # 473a <printf>
    exit(1);
    2e9c:	4505                	li	a0,1
    2e9e:	00001097          	auipc	ra,0x1
    2ea2:	504080e7          	jalr	1284(ra) # 43a2 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    2ea6:	85ca                	mv	a1,s2
    2ea8:	00003517          	auipc	a0,0x3
    2eac:	e9050513          	addi	a0,a0,-368 # 5d38 <malloc+0x1540>
    2eb0:	00002097          	auipc	ra,0x2
    2eb4:	88a080e7          	jalr	-1910(ra) # 473a <printf>
    exit(1);
    2eb8:	4505                	li	a0,1
    2eba:	00001097          	auipc	ra,0x1
    2ebe:	4e8080e7          	jalr	1256(ra) # 43a2 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    2ec2:	85ca                	mv	a1,s2
    2ec4:	00003517          	auipc	a0,0x3
    2ec8:	e9450513          	addi	a0,a0,-364 # 5d58 <malloc+0x1560>
    2ecc:	00002097          	auipc	ra,0x2
    2ed0:	86e080e7          	jalr	-1938(ra) # 473a <printf>
    exit(1);
    2ed4:	4505                	li	a0,1
    2ed6:	00001097          	auipc	ra,0x1
    2eda:	4cc080e7          	jalr	1228(ra) # 43a2 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    2ede:	85ca                	mv	a1,s2
    2ee0:	00003517          	auipc	a0,0x3
    2ee4:	eb850513          	addi	a0,a0,-328 # 5d98 <malloc+0x15a0>
    2ee8:	00002097          	auipc	ra,0x2
    2eec:	852080e7          	jalr	-1966(ra) # 473a <printf>
    exit(1);
    2ef0:	4505                	li	a0,1
    2ef2:	00001097          	auipc	ra,0x1
    2ef6:	4b0080e7          	jalr	1200(ra) # 43a2 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    2efa:	85ca                	mv	a1,s2
    2efc:	00003517          	auipc	a0,0x3
    2f00:	ecc50513          	addi	a0,a0,-308 # 5dc8 <malloc+0x15d0>
    2f04:	00002097          	auipc	ra,0x2
    2f08:	836080e7          	jalr	-1994(ra) # 473a <printf>
    exit(1);
    2f0c:	4505                	li	a0,1
    2f0e:	00001097          	auipc	ra,0x1
    2f12:	494080e7          	jalr	1172(ra) # 43a2 <exit>
    printf("%s: create dd succeeded!\n", s);
    2f16:	85ca                	mv	a1,s2
    2f18:	00003517          	auipc	a0,0x3
    2f1c:	ed050513          	addi	a0,a0,-304 # 5de8 <malloc+0x15f0>
    2f20:	00002097          	auipc	ra,0x2
    2f24:	81a080e7          	jalr	-2022(ra) # 473a <printf>
    exit(1);
    2f28:	4505                	li	a0,1
    2f2a:	00001097          	auipc	ra,0x1
    2f2e:	478080e7          	jalr	1144(ra) # 43a2 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    2f32:	85ca                	mv	a1,s2
    2f34:	00003517          	auipc	a0,0x3
    2f38:	ed450513          	addi	a0,a0,-300 # 5e08 <malloc+0x1610>
    2f3c:	00001097          	auipc	ra,0x1
    2f40:	7fe080e7          	jalr	2046(ra) # 473a <printf>
    exit(1);
    2f44:	4505                	li	a0,1
    2f46:	00001097          	auipc	ra,0x1
    2f4a:	45c080e7          	jalr	1116(ra) # 43a2 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    2f4e:	85ca                	mv	a1,s2
    2f50:	00003517          	auipc	a0,0x3
    2f54:	ed850513          	addi	a0,a0,-296 # 5e28 <malloc+0x1630>
    2f58:	00001097          	auipc	ra,0x1
    2f5c:	7e2080e7          	jalr	2018(ra) # 473a <printf>
    exit(1);
    2f60:	4505                	li	a0,1
    2f62:	00001097          	auipc	ra,0x1
    2f66:	440080e7          	jalr	1088(ra) # 43a2 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    2f6a:	85ca                	mv	a1,s2
    2f6c:	00003517          	auipc	a0,0x3
    2f70:	eec50513          	addi	a0,a0,-276 # 5e58 <malloc+0x1660>
    2f74:	00001097          	auipc	ra,0x1
    2f78:	7c6080e7          	jalr	1990(ra) # 473a <printf>
    exit(1);
    2f7c:	4505                	li	a0,1
    2f7e:	00001097          	auipc	ra,0x1
    2f82:	424080e7          	jalr	1060(ra) # 43a2 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    2f86:	85ca                	mv	a1,s2
    2f88:	00003517          	auipc	a0,0x3
    2f8c:	ef850513          	addi	a0,a0,-264 # 5e80 <malloc+0x1688>
    2f90:	00001097          	auipc	ra,0x1
    2f94:	7aa080e7          	jalr	1962(ra) # 473a <printf>
    exit(1);
    2f98:	4505                	li	a0,1
    2f9a:	00001097          	auipc	ra,0x1
    2f9e:	408080e7          	jalr	1032(ra) # 43a2 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    2fa2:	85ca                	mv	a1,s2
    2fa4:	00003517          	auipc	a0,0x3
    2fa8:	f0450513          	addi	a0,a0,-252 # 5ea8 <malloc+0x16b0>
    2fac:	00001097          	auipc	ra,0x1
    2fb0:	78e080e7          	jalr	1934(ra) # 473a <printf>
    exit(1);
    2fb4:	4505                	li	a0,1
    2fb6:	00001097          	auipc	ra,0x1
    2fba:	3ec080e7          	jalr	1004(ra) # 43a2 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    2fbe:	85ca                	mv	a1,s2
    2fc0:	00003517          	auipc	a0,0x3
    2fc4:	f1050513          	addi	a0,a0,-240 # 5ed0 <malloc+0x16d8>
    2fc8:	00001097          	auipc	ra,0x1
    2fcc:	772080e7          	jalr	1906(ra) # 473a <printf>
    exit(1);
    2fd0:	4505                	li	a0,1
    2fd2:	00001097          	auipc	ra,0x1
    2fd6:	3d0080e7          	jalr	976(ra) # 43a2 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    2fda:	85ca                	mv	a1,s2
    2fdc:	00003517          	auipc	a0,0x3
    2fe0:	f1450513          	addi	a0,a0,-236 # 5ef0 <malloc+0x16f8>
    2fe4:	00001097          	auipc	ra,0x1
    2fe8:	756080e7          	jalr	1878(ra) # 473a <printf>
    exit(1);
    2fec:	4505                	li	a0,1
    2fee:	00001097          	auipc	ra,0x1
    2ff2:	3b4080e7          	jalr	948(ra) # 43a2 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    2ff6:	85ca                	mv	a1,s2
    2ff8:	00003517          	auipc	a0,0x3
    2ffc:	f1850513          	addi	a0,a0,-232 # 5f10 <malloc+0x1718>
    3000:	00001097          	auipc	ra,0x1
    3004:	73a080e7          	jalr	1850(ra) # 473a <printf>
    exit(1);
    3008:	4505                	li	a0,1
    300a:	00001097          	auipc	ra,0x1
    300e:	398080e7          	jalr	920(ra) # 43a2 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3012:	85ca                	mv	a1,s2
    3014:	00003517          	auipc	a0,0x3
    3018:	f2450513          	addi	a0,a0,-220 # 5f38 <malloc+0x1740>
    301c:	00001097          	auipc	ra,0x1
    3020:	71e080e7          	jalr	1822(ra) # 473a <printf>
    exit(1);
    3024:	4505                	li	a0,1
    3026:	00001097          	auipc	ra,0x1
    302a:	37c080e7          	jalr	892(ra) # 43a2 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    302e:	85ca                	mv	a1,s2
    3030:	00003517          	auipc	a0,0x3
    3034:	f2850513          	addi	a0,a0,-216 # 5f58 <malloc+0x1760>
    3038:	00001097          	auipc	ra,0x1
    303c:	702080e7          	jalr	1794(ra) # 473a <printf>
    exit(1);
    3040:	4505                	li	a0,1
    3042:	00001097          	auipc	ra,0x1
    3046:	360080e7          	jalr	864(ra) # 43a2 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    304a:	85ca                	mv	a1,s2
    304c:	00003517          	auipc	a0,0x3
    3050:	f2c50513          	addi	a0,a0,-212 # 5f78 <malloc+0x1780>
    3054:	00001097          	auipc	ra,0x1
    3058:	6e6080e7          	jalr	1766(ra) # 473a <printf>
    exit(1);
    305c:	4505                	li	a0,1
    305e:	00001097          	auipc	ra,0x1
    3062:	344080e7          	jalr	836(ra) # 43a2 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3066:	85ca                	mv	a1,s2
    3068:	00003517          	auipc	a0,0x3
    306c:	f3850513          	addi	a0,a0,-200 # 5fa0 <malloc+0x17a8>
    3070:	00001097          	auipc	ra,0x1
    3074:	6ca080e7          	jalr	1738(ra) # 473a <printf>
    exit(1);
    3078:	4505                	li	a0,1
    307a:	00001097          	auipc	ra,0x1
    307e:	328080e7          	jalr	808(ra) # 43a2 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3082:	85ca                	mv	a1,s2
    3084:	00003517          	auipc	a0,0x3
    3088:	bb450513          	addi	a0,a0,-1100 # 5c38 <malloc+0x1440>
    308c:	00001097          	auipc	ra,0x1
    3090:	6ae080e7          	jalr	1710(ra) # 473a <printf>
    exit(1);
    3094:	4505                	li	a0,1
    3096:	00001097          	auipc	ra,0x1
    309a:	30c080e7          	jalr	780(ra) # 43a2 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    309e:	85ca                	mv	a1,s2
    30a0:	00003517          	auipc	a0,0x3
    30a4:	f2050513          	addi	a0,a0,-224 # 5fc0 <malloc+0x17c8>
    30a8:	00001097          	auipc	ra,0x1
    30ac:	692080e7          	jalr	1682(ra) # 473a <printf>
    exit(1);
    30b0:	4505                	li	a0,1
    30b2:	00001097          	auipc	ra,0x1
    30b6:	2f0080e7          	jalr	752(ra) # 43a2 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    30ba:	85ca                	mv	a1,s2
    30bc:	00003517          	auipc	a0,0x3
    30c0:	f2450513          	addi	a0,a0,-220 # 5fe0 <malloc+0x17e8>
    30c4:	00001097          	auipc	ra,0x1
    30c8:	676080e7          	jalr	1654(ra) # 473a <printf>
    exit(1);
    30cc:	4505                	li	a0,1
    30ce:	00001097          	auipc	ra,0x1
    30d2:	2d4080e7          	jalr	724(ra) # 43a2 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    30d6:	85ca                	mv	a1,s2
    30d8:	00003517          	auipc	a0,0x3
    30dc:	f3850513          	addi	a0,a0,-200 # 6010 <malloc+0x1818>
    30e0:	00001097          	auipc	ra,0x1
    30e4:	65a080e7          	jalr	1626(ra) # 473a <printf>
    exit(1);
    30e8:	4505                	li	a0,1
    30ea:	00001097          	auipc	ra,0x1
    30ee:	2b8080e7          	jalr	696(ra) # 43a2 <exit>
    printf("%s: unlink dd failed\n", s);
    30f2:	85ca                	mv	a1,s2
    30f4:	00003517          	auipc	a0,0x3
    30f8:	f3c50513          	addi	a0,a0,-196 # 6030 <malloc+0x1838>
    30fc:	00001097          	auipc	ra,0x1
    3100:	63e080e7          	jalr	1598(ra) # 473a <printf>
    exit(1);
    3104:	4505                	li	a0,1
    3106:	00001097          	auipc	ra,0x1
    310a:	29c080e7          	jalr	668(ra) # 43a2 <exit>

000000000000310e <dirfile>:
{
    310e:	1101                	addi	sp,sp,-32
    3110:	ec06                	sd	ra,24(sp)
    3112:	e822                	sd	s0,16(sp)
    3114:	e426                	sd	s1,8(sp)
    3116:	e04a                	sd	s2,0(sp)
    3118:	1000                	addi	s0,sp,32
    311a:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    311c:	20000593          	li	a1,512
    3120:	00002517          	auipc	a0,0x2
    3124:	a0850513          	addi	a0,a0,-1528 # 4b28 <malloc+0x330>
    3128:	00001097          	auipc	ra,0x1
    312c:	2ba080e7          	jalr	698(ra) # 43e2 <open>
  if(fd < 0){
    3130:	0e054d63          	bltz	a0,322a <dirfile+0x11c>
  close(fd);
    3134:	00001097          	auipc	ra,0x1
    3138:	296080e7          	jalr	662(ra) # 43ca <close>
  if(chdir("dirfile") == 0){
    313c:	00002517          	auipc	a0,0x2
    3140:	9ec50513          	addi	a0,a0,-1556 # 4b28 <malloc+0x330>
    3144:	00001097          	auipc	ra,0x1
    3148:	2ce080e7          	jalr	718(ra) # 4412 <chdir>
    314c:	cd6d                	beqz	a0,3246 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    314e:	4581                	li	a1,0
    3150:	00003517          	auipc	a0,0x3
    3154:	f3850513          	addi	a0,a0,-200 # 6088 <malloc+0x1890>
    3158:	00001097          	auipc	ra,0x1
    315c:	28a080e7          	jalr	650(ra) # 43e2 <open>
  if(fd >= 0){
    3160:	10055163          	bgez	a0,3262 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3164:	20000593          	li	a1,512
    3168:	00003517          	auipc	a0,0x3
    316c:	f2050513          	addi	a0,a0,-224 # 6088 <malloc+0x1890>
    3170:	00001097          	auipc	ra,0x1
    3174:	272080e7          	jalr	626(ra) # 43e2 <open>
  if(fd >= 0){
    3178:	10055363          	bgez	a0,327e <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    317c:	00003517          	auipc	a0,0x3
    3180:	f0c50513          	addi	a0,a0,-244 # 6088 <malloc+0x1890>
    3184:	00001097          	auipc	ra,0x1
    3188:	286080e7          	jalr	646(ra) # 440a <mkdir>
    318c:	10050763          	beqz	a0,329a <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3190:	00003517          	auipc	a0,0x3
    3194:	ef850513          	addi	a0,a0,-264 # 6088 <malloc+0x1890>
    3198:	00001097          	auipc	ra,0x1
    319c:	25a080e7          	jalr	602(ra) # 43f2 <unlink>
    31a0:	10050b63          	beqz	a0,32b6 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    31a4:	00003597          	auipc	a1,0x3
    31a8:	ee458593          	addi	a1,a1,-284 # 6088 <malloc+0x1890>
    31ac:	00003517          	auipc	a0,0x3
    31b0:	f6450513          	addi	a0,a0,-156 # 6110 <malloc+0x1918>
    31b4:	00001097          	auipc	ra,0x1
    31b8:	24e080e7          	jalr	590(ra) # 4402 <link>
    31bc:	10050b63          	beqz	a0,32d2 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    31c0:	00002517          	auipc	a0,0x2
    31c4:	96850513          	addi	a0,a0,-1688 # 4b28 <malloc+0x330>
    31c8:	00001097          	auipc	ra,0x1
    31cc:	22a080e7          	jalr	554(ra) # 43f2 <unlink>
    31d0:	10051f63          	bnez	a0,32ee <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    31d4:	4589                	li	a1,2
    31d6:	00002517          	auipc	a0,0x2
    31da:	a5a50513          	addi	a0,a0,-1446 # 4c30 <malloc+0x438>
    31de:	00001097          	auipc	ra,0x1
    31e2:	204080e7          	jalr	516(ra) # 43e2 <open>
  if(fd >= 0){
    31e6:	12055263          	bgez	a0,330a <dirfile+0x1fc>
  fd = open(".", 0);
    31ea:	4581                	li	a1,0
    31ec:	00002517          	auipc	a0,0x2
    31f0:	a4450513          	addi	a0,a0,-1468 # 4c30 <malloc+0x438>
    31f4:	00001097          	auipc	ra,0x1
    31f8:	1ee080e7          	jalr	494(ra) # 43e2 <open>
    31fc:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    31fe:	4605                	li	a2,1
    3200:	00002597          	auipc	a1,0x2
    3204:	49058593          	addi	a1,a1,1168 # 5690 <malloc+0xe98>
    3208:	00001097          	auipc	ra,0x1
    320c:	1ba080e7          	jalr	442(ra) # 43c2 <write>
    3210:	10a04b63          	bgtz	a0,3326 <dirfile+0x218>
  close(fd);
    3214:	8526                	mv	a0,s1
    3216:	00001097          	auipc	ra,0x1
    321a:	1b4080e7          	jalr	436(ra) # 43ca <close>
}
    321e:	60e2                	ld	ra,24(sp)
    3220:	6442                	ld	s0,16(sp)
    3222:	64a2                	ld	s1,8(sp)
    3224:	6902                	ld	s2,0(sp)
    3226:	6105                	addi	sp,sp,32
    3228:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    322a:	85ca                	mv	a1,s2
    322c:	00003517          	auipc	a0,0x3
    3230:	e1c50513          	addi	a0,a0,-484 # 6048 <malloc+0x1850>
    3234:	00001097          	auipc	ra,0x1
    3238:	506080e7          	jalr	1286(ra) # 473a <printf>
    exit(1);
    323c:	4505                	li	a0,1
    323e:	00001097          	auipc	ra,0x1
    3242:	164080e7          	jalr	356(ra) # 43a2 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3246:	85ca                	mv	a1,s2
    3248:	00003517          	auipc	a0,0x3
    324c:	e2050513          	addi	a0,a0,-480 # 6068 <malloc+0x1870>
    3250:	00001097          	auipc	ra,0x1
    3254:	4ea080e7          	jalr	1258(ra) # 473a <printf>
    exit(1);
    3258:	4505                	li	a0,1
    325a:	00001097          	auipc	ra,0x1
    325e:	148080e7          	jalr	328(ra) # 43a2 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3262:	85ca                	mv	a1,s2
    3264:	00003517          	auipc	a0,0x3
    3268:	e3450513          	addi	a0,a0,-460 # 6098 <malloc+0x18a0>
    326c:	00001097          	auipc	ra,0x1
    3270:	4ce080e7          	jalr	1230(ra) # 473a <printf>
    exit(1);
    3274:	4505                	li	a0,1
    3276:	00001097          	auipc	ra,0x1
    327a:	12c080e7          	jalr	300(ra) # 43a2 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    327e:	85ca                	mv	a1,s2
    3280:	00003517          	auipc	a0,0x3
    3284:	e1850513          	addi	a0,a0,-488 # 6098 <malloc+0x18a0>
    3288:	00001097          	auipc	ra,0x1
    328c:	4b2080e7          	jalr	1202(ra) # 473a <printf>
    exit(1);
    3290:	4505                	li	a0,1
    3292:	00001097          	auipc	ra,0x1
    3296:	110080e7          	jalr	272(ra) # 43a2 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    329a:	85ca                	mv	a1,s2
    329c:	00003517          	auipc	a0,0x3
    32a0:	e2450513          	addi	a0,a0,-476 # 60c0 <malloc+0x18c8>
    32a4:	00001097          	auipc	ra,0x1
    32a8:	496080e7          	jalr	1174(ra) # 473a <printf>
    exit(1);
    32ac:	4505                	li	a0,1
    32ae:	00001097          	auipc	ra,0x1
    32b2:	0f4080e7          	jalr	244(ra) # 43a2 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    32b6:	85ca                	mv	a1,s2
    32b8:	00003517          	auipc	a0,0x3
    32bc:	e3050513          	addi	a0,a0,-464 # 60e8 <malloc+0x18f0>
    32c0:	00001097          	auipc	ra,0x1
    32c4:	47a080e7          	jalr	1146(ra) # 473a <printf>
    exit(1);
    32c8:	4505                	li	a0,1
    32ca:	00001097          	auipc	ra,0x1
    32ce:	0d8080e7          	jalr	216(ra) # 43a2 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    32d2:	85ca                	mv	a1,s2
    32d4:	00003517          	auipc	a0,0x3
    32d8:	e4450513          	addi	a0,a0,-444 # 6118 <malloc+0x1920>
    32dc:	00001097          	auipc	ra,0x1
    32e0:	45e080e7          	jalr	1118(ra) # 473a <printf>
    exit(1);
    32e4:	4505                	li	a0,1
    32e6:	00001097          	auipc	ra,0x1
    32ea:	0bc080e7          	jalr	188(ra) # 43a2 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    32ee:	85ca                	mv	a1,s2
    32f0:	00003517          	auipc	a0,0x3
    32f4:	e5050513          	addi	a0,a0,-432 # 6140 <malloc+0x1948>
    32f8:	00001097          	auipc	ra,0x1
    32fc:	442080e7          	jalr	1090(ra) # 473a <printf>
    exit(1);
    3300:	4505                	li	a0,1
    3302:	00001097          	auipc	ra,0x1
    3306:	0a0080e7          	jalr	160(ra) # 43a2 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    330a:	85ca                	mv	a1,s2
    330c:	00003517          	auipc	a0,0x3
    3310:	e5450513          	addi	a0,a0,-428 # 6160 <malloc+0x1968>
    3314:	00001097          	auipc	ra,0x1
    3318:	426080e7          	jalr	1062(ra) # 473a <printf>
    exit(1);
    331c:	4505                	li	a0,1
    331e:	00001097          	auipc	ra,0x1
    3322:	084080e7          	jalr	132(ra) # 43a2 <exit>
    printf("%s: write . succeeded!\n", s);
    3326:	85ca                	mv	a1,s2
    3328:	00003517          	auipc	a0,0x3
    332c:	e6050513          	addi	a0,a0,-416 # 6188 <malloc+0x1990>
    3330:	00001097          	auipc	ra,0x1
    3334:	40a080e7          	jalr	1034(ra) # 473a <printf>
    exit(1);
    3338:	4505                	li	a0,1
    333a:	00001097          	auipc	ra,0x1
    333e:	068080e7          	jalr	104(ra) # 43a2 <exit>

0000000000003342 <iref>:
{
    3342:	7139                	addi	sp,sp,-64
    3344:	fc06                	sd	ra,56(sp)
    3346:	f822                	sd	s0,48(sp)
    3348:	f426                	sd	s1,40(sp)
    334a:	f04a                	sd	s2,32(sp)
    334c:	ec4e                	sd	s3,24(sp)
    334e:	e852                	sd	s4,16(sp)
    3350:	e456                	sd	s5,8(sp)
    3352:	e05a                	sd	s6,0(sp)
    3354:	0080                	addi	s0,sp,64
    3356:	8b2a                	mv	s6,a0
    3358:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    335c:	00003a17          	auipc	s4,0x3
    3360:	e44a0a13          	addi	s4,s4,-444 # 61a0 <malloc+0x19a8>
    mkdir("");
    3364:	00003497          	auipc	s1,0x3
    3368:	a1c48493          	addi	s1,s1,-1508 # 5d80 <malloc+0x1588>
    link("README", "");
    336c:	00003a97          	auipc	s5,0x3
    3370:	da4a8a93          	addi	s5,s5,-604 # 6110 <malloc+0x1918>
    fd = open("xx", O_CREATE);
    3374:	00003997          	auipc	s3,0x3
    3378:	d1c98993          	addi	s3,s3,-740 # 6090 <malloc+0x1898>
    337c:	a891                	j	33d0 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    337e:	85da                	mv	a1,s6
    3380:	00003517          	auipc	a0,0x3
    3384:	e2850513          	addi	a0,a0,-472 # 61a8 <malloc+0x19b0>
    3388:	00001097          	auipc	ra,0x1
    338c:	3b2080e7          	jalr	946(ra) # 473a <printf>
      exit(1);
    3390:	4505                	li	a0,1
    3392:	00001097          	auipc	ra,0x1
    3396:	010080e7          	jalr	16(ra) # 43a2 <exit>
      printf("%s: chdir irefd failed\n", s);
    339a:	85da                	mv	a1,s6
    339c:	00003517          	auipc	a0,0x3
    33a0:	e2450513          	addi	a0,a0,-476 # 61c0 <malloc+0x19c8>
    33a4:	00001097          	auipc	ra,0x1
    33a8:	396080e7          	jalr	918(ra) # 473a <printf>
      exit(1);
    33ac:	4505                	li	a0,1
    33ae:	00001097          	auipc	ra,0x1
    33b2:	ff4080e7          	jalr	-12(ra) # 43a2 <exit>
      close(fd);
    33b6:	00001097          	auipc	ra,0x1
    33ba:	014080e7          	jalr	20(ra) # 43ca <close>
    33be:	a889                	j	3410 <iref+0xce>
    unlink("xx");
    33c0:	854e                	mv	a0,s3
    33c2:	00001097          	auipc	ra,0x1
    33c6:	030080e7          	jalr	48(ra) # 43f2 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    33ca:	397d                	addiw	s2,s2,-1
    33cc:	06090063          	beqz	s2,342c <iref+0xea>
    if(mkdir("irefd") != 0){
    33d0:	8552                	mv	a0,s4
    33d2:	00001097          	auipc	ra,0x1
    33d6:	038080e7          	jalr	56(ra) # 440a <mkdir>
    33da:	f155                	bnez	a0,337e <iref+0x3c>
    if(chdir("irefd") != 0){
    33dc:	8552                	mv	a0,s4
    33de:	00001097          	auipc	ra,0x1
    33e2:	034080e7          	jalr	52(ra) # 4412 <chdir>
    33e6:	f955                	bnez	a0,339a <iref+0x58>
    mkdir("");
    33e8:	8526                	mv	a0,s1
    33ea:	00001097          	auipc	ra,0x1
    33ee:	020080e7          	jalr	32(ra) # 440a <mkdir>
    link("README", "");
    33f2:	85a6                	mv	a1,s1
    33f4:	8556                	mv	a0,s5
    33f6:	00001097          	auipc	ra,0x1
    33fa:	00c080e7          	jalr	12(ra) # 4402 <link>
    fd = open("", O_CREATE);
    33fe:	20000593          	li	a1,512
    3402:	8526                	mv	a0,s1
    3404:	00001097          	auipc	ra,0x1
    3408:	fde080e7          	jalr	-34(ra) # 43e2 <open>
    if(fd >= 0)
    340c:	fa0555e3          	bgez	a0,33b6 <iref+0x74>
    fd = open("xx", O_CREATE);
    3410:	20000593          	li	a1,512
    3414:	854e                	mv	a0,s3
    3416:	00001097          	auipc	ra,0x1
    341a:	fcc080e7          	jalr	-52(ra) # 43e2 <open>
    if(fd >= 0)
    341e:	fa0541e3          	bltz	a0,33c0 <iref+0x7e>
      close(fd);
    3422:	00001097          	auipc	ra,0x1
    3426:	fa8080e7          	jalr	-88(ra) # 43ca <close>
    342a:	bf59                	j	33c0 <iref+0x7e>
  chdir("/");
    342c:	00001517          	auipc	a0,0x1
    3430:	7ac50513          	addi	a0,a0,1964 # 4bd8 <malloc+0x3e0>
    3434:	00001097          	auipc	ra,0x1
    3438:	fde080e7          	jalr	-34(ra) # 4412 <chdir>
}
    343c:	70e2                	ld	ra,56(sp)
    343e:	7442                	ld	s0,48(sp)
    3440:	74a2                	ld	s1,40(sp)
    3442:	7902                	ld	s2,32(sp)
    3444:	69e2                	ld	s3,24(sp)
    3446:	6a42                	ld	s4,16(sp)
    3448:	6aa2                	ld	s5,8(sp)
    344a:	6b02                	ld	s6,0(sp)
    344c:	6121                	addi	sp,sp,64
    344e:	8082                	ret

0000000000003450 <validatetest>:
{
    3450:	7139                	addi	sp,sp,-64
    3452:	fc06                	sd	ra,56(sp)
    3454:	f822                	sd	s0,48(sp)
    3456:	f426                	sd	s1,40(sp)
    3458:	f04a                	sd	s2,32(sp)
    345a:	ec4e                	sd	s3,24(sp)
    345c:	e852                	sd	s4,16(sp)
    345e:	e456                	sd	s5,8(sp)
    3460:	e05a                	sd	s6,0(sp)
    3462:	0080                	addi	s0,sp,64
    3464:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    3466:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    3468:	00003997          	auipc	s3,0x3
    346c:	d7098993          	addi	s3,s3,-656 # 61d8 <malloc+0x19e0>
    3470:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    3472:	6a85                	lui	s5,0x1
    3474:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    3478:	85a6                	mv	a1,s1
    347a:	854e                	mv	a0,s3
    347c:	00001097          	auipc	ra,0x1
    3480:	f86080e7          	jalr	-122(ra) # 4402 <link>
    3484:	01251f63          	bne	a0,s2,34a2 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    3488:	94d6                	add	s1,s1,s5
    348a:	ff4497e3          	bne	s1,s4,3478 <validatetest+0x28>
}
    348e:	70e2                	ld	ra,56(sp)
    3490:	7442                	ld	s0,48(sp)
    3492:	74a2                	ld	s1,40(sp)
    3494:	7902                	ld	s2,32(sp)
    3496:	69e2                	ld	s3,24(sp)
    3498:	6a42                	ld	s4,16(sp)
    349a:	6aa2                	ld	s5,8(sp)
    349c:	6b02                	ld	s6,0(sp)
    349e:	6121                	addi	sp,sp,64
    34a0:	8082                	ret
      printf("%s: link should not succeed\n", s);
    34a2:	85da                	mv	a1,s6
    34a4:	00003517          	auipc	a0,0x3
    34a8:	d4450513          	addi	a0,a0,-700 # 61e8 <malloc+0x19f0>
    34ac:	00001097          	auipc	ra,0x1
    34b0:	28e080e7          	jalr	654(ra) # 473a <printf>
      exit(1);
    34b4:	4505                	li	a0,1
    34b6:	00001097          	auipc	ra,0x1
    34ba:	eec080e7          	jalr	-276(ra) # 43a2 <exit>

00000000000034be <sbrkmuch>:
{
    34be:	7179                	addi	sp,sp,-48
    34c0:	f406                	sd	ra,40(sp)
    34c2:	f022                	sd	s0,32(sp)
    34c4:	ec26                	sd	s1,24(sp)
    34c6:	e84a                	sd	s2,16(sp)
    34c8:	e44e                	sd	s3,8(sp)
    34ca:	e052                	sd	s4,0(sp)
    34cc:	1800                	addi	s0,sp,48
    34ce:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    34d0:	4501                	li	a0,0
    34d2:	00001097          	auipc	ra,0x1
    34d6:	f58080e7          	jalr	-168(ra) # 442a <sbrk>
    34da:	892a                	mv	s2,a0
  a = sbrk(0);
    34dc:	4501                	li	a0,0
    34de:	00001097          	auipc	ra,0x1
    34e2:	f4c080e7          	jalr	-180(ra) # 442a <sbrk>
    34e6:	84aa                	mv	s1,a0
  p = sbrk(amt);
    34e8:	06400537          	lui	a0,0x6400
    34ec:	9d05                	subw	a0,a0,s1
    34ee:	00001097          	auipc	ra,0x1
    34f2:	f3c080e7          	jalr	-196(ra) # 442a <sbrk>
  if (p != a) {
    34f6:	0aa49963          	bne	s1,a0,35a8 <sbrkmuch+0xea>
  *lastaddr = 99;
    34fa:	064007b7          	lui	a5,0x6400
    34fe:	06300713          	li	a4,99
    3502:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f3e6f>
  a = sbrk(0);
    3506:	4501                	li	a0,0
    3508:	00001097          	auipc	ra,0x1
    350c:	f22080e7          	jalr	-222(ra) # 442a <sbrk>
    3510:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    3512:	757d                	lui	a0,0xfffff
    3514:	00001097          	auipc	ra,0x1
    3518:	f16080e7          	jalr	-234(ra) # 442a <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    351c:	57fd                	li	a5,-1
    351e:	0af50363          	beq	a0,a5,35c4 <sbrkmuch+0x106>
  c = sbrk(0);
    3522:	4501                	li	a0,0
    3524:	00001097          	auipc	ra,0x1
    3528:	f06080e7          	jalr	-250(ra) # 442a <sbrk>
  if(c != a - PGSIZE){
    352c:	77fd                	lui	a5,0xfffff
    352e:	97a6                	add	a5,a5,s1
    3530:	0af51863          	bne	a0,a5,35e0 <sbrkmuch+0x122>
  a = sbrk(0);
    3534:	4501                	li	a0,0
    3536:	00001097          	auipc	ra,0x1
    353a:	ef4080e7          	jalr	-268(ra) # 442a <sbrk>
    353e:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    3540:	6505                	lui	a0,0x1
    3542:	00001097          	auipc	ra,0x1
    3546:	ee8080e7          	jalr	-280(ra) # 442a <sbrk>
    354a:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    354c:	0aa49963          	bne	s1,a0,35fe <sbrkmuch+0x140>
    3550:	4501                	li	a0,0
    3552:	00001097          	auipc	ra,0x1
    3556:	ed8080e7          	jalr	-296(ra) # 442a <sbrk>
    355a:	6785                	lui	a5,0x1
    355c:	97a6                	add	a5,a5,s1
    355e:	0af51063          	bne	a0,a5,35fe <sbrkmuch+0x140>
  if(*lastaddr == 99){
    3562:	064007b7          	lui	a5,0x6400
    3566:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f3e6f>
    356a:	06300793          	li	a5,99
    356e:	0af70763          	beq	a4,a5,361c <sbrkmuch+0x15e>
  a = sbrk(0);
    3572:	4501                	li	a0,0
    3574:	00001097          	auipc	ra,0x1
    3578:	eb6080e7          	jalr	-330(ra) # 442a <sbrk>
    357c:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    357e:	4501                	li	a0,0
    3580:	00001097          	auipc	ra,0x1
    3584:	eaa080e7          	jalr	-342(ra) # 442a <sbrk>
    3588:	40a9053b          	subw	a0,s2,a0
    358c:	00001097          	auipc	ra,0x1
    3590:	e9e080e7          	jalr	-354(ra) # 442a <sbrk>
  if(c != a){
    3594:	0aa49263          	bne	s1,a0,3638 <sbrkmuch+0x17a>
}
    3598:	70a2                	ld	ra,40(sp)
    359a:	7402                	ld	s0,32(sp)
    359c:	64e2                	ld	s1,24(sp)
    359e:	6942                	ld	s2,16(sp)
    35a0:	69a2                	ld	s3,8(sp)
    35a2:	6a02                	ld	s4,0(sp)
    35a4:	6145                	addi	sp,sp,48
    35a6:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    35a8:	85ce                	mv	a1,s3
    35aa:	00003517          	auipc	a0,0x3
    35ae:	c5e50513          	addi	a0,a0,-930 # 6208 <malloc+0x1a10>
    35b2:	00001097          	auipc	ra,0x1
    35b6:	188080e7          	jalr	392(ra) # 473a <printf>
    exit(1);
    35ba:	4505                	li	a0,1
    35bc:	00001097          	auipc	ra,0x1
    35c0:	de6080e7          	jalr	-538(ra) # 43a2 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    35c4:	85ce                	mv	a1,s3
    35c6:	00003517          	auipc	a0,0x3
    35ca:	c8a50513          	addi	a0,a0,-886 # 6250 <malloc+0x1a58>
    35ce:	00001097          	auipc	ra,0x1
    35d2:	16c080e7          	jalr	364(ra) # 473a <printf>
    exit(1);
    35d6:	4505                	li	a0,1
    35d8:	00001097          	auipc	ra,0x1
    35dc:	dca080e7          	jalr	-566(ra) # 43a2 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    35e0:	862a                	mv	a2,a0
    35e2:	85a6                	mv	a1,s1
    35e4:	00003517          	auipc	a0,0x3
    35e8:	c8c50513          	addi	a0,a0,-884 # 6270 <malloc+0x1a78>
    35ec:	00001097          	auipc	ra,0x1
    35f0:	14e080e7          	jalr	334(ra) # 473a <printf>
    exit(1);
    35f4:	4505                	li	a0,1
    35f6:	00001097          	auipc	ra,0x1
    35fa:	dac080e7          	jalr	-596(ra) # 43a2 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", a, c);
    35fe:	8652                	mv	a2,s4
    3600:	85a6                	mv	a1,s1
    3602:	00003517          	auipc	a0,0x3
    3606:	cae50513          	addi	a0,a0,-850 # 62b0 <malloc+0x1ab8>
    360a:	00001097          	auipc	ra,0x1
    360e:	130080e7          	jalr	304(ra) # 473a <printf>
    exit(1);
    3612:	4505                	li	a0,1
    3614:	00001097          	auipc	ra,0x1
    3618:	d8e080e7          	jalr	-626(ra) # 43a2 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    361c:	85ce                	mv	a1,s3
    361e:	00003517          	auipc	a0,0x3
    3622:	cc250513          	addi	a0,a0,-830 # 62e0 <malloc+0x1ae8>
    3626:	00001097          	auipc	ra,0x1
    362a:	114080e7          	jalr	276(ra) # 473a <printf>
    exit(1);
    362e:	4505                	li	a0,1
    3630:	00001097          	auipc	ra,0x1
    3634:	d72080e7          	jalr	-654(ra) # 43a2 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", a, c);
    3638:	862a                	mv	a2,a0
    363a:	85a6                	mv	a1,s1
    363c:	00003517          	auipc	a0,0x3
    3640:	cdc50513          	addi	a0,a0,-804 # 6318 <malloc+0x1b20>
    3644:	00001097          	auipc	ra,0x1
    3648:	0f6080e7          	jalr	246(ra) # 473a <printf>
    exit(1);
    364c:	4505                	li	a0,1
    364e:	00001097          	auipc	ra,0x1
    3652:	d54080e7          	jalr	-684(ra) # 43a2 <exit>

0000000000003656 <sbrkfail>:
{
    3656:	7119                	addi	sp,sp,-128
    3658:	fc86                	sd	ra,120(sp)
    365a:	f8a2                	sd	s0,112(sp)
    365c:	f4a6                	sd	s1,104(sp)
    365e:	f0ca                	sd	s2,96(sp)
    3660:	ecce                	sd	s3,88(sp)
    3662:	e8d2                	sd	s4,80(sp)
    3664:	e4d6                	sd	s5,72(sp)
    3666:	0100                	addi	s0,sp,128
    3668:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    366a:	fb040513          	addi	a0,s0,-80
    366e:	00001097          	auipc	ra,0x1
    3672:	d44080e7          	jalr	-700(ra) # 43b2 <pipe>
    3676:	e901                	bnez	a0,3686 <sbrkfail+0x30>
    3678:	f8040493          	addi	s1,s0,-128
    367c:	fa840993          	addi	s3,s0,-88
    3680:	8926                	mv	s2,s1
    if(pids[i] != -1)
    3682:	5a7d                	li	s4,-1
    3684:	a085                	j	36e4 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    3686:	85d6                	mv	a1,s5
    3688:	00002517          	auipc	a0,0x2
    368c:	f8850513          	addi	a0,a0,-120 # 5610 <malloc+0xe18>
    3690:	00001097          	auipc	ra,0x1
    3694:	0aa080e7          	jalr	170(ra) # 473a <printf>
    exit(1);
    3698:	4505                	li	a0,1
    369a:	00001097          	auipc	ra,0x1
    369e:	d08080e7          	jalr	-760(ra) # 43a2 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    36a2:	00001097          	auipc	ra,0x1
    36a6:	d88080e7          	jalr	-632(ra) # 442a <sbrk>
    36aa:	064007b7          	lui	a5,0x6400
    36ae:	40a7853b          	subw	a0,a5,a0
    36b2:	00001097          	auipc	ra,0x1
    36b6:	d78080e7          	jalr	-648(ra) # 442a <sbrk>
      write(fds[1], "x", 1);
    36ba:	4605                	li	a2,1
    36bc:	00002597          	auipc	a1,0x2
    36c0:	fd458593          	addi	a1,a1,-44 # 5690 <malloc+0xe98>
    36c4:	fb442503          	lw	a0,-76(s0)
    36c8:	00001097          	auipc	ra,0x1
    36cc:	cfa080e7          	jalr	-774(ra) # 43c2 <write>
      for(;;) sleep(1000);
    36d0:	3e800513          	li	a0,1000
    36d4:	00001097          	auipc	ra,0x1
    36d8:	d5e080e7          	jalr	-674(ra) # 4432 <sleep>
    36dc:	bfd5                	j	36d0 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    36de:	0911                	addi	s2,s2,4
    36e0:	03390563          	beq	s2,s3,370a <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    36e4:	00001097          	auipc	ra,0x1
    36e8:	cb6080e7          	jalr	-842(ra) # 439a <fork>
    36ec:	00a92023          	sw	a0,0(s2) # 3000 <subdir+0x6b8>
    36f0:	d94d                	beqz	a0,36a2 <sbrkfail+0x4c>
    if(pids[i] != -1)
    36f2:	ff4506e3          	beq	a0,s4,36de <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    36f6:	4605                	li	a2,1
    36f8:	faf40593          	addi	a1,s0,-81
    36fc:	fb042503          	lw	a0,-80(s0)
    3700:	00001097          	auipc	ra,0x1
    3704:	cba080e7          	jalr	-838(ra) # 43ba <read>
    3708:	bfd9                	j	36de <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    370a:	6505                	lui	a0,0x1
    370c:	00001097          	auipc	ra,0x1
    3710:	d1e080e7          	jalr	-738(ra) # 442a <sbrk>
    3714:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    3716:	597d                	li	s2,-1
    3718:	a021                	j	3720 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    371a:	0491                	addi	s1,s1,4
    371c:	01348f63          	beq	s1,s3,373a <sbrkfail+0xe4>
    if(pids[i] == -1)
    3720:	4088                	lw	a0,0(s1)
    3722:	ff250ce3          	beq	a0,s2,371a <sbrkfail+0xc4>
    kill(pids[i]);
    3726:	00001097          	auipc	ra,0x1
    372a:	cac080e7          	jalr	-852(ra) # 43d2 <kill>
    wait(0);
    372e:	4501                	li	a0,0
    3730:	00001097          	auipc	ra,0x1
    3734:	c7a080e7          	jalr	-902(ra) # 43aa <wait>
    3738:	b7cd                	j	371a <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    373a:	57fd                	li	a5,-1
    373c:	02fa0e63          	beq	s4,a5,3778 <sbrkfail+0x122>
  pid = fork();
    3740:	00001097          	auipc	ra,0x1
    3744:	c5a080e7          	jalr	-934(ra) # 439a <fork>
    3748:	84aa                	mv	s1,a0
  if(pid < 0){
    374a:	04054563          	bltz	a0,3794 <sbrkfail+0x13e>
  if(pid == 0){
    374e:	c12d                	beqz	a0,37b0 <sbrkfail+0x15a>
  wait(&xstatus);
    3750:	fbc40513          	addi	a0,s0,-68
    3754:	00001097          	auipc	ra,0x1
    3758:	c56080e7          	jalr	-938(ra) # 43aa <wait>
  if(xstatus != -1)
    375c:	fbc42703          	lw	a4,-68(s0)
    3760:	57fd                	li	a5,-1
    3762:	08f71c63          	bne	a4,a5,37fa <sbrkfail+0x1a4>
}
    3766:	70e6                	ld	ra,120(sp)
    3768:	7446                	ld	s0,112(sp)
    376a:	74a6                	ld	s1,104(sp)
    376c:	7906                	ld	s2,96(sp)
    376e:	69e6                	ld	s3,88(sp)
    3770:	6a46                	ld	s4,80(sp)
    3772:	6aa6                	ld	s5,72(sp)
    3774:	6109                	addi	sp,sp,128
    3776:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    3778:	85d6                	mv	a1,s5
    377a:	00003517          	auipc	a0,0x3
    377e:	bc650513          	addi	a0,a0,-1082 # 6340 <malloc+0x1b48>
    3782:	00001097          	auipc	ra,0x1
    3786:	fb8080e7          	jalr	-72(ra) # 473a <printf>
    exit(1);
    378a:	4505                	li	a0,1
    378c:	00001097          	auipc	ra,0x1
    3790:	c16080e7          	jalr	-1002(ra) # 43a2 <exit>
    printf("%s: fork failed\n", s);
    3794:	85d6                	mv	a1,s5
    3796:	00001517          	auipc	a0,0x1
    379a:	54a50513          	addi	a0,a0,1354 # 4ce0 <malloc+0x4e8>
    379e:	00001097          	auipc	ra,0x1
    37a2:	f9c080e7          	jalr	-100(ra) # 473a <printf>
    exit(1);
    37a6:	4505                	li	a0,1
    37a8:	00001097          	auipc	ra,0x1
    37ac:	bfa080e7          	jalr	-1030(ra) # 43a2 <exit>
    a = sbrk(0);
    37b0:	4501                	li	a0,0
    37b2:	00001097          	auipc	ra,0x1
    37b6:	c78080e7          	jalr	-904(ra) # 442a <sbrk>
    37ba:	892a                	mv	s2,a0
    sbrk(10*BIG);
    37bc:	3e800537          	lui	a0,0x3e800
    37c0:	00001097          	auipc	ra,0x1
    37c4:	c6a080e7          	jalr	-918(ra) # 442a <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    37c8:	87ca                	mv	a5,s2
    37ca:	3e800737          	lui	a4,0x3e800
    37ce:	993a                	add	s2,s2,a4
    37d0:	6705                	lui	a4,0x1
      n += *(a+i);
    37d2:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f3e70>
    37d6:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    37d8:	97ba                	add	a5,a5,a4
    37da:	ff279ce3          	bne	a5,s2,37d2 <sbrkfail+0x17c>
    printf("%s: allocate a lot of memory succeeded %d\n", n);
    37de:	85a6                	mv	a1,s1
    37e0:	00003517          	auipc	a0,0x3
    37e4:	b8050513          	addi	a0,a0,-1152 # 6360 <malloc+0x1b68>
    37e8:	00001097          	auipc	ra,0x1
    37ec:	f52080e7          	jalr	-174(ra) # 473a <printf>
    exit(1);
    37f0:	4505                	li	a0,1
    37f2:	00001097          	auipc	ra,0x1
    37f6:	bb0080e7          	jalr	-1104(ra) # 43a2 <exit>
    exit(1);
    37fa:	4505                	li	a0,1
    37fc:	00001097          	auipc	ra,0x1
    3800:	ba6080e7          	jalr	-1114(ra) # 43a2 <exit>

0000000000003804 <sbrkarg>:
{
    3804:	7179                	addi	sp,sp,-48
    3806:	f406                	sd	ra,40(sp)
    3808:	f022                	sd	s0,32(sp)
    380a:	ec26                	sd	s1,24(sp)
    380c:	e84a                	sd	s2,16(sp)
    380e:	e44e                	sd	s3,8(sp)
    3810:	1800                	addi	s0,sp,48
    3812:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    3814:	6505                	lui	a0,0x1
    3816:	00001097          	auipc	ra,0x1
    381a:	c14080e7          	jalr	-1004(ra) # 442a <sbrk>
    381e:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    3820:	20100593          	li	a1,513
    3824:	00003517          	auipc	a0,0x3
    3828:	b6c50513          	addi	a0,a0,-1172 # 6390 <malloc+0x1b98>
    382c:	00001097          	auipc	ra,0x1
    3830:	bb6080e7          	jalr	-1098(ra) # 43e2 <open>
    3834:	84aa                	mv	s1,a0
  unlink("sbrk");
    3836:	00003517          	auipc	a0,0x3
    383a:	b5a50513          	addi	a0,a0,-1190 # 6390 <malloc+0x1b98>
    383e:	00001097          	auipc	ra,0x1
    3842:	bb4080e7          	jalr	-1100(ra) # 43f2 <unlink>
  if(fd < 0)  {
    3846:	0404c163          	bltz	s1,3888 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    384a:	6605                	lui	a2,0x1
    384c:	85ca                	mv	a1,s2
    384e:	8526                	mv	a0,s1
    3850:	00001097          	auipc	ra,0x1
    3854:	b72080e7          	jalr	-1166(ra) # 43c2 <write>
    3858:	04054663          	bltz	a0,38a4 <sbrkarg+0xa0>
  close(fd);
    385c:	8526                	mv	a0,s1
    385e:	00001097          	auipc	ra,0x1
    3862:	b6c080e7          	jalr	-1172(ra) # 43ca <close>
  a = sbrk(PGSIZE);
    3866:	6505                	lui	a0,0x1
    3868:	00001097          	auipc	ra,0x1
    386c:	bc2080e7          	jalr	-1086(ra) # 442a <sbrk>
  if(pipe((int *) a) != 0){
    3870:	00001097          	auipc	ra,0x1
    3874:	b42080e7          	jalr	-1214(ra) # 43b2 <pipe>
    3878:	e521                	bnez	a0,38c0 <sbrkarg+0xbc>
}
    387a:	70a2                	ld	ra,40(sp)
    387c:	7402                	ld	s0,32(sp)
    387e:	64e2                	ld	s1,24(sp)
    3880:	6942                	ld	s2,16(sp)
    3882:	69a2                	ld	s3,8(sp)
    3884:	6145                	addi	sp,sp,48
    3886:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    3888:	85ce                	mv	a1,s3
    388a:	00003517          	auipc	a0,0x3
    388e:	b0e50513          	addi	a0,a0,-1266 # 6398 <malloc+0x1ba0>
    3892:	00001097          	auipc	ra,0x1
    3896:	ea8080e7          	jalr	-344(ra) # 473a <printf>
    exit(1);
    389a:	4505                	li	a0,1
    389c:	00001097          	auipc	ra,0x1
    38a0:	b06080e7          	jalr	-1274(ra) # 43a2 <exit>
    printf("%s: write sbrk failed\n", s);
    38a4:	85ce                	mv	a1,s3
    38a6:	00003517          	auipc	a0,0x3
    38aa:	b0a50513          	addi	a0,a0,-1270 # 63b0 <malloc+0x1bb8>
    38ae:	00001097          	auipc	ra,0x1
    38b2:	e8c080e7          	jalr	-372(ra) # 473a <printf>
    exit(1);
    38b6:	4505                	li	a0,1
    38b8:	00001097          	auipc	ra,0x1
    38bc:	aea080e7          	jalr	-1302(ra) # 43a2 <exit>
    printf("%s: pipe() failed\n", s);
    38c0:	85ce                	mv	a1,s3
    38c2:	00002517          	auipc	a0,0x2
    38c6:	d4e50513          	addi	a0,a0,-690 # 5610 <malloc+0xe18>
    38ca:	00001097          	auipc	ra,0x1
    38ce:	e70080e7          	jalr	-400(ra) # 473a <printf>
    exit(1);
    38d2:	4505                	li	a0,1
    38d4:	00001097          	auipc	ra,0x1
    38d8:	ace080e7          	jalr	-1330(ra) # 43a2 <exit>

00000000000038dc <argptest>:
{
    38dc:	1101                	addi	sp,sp,-32
    38de:	ec06                	sd	ra,24(sp)
    38e0:	e822                	sd	s0,16(sp)
    38e2:	e426                	sd	s1,8(sp)
    38e4:	e04a                	sd	s2,0(sp)
    38e6:	1000                	addi	s0,sp,32
    38e8:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    38ea:	4581                	li	a1,0
    38ec:	00003517          	auipc	a0,0x3
    38f0:	adc50513          	addi	a0,a0,-1316 # 63c8 <malloc+0x1bd0>
    38f4:	00001097          	auipc	ra,0x1
    38f8:	aee080e7          	jalr	-1298(ra) # 43e2 <open>
  if (fd < 0) {
    38fc:	02054b63          	bltz	a0,3932 <argptest+0x56>
    3900:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    3902:	4501                	li	a0,0
    3904:	00001097          	auipc	ra,0x1
    3908:	b26080e7          	jalr	-1242(ra) # 442a <sbrk>
    390c:	567d                	li	a2,-1
    390e:	fff50593          	addi	a1,a0,-1
    3912:	8526                	mv	a0,s1
    3914:	00001097          	auipc	ra,0x1
    3918:	aa6080e7          	jalr	-1370(ra) # 43ba <read>
  close(fd);
    391c:	8526                	mv	a0,s1
    391e:	00001097          	auipc	ra,0x1
    3922:	aac080e7          	jalr	-1364(ra) # 43ca <close>
}
    3926:	60e2                	ld	ra,24(sp)
    3928:	6442                	ld	s0,16(sp)
    392a:	64a2                	ld	s1,8(sp)
    392c:	6902                	ld	s2,0(sp)
    392e:	6105                	addi	sp,sp,32
    3930:	8082                	ret
    printf("%s: open failed\n", s);
    3932:	85ca                	mv	a1,s2
    3934:	00002517          	auipc	a0,0x2
    3938:	b7c50513          	addi	a0,a0,-1156 # 54b0 <malloc+0xcb8>
    393c:	00001097          	auipc	ra,0x1
    3940:	dfe080e7          	jalr	-514(ra) # 473a <printf>
    exit(1);
    3944:	4505                	li	a0,1
    3946:	00001097          	auipc	ra,0x1
    394a:	a5c080e7          	jalr	-1444(ra) # 43a2 <exit>

000000000000394e <sbrkbugs>:
{
    394e:	1141                	addi	sp,sp,-16
    3950:	e406                	sd	ra,8(sp)
    3952:	e022                	sd	s0,0(sp)
    3954:	0800                	addi	s0,sp,16
  int pid = fork();
    3956:	00001097          	auipc	ra,0x1
    395a:	a44080e7          	jalr	-1468(ra) # 439a <fork>
  if(pid < 0){
    395e:	02054263          	bltz	a0,3982 <sbrkbugs+0x34>
  if(pid == 0){
    3962:	ed0d                	bnez	a0,399c <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    3964:	00001097          	auipc	ra,0x1
    3968:	ac6080e7          	jalr	-1338(ra) # 442a <sbrk>
    sbrk(-sz);
    396c:	40a0053b          	negw	a0,a0
    3970:	00001097          	auipc	ra,0x1
    3974:	aba080e7          	jalr	-1350(ra) # 442a <sbrk>
    exit(0);
    3978:	4501                	li	a0,0
    397a:	00001097          	auipc	ra,0x1
    397e:	a28080e7          	jalr	-1496(ra) # 43a2 <exit>
    printf("fork failed\n");
    3982:	00002517          	auipc	a0,0x2
    3986:	c5e50513          	addi	a0,a0,-930 # 55e0 <malloc+0xde8>
    398a:	00001097          	auipc	ra,0x1
    398e:	db0080e7          	jalr	-592(ra) # 473a <printf>
    exit(1);
    3992:	4505                	li	a0,1
    3994:	00001097          	auipc	ra,0x1
    3998:	a0e080e7          	jalr	-1522(ra) # 43a2 <exit>
  wait(0);
    399c:	4501                	li	a0,0
    399e:	00001097          	auipc	ra,0x1
    39a2:	a0c080e7          	jalr	-1524(ra) # 43aa <wait>
  pid = fork();
    39a6:	00001097          	auipc	ra,0x1
    39aa:	9f4080e7          	jalr	-1548(ra) # 439a <fork>
  if(pid < 0){
    39ae:	02054563          	bltz	a0,39d8 <sbrkbugs+0x8a>
  if(pid == 0){
    39b2:	e121                	bnez	a0,39f2 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    39b4:	00001097          	auipc	ra,0x1
    39b8:	a76080e7          	jalr	-1418(ra) # 442a <sbrk>
    sbrk(-(sz - 3500));
    39bc:	6785                	lui	a5,0x1
    39be:	dac7879b          	addiw	a5,a5,-596
    39c2:	40a7853b          	subw	a0,a5,a0
    39c6:	00001097          	auipc	ra,0x1
    39ca:	a64080e7          	jalr	-1436(ra) # 442a <sbrk>
    exit(0);
    39ce:	4501                	li	a0,0
    39d0:	00001097          	auipc	ra,0x1
    39d4:	9d2080e7          	jalr	-1582(ra) # 43a2 <exit>
    printf("fork failed\n");
    39d8:	00002517          	auipc	a0,0x2
    39dc:	c0850513          	addi	a0,a0,-1016 # 55e0 <malloc+0xde8>
    39e0:	00001097          	auipc	ra,0x1
    39e4:	d5a080e7          	jalr	-678(ra) # 473a <printf>
    exit(1);
    39e8:	4505                	li	a0,1
    39ea:	00001097          	auipc	ra,0x1
    39ee:	9b8080e7          	jalr	-1608(ra) # 43a2 <exit>
  wait(0);
    39f2:	4501                	li	a0,0
    39f4:	00001097          	auipc	ra,0x1
    39f8:	9b6080e7          	jalr	-1610(ra) # 43aa <wait>
  pid = fork();
    39fc:	00001097          	auipc	ra,0x1
    3a00:	99e080e7          	jalr	-1634(ra) # 439a <fork>
  if(pid < 0){
    3a04:	02054a63          	bltz	a0,3a38 <sbrkbugs+0xea>
  if(pid == 0){
    3a08:	e529                	bnez	a0,3a52 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    3a0a:	00001097          	auipc	ra,0x1
    3a0e:	a20080e7          	jalr	-1504(ra) # 442a <sbrk>
    3a12:	67ad                	lui	a5,0xb
    3a14:	8007879b          	addiw	a5,a5,-2048
    3a18:	40a7853b          	subw	a0,a5,a0
    3a1c:	00001097          	auipc	ra,0x1
    3a20:	a0e080e7          	jalr	-1522(ra) # 442a <sbrk>
    sbrk(-10);
    3a24:	5559                	li	a0,-10
    3a26:	00001097          	auipc	ra,0x1
    3a2a:	a04080e7          	jalr	-1532(ra) # 442a <sbrk>
    exit(0);
    3a2e:	4501                	li	a0,0
    3a30:	00001097          	auipc	ra,0x1
    3a34:	972080e7          	jalr	-1678(ra) # 43a2 <exit>
    printf("fork failed\n");
    3a38:	00002517          	auipc	a0,0x2
    3a3c:	ba850513          	addi	a0,a0,-1112 # 55e0 <malloc+0xde8>
    3a40:	00001097          	auipc	ra,0x1
    3a44:	cfa080e7          	jalr	-774(ra) # 473a <printf>
    exit(1);
    3a48:	4505                	li	a0,1
    3a4a:	00001097          	auipc	ra,0x1
    3a4e:	958080e7          	jalr	-1704(ra) # 43a2 <exit>
  wait(0);
    3a52:	4501                	li	a0,0
    3a54:	00001097          	auipc	ra,0x1
    3a58:	956080e7          	jalr	-1706(ra) # 43aa <wait>
  exit(0);
    3a5c:	4501                	li	a0,0
    3a5e:	00001097          	auipc	ra,0x1
    3a62:	944080e7          	jalr	-1724(ra) # 43a2 <exit>

0000000000003a66 <dirtest>:
{
    3a66:	1101                	addi	sp,sp,-32
    3a68:	ec06                	sd	ra,24(sp)
    3a6a:	e822                	sd	s0,16(sp)
    3a6c:	e426                	sd	s1,8(sp)
    3a6e:	1000                	addi	s0,sp,32
    3a70:	84aa                	mv	s1,a0
  printf("mkdir test\n");
    3a72:	00003517          	auipc	a0,0x3
    3a76:	95e50513          	addi	a0,a0,-1698 # 63d0 <malloc+0x1bd8>
    3a7a:	00001097          	auipc	ra,0x1
    3a7e:	cc0080e7          	jalr	-832(ra) # 473a <printf>
  if(mkdir("dir0") < 0){
    3a82:	00003517          	auipc	a0,0x3
    3a86:	95e50513          	addi	a0,a0,-1698 # 63e0 <malloc+0x1be8>
    3a8a:	00001097          	auipc	ra,0x1
    3a8e:	980080e7          	jalr	-1664(ra) # 440a <mkdir>
    3a92:	04054d63          	bltz	a0,3aec <dirtest+0x86>
  if(chdir("dir0") < 0){
    3a96:	00003517          	auipc	a0,0x3
    3a9a:	94a50513          	addi	a0,a0,-1718 # 63e0 <malloc+0x1be8>
    3a9e:	00001097          	auipc	ra,0x1
    3aa2:	974080e7          	jalr	-1676(ra) # 4412 <chdir>
    3aa6:	06054163          	bltz	a0,3b08 <dirtest+0xa2>
  if(chdir("..") < 0){
    3aaa:	00001517          	auipc	a0,0x1
    3aae:	1a650513          	addi	a0,a0,422 # 4c50 <malloc+0x458>
    3ab2:	00001097          	auipc	ra,0x1
    3ab6:	960080e7          	jalr	-1696(ra) # 4412 <chdir>
    3aba:	06054563          	bltz	a0,3b24 <dirtest+0xbe>
  if(unlink("dir0") < 0){
    3abe:	00003517          	auipc	a0,0x3
    3ac2:	92250513          	addi	a0,a0,-1758 # 63e0 <malloc+0x1be8>
    3ac6:	00001097          	auipc	ra,0x1
    3aca:	92c080e7          	jalr	-1748(ra) # 43f2 <unlink>
    3ace:	06054963          	bltz	a0,3b40 <dirtest+0xda>
  printf("%s: mkdir test ok\n");
    3ad2:	00003517          	auipc	a0,0x3
    3ad6:	95e50513          	addi	a0,a0,-1698 # 6430 <malloc+0x1c38>
    3ada:	00001097          	auipc	ra,0x1
    3ade:	c60080e7          	jalr	-928(ra) # 473a <printf>
}
    3ae2:	60e2                	ld	ra,24(sp)
    3ae4:	6442                	ld	s0,16(sp)
    3ae6:	64a2                	ld	s1,8(sp)
    3ae8:	6105                	addi	sp,sp,32
    3aea:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3aec:	85a6                	mv	a1,s1
    3aee:	00001517          	auipc	a0,0x1
    3af2:	08250513          	addi	a0,a0,130 # 4b70 <malloc+0x378>
    3af6:	00001097          	auipc	ra,0x1
    3afa:	c44080e7          	jalr	-956(ra) # 473a <printf>
    exit(1);
    3afe:	4505                	li	a0,1
    3b00:	00001097          	auipc	ra,0x1
    3b04:	8a2080e7          	jalr	-1886(ra) # 43a2 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3b08:	85a6                	mv	a1,s1
    3b0a:	00003517          	auipc	a0,0x3
    3b0e:	8de50513          	addi	a0,a0,-1826 # 63e8 <malloc+0x1bf0>
    3b12:	00001097          	auipc	ra,0x1
    3b16:	c28080e7          	jalr	-984(ra) # 473a <printf>
    exit(1);
    3b1a:	4505                	li	a0,1
    3b1c:	00001097          	auipc	ra,0x1
    3b20:	886080e7          	jalr	-1914(ra) # 43a2 <exit>
    printf("%s: chdir .. failed\n", s);
    3b24:	85a6                	mv	a1,s1
    3b26:	00003517          	auipc	a0,0x3
    3b2a:	8da50513          	addi	a0,a0,-1830 # 6400 <malloc+0x1c08>
    3b2e:	00001097          	auipc	ra,0x1
    3b32:	c0c080e7          	jalr	-1012(ra) # 473a <printf>
    exit(1);
    3b36:	4505                	li	a0,1
    3b38:	00001097          	auipc	ra,0x1
    3b3c:	86a080e7          	jalr	-1942(ra) # 43a2 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3b40:	85a6                	mv	a1,s1
    3b42:	00003517          	auipc	a0,0x3
    3b46:	8d650513          	addi	a0,a0,-1834 # 6418 <malloc+0x1c20>
    3b4a:	00001097          	auipc	ra,0x1
    3b4e:	bf0080e7          	jalr	-1040(ra) # 473a <printf>
    exit(1);
    3b52:	4505                	li	a0,1
    3b54:	00001097          	auipc	ra,0x1
    3b58:	84e080e7          	jalr	-1970(ra) # 43a2 <exit>

0000000000003b5c <mem>:
{
    3b5c:	7139                	addi	sp,sp,-64
    3b5e:	fc06                	sd	ra,56(sp)
    3b60:	f822                	sd	s0,48(sp)
    3b62:	f426                	sd	s1,40(sp)
    3b64:	f04a                	sd	s2,32(sp)
    3b66:	ec4e                	sd	s3,24(sp)
    3b68:	0080                	addi	s0,sp,64
    3b6a:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    3b6c:	00001097          	auipc	ra,0x1
    3b70:	82e080e7          	jalr	-2002(ra) # 439a <fork>
    m1 = 0;
    3b74:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    3b76:	6909                	lui	s2,0x2
    3b78:	71190913          	addi	s2,s2,1809 # 2711 <linkunlink+0x2b>
  if((pid = fork()) == 0){
    3b7c:	cd19                	beqz	a0,3b9a <mem+0x3e>
    wait(&xstatus);
    3b7e:	fcc40513          	addi	a0,s0,-52
    3b82:	00001097          	auipc	ra,0x1
    3b86:	828080e7          	jalr	-2008(ra) # 43aa <wait>
    exit(xstatus);
    3b8a:	fcc42503          	lw	a0,-52(s0)
    3b8e:	00001097          	auipc	ra,0x1
    3b92:	814080e7          	jalr	-2028(ra) # 43a2 <exit>
      *(char**)m2 = m1;
    3b96:	e104                	sd	s1,0(a0)
      m1 = m2;
    3b98:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    3b9a:	854a                	mv	a0,s2
    3b9c:	00001097          	auipc	ra,0x1
    3ba0:	c5c080e7          	jalr	-932(ra) # 47f8 <malloc>
    3ba4:	f96d                	bnez	a0,3b96 <mem+0x3a>
    while(m1){
    3ba6:	c881                	beqz	s1,3bb6 <mem+0x5a>
      m2 = *(char**)m1;
    3ba8:	8526                	mv	a0,s1
    3baa:	6084                	ld	s1,0(s1)
      free(m1);
    3bac:	00001097          	auipc	ra,0x1
    3bb0:	bc4080e7          	jalr	-1084(ra) # 4770 <free>
    while(m1){
    3bb4:	f8f5                	bnez	s1,3ba8 <mem+0x4c>
    m1 = malloc(1024*20);
    3bb6:	6515                	lui	a0,0x5
    3bb8:	00001097          	auipc	ra,0x1
    3bbc:	c40080e7          	jalr	-960(ra) # 47f8 <malloc>
    if(m1 == 0){
    3bc0:	c911                	beqz	a0,3bd4 <mem+0x78>
    free(m1);
    3bc2:	00001097          	auipc	ra,0x1
    3bc6:	bae080e7          	jalr	-1106(ra) # 4770 <free>
    exit(0);
    3bca:	4501                	li	a0,0
    3bcc:	00000097          	auipc	ra,0x0
    3bd0:	7d6080e7          	jalr	2006(ra) # 43a2 <exit>
      printf("couldn't allocate mem?!!\n", s);
    3bd4:	85ce                	mv	a1,s3
    3bd6:	00003517          	auipc	a0,0x3
    3bda:	87250513          	addi	a0,a0,-1934 # 6448 <malloc+0x1c50>
    3bde:	00001097          	auipc	ra,0x1
    3be2:	b5c080e7          	jalr	-1188(ra) # 473a <printf>
      exit(1);
    3be6:	4505                	li	a0,1
    3be8:	00000097          	auipc	ra,0x0
    3bec:	7ba080e7          	jalr	1978(ra) # 43a2 <exit>

0000000000003bf0 <sbrkbasic>:
{
    3bf0:	7139                	addi	sp,sp,-64
    3bf2:	fc06                	sd	ra,56(sp)
    3bf4:	f822                	sd	s0,48(sp)
    3bf6:	f426                	sd	s1,40(sp)
    3bf8:	f04a                	sd	s2,32(sp)
    3bfa:	ec4e                	sd	s3,24(sp)
    3bfc:	e852                	sd	s4,16(sp)
    3bfe:	0080                	addi	s0,sp,64
    3c00:	8a2a                	mv	s4,a0
  a = sbrk(TOOMUCH);
    3c02:	40000537          	lui	a0,0x40000
    3c06:	00001097          	auipc	ra,0x1
    3c0a:	824080e7          	jalr	-2012(ra) # 442a <sbrk>
  if(a != (char*)0xffffffffffffffffL){
    3c0e:	57fd                	li	a5,-1
    3c10:	02f50063          	beq	a0,a5,3c30 <sbrkbasic+0x40>
    3c14:	85aa                	mv	a1,a0
    printf("%s: sbrk(<toomuch>) returned %p\n", a);
    3c16:	00003517          	auipc	a0,0x3
    3c1a:	85250513          	addi	a0,a0,-1966 # 6468 <malloc+0x1c70>
    3c1e:	00001097          	auipc	ra,0x1
    3c22:	b1c080e7          	jalr	-1252(ra) # 473a <printf>
    exit(1);
    3c26:	4505                	li	a0,1
    3c28:	00000097          	auipc	ra,0x0
    3c2c:	77a080e7          	jalr	1914(ra) # 43a2 <exit>
  a = sbrk(0);
    3c30:	4501                	li	a0,0
    3c32:	00000097          	auipc	ra,0x0
    3c36:	7f8080e7          	jalr	2040(ra) # 442a <sbrk>
    3c3a:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    3c3c:	4901                	li	s2,0
    3c3e:	6985                	lui	s3,0x1
    3c40:	38898993          	addi	s3,s3,904 # 1388 <unlinkread+0x10e>
    3c44:	a011                	j	3c48 <sbrkbasic+0x58>
    a = b + 1;
    3c46:	84be                	mv	s1,a5
    b = sbrk(1);
    3c48:	4505                	li	a0,1
    3c4a:	00000097          	auipc	ra,0x0
    3c4e:	7e0080e7          	jalr	2016(ra) # 442a <sbrk>
    if(b != a){
    3c52:	04951c63          	bne	a0,s1,3caa <sbrkbasic+0xba>
    *b = 1;
    3c56:	4785                	li	a5,1
    3c58:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    3c5c:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    3c60:	2905                	addiw	s2,s2,1
    3c62:	ff3912e3          	bne	s2,s3,3c46 <sbrkbasic+0x56>
  pid = fork();
    3c66:	00000097          	auipc	ra,0x0
    3c6a:	734080e7          	jalr	1844(ra) # 439a <fork>
    3c6e:	892a                	mv	s2,a0
  if(pid < 0){
    3c70:	04054d63          	bltz	a0,3cca <sbrkbasic+0xda>
  c = sbrk(1);
    3c74:	4505                	li	a0,1
    3c76:	00000097          	auipc	ra,0x0
    3c7a:	7b4080e7          	jalr	1972(ra) # 442a <sbrk>
  c = sbrk(1);
    3c7e:	4505                	li	a0,1
    3c80:	00000097          	auipc	ra,0x0
    3c84:	7aa080e7          	jalr	1962(ra) # 442a <sbrk>
  if(c != a + 1){
    3c88:	0489                	addi	s1,s1,2
    3c8a:	04a48e63          	beq	s1,a0,3ce6 <sbrkbasic+0xf6>
    printf("%s: sbrk test failed post-fork\n", s);
    3c8e:	85d2                	mv	a1,s4
    3c90:	00003517          	auipc	a0,0x3
    3c94:	84050513          	addi	a0,a0,-1984 # 64d0 <malloc+0x1cd8>
    3c98:	00001097          	auipc	ra,0x1
    3c9c:	aa2080e7          	jalr	-1374(ra) # 473a <printf>
    exit(1);
    3ca0:	4505                	li	a0,1
    3ca2:	00000097          	auipc	ra,0x0
    3ca6:	700080e7          	jalr	1792(ra) # 43a2 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    3caa:	86aa                	mv	a3,a0
    3cac:	8626                	mv	a2,s1
    3cae:	85ca                	mv	a1,s2
    3cb0:	00002517          	auipc	a0,0x2
    3cb4:	7e050513          	addi	a0,a0,2016 # 6490 <malloc+0x1c98>
    3cb8:	00001097          	auipc	ra,0x1
    3cbc:	a82080e7          	jalr	-1406(ra) # 473a <printf>
      exit(1);
    3cc0:	4505                	li	a0,1
    3cc2:	00000097          	auipc	ra,0x0
    3cc6:	6e0080e7          	jalr	1760(ra) # 43a2 <exit>
    printf("%s: sbrk test fork failed\n", s);
    3cca:	85d2                	mv	a1,s4
    3ccc:	00002517          	auipc	a0,0x2
    3cd0:	7e450513          	addi	a0,a0,2020 # 64b0 <malloc+0x1cb8>
    3cd4:	00001097          	auipc	ra,0x1
    3cd8:	a66080e7          	jalr	-1434(ra) # 473a <printf>
    exit(1);
    3cdc:	4505                	li	a0,1
    3cde:	00000097          	auipc	ra,0x0
    3ce2:	6c4080e7          	jalr	1732(ra) # 43a2 <exit>
  if(pid == 0)
    3ce6:	00091763          	bnez	s2,3cf4 <sbrkbasic+0x104>
    exit(0);
    3cea:	4501                	li	a0,0
    3cec:	00000097          	auipc	ra,0x0
    3cf0:	6b6080e7          	jalr	1718(ra) # 43a2 <exit>
  wait(&xstatus);
    3cf4:	fcc40513          	addi	a0,s0,-52
    3cf8:	00000097          	auipc	ra,0x0
    3cfc:	6b2080e7          	jalr	1714(ra) # 43aa <wait>
  exit(xstatus);
    3d00:	fcc42503          	lw	a0,-52(s0)
    3d04:	00000097          	auipc	ra,0x0
    3d08:	69e080e7          	jalr	1694(ra) # 43a2 <exit>

0000000000003d0c <fsfull>:
{
    3d0c:	7171                	addi	sp,sp,-176
    3d0e:	f506                	sd	ra,168(sp)
    3d10:	f122                	sd	s0,160(sp)
    3d12:	ed26                	sd	s1,152(sp)
    3d14:	e94a                	sd	s2,144(sp)
    3d16:	e54e                	sd	s3,136(sp)
    3d18:	e152                	sd	s4,128(sp)
    3d1a:	fcd6                	sd	s5,120(sp)
    3d1c:	f8da                	sd	s6,112(sp)
    3d1e:	f4de                	sd	s7,104(sp)
    3d20:	f0e2                	sd	s8,96(sp)
    3d22:	ece6                	sd	s9,88(sp)
    3d24:	e8ea                	sd	s10,80(sp)
    3d26:	e4ee                	sd	s11,72(sp)
    3d28:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    3d2a:	00002517          	auipc	a0,0x2
    3d2e:	7c650513          	addi	a0,a0,1990 # 64f0 <malloc+0x1cf8>
    3d32:	00001097          	auipc	ra,0x1
    3d36:	a08080e7          	jalr	-1528(ra) # 473a <printf>
  for(nfiles = 0; ; nfiles++){
    3d3a:	4481                	li	s1,0
    name[0] = 'f';
    3d3c:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    3d40:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    3d44:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    3d48:	4b29                	li	s6,10
    printf("%s: writing %s\n", name);
    3d4a:	00002c97          	auipc	s9,0x2
    3d4e:	7b6c8c93          	addi	s9,s9,1974 # 6500 <malloc+0x1d08>
    int total = 0;
    3d52:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    3d54:	00005a17          	auipc	s4,0x5
    3d58:	42ca0a13          	addi	s4,s4,1068 # 9180 <buf>
    name[0] = 'f';
    3d5c:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    3d60:	0384c7bb          	divw	a5,s1,s8
    3d64:	0307879b          	addiw	a5,a5,48
    3d68:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    3d6c:	0384e7bb          	remw	a5,s1,s8
    3d70:	0377c7bb          	divw	a5,a5,s7
    3d74:	0307879b          	addiw	a5,a5,48
    3d78:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    3d7c:	0374e7bb          	remw	a5,s1,s7
    3d80:	0367c7bb          	divw	a5,a5,s6
    3d84:	0307879b          	addiw	a5,a5,48
    3d88:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    3d8c:	0364e7bb          	remw	a5,s1,s6
    3d90:	0307879b          	addiw	a5,a5,48
    3d94:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    3d98:	f4040aa3          	sb	zero,-171(s0)
    printf("%s: writing %s\n", name);
    3d9c:	f5040593          	addi	a1,s0,-176
    3da0:	8566                	mv	a0,s9
    3da2:	00001097          	auipc	ra,0x1
    3da6:	998080e7          	jalr	-1640(ra) # 473a <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    3daa:	20200593          	li	a1,514
    3dae:	f5040513          	addi	a0,s0,-176
    3db2:	00000097          	auipc	ra,0x0
    3db6:	630080e7          	jalr	1584(ra) # 43e2 <open>
    3dba:	892a                	mv	s2,a0
    if(fd < 0){
    3dbc:	0a055663          	bgez	a0,3e68 <fsfull+0x15c>
      printf("%s: open %s failed\n", name);
    3dc0:	f5040593          	addi	a1,s0,-176
    3dc4:	00002517          	auipc	a0,0x2
    3dc8:	74c50513          	addi	a0,a0,1868 # 6510 <malloc+0x1d18>
    3dcc:	00001097          	auipc	ra,0x1
    3dd0:	96e080e7          	jalr	-1682(ra) # 473a <printf>
  while(nfiles >= 0){
    3dd4:	0604c363          	bltz	s1,3e3a <fsfull+0x12e>
    name[0] = 'f';
    3dd8:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    3ddc:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    3de0:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    3de4:	4929                	li	s2,10
  while(nfiles >= 0){
    3de6:	5afd                	li	s5,-1
    name[0] = 'f';
    3de8:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    3dec:	0344c7bb          	divw	a5,s1,s4
    3df0:	0307879b          	addiw	a5,a5,48
    3df4:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    3df8:	0344e7bb          	remw	a5,s1,s4
    3dfc:	0337c7bb          	divw	a5,a5,s3
    3e00:	0307879b          	addiw	a5,a5,48
    3e04:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    3e08:	0334e7bb          	remw	a5,s1,s3
    3e0c:	0327c7bb          	divw	a5,a5,s2
    3e10:	0307879b          	addiw	a5,a5,48
    3e14:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    3e18:	0324e7bb          	remw	a5,s1,s2
    3e1c:	0307879b          	addiw	a5,a5,48
    3e20:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    3e24:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    3e28:	f5040513          	addi	a0,s0,-176
    3e2c:	00000097          	auipc	ra,0x0
    3e30:	5c6080e7          	jalr	1478(ra) # 43f2 <unlink>
    nfiles--;
    3e34:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    3e36:	fb5499e3          	bne	s1,s5,3de8 <fsfull+0xdc>
  printf("fsfull test finished\n");
    3e3a:	00002517          	auipc	a0,0x2
    3e3e:	70650513          	addi	a0,a0,1798 # 6540 <malloc+0x1d48>
    3e42:	00001097          	auipc	ra,0x1
    3e46:	8f8080e7          	jalr	-1800(ra) # 473a <printf>
}
    3e4a:	70aa                	ld	ra,168(sp)
    3e4c:	740a                	ld	s0,160(sp)
    3e4e:	64ea                	ld	s1,152(sp)
    3e50:	694a                	ld	s2,144(sp)
    3e52:	69aa                	ld	s3,136(sp)
    3e54:	6a0a                	ld	s4,128(sp)
    3e56:	7ae6                	ld	s5,120(sp)
    3e58:	7b46                	ld	s6,112(sp)
    3e5a:	7ba6                	ld	s7,104(sp)
    3e5c:	7c06                	ld	s8,96(sp)
    3e5e:	6ce6                	ld	s9,88(sp)
    3e60:	6d46                	ld	s10,80(sp)
    3e62:	6da6                	ld	s11,72(sp)
    3e64:	614d                	addi	sp,sp,176
    3e66:	8082                	ret
    int total = 0;
    3e68:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    3e6a:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    3e6e:	40000613          	li	a2,1024
    3e72:	85d2                	mv	a1,s4
    3e74:	854a                	mv	a0,s2
    3e76:	00000097          	auipc	ra,0x0
    3e7a:	54c080e7          	jalr	1356(ra) # 43c2 <write>
      if(cc < BSIZE)
    3e7e:	00aad563          	bge	s5,a0,3e88 <fsfull+0x17c>
      total += cc;
    3e82:	00a989bb          	addw	s3,s3,a0
    while(1){
    3e86:	b7e5                	j	3e6e <fsfull+0x162>
    printf("%s: wrote %d bytes\n", total);
    3e88:	85ce                	mv	a1,s3
    3e8a:	00002517          	auipc	a0,0x2
    3e8e:	69e50513          	addi	a0,a0,1694 # 6528 <malloc+0x1d30>
    3e92:	00001097          	auipc	ra,0x1
    3e96:	8a8080e7          	jalr	-1880(ra) # 473a <printf>
    close(fd);
    3e9a:	854a                	mv	a0,s2
    3e9c:	00000097          	auipc	ra,0x0
    3ea0:	52e080e7          	jalr	1326(ra) # 43ca <close>
    if(total == 0)
    3ea4:	f20988e3          	beqz	s3,3dd4 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    3ea8:	2485                	addiw	s1,s1,1
    3eaa:	bd4d                	j	3d5c <fsfull+0x50>

0000000000003eac <rand>:
{
    3eac:	1141                	addi	sp,sp,-16
    3eae:	e422                	sd	s0,8(sp)
    3eb0:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    3eb2:	00003717          	auipc	a4,0x3
    3eb6:	aa670713          	addi	a4,a4,-1370 # 6958 <randstate>
    3eba:	6308                	ld	a0,0(a4)
    3ebc:	001967b7          	lui	a5,0x196
    3ec0:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x18a47d>
    3ec4:	02f50533          	mul	a0,a0,a5
    3ec8:	3c6ef7b7          	lui	a5,0x3c6ef
    3ecc:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e31cf>
    3ed0:	953e                	add	a0,a0,a5
    3ed2:	e308                	sd	a0,0(a4)
}
    3ed4:	2501                	sext.w	a0,a0
    3ed6:	6422                	ld	s0,8(sp)
    3ed8:	0141                	addi	sp,sp,16
    3eda:	8082                	ret

0000000000003edc <badwrite>:
{
    3edc:	7179                	addi	sp,sp,-48
    3ede:	f406                	sd	ra,40(sp)
    3ee0:	f022                	sd	s0,32(sp)
    3ee2:	ec26                	sd	s1,24(sp)
    3ee4:	e84a                	sd	s2,16(sp)
    3ee6:	e44e                	sd	s3,8(sp)
    3ee8:	e052                	sd	s4,0(sp)
    3eea:	1800                	addi	s0,sp,48
  unlink("junk");
    3eec:	00002517          	auipc	a0,0x2
    3ef0:	66c50513          	addi	a0,a0,1644 # 6558 <malloc+0x1d60>
    3ef4:	00000097          	auipc	ra,0x0
    3ef8:	4fe080e7          	jalr	1278(ra) # 43f2 <unlink>
    3efc:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    3f00:	00002997          	auipc	s3,0x2
    3f04:	65898993          	addi	s3,s3,1624 # 6558 <malloc+0x1d60>
    write(fd, (char*)0xffffffffffL, 1);
    3f08:	5a7d                	li	s4,-1
    3f0a:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    3f0e:	20100593          	li	a1,513
    3f12:	854e                	mv	a0,s3
    3f14:	00000097          	auipc	ra,0x0
    3f18:	4ce080e7          	jalr	1230(ra) # 43e2 <open>
    3f1c:	84aa                	mv	s1,a0
    if(fd < 0){
    3f1e:	06054b63          	bltz	a0,3f94 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    3f22:	4605                	li	a2,1
    3f24:	85d2                	mv	a1,s4
    3f26:	00000097          	auipc	ra,0x0
    3f2a:	49c080e7          	jalr	1180(ra) # 43c2 <write>
    close(fd);
    3f2e:	8526                	mv	a0,s1
    3f30:	00000097          	auipc	ra,0x0
    3f34:	49a080e7          	jalr	1178(ra) # 43ca <close>
    unlink("junk");
    3f38:	854e                	mv	a0,s3
    3f3a:	00000097          	auipc	ra,0x0
    3f3e:	4b8080e7          	jalr	1208(ra) # 43f2 <unlink>
  for(int i = 0; i < assumed_free; i++){
    3f42:	397d                	addiw	s2,s2,-1
    3f44:	fc0915e3          	bnez	s2,3f0e <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    3f48:	20100593          	li	a1,513
    3f4c:	00002517          	auipc	a0,0x2
    3f50:	60c50513          	addi	a0,a0,1548 # 6558 <malloc+0x1d60>
    3f54:	00000097          	auipc	ra,0x0
    3f58:	48e080e7          	jalr	1166(ra) # 43e2 <open>
    3f5c:	84aa                	mv	s1,a0
  if(fd < 0){
    3f5e:	04054863          	bltz	a0,3fae <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    3f62:	4605                	li	a2,1
    3f64:	00001597          	auipc	a1,0x1
    3f68:	72c58593          	addi	a1,a1,1836 # 5690 <malloc+0xe98>
    3f6c:	00000097          	auipc	ra,0x0
    3f70:	456080e7          	jalr	1110(ra) # 43c2 <write>
    3f74:	4785                	li	a5,1
    3f76:	04f50963          	beq	a0,a5,3fc8 <badwrite+0xec>
    printf("write failed\n");
    3f7a:	00002517          	auipc	a0,0x2
    3f7e:	5fe50513          	addi	a0,a0,1534 # 6578 <malloc+0x1d80>
    3f82:	00000097          	auipc	ra,0x0
    3f86:	7b8080e7          	jalr	1976(ra) # 473a <printf>
    exit(1);
    3f8a:	4505                	li	a0,1
    3f8c:	00000097          	auipc	ra,0x0
    3f90:	416080e7          	jalr	1046(ra) # 43a2 <exit>
      printf("open junk failed\n");
    3f94:	00002517          	auipc	a0,0x2
    3f98:	5cc50513          	addi	a0,a0,1484 # 6560 <malloc+0x1d68>
    3f9c:	00000097          	auipc	ra,0x0
    3fa0:	79e080e7          	jalr	1950(ra) # 473a <printf>
      exit(1);
    3fa4:	4505                	li	a0,1
    3fa6:	00000097          	auipc	ra,0x0
    3faa:	3fc080e7          	jalr	1020(ra) # 43a2 <exit>
    printf("open junk failed\n");
    3fae:	00002517          	auipc	a0,0x2
    3fb2:	5b250513          	addi	a0,a0,1458 # 6560 <malloc+0x1d68>
    3fb6:	00000097          	auipc	ra,0x0
    3fba:	784080e7          	jalr	1924(ra) # 473a <printf>
    exit(1);
    3fbe:	4505                	li	a0,1
    3fc0:	00000097          	auipc	ra,0x0
    3fc4:	3e2080e7          	jalr	994(ra) # 43a2 <exit>
  close(fd);
    3fc8:	8526                	mv	a0,s1
    3fca:	00000097          	auipc	ra,0x0
    3fce:	400080e7          	jalr	1024(ra) # 43ca <close>
  unlink("junk");
    3fd2:	00002517          	auipc	a0,0x2
    3fd6:	58650513          	addi	a0,a0,1414 # 6558 <malloc+0x1d60>
    3fda:	00000097          	auipc	ra,0x0
    3fde:	418080e7          	jalr	1048(ra) # 43f2 <unlink>
  exit(0);
    3fe2:	4501                	li	a0,0
    3fe4:	00000097          	auipc	ra,0x0
    3fe8:	3be080e7          	jalr	958(ra) # 43a2 <exit>

0000000000003fec <run>:
}

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    3fec:	7179                	addi	sp,sp,-48
    3fee:	f406                	sd	ra,40(sp)
    3ff0:	f022                	sd	s0,32(sp)
    3ff2:	ec26                	sd	s1,24(sp)
    3ff4:	e84a                	sd	s2,16(sp)
    3ff6:	1800                	addi	s0,sp,48
    3ff8:	892a                	mv	s2,a0
    3ffa:	84ae                	mv	s1,a1
  int pid;
  int xstatus;
  
  printf("test %s: ", s);
    3ffc:	00002517          	auipc	a0,0x2
    4000:	58c50513          	addi	a0,a0,1420 # 6588 <malloc+0x1d90>
    4004:	00000097          	auipc	ra,0x0
    4008:	736080e7          	jalr	1846(ra) # 473a <printf>
  if((pid = fork()) < 0) {
    400c:	00000097          	auipc	ra,0x0
    4010:	38e080e7          	jalr	910(ra) # 439a <fork>
    4014:	02054f63          	bltz	a0,4052 <run+0x66>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    4018:	c931                	beqz	a0,406c <run+0x80>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    401a:	fdc40513          	addi	a0,s0,-36
    401e:	00000097          	auipc	ra,0x0
    4022:	38c080e7          	jalr	908(ra) # 43aa <wait>
    if(xstatus != 0) 
    4026:	fdc42783          	lw	a5,-36(s0)
    402a:	cba1                	beqz	a5,407a <run+0x8e>
      printf("FAILED\n", s);
    402c:	85a6                	mv	a1,s1
    402e:	00002517          	auipc	a0,0x2
    4032:	58250513          	addi	a0,a0,1410 # 65b0 <malloc+0x1db8>
    4036:	00000097          	auipc	ra,0x0
    403a:	704080e7          	jalr	1796(ra) # 473a <printf>
    else
      printf("OK\n", s);
    return xstatus == 0;
    403e:	fdc42503          	lw	a0,-36(s0)
  }
}
    4042:	00153513          	seqz	a0,a0
    4046:	70a2                	ld	ra,40(sp)
    4048:	7402                	ld	s0,32(sp)
    404a:	64e2                	ld	s1,24(sp)
    404c:	6942                	ld	s2,16(sp)
    404e:	6145                	addi	sp,sp,48
    4050:	8082                	ret
    printf("runtest: fork error\n");
    4052:	00002517          	auipc	a0,0x2
    4056:	54650513          	addi	a0,a0,1350 # 6598 <malloc+0x1da0>
    405a:	00000097          	auipc	ra,0x0
    405e:	6e0080e7          	jalr	1760(ra) # 473a <printf>
    exit(1);
    4062:	4505                	li	a0,1
    4064:	00000097          	auipc	ra,0x0
    4068:	33e080e7          	jalr	830(ra) # 43a2 <exit>
    f(s);
    406c:	8526                	mv	a0,s1
    406e:	9902                	jalr	s2
    exit(0);
    4070:	4501                	li	a0,0
    4072:	00000097          	auipc	ra,0x0
    4076:	330080e7          	jalr	816(ra) # 43a2 <exit>
      printf("OK\n", s);
    407a:	85a6                	mv	a1,s1
    407c:	00002517          	auipc	a0,0x2
    4080:	53c50513          	addi	a0,a0,1340 # 65b8 <malloc+0x1dc0>
    4084:	00000097          	auipc	ra,0x0
    4088:	6b6080e7          	jalr	1718(ra) # 473a <printf>
    408c:	bf4d                	j	403e <run+0x52>

000000000000408e <main>:

int
main(int argc, char *argv[])
{
    408e:	d0010113          	addi	sp,sp,-768
    4092:	2e113c23          	sd	ra,760(sp)
    4096:	2e813823          	sd	s0,752(sp)
    409a:	2e913423          	sd	s1,744(sp)
    409e:	2f213023          	sd	s2,736(sp)
    40a2:	2d313c23          	sd	s3,728(sp)
    40a6:	2d413823          	sd	s4,720(sp)
    40aa:	0600                	addi	s0,sp,768
  char *n = 0;
  if(argc > 1) {
    40ac:	4785                	li	a5,1
  char *n = 0;
    40ae:	4901                	li	s2,0
  if(argc > 1) {
    40b0:	00a7d463          	bge	a5,a0,40b8 <main+0x2a>
    n = argv[1];
    40b4:	0085b903          	ld	s2,8(a1)
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    40b8:	00002797          	auipc	a5,0x2
    40bc:	5a878793          	addi	a5,a5,1448 # 6660 <malloc+0x1e68>
    40c0:	d0040713          	addi	a4,s0,-768
    40c4:	00003897          	auipc	a7,0x3
    40c8:	86c88893          	addi	a7,a7,-1940 # 6930 <malloc+0x2138>
    40cc:	0007b803          	ld	a6,0(a5)
    40d0:	6788                	ld	a0,8(a5)
    40d2:	6b8c                	ld	a1,16(a5)
    40d4:	6f90                	ld	a2,24(a5)
    40d6:	7394                	ld	a3,32(a5)
    40d8:	01073023          	sd	a6,0(a4)
    40dc:	e708                	sd	a0,8(a4)
    40de:	eb0c                	sd	a1,16(a4)
    40e0:	ef10                	sd	a2,24(a4)
    40e2:	f314                	sd	a3,32(a4)
    40e4:	02878793          	addi	a5,a5,40
    40e8:	02870713          	addi	a4,a4,40
    40ec:	ff1790e3          	bne	a5,a7,40cc <main+0x3e>
    {forktest, "forktest"},
    {bigdir, "bigdir"}, // slow
    { 0, 0},
  };
    
  printf("usertests starting\n");
    40f0:	00002517          	auipc	a0,0x2
    40f4:	4d050513          	addi	a0,a0,1232 # 65c0 <malloc+0x1dc8>
    40f8:	00000097          	auipc	ra,0x0
    40fc:	642080e7          	jalr	1602(ra) # 473a <printf>

  if(open("usertests.ran", 0) >= 0){
    4100:	4581                	li	a1,0
    4102:	00002517          	auipc	a0,0x2
    4106:	4d650513          	addi	a0,a0,1238 # 65d8 <malloc+0x1de0>
    410a:	00000097          	auipc	ra,0x0
    410e:	2d8080e7          	jalr	728(ra) # 43e2 <open>
    4112:	00054f63          	bltz	a0,4130 <main+0xa2>
    printf("already ran user tests -- rebuild fs.img (rm fs.img; make fs.img)\n");
    4116:	00002517          	auipc	a0,0x2
    411a:	4d250513          	addi	a0,a0,1234 # 65e8 <malloc+0x1df0>
    411e:	00000097          	auipc	ra,0x0
    4122:	61c080e7          	jalr	1564(ra) # 473a <printf>
    exit(1);
    4126:	4505                	li	a0,1
    4128:	00000097          	auipc	ra,0x0
    412c:	27a080e7          	jalr	634(ra) # 43a2 <exit>
  }
  close(open("usertests.ran", O_CREATE));
    4130:	20000593          	li	a1,512
    4134:	00002517          	auipc	a0,0x2
    4138:	4a450513          	addi	a0,a0,1188 # 65d8 <malloc+0x1de0>
    413c:	00000097          	auipc	ra,0x0
    4140:	2a6080e7          	jalr	678(ra) # 43e2 <open>
    4144:	00000097          	auipc	ra,0x0
    4148:	286080e7          	jalr	646(ra) # 43ca <close>

  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    414c:	d0843503          	ld	a0,-760(s0)
    4150:	c529                	beqz	a0,419a <main+0x10c>
    4152:	d0040493          	addi	s1,s0,-768
  int fail = 0;
    4156:	4981                	li	s3,0
    if((n == 0) || strcmp(t->s, n) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    4158:	4a05                	li	s4,1
    415a:	a021                	j	4162 <main+0xd4>
  for (struct test *t = tests; t->s != 0; t++) {
    415c:	04c1                	addi	s1,s1,16
    415e:	6488                	ld	a0,8(s1)
    4160:	c115                	beqz	a0,4184 <main+0xf6>
    if((n == 0) || strcmp(t->s, n) == 0) {
    4162:	00090863          	beqz	s2,4172 <main+0xe4>
    4166:	85ca                	mv	a1,s2
    4168:	00000097          	auipc	ra,0x0
    416c:	068080e7          	jalr	104(ra) # 41d0 <strcmp>
    4170:	f575                	bnez	a0,415c <main+0xce>
      if(!run(t->f, t->s))
    4172:	648c                	ld	a1,8(s1)
    4174:	6088                	ld	a0,0(s1)
    4176:	00000097          	auipc	ra,0x0
    417a:	e76080e7          	jalr	-394(ra) # 3fec <run>
    417e:	fd79                	bnez	a0,415c <main+0xce>
        fail = 1;
    4180:	89d2                	mv	s3,s4
    4182:	bfe9                	j	415c <main+0xce>
    }
  }
  if(!fail)
    4184:	00098b63          	beqz	s3,419a <main+0x10c>
    printf("ALL TESTS PASSED\n");
  else
    printf("SOME TESTS FAILED\n");
    4188:	00002517          	auipc	a0,0x2
    418c:	4c050513          	addi	a0,a0,1216 # 6648 <malloc+0x1e50>
    4190:	00000097          	auipc	ra,0x0
    4194:	5aa080e7          	jalr	1450(ra) # 473a <printf>
    4198:	a809                	j	41aa <main+0x11c>
    printf("ALL TESTS PASSED\n");
    419a:	00002517          	auipc	a0,0x2
    419e:	49650513          	addi	a0,a0,1174 # 6630 <malloc+0x1e38>
    41a2:	00000097          	auipc	ra,0x0
    41a6:	598080e7          	jalr	1432(ra) # 473a <printf>
  exit(1);   // not reached.
    41aa:	4505                	li	a0,1
    41ac:	00000097          	auipc	ra,0x0
    41b0:	1f6080e7          	jalr	502(ra) # 43a2 <exit>

00000000000041b4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    41b4:	1141                	addi	sp,sp,-16
    41b6:	e422                	sd	s0,8(sp)
    41b8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    41ba:	87aa                	mv	a5,a0
    41bc:	0585                	addi	a1,a1,1
    41be:	0785                	addi	a5,a5,1
    41c0:	fff5c703          	lbu	a4,-1(a1)
    41c4:	fee78fa3          	sb	a4,-1(a5)
    41c8:	fb75                	bnez	a4,41bc <strcpy+0x8>
    ;
  return os;
}
    41ca:	6422                	ld	s0,8(sp)
    41cc:	0141                	addi	sp,sp,16
    41ce:	8082                	ret

00000000000041d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    41d0:	1141                	addi	sp,sp,-16
    41d2:	e422                	sd	s0,8(sp)
    41d4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    41d6:	00054783          	lbu	a5,0(a0)
    41da:	cb91                	beqz	a5,41ee <strcmp+0x1e>
    41dc:	0005c703          	lbu	a4,0(a1)
    41e0:	00f71763          	bne	a4,a5,41ee <strcmp+0x1e>
    p++, q++;
    41e4:	0505                	addi	a0,a0,1
    41e6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    41e8:	00054783          	lbu	a5,0(a0)
    41ec:	fbe5                	bnez	a5,41dc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    41ee:	0005c503          	lbu	a0,0(a1)
}
    41f2:	40a7853b          	subw	a0,a5,a0
    41f6:	6422                	ld	s0,8(sp)
    41f8:	0141                	addi	sp,sp,16
    41fa:	8082                	ret

00000000000041fc <strlen>:

uint
strlen(const char *s)
{
    41fc:	1141                	addi	sp,sp,-16
    41fe:	e422                	sd	s0,8(sp)
    4200:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    4202:	00054783          	lbu	a5,0(a0)
    4206:	cf91                	beqz	a5,4222 <strlen+0x26>
    4208:	0505                	addi	a0,a0,1
    420a:	87aa                	mv	a5,a0
    420c:	4685                	li	a3,1
    420e:	9e89                	subw	a3,a3,a0
    4210:	00f6853b          	addw	a0,a3,a5
    4214:	0785                	addi	a5,a5,1
    4216:	fff7c703          	lbu	a4,-1(a5)
    421a:	fb7d                	bnez	a4,4210 <strlen+0x14>
    ;
  return n;
}
    421c:	6422                	ld	s0,8(sp)
    421e:	0141                	addi	sp,sp,16
    4220:	8082                	ret
  for(n = 0; s[n]; n++)
    4222:	4501                	li	a0,0
    4224:	bfe5                	j	421c <strlen+0x20>

0000000000004226 <memset>:

void*
memset(void *dst, int c, uint n)
{
    4226:	1141                	addi	sp,sp,-16
    4228:	e422                	sd	s0,8(sp)
    422a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    422c:	ca19                	beqz	a2,4242 <memset+0x1c>
    422e:	87aa                	mv	a5,a0
    4230:	1602                	slli	a2,a2,0x20
    4232:	9201                	srli	a2,a2,0x20
    4234:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    4238:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    423c:	0785                	addi	a5,a5,1
    423e:	fee79de3          	bne	a5,a4,4238 <memset+0x12>
  }
  return dst;
}
    4242:	6422                	ld	s0,8(sp)
    4244:	0141                	addi	sp,sp,16
    4246:	8082                	ret

0000000000004248 <strchr>:

char*
strchr(const char *s, char c)
{
    4248:	1141                	addi	sp,sp,-16
    424a:	e422                	sd	s0,8(sp)
    424c:	0800                	addi	s0,sp,16
  for(; *s; s++)
    424e:	00054783          	lbu	a5,0(a0)
    4252:	cb99                	beqz	a5,4268 <strchr+0x20>
    if(*s == c)
    4254:	00f58763          	beq	a1,a5,4262 <strchr+0x1a>
  for(; *s; s++)
    4258:	0505                	addi	a0,a0,1
    425a:	00054783          	lbu	a5,0(a0)
    425e:	fbfd                	bnez	a5,4254 <strchr+0xc>
      return (char*)s;
  return 0;
    4260:	4501                	li	a0,0
}
    4262:	6422                	ld	s0,8(sp)
    4264:	0141                	addi	sp,sp,16
    4266:	8082                	ret
  return 0;
    4268:	4501                	li	a0,0
    426a:	bfe5                	j	4262 <strchr+0x1a>

000000000000426c <gets>:

char*
gets(char *buf, int max)
{
    426c:	711d                	addi	sp,sp,-96
    426e:	ec86                	sd	ra,88(sp)
    4270:	e8a2                	sd	s0,80(sp)
    4272:	e4a6                	sd	s1,72(sp)
    4274:	e0ca                	sd	s2,64(sp)
    4276:	fc4e                	sd	s3,56(sp)
    4278:	f852                	sd	s4,48(sp)
    427a:	f456                	sd	s5,40(sp)
    427c:	f05a                	sd	s6,32(sp)
    427e:	ec5e                	sd	s7,24(sp)
    4280:	1080                	addi	s0,sp,96
    4282:	8baa                	mv	s7,a0
    4284:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4286:	892a                	mv	s2,a0
    4288:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    428a:	4aa9                	li	s5,10
    428c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    428e:	89a6                	mv	s3,s1
    4290:	2485                	addiw	s1,s1,1
    4292:	0344d863          	bge	s1,s4,42c2 <gets+0x56>
    cc = read(0, &c, 1);
    4296:	4605                	li	a2,1
    4298:	faf40593          	addi	a1,s0,-81
    429c:	4501                	li	a0,0
    429e:	00000097          	auipc	ra,0x0
    42a2:	11c080e7          	jalr	284(ra) # 43ba <read>
    if(cc < 1)
    42a6:	00a05e63          	blez	a0,42c2 <gets+0x56>
    buf[i++] = c;
    42aa:	faf44783          	lbu	a5,-81(s0)
    42ae:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    42b2:	01578763          	beq	a5,s5,42c0 <gets+0x54>
    42b6:	0905                	addi	s2,s2,1
    42b8:	fd679be3          	bne	a5,s6,428e <gets+0x22>
  for(i=0; i+1 < max; ){
    42bc:	89a6                	mv	s3,s1
    42be:	a011                	j	42c2 <gets+0x56>
    42c0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    42c2:	99de                	add	s3,s3,s7
    42c4:	00098023          	sb	zero,0(s3)
  return buf;
}
    42c8:	855e                	mv	a0,s7
    42ca:	60e6                	ld	ra,88(sp)
    42cc:	6446                	ld	s0,80(sp)
    42ce:	64a6                	ld	s1,72(sp)
    42d0:	6906                	ld	s2,64(sp)
    42d2:	79e2                	ld	s3,56(sp)
    42d4:	7a42                	ld	s4,48(sp)
    42d6:	7aa2                	ld	s5,40(sp)
    42d8:	7b02                	ld	s6,32(sp)
    42da:	6be2                	ld	s7,24(sp)
    42dc:	6125                	addi	sp,sp,96
    42de:	8082                	ret

00000000000042e0 <stat>:

int
stat(const char *n, struct stat *st)
{
    42e0:	1101                	addi	sp,sp,-32
    42e2:	ec06                	sd	ra,24(sp)
    42e4:	e822                	sd	s0,16(sp)
    42e6:	e426                	sd	s1,8(sp)
    42e8:	e04a                	sd	s2,0(sp)
    42ea:	1000                	addi	s0,sp,32
    42ec:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    42ee:	4581                	li	a1,0
    42f0:	00000097          	auipc	ra,0x0
    42f4:	0f2080e7          	jalr	242(ra) # 43e2 <open>
  if(fd < 0)
    42f8:	02054563          	bltz	a0,4322 <stat+0x42>
    42fc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    42fe:	85ca                	mv	a1,s2
    4300:	00000097          	auipc	ra,0x0
    4304:	0fa080e7          	jalr	250(ra) # 43fa <fstat>
    4308:	892a                	mv	s2,a0
  close(fd);
    430a:	8526                	mv	a0,s1
    430c:	00000097          	auipc	ra,0x0
    4310:	0be080e7          	jalr	190(ra) # 43ca <close>
  return r;
}
    4314:	854a                	mv	a0,s2
    4316:	60e2                	ld	ra,24(sp)
    4318:	6442                	ld	s0,16(sp)
    431a:	64a2                	ld	s1,8(sp)
    431c:	6902                	ld	s2,0(sp)
    431e:	6105                	addi	sp,sp,32
    4320:	8082                	ret
    return -1;
    4322:	597d                	li	s2,-1
    4324:	bfc5                	j	4314 <stat+0x34>

0000000000004326 <atoi>:

int
atoi(const char *s)
{
    4326:	1141                	addi	sp,sp,-16
    4328:	e422                	sd	s0,8(sp)
    432a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    432c:	00054603          	lbu	a2,0(a0)
    4330:	fd06079b          	addiw	a5,a2,-48
    4334:	0ff7f793          	andi	a5,a5,255
    4338:	4725                	li	a4,9
    433a:	02f76963          	bltu	a4,a5,436c <atoi+0x46>
    433e:	86aa                	mv	a3,a0
  n = 0;
    4340:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    4342:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    4344:	0685                	addi	a3,a3,1
    4346:	0025179b          	slliw	a5,a0,0x2
    434a:	9fa9                	addw	a5,a5,a0
    434c:	0017979b          	slliw	a5,a5,0x1
    4350:	9fb1                	addw	a5,a5,a2
    4352:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    4356:	0006c603          	lbu	a2,0(a3)
    435a:	fd06071b          	addiw	a4,a2,-48
    435e:	0ff77713          	andi	a4,a4,255
    4362:	fee5f1e3          	bgeu	a1,a4,4344 <atoi+0x1e>
  return n;
}
    4366:	6422                	ld	s0,8(sp)
    4368:	0141                	addi	sp,sp,16
    436a:	8082                	ret
  n = 0;
    436c:	4501                	li	a0,0
    436e:	bfe5                	j	4366 <atoi+0x40>

0000000000004370 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    4370:	1141                	addi	sp,sp,-16
    4372:	e422                	sd	s0,8(sp)
    4374:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    4376:	00c05f63          	blez	a2,4394 <memmove+0x24>
    437a:	1602                	slli	a2,a2,0x20
    437c:	9201                	srli	a2,a2,0x20
    437e:	00c506b3          	add	a3,a0,a2
  dst = vdst;
    4382:	87aa                	mv	a5,a0
    *dst++ = *src++;
    4384:	0585                	addi	a1,a1,1
    4386:	0785                	addi	a5,a5,1
    4388:	fff5c703          	lbu	a4,-1(a1)
    438c:	fee78fa3          	sb	a4,-1(a5)
  while(n-- > 0)
    4390:	fed79ae3          	bne	a5,a3,4384 <memmove+0x14>
  return vdst;
}
    4394:	6422                	ld	s0,8(sp)
    4396:	0141                	addi	sp,sp,16
    4398:	8082                	ret

000000000000439a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    439a:	4885                	li	a7,1
 ecall
    439c:	00000073          	ecall
 ret
    43a0:	8082                	ret

00000000000043a2 <exit>:
.global exit
exit:
 li a7, SYS_exit
    43a2:	4889                	li	a7,2
 ecall
    43a4:	00000073          	ecall
 ret
    43a8:	8082                	ret

00000000000043aa <wait>:
.global wait
wait:
 li a7, SYS_wait
    43aa:	488d                	li	a7,3
 ecall
    43ac:	00000073          	ecall
 ret
    43b0:	8082                	ret

00000000000043b2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    43b2:	4891                	li	a7,4
 ecall
    43b4:	00000073          	ecall
 ret
    43b8:	8082                	ret

00000000000043ba <read>:
.global read
read:
 li a7, SYS_read
    43ba:	4895                	li	a7,5
 ecall
    43bc:	00000073          	ecall
 ret
    43c0:	8082                	ret

00000000000043c2 <write>:
.global write
write:
 li a7, SYS_write
    43c2:	48c1                	li	a7,16
 ecall
    43c4:	00000073          	ecall
 ret
    43c8:	8082                	ret

00000000000043ca <close>:
.global close
close:
 li a7, SYS_close
    43ca:	48d5                	li	a7,21
 ecall
    43cc:	00000073          	ecall
 ret
    43d0:	8082                	ret

00000000000043d2 <kill>:
.global kill
kill:
 li a7, SYS_kill
    43d2:	4899                	li	a7,6
 ecall
    43d4:	00000073          	ecall
 ret
    43d8:	8082                	ret

00000000000043da <exec>:
.global exec
exec:
 li a7, SYS_exec
    43da:	489d                	li	a7,7
 ecall
    43dc:	00000073          	ecall
 ret
    43e0:	8082                	ret

00000000000043e2 <open>:
.global open
open:
 li a7, SYS_open
    43e2:	48bd                	li	a7,15
 ecall
    43e4:	00000073          	ecall
 ret
    43e8:	8082                	ret

00000000000043ea <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    43ea:	48c5                	li	a7,17
 ecall
    43ec:	00000073          	ecall
 ret
    43f0:	8082                	ret

00000000000043f2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    43f2:	48c9                	li	a7,18
 ecall
    43f4:	00000073          	ecall
 ret
    43f8:	8082                	ret

00000000000043fa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    43fa:	48a1                	li	a7,8
 ecall
    43fc:	00000073          	ecall
 ret
    4400:	8082                	ret

0000000000004402 <link>:
.global link
link:
 li a7, SYS_link
    4402:	48cd                	li	a7,19
 ecall
    4404:	00000073          	ecall
 ret
    4408:	8082                	ret

000000000000440a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    440a:	48d1                	li	a7,20
 ecall
    440c:	00000073          	ecall
 ret
    4410:	8082                	ret

0000000000004412 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    4412:	48a5                	li	a7,9
 ecall
    4414:	00000073          	ecall
 ret
    4418:	8082                	ret

000000000000441a <dup>:
.global dup
dup:
 li a7, SYS_dup
    441a:	48a9                	li	a7,10
 ecall
    441c:	00000073          	ecall
 ret
    4420:	8082                	ret

0000000000004422 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    4422:	48ad                	li	a7,11
 ecall
    4424:	00000073          	ecall
 ret
    4428:	8082                	ret

000000000000442a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    442a:	48b1                	li	a7,12
 ecall
    442c:	00000073          	ecall
 ret
    4430:	8082                	ret

0000000000004432 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    4432:	48b5                	li	a7,13
 ecall
    4434:	00000073          	ecall
 ret
    4438:	8082                	ret

000000000000443a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    443a:	48b9                	li	a7,14
 ecall
    443c:	00000073          	ecall
 ret
    4440:	8082                	ret

0000000000004442 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
    4442:	48d9                	li	a7,22
 ecall
    4444:	00000073          	ecall
 ret
    4448:	8082                	ret

000000000000444a <crash>:
.global crash
crash:
 li a7, SYS_crash
    444a:	48dd                	li	a7,23
 ecall
    444c:	00000073          	ecall
 ret
    4450:	8082                	ret

0000000000004452 <mount>:
.global mount
mount:
 li a7, SYS_mount
    4452:	48e1                	li	a7,24
 ecall
    4454:	00000073          	ecall
 ret
    4458:	8082                	ret

000000000000445a <umount>:
.global umount
umount:
 li a7, SYS_umount
    445a:	48e5                	li	a7,25
 ecall
    445c:	00000073          	ecall
 ret
    4460:	8082                	ret

0000000000004462 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    4462:	1101                	addi	sp,sp,-32
    4464:	ec06                	sd	ra,24(sp)
    4466:	e822                	sd	s0,16(sp)
    4468:	1000                	addi	s0,sp,32
    446a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    446e:	4605                	li	a2,1
    4470:	fef40593          	addi	a1,s0,-17
    4474:	00000097          	auipc	ra,0x0
    4478:	f4e080e7          	jalr	-178(ra) # 43c2 <write>
}
    447c:	60e2                	ld	ra,24(sp)
    447e:	6442                	ld	s0,16(sp)
    4480:	6105                	addi	sp,sp,32
    4482:	8082                	ret

0000000000004484 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    4484:	7139                	addi	sp,sp,-64
    4486:	fc06                	sd	ra,56(sp)
    4488:	f822                	sd	s0,48(sp)
    448a:	f426                	sd	s1,40(sp)
    448c:	f04a                	sd	s2,32(sp)
    448e:	ec4e                	sd	s3,24(sp)
    4490:	0080                	addi	s0,sp,64
    4492:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    4494:	c299                	beqz	a3,449a <printint+0x16>
    4496:	0805c863          	bltz	a1,4526 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    449a:	2581                	sext.w	a1,a1
  neg = 0;
    449c:	4881                	li	a7,0
    449e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    44a2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    44a4:	2601                	sext.w	a2,a2
    44a6:	00002517          	auipc	a0,0x2
    44aa:	49250513          	addi	a0,a0,1170 # 6938 <digits>
    44ae:	883a                	mv	a6,a4
    44b0:	2705                	addiw	a4,a4,1
    44b2:	02c5f7bb          	remuw	a5,a1,a2
    44b6:	1782                	slli	a5,a5,0x20
    44b8:	9381                	srli	a5,a5,0x20
    44ba:	97aa                	add	a5,a5,a0
    44bc:	0007c783          	lbu	a5,0(a5)
    44c0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    44c4:	0005879b          	sext.w	a5,a1
    44c8:	02c5d5bb          	divuw	a1,a1,a2
    44cc:	0685                	addi	a3,a3,1
    44ce:	fec7f0e3          	bgeu	a5,a2,44ae <printint+0x2a>
  if(neg)
    44d2:	00088b63          	beqz	a7,44e8 <printint+0x64>
    buf[i++] = '-';
    44d6:	fd040793          	addi	a5,s0,-48
    44da:	973e                	add	a4,a4,a5
    44dc:	02d00793          	li	a5,45
    44e0:	fef70823          	sb	a5,-16(a4)
    44e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    44e8:	02e05863          	blez	a4,4518 <printint+0x94>
    44ec:	fc040793          	addi	a5,s0,-64
    44f0:	00e78933          	add	s2,a5,a4
    44f4:	fff78993          	addi	s3,a5,-1
    44f8:	99ba                	add	s3,s3,a4
    44fa:	377d                	addiw	a4,a4,-1
    44fc:	1702                	slli	a4,a4,0x20
    44fe:	9301                	srli	a4,a4,0x20
    4500:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    4504:	fff94583          	lbu	a1,-1(s2)
    4508:	8526                	mv	a0,s1
    450a:	00000097          	auipc	ra,0x0
    450e:	f58080e7          	jalr	-168(ra) # 4462 <putc>
  while(--i >= 0)
    4512:	197d                	addi	s2,s2,-1
    4514:	ff3918e3          	bne	s2,s3,4504 <printint+0x80>
}
    4518:	70e2                	ld	ra,56(sp)
    451a:	7442                	ld	s0,48(sp)
    451c:	74a2                	ld	s1,40(sp)
    451e:	7902                	ld	s2,32(sp)
    4520:	69e2                	ld	s3,24(sp)
    4522:	6121                	addi	sp,sp,64
    4524:	8082                	ret
    x = -xx;
    4526:	40b005bb          	negw	a1,a1
    neg = 1;
    452a:	4885                	li	a7,1
    x = -xx;
    452c:	bf8d                	j	449e <printint+0x1a>

000000000000452e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    452e:	7119                	addi	sp,sp,-128
    4530:	fc86                	sd	ra,120(sp)
    4532:	f8a2                	sd	s0,112(sp)
    4534:	f4a6                	sd	s1,104(sp)
    4536:	f0ca                	sd	s2,96(sp)
    4538:	ecce                	sd	s3,88(sp)
    453a:	e8d2                	sd	s4,80(sp)
    453c:	e4d6                	sd	s5,72(sp)
    453e:	e0da                	sd	s6,64(sp)
    4540:	fc5e                	sd	s7,56(sp)
    4542:	f862                	sd	s8,48(sp)
    4544:	f466                	sd	s9,40(sp)
    4546:	f06a                	sd	s10,32(sp)
    4548:	ec6e                	sd	s11,24(sp)
    454a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    454c:	0005c903          	lbu	s2,0(a1)
    4550:	18090f63          	beqz	s2,46ee <vprintf+0x1c0>
    4554:	8aaa                	mv	s5,a0
    4556:	8b32                	mv	s6,a2
    4558:	00158493          	addi	s1,a1,1
  state = 0;
    455c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    455e:	02500a13          	li	s4,37
      if(c == 'd'){
    4562:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    4566:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    456a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    456e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    4572:	00002b97          	auipc	s7,0x2
    4576:	3c6b8b93          	addi	s7,s7,966 # 6938 <digits>
    457a:	a839                	j	4598 <vprintf+0x6a>
        putc(fd, c);
    457c:	85ca                	mv	a1,s2
    457e:	8556                	mv	a0,s5
    4580:	00000097          	auipc	ra,0x0
    4584:	ee2080e7          	jalr	-286(ra) # 4462 <putc>
    4588:	a019                	j	458e <vprintf+0x60>
    } else if(state == '%'){
    458a:	01498f63          	beq	s3,s4,45a8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    458e:	0485                	addi	s1,s1,1
    4590:	fff4c903          	lbu	s2,-1(s1)
    4594:	14090d63          	beqz	s2,46ee <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    4598:	0009079b          	sext.w	a5,s2
    if(state == 0){
    459c:	fe0997e3          	bnez	s3,458a <vprintf+0x5c>
      if(c == '%'){
    45a0:	fd479ee3          	bne	a5,s4,457c <vprintf+0x4e>
        state = '%';
    45a4:	89be                	mv	s3,a5
    45a6:	b7e5                	j	458e <vprintf+0x60>
      if(c == 'd'){
    45a8:	05878063          	beq	a5,s8,45e8 <vprintf+0xba>
      } else if(c == 'l') {
    45ac:	05978c63          	beq	a5,s9,4604 <vprintf+0xd6>
      } else if(c == 'x') {
    45b0:	07a78863          	beq	a5,s10,4620 <vprintf+0xf2>
      } else if(c == 'p') {
    45b4:	09b78463          	beq	a5,s11,463c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    45b8:	07300713          	li	a4,115
    45bc:	0ce78663          	beq	a5,a4,4688 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    45c0:	06300713          	li	a4,99
    45c4:	0ee78e63          	beq	a5,a4,46c0 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    45c8:	11478863          	beq	a5,s4,46d8 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    45cc:	85d2                	mv	a1,s4
    45ce:	8556                	mv	a0,s5
    45d0:	00000097          	auipc	ra,0x0
    45d4:	e92080e7          	jalr	-366(ra) # 4462 <putc>
        putc(fd, c);
    45d8:	85ca                	mv	a1,s2
    45da:	8556                	mv	a0,s5
    45dc:	00000097          	auipc	ra,0x0
    45e0:	e86080e7          	jalr	-378(ra) # 4462 <putc>
      }
      state = 0;
    45e4:	4981                	li	s3,0
    45e6:	b765                	j	458e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    45e8:	008b0913          	addi	s2,s6,8
    45ec:	4685                	li	a3,1
    45ee:	4629                	li	a2,10
    45f0:	000b2583          	lw	a1,0(s6)
    45f4:	8556                	mv	a0,s5
    45f6:	00000097          	auipc	ra,0x0
    45fa:	e8e080e7          	jalr	-370(ra) # 4484 <printint>
    45fe:	8b4a                	mv	s6,s2
      state = 0;
    4600:	4981                	li	s3,0
    4602:	b771                	j	458e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    4604:	008b0913          	addi	s2,s6,8
    4608:	4681                	li	a3,0
    460a:	4629                	li	a2,10
    460c:	000b2583          	lw	a1,0(s6)
    4610:	8556                	mv	a0,s5
    4612:	00000097          	auipc	ra,0x0
    4616:	e72080e7          	jalr	-398(ra) # 4484 <printint>
    461a:	8b4a                	mv	s6,s2
      state = 0;
    461c:	4981                	li	s3,0
    461e:	bf85                	j	458e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    4620:	008b0913          	addi	s2,s6,8
    4624:	4681                	li	a3,0
    4626:	4641                	li	a2,16
    4628:	000b2583          	lw	a1,0(s6)
    462c:	8556                	mv	a0,s5
    462e:	00000097          	auipc	ra,0x0
    4632:	e56080e7          	jalr	-426(ra) # 4484 <printint>
    4636:	8b4a                	mv	s6,s2
      state = 0;
    4638:	4981                	li	s3,0
    463a:	bf91                	j	458e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    463c:	008b0793          	addi	a5,s6,8
    4640:	f8f43423          	sd	a5,-120(s0)
    4644:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    4648:	03000593          	li	a1,48
    464c:	8556                	mv	a0,s5
    464e:	00000097          	auipc	ra,0x0
    4652:	e14080e7          	jalr	-492(ra) # 4462 <putc>
  putc(fd, 'x');
    4656:	85ea                	mv	a1,s10
    4658:	8556                	mv	a0,s5
    465a:	00000097          	auipc	ra,0x0
    465e:	e08080e7          	jalr	-504(ra) # 4462 <putc>
    4662:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    4664:	03c9d793          	srli	a5,s3,0x3c
    4668:	97de                	add	a5,a5,s7
    466a:	0007c583          	lbu	a1,0(a5)
    466e:	8556                	mv	a0,s5
    4670:	00000097          	auipc	ra,0x0
    4674:	df2080e7          	jalr	-526(ra) # 4462 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    4678:	0992                	slli	s3,s3,0x4
    467a:	397d                	addiw	s2,s2,-1
    467c:	fe0914e3          	bnez	s2,4664 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    4680:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    4684:	4981                	li	s3,0
    4686:	b721                	j	458e <vprintf+0x60>
        s = va_arg(ap, char*);
    4688:	008b0993          	addi	s3,s6,8
    468c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    4690:	02090163          	beqz	s2,46b2 <vprintf+0x184>
        while(*s != 0){
    4694:	00094583          	lbu	a1,0(s2)
    4698:	c9a1                	beqz	a1,46e8 <vprintf+0x1ba>
          putc(fd, *s);
    469a:	8556                	mv	a0,s5
    469c:	00000097          	auipc	ra,0x0
    46a0:	dc6080e7          	jalr	-570(ra) # 4462 <putc>
          s++;
    46a4:	0905                	addi	s2,s2,1
        while(*s != 0){
    46a6:	00094583          	lbu	a1,0(s2)
    46aa:	f9e5                	bnez	a1,469a <vprintf+0x16c>
        s = va_arg(ap, char*);
    46ac:	8b4e                	mv	s6,s3
      state = 0;
    46ae:	4981                	li	s3,0
    46b0:	bdf9                	j	458e <vprintf+0x60>
          s = "(null)";
    46b2:	00002917          	auipc	s2,0x2
    46b6:	27e90913          	addi	s2,s2,638 # 6930 <malloc+0x2138>
        while(*s != 0){
    46ba:	02800593          	li	a1,40
    46be:	bff1                	j	469a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    46c0:	008b0913          	addi	s2,s6,8
    46c4:	000b4583          	lbu	a1,0(s6)
    46c8:	8556                	mv	a0,s5
    46ca:	00000097          	auipc	ra,0x0
    46ce:	d98080e7          	jalr	-616(ra) # 4462 <putc>
    46d2:	8b4a                	mv	s6,s2
      state = 0;
    46d4:	4981                	li	s3,0
    46d6:	bd65                	j	458e <vprintf+0x60>
        putc(fd, c);
    46d8:	85d2                	mv	a1,s4
    46da:	8556                	mv	a0,s5
    46dc:	00000097          	auipc	ra,0x0
    46e0:	d86080e7          	jalr	-634(ra) # 4462 <putc>
      state = 0;
    46e4:	4981                	li	s3,0
    46e6:	b565                	j	458e <vprintf+0x60>
        s = va_arg(ap, char*);
    46e8:	8b4e                	mv	s6,s3
      state = 0;
    46ea:	4981                	li	s3,0
    46ec:	b54d                	j	458e <vprintf+0x60>
    }
  }
}
    46ee:	70e6                	ld	ra,120(sp)
    46f0:	7446                	ld	s0,112(sp)
    46f2:	74a6                	ld	s1,104(sp)
    46f4:	7906                	ld	s2,96(sp)
    46f6:	69e6                	ld	s3,88(sp)
    46f8:	6a46                	ld	s4,80(sp)
    46fa:	6aa6                	ld	s5,72(sp)
    46fc:	6b06                	ld	s6,64(sp)
    46fe:	7be2                	ld	s7,56(sp)
    4700:	7c42                	ld	s8,48(sp)
    4702:	7ca2                	ld	s9,40(sp)
    4704:	7d02                	ld	s10,32(sp)
    4706:	6de2                	ld	s11,24(sp)
    4708:	6109                	addi	sp,sp,128
    470a:	8082                	ret

000000000000470c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    470c:	715d                	addi	sp,sp,-80
    470e:	ec06                	sd	ra,24(sp)
    4710:	e822                	sd	s0,16(sp)
    4712:	1000                	addi	s0,sp,32
    4714:	e010                	sd	a2,0(s0)
    4716:	e414                	sd	a3,8(s0)
    4718:	e818                	sd	a4,16(s0)
    471a:	ec1c                	sd	a5,24(s0)
    471c:	03043023          	sd	a6,32(s0)
    4720:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    4724:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    4728:	8622                	mv	a2,s0
    472a:	00000097          	auipc	ra,0x0
    472e:	e04080e7          	jalr	-508(ra) # 452e <vprintf>
}
    4732:	60e2                	ld	ra,24(sp)
    4734:	6442                	ld	s0,16(sp)
    4736:	6161                	addi	sp,sp,80
    4738:	8082                	ret

000000000000473a <printf>:

void
printf(const char *fmt, ...)
{
    473a:	711d                	addi	sp,sp,-96
    473c:	ec06                	sd	ra,24(sp)
    473e:	e822                	sd	s0,16(sp)
    4740:	1000                	addi	s0,sp,32
    4742:	e40c                	sd	a1,8(s0)
    4744:	e810                	sd	a2,16(s0)
    4746:	ec14                	sd	a3,24(s0)
    4748:	f018                	sd	a4,32(s0)
    474a:	f41c                	sd	a5,40(s0)
    474c:	03043823          	sd	a6,48(s0)
    4750:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    4754:	00840613          	addi	a2,s0,8
    4758:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    475c:	85aa                	mv	a1,a0
    475e:	4505                	li	a0,1
    4760:	00000097          	auipc	ra,0x0
    4764:	dce080e7          	jalr	-562(ra) # 452e <vprintf>
}
    4768:	60e2                	ld	ra,24(sp)
    476a:	6442                	ld	s0,16(sp)
    476c:	6125                	addi	sp,sp,96
    476e:	8082                	ret

0000000000004770 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    4770:	1141                	addi	sp,sp,-16
    4772:	e422                	sd	s0,8(sp)
    4774:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    4776:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    477a:	00002797          	auipc	a5,0x2
    477e:	1ee7b783          	ld	a5,494(a5) # 6968 <freep>
    4782:	a805                	j	47b2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    4784:	4618                	lw	a4,8(a2)
    4786:	9db9                	addw	a1,a1,a4
    4788:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    478c:	6398                	ld	a4,0(a5)
    478e:	6318                	ld	a4,0(a4)
    4790:	fee53823          	sd	a4,-16(a0)
    4794:	a091                	j	47d8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    4796:	ff852703          	lw	a4,-8(a0)
    479a:	9e39                	addw	a2,a2,a4
    479c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    479e:	ff053703          	ld	a4,-16(a0)
    47a2:	e398                	sd	a4,0(a5)
    47a4:	a099                	j	47ea <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    47a6:	6398                	ld	a4,0(a5)
    47a8:	00e7e463          	bltu	a5,a4,47b0 <free+0x40>
    47ac:	00e6ea63          	bltu	a3,a4,47c0 <free+0x50>
{
    47b0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    47b2:	fed7fae3          	bgeu	a5,a3,47a6 <free+0x36>
    47b6:	6398                	ld	a4,0(a5)
    47b8:	00e6e463          	bltu	a3,a4,47c0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    47bc:	fee7eae3          	bltu	a5,a4,47b0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    47c0:	ff852583          	lw	a1,-8(a0)
    47c4:	6390                	ld	a2,0(a5)
    47c6:	02059713          	slli	a4,a1,0x20
    47ca:	9301                	srli	a4,a4,0x20
    47cc:	0712                	slli	a4,a4,0x4
    47ce:	9736                	add	a4,a4,a3
    47d0:	fae60ae3          	beq	a2,a4,4784 <free+0x14>
    bp->s.ptr = p->s.ptr;
    47d4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    47d8:	4790                	lw	a2,8(a5)
    47da:	02061713          	slli	a4,a2,0x20
    47de:	9301                	srli	a4,a4,0x20
    47e0:	0712                	slli	a4,a4,0x4
    47e2:	973e                	add	a4,a4,a5
    47e4:	fae689e3          	beq	a3,a4,4796 <free+0x26>
  } else
    p->s.ptr = bp;
    47e8:	e394                	sd	a3,0(a5)
  freep = p;
    47ea:	00002717          	auipc	a4,0x2
    47ee:	16f73f23          	sd	a5,382(a4) # 6968 <freep>
}
    47f2:	6422                	ld	s0,8(sp)
    47f4:	0141                	addi	sp,sp,16
    47f6:	8082                	ret

00000000000047f8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    47f8:	7139                	addi	sp,sp,-64
    47fa:	fc06                	sd	ra,56(sp)
    47fc:	f822                	sd	s0,48(sp)
    47fe:	f426                	sd	s1,40(sp)
    4800:	f04a                	sd	s2,32(sp)
    4802:	ec4e                	sd	s3,24(sp)
    4804:	e852                	sd	s4,16(sp)
    4806:	e456                	sd	s5,8(sp)
    4808:	e05a                	sd	s6,0(sp)
    480a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    480c:	02051493          	slli	s1,a0,0x20
    4810:	9081                	srli	s1,s1,0x20
    4812:	04bd                	addi	s1,s1,15
    4814:	8091                	srli	s1,s1,0x4
    4816:	0014899b          	addiw	s3,s1,1
    481a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    481c:	00002517          	auipc	a0,0x2
    4820:	14c53503          	ld	a0,332(a0) # 6968 <freep>
    4824:	c515                	beqz	a0,4850 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4826:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    4828:	4798                	lw	a4,8(a5)
    482a:	02977f63          	bgeu	a4,s1,4868 <malloc+0x70>
    482e:	8a4e                	mv	s4,s3
    4830:	0009871b          	sext.w	a4,s3
    4834:	6685                	lui	a3,0x1
    4836:	00d77363          	bgeu	a4,a3,483c <malloc+0x44>
    483a:	6a05                	lui	s4,0x1
    483c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    4840:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    4844:	00002917          	auipc	s2,0x2
    4848:	12490913          	addi	s2,s2,292 # 6968 <freep>
  if(p == (char*)-1)
    484c:	5afd                	li	s5,-1
    484e:	a88d                	j	48c0 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    4850:	00008797          	auipc	a5,0x8
    4854:	93078793          	addi	a5,a5,-1744 # c180 <base>
    4858:	00002717          	auipc	a4,0x2
    485c:	10f73823          	sd	a5,272(a4) # 6968 <freep>
    4860:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    4862:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    4866:	b7e1                	j	482e <malloc+0x36>
      if(p->s.size == nunits)
    4868:	02e48b63          	beq	s1,a4,489e <malloc+0xa6>
        p->s.size -= nunits;
    486c:	4137073b          	subw	a4,a4,s3
    4870:	c798                	sw	a4,8(a5)
        p += p->s.size;
    4872:	1702                	slli	a4,a4,0x20
    4874:	9301                	srli	a4,a4,0x20
    4876:	0712                	slli	a4,a4,0x4
    4878:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    487a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    487e:	00002717          	auipc	a4,0x2
    4882:	0ea73523          	sd	a0,234(a4) # 6968 <freep>
      return (void*)(p + 1);
    4886:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    488a:	70e2                	ld	ra,56(sp)
    488c:	7442                	ld	s0,48(sp)
    488e:	74a2                	ld	s1,40(sp)
    4890:	7902                	ld	s2,32(sp)
    4892:	69e2                	ld	s3,24(sp)
    4894:	6a42                	ld	s4,16(sp)
    4896:	6aa2                	ld	s5,8(sp)
    4898:	6b02                	ld	s6,0(sp)
    489a:	6121                	addi	sp,sp,64
    489c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    489e:	6398                	ld	a4,0(a5)
    48a0:	e118                	sd	a4,0(a0)
    48a2:	bff1                	j	487e <malloc+0x86>
  hp->s.size = nu;
    48a4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    48a8:	0541                	addi	a0,a0,16
    48aa:	00000097          	auipc	ra,0x0
    48ae:	ec6080e7          	jalr	-314(ra) # 4770 <free>
  return freep;
    48b2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    48b6:	d971                	beqz	a0,488a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    48b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    48ba:	4798                	lw	a4,8(a5)
    48bc:	fa9776e3          	bgeu	a4,s1,4868 <malloc+0x70>
    if(p == freep)
    48c0:	00093703          	ld	a4,0(s2)
    48c4:	853e                	mv	a0,a5
    48c6:	fef719e3          	bne	a4,a5,48b8 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    48ca:	8552                	mv	a0,s4
    48cc:	00000097          	auipc	ra,0x0
    48d0:	b5e080e7          	jalr	-1186(ra) # 442a <sbrk>
  if(p == (char*)-1)
    48d4:	fd5518e3          	bne	a0,s5,48a4 <malloc+0xac>
        return 0;
    48d8:	4501                	li	a0,0
    48da:	bf45                	j	488a <malloc+0x92>
