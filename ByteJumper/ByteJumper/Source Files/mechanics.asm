

INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib 

EXTERN WriteConsoleW@20 : PROC  ;  declare external WinAPI
EXTERN GetStdHandle@4 : PROC
EXTERN SetConsoleCursorInfo@8 : PROC
EXTERN StartInputThread@0 : PROC


; SCREEN HEIGHT AND WIDTH
ROWS = 25 ; Y
COLS = 120 ; X  

; SCREEN SIZE
SCREENSIZE = ROWS * COLS

; REFRESH TIME
REFRESHTIME = 1 ; MilliSeconds

.data
; CURSOR 
hStdOut      DWORD ?
cursorInfo   CONSOLE_CURSOR_INFO <>
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
commaStr DWORD " , ", 0
leftPrt DWORD "( ", 0
rightPrt DWORD ")", 0
temp DWORD ? ; Previous Location
gameBoard WORD ROWS * COLS DUP(' ') ; 
msg BYTE "Loading Game...", 0   ; Null-terminated string
; Index = row * COLS + col This gives you the correct index into the flat array as if it were 2D
.code


GameEngine PROC 
  ; Create new thread for player input
    call StartInputThread@0
  ; Get console handle once
    push -11
    call GetStdHandle@4
    mov outputHandle, eax

    ; Clear screen
    call Clrscr

    ; Set up the CONSOLE_CURSOR_INFO structure
    mov cursorInfo.dwSize, 1        ; Minimum size
    mov cursorInfo.bVisible, 0      ; FALSE (invisible)

    ; Call SetConsoleCursorInfo with stored handle
    push OFFSET cursorInfo
    push outputHandle
    call SetConsoleCursorInfo@8

    ; Main loop or other code
    call Crlf
   
;mov eax, 400
;call GetCoordinate
call StartPlatform 
call SpawnPlayer


; This is where the main game functions are called
mainLoop_:
mov eax, 1   ; time in milliseconds
call Delay       ;  pauses program for 500 ms
mov edx, 0   ; column
mov ecx, 0     ; row
call Gotoxy    ;  move the cursor
call GetCurrentFrame
call PrintPlayerPos
jmp mainLoop_
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
PrintPlayerPos PROC

mov edx, offset leftPrt
call WriteString
mov eax, xCoord 
call WriteInt
mov edx, offset commaStr
call WriteString
mov eax, yCoord
call WriteInt
mov edx, offset rightPrt
call WriteString

ret

PrintPlayerPos ENDP

; Method for updating the chars on the Gameboard
; Parameters: EAX (X coordinate) EBX (Y coordinate)
; Parameters: EAX = X, EBX = Y
ChangeCharAt PROC
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

; Used to update player position from Input
; Parameters EAX = new X EBX = new Y
SetPlayerPos PROC
mov xCoord, eax
mov yCoord, ebx
ret
SetPlayerPos ENDP

; Called first updates coordinate relative to (player input)
; Input checks for movement -> Set Player Position is called every ms - > 
; GetPlayerPos called every ms -> character follows head pos
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
mov ebx, 5
mov xCoord, 56 ; Set player position
mov yCoord, 5 ; Set player position
mov newChar, 25CBh
call ChangeCharAt
mov eax, 56
mov ebx, 4
mov newChar, '|'
call ChangeCharAt
mov eax, 57
mov ebx, 4
mov newChar, '\'
call ChangeCharAt
mov eax, 55
mov ebx, 4
mov newChar, '/'
call ChangeCharAt
mov eax, 57
mov ebx, 3
mov newChar, '\'
call ChangeCharAt
mov eax, 55
mov ebx, 3
mov newChar, '/'
call ChangeCharAt


ret
SpawnPlayer ENDP

StartPlatform PROC

mov eax, 54
mov ebx, 2
mov newChar, 2588h
call ChangeCharAt
mov eax, 55
mov ebx, 2
mov newChar, 2588h
call ChangeCharAt
mov eax, 56
mov ebx, 2
mov newChar, 2588h
call ChangeCharAt
mov eax, 57
mov ebx, 2
mov newChar, 2588h
call ChangeCharAt
mov eax, 58
mov ebx, 2
mov newChar, 2588h
call ChangeCharAt
mov eax, 54
mov ebx, 1
mov newChar, 2588h
call ChangeCharAt
mov eax, 55
mov ebx, 1
mov newChar, 2588h
call ChangeCharAt
mov eax, 56
mov ebx, 1
mov newChar, 2588h
call ChangeCharAt
mov eax, 57
mov ebx, 1
mov newChar, 2588h
call ChangeCharAt
mov eax, 58
mov ebx, 1
mov newChar, 2588h
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