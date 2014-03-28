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
	invoke SetTimer,hwnd, TIMERID,FREQUENCY,NULL

	
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
		invoke UpdateData
		mov eax, base_y
		mov actor_y, eax
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
		.if leftFringe > 3000
			invoke KillTimer,hWnd, TIMERID
			invoke dw2a, totalScore, OFFSET testStr
			invoke MessageBox,0,OFFSET testStr, OFFSET testStr2,0
		.endif
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
	mov edx, 0
	mov eax, leftFringe
	cdq
	mov ebx, BACKG_WIDTH
	idiv ebx
	mov tmpBackground, edx
	;invoke dw2a, leftFringe, OFFSET testStr
	;invoke dw2a,coinEndY, OFFSET testStr2
	;invoke MessageBox,0,OFFSET testStr, OFFSET testStr2,0
	invoke BitBlt,tmpDc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,BackgroundDc,tmpBackground,0,SRCCOPY ;//绘制背景图片1
	mov eax, tmpBackground
	sub eax, BACKG_WIDTH
	invoke BitBlt,tmpDc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,BackgroundDc,eax,0,SRCCOPY ;//绘制背景图片2
	

	;确定左边界点
	mov edx, 0
	mov eax, leftFringe
	cdq
	mov ebx, MAPPOINT_LENGTH
	idiv ebx
	mov leftPoint, eax
	;确定右边界点
	mov edx, 0
	mov eax, leftFringe
	cdq
	add eax, WINDOW_WIDTH
	mov ebx, MAPPOINT_LENGTH
	idiv ebx
	mov rightPoint, eax
	
	;绘制地图点
	mov ebx, leftPoint
	dec ebx
	.WHILE ebx <= rightPoint
		invoke DrawMapPoint,tmpDc, ebx
		inc ebx
	.endw
	
	
	;绘制小人
	mov eax, actor_x
	sub eax, leftFringe
	mov tmpActorX, eax
	.if actorImage < 20
		invoke DrawIconEx,tmpDc,tmpActorX,actor_y,hActor,ACTOR_WIDTH,ACTOR_RUN_HEIGHT,0,0,DI_NORMAL;//绘制小人
		inc actorImage
	.elseif actorImage < 40
		invoke DrawIconEx,tmpDc,tmpActorX,actor_y,hActor2,ACTOR_WIDTH,ACTOR_RUN_HEIGHT,0,0,DI_NORMAL;//绘制小人2
		inc actorImage
	.else
		mov actorImage, 0
	.endif
	
	.if firstDigit == 0
		invoke DrawIconEx,tmpDc,180,40,hICON_0,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif firstDigit == 1
		invoke DrawIconEx,tmpDc,180,40,hICON_1,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif firstDigit == 2
		invoke DrawIconEx,tmpDc,180,40,hICON_2,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif firstDigit == 3
		invoke DrawIconEx,tmpDc,180,40,hICON_3,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif firstDigit == 4
		invoke DrawIconEx,tmpDc,180,40,hICON_4,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif firstDigit == 5
		invoke DrawIconEx,tmpDc,180,40,hICON_5,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif firstDigit == 6
		invoke DrawIconEx,tmpDc,180,40,hICON_6,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif firstDigit == 7
		invoke DrawIconEx,tmpDc,180,40,hICON_7,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif firstDigit == 8
		invoke DrawIconEx,tmpDc,180,40,hICON_8,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif firstDigit == 9
		invoke DrawIconEx,tmpDc,180,40,hICON_9,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.endif
	
	.if secondDigit == 0
		invoke DrawIconEx,tmpDc,120,40,hICON_0,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif secondDigit == 1
		invoke DrawIconEx,tmpDc,120,40,hICON_1,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif secondDigit == 2
		invoke DrawIconEx,tmpDc,120,40,hICON_2,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif secondDigit == 3
		invoke DrawIconEx,tmpDc,120,40,hICON_3,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif secondDigit == 4
		invoke DrawIconEx,tmpDc,120,40,hICON_4,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif secondDigit == 5
		invoke DrawIconEx,tmpDc,120,40,hICON_5,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif secondDigit == 6
		invoke DrawIconEx,tmpDc,120,40,hICON_6,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif secondDigit == 7
		invoke DrawIconEx,tmpDc,120,40,hICON_7,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif secondDigit == 8
		invoke DrawIconEx,tmpDc,120,40,hICON_8,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif secondDigit == 9
		invoke DrawIconEx,tmpDc,120,40,hICON_9,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.endif
	
	.if thirdDigit == 0
		invoke DrawIconEx,tmpDc,60,40,hICON_0,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif thirdDigit == 1
		invoke DrawIconEx,tmpDc,60,40,hICON_1,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif thirdDigit == 2
		invoke DrawIconEx,tmpDc,60,40,hICON_2,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif thirdDigit == 3
		invoke DrawIconEx,tmpDc,60,40,hICON_3,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif thirdDigit == 4
		invoke DrawIconEx,tmpDc,60,40,hICON_4,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif thirdDigit == 5
		invoke DrawIconEx,tmpDc,60,40,hICON_5,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif thirdDigit == 6
		invoke DrawIconEx,tmpDc,60,40,hICON_6,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif thirdDigit == 7
		invoke DrawIconEx,tmpDc,60,40,hICON_7,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif thirdDigit == 8
		invoke DrawIconEx,tmpDc,60,40,hICON_8,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.elseif thirdDigit == 9
		invoke DrawIconEx,tmpDc,60,40,hICON_9,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL;//绘制小人
	.endif
	
	;将背景画到前景
	invoke BitBlt,Dc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,tmpDc,0,0,SRCCOPY ;
	
	
	;释放临时资源	
	invoke ReleaseDC,hWnd,tmpDc
	invoke DeleteObject,tmpBitmap
	invoke DeleteObject,tmpDc
	ret
