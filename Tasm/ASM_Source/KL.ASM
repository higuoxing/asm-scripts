;386����΢������
;tasm4.1�����ϱ���
;*********************;
;* ������ʾ 8255LED  *;
;*********************;
 ioport	equ 0d400h-280H
 pa8255	equ ioport+288H	;8255�˿�,a��
 pc8255	equ ioport+28aH	;8255�˿�,c��
 p8255ctl	equ	ioport+28bH	;8255�˿�,���ƿ�
 PORTSEG	EQU ioport+2b1H	;����ܶ˿ڵ�ַ,�����ַ
 PORTBIT	EQU ioport+2b0H	;����ܶ˿ڵ�ַ,λ���ַ
data segment
TABLE1    DW 0101H,0201H,0401H,0801H,1001H,2001H,4001H,8001H
          DW 0102H,0202H,0402H,0802H,1002H,2002H,4002H,8002H
          DW 0104H,0204H,0404H,0804H,1004H,2004H,4004H,8004H		;����ɨ�����
 LED	DB 7FH,6FH,77H,7CH,39H,5EH,79H,71H,3FH,06H,5BH,4FH,66H,6DH,7DH,07H
        DB 67H,37H,73H,31H,3EH,36H,66H	;LED�����,89ABCDEF01234567GMPRWXY
 char  db '89ABCDEF01234567GMPRWXY '				;�ַ���
 CHAR1 DB 0FFH
 mes   db 0ah,0dh
       db 'PLAY ANY KEY IN THE SMALL KEYBOARD! ',0ah,0dh
       db 'IT WILL BE ON THE SCREEN! END WITH R or ANY KEY',0ah,0dh,'$'
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
	mov dx,offset mes	;��ʾ��ʾ��Ϣ
	mov ah,09
	int 21h
ky:
        call key                ;get a char in (dl) and display it
	mov ah,1
	int 16h
        jnz exit                ;��������˳�
	cmp dl,'R'
        jnz ky
exit:
        mov ax,4c00h            ;if (dl)='R' return to EXIT!
	int 21h			;�˳�

KEY	PROC NEAR
	PUSHA
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
        JZ KEY_EXIT             ;no key to EXIT
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
NN:	PUSH CX
        PUSH AX
        MOV AL,18H
        SUB AL,CL
        MOV [CHAR1],AL
        POP AX
        POP CX
        MOV DL,[DI]
	MOV AH,02H
	INT 21H			;��ʾ��ȡ���ַ�
     
KEY_DISP:
	CALL DISPLY		;��ʾ
key_exit:
	POPA
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
	PUSHA
	MOV BX,OFFSET LED
	MOV AL,[CHAR1]
	XLAT
	MOV DX,PORTSEG
	OUT DX,AL		;�����ʾ���ݣ�����
	MOV AL,01H
	MOV DX,PORTBIT
	MOV CX,0006		;������ʾ,6λ
DISPLY1:
	OUT DX,AL		;�����ʾ���ݣ�λ�룬����ʾ
	PUSH CX
        MOV CX,0A000H		;��ʾʱ���ӳ�
DISPLY_DELAY:
	LOOP DISPLY_DELAY
	POP CX
	SHL AL,1
	LOOP DISPLY1
	POPA
	RET
DISPLY	ENDP
code ends
end start