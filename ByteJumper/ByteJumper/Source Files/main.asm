
option casemap:none

INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib

extern GameStart@0 : near
extern GameInit@0 : near
.data
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



    call GameInit@0
    ;call GameStart@0
    exit
main ENDP
END main
