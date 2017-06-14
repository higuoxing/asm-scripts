;386����΢������
;win9x/me/dos�¿�����
;tasm4.1�����ϱ���
;*********************;
;*     PCI�˿ڶ�     *;
;*    �˿ڶ�д��ʽ   *;
;*********************;
data	segment
io_port_addre		equ 0cf8h	;32λ���õ�ַ�˿�
io_port_data		equ 0cfch	;32λ�������ݶ˿�
io_plx_id		equ 0540610b5h	;TPC���豸������ID
io_9054base_address     db 4 DUP(0)	;TPC��9054оƬI/O����ַ�ݴ�ռ�
io_base_address         db 4 DUP(0)	;TPC��I/O����ַ�ݴ�ռ�
memory_base_address     db 4 DUP(0)	;TPC��MEMORY����ַ�ݴ�ռ�
interrupt_line          db 2 DUP(0)	;TPC���жϺ��ݴ�ռ�
pcicardnotfind		db 0dh,0ah,'TPC pci card not find or address/interrupt error !!!',0dh,0ah,'$'
io9054baseaddress       db 0dh,0ah,'TPC pci card 9054 Chip I/O Base Address : ','$'
iobaseaddress		db 0dh,0ah,'TPC pci card I/O Base Address : ','$'
memorybaseaddress	db 0dh,0ah,'TPC pci card Memory Base Address : ','$'
intnumber		db 0dh,0ah,'TPC pci card Interrupt Line : ','$'
enter_return		db 0dh,0ah,'$'
data	ends
code segment
	assume cs:code,ds:data,es:data
start:
	mov ax,data
	mov ds,ax
	mov es,ax
.386	;386ģʽ����
	mov ebx,080000000h
next:
	add ebx,100h
	cmp ebx,081000000h
	jnz continue
	mov dx,offset pcicardnotfind	;��ʾδ�ҵ�tpc����ʾ��Ϣ
	mov ah,09h
	int 21h
	mov ah,4ch
	int 21h			;�˳�
continue:
	mov dx,io_port_addre
	mov eax,ebx
	out dx,eax		;д��ַ��
	mov dx,io_port_data
	in  eax,dx		;�����ݿ�
	cmp eax,io_plx_id
	jnz  next		;����Ƿ���tpc��

	mov dx,io_port_addre
	mov eax,ebx
        add eax,14h
	out dx,eax		;д��ַ��
	mov dx,io_port_data
	in  eax,dx		;�����ݿ�
	mov dword ptr io_9054base_address,eax
	and eax,1
	jz next			;����Ƿ�Ϊi/o��ַ��Ϣ
        mov eax,dword ptr io_9054base_address
	and eax,0fffffffeh
        mov dword ptr io_9054base_address,eax        ;ȥ��i/oָʾλ������

	mov dx,io_port_addre
	mov eax,ebx
	add eax,18h
	out dx,eax		;д��ַ��
	mov dx,io_port_data
	in  eax,dx		;�����ݿ�
	mov dword ptr io_base_address,eax
	and eax,1
	jz next			;����Ƿ�Ϊi/o��ַ��Ϣ
	mov eax,dword ptr io_base_address
	and eax,0fffffffeh
	mov dword ptr io_base_address,eax	;ȥ��i/oָʾλ������

	mov dx,io_port_addre
	mov eax,ebx
	add eax,1ch
	out dx,eax		;д��ַ��
	mov dx,io_port_data
	in  eax,dx		;�����ݿ�
	mov dword ptr memory_base_address,eax
	and eax,1h
	jnz next		;����Ƿ�Ϊmemory��ַ��Ϣ
	mov eax,dword ptr memory_base_address
	and eax,0fffffff0h
	mov dword ptr memory_base_address,eax	;ȥ��memoryָʾλ������

	mov dx,io_port_addre
	mov eax,ebx
	add eax,3ch
	out dx,eax		;д��ַ��
	mov dx,io_port_data
	in  eax,dx		;�����ݿ�
	and eax,0ffh
	mov word ptr interrupt_line,ax		;ȥ��interrupt����ָʾλ������

        mov dx,offset io9054baseaddress		;��ʾi/o��ʾ��Ϣ
	mov ah,09h
	int 21h
        mov ax,word ptr io_9054base_address
	call disp		;��ʾi/o����ַ

	mov dx,offset iobaseaddress	;��ʾi/o��ʾ��Ϣ
	mov ah,09h
	int 21h
	mov ax,word ptr io_base_address
	call disp		;��ʾi/o����ַ

	mov dx,offset memorybaseaddress	;��ʾmemory��ʾ��Ϣ
	mov ah,09h
	int 21h
	mov ax,word ptr memory_base_address+2
	call disp		;��ʾmemory����ַ��16λ
	mov ax,word ptr memory_base_address
	shr ax,16
	call disp		;��ʾmemory����ַ��16λ

	mov dx,offset intnumber	;��ʾinterrupt��ʾ��Ϣ
	mov ah,09h
	int 21h
	mov ax,word ptr interrupt_line
	call disp		;��ʾinterrupt��

	mov dx,offset enter_return	;�ӻس���,���з�
	mov ah,09h
	int 21h
	mov ah,4ch
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
	and al,0fh	;����ȡ����λ
	mov dl,al
	cmp dl,9	;�ж��Ƿ�<=9
	jle num		;������Ϊ'0'-'9',ASCII���30H
	add dl,7	;����Ϊ'A'-'F',ASCII���37H
num:	add dl,30h
	mov ah,02h	;��ʾ
	int 21h
	pop cx
	pop ax
	loop loop1
	pop bx
	pop cx
	pop dx
	ret		;�ӳ��򷵻�
disp endp
	code ends
	end start