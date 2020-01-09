.386				; 汇编语言的伪指令，在80386及以后点处理器中使用该指令集，工作模式和格式。	
.model flat,stdcall		; 模式定义“model 内存模式[调用模式]”
option casemap:none		; 选项设定（设定为对大小写敏感）
;
; -=-=-=-=-=-=-=-=头文件-=-=-=-=-=-=-=-=-
;
include windows.inc
include msvcrt.inc		; 包含C语言的库
includelib msvcrt.lib		; 包含C语言库对应的lib文件
include user32.inc
includelib user32.lib

.data
; 定义结构体
_PERSON struct
	szName   db 32 dup(0)
	szNumber db 32 dup(0)
_PERSON ends
PPERSON TYPEDEF PTR _PERSON

; 声明全局变量
g_nCountMax	dd	100			; 最大存放元素
g_nCount	dd	0			; 元素个数
g_GetContacts	_PERSON  <'0','0'>		; 接收输入信息
g_pContacts	dd	0			; 指针，联系人信息
;
;
; -=-=-=-=-=-=-=-只读数据段-=-=-=-=-=-=-=-
;
.const
dFormat    db "%d",00H
sFormat    db "%s",00H
ssFormat   db "%s %s",00H
pszMenu	   db "请输入您的选项:",0AH
	   db "1. 添加电话号码",0AH
	   db "2. 查找电话号码",0AH
	   db "3. 修改电话号码",0AH
	   db "4. 删除电话号码",0AH
	   db "5. 打开电话文件",0AH
	   db "6. 保存电话文件",0AH
	   db "7. 显示电话",0AH
	   db "8. 退出",0AH,00H
szAdd      db "请输入添加的姓名和电话号码",0AH,00H
szFind	   db "请输入需要查找的姓名",0AH,00H
szFindNo   db "没有找到",0AH,00H
szChange   db "请输入修改后的手机号码",0AH,00H
szDelete   db "请问是否要删除该信息,0(不删除),1(删除)",0AH,00H
szSafe	   db "wb+",00H
szRead     db "rb+",00H
szFileName db "E:\\Books.txt",00H
szEnt	   db 0AH,00H
;
; -=-=-=-=-=-=-=-=代码段-=-=-=-=-=-=-=-=-
;
.code

IsMax proc
	mov  eax, g_nCount
	cmp  eax, g_nCountMax
	jz   _Add		; 如果此时容量等于最大容量，则跳转
	ret
_Add:	; 再分配一百个空间出来
	mov  eax, g_nCountMax
	add  eax, 100		; 最大空间再加一百
	mov  g_nCountMax, eax
	push g_nCountMax	; 压入新的大小
	push g_pContacts	; 压入需要重新分配的空间指针
	call crt_realloc	; 重新分配空间
	add  esp, 08H	
	ret
IsMax endp

AddNum proc	; 增加手机号码和姓名
	push eax				; 由于接下来可能用到eax和ecx,edx,esi，所以先压入栈中
	push ecx
	push edx
	push esi
	push offset szAdd
	call crt_printf
	add  esp, 4
	; 判断是否超过最大容量了
	call IsMax
	lea  esi, [g_pContacts]			; 保存数据的结构体数组首地址
	mov  ecx, g_nCount			; 获取当前已经插入点用户个数
	mov  eax, sizeof(_PERSON)		; 计算结构体点大小(sizeof宏)
	imul eax, ecx
	add  esi, eax				; 移动结构体数组点指针
	lea  eax, [esi+_PERSON.szNumber]	; 获取szNumber的偏移
	lea  edx, [esi+_PERSON.szName]		; 获取szName的偏移
	push eax
	push edx
	push offset ssFormat
	call crt_scanf				; 输入要加入的信息
	add  esp,0CH
	inc  g_nCount
	pop  esi
	pop  edx
	pop  ecx
	pop  eax
	ret
AddNum endp

FindNum proc	; 根据姓名查找手机号码
	push eax
	push ecx
	push edx
	push esi
	push edi
	push offset szFind
	call crt_printf
	add  esp, 4
	lea  edi, [g_GetContacts.szName]	; 保存输入的姓名的地址
	push edi
	push offset sFormat
	call crt_scanf
	add  esp, 4				; 获取输入的姓名
	; 获取输入名字的长度
	pop  edi
	mov  esi, 0
