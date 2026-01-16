; AARON VILLALOBOS
;GRAPHICS FILE FOR BYTE JUMPER
;Purpose Display front end graphics of game including text and textcolor
;Title page, how to play page, game over display
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib
INCLUDELIB C:\Irvine\Kernel32.lib

extern WriteConsoleW@20 : PROC  ;  declare external WinAPI
extern GetStdHandle@4 : PROC
extern ChangeCharAt@0 : PROC
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


bigText0 BYTE "      /$$$$$$$              /$$                        /$$$$$ ", 10,0                                                     
bigText1 BYTE "     | $$__  $$            | $$                       |__  $$ ", 10,0                                                     
bigText2 BYTE "     | $$  \ $$ /$$   /$$ /$$$$$$    /$$$$$$             | $$ /$$   /$$ /$$$$$$/$$$$   /$$$$$$   /$$$$$$   /$$$$$$ ", 10,0
bigText3 BYTE "     | $$$$$$$ | $$  | $$|_  $$_/   /$$__  $$            | $$| $$  | $$| $$_  $$_  $$ /$$__  $$ /$$__  $$ /$$__  $$ ", 10,0
bigText4 BYTE "     | $$__  $$| $$  | $$  | $$    | $$$$$$$$       /$$  | $$| $$  | $$| $$ \ $$ \ $$| $$  \ $$| $$$$$$$$| $$  \__/ ", 10,0
bigText5 BYTE "     | $$  \ $$| $$  | $$  | $$ /$$| $$_____/      | $$  | $$| $$  | $$| $$ | $$ | $$| $$  | $$| $$_____/| $$  ", 10,0     
bigText6 BYTE "     | $$$$$$$/|  $$$$$$$  |  $$$$/|  $$$$$$$      |  $$$$$$/|  $$$$$$/| $$ | $$ | $$| $$$$$$$/|  $$$$$$$| $$ ", 10,0     
bigText7 BYTE "     |_______/  \____  $$   \___/   \_______/       \______/  \______/ |__/ |__/ |__/| $$____/  \_______/|__/ ", 10,0      
bigText8 BYTE "                /$$  | $$                                                            | $$", 10,0                      
bigText9 BYTE "               |  $$$$$$/                                                            | $$", 10,0                    
bigText10 BYTE "                \______/                                                             |__/", 10,0 

howToPlayDisplay1 BYTE "                .--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--. ",10,0
howToPlayDisplay2 BYTE "               / .. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \",10,0
howToPlayDisplay3 BYTE "               \ \/\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ \/ /",10,0
howToPlayDisplay4 BYTE "                \/ /`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'\/ / ",10,0
howToPlayDisplay5 BYTE "                / /\                                                                                / /\ ",10,0
howToPlayDisplay6 BYTE "               / /\ \   _    _  ______          __  _______ ____    _____  _           __     __   / /\ \",10,0
howToPlayDisplay7 BYTE "               \ \/ /  | |  | |/ __ \ \        / / |__   __/ __ \  |  __ \| |        /\\ \   / /   \ \/ /",10,0
howToPlayDisplay8 BYTE "                \/ /   | |__| | |  | \ \  /\  / /     | | | |  | | | |__) | |       /  \\ \_/ /     \/ / ",10,0
howToPlayDisplay9 BYTE "                / /\   |  __  | |  | |\ \/  \/ /      | | | |  | | |  ___/| |      / /\ \\   /      / /\ ",10,0
howToPlayDisplay10 BYTE "               / /\ \  | |  | | |__| | \  /\  /       | | | |__| | | |    | |____ / ____ \| |      / /\ \",10,0
howToPlayDisplay11 BYTE "               \ \/ /  |_|  |_|\____/   \/  \/        |_|  \____/  |_|    |______/_/    \_\_|      \ \/ /",10,0
howToPlayDisplay12 BYTE "                \/ /                                                                                \/ / ",10,0
howToPlayDisplay13 BYTE "                / /\.--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--./ /\ ",10,0
howToPlayDisplay14 BYTE "               / /\ \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \.. \/\ \",10,0
howToPlayDisplay15 BYTE "               \ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `'\ `' /",10,0
howToPlayDisplay16 BYTE "                `--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--'`--' ",10,0

          playInstruction1   BYTE "                                 __| |____________________________________________| |__",10,0
