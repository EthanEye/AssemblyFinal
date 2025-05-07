INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib
EXTERN ChangeCharAt@0 : PROC
EXTERN GetCharAt@0 : PROC
EXTERN GetPlayerXy@0 : PROC
EXTERN SetNewChar@0 : PROC
EXTERN SetPlayerPos@0 : PROC
EXTERN CreateThread@24 : PROC
EXTERN GroundCheckMsg@0 : PROC
EXTERN JumpCheckingMsg@0 : PROC
EXTERN CheckForCollisions@0 : PROC
EXTERN EndGame@0 : PROC
EXTERN ExitThread@4 : PROC


; PHYSICS THREAD

.data
gravityDelay DWORD 80   ; Initial delay time (ms)
isJumping BYTE 0
isGrounded BYTE 1
threadRunning BYTE 0
direction DWORD 4 dup(?)
xCoord DWORD ?
yCoord DWORD ?
newChar WORD ?
textMsg BYTE "Test"
collisionLock DWORD 0
; GAME PHYSICS

threadID DWORD ?
threadHandle DWORD ?
.code

StartPhysicsThread PROC

    ; Create the thread
    push 0                  ; lpThreadId (optional)
    push 0                  ; dwCreationFlags (run immediately)
    push 0                  ; lpParameter (none)
    push OFFSET Gravity ; lpStartAddress
    push 0                  ; dwStackSize (default)
    push 0                  ; lpThreadAttributes (default)
    call CreateThread@24
    mov threadHandle, eax   ; Store handle if needed
    mov threadRunning, 1
    ret
  StartPhysicsThread ENDP


 Gravity PROC
    mov eax, 500
    call Delay
groundCheckLoop_:
    ; Check thread 
    mov dl, threadRunning
    cmp dl, 0
    je endGravityLoop_
    mov eax, 1
    call Delay
    call GroundCheck
    mov dl, isGrounded
    call GroundCheckMsg@0
    cmp dl, 1
    je groundCheckLoop_
    mov dl, isJumping
    call JumpCheckingMsg@0
    cmp dl, 1
    jne applyGravity_

    ; --- Jumping Loop ---
    mov ecx, 0
noGravity_:
    push ecx
    cmp ecx, 8             ; Jump height limit
    je endJump_

    call GroundCheck
    mov dl, isGrounded
    cmp dl, 1
    je endJump_

    ; Delay increases as you go up
    mov eax, ecx
    imul eax, ecx          ; eax = ecx * ecx
    imul eax, 2            ; scale adjustment
    add eax, 1             ; base delay
    call Delay

    mov edx, 2             ; 2 = direction UP
    call CheckForCollisions@0
    cmp al, 1
    je endJump_
    call JumpProc
    
   
    pop ecx
    inc ecx
    jmp noGravity_

applyGravity_:
    
    ; Check jumping status again before moving down
    mov dl, isJumping
    cmp dl, 1
    je groundCheckLoop_   ; If still jumping, skip applying gravity

    call GroundCheck
    mov dl, isGrounded
    cmp dl, 1
    je groundCheckLoop_   ; If grounded, skip applying gravity

    mov eax, gravityDelay
    call Delay

    ;  Check again before moving
    call GravityProc      ; Only now move downgravityCheck

    ; Decrease delay (faster fall)
    mov eax, gravityDelay
    sub eax, 15                ; decrease by 5 ms each time
    cmp eax, 10               ; limit: don't go below 20ms
    jl skipUpdate
    mov gravityDelay, eax
    skipUpdate:
    jmp groundCheckLoop_

endJump_:
    mov isJumping, 0        ; Reset jumping state
    mov gravityDelay, 80   ; Reset gravity delay
    jmp groundCheckLoop_

endGravityLoop_:
    
ret
Gravity ENDP



  
  ; All inputs call this method to update player position
  ; EDX = direction 1- DOWN 2 - JUMP, 3 LEFT, 4 RIGHT
Movement PROC
    mov direction, edx
    call GetPlayerXy@0
    Jump_:
    cmp edx, 2
    jne Left_
    call CheckForCollisions@0
    cmp al, 1 
    je endMovementProc_ ; Collision 
    cmp isGrounded, 1     ; Check if on ground
    jne Left_             ; If not grounded, skip jump
    mov dl, 1
    mov isJumping, dl
    call JumpCheckingMsg@0 
    ; 1. Get player position
    call GetPlayerXy@0
    mov xCoord, eax
    mov yCoord, ebx

    ; 2. Clear old position
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0

    ; 3. Move Up
    inc yCoord

    ; 4. Draw new position
    mov ecx, 'O'
    mov eax, xCoord
    mov ebx, yCoord
    call SetNewChar@0
    call ChangeCharAt@0

    ; 5. Save updated position
    mov eax, xCoord
    mov ebx, yCoord
    call SetPlayerPos@0
    call UpdatePlayerBody
   
    Left_:
    cmp edx, 3
    jne Right_
    call CheckForCollisions@0
    cmp al, 1 
    je endMovementProc_ ; Collision 
    ; 1. Get player position
    call GetPlayerXy@0
    mov xCoord, eax
    mov yCoord, ebx
    ; 2. Clear old position
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; Move left
    dec xCoord
    ; 4. Draw new position
    mov ecx, 'O'
    mov eax, xCoord
    mov ebx, yCoord
    call SetNewChar@0
    call ChangeCharAt@0
    ; 5. Save updated position
    mov eax, xCoord
    mov ebx, yCoord
    call SetPlayerPos@0
    call UpdatePlayerBody
    mov ecx, ' '
    call GetPlayerXy@0
    add eax, 2
    sub ebx, 1
    call SetNewChar@0
    call ChangeCharAt@0
    call GetPlayerXy@0
    add eax, 2
    sub ebx, 2
    call SetNewChar@0
    call ChangeCharAt@0
    Right_:
    cmp edx, 4
    jne endMovementProc_
    call CheckForCollisions@0
    cmp al, 1 
    je endMovementProc_ ; Collision 
    ; 1. Get player position
    call GetPlayerXy@0
    mov xCoord, eax
    mov yCoord, ebx
    ; 2. Clear old position
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; 3. Move right
    inc XCoord
    ; 4. Draw new position
    mov ecx, 'O'
    mov eax, xCoord
    mov ebx, yCoord
    call SetNewChar@0
    call ChangeCharAt@0
    ; 5. Save updated position
    mov eax, xCoord
    mov ebx, yCoord
    call SetPlayerPos@0
    call UpdatePlayerBody
    mov ecx, ' '
    call GetPlayerXy@0
    sub eax, 2
    sub ebx, 1
    call SetNewChar@0
    call ChangeCharAt@0
    call GetPlayerXy@0
    sub eax, 2
    sub ebx, 2
    call SetNewChar@0
    call ChangeCharAt@0

    endMovementProc_:
    mov edx, 0
    ret
    Movement ENDP

