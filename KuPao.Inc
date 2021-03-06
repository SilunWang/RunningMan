;------ include inc and lib ----
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include masm32.inc
include winmm.inc;

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib masm32.lib
includelib WINMM.lib

WINDOW_WIDTH equ 1024
WINDOW_HEIGHT equ 576
;窗体相对坐标
WINDOW_X equ 170
WINDOW_Y equ 100
;小人的稳定位置
STEADY_X equ 200
;背景图片的宽度
BACKG_WIDTH equ 1024

BM_FLOOR equ 1006
BM_BACKGROUND equ 1007

ICON_ACTOR1_RUN1 equ 1001
ICON_ACTOR1_RUN2 equ 1018
ICON_ACTOR1_JUMP equ 1027
ICON_ACTOR1_LIE equ 1026

ICON_ACTOR2_RUN1 equ 1061
ICON_ACTOR2_RUN2 equ 1062
ICON_ACTOR2_JUMP equ 1063
ICON_ACTOR2_LIE equ 1064

ICON_ACTOR3_RUN1 equ 1071
ICON_ACTOR3_RUN2 equ 1072
ICON_ACTOR3_JUMP equ 1073
ICON_ACTOR3_LIE equ 1074


ICON_GOLDEN_COIN equ 1019
ICON_SILVER_COIN equ 1020
ICON_RAINBOW_COIN equ 1021
ICON_DUCK_BISCUIT equ 1022
ICON_BEAR_BISCUIT equ 1023

ICON_UP_OBSTACLE equ 1024
ICON_DOWN_OBSTACLE equ 1025
ICON_DOWN_OBSTACLE2 equ 1089

ICON_0 equ 1008
ICON_1 equ 1009
ICON_2 equ 1010
ICON_3 equ 1011
ICON_4 equ 1012
ICON_5 equ 1013
ICON_6 equ 1014
ICON_7 equ 1015
ICON_8 equ 1016
ICON_9 equ 1017

FIGURE_1 equ 1050
FIGURE_2 equ 1051
FIGURE_3 equ 1052
FIGURE_4 equ 1053

BG_MUSIC_1 equ 1090
BG_MUSIC_2 equ 1091


BM_INDEX_BACKGROUND equ 1080

ICON_ARROW equ 1055

NULL_HANDLER equ 15555

;刷新间隔
FREQUENCY equ 5

TIMERID equ 1

.data
	BackgroundDc  dd ?
	IndexBackgroundDc dd ?
	FloorDc dd ?
	
	hBackg dd ?
	hActor dd ?
	hActor2 dd ?
	hActor3 dd ?
	hActor4 dd ?
	
	hGoldenCoin dd ?
	hSilverCoin dd ?
	hRainbowCoin dd ?
	hDuckBiscuit dd ?
	hBearBiscuit dd ?
	hUpObstacle dd ?
	hDownObstacle dd ?
	hFloorBmp dd ?
	
	hICON_0 dd ?
	hICON_1 dd ?
	hICON_2 dd ?
	hICON_3 dd ?
	hICON_4 dd ?
	hICON_5 dd ?
	hICON_6 dd ?
	hICON_7 dd ?
	hICON_8 dd ?
	hICON_9 dd ?
	
	hIndexbg dd ?
	
	hArrow dd ?
	
	hFIGURE_1 dd ?
	hFIGURE_2 dd ?
	hFIGURE_3 dd ?
	hFIGURE_4 dd ?
	
	soundFileName1 db ".\Res\music\bgm1.wav",0
	soundFileName2 db ".\Res\music\bgm2.wav",0
	
	testStr db "Stage Clear",0
   	testStr2 db "Message",0
   	testStr3 db "0",0
   	   	
WMPaint proto,p1:DWORD,p2:DWORD
DrawNumber proto,p1:DWORD,p2:DWORD,p3:DWORD
DrawMapPoint proto,p1:DWORD,p2:DWORD

LoadResWelcome proto:HWND
ChooseFigure proto,Dc:DWORD, hWnd:DWORD
ArrowLeft proto
ArrowRight proto
pressEnter proto:DWORD

LoadRes proto:HWND
InitMap proto

KeyDownCallBack proto,p1:DWORD,p2:DWORD
ActorMove proto:DWORD
Repaint proto:HWND
UpdateData proto

LoadMap proto: PTR BYTE
ConvertMap proto: PTR DWORD
CopyMap proto, p1:DWORD, p2:DWORD, p3:DWORD
CreateGlobalMap proto

replay proto
