
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
       0:	00007797          	auipc	a5,0x7
       4:	b2878793          	addi	a5,a5,-1240 # 6b28 <uninit>
       8:	00009697          	auipc	a3,0x9
       c:	23068693          	addi	a3,a3,560 # 9238 <buf>
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
      2c:	bb050513          	addi	a0,a0,-1104 # 4bd8 <malloc+0x36e>
      30:	00004097          	auipc	ra,0x4
      34:	77c080e7          	jalr	1916(ra) # 47ac <printf>
      exit(1);
      38:	4505                	li	a0,1
      3a:	00004097          	auipc	ra,0x4
      3e:	3ea080e7          	jalr	1002(ra) # 4424 <exit>

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
      52:	ba250513          	addi	a0,a0,-1118 # 4bf0 <malloc+0x386>
      56:	00004097          	auipc	ra,0x4
      5a:	436080e7          	jalr	1078(ra) # 448c <mkdir>
      5e:	04054563          	bltz	a0,a8 <iputtest+0x66>
  if(chdir("iputdir") < 0){
      62:	00005517          	auipc	a0,0x5
      66:	b8e50513          	addi	a0,a0,-1138 # 4bf0 <malloc+0x386>
      6a:	00004097          	auipc	ra,0x4
      6e:	42a080e7          	jalr	1066(ra) # 4494 <chdir>
      72:	04054963          	bltz	a0,c4 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
      76:	00005517          	auipc	a0,0x5
      7a:	bba50513          	addi	a0,a0,-1094 # 4c30 <malloc+0x3c6>
      7e:	00004097          	auipc	ra,0x4
      82:	3f6080e7          	jalr	1014(ra) # 4474 <unlink>
      86:	04054d63          	bltz	a0,e0 <iputtest+0x9e>
  if(chdir("/") < 0){
      8a:	00005517          	auipc	a0,0x5
      8e:	bd650513          	addi	a0,a0,-1066 # 4c60 <malloc+0x3f6>
      92:	00004097          	auipc	ra,0x4
      96:	402080e7          	jalr	1026(ra) # 4494 <chdir>
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
      ae:	b4e50513          	addi	a0,a0,-1202 # 4bf8 <malloc+0x38e>
      b2:	00004097          	auipc	ra,0x4
      b6:	6fa080e7          	jalr	1786(ra) # 47ac <printf>
    exit(1);
      ba:	4505                	li	a0,1
      bc:	00004097          	auipc	ra,0x4
      c0:	368080e7          	jalr	872(ra) # 4424 <exit>
    printf("%s: chdir iputdir failed\n", s);
      c4:	85a6                	mv	a1,s1
      c6:	00005517          	auipc	a0,0x5
      ca:	b4a50513          	addi	a0,a0,-1206 # 4c10 <malloc+0x3a6>
      ce:	00004097          	auipc	ra,0x4
      d2:	6de080e7          	jalr	1758(ra) # 47ac <printf>
    exit(1);
      d6:	4505                	li	a0,1
      d8:	00004097          	auipc	ra,0x4
      dc:	34c080e7          	jalr	844(ra) # 4424 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
      e0:	85a6                	mv	a1,s1
      e2:	00005517          	auipc	a0,0x5
      e6:	b5e50513          	addi	a0,a0,-1186 # 4c40 <malloc+0x3d6>
      ea:	00004097          	auipc	ra,0x4
      ee:	6c2080e7          	jalr	1730(ra) # 47ac <printf>
    exit(1);
      f2:	4505                	li	a0,1
      f4:	00004097          	auipc	ra,0x4
      f8:	330080e7          	jalr	816(ra) # 4424 <exit>
    printf("%s: chdir / failed\n", s);
      fc:	85a6                	mv	a1,s1
      fe:	00005517          	auipc	a0,0x5
     102:	b6a50513          	addi	a0,a0,-1174 # 4c68 <malloc+0x3fe>
     106:	00004097          	auipc	ra,0x4
     10a:	6a6080e7          	jalr	1702(ra) # 47ac <printf>
    exit(1);
     10e:	4505                	li	a0,1
     110:	00004097          	auipc	ra,0x4
     114:	314080e7          	jalr	788(ra) # 4424 <exit>

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
     128:	b5c50513          	addi	a0,a0,-1188 # 4c80 <malloc+0x416>
     12c:	00004097          	auipc	ra,0x4
     130:	360080e7          	jalr	864(ra) # 448c <mkdir>
     134:	e549                	bnez	a0,1be <rmdot+0xa6>
  if(chdir("dots") != 0){
     136:	00005517          	auipc	a0,0x5
     13a:	b4a50513          	addi	a0,a0,-1206 # 4c80 <malloc+0x416>
     13e:	00004097          	auipc	ra,0x4
     142:	356080e7          	jalr	854(ra) # 4494 <chdir>
     146:	e951                	bnez	a0,1da <rmdot+0xc2>
  if(unlink(".") == 0){
     148:	00005517          	auipc	a0,0x5
     14c:	b7050513          	addi	a0,a0,-1168 # 4cb8 <malloc+0x44e>
     150:	00004097          	auipc	ra,0x4
     154:	324080e7          	jalr	804(ra) # 4474 <unlink>
     158:	cd59                	beqz	a0,1f6 <rmdot+0xde>
  if(unlink("..") == 0){
     15a:	00005517          	auipc	a0,0x5
     15e:	b7e50513          	addi	a0,a0,-1154 # 4cd8 <malloc+0x46e>
     162:	00004097          	auipc	ra,0x4
     166:	312080e7          	jalr	786(ra) # 4474 <unlink>
     16a:	c545                	beqz	a0,212 <rmdot+0xfa>
  if(chdir("/") != 0){
     16c:	00005517          	auipc	a0,0x5
     170:	af450513          	addi	a0,a0,-1292 # 4c60 <malloc+0x3f6>
     174:	00004097          	auipc	ra,0x4
     178:	320080e7          	jalr	800(ra) # 4494 <chdir>
     17c:	e94d                	bnez	a0,22e <rmdot+0x116>
  if(unlink("dots/.") == 0){
     17e:	00005517          	auipc	a0,0x5
     182:	b7a50513          	addi	a0,a0,-1158 # 4cf8 <malloc+0x48e>
     186:	00004097          	auipc	ra,0x4
     18a:	2ee080e7          	jalr	750(ra) # 4474 <unlink>
     18e:	cd55                	beqz	a0,24a <rmdot+0x132>
  if(unlink("dots/..") == 0){
     190:	00005517          	auipc	a0,0x5
     194:	b9050513          	addi	a0,a0,-1136 # 4d20 <malloc+0x4b6>
     198:	00004097          	auipc	ra,0x4
     19c:	2dc080e7          	jalr	732(ra) # 4474 <unlink>
     1a0:	c179                	beqz	a0,266 <rmdot+0x14e>
  if(unlink("dots") != 0){
     1a2:	00005517          	auipc	a0,0x5
     1a6:	ade50513          	addi	a0,a0,-1314 # 4c80 <malloc+0x416>
     1aa:	00004097          	auipc	ra,0x4
     1ae:	2ca080e7          	jalr	714(ra) # 4474 <unlink>
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
     1c4:	ac850513          	addi	a0,a0,-1336 # 4c88 <malloc+0x41e>
     1c8:	00004097          	auipc	ra,0x4
     1cc:	5e4080e7          	jalr	1508(ra) # 47ac <printf>
    exit(1);
     1d0:	4505                	li	a0,1
     1d2:	00004097          	auipc	ra,0x4
     1d6:	252080e7          	jalr	594(ra) # 4424 <exit>
    printf("%s: chdir dots failed\n", s);
     1da:	85a6                	mv	a1,s1
     1dc:	00005517          	auipc	a0,0x5
     1e0:	ac450513          	addi	a0,a0,-1340 # 4ca0 <malloc+0x436>
     1e4:	00004097          	auipc	ra,0x4
     1e8:	5c8080e7          	jalr	1480(ra) # 47ac <printf>
    exit(1);
     1ec:	4505                	li	a0,1
     1ee:	00004097          	auipc	ra,0x4
     1f2:	236080e7          	jalr	566(ra) # 4424 <exit>
    printf("%s: rm . worked!\n", s);
     1f6:	85a6                	mv	a1,s1
     1f8:	00005517          	auipc	a0,0x5
     1fc:	ac850513          	addi	a0,a0,-1336 # 4cc0 <malloc+0x456>
     200:	00004097          	auipc	ra,0x4
     204:	5ac080e7          	jalr	1452(ra) # 47ac <printf>
    exit(1);
     208:	4505                	li	a0,1
     20a:	00004097          	auipc	ra,0x4
     20e:	21a080e7          	jalr	538(ra) # 4424 <exit>
    printf("%s: rm .. worked!\n", s);
     212:	85a6                	mv	a1,s1
     214:	00005517          	auipc	a0,0x5
     218:	acc50513          	addi	a0,a0,-1332 # 4ce0 <malloc+0x476>
     21c:	00004097          	auipc	ra,0x4
     220:	590080e7          	jalr	1424(ra) # 47ac <printf>
    exit(1);
     224:	4505                	li	a0,1
     226:	00004097          	auipc	ra,0x4
     22a:	1fe080e7          	jalr	510(ra) # 4424 <exit>
    printf("%s: chdir / failed\n", s);
     22e:	85a6                	mv	a1,s1
     230:	00005517          	auipc	a0,0x5
     234:	a3850513          	addi	a0,a0,-1480 # 4c68 <malloc+0x3fe>
     238:	00004097          	auipc	ra,0x4
     23c:	574080e7          	jalr	1396(ra) # 47ac <printf>
    exit(1);
     240:	4505                	li	a0,1
     242:	00004097          	auipc	ra,0x4
     246:	1e2080e7          	jalr	482(ra) # 4424 <exit>
    printf("%s: unlink dots/. worked!\n", s);
     24a:	85a6                	mv	a1,s1
     24c:	00005517          	auipc	a0,0x5
     250:	ab450513          	addi	a0,a0,-1356 # 4d00 <malloc+0x496>
     254:	00004097          	auipc	ra,0x4
     258:	558080e7          	jalr	1368(ra) # 47ac <printf>
    exit(1);
     25c:	4505                	li	a0,1
     25e:	00004097          	auipc	ra,0x4
     262:	1c6080e7          	jalr	454(ra) # 4424 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
     266:	85a6                	mv	a1,s1
     268:	00005517          	auipc	a0,0x5
     26c:	ac050513          	addi	a0,a0,-1344 # 4d28 <malloc+0x4be>
     270:	00004097          	auipc	ra,0x4
     274:	53c080e7          	jalr	1340(ra) # 47ac <printf>
    exit(1);
     278:	4505                	li	a0,1
     27a:	00004097          	auipc	ra,0x4
     27e:	1aa080e7          	jalr	426(ra) # 4424 <exit>
    printf("%s: unlink dots failed!\n", s);
     282:	85a6                	mv	a1,s1
     284:	00005517          	auipc	a0,0x5
     288:	ac450513          	addi	a0,a0,-1340 # 4d48 <malloc+0x4de>
     28c:	00004097          	auipc	ra,0x4
     290:	520080e7          	jalr	1312(ra) # 47ac <printf>
    exit(1);
     294:	4505                	li	a0,1
     296:	00004097          	auipc	ra,0x4
     29a:	18e080e7          	jalr	398(ra) # 4424 <exit>

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
     2ae:	172080e7          	jalr	370(ra) # 441c <fork>
  if(pid < 0){
     2b2:	04054663          	bltz	a0,2fe <exitiputtest+0x60>
  if(pid == 0){
     2b6:	ed45                	bnez	a0,36e <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
     2b8:	00005517          	auipc	a0,0x5
     2bc:	93850513          	addi	a0,a0,-1736 # 4bf0 <malloc+0x386>
     2c0:	00004097          	auipc	ra,0x4
     2c4:	1cc080e7          	jalr	460(ra) # 448c <mkdir>
     2c8:	04054963          	bltz	a0,31a <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
     2cc:	00005517          	auipc	a0,0x5
     2d0:	92450513          	addi	a0,a0,-1756 # 4bf0 <malloc+0x386>
     2d4:	00004097          	auipc	ra,0x4
     2d8:	1c0080e7          	jalr	448(ra) # 4494 <chdir>
     2dc:	04054d63          	bltz	a0,336 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
     2e0:	00005517          	auipc	a0,0x5
     2e4:	95050513          	addi	a0,a0,-1712 # 4c30 <malloc+0x3c6>
     2e8:	00004097          	auipc	ra,0x4
     2ec:	18c080e7          	jalr	396(ra) # 4474 <unlink>
     2f0:	06054163          	bltz	a0,352 <exitiputtest+0xb4>
    exit(0);
     2f4:	4501                	li	a0,0
     2f6:	00004097          	auipc	ra,0x4
     2fa:	12e080e7          	jalr	302(ra) # 4424 <exit>
    printf("%s: fork failed\n", s);
     2fe:	85a6                	mv	a1,s1
     300:	00005517          	auipc	a0,0x5
     304:	a6850513          	addi	a0,a0,-1432 # 4d68 <malloc+0x4fe>
     308:	00004097          	auipc	ra,0x4
     30c:	4a4080e7          	jalr	1188(ra) # 47ac <printf>
    exit(1);
     310:	4505                	li	a0,1
     312:	00004097          	auipc	ra,0x4
     316:	112080e7          	jalr	274(ra) # 4424 <exit>
      printf("%s: mkdir failed\n", s);
     31a:	85a6                	mv	a1,s1
     31c:	00005517          	auipc	a0,0x5
     320:	8dc50513          	addi	a0,a0,-1828 # 4bf8 <malloc+0x38e>
     324:	00004097          	auipc	ra,0x4
     328:	488080e7          	jalr	1160(ra) # 47ac <printf>
      exit(1);
     32c:	4505                	li	a0,1
     32e:	00004097          	auipc	ra,0x4
     332:	0f6080e7          	jalr	246(ra) # 4424 <exit>
      printf("%s: child chdir failed\n", s);
     336:	85a6                	mv	a1,s1
     338:	00005517          	auipc	a0,0x5
     33c:	a4850513          	addi	a0,a0,-1464 # 4d80 <malloc+0x516>
     340:	00004097          	auipc	ra,0x4
     344:	46c080e7          	jalr	1132(ra) # 47ac <printf>
      exit(1);
     348:	4505                	li	a0,1
     34a:	00004097          	auipc	ra,0x4
     34e:	0da080e7          	jalr	218(ra) # 4424 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
     352:	85a6                	mv	a1,s1
     354:	00005517          	auipc	a0,0x5
     358:	8ec50513          	addi	a0,a0,-1812 # 4c40 <malloc+0x3d6>
     35c:	00004097          	auipc	ra,0x4
     360:	450080e7          	jalr	1104(ra) # 47ac <printf>
      exit(1);
     364:	4505                	li	a0,1
     366:	00004097          	auipc	ra,0x4
     36a:	0be080e7          	jalr	190(ra) # 4424 <exit>
  wait(&xstatus);
     36e:	fdc40513          	addi	a0,s0,-36
     372:	00004097          	auipc	ra,0x4
     376:	0ba080e7          	jalr	186(ra) # 442c <wait>
  exit(xstatus);
     37a:	fdc42503          	lw	a0,-36(s0)
     37e:	00004097          	auipc	ra,0x4
     382:	0a6080e7          	jalr	166(ra) # 4424 <exit>

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
     3a2:	07e080e7          	jalr	126(ra) # 441c <fork>
     3a6:	84aa                	mv	s1,a0
    if(pid < 0){
     3a8:	02054a63          	bltz	a0,3dc <exitwait+0x56>
    if(pid){
     3ac:	c151                	beqz	a0,430 <exitwait+0xaa>
      if(wait(&xstate) != pid){
     3ae:	fcc40513          	addi	a0,s0,-52
     3b2:	00004097          	auipc	ra,0x4
     3b6:	07a080e7          	jalr	122(ra) # 442c <wait>
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
     3e2:	98a50513          	addi	a0,a0,-1654 # 4d68 <malloc+0x4fe>
     3e6:	00004097          	auipc	ra,0x4
     3ea:	3c6080e7          	jalr	966(ra) # 47ac <printf>
      exit(1);
     3ee:	4505                	li	a0,1
     3f0:	00004097          	auipc	ra,0x4
     3f4:	034080e7          	jalr	52(ra) # 4424 <exit>
        printf("%s: wait wrong pid\n", s);
     3f8:	85d2                	mv	a1,s4
     3fa:	00005517          	auipc	a0,0x5
     3fe:	99e50513          	addi	a0,a0,-1634 # 4d98 <malloc+0x52e>
     402:	00004097          	auipc	ra,0x4
     406:	3aa080e7          	jalr	938(ra) # 47ac <printf>
        exit(1);
     40a:	4505                	li	a0,1
     40c:	00004097          	auipc	ra,0x4
     410:	018080e7          	jalr	24(ra) # 4424 <exit>
        printf("%s: wait wrong exit status\n", s);
     414:	85d2                	mv	a1,s4
     416:	00005517          	auipc	a0,0x5
     41a:	99a50513          	addi	a0,a0,-1638 # 4db0 <malloc+0x546>
     41e:	00004097          	auipc	ra,0x4
     422:	38e080e7          	jalr	910(ra) # 47ac <printf>
        exit(1);
     426:	4505                	li	a0,1
     428:	00004097          	auipc	ra,0x4
     42c:	ffc080e7          	jalr	-4(ra) # 4424 <exit>
      exit(i);
     430:	854a                	mv	a0,s2
     432:	00004097          	auipc	ra,0x4
     436:	ff2080e7          	jalr	-14(ra) # 4424 <exit>

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
     450:	fd0080e7          	jalr	-48(ra) # 441c <fork>
    if(pid1 < 0){
     454:	02054c63          	bltz	a0,48c <twochildren+0x52>
    if(pid1 == 0){
     458:	c921                	beqz	a0,4a8 <twochildren+0x6e>
      int pid2 = fork();
     45a:	00004097          	auipc	ra,0x4
     45e:	fc2080e7          	jalr	-62(ra) # 441c <fork>
      if(pid2 < 0){
     462:	04054763          	bltz	a0,4b0 <twochildren+0x76>
      if(pid2 == 0){
     466:	c13d                	beqz	a0,4cc <twochildren+0x92>
        wait(0);
     468:	4501                	li	a0,0
     46a:	00004097          	auipc	ra,0x4
     46e:	fc2080e7          	jalr	-62(ra) # 442c <wait>
        wait(0);
     472:	4501                	li	a0,0
     474:	00004097          	auipc	ra,0x4
     478:	fb8080e7          	jalr	-72(ra) # 442c <wait>
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
     492:	8da50513          	addi	a0,a0,-1830 # 4d68 <malloc+0x4fe>
     496:	00004097          	auipc	ra,0x4
     49a:	316080e7          	jalr	790(ra) # 47ac <printf>
      exit(1);
     49e:	4505                	li	a0,1
     4a0:	00004097          	auipc	ra,0x4
     4a4:	f84080e7          	jalr	-124(ra) # 4424 <exit>
      exit(0);
     4a8:	00004097          	auipc	ra,0x4
     4ac:	f7c080e7          	jalr	-132(ra) # 4424 <exit>
        printf("%s: fork failed\n", s);
     4b0:	85ca                	mv	a1,s2
     4b2:	00005517          	auipc	a0,0x5
     4b6:	8b650513          	addi	a0,a0,-1866 # 4d68 <malloc+0x4fe>
     4ba:	00004097          	auipc	ra,0x4
     4be:	2f2080e7          	jalr	754(ra) # 47ac <printf>
        exit(1);
     4c2:	4505                	li	a0,1
     4c4:	00004097          	auipc	ra,0x4
     4c8:	f60080e7          	jalr	-160(ra) # 4424 <exit>
        exit(0);
     4cc:	00004097          	auipc	ra,0x4
     4d0:	f58080e7          	jalr	-168(ra) # 4424 <exit>

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
     4e4:	f3c080e7          	jalr	-196(ra) # 441c <fork>
    if(pid < 0){
     4e8:	04054163          	bltz	a0,52a <forkfork+0x56>
    if(pid == 0){
     4ec:	cd29                	beqz	a0,546 <forkfork+0x72>
    int pid = fork();
     4ee:	00004097          	auipc	ra,0x4
     4f2:	f2e080e7          	jalr	-210(ra) # 441c <fork>
    if(pid < 0){
     4f6:	02054a63          	bltz	a0,52a <forkfork+0x56>
    if(pid == 0){
     4fa:	c531                	beqz	a0,546 <forkfork+0x72>
    wait(&xstatus);
     4fc:	fdc40513          	addi	a0,s0,-36
     500:	00004097          	auipc	ra,0x4
     504:	f2c080e7          	jalr	-212(ra) # 442c <wait>
    if(xstatus != 0) {
     508:	fdc42783          	lw	a5,-36(s0)
     50c:	ebbd                	bnez	a5,582 <forkfork+0xae>
    wait(&xstatus);
     50e:	fdc40513          	addi	a0,s0,-36
     512:	00004097          	auipc	ra,0x4
     516:	f1a080e7          	jalr	-230(ra) # 442c <wait>
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
     530:	8a450513          	addi	a0,a0,-1884 # 4dd0 <malloc+0x566>
     534:	00004097          	auipc	ra,0x4
     538:	278080e7          	jalr	632(ra) # 47ac <printf>
      exit(1);
     53c:	4505                	li	a0,1
     53e:	00004097          	auipc	ra,0x4
     542:	ee6080e7          	jalr	-282(ra) # 4424 <exit>
{
     546:	0c800493          	li	s1,200
        int pid1 = fork();
     54a:	00004097          	auipc	ra,0x4
     54e:	ed2080e7          	jalr	-302(ra) # 441c <fork>
        if(pid1 < 0){
     552:	00054f63          	bltz	a0,570 <forkfork+0x9c>
        if(pid1 == 0){
     556:	c115                	beqz	a0,57a <forkfork+0xa6>
        wait(0);
     558:	4501                	li	a0,0
     55a:	00004097          	auipc	ra,0x4
     55e:	ed2080e7          	jalr	-302(ra) # 442c <wait>
      for(int j = 0; j < 200; j++){
     562:	34fd                	addiw	s1,s1,-1
     564:	f0fd                	bnez	s1,54a <forkfork+0x76>
      exit(0);
     566:	4501                	li	a0,0
     568:	00004097          	auipc	ra,0x4
     56c:	ebc080e7          	jalr	-324(ra) # 4424 <exit>
          exit(1);
     570:	4505                	li	a0,1
     572:	00004097          	auipc	ra,0x4
     576:	eb2080e7          	jalr	-334(ra) # 4424 <exit>
          exit(0);
     57a:	00004097          	auipc	ra,0x4
     57e:	eaa080e7          	jalr	-342(ra) # 4424 <exit>
      printf("%s: fork in child failed", s);
     582:	85a6                	mv	a1,s1
     584:	00005517          	auipc	a0,0x5
     588:	85c50513          	addi	a0,a0,-1956 # 4de0 <malloc+0x576>
     58c:	00004097          	auipc	ra,0x4
     590:	220080e7          	jalr	544(ra) # 47ac <printf>
      exit(1);
     594:	4505                	li	a0,1
     596:	00004097          	auipc	ra,0x4
     59a:	e8e080e7          	jalr	-370(ra) # 4424 <exit>

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
     5b0:	e70080e7          	jalr	-400(ra) # 441c <fork>
    if(pid1 < 0){
     5b4:	00054f63          	bltz	a0,5d2 <reparent2+0x34>
    if(pid1 == 0){
     5b8:	c915                	beqz	a0,5ec <reparent2+0x4e>
    wait(0);
     5ba:	4501                	li	a0,0
     5bc:	00004097          	auipc	ra,0x4
     5c0:	e70080e7          	jalr	-400(ra) # 442c <wait>
  for(int i = 0; i < 800; i++){
     5c4:	34fd                	addiw	s1,s1,-1
     5c6:	f0fd                	bnez	s1,5ac <reparent2+0xe>
  exit(0);
     5c8:	4501                	li	a0,0
     5ca:	00004097          	auipc	ra,0x4
     5ce:	e5a080e7          	jalr	-422(ra) # 4424 <exit>
      printf("fork failed\n");
     5d2:	00005517          	auipc	a0,0x5
     5d6:	09650513          	addi	a0,a0,150 # 5668 <malloc+0xdfe>
     5da:	00004097          	auipc	ra,0x4
     5de:	1d2080e7          	jalr	466(ra) # 47ac <printf>
      exit(1);
     5e2:	4505                	li	a0,1
     5e4:	00004097          	auipc	ra,0x4
     5e8:	e40080e7          	jalr	-448(ra) # 4424 <exit>
      fork();
     5ec:	00004097          	auipc	ra,0x4
     5f0:	e30080e7          	jalr	-464(ra) # 441c <fork>
      fork();
     5f4:	00004097          	auipc	ra,0x4
     5f8:	e28080e7          	jalr	-472(ra) # 441c <fork>
      exit(0);
     5fc:	4501                	li	a0,0
     5fe:	00004097          	auipc	ra,0x4
     602:	e26080e7          	jalr	-474(ra) # 4424 <exit>

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
     620:	e00080e7          	jalr	-512(ra) # 441c <fork>
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
     636:	7e650513          	addi	a0,a0,2022 # 4e18 <malloc+0x5ae>
     63a:	00004097          	auipc	ra,0x4
     63e:	172080e7          	jalr	370(ra) # 47ac <printf>
    exit(1);
     642:	4505                	li	a0,1
     644:	00004097          	auipc	ra,0x4
     648:	de0080e7          	jalr	-544(ra) # 4424 <exit>
      exit(0);
     64c:	00004097          	auipc	ra,0x4
     650:	dd8080e7          	jalr	-552(ra) # 4424 <exit>
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
     668:	dc8080e7          	jalr	-568(ra) # 442c <wait>
     66c:	04054163          	bltz	a0,6ae <forktest+0xa8>
  for(; n > 0; n--){
     670:	34fd                	addiw	s1,s1,-1
     672:	f8e5                	bnez	s1,662 <forktest+0x5c>
  if(wait(0) != -1){
     674:	4501                	li	a0,0
     676:	00004097          	auipc	ra,0x4
     67a:	db6080e7          	jalr	-586(ra) # 442c <wait>
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
     698:	76c50513          	addi	a0,a0,1900 # 4e00 <malloc+0x596>
     69c:	00004097          	auipc	ra,0x4
     6a0:	110080e7          	jalr	272(ra) # 47ac <printf>
    exit(1);
     6a4:	4505                	li	a0,1
     6a6:	00004097          	auipc	ra,0x4
     6aa:	d7e080e7          	jalr	-642(ra) # 4424 <exit>
      printf("%s: wait stopped early\n", s);
     6ae:	85ce                	mv	a1,s3
     6b0:	00004517          	auipc	a0,0x4
     6b4:	79050513          	addi	a0,a0,1936 # 4e40 <malloc+0x5d6>
     6b8:	00004097          	auipc	ra,0x4
     6bc:	0f4080e7          	jalr	244(ra) # 47ac <printf>
      exit(1);
     6c0:	4505                	li	a0,1
     6c2:	00004097          	auipc	ra,0x4
     6c6:	d62080e7          	jalr	-670(ra) # 4424 <exit>
    printf("%s: wait got too many\n", s);
     6ca:	85ce                	mv	a1,s3
     6cc:	00004517          	auipc	a0,0x4
     6d0:	78c50513          	addi	a0,a0,1932 # 4e58 <malloc+0x5ee>
     6d4:	00004097          	auipc	ra,0x4
     6d8:	0d8080e7          	jalr	216(ra) # 47ac <printf>
    exit(1);
     6dc:	4505                	li	a0,1
     6de:	00004097          	auipc	ra,0x4
     6e2:	d46080e7          	jalr	-698(ra) # 4424 <exit>

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
     702:	35098993          	addi	s3,s3,848 # c350 <__BSS_END__+0x108>
     706:	1003d937          	lui	s2,0x1003d
     70a:	090e                	slli	s2,s2,0x3
     70c:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x10031238>
    pid = fork();
     710:	00004097          	auipc	ra,0x4
     714:	d0c080e7          	jalr	-756(ra) # 441c <fork>
    if(pid < 0){
     718:	02054963          	bltz	a0,74a <kernmem+0x64>
    if(pid == 0){
     71c:	c529                	beqz	a0,766 <kernmem+0x80>
    wait(&xstatus);
     71e:	fbc40513          	addi	a0,s0,-68
     722:	00004097          	auipc	ra,0x4
     726:	d0a080e7          	jalr	-758(ra) # 442c <wait>
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
     750:	61c50513          	addi	a0,a0,1564 # 4d68 <malloc+0x4fe>
     754:	00004097          	auipc	ra,0x4
     758:	058080e7          	jalr	88(ra) # 47ac <printf>
      exit(1);
     75c:	4505                	li	a0,1
     75e:	00004097          	auipc	ra,0x4
     762:	cc6080e7          	jalr	-826(ra) # 4424 <exit>
      printf("%s: oops could read %x = %x\n", a, *a);
     766:	0004c603          	lbu	a2,0(s1)
     76a:	85a6                	mv	a1,s1
     76c:	00004517          	auipc	a0,0x4
     770:	70450513          	addi	a0,a0,1796 # 4e70 <malloc+0x606>
     774:	00004097          	auipc	ra,0x4
     778:	038080e7          	jalr	56(ra) # 47ac <printf>
      exit(1);
     77c:	4505                	li	a0,1
     77e:	00004097          	auipc	ra,0x4
     782:	ca6080e7          	jalr	-858(ra) # 4424 <exit>
      exit(1);
     786:	4505                	li	a0,1
     788:	00004097          	auipc	ra,0x4
     78c:	c9c080e7          	jalr	-868(ra) # 4424 <exit>

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
     7a0:	c80080e7          	jalr	-896(ra) # 441c <fork>
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
     7b2:	c7e080e7          	jalr	-898(ra) # 442c <wait>
  if(xstatus == -1)  // kernel killed child?
     7b6:	fdc42503          	lw	a0,-36(s0)
     7ba:	57fd                	li	a5,-1
     7bc:	04f50663          	beq	a0,a5,808 <stacktest+0x78>
    exit(0);
  else
    exit(xstatus);
     7c0:	00004097          	auipc	ra,0x4
     7c4:	c64080e7          	jalr	-924(ra) # 4424 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
     7c8:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", *sp);
     7ca:	77fd                	lui	a5,0xfffff
     7cc:	97ba                	add	a5,a5,a4
     7ce:	0007c583          	lbu	a1,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff2db8>
     7d2:	00004517          	auipc	a0,0x4
     7d6:	6be50513          	addi	a0,a0,1726 # 4e90 <malloc+0x626>
     7da:	00004097          	auipc	ra,0x4
     7de:	fd2080e7          	jalr	-46(ra) # 47ac <printf>
    exit(1);
     7e2:	4505                	li	a0,1
     7e4:	00004097          	auipc	ra,0x4
     7e8:	c40080e7          	jalr	-960(ra) # 4424 <exit>
    printf("%s: fork failed\n", s);
     7ec:	85a6                	mv	a1,s1
     7ee:	00004517          	auipc	a0,0x4
     7f2:	57a50513          	addi	a0,a0,1402 # 4d68 <malloc+0x4fe>
     7f6:	00004097          	auipc	ra,0x4
     7fa:	fb6080e7          	jalr	-74(ra) # 47ac <printf>
    exit(1);
     7fe:	4505                	li	a0,1
     800:	00004097          	auipc	ra,0x4
     804:	c24080e7          	jalr	-988(ra) # 4424 <exit>
    exit(0);
     808:	4501                	li	a0,0
     80a:	00004097          	auipc	ra,0x4
     80e:	c1a080e7          	jalr	-998(ra) # 4424 <exit>

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
     822:	69a50513          	addi	a0,a0,1690 # 4eb8 <malloc+0x64e>
     826:	00004097          	auipc	ra,0x4
     82a:	c66080e7          	jalr	-922(ra) # 448c <mkdir>
     82e:	04054263          	bltz	a0,872 <openiputtest+0x60>
  pid = fork();
     832:	00004097          	auipc	ra,0x4
     836:	bea080e7          	jalr	-1046(ra) # 441c <fork>
  if(pid < 0){
     83a:	04054a63          	bltz	a0,88e <openiputtest+0x7c>
  if(pid == 0){
     83e:	e93d                	bnez	a0,8b4 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
     840:	4589                	li	a1,2
     842:	00004517          	auipc	a0,0x4
     846:	67650513          	addi	a0,a0,1654 # 4eb8 <malloc+0x64e>
     84a:	00004097          	auipc	ra,0x4
     84e:	c1a080e7          	jalr	-998(ra) # 4464 <open>
    if(fd >= 0){
     852:	04054c63          	bltz	a0,8aa <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
     856:	85a6                	mv	a1,s1
     858:	00004517          	auipc	a0,0x4
     85c:	68050513          	addi	a0,a0,1664 # 4ed8 <malloc+0x66e>
     860:	00004097          	auipc	ra,0x4
     864:	f4c080e7          	jalr	-180(ra) # 47ac <printf>
      exit(1);
     868:	4505                	li	a0,1
     86a:	00004097          	auipc	ra,0x4
     86e:	bba080e7          	jalr	-1094(ra) # 4424 <exit>
    printf("%s: mkdir oidir failed\n", s);
     872:	85a6                	mv	a1,s1
     874:	00004517          	auipc	a0,0x4
     878:	64c50513          	addi	a0,a0,1612 # 4ec0 <malloc+0x656>
     87c:	00004097          	auipc	ra,0x4
     880:	f30080e7          	jalr	-208(ra) # 47ac <printf>
    exit(1);
     884:	4505                	li	a0,1
     886:	00004097          	auipc	ra,0x4
     88a:	b9e080e7          	jalr	-1122(ra) # 4424 <exit>
    printf("%s: fork failed\n", s);
     88e:	85a6                	mv	a1,s1
     890:	00004517          	auipc	a0,0x4
     894:	4d850513          	addi	a0,a0,1240 # 4d68 <malloc+0x4fe>
     898:	00004097          	auipc	ra,0x4
     89c:	f14080e7          	jalr	-236(ra) # 47ac <printf>
    exit(1);
     8a0:	4505                	li	a0,1
     8a2:	00004097          	auipc	ra,0x4
     8a6:	b82080e7          	jalr	-1150(ra) # 4424 <exit>
    exit(0);
     8aa:	4501                	li	a0,0
     8ac:	00004097          	auipc	ra,0x4
     8b0:	b78080e7          	jalr	-1160(ra) # 4424 <exit>
  sleep(1);
     8b4:	4505                	li	a0,1
     8b6:	00004097          	auipc	ra,0x4
     8ba:	bfe080e7          	jalr	-1026(ra) # 44b4 <sleep>
  if(unlink("oidir") != 0){
     8be:	00004517          	auipc	a0,0x4
     8c2:	5fa50513          	addi	a0,a0,1530 # 4eb8 <malloc+0x64e>
     8c6:	00004097          	auipc	ra,0x4
     8ca:	bae080e7          	jalr	-1106(ra) # 4474 <unlink>
     8ce:	cd19                	beqz	a0,8ec <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
     8d0:	85a6                	mv	a1,s1
     8d2:	00004517          	auipc	a0,0x4
     8d6:	62e50513          	addi	a0,a0,1582 # 4f00 <malloc+0x696>
     8da:	00004097          	auipc	ra,0x4
     8de:	ed2080e7          	jalr	-302(ra) # 47ac <printf>
    exit(1);
     8e2:	4505                	li	a0,1
     8e4:	00004097          	auipc	ra,0x4
     8e8:	b40080e7          	jalr	-1216(ra) # 4424 <exit>
  wait(&xstatus);
     8ec:	fdc40513          	addi	a0,s0,-36
     8f0:	00004097          	auipc	ra,0x4
     8f4:	b3c080e7          	jalr	-1220(ra) # 442c <wait>
  exit(xstatus);
     8f8:	fdc42503          	lw	a0,-36(s0)
     8fc:	00004097          	auipc	ra,0x4
     900:	b28080e7          	jalr	-1240(ra) # 4424 <exit>

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
     916:	60650513          	addi	a0,a0,1542 # 4f18 <malloc+0x6ae>
     91a:	00004097          	auipc	ra,0x4
     91e:	b4a080e7          	jalr	-1206(ra) # 4464 <open>
  if(fd < 0){
     922:	02054663          	bltz	a0,94e <opentest+0x4a>
  close(fd);
     926:	00004097          	auipc	ra,0x4
     92a:	b26080e7          	jalr	-1242(ra) # 444c <close>
  fd = open("doesnotexist", 0);
     92e:	4581                	li	a1,0
     930:	00004517          	auipc	a0,0x4
     934:	60850513          	addi	a0,a0,1544 # 4f38 <malloc+0x6ce>
     938:	00004097          	auipc	ra,0x4
     93c:	b2c080e7          	jalr	-1236(ra) # 4464 <open>
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
     954:	5d050513          	addi	a0,a0,1488 # 4f20 <malloc+0x6b6>
     958:	00004097          	auipc	ra,0x4
     95c:	e54080e7          	jalr	-428(ra) # 47ac <printf>
    exit(1);
     960:	4505                	li	a0,1
     962:	00004097          	auipc	ra,0x4
     966:	ac2080e7          	jalr	-1342(ra) # 4424 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     96a:	85a6                	mv	a1,s1
     96c:	00004517          	auipc	a0,0x4
     970:	5dc50513          	addi	a0,a0,1500 # 4f48 <malloc+0x6de>
     974:	00004097          	auipc	ra,0x4
     978:	e38080e7          	jalr	-456(ra) # 47ac <printf>
    exit(1);
     97c:	4505                	li	a0,1
     97e:	00004097          	auipc	ra,0x4
     982:	aa6080e7          	jalr	-1370(ra) # 4424 <exit>

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
     998:	08478793          	addi	a5,a5,132 # 6a18 <name>
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
     9c0:	aa8080e7          	jalr	-1368(ra) # 4464 <open>
    close(fd);
     9c4:	00004097          	auipc	ra,0x4
     9c8:	a88080e7          	jalr	-1400(ra) # 444c <close>
  for(i = 0; i < N; i++){
     9cc:	2485                	addiw	s1,s1,1
     9ce:	0ff4f493          	andi	s1,s1,255
     9d2:	ff3490e3          	bne	s1,s3,9b2 <createtest+0x2c>
  name[0] = 'a';
     9d6:	00006797          	auipc	a5,0x6
     9da:	04278793          	addi	a5,a5,66 # 6a18 <name>
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
     9fe:	a7a080e7          	jalr	-1414(ra) # 4474 <unlink>
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
     a2a:	54a50513          	addi	a0,a0,1354 # 4f70 <malloc+0x706>
     a2e:	00004097          	auipc	ra,0x4
     a32:	a46080e7          	jalr	-1466(ra) # 4474 <unlink>
  int pid = fork();
     a36:	00004097          	auipc	ra,0x4
     a3a:	9e6080e7          	jalr	-1562(ra) # 441c <fork>
  if(pid < 0){
     a3e:	04054563          	bltz	a0,a88 <forkforkfork+0x6e>
  if(pid == 0){
     a42:	c12d                	beqz	a0,aa4 <forkforkfork+0x8a>
  sleep(20); // two seconds
     a44:	4551                	li	a0,20
     a46:	00004097          	auipc	ra,0x4
     a4a:	a6e080e7          	jalr	-1426(ra) # 44b4 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
     a4e:	20200593          	li	a1,514
     a52:	00004517          	auipc	a0,0x4
     a56:	51e50513          	addi	a0,a0,1310 # 4f70 <malloc+0x706>
     a5a:	00004097          	auipc	ra,0x4
     a5e:	a0a080e7          	jalr	-1526(ra) # 4464 <open>
     a62:	00004097          	auipc	ra,0x4
     a66:	9ea080e7          	jalr	-1558(ra) # 444c <close>
  wait(0);
     a6a:	4501                	li	a0,0
     a6c:	00004097          	auipc	ra,0x4
     a70:	9c0080e7          	jalr	-1600(ra) # 442c <wait>
  sleep(10); // one second
     a74:	4529                	li	a0,10
     a76:	00004097          	auipc	ra,0x4
     a7a:	a3e080e7          	jalr	-1474(ra) # 44b4 <sleep>
}
     a7e:	60e2                	ld	ra,24(sp)
     a80:	6442                	ld	s0,16(sp)
     a82:	64a2                	ld	s1,8(sp)
     a84:	6105                	addi	sp,sp,32
     a86:	8082                	ret
    printf("%s: fork failed", s);
     a88:	85a6                	mv	a1,s1
     a8a:	00004517          	auipc	a0,0x4
     a8e:	34650513          	addi	a0,a0,838 # 4dd0 <malloc+0x566>
     a92:	00004097          	auipc	ra,0x4
     a96:	d1a080e7          	jalr	-742(ra) # 47ac <printf>
    exit(1);
     a9a:	4505                	li	a0,1
     a9c:	00004097          	auipc	ra,0x4
     aa0:	988080e7          	jalr	-1656(ra) # 4424 <exit>
      int fd = open("stopforking", 0);
     aa4:	00004497          	auipc	s1,0x4
     aa8:	4cc48493          	addi	s1,s1,1228 # 4f70 <malloc+0x706>
     aac:	4581                	li	a1,0
     aae:	8526                	mv	a0,s1
     ab0:	00004097          	auipc	ra,0x4
     ab4:	9b4080e7          	jalr	-1612(ra) # 4464 <open>
      if(fd >= 0){
     ab8:	02055463          	bgez	a0,ae0 <forkforkfork+0xc6>
      if(fork() < 0){
     abc:	00004097          	auipc	ra,0x4
     ac0:	960080e7          	jalr	-1696(ra) # 441c <fork>
     ac4:	fe0554e3          	bgez	a0,aac <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
     ac8:	20200593          	li	a1,514
     acc:	8526                	mv	a0,s1
     ace:	00004097          	auipc	ra,0x4
     ad2:	996080e7          	jalr	-1642(ra) # 4464 <open>
     ad6:	00004097          	auipc	ra,0x4
     ada:	976080e7          	jalr	-1674(ra) # 444c <close>
     ade:	b7f9                	j	aac <forkforkfork+0x92>
        exit(0);
     ae0:	4501                	li	a0,0
     ae2:	00004097          	auipc	ra,0x4
     ae6:	942080e7          	jalr	-1726(ra) # 4424 <exit>

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
     b0e:	912080e7          	jalr	-1774(ra) # 441c <fork>
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
     b2a:	906080e7          	jalr	-1786(ra) # 442c <wait>
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
     b58:	b1450513          	addi	a0,a0,-1260 # 5668 <malloc+0xdfe>
     b5c:	00004097          	auipc	ra,0x4
     b60:	c50080e7          	jalr	-944(ra) # 47ac <printf>
      exit(1);
     b64:	4505                	li	a0,1
     b66:	00004097          	auipc	ra,0x4
     b6a:	8be080e7          	jalr	-1858(ra) # 4424 <exit>
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
     b84:	40050513          	addi	a0,a0,1024 # 4f80 <malloc+0x716>
     b88:	00004097          	auipc	ra,0x4
     b8c:	c24080e7          	jalr	-988(ra) # 47ac <printf>
          exit(1);
     b90:	4505                	li	a0,1
     b92:	00004097          	auipc	ra,0x4
     b96:	892080e7          	jalr	-1902(ra) # 4424 <exit>
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
     bb4:	8b4080e7          	jalr	-1868(ra) # 4464 <open>
        if(fd < 0){
     bb8:	fc0543e3          	bltz	a0,b7e <createdelete+0x94>
        close(fd);
     bbc:	00004097          	auipc	ra,0x4
     bc0:	890080e7          	jalr	-1904(ra) # 444c <close>
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
     be8:	890080e7          	jalr	-1904(ra) # 4474 <unlink>
     bec:	fa0557e3          	bgez	a0,b9a <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
     bf0:	85e6                	mv	a1,s9
     bf2:	00004517          	auipc	a0,0x4
     bf6:	30e50513          	addi	a0,a0,782 # 4f00 <malloc+0x696>
     bfa:	00004097          	auipc	ra,0x4
     bfe:	bb2080e7          	jalr	-1102(ra) # 47ac <printf>
            exit(1);
     c02:	4505                	li	a0,1
     c04:	00004097          	auipc	ra,0x4
     c08:	820080e7          	jalr	-2016(ra) # 4424 <exit>
      exit(0);
     c0c:	4501                	li	a0,0
     c0e:	00004097          	auipc	ra,0x4
     c12:	816080e7          	jalr	-2026(ra) # 4424 <exit>
      exit(1);
     c16:	4505                	li	a0,1
     c18:	00004097          	auipc	ra,0x4
     c1c:	80c080e7          	jalr	-2036(ra) # 4424 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
     c20:	f8040613          	addi	a2,s0,-128
     c24:	85e6                	mv	a1,s9
     c26:	00004517          	auipc	a0,0x4
     c2a:	37250513          	addi	a0,a0,882 # 4f98 <malloc+0x72e>
     c2e:	00004097          	auipc	ra,0x4
     c32:	b7e080e7          	jalr	-1154(ra) # 47ac <printf>
        exit(1);
     c36:	4505                	li	a0,1
     c38:	00003097          	auipc	ra,0x3
     c3c:	7ec080e7          	jalr	2028(ra) # 4424 <exit>
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
     c60:	00004097          	auipc	ra,0x4
     c64:	804080e7          	jalr	-2044(ra) # 4464 <open>
      if((i == 0 || i >= N/2) && fd < 0){
     c68:	00090463          	beqz	s2,c70 <createdelete+0x186>
     c6c:	fd2bdae3          	bge	s7,s2,c40 <createdelete+0x156>
     c70:	fa0548e3          	bltz	a0,c20 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
     c74:	014b7963          	bgeu	s6,s4,c86 <createdelete+0x19c>
        close(fd);
     c78:	00003097          	auipc	ra,0x3
     c7c:	7d4080e7          	jalr	2004(ra) # 444c <close>
     c80:	b7e1                	j	c48 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
     c82:	fc0543e3          	bltz	a0,c48 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
     c86:	f8040613          	addi	a2,s0,-128
     c8a:	85e6                	mv	a1,s9
     c8c:	00004517          	auipc	a0,0x4
     c90:	33450513          	addi	a0,a0,820 # 4fc0 <malloc+0x756>
     c94:	00004097          	auipc	ra,0x4
     c98:	b18080e7          	jalr	-1256(ra) # 47ac <printf>
        exit(1);
     c9c:	4505                	li	a0,1
     c9e:	00003097          	auipc	ra,0x3
     ca2:	786080e7          	jalr	1926(ra) # 4424 <exit>
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
     cdc:	79c080e7          	jalr	1948(ra) # 4474 <unlink>
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
     d20:	49c50513          	addi	a0,a0,1180 # 51b8 <malloc+0x94e>
     d24:	00003097          	auipc	ra,0x3
     d28:	768080e7          	jalr	1896(ra) # 448c <mkdir>
     d2c:	e141                	bnez	a0,dac <fourteen+0x9c>
  if(mkdir("12345678901234/123456789012345") != 0){
     d2e:	00004517          	auipc	a0,0x4
     d32:	2e250513          	addi	a0,a0,738 # 5010 <malloc+0x7a6>
     d36:	00003097          	auipc	ra,0x3
     d3a:	756080e7          	jalr	1878(ra) # 448c <mkdir>
     d3e:	e549                	bnez	a0,dc8 <fourteen+0xb8>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
     d40:	20000593          	li	a1,512
     d44:	00004517          	auipc	a0,0x4
     d48:	32450513          	addi	a0,a0,804 # 5068 <malloc+0x7fe>
     d4c:	00003097          	auipc	ra,0x3
     d50:	718080e7          	jalr	1816(ra) # 4464 <open>
  if(fd < 0){
     d54:	08054863          	bltz	a0,de4 <fourteen+0xd4>
  close(fd);
     d58:	00003097          	auipc	ra,0x3
     d5c:	6f4080e7          	jalr	1780(ra) # 444c <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
     d60:	4581                	li	a1,0
     d62:	00004517          	auipc	a0,0x4
     d66:	37e50513          	addi	a0,a0,894 # 50e0 <malloc+0x876>
     d6a:	00003097          	auipc	ra,0x3
     d6e:	6fa080e7          	jalr	1786(ra) # 4464 <open>
  if(fd < 0){
     d72:	08054763          	bltz	a0,e00 <fourteen+0xf0>
  close(fd);
     d76:	00003097          	auipc	ra,0x3
     d7a:	6d6080e7          	jalr	1750(ra) # 444c <close>
  if(mkdir("12345678901234/12345678901234") == 0){
     d7e:	00004517          	auipc	a0,0x4
     d82:	3d250513          	addi	a0,a0,978 # 5150 <malloc+0x8e6>
     d86:	00003097          	auipc	ra,0x3
     d8a:	706080e7          	jalr	1798(ra) # 448c <mkdir>
     d8e:	c559                	beqz	a0,e1c <fourteen+0x10c>
  if(mkdir("123456789012345/12345678901234") == 0){
     d90:	00004517          	auipc	a0,0x4
     d94:	41850513          	addi	a0,a0,1048 # 51a8 <malloc+0x93e>
     d98:	00003097          	auipc	ra,0x3
     d9c:	6f4080e7          	jalr	1780(ra) # 448c <mkdir>
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
     db2:	23a50513          	addi	a0,a0,570 # 4fe8 <malloc+0x77e>
     db6:	00004097          	auipc	ra,0x4
     dba:	9f6080e7          	jalr	-1546(ra) # 47ac <printf>
    exit(1);
     dbe:	4505                	li	a0,1
     dc0:	00003097          	auipc	ra,0x3
     dc4:	664080e7          	jalr	1636(ra) # 4424 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
     dc8:	85a6                	mv	a1,s1
     dca:	00004517          	auipc	a0,0x4
     dce:	26650513          	addi	a0,a0,614 # 5030 <malloc+0x7c6>
     dd2:	00004097          	auipc	ra,0x4
     dd6:	9da080e7          	jalr	-1574(ra) # 47ac <printf>
    exit(1);
     dda:	4505                	li	a0,1
     ddc:	00003097          	auipc	ra,0x3
     de0:	648080e7          	jalr	1608(ra) # 4424 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
     de4:	85a6                	mv	a1,s1
     de6:	00004517          	auipc	a0,0x4
     dea:	2b250513          	addi	a0,a0,690 # 5098 <malloc+0x82e>
     dee:	00004097          	auipc	ra,0x4
     df2:	9be080e7          	jalr	-1602(ra) # 47ac <printf>
    exit(1);
     df6:	4505                	li	a0,1
     df8:	00003097          	auipc	ra,0x3
     dfc:	62c080e7          	jalr	1580(ra) # 4424 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
     e00:	85a6                	mv	a1,s1
     e02:	00004517          	auipc	a0,0x4
     e06:	30e50513          	addi	a0,a0,782 # 5110 <malloc+0x8a6>
     e0a:	00004097          	auipc	ra,0x4
     e0e:	9a2080e7          	jalr	-1630(ra) # 47ac <printf>
    exit(1);
     e12:	4505                	li	a0,1
     e14:	00003097          	auipc	ra,0x3
     e18:	610080e7          	jalr	1552(ra) # 4424 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
     e1c:	85a6                	mv	a1,s1
     e1e:	00004517          	auipc	a0,0x4
     e22:	35250513          	addi	a0,a0,850 # 5170 <malloc+0x906>
     e26:	00004097          	auipc	ra,0x4
     e2a:	986080e7          	jalr	-1658(ra) # 47ac <printf>
    exit(1);
     e2e:	4505                	li	a0,1
     e30:	00003097          	auipc	ra,0x3
     e34:	5f4080e7          	jalr	1524(ra) # 4424 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
     e38:	85a6                	mv	a1,s1
     e3a:	00004517          	auipc	a0,0x4
     e3e:	38e50513          	addi	a0,a0,910 # 51c8 <malloc+0x95e>
     e42:	00004097          	auipc	ra,0x4
     e46:	96a080e7          	jalr	-1686(ra) # 47ac <printf>
    exit(1);
     e4a:	4505                	li	a0,1
     e4c:	00003097          	auipc	ra,0x3
     e50:	5d8080e7          	jalr	1496(ra) # 4424 <exit>

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
     e70:	c1c50513          	addi	a0,a0,-996 # 4a88 <malloc+0x21e>
     e74:	00003097          	auipc	ra,0x3
     e78:	600080e7          	jalr	1536(ra) # 4474 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     e7c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     e80:	00004a97          	auipc	s5,0x4
     e84:	c08a8a93          	addi	s5,s5,-1016 # 4a88 <malloc+0x21e>
      int cc = write(fd, buf, sz);
     e88:	00008a17          	auipc	s4,0x8
     e8c:	3b0a0a13          	addi	s4,s4,944 # 9238 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     e90:	6b0d                	lui	s6,0x3
     e92:	1c9b0b13          	addi	s6,s6,457 # 31c9 <dirfile+0x25>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     e96:	20200593          	li	a1,514
     e9a:	8556                	mv	a0,s5
     e9c:	00003097          	auipc	ra,0x3
     ea0:	5c8080e7          	jalr	1480(ra) # 4464 <open>
     ea4:	892a                	mv	s2,a0
    if(fd < 0){
     ea6:	04054d63          	bltz	a0,f00 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     eaa:	8626                	mv	a2,s1
     eac:	85d2                	mv	a1,s4
     eae:	00003097          	auipc	ra,0x3
     eb2:	596080e7          	jalr	1430(ra) # 4444 <write>
     eb6:	89aa                	mv	s3,a0
      if(cc != sz){
     eb8:	06a49463          	bne	s1,a0,f20 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     ebc:	8626                	mv	a2,s1
     ebe:	85d2                	mv	a1,s4
     ec0:	854a                	mv	a0,s2
     ec2:	00003097          	auipc	ra,0x3
     ec6:	582080e7          	jalr	1410(ra) # 4444 <write>
      if(cc != sz){
     eca:	04951963          	bne	a0,s1,f1c <bigwrite+0xc8>
    close(fd);
     ece:	854a                	mv	a0,s2
     ed0:	00003097          	auipc	ra,0x3
     ed4:	57c080e7          	jalr	1404(ra) # 444c <close>
    unlink("bigwrite");
     ed8:	8556                	mv	a0,s5
     eda:	00003097          	auipc	ra,0x3
     ede:	59a080e7          	jalr	1434(ra) # 4474 <unlink>
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
     f06:	2fe50513          	addi	a0,a0,766 # 5200 <malloc+0x996>
     f0a:	00004097          	auipc	ra,0x4
     f0e:	8a2080e7          	jalr	-1886(ra) # 47ac <printf>
      exit(1);
     f12:	4505                	li	a0,1
     f14:	00003097          	auipc	ra,0x3
     f18:	510080e7          	jalr	1296(ra) # 4424 <exit>
     f1c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     f1e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     f20:	86ce                	mv	a3,s3
     f22:	8626                	mv	a2,s1
     f24:	85de                	mv	a1,s7
     f26:	00004517          	auipc	a0,0x4
     f2a:	2fa50513          	addi	a0,a0,762 # 5220 <malloc+0x9b6>
     f2e:	00004097          	auipc	ra,0x4
     f32:	87e080e7          	jalr	-1922(ra) # 47ac <printf>
        exit(1);
     f36:	4505                	li	a0,1
     f38:	00003097          	auipc	ra,0x3
     f3c:	4ec080e7          	jalr	1260(ra) # 4424 <exit>

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
     f5e:	2de50513          	addi	a0,a0,734 # 5238 <malloc+0x9ce>
     f62:	00003097          	auipc	ra,0x3
     f66:	502080e7          	jalr	1282(ra) # 4464 <open>
  if(fd < 0){
     f6a:	0a054d63          	bltz	a0,1024 <writetest+0xe4>
     f6e:	892a                	mv	s2,a0
     f70:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     f72:	00004997          	auipc	s3,0x4
     f76:	2ee98993          	addi	s3,s3,750 # 5260 <malloc+0x9f6>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     f7a:	00004a97          	auipc	s5,0x4
     f7e:	31ea8a93          	addi	s5,s5,798 # 5298 <malloc+0xa2e>
  for(i = 0; i < N; i++){
     f82:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     f86:	4629                	li	a2,10
     f88:	85ce                	mv	a1,s3
     f8a:	854a                	mv	a0,s2
     f8c:	00003097          	auipc	ra,0x3
     f90:	4b8080e7          	jalr	1208(ra) # 4444 <write>
     f94:	47a9                	li	a5,10
     f96:	0af51563          	bne	a0,a5,1040 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     f9a:	4629                	li	a2,10
     f9c:	85d6                	mv	a1,s5
     f9e:	854a                	mv	a0,s2
     fa0:	00003097          	auipc	ra,0x3
     fa4:	4a4080e7          	jalr	1188(ra) # 4444 <write>
     fa8:	47a9                	li	a5,10
     faa:	0af51963          	bne	a0,a5,105c <writetest+0x11c>
  for(i = 0; i < N; i++){
     fae:	2485                	addiw	s1,s1,1
     fb0:	fd449be3          	bne	s1,s4,f86 <writetest+0x46>
  close(fd);
     fb4:	854a                	mv	a0,s2
     fb6:	00003097          	auipc	ra,0x3
     fba:	496080e7          	jalr	1174(ra) # 444c <close>
  fd = open("small", O_RDONLY);
     fbe:	4581                	li	a1,0
     fc0:	00004517          	auipc	a0,0x4
     fc4:	27850513          	addi	a0,a0,632 # 5238 <malloc+0x9ce>
     fc8:	00003097          	auipc	ra,0x3
     fcc:	49c080e7          	jalr	1180(ra) # 4464 <open>
     fd0:	84aa                	mv	s1,a0
  if(fd < 0){
     fd2:	0a054363          	bltz	a0,1078 <writetest+0x138>
  i = read(fd, buf, N*SZ*2);
     fd6:	7d000613          	li	a2,2000
     fda:	00008597          	auipc	a1,0x8
     fde:	25e58593          	addi	a1,a1,606 # 9238 <buf>
     fe2:	00003097          	auipc	ra,0x3
     fe6:	45a080e7          	jalr	1114(ra) # 443c <read>
  if(i != N*SZ*2){
     fea:	7d000793          	li	a5,2000
     fee:	0af51363          	bne	a0,a5,1094 <writetest+0x154>
  close(fd);
     ff2:	8526                	mv	a0,s1
     ff4:	00003097          	auipc	ra,0x3
     ff8:	458080e7          	jalr	1112(ra) # 444c <close>
  if(unlink("small") < 0){
     ffc:	00004517          	auipc	a0,0x4
    1000:	23c50513          	addi	a0,a0,572 # 5238 <malloc+0x9ce>
    1004:	00003097          	auipc	ra,0x3
    1008:	470080e7          	jalr	1136(ra) # 4474 <unlink>
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
    102a:	21a50513          	addi	a0,a0,538 # 5240 <malloc+0x9d6>
    102e:	00003097          	auipc	ra,0x3
    1032:	77e080e7          	jalr	1918(ra) # 47ac <printf>
    exit(1);
    1036:	4505                	li	a0,1
    1038:	00003097          	auipc	ra,0x3
    103c:	3ec080e7          	jalr	1004(ra) # 4424 <exit>
      printf("%s: error: write aa %d new file failed\n", i);
    1040:	85a6                	mv	a1,s1
    1042:	00004517          	auipc	a0,0x4
    1046:	22e50513          	addi	a0,a0,558 # 5270 <malloc+0xa06>
    104a:	00003097          	auipc	ra,0x3
    104e:	762080e7          	jalr	1890(ra) # 47ac <printf>
      exit(1);
    1052:	4505                	li	a0,1
    1054:	00003097          	auipc	ra,0x3
    1058:	3d0080e7          	jalr	976(ra) # 4424 <exit>
      printf("%s: error: write bb %d new file failed\n", i);
    105c:	85a6                	mv	a1,s1
    105e:	00004517          	auipc	a0,0x4
    1062:	24a50513          	addi	a0,a0,586 # 52a8 <malloc+0xa3e>
    1066:	00003097          	auipc	ra,0x3
    106a:	746080e7          	jalr	1862(ra) # 47ac <printf>
      exit(1);
    106e:	4505                	li	a0,1
    1070:	00003097          	auipc	ra,0x3
    1074:	3b4080e7          	jalr	948(ra) # 4424 <exit>
    printf("%s: error: open small failed!\n", s);
    1078:	85da                	mv	a1,s6
    107a:	00004517          	auipc	a0,0x4
    107e:	25650513          	addi	a0,a0,598 # 52d0 <malloc+0xa66>
    1082:	00003097          	auipc	ra,0x3
    1086:	72a080e7          	jalr	1834(ra) # 47ac <printf>
    exit(1);
    108a:	4505                	li	a0,1
    108c:	00003097          	auipc	ra,0x3
    1090:	398080e7          	jalr	920(ra) # 4424 <exit>
    printf("%s: read failed\n", s);
    1094:	85da                	mv	a1,s6
    1096:	00004517          	auipc	a0,0x4
    109a:	25a50513          	addi	a0,a0,602 # 52f0 <malloc+0xa86>
    109e:	00003097          	auipc	ra,0x3
    10a2:	70e080e7          	jalr	1806(ra) # 47ac <printf>
    exit(1);
    10a6:	4505                	li	a0,1
    10a8:	00003097          	auipc	ra,0x3
    10ac:	37c080e7          	jalr	892(ra) # 4424 <exit>
    printf("%s: unlink small failed\n", s);
    10b0:	85da                	mv	a1,s6
    10b2:	00004517          	auipc	a0,0x4
    10b6:	25650513          	addi	a0,a0,598 # 5308 <malloc+0xa9e>
    10ba:	00003097          	auipc	ra,0x3
    10be:	6f2080e7          	jalr	1778(ra) # 47ac <printf>
    exit(1);
    10c2:	4505                	li	a0,1
    10c4:	00003097          	auipc	ra,0x3
    10c8:	360080e7          	jalr	864(ra) # 4424 <exit>

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
    10e8:	24450513          	addi	a0,a0,580 # 5328 <malloc+0xabe>
    10ec:	00003097          	auipc	ra,0x3
    10f0:	378080e7          	jalr	888(ra) # 4464 <open>
  if(fd < 0){
    10f4:	08054563          	bltz	a0,117e <writebig+0xb2>
    10f8:	89aa                	mv	s3,a0
    10fa:	4481                	li	s1,0
    ((int*)buf)[0] = i;
    10fc:	00008917          	auipc	s2,0x8
    1100:	13c90913          	addi	s2,s2,316 # 9238 <buf>
  for(i = 0; i < MAXFILE; i++){
    1104:	6a41                	lui	s4,0x10
    1106:	10ba0a13          	addi	s4,s4,267 # 1010b <__BSS_END__+0x3ec3>
    ((int*)buf)[0] = i;
    110a:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
    110e:	40000613          	li	a2,1024
    1112:	85ca                	mv	a1,s2
    1114:	854e                	mv	a0,s3
    1116:	00003097          	auipc	ra,0x3
    111a:	32e080e7          	jalr	814(ra) # 4444 <write>
    111e:	40000793          	li	a5,1024
    1122:	06f51c63          	bne	a0,a5,119a <writebig+0xce>
  for(i = 0; i < MAXFILE; i++){
    1126:	2485                	addiw	s1,s1,1
    1128:	ff4491e3          	bne	s1,s4,110a <writebig+0x3e>
  close(fd);
    112c:	854e                	mv	a0,s3
    112e:	00003097          	auipc	ra,0x3
    1132:	31e080e7          	jalr	798(ra) # 444c <close>
  fd = open("big", O_RDONLY);
    1136:	4581                	li	a1,0
    1138:	00004517          	auipc	a0,0x4
    113c:	1f050513          	addi	a0,a0,496 # 5328 <malloc+0xabe>
    1140:	00003097          	auipc	ra,0x3
    1144:	324080e7          	jalr	804(ra) # 4464 <open>
    1148:	89aa                	mv	s3,a0
  n = 0;
    114a:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
    114c:	00008917          	auipc	s2,0x8
    1150:	0ec90913          	addi	s2,s2,236 # 9238 <buf>
  if(fd < 0){
    1154:	06054163          	bltz	a0,11b6 <writebig+0xea>
    i = read(fd, buf, BSIZE);
    1158:	40000613          	li	a2,1024
    115c:	85ca                	mv	a1,s2
    115e:	854e                	mv	a0,s3
    1160:	00003097          	auipc	ra,0x3
    1164:	2dc080e7          	jalr	732(ra) # 443c <read>
    if(i == 0){
    1168:	c52d                	beqz	a0,11d2 <writebig+0x106>
    } else if(i != BSIZE){
    116a:	40000793          	li	a5,1024
    116e:	0af51d63          	bne	a0,a5,1228 <writebig+0x15c>
    if(((int*)buf)[0] != n){
    1172:	00092603          	lw	a2,0(s2)
    1176:	0c961763          	bne	a2,s1,1244 <writebig+0x178>
    n++;
    117a:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
    117c:	bff1                	j	1158 <writebig+0x8c>
    printf("%s: error: creat big failed!\n", s);
    117e:	85d6                	mv	a1,s5
    1180:	00004517          	auipc	a0,0x4
    1184:	1b050513          	addi	a0,a0,432 # 5330 <malloc+0xac6>
    1188:	00003097          	auipc	ra,0x3
    118c:	624080e7          	jalr	1572(ra) # 47ac <printf>
    exit(1);
    1190:	4505                	li	a0,1
    1192:	00003097          	auipc	ra,0x3
    1196:	292080e7          	jalr	658(ra) # 4424 <exit>
      printf("%s: error: write big file failed\n", i);
    119a:	85a6                	mv	a1,s1
    119c:	00004517          	auipc	a0,0x4
    11a0:	1b450513          	addi	a0,a0,436 # 5350 <malloc+0xae6>
    11a4:	00003097          	auipc	ra,0x3
    11a8:	608080e7          	jalr	1544(ra) # 47ac <printf>
      exit(1);
    11ac:	4505                	li	a0,1
    11ae:	00003097          	auipc	ra,0x3
    11b2:	276080e7          	jalr	630(ra) # 4424 <exit>
    printf("%s: error: open big failed!\n", s);
    11b6:	85d6                	mv	a1,s5
    11b8:	00004517          	auipc	a0,0x4
    11bc:	1c050513          	addi	a0,a0,448 # 5378 <malloc+0xb0e>
    11c0:	00003097          	auipc	ra,0x3
    11c4:	5ec080e7          	jalr	1516(ra) # 47ac <printf>
    exit(1);
    11c8:	4505                	li	a0,1
    11ca:	00003097          	auipc	ra,0x3
    11ce:	25a080e7          	jalr	602(ra) # 4424 <exit>
      if(n == MAXFILE - 1){
    11d2:	67c1                	lui	a5,0x10
    11d4:	10a78793          	addi	a5,a5,266 # 1010a <__BSS_END__+0x3ec2>
    11d8:	02f48a63          	beq	s1,a5,120c <writebig+0x140>
  close(fd);
    11dc:	854e                	mv	a0,s3
    11de:	00003097          	auipc	ra,0x3
    11e2:	26e080e7          	jalr	622(ra) # 444c <close>
  if(unlink("big") < 0){
    11e6:	00004517          	auipc	a0,0x4
    11ea:	14250513          	addi	a0,a0,322 # 5328 <malloc+0xabe>
    11ee:	00003097          	auipc	ra,0x3
    11f2:	286080e7          	jalr	646(ra) # 4474 <unlink>
    11f6:	06054563          	bltz	a0,1260 <writebig+0x194>
}
    11fa:	70e2                	ld	ra,56(sp)
    11fc:	7442                	ld	s0,48(sp)
    11fe:	74a2                	ld	s1,40(sp)
    1200:	7902                	ld	s2,32(sp)
    1202:	69e2                	ld	s3,24(sp)
    1204:	6a42                	ld	s4,16(sp)
    1206:	6aa2                	ld	s5,8(sp)
    1208:	6121                	addi	sp,sp,64
    120a:	8082                	ret
        printf("%s: read only %d blocks from big", n);
    120c:	85be                	mv	a1,a5
    120e:	00004517          	auipc	a0,0x4
    1212:	18a50513          	addi	a0,a0,394 # 5398 <malloc+0xb2e>
    1216:	00003097          	auipc	ra,0x3
    121a:	596080e7          	jalr	1430(ra) # 47ac <printf>
        exit(1);
    121e:	4505                	li	a0,1
    1220:	00003097          	auipc	ra,0x3
    1224:	204080e7          	jalr	516(ra) # 4424 <exit>
      printf("%s: read failed %d\n", i);
    1228:	85aa                	mv	a1,a0
    122a:	00004517          	auipc	a0,0x4
    122e:	19650513          	addi	a0,a0,406 # 53c0 <malloc+0xb56>
    1232:	00003097          	auipc	ra,0x3
    1236:	57a080e7          	jalr	1402(ra) # 47ac <printf>
      exit(1);
    123a:	4505                	li	a0,1
    123c:	00003097          	auipc	ra,0x3
    1240:	1e8080e7          	jalr	488(ra) # 4424 <exit>
      printf("%s: read content of block %d is %d\n",
    1244:	85a6                	mv	a1,s1
    1246:	00004517          	auipc	a0,0x4
    124a:	19250513          	addi	a0,a0,402 # 53d8 <malloc+0xb6e>
    124e:	00003097          	auipc	ra,0x3
    1252:	55e080e7          	jalr	1374(ra) # 47ac <printf>
      exit(1);
    1256:	4505                	li	a0,1
    1258:	00003097          	auipc	ra,0x3
    125c:	1cc080e7          	jalr	460(ra) # 4424 <exit>
    printf("%s: unlink big failed\n", s);
    1260:	85d6                	mv	a1,s5
    1262:	00004517          	auipc	a0,0x4
    1266:	19e50513          	addi	a0,a0,414 # 5400 <malloc+0xb96>
    126a:	00003097          	auipc	ra,0x3
    126e:	542080e7          	jalr	1346(ra) # 47ac <printf>
    exit(1);
    1272:	4505                	li	a0,1
    1274:	00003097          	auipc	ra,0x3
    1278:	1b0080e7          	jalr	432(ra) # 4424 <exit>

000000000000127c <unlinkread>:
{
    127c:	7179                	addi	sp,sp,-48
    127e:	f406                	sd	ra,40(sp)
    1280:	f022                	sd	s0,32(sp)
    1282:	ec26                	sd	s1,24(sp)
    1284:	e84a                	sd	s2,16(sp)
    1286:	e44e                	sd	s3,8(sp)
    1288:	1800                	addi	s0,sp,48
    128a:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
    128c:	20200593          	li	a1,514
    1290:	00003517          	auipc	a0,0x3
    1294:	79050513          	addi	a0,a0,1936 # 4a20 <malloc+0x1b6>
    1298:	00003097          	auipc	ra,0x3
    129c:	1cc080e7          	jalr	460(ra) # 4464 <open>
  if(fd < 0){
    12a0:	0e054563          	bltz	a0,138a <unlinkread+0x10e>
    12a4:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
    12a6:	4615                	li	a2,5
    12a8:	00004597          	auipc	a1,0x4
    12ac:	19058593          	addi	a1,a1,400 # 5438 <malloc+0xbce>
    12b0:	00003097          	auipc	ra,0x3
    12b4:	194080e7          	jalr	404(ra) # 4444 <write>
  close(fd);
    12b8:	8526                	mv	a0,s1
    12ba:	00003097          	auipc	ra,0x3
    12be:	192080e7          	jalr	402(ra) # 444c <close>
  fd = open("unlinkread", O_RDWR);
    12c2:	4589                	li	a1,2
    12c4:	00003517          	auipc	a0,0x3
    12c8:	75c50513          	addi	a0,a0,1884 # 4a20 <malloc+0x1b6>
    12cc:	00003097          	auipc	ra,0x3
    12d0:	198080e7          	jalr	408(ra) # 4464 <open>
    12d4:	84aa                	mv	s1,a0
  if(fd < 0){
    12d6:	0c054863          	bltz	a0,13a6 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
    12da:	00003517          	auipc	a0,0x3
    12de:	74650513          	addi	a0,a0,1862 # 4a20 <malloc+0x1b6>
    12e2:	00003097          	auipc	ra,0x3
    12e6:	192080e7          	jalr	402(ra) # 4474 <unlink>
    12ea:	ed61                	bnez	a0,13c2 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    12ec:	20200593          	li	a1,514
    12f0:	00003517          	auipc	a0,0x3
    12f4:	73050513          	addi	a0,a0,1840 # 4a20 <malloc+0x1b6>
    12f8:	00003097          	auipc	ra,0x3
    12fc:	16c080e7          	jalr	364(ra) # 4464 <open>
    1300:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
    1302:	460d                	li	a2,3
    1304:	00004597          	auipc	a1,0x4
    1308:	17c58593          	addi	a1,a1,380 # 5480 <malloc+0xc16>
    130c:	00003097          	auipc	ra,0x3
    1310:	138080e7          	jalr	312(ra) # 4444 <write>
  close(fd1);
    1314:	854a                	mv	a0,s2
    1316:	00003097          	auipc	ra,0x3
    131a:	136080e7          	jalr	310(ra) # 444c <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
    131e:	660d                	lui	a2,0x3
    1320:	00008597          	auipc	a1,0x8
    1324:	f1858593          	addi	a1,a1,-232 # 9238 <buf>
    1328:	8526                	mv	a0,s1
    132a:	00003097          	auipc	ra,0x3
    132e:	112080e7          	jalr	274(ra) # 443c <read>
    1332:	4795                	li	a5,5
    1334:	0af51563          	bne	a0,a5,13de <unlinkread+0x162>
  if(buf[0] != 'h'){
    1338:	00008717          	auipc	a4,0x8
    133c:	f0074703          	lbu	a4,-256(a4) # 9238 <buf>
    1340:	06800793          	li	a5,104
    1344:	0af71b63          	bne	a4,a5,13fa <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
    1348:	4629                	li	a2,10
    134a:	00008597          	auipc	a1,0x8
    134e:	eee58593          	addi	a1,a1,-274 # 9238 <buf>
    1352:	8526                	mv	a0,s1
    1354:	00003097          	auipc	ra,0x3
    1358:	0f0080e7          	jalr	240(ra) # 4444 <write>
    135c:	47a9                	li	a5,10
    135e:	0af51c63          	bne	a0,a5,1416 <unlinkread+0x19a>
  close(fd);
    1362:	8526                	mv	a0,s1
    1364:	00003097          	auipc	ra,0x3
    1368:	0e8080e7          	jalr	232(ra) # 444c <close>
  unlink("unlinkread");
    136c:	00003517          	auipc	a0,0x3
    1370:	6b450513          	addi	a0,a0,1716 # 4a20 <malloc+0x1b6>
    1374:	00003097          	auipc	ra,0x3
    1378:	100080e7          	jalr	256(ra) # 4474 <unlink>
}
    137c:	70a2                	ld	ra,40(sp)
    137e:	7402                	ld	s0,32(sp)
    1380:	64e2                	ld	s1,24(sp)
    1382:	6942                	ld	s2,16(sp)
    1384:	69a2                	ld	s3,8(sp)
    1386:	6145                	addi	sp,sp,48
    1388:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
    138a:	85ce                	mv	a1,s3
    138c:	00004517          	auipc	a0,0x4
    1390:	08c50513          	addi	a0,a0,140 # 5418 <malloc+0xbae>
    1394:	00003097          	auipc	ra,0x3
    1398:	418080e7          	jalr	1048(ra) # 47ac <printf>
    exit(1);
    139c:	4505                	li	a0,1
    139e:	00003097          	auipc	ra,0x3
    13a2:	086080e7          	jalr	134(ra) # 4424 <exit>
    printf("%s: open unlinkread failed\n", s);
    13a6:	85ce                	mv	a1,s3
    13a8:	00004517          	auipc	a0,0x4
    13ac:	09850513          	addi	a0,a0,152 # 5440 <malloc+0xbd6>
    13b0:	00003097          	auipc	ra,0x3
    13b4:	3fc080e7          	jalr	1020(ra) # 47ac <printf>
    exit(1);
    13b8:	4505                	li	a0,1
    13ba:	00003097          	auipc	ra,0x3
    13be:	06a080e7          	jalr	106(ra) # 4424 <exit>
    printf("%s: unlink unlinkread failed\n", s);
    13c2:	85ce                	mv	a1,s3
    13c4:	00004517          	auipc	a0,0x4
    13c8:	09c50513          	addi	a0,a0,156 # 5460 <malloc+0xbf6>
    13cc:	00003097          	auipc	ra,0x3
    13d0:	3e0080e7          	jalr	992(ra) # 47ac <printf>
    exit(1);
    13d4:	4505                	li	a0,1
    13d6:	00003097          	auipc	ra,0x3
    13da:	04e080e7          	jalr	78(ra) # 4424 <exit>
    printf("%s: unlinkread read failed", s);
    13de:	85ce                	mv	a1,s3
    13e0:	00004517          	auipc	a0,0x4
    13e4:	0a850513          	addi	a0,a0,168 # 5488 <malloc+0xc1e>
    13e8:	00003097          	auipc	ra,0x3
    13ec:	3c4080e7          	jalr	964(ra) # 47ac <printf>
    exit(1);
    13f0:	4505                	li	a0,1
    13f2:	00003097          	auipc	ra,0x3
    13f6:	032080e7          	jalr	50(ra) # 4424 <exit>
    printf("%s: unlinkread wrong data\n", s);
    13fa:	85ce                	mv	a1,s3
    13fc:	00004517          	auipc	a0,0x4
    1400:	0ac50513          	addi	a0,a0,172 # 54a8 <malloc+0xc3e>
    1404:	00003097          	auipc	ra,0x3
    1408:	3a8080e7          	jalr	936(ra) # 47ac <printf>
    exit(1);
    140c:	4505                	li	a0,1
    140e:	00003097          	auipc	ra,0x3
    1412:	016080e7          	jalr	22(ra) # 4424 <exit>
    printf("%s: unlinkread write failed\n", s);
    1416:	85ce                	mv	a1,s3
    1418:	00004517          	auipc	a0,0x4
    141c:	0b050513          	addi	a0,a0,176 # 54c8 <malloc+0xc5e>
    1420:	00003097          	auipc	ra,0x3
    1424:	38c080e7          	jalr	908(ra) # 47ac <printf>
    exit(1);
    1428:	4505                	li	a0,1
    142a:	00003097          	auipc	ra,0x3
    142e:	ffa080e7          	jalr	-6(ra) # 4424 <exit>

0000000000001432 <exectest>:
{
    1432:	715d                	addi	sp,sp,-80
    1434:	e486                	sd	ra,72(sp)
    1436:	e0a2                	sd	s0,64(sp)
    1438:	fc26                	sd	s1,56(sp)
    143a:	f84a                	sd	s2,48(sp)
    143c:	0880                	addi	s0,sp,80
    143e:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1440:	00004797          	auipc	a5,0x4
    1444:	ad878793          	addi	a5,a5,-1320 # 4f18 <malloc+0x6ae>
    1448:	fcf43023          	sd	a5,-64(s0)
    144c:	00004797          	auipc	a5,0x4
    1450:	09c78793          	addi	a5,a5,156 # 54e8 <malloc+0xc7e>
    1454:	fcf43423          	sd	a5,-56(s0)
    1458:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    145c:	00004517          	auipc	a0,0x4
    1460:	09450513          	addi	a0,a0,148 # 54f0 <malloc+0xc86>
    1464:	00003097          	auipc	ra,0x3
    1468:	010080e7          	jalr	16(ra) # 4474 <unlink>
  pid = fork();
    146c:	00003097          	auipc	ra,0x3
    1470:	fb0080e7          	jalr	-80(ra) # 441c <fork>
  if(pid < 0) {
    1474:	04054663          	bltz	a0,14c0 <exectest+0x8e>
    1478:	84aa                	mv	s1,a0
  if(pid == 0) {
    147a:	e959                	bnez	a0,1510 <exectest+0xde>
    close(1);
    147c:	4505                	li	a0,1
    147e:	00003097          	auipc	ra,0x3
    1482:	fce080e7          	jalr	-50(ra) # 444c <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1486:	20100593          	li	a1,513
    148a:	00004517          	auipc	a0,0x4
    148e:	06650513          	addi	a0,a0,102 # 54f0 <malloc+0xc86>
    1492:	00003097          	auipc	ra,0x3
    1496:	fd2080e7          	jalr	-46(ra) # 4464 <open>
    if(fd < 0) {
    149a:	04054163          	bltz	a0,14dc <exectest+0xaa>
    if(fd != 1) {
    149e:	4785                	li	a5,1
    14a0:	04f50c63          	beq	a0,a5,14f8 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    14a4:	85ca                	mv	a1,s2
    14a6:	00004517          	auipc	a0,0x4
    14aa:	05250513          	addi	a0,a0,82 # 54f8 <malloc+0xc8e>
    14ae:	00003097          	auipc	ra,0x3
    14b2:	2fe080e7          	jalr	766(ra) # 47ac <printf>
      exit(1);
    14b6:	4505                	li	a0,1
    14b8:	00003097          	auipc	ra,0x3
    14bc:	f6c080e7          	jalr	-148(ra) # 4424 <exit>
     printf("%s: fork failed\n", s);
    14c0:	85ca                	mv	a1,s2
    14c2:	00004517          	auipc	a0,0x4
    14c6:	8a650513          	addi	a0,a0,-1882 # 4d68 <malloc+0x4fe>
    14ca:	00003097          	auipc	ra,0x3
    14ce:	2e2080e7          	jalr	738(ra) # 47ac <printf>
     exit(1);
    14d2:	4505                	li	a0,1
    14d4:	00003097          	auipc	ra,0x3
    14d8:	f50080e7          	jalr	-176(ra) # 4424 <exit>
      printf("%s: create failed\n", s);
    14dc:	85ca                	mv	a1,s2
    14de:	00004517          	auipc	a0,0x4
    14e2:	aa250513          	addi	a0,a0,-1374 # 4f80 <malloc+0x716>
    14e6:	00003097          	auipc	ra,0x3
    14ea:	2c6080e7          	jalr	710(ra) # 47ac <printf>
      exit(1);
    14ee:	4505                	li	a0,1
    14f0:	00003097          	auipc	ra,0x3
    14f4:	f34080e7          	jalr	-204(ra) # 4424 <exit>
    if(exec("echo", echoargv) < 0){
    14f8:	fc040593          	addi	a1,s0,-64
    14fc:	00004517          	auipc	a0,0x4
    1500:	a1c50513          	addi	a0,a0,-1508 # 4f18 <malloc+0x6ae>
    1504:	00003097          	auipc	ra,0x3
    1508:	f58080e7          	jalr	-168(ra) # 445c <exec>
    150c:	02054163          	bltz	a0,152e <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1510:	fdc40513          	addi	a0,s0,-36
    1514:	00003097          	auipc	ra,0x3
    1518:	f18080e7          	jalr	-232(ra) # 442c <wait>
    151c:	02951763          	bne	a0,s1,154a <exectest+0x118>
  if(xstatus != 0)
    1520:	fdc42503          	lw	a0,-36(s0)
    1524:	cd0d                	beqz	a0,155e <exectest+0x12c>
    exit(xstatus);
    1526:	00003097          	auipc	ra,0x3
    152a:	efe080e7          	jalr	-258(ra) # 4424 <exit>
      printf("%s: exec echo failed\n", s);
    152e:	85ca                	mv	a1,s2
    1530:	00004517          	auipc	a0,0x4
    1534:	fd850513          	addi	a0,a0,-40 # 5508 <malloc+0xc9e>
    1538:	00003097          	auipc	ra,0x3
    153c:	274080e7          	jalr	628(ra) # 47ac <printf>
      exit(1);
    1540:	4505                	li	a0,1
    1542:	00003097          	auipc	ra,0x3
    1546:	ee2080e7          	jalr	-286(ra) # 4424 <exit>
    printf("%s: wait failed!\n", s);
    154a:	85ca                	mv	a1,s2
    154c:	00004517          	auipc	a0,0x4
    1550:	fd450513          	addi	a0,a0,-44 # 5520 <malloc+0xcb6>
    1554:	00003097          	auipc	ra,0x3
    1558:	258080e7          	jalr	600(ra) # 47ac <printf>
    155c:	b7d1                	j	1520 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    155e:	4581                	li	a1,0
    1560:	00004517          	auipc	a0,0x4
    1564:	f9050513          	addi	a0,a0,-112 # 54f0 <malloc+0xc86>
    1568:	00003097          	auipc	ra,0x3
    156c:	efc080e7          	jalr	-260(ra) # 4464 <open>
  if(fd < 0) {
    1570:	02054a63          	bltz	a0,15a4 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    1574:	4609                	li	a2,2
    1576:	fb840593          	addi	a1,s0,-72
    157a:	00003097          	auipc	ra,0x3
    157e:	ec2080e7          	jalr	-318(ra) # 443c <read>
    1582:	4789                	li	a5,2
    1584:	02f50e63          	beq	a0,a5,15c0 <exectest+0x18e>
    printf("%s: read failed\n", s);
    1588:	85ca                	mv	a1,s2
    158a:	00004517          	auipc	a0,0x4
    158e:	d6650513          	addi	a0,a0,-666 # 52f0 <malloc+0xa86>
    1592:	00003097          	auipc	ra,0x3
    1596:	21a080e7          	jalr	538(ra) # 47ac <printf>
    exit(1);
    159a:	4505                	li	a0,1
    159c:	00003097          	auipc	ra,0x3
    15a0:	e88080e7          	jalr	-376(ra) # 4424 <exit>
    printf("%s: open failed\n", s);
    15a4:	85ca                	mv	a1,s2
    15a6:	00004517          	auipc	a0,0x4
    15aa:	f9250513          	addi	a0,a0,-110 # 5538 <malloc+0xcce>
    15ae:	00003097          	auipc	ra,0x3
    15b2:	1fe080e7          	jalr	510(ra) # 47ac <printf>
    exit(1);
    15b6:	4505                	li	a0,1
    15b8:	00003097          	auipc	ra,0x3
    15bc:	e6c080e7          	jalr	-404(ra) # 4424 <exit>
  unlink("echo-ok");
    15c0:	00004517          	auipc	a0,0x4
    15c4:	f3050513          	addi	a0,a0,-208 # 54f0 <malloc+0xc86>
    15c8:	00003097          	auipc	ra,0x3
    15cc:	eac080e7          	jalr	-340(ra) # 4474 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    15d0:	fb844703          	lbu	a4,-72(s0)
    15d4:	04f00793          	li	a5,79
    15d8:	00f71863          	bne	a4,a5,15e8 <exectest+0x1b6>
    15dc:	fb944703          	lbu	a4,-71(s0)
    15e0:	04b00793          	li	a5,75
    15e4:	02f70063          	beq	a4,a5,1604 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    15e8:	85ca                	mv	a1,s2
    15ea:	00004517          	auipc	a0,0x4
    15ee:	f6650513          	addi	a0,a0,-154 # 5550 <malloc+0xce6>
    15f2:	00003097          	auipc	ra,0x3
    15f6:	1ba080e7          	jalr	442(ra) # 47ac <printf>
    exit(1);
    15fa:	4505                	li	a0,1
    15fc:	00003097          	auipc	ra,0x3
    1600:	e28080e7          	jalr	-472(ra) # 4424 <exit>
    exit(0);
    1604:	4501                	li	a0,0
    1606:	00003097          	auipc	ra,0x3
    160a:	e1e080e7          	jalr	-482(ra) # 4424 <exit>

000000000000160e <bigargtest>:
{
    160e:	7179                	addi	sp,sp,-48
    1610:	f406                	sd	ra,40(sp)
    1612:	f022                	sd	s0,32(sp)
    1614:	ec26                	sd	s1,24(sp)
    1616:	1800                	addi	s0,sp,48
    1618:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    161a:	00004517          	auipc	a0,0x4
    161e:	f4e50513          	addi	a0,a0,-178 # 5568 <malloc+0xcfe>
    1622:	00003097          	auipc	ra,0x3
    1626:	e52080e7          	jalr	-430(ra) # 4474 <unlink>
  pid = fork();
    162a:	00003097          	auipc	ra,0x3
    162e:	df2080e7          	jalr	-526(ra) # 441c <fork>
  if(pid == 0){
    1632:	c121                	beqz	a0,1672 <bigargtest+0x64>
  } else if(pid < 0){
    1634:	0a054063          	bltz	a0,16d4 <bigargtest+0xc6>
  wait(&xstatus);
    1638:	fdc40513          	addi	a0,s0,-36
    163c:	00003097          	auipc	ra,0x3
    1640:	df0080e7          	jalr	-528(ra) # 442c <wait>
  if(xstatus != 0)
    1644:	fdc42503          	lw	a0,-36(s0)
    1648:	e545                	bnez	a0,16f0 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    164a:	4581                	li	a1,0
    164c:	00004517          	auipc	a0,0x4
    1650:	f1c50513          	addi	a0,a0,-228 # 5568 <malloc+0xcfe>
    1654:	00003097          	auipc	ra,0x3
    1658:	e10080e7          	jalr	-496(ra) # 4464 <open>
  if(fd < 0){
    165c:	08054e63          	bltz	a0,16f8 <bigargtest+0xea>
  close(fd);
    1660:	00003097          	auipc	ra,0x3
    1664:	dec080e7          	jalr	-532(ra) # 444c <close>
}
    1668:	70a2                	ld	ra,40(sp)
    166a:	7402                	ld	s0,32(sp)
    166c:	64e2                	ld	s1,24(sp)
    166e:	6145                	addi	sp,sp,48
    1670:	8082                	ret
    1672:	00005797          	auipc	a5,0x5
    1676:	3b678793          	addi	a5,a5,950 # 6a28 <args.0>
    167a:	00005697          	auipc	a3,0x5
    167e:	4a668693          	addi	a3,a3,1190 # 6b20 <args.0+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    1682:	00004717          	auipc	a4,0x4
    1686:	ef670713          	addi	a4,a4,-266 # 5578 <malloc+0xd0e>
    168a:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    168c:	07a1                	addi	a5,a5,8
    168e:	fed79ee3          	bne	a5,a3,168a <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    1692:	00005597          	auipc	a1,0x5
    1696:	39658593          	addi	a1,a1,918 # 6a28 <args.0>
    169a:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    169e:	00004517          	auipc	a0,0x4
    16a2:	87a50513          	addi	a0,a0,-1926 # 4f18 <malloc+0x6ae>
    16a6:	00003097          	auipc	ra,0x3
    16aa:	db6080e7          	jalr	-586(ra) # 445c <exec>
    fd = open("bigarg-ok", O_CREATE);
    16ae:	20000593          	li	a1,512
    16b2:	00004517          	auipc	a0,0x4
    16b6:	eb650513          	addi	a0,a0,-330 # 5568 <malloc+0xcfe>
    16ba:	00003097          	auipc	ra,0x3
    16be:	daa080e7          	jalr	-598(ra) # 4464 <open>
    close(fd);
    16c2:	00003097          	auipc	ra,0x3
    16c6:	d8a080e7          	jalr	-630(ra) # 444c <close>
    exit(0);
    16ca:	4501                	li	a0,0
    16cc:	00003097          	auipc	ra,0x3
    16d0:	d58080e7          	jalr	-680(ra) # 4424 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    16d4:	85a6                	mv	a1,s1
    16d6:	00004517          	auipc	a0,0x4
    16da:	f8250513          	addi	a0,a0,-126 # 5658 <malloc+0xdee>
    16de:	00003097          	auipc	ra,0x3
    16e2:	0ce080e7          	jalr	206(ra) # 47ac <printf>
    exit(1);
    16e6:	4505                	li	a0,1
    16e8:	00003097          	auipc	ra,0x3
    16ec:	d3c080e7          	jalr	-708(ra) # 4424 <exit>
    exit(xstatus);
    16f0:	00003097          	auipc	ra,0x3
    16f4:	d34080e7          	jalr	-716(ra) # 4424 <exit>
    printf("%s: bigarg test failed!\n", s);
    16f8:	85a6                	mv	a1,s1
    16fa:	00004517          	auipc	a0,0x4
    16fe:	f7e50513          	addi	a0,a0,-130 # 5678 <malloc+0xe0e>
    1702:	00003097          	auipc	ra,0x3
    1706:	0aa080e7          	jalr	170(ra) # 47ac <printf>
    exit(1);
    170a:	4505                	li	a0,1
    170c:	00003097          	auipc	ra,0x3
    1710:	d18080e7          	jalr	-744(ra) # 4424 <exit>

0000000000001714 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1714:	7139                	addi	sp,sp,-64
    1716:	fc06                	sd	ra,56(sp)
    1718:	f822                	sd	s0,48(sp)
    171a:	f426                	sd	s1,40(sp)
    171c:	f04a                	sd	s2,32(sp)
    171e:	ec4e                	sd	s3,24(sp)
    1720:	0080                	addi	s0,sp,64
    1722:	64b1                	lui	s1,0xc
    1724:	35048493          	addi	s1,s1,848 # c350 <__BSS_END__+0x108>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1728:	597d                	li	s2,-1
    172a:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    172e:	00003997          	auipc	s3,0x3
    1732:	7ea98993          	addi	s3,s3,2026 # 4f18 <malloc+0x6ae>
    argv[0] = (char*)0xffffffff;
    1736:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    173a:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    173e:	fc040593          	addi	a1,s0,-64
    1742:	854e                	mv	a0,s3
    1744:	00003097          	auipc	ra,0x3
    1748:	d18080e7          	jalr	-744(ra) # 445c <exec>
  for(int i = 0; i < 50000; i++){
    174c:	34fd                	addiw	s1,s1,-1
    174e:	f4e5                	bnez	s1,1736 <badarg+0x22>
  }
  
  exit(0);
    1750:	4501                	li	a0,0
    1752:	00003097          	auipc	ra,0x3
    1756:	cd2080e7          	jalr	-814(ra) # 4424 <exit>

000000000000175a <pipe1>:
{
    175a:	711d                	addi	sp,sp,-96
    175c:	ec86                	sd	ra,88(sp)
    175e:	e8a2                	sd	s0,80(sp)
    1760:	e4a6                	sd	s1,72(sp)
    1762:	e0ca                	sd	s2,64(sp)
    1764:	fc4e                	sd	s3,56(sp)
    1766:	f852                	sd	s4,48(sp)
    1768:	f456                	sd	s5,40(sp)
    176a:	f05a                	sd	s6,32(sp)
    176c:	ec5e                	sd	s7,24(sp)
    176e:	1080                	addi	s0,sp,96
    1770:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1772:	fa840513          	addi	a0,s0,-88
    1776:	00003097          	auipc	ra,0x3
    177a:	cbe080e7          	jalr	-834(ra) # 4434 <pipe>
    177e:	ed25                	bnez	a0,17f6 <pipe1+0x9c>
    1780:	84aa                	mv	s1,a0
  pid = fork();
    1782:	00003097          	auipc	ra,0x3
    1786:	c9a080e7          	jalr	-870(ra) # 441c <fork>
    178a:	8a2a                	mv	s4,a0
  if(pid == 0){
    178c:	c159                	beqz	a0,1812 <pipe1+0xb8>
  } else if(pid > 0){
    178e:	16a05e63          	blez	a0,190a <pipe1+0x1b0>
    close(fds[1]);
    1792:	fac42503          	lw	a0,-84(s0)
    1796:	00003097          	auipc	ra,0x3
    179a:	cb6080e7          	jalr	-842(ra) # 444c <close>
    total = 0;
    179e:	8a26                	mv	s4,s1
    cc = 1;
    17a0:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    17a2:	00008a97          	auipc	s5,0x8
    17a6:	a96a8a93          	addi	s5,s5,-1386 # 9238 <buf>
      if(cc > sizeof(buf))
    17aa:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    17ac:	864e                	mv	a2,s3
    17ae:	85d6                	mv	a1,s5
    17b0:	fa842503          	lw	a0,-88(s0)
    17b4:	00003097          	auipc	ra,0x3
    17b8:	c88080e7          	jalr	-888(ra) # 443c <read>
    17bc:	10a05263          	blez	a0,18c0 <pipe1+0x166>
      for(i = 0; i < n; i++){
    17c0:	00008717          	auipc	a4,0x8
    17c4:	a7870713          	addi	a4,a4,-1416 # 9238 <buf>
    17c8:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17cc:	00074683          	lbu	a3,0(a4)
    17d0:	0ff4f793          	andi	a5,s1,255
    17d4:	2485                	addiw	s1,s1,1
    17d6:	0cf69163          	bne	a3,a5,1898 <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17da:	0705                	addi	a4,a4,1
    17dc:	fec498e3          	bne	s1,a2,17cc <pipe1+0x72>
      total += n;
    17e0:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17e4:	0019979b          	slliw	a5,s3,0x1
    17e8:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17ec:	013b7363          	bgeu	s6,s3,17f2 <pipe1+0x98>
        cc = sizeof(buf);
    17f0:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17f2:	84b2                	mv	s1,a2
    17f4:	bf65                	j	17ac <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17f6:	85ca                	mv	a1,s2
    17f8:	00004517          	auipc	a0,0x4
    17fc:	ea050513          	addi	a0,a0,-352 # 5698 <malloc+0xe2e>
    1800:	00003097          	auipc	ra,0x3
    1804:	fac080e7          	jalr	-84(ra) # 47ac <printf>
    exit(1);
    1808:	4505                	li	a0,1
    180a:	00003097          	auipc	ra,0x3
    180e:	c1a080e7          	jalr	-998(ra) # 4424 <exit>
    close(fds[0]);
    1812:	fa842503          	lw	a0,-88(s0)
    1816:	00003097          	auipc	ra,0x3
    181a:	c36080e7          	jalr	-970(ra) # 444c <close>
    for(n = 0; n < N; n++){
    181e:	00008b17          	auipc	s6,0x8
    1822:	a1ab0b13          	addi	s6,s6,-1510 # 9238 <buf>
    1826:	416004bb          	negw	s1,s6
    182a:	0ff4f493          	andi	s1,s1,255
    182e:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1832:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1834:	6a85                	lui	s5,0x1
    1836:	42da8a93          	addi	s5,s5,1069 # 142d <unlinkread+0x1b1>
{
    183a:	87da                	mv	a5,s6
        buf[i] = seq++;
    183c:	0097873b          	addw	a4,a5,s1
    1840:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1844:	0785                	addi	a5,a5,1
    1846:	fef99be3          	bne	s3,a5,183c <pipe1+0xe2>
        buf[i] = seq++;
    184a:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    184e:	40900613          	li	a2,1033
    1852:	85de                	mv	a1,s7
    1854:	fac42503          	lw	a0,-84(s0)
    1858:	00003097          	auipc	ra,0x3
    185c:	bec080e7          	jalr	-1044(ra) # 4444 <write>
    1860:	40900793          	li	a5,1033
    1864:	00f51c63          	bne	a0,a5,187c <pipe1+0x122>
    for(n = 0; n < N; n++){
    1868:	24a5                	addiw	s1,s1,9
    186a:	0ff4f493          	andi	s1,s1,255
    186e:	fd5a16e3          	bne	s4,s5,183a <pipe1+0xe0>
    exit(0);
    1872:	4501                	li	a0,0
    1874:	00003097          	auipc	ra,0x3
    1878:	bb0080e7          	jalr	-1104(ra) # 4424 <exit>
        printf("%s: pipe1 oops 1\n", s);
    187c:	85ca                	mv	a1,s2
    187e:	00004517          	auipc	a0,0x4
    1882:	e3250513          	addi	a0,a0,-462 # 56b0 <malloc+0xe46>
    1886:	00003097          	auipc	ra,0x3
    188a:	f26080e7          	jalr	-218(ra) # 47ac <printf>
        exit(1);
    188e:	4505                	li	a0,1
    1890:	00003097          	auipc	ra,0x3
    1894:	b94080e7          	jalr	-1132(ra) # 4424 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1898:	85ca                	mv	a1,s2
    189a:	00004517          	auipc	a0,0x4
    189e:	e2e50513          	addi	a0,a0,-466 # 56c8 <malloc+0xe5e>
    18a2:	00003097          	auipc	ra,0x3
    18a6:	f0a080e7          	jalr	-246(ra) # 47ac <printf>
}
    18aa:	60e6                	ld	ra,88(sp)
    18ac:	6446                	ld	s0,80(sp)
    18ae:	64a6                	ld	s1,72(sp)
    18b0:	6906                	ld	s2,64(sp)
    18b2:	79e2                	ld	s3,56(sp)
    18b4:	7a42                	ld	s4,48(sp)
    18b6:	7aa2                	ld	s5,40(sp)
    18b8:	7b02                	ld	s6,32(sp)
    18ba:	6be2                	ld	s7,24(sp)
    18bc:	6125                	addi	sp,sp,96
    18be:	8082                	ret
    if(total != N * SZ){
    18c0:	6785                	lui	a5,0x1
    18c2:	42d78793          	addi	a5,a5,1069 # 142d <unlinkread+0x1b1>
    18c6:	02fa0063          	beq	s4,a5,18e6 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18ca:	85d2                	mv	a1,s4
    18cc:	00004517          	auipc	a0,0x4
    18d0:	e1450513          	addi	a0,a0,-492 # 56e0 <malloc+0xe76>
    18d4:	00003097          	auipc	ra,0x3
    18d8:	ed8080e7          	jalr	-296(ra) # 47ac <printf>
      exit(1);
    18dc:	4505                	li	a0,1
    18de:	00003097          	auipc	ra,0x3
    18e2:	b46080e7          	jalr	-1210(ra) # 4424 <exit>
    close(fds[0]);
    18e6:	fa842503          	lw	a0,-88(s0)
    18ea:	00003097          	auipc	ra,0x3
    18ee:	b62080e7          	jalr	-1182(ra) # 444c <close>
    wait(&xstatus);
    18f2:	fa440513          	addi	a0,s0,-92
    18f6:	00003097          	auipc	ra,0x3
    18fa:	b36080e7          	jalr	-1226(ra) # 442c <wait>
    exit(xstatus);
    18fe:	fa442503          	lw	a0,-92(s0)
    1902:	00003097          	auipc	ra,0x3
    1906:	b22080e7          	jalr	-1246(ra) # 4424 <exit>
    printf("%s: fork() failed\n", s);
    190a:	85ca                	mv	a1,s2
    190c:	00004517          	auipc	a0,0x4
    1910:	df450513          	addi	a0,a0,-524 # 5700 <malloc+0xe96>
    1914:	00003097          	auipc	ra,0x3
    1918:	e98080e7          	jalr	-360(ra) # 47ac <printf>
    exit(1);
    191c:	4505                	li	a0,1
    191e:	00003097          	auipc	ra,0x3
    1922:	b06080e7          	jalr	-1274(ra) # 4424 <exit>

0000000000001926 <pgbug>:
{
    1926:	7179                	addi	sp,sp,-48
    1928:	f406                	sd	ra,40(sp)
    192a:	f022                	sd	s0,32(sp)
    192c:	ec26                	sd	s1,24(sp)
    192e:	1800                	addi	s0,sp,48
  argv[0] = 0;
    1930:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1934:	00005497          	auipc	s1,0x5
    1938:	0d44b483          	ld	s1,212(s1) # 6a08 <__SDATA_BEGIN__>
    193c:	fd840593          	addi	a1,s0,-40
    1940:	8526                	mv	a0,s1
    1942:	00003097          	auipc	ra,0x3
    1946:	b1a080e7          	jalr	-1254(ra) # 445c <exec>
  pipe((int*)0xeaeb0b5b00002f5e);
    194a:	8526                	mv	a0,s1
    194c:	00003097          	auipc	ra,0x3
    1950:	ae8080e7          	jalr	-1304(ra) # 4434 <pipe>
  exit(0);
    1954:	4501                	li	a0,0
    1956:	00003097          	auipc	ra,0x3
    195a:	ace080e7          	jalr	-1330(ra) # 4424 <exit>

000000000000195e <preempt>:
{
    195e:	7139                	addi	sp,sp,-64
    1960:	fc06                	sd	ra,56(sp)
    1962:	f822                	sd	s0,48(sp)
    1964:	f426                	sd	s1,40(sp)
    1966:	f04a                	sd	s2,32(sp)
    1968:	ec4e                	sd	s3,24(sp)
    196a:	e852                	sd	s4,16(sp)
    196c:	0080                	addi	s0,sp,64
    196e:	892a                	mv	s2,a0
  pid1 = fork();
    1970:	00003097          	auipc	ra,0x3
    1974:	aac080e7          	jalr	-1364(ra) # 441c <fork>
  if(pid1 < 0) {
    1978:	00054563          	bltz	a0,1982 <preempt+0x24>
    197c:	84aa                	mv	s1,a0
  if(pid1 == 0)
    197e:	ed19                	bnez	a0,199c <preempt+0x3e>
    for(;;)
    1980:	a001                	j	1980 <preempt+0x22>
    printf("%s: fork failed");
    1982:	00003517          	auipc	a0,0x3
    1986:	44e50513          	addi	a0,a0,1102 # 4dd0 <malloc+0x566>
    198a:	00003097          	auipc	ra,0x3
    198e:	e22080e7          	jalr	-478(ra) # 47ac <printf>
    exit(1);
    1992:	4505                	li	a0,1
    1994:	00003097          	auipc	ra,0x3
    1998:	a90080e7          	jalr	-1392(ra) # 4424 <exit>
  pid2 = fork();
    199c:	00003097          	auipc	ra,0x3
    19a0:	a80080e7          	jalr	-1408(ra) # 441c <fork>
    19a4:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    19a6:	00054463          	bltz	a0,19ae <preempt+0x50>
  if(pid2 == 0)
    19aa:	e105                	bnez	a0,19ca <preempt+0x6c>
    for(;;)
    19ac:	a001                	j	19ac <preempt+0x4e>
    printf("%s: fork failed\n", s);
    19ae:	85ca                	mv	a1,s2
    19b0:	00003517          	auipc	a0,0x3
    19b4:	3b850513          	addi	a0,a0,952 # 4d68 <malloc+0x4fe>
    19b8:	00003097          	auipc	ra,0x3
    19bc:	df4080e7          	jalr	-524(ra) # 47ac <printf>
    exit(1);
    19c0:	4505                	li	a0,1
    19c2:	00003097          	auipc	ra,0x3
    19c6:	a62080e7          	jalr	-1438(ra) # 4424 <exit>
  pipe(pfds);
    19ca:	fc840513          	addi	a0,s0,-56
    19ce:	00003097          	auipc	ra,0x3
    19d2:	a66080e7          	jalr	-1434(ra) # 4434 <pipe>
  pid3 = fork();
    19d6:	00003097          	auipc	ra,0x3
    19da:	a46080e7          	jalr	-1466(ra) # 441c <fork>
    19de:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    19e0:	02054e63          	bltz	a0,1a1c <preempt+0xbe>
  if(pid3 == 0){
    19e4:	e13d                	bnez	a0,1a4a <preempt+0xec>
    close(pfds[0]);
    19e6:	fc842503          	lw	a0,-56(s0)
    19ea:	00003097          	auipc	ra,0x3
    19ee:	a62080e7          	jalr	-1438(ra) # 444c <close>
    if(write(pfds[1], "x", 1) != 1)
    19f2:	4605                	li	a2,1
    19f4:	00004597          	auipc	a1,0x4
    19f8:	d2458593          	addi	a1,a1,-732 # 5718 <malloc+0xeae>
    19fc:	fcc42503          	lw	a0,-52(s0)
    1a00:	00003097          	auipc	ra,0x3
    1a04:	a44080e7          	jalr	-1468(ra) # 4444 <write>
    1a08:	4785                	li	a5,1
    1a0a:	02f51763          	bne	a0,a5,1a38 <preempt+0xda>
    close(pfds[1]);
    1a0e:	fcc42503          	lw	a0,-52(s0)
    1a12:	00003097          	auipc	ra,0x3
    1a16:	a3a080e7          	jalr	-1478(ra) # 444c <close>
    for(;;)
    1a1a:	a001                	j	1a1a <preempt+0xbc>
     printf("%s: fork failed\n", s);
    1a1c:	85ca                	mv	a1,s2
    1a1e:	00003517          	auipc	a0,0x3
    1a22:	34a50513          	addi	a0,a0,842 # 4d68 <malloc+0x4fe>
    1a26:	00003097          	auipc	ra,0x3
    1a2a:	d86080e7          	jalr	-634(ra) # 47ac <printf>
     exit(1);
    1a2e:	4505                	li	a0,1
    1a30:	00003097          	auipc	ra,0x3
    1a34:	9f4080e7          	jalr	-1548(ra) # 4424 <exit>
      printf("%s: preempt write error");
    1a38:	00004517          	auipc	a0,0x4
    1a3c:	ce850513          	addi	a0,a0,-792 # 5720 <malloc+0xeb6>
    1a40:	00003097          	auipc	ra,0x3
    1a44:	d6c080e7          	jalr	-660(ra) # 47ac <printf>
    1a48:	b7d9                	j	1a0e <preempt+0xb0>
  close(pfds[1]);
    1a4a:	fcc42503          	lw	a0,-52(s0)
    1a4e:	00003097          	auipc	ra,0x3
    1a52:	9fe080e7          	jalr	-1538(ra) # 444c <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    1a56:	660d                	lui	a2,0x3
    1a58:	00007597          	auipc	a1,0x7
    1a5c:	7e058593          	addi	a1,a1,2016 # 9238 <buf>
    1a60:	fc842503          	lw	a0,-56(s0)
    1a64:	00003097          	auipc	ra,0x3
    1a68:	9d8080e7          	jalr	-1576(ra) # 443c <read>
    1a6c:	4785                	li	a5,1
    1a6e:	02f50263          	beq	a0,a5,1a92 <preempt+0x134>
    printf("%s: preempt read error");
    1a72:	00004517          	auipc	a0,0x4
    1a76:	cc650513          	addi	a0,a0,-826 # 5738 <malloc+0xece>
    1a7a:	00003097          	auipc	ra,0x3
    1a7e:	d32080e7          	jalr	-718(ra) # 47ac <printf>
}
    1a82:	70e2                	ld	ra,56(sp)
    1a84:	7442                	ld	s0,48(sp)
    1a86:	74a2                	ld	s1,40(sp)
    1a88:	7902                	ld	s2,32(sp)
    1a8a:	69e2                	ld	s3,24(sp)
    1a8c:	6a42                	ld	s4,16(sp)
    1a8e:	6121                	addi	sp,sp,64
    1a90:	8082                	ret
  close(pfds[0]);
    1a92:	fc842503          	lw	a0,-56(s0)
    1a96:	00003097          	auipc	ra,0x3
    1a9a:	9b6080e7          	jalr	-1610(ra) # 444c <close>
  printf("kill... ");
    1a9e:	00004517          	auipc	a0,0x4
    1aa2:	cb250513          	addi	a0,a0,-846 # 5750 <malloc+0xee6>
    1aa6:	00003097          	auipc	ra,0x3
    1aaa:	d06080e7          	jalr	-762(ra) # 47ac <printf>
  kill(pid1);
    1aae:	8526                	mv	a0,s1
    1ab0:	00003097          	auipc	ra,0x3
    1ab4:	9a4080e7          	jalr	-1628(ra) # 4454 <kill>
  kill(pid2);
    1ab8:	854e                	mv	a0,s3
    1aba:	00003097          	auipc	ra,0x3
    1abe:	99a080e7          	jalr	-1638(ra) # 4454 <kill>
  kill(pid3);
    1ac2:	8552                	mv	a0,s4
    1ac4:	00003097          	auipc	ra,0x3
    1ac8:	990080e7          	jalr	-1648(ra) # 4454 <kill>
  printf("wait... ");
    1acc:	00004517          	auipc	a0,0x4
    1ad0:	c9450513          	addi	a0,a0,-876 # 5760 <malloc+0xef6>
    1ad4:	00003097          	auipc	ra,0x3
    1ad8:	cd8080e7          	jalr	-808(ra) # 47ac <printf>
  wait(0);
    1adc:	4501                	li	a0,0
    1ade:	00003097          	auipc	ra,0x3
    1ae2:	94e080e7          	jalr	-1714(ra) # 442c <wait>
  wait(0);
    1ae6:	4501                	li	a0,0
    1ae8:	00003097          	auipc	ra,0x3
    1aec:	944080e7          	jalr	-1724(ra) # 442c <wait>
  wait(0);
    1af0:	4501                	li	a0,0
    1af2:	00003097          	auipc	ra,0x3
    1af6:	93a080e7          	jalr	-1734(ra) # 442c <wait>
    1afa:	b761                	j	1a82 <preempt+0x124>

0000000000001afc <reparent>:
{
    1afc:	7179                	addi	sp,sp,-48
    1afe:	f406                	sd	ra,40(sp)
    1b00:	f022                	sd	s0,32(sp)
    1b02:	ec26                	sd	s1,24(sp)
    1b04:	e84a                	sd	s2,16(sp)
    1b06:	e44e                	sd	s3,8(sp)
    1b08:	e052                	sd	s4,0(sp)
    1b0a:	1800                	addi	s0,sp,48
    1b0c:	89aa                	mv	s3,a0
  int master_pid = getpid();
    1b0e:	00003097          	auipc	ra,0x3
    1b12:	996080e7          	jalr	-1642(ra) # 44a4 <getpid>
    1b16:	8a2a                	mv	s4,a0
    1b18:	0c800913          	li	s2,200
    int pid = fork();
    1b1c:	00003097          	auipc	ra,0x3
    1b20:	900080e7          	jalr	-1792(ra) # 441c <fork>
    1b24:	84aa                	mv	s1,a0
    if(pid < 0){
    1b26:	02054263          	bltz	a0,1b4a <reparent+0x4e>
    if(pid){
    1b2a:	cd21                	beqz	a0,1b82 <reparent+0x86>
      if(wait(0) != pid){
    1b2c:	4501                	li	a0,0
    1b2e:	00003097          	auipc	ra,0x3
    1b32:	8fe080e7          	jalr	-1794(ra) # 442c <wait>
    1b36:	02951863          	bne	a0,s1,1b66 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    1b3a:	397d                	addiw	s2,s2,-1
    1b3c:	fe0910e3          	bnez	s2,1b1c <reparent+0x20>
  exit(0);
    1b40:	4501                	li	a0,0
    1b42:	00003097          	auipc	ra,0x3
    1b46:	8e2080e7          	jalr	-1822(ra) # 4424 <exit>
      printf("%s: fork failed\n", s);
    1b4a:	85ce                	mv	a1,s3
    1b4c:	00003517          	auipc	a0,0x3
    1b50:	21c50513          	addi	a0,a0,540 # 4d68 <malloc+0x4fe>
    1b54:	00003097          	auipc	ra,0x3
    1b58:	c58080e7          	jalr	-936(ra) # 47ac <printf>
      exit(1);
    1b5c:	4505                	li	a0,1
    1b5e:	00003097          	auipc	ra,0x3
    1b62:	8c6080e7          	jalr	-1850(ra) # 4424 <exit>
        printf("%s: wait wrong pid\n", s);
    1b66:	85ce                	mv	a1,s3
    1b68:	00003517          	auipc	a0,0x3
    1b6c:	23050513          	addi	a0,a0,560 # 4d98 <malloc+0x52e>
    1b70:	00003097          	auipc	ra,0x3
    1b74:	c3c080e7          	jalr	-964(ra) # 47ac <printf>
        exit(1);
    1b78:	4505                	li	a0,1
    1b7a:	00003097          	auipc	ra,0x3
    1b7e:	8aa080e7          	jalr	-1878(ra) # 4424 <exit>
      int pid2 = fork();
    1b82:	00003097          	auipc	ra,0x3
    1b86:	89a080e7          	jalr	-1894(ra) # 441c <fork>
      if(pid2 < 0){
    1b8a:	00054763          	bltz	a0,1b98 <reparent+0x9c>
      exit(0);
    1b8e:	4501                	li	a0,0
    1b90:	00003097          	auipc	ra,0x3
    1b94:	894080e7          	jalr	-1900(ra) # 4424 <exit>
        kill(master_pid);
    1b98:	8552                	mv	a0,s4
    1b9a:	00003097          	auipc	ra,0x3
    1b9e:	8ba080e7          	jalr	-1862(ra) # 4454 <kill>
        exit(1);
    1ba2:	4505                	li	a0,1
    1ba4:	00003097          	auipc	ra,0x3
    1ba8:	880080e7          	jalr	-1920(ra) # 4424 <exit>

0000000000001bac <mem>:
{
    1bac:	7139                	addi	sp,sp,-64
    1bae:	fc06                	sd	ra,56(sp)
    1bb0:	f822                	sd	s0,48(sp)
    1bb2:	f426                	sd	s1,40(sp)
    1bb4:	f04a                	sd	s2,32(sp)
    1bb6:	ec4e                	sd	s3,24(sp)
    1bb8:	0080                	addi	s0,sp,64
    1bba:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    1bbc:	00003097          	auipc	ra,0x3
    1bc0:	860080e7          	jalr	-1952(ra) # 441c <fork>
    m1 = 0;
    1bc4:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    1bc6:	6909                	lui	s2,0x2
    1bc8:	71190913          	addi	s2,s2,1809 # 2711 <concreate+0x2ab>
  if((pid = fork()) == 0){
    1bcc:	cd19                	beqz	a0,1bea <mem+0x3e>
    wait(&xstatus);
    1bce:	fcc40513          	addi	a0,s0,-52
    1bd2:	00003097          	auipc	ra,0x3
    1bd6:	85a080e7          	jalr	-1958(ra) # 442c <wait>
    exit(xstatus);
    1bda:	fcc42503          	lw	a0,-52(s0)
    1bde:	00003097          	auipc	ra,0x3
    1be2:	846080e7          	jalr	-1978(ra) # 4424 <exit>
      *(char**)m2 = m1;
    1be6:	e104                	sd	s1,0(a0)
      m1 = m2;
    1be8:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    1bea:	854a                	mv	a0,s2
    1bec:	00003097          	auipc	ra,0x3
    1bf0:	c7e080e7          	jalr	-898(ra) # 486a <malloc>
    1bf4:	f96d                	bnez	a0,1be6 <mem+0x3a>
    while(m1){
    1bf6:	c881                	beqz	s1,1c06 <mem+0x5a>
      m2 = *(char**)m1;
    1bf8:	8526                	mv	a0,s1
    1bfa:	6084                	ld	s1,0(s1)
      free(m1);
    1bfc:	00003097          	auipc	ra,0x3
    1c00:	be6080e7          	jalr	-1050(ra) # 47e2 <free>
    while(m1){
    1c04:	f8f5                	bnez	s1,1bf8 <mem+0x4c>
    m1 = malloc(1024*20);
    1c06:	6515                	lui	a0,0x5
    1c08:	00003097          	auipc	ra,0x3
    1c0c:	c62080e7          	jalr	-926(ra) # 486a <malloc>
    if(m1 == 0){
    1c10:	c911                	beqz	a0,1c24 <mem+0x78>
    free(m1);
    1c12:	00003097          	auipc	ra,0x3
    1c16:	bd0080e7          	jalr	-1072(ra) # 47e2 <free>
    exit(0);
    1c1a:	4501                	li	a0,0
    1c1c:	00003097          	auipc	ra,0x3
    1c20:	808080e7          	jalr	-2040(ra) # 4424 <exit>
      printf("couldn't allocate mem?!!\n", s);
    1c24:	85ce                	mv	a1,s3
    1c26:	00004517          	auipc	a0,0x4
    1c2a:	b4a50513          	addi	a0,a0,-1206 # 5770 <malloc+0xf06>
    1c2e:	00003097          	auipc	ra,0x3
    1c32:	b7e080e7          	jalr	-1154(ra) # 47ac <printf>
      exit(1);
    1c36:	4505                	li	a0,1
    1c38:	00002097          	auipc	ra,0x2
    1c3c:	7ec080e7          	jalr	2028(ra) # 4424 <exit>

0000000000001c40 <sharedfd>:
{
    1c40:	7159                	addi	sp,sp,-112
    1c42:	f486                	sd	ra,104(sp)
    1c44:	f0a2                	sd	s0,96(sp)
    1c46:	eca6                	sd	s1,88(sp)
    1c48:	e8ca                	sd	s2,80(sp)
    1c4a:	e4ce                	sd	s3,72(sp)
    1c4c:	e0d2                	sd	s4,64(sp)
    1c4e:	fc56                	sd	s5,56(sp)
    1c50:	f85a                	sd	s6,48(sp)
    1c52:	f45e                	sd	s7,40(sp)
    1c54:	1880                	addi	s0,sp,112
    1c56:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    1c58:	00003517          	auipc	a0,0x3
    1c5c:	e0050513          	addi	a0,a0,-512 # 4a58 <malloc+0x1ee>
    1c60:	00003097          	auipc	ra,0x3
    1c64:	814080e7          	jalr	-2028(ra) # 4474 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    1c68:	20200593          	li	a1,514
    1c6c:	00003517          	auipc	a0,0x3
    1c70:	dec50513          	addi	a0,a0,-532 # 4a58 <malloc+0x1ee>
    1c74:	00002097          	auipc	ra,0x2
    1c78:	7f0080e7          	jalr	2032(ra) # 4464 <open>
  if(fd < 0){
    1c7c:	04054a63          	bltz	a0,1cd0 <sharedfd+0x90>
    1c80:	892a                	mv	s2,a0
  pid = fork();
    1c82:	00002097          	auipc	ra,0x2
    1c86:	79a080e7          	jalr	1946(ra) # 441c <fork>
    1c8a:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    1c8c:	06300593          	li	a1,99
    1c90:	c119                	beqz	a0,1c96 <sharedfd+0x56>
    1c92:	07000593          	li	a1,112
    1c96:	4629                	li	a2,10
    1c98:	fa040513          	addi	a0,s0,-96
    1c9c:	00002097          	auipc	ra,0x2
    1ca0:	58c080e7          	jalr	1420(ra) # 4228 <memset>
    1ca4:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    1ca8:	4629                	li	a2,10
    1caa:	fa040593          	addi	a1,s0,-96
    1cae:	854a                	mv	a0,s2
    1cb0:	00002097          	auipc	ra,0x2
    1cb4:	794080e7          	jalr	1940(ra) # 4444 <write>
    1cb8:	47a9                	li	a5,10
    1cba:	02f51963          	bne	a0,a5,1cec <sharedfd+0xac>
  for(i = 0; i < N; i++){
    1cbe:	34fd                	addiw	s1,s1,-1
    1cc0:	f4e5                	bnez	s1,1ca8 <sharedfd+0x68>
  if(pid == 0) {
    1cc2:	04099363          	bnez	s3,1d08 <sharedfd+0xc8>
    exit(0);
    1cc6:	4501                	li	a0,0
    1cc8:	00002097          	auipc	ra,0x2
    1ccc:	75c080e7          	jalr	1884(ra) # 4424 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    1cd0:	85d2                	mv	a1,s4
    1cd2:	00004517          	auipc	a0,0x4
    1cd6:	abe50513          	addi	a0,a0,-1346 # 5790 <malloc+0xf26>
    1cda:	00003097          	auipc	ra,0x3
    1cde:	ad2080e7          	jalr	-1326(ra) # 47ac <printf>
    exit(1);
    1ce2:	4505                	li	a0,1
    1ce4:	00002097          	auipc	ra,0x2
    1ce8:	740080e7          	jalr	1856(ra) # 4424 <exit>
      printf("%s: write sharedfd failed\n", s);
    1cec:	85d2                	mv	a1,s4
    1cee:	00004517          	auipc	a0,0x4
    1cf2:	aca50513          	addi	a0,a0,-1334 # 57b8 <malloc+0xf4e>
    1cf6:	00003097          	auipc	ra,0x3
    1cfa:	ab6080e7          	jalr	-1354(ra) # 47ac <printf>
      exit(1);
    1cfe:	4505                	li	a0,1
    1d00:	00002097          	auipc	ra,0x2
    1d04:	724080e7          	jalr	1828(ra) # 4424 <exit>
    wait(&xstatus);
    1d08:	f9c40513          	addi	a0,s0,-100
    1d0c:	00002097          	auipc	ra,0x2
    1d10:	720080e7          	jalr	1824(ra) # 442c <wait>
    if(xstatus != 0)
    1d14:	f9c42983          	lw	s3,-100(s0)
    1d18:	00098763          	beqz	s3,1d26 <sharedfd+0xe6>
      exit(xstatus);
    1d1c:	854e                	mv	a0,s3
    1d1e:	00002097          	auipc	ra,0x2
    1d22:	706080e7          	jalr	1798(ra) # 4424 <exit>
  close(fd);
    1d26:	854a                	mv	a0,s2
    1d28:	00002097          	auipc	ra,0x2
    1d2c:	724080e7          	jalr	1828(ra) # 444c <close>
  fd = open("sharedfd", 0);
    1d30:	4581                	li	a1,0
    1d32:	00003517          	auipc	a0,0x3
    1d36:	d2650513          	addi	a0,a0,-730 # 4a58 <malloc+0x1ee>
    1d3a:	00002097          	auipc	ra,0x2
    1d3e:	72a080e7          	jalr	1834(ra) # 4464 <open>
    1d42:	8baa                	mv	s7,a0
  nc = np = 0;
    1d44:	8ace                	mv	s5,s3
  if(fd < 0){
    1d46:	02054563          	bltz	a0,1d70 <sharedfd+0x130>
    1d4a:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    1d4e:	06300493          	li	s1,99
      if(buf[i] == 'p')
    1d52:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    1d56:	4629                	li	a2,10
    1d58:	fa040593          	addi	a1,s0,-96
    1d5c:	855e                	mv	a0,s7
    1d5e:	00002097          	auipc	ra,0x2
    1d62:	6de080e7          	jalr	1758(ra) # 443c <read>
    1d66:	02a05f63          	blez	a0,1da4 <sharedfd+0x164>
    1d6a:	fa040793          	addi	a5,s0,-96
    1d6e:	a01d                	j	1d94 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    1d70:	85d2                	mv	a1,s4
    1d72:	00004517          	auipc	a0,0x4
    1d76:	a6650513          	addi	a0,a0,-1434 # 57d8 <malloc+0xf6e>
    1d7a:	00003097          	auipc	ra,0x3
    1d7e:	a32080e7          	jalr	-1486(ra) # 47ac <printf>
    exit(1);
    1d82:	4505                	li	a0,1
    1d84:	00002097          	auipc	ra,0x2
    1d88:	6a0080e7          	jalr	1696(ra) # 4424 <exit>
        nc++;
    1d8c:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    1d8e:	0785                	addi	a5,a5,1
    1d90:	fd2783e3          	beq	a5,s2,1d56 <sharedfd+0x116>
      if(buf[i] == 'c')
    1d94:	0007c703          	lbu	a4,0(a5)
    1d98:	fe970ae3          	beq	a4,s1,1d8c <sharedfd+0x14c>
      if(buf[i] == 'p')
    1d9c:	ff6719e3          	bne	a4,s6,1d8e <sharedfd+0x14e>
        np++;
    1da0:	2a85                	addiw	s5,s5,1
    1da2:	b7f5                	j	1d8e <sharedfd+0x14e>
  close(fd);
    1da4:	855e                	mv	a0,s7
    1da6:	00002097          	auipc	ra,0x2
    1daa:	6a6080e7          	jalr	1702(ra) # 444c <close>
  unlink("sharedfd");
    1dae:	00003517          	auipc	a0,0x3
    1db2:	caa50513          	addi	a0,a0,-854 # 4a58 <malloc+0x1ee>
    1db6:	00002097          	auipc	ra,0x2
    1dba:	6be080e7          	jalr	1726(ra) # 4474 <unlink>
  if(nc == N*SZ && np == N*SZ){
    1dbe:	6789                	lui	a5,0x2
    1dc0:	71078793          	addi	a5,a5,1808 # 2710 <concreate+0x2aa>
    1dc4:	00f99763          	bne	s3,a5,1dd2 <sharedfd+0x192>
    1dc8:	6789                	lui	a5,0x2
    1dca:	71078793          	addi	a5,a5,1808 # 2710 <concreate+0x2aa>
    1dce:	02fa8063          	beq	s5,a5,1dee <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    1dd2:	85d2                	mv	a1,s4
    1dd4:	00004517          	auipc	a0,0x4
    1dd8:	a2c50513          	addi	a0,a0,-1492 # 5800 <malloc+0xf96>
    1ddc:	00003097          	auipc	ra,0x3
    1de0:	9d0080e7          	jalr	-1584(ra) # 47ac <printf>
    exit(1);
    1de4:	4505                	li	a0,1
    1de6:	00002097          	auipc	ra,0x2
    1dea:	63e080e7          	jalr	1598(ra) # 4424 <exit>
    exit(0);
    1dee:	4501                	li	a0,0
    1df0:	00002097          	auipc	ra,0x2
    1df4:	634080e7          	jalr	1588(ra) # 4424 <exit>

0000000000001df8 <fourfiles>:
{
    1df8:	7171                	addi	sp,sp,-176
    1dfa:	f506                	sd	ra,168(sp)
    1dfc:	f122                	sd	s0,160(sp)
    1dfe:	ed26                	sd	s1,152(sp)
    1e00:	e94a                	sd	s2,144(sp)
    1e02:	e54e                	sd	s3,136(sp)
    1e04:	e152                	sd	s4,128(sp)
    1e06:	fcd6                	sd	s5,120(sp)
    1e08:	f8da                	sd	s6,112(sp)
    1e0a:	f4de                	sd	s7,104(sp)
    1e0c:	f0e2                	sd	s8,96(sp)
    1e0e:	ece6                	sd	s9,88(sp)
    1e10:	e8ea                	sd	s10,80(sp)
    1e12:	e4ee                	sd	s11,72(sp)
    1e14:	1900                	addi	s0,sp,176
    1e16:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    1e1a:	00003797          	auipc	a5,0x3
    1e1e:	b3678793          	addi	a5,a5,-1226 # 4950 <malloc+0xe6>
    1e22:	f6f43823          	sd	a5,-144(s0)
    1e26:	00003797          	auipc	a5,0x3
    1e2a:	b3278793          	addi	a5,a5,-1230 # 4958 <malloc+0xee>
    1e2e:	f6f43c23          	sd	a5,-136(s0)
    1e32:	00003797          	auipc	a5,0x3
    1e36:	b2e78793          	addi	a5,a5,-1234 # 4960 <malloc+0xf6>
    1e3a:	f8f43023          	sd	a5,-128(s0)
    1e3e:	00003797          	auipc	a5,0x3
    1e42:	b2a78793          	addi	a5,a5,-1238 # 4968 <malloc+0xfe>
    1e46:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    1e4a:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    1e4e:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    1e50:	4481                	li	s1,0
    1e52:	4a11                	li	s4,4
    fname = names[pi];
    1e54:	00093983          	ld	s3,0(s2)
    unlink(fname);
    1e58:	854e                	mv	a0,s3
    1e5a:	00002097          	auipc	ra,0x2
    1e5e:	61a080e7          	jalr	1562(ra) # 4474 <unlink>
    pid = fork();
    1e62:	00002097          	auipc	ra,0x2
    1e66:	5ba080e7          	jalr	1466(ra) # 441c <fork>
    if(pid < 0){
    1e6a:	04054463          	bltz	a0,1eb2 <fourfiles+0xba>
    if(pid == 0){
    1e6e:	c12d                	beqz	a0,1ed0 <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    1e70:	2485                	addiw	s1,s1,1
    1e72:	0921                	addi	s2,s2,8
    1e74:	ff4490e3          	bne	s1,s4,1e54 <fourfiles+0x5c>
    1e78:	4491                	li	s1,4
    wait(&xstatus);
    1e7a:	f6c40513          	addi	a0,s0,-148
    1e7e:	00002097          	auipc	ra,0x2
    1e82:	5ae080e7          	jalr	1454(ra) # 442c <wait>
    if(xstatus != 0)
    1e86:	f6c42b03          	lw	s6,-148(s0)
    1e8a:	0c0b1e63          	bnez	s6,1f66 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    1e8e:	34fd                	addiw	s1,s1,-1
    1e90:	f4ed                	bnez	s1,1e7a <fourfiles+0x82>
    1e92:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    1e96:	00007a17          	auipc	s4,0x7
    1e9a:	3a2a0a13          	addi	s4,s4,930 # 9238 <buf>
    1e9e:	00007a97          	auipc	s5,0x7
    1ea2:	39ba8a93          	addi	s5,s5,923 # 9239 <buf+0x1>
    if(total != N*SZ){
    1ea6:	6d85                	lui	s11,0x1
    1ea8:	770d8d93          	addi	s11,s11,1904 # 1770 <pipe1+0x16>
  for(i = 0; i < NCHILD; i++){
    1eac:	03400d13          	li	s10,52
    1eb0:	aa1d                	j	1fe6 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    1eb2:	f5843583          	ld	a1,-168(s0)
    1eb6:	00003517          	auipc	a0,0x3
    1eba:	7b250513          	addi	a0,a0,1970 # 5668 <malloc+0xdfe>
    1ebe:	00003097          	auipc	ra,0x3
    1ec2:	8ee080e7          	jalr	-1810(ra) # 47ac <printf>
      exit(1);
    1ec6:	4505                	li	a0,1
    1ec8:	00002097          	auipc	ra,0x2
    1ecc:	55c080e7          	jalr	1372(ra) # 4424 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    1ed0:	20200593          	li	a1,514
    1ed4:	854e                	mv	a0,s3
    1ed6:	00002097          	auipc	ra,0x2
    1eda:	58e080e7          	jalr	1422(ra) # 4464 <open>
    1ede:	892a                	mv	s2,a0
      if(fd < 0){
    1ee0:	04054763          	bltz	a0,1f2e <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    1ee4:	1f400613          	li	a2,500
    1ee8:	0304859b          	addiw	a1,s1,48
    1eec:	00007517          	auipc	a0,0x7
    1ef0:	34c50513          	addi	a0,a0,844 # 9238 <buf>
    1ef4:	00002097          	auipc	ra,0x2
    1ef8:	334080e7          	jalr	820(ra) # 4228 <memset>
    1efc:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    1efe:	00007997          	auipc	s3,0x7
    1f02:	33a98993          	addi	s3,s3,826 # 9238 <buf>
    1f06:	1f400613          	li	a2,500
    1f0a:	85ce                	mv	a1,s3
    1f0c:	854a                	mv	a0,s2
    1f0e:	00002097          	auipc	ra,0x2
    1f12:	536080e7          	jalr	1334(ra) # 4444 <write>
    1f16:	85aa                	mv	a1,a0
    1f18:	1f400793          	li	a5,500
    1f1c:	02f51863          	bne	a0,a5,1f4c <fourfiles+0x154>
      for(i = 0; i < N; i++){
    1f20:	34fd                	addiw	s1,s1,-1
    1f22:	f0f5                	bnez	s1,1f06 <fourfiles+0x10e>
      exit(0);
    1f24:	4501                	li	a0,0
    1f26:	00002097          	auipc	ra,0x2
    1f2a:	4fe080e7          	jalr	1278(ra) # 4424 <exit>
        printf("create failed\n", s);
    1f2e:	f5843583          	ld	a1,-168(s0)
    1f32:	00004517          	auipc	a0,0x4
    1f36:	8e650513          	addi	a0,a0,-1818 # 5818 <malloc+0xfae>
    1f3a:	00003097          	auipc	ra,0x3
    1f3e:	872080e7          	jalr	-1934(ra) # 47ac <printf>
        exit(1);
    1f42:	4505                	li	a0,1
    1f44:	00002097          	auipc	ra,0x2
    1f48:	4e0080e7          	jalr	1248(ra) # 4424 <exit>
          printf("write failed %d\n", n);
    1f4c:	00004517          	auipc	a0,0x4
    1f50:	8dc50513          	addi	a0,a0,-1828 # 5828 <malloc+0xfbe>
    1f54:	00003097          	auipc	ra,0x3
    1f58:	858080e7          	jalr	-1960(ra) # 47ac <printf>
          exit(1);
    1f5c:	4505                	li	a0,1
    1f5e:	00002097          	auipc	ra,0x2
    1f62:	4c6080e7          	jalr	1222(ra) # 4424 <exit>
      exit(xstatus);
    1f66:	855a                	mv	a0,s6
    1f68:	00002097          	auipc	ra,0x2
    1f6c:	4bc080e7          	jalr	1212(ra) # 4424 <exit>
          printf("wrong char\n", s);
    1f70:	f5843583          	ld	a1,-168(s0)
    1f74:	00004517          	auipc	a0,0x4
    1f78:	8cc50513          	addi	a0,a0,-1844 # 5840 <malloc+0xfd6>
    1f7c:	00003097          	auipc	ra,0x3
    1f80:	830080e7          	jalr	-2000(ra) # 47ac <printf>
          exit(1);
    1f84:	4505                	li	a0,1
    1f86:	00002097          	auipc	ra,0x2
    1f8a:	49e080e7          	jalr	1182(ra) # 4424 <exit>
      total += n;
    1f8e:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    1f92:	660d                	lui	a2,0x3
    1f94:	85d2                	mv	a1,s4
    1f96:	854e                	mv	a0,s3
    1f98:	00002097          	auipc	ra,0x2
    1f9c:	4a4080e7          	jalr	1188(ra) # 443c <read>
    1fa0:	02a05363          	blez	a0,1fc6 <fourfiles+0x1ce>
    1fa4:	00007797          	auipc	a5,0x7
    1fa8:	29478793          	addi	a5,a5,660 # 9238 <buf>
    1fac:	fff5069b          	addiw	a3,a0,-1
    1fb0:	1682                	slli	a3,a3,0x20
    1fb2:	9281                	srli	a3,a3,0x20
    1fb4:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    1fb6:	0007c703          	lbu	a4,0(a5)
    1fba:	fa971be3          	bne	a4,s1,1f70 <fourfiles+0x178>
      for(j = 0; j < n; j++){
    1fbe:	0785                	addi	a5,a5,1
    1fc0:	fed79be3          	bne	a5,a3,1fb6 <fourfiles+0x1be>
    1fc4:	b7e9                	j	1f8e <fourfiles+0x196>
    close(fd);
    1fc6:	854e                	mv	a0,s3
    1fc8:	00002097          	auipc	ra,0x2
    1fcc:	484080e7          	jalr	1156(ra) # 444c <close>
    if(total != N*SZ){
    1fd0:	03b91863          	bne	s2,s11,2000 <fourfiles+0x208>
    unlink(fname);
    1fd4:	8566                	mv	a0,s9
    1fd6:	00002097          	auipc	ra,0x2
    1fda:	49e080e7          	jalr	1182(ra) # 4474 <unlink>
  for(i = 0; i < NCHILD; i++){
    1fde:	0c21                	addi	s8,s8,8
    1fe0:	2b85                	addiw	s7,s7,1
    1fe2:	03ab8d63          	beq	s7,s10,201c <fourfiles+0x224>
    fname = names[i];
    1fe6:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    1fea:	4581                	li	a1,0
    1fec:	8566                	mv	a0,s9
    1fee:	00002097          	auipc	ra,0x2
    1ff2:	476080e7          	jalr	1142(ra) # 4464 <open>
    1ff6:	89aa                	mv	s3,a0
    total = 0;
    1ff8:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    1ffa:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    1ffe:	bf51                	j	1f92 <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    2000:	85ca                	mv	a1,s2
    2002:	00004517          	auipc	a0,0x4
    2006:	84e50513          	addi	a0,a0,-1970 # 5850 <malloc+0xfe6>
    200a:	00002097          	auipc	ra,0x2
    200e:	7a2080e7          	jalr	1954(ra) # 47ac <printf>
      exit(1);
    2012:	4505                	li	a0,1
    2014:	00002097          	auipc	ra,0x2
    2018:	410080e7          	jalr	1040(ra) # 4424 <exit>
}
    201c:	70aa                	ld	ra,168(sp)
    201e:	740a                	ld	s0,160(sp)
    2020:	64ea                	ld	s1,152(sp)
    2022:	694a                	ld	s2,144(sp)
    2024:	69aa                	ld	s3,136(sp)
    2026:	6a0a                	ld	s4,128(sp)
    2028:	7ae6                	ld	s5,120(sp)
    202a:	7b46                	ld	s6,112(sp)
    202c:	7ba6                	ld	s7,104(sp)
    202e:	7c06                	ld	s8,96(sp)
    2030:	6ce6                	ld	s9,88(sp)
    2032:	6d46                	ld	s10,80(sp)
    2034:	6da6                	ld	s11,72(sp)
    2036:	614d                	addi	sp,sp,176
    2038:	8082                	ret

000000000000203a <bigfile>:
{
    203a:	7139                	addi	sp,sp,-64
    203c:	fc06                	sd	ra,56(sp)
    203e:	f822                	sd	s0,48(sp)
    2040:	f426                	sd	s1,40(sp)
    2042:	f04a                	sd	s2,32(sp)
    2044:	ec4e                	sd	s3,24(sp)
    2046:	e852                	sd	s4,16(sp)
    2048:	e456                	sd	s5,8(sp)
    204a:	0080                	addi	s0,sp,64
    204c:	8aaa                	mv	s5,a0
  unlink("bigfile.test");
    204e:	00004517          	auipc	a0,0x4
    2052:	81a50513          	addi	a0,a0,-2022 # 5868 <malloc+0xffe>
    2056:	00002097          	auipc	ra,0x2
    205a:	41e080e7          	jalr	1054(ra) # 4474 <unlink>
  fd = open("bigfile.test", O_CREATE | O_RDWR);
    205e:	20200593          	li	a1,514
    2062:	00004517          	auipc	a0,0x4
    2066:	80650513          	addi	a0,a0,-2042 # 5868 <malloc+0xffe>
    206a:	00002097          	auipc	ra,0x2
    206e:	3fa080e7          	jalr	1018(ra) # 4464 <open>
    2072:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    2074:	4481                	li	s1,0
    memset(buf, i, SZ);
    2076:	00007917          	auipc	s2,0x7
    207a:	1c290913          	addi	s2,s2,450 # 9238 <buf>
  for(i = 0; i < N; i++){
    207e:	4a51                	li	s4,20
  if(fd < 0){
    2080:	0a054063          	bltz	a0,2120 <bigfile+0xe6>
    memset(buf, i, SZ);
    2084:	25800613          	li	a2,600
    2088:	85a6                	mv	a1,s1
    208a:	854a                	mv	a0,s2
    208c:	00002097          	auipc	ra,0x2
    2090:	19c080e7          	jalr	412(ra) # 4228 <memset>
    if(write(fd, buf, SZ) != SZ){
    2094:	25800613          	li	a2,600
    2098:	85ca                	mv	a1,s2
    209a:	854e                	mv	a0,s3
    209c:	00002097          	auipc	ra,0x2
    20a0:	3a8080e7          	jalr	936(ra) # 4444 <write>
    20a4:	25800793          	li	a5,600
    20a8:	08f51a63          	bne	a0,a5,213c <bigfile+0x102>
  for(i = 0; i < N; i++){
    20ac:	2485                	addiw	s1,s1,1
    20ae:	fd449be3          	bne	s1,s4,2084 <bigfile+0x4a>
  close(fd);
    20b2:	854e                	mv	a0,s3
    20b4:	00002097          	auipc	ra,0x2
    20b8:	398080e7          	jalr	920(ra) # 444c <close>
  fd = open("bigfile.test", 0);
    20bc:	4581                	li	a1,0
    20be:	00003517          	auipc	a0,0x3
    20c2:	7aa50513          	addi	a0,a0,1962 # 5868 <malloc+0xffe>
    20c6:	00002097          	auipc	ra,0x2
    20ca:	39e080e7          	jalr	926(ra) # 4464 <open>
    20ce:	8a2a                	mv	s4,a0
  total = 0;
    20d0:	4981                	li	s3,0
  for(i = 0; ; i++){
    20d2:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    20d4:	00007917          	auipc	s2,0x7
    20d8:	16490913          	addi	s2,s2,356 # 9238 <buf>
  if(fd < 0){
    20dc:	06054e63          	bltz	a0,2158 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    20e0:	12c00613          	li	a2,300
    20e4:	85ca                	mv	a1,s2
    20e6:	8552                	mv	a0,s4
    20e8:	00002097          	auipc	ra,0x2
    20ec:	354080e7          	jalr	852(ra) # 443c <read>
    if(cc < 0){
    20f0:	08054263          	bltz	a0,2174 <bigfile+0x13a>
    if(cc == 0)
    20f4:	c971                	beqz	a0,21c8 <bigfile+0x18e>
    if(cc != SZ/2){
    20f6:	12c00793          	li	a5,300
    20fa:	08f51b63          	bne	a0,a5,2190 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    20fe:	01f4d79b          	srliw	a5,s1,0x1f
    2102:	9fa5                	addw	a5,a5,s1
    2104:	4017d79b          	sraiw	a5,a5,0x1
    2108:	00094703          	lbu	a4,0(s2)
    210c:	0af71063          	bne	a4,a5,21ac <bigfile+0x172>
    2110:	12b94703          	lbu	a4,299(s2)
    2114:	08f71c63          	bne	a4,a5,21ac <bigfile+0x172>
    total += cc;
    2118:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    211c:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    211e:	b7c9                	j	20e0 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    2120:	85d6                	mv	a1,s5
    2122:	00003517          	auipc	a0,0x3
    2126:	75650513          	addi	a0,a0,1878 # 5878 <malloc+0x100e>
    212a:	00002097          	auipc	ra,0x2
    212e:	682080e7          	jalr	1666(ra) # 47ac <printf>
    exit(1);
    2132:	4505                	li	a0,1
    2134:	00002097          	auipc	ra,0x2
    2138:	2f0080e7          	jalr	752(ra) # 4424 <exit>
      printf("%s: write bigfile failed\n", s);
    213c:	85d6                	mv	a1,s5
    213e:	00003517          	auipc	a0,0x3
    2142:	75a50513          	addi	a0,a0,1882 # 5898 <malloc+0x102e>
    2146:	00002097          	auipc	ra,0x2
    214a:	666080e7          	jalr	1638(ra) # 47ac <printf>
      exit(1);
    214e:	4505                	li	a0,1
    2150:	00002097          	auipc	ra,0x2
    2154:	2d4080e7          	jalr	724(ra) # 4424 <exit>
    printf("%s: cannot open bigfile\n", s);
    2158:	85d6                	mv	a1,s5
    215a:	00003517          	auipc	a0,0x3
    215e:	75e50513          	addi	a0,a0,1886 # 58b8 <malloc+0x104e>
    2162:	00002097          	auipc	ra,0x2
    2166:	64a080e7          	jalr	1610(ra) # 47ac <printf>
    exit(1);
    216a:	4505                	li	a0,1
    216c:	00002097          	auipc	ra,0x2
    2170:	2b8080e7          	jalr	696(ra) # 4424 <exit>
      printf("%s: read bigfile failed\n", s);
    2174:	85d6                	mv	a1,s5
    2176:	00003517          	auipc	a0,0x3
    217a:	76250513          	addi	a0,a0,1890 # 58d8 <malloc+0x106e>
    217e:	00002097          	auipc	ra,0x2
    2182:	62e080e7          	jalr	1582(ra) # 47ac <printf>
      exit(1);
    2186:	4505                	li	a0,1
    2188:	00002097          	auipc	ra,0x2
    218c:	29c080e7          	jalr	668(ra) # 4424 <exit>
      printf("%s: short read bigfile\n", s);
    2190:	85d6                	mv	a1,s5
    2192:	00003517          	auipc	a0,0x3
    2196:	76650513          	addi	a0,a0,1894 # 58f8 <malloc+0x108e>
    219a:	00002097          	auipc	ra,0x2
    219e:	612080e7          	jalr	1554(ra) # 47ac <printf>
      exit(1);
    21a2:	4505                	li	a0,1
    21a4:	00002097          	auipc	ra,0x2
    21a8:	280080e7          	jalr	640(ra) # 4424 <exit>
      printf("%s: read bigfile wrong data\n", s);
    21ac:	85d6                	mv	a1,s5
    21ae:	00003517          	auipc	a0,0x3
    21b2:	76250513          	addi	a0,a0,1890 # 5910 <malloc+0x10a6>
    21b6:	00002097          	auipc	ra,0x2
    21ba:	5f6080e7          	jalr	1526(ra) # 47ac <printf>
      exit(1);
    21be:	4505                	li	a0,1
    21c0:	00002097          	auipc	ra,0x2
    21c4:	264080e7          	jalr	612(ra) # 4424 <exit>
  close(fd);
    21c8:	8552                	mv	a0,s4
    21ca:	00002097          	auipc	ra,0x2
    21ce:	282080e7          	jalr	642(ra) # 444c <close>
  if(total != N*SZ){
    21d2:	678d                	lui	a5,0x3
    21d4:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x502>
    21d8:	02f99363          	bne	s3,a5,21fe <bigfile+0x1c4>
  unlink("bigfile.test");
    21dc:	00003517          	auipc	a0,0x3
    21e0:	68c50513          	addi	a0,a0,1676 # 5868 <malloc+0xffe>
    21e4:	00002097          	auipc	ra,0x2
    21e8:	290080e7          	jalr	656(ra) # 4474 <unlink>
}
    21ec:	70e2                	ld	ra,56(sp)
    21ee:	7442                	ld	s0,48(sp)
    21f0:	74a2                	ld	s1,40(sp)
    21f2:	7902                	ld	s2,32(sp)
    21f4:	69e2                	ld	s3,24(sp)
    21f6:	6a42                	ld	s4,16(sp)
    21f8:	6aa2                	ld	s5,8(sp)
    21fa:	6121                	addi	sp,sp,64
    21fc:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    21fe:	85d6                	mv	a1,s5
    2200:	00003517          	auipc	a0,0x3
    2204:	73050513          	addi	a0,a0,1840 # 5930 <malloc+0x10c6>
    2208:	00002097          	auipc	ra,0x2
    220c:	5a4080e7          	jalr	1444(ra) # 47ac <printf>
    exit(1);
    2210:	4505                	li	a0,1
    2212:	00002097          	auipc	ra,0x2
    2216:	212080e7          	jalr	530(ra) # 4424 <exit>

000000000000221a <linktest>:
{
    221a:	1101                	addi	sp,sp,-32
    221c:	ec06                	sd	ra,24(sp)
    221e:	e822                	sd	s0,16(sp)
    2220:	e426                	sd	s1,8(sp)
    2222:	e04a                	sd	s2,0(sp)
    2224:	1000                	addi	s0,sp,32
    2226:	892a                	mv	s2,a0
  unlink("lf1");
    2228:	00003517          	auipc	a0,0x3
    222c:	72850513          	addi	a0,a0,1832 # 5950 <malloc+0x10e6>
    2230:	00002097          	auipc	ra,0x2
    2234:	244080e7          	jalr	580(ra) # 4474 <unlink>
  unlink("lf2");
    2238:	00003517          	auipc	a0,0x3
    223c:	72050513          	addi	a0,a0,1824 # 5958 <malloc+0x10ee>
    2240:	00002097          	auipc	ra,0x2
    2244:	234080e7          	jalr	564(ra) # 4474 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
    2248:	20200593          	li	a1,514
    224c:	00003517          	auipc	a0,0x3
    2250:	70450513          	addi	a0,a0,1796 # 5950 <malloc+0x10e6>
    2254:	00002097          	auipc	ra,0x2
    2258:	210080e7          	jalr	528(ra) # 4464 <open>
  if(fd < 0){
    225c:	10054763          	bltz	a0,236a <linktest+0x150>
    2260:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
    2262:	4615                	li	a2,5
    2264:	00003597          	auipc	a1,0x3
    2268:	1d458593          	addi	a1,a1,468 # 5438 <malloc+0xbce>
    226c:	00002097          	auipc	ra,0x2
    2270:	1d8080e7          	jalr	472(ra) # 4444 <write>
    2274:	4795                	li	a5,5
    2276:	10f51863          	bne	a0,a5,2386 <linktest+0x16c>
  close(fd);
    227a:	8526                	mv	a0,s1
    227c:	00002097          	auipc	ra,0x2
    2280:	1d0080e7          	jalr	464(ra) # 444c <close>
  if(link("lf1", "lf2") < 0){
    2284:	00003597          	auipc	a1,0x3
    2288:	6d458593          	addi	a1,a1,1748 # 5958 <malloc+0x10ee>
    228c:	00003517          	auipc	a0,0x3
    2290:	6c450513          	addi	a0,a0,1732 # 5950 <malloc+0x10e6>
    2294:	00002097          	auipc	ra,0x2
    2298:	1f0080e7          	jalr	496(ra) # 4484 <link>
    229c:	10054363          	bltz	a0,23a2 <linktest+0x188>
  unlink("lf1");
    22a0:	00003517          	auipc	a0,0x3
    22a4:	6b050513          	addi	a0,a0,1712 # 5950 <malloc+0x10e6>
    22a8:	00002097          	auipc	ra,0x2
    22ac:	1cc080e7          	jalr	460(ra) # 4474 <unlink>
  if(open("lf1", 0) >= 0){
    22b0:	4581                	li	a1,0
    22b2:	00003517          	auipc	a0,0x3
    22b6:	69e50513          	addi	a0,a0,1694 # 5950 <malloc+0x10e6>
    22ba:	00002097          	auipc	ra,0x2
    22be:	1aa080e7          	jalr	426(ra) # 4464 <open>
    22c2:	0e055e63          	bgez	a0,23be <linktest+0x1a4>
  fd = open("lf2", 0);
    22c6:	4581                	li	a1,0
    22c8:	00003517          	auipc	a0,0x3
    22cc:	69050513          	addi	a0,a0,1680 # 5958 <malloc+0x10ee>
    22d0:	00002097          	auipc	ra,0x2
    22d4:	194080e7          	jalr	404(ra) # 4464 <open>
    22d8:	84aa                	mv	s1,a0
  if(fd < 0){
    22da:	10054063          	bltz	a0,23da <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
    22de:	660d                	lui	a2,0x3
    22e0:	00007597          	auipc	a1,0x7
    22e4:	f5858593          	addi	a1,a1,-168 # 9238 <buf>
    22e8:	00002097          	auipc	ra,0x2
    22ec:	154080e7          	jalr	340(ra) # 443c <read>
    22f0:	4795                	li	a5,5
    22f2:	10f51263          	bne	a0,a5,23f6 <linktest+0x1dc>
  close(fd);
    22f6:	8526                	mv	a0,s1
    22f8:	00002097          	auipc	ra,0x2
    22fc:	154080e7          	jalr	340(ra) # 444c <close>
  if(link("lf2", "lf2") >= 0){
    2300:	00003597          	auipc	a1,0x3
    2304:	65858593          	addi	a1,a1,1624 # 5958 <malloc+0x10ee>
    2308:	852e                	mv	a0,a1
    230a:	00002097          	auipc	ra,0x2
    230e:	17a080e7          	jalr	378(ra) # 4484 <link>
    2312:	10055063          	bgez	a0,2412 <linktest+0x1f8>
  unlink("lf2");
    2316:	00003517          	auipc	a0,0x3
    231a:	64250513          	addi	a0,a0,1602 # 5958 <malloc+0x10ee>
    231e:	00002097          	auipc	ra,0x2
    2322:	156080e7          	jalr	342(ra) # 4474 <unlink>
  if(link("lf2", "lf1") >= 0){
    2326:	00003597          	auipc	a1,0x3
    232a:	62a58593          	addi	a1,a1,1578 # 5950 <malloc+0x10e6>
    232e:	00003517          	auipc	a0,0x3
    2332:	62a50513          	addi	a0,a0,1578 # 5958 <malloc+0x10ee>
    2336:	00002097          	auipc	ra,0x2
    233a:	14e080e7          	jalr	334(ra) # 4484 <link>
    233e:	0e055863          	bgez	a0,242e <linktest+0x214>
  if(link(".", "lf1") >= 0){
    2342:	00003597          	auipc	a1,0x3
    2346:	60e58593          	addi	a1,a1,1550 # 5950 <malloc+0x10e6>
    234a:	00003517          	auipc	a0,0x3
    234e:	96e50513          	addi	a0,a0,-1682 # 4cb8 <malloc+0x44e>
    2352:	00002097          	auipc	ra,0x2
    2356:	132080e7          	jalr	306(ra) # 4484 <link>
    235a:	0e055863          	bgez	a0,244a <linktest+0x230>
}
    235e:	60e2                	ld	ra,24(sp)
    2360:	6442                	ld	s0,16(sp)
    2362:	64a2                	ld	s1,8(sp)
    2364:	6902                	ld	s2,0(sp)
    2366:	6105                	addi	sp,sp,32
    2368:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    236a:	85ca                	mv	a1,s2
    236c:	00003517          	auipc	a0,0x3
    2370:	5f450513          	addi	a0,a0,1524 # 5960 <malloc+0x10f6>
    2374:	00002097          	auipc	ra,0x2
    2378:	438080e7          	jalr	1080(ra) # 47ac <printf>
    exit(1);
    237c:	4505                	li	a0,1
    237e:	00002097          	auipc	ra,0x2
    2382:	0a6080e7          	jalr	166(ra) # 4424 <exit>
    printf("%s: write lf1 failed\n", s);
    2386:	85ca                	mv	a1,s2
    2388:	00003517          	auipc	a0,0x3
    238c:	5f050513          	addi	a0,a0,1520 # 5978 <malloc+0x110e>
    2390:	00002097          	auipc	ra,0x2
    2394:	41c080e7          	jalr	1052(ra) # 47ac <printf>
    exit(1);
    2398:	4505                	li	a0,1
    239a:	00002097          	auipc	ra,0x2
    239e:	08a080e7          	jalr	138(ra) # 4424 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    23a2:	85ca                	mv	a1,s2
    23a4:	00003517          	auipc	a0,0x3
    23a8:	5ec50513          	addi	a0,a0,1516 # 5990 <malloc+0x1126>
    23ac:	00002097          	auipc	ra,0x2
    23b0:	400080e7          	jalr	1024(ra) # 47ac <printf>
    exit(1);
    23b4:	4505                	li	a0,1
    23b6:	00002097          	auipc	ra,0x2
    23ba:	06e080e7          	jalr	110(ra) # 4424 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    23be:	85ca                	mv	a1,s2
    23c0:	00003517          	auipc	a0,0x3
    23c4:	5f050513          	addi	a0,a0,1520 # 59b0 <malloc+0x1146>
    23c8:	00002097          	auipc	ra,0x2
    23cc:	3e4080e7          	jalr	996(ra) # 47ac <printf>
    exit(1);
    23d0:	4505                	li	a0,1
    23d2:	00002097          	auipc	ra,0x2
    23d6:	052080e7          	jalr	82(ra) # 4424 <exit>
    printf("%s: open lf2 failed\n", s);
    23da:	85ca                	mv	a1,s2
    23dc:	00003517          	auipc	a0,0x3
    23e0:	60450513          	addi	a0,a0,1540 # 59e0 <malloc+0x1176>
    23e4:	00002097          	auipc	ra,0x2
    23e8:	3c8080e7          	jalr	968(ra) # 47ac <printf>
    exit(1);
    23ec:	4505                	li	a0,1
    23ee:	00002097          	auipc	ra,0x2
    23f2:	036080e7          	jalr	54(ra) # 4424 <exit>
    printf("%s: read lf2 failed\n", s);
    23f6:	85ca                	mv	a1,s2
    23f8:	00003517          	auipc	a0,0x3
    23fc:	60050513          	addi	a0,a0,1536 # 59f8 <malloc+0x118e>
    2400:	00002097          	auipc	ra,0x2
    2404:	3ac080e7          	jalr	940(ra) # 47ac <printf>
    exit(1);
    2408:	4505                	li	a0,1
    240a:	00002097          	auipc	ra,0x2
    240e:	01a080e7          	jalr	26(ra) # 4424 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    2412:	85ca                	mv	a1,s2
    2414:	00003517          	auipc	a0,0x3
    2418:	5fc50513          	addi	a0,a0,1532 # 5a10 <malloc+0x11a6>
    241c:	00002097          	auipc	ra,0x2
    2420:	390080e7          	jalr	912(ra) # 47ac <printf>
    exit(1);
    2424:	4505                	li	a0,1
    2426:	00002097          	auipc	ra,0x2
    242a:	ffe080e7          	jalr	-2(ra) # 4424 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
    242e:	85ca                	mv	a1,s2
    2430:	00003517          	auipc	a0,0x3
    2434:	60850513          	addi	a0,a0,1544 # 5a38 <malloc+0x11ce>
    2438:	00002097          	auipc	ra,0x2
    243c:	374080e7          	jalr	884(ra) # 47ac <printf>
    exit(1);
    2440:	4505                	li	a0,1
    2442:	00002097          	auipc	ra,0x2
    2446:	fe2080e7          	jalr	-30(ra) # 4424 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    244a:	85ca                	mv	a1,s2
    244c:	00003517          	auipc	a0,0x3
    2450:	61450513          	addi	a0,a0,1556 # 5a60 <malloc+0x11f6>
    2454:	00002097          	auipc	ra,0x2
    2458:	358080e7          	jalr	856(ra) # 47ac <printf>
    exit(1);
    245c:	4505                	li	a0,1
    245e:	00002097          	auipc	ra,0x2
    2462:	fc6080e7          	jalr	-58(ra) # 4424 <exit>

0000000000002466 <concreate>:
{
    2466:	7135                	addi	sp,sp,-160
    2468:	ed06                	sd	ra,152(sp)
    246a:	e922                	sd	s0,144(sp)
    246c:	e526                	sd	s1,136(sp)
    246e:	e14a                	sd	s2,128(sp)
    2470:	fcce                	sd	s3,120(sp)
    2472:	f8d2                	sd	s4,112(sp)
    2474:	f4d6                	sd	s5,104(sp)
    2476:	f0da                	sd	s6,96(sp)
    2478:	ecde                	sd	s7,88(sp)
    247a:	1100                	addi	s0,sp,160
    247c:	89aa                	mv	s3,a0
  file[0] = 'C';
    247e:	04300793          	li	a5,67
    2482:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    2486:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    248a:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    248c:	4b0d                	li	s6,3
    248e:	4a85                	li	s5,1
      link("C0", file);
    2490:	00003b97          	auipc	s7,0x3
    2494:	5f0b8b93          	addi	s7,s7,1520 # 5a80 <malloc+0x1216>
  for(i = 0; i < N; i++){
    2498:	02800a13          	li	s4,40
    249c:	a471                	j	2728 <concreate+0x2c2>
      link("C0", file);
    249e:	fa840593          	addi	a1,s0,-88
    24a2:	855e                	mv	a0,s7
    24a4:	00002097          	auipc	ra,0x2
    24a8:	fe0080e7          	jalr	-32(ra) # 4484 <link>
    if(pid == 0) {
    24ac:	a48d                	j	270e <concreate+0x2a8>
    } else if(pid == 0 && (i % 5) == 1){
    24ae:	4795                	li	a5,5
    24b0:	02f9693b          	remw	s2,s2,a5
    24b4:	4785                	li	a5,1
    24b6:	02f90b63          	beq	s2,a5,24ec <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    24ba:	20200593          	li	a1,514
    24be:	fa840513          	addi	a0,s0,-88
    24c2:	00002097          	auipc	ra,0x2
    24c6:	fa2080e7          	jalr	-94(ra) # 4464 <open>
      if(fd < 0){
    24ca:	22055963          	bgez	a0,26fc <concreate+0x296>
        printf("concreate create %s failed\n", file);
    24ce:	fa840593          	addi	a1,s0,-88
    24d2:	00003517          	auipc	a0,0x3
    24d6:	5b650513          	addi	a0,a0,1462 # 5a88 <malloc+0x121e>
    24da:	00002097          	auipc	ra,0x2
    24de:	2d2080e7          	jalr	722(ra) # 47ac <printf>
        exit(1);
    24e2:	4505                	li	a0,1
    24e4:	00002097          	auipc	ra,0x2
    24e8:	f40080e7          	jalr	-192(ra) # 4424 <exit>
      link("C0", file);
    24ec:	fa840593          	addi	a1,s0,-88
    24f0:	00003517          	auipc	a0,0x3
    24f4:	59050513          	addi	a0,a0,1424 # 5a80 <malloc+0x1216>
    24f8:	00002097          	auipc	ra,0x2
    24fc:	f8c080e7          	jalr	-116(ra) # 4484 <link>
      exit(0);
    2500:	4501                	li	a0,0
    2502:	00002097          	auipc	ra,0x2
    2506:	f22080e7          	jalr	-222(ra) # 4424 <exit>
        exit(1);
    250a:	4505                	li	a0,1
    250c:	00002097          	auipc	ra,0x2
    2510:	f18080e7          	jalr	-232(ra) # 4424 <exit>
  memset(fa, 0, sizeof(fa));
    2514:	02800613          	li	a2,40
    2518:	4581                	li	a1,0
    251a:	f8040513          	addi	a0,s0,-128
    251e:	00002097          	auipc	ra,0x2
    2522:	d0a080e7          	jalr	-758(ra) # 4228 <memset>
  fd = open(".", 0);
    2526:	4581                	li	a1,0
    2528:	00002517          	auipc	a0,0x2
    252c:	79050513          	addi	a0,a0,1936 # 4cb8 <malloc+0x44e>
    2530:	00002097          	auipc	ra,0x2
    2534:	f34080e7          	jalr	-204(ra) # 4464 <open>
    2538:	892a                	mv	s2,a0
  n = 0;
    253a:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    253c:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    2540:	02700b13          	li	s6,39
      fa[i] = 1;
    2544:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    2546:	4641                	li	a2,16
    2548:	f7040593          	addi	a1,s0,-144
    254c:	854a                	mv	a0,s2
    254e:	00002097          	auipc	ra,0x2
    2552:	eee080e7          	jalr	-274(ra) # 443c <read>
    2556:	08a05163          	blez	a0,25d8 <concreate+0x172>
    if(de.inum == 0)
    255a:	f7045783          	lhu	a5,-144(s0)
    255e:	d7e5                	beqz	a5,2546 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    2560:	f7244783          	lbu	a5,-142(s0)
    2564:	ff4791e3          	bne	a5,s4,2546 <concreate+0xe0>
    2568:	f7444783          	lbu	a5,-140(s0)
    256c:	ffe9                	bnez	a5,2546 <concreate+0xe0>
      i = de.name[1] - '0';
    256e:	f7344783          	lbu	a5,-141(s0)
    2572:	fd07879b          	addiw	a5,a5,-48
    2576:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    257a:	00eb6f63          	bltu	s6,a4,2598 <concreate+0x132>
      if(fa[i]){
    257e:	fb040793          	addi	a5,s0,-80
    2582:	97ba                	add	a5,a5,a4
    2584:	fd07c783          	lbu	a5,-48(a5)
    2588:	eb85                	bnez	a5,25b8 <concreate+0x152>
      fa[i] = 1;
    258a:	fb040793          	addi	a5,s0,-80
    258e:	973e                	add	a4,a4,a5
    2590:	fd770823          	sb	s7,-48(a4)
      n++;
    2594:	2a85                	addiw	s5,s5,1
    2596:	bf45                	j	2546 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    2598:	f7240613          	addi	a2,s0,-142
    259c:	85ce                	mv	a1,s3
    259e:	00003517          	auipc	a0,0x3
    25a2:	50a50513          	addi	a0,a0,1290 # 5aa8 <malloc+0x123e>
    25a6:	00002097          	auipc	ra,0x2
    25aa:	206080e7          	jalr	518(ra) # 47ac <printf>
        exit(1);
    25ae:	4505                	li	a0,1
    25b0:	00002097          	auipc	ra,0x2
    25b4:	e74080e7          	jalr	-396(ra) # 4424 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    25b8:	f7240613          	addi	a2,s0,-142
    25bc:	85ce                	mv	a1,s3
    25be:	00003517          	auipc	a0,0x3
    25c2:	50a50513          	addi	a0,a0,1290 # 5ac8 <malloc+0x125e>
    25c6:	00002097          	auipc	ra,0x2
    25ca:	1e6080e7          	jalr	486(ra) # 47ac <printf>
        exit(1);
    25ce:	4505                	li	a0,1
    25d0:	00002097          	auipc	ra,0x2
    25d4:	e54080e7          	jalr	-428(ra) # 4424 <exit>
  close(fd);
    25d8:	854a                	mv	a0,s2
    25da:	00002097          	auipc	ra,0x2
    25de:	e72080e7          	jalr	-398(ra) # 444c <close>
  if(n != N){
    25e2:	02800793          	li	a5,40
    25e6:	00fa9763          	bne	s5,a5,25f4 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    25ea:	4a8d                	li	s5,3
    25ec:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    25ee:	02800a13          	li	s4,40
    25f2:	a05d                	j	2698 <concreate+0x232>
    printf("%s: concreate not enough files in directory listing\n", s);
    25f4:	85ce                	mv	a1,s3
    25f6:	00003517          	auipc	a0,0x3
    25fa:	4fa50513          	addi	a0,a0,1274 # 5af0 <malloc+0x1286>
    25fe:	00002097          	auipc	ra,0x2
    2602:	1ae080e7          	jalr	430(ra) # 47ac <printf>
    exit(1);
    2606:	4505                	li	a0,1
    2608:	00002097          	auipc	ra,0x2
    260c:	e1c080e7          	jalr	-484(ra) # 4424 <exit>
      printf("%s: fork failed\n", s);
    2610:	85ce                	mv	a1,s3
    2612:	00002517          	auipc	a0,0x2
    2616:	75650513          	addi	a0,a0,1878 # 4d68 <malloc+0x4fe>
    261a:	00002097          	auipc	ra,0x2
    261e:	192080e7          	jalr	402(ra) # 47ac <printf>
      exit(1);
    2622:	4505                	li	a0,1
    2624:	00002097          	auipc	ra,0x2
    2628:	e00080e7          	jalr	-512(ra) # 4424 <exit>
      close(open(file, 0));
    262c:	4581                	li	a1,0
    262e:	fa840513          	addi	a0,s0,-88
    2632:	00002097          	auipc	ra,0x2
    2636:	e32080e7          	jalr	-462(ra) # 4464 <open>
    263a:	00002097          	auipc	ra,0x2
    263e:	e12080e7          	jalr	-494(ra) # 444c <close>
      close(open(file, 0));
    2642:	4581                	li	a1,0
    2644:	fa840513          	addi	a0,s0,-88
    2648:	00002097          	auipc	ra,0x2
    264c:	e1c080e7          	jalr	-484(ra) # 4464 <open>
    2650:	00002097          	auipc	ra,0x2
    2654:	dfc080e7          	jalr	-516(ra) # 444c <close>
      close(open(file, 0));
    2658:	4581                	li	a1,0
    265a:	fa840513          	addi	a0,s0,-88
    265e:	00002097          	auipc	ra,0x2
    2662:	e06080e7          	jalr	-506(ra) # 4464 <open>
    2666:	00002097          	auipc	ra,0x2
    266a:	de6080e7          	jalr	-538(ra) # 444c <close>
      close(open(file, 0));
    266e:	4581                	li	a1,0
    2670:	fa840513          	addi	a0,s0,-88
    2674:	00002097          	auipc	ra,0x2
    2678:	df0080e7          	jalr	-528(ra) # 4464 <open>
    267c:	00002097          	auipc	ra,0x2
    2680:	dd0080e7          	jalr	-560(ra) # 444c <close>
    if(pid == 0)
    2684:	06090763          	beqz	s2,26f2 <concreate+0x28c>
      wait(0);
    2688:	4501                	li	a0,0
    268a:	00002097          	auipc	ra,0x2
    268e:	da2080e7          	jalr	-606(ra) # 442c <wait>
  for(i = 0; i < N; i++){
    2692:	2485                	addiw	s1,s1,1
    2694:	0d448963          	beq	s1,s4,2766 <concreate+0x300>
    file[1] = '0' + i;
    2698:	0304879b          	addiw	a5,s1,48
    269c:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    26a0:	00002097          	auipc	ra,0x2
    26a4:	d7c080e7          	jalr	-644(ra) # 441c <fork>
    26a8:	892a                	mv	s2,a0
    if(pid < 0){
    26aa:	f60543e3          	bltz	a0,2610 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    26ae:	0354e73b          	remw	a4,s1,s5
    26b2:	00a767b3          	or	a5,a4,a0
    26b6:	2781                	sext.w	a5,a5
    26b8:	dbb5                	beqz	a5,262c <concreate+0x1c6>
    26ba:	01671363          	bne	a4,s6,26c0 <concreate+0x25a>
       ((i % 3) == 1 && pid != 0)){
    26be:	f53d                	bnez	a0,262c <concreate+0x1c6>
      unlink(file);
    26c0:	fa840513          	addi	a0,s0,-88
    26c4:	00002097          	auipc	ra,0x2
    26c8:	db0080e7          	jalr	-592(ra) # 4474 <unlink>
      unlink(file);
    26cc:	fa840513          	addi	a0,s0,-88
    26d0:	00002097          	auipc	ra,0x2
    26d4:	da4080e7          	jalr	-604(ra) # 4474 <unlink>
      unlink(file);
    26d8:	fa840513          	addi	a0,s0,-88
    26dc:	00002097          	auipc	ra,0x2
    26e0:	d98080e7          	jalr	-616(ra) # 4474 <unlink>
      unlink(file);
    26e4:	fa840513          	addi	a0,s0,-88
    26e8:	00002097          	auipc	ra,0x2
    26ec:	d8c080e7          	jalr	-628(ra) # 4474 <unlink>
    26f0:	bf51                	j	2684 <concreate+0x21e>
      exit(0);
    26f2:	4501                	li	a0,0
    26f4:	00002097          	auipc	ra,0x2
    26f8:	d30080e7          	jalr	-720(ra) # 4424 <exit>
      close(fd);
    26fc:	00002097          	auipc	ra,0x2
    2700:	d50080e7          	jalr	-688(ra) # 444c <close>
    if(pid == 0) {
    2704:	bbf5                	j	2500 <concreate+0x9a>
      close(fd);
    2706:	00002097          	auipc	ra,0x2
    270a:	d46080e7          	jalr	-698(ra) # 444c <close>
      wait(&xstatus);
    270e:	f6c40513          	addi	a0,s0,-148
    2712:	00002097          	auipc	ra,0x2
    2716:	d1a080e7          	jalr	-742(ra) # 442c <wait>
      if(xstatus != 0)
    271a:	f6c42483          	lw	s1,-148(s0)
    271e:	de0496e3          	bnez	s1,250a <concreate+0xa4>
  for(i = 0; i < N; i++){
    2722:	2905                	addiw	s2,s2,1
    2724:	df4908e3          	beq	s2,s4,2514 <concreate+0xae>
    file[1] = '0' + i;
    2728:	0309079b          	addiw	a5,s2,48
    272c:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    2730:	fa840513          	addi	a0,s0,-88
    2734:	00002097          	auipc	ra,0x2
    2738:	d40080e7          	jalr	-704(ra) # 4474 <unlink>
    pid = fork();
    273c:	00002097          	auipc	ra,0x2
    2740:	ce0080e7          	jalr	-800(ra) # 441c <fork>
    if(pid && (i % 3) == 1){
    2744:	d60505e3          	beqz	a0,24ae <concreate+0x48>
    2748:	036967bb          	remw	a5,s2,s6
    274c:	d55789e3          	beq	a5,s5,249e <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    2750:	20200593          	li	a1,514
    2754:	fa840513          	addi	a0,s0,-88
    2758:	00002097          	auipc	ra,0x2
    275c:	d0c080e7          	jalr	-756(ra) # 4464 <open>
      if(fd < 0){
    2760:	fa0553e3          	bgez	a0,2706 <concreate+0x2a0>
    2764:	b3ad                	j	24ce <concreate+0x68>
}
    2766:	60ea                	ld	ra,152(sp)
    2768:	644a                	ld	s0,144(sp)
    276a:	64aa                	ld	s1,136(sp)
    276c:	690a                	ld	s2,128(sp)
    276e:	79e6                	ld	s3,120(sp)
    2770:	7a46                	ld	s4,112(sp)
    2772:	7aa6                	ld	s5,104(sp)
    2774:	7b06                	ld	s6,96(sp)
    2776:	6be6                	ld	s7,88(sp)
    2778:	610d                	addi	sp,sp,160
    277a:	8082                	ret

000000000000277c <linkunlink>:
{
    277c:	711d                	addi	sp,sp,-96
    277e:	ec86                	sd	ra,88(sp)
    2780:	e8a2                	sd	s0,80(sp)
    2782:	e4a6                	sd	s1,72(sp)
    2784:	e0ca                	sd	s2,64(sp)
    2786:	fc4e                	sd	s3,56(sp)
    2788:	f852                	sd	s4,48(sp)
    278a:	f456                	sd	s5,40(sp)
    278c:	f05a                	sd	s6,32(sp)
    278e:	ec5e                	sd	s7,24(sp)
    2790:	e862                	sd	s8,16(sp)
    2792:	e466                	sd	s9,8(sp)
    2794:	1080                	addi	s0,sp,96
    2796:	84aa                	mv	s1,a0
  unlink("x");
    2798:	00003517          	auipc	a0,0x3
    279c:	f8050513          	addi	a0,a0,-128 # 5718 <malloc+0xeae>
    27a0:	00002097          	auipc	ra,0x2
    27a4:	cd4080e7          	jalr	-812(ra) # 4474 <unlink>
  pid = fork();
    27a8:	00002097          	auipc	ra,0x2
    27ac:	c74080e7          	jalr	-908(ra) # 441c <fork>
  if(pid < 0){
    27b0:	02054b63          	bltz	a0,27e6 <linkunlink+0x6a>
    27b4:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    27b6:	4c85                	li	s9,1
    27b8:	e119                	bnez	a0,27be <linkunlink+0x42>
    27ba:	06100c93          	li	s9,97
    27be:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    27c2:	41c659b7          	lui	s3,0x41c65
    27c6:	e6d9899b          	addiw	s3,s3,-403
    27ca:	690d                	lui	s2,0x3
    27cc:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    27d0:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    27d2:	4b05                	li	s6,1
      unlink("x");
    27d4:	00003a97          	auipc	s5,0x3
    27d8:	f44a8a93          	addi	s5,s5,-188 # 5718 <malloc+0xeae>
      link("cat", "x");
    27dc:	00003b97          	auipc	s7,0x3
    27e0:	34cb8b93          	addi	s7,s7,844 # 5b28 <malloc+0x12be>
    27e4:	a825                	j	281c <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    27e6:	85a6                	mv	a1,s1
    27e8:	00002517          	auipc	a0,0x2
    27ec:	58050513          	addi	a0,a0,1408 # 4d68 <malloc+0x4fe>
    27f0:	00002097          	auipc	ra,0x2
    27f4:	fbc080e7          	jalr	-68(ra) # 47ac <printf>
    exit(1);
    27f8:	4505                	li	a0,1
    27fa:	00002097          	auipc	ra,0x2
    27fe:	c2a080e7          	jalr	-982(ra) # 4424 <exit>
      close(open("x", O_RDWR | O_CREATE));
    2802:	20200593          	li	a1,514
    2806:	8556                	mv	a0,s5
    2808:	00002097          	auipc	ra,0x2
    280c:	c5c080e7          	jalr	-932(ra) # 4464 <open>
    2810:	00002097          	auipc	ra,0x2
    2814:	c3c080e7          	jalr	-964(ra) # 444c <close>
  for(i = 0; i < 100; i++){
    2818:	34fd                	addiw	s1,s1,-1
    281a:	c88d                	beqz	s1,284c <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    281c:	033c87bb          	mulw	a5,s9,s3
    2820:	012787bb          	addw	a5,a5,s2
    2824:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    2828:	0347f7bb          	remuw	a5,a5,s4
    282c:	dbf9                	beqz	a5,2802 <linkunlink+0x86>
    } else if((x % 3) == 1){
    282e:	01678863          	beq	a5,s6,283e <linkunlink+0xc2>
      unlink("x");
    2832:	8556                	mv	a0,s5
    2834:	00002097          	auipc	ra,0x2
    2838:	c40080e7          	jalr	-960(ra) # 4474 <unlink>
    283c:	bff1                	j	2818 <linkunlink+0x9c>
      link("cat", "x");
    283e:	85d6                	mv	a1,s5
    2840:	855e                	mv	a0,s7
    2842:	00002097          	auipc	ra,0x2
    2846:	c42080e7          	jalr	-958(ra) # 4484 <link>
    284a:	b7f9                	j	2818 <linkunlink+0x9c>
  if(pid)
    284c:	020c0463          	beqz	s8,2874 <linkunlink+0xf8>
    wait(0);
    2850:	4501                	li	a0,0
    2852:	00002097          	auipc	ra,0x2
    2856:	bda080e7          	jalr	-1062(ra) # 442c <wait>
}
    285a:	60e6                	ld	ra,88(sp)
    285c:	6446                	ld	s0,80(sp)
    285e:	64a6                	ld	s1,72(sp)
    2860:	6906                	ld	s2,64(sp)
    2862:	79e2                	ld	s3,56(sp)
    2864:	7a42                	ld	s4,48(sp)
    2866:	7aa2                	ld	s5,40(sp)
    2868:	7b02                	ld	s6,32(sp)
    286a:	6be2                	ld	s7,24(sp)
    286c:	6c42                	ld	s8,16(sp)
    286e:	6ca2                	ld	s9,8(sp)
    2870:	6125                	addi	sp,sp,96
    2872:	8082                	ret
    exit(0);
    2874:	4501                	li	a0,0
    2876:	00002097          	auipc	ra,0x2
    287a:	bae080e7          	jalr	-1106(ra) # 4424 <exit>

000000000000287e <bigdir>:
{
    287e:	715d                	addi	sp,sp,-80
    2880:	e486                	sd	ra,72(sp)
    2882:	e0a2                	sd	s0,64(sp)
    2884:	fc26                	sd	s1,56(sp)
    2886:	f84a                	sd	s2,48(sp)
    2888:	f44e                	sd	s3,40(sp)
    288a:	f052                	sd	s4,32(sp)
    288c:	ec56                	sd	s5,24(sp)
    288e:	e85a                	sd	s6,16(sp)
    2890:	0880                	addi	s0,sp,80
    2892:	89aa                	mv	s3,a0
  unlink("bd");
    2894:	00003517          	auipc	a0,0x3
    2898:	29c50513          	addi	a0,a0,668 # 5b30 <malloc+0x12c6>
    289c:	00002097          	auipc	ra,0x2
    28a0:	bd8080e7          	jalr	-1064(ra) # 4474 <unlink>
  fd = open("bd", O_CREATE);
    28a4:	20000593          	li	a1,512
    28a8:	00003517          	auipc	a0,0x3
    28ac:	28850513          	addi	a0,a0,648 # 5b30 <malloc+0x12c6>
    28b0:	00002097          	auipc	ra,0x2
    28b4:	bb4080e7          	jalr	-1100(ra) # 4464 <open>
  if(fd < 0){
    28b8:	0c054963          	bltz	a0,298a <bigdir+0x10c>
  close(fd);
    28bc:	00002097          	auipc	ra,0x2
    28c0:	b90080e7          	jalr	-1136(ra) # 444c <close>
  for(i = 0; i < N; i++){
    28c4:	4901                	li	s2,0
    name[0] = 'x';
    28c6:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    28ca:	00003a17          	auipc	s4,0x3
    28ce:	266a0a13          	addi	s4,s4,614 # 5b30 <malloc+0x12c6>
  for(i = 0; i < N; i++){
    28d2:	1f400b13          	li	s6,500
    name[0] = 'x';
    28d6:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    28da:	41f9579b          	sraiw	a5,s2,0x1f
    28de:	01a7d71b          	srliw	a4,a5,0x1a
    28e2:	012707bb          	addw	a5,a4,s2
    28e6:	4067d69b          	sraiw	a3,a5,0x6
    28ea:	0306869b          	addiw	a3,a3,48
    28ee:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    28f2:	03f7f793          	andi	a5,a5,63
    28f6:	9f99                	subw	a5,a5,a4
    28f8:	0307879b          	addiw	a5,a5,48
    28fc:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    2900:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    2904:	fb040593          	addi	a1,s0,-80
    2908:	8552                	mv	a0,s4
    290a:	00002097          	auipc	ra,0x2
    290e:	b7a080e7          	jalr	-1158(ra) # 4484 <link>
    2912:	84aa                	mv	s1,a0
    2914:	e949                	bnez	a0,29a6 <bigdir+0x128>
  for(i = 0; i < N; i++){
    2916:	2905                	addiw	s2,s2,1
    2918:	fb691fe3          	bne	s2,s6,28d6 <bigdir+0x58>
  unlink("bd");
    291c:	00003517          	auipc	a0,0x3
    2920:	21450513          	addi	a0,a0,532 # 5b30 <malloc+0x12c6>
    2924:	00002097          	auipc	ra,0x2
    2928:	b50080e7          	jalr	-1200(ra) # 4474 <unlink>
    name[0] = 'x';
    292c:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    2930:	1f400a13          	li	s4,500
    name[0] = 'x';
    2934:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    2938:	41f4d79b          	sraiw	a5,s1,0x1f
    293c:	01a7d71b          	srliw	a4,a5,0x1a
    2940:	009707bb          	addw	a5,a4,s1
    2944:	4067d69b          	sraiw	a3,a5,0x6
    2948:	0306869b          	addiw	a3,a3,48
    294c:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    2950:	03f7f793          	andi	a5,a5,63
    2954:	9f99                	subw	a5,a5,a4
    2956:	0307879b          	addiw	a5,a5,48
    295a:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    295e:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    2962:	fb040513          	addi	a0,s0,-80
    2966:	00002097          	auipc	ra,0x2
    296a:	b0e080e7          	jalr	-1266(ra) # 4474 <unlink>
    296e:	e931                	bnez	a0,29c2 <bigdir+0x144>
  for(i = 0; i < N; i++){
    2970:	2485                	addiw	s1,s1,1
    2972:	fd4491e3          	bne	s1,s4,2934 <bigdir+0xb6>
}
    2976:	60a6                	ld	ra,72(sp)
    2978:	6406                	ld	s0,64(sp)
    297a:	74e2                	ld	s1,56(sp)
    297c:	7942                	ld	s2,48(sp)
    297e:	79a2                	ld	s3,40(sp)
    2980:	7a02                	ld	s4,32(sp)
    2982:	6ae2                	ld	s5,24(sp)
    2984:	6b42                	ld	s6,16(sp)
    2986:	6161                	addi	sp,sp,80
    2988:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    298a:	85ce                	mv	a1,s3
    298c:	00003517          	auipc	a0,0x3
    2990:	1ac50513          	addi	a0,a0,428 # 5b38 <malloc+0x12ce>
    2994:	00002097          	auipc	ra,0x2
    2998:	e18080e7          	jalr	-488(ra) # 47ac <printf>
    exit(1);
    299c:	4505                	li	a0,1
    299e:	00002097          	auipc	ra,0x2
    29a2:	a86080e7          	jalr	-1402(ra) # 4424 <exit>
      printf("%s: bigdir link failed\n", s);
    29a6:	85ce                	mv	a1,s3
    29a8:	00003517          	auipc	a0,0x3
    29ac:	1b050513          	addi	a0,a0,432 # 5b58 <malloc+0x12ee>
    29b0:	00002097          	auipc	ra,0x2
    29b4:	dfc080e7          	jalr	-516(ra) # 47ac <printf>
      exit(1);
    29b8:	4505                	li	a0,1
    29ba:	00002097          	auipc	ra,0x2
    29be:	a6a080e7          	jalr	-1430(ra) # 4424 <exit>
      printf("%s: bigdir unlink failed", s);
    29c2:	85ce                	mv	a1,s3
    29c4:	00003517          	auipc	a0,0x3
    29c8:	1ac50513          	addi	a0,a0,428 # 5b70 <malloc+0x1306>
    29cc:	00002097          	auipc	ra,0x2
    29d0:	de0080e7          	jalr	-544(ra) # 47ac <printf>
      exit(1);
    29d4:	4505                	li	a0,1
    29d6:	00002097          	auipc	ra,0x2
    29da:	a4e080e7          	jalr	-1458(ra) # 4424 <exit>

00000000000029de <subdir>:
{
    29de:	1101                	addi	sp,sp,-32
    29e0:	ec06                	sd	ra,24(sp)
    29e2:	e822                	sd	s0,16(sp)
    29e4:	e426                	sd	s1,8(sp)
    29e6:	e04a                	sd	s2,0(sp)
    29e8:	1000                	addi	s0,sp,32
    29ea:	892a                	mv	s2,a0
  unlink("ff");
    29ec:	00003517          	auipc	a0,0x3
    29f0:	2d450513          	addi	a0,a0,724 # 5cc0 <malloc+0x1456>
    29f4:	00002097          	auipc	ra,0x2
    29f8:	a80080e7          	jalr	-1408(ra) # 4474 <unlink>
  if(mkdir("dd") != 0){
    29fc:	00003517          	auipc	a0,0x3
    2a00:	19450513          	addi	a0,a0,404 # 5b90 <malloc+0x1326>
    2a04:	00002097          	auipc	ra,0x2
    2a08:	a88080e7          	jalr	-1400(ra) # 448c <mkdir>
    2a0c:	38051663          	bnez	a0,2d98 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2a10:	20200593          	li	a1,514
    2a14:	00003517          	auipc	a0,0x3
    2a18:	19c50513          	addi	a0,a0,412 # 5bb0 <malloc+0x1346>
    2a1c:	00002097          	auipc	ra,0x2
    2a20:	a48080e7          	jalr	-1464(ra) # 4464 <open>
    2a24:	84aa                	mv	s1,a0
  if(fd < 0){
    2a26:	38054763          	bltz	a0,2db4 <subdir+0x3d6>
  write(fd, "ff", 2);
    2a2a:	4609                	li	a2,2
    2a2c:	00003597          	auipc	a1,0x3
    2a30:	29458593          	addi	a1,a1,660 # 5cc0 <malloc+0x1456>
    2a34:	00002097          	auipc	ra,0x2
    2a38:	a10080e7          	jalr	-1520(ra) # 4444 <write>
  close(fd);
    2a3c:	8526                	mv	a0,s1
    2a3e:	00002097          	auipc	ra,0x2
    2a42:	a0e080e7          	jalr	-1522(ra) # 444c <close>
  if(unlink("dd") >= 0){
    2a46:	00003517          	auipc	a0,0x3
    2a4a:	14a50513          	addi	a0,a0,330 # 5b90 <malloc+0x1326>
    2a4e:	00002097          	auipc	ra,0x2
    2a52:	a26080e7          	jalr	-1498(ra) # 4474 <unlink>
    2a56:	36055d63          	bgez	a0,2dd0 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2a5a:	00003517          	auipc	a0,0x3
    2a5e:	1ae50513          	addi	a0,a0,430 # 5c08 <malloc+0x139e>
    2a62:	00002097          	auipc	ra,0x2
    2a66:	a2a080e7          	jalr	-1494(ra) # 448c <mkdir>
    2a6a:	38051163          	bnez	a0,2dec <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2a6e:	20200593          	li	a1,514
    2a72:	00003517          	auipc	a0,0x3
    2a76:	1be50513          	addi	a0,a0,446 # 5c30 <malloc+0x13c6>
    2a7a:	00002097          	auipc	ra,0x2
    2a7e:	9ea080e7          	jalr	-1558(ra) # 4464 <open>
    2a82:	84aa                	mv	s1,a0
  if(fd < 0){
    2a84:	38054263          	bltz	a0,2e08 <subdir+0x42a>
  write(fd, "FF", 2);
    2a88:	4609                	li	a2,2
    2a8a:	00003597          	auipc	a1,0x3
    2a8e:	1d658593          	addi	a1,a1,470 # 5c60 <malloc+0x13f6>
    2a92:	00002097          	auipc	ra,0x2
    2a96:	9b2080e7          	jalr	-1614(ra) # 4444 <write>
  close(fd);
    2a9a:	8526                	mv	a0,s1
    2a9c:	00002097          	auipc	ra,0x2
    2aa0:	9b0080e7          	jalr	-1616(ra) # 444c <close>
  fd = open("dd/dd/../ff", 0);
    2aa4:	4581                	li	a1,0
    2aa6:	00003517          	auipc	a0,0x3
    2aaa:	1c250513          	addi	a0,a0,450 # 5c68 <malloc+0x13fe>
    2aae:	00002097          	auipc	ra,0x2
    2ab2:	9b6080e7          	jalr	-1610(ra) # 4464 <open>
    2ab6:	84aa                	mv	s1,a0
  if(fd < 0){
    2ab8:	36054663          	bltz	a0,2e24 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    2abc:	660d                	lui	a2,0x3
    2abe:	00006597          	auipc	a1,0x6
    2ac2:	77a58593          	addi	a1,a1,1914 # 9238 <buf>
    2ac6:	00002097          	auipc	ra,0x2
    2aca:	976080e7          	jalr	-1674(ra) # 443c <read>
  if(cc != 2 || buf[0] != 'f'){
    2ace:	4789                	li	a5,2
    2ad0:	36f51863          	bne	a0,a5,2e40 <subdir+0x462>
    2ad4:	00006717          	auipc	a4,0x6
    2ad8:	76474703          	lbu	a4,1892(a4) # 9238 <buf>
    2adc:	06600793          	li	a5,102
    2ae0:	36f71063          	bne	a4,a5,2e40 <subdir+0x462>
  close(fd);
    2ae4:	8526                	mv	a0,s1
    2ae6:	00002097          	auipc	ra,0x2
    2aea:	966080e7          	jalr	-1690(ra) # 444c <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2aee:	00003597          	auipc	a1,0x3
    2af2:	1ca58593          	addi	a1,a1,458 # 5cb8 <malloc+0x144e>
    2af6:	00003517          	auipc	a0,0x3
    2afa:	13a50513          	addi	a0,a0,314 # 5c30 <malloc+0x13c6>
    2afe:	00002097          	auipc	ra,0x2
    2b02:	986080e7          	jalr	-1658(ra) # 4484 <link>
    2b06:	34051b63          	bnez	a0,2e5c <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    2b0a:	00003517          	auipc	a0,0x3
    2b0e:	12650513          	addi	a0,a0,294 # 5c30 <malloc+0x13c6>
    2b12:	00002097          	auipc	ra,0x2
    2b16:	962080e7          	jalr	-1694(ra) # 4474 <unlink>
    2b1a:	34051f63          	bnez	a0,2e78 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2b1e:	4581                	li	a1,0
    2b20:	00003517          	auipc	a0,0x3
    2b24:	11050513          	addi	a0,a0,272 # 5c30 <malloc+0x13c6>
    2b28:	00002097          	auipc	ra,0x2
    2b2c:	93c080e7          	jalr	-1732(ra) # 4464 <open>
    2b30:	36055263          	bgez	a0,2e94 <subdir+0x4b6>
  if(chdir("dd") != 0){
    2b34:	00003517          	auipc	a0,0x3
    2b38:	05c50513          	addi	a0,a0,92 # 5b90 <malloc+0x1326>
    2b3c:	00002097          	auipc	ra,0x2
    2b40:	958080e7          	jalr	-1704(ra) # 4494 <chdir>
    2b44:	36051663          	bnez	a0,2eb0 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    2b48:	00003517          	auipc	a0,0x3
    2b4c:	20850513          	addi	a0,a0,520 # 5d50 <malloc+0x14e6>
    2b50:	00002097          	auipc	ra,0x2
    2b54:	944080e7          	jalr	-1724(ra) # 4494 <chdir>
    2b58:	36051a63          	bnez	a0,2ecc <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    2b5c:	00003517          	auipc	a0,0x3
    2b60:	22450513          	addi	a0,a0,548 # 5d80 <malloc+0x1516>
    2b64:	00002097          	auipc	ra,0x2
    2b68:	930080e7          	jalr	-1744(ra) # 4494 <chdir>
    2b6c:	36051e63          	bnez	a0,2ee8 <subdir+0x50a>
  if(chdir("./..") != 0){
    2b70:	00003517          	auipc	a0,0x3
    2b74:	24050513          	addi	a0,a0,576 # 5db0 <malloc+0x1546>
    2b78:	00002097          	auipc	ra,0x2
    2b7c:	91c080e7          	jalr	-1764(ra) # 4494 <chdir>
    2b80:	38051263          	bnez	a0,2f04 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    2b84:	4581                	li	a1,0
    2b86:	00003517          	auipc	a0,0x3
    2b8a:	13250513          	addi	a0,a0,306 # 5cb8 <malloc+0x144e>
    2b8e:	00002097          	auipc	ra,0x2
    2b92:	8d6080e7          	jalr	-1834(ra) # 4464 <open>
    2b96:	84aa                	mv	s1,a0
  if(fd < 0){
    2b98:	38054463          	bltz	a0,2f20 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    2b9c:	660d                	lui	a2,0x3
    2b9e:	00006597          	auipc	a1,0x6
    2ba2:	69a58593          	addi	a1,a1,1690 # 9238 <buf>
    2ba6:	00002097          	auipc	ra,0x2
    2baa:	896080e7          	jalr	-1898(ra) # 443c <read>
    2bae:	4789                	li	a5,2
    2bb0:	38f51663          	bne	a0,a5,2f3c <subdir+0x55e>
  close(fd);
    2bb4:	8526                	mv	a0,s1
    2bb6:	00002097          	auipc	ra,0x2
    2bba:	896080e7          	jalr	-1898(ra) # 444c <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2bbe:	4581                	li	a1,0
    2bc0:	00003517          	auipc	a0,0x3
    2bc4:	07050513          	addi	a0,a0,112 # 5c30 <malloc+0x13c6>
    2bc8:	00002097          	auipc	ra,0x2
    2bcc:	89c080e7          	jalr	-1892(ra) # 4464 <open>
    2bd0:	38055463          	bgez	a0,2f58 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2bd4:	20200593          	li	a1,514
    2bd8:	00003517          	auipc	a0,0x3
    2bdc:	26850513          	addi	a0,a0,616 # 5e40 <malloc+0x15d6>
    2be0:	00002097          	auipc	ra,0x2
    2be4:	884080e7          	jalr	-1916(ra) # 4464 <open>
    2be8:	38055663          	bgez	a0,2f74 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2bec:	20200593          	li	a1,514
    2bf0:	00003517          	auipc	a0,0x3
    2bf4:	28050513          	addi	a0,a0,640 # 5e70 <malloc+0x1606>
    2bf8:	00002097          	auipc	ra,0x2
    2bfc:	86c080e7          	jalr	-1940(ra) # 4464 <open>
    2c00:	38055863          	bgez	a0,2f90 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    2c04:	20000593          	li	a1,512
    2c08:	00003517          	auipc	a0,0x3
    2c0c:	f8850513          	addi	a0,a0,-120 # 5b90 <malloc+0x1326>
    2c10:	00002097          	auipc	ra,0x2
    2c14:	854080e7          	jalr	-1964(ra) # 4464 <open>
    2c18:	38055a63          	bgez	a0,2fac <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    2c1c:	4589                	li	a1,2
    2c1e:	00003517          	auipc	a0,0x3
    2c22:	f7250513          	addi	a0,a0,-142 # 5b90 <malloc+0x1326>
    2c26:	00002097          	auipc	ra,0x2
    2c2a:	83e080e7          	jalr	-1986(ra) # 4464 <open>
    2c2e:	38055d63          	bgez	a0,2fc8 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    2c32:	4585                	li	a1,1
    2c34:	00003517          	auipc	a0,0x3
    2c38:	f5c50513          	addi	a0,a0,-164 # 5b90 <malloc+0x1326>
    2c3c:	00002097          	auipc	ra,0x2
    2c40:	828080e7          	jalr	-2008(ra) # 4464 <open>
    2c44:	3a055063          	bgez	a0,2fe4 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2c48:	00003597          	auipc	a1,0x3
    2c4c:	2b858593          	addi	a1,a1,696 # 5f00 <malloc+0x1696>
    2c50:	00003517          	auipc	a0,0x3
    2c54:	1f050513          	addi	a0,a0,496 # 5e40 <malloc+0x15d6>
    2c58:	00002097          	auipc	ra,0x2
    2c5c:	82c080e7          	jalr	-2004(ra) # 4484 <link>
    2c60:	3a050063          	beqz	a0,3000 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2c64:	00003597          	auipc	a1,0x3
    2c68:	29c58593          	addi	a1,a1,668 # 5f00 <malloc+0x1696>
    2c6c:	00003517          	auipc	a0,0x3
    2c70:	20450513          	addi	a0,a0,516 # 5e70 <malloc+0x1606>
    2c74:	00002097          	auipc	ra,0x2
    2c78:	810080e7          	jalr	-2032(ra) # 4484 <link>
    2c7c:	3a050063          	beqz	a0,301c <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2c80:	00003597          	auipc	a1,0x3
    2c84:	03858593          	addi	a1,a1,56 # 5cb8 <malloc+0x144e>
    2c88:	00003517          	auipc	a0,0x3
    2c8c:	f2850513          	addi	a0,a0,-216 # 5bb0 <malloc+0x1346>
    2c90:	00001097          	auipc	ra,0x1
    2c94:	7f4080e7          	jalr	2036(ra) # 4484 <link>
    2c98:	3a050063          	beqz	a0,3038 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    2c9c:	00003517          	auipc	a0,0x3
    2ca0:	1a450513          	addi	a0,a0,420 # 5e40 <malloc+0x15d6>
    2ca4:	00001097          	auipc	ra,0x1
    2ca8:	7e8080e7          	jalr	2024(ra) # 448c <mkdir>
    2cac:	3a050463          	beqz	a0,3054 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    2cb0:	00003517          	auipc	a0,0x3
    2cb4:	1c050513          	addi	a0,a0,448 # 5e70 <malloc+0x1606>
    2cb8:	00001097          	auipc	ra,0x1
    2cbc:	7d4080e7          	jalr	2004(ra) # 448c <mkdir>
    2cc0:	3a050863          	beqz	a0,3070 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    2cc4:	00003517          	auipc	a0,0x3
    2cc8:	ff450513          	addi	a0,a0,-12 # 5cb8 <malloc+0x144e>
    2ccc:	00001097          	auipc	ra,0x1
    2cd0:	7c0080e7          	jalr	1984(ra) # 448c <mkdir>
    2cd4:	3a050c63          	beqz	a0,308c <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    2cd8:	00003517          	auipc	a0,0x3
    2cdc:	19850513          	addi	a0,a0,408 # 5e70 <malloc+0x1606>
    2ce0:	00001097          	auipc	ra,0x1
    2ce4:	794080e7          	jalr	1940(ra) # 4474 <unlink>
    2ce8:	3c050063          	beqz	a0,30a8 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    2cec:	00003517          	auipc	a0,0x3
    2cf0:	15450513          	addi	a0,a0,340 # 5e40 <malloc+0x15d6>
    2cf4:	00001097          	auipc	ra,0x1
    2cf8:	780080e7          	jalr	1920(ra) # 4474 <unlink>
    2cfc:	3c050463          	beqz	a0,30c4 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    2d00:	00003517          	auipc	a0,0x3
    2d04:	eb050513          	addi	a0,a0,-336 # 5bb0 <malloc+0x1346>
    2d08:	00001097          	auipc	ra,0x1
    2d0c:	78c080e7          	jalr	1932(ra) # 4494 <chdir>
    2d10:	3c050863          	beqz	a0,30e0 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    2d14:	00003517          	auipc	a0,0x3
    2d18:	33c50513          	addi	a0,a0,828 # 6050 <malloc+0x17e6>
    2d1c:	00001097          	auipc	ra,0x1
    2d20:	778080e7          	jalr	1912(ra) # 4494 <chdir>
    2d24:	3c050c63          	beqz	a0,30fc <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    2d28:	00003517          	auipc	a0,0x3
    2d2c:	f9050513          	addi	a0,a0,-112 # 5cb8 <malloc+0x144e>
    2d30:	00001097          	auipc	ra,0x1
    2d34:	744080e7          	jalr	1860(ra) # 4474 <unlink>
    2d38:	3e051063          	bnez	a0,3118 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    2d3c:	00003517          	auipc	a0,0x3
    2d40:	e7450513          	addi	a0,a0,-396 # 5bb0 <malloc+0x1346>
    2d44:	00001097          	auipc	ra,0x1
    2d48:	730080e7          	jalr	1840(ra) # 4474 <unlink>
    2d4c:	3e051463          	bnez	a0,3134 <subdir+0x756>
  if(unlink("dd") == 0){
    2d50:	00003517          	auipc	a0,0x3
    2d54:	e4050513          	addi	a0,a0,-448 # 5b90 <malloc+0x1326>
    2d58:	00001097          	auipc	ra,0x1
    2d5c:	71c080e7          	jalr	1820(ra) # 4474 <unlink>
    2d60:	3e050863          	beqz	a0,3150 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    2d64:	00003517          	auipc	a0,0x3
    2d68:	35c50513          	addi	a0,a0,860 # 60c0 <malloc+0x1856>
    2d6c:	00001097          	auipc	ra,0x1
    2d70:	708080e7          	jalr	1800(ra) # 4474 <unlink>
    2d74:	3e054c63          	bltz	a0,316c <subdir+0x78e>
  if(unlink("dd") < 0){
    2d78:	00003517          	auipc	a0,0x3
    2d7c:	e1850513          	addi	a0,a0,-488 # 5b90 <malloc+0x1326>
    2d80:	00001097          	auipc	ra,0x1
    2d84:	6f4080e7          	jalr	1780(ra) # 4474 <unlink>
    2d88:	40054063          	bltz	a0,3188 <subdir+0x7aa>
}
    2d8c:	60e2                	ld	ra,24(sp)
    2d8e:	6442                	ld	s0,16(sp)
    2d90:	64a2                	ld	s1,8(sp)
    2d92:	6902                	ld	s2,0(sp)
    2d94:	6105                	addi	sp,sp,32
    2d96:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    2d98:	85ca                	mv	a1,s2
    2d9a:	00003517          	auipc	a0,0x3
    2d9e:	dfe50513          	addi	a0,a0,-514 # 5b98 <malloc+0x132e>
    2da2:	00002097          	auipc	ra,0x2
    2da6:	a0a080e7          	jalr	-1526(ra) # 47ac <printf>
    exit(1);
    2daa:	4505                	li	a0,1
    2dac:	00001097          	auipc	ra,0x1
    2db0:	678080e7          	jalr	1656(ra) # 4424 <exit>
    printf("%s: create dd/ff failed\n", s);
    2db4:	85ca                	mv	a1,s2
    2db6:	00003517          	auipc	a0,0x3
    2dba:	e0250513          	addi	a0,a0,-510 # 5bb8 <malloc+0x134e>
    2dbe:	00002097          	auipc	ra,0x2
    2dc2:	9ee080e7          	jalr	-1554(ra) # 47ac <printf>
    exit(1);
    2dc6:	4505                	li	a0,1
    2dc8:	00001097          	auipc	ra,0x1
    2dcc:	65c080e7          	jalr	1628(ra) # 4424 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    2dd0:	85ca                	mv	a1,s2
    2dd2:	00003517          	auipc	a0,0x3
    2dd6:	e0650513          	addi	a0,a0,-506 # 5bd8 <malloc+0x136e>
    2dda:	00002097          	auipc	ra,0x2
    2dde:	9d2080e7          	jalr	-1582(ra) # 47ac <printf>
    exit(1);
    2de2:	4505                	li	a0,1
    2de4:	00001097          	auipc	ra,0x1
    2de8:	640080e7          	jalr	1600(ra) # 4424 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    2dec:	85ca                	mv	a1,s2
    2dee:	00003517          	auipc	a0,0x3
    2df2:	e2250513          	addi	a0,a0,-478 # 5c10 <malloc+0x13a6>
    2df6:	00002097          	auipc	ra,0x2
    2dfa:	9b6080e7          	jalr	-1610(ra) # 47ac <printf>
    exit(1);
    2dfe:	4505                	li	a0,1
    2e00:	00001097          	auipc	ra,0x1
    2e04:	624080e7          	jalr	1572(ra) # 4424 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    2e08:	85ca                	mv	a1,s2
    2e0a:	00003517          	auipc	a0,0x3
    2e0e:	e3650513          	addi	a0,a0,-458 # 5c40 <malloc+0x13d6>
    2e12:	00002097          	auipc	ra,0x2
    2e16:	99a080e7          	jalr	-1638(ra) # 47ac <printf>
    exit(1);
    2e1a:	4505                	li	a0,1
    2e1c:	00001097          	auipc	ra,0x1
    2e20:	608080e7          	jalr	1544(ra) # 4424 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    2e24:	85ca                	mv	a1,s2
    2e26:	00003517          	auipc	a0,0x3
    2e2a:	e5250513          	addi	a0,a0,-430 # 5c78 <malloc+0x140e>
    2e2e:	00002097          	auipc	ra,0x2
    2e32:	97e080e7          	jalr	-1666(ra) # 47ac <printf>
    exit(1);
    2e36:	4505                	li	a0,1
    2e38:	00001097          	auipc	ra,0x1
    2e3c:	5ec080e7          	jalr	1516(ra) # 4424 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    2e40:	85ca                	mv	a1,s2
    2e42:	00003517          	auipc	a0,0x3
    2e46:	e5650513          	addi	a0,a0,-426 # 5c98 <malloc+0x142e>
    2e4a:	00002097          	auipc	ra,0x2
    2e4e:	962080e7          	jalr	-1694(ra) # 47ac <printf>
    exit(1);
    2e52:	4505                	li	a0,1
    2e54:	00001097          	auipc	ra,0x1
    2e58:	5d0080e7          	jalr	1488(ra) # 4424 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    2e5c:	85ca                	mv	a1,s2
    2e5e:	00003517          	auipc	a0,0x3
    2e62:	e6a50513          	addi	a0,a0,-406 # 5cc8 <malloc+0x145e>
    2e66:	00002097          	auipc	ra,0x2
    2e6a:	946080e7          	jalr	-1722(ra) # 47ac <printf>
    exit(1);
    2e6e:	4505                	li	a0,1
    2e70:	00001097          	auipc	ra,0x1
    2e74:	5b4080e7          	jalr	1460(ra) # 4424 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2e78:	85ca                	mv	a1,s2
    2e7a:	00003517          	auipc	a0,0x3
    2e7e:	e7650513          	addi	a0,a0,-394 # 5cf0 <malloc+0x1486>
    2e82:	00002097          	auipc	ra,0x2
    2e86:	92a080e7          	jalr	-1750(ra) # 47ac <printf>
    exit(1);
    2e8a:	4505                	li	a0,1
    2e8c:	00001097          	auipc	ra,0x1
    2e90:	598080e7          	jalr	1432(ra) # 4424 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    2e94:	85ca                	mv	a1,s2
    2e96:	00003517          	auipc	a0,0x3
    2e9a:	e7a50513          	addi	a0,a0,-390 # 5d10 <malloc+0x14a6>
    2e9e:	00002097          	auipc	ra,0x2
    2ea2:	90e080e7          	jalr	-1778(ra) # 47ac <printf>
    exit(1);
    2ea6:	4505                	li	a0,1
    2ea8:	00001097          	auipc	ra,0x1
    2eac:	57c080e7          	jalr	1404(ra) # 4424 <exit>
    printf("%s: chdir dd failed\n", s);
    2eb0:	85ca                	mv	a1,s2
    2eb2:	00003517          	auipc	a0,0x3
    2eb6:	e8650513          	addi	a0,a0,-378 # 5d38 <malloc+0x14ce>
    2eba:	00002097          	auipc	ra,0x2
    2ebe:	8f2080e7          	jalr	-1806(ra) # 47ac <printf>
    exit(1);
    2ec2:	4505                	li	a0,1
    2ec4:	00001097          	auipc	ra,0x1
    2ec8:	560080e7          	jalr	1376(ra) # 4424 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    2ecc:	85ca                	mv	a1,s2
    2ece:	00003517          	auipc	a0,0x3
    2ed2:	e9250513          	addi	a0,a0,-366 # 5d60 <malloc+0x14f6>
    2ed6:	00002097          	auipc	ra,0x2
    2eda:	8d6080e7          	jalr	-1834(ra) # 47ac <printf>
    exit(1);
    2ede:	4505                	li	a0,1
    2ee0:	00001097          	auipc	ra,0x1
    2ee4:	544080e7          	jalr	1348(ra) # 4424 <exit>
    printf("chdir dd/../../dd failed\n", s);
    2ee8:	85ca                	mv	a1,s2
    2eea:	00003517          	auipc	a0,0x3
    2eee:	ea650513          	addi	a0,a0,-346 # 5d90 <malloc+0x1526>
    2ef2:	00002097          	auipc	ra,0x2
    2ef6:	8ba080e7          	jalr	-1862(ra) # 47ac <printf>
    exit(1);
    2efa:	4505                	li	a0,1
    2efc:	00001097          	auipc	ra,0x1
    2f00:	528080e7          	jalr	1320(ra) # 4424 <exit>
    printf("%s: chdir ./.. failed\n", s);
    2f04:	85ca                	mv	a1,s2
    2f06:	00003517          	auipc	a0,0x3
    2f0a:	eb250513          	addi	a0,a0,-334 # 5db8 <malloc+0x154e>
    2f0e:	00002097          	auipc	ra,0x2
    2f12:	89e080e7          	jalr	-1890(ra) # 47ac <printf>
    exit(1);
    2f16:	4505                	li	a0,1
    2f18:	00001097          	auipc	ra,0x1
    2f1c:	50c080e7          	jalr	1292(ra) # 4424 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    2f20:	85ca                	mv	a1,s2
    2f22:	00003517          	auipc	a0,0x3
    2f26:	eae50513          	addi	a0,a0,-338 # 5dd0 <malloc+0x1566>
    2f2a:	00002097          	auipc	ra,0x2
    2f2e:	882080e7          	jalr	-1918(ra) # 47ac <printf>
    exit(1);
    2f32:	4505                	li	a0,1
    2f34:	00001097          	auipc	ra,0x1
    2f38:	4f0080e7          	jalr	1264(ra) # 4424 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    2f3c:	85ca                	mv	a1,s2
    2f3e:	00003517          	auipc	a0,0x3
    2f42:	eb250513          	addi	a0,a0,-334 # 5df0 <malloc+0x1586>
    2f46:	00002097          	auipc	ra,0x2
    2f4a:	866080e7          	jalr	-1946(ra) # 47ac <printf>
    exit(1);
    2f4e:	4505                	li	a0,1
    2f50:	00001097          	auipc	ra,0x1
    2f54:	4d4080e7          	jalr	1236(ra) # 4424 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    2f58:	85ca                	mv	a1,s2
    2f5a:	00003517          	auipc	a0,0x3
    2f5e:	eb650513          	addi	a0,a0,-330 # 5e10 <malloc+0x15a6>
    2f62:	00002097          	auipc	ra,0x2
    2f66:	84a080e7          	jalr	-1974(ra) # 47ac <printf>
    exit(1);
    2f6a:	4505                	li	a0,1
    2f6c:	00001097          	auipc	ra,0x1
    2f70:	4b8080e7          	jalr	1208(ra) # 4424 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    2f74:	85ca                	mv	a1,s2
    2f76:	00003517          	auipc	a0,0x3
    2f7a:	eda50513          	addi	a0,a0,-294 # 5e50 <malloc+0x15e6>
    2f7e:	00002097          	auipc	ra,0x2
    2f82:	82e080e7          	jalr	-2002(ra) # 47ac <printf>
    exit(1);
    2f86:	4505                	li	a0,1
    2f88:	00001097          	auipc	ra,0x1
    2f8c:	49c080e7          	jalr	1180(ra) # 4424 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    2f90:	85ca                	mv	a1,s2
    2f92:	00003517          	auipc	a0,0x3
    2f96:	eee50513          	addi	a0,a0,-274 # 5e80 <malloc+0x1616>
    2f9a:	00002097          	auipc	ra,0x2
    2f9e:	812080e7          	jalr	-2030(ra) # 47ac <printf>
    exit(1);
    2fa2:	4505                	li	a0,1
    2fa4:	00001097          	auipc	ra,0x1
    2fa8:	480080e7          	jalr	1152(ra) # 4424 <exit>
    printf("%s: create dd succeeded!\n", s);
    2fac:	85ca                	mv	a1,s2
    2fae:	00003517          	auipc	a0,0x3
    2fb2:	ef250513          	addi	a0,a0,-270 # 5ea0 <malloc+0x1636>
    2fb6:	00001097          	auipc	ra,0x1
    2fba:	7f6080e7          	jalr	2038(ra) # 47ac <printf>
    exit(1);
    2fbe:	4505                	li	a0,1
    2fc0:	00001097          	auipc	ra,0x1
    2fc4:	464080e7          	jalr	1124(ra) # 4424 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    2fc8:	85ca                	mv	a1,s2
    2fca:	00003517          	auipc	a0,0x3
    2fce:	ef650513          	addi	a0,a0,-266 # 5ec0 <malloc+0x1656>
    2fd2:	00001097          	auipc	ra,0x1
    2fd6:	7da080e7          	jalr	2010(ra) # 47ac <printf>
    exit(1);
    2fda:	4505                	li	a0,1
    2fdc:	00001097          	auipc	ra,0x1
    2fe0:	448080e7          	jalr	1096(ra) # 4424 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    2fe4:	85ca                	mv	a1,s2
    2fe6:	00003517          	auipc	a0,0x3
    2fea:	efa50513          	addi	a0,a0,-262 # 5ee0 <malloc+0x1676>
    2fee:	00001097          	auipc	ra,0x1
    2ff2:	7be080e7          	jalr	1982(ra) # 47ac <printf>
    exit(1);
    2ff6:	4505                	li	a0,1
    2ff8:	00001097          	auipc	ra,0x1
    2ffc:	42c080e7          	jalr	1068(ra) # 4424 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3000:	85ca                	mv	a1,s2
    3002:	00003517          	auipc	a0,0x3
    3006:	f0e50513          	addi	a0,a0,-242 # 5f10 <malloc+0x16a6>
    300a:	00001097          	auipc	ra,0x1
    300e:	7a2080e7          	jalr	1954(ra) # 47ac <printf>
    exit(1);
    3012:	4505                	li	a0,1
    3014:	00001097          	auipc	ra,0x1
    3018:	410080e7          	jalr	1040(ra) # 4424 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    301c:	85ca                	mv	a1,s2
    301e:	00003517          	auipc	a0,0x3
    3022:	f1a50513          	addi	a0,a0,-230 # 5f38 <malloc+0x16ce>
    3026:	00001097          	auipc	ra,0x1
    302a:	786080e7          	jalr	1926(ra) # 47ac <printf>
    exit(1);
    302e:	4505                	li	a0,1
    3030:	00001097          	auipc	ra,0x1
    3034:	3f4080e7          	jalr	1012(ra) # 4424 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3038:	85ca                	mv	a1,s2
    303a:	00003517          	auipc	a0,0x3
    303e:	f2650513          	addi	a0,a0,-218 # 5f60 <malloc+0x16f6>
    3042:	00001097          	auipc	ra,0x1
    3046:	76a080e7          	jalr	1898(ra) # 47ac <printf>
    exit(1);
    304a:	4505                	li	a0,1
    304c:	00001097          	auipc	ra,0x1
    3050:	3d8080e7          	jalr	984(ra) # 4424 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3054:	85ca                	mv	a1,s2
    3056:	00003517          	auipc	a0,0x3
    305a:	f3250513          	addi	a0,a0,-206 # 5f88 <malloc+0x171e>
    305e:	00001097          	auipc	ra,0x1
    3062:	74e080e7          	jalr	1870(ra) # 47ac <printf>
    exit(1);
    3066:	4505                	li	a0,1
    3068:	00001097          	auipc	ra,0x1
    306c:	3bc080e7          	jalr	956(ra) # 4424 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3070:	85ca                	mv	a1,s2
    3072:	00003517          	auipc	a0,0x3
    3076:	f3650513          	addi	a0,a0,-202 # 5fa8 <malloc+0x173e>
    307a:	00001097          	auipc	ra,0x1
    307e:	732080e7          	jalr	1842(ra) # 47ac <printf>
    exit(1);
    3082:	4505                	li	a0,1
    3084:	00001097          	auipc	ra,0x1
    3088:	3a0080e7          	jalr	928(ra) # 4424 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    308c:	85ca                	mv	a1,s2
    308e:	00003517          	auipc	a0,0x3
    3092:	f3a50513          	addi	a0,a0,-198 # 5fc8 <malloc+0x175e>
    3096:	00001097          	auipc	ra,0x1
    309a:	716080e7          	jalr	1814(ra) # 47ac <printf>
    exit(1);
    309e:	4505                	li	a0,1
    30a0:	00001097          	auipc	ra,0x1
    30a4:	384080e7          	jalr	900(ra) # 4424 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    30a8:	85ca                	mv	a1,s2
    30aa:	00003517          	auipc	a0,0x3
    30ae:	f4650513          	addi	a0,a0,-186 # 5ff0 <malloc+0x1786>
    30b2:	00001097          	auipc	ra,0x1
    30b6:	6fa080e7          	jalr	1786(ra) # 47ac <printf>
    exit(1);
    30ba:	4505                	li	a0,1
    30bc:	00001097          	auipc	ra,0x1
    30c0:	368080e7          	jalr	872(ra) # 4424 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    30c4:	85ca                	mv	a1,s2
    30c6:	00003517          	auipc	a0,0x3
    30ca:	f4a50513          	addi	a0,a0,-182 # 6010 <malloc+0x17a6>
    30ce:	00001097          	auipc	ra,0x1
    30d2:	6de080e7          	jalr	1758(ra) # 47ac <printf>
    exit(1);
    30d6:	4505                	li	a0,1
    30d8:	00001097          	auipc	ra,0x1
    30dc:	34c080e7          	jalr	844(ra) # 4424 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    30e0:	85ca                	mv	a1,s2
    30e2:	00003517          	auipc	a0,0x3
    30e6:	f4e50513          	addi	a0,a0,-178 # 6030 <malloc+0x17c6>
    30ea:	00001097          	auipc	ra,0x1
    30ee:	6c2080e7          	jalr	1730(ra) # 47ac <printf>
    exit(1);
    30f2:	4505                	li	a0,1
    30f4:	00001097          	auipc	ra,0x1
    30f8:	330080e7          	jalr	816(ra) # 4424 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    30fc:	85ca                	mv	a1,s2
    30fe:	00003517          	auipc	a0,0x3
    3102:	f5a50513          	addi	a0,a0,-166 # 6058 <malloc+0x17ee>
    3106:	00001097          	auipc	ra,0x1
    310a:	6a6080e7          	jalr	1702(ra) # 47ac <printf>
    exit(1);
    310e:	4505                	li	a0,1
    3110:	00001097          	auipc	ra,0x1
    3114:	314080e7          	jalr	788(ra) # 4424 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3118:	85ca                	mv	a1,s2
    311a:	00003517          	auipc	a0,0x3
    311e:	bd650513          	addi	a0,a0,-1066 # 5cf0 <malloc+0x1486>
    3122:	00001097          	auipc	ra,0x1
    3126:	68a080e7          	jalr	1674(ra) # 47ac <printf>
    exit(1);
    312a:	4505                	li	a0,1
    312c:	00001097          	auipc	ra,0x1
    3130:	2f8080e7          	jalr	760(ra) # 4424 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3134:	85ca                	mv	a1,s2
    3136:	00003517          	auipc	a0,0x3
    313a:	f4250513          	addi	a0,a0,-190 # 6078 <malloc+0x180e>
    313e:	00001097          	auipc	ra,0x1
    3142:	66e080e7          	jalr	1646(ra) # 47ac <printf>
    exit(1);
    3146:	4505                	li	a0,1
    3148:	00001097          	auipc	ra,0x1
    314c:	2dc080e7          	jalr	732(ra) # 4424 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3150:	85ca                	mv	a1,s2
    3152:	00003517          	auipc	a0,0x3
    3156:	f4650513          	addi	a0,a0,-186 # 6098 <malloc+0x182e>
    315a:	00001097          	auipc	ra,0x1
    315e:	652080e7          	jalr	1618(ra) # 47ac <printf>
    exit(1);
    3162:	4505                	li	a0,1
    3164:	00001097          	auipc	ra,0x1
    3168:	2c0080e7          	jalr	704(ra) # 4424 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    316c:	85ca                	mv	a1,s2
    316e:	00003517          	auipc	a0,0x3
    3172:	f5a50513          	addi	a0,a0,-166 # 60c8 <malloc+0x185e>
    3176:	00001097          	auipc	ra,0x1
    317a:	636080e7          	jalr	1590(ra) # 47ac <printf>
    exit(1);
    317e:	4505                	li	a0,1
    3180:	00001097          	auipc	ra,0x1
    3184:	2a4080e7          	jalr	676(ra) # 4424 <exit>
    printf("%s: unlink dd failed\n", s);
    3188:	85ca                	mv	a1,s2
    318a:	00003517          	auipc	a0,0x3
    318e:	f5e50513          	addi	a0,a0,-162 # 60e8 <malloc+0x187e>
    3192:	00001097          	auipc	ra,0x1
    3196:	61a080e7          	jalr	1562(ra) # 47ac <printf>
    exit(1);
    319a:	4505                	li	a0,1
    319c:	00001097          	auipc	ra,0x1
    31a0:	288080e7          	jalr	648(ra) # 4424 <exit>

00000000000031a4 <dirfile>:
{
    31a4:	1101                	addi	sp,sp,-32
    31a6:	ec06                	sd	ra,24(sp)
    31a8:	e822                	sd	s0,16(sp)
    31aa:	e426                	sd	s1,8(sp)
    31ac:	e04a                	sd	s2,0(sp)
    31ae:	1000                	addi	s0,sp,32
    31b0:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    31b2:	20000593          	li	a1,512
    31b6:	00002517          	auipc	a0,0x2
    31ba:	9fa50513          	addi	a0,a0,-1542 # 4bb0 <malloc+0x346>
    31be:	00001097          	auipc	ra,0x1
    31c2:	2a6080e7          	jalr	678(ra) # 4464 <open>
  if(fd < 0){
    31c6:	0e054d63          	bltz	a0,32c0 <dirfile+0x11c>
  close(fd);
    31ca:	00001097          	auipc	ra,0x1
    31ce:	282080e7          	jalr	642(ra) # 444c <close>
  if(chdir("dirfile") == 0){
    31d2:	00002517          	auipc	a0,0x2
    31d6:	9de50513          	addi	a0,a0,-1570 # 4bb0 <malloc+0x346>
    31da:	00001097          	auipc	ra,0x1
    31de:	2ba080e7          	jalr	698(ra) # 4494 <chdir>
    31e2:	cd6d                	beqz	a0,32dc <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    31e4:	4581                	li	a1,0
    31e6:	00003517          	auipc	a0,0x3
    31ea:	f5a50513          	addi	a0,a0,-166 # 6140 <malloc+0x18d6>
    31ee:	00001097          	auipc	ra,0x1
    31f2:	276080e7          	jalr	630(ra) # 4464 <open>
  if(fd >= 0){
    31f6:	10055163          	bgez	a0,32f8 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    31fa:	20000593          	li	a1,512
    31fe:	00003517          	auipc	a0,0x3
    3202:	f4250513          	addi	a0,a0,-190 # 6140 <malloc+0x18d6>
    3206:	00001097          	auipc	ra,0x1
    320a:	25e080e7          	jalr	606(ra) # 4464 <open>
  if(fd >= 0){
    320e:	10055363          	bgez	a0,3314 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3212:	00003517          	auipc	a0,0x3
    3216:	f2e50513          	addi	a0,a0,-210 # 6140 <malloc+0x18d6>
    321a:	00001097          	auipc	ra,0x1
    321e:	272080e7          	jalr	626(ra) # 448c <mkdir>
    3222:	10050763          	beqz	a0,3330 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3226:	00003517          	auipc	a0,0x3
    322a:	f1a50513          	addi	a0,a0,-230 # 6140 <malloc+0x18d6>
    322e:	00001097          	auipc	ra,0x1
    3232:	246080e7          	jalr	582(ra) # 4474 <unlink>
    3236:	10050b63          	beqz	a0,334c <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    323a:	00003597          	auipc	a1,0x3
    323e:	f0658593          	addi	a1,a1,-250 # 6140 <malloc+0x18d6>
    3242:	00003517          	auipc	a0,0x3
    3246:	f8650513          	addi	a0,a0,-122 # 61c8 <malloc+0x195e>
    324a:	00001097          	auipc	ra,0x1
    324e:	23a080e7          	jalr	570(ra) # 4484 <link>
    3252:	10050b63          	beqz	a0,3368 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3256:	00002517          	auipc	a0,0x2
    325a:	95a50513          	addi	a0,a0,-1702 # 4bb0 <malloc+0x346>
    325e:	00001097          	auipc	ra,0x1
    3262:	216080e7          	jalr	534(ra) # 4474 <unlink>
    3266:	10051f63          	bnez	a0,3384 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    326a:	4589                	li	a1,2
    326c:	00002517          	auipc	a0,0x2
    3270:	a4c50513          	addi	a0,a0,-1460 # 4cb8 <malloc+0x44e>
    3274:	00001097          	auipc	ra,0x1
    3278:	1f0080e7          	jalr	496(ra) # 4464 <open>
  if(fd >= 0){
    327c:	12055263          	bgez	a0,33a0 <dirfile+0x1fc>
  fd = open(".", 0);
    3280:	4581                	li	a1,0
    3282:	00002517          	auipc	a0,0x2
    3286:	a3650513          	addi	a0,a0,-1482 # 4cb8 <malloc+0x44e>
    328a:	00001097          	auipc	ra,0x1
    328e:	1da080e7          	jalr	474(ra) # 4464 <open>
    3292:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3294:	4605                	li	a2,1
    3296:	00002597          	auipc	a1,0x2
    329a:	48258593          	addi	a1,a1,1154 # 5718 <malloc+0xeae>
    329e:	00001097          	auipc	ra,0x1
    32a2:	1a6080e7          	jalr	422(ra) # 4444 <write>
    32a6:	10a04b63          	bgtz	a0,33bc <dirfile+0x218>
  close(fd);
    32aa:	8526                	mv	a0,s1
    32ac:	00001097          	auipc	ra,0x1
    32b0:	1a0080e7          	jalr	416(ra) # 444c <close>
}
    32b4:	60e2                	ld	ra,24(sp)
    32b6:	6442                	ld	s0,16(sp)
    32b8:	64a2                	ld	s1,8(sp)
    32ba:	6902                	ld	s2,0(sp)
    32bc:	6105                	addi	sp,sp,32
    32be:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    32c0:	85ca                	mv	a1,s2
    32c2:	00003517          	auipc	a0,0x3
    32c6:	e3e50513          	addi	a0,a0,-450 # 6100 <malloc+0x1896>
    32ca:	00001097          	auipc	ra,0x1
    32ce:	4e2080e7          	jalr	1250(ra) # 47ac <printf>
    exit(1);
    32d2:	4505                	li	a0,1
    32d4:	00001097          	auipc	ra,0x1
    32d8:	150080e7          	jalr	336(ra) # 4424 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    32dc:	85ca                	mv	a1,s2
    32de:	00003517          	auipc	a0,0x3
    32e2:	e4250513          	addi	a0,a0,-446 # 6120 <malloc+0x18b6>
    32e6:	00001097          	auipc	ra,0x1
    32ea:	4c6080e7          	jalr	1222(ra) # 47ac <printf>
    exit(1);
    32ee:	4505                	li	a0,1
    32f0:	00001097          	auipc	ra,0x1
    32f4:	134080e7          	jalr	308(ra) # 4424 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    32f8:	85ca                	mv	a1,s2
    32fa:	00003517          	auipc	a0,0x3
    32fe:	e5650513          	addi	a0,a0,-426 # 6150 <malloc+0x18e6>
    3302:	00001097          	auipc	ra,0x1
    3306:	4aa080e7          	jalr	1194(ra) # 47ac <printf>
    exit(1);
    330a:	4505                	li	a0,1
    330c:	00001097          	auipc	ra,0x1
    3310:	118080e7          	jalr	280(ra) # 4424 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3314:	85ca                	mv	a1,s2
    3316:	00003517          	auipc	a0,0x3
    331a:	e3a50513          	addi	a0,a0,-454 # 6150 <malloc+0x18e6>
    331e:	00001097          	auipc	ra,0x1
    3322:	48e080e7          	jalr	1166(ra) # 47ac <printf>
    exit(1);
    3326:	4505                	li	a0,1
    3328:	00001097          	auipc	ra,0x1
    332c:	0fc080e7          	jalr	252(ra) # 4424 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3330:	85ca                	mv	a1,s2
    3332:	00003517          	auipc	a0,0x3
    3336:	e4650513          	addi	a0,a0,-442 # 6178 <malloc+0x190e>
    333a:	00001097          	auipc	ra,0x1
    333e:	472080e7          	jalr	1138(ra) # 47ac <printf>
    exit(1);
    3342:	4505                	li	a0,1
    3344:	00001097          	auipc	ra,0x1
    3348:	0e0080e7          	jalr	224(ra) # 4424 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    334c:	85ca                	mv	a1,s2
    334e:	00003517          	auipc	a0,0x3
    3352:	e5250513          	addi	a0,a0,-430 # 61a0 <malloc+0x1936>
    3356:	00001097          	auipc	ra,0x1
    335a:	456080e7          	jalr	1110(ra) # 47ac <printf>
    exit(1);
    335e:	4505                	li	a0,1
    3360:	00001097          	auipc	ra,0x1
    3364:	0c4080e7          	jalr	196(ra) # 4424 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3368:	85ca                	mv	a1,s2
    336a:	00003517          	auipc	a0,0x3
    336e:	e6650513          	addi	a0,a0,-410 # 61d0 <malloc+0x1966>
    3372:	00001097          	auipc	ra,0x1
    3376:	43a080e7          	jalr	1082(ra) # 47ac <printf>
    exit(1);
    337a:	4505                	li	a0,1
    337c:	00001097          	auipc	ra,0x1
    3380:	0a8080e7          	jalr	168(ra) # 4424 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3384:	85ca                	mv	a1,s2
    3386:	00003517          	auipc	a0,0x3
    338a:	e7250513          	addi	a0,a0,-398 # 61f8 <malloc+0x198e>
    338e:	00001097          	auipc	ra,0x1
    3392:	41e080e7          	jalr	1054(ra) # 47ac <printf>
    exit(1);
    3396:	4505                	li	a0,1
    3398:	00001097          	auipc	ra,0x1
    339c:	08c080e7          	jalr	140(ra) # 4424 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    33a0:	85ca                	mv	a1,s2
    33a2:	00003517          	auipc	a0,0x3
    33a6:	e7650513          	addi	a0,a0,-394 # 6218 <malloc+0x19ae>
    33aa:	00001097          	auipc	ra,0x1
    33ae:	402080e7          	jalr	1026(ra) # 47ac <printf>
    exit(1);
    33b2:	4505                	li	a0,1
    33b4:	00001097          	auipc	ra,0x1
    33b8:	070080e7          	jalr	112(ra) # 4424 <exit>
    printf("%s: write . succeeded!\n", s);
    33bc:	85ca                	mv	a1,s2
    33be:	00003517          	auipc	a0,0x3
    33c2:	e8250513          	addi	a0,a0,-382 # 6240 <malloc+0x19d6>
    33c6:	00001097          	auipc	ra,0x1
    33ca:	3e6080e7          	jalr	998(ra) # 47ac <printf>
    exit(1);
    33ce:	4505                	li	a0,1
    33d0:	00001097          	auipc	ra,0x1
    33d4:	054080e7          	jalr	84(ra) # 4424 <exit>

00000000000033d8 <iref>:
{
    33d8:	7139                	addi	sp,sp,-64
    33da:	fc06                	sd	ra,56(sp)
    33dc:	f822                	sd	s0,48(sp)
    33de:	f426                	sd	s1,40(sp)
    33e0:	f04a                	sd	s2,32(sp)
    33e2:	ec4e                	sd	s3,24(sp)
    33e4:	e852                	sd	s4,16(sp)
    33e6:	e456                	sd	s5,8(sp)
    33e8:	e05a                	sd	s6,0(sp)
    33ea:	0080                	addi	s0,sp,64
    33ec:	8b2a                	mv	s6,a0
    33ee:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    33f2:	00003a17          	auipc	s4,0x3
    33f6:	e66a0a13          	addi	s4,s4,-410 # 6258 <malloc+0x19ee>
    mkdir("");
    33fa:	00003497          	auipc	s1,0x3
    33fe:	a3e48493          	addi	s1,s1,-1474 # 5e38 <malloc+0x15ce>
    link("README", "");
    3402:	00003a97          	auipc	s5,0x3
    3406:	dc6a8a93          	addi	s5,s5,-570 # 61c8 <malloc+0x195e>
    fd = open("xx", O_CREATE);
    340a:	00003997          	auipc	s3,0x3
    340e:	d3e98993          	addi	s3,s3,-706 # 6148 <malloc+0x18de>
    3412:	a891                	j	3466 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3414:	85da                	mv	a1,s6
    3416:	00003517          	auipc	a0,0x3
    341a:	e4a50513          	addi	a0,a0,-438 # 6260 <malloc+0x19f6>
    341e:	00001097          	auipc	ra,0x1
    3422:	38e080e7          	jalr	910(ra) # 47ac <printf>
      exit(1);
    3426:	4505                	li	a0,1
    3428:	00001097          	auipc	ra,0x1
    342c:	ffc080e7          	jalr	-4(ra) # 4424 <exit>
      printf("%s: chdir irefd failed\n", s);
    3430:	85da                	mv	a1,s6
    3432:	00003517          	auipc	a0,0x3
    3436:	e4650513          	addi	a0,a0,-442 # 6278 <malloc+0x1a0e>
    343a:	00001097          	auipc	ra,0x1
    343e:	372080e7          	jalr	882(ra) # 47ac <printf>
      exit(1);
    3442:	4505                	li	a0,1
    3444:	00001097          	auipc	ra,0x1
    3448:	fe0080e7          	jalr	-32(ra) # 4424 <exit>
      close(fd);
    344c:	00001097          	auipc	ra,0x1
    3450:	000080e7          	jalr	ra # 444c <close>
    3454:	a889                	j	34a6 <iref+0xce>
    unlink("xx");
    3456:	854e                	mv	a0,s3
    3458:	00001097          	auipc	ra,0x1
    345c:	01c080e7          	jalr	28(ra) # 4474 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3460:	397d                	addiw	s2,s2,-1
    3462:	06090063          	beqz	s2,34c2 <iref+0xea>
    if(mkdir("irefd") != 0){
    3466:	8552                	mv	a0,s4
    3468:	00001097          	auipc	ra,0x1
    346c:	024080e7          	jalr	36(ra) # 448c <mkdir>
    3470:	f155                	bnez	a0,3414 <iref+0x3c>
    if(chdir("irefd") != 0){
    3472:	8552                	mv	a0,s4
    3474:	00001097          	auipc	ra,0x1
    3478:	020080e7          	jalr	32(ra) # 4494 <chdir>
    347c:	f955                	bnez	a0,3430 <iref+0x58>
    mkdir("");
    347e:	8526                	mv	a0,s1
    3480:	00001097          	auipc	ra,0x1
    3484:	00c080e7          	jalr	12(ra) # 448c <mkdir>
    link("README", "");
    3488:	85a6                	mv	a1,s1
    348a:	8556                	mv	a0,s5
    348c:	00001097          	auipc	ra,0x1
    3490:	ff8080e7          	jalr	-8(ra) # 4484 <link>
    fd = open("", O_CREATE);
    3494:	20000593          	li	a1,512
    3498:	8526                	mv	a0,s1
    349a:	00001097          	auipc	ra,0x1
    349e:	fca080e7          	jalr	-54(ra) # 4464 <open>
    if(fd >= 0)
    34a2:	fa0555e3          	bgez	a0,344c <iref+0x74>
    fd = open("xx", O_CREATE);
    34a6:	20000593          	li	a1,512
    34aa:	854e                	mv	a0,s3
    34ac:	00001097          	auipc	ra,0x1
    34b0:	fb8080e7          	jalr	-72(ra) # 4464 <open>
    if(fd >= 0)
    34b4:	fa0541e3          	bltz	a0,3456 <iref+0x7e>
      close(fd);
    34b8:	00001097          	auipc	ra,0x1
    34bc:	f94080e7          	jalr	-108(ra) # 444c <close>
    34c0:	bf59                	j	3456 <iref+0x7e>
  chdir("/");
    34c2:	00001517          	auipc	a0,0x1
    34c6:	79e50513          	addi	a0,a0,1950 # 4c60 <malloc+0x3f6>
    34ca:	00001097          	auipc	ra,0x1
    34ce:	fca080e7          	jalr	-54(ra) # 4494 <chdir>
}
    34d2:	70e2                	ld	ra,56(sp)
    34d4:	7442                	ld	s0,48(sp)
    34d6:	74a2                	ld	s1,40(sp)
    34d8:	7902                	ld	s2,32(sp)
    34da:	69e2                	ld	s3,24(sp)
    34dc:	6a42                	ld	s4,16(sp)
    34de:	6aa2                	ld	s5,8(sp)
    34e0:	6b02                	ld	s6,0(sp)
    34e2:	6121                	addi	sp,sp,64
    34e4:	8082                	ret

00000000000034e6 <validatetest>:
{
    34e6:	7139                	addi	sp,sp,-64
    34e8:	fc06                	sd	ra,56(sp)
    34ea:	f822                	sd	s0,48(sp)
    34ec:	f426                	sd	s1,40(sp)
    34ee:	f04a                	sd	s2,32(sp)
    34f0:	ec4e                	sd	s3,24(sp)
    34f2:	e852                	sd	s4,16(sp)
    34f4:	e456                	sd	s5,8(sp)
    34f6:	e05a                	sd	s6,0(sp)
    34f8:	0080                	addi	s0,sp,64
    34fa:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    34fc:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    34fe:	00003997          	auipc	s3,0x3
    3502:	d9298993          	addi	s3,s3,-622 # 6290 <malloc+0x1a26>
    3506:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    3508:	6a85                	lui	s5,0x1
    350a:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    350e:	85a6                	mv	a1,s1
    3510:	854e                	mv	a0,s3
    3512:	00001097          	auipc	ra,0x1
    3516:	f72080e7          	jalr	-142(ra) # 4484 <link>
    351a:	01251f63          	bne	a0,s2,3538 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    351e:	94d6                	add	s1,s1,s5
    3520:	ff4497e3          	bne	s1,s4,350e <validatetest+0x28>
}
    3524:	70e2                	ld	ra,56(sp)
    3526:	7442                	ld	s0,48(sp)
    3528:	74a2                	ld	s1,40(sp)
    352a:	7902                	ld	s2,32(sp)
    352c:	69e2                	ld	s3,24(sp)
    352e:	6a42                	ld	s4,16(sp)
    3530:	6aa2                	ld	s5,8(sp)
    3532:	6b02                	ld	s6,0(sp)
    3534:	6121                	addi	sp,sp,64
    3536:	8082                	ret
      printf("%s: link should not succeed\n", s);
    3538:	85da                	mv	a1,s6
    353a:	00003517          	auipc	a0,0x3
    353e:	d6650513          	addi	a0,a0,-666 # 62a0 <malloc+0x1a36>
    3542:	00001097          	auipc	ra,0x1
    3546:	26a080e7          	jalr	618(ra) # 47ac <printf>
      exit(1);
    354a:	4505                	li	a0,1
    354c:	00001097          	auipc	ra,0x1
    3550:	ed8080e7          	jalr	-296(ra) # 4424 <exit>

0000000000003554 <sbrkbasic>:
{
    3554:	7139                	addi	sp,sp,-64
    3556:	fc06                	sd	ra,56(sp)
    3558:	f822                	sd	s0,48(sp)
    355a:	f426                	sd	s1,40(sp)
    355c:	f04a                	sd	s2,32(sp)
    355e:	ec4e                	sd	s3,24(sp)
    3560:	e852                	sd	s4,16(sp)
    3562:	0080                	addi	s0,sp,64
    3564:	8a2a                	mv	s4,a0
  a = sbrk(TOOMUCH);
    3566:	40000537          	lui	a0,0x40000
    356a:	00001097          	auipc	ra,0x1
    356e:	f42080e7          	jalr	-190(ra) # 44ac <sbrk>
  if(a != (char*)0xffffffffffffffffL){
    3572:	57fd                	li	a5,-1
    3574:	02f50063          	beq	a0,a5,3594 <sbrkbasic+0x40>
    3578:	85aa                	mv	a1,a0
    printf("%s: sbrk(<toomuch>) returned %p\n", a);
    357a:	00003517          	auipc	a0,0x3
    357e:	d4650513          	addi	a0,a0,-698 # 62c0 <malloc+0x1a56>
    3582:	00001097          	auipc	ra,0x1
    3586:	22a080e7          	jalr	554(ra) # 47ac <printf>
    exit(1);
    358a:	4505                	li	a0,1
    358c:	00001097          	auipc	ra,0x1
    3590:	e98080e7          	jalr	-360(ra) # 4424 <exit>
  a = sbrk(0);
    3594:	4501                	li	a0,0
    3596:	00001097          	auipc	ra,0x1
    359a:	f16080e7          	jalr	-234(ra) # 44ac <sbrk>
    359e:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    35a0:	4901                	li	s2,0
    35a2:	6985                	lui	s3,0x1
    35a4:	38898993          	addi	s3,s3,904 # 1388 <unlinkread+0x10c>
    35a8:	a011                	j	35ac <sbrkbasic+0x58>
    a = b + 1;
    35aa:	84be                	mv	s1,a5
    b = sbrk(1);
    35ac:	4505                	li	a0,1
    35ae:	00001097          	auipc	ra,0x1
    35b2:	efe080e7          	jalr	-258(ra) # 44ac <sbrk>
    if(b != a){
    35b6:	04951c63          	bne	a0,s1,360e <sbrkbasic+0xba>
    *b = 1;
    35ba:	4785                	li	a5,1
    35bc:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    35c0:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    35c4:	2905                	addiw	s2,s2,1
    35c6:	ff3912e3          	bne	s2,s3,35aa <sbrkbasic+0x56>
  pid = fork();
    35ca:	00001097          	auipc	ra,0x1
    35ce:	e52080e7          	jalr	-430(ra) # 441c <fork>
    35d2:	892a                	mv	s2,a0
  if(pid < 0){
    35d4:	04054d63          	bltz	a0,362e <sbrkbasic+0xda>
  c = sbrk(1);
    35d8:	4505                	li	a0,1
    35da:	00001097          	auipc	ra,0x1
    35de:	ed2080e7          	jalr	-302(ra) # 44ac <sbrk>
  c = sbrk(1);
    35e2:	4505                	li	a0,1
    35e4:	00001097          	auipc	ra,0x1
    35e8:	ec8080e7          	jalr	-312(ra) # 44ac <sbrk>
  if(c != a + 1){
    35ec:	0489                	addi	s1,s1,2
    35ee:	04a48e63          	beq	s1,a0,364a <sbrkbasic+0xf6>
    printf("%s: sbrk test failed post-fork\n", s);
    35f2:	85d2                	mv	a1,s4
    35f4:	00003517          	auipc	a0,0x3
    35f8:	d3450513          	addi	a0,a0,-716 # 6328 <malloc+0x1abe>
    35fc:	00001097          	auipc	ra,0x1
    3600:	1b0080e7          	jalr	432(ra) # 47ac <printf>
    exit(1);
    3604:	4505                	li	a0,1
    3606:	00001097          	auipc	ra,0x1
    360a:	e1e080e7          	jalr	-482(ra) # 4424 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    360e:	86aa                	mv	a3,a0
    3610:	8626                	mv	a2,s1
    3612:	85ca                	mv	a1,s2
    3614:	00003517          	auipc	a0,0x3
    3618:	cd450513          	addi	a0,a0,-812 # 62e8 <malloc+0x1a7e>
    361c:	00001097          	auipc	ra,0x1
    3620:	190080e7          	jalr	400(ra) # 47ac <printf>
      exit(1);
    3624:	4505                	li	a0,1
    3626:	00001097          	auipc	ra,0x1
    362a:	dfe080e7          	jalr	-514(ra) # 4424 <exit>
    printf("%s: sbrk test fork failed\n", s);
    362e:	85d2                	mv	a1,s4
    3630:	00003517          	auipc	a0,0x3
    3634:	cd850513          	addi	a0,a0,-808 # 6308 <malloc+0x1a9e>
    3638:	00001097          	auipc	ra,0x1
    363c:	174080e7          	jalr	372(ra) # 47ac <printf>
    exit(1);
    3640:	4505                	li	a0,1
    3642:	00001097          	auipc	ra,0x1
    3646:	de2080e7          	jalr	-542(ra) # 4424 <exit>
  if(pid == 0)
    364a:	00091763          	bnez	s2,3658 <sbrkbasic+0x104>
    exit(0);
    364e:	4501                	li	a0,0
    3650:	00001097          	auipc	ra,0x1
    3654:	dd4080e7          	jalr	-556(ra) # 4424 <exit>
  wait(&xstatus);
    3658:	fcc40513          	addi	a0,s0,-52
    365c:	00001097          	auipc	ra,0x1
    3660:	dd0080e7          	jalr	-560(ra) # 442c <wait>
  exit(xstatus);
    3664:	fcc42503          	lw	a0,-52(s0)
    3668:	00001097          	auipc	ra,0x1
    366c:	dbc080e7          	jalr	-580(ra) # 4424 <exit>

0000000000003670 <sbrkmuch>:
{
    3670:	7179                	addi	sp,sp,-48
    3672:	f406                	sd	ra,40(sp)
    3674:	f022                	sd	s0,32(sp)
    3676:	ec26                	sd	s1,24(sp)
    3678:	e84a                	sd	s2,16(sp)
    367a:	e44e                	sd	s3,8(sp)
    367c:	e052                	sd	s4,0(sp)
    367e:	1800                	addi	s0,sp,48
    3680:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    3682:	4501                	li	a0,0
    3684:	00001097          	auipc	ra,0x1
    3688:	e28080e7          	jalr	-472(ra) # 44ac <sbrk>
    368c:	892a                	mv	s2,a0
  a = sbrk(0);
    368e:	4501                	li	a0,0
    3690:	00001097          	auipc	ra,0x1
    3694:	e1c080e7          	jalr	-484(ra) # 44ac <sbrk>
    3698:	84aa                	mv	s1,a0
  p = sbrk(amt);
    369a:	06400537          	lui	a0,0x6400
    369e:	9d05                	subw	a0,a0,s1
    36a0:	00001097          	auipc	ra,0x1
    36a4:	e0c080e7          	jalr	-500(ra) # 44ac <sbrk>
  if (p != a) {
    36a8:	0aa49963          	bne	s1,a0,375a <sbrkmuch+0xea>
  *lastaddr = 99;
    36ac:	064007b7          	lui	a5,0x6400
    36b0:	06300713          	li	a4,99
    36b4:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f3db7>
  a = sbrk(0);
    36b8:	4501                	li	a0,0
    36ba:	00001097          	auipc	ra,0x1
    36be:	df2080e7          	jalr	-526(ra) # 44ac <sbrk>
    36c2:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    36c4:	757d                	lui	a0,0xfffff
    36c6:	00001097          	auipc	ra,0x1
    36ca:	de6080e7          	jalr	-538(ra) # 44ac <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    36ce:	57fd                	li	a5,-1
    36d0:	0af50363          	beq	a0,a5,3776 <sbrkmuch+0x106>
  c = sbrk(0);
    36d4:	4501                	li	a0,0
    36d6:	00001097          	auipc	ra,0x1
    36da:	dd6080e7          	jalr	-554(ra) # 44ac <sbrk>
  if(c != a - PGSIZE){
    36de:	77fd                	lui	a5,0xfffff
    36e0:	97a6                	add	a5,a5,s1
    36e2:	0af51863          	bne	a0,a5,3792 <sbrkmuch+0x122>
  a = sbrk(0);
    36e6:	4501                	li	a0,0
    36e8:	00001097          	auipc	ra,0x1
    36ec:	dc4080e7          	jalr	-572(ra) # 44ac <sbrk>
    36f0:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    36f2:	6505                	lui	a0,0x1
    36f4:	00001097          	auipc	ra,0x1
    36f8:	db8080e7          	jalr	-584(ra) # 44ac <sbrk>
    36fc:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    36fe:	0aa49963          	bne	s1,a0,37b0 <sbrkmuch+0x140>
    3702:	4501                	li	a0,0
    3704:	00001097          	auipc	ra,0x1
    3708:	da8080e7          	jalr	-600(ra) # 44ac <sbrk>
    370c:	6785                	lui	a5,0x1
    370e:	97a6                	add	a5,a5,s1
    3710:	0af51063          	bne	a0,a5,37b0 <sbrkmuch+0x140>
  if(*lastaddr == 99){
    3714:	064007b7          	lui	a5,0x6400
    3718:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f3db7>
    371c:	06300793          	li	a5,99
    3720:	0af70763          	beq	a4,a5,37ce <sbrkmuch+0x15e>
  a = sbrk(0);
    3724:	4501                	li	a0,0
    3726:	00001097          	auipc	ra,0x1
    372a:	d86080e7          	jalr	-634(ra) # 44ac <sbrk>
    372e:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    3730:	4501                	li	a0,0
    3732:	00001097          	auipc	ra,0x1
    3736:	d7a080e7          	jalr	-646(ra) # 44ac <sbrk>
    373a:	40a9053b          	subw	a0,s2,a0
    373e:	00001097          	auipc	ra,0x1
    3742:	d6e080e7          	jalr	-658(ra) # 44ac <sbrk>
  if(c != a){
    3746:	0aa49263          	bne	s1,a0,37ea <sbrkmuch+0x17a>
}
    374a:	70a2                	ld	ra,40(sp)
    374c:	7402                	ld	s0,32(sp)
    374e:	64e2                	ld	s1,24(sp)
    3750:	6942                	ld	s2,16(sp)
    3752:	69a2                	ld	s3,8(sp)
    3754:	6a02                	ld	s4,0(sp)
    3756:	6145                	addi	sp,sp,48
    3758:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    375a:	85ce                	mv	a1,s3
    375c:	00003517          	auipc	a0,0x3
    3760:	bec50513          	addi	a0,a0,-1044 # 6348 <malloc+0x1ade>
    3764:	00001097          	auipc	ra,0x1
    3768:	048080e7          	jalr	72(ra) # 47ac <printf>
    exit(1);
    376c:	4505                	li	a0,1
    376e:	00001097          	auipc	ra,0x1
    3772:	cb6080e7          	jalr	-842(ra) # 4424 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    3776:	85ce                	mv	a1,s3
    3778:	00003517          	auipc	a0,0x3
    377c:	c1850513          	addi	a0,a0,-1000 # 6390 <malloc+0x1b26>
    3780:	00001097          	auipc	ra,0x1
    3784:	02c080e7          	jalr	44(ra) # 47ac <printf>
    exit(1);
    3788:	4505                	li	a0,1
    378a:	00001097          	auipc	ra,0x1
    378e:	c9a080e7          	jalr	-870(ra) # 4424 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    3792:	862a                	mv	a2,a0
    3794:	85a6                	mv	a1,s1
    3796:	00003517          	auipc	a0,0x3
    379a:	c1a50513          	addi	a0,a0,-998 # 63b0 <malloc+0x1b46>
    379e:	00001097          	auipc	ra,0x1
    37a2:	00e080e7          	jalr	14(ra) # 47ac <printf>
    exit(1);
    37a6:	4505                	li	a0,1
    37a8:	00001097          	auipc	ra,0x1
    37ac:	c7c080e7          	jalr	-900(ra) # 4424 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", a, c);
    37b0:	8652                	mv	a2,s4
    37b2:	85a6                	mv	a1,s1
    37b4:	00003517          	auipc	a0,0x3
    37b8:	c3c50513          	addi	a0,a0,-964 # 63f0 <malloc+0x1b86>
    37bc:	00001097          	auipc	ra,0x1
    37c0:	ff0080e7          	jalr	-16(ra) # 47ac <printf>
    exit(1);
    37c4:	4505                	li	a0,1
    37c6:	00001097          	auipc	ra,0x1
    37ca:	c5e080e7          	jalr	-930(ra) # 4424 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    37ce:	85ce                	mv	a1,s3
    37d0:	00003517          	auipc	a0,0x3
    37d4:	c5050513          	addi	a0,a0,-944 # 6420 <malloc+0x1bb6>
    37d8:	00001097          	auipc	ra,0x1
    37dc:	fd4080e7          	jalr	-44(ra) # 47ac <printf>
    exit(1);
    37e0:	4505                	li	a0,1
    37e2:	00001097          	auipc	ra,0x1
    37e6:	c42080e7          	jalr	-958(ra) # 4424 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", a, c);
    37ea:	862a                	mv	a2,a0
    37ec:	85a6                	mv	a1,s1
    37ee:	00003517          	auipc	a0,0x3
    37f2:	c6a50513          	addi	a0,a0,-918 # 6458 <malloc+0x1bee>
    37f6:	00001097          	auipc	ra,0x1
    37fa:	fb6080e7          	jalr	-74(ra) # 47ac <printf>
    exit(1);
    37fe:	4505                	li	a0,1
    3800:	00001097          	auipc	ra,0x1
    3804:	c24080e7          	jalr	-988(ra) # 4424 <exit>

0000000000003808 <sbrkfail>:
{
    3808:	7119                	addi	sp,sp,-128
    380a:	fc86                	sd	ra,120(sp)
    380c:	f8a2                	sd	s0,112(sp)
    380e:	f4a6                	sd	s1,104(sp)
    3810:	f0ca                	sd	s2,96(sp)
    3812:	ecce                	sd	s3,88(sp)
    3814:	e8d2                	sd	s4,80(sp)
    3816:	e4d6                	sd	s5,72(sp)
    3818:	0100                	addi	s0,sp,128
    381a:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    381c:	fb040513          	addi	a0,s0,-80
    3820:	00001097          	auipc	ra,0x1
    3824:	c14080e7          	jalr	-1004(ra) # 4434 <pipe>
    3828:	e901                	bnez	a0,3838 <sbrkfail+0x30>
    382a:	f8040493          	addi	s1,s0,-128
    382e:	fa840993          	addi	s3,s0,-88
    3832:	8926                	mv	s2,s1
    if(pids[i] != -1)
    3834:	5a7d                	li	s4,-1
    3836:	a085                	j	3896 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    3838:	85d6                	mv	a1,s5
    383a:	00002517          	auipc	a0,0x2
    383e:	e5e50513          	addi	a0,a0,-418 # 5698 <malloc+0xe2e>
    3842:	00001097          	auipc	ra,0x1
    3846:	f6a080e7          	jalr	-150(ra) # 47ac <printf>
    exit(1);
    384a:	4505                	li	a0,1
    384c:	00001097          	auipc	ra,0x1
    3850:	bd8080e7          	jalr	-1064(ra) # 4424 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    3854:	00001097          	auipc	ra,0x1
    3858:	c58080e7          	jalr	-936(ra) # 44ac <sbrk>
    385c:	064007b7          	lui	a5,0x6400
    3860:	40a7853b          	subw	a0,a5,a0
    3864:	00001097          	auipc	ra,0x1
    3868:	c48080e7          	jalr	-952(ra) # 44ac <sbrk>
      write(fds[1], "x", 1);
    386c:	4605                	li	a2,1
    386e:	00002597          	auipc	a1,0x2
    3872:	eaa58593          	addi	a1,a1,-342 # 5718 <malloc+0xeae>
    3876:	fb442503          	lw	a0,-76(s0)
    387a:	00001097          	auipc	ra,0x1
    387e:	bca080e7          	jalr	-1078(ra) # 4444 <write>
      for(;;) sleep(1000);
    3882:	3e800513          	li	a0,1000
    3886:	00001097          	auipc	ra,0x1
    388a:	c2e080e7          	jalr	-978(ra) # 44b4 <sleep>
    388e:	bfd5                	j	3882 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3890:	0911                	addi	s2,s2,4
    3892:	03390563          	beq	s2,s3,38bc <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    3896:	00001097          	auipc	ra,0x1
    389a:	b86080e7          	jalr	-1146(ra) # 441c <fork>
    389e:	00a92023          	sw	a0,0(s2) # 3000 <subdir+0x622>
    38a2:	d94d                	beqz	a0,3854 <sbrkfail+0x4c>
    if(pids[i] != -1)
    38a4:	ff4506e3          	beq	a0,s4,3890 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    38a8:	4605                	li	a2,1
    38aa:	faf40593          	addi	a1,s0,-81
    38ae:	fb042503          	lw	a0,-80(s0)
    38b2:	00001097          	auipc	ra,0x1
    38b6:	b8a080e7          	jalr	-1142(ra) # 443c <read>
    38ba:	bfd9                	j	3890 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    38bc:	6505                	lui	a0,0x1
    38be:	00001097          	auipc	ra,0x1
    38c2:	bee080e7          	jalr	-1042(ra) # 44ac <sbrk>
    38c6:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    38c8:	597d                	li	s2,-1
    38ca:	a021                	j	38d2 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    38cc:	0491                	addi	s1,s1,4
    38ce:	01348f63          	beq	s1,s3,38ec <sbrkfail+0xe4>
    if(pids[i] == -1)
    38d2:	4088                	lw	a0,0(s1)
    38d4:	ff250ce3          	beq	a0,s2,38cc <sbrkfail+0xc4>
    kill(pids[i]);
    38d8:	00001097          	auipc	ra,0x1
    38dc:	b7c080e7          	jalr	-1156(ra) # 4454 <kill>
    wait(0);
    38e0:	4501                	li	a0,0
    38e2:	00001097          	auipc	ra,0x1
    38e6:	b4a080e7          	jalr	-1206(ra) # 442c <wait>
    38ea:	b7cd                	j	38cc <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    38ec:	57fd                	li	a5,-1
    38ee:	02fa0e63          	beq	s4,a5,392a <sbrkfail+0x122>
  pid = fork();
    38f2:	00001097          	auipc	ra,0x1
    38f6:	b2a080e7          	jalr	-1238(ra) # 441c <fork>
    38fa:	84aa                	mv	s1,a0
  if(pid < 0){
    38fc:	04054563          	bltz	a0,3946 <sbrkfail+0x13e>
  if(pid == 0){
    3900:	c12d                	beqz	a0,3962 <sbrkfail+0x15a>
  wait(&xstatus);
    3902:	fbc40513          	addi	a0,s0,-68
    3906:	00001097          	auipc	ra,0x1
    390a:	b26080e7          	jalr	-1242(ra) # 442c <wait>
  if(xstatus != -1)
    390e:	fbc42703          	lw	a4,-68(s0)
    3912:	57fd                	li	a5,-1
    3914:	08f71c63          	bne	a4,a5,39ac <sbrkfail+0x1a4>
}
    3918:	70e6                	ld	ra,120(sp)
    391a:	7446                	ld	s0,112(sp)
    391c:	74a6                	ld	s1,104(sp)
    391e:	7906                	ld	s2,96(sp)
    3920:	69e6                	ld	s3,88(sp)
    3922:	6a46                	ld	s4,80(sp)
    3924:	6aa6                	ld	s5,72(sp)
    3926:	6109                	addi	sp,sp,128
    3928:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    392a:	85d6                	mv	a1,s5
    392c:	00003517          	auipc	a0,0x3
    3930:	b5450513          	addi	a0,a0,-1196 # 6480 <malloc+0x1c16>
    3934:	00001097          	auipc	ra,0x1
    3938:	e78080e7          	jalr	-392(ra) # 47ac <printf>
    exit(1);
    393c:	4505                	li	a0,1
    393e:	00001097          	auipc	ra,0x1
    3942:	ae6080e7          	jalr	-1306(ra) # 4424 <exit>
    printf("%s: fork failed\n", s);
    3946:	85d6                	mv	a1,s5
    3948:	00001517          	auipc	a0,0x1
    394c:	42050513          	addi	a0,a0,1056 # 4d68 <malloc+0x4fe>
    3950:	00001097          	auipc	ra,0x1
    3954:	e5c080e7          	jalr	-420(ra) # 47ac <printf>
    exit(1);
    3958:	4505                	li	a0,1
    395a:	00001097          	auipc	ra,0x1
    395e:	aca080e7          	jalr	-1334(ra) # 4424 <exit>
    a = sbrk(0);
    3962:	4501                	li	a0,0
    3964:	00001097          	auipc	ra,0x1
    3968:	b48080e7          	jalr	-1208(ra) # 44ac <sbrk>
    396c:	892a                	mv	s2,a0
    sbrk(10*BIG);
    396e:	3e800537          	lui	a0,0x3e800
    3972:	00001097          	auipc	ra,0x1
    3976:	b3a080e7          	jalr	-1222(ra) # 44ac <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    397a:	87ca                	mv	a5,s2
    397c:	3e800737          	lui	a4,0x3e800
    3980:	993a                	add	s2,s2,a4
    3982:	6705                	lui	a4,0x1
      n += *(a+i);
    3984:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f3db8>
    3988:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    398a:	97ba                	add	a5,a5,a4
    398c:	ff279ce3          	bne	a5,s2,3984 <sbrkfail+0x17c>
    printf("%s: allocate a lot of memory succeeded %d\n", n);
    3990:	85a6                	mv	a1,s1
    3992:	00003517          	auipc	a0,0x3
    3996:	b0e50513          	addi	a0,a0,-1266 # 64a0 <malloc+0x1c36>
    399a:	00001097          	auipc	ra,0x1
    399e:	e12080e7          	jalr	-494(ra) # 47ac <printf>
    exit(1);
    39a2:	4505                	li	a0,1
    39a4:	00001097          	auipc	ra,0x1
    39a8:	a80080e7          	jalr	-1408(ra) # 4424 <exit>
    exit(1);
    39ac:	4505                	li	a0,1
    39ae:	00001097          	auipc	ra,0x1
    39b2:	a76080e7          	jalr	-1418(ra) # 4424 <exit>

00000000000039b6 <sbrkarg>:
{
    39b6:	7179                	addi	sp,sp,-48
    39b8:	f406                	sd	ra,40(sp)
    39ba:	f022                	sd	s0,32(sp)
    39bc:	ec26                	sd	s1,24(sp)
    39be:	e84a                	sd	s2,16(sp)
    39c0:	e44e                	sd	s3,8(sp)
    39c2:	1800                	addi	s0,sp,48
    39c4:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    39c6:	6505                	lui	a0,0x1
    39c8:	00001097          	auipc	ra,0x1
    39cc:	ae4080e7          	jalr	-1308(ra) # 44ac <sbrk>
    39d0:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    39d2:	20100593          	li	a1,513
    39d6:	00003517          	auipc	a0,0x3
    39da:	afa50513          	addi	a0,a0,-1286 # 64d0 <malloc+0x1c66>
    39de:	00001097          	auipc	ra,0x1
    39e2:	a86080e7          	jalr	-1402(ra) # 4464 <open>
    39e6:	84aa                	mv	s1,a0
  unlink("sbrk");
    39e8:	00003517          	auipc	a0,0x3
    39ec:	ae850513          	addi	a0,a0,-1304 # 64d0 <malloc+0x1c66>
    39f0:	00001097          	auipc	ra,0x1
    39f4:	a84080e7          	jalr	-1404(ra) # 4474 <unlink>
  if(fd < 0)  {
    39f8:	0404c163          	bltz	s1,3a3a <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    39fc:	6605                	lui	a2,0x1
    39fe:	85ca                	mv	a1,s2
    3a00:	8526                	mv	a0,s1
    3a02:	00001097          	auipc	ra,0x1
    3a06:	a42080e7          	jalr	-1470(ra) # 4444 <write>
    3a0a:	04054663          	bltz	a0,3a56 <sbrkarg+0xa0>
  close(fd);
    3a0e:	8526                	mv	a0,s1
    3a10:	00001097          	auipc	ra,0x1
    3a14:	a3c080e7          	jalr	-1476(ra) # 444c <close>
  a = sbrk(PGSIZE);
    3a18:	6505                	lui	a0,0x1
    3a1a:	00001097          	auipc	ra,0x1
    3a1e:	a92080e7          	jalr	-1390(ra) # 44ac <sbrk>
  if(pipe((int *) a) != 0){
    3a22:	00001097          	auipc	ra,0x1
    3a26:	a12080e7          	jalr	-1518(ra) # 4434 <pipe>
    3a2a:	e521                	bnez	a0,3a72 <sbrkarg+0xbc>
}
    3a2c:	70a2                	ld	ra,40(sp)
    3a2e:	7402                	ld	s0,32(sp)
    3a30:	64e2                	ld	s1,24(sp)
    3a32:	6942                	ld	s2,16(sp)
    3a34:	69a2                	ld	s3,8(sp)
    3a36:	6145                	addi	sp,sp,48
    3a38:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    3a3a:	85ce                	mv	a1,s3
    3a3c:	00003517          	auipc	a0,0x3
    3a40:	a9c50513          	addi	a0,a0,-1380 # 64d8 <malloc+0x1c6e>
    3a44:	00001097          	auipc	ra,0x1
    3a48:	d68080e7          	jalr	-664(ra) # 47ac <printf>
    exit(1);
    3a4c:	4505                	li	a0,1
    3a4e:	00001097          	auipc	ra,0x1
    3a52:	9d6080e7          	jalr	-1578(ra) # 4424 <exit>
    printf("%s: write sbrk failed\n", s);
    3a56:	85ce                	mv	a1,s3
    3a58:	00003517          	auipc	a0,0x3
    3a5c:	a9850513          	addi	a0,a0,-1384 # 64f0 <malloc+0x1c86>
    3a60:	00001097          	auipc	ra,0x1
    3a64:	d4c080e7          	jalr	-692(ra) # 47ac <printf>
    exit(1);
    3a68:	4505                	li	a0,1
    3a6a:	00001097          	auipc	ra,0x1
    3a6e:	9ba080e7          	jalr	-1606(ra) # 4424 <exit>
    printf("%s: pipe() failed\n", s);
    3a72:	85ce                	mv	a1,s3
    3a74:	00002517          	auipc	a0,0x2
    3a78:	c2450513          	addi	a0,a0,-988 # 5698 <malloc+0xe2e>
    3a7c:	00001097          	auipc	ra,0x1
    3a80:	d30080e7          	jalr	-720(ra) # 47ac <printf>
    exit(1);
    3a84:	4505                	li	a0,1
    3a86:	00001097          	auipc	ra,0x1
    3a8a:	99e080e7          	jalr	-1634(ra) # 4424 <exit>

0000000000003a8e <argptest>:
{
    3a8e:	1101                	addi	sp,sp,-32
    3a90:	ec06                	sd	ra,24(sp)
    3a92:	e822                	sd	s0,16(sp)
    3a94:	e426                	sd	s1,8(sp)
    3a96:	e04a                	sd	s2,0(sp)
    3a98:	1000                	addi	s0,sp,32
    3a9a:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    3a9c:	4581                	li	a1,0
    3a9e:	00003517          	auipc	a0,0x3
    3aa2:	a6a50513          	addi	a0,a0,-1430 # 6508 <malloc+0x1c9e>
    3aa6:	00001097          	auipc	ra,0x1
    3aaa:	9be080e7          	jalr	-1602(ra) # 4464 <open>
  if (fd < 0) {
    3aae:	02054b63          	bltz	a0,3ae4 <argptest+0x56>
    3ab2:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    3ab4:	4501                	li	a0,0
    3ab6:	00001097          	auipc	ra,0x1
    3aba:	9f6080e7          	jalr	-1546(ra) # 44ac <sbrk>
    3abe:	567d                	li	a2,-1
    3ac0:	fff50593          	addi	a1,a0,-1
    3ac4:	8526                	mv	a0,s1
    3ac6:	00001097          	auipc	ra,0x1
    3aca:	976080e7          	jalr	-1674(ra) # 443c <read>
  close(fd);
    3ace:	8526                	mv	a0,s1
    3ad0:	00001097          	auipc	ra,0x1
    3ad4:	97c080e7          	jalr	-1668(ra) # 444c <close>
}
    3ad8:	60e2                	ld	ra,24(sp)
    3ada:	6442                	ld	s0,16(sp)
    3adc:	64a2                	ld	s1,8(sp)
    3ade:	6902                	ld	s2,0(sp)
    3ae0:	6105                	addi	sp,sp,32
    3ae2:	8082                	ret
    printf("%s: open failed\n", s);
    3ae4:	85ca                	mv	a1,s2
    3ae6:	00002517          	auipc	a0,0x2
    3aea:	a5250513          	addi	a0,a0,-1454 # 5538 <malloc+0xcce>
    3aee:	00001097          	auipc	ra,0x1
    3af2:	cbe080e7          	jalr	-834(ra) # 47ac <printf>
    exit(1);
    3af6:	4505                	li	a0,1
    3af8:	00001097          	auipc	ra,0x1
    3afc:	92c080e7          	jalr	-1748(ra) # 4424 <exit>

0000000000003b00 <sbrkbugs>:
{
    3b00:	1141                	addi	sp,sp,-16
    3b02:	e406                	sd	ra,8(sp)
    3b04:	e022                	sd	s0,0(sp)
    3b06:	0800                	addi	s0,sp,16
  int pid = fork();
    3b08:	00001097          	auipc	ra,0x1
    3b0c:	914080e7          	jalr	-1772(ra) # 441c <fork>
  if(pid < 0){
    3b10:	02054263          	bltz	a0,3b34 <sbrkbugs+0x34>
  if(pid == 0){
    3b14:	ed0d                	bnez	a0,3b4e <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    3b16:	00001097          	auipc	ra,0x1
    3b1a:	996080e7          	jalr	-1642(ra) # 44ac <sbrk>
    sbrk(-sz);
    3b1e:	40a0053b          	negw	a0,a0
    3b22:	00001097          	auipc	ra,0x1
    3b26:	98a080e7          	jalr	-1654(ra) # 44ac <sbrk>
    exit(0);
    3b2a:	4501                	li	a0,0
    3b2c:	00001097          	auipc	ra,0x1
    3b30:	8f8080e7          	jalr	-1800(ra) # 4424 <exit>
    printf("fork failed\n");
    3b34:	00002517          	auipc	a0,0x2
    3b38:	b3450513          	addi	a0,a0,-1228 # 5668 <malloc+0xdfe>
    3b3c:	00001097          	auipc	ra,0x1
    3b40:	c70080e7          	jalr	-912(ra) # 47ac <printf>
    exit(1);
    3b44:	4505                	li	a0,1
    3b46:	00001097          	auipc	ra,0x1
    3b4a:	8de080e7          	jalr	-1826(ra) # 4424 <exit>
  wait(0);
    3b4e:	4501                	li	a0,0
    3b50:	00001097          	auipc	ra,0x1
    3b54:	8dc080e7          	jalr	-1828(ra) # 442c <wait>
  pid = fork();
    3b58:	00001097          	auipc	ra,0x1
    3b5c:	8c4080e7          	jalr	-1852(ra) # 441c <fork>
  if(pid < 0){
    3b60:	02054563          	bltz	a0,3b8a <sbrkbugs+0x8a>
  if(pid == 0){
    3b64:	e121                	bnez	a0,3ba4 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    3b66:	00001097          	auipc	ra,0x1
    3b6a:	946080e7          	jalr	-1722(ra) # 44ac <sbrk>
    sbrk(-(sz - 3500));
    3b6e:	6785                	lui	a5,0x1
    3b70:	dac7879b          	addiw	a5,a5,-596
    3b74:	40a7853b          	subw	a0,a5,a0
    3b78:	00001097          	auipc	ra,0x1
    3b7c:	934080e7          	jalr	-1740(ra) # 44ac <sbrk>
    exit(0);
    3b80:	4501                	li	a0,0
    3b82:	00001097          	auipc	ra,0x1
    3b86:	8a2080e7          	jalr	-1886(ra) # 4424 <exit>
    printf("fork failed\n");
    3b8a:	00002517          	auipc	a0,0x2
    3b8e:	ade50513          	addi	a0,a0,-1314 # 5668 <malloc+0xdfe>
    3b92:	00001097          	auipc	ra,0x1
    3b96:	c1a080e7          	jalr	-998(ra) # 47ac <printf>
    exit(1);
    3b9a:	4505                	li	a0,1
    3b9c:	00001097          	auipc	ra,0x1
    3ba0:	888080e7          	jalr	-1912(ra) # 4424 <exit>
  wait(0);
    3ba4:	4501                	li	a0,0
    3ba6:	00001097          	auipc	ra,0x1
    3baa:	886080e7          	jalr	-1914(ra) # 442c <wait>
  pid = fork();
    3bae:	00001097          	auipc	ra,0x1
    3bb2:	86e080e7          	jalr	-1938(ra) # 441c <fork>
  if(pid < 0){
    3bb6:	02054a63          	bltz	a0,3bea <sbrkbugs+0xea>
  if(pid == 0){
    3bba:	e529                	bnez	a0,3c04 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    3bbc:	00001097          	auipc	ra,0x1
    3bc0:	8f0080e7          	jalr	-1808(ra) # 44ac <sbrk>
    3bc4:	67ad                	lui	a5,0xb
    3bc6:	8007879b          	addiw	a5,a5,-2048
    3bca:	40a7853b          	subw	a0,a5,a0
    3bce:	00001097          	auipc	ra,0x1
    3bd2:	8de080e7          	jalr	-1826(ra) # 44ac <sbrk>
    sbrk(-10);
    3bd6:	5559                	li	a0,-10
    3bd8:	00001097          	auipc	ra,0x1
    3bdc:	8d4080e7          	jalr	-1836(ra) # 44ac <sbrk>
    exit(0);
    3be0:	4501                	li	a0,0
    3be2:	00001097          	auipc	ra,0x1
    3be6:	842080e7          	jalr	-1982(ra) # 4424 <exit>
    printf("fork failed\n");
    3bea:	00002517          	auipc	a0,0x2
    3bee:	a7e50513          	addi	a0,a0,-1410 # 5668 <malloc+0xdfe>
    3bf2:	00001097          	auipc	ra,0x1
    3bf6:	bba080e7          	jalr	-1094(ra) # 47ac <printf>
    exit(1);
    3bfa:	4505                	li	a0,1
    3bfc:	00001097          	auipc	ra,0x1
    3c00:	828080e7          	jalr	-2008(ra) # 4424 <exit>
  wait(0);
    3c04:	4501                	li	a0,0
    3c06:	00001097          	auipc	ra,0x1
    3c0a:	826080e7          	jalr	-2010(ra) # 442c <wait>
  exit(0);
    3c0e:	4501                	li	a0,0
    3c10:	00001097          	auipc	ra,0x1
    3c14:	814080e7          	jalr	-2028(ra) # 4424 <exit>

0000000000003c18 <dirtest>:
{
    3c18:	1101                	addi	sp,sp,-32
    3c1a:	ec06                	sd	ra,24(sp)
    3c1c:	e822                	sd	s0,16(sp)
    3c1e:	e426                	sd	s1,8(sp)
    3c20:	1000                	addi	s0,sp,32
    3c22:	84aa                	mv	s1,a0
  printf("mkdir test\n");
    3c24:	00003517          	auipc	a0,0x3
    3c28:	8ec50513          	addi	a0,a0,-1812 # 6510 <malloc+0x1ca6>
    3c2c:	00001097          	auipc	ra,0x1
    3c30:	b80080e7          	jalr	-1152(ra) # 47ac <printf>
  if(mkdir("dir0") < 0){
    3c34:	00003517          	auipc	a0,0x3
    3c38:	8ec50513          	addi	a0,a0,-1812 # 6520 <malloc+0x1cb6>
    3c3c:	00001097          	auipc	ra,0x1
    3c40:	850080e7          	jalr	-1968(ra) # 448c <mkdir>
    3c44:	04054d63          	bltz	a0,3c9e <dirtest+0x86>
  if(chdir("dir0") < 0){
    3c48:	00003517          	auipc	a0,0x3
    3c4c:	8d850513          	addi	a0,a0,-1832 # 6520 <malloc+0x1cb6>
    3c50:	00001097          	auipc	ra,0x1
    3c54:	844080e7          	jalr	-1980(ra) # 4494 <chdir>
    3c58:	06054163          	bltz	a0,3cba <dirtest+0xa2>
  if(chdir("..") < 0){
    3c5c:	00001517          	auipc	a0,0x1
    3c60:	07c50513          	addi	a0,a0,124 # 4cd8 <malloc+0x46e>
    3c64:	00001097          	auipc	ra,0x1
    3c68:	830080e7          	jalr	-2000(ra) # 4494 <chdir>
    3c6c:	06054563          	bltz	a0,3cd6 <dirtest+0xbe>
  if(unlink("dir0") < 0){
    3c70:	00003517          	auipc	a0,0x3
    3c74:	8b050513          	addi	a0,a0,-1872 # 6520 <malloc+0x1cb6>
    3c78:	00000097          	auipc	ra,0x0
    3c7c:	7fc080e7          	jalr	2044(ra) # 4474 <unlink>
    3c80:	06054963          	bltz	a0,3cf2 <dirtest+0xda>
  printf("%s: mkdir test ok\n");
    3c84:	00003517          	auipc	a0,0x3
    3c88:	8ec50513          	addi	a0,a0,-1812 # 6570 <malloc+0x1d06>
    3c8c:	00001097          	auipc	ra,0x1
    3c90:	b20080e7          	jalr	-1248(ra) # 47ac <printf>
}
    3c94:	60e2                	ld	ra,24(sp)
    3c96:	6442                	ld	s0,16(sp)
    3c98:	64a2                	ld	s1,8(sp)
    3c9a:	6105                	addi	sp,sp,32
    3c9c:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3c9e:	85a6                	mv	a1,s1
    3ca0:	00001517          	auipc	a0,0x1
    3ca4:	f5850513          	addi	a0,a0,-168 # 4bf8 <malloc+0x38e>
    3ca8:	00001097          	auipc	ra,0x1
    3cac:	b04080e7          	jalr	-1276(ra) # 47ac <printf>
    exit(1);
    3cb0:	4505                	li	a0,1
    3cb2:	00000097          	auipc	ra,0x0
    3cb6:	772080e7          	jalr	1906(ra) # 4424 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3cba:	85a6                	mv	a1,s1
    3cbc:	00003517          	auipc	a0,0x3
    3cc0:	86c50513          	addi	a0,a0,-1940 # 6528 <malloc+0x1cbe>
    3cc4:	00001097          	auipc	ra,0x1
    3cc8:	ae8080e7          	jalr	-1304(ra) # 47ac <printf>
    exit(1);
    3ccc:	4505                	li	a0,1
    3cce:	00000097          	auipc	ra,0x0
    3cd2:	756080e7          	jalr	1878(ra) # 4424 <exit>
    printf("%s: chdir .. failed\n", s);
    3cd6:	85a6                	mv	a1,s1
    3cd8:	00003517          	auipc	a0,0x3
    3cdc:	86850513          	addi	a0,a0,-1944 # 6540 <malloc+0x1cd6>
    3ce0:	00001097          	auipc	ra,0x1
    3ce4:	acc080e7          	jalr	-1332(ra) # 47ac <printf>
    exit(1);
    3ce8:	4505                	li	a0,1
    3cea:	00000097          	auipc	ra,0x0
    3cee:	73a080e7          	jalr	1850(ra) # 4424 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3cf2:	85a6                	mv	a1,s1
    3cf4:	00003517          	auipc	a0,0x3
    3cf8:	86450513          	addi	a0,a0,-1948 # 6558 <malloc+0x1cee>
    3cfc:	00001097          	auipc	ra,0x1
    3d00:	ab0080e7          	jalr	-1360(ra) # 47ac <printf>
    exit(1);
    3d04:	4505                	li	a0,1
    3d06:	00000097          	auipc	ra,0x0
    3d0a:	71e080e7          	jalr	1822(ra) # 4424 <exit>

0000000000003d0e <fsfull>:
{
    3d0e:	7171                	addi	sp,sp,-176
    3d10:	f506                	sd	ra,168(sp)
    3d12:	f122                	sd	s0,160(sp)
    3d14:	ed26                	sd	s1,152(sp)
    3d16:	e94a                	sd	s2,144(sp)
    3d18:	e54e                	sd	s3,136(sp)
    3d1a:	e152                	sd	s4,128(sp)
    3d1c:	fcd6                	sd	s5,120(sp)
    3d1e:	f8da                	sd	s6,112(sp)
    3d20:	f4de                	sd	s7,104(sp)
    3d22:	f0e2                	sd	s8,96(sp)
    3d24:	ece6                	sd	s9,88(sp)
    3d26:	e8ea                	sd	s10,80(sp)
    3d28:	e4ee                	sd	s11,72(sp)
    3d2a:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    3d2c:	00003517          	auipc	a0,0x3
    3d30:	85c50513          	addi	a0,a0,-1956 # 6588 <malloc+0x1d1e>
    3d34:	00001097          	auipc	ra,0x1
    3d38:	a78080e7          	jalr	-1416(ra) # 47ac <printf>
  for(nfiles = 0; ; nfiles++){
    3d3c:	4481                	li	s1,0
    name[0] = 'f';
    3d3e:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    3d42:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    3d46:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    3d4a:	4b29                	li	s6,10
    printf("%s: writing %s\n", name);
    3d4c:	00003c97          	auipc	s9,0x3
    3d50:	84cc8c93          	addi	s9,s9,-1972 # 6598 <malloc+0x1d2e>
    int total = 0;
    3d54:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    3d56:	00005a17          	auipc	s4,0x5
    3d5a:	4e2a0a13          	addi	s4,s4,1250 # 9238 <buf>
    name[0] = 'f';
    3d5e:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    3d62:	0384c7bb          	divw	a5,s1,s8
    3d66:	0307879b          	addiw	a5,a5,48
    3d6a:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    3d6e:	0384e7bb          	remw	a5,s1,s8
    3d72:	0377c7bb          	divw	a5,a5,s7
    3d76:	0307879b          	addiw	a5,a5,48
    3d7a:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    3d7e:	0374e7bb          	remw	a5,s1,s7
    3d82:	0367c7bb          	divw	a5,a5,s6
    3d86:	0307879b          	addiw	a5,a5,48
    3d8a:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    3d8e:	0364e7bb          	remw	a5,s1,s6
    3d92:	0307879b          	addiw	a5,a5,48
    3d96:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    3d9a:	f4040aa3          	sb	zero,-171(s0)
    printf("%s: writing %s\n", name);
    3d9e:	f5040593          	addi	a1,s0,-176
    3da2:	8566                	mv	a0,s9
    3da4:	00001097          	auipc	ra,0x1
    3da8:	a08080e7          	jalr	-1528(ra) # 47ac <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    3dac:	20200593          	li	a1,514
    3db0:	f5040513          	addi	a0,s0,-176
    3db4:	00000097          	auipc	ra,0x0
    3db8:	6b0080e7          	jalr	1712(ra) # 4464 <open>
    3dbc:	892a                	mv	s2,a0
    if(fd < 0){
    3dbe:	0a055663          	bgez	a0,3e6a <fsfull+0x15c>
      printf("%s: open %s failed\n", name);
    3dc2:	f5040593          	addi	a1,s0,-176
    3dc6:	00002517          	auipc	a0,0x2
    3dca:	7e250513          	addi	a0,a0,2018 # 65a8 <malloc+0x1d3e>
    3dce:	00001097          	auipc	ra,0x1
    3dd2:	9de080e7          	jalr	-1570(ra) # 47ac <printf>
  while(nfiles >= 0){
    3dd6:	0604c363          	bltz	s1,3e3c <fsfull+0x12e>
    name[0] = 'f';
    3dda:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    3dde:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    3de2:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    3de6:	4929                	li	s2,10
  while(nfiles >= 0){
    3de8:	5afd                	li	s5,-1
    name[0] = 'f';
    3dea:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    3dee:	0344c7bb          	divw	a5,s1,s4
    3df2:	0307879b          	addiw	a5,a5,48
    3df6:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    3dfa:	0344e7bb          	remw	a5,s1,s4
    3dfe:	0337c7bb          	divw	a5,a5,s3
    3e02:	0307879b          	addiw	a5,a5,48
    3e06:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    3e0a:	0334e7bb          	remw	a5,s1,s3
    3e0e:	0327c7bb          	divw	a5,a5,s2
    3e12:	0307879b          	addiw	a5,a5,48
    3e16:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    3e1a:	0324e7bb          	remw	a5,s1,s2
    3e1e:	0307879b          	addiw	a5,a5,48
    3e22:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    3e26:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    3e2a:	f5040513          	addi	a0,s0,-176
    3e2e:	00000097          	auipc	ra,0x0
    3e32:	646080e7          	jalr	1606(ra) # 4474 <unlink>
    nfiles--;
    3e36:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    3e38:	fb5499e3          	bne	s1,s5,3dea <fsfull+0xdc>
  printf("fsfull test finished\n");
    3e3c:	00002517          	auipc	a0,0x2
    3e40:	79c50513          	addi	a0,a0,1948 # 65d8 <malloc+0x1d6e>
    3e44:	00001097          	auipc	ra,0x1
    3e48:	968080e7          	jalr	-1688(ra) # 47ac <printf>
}
    3e4c:	70aa                	ld	ra,168(sp)
    3e4e:	740a                	ld	s0,160(sp)
    3e50:	64ea                	ld	s1,152(sp)
    3e52:	694a                	ld	s2,144(sp)
    3e54:	69aa                	ld	s3,136(sp)
    3e56:	6a0a                	ld	s4,128(sp)
    3e58:	7ae6                	ld	s5,120(sp)
    3e5a:	7b46                	ld	s6,112(sp)
    3e5c:	7ba6                	ld	s7,104(sp)
    3e5e:	7c06                	ld	s8,96(sp)
    3e60:	6ce6                	ld	s9,88(sp)
    3e62:	6d46                	ld	s10,80(sp)
    3e64:	6da6                	ld	s11,72(sp)
    3e66:	614d                	addi	sp,sp,176
    3e68:	8082                	ret
    int total = 0;
    3e6a:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    3e6c:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    3e70:	40000613          	li	a2,1024
    3e74:	85d2                	mv	a1,s4
    3e76:	854a                	mv	a0,s2
    3e78:	00000097          	auipc	ra,0x0
    3e7c:	5cc080e7          	jalr	1484(ra) # 4444 <write>
      if(cc < BSIZE)
    3e80:	00aad563          	bge	s5,a0,3e8a <fsfull+0x17c>
      total += cc;
    3e84:	00a989bb          	addw	s3,s3,a0
    while(1){
    3e88:	b7e5                	j	3e70 <fsfull+0x162>
    printf("%s: wrote %d bytes\n", total);
    3e8a:	85ce                	mv	a1,s3
    3e8c:	00002517          	auipc	a0,0x2
    3e90:	73450513          	addi	a0,a0,1844 # 65c0 <malloc+0x1d56>
    3e94:	00001097          	auipc	ra,0x1
    3e98:	918080e7          	jalr	-1768(ra) # 47ac <printf>
    close(fd);
    3e9c:	854a                	mv	a0,s2
    3e9e:	00000097          	auipc	ra,0x0
    3ea2:	5ae080e7          	jalr	1454(ra) # 444c <close>
    if(total == 0)
    3ea6:	f20988e3          	beqz	s3,3dd6 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    3eaa:	2485                	addiw	s1,s1,1
    3eac:	bd4d                	j	3d5e <fsfull+0x50>

0000000000003eae <rand>:
{
    3eae:	1141                	addi	sp,sp,-16
    3eb0:	e422                	sd	s0,8(sp)
    3eb2:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    3eb4:	00003717          	auipc	a4,0x3
    3eb8:	b5c70713          	addi	a4,a4,-1188 # 6a10 <randstate>
    3ebc:	6308                	ld	a0,0(a4)
    3ebe:	001967b7          	lui	a5,0x196
    3ec2:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x18a3c5>
    3ec6:	02f50533          	mul	a0,a0,a5
    3eca:	3c6ef7b7          	lui	a5,0x3c6ef
    3ece:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e3117>
    3ed2:	953e                	add	a0,a0,a5
    3ed4:	e308                	sd	a0,0(a4)
}
    3ed6:	2501                	sext.w	a0,a0
    3ed8:	6422                	ld	s0,8(sp)
    3eda:	0141                	addi	sp,sp,16
    3edc:	8082                	ret

0000000000003ede <badwrite>:
{
    3ede:	7179                	addi	sp,sp,-48
    3ee0:	f406                	sd	ra,40(sp)
    3ee2:	f022                	sd	s0,32(sp)
    3ee4:	ec26                	sd	s1,24(sp)
    3ee6:	e84a                	sd	s2,16(sp)
    3ee8:	e44e                	sd	s3,8(sp)
    3eea:	e052                	sd	s4,0(sp)
    3eec:	1800                	addi	s0,sp,48
  unlink("junk");
    3eee:	00002517          	auipc	a0,0x2
    3ef2:	70250513          	addi	a0,a0,1794 # 65f0 <malloc+0x1d86>
    3ef6:	00000097          	auipc	ra,0x0
    3efa:	57e080e7          	jalr	1406(ra) # 4474 <unlink>
    3efe:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    3f02:	00002997          	auipc	s3,0x2
    3f06:	6ee98993          	addi	s3,s3,1774 # 65f0 <malloc+0x1d86>
    write(fd, (char*)0xffffffffffL, 1);
    3f0a:	5a7d                	li	s4,-1
    3f0c:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    3f10:	20100593          	li	a1,513
    3f14:	854e                	mv	a0,s3
    3f16:	00000097          	auipc	ra,0x0
    3f1a:	54e080e7          	jalr	1358(ra) # 4464 <open>
    3f1e:	84aa                	mv	s1,a0
    if(fd < 0){
    3f20:	06054b63          	bltz	a0,3f96 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    3f24:	4605                	li	a2,1
    3f26:	85d2                	mv	a1,s4
    3f28:	00000097          	auipc	ra,0x0
    3f2c:	51c080e7          	jalr	1308(ra) # 4444 <write>
    close(fd);
    3f30:	8526                	mv	a0,s1
    3f32:	00000097          	auipc	ra,0x0
    3f36:	51a080e7          	jalr	1306(ra) # 444c <close>
    unlink("junk");
    3f3a:	854e                	mv	a0,s3
    3f3c:	00000097          	auipc	ra,0x0
    3f40:	538080e7          	jalr	1336(ra) # 4474 <unlink>
  for(int i = 0; i < assumed_free; i++){
    3f44:	397d                	addiw	s2,s2,-1
    3f46:	fc0915e3          	bnez	s2,3f10 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    3f4a:	20100593          	li	a1,513
    3f4e:	00002517          	auipc	a0,0x2
    3f52:	6a250513          	addi	a0,a0,1698 # 65f0 <malloc+0x1d86>
    3f56:	00000097          	auipc	ra,0x0
    3f5a:	50e080e7          	jalr	1294(ra) # 4464 <open>
    3f5e:	84aa                	mv	s1,a0
  if(fd < 0){
    3f60:	04054863          	bltz	a0,3fb0 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    3f64:	4605                	li	a2,1
    3f66:	00001597          	auipc	a1,0x1
    3f6a:	7b258593          	addi	a1,a1,1970 # 5718 <malloc+0xeae>
    3f6e:	00000097          	auipc	ra,0x0
    3f72:	4d6080e7          	jalr	1238(ra) # 4444 <write>
    3f76:	4785                	li	a5,1
    3f78:	04f50963          	beq	a0,a5,3fca <badwrite+0xec>
    printf("write failed\n");
    3f7c:	00002517          	auipc	a0,0x2
    3f80:	69450513          	addi	a0,a0,1684 # 6610 <malloc+0x1da6>
    3f84:	00001097          	auipc	ra,0x1
    3f88:	828080e7          	jalr	-2008(ra) # 47ac <printf>
    exit(1);
    3f8c:	4505                	li	a0,1
    3f8e:	00000097          	auipc	ra,0x0
    3f92:	496080e7          	jalr	1174(ra) # 4424 <exit>
      printf("open junk failed\n");
    3f96:	00002517          	auipc	a0,0x2
    3f9a:	66250513          	addi	a0,a0,1634 # 65f8 <malloc+0x1d8e>
    3f9e:	00001097          	auipc	ra,0x1
    3fa2:	80e080e7          	jalr	-2034(ra) # 47ac <printf>
      exit(1);
    3fa6:	4505                	li	a0,1
    3fa8:	00000097          	auipc	ra,0x0
    3fac:	47c080e7          	jalr	1148(ra) # 4424 <exit>
    printf("open junk failed\n");
    3fb0:	00002517          	auipc	a0,0x2
    3fb4:	64850513          	addi	a0,a0,1608 # 65f8 <malloc+0x1d8e>
    3fb8:	00000097          	auipc	ra,0x0
    3fbc:	7f4080e7          	jalr	2036(ra) # 47ac <printf>
    exit(1);
    3fc0:	4505                	li	a0,1
    3fc2:	00000097          	auipc	ra,0x0
    3fc6:	462080e7          	jalr	1122(ra) # 4424 <exit>
  close(fd);
    3fca:	8526                	mv	a0,s1
    3fcc:	00000097          	auipc	ra,0x0
    3fd0:	480080e7          	jalr	1152(ra) # 444c <close>
  unlink("junk");
    3fd4:	00002517          	auipc	a0,0x2
    3fd8:	61c50513          	addi	a0,a0,1564 # 65f0 <malloc+0x1d86>
    3fdc:	00000097          	auipc	ra,0x0
    3fe0:	498080e7          	jalr	1176(ra) # 4474 <unlink>
  exit(0);
    3fe4:	4501                	li	a0,0
    3fe6:	00000097          	auipc	ra,0x0
    3fea:	43e080e7          	jalr	1086(ra) # 4424 <exit>

0000000000003fee <run>:
}

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    3fee:	7179                	addi	sp,sp,-48
    3ff0:	f406                	sd	ra,40(sp)
    3ff2:	f022                	sd	s0,32(sp)
    3ff4:	ec26                	sd	s1,24(sp)
    3ff6:	e84a                	sd	s2,16(sp)
    3ff8:	1800                	addi	s0,sp,48
    3ffa:	892a                	mv	s2,a0
    3ffc:	84ae                	mv	s1,a1
  int pid;
  int xstatus;
  
  printf("test %s: ", s);
    3ffe:	00002517          	auipc	a0,0x2
    4002:	62250513          	addi	a0,a0,1570 # 6620 <malloc+0x1db6>
    4006:	00000097          	auipc	ra,0x0
    400a:	7a6080e7          	jalr	1958(ra) # 47ac <printf>
  if((pid = fork()) < 0) {
    400e:	00000097          	auipc	ra,0x0
    4012:	40e080e7          	jalr	1038(ra) # 441c <fork>
    4016:	02054f63          	bltz	a0,4054 <run+0x66>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    401a:	c931                	beqz	a0,406e <run+0x80>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    401c:	fdc40513          	addi	a0,s0,-36
    4020:	00000097          	auipc	ra,0x0
    4024:	40c080e7          	jalr	1036(ra) # 442c <wait>
    if(xstatus != 0) 
    4028:	fdc42783          	lw	a5,-36(s0)
    402c:	cba1                	beqz	a5,407c <run+0x8e>
      printf("FAILED\n", s);
    402e:	85a6                	mv	a1,s1
    4030:	00002517          	auipc	a0,0x2
    4034:	61850513          	addi	a0,a0,1560 # 6648 <malloc+0x1dde>
    4038:	00000097          	auipc	ra,0x0
    403c:	774080e7          	jalr	1908(ra) # 47ac <printf>
    else
      printf("OK\n", s);
    return xstatus == 0;
    4040:	fdc42503          	lw	a0,-36(s0)
  }
}
    4044:	00153513          	seqz	a0,a0
    4048:	70a2                	ld	ra,40(sp)
    404a:	7402                	ld	s0,32(sp)
    404c:	64e2                	ld	s1,24(sp)
    404e:	6942                	ld	s2,16(sp)
    4050:	6145                	addi	sp,sp,48
    4052:	8082                	ret
    printf("runtest: fork error\n");
    4054:	00002517          	auipc	a0,0x2
    4058:	5dc50513          	addi	a0,a0,1500 # 6630 <malloc+0x1dc6>
    405c:	00000097          	auipc	ra,0x0
    4060:	750080e7          	jalr	1872(ra) # 47ac <printf>
    exit(1);
    4064:	4505                	li	a0,1
    4066:	00000097          	auipc	ra,0x0
    406a:	3be080e7          	jalr	958(ra) # 4424 <exit>
    f(s);
    406e:	8526                	mv	a0,s1
    4070:	9902                	jalr	s2
    exit(0);
    4072:	4501                	li	a0,0
    4074:	00000097          	auipc	ra,0x0
    4078:	3b0080e7          	jalr	944(ra) # 4424 <exit>
      printf("OK\n", s);
    407c:	85a6                	mv	a1,s1
    407e:	00002517          	auipc	a0,0x2
    4082:	5d250513          	addi	a0,a0,1490 # 6650 <malloc+0x1de6>
    4086:	00000097          	auipc	ra,0x0
    408a:	726080e7          	jalr	1830(ra) # 47ac <printf>
    408e:	bf4d                	j	4040 <run+0x52>

0000000000004090 <main>:

int
main(int argc, char *argv[])
{
    4090:	ce010113          	addi	sp,sp,-800
    4094:	30113c23          	sd	ra,792(sp)
    4098:	30813823          	sd	s0,784(sp)
    409c:	30913423          	sd	s1,776(sp)
    40a0:	31213023          	sd	s2,768(sp)
    40a4:	2f313c23          	sd	s3,760(sp)
    40a8:	2f413823          	sd	s4,752(sp)
    40ac:	1600                	addi	s0,sp,800
  char *n = 0;
  if(argc > 1) {
    40ae:	4785                	li	a5,1
  char *n = 0;
    40b0:	4901                	li	s2,0
  if(argc > 1) {
    40b2:	00a7d463          	bge	a5,a0,40ba <main+0x2a>
    n = argv[1];
    40b6:	0085b903          	ld	s2,8(a1)
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    40ba:	00002797          	auipc	a5,0x2
    40be:	63e78793          	addi	a5,a5,1598 # 66f8 <malloc+0x1e8e>
    40c2:	ce040713          	addi	a4,s0,-800
    40c6:	00003817          	auipc	a6,0x3
    40ca:	91280813          	addi	a6,a6,-1774 # 69d8 <malloc+0x216e>
    40ce:	6388                	ld	a0,0(a5)
    40d0:	678c                	ld	a1,8(a5)
    40d2:	6b90                	ld	a2,16(a5)
    40d4:	6f94                	ld	a3,24(a5)
    40d6:	e308                	sd	a0,0(a4)
    40d8:	e70c                	sd	a1,8(a4)
    40da:	eb10                	sd	a2,16(a4)
    40dc:	ef14                	sd	a3,24(a4)
    40de:	02078793          	addi	a5,a5,32
    40e2:	02070713          	addi	a4,a4,32
    40e6:	ff0794e3          	bne	a5,a6,40ce <main+0x3e>
    40ea:	6394                	ld	a3,0(a5)
    40ec:	679c                	ld	a5,8(a5)
    40ee:	e314                	sd	a3,0(a4)
    40f0:	e71c                	sd	a5,8(a4)
    {forktest, "forktest"},
    {bigdir, "bigdir"}, // slow
    { 0, 0},
  };
    
  printf("usertests starting\n");
    40f2:	00002517          	auipc	a0,0x2
    40f6:	56650513          	addi	a0,a0,1382 # 6658 <malloc+0x1dee>
    40fa:	00000097          	auipc	ra,0x0
    40fe:	6b2080e7          	jalr	1714(ra) # 47ac <printf>

  if(open("usertests.ran", 0) >= 0){
    4102:	4581                	li	a1,0
    4104:	00002517          	auipc	a0,0x2
    4108:	56c50513          	addi	a0,a0,1388 # 6670 <malloc+0x1e06>
    410c:	00000097          	auipc	ra,0x0
    4110:	358080e7          	jalr	856(ra) # 4464 <open>
    4114:	00054f63          	bltz	a0,4132 <main+0xa2>
    printf("already ran user tests -- rebuild fs.img (rm fs.img; make fs.img)\n");
    4118:	00002517          	auipc	a0,0x2
    411c:	56850513          	addi	a0,a0,1384 # 6680 <malloc+0x1e16>
    4120:	00000097          	auipc	ra,0x0
    4124:	68c080e7          	jalr	1676(ra) # 47ac <printf>
    exit(1);
    4128:	4505                	li	a0,1
    412a:	00000097          	auipc	ra,0x0
    412e:	2fa080e7          	jalr	762(ra) # 4424 <exit>
  }
  close(open("usertests.ran", O_CREATE));
    4132:	20000593          	li	a1,512
    4136:	00002517          	auipc	a0,0x2
    413a:	53a50513          	addi	a0,a0,1338 # 6670 <malloc+0x1e06>
    413e:	00000097          	auipc	ra,0x0
    4142:	326080e7          	jalr	806(ra) # 4464 <open>
    4146:	00000097          	auipc	ra,0x0
    414a:	306080e7          	jalr	774(ra) # 444c <close>

  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    414e:	ce843503          	ld	a0,-792(s0)
    4152:	c529                	beqz	a0,419c <main+0x10c>
    4154:	ce040493          	addi	s1,s0,-800
  int fail = 0;
    4158:	4981                	li	s3,0
    if((n == 0) || strcmp(t->s, n) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    415a:	4a05                	li	s4,1
    415c:	a021                	j	4164 <main+0xd4>
  for (struct test *t = tests; t->s != 0; t++) {
    415e:	04c1                	addi	s1,s1,16
    4160:	6488                	ld	a0,8(s1)
    4162:	c115                	beqz	a0,4186 <main+0xf6>
    if((n == 0) || strcmp(t->s, n) == 0) {
    4164:	00090863          	beqz	s2,4174 <main+0xe4>
    4168:	85ca                	mv	a1,s2
    416a:	00000097          	auipc	ra,0x0
    416e:	068080e7          	jalr	104(ra) # 41d2 <strcmp>
    4172:	f575                	bnez	a0,415e <main+0xce>
      if(!run(t->f, t->s))
    4174:	648c                	ld	a1,8(s1)
    4176:	6088                	ld	a0,0(s1)
    4178:	00000097          	auipc	ra,0x0
    417c:	e76080e7          	jalr	-394(ra) # 3fee <run>
    4180:	fd79                	bnez	a0,415e <main+0xce>
        fail = 1;
    4182:	89d2                	mv	s3,s4
    4184:	bfe9                	j	415e <main+0xce>
    }
  }
  if(!fail)
    4186:	00098b63          	beqz	s3,419c <main+0x10c>
    printf("ALL TESTS PASSED\n");
  else
    printf("SOME TESTS FAILED\n");
    418a:	00002517          	auipc	a0,0x2
    418e:	55650513          	addi	a0,a0,1366 # 66e0 <malloc+0x1e76>
    4192:	00000097          	auipc	ra,0x0
    4196:	61a080e7          	jalr	1562(ra) # 47ac <printf>
    419a:	a809                	j	41ac <main+0x11c>
    printf("ALL TESTS PASSED\n");
    419c:	00002517          	auipc	a0,0x2
    41a0:	52c50513          	addi	a0,a0,1324 # 66c8 <malloc+0x1e5e>
    41a4:	00000097          	auipc	ra,0x0
    41a8:	608080e7          	jalr	1544(ra) # 47ac <printf>
  exit(1);   // not reached.
    41ac:	4505                	li	a0,1
    41ae:	00000097          	auipc	ra,0x0
    41b2:	276080e7          	jalr	630(ra) # 4424 <exit>

00000000000041b6 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    41b6:	1141                	addi	sp,sp,-16
    41b8:	e422                	sd	s0,8(sp)
    41ba:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    41bc:	87aa                	mv	a5,a0
    41be:	0585                	addi	a1,a1,1
    41c0:	0785                	addi	a5,a5,1
    41c2:	fff5c703          	lbu	a4,-1(a1)
    41c6:	fee78fa3          	sb	a4,-1(a5)
    41ca:	fb75                	bnez	a4,41be <strcpy+0x8>
    ;
  return os;
}
    41cc:	6422                	ld	s0,8(sp)
    41ce:	0141                	addi	sp,sp,16
    41d0:	8082                	ret

00000000000041d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    41d2:	1141                	addi	sp,sp,-16
    41d4:	e422                	sd	s0,8(sp)
    41d6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    41d8:	00054783          	lbu	a5,0(a0)
    41dc:	cb91                	beqz	a5,41f0 <strcmp+0x1e>
    41de:	0005c703          	lbu	a4,0(a1)
    41e2:	00f71763          	bne	a4,a5,41f0 <strcmp+0x1e>
    p++, q++;
    41e6:	0505                	addi	a0,a0,1
    41e8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    41ea:	00054783          	lbu	a5,0(a0)
    41ee:	fbe5                	bnez	a5,41de <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    41f0:	0005c503          	lbu	a0,0(a1)
}
    41f4:	40a7853b          	subw	a0,a5,a0
    41f8:	6422                	ld	s0,8(sp)
    41fa:	0141                	addi	sp,sp,16
    41fc:	8082                	ret

00000000000041fe <strlen>:

uint
strlen(const char *s)
{
    41fe:	1141                	addi	sp,sp,-16
    4200:	e422                	sd	s0,8(sp)
    4202:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    4204:	00054783          	lbu	a5,0(a0)
    4208:	cf91                	beqz	a5,4224 <strlen+0x26>
    420a:	0505                	addi	a0,a0,1
    420c:	87aa                	mv	a5,a0
    420e:	4685                	li	a3,1
    4210:	9e89                	subw	a3,a3,a0
    4212:	00f6853b          	addw	a0,a3,a5
    4216:	0785                	addi	a5,a5,1
    4218:	fff7c703          	lbu	a4,-1(a5)
    421c:	fb7d                	bnez	a4,4212 <strlen+0x14>
    ;
  return n;
}
    421e:	6422                	ld	s0,8(sp)
    4220:	0141                	addi	sp,sp,16
    4222:	8082                	ret
  for(n = 0; s[n]; n++)
    4224:	4501                	li	a0,0
    4226:	bfe5                	j	421e <strlen+0x20>

0000000000004228 <memset>:

void*
memset(void *dst, int c, uint n)
{
    4228:	1141                	addi	sp,sp,-16
    422a:	e422                	sd	s0,8(sp)
    422c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    422e:	ca19                	beqz	a2,4244 <memset+0x1c>
    4230:	87aa                	mv	a5,a0
    4232:	1602                	slli	a2,a2,0x20
    4234:	9201                	srli	a2,a2,0x20
    4236:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    423a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    423e:	0785                	addi	a5,a5,1
    4240:	fee79de3          	bne	a5,a4,423a <memset+0x12>
  }
  return dst;
}
    4244:	6422                	ld	s0,8(sp)
    4246:	0141                	addi	sp,sp,16
    4248:	8082                	ret

000000000000424a <strchr>:

char*
strchr(const char *s, char c)
{
    424a:	1141                	addi	sp,sp,-16
    424c:	e422                	sd	s0,8(sp)
    424e:	0800                	addi	s0,sp,16
  for(; *s; s++)
    4250:	00054783          	lbu	a5,0(a0)
    4254:	cb99                	beqz	a5,426a <strchr+0x20>
    if(*s == c)
    4256:	00f58763          	beq	a1,a5,4264 <strchr+0x1a>
  for(; *s; s++)
    425a:	0505                	addi	a0,a0,1
    425c:	00054783          	lbu	a5,0(a0)
    4260:	fbfd                	bnez	a5,4256 <strchr+0xc>
      return (char*)s;
  return 0;
    4262:	4501                	li	a0,0
}
    4264:	6422                	ld	s0,8(sp)
    4266:	0141                	addi	sp,sp,16
    4268:	8082                	ret
  return 0;
    426a:	4501                	li	a0,0
    426c:	bfe5                	j	4264 <strchr+0x1a>

000000000000426e <gets>:

char*
gets(char *buf, int max)
{
    426e:	711d                	addi	sp,sp,-96
    4270:	ec86                	sd	ra,88(sp)
    4272:	e8a2                	sd	s0,80(sp)
    4274:	e4a6                	sd	s1,72(sp)
    4276:	e0ca                	sd	s2,64(sp)
    4278:	fc4e                	sd	s3,56(sp)
    427a:	f852                	sd	s4,48(sp)
    427c:	f456                	sd	s5,40(sp)
    427e:	f05a                	sd	s6,32(sp)
    4280:	ec5e                	sd	s7,24(sp)
    4282:	1080                	addi	s0,sp,96
    4284:	8baa                	mv	s7,a0
    4286:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4288:	892a                	mv	s2,a0
    428a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    428c:	4aa9                	li	s5,10
    428e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    4290:	89a6                	mv	s3,s1
    4292:	2485                	addiw	s1,s1,1
    4294:	0344d863          	bge	s1,s4,42c4 <gets+0x56>
    cc = read(0, &c, 1);
    4298:	4605                	li	a2,1
    429a:	faf40593          	addi	a1,s0,-81
    429e:	4501                	li	a0,0
    42a0:	00000097          	auipc	ra,0x0
    42a4:	19c080e7          	jalr	412(ra) # 443c <read>
    if(cc < 1)
    42a8:	00a05e63          	blez	a0,42c4 <gets+0x56>
    buf[i++] = c;
    42ac:	faf44783          	lbu	a5,-81(s0)
    42b0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    42b4:	01578763          	beq	a5,s5,42c2 <gets+0x54>
    42b8:	0905                	addi	s2,s2,1
    42ba:	fd679be3          	bne	a5,s6,4290 <gets+0x22>
  for(i=0; i+1 < max; ){
    42be:	89a6                	mv	s3,s1
    42c0:	a011                	j	42c4 <gets+0x56>
    42c2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    42c4:	99de                	add	s3,s3,s7
    42c6:	00098023          	sb	zero,0(s3)
  return buf;
}
    42ca:	855e                	mv	a0,s7
    42cc:	60e6                	ld	ra,88(sp)
    42ce:	6446                	ld	s0,80(sp)
    42d0:	64a6                	ld	s1,72(sp)
    42d2:	6906                	ld	s2,64(sp)
    42d4:	79e2                	ld	s3,56(sp)
    42d6:	7a42                	ld	s4,48(sp)
    42d8:	7aa2                	ld	s5,40(sp)
    42da:	7b02                	ld	s6,32(sp)
    42dc:	6be2                	ld	s7,24(sp)
    42de:	6125                	addi	sp,sp,96
    42e0:	8082                	ret

00000000000042e2 <stat>:

int
stat(const char *n, struct stat *st)
{
    42e2:	1101                	addi	sp,sp,-32
    42e4:	ec06                	sd	ra,24(sp)
    42e6:	e822                	sd	s0,16(sp)
    42e8:	e426                	sd	s1,8(sp)
    42ea:	e04a                	sd	s2,0(sp)
    42ec:	1000                	addi	s0,sp,32
    42ee:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    42f0:	4581                	li	a1,0
    42f2:	00000097          	auipc	ra,0x0
    42f6:	172080e7          	jalr	370(ra) # 4464 <open>
  if(fd < 0)
    42fa:	02054563          	bltz	a0,4324 <stat+0x42>
    42fe:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    4300:	85ca                	mv	a1,s2
    4302:	00000097          	auipc	ra,0x0
    4306:	17a080e7          	jalr	378(ra) # 447c <fstat>
    430a:	892a                	mv	s2,a0
  close(fd);
    430c:	8526                	mv	a0,s1
    430e:	00000097          	auipc	ra,0x0
    4312:	13e080e7          	jalr	318(ra) # 444c <close>
  return r;
}
    4316:	854a                	mv	a0,s2
    4318:	60e2                	ld	ra,24(sp)
    431a:	6442                	ld	s0,16(sp)
    431c:	64a2                	ld	s1,8(sp)
    431e:	6902                	ld	s2,0(sp)
    4320:	6105                	addi	sp,sp,32
    4322:	8082                	ret
    return -1;
    4324:	597d                	li	s2,-1
    4326:	bfc5                	j	4316 <stat+0x34>

0000000000004328 <atoi>:

int
atoi(const char *s)
{
    4328:	1141                	addi	sp,sp,-16
    432a:	e422                	sd	s0,8(sp)
    432c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    432e:	00054603          	lbu	a2,0(a0)
    4332:	fd06079b          	addiw	a5,a2,-48
    4336:	0ff7f793          	andi	a5,a5,255
    433a:	4725                	li	a4,9
    433c:	02f76963          	bltu	a4,a5,436e <atoi+0x46>
    4340:	86aa                	mv	a3,a0
  n = 0;
    4342:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    4344:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    4346:	0685                	addi	a3,a3,1
    4348:	0025179b          	slliw	a5,a0,0x2
    434c:	9fa9                	addw	a5,a5,a0
    434e:	0017979b          	slliw	a5,a5,0x1
    4352:	9fb1                	addw	a5,a5,a2
    4354:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    4358:	0006c603          	lbu	a2,0(a3)
    435c:	fd06071b          	addiw	a4,a2,-48
    4360:	0ff77713          	andi	a4,a4,255
    4364:	fee5f1e3          	bgeu	a1,a4,4346 <atoi+0x1e>
  return n;
}
    4368:	6422                	ld	s0,8(sp)
    436a:	0141                	addi	sp,sp,16
    436c:	8082                	ret
  n = 0;
    436e:	4501                	li	a0,0
    4370:	bfe5                	j	4368 <atoi+0x40>

0000000000004372 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    4372:	1141                	addi	sp,sp,-16
    4374:	e422                	sd	s0,8(sp)
    4376:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    4378:	02b57463          	bgeu	a0,a1,43a0 <memmove+0x2e>
    while(n-- > 0)
    437c:	00c05f63          	blez	a2,439a <memmove+0x28>
    4380:	1602                	slli	a2,a2,0x20
    4382:	9201                	srli	a2,a2,0x20
    4384:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    4388:	872a                	mv	a4,a0
      *dst++ = *src++;
    438a:	0585                	addi	a1,a1,1
    438c:	0705                	addi	a4,a4,1
    438e:	fff5c683          	lbu	a3,-1(a1)
    4392:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    4396:	fee79ae3          	bne	a5,a4,438a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    439a:	6422                	ld	s0,8(sp)
    439c:	0141                	addi	sp,sp,16
    439e:	8082                	ret
    dst += n;
    43a0:	00c50733          	add	a4,a0,a2
    src += n;
    43a4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    43a6:	fec05ae3          	blez	a2,439a <memmove+0x28>
    43aa:	fff6079b          	addiw	a5,a2,-1
    43ae:	1782                	slli	a5,a5,0x20
    43b0:	9381                	srli	a5,a5,0x20
    43b2:	fff7c793          	not	a5,a5
    43b6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    43b8:	15fd                	addi	a1,a1,-1
    43ba:	177d                	addi	a4,a4,-1
    43bc:	0005c683          	lbu	a3,0(a1)
    43c0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    43c4:	fee79ae3          	bne	a5,a4,43b8 <memmove+0x46>
    43c8:	bfc9                	j	439a <memmove+0x28>

00000000000043ca <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    43ca:	1141                	addi	sp,sp,-16
    43cc:	e422                	sd	s0,8(sp)
    43ce:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    43d0:	ca05                	beqz	a2,4400 <memcmp+0x36>
    43d2:	fff6069b          	addiw	a3,a2,-1
    43d6:	1682                	slli	a3,a3,0x20
    43d8:	9281                	srli	a3,a3,0x20
    43da:	0685                	addi	a3,a3,1
    43dc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    43de:	00054783          	lbu	a5,0(a0)
    43e2:	0005c703          	lbu	a4,0(a1)
    43e6:	00e79863          	bne	a5,a4,43f6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    43ea:	0505                	addi	a0,a0,1
    p2++;
    43ec:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    43ee:	fed518e3          	bne	a0,a3,43de <memcmp+0x14>
  }
  return 0;
    43f2:	4501                	li	a0,0
    43f4:	a019                	j	43fa <memcmp+0x30>
      return *p1 - *p2;
    43f6:	40e7853b          	subw	a0,a5,a4
}
    43fa:	6422                	ld	s0,8(sp)
    43fc:	0141                	addi	sp,sp,16
    43fe:	8082                	ret
  return 0;
    4400:	4501                	li	a0,0
    4402:	bfe5                	j	43fa <memcmp+0x30>

0000000000004404 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    4404:	1141                	addi	sp,sp,-16
    4406:	e406                	sd	ra,8(sp)
    4408:	e022                	sd	s0,0(sp)
    440a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    440c:	00000097          	auipc	ra,0x0
    4410:	f66080e7          	jalr	-154(ra) # 4372 <memmove>
}
    4414:	60a2                	ld	ra,8(sp)
    4416:	6402                	ld	s0,0(sp)
    4418:	0141                	addi	sp,sp,16
    441a:	8082                	ret

000000000000441c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    441c:	4885                	li	a7,1
 ecall
    441e:	00000073          	ecall
 ret
    4422:	8082                	ret

0000000000004424 <exit>:
.global exit
exit:
 li a7, SYS_exit
    4424:	4889                	li	a7,2
 ecall
    4426:	00000073          	ecall
 ret
    442a:	8082                	ret

000000000000442c <wait>:
.global wait
wait:
 li a7, SYS_wait
    442c:	488d                	li	a7,3
 ecall
    442e:	00000073          	ecall
 ret
    4432:	8082                	ret

0000000000004434 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    4434:	4891                	li	a7,4
 ecall
    4436:	00000073          	ecall
 ret
    443a:	8082                	ret

000000000000443c <read>:
.global read
read:
 li a7, SYS_read
    443c:	4895                	li	a7,5
 ecall
    443e:	00000073          	ecall
 ret
    4442:	8082                	ret

0000000000004444 <write>:
.global write
write:
 li a7, SYS_write
    4444:	48c1                	li	a7,16
 ecall
    4446:	00000073          	ecall
 ret
    444a:	8082                	ret

000000000000444c <close>:
.global close
close:
 li a7, SYS_close
    444c:	48d5                	li	a7,21
 ecall
    444e:	00000073          	ecall
 ret
    4452:	8082                	ret

0000000000004454 <kill>:
.global kill
kill:
 li a7, SYS_kill
    4454:	4899                	li	a7,6
 ecall
    4456:	00000073          	ecall
 ret
    445a:	8082                	ret

000000000000445c <exec>:
.global exec
exec:
 li a7, SYS_exec
    445c:	489d                	li	a7,7
 ecall
    445e:	00000073          	ecall
 ret
    4462:	8082                	ret

0000000000004464 <open>:
.global open
open:
 li a7, SYS_open
    4464:	48bd                	li	a7,15
 ecall
    4466:	00000073          	ecall
 ret
    446a:	8082                	ret

000000000000446c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    446c:	48c5                	li	a7,17
 ecall
    446e:	00000073          	ecall
 ret
    4472:	8082                	ret

0000000000004474 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    4474:	48c9                	li	a7,18
 ecall
    4476:	00000073          	ecall
 ret
    447a:	8082                	ret

000000000000447c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    447c:	48a1                	li	a7,8
 ecall
    447e:	00000073          	ecall
 ret
    4482:	8082                	ret

0000000000004484 <link>:
.global link
link:
 li a7, SYS_link
    4484:	48cd                	li	a7,19
 ecall
    4486:	00000073          	ecall
 ret
    448a:	8082                	ret

000000000000448c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    448c:	48d1                	li	a7,20
 ecall
    448e:	00000073          	ecall
 ret
    4492:	8082                	ret

0000000000004494 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    4494:	48a5                	li	a7,9
 ecall
    4496:	00000073          	ecall
 ret
    449a:	8082                	ret

000000000000449c <dup>:
.global dup
dup:
 li a7, SYS_dup
    449c:	48a9                	li	a7,10
 ecall
    449e:	00000073          	ecall
 ret
    44a2:	8082                	ret

00000000000044a4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    44a4:	48ad                	li	a7,11
 ecall
    44a6:	00000073          	ecall
 ret
    44aa:	8082                	ret

00000000000044ac <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    44ac:	48b1                	li	a7,12
 ecall
    44ae:	00000073          	ecall
 ret
    44b2:	8082                	ret

00000000000044b4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    44b4:	48b5                	li	a7,13
 ecall
    44b6:	00000073          	ecall
 ret
    44ba:	8082                	ret

00000000000044bc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    44bc:	48b9                	li	a7,14
 ecall
    44be:	00000073          	ecall
 ret
    44c2:	8082                	ret

00000000000044c4 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
    44c4:	48d9                	li	a7,22
 ecall
    44c6:	00000073          	ecall
 ret
    44ca:	8082                	ret

00000000000044cc <symlink>:
.global symlink
symlink:
 li a7, SYS_symlink
    44cc:	48dd                	li	a7,23
 ecall
    44ce:	00000073          	ecall
 ret
    44d2:	8082                	ret

00000000000044d4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    44d4:	1101                	addi	sp,sp,-32
    44d6:	ec06                	sd	ra,24(sp)
    44d8:	e822                	sd	s0,16(sp)
    44da:	1000                	addi	s0,sp,32
    44dc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    44e0:	4605                	li	a2,1
    44e2:	fef40593          	addi	a1,s0,-17
    44e6:	00000097          	auipc	ra,0x0
    44ea:	f5e080e7          	jalr	-162(ra) # 4444 <write>
}
    44ee:	60e2                	ld	ra,24(sp)
    44f0:	6442                	ld	s0,16(sp)
    44f2:	6105                	addi	sp,sp,32
    44f4:	8082                	ret

00000000000044f6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    44f6:	7139                	addi	sp,sp,-64
    44f8:	fc06                	sd	ra,56(sp)
    44fa:	f822                	sd	s0,48(sp)
    44fc:	f426                	sd	s1,40(sp)
    44fe:	f04a                	sd	s2,32(sp)
    4500:	ec4e                	sd	s3,24(sp)
    4502:	0080                	addi	s0,sp,64
    4504:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    4506:	c299                	beqz	a3,450c <printint+0x16>
    4508:	0805c863          	bltz	a1,4598 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    450c:	2581                	sext.w	a1,a1
  neg = 0;
    450e:	4881                	li	a7,0
    4510:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    4514:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    4516:	2601                	sext.w	a2,a2
    4518:	00002517          	auipc	a0,0x2
    451c:	4d850513          	addi	a0,a0,1240 # 69f0 <digits>
    4520:	883a                	mv	a6,a4
    4522:	2705                	addiw	a4,a4,1
    4524:	02c5f7bb          	remuw	a5,a1,a2
    4528:	1782                	slli	a5,a5,0x20
    452a:	9381                	srli	a5,a5,0x20
    452c:	97aa                	add	a5,a5,a0
    452e:	0007c783          	lbu	a5,0(a5)
    4532:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    4536:	0005879b          	sext.w	a5,a1
    453a:	02c5d5bb          	divuw	a1,a1,a2
    453e:	0685                	addi	a3,a3,1
    4540:	fec7f0e3          	bgeu	a5,a2,4520 <printint+0x2a>
  if(neg)
    4544:	00088b63          	beqz	a7,455a <printint+0x64>
    buf[i++] = '-';
    4548:	fd040793          	addi	a5,s0,-48
    454c:	973e                	add	a4,a4,a5
    454e:	02d00793          	li	a5,45
    4552:	fef70823          	sb	a5,-16(a4)
    4556:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    455a:	02e05863          	blez	a4,458a <printint+0x94>
    455e:	fc040793          	addi	a5,s0,-64
    4562:	00e78933          	add	s2,a5,a4
    4566:	fff78993          	addi	s3,a5,-1
    456a:	99ba                	add	s3,s3,a4
    456c:	377d                	addiw	a4,a4,-1
    456e:	1702                	slli	a4,a4,0x20
    4570:	9301                	srli	a4,a4,0x20
    4572:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    4576:	fff94583          	lbu	a1,-1(s2)
    457a:	8526                	mv	a0,s1
    457c:	00000097          	auipc	ra,0x0
    4580:	f58080e7          	jalr	-168(ra) # 44d4 <putc>
  while(--i >= 0)
    4584:	197d                	addi	s2,s2,-1
    4586:	ff3918e3          	bne	s2,s3,4576 <printint+0x80>
}
    458a:	70e2                	ld	ra,56(sp)
    458c:	7442                	ld	s0,48(sp)
    458e:	74a2                	ld	s1,40(sp)
    4590:	7902                	ld	s2,32(sp)
    4592:	69e2                	ld	s3,24(sp)
    4594:	6121                	addi	sp,sp,64
    4596:	8082                	ret
    x = -xx;
    4598:	40b005bb          	negw	a1,a1
    neg = 1;
    459c:	4885                	li	a7,1
    x = -xx;
    459e:	bf8d                	j	4510 <printint+0x1a>

00000000000045a0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    45a0:	7119                	addi	sp,sp,-128
    45a2:	fc86                	sd	ra,120(sp)
    45a4:	f8a2                	sd	s0,112(sp)
    45a6:	f4a6                	sd	s1,104(sp)
    45a8:	f0ca                	sd	s2,96(sp)
    45aa:	ecce                	sd	s3,88(sp)
    45ac:	e8d2                	sd	s4,80(sp)
    45ae:	e4d6                	sd	s5,72(sp)
    45b0:	e0da                	sd	s6,64(sp)
    45b2:	fc5e                	sd	s7,56(sp)
    45b4:	f862                	sd	s8,48(sp)
    45b6:	f466                	sd	s9,40(sp)
    45b8:	f06a                	sd	s10,32(sp)
    45ba:	ec6e                	sd	s11,24(sp)
    45bc:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    45be:	0005c903          	lbu	s2,0(a1)
    45c2:	18090f63          	beqz	s2,4760 <vprintf+0x1c0>
    45c6:	8aaa                	mv	s5,a0
    45c8:	8b32                	mv	s6,a2
    45ca:	00158493          	addi	s1,a1,1
  state = 0;
    45ce:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    45d0:	02500a13          	li	s4,37
      if(c == 'd'){
    45d4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    45d8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    45dc:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    45e0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    45e4:	00002b97          	auipc	s7,0x2
    45e8:	40cb8b93          	addi	s7,s7,1036 # 69f0 <digits>
    45ec:	a839                	j	460a <vprintf+0x6a>
        putc(fd, c);
    45ee:	85ca                	mv	a1,s2
    45f0:	8556                	mv	a0,s5
    45f2:	00000097          	auipc	ra,0x0
    45f6:	ee2080e7          	jalr	-286(ra) # 44d4 <putc>
    45fa:	a019                	j	4600 <vprintf+0x60>
    } else if(state == '%'){
    45fc:	01498f63          	beq	s3,s4,461a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    4600:	0485                	addi	s1,s1,1
    4602:	fff4c903          	lbu	s2,-1(s1)
    4606:	14090d63          	beqz	s2,4760 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    460a:	0009079b          	sext.w	a5,s2
    if(state == 0){
    460e:	fe0997e3          	bnez	s3,45fc <vprintf+0x5c>
      if(c == '%'){
    4612:	fd479ee3          	bne	a5,s4,45ee <vprintf+0x4e>
        state = '%';
    4616:	89be                	mv	s3,a5
    4618:	b7e5                	j	4600 <vprintf+0x60>
      if(c == 'd'){
    461a:	05878063          	beq	a5,s8,465a <vprintf+0xba>
      } else if(c == 'l') {
    461e:	05978c63          	beq	a5,s9,4676 <vprintf+0xd6>
      } else if(c == 'x') {
    4622:	07a78863          	beq	a5,s10,4692 <vprintf+0xf2>
      } else if(c == 'p') {
    4626:	09b78463          	beq	a5,s11,46ae <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    462a:	07300713          	li	a4,115
    462e:	0ce78663          	beq	a5,a4,46fa <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    4632:	06300713          	li	a4,99
    4636:	0ee78e63          	beq	a5,a4,4732 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    463a:	11478863          	beq	a5,s4,474a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    463e:	85d2                	mv	a1,s4
    4640:	8556                	mv	a0,s5
    4642:	00000097          	auipc	ra,0x0
    4646:	e92080e7          	jalr	-366(ra) # 44d4 <putc>
        putc(fd, c);
    464a:	85ca                	mv	a1,s2
    464c:	8556                	mv	a0,s5
    464e:	00000097          	auipc	ra,0x0
    4652:	e86080e7          	jalr	-378(ra) # 44d4 <putc>
      }
      state = 0;
    4656:	4981                	li	s3,0
    4658:	b765                	j	4600 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    465a:	008b0913          	addi	s2,s6,8
    465e:	4685                	li	a3,1
    4660:	4629                	li	a2,10
    4662:	000b2583          	lw	a1,0(s6)
    4666:	8556                	mv	a0,s5
    4668:	00000097          	auipc	ra,0x0
    466c:	e8e080e7          	jalr	-370(ra) # 44f6 <printint>
    4670:	8b4a                	mv	s6,s2
      state = 0;
    4672:	4981                	li	s3,0
    4674:	b771                	j	4600 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    4676:	008b0913          	addi	s2,s6,8
    467a:	4681                	li	a3,0
    467c:	4629                	li	a2,10
    467e:	000b2583          	lw	a1,0(s6)
    4682:	8556                	mv	a0,s5
    4684:	00000097          	auipc	ra,0x0
    4688:	e72080e7          	jalr	-398(ra) # 44f6 <printint>
    468c:	8b4a                	mv	s6,s2
      state = 0;
    468e:	4981                	li	s3,0
    4690:	bf85                	j	4600 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    4692:	008b0913          	addi	s2,s6,8
    4696:	4681                	li	a3,0
    4698:	4641                	li	a2,16
    469a:	000b2583          	lw	a1,0(s6)
    469e:	8556                	mv	a0,s5
    46a0:	00000097          	auipc	ra,0x0
    46a4:	e56080e7          	jalr	-426(ra) # 44f6 <printint>
    46a8:	8b4a                	mv	s6,s2
      state = 0;
    46aa:	4981                	li	s3,0
    46ac:	bf91                	j	4600 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    46ae:	008b0793          	addi	a5,s6,8
    46b2:	f8f43423          	sd	a5,-120(s0)
    46b6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    46ba:	03000593          	li	a1,48
    46be:	8556                	mv	a0,s5
    46c0:	00000097          	auipc	ra,0x0
    46c4:	e14080e7          	jalr	-492(ra) # 44d4 <putc>
  putc(fd, 'x');
    46c8:	85ea                	mv	a1,s10
    46ca:	8556                	mv	a0,s5
    46cc:	00000097          	auipc	ra,0x0
    46d0:	e08080e7          	jalr	-504(ra) # 44d4 <putc>
    46d4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    46d6:	03c9d793          	srli	a5,s3,0x3c
    46da:	97de                	add	a5,a5,s7
    46dc:	0007c583          	lbu	a1,0(a5)
    46e0:	8556                	mv	a0,s5
    46e2:	00000097          	auipc	ra,0x0
    46e6:	df2080e7          	jalr	-526(ra) # 44d4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    46ea:	0992                	slli	s3,s3,0x4
    46ec:	397d                	addiw	s2,s2,-1
    46ee:	fe0914e3          	bnez	s2,46d6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    46f2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    46f6:	4981                	li	s3,0
    46f8:	b721                	j	4600 <vprintf+0x60>
        s = va_arg(ap, char*);
    46fa:	008b0993          	addi	s3,s6,8
    46fe:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    4702:	02090163          	beqz	s2,4724 <vprintf+0x184>
        while(*s != 0){
    4706:	00094583          	lbu	a1,0(s2)
    470a:	c9a1                	beqz	a1,475a <vprintf+0x1ba>
          putc(fd, *s);
    470c:	8556                	mv	a0,s5
    470e:	00000097          	auipc	ra,0x0
    4712:	dc6080e7          	jalr	-570(ra) # 44d4 <putc>
          s++;
    4716:	0905                	addi	s2,s2,1
        while(*s != 0){
    4718:	00094583          	lbu	a1,0(s2)
    471c:	f9e5                	bnez	a1,470c <vprintf+0x16c>
        s = va_arg(ap, char*);
    471e:	8b4e                	mv	s6,s3
      state = 0;
    4720:	4981                	li	s3,0
    4722:	bdf9                	j	4600 <vprintf+0x60>
          s = "(null)";
    4724:	00002917          	auipc	s2,0x2
    4728:	2c490913          	addi	s2,s2,708 # 69e8 <malloc+0x217e>
        while(*s != 0){
    472c:	02800593          	li	a1,40
    4730:	bff1                	j	470c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    4732:	008b0913          	addi	s2,s6,8
    4736:	000b4583          	lbu	a1,0(s6)
    473a:	8556                	mv	a0,s5
    473c:	00000097          	auipc	ra,0x0
    4740:	d98080e7          	jalr	-616(ra) # 44d4 <putc>
    4744:	8b4a                	mv	s6,s2
      state = 0;
    4746:	4981                	li	s3,0
    4748:	bd65                	j	4600 <vprintf+0x60>
        putc(fd, c);
    474a:	85d2                	mv	a1,s4
    474c:	8556                	mv	a0,s5
    474e:	00000097          	auipc	ra,0x0
    4752:	d86080e7          	jalr	-634(ra) # 44d4 <putc>
      state = 0;
    4756:	4981                	li	s3,0
    4758:	b565                	j	4600 <vprintf+0x60>
        s = va_arg(ap, char*);
    475a:	8b4e                	mv	s6,s3
      state = 0;
    475c:	4981                	li	s3,0
    475e:	b54d                	j	4600 <vprintf+0x60>
    }
  }
}
    4760:	70e6                	ld	ra,120(sp)
    4762:	7446                	ld	s0,112(sp)
    4764:	74a6                	ld	s1,104(sp)
    4766:	7906                	ld	s2,96(sp)
    4768:	69e6                	ld	s3,88(sp)
    476a:	6a46                	ld	s4,80(sp)
    476c:	6aa6                	ld	s5,72(sp)
    476e:	6b06                	ld	s6,64(sp)
    4770:	7be2                	ld	s7,56(sp)
    4772:	7c42                	ld	s8,48(sp)
    4774:	7ca2                	ld	s9,40(sp)
    4776:	7d02                	ld	s10,32(sp)
    4778:	6de2                	ld	s11,24(sp)
    477a:	6109                	addi	sp,sp,128
    477c:	8082                	ret

000000000000477e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    477e:	715d                	addi	sp,sp,-80
    4780:	ec06                	sd	ra,24(sp)
    4782:	e822                	sd	s0,16(sp)
    4784:	1000                	addi	s0,sp,32
    4786:	e010                	sd	a2,0(s0)
    4788:	e414                	sd	a3,8(s0)
    478a:	e818                	sd	a4,16(s0)
    478c:	ec1c                	sd	a5,24(s0)
    478e:	03043023          	sd	a6,32(s0)
    4792:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    4796:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    479a:	8622                	mv	a2,s0
    479c:	00000097          	auipc	ra,0x0
    47a0:	e04080e7          	jalr	-508(ra) # 45a0 <vprintf>
}
    47a4:	60e2                	ld	ra,24(sp)
    47a6:	6442                	ld	s0,16(sp)
    47a8:	6161                	addi	sp,sp,80
    47aa:	8082                	ret

00000000000047ac <printf>:

void
printf(const char *fmt, ...)
{
    47ac:	711d                	addi	sp,sp,-96
    47ae:	ec06                	sd	ra,24(sp)
    47b0:	e822                	sd	s0,16(sp)
    47b2:	1000                	addi	s0,sp,32
    47b4:	e40c                	sd	a1,8(s0)
    47b6:	e810                	sd	a2,16(s0)
    47b8:	ec14                	sd	a3,24(s0)
    47ba:	f018                	sd	a4,32(s0)
    47bc:	f41c                	sd	a5,40(s0)
    47be:	03043823          	sd	a6,48(s0)
    47c2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    47c6:	00840613          	addi	a2,s0,8
    47ca:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    47ce:	85aa                	mv	a1,a0
    47d0:	4505                	li	a0,1
    47d2:	00000097          	auipc	ra,0x0
    47d6:	dce080e7          	jalr	-562(ra) # 45a0 <vprintf>
}
    47da:	60e2                	ld	ra,24(sp)
    47dc:	6442                	ld	s0,16(sp)
    47de:	6125                	addi	sp,sp,96
    47e0:	8082                	ret

00000000000047e2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    47e2:	1141                	addi	sp,sp,-16
    47e4:	e422                	sd	s0,8(sp)
    47e6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    47e8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    47ec:	00002797          	auipc	a5,0x2
    47f0:	2347b783          	ld	a5,564(a5) # 6a20 <freep>
    47f4:	a805                	j	4824 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    47f6:	4618                	lw	a4,8(a2)
    47f8:	9db9                	addw	a1,a1,a4
    47fa:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    47fe:	6398                	ld	a4,0(a5)
    4800:	6318                	ld	a4,0(a4)
    4802:	fee53823          	sd	a4,-16(a0)
    4806:	a091                	j	484a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    4808:	ff852703          	lw	a4,-8(a0)
    480c:	9e39                	addw	a2,a2,a4
    480e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    4810:	ff053703          	ld	a4,-16(a0)
    4814:	e398                	sd	a4,0(a5)
    4816:	a099                	j	485c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    4818:	6398                	ld	a4,0(a5)
    481a:	00e7e463          	bltu	a5,a4,4822 <free+0x40>
    481e:	00e6ea63          	bltu	a3,a4,4832 <free+0x50>
{
    4822:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4824:	fed7fae3          	bgeu	a5,a3,4818 <free+0x36>
    4828:	6398                	ld	a4,0(a5)
    482a:	00e6e463          	bltu	a3,a4,4832 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    482e:	fee7eae3          	bltu	a5,a4,4822 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    4832:	ff852583          	lw	a1,-8(a0)
    4836:	6390                	ld	a2,0(a5)
    4838:	02059713          	slli	a4,a1,0x20
    483c:	9301                	srli	a4,a4,0x20
    483e:	0712                	slli	a4,a4,0x4
    4840:	9736                	add	a4,a4,a3
    4842:	fae60ae3          	beq	a2,a4,47f6 <free+0x14>
    bp->s.ptr = p->s.ptr;
    4846:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    484a:	4790                	lw	a2,8(a5)
    484c:	02061713          	slli	a4,a2,0x20
    4850:	9301                	srli	a4,a4,0x20
    4852:	0712                	slli	a4,a4,0x4
    4854:	973e                	add	a4,a4,a5
    4856:	fae689e3          	beq	a3,a4,4808 <free+0x26>
  } else
    p->s.ptr = bp;
    485a:	e394                	sd	a3,0(a5)
  freep = p;
    485c:	00002717          	auipc	a4,0x2
    4860:	1cf73223          	sd	a5,452(a4) # 6a20 <freep>
}
    4864:	6422                	ld	s0,8(sp)
    4866:	0141                	addi	sp,sp,16
    4868:	8082                	ret

000000000000486a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    486a:	7139                	addi	sp,sp,-64
    486c:	fc06                	sd	ra,56(sp)
    486e:	f822                	sd	s0,48(sp)
    4870:	f426                	sd	s1,40(sp)
    4872:	f04a                	sd	s2,32(sp)
    4874:	ec4e                	sd	s3,24(sp)
    4876:	e852                	sd	s4,16(sp)
    4878:	e456                	sd	s5,8(sp)
    487a:	e05a                	sd	s6,0(sp)
    487c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    487e:	02051493          	slli	s1,a0,0x20
    4882:	9081                	srli	s1,s1,0x20
    4884:	04bd                	addi	s1,s1,15
    4886:	8091                	srli	s1,s1,0x4
    4888:	0014899b          	addiw	s3,s1,1
    488c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    488e:	00002517          	auipc	a0,0x2
    4892:	19253503          	ld	a0,402(a0) # 6a20 <freep>
    4896:	c515                	beqz	a0,48c2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4898:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    489a:	4798                	lw	a4,8(a5)
    489c:	02977f63          	bgeu	a4,s1,48da <malloc+0x70>
    48a0:	8a4e                	mv	s4,s3
    48a2:	0009871b          	sext.w	a4,s3
    48a6:	6685                	lui	a3,0x1
    48a8:	00d77363          	bgeu	a4,a3,48ae <malloc+0x44>
    48ac:	6a05                	lui	s4,0x1
    48ae:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    48b2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    48b6:	00002917          	auipc	s2,0x2
    48ba:	16a90913          	addi	s2,s2,362 # 6a20 <freep>
  if(p == (char*)-1)
    48be:	5afd                	li	s5,-1
    48c0:	a88d                	j	4932 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    48c2:	00008797          	auipc	a5,0x8
    48c6:	97678793          	addi	a5,a5,-1674 # c238 <base>
    48ca:	00002717          	auipc	a4,0x2
    48ce:	14f73b23          	sd	a5,342(a4) # 6a20 <freep>
    48d2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    48d4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    48d8:	b7e1                	j	48a0 <malloc+0x36>
      if(p->s.size == nunits)
    48da:	02e48b63          	beq	s1,a4,4910 <malloc+0xa6>
        p->s.size -= nunits;
    48de:	4137073b          	subw	a4,a4,s3
    48e2:	c798                	sw	a4,8(a5)
        p += p->s.size;
    48e4:	1702                	slli	a4,a4,0x20
    48e6:	9301                	srli	a4,a4,0x20
    48e8:	0712                	slli	a4,a4,0x4
    48ea:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    48ec:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    48f0:	00002717          	auipc	a4,0x2
    48f4:	12a73823          	sd	a0,304(a4) # 6a20 <freep>
      return (void*)(p + 1);
    48f8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    48fc:	70e2                	ld	ra,56(sp)
    48fe:	7442                	ld	s0,48(sp)
    4900:	74a2                	ld	s1,40(sp)
    4902:	7902                	ld	s2,32(sp)
    4904:	69e2                	ld	s3,24(sp)
    4906:	6a42                	ld	s4,16(sp)
    4908:	6aa2                	ld	s5,8(sp)
    490a:	6b02                	ld	s6,0(sp)
    490c:	6121                	addi	sp,sp,64
    490e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    4910:	6398                	ld	a4,0(a5)
    4912:	e118                	sd	a4,0(a0)
    4914:	bff1                	j	48f0 <malloc+0x86>
  hp->s.size = nu;
    4916:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    491a:	0541                	addi	a0,a0,16
    491c:	00000097          	auipc	ra,0x0
    4920:	ec6080e7          	jalr	-314(ra) # 47e2 <free>
  return freep;
    4924:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    4928:	d971                	beqz	a0,48fc <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    492a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    492c:	4798                	lw	a4,8(a5)
    492e:	fa9776e3          	bgeu	a4,s1,48da <malloc+0x70>
    if(p == freep)
    4932:	00093703          	ld	a4,0(s2)
    4936:	853e                	mv	a0,a5
    4938:	fef719e3          	bne	a4,a5,492a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    493c:	8552                	mv	a0,s4
    493e:	00000097          	auipc	ra,0x0
    4942:	b6e080e7          	jalr	-1170(ra) # 44ac <sbrk>
  if(p == (char*)-1)
    4946:	fd5518e3          	bne	a0,s5,4916 <malloc+0xac>
        return 0;
    494a:	4501                	li	a0,0
    494c:	bf45                	j	48fc <malloc+0x92>
