.386				; ������Ե�αָ���80386���Ժ�㴦������ʹ�ø�ָ�������ģʽ�͸�ʽ��	
.model flat,stdcall		; ģʽ���塰model �ڴ�ģʽ[����ģʽ]��
option casemap:none		; ѡ���趨���趨Ϊ�Դ�Сд���У�
;
; -=-=-=-=-=-=-=-=ͷ�ļ�-=-=-=-=-=-=-=-=-
;
include windows.inc
include msvcrt.inc		; ����C���ԵĿ�
includelib msvcrt.lib		; ����C���Կ��Ӧ��lib�ļ�
include user32.inc
includelib user32.lib

.data
; ����ṹ��
_PERSON struct
	szName   db 32 dup(0)
	szNumber db 32 dup(0)
_PERSON ends
PPERSON TYPEDEF PTR _PERSON

; ����ȫ�ֱ���
g_nCountMax	dd	100			; �����Ԫ��
g_nCount	dd	0			; Ԫ�ظ���
g_GetContacts	_PERSON  <'0','0'>		; ����������Ϣ
g_pContacts	dd	0			; ָ�룬��ϵ����Ϣ
;
;
; -=-=-=-=-=-=-=-ֻ�����ݶ�-=-=-=-=-=-=-=-
;
.const
dFormat    db "%d",00H
sFormat    db "%s",00H
ssFormat   db "%s %s",00H
pszMenu	   db "����������ѡ��:",0AH
	   db "1. ���ӵ绰����",0AH
	   db "2. ���ҵ绰����",0AH
	   db "3. �޸ĵ绰����",0AH
	   db "4. ɾ���绰����",0AH
	   db "5. �򿪵绰�ļ�",0AH
	   db "6. ����绰�ļ�",0AH
	   db "7. ��ʾ�绰",0AH
	   db "8. �˳�",0AH,00H
szAdd      db "���������ӵ������͵绰����",0AH,00H
szFind	   db "��������Ҫ���ҵ�����",0AH,00H
szFindNo   db "û���ҵ�",0AH,00H
szChange   db "�������޸ĺ���ֻ�����",0AH,00H
szDelete   db "�����Ƿ�Ҫɾ������Ϣ,0(��ɾ��),1(ɾ��)",0AH,00H
szSafe	   db "wb+",00H
szRead     db "rb+",00H
szFileName db "E:\\Books.txt",00H
szEnt	   db 0AH,00H
;
; -=-=-=-=-=-=-=-=�����-=-=-=-=-=-=-=-=-
;
.code

IsMax proc
	mov  eax, g_nCount
	cmp  eax, g_nCountMax
	jz   _Add		; �����ʱ���������������������ת
	ret
_Add:	; �ٷ���һ�ٸ��ռ����
	mov  eax, g_nCountMax
	add  eax, 100		; ���ռ��ټ�һ��
	mov  g_nCountMax, eax
	push g_nCountMax	; ѹ���µĴ�С
	push g_pContacts	; ѹ����Ҫ���·���Ŀռ�ָ��
	call crt_realloc	; ���·���ռ�
	add  esp, 08H	
	ret
IsMax endp

AddNum proc	; �����ֻ����������
	push eax				; ���ڽ����������õ�eax��ecx,edx,esi��������ѹ��ջ��
	push ecx
	push edx
	push esi
	push offset szAdd
	call crt_printf
	add  esp, 4
	; �ж��Ƿ񳬹����������
	call IsMax
	lea  esi, [g_pContacts]			; �������ݵĽṹ�������׵�ַ
	mov  ecx, g_nCount			; ��ȡ��ǰ�Ѿ�������û�����
	mov  eax, sizeof(_PERSON)		; ����ṹ����С(sizeof��)
	imul eax, ecx
	add  esi, eax				; �ƶ��ṹ�������ָ��
	lea  eax, [esi+_PERSON.szNumber]	; ��ȡszNumber��ƫ��
	lea  edx, [esi+_PERSON.szName]		; ��ȡszName��ƫ��
	push eax
	push edx
	push offset ssFormat
	call crt_scanf				; ����Ҫ�������Ϣ
	add  esp,0CH
	inc  g_nCount
	pop  esi
	pop  edx
	pop  ecx
	pop  eax
	ret
