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
		invoke LoadRes,hWnd
		invoke CreateGlobalMap
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
		.if leftFringe > TotalXLimit
			invoke KillTimer,hWnd, TIMERID
			invoke dw2a, totalScore, OFFSET gameSucceed
			invoke MessageBox,0,OFFSET gameSucceed, OFFSET gameSucceedTitle,0
		.endif
		.if isGameOver == 1
			invoke KillTimer,hWnd, TIMERID
			invoke dw2a, totalScore, OFFSET gameOver
			invoke MessageBox,hWnd,OFFSET gameOver, OFFSET gameOverTitle,0
			invoke replay
			invoke SetTimer, hWnd, TIMERID,FREQUENCY,NULL
		.endif
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam		
		ret
	.ENDIF
	
	xor eax,eax
	ret
WndProc endp

replay Proc
	
	mov actor_x,200
	mov actor_y,300
	
	mov base_x,168;与屏幕左边界默认值的差值基准
	mov base_y,300
	
	mov actorSpeed_x,6
	mov actorSpeed_y,0
	
	mov totalScore,0
	mov firstDigit,0
	mov secondDigit,0
	mov thirdDigit,0
	mov fourthDigit,0
	mov fifthDigit,0
	
	mov actorState,0
	mov actorImage,0
	mov actorLie,0
	
	;小人被阻塞
	mov isBlocked,0
	
	mov isGameOver, 0
	
	mov leftFringe,32
	
	invoke CreateGlobalMap
	
	ret

replay endp

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
	
	.if actorState == ACTOR_LIE
		mov eax, actor_y
		;小人躺着和站着高度差32
		add eax, 32
		.if actorLie < 40
			invoke DrawIconEx,tmpDc,tmpActorX,eax,hActor3,ACTOR_WIDTH,ACTOR_LIE_HEIGHT,0,0,DI_NORMAL;//绘制小人
			inc actorLie
		.else
			mov actorLie, 0
			mov actorState, ACTOR_RUN
			invoke DrawIconEx,tmpDc,tmpActorX,eax,hActor3,ACTOR_WIDTH,ACTOR_LIE_HEIGHT,0,0,DI_NORMAL;//绘制小人
		.endif
	
	.elseif actorState == ACTOR_RUN
		.if actorImage < 20
			invoke DrawIconEx,tmpDc,tmpActorX,actor_y,hActor,ACTOR_WIDTH,ACTOR_RUN_HEIGHT,0,0,DI_NORMAL;//绘制小人
			inc actorImage
		.elseif actorImage < 40
			invoke DrawIconEx,tmpDc,tmpActorX,actor_y,hActor2,ACTOR_WIDTH,ACTOR_RUN_HEIGHT,0,0,DI_NORMAL;//绘制小人2
			inc actorImage
		.else
			mov actorImage, 0
			invoke DrawIconEx,tmpDc,tmpActorX,actor_y,hActor,ACTOR_WIDTH,ACTOR_RUN_HEIGHT,0,0,DI_NORMAL;//绘制小人
		.endif
	.elseif actorState == ACTOR_JUMP1 || actorState == ACTOR_JUMP2
		invoke DrawIconEx,tmpDc,tmpActorX,actor_y,hActor4,ACTOR_JUMP_SIZE,ACTOR_JUMP_SIZE,0,0,DI_NORMAL;//绘制小人

	.endif
	
	;画数字
	invoke DrawNumber, firstDigit, 930, tmpDc
	invoke DrawNumber, secondDigit, 870, tmpDc
	invoke DrawNumber, thirdDigit, 810, tmpDc
	invoke DrawNumber, fourthDigit, 750, tmpDc
	invoke DrawNumber, fifthDigit, 690, tmpDc
	
	;将背景画到前景
	invoke BitBlt,Dc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,tmpDc,0,0,SRCCOPY ;
	
	
	;释放临时资源	
	invoke ReleaseDC,hWnd,tmpDc
	invoke DeleteObject,tmpBitmap
	invoke DeleteObject,tmpDc
	ret