playInstruction2   BYTE "                                (__   ____________________________________________   __)",10,0
playInstruction3a  BYTE "                                   | |       ",0
playInstruction3b  BYTE "MOVE LEFT: ",0
playInstruction3c  BYTE "A",0
playInstruction3d  BYTE "|||",0
playInstruction3e  BYTE "MOVE RIGHT: ",0
playInstruction3f  BYTE "D",0
playInstruction3g  BYTE "         | |   ",10,0
playInstruction4a  BYTE "                                   | |              ",0
playInstruction4b  BYTE "   JUMP: ",0
playInstruction4c  BYTE "   SPACEBAR",0
playInstruction4d  BYTE "          | |",10,0
playInstruction5a  BYTE "                                   | |      ",0
playInstruction5b  BYTE "   JUMP ",0
playInstruction5c  BYTE "   FROM PLATFORM TO PLATFORM",0
playInstruction5d  BYTE "  | |",10,0
playInstruction6a  BYTE "                                   | |     ",0
playInstruction6b  BYTE "FALL ",0
playInstruction6c  BYTE "TO THE GROUND ",0
playInstruction6d  BYTE "=== ",0
playInstruction6e  BYTE "GAME OVER",0
playInstruction6f  BYTE "       | |",10,0
playInstruction7   BYTE "                                   | |                                            | |",10,0
playInstruction8a  BYTE "                                   | |              ",0
playInstruction8b  BYTE "   PLAY:  ",0
playInstruction8c  BYTE "   ENTER",0
playInstruction8d  BYTE "            | |",10,0
playInstruction9   BYTE "                                 __| |____________________________________________| |__",10,0
playInstruction10  BYTE "                                (__   ____________________________________________   __)",10,0
playInstruction11  BYTE "                                   | |                                            | |",10,0

       