AddNum endp

FindNum proc	; �������������ֻ�����
	push eax
	push ecx
	push edx
	push esi
	push edi
	push offset szFind
	call crt_printf
	add  esp, 4
	lea  edi, [g_GetContacts.szName]	; ��������������ĵ�ַ
	push edi
	push offset sFormat
	call crt_scanf
	add  esp, 4				; ��ȡ���������
	; ��ȡ�������ֵĳ���
	pop  edi
	mov  esi, 0
_GetLen:	
	mov  al,  [edi+esi]
	inc  esi
	cmp  al,  0
	jnz  _GetLen
	mov  ecx, esi				; �������ַ����ĳ��ȸ���ecx	
	xor  edx,edx				; ����edxΪ����������һ��ʼΪ0	
_FORBEGIN:
	cmp  edx, g_nCount			; �ж��Ƿ���ڵ���g_nCount
	jnb  _FINDNO			
	push ecx				; ��ecx��������
	mov  eax, sizeof(_PERSON)	
	imul eax, edx
	lea  esi, [g_pContacts]
	add  esi, eax				; ��ȡƫ�Ƶ�ַ
	push esi
	lea  esi, [esi+_PERSON.szName]		; ��ȡ����ƫ��
	lea  edi, [g_GetContacts.szName]	; �������������
	repe  cmpsb
	jz   _EQUAL				; �����ȵĻ�ֱ������ѭ��
	pop  esi
	pop  ecx
	inc  edx
	jmp  _FORBEGIN
	
_EQUAL: ; �ҵ���
	pop  esi
	pop  ecx
	push edx
	lea  eax, [esi+_PERSON.szNumber]	; ��ȡ�ýṹ�������
	lea  edx, [esi+_PERSON.szName]		; ��ȡ�ýṹ����ֻ���
	push eax
	push edx
	push offset ssFormat
	call crt_printf				; ���ҵ������ֺ��ֻ��Ŵ�ӡ����
	add  esp, 0CH
       	push offset szEnt			; ��ӡ�س�
       	push offset sFormat
       	call crt_printf
       	add  esp, 08H
       	pop  ebx				; �ҵ��Ļ���ebxΪ�ڼ���
       	inc  ebx				; �����һ���±�Ϊ0�����Լ�1
	jmp  _FOREND
	
_FINDNO:; û�ҵ�
	push offset szFindNo
	call crt_printf
	add  esp, 04H
	mov  ebx, 00H				; û�ҵ��Ļ���ebxΪ00H
	jmp _FOREND
_FOREND:	
	pop  edi
	pop  esi
	pop  edx
	pop  ecx
	pop  eax
	ret

FindNum endp

ChangeNum proc	; ���������޸��ֻ�����
	push ecx
	push esi
	xor ebx, ebx
	call FindNum
	test ebx, ebx				; �ж�ebx�Ƿ�Ϊ0
	jnz  _Find	
	pop  esi
	pop  ecx
	ret
_Find:	
	dec  ebx				; -1����±�
	; ����ebx��Ѱ��
	lea  esi, g_pContacts
	mov  eax, sizeof(_PERSON)
	imul eax, ebx
	lea  esi, [esi+eax+_PERSON.szNumber]	; ��ȡ���ֻ�����ĵ�ַ
	push esi				; �ȱ�������ֻ�����ĵ�ַ
	mov  edi, esi
	mov  ecx, 20H
	mov  al,  0
	rep  stosb				; ����ֻ�����
	push offset szChange
	call crt_printf
	add  esp, 04H
	lea  eax, [g_GetContacts.szNumber]
	push eax
	push offset sFormat
	call crt_scanf
	add  esp, 08H
	lea  esi, [g_GetContacts.szNumber]	; ���ǽ��յ��޸ĺ��ֻ�����ĵ�ַ
	xor  ecx, ecx
