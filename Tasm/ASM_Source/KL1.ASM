;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;*********************;
;* ������ʾ 8255LED1 *;
;*********************;
 ioport	equ 0d400h-280H
 pa8255	equ ioport+288H	;8255�˿�,a��
 pc8255	equ ioport+28aH	;8255�˿�,c��
 p8255ctl	equ	ioport+28bH	;8255�˿�,���ƿ�
 TIM_CTL	EQU ioport+283H	;8253�˿ڵ�ַ,���ƶ˿�
 TIMER0		EQU ioport+280H
 TIMER1		EQU ioport+281H
 MODE03		EQU 36H		;8253�˿�����
 MODE12		EQU 74H
 PORTSEG	EQU ioport+2b1H	;����ܶ˿ڵ�ַ,�����ַ
 PORTBIT	EQU ioport+2b0H	;����ܶ˿ڵ�ַ,λ���ַ
 int_vect	EQU	071H		;�ж�0-7������Ϊ:08h-0fh,�ж�8-15������Ϊ:70h-77h
 irq_mask_2_7	equ	011111011b	;�ж�����,�ж�0-7ʱ�ӵ�������ӦλΪ��,�ж�8-15ʱ��2λΪ��
 irq_mask_9_15	equ	011111101b	;�ж�0-7ʱȫһ,�ж�8-15ʱ�ӵ�������ӦλΪ��
 ioport_data	equ	0d400h-280h	;tpc �����豸��io��ַ
 ioport_cent	equ	0d800h		;tpc ����9054оƬ��io��ַ
data segment
 csreg	dw	?
 ipreg	dw	?	;���ж���������ռ�
 MESS	 DB	   '8253A TIMER0 IN MODE3! COUNT=0400H',0AH,0DH
         DB        '8253A TIMER1 IN MODE2! COUNT=0400H',0AH,0DH,'$'
YEAR1     DB 00H,00H,00H,01H,00H,01H
MONTH3    DB 0
DAY3      DB 0
CHAR1     DB 0FFH
INTMASK   DB ?
LED       DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,40H,79H,00H	;LED�������1,2,3,4,5,6,7,8,9,0,-,E,
TABLE1    DW 0101H,0201H,0401H,0801H,1001H,2001H,4001H,8001H
          DW 0102H,0202H,0402H,0802H,1002H,2002H,4002H,8002H
          DW 0104H,0204H,0404H,0804H,1004H,2004H,4004H,8004H		;����ɨ�����
CHAR      DB '89ABCDEF01234567GMPRWXY '					;�ַ���
MAXDAY    DB 00H,1FH,1CH,1FH,1EH,1FH,1EH,1FH,1FH,1EH,1FH,1EH,1FH	;ʮ�����µ�����
MES       DB 'IN SMALL KEYBOARD',0AH,0DH
          DB 'C--DISPLAY 1, JAN, 93 ;  G--GO AHEAD',0AH,0DH
          DB 'D--STOP TO DISPLAY  ;    E--EXIT',0AH,0DH
          DB 'P--POSITION THE BENINNING DATE',0AH,0DH,'$'
data ends
stacks segment stack	;��ջ�ռ�
 db 100 dup (?)
stacks ends
code segment
        assume cs:code,ds:data,ss:stacks,es:data
start:
;Enable Local Interrupt Input
.386
        cli
        mov ax,data
        mov ds,ax
        mov es,ax
        mov ax,stacks
        mov ss,ax
	MOV DX,OFFSET MES
	MOV AH,09
	INT 21H

	MOV DX,TIM_CTL		;��ʼ��8253
	MOV AL,MODE03
	OUT DX,AL
	MOV DX,TIMER0		;��ʼ��������0
	MOV AL,00h
	OUT DX,AL
        MOV AL,04H
	OUT DX,AL
	MOV DX,TIM_CTL		;���������ֵ��0400h��1024��Ƶ
	MOV AL,MODE12
	OUT DX,AL
	MOV DX,TIMER1		;��ʼ��������1
        MOV AL,00H
	OUT DX,AL
        MOV AL,04H
	OUT DX,AL		;���������ֵ��0400h��1024��Ƶ

	mov dx,ioport_cent	;���� tpc ����9054оƬio��,ʹ���ж�
        add dx,068h
        in ax,dx
        or ax,0900h
        out dx,ax

	mov al,int_vect		;����ԭ�ж�����
	mov ah,35h
        int 21h
	mov ax,es
	mov csreg,ax
	mov ipreg,bx

        mov al,int_vect		;�������ж�����
        mov cx,cs
        mov ds,cx
	mov dx,offset int_proc
	mov ah,25h
        int 21h

	mov ax,data
	mov ds,ax
	mov es,ax
        in al, 21h		;�����ж�����
	mov ah,irq_mask_2_7
	and al,ah
        out 21h, al
        in al, 0a1h
	mov ah,irq_mask_9_15
	and al,ah
        out 0a1h, al
	sti			;���ж�
LKEY:
	mov ah,06h		;�ж��Ƿ��м�����
	mov dl,0ffh
	int 21h
	jnz main_exit		;������ת
	CALL KEY		;��ȡ����ֵ
	MOV DL,[CHAR1]		;ȡ����ȡ���ַ�
	CMP DL,'C'
	JNZ LGY
        CALL CPRO               ;��ʼ����������
	JMP LKEY
LGY:	CMP DL,'G'
	JNZ LDY
	CALL GPRO		;��ʼ��ʱ����
	JMP LKEY
LDY:	CMP DL,'D'
	JNZ LPY
        CALL DPRO               ;ֹͣ��ʱ����
	JMP LKEY
LPY:	CMP DL,'P'
	JNZ LEY
	CALL PPRO		;������������
	JMP LKEY
LEY:	CMP DL,'E'
        JNZ LKEY                ;�˳���������

main_exit:
	cli
	mov ah,irq_mask_2_7	;�ָ��ж�����
	not ah
	in al,21h
	or al,ah
	out 21h,al
	mov ah,irq_mask_9_15
	not ah
	in al,0a1h
	or al,ah
	out 0a1h,al

	mov al,int_vect		;�ָ�ԭ�ж�����
        mov dx,ipreg
	mov cx,csreg
	mov ds,cx
	mov ah,25h
        int 21h

	mov ax,data		;���� tpc ����9054оƬio��,�ر��ж�
        mov ds,ax
	mov dx,ioport_cent
        add dx,068h
	in ax,dx
        and ax,0f7ffh
	out dx,ax

	mov ax,4c00h
	int 21h			;�˳�

int_proc proc far
        cli
        pusha
        push ds
        mov ax,data             ;Interrupt to do
        mov ds,ax
        MOV AX,WORD PTR [YEAR1]
        CMP AX,0A0BH
        JNZ INT_PROC_NEXT
        CALL CPRO
INT_PROC_NEXT:
	MOV BX,OFFSET MAXDAY	;ʮ�����µ������洢��ַ
	MOV DI,OFFSET YEAR1	;���ڴ洢��ַ
	MOV AL,[DI+2]
	MOV AH,0AH
	MUL AH
	ADD AL,[DI+3]
	PUSH AX
	XLAT
	PUSH AX
	MOV AL,[DI+4]
	MOV AH,0AH
	MUL AH
	ADD AL,[DI+5]
	POP SI
	CMP SI,AX
	JZ PPP
	POP AX
	INC BYTE PTR [DI+5]
	CMP BYTE PTR [DI+5],0AH
	JNZ DDD
	MOV BYTE PTR [DI+5],00H		;���ڵĸ�λ�������Ƚϡ����
	INC BYTE PTR [DI+4]
	JMP DDD
PPP:	MOV WORD PTR [DI+4],0100H
	POP AX
	CMP AX,000CH
	JNZ CCC
	MOV WORD PTR [DI+2],0100H
	INC BYTE PTR [DI+1] 
	CMP BYTE PTR [DI+1],0AH
	JNZ DDD
	MOV BYTE PTR [DI+1],00H		;��ݵĸ�λ�������Ƚϡ����
	INC BYTE PTR [DI]
	CMP BYTE PTR [DI],0AH
	JNZ DDD
	MOV BYTE PTR [DI],00H		;��ݵ�ʮλ�������Ƚϡ����
	JMP DDD