_GetLen:	
	mov  al,  [edi+esi]
	inc  esi
	cmp  al,  0
	jnz  _GetLen
	mov  ecx, esi				; 将输入字符串的长度给了ecx	
	xor  edx,edx				; 设置edx为计数器并且一开始为0	
_FORBEGIN:
	cmp  edx, g_nCount			; 判断是否大于等于g_nCount
	jnb  _FINDNO			
	push ecx				; 将ecx保存下来
	mov  eax, sizeof(_PERSON)	
	imul eax, edx
	lea  esi, [g_pContacts]
	add  esi, eax				; 获取偏移地址
	push esi
	lea  esi, [esi+_PERSON.szName]		; 获取名字偏移
	lea  edi, [g_GetContacts.szName]	; 保存输入的姓名
	repe  cmpsb
	jz   _EQUAL				; 如果相等的话直接跳出循环
	pop  esi
	pop  ecx
	inc  edx
	jmp  _FORBEGIN
	
_EQUAL: ; 找到了
	pop  esi
	pop  ecx
	push edx
	lea  eax, [esi+_PERSON.szNumber]	; 获取该结构体的名称
	lea  edx, [esi+_PERSON.szName]		; 获取该结构体点手机号
	push eax
	push edx
	push offset ssFormat
	call crt_printf				; 将找到的名字和手机号打印出来
	add  esp, 0CH
       	push offset szEnt			; 打印回车
       	push offset sFormat
       	call crt_printf
       	add  esp, 08H
       	pop  ebx				; 找到的话，ebx为第几个
       	inc  ebx				; 数组第一个下标为0，所以加1
	jmp  _FOREND
	
_FINDNO:; 没找到
	push offset szFindNo
	call crt_printf
	add  esp, 04H
	mov  ebx, 00H				; 没找到的话，ebx为00H
	jmp _FOREND
_FOREND:	
	pop  edi
	pop  esi
	pop  edx
	pop  ecx
	pop  eax
	ret

FindNum endp

ChangeNum proc	; 根据姓名修改手机号码
	push ecx
	push esi
	xor ebx, ebx
	call FindNum
	test ebx, ebx				; 判断ebx是否为0
	jnz  _Find	
	pop  esi
	pop  ecx
	ret
_Find:	
	dec  ebx				; -1获得下标
	; 根据ebx来寻找
	lea  esi, g_pContacts
	mov  eax, sizeof(_PERSON)
	imul eax, ebx
	lea  esi, [esi+eax+_PERSON.szNumber]	; 获取到手机号码的地址
	push esi				; 先保存这个手机号码的地址
	mov  edi, esi
	mov  ecx, 20H
	mov  al,  0
	rep  stosb				; 清空手机号码
	push offset szChange
	call crt_printf
	add  esp, 04H
	lea  eax, [g_GetContacts.szNumber]
	push eax
	push offset sFormat
	call crt_scanf
	add  esp, 08H
	lea  esi, [g_GetContacts.szNumber]	; 这是接收到修改后手机号码的地址
	xor  ecx, ecx
_GetLen:	
	mov  al,  [esi+ecx]	
	inc  ecx				; ecx保存长度
	cmp  al,  0
	jnz  _GetLen
	pop  edi
	rep movsb				; 将esi的内容（修改后手机号码）存放到edi（原地址）
	pop  esi
	pop  ecx
	ret
ChangeNum endp

DeleteNum proc	; 根据姓名删除手机号码等相关信息
LOCAL   IsDelete : DWORD 
	push eax
	call FindNum
	test ebx, ebx				; 判断ebx是否为0
	jnz  _Find
	ret 

_Find: ; 找到以后
	push offset szDelete
	call crt_printf
	add  esp, 04H
	lea  eax, [IsDelete]
	push eax
	push offset dFormat
	call crt_scanf
	add  esp, 08H
	mov  edx, IsDelete
	test edx, edx		; 判断是否为0了，如果不为0则删掉
	jnz  _Yes
	pop  eax
	ret
