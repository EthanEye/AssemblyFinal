
option casemap:none

INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib

extern GameStart@0 : near
extern GameEngine@0 : near
extern GetStdHandle@4 : PROC
extern GetConsoleMode@8 : PROC
extern SetConsoleMode@8 : PROC
extern SetConsoleTitleA@4: PROC
extern GetConsoleUi@0 : PROC
extern GameOver@0 : near
extern ShowHowToMenu@0 : near
extern DisplayPlatform@0 : near


.data
titleStr BYTE "Byte Jumper", 0
GWL_STYLE      EQU -16
WS_MAXIMIZEBOX EQU 00010000h
WS_THICKFRAME  EQU 00040000h

.code

; Required PROTOTYPES
GetConsoleWindow PROTO
GetWindowLongA PROTO :DWORD, :DWORD
SetWindowLongA PROTO :DWORD, :DWORD, :DWORD
SetWindowPos PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

main PROC
    ; Set console title
    push OFFSET titleStr
    call SetConsoleTitleA@4
    ; Get the console window handle
    invoke GetConsoleWindow
    mov ebx, eax

    ; Get the current window style
    invoke GetWindowLongA, ebx, GWL_STYLE

    ; Remove the maximize button and resizing border
    and eax, NOT WS_MAXIMIZEBOX
    and eax, NOT WS_THICKFRAME

    ; Apply the new window style
    invoke SetWindowLongA, ebx, GWL_STYLE, eax

    ; Force the window to update with the new style
    invoke SetWindowPos, ebx, 0, 0, 0, 0, 0, 0027h
    ; SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED
    STD_INPUT_HANDLE EQU -10
    ENABLE_QUICK_EDIT_MODE EQU 0x0040
    ENABLE_EXTENDED_FLAGS  EQU 0x0080
   
    ; Game start 
     call GameStart@0

     ;call ShowHowToMenu@0

     call DisplayPlatform@0

    
  
    ; call GameEngine@0

    ; Game over
     ;call GameOver@0
     
    
    exit
main ENDP


END main