emptyByteText BYTE "                                                                                                           ",10,0
gameOverText1 BYTE "                 ______    ______     __        __ ________        ______    __     __   ________  _______ ",10,0
gameOverText2 BYTE "                /      \\  /      \\ |  \\    / \\|        \\     /      \\ |  \\   | \\|        \\|       \\",10,0
gameOverText3 BYTE "               |  $$$$$$\\|  $$$$$$\\| $$\\  /  $$| $$$$$$$$      | $$$$$$\\| $$    | $$| $$$$$$$$| $$$$$$$\\",10,0
gameOverText4 BYTE "               | $$ __\\$$| $$__| $$| $$$\\ /  $$$| $$__          | $$  | $$| $$    | $$| $$__    | $$__| $$",10,0
gameOverText5 BYTE "               | $$|    \\| $$    $$| $$$$\\  $$$$| $$  \\        | $$  | $$\\$$\\ /  $$| $$  \\  | $$    $$",10,0
gameOverText6 BYTE "               | $$ \\$$$$| $$$$$$$$| $$\\$$ $$ $$| $$$$$         | $$  | $$ \\$$\\  $$ | $$$$$   | $$$$$$$\\",10,0
gameOverText7 BYTE "               | $$__| $$|  $$  | $$| $$ \\$$$| $$| $$_____       | $$__/ $$  \\$$ $$   | $$_____ | $$  | $$",10,0
gameOverText8 BYTE "                \\$$    $$| $$  | $$| $$  \\$ | $$| $$     \\     \\$$    $$   \\$$$    | $$     \\|$$  | $$",10,0
gameOverText9 BYTE "                 \\$$$$$$ \\$$   \\$\\$$      \\$$ \\$$$$$$$$       \\$$$$$$    \\$     \\$$$$$$$$\\$$  \\$$",10,0
                                                                                       
                                                                                          



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
    mov eax, magenta
    call SetTextColor
    mov edx, OFFSET bigText0
    call WriteString
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
    mov edx, OFFSET bigText6
    call WriteString
    mov edx, OFFSET bigText7
    call WriteString
    mov edx, OFFSET bigText8
    call WriteString
    mov edx, OFFSET bigText9
    call WriteString
    mov edx, OFFSET bigText10
    call WriteString
    mov eax, 3000   ; time in milliseconds
    call Delay 
    call waitMsg
    mov dh, 0
    mov dl, 0
    call Gotoxy      ; Clears the screen
    

    
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

    mov eax, lightCyan
    call SetTextColor
    mov edx, OFFSET howToPlayDisplay1
    call WriteString
    mov edx, OFFSET howToPlayDisplay2
    call WriteString
    mov edx, OFFSET howToPlayDisplay3
    call WriteString
    mov edx, OFFSET howToPlayDisplay4
    call WriteString
    mov edx, OFFSET howToPlayDisplay5
    call WriteString
    mov edx, OFFSET howToPlayDisplay6
    call WriteString
    mov edx, OFFSET howToPlayDisplay7
    call WriteString
    mov edx, OFFSET howToPlayDisplay8
    call WriteString
    mov edx, OFFSET howToPlayDisplay9
    call WriteString
    mov edx, OFFSET howToPlayDisplay10
    call WriteString
    mov edx, OFFSET howToPlayDisplay11
    call WriteString
    mov edx, OFFSET howToPlayDisplay12
    call WriteString
    mov edx, OFFSET howToPlayDisplay13
    call WriteString
    mov edx, OFFSET howToPlayDisplay14
    call WriteString
    mov edx, OFFSET howToPlayDisplay15
    call WriteString
    mov edx, OFFSET howToPlayDisplay16
    call WriteString



    mov edx, OFFSET playInstruction1
    call WriteString
    mov edx, OFFSET playInstruction2
    call WriteString
    mov edx, OFFSET playInstruction3a
    call WriteString
    mov eax, white
    call SetTextColor
    mov edx, OFFSET playInstruction3b
    call WriteString
    mov eax, cyan
    call SetTextColor
    mov edx, OFFSET playInstruction3c
    call WriteString
    mov eax, lightCyan
    call SetTextColor
    mov edx, OFFSET playInstruction3d
    call WriteString
    mov eax, white
    call SetTextColor
    mov edx, OFFSET playInstruction3e
    call WriteString
    mov eax, cyan
    call SetTextColor
    mov edx, OFFSET playInstruction3f
    call WriteString
    mov eax, lightCyan
    call SetTextColor
    mov edx, OFFSET playInstruction3g
    call WriteString
    mov edx, OFFSET playInstruction4a
    call WriteString
    mov eax, white
    call SetTextColor
    mov edx, OFFSET playInstruction4b
    call WriteString
    mov eax, cyan
    call SetTextColor
    mov edx, OFFSET playInstruction4c
    call WriteString
    mov eax, lightCyan
    call SetTextColor
    mov edx, OFFSET playInstruction4d
    call WriteString
    mov edx, OFFSET playInstruction5a
    call WriteString
    mov eax, cyan
    call SetTextColor
    mov edx, OFFSET playInstruction5b
    call WriteString
    mov eax, white
    call SetTextColor
    mov edx, OFFSET playInstruction5c
    call WriteString
    mov eax, lightCyan
    call SetTextColor
    mov edx, OFFSET playInstruction5d
    call WriteString
    mov edx, OFFSET playInstruction6a
    call WriteString
    mov eax, Yellow
    call SetTextColor
    mov edx, OFFSET playInstruction6b
    call WriteString
    mov eax, white
    call SetTextColor
    mov edx, OFFSET playInstruction6c
    call WriteString
    mov eax, lightGreen
    call SetTextColor
    mov edx, OFFSET playInstruction6d
    call WriteString
    mov eax, lightRed
    call SetTextColor
    mov edx, OFFSET playInstruction6e
    call WriteString
    mov eax, lightCyan
    call SetTextColor
    mov edx, OFFSET playInstruction6f
    call WriteString
    mov edx, OFFSET playInstruction7
    call WriteString
    mov edx, OFFSET playInstruction8a
    call WriteString
    mov eax, white
    call SetTextColor
    mov edx, OFFSET playInstruction8b
    call WriteString
    mov eax, cyan
    call SetTextColor
    mov edx, OFFSET playInstruction8c
    call WriteString
    mov eax, lightCyan
    call SetTextColor
    mov edx, OFFSET playInstruction8d
    call WriteString
    mov edx, OFFSET playInstruction9
    call WriteString
    mov edx, OFFSET playInstruction10
    call WriteString
    mov edx, OFFSET playInstruction11
    call WriteString

waitForEnter:
    call ReadChar
    cmp al, 13                  ; ASCII code for enter
    jne waitForEnter

    ret



ShowHowToMenu ENDP




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
       
    mov edx, OFFSET emptyByteText
    call WriteString
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


    
    ret

GameOver ENDP


END 