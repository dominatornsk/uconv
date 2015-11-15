format PE64 GUI 4.0
entry start

include 'win64a.inc'
include 'rsrc.inc'

section '.data' readable writable

str_ptr   rq 1
str_text  rq 1
len	  rq 1
mystr	  rb 10
hwnd	  rq 1
frm_hndl  rq 1
edt1_hndl rq 1
edt2_hndl rq 1
my_esp	  rq 1
hex_fmt   db 0x30,0x78,0x25,0x78,0x2c,0 ;'0x%x,',0

title	   dw 0x55,0x6e,0x69,0x63,0x6f,0x64,0x65,0x2d,0x4b,0x6f,0x6e,0x76,0x65,0x72,0x74,0x65,0x72,0
willkommen dw 0x55,0x6e,0x69,0x63,0x6f,0x64,0x65,0x2d,0x4b,0x6f,0x6e,0x76,0x65,0x72,0x74,0x65,0x72
	   dw 0xd,0xa9,0x32,0x30,0x31,0x35,0x20,0x4e,0x69,0x6b,0x6f,0x6c,0x61,0x6a,0x20,0x4c,0x69,0x6e,0x6b,0x65,0x77,0x69,0x74,0x73,0x63,0x68
	   dw 0xd,0x4b,0x6f,0x6e,0x74,0x61,0x6b,0x74,0x65,0x3a
	   dw 0xd,0x62,0x65,0x72,0x6c,0x69,0x6f,0x7a,0x20,0x61,0x75,0x66,0x20,0x70,0x72,0x6f,0x67,0x72,0x61,0x6d,0x6d,0x65,0x72,0x73,0x66,0x6f,0x72,0x75,0x6d,0x2e,0x72,0x75
	   dw 0xd,0x68,0x74,0x74,0x70,0x3a,0x2f,0x2f,0x67,0x69,0x74,0x68,0x75,0x62,0x2e,0x63,0x6f,0x6d,0x2f,0x64,0x6f,0x6d,0x69,0x6e,0x61,0x74,0x6f,0x72,0x6e,0x73,0x6b
	   dw 0

section '.code' readable executable
start:
	sub	rsp,8*5
	invoke	GetModuleHandle,0
	mov	[hwnd],rax
	invoke	DialogBoxParam,rax,IDD_DLG1,HWND_DESKTOP,DialogProc,0
	invoke	ExitProcess,0


proc DialogProc
	push	rbx rsi rdi
	cmp	rdx,WM_INITDIALOG
	je	.wminitdialog
	cmp	rdx,WM_COMMAND
	je	.wmcommand
	cmp	rdx,WM_CLOSE
	je	.wmclose
	xor	rax,rax
	jmp	.finish
  .wminitdialog:
	mov	[frm_hndl],rcx
	invoke	GetDlgItem,[frm_hndl],IDC_EDT1
	mov	[edt1_hndl],rax
	invoke	GetDlgItem,[frm_hndl],IDC_EDT2
	mov	[edt2_hndl],rax
	invoke	LoadIcon,[hwnd],1
	invoke	SendMessage,[frm_hndl],WM_SETICON,ICON_BIG,eax

	jmp	.processed
  .wmcommand:
	cmp	r8,BN_CLICKED shl 16 + IDC_BTN1
	je	.btn
	cmp	r8,BN_CLICKED shl 16 + IDC_BTN2
	je	.about
	cmp	r8,BN_CLICKED shl 16 + IDC_BTN3
	je	.wmclose
	jmp	.processed
  .btn:
	mov	rcx,[edt1_hndl]
	mov	rdx,WM_GETTEXTLENGTH
	xor	r8,r8
	xor	r9,r9
	sub	rsp,0x20
	call	[SendMessage]
	add	rsp,0x20

	test	rax,rax
	jz	.processed
	mov	[len],rax

	mov	rbx,7
	mul	rbx
	xor	rcx,rcx
	mov	rdx,rax
	sub	rsp,0x20
	call	[LocalAlloc]
	add	rsp,0x20
	mov	[str_ptr],rax

	mov	rax,[len]

	inc	rax
	mov	rbx,2
	mul	rbx
	add	rax,10
	xor	rcx,rcx
	mov	rdx,rax
	sub	rsp,0x20
	call	[LocalAlloc]
	add	rsp,0x20
	mov	[str_text],rax

	mov	rax,[len]
	inc	rax
	invoke	GetWindowText,[edt1_hndl],[str_text],rax

	mov	rsi,[str_text]
	mov	rdi,rsi
	mov	rax,[len]
	mov	rbx,2
	mul	rbx
	add	rdi,rax

	mov	rcx,mystr
	mov	rdx,hex_fmt
	xor	rax,rax
	mov	ax,word[rsi]
	mov	r8,rax
	sub	rsp,0x20
	call	[sprintf]
	add	rsp,0x20

	cinvoke strcpy,[str_ptr],mystr
	add	rsi,2
	cmp	rsi,rdi
	jge	.processed

	.progress:
		mov	rcx,mystr
		mov	rdx,hex_fmt
		xor	rax,rax
		mov	ax,word[rsi]
		mov	r8,rax
		sub	rsp,0x20
		call	[sprintf]
		add	rsp,0x20

		cinvoke strcat,[str_ptr],mystr
		add	rsi,2
		cmp	rsi,rdi
		jl	.progress

	mov	rcx,[str_ptr]
	sub	rsp,0x20
	call	[strlen]
	add	rsp,0x20
	dec	rax
	add	rax,[str_ptr]
	mov	byte[rax],0

	mov	rcx,[edt2_hndl]
	mov	rdx,[str_ptr]
	sub	rsp,0x20
	call	[SetWindowTextA]
	add	rsp,0x20

	invoke	LocalFree,[str_text]
	invoke	LocalFree,[str_ptr]

	jmp	.processed

  .about:
	sub	rsp,8*5
	invoke	MessageBox,[frm_hndl],willkommen,title,0x40
	jmp	.processed

  .wmclose:
	invoke	EndDialog,rcx,0
  .processed:
	mov	rax,1
  .finish:
	pop	rdi rsi rbx
	ret
endp

section '.idata' import data readable

  library kernel,'KERNEL32.DLL',\
	  user,'USER32.DLL',\
	  msvcrt,'msvcrt.dll'

  import kernel,\
	 GetModuleHandle,'GetModuleHandleW',\
	 ExitProcess,'ExitProcess',\
	 LocalAlloc, 'LocalAlloc',\
	 LocalFree, 'LocalFree'

  import user,\
	 DialogBoxParam,'DialogBoxParamW',\
	 MessageBox,'MessageBoxW',\
	 GetDlgItem, 'GetDlgItem',\
	 GetWindowTextLength, 'GetWindowTextLengthW',\
	 GetWindowText,'GetWindowTextW',\
	 EndDialog,'EndDialog',\
	 wsprintf,'wsprintfW',\
	 SendMessage,'SendMessageW',\
	 SetWindowTextA,'SetWindowTextA',\
	 LoadIcon,'LoadIconW'

  import msvcrt,\
	 sprintf,'sprintf',\
	 strcpy,'strcpy',\
	 strcat,'strcat',\
	 strlen,'strlen'


section '.rsrc' resource data readable
  directory RT_GROUP_ICON,group_icons,\
	    RT_ICON,icons,\
	    RT_DIALOG,dialogs

include "dialogs.tab"

include "dialogs.dat"

resource icons,\
	 1,LANG_NEUTRAL,main_icon_data
resource group_icons,\
	 1,LANG_NEUTRAL,main_icon
icon main_icon,main_icon_data,'calc.ico'