WMPaint endp

DrawMapPoint proc USES eax ebx ecx edx esi edi,
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
	add esi, pointOffset
	mov eax, SIZEOF MapPoint
	imul eax, pointIndex
	mov pointOffset, eax
	
	;绘制金币/银币等
	
	mov ebx, 0
	lea edi, (MapPoint PTR [esi]).elements
	.while ebx < ELEMENTS_LENGTH
		mov eax, ebx
		imul eax, MAPPOINT_LENGTH
		mov edx, [edi]
		
		.if edx == GOLDEN_COIN
			invoke DrawIconEx,tmpDc,pointX,eax,hGoldenCoin,MAPPOINT_LENGTH,MAPPOINT_LENGTH,0,0,DI_NORMAL;
		.endif
		
		add edi, SIZEOF DWORD
		inc ebx
	.endw
	
	mov ebx, (MapPoint PTR [esi]).ground_y
	.while ebx <= WINDOW_HEIGHT
		invoke BitBlt,tmpDc,pointX,ebx,32,32,FloorDc,0,0,SRCCOPY ;//绘制
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
	
	;地面
	invoke CreateCompatibleDC,Dc
	mov FloorDc,eax
	
	invoke LoadBitmap,hInstance,BM_FLOOR
	mov hFloorBmp,eax
	invoke SelectObject,FloorDc,hFloorBmp ;//将一个Dc和bitmap hd与资源绑定起来
	
	;小人
	invoke LoadImage,hInstance,ICON_ACTOR,IMAGE_ICON,ACTOR_WIDTH,ACTOR_RUN_HEIGHT,LR_DEFAULTCOLOR
	mov hActor,eax
	invoke LoadImage,hInstance,ICON_ACTOR2,IMAGE_ICON,ACTOR_WIDTH,ACTOR_RUN_HEIGHT,LR_DEFAULTCOLOR
	mov hActor2,eax
	
	;金币
	invoke LoadImage,hInstance,ICON_GOLDEN_COIN,IMAGE_ICON,MAPPOINT_LENGTH,MAPPOINT_LENGTH,LR_DEFAULTCOLOR
	mov hGoldenCoin,eax
	
	invoke LoadImage,hInstance,ICON_SILVER_COIN,IMAGE_ICON,MAPPOINT_LENGTH,MAPPOINT_LENGTH,LR_DEFAULTCOLOR
	mov hSilverCoin,eax
	
	invoke LoadImage,hInstance,ICON_RAINBOW_COIN,IMAGE_ICON,MAPPOINT_LENGTH,MAPPOINT_LENGTH,LR_DEFAULTCOLOR
	mov hRainbowCoin,eax
	
	;Numbers
	invoke LoadImage,hInstance,ICON_0,IMAGE_ICON,NUMBER_LENGTH,NUMBER_LENGTH,LR_DEFAULTCOLOR
	mov hICON_0,eax
	
	invoke LoadImage,hInstance,ICON_1,IMAGE_ICON,NUMBER_LENGTH,NUMBER_LENGTH,LR_DEFAULTCOLOR
	mov hICON_1,eax
	
	invoke LoadImage,hInstance,ICON_2,IMAGE_ICON,NUMBER_LENGTH,NUMBER_LENGTH,LR_DEFAULTCOLOR
	mov hICON_2,eax
	
	invoke LoadImage,hInstance,ICON_3,IMAGE_ICON,NUMBER_LENGTH,NUMBER_LENGTH,LR_DEFAULTCOLOR
	mov hICON_3,eax
	
	invoke LoadImage,hInstance,ICON_4,IMAGE_ICON,NUMBER_LENGTH,NUMBER_LENGTH,LR_DEFAULTCOLOR
	mov hICON_4,eax
	
	invoke LoadImage,hInstance,ICON_5,IMAGE_ICON,NUMBER_LENGTH,NUMBER_LENGTH,LR_DEFAULTCOLOR
	mov hICON_5,eax
	
	invoke LoadImage,hInstance,ICON_6,IMAGE_ICON,NUMBER_LENGTH,NUMBER_LENGTH,LR_DEFAULTCOLOR
	mov hICON_6,eax
	
	invoke LoadImage,hInstance,ICON_7,IMAGE_ICON,NUMBER_LENGTH,NUMBER_LENGTH,LR_DEFAULTCOLOR
	mov hICON_7,eax
	
	invoke LoadImage,hInstance,ICON_8,IMAGE_ICON,NUMBER_LENGTH,NUMBER_LENGTH,LR_DEFAULTCOLOR
	mov hICON_8,eax
	
	invoke LoadImage,hInstance,ICON_9,IMAGE_ICON,NUMBER_LENGTH,NUMBER_LENGTH,LR_DEFAULTCOLOR
	mov hICON_9,eax
	 
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

