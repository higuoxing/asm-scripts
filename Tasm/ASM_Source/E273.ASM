;****************************;
;*   �򵥵Ĳ������ʵ��     *;
;****************************;
ioport		equ 0d400h-0280h
ls273		equ ioport+2a8h
code segment
  assume cs:code
start:
	mov ah,2      ;�س���
	mov dl,0dh
	int 21h
	mov ah,1      ;�ȴ���������
	int 21h
	cmp al,27     ;�ж��Ƿ�ΪESC��
	je exit       ;�������˳�
	mov dx,ls273   ;������,��2A8H�����ASCII��
	out dx,al
	jmp start     ;תstart
exit: mov ah,4ch    ;����
	int 21h
code ends
end start