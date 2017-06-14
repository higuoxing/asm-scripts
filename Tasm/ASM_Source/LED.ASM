;386����΢������
;tasm4.1�����ϱ���
;****************************;
;* LED��λ������ʾʵ��(I/O) *;
;****************************;
 ioport	equ 0d400h-280H
 PORTSEG	EQU ioport+2b1H	;����ܶ˿ڵ�ַ,�����ַ
 PORTBIT	EQU ioport+2b0H	;����ܶ˿ڵ�ַ,λ���ַ
data segment
 BIT6     DB        0   ;1����ʾ����
 BIT5     DB        0   ;2����ʾ����
 BIT4     DB        0   ;3����ʾ����
 BIT3     DB        0   ;4����ʾ����
 BIT2     DB        0   ;5����ʾ����
 BIT1     DB        0   ;6����ʾ����
 LED      DB        3FH,06,5BH,4FH,66H,6DH,7DH,07,7FH,6FH   ;LED�������1,2,3,4,5,6,7,8,9,0
 MES      DB        'DISPLAY THE LEDS,PRESS ANY KEY TO EXIT!',0AH,0DH,'$'
data ends
stacks segment stack	;��ջ�ռ�
 db 100 dup (?)
stacks ends
code segment
        assume cs:code,ds:data,ss:stacks,es:data
start:
.386
        cli
        mov ax,data
        mov ds,ax
        mov es,ax
        mov ax,stacks
        mov ss,ax
	MOV  DX,OFFSET MES	;��ʾ��ʾ
	MOV  AH,09
	INT  21H
loop1:
	call DISP_proc		;������ʾ����
	mov ah,1
	int 16h
        jz loop1                ;��������˳�
	mov ax,4c00h
	int 21h		;�˳�

DISP_proc proc near
	pusha
	push ds		;����Ĵ���ֵ
	MOV       AX,DATA
	MOV       DS,AX
        MOV       DI,OFFSET BIT6        ;��ȡ��ʾ����ʼ��ַ
	MOV       CL,01			;������ʾλ��
DIS1:   MOV       AL,[DI]		;��ȡ��ʾ����
	MOV       BX,OFFSET LED		;��ȡ�������ʼ��ַ
	XLAT				;��ȡ����ʾ���ֵĶ���
	MOV  DX,PORTSEG
        OUT       DX,AL		;�����ʾ���ݣ�����
        MOV       AL,CL
        MOV  DX,PORTBIT
	OUT       DX,AL		;�����ʾ���ݣ�λ�룬����ʾ
	PUSH      CX
        MOV       CX,0A000H     ;��ʾʱ���ӳ�
DELAY:  LOOP      DELAY
	POP       CX
        CMP       CL,020H	;������ʾ���,6λ
	JZ        CHG
	INC       DI
	SHL       CL,1
	MOV       AL,00
	OUT       DX,AL		;�ر���ʾ
	JMP       DIS1		;��ʾ��һ����
CHG:    INC       BIT1		;1����������
	CMP       BIT1,10	;��λ��
	JL        QUIT		;����λ���˳�
	MOV       BIT1,0	;��λ��1����������
	INC       BIT2		;��λ��2����������
	CMP       BIT2,10
	JL        QUIT
	MOV       BIT2,0	;��λ��2����������
	INC       BIT3		;��λ��3����������
	CMP       BIT3,10
	JL        QUIT
	MOV       BIT3,0	;��λ��3����������
	INC       BIT4		;��λ��4����������
	CMP       BIT4,10
	JL        QUIT
	MOV       BIT4,0	;��λ��4����������
	INC       BIT5		;��λ��5����������
	CMP       BIT5,10
	JL        QUIT
	MOV       BIT5,0	;��λ��5����������
	INC       BIT6		;��λ��6����������
	CMP       BIT6,10
	JL        QUIT
	MOV       BIT6,0	;��λ��6����������	
QUIT:
        MOV  DX,PORTBIT
        MOV       AL,00
        OUT       DX,AL		;�ر���ʾ
        pop ds
	popa			;�ָ��Ĵ���ֵ
	ret
DISP_proc endp
code ends
end start