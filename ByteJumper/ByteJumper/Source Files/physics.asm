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



JUMP_DURATION = 2
; PHYSICS THREAD

.data
isJumping BYTE 0
isGrounded BYTE 1
direction DWORD 4 dup(?)
xCoord DWORD ?
yCoord DWORD ?
newChar WORD ?
textMsg BYTE "Test"
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
    mov threadHandle, eax   ; store handle if needed
    ret
  StartPhysicsThread ENDP


 Gravity PROC
 groundCheckLoop_:
   
    call GroundCheck
    mov dl, isGrounded
    call GroundCheckMsg@0
    mov eax, 1
    call Delay
    mov dl, isJumping
    call JumpCheckingMsg@0
    cmp dl, 1
    jne applyGravity_
    mov ecx, 0
    ; This is where jumping loop happens
    ; Need a seperate thread for this
    noGravity_:
    push ecx
    cmp ecx, 6 ; Jump height
    je endJump_
    call GroundCheck
    mov dl, isGrounded
    cmp dl, 1
    je endJump_
    ; JUMP MOVEMENT NEED TO FIX
    mov eax, ecx
    imul eax, ecx        ; eax = ecx
    imul eax, 2          ; adjust scale 
    add eax, 1         ; base delay
    call Delay
    mov edx, 2 ; EDX is direction to go up
    call JumpProc
    pop ecx
    inc ecx
    jmp noGravity_
    
    applyGravity_:
    call GroundCheck
    mov dl, isGrounded
    cmp dl, 1
    je groundCheckLoop_
    ; Move player down to simulate gravity

    jmp groundCheckLoop_
    endJump_:
    mov isJumping, 0
    jmp groundCheckLoop_
    
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

    ; -------- Clear one below torso --------
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx
    sub ebx,2                  
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; Update right arm
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx

    mov eax, xCoord
    mov ebx, yCoord
    dec ebx 
    inc eax 
    mov ecx, '\'
    call SetNewChar@0
    call ChangeCharAt@0
    
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx
    sub ebx, 2
    inc eax
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; Update left arm
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx

    mov eax, xCoord
    mov ebx, yCoord
    dec ebx
    dec eax 
    mov ecx, '/'
    call SetNewChar@0
    call ChangeCharAt@0

    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx
    sub ebx, 2
    dec eax
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    ; Update right leg
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx

    mov eax, xCoord
    mov ebx, yCoord
    sub ebx, 2
    inc eax 
    mov ecx, '\'
    call SetNewChar@0
    call ChangeCharAt@0
     
    mov edx, direction
    cmp edx, 2 ; For jumping
    jne skipReplace1_
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx
    sub ebx, 3
    inc eax
    mov ecx, ' '
    call SetNewChar@0
    call ChangeCharAt@0
    skipReplace1_:

; Update left leg
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx

    mov eax, xCoord
    mov ebx, yCoord
    sub ebx, 2
    dec eax 
    mov ecx, '/'
    call SetNewChar@0
    call ChangeCharAt@0
    
    mov edx, direction
    cmp edx, 2 ; For jumping
    jne skipReplace2_
    call GetPlayerXy@0         ; EAX = x (head), EBX = y (head)
    mov xCoord, eax
    mov yCoord, ebx
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
    ret
GroundCheck ENDP

JumpProc PROC
mov direction, edx
    call GetPlayerXy@0
    Jump_:
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


END 