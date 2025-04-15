.386
.model flat, stdcall
option casemap:none

INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib

extern GameStart@0 : PROC    ; <-- decorated name

.data
.code

main PROC
    call GameStart@0         ; <-- match decoration
    
    
    push 0
    call ExitProcess
main ENDP

END main
