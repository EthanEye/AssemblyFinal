

INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib

ROWS = 30 ; Y
COLS = 119 ; X  
SCREENSIZE = ROWS * COLS
.data
gameBoard BYTE ROWS * COLS DUP('$') ; 5x10 = 50 bytes initialized to S
msg BYTE "Loading Game...", 0   ; Null-terminated string
.code

GameEngine PROC 
call GetCurrentFrame

ret
GameEngine ENDP

GetCurrentFrame PROC
	mov edx, OFFSET msg    ; point to string
    call WriteString       ; print it
	call Crlf              ; optional newline
		
		mov ecx, 0
		fillCharacters:
		cmp ecx, SCREENSIZE 
		jge endFill
		mov eax, ecx
		xor edx, edx      ; clear remainder before division
		mov ebx, COLS       ; divisor
		div ebx           ; EAX = ecx / 25, EDX = ecx % 25
	    cmp edx, 0
		jne skipSpace
		call Crlf
		skipSpace:
		mov al, gameBoard[ecx]
		call WriteChar

		
		inc ecx
		jmp fillCharacters
		endFill:
		
ret
GetCurrentFrame ENDP

UpdateFrame PROC


ret
UpdateFrame ENDP

UpdatePlayerPosition PROC


ret
UpdatePlayerPosition ENDP

PlayerMovement PROC


ret
PlayerMovement ENDP

END 