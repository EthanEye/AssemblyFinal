INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
.data
timerDisplay     BYTE "TIME: ", 0
digits       BYTE 12 DUP(0)
timerCounter DWORD 0

.code
Timer PROC 

    mov eax, green
    call SetTextColor
    ; Timer location
    mov dh, 0
    mov dl, 20
    call Gotoxy

    ; Print "Time: "
    mov edx, OFFSET timerDisplay
    call WriteString

    ; Print counter
    mov eax, timerCounter
    call WriteDec

    mov eax, white
    call SetTextColor
   
    inc timerCounter

    ret
Timer ENDP
END timer