WMPaint endp

DrawNumber proc USES eax ebx ecx edx esi edi,
	number: DWORD,
	xPos: DWORD,
	tmpDc:DWORD
	
	.if number == 0
		invoke DrawIconEx,tmpDc,xPos,30,hICON_0,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL
	.elseif number == 1
		invoke DrawIconEx,tmpDc,xPos,30,hICON_1,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL
	.elseif number == 2
		invoke DrawIconEx,tmpDc,xPos,30,hICON_2,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL
	.elseif number == 3
		invoke DrawIconEx,tmpDc,xPos,30,hICON_3,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL
	.elseif number == 4
		invoke DrawIconEx,tmpDc,xPos,30,hICON_4,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL
	.elseif number == 5
		invoke DrawIconEx,tmpDc,xPos,30,hICON_5,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL
	.elseif number == 6
		invoke DrawIconEx,tmpDc,xPos,30,hICON_6,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL
	.elseif number == 7
		invoke DrawIconEx,tmpDc,xPos,30,hICON_7,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL
	.elseif number == 8
		invoke DrawIconEx,tmpDc,xPos,30,hICON_8,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL
	.elseif number == 9
		invoke DrawIconEx,tmpDc,xPos,30,hICON_9,NUMBER_LENGTH,NUMBER_LENGTH,0,0,DI_NORMAL
	.endif
	
	ret

DrawNumber endp

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
	
	;绘制障碍物
	mov ebx, (MapPoint PTR [esi]).obstacleType
	.if ebx == UP_OBSTACLE
		mov eax, 3
		mov ebx, MAPPOINT_LENGTH
		mul ebx
		mov ebx, (MapPoint PTR [esi]).ground_y
		sub ebx, eax
		invoke DrawIconEx,tmpDc,pointX,ebx,hUpObstacle,UP_OB_WIDTH,UP_OB_HEIGHT,0,0,DI_NORMAL;	
	.endif
	
	mov ebx, (MapPoint PTR [esi]).obstacleType
	.if ebx == DOWN_OBSTACLE
		mov edx, (MapPoint PTR [esi]).ground_y
		sub edx, DOWN_OBSTACLE_GAP
		sub edx, DOWN_OBSTACLE_GAP
		L1:	
		push edx
		invoke DrawIconEx,tmpDc,pointX,edx,hDownObstacle,DOWN_OB_WIDTH,DOWN_OB_HEIGHT,0,0,DI_NORMAL;
		pop edx
		sub edx, 64
		cmp edx, -64
		jg L1
		L2:
	.endif
	
	;绘制金币/银币等
	mov ebx, 0
	lea edi, (MapPoint PTR [esi]).elements
	.while ebx < ELEMENTS_LENGTH
		mov eax, ebx
		imul eax, MAPPOINT_LENGTH
		mov edx, [edi]
		
		.if edx == GOLDEN_COIN
			invoke DrawIconEx,tmpDc,pointX,eax,hGoldenCoin,MAPPOINT_LENGTH,MAPPOINT_LENGTH,0,0,DI_NORMAL;
		.elseif edx == SILVER_COIN
			invoke DrawIconEx,tmpDc,pointX,eax,hSilverCoin,MAPPOINT_LENGTH,MAPPOINT_LENGTH,0,0,DI_NORMAL;
		.elseif edx == RAINBOW_COIN
			invoke DrawIconEx,tmpDc,pointX,eax,hRainbowCoin,MAPPOINT_LENGTH,MAPPOINT_LENGTH,0,0,DI_NORMAL;
		.elseif edx == DUCK_BISCUIT
			invoke DrawIconEx,tmpDc,pointX,eax,hDuckBiscuit,MAPPOINT_LENGTH,MAPPOINT_LENGTH,0,0,DI_NORMAL;
		.elseif edx == BEAR_BISCUIT
			invoke DrawIconEx,tmpDc,pointX,eax,hBearBiscuit,MAPPOINT_LENGTH,MAPPOINT_LENGTH,0,0,DI_NORMAL;
	
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

