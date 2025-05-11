

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
EXTERN EndInputThread@0 : PROC
EXTERN EndPhysicsThread@0 : PROC
EXTERN GameOver@0 : PROC
EXTERN ShowHowToMenu@0 : PROC
EXTERN CreatePlatform@0 : PROC

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
newChar WORD 2584h
; STRINGS AND CHARACTERS
commaStr DWORD ",", 0
leftPrt DWORD " =X ", 0
rightPrt DWORD " =Y ", 0
temp DWORD ? ; Previous Location
; DISPLAY ARRAY
gameBoard WORD ROWS * COLS DUP(' ') ; 
groundedMsg BYTE " Grounded: ", 0
jumpingMsg BYTE " Jumping: " , 0
inputStr BYTE 32 DUP(0)         ; reserve 32 bytes for output message ; Updated based on current input for debugging
fpsBuffer DWORD ?
fpsMsg BYTE " FPS: ", 0
frameCount DWORD 0
                                ; Index = row * COLS + col This gives you the correct index into the flat array as if it were 2D
checkGrounded BYTE 1            ; Updated from physics.asm make sure its set to 1
checkJumping BYTE 0             ;Updated from physics.asm
gameRunning BYTE 1
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
   
mov eax, 53
mov ebx, 1
call CreatePlatform@0

call SpawnPlayer


; This is where the main game functions are called
mainLoop_:
mov eax, 1              
call Delay              ; Time in milliseconds
mov edx, 0              ; Column
mov ecx, 0              ; Row
mov dl, gameRunning 
cmp dl , 0
je mainLoop_
mov al, checkJumping
cmp al, 1
jne skipPlatforms_
;Update
skipPlatforms_:
call Gotoxy             ; Move the cursor
call GetCurrentFrame    ; Print Current Array
call PrintPlayerPos     ; Current player pos

jmp mainLoop_

ret
GameEngine ENDP

GetCurrentFrame PROC

mov eax, cyan
call SetTextColor
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
    mov eax, green
    call SetTextColor

    ; Line 0 – Print X and Y
    mov dh, 0
    mov dl, 97
    call Gotoxy
    mov edx, offset leftPrt
    call WriteString
    mov eax, xCoord
    call WriteInt
    mov edx, offset rightPrt
    call WriteString
    mov eax, yCoord
    call WriteInt

    ; Line 1 – FPS
    mov dh, 0
    mov dl, 110
    call Gotoxy
    mov edx, offset fpsMsg
    call WriteString
    mov eax, fpsBuffer
    call WriteDec

    ; Line 2 – Input text (static unless you update inputStr dynamically)
    mov dh, 0
    mov dl, 52
    call Gotoxy
    mov edx, offset inputStr
    call WriteString

    ; Line 3 – Grounded
    ;mov dh, 0
    ;mov dl, 85
    ;call Gotoxy
    ;mov edx, offset groundedMsg
    ;call WriteString
    ;movzx eax, BYTE PTR checkGrounded
    ;call WriteDec

    ; Line 4 – Jumping
    ;mov dh, 0
    ;mov dl, 100
    ;call Gotoxy
    ;mov edx, offset jumpingMsg
    ;call WriteString
    ;movzx eax, BYTE PTR checkJumping
    ;call WriteDec

    ; Timer update every 20 frames
    inc frameCount
    cmp frameCount, 20
    jne skipTimerUpdate
    call Timer@0
    mov frameCount, 0
skipTimerUpdate:

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

; Used by physics to alter player position
GetPlayerXy PROC
mov eax, xCoord
mov ebx, yCoord
ret
GetPlayerXy ENDP

GetCharAt PROC
; Flip Y: edx = ROWS - ebx
    mov edx, ROWS
    sub edx, ebx              ; flippedY

    ; Calculate index = (flippedY * COLS) + X
    imul edx, COLS            ; edx = row * COLS
    add edx, eax              ; edx = (row * COLS) + col

    ; Scale index for WORD array (2 bytes per element)
    shl edx, 1                ; edx = edx * 2

    ; Load char at X, Y into ax
    mov ax, WORD PTR gameBoard[edx]

ret
GetCharAt ENDP


; Used to update player position from Input
; Parameters EAX = new X EBX = new Y
SetPlayerPos PROC
mov xCoord, eax
mov yCoord, ebx
ret
SetPlayerPos ENDP
; Used for updating char from different location
; ECX = new char
SetNewChar PROC
mov newChar, cx
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

