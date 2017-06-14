ioport	EQU	0ec00h-0280h	
io0832	EQU	ioport+290H	;	d/a	
io8255k	EQU	ioport+28BH	;	8255	KONG
io8255a	EQU	ioport+288H	;	8255	a
io8255b	EQU	ioport+289H	;	8255	b
io8255c	EQU	ioport+28AH	;	8255	c
io8253k	EQU	ioport+283H	;	8253控制
io82532	EQU	ioport+282H	;	8253计数器2
io82531	EQU	ioport+281H	;	8253计数器1
io82530	EQU	ioport+280H	;	8253计数器0
DATA	SEGMENT
mess0	DB	'------------------The control program of DC motor------------------
',0AH,0DH,'$'
mess00	
DB	'------------------Made by 61313122 and 61313102------------------
',0AH,0DH,'$'	
mess	DB	'Strike r to show the tested value on LED!,s to show the sandard

mess2	
DB	
'RealSpeed: ','$'
mess3	DB	'	SetSpeed: ','$'
LEDCOD	DB	3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
BUF1		DW	?
BUF2 NUM1	
DB	DW	?
0
NUM2	DB	0
NUM3	DB	0
NUM4	DB	0
KEYS	DB	0
SAND	DW	0	;标准值
RESU	DW	0	;测得值
MINU	DW	0	;偏差值
REPL	DW	0	;显示值
REPG	DB	0	;显示值个位
REPS	DB	0	;显示值十位
ZFSIT	DB	0FFH	;D/A输出极性控制
K0B2	DW	0100H
K1B2	DW	0150H
K2B2	DW	0200H
K3B2	DW	0250H
K4B2	DW	0300H
K5B2	DW	0350H
DATA		ENDS


stacks segment stack db 256 dup(0)
stacks ends

CODE	SEGMENT
ASSUME	CS:CODE,DS:DATA, ss:stacks

START:		
MOV		AX,DATA 
MOV		DS,AX
MOV	DX,io8255k
MOV	AL,8AH	;A输出负责数码显示，B用于输入开关状态和输入 负责监控计时器是否计时完毕，C输出负责控制计数器工作，
OUT	DX,AL

MOV	DX,io8253k
MOV	AL,36h	;计数器0，方式3，先读写低8位，再读写高8位

OUT	DX,AL	;输入时钟，1MHZ MOV	DX,io82530
MOV	AX,50000	;初值50000，输出时钟周期50ms OUT	DX,AL
NOP
NOP
MOV	AL,AH
OUT	DX,AL

MOV DX,io8255k MOV AL,00H
OUT DX,AL	;C0(GATE1)低电平,定时器1禁止计数

MOV DX,offset mess MOV AH,09H
INT 21H	;显示提示信息

 
INTK:




位。
 

MOV	DX,io8253k
MOV	AL,70H
OUT	DX,AL	;计数器1，方式0，先读写低8位，再读写高8
 

MOV	DX,io82531	;输入时钟为光电开关输出。
MOV	AL,0ffH	
OUT NOP	DX,AL	;从FFFF到零，65536
NOP		
OUT	DX,AL	;高八位

MOV DX,io8253k MOV AL,90H
OUT DX,AL	;计数器2，方式0，只读写低8位,检测时间5秒

MOV DX,io82532 MOV AL,100D
OUT DX,AL	;r初值 100 ，检测 5 秒 50ms * 100 计数器 0 输出是计数器 2 的 CLK

MOV DX,io8255k MOV AL,01H
OUT DX,AL	;PC0输出1，定时器1开始计数

LOOPER: MOV AH,06H
MOV DL,0FFH
INT 21H	;判断输入按键




	JE


MOV	COUNTER


BL,AL	
	XOR	BL,73H	;判断是否有按键为s(标准值)
	JZ	SANREP	
	MOV XOR	BL,AL BL,72H	
;判断是否有按键为r(测得值)
	JZ	RESREP	
	JMP	EXPRO	
SANREP:	MOV MOV	AX,SAND DX,0000h	
	MOV	CX,000ah	;折算成0.5秒钟的电机转速
	DIV	CX	;这时转速应为一个2位数，存于AX中
	MOV	CL,10	
	DIV MOV	CL REPS,AL	;除10
