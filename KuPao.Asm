.586
.model flat,stdcall
option casemap:none


   
   include KuPao.inc
   include data.inc
   


WinMain proto :DWORD,:DWORD,:DWORD,:DWORD


.data
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
	invoke SetTimer,hwnd,1,FREQUENCY,NULL

	
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
		invoke InitMap
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

WMPaint Proc USES eax ebx ecx edx esi,
	Dc:DWORD, hWnd:DWORD	
LOCAL tmpDc: DWORD
LOCAL tmpBitmap: DWORD
LOCAL tmpActorX: SDWORD
LOCAL tmpBackground: SDWORD

LOCAL leftPoint: SDWORD
LOCAL rightPoint: SDWORD

LOCAL coinStartY: SDWORD
LOCAL coinEndY: SDWORD

		

 	;创建双缓冲
	invoke CreateCompatibleDC, Dc
	mov tmpDc, eax
	invoke CreateCompatibleBitmap,Dc, WINDOW_WIDTH, WINDOW_HEIGHT
	mov tmpBitmap, eax
	invoke SelectObject,tmpDc, tmpBitmap
	
	;绘制背景图片
	mov eax, leftFringe
	cdq
	mov ebx, 1536
	idiv ebx
	mov tmpBackground, edx
	invoke BitBlt,tmpDc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,BackgroundDc,tmpBackground,0,SRCCOPY ;//绘制背景图片1
	mov eax, tmpBackground
	sub eax, 1536
	invoke BitBlt,tmpDc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,BackgroundDc,eax,0,SRCCOPY ;//绘制背景图片2
	

	;确定左边界点
	mov eax, leftFringe
	cdq
	mov ebx, MAPPOINT_LENGTH
	idiv ebx
	mov leftPoint, eax
	;确定右边界点
	mov eax, leftFringe
	cdq
	add eax, WINDOW_WIDTH
	mov ebx, MAPPOINT_LENGTH
	idiv ebx
	mov rightPoint, eax
	
	;绘制地图点
	mov ebx, leftPoint
	.WHILE ebx <= rightPoint
		invoke DrawMapPoint,tmpDc, ebx
		inc ebx
	.endw
	
	
	;绘制小人
	mov eax, actor_x
	sub eax, leftFringe
	mov tmpActorX, eax
	invoke DrawIconEx,tmpDc,tmpActorX,actor_y,hActor,80D,80D,0,0,DI_NORMAL;//绘制小人
	
	;将背景画到前景
	invoke BitBlt,Dc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,tmpDc,0,0,SRCCOPY ;
	
	;释放临时资源	
	invoke ReleaseDC,hWnd,tmpDc
	invoke DeleteObject,tmpBitmap
	invoke DeleteObject,tmpDc
	ret
WMPaint endp

DrawMapPoint proc USES eax ebx ecx edx esi,
	tmpDc: DWORD,
	pointIndex: DWORD
	
LOCAL coinEndY:DWORD
LOCAL pointX:DWORD
LOCAL pointOffset:DWORD
		
	;确定点的横坐标
	mov eax, MAPPOINT_LENGTH
	imul eax, pointIndex
	sub eax, leftFringe
	mov pointX, eax
	;确定点的地址偏移
	mov esi, OFFSET gMap
	mov eax, SIZEOF MapPoint
	imul eax, pointIndex
	mov pointOffset, eax
	

	add esi, pointOffset
	mov ebx, (MapPoint PTR [esi]).coinEnd
	mov coinEndY, ebx
	mov ebx, (MapPoint PTR [esi]).coinStart
	
		invoke dw2a,pointOffset, OFFSET testStr 
		invoke dw2a,coinEndY, OFFSET testStr2
		;invoke MessageBox,0,OFFSET testStr, OFFSET testStr2,0 
	.while ebx < coinEndY

		invoke DrawIconEx,tmpDc,pointX,ebx,hGoldenCoin,32D,32D,0,0,DI_NORMAL;//绘制小人
		add ebx, MAPPOINT_LENGTH
	.endw
	ret
DrawMapPoint endp

LoadRes proc USES eax esi edi,
	hWnd:HWND
LOCAL Dc:DWORD
	invoke GetDC,hWnd
	mov Dc,eax
	
	;背景
	invoke CreateCompatibleDC,Dc
	mov BackgroundDc,eax

	invoke LoadBitmap,hInstance,BM_BACKGROUND1
	mov hBackg,eax
	invoke SelectObject,BackgroundDc,hBackg ;//将一个Dc和bitmap hd与资源绑定起来
	
	;小人
	invoke LoadImage,hInstance,ICON_ACTOR,IMAGE_ICON,80D,80D,LR_DEFAULTCOLOR
	mov hActor,eax
	
	;金币
	invoke LoadImage,hInstance,ICON_GOLDEN_COIN,IMAGE_ICON,32D,32D,LR_DEFAULTCOLOR
	mov hGoldenCoin,eax
	 
	mov eax ,TRUE 
	   
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
	mov eax, actorSpeed_x
	add actor_x, eax
	add leftFringe, eax

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

InitMap proc USES eax ebx ecx esi
	
	mov esi, OFFSET gMap
	mov ebx, SIZEOF MapPoint
	mov eax, 0
	mov ecx, 32
L1:
	mov (MapPoint PTR [esi]).coinStart, 128
	mov (MapPoint PTR [esi]).coinEnd, 256
	mov (MapPoint PTR [esi]).coinType,GOLDEN_COIN
	add esi, ebx
	Loop L1 
	ret

InitMap endp

end start


