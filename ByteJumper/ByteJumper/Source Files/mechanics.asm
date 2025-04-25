

INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib 

EXTERN WriteConsoleW@20 : PROC  ;  declare external WinAPI
EXTERN Timer@0 : PROC
EXTERN WriteConsoleW@20 : PROC  ;  declare external WinAPI
EXTERN GetStdHandle@4 : PROC
EXTERN SetConsoleCursorInfo@8 : PROC
EXTERN StartInputThread@0 : PROC
EXTERN StartPhysicsThread@0 : PROC

; SCREEN HEIGHT AND WIDTH
ROWS = 25 ; Y
COLS = 120 ; X  

; PLAYER START POSITION
STARTX = 56
STARTY = 5

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
; STRINGS AND CHARACTERS
commaStr DWORD " , ", 0
leftPrt DWORD " ( ", 0
rightPrt DWORD " ) ", 0
temp DWORD ? ; Previous Location
gameBoard WORD ROWS * COLS DUP(' ') ; 
msg BYTE "Loading Game...", 0   ; Null-terminated string
inputStr BYTE 32 DUP(0)    ; reserve 32 bytes for output message ; Updated based on current input for debugging
fpsBuffer DWORD ?
fpsMsg BYTE "FPS: ", 0
frameCount DWORD 0
; Index = row * COLS + col This gives you the correct index into the flat array as if it were 2D
; PLAYER LOGIC
isGrounded BYTE 1
.code

GameEngine PROC 
 ; Create new thread for player input
    call StartPhysicsThread@0
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

mov eax, 0    ; time in milliseconds
; This is where the main game functions are called
mainLoop_:
mov eax, 1   ; time in milliseconds
call Delay       
mov edx, 0   ; column
mov ecx, 0     ; row
; Timer
inc frameCount
cmp frameCount, 20
jne skipTimerUpdate
;call Timer@0
mov frameCount, 0
skipTimerUpdate:
call Gotoxy    ;  move the cursor
call GetPlayerPos
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
;GetCoordinate PROC
    ;xor edx, edx            ; Clear EDX before DIV
    ;mov ebx, COLS			; Adjust for width of board
    ;div ebx					; Divides EDX by EAX        
	;mov ecx, eax            ; Save row
	;call Crlf               ; Move to new line before printing
	; Print col
	;mov xCoord, edx         ; Store X value
    ;mov eax, edx
    ;call WriteDec
	; Print comma
    ;mov edx, OFFSET commaStr
    ;call WriteString
	; Print row
	;mov eax, ROWS       ; use the ROWS constant
	;sub eax, ecx        ; eax = ROWS - row
	;mov YCoord, eax     ; store the flipped Y value
	;call WriteDec       ; print flipped Y
	;ret
;GetCoordinate ENDP

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
; FPS TEXT
mov edx, offset leftPrt
call WriteString
mov edx, offset fpsMsg
call WriteString
mov eax, fpsBuffer
call WriteDec
mov edx, offset rightPrt
call WriteString
; INPUT TEXT
mov edx, offset inputStr
call WriteString
; FPS TEXT



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
; Used by physics to alter player position
GetPlayerXy PROC
mov eax, xCoord
mov ebx, yCoord
ret
GetPlayerXy ENDP


; Used to update player position from Input
; Parameters EAX = new X EBX = new Y
SetPlayerPos PROC
mov xCoord, eax
mov yCoord, ebx
ret
SetPlayerPos ENDP
; Used for updating char from different location
; EDX = new char
SetNewChar PROC
mov newChar, dx
ret
SetNewChar ENDP

; Called from input.asm EDX = new message address
SetInputMsg PROC
; EDX = address of source null-terminated string
    ; Destination = inputStr
    push esi
    push edi

    mov esi, edx             ; source string
    mov edi, OFFSET inputStr  ; destination buffer
    mov ecx, 32               ; max length (buffer size)

copyLoop_:
    lodsb                     ; load byte from [esi] AL
    stosb                     ; store AL into [edi]
    test al, al               ; check if null terminator
    jz done_
    loop copyLoop_

done_:
    pop edi
    pop esi
    ret
SetInputMsg ENDP

; Update FPS msg EDX = new FRAME RATE from input.asm
SetFpsBuffer PROC
mov fpsBuffer, edx 
ret
SetFpsBuffer ENDP
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

; Head position updated from input.asm and then Getplayer position will update body relative to head
SetHeadPos PROC

ret
SetHeadPos ENDP

SpawnPlayer PROC 
mov eax, STARTX
mov ebx, STARTY
mov xCoord, 56 ; Set player position from head Pos
mov yCoord, 5 ; Set player position
mov newChar, 1
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









END