;十位
 
MOV REPG,AH	;个位 JMP COUNTER

RESREP:		MOV AX,RESU MOV DX,0000h
MOV CX,000ah		;折算成0.5秒钟的电机转速  DIV CX	;这时转速应为一个2位数，存于AX中

MOV CL,10
DIV CL	;除10
MOV REPS,AL	;十位
MOV REPG,AH	;个位 JMP COUNTER

EXPRO:	MOV	AH,4CH
INT	21H	;退出程序

COUNTER:	MOV DX,io8255b IN	AL,DX
AND AL,80H
JZ	SWITMP	;8255 PB7是否为0,为零则计数未结束

FINISH:	MOV DX,io8255k MOV AL,00H
OUT DX,AL	;定时器1停止计数

MOV DX,io82531 IN	AL,DX
MOV BL,AL IN	AL,DX
MOV BH,AL	;16位计数值送BX MOV AX,0FFFFH
SUB AX,BX		;计算脉冲个数  MOV RESU,AX	;将脉冲值保存到resu中


CMP	AX,0000H
JZ	RED
CMP	AX,0200H
JB		GREEN	;脉冲小于0200H	，绿灯亮 MOV	DX,io8255k
MOV AL,05H	;C口位控，pc2为1，接黄灯 OUT	DX,AL
MOV AL,06H
OUT DX,AL MOV AL,02H OUT DX,AL JMP	LOOP2
RED:	MOV DX,io8255k
MOV AL,03H	;PC1为红灯
OUT DX,AL MOV AL,04H OUT DX,AL MOV AL,06H OUT DX,AL JMP	LOOP2

GREEN:	MOV DX,io8255k
MOV AL,07H	; PC3为绿灯
OUT DX,AL MOV AL,04H OUT DX,AL MOV AL,02H OUT DX,AL JMP	LOOP2

SWITMP:	JMP SWI	;SWI跳转过渡 LOOP2:
MOV	DX,io8255c
IN	AL,DX
TEST	AL,10H
JNZ NEXT1	;PC4开环检测 MOV DX,RESU
CMP DX,SAND JL	LESSTHAN CMP DX,SAND
JG	GREATERTHAN
NEXT1:	JMP NEXT
LOOPERTMP:	JMP LOOPER	;从DELAY跳转至LOOPER的过渡 LESSTHAN:	MOV BL,KEYS
TEST	BL,01H
JNZ	CL0
TEST	BL,02H
JNZ	CL1
TEST	BL,04H
 
JNZ	CL2
TEST	BL,08H
JNZ	CL3
TEST	BL,10H
JNZ	CL4
TEST	BL,20H
JNZ	CL5 JMP NEXT



CL0:		SUB K0B2,0010H JMP NEXT
CL1:		SUB K1B2,0010H JMP NEXT
CL2:		SUB K2B2,0010H JMP NEXT
CL3:		SUB K3B2,0010H JMP NEXT
CL4:		SUB K4B2,0010H JMP NEXT
CL5:		SUB K5B2,0010H JMP NEXT

GREATERTHAN:	MOV BL,KEYS TEST	BL,01H
JNZ	CG0
TEST	BL,02H
JNZ	CG1
TEST	BL,04H
JNZ	CG2
TEST	BL,08H
JNZ	CG3
TEST	BL,10H
JNZ	CG4
TEST	BL,20H
JNZ	CG5 JMP NEXT

CG0:		ADD K0B2,0010H JMP NEXT
CG1:		ADD K1B2,0010H JMP NEXT
CG2:	ADD K2B2,0010H
 

JMP NEXT
CG3:		ADD K3B2,0010H JMP NEXT
CG4:		ADD K4B2,0010H JMP NEXT
CG5:		ADD K5B2,0010H JMP NEXT


NEXT:		MOV DX,offset mess3 MOV AH,09H
INT 21H
;........................
MOV	AX,SAND
CALL	DISP	;显示标准值 MOV DL,0dh
MOV AH,02 INT 21h