GroundCheckMsg PROC
    cmp dl, 1                              ; Check for ground
    jne notGrounded_
    isGrounded_:
    mov checkGrounded, 1                   ; Is Grounded
    jmp endGroundCheck_
    notGrounded_:
    mov checkGrounded, 0                   ; Not Grounded
    endGroundCheck_:
ret
GroundCheckMsg ENDP

JumpCheckingMsg PROC
    cmp dl, 1                              ; Check if jumping 
    jne notJumping_
    isJumping_:
    mov checkJumping, 1                   ; Is jumping 
    jmp endJumpingCheck_
    notJumping_:
    mov checkJumping, 0                   ; Not jumping
    endJumpingCheck_:
ret
JumpCheckingMsg ENDP



SpawnPlayer PROC 
mov eax, STARTX
mov ebx, STARTY
mov xCoord, 56 ; Set player position from head Pos
mov yCoord, 5 ; Set player position
mov newChar, 'O'
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


EndGame PROC
 mov gameRunning, 0
 mov esi, OFFSET gameBoard        ; point to start of board
 mov ecx, ROWS * COLS             ; total number of characters

fillLoop:
    mov WORD PTR [esi], ' '          ; store space character
    add esi, 2                       ; move to next WORD
    loop fillLoop
mov edx, 0              ; Column
mov ecx, 0              ; Row
call Gotoxy             ; Move the cursor
call ClrScr
call GameOver@0
call EndInputThread@0
call EndPhysicsThread@0

ret
EndGame ENDP

CheckForCollisions PROC
; EDX = direction 1- DOWN 2 - JUMP, 3 LEFT, 4 RIGHT
; RETURNS 1 in AL if collision found 0 if not
call GetPlayerXy         ; EAX = x (head), EBX = y (head)
mov xCoord, eax
mov yCoord, ebx
cmp edx, 2
jne skipJumpCollision_
; Check jump collisions 
mov eax, xCoord
mov ebx, yCoord
add ebx, 1
call GetCharAt         
cmp ax, 2588h 
je collisionFound_
mov eax, xCoord
mov ebx, yCoord
add eax, 1
add ebx, 1
call GetCharAt         
cmp ax, 2588h 
je collisionFound_
mov eax, xCoord
mov ebx, yCoord
sub eax, 1
add ebx, 1
call GetCharAt         
cmp ax, 2588h 
je collisionFound_
jmp collisionNotFound_ 
skipJumpCollision_:
cmp edx, 4
jne skipRightCollision_
; Check right collisions
mov eax, xCoord
mov ebx, yCoord
add eax, 3
call GetCharAt          
cmp ax, 2588h 
je collisionFound_
mov eax, xCoord
mov ebx, yCoord
add eax, 3
sub ebx, 1
;mov newChar, '?'
;call ChangeCharAt
call GetCharAt          
cmp ax, 2588h 
je collisionFound_
mov eax, xCoord
mov ebx, yCoord
add eax, 3
sub ebx, 2
call GetCharAt          
cmp ax, 2588h 
je collisionFound_
; This one is only for if player is not grounded
mov dl, checkGrounded
cmp dl, 1
je skipRightCollision_
mov eax, xCoord
mov ebx, yCoord
add eax, 3
sub ebx, 3
call GetCharAt          
cmp ax, 2588h 
je collisionFound_
jmp collisionNotFound_ 
skipRightCollision_:
cmp edx, 3
jne skipLeftCollision_
; Check left collisions
mov eax, xCoord
mov ebx, yCoord
sub eax, 3
call GetCharAt          
cmp ax, 2588h 
je collisionFound_
mov eax, xCoord
mov ebx, yCoord
sub eax, 3
sub ebx, 1
call GetCharAt          
cmp ax, 2588h 
je collisionFound_
mov eax, xCoord
mov ebx, yCoord
sub eax, 3
sub ebx, 2
call GetCharAt          
cmp ax, 2588h 
je collisionFound_
; This one is only for if player is not grounded
mov dl, checkGrounded
cmp dl, 1
je skipRightCollision_
mov eax, xCoord
mov ebx, yCoord
sub eax, 3
sub ebx, 3
call GetCharAt          
cmp ax, 2588h 
je collisionFound_
skipLeftCollision_:
jmp endCollisionCheck_

collisionFound_:
mov al, 1
jmp endCollisionCheck_
collisionNotFound_:
mov al, 0
endCollisionCheck_:

ret
CheckForCollisions ENDP




END