UpdatePlayerBody PROC


 ; 1. Get head position
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx
    ; -------- Draw torso below head --------
    mov eax, xCoord
    mov ebx, yCoord
    dec ebx                    ; torso = head Y + 1
    mov ecx, '|'
    call SetNewChar@0
    call ChangeCharAt@0

    ; -------- Clear two below head --------
    mov eax, xCoord
    mov ebx, yCoord
    sub ebx, 2                  
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; Update right arm
    mov eax, xCoord
    mov ebx, yCoord
    dec ebx 
    inc eax 
    mov ecx, '\'
    call SetNewChar@0
    call ChangeCharAt@0
    mov eax, xCoord
    mov ebx, yCoord
    inc eax
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; Update left arm
    mov eax, xCoord
    mov ebx, yCoord
    dec ebx
    dec eax 
    mov ecx, '/'
    call SetNewChar@0
    call ChangeCharAt@0
    
    mov eax, xCoord
    mov ebx, yCoord
    dec eax
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; Update right leg
    mov eax, xCoord
    mov ebx, yCoord
    sub ebx, 2
    inc eax 
    mov ecx, '\'
    call SetNewChar@0
    call ChangeCharAt@0

    mov dl, isJumping
    cmp dl, 1
    jne skipReplace1_
    mov eax, xCoord
    mov ebx, yCoord
   
    sub ebx, 3
    inc eax
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    
    skipReplace1_:

; Update left leg
  

    mov eax, xCoord
    mov ebx, yCoord
    sub ebx, 2
    dec eax 
    mov ecx, '/'
    call SetNewChar@0
    call ChangeCharAt@0

    mov dl, isJumping
    cmp dl, 1
    jne skipReplace2_
    mov eax, xCoord
    mov ebx, yCoord
    sub ebx, 3
    dec eax
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    skipReplace2_:
   

    ret
UpdatePlayerBody ENDP

; DX = 1 if player is touching ground DX = 0 if player not touching ground
GroundCheck PROC
    call GetPlayerXy@0               ; EAX = x (head), EBX = y (head)
    ; First check - straight down
    sub ebx, 3
    call GetCharAt@0
    cmp ax, 2588h 
    je isGrounded_

    ; Second check - down right one
    call GetPlayerXy@0
    sub ebx, 3
    inc eax
    call GetCharAt@0
    cmp ax, 2588h 
    je isGrounded_

    ; Third check - down left one
    call GetPlayerXy@0
    sub ebx, 3
    dec eax
    call GetCharAt@0
    cmp ax, 2588h 
    je isGrounded_
   

    ; If no ground detected
    jmp notGrounded_

isGrounded_:
    mov BYTE PTR isGrounded, 1
    jmp endGroundCheck_

notGrounded_:
    mov BYTE PTR isGrounded, 0

endGroundCheck_:
    call GroundCheckMsg@0
; Check game over
call GetPlayerXy@0         ; EAX = x, EBX = y
; If y is less than 2 end the game
cmp ebx, 1
je gameOver_
jmp endBoundCheck_
gameOver_:

mov threadRunning, 0
call EndGame@0



exit

endBoundCheck_:

ret
GroundCheck ENDP

JumpProc PROC

    ; 1. Get player position
    call GetPlayerXy@0
    mov xCoord, eax
    mov yCoord, ebx

    ; 2. Clear old position
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0

    ; 3. Move Up
    inc yCoord

    ; 4. Draw new position
    mov ecx, 'O'
    mov eax, xCoord
    mov ebx, yCoord
    call SetNewChar@0
    call ChangeCharAt@0

    ; 5. Save updated position
    mov eax, xCoord
    mov ebx, yCoord

    call SetPlayerPos@0
    call UpdatePlayerBody

ret
JumpProc ENDP

GravityProc PROC
  
; 1. Get player position
    call GetPlayerXy@0
    mov xCoord, eax
    mov yCoord, ebx

    ; 2. Clear old position
   
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
  
    ; 3. Move down
    dec yCoord

    ; 4. Draw new position
    mov ecx, 'O'
    mov eax, xCoord
    mov ebx, yCoord
    call SetNewChar@0
    call ChangeCharAt@0

    ; 5. Save updated position
    mov eax, xCoord
    mov ebx, yCoord
    call SetPlayerPos@0
    call UpdatePlayerBody

ret
GravityProc ENDP



EndPhysicsThread PROC
push 0              ; Exit code (0 = success)
call ExitThread@4     ; Gracefully end this thread

ret
EndPhysicsThread ENDP

END 