;386����΢������
;��dos�¿�����
;tasm4.1�����ϱ���
;***********************;
;*       DMAʵ��       *;
;*     244 �����·    *;
;* ʹ��DMA���������ж� *;
;***********************;
 ioport_cent	equ 0d800h	;TPC��PCI�ӿ�оƬIO�Ĵ�����ַ
 io_data        equ 080000000h	;TPC���߼������������ַ��PCI����չ
 dmamode        equ 100001010001000000b ;DMAͨ��ģʽ��,Demandģʽ,DMA���������ж�
 dmacount       equ 32		;�������ݳ��ȣ�32�ֽڣ�8˫��
 dmadpr         equ 1100b	;���ݴ��䷽��LOCAL->PCI��TPC�豸��������DMA���������ж�
 dmacsr         equ 0011b	;����DMA����
 int_vect	EQU 071H	;�µ��ж�����,�ж�0-7������Ϊ:08h-0fh,�ж�8-15������Ϊ:70h-77h
 irq_mask_2_7	equ 011111011b	;�µ��ж�����,�ж�0-7ʱ�ӵ�������ӦλΪ��,�ж�8-15ʱ��2λΪ��
 irq_mask_9_15	equ 011111101b	;�µ��ж�����,�ж�0-7ʱȫһ,�ж�8-15ʱ�ӵ�������ӦλΪ��
data SEGMENT
 csreg		dw ?		;
 ipreg		dw ?		;���ж���������ռ�
 irq_times      db 00h		;DMA���������־λ,Ϊ1ʱ��ʾDMA���ͽ���
 msg1    db 'DMA Transfare finished! Press any key to exit!',0dh,0ah,'$'
 in_data db dmacount dup(0)
data ENDS
extra segment at 6000h
 ext db dmacount dup(?)
extra ends
stacks segment
 db 100h dup(?)
stacks ends
code SEGMENT
        ASSUME CS:code,DS:data,SS:stacks,ES:data
start:
.386p
        cli
        mov ax,stacks
        mov ss,ax
        mov ax,data
        mov ds,ax
        mov ax,extra
        mov es,ax
        lea si,in_data
        lea di,ext
        cld
        mov cx,dmacount
        rep movsb		;���������

        mov irq_times,0h

        mov dx,ioport_cent+68h  ;����TPC����9054оƬio��,ʹ��DMA��������ж�
        in eax,dx
        or eax,040100h
        out dx,eax

        mov al,int_vect         ;����ԭ�ж�����
	mov ah,35h
        int 21h
	mov ax,es
	mov csreg,ax
	mov ipreg,bx

        mov ax,cs               ;�������ж�����
	mov ds,ax
	mov dx,offset int_proc
	mov al,int_vect
	mov ah,25h
        int 21h

        in      al, 21h         ;�����ж�����
        and     al, irq_mask_2_7
        out     21h, al
        in      al, 0a1h
        and     al, irq_mask_9_15
        out     0a1h, al

	mov dx,ioport_cent+80h
        mov eax,dmamode
	out dx,eax		;����dmaͨ��0
	mov dx,ioport_cent+84h
	mov eax,060000h
        mov ecx,offset ext
	add eax,ecx
	out dx,eax		;����PCI�ӿڶ˴洢����ַ��΢���ڴ�ĵ�ַ
	mov dx,ioport_cent+88h
	mov eax,io_data
	out dx,eax		;����local�洢����ַ��PCI����չ
	mov dx,ioport_cent+8ch
        mov eax,dmacount
	out dx,eax		;���ô������ݳ���
	mov dx,ioport_cent+90h
        mov eax,dmadpr
	out dx,eax		;���ô��䷽���
	mov dx,ioport_cent+0a8h
        mov al,dmacsr
	out dx,al		;��������
	sti			;���ж�
next3:
	mov ax,6000h
	mov ds,ax
        mov si,offset ext
        mov cx,8
        cli
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

        mov ax,data
        mov ds,ax
        cmp irq_times,1h
        jnz next2
        mov dx,offset msg1
	mov ah,09h
        int 21h			;��ʾDMA���ͽ�����Ϣ
next2:
	mov ah,1
	int 16h
        jz next3                ;��������˳�

exit:
	cli
	mov dx,ioport_cent+0a8h
        mov al,0h
        out dx,al
	mov dx,ioport_cent+80h
        mov ebx,dmamode
        not ebx
        in  eax,dx
        and eax,ebx
        out dx,eax		;�ָ�dmaͨ��0����

        mov     bl, irq_mask_2_7	;�ָ��ж�����
	not	bl
	in	al, 21h
	or	al, bl
	out	21h, al
	mov	bl, irq_mask_9_15
	not	bl
	in	al, 0a1h
	or	al, bl
	out	0a1h, al

        mov dx,ipreg		;�ָ�ԭ�ж�����
	mov ax,csreg
	mov ds,ax
	mov ah,25h
	mov al,int_vect
        int 21h

        mov dx,ioport_cent+68h	;���� tpc ����9054оƬio��,�ر��ж�
	in  eax,dx
        and eax,0bfeffh
	out dx,eax

        mov ax,4c00h
        int 21h		;�˳�

disp proc near		;��ʾ�ӳ���
        cli
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
        sti
	ret              ;�ӳ��򷵻�
disp endp

int_proc proc far	;�жϳ���
        cli
        push ax
        push cx
        push dx
        push ds

	mov ax,data
        mov ds,ax
        mov irq_times,1h	;����DMA���������־λ

        mov dx,ioport_cent+0a8h
        in al,dx
        mov bl,8h
        or al,bl
        out dx,al	;���DMA�����жϱ�־λ

        mov al,20h      ;Send EOI
        out 0a0h,al
        out 20h,al
        mov cx,0ffffh
loopx:
        nop
        loop loopx      ;��ʱ

        pop ds
        pop dx
        pop cx
        pop ax
        sti
        iret
int_proc endp

code ENDS
	END start