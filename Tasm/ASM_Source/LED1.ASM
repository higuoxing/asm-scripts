;**************************************
;* ������������(0-9)����LED�������ʾ *
;**************************************
data  segment
ioport		equ 0d400h-0280h
io8255a		equ ioport+288h
io8255b		equ ioport+28bh
led      db        3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,6fh
mesg1    db        0dh,0ah,'Input a num (0--9),other key is exit:',0dh,0ah,'$'
data ends
code  segment
	assume cs:code,ds:data
start:  mov ax,data
	mov ds,ax
	mov dx,io8255b           ;ʹ8255��A��Ϊ�����ʽ
	mov ax,80h
	out dx,al
sss:    mov dx,offset mesg1    ;��ʾ��ʾ��Ϣ
	mov ah,09h
	int 21h
	mov ah,01              ;�Ӽ��̽����ַ�
	int 21h
	cmp al,'0'             ;�Ƿ�С��0
	jl  exit               ;�������˳�
	cmp al,'9'             ;�Ƿ����9
	jg  exit               ;�������˳�
	sub al,30h             ;�������ַ���ASCII���30H
	mov bx,offset led      ;bxΪ���������ʼ��ַ
	xlat                   ;�����Ӧ�Ķ���
	mov dx,io8255a            ;��8255��A�����
	out dx,al
	jmp sss                ;תSSS
exit:   mov ah,4ch             ;����
	int 21h
code ends
	end start


