INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
.data
timerDisplay     BYTE "Time: ", 0
digits       BYTE 12 DUP(0)
timerCounter DWORD 0

.code
Timer PROC 
    ; Timer location
    mov dh, 0
    mov dl, 0
    call Gotoxy

    ; Print "Time: "
    mov edx, OFFSET timerDisplay
    call WriteString

    ; Print counter
    mov eax, timerCounter
    call WriteDec
   
    inc timerCounter

    ret
Timer ENDP
END timer
