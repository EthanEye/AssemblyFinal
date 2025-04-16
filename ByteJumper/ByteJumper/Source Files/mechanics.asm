

INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib

; SCREEN HEIGHT AND WIDTH
ROWS = 27 ; Y
COLS = 119 ; X  




; SCREEN SIZE
SCREENSIZE = ROWS * COLS

; REFRESH TIME
REFRESHTIME = 1 ; MilliSeconds

.data
; PLAYER POSITION
x DWORD ?
y DWORD ?
index BYTE ?
row BYTE 0
col BYTE 0
commaStr BYTE ", ", 0
temp DWORD ? ; Previous Location
gameBoard BYTE ROWS * COLS DUP('$') ; 
msg BYTE "Loading Game...", 0   ; Null-terminated string
;index = row * COLS + col This gives you the correct index into the flat array as if it were 2D
.code


GameEngine PROC 
call ClrScr
mov esi, 0
testLoop:
mov eax, [temp]
mov gameBoard[eax], '$'
cmp esi, SCREENSIZE 
jge exitTestLoop
mov gameBoard[esi], 'X'   ; sets gameBoard[ecx] to 'X'
call GetCurrentFrame
mov eax, esi
call PlayerLocation
mov eax, REFRESHTIME       
call Delay
mov edx, 0       ; column
mov ecx, 0       ; row
call Gotoxy      ;  just move cursor to top
mov [temp], esi
inc esi
jmp testLoop

exitTestLoop:


ret
GameEngine ENDP

GetCurrentFrame PROC
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
		mov al, gameBoard[ecx] ; write char at array index
		call WriteChar
		inc ecx
		jmp fillCharacters
		endFill:
	
		
ret
GetCurrentFrame ENDP

UpdateFrame PROC


ret
UpdateFrame ENDP

; Converts array index into X, Y Coordinates
; Parameters: EAX (gameBoard index)
PlayerLocation PROC
    xor edx, edx            ; clear EDX before DIV
    mov ebx, COLS
    div ebx                 ; EAX = row, EDX = col

    mov ecx, eax            ; save row
   
	call Crlf               ; move to new line before printing

    ; Print col
    mov eax, edx
    call WriteDec
	; Print comma
    mov edx, OFFSET commaStr
    call WriteString
	; Print row
    mov eax, ecx
    call WriteDec

    ret
PlayerLocation ENDP






END 