CCC:	INC BYTE PTR [DI+3]
	CMP BYTE PTR [DI+3],0AH
	JNZ DDD
	MOV BYTE PTR [DI+3],00H		;�·ݵĸ�λ�������Ƚϡ����
	INC BYTE PTR [DI+2]
DDD:
	mov al,20h              ;Send EOI
	out 0a0h,al
        mov cx,0ffffh
loopx1: loop loopx1             ;��ʱ
	out 20h,al
        mov cx,0ffffh
loopx:  loop loopx              ;��ʱ
	pop ds
        popa
        sti
        iret
int_proc endp

KEY	PROC NEAR
	PUSH CX
	MOV AL,010000011b
	MOV DX,P8255CTL
	OUT DX,AL               ;set command word of 8255a
	                        ;port a for output,port c for input
	MOV AL,00H
	MOV DX,PA8255
	OUT DX,AL               ;port a output 00
	MOV DX,PC8255
	IN AL,DX                ;get col data from port c
	OR AL,0F8H		;���θ�5λ����Ϊ1
	CMP AL,0FFH
        JZ KEY_disp             ;no key to display
        call delay		;delay for amoment
	MOV CL,08H		;ɨ�����룬8��
	MOV AH,0FEH
SCAN1:
	MOV DX,PA8255
	MOV AL,AH
	OUT DX,AL               ;port a output
	MOV DX,PC8255
	IN AL,DX                ;get col data from port c
	OR AL,0F8H		;���θ�5λ����Ϊ1
	CMP AL,0FFH
	JNZ KEYN
	ROL AH,1
	DEC CL
	JNZ SCAN1
	JMP key_exit		;δ���ְ�������
KEYN:	PUSH AX
	MOV DX,PC8255
RELEA:	IN AL,DX                ;get col data from port c
	OR AL,0F8H		;���θ�5λ����Ϊ1
	CMP AL,0FFH
	JNZ RELEA		;�ȴ�����̧��
	POP AX
	NOT AX
	MOV SI,OFFSET TABLE1	;����ɨ�������ַ
	MOV DI,OFFSET CHAR	;�ַ�����ַ
	MOV CX,24		;������ı���С
TT:	CMP AX,[SI]		;cmp (col,row) with every word
	JZ NN			;in the table
	DEC CX
	JZ key_exit		;δ�ҵ���Ӧɨ����
	ADD SI,02
	INC DI
	JMP TT			;����һ���
NN:	MOV DL,[DI]
	MOV [CHAR1],DL		;�����ȡ���ַ�
	MOV AH,02H
	INT 21H			;��ʾ��ȡ���ַ�
        JMP KEY_EXIT
KEY_DISP:
	CALL DISPLY		;��ʾ
key_exit:
	POP CX
	RET
KEY	ENDP

delay proc near
        pusha           ;delay 50ms--100ms
        pushf
        mov ah,0
        int 1ah
        mov bx,dx
delay1:
	mov ah,0
	int 1ah
	cmp bx,dx
	jz delay1
	mov bx,dx
delay2:
	mov ah,0
	int 1ah
	cmp bx,dx
	jz delay2
        popf
        popa
        ret
delay endp

DISPLY	PROC NEAR
	PUSH CX
	MOV BX,OFFSET LED
	MOV CX,0006		;������ʾ,6λ
	MOV SI,OFFSET YEAR1
	MOV AH,01H
DISPLY1:
	CLD
	LODSB
	XLAT
	MOV DX,PORTSEG
	OUT DX,AL
	MOV AL,AH
	MOV DX,PORTBIT
	OUT DX,AL
	SHL AH,1
	MOV AL,00
	OUT DX,AL
	LOOP DISPLY1
	POP CX
	RET
DISPLY	ENDP

CPRO	PROC NEAR
	CLI
	MOV WORD PTR [YEAR1],0400H
	MOV WORD PTR [YEAR1+2],0100H
	MOV WORD PTR [YEAR1+4],0100H
	RET
CPRO	ENDP

GPRO	PROC NEAR
        STI
	RET
GPRO	ENDP

DPRO	PROC NEAR
	CLI
	RET
DPRO	ENDP