_GetLen:	
	mov  al,  [esi+ecx]	
	inc  ecx				; ecx���泤��
	cmp  al,  0
	jnz  _GetLen
	pop  edi
	rep movsb				; ��esi�����ݣ��޸ĺ��ֻ����룩��ŵ�edi��ԭ��ַ��
	pop  esi
	pop  ecx
	ret
ChangeNum endp

DeleteNum proc	; ��������ɾ���ֻ�����������Ϣ
LOCAL   IsDelete : DWORD 
	push eax
	call FindNum
	test ebx, ebx				; �ж�ebx�Ƿ�Ϊ0
	jnz  _Find
	ret 

_Find: ; �ҵ��Ժ�
	push offset szDelete
	call crt_printf
	add  esp, 04H
	lea  eax, [IsDelete]
	push eax
	push offset dFormat
	call crt_scanf
	add  esp, 08H
	mov  edx, IsDelete
	test edx, edx		; �ж��Ƿ�Ϊ0�ˣ������Ϊ0��ɾ��
	jnz  _Yes
	pop  eax
	ret
_Yes:  ; ���ѡ��Ϊ1�Ļ�����ɾ����
	dec  ebx				; -1��ȡ�±�
	; ����ebx��Ѱ��
	lea  edi, g_pContacts
	mov  eax, sizeof(_PERSON)
	imul eax, ebx
	lea  edi, [edi+eax]			; ��ȡ����ɾ����Ϣ���ַ
	mov  ecx, 40H				; ���64λ�ռ�
	xor  eax, eax
	rep  stosb
	mov  esi, edi				; ��ȡ����һ���ṹ����ַ
	lea  edi, [edi-sizeof(_PERSON)]		; ��ȡҪ���ǵ��ַ
	mov  ecx, g_nCount
	inc  ebx
	sub  ecx, ebx				; ��ȡ���滹�м���
	imul ecx, sizeof(_PERSON)		; ��ȡҪ�ƶ����ٸ��ֽ�
	rep  movsb
	mov  ecx, sizeof(_PERSON)		; ������һ��
	xor  eax, eax
	rep  stosb
	mov  eax, g_nCount
	dec  eax
	mov  g_nCount, eax
	pop  eax
	ret	

DeleteNum endp

OpenFiles proc
LOCAL    pFile  : DWORD
LOCAL    nSize : DWORD 
	push offset szRead
	push offset szFileName
	call crt_fopen
	add  esp, 08H
	mov  pFile, eax
	push 2
	push 0
	push pFile
	call crt_fseek		; �ļ�ָ��ָ���ļ�β��
	add  esp, 0CH
	push pFile
	call crt_ftell		; ͨ��ftell����ȡ�ļ���С
	add  esp, 04H
	mov  nSize, eax		; ��ȡ����С
	mov  ecx, sizeof(_PERSON)
	xor  edx, edx
	idiv ecx		; ͨ���������ȡ���뱾�������˵ĸ���
	mov  g_nCount, eax
	push nSize
	call crt_malloc		; ����ռ�
	add  esp, 04H
	mov  g_pContacts, eax	; ��ָ�븳ֵ��ȫ�ֱ���ָ��
	push 0
	push 0
	push pFile
	call crt_fseek		; �ļ�ָ��ָ���ļ�ͷ��
	push pFile
	push g_nCount
	mov  eax, sizeof(_PERSON)
	push eax
	push offset g_pContacts
	call crt_fread
	add  esp, 10H
	push pFile
	call crt_fclose
	add  esp, 04H
	ret
OpenFiles endp

SaveFile proc
LOCAL   pFile  : DWORD
	push offset szSafe
	push offset szFileName
	call crt_fopen
	add  esp, 08H
	mov  pFile, eax
	push pFile
	push g_nCount		; ����
	mov  eax, sizeof(_PERSON)
	push eax
	push offset g_pContacts
	call crt_fwrite
	add  esp, 10H
	push pFile
	call crt_fclose
	add  esp, 04H
	ret
