;******************;
;* ������ٳ���  *;
;******************;
ioport		equ 0ec00h-0280h
io8255k		equ ioport+28bh   ;8255���ƿ�
io8255a		equ ioport+288h   ;8255 A��
io8253k		equ ioport+283h   ;8253����
io82532		equ ioport+282h   ;8253������2
io82531		equ ioport+281h   ;8253������1
io82530		equ ioport+280h   ;8253������0
data   segment
mess   db 'Strike any key,return to DOS!',0AH,0DH,'$'
cou    db 0
cou1	db 0
count1  db 0
count2  db 0
count3  db 0
count4  db 0
data   ends
code   segment
assume cs:code,ds:data
start:   mov	ax,data
	  mov	ds,ax
	  mov	dx,offset mess
	  mov	ah,09h
	  int	21h                ;��ʾ��ʾ��Ϣ
	  mov   dx,io8253k
	  mov   al,36h             ;������0����ʽ3���ȶ�д��8λ���ٶ�д��8λ
	  out   dx,al              ;����ʱ�ӣ�1MHZ
	  mov   dx,io82530
	  mov   ax,50000           ;��ֵ50000�����ʱ������50ms
	  out   dx,al
	  nop
         nop
	  mov   al,ah
	  out   dx,al
	  
	  mov	dx,io8255k             ;8255,Aͨ�����룬C0���
	  mov	al,90h
	  out	dx,al
	  mov	al,00
	  out	dx,al               ;C0(GATE1)�͵�ƽ,��ʱ��1��ֹ����
	
	
ll:	  mov	ah,01h              ;���޼���
	  int	16h
	  jnz	quit1               ;�м�������
	    
	  mov   dx,io8253k           
	  mov   al,70h
	  out   dx,al              ;������1����ʽ0���ȶ�д��8λ���ٶ�д��8λ��
	  mov   dx,io82531         ;����ʱ��Ϊ��翪�������
	  mov   al,0ffh
	  out   dx,al
	  nop
	  nop
	  out   dx,al
	  
	  mov	dx,io8253k
	  mov	al,90h
	  out	dx,al              ;������2����ʽ0��ֻ��д��8λ
	  mov	dx,io82532
	  mov	al,100
	  out	dx,al               ;��ֵ100�����5��
	  
	  mov	dx,io8255k
	  mov	al,01h
	  out	dx,al               ;PC0���1����ʱ��1��ʼ����
	  	 
	  jmp	a0
quit1:	  jmp	quit
a0:	  mov	dx,io8255a             
a1:	  in	al,dx
	  and	al,01h
	  jz	a1                  ;8255 PA0�Ƿ�Ϊ0
	  mov	dx,io8255k
	  mov	al,00h
	  out	dx,al               ;��ʱ��1ֹͣ����
	  	
          mov	dx,io82531
          in	al,dx
          mov	bl,al
          in	al,dx
          mov	bh,al              ;16λ����ֵ��bx
          mov	ax,0ffffh
          sub	ax,bx              ;�����������
	  call	disp                ;��ʾ
	  mov	dl,0dh
	  mov	ah,02
	  int	21h
	  mov	dl,0ah
	  mov	ah,02
	  int	21h
          jmp ll                   ;�޼�������

;------------------------------------------------------------
disp	  PROC	NEAR                 ;BCDת������ʾ�ӳ���
	  mov	dx,0000h
	  mov	cx,03e8h             ;��1000
	  div	cx
	  mov	count1,al            ;ǧλ            
	  mov	ax,dx
	  mov	cl,64h
	  div	cl                   ;��100
	  mov	count2,al            ;��λ
	  mov	al,ah
	  mov	ah,00h
	  mov	cl,10
	  div	cl                   ;��10
	  mov	count3,al            ;10λ
	  mov	count4,ah            ;��λ          
          mov	al,count1
          call	disp1
          mov	al,count2
          call	disp1
          mov	al,count3
          call	disp1
          mov	al,count4
          call	disp1
          ret
DISP	  ENDP
;--------------------------------------------------------------------
disp1	  PROC	NEAR                ;��ʾһ���ַ�           
          and	al,0fh
          cmp	al,09h
          jle	num
          add	al,07h
num:      add	al,30h
          mov	dl,al
          mov	ah,02
          int	21h                 
          ret
disp1	  endp
;-------------------------------------------------------------
quit:	  
	 
	  mov ah,4ch               ;����DOS
	  int 21h
	  
code    ends
	end start
	