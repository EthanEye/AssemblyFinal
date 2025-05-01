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
topLeftChar WORD 9556h
topRightChar WORD 9559h
bottomLeftChar WORD 9562h
bottomRightChar WORD 9565h
vLineChar WORD 9553h
hLineChar WORD 9555h

gameBoard WORD ROWS * COLS DUP(' ') ;
bigText1 BYTE "       ______     __  __     ______   ______          __     __  __     __    __     ______   ______     ______    ", 10,0  
bigText2 BYTE "      /\  == \   /\ \_\ \   /\__  _\ /\  ___\        /\ \   /\ \/\ \   /\ -./ \ \   /\  == \ /\  ___\   /\  == \  ", 10,0 
bigText3 BYTE "      \ \  __<   \ \____ \  \/_/\ \/ \ \  __\       _\_\ \  \ \ \_\ \  \ \ \-./\ \  \ \  __/ \ \  __\   \ \  __< " , 10,0 
bigText4 BYTE "       \ \_____\  \/\_____\    \ \_\  \ \_____\    /\_____\  \ \_____\  \ \_\ \ \_\  \ \_\    \ \_____\  \ \_\ \_\", 10, 0
bigText5 BYTE "        \/_____/   \/_____/     \/_/   \/_____/    \/_____/   \/_____/   \/_/  \/_/   \/_/     \/_____/   \/_/ /_/ ", 10,0                                                                                                            


start BYTE "            How To Play: '?' ||| Start: 'Enter' ||| Quit: 'Esc'",10,0 

howToPlay0 BYTE "+----------------------------------------------+",10,0
howToPlay1 BYTE "|                  HOW TO PLAY                 |",10,0
howToPlay2 BYTE "|           MOVE: A(LEFT), D(RIGHT)            |",10,0
howToPlay3 BYTE "|           JUMP: SPACE BAR                    |",10,0
howToPlay4 BYTE "|           LAND ON PLATFORMS TO SURVIVE       |",10,0
howToPlay5 BYTE "|           MISS A PLATFORM === GAME OVER      |",10,0
howToPlay6 BYTE "+----------------------------------------------+",10,0

