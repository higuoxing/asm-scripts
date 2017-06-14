;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;******************************;
;*      ������ʾ������        *;
;******************************;
int_vect	EQU	071H	;�ж�0-7������Ϊ:08h-0fh,�ж�8-15������Ϊ:70h-77h
irq_mask_2_7	equ	011111011b	;�ж�����,�ж�0-7ʱ�ӵ�������ӦλΪ��,�ж�8-15ʱ��2λΪ��
irq_mask_9_15	equ	011111101b	;�ж�0-7ʱȫһ,�ж�8-15ʱ�ӵ�������ӦλΪ��
ioport_data	equ	0d400h-280h	;tpc �����豸��io��ַ
ioport_cent     equ	0d800h	;tpc ����9054оƬ��io��ַ
INTA00  EQU     20H           ;8259A PORT���ڵ�ַ
INTA01  EQU     21H           ;8259A PORT���ڵ�ַ
INTA02	EQU	0A0H		;PC/AT �м�����8259A�ڵ�ַ
INTA03	EQU	0A1H		;PC/AT �м�����8259A�ڵ�ַ
PORT0   EQU     ioport_data+2B0H          ;8279 DATA PORT��8279���ݿ�
PORT1   EQU     ioport_data+2B1H          ;8279 CTRL PORT��8279���ƿ�
TIME0   EQU     ioport_data+280H          ;8253 TIME0 PORT��8253��ʱ��0�ڵ�ַ
TIME1   EQU     ioport_data+281H          ;8253 TIME1 PORT��8253��ʱ��1�ڵ�ַ
TIMEC   EQU     ioport_data+283H          ;8253 CTRL PORT��8253���ƿڵ�ַ

STACKS   SEGMENT STACK
STA             DW 512 DUP(?)
TOP     EQU     LENGTH STA
STACKS   ENDS

DATA            SEGMENT
csreg		dw	?
ipreg		dw	?
irq_times	dw	00h
BUF             DB      0             ;COUNT��������Ԫ
SIGN            DB      0             ;FLAGE��������־
SEC1            DB      0             ;HOUR HIGHT�����λ
SEC2            DB      0             ;HOUP LOW�����λ
MIN1            DB      0             ;MIN  HIGHT���ָ�λ
MIN2            DB      0             ;MIN LOW���ֵ�λ
HOUR1           DB      0             ;SEC HIGHT��ʱ��λ
HOUR2           DB      0             ;SEC LOW��ʱ��λ
ERR1            DB      0             ;ERROR FLAGE��������־
HMS             DB      0             ;00 IS HOUR,11 IS MIN,22 IS SEC��Ԥ��ʱ���֡����־
LED             DB 3FH,06,5BH,4FH,66H,6DH,7DH,07,7FH,6FH,79H,40H
MES             DB 'PLEAS FIRST CREATE THE IRQ PULSE!',0AH,0DH,0AH,0DH
		DB 'IN SMALL KEYBORD:',0AH,0DH
		DB 'C--CLEAR TO ZERO;  G--GO AHEAD',0AH,0DH
		DB 'D--STOP THE DISPLY;E--EXIT',0AH,0DH
		DB 'P--POSITION THE BEGINNING TIME',0AH,0DH,'$'
DATA            ENDS

CODE    SEGMENT
MAIN            PROC    FAR
	ASSUME  CS:CODE,DS:DATA,SS:STACKS,ES:DATA
START:          CLI
		MOV     AX,DATA
		MOV     DS,AX
		mov     buf,0
		mov     sign,01
		mov     sec1,0
		mov     sec2,0
		mov     min1,0
		mov     min2,0
		mov     hour1,0
		mov     hour2,0
		mov     err1,0
		MOV     DX,TIMEC	;8253��ʼ��
		MOV     AL,36H
		OUT     DX,AL
		MOV     DX,TIME0
		MOV     AX,1000
		OUT     DX,AL
		MOV     AL,AH
		OUT     DX,AL
		MOV     DX,TIMEC
		MOV     AL, 74H
		OUT     DX,AL
		MOV     AX,100
		MOV     DX,TIME1	;��ʱ��1ÿ0.1���ж�һ��
		OUT     DX,AL
		MOV     AL,AH
		OUT     DX,AL
		MOV     AX,STACKS
		MOV     SS,AX
		MOV     SP,TOP
		MOV     AX,DATA
		MOV     DS,AX
		MOV	ES,AX
		MOV     DX,OFFSET MES
		MOV     AH,09
		INT     21H

	        mov dx,ioport_cent+68h  ;���� tpc ����9054оƬio��,ʹ���ж�
        	in ax,dx
	        or ax,0900h
        	out dx,ax

	        mov al,int_vect         ;����ԭ�ж�����
		mov ah,35h
	        int 21h
		mov ax,es
		mov csreg,ax
		mov ipreg,bx

		MOV     AX,CS
		MOV     DS,AX
		MOV     DX,OFFSET INT_PROC
		MOV	AL,int_vect
		MOV     AH,25H
		INT     21H                           ;�������ж�����

		MOV     DX,INTA01                     ;�����ж�����
		IN      AL,DX
		AND     AL,irq_mask_2_7
		OUT     DX,AL
		MOV	DX,INTA03
		IN	AL,DX
		AND	AL,irq_mask_9_15
		OUT	DX,AL

		MOV     DX,PORT1
		MOV     AL,0D3H
		OUT     DX,AL                          ;8279 CLEAR,����
		MOV     AL,2AH
		OUT     DX,AL                          ;8279 CLOCK����ʱ������
		MOV     AL,40H
		OUT     DX,AL                          ;READ FIFO RAM COMMAND����FIFO RAM����
		MOV     AL,00H
		OUT     DX,AL                          ;KEYBORD DISPLY MODE���ü�����ʾģʽ
		MOV     AL,80H
		OUT     DX,AL                          ;WRITE RAM COMMAND��дRAM����
		STI
