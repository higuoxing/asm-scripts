;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;**********************;
;* �ַ�Һ����ʾʵ��1  *;
;**********************;
 ioport		equ 0d400h-0280h
 chlcdctlport	equ ioport+2b0H	;�ַ�lcdָ��˿ڵ�ַ
 chlcddataport	equ ioport+2b1H	;�ַ�lcd���ݶ˿ڵ�ַ
data segment
 mes2  db 0ah,0dh,'DISPLAY USERLIB CHAR TO LCD !',0ah,0dh,'$'
 userlib   DB  08H,0FH,12H,0FH,0AH,1FH,02H,02H		;"��"����=00H
           DB  0FH,09H,0FH,09H,0FH,09H,11H,00H		;"��"����=01H
           DB  1FH,11H,11H,1FH,11H,11H,1FH,00H		;"��"����=02H
           DB  11H,0AH,04H,1FH,04H,1FH,04H,00H		;"$"����=03H
           DB  0EH,00H,1FH,0AH,0AH,0AH,13H,00H		;"Ԫ"����=04H
           DB  18H,18H,07H,08H,08H,08H,07H,00H		;"��"����=05H
           DB  04H,0AH,15H,04H,04H,04H,04H,00H		;"��"����=06H
           DB  17H,15H,15H,15H,15H,15H,17H,00H		;"10"����=07H
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
        call char_lcd_reset	;��λ����ʼ��
	call char_lcd_userlib	;��ʾ�Զ����ַ�
        mov ax,4c00h
	int 21h			;�˳�

char_lcd_reset proc near	;��λ����ʼ��
	mov bl,00110000B
	call chlcd_write_ctr
	call delay2
	mov bl,00110000B
	call chlcd_write_ctr
	call delay2
	mov bl,00110000B
	call chlcd_write_ctr
	call delay2
	mov bl,00111100B
	call chlcd_write_ctr	;�������ã�������ʽ���ã���ʼ����
	mov bl,00000001B
	call chlcd_write_ctr	;����,��DDRAM,AC
	mov bl,00000110B
	call chlcd_write_ctr	;���뷽ʽ���ã���ꡢ�����ƶ���ʽ
	mov bl,00000010B
	call chlcd_write_ctr	;�����飩λ,AC=0,��ꡢ�����HOMEλ
	mov bl,00001111B
	call chlcd_write_ctr	;��ʾ���ؿ��ƣ���
	ret
char_lcd_reset endp

char_lcd_userlib proc near
	mov dx,offset mes2	;��ʾ��ʾ��Ϣ
	mov ah,09
	int 21h

	mov bl,01000000B
	call chlcd_write_ctr	;����CGRAM��ַ
	mov si,offset userlib
	mov cx,64
char_lcd_userlib_loop1:
	mov bl,byte ptr [si]
	call chlcd_write_data	;��CGRAMд�Զ����ַ���������
	inc si
	loop char_lcd_userlib_loop1

	mov bl,10000000B
	call chlcd_write_ctr	;���õ�һ��DDRAM��ַ
	mov cx,16
	mov bl,0h
char_lcd_userlib_loop:
	call chlcd_write_data	;���һ��DDRAMд�Զ����ַ�����
	inc bl
	loop char_lcd_userlib_loop

	ret
char_lcd_userlib endp

chlcd_write_ctr proc near	;��lcdд��������(bl)
	pusha
	pushf
	MOV DX,chlcdctlport
	mov al,bl
	out dx,al		;��ָ��˿��������
	call delay2
	popf
	popa
	ret
chlcd_write_ctr endp

chlcd_write_data proc near	;��lcdд����(bl)
	pusha
	pushf
	MOV DX,chlcddataport
	mov al,bl
	out dx,al		;�����ݶ˿��������
	call delay2
	popf
	popa
	ret
chlcd_write_data endp

delay2 proc near
	pusha       ;delay
	pushf
	mov cx,010h
delay2_2:
	push cx
	mov cx,0ffffh
delay2_1:
	nop
	loop delay2_1
	pop cx
	nop
	loop delay2_2
	popf
	popa
	ret
delay2 endp
code ends
end start