gameOverText1 BYTE "               ______    ______   __       __  ________         ______   __     __  ________  _______",10,0
gameOverText2 BYTE "              /      \  /      \ |  \     /  \|        \       /      \ |  \   |  \|        \|       \",10,0
gameOverText3 BYTE "             |  $$$$$$\|  $$$$$$\| $$\   /  $$| $$$$$$$$      |  $$$$$$\| $$   | $$| $$$$$$$$| $$$$$$$\",10,0
gameOverText4 BYTE "             | $$ __\$$| $$__| $$| $$$\ /  $$$| $$__          | $$  | $$| $$   | $$| $$__    | $$__| $$",10,0
gameOverText5 BYTE "             | $$|    \| $$    $$| $$$$\  $$$$| $$  \         | $$  | $$ \$$\ /  $$| $$  \   | $$    $$",10,0
gameOverText6 BYTE "             | $$ \$$$$| $$$$$$$$| $$\$$ $$ $$| $$$$$         | $$  | $$  \$$\  $$ | $$$$$   | $$$$$$$\",10,0
gameOverText7 BYTE "             | $$__| $$| $$  | $$| $$ \$$$| $$| $$_____       | $$__/ $$   \$$ $$  | $$_____ | $$  | $$",10,0
gameOverText8 BYTE "              \$$    $$| $$  | $$| $$  \$ | $$| $$     \       \$$    $$    \$$$   | $$     \| $$  | $$",10,0
gameOverText9 BYTE "               \$$$$$$  \$$   \$$ \$$      \$$ \$$$$$$$$        \$$$$$$      \$     \$$$$$$$$ \$$   \$$",10,0
                                                                                          
                                                                                       
                                                                                          



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
    mov eax, 3000   ; time in milliseconds
    call Delay 
    mov dh, 0
    mov dl, 0
    call Gotoxy      ; Clears the screen
 
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

    ; Ground
    mov eax, 1                 ; this is the x value
    mov ebx, 1                 ; this is the y value
    mov newChar, 2588h
    call ChangeChar
    mov eax, 2
    mov ebx, 1
    mov newChar, 2588h
    call ChangeChar
    mov eax, 3
    mov ebx, 1
    mov newChar, 2588h
    call ChangeChar
    mov eax, 4
    mov ebx, 1
    mov newChar, 2588h
    call ChangeChar
    mov eax, 5
    mov ebx, 1
    mov newChar, 2588h
    call ChangeChar
    mov eax, 6
    mov ebx, 1
    mov newChar, 2588h
    call ChangeChar
    mov eax, 7
    mov ebx, 1
    mov newChar, 2588h
    call ChangeChar
    mov eax, 8
    mov ebx, 1
    mov newChar, 2588h
    call ChangeChar
    mov eax, 9
    mov ebx, 1
    mov newChar, 2588h
    call ChangeChar
    mov eax, 10
    mov ebx, 1
    mov newChar, 2588h
    call ChangeChar
    
    ; first platform
    mov eax, 21                 ; this is the x value
    mov ebx, 5                 ; this is the y value
    mov newChar, 2588h
    call ChangeChar
    mov eax, 22
    mov ebx, 5
    mov newChar, 2588h
    call ChangeChar
    mov eax, 23
    mov ebx, 5
    mov newChar, 2588h
    call ChangeChar
    mov eax, 24
    mov ebx, 5
    mov newChar, 2588h
    call ChangeChar
    mov eax, 25
    mov ebx, 5
    mov newChar, 2588h
    call ChangeChar
    mov eax, 26
    mov ebx, 5
    mov newChar, 2588h
    call ChangeChar
    mov eax, 27
    mov ebx, 5
    mov newChar, 2588h
    call ChangeChar
    mov eax, 28
    mov ebx, 5
    mov newChar, 2588h
    call ChangeChar
    mov eax, 29
    mov ebx, 5
    mov newChar, 2588h
    call ChangeChar
    mov eax, 30
    mov ebx, 5
    mov newChar, 2588h
    call ChangeChar

    ; Second platform 

    mov eax, 51                 ; this is the x value
    mov ebx, 10                 ; this is the y value
    mov newChar, 2588h
    call ChangeChar
    mov eax, 52
    mov ebx, 10
    mov newChar, 2588h
    call ChangeChar
    mov eax, 53
    mov ebx, 10
    mov newChar, 2588h
    call ChangeChar
    mov eax, 54
    mov ebx, 10
    mov newChar, 2588h
    call ChangeChar
    mov eax, 55
    mov ebx, 10
    mov newChar, 2588h
    call ChangeChar
    mov eax, 56
    mov ebx, 10
    mov newChar, 2588h
    call ChangeChar
    mov eax, 57
    mov ebx, 10
    mov newChar, 2588h
    call ChangeChar
    mov eax, 58
    mov ebx, 10
    mov newChar, 2588h
    call ChangeChar
    mov eax, 59
    mov ebx, 10
    mov newChar, 2588h
    call ChangeChar
    mov eax, 60
    mov ebx, 10
    mov newChar, 2588h
    call ChangeChar

    ; Third platform 
    mov eax, 81                 ; this is the x value
    mov ebx, 15                 ; this is the y value
    mov newChar, 2588h
    call ChangeChar
    mov eax, 82
    mov ebx, 15
    mov newChar, 2588h
    call ChangeChar
    mov eax, 83
    mov ebx, 15
    mov newChar, 2588h
    call ChangeChar
    mov eax, 84
    mov ebx, 15
    mov newChar, 2588h
    call ChangeChar
    mov eax, 85
    mov ebx, 15
    mov newChar, 2588h
    call ChangeChar
    mov eax, 86
    mov ebx, 15
    mov newChar, 2588h
    call ChangeChar
    mov eax, 87
    mov ebx, 15
    mov newChar, 2588h
    call ChangeChar
    mov eax, 88
    mov ebx, 15
    mov newChar, 2588h
    call ChangeChar
    mov eax, 89
    mov ebx, 15
    mov newChar, 2588h
    call ChangeChar
    mov eax, 90
    mov ebx, 15
    mov newChar, 2588h
    call ChangeChar

    ; Fourth Platform
    mov eax, 101                 ; this is the x value
    mov ebx, 20                 ; this is the y value
    mov newChar, 2588h
    call ChangeChar
    mov eax, 102
    mov ebx, 20
    mov newChar, 2588h
    call ChangeChar
    mov eax, 103
    mov ebx, 20
    mov newChar, 2588h
    call ChangeChar
    mov eax, 104
    mov ebx, 20
    mov newChar, 2588h
    call ChangeChar
    mov eax, 105
    mov ebx, 20
    mov newChar, 2588h
    call ChangeChar
    mov eax, 106
    mov ebx, 20
    mov newChar, 2588h
    call ChangeChar
    mov eax, 107
    mov ebx, 20
    mov newChar, 2588h
    call ChangeChar
    mov eax, 108
    mov ebx, 20
    mov newChar, 2588h
    call ChangeChar
    mov eax, 109
    mov ebx, 20
    mov newChar, 2588h
    call ChangeChar
    mov eax, 110
    mov ebx, 20
    mov newChar, 2588h
    call ChangeChar
    call GetConsoleUi

   

ret

DisplayPlatform ENDP

GameOver PROC
    call ClrScr
    mov ecx, 0
    centerScreen:
    cmp ecx, 10
    je endCenter_
    call Crlf
    inc ecx
    jmp centerScreen
    endCenter_:
   
    mov edx, OFFSET gameOverText1
    call WriteString
    mov edx, OFFSET gameOverText2
    call WriteString
    mov edx, OFFSET gameOverText3
    call WriteString
    mov edx, OFFSET gameOverText4
    call WriteString
    mov edx, OFFSET gameOverText5
    call WriteString
    mov edx, OFFSET gameOverText6
    call WriteString
    mov edx, OFFSET gameOverText7
    call WriteString
    mov edx, OFFSET gameOverText8
    call WriteString
    mov edx, OFFSET gameOverText9
    call WriteString

    call WaitMsg
   
    ;mov eax, 10                 ; this is the x value
   ; mov ebx, 10                 ; this is the y value
   ; mov newChar, 'X'
   ; call ChangeChar
   ; call GetConsoleUi
    
    ret

GameOver ENDP


END 