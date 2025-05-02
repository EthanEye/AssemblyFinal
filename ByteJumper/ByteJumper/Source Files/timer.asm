INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib

.data
timerDisplay     BYTE "Time: ", 0
clearSpaceStr    BYTE "             ", 0    ; enough to overwrite entire old text
digits           BYTE 12 DUP(0)
timerCounter     DWORD 0

.code
Timer PROC 

    ; === Set text color to green ===
    mov eax, green
    call SetTextColor

    ; Clear previous timer output
    mov dh, 0
    mov dl, 0
    call Gotoxy

    mov edx, OFFSET clearSpaceStr
    call WriteString

    ; Move to timer position again
    mov dh, 0
    mov dl, 0
    call Gotoxy

    ; Print "Time: "
    mov edx, OFFSET timerDisplay
    call WriteString

    ; Convert timerCounter into minutes and seconds
    mov eax, timerCounter
    xor edx, edx
    mov ecx, 60
    div ecx            ; EAX = minutes, EDX = seconds

    push edx           ; save seconds
    call WriteDec      ; print minutes

    mov al, ':'        ; print colon
    call WriteChar

    pop eax            ; restore seconds
    call WriteDec

    ; Reset text color to green
    mov eax, white
    call SetTextColor

    ; Increment counter 
    inc timerCounter

    ret
Timer ENDP
END Timer
