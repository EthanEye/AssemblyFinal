

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
newChar BYTE 'O'
commaStr BYTE ", ", 0
temp DWORD ? ; Previous Location
gameBoard BYTE ROWS * COLS DUP(' ') ; 
msg BYTE "Loading Game...", 0   ; Null-terminated string
; Index = row * COLS + col This gives you the correct index into the flat array as if it were 2D
.code


GameEngine PROC 

mov eax, 400
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
	mov eax, ROWS       ; use the ROWS constant
	sub eax, ecx        ; eax = ROWS - row
	mov YCoord, eax     ; store the flipped Y value
	call WriteDec       ; print flipped Y
	ret
GetCoordinate ENDP

; Method for updating the chars on the Gameboard
; Parameters: EAX (X coordinate) EBX (Y coordinate)
ChangeCharAt PROC
	; Flip Y: ebx = ROWS - ebx
    mov edx, ROWS
    sub edx, ebx      ; edx = flipped Y

    ; Calculate index = (flippedY * COLS) + X
    imul edx, COLS    ; edx = flippedY * COLS
    add edx, eax      ; edx = (flippedY * COLS) + X

    mov al, newChar           ; Set index to a specific character loaded from newChar
	mov gameBoard[edx], al    ; store AL into gameBoard	
ret
ChangeCharAt ENDP

; Keeps track of each part of player character
GetPlayerPos PROC


ret
GetPlayerPos ENDP

; Called firsts updates coordinate relative to (player input)
GetHeadPos PROC


ret
GetHeadPos ENDP


; Called second updates coordinate relative to head (down 1 right 1)
GetRightArmPos PROC


ret
GetRightArmPos ENDP

; Called third updates coordinate relative to head (down 1 left 1)
GetLeftArmPos PROC

ret
GetLeftArmPos ENDP

; Called fourth updates coordinate relative to head (down 1)
GetTorsoPos PROC


ret
GetTorsoPos ENDP

; Called fifth updates coordinate relative to torso down (1 left 1)
GetLeftLegPos PROC


ret
GetLeftLegPos ENDP

; Called sixth updates coordinate relative to torso down (1 right 1)
GetRightLegPos PROC


ret
GetRightLegPos ENDP





END 