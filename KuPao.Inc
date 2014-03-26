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
WINDOW_X equ 170
WINDOW_Y equ 100
STEADY_X equ 200

BM_BACKGROUND equ 1000
ICON_ACTOR equ 1001
BM_BACKGROUND1 equ 1002
ICON_GOLDEN_COIN equ 1003

FREQUENCY equ 30



.data
	BackgroundDc  dd ?

	hBackg dd ?
	hActor dd ?
	hGoldenCoin dd ?
	
	testStr db "heheaa",0
   	testStr2 db "hheaaa",0

WMPaint proto,p1:DWORD,p2:DWORD
DrawMapPoint proto,p1:DWORD,p2:DWORD

LoadRes proto:HWND
InitMap proto

KeyDownCallBack proto:DWORD
ActorMove proto:DWORD
Repaint proto:HWND
UpdateData proto