KEY1:
		CALL    KEY2                        ;CALL KEYBORD AND DISPLY����������ʾ������
		CMP     HOUR2,0AH                         ;ERR FLAGE
		JZ      NEXT2
NEXT1:          CMP     AL,0CH                            ;'C' COMMAND����C�������
		JNZ     LP0
NEXT2:          MOV     SIGN,00H
		MOV     HOUR2,00H
		MOV     HOUR1,00H
		MOV     MIN2,00H
		MOV     MIN1,00H
		MOV     SEC2,00H
		MOV     SEC1,00H
LP0:            CMP     AL,0EH                             ;'E' COMMAND����E�������˳�����
		JNZ     LP1
		MOV     SIGN,00H
                JMP     EXIT

LP1:            CMP     AL,10H                              ;'G' COMMAND����G�������
		JNZ     LP2
		MOV     SIGN,01H
		JMP     KEY1
LP2:            CMP     AL,0DH                              ;'D' COMMAND����D�������
		JNZ     SETI
		MOV     SIGN,00H
KEY3:           JMP     KEY1
SETI:           CMP     AL,12H                              ;'P' COMMAND����P�������
		JNZ     KEY1
		MOV     SIGN,00H                            ;ADD 1 FLAGE����00��ΪԤ��ʱ��־
		MOV     HMS,00H                             ;HOUR FLAGE
		CALL    HIGH0
		CMP     ERR1,01H
		JZ      KEY3
		CALL    LOW0
		CMP     ERR1,01H
		JZ      KEY3
		MOV     HMS,11H                             ;MIN FLAGE����11��ΪԤ�÷ֱ�־
		CALL    HIGH0
		CMP     ERR1,01H
		JZ      KEY3
		CALL    LOW0
		CMP     ERR1,01H
		JZ      KEY3
		MOV     HMS,22H                             ;SEC FLAGE����22��ΪԤ�����־
		CALL    HIGH0
		CMP     ERR1,01H
		JZ      KEY3
		CALL    LOW0
		JMP     KEY1

EXIT:
		CLI
	        mov     bl, irq_mask_2_7        ;�ָ��ж�����
		not	bl
		mov	dx,INTA01
		in	al, dx
		or	al, bl
		out	dx, al
		mov	bl, irq_mask_9_15
		not	bl
		mov	dx, INTA03
		in	al, dx
		or	al, bl
		out	dx, al

	        mov dx,ipreg                    ;�ָ�ԭ�ж�����
		mov ax,csreg
		mov ds,ax
		mov ah,25h
		mov al,int_vect
        	int 21h

	        mov dx,ioport_cent+68h          ;���� tpc ����9054оƬio��,�ر��ж�
		in  ax,dx
	        and ax,0f7ffh
		out dx,ax

		MOV     AX,4C00H                ;�˳�����
		INT     21H
MAIN            ENDP

INT_PROC	PROC	FAR
		CLI
		PUSH    AX
		PUSH    BX
		PUSH    CX
		PUSH    DX
		PUSH    SI
		PUSH    DI
		PUSH    DS
		CMP     SIGN,00                    ;SIGN IS ADD 1 FLAGE���Ƿ���������
		JZ	ENDT1
		INC     BUF                        ;BUF IS COUNT��������Ԫ��һ
		CMP     BUF,10
		JL      ENDT
		MOV     BUF,0
		INC     SEC1
		CMP     SEC1,10
		JL      ENDT
		MOV     SEC1,0
		INC     SEC2
		CMP     SEC2,6
		JL      ENDT
		MOV     SEC2,0
		INC     MIN1
		CMP     MIN1,10
		JL      ENDT
		MOV     MIN1,0
		INC     MIN2
		CMP     MIN2,6
		JL      ENDT
		MOV     MIN2,0
		INC     HOUR1
		CMP     HOUR2,2
		JL      HH
		CMP     HOUR1,4
		JL      ENDT
		MOV     HOUR1,0
		MOV     HOUR2,0
