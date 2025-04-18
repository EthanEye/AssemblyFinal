

INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib 

extern WriteConsoleW@20 : PROC  ;  declare external WinAPI
extern GetStdHandle@4 : PROC


; SCREEN HEIGHT AND WIDTH
ROWS = 40 ; Y
COLS = 100 ; X  

; SCREEN SIZE
SCREENSIZE = ROWS * COLS

; REFRESH TIME
REFRESHTIME = 1 ; MilliSeconds

.data
; PRINTING UNICODE
outputHandle DWORD ?
tempChar WORD ?
bytesWritten DWORD ?
; PLAYER POSITION
xCoord DWORD ?
yCoord DWORD ?
index BYTE ? 
row WORD 0
col WORD 0
newChar WORD 2584h
commaStr WORD ", ", 0
temp DWORD ? ; Previous Location
gameBoard WORD ROWS * COLS DUP(2588h) ; 
msg BYTE "Loading Game...", 0   ; Null-terminated string
; Index = row * COLS + col This gives you the correct index into the flat array as if it were 2D
.code


GameEngine PROC 
 ; Get console handle once
    push -11
    call GetStdHandle@4
    mov outputHandle, eax
;mov eax, 400
;call GetCoordinate
;call StartPlatform 
call GetCurrentFrame

;call SpawnPlayer
call GetPlayerPos

exitTestLoop:


ret
GameEngine ENDP

GetCurrentFrame PROC
    mov ecx, 0

fillCharacters:
    cmp ecx, SCREENSIZE
    jge endFill

    ; Print newline every COLS
    mov eax, ecx
    xor edx, edx
    mov ebx, COLS
    div ebx
    cmp edx, 0
    jne skipSpace
    call Crlf

skipSpace:
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
    jmp fillCharacters

endFill:
    ret
GetCurrentFrame ENDP




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

; Print coordinate given (EAX = x EBX = y)
PrintCoordinate PROC


ret
PrintCoordinate ENDP

; Method for updating the chars on the Gameboard
; Parameters: EAX (X coordinate) EBX (Y coordinate)
ChangeCharAt PROC
	; Flip Y: ebx = ROWS - ebx
    mov edx, ROWS
    sub edx, ebx      ; edx = flipped Y

    ; Calculate index = (flippedY * COLS) + X
    imul edx, COLS    ; edx = flippedY * COLS
    add edx, eax      ; edx = (flippedY * COLS) + X


	mov ax, newChar					 ; Set index to a specific character loaded from newChar
	mov WORD PTR gameBoard[edx], ax ; store AL into gameBoard	

  
ret
ChangeCharAt ENDP

; Keeps track of each part of player character
GetPlayerPos PROC

call GetHeadPos
call GetRightArmPos
call GetLeftArmPos
call GetTorsoPos
call GetLeftLegPos
call GetRightLegPos 
ret
GetPlayerPos ENDP

; Called first updates coordinate relative to (player input)
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

SpawnPlayer PROC 
mov eax, 56
mov ebx, 13
mov newChar, 'O'
call ChangeCharAt
mov eax, 56
mov ebx, 12
mov newChar, '?'
call ChangeCharAt
mov eax, 57
mov ebx, 12
mov newChar, '\'
call ChangeCharAt
mov eax, 55
mov ebx, 12
mov newChar, '/'
call ChangeCharAt
mov eax, 57
mov ebx, 11
mov newChar, '\'
call ChangeCharAt
mov eax, 55
mov ebx, 11
mov newChar, '/'
call ChangeCharAt


ret
SpawnPlayer ENDP

StartPlatform PROC

mov eax, 54
mov ebx, 10
mov newChar, '_'
call ChangeCharAt
mov eax, 55
mov ebx, 10
mov newChar, '_'
call ChangeCharAt
mov eax, 56
mov ebx, 10
mov newChar, '_'
call ChangeCharAt
mov eax, 57
mov ebx, 10
mov newChar, '_'
call ChangeCharAt
mov eax, 58
mov ebx, 10
mov newChar, '_'
call ChangeCharAt

ret
StartPlatform ENDP

ret
MoveLeft PROC

ret
MoveLeft ENDP



MoveRight PROC

ret
MoveRight ENDP


END 