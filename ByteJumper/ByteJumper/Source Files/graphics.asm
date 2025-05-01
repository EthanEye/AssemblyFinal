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
; UNICODE FOR BOX FRAME


gameBoard WORD ROWS * COLS DUP(' ') ;
bigText1 BYTE "        ______     __  __     ______   ______          __     __  __     __    __     ______   ______     ______    ", 10,0  
bigText2 BYTE "       /\  == \   /\ \_\ \   /\__  _\ /\  ___\        /\ \   /\ \/\ \   /\ -./  \    /\  == \ /\  ___\   /\  == \  ", 10,0 
bigText3 BYTE "       \ \  __<   \ \____ \  \/_/\ \/ \ \  __\       _\_\ \  \ \ \_\ \  \ \ \-./\ \  \ \  _-/ \ \  __\   \ \  __< " , 10,0 
bigText4 BYTE "        \ \_____\  \/\_____\    \ \_\  \ \_____\    /\_____\  \ \_____\  \ \_\ \ \_\  \ \_\    \ \_____\  \ \_\ \_\", 10, 0
bigText5 BYTE "         \/_____/   \/_____/     \/_/   \/_____/    \/_____/   \/_____/   \/_/  \/_/   \/_/     \/_____/   \/_/ /_/ ", 10,0                                                                                                            




howToPlay0 BYTE "+----------------------------------------------+",10,0
howToPlay1 BYTE "|                  HOW TO PLAY                 |",10,0
howToPlay2 BYTE "|           MOVE: A(LEFT), D(RIGHT)            |",10,0
howToPlay3 BYTE "|           JUMP: SPACE BAR                    |",10,0
howToPlay4 BYTE "|           LAND ON PLATFORMS TO SURVIVE       |",10,0
howToPlay5 BYTE "|           MISS A PLATFORM === GAME OVER      |",10,0
howToPlay6 BYTE "+----------------------------------------------+",10,0

gameOverText1 BYTE "         ______    ______   __       __  ________         ______   __     __  ________  _______",10,0
gameOverText2 BYTE "        /      \  /      \ |  \     /  \|        \       /      \ |  \   |  \|        \|       \",10,0
gameOverText3 BYTE "       |  $$$$$$\|  $$$$$$\| $$\   /  $$| $$$$$$$$      |  $$$$$$\| $$   | $$| $$$$$$$$| $$$$$$$\",10,0
gameOverText4 BYTE "       | $$ __\$$| $$__| $$| $$$\ /  $$$| $$__          | $$  | $$| $$   | $$| $$__    | $$__| $$",10,0
gameOverText5 BYTE "       | $$|    \| $$    $$| $$$$\  $$$$| $$  \         | $$  | $$ \$$\ /  $$| $$  \   | $$    $$",10,0
gameOverText6 BYTE "       | $$ \$$$$| $$$$$$$$| $$\$$ $$ $$| $$$$$         | $$  | $$  \$$\  $$ | $$$$$   | $$$$$$$\",10,0
gameOverText7 BYTE "       | $$__| $$| $$  | $$| $$ \$$$| $$| $$_____       | $$__/ $$   \$$ $$  | $$_____ | $$  | $$",10,0
gameOverText8 BYTE "        \$$    $$| $$  | $$| $$  \$ | $$| $$     \       \$$    $$    \$$$   | $$     \| $$  | $$",10,0
gameOverText9 BYTE "         \$$$$$$  \$$   \$$ \$$      \$$ \$$$$$$$$        \$$$$$$      \$     \$$$$$$$$ \$$   \$$",10,0
                                                                                          
                                                                                       
                                                                                          



.code