PPRO	PROC NEAR
	CLI
	PUSH AX
	PUSH BX
	MOV WORD PTR [YEAR1],0C0CH
	MOV WORD PTR [YEAR1+2],0C0CH
	MOV WORD PTR [YEAR1+4],0C0CH	;����ֵ���
	CALL DISPLY			;��ʾ
	MOV [CHAR1],0FFH		;����ֵ�洢������ֵ
ppro_key1:
	CALL KEY			;��ȡ����ֵ����ݵ�ʮλ
	cmp [CHAR1],0FFH
	jz ppro_key1			;û�а���������ת
	MOV DL,[CHAR1]
	CMP DL,'9'
	JNG NEXT1
	JMP ERR1
NEXT1:	SUB DL,30H
	MOV [YEAR1],DL
	CALL DISPLY
	MOV [CHAR1],0FFH		;����ֵ�洢������ֵ
ppro_key2:
	CALL KEY			;��ȡ����ֵ����ݵĸ�λ
	cmp [CHAR1],0FFH
	jz ppro_key2			;û�а���������ת
	MOV DL,[CHAR1]
	CMP DL,'9'
	JNG NEXT2
	JMP ERR1
NEXT2:	SUB DL,30H
	MOV [YEAR1+1],DL
	CALL DISPLY
	MOV [CHAR1],0FFH		;����ֵ�洢������ֵ
ppro_key3:
	CALL KEY			;��ȡ����ֵ���·ݵ�ʮλ
	cmp [CHAR1],0FFH
	jz ppro_key3			;û�а���������ת
	MOV DL,[CHAR1]
	CMP DL,'1'
	JNG NEXT3
	JMP ERR1
NEXT3:	SUB DL,30H
	MOV [YEAR1+2],DL
	CALL DISPLY
	MOV [CHAR1],0FFH		;����ֵ�洢������ֵ
ppro_key4:
	CALL KEY			;��ȡ����ֵ���·ݵĸ�λ
	cmp [CHAR1],0FFH
	jz ppro_key4			;û�а���������ת
	MOV DL,[CHAR1]
	CMP DL,'9'
	JNG NEXT4
	JMP ERR1
NEXT4:	SUB DL,30H
	MOV AL,[YEAR1+2]
	MOV AH,0AH
	MUL AH
	ADD AL,DL
	MOV [MONTH3],AL
	CMP AL,0CH
	JG ERR1
	CMP AL,00
	JZ ERR1
	MOV [YEAR1+3],DL
	CALL DISPLY
	MOV [CHAR1],0FFH		;����ֵ�洢������ֵ
ppro_key5:
	CALL KEY			;��ȡ����ֵ�����ڵ�ʮλ
	cmp [CHAR1],0FFH
	jz ppro_key5			;û�а���������ת
	MOV DL,[CHAR1] 
	CMP DL,'3'
	JG ERR1
	SUB DL,30H
	MOV AL,[MONTH3]
	CMP AL,02
	JZ PPRO1
	MOV [YEAR1+4],DL
	CALL DISPLY
	JMP PPRO2
PPRO1:	CMP DL,02
	JG ERR1
	MOV [YEAR1+4],DL
	CALL DISPLY
PPRO2:	MOV AL,[MONTH3]
	MOV BX,OFFSET MAXDAY
	XLAT
	MOV [DAY3],AL
	MOV [CHAR1],0FFH		;����ֵ�洢������ֵ
ppro_key6:
	CALL KEY			;��ȡ����ֵ�����ڵĸ�λ
	cmp [CHAR1],0FFH
	jz ppro_key6			;û�а���������ת
	MOV DL,[CHAR1]
	CMP DL,'9'
	JG ERR1
	SUB DL,30H
	MOV AL,[YEAR1+4]
	MOV AH,0AH
	MUL AH
	ADD AL,DL
	CMP AL,[DAY3]
	JG ERR1
	MOV [YEAR1+5],DL
	CALL DISPLY
	JMP WW
ERR1:	MOV WORD PTR [YEAR1],0A0BH
	MOV WORD PTR [YEAR1+2],0A0AH
	MOV WORD PTR [YEAR1+4],0A0AH
	CALL DISPLY
WW:	POP BX
	POP AX
	RET
PPRO	ENDP
code ends
end start