LoadRes proc USES eax ebx esi edi,
	hWnd:HWND
LOCAL Dc:DWORD
	invoke GetDC,hWnd
	mov Dc,eax
	
	;背景
	invoke CreateCompatibleDC,Dc
	mov BackgroundDc,eax

	invoke LoadBitmap,hInstance,BM_BACKGROUND
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
	invoke LoadImage,hInstance,ICON_ACTOR3,IMAGE_ICON,ACTOR_WIDTH,ACTOR_LIE_HEIGHT,LR_DEFAULTCOLOR
	mov hActor3,eax
	invoke LoadImage,hInstance,ICON_ACTOR4,IMAGE_ICON,ACTOR_JUMP_SIZE,ACTOR_JUMP_SIZE,LR_DEFAULTCOLOR
	mov hActor4,eax
	
	;币和饼干
	invoke LoadImage,hInstance,ICON_GOLDEN_COIN,IMAGE_ICON,MAPPOINT_LENGTH,MAPPOINT_LENGTH,LR_DEFAULTCOLOR
	mov hGoldenCoin,eax
	
	invoke LoadImage,hInstance,ICON_SILVER_COIN,IMAGE_ICON,MAPPOINT_LENGTH,MAPPOINT_LENGTH,LR_DEFAULTCOLOR
	mov hSilverCoin,eax
	
	invoke LoadImage,hInstance,ICON_RAINBOW_COIN,IMAGE_ICON,MAPPOINT_LENGTH,MAPPOINT_LENGTH,LR_DEFAULTCOLOR
	mov hRainbowCoin,eax
	
	invoke LoadImage,hInstance,ICON_DUCK_BISCUIT,IMAGE_ICON,MAPPOINT_LENGTH,MAPPOINT_LENGTH,LR_DEFAULTCOLOR
	mov hDuckBiscuit,eax
	
	invoke LoadImage,hInstance,ICON_BEAR_BISCUIT,IMAGE_ICON,MAPPOINT_LENGTH,MAPPOINT_LENGTH,LR_DEFAULTCOLOR
	mov hBearBiscuit,eax
	
	;障碍物
	invoke LoadImage,hInstance,ICON_UP_OBSTACLE,IMAGE_ICON,UP_OB_WIDTH,UP_OB_HEIGHT,LR_DEFAULTCOLOR
	mov hUpObstacle,eax
	
	invoke LoadImage,hInstance,ICON_DOWN_OBSTACLE,IMAGE_ICON,DOWN_OB_WIDTH,DOWN_OB_HEIGHT,LR_DEFAULTCOLOR
	mov hDownObstacle,eax
	
	;数字
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
	.elseif eax == VK_DOWN
		invoke ActorMove,VK_DOWN

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
	
	.if eax == VK_DOWN && actorState != ACTOR_JUMP1 && actorState != ACTOR_JUMP2
		mov actorState, ACTOR_LIE
		mov actorLie, 0
	.endif
	
	ret

ActorMove endp

Repaint proc hWnd:HWND
LOCAL R:RECT

  invoke GetClientRect,hWnd,Addr R
  invoke InvalidateRect,hWnd,Addr R,0
  ret

Repaint endp

CalculateScoreDigit proc
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
	cdq
	mov ebx, 10
	idiv ebx
	mov fourthDigit, edx
	cdq
	mov ebx, 10
	idiv ebx
	mov fifthDigit, edx
	
	;invoke dw2a, secondDigit, OFFSET testStr
	;invoke MessageBox,0,OFFSET testStr, OFFSET testStr2,0
	popad
	ret

CalculateScoreDigit endp


