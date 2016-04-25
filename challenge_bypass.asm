.386
.model flat, stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\macros\macros.asm
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.data
	AppName db "Nightware Neptuna Antivirus Challenge", 0
	ClassName db "Class of GUI", 0
	scan db "button", 0
	scanfile db  "button", 0

.data?
	hInstance HINSTANCE ?
	CommandLine LPSTR ?
	hwndButton HWND ?
	
.const
	ButtonID equ 1
	
.code

_start:

	call IsDebuggerPresent
	xor eax, eax
	cmp eax, 1
	jmp founddebugger
	mov hInstance, eax
	push 0
	call GetModuleHandle
	
	mov CommandLine, eax
	call GetCommandLine
	
	invoke WinMain, hInstance, 0, CommandLine, SW_SHOWDEFAULT
	
	invoke ExitProcess, eax
	
	WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
	
	local wc:WNDCLASSEX
	local hwnd:HWND
	local msg:MSG
	
	mov wc.cbSize, SIZEOF WNDCLASSEX
	mov wc.style, CS_HREDRAW or CS_VREDRAW
	mov wc.lpfnWndProc, offset AvWinGui
	mov wc.hbrBackground, COLOR_BTNFACE+1
	mov wc.cbClsExtra, 0
	mov wc.cbWndExtra, 0
	push hInst
	pop wc.hInstance
	mov wc.lpszMenuName, 0
	mov wc.lpszClassName, offset ClassName
	push IDI_APPLICATION
	push 0
	call LoadIcon
	mov wc.hIcon, eax
	mov wc.hIconSm, eax
	push IDC_ARROW
	push 0
	call LoadCursor
	mov wc.hCursor, eax
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx, 0,\
	addr ClassName,\
	addr AppName,\
	WS_OVERLAPPEDWINDOW and not WS_MAXIMIZEBOX and not WS_SIZEBOX,\
	CW_USEDEFAULT,\
	CW_USEDEFAULT,\
	500,\
	300,\
	0,\
	0,\
	hInst,\
	0
	mov hwnd, eax
	
	invoke ShowWindow, hwnd, CmdShow
	invoke UpdateWindow, hwnd
	
	.while 1
		invoke GetMessage, addr msg, 0, 0, 0	
	.break .if(!eax)
		invoke TranslateMessage, addr msg
		invoke DispatchMessage, addr msg
	.endw
	mov eax, msg.wParam
	
	RET
WinMain endp

AvWinGui proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
.if uMsg==WM_DESTROY
	invoke PostQuitMessage, 0
.elseif uMsg==WM_CREATE
	invoke CreateWindowEx, 0, addr scanfile, chr$("Scan particular file"),\
	WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
	250, 15, 230, 25, hWnd, ButtonID, hInstance, 0
	invoke CreateWindowEx, 0, addr scan ,  chr$("Scan computer for malware"),\
	WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
	10, 15, 230, 25, hWnd, ButtonID, hInstance, 0
.else
	push lParam
	push wParam
	push uMsg
	push hWnd
	call DefWindowProc
	ret
	.endif
	xor eax, eax
	RET
AvWinGui endp

founddebugger:
	invoke MessageBox, 0, chr$("Debugger found"), chr$("Debugger detected"), MB_ICONERROR
	invoke ExitProcess, 0

end _start