SaveFile endp

ShowNum proc	; ��ʾ�ֻ����������
LOCAL   i  : DWORD
	push eax
	push ecx
	push edx
	push esi
	push offset g_pContacts
	mov  i, 0
_ForBegin:
	xor  ecx, ecx
	mov  ecx, i	
	cmp  ecx, g_nCount	; �Ƚϴ���
	jnb  _ForEnd		; ������ڵ���ecx������ѭ��
	mov  eax, sizeof(_PERSON)
	imul eax, ecx	
	mov  esi, [esp]
	add  esi, eax		; ��ȡƫ����
	lea  eax, [esi+_PERSON.szNumber]
	lea  edx, [esi+_PERSON.szName]
	push eax
	push edx
	push offset ssFormat
	call crt_printf
	add  esp, 0CH
       	push offset szEnt	; ��ӡ�س�
       	push offset sFormat
       	call crt_printf
       	add  esp, 08H
       	add  i, 1		; i�Լ�
	jmp _ForBegin
_ForEnd:
	add  esp, 08H
	pop esi
	pop edx
	pop ecx
	pop eax
	ret

ShowNum endp

;
; Main����
;
Main proc
; �ֲ�����
LOCAL 	nChoice : DWORD
	mov  eax, sizeof(_PERSON)
	mov  ecx, g_nCountMax		; һ��ʼ��������ôg_nCountMax*size�Ŀռ�
	imul ecx
	push eax
	call crt_malloc
	add  esp, 04H
	mov  g_pContacts, eax
	mov  eax, sizeof(_PERSON)
	mov  ecx, g_nCountMax		; һ��ʼ��������ôg_nCountMax*size�Ŀռ�
	imul ecx
	push eax
	push 0
	push g_pContacts
	call crt_memset
	add  esp, 0CH
_WHILE_BEGIN:
	xor  eax, eax
	cmp  eax, 1		; ��ѭ��
	je _WHILE_END
	push offset pszMenu
	call crt_printf		; ��ӡ���˵�
	add  esp, 4
	lea  eax, nChoice	; ��ȡ�ֲ������ĵ�ַ
	push eax
	push offset dFormat
	call crt_scanf		; ��ȡ����
	add  esp, 8
	lea  esi, [jmpTable]	; ��ȡ��ת�����׵�ַ
	mov  edx, nChoice
	dec  edx		; ת��Ϊ��ת���±�
	cmp  edx, 0		; �����Ƿ�С��0
	jc   _SWITCH_END	; ���С��0 ������ȥ
	cmp  edx, 8		; �����Ƿ���ڵ���8
	jnc  _SWITCH_END	; �������0 ����ת
	jmp  dword ptr [esi + edx * 4]  ; ��ת����ת����Ӧ�ı�ǩ

	
;
; -=-=-=-=-=-=-=-=��ת��-=-=-=-=-=-=-=-=-
;

jmpTable dd _Addfunc, _Findfunc, _Changefunc, _Deletefunc, _Openfunc, _Savefunc, _Showfunc, _Endfunc

_Addfunc:
	call AddNum
	jmp _SWITCH_END

_Findfunc:
	call FindNum
	jmp _SWITCH_END

_Changefunc:
	call ChangeNum
	jmp _SWITCH_END

_Deletefunc:
	call DeleteNum
	jmp _SWITCH_END

_Openfunc:
	call OpenFiles
	jmp _SWITCH_END

_Savefunc: 
	call SaveFile
	jmp _SWITCH_END

_Showfunc:
	call ShowNum
	jmp _SWITCH_END
	
_Endfunc:
	jmp _WHILE_END

_SWITCH_END:
	jmp _WHILE_BEGIN	; ����ѭ���Ŀ�ʼ
	
_WHILE_END:
	ret			; ѭ��������

Main endp


; ������ڵ�
Entry:
	call Main
	ret
end Entry
end