UpdateData proc USES eax ebx ecx edx esi edi

LOCAL actorHeadElement: DWORD
	mov eax, actorSpeed_x
	add leftFringe, eax
	.if isBlocked == 0
		add actor_x, eax
		mov edx, actor_x
		sub edx, leftFringe
		.if edx < base_x
			add actor_x, 2
		.endif
	.endif
	
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
	
	mov eax, actor_y
	.if (actorState == ACTOR_RUN || actorState == ACTOR_LIE) && eax < base_y
		mov actorSpeed_y, 0
		mov actorState, ACTOR_JUMP1
	.endif
	
	.if actorState == ACTOR_LIE && isBlocked == 1
		mov isBlocked, 0
	.endif
	
	mov edi, esi
	add edi, SIZEOF MapPoint
	
	;更新金币状态
	mov ebx, MAPPOINT_LENGTH
	mov eax, actor_y
	cdq
	idiv ebx
	lea edi, (MapPoint PTR [edi]).elements
	imul eax, 4
	
	;更新得分
	add edi, eax
	mov ebx, NONE_ELEMENT
	.if [edi] != ebx
		mov edx, [edi]
		add totalScore, edx
		mov [edi], ebx
	.endif
	add edi, SIZEOF DWORD
	.if [edi] != ebx
		mov edx, [edi]
		add totalScore, edx
		mov [edi], ebx
	.endif
	mov [edi], ebx
	add edi, SIZEOF DWORD
	.if [edi] != ebx
		mov edx, [edi]
		add totalScore, edx
		mov [edi], ebx
	.endif
	mov [edi], ebx
	invoke CalculateScoreDigit
	
	;小人重心偏移到中轴
	mov edi, esi
	add edi, SIZEOF MapPoint
	
	;检测死亡-UpObstacle碰撞检测
	;前身基准
	mov ebx, UP_OBSTACLE
	mov ecx, (MapPoint PTR [edi]).obstacleType 
	.if ebx == ecx
		mov eax, actor_y
		add eax, ACTOR_RUN_HEIGHT
		mov edx, (MapPoint PTR [edi]).ground_y
		sub edx, 96
		mov ecx, (MapPoint PTR [edi]).ground_y
		.if eax <= ecx && eax >= edx
			mov isGameOver, 1
		.endif	
	.endif
	;后身基准
	mov ebx, UP_OBSTACLE
	mov ecx, (MapPoint PTR [esi]).obstacleType 
	.if ebx == ecx
		mov eax, actor_y
		add eax, ACTOR_RUN_HEIGHT
		mov edx, (MapPoint PTR [esi]).ground_y
		sub edx, 96
		mov ecx, (MapPoint PTR [esi]).ground_y
		.if eax <= ecx && eax >= edx
			mov isGameOver, 1
		.endif	
	.endif
	
	;检测阻塞碰撞
	mov ebx, DOWN_OBSTACLE

	mov ecx, (MapPoint PTR [edi]).obstacleType 
	.if ebx == ecx && actorState != ACTOR_LIE
		mov isBlocked, 1
	.endif
	
	;检测地面阻塞
	mov ebx, (MapPoint PTR [edi]).ground_y
	mov eax, actor_y
	add eax, ACTOR_RUN_HEIGHT
	.if eax > ebx
		mov isBlocked, 2
	.elseif isBlocked != 1
		mov isBlocked, 0
	.endif
	
	;检测阻塞死亡
	mov ebx, leftFringe
	.if actor_x < ebx
		mov isGameOver, 1
	.endif
	ret

UpdateData endp



LoadMap proc USES eax ecx edx esi edi,
	MapName: PTR BYTE ;需要打开的map文件的文件名
	
