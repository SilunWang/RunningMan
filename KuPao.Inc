;------ include inc and lib ----
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include masm32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib masm32.lib

WINDOW_WIDTH equ 1024
WINDOW_HEIGHT equ 576
;窗体相对坐标
WINDOW_X equ 170
WINDOW_Y equ 100
;小人的稳定位置
STEADY_X equ 200
;背景图片的宽度
BACKG_WIDTH equ 1024

BM_BACKGROUND equ 1000
ICON_ACTOR equ 1001
BM_BACKGROUND1 equ 1002
ICON_GOLDEN_COIN equ 1003
ICON_SILVER_COIN equ 1004
ICON_RAINBOW_COIN equ 1005
BM_FLOOR equ 1006
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

;刷新间隔
FREQUENCY equ 15

TIMERID equ 1

.data
	BackgroundDc  dd ?
	FloorDc dd ?
	
	hBackg dd ?
	hActor dd ?
	hGoldenCoin dd ?
	hSilverCoin dd ?
	hRainbowCoin dd ?
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
	
	testStr db "Stage Clear",0
   	testStr2 db "Message",0
   	
WMPaint proto,p1:DWORD,p2:DWORD
DrawMapPoint proto,p1:DWORD,p2:DWORD

LoadRes proto:HWND
InitMap proto

KeyDownCallBack proto:DWORD
ActorMove proto:DWORD
Repaint proto:HWND
UpdateData proto




