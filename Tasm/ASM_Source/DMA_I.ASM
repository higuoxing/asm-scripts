;386����΢������
;��dos�¿�����
;tasm4.1�����ϱ���
;***********************;
;*       DMAʵ��       *;
;*     244 �����·    *;
;***********************;
 ioport_cent    equ 0d800h		;TPC��PCI�ӿ�оƬIO�Ĵ�����ַ
 io_data        equ 080000000h          ;TPC���߼������������ַ��PCI����չ
 dmamode        equ 01000001000000b     ;DMAͨ��ģʽ��,Demandģʽ
 dmacount       equ 32			;�������ݳ��ȣ�32�ֽڣ�8˫��
 dmadpr         equ 1000b               ;���ݴ��䷽��LOCAL->PCI��TPC�豸������
 dmacsr         equ 0011b		;����DMA����
data SEGMENT
 in_data db      dmacount dup(0)
data ENDS
extra segment at 6000h
 ext db dmacount dup(?)		;���ݻ�����
extra ends
stacks segment
 db 100h dup(?)
stacks ends
code SEGMENT
        ASSUME CS:code,DS:data,SS:stacks,ES:data
start:
.386p
        mov ax,data
        mov ds,ax
        mov ax,extra
        mov es,ax
        lea si,in_data
        lea di,ext
        cld
        mov cx,dmacount
        rep movsb		;���������

	mov dx,ioport_cent+80h
        mov eax,dmamode
	out dx,eax			;����dmaͨ��0
	mov dx,ioport_cent+84h
	mov eax,060000h
        mov ecx,offset ext
	add eax,ecx
	out dx,eax			;����PCI�ӿڶ˴洢����ַ��΢���ڴ�ĵ�ַ
	mov dx,ioport_cent+88h
	mov eax,io_data
	out dx,eax			;����local�洢����ַ��PCI����չ
	mov dx,ioport_cent+8ch
        mov eax,dmacount
	out dx,eax			;���ô������ݳ���
	mov dx,ioport_cent+90h
        mov eax,dmadpr
	out dx,eax			;���ô��䷽���
	mov dx,ioport_cent+0a8h
        mov al,dmacsr
	out dx,al			;��������
next3:
	mov ax,6000h
	mov ds,ax
        mov si,offset ext
        mov cx,8
loop3:
        mov ax,[si+2]
        call disp
        mov ax,[si]
	call disp
        add si,4
	mov ah,02h
	mov dl,20h
	int 21h
        loop loop3		;����������8��˫�����ݲ���ʾ
	mov ah,02h
	mov dl,0dh
	int 21h
	mov dl,0ah
	int 21h			;��ʾ�س�������

        mov ah,1
	int 16h
        jz next3                ;��������˳�

	mov dx,ioport_cent+0a8h
        mov al,0h
        out dx,al
        mov ax,4c00h
        int 21h		;�˳�

disp proc near		;��ʾ�ӳ���
	push dx
	push cx
	push bx
	mov cx,4
	mov bx,16
loop1:	push ax
	push cx
	sub bx,4
	mov cx,bx
	shr ax,cl
	and al,0fh       ;����ȡ����λ
	mov dl,al
	cmp dl,9         ;�ж��Ƿ�<=9
	jle num          ;������Ϊ'0'-'9',ASCII���30H
	add dl,7         ;����Ϊ'A'-'F',ASCII���37H
num:	add dl,30h
	mov ah,02h       ;��ʾ
	int 21h
	pop cx
	pop ax
	loop loop1
	pop bx
	pop cx
	pop dx
	ret              ;�ӳ��򷵻�
disp endp

code ENDS
	END start