_Yes:  ; 如果选择为1的话，则删掉它
	dec  ebx				; -1获取下标
	; 根据ebx来寻找
	lea  edi, g_pContacts
	mov  eax, sizeof(_PERSON)
	imul eax, ebx
	lea  edi, [edi+eax]			; 获取到所删掉信息点地址
	mov  ecx, 40H				; 清空64位空间
	xor  eax, eax
	rep  stosb
	mov  esi, edi				; 获取后面一个结构体点地址
	lea  edi, [edi-sizeof(_PERSON)]		; 获取要覆盖点地址
	mov  ecx, g_nCount
	inc  ebx
	sub  ecx, ebx				; 获取后面还有几个
	imul ecx, sizeof(_PERSON)		; 获取要移动多少个字节
	rep  movsb
	mov  ecx, sizeof(_PERSON)		; 清空最后一个
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
	call crt_fseek		; 文件指针指向文件尾部
	add  esp, 0CH
	push pFile
	call crt_ftell		; 通过ftell来获取文件大小
	add  esp, 04H
	mov  nSize, eax		; 获取到大小
	mov  ecx, sizeof(_PERSON)
	xor  edx, edx
	idiv ecx		; 通过相除来获取密码本里面存放了的个数
	mov  g_nCount, eax
	push nSize
	call crt_malloc		; 申请空间
	add  esp, 04H
	mov  g_pContacts, eax	; 将指针赋值给全局变量指针
	push 0
	push 0
	push pFile
	call crt_fseek		; 文件指针指向文件头部
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
	push g_nCount		; 块数
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

ShowNum proc	; 显示手机号码和姓名
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
	cmp  ecx, g_nCount	; 比较次数
	jnb  _ForEnd		; 如果大于等于ecx则跳出循环
	mov  eax, sizeof(_PERSON)
	imul eax, ecx	
	mov  esi, [esp]
	add  esi, eax		; 获取偏移量
	lea  eax, [esi+_PERSON.szNumber]
	lea  edx, [esi+_PERSON.szName]
	push eax
	push edx
	push offset ssFormat
	call crt_printf
	add  esp, 0CH
       	push offset szEnt	; 打印回车
       	push offset sFormat
       	call crt_printf
       	add  esp, 08H
       	add  i, 1		; i自加
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
; Main函数
;
Main proc
; 局部变量
LOCAL 	nChoice : DWORD
	mov  eax, sizeof(_PERSON)
	mov  ecx, g_nCountMax		; 一开始先申请这么g_nCountMax*size的空间
	imul ecx
	push eax
	call crt_malloc
	add  esp, 04H
	mov  g_pContacts, eax
	mov  eax, sizeof(_PERSON)
	mov  ecx, g_nCountMax		; 一开始先申请这么g_nCountMax*size的空间
	imul ecx
	push eax
	push 0
	push g_pContacts
	call crt_memset
	add  esp, 0CH
_WHILE_BEGIN:
	xor  eax, eax
	cmp  eax, 1		; 死循环
	je _WHILE_END
	push offset pszMenu
	call crt_printf		; 打印出菜单
	add  esp, 4
	lea  eax, nChoice	; 获取局部变量的地址
	push eax
	push offset dFormat
	call crt_scanf		; 获取输入
	add  esp, 8
	lea  esi, [jmpTable]	; 获取跳转表的首地址
	mov  edx, nChoice
	dec  edx		; 转换为跳转表下标
	cmp  edx, 0		; 看看是否小于0
	jc   _SWITCH_END	; 如果小于0 则跳回去
	cmp  edx, 8		; 看看是否大于等于8
	jnc  _SWITCH_END	; 如果大于0 则跳转
	jmp  dword ptr [esi + edx * 4]  ; 跳转表跳转到相应的标签

	
;
; -=-=-=-=-=-=-=-=跳转表-=-=-=-=-=-=-=-=-
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
	jmp _WHILE_BEGIN	; 跳到循环的开始
	
_WHILE_END:
	ret			; 循环结束点

Main endp


; 程序入口点
Entry:
	call Main
	ret
end Entry
end