MOV DX,offset mess2 MOV AH,09H
INT 21H
;........................
MOV	AX,RESU
CALL	DISP	;显示实际值 MOV DL,0ah
MOV AH,02 INT 21h JMP INTK

SWI:	MOV	DX,io8255b
IN		AL,DX	;8255b口为读取开关 MOV	KEYS,AL

 





SWIST:
 
TEST	AL,40H
JZ	SWIST	;无需反转则继续检测其他情况 MOV ZFSIT,0FFH
JMP SWISAND

MOV DX,io8255k
MOV AL,03H	;PC1为红灯
OUT DX,AL MOV AL,04H
 
OUT DX,AL MOV AL,06H OUT DX,AL
MOV ZFSIT,00H MOV	RESU,00H

SWISAND:		TEST	AL,01H JNZ		K0
TEST	AL,02H
JNZ	KK1TMP
TEST	AL,04H
JNZ	KK2TMP

TEST	AL,08H
JNZ	KK3TMP
TEST	AL,10H
JNZ	KK4TMP
TEST	AL,20H
JNZ	K5TMP
JMP	LOOPERTMP

K0:	MOV SAND,880	;假设标准
MOV	BUF2,0050H	;高电平延时的常数 MOV AX,K0B2
MOV	BUF1,AX	;低电平延时的常数

DELAY:		MOV	CX,BUF2 MOV	AL,ZFSIT
MOV	DX,io0832
OUT	DX,AL

DELAY1:	MOV AL,REPS
MOV BX,OFFSET LEDCOD XLAT
MOV DX,io8255a	; A口控制LED灯，低位 OUT DX,AL
MOV AL,REPG
MOV BX,OFFSET LEDCOD XLAT
OR	AL,80H
MOV DX,io8255a	; PA7为1，写高位 OUT DX,AL
LOOP	DELAY1 JMP TTMP
 

KK1TMP:	JMP K1
KK2TMP:	JMP K2
KK3TMP:	JMP K3
KK4TMP:	JMP K4

TTMP:		MOV		AL,80H MOV		DX,io0832
OUT	DX,AL
MOV	CX,BUF1

DELAY2:	MOV AL,REPS
MOV BX,OFFSET LEDCOD XLAT
MOV DX,io8255a OUT DX,AL
MOV AL,REPG
MOV BX,OFFSET LEDCOD XLAT
OR	AL,80H
MOV DX,io8255a OUT DX,AL
LOOP	DELAY2

JMP	LOOPERTMP

K5TMP:	JMP	K5	;跳转至K5的过渡

K1:	MOV	SAND,750	;假设标准
	MOV	BUF2,0050H	
	MOV	AX,K1B2	
	MOV	BUF1,AX	
	JMP	DELAY	
K2:	MOV	SAND,500	;假设标准
	MOV	BUF2,0050H	
	MOV	AX,K2B2	
	MOV JMP	BUF1,AX DELAY	
K3:	MOV	SAND,430	;假设标准
	MOV	BUF2,0050H	
	MOV MOV	AX,K3B2
BUF1,AX	
 
JMP	DELAY

K4:	MOV SAND,140	;假设标准 MOV	BUF2,0050H
MOV  AX,K4B2 MOV	BUF1,AX
JMP	DELAY

K5:	MOV SAND,110	;假设标准 MOV	BUF2,0050H
MOV  AX,K5B2 MOV	BUF1,AX
JMP	DELAY
DISP PROC NEAR	;BCD转换并显示子程序 MOV DX,0000h
MOV CX,000ah	;折算成0.5秒钟的电机转速
DIV CX	;这时转速应为一个2位数，存于AX中 MOV CL,10
DIV CL	;除10
MOV NUM3,AL	;十位
MOV NUM4,AH	;个位 MOV AL,NUM3
CALL	DISP1 MOV AL,NUM4 CALL	DISP1 RET

DISP ENDP

DISP1 PROC NEAR		;显示一个字符 AND	AL,0FH
CMP	AL,09H
JLE	NUM
ADD	AL,07H
NUM:	ADD	AL,30H MOV	DL,AL
MOV	AH,02
INT	21H
RET
DISP1 ENDP CODE ENDS END START