endt1:          JMP     ENDT
HH:             CMP     HOUR1,10
		JL      ENDT
		MOV     HOUR1,0
		INC     HOUR2

ENDT:
                MOV     DX,INTA02               ;Send EOI
		MOV     AL,20H
		OUT     DX,AL
                MOV     DX,INTA00
		OUT	DX,AL
                mov     cx,0ffffh
loopx:
                nop
                loop    loopx                      ;��ʱ

		POP     DS
		POP     DI
		POP     SI
		POP     DX
		POP     CX
		POP     BX
		POP     AX
		STI
		IRET
INT_PROC	ENDP

KEY2            PROC    NEAR
		MOV     DX,PORT1
		MOV     AL,0D1H
		OUT     DX,AL                        ;CLEAR DISPLAY������ʾ
WREP:           CALL    DISP			;����ʾ�ӳ���
		MOV     DX,PORT1
		IN      AL,DX
		AND     AL,07H
		JZ      WREP
KEYN:           MOV     DX,PORT0		;��״̬
		IN      AL,DX
		MOV     BL,AL
		AND     AL,07H
		AND     BL,38H
		MOV     CL,03
		SHR     BL,CL
		CMP     BL,00H			;�Ƿ��һ�м�
		JNZ     LINE1
		ADD     AL,08H
		JMP     QUIT1
LINE1:          CMP     BL,01H
		JNZ     LINE2			;�Ƿ�ڶ��м�
		JMP     QUIT1
LINE2:          ADD     AL,10H
QUIT1:          RET
KEY2            ENDP

DISP            PROC    NEAR
		PUSH    CX
		MOV     AX,DATA
		MOV     DS,AX
		MOV     DX,PORT1
		MOV     AL,90H
		OUT     DX,AL
		MOV     SI,OFFSET SEC1
		MOV     CX,0006
		MOV     BX,OFFSET LED
DISP1:          CLD
		LODSB
		XLAT
		MOV     DX,PORT0
		OUT     DX,AL
		LOOP    DISP1
		POP     CX
		RET
DISP            ENDP

ERRS            PROC    NEAR
		MOV     HOUR2,0AH
		MOV     HOUR1,0BH                          ;ERROR
		MOV     MIN2,0BH                           ;DISPLY 'E-----'����ʾ������־
		MOV     MIN1,0BH
		MOV     SEC2,0BH
		MOV     SEC1,0BH
		MOV     ERR1,01H                           ;ERR FLAGE����ǳ���
		RET
ERRS            ENDP

HIGH0           PROC    NEAR
		CALL    KEY2
		MOV     ERR1,00
		CMP     HMS,00H                  ;HMS IS HOUR MIN SC FLAGE��Ԥ��ʱ���֡���
		JNZ     MIN0
		CMP     AL,02H                   ;00 IS HOUR��Ԥ��ʱ
		JG      ERROR                    ;11 IS MIN��Ԥ�÷�
		MOV     HOUR2,AL                 ;22 IS SEC��Ԥ����
		JMP     HQUT1
MIN0:           CMP     HMS,11H
		JNZ     SEC0
		CMP     AL,05H
		JG      ERROR
		MOV     MIN2,AL
		JMP     HQUT1
SEC0:
		CMP     AL,05H
		JG      ERROR
		MOV     SEC2,AL
HQUT1:          RET 

ERROR:          CALL    ERRS
		RET
HIGH0           ENDP

LOW0            PROC    NEAR
		CALL     KEY2                    ;GET HOUR MIN SEC LOW��Ԥ��ʱ���֡����λ
		MOV     ERR1,00
		CMP      HMS,00H
		JNZ      MIN3
		MOV      DL,HOUR2
		CMP      DL,01
		JG       HOUR3
		CMP      AL,09H
		JG       ERROR
		MOV      HOUR1,AL
		JMP      LQUT1
HOUR3:          
		CMP      AL,03H 
		JG       ERROR
		MOV      HOUR1,AL
		JMP      LQUT1
MIN3:           CMP      HMS,11H
		JNZ      SEC3
		CMP      AL,09H
		JG       ERROR
		MOV      MIN1,AL
		JMP      LQUT1
SEC3:           
		CMP      AL,09H
		JG       ERROR
		MOV      SEC1,AL
LQUT1:          RET
LOW0            ENDP

CODE            ENDS
END             START