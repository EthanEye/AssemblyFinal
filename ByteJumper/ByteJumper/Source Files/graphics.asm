INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib 

extern WriteConsoleW@20 : PROC  ;  declare external WinAPI
extern GetStdHandle@4 : PROC


; SCREEN HEIGHT AND WIDTH
ROWS = 25 ; Y
COLS = 120 ; X  

; SCREEN SIZE
SCREENSIZE = ROWS * COLS
.data
; PRINTING UNICODE
outputHandle DWORD ?
tempChar WORD ?
bytesWritten DWORD ?
newChar WORD 2584h
gameBoard WORD ROWS * COLS DUP('X') ;
bigText1 BYTE " ______     __  __     ______   ______          __     __  __     __    __     ______   ______     ______    ", 10,0  
bigText2 BYTE "/\  == \   /\ \_\ \   /\__  _\ /\  ___\        /\ \   /\ \/\ \   /\ -./  \    /\  == \ /\  ___\   /\  == \  ", 10,0 
bigText3 BYTE "\ \  __<   \ \____ \  \/_/\ \/ \ \  __\       _\_\ \  \ \ \_\ \  \ \ \-./\ \  \ \  _-/ \ \  __\   \ \  __< " , 10,0 
bigText4 BYTE " \ \_____\  \/\_____\    \ \_\  \ \_____\    /\_____\  \ \_____\  \ \_\ \ \_\  \ \_\    \ \_____\  \ \_\ \_\", 10, 0
bigText5 BYTE "  \/_____/   \/_____/     \/_/   \/_____/    \/_____/   \/_____/   \/_/  \/_/   \/_/     \/_____/   \/_/ /_/ ", 10,0                                                                                                            

.code

; Welcome Screen Message, "Play Button", Title Screen, Rules etc...
GameStart PROC
    mov edx, OFFSET bigText1
    call WriteString
    mov edx, OFFSET bigText2
    call WriteString
    mov edx, OFFSET bigText3
    call WriteString
    mov edx, OFFSET bigText4
    call WriteString
    mov edx, OFFSET bigText5
    call WriteString
    call WaitMsg
   
    mov eax, 10 ; this is the x value
    mov ebx, 10 ; this is the y value
    mov newChar, 2584h
    call ChangeChar
    ;call GetConsoleUi
    
    ret
    GameStart ENDP





GetConsoleUi PROC
   

; Get console handle once
    push -11
    call GetStdHandle@4
    mov outputHandle, eax
    call Clrscr
  
    
  mov ecx, 0

fill:
    cmp ecx, SCREENSIZE
    jge endUpdate

    ; Print newline every COLS
    mov eax, ecx
    xor edx, edx
    mov ebx, COLS
    div ebx
    cmp edx, 0
    jne skip
    call Crlf

skip:
    push ecx                   ; preserve ECX
    mov eax, ecx
    shl eax, 1                 ; index * 2
    mov ax, WORD PTR gameBoard[eax]
    mov tempChar, ax
    push 0
    push offset bytesWritten
    push 1
    push offset tempChar
    push outputHandle
    call WriteConsoleW@20
    pop ecx                    ; restore ECX
    inc ecx
    jmp fill

endUpdate:

  
    ret


ret
GetConsoleUi ENDP


ChangeChar PROC
    ; Flip Y: edx = ROWS - ebx
    mov edx, ROWS
    sub edx, ebx              ; flippedY

    ; Calculate index = (flippedY * COLS) + X
    imul edx, COLS            ; edx = row * COLS
    add edx, eax              ; edx = (row * COLS) + col

    ; Scale index for WORD array (2 bytes per element)
    shl edx, 1                ; edx = edx * 2

    ; Write new character to gameBoard
    mov ax, newChar
    mov WORD PTR gameBoard[edx], ax

    ret
ChangeChar ENDP
END 