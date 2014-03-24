.586
.model flat,stdcall
option casemap:none


   
   include KuPao.inc
   include data.inc
   


WinMain proto :DWORD,:DWORD,:DWORD,:DWORD


.data
   testStr db "heheaa",0
   testStr2 db "hheaaa",0
   ClassName db "MainWinClass",0
   AppName  db "Main Window",0

.data?
   hInstance HINSTANCE ?
   CommandLine LPSTR ?

.code


; ---------------------------------------------------------------------------


start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	
	invoke GetCommandLine
	mov    CommandLine,eax
	
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	LOCAL hwnd:HWND
	
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_BTNFACE+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
	
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,WINDOW_X,\
           WINDOW_Y,WINDOW_WIDTH,WINDOW_HEIGHT,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	
	invoke ShowWindow, hwnd,SW_SHOWNORMAL
	invoke UpdateWindow, hwnd
	invoke SetTimer,hwnd,1,30,NULL

	
	.WHILE TRUE
		invoke GetMessage, ADDR msg,NULL,0,0
		.BREAK .IF (!eax)
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
	.ENDW
	
	mov     eax,msg.wParam
	
	ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL ps :PAINTSTRUCT
LOCAL Dc :HDC
	
	.IF uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.ELSEIF uMsg==WM_CREATE
		invoke LoadRes,hWnd;//
		;
	.ELSEIF uMsg==WM_KEYDOWN
		invoke KeyDownCallBack, wParam
	.ELSEIF uMsg==WM_PAINT
		invoke BeginPaint,hWnd,Addr ps
	   	mov Dc,eax ;// 返回画笔对象
	   	
	   	invoke WMPaint,Dc,hWnd
	   	
	   	invoke EndPaint,hWnd,Addr ps
	.ELSEIF uMsg == WM_TIMER
		invoke UpdateData
		invoke Repaint,hWnd
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.ENDIF
	
	xor eax,eax
	ret
WndProc endp

WMPaint Proc Dc:DWORD, hWnd:DWORD	
LOCAL tmpDc: DWORD
LOCAL tmpBitmap: DWORD
	invoke CreateCompatibleDC, Dc
	mov tmpDc, eax
	invoke CreateCompatibleBitmap,Dc, WINDOW_WIDTH, WINDOW_HEIGHT
	mov tmpBitmap, eax
	invoke SelectObject,tmpDc, tmpBitmap
	invoke BitBlt,tmpDc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,BackgroundDc,0,0,SRCCOPY ;//绘制背景图片
	invoke DrawIconEx,tmpDc,100,actor_y,hActor,80D,80D,0,0,DI_NORMAL;//绘制小人
	invoke DrawIconEx,tmpDc,200,actor_y,hActor,80D,80D,0,0,DI_NORMAL;
	invoke DrawIconEx,tmpDc,300,actor_y,hActor,80D,80D,0,0,DI_NORMAL;
	invoke DrawIconEx,tmpDc,400,actor_y,hActor,80D,80D,0,0,DI_NORMAL;
	invoke BitBlt,Dc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,tmpDc,0,0,SRCCOPY ;
	invoke ReleaseDC,hWnd,tmpDc
	invoke DeleteObject,tmpBitmap
	invoke DeleteObject,tmpDc
	ret
WMPaint endp

LoadRes proc USES eax esi edi,
	hWnd:HWND
LOCAL Dc:DWORD
	invoke GetDC,hWnd
	mov Dc,eax
	invoke CreateCompatibleDC,Dc
	mov BackgroundDc,eax
	;//invoke MessageBox,0,OFFSET testStr, OFFSET testStr,0 
	invoke LoadBitmap,hInstance,BM_BACKGROUND
	
	.if eax == 0
	   mov eax ,FALSE 
	   jmp @@ExitLoad
	.endif
	
	mov hBackg,eax
	invoke SelectObject,BackgroundDc,hBackg ;//将一个Dc和bitmap hd与资源绑定起来
	
	invoke CreateCompatibleDC,Dc
	mov ActorDc,eax
	invoke LoadImage,hInstance,BM_ACTOR,IMAGE_ICON,80D,80D,LR_DEFAULTCOLOR
	mov hActor,eax
	invoke SelectObject,ActorDc,hActor 
	mov eax ,TRUE 
@@ExitLoad:
	   
	ret

LoadRes endp

KeyDownCallBack proc wParam:DWORD
	mov eax ,wParam
	.if eax == VK_UP
		invoke ActorMove,VK_UP
	;.elseif eax == VK_DOWN
	;	invoke ActorMove,VK_DOWN
	;.elseif eax == VK_LEFT
	;	invoke ActorMove,VK_LEFT
	;.elseif eax == VK_RIGHT   
	;	invoke ActorMove ,VK_RIGHT 
	.endif
	ret
KeyDownCallBack endp

ActorMove proc vKey :DWORD
	mov eax, vKey
	.if eax == VK_UP && actorState != ACTOR_JUMP2
		;invoke MessageBox,0,OFFSET testStr, OFFSET testStr,0
		mov actorSpeed_y, INITIAL_SPEED
		.if actorState == ACTOR_JUMP1
			mov actorState,ACTOR_JUMP2
		.else
			mov actorState,ACTOR_JUMP1
		.endif
	.endif
	
	ret

ActorMove endp

Repaint proc hWnd:HWND
LOCAL R:RECT

  invoke GetClientRect,hWnd,Addr R
  invoke InvalidateRect,hWnd,Addr R,0
  ret

Repaint endp

UpdateData proc USES eax ebx
	.if actorState == ACTOR_JUMP1 || actorState == ACTOR_JUMP2
		mov eax, actor_y
		sub eax, actorSpeed_y
		mov actor_y, eax
		sub actorSpeed_y, ACCELERATE_SPEED
		

				
		cmp eax, base_y
		jb L1
		mov ebx, base_y
		mov actor_y, ebx
		mov actorState, ACTOR_RUN
		L1:
	.else	
	.endif
	
	ret

UpdateData endp

end start
