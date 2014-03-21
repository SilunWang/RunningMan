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

BM_BACKGROUND equ 1000
BM_ACTOR equ 1001

ACTOR_RUN  equ 2000
ACTOR_JUMP equ 2001
ACTOR_CROUCH equ 2002

.data
	BackDc  dd ?
	ActorDc dd ?
	hBackg dd ?
	hActor dd ?

WMPaint proto:DWORD
LoadRes proto:HWND
KeyDownCallBack proto:DWORD
ActorMove proto:DWORD
Repaint proto:HWND
UpdateData proto


