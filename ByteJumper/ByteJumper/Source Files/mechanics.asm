

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
xCoord DWORD ?
yCoord DWORD ?
index BYTE ?
row BYTE 0
col BYTE 0
commaStr BYTE ", ", 0
temp DWORD ? ; Previous Location
gameBoard BYTE ROWS * COLS DUP('$') ; 
msg BYTE "Loading Game...", 0   ; Null-terminated string
; Index = row * COLS + col This gives you the correct index into the flat array as if it were 2D
.code


GameEngine PROC 

mov eax, 1000
call GetCoordinate
mov eax, xCoord
mov ebx, yCoord
call ChangeCharAt
call GetCurrentFrame

exitTestLoop:


ret
GameEngine ENDP

GetCurrentFrame PROC
		mov ecx, 0
		fillCharacters:
		cmp ecx, SCREENSIZE 
		jge endFill
		mov eax, ecx
		xor edx, edx      ; Clear remainder before division
		mov ebx, COLS       ; Divisor
		div ebx           ; EAX = ecx / 25, EDX = ecx % 25
	    cmp edx, 0
		jne skipSpace
		call Crlf
		skipSpace:
		mov al, gameBoard[ecx] ; Write char at array index
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
GetCoordinate PROC
    xor edx, edx            ; Clear EDX before DIV
    mov ebx, COLS			; Adjust for width of board
    div ebx					; Divides EDX by EAX        
	mov ecx, eax            ; Save row
	call Crlf               ; Move to new line before printing
	; Print col
	mov xCoord, edx         ; Store X value
    mov eax, edx
    call WriteDec
	; Print comma
    mov edx, OFFSET commaStr
    call WriteString
	; Print row
	mov YCoord, ecx         ; Store Y value
    mov eax, ecx
    call WriteDec
	ret
GetCoordinate ENDP

; Method for updating the chars on the Gameboard
; Parameters: EAX (X coordinate) EBX (Y coordinate)
ChangeCharAt PROC
  ; Convert (X = EAX, Y = EBX) index = (Y * COLS) + X
    mov edx, ebx
    imul edx, COLS       ; edx = row * COLS
    add edx, eax         ; edx = (row * COLS) + col
  ; update value at that index
    mov gameBoard[edx], 'X'
ret
ChangeCharAt ENDP




END 