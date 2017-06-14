;386����΢������
;��dos�²���ʹ��
;tasm4.1�����ϱ���
;*********************;
;* �ж� IRQ5/INT 0DH *;
;*********************;
data segment
 int_vect EQU 0DH      ;IRQ0-7������Ϊ:08h-0fh,�ж�8-15������Ϊ:70h-77h
 irq_mask_2_7 equ 011011111b    ;�ж�����,�ж�0-7ʱ�ӵ�������ӦλΪ��,�ж�8-15ʱ��2λΪ��
 irq_mask_9_15 equ 011111111b   ;�ж�0-7ʱȫһ,�ж�8-15ʱ�ӵ�������ӦλΪ��
 ioport_cent equ 0c000h ;tpc ����9054оƬ�Ŀ���ַ
 csreg	dw	?
 ipreg	dw	?	;���ж���������ռ�
 irq_times      db      5     ;�жϼ���
 msg1    db      0dh,0ah,'TPC pci card Interrupt',0dh,0ah,'$'
 msg2    db      0dh,0ah,'Press any key to exit!',0dh,0ah,'$'
 msg3    db      0dh,0ah,'Press DMC to interrupt 5 times and exit!',0dh,0ah,'$'
data ends
stacks segment
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

        mov ax,data
        mov ds,ax
        mov dx,offset msg2
	mov ah,09h
	int 21h
        mov dx,offset msg3
	mov ah,09h
	int 21h
;        mov irq_times,5
	sti

loop1:
        cmp irq_times,0		;�ȴ��жϲ��ж��ж�10�κ��˳�
        jz exit
	mov ah,1
	int 16h
        jnz exit		;��������˳�
        jmp loop1

exit:   cli
        mov     bl, irq_mask_2_7        ;�ָ��ж�����
	not	bl
	in	al, 21h
	or	al, bl
	out	21h, al
	mov	bl, irq_mask_9_15
	not	bl
	in	al, 0a1h
	or	al, bl
	out	0a1h, al

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

	mov ax,4c00h
	int 21h

int_proc proc far
        cli
        push ax
        push dx
        push ds
        dec irq_times
        mov ax,data             ;Interrupt to do
        mov ds,ax
	mov dx,offset msg1
	mov ah,09h
	int 21h

        mov al,20h              ;Send EOI
        out 0a0h,al
        out 20h,al
        pop ds
        pop dx
        pop ax
        sti
        iret
int_proc endp

code ends
	end start