LOCAL hFile:DWORD
LOCAL readSize: DWORD
	invoke CreateFile, MapName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	mov  hFile, eax
	lea edx, readSize
	invoke ReadFile, hFile, OFFSET MapBuffer, MapBufferSize, edx, NULL
	invoke CloseHandle, hFile
	
	mov ecx, readSize

	mov esi, OFFSET MapBuffer
	mov edi, OFFSET MapFlag
	;
L1:	
	push ecx
	mov eax, 0
	mov al, [esi]

	cmp al, 10
	je L2
	cmp al, 13
	je L2
	mov [edi], eax
	inc edi
L2:

	inc esi
	pop ecx
	Loop L1
	
	ret
LoadMap endp

ConvertMap proc USES eax ebx ecx edx esi edi,
	AddrMap:  PTR DWORD, ;需要存入的map数组的地址
	
	mov esi, OFFSET MapFlag
	mov edi, AddrMap
	
	mov ecx, MapSize
L1:
	push ecx
	mov edx, 0
	mov dl, [esi]
	;invoke dw2a, edx, OFFSET testStr2
	;invoke MessageBox,0,OFFSET testStr3, OFFSET testStr2,0
	
	.if edx == 'a'
		mov eax, GOLDEN_COIN
	.elseif dl == 'b'
		mov eax, SILVER_COIN
	.elseif dl == 'c'
		mov eax, RAINBOW_COIN
	.elseif dl == 'd'
		mov eax, DUCK_BISCUIT
	.elseif dl == 'e'
		mov eax, BEAR_BISCUIT
	.elseif dl >= '1' && dl <= '9'
		mov eax, 0
		mov al, dl 
		sub eax, '0'
		mov ebx, 32
		mul ebx
		neg eax
		add eax, WINDOW_HEIGHT
	.elseif dl == 'x'
		mov eax, UP_OBSTACLE
	.elseif dl == 'y'
		mov eax, DOWN_OBSTACLE
	.else 
		mov eax, 0
	.endif
	
	mov [edi], eax
	inc esi
	add edi, SIZEOF SDWORD
	pop ecx
	dec ecx
	cmp ecx, 0
	jg L1
	
	ret
ConvertMap endp

CreateGlobalMap proc USES eax ebx ecx edx esi edi


	invoke LoadMap, OFFSET Map1
	invoke ConvertMap, OFFSET gMap1

	invoke LoadMap, OFFSET Map2
	invoke ConvertMap, OFFSET gMap2
		
	invoke LoadMap, OFFSET Map3
	invoke ConvertMap, OFFSET gMap3
	
	invoke LoadMap, OFFSET Map4
	invoke ConvertMap, OFFSET gMap4
	
	invoke LoadMap, OFFSET Map5
	invoke ConvertMap, OFFSET gMap5
	
	mov ecx, MapNum
	mov esi, OFFSET firstStage
	mov edi, OFFSET gMap

L1:	
	mov eax, [esi]
	sub eax, 1
	mov ebx, SIZEOF gMap1
	mul ebx
	;得到的eax为复制的地图源的地址
	add eax, OFFSET gMap1
	
	pushad
	;invoke dw2a, eax, OFFSET testStr2
	;invoke MessageBox,0,OFFSET testStr2, OFFSET testStr2,0
	popad
	
	;得到的edi为地图目标的地址
	invoke CopyMap, eax, edi, SIZEOF gMap1
	
	
	add esi, 4
	add edi, SIZEOF gMap1
	Loop L1

	ret

CreateGlobalMap endp

CopyMap proc uses eax ebx ecx edx esi edi,
	SrcAddr: DWORD,
	DestAddr: DWORD,
	mMapSize: DWORD
	
	mov esi, SrcAddr
	mov edi, DestAddr
	
	mov eax, mMapSize
	cdq
	mov ebx, 4
	div ebx
	;得到的ecx为循环次数
	mov ecx, eax

L1:
	mov eax, [esi]
	mov [edi], eax
	add esi, 4
	add edi, 4
	Loop L1
		
	ret

CopyMap endp

end start