; Welcome Screen Message, "Play Button", Title Screen, Rules etc...
GameStart PROC
    mov ecx, 0
    centerScreen:
    cmp ecx, 10
    je endCenter_
    call Crlf
    inc ecx
    jmp centerScreen
    endCenter_:
    mov eax, cyan
    call SetTextColor
    mov edx, OFFSET bigText1
    call WriteString
    mov eax, cyan
    call SetTextColor
    mov edx, OFFSET bigText2
    mov eax, cyan
    call SetTextColor
    call WriteString
    mov edx, OFFSET bigText3
    mov eax, cyan
    call SetTextColor
    call WriteString
    mov edx, OFFSET bigText4
    mov eax, cyan
    call SetTextColor
    call WriteString
    mov edx, OFFSET bigText5
    mov eax, cyan
    call SetTextColor
    call WriteString
    mov eax, 3000   ; time in milliseconds
    call Delay 
    mov dh, 0
    mov dl, 0
    call Gotoxy      ; Clears the screen
 
    ;call GetConsoleUi
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

ShowHowToMenu PROC
    call Clrscr
    mov edx, OFFSET howToPlay0
    call WriteString
    mov edx, OFFSET howToPlay1
    call WriteString
    mov edx, OFFSET howToPlay2
    call WriteString
    mov edx, OFFSET howToPlay3
    call WriteString
    mov edx, OFFSET howToPlay4
    call WriteString
    mov edx, OFFSET howToPlay5
    call WriteString
    mov edx, OFFSET howToPlay6
    call WriteString

    ; Top Border
  


    ;mov  eax, 10                 ; this is the x value
    ;mov  ebx, 10                 ; this is the y value
    ;mov  topLeftChar, 9556h
    ;call ChangeChar
    ;call GetConsoleUi
    
    
    ret


ShowHowToMenu ENDP



DisplayPlatform PROC
    call Clrscr

    mov ecx, 4              ; Number of platforms
    mov ebx, 5              ; Starting Y position (low on screen)
    
platform_loop:
    push ecx                ; Save loop counter
    push ebx                ; Save current Y

    ; Generate random X position (safe range: 0 to COLS - platformWidth)
    mov eax, COLS - 10
    call RandomRange        ; EAX = random X between 0 and (COLS - 10)

    ; Draw 10-character platform at random X (EAX), fixed Y (EBX)
    mov edi, 0              ; Counter for platform width
draw_loop:
    
    push eax                ; Save X
    push ebx                ; Save Y
    add eax, edi            ; X + offset
    mov newChar, 2588h
    call ChangeChar
    pop ebx
    pop eax
    inc edi
    cmp edi, 10
    jl draw_loop

    pop ebx                 ; Restore Y
    pop ecx                 ; Restore loop counter
    add ebx, 5              ; Move next platform higher (Y + 5)
    loop platform_loop

    call GetConsoleUi
    ret
DisplayPlatform ENDP


GameOver PROC
    call Clrscr

    mov ecx, 0
    centerScreen:
    cmp ecx, 10
    je endCenter_
    call Crlf
    inc ecx
    jmp centerScreen
    endCenter_:
    
    mov eax, red
    call SetTextColor
    mov edx, OFFSET gameOverText1
    call WriteString
    mov eax, red
    call SetTextColor
    mov edx, OFFSET gameOverText2
    mov eax, red
    call SetTextColor
    call WriteString
    mov edx, OFFSET gameOverText3
    mov eax, red
    call SetTextColor
    call WriteString
    mov edx, OFFSET gameOverText4
    mov eax, red
    call SetTextColor
    call WriteString
    mov edx, OFFSET gameOverText5
    mov eax, red
    call SetTextColor
    call WriteString
    mov edx, OFFSET gameOverText6
    mov eax, red
    call SetTextColor
    call WriteString
    mov edx, OFFSET gameOverText7
    mov eax, red
    call SetTextColor
    call WriteString
    mov edx, OFFSET gameOverText8
    mov eax, red
    call SetTextColor
    call WriteString
    mov eax, red
    call SetTextColor
    mov edx, OFFSET gameOverText9
    call WriteString

    ;call WaitMsg
   
    ;mov eax, 10                 ; this is the x value
   ; mov ebx, 10                 ; this is the y value
   ; mov newChar, 'X'
   ; call ChangeChar
   ; call GetConsoleUi
    
    ret

GameOver ENDP


END 