DisplayScore proc
	pushad
	
	mov eax, totalScore
	cdq
	
	mov ebx, 10
	idiv ebx
	mov firstDigit, edx
	cdq
	mov ebx, 10
	idiv ebx
	mov secondDigit, edx
	cdq
	mov ebx, 10
	idiv ebx
	mov thirdDigit, edx
	
	;invoke dw2a, secondDigit, OFFSET testStr
	;invoke MessageBox,0,OFFSET testStr, OFFSET testStr2,0
	popad
	ret

DisplayScore endp

UpdateData proc USES eax ebx edx esi edi
	mov eax, actorSpeed_x
	add actor_x, eax
	add leftFringe, eax
	
	;取出数组偏移地址
	mov ebx, MAPPOINT_LENGTH
	mov eax, actor_x
	cdq
	idiv ebx
	imul eax, SIZEOF MapPoint
	mov esi, OFFSET gMap
	add esi, eax
	
	;取出地面高度，base_y：头的高度
	mov eax, (MapPoint PTR [esi]).ground_y
	mov base_y, eax
	sub base_y, ACTOR_RUN_HEIGHT
	
	;更新人的状态
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
	.endif
	
	;更新金币状态
	mov ebx, MAPPOINT_LENGTH
	mov eax, actor_y
	cdq
	idiv ebx
	lea edi, (MapPoint PTR [esi]).elements
	imul eax, 4
	add edi, eax
	mov ebx, NONE_ELEMENT
	.if [edi] != ebx
		mov [edi], ebx
		add totalScore, GOLDEN_COIN
	.endif
	add edi, 4
	.if [edi] != ebx
		mov [edi], ebx
		add totalScore, GOLDEN_COIN
	.endif
	mov [edi], ebx
	add edi, 4
	.if [edi] != ebx
		mov [edi], ebx
		add totalScore, GOLDEN_COIN
		
	.endif
	mov [edi], ebx
	invoke DisplayScore
	ret

UpdateData endp



InitMap proc USES eax ebx ecx esi
	
	mov esi, OFFSET gMap
	mov ebx, SIZEOF MapPoint
	mov eax, 0
	mov ecx, 60
L1:
	add esi, ebx
	;Loop L1
	ret

InitMap endp

end start


